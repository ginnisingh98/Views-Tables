--------------------------------------------------------
--  DDL for Package Body PO_CORE_S
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_CORE_S" AS
-- $Header: POXCOC1B.pls 120.24.12010000.28 2014/06/20 07:48:59 shipwu ship $


-----------------------------------------------------------------------------
-- Declare private package variables.
-----------------------------------------------------------------------------

-- Debugging

g_pkg_name                       CONSTANT
   VARCHAR2(30)
   := 'PO_CORE_S'
   ;
g_log_head                       CONSTANT
   VARCHAR2(50)
   := 'po.plsql.' || g_pkg_name || '.'
   ;

g_debug_stmt                     CONSTANT
   BOOLEAN
   := PO_DEBUG.is_debug_stmt_on
   ;
g_debug_unexp                    CONSTANT
   BOOLEAN
   := PO_DEBUG.is_debug_unexp_on
   ;


D_PACKAGE_BASE CONSTANT VARCHAR2(100) := PO_LOG.get_package_base(g_pkg_name);
-----------------------------------------------------------------------------
-- Declare private package types.
-----------------------------------------------------------------------------


-- Bug 3292870
TYPE g_rowid_char_tbl IS TABLE OF VARCHAR2(18);



-----------------------------------------------------------------------------
-- Define procedures.
-----------------------------------------------------------------------------

PROCEDURE get_open_encumbrance_stats(
   p_doc_type                       IN             VARCHAR2
,  p_doc_level                      IN             VARCHAR2
,  p_doc_level_id                   IN             NUMBER
,  x_reserved_count                 OUT NOCOPY     NUMBER
,  x_unreserved_count               OUT NOCOPY     NUMBER
,  x_prevented_count                OUT NOCOPY     NUMBER
);

-- <GC FPJ START>
-- Prototype of get_gc_amount_released

FUNCTION get_gc_amount_released
(
    p_po_header_id         IN NUMBER,
    p_convert_to_base      IN BOOLEAN := FALSE
) RETURN NUMBER;

-- <GC FPJ END>


/* ===========================================================================

  FUNCTION NAME : get_ussgl_option

  DESCRIPTION   :

  CLIENT/SERVER : SERVER

  LIBRARY NAME  :

  OWNER         : SUBHAJIT PURKAYASTHA

  PARAMETERS    :

  ALGORITHM     : Use fnd_profile.get function to retreive the value

  NOTES         :  Add sqlcode param in  the call to po_message_c.sql_error
                   - SI 04/08

=========================================================================== */
FUNCTION get_ussgl_option RETURN VARCHAR2 is

  x_progress      VARCHAR2(3) := NULL;
  x_option_value  VARCHAR2(1);
begin
  x_progress := 10;

  fnd_profile.get('USSGL_OPTION',x_option_value);

  RETURN(x_option_value);

  EXCEPTION
  WHEN OTHERS THEN
     po_message_s.sql_error('get_ussgl_option', x_progress, sqlcode);
  RAISE;

end get_ussgl_option;

/* ===========================================================================

  FUNCTION NAME : get_gl_set_of_bks_id

  DESCRIPTION   :

  CLIENT/SERVER : SERVER

  LIBRARY NAME  :

  OWNER         : SUBHAJIT PURKAYASTHA

  PARAMETERS    :

  ALGORITHM     : Use fnd_profile.get function to retreive the value

  NOTES         :

=========================================================================== */
FUNCTION get_gl_set_of_bks_id RETURN VARCHAR2 is

  x_progress      VARCHAR2(3) := NULL;
  x_option_value  VARCHAR2(3);
begin
  x_progress := 10;

/* Replaced the profile option name from 'GL_SET_OF_BKS_ID' to GL_ACCESS_SET_ID'*/

 fnd_profile.get('GL_ACCESS_SET_ID',x_option_value); --<R12 Ledger Architecture>

  RETURN(x_option_value);

  EXCEPTION
  WHEN OTHERS THEN
     po_message_s.sql_error('get_gl_set_of_bks_id', x_progress, sqlcode);
  RAISE;

end get_gl_set_of_bks_id;

/* ===========================================================================
  FUNCTION get_conversion_rate (
		x_set_of_books_id       NUMBER,
		x_from_currency		VARCHAR2,
		x_conversion_date	DATE,
		x_conversion_type	VARCHAR2 DEFAULT NULL ) RETURN NUMBER;

  DESCRIPTION    : Returns the rate between the two currencies for a
                   given conversion date and conversion type.
  CLIENT/SERVER  : SERVER

  LIBRARY NAME   :

  OWNER          : GKELLNER

  PARAMETERS     :   x_set_of_books_id		Set of Books you are in
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
		x_set_of_books_id       NUMBER,
		x_from_currency		VARCHAR2,
		x_conversion_date	DATE,
		x_conversion_type	VARCHAR2 DEFAULT NULL )

  RETURN NUMBER IS

  x_conversion_rate NUMBER := 0;
  x_progress  VARCHAR2(3) := '000';

  BEGIN

      x_conversion_rate := gl_currency_api.get_rate (
          x_set_of_books_id,
          x_from_currency  ,
	  x_conversion_date,
	  x_conversion_type);

      -- <2694908>: Truncate rate value (as done in PO_CURRENCY_SV.get_rate( ))
      x_conversion_rate := round(x_conversion_rate, 15);

      return (x_conversion_rate);

   EXCEPTION
   WHEN gl_currency_api.no_rate THEN
       return(NULL);
   WHEN no_data_found THEN
       return(NULL);
   WHEN OTHERS THEN
       RAISE;

  END get_conversion_rate;

/* ===========================================================================
  PROCEDURE NAME : get_org_sob (x_org_id    OUT NOCOPY NUMBER,
                                x_org_name  OUT NOCOPY VARCHAR2,
                                x_sob_id    OUT NOCOPY NUMBER)

  DESCRIPTION    :

  CLIENT/SERVER  : SERVER

  LIBRARY NAME   :

  OWNER          : SUBHAJIT PURKAYASTHA

  PARAMETERS     : x_org_id   - Return's the Id of the organization
                   x_org_name - Return's the name of the organization
                   x_sob_id   - Return's the SOB id

  ALGORITHM      : AOL function fnd_profile.get('MFG_ORGANIZATION_ID') returns
                   the default id of the org.
                   If id <> 0 then
                     retreive organization name and sob id from
                     org_organization_definitions table based on org_id
                   else
                     retreive purchasing organization from
                     financials_system_parameters and gl_sets_of_books table

  NOTES          :

=========================================================================== */

PROCEDURE get_org_sob (x_org_id    OUT NOCOPY NUMBER,
                       x_org_name  OUT NOCOPY VARCHAR2,
                       x_sob_id    OUT NOCOPY NUMBER) is
    x_progress  VARCHAR2(3) := NULL;
    org_id      NUMBER;

/** <UTF8 FPI> **/
/** tpoon 9/27/2002 **/
/** Changed org_name to use %TYPE **/
--    org_name    VARCHAR2(60);
    org_name    hr_all_organization_units.name%TYPE;

    sob_id      NUMBER;
begin
  x_progress := 10;
  fnd_profile.get('MFG_ORGANIZATION_ID',org_id);
  if org_id <> 0 then

    x_progress := 20;
    select  organization_name,
            set_of_books_id
    into    org_name,
            sob_id
    FROM   org_organization_definitions
    WHERE  organization_id = org_id ;

  else
    --Get purchasing organization
    x_progress := 30;
    SELECT  fsp.inventory_organization_id,
            fsp.set_of_books_id,
            sob.name
    INTO    org_id,
            sob_id,
            org_name
    FROM    financials_system_parameters fsp,
            gl_sets_of_books sob
    WHERE   fsp.set_of_books_id = sob.set_of_books_id;

  end if;
  x_progress := 40;
  --Associate each of the OUT NOCOPY variable with local variable

  x_org_id   := org_id;
  x_org_name := org_name;
  x_sob_id   := sob_id;

  EXCEPTION
  WHEN OTHERS THEN
    po_message_s.sql_error('get_org_sob', x_progress, sqlcode);
    RAISE;
  end get_org_sob;

/* ===========================================================================
  PROCEDURE NAME: get_po_parameters

  DESCRIPTION   :

  CLIENT/SERVER : SERVER

  LIBRARY NAME  :

  OWNER         : SUBHAJIT PURKAYASTHA

  PARAMETERS    : x_currency_code
                  x_coa_id
                  x_po_encumberance_flag
                  x_req_encumberance_flag
                  x_sob_id
                  x_ship_to_location_id
                  x_bill_to_location_id
                  x_fob_lookup_code
                  x_freight_terms_lookup_code
                  x_terms_id
                  x_default_rate_type
                  x_taxable_flag
                  x_receiving_flag
                  x_enforce_buyer_name_flag
                  x_enforce_buyer_auth_flag
                  x_line_type_id
                  x_manual_po_num_type
                  x_po_num_code
                  x_price_lookup_code
                  x_invoice_close_tolerance
                  x_receive_close_tolerance
                  x_security_structure_id
                  x_expense_accrual_code
                  x_inv_org_id
                  x_rev_sort_ordering
                  x_min_rel_amount
                  x_notify_blanket_flag
                  x_budgetary_control_flag
                  x_user_defined_req_num_code
                  x_rfq_required_flag
                  x_manual_req_num_type
                  x_enforce_full_lot_qty
                  x_disposition_warning_flag
                  x_reserve_at_completion_flag
                  x_user_defined_rcpt_num_code
                  x_manual_rcpt_num_type
		  x_use_positions_flag
		  x_default_quote_warning_delay
		  x_inspection_required_flag
		  x_user_defined_quote_num_code
		  x_manual_quote_num_type
		  x_user_defined_rfq_num_code
		  x_manual_rfq_num_type
		  x_ship_via_lookup_code
		  x_qty_rcv_tolerance


  ALGORITHM     : Retreive po parameters from
                  financials_system_parameters,gl_sets_of_books,
                  po_system_parameters and rcv_parameters tables.

  NOTES         :

=========================================================================== */
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
			       x_use_positions_flag	       OUT NOCOPY VARCHAR2,
			       x_default_quote_warning_delay   OUT NOCOPY NUMBER,
		  	       x_inspection_required_flag      OUT NOCOPY VARCHAR2,
		  	       x_user_defined_quote_num_code   OUT NOCOPY VARCHAR2,
		  	       x_manual_quote_num_type	       OUT NOCOPY VARCHAR2,
		  	       x_user_defined_rfq_num_code     OUT NOCOPY VARCHAR2,
		  	       x_manual_rfq_num_type	       OUT NOCOPY VARCHAR2,
		  	       x_ship_via_lookup_code	       OUT NOCOPY VARCHAR2,
		  	       x_qty_rcv_tolerance	       OUT NOCOPY NUMBER
                              ) is

  x_progress     VARCHAR2(3) := NULL;
  x_acceptance_required_flag VARCHAR2(1) := NULL;
  -- PDOI Enhancement bug#17063664
  x_group_shipments_flag   VARCHAR2(1) := NULL;
begin
  x_progress := 10;


          get_po_parameters (  x_currency_code               => x_currency_code
                               ,x_coa_id                     => x_coa_id
                               ,x_po_encumberance_flag       => x_po_encumberance_flag
                               ,x_req_encumberance_flag      => x_req_encumberance_flag
                               ,x_sob_id                     => x_sob_id
                               ,x_ship_to_location_id        => x_ship_to_location_id
                               ,x_bill_to_location_id        => x_bill_to_location_id
                               ,x_fob_lookup_code            => x_fob_lookup_code
                               ,x_freight_terms_lookup_code  => x_freight_terms_lookup_code
                               ,x_terms_id                   => x_terms_id
                               ,x_default_rate_type          => x_default_rate_type
                               ,x_taxable_flag               => x_taxable_flag
                               ,x_receiving_flag             => x_receiving_flag
                               ,x_enforce_buyer_name_flag    => x_enforce_buyer_name_flag
                               ,x_enforce_buyer_auth_flag    => x_enforce_buyer_auth_flag
                               ,x_line_type_id               => x_line_type_id
                               ,x_manual_po_num_type         => x_manual_po_num_type
                               ,x_po_num_code                => x_po_num_code
                               ,x_price_lookup_code          => x_price_lookup_code
                               ,x_invoice_close_tolerance    => x_invoice_close_tolerance
                               ,x_receive_close_tolerance    => x_receive_close_tolerance
                               ,x_security_structure_id      => x_security_structure_id
                               ,x_expense_accrual_code       => x_expense_accrual_code
                               ,x_inv_org_id                 => x_inv_org_id
                               ,x_rev_sort_ordering          => x_rev_sort_ordering
                               ,x_min_rel_amount             => x_min_rel_amount
                               ,x_notify_blanket_flag        => x_notify_blanket_flag
                               ,x_budgetary_control_flag     => x_budgetary_control_flag
                               ,x_user_defined_req_num_code  => x_user_defined_req_num_code
                               ,x_rfq_required_flag          => x_rfq_required_flag
                               ,x_manual_req_num_type        => x_manual_req_num_type
                               ,x_enforce_full_lot_qty       => x_enforce_full_lot_qty
                               ,x_disposition_warning_flag   => x_disposition_warning_flag
                               ,x_reserve_at_completion_flag => x_reserve_at_completion_flag
                               ,x_user_defined_rcpt_num_code => x_user_defined_rcpt_num_code
                               ,x_manual_rcpt_num_type       => x_manual_rcpt_num_type
			       ,x_use_positions_flag	     => x_use_positions_flag
			       ,x_default_quote_warning_delay => x_default_quote_warning_delay
		  	       ,x_inspection_required_flag   => x_inspection_required_flag
		  	       ,x_user_defined_quote_num_code => x_user_defined_quote_num_code
		  	       ,x_manual_quote_num_type	     => x_manual_quote_num_type
		  	       ,x_user_defined_rfq_num_code  => x_user_defined_rfq_num_code
		  	       ,x_manual_rfq_num_type	     => x_manual_rfq_num_type
		  	       ,x_ship_via_lookup_code	     => x_ship_via_lookup_code
		  	       ,x_qty_rcv_tolerance	     => x_qty_rcv_tolerance
			       ,x_acceptance_required_flag   => x_acceptance_required_flag
			       ,x_group_shipments_flag       => x_group_shipments_flag
                              );

  EXCEPTION
  WHEN OTHERS THEN
    po_message_s.sql_error('get_po_parameters', x_progress, sqlcode);
    RAISE;

end get_po_parameters;

/* Bug 7518967: ER Default Acceptance Required Check : Overloading the procedure
  get_po_parameters to get the default acceptance_required_flag from
  PO_SYSTEM_PARAMETERS_ALL */

/* ===========================================================================
  PROCEDURE NAME: get_po_parameters

  DESCRIPTION   :

  CLIENT/SERVER : SERVER

  LIBRARY NAME  :

  OWNER         : SUBHAJIT PURKAYASTHA

  PARAMETERS    : x_currency_code
                  x_coa_id
                  x_po_encumberance_flag
                  x_req_encumberance_flag
                  x_sob_id
                  x_ship_to_location_id
                  x_bill_to_location_id
                  x_fob_lookup_code
                  x_freight_terms_lookup_code
                  x_terms_id
                  x_default_rate_type
                  x_taxable_flag
                  x_receiving_flag
                  x_enforce_buyer_name_flag
                  x_enforce_buyer_auth_flag
                  x_line_type_id
                  x_manual_po_num_type
                  x_po_num_code
                  x_price_lookup_code
                  x_invoice_close_tolerance
                  x_receive_close_tolerance
                  x_security_structure_id
                  x_expense_accrual_code
                  x_inv_org_id
                  x_rev_sort_ordering
                  x_min_rel_amount
                  x_notify_blanket_flag
                  x_budgetary_control_flag
                  x_user_defined_req_num_code
                  x_rfq_required_flag
                  x_manual_req_num_type
                  x_enforce_full_lot_qty
                  x_disposition_warning_flag
                  x_reserve_at_completion_flag
                  x_user_defined_rcpt_num_code
                  x_manual_rcpt_num_type
		  x_use_positions_flag
		  x_default_quote_warning_delay
		  x_inspection_required_flag
		  x_user_defined_quote_num_code
		  x_manual_quote_num_type
		  x_user_defined_rfq_num_code
		  x_manual_rfq_num_type
		  x_ship_via_lookup_code
		  x_qty_rcv_tolerance
		  x_acceptance_required_flag


  ALGORITHM     : Retreive po parameters from
                  financials_system_parameters,gl_sets_of_books,
                  po_system_parameters and rcv_parameters tables.

  NOTES         :

=========================================================================== */
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
			       x_use_positions_flag	       OUT NOCOPY VARCHAR2,
			       x_default_quote_warning_delay   OUT NOCOPY NUMBER,
		  	       x_inspection_required_flag      OUT NOCOPY VARCHAR2,
		  	       x_user_defined_quote_num_code   OUT NOCOPY VARCHAR2,
		  	       x_manual_quote_num_type	       OUT NOCOPY VARCHAR2,
		  	       x_user_defined_rfq_num_code     OUT NOCOPY VARCHAR2,
		  	       x_manual_rfq_num_type	       OUT NOCOPY VARCHAR2,
		  	       x_ship_via_lookup_code	       OUT NOCOPY VARCHAR2,
		  	       x_qty_rcv_tolerance	       OUT NOCOPY NUMBER,
			       x_acceptance_required_flag      OUT NOCOPY VARCHAR2
                              ) is

  x_progress     VARCHAR2(3) := NULL;
  -- PDOI Enhancement bug#17063664
  x_group_shipments_flag   VARCHAR2(1) := NULL;
begin
  x_progress := 10;


          get_po_parameters (  x_currency_code               => x_currency_code
                               ,x_coa_id                     => x_coa_id
                               ,x_po_encumberance_flag       => x_po_encumberance_flag
                               ,x_req_encumberance_flag      => x_req_encumberance_flag
                               ,x_sob_id                     => x_sob_id
                               ,x_ship_to_location_id        => x_ship_to_location_id
                               ,x_bill_to_location_id        => x_bill_to_location_id
                               ,x_fob_lookup_code            => x_fob_lookup_code
                               ,x_freight_terms_lookup_code  => x_freight_terms_lookup_code
                               ,x_terms_id                   => x_terms_id
                               ,x_default_rate_type          => x_default_rate_type
                               ,x_taxable_flag               => x_taxable_flag
                               ,x_receiving_flag             => x_receiving_flag
                               ,x_enforce_buyer_name_flag    => x_enforce_buyer_name_flag
                               ,x_enforce_buyer_auth_flag    => x_enforce_buyer_auth_flag
                               ,x_line_type_id               => x_line_type_id
                               ,x_manual_po_num_type         => x_manual_po_num_type
                               ,x_po_num_code                => x_po_num_code
                               ,x_price_lookup_code          => x_price_lookup_code
                               ,x_invoice_close_tolerance    => x_invoice_close_tolerance
                               ,x_receive_close_tolerance    => x_receive_close_tolerance
                               ,x_security_structure_id      => x_security_structure_id
                               ,x_expense_accrual_code       => x_expense_accrual_code
                               ,x_inv_org_id                 => x_inv_org_id
                               ,x_rev_sort_ordering          => x_rev_sort_ordering
                               ,x_min_rel_amount             => x_min_rel_amount
                               ,x_notify_blanket_flag        => x_notify_blanket_flag
                               ,x_budgetary_control_flag     => x_budgetary_control_flag
                               ,x_user_defined_req_num_code  => x_user_defined_req_num_code
                               ,x_rfq_required_flag          => x_rfq_required_flag
                               ,x_manual_req_num_type        => x_manual_req_num_type
                               ,x_enforce_full_lot_qty       => x_enforce_full_lot_qty
                               ,x_disposition_warning_flag   => x_disposition_warning_flag
                               ,x_reserve_at_completion_flag => x_reserve_at_completion_flag
                               ,x_user_defined_rcpt_num_code => x_user_defined_rcpt_num_code
                               ,x_manual_rcpt_num_type       => x_manual_rcpt_num_type
			       ,x_use_positions_flag	     => x_use_positions_flag
			       ,x_default_quote_warning_delay => x_default_quote_warning_delay
		  	       ,x_inspection_required_flag   => x_inspection_required_flag
		  	       ,x_user_defined_quote_num_code => x_user_defined_quote_num_code
		  	       ,x_manual_quote_num_type	     => x_manual_quote_num_type
		  	       ,x_user_defined_rfq_num_code  => x_user_defined_rfq_num_code
		  	       ,x_manual_rfq_num_type	     => x_manual_rfq_num_type
		  	       ,x_ship_via_lookup_code	     => x_ship_via_lookup_code
		  	       ,x_qty_rcv_tolerance	     => x_qty_rcv_tolerance
			       ,x_acceptance_required_flag   => x_acceptance_required_flag
			       ,x_group_shipments_flag       => x_group_shipments_flag
                              );

  EXCEPTION
  WHEN OTHERS THEN
    po_message_s.sql_error('get_po_parameters', x_progress, sqlcode);
    RAISE;

end get_po_parameters;


/*PDOI Enhancement bug#17063664 Added new parameter group shipments flag */

/* ===========================================================================
  PROCEDURE NAME: get_po_parameters

  DESCRIPTION   :

  CLIENT/SERVER : SERVER

  LIBRARY NAME  :

  OWNER         : SUBHAJIT PURKAYASTHA

  PARAMETERS    : x_currency_code
                  x_coa_id
                  x_po_encumberance_flag
                  x_req_encumberance_flag
                  x_sob_id
                  x_ship_to_location_id
                  x_bill_to_location_id
                  x_fob_lookup_code
                  x_freight_terms_lookup_code
                  x_terms_id
                  x_default_rate_type
                  x_taxable_flag
                  x_receiving_flag
                  x_enforce_buyer_name_flag
                  x_enforce_buyer_auth_flag
                  x_line_type_id
                  x_manual_po_num_type
                  x_po_num_code
                  x_price_lookup_code
                  x_invoice_close_tolerance
                  x_receive_close_tolerance
                  x_security_structure_id
                  x_expense_accrual_code
                  x_inv_org_id
                  x_rev_sort_ordering
                  x_min_rel_amount
                  x_notify_blanket_flag
                  x_budgetary_control_flag
                  x_user_defined_req_num_code
                  x_rfq_required_flag
                  x_manual_req_num_type
                  x_enforce_full_lot_qty
                  x_disposition_warning_flag
                  x_reserve_at_completion_flag
                  x_user_defined_rcpt_num_code
                  x_manual_rcpt_num_type
		  x_use_positions_flag
		  x_default_quote_warning_delay
		  x_inspection_required_flag
		  x_user_defined_quote_num_code
		  x_manual_quote_num_type
		  x_user_defined_rfq_num_code
		  x_manual_rfq_num_type
		  x_ship_via_lookup_code
		  x_qty_rcv_tolerance
		  x_acceptance_required_flag
		  x_group_shipments_flag


  ALGORITHM     : Retreive po parameters from
                  financials_system_parameters,gl_sets_of_books,
                  po_system_parameters and rcv_parameters tables.


  NOTES         :

=========================================================================== */
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
			       x_use_positions_flag	       OUT NOCOPY VARCHAR2,
			       x_default_quote_warning_delay   OUT NOCOPY NUMBER,
		  	       x_inspection_required_flag      OUT NOCOPY VARCHAR2,
		  	       x_user_defined_quote_num_code   OUT NOCOPY VARCHAR2,
		  	       x_manual_quote_num_type	       OUT NOCOPY VARCHAR2,
		  	       x_user_defined_rfq_num_code     OUT NOCOPY VARCHAR2,
		  	       x_manual_rfq_num_type	       OUT NOCOPY VARCHAR2,
		  	       x_ship_via_lookup_code	       OUT NOCOPY VARCHAR2,
		  	       x_qty_rcv_tolerance	       OUT NOCOPY NUMBER,
			       x_acceptance_required_flag      OUT NOCOPY VARCHAR2,
			       x_group_shipments_flag          OUT NOCOPY VARCHAR2
                              ) is

  x_progress     VARCHAR2(3) := NULL;
begin
  x_progress := 10;

  SELECT  sob.currency_code,
          sob.chart_of_accounts_id,
          nvl(fsp.purch_encumbrance_flag,'N'),
          nvl(fsp.req_encumbrance_flag,'N'),
          sob.set_of_books_id,
          fsp.ship_to_location_id,
          fsp.bill_to_location_id,
          fsp.fob_lookup_code,
          fsp.freight_terms_lookup_code,
          aps.terms_id,     -- bug5701539
          psp.default_rate_type,
	  --togeorge 07/03/2001
	  --Bug# 1839659
	  --We are no more using this flag from psp.
          --psp.taxable_flag,
	  null,
	  --
          psp.receiving_flag,
          nvl(psp.enforce_buyer_name_flag, 'N'),
          nvl(psp.enforce_buyer_authority_flag,'N'),
          psp.line_type_id,
          psp.manual_po_num_type,
          psp.user_defined_po_num_code,
          psp.price_type_lookup_code,
          psp.invoice_close_tolerance,
          psp.receive_close_tolerance,
          psp.security_position_structure_id,
          psp.expense_accrual_code,
          fsp.inventory_organization_id,
          fsp.revision_sort_ordering,
          psp.min_release_amount,
          nvl(psp.notify_if_blanket_flag,'N'),
          nvl(sob.enable_budgetary_control_flag,'N'),
          psp.user_defined_req_num_code,
          nvl(psp.rfq_required_flag,'N'),
          psp.manual_req_num_type,
          psp.enforce_full_lot_quantities,
          psp.disposition_warning_flag,
          nvl(fsp.reserve_at_completion_flag,'N'),
          psp.user_defined_receipt_num_code,
          psp.manual_receipt_num_type,
	  fsp.use_positions_flag,
	  psp.default_quote_warning_delay,
	  psp.inspection_required_flag,
	  psp.user_defined_quote_num_code,
	  psp.manual_quote_num_type,
	  psp.user_defined_rfq_num_code,
	  psp.manual_rfq_num_type,
	  fsp.ship_via_lookup_code,
	  rcv.qty_rcv_tolerance,
	  psp.acceptance_required_flag,
	  psp.group_shipments_flag
  INTO    x_currency_code       ,
          x_coa_id               ,
          x_po_encumberance_flag  ,
          x_req_encumberance_flag  ,
          x_sob_id                  ,
          x_ship_to_location_id      ,
          x_bill_to_location_id       ,
          x_fob_lookup_code         ,
          x_freight_terms_lookup_code,
          x_terms_id           ,
          x_default_rate_type   ,
          x_taxable_flag         ,
          x_receiving_flag        ,
          x_enforce_buyer_name_flag,
          x_enforce_buyer_auth_flag,
          x_line_type_id       ,
          x_manual_po_num_type  ,
          x_po_num_code          ,
          x_price_lookup_code     ,
          x_invoice_close_tolerance,
          x_receive_close_tolerance,
          x_security_structure_id,
          x_expense_accrual_code,
          x_inv_org_id      ,
          x_rev_sort_ordering,
          x_min_rel_amount    ,
          x_notify_blanket_flag,
          x_budgetary_control_flag,
          x_user_defined_req_num_code,
          x_rfq_required_flag,
          x_manual_req_num_type,
          x_enforce_full_lot_qty,
          x_disposition_warning_flag,
          x_reserve_at_completion_flag,
          x_user_defined_rcpt_num_code,
          x_manual_rcpt_num_type,
	  x_use_positions_flag,
	  x_default_quote_warning_delay,
	  x_inspection_required_flag,
	  x_user_defined_quote_num_code,
	  x_manual_quote_num_type,
	  x_user_defined_rfq_num_code,
	  x_manual_rfq_num_type,
	  x_ship_via_lookup_code,
	  x_qty_rcv_tolerance,
	  x_acceptance_required_flag,
	  x_group_shipments_flag
  FROM    financials_system_parameters fsp,
          gl_sets_of_books sob,
          po_system_parameters psp,
	  rcv_parameters  rcv,
          ap_product_setup aps
  WHERE   fsp.set_of_books_id = sob.set_of_books_id
  AND     rcv.organization_id (+) = fsp.inventory_organization_id;


  EXCEPTION
  WHEN OTHERS THEN
    po_message_s.sql_error('get_po_parameters', x_progress, sqlcode);
    RAISE;

end get_po_parameters;

/* ===========================================================================
  PROCEDURE NAME: get_item_category_structure(x_category_set_id OUT NOCOPY NUMBER,
                                              x_structure_id    OUT NOCOPY NUMBER)

  DESCRIPTION   :

  CLIENT/SERVER : SERVER

  LIBRARY NAME  :

  OWNER         : SUBHAJIT PURKAYASTHA

  PARAMETERS    : Category_set_id NUMBER
                  structure_id    NUMBER

  ALGORITHM     : Retreive category_set_id and structure_id from
                  mtl_default_sets_view for functional_area_id = 2

  NOTES         :

=========================================================================== */
PROCEDURE get_item_category_structure (  x_category_set_id OUT NOCOPY NUMBER,
                                         x_structure_id    OUT NOCOPY NUMBER ) is
    x_progress  VARCHAR2(3) := NULL;
begin
  x_progress := 10;
  SELECT mdsv.category_set_id,
         mdsv.structure_id
  INTO   x_category_set_id,
         x_structure_id
  FROM   mtl_default_sets_view mdsv
  WHERE  mdsv.functional_area_id = 2;

  EXCEPTION
  WHEN OTHERS THEN
    po_message_s.sql_error('get_item_category_structure', x_progress, sqlcode);
    RAISE;

end get_item_category_structure;

/* ===========================================================================
  FUNCTION NAME : get_product_install_status (x_product_name IN VARCHAR2)
                                                RETURN VARCHAR2

  DESCRIPTION   : Returns the product's installation status

  CLIENT/SERVER : SERVER

  LIBRARY NAME  :

  OWNER         : SUBHAJIT PURKAYASTHA

  PARAMETERS    : x_product_name - Name of the product
                  For eg - 'INV','PO','ENG'

  ALGORITHM     : Use fnd_installation.get function to retreive
                  the status of product installation.
                  Function expects product id to be passed
                  Product Id will be derived from FND_APPLICATION table
                  Product       Product Id
                  --------      -----------
                  INV           401
                  PO            201

  NOTES         : valid installation status:
                  I - Product is installed
                  S - Product is partially installed
                  N - Product is not installed
                  L - Product is a local (custom) application


=========================================================================== */

FUNCTION get_product_install_status ( x_product_name IN VARCHAR2) RETURN VARCHAR2 IS
  x_progress     VARCHAR2(3) := NULL;
  x_app_id       NUMBER;
  x_install      BOOLEAN;
  x_status       VARCHAR2(1);
  x_org          VARCHAR2(1);
  x_temp_product_name varchar2(10);
begin
  --Retreive product id from fnd_application based on product name
  x_progress := 10;

  select application_id
  into   x_app_id
  from   fnd_application
  where application_short_name = x_product_name ;

  --get product installation status
  x_progress := 20;
  x_install := fnd_installation.get(x_app_id,x_app_id,x_status,x_org);

  if x_product_name in ('OE', 'ONT') then

	if Oe_install.get_active_product() in ('OE', 'ONT') then
		x_status := 'I';
	else
		x_status := 'N';
	end if;
  end if;

  RETURN(x_status);

  EXCEPTION
    WHEN NO_DATA_FOUND then
      null;
      RETURN(null);
    WHEN OTHERS THEN
    po_message_s.sql_error('get_product_install_status', x_progress, sqlcode);
      RAISE;

end get_product_install_status;

/* ===========================================================================
  PROCEDURE NAME: get_global_values(x_userid        OUT NOCOPY number,
                                    x_logonid       OUT NOCOPY number,
                                    x_last_upd_date OUT NOCOPY date,
                                    x_current_date  OUT NOCOPY date )

  DESCRIPTION   :

  CLIENT/SERVER : SERVER

  LIBRARY NAME  :

  OWNER         : SUBHAJIT PURKAYASTHA

  PARAMETERS    : x_userid        - Returns fnd user_id
                  x_logonid       - Return fnd logon id
                  x_last_upd_date - Returns sysdate
                  x_current_date  - Returns sysdate

  ALGORITHM     :

  NOTES         :

=========================================================================== */

PROCEDURE get_global_values(x_userid        OUT NOCOPY number,
                            x_logonid       OUT NOCOPY number,
                            x_last_upd_date OUT NOCOPY date,
                            x_current_date  OUT NOCOPY date ) is
  x_progress VARCHAR2(3) := NULL;
begin
  x_progress := 10;
  x_userid        := fnd_global.user_id;

  x_progress := 20;
  x_logonid       := fnd_global.login_id;

  x_progress := 30;
  x_last_upd_date := sysdate;

  x_progress := 40;
  x_current_date  := sysdate;

  EXCEPTION
  WHEN OTHERS THEN
    po_message_s.sql_error('get_global_values', x_progress, sqlcode);
    RAISE;

end get_global_values;

/*===========================================================================

  PROCEDURE NAME : GET_PERIOD_NAME

  DESCRIPTION   : Based on system date, function returns appropriate period
                  and gl_date

  CLIENT/SERVER : SERVER

  LIBRARY NAME  :

  OWNER         : SUBHAJIT PURKAYASTHA

  PARAMETERS    : sob_id      - Set_of_books_id
                  period_name - Period Name
                  gl_date     - GL Date
  ALGORITHM     :

  NOTES         :

===========================================================================*/
-------------------------------------------------------------------------------
--Start of Comments
--Name: get_period_name
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Retrieves the GL period name and date for SYSDATE,
--  if the date is in a usable period (valid for GL and PO).
--Parameters:
--IN:
--x_sob_id
--  Set of books.
--OUT:
--x_gl_period
--  The period name corresponding to SYSDATE.
--x_gl_date
--  SYSDATE.
--Notes:
--  This procedure was refactored in FPJ to call the more generalized
--  procedure get_period_info.  However, the parameter names were
--  not changed to meet standards, as that may have impacted calling code.
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE get_period_name (
   x_sob_id                         IN             NUMBER
,  x_period                         OUT NOCOPY     VARCHAR2
,  x_gl_date                        OUT NOCOPY     DATE
)
IS


l_log_head     CONSTANT VARCHAR2(100) := g_log_head||'GET_PERIOD_NAME';
l_progress     VARCHAR2(3) := '000';

l_period_name_tbl       po_tbl_varchar30;
l_period_year_tbl       po_tbl_number;
l_period_num_tbl        po_tbl_number;
l_quarter_num_tbl       po_tbl_number;
l_invalid_period_flag   VARCHAR2(1);

BEGIN

IF g_debug_stmt THEN
   PO_DEBUG.debug_begin(l_log_head);
   PO_DEBUG.debug_var(l_log_head,l_progress,'x_sob_id',x_sob_id);
END IF;

l_progress := '010';

PO_PERIODS_SV.get_period_info(
   p_roll_logic => NULL
,  p_set_of_books_id => x_sob_id
,  p_date_tbl => po_tbl_date( SYSDATE )
,  x_period_name_tbl => l_period_name_tbl
,  x_period_year_tbl => l_period_year_tbl
,  x_period_num_tbl => l_period_num_tbl
,  x_quarter_num_tbl => l_quarter_num_tbl
,  x_invalid_period_flag => l_invalid_period_flag
);

l_progress := '020';

x_period := l_period_name_tbl(1);

IF (l_invalid_period_flag = FND_API.G_FALSE) THEN

   l_progress := '030';
   IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(l_log_head,l_progress,'valid period');
   END IF;

   x_gl_date := TRUNC(SYSDATE);

END IF;

l_progress := '900';

IF g_debug_stmt THEN
   PO_DEBUG.debug_var(l_log_head,l_progress,'x_period',x_period);
   PO_DEBUG.debug_var(l_log_head,l_progress,'x_gl_date',x_gl_date);
   PO_DEBUG.debug_end(l_log_head);
END IF;

EXCEPTION
WHEN OTHERS THEN
   IF g_debug_unexp THEN
      PO_DEBUG.debug_exc(l_log_head,l_progress);
   END IF;
   RAISE;

END get_period_name;




/* ===========================================================================
  PROCEDURE NAME: get_displayed_value(x_lookup_type       IN  VARCHAR2,
                                      x_lookup_code       IN  VARCHAR2,
				      x_disp_value	  OUT NOCOPY VARCHAR2,
				      x_description       OUT NOCOPY VARCHAR2,
				      x_validate  	  IN  BOOLEAN)

  DESCRIPTION   : Obtain the  displayed field and description. This procedure
		  also performs active date validation.

  CLIENT/SERVER : SERVER

  LIBRARY NAME  :

  OWNER         : Ramana Mulpury

  PARAMETERS    : lookup_type		VARCHAR2
                  lookup_type		VARCHAR2
 		  displayed_field 	VARCHAR2
		  descriptioni    	VARCHAR2
		  validate		BOOLEAN

  ALGORITHM     : Get the displayed field and description from the
		  table po_lookup_codes. These values are validated
		  against the inactive date if x_validate is set to TRUE
		  No validation is performed if x_validate is set to
		  FALSE.
  NOTES         :

=========================================================================== */
PROCEDURE get_displayed_value (x_lookup_type       IN  VARCHAR2,
                               x_lookup_code       IN  VARCHAR2,
			       x_disp_value	   OUT NOCOPY VARCHAR2,
			       x_description       OUT NOCOPY VARCHAR2,
			       x_validate	   IN  BOOLEAN) IS
    x_progress  VARCHAR2(3) := NULL;
begin

  x_progress := 10;

  IF  (x_validate = TRUE) THEN

  SELECT plc.displayed_field,
         plc.description
  INTO   x_disp_value,
         x_description
  FROM   po_lookup_codes plc
  WHERE  plc.lookup_code = x_lookup_code
  AND    plc.lookup_type = x_lookup_type
  AND    sysdate < nvl(plc.inactive_date,sysdate + 1);

  ELSE
   get_displayed_value(x_lookup_type, x_lookup_code, x_disp_value, x_description);

  END IF;

  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    x_disp_value   := NULL;
    x_description  := NULL;

  WHEN OTHERS THEN
    po_message_s.sql_error('get_displayed_value', x_progress, sqlcode);
    RAISE;

end get_displayed_value;



/* ===========================================================================
  PROCEDURE NAME: get_displayed_value(x_lookup_type       IN  VARCHAR2,
                                      x_lookup_code       IN  VARCHAR2,
				      x_disp_value	  OUT NOCOPY VARCHAR2,
				      x_description       OUT NOCOPY VARCHAR2)

  DESCRIPTION   : Obtain the  displayed field and description

  CLIENT/SERVER : SERVER

  LIBRARY NAME  :

  OWNER         : Ramana Mulpury

  PARAMETERS    : lookup_type		VARCHAR2
                  lookup_type		VARCHAR2
 		  displayed_field 	VARCHAR2
		  descriptioni    	VARCHAR2

  ALGORITHM     : Get the displayed field and description from the
		  table po_lookup_codes.

  NOTES         :

=========================================================================== */
PROCEDURE get_displayed_value (x_lookup_type       IN  VARCHAR2,
                               x_lookup_code       IN  VARCHAR2,
			       x_disp_value	   OUT NOCOPY VARCHAR2,
			       x_description       OUT NOCOPY VARCHAR2) IS
    x_progress  VARCHAR2(3) := NULL;
begin

  x_progress := 10;

  SELECT plc.displayed_field,
         plc.description
  INTO   x_disp_value,
         x_description
  FROM   po_lookup_codes plc
  WHERE  plc.lookup_code = x_lookup_code
  AND    plc.lookup_type = x_lookup_type;

  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    x_disp_value   := NULL;
    x_description  := NULL;

  WHEN OTHERS THEN
    po_message_s.sql_error('get_displayed_value', x_progress, sqlcode);
    RAISE;

end get_displayed_value;


/* ===========================================================================
  PROCEDURE NAME: get_displayed_value(x_lookup_type       IN  VARCHAR2,
                                      x_lookup_code       IN  VARCHAR2,
				      x_disp_value	  OUT NOCOPY VARCHAR2)

  DESCRIPTION   : Obtain the  displayed field . This is an overloaded
		  procedure

  CLIENT/SERVER : SERVER

  LIBRARY NAME  :

  OWNER         : Ramana Mulpury

  PARAMETERS    : lookup_type   VARCHAR2
                  lookup_code   VARCHAR2
 		  displayed_field VARCHAR2


  ALGORITHM     : Get the displayed field from the table po_lookup_codes.

  NOTES         :

=========================================================================== */
PROCEDURE get_displayed_value (x_lookup_type       IN  VARCHAR2,
                               x_lookup_code       IN  VARCHAR2,
			       x_disp_value	   OUT NOCOPY VARCHAR2) IS

x_progress  VARCHAR2(3) := NULL;

begin

  x_progress := 10;

  SELECT plc.displayed_field
  INTO   x_disp_value
  FROM   po_lookup_codes plc
  WHERE  plc.lookup_code = x_lookup_code
  AND    plc.lookup_type = x_lookup_type;

  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    x_disp_value   := NULL;

  WHEN OTHERS THEN
    po_message_s.sql_error('get_displayed_value', x_progress, sqlcode);
    RAISE;

end get_displayed_value;

/*===========================================================================
  FUNCTION NAME:	get_total

===========================================================================*/
FUNCTION  get_total (x_object_type     IN VARCHAR2,
                     x_object_id       IN NUMBER) RETURN NUMBER IS
	x_total		NUMBER;
BEGIN
    x_total := get_total(x_object_type,
		  	 x_object_id,
		  	 NULL);
    return(x_total);
END;


-- Bug 5124868: as part of refactoring for this bug, the get_entity_org_id
-- method was removed from this package and moved to PO_MOAC_UTILS_PVT.
-- get_entity_org_id was originally created for bug 5092574


/*===========================================================================
  FUNCTION NAME:	get_total

===========================================================================*/
--<CONTERMS FPJ START>
-- When making any change to this function please check if get_archive_total/get_archive_total_for_any_rev
-- also needs to be change correspondigly
--<CONTERMS FPJ END>
FUNCTION  get_total (x_object_type     IN VARCHAR2,
                     x_object_id       IN NUMBER,
                     x_base_cur_result IN BOOLEAN) RETURN NUMBER IS
  x_progress       VARCHAR2(3) := NULL;
  x_base_currency  VARCHAR2(16);
  x_po_currency    VARCHAR2(16);
  x_min_unit       NUMBER;
  x_base_min_unit  NUMBER;
  x_precision      INTEGER;
  x_base_precision INTEGER;
  x_result_fld     NUMBER;
  l_org_id         HR_ALL_ORGANIZATION_UNITS.organization_id%type;

  --bug 12723347
  l_rel_amt_same_curr NUMBER;
  l_rel_amt_diff_curr NUMBER;

BEGIN
  if (x_object_type in ('H','B') ) then

    if x_base_cur_result then
      /* Result should be returned in base currency. Get the currency code
         of the PO and the base currency code
      */
      x_progress := 10;
      po_core_s2.get_po_currency (x_object_id,
                       x_base_currency,
                       x_po_currency );

      /* Chk if base_currency = po_currency */
      if x_base_currency <> x_po_currency then
        /* Get precision and minimum accountable unit of the PO CURRENCY */
        x_progress := 20;
        po_core_s2.get_currency_info (x_po_currency,
                           x_precision,
                           x_min_unit );

        /* Get precision and minimum accountable unit of the base CURRENCY */
        x_progress := 30;
        po_core_s2.get_currency_info (x_base_currency,
                           x_base_precision,
                           x_base_min_unit );



        if X_base_min_unit is null  then

          if X_min_unit is null then

            x_progress := 40;

/* 958792 kbenjami 8/25/99.  Proprogated fix from R11.
   849493 - SVAIDYAN: Do a sum(round()) instead of round(sum()) since what
                      we pass to GL is the round of individual dist. amounts
                      and the sum of these rounded values is what should be
                      displayed as the header total.
*/
            -- <SERVICES FPJ>
            -- For the new Services lines, quantity will be null.
            -- Hence, added a decode statement to use amount directly
            -- in the total amount calculation when quantity is null.
            --< Bug 3549096 > Use _ALL tables instead of org-striped views.
	    --<BUG 10060275 Modified below sql to reduce performance issues>
            SELECT nvl(sum(round(
                   round(
                       (decode(PLL.quantity,
                               null,
                               (nvl(PLL.amount, 0) -
                               nvl(PLL.amount_cancelled, 0)),
                               ((nvl(PLL.quantity, 0) -
                               nvl(PLL.quantity_cancelled, 0)) *
                               nvl(PLL.price_override, 0))
                              )
                       * POD.rate
                       )
                   , X_precision) ,
                   X_base_precision)),0)
            INTO   X_result_fld
            FROM   PO_DISTRIBUTIONS_ALL POD, PO_LINE_LOCATIONS_ALL PLL
            WHERE  PLL.po_header_id = X_object_id
            AND    PLL.shipment_type in ('STANDARD','PLANNED','BLANKET')
            AND    PLL.line_location_id = POD.line_location_id;

          else
            x_progress := 42;

            -- <SERVICES FPJ>
            -- For the new Services lines, quantity will be null.
            -- Hence, added a decode statement to use amount directly
            -- in the total amount calculation when quantity is null.
            --< Bug 3549096 > Use _ALL tables instead of org-striped views.
	    --<BUG 10060275 Modified below sql to reduce performance issues>
            SELECT nvl(sum(round(
                   round(
                       decode(PLL.quantity,
                              null,
                              (nvl(PLL.amount, 0) -
                              nvl(PLL.amount_cancelled, 0)),
                              ((nvl(PLL.quantity, 0) -
                              nvl(PLL.quantity_cancelled, 0)) *
                              nvl(PLL.price_override, 0))
                             )
                       * POD.rate / X_min_unit
                        )
                   * X_min_unit , X_base_precision)),0)
            INTO   X_result_fld
            FROM   PO_DISTRIBUTIONS_ALL POD, PO_LINE_LOCATIONS_ALL PLL
            WHERE  PLL.po_header_id = X_object_id
            AND    PLL.shipment_type in ('STANDARD','PLANNED','BLANKET')
            AND    PLL.line_location_id = POD.line_location_id;

          end if;

        else /* base_min_unit is NOT null */

          if X_min_unit is null then
            x_progress := 44;

            -- <SERVICES FPJ>
            -- For the new Services lines, quantity will be null.
            -- Hence, added a decode statement to use amount directly
            -- in the total amount calculation when quantity is null.
            --< Bug 3549096 > Use _ALL tables instead of org-striped views.
	    --<BUG 10060275 Modified below sql to reduce performance issues>
            SELECT nvl(sum(round( round(
                   decode(PLL.quantity,
                          null,
                          (nvl(PLL.amount, 0) -
                          nvl(PLL.amount_cancelled, 0)),
                          (nvl(PLL.quantity, 0) -
                          nvl(PLL.quantity_cancelled, 0))
                          * nvl(PLL.price_override, 0)
                         )
                   * POD.rate , X_precision)
                   / X_base_min_unit ) * X_base_min_unit) ,0)
            INTO   X_result_fld
            FROM   PO_DISTRIBUTIONS_ALL POD, PO_LINE_LOCATIONS_ALL PLL
            WHERE  PLL.po_header_id = X_object_id
            AND    PLL.shipment_type in ('STANDARD','PLANNED','BLANKET')
            AND    PLL.line_location_id = POD.line_location_id;

          else
            x_progress := 46;

            -- <SERVICES FPJ>
            -- For the new Services lines, quantity will be null.
            -- Hence, added a decode statement to use amount directly
            -- in the total amount calculation when quantity is null.
            --< Bug 3549096 > Use _ALL tables instead of org-striped views.
	    --<BUG 10060275 Modified below sql to reduce performance issues>
            SELECT nvl(sum(round( round(
                   decode(PLL.quantity,
                          null,
                          (nvl(PLL.amount, 0) -
                          nvl(PLL.amount_cancelled, 0)),
                          (nvl(PLL.quantity, 0) -
                          nvl(PLL.quantity_cancelled, 0))
                          * nvl(PLL.price_override, 0)
                         )
                   * POD.rate /
                   X_min_unit) * X_min_unit  / X_base_min_unit)
                   * X_base_min_unit) , 0)
            INTO   X_result_fld
            FROM   PO_DISTRIBUTIONS_ALL POD, PO_LINE_LOCATIONS_ALL PLL
            WHERE  PLL.po_header_id = X_object_id
            AND    PLL.shipment_type in ('STANDARD','PLANNED','BLANKET')
            AND    PLL.line_location_id = POD.line_location_id;

          end if;

        end if;

      end if;  /* x_base_currency <> x_po_currency */

    else

      /* if we donot want result converted to base currency or if
         the currencies are the same then do the check without
         rate conversion */

/* 958792 kbenjami 8/25/99.  Proprogated fix from R11.
   849493 - SVAIDYAN: Do a sum(round()) instead of round(sum()) since what
                      we pass to GL is the round of individual dist. amounts
                      and the sum of these rounded values is what should be
                      displayed as the header total.
*/

      x_progress := 50;

      --< Bug 3549096 > Use _ALL tables instead of org-striped views.
      SELECT c.minimum_accountable_unit,
             c.precision
      INTO   x_min_unit,
             x_precision
      FROM   FND_CURRENCIES C,
             PO_HEADERS_ALL     PH
      WHERE  PH.po_header_id  = x_object_id
      AND    C.currency_code  = PH.CURRENCY_CODE;

      if x_min_unit is null then
	x_progress := 53;

	-- <SERVICES FPJ>
        -- For the new Services lines, quantity will be null.
        -- Hence, added a decode statement to use amount directly
        -- in the total amount calculation when quantity is null.
        --< Bug 3549096 > Use _ALL tables instead of org-striped views.
        select sum(round(
               decode(pll.quantity,
                      null,
                      (pll.amount - nvl(pll.amount_cancelled,0)),
                      (pll.quantity - nvl(pll.quantity_cancelled,0))
                      * nvl(pll.price_override,0)
                     )
               ,x_precision))
        INTO   x_result_fld
        FROM   PO_LINE_LOCATIONS_ALL PLL
        WHERE  PLL.po_header_id   = x_object_id
        --Bug 17526240 fix
	      AND (PLL.shipment_type in ('STANDARD','PLANNED')
              OR (PLL.shipment_type = 'BLANKET' AND NVL(PLL.consigned_flag, 'N') <> 'Y' ));

      else
		/* Bug 1111926: GMudgal 2/18/2000
		** Incorrect placement of brackets caused incorrect rounding
		** and consequently incorrect PO header totals
		*/
        x_progress := 56;

        -- <SERVICES FPJ>
        -- For the new Services lines, quantity will be null.
        -- Hence, added a decode statement to use amount directly
        -- in the total amount calculation when quantity is null.
        --< Bug 3549096 > Use _ALL tables instead of org-striped views.
        select sum(round(
               decode(pll.quantity,
                      null,
                      (pll.amount - nvl(pll.amount_cancelled, 0)),
                      (pll.quantity - nvl(pll.quantity_cancelled, 0))
                      * nvl(pll.price_override,0)
                     )
               / x_min_unit)
               * x_min_unit)
        INTO   x_result_fld
        FROM   PO_LINE_LOCATIONS_ALL PLL
        WHERE  PLL.po_header_id   = x_object_id
        --Bug 17526240 fix
        AND (PLL.shipment_type in ('STANDARD','PLANNED')
              OR (PLL.shipment_type = 'BLANKET' AND NVL(PLL.consigned_flag, 'N') <> 'Y' ));

      end if;

    end if;

    -- <GA FPI START>
    --

    -- <GC FPJ>
    -- Change x_object_type for GA from 'G' to 'GA'

    ELSIF ( x_object_type = 'GA' ) THEN                       -- Global Agreement

        x_result_fld := get_ga_amount_released( x_object_id, x_base_cur_result );
    --
    -- <GA FPI END>

   -- <GC FPJ START>
   ELSIF (x_object_type = 'GC') THEN                       -- Global Contract
       x_result_fld := get_gc_amount_released
                       (
                           p_po_header_id    => x_object_id,
                           p_convert_to_base => x_base_cur_result
                       );

   -- <GC FPJ END>

   elsif (x_object_type = 'P') then /* For PO Planned */

     if x_base_cur_result then

      /* Result should be returned in base currency. Get the currency code
         of the PO and the base currency code */

      x_progress := 60;
      po_core_s2.get_po_currency (x_object_id,
                       x_base_currency,
                       x_po_currency );

      /* Chk if base_currency = po_currency */
      if x_base_currency <> x_po_currency then
        /* Get precision and minimum accountable unit of the PO CURRENCY */
        x_progress := 70;
        po_core_s2.get_currency_info (x_po_currency,
                           x_precision,
                           x_min_unit );

        /* Get precision and minimum accountable unit of the base CURRENCY */
        x_progress := 80;
        po_core_s2.get_currency_info (x_base_currency,
                           x_base_precision,
                           x_base_min_unit );

/* iali - Bug 482497 - 05/09/97
   For Planned PO the PLL.shipment_type should be 'PLANNED' and not
   'SCHEDULED' as it was before. Adding both in the where clause by replacing
   eqality check with in clause.
*/
-- Bugs 482497 and 602664, lpo, 12/22/97
-- Actually, for planned PO, the shipment_type should remain to be 'SCHEDULED'.
-- This will calculate the total released amount. (a shipment type of 'PLANNED'
-- indicates the lines in the planned PO, therefore using IN ('PLANNED',
-- 'SCHEDULED') will calculate the total released amount plus the amount
-- agreed, which is not what we want.
-- Refer to POXBWN3B.pls for fix to bug 482497.

        if X_base_min_unit is null  then

          if X_min_unit is null then

            x_progress := 90;

/* 958792 kbenjami 8/25/99.  Proprogated fix from R11.
   849493 - SVAIDYAN: Do a sum(round()) instead of round(sum()) since what
                      we pass to GL is the round of individual dist. amounts
                      and the sum of these rounded values is what should be
                      displayed as the header total.
*/
            --< Bug 3549096 > Use _ALL tables instead of org-striped views.
            SELECT nvl(sum(round( round((nvl(POD.quantity_ordered, 0) -
                   nvl(POD.quantity_cancelled, 0)) *
                   nvl(PLL.price_override, 0) * POD.rate, X_precision) ,
                   X_base_precision)),0)
            INTO   X_result_fld
            FROM   PO_DISTRIBUTIONS_ALL POD, PO_LINE_LOCATIONS_ALL PLL
            WHERE  PLL.po_header_id     = X_object_id
-- Bugs 482497 and 602664, lpo, 12/22/97
            AND    PLL.shipment_type    = 'SCHEDULED'
-- End of fix. Bugs 482497 and 602664, lpo, 12/22/97
            AND    PLL.line_location_id = POD.line_location_id;

          else
            x_progress := 92;
            --< Bug 3549096 > Use _ALL tables instead of org-striped views.
            SELECT nvl(sum(round( round((nvl(POD.quantity_ordered, 0) -
                   nvl(POD.quantity_cancelled, 0)) *
                   nvl(PLL.price_override, 0) * POD.rate /
                   X_min_unit) * X_min_unit , X_base_precision)),0)
            INTO   X_result_fld
            FROM   PO_DISTRIBUTIONS_ALL POD, PO_LINE_LOCATIONS_ALL PLL
            WHERE  PLL.po_header_id     = X_object_id
-- Bugs 482497 and 602664, lpo, 12/22/97
            AND    PLL.shipment_type   	= 'SCHEDULED'
-- End of fix. Bugs 482497 and 602664, lpo, 12/22/97
            AND    PLL.line_location_id = POD.line_location_id;
          end if;

        else /* base_min_unit is NOT null */

          if X_min_unit is null then
            x_progress := 94;
            --< Bug 3549096 > Use _ALL tables instead of org-striped views.
            SELECT nvl(sum(round( round((nvl(POD.quantity_ordered, 0) -
                   nvl(POD.quantity_cancelled, 0)) *
                   nvl(PLL.price_override, 0) * POD.rate , X_precision)
                   / X_base_min_unit ) * X_base_min_unit) ,0)
            INTO   X_result_fld
            FROM   PO_DISTRIBUTIONS_ALL POD, PO_LINE_LOCATIONS_ALL PLL
            WHERE  PLL.po_header_id     = X_object_id
-- Bugs 482497 and 602664, lpo, 12/22/97
            AND    PLL.shipment_type    = 'SCHEDULED'
-- End of fix. Bugs 482497 and 602664, lpo, 12/22/97
            AND    PLL.line_location_id = POD.line_location_id;

          else
            x_progress := 96;
            --< Bug 3549096 > Use _ALL tables instead of org-striped views.
            SELECT nvl(sum(round( round((nvl(POD.quantity_ordered, 0) -
                                         nvl(POD.quantity_cancelled, 0)) *
                   nvl(PLL.price_override, 0) * POD.rate /
                   X_min_unit) * X_min_unit  / X_base_min_unit)
                   * X_base_min_unit) , 0)
            INTO   X_result_fld
            FROM   PO_DISTRIBUTIONS_ALL POD, PO_LINE_LOCATIONS_ALL PLL
            WHERE  PLL.po_header_id     = X_object_id
-- Bugs 482497 and 602664, lpo, 12/22/97
            AND    PLL.shipment_type    = 'SCHEDULED'
-- End of fix. Bugs 482497 and 602664, lpo, 12/22/97
            AND    PLL.line_location_id = POD.line_location_id;
          end if;

        end if;

      end if;  /* x_base_currency <> x_po_currency */

    else

      /* if we donot want result converted to base currency or if
         the currencies are the same then do the check without
         rate conversion */
      x_progress := 100;
      --< Bug 3549096 > Use _ALL tables instead of org-striped views.
      SELECT c.minimum_accountable_unit,
             c.precision
      INTO   x_min_unit,
             x_precision
      FROM   FND_CURRENCIES C,
             PO_HEADERS_ALL     PH
      WHERE  PH.po_header_id  = x_object_id
      AND    C.currency_code  = PH.CURRENCY_CODE;

/* 958792 kbenjami 8/25/99.  Proprogated fix from R11.
   849493 - SVAIDYAN: Do a sum(round()) instead of round(sum()) since what
                      we pass to GL is the round of individual dist. amounts
                      and the sum of these rounded values is what should be
                      displayed as the header total.
*/
      if x_min_unit is null then
        x_progress := 103;
        --< Bug 3549096 > Use _ALL tables instead of org-striped views.
        select sum(round((pll.quantity - nvl(pll.quantity_cancelled,0))*
                         nvl(pll.price_override,0),x_precision))
        INTO   x_result_fld
        FROM   PO_LINE_LOCATIONS_ALL PLL
        WHERE  PLL.po_header_id   = x_object_id
-- Bugs 482497 and 602664, lpo, 12/22/97
        AND    PLL.shipment_type  = 'SCHEDULED';
-- Bugs 482497 and 602664, lpo, 12/22/97
      else
		/* Bug 1111926: GMudgal 2/18/2000
		** Incorrect placement of brackets caused incorrect rounding
		** and consequently incorrect PO header totals
		*/
        x_progress := 106;
        --< Bug 3549096 > Use _ALL tables instead of org-striped views.
        select sum(round((pll.quantity -
                          nvl(pll.quantity_cancelled,0)) *
                          nvl(pll.price_override,0)/x_min_unit)*
                          x_min_unit)
        INTO   x_result_fld
        FROM   PO_LINE_LOCATIONS_ALL PLL
        WHERE  PLL.po_header_id   = x_object_id
-- Bugs 482497 and 602664, lpo, 12/22/97
        AND    PLL.shipment_type  = 'SCHEDULED';
-- End of fix. Bugs 482497 and 602664, lpo, 12/22/97
      end if;

    end if;

  elsif (x_object_type = 'E' ) then /* Requisition Header */
    x_progress := 110;
    --bug#5092574 Retrieve the doc org id and pass this to retrieve
    --the document currency. Bug 5124868: refactored this call
    l_org_id := PO_MOAC_UTILS_PVT.get_entity_org_id(
                  PO_MOAC_UTILS_PVT.g_doc_type_REQUISITION
                , PO_MOAC_UTILS_PVT.g_doc_level_HEADER
                , x_object_id);--bug#5092574

    po_core_s2.get_req_currency (x_object_id,
                                 x_base_currency,
                                 l_org_id);--bug#5092574

    x_progress := 120;
    po_core_s2.get_currency_info (x_base_currency,
                       x_base_precision,
                       x_base_min_unit );

    if x_base_min_unit is null then
      x_progress := 130;

/*    Bug No. 1431811 Changing the round of sum to sum of rounded totals

      round(sum((nvl(quantity,0) * nvl(unit_price,0))), x_base_precision)
*/
      -- <SERVICES FPJ>
      -- For the new Services lines, quantity will be null.
      -- Hence, added a decode statement to use amount directly
      -- in the total amount calculation when quantity is null.
      --< Bug 3549096 > Use _ALL tables instead of org-striped views.
      -- <Bug 4036549, include cancelled lines with with delivered quantity>

      select sum(round(
                 decode(quantity,
                        null,
      	                nvl(amount, 0),
                        (
                          (nvl(quantity,0) - nvl(quantity_cancelled,0))* nvl(unit_price,0)
                        )
                       )
	     , x_base_precision))
      INTO   x_result_fld
      FROM   PO_REQUISITION_LINES_ALL
      WHERE  requisition_header_id            = x_object_id
      AND    nvl(modified_by_agent_flag, 'N') = 'N';

    else
      x_progress := 135;

/*    Bug No. 1431811 Changing the round of sum to sum of rounded totals
      select
      round(sum((nvl(quantity,0) * nvl(unit_price,0)/x_base_min_unit)*
                 x_base_min_unit))
*/
      -- <SERVICES FPJ>
      -- For the new Services lines, quantity will be null.
      -- Hence, added a decode statement to use amount directly
      -- in the total amount calculation when quantity is null.
      --< Bug 3549096 > Use _ALL tables instead of org-striped views.
      -- <Bug 4036549, include cancelled lines with with delivered quantity>
      select sum(round(
             decode(quantity,
                    null,
                    nvl(amount, 0),
                    (
                      (nvl(quantity,0) - nvl(quantity_cancelled,0))* nvl(unit_price,0)
                    )
                   )
             /x_base_min_unit)*
             x_base_min_unit)
      INTO   x_result_fld
      FROM   PO_REQUISITION_LINES_ALL
      WHERE  requisition_header_id            = x_object_id
      AND    nvl(modified_by_agent_flag, 'N') = 'N';

    end if;

  elsif (x_object_type = 'I' ) then /* Requisition Line */

    x_progress := 140;
    --bug#5092574 Retrieve the doc org id and pass this to retrieve
    --the document currency. Bug 5124868: refactored this call
    l_org_id := PO_MOAC_UTILS_PVT.get_entity_org_id(
                  PO_MOAC_UTILS_PVT.g_doc_type_REQUISITION
                , PO_MOAC_UTILS_PVT.g_doc_level_LINE
                , x_object_id);--bug#5092574

    po_core_s2.get_req_currency (x_object_id,
                                 x_base_currency,
                                 l_org_id);--bug#5092574

    x_progress := 150;
    po_core_s2.get_currency_info (x_base_currency,
                       x_base_precision,
                       x_base_min_unit );

    if x_base_min_unit is null then
      x_progress := 160;

/*    Bug No. 1431811 Changing the round of sum to sum of rounded totals

      select
      round(sum((nvl(quantity,0) * nvl(unit_price,0))), x_base_precision)
*/
      -- <SERVICES FPJ>
      -- For the new Services lines, quantity will be null.
      -- Hence, added a decode statement to use amount directly
      -- in the total amount calculation when quantity is null.
      --< Bug 3549096 > Use _ALL tables instead of org-striped views.
      -- <Bug 4036549, include cancelled lines with with delivered quantity>
      select sum(round(
	     decode(quantity,
                    null,
                    nvl(amount, 0),
                    (
                      (nvl(quantity,0) - nvl(quantity_cancelled,0))* nvl(unit_price,0)
                    )
              )
             , x_base_precision))
      INTO   x_result_fld
      FROM   PO_REQUISITION_LINES_ALL
      WHERE  requisition_line_id              = x_object_id
      AND    nvl(modified_by_agent_flag, 'N') = 'N';

    else
      x_progress := 165;
      -- <SERVICES FPJ>
      -- For the new Services lines, quantity will be null.
      -- Hence, added a decode statement to use amount directly
      -- in the total amount calculation when quantity is null.
      --< Bug 3549096 > Use _ALL tables instead of org-striped views.
      -- <Bug 4036549, include cancelled lines with with delivered quantity>
      select round(sum((
             decode(quantity,
                    null,
                    nvl(amount, 0),
                    (
                      (nvl(quantity,0) - nvl(quantity_cancelled,0))* nvl(unit_price,0)
                    )
                    )
             /x_base_min_unit)*
             x_base_min_unit))
      INTO   x_result_fld
      FROM   PO_REQUISITION_LINES_ALL
      WHERE  requisition_line_id              = x_object_id
      AND    nvl(modified_by_agent_flag, 'N') = 'N';

    end if;
    x_progress := 160;

    elsif (x_object_type = 'J' ) then /* Requisition Distribution */

    x_progress := 162;
    --bug#5092574 Retrieve the doc org id and pass this to retrieve
    --the document currency. Bug 5124868: refactored this call
    l_org_id := PO_MOAC_UTILS_PVT.get_entity_org_id(
                  PO_MOAC_UTILS_PVT.g_doc_type_REQUISITION
                , PO_MOAC_UTILS_PVT.g_doc_level_DISTRIBUTION
                , x_object_id);--bug#5092574

    po_core_s2.get_req_currency (x_object_id,
                                 x_base_currency,
                                 l_org_id);--bug#5092574
    x_progress := 164;
    po_core_s2.get_currency_info (x_base_currency,
                       x_base_precision,
                       x_base_min_unit );

    x_progress := 166;

    -- <SERVICES FPJ>
    -- Modified the SELECT statement to take account into Services
    -- lines. For the new Services lines, quantity will be null.
    -- Hence, added decode statements to use amount directly
    -- in the total amount calculation when quantity is null.
    --< Bug 3549096 > Use _ALL tables instead of org-striped views.

/*  bug 12584086 : Added condition to not calculate amount for distribution for
    which line is modified or not valid. */

    SELECT
    sum( decode
       ( x_base_min_unit, NULL,
             decode(quantity, NULL,
                    round( nvl(PORD.req_line_amount, 0),
                           x_base_precision),
                    round( nvl(PORD.req_line_quantity, 0) *
                           nvl(PORL.unit_price, 0),
                           x_base_precision)
                    ),
             decode(quantity, NULL,
                    round((nvl(PORD.req_line_amount, 0) /
                           x_base_min_unit) *
                           x_base_min_unit),
                    round((nvl(PORD.req_line_quantity, 0) *
                           nvl(PORL.unit_price, 0) /
                           x_base_min_unit) *
                           x_base_min_unit)
                   )))
    INTO   x_result_fld
    FROM   PO_REQ_DISTRIBUTIONS_ALL PORD,
           PO_REQUISITION_LINES_ALL PORL
    WHERE  PORD.distribution_id             = x_object_id
    AND    PORD.requisition_line_id         = PORL.requisition_line_id
    AND  nvl(PORL.modified_by_agent_flag, 'N') = 'N'; -- bug 12584086

  elsif (x_object_type = 'C' ) then /* Contract */

    x_progress := 170;
    --< Bug 3549096 > Use _ALL tables instead of org-striped views.
    SELECT c.minimum_accountable_unit,
           c.precision
    INTO   x_min_unit,
           x_precision
    FROM   FND_CURRENCIES C,
           PO_HEADERS_ALL     PH
    WHERE  PH.po_header_id  = x_object_id
    AND    C.currency_code  = PH.CURRENCY_CODE;

/* 716188 - SVAIDYAN : Changed the sql stmt to select only Standard and Planned
   POs that reference this contract and also to convert the amount into the
   Contract's currency. This is achieved by converting the PO amt first to the
   functional currency and then changing this to the Contract currency */

/* 716188 - Added an outer join on PO_DISTRIBUTIONS */
/* 866358 - BPESCHAN: Changed the sql stmt to select quantity_ordered and
   quantity_cancelled from PO_DISTRIBUTIONS instead of PO_LINE_LOCATIONS.
   This fix prevents incorrect calculation for amount release when more then
   one distribution exists. */

/* 958792 kbenjami 8/25/99.  Proprogated fix from R11.
   849493 - SVAIDYAN: Do a sum(round()) instead of round(sum()) since what
                      we pass to GL is the round of individual dist. amounts
                      and the sum of these rounded values is what should be
                      displayed as the header total.
*/
/*Bug3760487:Purchase Order form was displaying incorrect released
  amount for foreign currency contract when the PO currency is same
  as the contract currency and the rates were different.Added the decode
  to perform the currency conversion only when the currency code of
  PO and contract are different.
  Also removed the join to FND_CURRENCIES
*/
/*Bug 12723347
  1)For execution documents with same currency as the Contract, get
  quantity/amount from po_line_locations_all;
  2)For execution documents with different currency as the Contract, get
  quantity/amount from po_distributions_all;

  Assume most execution documents have same currency as the contract, so the
  performance impact as described in bug 7518629 by reverting back to POD
 (second case) will be limited.*/

    if x_min_unit is null then
      x_progress := 172;
      --< Bug 3549096 > Use _ALL tables instead of org-striped views.
      --<Bug 10060275 Modifed the following sql to increase the performance
      -- when the contract PO is queried through the PO summary form.


      /*SELECT nvl ( sum (decode ( PH.currency_code, PH1.currency_code,
                           round (
			         decode ( PLL.quantity,
                                           null,
					       ( nvl ( PLL.amount,0) -
					           nvl(PLL.amount_cancelled, 0) ),
                                               ( nvl ( PLL.quantity,0) -
						   nvl ( PLL.quantity_cancelled,0 ) )
						   * nvl(pll.price_override,0) ) ,x_precision ),
                            round (
			          decode ( PLL.quantity,
                                           null,
					       ( nvl ( PLL.amount, 0) -
					           nvl ( PLL.amount_cancelled, 0 ) ),
                                               ( nvl ( PLL.quantity,0) -
						   nvl ( PLL.quantity_cancelled,0 ) )
						   * nvl(pll.price_override,0) ) * nvl(POD.rate,nvl(PH1.rate,1)) / nvl (PH.rate,1),x_precision)
              ) ) , 0 )
INTO   x_result_fld
FROM   PO_LINE_LOCATIONS_ALL PLL,
       PO_DISTRIBUTIONS_ALL POD,
       PO_LINES_ALL PL,
       PO_HEADERS_ALL PH,
       PO_HEADERS_ALL PH1
WHERE  PH.po_header_id      = x_object_id
  AND  PH.po_header_id      = PL.contract_id
  AND  PL.po_line_id        = PLL.po_line_id
  AND  PLL.shipment_type IN ('STANDARD','PLANNED')
  AND  POD.line_location_id(+) = PLL.line_location_id
  AND  PH1.po_header_id = PL.po_header_id;*/

  --Get release amount for documents with same currency
      SELECT nvl ( sum (round (decode ( PLL.quantity,null,
                    ( nvl ( PLL.amount,0) -nvl(PLL.amount_cancelled, 0) ),
                    ( nvl ( PLL.quantity,0) - nvl ( PLL.quantity_cancelled,0 ) )
                          * nvl(pll.price_override,0) ) , x_precision)), 0)
      INTO   l_rel_amt_same_curr
      FROM   PO_LINE_LOCATIONS_ALL PLL,
             PO_LINES_ALL PL,
             PO_HEADERS_ALL PH,
             PO_HEADERS_ALL PH1
      WHERE  PH.po_header_id      = x_object_id
        AND  PH.po_header_id      = PL.contract_id
        AND  PL.po_line_id        = PLL.po_line_id
        AND  PLL.shipment_type IN ('STANDARD','PLANNED')
        AND  PH1.po_header_id = PL.po_header_id
        and  PH.currency_code = PH1.currency_code;

      --Get release amount for documents with different currency
      SELECT nvl (sum(round(decode(POD.quantity_ordered, null,
                              (nvl(POD.amount_ordered, 0) - nvl(POD.amount_cancelled, 0)),
                              (nvl(POD.quantity_ordered,0) - nvl(POD.quantity_cancelled,0))
                                 * nvl(pll.price_override,0) * nvl(POD.rate, nvl(PH1.rate,1))
                                 /nvl(PH.rate,1)), x_precision)
                ),0)
      INTO   l_rel_amt_diff_curr
      FROM   PO_LINE_LOCATIONS_ALL PLL,
             PO_DISTRIBUTIONS_ALL POD,
             PO_LINES_ALL PL,
             PO_HEADERS_ALL PH,
             PO_HEADERS_ALL PH1
      WHERE  PH.po_header_id      = x_object_id
        AND  PH.po_header_id      = PL.contract_id
        AND  PL.po_line_id        = PLL.po_line_id
        AND  PLL.shipment_type IN ('STANDARD','PLANNED')
        AND  POD.line_location_id(+) = PLL.line_location_id
        AND  PH1.po_header_id = PL.po_header_id
        and PH.currency_code <> PH1.currency_code;

      x_result_fld := l_rel_amt_same_curr + l_rel_amt_diff_curr;


    else

/* 958792 kbenjami 8/25/99.  Proprogated fix from R11.
   849493 - SVAIDYAN: Do a sum(round()) instead of round(sum()) since what
                      we pass to GL is the round of individual dist. amounts
                      and the sum of these rounded values is what should be
                      displayed as the header total.
*/
      x_progress := 174;
      --< Bug 3549096 > Use _ALL tables instead of org-striped views.
      --<Bug 10060275 Modifed the following sql to increase the performance
      -- when the contract PO is queried through the PO summary form.
      /*SELECT
      nvl(sum(decode(PH.currency_code, PH1.currency_code,
                 round(
                      decode(PLL.quantity,     --Bug# 5238463
                              null,
                                 (nvl(PLL.amount, 0) -
                                    nvl(PLL.amount_cancelled, 0)),
                                 ((nvl(PLL.quantity,0) -
                                    nvl(PLL.quantity_cancelled,0))
                                   * nvl(pll.price_override,0)))/x_min_unit),
                 round(
                      decode(PLL.quantity,
                              null,
                                 (nvl(PLL.amount, 0) -
                                    nvl(PLL.amount_cancelled, 0)),
                                 ((nvl(PLL.quantity,0) -
                                    nvl(PLL.quantity_cancelled,0))
                                    * nvl(pll.price_override,0)))
                    * nvl(POD.rate, nvl(PH1.rate,1))/nvl(PH.rate,1)/x_min_unit))
              * x_min_unit),0)
      INTO   x_result_fld
      FROM   PO_DISTRIBUTIONS_ALL POD,
             PO_LINE_LOCATIONS_ALL PLL,
             PO_LINES_ALL PL,
             PO_HEADERS_ALL PH,
             PO_HEADERS_ALL PH1
             --,FND_CURRENCIES C
      WHERE  PH.po_header_id      = x_object_id
      AND    PH.po_header_id      = PL.contract_id         -- <GC FPJ>
      --AND    PH.currency_code     = C.currency_code
      AND    PL.po_line_id        = PLL.po_line_id
      AND    PLL.shipment_type in ('STANDARD','PLANNED')
      AND    POD.line_location_id(+) = PLL.line_location_id
      AND    PH1.po_header_id = PL.po_header_id;*/

	         --Get release amount for documents with same currency
      SELECT nvl ( sum (round (decode ( PLL.quantity,null,
                    ( nvl ( PLL.amount,0) -nvl(PLL.amount_cancelled, 0) ),
                    ( nvl ( PLL.quantity,0) - nvl ( PLL.quantity_cancelled,0 ) )
                          * nvl(pll.price_override,0) )/x_min_unit) * x_min_unit), 0)
      INTO   l_rel_amt_same_curr
      FROM   PO_LINE_LOCATIONS_ALL PLL,
             PO_LINES_ALL PL,
             PO_HEADERS_ALL PH,
             PO_HEADERS_ALL PH1
      WHERE  PH.po_header_id      = x_object_id
        AND  PH.po_header_id      = PL.contract_id
        AND  PL.po_line_id        = PLL.po_line_id
        AND  PLL.shipment_type IN ('STANDARD','PLANNED')
        AND  PH1.po_header_id = PL.po_header_id
        and  PH.currency_code = PH1.currency_code;

     --Get release amount for documents with different currency
     SELECT nvl (sum(round(decode(POD.quantity_ordered, null,
                              (nvl(POD.amount_ordered, 0) - nvl(POD.amount_cancelled, 0)),
                              (nvl(POD.quantity_ordered,0) - nvl(POD.quantity_cancelled,0))
                                 * nvl(pll.price_override,0) * nvl(POD.rate, nvl(PH1.rate,1))
                                 /nvl(PH.rate,1))/x_min_unit)
                * x_min_unit),0)
      INTO   l_rel_amt_diff_curr
      FROM   PO_LINE_LOCATIONS_ALL PLL,
             PO_DISTRIBUTIONS_ALL POD,
             PO_LINES_ALL PL,
             PO_HEADERS_ALL PH,
             PO_HEADERS_ALL PH1
      WHERE  PH.po_header_id      = x_object_id
        AND  PH.po_header_id      = PL.contract_id
        AND  PL.po_line_id        = PLL.po_line_id
        AND  PLL.shipment_type IN ('STANDARD','PLANNED')
        AND  POD.line_location_id(+) = PLL.line_location_id
        AND  PH1.po_header_id = PL.po_header_id
        and PH.currency_code <> PH1.currency_code;

      x_result_fld := l_rel_amt_same_curr + l_rel_amt_diff_curr;
    end if;

  elsif (x_object_type = 'R' ) then /* Release */

    if x_base_cur_result then
      x_progress := 180;
      --< Bug 3549096 > Use _ALL tables instead of org-striped views.
      SELECT GSB.currency_code,
             POH.currency_code
      INTO   x_base_currency,
             x_po_currency
      FROM   PO_HEADERS_ALL POH,
             FINANCIALS_SYSTEM_PARAMS_ALL FSP,
             GL_SETS_OF_BOOKS GSB,
             PO_RELEASES_ALL POR
      WHERE  POR.po_release_id   = x_object_id
      AND    POH.po_header_id    = POR.po_header_id
      AND    NVL(POR.org_id,-99) = NVL(FSP.org_id,-99)      --< Bug 3549096 >
      AND    FSP.set_of_books_id = GSB.set_of_books_id;

      if (x_base_currency <> x_po_currency) then
        /* Get precision and minimum accountable unit of the PO CURRENCY */
        x_progress := 190;
        po_core_s2.get_currency_info (x_po_currency,
                           x_precision,
                           x_min_unit );

        /* Get precision and minimum accountable unit of the base CURRENCY */
        x_progress := 200;
        po_core_s2.get_currency_info (x_base_currency,
                           x_base_precision,
                           x_base_min_unit );

        if x_base_min_unit is null then
          if x_min_unit is null then
            x_progress := 210;

/* 958792 kbenjami 8/25/99.  Proprogated fix from R11.
   849493 - SVAIDYAN: Do a sum(round()) instead of round(sum()) since what
                      we pass to GL is the round of individual dist. amounts
                      and the sum of these rounded values is what should be
                      displayed as the header total.
*/
            -- <SERVICES FPJ>
            -- For the new Services lines, quantity will be null.
            -- Hence, added a decode statement to use amount directly
            -- in the total amount calculation when quantity is null.
            --< Bug 3549096 > Use _ALL tables instead of org-striped views.
            select nvl(sum(round(round(
                   decode(POD.quantity_ordered,
                          null,
                          nvl(POD.amount_ordered, 0),
                          (nvl(POD.quantity_ordered,0) *
                          nvl(PLL.price_override,0))
                         )
                   * POD.rate
                   ,x_precision),x_base_precision)),0)
            INTO x_result_fld
            FROM PO_DISTRIBUTIONS_ALL POD, PO_LINE_LOCATIONS_ALL PLL
            WHERE PLL.po_release_id    = x_object_id
            AND   PLL.line_location_id = POD.line_location_id
            AND   PLL.shipment_type in ('SCHEDULED','BLANKET');

          else
            x_progress := 212;
            -- <SERVICES FPJ>
            -- For the new Services lines, quantity will be null.
            -- Hence, added a decode statement to use amount directly
            -- in the total amount calculation when quantity is null.
            --< Bug 3549096 > Use _ALL tables instead of org-striped views.
	    SELECT nvl(sum(round( round(
                   decode(POD.quantity_ordered,
                          null,
                          nvl(POD.amount_ordered, 0),
                          (nvl(POD.quantity_ordered, 0) *
                          nvl(PLL.price_override, 0))
                         )
                   * POD.rate /
                   X_min_unit) * X_min_unit , X_base_precision)),0)
            INTO x_result_fld
            FROM PO_DISTRIBUTIONS_ALL POD, PO_LINE_LOCATIONS_ALL PLL
            WHERE PLL.po_release_id    = x_object_id
            AND   PLL.line_location_id = POD.line_location_id
            AND   PLL.shipment_type in ('SCHEDULED','BLANKET');

          end if;
        else
          if X_min_unit is null then
            x_progress := 214;
            -- <SERVICES FPJ>
            -- For the new Services lines, quantity will be null.
            -- Hence, added a decode statement to use amount directly
            -- in the total amount calculation when quantity is null.
            --< Bug 3549096 > Use _ALL tables instead of org-striped views.
            SELECT nvl(sum(round( round(
                   decode(POD.quantity_ordered,
                          null,
                          nvl(POD.amount_ordered, 0),
                          (nvl(POD.quantity_ordered, 0) *
                          nvl(PLL.price_override, 0))
                         )
                   * POD.rate
                   , X_precision)
                   / X_base_min_unit ) * X_base_min_unit) ,0)
            INTO   X_result_fld
            FROM PO_DISTRIBUTIONS_ALL POD, PO_LINE_LOCATIONS_ALL PLL
            WHERE PLL.po_release_id    = x_object_id
            AND   PLL.line_location_id = POD.line_location_id
            AND   PLL.shipment_type in ('SCHEDULED','BLANKET');

          else
            x_progress := 216;
            -- <SERVICES FPJ>
            -- For the new Services lines, quantity will be null.
            -- Hence, added a decode statement to use amount directly
            -- in the total amount calculation when quantity is null.
            --< Bug 3549096 > Use _ALL tables instead of org-striped views.
	    SELECT nvl(sum(round( round(
                   decode(POD.quantity_ordered,
                          null,
                          nvl(POD.amount_ordered, 0),
                          (nvl(POD.quantity_ordered, 0) *
                          nvl(PLL.price_override, 0))
                         )
                   * POD.rate /
                   X_min_unit) * X_min_unit  / X_base_min_unit)
                   * X_base_min_unit) , 0)
            INTO   X_result_fld
            FROM PO_DISTRIBUTIONS_ALL POD, PO_LINE_LOCATIONS_ALL PLL
            WHERE PLL.po_release_id    = x_object_id
            AND   PLL.line_location_id = POD.line_location_id
            AND   PLL.shipment_type in ('SCHEDULED','BLANKET');

          end if;
        end if;

      end if;
    else
      x_progress := 220;
      --< Bug 3549096 > Use _ALL tables instead of org-striped views.
      SELECT c.minimum_accountable_unit,
             c.precision
      INTO   x_min_unit,
             x_precision
      FROM   FND_CURRENCIES C,
             PO_RELEASES_ALL    POR,
             PO_HEADERS_ALL     PH
      WHERE  POR.po_release_id = x_object_id
      AND    PH.po_header_id   = POR.PO_HEADER_ID
      AND    C.currency_code   = PH.CURRENCY_CODE;

      if x_min_unit is null then

/* 958792 kbenjami 8/25/99.  Proprogated fix from R11.
   849493 - SVAIDYAN: Do a sum(round()) instead of round(sum()) since what
                      we pass to GL is the round of individual dist. amounts
                      and the sum of these rounded values is what should be
                      displayed as the header total.
*/
        x_progress := 222;
        -- <SERVICES FPJ>
        -- For the new Services lines, quantity will be null.
        -- Hence, added a decode statement to use amount directly
        -- in the total amount calculation when quantity is null.
        --< Bug 3549096 > Use _ALL tables instead of org-striped views.
        select sum(round(
               decode(pll.quantity,
                      null,
                      (pll.amount - nvl(pll.amount_cancelled,0)),
                      ((pll.quantity - nvl(pll.quantity_cancelled,0)) *
                      nvl(pll.price_override,0))
                     )
               ,x_precision))
        INTO   x_result_fld
        FROM   PO_LINE_LOCATIONS_ALL PLL
        WHERE  PLL.po_release_id   = x_object_id
        AND    PLL.shipment_type  in ( 'SCHEDULED','BLANKET');

      else
		/* Bug 1111926: GMudgal 2/18/2000
		** Incorrect placement of brackets caused incorrect rounding
		** and consequently incorrect PO header totals
		*/
        x_progress := 224;

        -- <SERVICES FPJ>
        -- For the new Services lines, quantity will be null.
        -- Hence, added a decode statement to use amount directly
        -- in the total amount calculation when quantity is null.
        --< Bug 3549096 > Use _ALL tables instead of org-striped views.
        select sum(round(
               decode(pll.quantity,
                      null,
                     (pll.amount - nvl(pll.amount_cancelled,0)),
                     ((pll.quantity - nvl(pll.quantity_cancelled,0)) *
                     nvl(pll.price_override,0))
                     )
               /x_min_unit) *
               x_min_unit)
        INTO   x_result_fld
        FROM   PO_LINE_LOCATIONS_ALL PLL
        WHERE  PLL.po_release_id   = x_object_id
        AND    PLL.shipment_type  in ( 'SCHEDULED','BLANKET');

      end if;

    end if;

  elsif (x_object_type = 'L' ) then /* Po Line */
    x_progress := 230;
    --< Bug 3549096 > Use _ALL tables instead of org-striped views.
    SELECT sum(c.minimum_accountable_unit),
           sum(c.precision)
    INTO   x_min_unit,
           x_precision
    FROM   FND_CURRENCIES C,
           PO_HEADERS_ALL     PH,
           PO_LINES_ALL POL
    WHERE  POL.po_line_id   = x_object_id
    AND    PH.po_header_id  = POL.po_header_id
    AND    C.currency_code  = PH.CURRENCY_CODE;

    if x_min_unit is null then
      x_progress := 232;

/*    Bug No. 1431811 Changing the round of sum to sum of rounded totals
      select round(sum((pll.quantity - nvl(pll.quantity_cancelled,0))*
                       nvl(pll.price_override,0)),x_precision)
*/
/*    Bug No. 1849112 In the previous fix of 143811 by mistake x_precision
      was not used.
*/
      -- <SERVICES FPJ>
      -- For the new Services lines, quantity will be null.
      -- Hence, added a decode statement to use amount directly
      -- in the total amount calculation when quantity is null.
      --< Bug 3549096 > Use _ALL tables instead of org-striped views.
      select sum(round((
             decode(pll.quantity,
                    null,
                    (pll.amount - nvl(pll.amount_cancelled, 0)),
                    (pll.quantity - nvl(pll.quantity_cancelled,0))
                    * nvl(pll.price_override,0)
                   )
             ),x_precision))
      INTO   x_result_fld
      FROM   PO_LINE_LOCATIONS_ALL PLL
      WHERE  PLL.po_line_id   = x_object_id
      --Bug 17526240 fix
      AND (PLL.shipment_type in ('STANDARD','PLANNED')
           OR (PLL.shipment_type = 'BLANKET' AND NVL(PLL.consigned_flag, 'N') <> 'Y' ));

    else
      x_progress := 234;

/*    Bug No. 1431811 Changing the round of sum to sum of rounded totals
*/
      -- <SERVICES FPJ>
      -- For the new Services lines, quantity will be null.
      -- Hence, added a decode statement to use amount directly
      -- in the total amount calculation when quantity is null.
      --< Bug 3549096 > Use _ALL tables instead of org-striped views.
      select sum(round((
             decode(pll.quantity,
                    null,
                    (pll.amount - nvl(pll.amount_cancelled,0)),
                    (pll.quantity - nvl(pll.quantity_cancelled,0))
                    * nvl(pll.price_override,0)
                   )
             / x_min_unit) * x_min_unit))
      INTO   x_result_fld
      FROM   PO_LINE_LOCATIONS_ALL PLL
      WHERE  PLL.po_line_id   = x_object_id
      --Bug 17526240 fix
      AND (PLL.shipment_type in ('STANDARD','PLANNED')
           OR (PLL.shipment_type = 'BLANKET' AND NVL(PLL.consigned_flag, 'N') <> 'Y' ));

    end if;

  elsif (x_object_type = 'S' ) then /* PO Shipment */
    x_progress := 240;
    --< Bug 3549096 > Use _ALL tables instead of org-striped views.
    SELECT c.minimum_accountable_unit,
           c.precision
    INTO   x_min_unit,
           x_precision
    FROM   FND_CURRENCIES C,
           PO_HEADERS_ALL     PH,
           PO_LINE_LOCATIONS_ALL PLL
    WHERE  PLL.line_location_id   = x_object_id
    AND    PH.po_header_id        = PLL.po_header_id
    AND    C.currency_code        = PH.CURRENCY_CODE;

    if x_min_unit is null then
      x_progress := 242;

/*    Bug No. 1431811 Changing the round of sum to sum of rounded totals
      select round(sum((pll.quantity - nvl(pll.quantity_cancelled,0))*
                       nvl(pll.price_override,0)),x_precision)
*/
      -- <SERVICES FPJ>
      -- For the new Services lines, quantity will be null.
      -- Hence, added a decode statement to use amount directly
      -- in the total amount calculation when quantity is null.
      --< Bug 3549096 > Use _ALL tables instead of org-striped views.
      select sum(round((
             decode(pll.quantity,
                    null,
                    (pll.amount - nvl(pll.amount_cancelled,0)),
                    (pll.quantity - nvl(pll.quantity_cancelled,0))
                    * nvl(pll.price_override,0)
                   )
             ),x_precision))
      INTO   x_result_fld
      FROM   PO_LINE_LOCATIONS_ALL PLL
      WHERE  PLL.line_location_id   = x_object_id;

    else
      x_progress := 244;
      -- <SERVICES FPJ>
      -- For the new Services lines, quantity will be null.
      -- Hence, added a decode statement to use amount directly
      -- in the total amount calculation when quantity is null.
      --< Bug 3549096 > Use _ALL tables instead of org-striped views.
      select round(sum((
             decode(pll.quantity,
                    null,
                    (pll.amount - nvl(pll.amount_cancelled,0)),
                    (pll.quantity - nvl(pll.quantity_cancelled,0))
                    * nvl(pll.price_override,0)
                   )
             /x_min_unit) * x_min_unit))
      INTO   x_result_fld
      FROM   PO_LINE_LOCATIONS_ALL PLL
      WHERE  PLL.line_location_id   = x_object_id;

    end if;

  end if; /* x_object_type */

  /* If x_result_fld has a null value, return 0 as the total. */
  IF x_result_fld IS NULL THEN
	x_result_fld := 0;
  END IF;

  RETURN(x_result_fld);

  EXCEPTION
  WHEN OTHERS THEN
    RETURN(0);
    RAISE;

END get_total;

--<CONTERMS FPJ START>
-------------------------------------------------------------------------------
--Start of Comments
--Name: GET_ARCHIVE_TOTAL
--Pre-reqs:
--  None
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--   Returns total amount for latest archived revision for Standard Purchase order
--Parameters:
--IN:
--  p_object_id
--     PO header id
--  p_doc_type
--     The main doc type for PO. Valid values are 'PO'
--  p_doc_subtype
--     The lookup code of the document. Valid values are 'STANDARD'
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
FUNCTION  get_archive_total (p_object_id       IN NUMBER,
                             p_doc_type        IN VARCHAR2,
                             p_doc_subtype     IN VARCHAR2,
                             p_base_cur_result IN VARCHAR2) RETURN NUMBER IS

  l_base_currency       PO_HEADERS_ALL.CURRENCY_CODE%TYPE;
  l_po_currency         PO_HEADERS_ALL.CURRENCY_CODE%TYPE;
  l_min_unit            FND_CURRENCIES.MINIMUM_ACCOUNTABLE_UNIT%TYPE;
  l_base_min_unit       FND_CURRENCIES.MINIMUM_ACCOUNTABLE_UNIT%TYPE;
  l_precision           FND_CURRENCIES.PRECISION%TYPE;
  l_base_precision      FND_CURRENCIES.PRECISION%TYPE;
  l_archive_total_amt   NUMBER;
  l_progress            VARCHAR2(3):='000';
BEGIN
  l_progress := '010';
  IF (p_doc_type = 'PO') AND (p_doc_subtype = 'STANDARD') then

        --Get the currency code of the PO and the base currency code

        po_core_s2.get_po_currency (x_object_id=>p_object_id,
                                    x_base_currency =>l_base_currency,
                                    x_po_currency  =>l_po_currency );
      l_progress := '020';
       --Get precision and minimum accountable unit of the PO CURRENCY
        po_core_s2.get_currency_info (x_currency_code => l_po_currency,
                                      x_precision=>l_precision,
                                      x_min_unit=>l_min_unit );
      l_progress := '030';
       -- Chk if base_currency = po_currency
       IF (p_base_cur_result = 'Y') AND (l_base_currency <> l_po_currency) then

          l_progress := '040';
            --Get precision and minimum accountable unit of the base CURRENCY

            po_core_s2.get_currency_info (x_currency_code => l_base_currency,
                                            x_precision=>l_base_precision,
                                             x_min_unit=>l_base_min_unit );


       ELSE -- if l_base_currency <> l_po_currency
         l_base_precision := l_precision;
         l_base_min_unit  := l_min_unit;
       END IF;  -- if l_base_currency <> l_po_currency
       l_progress := '050';
          --SQL WHAT- This query returns the total amount for an archived SPO
          --SQL WHY- To check if archived amount different from working copy amt. for a po in contract terms
          --SQL JOIN- Location id in PO_LINE_LOCATIONS_ARCHIVE_ALL and PO_DISTRIBUTIONS_ARCHIVE_ALL
          SELECT nvl(sum(round( ( (round( ( ( decode(POD.quantity_ordered, NULL,
                                                       (nvl(POD.amount_ordered,0) -
                                                         nvl(POD.amount_cancelled,0)
                                                       ),
                                                       ( (nvl(POD.quantity_ordered,0) -
                                                           nvl(POD.quantity_cancelled,0)
                                                         )*
                                                            nvl(PLL.price_override, 0)
                                                        )
                                                      ) *
                                               decode(p_base_cur_result,'Y',nvl(POD.rate,1),1)
                                            )/
                                             nvl(l_min_unit,1)
                                          ),decode(l_min_unit,null,l_precision,0)
                                        )*
                                         nvl(l_min_unit,1)
                                  )/
                                   nvl(l_base_min_unit,1)
                                )
                                 ,decode(l_base_min_unit,null,l_base_precision,0)
                              )*
                               nvl(l_base_min_unit,1)
                        ), 0
                      )
            INTO   l_archive_total_amt
            FROM   PO_DISTRIBUTIONS_ARCHIVE_ALL POD, PO_LINE_LOCATIONS_ARCHIVE_ALL PLL
            WHERE  PLL.po_header_id = p_object_id
            AND    PLL.shipment_type in ('STANDARD')
            AND    PLL.line_location_id = POD.line_location_id
            AND    PLL.LATEST_EXTERNAL_FLAG = 'Y'
            AND    POD.LATEST_EXTERNAL_FLAG = 'Y';

        l_progress := '060';
  END if;-- (p_doc_type = 'PO') AND (p_doc_subtype = 'STANDARD')
  l_progress := '070';
  --If l_archive_total_amt has a null value, return 0 as the total.
  IF l_archive_total_amt IS NULL THEN
	l_archive_total_amt := 0;
  END IF;
  l_progress := '080';
  RETURN(l_archive_total_amt);

EXCEPTION
   WHEN OTHERS THEN
            IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
            THEN
              fnd_msg_pub.add_exc_msg (g_pkg_name, 'GET_ARCHIVE_TOTAL',
                  SUBSTRB (SQLERRM , 1 , 200) || ' at location ' || l_progress);
            END IF;
            RETURN(0);
END get_archive_total;
--<CONTERMS FPJ END>



--<POC FPJ START>


FUNCTION  get_archive_total_for_any_rev (p_object_id       IN NUMBER,
                             p_object_type in varchar2,
                             p_doc_type        IN VARCHAR2,
                             p_doc_subtype     IN VARCHAR2,
                             p_doc_revision    IN NUMBER,
                             p_base_cur_result IN VARCHAR2) RETURN NUMBER IS

  l_base_currency       PO_HEADERS_ALL.CURRENCY_CODE%TYPE;
  l_po_currency         PO_HEADERS_ALL.CURRENCY_CODE%TYPE;
  l_min_unit            FND_CURRENCIES.MINIMUM_ACCOUNTABLE_UNIT%TYPE;
  l_base_min_unit       FND_CURRENCIES.MINIMUM_ACCOUNTABLE_UNIT%TYPE;
  l_precision           FND_CURRENCIES.PRECISION%TYPE;
  l_base_precision      FND_CURRENCIES.PRECISION%TYPE;
  l_archive_total_amt   NUMBER;
  l_progress            VARCHAR2(3):='000';

BEGIN
  l_progress := '010';
  IF (p_doc_type = 'PO') AND (p_doc_subtype = 'STANDARD') then

    IF p_object_type = 'H' then

        --Get the currency code of the PO and the base currency code

        po_core_s2.get_po_currency (x_object_id=>p_object_id,
                                    x_base_currency =>l_base_currency,
                                    x_po_currency  =>l_po_currency );
        l_progress := '020';
        --Get precision and minimum accountable unit of the PO CURRENCY
        po_core_s2.get_currency_info (x_currency_code => l_po_currency,
                                      x_precision=>l_precision,
                                      x_min_unit=>l_min_unit );
        l_progress := '030';
        -- Chk if base_currency = po_currency
        IF (p_base_cur_result = 'Y') AND (l_base_currency <> l_po_currency) then

            l_progress := '040';
            --Get precision and minimum accountable unit of the base CURRENCY

            po_core_s2.get_currency_info (x_currency_code => l_base_currency,
                                          x_precision=>l_base_precision,
                                          x_min_unit=>l_base_min_unit );


        ELSE -- if l_base_currency <> l_po_currency
            l_base_precision := l_precision;
            l_base_min_unit  := l_min_unit;
        END IF;  -- if l_base_currency <> l_po_currency
        l_progress := '050';
          --SQL WHAT- This query returns the total amount for an archived SPO
          --SQL WHY- To derive the total amount for an archived PO revision
          --SQL JOIN- Location id in PO_LINE_LOCATIONS_ARCHIVE_ALL and PO_DISTRIBUTIONS_ARCHIVE_ALL
        SELECT nvl(sum(round( ( (round( ( ( decode(POD.quantity_ordered, NULL,
                                                       (nvl(POD.amount_ordered,0) -
                                                         nvl(POD.amount_cancelled,0)
                                                       ),
                                                       ( (nvl(POD.quantity_ordered,0) -
                                                           nvl(POD.quantity_cancelled,0)
                                                         )*
                                                            nvl(PLL.price_override, 0)
                                                        )
                                                      ) *
                                               decode(p_base_cur_result,'Y',nvl(POD.rate,1),1)
                                            )/
                                             nvl(l_min_unit,1)
                                          ),decode(l_min_unit,null,l_precision,0)
                                        )*
                                         nvl(l_min_unit,1)
                                  )/
                                   nvl(l_base_min_unit,1)
                                )
                                 ,decode(l_base_min_unit,null,l_base_precision,0)
                              )*
                               nvl(l_base_min_unit,1)
                        ), 0
                      )
        INTO   l_archive_total_amt
        FROM   PO_DISTRIBUTIONS_ARCHIVE_ALL POD, PO_LINE_LOCATIONS_ARCHIVE_ALL PLL
        WHERE  PLL.po_header_id = p_object_id
        AND    PLL.shipment_type in ('STANDARD')
        AND    PLL.line_location_id = POD.line_location_id
        AND    PLL.REVISION_NUM = (SELECT MAX(pll1.revision_num) FROM PO_LINE_LOCATIONS_ARCHIVE_ALL PLL1
                                   WHERE pll1.line_location_id = pll.line_location_id AND
                                             pll1.revision_num <= p_doc_revision)
        AND    POD.REVISION_NUM = (SELECT MAX(pdd1.revision_num) FROM PO_DISTRIBUTIONS_ARCHIVE_ALL PDD1
                                   WHERE pdd1.po_distribution_id = pod.po_distribution_id AND
                                         pdd1.revision_num <= p_doc_revision);

        l_progress := '060';


    elsif (p_object_type = 'S' ) then /* PO Shipment */
        l_progress := '070';
        --< Bug 3549096 > Use _ALL tables instead of org-striped views.
        SELECT c.minimum_accountable_unit,
               c.precision
        INTO   l_min_unit,
               l_precision
        FROM   FND_CURRENCIES C,
               PO_HEADERS_ALL     PH,
               PO_LINE_LOCATIONS_ALL PLL
        WHERE  PLL.line_location_id   = p_object_id
        AND    PH.po_header_id        = PLL.po_header_id
        AND    C.currency_code        = PH.CURRENCY_CODE;

        if l_min_unit is null then
          l_progress := '80';

          --SQL WHAT- This query returns the amount for the appropriate revision of a line_location
          --SQL WHY-  To return the amount for line location
          --SQL JOIN- Use MAX to derive the appropriate revision of a line location
          -- <SERVICES FPJ>
          -- For the new Services lines, quantity will be null.
          -- Hence, added a decode statement to use amount directly
          -- in the total amount calculation when quantity is null.
          SELECT sum(round((
                 decode(pll.quantity,
                        null,
                        (pll.amount - nvl(pll.amount_cancelled,0)),
                        (pll.quantity - nvl(pll.quantity_cancelled,0))
                        * nvl(pll.price_override,0)
                       )
                 ),l_precision))
          INTO   l_archive_total_amt
          FROM   PO_LINE_LOCATIONS_ARCHIVE_ALL PLL
          WHERE  PLL.line_location_id   = p_object_id AND
          PLL.revision_num = (SELECT MAX(pll1.revision_num) FROM PO_LINE_LOCATIONS_ARCHIVE_ALL PLL1 WHERE
                              pll1.line_location_id = pll.line_location_id AND
                              pll1.revision_num <= p_doc_revision) ;

        else
          l_progress := '90';
          -- <SERVICES FPJ>
          -- For the new Services lines, quantity will be null.
          -- Hence, added a decode statement to use amount directly
          -- in the total amount calculation when quantity is null.
          select round(sum((
                 decode(pll.quantity,
                        null,
                        (pll.amount - nvl(pll.amount_cancelled,0)),
                        (pll.quantity - nvl(pll.quantity_cancelled,0))
                        * nvl(pll.price_override,0)
                   )
                 /l_min_unit) * l_min_unit))
          INTO   l_archive_total_amt
          FROM   PO_LINE_LOCATIONS_ARCHIVE_ALL PLL
          WHERE  PLL.line_location_id   = p_object_id AND
          PLL.revision_num = (SELECT MAX(pll1.revision_num) FROM PO_LINE_LOCATIONS_ARCHIVE_ALL PLL1 WHERE
                              pll1.line_location_id = pll.line_location_id AND
                              pll1.revision_num <= p_doc_revision) ;

        end if;

       elsif (p_object_type = 'L' ) then /* Po Line */
          l_progress := '100';
          --< Bug 3549096 > Use _ALL tables instead of org-striped views.
          SELECT sum(c.minimum_accountable_unit),
                 sum(c.precision)
          INTO   l_min_unit,
                 l_precision
          FROM   FND_CURRENCIES C,
                 PO_HEADERS_ALL     PH,
                 PO_LINES_ALL POL
          WHERE  POL.po_line_id   = p_object_id
          AND    PH.po_header_id  = POL.po_header_id
          AND    C.currency_code  = PH.CURRENCY_CODE;

          if l_min_unit is null then
            l_progress := '105';

      -- <SERVICES FPJ>
      -- For the new Services lines, quantity will be null.
      -- Hence, added a decode statement to use amount directly
      -- in the total amount calculation when quantity is null.
            select sum(round((
                   decode(pll.quantity,
                          null,
                          (pll.amount - nvl(pll.amount_cancelled, 0)),
                          (pll.quantity - nvl(pll.quantity_cancelled,0))
                          * nvl(pll.price_override,0)
                         )
                      ),l_precision))
            INTO   l_archive_total_amt
            FROM   PO_LINE_LOCATIONS_ARCHIVE_ALL PLL
            WHERE  PLL.po_line_id   = p_object_id
            AND    PLL.shipment_type  in ( 'STANDARD','BLANKET','PLANNED')
            AND    PLL.revision_num = (SELECT MAX(pll1.revision_num) FROM PO_LINE_LOCATIONS_ARCHIVE_ALL PLL1 WHERE
                                        pll1.line_location_id = pll.line_location_id AND
                                        pll1.revision_num <= p_doc_revision) ;

          else
            l_progress := '110';

      -- <SERVICES FPJ>
      -- For the new Services lines, quantity will be null.
      -- Hence, added a decode statement to use amount directly
      -- in the total amount calculation when quantity is null.
            select sum(round((
                   decode(pll.quantity,
                          null,
                          (pll.amount - nvl(pll.amount_cancelled,0)),
                          (pll.quantity - nvl(pll.quantity_cancelled,0))
                          * nvl(pll.price_override,0)
                         )
                   / l_min_unit) * l_min_unit))
            INTO   l_archive_total_amt
            FROM   PO_LINE_LOCATIONS_ARCHIVE_ALL PLL
            WHERE  PLL.po_line_id   = p_object_id
            AND    PLL.shipment_type  in ( 'STANDARD','BLANKET','PLANNED')
            AND    PLL.revision_num = (SELECT MAX(pll1.revision_num) FROM PO_LINE_LOCATIONS_ARCHIVE_ALL PLL1 WHERE
                                       pll1.line_location_id = pll.line_location_id AND
                                       pll1.revision_num <= p_doc_revision) ;


          end if;
      end if; /* p_object_type */

  elsif (p_doc_type = 'RELEASE') AND (p_doc_subtype = 'BLANKET') then


     if (p_object_type = 'R' ) then /* Release */

       if p_base_cur_result = 'Y' then
         l_progress := '180';
         --< Bug 3549096 > Use _ALL tables instead of org-striped views.
         SELECT GSB.currency_code,
                POH.currency_code
         INTO   l_base_currency,
                l_po_currency
         FROM   PO_HEADERS_ALL POH,
                FINANCIALS_SYSTEM_PARAMS_ALL FSP,
                GL_SETS_OF_BOOKS GSB,
                PO_RELEASES_ALL POR
         WHERE  POR.po_release_id   = p_object_id
         AND    POH.po_header_id    = POR.po_header_id
         AND    NVL(POR.org_id,-99) = NVL(FSP.org_id,-99)   --< Bug 3549096 >
         AND    FSP.set_of_books_id = GSB.set_of_books_id;

         if (l_base_currency <> l_po_currency) then
           /* Get precision and minimum accountable unit of the PO CURRENCY */
           l_progress := '190';
           po_core_s2.get_currency_info (l_po_currency,
                              l_precision,
                              l_min_unit );

           /* Get precision and minimum accountable unit of the base CURRENCY */
           l_progress := '200';
           po_core_s2.get_currency_info (l_base_currency,
                              l_base_precision,
                              l_base_min_unit );

           if l_base_min_unit is null then
             if l_min_unit is null then
               l_progress := '210';

               -- <SERVICES FPJ>
               -- For the new Services lines, quantity will be null.
               -- Hence, added a decode statement to use amount directly
               -- in the total amount calculation when quantity is null.
               select nvl(sum(round(round(
                      decode(POD.quantity_ordered,
                             null,
                             nvl(POD.amount_ordered, 0),
                             (nvl(POD.quantity_ordered,0) *
                             nvl(PLL.price_override,0))
                            )
                      * POD.rate
                      ,l_precision),l_base_precision)),0)
               INTO l_archive_total_amt
               FROM PO_DISTRIBUTIONS_ARCHIVE_ALL POD, PO_LINE_LOCATIONS_ARCHIVE_ALL PLL
               WHERE PLL.po_release_id    = p_object_id
               AND   PLL.line_location_id = POD.line_location_id
               AND   PLL.shipment_type in ('SCHEDULED','BLANKET')
               AND   PLL.REVISION_NUM = (SELECT MAX(pll1.revision_num) FROM PO_LINE_LOCATIONS_ARCHIVE_ALL PLL1
                                         WHERE pll1.line_location_id = pll.line_location_id AND
                                               pll1.revision_num <= p_doc_revision)
               AND   POD.REVISION_NUM = (SELECT MAX(pdd1.revision_num) FROM PO_DISTRIBUTIONS_ARCHIVE_ALL PDD1
                                         WHERE pdd1.po_distribution_id = pod.po_distribution_id AND
                                               pdd1.revision_num <= p_doc_revision);


             else
               l_progress := '212';
               -- <SERVICES FPJ>
               -- For the new Services lines, quantity will be null.
               -- Hence, added a decode statement to use amount directly
               -- in the total amount calculation when quantity is null.
	       SELECT nvl(sum(round( round(
                      decode(POD.quantity_ordered,
                             null,
                             nvl(POD.amount_ordered, 0),
                             (nvl(POD.quantity_ordered, 0) *
                             nvl(PLL.price_override, 0))
                            )
                      * POD.rate /
                      l_min_unit) * l_min_unit , l_base_precision)),0)
               INTO l_archive_total_amt
               FROM PO_DISTRIBUTIONS_ARCHIVE_ALL POD, PO_LINE_LOCATIONS_ARCHIVE_ALL PLL
               WHERE PLL.po_release_id    = p_object_id
               AND   PLL.line_location_id = POD.line_location_id
               AND   PLL.shipment_type in ('SCHEDULED','BLANKET')
               AND   PLL.REVISION_NUM = (SELECT MAX(pll1.revision_num) FROM PO_LINE_LOCATIONS_ARCHIVE_ALL PLL1
                                         WHERE pll1.line_location_id = pll.line_location_id AND
                                               pll1.revision_num <= p_doc_revision)
               AND   POD.REVISION_NUM = (SELECT MAX(pdd1.revision_num) FROM PO_DISTRIBUTIONS_ARCHIVE_ALL PDD1
                                         WHERE pdd1.po_distribution_id = pod.po_distribution_id AND
                                               pdd1.revision_num <= p_doc_revision);

             end if;
           else
             if l_min_unit is null then
               l_progress := '214';
               -- <SERVICES FPJ>
               -- For the new Services lines, quantity will be null.
               -- Hence, added a decode statement to use amount directly
               -- in the total amount calculation when quantity is null.
               SELECT nvl(sum(round( round(
                      decode(POD.quantity_ordered,
                             null,
                             nvl(POD.amount_ordered, 0),
                             (nvl(POD.quantity_ordered, 0) *
                             nvl(PLL.price_override, 0))
                            )
                      * POD.rate
                      , l_precision)
                      / l_base_min_unit ) * l_base_min_unit) ,0)
               INTO   l_archive_total_amt
               FROM PO_DISTRIBUTIONS_ARCHIVE_ALL POD, PO_LINE_LOCATIONS_ARCHIVE_ALL PLL
               WHERE PLL.po_release_id    = p_object_id
               AND   PLL.line_location_id = POD.line_location_id
               AND   PLL.shipment_type in ('SCHEDULED','BLANKET')
               AND   PLL.REVISION_NUM = (SELECT MAX(pll1.revision_num) FROM PO_LINE_LOCATIONS_ARCHIVE_ALL PLL1
                                         WHERE pll1.line_location_id = pll.line_location_id AND
                                               pll1.revision_num <= p_doc_revision)
               AND   POD.REVISION_NUM = (SELECT MAX(pdd1.revision_num) FROM PO_DISTRIBUTIONS_ARCHIVE_ALL PDD1
                                         WHERE pdd1.po_distribution_id = pod.po_distribution_id AND
                                               pdd1.revision_num <= p_doc_revision);

             else
               l_progress := '216';
            -- <SERVICES FPJ>
               -- For the new Services lines, quantity will be null.
               -- Hence, added a decode statement to use amount directly
               -- in the total amount calculation when quantity is null.
	       SELECT nvl(sum(round( round(
                      decode(POD.quantity_ordered,
                             null,
                             nvl(POD.amount_ordered, 0),
                             (nvl(POD.quantity_ordered, 0) *
                             nvl(PLL.price_override, 0))
                            )
                      * POD.rate /
                      l_min_unit) * l_min_unit  / l_base_min_unit)
                      * l_base_min_unit) , 0)
               INTO   l_archive_total_amt
               FROM PO_DISTRIBUTIONS_ARCHIVE_ALL POD, PO_LINE_LOCATIONS_ARCHIVE_ALL PLL
               WHERE PLL.po_release_id    = p_object_id
               AND   PLL.line_location_id = POD.line_location_id
               AND   PLL.shipment_type in ('SCHEDULED','BLANKET')
               AND   PLL.REVISION_NUM = (SELECT MAX(pll1.revision_num) FROM PO_LINE_LOCATIONS_ARCHIVE_ALL PLL1
                                         WHERE pll1.line_location_id = pll.line_location_id AND
                                               pll1.revision_num <= p_doc_revision)
               AND   POD.REVISION_NUM = (SELECT MAX(pdd1.revision_num) FROM PO_DISTRIBUTIONS_ARCHIVE_ALL PDD1
                                         WHERE pdd1.po_distribution_id = pod.po_distribution_id AND
                                               pdd1.revision_num <= p_doc_revision);

             end if;
           end if;

         end if;
       else
         l_progress := '220';
         --< Bug 3549096 > Use _ALL tables instead of org-striped views.
         SELECT c.minimum_accountable_unit,
                c.precision
         INTO   l_min_unit,
                l_precision
         FROM   FND_CURRENCIES C,
                PO_RELEASES_ALL    POR,
                PO_HEADERS_ALL     PH
         WHERE  POR.po_release_id = p_object_id
         AND    PH.po_header_id   = POR.PO_HEADER_ID
         AND    C.currency_code   = PH.CURRENCY_CODE;

         if l_min_unit is null then

   /* 958792 kbenjami 8/25/99.  Proprogated fix from R11.
      849493 - SVAIDYAN: Do a sum(round()) instead of round(sum()) since what
                         we pass to GL is the round of individual dist. amounts
                         and the sum of these rounded values is what should be
                         displayed as the header total.
   */
           l_progress := '222';
           -- <SERVICES FPJ>
           -- For the new Services lines, quantity will be null.
           -- Hence, added a decode statement to use amount directly
           -- in the total amount calculation when quantity is null.
           select sum(round(
                  decode(pll.quantity,
                         null,
                         (pll.amount - nvl(pll.amount_cancelled,0)),
                         ((pll.quantity - nvl(pll.quantity_cancelled,0)) *
                         nvl(pll.price_override,0))
                        )
                  ,l_precision))
           INTO   l_archive_total_amt
           FROM   PO_LINE_LOCATIONS_ARCHIVE_ALL PLL
           WHERE  PLL.po_release_id   = p_object_id
           AND    PLL.shipment_type  in ( 'SCHEDULED','BLANKET')
           AND   PLL.REVISION_NUM = (SELECT MAX(pll1.revision_num) FROM PO_LINE_LOCATIONS_ARCHIVE_ALL PLL1
                                     WHERE pll1.line_location_id = pll.line_location_id AND
                                           pll1.revision_num <= p_doc_revision);

         else
		   /* Bug 1111926: GMudgal 2/18/2000
		   ** Incorrect placement of brackets caused incorrect rounding
		   ** and consequently incorrect PO header totals
		   */
           l_progress := '224';

           -- <SERVICES FPJ>
           -- For the new Services lines, quantity will be null.
           -- Hence, added a decode statement to use amount directly
           -- in the total amount calculation when quantity is null.
           select sum(round(
                  decode(pll.quantity,
                         null,
                        (pll.amount - nvl(pll.amount_cancelled,0)),
                        ((pll.quantity - nvl(pll.quantity_cancelled,0)) *
                        nvl(pll.price_override,0))
                        )
                  /l_min_unit) *
                  l_min_unit)
           INTO   l_archive_total_amt
           FROM   PO_LINE_LOCATIONS_ARCHIVE_ALL PLL
           WHERE  PLL.po_release_id   = p_object_id
           AND    PLL.shipment_type  in ( 'SCHEDULED','BLANKET')
           AND   PLL.REVISION_NUM = (SELECT MAX(pll1.revision_num) FROM PO_LINE_LOCATIONS_ARCHIVE_ALL PLL1
                                     WHERE pll1.line_location_id = pll.line_location_id AND
                                           pll1.revision_num <= p_doc_revision);

         end if;

       end if;


     end if;
  END IF;-- (p_doc_type = 'PO') AND (p_doc_subtype = 'STANDARD')


  l_progress := '250';
  --If l_archive_total_amt has a null value, return 0 as the total.
  IF l_archive_total_amt IS NULL THEN
	l_archive_total_amt := 0;
  END IF;
  l_progress := '260';
  RETURN(l_archive_total_amt);

EXCEPTION
   WHEN OTHERS THEN
            IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
            THEN
                  fnd_msg_pub.add_exc_msg (g_pkg_name, 'GET_ARCHIVE_TOTAL_FOR_ANY_REV',
                  SUBSTRB (SQLERRM , 1 , 200) || ' at location ' || l_progress);
            END IF;
            RETURN(0);
END get_archive_total_for_any_rev;

--<POC FPJ END>
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
)
RETURN NUMBER
IS
  x_min_unit       NUMBER;
  x_precision      INTEGER;
  x_result_fld     NUMBER;

BEGIN

    SELECT sum(c.minimum_accountable_unit),
           sum(c.precision)
    INTO   x_min_unit,
           x_precision
    FROM   FND_CURRENCIES C,
           PO_HEADERS_ALL     PH,
           PO_LINES_ALL POL
    WHERE  POL.po_line_id   = p_line_id
    AND    PH.po_header_id  = POL.po_header_id
    AND    C.currency_code  = PH.CURRENCY_CODE;

    if x_min_unit is null then
      -- <SERVICES FPJ>
      -- For the new Services lines, quantity will be null.
      -- Hence, added a decode statement to use amount directly
      -- in the total amount calculation when quantity is null.
      --Use _ALL tables instead of org-striped views.
      select sum(round((
             decode(pll.quantity,
                    null,
                    (pll.amount - nvl(pll.amount_cancelled, 0)),
                    (pll.quantity - nvl(pll.quantity_cancelled,0))
                    * nvl(pll.price_override,0)
                   )
             ),x_precision))
      INTO   x_result_fld
      FROM   PO_LINE_LOCATIONS_ALL PLL
      WHERE  PLL.po_line_id   = p_line_id
      AND    PLL.po_release_id  = p_release_id
      AND    PLL.shipment_type  in ( 'STANDARD','BLANKET','PLANNED');

    else
      -- <SERVICES FPJ>
      -- For the new Services lines, quantity will be null.
      -- Hence, added a decode statement to use amount directly
      -- in the total amount calculation when quantity is null.
      -- Use _ALL tables instead of org-striped views.
      select sum(round((
             decode(pll.quantity,
                    null,
                    (pll.amount - nvl(pll.amount_cancelled,0)),
                    (pll.quantity - nvl(pll.quantity_cancelled,0))
                    * nvl(pll.price_override,0)
                   )
             / x_min_unit) * x_min_unit))
      INTO   x_result_fld
      FROM   PO_LINE_LOCATIONS_ALL PLL
      WHERE  PLL.po_line_id   = p_line_id
      AND    PLL.po_release_id   = p_release_id
      AND    PLL.shipment_type  in ( 'STANDARD','BLANKET','PLANNED');

    end if;
    return(x_result_fld);
END GET_RELEASE_LINE_TOTAL;

/*===================================================================================

    FUNCTION:    get_ga_amount_released                  <GA FPI>

    DESCRIPTION: Gets the total Amount Released for a particular Global Agreement.
                 That is, sum up the total for all uncancelled Standard PO lines
                 which reference that Global Agreement.

===================================================================================*/
FUNCTION get_ga_amount_released
(
    p_po_header_id             PO_HEADERS_ALL.po_header_id%TYPE,
    p_convert_to_base          BOOLEAN := FALSE
)
RETURN NUMBER
IS
    l_base_currency            FND_CURRENCIES.currency_code%TYPE;
    l_base_precision           FND_CURRENCIES.precision%TYPE;
    l_base_ext_precision       FND_CURRENCIES.extended_precision%TYPE;
    l_base_min_unit            FND_CURRENCIES.minimum_accountable_unit%TYPE;

    l_po_currency              FND_CURRENCIES.currency_code%TYPE;
    l_po_precision             FND_CURRENCIES.precision%TYPE;
    l_po_ext_precision         FND_CURRENCIES.extended_precision%TYPE;
    l_po_min_unit              FND_CURRENCIES.minimum_accountable_unit%TYPE;

    l_rate                     PO_HEADERS_ALL.rate%TYPE;

    x_total                    NUMBER;

BEGIN

    -- Get the functional currency code for the current org's Set of Books
    -- and the currency code defined for the PO
    PO_CORE_S2.get_po_currency( p_po_header_id,               -- IN
                                l_base_currency,              --OUT
                                l_po_currency );              --OUT

    -- Get the Precision (never NULL), Extended Precision, Minimum Accountable Unit
    -- for the Set of Books' currency code...
    FND_CURRENCY.get_info( l_base_currency,                   -- IN
                           l_base_precision,                  --OUT
                           l_base_ext_precision,              --OUT
                           l_base_min_unit );                 --OUT

    -- and for the PO's currency code...
    FND_CURRENCY.get_info( l_po_currency,                     -- IN
                           l_po_precision,                    --OUT
                           l_po_ext_precision,                --OUT
                           l_po_min_unit );                   --OUT

    -- NOTE: All Standard PO's must have the same currency code as the
    -- Global Agreement that they reference. The currency conversion rate used
    -- will be the rate between the Global Agreement's currency and the owning
    -- org's currency.

    IF  (   ( p_convert_to_base )               -- convert back to base currency
        AND ( l_base_currency <> l_po_currency ) ) THEN

        -- Get the rate from PO_HEADERS_ALL for the Global Agreement.
        SELECT     rate
        INTO       l_rate
        FROM       po_headers_all
        WHERE      po_header_id = p_po_header_id;

        IF ( l_base_min_unit IS NOT NULL ) THEN

            IF ( l_po_min_unit IS NOT NULL ) THEN

   /*Bug11802312 - Exclude the records with consigned flag Y while calculating the amount released
   After this fix, document reference is retained and hence from header id and from line id will
   be populated.Added AND Nvl(poll.consigned_flag,'N') <> 'Y'; to exclude the consigned shipments*/

	      -- <SERVICES FPJ>
              -- For the new Services lines, quantity will be null.
              -- Hence, added a decode statement to use amount directly
              -- in the total amount calculation when quantity is null.
	      --<BUG 10060275 Modified below sql to reduce performance issues>
	      SELECT    sum ( round (  ( round (  (  ( decode(poll.quantity, null,
		                                       (poll.amount -
		                                       poll.amount_cancelled),
		                                       (( poll.quantity
                                                       - poll.quantity_cancelled )
		                                       * nvl(poll.price_override,0))
							     )
					             )
                                                    * l_rate )
                                                 / l_po_min_unit )
                                         * l_po_min_unit )
                                      / l_base_min_unit )
                              * l_base_min_unit )
                INTO      x_total
                FROM      po_line_locations_all   poll,
                          po_lines_all            pol
                WHERE     poll.po_line_id = pol.po_line_id
                AND       pol.from_header_id = p_po_header_id
		AND       Nvl(poll.consigned_flag,'N') <> 'Y';

            ELSE          -- ( l_po_min_unit IS NULL )

	       -- <SERVICES FPJ>
               -- For the new Services lines, quantity will be null.
               -- Hence, added a decode statement to use amount directly
               -- in the total amount calculation when quantity is null.
	       --<BUG 10060275 Modified below sql to reduce performance issues>
	       SELECT    sum ( round (  (  (decode(poll.quantity, null,
		                                   (poll.amount -
		                                   poll.amount_cancelled),
		                                   (( poll.quantity
                                                   - poll.quantity_cancelled )
		                                   * nvl(poll.price_override,0))
						  )
					   )
                                         * l_rate )
                                      / l_base_min_unit )
                              * l_base_min_unit )
                INTO      x_total
                FROM      po_line_locations_all   poll,
                          po_lines_all            pol
                WHERE     poll.po_line_id = pol.po_line_id
                AND       pol.from_header_id = p_po_header_id
		AND       Nvl(poll.consigned_flag,'N') <> 'Y';

            END IF;

        ELSE              -- ( l_base_min_unit IS NULL )

            IF ( l_po_min_unit IS NOT NULL ) THEN

               -- <SERVICES FPJ>
               -- For the new Services lines, quantity will be null.
               -- Hence, added a decode statement to use amount directly
               -- in the total amount calculation when quantity is null.
	       --<BUG 10060275 Modified below sql to reduce performance issues>
	       SELECT    sum ( round (  (  (decode(poll.quantity, null,
		                                   (poll.amount -
		                                   poll.amount_cancelled),
		                                   (( poll.quantity
                                                   - poll.quantity_cancelled )
		                                   * nvl(poll.price_override,0))
					          )
					   )
                                         * l_rate )
                                      / l_po_min_unit )
                              * l_po_min_unit )
                INTO      x_total
                FROM      po_line_locations_all   poll,
                          po_lines_all            pol
                WHERE     poll.po_line_id = pol.po_line_id
                AND       pol.from_header_id = p_po_header_id
		AND       Nvl(poll.consigned_flag,'N') <> 'Y';

            ELSE          -- ( l_po_min_unit IS NULL )

               -- <SERVICES FPJ>
               -- For the new Services lines, quantity will be null.
               -- Hence, added a decode statement to use amount directly
               -- in the total amount calculation when quantity is null.
	       --<BUG 10060275 Modified below sql to reduce performance issues>
	       SELECT    sum (  (decode(poll.quantity, null,
		                        (poll.amount -
		                        poll.amount_cancelled),
	                                (( poll.quantity
                                        - poll.quantity_cancelled )
		                        * nvl(poll.price_override,0))
                                       )
				)
                              * l_rate )
                INTO      x_total
                FROM      po_line_locations_all   poll,
                          po_lines_all            pol
                WHERE     poll.po_line_id = pol.po_line_id
                AND       pol.from_header_id = p_po_header_id
		AND       Nvl(poll.consigned_flag,'N') <> 'Y';

            END IF;

        END IF;

    ELSE                  -- just get po_currency (no conversion necessary)

        IF ( l_po_min_unit IS NOT NULL ) THEN

	   -- <SERVICES FPJ>
           -- For the new Services lines, quantity will be null.
           -- Hence, added a decode statement to use amount directly
           -- in the total amount calculation when quantity is null.
	   --<BUG 10060275 Modified below sql to reduce performance issues>
	   SELECT    sum ( round (  (decode(poll.quantity, null,
                                            (poll.amount -
                                            poll.amount_cancelled),
                                            (( poll.quantity
                                            - poll.quantity_cancelled )
                                            * nvl(poll.price_override,0))
                                           )
				     )
                                  / l_po_min_unit )
                          * l_po_min_unit )
            INTO      x_total
            FROM      po_line_locations_all   poll,
                      po_lines_all            pol
            WHERE     poll.po_line_id = pol.po_line_id
            AND       pol.from_header_id = p_po_header_id
	    AND       Nvl(poll.consigned_flag,'N') <> 'Y';

        ELSE              -- ( l_po_min_unit IS NULL )

           -- <SERVICES FPJ>
           -- For the new Services lines, quantity will be null.
           -- Hence, added a decode statement to use amount directly
           -- in the total amount calculation when quantity is null.
	   --<BUG 10060275 Modified below sql to reduce performance issues>
	   SELECT    sum (decode(poll.quantity, null,
                                 (poll.amount -
                                 poll.amount_cancelled),
		                 (( poll.quantity
                                 - poll.quantity_cancelled )
		                 * nvl(poll.price_override,0))
			        )
			 )
            INTO      x_total
            FROM      po_line_locations_all   poll,
                      po_lines_all            pol
            WHERE     poll.po_line_id = pol.po_line_id
            AND       pol.from_header_id = p_po_header_id
	    AND       Nvl(poll.consigned_flag,'N') <> 'Y';


        END IF;

    END IF;

    return(x_total);

EXCEPTION
    WHEN OTHERS THEN
        return(0);

END get_ga_amount_released;


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
)
IS
    l_base_currency            FND_CURRENCIES.currency_code%TYPE;

    l_po_currency              FND_CURRENCIES.currency_code%TYPE;
    l_po_precision             FND_CURRENCIES.precision%TYPE;
    l_po_ext_precision         FND_CURRENCIES.extended_precision%TYPE;
    l_po_min_unit              FND_CURRENCIES.minimum_accountable_unit%TYPE;

    l_rate                     PO_HEADERS_ALL.rate%TYPE;

BEGIN

 /*Bug11802312 - Exclude the records with consigned flag Y while calculating the amount released
   After this fix, document reference is retained and hence from header id and from line id will
   be populated.Added AND Nvl(poll.consigned_flag,'N') <> 'Y'; to exclude the consigned shipments*/

    -- Get the currency code defined for the PO
    PO_CORE_S2.get_po_currency( p_po_header_id,               -- IN
                                l_base_currency,              --OUT
                                l_po_currency );              --OUT

    -- Get the Precision (never NULL), Extended Precision, Minimum Accountable Unit
    -- for the PO's currency code...
    FND_CURRENCY.get_info( l_po_currency,                     -- IN
                           l_po_precision,                    --OUT
                           l_po_ext_precision,                --OUT
                           l_po_min_unit );                   --OUT

    IF ( l_po_min_unit IS NOT NULL ) THEN

       -- <SERVICES FPJ>
       -- For the new Services lines, quantity will be null.
       -- Hence, added a decode statement to use amount directly
       -- in the total amount calculation when quantity is null.
       SELECT    sum ( round (  (decode(pol.quantity, null,
		                        (pod.amount_ordered -
		                        pod.amount_cancelled),
		                        (( pod.quantity_ordered
                                        - pod.quantity_cancelled )
		                        * poll.price_override))
                                       )
                              / l_po_min_unit )
                      * l_po_min_unit ),
                  sum ( pod.quantity_ordered - pod.quantity_cancelled )
        INTO      x_amount_released,
                  x_quantity_released
        FROM      po_distributions_all    pod,
                  po_line_locations_all   poll,
                  po_lines_all            pol
        WHERE     pod.line_location_id = poll.line_location_id
        AND       poll.po_line_id = pol.po_line_id
        AND       pol.from_line_id = p_po_line_id
	AND       Nvl(poll.consigned_flag,'N') <> 'Y';

    ELSE              -- ( l_po_min_unit IS NULL )

       -- <SERVICES FPJ>
       -- For the new Services lines, quantity will be null.
       -- Hence, added a decode statement to use amount directly
       -- in the total amount calculation when quantity is null.
       SELECT    sum (decode(pol.quantity, null,
		             (pod.amount_ordered -
                             pod.amount_cancelled),
		             (( pod.quantity_ordered
                             - pod.quantity_cancelled )
		             * poll.price_override)
			    )
		     ),
                  sum ( pod.quantity_ordered - pod.quantity_cancelled )
        INTO      x_amount_released,
                  x_quantity_released
        FROM      po_distributions_all    pod,
                  po_line_locations_all   poll,
                  po_lines_all            pol
        WHERE     pod.line_location_id = poll.line_location_id
        AND       poll.po_line_id = pol.po_line_id
        AND       pol.from_line_id = p_po_line_id
	AND       Nvl(poll.consigned_flag,'N') <> 'Y';

    END IF;

END get_ga_line_amount_released;


-- <GC FPJ START>
/**=========================================================================
* Function: get_gc_amount_released
* Effects:  Calculate amount released given a global contract
* Requires: None
* Modifies: None
* Return:   amount released. Whether the amount is converted to base currency
*           is determined by p_convert_to_base
=========================================================================**/

FUNCTION get_gc_amount_released
(
    p_po_header_id         IN NUMBER,
    p_convert_to_base      IN BOOLEAN := FALSE
) RETURN NUMBER
IS

l_base_currency   FND_CURRENCIES.currency_code%TYPE;
l_base_precision  FND_CURRENCIES.precision%TYPE;
l_base_min_unit   FND_CURRENCIES.minimum_accountable_unit%TYPE;

l_po_currency     FND_CURRENCIES.currency_code%TYPE;
l_po_precision    FND_CURRENCIES.precision%TYPE;
l_po_min_unit     FND_CURRENCIES.minimum_accountable_unit%TYPE;

l_rate            PO_HEADERS_ALL.rate%TYPE;
l_total           NUMBER;

l_log_head     CONSTANT VARCHAR2(100) := g_log_head||'GET_GC_AMOUNT_RELEASED';
l_progress     VARCHAR2(3) := '000';

BEGIN
    IF g_debug_stmt THEN
         PO_DEBUG.debug_begin(l_log_head);
    END IF;

    l_progress := '010';

    PO_CORE_S2.get_po_currency ( x_object_id     => p_po_header_id,
                                 x_base_currency => l_base_currency,
                                 x_po_currency   => l_po_currency     );

    PO_CORE_S2.get_currency_info ( x_currency_code => l_base_currency,
                                   x_precision     => l_base_precision,
                                   x_min_unit      => l_base_min_unit  );

    PO_CORE_S2.get_currency_info ( x_currency_code => l_po_currency,
                                   x_precision     => l_po_precision,
                                   x_min_unit      => l_po_min_unit  );

    --Bug# 5391346 START:
    --Added the following to queries below as was coded in the local contract case (refer bug# 716188)
    --1. Where clause POLL.shipment_type in ('STANDARD','PLANNED')
    --2. Outer Join POD.line_location_id(+) = POLL.line_location_id instead of simple join
    --3. Proper rate conversions taking into account different currencies of GCPA and SPOs sourced to it.



    IF ( p_convert_to_base AND
         l_base_currency <> l_po_currency ) THEN

      --Bug# 5391346: Removed the query to get l_rate from GCPA header
      --as we now use rate on the PO header to convert it to base currency.

      l_progress := '020';

        IF (l_base_min_unit IS NOT NULL) THEN

          l_progress := '030';

            IF (l_po_min_unit IS NOT NULL) THEN
   /*Bug11802312 - Exclude the records with consigned flag Y while calculating the amount released
   After this fix, document reference is retained and hence from header id and from line id will
   be populated.Added AND Nvl(poll.consigned_flag,'N') <> 'Y'; to exclude the consigned shipments*/

                -- SQL What: calculate amount released from all lines across OU
                --           referencing this GC, with the amount being
                --           converted to base currency
                -- SQL Why:  This is the return value
                --<Complex Work R12>: added decode on value basis

                --Bug# 5391346: Added Decode for currency match condition
                --Also added a join with PO_HEADERS_ALL for rate in header of execution document
		--<BUG 10060275 Modified below sql to reduce performance issues>
               l_progress := '040';

               SELECT  NVL(
                       SUM(
                        DECODE(l_base_currency, PH1.currency_code,
                                ROUND(
                                  ROUND(
                                        DECODE(POLL.value_basis
                                        ,'FIXED PRICE',
                                         NVL(POD.AMOUNT_ORDERED, 0) -
                                         NVL(POD.amount_cancelled, 0)
                                        , 'RATE',
                                         NVL(POD.AMOUNT_ORDERED, 0)-
                                         NVL(POD.amount_cancelled, 0)
                                        , --Qty based
                                        (NVL(POD.QUANTITY_ORDERED, 0) -
                                         NVL(POD.quantity_cancelled,0)
                                         ) * NVL(POLL.price_override, 0)
                                              )
                                        /l_po_min_unit)*l_po_min_unit
                                       /l_base_min_unit)*l_base_min_unit
                              ,


                                ROUND(
                                  ROUND(
                                         DECODE(POLL.value_basis
                                          ,'FIXED PRICE',
                                           NVL(POD.AMOUNT_ORDERED, 0) -
                                           NVL(POD.amount_cancelled, 0)
                                          , 'RATE',
                                           NVL(POD.AMOUNT_ORDERED, 0)-
                                           NVL(POD.amount_cancelled, 0)
                                          , --Qty based
                                          (NVL(POD.QUANTITY_ORDERED, 0) -
                                           NVL(POD.quantity_cancelled,0)
                                           ) * NVL(POLL.price_override, 0)
                                               )
                                      /l_po_min_unit)*l_po_min_unit
                                      * NVL(POD.rate, NVL(PH1.rate,1))
                                    /l_base_min_unit) * l_base_min_unit
                                )
                               )
                            ,0)
              INTO   l_total
              FROM   PO_DISTRIBUTIONS_ALL POD,
                     PO_LINE_LOCATIONS_ALL POLL,
                     PO_LINES_ALL POL,
                     PO_HEADERS_ALL PH1
              WHERE  POL.contract_id = p_po_header_id
              AND    POL.po_line_id        = POLL.po_line_id
              AND    POLL.shipment_type in ('STANDARD','PLANNED')
              AND    POD.line_location_id = POLL.line_location_id  --bug 12572504
              AND    PH1.po_header_id = POL.po_header_id
	            AND    Nvl(poll.consigned_flag,'N') <> 'Y';

            ELSE                  -- (l_po_min_unit is null)

                -- SQL What: calculate amount released from all lines across OU
                --           referencing this GC, with the amount being
                --           converted to base currency
                -- SQL Why:  This is the return value
                --<Complex Work R12>: added decode on value basis

                --Bug# 5391346: Added Decode for currency match condition
                --Use PO precision (ie Contract currency precision) when l_po_min_unit is null (PO implies the Contract here)
                --Also added a join with PO_HEADERS_ALL for rate in header of execution document
		--<BUG 10060275 Modified below sql to reduce performance issues>
              l_progress := '050';

              SELECT NVL(
                     SUM(
                        DECODE(l_base_currency, PH1.currency_code,
                               ROUND(
                                 ROUND(
                                    DECODE(POLL.value_basis
                                    ,'FIXED PRICE',
                                     NVL(POD.AMOUNT_ORDERED, 0) -
                                     NVL(POD.amount_cancelled, 0)
                                    , 'RATE',
                                     NVL(POD.AMOUNT_ORDERED, 0)-
                                     NVL(POD.amount_cancelled, 0)
                                    , --Qty based
                                    (NVL(POD.QUANTITY_ORDERED, 0) -
                                     NVL(POD.quantity_cancelled,0)
                                     ) * NVL(POLL.price_override, 0)
                                          )
                                    ,l_po_precision)
                                   /l_base_min_unit)*l_base_min_unit
                              ,


                                  ROUND(
                                    ROUND(
                                         DECODE(POLL.value_basis
                                          ,'FIXED PRICE',
                                           NVL(POD.AMOUNT_ORDERED, 0) -
                                           NVL(POD.amount_cancelled, 0)
                                          , 'RATE',
                                           NVL(POD.AMOUNT_ORDERED, 0)-
                                           NVL(POD.amount_cancelled, 0)
                                          , --Qty based
                                          (NVL(POD.QUANTITY_ORDERED, 0) -
                                           NVL(POD.quantity_cancelled,0)
                                           ) * NVL(POLL.price_override, 0)
                                            ) * NVL(POD.rate, NVL(PH1.rate,1))
                                      ,l_po_precision)
                                    /l_base_min_unit) * l_base_min_unit
                                )
                               )
                            ,0)
              INTO   l_total
              FROM   PO_DISTRIBUTIONS_ALL POD,
                     PO_LINE_LOCATIONS_ALL POLL,
                     PO_LINES_ALL POL,
                     PO_HEADERS_ALL PH1
              WHERE POL.contract_id = p_po_header_id
              AND    POL.po_line_id        = POLL.po_line_id
              AND    POLL.shipment_type in ('STANDARD','PLANNED')
              AND    POD.line_location_id = POLL.line_location_id  --bug 12572504
              AND    PH1.po_header_id = POL.po_header_id
	            AND    Nvl(poll.consigned_flag,'N') <> 'Y';
            END IF;

        ELSE                     -- (l_base_min_unit IS NULL)
            l_progress := '060';

            IF (l_po_min_unit IS NOT NULL) THEN

                -- SQL What: calculate amount released from all lines across OU
                --           referencing this GC, with the amount being
                --           converted to base currency
                -- SQL Why:  This is the return value
                --<Complex Work R12>: added decode on value basis

                --Bug# 5391346: Added Decode for currency match condition
                --use only PO min unit and not PO precision when l_po_min_unit is not null (PO implies the Contract here)
                --Also added a join with PO_HEADERS_ALL for rate in header of execution document
                --<BUG 10060275 Modified below sql to reduce performance issues>
              l_progress := '070';

              SELECT  NVL(
                       SUM(
                         DECODE(l_base_currency, PH1.currency_code,
                                 ROUND(
                                  ROUND(
                                     DECODE(POLL.value_basis
                                        ,'FIXED PRICE',
                                         NVL(POD.amount_ordered, 0) -
                                         NVL(POD.amount_cancelled, 0)
                                        , 'RATE',
                                         NVL(POD.amount_ordered, 0)-
                                         NVL(POD.amount_cancelled, 0)
                                        , --Qty based
                                        (NVL(POD.quantity_ordered, 0) -
                                         NVL(POD.quantity_cancelled,0)
                                         ) * NVL(POLL.price_override, 0)
                                        )
                                     /l_po_min_unit) * l_po_min_unit
                                    , l_base_precision),
                                  ROUND(
                                    ROUND(
                                     DECODE(POLL.value_basis
                                          ,'FIXED PRICE',
                                           NVL(POD.amount_ordered, 0) -
                                           NVL(POD.amount_cancelled, 0)
                                          , 'RATE',
                                           NVL(POD.amount_ordered, 0)-
                                           NVL(POD.amount_cancelled, 0)
                                          , --Qty based
                                          (NVL(POD.quantity_ordered, 0) -
                                           NVL(POD.quantity_cancelled,0)
                                           ) * NVL(POLL.price_override, 0)
                                          )* NVL(POD.rate, NVL(PH1.rate,1)
                                          )
                                       /l_po_min_unit) * l_po_min_unit
                                    , l_base_precision)
                                  )
                             ),0)
                INTO   l_total
                FROM   PO_DISTRIBUTIONS_ALL POD,
                       PO_LINE_LOCATIONS_ALL POLL,
                       PO_LINES_ALL PoL,
                       PO_HEADERS_ALL PH1
                WHERE   POL.contract_id = p_po_header_id
                AND    POL.po_line_id        = POLL.po_line_id
                AND    POLL.shipment_type in ('STANDARD','PLANNED')
                AND    POD.line_location_id = POLL.line_location_id   --bug 12572504
                AND    PH1.po_header_id = POL.po_header_id
		            AND    Nvl(poll.consigned_flag,'N') <> 'Y';

            ELSE                -- (l_po_min_unit IS NULL)

                -- SQL What: calculate amount released from all lines across OU
                --           referencing this GC, with the amount being
                --           converted to base currency
                -- SQL Why:  This is the return value
                --<Complex Work R12>: added decode on value basis

                --Bug# 5391346: Added Decode for currency match condition
                --use PO precision when PO currency min unit is null
                --Also added a join with PO_HEADERS_ALL for rate in header of execution document
		--<BUG 10060275 Modified below sql to reduce performance issues>
              l_progress := '080';

              SELECT  NVL(
                       SUM(
                         DECODE(l_base_currency, PH1.currency_code,
                                 ROUND(
                                  ROUND(
                                     DECODE(POLL.value_basis
                                        ,'FIXED PRICE',
                                         NVL(POD.amount_ordered, 0) -
                                         NVL(POD.amount_cancelled, 0)
                                        , 'RATE',
                                         NVL(POD.amount_ordered, 0)-
                                         NVL(POD.amount_cancelled, 0)
                                        , --Qty based
                                        (NVL(POD.quantity_ordered, 0) -
                                         NVL(POD.quantity_cancelled,0)
                                         ) * NVL(POLL.price_override, 0)
                                        )
                                     ,l_po_precision)
                                    , l_base_precision),
                                  ROUND(
                                    ROUND(
                                     DECODE(POLL.value_basis
                                          ,'FIXED PRICE',
                                           NVL(POD.amount_ordered, 0) -
                                           NVL(POD.amount_cancelled, 0)
                                          , 'RATE',
                                           NVL(POD.amount_ordered, 0)-
                                           NVL(POD.amount_cancelled, 0)
                                          , --Qty based
                                          (NVL(POD.quantity_ordered, 0) -
                                           NVL(POD.quantity_cancelled,0)
                                           ) * NVL(POLL.price_override, 0)
                                          )* NVL(POD.rate, NVL(PH1.rate,1)
                                          )
                                       ,l_po_precision)
                                    , l_base_precision)
                                  )
                             ),0)
                INTO   l_total
                FROM   PO_DISTRIBUTIONS_ALL POD,
                       PO_LINE_LOCATIONS_ALL POLL,
                       PO_LINES_ALL POL,
                       PO_HEADERS_ALL PH1
                WHERE   POL.contract_id = p_po_header_id
                AND    POL.po_line_id        = POLL.po_line_id
                AND    POLL.shipment_type in ('STANDARD','PLANNED')
                AND    POD.line_location_id = POLL.line_location_id  --bug 12572504
                AND    PH1.po_header_id = POL.po_header_id
		            AND    Nvl(poll.consigned_flag,'N') <> 'Y';

            END IF;

        END IF;

    ELSE                   -- (no base currency conversion)

        l_progress := '090';

        IF (l_po_min_unit IS NOT NULL) THEN

            -- SQL What: calculate amount released from all lines across OU
            --           referencing this GC in GC currency
            -- SQL Why:  This is the return value
            --<Complex Work R12>: added decode on value basis

            --Bug# 5391346: Added Decode for currency match condition
            --Also added a join with PO_HEADERS_ALL for rate in header of execution document
	    --<BUG 10060275 Modified below sql to reduce performance issues>
          l_progress := '100';

          SELECT /*+ use_nl(POLL,POD,PH1) index(POLL PO_LINE_LOCATIONS_N1) index(PH1 PO_HEADERS_U1) */ NVL(
                    SUM(
                       DECODE(PH.currency_code, PH1.currency_code,
                                ROUND (
                                        DECODE(POLL.value_basis
                                            ,'FIXED PRICE',
                                             NVL(POD.amount_ordered, 0) -
                                             NVL(POD.amount_cancelled, 0)
                                            , 'RATE',
                                             NVL(POD.amount_ordered, 0)-
                                             NVL(POD.amount_cancelled, 0)
                                            , --Qty based
                                            (NVL(POD.quantity_ordered, 0) -
                                             NVL(POD.quantity_cancelled,0)
                                             ) * NVL(POLL.price_override, 0)
                                              )
                                       /l_po_min_unit)* l_po_min_unit
                                          ,

                                ROUND(
                                        DECODE(POLL.value_basis
                                            ,'FIXED PRICE',
                                             NVL(POD.amount_ordered, 0) -
                                             NVL(POD.amount_cancelled, 0)
                                            , 'RATE',
                                             NVL(POD.amount_ordered, 0)-
                                             NVL(POD.amount_cancelled, 0)
                                            , --Qty based
                                            (NVL(POD.quantity_ordered, 0) -
                                             NVL(POD.quantity_cancelled,0)
                                             ) * NVL(POLL.price_override, 0)
                                            )* NVL(POD.rate, NVL(PH1.rate,1))
                                            /NVL(PH.rate,1)
                                       /l_po_min_unit)* l_po_min_unit

                           )
                        )
                     ,0)
           INTO   l_total
           FROM   PO_DISTRIBUTIONS_ALL POD,
                  PO_LINE_LOCATIONS_ALL POLL,
                  PO_LINES_ALL POL,
                  PO_HEADERS_ALL PH,
                  PO_HEADERS_ALL PH1
           WHERE  PH.po_header_id      = p_po_header_id
           AND    PH.po_header_id      = POL.contract_id
           AND    POL.po_line_id        = POLL.po_line_id
           AND    POLL.shipment_type in ('STANDARD','PLANNED')
           AND    POD.line_location_id = POLL.line_location_id  --bug 12572504
           AND    PH1.po_header_id = POL.po_header_id
	         AND    Nvl(poll.consigned_flag,'N') <> 'Y';

        ELSE               -- (l_po_min unit IS NULL)

            -- SQL What: calculate amount released from all lines across OU
            --           referencing this GC in GC currency
            -- SQL Why:  This is the return value
            --<Complex Work R12>: added decode on value basis

            --Bug# 5391346: Added Decode for currency match condition
            --Also added a join with PO_HEADERS_ALL for rate in header of execution document
            --<BUG 10060275 Modified below sql to reduce performance issues>
          l_progress := '110';

          SELECT /*+ use_nl(POLL,POD,PH1) index(POLL PO_LINE_LOCATIONS_N1) index(PH1 PO_HEADERS_U1) */ NVL(
                    SUM(

                             DECODE(PH.currency_code, PH1.currency_code,
                                 ROUND(
                                     DECODE(POLL.value_basis
                                            ,'FIXED PRICE',
                                             NVL(POD.amount_ordered, 0) -
                                             NVL(POD.amount_cancelled, 0)
                                            , 'RATE',
                                             NVL(POD.amount_ordered, 0)-
                                             NVL(POD.amount_cancelled, 0)
                                            , --Qty based
                                            (NVL(POD.quantity_ordered, 0) -
                                             NVL(POD.quantity_cancelled,0)
                                             ) * NVL(POLL.price_override, 0)
                                              )


                                  , l_po_precision ) ,

                                  ROUND(
                                     DECODE(POLL.value_basis
                                            ,'FIXED PRICE',
                                             NVL(POD.amount_ordered, 0) -
                                             NVL(POD.amount_cancelled, 0)
                                            , 'RATE',
                                             NVL(POD.amount_ordered, 0)-
                                             NVL(POD.amount_cancelled, 0)
                                            , --Qty based
                                            (NVL(POD.quantity_ordered, 0) -
                                             NVL(POD.quantity_cancelled,0)
                                             ) * NVL(POLL.price_override, 0)
                                            )

                                          * NVL(POD.rate, NVL(PH1.rate,1))
                                          /NVL(PH.rate,1)

                                 , l_po_precision)
                            )
                        )
                     ,0)
         INTO   l_total
         FROM   PO_DISTRIBUTIONS_ALL POD,
                PO_LINE_LOCATIONS_ALL POLL,
                PO_LINES_ALL POL,
                PO_HEADERS_ALL PH,
                PO_HEADERS_ALL PH1
         WHERE  PH.po_header_id      = p_po_header_id
         AND    PH.po_header_id      = POL.contract_id         -- <GC FPJ>
         AND    POL.po_line_id        = POLL.po_line_id
         AND    POLL.shipment_type in ('STANDARD','PLANNED')
         AND    POD.line_location_id = POLL.line_location_id  --bug 12572504
         AND    PH1.po_header_id = POL.po_header_id
	       AND    Nvl(poll.consigned_flag,'N') <> 'Y';

        END IF;

    END IF;

  IF g_debug_stmt THEN
     PO_DEBUG.debug_end(l_log_head);
  END IF;

  --Bug# 5391346 END

  RETURN l_total;

EXCEPTION
    WHEN OTHERS THEN
        PO_DEBUG.debug_exc(l_log_head,l_progress);
        RETURN 0;
END get_gc_amount_released;

-- <GC FPJ END>

/* ===========================================================================
  PROCEDURE NAME : validate_lookup_info (
                   p_lookup_rec IN OUT NOCOPY RCV_SHIPMENT_HEADER_SV.LookupRecType)

  DESCRIPTION    :

  CLIENT/SERVER  : SERVER

  LIBRARY NAME   :

  OWNER          : Raj Bhakta

  PARAMETERS     : p_lookup_rec IN OUT NOCOPY RCV_SHIPMENT_HEADER_SV.LookupRecType

  ALGORITHM      :

  NOTES          : Generic procedure which accepts the lookup record and
                   returns error status and error message depending on
                   business rules. The lookup record has type and code as
                   components.

  CHANGE HISTORY : Raj Bhakta 10/30/96 created

=========================================================================== */

 PROCEDURE validate_lookup_info(
          p_lookup_rec IN OUT NOCOPY RCV_SHIPMENT_HEADER_SV.LookupRecType) IS


 cursor C is
   SELECT inactive_date
   FROM po_lookup_codes
   WHERE
       lookup_type = p_lookup_rec.lookup_type and
       lookup_code = p_lookup_rec.lookup_code;

 X_sysdate Date := sysdate;

 X_inactive_date   po_lookup_codes.INACTIVE_DATE%TYPE;

 BEGIN

   OPEN C;
   FETCH C INTO X_inactive_date;

   IF C%ROWCOUNT = 0 then
      CLOSE C;
      p_lookup_rec.error_record.error_status := 'E';
      p_lookup_rec.error_record.error_message := 'INVALID_LOOKUP';
      RETURN;

   ELSE

      IF X_sysdate > nvl(X_inactive_date,X_sysdate + 1) THEN

           CLOSE C;
           p_lookup_rec.error_record.error_status := 'E';
           p_lookup_rec.error_record.error_message := 'INACTIVE_LOOKUP';
           RETURN;
      END IF;

      LOOP
        FETCH C INTO X_inactive_date;
        IF C%NOTFOUND THEN

           p_lookup_rec.error_record.error_status := 'S';
           p_lookup_rec.error_record.error_message := NULL;
           EXIT;

        END IF;
        IF C%FOUND THEN

           p_lookup_rec.error_record.error_status := 'E';
           p_lookup_rec.error_record.error_message := 'TOOMANYROWS';
           CLOSE C;
           EXIT;

        END IF;

       END LOOP;

   END IF;

 EXCEPTION
    WHEN others THEN
           p_lookup_rec.error_record.error_status := 'U';
           p_lookup_rec.error_record.error_message := sqlerrm;

 END validate_lookup_info;





-------------------------------------------
-- Document id helper procedures
-------------------------------------------




-------------------------------------------------------------------------------
--Start of Comments
--Name: get_document_ids
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Returns the header-level document id for the given ids.
--Parameters:
--IN:
--p_doc_type
--  Document type.  Use the g_doc_type_<> variables, where <> is:
--    REQUISITION
--    PA
--    PO
--    RELEASE
--p_doc_level
--  The type of ids that are being passed.  Use g_doc_level_<>
--    HEADER
--    LINE
--    SHIPMENT
--    DISTRIBUTION
--p_doc_level_id_tbl
--  Ids of the doc level type of which to derive the document header id.
--OUT:
--x_doc_id_tbl
--  Header-level ids of the input ids.
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE get_document_ids(
   p_doc_type                       IN             VARCHAR2
,  p_doc_level                      IN             VARCHAR2
,  p_doc_level_id_tbl               IN             po_tbl_number
,  x_doc_id_tbl                     OUT NOCOPY     po_tbl_number
)
IS

l_log_head     CONSTANT VARCHAR2(100) := g_log_head||'GET_DOCUMENT_IDS';
l_progress     VARCHAR2(3) := '000';

l_id_key    NUMBER;

-- Bug 3292870
l_rowid_char_tbl    g_rowid_char_tbl;

BEGIN

IF g_debug_stmt THEN
   PO_DEBUG.debug_begin(l_log_head);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_type', p_doc_type);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_level', p_doc_level);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_level_id_tbl', p_doc_level_id_tbl);
END IF;

l_progress := '010';

IF (p_doc_level = g_doc_level_HEADER) THEN

   l_progress := '020';
   IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(l_log_head,l_progress,'headers');
   END IF;

   x_doc_id_tbl := p_doc_level_id_tbl;

ELSE

   l_progress := '100';
   IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(l_log_head,l_progress,'not headers');
   END IF;

   -- We need to get outthe header ids in the same ordering as the
   -- input id table.
   -- We can't do a FORALL ... SELECT (PL/SQL limitation),
   -- but we can to a FORALL ... INSERT ... RETURNING.

   ----------------------------------------------------------------
   -- PO_SESSION_GT column mapping
   --
   -- num1     doc level id
   -- num2     header id of num1
   ----------------------------------------------------------------

   l_id_key := get_session_gt_nextval();

   l_progress := '110';

   IF (p_doc_type = g_doc_type_REQUISITION) THEN

      l_progress := '120';
      IF g_debug_stmt THEN
         PO_DEBUG.debug_stmt(l_log_head,l_progress,'requisition');
      END IF;

      IF (p_doc_level = g_doc_level_LINE) THEN

         l_progress := '130';
         IF g_debug_stmt THEN
            PO_DEBUG.debug_stmt(l_log_head,l_progress,'line');
         END IF;

         /* Start Bug 3292870: Split query to make it compatible with 8i db. */

         FORALL i IN 1 .. p_doc_level_id_tbl.COUNT
         INSERT INTO PO_SESSION_GT ( key, num1 )
         VALUES
         (  l_id_key
         ,  p_doc_level_id_tbl(i)
         )
         RETURNING ROWIDTOCHAR(rowid)
         BULK COLLECT INTO l_rowid_char_tbl
         ;

         FORALL i IN 1 .. p_doc_level_id_tbl.COUNT
         UPDATE PO_SESSION_GT
         SET num2 =
            (
               SELECT PRL.requisition_header_id
               FROM PO_REQUISITION_LINES_ALL PRL
               WHERE PRL.requisition_line_id = p_doc_level_id_tbl(i)
            )
         WHERE rowid = CHARTOROWID(l_rowid_char_tbl(i))
         RETURNING num2
         BULK COLLECT INTO x_doc_id_tbl
         ;

         /* End Bug 3292870 */

         l_progress := '140';

      ELSIF (p_doc_level = g_doc_level_DISTRIBUTION) THEN

         l_progress := '150';
         IF g_debug_stmt THEN
            PO_DEBUG.debug_stmt(l_log_head,l_progress,'distribution');
         END IF;

         /* Start Bug 3292870: Split query to make it compatible with 8i db. */

         FORALL i IN 1 .. p_doc_level_id_tbl.COUNT
         INSERT INTO PO_SESSION_GT ( key, num1 )
         VALUES
         (  l_id_key
         ,  p_doc_level_id_tbl(i)
         )
         RETURNING ROWIDTOCHAR(rowid)
         BULK COLLECT INTO l_rowid_char_tbl
         ;

         FORALL i IN 1 .. p_doc_level_id_tbl.COUNT
         UPDATE PO_SESSION_GT
         SET num2 =
            (
               SELECT PRL.requisition_header_id
               FROM
                  PO_REQUISITION_LINES_ALL PRL
               ,  PO_REQ_DISTRIBUTIONS_ALL PRD
               WHERE PRL.requisition_line_id = PRD.requisition_line_id
               AND PRD.distribution_id = p_doc_level_id_tbl(i)
            )
         WHERE rowid = CHARTOROWID(l_rowid_char_tbl(i))
         RETURNING num2
         BULK COLLECT INTO x_doc_id_tbl
         ;

         /* End Bug 3292870 */

         l_progress := '160';

      ELSE
         l_progress := '170';
         RAISE g_INVALID_CALL_EXC;
      END IF;

      l_progress := '190';

   ELSE -- PO, PA, RELEASE

      l_progress := '200';
      IF g_debug_stmt THEN
         PO_DEBUG.debug_stmt(l_log_head,l_progress,'not req');
      END IF;

      IF (p_doc_level = g_doc_level_LINE) THEN

         l_progress := '210';
         IF g_debug_stmt THEN
            PO_DEBUG.debug_stmt(l_log_head,l_progress,'line');
         END IF;

         /* Start Bug 3292870: Split query to make it compatible with 8i db. */

         FORALL i IN 1 .. p_doc_level_id_tbl.COUNT
         INSERT INTO PO_SESSION_GT ( key, num1 )
         VALUES
         (  l_id_key
         ,  p_doc_level_id_tbl(i)
         )
         RETURNING ROWIDTOCHAR(rowid)
         BULK COLLECT INTO l_rowid_char_tbl
         ;

         FORALL i IN 1 .. p_doc_level_id_tbl.COUNT
         UPDATE PO_SESSION_GT
         SET num2 =
            (
               SELECT POL.po_header_id
               FROM PO_LINES_ALL POL
               WHERE POL.po_line_id = p_doc_level_id_tbl(i)
            )
         WHERE rowid = CHARTOROWID(l_rowid_char_tbl(i))
         RETURNING num2
         BULK COLLECT INTO x_doc_id_tbl
         ;

         /* End Bug 3292870 */

         l_progress := '220';

      ELSIF (p_doc_level = g_doc_level_SHIPMENT) THEN

         l_progress := '230';
         IF g_debug_stmt THEN
            PO_DEBUG.debug_stmt(l_log_head,l_progress,'shipment');
         END IF;

         /* Start Bug 3292870: Split query to make it compatible with 8i db. */

         FORALL i IN 1 .. p_doc_level_id_tbl.COUNT
         INSERT INTO PO_SESSION_GT ( key, num1 )
         VALUES
         (  l_id_key
         ,  p_doc_level_id_tbl(i)
         )
         RETURNING ROWIDTOCHAR(rowid)
         BULK COLLECT INTO l_rowid_char_tbl
         ;

         FORALL i IN 1 .. p_doc_level_id_tbl.COUNT
         UPDATE PO_SESSION_GT
         SET num2 =
            (
               SELECT DECODE( p_doc_type
                           ,  g_doc_type_RELEASE, POLL.po_release_id
                           ,  POLL.po_header_id
                           )
               FROM PO_LINE_LOCATIONS_ALL POLL
               WHERE POLL.line_location_id = p_doc_level_id_tbl(i)
            )
         WHERE rowid = CHARTOROWID(l_rowid_char_tbl(i))
         RETURNING num2
         BULK COLLECT INTO x_doc_id_tbl
         ;

         /* End Bug 3292870 */

         l_progress := '240';

      ELSIF (p_doc_level = g_doc_level_DISTRIBUTION) THEN

         l_progress := '250';
         IF g_debug_stmt THEN
            PO_DEBUG.debug_stmt(l_log_head,l_progress,'distribution');
         END IF;

         /* Start Bug 3292870: Split query to make it compatible with 8i db. */

         FORALL i IN 1 .. p_doc_level_id_tbl.COUNT
         INSERT INTO PO_SESSION_GT ( key, num1 )
         VALUES
         (  l_id_key
         ,  p_doc_level_id_tbl(i)
         )
         RETURNING ROWIDTOCHAR(rowid)
         BULK COLLECT INTO l_rowid_char_tbl
         ;

         FORALL i IN 1 .. p_doc_level_id_tbl.COUNT
         UPDATE PO_SESSION_GT
         SET num2 =
            (
               SELECT DECODE( p_doc_type
                           ,  g_doc_type_RELEASE, POD.po_release_id
                           ,  POD.po_header_id
                           )
               FROM PO_DISTRIBUTIONS_ALL POD
               WHERE POD.po_distribution_id = p_doc_level_id_tbl(i)
            )
         WHERE rowid = CHARTOROWID(l_rowid_char_tbl(i))
         RETURNING num2
         BULK COLLECT INTO x_doc_id_tbl
         ;

         /* End Bug 3292870 */

         l_progress := '260';

      ELSE
         l_progress := '270';
         RAISE g_INVALID_CALL_EXC;
      END IF;

      l_progress := '280';

   END IF;

   l_progress := '290';

END IF;

l_progress := '900';

IF g_debug_stmt THEN
   PO_DEBUG.debug_var(l_log_head,l_progress,'x_doc_id_tbl',x_doc_id_tbl);
   PO_DEBUG.debug_end(l_log_head);
END IF;

EXCEPTION
WHEN OTHERS THEN
   IF g_debug_unexp THEN
      PO_DEBUG.debug_exc(l_log_head,l_progress);
   END IF;
   RAISE;

END get_document_ids;




-------------------------------------------------------------------------------
--Start of Comments
--Name: get_line_ids
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Returns the line-level ids for the given ids.
--Parameters:
--IN:
--p_doc_type
--  Document type.  Use the g_doc_type_<> variables, where <> is:
--    REQUISITION
--    PA
--    PO
--    RELEASE
--p_doc_level
--  The type of ids that are being passed.  Use g_doc_level_<>
--    HEADER
--    LINE
--    SHIPMENT
--    DISTRIBUTION
--p_doc_level_id_tbl
--  Ids of the doc level type of which to derive the document header id.
--OUT:
--x_line_id_tbl
--  Line-level ids of the input ids.
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE get_line_ids(
   p_doc_type                       IN             VARCHAR2
,  p_doc_level                      IN             VARCHAR2
,  p_doc_level_id_tbl               IN             po_tbl_number
,  x_line_id_tbl                    OUT NOCOPY     po_tbl_number
)
IS

l_log_head     CONSTANT VARCHAR2(100) := g_log_head||'GET_LINE_IDS';
l_progress     VARCHAR2(3) := '000';

l_id_key    NUMBER;

--Bug 3292870
l_rowid_char_tbl     g_rowid_char_tbl;

BEGIN

IF g_debug_stmt THEN
   PO_DEBUG.debug_begin(l_log_head);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_type', p_doc_type);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_level', p_doc_level);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_level_id_tbl', p_doc_level_id_tbl);
END IF;

l_progress := '010';

IF (p_doc_level = g_doc_level_LINE) THEN

   l_progress := '020';
   IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(l_log_head,l_progress,'lines');
   END IF;

   x_line_id_tbl := p_doc_level_id_tbl;

ELSIF (p_doc_level = g_doc_level_HEADER) THEN

   l_progress := '100';
   IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(l_log_head,l_progress,'headers');
   END IF;

   ----------------------------------------------------
   --Algorithm:
   --
   -- 1. Load the ids into the scratchpad.
   -- 2. Join to the appropriate tables to bulk collect the line ids.
   ----------------------------------------------------

   ---------------------------------------
   -- PO_SESSION_GT column mapping
   --
   -- num1     doc_level_id
   ---------------------------------------

   l_id_key := get_session_gt_nextval();

   l_progress := '110';

   FORALL i IN 1 .. p_doc_level_id_tbl.COUNT
   INSERT INTO PO_SESSION_GT ( key, num1 )
   VALUES ( l_id_key, p_doc_level_id_tbl(i) )
   ;

   l_progress := '120';

   IF (p_doc_type = g_doc_type_REQUISITION) THEN

      l_progress := '130';
      IF g_debug_stmt THEN
         PO_DEBUG.debug_stmt(l_log_head,l_progress,'req headers');
      END IF;

      -- Gather all of the req line ids below this entity level.

      SELECT PRL.requisition_line_id
      BULK COLLECT INTO x_line_id_tbl
      FROM
         PO_REQUISITION_LINES_ALL PRL
      ,  PO_SESSION_GT IDS
      WHERE PRL.requisition_header_id = IDS.num1
      AND IDS.key = l_id_key
      ;

      l_progress := '140';

   ELSIF (p_doc_type IN (g_doc_type_PO, g_doc_type_PA)) THEN

      l_progress := '150';
      IF g_debug_stmt THEN
         PO_DEBUG.debug_stmt(l_log_head,l_progress,'po/pa headers');
      END IF;

      -- Gather all of the line ids below this entity level.

      SELECT POL.po_line_id
      BULK COLLECT INTO x_line_id_tbl
      FROM
         PO_LINES_ALL POL
      ,  PO_SESSION_GT IDS
      WHERE POL.po_header_id = IDS.num1
      AND IDS.key = l_id_key
      ;

      l_progress := '160';

   ELSE
      l_progress := '180';
      RAISE g_INVALID_CALL_EXC;
   END IF;

   l_progress := '190';

ELSIF (p_doc_level = g_doc_level_SHIPMENT
      AND p_doc_type IN (g_doc_type_PO, g_doc_type_PA, g_doc_type_RELEASE))
THEN

   l_progress := '200';
   IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(l_log_head,l_progress,'shipments');
   END IF;

   -- We need to get out the line ids in the same ordering as the
   -- input id table.
   -- We can't do a FORALL ... SELECT (PL/SQL limitation),
   -- but we can to a FORALL ... INSERT ... RETURNING.

   ----------------------------------------------------------------
   -- PO_SESSION_GT column mapping
   --
   -- num1     doc level id
   -- num2     line id of num1
   ----------------------------------------------------------------

   l_id_key := get_session_gt_nextval();

   l_progress := '210';

   /* Start Bug 3292870: Split query to make it compatible with 8i db. */

   FORALL i IN 1 .. p_doc_level_id_tbl.COUNT
   INSERT INTO PO_SESSION_GT ( key, num1 )
   VALUES
   (  l_id_key
   ,  p_doc_level_id_tbl(i)
   )
   RETURNING ROWIDTOCHAR(rowid)
   BULK COLLECT INTO l_rowid_char_tbl
   ;

   FORALL i IN 1 .. p_doc_level_id_tbl.COUNT
   UPDATE PO_SESSION_GT
   SET num2 =
      (
         SELECT POLL.po_line_id
         FROM PO_LINE_LOCATIONS_ALL POLL
         WHERE POLL.line_location_id = p_doc_level_id_tbl(i)
      )
   WHERE rowid = CHARTOROWID(l_rowid_char_tbl(i))
   RETURNING num2
   BULK COLLECT INTO x_line_id_tbl
   ;

   /* End Bug 3292870 */

   l_progress := '220';

ELSIF (p_doc_level = g_doc_level_DISTRIBUTION) THEN

   l_progress := '300';
   IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(l_log_head,l_progress,'distributions');
   END IF;

   -- We need to get out the line ids in the same ordering as the
   -- input id table.
   -- We can't do a FORALL ... SELECT (PL/SQL limitation),
   -- but we can to a FORALL ... INSERT ... RETURNING.

   ----------------------------------------------------------------
   -- PO_SESSION_GT column mapping
   --
   -- num1     doc level id
   -- num2     line id of num1
   ----------------------------------------------------------------

   l_id_key := get_session_gt_nextval();

   l_progress := '310';

   IF (p_doc_type = g_doc_type_REQUISITION) THEN

      l_progress := '320';
      IF g_debug_stmt THEN
         PO_DEBUG.debug_stmt(l_log_head,l_progress,'req');
      END IF;

      /* Start Bug 3292870: Split query to make it compatible with 8i db. */

      FORALL i IN 1 .. p_doc_level_id_tbl.COUNT
      INSERT INTO PO_SESSION_GT ( key, num1 )
      VALUES
      (  l_id_key
      ,  p_doc_level_id_tbl(i)
      )
      RETURNING ROWIDTOCHAR(rowid)
      BULK COLLECT INTO l_rowid_char_tbl
      ;

      FORALL i IN 1 .. p_doc_level_id_tbl.COUNT
      UPDATE PO_SESSION_GT
      SET num2 =
         (
            SELECT PRD.requisition_line_id
            FROM PO_REQ_DISTRIBUTIONS_ALL PRD
            WHERE PRD.distribution_id = p_doc_level_id_tbl(i)
         )
      WHERE rowid = CHARTOROWID(l_rowid_char_tbl(i))
      RETURNING num2
      BULK COLLECT INTO x_line_id_tbl
      ;

      /* End Bug 3292870 */

      l_progress := '330';

   ELSE

      l_progress := '340';
      IF g_debug_stmt THEN
         PO_DEBUG.debug_stmt(l_log_head,l_progress,'not req');
      END IF;

      /* Start Bug 3292870: Split query to make it compatible with 8i db. */

      FORALL i IN 1 .. p_doc_level_id_tbl.COUNT
      INSERT INTO PO_SESSION_GT ( key, num1 )
      VALUES
      (  l_id_key
      ,  p_doc_level_id_tbl(i)
      )
      RETURNING ROWIDTOCHAR(rowid)
      BULK COLLECT INTO l_rowid_char_tbl
      ;

      FORALL i IN 1 .. p_doc_level_id_tbl.COUNT
      UPDATE PO_SESSION_GT
      SET num2 =
         (
            SELECT POD.po_line_id
            FROM PO_DISTRIBUTIONS_ALL POD
            WHERE POD.po_distribution_id = p_doc_level_id_tbl(i)
         )
      WHERE rowid = CHARTOROWID(l_rowid_char_tbl(i))
      RETURNING num2
      BULK COLLECT INTO x_line_id_tbl
      ;

      /* End Bug 3292870 */

      l_progress := '350';

   END IF;

   l_progress := '370';

ELSE
   l_progress := '390';
   RAISE g_INVALID_CALL_EXC;
END IF;

l_progress := '900';

IF g_debug_stmt THEN
   PO_DEBUG.debug_var(l_log_head,l_progress,'x_line_id_tbl',x_line_id_tbl);
   PO_DEBUG.debug_end(l_log_head);
END IF;

EXCEPTION
WHEN OTHERS THEN
   IF g_debug_unexp THEN
      PO_DEBUG.debug_exc(l_log_head,l_progress);
   END IF;
   RAISE;

END get_line_ids;




-------------------------------------------------------------------------------
--Start of Comments
--Name: get_line_location_ids
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Retrieves the ids of shipments corresponding to the given doc level.
--Parameters:
--IN:
--p_doc_type
--  Document type.  Use the g_doc_type_<> variables, where <> is:
--    PO
--    PA
--    RELEASE
--    - REQUISITION not currently supported.
--p_doc_level
--  The type of ids that are being passed.  Use g_doc_level_<>
--    HEADER
--    LINE
--    SHIPMENT
--    DISTRIBUTION
--p_doc_level_id_tbl
--  Ids of the doc level type with which to find related shipments.
--OUT:
--x_line_location_id_tbl
--  The ids of the related shipments that were found.
--  If p_doc_level is DISTRIBUTION, the entries in this table
--  will map one-to-one to the input id table.
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE get_line_location_ids(
   p_doc_type                       IN             VARCHAR2
,  p_doc_level                      IN             VARCHAR2
,  p_doc_level_id_tbl               IN             po_tbl_number
,  x_line_location_id_tbl           OUT NOCOPY     po_tbl_number
)
IS

l_log_head     CONSTANT VARCHAR2(100) := g_log_head||'GET_LINE_LOCATION_IDS';
l_progress     VARCHAR2(3) := '000';

l_doc_level_id_key      NUMBER;

-- Bug 3292870
l_rowid_char_tbl   g_rowid_char_tbl;

BEGIN

IF g_debug_stmt THEN
   PO_DEBUG.debug_begin(l_log_head);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_type', p_doc_type);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_level', p_doc_level);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_level_id_tbl', p_doc_level_id_tbl);
END IF;

l_progress := '010';

-----------------------------------------------------------------
--Algorithm:
--
-- -  Insert the doc level ids into the scratchpad table.
-- -  Join to the main doc tables against these doc level ids
--       to retrieve the linked line location ids.
-----------------------------------------------------------------

IF (p_doc_level = g_doc_level_SHIPMENT) THEN

   l_progress := '100';
   IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(l_log_head,l_progress,'shipments');
   END IF;

   x_line_location_id_tbl := p_doc_level_id_tbl;

ELSE

   l_progress := '200';
   IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(l_log_head,l_progress,'not shipments');
   END IF;

   -- Load the entity ids into the scratchpad.

   ---------------------------------------
   -- PO_SESSION_GT column mapping
   --
   -- num1     document_level_id
   ---------------------------------------

   l_doc_level_id_key := get_session_gt_nextval();

   l_progress := '210';

   FORALL i IN 1 .. p_doc_level_id_tbl.COUNT
   INSERT INTO PO_SESSION_GT ( key, num1 )
   VALUES ( l_doc_level_id_key, p_doc_level_id_tbl(i) )
   ;

   l_progress := '220';

   -- We need to derive the appropriate line location ids for the given
   -- entity id and entity level.

   -- NOT SUPPORTED FOR REQUISITIONS

   IF (  p_doc_type = g_doc_type_RELEASE
         AND p_doc_level = g_doc_level_HEADER)
   THEN

      l_progress := '410';
      IF g_debug_stmt THEN
         PO_DEBUG.debug_stmt(l_log_head,l_progress,'release');
      END IF;

      SELECT POLL.line_location_id
      BULK COLLECT INTO x_line_location_id_tbl
      FROM
         PO_LINE_LOCATIONS_ALL POLL
      ,  PO_SESSION_GT IDS
      WHERE POLL.po_release_id = IDS.num1
      AND IDS.key = l_doc_level_id_key
      ;

      l_progress := '420';

   ELSIF (p_doc_level = g_doc_level_HEADER) THEN

      l_progress := '430';
      IF g_debug_stmt THEN
         PO_DEBUG.debug_stmt(l_log_head,l_progress,'headers');
      END IF;

      SELECT POLL.line_location_id
      BULK COLLECT INTO x_line_location_id_tbl
      FROM
         PO_LINE_LOCATIONS_ALL POLL
      ,  PO_SESSION_GT IDS
      WHERE POLL.po_header_id = IDS.num1
      AND POLL.shipment_type <> g_ship_type_SCHEDULED
      AND POLL.shipment_type <> g_ship_type_BLANKET
         -- don't pick up release shipments for POs/PAs
      AND IDS.key = l_doc_level_id_key
      ;

      l_progress := '440';

   ELSIF (p_doc_level = g_doc_level_LINE) THEN

      l_progress := '450';
      IF g_debug_stmt THEN
         PO_DEBUG.debug_stmt(l_log_head,l_progress,'lines');
      END IF;

      SELECT POLL.line_location_id
      BULK COLLECT INTO x_line_location_id_tbl
      FROM
         PO_LINE_LOCATIONS_ALL POLL
      ,  PO_SESSION_GT IDS
      WHERE POLL.po_line_id = IDS.num1
      AND POLL.shipment_type <> g_ship_type_SCHEDULED
      AND POLL.shipment_type <> g_ship_type_BLANKET
         -- don't pick up release shipments for POs/PAs
      AND IDS.key = l_doc_level_id_key
      ;

      l_progress := '460';

   ELSIF (p_doc_level = g_doc_level_DISTRIBUTION) THEN

      -- We need to get out the header ids in the same ordering as the
      -- input id table.
      -- We can't do a FORALL ... SELECT (PL/SQL limitation),
      -- but we can to a FORALL ... INSERT ... RETURNING.

      ----------------------------------------------------------------
      -- PO_SESSION_GT column mapping
      --
      -- num1     doc level id
      -- num2     line location id of num1
      ----------------------------------------------------------------

      l_progress := '470';
      IF g_debug_stmt THEN
         PO_DEBUG.debug_stmt(l_log_head,l_progress,'distributions');
      END IF;

      /* Start Bug 3292870: Split query to make it compatible with 8i db. */

      FORALL i IN 1 .. p_doc_level_id_tbl.COUNT
      INSERT INTO PO_SESSION_GT ( key, num1 )
      VALUES
      (  l_doc_level_id_key
      ,  p_doc_level_id_tbl(i)
      )
      RETURNING ROWIDTOCHAR(rowid)
      BULK COLLECT INTO l_rowid_char_tbl
      ;

      FORALL i IN 1 .. p_doc_level_id_tbl.COUNT
      UPDATE PO_SESSION_GT
      SET num2 =
         (
            SELECT POD.line_location_id
            FROM PO_DISTRIBUTIONS_ALL POD
            WHERE POD.po_distribution_id = p_doc_level_id_tbl(i)
         )
      WHERE rowid = CHARTOROWID(l_rowid_char_tbl(i))
      RETURNING num2
      BULK COLLECT INTO x_line_location_id_tbl
      ;

      /* End Bug 3292870 */

      l_progress := '480';

   ELSE
      l_progress := '490';
      RAISE g_INVALID_CALL_EXC;
   END IF;

   l_progress := '500';

END IF;

l_progress := '900';

IF g_debug_stmt THEN
   PO_DEBUG.debug_var(l_log_head,l_progress,'x_line_location_id_tbl',x_line_location_id_tbl);
   PO_DEBUG.debug_end(l_log_head);
END IF;

EXCEPTION
WHEN OTHERS THEN
   IF g_debug_unexp THEN
      PO_DEBUG.debug_exc(l_log_head,l_progress);
   END IF;
   RAISE;

END get_line_location_ids;




-------------------------------------------------------------------------------
--Start of Comments
--Name: get_distribution_ids
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Retrieves the ids of distributions below the given doc level.
--Parameters:
--IN:
--p_doc_type
--  Document type.  Use the g_doc_type_<> variables, where <> is:
--    REQUISITION
--    PA
--    PO
--    RELEASE
--p_doc_level
--  The type of ids that are being passed.  Use g_doc_level_<>
--    HEADER
--    LINE
--    SHIPMENT
--    DISTRIBUTION
--p_doc_level_id_tbl
--  Ids of the doc level type with which to find related distributions.
--OUT:
--x_dist_id_tbl
--  The ids of the related distributions that were found.
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE get_distribution_ids(
   p_doc_type                       IN             VARCHAR2
,  p_doc_level                      IN             VARCHAR2
,  p_doc_level_id_tbl               IN             po_tbl_number
,  x_distribution_id_tbl            OUT NOCOPY     po_tbl_number
)
IS

l_log_head     CONSTANT VARCHAR2(100) := g_log_head||'GET_DISTRIBUTION_IDS';
l_progress     VARCHAR2(3) := '000';

l_doc_level_id_key      NUMBER;

BEGIN

IF g_debug_stmt THEN
   PO_DEBUG.debug_begin(l_log_head);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_type', p_doc_type);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_level', p_doc_level);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_level_id_tbl', p_doc_level_id_tbl);
END IF;

l_progress := '010';

-----------------------------------------------------------------
--Algorithm:
--
-- -  Insert the doc level ids into the scratchpad table.
-- -  Join to the main doc tables against these doc level ids
--       to retrieve the linked distribution ids.
-----------------------------------------------------------------

IF (p_doc_level = g_doc_level_DISTRIBUTION) THEN

   l_progress := '100';
   IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(l_log_head,l_progress,'distributions');
   END IF;

   x_distribution_id_tbl := p_doc_level_id_tbl;

ELSE

   l_progress := '200';
   IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(l_log_head,l_progress,'not dists');
   END IF;

   -- Load the entity ids into the scratchpad.

   ---------------------------------------
   -- PO_SESSION_GT column mapping
   --
   -- num1     document_level_id
   ---------------------------------------

   l_doc_level_id_key := get_session_gt_nextval();

   l_progress := '210';

   FORALL i IN 1 .. p_doc_level_id_tbl.COUNT
   INSERT INTO PO_SESSION_GT ( key, num1 )
   VALUES ( l_doc_level_id_key, p_doc_level_id_tbl(i) )
   ;

   l_progress := '220';

   -- We need to derive the appropriate distribution ids for the given
   -- entity id and entity level.

   IF (p_doc_type = g_doc_type_REQUISITION) THEN

      l_progress := '300';
      IF g_debug_stmt THEN
         PO_DEBUG.debug_stmt(l_log_head,l_progress,'requisition');
      END IF;

      -- Gather all of the req distribution ids below this entity level.

      IF (p_doc_level = g_doc_level_HEADER) THEN

         l_progress := '310';
         IF g_debug_stmt THEN
            PO_DEBUG.debug_stmt(l_log_head,l_progress,'headers');
         END IF;

         SELECT PRD.distribution_id
         BULK COLLECT INTO x_distribution_id_tbl
         FROM
            PO_REQUISITION_LINES_ALL PRL
         ,  PO_REQ_DISTRIBUTIONS_ALL PRD
         ,  PO_SESSION_GT IDS
         WHERE PRL.requisition_header_id = IDS.num1
         AND PRD.requisition_line_id = PRL.requisition_line_id
         AND IDS.key = l_doc_level_id_key
         ;

         l_progress := '320';

      ELSIF (p_doc_level = g_doc_level_LINE) THEN

         l_progress := '330';
         IF g_debug_stmt THEN
            PO_DEBUG.debug_stmt(l_log_head,l_progress,'lines');
         END IF;

         SELECT PRD.distribution_id
         BULK COLLECT INTO x_distribution_id_tbl
         FROM
            PO_REQ_DISTRIBUTIONS_ALL PRD
         ,  PO_SESSION_GT IDS
         WHERE PRD.requisition_line_id = IDS.num1
         AND IDS.key = l_doc_level_id_key
         ;

         l_progress := '340';

      ELSE
         l_progress := '370';
         RAISE g_INVALID_CALL_EXC;
      END IF;

      l_progress := '390';

   ELSE -- PO, PA, Release, etc.

      l_progress := '400';
      IF g_debug_stmt THEN
         PO_DEBUG.debug_stmt(l_log_head,l_progress,'not req');
      END IF;

      -- Gather all of the distribution ids below this entity level.

      IF (  p_doc_type = g_doc_type_RELEASE
            AND p_doc_level = g_doc_level_HEADER
         )
      THEN

         l_progress := '410';
         IF g_debug_stmt THEN
            PO_DEBUG.debug_stmt(l_log_head,l_progress,'release');
         END IF;

         SELECT POD.po_distribution_id
         BULK COLLECT INTO x_distribution_id_tbl
         FROM
            PO_DISTRIBUTIONS_ALL POD
         ,  PO_SESSION_GT IDS
         WHERE POD.po_release_id = IDS.num1
         AND IDS.key = l_doc_level_id_key
         ;

         l_progress := '420';

      ELSIF (p_doc_level = g_doc_level_HEADER) THEN

         l_progress := '430';
         IF g_debug_stmt THEN
            PO_DEBUG.debug_stmt(l_log_head,l_progress,'headers');
         END IF;

         SELECT POD.po_distribution_id
         BULK COLLECT INTO x_distribution_id_tbl
         FROM
            PO_DISTRIBUTIONS_ALL POD
         ,  PO_SESSION_GT IDS
         WHERE POD.po_header_id = IDS.num1
         AND POD.po_release_id IS NULL
         -- Don't pick up Release distributions when acting on a PPO/BPA/GA.
         -- Not using distribution_type due to dependency issues.
         AND IDS.key = l_doc_level_id_key
         ;

         l_progress := '440';

      ELSIF (p_doc_level = g_doc_level_LINE) THEN

         l_progress := '450';
         IF g_debug_stmt THEN
            PO_DEBUG.debug_stmt(l_log_head,l_progress,'lines');
         END IF;

         SELECT POD.po_distribution_id
         BULK COLLECT INTO x_distribution_id_tbl
         FROM
            PO_DISTRIBUTIONS_ALL POD
         ,  PO_SESSION_GT IDS
         WHERE POD.po_line_id = IDS.num1
         AND POD.po_release_id IS NULL
         -- Don't pick up SR distributions when acting on a PPO.
         -- Not using distribution_type due to dependency issues.
         AND IDS.key = l_doc_level_id_key
         ;

         l_progress := '460';

      ELSIF (p_doc_level = g_doc_level_SHIPMENT) THEN

         l_progress := '470';
         IF g_debug_stmt THEN
            PO_DEBUG.debug_stmt(l_log_head,l_progress,'shipments');
         END IF;

         SELECT POD.po_distribution_id
         BULK COLLECT INTO x_distribution_id_tbl
         FROM
            PO_DISTRIBUTIONS_ALL POD
         ,  PO_SESSION_GT IDS
         WHERE POD.line_location_id = IDS.num1
         AND IDS.key = l_doc_level_id_key
         ;

         l_progress := '480';

      ELSE
         l_progress := '490';
         RAISE g_INVALID_CALL_EXC;
      END IF;

      l_progress := '500';

   END IF; -- Req vs. PO/PA/Release

   l_progress := '600';

END IF; -- entity type <> DISTRIBUTION

l_progress := '900';

IF g_debug_stmt THEN
   PO_DEBUG.debug_var(l_log_head,l_progress,'x_distribution_id_tbl',x_distribution_id_tbl);
   PO_DEBUG.debug_end(l_log_head);
END IF;

EXCEPTION
WHEN OTHERS THEN
   IF g_debug_unexp THEN
      PO_DEBUG.debug_exc(l_log_head,l_progress);
   END IF;
   RAISE;

END get_distribution_ids;


--<Complex Work R12 START>
-------------------------------------------------------------------------------
--Start of Comments
--Name: get_dist_ids_from_archive
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Retrieves the ids of distributions below the given doc level for a
--  particular revision of the document from the archive tables
--Parameters:
--IN:
--p_doc_type
--  Document type.  Use the g_doc_type_<> variables, where <> is:
--    PO
--    RELEASE
--p_doc_level
--  The type of ids that are being passed.  Use g_doc_level_<>
--    HEADER
--    LINE
--    SHIPMENT
--    DISTRIBUTION
--p_doc_level_id_tbl
--  Ids of the doc level type with which to find related distributions.
--p_doc_revision_num
--  The revision number of the header in the archive table.
--  If this parameter is passed as null, the latest version in the table
--  is assumed
--OUT:
--x_distribution_id_tbl
--  The ids of the related distributions that were found.
--x_distribution_rev_num_tbl
--  The revision number of the distribution rows in the archive table
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE get_dist_ids_from_archive(
   p_doc_type                       IN             VARCHAR2
,  p_doc_level                      IN             VARCHAR2
,  p_doc_level_id_tbl               IN             po_tbl_number
,  p_doc_revision_num               IN             NUMBER
,  x_distribution_id_tbl            OUT NOCOPY     po_tbl_number
,  x_distribution_rev_num_tbl       OUT NOCOPY     po_tbl_number
)
IS

l_log_head     CONSTANT VARCHAR2(100) := g_log_head||'GET_DIST_IDS_FROM_ARCHIVE';
l_progress     VARCHAR2(3) := '000';

l_doc_level_id_key      NUMBER;
l_revision_specified_flag  VARCHAR2(1);

BEGIN

IF g_debug_stmt THEN
   PO_DEBUG.debug_begin(l_log_head);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_type', p_doc_type);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_level', p_doc_level);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_level_id_tbl', p_doc_level_id_tbl);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_revision_num', p_doc_revision_num);
END IF;

  l_progress := '010';

-----------------------------------------------------------------
--Algorithm:
--
-- -  Insert the doc level ids into the scratchpad table.
-- -  Join to the main doc tables against these doc level ids
--       to retrieve the linked distribution ids.
-----------------------------------------------------------------

   l_progress := '200';
   IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(l_log_head,l_progress,'not dists');
   END IF;

   -- Load the entity ids into the scratchpad.

   ---------------------------------------
   -- PO_SESSION_GT column mapping
   --
   -- num1     document_level_id
   ---------------------------------------

   l_doc_level_id_key := get_session_gt_nextval();

   l_progress := '210';

   FORALL i IN 1 .. p_doc_level_id_tbl.COUNT
   INSERT INTO PO_SESSION_GT ( key, num1 )
   VALUES ( l_doc_level_id_key, p_doc_level_id_tbl(i) )
   ;

   l_progress := '220';

   -- If a specific revision num is not passed in, set a flag to
   -- indicate we should use the latest revision in the archive table
   IF (p_doc_revision_num IS NULL) THEN
     l_revision_specified_flag := 'Y';
   ELSE
     l_revision_specified_flag := 'N';
   END IF;


   -- We need to derive the appropriate distribution ids for the given
   -- entity id and entity level.

   IF (p_doc_type = g_doc_type_REQUISITION) THEN

      l_progress := '300';
      IF g_debug_stmt THEN
         PO_DEBUG.debug_stmt(l_log_head,l_progress,'requisition');
      END IF;

      -- Requisitions are not archived, hence this doc type is not
      -- supported by this API
      RAISE g_INVALID_CALL_EXC;

   ELSE -- PO, Release

      l_progress := '400';
      IF g_debug_stmt THEN
         PO_DEBUG.debug_stmt(l_log_head,l_progress,'not req');
      END IF;

      -- Gather all of the distribution ids below this entity level.

      IF (  p_doc_type = g_doc_type_RELEASE
            AND p_doc_level = g_doc_level_HEADER
         )
      THEN

         l_progress := '410';
         IF g_debug_stmt THEN
            PO_DEBUG.debug_stmt(l_log_head,l_progress,'release');
         END IF;

         SELECT POD.po_distribution_id
              , POD.revision_num
         BULK COLLECT INTO
                x_distribution_id_tbl
              , x_distribution_rev_num_tbl
         FROM
            PO_DISTRIBUTIONS_ARCHIVE_ALL POD
         ,  PO_SESSION_GT IDS
         WHERE POD.po_release_id = IDS.num1
         AND IDS.key = l_doc_level_id_key
         AND ( (l_revision_specified_flag = 'Y'
                AND POD.latest_external_flag = 'Y')
             OR
               (l_revision_specified_flag = 'N'
                AND POD.revision_num =
                   (SELECT max(POD2.revision_num)
                    FROM PO_DISTRIBUTIONS_ARCHIVE_ALL POD2
                    WHERE POD2.po_distribution_id = POD.po_distribution_id
                    AND POD2.revision_num <= p_doc_revision_num) )
              )
         ;

         l_progress := '420';

      ELSIF (p_doc_level = g_doc_level_HEADER) THEN

         l_progress := '430';
         IF g_debug_stmt THEN
            PO_DEBUG.debug_stmt(l_log_head,l_progress,'headers');
         END IF;

         SELECT POD.po_distribution_id
              , POD.revision_num
         BULK COLLECT INTO
                x_distribution_id_tbl
              , x_distribution_rev_num_tbl
         FROM
            PO_DISTRIBUTIONS_ARCHIVE_ALL POD
         ,  PO_SESSION_GT IDS
         WHERE POD.po_header_id = IDS.num1
         AND POD.po_release_id IS NULL
         -- Don't pick up Release distributions when acting on a PPO/BPA/GA.
         -- Not using distribution_type due to dependency issues.
         AND IDS.key = l_doc_level_id_key
         AND ( (l_revision_specified_flag = 'Y'
                AND POD.latest_external_flag = 'Y')
             OR
               (l_revision_specified_flag = 'N'
                AND POD.revision_num =
                   (SELECT max(POD2.revision_num)
                    FROM PO_DISTRIBUTIONS_ARCHIVE_ALL POD2
                    WHERE POD2.po_distribution_id = POD.po_distribution_id
                    AND POD2.revision_num <= p_doc_revision_num) )
              )
         ;

         l_progress := '440';

      ELSIF (p_doc_level = g_doc_level_LINE) THEN

         l_progress := '450';
         IF g_debug_stmt THEN
            PO_DEBUG.debug_stmt(l_log_head,l_progress,'lines');
         END IF;

         SELECT POD.po_distribution_id
              , POD.revision_num
         BULK COLLECT INTO
                x_distribution_id_tbl
              , x_distribution_rev_num_tbl
         FROM
            PO_DISTRIBUTIONS_ARCHIVE_ALL POD
         ,  PO_SESSION_GT IDS
         WHERE POD.po_line_id = IDS.num1
         AND POD.po_release_id IS NULL
         -- Don't pick up SR distributions when acting on a PPO.
         -- Not using distribution_type due to dependency issues.
         AND IDS.key = l_doc_level_id_key
         AND ( (l_revision_specified_flag = 'Y'
                AND POD.latest_external_flag = 'Y')
             OR
               (l_revision_specified_flag = 'N'
                AND POD.revision_num =
                   (SELECT max(POD2.revision_num)
                    FROM PO_DISTRIBUTIONS_ARCHIVE_ALL POD2
                    WHERE POD2.po_distribution_id = POD.po_distribution_id
                    AND POD2.revision_num <= p_doc_revision_num) )
              )
         ;

         l_progress := '460';

      ELSIF (p_doc_level = g_doc_level_SHIPMENT) THEN

         l_progress := '470';
         IF g_debug_stmt THEN
            PO_DEBUG.debug_stmt(l_log_head,l_progress,'shipments');
         END IF;

         SELECT POD.po_distribution_id
              , POD.revision_num
         BULK COLLECT INTO
                x_distribution_id_tbl
              , x_distribution_rev_num_tbl
         FROM
            PO_DISTRIBUTIONS_ARCHIVE_ALL POD
         ,  PO_SESSION_GT IDS
         WHERE POD.line_location_id = IDS.num1
         AND IDS.key = l_doc_level_id_key
         AND ( (l_revision_specified_flag = 'Y'
                AND POD.latest_external_flag = 'Y')
             OR
               (l_revision_specified_flag = 'N'
                AND POD.revision_num =
                   (SELECT max(POD2.revision_num)
                    FROM PO_DISTRIBUTIONS_ARCHIVE_ALL POD2
                    WHERE POD2.po_distribution_id = POD.po_distribution_id
                    AND POD2.revision_num <= p_doc_revision_num) )
              )
         ;

         l_progress := '480';

      ELSIF (p_doc_level = g_doc_level_DISTRIBUTION) THEN

         l_progress := '490';
         IF g_debug_stmt THEN
            PO_DEBUG.debug_stmt(l_log_head,l_progress,'distributions');
         END IF;

         SELECT POD.po_distribution_id
              , POD.revision_num
         BULK COLLECT INTO
                x_distribution_id_tbl
              , x_distribution_rev_num_tbl
         FROM
            PO_DISTRIBUTIONS_ARCHIVE_ALL POD
         ,  PO_SESSION_GT IDS
         WHERE POD.po_distribution_id = IDS.num1
         AND IDS.key = l_doc_level_id_key
         AND ( (l_revision_specified_flag = 'Y'
                AND POD.latest_external_flag = 'Y')
             OR
               (l_revision_specified_flag = 'N'
                AND POD.revision_num =
                   (SELECT max(POD2.revision_num)
                    FROM PO_DISTRIBUTIONS_ARCHIVE_ALL POD2
                    WHERE POD2.po_distribution_id = POD.po_distribution_id
                    AND POD2.revision_num <= p_doc_revision_num) )
              )
         ;

         l_progress := '500';

      ELSE
         l_progress := '510';
         RAISE g_INVALID_CALL_EXC;
      END IF;

      l_progress := '520';

   END IF; -- Req vs. PO/Release

   l_progress := '600';


IF g_debug_stmt THEN
   PO_DEBUG.debug_var(l_log_head,l_progress,'x_distribution_id_tbl',x_distribution_id_tbl);
   PO_DEBUG.debug_var(l_log_head,l_progress,'x_distribution_rev_num_tbl',x_distribution_rev_num_tbl);
   PO_DEBUG.debug_end(l_log_head);
END IF;

EXCEPTION
WHEN OTHERS THEN
   IF g_debug_unexp THEN
      PO_DEBUG.debug_exc(l_log_head,l_progress);
   END IF;
   RAISE;

END get_dist_ids_from_archive;
--<Complex Work R12 END>


------------------------------------------------------------------------------
--Start of Comments
--Name: is_encumbrance_on
--Pre-reqs:
--  Org context may need to be set prior to calling.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  This procedure checks if encumbrance is ON for a document type in a
--  specified org.
--Parameters:
--IN:
--p_doc_type
--  The type of doc to check.  Use g_doc_type_<> where <> is:
--    REQUISITION       - req enc
--    PO                - purch enc
--    RELEASE           - purch enc
--    PA                - both req and purch enc are on
--    ANY               - either req or purch enc or both are on
--p_org_id
--  The org id to check the encumbrance status in.
--  If NULL is passed, the org context is assumed to have been set
--  by the caller.
--Returns:
--  FALSE   the encumbrance for p_doc_type is NOT on
--  TRUE    the encumbrance for p_doc_type is on
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
FUNCTION is_encumbrance_on(
   p_doc_type                       IN             VARCHAR2
,  p_org_id                         IN             NUMBER
)  RETURN BOOLEAN
IS

l_log_head     CONSTANT VARCHAR2(100) := g_log_head||'IS_ENCUMBRANCE_ON';
l_progress     VARCHAR2(3) := '000';

l_req_enc_flag       FINANCIALS_SYSTEM_PARAMS_ALL.req_encumbrance_flag%TYPE;
l_purch_enc_flag     FINANCIALS_SYSTEM_PARAMS_ALL.purch_encumbrance_flag%TYPE;

l_req_encumbrance_on    BOOLEAN;
l_po_encumbrance_on  BOOLEAN;

l_enc_on    BOOLEAN;

BEGIN

IF g_debug_stmt THEN
   PO_DEBUG.debug_begin(l_log_head);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_type', p_doc_type);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_org_id', p_org_id);
END IF;

l_progress := '010';

-- Get the FSP encumbrance status values.
-- If org id is not passed in, use the org-striped table,
-- otherwise use the _ALL table.

IF (p_org_id IS NULL) THEN

   l_progress := '020';
   IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(l_log_head,l_progress,'using FINANCIALS_SYSTEM_PARAMETERS');
   END IF;

   SELECT FSP.req_encumbrance_flag, FSP.purch_encumbrance_flag
   INTO l_req_enc_flag, l_purch_enc_flag
   FROM FINANCIALS_SYSTEM_PARAMETERS FSP
   ;

   l_progress := '030';

ELSE

   l_progress := '040';
   IF g_debug_stmt THEN
      PO_DEBUG.debug_stmt(l_log_head,l_progress,'using FINANCIALS_SYSTEM_PARAMS_ALL');
   END IF;

   SELECT FSP.req_encumbrance_flag, FSP.purch_encumbrance_flag
   INTO l_req_enc_flag, l_purch_enc_flag
   FROM FINANCIALS_SYSTEM_PARAMS_ALL FSP
   WHERE FSP.org_id = p_org_id
   ;

   l_progress := '050';

END IF;

l_progress := '060';

IF g_debug_stmt THEN
   PO_DEBUG.debug_var(l_log_head,l_progress,'l_req_enc_flag',l_req_enc_flag);
   PO_DEBUG.debug_var(l_log_head,l_progress,'l_purch_enc_flag',l_purch_enc_flag);
END IF;

-- Set the vars for encumbrance checking.

IF (l_req_enc_flag = 'Y') THEN
   l_req_encumbrance_on := TRUE;
ELSE
   l_req_encumbrance_on := FALSE;
END IF;

l_progress := '070';

IF (l_purch_enc_flag = 'Y') THEN
   l_po_encumbrance_on := TRUE;
ELSE
   l_po_encumbrance_on := FALSE;
END IF;

l_progress := '080';

IF g_debug_stmt THEN
   PO_DEBUG.debug_var(l_log_head,l_progress,'l_req_encumbrance_on',l_req_encumbrance_on);
   PO_DEBUG.debug_var(l_log_head,l_progress,'l_po_encumbrance_on',l_po_encumbrance_on);
END IF;

-- Set the return value for the appropriate doc type.

IF (p_doc_type = g_doc_type_REQUISITION) THEN

   l_progress := '100';

   l_enc_on := l_req_encumbrance_on;

ELSIF (p_doc_type IN (g_doc_type_PO, g_doc_type_RELEASE)) THEN

   l_progress := '110';

   l_enc_on := l_po_encumbrance_on;

ELSIF (p_doc_type = g_doc_type_PA) THEN

   l_progress := '120';

   l_enc_on := (l_req_encumbrance_on AND l_po_encumbrance_on);

ELSIF (p_doc_type = g_doc_type_ANY) THEN

   l_progress := '130';

   l_enc_on := (l_req_encumbrance_on OR l_po_encumbrance_on);

ELSE
   l_progress := '170';
   RAISE g_INVALID_CALL_EXC;
END IF;

l_progress := '900';

IF g_debug_stmt THEN
   PO_DEBUG.debug_var(l_log_head,l_progress,'l_enc_on',l_enc_on);
   PO_DEBUG.debug_end(l_log_head);
END IF;

RETURN(l_enc_on);

EXCEPTION
WHEN OTHERS THEN
   IF g_debug_unexp THEN
      PO_DEBUG.debug_var(l_log_head,l_progress,'l_enc_on',l_enc_on);
      PO_DEBUG.debug_exc(l_log_head,l_progress);
   END IF;
   RAISE;

END is_encumbrance_on;


-----------------------------------------------------------------<SERVICES FPJ>
-------------------------------------------------------------------------------
--Start of Comments
--Name: get_translated_text
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  This function takes in a message name and token-value pairs and returns
--  the translated text as a VARCHAR2 String.
--Parameters:
--IN:
--p_message_name
--  Name of message in Message Dictionary.
--p_token1
--  Name of token variable in the message (only applies if a token exists).
--p_value1
--  Value to subsitute for token (only applies if a token exists).
--Returns:
--  VARCHAR2 - The translated and token-substituted message.
--Testing:
--  None.
--End of Comments
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
FUNCTION get_translated_text
(   p_message_name    IN  VARCHAR2
,   p_token1          IN  VARCHAR2 -- := NULL
,   p_value1          IN  VARCHAR2 -- := NULL
,   p_token2          IN  VARCHAR2 -- := NULL
,   p_value2          IN  VARCHAR2 -- := NULL
,   p_token3          IN  VARCHAR2 -- := NULL
,   p_value3          IN  VARCHAR2 -- := NULL
,   p_token4          IN  VARCHAR2 -- := NULL
,   p_value4          IN  VARCHAR2 -- := NULL
,   p_token5          IN  VARCHAR2 -- := NULL
,   p_value5          IN  VARCHAR2 -- := NULL
) RETURN VARCHAR2
IS
    l_application_name        VARCHAR2(3) := 'PO';

BEGIN

    ---------------------------------------------------------------------------
    -- Set Message on Stack ---------------------------------------------------
    ---------------------------------------------------------------------------

    FND_MESSAGE.set_name(l_application_name, p_message_name);

    ---------------------------------------------------------------------------
    -- Substitute Tokens ------------------------------------------------------
    ---------------------------------------------------------------------------

    IF ( p_token1 IS NOT NULL ) THEN
        FND_MESSAGE.set_token(p_token1, p_value1);
    END IF;

    IF ( p_token2 IS NOT NULL ) THEN
        FND_MESSAGE.set_token(p_token2, p_value2);
    END IF;

    IF ( p_token3 IS NOT NULL ) THEN
        FND_MESSAGE.set_token(p_token3, p_value3);
    END IF;

    IF ( p_token4 IS NOT NULL ) THEN
        FND_MESSAGE.set_token(p_token4, p_value4);
    END IF;

    IF ( p_token5 IS NOT NULL ) THEN
        FND_MESSAGE.set_token(p_token5, p_value5);
    END IF;

    ---------------------------------------------------------------------------
    -- Return Translated Message ----------------------------------------------
    ---------------------------------------------------------------------------

    return (FND_MESSAGE.get);

    ---------------------------------------------------------------------------

END get_translated_text;

--<Shared Proc FPJ START>
-------------------------------------------------------------------------------
--Start of Comments
--Name: CHECK_DOC_NUMBER_UNIQUE
--Pre-reqs:
--  None
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--   Returns boolean indicating whether a segment1 value with given type lookup
--   code passed in is unique in given operating unit. The uniqueness test is
--   done in PO trasaction and history tables. The uniqueness test spans Sourcing's
--   transaction tables also.
--Parameters:
--IN:
--  p_segment1
--     The doc number whose uniqueness needs to be tested
--  p_org_id
--     The operating unit where the uniqueness needs to be tested
--  p_type_lookup_code
--     The lookup code of the document. Valid values are 'STANDARD', 'PLANNED',
--     'CONTRACT','BLANKET', 'RFQ', 'QUOTATION'
--Testing:
--  None
--End of Comments
---------------------------------------------------------------------------
 FUNCTION Check_Doc_Number_Unique(p_Segment1 In VARCHAR2,
                                  p_org_id IN VARCHAR2,
			          p_Type_lookup_code IN VARCHAR2)
 RETURN boolean  is

 l_Unique             boolean;
 l_non_unique_seg1    Varchar2(20);
 l_api_name           CONSTANT VARCHAR2(30) := 'Check_Doc_Number_Unique';
 l_progress           varchar2(3) := '000';
 l_duplicate_exists   varchar2(1);
 l_pon_install_status varchar2(1);
 l_status             varchar2(10);
 BEGIN

    IF p_Type_lookup_code NOT IN ('RFQ', 'QUOTATION') THEN

        l_progress := '010';

        SELECT 'N'
        into l_duplicate_exists
        from sys.dual
        where not exists
          (SELECT 'po number is not unique'
           FROM   po_headers_all ph
           WHERE  ph.segment1 = p_segment1
           AND    ph.type_lookup_code IN
                  ('STANDARD','CONTRACT','BLANKET','PLANNED')
           AND    nvl(ph.org_id, -99) = nvl(p_org_id, -99));

        l_Progress := '020';

        SELECT 'N'
        into l_duplicate_exists
        from sys.dual
        where not exists
           (SELECT 'po number is not unique'
           FROM   po_history_pos_all ph
           WHERE  ph.segment1 = p_segment1
           AND    ph.type_lookup_code IN
                ('STANDARD','CONTRACT','BLANKET','PLANNED')
           AND    nvl(ph.org_id, -99) = nvl(p_org_id, -99));

      --Get the install status of Sourcing
      po_setup_s1.get_sourcing_startup(l_pon_install_status);

      if nvl(l_pon_install_status,'N') ='I' then
	   if p_Type_lookup_code in ('STANDARD','BLANKET') then
	      pon_auction_po_pkg.check_unique(p_org_id,p_segment1,l_status);
	      if l_status = 'SUCCESS' then
		    l_Unique :=TRUE;
          else
		    raise no_data_found;
          end if;
        end if;
      end if;

        l_Unique:= TRUE;

       return(l_Unique);

    ELSIF  (p_Type_lookup_code = 'RFQ') THEN

	-- RFQ specific processing

        l_progress := '030';

        SELECT 'N'
        into l_duplicate_exists
        from sys.dual
        where not exists
          (SELECT 'rfq number is not unique'
           FROM   po_headers_all ph
           WHERE  ph.segment1 = p_segment1
           AND    ph.type_lookup_code = 'RFQ'
           AND    nvl(ph.org_id, -99) = nvl(p_org_id, -99));

        l_Progress := '040';

        SELECT 'N'
        into l_duplicate_exists
        from sys.dual
        where not exists
           (SELECT 'rfq number is not unique'
           FROM   po_history_pos_all ph
           WHERE  ph.segment1 = p_segment1
           AND    ph.type_lookup_code = 'RFQ'
           AND    nvl(ph.org_id, -99) = nvl(p_org_id, -99));

        l_Unique:= TRUE;

        return(l_Unique);

    ELSIF  (p_Type_lookup_code = 'QUOTATION') THEN

	-- Quotation specific processing

        l_progress := '050';

        SELECT 'N'
        into l_duplicate_exists
        from sys.dual
        where not exists
          (SELECT 'quote number is not unique'
           FROM   po_headers_all ph
           WHERE  ph.segment1 = p_segment1
           AND    ph.type_lookup_code = 'QUOTATION'
           AND    nvl(ph.org_id, -99) = nvl(p_org_id, -99));

        l_Progress := '060';

        SELECT 'N'
        into l_duplicate_exists
        from sys.dual
        where not exists
           (SELECT 'quote number is not unique'
           FROM   po_history_pos_all ph
           WHERE  ph.segment1 = p_segment1
           AND    ph.type_lookup_code = 'QUOTATION'
           AND    nvl(ph.org_id, -99) = nvl(p_org_id, -99));

        l_Unique:= TRUE;

        return(l_Unique);

    END IF;

EXCEPTION
        WHEN NO_DATA_FOUND THEN
             --Bug 3417966 No need to set the message here
             --fnd_message.set_name('PO', 'PO_ALL_ENTER_UNIQUE_VAL');
             l_Unique:= FALSE;
             RETURN(l_Unique);
        WHEN OTHERS THEN
            l_unique := FALSE;
            IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
            THEN
              fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name,
                  SUBSTRB (SQLERRM , 1 , 200) || ' at location ' || l_progress);
            END IF;
            RETURN(l_Unique);
END Check_doc_number_Unique;

--------------------------------------------------------------------------------
--Start of Comments
--Name: check_inv_org_in_sob
--Pre-reqs:
--  None.
--Modifies:
--  FND_LOG
--  FND_MSG_PUB
--Locks:
--  None.
--Function:
--  Checks if p_inv_org_id is in the Set of Books p_sob_id. If p_sob_id
--  is NULL, then defaults p_sob_id to be the current OU's SOB.  Appends to the
--  API message list upon error.
--Parameters:
--IN:
--p_inv_org_id
--  The inventory organization ID.
--p_sob_id
--  The set of books ID, or NULL to default the current OU's SOB.
--OUT:
--x_return_status
--  FND_API.g_ret_sts_success - if the procedure completed successfully
--  FND_API.g_ret_sts_unexp_error - unexpected error occurred
--x_in_sob
--  TRUE if p_inv_org_id is within the set of books p_sob_id.
--  FALSE otherwise.
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE check_inv_org_in_sob
(
    x_return_status OUT NOCOPY VARCHAR2,
    p_inv_org_id    IN  NUMBER,
    p_sob_id        IN  NUMBER,
    x_in_sob        OUT NOCOPY BOOLEAN
)
IS
    l_progress VARCHAR2(3);
    l_in_sob VARCHAR2(1);
BEGIN
    l_progress := '000';
    x_return_status := FND_API.g_ret_sts_success;

    IF g_debug_stmt THEN
        PO_DEBUG.debug_stmt
           (p_log_head => g_log_head||'check_inv_org_in_sob',
            p_token    => 'invoked',
            p_message  => 'inv org ID: '||p_inv_org_id||' sob ID: '||p_sob_id);
    END IF;

    BEGIN

        IF (p_sob_id IS NULL) THEN
            l_progress := '010';

            --SQL What: Check if inv org p_inv_org_id is in current set of books
            --SQL Why: Outcome determines output parameter x_in_sob
            SELECT 'Y'
              INTO l_in_sob
              FROM financials_system_parameters fsp,
                   hr_organization_information hoi,
                   mtl_parameters mp
             WHERE mp.organization_id = p_inv_org_id
               AND mp.organization_id = hoi.organization_id
               AND hoi.org_information_context = 'Accounting Information'
               AND hoi.org_information1 = TO_CHAR(fsp.set_of_books_id);
        ELSE
            l_progress := '020';

            --SQL What: Check if inv org p_inv_org_id is in SOB p_sob_id
            --SQL Why: Outcome determines output parameter x_in_sob
            SELECT 'Y'
              INTO l_in_sob
              FROM hr_organization_information hoi,
                   mtl_parameters mp
             WHERE mp.organization_id = p_inv_org_id
               AND mp.organization_id = hoi.organization_id
               AND hoi.org_information_context = 'Accounting Information'
               AND hoi.org_information1 = TO_CHAR(p_sob_id);
        END IF;

        -- Successful select means inv org is in the SOB.
        x_in_sob := TRUE;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            l_progress := '030';
            x_in_sob := FALSE;
    END;

    IF g_debug_stmt THEN
        PO_DEBUG.debug_var
           (p_log_head => g_log_head||'check_inv_org_in_sob',
            p_progress => l_progress,
            p_name     => 'x_in_sob',
            p_value    => x_in_sob);
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        x_return_status := FND_API.g_ret_sts_unexp_error;
        x_in_sob := FALSE;
        FND_MSG_PUB.add_exc_msg(p_pkg_name       => g_pkg_name,
                                p_procedure_name => 'check_inv_org_in_sob',
                                p_error_text     => 'Progress: '||l_progress||
                                           ' Error: '||SUBSTRB(SQLERRM,1,215));
        IF g_debug_unexp THEN
            PO_DEBUG.debug_exc
               (p_log_head => g_log_head||'check_inv_org_in_sob',
                p_progress => l_progress);
        END IF;
END check_inv_org_in_sob;

--------------------------------------------------------------------------------
--Start of Comments
--Name: get_inv_org_ou_id
--Pre-reqs:
--  None.
--Modifies:
--  FND_LOG
--  FND_MSG_PUB
--Locks:
--  None.
--Function:
--  Gets the operating unit associated with p_inv_org_id.  If p_inv_org_id is
--  NULL, then just return a NULL x_ou_id. Appends to the API message list upon
--  error.
--Parameters:
--IN:
--p_inv_org_id
--  The inventory organization ID.
--OUT:
--x_return_status
--  FND_API.g_ret_sts_success - if the procedure completed successfully
--  FND_API.g_ret_sts_unexp_error - unexpected error occurred
--x_ou_id
--  The operating unit ID associated with the inventory org p_inv_org_id. This
--  will be NULL if p_inv_org_id is passed in as NULL.
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE get_inv_org_ou_id
(
    x_return_status OUT NOCOPY VARCHAR2,
    p_inv_org_id    IN  NUMBER,
    x_ou_id         OUT NOCOPY NUMBER
)
IS
    l_progress VARCHAR2(3);
BEGIN
    l_progress := '000';
    x_return_status := FND_API.g_ret_sts_success;

    IF g_debug_stmt THEN
        PO_DEBUG.debug_stmt
           (p_log_head => g_log_head||'get_inv_org_ou_id',
            p_token    => 'invoked',
            p_message  => 'inv org ID: '||p_inv_org_id);
    END IF;

    --< Bug 3370735 Start >
    IF (p_inv_org_id IS NULL) THEN
        -- Null out x_ou_id and return when the inv org ID is NULL
        x_ou_id := NULL;
        RETURN;
    END IF;
    --< Bug 3370735 Start >

    l_progress := '010';

    --SQL What: Get the operating unit associated with p_inv_org_id
    --SQL Why: Return value as output parameter x_ou_id
    SELECT TO_NUMBER(hoi.org_information3)
      INTO x_ou_id
      FROM hr_organization_information hoi,
           mtl_parameters mp
     WHERE mp.organization_id = p_inv_org_id
       AND mp.organization_id = hoi.organization_id
       AND hoi.org_information_context = 'Accounting Information';

    l_progress := '020';

    IF g_debug_stmt THEN
        PO_DEBUG.debug_var
           (p_log_head => g_log_head||'get_inv_org_ou_id',
            p_progress => l_progress,
            p_name     => 'x_ou_id',
            p_value    => x_ou_id);
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        x_return_status := FND_API.g_ret_sts_unexp_error;
        FND_MSG_PUB.add_exc_msg(p_pkg_name       => g_pkg_name,
                                p_procedure_name => 'get_inv_org_ou_id',
                                p_error_text     => 'Progress: '||l_progress||
                                           ' Error: '||SUBSTRB(SQLERRM,1,215));
        IF g_debug_unexp THEN
            PO_DEBUG.debug_exc
               (p_log_head => g_log_head||'get_inv_org_ou_id',
                p_progress => l_progress);
        END IF;
END get_inv_org_ou_id;

--------------------------------------------------------------------------------
--Start of Comments
--Name: get_inv_org_sob_id
--Pre-reqs:
--  None.
--Modifies:
--  FND_LOG
--  FND_MSG_PUB
--Locks:
--  None.
--Function:
--  Gets the set of books ID associated with p_inv_org_id.  Appends to the
--  API message list upon error.
--Parameters:
--IN:
--p_inv_org_id
--  The inventory organization ID.
--OUT:
--x_return_status
--  FND_API.g_ret_sts_success - if the procedure completed successfully
--  FND_API.g_ret_sts_unexp_error - unexpected error occurred
--x_sob_id
--  The set of books ID associated with the inventory org p_inv_org_id.
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE get_inv_org_sob_id
(
    x_return_status OUT NOCOPY VARCHAR2,
    p_inv_org_id    IN  NUMBER,
    x_sob_id        OUT NOCOPY NUMBER
)
IS
    l_progress VARCHAR2(3);
BEGIN
    l_progress := '000';
    x_return_status := FND_API.g_ret_sts_success;

    IF g_debug_stmt THEN
        PO_DEBUG.debug_stmt
           (p_log_head => g_log_head||'get_inv_org_sob_id',
            p_token    => 'invoked',
            p_message  => 'inv org ID: '||p_inv_org_id);
    END IF;

    l_progress := '010';

    --SQL What: Get the set of books ID associated with p_inv_org_id
    --SQL Why: Return value as output parameter x_sob_id
    SELECT TO_NUMBER(hoi.org_information1)
      INTO x_sob_id
      FROM hr_organization_information hoi,
           mtl_parameters mp
     WHERE mp.organization_id = p_inv_org_id
       AND mp.organization_id = hoi.organization_id
       AND hoi.org_information_context = 'Accounting Information';

    l_progress := '020';

    IF g_debug_stmt THEN
        PO_DEBUG.debug_var
           (p_log_head => g_log_head||'get_inv_org_sob_id',
            p_progress => l_progress,
            p_name     => 'x_sob_id',
            p_value    => x_sob_id);
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        x_return_status := FND_API.g_ret_sts_unexp_error;
        FND_MSG_PUB.add_exc_msg(p_pkg_name       => g_pkg_name,
                                p_procedure_name => 'get_inv_org_sob_id',
                                p_error_text     => 'Progress: '||l_progress||
                                           ' Error: '||SUBSTRB(SQLERRM,1,215));
        IF g_debug_unexp THEN
            PO_DEBUG.debug_exc
               (p_log_head => g_log_head||'get_inv_org_sob_id',
                p_progress => l_progress);
        END IF;
END get_inv_org_sob_id;

--------------------------------------------------------------------------------
--Start of Comments
--Name: get_inv_org_info
--Pre-reqs:
--  None.
--Modifies:
--  FND_LOG
--  FND_MSG_PUB
--Locks:
--  None.
--Function:
--  Gets the following information associated with p_inv_org_id:
--      business group ID
--      set of books ID
--      chart of accounts ID
--      operating unit ID
--      legal entity ID
--  Appends to the API message list upon error.
--Parameters:
--IN:
--p_inv_org_id
--  The inventory organization ID.
--OUT:
--x_return_status
--  FND_API.g_ret_sts_success - if the procedure completed successfully
--  FND_API.g_ret_sts_unexp_error - unexpected error occurred
--x_business_group_id
--  The business group ID associated with the inventory org p_inv_org_id.
--x_set_of_books_id
--  The set of books ID associated with the inventory org p_inv_org_id.
--x_chart_of_accounts_id
--  The chart of accounts ID associated with the inventory org p_inv_org_id.
--x_operating_unit_id
--  The operating unit ID associated with the inventory org p_inv_org_id.
--x_legal_entity_id
--  The legal entity ID associated with the inventory org p_inv_org_id.
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE get_inv_org_info
(
    x_return_status         OUT NOCOPY VARCHAR2,
    p_inv_org_id            IN  NUMBER,
    x_business_group_id     OUT NOCOPY NUMBER,
    x_set_of_books_id       OUT NOCOPY NUMBER,
    x_chart_of_accounts_id  OUT NOCOPY NUMBER,
    x_operating_unit_id     OUT NOCOPY NUMBER,
    x_legal_entity_id       OUT NOCOPY NUMBER
)
IS
    l_progress VARCHAR2(3);
BEGIN
    l_progress := '000';
    x_return_status := FND_API.g_ret_sts_success;

    IF g_debug_stmt THEN
        PO_DEBUG.debug_stmt
           (p_log_head => g_log_head||'get_inv_org_info',
            p_token    => 'invoked',
            p_message  => 'inv org ID: '||p_inv_org_id);
    END IF;

    l_progress := '010';

    --SQL What: Get the important ID's associated with p_inv_org_id. These ID's
    --  are the same as those returned by ORG_ORGANIZATION_DEFINITIONS.
    --SQL Why: Return value of ID's as output parameters to procedure.
    SELECT haou.business_group_id,
           gsob.set_of_books_id,
           gsob.chart_of_accounts_id,
           TO_NUMBER(hoi.org_information3),
           TO_NUMBER(hoi.org_information2)
      INTO x_business_group_id,
           x_set_of_books_id,
           x_chart_of_accounts_id,
           x_operating_unit_id,
           x_legal_entity_id
      FROM hr_organization_information hoi,
           hr_all_organization_units haou,
           mtl_parameters mp,
           gl_sets_of_books gsob
     WHERE mp.organization_id = p_inv_org_id
       AND mp.organization_id = haou.organization_id
       AND haou.organization_id = hoi.organization_id
       AND hoi.org_information_context = 'Accounting Information'
       AND TO_NUMBER(hoi.org_information1) = gsob.set_of_books_id;

    l_progress := '020';

    IF g_debug_stmt THEN
        PO_DEBUG.debug_stmt
           (p_log_head => g_log_head||'get_inv_org_info',
            p_token    => 'output',
            p_message  => 'bg ID: '||x_business_group_id||' sob ID: '||
                x_set_of_books_id||' coa ID: '||x_chart_of_accounts_id||
                ' ou ID: '||x_operating_unit_id||' le ID: '||
                x_legal_entity_id);
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        x_return_status := FND_API.g_ret_sts_unexp_error;
        FND_MSG_PUB.add_exc_msg(p_pkg_name       => g_pkg_name,
                                p_procedure_name => 'get_inv_org_info',
                                p_error_text     => 'Progress: '||l_progress||
                                           ' Error: '||SUBSTRB(SQLERRM,1,215));
        IF g_debug_unexp THEN
            PO_DEBUG.debug_exc
               (p_log_head => g_log_head||'get_inv_org_info',
                p_progress => l_progress);
        END IF;
END get_inv_org_info;

--<Shared Proc FPJ END>



--------------------------------------------------------------------------------
--Start of Comments
--Name: get_open_encumbrance_stats
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Classifies the distributions below the given entity that are not
--  cancelled or finally closed.
--  This procedure is being used by functions that are embedded in SQL
--  statements in other products (views, etc.), so it is not allowed
--  to modify anything (except in an autonomous transaction).
--  Because of this restriction, the utility procedures that use
--  global temp tables cannot be leveraged.
--Parameters:
--IN:
--p_doc_type
--  Document type.  Use the g_doc_type_<> variables, where <> is:
--    REQUISITION
--    PA
--    PO
--    RELEASE
--p_doc_level
--  The type of ids that are being passed.  Use g_doc_level_<>
--    HEADER
--    LINE
--    SHIPMENT
--    DISTRIBUTION
--p_doc_level_id
--  Id of the doc level type on which the action is being taken.
--OUT:
--x_reserved_count
--  The number of (non-prevent) distributions that are reserved.
--x_unreserved_count
--  The number of non-prevent distributions that are unreserved.
--x_prevented_count
--  The number of distributions that have prevent_encumbrance_flag set to 'Y'.
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE get_open_encumbrance_stats(
   p_doc_type                       IN             VARCHAR2
,  p_doc_level                      IN             VARCHAR2
,  p_doc_level_id                   IN             NUMBER
,  x_reserved_count                 OUT NOCOPY     NUMBER
,  x_unreserved_count               OUT NOCOPY     NUMBER
,  x_prevented_count                OUT NOCOPY     NUMBER
)
IS

l_proc_name CONSTANT VARCHAR2(30) := 'GET_OPEN_ENCUMBRANCE_STATS';
l_log_head  CONSTANT VARCHAR2(100) := g_log_head || l_proc_name;
l_progress  VARCHAR2(3) := '000';

BEGIN

IF g_debug_stmt THEN
   PO_DEBUG.debug_begin(l_log_head);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_type',p_doc_type);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_level',p_doc_level);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_level_id',p_doc_level_id);
END IF;

l_progress := '010';

IF (p_doc_type = g_doc_type_REQUISITION) THEN

   l_progress := '100';

   --SQL What:
   --    Count the distributions that fall into different categories.
   --SQL Where:
   --    Not Cancelled, not Finally Closed.
   --    The id passed in can be header, line, or dist. id.
   --    An inner query is used in the FROM clause to avoid duplicating
   --    any logic, while maintaining a decent SQL plan.

   SELECT

      -- reserved rows that are not prevent_encumbrance
      -- i.e., prevent_encumbrance_flag <> Y and encumbered_flag = Y
      COUNT(   DECODE(  PRD.prevent_encumbrance_flag
                     ,  'Y', NULL
                     ,  DECODE(  PRD.encumbered_flag
                              ,  'Y', 'Y'
                              ,  NULL
                              )
                     )
            )

      -- unreserved rows that are not prevent_encumbrance
      -- i.e., prevent_encumbrance_flag <> Y and encumbered_flag <> Y
   ,  COUNT(   DECODE(  PRD.prevent_encumbrance_flag
                     ,  'Y', NULL
                     ,  DECODE(  PRD.encumbered_flag
                              ,  'Y', NULL
                              ,  'N'
                              )
                     )
            )

      -- prevent_encumbrance rows
      -- i.e., prevent_encumbrance_flag = Y
   ,  COUNT(   DECODE(  PRD.prevent_encumbrance_flag
                     ,  'Y', 'Y'
                     ,  NULL
                     )
            )

   INTO
      x_reserved_count
   ,  x_unreserved_count
   ,  x_prevented_count

   FROM
      PO_REQ_DISTRIBUTIONS_ALL PRD
   ,  PO_REQUISITION_LINES_ALL PRL
   ,  (
         SELECT
            p_doc_level_id             dist_id
         FROM DUAL
         WHERE p_doc_level = g_doc_level_DISTRIBUTION
         UNION ALL
         SELECT
            PRD1.distribution_id       dist_id
         FROM PO_REQ_DISTRIBUTIONS_ALL PRD1
         WHERE p_doc_level = g_doc_level_LINE
         AND   PRD1.requisition_line_id = p_doc_level_id
         UNION ALL
         SELECT
            PRD2.distribution_id       dist_id
         FROM
            PO_REQ_DISTRIBUTIONS_ALL PRD2
         ,  PO_REQUISITION_LINES_ALL PRL2
         WHERE p_doc_level = g_doc_level_HEADER
         AND   PRD2.requisition_line_id = PRL2.requisition_line_id
         AND   PRL2.requisition_header_id = p_doc_level_id
      ) DIST_IDS

   WHERE PRL.requisition_line_id = PRD.requisition_line_id
   AND   NVL(PRL.cancel_flag,'N') <> 'Y'
   AND   NVL(PRL.closed_code,g_clsd_OPEN) <> g_clsd_FINALLY_CLOSED
   AND   PRD.distribution_id = DIST_IDS.dist_id
   ;

   l_progress := '190';

ELSE  -- not a requisition

   l_progress := '200';

   --SQL What:
   --    Count the distributions that fall into different categories.
   --SQL Where:
   --    Not Cancelled, not Finally Closed.
   --    The id passed in can be header, line, shipment, dist., or release id.

   SELECT

      -- reserved rows that are not prevent_encumbrance
      -- i.e., prevent_encumbrance_flag <> Y and encumbered_flag = Y
      COUNT(   DECODE(  POD.prevent_encumbrance_flag
                     ,  'Y', NULL
                     ,  DECODE(  POD.encumbered_flag
                              ,  'Y', 'Y'
                              ,  NULL
                              )
                     )
            )

      -- unreserved rows that are not prevent_encumbrance
      -- i.e., prevent_encumbrance_flag <> Y and encumbered_flag <> Y
   ,  COUNT(   DECODE(  POD.prevent_encumbrance_flag
                     ,  'Y', NULL
                     ,  DECODE(  POD.encumbered_flag
                              ,  'Y', NULL
                              ,  'N'
                              )
                     )
            )

      -- prevent_encumbrance rows
      -- i.e., prevent_encumbrance_flag = Y
   ,  COUNT(   DECODE(  POD.prevent_encumbrance_flag
                     ,  'Y', 'Y'
                     ,  NULL
                     )
            )

   INTO
      x_reserved_count
   ,  x_unreserved_count
   ,  x_prevented_count

   FROM
      PO_DISTRIBUTIONS_ALL POD
   ,  PO_LINE_LOCATIONS_ALL POLL
   ,  PO_HEADERS_ALL POH

   WHERE POLL.line_location_id(+) = POD.line_location_id
   AND   POH.po_header_id = POD.po_header_id
   AND
      (   (p_doc_type <> g_doc_type_PA AND NVL(POLL.cancel_flag,'N') <> 'Y')
      OR  (p_doc_type = g_doc_type_PA AND NVL(POH.cancel_flag,'N') <> 'Y')
      )
   AND
      (
         (  p_doc_type <> g_doc_type_PA
            AND NVL(POLL.closed_code,g_clsd_OPEN) <> g_clsd_FINALLY_CLOSED
         )
      OR
         (  p_doc_type = g_doc_type_PA
            AND NVL(POH.closed_code,g_clsd_OPEN) <> g_clsd_FINALLY_CLOSED
         )
      )
   AND
      (
         (  p_doc_level = g_doc_level_DISTRIBUTION
            AND   POD.po_distribution_id = p_doc_level_id
         )
      OR
         (  p_doc_level = g_doc_level_SHIPMENT
            AND   POD.line_location_id = p_doc_level_id
         )
      OR
         (  p_doc_level = g_doc_level_LINE
            AND   POD.po_line_id = p_doc_level_id
         )
      OR
         (  p_doc_level = g_doc_level_HEADER
            AND   p_doc_type = g_doc_type_RELEASE
            AND   POD.po_release_id = p_doc_level_id
         )
      OR
         (  p_doc_level = g_doc_level_HEADER
            AND   p_doc_type <> g_doc_type_RELEASE
            AND   POD.po_header_id = p_doc_level_id
         )
      )
   -- Make sure that release dists are not picked up for BPAs, PPOs.
   AND
      (
         (  p_doc_type <> g_doc_type_RELEASE
            AND   POD.po_release_id IS NULL
         )
      OR
         (  p_doc_type = g_doc_type_RELEASE
            AND   POD.po_release_id IS NOT NULL
         )
      )
   ;

   l_progress := '290';

END IF;

IF g_debug_stmt THEN
   PO_DEBUG.debug_stmt(l_log_head,l_progress,'got encumbrance counts');
END IF;

l_progress := '900';
IF g_debug_stmt THEN
   PO_DEBUG.debug_var(l_log_head,l_progress,'x_reserved_count',x_reserved_count);
   PO_DEBUG.debug_var(l_log_head,l_progress,'x_unreserved_count',x_unreserved_count);
   PO_DEBUG.debug_var(l_log_head,l_progress,'x_prevented_count',x_prevented_count);
   PO_DEBUG.debug_end(l_log_head);
END IF;

EXCEPTION
WHEN OTHERS THEN
   IF g_debug_unexp THEN
      PO_DEBUG.debug_var(l_log_head,l_progress,'x_reserved_count',x_reserved_count);
      PO_DEBUG.debug_var(l_log_head,l_progress,'x_unreserved_count',x_unreserved_count);
      PO_DEBUG.debug_var(l_log_head,l_progress,'x_prevented_count',x_prevented_count);
      PO_DEBUG.debug_exc(l_log_head,l_progress);
   END IF;
   RAISE;

END get_open_encumbrance_stats;




--------------------------------------------------------------------------------
--Start of Comments
--Name: should_display_reserved
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Determines whether or not the status of the given entity should display
--  as "Reserved".
--  This procedure is being used by functions that are embedded in SQL
--  statements in other products (views, etc.), so it is not allowed
--  to modify anything (except in an autonomous transaction).
--Parameters:
--IN:
--p_doc_type
--  Document type.  Use the g_doc_type_<> variables, where <> is:
--    REQUISITION
--    PA
--    PO
--    RELEASE
--p_doc_level
--  The type of ids that are being passed.  Use g_doc_level_<>
--    HEADER
--    LINE
--    SHIPMENT
--    DISTRIBUTION
--p_doc_level_id
--  Id of the doc level type on which the action is being taken.
--OUT:
--x_display_reserved_flag
--  VARCHAR2(1)
--  'Y' - "Reserved" should be displayed
--  'N' - don't display "Reserved"
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE should_display_reserved(
   p_doc_type                       IN             VARCHAR2
,  p_doc_level                      IN             VARCHAR2
,  p_doc_level_id                   IN             NUMBER
,  x_display_reserved_flag          OUT NOCOPY     VARCHAR2
)
IS

l_proc_name CONSTANT VARCHAR2(30) := 'SHOULD_DISPLAY_RESERVED';
l_log_head  CONSTANT VARCHAR2(100) := g_log_head || l_proc_name;
l_progress  VARCHAR2(3) := '000';

l_reserved_count   NUMBER;
l_unreserved_count NUMBER;
l_prevented_count  NUMBER;

BEGIN

IF g_debug_stmt THEN
   PO_DEBUG.debug_begin(l_log_head);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_type',p_doc_type);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_level',p_doc_level);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_level_id',p_doc_level_id);
END IF;

l_progress := '010';

get_open_encumbrance_stats(
   p_doc_type           => p_doc_type
,  p_doc_level          => p_doc_level
,  p_doc_level_id       => p_doc_level_id
,  x_reserved_count     => l_reserved_count
,  x_unreserved_count   => l_unreserved_count
,  x_prevented_count    => l_prevented_count
);

l_progress := '020';

IF (l_unreserved_count = 0 AND l_reserved_count > 0) THEN
   x_display_reserved_flag := 'Y';
ELSE
   x_display_reserved_flag := 'N';
END IF;

l_progress := '900';
IF g_debug_stmt THEN
   PO_DEBUG.debug_var(l_log_head,l_progress,'x_display_reserved_flag',x_display_reserved_flag);
   PO_DEBUG.debug_end(l_log_head);
END IF;

EXCEPTION
WHEN OTHERS THEN
   IF g_debug_unexp THEN
PO_DEBUG.debug_var(l_log_head,l_progress,'x_display_reserved_flag',x_display_reserved_flag);
      PO_DEBUG.debug_exc(l_log_head,l_progress);
   END IF;
   RAISE;

END should_display_reserved;




--------------------------------------------------------------------------------
--Start of Comments
--Name: is_fully_reserved
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Determines whether or not all of the distributions below the given entity that
--  can be reserved are reserved.
--Parameters:
--IN:
--p_doc_type
--  Document type.  Use the g_doc_type_<> variables, where <> is:
--    REQUISITION
--    PA
--    PO
--    RELEASE
--p_doc_level
--  The type of ids that are being passed.  Use g_doc_level_<>
--    HEADER
--    LINE
--    SHIPMENT
--    DISTRIBUTION
--p_doc_level_id
--  Id of the doc level type on which the action is being taken.
--OUT:
--x_fully_reserved_flag
--  VARCHAR2(1)
--  'Y' - all of the dists that can be reserved are reserved
--  'N' - there is at least one non-prevent dist that is not reserved
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE is_fully_reserved(
   p_doc_type                       IN             VARCHAR2
,  p_doc_level                      IN             VARCHAR2
,  p_doc_level_id                   IN             NUMBER
,  x_fully_reserved_flag            OUT NOCOPY     VARCHAR2
)
IS

l_proc_name CONSTANT VARCHAR2(30) := 'IS_FULLY_RESERVED';
l_log_head  CONSTANT VARCHAR2(100) := g_log_head || l_proc_name;
l_progress  VARCHAR2(3) := '000';

l_reserved_count   NUMBER;
l_unreserved_count NUMBER;
l_prevented_count  NUMBER;

BEGIN

IF g_debug_stmt THEN
   PO_DEBUG.debug_begin(l_log_head);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_type',p_doc_type);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_level',p_doc_level);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_level_id',p_doc_level_id);
END IF;

l_progress := '010';

get_open_encumbrance_stats(
   p_doc_type           => p_doc_type
,  p_doc_level          => p_doc_level
,  p_doc_level_id       => p_doc_level_id
,  x_reserved_count     => l_reserved_count
,  x_unreserved_count   => l_unreserved_count
,  x_prevented_count    => l_prevented_count
);

l_progress := '020';

IF (l_unreserved_count > 0) THEN
   x_fully_reserved_flag := 'N';
ELSE
   x_fully_reserved_flag := 'Y';
END IF;

l_progress := '900';
IF g_debug_stmt THEN
   PO_DEBUG.debug_var(l_log_head,l_progress,'x_fully_reserved_flag',x_fully_reserved_flag);
   PO_DEBUG.debug_end(l_log_head);
END IF;

EXCEPTION
WHEN OTHERS THEN
   IF g_debug_unexp THEN
PO_DEBUG.debug_var(l_log_head,l_progress,'x_fully_reserved_flag',x_fully_reserved_flag);
      PO_DEBUG.debug_exc(l_log_head,l_progress);
   END IF;
   RAISE;

END is_fully_reserved;




--------------------------------------------------------------------------------
--Start of Comments
--Name: are_any_dists_reserved
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Determines if any of the distributions below the given entity are reserved.
--Parameters:
--IN:
--p_doc_type
--  Document type.  Use the g_doc_type_<> variables, where <> is:
--    REQUISITION
--    PA
--    PO
--    RELEASE
--p_doc_level
--  The type of ids that are being passed.  Use g_doc_level_<>
--    HEADER
--    LINE
--    SHIPMENT
--    DISTRIBUTION
--p_doc_level_id
--  Id of the doc level type on which the action is being taken.
--OUT:
--x_some_dists_reserved_flag
--  VARCHAR2(1)
--  'Y' - at least one distribution is reserved
--  'N' - no distributions are reserved
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE are_any_dists_reserved(
   p_doc_type                       IN             VARCHAR2
,  p_doc_level                      IN             VARCHAR2
,  p_doc_level_id                   IN             NUMBER
,  x_some_dists_reserved_flag       OUT NOCOPY     VARCHAR2
)
IS

l_proc_name CONSTANT VARCHAR2(30) := 'ARE_ANY_DISTS_RESERVED';
l_log_head  CONSTANT VARCHAR2(100) := g_log_head || l_proc_name;
l_progress  VARCHAR2(3) := '000';

l_reserved_count   NUMBER;
l_unreserved_count NUMBER;
l_prevented_count  NUMBER;

BEGIN

IF g_debug_stmt THEN
   PO_DEBUG.debug_begin(l_log_head);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_type',p_doc_type);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_level',p_doc_level);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_doc_level_id',p_doc_level_id);
END IF;

l_progress := '010';

get_open_encumbrance_stats(
   p_doc_type           => p_doc_type
,  p_doc_level          => p_doc_level
,  p_doc_level_id       => p_doc_level_id
,  x_reserved_count     => l_reserved_count
,  x_unreserved_count   => l_unreserved_count
,  x_prevented_count    => l_prevented_count
);

l_progress := '020';

IF (l_reserved_count > 0) THEN
   x_some_dists_reserved_flag := 'Y';
ELSE
   x_some_dists_reserved_flag := 'N';
END IF;

l_progress := '900';
IF g_debug_stmt THEN
   PO_DEBUG.debug_var(l_log_head,l_progress,'x_some_dists_reserved_flag',x_some_dists_reserved_flag);
   PO_DEBUG.debug_end(l_log_head);
END IF;

EXCEPTION
WHEN OTHERS THEN
   IF g_debug_unexp THEN
PO_DEBUG.debug_var(l_log_head,l_progress,'x_some_dists_reserved_flag',x_some_dists_reserved_flag);
      PO_DEBUG.debug_exc(l_log_head,l_progress);
   END IF;
   RAISE;

END are_any_dists_reserved;




--------------------------------------------------------------------------------
--Start of Comments
--Name: get_reserved_lookup
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Gets the text to display for the "Reserved" keyword.
--Parameters:
--OUT:
--x_displayed_field
--  PO_LOOKUP_CODES.displayed_field%TYPE
--  The text corresponding to the 'RESERVED' code.
--End of Comments
--------------------------------------------------------------------------------
PROCEDURE get_reserved_lookup(
   x_displayed_field                  OUT NOCOPY     VARCHAR2
)
IS

l_proc_name CONSTANT VARCHAR2(30) := 'GET_RESERVED_LOOKUP';
l_log_head  CONSTANT VARCHAR2(100) := g_log_head || l_proc_name;
l_progress  VARCHAR2(3) := '000';

BEGIN

IF g_debug_stmt THEN
   PO_DEBUG.debug_begin(l_log_head);
END IF;

l_progress := '010';

SELECT POLC.displayed_field
INTO x_displayed_field
FROM PO_LOOKUP_CODES POLC
WHERE POLC.lookup_type = 'DOCUMENT STATE'
AND POLC.lookup_code = 'RESERVED'
;

l_progress := '900';
IF g_debug_stmt THEN
   PO_DEBUG.debug_var(l_log_head,l_progress,'x_displayed_field',x_displayed_field);
   PO_DEBUG.debug_end(l_log_head);
END IF;

EXCEPTION
WHEN OTHERS THEN
   IF g_debug_unexp THEN
      PO_DEBUG.debug_var(l_log_head,l_progress,'x_displayed_field',x_displayed_field);
      PO_DEBUG.debug_exc(l_log_head,l_progress);
   END IF;

END get_reserved_lookup;




-- Bug 3373453 START
-------------------------------------------------------------------------------
--Start of Comments
--Name: validate_yes_no_param
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Validates that the given parameter value is one of the following:
--    null, G_PARAMETER_YES, or G_PARAMETER_NO
--  Returns an error for any other value.
--Parameters:
--IN:
--p_parameter_name
--  Name of the parameter; used in the error message
--p_parameter_value
--  Parameter value to be validated
--OUT:
--x_return_status
--  FND_API.G_RET_STS_SUCCESS if the parameter value is valid.
--  FND_API.G_RET_STS_ERROR if the parameter value is not valid.
--  FND_API.G_RET_STS_UNEXP_ERROR if an unexpected error occurred.
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE validate_yes_no_param (
  x_return_status   OUT NOCOPY VARCHAR2,
  p_parameter_name  IN VARCHAR2,
  p_parameter_value IN VARCHAR2
) IS
  l_proc_name CONSTANT VARCHAR2(30) := 'VALIDATE_YES_NO_PARAM';
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF (p_parameter_value IS NOT NULL)
     AND (p_parameter_value NOT IN (G_PARAMETER_YES, G_PARAMETER_NO)) THEN

    FND_MESSAGE.set_name('PO', 'PO_INVALID_YES_NO_PARAM');
    FND_MESSAGE.set_token('PARAMETER_NAME', p_parameter_name);
    FND_MESSAGE.set_token('PARAMETER_VALUE', p_parameter_value);
    FND_MSG_PUB.add;

    x_return_status := FND_API.G_RET_STS_ERROR;
    RETURN;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    PO_DEBUG.handle_unexp_error(p_pkg_name => g_pkg_name,
                                p_proc_name => l_proc_name );
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END validate_yes_no_param;
-- Bug 3373453 END




--------------------------------------------------------------------------------
--Start of Comments
--Name: get_session_gt_nextval
--Pre-reqs:
--  None.
--Modifies:
--  PO_SESSION_GT_S
--Locks:
--  None.
--Function:
--  Retrieves the next sequence number from the PO_SESSION_GT_S sequence.
--Returns:
--  PO_SESSION_GT_S.nextval
--End of Comments
--------------------------------------------------------------------------------
FUNCTION get_session_gt_nextval
RETURN NUMBER
IS

l_proc_name CONSTANT VARCHAR2(30) := 'GET_SESSION_GT_NEXTVAL';
l_log_head  CONSTANT VARCHAR2(100) := g_log_head || l_proc_name;
l_progress  VARCHAR2(3) := '000';

x_nextval   NUMBER;

BEGIN

IF g_debug_stmt THEN
   PO_DEBUG.debug_begin(l_log_head);
END IF;

l_progress := '010';

SELECT PO_SESSION_GT_S.nextval
INTO x_nextval
FROM DUAL
;

l_progress := '900';

IF g_debug_stmt THEN
   PO_DEBUG.debug_var(l_log_head,l_progress,'x_nextval',x_nextval);
   PO_DEBUG.debug_end(l_log_head);
END IF;

RETURN(x_nextval);

EXCEPTION
WHEN OTHERS THEN
   PO_MESSAGE_S.sql_error(g_pkg_name,l_proc_name,l_progress,SQLCODE,SQLERRM);
   IF g_debug_stmt THEN
      PO_DEBUG.debug_var(l_log_head,l_progress,'x_nextval',x_nextval);
   END IF;
   RAISE;

END get_session_gt_nextval;


-- <Doc Manager Rewrite 11.5.11 Start>
-- port of deprecated user exit "REQUEST_INFO" for request code DOCUMENT_STATUS
-- org_context should be set
PROCEDURE get_document_status(
   p_document_id          IN      VARCHAR2
,  p_document_type        IN      VARCHAR2
,  p_document_subtype     IN      VARCHAR2
,  x_return_status        OUT NOCOPY VARCHAR2
,  x_document_status      OUT NOCOPY VARCHAR2
)
IS

d_msg           VARCHAR2(200);
d_progress      NUMBER;
d_module        VARCHAR2(70) := 'po.plsql.PO_CORE_S.get_document_status';

l_sep           VARCHAR2(8) := ', ';
l_ret_sts       VARCHAR2(1);

l_status_code     PO_LOOKUP_CODES.displayed_field%TYPE;
l_cancel_status   PO_LOOKUP_CODES.displayed_field%TYPE;
l_closed_status   PO_LOOKUP_CODES.displayed_field%TYPE;
l_frozen_status   PO_LOOKUP_CODES.displayed_field%TYPE;
l_hold_status     PO_LOOKUP_CODES.displayed_field%TYPE;
l_auth_status     PO_HEADERS.authorization_status%TYPE;
l_offline_status  PO_LOOKUP_CODES.displayed_field%TYPE;
l_reserved_status    PO_LOOKUP_CODES.displayed_field%TYPE;

l_cancel_flag     PO_HEADERS.cancel_flag%TYPE;
l_closed_code     PO_HEADERS.closed_code%TYPE;
l_frozen_flag     PO_HEADERS.frozen_flag%TYPE;
l_user_hold_flag  PO_HEADERS.user_hold_flag%TYPE;
l_offline_flag    PO_ACTION_HISTORY.offline_code%TYPE;
l_reserved_flag      VARCHAR2(1);

l_display_reserved   VARCHAR2(1);

BEGIN

  d_progress := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
    PO_LOG.proc_begin(d_module, 'p_document_id', p_document_id);
    PO_LOG.proc_begin(d_module, 'p_document_type', p_document_type);
    PO_LOG.proc_begin(d_module, 'p_document_subtype', p_document_subtype);
  END IF;

  BEGIN

    IF (p_document_type = 'REQUISITION')
    THEN

      d_progress := 20;

      SELECT plc_sta.displayed_field
          ,  prh.authorization_status
          ,  DECODE(nvl(prh.closed_code,'OPEN'), 'OPEN', NULL, plc_clo.displayed_field)
      INTO l_status_code, l_auth_status, l_closed_status
      FROM po_requisition_headers prh, po_lookup_codes plc_sta, po_lookup_codes plc_clo
      WHERE plc_sta.lookup_code = DECODE(prh.authorization_status,
                                    'SYSTEM_SAVED', 'INCOMPLETE',
                                    nvl(prh.authorization_status, 'INCOMPLETE')
                                  )
        AND plc_clo.lookup_code = nvl(prh.closed_code, 'OPEN')
        AND plc_clo.lookup_type = 'DOCUMENT STATE'
        AND plc_sta.lookup_type = 'AUTHORIZATION STATUS'
        AND prh.requisition_header_id = p_document_id;

      d_progress := 30;

      BEGIN

        SELECT polc.displayed_field, nvl(poah.offline_code, 'N')
        INTO l_offline_status, l_offline_flag
        FROM po_lookup_codes polc, po_action_history poah
        WHERE polc.lookup_type = 'DOCUMENT STATE'
          AND polc.lookup_code = poah.offline_code
          AND poah.object_id = p_document_id
          AND poah.object_type_code = 'REQUISITION'
          AND poah.action_code IS NULL;

      EXCEPTION
        WHEN no_data_found THEN
          IF (PO_LOG.d_stmt) THEN
            PO_LOG.stmt(d_module, d_progress, 'No data found');
          END IF;
      END;

    ELSIF (p_document_type IN ('PO', 'PA'))
    THEN

      d_progress := 40;

      SELECT plc_sta.displayed_field
          ,  DECODE(poh.cancel_flag, 'Y', plc_can.displayed_field, NULL)
          ,  DECODE(nvl(poh.closed_code,'OPEN'), 'OPEN', NULL, plc_clo.displayed_field)
          ,  DECODE(poh.frozen_flag, 'Y', plc_fro.displayed_field, NULL)
          ,  DECODE(poh.user_hold_flag, 'Y', plc_hld.displayed_field, NULL)
          ,  poh.authorization_status
          ,  nvl(poh.cancel_flag, 'N')
          ,  poh.closed_code
          ,  nvl(poh.frozen_flag, 'N')
          ,  nvl(poh.user_hold_flag,'N')
       INTO l_status_code
         ,  l_cancel_status
         ,  l_closed_status
         ,  l_frozen_status
         ,  l_hold_status
         ,  l_auth_status
         ,  l_cancel_flag
         ,  l_closed_code
         ,  l_frozen_flag
         ,  l_user_hold_flag
       FROM po_headers poh
         ,  po_lookup_codes plc_sta
		   ,  po_lookup_codes plc_can
		   ,  po_lookup_codes plc_clo
		   ,  po_lookup_codes plc_fro
 		   ,  po_lookup_codes plc_hld
       WHERE plc_sta.lookup_code = DECODE(poh.approved_flag,
                                     'R', poh.approved_flag,
                                     nvl(poh.authorization_status, 'INCOMPLETE')
                                   )
         AND plc_sta.lookup_type in ('PO APPROVAL', 'DOCUMENT STATE')
	      AND plc_can.lookup_code = 'CANCELLED'
         AND plc_can.lookup_type = 'DOCUMENT STATE'
         AND plc_clo.lookup_code = nvl(poh.closed_code, 'OPEN')
         AND plc_clo.lookup_type = 'DOCUMENT STATE'
         AND plc_fro.lookup_code = 'FROZEN'
         AND plc_fro.lookup_type = 'DOCUMENT STATE'
         AND plc_hld.lookup_code = 'ON HOLD'
         AND plc_hld.lookup_type = 'DOCUMENT STATE'
         AND poh.po_header_id    = p_document_id;

      d_progress := 50;

      BEGIN

        SELECT polc.displayed_field, nvl(poah.offline_code, 'N')
        INTO l_offline_status, l_offline_flag
        FROM po_lookup_codes polc, po_action_history poah
        WHERE polc.lookup_type = 'DOCUMENT STATE'
          AND polc.lookup_code = poah.offline_code
          AND poah.object_id = p_document_id
          AND poah.object_type_code IN ('PO', 'PA')
          AND poah.action_code IS NULL;

      EXCEPTION
        WHEN no_data_found THEN
          IF (PO_LOG.d_stmt) THEN
            PO_LOG.stmt(d_module, d_progress, 'No data found');
          END IF;
      END;

    ELSIF (p_document_type = 'RELEASE')
    THEN

      d_progress := 60;

      SELECT plc_sta.displayed_field
          ,  DECODE(por.cancel_flag, 'Y', plc_can.displayed_field, NULL)
          ,  DECODE(nvl(por.closed_code,'OPEN'), 'OPEN', NULL, plc_clo.displayed_field)
          ,  DECODE(por.frozen_flag, 'Y', plc_fro.displayed_field, NULL)
          ,  DECODE(por.hold_flag, 'Y', plc_hld.displayed_field, NULL)
          ,  por.authorization_status
          ,  nvl(por.cancel_flag, 'N')
          ,  por.closed_code
          ,  nvl(por.frozen_flag, 'N')
          ,  nvl(por.hold_flag,'N')
       INTO l_status_code
         ,  l_cancel_status
         ,  l_closed_status
         ,  l_frozen_status
         ,  l_hold_status
         ,  l_auth_status
         ,  l_cancel_flag
         ,  l_closed_code
         ,  l_frozen_flag
         ,  l_user_hold_flag
       FROM po_releases por
         ,  po_lookup_codes plc_sta
		   ,  po_lookup_codes plc_can
		   ,  po_lookup_codes plc_clo
		   ,  po_lookup_codes plc_fro
 		   ,  po_lookup_codes plc_hld
       WHERE plc_sta.lookup_code = DECODE(por.approved_flag,
                                     'R', por.approved_flag,
                                     nvl(por.authorization_status, 'INCOMPLETE')
                                   )
         AND plc_sta.lookup_type in ('PO APPROVAL', 'DOCUMENT STATE')
	      AND plc_can.lookup_code = 'CANCELLED'
         AND plc_can.lookup_type = 'DOCUMENT STATE'
         AND plc_clo.lookup_code = nvl(por.closed_code, 'OPEN')
         AND plc_clo.lookup_type = 'DOCUMENT STATE'
         AND plc_fro.lookup_code = 'FROZEN'
         AND plc_fro.lookup_type = 'DOCUMENT STATE'
         AND plc_hld.lookup_code = 'ON HOLD'
         AND plc_hld.lookup_type = 'DOCUMENT STATE'
         AND por.po_release_id    = p_document_id;

      d_progress := 70;

      BEGIN

        SELECT polc.displayed_field, nvl(poah.offline_code, 'N')
        INTO l_offline_status, l_offline_flag
        FROM po_lookup_codes polc, po_action_history poah
        WHERE polc.lookup_type = 'DOCUMENT STATE'
          AND polc.lookup_code = poah.offline_code
          AND poah.object_id = p_document_id
          AND poah.object_type_code = 'RELEASE'
          AND poah.action_code IS NULL;

      EXCEPTION
        WHEN no_data_found THEN
          IF (PO_LOG.d_stmt) THEN
            PO_LOG.stmt(d_module, d_progress, 'No data found');
          END IF;
      END;

    ELSE

      d_progress := 80;
      d_msg := 'Invalid document type';
      RAISE g_early_return_exc;

    END IF;

    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_progress, 'l_status_code', l_status_code);
      PO_LOG.stmt(d_module, d_progress, 'l_cancel_status', l_cancel_status);
      PO_LOG.stmt(d_module, d_progress, 'l_closed_status', l_closed_status);
      PO_LOG.stmt(d_module, d_progress, 'l_frozen_status', l_frozen_status);
      PO_LOG.stmt(d_module, d_progress, 'l_auth_status', l_auth_status);
      PO_LOG.stmt(d_module, d_progress, 'l_cancel_flag', l_cancel_flag);
      PO_LOG.stmt(d_module, d_progress, 'l_closed_code', l_closed_code);
      PO_LOG.stmt(d_module, d_progress, 'l_frozen_flag', l_frozen_flag);
      PO_LOG.stmt(d_module, d_progress, 'l_user_hold_flag', l_user_hold_flag);
      PO_LOG.stmt(d_module, d_progress, 'l_offline_status', l_offline_status);
      PO_LOG.stmt(d_module, d_progress, 'l_offline_flag', l_offline_flag);
    END IF;

    d_progress := 100;

    should_display_reserved(
       p_doc_type      => p_document_type
    ,  p_doc_level     => g_doc_level_HEADER
    ,  p_doc_level_id  => p_document_id
    ,  x_display_reserved_flag => l_display_reserved
    );

    IF (l_display_reserved = 'Y')
    THEN

      d_progress := 110;
      get_reserved_lookup(x_displayed_field => l_reserved_status);

    ELSE

      d_progress := 120;
      l_reserved_status := '';

    END IF;  -- l_display_reserved = 'Y';

    d_progress := 130;

    is_fully_reserved(
       p_doc_type      => p_document_type
    ,  p_doc_level     => g_doc_level_HEADER
    ,  p_doc_level_id  => p_document_id
    ,  x_fully_reserved_flag => l_reserved_flag
    );

    d_progress := 140;

    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_progress, 'l_display_reserved', l_display_reserved);
      PO_LOG.stmt(d_module, d_progress, 'l_reserved_status', l_reserved_status);
      PO_LOG.stmt(d_module, d_progress, 'l_reserved_flag', l_reserved_flag);
    END IF;

    x_document_status := l_status_code;

    IF (l_cancel_status IS NOT NULL) THEN
      x_document_status := x_document_status || l_sep || l_cancel_status;
    END IF;

    IF (l_closed_status IS NOT NULL) THEN
      x_document_status := x_document_status || l_sep || l_closed_status;
    END IF;

    IF (l_frozen_status IS NOT NULL) THEN
      x_document_status := x_document_status || l_sep || l_frozen_status;
    END IF;

    IF (l_hold_status IS NOT NULL) THEN
      x_document_status := x_document_status || l_sep || l_hold_status;
    END IF;

    IF (l_reserved_status IS NOT NULL) THEN
      x_document_status := x_document_status || l_sep || l_reserved_status;
    END IF;

    IF (l_offline_status IS NOT NULL) THEN
      x_document_status := x_document_status || l_sep || l_offline_status;
    END IF;

    l_ret_sts := 'S';

  EXCEPTION
    WHEN g_early_return_exc THEN
      l_ret_sts := 'U';
      IF (PO_LOG.d_exc) THEN
        PO_LOG.exc(d_module, d_progress, d_msg);
      END IF;
  END;

  x_return_status := l_ret_sts;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module, 'x_return_status', x_return_status);
    PO_LOG.proc_end(d_module, 'p_document_status', x_document_status);
    PO_LOG.proc_end(d_module);
  END IF;

  RETURN;

EXCEPTION
  WHEN others THEN
    x_return_status := 'U';
    IF (PO_LOG.d_exc) THEN
      PO_LOG.exc(d_module, d_progress, SQLCODE || SQLERRM);
      PO_LOG.proc_end(d_module, 'x_return_status', x_return_status);
      PO_LOG.proc_end(d_module);
    END IF;

    RETURN;

END get_document_status;

-- port of deprecated user exit "DEFAULT_PRICE"
-- org_context must be set
-- previously, if p_uom <> x_return_uom, then the form fields would not be updated
-- with the pl/sql change, it is up to the caller to check this condition.
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
)
IS

d_progress        NUMBER;
d_module          VARCHAR2(70) := 'po.plsql.PO_CORE_S.get_default_price';
d_msg             VARCHAR2(200);

l_ret_sts         VARCHAR2(1)   := 'S';
l_ship_to_loc_id  HR_LOCATIONS.ship_to_location_id%TYPE;

l_do_non_loc_cursor  BOOLEAN;

l_quantity   NUMBER;

CURSOR loc_unit_price_cur(  p_header_id NUMBER, p_line_num NUMBER
                          , p_required_curr VARCHAR2, p_required_rate_type VARCHAR2
                          , p_uom VARCHAR2, p_qty NUMBER, p_ship_to_loc_id NUMBER)
IS
  SELECT ROUND(poll.price_override * DECODE(poh.rate, 0, 1, null, 1, ROUND(poh.rate,5)), 5)
	    , poh.rate_date
	    , poh.rate
	    ,	poh.currency_code
       , poh.rate_type
       , poll.price_discount
       , poll.price_override
       , DECODE(poll.line_location_id, NULL, pol.unit_meas_lookup_code, poll.unit_meas_lookup_code)
  FROM po_headers poh, po_lines pol, po_line_locations poll
  WHERE poh.po_header_id = p_header_id
    AND poh.po_header_id = pol.po_header_id
    AND pol.line_num = p_line_num
    AND pol.po_line_id = poll.po_line_id (+)
    AND (p_required_curr IS NULL or poh.currency_code = p_required_curr)
    AND (p_required_rate_type is null or poh.rate_type = p_required_rate_type)
    AND NVL(poll.unit_meas_lookup_code, NVL(p_uom, pol.unit_meas_lookup_code))
          = NVL(p_uom, pol.unit_meas_lookup_code)
    AND trunc(sysdate) BETWEEN NVL(poll.start_date, trunc(sysdate)) AND NVL(poll.end_date, trunc(sysdate))
    AND poll.quantity <= p_qty
    AND poll.ship_to_location_id = p_ship_to_loc_id
    AND poll.shipment_type in ('PRICE BREAK', 'QUOTATION')
  ORDER BY 1 ASC;

CURSOR unit_price_cur(  p_header_id NUMBER, p_line_num NUMBER
                      , p_required_curr VARCHAR2, p_required_rate_type VARCHAR2
                      , p_uom VARCHAR2, p_qty NUMBER)
IS
  SELECT ROUND(DECODE(poll.shipment_type,
                  'PRICE BREAK', DECODE(poll.ship_to_location_id,
                                   NULL, poll.price_override,pol.unit_price),
                  'QUOTATION', DECODE(poll.ship_to_location_id,
                                 NULL,poll.price_override, pol.unit_price),
                  pol.unit_price)
                * DECODE(poh.rate, 0, 1, null, 1, ROUND(poh.rate,5)), 5)
        , poh.rate_date
        , poh.rate
        , poh.currency_code
        , poh.rate_type
        , poll.price_discount
        , DECODE(poll.shipment_type,
            'PRICE BREAK', DECODE(poll.ship_to_location_id,
                             NULL, poll.price_override ,pol.unit_price),
            'QUOTATION', DECODE(poll.ship_to_location_id,
                             NULL,poll.price_override, pol.unit_price),
            pol.unit_price)
        , DECODE(poll.line_location_id, NULL, pol.unit_meas_lookup_code, poll.unit_meas_lookup_code)
  FROM po_headers poh, po_lines pol, po_line_locations poll
  WHERE poh.po_header_id = p_header_id
    AND poh.po_header_id = pol.po_header_id
    AND pol.line_num = p_line_num
    AND pol.po_line_id = poll.po_line_id (+)
    AND (p_required_curr IS NULL or poh.currency_code = p_required_curr)
    AND (p_required_rate_type is null or poh.rate_type = p_required_rate_type)
    AND NVL(poll.unit_meas_lookup_code, NVL(p_uom, pol.unit_meas_lookup_code))
          = NVL(p_uom, pol.unit_meas_lookup_code)
    AND trunc(sysdate) BETWEEN NVL(poll.start_date, trunc(sysdate)) AND NVL(poll.end_date, trunc(sysdate))
    AND poll.quantity <= p_qty
  ORDER BY 1 ASC;


BEGIN

  d_progress := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
    PO_LOG.proc_begin(d_module, 'p_src_doc_header_id', p_src_doc_header_id);
    PO_LOG.proc_begin(d_module, 'p_src_doc_line_num', p_src_doc_line_num);
    PO_LOG.proc_begin(d_module, 'p_deliver_to_loc_id', p_deliver_to_loc_id);
    PO_LOG.proc_begin(d_module, 'p_required_currency', p_required_currency);
    PO_LOG.proc_begin(d_module, 'p_required_rate_type', p_required_rate_type);
    PO_LOG.proc_begin(d_module, 'p_quantity', p_quantity);
    PO_LOG.proc_begin(d_module, 'p_uom', p_uom);
  END IF;

  d_progress := 5;

  l_quantity := NVL(p_quantity, -1);

  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module, d_progress, 'l_quanity', l_quantity);
  END IF;

  d_progress := 10;

  BEGIN

    SELECT hrl.ship_to_location_id
    INTO l_ship_to_loc_id
    FROM hr_locations hrl
    WHERE hrl.location_id = p_deliver_to_loc_id;

    d_progress := 15;

  EXCEPTION
    WHEN no_data_found THEN
      d_progress := 17;
      l_ship_to_loc_id := NULL;
  END;

  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module, d_progress, 'l_ship_to_loc_id', l_ship_to_loc_id);
  END IF;

  d_progress := 20;

  OPEN loc_unit_price_cur( p_src_doc_header_id, p_src_doc_line_num
                         , p_required_currency, p_required_rate_type
                         , p_uom, l_quantity, l_ship_to_loc_id);

  d_progress := 25;

  FETCH loc_unit_price_cur INTO
     x_base_price
  ,  x_rate_date
  ,  x_rate
  ,  x_currency_code
  ,  x_rate_type
  ,  x_discount
  ,  x_currency_price
  ,  x_return_uom;

  IF (loc_unit_price_cur%NOTFOUND)
  THEN
    l_do_non_loc_cursor := TRUE;
  ELSE
    l_do_non_loc_cursor := FALSE;
  END IF;

  d_progress := 30;
  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module, d_progress, 'l_do_non_loc_cursor', l_do_non_loc_cursor);
  END IF;

  IF loc_unit_price_cur%ISOPEN THEN
    CLOSE loc_unit_price_cur;
  END IF;

  IF (l_do_non_loc_cursor)
  THEN

    d_progress := 40;

    OPEN unit_price_cur( p_src_doc_header_id, p_src_doc_line_num
                       , p_required_currency, p_required_rate_type
                       , p_uom, l_quantity);

    d_progress := 45;

    FETCH unit_price_cur INTO
       x_base_price
    ,  x_rate_date
    ,  x_rate
    ,  x_currency_code
    ,  x_rate_type
    ,  x_discount
    ,  x_currency_price
    ,  x_return_uom;

    --<Bug 4654432 Start>
    -- Commenting out the following IF block because this is not really an
    -- unhandled exception condition. IF no data is found from the above
    -- cursor, then the price would not default, but the API should return
    -- without error.
    --IF (unit_price_cur%NOTFOUND)
    --THEN
    --  l_ret_sts := 'U';
    --END IF;
    --<Bug 4654432 End>

    IF unit_price_cur%ISOPEN THEN
      CLOSE unit_price_cur;
    END IF;

  END IF;  -- IF l_do_non_loc_cursor

  d_progress := 50;

  x_return_status := l_ret_sts;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module, 'x_return_status', x_return_status);
    PO_LOG.proc_end(d_module, 'x_return_uom', x_return_uom);
    PO_LOG.proc_end(d_module, 'x_base_price', x_base_price);
    PO_LOG.proc_end(d_module, 'x_currency_price', x_currency_price);
    PO_LOG.proc_end(d_module, 'x_discount', x_discount);
    PO_LOG.proc_end(d_module, 'x_currency_code', x_currency_code);
    PO_LOG.proc_end(d_module, 'x_rate_type', x_rate_type);
    PO_LOG.proc_end(d_module, 'x_rate_date', x_rate_date);
    PO_LOG.proc_end(d_module, 'x_rate', x_rate);
    PO_LOG.proc_end(d_module);
  END IF;

EXCEPTION
  WHEN OTHERS THEN

    IF loc_unit_price_cur%ISOPEN THEN
      CLOSE loc_unit_price_cur;
    END IF;

    IF unit_price_cur%ISOPEN THEN
      CLOSE unit_price_cur;
    END IF;

    x_return_status := 'U';

    IF (PO_LOG.d_exc) THEN
      PO_LOG.exc(d_module, d_progress, SQLCODE || SQLERRM);
      PO_LOG.proc_end(d_module, 'x_return_status', x_return_status);
      PO_LOG.proc_end(d_module);
    END IF;

    RETURN;
END get_default_price;


-- <Doc Manager Rewrite 11.5.11 End>

-- <HTML Orders R12 Start>
--------------------------------------------------------------------------------
--Start of Comments
--Name: flag_to_boolean
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Converts the given flag value (i.e. 'Y' or 'N') to a boolean.
--  This is useful when invoking PL/SQL procedures from Java, since the
--  OracleCallableStatement does not support boolean parameters.
--Returns:
--  TRUE if the flag value is 'Y', FALSE otherwise.
--End of Comments
--------------------------------------------------------------------------------
FUNCTION flag_to_boolean (
  p_flag_value IN VARCHAR2
) RETURN BOOLEAN
IS
BEGIN
  RETURN (p_flag_value = 'Y');
END flag_to_boolean;

--------------------------------------------------------------------------------
--Start of Comments
--Name: boolean_to_flag
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Converts the given boolean to a flag value (i.e. 'Y' or 'N').
--  This is useful when invoking PL/SQL procedures from Java, since the
--  OracleCallableStatement does not support boolean parameters.
--Returns:
--  'Y' if the boolean value is TRUE, 'N' otherwise.
--End of Comments
--------------------------------------------------------------------------------
FUNCTION boolean_to_flag (
  p_boolean_value IN BOOLEAN
) RETURN VARCHAR2
IS
BEGIN
  IF (p_boolean_value) THEN
    RETURN 'Y';
  ELSE
    RETURN 'N';
  END IF;
END;
-- <HTML Orders R12 End>

-- <R12 SLA>
-------------------------------------------------------------------------------
--Start of Comments
--Name: Check_Federal_Instance
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
-- This function will identify whether the instance identified by the Operating
-- Unit specified by p_org_id is a federal instance or not.
--Parameters:
--IN:
-- p_org_id
--  This contains the org_id for which it needs to be verified whether it is
--  a federal instance or not.
--IN OUT:
-- None
--OUT:
-- None
--Returns:
-- Returns 'Y'/'N'.
--Notes:
--
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
FUNCTION Check_Federal_Instance (
  p_org_id        IN        hr_operating_units.organization_id%type
)
RETURN VARCHAR2
IS
  x_progress      VARCHAR2(3) := NULL;
  x_option_value  VARCHAR2(1);
BEGIN
  x_progress := 10;

  x_option_value := Boolean_To_Flag (FV_INSTALL.enabled(p_org_id)) ;

  RETURN(x_option_value);

EXCEPTION
  WHEN OTHERS THEN
     po_message_s.sql_error('Check_Federal_Customer', x_progress, sqlcode);
  RAISE;
END Check_Federal_Instance;

--------------------------------------------------------------------------
--Start of Comments
--Name: GET_OUTSOURCED_ASSEMBLY
--Pre-reqs:  None.
--Modifies:  None.
--Locks:     None.
--Function:
--         This function returns OUTSOURCED_ASSEMBLY value by calling the
--         JMF_SHIKYU_GRP.Validate_Osa_Flag procedure.
--         OUTSOURCED_ASSEMBLY will be either 1 (SHIKYU) or 2 (NON-SHIKYU).
--IN:	p_item_id
--	This contains unique item identifier.
--IN:	p_ship_to_org_id
--	This contains the ship_to_org_id value.
--IN OUT:  None.
--OUT:	   None.
--Returns: The function returns OUTSOURCED_ASSEMBLY.
--Notes:
-- The algorithm of the function is as follows :
-- Returns OUTSOURCED_ASSEMBLY for a given item_id and ship_to_org_id by calling
-- JMF_SHIKYU_GRP.Validate_Osa_Flag procedure.
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
FUNCTION get_outsourced_assembly( p_item_id IN NUMBER,
				  p_ship_to_org_id IN NUMBER ) RETURN NUMBER IS
	l_osa_flag varchar2(1) := 'N';
	l_return_status varchar2(1);
	l_outsourced_assembly NUMBER ;
	l_progress      VARCHAR2(3) := NULL;
        l_msg_count     NUMBER;
        l_msg_data           VARCHAR2(2000);

BEGIN

	l_progress := 10;

        -- bug4958421
        -- do not call JMF API if item id is NULL

        IF (p_item_id IS NULL) THEN
          l_outsourced_assembly := 2;

        ELSE

          JMF_SHIKYU_GRP.Validate_Osa_Flag(
                                       p_api_version  =>  1.0,
                                       p_init_msg_list  => FND_API.G_FALSE,
                                       x_return_status =>  l_return_status,
                                       x_msg_count => l_msg_count,
                                       x_msg_data   => l_msg_data,
                                       p_inventory_item_id => p_item_id,
                                       p_vendor_id=> NULL,
                                       p_vendor_site_id => NULL ,
                                       p_ship_to_organization_id => p_ship_to_org_id,
                                       x_osa_flag => l_osa_flag );


          IF l_osa_flag = 'Y' THEN
                  l_outsourced_assembly := 1;
          ELSE
                  l_outsourced_assembly := 2;
          END IF;

        END IF;

	return l_outsourced_assembly;

	EXCEPTION
	  WHEN OTHERS THEN
		po_message_s.sql_error('Get_Outsourced_Assembly', l_progress, sqlcode);
		return 2;
END get_outsourced_assembly;

--<R12 eTax Integration Start>
-------------------------------------------------------------------------------
--Start of Comments
--Name: get_default_legal_entity_id
--Pre-reqs:
--  None
--Modifies:
--  None
--Locks:
--  None
--Function:
--  Return the default legal context given the org id
--Parameters:
--IN:
--org_id
--  Unique id for the operating unit
--Returns:
--  Default Legal Entity Id
--End of Comments
-------------------------------------------------------------------------------
FUNCTION get_default_legal_entity_id(p_org_id IN NUMBER) RETURN NUMBER
IS
  l_legal_entity_id NUMBER;
  l_module_name CONSTANT VARCHAR2(100) := 'GET_DEFAULT_LEGAL_ENTITY_ID';
  d_module_base CONSTANT VARCHAR2(100) := PO_LOG.get_subprogram_base(
                                            g_log_head, l_module_name);
  d_progress NUMBER;
BEGIN
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module_base);
    PO_LOG.proc_begin(d_module_base, 'p_org_id', p_org_id);
  END IF;

  d_progress := 0;
  l_legal_entity_id := XLE_UTILITIES_GRP.Get_DefaultLegalContext_OU(p_org_id);

  d_progress := 10;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module_base);
    PO_LOG.proc_end(d_module_base, 'l_legal_entity_id', l_legal_entity_id);
  END IF;

  d_progress := 20;
  return l_legal_entity_id;
EXCEPTION
  WHEN OTHERS THEN
    IF (PO_LOG.d_exc) THEN
      PO_LOG.exc(d_module_base, d_progress, SQLCODE || SQLERRM);
      PO_LOG.proc_end(d_module_base);
      PO_LOG.proc_end(d_module_base, 'l_legal_entity_id', l_legal_entity_id);
    END IF;

    RAISE;
END get_default_legal_entity_id;
--<R12 eTax Integration End>

--<HTML Agreements R12 Start>
-------------------------------------------------------------------------------
--Start of Comments
--Name: get_last_update_date_for_doc
--Pre-reqs:
--  None
--Modifies:
--  None
--Locks:
--  None
--Function:
--  It returns the max of the last_update_date column from all the levels for a
--  given document
--Parameters:
--IN:
--p_doc_header_id
--  Document header Id
--Returns:
--  latest last_update_date for the entire document
--End of Comments
-------------------------------------------------------------------------------
FUNCTION get_last_update_date_for_doc(p_doc_header_id IN NUMBER) RETURN DATE
IS
  header_last_update_date PO_HEADERS_ALL.last_update_date%type;
  line_last_update_date PO_LINES_ALL.last_update_date%type;
  line_loc_last_update_date PO_LINE_LOCATIONS_ALL.last_update_date%type;
  dist_last_update_date PO_DISTRIBUTIONS_ALL.last_update_date%type;
  doc_last_update_date PO_HEADERS_ALL.last_update_date%type;
  --Lowest date supported by database as we need to handle null dates
  min_date PO_HEADERS_ALL.last_update_date%type := to_date('01/01/-4712','DD/MM/SYYYY');

  l_module_name CONSTANT VARCHAR2(100) := 'GET_LAST_UPDATE_DATE_FOR_DOC';
  d_module_base CONSTANT VARCHAR2(100) := PO_LOG.get_subprogram_base(g_log_head, l_module_name);
  d_pos NUMBER := 0;

BEGIN
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module_base); PO_LOG.proc_begin(d_module_base, 'p_doc_header_id', p_doc_header_id);
  END IF;
  d_pos := 10;
  select nvl(max(last_update_date), min_date) into header_last_update_date from po_headers_all where po_header_id = p_doc_header_id;
  d_pos := 20;
  select nvl(max(last_update_date), min_date) into line_last_update_date from  po_lines_all where po_header_id = p_doc_header_id;
  d_pos := 30;
  select nvl(max(last_update_date), min_date) into line_loc_last_update_date from po_line_locations_all where po_header_id = p_doc_header_id;
  d_pos := 40;
  select nvl(max(last_update_date), min_date)  into dist_last_update_date from  po_distributions_all where po_header_id = p_doc_header_id;
  d_pos := 50;
  doc_last_update_date := greatest( header_last_update_date
                                   ,line_last_update_date
                                   ,line_loc_last_update_date
                                   ,dist_last_update_date);

  IF (PO_LOG.d_stmt) THEN
    PO_LOG.stmt(d_module_base, d_pos, 'doc_last_update_date', doc_last_update_date);
  END IF;
  d_pos := 60;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module_base);
  END IF;
  return(doc_last_update_date);
EXCEPTION
  WHEN OTHERS THEN
    FND_MSG_PUB.add_exc_msg(g_pkg_name, l_module_name|| ':'||d_pos);
    IF (PO_LOG.d_exc) THEN
      PO_LOG.exc(d_module_base, d_pos, SQLCODE || SQLERRM);
    END IF;
    RAISE;
END;
--<HTML Agreements R12 End>

-- <ACHTML R12 START>
-------------------------------------------------------------------------------
--Start of Comments
--Name:  is_equal
--Pre-reqs:
--  None
--Modifies:
--  None
--Locks:
--  None
--Function:
--  Determines whether two numbers are equal. They are equal if they are both
--  null or have the same value.
--Parameters:
--IN:
--p_attribute_primary
--  The first number to compare with.
--p_attribute_secondary
--  The second number to compare with.
--RETURNS:
--  Boolean TRUE or FALSE indicating whether the two numbers are equal.
--Notes:
--  None
--Testing:
--  None
--End of Comments
-------------------------------------------------------------------------------
FUNCTION is_equal(
  p_attribute_primary NUMBER,
  p_attribute_secondary NUMBER
) RETURN BOOLEAN
IS
  l_is_equal                    BOOLEAN;
BEGIN
  IF ((p_attribute_primary IS NULL AND p_attribute_secondary IS NULL)
      OR p_attribute_primary = p_attribute_secondary)
  THEN
    l_is_equal := TRUE;
  ELSE
    l_is_equal := FALSE;
  END IF;

  RETURN l_is_equal;
EXCEPTION
  WHEN OTHERS THEN
    RETURN FALSE;
END is_equal;
-- <ACHTML R12 END>

-- <ACHTML R12 START>
-------------------------------------------------------------------------------
--Start of Comments
--Name:  is_equal
--Pre-reqs:
--  None
--Modifies:
--  None
--Locks:
--  None
--Function:
--  Determines whether two varchars are equal. They are equal if they are both
--  null or have the same value.
--Parameters:
--IN:
--p_attribute_primary
--  The first varchar to compare with.
--p_attribute_secondary
--  The second varchar to compare with.
--RETURNS:
--  Boolean TRUE or FALSE indicating whether the two varchars are equal.
--Notes:
--  None
--Testing:
--  None
--End of Comments
-------------------------------------------------------------------------------
FUNCTION is_equal(
  p_attribute_primary VARCHAR2,
  p_attribute_secondary VARCHAR2
) RETURN BOOLEAN
IS
  l_is_equal                    BOOLEAN;
BEGIN
  IF ((p_attribute_primary IS NULL AND p_attribute_secondary IS NULL)
      OR p_attribute_primary = p_attribute_secondary)
  THEN
    l_is_equal := TRUE;
  ELSE
    l_is_equal := FALSE;
  END IF;

  RETURN l_is_equal;
EXCEPTION
  WHEN OTHERS THEN
    RETURN FALSE;
END is_equal;
-- <ACHTML R12 END>

-- <ACHTML R12 START>
-------------------------------------------------------------------------------
--Start of Comments
--Name:  is_equal_minutes
--Pre-reqs:
--  None
--Modifies:
--  None
--Locks:
--  None
--Function:
--  Determines whether two dates are equal up to the minute. They are equal if
-- they are both null or have a difference of less than a minute.
--Parameters:
--IN:
--p_attribute_primary
--  The first date to compare with.
--p_attribute_secondary
--  The second date to compare with.
--RETURNS:
--  Boolean TRUE or FALSE indicating whether the two dates are equal up to the
--  minute.
--Notes:
--  None
--Testing:
--  None
--End of Comments
-------------------------------------------------------------------------------
FUNCTION is_equal_minutes(
  p_attribute_primary DATE,
  p_attribute_secondary DATE
) RETURN BOOLEAN
IS
  l_is_equal                    BOOLEAN;
BEGIN
  IF ((p_attribute_primary IS NULL AND p_attribute_secondary IS NULL)
      OR trunc(p_attribute_primary, 'MI') = trunc(p_attribute_secondary, 'MI'))
  THEN
    l_is_equal := TRUE;
  ELSE
    l_is_equal := FALSE;
  END IF;

  RETURN l_is_equal;
EXCEPTION
  WHEN OTHERS THEN
    RETURN FALSE;
END is_equal_minutes;
-- <ACHTML R12 END>

--Bug 11056822 Function to validate email address using regular expression
FUNCTION is_email_valid(p_email_address VARCHAR2) RETURN BOOLEAN
IS

BEGIN

  /* Bug 17525578 fix: Validating the special characters in the email address local part
     as per the RFC5322 specification.
  */
  IF REGEXP_LIKE(p_email_address, '^[A-Z0-9._%+-\''\&$`^|!#*~{}]+@[A-Z0-9.-]+\.[A-Zz0-9]+$','i') THEN
      RETURN TRUE;
  ELSE
      RETURN FALSE;
  END IF;

END is_email_valid;


END PO_CORE_S;

/

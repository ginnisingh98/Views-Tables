--------------------------------------------------------
--  DDL for Package Body RCV_SETUP_S
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RCV_SETUP_S" AS
/* $Header: RCVSTS1B.pls 115.1 2002/11/23 01:00:02 sbull ship $*/

/*===========================================================================

   FUNCTION NAME:	get_override_routing()

===========================================================================*/
FUNCTION get_override_routing  RETURN VARCHAR2 IS

/*
** Function will return Override Routing Option
** If Override Routing Option is NULL then
**   Default the Option to 'N'
** Function will be referencing a 'FND_PROFILE.GET' procedure defined
** by AOL grp . It will return the value of the PROFILE being asked for,
** or will return NULL value.
*/

x_progress VARCHAR2(3) := '';
option_value VARCHAR2(1);

BEGIN
   x_progress := '010';

   option_value := fnd_profile.value('OVERRIDE_ROUTING');

   if option_value is null then
     option_value := 'N';
   end if;

   RETURN(option_value);

   EXCEPTION
   WHEN OTHERS THEN
      po_message_s.sql_error('get_override_routing', x_progress,sqlcode);
   RAISE;

END get_override_routing;
/*===========================================================================

  FUNCTION NAME:	get_trx_proc_mode()

===========================================================================*/
FUNCTION get_trx_proc_mode RETURN VARCHAR2 IS

/*
** Function will return Receiving's Transaction Processor Mode (RCV_TP_MODE)
** If Transaction Processor Mode is NULL then
**   Default the Mode to 'ONLINE'
** Function will be referencing a 'FND_PROFILE.GET' procedure defined
** by AOL grp . It will return the value of the PROFILE being asked for,
** or will return NULL value.
*/

x_progress VARCHAR2(3) := '';
transaction_processor_value VARCHAR2(10);

BEGIN

   x_progress := '010';

   fnd_profile.get('RCV_TP_MODE',transaction_processor_value);

   if transaction_processor_value is null then
      transaction_processor_value := 'ONLINE';
   end if;

   RETURN(transaction_processor_value);

   EXCEPTION
   WHEN OTHERS THEN
      po_message_s.sql_error('get_trx_proc_mode', x_progress,sqlcode);
   RAISE;

END get_trx_proc_mode;
/*===========================================================================

  FUNCTION NAME:	get_print_traveller()

===========================================================================*/
FUNCTION get_print_traveller RETURN VARCHAR2 IS

/*
** Function will return Print Traveller Option
** If Print Traveller Option is NULL then
**   Default the Option to 'N'
** Function will be referencing a 'FND_PROFILE.GET' procedure defined
** by AOL grp . It will return the value of the PROFILE being asked for,
** or will return NULL value.
*/

x_progress VARCHAR2(3) := '';
option_value VARCHAR2(1);

BEGIN

   x_progress := '010';

   fnd_profile.get('PRINT_TRAVELLER',option_value);

   if option_value is null then
     option_value := 'N';
   end if;

   RETURN(option_value);

   EXCEPTION
   WHEN OTHERS THEN
      po_message_s.sql_error('get_print_traveller', x_progress,sqlcode);
   RAISE;

END get_print_traveller;
/*===========================================================================

  PROCEDURE NAME:	get_org_locator_control()

===========================================================================*/
PROCEDURE get_org_locator_control(x_org_id           IN NUMBER,
                                  x_locator_cc      OUT NOCOPY NUMBER,
                                  x_negative_inv_rc OUT NOCOPY NUMBER) IS

/*
** Procedure will return negative_inventory_receipt_code,
** Locator Control for the org
*/

x_progress      VARCHAR2(3) := '';

BEGIN

   x_progress := '010';

   select stock_locator_control_code,
          negative_inv_receipt_code
   into   x_locator_cc,
          x_negative_inv_rc
   FROM   mtl_parameters
   WHERE  organization_id = x_org_id;


   EXCEPTION
   WHEN NO_DATA_FOUND then
     null;

   WHEN OTHERS THEN
      po_message_s.sql_error('get_org_locator_control', x_progress,sqlcode);
   RAISE;

END get_org_locator_control;

/*===========================================================================

   PROCEDURE NAME:	get_receipt_number_info()

===========================================================================*/
PROCEDURE get_receipt_number_info(
				x_user_defined_rcpt_num_code OUT NOCOPY VARCHAR2,
                                x_manual_rcpt_num_type       OUT NOCOPY VARCHAR2,
                                x_manual_po_num_type         OUT NOCOPY VARCHAR2) IS

/*
**  Procedure gets the user defined receipt number code, manual receipt and
**  purchase order number types from po_system parameters.
*/

x_progress 			VARCHAR2(3) 	:= '';
x_currency_code                 VARCHAR2(30);
x_coa_id                        NUMBER;
x_po_encumberance_flag          VARCHAR2(1);
x_req_encumberance_flag         VARCHAR2(1);
x_sob_id                        NUMBER;
x_ship_to_location_id           NUMBER;
x_bill_to_location_id           NUMBER;
x_fob_lookup_code               VARCHAR2(30);
x_freight_terms_lookup_code     VARCHAR2(30);
x_terms_id                      NUMBER;
x_default_rate_type             VARCHAR2(30);
x_taxable_flag                  VARCHAR2(30);
x_receiving_flag                VARCHAR2(30);
x_enforce_buyer_name_flag       VARCHAR2(1);
x_enforce_buyer_auth_flag       VARCHAR2(1);
x_line_type_id                  NUMBER;
x_po_num_code                   VARCHAR2(30);
x_price_lookup_code             VARCHAR2(30);
x_invoice_close_tolerance       NUMBER;
x_receive_close_tolerance       NUMBER;
x_security_structure_id         NUMBER;
x_expense_accrual_code          VARCHAR2(30);
x_inv_org_id                    NUMBER;
x_rev_sort_ordering             NUMBER;
x_min_rel_amount                NUMBER;
x_notify_blanket_flag           VARCHAR2(1);
x_budgetary_control_flag        VARCHAR2(1);
x_user_defined_req_num_code     VARCHAR2(30);
x_rfq_required_flag             VARCHAR2(1);
x_manual_req_num_type           VARCHAR2(30);
x_enforce_full_lot_qty          VARCHAR2(30);
x_disposition_warning_flag      VARCHAR2(1);
x_reserve_at_completion_flag    VARCHAR2(1);
x_use_positions_flag            VARCHAR2(1);
x_default_quote_warning_delay   NUMBER;
x_inspection_required_flag      VARCHAR2(1);
x_user_defined_quote_num_code   VARCHAR2(30);
x_manual_quote_num_type         VARCHAR2(30);
x_user_defined_rfq_num_code     VARCHAR2(30);
x_manual_rfq_num_type           VARCHAR2(30);
x_ship_via_lookup_code          VARCHAR2(30);
x_qty_rcv_tolerance             NUMBER;

BEGIN

   x_progress := '010';

   PO_CORE_S.get_po_parameters(
		     x_currency_code,
                     x_coa_id      ,
                     x_po_encumberance_flag,
                     x_req_encumberance_flag,
                     x_sob_id ,
                     x_ship_to_location_id ,
                     x_bill_to_location_id ,
                     x_fob_lookup_code          ,
                     x_freight_terms_lookup_code ,
                     x_terms_id           ,
                     x_default_rate_type  ,
                     x_taxable_flag      ,
                     x_receiving_flag   ,
                     x_enforce_buyer_name_flag ,
                     x_enforce_buyer_auth_flag ,
                     x_line_type_id        ,
                     x_manual_po_num_type ,
                     x_po_num_code       ,
                     x_price_lookup_code  ,
                     x_invoice_close_tolerance ,
                     x_receive_close_tolerance ,
                     x_security_structure_id ,
                     x_expense_accrual_code ,
                     x_inv_org_id       ,
                     x_rev_sort_ordering ,
                     x_min_rel_amount   ,
                     x_notify_blanket_flag ,
                     x_budgetary_control_flag,
                     x_user_defined_req_num_code,
                     x_rfq_required_flag,
                     x_manual_req_num_type,
                     x_enforce_full_lot_qty,
                     x_disposition_warning_flag,
                     x_reserve_at_completion_flag,
                     x_user_defined_rcpt_num_code,
                     x_manual_rcpt_num_type ,
                     x_use_positions_flag,
                     x_default_quote_warning_delay,
                     x_inspection_required_flag  ,
                     x_user_defined_quote_num_code,
                     x_manual_quote_num_type     ,
                     x_user_defined_rfq_num_code,
                     x_manual_rfq_num_type     ,
                     x_ship_via_lookup_code   ,
                     x_qty_rcv_tolerance     );

   EXCEPTION
   WHEN OTHERS THEN
      po_message_s.sql_error('get_receipt_number_info', x_progress,sqlcode);
   RAISE;

END get_receipt_number_info;
/*===========================================================================

  FUNCTION NAME : get_chart_of_accounts

  DESCRIPTION   :

  CLIENT/SERVER : SERVER

  LIBRARY NAME  :

  OWNER         : SUBHAJIT PURKAYASTHA

  PARAMETERS    :

  ALGORITHM     : Retreive chart of accounts id from
                  financials_system_parameters and gl_sets_of_books table

  NOTES         :

===========================================================================*/
FUNCTION get_chart_of_accounts RETURN NUMBER is
  x_progress                      VARCHAR2(3) := NULL;
  x_currency_code                 VARCHAR2(30);
  x_coa_id                        NUMBER;
  x_po_encumberance_flag          VARCHAR2(1);
  x_req_encumberance_flag         VARCHAR2(1);
  x_sob_id                        NUMBER;
  x_ship_to_location_id           NUMBER;
  x_bill_to_location_id           NUMBER;
  x_fob_lookup_code               VARCHAR2(30);
  x_freight_terms_lookup_code     VARCHAR2(30);
  x_terms_id                      NUMBER;
  x_default_rate_type             VARCHAR2(30);
  x_taxable_flag                  VARCHAR2(30);
  x_receiving_flag                VARCHAR2(30);
  x_enforce_buyer_name_flag       VARCHAR2(1);
  x_enforce_buyer_auth_flag       VARCHAR2(1);
  x_line_type_id                  NUMBER;
  x_manual_po_num_type            VARCHAR2(30);
  x_po_num_code                   VARCHAR2(30);
  x_price_lookup_code             VARCHAR2(30);
  x_invoice_close_tolerance       NUMBER;
  x_receive_close_tolerance       NUMBER;
  x_security_structure_id         NUMBER;
  x_expense_accrual_code          VARCHAR2(30);
  x_inv_org_id                    NUMBER;
  x_rev_sort_ordering             NUMBER;
  x_min_rel_amount                NUMBER;
  x_notify_blanket_flag           VARCHAR2(1);
  x_budgetary_control_flag        VARCHAR2(1);
  x_user_defined_req_num_code     VARCHAR2(30);
  x_rfq_required_flag             VARCHAR2(1);
  x_manual_req_num_type           VARCHAR2(30);
  x_enforce_full_lot_qty          VARCHAR2(30);
  x_disposition_warning_flag      VARCHAR2(1);
  x_reserve_at_completion_flag    VARCHAR2(1);
  x_user_defined_rcpt_num_code    VARCHAR2(30);
  x_manual_rcpt_num_type          VARCHAR2(30);
  x_use_positions_flag            VARCHAR2(1);
  x_default_quote_warning_delay   NUMBER;
  x_inspection_required_flag      VARCHAR2(1);
  x_user_defined_quote_num_code   VARCHAR2(30);
  x_manual_quote_num_type         VARCHAR2(30);
  x_user_defined_rfq_num_code     VARCHAR2(30);
  x_manual_rfq_num_type           VARCHAR2(30);
  x_ship_via_lookup_code          VARCHAR2(30);
  x_qty_rcv_tolerance             NUMBER;

begin
  x_progress := 10;

  PO_CORE_S.get_po_parameters( x_currency_code,
                               x_coa_id      ,
                               x_po_encumberance_flag,
                               x_req_encumberance_flag,
                               x_sob_id ,
                               x_ship_to_location_id ,
                               x_bill_to_location_id ,
                               x_fob_lookup_code          ,
                               x_freight_terms_lookup_code ,
                               x_terms_id            ,
                               x_default_rate_type  ,
                               x_taxable_flag      ,
                               x_receiving_flag   ,
                               x_enforce_buyer_name_flag ,
                               x_enforce_buyer_auth_flag ,
                               x_line_type_id        ,
                               x_manual_po_num_type ,
                               x_po_num_code       ,
                               x_price_lookup_code  ,
                               x_invoice_close_tolerance ,
                               x_receive_close_tolerance ,
                               x_security_structure_id ,
                               x_expense_accrual_code ,
                               x_inv_org_id       ,
                               x_rev_sort_ordering ,
                               x_min_rel_amount   ,
                               x_notify_blanket_flag ,
                               x_budgetary_control_flag,
                               x_user_defined_req_num_code,
                               x_rfq_required_flag,
                               x_manual_req_num_type,
                               x_enforce_full_lot_qty,
                               x_disposition_warning_flag,
                               x_reserve_at_completion_flag,
                               x_user_defined_rcpt_num_code,
                               x_manual_rcpt_num_type ,
                               x_use_positions_flag,
                               x_default_quote_warning_delay,
                               x_inspection_required_flag  ,
                               x_user_defined_quote_num_code,
                               x_manual_quote_num_type     ,
                               x_user_defined_rfq_num_code,
                               x_manual_rfq_num_type     ,
                               x_ship_via_lookup_code   ,
                               x_qty_rcv_tolerance     );

  RETURN(x_coa_id);

  EXCEPTION
  WHEN OTHERS THEN
    po_message_s.sql_error('get_chart_of_accounts', x_progress,sqlcode);
    RAISE;

end get_chart_of_accounts;

END RCV_SETUP_S;

/

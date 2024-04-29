--------------------------------------------------------
--  DDL for Package Body RCV_SETUP_S2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RCV_SETUP_S2" AS
/* $Header: RCVSTS2B.pls 120.2 2006/06/19 07:38:40 rahujain noship $*/

--Bug 5049614: Creted function get_org_name.
/*===========================================================================

  FUNCTION NAME:        get_org_name

===========================================================================*/

FUNCTION get_org_name(p_org_id IN NUMBER) RETURN VARCHAR2
IS
  x_org_name VARCHAR2(240);
Begin
  --Bug 5217526. Fetch Org Name from HR_ORGANIZATION_UNITS
  SELECT ood.name
  INTO   x_org_name
  FROM   HR_ORGANIZATION_UNITS ood
  WHERE  ood.organization_id = p_org_id;

  return (x_org_name);

EXCEPTION

    WHEN OTHERS THEN
            return (NULL);

END get_org_name;

/*===========================================================================

  FUNCTION NAME:	get_receiving_flags

===========================================================================*/
PROCEDURE get_receiving_flags(x_org_id  IN  NUMBER,
			     x_blind   OUT NOCOPY VARCHAR2,
                             x_express OUT NOCOPY VARCHAR2,
                             x_cascade OUT NOCOPY VARCHAR2,
                             x_unordered OUT NOCOPY VARCHAR2) IS

/*
** Function will return the Receiving Parameter Value for Blind Receiving
** Flag.
*/

x_progress VARCHAR2(3) := '';
x_flag VARCHAR2(1);

BEGIN

   x_progress := '010';

   SELECT BLIND_RECEIVING_FLAG , ALLOW_EXPRESS_DELIVERY_FLAG,
          ALLOW_CASCADE_TRANSACTIONS, ALLOW_UNORDERED_RECEIPTS_FLAG
   INTO   x_blind, x_express, x_cascade, x_unordered
   FROM   rcv_parameters
   WHERE  organization_id = x_org_id;

-- Bug 5049614 : Added the following IF condition to raise no_data_found
-- exception.
   IF (SQL%NOTFOUND) THEN
     RAISE NO_DATA_FOUND;
   END IF;

   EXCEPTION

-- Bug 5049614 : Added the no_data_found exception.

     WHEN NO_DATA_FOUND THEN
       po_message_s.app_error('RCV_NO_OPTION','ORG',get_org_name(x_org_id));
       RAISE;

     WHEN OTHERS THEN
       po_message_s.sql_error('get_receiving_flags', x_progress,sqlcode);
       RAISE;

END get_receiving_flags;

/*===========================================================================

  PROCEDURE NAME:	get_startup_values()

===========================================================================*/

PROCEDURE get_startup_values(x_sob_id            IN OUT NOCOPY NUMBER,
                             x_org_id            IN OUT NOCOPY NUMBER,
                             x_org_name             OUT NOCOPY VARCHAR2,
                             x_ussgl_value          OUT NOCOPY VARCHAR2 ,
                             x_override_routing     OUT NOCOPY VARCHAR2,
                             x_transaction_mode     OUT NOCOPY VARCHAR2,
                             x_receipt_traveller    OUT NOCOPY VARCHAR2,
                             x_period_name          OUT NOCOPY VARCHAR2,
                             x_gl_date              OUT NOCOPY DATE,
                             x_category_set_id      OUT NOCOPY NUMBER,
                             x_structure_id         OUT NOCOPY NUMBER,
                             x_receipt_num_code     OUT NOCOPY VARCHAR2,
                             x_receipt_num_type     OUT NOCOPY VARCHAR2,
                             x_po_num_type          OUT NOCOPY VARCHAR2,
                             x_allow_express        OUT NOCOPY VARCHAR2,
                             x_allow_cascade        OUT NOCOPY VARCHAR2,
                             x_user_id              OUT NOCOPY NUMBER,
                             x_logonid              OUT NOCOPY NUMBER,
                             x_creation_date        OUT NOCOPY DATE,
                             x_update_date          OUT NOCOPY DATE,
                             x_coa_id               OUT NOCOPY NUMBER,
                             x_org_locator_control  OUT NOCOPY NUMBER,
                             x_negative_inv_receipt_code OUT NOCOPY NUMBER,
                             x_gl_set_of_bks_id     OUT NOCOPY VARCHAR2,
                             x_blind_Receiving_flag OUT NOCOPY VARCHAR2,
			     x_allow_unordered      OUT NOCOPY VARCHAR2 ) is

/*
**  Procedure calls the above hidden procedures within RCV_SETUP_S to get
**  startup values.
*/

x_progress VARCHAR2(3) := '';

BEGIN
   x_progress := 5;
   /*
   ** This call is junk.  Should never be used since the org and sob id's
   ** are passed in.  Just need to get the org_name
   */

   /*   po_core_s.get_org_sob(x_org_id,x_org_name,x_sob_id); */

   select  organization_name
   into    x_org_name
   FROM   org_organization_definitions
   WHERE  organization_id = x_org_id ;

   x_progress := 10;
   x_ussgl_value := po_core_s.get_ussgl_option;

   x_progress := '015';
   x_override_routing := RCV_SETUP_S.get_override_routing;


   x_progress := '020';
   x_transaction_mode := RCV_SETUP_S.get_trx_proc_mode;


   x_progress := '030';
   x_receipt_traveller := RCV_SETUP_S.get_print_traveller;


   x_progress := '040';

   --<R12 MOAC START>
   /* Commented the following calls that are operating unit sensitive */
   /*
   RCV_SETUP_S.get_receipt_number_info(x_receipt_num_code,
                                       x_receipt_num_type,
                                       x_po_num_type);

   x_progress := '080';
   x_coa_id := RCV_SETUP_S.get_chart_of_accounts;

   */
   --<R12 MOAC END>

   x_progress := 90;
   PO_CORE_S.get_period_name(x_sob_id,
                             x_period_name,
                             x_gl_date );

   x_progress := 100;
   po_core_s.get_item_category_structure(x_category_set_id,x_structure_id);

   x_progress := 110;
   po_core_s.get_global_values(x_user_id,x_logonid,x_update_date,x_creation_date);

   x_progress := 120;
   RCV_SETUP_S.get_org_locator_control(x_org_id,
                                       x_org_locator_control,
                                       x_negative_inv_receipt_code);

   x_progress := '125';
   x_gl_set_of_bks_id := PO_CORE_S.get_gl_set_of_bks_id;

   x_progress := '130';
   RCV_SETUP_S2.get_receiving_flags (
       x_org_id,
       x_blind_receiving_flag,
       x_allow_express,
       x_allow_cascade,
       x_allow_unordered);

   EXCEPTION
   WHEN OTHERS THEN
      po_message_s.sql_error('get_startup_values', x_progress,sqlcode);
   RAISE;

END get_startup_values;

END RCV_SETUP_S2;

/

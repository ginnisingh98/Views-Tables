--------------------------------------------------------
--  DDL for Package Body RCV_OE_RMA_RECEIPTS_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RCV_OE_RMA_RECEIPTS_SV" AS
/* $Header: RCVRMARB.pls 120.0.12000000.2 2007/04/10 06:36:20 kagupta ship $*/


/*===========================================================================

  FUNCTION NAME:	rma_val_receipt_date_tolerance()

  DESCRIPTION:

		Checks that the receipt date is within the receipt date
		tolerance.

  PARAMETERS:

  Parameter	  IN/OUT   Datatype	Description
  --------------- -------- ------------ --------------------------------------

  x_oe_order_header_id IN  NUMBER	RMA header id

  x_oe_order_line_id   IN  NUMBER	RMA line id

  x_receipt_date       IN  DATE		Receipt Date to be validated.

  RETURN VALUE:	    TRUE if receipt date is within tolerance
		    FALSE otherwise.

  DESIGN REFERENCES:	RCVRCERC.dd x
			RCVTXECO.dd _/
			RCVTXERE.dd x
			RCVTXERT.dd x

  CHANGE HISTORY:
===========================================================================*/



FUNCTION rma_val_receipt_date_tolerance (x_oe_order_header_id   IN NUMBER,
				     	 x_oe_order_line_id     IN NUMBER,
				     	 x_receipt_date         IN DATE) RETURN BOOLEAN IS

/*
**  Function determines if the receipt date falls within the receipt date
**  tolerance window.  If it does, the function returns a value of TRUE,
**  otherwise it returns a value of FALSE.
*/

x_progress 		   VARCHAR2(3) := '001';
x_earliest_acceptable_date DATE := sysdate;
x_latest_acceptable_date   DATE := sysdate;

BEGIN

   x_progress := '010';

   SELECT EARLIEST_ACCEPTABLE_DATE,
	  LATEST_ACCEPTABLE_DATE
   INTO   x_earliest_acceptable_date,
	  x_latest_acceptable_date
   FROM   oe_order_lines_all --1561179
   WHERE  header_id = x_oe_order_header_id
   AND    line_id = x_oe_order_line_id;

   x_progress := '020';

   /* bug 1362426 : added 'trunc' to all the dates because the dates include time and
      this was causing the condition to always return false */

   /* Bug 3543872 : If either of or both earliest_acceptable_date and latest_acceptable_date
        were null and the receipt date was other than sysdate we were always returning
        false. So modified the if clause to have proper validations on the receipt date
        tolerance.

      The validation works as follows:

      earliest_acceptable_date  latest_acceptable_date       return true if

         null                     null                 return true
         null                   not null               receipt date <= latest_acceptable_date
       not null                   null                 receipt_date >= earliest_acceptable_date
       not null                 not null               receipt_date between earliest_acceptable_
                                                         date and latest_acceptable_date.

   */


   IF   (trunc(x_earliest_acceptable_date) is null and trunc(x_latest_acceptable_date) is null)
     OR (trunc(x_earliest_acceptable_date) is null
         and (nvl(trunc(x_receipt_date), trunc(sysdate)) <= nvl(trunc(x_latest_acceptable_date),trunc(sysdate))))
     OR (trunc(x_latest_acceptable_date) is null
         and (nvl(trunc(x_receipt_date), trunc(sysdate)) >= nvl(trunc(x_earliest_acceptable_date),trunc(sysdate))))
     OR (  (nvl(trunc(x_receipt_date), trunc(sysdate)) >= nvl(trunc(x_earliest_acceptable_date),trunc(sysdate)))
 	 and
       (nvl(trunc(x_receipt_date), trunc(sysdate)) <= nvl(trunc(x_latest_acceptable_date),trunc(sysdate)))  )
    THEN
	 return (true);
    ELSE
	 return (false);
   END IF;

   EXCEPTION
   WHEN OTHERS THEN
      po_message_s.sql_error('rma_val_receipt_date_tolerance', x_progress,sqlcode);
   RAISE;

END rma_val_receipt_date_tolerance;

/*===========================================================================

  PROCEDURE NAME:       rma_get_org_info()

===========================================================================*/

/* <R12 MOAC START>
**   Changed the signature of the following procedure rma_get_org_info.
**   The procedure now has only 2 parameters.
**   The procedure returns the org_id for a given oe_order_line_id.
*/

PROCEDURE rma_get_org_info (x_new_org_id        OUT NOCOPY NUMBER,
                            X_oe_order_line_id  IN NUMBER) IS
BEGIN

/* For Bug 5958418 Getting the org information from OM table rather than from work flow tables.
	select number_value
        into x_new_org_id
        from wf_item_attribute_values
        where item_key = to_char(X_oe_order_line_id)
        and item_type='OEOL'
        and name='ORG_ID';
*/
        select org_id
        into x_new_org_id
        from oe_order_lines_all
        where line_id = X_oe_order_line_id;

END rma_get_org_info;

/* <R12 MOAC END> */

END RCV_OE_RMA_RECEIPTS_SV;

/

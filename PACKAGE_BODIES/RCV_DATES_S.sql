--------------------------------------------------------
--  DDL for Package Body RCV_DATES_S
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RCV_DATES_S" AS
/* $Header: RCVTXDAB.pls 120.0.12010000.2 2008/08/04 08:42:42 rramasam ship $*/

/*===========================================================================

  FUNCTION NAME:	val_trx_date()

===========================================================================*/

FUNCTION val_trx_date(x_trx_date           IN DATE,
		      x_trx_type	    IN VARCHAR2,
		      x_parent_trx_date     IN OUT NOCOPY DATE,
		      x_line_loc_id	    IN NUMBER,
		      x_ship_line_id        IN NUMBER,
		      x_parent_trx_id       IN NUMBER,
		      x_sob_id		    IN NUMBER,
		      x_org_id		    IN NUMBER,
		      x_receipt_source_code IN VARCHAR2)RETURN BOOLEAN IS

/*
**  Function validates the transaction date:
**
**  1) Checks if the transaction date is less than or equal to the system date.
**
**  2) If the transaction type is 'RECEIVE' or 'MATCH' for a vendor, then it
**     calls val_receipt_date_tolerance to check if the transaction date falls
**     within the receipt date tolerance.
**
**  3) Calls PO_DATES_S.val_open_period to check if transaction date is in an
**     open GL period.
**
**  4) Calls PO_DATES_S.val_open_period to first check if inventory is
**     installed.  If so, it checks that the transaction date is in an open
**     inventory period.
**
**  5) Calls PO_DATES_S.val_open_period to first check if purchasing is
**     installed.  If so, it checks that the transaction date is in an open
**     purchasing period.
**
**  6) If the transaction type is not 'RECEIVE' or 'UNORDERED' then it checks
**     if the parent transaction date is null.  If it is then get the parent
**     transaction date from rcv_transactions using the parent_transaction_id.
**     Then check that the parent transaction date is less than or equal to the
**     transaction date.
**
**  7) If the transaction type is 'RECEIVE' internally, then gets the shipped
**     date from rcv_shipment_headers using the shipment_line_id.  Then checks
**     if the transaction date is greater than or equal to the shipped date.
**
**  If any one of these checks fail, the function returns a value of FALSE
**  along with the appropriate error message.  If all are okay, it returns a
**  value of TRUE.
*/

x_progress     	VARCHAR2(3)                 := NULL;
x_shipped_date 	DATE                        := NULL;
x_opm_orgn	sy_orgn_mst.orgn_Code%type      := NULL;
x_whse_code 	ic_whse_mst.whse_code%type  := NULL;
v_retval	NUMBER	    := 0;

BEGIN

--  1) Transaction Date must be greater than the system date

   x_progress := '010';

   IF (x_trx_date > sysdate) THEN

      po_message_s.app_error('RCV_TRX_FUTURE_DATE_NA');

   END IF;


--  2) Transaction Date must fall within Early/Late receipt date tolerance

   x_progress := '020';

   IF x_trx_type IN ('RECEIVE','MATCH') AND x_line_loc_id IS NOT NULL THEN

      IF NOT (RCV_DATES_S.val_receipt_date_tolerance(x_line_loc_id,
						     x_trx_date)) THEN
        /* BUG 704593
         * The following app_error raises an exception, it's wrong for
         * the scenario when the days_exception_code is only 'warning'.
         * exception should be raised in the procedure which calls this
         * function.
         */
	--po_message_s.app_error('RCV_ALL_DATE_OUT_OF_RANGE');
        RETURN (FALSE);

      END IF;

   END IF;


--  3) Transaction Date must be in an open GL period

   x_progress := '030';

   IF NOT (PO_DATES_S.val_open_period(
        inv_le_timezone_pub.get_le_day_for_inv_org(x_trx_date, x_org_id),
        x_sob_id,
        'SQLGL',
	    x_org_id)) THEN

         /* Bug# 2235828 */
	 /* po_message_s.app_error('PO_PO_ENTER_OPEN_GL_DATE'); */
         po_message_s.app_error('PO_CNL_NO_PERIOD');

   END IF;


--  4) Transaction Date must be in open accounting period if INV is installed

   x_progress := '040';
   /* INVCONV BEGIN PBAMB */
	/*Bug# 1548597 check if for this proess receipt the OPM inventory calendars are open*/
   	/*If PO_GML_DB_COMMON.CHECK_PROCESS_ORG(x_org_id) = 'Y'  then
   		Select 	whse_code,orgn_code
   		into 	x_whse_code,x_opm_orgn
   		from 	ic_whse_mst
		where 	mtl_organization_id = x_org_id;

		v_retval := GMICCAL.trans_date_validate(
        inv_le_timezone_pub.get_le_day_for_inv_org(x_trx_date, x_org_id),
        x_opm_orgn,
        x_whse_code);

		--IF v_retval = -21 THEN /* Fiscal Yr and Fiscal Yr beginning date  not found. */
          	--	po_message_s.app_error('INVCAL_FISCALYR_ERR');

       		--ELSIF v_retval = -22 THEN /* Period end date and close indicator not found. */
          	--	po_message_s.app_error('INVCAL_PERIOD_ERR');

	       --	ELSIF v_retval = -23 THEN /* Date is within a closed Inventory calendar period */
        	--	po_message_s.app_error('INVCAL_CLOSED_PERIOD_ERR');

       		--ELSIF v_retval = -24 THEN /*  Company Code not found. */
          	--	po_message_s.app_error('INVCAL_INVALIDCO_ERR');

		--ELSIF  v_retval = -25 THEN /* Warehouse has been closed for the period */
          	--	po_message_s.app_error('INVCAL_WHSE_CLOSED_ERR');

		--ELSIF  v_retval = -26 THEN /* Transaction not passed in as a parameter.*/
          	--	po_message_s.app_error('INVCAL_TRANS_DATE_ERR');

       		--ELSIF  v_retval = -27 THEN /* Organization code not passed as a parameter.*/
          	--	po_message_s.app_error('INVCAL_INVALIDORGN_ERR');

        	--ELSIF  v_retval = -28 THEN /* Warehouse code not passed as a parameter.*/
          	--	po_message_s.app_error('INVCAL_WHSEPARM_ERR');

       		--ELSIF  v_retval = -29 THEN /* Warehouse code is not found. */
		--        po_message_s.app_error('INVCAL_WHSE_ERR');

       		--ELSIF v_retval < -29 THEN /* Log a general message */
          	--	po_message_s.app_error('INVCAL_GENL_ERR');
       		--END IF;

	--else

   		IF NOT (PO_DATES_S.val_open_period(
            inv_le_timezone_pub.get_le_day_for_inv_org(x_trx_date, x_org_id),
            x_sob_id,
            'INV',
            x_org_id)) THEN

			po_message_s.app_error('PO_INV_NO_OPEN_PERIOD');

   		END IF;
   	--end if;


--  5) Transaction Date must be in an open PO period

   x_progress := '050';

   IF NOT (PO_DATES_S.val_open_period(
        inv_le_timezone_pub.get_le_day_for_inv_org(x_trx_date, x_org_id),
        x_sob_id,
        'PO',
        x_org_id)) THEN

      po_message_s.app_error('PO_PO_ENTER_OPEN_GL_DATE');

   END IF;

/* Bug#3308963 Added the following assignment statement for assigning the value
** of x_trx_date to the global variable after successfull validation of
** Purchasing open period.
*/

   /* Bug 3622309.
    * Commenting out the change below since this is causing problems.
   PO_DATES_S.x_last_txn_date := x_trx_date ;
   */



--  6) Transaction Date must be > parent transaction date

   x_progress := '060';

   IF (x_trx_type NOT IN ('RECEIVE','UNORDERED') AND
       x_parent_trx_date is null) THEN

     /* Bug 6957731
     ** Time stamp of transaction date was not considered during validation.
     ** Replaced Trunc(transaction_date) with transaction_date.
     */

      SELECT transaction_date
      INTO   x_parent_trx_date
      FROM   rcv_transactions
      WHERE  transaction_id = x_parent_trx_id;

   END IF;

   x_progress := '070';

   IF x_trx_type NOT IN ('RECEIVE','UNORDERED') THEN

      IF (x_parent_trx_date > x_trx_date) THEN

         po_message_s.app_error('RCV_TRX_ENTER_DT_GT_PARENT_DT');

      END IF;

   END IF;


/* This must be checked at the line level. You cannot validate this here
--  7) Transaction Date must be >= shipped date for internal receipts

   x_progress := '80';

   IF x_trx_type = 'RECEIVE' and x_ship_line_id IS NOT NULL and
      x_receipt_source_code = 'INTERNAL' THEN

      SELECT trunc(rsh.shipped_date)
      INTO   x_shipped_date
      FROM   rcv_shipment_headers rsh,
             rcv_shipment_lines   rsl
      WHERE  rsh.shipment_header_id = rsl.shipment_header_id
      AND    rsh.organization_id = x_org_id;

      IF (x_trx_date < x_shipped_date) THEN

         po_message_s.app_error('RCV_ERC_SHIP_DATE_GT_RCV_DATE');

      END IF;

   END IF;
*/

   RETURN(TRUE);

   EXCEPTION
   WHEN OTHERS THEN
      po_message_s.sql_error('val_trx_date', x_progress, sqlcode);
   RAISE;

END val_trx_date;

/*===========================================================================

  FUNCTION NAME:	val_receipt_date_tolerance()

===========================================================================*/

FUNCTION val_receipt_date_tolerance(x_line_loc_id  IN NUMBER,
				    x_receipt_date IN DATE)RETURN BOOLEAN IS

/*
**  Function determines if the receipt date falls within the receipt date
**  tolerance window.  If it does, the function returns a value of TRUE,
**  otherwise it returns a value of FALSE.
*/

x_progress VARCHAR2(3) := NULL;
x_days_early_receipt_allowed NUMBER;
x_days_late_receipt_allowed  NUMBER;
x_promised_date DATE;
x_need_by_date  DATE;
days_diff NUMBER := 0;

BEGIN

   x_progress := '010';

   SELECT days_early_receipt_allowed, days_late_receipt_allowed,
	  promised_date, need_by_date
   INTO   x_days_early_receipt_allowed, x_days_late_receipt_allowed,
	  x_promised_date, x_need_by_date
   FROM   po_line_locations
   WHERE  line_location_id = x_line_loc_id;

   days_diff := x_receipt_date -

	        nvl(nvl(x_promised_date,x_need_by_date),x_receipt_date);

   IF (days_diff < 0) THEN

      IF x_days_early_receipt_allowed < ABS(days_diff) THEN
	 RETURN (FALSE);
      ELSE
	 RETURN (TRUE);
      END IF;

   ELSE

      IF x_days_late_receipt_allowed < days_diff THEN
	 RETURN (FALSE);
      ELSE
	 RETURN (TRUE);
      END IF;

   END IF;

   EXCEPTION
   WHEN OTHERS THEN
      po_message_s.sql_error('val_receipt_date_tolerance', x_progress,sqlcode);
   RAISE;

END val_receipt_date_tolerance;

END RCV_DATES_S;

/

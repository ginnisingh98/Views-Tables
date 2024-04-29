--------------------------------------------------------
--  DDL for Package Body RCV_EXPRESS_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RCV_EXPRESS_SV" AS
/* $Header: RCVTXEXB.pls 120.9.12010000.14 2014/02/12 10:49:41 smididud ship $*/

/** Bug:5855096
     Modified the Signature of the function val_rcv_trx_interface to
     pass the value of X_txn_from_web and X_txn_from_wf which tells
     whether the call is made from iProcurement page.
     Reason:
     -------
     It is not possible to find out whether the call is made from
     iProcurement page in val_rcv_trx_interface(), as the rti.transaction_type
     is modifed in val_express_transactions() and set_trx_defaults()
     before calling val_rcv_trx_interface().
 */
FUNCTION val_rcv_trx_interface (
rcv_trx            IN OUT NOCOPY rcv_transactions_interface%ROWTYPE,
X_txn_from_web     IN BOOLEAN,--Bug 5855096
X_txn_from_wf      IN BOOLEAN)--Bug 5855096
RETURN BOOLEAN;

PROCEDURE set_trx_defaults (
rcv_trx            IN OUT NOCOPY rcv_transactions_interface%ROWTYPE);

PROCEDURE print_record (
rcv_trx IN OUT NOCOPY rcv_transactions_interface%ROWTYPE);

PROCEDURE  insert_interface_errors ( rcv_trx IN OUT NOCOPY rcv_transactions_interface%ROWTYPE,
                                      X_column_name IN VARCHAR2,
                                      X_err_message IN VARCHAR2);

/*===========================================================================

  PROCEDURE NAME:	val_express_transactions

===========================================================================*/

PROCEDURE val_express_transactions (X_group_id       IN  NUMBER,
				    X_rows_succeeded OUT NOCOPY NUMBER,
				    X_rows_failed    OUT NOCOPY NUMBER) IS

CURSOR  rcv_get_interface_rows IS
SELECT  *
FROM    rcv_transactions_interface
WHERE   group_id = X_group_id
AND     transaction_status_code in ( 'EXPRESS', 'CONFIRM' )
ORDER BY interface_transaction_id;

rcv_trx                  rcv_transactions_interface%ROWTYPE;
record_num               NUMBER  := 0;
rows_succeeded           NUMBER  := 0;
rows_failed              NUMBER  := 0;
delivery_rows_succeeded  NUMBER  := 0;
delivery_rows_failed     NUMBER  := 0;
done 		         BOOLEAN := FALSE;
transaction_ok           BOOLEAN := FALSE;
x_first_error		 BOOLEAN := TRUE;
X_progress 	         VARCHAR2(4) := '000';
x_column_name		 po_interface_errors.column_name%type;
x_message_text		 fnd_new_messages.message_text%type;
x_message_name           varchar2(30);
X_txn_from_web           BOOLEAN := FALSE;
X_txn_from_wf            BOOLEAN := FALSE;
X_language_code          varchar2(4);
X_language_id            number;
x_output_message	 fnd_new_messages.message_text%type := null;

l_matching_basis         po_lines.matching_basis%type ;
/* The following variables were added for bug 2734333 */
x_base_currency_code     varchar2(30) := ''; -- Bug 2734333
x_match_option           varchar2(25);
v_rateDate               DATE;
v_rate                   NUMBER;
v_sobid                  NUMBER;
--Bugfix5213454: Variable declaration for QA API.
l_qa_eval_result              VARCHAR2(10);
l_qa_return_status            VARCHAR2(5);
l_qa_msg_count                NUMBER;
l_qa_msg_data                 VARCHAR2(2400);

/*
** The get interface rows cursor is used to select all the rows that
** were inserted during the express transaction from the form.  We will
** will loop through each of these rows to ensure that the row can
** be transacted.  For now the only feedback that the user will receive
** is how many rows passed validation and how many failed.  We should
** add some kind of notification to this so the user can see which records
** had problems.
**
** This function assumes that if you are performing an
** express direct receipt or an express delivery that you will insert all
** the distributions into the transaction_interface table.
**
** The process is read a record into memory, set defaults in memory,
** validate trx, if transaction passes validation then write it out
** to database with all the defaults and updated values, otherwise
** delete it from the interface.
*/

/* Modified this procedure to validate input from the Receive Orders
** Web Page.
*/

BEGIN

   X_progress := '010';

   /* Open the cursor for the fetch */
   OPEN rcv_get_interface_rows;

   /*
   ** Loop:
   **   Select the rows from the rcv_transactions_interface table
   **   that will be transacted with this group_id
   */
   X_progress := '020';

   LOOP

      record_num := record_num + 1;

      FETCH rcv_get_interface_rows INTO
         rcv_trx;

      EXIT WHEN rcv_get_interface_rows%NOTFOUND;

      /*
      ** DEBUG: Need a lock row routine for both the shipment line and
      ** the line location.  Will locking here collide with a potention
      ** lock in the form.
      ** Lock the shipment to prevent two users receiving against the
      ** PO at the same time. If rows are not locked it is possible to
      ** over-receive the PO.
      */
      X_progress := '030';

      -- po_line_locations_sv.lock_row (line_location_id);
      /* Bug 4773978: Added the following code for logging error messages
                      in PO_INTERFACE_ERRORS table. */
      RCV_ERROR_PKG.initialize(rcv_trx.transaction_type,
                               rcv_trx.group_id,
                               rcv_trx.header_interface_id,
                               rcv_trx.interface_transaction_id);
       /* Bug 4773978 end */

      /*
      ** Make sure that this is a express transaction that you're
      ** processing
      */
      IF (rcv_trx.transaction_type IN ('EXPRESS RECEIPT','EXPRESS DIRECT','EXPRESS DELIVER','CONFIRM RECEIPT',
				       'CONFIRM RECEIPT(WF)')) then

           /*
           ** set any default values that might be required for this receipt
           ** transaction. This should not be done if the transaction type
           ** is CONFIRM RECEIPT as the quantity and uom would have been
           ** entered by the user.We should not be defaulting in such a
           ** case.
           */
           X_progress := '040';

	   if (rcv_trx.transaction_type = 'CONFIRM RECEIPT') then
		x_txn_from_web := TRUE;
	   else
		x_txn_from_web := FALSE;
	   end if;

           -- bug 513848
           -- Set flag to indicate from workflow
 	   if (rcv_trx.transaction_type = 'CONFIRM RECEIPT(WF)') then
		x_txn_from_wf := TRUE;
	   else
		x_txn_from_wf := FALSE;
	   end if;


	   /* FPJ SERVICES.
	    * We support services only through ROI and IP. This part of
	    * the code should work only when it comes through IP. Through
	    * forms we cannot receive Service PO shipments. From IP, we
	    * will have po_line_id. We dont need to call set_trx_defaults
	    * and val_rcv_trx_interface for service based amounts since
	    * they are already done in IP.
	   */
	    /* R12 Complex work.
	     * We get matching_basis from the shipment level and not
	     * from line level.
	    */
	    begin
		    select nvl(matching_basis,'QUANTITY')
		    into l_matching_basis
		    from po_line_locations
		    where line_location_id =rcv_trx.po_line_location_id;
	    exception
             /* Bug 3417961 : If the receipt_source_code is not PO then the above sql
	             will fetch null in l_matching_basis. This will cause set_trx_defaults()
		     and val_rcv_trx_interface() not getting called for RMA, Internal Order
		     and Intransit shipment Receipts. Defaulting l_matching_basis to 'QUANTITY'
	     */

		when no_data_found then
		     l_matching_basis := 'QUANTITY';
	    end;

            If (l_matching_basis <> 'AMOUNT') then --{

		   rcv_express_sv.set_trx_defaults (rcv_trx);
            else
		   IF (rcv_trx.transaction_type = 'EXPRESS RECEIPT') THEN

		      rcv_trx.transaction_type   := 'RECEIVE';
		      rcv_trx.auto_transact_code := 'RECEIVE';

		   ELSIF (rcv_trx.transaction_type = 'EXPRESS DIRECT') THEN

		      rcv_trx.transaction_type   := 'RECEIVE';
		      rcv_trx.auto_transact_code := 'DELIVER';

		   ELSIF (rcv_trx.transaction_type = 'EXPRESS DELIVER') THEN

		      rcv_trx.transaction_type   := 'DELIVER';
		      rcv_trx.auto_transact_code := '';

		   ELSIF (rcv_trx.transaction_type = 'CONFIRM RECEIPT') THEN

		      rcv_trx.transaction_type   := 'RECEIVE';
		      rcv_trx.auto_transact_code := 'DELIVER';
		      X_txn_from_web             := TRUE;

		   ELSIF (rcv_trx.transaction_type = 'CONFIRM RECEIPT(WF)') THEN

		      rcv_trx.transaction_type   := 'RECEIVE';
		      rcv_trx.auto_transact_code := 'DELIVER';
		      X_txn_from_web		 := FALSE;

		      -- bug 513848
		      X_txn_from_wf              := TRUE;

		   END IF;

		   rcv_trx.processing_status_code := 'PENDING';
		   rcv_trx.transaction_status_code := 'PENDING';
	end if; --}

     /* Bug 13864622 set the interface_source_code to IP for the receiving txns from iProcurement or workflow. */

     IF ( X_txn_from_wf OR  X_txn_from_web) THEN
        rcv_trx.interface_source_code := 'IP' ;

     END IF;

     /* End of Bug 13864622 */


          /* Bug 2734333 - Getting the currency conversion rate for the receipt creation date when the match option is Receipt */

           IF (rcv_trx.source_document_code = 'PO') THEN

           /* Added the following pl/sql block to get the functional currency - Bug 2734333 */

           /* <R12 MOAC START>
           **   Moved the following Begin-End block into the LOOP and
           **   added the predicate for Org_id in the where clause
           */

               BEGIN
                    SELECT GSB.currency_code,FSP.set_of_books_id
                    INTO   x_base_currency_code,
                           v_sobid
                    FROM   FINANCIALS_SYSTEM_PARAMETERS FSP,
                           GL_SETS_OF_BOOKS GSB
                    WHERE  FSP.set_of_books_id = GSB.set_of_books_id
                       AND FSP.org_id = rcv_trx.org_id;
               EXCEPTION
                   WHEN OTHERS THEN
                       RAISE;
               END;

           --<R12 MOAC END>

              IF (rcv_trx.currency_code <> nvl(x_base_currency_code,rcv_trx.currency_code)) then

                 /* getting the match option from the PO */

                    select match_option
                    into x_match_option
                    from po_line_locations
                    where line_location_id = rcv_trx.po_line_location_id;

               /* bug 4356092 - currency conversion rate code was incorrect */
               IF (x_match_option = 'R') THEN
                  /* For enter receipts form */
                  IF (rcv_trx.parent_transaction_id IS NULL) THEN
                     IF (rcv_trx.currency_conversion_type = 'User') THEN
                        rcv_trx.currency_conversion_date  := rcv_trx.creation_date;
                     ELSE --rcv_trx.currency_converstion_type <> 'User'
                        BEGIN
                           /* attempt to to get rate at creation time */
                           v_rate                            := gl_currency_api.get_rate(v_sobid,
                                                                                         rcv_trx.currency_code,
                                                                                         rcv_trx.creation_date,
                                                                                         rcv_trx.currency_conversion_type
                                                                                        );
                           /* if successfull then set the currency_conversion_date to the date used above */
                           rcv_trx.currency_conversion_date  := rcv_trx.creation_date;
                        EXCEPTION
                           WHEN OTHERS THEN
     /* Bug 4773978: Removed the code to get currency conversion rate using currency conversion date
                     defined in PO, if currency conversion rate is not defined for the receipt date.
                     We have to error out the transaction in PO_INTERFACE_ERRORS table for the POs created
                     with invoice match set to 'Receipts', if currency conversion rate is not defined for
                     the receipt date. */
                              v_rate  := fnd_api.g_miss_num;
     /* Bug 4773978 end */
                        END;

                        rcv_trx.currency_conversion_rate  := v_rate;
                     END IF; -- conversion type is not user
                  ELSE
                     /* For receiving transactions form */
                     SELECT currency_conversion_date,
                            currency_conversion_rate
                     INTO   v_ratedate,
                            v_rate
                     FROM   rcv_transactions
                     WHERE  transaction_id = rcv_trx.parent_transaction_id;

                     rcv_trx.currency_conversion_date  := v_ratedate;
                     rcv_trx.currency_conversion_rate  := v_rate;
                  END IF; -- parent transaction id
               END IF; -- match option is R

              END IF;  --currency code

           END IF; -- source document code is po

           /* Validate that the transaction can be express received */

           --Bug#17274482 allow validation for amount based line
	   -- If (l_matching_basis <> 'AMOUNT') then
           transaction_ok := rcv_express_sv.val_rcv_trx_interface (rcv_trx,X_txn_from_web,X_txn_from_wf);--Bug 5855096
	  -- else
		/* Set transaction_ok to TRUE since we are not calling
		 * val_rcv_trx_interface.
		*/
	  --	transaction_ok := TRUE;
	  --  end if;

           /*
           ** If the transaction passes all validation requirements
           ** then go ahead and process the rows so that it gets picked
           ** up by the transaction procesor
           */
           IF (transaction_ok) THEN

              X_progress := '050';

              /*
              ** Set all the columns for this receipt transaction row`
              ** so that it can be picked up by the transaction processor
              */
            --Bugfix5213454 Start: Called QA API after RTI record validation.

            /* Bugfix 5855096 : Modified the condtion rcv_trx.auto_transact_code <> 'CUSTOMER'
                                with rcv_trx.receipt_source_code = 'VENDOR'*/

            IF (rcv_trx.routing_header_id = 2 AND
                rcv_trx.receipt_source_code = 'VENDOR' AND --Bug 5855096
                rcv_trx.quantity > 0) THEN

              QA_SKIPLOT_RCV_GRP.EVALUATE_LOT
              (p_api_version         => 1.0,
               p_init_msg_list       => NULL,
               p_commit              => 'T',
               p_validation_level    => NULL,
               p_interface_txn_id    => rcv_trx.interface_transaction_id,
               p_organization_id     => rcv_trx.to_organization_id,
               p_vendor_id           => rcv_trx.vendor_id,
               p_vendor_site_id      => rcv_trx.vendor_site_id,
               p_item_id             => rcv_trx.item_id,
               p_item_revision       => rcv_trx.item_revision,
               p_item_category_id    => rcv_trx.category_id,
               p_project_id          => rcv_trx.project_id,
               p_task_id             => rcv_trx.task_id,
               p_manufacturer_id     => NULL,
               p_source_inspected    => NULL,
               p_receipt_qty         => rcv_trx.quantity,
               p_receipt_date        => rcv_trx.transaction_date,
               p_primary_uom         => rcv_trx.primary_unit_of_measure,
               p_transaction_uom     => rcv_trx.unit_of_measure,
               p_po_header_id        => rcv_trx.po_header_id,
               p_po_line_id          => rcv_trx.po_line_id,
               p_po_line_location_id => rcv_trx.po_line_location_id,
               p_po_distribution_id  => rcv_trx.po_distribution_id,
               x_evaluation_result   => l_qa_eval_result,
               x_return_status       => l_qa_return_status,
               x_msg_count           => l_qa_msg_count,
               x_msg_data            => l_qa_msg_data);

               IF l_qa_return_status <> 'S' THEN
                 l_qa_eval_result := 'INSPECT';
               END IF;

               IF l_qa_eval_result = 'STANDARD' THEN
                 rcv_trx.routing_header_id := 1;
               END IF;
           END IF;
           --Bugfix5213454 End: Called QA API after RTI record validation.

              rcv_trx_interface_trx_upd_pkg.update_rcv_transaction (rcv_trx);

              /*
	      ** If the row passes all validation then set the succeed
              ** count appropriately
	      */

	--      if (x_txn_from_web) then
	--              rcv_express_sv.print_record (rcv_trx);
	--      end if;

	      rows_succeeded := rows_succeeded + 1;

	   ELSE

	      if (x_txn_from_web) then


                      X_progress := 70;

                      --Bug 5230922. Changed the where clause. Previously it was matching
                      --po.interface_transaction_id = rcv_trx.interface_transaction_id
                      --that was wrong because  rcv_trx.interface_transaction_id would be
                      --stored as interface_line_id in the table po_interface_errors
		      SELECT column_name, error_message_name
		      INTO   x_column_name, x_message_name
		      FROM   po_interface_errors po
		      WHERE  po.interface_line_id = rcv_trx.interface_transaction_id; --Bug 5230922

                      /* Get the translated message for the
                      ** column that failed validation
                      */

                      X_message_text := fnd_message.get_string('PO',x_message_name);

--Bug#2869368.The error in htp call was causing error message not
--displayed on the browser for the receipt done through SSP.
--Added exception to handle this situation.
                     Begin
		      if (x_first_error) then
			x_output_message := fnd_message.get_string('PO','RCV_CONFIRM_ERRORS');
		        htp.teletype(x_output_message);
			htp.nl;
			htp.teletype('=============================================================================');
			htp.nl;
			x_first_error := FALSE;
		      end if;

		      htp.teletype(x_column_name);   htp.nl;
		      htp.teletype(x_message_text);  htp.nl;
		      htp.teletype('------------');  htp.nl;

                    Exception
                      When others then null;
                    End;


	      end if;

              /*
              ** Bug 3438171 - Don't delete the transaction, update it.
	      ** If the transactions fails validation then update it
              ** in the interface to error
              */
              rcv_trx.processing_status_code := 'COMPLETED';
	      rcv_trx.transaction_status_code := 'ERROR';
	      rcv_trx_interface_trx_upd_pkg.update_rcv_transaction (rcv_trx);


              /*
	      ** If the row fails a validation step then set the failure
              ** count appropriately
	      */
	      rows_failed := rows_failed + 1;

           END IF;

      END IF;

   END LOOP;

   X_rows_succeeded := rows_succeeded;
   X_rows_failed    := rows_failed;

   /* Bug 4891693 fixed. deleting records from RTI which has quantity = 0 */
   BEGIN
     DELETE FROM rcv_transactions_interface
     WHERE   group_id = X_group_id
     AND     quantity = 0;
   EXCEPTION
     WHEN OTHERS THEN
       NULL;
   END;

   RETURN;

   EXCEPTION
   WHEN OTHERS THEN
      po_message_s.sql_error('val_express_transactions', X_progress, sqlcode);
   RAISE;

END val_express_transactions;

/*===========================================================================

  FUNCTION NAME:	val_rcv_trx_interface

===========================================================================*/

FUNCTION val_rcv_trx_interface (rcv_trx   IN OUT NOCOPY rcv_transactions_interface%ROWTYPE,
                                X_txn_from_web     IN BOOLEAN,--Bug 5855096
                                X_txn_from_wf      IN BOOLEAN)--Bug 5855096
   RETURN BOOLEAN IS

X_progress			VARCHAR2(4)	:= '000';
under_lot_control		BOOLEAN		:= FALSE;
under_serial_control		BOOLEAN		:= FALSE;
valid_receiving_controls	NUMBER		:= 0;
valid_deliver_dest		NUMBER		:= 0;
valid_wip_info			NUMBER		:=0;
X_column_name			VARCHAR2(30);
X_err_message			VARCHAR2(240);
x_sob_id			org_organization_definitions.set_of_books_id%type;
x_is_val_period			BOOLEAN		:= FALSE;   -- bug 626224
x_item_name                     VARCHAR2(50)    := '';   --bug 2706571
x_stock_enabled_flag            VARCHAR2(2)     := '';   --bug 2706571
x_allow_express_delivery_flag    VARCHAR2(2)    := '';   --bug 5498095
l_transaction_type_id         NUMBER;
BEGIN

   /* Fix for Bug 5498095
      If the item is not express allowed in the destination organization
      for an inventory destination receipt then an error message will be
      inserted into po_interface errors.
    */

/* Bug: 5855096
    We neeed to by pass the validation for allow_express_delivery flag
    mentioned at item level for the transactions made through the
    web page(iProcurement).
    For the transactions made through iProcurement possible
    transaction_types are 'CONFIRM RECEIPT' and 'CONFIRM RECEIPT(WF)'
    and the variables  X_txn_from_web or X_txn_from_wf set to TRUE.

    Changed nvl(msi.allow_express_delivery_flag,'N') to
    nvl(msi.allow_express_delivery_flag,'U'), to bypass the
    allow_express_delivery flag validation if that flag value
    is to NULL in the Master Items form.
 */
      if ( not(X_txn_from_web or X_txn_from_wf) ) then--Bug 5855096
         if (nvl(rcv_trx.item_id,0) <> 0) then
            select nvl(msi.allow_express_delivery_flag,'U') --Bug 5855096
              into x_allow_express_delivery_flag
              from mtl_system_items msi
             where msi.inventory_item_id =rcv_trx.item_id
               and msi.organization_id = rcv_trx.to_organization_id;

             if x_allow_express_delivery_flag = 'N' then
                X_column_name := 'ITEM_NUMBER: ' || x_item_name;
                X_err_message := 'PO_RI_INVALID_EXPRESS_ITEM';

                rcv_express_sv.insert_interface_errors(rcv_trx,
                                             X_column_name,
                                             X_err_message);
                return FALSE;
             end if;
         end if;  /* fix end for Bug 5498095 */
      end if; /* fix end for Bug 5855096 */

 /* Fix for bug 2706571
    If the item is not stock enabled in the destination organization
    for an inventory destination receipt then an error message will be
    inserted into po_interface errors.
 */

      if ( (rcv_trx.destination_type_code = 'INVENTORY' or
           (rcv_trx.source_document_code = 'RMA' and
            (rcv_trx.transaction_type = 'DELIVER' or rcv_trx.auto_transact_code = 'DELIVER'))) and
          nvl(rcv_trx.item_id,0) <> 0) then

          select msi.segment1,
                 msi.stock_enabled_flag
          into   x_item_name,
                 x_stock_enabled_flag
          from   mtl_system_items msi
          where  msi.inventory_item_id = rcv_trx.item_id
          and    msi.organization_id = rcv_trx.to_organization_id;


          if nvl(x_stock_enabled_flag,'N') = 'N' then

            X_column_name := 'ITEM_NUMBER: ' || x_item_name;
            X_err_message := 'PO_RI_INVALID_DEST_ORG_ITEM';

            rcv_express_sv.insert_interface_errors(rcv_trx,
                                         X_column_name,
                                         X_err_message);

            return FALSE;
          end if;

       end if;  /* End of bug 2706571 */

   if (rcv_trx.transaction_date > sysdate) then

	X_column_name	:= 'TRANSACTION_DATE';
	X_err_message	:= 'RCV_TRX_FUTURE_DATE_NA';

        rcv_express_sv.insert_interface_errors(rcv_trx,
                               X_column_name,
                               X_err_message);

        return FALSE;

   end if;

   --Perf bugfix 5220058
   select GSOB.SET_OF_BOOKS_ID
   into   x_sob_id
   from
     GL_SETS_OF_BOOKS GSOB,
     HR_ORGANIZATION_INFORMATION HOI
   where
       HOI.ORGANIZATION_ID = rcv_trx.to_organization_id
   AND ( HOI.ORG_INFORMATION_CONTEXT || '') ='Accounting Information'
   AND HOI.ORG_INFORMATION1 = TO_CHAR(GSOB.SET_OF_BOOKS_ID);

   -- bug 626224 if period is not defined, just say it's not open

   BEGIN
       x_is_val_period := PO_DATES_S.val_open_period(rcv_trx.transaction_date,x_sob_id,'SQLGL',
						     rcv_trx.to_organization_id);
   EXCEPTION
     WHEN OTHERS THEN
       x_is_val_period := FALSE;
   END;

   if (not x_is_val_period) then

	X_column_name	:= 'TRANSACTION_DATE';
	X_err_message	:= 'PO_PO_ENTER_OPEN_GL_DATE';

        rcv_express_sv.insert_interface_errors(rcv_trx,
                               X_column_name,
                               X_err_message);

	return FALSE;

   end if;

   BEGIN
       x_is_val_period := PO_DATES_S.val_open_period(rcv_trx.transaction_date,x_sob_id,'INV',
						     rcv_trx.to_organization_id);
   EXCEPTION
     WHEN OTHERS THEN
       x_is_val_period := FALSE;
   END;

   if (not x_is_val_period) then

	X_column_name	:= 'TRANSACTION_DATE';
	X_err_message	:= 'PO_INV_NO_OPEN_PERIOD';

        rcv_express_sv.insert_interface_errors(rcv_trx,
                               X_column_name,
                               X_err_message);

	return FALSE;
   end if;

   BEGIN
       x_is_val_period := PO_DATES_S.val_open_period(rcv_trx.transaction_date,x_sob_id,'PO',
						     rcv_trx.to_organization_id);
   EXCEPTION
     WHEN OTHERS THEN
       x_is_val_period := FALSE;
   END;

   if (not x_is_val_period) then

	X_column_name	:= 'TRANSACTION_DATE';
	X_err_message	:= 'PO_PO_ENTER_OPEN_GL_DATE';

        rcv_express_sv.insert_interface_errors(rcv_trx,
                               X_column_name,
                               X_err_message);

	return FALSE;
   end if;

   /*
   ** Check for 0 transaction quantity.  If it's 0 then fail and delete it.
   */
   /*   Bug 4891693 fixed.
 	No need for validation of zero quantity RTI records since we
 	are deleting them down the line.

   IF (rcv_trx.quantity = 0) THEN

       X_column_name := 'QUANTITY';
       X_err_message := 'PO_ALL_ENTER_VALUE_GT_ZERO';

       rcv_express_sv.insert_interface_errors(rcv_trx,
                               X_column_name,
                               X_err_message);


      return FALSE;

   END IF;
   */

   /*
   ** check for valid currency conversion rate. bug 4356092
   */
   IF (rcv_trx.currency_conversion_rate = fnd_api.g_miss_num) THEN
       /*
       ** Push the failed Row into the interface_errors table
       ** so we can provide feedback to the user.
       */
       X_column_name := 'CURRENCY_CONVERSION_RATE';
       X_err_message := 'PO_CPO_NO_RATE_FOR_DATE';

       rcv_express_sv.insert_interface_errors(rcv_trx,
                               X_column_name,
                               X_err_message);


      return FALSE;

   END IF;


   /*
   ** Check for a receipt transaction.  If it is then do all the validation
   ** required to perform a receipt ncluding:
   **
   ** 1.  Does the receipt match the receiving controls like date tolerances
   ** 2.  Does the receipt have the required revision value
   ** 3.  If this is an express receipt make sure there are no pending
   **     transactions for this line.
   */
   IF (rcv_trx.transaction_type = 'RECEIVE') THEN
      /*
      ** Check the receiving controls for this transaction.
      */
      X_progress := '100';

--      htp.p ('validating receiving controls');  --   htp.nl;

      valid_receiving_controls := rcv_transactions_sv.val_receiving_controls (
             rcv_trx.transaction_type,
             rcv_trx.auto_transact_code,
             rcv_trx.expected_receipt_date,
             rcv_trx.transaction_date,
             rcv_trx.routing_header_id,
             rcv_trx.po_line_location_id,
             rcv_trx.item_id,
             rcv_trx.vendor_id,
             rcv_trx.to_organization_id);

      if valid_receiving_controls<> 0  THEN

--         htp.p ('receiving controls validation failed');  --   htp.nl;

         /*
         ** Push the failed Row into the interface_errors table
         ** so we can provide feedback to the user.The variable valid
         ** _receiving_controls will hold a 1 if the receipt date
         ** exceeded tolerance . It will have a value of 2 if the
         ** routing information was incorrect.If the routing info
         ** fails, the only way the user can receive is thru the
         ** 10sc apps. We do not have Routing info as enterable fields
         ** on the Receive Orders Web Page yet.
         */
         if valid_receiving_controls = 1 then
            X_column_name := 'TRANSACTION_DATE';
            X_err_message := 'RCV_ALL_DATE_OUT_OF_RANGE';
         elsif  valid_receiving_controls = 2 then
            X_column_name := 'ROUTING_HEADER_ID';
            X_err_message := 'RCV_ROUTING_OVERRIDE_NA';

         /*  Bug 3724862 : Error handling for dropship case */
         elsif valid_receiving_controls = 3 then
	    X_column_name := 'ROUTING_HEADER_ID';
            X_err_message := 'RCV_DROPSHIP_DIRECT_ONLY';
         end if;

         rcv_express_sv.insert_interface_errors(rcv_trx,
                                 X_column_name,
                                 X_err_message);

         RETURN (FALSE);

      END IF;

      --   htp.p ('validating item rev controls');  --   htp.nl;
      /*
      ** Check that the item rev control matches is satisfied
      */
      X_progress := '110';
      IF (NOT po_items_sv2.val_item_rev_controls (
           rcv_trx.transaction_type,
           rcv_trx.auto_transact_code,
           rcv_trx.po_line_location_id,
           rcv_trx.shipment_line_id,
           rcv_trx.to_organization_id,
           rcv_trx.destination_type_code,
           rcv_trx.item_id,
           rcv_trx.item_revision)) THEN

        --   htp.p ('item rev controls validation');  --   htp.nl;

        X_column_name := 'ITEM_REVISION';
        X_err_message := 'RCV_ITEM_IN_REV_CONTROL';

        rcv_express_sv.insert_interface_errors(rcv_trx,
                                X_column_name,
                                X_err_message);

   	RETURN (FALSE);

      END IF;

      /*
      ** Bug 3417961 : Item revision needs to be validated for an Express Receipt
      **          against an Internal Order, RMA and Inventory Inter Org Transfers.
      */

      IF ( rcv_trx.receipt_source_code IN ('INTERNAL ORDER','CUSTOMER','INVENTORY') ) THEN

         DECLARE
           l_valid_revision   NUMBER := NULL;
   	   l_item_rev_control NUMBER := NULL;
         BEGIN

      	    SELECT msi.revision_qty_control_code
               INTO   l_item_rev_control
               FROM   mtl_system_items_kfv msi
            WHERE  msi.inventory_item_id = rcv_trx.item_id
               AND  msi.organization_id = rcv_trx.to_organization_id;

            IF ( nvl(l_item_rev_control,1) = 2 ) THEN

  	          SELECT count(*)
                    INTO l_valid_revision
                    FROM mtl_item_revisions
                  WHERE inventory_item_id = rcv_trx.item_id
                    AND organization_id = rcv_trx.to_organization_id
                    AND revision = rcv_trx.item_revision;

                  IF ( l_valid_revision = 0 ) THEN

		      IF ( rcv_trx.receipt_source_code = 'CUSTOMER') THEN
		          X_column_name := 'ITEM_REVISION';
                          X_err_message := 'PO_RI_INVALID_ITEM_REVISION';
                      ELSE
  	                  X_column_name := 'ITEM_REVISION';
                          X_err_message := 'PO_RI_INVALID_DEST_REVISION';
                      END IF;

                      rcv_express_sv.insert_interface_errors(rcv_trx,
                                   X_column_name,
                                   X_err_message);

   	              RETURN (FALSE);
                  END IF;
	    END IF;
         END;
      END IF;	 -- if receipt_source_code = 'INTERNAL ORDER'

      /* End of Bug 3417961 */

      IF (rcv_trx.auto_transact_code = 'RECEIVE') THEN

         --   htp.p ('validating ship to location id');  --   htp.nl;
         /*
         ** If this is a express receipt then make sure
         ** you have a ship_to_location_id
         */
         IF (rcv_trx.ship_to_location_id IS NULL OR
                rcv_trx.ship_to_location_id = 0) THEN

            X_column_name := 'SHIP_TO_LOCATION_ID';
            X_err_message := 'RCV_SHIP_TO_LOC_NA';

            rcv_express_sv.insert_interface_errors(rcv_trx,
                                    X_column_name,
                                    X_err_message);
            RETURN FALSE;

         END IF;

      END IF; -- (rcv_trx.auto_transact_code = 'RECEIVE')

   END IF; -- (rcv_trx.transaction_type = 'RECEIVE')

   IF (rcv_trx.auto_transact_code = 'DELIVER' OR
          rcv_trx.transaction_type = 'DELIVER') THEN

      --   htp.p ('validating destination info : ');  --   htp.nl;

      /*
      ** Check that the destination information is valid
      */
      X_progress := '130';
      valid_deliver_dest := rcv_transactions_sv.val_deliver_destination (
                   rcv_trx.to_organization_id,
                   rcv_trx.item_id,
                   rcv_trx.destination_type_code,
                   rcv_trx.deliver_to_location_id,
                   rcv_trx.subinventory);

      --   htp.p ('The var Valid_Deliver_dest is :' || to_char(valid_deliver_dest));  --   htp.nl;
      IF valid_deliver_dest <> 0 THEN

        --   htp.p ('destination info validation failed: ');  --   htp.nl;

        if valid_deliver_dest = 10 then

           /* The Destination Org is not defined */

           X_column_name := 'TO_ORGANIZATION_ID';
           X_err_message := 'RCV_DEST_ORG_NA';

        elsif valid_deliver_dest = 20 then

           /* The Deliver To Location is not defined */

           X_column_name := 'DELIVER_TO_LOCATION_ID';
           X_err_message := 'RCV_DELIVER_TO_LOC_NA';

        elsif valid_deliver_dest = 30 then

           /* The deliver to Location is invalid */

           X_column_name := 'DELIVER_TO_LOCATION_ID';
           X_err_message := 'RCV_DELIVER_TO_LOC_INVALID';

        elsif valid_deliver_dest = 40 then

           /* The Sub is not defined */

           X_column_name := 'DESTINATION_SUBINVENTORY';
           X_err_message := 'RCV_DEST_SUB_NA';

        elsif valid_deliver_dest = 50 then

           /* The Sub is invalid */
           X_column_name := 'DESTINATION_SUBINVENTORY';
           X_err_message := 'RCV_DEST_SUB_INVALID';

        elsif valid_deliver_dest = 60 then

           /* Destination Type Code is Invalid */
           X_column_name := 'DESTINATION_TYPE_CODE';
           X_err_message := 'RCV_DEST_TYPE_CODE_INVALID';

        end if;
        rcv_express_sv.insert_interface_errors(rcv_trx,
                                X_column_name,
                                X_err_message);
   	RETURN (FALSE);

      END IF;


      /*
      ** The required info for inventory is the
      ** subinventory, and locator and that the item not be under
      ** lot or serial control
      */
      /*
      ** Check if an item/org is under lot and/or
      ** serial control.
      */
      X_progress := '140';


       /* Bug# 2166549.We should not validate for expense items which are
        * lot/serial controlled even when express functionality is used.
       */

      IF (rcv_trx.destination_type_code <> 'EXPENSE') THEN

        IF rcv_trx.use_mtl_lot in (2, 5) THEN

          --   htp.p ('lot control validation failed: ');   --   htp.nl;
          X_column_name := 'USE_MTL_LOT';
          X_err_message := 'RCV_MTL_LOT_CONTROL_FAIL';
          rcv_express_sv.insert_interface_errors(rcv_trx,
                                 X_column_name,
                                 X_err_message);
          RETURN (FALSE);

        END IF;

      END IF;


      IF (rcv_trx.destination_type_code <> 'EXPENSE') THEN

        IF rcv_trx.use_mtl_serial in (2, 5) THEN

           --   htp.p ('serial control validation failed: ');  --   htp.nl;
           X_column_name := 'USE_MTL_SERIAL';
           X_err_message := 'RCV_MTL_SERIAL_CONTROL_FAIL';
           rcv_express_sv.insert_interface_errors(rcv_trx,
                                 X_column_name,
                                 X_err_message);

           RETURN (FALSE);

        END IF;

      END IF;

      --   htp.p ('validating locator control : ');  --   htp.nl;

      /*
      ** Check that a locator is not required for this transaction since a user
      ** would never have the opportunity to enter one.  The only way a
      ** delivery to an inventory destination could work is if a default
      ** locator was defined for the subinventory
      */
      IF (rcv_trx.destination_type_code = 'INVENTORY') THEN

         X_progress := '150';
         IF (NOT po_subinventories_s.val_locator_control (
                     rcv_trx.to_organization_id,
                     rcv_trx.item_id,
                     rcv_trx.subinventory,
                     rcv_trx.locator_id)) THEN

            X_column_name := 'LOCATOR_ID';
            X_err_message := 'RCV_LOCATOR_CONTROL_INVALID';
            rcv_express_sv.insert_interface_errors(rcv_trx,
                                 X_column_name,
                                 X_err_message);

            --   htp.p ('locator control validation failed: ');   --   htp.nl;

            RETURN (FALSE);

         END IF;

      ELSE

         /* BUG: 5435353
         ** Mark the locator id as null if it is not an inventory transaction
         */
         rcv_trx.locator_id := NULL;

      END IF;

      --   htp.p ('validating wip info : ');  --   htp.nl;

      /*
      ** if this is a shop floor destination then make sure that the job
      ** information is still valid
      */
      IF (rcv_trx.destination_type_code = 'SHOP FLOOR') THEN

         X_progress := '160';

         valid_wip_info := rcv_transactions_sv.val_wip_info (
                     rcv_trx.to_organization_id,
                     rcv_trx.wip_entity_id,
                     rcv_trx.wip_operation_seq_num,
                     rcv_trx.wip_resource_seq_num,
                     rcv_trx.wip_line_id,
                     rcv_trx.wip_repetitive_schedule_id,
                     rcv_trx.po_line_id); -- bug 2619164

         IF (valid_wip_info <> 0) THEN

           if valid_wip_info = 10 then

              X_column_name := 'TO_ORGANIZATION_ID';
              X_err_message := 'RCV_DEST_ORG_NA';

           elsif valid_wip_info = 20 then

              X_column_name := 'WIP_ENTITY_ID';
              X_err_message := 'RCV_WIP_ENTITY_ID_NA';

           elsif valid_wip_info = 30 then

              X_column_name := 'WIP_OP_SEQ_NUM';
              X_err_message := 'RCV_WIP_OP_SEQ_NUM_NA';

           elsif valid_wip_info = 40 then

              X_column_name := 'WIP_RES_SEQ_NUM';
              X_err_message := 'RCV_WIP_RES_SEQ_NUM_NA';

           elsif valid_wip_info = 50 then

              X_column_name := 'WIP_REPETITIVE_SCHEDULE_ID';
              X_err_message := 'RCV_WIP_REP_SCH_JOB_NOT_OPEN';

           elsif valid_wip_info = 60 then

              X_column_name := '_WIP_ENTITY_ID';
              X_err_message := 'RCV_WIP_JOB_NOT_OPEN';

           end if;

           rcv_express_sv.insert_interface_errors(rcv_trx,
                                   X_column_name,
                                   X_err_message);

           --   htp.p ('wip info validation failed : ');  --   htp.nl;

           RETURN (FALSE);

         END IF;

      END IF;

      /*
      ** DEBUG: This needs to be moved out of this function since it's not
      ** generic unless we want to pass this function an express flag and
      ** then only execute this check if its express.
      ** If you're doing an express direct/deliver then make sure that there
      ** are no receipts that have not been delivered.  Otherwise we
      ** won't be able to distribute them properly.
      */

      --   htp.p ('validating pending delivery transactions');  --   htp.nl;

      /*
      ** If this is a receipt transaction. Then check that there are is no
      ** receipt supply for this line location
      **
      */
      IF (rcv_trx.source_document_code = 'PO' AND
           (rcv_trx.transaction_type = 'RECEIVE' OR
              rcv_trx.auto_transact_code = 'RECEIVE')) THEN

         X_progress := '120';
         IF (NOT rcv_transactions_sv.val_pending_receipt_trx (
              rcv_trx.po_line_location_id,
              rcv_trx.group_id)) THEN

                X_column_name := 'PO_LINE_LOCATION_ID';
                X_err_message := 'RCV_PENDING_DELIVERY_FAILED';--bug8663187
                rcv_express_sv.insert_interface_errors(rcv_trx,
                                        X_column_name,
                                        X_err_message);
                --   htp.p ('pending delivery transactions validation failed');  --   htp.nl;

                RETURN (FALSE);

         END IF; -- (NOT rcv_transactions_sv.val_pending_transactions)

      END IF; -- (rcv_trx.source_document_code = 'PO')

   END IF; -- (rcv_trx.auto_transact_code = 'DELIVER' ...)

   -- Bug 10253000 : Validate material status on subinventory and locator level
   IF (rcv_trx.destination_type_code = 'INVENTORY' AND
        (rcv_trx.auto_transact_code = 'DELIVER' OR
         rcv_trx.transaction_type = 'DELIVER') ) THEN

              X_progress := '170';

              IF rcv_trx.receipt_source_code = 'VENDOR' THEN
                 l_transaction_type_id := 18;

              ELSIF rcv_trx.receipt_source_code = 'INVENTORY' THEN
                 l_transaction_type_id := 12;

              ELSIF rcv_trx.receipt_source_code = 'INTERNAL ORDER' THEN
                 l_transaction_type_id := 61;

              ELSIF rcv_trx.receipt_source_code = 'CUSTOMER' THEN
                 l_transaction_type_id := 15;

              ELSE
                 l_transaction_type_id := -99;
              END IF;

              IF( inv_material_status_grp.is_status_applicable(NULL,
                                            NULL,
                                            l_transaction_type_id,
                                            NULL,
                                            NULL,
                                            rcv_trx.to_organization_id,
                                            NULL,
                                            rcv_trx.subinventory,
                                            NULL,
                                            NULL,
                                            NULL,
                                            'Z') <> 'Y') THEN

                      X_column_name := 'SUBINVENTORY';
                      X_err_message := 'RCV_DEST_SUB_INVALID';
                      rcv_express_sv.insert_interface_errors(rcv_trx,
                                   X_column_name,
                                   X_err_message);
                       RETURN (FALSE);
                END IF;

                IF( inv_material_status_grp.is_status_applicable(NULL,
                                            NULL,
                                            l_transaction_type_id,
                                            NULL,
                                            NULL,
                                            rcv_trx.to_organization_id,
                                            NULL,
                                            NULL,
                                            rcv_trx.locator_id,
                                            NULL,
                                            NULL,
                                            'L') <> 'Y') THEN
                      X_column_name := 'LOCATOR_ID';
                      X_err_message := 'RCV_ALL_INVALID_LOCATOR';
                      rcv_express_sv.insert_interface_errors(rcv_trx,
                                   X_column_name,
                                   X_err_message);
                      RETURN (FALSE);
                END IF;

          END IF;
          -- Bug 10253000: End

   RETURN TRUE;

   EXCEPTION
    WHEN OTHERS THEN
       po_message_s.sql_error('val_rcv_trx_interface', x_progress, sqlcode);
    RAISE;

END val_rcv_trx_interface;

/*===========================================================================

  PROCEDURE NAME:	set_trx_defaults

===========================================================================*/

PROCEDURE set_trx_defaults (
rcv_trx IN OUT NOCOPY rcv_transactions_interface%ROWTYPE)
IS

inventory_receipt      BOOLEAN      := FALSE;
item_rev_exists        BOOLEAN      := FALSE;
X_item_rev_control     NUMBER       := 1;
X_sysdate	       DATE;
locator_control        NUMBER       := 0;
X_parent_id            NUMBER       := 0;
X_tolerable_quantity   NUMBER       := 0;
X_transaction_type     VARCHAR2(30) := NULL;
X_uom                  VARCHAR2(30) := NULL;
X_receipt_source_code          VARCHAR2(30) := NULL;
X_available_quantity   NUMBER       := 0;
X_progress 	       VARCHAR2(4)  := '000';
x_default_subinventory       VARCHAR2(10);
X_default_locator_id         NUMBER;
X_SUCCESS		BOOLEAN     := FALSE;
X_txn_from_web          BOOLEAN := FALSE;
X_txn_from_wf          BOOLEAN := FALSE;
/*Bug 2869806 */
x_dist_avail_qty       NUMBER := 0;
x_dist_tol_qty         NUMBER := 0;
x_dist_uom             VARCHAR2(30) := NULL;
x_distribution_id      NUMBER := 0;
x_dist_qty_in_trx_uom  NUMBER  := 0;
x_dist_count  NUMBER := 0;
x_ship_qty_in_trx_uom  NUMBER := 0;
x_trx_uom              VARCHAR2(30) := NULL;
/*Bug 1548597 */
X_secondary_available_qty NUMBER := 0;
/* Bug# 2834411 */
x_project_id           NUMBER;
x_task_id        NUMBER;
/* bug 2994421 */
x_uom_code             VARCHAR2(5)  := NULL;
/* Bug 9048393 */
x_locator_id NUMBER;
l_project_locator_id number;
l_locator_id number;

l_mp_lcm_flag          mtl_parameters.lcm_enabled_flag%TYPE; -- Bug 9575796
l_pre_receive_flag     rcv_parameters.pre_receive%TYPE;      -- Bug 9575796
l_pll_lcm_flag         po_line_locations_all.lcm_flag%TYPE;  -- Bug 9575796

l_country_of_origin_code  po_line_locations_all.country_of_origin_code%TYPE := NULL;   /* bug 18143479 */

BEGIN


   /* Start of bug 18143479 */
   IF (rcv_trx.transaction_type IN ('EXPRESS DELIVER') AND rcv_trx.source_document_code = 'PO') THEN

          SELECT country_of_origin_code
            INTO l_country_of_origin_code
            FROM rcv_transactions
           WHERE transaction_id = rcv_trx.parent_transaction_id
           AND shipment_line_id = rcv_trx.shipment_line_id;

           UPDATE rcv_transactions_interface
           SET country_of_origin_code = l_country_of_origin_code
           WHERE interface_transaction_id = rcv_trx.interface_transaction_id;

   END IF;
   /* End of bug 18143479 */

   /*
   ** Set the transaction type and the auto transact code and the
   ** quantity
   */
   IF (rcv_trx.transaction_type = 'EXPRESS RECEIPT') THEN

      rcv_trx.transaction_type   := 'RECEIVE';
      rcv_trx.auto_transact_code := 'RECEIVE';

   ELSIF (rcv_trx.transaction_type = 'EXPRESS DIRECT') THEN

      rcv_trx.transaction_type   := 'RECEIVE';
      rcv_trx.auto_transact_code := 'DELIVER';

   ELSIF (rcv_trx.transaction_type = 'EXPRESS DELIVER') THEN

      rcv_trx.transaction_type   := 'DELIVER';
      rcv_trx.auto_transact_code := '';

   ELSIF (rcv_trx.transaction_type = 'CONFIRM RECEIPT') THEN

      rcv_trx.transaction_type   := 'RECEIVE';
      rcv_trx.auto_transact_code := 'DELIVER';
      X_txn_from_web             := TRUE;

   ELSIF (rcv_trx.transaction_type = 'CONFIRM RECEIPT(WF)') THEN

      rcv_trx.transaction_type   := 'RECEIVE';
      rcv_trx.auto_transact_code := 'DELIVER';
      X_txn_from_web		 := FALSE;

      -- bug 513848
      X_txn_from_wf              := TRUE;

   END IF;

   /*
   ** Set the status of the record to pending
   */
   -- Bug 9575796 : Start
   IF (rcv_trx.source_document_code = 'PO' and rcv_trx.po_line_location_id is not null) THEN
       SELECT nvl(mp.lcm_enabled_flag,'N'), nvl(rp.pre_receive,'N'),nvl(pll.lcm_flag,'N')
       INTO   l_mp_lcm_flag, l_pre_receive_flag, l_pll_lcm_flag
       FROM   po_line_locations_all pll,
              mtl_parameters        mp,
              rcv_parameters        rp
       WHERE  pll.line_location_id    = rcv_trx.po_line_location_id
       AND    mp.organization_id      = rcv_trx.to_organization_id
       AND    mp.organization_id      = rp.organization_id;
   END IF;

   IF (l_mp_lcm_flag = 'Y' and l_pre_receive_flag = 'N' and l_pll_lcm_flag = 'Y' and rcv_trx.lcm_shipment_line_id IS NULL) THEN
      rcv_trx.processing_status_code := 'LC_PENDING';
      rcv_trx.processing_mode_code   := 'BATCH';
   ELSE
      rcv_trx.processing_status_code := 'PENDING';
   END IF;
   -- Bug 9575796: End

   rcv_trx.transaction_status_code := 'PENDING';

   /*
   ** Set the default item rev if one is not set on the transaction
   */
   inventory_receipt := rcv_transactions_sv.val_if_inventory_destination (
         rcv_trx.po_line_location_id, rcv_trx.shipment_line_id);

   /*
   ** If this is has an inventory destination and there is not item rev
   ** specified and it's under item rev control then try to go get the
   ** latest implemented item rev
   */
   IF (inventory_receipt AND
      rcv_trx.item_id IS NOT NULL AND
      rcv_trx.item_revision IS NULL) THEN

      X_progress := 400;

      SELECT msi.revision_qty_control_code
      INTO   X_item_rev_control
      FROM   mtl_system_items_kfv msi
      WHERE  rcv_trx.item_id = msi.inventory_item_id
      AND    rcv_trx.to_organization_id = msi.organization_id;

      /*
      ** If this item is under rev control which is the code 2
      ** then go get the latest implemented version
      */
      IF (X_item_rev_control = 2 AND rcv_trx.item_revision IS NULL) THEN

           X_progress := 410;
           po_items_sv2.get_latest_item_rev (rcv_trx.item_id,
       	   			        rcv_trx.to_organization_id,
			                rcv_trx.item_revision,
		 		        item_rev_exists);
      END IF;

   END IF; -- (inventory_receipt ...)

   X_receipt_source_code := rcv_trx.receipt_source_code;
   /*
   ** Get the available transaction quantity for this receipt
   */
   IF (rcv_trx.transaction_type = 'RECEIVE' AND
       rcv_trx.auto_transact_code = 'RECEIVE') THEN

      /*
      ** If this is a vendor receipt then the parent id is the line
      ** location id otherwise its an internal shipment so the parent
      ** id is the shipment_line_id.
      */
      IF (rcv_trx.receipt_source_code = 'VENDOR') THEN
         X_parent_id := rcv_trx.po_line_location_id;

      /*
      ** If this is an asn then we need to override the parameters to the
      ** get_available call in this case.
      */
      ELSIF (rcv_trx.receipt_source_code in ('ASN','LCM')) THEN -- lcm changes

         X_parent_id := rcv_trx.shipment_line_id;
         X_transaction_type := 'RECEIVE';
         X_receipt_source_code := 'INVENTORY';

      ELSE

         X_parent_id := rcv_trx.shipment_line_id;

      END IF;

      X_transaction_type := 'RECEIVE';

      X_progress := '1100';

      /*Bug 1548597 */

      rcv_quantities_s.get_available_quantity (
         X_transaction_type, X_parent_id,
         X_receipt_source_code, NULL, 0, NULL, X_available_quantity,
         X_tolerable_quantity, X_uom,X_secondary_available_qty);


   ELSIF (rcv_trx.transaction_type = 'RECEIVE' AND
        rcv_trx.auto_transact_code = 'DELIVER')THEN

      /*
      ** If this is a vendor receipt then the parent id is the line
      ** location id otherwise its an internal shipment so the parent
      ** id is the shipment_line_id.
      */
      IF (rcv_trx.receipt_source_code = 'VENDOR') THEN

         X_parent_id := rcv_trx.po_distribution_id;
         X_transaction_type := 'DIRECT RECEIPT';

      /*
      ** If the shipment_line_id is populated then this must be sourced
      ** from an asn.  We need to override the parameters to the get_available
      ** call in this case.
      */
      ELSIF (rcv_trx.receipt_source_code in ('ASN','LCM')) THEN -- lcm changes


      /* Bug 2869806 - Added the following piece of code to get the available
         distribution qty if the distribution id is populated.We are also
         getting the count(po_distribution_id) to check if this is the last
         distribution. When doing a express delivery on an overshipped ASN
         we need to allocate the excess qty only to the last distribution.
         If the following select returns one then this is the last distribution
         and the excess quantity should be allocated against this distribution.
      */

         select count(po_distribution_id)
         into x_dist_count
         from rcv_transactions_interface
         where transaction_type = 'EXPRESS DIRECT'
         and po_line_location_id = rcv_trx.po_line_location_id
         and shipment_line_id = rcv_trx.shipment_line_id;


         if (rcv_trx.po_distribution_id is not null) then

            x_distribution_id := rcv_trx.po_distribution_id;
            x_transaction_type := 'DIRECT RECEIPT';

            rcv_quantities_s.get_available_quantity (
            X_transaction_type, x_distribution_id,
            X_receipt_source_code, NULL, 0, NULL, x_dist_avail_qty,
            x_dist_tol_qty, x_dist_uom,X_secondary_available_qty);


         end if;


         X_parent_id := rcv_trx.shipment_line_id;
         X_transaction_type := 'RECEIVE';
         X_receipt_source_code := 'INVENTORY';


      ELSE

         X_parent_id := rcv_trx.shipment_line_id;
         X_transaction_type := 'RECEIVE';

      END IF;

      X_progress := '1100';

      /*Bug 1548597 */
      rcv_quantities_s.get_available_quantity (
         X_transaction_type, X_parent_id,
         X_receipt_source_code, NULL, 0, NULL, X_available_quantity,
         X_tolerable_quantity, X_uom,X_secondary_available_qty);

   /*
   ** If this is a delivery then you need to give the parent transaction
   ** id as the the parent id
   */
   ELSIF (rcv_trx.transaction_type = 'DELIVER') THEN


      /* Chk avaliable qty and UOM for the distribution transaction */
      /*Bug 1548597 */

      IF (rcv_trx.receipt_source_code = 'VENDOR') THEN

      /* Bug 7040004 */
      /* Call this API only when receipt_source_code is Vendor */
      /* Donot calculate the available quantity in case of internal orders and inter-org transfers */

      rcv_quantities_s.get_available_quantity ('STANDARD DELIVER',
                                                rcv_trx.po_distribution_id,
                                                null,
                                                null,
                                                rcv_trx.parent_transaction_id,
                                                null,
                                                X_available_quantity,
                                                X_tolerable_quantity, X_uom,X_secondary_available_qty);
      ELSE

	  /*
          ** start of bug 14001648
          ** X_available_quantity := rcv_trx.quantity;
          ** X_tolerable_quantity := rcv_trx.quantity;
          ** X_uom := rcv_trx.unit_of_measure;
          ** X_secondary_available_qty:=rcv_trx.secondary_quantity;
	  ** end of bug 14001648
	  */

	  /*
	  ** start of bug 14001648:pass parameters 'DELIVER' and 'rcv_trx.parent_transaction_id' to
	  ** rcv_quantities_s.get_available_quantity,so that procedure get_transaction_quantity in
	  ** package rcv_quantities_s is called finally to get the quantity
	  */
	  rcv_quantities_s.get_available_quantity ('DELIVER',
                                                rcv_trx.parent_transaction_id,
                                                null,
                                                null,
                                                0,
                                                null,
                                                X_available_quantity,
                                                X_tolerable_quantity, X_uom,X_secondary_available_qty);
	  /*end of bug 14001648*/

      END IF;

      /* End bug 7040004 */

   ELSE
	   null;
      --   htp.p ('ERROR: Invalid transaction type' || rcv_trx.receipt_source_code);  htp.nl;

   END IF;


   --   htp.p ('set_trx_defaults : available quantity = ' || TO_CHAR(X_available_quantity));  htp.nl;
   --   htp.p ('set_trx_defaults : transaction status code = ' || rcv_trx.transaction_status_code);  htp.nl;
   /*
   ** Set the transactions quantity to the quantity available to transact
   ** only if the transaction_status_code is not CONFIRM.
   ** If the order is received via the Receive Orders Page on the Web,
   ** we set the variable X_txn_from_web to TRUE in the beg. of this procedure.
   */

   -- bug 513848
   -- Do not set the transactions quantity if it is from Confirm Receipt
   -- Web page or Workflow

   if X_txn_from_web or
      X_txn_from_wf then
      NULL;
   else
      rcv_trx.quantity := X_available_quantity;
   end if;


   /* Bug 3927688.
      Passing ASN uom to RTI record for ASN Express Receipt.
   */
   IF (rcv_trx.transaction_type = 'RECEIVE' AND
       rcv_trx.auto_transact_code = 'RECEIVE' AND
       rcv_trx.receipt_source_code in ('ASN','LCM'))THEN -- lcm changes

       rcv_trx.unit_of_measure := x_uom;

   END IF;


  /*  Bug 2869806  As we have the available qty from ASN,available qunatity from
      the distribution and distribtion count we allocate the available qty
      from the distribution as transaction qty.*/



IF (rcv_trx.transaction_type = 'RECEIVE' AND
    rcv_trx.auto_transact_code = 'DELIVER' AND
    rcv_trx.receipt_source_code in ('ASN','LCM'))THEN -- lcm changes

   x_trx_uom := x_uom;   --3927688

   if (x_dist_uom <> x_trx_uom) then

     po_uom_s.uom_convert(x_dist_avail_qty, x_dist_uom, rcv_trx.item_id,
                     x_trx_uom, x_dist_qty_in_trx_uom);

   else

     x_dist_qty_in_trx_uom := x_dist_avail_qty;

   end if;


   if(x_uom <> x_trx_uom ) then

      po_uom_s.uom_convert(x_available_quantity, x_uom, rcv_trx.item_id,
                     x_trx_uom, x_ship_qty_in_trx_uom);

   else

     x_ship_qty_in_trx_uom := x_available_quantity;

   end if;



  if (rcv_trx.po_distribution_id is not null) then

    if((x_ship_qty_in_trx_uom > x_dist_qty_in_trx_uom) and
       (x_dist_count > 1)) then

        rcv_trx.quantity := x_dist_qty_in_trx_uom;
        rcv_trx.unit_of_measure := x_trx_uom;    --3927688
    else
         rcv_trx.quantity := x_ship_qty_in_trx_uom;
         rcv_trx.unit_of_measure := x_trx_uom;   --3927688

    end if;

  end if;

END IF;

   --It is required to move the bugfix of 2994421 to this
   --location after the bugfix of 3927688 to populate the
   --correct uom_code in RTI.

   /* Fix for bug 2994421.
      Populating uom_code into rti. Uom_code is required
      for receipts done against drop ship POs as this is
      used at the time of Sales Order Issue transaction.
   */

   if (rcv_trx.uom_code is null) then

      select uom_code
      into  x_uom_code
      from mtl_units_of_measure
      where unit_of_measure = rcv_trx.unit_of_measure;

    rcv_trx.uom_code := x_uom_code;

   end if;
 --   htp.p ('set_trx_defaults : rcv_trx.quantity = ' || TO_CHAR(rcv_trx.quantity));  htp.nl;

   IF (rcv_trx.destination_type_code = 'INVENTORY' AND
        (rcv_trx.auto_transact_code = 'DELIVER' OR
          rcv_trx.transaction_type = 'DELIVER')) THEN

      /*
      ** A subinventory must have been defined on the po or a default
      ** must be available for the item.  If it's not already defined
      ** then go get it out of inventory.  If you're using express
      ** then it's ok to get the default rather than having it be
      ** defined on the record
      */
      IF (rcv_trx.subinventory IS NULL) THEN

         /*
         ** If you're using express then it's ok to get the default
         ** rather than having it be defined on the record
         */
         X_progress := '1200';
         po_subinventories_s.get_default_subinventory (
              rcv_trx.to_organization_id,
              rcv_trx.item_id,
              rcv_trx.subinventory);

      END IF; -- (rcv_trx.subinventory IS NULL)

      /*
      ** See if org/sub/item is under locator control.  If the sub is
      ** not available then don't do this call since it won't matter
      ** because the row will fail without a sub
      */
      IF (rcv_trx.subinventory IS NOT NULL) THEN

         X_progress := '1220';
         po_subinventories_s.get_locator_control
            (rcv_trx.to_organization_id,
             rcv_trx.subinventory,
             rcv_trx.item_id,
             locator_control);

         /*
         ** If locator control is 2 which means it is under predefined
         ** locator contol or 3 which means it's under dynamic (any value)
         ** locator control then you need to go get the default locator id
         */
         IF (locator_control = 2 OR locator_control = 3) THEN

             X_progress := '1230';

             /* Bug 9048393 - get locator_id from shipment */
             IF ( rcv_trx.source_document_code = 'INVENTORY') THEN
               select locator_id
               into  x_locator_id
               from rcv_shipment_lines
               where shipment_line_id = rcv_trx.shipment_line_id;

               rcv_trx.locator_id := x_locator_id;
             END IF;

             IF (rcv_trx.locator_id IS NULL) THEN  -- Bug 9048393 only locator_id is null then set default value
               po_subinventories_s.get_default_locator (
                  rcv_trx.to_organization_id,
                  rcv_trx.item_id,
                  rcv_trx.subinventory,
                  rcv_trx.locator_id);
             END IF;

             /* Bug# 2834411 - Added the following logic to default the
                project_id and task_id */
             IF (rcv_trx.receipt_source_code <> 'CUSTOMER') THEN

                IF (rcv_trx.po_distribution_id IS NOT NULL AND
                    rcv_trx.locator_id IS NOT NULL) THEN

                    SELECT project_id, task_id
                    INTO   x_project_id, x_task_id
                    FROM   po_distributions
                    WHERE  po_distribution_id = rcv_trx.po_distribution_id;

                ELSIF (rcv_trx.requisition_line_id is not null and
                       rcv_trx.locator_id is not null) then

                    SELECT project_id, task_id
                    INTO   x_project_id,x_task_id
                    FROM   po_req_distributions
                    WHERE  requisition_line_id = rcv_trx.requisition_line_id;

                END IF;

                IF (x_project_id IS NOT NULL) THEN
                   begin
                        l_locator_id :=  rcv_trx.locator_id;

                        PJM_PROJECT_LOCATOR.Get_DefaultProjectLocator(
                             rcv_trx.to_organization_id,
                              l_locator_id,
                             x_project_id,
                             x_task_id,
                             l_project_locator_id);

  	 if(l_project_locator_id is not null ) then
 	           rcv_trx.locator_id :=l_project_locator_id ;
 	 end if;
                   exception
                        when others then null;
                   end;

                END IF;

             END IF;
             /* Bug# 2834411 - End */

         END IF;


      END IF;

   END IF; -- (rcv_trx.destination_type_code = 'INVENTORY' AND...)

   /*
   ** DEBUG: If this is an express direct then check the quantity left
   ** on the receipt against what you are attempting to deliver and
   ** see if there is enough to deliver.  If not, takes what's left
   ** and then terminate the loop up above on the distributions.
   ** The problem here is that I could have over received a distribution
   ** in an earlier manual transaction so we can't assume we can deliver
   ** what's on the distribution.  Need to modify Sanjay's get quantity
   ** routines to perform this function.
   */

   /*
   ** Set all the quantity information.
   ** You must also set the primary_quantity and uom properly
   */

   X_progress := '900';

   RCV_QUANTITIES_S.get_primary_qty_uom (
       rcv_trx.quantity,
       rcv_trx.unit_of_measure,
       rcv_trx.item_id,
       rcv_trx.to_organization_id,
       rcv_trx.primary_quantity,
       rcv_trx.primary_unit_of_measure);

   /*
   ** Override the receipt_source_code if it is set to ASN
   */
   IF (rcv_trx.receipt_source_code in ('ASN','LCM'))THEN -- lcm changes

	rcv_trx.receipt_source_code := 'VENDOR';

   END IF;

   IF (rcv_trx.destination_type_code = 'INVENTORY' AND
        (rcv_trx.auto_transact_code = 'DELIVER' OR
          rcv_trx.transaction_type = 'DELIVER')) THEN

         X_default_subinventory := rcv_trx.subinventory;
         X_default_locator_id   := rcv_trx.locator_id;

         /*
         ** Call the put away function
         */
         X_success := rcv_sub_locator_sv.put_away_api (
			 rcv_trx.po_line_location_id,
                         rcv_trx.po_distribution_id,
			 rcv_trx.shipment_line_id,
                         rcv_trx.receipt_source_code ,
                         rcv_trx.from_organization_id,
                         rcv_trx.to_organization_id,
			 rcv_trx.item_id,
			 rcv_trx.item_revision,
			 rcv_trx.vendor_id,
			 rcv_trx.ship_to_location_id,
    			 rcv_trx.deliver_to_location_id,
    			 rcv_trx.deliver_to_person_id	,
                         rcv_trx.quantity,
                         rcv_trx.primary_quantity,
			 rcv_trx.primary_unit_of_measure,
			 x_tolerable_quantity	,
                         rcv_trx.unit_of_measure,
			 rcv_trx.routing_header_id,
                         x_default_subinventory ,
                         x_default_locator_id   ,
                         rcv_trx.subinventory,
                         rcv_trx.locator_id);

   END IF;

   RETURN;

   EXCEPTION
   WHEN OTHERS THEN
      po_message_s.sql_error('set_trx_defaults', X_progress, sqlcode);
   RAISE;

END set_trx_defaults;


/*===========================================================================

  PROCEDURE NAME:	print_receord

===========================================================================*/

/*
**   Prints a transaction record
*/

PROCEDURE print_record (rcv_trx IN OUT NOCOPY rcv_transactions_interface%ROWTYPE) IS

BEGIN
	htp.code('-------------- Transactions Definition ------------------');  htp.nl;
        htp.code('interface_transaction_id   :			' ||
            to_char(rcv_trx.interface_transaction_id)); htp.nl;
        htp.code('transaction_type           :			' ||
            rcv_trx.transaction_type); htp.nl;
        htp.code('auto_transact_code         : ' ||
            rcv_trx.auto_transact_code); htp.nl;
        htp.code('transaction_date           : ' ||
            to_char(rcv_trx.transaction_date)); htp.nl;
        htp.code('quantity                   : ' ||
            TO_CHAR(rcv_trx.quantity)); htp.nl;
        htp.code('unit_of_measure            : ' ||
            rcv_trx.unit_of_measure); htp.nl;
        htp.code('po_line_location_id        : ' ||
            to_char(rcv_trx.po_line_location_id)); htp.nl;
        htp.code('shipment_line_id           : ' ||
            to_char(rcv_trx.shipment_line_id)); htp.nl;
        htp.code('item_id                    : ' ||
            to_char(rcv_trx.item_id)); htp.nl;
        htp.code('item_revision              : ' ||
            rcv_trx.item_revision); htp.nl;
        htp.code('vendor_id                  : ' ||
            to_char(rcv_trx.vendor_id)); htp.nl;
        htp.code('from_organization_id       : ' ||
            to_char(rcv_trx.from_organization_id)); htp.nl;
        htp.code('to_organization_id         : ' ||
            to_char(rcv_trx.to_organization_id)); htp.nl;
        htp.code('expected_receipt_date      : ' ||
            to_char(rcv_trx.expected_receipt_date)); htp.nl;
        htp.code('routing_header_id          : ' ||
            to_char(rcv_trx.routing_header_id)); htp.nl;
        htp.code('destination_type_code      : ' ||
            rcv_trx.destination_type_code); htp.nl;
        htp.code('po_distribution_id         : ' ||
            TO_CHAR(rcv_trx.po_distribution_id)); htp.nl;
        htp.code('deliver_to_person_id       : ' ||
            TO_CHAR(rcv_trx.deliver_to_person_id)); htp.nl;
        htp.code('deliver_to_location_id     : ' ||
            TO_CHAR(rcv_trx.deliver_to_location_id)); htp.nl;
        htp.code('subinventory               : ' ||
            rcv_trx.subinventory); htp.nl;
        htp.code('locator_id                 : ' ||
            TO_CHAR(rcv_trx.locator_id)); htp.nl;
        htp.code('wip_entity_id              : ' ||
            TO_CHAR(rcv_trx.wip_entity_id)); htp.nl;
        htp.code('wip_line_id                : ' ||
            TO_CHAR(rcv_trx.wip_line_id)); htp.nl;
        htp.code('wip_repetitive_schedule_id : ' ||
            TO_CHAR(rcv_trx.wip_repetitive_schedule_id)); htp.nl;
        htp.code('wip_operation_seq_num      : ' ||
            TO_CHAR(rcv_trx.wip_operation_seq_num)); htp.nl;
        htp.code('wip_resource_seq_num       : ' ||
            TO_CHAR(rcv_trx.wip_resource_seq_num)); htp.nl;
        htp.code('bom_resource_id            : ' ||
            TO_CHAR(rcv_trx.bom_resource_id)); htp.nl; htp.nl;

END print_record;

/*===========================================================================

  PROCEDURE NAME:	Insert_Interface_Errors

===========================================================================*/

/*
**   Insert into PO_INTERFACE_ERRORS table
*/

 PROCEDURE  insert_interface_errors ( rcv_trx IN OUT NOCOPY rcv_transactions_interface%ROWTYPE,
                                      X_column_name IN VARCHAR2,
                                      X_err_message IN VARCHAR2) as

  X_progress VARCHAR2(3) := '000';

 begin

       X_progress := '050';

      /* Bug 4773978: Added the following code for logging error messages
                      in PO_INTERFACE_ERRORS table and removed the Insert
                      statements to insert into PO_INTERFACE_ERRORS
                      table, as the fields error_message, interface_line_id
                      and interface_header_id are not populated. */
       RCV_ERROR_PKG.set_error_message(X_err_message);
       RCV_ERROR_PKG.log_interface_error(X_column_name,FALSE);

 end insert_interface_errors;

End rcv_express_sv;

/

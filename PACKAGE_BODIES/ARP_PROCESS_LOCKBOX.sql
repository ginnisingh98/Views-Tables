--------------------------------------------------------
--  DDL for Package Body ARP_PROCESS_LOCKBOX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_PROCESS_LOCKBOX" AS
/*$Header: ARRPRLBB.pls 120.21.12010000.12 2010/01/07 11:48:31 aghoraka ship $*/
TYPE option_record IS RECORD(
                        option_name  ar_lookups.lookup_code%type,
                        cursor_name  INTEGER);
TYPE opened_cursors IS table of option_record
  INDEX BY BINARY_INTEGER;
TYPE curr_record IS RECORD ( currency_code fnd_currencies.currency_code%TYPE,
                               precision fnd_currencies.precision%TYPE );
TYPE table_curr IS TABLE OF curr_record INDEX BY BINARY_INTEGER;
--
opened_cursor_table               opened_cursors;
g_matching_option                 ar_lookups.lookup_code%type;
g_cursor_name                     INTEGER;
g_total_maching_options           INTEGER;
g_cursor_string                   VARCHAR2(32767);
l_cursor_string                   VARCHAR2(32767);
g_include_closed_inv		  VARCHAR2(1); /* Bug 9156980 */
l_table_curr                      table_curr;
--
  CURSOR all_matching_options IS
   select LOOKUP_CODE
   from   ar_lookups
   where  LOOKUP_TYPE = 'ARLPLB_MATCHING_OPTION'
   order by decode(LOOKUP_CODE, 'INVOICE', 1,
                                'SALES_ORDER', 2,
                                'PURCHASE_ORDER', 3,
                                'CONSOLIDATE_BILL', 4,
                                                   100);
--
--
/*----------------------------------------------------------------------------
| Procedure
|     auto_associate
|
|   Logic:
|    Fetch (using cursor matching_number) all 8 matching numbers, matching dates
|      and installments for each record, for given lockbox/batch and item number.
|    Call find_cust_and_trx_num for each payment/overflow record to get the
|      customer id and trx numbers.
|    If find_cust_and_trx_num returns matched_flag = TRUE, then compare the
|      l_customer_id with l_prev_customer_id. If they are same update the
|      record in ar_payments_interface for returned trx_number, trx_date and
|      installment number.
|    If find_cust_and_trx_num returns matched_flag = FALSE, then rollback
|      the updates for current item number.
|    If all the customers are same for given item number,
|      return p_out_customer_identified = 1, p_out_customer_id = identfied customer id.
|     Else return p_out_customer_identified = 0, p_out_customer_id = NULL.
|
|    Modification History
|       28-Jul-97   K Trivedi    Created.
|       24-Sep-97   K Trivedi    Modified to populate match_resolved_using
|                                 column in ar_payments_interface.
 ----------------------------------------------------------------------------*/
PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

PROCEDURE auto_associate(
                          p_transmission_id IN VARCHAR2,
                          p_payment_rec_type IN VARCHAR2,
                          p_overflow_rec_type IN VARCHAR2,
                          p_item_num IN ar_payments_interface.item_number%type,
                          p_batch_name IN ar_payments_interface.batch_name%type,
                          p_lockbox_number IN ar_payments_interface.lockbox_number%type,
                          p_batches IN VARCHAR2,
                          p_only_one_lb IN VARCHAR2,
                          p_use_matching_date IN ar_lockboxes.use_matching_date%type,
                          p_lockbox_matching_option IN ar_lockboxes.lockbox_matching_option%type,
                          p_pay_unrelated_invoices IN VARCHAR2,
                          p_out_customer_id OUT NOCOPY NUMBER,
                          p_out_customer_identified OUT NOCOPY NUMBER
                         ) IS
--
l_transmission_id         VARCHAR2(50);
l_payment_rec_type        VARCHAR2(3);
l_overflow_rec_type       VARCHAR2(3);
l_item_num                ar_payments_interface.item_number%type;
l_batch_name              ar_payments_interface.batch_name%type;
l_lockbox_number          ar_payments_interface.lockbox_number%type;
l_batches                 VARCHAR2(2);
l_only_one_lb             VARCHAR2(2);
l_use_matching_date       ar_lockboxes.use_matching_date%type;
l_lockbox_matching_option ar_lockboxes.lockbox_matching_option%type;
l_match_flag              VARCHAR2(10);
l_rowid                   ROWID;
l_pay_unrelated_invoices  VARCHAR2(2);
l_receipt_date            ar_payments_interface.receipt_date%type;
l_no_batch_or_lb    	  VARCHAR2(2);  -- bug2980051
--
l_matching_number1        ar_payments_interface.invoice1%type;
l_matching_number2        ar_payments_interface.invoice2%type;
l_matching_number3        ar_payments_interface.invoice3%type;
l_matching_number4        ar_payments_interface.invoice4%type;
l_matching_number5        ar_payments_interface.invoice5%type;
l_matching_number6        ar_payments_interface.invoice6%type;
l_matching_number7        ar_payments_interface.invoice7%type;
l_matching_number8        ar_payments_interface.invoice8%type;
--
l_matching1_date          ar_payments_interface.matching1_date%type;
l_matching2_date          ar_payments_interface.matching2_date%type;
l_matching3_date          ar_payments_interface.matching3_date%type;
l_matching4_date          ar_payments_interface.matching4_date%type;
l_matching5_date          ar_payments_interface.matching5_date%type;
l_matching6_date          ar_payments_interface.matching6_date%type;
l_matching7_date          ar_payments_interface.matching7_date%type;
l_matching8_date          ar_payments_interface.matching8_date%type;
--
l_matching1_installment   ar_payments_interface.invoice1_installment%type;
l_matching2_installment   ar_payments_interface.invoice2_installment%type;
l_matching3_installment   ar_payments_interface.invoice3_installment%type;
l_matching4_installment   ar_payments_interface.invoice4_installment%type;
l_matching5_installment   ar_payments_interface.invoice5_installment%type;
l_matching6_installment   ar_payments_interface.invoice6_installment%type;
l_matching7_installment   ar_payments_interface.invoice7_installment%type;
l_matching8_installment   ar_payments_interface.invoice8_installment%type;
--
l_match1_status           ar_payments_interface.invoice1_status%type;
l_match2_status           ar_payments_interface.invoice2_status%type;
l_match3_status           ar_payments_interface.invoice3_status%type;
l_match4_status           ar_payments_interface.invoice4_status%type;
l_match5_status           ar_payments_interface.invoice5_status%type;
l_match6_status           ar_payments_interface.invoice6_status%type;
l_match7_status           ar_payments_interface.invoice7_status%type;
l_match8_status           ar_payments_interface.invoice8_status%type;
--
l_prev_customer_id        ar_payments_interface.customer_id%type;
l_customer_id             ar_payments_interface.customer_id%type;
l_matching_option         ar_lookups.lookup_code%type;
--
unexpected_program_error  EXCEPTION;
--
   /* Bug2980051. Replaced l_only_one_lb with l_no_batch_or_lb  */
   CURSOR matching_numbers IS
       select
         rowid,
         receipt_date,
         invoice1, matching1_date, invoice1_installment,
         invoice2, matching2_date, invoice2_installment,
         invoice3, matching3_date, invoice3_installment,
         invoice4, matching4_date, invoice4_installment,
         invoice5, matching5_date, invoice5_installment,
         invoice6, matching6_date, invoice6_installment,
         invoice7, matching7_date, invoice7_installment,
         invoice8, matching8_date, invoice8_installment
       from   ar_payments_interface pi
       where  pi.transmission_id = l_transmission_id
       and    pi.record_type||'' in ( l_payment_rec_type, l_overflow_rec_type )
       and    pi.customer_id is null
       and    pi.status = 'AR_PLB_CONTROLS_OK'
       and    pi.item_number = l_item_num
       and    ( pi.batch_name = l_batch_name
	        or
	        ( pi.lockbox_number = l_lockbox_number
	          and
	          l_batches = 'N'
	        )
	        or
	        l_no_batch_or_lb = 'Y'
              );
--
BEGIN
  debug1('arp_process_lockbox.auto_associate()+');
  --
  -- Assign variables to local values.
  --
  l_transmission_id := p_transmission_id;
  l_payment_rec_type := p_payment_rec_type;
  l_overflow_rec_type := p_overflow_rec_type;
  l_item_num := p_item_num;
  l_batch_name := p_batch_name;
  l_lockbox_number := p_lockbox_number;
  l_batches := p_batches;
  l_only_one_lb := p_only_one_lb;
  l_use_matching_date := p_use_matching_date;
  l_lockbox_matching_option := p_lockbox_matching_option;
  l_pay_unrelated_invoices := p_pay_unrelated_invoices;

  /* Bugfix 2980051 */
  IF l_batches = 'N' AND l_only_one_lb = 'Y' THEN
      l_no_batch_or_lb := 'Y';
  ELSE
      l_no_batch_or_lb := 'N';
  END IF;
  --
  debug1('Input parameters to the package...');
  debug1('l_transmission_id ' || l_transmission_id);
  debug1('l_payment_rec_type ' || l_payment_rec_type);
  debug1('l_overflow_rec_type ' || l_overflow_rec_type);
  debug1('l_item_num ' || to_char(l_item_num));
  debug1('l_batch_name ' || l_batch_name);
  debug1('l_lockbox_number ' || l_lockbox_number);
  debug1('l_batches ' || l_batches);
  debug1('l_only_one_lb ' || l_only_one_lb);
  debug1('l_use_matching_date ' || l_use_matching_date);
  debug1('l_lockbox_matching_option ' || l_lockbox_matching_option);
  debug1('l_pay_unrelated_invoices ' || l_pay_unrelated_invoices);
  debug1('l_no_batch_or_lb ' || l_no_batch_or_lb); -- bug2980051
  --
  -- Define Save point here. If unique customer cannot be identified for
  -- all the matching numbers passed for given item, we need to rollback
  -- the updates made in this procedure. That time we will rollback to
  -- this point.
  --
  --
  SAVEPOINT before_this_item;
--
  /* l_prev_customer_id = -8888, indicates that sofar find_cust_and_trx_num
     has NOT returned match_flag TRUE. If find_cust_and_trx_num returns
     TRUE, it means there was atleast one matching number for which the
     customer could be identified. */
--
  l_prev_customer_id := -8888;
--
  /* Logic with l_matching_option is as follows:
     Let's say there are four overflow records with a receipt record.
     If the invoice1 mentioned on 1st record matches to a purchase order
     number, the program should expect other numbers on that receipt also
     as purchase order number and need not match them with Invoice and/or
     Sales order number.

     When there is a new receipt record (i.e., new item number)
     it should start matching with All. Therefore initilising
     l_matching_option as 'ALL' everytime there is a new item number.

     find_cust_and_trx_num will return p_in_out_matching_option, once it finds
     a match. Next record in loop onwards till the end of loop,
     find_cust_and_trx_num will match only using that l_matching_option.
  */
--
   l_matching_option := 'ALL';
--
--
  OPEN matching_numbers;
  debug1('Opened cursor matching_numbers.');
  --
  LOOP
  FETCH matching_numbers INTO
      l_rowid,
      l_receipt_date,
      l_matching_number1, l_matching1_date, l_matching1_installment,
      l_matching_number2, l_matching2_date, l_matching2_installment,
      l_matching_number3, l_matching3_date, l_matching3_installment,
      l_matching_number4, l_matching4_date, l_matching4_installment,
      l_matching_number5, l_matching5_date, l_matching5_installment,
      l_matching_number6, l_matching6_date, l_matching6_installment,
      l_matching_number7, l_matching7_date, l_matching7_installment,
      l_matching_number8, l_matching8_date, l_matching8_installment;
  EXIT WHEN matching_numbers%NOTFOUND;
  --
  debug1('Fetched data for cursor matching_numbers.');
  debug1('l_matching_number1 ' || l_matching_number1);
  debug1('l_matching1_installment ' || l_matching1_installment);
  debug1('l_matching1_date ' || to_char(l_matching1_date));
  --
  -- There are two matching options passed to find_cust_and_trx_num.
  -- lockbox_matching_option is the one, which is setup at the
  -- lockbox level for the current lockbox.
  -- whereas, l_matching_option is the one matched for the current
  -- receipt.
  --
  find_cust_and_trx_num(
      p_transmission_id=>l_transmission_id,
      p_payment_rec_type=>l_payment_rec_type,
      p_overflow_rec_type=>l_overflow_rec_type,
      p_item_num=>l_item_num,
      p_batch_name=>l_batch_name,
      p_lockbox_number=>l_lockbox_number,
      p_batches=>l_batches,
      p_receipt_date=>l_receipt_date,
      p_only_one_lb=>l_only_one_lb,
      p_use_matching_date=>l_use_matching_date,
      p_lockbox_matching_option=>l_lockbox_matching_option,
      p_pay_unrelated_invoices=>l_pay_unrelated_invoices,
      p_matching_number1=>l_matching_number1,
      p_matching1_date=>l_matching1_date,
      p_matching1_installment=>l_matching1_installment,
      p_matching_number2=>l_matching_number2,
      p_matching2_date=>l_matching2_date,
      p_matching2_installment=>l_matching2_installment,
      p_matching_number3=>l_matching_number3,
      p_matching3_date=>l_matching3_date,
      p_matching3_installment=>l_matching3_installment,
      p_matching_number4=>l_matching_number4,
      p_matching4_date=>l_matching4_date,
      p_matching4_installment=>l_matching4_installment,
      p_matching_number5=>l_matching_number5,
      p_matching5_date=>l_matching5_date,
      p_matching5_installment=>l_matching5_installment,
      p_matching_number6=>l_matching_number6,
      p_matching6_date=>l_matching6_date,
      p_matching6_installment=>l_matching6_installment,
      p_matching_number7=>l_matching_number7,
      p_matching7_date=>l_matching7_date,
      p_matching7_installment=>l_matching7_installment,
      p_matching_number8=>l_matching_number8,
      p_matching8_date=>l_matching8_date,
      p_matching8_installment=>l_matching8_installment,
      p_matched_flag=>l_match_flag,
      p_customer_id=>l_customer_id,
      p_matching_option=>l_matching_option,
      p_match1_status=>l_match1_status,
      p_match2_status=>l_match2_status,
      p_match3_status=>l_match3_status,
      p_match4_status=>l_match4_status,
      p_match5_status=>l_match5_status,
      p_match6_status=>l_match6_status,
      p_match7_status=>l_match7_status,
      p_match8_status=>l_match8_status
    );
  --
  IF (l_match_flag = 'PROGRAM_ERROR') THEN
      raise unexpected_program_error;
  END IF;
  --
  IF ((l_match_flag = 'TRUE') and (l_prev_customer_id = -8888) and
      (l_customer_id is NOT NULL)) THEN
       --
       debug1('first_customer has been identified using matching number');
       --
       -- match_flag will be returned TRUE only if there was no mismatch
       -- among eight invoices passed and customer could be identified
       --
       l_prev_customer_id := l_customer_id;
  END IF;
  --
     IF ((l_customer_id = l_prev_customer_id) AND (l_match_flag = 'TRUE')) THEN
       --
       -- If the customer_id was identified uniquely,
       -- update the current record of ar_payments_interface table
       -- with returned values from  find_cust_and_trx_num procedure.
       -- Also update the status to indicate that Resolved columns were
       -- populated.
       -- customer_id is populated in arlvaa(), here we are updating the
       -- trx_number values and related details. It is possible that
       -- customer_id was identified, but trx_number was not identified
       -- uniquely. In that case matching_number will be NULL.
       --
       debug1('Updating ar_payments_interface for resolved columns..');
       debug1('l_matching_number1 ' || l_matching_number1);
       debug1('l_matching1_installment ' || l_matching1_installment);
       debug1('l_matching1_date ' || to_char(l_matching1_date));
       --
       UPDATE ar_payments_interface
       SET    resolved_matching_number1 = l_matching_number1,
              resolved_matching1_installment = l_matching1_installment,
              resolved_matching1_date = l_matching1_date,
              invoice1_status = l_match1_status,
              resolved_matching_number2 = l_matching_number2,
              resolved_matching2_installment = l_matching2_installment,
              resolved_matching2_date = l_matching2_date,
              invoice2_status = l_match2_status,
              resolved_matching_number3 = l_matching_number3,
              resolved_matching3_installment = l_matching3_installment,
              resolved_matching3_date = l_matching3_date,
              invoice3_status = l_match3_status,
              resolved_matching_number4 = l_matching_number4,
              resolved_matching4_installment = l_matching4_installment,
              resolved_matching4_date = l_matching4_date,
              invoice4_status = l_match4_status,
              resolved_matching_number5 = l_matching_number5,
              resolved_matching5_installment = l_matching5_installment,
              resolved_matching5_date = l_matching5_date,
              invoice5_status = l_match5_status,
              resolved_matching_number6 = l_matching_number6,
              resolved_matching6_installment = l_matching6_installment,
              resolved_matching6_date = l_matching6_date,
              invoice6_status = l_match6_status,
              resolved_matching_number7 = l_matching_number7,
              resolved_matching7_installment = l_matching7_installment,
              resolved_matching7_date = l_matching7_date,
              invoice7_status = l_match7_status,
              resolved_matching_number8 = l_matching_number8,
              resolved_matching8_installment = l_matching8_installment,
              resolved_matching8_date = l_matching8_date,
              invoice8_status = l_match8_status,
              match_resolved_using = l_matching_option
       WHERE  rowid = l_rowid;
	/*5052049*/
	IF l_matching_option='CONSOLIDATE_BILL' then
       		UPDATE AR_PAYMENTS_INTERFACE SET  tmp_amt_applied1=amount_applied1,
       			tmp_amt_applied2=amount_applied2,
       			tmp_amt_applied3=amount_applied3,
       			tmp_amt_applied4=amount_applied4,
       			tmp_amt_applied5=amount_applied5,
       			tmp_amt_applied6=amount_applied6,
       			tmp_amt_applied7=amount_applied7,
       			tmp_amt_applied8=amount_applied8,
			amount_applied1 = null,
	      		amount_applied2= null,
	      		amount_applied3= null,
	      		amount_applied4= null,
	      		amount_applied5= null,
	      		amount_applied6= null,
	      		amount_applied7= null,
	      		amount_applied8= null
       		WHERE  rowid = l_rowid and match_resolved_using='CONSOLIDATE_BILL';
	END IF;

        --
        -- Using rowid here for getting the current record, as ar_payments_interface
        -- does not have any other primary key.
        --
  /* Bug 2106408. Added the following ELSIF */
  ELSIF (l_match_flag = 'FALSE') AND
	(l_customer_id = -7777)
  THEN
    debug1('Auto_associate : Duplicate Matching Number');
    CLOSE matching_numbers;
    ROLLBACK TO SAVEPOINT before_this_item;
    GOTO return_duplicate;
  --
  ELSIF ((l_match_flag = 'FALSE') OR
         (l_customer_id <> l_prev_customer_id) OR
         (l_match_flag = 'NO_MATCH'))
  THEN
    --
    -- If find_cust_and_trx_num returns l_match_flag = FALSE
    -- or it returns the customer_id that was not same as l_prev_customer_id
    -- we cannot identify the customer uniquely.
    -- Close the cursor, Rollback to savepoint and Goto return_no_match
    -- in this case.
    --
    debug1('Rolling back to the savepoint l_match_flag ' || l_match_flag);
    debug1('l_customer_id ' || to_char(l_customer_id));
    debug1('l_prev_customer_id ' || to_char(l_prev_customer_id));
    --
    CLOSE matching_numbers;
    ROLLBACK TO SAVEPOINT before_this_item;
    --
    debug1('Closed cursor matching_numbers and Rolled back ');
    GOTO return_no_match;
  END IF;
  --
  --
  END LOOP; -- End loop for matching_numbers cursor.
  CLOSE matching_numbers;
  --
  -- Check if there was any record that had matching numbers
  -- and we could identify the customer from that.
  --
  IF (l_prev_customer_id = -8888) THEN
    -- actually in this case there were no database changes made
    -- but as we could not resolve customer_id, so we want to
    -- go back to a point from where we started.
    ROLLBACK TO SAVEPOINT before_this_item;
    GOTO return_no_match;
  END IF;
  --
  -- If the program reached here, means all records were successfully
  -- identified to a single customer.
  --
    p_out_customer_id := l_customer_id;
    p_out_customer_identified := 1;
    debug1('arp_process_lockbox.auto_associate(1)-');
    RETURN;
  --
<<return_no_match>>
       -- If there was no match found, then also we must populate the
       -- resolved columns as the program looks at resolved columns only
       -- from hence forth.
       /* Bug2980051. Replaced l_only_one_lb with l_no_batch_or_lb  */
       UPDATE ar_payments_interface pi
       SET    resolved_matching_number1 = invoice1,
              resolved_matching1_installment = invoice1_installment,
              resolved_matching1_date = matching1_date,
              invoice1_status = decode(invoice1, null, null, 'AR_PLB_INVALID_MATCH'),
              resolved_matching_number2 = invoice2,
              resolved_matching2_installment = invoice2_installment,
              resolved_matching2_date = matching2_date,
              invoice2_status = decode(invoice2, null, null, 'AR_PLB_INVALID_MATCH'),
              resolved_matching_number3 = invoice3,
              resolved_matching3_installment = invoice3_installment,
              resolved_matching3_date = matching3_date,
              invoice3_status = decode(invoice3, null, null, 'AR_PLB_INVALID_MATCH'),
              resolved_matching_number4 = invoice4,
              resolved_matching4_installment = invoice4_installment,
              resolved_matching4_date = matching4_date,
              invoice4_status = decode(invoice4, null, null, 'AR_PLB_INVALID_MATCH'),
              resolved_matching_number5 = invoice5,
              resolved_matching5_installment = invoice5_installment,
              resolved_matching5_date = matching5_date,
              invoice5_status = decode(invoice5, null, null, 'AR_PLB_INVALID_MATCH'),
              resolved_matching_number6 = invoice6,
              resolved_matching6_installment = invoice6_installment,
              resolved_matching6_date = matching6_date,
              invoice6_status = decode(invoice6, null, null, 'AR_PLB_INVALID_MATCH'),
              resolved_matching_number7 = invoice7,
              resolved_matching7_installment = invoice7_installment,
              resolved_matching7_date = matching7_date,
              invoice7_status = decode(invoice7, null, null, 'AR_PLB_INVALID_MATCH'),
              resolved_matching_number8 = invoice8,
              resolved_matching8_installment = invoice8_installment,
              resolved_matching8_date = matching8_date,
              invoice8_status = decode(invoice8, null, null, 'AR_PLB_INVALID_MATCH'),
              match_resolved_using = null
       where  pi.transmission_id = l_transmission_id
       and    pi.record_type||'' in ( l_payment_rec_type, l_overflow_rec_type )
       and    pi.customer_id is null
       and    pi.status = 'AR_PLB_CONTROLS_OK'
       and    pi.item_number = l_item_num
       and    ( pi.batch_name = l_batch_name
                or
                ( pi.lockbox_number = l_lockbox_number
                  and
                  l_batches = 'N'
                )
                or
                l_no_batch_or_lb = 'Y'
              );
  --
  -- Following values will be used by arlvaa()
  p_out_customer_identified := 0;
  p_out_customer_id := NULL;
  debug1('arp_process_lockbox.auto_associate(2)-');
  RETURN;
/* Bug 2106408. Added the following UPDATE */
<<return_duplicate>>
       /* Bug2980051. Replaced l_only_one_lb with l_no_batch_or_lb  */
       UPDATE ar_payments_interface pi
       SET    resolved_matching_number1 = invoice1,
              resolved_matching1_installment = invoice1_installment,
              resolved_matching1_date = matching1_date,
              invoice1_status = decode(invoice1, null, null, 'AR_PLB_DUP_INV'),
              resolved_matching_number2 = invoice2,
              resolved_matching2_installment = invoice2_installment,
              resolved_matching2_date = matching2_date,
              invoice2_status = decode(invoice2, null, null, 'AR_PLB_DUP_INV'),
              resolved_matching_number3 = invoice3,
              resolved_matching3_installment = invoice3_installment,
              resolved_matching3_date = matching3_date,
              invoice3_status = decode(invoice3, null, null, 'AR_PLB_DUP_INV'),
              resolved_matching_number4 = invoice4,
              resolved_matching4_installment = invoice4_installment,
              resolved_matching4_date = matching4_date,
              invoice4_status = decode(invoice4, null, null, 'AR_PLB_DUP_INV'),
              resolved_matching_number5 = invoice5,
              resolved_matching5_installment = invoice5_installment,
              resolved_matching5_date = matching5_date,
              invoice5_status = decode(invoice5, null, null, 'AR_PLB_DUP_INV'),
              resolved_matching_number6 = invoice6,
              resolved_matching6_installment = invoice6_installment,
              resolved_matching6_date = matching6_date,
              invoice6_status = decode(invoice6, null, null, 'AR_PLB_DUP_INV'),
              resolved_matching_number7 = invoice7,
              resolved_matching7_installment = invoice7_installment,
              resolved_matching7_date = matching7_date,
              invoice7_status = decode(invoice7, null, null, 'AR_PLB_DUP_INV'),
              resolved_matching_number8 = invoice8,
              resolved_matching8_installment = invoice8_installment,
              resolved_matching8_date = matching8_date,
              invoice8_status = decode(invoice8, null, null, 'AR_PLB_DUP_INV'),
              match_resolved_using = null
       where  pi.transmission_id = l_transmission_id
       and    pi.record_type||'' in ( l_payment_rec_type, l_overflow_rec_type )
       and    pi.customer_id is null
       and    pi.status = 'AR_PLB_CONTROLS_OK'
       and    pi.item_number = l_item_num
       and    ( pi.batch_name = l_batch_name
                or
                ( pi.lockbox_number = l_lockbox_number
                  and
                  l_batches = 'N'
                )
                or
                l_no_batch_or_lb = 'Y'
              );
  p_out_customer_identified := 0;
  p_out_customer_id := NULL;
  debug1('arp_process_lockbox.auto_associate : Duplicate Matching');
  RETURN;
--
  EXCEPTION
    -- WHEN no_data_found
    --         THEN null;
    WHEN others
            THEN RAISE;
  debug1('arp_process_lockbox.auto_associate(3)-');
  RETURN;
END auto_associate;
--
--
/*----------------------------------------------------------------------------
| Procedure
|     populate_resolved_columns
|
|   Logic:
|    Fetch (using cursor matching_number) all 8 matching numbers, matching dates
|      and installments for each record, for given lockbox/batch and item number.
|    Call find_cust_and_trx_num for each payment/overflow record to get the
|      trx numbers.
|    Update record in ar_payments_interface for returned trx_number, trx_date and
|      installment number.
|
|    Modification History
|       30-Jul-97   K Trivedi    Created. Rel 11 related changes.
|       24-Sep-97   K Trivedi    Modified to populate match_resolved_using
|                                 column in ar_payments_interface.
|
 ----------------------------------------------------------------------------*/
PROCEDURE populate_resolved_columns(
                          p_transmission_id IN VARCHAR2,
                          p_payment_rec_type IN VARCHAR2,
                          p_overflow_rec_type IN VARCHAR2,
                          p_item_num IN ar_payments_interface.item_number%type,
                          p_batch_name IN ar_payments_interface.batch_name%type,
                          p_lockbox_number IN ar_payments_interface.lockbox_number%type,
                          p_batches IN VARCHAR2,
                          p_only_one_lb IN VARCHAR2,
                          p_use_matching_date IN ar_lockboxes.use_matching_date%type,
                          p_lockbox_matching_option IN ar_lockboxes.lockbox_matching_option%type,
                          p_pay_unrelated_invoices IN VARCHAR2
                         ) IS
--
l_transmission_id         VARCHAR2(50);
l_payment_rec_type        VARCHAR2(3);
l_overflow_rec_type       VARCHAR2(3);
l_item_num                ar_payments_interface.item_number%type;
l_batch_name              ar_payments_interface.batch_name%type;
l_lockbox_number          ar_payments_interface.lockbox_number%type;
l_batches                 VARCHAR2(2);
l_only_one_lb             VARCHAR2(2);
l_use_matching_date       ar_lockboxes.use_matching_date%type;
l_lockbox_matching_option ar_lockboxes.lockbox_matching_option%type;
l_match_flag              VARCHAR2(10);
l_rowid                   ROWID;
l_pay_unrelated_invoices  VARCHAR2(2);
l_receipt_date            ar_payments_interface.receipt_date%type;

l_no_batch_or_lb          VARCHAR2(2); -- bug2980051
--
l_matching_number1        ar_payments_interface.invoice1%type;
l_matching_number2        ar_payments_interface.invoice2%type;
l_matching_number3        ar_payments_interface.invoice3%type;
l_matching_number4        ar_payments_interface.invoice4%type;
l_matching_number5        ar_payments_interface.invoice5%type;
l_matching_number6        ar_payments_interface.invoice6%type;
l_matching_number7        ar_payments_interface.invoice7%type;
l_matching_number8        ar_payments_interface.invoice8%type;
--
l_matching1_date          ar_payments_interface.matching1_date%type;
l_matching2_date          ar_payments_interface.matching2_date%type;
l_matching3_date          ar_payments_interface.matching3_date%type;
l_matching4_date          ar_payments_interface.matching4_date%type;
l_matching5_date          ar_payments_interface.matching5_date%type;
l_matching6_date          ar_payments_interface.matching6_date%type;
l_matching7_date          ar_payments_interface.matching7_date%type;
l_matching8_date          ar_payments_interface.matching8_date%type;
--
l_matching1_installment   ar_payments_interface.invoice1_installment%type;
l_matching2_installment   ar_payments_interface.invoice2_installment%type;
l_matching3_installment   ar_payments_interface.invoice3_installment%type;
l_matching4_installment   ar_payments_interface.invoice4_installment%type;
l_matching5_installment   ar_payments_interface.invoice5_installment%type;
l_matching6_installment   ar_payments_interface.invoice6_installment%type;
l_matching7_installment   ar_payments_interface.invoice7_installment%type;
l_matching8_installment   ar_payments_interface.invoice8_installment%type;
--
l_match1_status           ar_payments_interface.invoice1_status%type;
l_match2_status           ar_payments_interface.invoice2_status%type;
l_match3_status           ar_payments_interface.invoice3_status%type;
l_match4_status           ar_payments_interface.invoice4_status%type;
l_match5_status           ar_payments_interface.invoice5_status%type;
l_match6_status           ar_payments_interface.invoice6_status%type;
l_match7_status           ar_payments_interface.invoice7_status%type;
l_match8_status           ar_payments_interface.invoice8_status%type;
--
l_customer_id             ar_payments_interface.customer_id%type;
l_matching_option         ar_lookups.lookup_code%type;
--
unexpected_program_error  EXCEPTION;
--
   /* Bug2980051. Replaced l_only_one_lb with l_no_batch_or_lb  */
   CURSOR matching_numbers IS
       select
         rowid, customer_id,
         receipt_date,
         invoice1, matching1_date, invoice1_installment,
         invoice2, matching2_date, invoice2_installment,
         invoice3, matching3_date, invoice3_installment,
         invoice4, matching4_date, invoice4_installment,
         invoice5, matching5_date, invoice5_installment,
         invoice6, matching6_date, invoice6_installment,
         invoice7, matching7_date, invoice7_installment,
         invoice8, matching8_date, invoice8_installment
       from   ar_payments_interface pi
       where  pi.transmission_id = l_transmission_id
       and    pi.record_type||'' in ( l_payment_rec_type, l_overflow_rec_type )
       and    pi.customer_id is NOT null
       and    pi.status in ('AR_PLB_CUST_OK', 'AR_PLB_MICR_OK')
       and    pi.item_number = l_item_num
       and    ( pi.batch_name = l_batch_name
	        or
	        ( pi.lockbox_number = l_lockbox_number
	          and
	          l_batches = 'N'
	        )
	        or
	        l_no_batch_or_lb = 'Y'
              );
--
BEGIN
  debug1('arp_process_lockbox.populate_resolved_columns()+');
  --
  -- Assign variables to local values.
  --
  l_transmission_id := p_transmission_id;
  l_payment_rec_type := p_payment_rec_type;
  l_overflow_rec_type := p_overflow_rec_type;
  l_item_num := p_item_num;
  l_batch_name := p_batch_name;
  l_lockbox_number := p_lockbox_number;
  l_batches := p_batches;
  l_only_one_lb := p_only_one_lb;
  l_pay_unrelated_invoices := p_pay_unrelated_invoices;
  l_lockbox_matching_option := p_lockbox_matching_option;
  l_use_matching_date := p_use_matching_date;

  /* Bugfix 2980051 */
  IF l_batches = 'N' AND l_only_one_lb = 'Y' THEN
      l_no_batch_or_lb := 'Y';
  ELSE
      l_no_batch_or_lb := 'N';
  END IF;
  --
  debug1('Input parameters to the package...');
  debug1('l_transmission_id ' || l_transmission_id);
  debug1('l_payment_rec_type ' || l_payment_rec_type);
  debug1('l_overflow_rec_type ' || l_overflow_rec_type);
  debug1('l_item_num ' || to_char(l_item_num));
  debug1('l_batch_name ' || l_batch_name);
  debug1('l_lockbox_number ' || l_lockbox_number);
  debug1('l_batches ' || l_batches);
  debug1('l_only_one_lb ' || l_only_one_lb);
  debug1('l_pay_unrelated_invoices ' || l_pay_unrelated_invoices);
  debug1('l_lockbox_matching_option ' || l_lockbox_matching_option);
  debug1('l_use_matching_date ' || l_use_matching_date);
  debug1('l_no_batch_or_lb ' || l_no_batch_or_lb); --bug2980051
  --
  --
  /* Logic with l_matching_option is as follows:
     Let's say there are four overflow records with a receipt record.
     If the invoice1 mentioned on 1st record matches to a purchase order
     number, the program should expect other numbers on that receipt also
     as purchase order number and need not match them with Invoice and/or
     Sales order number.

     When there is a new receipt record (i.e., new item number)
     it should start matching with All. Therefore initilising
     l_matching_option as 'ALL' everytime there is a new item number.

     find_cust_and_trx_num will return p_in_out_matching_option, once it finds
     a match. Next record in loop onwards till the end of loop,
     find_cust_and_trx_num will match only using that l_matching_option.
  */
--
   l_matching_option := 'ALL';
  --
  --
  OPEN matching_numbers;
  debug1('Opened cursor matching_numbers.');
  --
  LOOP
  FETCH matching_numbers INTO
      l_rowid, l_customer_id,
      l_receipt_date,
      l_matching_number1, l_matching1_date, l_matching1_installment,
      l_matching_number2, l_matching2_date, l_matching2_installment,
      l_matching_number3, l_matching3_date, l_matching3_installment,
      l_matching_number4, l_matching4_date, l_matching4_installment,
      l_matching_number5, l_matching5_date, l_matching5_installment,
      l_matching_number6, l_matching6_date, l_matching6_installment,
      l_matching_number7, l_matching7_date, l_matching7_installment,
      l_matching_number8, l_matching8_date, l_matching8_installment;
  EXIT WHEN matching_numbers%NOTFOUND;
  --
  debug1('Fetched data for cursor matching_numbers.');
  debug1('l_matching_number1 ' || l_matching_number1);
  debug1('l_matching1_installment ' || l_matching1_installment);
  debug1('l_matching1_date ' || to_char(l_matching1_date));
  debug1('l_customer_id ' || to_char(l_customer_id));
  --
  find_cust_and_trx_num(
      p_transmission_id=>l_transmission_id,
      p_payment_rec_type=>l_payment_rec_type,
      p_overflow_rec_type=>l_overflow_rec_type,
      p_item_num=>l_item_num,
      p_batch_name=>l_batch_name,
      p_lockbox_number=>l_lockbox_number,
      p_batches=>l_batches,
      p_receipt_date=>l_receipt_date,
      p_only_one_lb=>l_only_one_lb,
      p_use_matching_date=>l_use_matching_date,
      p_lockbox_matching_option=>l_lockbox_matching_option,
      p_pay_unrelated_invoices=>l_pay_unrelated_invoices,
      p_matching_number1=>l_matching_number1,
      p_matching1_date=>l_matching1_date,
      p_matching1_installment=>l_matching1_installment,
      p_matching_number2=>l_matching_number2,
      p_matching2_date=>l_matching2_date,
      p_matching2_installment=>l_matching2_installment,
      p_matching_number3=>l_matching_number3,
      p_matching3_date=>l_matching3_date,
      p_matching3_installment=>l_matching3_installment,
      p_matching_number4=>l_matching_number4,
      p_matching4_date=>l_matching4_date,
      p_matching4_installment=>l_matching4_installment,
      p_matching_number5=>l_matching_number5,
      p_matching5_date=>l_matching5_date,
      p_matching5_installment=>l_matching5_installment,
      p_matching_number6=>l_matching_number6,
      p_matching6_date=>l_matching6_date,
      p_matching6_installment=>l_matching6_installment,
      p_matching_number7=>l_matching_number7,
      p_matching7_date=>l_matching7_date,
      p_matching7_installment=>l_matching7_installment,
      p_matching_number8=>l_matching_number8,
      p_matching8_date=>l_matching8_date,
      p_matching8_installment=>l_matching8_installment,
      p_matched_flag=>l_match_flag,
      p_customer_id=>l_customer_id,
      p_matching_option=>l_matching_option,
      p_match1_status=>l_match1_status,
      p_match2_status=>l_match2_status,
      p_match3_status=>l_match3_status,
      p_match4_status=>l_match4_status,
      p_match5_status=>l_match5_status,
      p_match6_status=>l_match6_status,
      p_match7_status=>l_match7_status,
      p_match8_status=>l_match8_status
    );
  --
      IF (l_match_flag = 'PROGRAM_ERROR') THEN
          raise unexpected_program_error;
      END IF;
      --
       -- If there were all invalid items on record, find_cust_and_trx_num
       -- would have returned error in the l_matchX_status. So, that record
       -- will error out NOCOPY (or that amount will go UNAPP) in arlvin. In this
       -- case l_match_flag would be no_match.
       --
       -- If there were some matching numbers not matching, l_match_flag
       -- would be TRUE and only those matching_numbers will have corresponding
       -- l_matchX_status as error.
       --
       -- If all matching_numbers were fine then we are updating the
       -- resolved columns correctly.
       --
       -- We donot want to update the record, in case there were no matching_numbers
       -- in the record.
       --
     IF (l_match_flag <> 'NO_ITEM') THEN
       --
       debug1('Updating ar_payments_interface for resolved columns...');
       debug1('l_matching_number1 ' || l_matching_number1);
       debug1('l_matching1_installment ' || l_matching1_installment);
       debug1('l_matching1_date ' || to_char(l_matching1_date));
       --
       UPDATE ar_payments_interface
       SET    resolved_matching_number1 = l_matching_number1,
              resolved_matching1_installment = l_matching1_installment,
              resolved_matching1_date = l_matching1_date,
              invoice1_status = l_match1_status,
              resolved_matching_number2 = l_matching_number2,
              resolved_matching2_installment = l_matching2_installment,
              resolved_matching2_date = l_matching2_date,
              invoice2_status = l_match2_status,
              resolved_matching_number3 = l_matching_number3,
              resolved_matching3_installment = l_matching3_installment,
              resolved_matching3_date = l_matching3_date,
              invoice3_status = l_match3_status,
              resolved_matching_number4 = l_matching_number4,
              resolved_matching4_installment = l_matching4_installment,
              resolved_matching4_date = l_matching4_date,
              invoice4_status = l_match4_status,
              resolved_matching_number5 = l_matching_number5,
              resolved_matching5_installment = l_matching5_installment,
              resolved_matching5_date = l_matching5_date,
              invoice5_status = l_match5_status,
              resolved_matching_number6 = l_matching_number6,
              resolved_matching6_installment = l_matching6_installment,
              resolved_matching6_date = l_matching6_date,
              invoice6_status = l_match6_status,
              resolved_matching_number7 = l_matching_number7,
              resolved_matching7_installment = l_matching7_installment,
              resolved_matching7_date = l_matching7_date,
              invoice7_status = l_match7_status,
              resolved_matching_number8 = l_matching_number8,
              resolved_matching8_installment = l_matching8_installment,
              resolved_matching8_date = l_matching8_date,
              invoice8_status = l_match8_status,
              match_resolved_using = l_matching_option
       WHERE  rowid = l_rowid;
        --
        -- Using rowid here for getting the current record, as ar_payments_interface
        -- does not have any other primary key.
        --
	/*5052049*/
	IF l_matching_option='CONSOLIDATE_BILL' then
       		UPDATE AR_PAYMENTS_INTERFACE SET  tmp_amt_applied1=amount_applied1,
       			tmp_amt_applied2=amount_applied2,
       			tmp_amt_applied3=amount_applied3,
       			tmp_amt_applied4=amount_applied4,
       			tmp_amt_applied5=amount_applied5,
       			tmp_amt_applied6=amount_applied6,
       			tmp_amt_applied7=amount_applied7,
       			tmp_amt_applied8=amount_applied8,
			amount_applied1 = null,
	      		amount_applied2= null,
	      		amount_applied3= null,
	      		amount_applied4= null,
	      		amount_applied5= null,
	      		amount_applied6= null,
	      		amount_applied7= null,
	      		amount_applied8= null
       		WHERE  rowid = l_rowid and match_resolved_using='CONSOLIDATE_BILL';
	END IF;
  END IF;
  --
  --
  END LOOP; -- End loop for matching_numbers cursor.
  CLOSE matching_numbers;
  --
  -- Check if there was any record that had matching numbers
  -- and we could identify the customer from that.
  --
  -- If the program reached here, means all records were successfully
  -- identified to a single customer.
  --
    debug1('arp_process_lockbox.populate_resolved_columns(1)-');
    RETURN;
  --
--
  EXCEPTION
    -- WHEN no_data_found
    --         THEN null;
    WHEN others
            THEN RAISE;
  debug1('arp_process_lockbox.populate_resolved_columns(2)-');
  RETURN;
END populate_resolved_columns;
--
--
/*----------------------------------------------------------------------------
| Procedure
|     find_cust_and_trx_num
|
| Logic:
|     Check, if there is no matching_number given out NOCOPY of given 8 invoices,
|        return NO_ITEM.
|     LOOP
|     Fetch available matching_options using matching_options cursor.
|     Call get_cursor_name to get the parsed cursor for that matching_option.
|     Initialise the variables to NULL/-9999 as required.
|     For 1..8
|       Assign values of matching_number, date and installment to *current* variables.
|       If the current_matching_number is NOT NULL then
|         Bind the variables. - Required for dynamic SQL.
|         define_columns   - Required for dynamic SQL.
|         execute_and_fetch - Required for dynamic SQL
|         column_value - Required for dynamic SQL
|         Assign values back to matching_number, date and installment.
|      Else current_customer_idX = -9999.
|    End Loop.
|    If p_customer_id is not null /o procedure called from populate_resolved_columns o/
|    then
|      return correct status for each of the 8 matching_numbers and invoice numbers
|      also return p_matching_option, as you need to match only on that next time.
|      return match_flag as TRUE.
|   else /o procedure was called from auto_associate o/
|     if any customer_id was -7777, return match_flag as FALSE.
|          /o more than one customers associated with given matching number. o/
|     Compare all customer_id and then return error in case all of them are not same.
|     return correct status for each of the 8 matching_numbers and invoice numbers
|     also return p_matching_option, as you need to match only on that next time.
|     return match_flag as TRUE.
|    END LOOP for matching_options, close cursor matching_options.
|    If at the end of all matching_rules, given numbers have not matched
|    then return match_flag as NO_MATCH.
|
|
| Description:
|     This procedure is called from auto_associate and populate_resolved_columns
|     When it is called from auto_associate, it returns the customer_id.
|     When it is called from populate_resolved_columns,
|       it accepts the customer_id.
|
|
| Notes for future enhancements/customisation:
|     If you wants to add one more matching algorithm,
|      you should add that using this procedure.
|
|  Modification History:
|     28-Jul-97  K Trivedi    Created.
|
-----------------------------------------------------------------------------*/
PROCEDURE
  find_cust_and_trx_num(
      p_transmission_id         IN VARCHAR2,
      p_payment_rec_type        IN VARCHAR2,
      p_overflow_rec_type       IN VARCHAR2,
      p_item_num                IN ar_payments_interface.item_number%type,
      p_batch_name              IN ar_payments_interface.batch_name%type,
      p_lockbox_number          IN ar_payments_interface.lockbox_number%type,
      p_receipt_date            IN ar_payments_interface.receipt_date%type,
      p_batches                 IN VARCHAR2,
      p_only_one_lb             IN VARCHAR2,
      p_use_matching_date       IN ar_lockboxes.use_matching_date%type,
      p_lockbox_matching_option IN ar_lockboxes.lockbox_matching_option%type,
      p_pay_unrelated_invoices  IN VARCHAR2,
      p_matching_number1        IN OUT NOCOPY ar_payments_interface.invoice1%type,
      p_matching1_date          IN OUT NOCOPY ar_payments_interface.matching1_date%type,
      p_matching1_installment   IN OUT NOCOPY ar_payments_interface.invoice1_installment%type,
      p_matching_number2        IN OUT NOCOPY ar_payments_interface.invoice2%type,
      p_matching2_date          IN OUT NOCOPY ar_payments_interface.matching2_date%type,
      p_matching2_installment   IN OUT NOCOPY ar_payments_interface.invoice2_installment%type,
      p_matching_number3        IN OUT NOCOPY ar_payments_interface.invoice3%type,
      p_matching3_date          IN OUT NOCOPY ar_payments_interface.matching3_date%type,
      p_matching3_installment   IN OUT NOCOPY ar_payments_interface.invoice3_installment%type,
      p_matching_number4        IN OUT NOCOPY ar_payments_interface.invoice4%type,
      p_matching4_date          IN OUT NOCOPY ar_payments_interface.matching4_date%type,
      p_matching4_installment   IN OUT NOCOPY ar_payments_interface.invoice4_installment%type,
      p_matching_number5        IN OUT NOCOPY ar_payments_interface.invoice5%type,
      p_matching5_date          IN OUT NOCOPY ar_payments_interface.matching5_date%type,
      p_matching5_installment   IN OUT NOCOPY ar_payments_interface.invoice5_installment%type,
      p_matching_number6        IN OUT NOCOPY ar_payments_interface.invoice6%type,
      p_matching6_date          IN OUT NOCOPY ar_payments_interface.matching6_date%type,
      p_matching6_installment   IN OUT NOCOPY ar_payments_interface.invoice6_installment%type,
      p_matching_number7        IN OUT NOCOPY ar_payments_interface.invoice7%type,
      p_matching7_date          IN OUT NOCOPY ar_payments_interface.matching7_date%type,
      p_matching7_installment   IN OUT NOCOPY ar_payments_interface.invoice7_installment%type,
      p_matching_number8        IN OUT NOCOPY ar_payments_interface.invoice8%type,
      p_matching8_date          IN OUT NOCOPY ar_payments_interface.matching8_date%type,
      p_matching8_installment   IN OUT NOCOPY ar_payments_interface.invoice8_installment%type,
      p_matched_flag            OUT NOCOPY VARCHAR2,
      p_customer_id             IN OUT NOCOPY NUMBER,
      p_matching_option         IN OUT NOCOPY ar_lookups.lookup_code%type,
      p_match1_status           OUT NOCOPY ar_payments_interface.invoice1_status%type,
      p_match2_status           OUT NOCOPY ar_payments_interface.invoice2_status%type,
      p_match3_status           OUT NOCOPY ar_payments_interface.invoice3_status%type,
      p_match4_status           OUT NOCOPY ar_payments_interface.invoice4_status%type,
      p_match5_status           OUT NOCOPY ar_payments_interface.invoice5_status%type,
      p_match6_status           OUT NOCOPY ar_payments_interface.invoice6_status%type,
      p_match7_status           OUT NOCOPY ar_payments_interface.invoice7_status%type,
      p_match8_status           OUT NOCOPY ar_payments_interface.invoice8_status%type
    ) IS
--
bind_var_does_not_exist  EXCEPTION;
not_all_var_bound        EXCEPTION;
PRAGMA EXCEPTION_INIT(bind_var_does_not_exist, -01006);
PRAGMA EXCEPTION_INIT(not_all_var_bound, -01008);
--
i              integer;  -- Index variable, used for looping
                         -- thru' 1 to 8 for 8 matching number.
--
l_current_matching_number    ar_payments_interface.invoice1%type;
l_current_matching_date      ar_payments_interface.matching1_date%type;
l_current_invoice_number     ar_payments_interface.invoice1%type;
l_current_invoice_date       ar_payments_interface.matching1_date%type;
l_current_customer_id        ar_payments_interface.customer_id%type;
l_current_customer_id1       ar_payments_interface.customer_id%type;
l_current_customer_id2       ar_payments_interface.customer_id%type;
l_current_customer_id3       ar_payments_interface.customer_id%type;
l_current_customer_id4       ar_payments_interface.customer_id%type;
l_current_customer_id5       ar_payments_interface.customer_id%type;
l_current_customer_id6       ar_payments_interface.customer_id%type;
l_current_customer_id7       ar_payments_interface.customer_id%type;
l_current_customer_id8       ar_payments_interface.customer_id%type;
l_current_installment        ar_payments_interface.invoice1_installment%type;
first_customer               ar_payments_interface.customer_id%type;
l_matching_option            ar_lookups.lookup_code%type;
l_cursor_name                INTEGER;
l_cursor_found               BOOLEAN;
--
l_matching_number1  ar_payments_interface.invoice1%type;
l_matching1_date    ar_payments_interface.matching1_date%type;
l_matching_number2  ar_payments_interface.invoice2%type;
l_matching2_date    ar_payments_interface.matching2_date%type;
l_matching_number3  ar_payments_interface.invoice3%type;
l_matching3_date    ar_payments_interface.matching3_date%type;
l_matching_number4  ar_payments_interface.invoice4%type;
l_matching4_date    ar_payments_interface.matching4_date%type;
l_matching_number5  ar_payments_interface.invoice5%type;
l_matching5_date    ar_payments_interface.matching5_date%type;
l_matching_number6  ar_payments_interface.invoice6%type;
l_matching6_date    ar_payments_interface.matching6_date%type;
l_matching_number7  ar_payments_interface.invoice7%type;
l_matching7_date    ar_payments_interface.matching7_date%type;
l_matching_number8  ar_payments_interface.invoice8%type;
l_matching8_date    ar_payments_interface.matching8_date%type;
--
r_invoice_number1   ar_payments_interface.invoice1%type;
r_invoice_number2   ar_payments_interface.invoice2%type;
r_invoice_number3   ar_payments_interface.invoice3%type;
r_invoice_number4   ar_payments_interface.invoice4%type;
r_invoice_number5   ar_payments_interface.invoice5%type;
r_invoice_number6   ar_payments_interface.invoice6%type;
r_invoice_number7   ar_payments_interface.invoice7%type;
r_invoice_number8   ar_payments_interface.invoice8%type;
--
r_invoice1_date     ar_payments_interface.matching1_date%type;
r_invoice2_date     ar_payments_interface.matching2_date%type;
r_invoice3_date     ar_payments_interface.matching3_date%type;
r_invoice4_date     ar_payments_interface.matching4_date%type;
r_invoice5_date     ar_payments_interface.matching5_date%type;
r_invoice6_date     ar_payments_interface.matching6_date%type;
r_invoice7_date     ar_payments_interface.matching7_date%type;
r_invoice8_date     ar_payments_interface.matching8_date%type;
--
r_current_invoice_number   ar_payments_interface.invoice1%type;
r_current_invoice_date     ar_payments_interface.matching1_date%type;
r_temp_int          INTEGER;
--
  CURSOR matching_options IS
   select LOOKUP_CODE
   from   ar_lookups
   where  LOOKUP_TYPE = 'ARLPLB_MATCHING_OPTION'
   and    LOOKUP_CODE = decode(p_matching_option, 'ALL', LOOKUP_CODE, p_matching_option)
   order by decode(LOOKUP_CODE, 'INVOICE', 1,
                                'SALES_ORDER', 2,
                                'PURCHASE_ORDER', 3,
                                'CONSOLIDATE_BILL', 4,
                                                   100);
--
BEGIN
  debug1('arp_process_lockbox.find_cust_and_trx_num()+');
--
-- Note that the installment numbers are passed till
-- this point, but are not used, as the current functionality
-- matches are on invoice (where we need to return installment
-- number as it is). For match with PO and SO, installement
-- number is not currently used.
-- If required, installment number can be made use of in
-- any other future enhancements.
--
-- Assigning the parameters to Local variables.
--
l_matching_number1 := p_matching_number1;
l_matching1_date := p_matching1_date;
l_matching_number2 := p_matching_number2;
l_matching2_date := p_matching2_date;
l_matching_number3 := p_matching_number3;
l_matching3_date := p_matching3_date;
l_matching_number4 := p_matching_number4;
l_matching4_date := p_matching4_date;
l_matching_number5 := p_matching_number5;
l_matching5_date := p_matching5_date;
l_matching_number6 := p_matching_number6;
l_matching6_date := p_matching6_date;
l_matching_number7 := p_matching_number7;
l_matching7_date := p_matching7_date;
l_matching_number8 := p_matching_number8;
l_matching8_date := p_matching8_date;
  --
--
  -- Program should proceed, only if there was atleast one matching number
  --  being passed. In that case, we will return p_matched_flag := 'NO_ITEM'
  --
  IF ((p_matching_number1 is NULL) and
      (p_matching_number2 is NULL) and
      (p_matching_number3 is NULL) and
      (p_matching_number4 is NULL) and
      (p_matching_number5 is NULL) and
      (p_matching_number6 is NULL) and
      (p_matching_number7 is NULL) and
      (p_matching_number8 is NULL))
  THEN
      -- Note: Let the p_matching_option as it is, as there was no item.
      --       Also the p_customer_id is returned unchanged.
    debug1('No items were found.. returning NO_ITEM');
    p_matched_flag := 'NO_ITEM';
    debug1('arp_process_lockbox.find_cust_and_trx_num(1)-');
    RETURN;
  END IF;
  --
  OPEN matching_options;
  debug1('Opened cursor matching_options with p_matching_option ' || p_matching_option );
--
<<matching_options_loop>>
  LOOP
   FETCH matching_options
       INTO l_matching_option;
  debug1('Fetched cursor matching_options found l_matching_option = ' || l_matching_option );
  --
   EXIT matching_options_loop WHEN matching_options%NOTFOUND;
  --
  arp_process_lockbox.get_cursor_name(p_matching_option=>l_matching_option,
                                      p_cursor_name=>l_cursor_name,
                                      p_match_successful=>l_cursor_found);
  IF l_cursor_found = FALSE THEN
     -- This condition will never arise...
     p_matched_flag := 'PROGRAM_ERROR';
     debug1('PROGRAM_ERROR');
     debug1('arp_process_lockbox.find_cust_and_trx_num(6)-');
  END IF;
  --
    debug1('Got cursor ' || to_char(l_cursor_name) ||
             ' for matching option ' || l_matching_option);
  --
  first_customer := -9999;
  --
  --  Call a procedure to Create and Parse the cursor for :p_matching_option
  --
  -- Initilise the variables to NULL before starting loop again everytime.
  r_invoice_number1 := NULL;
  r_invoice_number2 := NULL;
  r_invoice_number3 := NULL;
  r_invoice_number4 := NULL;
  r_invoice_number5 := NULL;
  r_invoice_number6 := NULL;
  r_invoice_number7 := NULL;
  r_invoice_number8 := NULL;
  --
  r_invoice1_date := NULL;
  r_invoice2_date := NULL;
  r_invoice3_date := NULL;
  r_invoice4_date := NULL;
  r_invoice5_date := NULL;
  r_invoice6_date := NULL;
  r_invoice7_date := NULL;
  r_invoice8_date := NULL;
  --
  l_current_customer_id1 := -9999;
  l_current_customer_id2 := -9999;
  l_current_customer_id3 := -9999;
  l_current_customer_id4 := -9999;
  l_current_customer_id5 := -9999;
  l_current_customer_id6 := -9999;
  l_current_customer_id7 := -9999;
  l_current_customer_id8 := -9999;
  --
  -- Loop for getting the invoice number, invoice date and
  -- customer_id (only if called from auto_associate) for each matching number.
  --
  FOR i in 1 .. 8
   LOOP
   --
     IF (i = 1) THEN
           l_current_matching_number := p_matching_number1;
           l_current_matching_date := p_matching1_date;
           l_current_installment := p_matching1_installment;
     ELSIF (i = 2) THEN
           l_current_matching_number := p_matching_number2;
           l_current_matching_date := p_matching2_date;
           l_current_installment := p_matching2_installment;
     ELSIF (i = 3) THEN
           l_current_matching_number := p_matching_number3;
           l_current_matching_date := p_matching3_date;
           l_current_installment := p_matching3_installment;
     ELSIF (i = 4) THEN
           l_current_matching_number := p_matching_number4;
           l_current_matching_date := p_matching4_date;
           l_current_installment := p_matching4_installment;
     ELSIF (i = 5) THEN
           l_current_matching_number := p_matching_number5;
           l_current_matching_date := p_matching5_date;
           l_current_installment := p_matching5_installment;
     ELSIF (i = 6) THEN
           l_current_matching_number := p_matching_number6;
           l_current_matching_date := p_matching6_date;
           l_current_installment := p_matching6_installment;
     ELSIF (i = 7) THEN
           l_current_matching_number := p_matching_number7;
           l_current_matching_date := p_matching7_date;
           l_current_installment := p_matching7_installment;
     ELSIF (i = 8) THEN
           l_current_matching_number := p_matching_number8;
           l_current_matching_date := p_matching8_date;
           l_current_installment := p_matching8_installment;
     END IF;
   --
   -- If the l_current_matching_number is NULL, we should not
   -- execute the SQL statement, as it cannot return any
   -- value for invoice number. So, bind and execute the
   -- SQL statement only for l_current_matching_number <> NULL.
   --
    IF (l_current_matching_number is NOT NULL) THEN
      debug1('l_current_matching_number was found ' || l_current_matching_number );
      debug1('for i = ' || to_char(i));
      -- Bind the variables  p_customer_id, l_current_matching_number, l_current_matching_date
      -- Fetch values from the cursor
      -- into :l_current_customer_id, :r_current_invoice_number, :r_current_invoice_date;
      debug1('Now binding the variables for Dyn SQL.');
      begin
        debug1('Binding b_current_matching_date with: ' || to_char(l_current_matching_date));
        dbms_sql.bind_variable(l_cursor_name, ':b_current_matching_date', l_current_matching_date);
        exception
            when bind_var_does_not_exist then null;
            when others then raise;
      end;
      begin
        debug1('Binding b_current_matching_number with: ' || l_current_matching_number);
        dbms_sql.bind_variable(l_cursor_name, ':b_current_matching_number', l_current_matching_number);
        exception
            when bind_var_does_not_exist then null;
            when others then raise;
      end;
      begin
        debug1('Binding b_pay_unrelated_customers with: ' || p_pay_unrelated_invoices);
        dbms_sql.bind_variable(l_cursor_name, ':b_pay_unrelated_customers', p_pay_unrelated_invoices);
        exception
            when bind_var_does_not_exist then null;
            when others then raise;
      end;
      begin
        debug1('Binding b_customer_id with: ' || to_char(p_customer_id));
        dbms_sql.bind_variable(l_cursor_name, ':b_customer_id', p_customer_id);
        exception
            when bind_var_does_not_exist then null;
            when others then raise;
      end;
      begin
        debug1('Binding b_receipt_date with: ' || to_char(p_receipt_date,'YYYYMMDD'));
        dbms_sql.bind_variable(l_cursor_name, ':b_receipt_date', to_char(p_receipt_date,'YYYYMMDD'));
        exception
            when bind_var_does_not_exist then null;
            when others then raise;
      end;
      begin
        debug1('Binding b_current_installment with: ' || to_char(l_current_installment));
        dbms_sql.bind_variable(l_cursor_name, ':b_current_installment', l_current_installment);
        exception
            when bind_var_does_not_exist then null;
            when others then raise;
      end;
      begin
        debug1('Binding b_lockbox_matching_option with: ' || p_lockbox_matching_option);
        dbms_sql.bind_variable(l_cursor_name, ':b_lockbox_matching_option', p_lockbox_matching_option);
        exception
            when bind_var_does_not_exist then null;
            when others then raise;
      end;
      begin
        debug1('Binding b_use_matching_date with: ' || p_use_matching_date);
        dbms_sql.bind_variable(l_cursor_name, ':b_use_matching_date', p_use_matching_date);
        exception
            when bind_var_does_not_exist then null;
            when others then raise;
      end;
      -- Define the columns to fetch the values INTO appropriate variables.
      debug1('Now Defining columns for Dyn SQL.');
      dbms_sql.define_column(l_cursor_name, 1, l_current_customer_id);
      dbms_sql.define_column(l_cursor_name, 2, r_current_invoice_number, 50);
      dbms_sql.define_column(l_cursor_name, 3, r_current_invoice_date);
      -- Fetch and execute the record.
      -- At this point we expect the query to return only one record,
      -- so it should raise error exception in case it fetches more than one
      -- record.
      --
      debug1('Now executing and fetching data from Dyn SQL..');
      begin
        r_temp_int := dbms_sql.execute_and_fetch(l_cursor_name, TRUE);
        /** r_temp_int := dbms_sql.execute(l_cursor_name);
        debug1('After exeucute .. ');
        r_temp_int := dbms_sql.fetch_rows(l_cursor_name);
        **/
        debug1('After fetch .. ');
        exception
            when not_all_var_bound then
              debug1('Some bind variables are not assigned value');
              raise;
            when others then
              debug1('exe and fetch :' || SQLERRM(SQLCODE));
              raise;
      end;
      --
      debug1('Now putting data in columns..Dyn SQL..');
      dbms_sql.column_value(l_cursor_name, 1, l_current_customer_id);
      dbms_sql.column_value(l_cursor_name, 2, r_current_invoice_number);
      dbms_sql.column_value(l_cursor_name, 3, r_current_invoice_date);
      debug1('l_current_customer_id is ' || to_char(l_current_customer_id));
      debug1('r_current_invoice_number is ' || r_current_invoice_number);
      --
     IF (i = 1) THEN
           r_invoice_number1 := r_current_invoice_number;
           r_invoice1_date := r_current_invoice_date;
          /* Bug 2651127:  setting a new cust id to distinquish between
             not a match and not given */
          if ( l_current_customer_id = -9999) THEN
              /* we have not found a unique match */
              l_current_customer_id1 := -6666;
          else
              l_current_customer_id1 := l_current_customer_id;
          end if;
     ELSIF (i = 2) THEN
           r_invoice_number2 := r_current_invoice_number;
           r_invoice2_date := r_current_invoice_date;
          /* Bug 2651127:  setting a new cust id to distinquish between
             not a match and not given */
           if ( l_current_customer_id = -9999) THEN
              /* we have not found a unique match */
             l_current_customer_id2 := -6666;
           else
             l_current_customer_id2 := l_current_customer_id;
           end if;
     ELSIF (i = 3) THEN
           r_invoice_number3 := r_current_invoice_number;
           r_invoice3_date := r_current_invoice_date;
           /* Bug 2651127:  setting a new cust id to distinquish between
              not a match and not given */
           if ( l_current_customer_id = -9999) THEN
              /* we have not found a unique match */
              l_current_customer_id3 := -6666;
           else
              l_current_customer_id3 := l_current_customer_id;
           end if;
     ELSIF (i = 4) THEN
           r_invoice_number4 := r_current_invoice_number;
           r_invoice4_date := r_current_invoice_date;
           /* Bug 2651127:  setting a new cust id to distinquish between
              not a match and not given */
           if ( l_current_customer_id = -9999) THEN
              /* we have not found a unique match */
              l_current_customer_id4 := -6666;
           else
              l_current_customer_id4 := l_current_customer_id;
           end if;
     ELSIF (i = 5) THEN
           r_invoice_number5 := r_current_invoice_number;
           r_invoice5_date := r_current_invoice_date;
           /* Bug 2651127:  setting a new cust id to distinquish between
           not a match and not given */
           if ( l_current_customer_id = -9999) THEN
              /* we have not found a unique match */
             l_current_customer_id5 := -6666;
           else
             l_current_customer_id5 := l_current_customer_id;
           end if;
     ELSIF (i = 6) THEN
           r_invoice_number6 := r_current_invoice_number;
           r_invoice6_date := r_current_invoice_date;
           /* Bug 2651127:  setting a new cust id to distinquish between
           not a match and not given */
           if ( l_current_customer_id = -9999) THEN
              /* we have not found a unique match */
             l_current_customer_id6 := -6666;
           else
             l_current_customer_id6 := l_current_customer_id;
           end if;
     ELSIF (i = 7) THEN
           r_invoice_number7 := r_current_invoice_number;
           r_invoice7_date := r_current_invoice_date;
          /* Bug 2651127:  setting a new cust id to distinquish between
           not a match and not given */
           if ( l_current_customer_id = -9999) THEN
              /* we have not found a unique match */
             l_current_customer_id7 := -6666;
           else
             l_current_customer_id7 := l_current_customer_id;
           end if;
     ELSIF (i = 8) THEN
           r_invoice_number8 := r_current_invoice_number;
           r_invoice8_date := r_current_invoice_date;
           /* Bug 2651127:  setting a new cust id to distinquish between
           not a match and not given */
           if ( l_current_customer_id = -9999) THEN
              /* we have not found a unique match */
             l_current_customer_id8 := -6666;
           else
             l_current_customer_id8 := l_current_customer_id;
           end if;
     END IF;
      --
      -- No need to close the cursor here.
      -- cursors will be closed thru' close_cursors called from C program
      -- which will check, if the cursors are open. It will close them
      -- if they are open.
    ELSE  -- If the l_current_matching_number is null.
    debug1('l_current_matching_number is null for i =' || to_char(i));
     IF (i = 1) THEN
      l_current_customer_id1 := -9999;
     ELSIF (i = 2) THEN
      l_current_customer_id2 := -9999;
     ELSIF (i = 3) THEN
      l_current_customer_id3 := -9999;
     ELSIF (i = 4) THEN
      l_current_customer_id4 := -9999;
     ELSIF (i = 5) THEN
      l_current_customer_id5 := -9999;
     ELSIF (i = 6) THEN
      l_current_customer_id6 := -9999;
     ELSIF (i = 7) THEN
      l_current_customer_id7 := -9999;
     ELSIF (i = 8) THEN
      l_current_customer_id8 := -9999;
     END IF;
    END IF; -- End if for l_current_matching_number is NOT NULL
   --
   --
   END LOOP;  -- End loop for 1 to 8 matching numbers.
   --
--
    /*5052049*/
   IF (p_customer_id is NOT NULL AND l_matching_option <> 'CONSOLIDATE_BILL') THEN
      -- Procedure was called from populate_resolved_columns
      -- and not from Auto_Associate.
    debug1('Procedure was called from populate_resolved_columns.');
    IF
      ((r_invoice_number1 IS NOT NULL) or
       (r_invoice_number2 IS NOT NULL) or
       (r_invoice_number3 IS NOT NULL) or
       (r_invoice_number4 IS NOT NULL) or
       (r_invoice_number5 IS NOT NULL) or
       (r_invoice_number6 IS NOT NULL) or
       (r_invoice_number7 IS NOT NULL) or
       (r_invoice_number8 IS NOT NULL))   THEN
         --
         -- Program found atleast one matching number out NOCOPY of
         -- all eight that matched with Invoice/SO/PO.
         -- Rest all txn_numbers and txn_dates on this record are selected now.
         -- populate_resolved_columns expects only txn details
         -- from this routine.
         --
         -- If input value p_matching_number1 was not null
         -- and result r_invoice_number1 is NULL, it means that
         -- the program could not resolve the matching number.
         -- Return Error for such matching number.
         --
	 -- If the resolved matching number is -1111, it means that the invoice
	 -- is closed. So flag the invoice as 'Invalid Match'. Bug 7431540.
	 --
         IF ((r_invoice_number1 IS NULL OR r_invoice_number1 = '-1111') AND
             (p_matching_number1 IS NOT NULL))
         THEN
            --
            -- In this error condition, we need to return the same
            -- values for p_matching_number1, p_matching1_date,
            -- p_matching1_installment, if called from populate_resolved_columns.
            --
            p_match1_status := 'AR_PLB_INVALID_MATCH';
            -- p_matching_number1 := NULL;
            -- p_matching1_date := NULL;
            -- p_matching1_installment := NULL;
         ELSE
            -- This covers three possiblities.
            -- 1. p_matching_number1 was null and r_invoice_number1 was also null.
            -- program would have never opened, fetched and executed the cursor.
            -- So, r_invoice_number1 and r_invoice1_date will also be null in that case.
            -- Return nothing for no input.
            -- 2. p_matching_number1 was not null and r_invoice_number1 was also not null.
            -- We are returning the correct return values.
            -- 3. p_matching_number1 was null and r_invoice_number1 was not null.
            -- We don't expect the values in r_invoice_number1 in this case for the
            -- reasons mentioned in 1.
            --
            p_match1_status := NULL;
            p_matching_number1 := r_invoice_number1;
            p_matching1_date := r_invoice1_date;
            -- Return p_matching1_installment as it is.
         END IF;
         -- Repeat the same for all other seven matching numbers.
         --
         IF ((r_invoice_number2 IS NULL  OR r_invoice_number2 = '-1111') AND
             (p_matching_number2 IS NOT NULL))
         THEN
            p_match2_status := 'AR_PLB_INVALID_MATCH';
            -- p_matching_number2 := NULL;
            -- p_matching2_date := NULL;
            -- p_matching2_installment := NULL;
         ELSE
            p_match2_status := NULL;
            p_matching_number2 := r_invoice_number2;
            p_matching2_date := r_invoice2_date;
            -- Return p_matching2_installment as it is.
         END IF;
         IF ((r_invoice_number3 IS NULL  OR r_invoice_number3 = '-1111') AND
             (p_matching_number3 IS NOT NULL))
         THEN
            p_match3_status := 'AR_PLB_INVALID_MATCH';
            p_matching_number3 := NULL;
            p_matching3_date := NULL;
            p_matching3_installment := NULL;
         ELSE
            p_match3_status := NULL;
            p_matching_number3 := r_invoice_number3;
            p_matching3_date := r_invoice3_date;
            -- Return p_matching3_installment as it is.
         END IF;
         IF ((r_invoice_number4 IS NULL  OR r_invoice_number4 = '-1111') AND
             (p_matching_number4 IS NOT NULL))
         THEN
            p_match4_status := 'AR_PLB_INVALID_MATCH';
            -- p_matching_number4 := NULL;
            -- p_matching4_date := NULL;
            -- p_matching4_installment := NULL;
         ELSE
            p_match4_status := NULL;
            p_matching_number4 := r_invoice_number4;
            p_matching4_date := r_invoice4_date;
            -- Return p_matching4_installment as it is.
         END IF;
         IF ((r_invoice_number5 IS NULL  OR r_invoice_number5 = '-1111') AND
             (p_matching_number5 IS NOT NULL))
         THEN
            p_match5_status := 'AR_PLB_INVALID_MATCH';
            -- p_matching_number5 := NULL;
            -- p_matching5_date := NULL;
            -- p_matching5_installment := NULL;
         ELSE
            p_match5_status := NULL;
            p_matching_number5 := r_invoice_number5;
            p_matching5_date := r_invoice5_date;
            -- Return p_matching5_installment as it is.
         END IF;
         IF ((r_invoice_number6 IS NULL  OR r_invoice_number6 = '-1111') AND
             (p_matching_number6 IS NOT NULL))
         THEN
            p_match6_status := 'AR_PLB_INVALID_MATCH';
            -- p_matching_number6 := NULL;
            -- p_matching6_date := NULL;
            -- p_matching6_installment := NULL;
         ELSE
            p_match6_status := NULL;
            p_matching_number6 := r_invoice_number6;
            p_matching6_date := r_invoice6_date;
            -- Return p_matching6_installment as it is.
         END IF;
         IF ((r_invoice_number7 IS NULL  OR r_invoice_number7 = '-1111') AND
             (p_matching_number7 IS NOT NULL))
         THEN
            p_match7_status := 'AR_PLB_INVALID_MATCH';
            -- p_matching_number7 := NULL;
            -- p_matching7_date := NULL;
            -- p_matching7_installment := NULL;
         ELSE
            p_match7_status := NULL;
            p_matching_number7 := r_invoice_number7;
            p_matching7_date := r_invoice7_date;
            -- Return p_matching7_installment as it is.
         END IF;
         IF ((r_invoice_number8 IS NULL  OR r_invoice_number8 = '-1111') AND
             (p_matching_number8 IS NOT NULL))
         THEN
            p_match8_status := 'AR_PLB_INVALID_MATCH';
            -- p_matching_number8 := NULL;
            -- p_matching8_date := NULL;
            -- p_matching8_installment := NULL;
         ELSE
            p_match8_status := NULL;
            p_matching_number8 := r_invoice_number8;
            p_matching8_date := r_invoice8_date;
            -- Return p_matching8_installment as it is.
         END IF;
      p_matching_option := l_matching_option;
      p_matched_flag := 'TRUE';
      debug1('arp_process_lockbox.find_cust_and_trx_num(2)-');
      RETURN;

   ELSE
         -- None of the eight matching_numbers matched to
         -- current matching_opition. So try with next matching_opition.
           debug1('None of the eight matching_numbers matched to current matching_opition');
           GOTO end_of_current_matching_option;
   --
    END IF;  -- End if for 8 or conditions.
   END IF; -- End if for Procedure was called from populate_resolved_columns
--
--
   debug1('Procedure was called from auto_associate.');
   --
   -- If any of the customer_id is -7777, that means that
   -- the invoice number and invoice date were such that there were multiple
   -- customers associated with these numbers. In other words, the
   -- there were two invoices asssociated with two different customers
   -- having the same invoice numbers and same invoice date.
   -- This should read as SO/PO/Cons_Bill number and SO/PO date in case the
   -- matching option was SO/PO/Cons_Bill.
   --
   IF   (
         (l_current_customer_id1 = -7777) or
         (l_current_customer_id2 = -7777) or
         (l_current_customer_id3 = -7777) or
         (l_current_customer_id4 = -7777) or
         (l_current_customer_id5 = -7777) or
         (l_current_customer_id6 = -7777) or
         (l_current_customer_id7 = -7777) or
         (l_current_customer_id8 = -7777)
        ) THEN
     p_matched_flag := 'FALSE';
     /* Bug 2106408. The p_customer_id should be passed as -7777 whenever
     there is a duplicate invoice number. */
     debug1('arp_process_lockbox.find_cust_and_trx_num : Duplicate Invoice');
     p_customer_id := -7777;
     debug1('arp_process_lockbox.find_cust_and_trx_num(8)-');
     RETURN;
   END IF;

  /* Bug2651127: if any customer_id is -6666 that means that we have an invalid
     invoice number and the customer should not be uniquely identified */
      IF   (
         (l_current_customer_id1 = -6666) or
         (l_current_customer_id2 = -6666) or
         (l_current_customer_id3 = -6666) or
         (l_current_customer_id4 = -6666) or
         (l_current_customer_id5 = -6666) or
         (l_current_customer_id6 = -6666) or
         (l_current_customer_id7 = -6666) or
         (l_current_customer_id8 = -6666)
        ) THEN
        p_matched_flag := 'FALSE';
        debug1('arp_process_lockbox.find_cust_and_trx_num : Invalid Invoice');
        debug1('arp_process_lockbox.find_cust_and_trx_num(8.1)-');
        /*RETURN;*/ /*5052049*/
      END IF;
   --
   /*5052049*/
   IF   l_current_customer_id1 NOT IN (-9999,-6666) then
            debug1('l_current_customer_id1 = ' || to_char(l_current_customer_id1));
            first_customer := l_current_customer_id1;
   ELSIF l_current_customer_id2 NOT IN (-9999,-6666) then
            debug1('l_current_customer_id2 = ' || to_char(l_current_customer_id2));
            first_customer := l_current_customer_id2;
   ELSIF l_current_customer_id3 NOT IN (-9999,-6666) then
            first_customer := l_current_customer_id3;
   ELSIF l_current_customer_id4 NOT IN (-9999,-6666) then
            first_customer := l_current_customer_id4;
   ELSIF l_current_customer_id5 NOT IN (-9999,-6666) then
            first_customer := l_current_customer_id5;
   ELSIF l_current_customer_id6 NOT IN (-9999,-6666) then
            first_customer := l_current_customer_id6;
   ELSIF l_current_customer_id7 NOT IN (-9999,-6666) then
            first_customer := l_current_customer_id7;
   ELSIF l_current_customer_id8 NOT IN (-9999,-6666) then
            first_customer := l_current_customer_id8;
   END IF;

   debug1('first_customer is '||  to_char(first_customer));

   IF (first_customer not in (-9999,-6666)) THEN   /*5052049*/
     IF (
         ((l_current_customer_id1 = first_customer) or (l_current_customer_id1 IN (-9999,-6666))) AND
         ((l_current_customer_id2 = first_customer) or (l_current_customer_id2 IN (-9999,-6666))) AND
         ((l_current_customer_id3 = first_customer) or (l_current_customer_id3 IN (-9999,-6666))) AND
         ((l_current_customer_id4 = first_customer) or (l_current_customer_id4 IN (-9999,-6666))) AND
         ((l_current_customer_id5 = first_customer) or (l_current_customer_id5 IN (-9999,-6666))) AND
         ((l_current_customer_id6 = first_customer) or (l_current_customer_id6 IN (-9999,-6666))) AND
         ((l_current_customer_id7 = first_customer) or (l_current_customer_id7 IN (-9999,-6666))) AND
         ((l_current_customer_id8 = first_customer) or (l_current_customer_id8  IN (-9999,-6666)))
        )
     THEN  /* Identified the customer uniquely */
         debug1('r_invoice_number1 is ' || r_invoice_number1);
         debug1('p_matching_number1 is ' || p_matching_number1);
        --
        -- We have identified the customer uniquely. However, it is
        -- possible that we could not identify the invoice for the given
        -- matching number uniquely. For example, there were more than one
        -- invoices with same invoice number for the same customer.
        -- This is more likely in case of PO/SO. So, we need to check here.
        --

        /* bug3252655 Changed IF condition because r_invoice_number1 is
           always null regardless of autoassociation result for consolidated
           billing invoice matching. When customer is identified by
           Invoice/PO/SO matching, trx_number is selected like max(trx_number).
           Hence, Need to check l_current_customer_id to check the auto
           association result.
         */
        /* bug3252655
         IF ((r_invoice_number1 IS NULL) AND
             (p_matching_number1 IS NOT NULL))
         */
	 /*5052049 added -6666 along with -9999 in the if structure
	   for all l_current_customer_id 1 to 8*/
	 -- If the resolved matching number is -1111, it means that the invoice
	 -- is closed. So flag the invoice as 'Invalid Match'. Bug 7431540.
         IF ((l_current_customer_id1 IN (-9999,-6666)  OR r_invoice_number1 = '-1111') AND
             (p_matching_number1 IS NOT NULL))
         THEN
            debug1('Invalid Match for 1st match num');
            p_match1_status := 'AR_PLB_INVALID_MATCH';
            p_matching_number1 := NULL;
            p_matching1_date := NULL;
            p_matching1_installment := NULL;
         ELSE
            debug1('Valid Match for 1st match num');
            p_match1_status := NULL;
            p_matching_number1 := r_invoice_number1;
            p_matching1_date := r_invoice1_date;
            -- Return p_matching1_installment as it is.
         END IF;
         /* bug3252655
         IF ((r_invoice_number2 IS NULL) AND
             (p_matching_number2 IS NOT NULL))
          */
         IF ((l_current_customer_id2 IN (-9999,-6666)  OR r_invoice_number2 = '-1111') AND
             (p_matching_number2 IS NOT NULL))
         THEN
            p_match2_status := 'AR_PLB_INVALID_MATCH';
            p_matching_number2 := NULL;
            p_matching2_date := NULL;
            p_matching2_installment := NULL;
         ELSE
            p_match2_status := NULL;
            p_matching_number2 := r_invoice_number2;
            p_matching2_date := r_invoice2_date;
            -- Return p_matching2_installment as it is.
         END IF;
         /* bug3252655
         IF ((r_invoice_number3 IS NULL) AND
             (p_matching_number3 IS NOT NULL))
          */
         IF ((l_current_customer_id3 IN (-9999,-6666) OR r_invoice_number3 = '-1111') AND
             (p_matching_number3 IS NOT NULL))
         THEN
            p_match3_status := 'AR_PLB_INVALID_MATCH';
            p_matching_number3 := NULL;
            p_matching3_date := NULL;
            p_matching3_installment := NULL;
         ELSE
            p_match3_status := NULL;
            p_matching_number3 := r_invoice_number3;
            p_matching3_date := r_invoice3_date;
            -- Return p_matching3_installment as it is.
         END IF;
         /* bug3252655
         IF ((r_invoice_number4 IS NULL) AND
             (p_matching_number4 IS NOT NULL))
          */
         IF ((l_current_customer_id4 IN (-9999,-6666) OR r_invoice_number4 = '-1111') AND
             (p_matching_number4 IS NOT NULL))
         THEN
            p_match4_status := 'AR_PLB_INVALID_MATCH';
            p_matching_number4 := NULL;
            p_matching4_date := NULL;
            p_matching4_installment := NULL;
         ELSE
            p_match4_status := NULL;
            p_matching_number4 := r_invoice_number4;
            p_matching4_date := r_invoice4_date;
            -- Return p_matching4_installment as it is.
         END IF;
         /* bug3252655
         IF ((r_invoice_number5 IS NULL) AND
             (p_matching_number5 IS NOT NULL))
          */
         IF ((l_current_customer_id5 IN (-9999,-6666) OR r_invoice_number5 = '-1111') AND
             (p_matching_number5 IS NOT NULL))
         THEN
            p_match5_status := 'AR_PLB_INVALID_MATCH';
            p_matching_number5 := NULL;
            p_matching5_date := NULL;
            p_matching5_installment := NULL;
         ELSE
            p_match5_status := NULL;
            p_matching_number5 := r_invoice_number5;
            p_matching5_date := r_invoice5_date;
            -- Return p_matching5_installment as it is.
         END IF;
         /* bug3252655
         IF ((r_invoice_number6 IS NULL) AND
             (p_matching_number6 IS NOT NULL))
          */
         IF ((l_current_customer_id6 IN (-9999,-6666) OR r_invoice_number6 = '-1111') AND
             (p_matching_number6 IS NOT NULL))
         THEN
            p_match6_status := 'AR_PLB_INVALID_MATCH';
            p_matching_number6 := NULL;
            p_matching6_date := NULL;
            p_matching6_installment := NULL;
         ELSE
            p_match6_status := NULL;
            p_matching_number6 := r_invoice_number6;
            p_matching6_date := r_invoice6_date;
            -- Return p_matching6_installment as it is.
         END IF;
         /* bug3252655
         IF ((r_invoice_number7 IS NULL) AND
             (p_matching_number7 IS NOT NULL))
          */
         IF ((l_current_customer_id7 IN (-9999,-6666) OR r_invoice_number7 = '-1111') AND
             (p_matching_number7 IS NOT NULL))
         THEN
            p_match7_status := 'AR_PLB_INVALID_MATCH';
            p_matching_number7 := NULL;
            p_matching7_date := NULL;
            p_matching7_installment := NULL;
         ELSE
            p_match7_status := NULL;
            p_matching_number7 := r_invoice_number7;
            p_matching7_date := r_invoice7_date;
            -- Return p_matching7_installment as it is.
         END IF;
         /* bug3252655
         IF ((r_invoice_number8 IS NULL) AND
             (p_matching_number8 IS NOT NULL))
          */
         IF ((l_current_customer_id8 IN (-9999,-6666) OR r_invoice_number8 = '-1111') AND
             (p_matching_number8 IS NOT NULL))
         THEN
            p_match8_status := 'AR_PLB_INVALID_MATCH';
            p_matching_number8 := NULL;
            p_matching8_date := NULL;
            p_matching8_installment := NULL;
         ELSE
            p_match8_status := NULL;
            p_matching_number8 := r_invoice_number8;
            p_matching8_date := r_invoice8_date;
            -- Return p_matching8_installment as it is.
         END IF;
        p_matching_option := l_matching_option;
        p_customer_id := first_customer;
        p_matched_flag := 'TRUE';
        debug1('arp_process_lockbox.find_cust_and_trx_num(3)-');
        RETURN;
     ELSE  /* Could not identify the customer uniquely */
        /* Let the p_customer_id be whatever was the input value,
           It will be null, if it is called form Auto_Associate or it
           will hold some valid value, if called from populate_resolved_coulmns */
        p_matched_flag := 'FALSE';
        debug1('arp_process_lockbox.find_cust_and_trx_num(4)-');
        RETURN;
     END IF;
   END IF;  -- End if for first_customer <> -9999.
   /* Note : Do nothing and countinue with the next option in
             cursor matching_options in case first_customer = -9999 */
   --
  <<end_of_current_matching_option>>
    null;
  END LOOP matching_options_loop;
  CLOSE matching_options;
--
  -- If the program has reached here, it means that there were no
  -- matches to the input number.
      -- Note: Let the p_matching_option as it is, as there was no item.
      --       Also returning p_matching_number and p_matching_date unchanged.
      IF (p_matching_number1 IS NOT NULL)
      THEN
         p_match1_status := 'AR_PLB_INVALID_MATCH';
      ELSE
         p_match1_status := NULL;
      END IF;
      IF (p_matching_number2 IS NOT NULL)
      THEN
         p_match2_status := 'AR_PLB_INVALID_MATCH';
      ELSE
         p_match2_status := NULL;
      END IF;
      IF (p_matching_number3 IS NOT NULL)
      THEN
         p_match3_status := 'AR_PLB_INVALID_MATCH';
      ELSE
         p_match3_status := NULL;
      END IF;
      IF (p_matching_number4 IS NOT NULL)
      THEN
         p_match4_status := 'AR_PLB_INVALID_MATCH';
      ELSE
         p_match4_status := NULL;
      END IF;
      IF (p_matching_number5 IS NOT NULL)
      THEN
         p_match5_status := 'AR_PLB_INVALID_MATCH';
      ELSE
         p_match5_status := NULL;
      END IF;
      IF (p_matching_number6 IS NOT NULL)
      THEN
         p_match6_status := 'AR_PLB_INVALID_MATCH';
      ELSE
         p_match6_status := NULL;
      END IF;
      IF (p_matching_number7 IS NOT NULL)
      THEN
         p_match7_status := 'AR_PLB_INVALID_MATCH';
      ELSE
         p_match7_status := NULL;
      END IF;
      IF (p_matching_number8 IS NOT NULL)
      THEN
         p_match8_status := 'AR_PLB_INVALID_MATCH';
      ELSE
         p_match8_status := NULL;
      END IF;
      p_matched_flag := 'NO_MATCH';
      debug1('arp_process_lockbox.find_cust_and_trx_num(5)-');
      RETURN;
--
  EXCEPTION
    WHEN others
      THEN
      debug1('arp_process_lockbox.find_cust_and_trx_num(7)-');
      RAISE;
END find_cust_and_trx_num;
--
/*----------------------------------------------------------------------------
This procedure calls arp_util.debug for the string passed.
Till arp_util.debug is changed to provide an option to write to a
file, we can use this procedure to write to a file at the time of testing.
Un comment lines calling fnd_file package and that will write to a file.
Please change the directory name so that it does not raise any exception.
----------------------------------------------------------------------------*/
PROCEDURE debug1(str IN VARCHAR2) IS
-- myfile utl_file.file_type;
-- dir_name varchar2(100);
-- out_file_name varchar2(8);
-- log_file_name varchar2(8);
BEGIN
--
  -- Check for the directory name.
  -- dir_name := '/sqlcom/inbound';
  -- log_file_name := 'ar.log';
  -- out_file_name := 'ar.out';
  -- myfile := utl_file.fopen(dir_name, out_file_name, 'a');
  -- utl_file.put(myfile, str);
  -- utl_file.fclose(myfile);
  --
  IF PG_DEBUG in ('Y', 'C') THEN
  arp_util.debug(str);
  END IF;
END;
--
/*----------------------------------------------------------------------------
| Procedure
|     get_cursor_name
|
|   Logic:
|     Loop thru' the table opened_cursors_table and find the
|     record for p_matching_option
|     return cursor_name when you find match.
|     In case you don't find a match, return Failure.
|
|
|    Modification History
|       05-Aug-97   K Trivedi    Created. Rel 11 related changes.
|
 ----------------------------------------------------------------------------*/
PROCEDURE
get_cursor_name(p_matching_option   IN     ar_lookups.lookup_code%type,
                      p_cursor_name       OUT NOCOPY    INTEGER,
                      p_match_successful  OUT NOCOPY    BOOLEAN) IS
--
--
BEGIN
debug1('arp_process_lockbox.get_cursor_name()+');
FOR i in 1 .. g_total_maching_options
  LOOP
   IF (opened_cursor_table(i).option_name = p_matching_option) THEN
      p_cursor_name :=  opened_cursor_table(i).cursor_name;
      p_match_successful := TRUE;
      debug1('arp_process_lockbox.get_cursor_name(1)-');
      RETURN;
  END IF;
  END LOOP;  -- End loop for 1 to g_total_maching_options matching numbers.
--
-- If the program control has reached here, it means that requested
-- cursor was not defined. .. will return error in this case.
--
   p_cursor_name := NULL;
   p_match_successful := FALSE;
   debug1('arp_process_lockbox.get_cursor_name(2)-');
   RETURN;
--
END get_cursor_name;
--
/*----------------------------------------------------------------------------
| Procedure
|     close_cursors
|
|   Logic:
|     Loop from 1 to g_total_opened_cursors.
|       Check if the cursor is Open.
|       Close it if it is open.
|
|    Modification History
|       05-Aug-97   K Trivedi    Created. Rel 11 related changes.
|
 ----------------------------------------------------------------------------*/
PROCEDURE
close_cursors IS
Begin
debug1('arp_process_lockbox.get_cursor_name()+');
--
FOR i in 1 .. g_total_maching_options
  LOOP
   IF (dbms_sql.is_open(opened_cursor_table(i).cursor_name)) THEN
      debug1('Closing Cursor for index ' || to_char(i));
      dbms_sql.close_cursor(opened_cursor_table(i).cursor_name);
  END IF;
  END LOOP;  -- End loop for 1 to g_total_maching_options matching numbers.
--
debug1('arp_process_lockbox.get_cursor_name()-');
End close_cursors;

--
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    validate_llca_interface_data                                           |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    Validate interface data for LLCA                                       |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                            |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |              p_trans_request_id - Id of transmission request whose llca   |
 |                                   data to be validated.                   |
 | RETURNS    : NONE                                                         |
 |                                                                           |
 | MODIFICATION HISTORY  :                                                   |
 |                                                                           |
 |  28-Jul-07       vpusulur      Created.                                   |
 |  24-JUN-08       aghoraka      Modified the design.                       |
 |                                Used queries to process teh entire data.   |
 |                                Refer Bug 7195038.                         |
 +===========================================================================*/
PROCEDURE validate_llca_interface_data(
p_trans_request_id   IN   varchar2,
p_allow_invalid_trx_num IN varchar2,
p_format_amount IN varchar2,
p_return_status OUT NOCOPY varchar2
) IS
        CURSOR customer_trx_cursor(p_trans_request_id IN NUMBER) IS
                SELECT DISTINCT customer_trx_id
                FROM   ar_pmts_interface_header_gt
                WHERE  transmission_request_id = p_trans_request_id;

        CURSOR apply_to_rec(p_trans_request_id IN NUMBER,
                        p_customer_trx_id IN NUMBER) IS
                SELECT distinct apply_to
                FROM   ar_pmts_interface_line_details
                WHERE  transmission_request_id = p_trans_request_id
                AND    customer_trx_id = p_customer_trx_id;

        CURSOR trans_rec_cur(p_trans_request_id IN NUMBER) IS
                SELECT distinct transmission_record_id
                FROM   ar_pmts_interface_line_details
                WHERE  transmission_request_id = p_trans_request_id
                AND    status = 'AR_PLB_NEW_RECORD';

        CURSOR  invoice_rec_cur(p_trans_request_id IN NUMBER,
                                p_transmission_record_id IN NUMBER) IS
                SELECT  distinct customer_trx_id
                FROM    ar_pmts_interface_line_details
                WHERE   transmission_request_id = p_trans_request_id
                AND     transmission_record_id = p_transmission_record_id;

        CURSOR  app_to_cur(p_trans_req_id IN NUMBER,
                            p_transmission_record_id IN NUMBER,
                            p_customer_trx_id IN NUMBER) IS
                SELECT  apply_to,
                        line_amount,
                        tax,
                        amount_applied
                FROM    ar_pmts_interface_line_details
                WHERE   transmission_request_id = p_trans_req_id
                AND     transmission_record_id = p_transmission_record_id
                AND     customer_trx_id = p_customer_trx_id
                AND     apply_to NOT IN ('FREIGHT','CHARGES')
                AND    status = 'AR_PLB_NEW_RECORD';

        tot_app_count   NUMBER;
        line_app_count  NUMBER;
        l_invoice_number        ar_payments_interface.INVOICE1%TYPE;
        l_inv_currency_code     ar_payments_interface.CURRENCY_CODE%TYPE;
        l_currency_code         ar_payments_interface.CURRENCY_CODE%TYPE;
        l_trans_to_receipt_rate ar_payments_interface.TRANS_TO_RECEIPT_RATE1%TYPE;
        l_default_by    VARCHAR2(20);
        l_line_amount_remaining NUMBER;
        l_line_tax_remaining    NUMBER;
        line_amt_due_original   NUMBER;
        l_customer_trx          ra_customer_trx%rowtype;
        ll_leg_app              varchar2(1);
    	ll_mfar_app             varchar2(1);
     	ll_leg_adj              varchar2(1);
      	ll_mfar_adj             varchar2(1);
      	l_return_status         varchar2(2) := 'S';
      	p_trans_req_id          number := 0;
      	l_msg_count             number;
        l_msg_data              varchar2(50);
        l_tot_amt_app           NUMBER;
        l_tot_amt_app_from      NUMBER;
        hdr_amt_app             NUMBER;
        hdr_amt_app_frm         NUMBER;
        l_calc_per_line         NUMBER;
        l_calc_tot_amount_app   NUMBER;
        l_calc_line_amount	    NUMBER;
        l_calc_tax_amount	    NUMBER;
        l_trans_record_id       ar_payments_interface.TRANSMISSION_RECORD_ID%TYPE;
        format_amount_app1      varchar2(2);
        format_amount_app2      varchar2(2);
        format_amount_app3      varchar2(2);
        format_amount_app4      varchar2(2);
        format_amount_app5      varchar2(2);
        format_amount_app6      varchar2(2);
        format_amount_app7      varchar2(2);
        format_amount_app8      varchar2(2);
        format_amount1          varchar2(2);
        format_amount2          varchar2(2);
        format_amount3          varchar2(2);
        format_amount4          varchar2(2);
        format_amount5          varchar2(2);
        format_amount6          varchar2(2);
        format_amount7          varchar2(2);
        format_amount8          varchar2(2);

BEGIN
debug1('arp_process_lockbox.validate_llca_interface_data()+');
p_trans_req_id  := to_number(p_trans_request_id);

UPDATE   ar_pmts_interface_line_details
SET      status = 'AR_PLB_NEW_RECORD'
WHERE    transmission_request_id = p_trans_req_id;

UPDATE  ar_pmts_interface_line_details
SET     amount_applied = decode(apply_to,'FREIGHT',freight,charges)
WHERE   transmission_request_id = p_trans_req_id
AND     apply_to IN ('FREIGHT', 'CHARGES')
AND     amount_applied IS NULL
AND     allocated_receipt_amount IS NULL;

UPDATE  ar_pmts_interface_line_details line_details
SET     status = 'AR_PLB_INVALID_REC_ID'
WHERE   transmission_record_id in ( SELECT transmission_record_id
                                FROM ar_payments_interface interface
                                WHERE interface.transmission_request_id = p_trans_req_id
                                AND   interface.transmission_record_id  = line_details.transmission_record_id
                                GROUP BY transmission_record_id
                                HAVING count(transmission_record_id) <> 1
                                )
AND     transmission_request_id = p_trans_req_id
AND     status = 'AR_PLB_NEW_RECORD';

UPDATE  ar_pmts_interface_line_details line_details
SET     status = 'AR_PLB_INVALID_RECORD'
WHERE   transmission_record_id in ( SELECT transmission_record_id
                                FROM    ar_payments_interface interface
                                WHERE   interface.transmission_request_id = p_trans_req_id
                                AND     interface.transmission_record_id  = line_details.transmission_record_id
                                AND     status <> 'AR_PLB_APP_OK')
AND     transmission_request_id = p_trans_req_id
AND     status = 'AR_PLB_NEW_RECORD';

SELECT  transmission_record_id
INTO    l_trans_record_id
FROM    ar_payments_interface
WHERE   transmission_request_id = p_trans_req_id
AND     rownum = 1;

format_amount1 := ARP_PROCESS_LOCKBOX.get_format_amount(p_trans_req_id,
                                    l_trans_record_id,'AMT APP 1');
format_amount2 := ARP_PROCESS_LOCKBOX.get_format_amount(p_trans_req_id,
                                    l_trans_record_id,'AMT APP 2');
format_amount3 := ARP_PROCESS_LOCKBOX.get_format_amount(p_trans_req_id,
                                    l_trans_record_id,'AMT APP 3');
format_amount4 := ARP_PROCESS_LOCKBOX.get_format_amount(p_trans_req_id,
                                    l_trans_record_id,'AMT APP 4');
format_amount5 := ARP_PROCESS_LOCKBOX.get_format_amount(p_trans_req_id,
                                    l_trans_record_id,'AMT APP 5');
format_amount6 := ARP_PROCESS_LOCKBOX.get_format_amount(p_trans_req_id,
                                    l_trans_record_id,'AMT APP 6');
format_amount7 := ARP_PROCESS_LOCKBOX.get_format_amount(p_trans_req_id,
                                    l_trans_record_id,'AMT APP 7');
format_amount8 := ARP_PROCESS_LOCKBOX.get_format_amount(p_trans_req_id,
                                    l_trans_record_id,'AMT APP 8');
format_amount_app1 := ARP_PROCESS_LOCKBOX.get_format_amount(p_trans_req_id,
                                l_trans_record_id,'AMT APP FROM 1');
format_amount_app2 := ARP_PROCESS_LOCKBOX.get_format_amount(p_trans_req_id,
                                l_trans_record_id,'AMT APP FROM 2');
format_amount_app3 := ARP_PROCESS_LOCKBOX.get_format_amount(p_trans_req_id,
                                l_trans_record_id,'AMT APP FROM 3');
format_amount_app4 := ARP_PROCESS_LOCKBOX.get_format_amount(p_trans_req_id,
                                l_trans_record_id,'AMT APP FROM 4');
format_amount_app5 := ARP_PROCESS_LOCKBOX.get_format_amount(p_trans_req_id,
                                l_trans_record_id,'AMT APP FROM 5');
format_amount_app6 := ARP_PROCESS_LOCKBOX.get_format_amount(p_trans_req_id,
                                l_trans_record_id,'AMT APP FROM 6');
format_amount_app7 := ARP_PROCESS_LOCKBOX.get_format_amount(p_trans_req_id,
                                l_trans_record_id,'AMT APP FROM 7');
format_amount_app8 := ARP_PROCESS_LOCKBOX.get_format_amount(p_trans_req_id,
                                l_trans_record_id,'AMT APP FROM 8');

INSERT INTO ar_pmts_interface_header_gt
        (transmission_request_id,
        transmission_record_id,
        currency_code,
        invoice_number,
        amount_applied_from,
        amount_applied,
        trans_to_receipt_rate,
        invoice_currency_code,
        record_status )
        SELECT  transmission_request_id,
                transmission_record_id,
                interface.currency_code,
                invoice1,
                decode(format_amount_app1, 'Y',
                    round(amount_applied_from1/power(10,fc1.precision),fc1.precision),
                    amount_applied_from1),
                decode(format_amount1, 'Y',
                    round(amount_applied1/power(10,fc.precision),fc.precision),
                    amount_applied1),
                nvl(trans_to_receipt_rate1,1),
                invoice_currency_code1,
                status
        FROM    ar_payments_interface interface,
                fnd_currencies fc,
                fnd_currencies fc1
        WHERE   invoice1 is NOT NULL
        AND     transmission_request_id = p_trans_req_id
        AND     status = 'AR_PLB_APP_OK'
        AND     fc.currency_code = interface.currency_code
        AND     fc1.currency_code = nvl(interface.invoice_currency_code1,
                                    interface.currency_code)
        AND     EXISTS (  SELECT 'X'
                          FROM  ar_pmts_interface_line_details line_details
                          WHERE line_details.transmission_record_id = interface.transmission_record_id
                          AND   line_details.invoice_number = interface.invoice1);

INSERT INTO ar_pmts_interface_header_gt
        (transmission_request_id,
        transmission_record_id,
        currency_code,
        invoice_number,
        amount_applied_from,
        amount_applied,
        trans_to_receipt_rate,
        invoice_currency_code,
        record_status )
        SELECT  transmission_request_id,
                transmission_record_id,
                interface.currency_code,
                invoice2,
                decode(format_amount_app2, 'Y',
                    round(amount_applied_from2/power(10,fc1.precision),fc1.precision),
                    amount_applied_from2),
                decode(format_amount2, 'Y',
                    round(amount_applied2/power(10,fc.precision),fc.precision),
                    amount_applied2),
                nvl(trans_to_receipt_rate2,1),
                invoice_currency_code2,
                status
        FROM    ar_payments_interface interface,
                fnd_currencies fc,
                fnd_currencies fc1
        WHERE   invoice2 is NOT NULL
        AND     transmission_request_id = p_trans_req_id
        AND     status = 'AR_PLB_APP_OK'
        AND     fc.currency_code = interface.currency_code
        AND     fc1.currency_code = nvl(interface.invoice_currency_code2,
                                    interface.currency_code)
        AND     EXISTS (  SELECT 'X'
                          FROM  ar_pmts_interface_line_details line_details
                          WHERE line_details.transmission_record_id = interface.transmission_record_id
                          AND   line_details.invoice_number = interface.invoice2);

INSERT INTO ar_pmts_interface_header_gt
        (transmission_request_id,
        transmission_record_id,
        currency_code,
        invoice_number,
        amount_applied_from,
        amount_applied,
        trans_to_receipt_rate,
        invoice_currency_code,
        record_status )
        SELECT  transmission_request_id,
                transmission_record_id,
                interface.currency_code,
                invoice3,
                decode(format_amount_app3, 'Y',
                    round(amount_applied_from3/power(10,fc1.precision),fc1.precision),
                    amount_applied_from3),
                decode(format_amount3, 'Y',
                    round(amount_applied3/power(10,fc.precision),fc.precision),
                    amount_applied3),
                nvl(trans_to_receipt_rate3,1),
                invoice_currency_code3,
                status
        FROM    ar_payments_interface interface,
                fnd_currencies fc,
                fnd_currencies fc1
        WHERE   invoice3 is NOT NULL
        AND     transmission_request_id = p_trans_req_id
        AND     status = 'AR_PLB_APP_OK'
        AND     fc.currency_code = interface.currency_code
        AND     fc1.currency_code = nvl(interface.invoice_currency_code3,
                                    interface.currency_code)
        AND     EXISTS (  SELECT 'X'
                          FROM  ar_pmts_interface_line_details line_details
                          WHERE line_details.transmission_record_id = interface.transmission_record_id
                          AND   line_details.invoice_number = interface.invoice3);

INSERT INTO ar_pmts_interface_header_gt
        (transmission_request_id,
        transmission_record_id,
        currency_code,
        invoice_number,
        amount_applied_from,
        amount_applied,
        trans_to_receipt_rate,
        invoice_currency_code,
        record_status )
        SELECT  transmission_request_id,
                transmission_record_id,
                interface.currency_code,
                invoice4,
                decode(format_amount_app4, 'Y',
                    round(amount_applied_from4/power(10,fc1.precision),fc1.precision),
                    amount_applied_from4),
                decode(format_amount4, 'Y',
                    round(amount_applied4/power(10,fc.precision),fc.precision),
                    amount_applied4),
                nvl(trans_to_receipt_rate4,1),
                invoice_currency_code4,
                status
        FROM    ar_payments_interface interface,
                fnd_currencies fc,
                fnd_currencies fc1
        WHERE   invoice4 is NOT NULL
        AND     transmission_request_id = p_trans_req_id
        AND     status = 'AR_PLB_APP_OK'
        AND     fc.currency_code = interface.currency_code
        AND     fc1.currency_code = nvl(interface.invoice_currency_code4,
                                    interface.currency_code)
        AND     EXISTS (  SELECT 'X'
                          FROM  ar_pmts_interface_line_details line_details
                          WHERE line_details.transmission_record_id = interface.transmission_record_id
                          AND   line_details.invoice_number = interface.invoice4);

INSERT INTO ar_pmts_interface_header_gt
        (transmission_request_id,
        transmission_record_id,
        currency_code,
        invoice_number,
        amount_applied_from,
        amount_applied,
        trans_to_receipt_rate,
        invoice_currency_code,
        record_status )
        SELECT  transmission_request_id,
                transmission_record_id,
                interface.currency_code,
                invoice5,
                decode(format_amount_app5, 'Y',
                    round(amount_applied_from5/power(10,fc1.precision),fc1.precision),
                    amount_applied_from5),
                decode(format_amount5, 'Y',
                    round(amount_applied5/power(10,fc.precision),fc.precision),
                    amount_applied5),
                nvl(trans_to_receipt_rate5,1),
                invoice_currency_code5,
                status
        FROM    ar_payments_interface interface,
                fnd_currencies fc,
                fnd_currencies fc1
        WHERE   invoice5 is NOT NULL
        AND     transmission_request_id = p_trans_req_id
        AND     status = 'AR_PLB_APP_OK'
        AND     fc.currency_code = interface.currency_code
        AND     fc1.currency_code = nvl(interface.invoice_currency_code5,
                                    interface.currency_code)
        AND     EXISTS (  SELECT 'X'
                          FROM  ar_pmts_interface_line_details line_details
                          WHERE line_details.transmission_record_id = interface.transmission_record_id
                          AND   line_details.invoice_number = interface.invoice5);

INSERT INTO ar_pmts_interface_header_gt
        (transmission_request_id,
        transmission_record_id,
        currency_code,
        invoice_number,
        amount_applied_from,
        amount_applied,
        trans_to_receipt_rate,
        invoice_currency_code,
        record_status )
        SELECT  transmission_request_id,
                transmission_record_id,
                interface.currency_code,
                invoice6,
                decode(format_amount_app6, 'Y',
                    round(amount_applied_from6/power(10,fc1.precision),fc1.precision),
                    amount_applied_from6),
                decode(format_amount6, 'Y',
                    round(amount_applied6/power(10,fc.precision),fc.precision),
                    amount_applied6),
                nvl(trans_to_receipt_rate6,1),
                invoice_currency_code6,
                status
        FROM    ar_payments_interface interface,
                fnd_currencies fc,
                fnd_currencies fc1
        WHERE   invoice6 is NOT NULL
        AND     transmission_request_id = p_trans_req_id
        AND     status = 'AR_PLB_APP_OK'
        AND     fc.currency_code = interface.currency_code
        AND     fc1.currency_code = nvl(interface.invoice_currency_code6,
                                    interface.currency_code)
        AND     EXISTS (  SELECT 'X'
                          FROM  ar_pmts_interface_line_details line_details
                          WHERE line_details.transmission_record_id = interface.transmission_record_id
                          AND   line_details.invoice_number = interface.invoice6);

INSERT INTO ar_pmts_interface_header_gt
        (transmission_request_id,
        transmission_record_id,
        currency_code,
        invoice_number,
        amount_applied_from,
        amount_applied,
        trans_to_receipt_rate,
        invoice_currency_code,
        record_status )
        SELECT  transmission_request_id,
                transmission_record_id,
                interface.currency_code,
                invoice7,
                decode(format_amount_app7, 'Y',
                    round(amount_applied_from7/power(10,fc1.precision),fc1.precision),
                    amount_applied_from7),
                decode(format_amount7, 'Y',
                    round(amount_applied7/power(10,fc.precision),fc.precision),
                    amount_applied7),
                nvl(trans_to_receipt_rate7,1),
                invoice_currency_code7,
                status
        FROM    ar_payments_interface interface,
                fnd_currencies fc,
                fnd_currencies fc1
        WHERE   invoice7 is NOT NULL
        AND     transmission_request_id = p_trans_req_id
        AND     status = 'AR_PLB_APP_OK'
        AND     fc.currency_code = interface.currency_code
        AND     fc1.currency_code = nvl(interface.invoice_currency_code7,
                                    interface.currency_code)
        AND     EXISTS (  SELECT 'X'
                          FROM  ar_pmts_interface_line_details line_details
                          WHERE line_details.transmission_record_id = interface.transmission_record_id
                          AND   line_details.invoice_number = interface.invoice7);

INSERT INTO ar_pmts_interface_header_gt
        (transmission_request_id,
        transmission_record_id,
        currency_code,
        invoice_number,
        amount_applied_from,
        amount_applied,
        trans_to_receipt_rate,
        invoice_currency_code,
        record_status )
        SELECT  transmission_request_id,
                transmission_record_id,
                interface.currency_code,
                invoice8,
                decode(format_amount_app8, 'Y',
                    round(amount_applied_from8/power(10,fc1.precision),fc1.precision),
                    amount_applied_from8),
                decode(format_amount8, 'Y',
                    round(amount_applied8/power(10,fc.precision),fc.precision),
                    amount_applied8),
                nvl(trans_to_receipt_rate8,1),
                invoice_currency_code8,
                status
        FROM    ar_payments_interface interface,
                fnd_currencies fc,
                fnd_currencies fc1
        WHERE   invoice8 is NOT NULL
        AND     transmission_request_id = p_trans_req_id
        AND     status = 'AR_PLB_APP_OK'
        AND     fc.currency_code = interface.currency_code
        AND     fc1.currency_code = nvl(interface.invoice_currency_code8,
                                    interface.currency_code)
        AND     EXISTS (  SELECT 'X'
                          FROM  ar_pmts_interface_line_details line_details
                          WHERE line_details.transmission_record_id = interface.transmission_record_id
                          AND   line_details.invoice_number = interface.invoice8);

UPDATE  ar_pmts_interface_line_details line_details
SET     status = 'AR_PLB_DUP_INVOICE'
WHERE   invoice_number IN (  SELECT invoice_number
                        FROM ar_pmts_interface_header_gt
                        WHERE  transmission_record_id = line_details.transmission_record_id
                        GROUP  BY invoice_number
                        HAVING count(invoice_number) > 1 )
AND     transmission_request_id = p_trans_req_id
AND     status = 'AR_PLB_NEW_RECORD';

UPDATE  ar_pmts_interface_line_details line_details
SET     status = 'AR_PLB_DUP_FRGT_CHRG'
WHERE   (transmission_record_id, invoice_number, apply_to)
        IN (SELECT transmission_record_id, invoice_number, apply_to
            FROM   ar_pmts_interface_line_details ld
            WHERE  ld.transmission_record_id = line_details.transmission_record_id
            AND    ld.invoice_number = line_details.invoice_number
            AND    ld.apply_to = line_details.apply_to
            AND    ld.transmission_request_id = p_trans_req_id
            GROUP BY transmission_record_id, invoice_number, apply_to
            HAVING count(*) >  1)
AND     transmission_request_id = p_trans_req_id
AND     apply_to IN ('FREIGHT', 'CHARGES')
AND     status = 'AR_PLB_NEW_RECORD';

UPDATE  ar_pmts_interface_line_details
SET     status = 'AR_PLB_NO_APP_INFO'
WHERE   transmission_request_id = p_trans_req_id
AND     amount_applied IS  NULL
AND     line_amount IS  NULL
AND     allocated_receipt_amount IS NULL
AND     status = 'AR_PLB_NEW_RECORD';

/* Does we need this since we are defaulting values? */
/*UPDATE  ar_pmts_interface_line_details
SET     status = 'AR_PLB_LINE_TAX_TOT_MISMATCH'
WHERE   transmission_request_id = p_trans_req_id
AND     amount_applied IS NOT NULL
AND     line_amount IS NOT NULL
AND     tax_amount IS NOT NULL
AND     amount_applied <> line_amount + tax_amount
AND     status = 'AR_PLB_NEW_RECORD'; */

/* We may need to handle duplicate invoices in future, here */
UPDATE ar_pmts_interface_header_gt gt
SET    (customer_trx_id) = ( SELECT customer_trx_id
                           FROM ra_customer_trx
                           WHERE trx_number = gt.invoice_number ) ;

UPDATE  ar_pmts_interface_line_details ld
SET     customer_trx_id = (SELECT customer_trx_id
                           FROM ar_pmts_interface_header_gt
                           WHERE invoice_number = ld.invoice_number
                           AND   transmission_record_id = ld.transmission_record_id
                           )
WHERE   transmission_request_id = p_trans_req_id;

/*UPDATE  ar_pmts_interface_header_gt gt
SET     precision = get_currency_precision(gt.currency_code),
        inv_precision = get_currency_precision(NVL(gt.inv_currency_code, gt.currency_code));*/

UPDATE  ar_pmts_interface_line_details line_details
SET     amount_applied = allocated_receipt_amount
WHERE   amount_applied IS NULL
AND     allocated_receipt_amount IS NOT NULL
AND     invoice_number IN ( SELECT invoice_number
                          FROM ar_pmts_interface_header_gt header
                          WHERE header.transmission_record_id = line_details.transmission_record_id
                          AND header.invoice_number = line_details.invoice_number
                          AND header.currency_code = header.invoice_currency_code
                          AND transmission_request_id = p_trans_req_id)
AND     transmission_request_id = p_trans_req_id
AND     status = 'AR_PLB_NEW_RECORD';

For cur_var in customer_trx_cursor(p_trans_req_id) LOOP

        SELECT  amount_due_original
        INTO    line_amt_due_original
        FROM    ra_customer_trx_lines TL,ra_customer_trx T
        WHERE   T.customer_trx_id = TL.customer_trx_id
        AND     T.customer_trx_id = cur_var.customer_trx_id
        AND     TL.line_type   = 'LINE'
        AND     rownum = 1;

        if line_amt_due_original is null then

                arp_det_dist_pkg.check_legacy_status
                (p_trx_id     => cur_var.customer_trx_id,
                 x_11i_adj    => ll_leg_adj,
                 x_mfar_adj   => ll_mfar_adj,
                 x_11i_app    => ll_leg_app,
                 x_mfar_app   => ll_mfar_app );

                 IF (ll_leg_adj = 'Y') OR (ll_leg_app = 'Y') then
                               UPDATE   ar_pmts_interface_line_details
                               SET      status = 'AR_PLB_BAL_STAMP_FAILED'
                               WHERE    transmission_request_id = p_trans_req_id
                               AND      invoice_number = ( SELECT invoice_number
                                                        FROM    ar_pmts_interface_header_gt
                                                        WHERE   transmission_request_id = p_trans_req_id
                                                        AND     customer_trx_id = cur_var.customer_trx_id);
                else
                                l_customer_trx.customer_trx_id := cur_var.customer_trx_id;

                                ARP_DET_DIST_PKG.SET_ORIGINAL_REM_AMT_R12(
                                	p_customer_trx => l_customer_trx,
                                	x_return_status => l_return_status,
                                	x_msg_count => l_msg_count,
                                	x_msg_data => l_msg_data,
                                	p_from_llca => 'Y'
                                );
                end if;

        end if;
END LOOP;

UPDATE  ar_pmts_interface_line_details line_details
SET     status = 'AR_PLB_INVALID_LINE_NUM'
WHERE   transmission_request_id = p_trans_req_id
AND     apply_to NOT in ('FREIGHT','CHARGES')
AND     NOT EXISTS ( select 'x'
                     FROM   ra_customer_trx trx,
                            ra_customer_trx_lines lines,
                            ar_pmts_interface_header_gt header
                     WHERE  trx.customer_trx_id = lines.customer_trx_id
                     AND    header.invoice_number = line_details.invoice_number
                     AND    header.transmission_record_id = line_details.transmission_record_id
                     AND    trx.customer_trx_id = header.customer_trx_id
                     AND    lines.line_type = 'LINE'
                     AND    lines.line_number = line_details.apply_to );

UPDATE  ar_pmts_interface_line_details line_details
SET     status = 'AR_PLB_INVALID_LINE_NUM'
WHERE   transmission_request_id = p_trans_req_id
AND     apply_to IN ('FREIGHT', 'CHARGES')
AND     NOT EXISTS ( select 'x'
                     FROM   ra_customer_trx trx,
                            ra_customer_trx_lines lines,
                            ar_pmts_interface_header_gt header
                     WHERE  trx.customer_trx_id = lines.customer_trx_id
                     AND    header.invoice_number = line_details.invoice_number
                     AND    header.transmission_record_id = line_details.transmission_record_id
                     AND    trx.customer_trx_id = header.customer_trx_id
                     AND    lines.line_type = line_details.apply_to );

FOR cur_var IN customer_trx_cursor(p_trans_req_id) LOOP
        SELECT  invoice_number,
                trans_to_receipt_rate,
                invoice_currency_code,
                currency_code
        INTO    l_invoice_number,
                l_trans_to_receipt_rate,
                l_inv_currency_code,
                l_currency_code
        FROM    ar_pmts_interface_header_gt
        WHERE   transmission_request_id = p_trans_req_id
        AND     customer_trx_id = cur_var.customer_trx_id
        AND     rownum = 1;

        FOR cur_var1 in apply_to_rec(p_trans_req_id,
                                cur_var.customer_trx_id) LOOP
                INSERT INTO ar_pmts_interface_lines_gt(
                transmission_request_id,
                customer_trx_id,
                currency_code,
                invoice_number,
                invoice_currency_code,
                trans_to_receipt_rate,
                apply_to
                )VALUES(
                p_trans_req_id,
                cur_var.customer_trx_id,
                l_currency_code,
                l_invoice_number,
                l_inv_currency_code,
                l_trans_to_receipt_rate,
                cur_var1.apply_to
                );
        END LOOP;
END LOOP;

UPDATE  ar_pmts_interface_lines_gt lines
SET     line_amt_remaining
        = (select sum(nvl(TL.amount_due_remaining,0))
           from ra_customer_trx_lines TL
	   where  TL.customer_trx_id = lines.customer_trx_id
	   and    TL.line_number = lines.apply_to
	   and    TL.line_type   = 'LINE'
        )
WHERE lines.apply_to NOT IN ('FREIGHT', 'CHARGES');

UPDATE  ar_pmts_interface_lines_gt lines
SET     tax_remaining
                = (select sum(nvl(TL.amount_due_remaining,0))
                   from ra_customer_trx_lines TL
                   where TL.link_to_cust_trx_line_id = (
                        select l.customer_trx_line_id
                        from ra_customer_trx_lines l
                        where l.customer_trx_id = lines.customer_trx_id
                        and   l.line_type       = 'LINE'
                        and   l.line_number     = lines.apply_to)
                   and TL.line_type = 'TAX'
        )
WHERE lines.apply_to NOT IN ('FREIGHT', 'CHARGES');

UPDATE  ar_pmts_interface_lines_gt lines
SET     freight_remaining
        = ( SELECT sum(nvl(TL.amount_due_remaining,0))
            FROM ra_customer_trx_lines TL
            WHERE TL.customer_trx_id = lines.customer_trx_id
            AND   TL.line_type = lines.apply_to)
WHERE   lines.apply_to = 'FREIGHT';

UPDATE  ar_pmts_interface_lines_gt lines
SET     charges_remaining
        = ( SELECT sum(nvl(TL.amount_due_remaining,0))
            FROM ra_customer_trx_lines TL
            WHERE TL.customer_trx_id = lines.customer_trx_id
            AND   TL.line_type = lines.apply_to)
WHERE   lines.apply_to = 'CHARGES';

UPDATE  ar_pmts_interface_line_details
SET     status = 'AR_PLB_INVALID_APP'
WHERE   transmission_request_id = p_trans_req_id
AND     (customer_trx_id, apply_to) IN
        (SELECT customer_trx_id, apply_to
        FROM    ar_pmts_interface_lines_gt
        WHERE   nvl(line_amt_remaining, 0) = 0
        AND     nvl(tax_remaining, 0) = 0
        AND     apply_to NOT IN ('FREIGHT', 'CHARGES'));

UPDATE  ar_pmts_interface_line_details
SET     status = 'AR_PLB_INVALID_APP'
WHERE   transmission_request_id = p_trans_req_id
AND     (customer_trx_id, apply_to) IN
        (SELECT customer_trx_id, apply_to
        FROM    ar_pmts_interface_lines_gt
        WHERE   freight_remaining = 0
        AND     apply_to = 'FREIGHT');

UPDATE  ar_pmts_interface_line_details
SET     status = 'AR_PLB_INVALID_APP'
WHERE   transmission_request_id = p_trans_req_id
AND     (customer_trx_id, apply_to) IN
        (SELECT customer_trx_id, apply_to
        FROM    ar_pmts_interface_lines_gt
        WHERE   charges_remaining = 0
        AND     apply_to = 'CHARGES' );

UPDATE  ar_pmts_interface_header_gt header
SET     default_by = 'LINE_AMT'
WHERE   transmission_request_id = p_trans_req_id
AND     invoice_number IN (SELECT invoice_number
                           FROM ar_pmts_interface_line_details
                           WHERE transmission_request_id = p_trans_req_id
                           AND   transmission_record_id = header.transmission_record_id
                           AND   allocated_receipt_amount IS NULL
                           AND   line_amount IS NOT NULL);

For cur_var IN trans_rec_cur(p_trans_req_id) loop
        FOR cur_var1 IN invoice_rec_cur(p_trans_req_id, cur_var.transmission_record_id) LOOP
        SELECT  invoice_currency_code,
                trans_to_receipt_rate,
                currency_code,
                invoice_number
        INTO    l_inv_currency_code,
                l_trans_to_receipt_rate,
                l_currency_code,
                l_invoice_number
        FROM    ar_pmts_interface_header_gt
        WHERE   customer_trx_id = cur_var1.customer_trx_id
        AND     transmission_request_id = p_trans_req_id
        AND     rownum = 1;

        l_default_by := NULL;

        SELECT  amount_applied, amount_applied_from
        INTO    hdr_amt_app, hdr_amt_app_frm
        FROM    ar_pmts_interface_header_gt
        WHERE   transmission_record_id = cur_var.transmission_record_id
        AND     invoice_number = l_invoice_number
        AND     transmission_request_id = p_trans_req_id;

        SELECT  SUM(DECODE(apply_to,'FREIGHT',0, 'CHARGES',0,1)) line_app_count,
                count(*) tot_app_count
         INTO   line_app_count, tot_app_count
         FROM   ar_pmts_interface_line_details
         WHERE  transmission_record_id = cur_var.transmission_record_id
         AND    invoice_number = l_invoice_number
         AND    transmission_request_id = p_trans_req_id ;

        UPDATE  ar_pmts_interface_line_details
        SET     amount_applied  = ARPCURR.CurrRound( allocated_receipt_amount/l_trans_to_receipt_rate,
                                l_currency_code),
                line_amount     = NULL,
                tax      = NULL
        WHERE   allocated_receipt_amount IS NOT NULL
        AND     amount_applied IS NULL
        AND     transmission_record_id = cur_var.transmission_record_id
        AND     invoice_number = l_invoice_number;

        IF SQL%ROWCOUNT = tot_app_count THEN
               UPDATE   ar_pmts_interface_header_gt
               SET      default_by = 'AMT_APP_FRM'
               WHERE    transmission_record_id = cur_var.transmission_record_id
               AND      invoice_number = l_invoice_number;

               l_default_by := 'AMT_APP_FRM';
        END IF;

        IF line_app_count > 0 THEN
                FOR cur_var2 IN app_to_cur(p_trans_req_id,
                                cur_var.transmission_record_id,
                                cur_var1.customer_trx_id) LOOP

                        SELECT  line_amt_remaining,
                                tax_remaining
                        INTO    l_line_amount_remaining,
                                l_line_tax_remaining
                        FROM    ar_pmts_interface_lines_gt
                        WHERE   customer_trx_id = cur_var1.customer_trx_id
                        AND     transmission_request_id = p_trans_req_id
                        AND     apply_to = cur_var2.apply_to;

                        IF PG_DEBUG in ('Y', 'C') THEN
                        	arp_util.debug('Apply_to ' || cur_var2.apply_to);
                        	arp_util.debug('Line_Amt '||l_line_amount_remaining);
                        	arp_util.debug('Tax_Amt '||l_line_tax_remaining);
                        END IF;

                        l_calc_per_line := ( Nvl(l_line_amount_remaining,0)
                                             / ( Nvl(l_line_amount_remaining,0)
                                               + Nvl(l_line_tax_remaining,0)));

			IF PG_DEBUG in ('Y', 'C') THEN
                        	arp_util.debug('l_calc_per_line ' || l_calc_per_line);
			END IF;

                        IF l_calc_per_line = 0 THEN
                                l_calc_per_line := 1;
                        END IF;

                        If cur_var2.line_amount IS NOT NULL
                        Then
                        IF PG_DEBUG in ('Y', 'C') THEN
                        arp_util.debug('First priority : Line Amount ');
                        arp_util.debug('Line Amount has taken precedence over the amount applied ');
                        END IF;
                        l_calc_tot_amount_app := ARPCURR.CurrRound(
                                                        ( cur_var2.line_amount
                                                         / l_calc_per_line
                                                        )
                                                        ,l_inv_currency_code);
                        l_calc_line_amount    := ARPCURR.CurrRound(cur_var2.line_amount
                                                        ,l_inv_currency_code);

                        -- Calculate Line amount based on the Amount Applied.
                        Elsif cur_var2.amount_applied IS NOT NULL
                        Then
                        IF PG_DEBUG in ('Y', 'C') THEN
                        arp_util.debug('Considered the Amount Applied value ');
                        End If;

                        l_calc_tot_amount_app   := ARPCURR.CurrRound(cur_var2.amount_applied
                                                        ,l_inv_currency_code);
                        l_calc_line_amount      :=  ARPCURR.CurrRound((l_calc_tot_amount_app
                                                  * l_calc_per_line),l_inv_currency_code);
                        End If;

                        IF PG_DEBUG in ('Y', 'C') THEN
                        arp_util.debug('l_calc_tot_amount_app -> '||to_char(l_calc_tot_amount_app));
                        arp_util.debug('l_calc_line_amount    -> '||to_char(l_calc_line_amount));
                        END IF;

                        -- Tax amount has taken precedence over the Line / amount applied
                        If cur_var2.tax IS NOT NULL
                        THEN
                        IF PG_DEBUG in ('Y', 'C') THEN
                        arp_util.debug('Tax Amount has taken precedence over the amount applied ');
                        End If;
                        l_calc_tax_amount := ARPCURR.CurrRound(cur_var2.tax
                                                        ,l_inv_currency_code);

                        l_calc_tot_amount_app := l_calc_line_amount +
                                                        l_calc_tax_amount;
                        Else
                        IF PG_DEBUG in ('Y', 'C') THEN
                        arp_util.debug('Amount Applied has taken precedence over the Tax Amount');
                        End If;
                        -- Amount applied has taken precedence over the tax amount
                        l_calc_tax_amount :=  ARPCURR.CurrRound((Nvl(l_calc_tot_amount_app,0)
                                                  - Nvl(l_calc_line_amount,0))
                                                  ,l_inv_currency_code);
                        End If;

                        UPDATE     ar_pmts_interface_line_details
                        SET        amount_applied  =   l_calc_tot_amount_app,
                                   line_amount     =   l_calc_line_amount,
                                   tax             =   l_calc_tax_amount
                        WHERE     transmission_record_id = cur_var.transmission_record_id
                        AND       invoice_number = l_invoice_number
                        AND       apply_to = cur_var2.apply_to
                        AND       apply_to NOT IN ('FREIGHT','CHARGES');
                END LOOP;
        END IF;

        IF l_inv_currency_code <> l_currency_code THEN
                UPDATE  ar_pmts_interface_line_details line_details
                SET     allocated_receipt_amount
                        =  ARPCURR.CurrRound( amount_applied * l_trans_to_receipt_rate,
                                                l_inv_currency_code)
                WHERE   amount_applied IS NOT NULL
                AND     allocated_receipt_amount IS NULL
                AND     transmission_request_id = p_trans_req_id
                AND     transmission_record_id = cur_var.transmission_record_id
                AND     invoice_number = l_invoice_number;

                IF SQL%ROWCOUNT = tot_app_count THEN
                       UPDATE   ar_pmts_interface_header_gt
                       SET      default_by = 'AMT_APP'
                       WHERE    transmission_record_id = cur_var.transmission_record_id
                       AND      invoice_number = l_invoice_number
                       AND      default_by <> 'LINE_AMT';
                       IF SQL%ROWCOUNT > 0 THEN
                                l_default_by := 'AMT_APP';
                       END IF;
                END IF;
        END IF;

        SELECT  SUM(amount_applied), SUM(allocated_receipt_amount)
        INTO    l_tot_amt_app, l_tot_amt_app_from
        FROM    ar_pmts_interface_line_details
        WHERE   transmission_request_id = p_trans_req_id
        AND     transmission_record_id = cur_var.transmission_record_id
        AND     invoice_number = l_invoice_number;

        IF l_default_by = 'AMT_APP_FRM' THEN
        arp_util.debug(' Deafult By '||l_default_by);
        UPDATE  ar_pmts_interface_line_details
        SET     amount_applied = amount_applied + (hdr_amt_app - l_tot_amt_app )
        WHERE   transmission_request_id = p_trans_req_id
        AND     transmission_record_id = cur_var.transmission_record_id
        AND     invoice_number = l_invoice_number
        AND     rownum = 1;
        END IF;

        IF l_default_by = 'AMT_APP' THEN
        arp_util.debug(' Deafult By '||l_default_by);
        UPDATE  ar_pmts_interface_line_details
        SET     allocated_receipt_amount = allocated_receipt_amount + (hdr_amt_app_frm - l_tot_amt_app_from )
        WHERE   transmission_request_id = p_trans_req_id
        AND     transmission_record_id = cur_var.transmission_record_id
        AND     invoice_number = l_invoice_number
        AND     rownum = 1;
        END IF;

        END LOOP;
END LOOP;
/* At this stage we will have all values calculated with us. So we can go for validation */
        UPDATE  ar_pmts_interface_line_details ld
        SET     status = 'AR_PLB_EXCEED_LINE_AMT'
        WHERE   transmission_request_id = p_trans_req_id
        AND     (customer_trx_id, apply_to) IN
               ( select lines_gt.customer_trx_id, lines_gt.apply_to
                 from   ar_pmts_interface_lines_gt ld1,
                        ( select customer_trx_id,
                                 apply_to,
                                 sum(lines.line_amount) tot_amt
                          from   ar_pmts_interface_line_details lines
                          where  lines.transmission_request_id = p_trans_req_id
                          group by customer_trx_id, apply_to ) lines_gt
                 where  lines_gt.customer_trx_id = ld1.customer_trx_id
                 and    lines_gt.apply_to = ld1.apply_to
                 and    ld1.apply_to NOT IN ('FREIGHT', 'CHARGES')
                 and    ld1.line_amt_remaining < lines_gt.tot_amt)
        AND     status = 'AR_PLB_NEW_RECORD';

        UPDATE  ar_pmts_interface_line_details ld
        SET     status = 'AR_PLB_EXCEED_TAX_AMT'
        WHERE   transmission_request_id = p_trans_req_id
        AND     (customer_trx_id, apply_to) IN
               ( select lines_gt.customer_trx_id, lines_gt.apply_to
                 from   ar_pmts_interface_lines_gt ld1,
                        ( select customer_trx_id,
                                 apply_to,
                                 sum(lines.tax) tot_amt
                          from   ar_pmts_interface_line_details lines
                          where  lines.transmission_request_id = p_trans_req_id
                          group by customer_trx_id, apply_to ) lines_gt
                 where  lines_gt.customer_trx_id = ld1.customer_trx_id
                 and    lines_gt.apply_to = ld1.apply_to
                 and    ld1.apply_to NOT IN ('FREIGHT', 'CHARGES')
                 and    ld1.tax_remaining < lines_gt.tot_amt)
        AND     status = 'AR_PLB_NEW_RECORD';

        UPDATE  ar_pmts_interface_line_details ld
        SET     status = 'AR_PLB_EXCEED_FRGT_AMT'
        WHERE   transmission_request_id = p_trans_req_id
        AND     (customer_trx_id, apply_to) IN
               ( select ld1.customer_trx_id, ld1.apply_to
                 from   ar_pmts_interface_lines_gt ld1,
                        ar_pmts_interface_line_details ld2
                 where  ld1.customer_trx_id = ld2.customer_trx_id
                 and    ld1.apply_to = ld2.apply_to
                 and    ld2.apply_to = 'FREIGHT'
                 and    ld2.transmission_request_id = p_trans_req_id
                 and    ld1.freight_remaining < ld2.amount_applied)
        AND     status = 'AR_PLB_NEW_RECORD';

        UPDATE  ar_pmts_interface_line_details ld
        SET     status = 'AR_PLB_EXCEED_CHRG_AMT'
        WHERE   transmission_request_id = p_trans_req_id
        AND     (customer_trx_id, apply_to) IN
               ( select ld1.customer_trx_id, ld1.apply_to
                 from   ar_pmts_interface_lines_gt ld1,
                        ar_pmts_interface_line_details ld2
                 where  ld1.customer_trx_id = ld2.customer_trx_id
                 and    ld1.apply_to = ld2.apply_to
                 and    ld2.transmission_request_id = p_trans_req_id
                 and    ld2.apply_to = 'CHARGES'
                 and    ld1.charges_remaining < ld2.amount_applied)
        AND     status = 'AR_PLB_NEW_RECORD';

        UPDATE  ar_pmts_interface_line_details line_details
        SET     status = 'AR_PLB_AMT_APP_INVALID'
        WHERE   transmission_request_id = p_trans_req_id
        AND     (transmission_record_id, customer_trx_id) IN
                (select header.transmission_record_id, header.customer_trx_id
                        from ar_pmts_interface_header_gt header,
                        (select transmission_record_id,
                                customer_trx_id,
                                sum(amount_applied) aa
                        from ar_pmts_interface_line_details ld
                        where ld.transmission_request_id = p_trans_req_id
                        group by transmission_record_id, customer_trx_id) line
                        where header.transmission_record_id = line.transmission_record_id
                        and header.customer_trx_id = line.customer_trx_id
                        and header.transmission_request_id = p_trans_req_id
                        and header.amount_applied <> line.aa)
        AND     status = 'AR_PLB_NEW_RECORD';

        UPDATE  ar_pmts_interface_line_details line_details
        SET     status = 'AR_PLB_AMT_APP_FRM_INVALID'
        WHERE   transmission_request_id = p_trans_req_id
        AND     (transmission_record_id, customer_trx_id) IN
                 (select header.transmission_record_id, header.customer_trx_id
                        from ar_pmts_interface_header_gt header,
                        (select transmission_record_id,
                                customer_trx_id,
                                sum(allocated_receipt_amount) aa
                        from ar_pmts_interface_line_details ld
                        where ld.transmission_request_id = p_trans_req_id
                        group by transmission_record_id, customer_trx_id) line
                        where header.transmission_record_id = line.transmission_record_id
                        and header.customer_trx_id = line.customer_trx_id
                        and header.transmission_request_id = p_trans_req_id
                        and header.amount_applied_from <> line.aa)
        AND     status = 'AR_PLB_NEW_RECORD';

        UPDATE  ar_pmts_interface_line_details
        SET     status = 'AR_PLB_LINE_OK'
        WHERE   status = 'AR_PLB_NEW_RECORD'
        AND     transmission_request_id = p_trans_req_id;

        IF p_allow_invalid_trx_num = 'Y' THEN
                UPDATE  ar_payments_interface interface
                SET     resolved_matching_number1 = NULL
                WHERE   (transmission_record_id, resolved_matching_number1)
                         IN (SELECT transmission_record_id, invoice_number
                           FROM ar_pmts_interface_line_details line_details
                           WHERE transmission_request_id = p_trans_req_id
                           AND status NOT IN ('AR_PLB_INVALID_RECORD', 'AR_PLB_LINE_OK'))
                AND     transmission_request_id = p_trans_req_id;

                UPDATE  ar_payments_interface interface
                SET     resolved_matching_number2 = NULL
                WHERE    (transmission_record_id, resolved_matching_number2)
                         IN (SELECT transmission_record_id, invoice_number
                           FROM ar_pmts_interface_line_details line_details
                           WHERE transmission_request_id = p_trans_req_id
                           AND status NOT IN ('AR_PLB_INVALID_RECORD', 'AR_PLB_LINE_OK'))
                AND     transmission_request_id = p_trans_req_id;

                UPDATE  ar_payments_interface interface
                SET     resolved_matching_number3 = NULL
                WHERE  (transmission_record_id, resolved_matching_number3)
                         IN (SELECT transmission_record_id, invoice_number
                           FROM ar_pmts_interface_line_details line_details
                           WHERE transmission_request_id = p_trans_req_id
                           AND status NOT IN ('AR_PLB_INVALID_RECORD', 'AR_PLB_LINE_OK'))
                AND     transmission_request_id = p_trans_req_id;

                UPDATE  ar_payments_interface interface
                SET     resolved_matching_number4 = NULL
                WHERE   (transmission_record_id, resolved_matching_number4)
                         IN (SELECT transmission_record_id, invoice_number
                           FROM ar_pmts_interface_line_details line_details
                           WHERE transmission_request_id = p_trans_req_id
                           AND status NOT IN ('AR_PLB_INVALID_RECORD', 'AR_PLB_LINE_OK'))
                AND     transmission_request_id = p_trans_req_id;

                UPDATE  ar_payments_interface interface
                SET     resolved_matching_number5 = NULL
                WHERE   (transmission_record_id, resolved_matching_number5)
                         IN (SELECT transmission_record_id, invoice_number
                           FROM ar_pmts_interface_line_details line_details
                           WHERE transmission_request_id = p_trans_req_id
                           AND status NOT IN ('AR_PLB_INVALID_RECORD', 'AR_PLB_LINE_OK'))
                AND     transmission_request_id = p_trans_req_id;

                UPDATE  ar_payments_interface interface
                SET     resolved_matching_number6 = NULL
                WHERE   (transmission_record_id, resolved_matching_number6)
                         IN (SELECT transmission_record_id, invoice_number
                           FROM ar_pmts_interface_line_details line_details
                           WHERE transmission_request_id = p_trans_req_id
                           AND status NOT IN ('AR_PLB_INVALID_RECORD', 'AR_PLB_LINE_OK'))
                AND     transmission_request_id = p_trans_req_id;

                UPDATE  ar_payments_interface interface
                SET     resolved_matching_number7 = NULL
                WHERE   (transmission_record_id, resolved_matching_number7)
                         IN (SELECT transmission_record_id, invoice_number
                           FROM ar_pmts_interface_line_details line_details
                           WHERE transmission_request_id = p_trans_req_id
                           AND status NOT IN ('AR_PLB_INVALID_RECORD', 'AR_PLB_LINE_OK'))
                AND     transmission_request_id = p_trans_req_id;

                UPDATE  ar_payments_interface interface
                SET     resolved_matching_number8 = NULL
                WHERE   (transmission_record_id, resolved_matching_number8)
                         IN (SELECT transmission_record_id, invoice_number
                           FROM ar_pmts_interface_line_details line_details
                           WHERE transmission_request_id = p_trans_req_id
                           AND status NOT IN ('AR_PLB_INVALID_RECORD', 'AR_PLB_LINE_OK'))
                AND     transmission_request_id = p_trans_req_id;
        ELSE
                UPDATE  ar_payments_interface interface
                SET     invoice1_status = 'AR_PLB_INVALID_LINE_DET'
                WHERE   (transmission_record_id, resolved_matching_number1)
                         IN (SELECT transmission_record_id, invoice_number
                           FROM ar_pmts_interface_line_details line_details
                           WHERE transmission_request_id = p_trans_req_id
                           AND line_details.status NOT IN ('AR_PLB_INVALID_RECORD', 'AR_PLB_LINE_OK'))
                AND     transmission_request_id = p_trans_req_id;

                UPDATE  ar_payments_interface interface
                SET     invoice2_status = 'AR_PLB_INVALID_LINE_DET'
                WHERE   (transmission_record_id, resolved_matching_number2)
                         IN (SELECT transmission_record_id, invoice_number
                           FROM ar_pmts_interface_line_details line_details
                           WHERE transmission_request_id = p_trans_req_id
                           AND line_details.status NOT IN ('AR_PLB_INVALID_RECORD', 'AR_PLB_LINE_OK'))
                AND     transmission_request_id = p_trans_req_id;

                UPDATE  ar_payments_interface interface
                SET     invoice3_status = 'AR_PLB_INVALID_LINE_DET'
                WHERE   (transmission_record_id, resolved_matching_number3)
                         IN (SELECT transmission_record_id, invoice_number
                           FROM ar_pmts_interface_line_details line_details
                           WHERE transmission_request_id = p_trans_req_id
                           AND line_details.status NOT IN ('AR_PLB_INVALID_RECORD', 'AR_PLB_LINE_OK'))
                AND     transmission_request_id = p_trans_req_id;

                UPDATE  ar_payments_interface interface
                SET     invoice4_status = 'AR_PLB_INVALID_LINE_DET'
                WHERE   (transmission_record_id, resolved_matching_number4)
                         IN (SELECT transmission_record_id, invoice_number
                           FROM ar_pmts_interface_line_details line_details
                           WHERE transmission_request_id = p_trans_req_id
                           AND line_details.status NOT IN ('AR_PLB_INVALID_RECORD', 'AR_PLB_LINE_OK'))
                AND     transmission_request_id = p_trans_req_id;

                UPDATE  ar_payments_interface interface
                SET     invoice5_status = 'AR_PLB_INVALID_LINE_DET'
                WHERE   (transmission_record_id, resolved_matching_number5)
                         IN (SELECT transmission_record_id, invoice_number
                           FROM ar_pmts_interface_line_details line_details
                           WHERE transmission_request_id = p_trans_req_id
                           AND line_details.status NOT IN ('AR_PLB_INVALID_RECORD', 'AR_PLB_LINE_OK'))
                AND     transmission_request_id = p_trans_req_id;

                UPDATE  ar_payments_interface interface
                SET     invoice6_status = 'AR_PLB_INVALID_LINE_DET'
                WHERE   (transmission_record_id, resolved_matching_number6)
                         IN (SELECT transmission_record_id, invoice_number
                           FROM ar_pmts_interface_line_details line_details
                           WHERE transmission_request_id = p_trans_req_id
                           AND line_details.status NOT IN ('AR_PLB_INVALID_RECORD', 'AR_PLB_LINE_OK'))
                AND     transmission_request_id = p_trans_req_id;

                UPDATE  ar_payments_interface interface
                SET     invoice7_status = 'AR_PLB_INVALID_LINE_DET'
                WHERE   (transmission_record_id, resolved_matching_number7)
                         IN (SELECT transmission_record_id, invoice_number
                           FROM ar_pmts_interface_line_details line_details
                           WHERE transmission_request_id = p_trans_req_id
                           AND line_details.status NOT IN ('AR_PLB_INVALID_RECORD', 'AR_PLB_LINE_OK'))
                AND     transmission_request_id = p_trans_req_id;

                UPDATE  ar_payments_interface interface
                SET     invoice8_status = 'AR_PLB_INVALID_LINE_DET'
                WHERE   (transmission_record_id, resolved_matching_number8)
                         IN (SELECT transmission_record_id, invoice_number
                           FROM ar_pmts_interface_line_details line_details
                           WHERE transmission_request_id = p_trans_req_id
                           AND line_details.status NOT IN ('AR_PLB_INVALID_RECORD', 'AR_PLB_LINE_OK'))
                AND     transmission_request_id = p_trans_req_id;

                UPDATE  ar_payments_interface interface
                SET     status = 'AR_PLB_INVALID_RECEIPT'
                WHERE   (item_number, nvl(batch_name, -1))
                        IN (SELECT item_number, nvl(batch_name, -1)
                            FROM ar_payments_interface interface1
                            WHERE interface1.transmission_request_id = p_trans_req_id
                            AND (  interface1.invoice1_status = 'AR_PLB_INVALID_LINE_DET'
                                OR interface1.invoice2_status = 'AR_PLB_INVALID_LINE_DET'
                                OR interface1.invoice3_status = 'AR_PLB_INVALID_LINE_DET'
                                OR interface1.invoice4_status = 'AR_PLB_INVALID_LINE_DET'
                                OR interface1.invoice5_status = 'AR_PLB_INVALID_LINE_DET'
                                OR interface1.invoice6_status = 'AR_PLB_INVALID_LINE_DET'
                                OR interface1.invoice7_status = 'AR_PLB_INVALID_LINE_DET'
                                OR interface1.invoice8_status = 'AR_PLB_INVALID_LINE_DET'))
                AND     transmission_request_id = p_trans_req_id;
        END IF;
	debug1('arp_process_lockbox.validate_llca_interface_data()-');
EXCEPTION
	WHEN OTHERS THEN
		p_return_status := 'E';
		debug1('Error '|| SQLERRM);
		debug1('validate_llca_interface_data : p_return_status ' || p_return_status);
		RAISE;
END validate_llca_interface_data;
--
FUNCTION get_format_amount (
	p_trans_req_id IN NUMBER,
        p_trans_rec_id IN NUMBER,
        p_column_type  IN varchar2)
RETURN VARCHAR2
IS
	l_format_yn  varchar2(10) := 'N';
BEGIN

	select amount_format_lookup_code
	into l_format_yn
	from
		AR_TRANS_FIELD_FORMATS FF,
		AR_TRANS_RECORD_FORMATS RF,
		AR_PAYMENTS_INTERFACE_all PI,
		AR_TRANSMISSIONS_all TR
	where TR.transmission_request_id = p_trans_req_id
	and   PI.transmission_record_id = p_trans_rec_id
	and   RF.transmission_format_id = TR.requested_trans_format_id
	and   RF.record_identifier = PI.record_type
	and   FF.transmission_format_id = RF.transmission_format_id
	and   FF.record_format_id = RF.record_format_id
	and   field_type_lookup_code= p_column_type;
	if l_format_yn = 'Y' then
		return l_format_yn;
	else
		return 'N';
	end if;
EXCEPTION
	WHEN OTHERS THEN
		return 'E';
END get_format_amount;
--
FUNCTION get_currency_precision(p_currency_code IN fnd_currencies.currency_code%TYPE )
RETURN NUMBER IS
        table_size      NUMBER;
        i               NUMBER;
        l_precision     NUMBER;
BEGIN
        table_size := NVL(l_table_curr.last, 0);

        FOR i in 1..table_size
        LOOP
                IF l_table_curr(i).currency_code = p_currency_code THEN
                        RETURN l_table_curr(i).precision;
                END IF ;
        END LOOP ;

        SELECT precision
        INTO   l_precision
        FROM   fnd_currencies
        WHERE  currency_code = p_currency_code ;

        l_table_curr(table_size+1).currency_code := p_currency_code ;
        l_table_curr(table_size+1).precision := l_precision ;

        RETURN l_precision;

EXCEPTION
        WHEN  NO_DATA_FOUND THEN
        RAISE;
END;
--
/*===========================================================================+
 | PROCEDURE                                                                 |
 |    insert_interim_line_details                                            |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    insert records into AR_INTERIM_CASH_LINE_DETAILS                       |
 |                                                                           |
 | SCOPE - PRIVATE                                                           |
 |                                                                           |
 | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED - NONE                            |
 |                                                                           |
 | ARGUMENTS  : IN:                                                          |
 |                                                                           |
 | MODIFICATION HISTORY  :                                                   |
 |                                                                           |
 |  28-Jul-07       vpusulur      Created.                                   |
 +===========================================================================*/
PROCEDURE insert_interim_line_details(
p_customer_trx_id IN  ra_customer_trx.customer_trx_id%type,
p_cash_receipt_id IN  ar_cash_receipts.cash_receipt_id%type,
p_cash_receipt_line_id IN  NUMBER,
p_trans_req_id    IN  ar_payments_interface.transmission_request_id%type,
p_batch_name      IN  ar_payments_interface.batch_name%type,
p_item_num        IN  ar_payments_interface.item_number%type,
p_return_status   OUT NOCOPY varchar2
)
IS

    status_count number := 0;
    inv_number   ra_customer_trx.trx_number%type;
    l_line_id    number;
    tot_frgt_chrg_amt number := 0;
    prorated_frgt_chrg_amt number := 0;
    prorated_frgt_chrg_amt_frm number := 0;
    remaining_frgt_chrg_amt number := 0;
    remaining_frgt_chrg_amt_frm number := 0;
    l_currency_code varchar2(15);
    l_inv_currency_code VARCHAR2(15);
    l_trans_to_receipt_rate NUMBER;
    l_amount_applied_from   NUMBER;
    l_amount_applied        NUMBER;
    l_item_number                ar_payments_interface.item_number%type;
    l_batch_name              ar_payments_interface.batch_name%type;

    cursor interface_det_lines(inv_num in varchar2,req_id in number, receipt_id in number) is
        select  status,
                invoice_number,
                apply_to,
                allocated_receipt_amount,
                amount_applied,
                line_amount,
                tax,
                freight,
                charges,
                line_discount,
                tax_discount,
                freight_discount,
                comments,
                transmission_record_id
        from ar_pmts_interface_line_details
        where transmission_request_id = req_id
        and invoice_number = inv_num
        and transmission_record_id in (
        select overflow.transmission_record_id
        from  ar_payments_interface payment, ar_payments_interface overflow,
        ar_trans_record_formats format, ar_transmissions transmissions,
        ar_interim_cash_receipts cash
        where payment.check_number = cash.receipt_number
        and   payment.transmission_request_id = overflow.transmission_request_id
        and   payment.item_number = overflow.item_number
        and   nvl(payment.batch_name, -1) = nvl(overflow.batch_name, -1)
        and   overflow.record_type = format.record_identifier
        and   transmissions.requested_trans_format_id = format.transmission_format_id
        AND   transmissions.transmission_request_id = payment.transmission_request_id
        AND   format.record_type_lookup_code = 'OVRFLW PAYMENT'
        and   cash.cash_receipt_id = receipt_id
        and   payment.transmission_request_id = req_id
	and   payment.item_number = l_item_number
	and  nvl(payment.batch_name, -1) = nvl(l_batch_name, -1)  ) ;


    cursor frgt_chrg_prorate(ct_id in number,app_to in varchar2) is
        select  customer_trx_line_id,
                amount_due_remaining
        from ra_customer_trx_lines
        where customer_trx_id = ct_id
        and   line_type = app_to;

    BEGIN
    debug1('insert_interim_line_details()+ ' ||p_cash_receipt_line_id );
    l_item_number := p_item_num;
    l_batch_name  := p_batch_name;


    select  trx_number
    into    inv_number
    from    ra_customer_trx
    where   customer_trx_id = p_customer_trx_id;

    select  currency_code
    into    l_currency_code
    from    ar_interim_cash_receipts
    where   cash_receipt_id = p_cash_receipt_id;

    select  count(distinct status)
    into    status_count
    from    ar_pmts_interface_line_details
    where   transmission_request_id = p_trans_req_id
    and     invoice_number = inv_number;

    select  count(distinct status)
    into    status_count
    from    ar_pmts_interface_line_details
    where   transmission_request_id = p_trans_req_id
    and     invoice_number = inv_number;

    if status_count = 1 then
        FOR det_line IN interface_det_lines(inv_number,p_trans_req_id,p_cash_receipt_id) LOOP
        if det_line.status = 'AR_PLB_LINE_OK' then
            if det_line.apply_to not in ('FREIGHT','CHARGES') then

                Select ar_activity_details_s.nextval
                INTO l_line_id
                from dual;

                insert into AR_INTERIM_CASH_LINE_DETAILS(
                    cash_receipt_id,
                    customer_trx_line_id,
                    source_id,
                    source_table,
                    allocated_receipt_amount,
                    amount,
                    tax,
                    freight,
                    charges,
                    last_update_date,
                    last_updated_by,
                    line_discount,
                    tax_discount,
                    freight_discount,
                    line_balance,
                    tax_balance,
                    creation_date,
                    created_by,
                    last_update_login,
                    comments,
                    apply_to,
                    attribute1,
                    attribute2,
                    attribute3,
                    attribute4,
                    attribute5,
                    attribute6,
                    attribute7,
                    attribute8,
                    attribute9,
                    attribute10,
                    attribute11,
                    attribute12,
                    attribute13,
                    attribute14,
                    attribute15,
                    attribute_category,
                    reference1,
                    reference2,
                    reference3,
                    reference4,
                    reference5,
                    group_id,
                    object_version_number,
                    created_by_module,
                    line_id)
                select
                    p_cash_receipt_id,
                    l.customer_trx_line_id,
                    null,
                    null,
                    nvl(det_line.allocated_receipt_amount,0),
                    nvl(det_line.line_amount,0),
                    nvl(det_line.tax,0),
                    nvl(det_line.freight,0),
                    nvl(det_line.charges,0),
                    sysdate,
                    null,
                    nvl(det_line.line_discount,0),
                    nvl(det_line.tax_discount,0),
                    nvl(det_line.freight_discount,0),
                    null,
                    null,
                    sysdate,
                    null,
                    null,
                    det_line.comments,
                    det_line.apply_to,
                    null,
                    null,
                    null,
                    null,
                    null,
                    null,
                    null,
                    null,
                    null,
                    null,
                    null,
                    null,
                    null,
                    null,
                    null,
                    null,
                    null,
                    null,
                    null,
                    null,
                    null,
                    null,
                    1,
                    'ARLPLB',
                    l_line_id
                from    ra_customer_trx_lines l
                where   l.customer_trx_id = p_customer_trx_id
                and     l.line_type   = 'LINE'
                and     l.line_number = det_line.apply_to;
        else
                Select  sum(nvl(amount_due_remaining,0))
                into    tot_frgt_chrg_amt
                from    ra_customer_trx_lines
                where   customer_trx_id = p_customer_trx_id
                and     line_type = det_line.apply_to;

                SELECT  invoice_currency_code,
                        trans_to_receipt_rate
                INTO    l_inv_currency_code,
                        l_trans_to_receipt_rate
                FROM    ar_pmts_interface_header_gt
                WHERE   customer_trx_id = p_customer_trx_id
                AND     transmission_request_id = p_trans_req_id
                AND     rownum = 1;

                remaining_frgt_chrg_amt := det_line.amount_applied;
                remaining_frgt_chrg_amt_frm := nvl(det_line.allocated_receipt_amount, 0);

                FOR line IN frgt_chrg_prorate(p_customer_trx_id, det_line.apply_to) LOOP

                prorated_frgt_chrg_amt := ARPCURR.CurrRound(
                                remaining_frgt_chrg_amt*
                                (line.amount_due_remaining/tot_frgt_chrg_amt),
                                l_inv_currency_code);

                IF l_currency_code <> l_inv_currency_code THEN
                    prorated_frgt_chrg_amt_frm := ARPCURR.CurrRound(
                                remaining_frgt_chrg_amt_frm*
                                (line.amount_due_remaining/tot_frgt_chrg_amt),
                                l_currency_code);
                END IF;

                Select ar_activity_details_s.nextval
                INTO l_line_id
                from dual;

                insert into AR_INTERIM_CASH_LINE_DETAILS(
                    cash_receipt_id,
                    customer_trx_line_id,
                    source_id,
                    source_table,
                    allocated_receipt_amount,
                    amount,
                    tax,
                    freight,
                    charges,
                    last_update_date,
                    last_updated_by,
                    line_discount,
                    tax_discount,
                    freight_discount,
                    line_balance,
                    tax_balance,
                    creation_date,
                    created_by,
                    last_update_login,
                    comments,
                    apply_to,
                    attribute1,
                    attribute2,
                    attribute3,
                    attribute4,
                    attribute5,
                    attribute6,
                    attribute7,
                    attribute8,
                    attribute9,
                    attribute10,
                    attribute11,
                    attribute12,
                    attribute13,
                    attribute14,
                    attribute15,
                    attribute_category,
                    reference1,
                    reference2,
                    reference3,
                    reference4,
                    reference5,
                    group_id,
                    object_version_number,
                    created_by_module,
                    line_id)
                values(
                    p_cash_receipt_id,
                    line.customer_trx_line_id,
                    null,
                    null,
                    prorated_frgt_chrg_amt_frm,
                    nvl(det_line.line_amount,0),
                    nvl(det_line.tax,0),
                    decode(det_line.apply_to,'FREIGHT',prorated_frgt_chrg_amt,0),
                    decode(det_line.apply_to,'CHARGES',prorated_frgt_chrg_amt,0),
                    sysdate,
                    null,
                    nvl(det_line.line_discount,0),
                    nvl(det_line.tax_discount,0),
                    decode(det_line.apply_to,'FREIGHT',
                    nvl(det_line.freight_discount,0)*(nvl(line.amount_due_remaining,0)/
                    tot_frgt_chrg_amt),0),
                    null,
                    null,
                    sysdate,
                    null,
                    null,
                    det_line.comments,
                    det_line.apply_to,
                    null,
                    null,
                    null,
                    null,
                    null,
                    null,
                    null,
                    null,
                    null,
                    null,
                    null,
                    null,
                    null,
                    null,
                    null,
                    null,
                    null,
                    null,
                    null,
                    null,
                    null,
                    null,
                    1,
                    'ARLPLB',
                    l_line_id);

                remaining_frgt_chrg_amt := remaining_frgt_chrg_amt - prorated_frgt_chrg_amt;
                remaining_frgt_chrg_amt_frm := remaining_frgt_chrg_amt_frm - nvl(prorated_frgt_chrg_amt_frm, 0);
                tot_frgt_chrg_amt := tot_frgt_chrg_amt - line.amount_due_remaining;

                END LOOP;
        end if;
    end if;
    delete from ar_pmts_interface_line_details
    where transmission_request_id = p_trans_req_id
    and   invoice_number = inv_number
    and   transmission_record_id = det_line.transmission_record_id
    and   status = 'AR_PLB_LINE_OK';
    END LOOP;
    end if;
    p_return_status := 'S';
    debug1('insert_interim_line_details()-');
EXCEPTION
    WHEN OTHERS THEN
        p_return_status := 'E';
        debug1('update_statuses : p_return_status ' || p_return_status);
        debug1('Exception : '||SQLERRM);
        RAISE;
END insert_interim_line_details;
--
--
-- This is a First-Time-Only code. It will get executed only
-- the first time the package is instantiated.
-- It fetches the matching_rules specified in ar_lookups
-- Opens and parses the cursor for that.
-- It stores the cursor_names in table opened_cursor_table.
--
-- Logic:
--     Open the cursor for the matching_option,
--        If the matching option is one of the standard ones.
--         i.e., INVOICE
--               PURCHASE_ORDER
--               SALES_ORDER
--               CONSOLIDATE_BILL
--        Else
--          Call arp_lockbox_hook.custom_cursor
--     Parse the cursor
--     Return cursor_name to find_cust_and_trx_num
--
--
BEGIN
  g_include_closed_inv := NVL(FND_PROFILE.value('AR_INC_CLINV_AUTO_ASSO'), 'Y');
  g_total_maching_options := 0;
  debug1('Common code for arp_process_lockbox +');
  Open all_matching_options;
  debug1('Opened all_matching_options cursor');
  LOOP
     FETCH all_matching_options
         INTO g_matching_option;
     EXIT WHEN all_matching_options%NOTFOUND;
     debug1('Fetched cursor matching_options found g_matching_option = ' || g_matching_option);
    IF (g_matching_option = 'INVOICE') THEN
      g_cursor_string := NULL;  -- Initilising, may not be required.
      /* Constructing the SELECT clause */
      g_cursor_string := 'select ';
      g_cursor_string := g_cursor_string ||
           'decode(count(distinct ps.customer_id), ' ||
           '    0, -9999,' ||  /* No Matching transaction */
           '    1, max(ps.customer_id),' ||
           '       decode(:b_use_matching_date,''NEVER'', -7777,'  ||  /* More than one customer, without matching date */
           '                                   ''ALWAYS'', -7777,' || /* More than one customer on Matching date */
           '                                   ''FOR_DUPLICATES'', decode(sum(decode(ps.trx_date, :b_current_matching_date, 1,' ||
           '                                                                                  0)), 1,' ||
           '                                                        max(decode(ps.trx_date, :b_current_matching_date, ps.customer_id, -7777 )),' ||
           '                                                                    -7777))), ';
      --
      /* Bugfix 2651113. Added DISTINCT so that lockbox does not error out
         for invoice with multiple terms.
	 Bug 7431540 : Modified Logic to handle closed invoices in data file
	 If a invoice is closed, then matching number will be passes ad -1111
	 whereas customer information is retained. Later, the application will
	 be rejected as 'AR_PLB_INVALID_MATCH'.
   	 Bug 9156980 : Modified the Logic so that the closed invoices are
   	 considered for customer identification only based on the profile
   	 option 'AR_INC_CL_INV_FOR_CUST_ID'*/
      g_cursor_string := g_cursor_string ||
           'decode(count(distinct ps.customer_id), ' ||
           '  0, NULL, ';  /* No Matching transaction */
      IF g_include_closed_inv = 'Y' THEN
      	 g_cursor_string := g_cursor_string ||
	   '  1, decode(count(distinct ps.status), 1, decode(max(ps.status), ''CL'', '||
	   ' (decode(max(tt.allow_overapplication_flag), ''N'', ''-1111'', max(ps.trx_number))), max(ps.trx_number)), max(ps.trx_number)), ';
      ELSE
	 g_cursor_string := g_cursor_string ||
	   '  1, max(ps.trx_number), ';
      END IF;
       g_cursor_string := g_cursor_string ||
	   '       decode(:b_use_matching_date,''NEVER'', NULL,'  ||  /* More than one customer, without matching date */
           '                                   ''ALWAYS'', NULL,' || /* More than one customer on Matching date */
           '                                   ''FOR_DUPLICATES'', decode(sum(decode(ps.trx_date, :b_current_matching_date, 1,' ||
           '                                                                                  0)), 1,';
      IF g_include_closed_inv = 'Y' THEN
      	 g_cursor_string := g_cursor_string ||
	   '                                                        max(decode(ps.trx_date, :b_current_matching_date, ' ||
           '                                                            decode(ps.status, ''CL'', (decode(tt.allow_overapplication_flag, ''N'', ''-1111'', '||
	   '                                                                   ps.trx_number)), ps.trx_number), NULL )),';
      ELSE
	 g_cursor_string := g_cursor_string ||
	   '                                                        max(decode(ps.trx_date, :b_current_matching_date, ps.trx_number, NULL )),';
      END IF;
         g_cursor_string := g_cursor_string ||
	   '                                                                    NULL))), ';
      --
      /* Bugfix 2651113. Added DISTINCT so that lockbox does not error out
         for invoice with multiple terms. */
      g_cursor_string := g_cursor_string ||
           'decode(count(distinct ps.customer_id), ' ||
           '  0, NULL, ' ||  /* No Matching transaction */
           '  1, min(ps.trx_date), ' ||
           '       decode(:b_use_matching_date,''NEVER'', NULL,'  ||  /* More than one customer, without matching date */
           '                                   ''ALWAYS'', NULL,' || /* More than one customer on Matching date */
           '                                   ''FOR_DUPLICATES'', decode(sum(decode(ps.trx_date, :b_current_matching_date, 1,' ||
           '                                                                                  0)), 1,' ||
           '                                                        max(decode(ps.trx_date, :b_current_matching_date, ps.trx_date, NULL )),' ||
           '                                                                    NULL))) ';
      --
      /* Constructing the FROM clause */
      g_cursor_string := g_cursor_string ||
           ' from ' ||
           ' hz_customer_profiles cps, ' || /* For site level profile */
           ' hz_customer_profiles cpc, ' || /* For customer level profile */
           ' ra_cust_trx_types tt, ' ||
           ' ar_payment_schedules ps   ';
      /* Constructing WHERE clause */
      /* Bug2106408. Modified the WHERE clause so that
	 ps.payment_schedule_id included all the ps_id satisfying the
	 matching condition instead of just the min(ps_id). */
      g_cursor_string := g_cursor_string ||
           ' where ' ||
           ' ps.trx_number = :b_current_matching_number ' ||
           ' and  ps.customer_id in ( select  decode(:b_pay_unrelated_customers, ''Y'', ps.customer_id, ' ||
           '                                                             nvl(:b_customer_id, ps.customer_id)) ' ||
           '                          from    dual ' ||
           '                          UNION ' ||
           '                          select  related_cust_account_id ' ||
           '                          from    hz_cust_acct_relate rel ' ||
           '                          where   rel.cust_account_id = :b_customer_id ' ||
           '                          and     rel.bill_to_flag = ''Y'' ' ||
           '                          and     rel.status = ''A''  ' ||
           '                          UNION ' ||
           '                          select  rel.related_cust_account_id ' ||
           '                            from  ar_paying_relationships_v rel,' ||
           '                                  hz_cust_accounts acc ' ||
           '                           where  acc.cust_account_id = :b_customer_id ' ||
           '                             and  acc.party_id = rel.party_id ' ||
           '                             and  to_date(:b_receipt_date,''YYYYMMDD'') BETWEEN effective_start_date  ' ||
           '                                                               AND effective_end_date ) ';
      /* bug2958709 : Added 'group by' and min(ps_id)  */
      /* bug3518714 : Added ps.trx_date in 'group by' clause  */
      /* Bug 7431540: Logic to fetch payment_schedule_id is modified such that, if all the installments for a particular
         invoice are closed, then fetch minimum payment_schedule_id for that transaction. Otherwise, fetch minimum open
	 payment_schedule_id. Commented out reference to ra_cust_trx_types as the query needs to fetch trx info even when
	 it is closed.
	 Bug 9156980 : Modified the Logic so that the closed invoices are
   	 considered for customer identification only based on the profile
   	 option 'AR_INC_CL_INV_FOR_CUST_ID'*/
      IF g_include_closed_inv = 'Y' THEN
      	 g_cursor_string := g_cursor_string ||
           ' and  ( (ps.payment_schedule_id IN ' ||
           '         (select decode( min( decode(ps.status, ''CL'', 99999999999999999999, ps.payment_schedule_id)), '||
           '                         99999999999999999999, min(ps.payment_schedule_id), '||
           '                         min( decode(ps.status, ''CL'', 99999999999999999999, ps.payment_schedule_id))) '  ||
           '         from   ar_payment_schedules ps '
     /*    '                ra_cust_trx_types    tt ' || */;
      ELSE
         g_cursor_string := g_cursor_string ||
	   ' and  ( (ps.payment_schedule_id IN ' ||
           '         (select min(ps.payment_schedule_id) '  ||
           '         from   ar_payment_schedules ps, ' ||
           '                ra_cust_trx_types    tt ';
      END IF;
         g_cursor_string := g_cursor_string ||
	   '         where  ps.trx_number = :b_current_matching_number ' ||
           '         and    ps.class not in (''PMT'', ''GUAR'') ';
      IF g_include_closed_inv = 'N' THEN
      	 g_cursor_string := g_cursor_string ||
           '         and    ps.status = decode(tt.allow_overapplication_flag,' ||
           '                         ''N'', ''OP'', ps.status) ';
      END IF;
	 g_cursor_string := g_cursor_string ||
           '         and    ps.customer_id in ( select  '||
           '                                    decode(:b_pay_unrelated_customers,''Y'', ps.customer_id, ' ||
           '                          nvl(:b_customer_id, ps.customer_id)) ' ||
           '                          from    dual ' ||
           '                          UNION ' ||
           '                          select  related_cust_account_id ' ||
           '                          from    hz_cust_acct_relate rel ' ||
           '                          where   rel.cust_account_id = :b_customer_id ' ||
           '                          and     rel.bill_to_flag = ''Y'' ' ||
           '                          and     rel.status = ''A''  ' ||
           '                          UNION ' ||
           '                          select  rel.related_cust_account_id ' ||
           '                            from  ar_paying_relationships_v rel,' ||
           '                                  hz_cust_accounts acc ' ||
           '                           where  acc.cust_account_id = :b_customer_id ' ||
           '                             and  acc.party_id = rel.party_id ' ||
           '                             and  to_date(:b_receipt_date,''YYYYMMDD'') BETWEEN effective_start_date  ' ||
           '                                                               AND effective_end_date ) ';
      IF g_include_closed_inv = 'N' THEN
      	 g_cursor_string := g_cursor_string ||
           '         and    ps.cust_trx_type_id = tt.cust_trx_type_id ';
      END IF;
         g_cursor_string := g_cursor_string ||
           ' group by ps.customer_id, ps.trx_date)) or ' ||
           '       (ps.class = ''CM'' and ps.terms_sequence_number = 1)) ';
      IF g_include_closed_inv = 'N' THEN
      	 g_cursor_string := g_cursor_string ||
           ' and  ps.status = decode(tt.allow_overapplication_flag,' ||
           '                         ''N'', ''OP'', ps.status) ';
      END IF;
         g_cursor_string := g_cursor_string ||
           ' and  ps.class not in (''PMT'', ''GUAR'') ' ||
           ' and  ps.cust_trx_type_id = tt.cust_trx_type_id ' ||
           ' and  ps.customer_id = cpc.cust_account_id ' ||
           ' and  cpc.site_use_id is NULL ' ||
           ' and  ps.customer_site_use_id = cps.SITE_USE_ID (+) ' ||
           ' and  nvl(cps.lockbox_matching_option, ' ||
           '           nvl(cpc.lockbox_matching_option, :b_lockbox_matching_option)) = ''INVOICE'' ' ||
           ' and  ps.trx_date = decode(:b_use_matching_date, ''ALWAYS'', :b_current_matching_date, ' ||
           '                                                           ps.trx_date) ';
    --
    -- Added distinct condition to the second and third select statements
    -- to fix bug 1209136. The first select always had the distinct condition
    -- when code was added for matching with sales order
    --
    -- Changed count(distinct customer_id) to count(distinct customer_trx_id).
    -- Also added a condition to check if the invoice is open.
    -- Both are required to fix bug 1629752.

    -- Bug 2466415 : Changed the condition count(distinct customer_trx_id)
    -- to count(distinct rct.bill_to_customer_id), reverting part of the fix done
    -- for bug 1629752

    -- Bug 2466415 : Changed the condition count(distinct customer_trx_id)
    -- to count(distinct rct.bill_to_customer_id), reverting part of the fix done
    -- for bug 1629752

    ELSIF (g_matching_option = 'SALES_ORDER') THEN
      /* Constructing SELECT CLAUSE */
      g_cursor_string := 'select ';
      g_cursor_string := g_cursor_string ||
        ' decode(count(distinct rct.bill_to_customer_id), ' ||
        '   0, -9999, ' ||  /* No such SO Num */
        '   1, max(rct.bill_to_customer_id), ' ||
        '      decode(:b_use_matching_date,''NEVER'', -7777, ' || /* Multiple customers without matching date  */
	'  		                   ''ALWAYS'', -7777, ' || /* Multiple customerswith matching date */
	'		                   ''FOR_DUPLICATES'', decode(sum(decode(rctl.sales_order_date, :b_current_matching_date, 1, ' ||
	'	 						   0)), 1, ' ||
        '                max(decode(rctl.sales_order_date, :b_current_matching_date, rct.bill_to_customer_id, -7777)), ' ||
	'									   -7777))), ';
    --
      g_cursor_string := g_cursor_string ||
        ' decode(count(distinct rct.bill_to_customer_id), ' ||
        '     0, null, '; /* No such SO Num */
      IF g_include_closed_inv = 'Y' THEN
      	 g_cursor_string := g_cursor_string ||
	   '  1, decode(count(distinct ps.status), 1, decode(max(ps.status), ''CL'', '||
	   ' (decode(max(rctt.allow_overapplication_flag), ''N'', ''-1111'', max(ps.trx_number))), max(ps.trx_number)), max(decode(ps.status, ''CL'', '''', ps.trx_number))), ';
      ELSE
	       g_cursor_string := g_cursor_string ||
	   '  1, max(ps.trx_number), ';
      END IF;
       g_cursor_string := g_cursor_string ||
        '       decode(:b_use_matching_date,''NEVER'', null, ' || /* Multiple customers without matching date  */
	'		                    ''ALWAYS'', null, ' || /* Multiple customerswith matching date */
	'		                    ''FOR_DUPLICATES'', decode(sum(decode(rctl.sales_order_date, :b_current_matching_date, 1, ' ||
	'								   0)), 1, ';
	   IF g_include_closed_inv = 'Y' THEN
      	 g_cursor_string := g_cursor_string ||
	   '                                                        max(decode(rctl.sales_order_date, :b_current_matching_date, ' ||
           '                                                            decode(ps.status, ''CL'', (decode(rctt.allow_overapplication_flag, ''N'', ''-1111'', '||
	   '                                                                   ps.trx_number)), ps.trx_number), NULL )),';
     ELSE
	       g_cursor_string := g_cursor_string ||
	   '                                                        max(decode(rctl.sales_order_date, :b_current_matching_date, ps.trx_number, NULL )),';
      END IF;
         g_cursor_string := g_cursor_string ||
	'									   null))), ';
    --
      g_cursor_string := g_cursor_string ||
        ' decode(count(distinct rct.bill_to_customer_id), ' ||
        '     0, null, ' || /* No such SO Num */
        '     1, max(rct.trx_date), ' ||
        '        decode(:b_use_matching_date,''NEVER'', null, ' || /* Multiple customers without matching date  */
	'		                     ''ALWAYS'', null, ' || /* Multiple customers with matching date */
	'   		                     ''FOR_DUPLICATES'', decode(sum(decode(rctl.sales_order_date, :b_current_matching_date, 1, ' ||
	'								   0)), 1, ' ||
        '                max(decode(rctl.sales_order_date, :b_current_matching_date, rct.trx_date, null)), ' ||
	'									   null))) ';
    --
    -- Constructing FROM clause
      g_cursor_string := g_cursor_string ||
          ' from ' ||
          ' ra_cust_trx_types rctt, ' ||
          ' hz_customer_profiles cpc, ' ||
          ' hz_customer_profiles cps, ' ||
	  ' ar_payment_schedules ps, ' ||
          ' ra_customer_trx rct, ' ||
          ' ra_customer_trx_lines rctl ' ;
    --
    -- Constructing where clause
      g_cursor_string := g_cursor_string ||
         ' where ' ||
         ' rctl.sales_order = :b_current_matching_number ' ||
         ' and      rct.bill_to_customer_id in ( select  decode(:b_pay_unrelated_customers, ''Y'', ' ||
         '                                               rct.bill_to_customer_id, ' ||
         '                                               nvl(:b_customer_id, rct.bill_to_customer_id)) ' ||
         '                         from    dual ' ||
         '                         UNION ' ||
         '                         select  related_cust_account_id ' ||
         '                         from    hz_cust_acct_relate rel ' ||
         '                         where   rel.cust_account_id = :b_customer_id ' ||
         '                         and     rel.bill_to_flag = ''Y'' ' ||
         '                          and     rel.status = ''A''  ' ||
         '                          UNION ' ||
         '                          select  rel.related_cust_account_id ' ||
         '                            from  ar_paying_relationships_v rel,' ||
         '                                  hz_cust_accounts acc ' ||
         '                           where  acc.cust_account_id = :b_customer_id ' ||
         '                             and  acc.party_id = rel.party_id ' ||
         '                             and  to_date(:b_receipt_date,''YYYYMMDD'') BETWEEN effective_start_date  ' ||
         '                                                               AND effective_end_date ) ' ||
         ' and      rctt.accounting_affect_flag =  ''Y'' ' ||
         ' and      rctl.customer_trx_id = rct.customer_trx_id ' ||
         ' and      rct.cust_trx_type_id = rctt.cust_trx_type_id ' ||
         ' and      rctt.type not in (''PMT'', ''GUAR'') ' ||
         ' and      rct.complete_flag = ''Y'' ' ||
         ' and      rct.bill_to_customer_id = cpc.cust_account_id ' ||
         ' and      cpc.site_use_id is NULL ' ||
         ' and      rct.bill_to_site_use_id = cps.site_use_id (+) ' ||
         ' and      rct.customer_trx_id = ps.customer_trx_id ' ;
         IF g_include_closed_inv = 'N' THEN
            g_cursor_string := g_cursor_string ||
                              ' and      ps.status = decode(rctt.allow_overapplication_flag, ' ||
                                          '          ''N'', ''OP'', ps.status) ';
         END IF;
         g_cursor_string := g_cursor_string ||
         ' and      nvl(cps.lockbox_matching_option, ' ||
         '               nvl(cpc.lockbox_matching_option, :b_lockbox_matching_option)) = ''SALES_ORDER'' ' ||
         ' and      decode(rctl.sales_order_date,  ' ||
         '                   null, to_date(''01/01/1952'', ''MM/DD/YYYY''), rctl.sales_order_date)  ' ||
         '            = decode(:b_use_matching_date, ''ALWAYS'', :b_current_matching_date, ' ||
         '                                        decode(rctl.sales_order_date,  ' ||
         '                                                    null, to_date(''01/01/1952'', ''MM/DD/YYYY''), ' ||
         '                                      rctl.sales_order_date)) ';

    -- Added distinct condition to the second and third select statements
    -- to fix bug 1209136. The first select always had the distinct condition
    -- when code was added for matching with purchase order
    --
    -- Changed count(distinct customer_id) to count(distinct customer_trx_id).
    -- Also added a condition to check if the invoice is open.
    -- Both are required to fix bug 1629752.

    ELSIF (g_matching_option = 'PURCHASE_ORDER') THEN
      -- Constructing SELECT clause
      g_cursor_string := 'select ';
      g_cursor_string := g_cursor_string ||
        ' decode(count(distinct rct.bill_to_customer_id), ' ||
        '    0, -9999, ' ||  /* No such PO Num */
        '    1, max(rct.bill_to_customer_id), ' ||
        '       decode(:b_use_matching_date,''NEVER'', -7777,  ' || /* Multiple customers without matching date  */
        '                                    ''ALWAYS'', -7777, ' || /* Multiple customers with matching date */
        '                                    ''FOR_DUPLICATES'', decode(sum(decode(rct.purchase_order_date, :b_current_matching_date, 1, ' ||
        '                                                                   0)), 1, ' ||
        '                max(decode(rct.purchase_order_date, :b_current_matching_date, rct.bill_to_customer_id, -7777)), ' ||
        '                                                                           -7777 ))), ';
      --
      g_cursor_string := g_cursor_string ||
        ' decode(count(distinct rct.bill_to_customer_id), ' ||
        '    0, null, '; /* No such PO Num */
      IF g_include_closed_inv = 'Y' THEN
      	 g_cursor_string := g_cursor_string ||
	   '  1, decode(count(distinct ps.status), 1, decode(max(ps.status), ''CL'', '||
	   ' (decode(max(rctt.allow_overapplication_flag), ''N'', ''-1111'', max(ps.trx_number))), max(ps.trx_number)), max(decode(ps.status, ''CL'', '''', ps.trx_number))), ';
      ELSE
	       g_cursor_string := g_cursor_string ||
	   '  1, max(ps.trx_number), ';
      END IF;
       g_cursor_string := g_cursor_string ||
        '      decode(:b_use_matching_date,''NEVER'', null, ' ||  /* Multiple customers without matching date  */
        '                   ''ALWAYS'', null, ' ||/* Multiple customerswith matching date */
        '                   ''FOR_DUPLICATES'', decode(sum(decode(rct.purchase_order_date, :b_current_matching_date, 1, ' ||
        '                                                                   0)), 1, ' ;
      IF g_include_closed_inv = 'Y' THEN
      	 g_cursor_string := g_cursor_string ||
	   '                                                        max(decode(rct.purchase_order_date, :b_current_matching_date, ' ||
           '                                                            decode(ps.status, ''CL'', (decode(rctt.allow_overapplication_flag, ''N'', ''-1111'', '||
	   '                                                                   ps.trx_number)), ps.trx_number), NULL )),';
     ELSE
	       g_cursor_string := g_cursor_string ||
	   '                                                        max(decode(rct.purchase_order_date, :b_current_matching_date, ps.trx_number, NULL )),';
      END IF;
         g_cursor_string := g_cursor_string ||
       '                                                                                           null))), ';
      --
      g_cursor_string := g_cursor_string ||
       ' decode(count(distinct rct.bill_to_customer_id), ' ||
       '    0, null, ' || /* No such PO Num */
       '    1, max(rct.trx_date), ' ||
       '       decode(:b_use_matching_date,''NEVER'', null, ' ||  /* Multiple customers without matching date  */
       '                                   ''ALWAYS'', null, ' || /* Multiple customers with matching date */
       '                                   ''FOR_DUPLICATES'', decode(sum(decode(rct.purchase_order_date, :b_current_matching_date, 1, ' ||
       '                                                                                   0)), 1, ' ||
       '                 max(decode(rct.purchase_order_date, :b_current_matching_date, rct.trx_date, null)), ' ||
       '                                                                                           null))) ';
      --
      -- Constructing FROM clause
      g_cursor_string := g_cursor_string ||
       ' from ' ||
       ' ra_cust_trx_types rctt, ' ||
       ' hz_customer_profiles cpc, ' ||
       ' hz_customer_profiles cps, ' ||
       ' ar_payment_schedules ps, ' ||
       ' ra_customer_trx rct ' ;
      --
      -- Constructing WHERE clause
      g_cursor_string := g_cursor_string ||
       ' where ' ||
       ' rct.purchase_order = :b_current_matching_number ' ||
       ' and      rct.bill_to_customer_id in ( select  decode(:b_pay_unrelated_customers, ''Y'', ' ||
       '                                         rct.bill_to_customer_id, ' ||
       '                                         nvl(:b_customer_id, rct.bill_to_customer_id)) ' ||
       '                          from    dual ' ||
       '                          UNION ' ||
       '                          select  related_cust_account_id ' ||
       '                          from    hz_cust_acct_relate rel ' ||
       '                          where   rel.cust_account_id = :b_customer_id ' ||
       '                          and     rel.bill_to_flag = ''Y'' ' ||
       '                          and     rel.status = ''A''  ' ||
       '                          UNION ' ||
       '                          select  rel.related_cust_account_id ' ||
       '                            from  ar_paying_relationships_v rel,' ||
       '                                  hz_cust_accounts acc ' ||
       '                           where  acc.cust_account_id = :b_customer_id ' ||
       '                             and  acc.party_id = rel.party_id ' ||
       '                             and  to_date(:b_receipt_date,''YYYYMMDD'') BETWEEN effective_start_date  ' ||
       '                                                               AND effective_end_date ) ' ||
       '  and      rctt.accounting_affect_flag =  ''Y'' ' ||
       '  and      rct.cust_trx_type_id = rctt.cust_trx_type_id ' ||
       '  and      rctt.type not in (''PMT'', ''GUAR'') ' ||
       '  and      rct.complete_flag = ''Y'' ' ||
       '  and      rct.bill_to_customer_id = cpc.cust_account_id ' ||
       '  and      cpc.site_use_id is NULL ' ||
       '  and      rct.bill_to_site_use_id = cps.site_use_id (+) ' ||
       '  and      rct.customer_trx_id = ps.customer_trx_id ';
       IF g_include_closed_inv = 'N' THEN
            g_cursor_string := g_cursor_string ||
                              ' and      ps.status = decode(rctt.allow_overapplication_flag, ' ||
                                          '          ''N'', ''OP'', ps.status) ';
       END IF;
         g_cursor_string := g_cursor_string ||
       '  and      nvl(cps.lockbox_matching_option, ' ||
       '                nvl(cpc.lockbox_matching_option, :b_lockbox_matching_option)) = ''PURCHASE_ORDER'' ' ||
       '  and      decode(rct.purchase_order_date,  ' ||
       '                    null, to_date(''01/01/1952'', ''MM/DD/YYYY''), rct.purchase_order_date)  ' ||
       '             = decode(:b_use_matching_date, ''ALWAYS'', :b_current_matching_date, ' ||
       '                                         decode(rct.purchase_order_date, ' ||
       '                                                     null, to_date(''01/01/1952'', ''MM/DD/YYYY''), ' ||
       '                                                      rct.purchase_order_date)) ';
    --
    ELSIF (g_matching_option = 'CONSOLIDATE_BILL') THEN
    --
    --
      -- Constructing SELECT clause
      g_cursor_string := 'select ';
      g_cursor_string := g_cursor_string ||
        ' decode(count(distinct ci.customer_id), ' ||
        ' 0, -9999, ' || /* No such consolidated billing num */
        ' 1, max(ci.customer_id), ' ||
        '    decode(:b_use_matching_date, ''NEVER '', -7777, ' ||  /* Multiple customers without matching date  */
        '            ''ALWAYS '', -7777, ' || /* Multiple customers with matching date */
        '                           ''FOR_DUPLICATES '', decode(sum(decode(ci.issue_date, :b_current_matching_date, 1, ' ||
        '                                                                          0)), 1, ' ||
        '               max(decode(ci.issue_date, :b_current_matching_date, ci.customer_id, -7777)), ' ||
        '                                                                                  -7777))), ' ||
        ' null, ' || /* No trx num information for match on consolidated bill */
        ' null  '; /* No trx date information for match on consolidated bill */
      --
      -- Constructing FROM clause
      g_cursor_string := g_cursor_string ||
        ' from ' ||
        ' hz_customer_profiles cpc, ' ||
        ' hz_customer_profiles cps, ' ||
        ' ar_cons_inv ci ';
      --
      -- Constructing WHERE clause
      g_cursor_string := g_cursor_string ||
        ' where ' ||
        ' ci.cons_billing_number = :b_current_matching_number ' ||
        ' and      ci.customer_id in ( select  decode(:b_pay_unrelated_customers,  ''Y'', ci.customer_id, ' ||
        '                                                             nvl(:b_customer_id, ci.customer_id)) ' ||
        '                         from    dual ' ||
        '                         UNION ' ||
        '                         select  related_cust_account_id ' ||
        '                         from    hz_cust_acct_relate rel ' ||
        '                         where   rel.cust_account_id = :b_customer_id ' ||
        '                         and     rel.bill_to_flag = ''Y'' ' ||
        '                          and     rel.status = ''A''  ' ||
        '                          UNION ' ||
        '                          select  rel.related_cust_account_id ' ||
        '                            from  ar_paying_relationships_v rel,' ||
        '                                  hz_cust_accounts acc ' ||
        '                           where  acc.cust_account_id = :b_customer_id ' ||
        '                             and  acc.party_id = rel.party_id ' ||
        '                             and  to_date(:b_receipt_date,''YYYYMMDD'') BETWEEN effective_start_date  ' ||
        '                                                               AND effective_end_date ) ' ||
        ' and      ci.customer_id = cpc.cust_account_id ' ||
        ' and      cpc.site_use_id is NULL ' ||
        ' and      ci.site_use_id = cps.site_use_id (+) ' ||
        ' and      nvl(cps.lockbox_matching_option, ' ||
        '               nvl(cpc.lockbox_matching_option, :b_lockbox_matching_option)) =  ''CONSOLIDATE_BILL'' ' ||
        ' and      trunc(ci.issue_date) ' ||
        '            = decode(:b_use_matching_date,  ''ALWAYS'', :b_current_matching_date, trunc(ci.issue_date)) ';
    ELSE /* Custom option */
      arp_lockbox_hook.cursor_for_matching_rule(p_matching_option=>g_matching_option,
                                     p_cursor_string=>l_cursor_string);
      -- Bug 2045569.  Have to set g_cursor_string.
      g_cursor_string := l_cursor_string;
    null;
    END IF;
    --
    debug1('Now Opening the cursor..');
    g_cursor_name := dbms_sql.open_cursor;
    debug1(g_cursor_string);
    debug1('Opened the cursor.. Now Parsing cursor..');
    dbms_sql.parse(g_cursor_name, g_cursor_string, dbms_sql.NATIVE);
    debug1('Parsed cursor.');
    g_total_maching_options := g_total_maching_options + 1;
    -- Insert into PL/SQL table here values of matching_option, cursor_name
    --
      debug1('Inserting values into PL/SQL Table for index ' || to_char(g_total_maching_options));
      debug1('Cursor Name is ' || to_char(g_cursor_name));
      opened_cursor_table(g_total_maching_options).option_name := g_matching_option;
      opened_cursor_table(g_total_maching_options).cursor_name := g_cursor_name;
  END LOOP;
  --
--
  debug1('Common code for arp_process_lockbox -');
END;  -- Common First-Time-Only code.
--
-- END arp_process_lockbox;

/

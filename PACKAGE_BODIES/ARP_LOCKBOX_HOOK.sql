--------------------------------------------------------
--  DDL for Package Body ARP_LOCKBOX_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_LOCKBOX_HOOK" AS
/*$Header: ARRLBHKB.pls 120.7.12010000.5 2009/03/20 17:36:59 aghoraka ship $*/
--
/*----------------------------------------------------------------------------
   proc_before_validation

   This procedure will be called before the validation is called from arlplb().
   If this procedure returns 0,
     arlplb.opc will understand that some processing had taken place in this
     procedure and it returned success. It will proceed with validation then.
   If this procedure returns 2,
     arlplb.opc will understand that some error had occured during the
     processing in this procedure and will exit rolling back the information.
   If out_insert_records is returned as 'Y', the first validation will
     insert the records into ar_interim_cash_receipt and receipt_line.
     In non-custom mode, this parameter returns 'Y', because we do not call
     validation second time. However, if you are planning to call the second
     validation, for customising lockbox,  assign this variable as 'N'.

 ----------------------------------------------------------------------------*/
PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

PROCEDURE proc_before_validation(out_errorbuf OUT NOCOPY VARCHAR2,
                                 out_errorcode OUT NOCOPY VARCHAR2,
                                 in_trans_req_id IN VARCHAR2,
                                 out_insert_records OUT NOCOPY VARCHAR2) IS
BEGIN
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('arp_lockbox_hook.proc_before_validation()+');
  END IF;
  out_errorcode := 0;
  out_errorbuf := NULL;
  out_insert_records := 'Y';
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('arp_lockbox_hook.proc_before_validation()-');
  END IF;
END proc_before_validation;
--
/*----------------------------------------------------------------------------
   proc_after_validation

   This procedure will be called after the validation is over from arlplb().
   If this procedure returns 0,
     arlplb.opc will understand that some processing had taken place in this
     procedure and arlplb.opc will fire the validation (arlval) again.
   If this procedure returns 2,
     arlplb.opc will understand that some error had occured during the
     processing in this procedure and will exit rolling back the information.
   If this procedure returns 9,
     arlplb.opc will not fire the validation second time and will go ahead
     with arlprt(). This is the same path as it was taking in base Rel 10.7
   If out_insert_records is returned as 'Y', the second validation will
     insert the records into ar_interim_cash_receipt and receipt_line.
     In non-custom mode, this parameter returns 'N', because we do not call
     validation second time. However, if you are planning to call the second
     validation and you have returned out_insert_records as 'N' in the
     proc_before_validation, you should return 'Y' here. This parameter is
     considered only if the out_errorcode was returned as 0.

 ----------------------------------------------------------------------------*/
PROCEDURE proc_after_validation(out_errorbuf OUT NOCOPY VARCHAR2,
                                 out_errorcode OUT NOCOPY VARCHAR2,
                                 in_trans_req_id IN VARCHAR2,
                                 out_insert_records OUT NOCOPY VARCHAR2) IS
--
BEGIN
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('arp_lockbox_hook.proc_after_validation()+');
  END IF;
  out_errorcode := 9;
  out_errorbuf := NULL;
  out_insert_records := 'N';
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('arp_lockbox_hook.proc_after_validation()-');
  END IF;
END proc_after_validation;
--
/*----------------------------------------------------------------------------
   proc_after_second_validation

   This procedure will be called after the second validation and before printing
   Lockbox execution report. It is called from arlplb().
   If this procedure returns 0,
     arlplb.opc will understand that this procedure returned success.
     It will proceed with printing report then.
   If this procedure returns anything other than 0,
     arlplb.opc will understand that some error had occured during the
     processing in this procedure and will exit rolling back the information.

 ----------------------------------------------------------------------------*/
PROCEDURE proc_after_second_validation(out_errorbuf OUT NOCOPY VARCHAR2,
                                 out_errorcode OUT NOCOPY VARCHAR2,
                                 in_trans_req_id IN VARCHAR2) IS
BEGIN
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('arp_lockbox_hook.proc_after_second_validation()+');
  END IF;
  out_errorcode := 0;
  out_errorbuf := NULL;
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('arp_lockbox_hook.proc_after_second_validation()-');
  END IF;
END proc_after_second_validation;
--
/*----------------------------------------------------------------------------
  Procedure

  cursor_for_matching_rule

   Oracle Receivables supplies the Packaged Procedure
   arp_lockbox_Hook.cursor_for_matching_rule, which can be used to
   add a matching rule to Lockbox functionality.
   If for example you need to match matching numbers and date passed to
   Lockbox with numbers and dates in your own custom tables
   custom_table.custom_number and custom_table.custom_date, instead of
   or in addition to standard matching options, you can use this feature.
   Or you can use this feature to match with other numbers and dates in
   the existing Receivables tables, as the need arises.

   This procedure expects a row in the AR_LOOKUPS table with lookup_type
   = 'ARLPLB_MATCHING_OPTION' and valid values for other columns required
   for the customized option.
   The master program arp_process_lockbox will fetch that row and if it
   finds it to be one of the non-standard (NOT built in core AR), it will
   pass the control to this procedure with the corresponding lookup_code
   in your database.
   The procedure should return a string that Dynamic SQL can use to open and
   parse a cursor.  You need to create this SQL string to replace the string
   named 'p_cursor_string'.  (see below an example).

Your string should have the following restrictions:
1.  The only allowed bind variables are as follows:
	a.  b_current_matching_number
	At execution time, this will get a value of a matching_number passed
	in the overflow or payment record.
	b. b_current_matching_date
	At the execution time, this will get a value of a matching_date passed
	in the overflow or payment record.
	c. b_current_installment
	At the execution time, this will get a value of installment num passed
	in overflow or payment record.
	d. b_customer_id
	If the customer is identified using customer number or MICR number,
	the program will enforce that the matching_number be of the same
	customer (with an exception of a value 'Y' in b_pay_unrelated
	_customers, see below).
	e. b_pay_unrelated_customers
	At the time of submitting the lockbox process, the user is prompted to
	enter whether to allow payment through unrelated customers or not.
	This variable will get a value 'Y' or 'N' based on that entry.
	f. b_lockbox_matching_option
	The value of this variable will match to the value of ar_lookups.lookup
	_code. It is also stored in ar_customer_profiles.lockbox_matching
	_option and in ar_lockboxes.lockbox_matching_option.
	g. b_use_matching_date
	This variable will be assigned a value 'NEVER', 'ALWAYS' or
	'FOR_DUPLICATES', depending upon the setup in your lockbox
	(in ar_lockboxes).

2.	If you are customizing lockbox using this procedure, you have to make
	sure that this procedure retrns a string that can create a valid cursor
	and that the SQL returns one and only one row (neither zero nor more
	than one).

3.	The program expects three return values from proposed SQL necessarily
	in the same order:
     	1. Customer_Id    (NUMBER(15))
     	2. Invoice Number (VARCHAR2(20))
     	3. Invoice Date   (DATE)

4.	The program expects that the combination of Invoice Number and invoice
	date is unique in ar_payment_schedules.

5.	You need not use all the bind variables that are provided in your
	proposed SQL.
	For example your SQL string can be like this:

p_cursor_string := 'select ct.customer_id, ct.trx_number, ct.trx_date ' ||
                   'from custom_table ct ' ||
                   'where ct.matching_number = :b_current_matching_number ' ||
                   ' and  ct.matching_date = :b_current_matching_date ';

6.	The SQL must be such that, if it does not match with given matching
	number and matching date (optional), it must return:
	customer_id = -9999,
	trx_number = null,
	trx_date = null.

7.	In case it matches to multiple customers, but the same trx numbers
	it must return customer_id = -7777. trx_number and trx_date will
	be ignored in this case.

8.	The program calling this procedure does not expect it to return
	any errors, as the definition of a cursor is a one-time procedure
	and if done carefully should not error.


 ----------------------------------------------------------------------------*/
PROCEDURE CURSOR_FOR_MATCHING_RULE(p_matching_option IN VARCHAR2,
                                   p_cursor_string OUT NOCOPY VARCHAR2) IS
BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('arp_lockbox_hook.cursor_for_matching_rule()+');
    END IF;
    p_cursor_string := 'select -9999, NULL, NULL from dual';
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('arp_lockbox_hook.cursor_for_matching_rule()+');
    END IF;
    RETURN;
END cursor_for_matching_rule;
--
/*----------------------------------------------------------------------------
  Procedure

  cursor_for_custom_llca

   Oracle Receivables supplies the Packaged Procedure
   arp_lockbox_Hook.cursor_for_custom_llca, which can be used to :-

   1. Customise lockbox to add any matching rules of customers chioce.
   2. Earlier custom matching rule functionality provided in the PROCEDURE
      CURSOR_FOR_MATCHING_RULE, has a limitaion that each custom matching number
      provided in tha lockbox data file should be resolved to only one invoice
      number.Now this new custom hook is capable to handle, any mutiple invoice
      numbers, to which the custom matching number is resolved to.
   3. Customise lockbox to apply receipts at line level.Customers can provide the
      invoice line details to which this receipt is to be applied, in this procedure.


   Usage :-
   --------
    The pl/sql table p_unresolved_inv_array is populated with, one record for each
    matching number in the datafile, and each record containing the values,
	1. matching_number given in the lockbox datafile,
	2. item_number of the item in which it was applied,
	3. and the amount_applied on the matching_number.

    Customers can write custom code which accepts any or all of the values
    in (matching_number, item_number, amount_applied), from the pl/sql table
    unresolved_invoice_array. And this code should fetch the invoice_number(s)
    and the corresponding amount_applied on that invoice. And this data is to
    be populated in the pl/sql table p_invoice_array, one row for each resolved
    invoice number, with structure as below :-

	TYPE invoice_record IS RECORD
	(
		matching_number		varchar2(15), -- Unresolved matching_number
						      -- from the datafile.
		item_number		number,	      -- Item number from datafile.
		invoice_number		varchar2(15), -- Resolved invoice number.
		amount_applied		number        -- Amount to be applied on this invoice.
		amount_applied_from NUMBER,     -- Amount applied in Receipt Currency
		trans_to_receipt_rate NUMBER,   -- Exchange rate
		invoice_currency_code VARCHAR2(15),  -- Invoice Currency Code
		batch_name VARCHAR2(25),         -- Batch Name, if multiple batches are present
		record_type VARCHAR2(2)               -- record type (No need to populate this value)
	) ;
	TYPE invoice_array IS TABLE OF invoice_record INDEX BY BINARY_INTEGER ;

    For doing a line level cash application, a pl/sql table p_line_array, also need
    to be populated additionally, along with the resolved invoice details in the
    following format, for each resolved invoice number, one row for each invoice line.

	TYPE line_record IS RECORD
	(
                item_number             number,
                batch_name              varchar2(30),
		invoice_number		varchar2(50),
		apply_to		varchar2(150),
		amount_applied		number,
		allocated_receipt_amount number,
		line_amount		number,
		tax_amount		number,
		freight			number,
		charges			number
	) ;
	TYPE line_array IS TABLE OF line_record INDEX BY BINARY_INTEGER ;

	Guidelines to populate the line details pl/sql table p_line_array :-
	--------------------------------------------------------------------
	1. item_number = item number on the data file.
	                 Item number of resolved/matching number inside the data file.
	2. Batch_name  = Batch name of the invoice.
	                 Use this in case of batches present in the data file.
	                 Otherwise don't populate.
	3. invoice_number = Resolved invoice number.
	4. apply _to = line_number of invoice line to apply.
				(or)
	               'FREIGHT'/'CHARGES' to apply to
		       freight or charges of the invoice.
        5. amount_applied = total amount applied to this line.
        6. allocated_receipt_Amount = Amount Applied in receipt Currency
	7. line_amount and tax_amount.
		a. Should be populated only if apply_to = line_number.
		b. Should be either both null or either both populated.
		c. If both populated, then amount_applied = line_amount + tax_amount.
		d. If both null we prorate amount_applied for line and tax of the line.
	8. freight.
		a. should be populated only if apply_to = 'FREIGHT'.
		b. Can be null or populated.
		c. If populated then amount_applied = freight.
		d. If null, will be any way defaulted to amount_applied.
		e. If invoice has line level freight then we prorate this 'FREIGHT'
		   applied amount between the freight amounts of all lines.
	9. charges.
		-- All the rules are same as freight column for this column too.

    Points to note :-
    -----------------
    1. If custom code do not want to resolve any particular matching_numbers from the
       data file, they can just be simply ignored and it will be processed, as standard
       lockbox matching number. Anyway if some matching number is to ignored by the
       custom code, it should already be a invoice number, else will be reported as
       invalid number by,lockbox validation.

    2. If line level details are to be given to for matching number which custom code
       dont want to resolve, i.e already an invoice number then it should compulsarily
       be treated as resolved number, where resolved invoice number after resolving it
       will be same as it.

    3. Custom code should return only invoice numbers after resolving a matching number
       for all the matching numbers,if llca is required, i.e p_line_array has
       atleast one row.

    4. If llca is not needed, i.e if p_line_array is not populated at all then,
       custom code can return purchase order or sales order or CBI numbers, but
       all resolved numbers should be of same type of document.

    5. For cross currency application, either of the trans_to_receipt_rate or amount_
       applied_from must be provided, if not provided with the matching number.

    6. If trans_to_receipt_rate/invoice_currency_code/amount_applied_from is/are
       supplied with the matching number, then make sure that all the resolved
       numbers for this matching number belong to the same currency code(=invoice_
       currency_code with the matching number, if given).
 ----------------------------------------------------------------------------*/
PROCEDURE CURSOR_FOR_CUSTOM_LLCA(  p_unresolved_inv_array  IN OUT NOCOPY arp_lockbox_hook_pvt.invoice_array,
                                   p_invoice_array         IN OUT NOCOPY arp_lockbox_hook_pvt.invoice_array,
				   p_line_array            IN OUT NOCOPY arp_lockbox_hook_pvt.line_array ) IS

	/*******************PSEUDO CODE************************************************
	Declare cursor to fetch receipt applications.
	Declare cusrsor to fetch line level application details.
	********************PSEUDO CODE***********************************************/

BEGIN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('arp_lockbox_hook.cursor_for_custom_llca()+');
    END IF;

    /***********************PSEUDO CODE*****************************************
	Loop till last record in p_unresolved_inv_array

		Loop in cursor to fetch receipt applications.

			Put one record in p_invoice_array for each application.

			Loop in cursor to fetch line level application details.

				Put one record in p_line_array for each line detail.

			End Loop.

		End Loop.

	End Loop.
    ************************PSEUDO CODE****************************************/
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('arp_lockbox_hook.cursor_for_custom_llca()-');
    END IF;
    RETURN;
END cursor_for_custom_llca;
--
END arp_lockbox_hook;

/

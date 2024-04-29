--------------------------------------------------------
--  DDL for Package Body OKL_LOCKBOX_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_LOCKBOX_HOOK" AS
/*$Header: OKLRLBHB.pls 120.4 2006/07/07 10:07:24 pagarg noship $*/
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
PROCEDURE proc_before_validation(out_errorbuf OUT NOCOPY VARCHAR2,
                                 out_errorcode OUT NOCOPY VARCHAR2,
                                 in_trans_req_id IN VARCHAR2,
                                 out_insert_records OUT NOCOPY VARCHAR2) IS
BEGIN
  arp_util.debug('arp_lockbox_hook.proc_before_validation()+');
  IF nvl(arp_global.sysparam.ta_installed_flag,'N') = 'Y' THEN
    --lockbox_cover.proc_before_valid(in_trans_req_id,out_errorcode,out_errorbuf);
    out_insert_records := 'N';
  ELSE
    out_errorcode := 0;
    out_errorbuf := NULL;
    out_insert_records := 'N';
  END IF;
  arp_util.debug('arp_lockbox_hook.proc_before_validation()-');
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

p_api_version			 NUMBER := 1;
p_init_msg_list			 VARCHAR2(1);
x_return_status          VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
x_msg_count				 NUMBER;
x_msg_data				 VARCHAR(2000);

lp_trans_req_id          AR_PAYMENTS_INTERFACE.TRANSMISSION_REQUEST_ID%TYPE;

BEGIN

  lp_trans_req_id := in_trans_req_id;

  OKL_LCKBX_CSH_APP_PUB.handle_auto_pay ( p_api_version
                                         ,p_init_msg_list
                                         ,x_return_status
                                         ,x_msg_count
                                         ,x_msg_data
                                         ,lp_trans_req_id
                                        );
  arp_util.debug('arp_lockbox_hook.proc_before_validation()+');
  IF nvl(arp_global.sysparam.ta_installed_flag,'N') = 'Y' THEN
    --lockbox_cover.proc_after_valid(in_trans_req_id,out_errorcode,out_errorbuf);
    out_insert_records := 'Y';
  ELSE
    out_errorcode := 9;
    out_errorbuf := NULL;
    out_insert_records := 'Y';
  END IF;
  arp_util.debug('arp_lockbox_hook.proc_before_validation()-');
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
  arp_util.debug('arp_lockbox_hook.proc_after_second_validation()+');
  IF nvl(arp_global.sysparam.ta_installed_flag,'N') = 'Y' THEN
    --lockbox_cover.proc_after_second_valid(in_trans_req_id,out_errorcode,out_errorbuf);
    NULL;
  ELSE
    out_errorcode := 0;
    out_errorbuf := NULL;
  END IF;
  arp_util.debug('arp_lockbox_hook.proc_after_second_validation()-');
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
    arp_util.debug('arp_lockbox_hook.cursor_for_matching_rule()+');
    p_cursor_string := 'select -9999, NULL, NULL from dual';
    arp_util.debug('arp_lockbox_hook.cursor_for_matching_rule()+');
    RETURN;
END cursor_for_matching_rule;
--
END okl_lockbox_hook;

/

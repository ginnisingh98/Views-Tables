--------------------------------------------------------
--  DDL for Package Body AR_BR_REMIT_IMPORT_API_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_BR_REMIT_IMPORT_API_PUB" AS
/* $Header: ARBRIMRB.pls 120.4 2004/04/07 23:42:00 anukumar ship $ */
/* =======================================================================
 | Global Data Types							 |
 * ======================================================================*/

G_PKG_NAME      CONSTANT VARCHAR2(30) 	:=  'IMPREMAPI';
G_MSG_UERROR    CONSTANT NUMBER        	:=  FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR;
G_MSG_ERROR     CONSTANT NUMBER        	:=  FND_MSG_PUB.G_MSG_LVL_ERROR;
G_MSG_SUCCESS   CONSTANT NUMBER        	:=  FND_MSG_PUB.G_MSG_LVL_SUCCESS;
G_MSG_HIGH      CONSTANT NUMBER        	:=  FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH;
G_MSG_MEDIUM    CONSTANT NUMBER        	:=  FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM;
G_MSG_LOW       CONSTANT NUMBER        	:=  FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW;


/*---------------------------------------------------------------------------------------------------------------------------|
| PROCEDURE : Dummy_Remittance												     |
|                                                                                                                            |
| DESCRIPTION :                                                                                                              |
| This procedure will examine a remittance batch to see if it is empty. If it is empty it will cancel it by caling the       |
| routine ARP_BR_REMIT_BATCHES.cancel_remit(p_reserved_value,l_batch_applied_status).                                        |
|                                                                                                                            |
|---------------------------------------------------------------------------------------------------------------------------*/

PROCEDURE Dummy_Remittance (p_reserved_value ar_payment_schedules.reserved_value%TYPE,x_return_status  IN OUT NOCOPY VARCHAR2) is
count_brs number;
l_batch_applied_status AR_BATCHES.batch_applied_status%TYPE;
BEGIN
               --Check if the remittance is empty, i.e. has no Br's assiged to i,

               arp_standard.debug ('impremapi.dummy_remittance()+');

               select count(*)
               into count_brs
               from ar_transaction_history
               where batch_id = p_reserved_value
               and current_record_flag = 'Y';

	       select batch_applied_status
               into l_batch_applied_status
               from ar_batches
               where batch_id = p_reserved_value;

               if count_brs = 0 and l_batch_applied_status in ('COMPLETED_CREATION','STARTED_CREATION') THEN
                 ARP_BR_REMIT_BATCHES.cancel_remit(p_reserved_value,l_batch_applied_status);
               end if;

	       arp_standard.debug ('impremapi.dummy_remittance()-');

               EXCEPTION
                 WHEN OTHERS THEN
		       x_return_status := FND_API.G_RET_STS_ERROR;
		       ROLLBACK TO IMPORT_MAIN;
                       arp_standard.debug('EXCEPTION OTHERS: impremapi.Dummy_Remittance');
                       app_exception.raise_exception;
END;


/*---------------------------------------------------------------------------------------------------------------------------|
| PROCEDURE :  Check_BR_and_Batch_Status                                                                                     |
|                                                                                                                            |
| DESCRIPTION :           												     |
| Check that the BR is assigned to an approved remittance.                                                                   |
|---------------------------------------------------------------------------------------------------------------------------*/
PROCEDURE Check_BR_and_Batch_Status (p_internal_reference        IN  RA_CUSTOMER_TRX.Customer_trx_id%TYPE,
				     p_reserved_value 	         OUT NOCOPY AR_PAYMENT_SCHEDULES.reserved_value%TYPE,
				     p_payment_schedule_id       OUT NOCOPY AR_PAYMENT_SCHEDULES.payment_schedule_id%TYPE,
				     p_media_reference           OUT NOCOPY AR_BATCHES.media_reference%TYPE)
is

l_batch_applied_status          AR_BATCHES.batch_applied_status%TYPE;
l_status		  	AR_BATCHES.status%TYPE;
Invalid_Remittance_Status       Exception;

BEGIN

		arp_standard.debug ('impremapi.Check_BR_and_Batch_Status()+');

               /*---------------------------------------------------------------------------------------
                | Firstly check if the BR is currently assigned to an approved batch                   |
                --------------------------------------------------------------------------------------*/

                select max(reserved_value),     -- remittance batch id null check
                       max(payment_schedule_id)
                  into p_reserved_value,
                       p_payment_schedule_id
                from ar_payment_schedules
                where customer_trx_id = p_internal_reference
                and reserved_type = 'REMITTANCE';

                IF p_reserved_value is null THEN
                   fnd_message.set_name('AR_BR','AR_BR_TRX_INVALID');
                   app_exception.raise_exception;
                END IF;

		Select batch_applied_status,
		       status,
		       media_reference
		into   l_batch_applied_status,
		       l_status,
		       p_media_reference
	        from ar_batches
		where batch_id = p_reserved_value
		and type = 'BR_REMITTANCE';

     		IF l_batch_applied_status  NOT IN ('STARTED_CREATION','COMPLETED_CREATION') THEN
		   RAISE invalid_remittance_status;
		END IF;

 	        IF l_status <> 'OP' THEN
                   RAISE invalid_remittance_status;
                END IF;

		arp_standard.debug ('impremapi.Check_BR_and_Batch_Status()-');

                EXCEPTION
                       WHEN NO_DATA_FOUND THEN
			    ROLLBACK TO IMPORT_MAIN;
                            fnd_message.set_name ('AR_BR','AR_BR_TRX_INVALID');
			    arp_standard.debug ('EXCEPTION NO_DATA impremapi.Check_BR_and_Batch_Status');
			    app_exception.raise_exception;

		       WHEN invalid_remittance_status THEN
			    ROLLBACK TO IMPORT_MAIN;
			    fnd_message.set_name ('AR_BR','AR_BR_TRX_INVALID');
			    arp_standard.debug ('EXCEPTION invalid_remittance_status.Check_BR_and_Batch_Status');
                            app_exception.raise_exception;

		       WHEN OTHERS THEN
			    ROLLBACK TO IMPORT_MAIN;
			    arp_standard.debug ('EXCEPTION WHEN_OTHERS impremapi.Check_BR_and_Batch_Status');
			    app_exception.raise_exception;
END;

/*---------------------------------------------------------------------------------------------------------------------------|
| PROCEDURE :  compare_old_versus_new_values                                                                                 |
|                                                                                                                            |
| DESCRIPTION :                                                                                                              |
| a. Compares values on the database to values being supplied. For e.g. compares bank account details and if these differ the|
| n reports an appropriate error.                                                                                            |
|                                                                                                                            |
| CALLS TO EXTERNAL PROCEDURES :                                                                                             |
|                                                                                                                            |
|                                                                                                                            |
|----------------------------------------------------------------------------------------------------------------------------*/
PROCEDURE compare_old_versus_new_values (
  p_media_reference            IN  ar_batches.media_reference%TYPE,
  p_remittance_accounting_Date IN  ar_batches.gl_date%TYPE,
  p_remittance_method          IN  ar_batches.remit_method_code%TYPE,
  p_with_recourse_flag         IN  ar_batches.with_recourse_flag%TYPE,
  p_payment_method             IN  ar_receipt_methods.name%TYPE,
  p_remittance_date            IN  ar_batches.batch_date%TYPE,
  p_Currency_code              IN  ar_batches.currency_code%TYPE,
  p_remittance_bnk_acct_number IN  ce_bank_accounts.bank_account_num%TYPE,
  l_batch_applied_status       OUT NOCOPY ar_batches.batch_applied_status%TYPE,
  l_batch_id 		       OUT NOCOPY ar_batches.batch_id%TYPE
) IS

  l_remit_bank_acct_use_id     ce_bank_acct_uses_all.bank_acct_use_id%TYPE;
  l_currency_code              ar_batches.currency_code%TYPE;
  l_gl_date                    ar_batches.gl_date%type;
  l_with_recourse_flag         ar_batches.with_recourse_flag%TYPE;
  l_batch_date                 ar_batches.batch_date%TYPE;
  l_receipt_method_id          ar_batches.receipt_method_id%TYPE;
  l_remit_method_code          ar_batches.remit_method_code%TYPE;
  l_media_reference            ar_batches.media_reference%TYPE;
  l_reserved_value             ar_payment_schedules.reserved_value%TYPE;
  l_count                      NUMBER;
  l_payment_schedule_id        ar_payment_schedules.payment_schedule_id%TYPE;
  l_payment_method             ar_receipt_methods.name%TYPE;
  l_bank_account_num           ce_bank_accounts.bank_account_num%TYPE;

BEGIN

	        arp_standard.debug ('impremapi.Compare_old_versus_new_values ()+');

		select  remit_bank_acct_use_id,
                        currency_code,
                        gl_date,
                        with_recourse_flag,
                        batch_date,
                        receipt_method_id,
                        remit_method_code,
                        batch_applied_status,
                        batch_id

                into

                        l_remit_bank_acct_use_id,
                        l_currency_code,
                        l_gl_date,
                        l_with_recourse_flag,
                        l_batch_date,
                        l_receipt_method_id,
                        l_remit_method_code,
                        l_batch_applied_status,
                        l_batch_id

                from ar_batches
                where media_reference = p_media_reference
                and gl_date = p_remittance_accounting_Date
                and type = 'BR_REMITTANCE';


	        SELECT cba.bank_account_num INTO l_bank_account_num
                FROM   ce_bank_accounts cba,
                       ce_bank_acct_uses cbau
                WHERE  cbau.bank_acct_use_id =l_remit_bank_acct_use_id
                AND    cbau.bank_account_id = cba.bank_account_id;

 	        If l_bank_account_num <> p_remittance_bnk_acct_number THEN
                   fnd_message.set_name
                   ( 'AR_BR','AR_BR_INVALID_PARAMETER');
		   FND_MESSAGE.set_token('PARAMETER',' bank account ');
                   app_exception.raise_exception;
                END IF;

		IF l_currency_code<>p_currency_code THEN
                   fnd_message.set_name
                   ('AR_BR','AR_BR_INVALID_PARAMETER');
		   FND_MESSAGE.set_token('PARAMETER',' currency code ');
                   app_exception.raise_exception;
                END IF;

	        IF l_gl_date<>p_remittance_accounting_date THEN
                   fnd_message.set_name
                   ('AR_BR','AR_BR_INVALID_PARAMETER');
		   FND_MESSAGE.set_token('PARAMETER',' accounting date ');
                   app_exception.raise_exception;
                END IF;

	 	IF l_with_recourse_flag<>p_with_recourse_flag THEN
                   fnd_message.set_name
		   ('AR_BR','AR_BR_INVALID_PARAMETER');
                   FND_MESSAGE.set_token('PARAMETER',' recourse flag ');
                   app_exception.raise_exception;
                END IF;


		IF l_batch_date<>p_remittance_date THEN
		   fnd_message.set_name
                   ('AR_BR','AR_BR_INVALID_PARAMETER');
                   FND_MESSAGE.set_token('PARAMETER',' remittance date ');
		   app_exception.raise_exception;
                END IF;

		BEGIN
                         select  name

                         into    l_payment_method

                         from ar_receipt_methods
                         where receipt_method_id = l_receipt_method_id;


                         EXCEPTION
                                WHEN NO_DATA_FOUND THEN
                                     fnd_message.set_name ( 'AR', 'AR_BR_INVALID_RECEIPT_METHOD');
                                     app_exception.raise_exception;

		END;

                IF l_payment_method <> p_payment_method THEN
                   fnd_message.set_name
		   ('AR_BR','AR_BR_INVALID_PARAMETER');
                   FND_MESSAGE.set_token('PARAMETER',' payment method ');
                   app_exception.raise_exception;
                END IF;

	 	arp_standard.debug ('impremapi.Compare_old_versus_new_values ()-');

		EXCEPTION
                       WHEN NO_DATA_FOUND THEN
			    ROLLBACK TO IMPORT_MAIN;
			    arp_standard.debug ('EXCEPTION NO_DATA impremapi.Compare_old_versus_new_values');
                            app_exception.raise_exception;

                       WHEN OTHERS THEN
			    ROLLBACK TO IMPORT_MAIN;
			    arp_standard.debug ('EXCEPTION WHEN OTHERS impremapi.Compare_old_versus_new_values');
                            app_exception.raise_exception;

END;

/*---------------------------------------------------------------------------------------------------------------------------|
| PROCEDURE :  Existing_Remittance                                                                                           |
|                                                                                                                            |
| DESCRIPTION :                                                                                                              |
| a. Compares values on the database to values being supplied. For e.g. compares bank account details and if these differ the|
| n reports an appropriate error.                                                                                            |
| b. Checks that the BR supplied exists and if it does not reports an error.                                                 |
| c. Checks that the remittance is unapproved and if it is not reports an error.                                             |
| d. If the BR is valid :                                                                                                    |
|       Checks whether the BR is already assigned to the remittance being imported                                           |
|        If it is assigned                                                                                                   |
|            does nothing                                                                                                    |
|        else                                                                                                                |
|             Calls the Assign_BR_To_Remittance procedure                                                                    |
|e. If the BR is assigned to a different remittance                                                                          |
|       removes that assignment                                                                                              |
|       makes a new assignment to the new remittance calling Assign_BR_To_Remittance                                         |
|f. If there existed a previous assignment to a different remittance                                                         |
|      calls the procedure Dummy_Remittance                                                                                  |
|                                                                                                                            |
| CALLS TO EXTERNAL PROCEDURES :                                                                                             |
| AR_BILLS_MAINTAIN_PUB.Deselect_BR_Remit(l_payment_schedule_id,x_return_status);                                            |
| AR_BILLS_MAINTAIN_PUB.Select_BR_Remit(l_batch_id,l_payment_schedule_id,x_return_status);                                   |
|                                                                                                                            |
|---------------------------------------------------------------------------------------------------------------------------*/

PROCEDURE existing_remittance (
  p_media_reference            IN ar_batches.media_reference%TYPE,
  p_remittance_accounting_Date IN ar_batches.gl_date%TYPE,
  p_internal_reference         IN ra_customer_trx.customer_trx_id%TYPE,
  p_remittance_method          IN ar_batches.remit_method_code%TYPE,
  p_with_recourse_flag         IN ar_batches.with_recourse_flag%TYPE,
  p_payment_method	       IN ar_receipt_methods.name%TYPE,
  p_remittance_date            IN ar_batches.batch_date%TYPE,
  p_currency_code              IN ar_batches.currency_code%TYPE,
  p_remittance_bnk_acct_number IN ce_bank_accounts.bank_account_num%TYPE,
  x_return_status              IN OUT NOCOPY VARCHAR2
) IS

l_media_reference              AR_BATCHES.media_reference%TYPE;
l_reserved_value               AR_PAYMENT_SCHEDULES.reserved_value%TYPE;
l_payment_schedule_id          AR_PAYMENT_SCHEDULES.payment_schedule_id%TYPE;
l_batch_applied_status         AR_BATCHES.batch_applied_status%TYPE;
l_batch_id                     AR_BATCHES.batch_id%TYPE;

Invalid_Br Exception;
invalid_Remittance_status Exception;

BEGIN

		arp_standard.debug ('impremapi.Existing_Remittance ()+');

	        compare_old_versus_new_values(p_media_reference,
					      p_remittance_accounting_Date,
					      p_remittance_method,
				              p_with_recourse_flag,
					      p_payment_method,
					      p_remittance_date,
					      p_Currency_code,
					      p_remittance_bnk_acct_number,
					      l_batch_applied_status,
					      l_batch_id);

 		Check_BR_and_batch_status (p_internal_reference,l_reserved_value,l_payment_schedule_id,l_media_reference);

		/*----------------------------------------------------------------------------------------
                 | if the media references differ then deassign from the existing remittance and assign  |
                 | to the new one									 |
                 |---------------------------------------------------------------------------------------*/

                IF l_media_reference <> p_media_reference or l_media_reference is null then
		   arp_standard.debug ('impremapi.Existing_Remittance - call deselect');
                   AR_BILLS_MAINTAIN_PUB.Deselect_BR_Remit(l_payment_schedule_id,x_return_status);
                   AR_BILLS_MAINTAIN_PUB.Select_BR_Remit(l_batch_id,l_payment_schedule_id,x_return_status);
		   dummy_remittance(l_reserved_value, x_return_status);
		END IF;

	        arp_standard.debug ('impremapi.Existing_Remittance ()-');

		EXCEPTION
                  WHEN OTHERS THEN
		     x_return_status := FND_API.G_RET_STS_ERROR;
		     ROLLBACK TO IMPORT_MAIN;
                     arp_standard.debug ('EXCEPTION WHEN OTHERS impremapi.Existing_Remittance');
                     app_exception.raise_exception;

END;

/*---------------------------------------------------------------------------------------------------------------------------|
| PROCEDURE : New_Remittance                                                                                                 |
|                                                                                                                            |
| DESCRIPTION :
|                                                                                                                            |
| Validate the bank details supplied and ensure the receipt method is valid. Also check that the remittance print and        |
| transmission programs are of the correct type.                                                                             |
|                                                                                                                            |
| Insert the remittance into the databse by calling ARP_BR_REMIT_BATCHES.insert_remit.				             |
|                                                                                                                            |
| If the BR was already selected to a remittance then deselect it from that remittance. Check if the remittance is empty and |
| if it is then cancel it.                                                                                                   |
|                                                                                                                            |
| CALLS TO EXTERNAL PROCEDURES :
|                                                                                                                            |
| ARP_BR_REMIT_BATCHES.insert_remit                                                                                          |
| AR_BILLS_MAINTAIN_PUB.Deselect_BR_Remit                                                                                    |
|                                                                                                                            |
|---------------------------------------------------------------------------------------------------------------------------*/

PROCEDURE new_remittance(
  p_media_reference 		 IN ar_batches.media_reference%TYPE,
  p_remittance_accounting_date   IN ar_batches.gl_date%TYPE,
  p_remittance_Date 		 IN ar_batches.batch_date%TYPE,
  p_internal_reference   	 IN ra_customer_trx.Customer_trx_id%TYPE,
  p_with_recourse_flag		 IN ar_batches.with_recourse_flag%TYPE,
  p_currency_code 		 IN ar_batches.currency_code%TYPE,
  p_remittance_method    	 IN ar_batches.remit_method_code%TYPE,
  p_remittance_bnk_branch_number IN ce_bank_branches_v.branch_number%TYPE,
  p_remittance_bank_number       IN ce_bank_branches_v.bank_number%TYPE,
  p_remittance_bnk_acct_number   IN ce_bank_accounts.bank_account_num%TYPE,
  p_payment_method		 IN ar_receipt_methods.name%TYPE,
  x_batch_name                   OUT NOCOPY ar_batches.name%TYPE,
  x_return_status                IN OUT NOCOPY VARCHAR2
) IS

  l_receipt_class_id      	ar_receipt_methods.receipt_class_id%TYPE;
  l_auto_print_program_id 	ar_receipt_methods.auto_print_program_id%TYPE;
  l_auto_trans_program_id 	ar_receipt_methods.auto_trans_program_id%TYPE;
  l_bank_branch_id              ce_bank_branches_v.branch_party_id%TYPE;
  l_payment_method              ar_batches.receipt_method_id%TYPE;
  l_reserved_value              ar_payment_schedules.reserved_value%TYPE;
  l_batch_id                    ar_batches.batch_id%TYPE := null;
  l_payment_schedule_id         ar_payment_schedules.payment_schedule_id%TYPE;
  l_receipt_method_id           ra_customer_trx.receipt_method_id%TYPE;
  l_remit_bank_acct_use_id     	ce_bank_acct_uses_all.bank_acct_use_id%TYPE;
  l_media_reference             ar_batches.media_reference%TYPE;

  x_batch_id                    ar_batches.batch_id%TYPE;
  x_batch_applied_status        ar_batches.batch_applied_status%TYPE;

  CURSOR branch (p_bank_number NUMBER, p_branch_number NUMBER) IS
    SELECT branch_party_id
    FROM   ce_bank_branches_v cbb
    WHERE  cbb.bank_number = p_bank_number
    AND    cbb.branch_number = p_branch_number;

  CURSOR account (p_branch_id NUMBER,
                  p_bank_account_number NUMBER,
                  p_currency_code VARCHAR2) IS
    SELECT cbau.bank_acct_use_id
    FROM   ce_bank_accounts cba, ce_bank_acct_uses cbau
    WHERE  cba.bank_account_id = cbau.bank_account_id
    AND    cba.bank_branch_id = p_branch_id
    AND    cba.bank_account_num = p_bank_account_number
    AND    cba.currency_code    = p_currency_code
    AND    cba.account_classification = 'INTERNAL';

BEGIN

  arp_standard.debug ('impremapi.New_Remittance ()+');

  check_br_and_batch_status (p_internal_reference,
    l_reserved_value,l_payment_schedule_id,l_media_reference);

/*----------------------------------------------------------------------------
 | Setup data parameters for the create remittance procedure
 ----------------------------------------------------------------------------*/

  BEGIN

    OPEN  branch (p_remittance_bank_number, p_remittance_bnk_branch_number);
    FETCH branch INTO l_bank_branch_id;
    CLOSE branch;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      ROLLBACK TO IMPORT_MAIN;
      arp_standard.debug('EXCEPTION Branch no_data : ' ||
        'impremapi.New_Remittance');
      fnd_message.set_name ( 'AR', 'AR_MUST_ENTER_REMIT_BANK');
      app_exception.raise_exception;
  END;

  BEGIN

    OPEN  account (l_bank_branch_id,
                   p_remittance_bnk_branch_number,
                   p_currency_code);
    FETCH account INTO l_remit_bank_acct_use_id;
    CLOSE account;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      ROLLBACK TO IMPORT_MAIN;
      arp_standard.debug('EXCEPTION Bank acc id no_data : ' ||
        'impremapi.New_Remittance');
      fnd_message.set_name ( 'AR', 'Invalid Remittance Bank Branch');
      app_exception.raise_exception;
   END;

	       BEGIN
			 select   receipt_method_id,
				  nvl(auto_print_program_id,0),
                         	  nvl(auto_trans_program_id,0),
				  receipt_class_id
 			 into     l_receipt_method_id
			         ,l_auto_print_program_id
                               	 ,l_auto_trans_program_id
				 ,l_receipt_class_id
    			 from     ar_receipt_methods
		 	 where    name = p_payment_method;

			 EXCEPTION
                                WHEN NO_DATA_FOUND THEN
				     x_return_status := FND_API.G_RET_STS_ERROR;
				     ROLLBACK TO IMPORT_MAIN;
				     arp_standard.debug('EXCEPTION Receipt Method : impremapi.New_Remittance');
				     fnd_message.set_name('AR','AR_BR_INVALID_REMIT_PROGRAM');
                                     app_exception.raise_exception;

	       END;

 	       BEGIN
              		 select  nvl(auto_print_program_id,0),
                                 nvl(auto_trans_program_id,0)

               		 into     l_auto_print_program_id,
                                  l_auto_trans_program_id

             		 from ar_receipt_methods
               		 where receipt_method_id = l_receipt_method_id;


                         EXCEPTION
                                WHEN NO_DATA_FOUND THEN
				     x_return_status := FND_API.G_RET_STS_ERROR;
				     ROLLBACK TO IMPORT_MAIN;
				     arp_standard.debug('EXCEPTION Receipt Method Progs : impremapi.New_Remittance');
                                     fnd_message.set_name ( 'AR', 'AR_BR_INVALID_RECEIPT_METHOD');
                                     app_exception.raise_exception;
               END;

               l_batch_id := null;

	       arp_standard.debug('Call insert_remit : impremapi.New_Remittance');

               ARP_BR_REMIT_BATCHES.insert_remit(
               p_remittance_date,
               p_remittance_accounting_date,
               p_currency_code,
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
	       p_media_reference,
               l_receipt_method_id,
	       l_remit_bank_acct_use_id,
	       l_receipt_class_id,
	       l_bank_branch_id,
               p_remittance_method,
               p_with_recourse_flag,
	       null, -- p_bank_deposit_number
               l_auto_print_program_id,
               l_auto_trans_program_id,
               x_batch_id,
               x_batch_name,
               x_batch_applied_status);

	       arp_standard.debug ('impremapi.New_Remittance Called Insert_remit');

	       /*---------------------------------------------------------------------------------------
               | Deselect the BR from the batch it is currently assigned to                            |
               ---------------------------------------------------------------------------------------*/

	       IF l_reserved_value is not null THEN
		  arp_standard.debug ('impremapi.New_Remittance : call Deselect_BR_Remit');
                  AR_BILLS_MAINTAIN_PUB.Deselect_BR_Remit(l_payment_schedule_id,x_return_status);
		  arp_standard.debug ('impremapi.New_Remittance : called Deselect_BR_Remit');
                  dummy_remittance(l_reserved_value, x_return_status);
               END IF;

	       /*---------------------------------------------------------------------------------------
               | Assign the BR to the new remittance batch.        		                       |
               ---------------------------------------------------------------------------------------*/
               AR_BILLS_MAINTAIN_PUB.Select_BR_Remit(x_batch_id,l_payment_schedule_id,x_return_status);

	       arp_standard.debug ('impremapi.New_Remittance ()-');

               EXCEPTION
                        WHEN OTHERS THEN
			x_return_status := FND_API.G_RET_STS_ERROR;
			ROLLBACK TO IMPORT_MAIN;
                        arp_standard.debug('EXCEPTION OTHERS: impremapi.New_Remittance');
                        app_exception.raise_exception;
END;

/*---------------------------------------------------------------------------------------------------------------------------|
| FUNCTION  :                                                                                                                |
| Remittance_Exists                                                                                                          |
|                                                                                                                            |
| DESCRIPTION :                                                                                                              |
| Check if the remittance identified by the media reference (p_media_reference) exists					     |
| If it exists check the status of the batch to ensure it is approved.						             |
|															     |
| CALLS TO EXTERNAL PROCEDURES ;											     |
|                                                                                                                            |
|---------------------------------------------------------------------------------------------------------------------------*/
FUNCTION Remittance_Exists (p_media_reference AR_BATCHES.media_reference%TYPE)  return boolean
IS

l_batch_applied_status             AR_BATCHES.batch_applied_status%TYPE;
l_status			   AR_BATCHES.status%TYPE;

BEGIN

	        arp_standard.debug ('impremapi.remittance_Exists()+');

                select  batch_applied_status,
			status
                into
 			l_batch_applied_status,
			l_status
                from ar_batches
                where media_reference = p_media_reference;

		IF   l_batch_applied_status in ('STARTED_CREATION', 'COMPLETED_CREATION')
		AND  l_status in ('OP','NB') THEN
		     return true;
		ELSE
		     return false;
		END IF;

		arp_standard.debug ('impremapi.remittance_Exists()-');

		EXCEPTION
			WHEN NO_DATA_FOUND THEN
			arp_standard.debug ('EXCEPTION NO_DATA  : impremapi.remittance_Exists');
			return false;


                        WHEN OTHERS THEN
                        arp_standard.debug('EXCEPTION OTHERS: impremapi.remittance_Exists');
                        app_exception.raise_exception;

END;

/*---------------------------------------------------------------------------------------------------------------------------|
| PROCEDURE :														     |
| Import_Remittance_Main											             |
|                                                                                                                            |
| DESCRIPTION :													             |
| Declares global variables.											             |
| a. Carries out NOCOPY standard api functions : check version									     |
|                                         set up error message stack							     |
|      					  Setup Default data								     |
|                                         initiate AR_DEBUG facility						             |
| b. Determines whether the remittance being imported exists already and calls the relevant subprogram			     |
| CALLS TO EXTERNAL PROCEDURES :                                                                                             |
|                                                                                                                            |
|---------------------------------------------------------------------------------------------------------------------------*/

PROCEDURE import_remittance_main (
  p_api_version        		 IN  NUMBER,
  p_init_msg_list    		 IN  VARCHAR2 := FND_API.G_FALSE,
  p_commit           		 IN  VARCHAR2,  -- := FND_API.G_FALSE,
  p_validation_level 		 IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status    		 OUT NOCOPY VARCHAR2,
  x_msg_count        		 OUT NOCOPY NUMBER,
  x_msg_data         		 OUT NOCOPY VARCHAR2,
  p_remittance_bank_number       IN  ce_bank_branches_v.bank_number%TYPE,
  p_remittance_bnk_branch_number IN  ce_bank_branches_v.branch_number%TYPE,
  p_remittance_bnk_acct_number 	 IN  ce_bank_accounts.bank_account_num%TYPE,
  p_media_reference              IN  ar_batches.media_reference%TYPE,
  p_remittance_method            IN  ar_batches.remit_method_code%TYPE,
                                     -- 'STANDARD' , 'FACTORING' etc.
  p_with_recourse_flag		 IN  ar_batches.with_recourse_flag%TYPE,
  p_payment_method               IN  ar_receipt_methods.name%TYPE,
  p_remittance_date              IN  ar_batches.batch_date%TYPE,
  p_remittance_accounting_date   IN  ar_batches.gl_date%TYPE,
  p_currency_code       	 IN  ar_batches.currency_code%TYPE,
  p_internal_reference           IN  ra_customer_trx.Customer_trx_id%TYPE,
  p_org_id                       IN  Number default null,
  p_remittance_name              OUT NOCOPY ar_batches.name%TYPE
) IS

  l_api_name	 CONSTANT VARCHAR2(30)	:=	'IMPREMAPI';
  l_api_version	 CONSTANT NUMBER		:=	1.0;
  l_count        NUMBER(10);
  l_org_return_status VARCHAR2(1);
  l_org_id                           NUMBER;

BEGIN

		arp_standard.debug('Impremapi.Import_Remittance_Main (+)');

                --  Standard start of API savepoint

                SAVEPOINT IMPORT_MAIN;

                --  Standard call to check for call compatibility
	        IF NOT FND_API.Compatible_API_Call(
                                            l_api_version,
                                            p_api_version,
                                            l_api_name,
                                            G_PKG_NAME )
                THEN
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;

                -- Initialize message list if p_init_msg_list is set to TRUE

	        IF  FND_API.to_Boolean( p_init_msg_list )  THEN
 	              FND_MSG_PUB.initialize;
                END IF;


                --  Initialize return status to SUCCESS

                x_return_status := FND_API.G_RET_STS_SUCCESS;



/* SSA change */
       l_org_id            := p_org_id;
       l_org_return_status := FND_API.G_RET_STS_SUCCESS;
       ar_mo_cache_utils.set_org_context_in_api(p_org_id =>l_org_id,
                                                p_return_status =>l_org_return_status);
 IF l_org_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                                        p_count => x_msg_count,
                                        p_data  => x_msg_data);
 ELSE
                --  Start Of API Body


                /*---------------------------------------------------------------------------------------
		|		Check whether the remittance exists					|
                ---------------------------------------------------------------------------------------*/

                IF p_media_reference is null THEN
		   x_return_status := FND_API.G_RET_STS_ERROR;
		   arp_standard.debug('Impremapi.Import_Remittance_Main media_ref null');
                   --bug 1644533
                   fnd_message.set_name('AR_BR','AR_BR_MEDIA_REF_NULL');
                   app_exception.raise_exception;
                end if;

		/*---------------------------------------------------------------------------------------
                | if the remittance does not exist, call the new_remittance procedure else call the     |
                | existing_remittance procedure.							|
		---------------------------------------------------------------------------------------*/

		IF not remittance_exists (p_media_reference) THEN
		   arp_standard.debug('Impremapi.Import_Remittance_Main new remittance');
                   new_remittance (p_media_reference,p_remittance_accounting_date,p_remittance_Date,p_internal_reference,
			     	   p_with_recourse_flag,p_currency_code,p_remittance_method,p_remittance_bnk_branch_number,
                		   p_remittance_bank_number,p_remittance_bnk_acct_number,p_payment_method,p_remittance_name,
				   x_return_status);
                else
		   arp_standard.debug('Impremapi.Import_Remittance_Main existing remittance');
                   existing_remittance (p_media_reference,p_remittance_accounting_Date,p_internal_reference,p_remittance_method,
                                        p_with_recourse_flag,p_payment_method,p_remittance_date,p_Currency_code,
					p_remittance_bnk_acct_number,x_return_status);
                end if;

		/*-----------------------------------------------+
       	        |   Standard check of p_commit   	  	 |
                ------------------------------------------------*/

        	IF FND_API.To_Boolean( p_commit ) THEN                                                                                                  arp_standard.debug('committing');
            	   Commit;
        	END IF;
END IF;

		arp_standard.debug('Impremapi.Import_Remittance_Main (-)');

		EXCEPTION
                  WHEN OTHERS THEN
		       ROLLBACK TO IMPORT_MAIN;
		       arp_standard.debug('EXCEPTION OTHERS: impremapi.Import_Remittance_Main');
                  RAISE;

END;

END AR_BR_REMIT_IMPORT_API_PUB;


/

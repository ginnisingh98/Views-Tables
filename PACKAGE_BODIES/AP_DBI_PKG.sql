--------------------------------------------------------
--  DDL for Package Body AP_DBI_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_DBI_PKG" AS
/* $Header: apdbigeb.pls 120.1.12010000.2 2009/11/23 03:52:39 ssdeshpa ship $ */
--  Public Procedure Specifications

-- Procedure Definitions


PROCEDURE Maintain_DBI_Summary(p_table_name IN VARCHAR2,
				p_operation IN VARCHAR2,
				p_key_value1  IN NUMBER DEFAULT NULL,
				p_key_value2 IN NUMBER DEFAULT NULL,
				p_key_value_list IN
				 ap_dbi_pkg.r_dbi_key_value_arr DEFAULT NULL,
				p_calling_sequence in VARCHAR2) IS

	l_curr_calling_sequence varchar2(2000);
  	l_debug_info            varchar2(100);

	l_key_value1 	NUMBER DEFAULT NULL;
	l_use_dbi	VARCHAR2(1);
        l_use_exp_dbi       VARCHAR2(1);


BEGIN

      l_curr_calling_sequence := 'Maintain_DBI_Summary ' ||
					p_calling_sequence;


      --Add call to check if DBI is installed
      FND_PROFILE.GET('FII_AP_DBI_IMP' , l_use_dbi );
      FND_PROFILE.GET('FII_AP_DBI_EXP_IMP' , l_use_exp_dbi );

      IF nvl(l_use_dbi,'N') = 'Y' OR nvl(l_use_exp_dbi,'N') = 'Y' THEN


	l_debug_info := 'Checking list';
	IF p_key_value_list is not null THEN
	   l_debug_info := 'element exists';
	   --loop through all invoice distribution ids
	   FOR uniq_values IN 1..p_key_value_list.count LOOP

		IF p_table_name = 'AP_INVOICE_DISTRIBUTIONS' THEN
			--Occasionaly, the invoice_id cannot be determined in
			--the transaction code.
			l_debug_info := 'looping through elements';
			IF p_key_value1 IS NULL then
				SELECT invoice_id
				INTO l_key_value1
				FROM ap_invoice_distributions
				WHERE invoice_distribution_id =
				p_key_value_list(uniq_values);
	        	END IF;

			l_debug_info := 'inserting record from list';
			INSERT INTO AP_DBI_LOG(Table_Name,
                                Operation_Flag,
                                Key_Value1,
                                Key_Value2,
                                Exp_Processed_Flag,
                                PS_Processed_Flag,
				Created_By,
				Creation_Date,
				Last_Updated_By,
				Last_Update_Date,
                                Partition_ID)
                                VALUES
                                (p_table_name,
                                 p_operation,
                                 nvl(p_key_value1,l_key_value1),
                                 p_key_value_list(uniq_values),
                                 'N',
                                 'N',
				-1,
				sysdate,
				-1,
				sysdate,
                                mod(to_number(to_char(trunc(sysdate), 'J')), 32)
                                );
		ELSIF p_table_name = 'AP_INVOICES'
			OR p_table_name = 'AP_HOLDS' THEN
			l_debug_info := 'inserting record from list';
                        INSERT INTO AP_DBI_LOG(Table_Name,
                                Operation_Flag,
                                Key_Value1,
                                Key_Value2,
                                Exp_Processed_Flag,
                                PS_Processed_Flag,
                                Created_By,
                                Creation_Date,
                                Last_Updated_By,
                                Last_Update_Date,
                                Partition_ID)
                                VALUES
                                (p_table_name,
                                 p_operation,
                                 p_key_value_list(uniq_values),
				 p_key_value2,
                                 'N',
                                 'N',
                                -1,
                                sysdate,
                                -1,
                                sysdate,
                                mod(to_number(to_char(trunc(sysdate), 'J')), 32)
                                );
		ELSIF p_table_name = 'AP_PAYMENT_SCHEDULES' THEN

			IF p_key_value1 IS NULL THEN
			/*Have a list of invoices whose payment_nums change*/
				INSERT INTO AP_DBI_LOG(Table_Name,
                                Operation_Flag,
                                Key_Value1,
                                Key_Value2,
                                Exp_Processed_Flag,
                                PS_Processed_Flag,
                                Created_By,
                                Creation_Date,
                                Last_Updated_By,
                                Last_Update_Date,
                                Partition_ID)
                                SELECT
                                p_table_name,
                                p_operation,
                                p_key_value_list(uniq_values),
                                payment_num,
                                'N',
                                'N',
                                -1,
                                sysdate,
                                -1,
                                sysdate,
                                mod(to_number(to_char(trunc(sysdate), 'J')), 32)
                                FROM AP_PAYMENT_SCHEDULES
                                WHERE invoice_id =p_key_value_list(uniq_values);
			ELSE /*we have a list of payment_nums for one inv_id*/
				INSERT INTO AP_DBI_LOG(Table_Name,
                                Operation_Flag,
                                Key_Value1,
                                Key_Value2,
                                Exp_Processed_Flag,
                                PS_Processed_Flag,
                                Created_By,
                                Creation_Date,
                                Last_Updated_By,
                                Last_Update_Date,
                                Partition_ID)
                                SELECT
                                p_table_name,
                                p_operation,
				p_key_value2,
                                p_key_value_list(uniq_values),
                                'N',
                                'N',
                                -1,
                                sysdate,
                                -1,
                                sysdate,
                                mod(to_number(to_char(trunc(sysdate), 'J')), 32)
                                FROM AP_PAYMENT_SCHEDULES
                                WHERE invoice_id =p_key_value_list(uniq_values);
			END IF;

	 	End IF;
            END LOOP;

	--payment num was not available in the transaction code
	--but all the payment_nums associated with the invoice were affected*/
	ELSIF p_table_name = 'AP_PAYMENT_SCHEDULES' and
                                        p_key_value2 is null THEN


		INSERT INTO AP_DBI_LOG(Table_Name,
                                Operation_Flag,
                                Key_Value1,
                                Key_Value2,
                                Exp_Processed_Flag,
                                PS_Processed_Flag,
                                Created_By,
                                Creation_Date,
                                Last_Updated_By,
                                Last_Update_Date,
                                Partition_ID)
		        	SELECT
				p_table_name,
				p_operation,
				p_key_value1,
				payment_num,
				'N',
				'N',
                                -1,
                                sysdate,
                                -1,
                                sysdate,
                                mod(to_number(to_char(trunc(sysdate), 'J')), 32)
				FROM AP_PAYMENT_SCHEDULES
				WHERE invoice_id = p_key_value1;

	ELSE -- no values in list for all other situations

		IF p_key_value1 IS NULL then
			IF p_table_name ='AP_INVOICE_DISTRIBUTIONS' THEN
                                SELECT invoice_id
                                INTO l_key_value1
                                FROM ap_invoice_distributions
                                WHERE invoice_distribution_id =
                                p_key_value2;
			END IF;
                END IF;

		l_debug_info := 'inserting normal record';
		INSERT INTO AP_DBI_LOG(Table_Name,
				Operation_Flag,
				Key_Value1,
				Key_Value2,
				Exp_Processed_Flag,
				PS_Processed_Flag,
                                Created_By,
                                Creation_Date,
                                Last_Updated_By,
                                Last_Update_Date,
                                Partition_ID)
				VALUES
                                (p_table_name,
                                 p_operation,
                                 nvl(p_key_value1,l_key_value1),
			     	 p_key_value2,
                                 'N',
                                 'N',
                                -1,
                                sysdate,
                                -1,
                                sysdate,
                                mod(to_number(to_char(trunc(sysdate), 'J')), 32)
				);

	END IF;
      END IF; --using DBI

EXCEPTION
  WHEN OTHERS THEN
     IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP', 'AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR', 'SQLERRM');
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_curr_calling_sequence);
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
      FND_MESSAGE.SET_TOKEN('PARAMETERS',
                            'Table_Name = '||p_table_name
                        ||', Operation = '||p_operation
                        ||', Key_Value1 = '||to_char(p_key_value1));
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;


END Maintain_DBI_Summary;

/*===========================================================================
 |  PUBLIC PROCEDURE Insert_Payment_Confirm_DBI
 |
 |  DESCRIPTION:
 |                This is a special procedure for inserting invoice related
 |                data during the payment confirmation c program.
 |
 |                This procedure will call the Maintain_DBI_Summary with the
 |                information required.
 |
 |  PARAMETERS
 |   p_checkrun_name      IN     Name of the checkrun for the payment batch
 |   p_base_currency_code IN     Base currency code for the payment batch
 |   p_key_table          IN     Name of the table
 |   p_calling_sequence   IN
 |   p_debug_mode         IN
 |
 |  KNOWN ISSUES:
 |
 |  NOTES:
 |
 |  MODIFICATION HISTORY
 |  Date         Author             Description of Change
 |  04/00/03     Amy McGuire        Created -- copied from Biplob Ghose's
 | 				    Insert_Payment_Confirm_MRC.
 |  19-Nov-09    ssdeshpa  Bug#8964576  DBI information is not getting loaded
 |                         for Invoice Payments entity when creating the check
 |                         through the PPR
 *===========================================================================*/

PROCEDURE Insert_Payment_Confirm_DBI(
          p_checkrun_name      IN VARCHAR2,
          p_base_currency_code IN VARCHAR2,
          p_key_table          IN VARCHAR2,
          p_calling_sequence   IN VARCHAR2,
          p_debug_mode         IN VARCHAR2 default 'N') IS

   l_curr_calling_sequence  VARCHAR2(2000);
   l_token_value            VARCHAR2(200);
   l_debug_info            varchar2(100);

   CURSOR  invoice_cur IS
   SELECT  interest.invoice_id
   FROM    ap_selected_invoices interest
   WHERE   interest.original_invoice_id is NOT NULL  --Bug3293887
   AND     interest.checkrun_name = p_checkrun_name;

   CURSOR  invoice_dist_cur IS
   SELECT  aid.invoice_distribution_id, aid.invoice_id
   FROM    ap_selected_invoices interest,
           ap_invoice_distributions aid
   WHERE   interest.original_invoice_id is NOT NULL  --Bug3293887
   AND     interest.checkrun_name = p_checkrun_name
   AND     aid.invoice_id = interest.invoice_id;

   CURSOR  sched_cur IS
   SELECT  aps.invoice_id, aps.payment_num
   FROM    ap_selected_invoices interest,
           ap_payment_schedules aps
   WHERE   interest.original_invoice_id is NOT NULL  --Bug3293887
   AND     interest.checkrun_name = p_checkrun_name
   AND     aps.invoice_id = interest.invoice_id;

   /*Bug#8964576  Fixed the cursor */

   CURSOR  invoice_payments_cur IS
   SELECT  aip.invoice_payment_id
   FROM    ap_invoice_payments aip,
           ap_checks ac
   WHERE   aip.check_id = ac.check_id
   AND     ac.checkrun_name = p_checkrun_name;

   l_invoice_id             number;
   l_invoice_dist_id        number;
   l_check_id               number;
   l_invoice_pay_id         number;
   l_payment_num	    number;

BEGIN


  l_curr_calling_sequence := 'AP_DBI_PKG.Insert_Payment_Confirm_DBI<-'||
                                P_calling_sequence;


  IF (p_key_table = 'AP_INVOICES_ALL') THEN

    OPEN invoice_cur;
    LOOP
    FETCH invoice_cur
    INTO l_invoice_id;
    EXIT WHEN  invoice_cur%NOTFOUND;
    --l_num_fetches_inv := l_num_fetches_inv + 1;

    AP_DBI_PKG.Maintain_DBI_Summary
	(p_table_name => 'AP_INVOICES',
               p_operation => 'I',
               p_key_value1 => l_invoice_id,
                p_calling_sequence => l_curr_calling_sequence);

    END LOOP;
    CLOSE invoice_cur;

    OPEN invoice_dist_cur;
    LOOP
    FETCH invoice_dist_cur
    INTO l_invoice_dist_id,l_invoice_id;
    EXIT WHEN  invoice_dist_cur%NOTFOUND;

    AP_DBI_PKG.Maintain_DBI_Summary
	(p_table_name => 'AP_INVOICE_DISTRIBUTIONS',
               p_operation => 'I',
               p_key_value1 => l_invoice_id,
               p_key_value2 => l_invoice_dist_id,
                p_calling_sequence => l_curr_calling_sequence);
    END LOOP;
    CLOSE invoice_dist_cur;

    OPEN sched_cur;
    LOOP
    FETCH sched_cur
    INTO l_invoice_id, l_payment_num;
    EXIT WHEN  sched_cur%NOTFOUND;

    AP_DBI_PKG.Maintain_DBI_Summary
        (p_table_name => 'AP_PAYMENT_SCHEDULES',
               p_operation => 'I',
               p_key_value1 => l_invoice_id,
	       p_key_value2 => l_payment_num,
                p_calling_sequence => l_curr_calling_sequence);
    END LOOP;
    CLOSE sched_cur;

  ELSIF (p_key_table = 'AP_INVOICE_PAYMENTS_ALL') THEN

    OPEN invoice_payments_cur;
    LOOP
    FETCH invoice_payments_cur
    INTO l_invoice_pay_id;
    EXIT WHEN  invoice_payments_cur%NOTFOUND;

    AP_DBI_PKG.Maintain_DBI_Summary
	(p_table_name => 'AP_INVOICE_PAYMENTS',
               p_operation => 'I',
               p_key_value1 => l_invoice_pay_id,
                p_calling_sequence => l_curr_calling_sequence);
    END LOOP;
    CLOSE invoice_payments_cur;

  END IF;

  NULL;

  EXCEPTION
  WHEN OTHERS THEN
     IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP', 'AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR', 'SQLERRM');
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_curr_calling_sequence);
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;


END Insert_Payment_Confirm_DBI;

END AP_DBI_PKG;

/

--------------------------------------------------------
--  DDL for Package Body AP_CREATE_PAY_SCHEDS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_CREATE_PAY_SCHEDS_PKG" AS
/* $Header: apschedb.pls 120.17.12010000.8 2010/04/22 09:11:15 mkmeda ship $ */
G_PKG_NAME          CONSTANT VARCHAR2(30) := 'AP_CREATE_PAY_SCHEDS_PKG';
G_MSG_UERROR        CONSTANT NUMBER       := FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR;
G_MSG_ERROR         CONSTANT NUMBER       := FND_MSG_PUB.G_MSG_LVL_ERROR;
G_MSG_SUCCESS       CONSTANT NUMBER       := FND_MSG_PUB.G_MSG_LVL_SUCCESS;
G_MSG_HIGH          CONSTANT NUMBER       := FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH;
G_MSG_MEDIUM        CONSTANT NUMBER       := FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM;
G_MSG_LOW           CONSTANT NUMBER       := FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW;
G_LINES_PER_FETCH   CONSTANT NUMBER       := 1000;

G_CURRENT_RUNTIME_LEVEL CONSTANT NUMBER       := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
G_LEVEL_UNEXPECTED      CONSTANT NUMBER       := FND_LOG.LEVEL_UNEXPECTED;
G_LEVEL_ERROR           CONSTANT NUMBER       := FND_LOG.LEVEL_ERROR;
G_LEVEL_EXCEPTION       CONSTANT NUMBER       := FND_LOG.LEVEL_EXCEPTION;
G_LEVEL_EVENT           CONSTANT NUMBER       := FND_LOG.LEVEL_EVENT;
G_LEVEL_PROCEDURE       CONSTANT NUMBER       := FND_LOG.LEVEL_PROCEDURE;
G_LEVEL_STATEMENT       CONSTANT NUMBER       := FND_LOG.LEVEL_STATEMENT;
G_MODULE_NAME           CONSTANT VARCHAR2(100) := 'AP.PLSQL.AP_CREATE_PAY_SCHEDS_PKG.';

Function Calc_Due_Date(
          p_terms_date       IN     DATE,
          p_terms_id         IN     NUMBER,
          p_calendar         IN     VARCHAR2,
          p_sequence_num     IN     NUMBER,
          p_calling_sequence IN     VARCHAR2) RETURN DATE
IS
  l_due_date   DATE;
  l_curr_calling_sequence  VARCHAR2(2000);
  l_api_name varchar(50);
  l_debug_info varchar2(2000);
BEGIN

  l_api_name := 'Calc_Due_Date';

  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,
                      'AP_CREATE_PAY_SCHEDS_PKG.Calc_Due_Date(+)');
  END IF;

  l_debug_info := 'Check if p_calendar is nulli p_calendar is '||p_calendar;
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
  END IF;


  IF (p_calendar IS NOT NULL) THEN
    BEGIN
      -- bug2639133 added truncate function
      l_debug_info := 'Get due_date from ap_other_periods';
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
      END IF;

      SELECT   due_date
        INTO   l_due_date
        FROM   ap_other_periods aop
       WHERE   aop.period_type = p_calendar
         AND   aop.module = 'PAYMENT TERMS'
         AND TRUNC(P_Terms_Date) BETWEEN start_date AND end_date;
       EXCEPTION
         WHEN NO_DATA_FOUND THEN

          -- Probably the calendar has not been defined?
          -- In this case we set the due date to be the same as terms date

          -- bug2639133 added truncate function
          l_due_date := TRUNC(P_Terms_Date);

          l_debug_info := 'in the exception handler l_due_date is '||l_due_date;
	  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
          END IF;

    END;

  ELSE
    l_debug_info := 'There is no calendar associated with the term line';
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF;

    -- bug2682782 deleted needless least function
    SELECT NVL(fixed_date,
           (DECODE(ap_terms_lines.due_days,
                   NULL,TO_DATE(TO_CHAR(LEAST(NVL(ap_terms_lines.due_day_of_month,32),
                                              TO_NUMBER(TO_CHAR(LAST_DAY(ADD_MONTHS(P_Terms_Date,
                                                                          NVL(ap_terms_lines.due_months_forward,0) +
                                                                          DECODE(ap_terms.due_cutoff_day, NULL, 0,
                                                                                 DECODE(GREATEST(NVL(ap_terms.due_cutoff_day, 32),
                                                                                        TO_NUMBER(TO_CHAR(P_Terms_Date, 'DD'))),
                                                                                        TO_NUMBER(TO_CHAR(P_Terms_Date, 'DD'))
                                                                                 , 1, 0)))), 'DD')))) || '-' ||
  					             TO_CHAR(ADD_MONTHS(P_Terms_Date,
                 NVL(ap_terms_lines.due_months_forward,0) +
                   DECODE(ap_terms.due_cutoff_day, NULL, 0,
               DECODE(GREATEST(NVL(ap_terms.due_cutoff_day, 32),
                 TO_NUMBER(TO_CHAR(P_Terms_Date, 'DD'))),
                 TO_NUMBER(TO_CHAR(P_Terms_Date, 'DD')), 1, 0))),
          'MON-RR'),'DD-MON-RR'),  /*bugfix:5647464 */
          trunc(P_Terms_Date) /*bug 8522014*/ + NVL(ap_terms_lines.due_days,0))))
      INTO l_due_date
      FROM ap_terms,
           ap_terms_lines
     WHERE ap_terms.term_id = P_Terms_Id
      AND  ap_terms.term_id = ap_terms_lines.term_id
      AND  ap_terms_lines.sequence_num = p_sequence_num;
  END IF;

  l_debug_info := 'In the else part , l_due_date is '||l_due_date;
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
  END IF;

  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,
	                        'AP_CREATE_PAY_SCHEDS_PKG.Calc_Due_Date(-)');
  END IF;


RETURN(l_due_date);

EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', l_curr_calling_sequence);
      FND_MESSAGE.SET_TOKEN('PARAMETERS',
               'Terms id  = '|| to_char(p_terms_id)
         || 'Sequence num = ' || to_char(p_sequence_num));
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;
END Calc_Due_Date;


--Bug 4256225
PROCEDURE Create_Payment_Schedules
          (
           P_Invoice_Id              IN number,
           P_Terms_Id                IN number,
           P_Last_Updated_By         IN number,
           P_Created_By              IN number,
           P_Payment_Priority        IN number,
           P_Batch_Id                IN number,
           P_Terms_Date              IN date,
           P_Invoice_Amount          IN number,
           P_Pay_Curr_Invoice_Amount IN number,
           P_payment_cross_rate      IN number,
           P_Amount_For_Discount     IN number,
           P_Payment_Method          IN varchar2,
           P_Invoice_Currency        IN varchar2,
           P_Payment_currency        IN varchar2,
           P_calling_sequence        IN varchar2
           ) IS

  l_payment_schedule_index BINARY_INTEGER := 0;

  l_payment_cross_rate	   ap_payment_schedules.payment_cross_rate%TYPE;
  l_sequence_num	         ap_terms_lines.sequence_num%TYPE := 0;
  l_sign_due_amount	   ap_terms_lines.due_amount%TYPE;
  l_sign_remaining_amount  ap_terms_lines.due_amount%TYPE;
  l_calendar               ap_terms_lines.calendar%TYPE;
  l_terms_calendar         ap_terms_lines.calendar%TYPE;
  l_due_date               ap_other_periods.due_date%TYPE;
  l_invoice_sign	         NUMBER;
  l_pay_sched_total	   NUMBER := 0;  -- 4537932
  l_inv_curr_sched_total   NUMBER;
  l_remaining_amount	   ap_payment_schedules.amount_remaining%TYPE;
  l_old_remaining_amount   ap_payment_schedules.amount_remaining%TYPE;
  l_ins_gross_amount	   ap_payment_schedules.gross_amount%TYPE;
  l_last_line_flag	   BOOLEAN;
  l_dummy		         VARCHAR2(200);
  current_calling_sequence VARCHAR2(2000);
  debug_info               VARCHAR2(100);
  l_amount_for_discount    ap_invoices.amount_applicable_to_discount%TYPE;
  l_invoice_type           ap_invoices.invoice_type_lookup_code%TYPE;
  l_min_acc_unit_pay_curr  fnd_currencies.minimum_accountable_unit%TYPE;
  l_precision_pay_curr     fnd_currencies.precision%TYPE;
  l_min_acc_unit_inv_curr  fnd_currencies.minimum_accountable_unit%TYPE;
  l_precision_inv_curr     fnd_currencies.precision%TYPE;
  l_dbi_key_value_list     ap_dbi_pkg.r_dbi_key_value_arr;

  l_payment_priority       NUMBER;  -- Added for Payment Request
  l_vendor_site_id         NUMBER;
  l_hold_flag              varchar2(1);

  --Bug 7357218 Quick Pay and Dispute Resolution Project
  --Introduced variables for discount calculation
  l_disc_amt_by_percent    NUMBER;
  l_disc_amt_by_percent_2  NUMBER;
  l_disc_amt_by_percent_3  NUMBER;
  l_discount_amount        NUMBER;
  l_discount_amount_2      NUMBER;
  l_discount_amount_3      NUMBER;
  l_procedure_name CONSTANT VARCHAR2(30) := 'Create_Payment_Schedules';
  l_log_msg FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;



  T_INVOICE_ID                 INVOICE_ID;
  T_PAYMENT_NUM                PAYMENT_NUM;
  T_DUE_DATE                   DUE_DATE;
  T_DISCOUNT_DATE              DISCOUNT_DATE;
  T_SECOND_DISCOUNT_DATE       SECOND_DISCOUNT_DATE;
  T_THIRD_DISCOUNT_DATE        THIRD_DISCOUNT_DATE;
  T_LAST_UPDATE_DATE           LAST_UPDATE_DATE;
  T_LAST_UPDATED_BY            LAST_UPDATED_BY;
  T_LAST_UPDATE_LOGIN          LAST_UPDATE_LOGIN;
  T_CREATION_DATE              CREATION_DATE;
  T_CREATED_BY                 CREATED_BY;
  T_PAYMENT_CROSS_RATE         PAYMENT_CROSS_RATE;
  T_GROSS_AMOUNT               GROSS_AMOUNT;
  T_INV_CURR_GROSS_AMOUNT      INV_CURR_GROSS_AMOUNT;
  T_DISCOUNT_AMOUNT_AVAILABLE  DISCOUNT_AMOUNT_AVAILABLE;
  T_SECOND_DISC_AMT_AVAILABLE  SECOND_DISC_AMT_AVAILABLE;
  T_THIRD_DISC_AMT_AVAILABLE   THIRD_DISC_AMT_AVAILABLE;
  T_AMOUNT_REMAINING           AMOUNT_REMAINING;
  T_DISCOUNT_AMOUNT_REMAINING  DISCOUNT_AMOUNT_REMAINING;
  T_PAYMENT_PRIORITY           PAYMENT_PRIORITY;
  T_HOLD_FLAG                  HOLD_FLAG;
  T_PAYMENT_STATUS_FLAG        PAYMENT_STATUS_FLAG;
  T_BATCH_ID                   BATCH_ID;
  T_EXTERNAL_BANK_ACCOUNT_ID   EXTERNAL_BANK_ACCOUNT_ID;
  T_ORG_ID                     ORG_ID;

--4393358
  T_PAYMENT_METHOD_CODE        PAYMENT_METHOD_CODE;
  T_REMITTANCE_MESSAGE1        REMITTANCE_MESSAGE1;
  T_REMITTANCE_MESSAGE2        REMITTANCE_MESSAGE2;
  T_REMITTANCE_MESSAGE3        REMITTANCE_MESSAGE3;

--Third party Payments
  T_REMIT_TO_SUPPLIER_NAME	REMIT_TO_SUPPLIER_NAME;
  T_REMIT_TO_SUPPLIER_ID		REMIT_TO_SUPPLIER_ID;
  T_REMIT_TO_SUPPLIER_SITE	REMIT_TO_SUPPLIER_SITE;
  T_REMIT_TO_SUPPLIER_SITE_ID	REMIT_TO_SUPPLIER_SITE_ID;
  T_RELATIONSHIP_ID			RELATIONSHIP_ID;
  l_api_name                    varchar(50); --bug 8991699
  l_debug_info                  varchar2(2000); --bug 8991699

  CURSOR c_terms_percent IS
    SELECT 'Terms are percent type'
    FROM   ap_terms_lines
    WHERE  term_id = P_Terms_Id
    AND    sequence_num = 1
    AND    due_percent IS NOT NULL;

  CURSOR c_terms IS
  SELECT calendar, sequence_num
  FROM ap_terms_lines
  WHERE term_id = p_terms_id
   ORDER BY sequence_num;

  CURSOR c_amounts IS
    SELECT SIGN(ABS(P_Invoice_Amount))
    ,      SIGN(due_amount)
    ,      due_amount
    ,      SIGN(ABS(l_remaining_amount) - ABS(due_amount))
    ,      ABS(l_remaining_amount) - ABS(due_amount)
    ,      calendar
    FROM   ap_terms_lines
    WHERE  term_id = P_Terms_Id
    AND    sequence_num = l_sequence_num;
                                                                         --
BEGIN
  -- Update the calling sequence
  --
  current_calling_sequence :=
     'AP_CREATE_PAY_SCHEDS_PKG.Create_Payment_Schedules<-'||P_calling_sequence;

  l_api_name := 'Create_Payment_Schedules'; --bug 8991699

  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,
                      'AP_CREATE_PAY_SCHEDS_PKG.Create_Payment_Schedules<-'||P_calling_sequence);
  END IF; --bug 8991699


  BEGIN
    SELECT fc.minimum_accountable_unit,
           fc.precision
      INTO l_min_acc_unit_pay_curr,
           l_precision_pay_curr
      FROM fnd_currencies fc
     WHERE fc.currency_code = P_Payment_Currency;
  EXCEPTION
     WHEN OTHERS THEN
     NULL;
  END;

  --  Select precision and minimum_accountable_unit before loops
  --  for invoice currency

  BEGIN
    SELECT fc.minimum_accountable_unit,
           fc.precision
      INTO l_min_acc_unit_inv_curr,
           l_precision_inv_curr
      FROM fnd_currencies fc
     WHERE fc.currency_code = P_Invoice_Currency;
  EXCEPTION
     WHEN OTHERS THEN
     NULL;
  END;

  SELECT invoice_type_lookup_code,
         vendor_site_id
  INTO   l_invoice_type,
         l_vendor_site_id
  FROM   ap_invoices
  WHERE  invoice_id = P_Invoice_Id;


  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
  l_log_msg := 'Invoice Type is '|| l_invoice_type;
    FND_LOG.STRING(G_LEVEL_STATEMENT,
                   G_MODULE_NAME||l_procedure_name,
                   l_log_msg);
  END IF;

  -- Payment Request: Added the sql statement for payment request
  IF l_invoice_type <> 'PAYMENT REQUEST' THEN

     SELECT payment_priority
     INTO   l_payment_priority
     FROM   po_vendor_sites
     WHERE  vendor_site_id = l_vendor_site_id;

  END IF;

  l_debug_info := 'Before cursor c_terms_percent: P_Pay_Curr_Invoice_Amount->'||P_Pay_Curr_Invoice_Amount; --bug 8991699
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
  END IF; --bug 8991699

  debug_info := 'Open cursor c_terms_percent';
  OPEN  c_terms_percent;
  debug_info := 'Fetch cursor c_terms_percent';
  FETCH c_terms_percent INTO l_dummy;

  l_payment_cross_rate := P_payment_cross_rate;

  debug_info := 'Convert discount amount to payment currency';
  l_amount_for_discount :=  ap_utilities_pkg.ap_round_currency(
                                 P_Amount_For_Discount * P_Payment_Cross_Rate,
                                 P_Payment_Currency);

  IF c_terms_percent%NOTFOUND THEN
    /* Terms type is Slab */

    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
        l_log_msg := 'Terms type is Slab';
        FND_LOG.STRING(G_LEVEL_STATEMENT,
                   G_MODULE_NAME||l_procedure_name,
                   l_log_msg);
    END IF;
                                                                         --
    l_remaining_amount := P_Pay_Curr_Invoice_Amount;
                                                                         --
    <<slab_loop>>
    LOOP
      l_sequence_num := l_sequence_num + 1;
      l_old_remaining_amount := l_remaining_amount;
                                                                         --
      debug_info := 'Open cursor c_amounts';
      OPEN  c_amounts;
      debug_info := 'Fetch cursor c_amounts';
      FETCH c_amounts INTO l_invoice_sign
                         , l_sign_due_amount
                         , l_ins_gross_amount
                         , l_sign_remaining_amount
                         , l_remaining_amount
                         , l_calendar ;
      debug_info := 'Close cursor c_amounts';
      CLOSE c_amounts;

      IF l_invoice_type in ('CREDIT','DEBIT') THEN
         l_ins_gross_amount := 1 * l_ins_gross_amount;
         l_remaining_amount := -1 * l_remaining_amount;

      END IF;
                                                                         --
      IF (
          (l_sign_remaining_amount <= 0)
          OR
          (l_invoice_sign <= 0)
          OR
          (l_sign_due_amount = 0)
         ) THEN
        l_ins_gross_amount := l_old_remaining_amount;
        l_last_line_flag := TRUE;
      END IF;

                                                                       --
      debug_info := 'Calculate Due Date - terms slab type';
      l_due_date := Calc_Due_Date ( p_terms_date,
                                    p_terms_id,
                                    l_calendar,
                                    l_sequence_num,
                                    p_calling_sequence );

      debug_info := 'Insert into ap_payment_schedules';
      l_payment_schedule_index := l_payment_schedule_index + 1;

--Bug 7357218 Quick Pay and Dispute Resolution Project
  debug_info := 'Calculating discount amounts by percent for slab type BEGIN';
  SELECT DECODE(l_min_acc_unit_pay_curr,
  	  NULL, ROUND( l_ins_gross_amount *
             DECODE(P_Pay_Curr_Invoice_Amount, 0, 0, (l_amount_for_discount/
                   DECODE(P_Pay_Curr_Invoice_Amount, 0, 1,
                           P_Pay_Curr_Invoice_Amount))) *
              NVL(ap_terms_lines.discount_percent,0)/100 ,l_precision_pay_curr),
        	  ROUND(( l_ins_gross_amount *
            DECODE(P_Pay_Curr_Invoice_Amount, 0, 0,
                   (l_amount_for_discount/
                    DECODE(P_Pay_Curr_Invoice_Amount, 0, 1,
                           P_Pay_Curr_Invoice_Amount))) *
            NVL(ap_terms_lines.discount_percent,0)/100)
            / l_min_acc_unit_pay_curr) * l_min_acc_unit_pay_curr)
        ,	DECODE(l_min_acc_unit_pay_curr,
  	  NULL, ROUND( l_ins_gross_amount *
              DECODE(P_Pay_Curr_Invoice_Amount, 0, 0,
                   (l_amount_for_discount/
                    DECODE(P_Pay_Curr_Invoice_Amount, 0, 1,
                           P_Pay_Curr_Invoice_Amount))) *
              NVL(ap_terms_lines.discount_percent_2,0)/100 ,l_precision_pay_curr),
        	    ROUND(( l_ins_gross_amount *
              DECODE(P_Pay_Curr_Invoice_Amount, 0, 0,
                   (l_amount_for_discount/
                    DECODE(P_Pay_Curr_Invoice_Amount, 0, 1,
                           P_Pay_Curr_Invoice_Amount))) *
              NVL(ap_terms_lines.discount_percent_2,0)/100)
              / l_min_acc_unit_pay_curr) * l_min_acc_unit_pay_curr)
        ,	DECODE(l_min_acc_unit_pay_curr,
  	  NULL, ROUND( l_ins_gross_amount *
              DECODE(P_Pay_Curr_Invoice_Amount, 0, 0,
                   (l_amount_for_discount/
                    DECODE(P_Pay_Curr_Invoice_Amount, 0, 1,
                           P_Pay_Curr_Invoice_Amount))) *
              NVL(ap_terms_lines.discount_percent_3,0)/100 ,l_precision_pay_curr),
              ROUND(( l_ins_gross_amount *
              DECODE(P_Pay_Curr_Invoice_Amount, 0, 0,
                   (l_amount_for_discount/
                    DECODE(P_Pay_Curr_Invoice_Amount, 0, 1,
                           P_Pay_Curr_Invoice_Amount))) *
              NVL(ap_terms_lines.discount_percent_3,0)/100)
              / l_min_acc_unit_pay_curr) * l_min_acc_unit_pay_curr),
              discount_amount,
              discount_amount_2,
              discount_amount_3
  INTO
           l_disc_amt_by_percent, l_disc_amt_by_percent_2, l_disc_amt_by_percent_3,
           l_discount_amount, l_discount_amount_2, l_discount_amount_3

  FROM 	ap_terms
        ,	ap_terms_lines
        , ap_invoices ai
  WHERE ap_terms.term_id = ap_terms_lines.term_id
        AND ap_terms_lines.term_id = P_Terms_Id
        AND ap_terms_lines.sequence_num = l_sequence_num
        AND ai.Invoice_Id = P_Invoice_Id;

  --Bug 7357218 Quick Pay and Dispute Resolution Project
  --Calculating discount amounts by percent for slab type END


  --Bug 7357218 Quick Pay and Dispute Resolution Project
   debug_info := 'Making discount amount negative for credit/debit memos';
   IF l_invoice_type in ('CREDIT','DEBIT') THEN
        l_discount_amount   := -1 * l_discount_amount;
        l_discount_amount_2 := -1 * l_discount_amount_2;
        l_discount_amount_3 := -1 * l_discount_amount_3;
   END IF;


   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
      l_log_msg := 'Sequence:'|| l_sequence_num ||
                 ' Disc1 by percent:' || l_disc_amt_by_percent ||
                 ' Disc2 by percent:' || l_disc_amt_by_percent_2 ||
                 ' Disc3 by percent:' || l_disc_amt_by_percent_3 ||
                 ' Disc1 by amount:' || l_discount_amount ||
                 ' Disc2 by amount:' || l_discount_amount_2 ||
                 ' Disc3 by amount:' || l_discount_amount_3;
    FND_LOG.STRING(G_LEVEL_STATEMENT,
                   G_MODULE_NAME||l_procedure_name,
                   l_log_msg);
  END IF;

  SELECT P_Invoice_Id,
             l_sequence_num
             ,	l_due_date
      ,  DECODE(ap_terms_lines.discount_days,
	        NULL,
		DECODE(ap_terms_lines.discount_day_of_month, NULL, NULL,
      	        TO_DATE(TO_CHAR(LEAST(NVL(ap_terms_lines.discount_day_of_month,32),
      	        TO_NUMBER(TO_CHAR(LAST_DAY(ADD_MONTHS
      	        (P_Terms_Date, NVL(ap_terms_lines.discount_months_forward,0) +
      	         DECODE(ap_terms.due_cutoff_day, NULL, 0,
      	          DECODE(GREATEST(LEAST(NVL(ap_terms.due_cutoff_day, 32),
       	          TO_NUMBER(TO_CHAR(LAST_DAY(P_Terms_Date), 'DD'))),
       	          TO_NUMBER(TO_CHAR(P_Terms_Date, 'DD'))),
       	          TO_NUMBER(TO_CHAR(P_Terms_Date, 'DD'))
       	          , 1, 0)))), 'DD')))) || '-' ||
       	          TO_CHAR(ADD_MONTHS(P_Terms_Date,
       	          NVL(ap_terms_lines.discount_months_forward,0) +
      	          DECODE(ap_terms.due_cutoff_day, NULL, 0,
      	          DECODE(GREATEST(LEAST(NVL(ap_terms.due_cutoff_day, 32),
       	          TO_NUMBER(TO_CHAR(LAST_DAY(P_Terms_Date),'DD'))),
       	          TO_NUMBER(TO_CHAR(P_Terms_Date, 'DD'))),
       	          TO_NUMBER(TO_CHAR(P_Terms_Date, 'DD')), 1, 0))),
		'MON-RR'),'DD-MON-RR')
		      ),
      	      P_Terms_Date + NVL(ap_terms_lines.discount_days,0)
	      )
      ,	DECODE(ap_terms_lines.discount_days_2,
                 NULL,DECODE(ap_terms_lines.discount_day_of_month_2,NULL,NULL,
      	    TO_DATE(TO_CHAR(LEAST
		(NVL(ap_terms_lines.discount_day_of_month_2,32),
      	    TO_NUMBER(TO_CHAR(LAST_DAY(ADD_MONTHS(P_Terms_Date,
      	    NVL(ap_terms_lines.discount_months_forward_2,0) +
      	    DECODE(ap_terms.due_cutoff_day, NULL, 0,
      	    DECODE(GREATEST(LEAST(NVL(ap_terms.due_cutoff_day, 32),
       	      TO_NUMBER(TO_CHAR(LAST_DAY(P_Terms_Date), 'DD'))),
       	      TO_NUMBER(TO_CHAR(P_Terms_Date, 'DD'))),
       	      TO_NUMBER(TO_CHAR(P_Terms_Date, 'DD'))
       	      , 1, 0)))), 'DD')))) || '-' ||
       	    TO_CHAR(ADD_MONTHS(P_Terms_Date,
       	    NVL(ap_terms_lines.discount_months_forward_2,0) +
      	    DECODE(ap_terms.due_cutoff_day, NULL, 0,
      	    DECODE(GREATEST(LEAST(NVL(ap_terms.due_cutoff_day, 32),
              TO_NUMBER(TO_CHAR(LAST_DAY(P_Terms_Date),'DD'))),
       	      TO_NUMBER(TO_CHAR(P_Terms_Date, 'DD'))),
       	      TO_NUMBER(TO_CHAR(P_Terms_Date, 'DD')), 1, 0))),
		'MON-RR'),'DD-MON-RR')), /*bugfix:5647464 */
       	      P_Terms_Date + NVL(ap_terms_lines.discount_days_2,0))
      ,	DECODE(ap_terms_lines.discount_days_3,
	  NULL, DECODE(ap_terms_lines.discount_day_of_month_3, NULL,
		NULL,
      	    TO_DATE(TO_CHAR(LEAST
		(NVL(ap_terms_lines.discount_day_of_month_3,32),
      	    TO_NUMBER(TO_CHAR(LAST_DAY(ADD_MONTHS(P_Terms_Date,
       	    NVL(ap_terms_lines.discount_months_forward_3,0) +
      	    DECODE(ap_terms.due_cutoff_day, NULL, 0,
      	    DECODE(GREATEST(LEAST(NVL(ap_terms.due_cutoff_day, 32),
       	      TO_NUMBER(TO_CHAR(LAST_DAY(P_Terms_Date), 'DD'))),
       	      TO_NUMBER(TO_CHAR(P_Terms_Date, 'DD'))),
       	      TO_NUMBER(TO_CHAR(P_Terms_Date, 'DD'))
       		, 1, 0)))), 'DD')))) || '-' ||
       	    TO_CHAR(ADD_MONTHS(P_Terms_Date,
       	    NVL(ap_terms_lines.discount_months_forward_3,0) +
      	    DECODE(ap_terms.due_cutoff_day, NULL, 0,
      	    DECODE(GREATEST(LEAST(NVL(ap_terms.due_cutoff_day, 32),
       	      TO_NUMBER(TO_CHAR(LAST_DAY(P_Terms_Date),'DD'))),
       	      TO_NUMBER(TO_CHAR(P_Terms_Date, 'DD'))),
       	      TO_NUMBER(TO_CHAR(P_Terms_Date, 'DD')), 1, 0))),
		'MON-RR'),'DD-M0N-RR')),
      	      P_Terms_Date + NVL(ap_terms_lines.discount_days_3,0))
      ,	SYSDATE
      ,	P_Last_Updated_By
      ,	NULL
      ,	SYSDATE
      ,	P_Created_By
      ,	l_payment_cross_rate
      ,	DECODE(l_min_acc_unit_pay_curr,
	  NULL, ROUND(l_ins_gross_amount,
		l_precision_pay_curr),
      	  ROUND(l_ins_gross_amount
		/l_min_acc_unit_pay_curr)
       	    * l_min_acc_unit_pay_curr)
      ,NULL,

    --Bug 7357218 Quick Pay and Dispute Resolution Project
    --Considering absolute amount and criteria for all three discounts

    CASE
        WHEN discount_criteria IS NULL OR discount_criteria = 'H' THEN
              CASE WHEN abs(nvl(l_discount_amount,0)) > abs(l_disc_amt_by_percent) THEN
                        l_discount_amount
                   ELSE l_disc_amt_by_percent
              END
        ELSE  CASE WHEN abs(nvl(l_discount_amount,0)) < abs(l_disc_amt_by_percent) THEN
                        l_discount_amount
                   ELSE l_disc_amt_by_percent
              END
    END,
    CASE
        WHEN discount_criteria_2 IS NULL OR discount_criteria_2 = 'H' THEN
              CASE WHEN abs(nvl(l_discount_amount_2,0)) > abs(l_disc_amt_by_percent_2) THEN
                        l_discount_amount_2
                   ELSE l_disc_amt_by_percent_2
              END
        ELSE  CASE WHEN abs(nvl(l_discount_amount_2,0)) < abs(l_disc_amt_by_percent_2) THEN
                        l_discount_amount_2
                   ELSE l_disc_amt_by_percent_2
              END
    END,
    CASE
        WHEN discount_criteria_3 IS NULL OR discount_criteria_3 = 'H' THEN
              CASE WHEN abs(nvl(l_discount_amount_3,0)) > abs(l_disc_amt_by_percent_3) THEN
                        l_discount_amount_3
                   ELSE l_disc_amt_by_percent_3
              END
        ELSE  CASE WHEN abs(nvl(l_discount_amount_3,0)) < abs(l_disc_amt_by_percent_3) THEN
                        l_discount_amount_3
                   ELSE l_disc_amt_by_percent_3
              END
    END,

    DECODE(l_min_acc_unit_pay_curr,
	  NULL, ROUND(l_ins_gross_amount,
		l_precision_pay_curr),
      	    ROUND(l_ins_gross_amount
		/l_min_acc_unit_pay_curr)
                * l_min_acc_unit_pay_curr)
      ,	0
      ,	'N'
      ,	'N'
      ,	P_Batch_Id
      ,	NVL(P_Payment_Method, 'CHECK')
      , ai.external_bank_account_id  --4393358
      ,ai.org_id
      ,ai.remittance_message1
      ,ai.remittance_message2
      ,ai.remittance_message3
      --third party payments
      ,ai.remit_to_supplier_name
      ,ai.remit_to_supplier_id
      ,ai.remit_to_supplier_site
      ,ai.remit_to_supplier_site_id
      ,ai.relationship_id
      INTO
      T_INVOICE_ID(l_payment_schedule_index),
      T_PAYMENT_NUM(l_payment_schedule_index),
      T_DUE_DATE(l_payment_schedule_index),
      T_DISCOUNT_DATE(l_payment_schedule_index),
      T_SECOND_DISCOUNT_DATE(l_payment_schedule_index),
      T_THIRD_DISCOUNT_DATE(l_payment_schedule_index),
      T_LAST_UPDATE_DATE(l_payment_schedule_index),
      T_LAST_UPDATED_BY(l_payment_schedule_index),
      T_LAST_UPDATE_LOGIN(l_payment_schedule_index),
      T_CREATION_DATE(l_payment_schedule_index),
      T_CREATED_BY(l_payment_schedule_index),
      T_PAYMENT_CROSS_RATE(l_payment_schedule_index),
      T_GROSS_AMOUNT(l_payment_schedule_index),
      T_INV_CURR_GROSS_AMOUNT(l_payment_schedule_index),
      T_DISCOUNT_AMOUNT_AVAILABLE(l_payment_schedule_index),
      T_SECOND_DISC_AMT_AVAILABLE(l_payment_schedule_index),
      T_THIRD_DISC_AMT_AVAILABLE(l_payment_schedule_index),
      T_AMOUNT_REMAINING(l_payment_schedule_index),
      T_DISCOUNT_AMOUNT_REMAINING(l_payment_schedule_index),
      T_HOLD_FLAG(l_payment_schedule_index),
      T_PAYMENT_STATUS_FLAG(l_payment_schedule_index),
      T_BATCH_ID(l_payment_schedule_index),
      T_PAYMENT_METHOD_CODE(l_payment_schedule_index),
      T_EXTERNAL_BANK_ACCOUNT_ID(l_payment_schedule_index),
      T_ORG_ID(l_payment_schedule_index),
      T_REMITTANCE_MESSAGE1(l_payment_schedule_index),
      T_REMITTANCE_MESSAGE2(l_payment_schedule_index),
      T_REMITTANCE_MESSAGE3(l_payment_schedule_index),
      --Third Party Payments
      T_REMIT_TO_SUPPLIER_NAME(l_payment_schedule_index),
      T_REMIT_TO_SUPPLIER_ID(l_payment_schedule_index),
      T_REMIT_TO_SUPPLIER_SITE(l_payment_schedule_index),
      T_REMIT_TO_SUPPLIER_SITE_ID(l_payment_schedule_index),
      T_RELATIONSHIP_ID(l_payment_schedule_index)
      FROM 	ap_terms
      , 	ap_terms_lines
      ,     ap_invoices ai
      WHERE ap_terms.term_id = ap_terms_lines.term_id
      AND 	ap_terms_lines.term_id = P_Terms_Id
      AND 	ap_terms_lines.sequence_num = l_sequence_num
      AND   ai.Invoice_Id = P_Invoice_Id;

                                                                         --
      l_pay_sched_total := l_pay_sched_total +
           t_gross_amount(l_payment_schedule_index);

      l_debug_info := 'l_pay_sched_total->'||l_pay_sched_total; --bug 8991699
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
      END IF; --bug 8991699

      IF l_min_acc_unit_inv_curr IS NULL THEN

         t_inv_curr_gross_amount(l_payment_schedule_index) :=
         ROUND(
            t_gross_amount(l_payment_schedule_index)/
            P_Payment_Cross_Rate,
            l_precision_inv_curr
         );
      ELSE
         t_inv_curr_gross_amount(l_payment_schedule_index):=
         (ROUND(
            t_gross_amount(l_payment_schedule_index)/
            P_Payment_Cross_Rate/
            l_min_acc_unit_inv_curr)
            * l_min_acc_unit_inv_curr
         );
      END IF;

      l_debug_info := 't_inv_curr_gross_amount(l_payment_schedule_index)->'||t_inv_curr_gross_amount(l_payment_schedule_index); --bug 8991699
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
      END IF; --bug 8991699

      t_payment_priority(l_payment_schedule_index)
             := nvl(P_Payment_Priority,l_payment_priority);

      l_inv_curr_sched_total := l_inv_curr_sched_total +
          t_inv_curr_gross_amount(l_payment_schedule_index);

      IF t_discount_date(l_payment_schedule_index) IS NULL THEN
         t_discount_amount_available(l_payment_schedule_index) := NULL;
      END IF;

      IF t_second_discount_date(l_payment_schedule_index) IS NULL THEN
         t_second_disc_amt_available(l_payment_schedule_index) := NULL;
      END IF;

      IF t_third_discount_date(l_payment_schedule_index) IS NULL THEN
         t_third_disc_amt_available(l_payment_schedule_index) := NULL;
      END IF;

      IF (l_last_line_flag = TRUE) THEN
        EXIT;
      END IF;

      l_debug_info := 'l_inv_curr_sched_total->'||l_inv_curr_sched_total; --bug 8991699
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
      END IF; --bug 8991699

    END LOOP slab_loop;
                                                                         --
  ELSE
--    /* Terms type is Percent */

    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
        l_log_msg := 'Terms type is Percent';
    FND_LOG.STRING(G_LEVEL_STATEMENT,
                   G_MODULE_NAME||l_procedure_name,
                   l_log_msg);
    END IF;


    OPEN c_terms;

    LOOP
      FETCH c_terms INTO l_terms_calendar, l_sequence_num;
      EXIT WHEN c_terms%NOTFOUND;

      l_debug_info := 'Calculate Due Date - terms type is percent'; --bug 8991699
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
      END IF; --bug 8991699

      l_due_date := Calc_Due_Date ( p_terms_date,
                                    p_terms_id,
                                    l_terms_calendar,
                                    l_sequence_num,
                                    p_calling_sequence);


    debug_info := 'Insert into ap_payment_schedules : term type is percent';
    l_payment_schedule_index := l_payment_schedule_index + 1;

--Bug 7357218 Quick Pay and Dispute Resolution Project
    debug_info := 'Calculating discount amounts by percent for Percent type BEGIN';
    SELECT DECODE(l_min_acc_unit_pay_curr,NULL,
    	  ROUND( l_amount_for_discount *
            NVL(ap_terms_lines.discount_percent,0)/100 *
            NVL(ap_terms_lines.due_percent, 0)/100, l_precision_pay_curr),
            ROUND(( l_amount_for_discount *
            NVL(ap_terms_lines.discount_percent,0)/100 *
            NVL(ap_terms_lines.due_percent, 0)/100)
              / l_min_acc_unit_pay_curr)
	    * l_min_acc_unit_pay_curr)
    , DECODE(l_min_acc_unit_pay_curr,NULL,
    	  ROUND( l_amount_for_discount *
            NVL(ap_terms_lines.discount_percent_2,0)/100 *
            NVL(ap_terms_lines.due_percent, 0)/100, l_precision_pay_curr),
    	  ROUND(( l_amount_for_discount *
            NVL(ap_terms_lines.discount_percent_2,0)/100 *
            NVL(ap_terms_lines.due_percent, 0)/100)
              / l_min_acc_unit_pay_curr)*l_min_acc_unit_pay_curr)
    , DECODE(l_min_acc_unit_pay_curr,NULL,
    	  ROUND( l_amount_for_discount *
            NVL(ap_terms_lines.discount_percent_3,0)/100 *
            NVL(ap_terms_lines.due_percent, 0)/100, l_precision_pay_curr),
    	  ROUND(( l_amount_for_discount *
            NVL(ap_terms_lines.discount_percent_3,0)/100 *
            NVL(ap_terms_lines.due_percent, 0)/100)
              / l_min_acc_unit_pay_curr)*l_min_acc_unit_pay_curr),
              discount_amount,
              discount_amount_2,
              discount_amount_3
  INTO
           l_disc_amt_by_percent, l_disc_amt_by_percent_2, l_disc_amt_by_percent_3,
           l_discount_amount, l_discount_amount_2, l_discount_amount_3

    FROM 	ap_terms,
      	  ap_terms_lines,
          ap_invoices ai
    WHERE ap_terms.term_id = ap_terms_lines.term_id
    AND 	ap_terms_lines.term_id = P_Terms_Id
    AND   ap_terms_lines.sequence_num = l_sequence_num
    AND   ai.invoice_id = P_Invoice_Id;

  --Bug 7357218 Quick Pay and Dispute Resolution Project
  --Calculating discount amounts by percent for Percent type END

  --Bug 7357218 Quick Pay and Dispute Resolution Project
    debug_info := 'Making discount amount negative for credit/debit memos';
    IF l_invoice_type in ('CREDIT','DEBIT') THEN
        l_discount_amount   := -1 * l_discount_amount;
        l_discount_amount_2 := -1 * l_discount_amount_2;
        l_discount_amount_3 := -1 * l_discount_amount_3;
    END IF;


    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
        l_log_msg := 'Sequence:'|| l_sequence_num ||
                 ' Disc1 by percent:' || l_disc_amt_by_percent ||
                 ' Disc2 by percent:' || l_disc_amt_by_percent_2 ||
                 ' Disc3 by percent:' || l_disc_amt_by_percent_3 ||
                 ' Disc1 by amount:' || l_discount_amount ||
                 ' Disc2 by amount:' || l_discount_amount_2 ||
                 ' Disc3 by amount:' || l_discount_amount_3;
    FND_LOG.STRING(G_LEVEL_STATEMENT,
                   G_MODULE_NAME||l_procedure_name,
                   l_log_msg);
    END IF;

    SELECT P_Invoice_Id,l_sequence_num
    , l_due_date
    , DECODE(l_amount_for_discount, NULL, NULL,
       DECODE(ap_terms_lines.discount_days,
        NULL, DECODE(ap_terms_lines.discount_day_of_month, NULL, NULL,
          TO_DATE(TO_CHAR(LEAST(NVL(ap_terms_lines.discount_day_of_month,32),
    	    TO_NUMBER(TO_CHAR(LAST_DAY(ADD_MONTHS
    	    (P_Terms_Date,
		NVL(ap_terms_lines.discount_months_forward,0) +
    	    DECODE(ap_terms.due_cutoff_day, NULL, 0,
    	    DECODE(GREATEST(LEAST(NVL(ap_terms.due_cutoff_day, 32),
    	     TO_NUMBER(TO_CHAR(LAST_DAY(P_Terms_Date), 'DD'))),
    	     TO_NUMBER(TO_CHAR(P_Terms_Date, 'DD'))),
    	     TO_NUMBER(TO_CHAR(P_Terms_Date, 'DD'))
    	     , 1, 0)))), 'DD')))) || '-' ||
    	     TO_CHAR(ADD_MONTHS(P_Terms_Date,
    	     NVL(ap_terms_lines.discount_months_forward,0) +
    	    DECODE(ap_terms.due_cutoff_day, NULL, 0,
    	    DECODE(GREATEST(LEAST(NVL(ap_terms.due_cutoff_day, 32),
     	     TO_NUMBER(TO_CHAR(LAST_DAY(P_Terms_Date),'DD'))),
    	     TO_NUMBER(TO_CHAR(P_Terms_Date, 'DD'))),
    	     TO_NUMBER(TO_CHAR(P_Terms_Date, 'DD')), 1, 0))),
		'MON-RR'),'DD-MON-RR')),
    	     P_Terms_Date + NVL(ap_terms_lines.discount_days,0)))
    , DECODE(l_amount_for_discount, NULL, NULL,
       DECODE(ap_terms_lines.discount_days_2,
        NULL,DECODE(ap_terms_lines.discount_day_of_month_2,NULL,NULL,
          TO_DATE(TO_CHAR(LEAST(
		NVL(ap_terms_lines.discount_day_of_month_2,32),
    	    TO_NUMBER(TO_CHAR(LAST_DAY(ADD_MONTHS(P_Terms_Date,
    	    NVL(ap_terms_lines.discount_months_forward_2,0) +
    	    DECODE(ap_terms.due_cutoff_day, NULL, 0,
    	    DECODE(GREATEST(LEAST(NVL(ap_terms.due_cutoff_day, 32),
    	     TO_NUMBER(TO_CHAR(LAST_DAY(P_Terms_Date), 'DD'))),
    	     TO_NUMBER(TO_CHAR(P_Terms_Date, 'DD'))),
    	     TO_NUMBER(TO_CHAR(P_Terms_Date, 'DD'))
    	     , 1, 0)))), 'DD')))) || '-' ||
    	     TO_CHAR(ADD_MONTHS(P_Terms_Date,
    	     NVL(ap_terms_lines.discount_months_forward_2,0) +
    	    DECODE(ap_terms.due_cutoff_day, NULL, 0,
    	    DECODE(GREATEST(LEAST(NVL(ap_terms.due_cutoff_day, 32),
    	     TO_NUMBER(TO_CHAR(LAST_DAY(P_Terms_Date),'DD'))),
    	     TO_NUMBER(TO_CHAR(P_Terms_Date, 'DD'))),
    	     TO_NUMBER(TO_CHAR(P_Terms_Date, 'DD')), 1, 0))),
		'MON-RR'),'DD-MON-RR')),
    	     P_Terms_Date + NVL(ap_terms_lines.discount_days_2,0)))
    , DECODE(l_amount_for_discount, NULL, NULL,
       DECODE(ap_terms_lines.discount_days_3,
        NULL,DECODE(ap_terms_lines.discount_day_of_month_3,NULL,NULL,
          TO_DATE(TO_CHAR(LEAST(
		NVL(ap_terms_lines.discount_day_of_month_3,32),
    	    TO_NUMBER(TO_CHAR(LAST_DAY(ADD_MONTHS(P_Terms_Date,
    	     NVL(ap_terms_lines.discount_months_forward_3,0) +
    	    DECODE(ap_terms.due_cutoff_day, NULL, 0,
    	    DECODE(GREATEST(LEAST(NVL(ap_terms.due_cutoff_day, 32),
    	     TO_NUMBER(TO_CHAR(LAST_DAY(P_Terms_Date), 'DD'))),
    	     TO_NUMBER(TO_CHAR(P_Terms_Date, 'DD'))),
    	     TO_NUMBER(TO_CHAR(P_Terms_Date, 'DD'))
    	     , 1, 0)))), 'DD')))) || '-' ||
    		     TO_CHAR(ADD_MONTHS(P_Terms_Date,
    	     NVL(ap_terms_lines.discount_months_forward_3,0) +
    	    DECODE(ap_terms.due_cutoff_day, NULL, 0,
    	    DECODE(GREATEST(LEAST(NVL(ap_terms.due_cutoff_day, 32),
    	     TO_NUMBER(TO_CHAR(LAST_DAY(P_Terms_Date),'DD'))),
    	     TO_NUMBER(TO_CHAR(P_Terms_Date, 'DD'))),
    	     TO_NUMBER(TO_CHAR(P_Terms_Date, 'DD')), 1, 0))),
		'MON-RR'),'DD-M0N-RR')),
    	     P_Terms_Date + NVL(ap_terms_lines.discount_days_3,0)))
    , SYSDATE
    , P_Last_Updated_By
    , NULL
    , SYSDATE
    , P_Created_By
    , l_payment_cross_rate
    , DECODE(l_min_acc_unit_pay_curr,NULL,
    	  ROUND(P_Pay_Curr_Invoice_Amount *
                   NVL(ap_terms_lines.due_percent,0)/100,l_precision_pay_curr),
    	  ROUND((P_Pay_Curr_Invoice_Amount *
                   NVL(ap_terms_lines.due_percent,0)/100)
		/ l_min_acc_unit_pay_curr)
                   * l_min_acc_unit_pay_curr)
    , NULL ,

    --Bug 7357218 Quick Pay and Dispute Resolution Project
    --Considering absolute amount and criteria for all three discounts

    CASE
        WHEN discount_criteria IS NULL OR discount_criteria = 'H' THEN
              CASE WHEN abs(nvl(l_discount_amount,0)) > abs(l_disc_amt_by_percent) THEN
                        l_discount_amount
                   ELSE l_disc_amt_by_percent
              END
        ELSE  CASE WHEN abs(nvl(l_discount_amount,0)) < abs(l_disc_amt_by_percent) THEN
                        l_discount_amount
                   ELSE l_disc_amt_by_percent
              END
    END,
    CASE
        WHEN discount_criteria_2 IS NULL OR discount_criteria_2 = 'H' THEN
              CASE WHEN abs(nvl(l_discount_amount_2,0)) > abs(l_disc_amt_by_percent_2) THEN
                        l_discount_amount_2
                   ELSE l_disc_amt_by_percent_2
              END
        ELSE  CASE WHEN abs(nvl(l_discount_amount_2,0)) < abs(l_disc_amt_by_percent_2) THEN
                        l_discount_amount_2
                   ELSE l_disc_amt_by_percent_2
              END
    END,
    CASE
        WHEN discount_criteria_3 IS NULL OR discount_criteria_3 = 'H' THEN
              CASE WHEN abs(nvl(l_discount_amount_3,0)) > abs(l_disc_amt_by_percent_3) THEN
                        l_discount_amount_3
                   ELSE l_disc_amt_by_percent_3
              END
        ELSE  CASE WHEN abs(nvl(l_discount_amount_3,0)) < abs(l_disc_amt_by_percent_3) THEN
                        l_discount_amount_3
                   ELSE l_disc_amt_by_percent_3
              END
    END,

     DECODE(l_min_acc_unit_pay_curr,NULL,
      ROUND( P_Pay_Curr_Invoice_Amount *
             NVL(ap_terms_lines.due_percent, 0)/100, l_precision_pay_curr),
     	ROUND(( P_Pay_Curr_Invoice_Amount *
            NVL(ap_terms_lines.due_percent, 0)/100)
              / l_min_acc_unit_pay_curr)*l_min_acc_unit_pay_curr)
    , 0
    , 'N'
    , 'N'
    , P_Batch_Id
    , NVL(P_Payment_Method, 'CHECK')
    ,ai.external_bank_account_id  --4393358
    ,ai.org_id
    ,ai.remittance_message1
    ,ai.remittance_message2
    ,ai.remittance_message3
    --third party payments
    ,ai.remit_to_supplier_name
    ,ai.remit_to_supplier_id
    ,ai.remit_to_supplier_site
    ,ai.remit_to_supplier_site_id
    ,ai.relationship_id
    INTO
      T_INVOICE_ID(l_payment_schedule_index),
      T_PAYMENT_NUM(l_payment_schedule_index),
      T_DUE_DATE(l_payment_schedule_index),
      T_DISCOUNT_DATE(l_payment_schedule_index),
      T_SECOND_DISCOUNT_DATE(l_payment_schedule_index),
      T_THIRD_DISCOUNT_DATE(l_payment_schedule_index),
      T_LAST_UPDATE_DATE(l_payment_schedule_index),
      T_LAST_UPDATED_BY(l_payment_schedule_index),
      T_LAST_UPDATE_LOGIN(l_payment_schedule_index),
      T_CREATION_DATE(l_payment_schedule_index),
      T_CREATED_BY(l_payment_schedule_index),
      T_PAYMENT_CROSS_RATE(l_payment_schedule_index),
      T_GROSS_AMOUNT(l_payment_schedule_index),
      T_INV_CURR_GROSS_AMOUNT(l_payment_schedule_index),
      T_DISCOUNT_AMOUNT_AVAILABLE(l_payment_schedule_index),
      T_SECOND_DISC_AMT_AVAILABLE(l_payment_schedule_index),
      T_THIRD_DISC_AMT_AVAILABLE(l_payment_schedule_index),
      T_AMOUNT_REMAINING(l_payment_schedule_index),
      T_DISCOUNT_AMOUNT_REMAINING(l_payment_schedule_index),
      T_HOLD_FLAG(l_payment_schedule_index),
      T_PAYMENT_STATUS_FLAG(l_payment_schedule_index),
      T_BATCH_ID(l_payment_schedule_index),
      T_PAYMENT_METHOD_CODE(l_payment_schedule_index),
      T_EXTERNAL_BANK_ACCOUNT_ID(l_payment_schedule_index),
      T_ORG_ID(l_payment_schedule_index),
      T_REMITTANCE_MESSAGE1(l_payment_schedule_index),
      T_REMITTANCE_MESSAGE2(l_payment_schedule_index),
      T_REMITTANCE_MESSAGE3(l_payment_schedule_index),
      --Third Party Payments
      T_REMIT_TO_SUPPLIER_NAME(l_payment_schedule_index),
      T_REMIT_TO_SUPPLIER_ID(l_payment_schedule_index),
      T_REMIT_TO_SUPPLIER_SITE(l_payment_schedule_index),
      T_REMIT_TO_SUPPLIER_SITE_ID(l_payment_schedule_index),
      T_RELATIONSHIP_ID(l_payment_schedule_index)
    FROM 	ap_terms
    , 	ap_terms_lines
    ,       ap_invoices ai
    WHERE 	ap_terms.term_id = ap_terms_lines.term_id
    AND 	ap_terms_lines.term_id = P_Terms_Id
    AND     ap_terms_lines.sequence_num = l_sequence_num
    AND     ai.invoice_id = P_Invoice_Id;

                                                                         --
      l_pay_sched_total := l_pay_sched_total +
           t_gross_amount(l_payment_schedule_index);

      l_debug_info := 'l_pay_sched_total2->'||l_pay_sched_total; --bug 8991699
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
      END IF; --bug 8991699

      IF l_min_acc_unit_inv_curr IS NULL THEN

         t_inv_curr_gross_amount(l_payment_schedule_index) :=
         ROUND(
            t_gross_amount(l_payment_schedule_index)/
            P_Payment_Cross_Rate,
            l_precision_inv_curr
         );
      ELSE
         t_inv_curr_gross_amount(l_payment_schedule_index) :=
         (ROUND(
            t_gross_amount(l_payment_schedule_index)/
            P_Payment_Cross_Rate/
            l_min_acc_unit_inv_curr)
            * l_min_acc_unit_inv_curr
         );
      END IF;

      l_debug_info := 't_inv_curr_gross_amount(l_payment_schedule_index)2->'||t_inv_curr_gross_amount(l_payment_schedule_index); --bug 8991699
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
      END IF; --bug 8991699

      t_payment_priority(l_payment_schedule_index)
             := nvl(P_Payment_Priority,l_payment_priority);

      l_inv_curr_sched_total := l_inv_curr_sched_total +
          t_inv_curr_gross_amount(l_payment_schedule_index);

      IF t_discount_date(l_payment_schedule_index) IS NULL THEN
         t_discount_amount_available(l_payment_schedule_index) := NULL;
      END IF;

      IF t_second_discount_date(l_payment_schedule_index) IS NULL THEN
         t_second_disc_amt_available(l_payment_schedule_index) := NULL;
      END IF;

      IF t_third_discount_date(l_payment_schedule_index) IS NULL THEN
         t_third_disc_amt_available(l_payment_schedule_index):= NULL;
      END IF;

      l_debug_info := 'l_inv_curr_sched_total2->'||l_inv_curr_sched_total; --bug 8991699
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
      END IF; --bug 8991699

  END LOOP;

  debug_info := 'Close c_terms';
  CLOSE c_terms;

END IF;

  debug_info := 'Close cursor c_terms_percent';
  CLOSE c_terms_percent;

  -- Find out if there is any rounding?
  IF (l_pay_sched_total <> P_Pay_Curr_Invoice_Amount) THEN
    t_gross_amount(l_payment_schedule_index) :=
    t_gross_amount(l_payment_schedule_index) +
    (to_number(P_Pay_Curr_Invoice_Amount) -
     to_number(l_pay_sched_total));

    t_amount_remaining(l_payment_schedule_index) :=
    t_amount_remaining(l_payment_schedule_index) +
    (to_number(P_Pay_Curr_Invoice_Amount) -
     to_number(l_pay_sched_total));
  END IF;

  IF (l_inv_curr_sched_total <> P_Invoice_Amount) THEN
    t_inv_curr_gross_amount(l_payment_schedule_index) :=
    t_inv_curr_gross_amount(l_payment_schedule_index) +
    (to_number(P_Invoice_Amount) -
     to_number(l_inv_curr_sched_total));

  END IF;

  l_debug_info := 'Insert the Payment Schedule Lines into the table'; --bug 8991699
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
  END IF; --bug 8991699

  -- Insert the Payment Schedule Lines into the table
  FORALL i IN 1..l_payment_schedule_index
      INSERT INTO ap_payment_schedules (
      INVOICE_ID,
      PAYMENT_NUM,
      DUE_DATE,
      DISCOUNT_DATE,
      SECOND_DISCOUNT_DATE,
      THIRD_DISCOUNT_DATE,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN,
      CREATION_DATE,
      CREATED_BY,
      PAYMENT_CROSS_RATE,
      GROSS_AMOUNT,
      INV_CURR_GROSS_AMOUNT,
      DISCOUNT_AMOUNT_AVAILABLE,
      SECOND_DISC_AMT_AVAILABLE,
      THIRD_DISC_AMT_AVAILABLE,
      AMOUNT_REMAINING,
      DISCOUNT_AMOUNT_REMAINING,
      PAYMENT_PRIORITY,
      HOLD_FLAG,
      PAYMENT_STATUS_FLAG,
      BATCH_ID,
      PAYMENT_METHOD_CODE,
      EXTERNAL_BANK_ACCOUNT_ID,
      ORG_ID,
      REMITTANCE_MESSAGE1,
      REMITTANCE_MESSAGE2,
      REMITTANCE_MESSAGE3,
      REMIT_TO_SUPPLIER_NAME,
      REMIT_TO_SUPPLIER_ID,
      REMIT_TO_SUPPLIER_SITE,
      REMIT_TO_SUPPLIER_SITE_ID,
      RELATIONSHIP_ID
    ) VALUES (
      T_INVOICE_ID(i),
      T_PAYMENT_NUM(i),
      T_DUE_DATE(i),
      T_DISCOUNT_DATE(i),
      T_SECOND_DISCOUNT_DATE(i),
      T_THIRD_DISCOUNT_DATE(i),
      T_LAST_UPDATE_DATE(i),
      T_LAST_UPDATED_BY(i),
      T_LAST_UPDATE_LOGIN(i),
      T_CREATION_DATE(i),
      T_CREATED_BY(i),
      T_PAYMENT_CROSS_RATE(i),
      T_GROSS_AMOUNT(i),
      T_INV_CURR_GROSS_AMOUNT(i),
      T_DISCOUNT_AMOUNT_AVAILABLE(i),
      T_SECOND_DISC_AMT_AVAILABLE(i),
      T_THIRD_DISC_AMT_AVAILABLE(i),
      T_AMOUNT_REMAINING(i),
      T_DISCOUNT_AMOUNT_REMAINING(i),
      T_PAYMENT_PRIORITY(i),
      T_HOLD_FLAG(i),
      T_PAYMENT_STATUS_FLAG(i),
      T_BATCH_ID(i),
      T_PAYMENT_METHOD_CODE(i),
      T_EXTERNAL_BANK_ACCOUNT_ID(i),
      T_ORG_ID(i),
      T_REMITTANCE_MESSAGE1(i),
      T_REMITTANCE_MESSAGE2(i),
      T_REMITTANCE_MESSAGE3(i),
      --Third Party Payments
      T_REMIT_TO_SUPPLIER_NAME(i),
      T_REMIT_TO_SUPPLIER_ID(i),
      T_REMIT_TO_SUPPLIER_SITE(i),
      T_REMIT_TO_SUPPLIER_SITE_ID(i),
      T_RELATIONSHIP_ID(i)
    )
  RETURNING payment_num
  BULK COLLECT INTO l_dbi_key_value_list;

  AP_DBI_PKG.Maintain_DBI_Summary
            (p_table_name => 'AP_PAYMENT_SCHEDULES',
             p_operation => 'I',
             p_key_value1 => P_invoice_id,
             p_key_value_list => l_dbi_key_value_list,
             p_calling_sequence => current_calling_sequence);


  FOR j IN 1..l_payment_schedule_index loop
    ap_invoices_pkg.validate_docs_payable(T_INVOICE_ID(j),
                                          T_PAYMENT_NUM(j),
                                          l_hold_flag); --not used
  end loop;


                                                              --
  EXCEPTION
    WHEN OTHERS THEN
      if (SQLCODE <> -20001) then
        FND_MESSAGE.SET_NAME('SQLAP', 'AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR', SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', current_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS', 'Invoice_Id = '||P_Invoice_Id
                              ||', Terms_Id = '            ||P_Terms_Id
                              ||', Last_Updated_By = '     ||P_Last_Updated_By
                              ||', Created_By = '          ||P_Created_By
                              ||', Payment_Priority = '    ||P_Payment_Priority
                              ||', Batch_Id = '            ||P_Batch_Id
                              ||', Terms_Date = '          ||P_Terms_Date
                              ||', Invoice_Amount = '      ||P_Invoice_Amount
                              ||', Amount_for_discount = ' ||P_Amount_For_Discount
                              ||', Payment_Method = '      ||P_Payment_Method
                              ||', Currency = '            ||P_invoice_currency
			      	);
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO', debug_info);
      end if;
      APP_EXCEPTION.RAISE_EXCEPTION;

END Create_Payment_Schedules;


-- ===================================================================

PROCEDURE AP_Create_From_Terms(
          P_Invoice_Id               IN     NUMBER,
          P_Terms_Id                 IN     NUMBER,
          P_Last_Updated_By          IN     NUMBER,
          P_Created_By               IN     NUMBER,
          P_Payment_Priority         IN     NUMBER,
          P_Batch_Id                 IN     NUMBER,
          P_Terms_Date               IN     DATE,
          P_Invoice_Amount           IN     NUMBER,
          P_Pay_Curr_Invoice_Amount  IN     NUMBER,
          P_Payment_Cross_Rate       IN     NUMBER,
          P_Amount_For_Discount      IN     NUMBER,
          P_Payment_Method           IN     VARCHAR2,
          P_Invoice_Currency         IN     VARCHAR2,
          P_Payment_Currency         IN     VARCHAR2,
          P_calling_sequence         IN     VARCHAR2)
IS

  -- Following is how the input amounts are interpreted:
  --    Amount                    is in ....
  --    ======                    ==========
  --  P_Invoice_amount            invoice currency
  --  P_Pay_Curr_Invoice_Amount   payment currency
  --  P_Amount_For_Discount       invoice currency
  --  All amounts in AP_TERMS_LINES will be interpreted to be in the payment
  --  currency

  l_payment_cross_rate     ap_payment_schedules.payment_cross_rate%TYPE;
  l_sequence_num     ap_terms_lines.sequence_num%TYPE := 0;
  l_sign_due_amount     ap_terms_lines.due_amount%TYPE;
  l_sign_remaining_amount  ap_terms_lines.due_amount%TYPE;
  l_calendar               ap_terms_lines.calendar%TYPE; -- for payment terms
  l_terms_calendar         ap_terms_lines.calendar%TYPE; -- for payment terms
  l_due_date               ap_other_periods.due_date%TYPE; -- for payment terms
  l_invoice_sign     NUMBER;
  l_pay_sched_total     NUMBER;
  l_inv_curr_sched_total   NUMBER;
  l_remaining_amount     ap_payment_schedules.amount_remaining%TYPE;
  l_old_remaining_amount   ap_payment_schedules.amount_remaining%TYPE;
  l_ins_gross_amount     ap_payment_schedules.gross_amount%TYPE;
  l_last_line_flag     BOOLEAN;
  l_dummy       VARCHAR2(200);
  current_calling_sequence VARCHAR2(2000);
  debug_info               VARCHAR2(100);
  l_amount_for_discount    ap_invoices.amount_applicable_to_discount%TYPE;
  l_orig_ext_bank_acct_id  number;            /*bug 1274099*/
  l_orig_ext_bank_exists   varchar2(1);
  --bug 2143298 Included local variable to store invoice type
  l_invoice_type           ap_invoices.invoice_type_lookup_code%TYPE;
  l_Payment_Priority       NUMBER(15):=NULL; /*Bug fix:1635550*/

  --  Bug Fix: 1952122
  l_min_acc_unit_pay_curr  fnd_currencies.minimum_accountable_unit%TYPE;
  l_precision_pay_curr     fnd_currencies.precision%TYPE;
  l_min_acc_unit_inv_curr  fnd_currencies.minimum_accountable_unit%TYPE;
  l_precision_inv_curr     fnd_currencies.precision%TYPE;
  l_hold_flag              varchar2(1);
  --Bug 4539462 DBI logging
  l_dbi_key_value_list1        ap_dbi_pkg.r_dbi_key_value_arr;
  l_dbi_key_value_list2        ap_dbi_pkg.r_dbi_key_value_arr;


 --Bug 7357218 Quick Pay and Dispute Resolution Project
 --Introduced variables for discount calculation
  l_disc_amt_by_percent    NUMBER;
  l_disc_amt_by_percent_2  NUMBER;
  l_disc_amt_by_percent_3  NUMBER;
  l_discount_amount        NUMBER;
  l_discount_amount_2      NUMBER;
  l_discount_amount_3      NUMBER;
  l_procedure_name CONSTANT VARCHAR2(30) := 'Ap_Create_From_Terms';
  l_log_msg FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;

  l_api_name              varchar(50); --bug 8991699
  l_debug_info            varchar2(2000); --bug 8991699
  l_retained_amount        number; --bug 8991699
  l_net_of_ret_flag        ap_invoices.net_of_retainage_flag%TYPE; --bug 8991699

  CURSOR  c_terms_percent IS
  SELECT 'Terms are percent type'
    FROM  ap_terms_lines
   WHERE  term_id = P_Terms_Id
     AND  sequence_num = 1
     AND  due_percent IS NOT NULL;

  -- add cursor c_terms for calendar based payment terms

  CURSOR c_terms IS
  SELECT calendar, sequence_num
    FROM ap_terms_lines
   WHERE term_id = p_terms_id
   ORDER BY sequence_num;

  --bug 2143298 provides payment terms for credit/debit memo
  CURSOR c_amounts IS
  SELECT SIGN(ABS(P_Invoice_Amount)) ,
         SIGN(due_amount) ,
         due_amount ,
         SIGN(ABS(l_remaining_amount) - ABS(due_amount)) ,
         ABS(l_remaining_amount) - ABS(due_amount) ,
         calendar    -- change for calendar based payment terms
    FROM ap_terms_lines
   WHERE term_id = P_Terms_Id
     AND sequence_num = l_sequence_num;

  CURSOR c_shed_total IS
  SELECT SUM(gross_amount),
         SIGN(SUM(gross_amount))
    FROM ap_payment_schedules
   WHERE invoice_id = P_Invoice_Id;

  CURSOR c_inv_curr_sched_total IS
  SELECT SUM(inv_curr_gross_amount),
         SIGN(SUM(inv_curr_gross_amount))
    FROM  ap_payment_schedules
   WHERE invoice_id = P_Invoice_Id;


  -- if there is external bank account associated with the invoice associated
  -- with the payment schedule we are working on.  We have to join
  -- using the vendor id because a user could have updated the vendor
  -- on the invoice.

  CURSOR c_orig_bank_acct_vendor  IS  --BUG 1274099, checks at the vendor level
    SELECT ai.external_bank_account_id, 'Y'   --modified for the bug 7261556/7375488
    FROM ap_payment_schedules aps,
         ap_invoices ai,
         --iby_payee_assigned_bankacct_v ipab, /* External Bank Uptake */
         po_vendors pv
   WHERE ai.invoice_id = p_invoice_id
     AND ai.vendor_id  = pv.vendor_id        -- changed for bug 9531288
     --AND pv.party_id   = ipab.party_id(+)
     AND ai.invoice_id = aps.invoice_id
     --AND ipab.ext_bank_account_id = aps.external_bank_account_id
     AND EXISTS (SELECT 'x' FROM iby_payee_assigned_bankacct_v IPAB WHERE
             pv.party_id = ipab.party_id (+) AND ipab.ext_bank_account_id =
              aps.external_bank_account_id ) ;

  -- bug 1274099 checks for the vendor site level

  CURSOR c_orig_bank_acct_vend_site IS
  SELECT ai.external_bank_account_id, 'Y'   --modified for the bug 7437597
    FROM ap_payment_schedules aps,
         ap_invoices ai,
         iby_payee_assigned_bankacct_v ipab, /* External Bank Uptake */
         po_vendors pv
    WHERE ai.invoice_id = p_invoice_id
     AND ai.vendor_id   = pv.vendor_id
     AND pv.party_id    = ipab.party_id(+)
     AND (ai.vendor_site_id = ipab.supplier_site_id
          OR (ipab.supplier_site_id IS NULL
              AND ipab.org_id = ai.org_id))
     AND ai.invoice_id     = aps.invoice_id
     AND ipab.ext_bank_account_id = aps.external_bank_account_id;

BEGIN
  -- Update the calling sequence
  current_calling_sequence := 'AP_CREATE_PAY_SCHEDS_PKG.AP_Create_From_Terms<-'
                              ||P_calling_sequence;

  l_api_name := 'AP_Create_From_Terms';

  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name,
                      'AP_CREATE_PAY_SCHEDS_PKG.AP_Create_From_Terms<-'||P_calling_sequence);
  END IF;

  --  Bug Fix:1952122
  --  Select precision and minimum_accountable_unit before loops
  --  for payment currency

  BEGIN
    SELECT fc.minimum_accountable_unit, fc.precision
      INTO l_min_acc_unit_pay_curr, l_precision_pay_curr
      FROM fnd_currencies fc
     WHERE fc.currency_code = P_Payment_Currency;
  END;

  --  Select precision and minimum_accountable_unit before loops
  --  for invoice currency

  BEGIN
    SELECT fc.minimum_accountable_unit, fc.precision
      INTO l_min_acc_unit_inv_curr, l_precision_inv_curr
      FROM fnd_currencies fc
     WHERE fc.currency_code = P_Invoice_Currency;
  END;

  -- Bug Fix:1635550
  -- Added the following unit to the code so that when we recalculate
  -- the payment schedules whenever some fields at the invoice header are
  -- changed we repopulate the payment priority into all the records
  -- at the payment schedule level with value in the payment_priority
  -- of the first record

  BEGIN
    SELECT payment_priority
      INTO l_Payment_Priority
      FROM ap_payment_schedules
     WHERE Invoice_id = P_invoice_id
       AND Payment_num=1;

   EXCEPTION
     WHEN NO_Data_Found THEN
       NULL;
  END;

  /* The code below was added as part of bug 1274099.  We are checking
     to see if the queries in the 2 cursors defined above get data.  If
     they do, then we need to store the external_bank_account_id in a
     variable.  Later in the code we then insert in the payment schedule
     record.  We have to do this because below the code fix for this bug
     we delete the orignal payment schedule and create a new one. */

  OPEN c_orig_bank_acct_vendor;
  FETCH c_orig_bank_acct_vendor INTO
        l_orig_ext_bank_acct_id,
        l_orig_ext_bank_exists;

  IF c_orig_bank_acct_vendor%NOTFOUND THEN
     OPEN  c_orig_bank_acct_vend_site;
     FETCH c_orig_bank_acct_vend_site INTO
           l_orig_ext_bank_acct_id,
           l_orig_ext_bank_exists;
     CLOSE c_orig_bank_acct_vend_site;
  END IF;
  CLOSE c_orig_bank_acct_vendor;

  -- Delete existing payment schedules since we're creating
  -- new payment schedules from payment terms

  --Bug 4539462 get list of payment nums first
  SELECT payment_num
  BULK COLLECT INTO l_dbi_key_value_list1
  FROM AP_PAYMENT_SCHEDULES
  WHERE invoice_id = P_invoice_id;

  debug_info := 'Delete from ap_payment_schedules';
  DELETE
    FROM ap_payment_schedules
   WHERE invoice_id = P_invoice_id;

  --Bug 4539462 DBI logging
  AP_DBI_PKG.Maintain_DBI_Summary
              (p_table_name => 'AP_PAYMENT_SCHEDULES',
               p_operation => 'D',
               p_key_value1 => P_invoice_id,
               p_key_value_list => l_dbi_key_value_list1,
                p_calling_sequence => current_calling_sequence);

  -- bug 2143298 keep track of invoice type to provide payment terms
  -- for credit/debit memo

  SELECT invoice_type_lookup_code
    INTO l_invoice_type
    FROM ap_invoices
   WHERE invoice_id = P_Invoice_Id;


  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
    l_log_msg := 'Invoice Type is '|| l_invoice_type;
    FND_LOG.STRING(G_LEVEL_STATEMENT,
                   G_MODULE_NAME||l_procedure_name,
                   l_log_msg);
  END IF;



  debug_info := 'Open cursor c_terms_percent';

  OPEN  c_terms_percent;
  debug_info := 'Fetch cursor c_terms_percent';
  FETCH c_terms_percent INTO l_dummy;

  -- Change for cross currency
  -- Set the payment cross rate and amount applicable to discount

  l_payment_cross_rate := P_payment_cross_rate;

  debug_info := 'Convert discount amount to payment currency';
  l_amount_for_discount :=  ap_utilities_pkg.ap_round_currency(
                            P_Amount_For_Discount * P_Payment_Cross_Rate,
                            P_Payment_Currency);

   l_debug_info := 'Convert discount amount to payment currency->'||l_amount_for_discount||'P_Pay_Curr_Invoice_Amount->'||P_Pay_Curr_Invoice_Amount; --bug 8991699
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
  END IF; --bug 8991699

  IF c_terms_percent%NOTFOUND THEN -- Terms type is Slab
    debug_info := 'c_terms_percent%NOTFOUND';


    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
        l_log_msg := 'Terms type is Slab';
    FND_LOG.STRING(G_LEVEL_STATEMENT,
                   G_MODULE_NAME||l_procedure_name,
                   l_log_msg);
    END IF;

    l_remaining_amount := P_Pay_Curr_Invoice_Amount;

    <<slab_loop>>
    LOOP
      l_sequence_num := l_sequence_num + 1;
      l_old_remaining_amount := l_remaining_amount;
                                                                         --
      debug_info := 'Open cursor c_amounts';
      OPEN  c_amounts;
      debug_info := 'Fetch cursor c_amounts';
      FETCH c_amounts INTO l_invoice_sign
                         , l_sign_due_amount
                         , l_ins_gross_amount
                         , l_sign_remaining_amount
                         , l_remaining_amount
                         , l_calendar ;  -- add for payment terms
      debug_info := 'Close cursor c_amounts';
      CLOSE c_amounts;


      -- bug 2143298 For a negative amount invoice the due amount
      -- should be reversed. Also the remaining amount also should be
      -- reversed because the due amount for the last line will be
      -- assigned the remaining amount.

      IF l_invoice_type in ('CREDIT','DEBIT') THEN
         l_ins_gross_amount := 1 * l_ins_gross_amount;
         l_remaining_amount := -1 * l_remaining_amount;
  --Bug 8652612
            IF (l_ins_gross_amount > 0) THEN
               l_ins_gross_amount  :=l_remaining_amount - l_ins_gross_amount ;
               l_last_line_flag    := TRUE;
            END IF;

      END IF;
                                                                         --
      IF (
          (l_sign_remaining_amount <= 0)
          OR
          (l_invoice_sign <= 0)
          OR
          (l_sign_due_amount = 0)) THEN
        l_ins_gross_amount := l_old_remaining_amount;
        l_last_line_flag := TRUE;
      END IF;

                                                                         --
      -- Change for MSB Project
      -- If the invoice is created by recurring payments get appropriate
      -- bank account from there, if one exists. If it isn't a recurring
      -- payment get the site's primary supplier bank account for MSB.

      l_debug_info := 'Calculate Due Date - terms slab type'; --bug 8991699
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
      END IF; --bug 8991699

      l_due_date := Calc_Due_Date (
          p_terms_date,
          p_terms_id,
          l_calendar,
          l_sequence_num,
          p_calling_sequence );

--Bug 7357218 Quick Pay and Dispute Resolution Project

  debug_info := 'Calculating discount amounts by percent for slab type BEGIN';

  SELECT DECODE(l_min_acc_unit_pay_curr,
                 NULL, ROUND( l_ins_gross_amount *
                       DECODE(P_Pay_Curr_Invoice_Amount, 0, 0,
                             (l_amount_for_discount/
                              DECODE(P_Pay_Curr_Invoice_Amount, 0, 1,
                                     P_Pay_Curr_Invoice_Amount))) *
                       NVL(ap_terms_lines.discount_percent,0)/100 ,
                           l_precision_pay_curr),
          ROUND(( l_ins_gross_amount *
                 DECODE(P_Pay_Curr_Invoice_Amount, 0, 0,
                 (l_amount_for_discount/
                  DECODE(P_Pay_Curr_Invoice_Amount, 0, 1,
                         P_Pay_Curr_Invoice_Amount))) *
                  NVL(ap_terms_lines.discount_percent,0)/100)
                  / l_min_acc_unit_pay_curr) * l_min_acc_unit_pay_curr)
        ,	DECODE(l_min_acc_unit_pay_curr,
                 NULL, ROUND( l_ins_gross_amount *
                       DECODE(P_Pay_Curr_Invoice_Amount, 0, 0,
                             (l_amount_for_discount/
                              DECODE(P_Pay_Curr_Invoice_Amount, 0, 1,
                                     P_Pay_Curr_Invoice_Amount))) *
                       NVL(ap_terms_lines.discount_percent_2,0)/100 ,
                           l_precision_pay_curr),
          ROUND(( l_ins_gross_amount *
                 DECODE(P_Pay_Curr_Invoice_Amount, 0, 0,
                 (l_amount_for_discount/
                  DECODE(P_Pay_Curr_Invoice_Amount, 0, 1,
                         P_Pay_Curr_Invoice_Amount))) *
                  NVL(ap_terms_lines.discount_percent_2,0)/100)
                  / l_min_acc_unit_pay_curr) * l_min_acc_unit_pay_curr)
        ,	DECODE(l_min_acc_unit_pay_curr,
                 NULL, ROUND( l_ins_gross_amount *
                       DECODE(P_Pay_Curr_Invoice_Amount, 0, 0,
                             (l_amount_for_discount/
                              DECODE(P_Pay_Curr_Invoice_Amount, 0, 1,
                                     P_Pay_Curr_Invoice_Amount))) *
                       NVL(ap_terms_lines.discount_percent_3,0)/100 ,
                           l_precision_pay_curr),
          ROUND(( l_ins_gross_amount *
                 DECODE(P_Pay_Curr_Invoice_Amount, 0, 0,
                 (l_amount_for_discount/
                  DECODE(P_Pay_Curr_Invoice_Amount, 0, 1,
                         P_Pay_Curr_Invoice_Amount))) *
                  NVL(ap_terms_lines.discount_percent_3,0)/100)
                  / l_min_acc_unit_pay_curr) * l_min_acc_unit_pay_curr),
              discount_amount,
              discount_amount_2,
              discount_amount_3
  INTO
           l_disc_amt_by_percent, l_disc_amt_by_percent_2, l_disc_amt_by_percent_3,
           l_discount_amount, l_discount_amount_2, l_discount_amount_3

  FROM 	ap_terms
        , ap_terms_lines
        , ap_invoices ai
  WHERE ap_terms.term_id = ap_terms_lines.term_id
        AND ap_terms_lines.term_id = P_Terms_Id
        AND ap_terms_lines.sequence_num = l_sequence_num
        AND ai.Invoice_Id = P_Invoice_Id;

  --Bug 7357218 Quick Pay and Dispute Resolution Project
  --Calculating discount amounts by percent for slab type END

    --Bug 7357218 Quick Pay and Dispute Resolution Project
    debug_info := 'Making discount amount negative for credit/debit memos';
      IF l_invoice_type in ('CREDIT','DEBIT') THEN
        l_discount_amount   := -1 * l_discount_amount;
        l_discount_amount_2 := -1 * l_discount_amount_2;
        l_discount_amount_3 := -1 * l_discount_amount_3;
      END IF;


    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
        l_log_msg := 'Sequence:'|| l_sequence_num ||
                 ' Disc1 by percent:' || l_disc_amt_by_percent ||
                 ' Disc2 by percent:' || l_disc_amt_by_percent_2 ||
                 ' Disc3 by percent:' || l_disc_amt_by_percent_3 ||
                 ' Disc1 by amount:' || l_discount_amount ||
                 ' Disc2 by amount:' || l_discount_amount_2 ||
                 ' Disc3 by amount:' || l_discount_amount_3;
    FND_LOG.STRING(G_LEVEL_STATEMENT,
                   G_MODULE_NAME||l_procedure_name,
                   l_log_msg);
  END IF;

      debug_info := 'Insert into ap_payment_schedules';
/*Bug 45632726.When we are recreating the payment schedules after deleting it
 * then the created-by and last-updated-by would be same i.e the person who
 * recreated
 * payment schedules and not the one who created the invoice*/

      INSERT INTO ap_payment_schedules (
          invoice_id,
          payment_num,
          due_date,
          discount_date,
          second_discount_date,
          third_discount_date,
          last_update_date,
          last_updated_by,
          last_update_login,
          creation_date,
          created_by,
          payment_cross_rate,
          gross_amount,
          discount_amount_available,
          second_disc_amt_available,
          third_disc_amt_available,
          amount_remaining,
          discount_amount_remaining,
          payment_priority,
          hold_flag,
          payment_status_flag,
          batch_id,
          payment_method_code,
          external_bank_account_id,
          org_id,
          remittance_message1,
          remittance_message2,
          remittance_message3
	  --third party payments
          ,remit_to_supplier_name
          ,remit_to_supplier_id
          ,remit_to_supplier_site
          ,remit_to_supplier_site_id
	  ,relationship_id)
      SELECT
          P_Invoice_Id,
          l_sequence_num,
          l_due_date,    -- change for payment terms
          DECODE(ap_terms_lines.discount_days,
            NULL, DECODE(ap_terms_lines.discount_day_of_month, NULL, NULL,
            TO_DATE(TO_CHAR(LEAST(NVL(ap_terms_lines.discount_day_of_month,32),
            TO_NUMBER(TO_CHAR(LAST_DAY(ADD_MONTHS
            (P_Terms_Date, NVL(ap_terms_lines.discount_months_forward,0) +
            DECODE(ap_terms.due_cutoff_day, NULL, 0,
            DECODE(GREATEST(LEAST(NVL(ap_terms.due_cutoff_day, 32),
               TO_NUMBER(TO_CHAR(LAST_DAY(P_Terms_Date), 'DD'))),
               TO_NUMBER(TO_CHAR(P_Terms_Date, 'DD'))),
               TO_NUMBER(TO_CHAR(P_Terms_Date, 'DD'))
               , 1, 0)))), 'DD')))) || '-' ||
             TO_CHAR(ADD_MONTHS(P_Terms_Date,
             NVL(ap_terms_lines.discount_months_forward,0) +
            DECODE(ap_terms.due_cutoff_day, NULL, 0,
            DECODE(GREATEST(LEAST(NVL(ap_terms.due_cutoff_day, 32),
               TO_NUMBER(TO_CHAR(LAST_DAY(P_Terms_Date),'DD'))),
               TO_NUMBER(TO_CHAR(P_Terms_Date, 'DD'))),
               TO_NUMBER(TO_CHAR(P_Terms_Date, 'DD')), 1, 0))), 'MON-RR'),'DD-MON-RR')),  /*bugfix:5647464 */
               P_Terms_Date + NVL(ap_terms_lines.discount_days,0)),
          DECODE(ap_terms_lines.discount_days_2,
            NULL,DECODE(ap_terms_lines.discount_day_of_month_2,NULL,NULL,
            TO_DATE(TO_CHAR(LEAST
            (NVL(ap_terms_lines.discount_day_of_month_2,32),
            TO_NUMBER(TO_CHAR(LAST_DAY(ADD_MONTHS(P_Terms_Date,
            NVL(ap_terms_lines.discount_months_forward_2,0) +
            DECODE(ap_terms.due_cutoff_day, NULL, 0,
            DECODE(GREATEST(LEAST(NVL(ap_terms.due_cutoff_day, 32),
               TO_NUMBER(TO_CHAR(LAST_DAY(P_Terms_Date), 'DD'))),
               TO_NUMBER(TO_CHAR(P_Terms_Date, 'DD'))),
               TO_NUMBER(TO_CHAR(P_Terms_Date, 'DD'))
               , 1, 0)))), 'DD')))) || '-' ||
             TO_CHAR(ADD_MONTHS(P_Terms_Date,
             NVL(ap_terms_lines.discount_months_forward_2,0) +
            DECODE(ap_terms.due_cutoff_day, NULL, 0,
            DECODE(GREATEST(LEAST(NVL(ap_terms.due_cutoff_day, 32),
              TO_NUMBER(TO_CHAR(LAST_DAY(P_Terms_Date),'DD'))),
               TO_NUMBER(TO_CHAR(P_Terms_Date, 'DD'))),
               TO_NUMBER(TO_CHAR(P_Terms_Date, 'DD')), 1, 0))), 'MON-RR'),'DD-MON-RR')),  /*bugfix:5647464 */
               P_Terms_Date + NVL(ap_terms_lines.discount_days_2,0)),
          DECODE(ap_terms_lines.discount_days_3,
            NULL, DECODE(ap_terms_lines.discount_day_of_month_3, NULL,NULL,
            TO_DATE(TO_CHAR(LEAST
            (NVL(ap_terms_lines.discount_day_of_month_3,32),
            TO_NUMBER(TO_CHAR(LAST_DAY(ADD_MONTHS(P_Terms_Date,
             NVL(ap_terms_lines.discount_months_forward_3,0) +
            DECODE(ap_terms.due_cutoff_day, NULL, 0,
            DECODE(GREATEST(LEAST(NVL(ap_terms.due_cutoff_day, 32),
               TO_NUMBER(TO_CHAR(LAST_DAY(P_Terms_Date), 'DD'))),
               TO_NUMBER(TO_CHAR(P_Terms_Date, 'DD'))),
               TO_NUMBER(TO_CHAR(P_Terms_Date, 'DD'))
             , 1, 0)))), 'DD')))) || '-' ||
             TO_CHAR(ADD_MONTHS(P_Terms_Date,
             NVL(ap_terms_lines.discount_months_forward_3,0) +
            DECODE(ap_terms.due_cutoff_day, NULL, 0,
            DECODE(GREATEST(LEAST(NVL(ap_terms.due_cutoff_day, 32),
               TO_NUMBER(TO_CHAR(LAST_DAY(P_Terms_Date),'DD'))),
               TO_NUMBER(TO_CHAR(P_Terms_Date, 'DD'))),
               TO_NUMBER(TO_CHAR(P_Terms_Date, 'DD')), 1, 0))), 'MON-RR'),'DD-MON-RR')), /*bugfix:5647464 */
              P_Terms_Date + NVL(ap_terms_lines.discount_days_3,0)),
          SYSDATE,
          P_Last_Updated_By,
          NULL,
          SYSDATE,
          P_Last_Updated_By,--bug4563272
          l_payment_cross_rate,
          DECODE(l_min_acc_unit_pay_curr,
                 NULL, ROUND(l_ins_gross_amount, l_precision_pay_curr),
                       ROUND(l_ins_gross_amount /l_min_acc_unit_pay_curr)
                           * l_min_acc_unit_pay_curr) ,
        --Bug 7357218 Quick Pay and Dispute Resolution Project
        --Considering absolute amount and criteria for all three discounts

    CASE
        WHEN discount_criteria IS NULL OR discount_criteria = 'H' THEN
              CASE WHEN abs(nvl(l_discount_amount,0)) > abs(l_disc_amt_by_percent) THEN
                        l_discount_amount
                   ELSE l_disc_amt_by_percent
              END
        ELSE  CASE WHEN abs(nvl(l_discount_amount,0)) < abs(l_disc_amt_by_percent) THEN
                        l_discount_amount
                   ELSE l_disc_amt_by_percent
              END
    END,
    CASE
        WHEN discount_criteria_2 IS NULL OR discount_criteria_2 = 'H' THEN
              CASE WHEN abs(nvl(l_discount_amount_2,0)) > abs(l_disc_amt_by_percent_2) THEN
                        l_discount_amount_2
                   ELSE l_disc_amt_by_percent_2
              END
        ELSE  CASE WHEN abs(nvl(l_discount_amount_2,0)) < abs(l_disc_amt_by_percent_2) THEN
                        l_discount_amount_2
                   ELSE l_disc_amt_by_percent_2
              END
    END,
    CASE
        WHEN discount_criteria_3 IS NULL OR discount_criteria_3 = 'H' THEN
              CASE WHEN abs(nvl(l_discount_amount_3,0)) > abs(l_disc_amt_by_percent_3) THEN
                        l_discount_amount_3
                   ELSE l_disc_amt_by_percent_3
              END
        ELSE  CASE WHEN abs(nvl(l_discount_amount_3,0)) < abs(l_disc_amt_by_percent_3) THEN
                        l_discount_amount_3
                   ELSE l_disc_amt_by_percent_3
              END
    END,
          DECODE(l_min_acc_unit_pay_curr,
                 NULL, ROUND(l_ins_gross_amount, l_precision_pay_curr),
                       ROUND(l_ins_gross_amount /l_min_acc_unit_pay_curr)
                       * l_min_acc_unit_pay_curr),
          0,
          NVL(l_Payment_Priority,P_Payment_Priority),
          'N',
          'N',
          P_Batch_Id,
          NVL(P_Payment_Method, 'CHECK'),
         /*commented for bug 5332569
          DECODE(l_orig_ext_bank_exists, 'Y',
                   l_orig_ext_bank_acct_id,        --1274099
                   ai.external_bank_account_id),  --4393358
          */

       -- Added for Bug 5332569  for inserting external_bank_account_id correctly
        DECODE(l_orig_ext_bank_exists,
                      'Y', l_orig_ext_bank_acct_id,
                       DECODE(ai.source,
                             'RECURRING INVOICE', arp.external_bank_account_id,
                            ai.external_bank_account_id)),

          ai.org_id,
          ai.remittance_message1,
          ai.remittance_message2,
          ai.remittance_message3
          --third party payments
          ,ai.remit_to_supplier_name
          ,ai.remit_to_supplier_id
          ,ai.remit_to_supplier_site
          ,ai.remit_to_supplier_site_id
	  ,ai.relationship_id
      FROM   ap_terms,
             ap_terms_lines,
             ap_invoices ai,
             ap_recurring_payments arp  --bug 5332569
      WHERE  ap_terms.term_id            = ap_terms_lines.term_id
        AND  ap_terms_lines.term_id      = P_Terms_Id
        AND  ap_terms_lines.sequence_num = l_sequence_num
        AND  ai.Invoice_Id               = P_Invoice_Id
        AND  ai.recurring_payment_id = arp.recurring_payment_id(+); --bug 5332569

     l_debug_info := 'After Insert into ap_payment_schedules- term type is not percent'; --bug 8991699
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info); --bug 8991699
      END IF;

      --Bug 4539462 DBI logging
      AP_DBI_PKG.Maintain_DBI_Summary
              (p_table_name => 'AP_PAYMENT_SCHEDULES',
               p_operation => 'I',
               p_key_value1 => P_invoice_id,
               p_key_value2 => l_sequence_num,
                p_calling_sequence => current_calling_sequence);

      -- If we are at the last line then break out NOCOPY the loop

      IF (l_last_line_flag = TRUE) THEN
        EXIT;
      END IF;
    END LOOP slab_loop;
                                                                         --
  ELSE
  --    /* Terms type is Percent */

    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
        l_log_msg := 'Terms type is Percent';
    FND_LOG.STRING(G_LEVEL_STATEMENT,
                   G_MODULE_NAME||l_procedure_name,
                   l_log_msg);
    END IF;

    OPEN c_terms;
    LOOP
      FETCH c_terms INTO l_terms_calendar,
                         l_sequence_num;
      EXIT WHEN c_terms%NOTFOUND;

      -- Change for MSB Project
      -- If the invoice is created by recurring payments get appropriate
      -- bank account from there, if one exists. If it isn't a recurring
      -- payment get the site's primary supplier bank account for MSB.

      -- Terms type is Percent

      l_debug_info := 'Calculate Due Date - terms type is percent'; --bug 8991699
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
      END IF; --bug 8991699

      l_due_date := Calc_Due_Date (
          p_terms_date,
          p_terms_id,
          l_terms_calendar,
          l_sequence_num,
          p_calling_sequence); -- add for payment terms

    debug_info := 'l_due_date'||to_char(l_due_date,'dd-mm-yyyy');
--Bug 7357218 Quick Pay and Dispute Resolution Project

  debug_info := 'Calculating discount amounts by percent for pecent type BEGIN';

  SELECT DECODE(l_min_acc_unit_pay_curr,NULL,
               ROUND( l_amount_for_discount *
                      NVL(ap_terms_lines.discount_percent,0)/100 *
                      NVL(ap_terms_lines.due_percent, 0)/100,
                          l_precision_pay_curr),
               ROUND(( l_amount_for_discount *
                      NVL(ap_terms_lines.discount_percent,0)/100 *
                      NVL(ap_terms_lines.due_percent, 0)/100)
                      / l_min_acc_unit_pay_curr)
               * l_min_acc_unit_pay_curr)
        ,	DECODE(l_min_acc_unit_pay_curr,NULL,
               ROUND( l_amount_for_discount *
                      NVL(ap_terms_lines.discount_percent_2,0)/100 *
                      NVL(ap_terms_lines.due_percent, 0)/100,
                          l_precision_pay_curr),
               ROUND(( l_amount_for_discount *
                      NVL(ap_terms_lines.discount_percent_2,0)/100 *
                      NVL(ap_terms_lines.due_percent, 0)/100)
                      / l_min_acc_unit_pay_curr)
               * l_min_acc_unit_pay_curr)
        ,DECODE(l_min_acc_unit_pay_curr,NULL,
               ROUND( l_amount_for_discount *
                      NVL(ap_terms_lines.discount_percent_3,0)/100 *
                      NVL(ap_terms_lines.due_percent, 0)/100,
                          l_precision_pay_curr),
               ROUND(( l_amount_for_discount *
                      NVL(ap_terms_lines.discount_percent_3,0)/100 *
                      NVL(ap_terms_lines.due_percent, 0)/100)
                      / l_min_acc_unit_pay_curr)
               * l_min_acc_unit_pay_curr),
              discount_amount,
              discount_amount_2,
              discount_amount_3
  INTO
           l_disc_amt_by_percent, l_disc_amt_by_percent_2, l_disc_amt_by_percent_3,
           l_discount_amount, l_discount_amount_2, l_discount_amount_3

  FROM   ap_terms,
         ap_terms_lines,
         ap_invoices ai,
         ap_recurring_payments arp
  WHERE  ap_terms.term_id            = ap_terms_lines.term_id
    AND  ap_terms_lines.term_id      = P_Terms_Id
    AND  ap_terms_lines.sequence_num = l_sequence_num
    AND  ai.Invoice_Id               = P_Invoice_Id
    AND  ai.recurring_payment_id = arp.recurring_payment_id(+);

  --Bug 7357218 Quick Pay and Dispute Resolution Project
  --Calculating discount amounts by percent for percent type END

   --Bug 7357218 Quick Pay and Dispute Resolution Project
   debug_info := 'Making discount amount negative for credit/debit memos';
      IF l_invoice_type in ('CREDIT','DEBIT') THEN
        l_discount_amount   := -1 * l_discount_amount;
        l_discount_amount_2 := -1 * l_discount_amount_2;
        l_discount_amount_3 := -1 * l_discount_amount_3;
      END IF;


   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
      l_log_msg := 'Sequence:'|| l_sequence_num ||
                 ' Disc1 by percent:' || l_disc_amt_by_percent ||
                 ' Disc2 by percent:' || l_disc_amt_by_percent_2 ||
                 ' Disc3 by percent:' || l_disc_amt_by_percent_3 ||
                 ' Disc1 by amount:' || l_discount_amount ||
                 ' Disc2 by amount:' || l_discount_amount_2 ||
                 ' Disc3 by amount:' || l_discount_amount_3;
    FND_LOG.STRING(G_LEVEL_STATEMENT,
                   G_MODULE_NAME||l_procedure_name,
                   l_log_msg);
  END IF;

    debug_info := 'Insert into ap_payment_schedules : term type is percent';


    INSERT INTO ap_payment_schedules (
          invoice_id,
          payment_num,
          due_date,
          discount_date,
          second_discount_date,
          third_discount_date,
          last_update_date,
          last_updated_by,
          last_update_login,
          creation_date,
          created_by,
          payment_cross_rate,
          gross_amount,
          discount_amount_available,
          second_disc_amt_available,
          third_disc_amt_available,
          amount_remaining,
          discount_amount_remaining,
          payment_priority,
          hold_flag,
          payment_status_flag,
          batch_id,
          payment_method_code,
          external_bank_account_id,
          org_id,
          remittance_message1,
          remittance_message2,
          remittance_message3
	   --third party payments
          ,remit_to_supplier_name
          ,remit_to_supplier_id
          ,remit_to_supplier_site
          ,remit_to_supplier_site_id
	  ,relationship_id)
    SELECT
        P_Invoice_Id,
        l_sequence_num,    -- ap_terms_lines.sequence_num
        l_due_date,     -- change for payment terms
        DECODE(l_amount_for_discount, NULL, NULL,
          DECODE(ap_terms_lines.discount_days, NULL,
            DECODE(ap_terms_lines.discount_day_of_month,
              NULL, NULL, TO_DATE(TO_CHAR(LEAST(NVL(
                 ap_terms_lines.discount_day_of_month,32),
          TO_NUMBER(TO_CHAR(LAST_DAY(ADD_MONTHS
          (P_Terms_Date,
          NVL(ap_terms_lines.discount_months_forward,0) +
          DECODE(ap_terms.due_cutoff_day, NULL, 0,
          DECODE(GREATEST(LEAST(NVL(ap_terms.due_cutoff_day, 32),
           TO_NUMBER(TO_CHAR(LAST_DAY(P_Terms_Date), 'DD'))),
           TO_NUMBER(TO_CHAR(P_Terms_Date, 'DD'))),
           TO_NUMBER(TO_CHAR(P_Terms_Date, 'DD'))
           , 1, 0)))), 'DD')))) || '-' ||
           TO_CHAR(ADD_MONTHS(P_Terms_Date,
           NVL(ap_terms_lines.discount_months_forward,0) +
          DECODE(ap_terms.due_cutoff_day, NULL, 0,
          DECODE(GREATEST(LEAST(NVL(ap_terms.due_cutoff_day, 32),
            TO_NUMBER(TO_CHAR(LAST_DAY(P_Terms_Date),'DD'))),
           TO_NUMBER(TO_CHAR(P_Terms_Date, 'DD'))),
           TO_NUMBER(TO_CHAR(P_Terms_Date, 'DD')), 1, 0))),
           'MON-RR'),'DD-MON-RR')), /*bugfix:5647464 */
           P_Terms_Date + NVL(ap_terms_lines.discount_days,0))),
        DECODE(l_amount_for_discount, NULL, NULL,
          DECODE(ap_terms_lines.discount_days_2,
          NULL,DECODE(ap_terms_lines.discount_day_of_month_2,NULL,NULL,
          TO_DATE(TO_CHAR(LEAST(
          NVL(ap_terms_lines.discount_day_of_month_2,32),
          TO_NUMBER(TO_CHAR(LAST_DAY(ADD_MONTHS(P_Terms_Date,
          NVL(ap_terms_lines.discount_months_forward_2,0) +
          DECODE(ap_terms.due_cutoff_day, NULL, 0,
          DECODE(GREATEST(LEAST(NVL(ap_terms.due_cutoff_day, 32),
           TO_NUMBER(TO_CHAR(LAST_DAY(P_Terms_Date), 'DD'))),
           TO_NUMBER(TO_CHAR(P_Terms_Date, 'DD'))),
           TO_NUMBER(TO_CHAR(P_Terms_Date, 'DD'))
           , 1, 0)))), 'DD')))) || '-' ||
           TO_CHAR(ADD_MONTHS(P_Terms_Date,
           NVL(ap_terms_lines.discount_months_forward_2,0) +
          DECODE(ap_terms.due_cutoff_day, NULL, 0,
          DECODE(GREATEST(LEAST(NVL(ap_terms.due_cutoff_day, 32),
           TO_NUMBER(TO_CHAR(LAST_DAY(P_Terms_Date),'DD'))),
           TO_NUMBER(TO_CHAR(P_Terms_Date, 'DD'))),
           TO_NUMBER(TO_CHAR(P_Terms_Date, 'DD')), 1, 0))),
           'MON-RR'),'DD-MON-RR')), /*bugfix:5647464 */
           P_Terms_Date + NVL(ap_terms_lines.discount_days_2,0))),
        DECODE(l_amount_for_discount, NULL, NULL,
          DECODE(ap_terms_lines.discount_days_3,
          NULL,DECODE(ap_terms_lines.discount_day_of_month_3,NULL,NULL,
          TO_DATE(TO_CHAR(LEAST(
          NVL(ap_terms_lines.discount_day_of_month_3,32),
          TO_NUMBER(TO_CHAR(LAST_DAY(ADD_MONTHS(P_Terms_Date,
           NVL(ap_terms_lines.discount_months_forward_3,0) +
          DECODE(ap_terms.due_cutoff_day, NULL, 0,
          DECODE(GREATEST(LEAST(NVL(ap_terms.due_cutoff_day, 32),
           TO_NUMBER(TO_CHAR(LAST_DAY(P_Terms_Date), 'DD'))),
           TO_NUMBER(TO_CHAR(P_Terms_Date, 'DD'))),
           TO_NUMBER(TO_CHAR(P_Terms_Date, 'DD'))
           , 1, 0)))), 'DD')))) || '-' ||
             TO_CHAR(ADD_MONTHS(P_Terms_Date,
           NVL(ap_terms_lines.discount_months_forward_3,0) +
          DECODE(ap_terms.due_cutoff_day, NULL, 0,
          DECODE(GREATEST(LEAST(NVL(ap_terms.due_cutoff_day, 32),
           TO_NUMBER(TO_CHAR(LAST_DAY(P_Terms_Date),'DD'))),
           TO_NUMBER(TO_CHAR(P_Terms_Date, 'DD'))),
           TO_NUMBER(TO_CHAR(P_Terms_Date, 'DD')), 1, 0))),
           'MON-RR'),'DD-MON-RR')), /*bugfix:5647464 */
           P_Terms_Date + NVL(ap_terms_lines.discount_days_3,0))),
        SYSDATE,
        P_Last_Updated_By,
        NULL,
        SYSDATE,
        P_Last_Updated_By,--bug4563272
       l_payment_cross_rate,
        DECODE(l_min_acc_unit_pay_curr,NULL,
               ROUND(P_Pay_Curr_Invoice_Amount *
                     NVL(ap_terms_lines.due_percent,0)/100,
                     l_precision_pay_curr),
               ROUND((P_Pay_Curr_Invoice_Amount *
                     NVL(ap_terms_lines.due_percent,0)/100)
                     / l_min_acc_unit_pay_curr)
               * l_min_acc_unit_pay_curr),

     --Bug 7357218 Quick Pay and Dispute Resolution Project
     --Considering absolute amount and criteria for all three discounts

    CASE
        WHEN discount_criteria IS NULL OR discount_criteria = 'H' THEN
              CASE WHEN abs(nvl(l_discount_amount,0)) > abs(l_disc_amt_by_percent) THEN
                        l_discount_amount
                   ELSE l_disc_amt_by_percent
              END
        ELSE  CASE WHEN abs(nvl(l_discount_amount,0)) < abs(l_disc_amt_by_percent) THEN
                        l_discount_amount
                   ELSE l_disc_amt_by_percent
              END
    END,
    CASE
        WHEN discount_criteria_2 IS NULL OR discount_criteria_2 = 'H' THEN
              CASE WHEN abs(nvl(l_discount_amount_2,0)) > abs(l_disc_amt_by_percent_2) THEN
                        l_discount_amount_2
                   ELSE l_disc_amt_by_percent_2
              END
        ELSE  CASE WHEN abs(nvl(l_discount_amount_2,0)) < abs(l_disc_amt_by_percent_2) THEN
                        l_discount_amount_2
                   ELSE l_disc_amt_by_percent_2
              END
    END,
    CASE
        WHEN discount_criteria_3 IS NULL OR discount_criteria_3 = 'H' THEN
              CASE WHEN abs(nvl(l_discount_amount_3,0)) > abs(l_disc_amt_by_percent_3) THEN
                        l_discount_amount_3
                   ELSE l_disc_amt_by_percent_3
              END
        ELSE  CASE WHEN abs(nvl(l_discount_amount_3,0)) < abs(l_disc_amt_by_percent_3) THEN
                        l_discount_amount_3
                   ELSE l_disc_amt_by_percent_3
              END
    END,

        DECODE(l_min_acc_unit_pay_curr,NULL,
               ROUND( P_Pay_Curr_Invoice_Amount *
                      NVL(ap_terms_lines.due_percent, 0)/100,
                          l_precision_pay_curr),
               ROUND(( P_Pay_Curr_Invoice_Amount *
                      NVL(ap_terms_lines.due_percent, 0)/100)
                      / l_min_acc_unit_pay_curr)
               * l_min_acc_unit_pay_curr),
        0,
        NVL(l_Payment_Priority,P_Payment_priority),
        'N',
        'N',
        P_Batch_Id,
        NVL(P_Payment_Method, 'CHECK'),
        /*commented for bug 5332569
          DECODE(l_orig_ext_bank_exists, 'Y',
                   l_orig_ext_bank_acct_id,        --1274099
                   ai.external_bank_account_id),  --4393358
          */

       -- Added for Bug 5332569  for inserting external_bank_account_id correctly
       DECODE(l_orig_ext_bank_exists,
                      'Y', l_orig_ext_bank_acct_id,
                       DECODE(ai.source,
                             'RECURRING INVOICE', arp.external_bank_account_id,
                               ai.external_bank_account_id)),

        ai.org_id,
        ai.remittance_message1,
        ai.remittance_message2,
        ai.remittance_message3
        --third party payments
        ,ai.remit_to_supplier_name
        ,ai.remit_to_supplier_id
        ,ai.remit_to_supplier_site
        ,ai.remit_to_supplier_site_id
	,ai.relationship_id
    FROM   ap_terms,
           ap_terms_lines,
           ap_invoices ai,
           ap_recurring_payments arp
    WHERE  ap_terms.term_id            = ap_terms_lines.term_id
      AND  ap_terms_lines.term_id      = P_Terms_Id
      AND  ap_terms_lines.sequence_num = l_sequence_num
      AND  ai.invoice_id               = P_Invoice_Id
      AND  ai.recurring_payment_id     = arp.recurring_payment_id(+);

   l_debug_info := 'l_due_date'||to_char(l_due_date,'dd-mm-yyyy')||'Insert into ap_payment_schedules : term type is percent';
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
      END IF;

   --Bug 4539462 DBI logginG
   AP_DBI_PKG.Maintain_DBI_Summary
              (p_table_name => 'AP_PAYMENT_SCHEDULES',
               p_operation => 'I',
               p_key_value1 => P_invoice_id,
               p_key_value2 => l_sequence_num,
                p_calling_sequence => current_calling_sequence);

  END LOOP;

  debug_info := 'Close c_terms';

  debug_info := 'Open cursor c_shed_total';
  OPEN  c_shed_total;
  debug_info := 'Fetch cursor c_shed_total';
  FETCH c_shed_total INTO l_pay_sched_total,
                          l_invoice_sign;

   l_debug_info := 'Fetch cursor c_shed_total'||l_pay_sched_total||'P_Pay_Curr_Invoice_Amount->'||P_Pay_Curr_Invoice_Amount; --bug 8991699
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
   END IF; --bug 8991699

  debug_info := 'Close cursor c_shed_total';
  CLOSE c_shed_total;

  -- Adjust Payment Schedules for rounding errors

  IF (l_pay_sched_total <> P_Pay_Curr_Invoice_Amount) THEN

    l_debug_info := 'Update ap_payment_schedules - set gross_amount->P_Pay_Curr_Invoice_Amount:'||P_Pay_Curr_Invoice_Amount||
    'l_pay_sched_total->'||l_pay_sched_total; --bug 8991699
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
      END IF; --bug 8991699

    UPDATE AP_PAYMENT_SCHEDULES
       SET gross_amount     = gross_amount +
                              TO_NUMBER(P_Pay_Curr_Invoice_Amount) -
                              TO_NUMBER(l_pay_sched_total),
           amount_remaining = amount_remaining +
                              TO_NUMBER(P_Pay_Curr_Invoice_Amount) -
                              TO_NUMBER(l_pay_sched_total)
      WHERE invoice_id = P_Invoice_Id
        AND payment_num = (SELECT  MAX(payment_num)
                             FROM  ap_payment_schedules
                            WHERE  invoice_id = P_Invoice_Id);
    END IF;
  END IF;

  debug_info := 'Close cursor c_terms_percent';
  CLOSE c_terms_percent;

  debug_info := 'Update ap_payment_schedules - set discount amounts';

  UPDATE ap_payment_schedules
     SET discount_amount_available = DECODE(discount_date, '', '',
                                            discount_amount_available),
         second_disc_amt_available = DECODE(second_discount_date, '', '',
                                            second_disc_amt_available),
         third_disc_amt_available  = DECODE(third_discount_date, '', '',
                                            third_disc_amt_available)
   WHERE invoice_id = P_Invoice_Id
   RETURNING payment_num
   BULK COLLECT INTO l_dbi_key_value_list2;

  --Bug 4539462 DBI logging
  AP_DBI_PKG.Maintain_DBI_Summary
              (p_table_name => 'AP_PAYMENT_SCHEDULES',
               p_operation => 'U',
               p_key_value1 => P_invoice_id,
               p_key_value_list => l_dbi_key_value_list2,
                p_calling_sequence => current_calling_sequence);


  -- Change for cross currency
  -- Populate the inv_curr_gross_amount

  l_debug_info := 'Update ap_payment_schedules - set inv_curr_gross_amount'; --bug 8991699
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
  END IF; --bug 8991699

  IF l_min_acc_unit_inv_curr IS NULL THEN
    UPDATE ap_payment_schedules
       SET inv_curr_gross_amount = ROUND(gross_amount/P_Payment_Cross_Rate,
                                         l_precision_inv_curr)
     WHERE invoice_id = P_Invoice_Id;
  ELSE
    UPDATE ap_payment_schedules
       SET inv_curr_gross_amount = (ROUND(gross_amount/P_Payment_Cross_Rate
                                         /l_min_acc_unit_inv_curr)
                                         * l_min_acc_unit_inv_curr)
     WHERE invoice_id = P_Invoice_Id;
  END IF;

/*
  UPDATE ap_payment_schedules
  SET    inv_curr_gross_amount = (
                   SELECT   DECODE(F.minimum_accountable_unit,NULL,
                             ROUND( gross_amount / P_Payment_Cross_Rate
                                      , F.precision),
                               ROUND( gross_amount / P_Payment_Cross_Rate
                                      /F.minimum_accountable_unit)
                                * F.minimum_accountable_unit)
                   FROM   fnd_currencies F
                   WHERE  F.currency_code = P_Invoice_Currency)
  WHERE  invoice_id = P_Invoice_Id;
 */
                                                                        --
  -- Change for cross currency
  -- Adjust inv_curr_gross_amount for rounding error
                                                                         --
  debug_info := 'Open cursor c_inv_curr_sched_total';
  OPEN  c_inv_curr_sched_total;
  debug_info := 'Fetch cursor c_inv_curr_sched_total';
  FETCH c_inv_curr_sched_total INTO l_inv_curr_sched_total,
                                    l_invoice_sign;
  debug_info := 'Close cursor c_inv_curr_sched_total';
  CLOSE c_inv_curr_sched_total;


  l_debug_info := 'Update ap_payment_schedules - set inv_curr_gross_amount:P_Invoice_Amount->'||P_Invoice_Amount||
    'l_inv_curr_sched_total->'||l_inv_curr_sched_total; --bug 8991699
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name,l_debug_info);
    END IF; --bug 8991699

  --bug 8991699 begins
  l_retained_amount := nvl(abs(ap_invoices_utility_pkg.get_retained_total
                               (P_Invoice_Id,NULL)),0);

  Select nvl(net_of_retainage_flag,'N')
    into l_net_of_ret_flag
   from ap_invoices
   where invoice_id = P_Invoice_Id;

  --This procedure is called either during the time of recalculating
  --schedules or when invoice amount is updated as per fix 8891266.
  --Hence l_inv_curr_sched_total will always be net of retainage at this
  --point. Thus adding retainage back so that the following update happens
  --only when there is actual rounding issue and due to which the amount
  --doesn't match with invoice amount.

  If l_net_of_ret_flag = 'N' and l_retained_amount > 0 then
    l_inv_curr_sched_total := l_inv_curr_sched_total + l_retained_amount;
  END if;
  --bug 8991699 ends

  -- Adjust inv_curr_gross_amount for rounding errors

  IF (l_inv_curr_sched_total <> P_Invoice_Amount) THEN

    debug_info := 'Update ap_payment_schedules - set inv_curr_gross_amount';

    UPDATE AP_PAYMENT_SCHEDULES
       SET inv_curr_gross_amount = inv_curr_gross_amount +
                                   TO_NUMBER(P_Invoice_Amount) -
                                   TO_NUMBER(l_inv_curr_sched_total)
     WHERE invoice_id = P_Invoice_Id
       AND payment_num = (SELECT  MAX(payment_num)
                            FROM  ap_payment_schedules
                           WHERE  invoice_id = P_Invoice_Id);
    END IF;


  ap_invoices_pkg.validate_docs_payable(p_INVOICE_ID,null,l_hold_flag);



  EXCEPTION
    WHEN OTHERS THEN
      IF (SQLCODE <> -20001) THEN
        FND_MESSAGE.SET_NAME('SQLAP', 'AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR', SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', current_calling_sequence);
        FND_MESSAGE.SET_TOKEN('PARAMETERS', 'Invoice_Id = '||P_Invoice_Id
                ||', Terms_Id = '            ||P_Terms_Id
                ||', Last_Updated_By = '     ||P_Last_Updated_By
                ||', Created_By = '          ||P_Created_By
                ||', Payment_Priority = '    ||P_Payment_Priority
                ||', Batch_Id = '            ||P_Batch_Id
                ||', Terms_Date = '          ||P_Terms_Date
                ||', Invoice_Amount = '      ||P_Invoice_Amount
                ||', Amount_for_discount = ' ||P_Amount_For_Discount
                ||', Payment_Method = '      ||P_Payment_Method
                ||', Currency = '            ||P_invoice_currency
              );
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO', debug_info);
      END IF;
      APP_EXCEPTION.RAISE_EXCEPTION;

END AP_Create_From_Terms;

END AP_CREATE_PAY_SCHEDS_PKG;

/

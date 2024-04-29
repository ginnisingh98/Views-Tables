--------------------------------------------------------
--  DDL for Package Body FV_ECON_BENF_DISC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FV_ECON_BENF_DISC_PVT" AS
-- $Header: FVAPEBDB.pls 120.12.12010000.3 2009/05/28 18:47:33 schakkin ship $
  g_module_name VARCHAR2(100) := 'fv.plsql.FV_ECON_BENF_DISC_PVT.';
  g_org_id	number;
  g_sob		number;

Function PAYDT_BEFORE_DISCDT(X_Payment_Date IN DATE,
			     X_Discount_Date IN DATE)RETURN BOOLEAN IS
  l_module_name VARCHAR2(200) := g_module_name || 'PAYDT_BEFORE_DISCDT';
  l_errbuf VARCHAR2(1024);
Begin
     If  X_Payment_Date <= X_Discount_Date  then
            RETURN TRUE;
     Else
            RETURN FALSE;
     End If;
EXCEPTION
  WHEN OTHERS THEN
    l_errbuf := SQLERRM;
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',l_errbuf);
    RAISE;
End  PAYDT_BEFORE_DISCDT;
/*----------------------------------------------*/
Function  ROW_EXISTS(X_Invoice_Id IN NUMBER,
                     X_Err_Num OUT NOCOPY NUMBER,
                     X_Err_Stage OUT NOCOPY VARCHAR2) RETURN BOOLEAN  IS
  l_module_name VARCHAR2(200) := g_module_name || 'ROW_EXISTS';
   Inv_Nbr NUMBER(15);
 BEGIN
   BEGIN
      select invoice_id
      into
      Inv_Nbr
      from FV_DISCOUNTED_INVOICES
      where
      invoice_id = X_Invoice_Id;
                X_Err_Num := 0;

                RETURN TRUE;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
           X_Err_Num := 1;
           X_Err_Stage := 'No row found for Invoice '||to_char(X_Invoice_Id);
           FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name||'.error1',X_Err_Stage);
           RETURN FALSE;
      WHEN TOO_MANY_ROWS THEN
            X_Err_Num := 2;
            X_Err_Stage := 'There is more than one row for the Invoice '||to_char(X_Invoice_Id);
            FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name||'.error2',X_Err_Stage);
            RETURN FALSE;
      WHEN OTHERS THEN
        X_Err_Stage := SQLERRM;
        FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',X_Err_Stage);
        RAISE;
  END;
End ROW_EXISTS;
/*-----------------------------------------------------------------*/
-- Version 1.3.2  Added ROW_EXISTS for FV_ASSIGN_REASON_CODES  RCW.
/*-----------------------------------------------------------------*/
Function  ROW_EXISTS_FVRC(X_Invoice_Id IN NUMBER,
                     X_Err_Num OUT NOCOPY NUMBER,
                     X_Err_Stage OUT NOCOPY VARCHAR2) RETURN BOOLEAN  IS
  l_module_name VARCHAR2(200) := g_module_name || 'ROW_EXISTS_FVRC';
   Inv_id NUMBER(15);
   ent_source VARCHAR2(15);
 BEGIN
   BEGIN
      select invoice_id, entry_source
      into
      Inv_id, ent_source
      from FV_ASSIGN_REASON_CODES
      where
      invoice_id = X_Invoice_Id
      and entry_source = 'EBD';
                X_Err_Num := 0;

                RETURN TRUE;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
             X_Err_Num := 1;
             X_Err_Stage := 'No row found for Invoice '||to_char(X_Invoice_Id);
             FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name||'.error1',X_Err_Stage);
                      RETURN FALSE;
        WHEN TOO_MANY_ROWS THEN
              X_Err_Num := 2;
              X_Err_Stage := 'There is more than one row for the FVRC Invoice '||to_char(X_Invoice_Id);
              FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name||'.error1',X_Err_Stage);
                      RETURN FALSE;
        WHEN OTHERS THEN
          X_Err_Stage := SQLERRM;
          FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',X_Err_Stage);
          RAISE;
   END;
End ROW_EXISTS_FVRC;
/*------------- END 1.3.2 --------------------------------*/

Procedure CALCULATE_DISCOUNT(X_Invoice_Id IN NUMBER,
                 X_Discount_Amount IN NUMBER,
                 X_Invoice_Amount   IN NUMBER,
                 X_Due_Date IN OUT NOCOPY DATE,
                 X_Discount_Date IN OUT NOCOPY DATE,
                 X_Terms_Date  IN DATE,
                 X_Invoice_Date IN DATE,
                 X_Invoice_Received_Date IN DATE,
                 X_Goods_Received_Date IN DATE,
                 X_Effective_Discount_Rate IN OUT NOCOPY NUMBER,
                 X_Err_Num OUT NOCOPY NUMBER,
                 X_Err_Stage OUT NOCOPY VARCHAR2) IS
  l_module_name VARCHAR2(200) := g_module_name || 'CALCULATE_DISCOUNT';
         Discount_Pct  NUMBER;
         Days_In_Year NUMBER := 360;
         Due_Days    NUMBER;
         Total_Disc_Days NUMBER;
         Days_Left_In_Disc_Period  NUMBER;
BEGIN


  Discount_Pct := (X_Discount_Amount / X_Invoice_Amount);

 /* To check whether any changes made to original due date,if so
    using the orginal due date from fv_inv_selected_duedate */
 /*
 begin
    select org_due_date,org_discount_date
      into x_due_date ,x_discount_date
      from fv_inv_selected_duedate
    where invoice_id = x_invoice_id;
 exception
   when no_data_found then
   null;
   when too_many_rows then
   null;
 End ;
  commenting for bug#8550230 */

         ------------------------------------

   Due_days := TRUNC(X_Due_Date) - TRUNC(NVL(X_Invoice_Received_Date,X_Invoice_date));
    -- No. Of days for Payment Due
 Total_Disc_Days :=  TRUNC(X_Discount_Date) - TRUNC(X_Invoice_date);
    -- Total No. Of Days of Discount
Days_Left_In_Disc_Period :=Total_Disc_Days -(TRUNC(NVL(X_Invoice_Received_Date,					X_Invoice_date)) - TRUNC(X_Invoice_date));

-- Bug 5486026 (R12.FIN.A.QA.XB.9X: ERROR WHILE SUBMITING A PAYMENT PROCESS REQUEST)
-- This was caused by divide by zero error when discount_amount = invoice_amount
-- and therefore Discount_Pct = 1.  This is a limiting case and in this case we
-- hardcode the discount rate to a very high value so that the invoice is included
-- for payment

IF ((Due_days - Days_Left_In_Disc_Period) <> 0 AND (1 - Discount_Pct) <> 0) THEN
 X_Effective_Discount_Rate  := 100*((Discount_Pct / (1 - Discount_Pct)) *
                  (Days_In_Year / (Due_days - Days_Left_In_Disc_Period)));

ELSIF ((Due_days - Days_Left_In_Disc_Period) = 0 AND (1 - Discount_Pct) <> 0) THEN
 X_Effective_Discount_Rate  := 100*(Discount_Pct / (1 - Discount_Pct));
ELSE -- (1 - Discount_Pct) = 0
 X_Effective_Discount_Rate  := 10000;
END IF;


  X_Err_Num := 0;
EXCEPTION
    WHEN ZERO_DIVIDE THEN
         X_Err_Num := 2;
         X_Err_Stage := 'There has been a division by ZERO while processing Invoice '||to_char(X_Invoice_Id);
         FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name||'.error1',X_Err_Stage);
    WHEN OTHERS THEN
         X_Err_Num := SQLCODE;
         X_Err_Stage := SQLERRM;
         FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',X_Err_Stage);
End CALCULATE_DISCOUNT;
/*---------------------------------------------*/

Procedure INSERT_FV_DISCOUNTED_INVOICES(X_Invoice_Id              IN NUMBER,
                                        X_Discount_Taken_Flag     IN VARCHAR2,
                                        X_Discount_Status_Code    IN VARCHAR2,
                                        X_Payment_Date            IN DATE,
                                        X_Effective_Discount_Rate IN NUMBER,
                                        X_CVOF_Rate               IN NUMBER,
                                        X_Err_Num                 OUT NOCOPY NUMBER,
                                        X_Err_Stage               OUT NOCOPY VARCHAR2) IS
   PRAGMA AUTONOMOUS_TRANSACTION; --bug 5705668, AP Autoselect process uses EBD_CHECK as where clause of a query, which raised error. Hence made this as Autonomous
  l_module_name VARCHAR2(200) := g_module_name || 'INSERT_FV_DISCOUNTED_INVOICES';
Begin
      BEGIN
          INSERT INTO
          FV_DISCOUNTED_INVOICES(Invoice_Id,
                                 Last_Update_Date,
			         Last_Updated_By ,
                                 Last_Update_Login,
                                 Creation_Date ,
                                 Created_By ,
                                 Discount_Taken_Flag ,
                                 Payment_Date ,
 	                         Effective_Discount_Percent,
                                 CURR_VALUE_OF_FUNDS_PERCENT ,
                                 Discount_Status_Code,
                                 Request_Id,
                                 Program_Application_Id,
                                 Program_Id,
                                 Program_Update_Date)
           VALUES(X_Invoice_Id ,
                  SYSDATE,
                  FND_GLOBAL.USER_ID,
                  FND_GLOBAL.LOGIN_ID,
                  SYSDATE ,
                  FND_GLOBAL.USER_ID,
                  X_Discount_Taken_Flag ,
                  X_Payment_Date ,
                  X_Effective_Discount_Rate ,
                  X_CVOF_Rate,
                  X_Discount_Status_Code,
                  FND_GLOBAL.CONC_REQUEST_ID,
                  FND_GLOBAL.PROG_APPL_ID,
                  FND_GLOBAL.CONC_PROGRAM_ID,
                  SYSDATE );
             COMMIT; --bug 5705668

             X_Err_Num :=  0;
                  EXCEPTION
                     WHEN DUP_VAL_ON_INDEX THEN
                             X_Err_Num := 2;
                             X_Err_Stage := 'Row already exists for the Invoice '||to_char(X_Invoice_Id)||'. Hence Insert failed';
                             FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.error1',X_Err_Stage);
                     WHEN OTHERS THEN
                             X_Err_Num := SQLCODE;
                             X_Err_Stage := 'Insert Failed '||SQLERRM;
                             FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',X_Err_Stage);
      END;
END INSERT_FV_DISCOUNTED_INVOICES;

/*-----------------------------------------------------------------*/
-- Version 1.2  Added Procedure INSERT_FV_ASSIGN_REASON_CODES  RCW.
/*------------------------------------------------------------------*/
Procedure INSERT_FV_ASSIGN_REASON_CODES(X_Invoice_Id   IN NUMBER,
                                        x_Batch_Name     IN VARCHAR2,
				        X_Err_Num      OUT NOCOPY NUMBER,
                                        X_Err_Stage    OUT NOCOPY VARCHAR2) IS

  PRAGMA AUTONOMOUS_TRANSACTION; --bug 5705668, AP Autoselect process uses EBD_CHECK as where clause of a query, which raised error. Hence made this as Autonomous
  l_module_name VARCHAR2(200) := g_module_name || 'INSERT_FV_ASSIGN_REASON_CODES';
--   v_sob     number; --global variable
--   v_sob_name VARCHAR2(50);
/*--------------------------------------------------*/
-- Version 1.4  RCW.
/*--------------------------------------------------*/
--   v_org_id  number; --global variable
/*--  end 1.4 RCW  --------------------------------*/

Begin
  IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'Starting insert_fv_assign_reason_codes');
  END IF;

/*--------------------------------------------------*/
-- Version 1.4  RCW.
/*--------------------------------------------------*/
--LA Uptake
--   v_org_id  := to_number(fnd_profile.Value('ORG_ID'));
--     v_org_id := MO_GLOBAL.get_current_org_id; --global variable

/*--------------------------------------------------*/
-- Version 1.4  RCW.
/*-------------------------------------------------*/
--LA Uptake
--  v_sob      := to_number(fnd_profile.Value('GL_SET_OF_BKS_ID'));
--    MO_UTILS.get_ledger_info(v_org_id,v_sob,v_sob_name); --global variable


/*--  end 1.4 RCW  -------------------------------*/


      BEGIN
          INSERT INTO FV_ASSIGN_REASON_CODES(Invoice_Id,
					Set_of_Books_Id,
	/*--------------------------------------------------*/
	-- Version 1.4  RCW.
	/*--------------------------------------------------*/
   				      Org_id,
	/*--  end 1.4 RCW  -------------------------------*/
					Entry_Mode,
					Entry_Source,
					Checkrun_name,
                    Last_Update_Date,
                    Last_Updated_By,
                    Last_Update_Login,
                    Creation_Date,
                    Created_By)
           VALUES(X_Invoice_Id ,
		          g_sob,
	/*--------------------------------------------------*/
	-- Version 1.4  RCW.
	/*--------------------------------------------------*/
   	              g_org_id,
	/*--  end 1.4 RCW  -------------------------------*/
		         'SYSTEM',
                 'EBD',
                 x_Batch_Name,
                 SYSDATE,
                 FND_GLOBAL.USER_ID,
                 FND_GLOBAL.LOGIN_ID,
                 SYSDATE,
                 FND_GLOBAL.USER_ID
                  );
       COMMIT; --Bug 5705668
            X_Err_Num :=  0;
       EXCEPTION
          WHEN DUP_VAL_ON_INDEX THEN
            X_Err_Num := 2;
            X_Err_Stage := 'Row already exists for the Invoice '||to_char(X_Invoice_Id)||'.
						Insert failed';
            FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name||'.error1',X_Err_Stage);
         WHEN OTHERS THEN
                             X_Err_Num := SQLCODE;
                             X_Err_Stage := 'Insert Failed '||SQLERRM;
         FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.exception1',X_Err_Stage);
      END;
EXCEPTION
  WHEN OTHERS THEN
    X_Err_Num := SQLCODE;
    X_Err_Stage := SQLERRM;
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',X_Err_Stage);
END INSERT_FV_ASSIGN_REASON_CODES;

/*-----------  end 1.2  RCW  ----------------------------------------*/

Procedure DELETE_FV_DISCOUNTED_INVOICES(X_Invoice_Id IN NUMBER,
                                 X_Err_Num OUT NOCOPY NUMBER,
                                 X_Err_Stage OUT NOCOPY VARCHAR2) IS

  PRAGMA AUTONOMOUS_TRANSACTION; --bug 5705668, AP Autoselect process uses EBD_CHECK as where clause of a query, which raised error. Hence made this as Autonomous
  l_module_name VARCHAR2(200) := g_module_name || 'DELETE_FV_DISCOUNTED_INVOICES';
Begin
          delete from FV_DISCOUNTED_INVOICES
          where
           invoice_id = X_Invoice_Id;
        COMMIT; --Bug 5705668
        X_Err_Num := 0;
             If SQL%ROWCOUNT = 0 then
                X_Err_Num := 1;
                X_Err_Stage := 'There were no rows deleted from FV_DISCOUNTED_INVOICES for the Invoice '||to_char(X_Invoice_Id);
                FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name||'.error1',X_Err_Stage);
             End If;
EXCEPTION
  WHEN OTHERS THEN
    X_Err_Num := SQLCODE;
    X_Err_Stage := SQLERRM;
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',X_Err_Stage);
End DELETE_FV_DISCOUNTED_INVOICES;

/*-----------------------------------------------------------------------*/

Procedure UPDATE_FV_DISCOUNTED_INVOICES(X_Invoice_Id IN NUMBER,
                                        X_Payment_Date IN DATE,
						    X_Err_Num OUT NOCOPY NUMBER,
                                        X_Err_Stage OUT NOCOPY VARCHAR2) IS
  PRAGMA AUTONOMOUS_TRANSACTION; --bug 5705668, AP Autoselect process uses EBD_CHECK as where clause of a query, which raised error. Hence made this as Autonomous

  l_module_name VARCHAR2(200) := g_module_name || 'UPDATE_FV_DISCOUNTED_INVOICES';
   Existing_Flag VARCHAR2(1);

 Begin
      select discount_taken_flag
        into Existing_Flag
        from FV_DISCOUNTED_INVOICES
       where Invoice_Id = X_Invoice_Id;

         If Existing_Flag = 'N' then
            update FV_DISCOUNTED_INVOICES
            set Payment_Date = X_Payment_Date,
                Last_Update_Date = SYSDATE,
                Last_Updated_By = FND_GLOBAL.USER_ID,
                Last_Update_Login = FND_GLOBAL.LOGIN_ID
            where Invoice_Id   = X_Invoice_Id;

         Elsif Existing_Flag = 'Y' then
            update FV_DISCOUNTED_INVOICES
            set Payment_Date = X_Payment_Date,
                Discount_Taken_Flag = 'N',
                Effective_Discount_Percent = NULL,
                Curr_Value_Of_Funds_Percent = NULL,
                Discount_Status_Code = 'PAYMENT_DATE_PAST',
                Last_Update_Date = SYSDATE,
                Last_Updated_By = FND_GLOBAL.USER_ID,
                Last_Update_Login = FND_GLOBAL.LOGIN_ID
            where Invoice_Id   = X_Invoice_Id;


	  End If;
          COMMIT; --bug 5705668
 	  X_Err_Num := 0;
          If SQL%NOTFOUND THEN
             X_Err_Num := 1;
             X_Err_Stage := 'There were no rows updated for the Invoice '||to_char(X_Invoice_Id);
             FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name||'.error1',X_Err_Stage);
          End If;


EXCEPTION
  WHEN OTHERS THEN
    X_Err_Num := SQLCODE;
    X_Err_Stage := SQLERRM;
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',X_Err_Stage);
 End UPDATE_FV_DISCOUNTED_INVOICES;

/*-----------------------------------------------------------------*/
-- Version 1.2  Added Procedure UPDATE_FV_ASSIGN_REASON_CODES  RCW.
/*------------------------------------------------------------------*/
 Procedure UPDATE_FV_ASSIGN_REASON_CODES(X_Invoice_Id IN NUMBER,
                                        x_Batch_Name IN VARCHAR2,
            						    X_Err_Num OUT NOCOPY NUMBER,
                                        X_Err_Stage OUT NOCOPY VARCHAR2) IS

  PRAGMA AUTONOMOUS_TRANSACTION; --bug 5705668, AP Autoselect process uses EBD_CHECK as where clause of a query, which raised error. Hence made this as Autonomous

  l_module_name VARCHAR2(200) := g_module_name || 'UPDATE_FV_ASSIGN_REASON_CODES';
 Begin

       update FV_ASSIGN_REASON_CODES
         set Checkrun_name = x_Batch_Name,
		 Entry_mode = 'SYSTEM',
             Last_Update_Date = SYSDATE,
             Last_Updated_By = FND_GLOBAL.USER_ID,
             Last_Update_Login = FND_GLOBAL.LOGIN_ID
       where
       Invoice_Id   = X_Invoice_Id
	  and Entry_Source = 'EBD';

   COMMIT; --Bug 5705668

	X_Err_Num := 0;
        If SQL%NOTFOUND THEN
           IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
             FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'1-No rows in fv_assign_reason_codes');
           END IF;
           X_Err_Num := 1;
           X_Err_Stage := 'There were no rows updated for the Invoice '||to_char(X_Invoice_Id);
           FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name||'.error1',X_Err_Stage);
        End If;


EXCEPTION
  WHEN OTHERS THEN
    X_Err_Num := SQLCODE;
    X_Err_Stage := SQLERRM;
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',X_Err_Stage);
 End UPDATE_FV_ASSIGN_REASON_CODES;
/*-----------  end 1.2  RCW  ----------------------------------------*/


/*--------------------------------------------------------------------*/
Procedure GET_CVOF_RATE(X_Payment_Date IN DATE,
		        X_CVOF_Rate IN OUT NOCOPY NUMBER,
                        X_Err_Num OUT NOCOPY NUMBER,
                        X_Err_Stage OUT NOCOPY VARCHAR2) IS
  l_module_name VARCHAR2(200) := g_module_name || 'GET_CVOF_RATE';
 X_Current_Value_Of_Funds_Rate     NUMBER;
BEGIN
       select CURR_VALUE_OF_FUNDS_PERCENT
         into X_Current_Value_Of_Funds_Rate
         from fv_value_of_fund_periods
        where trunc(X_Payment_Date) between trunc(effective_start_date)
                     and trunc(nvl(effective_end_date, X_Payment_Date));

        X_CVOF_Rate := X_Current_Value_Of_Funds_Rate;
        X_Err_Num := 0;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    X_Err_Num := 1;
    X_Err_Stage := 'No CVOF Rate available for the Payment Date '||to_char(X_Payment_Date);
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name||'.error1',X_Err_Stage);
  WHEN OTHERS THEN
    X_Err_Num := SQLCODE;
    X_Err_Stage := SQLERRM;
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',X_Err_Stage);
END GET_CVOF_RATE;
/*-----------------------------------------------------------------*/
FUNCTION EBD_CHECK(x_batch_name IN VARCHAR2,
                   x_invoice_id IN NUMBER,
                   x_check_date IN DATE,
                   x_inv_due_date   IN DATE,
                   x_discount_amount IN NUMBER,
                   x_discount_date IN DATE) RETURN CHAR AS

--  This function will return 'N' if the invoice should NOT be included in this
--  batch because it is not economically beneficial.  Otherwise, 'Y' will be
--  returned to include the invoice.

  l_module_name VARCHAR2(200) := g_module_name || 'EBD_CHECK';
  l_discount_date DATE;
-- we are removing ap_payment_schedules from this join because this is called in
-- a update statement by AP where they are updating ap_payment_schedules,
-- this is causing some problems. See bug 4745133.
-- Instead AP will pass the discount_amount and discount_date parameters
-- and we will refrain from joining with ap_payment_schedules.

cursor c1 is
 select
    ai.invoice_amount,
    ai.invoice_date,
    ai.invoice_received_date,
    ai.goods_received_date,
    ai.org_id,
    ai.set_of_books_id,
    ai.terms_date,
    --aps.discount_amount_available, --Now passed as parameter
    --aps.discount_date, --Now passed as parameter
    ftt.terms_type
 from
 FV_TERMS_TYPES ftt,
 AP_INVOICES ai
-- AP_PAYMENT_SCHEDULES aps
 where
 ftt.term_id = ai.terms_id and
 ai.invoice_id = x_invoice_id and
--aps.invoice_id = ai.invoice_id and
-- aps.discount_amount_available > 0;
 x_discount_amount > 0;

 err_message varchar2(5000);
 /* Fetch Variables for Cursor c1 */
 X_Invoice_Num		 AP_INVOICES_ALL.INVOICE_NUM%TYPE;
 X_Invoice_Amount        AP_INVOICES_ALL.INVOICE_AMOUNT%TYPE;
 X_Invoice_Date          AP_INVOICES_ALL.INVOICE_DATE%TYPE;
 X_Invoice_Received_Date AP_INVOICES_ALL.INVOICE_RECEIVED_DATE%TYPE;
 X_Goods_Received_Date   AP_INVOICES_ALL.GOODS_RECEIVED_DATE%TYPE;
 X_Terms_Date            AP_INVOICES_ALL.TERMS_DATE%TYPE;
/*-------------Comments----------------------------------------------
 X_Discount_Amount       AP_PAYMENT_SCHEDULES.DISCOUNT_AMOUNT_AVAILABLE%TYPE;
 X_Discount_Date         AP_PAYMENT_SCHEDULES.DISCOUNT_DATE%TYPE;
--------------End of Comments---------------------------------------*/
 x_Due_Date		 AP_SELECTED_INVOICES.DUE_DATE%TYPE;
 X_Payment_Date            DATE;
 X_Effective_Discount_Rate FV_DISCOUNTED_INVOICES.EFFECTIVE_DISCOUNT_PERCENT%TYPE;
 X_CVOF_Rate               FV_VALUE_OF_FUND_PERIODS.CURR_VALUE_OF_FUNDS_PERCENT%TYPE;
 X_terms_type              FV_TERMS_TYPES.TERMS_TYPE%TYPE;
 X_Err_Nbr                 NUMBER ;
 X_Err_Stage               VARCHAR2(120);
--MOAC  changes: Removed the org_id parameter in the call to FV_INSTALL.enabled
-- x_org_id number := to_number(fnd_profile.value('ORG_ID'));
 v_fv_enabled 		BOOLEAN;
 errbuf varchar2(1000);
 retcode varchar2(2);
Begin

select invoice_num
into X_Invoice_Num
from ap_invoices_all
where invoice_id = X_Invoice_id;

--MOAC  changes: Removed the org_id parameter in the call to FV_INSTALL.enabled
v_fv_enabled := fv_install.enabled; -- check if FV is enabled

IF v_fv_enabled then
 -- FV is enabled continue with code

 open c1;

-- get the org and set of books from invoice id instead of getting org from current org and then finding set
-- of books from that org

 LOOP
  FETCH c1 into
        X_Invoice_Amount,
        X_Invoice_Date,
        X_Invoice_Received_Date,
        X_Goods_Received_Date,
        g_org_id,
        g_sob,
        X_Terms_Date,
  --    X_Discount_Amount,
  --    X_Discount_Date,
	    X_Terms_Type;
  EXIT when c1%NOTFOUND;

   /*Initialization of Variables */
   X_Effective_Discount_Rate := 0;
   X_CVOF_Rate               := 0;

   /* Assigning Check date to Payment Date */
   X_Payment_Date := X_Check_Date;

   /* Assigned Invoice due date to variable x_due_date */
   x_due_date := trunc(x_inv_due_date);

 IF PAYDT_BEFORE_DISCDT(X_Payment_Date,X_Discount_Date) then --2nd If

   If ROW_EXISTS(X_Invoice_Id,X_Err_Nbr,X_Err_Stage) then   -- 4th If

      DELETE_FV_DISCOUNTED_INVOICES(X_Invoice_Id, X_Err_Nbr, X_Err_Stage);
                                        RETCODE := to_char(X_Err_Nbr);
                                        ERRBUF  := X_Err_Stage;
   Else
      If X_Err_Nbr = 2 then
         err_message := x_err_stage;
         fnd_message.set_name('FV','FV_FAI_GENERAL');
         fnd_message.set_token('msg',err_message);
         IF ( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           FV_UTILITY.MESSAGE(FND_LOG.LEVEL_ERROR, l_module_name);
         END IF;
         app_exception.raise_exception;
      End If;
   End If ; -- End of 4th If
 --IN parameter x_discount_date cannot be used as a target of an assignment hence
 --local variable l_discount_date passed to x_discount_date in CALCULATE_DISCOUNT
 --which is defined as IN OUT parameter in CALCULATE_DISCOUNT.
 l_discount_date:=x_discount_date;

   CALCULATE_DISCOUNT(X_Invoice_Id,
                      X_Discount_Amount,
                      X_Invoice_Amount,
                      X_Due_Date,
                      l_discount_date,
                      X_Terms_Date,
                      X_Invoice_Date,
                      X_Invoice_Received_Date,
                      X_Goods_Received_Date,
                      X_Effective_Discount_Rate,
                      X_Err_Nbr,
                      X_Err_Stage);
    RETCODE := to_char(X_Err_Nbr);
    ERRBUF  := X_Err_Stage;
    If ((X_Err_Nbr = 2) or (X_Err_Nbr < 0))  then
       err_message := x_err_stage;
       fnd_message.set_name('FV','FV_FAI_GENERAL');
       fnd_message.set_token('msg',err_message);
       IF ( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FV_UTILITY.MESSAGE(FND_LOG.LEVEL_ERROR, l_module_name);
       END IF;
       app_exception.raise_exception;
    End If;

          /* Get the CVOF Rate */
   GET_CVOF_RATE(X_Payment_Date ,
                 X_CVOF_Rate,
                 X_Err_Nbr,
                 X_Err_Stage);
   RETCODE := to_char(X_Err_Nbr);
   ERRBUF  := X_Err_Stage;
   If X_Err_Nbr <> 0 then -- 5th If
           /* CVOF Rate was unavailable for the given Date range*/
        INSERT_FV_DISCOUNTED_INVOICES(X_Invoice_Id,
                                      'Y',
                                      'CVOF_RATE_UNAVAILABLE',
                                      X_Payment_Date,
                                      X_Effective_Discount_Rate,
                                      X_CVOF_Rate,
                                      X_Err_Nbr ,
                                      X_Err_Stage);
         RETCODE := to_char(X_Err_Nbr);
         ERRBUF  := X_Err_Stage;
         If ((X_Err_Nbr = 2) or (X_Err_Nbr < 0)) then
              err_message := x_err_stage;
              fnd_message.set_name('FV','FV_FAI_GENERAL');
              fnd_message.set_token('msg',err_message);
              IF ( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FV_UTILITY.MESSAGE(FND_LOG.LEVEL_ERROR, l_module_name);
              END IF;
              app_exception.raise_exception;
         End If;
   Else
          /* CVOF Rate Available */
          /* Disc_Rate less than CVOF Rate */
      If X_Effective_Discount_Rate <= X_CVOF_Rate then
         /* Insert invoice into FV_DISCOUNTED_INVOICES */
         INSERT_FV_DISCOUNTED_INVOICES(X_Invoice_Id,
                                      'N',
                                      'NOT_EBD',
                                      X_Payment_Date,
                                      X_Effective_Discount_Rate,
                                      X_CVOF_Rate,
                                      X_Err_Nbr ,
                                      X_Err_Stage);
         RETCODE := to_char(X_Err_Nbr);
         ERRBUF  := X_Err_Stage;
         If ((X_Err_Nbr = 2) or (X_Err_Nbr < 0)) then
            err_message := x_err_stage;
            fnd_message.set_name('FV','FV_FAI_GENERAL');
            fnd_message.set_token('msg',err_message);
            IF ( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FV_UTILITY.MESSAGE(FND_LOG.LEVEL_ERROR, l_module_name);
            END IF;
            app_exception.raise_exception;
         End If;

         -- This invoice does not meet the EBD requirements so do NOT include
         FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name, 'Invoice Number, '||x_invoice_num||', will NOT be included in the Payment Batch because it');
         FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name, 'does not meet EBD Requirements.');
         RETURN 'N';


      Elsif X_Effective_Discount_Rate > X_CVOF_Rate then
          /* Disc_Rate greater than CVOF Rate */
          INSERT_FV_DISCOUNTED_INVOICES(X_Invoice_Id,
                                        'Y',
                                        NULL,
                                        X_Payment_Date,
                                        X_Effective_Discount_Rate,
                                        X_CVOF_Rate,
                                        X_Err_Nbr ,
                                        X_Err_Stage);
           RETCODE := to_char(X_Err_Nbr);
            ERRBUF  := X_Err_Stage;
           If ((X_Err_Nbr = 2) or (X_Err_Nbr < 0)) then
              err_message := x_err_stage;
              fnd_message.set_name('FV','FV_FAI_GENERAL');
              fnd_message.set_token('msg',err_message);
              IF ( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FV_UTILITY.MESSAGE(FND_LOG.LEVEL_ERROR, l_module_name);
              END IF;
              app_exception.raise_exception;
           End If;
       End If;
   End If; -- End of 5th If

 Else
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name, 'Payment Date is after Discount Date');

       /* Payment Date after Discount Date */
   If ROW_EXISTS(X_Invoice_Id,X_Err_Nbr,X_Err_Stage) then    --3rd If
      UPDATE_FV_DISCOUNTED_INVOICES(X_Invoice_Id,X_Payment_Date,
			X_Err_Nbr,X_Err_Stage);
      RETCODE := to_char(X_Err_Nbr);
      ERRBUF  := X_Err_Stage;

       /*----------------------------------------------------------*/
       -- Ver 1.2  Added Procedure UPDATE_FV_ASSIGN_REASON_CODES  RCW.
      /*-----------------------------------------------------------*/
      IF fnd_profile.value('USE_DISCOUNT_LOST_REASON_CODES') = 'Y'
	      AND X_Terms_Type = 'PROMPT PAY'     THEN
         IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
           FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'Using Discount Lost Reason Codes');
         END IF;
  	 UPDATE_FV_ASSIGN_REASON_CODES(X_Invoice_Id,x_Batch_Name,
					X_Err_Nbr,X_Err_Stage);
         RETCODE := to_char(X_Err_Nbr);
         ERRBUF  := X_Err_Stage;
       END IF;
	/*-----------  end 1.2  RCW  -------------------------------*/

    Else
        IF X_Err_Nbr = 1 then -- 3A
           INSERT_FV_DISCOUNTED_INVOICES(X_Invoice_Id,
                                        'N',
                                        'PAYMENT_DATE_PAST',
                                         X_Payment_Date,
                                         X_Effective_Discount_Rate,
                                         X_CVOF_Rate,
                                         X_Err_Nbr ,
                                         X_Err_Stage);
            RETCODE := to_char(X_Err_Nbr);
            ERRBUF  := X_Err_Stage;
            If ((X_Err_Nbr = 2) or (X_Err_Nbr < 0)) then
              err_message := x_err_stage;
              fnd_message.set_name('FV','FV_FAI_GENERAL');
              fnd_message.set_token('msg',err_message);
              IF ( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FV_UTILITY.MESSAGE(FND_LOG.LEVEL_ERROR, l_module_name);
              END IF;
              app_exception.raise_exception;
            End If;

	    /*---------------------------------------------------------*/
	     -- Ver 1.2  Added Procedure INSERT_FV_ASSIGN_REASON_CODES  RCW
	    /*----------------------------------------------------------*/
	    IF fnd_profile.value('USE_DISCOUNT_LOST_REASON_CODES') = 'Y'
		   AND X_Terms_Type = 'PROMPT PAY'     THEN
	       If ROW_EXISTS_FVRC(X_Invoice_Id,X_Err_Nbr,X_Err_Stage) then
            IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name, 'Record exists in FVRC');
            END IF;

		  UPDATE_FV_ASSIGN_REASON_CODES(X_Invoice_Id,x_Batch_Name,
					X_Err_Nbr,X_Err_Stage);
                  RETCODE := to_char(X_Err_Nbr);
                  ERRBUF  := X_Err_Stage;

	       Else    -- ROW DOESN'T EXIST
            IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
              FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name, 'x_err_nbr = '||to_char(x_err_nbr));
            END IF;
		  IF X_Err_Nbr = 1 then       --no records found

 		     INSERT_FV_ASSIGN_REASON_CODES(X_Invoice_Id,
                                       		 x_Batch_Name,
				  		 X_Err_Nbr,
                                      		 X_Err_Stage);
		     RETCODE := to_char(X_Err_Nbr);
                     ERRBUF  := X_Err_Stage;
            	     If ((X_Err_Nbr = 2) or (X_Err_Nbr < 0)) then
                        err_message := x_err_stage;
                        fnd_message.set_name('FV','FV_FAI_GENERAL');
                        fnd_message.set_token('msg',err_message);
                        IF ( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                          FV_UTILITY.MESSAGE(FND_LOG.LEVEL_ERROR, l_module_name);
                        END IF;
                        app_exception.raise_exception;
                     End If;
                  ELSIF	X_Err_Nbr = 2 then     --too many rows
		       err_message := x_err_stage;
                       fnd_message.set_name('FV','FV_FAI_GENERAL');
                       fnd_message.set_token('msg',err_message);
                       IF ( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                         FV_UTILITY.MESSAGE(FND_LOG.LEVEL_ERROR, l_module_name);
                       END IF;
                       app_exception.raise_exception;

	          END IF;
	       End If;    --ROW_EXISTS_FVRC
	    END IF;

	   /*-------  end 1.2  RCW  --------------------------------*/
        ELSIF X_Err_Nbr = 2 then
             err_message := x_err_stage;
             fnd_message.set_name('FV','FV_FAI_GENERAL');
             fnd_message.set_token('msg',err_message);
              IF ( FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FV_UTILITY.MESSAGE(FND_LOG.LEVEL_ERROR, l_module_name);
              END IF;
             app_exception.raise_exception;

        END IF;  -- End of 3A
    END IF;  --End of 3rd IF
  END IF ; -- End of 2nd If
END LOOP;

IF c1%NOTFOUND THEN
   FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name, 'Invoice Number, '||x_invoice_num||', will be included in the Payment Batch because it');
   FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name, 'meets EBD Requirements.');
   RETURN 'Y';
END IF;

close c1;

ELSE
 -- FV is not enabled
 RETURN 'Y';
END IF;
EXCEPTION
  WHEN OTHERS THEN
    err_message := SQLERRM;
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',err_message);
    RAISE;
END EBD_CHECK;
/*-----------------------------------------------------------------------*/
END FV_ECON_BENF_DISC_PVT;

/

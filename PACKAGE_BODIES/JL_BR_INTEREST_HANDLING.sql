--------------------------------------------------------
--  DDL for Package Body JL_BR_INTEREST_HANDLING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JL_BR_INTEREST_HANDLING" AS
/* $Header: jlbrsinb.pls 120.5.12010000.3 2009/07/09 11:46:28 vspuli ship $ */

G_LEVEL_STATEMENT       CONSTANT NUMBER   := FND_LOG.LEVEL_STATEMENT;
G_CURRENT_RUNTIME_LEVEL CONSTANT NUMBER   := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
G_LEVEL_PROCEDURE       CONSTANT NUMBER   := FND_LOG.LEVEL_PROCEDURE;


-- *****************************************************************************
-- This procedure calcualtes interest based on the interest parameteres
-- entered by the user. This has MOAC changes needed for R12. bug: 8621688
-- Created by: vspuli
-- Creation Date : 02-JUL-2009
-- ****************************************************************************
PROCEDURE JL_BR_INTEREST(X_Interest_Type           IN VARCHAR2,
                         X_Interest_Rate_Amount    IN NUMBER,
                         X_Period_Days             IN NUMBER,
                         X_Interest_Formula 	   IN VARCHAR2,
                         X_Grace_Days   		   IN NUMBER,
                         X_Penalty_Type		   IN VARCHAR2,
                         X_Penalty_Rate_Amount     IN NUMBER,
                         X_Due_Date                IN DATE,
                         X_Payment_Date            IN DATE,
                         X_Invoice_Amount          IN NUMBER,
                         X_JLBR_Calendar     	   IN VARCHAR2,
                         X_JLBR_Local_Holiday      IN VARCHAR2,
                         X_JLBR_Action_Non_Workday IN VARCHAR2,
                         X_Interest_Calculated     IN OUT NOCOPY NUMBER,
                         X_Days_Late               IN OUT NOCOPY NUMBER,
                         X_Exit_Code               OUT NOCOPY NUMBER,
			 X_ORG_ID                  IN NUMBER) IS

   P_Date_Ok      	DATE;
   P_Late_Days1         NUMBER(38);
   P_Late_Days2         NUMBER(38);
   P_Penalty_Calculated NUMBER; -- BUG Number 859348
   P_Status             NUMBER(38);
   P_WorkDay_Ok         VARCHAR2(11);
   P_WorkDay_Date       DATE;
   P_Return_Code        NUMBER(38);
   C_interest_tolerance_amount number;
   jg_app_short_name   VARCHAR2(10);
   l_debug_info        VARCHAR2(2000);
BEGIN
   P_Status := 0;
   X_Exit_Code := 0;
   P_Late_Days1 := 0;
   P_Late_Days2 := 0;
   P_Penalty_Calculated := 0;
   X_Interest_Calculated := 0;
   X_Days_Late := 0;

    l_debug_info := 'Entered Interest Package ';
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        fnd_file.put_line(FND_FILE.LOG,l_debug_info);
      END IF;
   P_Date_Ok := X_Due_Date + NVL(X_Grace_Days,0);

    l_debug_info := 'jlbr p_date_ok: '||to_char(P_Date_Ok, 'DD-MON-YYYY');
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        fnd_file.put_line(FND_FILE.LOG,l_debug_info);
      END IF;

   --
   -- Validate Tolerance from ap_system_parameters
   --
    SELECT nvl(interest_tolerance_amount,0)
         Into C_interest_tolerance_amount
    FROM   ap_system_parameters_all
    WHERE  nvl(org_id,-99) = nvl(x_org_id,-99);


/***
   SELECT nvl(interest_tolerance_amount,0)
     INTO C_interest_tolerance_amount
     FROM ap_system_parameters;
***/


    l_debug_info := 'jlbr tolerance_amount '||to_char(C_interest_tolerance_amount);
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        fnd_file.put_line(FND_FILE.LOG,l_debug_info);
      END IF;


   jl_br_workday_calendar.jl_br_check_date(to_char(P_Date_Ok, 'DD-MM-YYYY'),
   		                               X_JLBR_Calendar,
                                           X_JLBR_Local_Holiday,
                                           X_JLBR_Action_Non_Workday,
                                           P_WorkDay_Ok,
                                           P_Status);

   P_WorkDay_Date := to_date(P_WorkDay_Ok, 'DD-MM-YYYY');

    l_debug_info := 'jlbr check_date status '||to_char(P_Status);
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        fnd_file.put_line(FND_FILE.LOG,l_debug_info);
      END IF;




    l_debug_info := 'jlbr check_date return '||P_WorkDay_Ok;
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        fnd_file.put_line(FND_FILE.LOG,l_debug_info);
      END IF;

   IF P_Status = 0 THEN

      l_debug_info := 'jlbr interest calc ';
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        fnd_file.put_line(FND_FILE.LOG,l_debug_info);
      END IF;

      X_Days_Late := trunc(X_Payment_Date - P_WorkDay_Date);
      P_Late_Days2 := trunc(X_Payment_Date - X_Due_Date);


      l_debug_info := 'jlbr interest calc:  X_Days_Late' || to_char(X_Days_Late);
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        fnd_file.put_line(FND_FILE.LOG,l_debug_info);
      END IF;

      l_debug_info := 'jlbr interest calc:  P_Late_Days2' || to_char(P_Late_Days2);
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        fnd_file.put_line(FND_FILE.LOG,l_debug_info);
      END IF;

      IF X_Days_Late > 0 THEN
         IF X_Interest_Type IS NOT NULL THEN
            IF X_Interest_Type = 'R' THEN
               IF X_Interest_Formula = 'S' THEN
       X_Interest_Calculated := round(((NVL(X_Interest_Rate_Amount,0)/NVL(X_Period_Days,0))/100)
       * NVL(X_Invoice_Amount,0)
       * NVL(P_Late_Days2,0),2);
               ELSE
       X_Interest_Calculated := round(NVL(X_Invoice_Amount,0) *
       (POWER(( 1 + (NVL(X_Interest_Rate_Amount,0)/100)),
       (NVL(P_Late_Days2,0)/NVL(X_Period_Days,0))) - 1),2);
               END IF;
            ELSE
               X_Interest_Calculated := round(NVL(P_Late_Days2,0) * (NVL(X_Interest_Rate_Amount,0)/NVL(X_Period_Days,0)),2);
            END IF;
         END IF;

         IF X_Penalty_Type IS NOT NULL THEN
            IF X_Penalty_Type = 'R' THEN
               P_Penalty_Calculated := round(NVL(X_Penalty_Rate_Amount,0)/100 * NVL(X_Invoice_Amount,0),2);
            ELSE
               P_Penalty_Calculated := round(NVL(X_Penalty_Rate_Amount,0),2);
            END IF;
            X_Interest_Calculated := round(NVL(X_Interest_Calculated,0) + NVL(P_Penalty_Calculated,0),2);
         END IF;
         -- Verify Tolerance vs Interest_Calculated
         -- Bug# 1480683
         -- Bug 2020279 check tolerance only for AP
         --
         --fnd_profile.get('JGZZ_APPL_SHORT_NAME', jg_app_short_name);
         jg_app_short_name := JG_ZZ_SHARED_PKG.get_application;
         --
         IF jg_app_short_name = 'SQLAP' THEN
           IF C_interest_tolerance_amount > X_Interest_Calculated THEN
              X_Interest_Calculated := 0;
           END IF;
         END IF;
      END IF;
   ELSE
      X_Exit_Code := 1;
   END IF;


     l_debug_info := 'jlbr interest calc:  return' || to_char(X_Interest_Calculated);
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        fnd_file.put_line(FND_FILE.LOG,l_debug_info);
      END IF;

     l_debug_info := 'jlbr interest calc:  Exit Code' || to_char(X_Exit_Code);
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        fnd_file.put_line(FND_FILE.LOG,l_debug_info);
      END IF;


END JL_BR_INTEREST;





PROCEDURE JL_BR_INTEREST(X_Interest_Type           IN VARCHAR2,
                         X_Interest_Rate_Amount    IN NUMBER,
                         X_Period_Days             IN NUMBER,
                         X_Interest_Formula 	   IN VARCHAR2,
                         X_Grace_Days   		   IN NUMBER,
                         X_Penalty_Type		   IN VARCHAR2,
                         X_Penalty_Rate_Amount     IN NUMBER,
                         X_Due_Date                IN DATE,
                         X_Payment_Date            IN DATE,
                         X_Invoice_Amount          IN NUMBER,
                         X_JLBR_Calendar     	   IN VARCHAR2,
                         X_JLBR_Local_Holiday      IN VARCHAR2,
                         X_JLBR_Action_Non_Workday IN VARCHAR2,
                         X_Interest_Calculated     IN OUT NOCOPY NUMBER,
                         X_Days_Late               IN OUT NOCOPY NUMBER,
                         X_Exit_Code               OUT NOCOPY NUMBER) IS

   P_Date_Ok      	DATE;
   P_Late_Days1         NUMBER(38);
   P_Late_Days2         NUMBER(38);
   P_Penalty_Calculated NUMBER; -- BUG Number 859348
   P_Status             NUMBER(38);
   P_WorkDay_Ok         VARCHAR2(11);
   P_WorkDay_Date       DATE;
   P_Return_Code        NUMBER(38);
   C_interest_tolerance_amount number;
   jg_app_short_name VARCHAR2(10);

BEGIN
   P_Status := 0;
   X_Exit_Code := 0;
   P_Late_Days1 := 0;
   P_Late_Days2 := 0;
   P_Penalty_Calculated := 0;
   X_Interest_Calculated := 0;
   X_Days_Late := 0;

   P_Date_Ok := X_Due_Date + NVL(X_Grace_Days,0);
   --
   -- Validate Tolerance from ap_system_parameters
   --
   SELECT nvl(interest_tolerance_amount,0)
     INTO C_interest_tolerance_amount
     FROM ap_system_parameters;


   jl_br_workday_calendar.jl_br_check_date(to_char(P_Date_Ok, 'DD-MM-YYYY'),
   		                               X_JLBR_Calendar,
                                           X_JLBR_Local_Holiday,
                                           X_JLBR_Action_Non_Workday,
                                           P_WorkDay_Ok,
                                           P_Status);

   P_WorkDay_Date := to_date(P_WorkDay_Ok, 'DD-MM-YYYY');

   IF P_Status = 0 THEN
      X_Days_Late := trunc(X_Payment_Date - P_WorkDay_Date);
      P_Late_Days2 := trunc(X_Payment_Date - X_Due_Date);

      IF X_Days_Late > 0 THEN
         IF X_Interest_Type IS NOT NULL THEN
            IF X_Interest_Type = 'R' THEN
               IF X_Interest_Formula = 'S' THEN
       X_Interest_Calculated := round(((NVL(X_Interest_Rate_Amount,0)/NVL(X_Period_Days,0))/100)
       * NVL(X_Invoice_Amount,0)
       * NVL(P_Late_Days2,0),2);
               ELSE
       X_Interest_Calculated := round(NVL(X_Invoice_Amount,0) *
       (POWER(( 1 + (NVL(X_Interest_Rate_Amount,0)/100)),
       (NVL(P_Late_Days2,0)/NVL(X_Period_Days,0))) - 1),2);
               END IF;
            ELSE
               X_Interest_Calculated := round(NVL(P_Late_Days2,0) * (NVL(X_Interest_Rate_Amount,0)/NVL(X_Period_Days,0)),2);
            END IF;
         END IF;

         IF X_Penalty_Type IS NOT NULL THEN
            IF X_Penalty_Type = 'R' THEN
               P_Penalty_Calculated := round(NVL(X_Penalty_Rate_Amount,0)/100 * NVL(X_Invoice_Amount,0),2);
            ELSE
               P_Penalty_Calculated := round(NVL(X_Penalty_Rate_Amount,0),2);
            END IF;
            X_Interest_Calculated := round(NVL(X_Interest_Calculated,0) + NVL(P_Penalty_Calculated,0),2);
         END IF;
         -- Verify Tolerance vs Interest_Calculated
         -- Bug# 1480683
         -- Bug 2020279 check tolerance only for AP
         --
         --fnd_profile.get('JGZZ_APPL_SHORT_NAME', jg_app_short_name);
         jg_app_short_name := JG_ZZ_SHARED_PKG.get_application;
         --
         IF jg_app_short_name = 'SQLAP' THEN
           IF C_interest_tolerance_amount > X_Interest_Calculated THEN
              X_Interest_Calculated := 0;
           END IF;
         END IF;
      END IF;
   ELSE
      X_Exit_Code := 1;
   END IF;
END JL_BR_INTEREST;


-- *****************************************************************************
-- This procedure updates the interest inovice description according to
-- brazilian rates.
-- Created by: Dario Betancourt.
-- Creation Date : 29-Mar-1999
-- ****************************************************************************
PROCEDURE JL_BR_CHANGE_INT_DES(P_invoice_related number,
                               P_invoice_original number,
                               P_payment_num_org number) IS
  l_interest_type       VARCHAR2(15);
  --l_currency_symbol     VARCHAR2(4) := 'R$';
  --commented above for bug 2870854
  --increased length to 12.
  l_currency_symbol     VARCHAR2(12) := 'R$';
  l_rate_amount         NUMBER;
  l_due_date            DATE;
  l_check_date          DATE;
  l_invoice_days_late   NUMBER;
  l_nls_interest        VARCHAR2(25);
  l_nls_days            VARCHAR2(25);
  l_nls_percent         VARCHAR2(25);
  l_invoice_description VARCHAR2(240);
BEGIN
   -- ********************************************************
   -- Get the Translatable Words for filling the description
   -- ********************************************************
   SELECT l1.displayed_field,
          l2.displayed_field,
          l3.displayed_field
   INTO l_nls_interest,
        l_nls_days,
        l_nls_percent
   FROM ap_lookup_codes l1,
        ap_lookup_codes l2,
        ap_lookup_codes l3
   WHERE l1.lookup_type = 'NLS TRANSLATION'
     AND l1.lookup_code = 'INTEREST'
     AND l2.lookup_type = 'NLS TRANSLATION'
     AND l2.lookup_code = 'DAYS'
     AND l3.lookup_type = 'NLS TRANSLATION'
     AND l3.lookup_code = 'PERCENT';

   -- ***********************************************************
   -- Get the interest rate from(GA2) and due_date
   -- from ap_payment_schedules
   -- ***********************************************************
   SELECT substr(global_attribute1, 1, 15),
          nvl(to_number(substr(global_attribute2, 1, 15)), 0),
          due_date
   INTO l_interest_type, l_rate_amount, l_due_date
   FROM ap_payment_schedules
   WHERE invoice_id  = P_invoice_original
     AND payment_num = P_payment_num_org;

   -- *********************************************************
   -- Get the payment_date from ap_invoices (interest invoice)
   -- *********************************************************
   SELECT invoice_date
   INTO l_check_date
   FROM ap_invoices
   WHERE invoice_id = P_invoice_related;


   -- *********************************************************
   -- Calculate the days late.
   -- *********************************************************
   l_invoice_days_late := LEAST(TRUNC(l_check_date), ADD_MONTHS(TRUNC(l_due_date), 12))
                         - TRUNC(l_due_date);

   -- **********************************************************
   -- Concat the Description with the appropriate interest rate
   -- BUG Number 856304
   -- **********************************************************
   IF l_interest_type = 'R' THEN
     l_invoice_description := l_nls_interest || ' ' || to_char(l_invoice_days_late)
                              || ' ' || l_nls_days || to_char(l_rate_amount) || l_nls_percent;
   ELSIF l_interest_type = 'A' THEN
     -- *********************************************************
     -- Get the currency symbol
     -- *********************************************************
     SELECT fc.symbol
     INTO l_currency_symbol
     FROM ap_invoices ai, fnd_currencies_vl fc
     WHERE ai.invoice_currency_code = fc.currency_code
       AND ai.invoice_id = P_invoice_original;

     l_invoice_description := l_nls_interest || ' ' || to_char(l_invoice_days_late)
                              || ' ' || l_nls_days || l_currency_symbol || to_char(l_rate_amount);
   ELSE
     l_invoice_description := 'Invalid Interest Type: ' || l_interest_type;
   END IF;

   UPDATE ap_invoices
   SET description = l_invoice_description
   WHERE invoice_id = P_invoice_related;

EXCEPTION
     WHEN others THEN NULL;
END JL_BR_CHANGE_INT_DES;

PROCEDURE JL_BR_INTEREST(X_Interest_Type           IN VARCHAR2,
                         X_Interest_Rate_Amount    IN NUMBER,
                         X_Period_Days             IN NUMBER,
                         X_Interest_Formula 	   IN VARCHAR2,
                         X_Grace_Days   		   IN NUMBER,
                         X_Penalty_Type		   IN VARCHAR2,
                         X_Penalty_Rate_Amount     IN NUMBER,
                         X_Due_Date                IN DATE,
                         X_Payment_Date            IN DATE,
                         X_Invoice_Amount          IN NUMBER,
                         X_JLBR_Calendar     	   IN VARCHAR2,
                         X_JLBR_Local_Holiday      IN VARCHAR2,
                         X_JLBR_Action_Non_Workday IN VARCHAR2,
                         X_Interest_Calculated     IN OUT NOCOPY NUMBER,
                         X_Days_Late               IN OUT NOCOPY NUMBER,
                         X_Exit_Code               OUT NOCOPY NUMBER,
                         X_JLBR_State              IN VARCHAR2) IS -- Bug # 2319552

   P_Date_Ok      	DATE;
   P_Late_Days1         NUMBER(38);
   P_Late_Days2         NUMBER(38);
   P_Penalty_Calculated NUMBER; -- BUG Number 859348
   P_Status             NUMBER(38);
   P_WorkDay_Ok         VARCHAR2(11);
   P_WorkDay_Date       DATE;
   P_Return_Code        NUMBER(38);
   C_interest_tolerance_amount number;
   jg_app_short_name VARCHAR2(10);

BEGIN
   P_Status := 0;
   X_Exit_Code := 0;
   P_Late_Days1 := 0;
   P_Late_Days2 := 0;
   P_Penalty_Calculated := 0;
   X_Interest_Calculated := 0;
   X_Days_Late := 0;

   P_Date_Ok := X_Due_Date + NVL(X_Grace_Days,0);
   --
   -- Validate Tolerance from ap_system_parameters
   --
   SELECT nvl(interest_tolerance_amount,0)
     INTO C_interest_tolerance_amount
     FROM ap_system_parameters;


   jl_br_workday_calendar.jl_br_check_date(to_char(P_Date_Ok, 'DD-MM-YYYY'),
   		                               X_JLBR_Calendar,
                                           X_JLBR_Local_Holiday,
                                           X_JLBR_Action_Non_Workday,
                                           P_WorkDay_Ok,
                                           P_Status,
                                           X_JLBR_State); -- Bug # 2319552

   P_WorkDay_Date := to_date(P_WorkDay_Ok, 'DD-MM-YYYY');

   IF P_Status = 0 THEN
      X_Days_Late := trunc(X_Payment_Date - P_WorkDay_Date);
      P_Late_Days2 := trunc(X_Payment_Date - X_Due_Date);

      IF X_Days_Late > 0 THEN
         IF X_Interest_Type IS NOT NULL THEN
            IF X_Interest_Type = 'R' THEN
               IF X_Interest_Formula = 'S' THEN
       X_Interest_Calculated := round(((NVL(X_Interest_Rate_Amount,0)/NVL(X_Period_Days,0))/100)
       * NVL(X_Invoice_Amount,0)
       * NVL(P_Late_Days2,0),2);
               ELSE
       X_Interest_Calculated := round(NVL(X_Invoice_Amount,0) *
       (POWER(( 1 + (NVL(X_Interest_Rate_Amount,0)/100)),
       (NVL(P_Late_Days2,0)/NVL(X_Period_Days,0))) - 1),2);
               END IF;
            ELSE
               X_Interest_Calculated := round(NVL(P_Late_Days2,0) * (NVL(X_Interest_Rate_Amount,0)/NVL(X_Period_Days,0)),2);
            END IF;
         END IF;

         IF X_Penalty_Type IS NOT NULL THEN
            IF X_Penalty_Type = 'R' THEN
               P_Penalty_Calculated := round(NVL(X_Penalty_Rate_Amount,0)/100 * NVL(X_Invoice_Amount,0),2);
            ELSE
               P_Penalty_Calculated := round(NVL(X_Penalty_Rate_Amount,0),2);
            END IF;
            X_Interest_Calculated := round(NVL(X_Interest_Calculated,0) + NVL(P_Penalty_Calculated,0),2);
         END IF;
         -- Verify Tolerance vs Interest_Calculated
         -- Bug# 1480683
         -- Bug 2020279 check tolerance only for AP
         --
         --fnd_profile.get('JGZZ_APPL_SHORT_NAME', jg_app_short_name);
         jg_app_short_name := JG_ZZ_SHARED_PKG.get_application;
         --
         IF jg_app_short_name = 'SQLAP' THEN
           IF C_interest_tolerance_amount > X_Interest_Calculated THEN
              X_Interest_Calculated := 0;
           END IF;
         END IF;
      END IF;
   ELSE
      X_Exit_Code := 1;
   END IF;
END JL_BR_INTEREST;

END JL_BR_INTEREST_HANDLING;

/

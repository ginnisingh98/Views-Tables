--------------------------------------------------------
--  DDL for Package Body AP_CUSTOM_INT_INV_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_CUSTOM_INT_INV_PKG" AS
/*$Header: apcstiib.pls 120.5.12010000.4 2009/07/09 11:22:39 njakkula ship $*/

/*==========================================================================
 Customize the Interest Calculation
 *=====================================================================*/
G_CURRENT_RUNTIME_LEVEL CONSTANT NUMBER       := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
G_LEVEL_UNEXPECTED      CONSTANT NUMBER       := FND_LOG.LEVEL_UNEXPECTED;
G_LEVEL_ERROR           CONSTANT NUMBER       := FND_LOG.LEVEL_ERROR;
G_LEVEL_EXCEPTION       CONSTANT NUMBER       := FND_LOG.LEVEL_EXCEPTION;
G_LEVEL_EVENT           CONSTANT NUMBER       := FND_LOG.LEVEL_EVENT;
G_LEVEL_PROCEDURE       CONSTANT NUMBER       := FND_LOG.LEVEL_PROCEDURE;
G_LEVEL_STATEMENT       CONSTANT NUMBER       := FND_LOG.LEVEL_STATEMENT;
G_MODULE_NAME           CONSTANT VARCHAR2(40) := 'AP.PLSQL.AP_CUSTOM_INT_INV_PKG.';

PROCEDURE ap_custom_calculate_interest(

              P_invoice_id                     IN   NUMBER,
              P_sys_auto_calc_int_flag         IN   VARCHAR2, --bug 4995343
              P_auto_calculate_interest_flag   IN   VARCHAR2, --bug 4995343
              P_check_date                     IN   DATE,
              P_payment_num                    IN   NUMBER,
              P_amount_remaining               IN   NUMBER, --bug 4995343
              P_discount_taken                 IN   NUMBER, --bug 4995343
              P_discount_available             IN   NUMBER, --bug 4995343
              P_currency_code                  IN   VARCHAR2,
              P_payment_amount                 IN   NUMBER,
              P_interest_amount                OUT  NOCOPY   NUMBER,
              P_invoice_due_date               IN   DATE  ) IS


  l_interest_amount              number;
  l_interest_type                varchar2(15);
  l_interest_rate_amount         number;
  l_interest_period              number;
  l_interest_formula             varchar2(30);
  l_interest_grace_days          number;
  l_penalty_type                 varchar2(15);
  l_penalty_rate_amount          number;
  l_calendar                     varchar2(10);
  l_city                         po_vendor_sites.city%type; --6708281
  l_payment_location             varchar2(80);
  l_payment_action               varchar2(1);
  l_days_late                    number;
  l_exit_code                    number;
  l_vendor_site_id               number;
  c                              INTEGER;
  rows                           INTEGER;
  statement                      VARCHAR2(2000);
  dummy                          VARCHAR2(25);
  l_country_code                 VARCHAR2(25);
  l_org_id                       NUMBER(15);
  DBG_Loc                        VARCHAR2(30) := 'ap_custom_calculate_interest';
  debug_info                     VARCHAR2(2000);

BEGIN

   debug_info := 'Start of ap_custom_calculate_interest';
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
   END IF;

  FND_PROFILE.GET('JGZZ_COUNTRY_CODE', l_country_code);

  -- bug 4995343.Added a code hook to call Federal
  -- package for interest calculation


 Select org_id into l_org_id
    from ap_invoices
   where invoice_id=p_invoice_id;

    debug_info := 'apcci Invoice_id: '||to_char(p_invoice_id) ||
                  ' Org_id: '|| l_org_id;
   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
   END IF;

  IF (FV_INSTALL.ENABLED (l_org_id)) THEN

        FV_ECON_BENF_DISC.fv_calculate_interest(
            P_invoice_id ,
            P_sys_auto_calc_int_flag ,
            P_auto_calculate_interest_flag ,
            P_check_date ,
            P_payment_num ,
            P_amount_remaining ,
            P_discount_taken ,
            P_discount_available ,
            P_interest_amount  );

         debug_info := 'apcci FV Int Amt '||to_char(P_interest_amount);
          IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
               FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
          END IF;

  ELSIF  l_country_code = 'BR' then

  -- Get Global_Attribute1..7, due_date from ap_payment_schedule
   --Bug6238399 Use fnd_number.canonical_to_number instead of to_number
 SELECT   substr(global_attribute1,1,15)    interest_type,
          fnd_number.canonical_to_number(substr(global_attribute2,1,15))   interest_rate_amount,
          fnd_number.canonical_to_number(substr(global_attribute3,1,15))   interest_period,
          substr(global_attribute4,1,30)    interest_formula,
	  fnd_number.canonical_to_number(substr(global_attribute5,1,4))   interest_grace_days,
          substr(global_attribute6,1,15)    penalty_type,
          fnd_number.canonical_to_number(substr(global_attribute7,1,15))   penalty_rate_amount
   INTO   l_interest_type,
          l_interest_rate_amount,
          l_interest_period,
          l_interest_formula,
          l_interest_grace_days,
          l_penalty_type,
          l_penalty_rate_amount
               FROM  ap_payment_schedules
               WHERE  invoice_id = p_invoice_id
                 AND payment_num = p_payment_num;

         debug_info := 'apcci Int Type '||l_interest_type;
          IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
               FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
          END IF;

         debug_info :=  'apcci Int Rate Amt '||to_char(l_interest_rate_amount);
          IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
               FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
          END IF;

  l_interest_rate_amount := nvl(l_interest_rate_amount,0);
  l_interest_period      := nvl(l_interest_period,0);
  l_interest_grace_days  := nvl(l_interest_grace_days,0);
  l_penalty_rate_amount  := nvl(l_penalty_rate_amount,0);

  -- Get the Calendar
  FND_PROFILE.GET('JLBR_CALENDAR',l_calendar);
  --
  -- Get the payment_location profile, vendor_site_id for getting CITY
  --
  -- Get payment_location
  FND_PROFILE.GET('JLBR_PAYMENT_LOCATION',l_payment_location);

  -- Get vendor_site_id from ap_invoices
  SELECT  vendor_site_id
    INTO  l_vendor_site_id
    FROM  ap_invoices
   WHERE  invoice_id = p_invoice_id;

  IF NVL(l_payment_location,'$') = '1' THEN		-- 1 COMPANY
    -- Get city from ap_system_parameters
    select substr(global_attribute4,1,25) city
      into l_city
     from ap_system_parameters;

  ELSIF NVL(l_payment_location,'$') = '2' THEN		-- 2 SUPPLIER
    -- Get city from po_vendor_sites
    select city
     into  l_city
     from po_vendor_sites
    where vendor_site_id = l_vendor_site_id
      and nvl(inactive_date,sysdate + 1) > sysdate;

  END IF;

  -- Get the payment_action
  --FND_PROFILE.GET('JLBR_PAYMENT_ACTION',l_payment_action);
  l_payment_action := JL_ZZ_SYS_OPTIONS_PKG.get_payment_action(l_org_id); --8493945

  l_interest_amount := 0;
  l_days_late := 0;

  BEGIN

  -- Call Stored Procedure JL_BR_INTEREST for calculation of INTEREST_AMOUNT

  SELECT 'X' into dummy
    from user_objects
     where object_name = 'JL_BR_INTEREST_HANDLING'
      and object_type = 'PACKAGE BODY';

  debug_info :=   'apcci calling JL_BR_INTEREST_HANDLING ';
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
  END IF;

  c := dbms_sql.open_cursor; --bug8652516: Added X_Org_id
  statement := 'BEGIN
                JL_BR_INTEREST_HANDLING.JL_BR_INTEREST(' ||
                'X_Interest_Type=>:interest_type, ' ||
                'X_Interest_Rate_Amount=>:interest_rate_amount, ' ||
                'X_Period_Days=>:interest_period, ' ||
                'X_Interest_Formula=>:interest_formula, ' ||
                'X_Grace_Days=>:interest_grace_days, ' ||
                'X_Penalty_Type=>:penalty_type, ' ||
                'X_Penalty_Rate_Amount=>:penalty_rate_amount, ' ||
                'X_Due_Date=>:invoice_due_date, ' ||
                'X_Payment_Date=>:check_date, ' ||
                'X_Invoice_Amount=>:payment_amount, ' ||
                'X_JLBR_Calendar=>:calendar, ' ||
                'X_JLBR_Local_Holiday=>:city, ' ||
                'X_JLBR_Action_Non_Workday=>:payment_action, ' ||
                'X_Interest_Calculated=>:interest_amount, ' ||
                'X_Days_Late=>:days_late, ' ||
                'X_Exit_Code=>:exit_code, ' ||
		'X_Org_id=>:org_id ); END; ';

      dbms_sql.parse(c, statement, dbms_sql.native);

      dbms_sql.bind_variable( c, 'interest_type', l_interest_type );
      dbms_sql.bind_variable( c, 'interest_rate_amount', l_interest_rate_amount
);
      dbms_sql.bind_variable( c, 'interest_period', l_interest_period );
      dbms_sql.bind_variable( c, 'interest_formula', l_interest_formula );
      dbms_sql.bind_variable( c, 'interest_grace_days', l_interest_grace_days );
      dbms_sql.bind_variable( c, 'penalty_type', l_penalty_type );
      dbms_sql.bind_variable( c, 'penalty_rate_amount', l_penalty_rate_amount );
      dbms_sql.bind_variable( c, 'invoice_due_date', p_invoice_due_date );
      dbms_sql.bind_variable( c, 'check_date', p_check_date );
      dbms_sql.bind_variable( c, 'payment_amount', p_payment_amount );
      dbms_sql.bind_variable( c, 'calendar', l_calendar );
      dbms_sql.bind_variable( c, 'city', l_city );
      dbms_sql.bind_variable( c, 'payment_action', l_payment_action );
      dbms_sql.bind_variable ( c, 'interest_amount', l_interest_amount);
      dbms_sql.bind_variable ( c, 'days_late', l_days_late);
      dbms_sql.bind_variable ( c, 'exit_code', l_exit_code);
      dbms_sql.bind_variable( c, 'org_id', l_org_id );

      rows := dbms_sql.execute(c);
      dbms_sql.variable_value ( c, 'interest_amount', p_interest_amount );
      dbms_sql.variable_value ( c, 'days_late', l_days_late );
      dbms_sql.variable_value ( c, 'exit_code', l_exit_code );

      dbms_sql.close_cursor(c);

      EXCEPTION
         WHEN NO_DATA_FOUND THEN P_INTEREST_AMOUNT := NULL;
	  debug_info :=   'sqlcode: '|| sqlcode||' sqlerrm: '||sqlerrm;
	  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
		FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
	  END IF;
         WHEN OTHERS THEN P_INTEREST_AMOUNT := NULL;
	  debug_info :=   'sqlcode: '|| sqlcode||' sqlerrm: '||sqlerrm;
	  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
		FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
	  END IF;
      END;

ELSE

    P_INTEREST_AMOUNT := NULL;

END IF;

  debug_info :=  'apcci Int AMT 2 '||to_char(p_interest_amount);
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||DBG_Loc,debug_info);
  END IF;

END ap_custom_calculate_interest;


END AP_CUSTOM_INT_INV_PKG;

/

--------------------------------------------------------
--  DDL for Package Body ARRX_BSS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARRX_BSS" AS
/* $Header: ARRXBSB.pls 120.3 2006/04/24 12:00:11 ggadhams ship $ */

PROCEDURE arrxbss_report(p_request_id                  IN NUMBER
                        ,p_user_id                     IN NUMBER
                        ,p_reporting_level             IN VARCHAR2
                        ,p_reporting_entity_id         IN NUMBER
                        ,p_as_of_date                  IN DATE
                        ,retcode                       OUT NOCOPY NUMBER
                        ,errbuf                        OUT NOCOPY VARCHAR2) AS

-- Declare local variables
  l_login_id                   NUMBER;
  l_status                     VARCHAR2(4000);
  l_amount                     VARCHAR2(4000);
  l_applied                    VARCHAR2(4000);
  l_org_where_trx              VARCHAR2(4000);
  l_org_where_ctt              VARCHAR2(4000);
  l_org_where_rah              VARCHAR2(4000);
  l_org_where_rah1             VARCHAR2(4000);
  l_org_where_ps               VARCHAR2(4000);
  l_org_where_app              VARCHAR2(4000);
  l_books_id                   GL_SETS_OF_BOOKS.set_of_books_id%TYPE;
  l_currency_code              GL_SETS_OF_BOOKS.currency_code%TYPE;
  l_sob_name                   GL_SETS_OF_BOOKS.name%TYPE;
  l_count                      NUMBER;
  l_balance_due                NUMBER;
  l_functional_balance_due     NUMBER;
  l_applied_amount             NUMBER;
  l_functional_applied_amount  NUMBER;
  l_new_ADR                    AR_PAYMENT_SCHEDULES.amount_due_remaining%TYPE;
  l_new_acctd_ADR              AR_PAYMENT_SCHEDULES.acctd_amount_due_remaining%TYPE;

-- Declare variables for Dynamic Cursors
  v_CursorID_main             INTEGER;
  v_Dummy_main                INTEGER;
  v_CursorID_amt              INTEGER;
  v_Dummy_amt                 INTEGER;
  v_CursorID_app              INTEGER;
  v_Dummy_app                 INTEGER;

-- Declare the variables which will hold the results of the SELECT statements
  v_transaction_type                RA_CUST_TRX_TYPES.name%TYPE;
  v_transaction_type_id             RA_CUST_TRX_TYPES.cust_trx_type_id%TYPE;
  v_status                          AR_LOOKUPS.meaning%TYPE;
  v_status_code                     AR_TRANSACTION_HISTORY.status%TYPE;
  v_currency_code                   RA_CUSTOMER_TRX.invoice_currency_code%TYPE;
  v_balance_due                     NUMBER;
  v_functional_balance_due          NUMBER;
  v_customer_trx_id                 RA_CUSTOMER_TRX.customer_trx_id%TYPE;
  v_ps_exchange_rate                AR_PAYMENT_SCHEDULES.exchange_rate%TYPE;

  BEGIN

  -- Initialise status parameters
  retcode := 2;
  errbuf  := 'Inner Package Failure';

  -- Initialize MO Reporting
  XLA_MO_REPORTING_API.Initialize(p_reporting_level, p_reporting_entity_id, 'AUTO');

  -- Initialize the org parameters for the ALL tables
  l_org_where_trx  := XLA_MO_REPORTING_API.Get_Predicate('trx', null);
  l_org_where_ctt  := XLA_MO_REPORTING_API.Get_Predicate('ctt', null);
  l_org_where_rah  := XLA_MO_REPORTING_API.Get_Predicate('rah', null);
  l_org_where_rah1 := XLA_MO_REPORTING_API.Get_Predicate('rah1', null);
  l_org_where_ps   := XLA_MO_REPORTING_API.Get_Predicate('ps', null);
  l_org_where_app  := XLA_MO_REPORTING_API.Get_Predicate('app', null);

  -- Get the Login info
  fnd_profile.get('LOGIN_ID', l_login_id);

  -- Get functional currency

  /* bug 2018415 replace fnd_profile call
     fnd_profile.get(name => 'GL_SET_OF_BKS_ID',
                   val => l_books_id);
  */

--     l_books_id := arp_global.sysparam.set_of_books_id;
--Bug 5041260 Seetting the Set Of Books Id Based on the Reporting Level
  if p_reporting_level = 3000 then
    select set_of_books_id
      into l_books_id
    from ar_system_parameters_all
    where org_id = p_reporting_entity_id;
  elsif p_reporting_level = 1000 then
   l_books_id := p_reporting_entity_id;
  end if ;



  SELECT currency_code,
         name
  INTO   l_currency_code,
         l_sob_name
  FROM   gl_sets_of_books
  WHERE  set_of_books_id = l_books_id;

/*------------------------------------------------------------------+
 |                         Create Cursors                           |
 +------------------------------------------------------------------*/

  -- This is the cursor at the highest level of summarising.
  l_status := 'SELECT   trx.invoice_currency_code
                       ,ctt.name transaction_type
                       ,ctt.cust_trx_type_id
                       ,rah.status
                       ,arl.meaning
               FROM     ra_cust_trx_types_all ctt
                       ,ra_customer_trx_all trx
                       ,ar_transaction_history_all rah
                       ,ar_lookups arl
               WHERE    trx.cust_trx_type_id = ctt.cust_trx_type_id
               AND      rah.customer_trx_id  = trx.customer_trx_id
               AND      arl.lookup_code = rah.status
               AND      arl.lookup_type = ''TRANSACTION_HISTORY_STATUS'''||
              'AND      rah.transaction_history_id = (SELECT  MAX(rah1.transaction_history_id)
                                                      FROM    ar_transaction_history_all rah1
                                                      WHERE   rah1.trx_date  <= to_char(:b_status_date)' ||
                                                      l_org_where_rah1 ||
                                                     'AND     rah1.customer_trx_id = trx.customer_trx_id)' ||
               l_org_where_trx ||
               l_org_where_ctt ||
               l_org_where_rah ||
              'AND     rah.status <> ''INCOMPLETE'''||
              'GROUP BY trx.invoice_currency_code
                       ,ctt.name
                       ,ctt.cust_trx_type_id
                       ,rah.status
                       ,arl.meaning';

  l_amount := 'SELECT  nvl(ps.amount_due_remaining,0)
                      ,nvl(ps.acctd_amount_due_remaining,0)
                      ,trx.customer_trx_id
                      ,ps.exchange_rate
               FROM    ra_cust_trx_types_all ctt
                      ,ra_customer_trx_all trx
                      ,ar_transaction_history_all rah
                      ,ar_payment_schedules_all ps
               WHERE   trx.cust_trx_type_id = ctt.cust_trx_type_id
               AND     rah.customer_trx_id  = trx.customer_trx_id
               AND     rah.transaction_history_id = (SELECT  MAX(rah1.transaction_history_id)
                                                     FROM    ar_transaction_history_all rah1
                                                     WHERE   rah1.trx_date  <= to_char(:b_status_date)' ||
                                                     l_org_where_rah1 ||
                                                    'AND     rah1.customer_trx_id = trx.customer_trx_id)' ||
               l_org_where_trx ||
               l_org_where_ctt ||
               l_org_where_rah ||
               l_org_where_ps ||
              'AND     trx.customer_trx_id = ps.customer_trx_id(+)
               AND     trx.invoice_currency_code = :b_currency_code '||
              'AND     rah.status = :b_status_code '||
              'AND     trx.cust_trx_type_id = :b_transaction_type_id ';

 l_applied := 'SELECT  nvl(app.amount_applied,0)
               FROM    ra_customer_trx_all trx,
                       ar_payment_schedules_all ps,
                       ar_receivable_applications_all app
               WHERE   trx.customer_trx_id = ps.customer_trx_id
               AND     trx.customer_trx_id = app.applied_customer_trx_id
               AND     app.applied_customer_trx_id = :b_trx_id '||
               l_org_where_trx ||
               l_org_where_ps ||
               l_org_where_app ||
              'AND     app.status = ''APP'''||
              'AND     trunc(app.apply_date) > :b_as_of_date ';

/*------------------------------------------------------------------+
 |                       Parse the main cursor                      |
 +------------------------------------------------------------------*/

  -- Open the cursor for dynamic processing.
  v_CursorID_main := DBMS_SQL.OPEN_CURSOR;

  -- Parse the main query.
  DBMS_SQL.PARSE(v_CursorID_main, l_status, DBMS_SQL.native);


  -- Bind variables for main cursor
  DBMS_SQL.BIND_VARIABLE(v_CursorID_main, ':b_status_date', p_as_of_date);
  -- If the MO Reporting Get Predicate function returns a bind variable then
  -- we need to bind it.
  IF l_org_where_trx like '%:p_reporting_entity_id%' THEN
    DBMS_SQL.BIND_VARIABLE(v_CursorID_main, ':p_reporting_entity_id', p_reporting_entity_id);
  END IF;


  -- Define the output variables
  DBMS_SQL.DEFINE_COLUMN(v_CursorID_main, 1, v_currency_code, 15);
  DBMS_SQL.DEFINE_COLUMN(v_CursorID_main, 2, v_transaction_type, 20);
  DBMS_SQL.DEFINE_COLUMN(v_CursorID_main, 3, v_transaction_type_id);
  DBMS_SQL.DEFINE_COLUMN(v_CursorID_main, 4, v_status_code, 30);
  DBMS_SQL.DEFINE_COLUMN(v_CursorID_main, 5, v_status, 80);

  -- Execute the statement. We're not concerned about the return
  -- value, but we do need to declare a variable for it.
  v_Dummy_main := DBMS_SQL.EXECUTE(v_CursorID_main);

  -- This is the fetch loop.
  LOOP

    -- Fetch the rows into the buffer, and also check for the exit
    -- condition from the loop.
    IF DBMS_SQL.FETCH_ROWS(v_CursorID_main) = 0 THEN
      EXIT;
    END IF;

    -- Retrieve the rows from the buffer into PL/SQL variables.
    DBMS_SQL.COLUMN_VALUE(v_CursorID_main, 1, v_currency_code);
    DBMS_SQL.COLUMN_VALUE(v_CursorID_main, 2, v_transaction_type);
    DBMS_SQL.COLUMN_VALUE(v_CursorID_main, 3, v_transaction_type_id);
    DBMS_SQL.COLUMN_VALUE(v_CursorID_main, 4, v_status_code);
    DBMS_SQL.COLUMN_VALUE(v_CursorID_main, 5, v_status);

 /*------------------------------------------------------------------+
  |                          Amount cursor                           |
  +------------------------------------------------------------------*/

    -- Open the cursor for dynamic processing.
    v_CursorID_amt := DBMS_SQL.OPEN_CURSOR;

    -- Parse the amt query.
    DBMS_SQL.PARSE(v_CursorID_amt, l_amount, DBMS_SQL.native);

    -- Bind variables for amt cursor
    DBMS_SQL.BIND_VARIABLE(v_CursorID_amt, ':b_status_date', p_as_of_date);
    DBMS_SQL.BIND_VARIABLE(v_CursorID_amt, ':b_currency_code', v_currency_code);
    DBMS_SQL.BIND_VARIABLE(v_CursorID_amt, ':b_status_code', v_status_code);
    DBMS_SQL.BIND_VARIABLE(v_CursorID_amt, ':b_transaction_type_id', v_transaction_type_id);

    -- If the MO Reporting Get Predicate function returns a bind variable then
    -- we need to bind it.
    IF l_org_where_trx like '%:p_reporting_entity_id%' THEN
      DBMS_SQL.BIND_VARIABLE(v_CursorID_amt, ':p_reporting_entity_id', p_reporting_entity_id);
    END IF;

    -- Define the output variables
    DBMS_SQL.DEFINE_COLUMN(v_CursorID_amt, 1, v_balance_due);
    DBMS_SQL.DEFINE_COLUMN(v_CursorID_amt, 2, v_functional_balance_due);
    DBMS_SQL.DEFINE_COLUMN(v_CursorID_amt, 3, v_customer_trx_id);
    DBMS_SQL.DEFINE_COLUMN(v_CursorID_amt, 4, v_ps_exchange_rate);

    -- Execute the statement.
    v_Dummy_amt := DBMS_SQL.EXECUTE(v_CursorID_amt);

    -- Initalise variables
    l_balance_due := 0;
    l_functional_balance_due := 0;
    l_count := 0;

    -- This is the fetch loop.
    LOOP

      -- Fetch the rows into the buffer, and also check for the exit
      -- condition from the loop.
      IF DBMS_SQL.FETCH_ROWS(v_CursorID_amt) = 0 THEN
        EXIT;
      END IF;

      -- Retrieve the rows from the buffer into PL/SQL variables.
      DBMS_SQL.COLUMN_VALUE(v_CursorID_amt, 1, v_balance_due);
      DBMS_SQL.COLUMN_VALUE(v_CursorID_amt, 2, v_functional_balance_due);
      DBMS_SQL.COLUMN_VALUE(v_CursorID_amt, 3, v_customer_trx_id);
      DBMS_SQL.COLUMN_VALUE(v_CursorID_amt, 4, v_ps_exchange_rate);

      l_balance_due := l_balance_due + v_balance_due;
      l_functional_balance_due := l_functional_balance_due + v_functional_balance_due;
      l_count := l_count +1;

     /*------------------------------------------------------------------+
      |                          Applied Amounts                         |
      |                                                                  |
      | We currently have the open amounts for each record. We need to   |
      | add in any amounts that have been applied if they have been      |
      | applied since the as_of_date so to store the actual open amount  |
      | at the as_of_date.                                               |
      +------------------------------------------------------------------*/

      l_applied_amount := null;
      l_functional_applied_amount := null;

      -- Open the cursor for dynamic processing.
      v_CursorID_app := DBMS_SQL.OPEN_CURSOR;

      -- Parse the amt query.
      DBMS_SQL.PARSE(v_CursorID_app, l_applied, DBMS_SQL.native);

      -- Bind variables for applied cursor
      DBMS_SQL.BIND_VARIABLE(v_CursorID_app, ':b_as_of_date', p_as_of_date);
      DBMS_SQL.BIND_VARIABLE(v_CursorID_app, ':b_trx_id', v_customer_trx_id);

      -- If the MO Reporting Get Predicate function returns a bind variable then
      -- we need to bind it.
      IF l_org_where_trx like '%:p_reporting_entity_id%' THEN
        DBMS_SQL.BIND_VARIABLE(v_CursorID_app, ':p_reporting_entity_id', p_reporting_entity_id);
      END IF;

      -- Define the output variables
      DBMS_SQL.DEFINE_COLUMN(v_CursorID_app, 1, l_applied_amount);

      -- Execute the statement.
      v_Dummy_app := DBMS_SQL.EXECUTE(v_CursorID_app);

      -- This is the fetch loop.
      LOOP

        -- Fetch the rows into the buffer, and also check for the exit
        -- condition from the loop.
        IF DBMS_SQL.FETCH_ROWS(v_CursorID_app) = 0 THEN
          EXIT;
        END IF;

      -- Retrieve the rows from the buffer into PL/SQL variables.
      DBMS_SQL.COLUMN_VALUE(v_CursorID_app, 1, l_applied_amount);

      -- Add to open amounts
      IF l_applied_amount IS NOT NULL THEN
         l_balance_due := l_balance_due + l_applied_amount;

         -- Ensure we calculate Functional Acctd Amount correctly
	--Changed the call to arp_util.calc_accounted_amount intead of
	-- arp_util.calc_acctd_amount for Bug 5041260
         arp_util.calc_accounted_amount(
				   l_currency_code,
				    --NULL,
                                    NULL,
                                    NULL,
                                    v_ps_exchange_rate,
                                    '-',
                                    v_balance_due,
                                    v_functional_balance_due,
                                    l_applied_amount,
                                    l_new_ADR,
                                    l_new_acctd_ADR,
                                    l_functional_applied_amount);

         l_functional_balance_due := l_functional_balance_due + l_functional_applied_amount;
      END IF;

      -- End loop for Applied Amounts
      END LOOP;

      IF DBMS_SQL.IS_OPEN(v_CursorID_app) THEN
        DBMS_SQL.CLOSE_CURSOR(v_CursorID_app);
      END IF;

    -- End loop for Amounts
    END LOOP;

    IF DBMS_SQL.IS_OPEN(v_CursorID_amt) THEN
      DBMS_SQL.CLOSE_CURSOR(v_CursorID_amt);
    END IF;

  /*------------------------------------------------------------------+
   |                 Insert Data into Interface Table                 |
   +------------------------------------------------------------------*/

    --  Check if any records exist for the status being inserted
    IF l_count > 0 THEN

      -- Insert the fetched data into the Interface Table
      INSERT INTO ar_br_status_sum_itf
        (creation_date
        ,created_by
        ,last_update_login
        ,last_update_date
        ,last_updated_by
        ,request_id
        ,status
        ,currency
        ,balance_due
        ,functional_balance_due
        ,transaction_type
        ,count
        ,functional_currency_code
        ,organization_name
        )
      VALUES
        (sysdate
        ,p_user_id
        ,l_login_id
        ,sysdate
        ,p_user_id
        ,p_request_id
        ,v_status
        ,v_currency_code
        ,l_balance_due
        ,l_functional_balance_due
        ,v_transaction_type
        ,l_count
        ,l_currency_code
        ,l_sob_name
        );

     END IF;

     END LOOP;

     -- Close the cursor.
     DBMS_SQL.CLOSE_CURSOR(v_CursorID_main);

      -- Update status variables to successful completion
      retcode := 0;
      errbuf := '';

    -- Commit our work.
    COMMIT;

  EXCEPTION
    WHEN OTHERS THEN
      -- Close the cursors, then raise the error again.
        IF DBMS_SQL.IS_OPEN (v_CursorID_amt) THEN
          DBMS_SQL.CLOSE_CURSOR(v_CursorID_amt);
        END IF;

        IF DBMS_SQL.IS_OPEN (v_CursorID_app) THEN
          DBMS_SQL.CLOSE_CURSOR(v_CursorID_app);
        END IF;

      DBMS_SQL.CLOSE_CURSOR(v_CursorID_main);
      RAISE;
    END arrxbss_report;

END arrx_bss;

/

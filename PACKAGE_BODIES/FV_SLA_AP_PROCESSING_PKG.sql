--------------------------------------------------------
--  DDL for Package Body FV_SLA_AP_PROCESSING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FV_SLA_AP_PROCESSING_PKG" AS
--$Header: FVXLAAPB.pls 120.0.12010000.1 2010/02/10 19:34:46 sasukuma noship $

---------------------------------------------------------------------------
---------------------------------------------------------------------------

  c_FAILURE   CONSTANT  NUMBER := -1;
  c_SUCCESS   CONSTANT  NUMBER := 0;
  C_GL_APPLICATION CONSTANT NUMBER := 101;
  C_GL_APPL_SHORT_NAME CONSTANT VARCHAR2(30) := 'SQLGL';
  C_GL_FLEX_CODE   CONSTANT VARCHAR2(10) := 'GL#';
  CRLF CONSTANT VARCHAR2(1) := FND_GLOBAL.newline;
  g_path_name   CONSTANT VARCHAR2(200)  := 'fv.plsql.fvxlaapb.fv_sla_ap_processing_pkg';
  C_STATE_LEVEL CONSTANT NUMBER       :=  FND_LOG.LEVEL_STATEMENT;
  C_PROC_LEVEL  CONSTANT  NUMBER       :=  FND_LOG.LEVEL_PROCEDURE;
  g_adjustment_type VARCHAR2(30);

  PROCEDURE trace
  (
    p_level             IN NUMBER,
    p_procedure_name    IN VARCHAR2,
    p_debug_info        IN VARCHAR2
  )
  IS
  BEGIN
    fv_sla_utl_processing_pkg.trace
    (
      p_level             => p_level,
      p_procedure_name    => p_procedure_name,
      p_debug_info        => p_debug_info
    );
  END trace;

  PROCEDURE stack_error
  (
    p_program_name  IN VARCHAR2,
    p_location      IN VARCHAR2,
    p_error_message IN VARCHAR2
  )
  IS
  BEGIN
    fv_sla_utl_processing_pkg.stack_error
    (
      p_program_name  => p_program_name,
      p_location      => p_location,
      p_error_message => p_error_message
    );
  END;

  PROCEDURE init
  IS
    l_procedure_name       VARCHAR2(100) :='.init';
  BEGIN
    trace(C_STATE_LEVEL, l_procedure_name, 'Package Information');
    trace(C_STATE_LEVEL, l_procedure_name, '$Header: FVXLAAPB.pls 120.0.12010000.1 2010/02/10 19:34:46 sasukuma noship $');
  END;

FUNCTION get_fund_value
(p_coaid                IN          NUMBER,
 p_ccid                 IN          NUMBER,
 p_gl_account_segment   OUT NOCOPY  NUMBER,
 p_gl_balancing_segment OUT NOCOPY  NUMBER
)
RETURN VARCHAR2
IS
    l_debug_info                   VARCHAR2(240);
    l_procedure_name               VARCHAR2(100) :='.GET_FUND_VALUE';

    l_result         BOOLEAN;
    l_fund_value                   VARCHAR2(30);
BEGIN

    l_procedure_name := g_path_name || l_procedure_name;
    -------------------------------------------------------------------------
    l_debug_info := 'Begin of procedure '||l_procedure_name;
    trace(C_STATE_LEVEL, l_procedure_name, l_debug_info);
    -------------------------------------------------------------------------
    -------------------------------------------------------------------------

        -- get the gl_account( natural account)
        IF (NOT FND_FLEX_APIS.GET_QUALIFIER_SEGNUM(APPL_ID                => 101,
                                                   KEY_FLEX_CODE          => 'GL#',
                                                   STRUCTURE_NUMBER       => p_coaid,
                                                   FLEX_QUAL_NAME         => 'GL_ACCOUNT',
                                                   SEGMENT_NUMBER         => p_gl_account_segment))  THEN

              --Raise GET_QUALIFIER_SEGNUM_EXCEP;
              NULL;
        END IF;
        --DEBUG('GL_Account_segment'||p_gl_account_segment);
        -- get the gl_balancing
        IF (NOT FND_FLEX_APIS.GET_QUALIFIER_SEGNUM(APPL_ID           => 101,
                                                   KEY_FLEX_CODE     => 'GL#',
                                                   STRUCTURE_NUMBER  => p_coaid,
                                                   FLEX_QUAL_NAME    => 'GL_BALANCING',
                                                   SEGMENT_NUMBER    => p_gl_balancing_segment))  THEN

             --Raise GET_QUALIFIER_SEGNUM_EXCEP;
             NULL;
        END IF;

       -- DEBUG('GL_balancing_segment'||p_gl_balancing_segment);

                         -- get the balancing segment value from the charge CCID
         l_result :=   FND_FLEX_KEYVAL.validate_ccid (
                        appl_short_name => 'SQLGL',
                        key_flex_code => 'GL#',
                        structure_number =>  p_coaid,
                        combination_id =>  p_ccid);

         l_fund_value:=FND_FLEX_KEYVAL.segment_value(p_gl_balancing_segment);

        -- DEBUG('Charge CCID '||p_ccid);
        -- DEBUG('Fund Value'||  l_fund_value);

      -------------------------------------------------------------------------
      l_debug_info := 'End of procedure '||l_procedure_name;
      trace(C_PROC_LEVEL, l_procedure_name, l_debug_info);
      -------------------------------------------------------------------------

      RETURN l_fund_value;

EXCEPTION

  WHEN OTHERS THEN
     l_debug_info := 'Error in Federal SLA processing ' || SQLERRM;
     trace(C_STATE_LEVEL, l_procedure_name, l_debug_info);
     FND_MESSAGE.SET_NAME('FND', 'FND_GENERIC_MESSAGE');
     FND_MESSAGE.SET_TOKEN('MESSAGE' ,
         'Procedure :fv_sla_processing_pkg.get_fund_value'|| CRLF||
         'Error     :'||SQLERRM);
     FND_MSG_PUB.ADD;
     APP_EXCEPTION.RAISE_EXCEPTION;

END get_fund_value;

/*Fund details*/
PROCEDURE get_fund_details
(
p_application_id           IN        NUMBER,
p_ledger_id                IN        VARCHAR2,
p_fund_value               IN        VARCHAR2,
p_gl_date                  IN        DATE,
p_fund_category            OUT NOCOPY          VARCHAR2,
p_fund_status              OUT NOCOPY          VARCHAR2
)
IS
    l_debug_info                   VARCHAR2(240);
    l_procedure_name               VARCHAR2(100) :='.GET_FUND_DETAILS';

    CURSOR c_get_fund_details IS
    SELECT fund_category, fund_expire_date
      FROM FV_FUND_PARAMETERS
     WHERE FUND_VALUE=P_fund_value;

    l_fund_details            c_get_fund_details%ROWTYPE;

BEGIN

    l_procedure_name := g_path_name || l_procedure_name;
    -------------------------------------------------------------------------
    l_debug_info := 'Begin of procedure '||l_procedure_name;
    trace(C_STATE_LEVEL, l_procedure_name, l_debug_info);
    -------------------------------------------------------------------------
    -------------------------------------------------------------------------

      p_fund_status    := NULL;
      p_fund_category  := NULL;

      -- get the fund category and expiration date
      OPEN c_get_fund_details;
      FETCH c_get_fund_details INTO l_fund_details;
      IF c_get_fund_details%FOUND THEN
           -- fund category
           IF p_application_id = 201 THEN
               IF l_fund_details.fund_category IN ('A','S') THEN
                    p_fund_category := 'A';
               ELSIF l_fund_details.fund_category IN ('B','T') THEN
                    p_fund_category := 'B';
               ELSE
                    p_fund_category := 'C';
               END IF;
           ELSIF p_application_id IN (707, 200, 222) THEN
               p_fund_category := l_fund_details.fund_category;
           END IF;

           -- fund expired
           IF l_fund_details.fund_expire_date < p_gl_date THEN
                 p_fund_status := 'Expired';
           ELSE
                 p_fund_status := 'Unexpired';
           END IF;


       ELSE
           p_fund_status     := NULL;
           p_fund_category   := NULL;
      END IF;
      CLOSE c_get_fund_details;

      -------------------------------------------------------------------------
      l_debug_info := 'End of procedure '||l_procedure_name;
      trace(C_PROC_LEVEL, l_procedure_name, l_debug_info);
      -------------------------------------------------------------------------
EXCEPTION
  WHEN OTHERS THEN
     l_debug_info := 'Error in Federal SLA processing ' || SQLERRM;
     trace(C_STATE_LEVEL, l_procedure_name, l_debug_info);
     FND_MESSAGE.SET_NAME('FND', 'FND_GENERIC_MESSAGE');
     FND_MESSAGE.SET_TOKEN('MESSAGE' ,
         'Procedure :fv_sla_processing_pkg.get_fund_details'|| CRLF||
         'Error     :'||SQLERRM);
     FND_MSG_PUB.ADD;
     APP_EXCEPTION.RAISE_EXCEPTION;

END get_fund_details;

FUNCTION get_prior_year_status
(
p_application_id             IN         NUMBER,
p_ledger_id                  IN         NUMBER,
p_coa_id           IN         NUMBER,
p_ccid                       IN         NUMBER,
p_gl_date                    IN         DATE
)
RETURN BOOLEAN
IS

    l_debug_info                   VARCHAR2(240);
    l_procedure_name               VARCHAR2(100) := '.GET_PRIOR_YEAR_STATUS';


    CURSOR c_get_bfy_segment IS
    SELECT application_column_name, fyr_segment_id
      FROM fv_pya_fiscalyear_segment
     WHERE set_of_books_id = p_ledger_id;


    CURSOR c_get_bfy_value (p_segment_id VARCHAR2, p_segment_value VARCHAR2 ) IS
    SELECT period_year
      FROM fv_pya_fiscalyear_map
     WHERE set_of_books_id = p_ledger_id
       AND fyr_segment_id = p_segment_id
       AND fyr_segment_value = p_segment_value;

--Bug 7169941. Added condition to exclude Adjustment periods
--Bug 7169941. Added trunc.

    CURSOR c_get_gl_fiscal_year IS
    SELECT period_year, period_name
      FROM gl_period_statuses
     WHERE ledger_id = p_ledger_id
       AND application_id = p_application_id
       AND (trunc(p_gl_date)  BETWEEN start_date AND end_date)
       and ADJUSTMENT_PERIOD_FLAG='N';

    l_transaction_year          c_get_gl_fiscal_year%ROWTYPE;
    l_bfy_segment               c_get_bfy_segment%ROWTYPE;
    l_bfy_value                 C_get_bfy_value%ROWTYPE;
    l_bfy_segment_value         VARCHAR2(25);

BEGIN

    l_procedure_name := g_path_name || l_procedure_name;
    -------------------------------------------------------------------------
    l_debug_info := 'Begin of procedure '||l_procedure_name;
    trace(C_STATE_LEVEL, l_procedure_name, l_debug_info);
    -------------------------------------------------------------------------
    -------------------------------------------------------------------------
          g_adjustment_type := Null;
         -- Determine the prior year transaction
         OPEN c_get_bfy_segment;
         FETCH c_get_bfy_segment INTO l_bfy_segment;
         -- ================================== FND_LOG ==================================
         l_debug_info := 'BFY Segment column name: '|| l_bfy_segment.application_column_name ||
         ', BFY Segment column ID: ' || l_bfy_segment.fyr_segment_id;
         trace(C_STATE_LEVEL, l_procedure_name, l_debug_info);
         -- ================================== FND_LOG ==================================
         IF c_get_bfy_segment%NOTFOUND THEN
             RAISE NO_DATA_FOUND;
         END IF;
         CLOSE c_get_bfy_segment;

        -- DEBUG('Fiscal year segment '|| l_bfy_segment.application_column_name);

         EXECUTE IMMEDIATE 'SELECT ' || l_bfy_segment.application_column_name ||
                                      ' FROM gl_code_combinations WHERE code_combination_id = :x_ccid' ||
                                      ' AND  chart_of_accounts_id = :x_coaid '
         INTO l_bfy_segment_value USING p_ccid, p_coa_id;
         -- ================================== FND_LOG ==================================
         l_debug_info := 'BFY Segment value from gl_code_combinations table: '|| l_bfy_segment_value;
         trace(C_STATE_LEVEL, l_procedure_name, l_debug_info);
         -- ================================== FND_LOG ==================================
         -- DEBUG('Fiscal year segment value '||l_bfy_segment_value);

         OPEN  c_get_bfy_value (l_bfy_segment.fyr_segment_id ,
                                l_bfy_segment_value);
         FETCH c_get_bfy_value INTO l_bfy_value;
         -- ================================== FND_LOG ==================================
         l_debug_info := 'BFY period year: '|| l_bfy_value.period_year;
         trace(C_STATE_LEVEL, l_procedure_name, l_debug_info);
         -- ================================== FND_LOG ==================================
         IF c_get_bfy_value%NOTFOUND THEN
             RAISE NO_DATA_FOUND;
         END IF;
         CLOSE c_get_bfy_value;

         -- get the fiscal year for the GL_DATE of the transction
         OPEN c_get_gl_fiscal_year;
         FETCH c_get_gl_fiscal_year INTO l_transaction_year;
         -- ================================== FND_LOG ==================================
         l_debug_info := 'Fiscal year: '|| l_transaction_year.period_year ;
         trace(C_STATE_LEVEL, l_procedure_name, l_debug_info);
         -- ================================== FND_LOG ==================================
         IF c_get_gl_fiscal_year%NOTFOUND THEN
             RAISE NO_DATA_FOUND;
         END IF;
         CLOSE c_get_gl_fiscal_year;

        -- DEBUG('Transaction year '|| l_transaction_year.period_year);

         IF l_transaction_year.period_year <> l_bfy_value.period_year THEN
              -------------------------------------------------------------------------
              l_debug_info := 'End of procedure'||l_procedure_name;
              trace(C_PROC_LEVEL, l_procedure_name, l_debug_info);
              -------------------------------------------------------------------------
             IF l_transaction_year.period_year > l_bfy_value.period_year THEN
                  g_adjustment_type := 'Upward';
              ELSIF l_transaction_year.period_year < l_bfy_value.period_year THEN
                  g_adjustment_type := 'Downward';
              END IF;

              RETURN TRUE;
         ELSE
              -------------------------------------------------------------------------
              l_debug_info := 'End of procedure'||l_procedure_name;
              trace(C_PROC_LEVEL, l_procedure_name, l_debug_info);
              -------------------------------------------------------------------------
              RETURN FALSE;
         END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
     l_debug_info := 'Error: Federal setup is incomplete';
     trace(C_STATE_LEVEL, l_procedure_name, l_debug_info);
     FND_MESSAGE.SET_NAME('FND', 'FND_GENERIC_MESSAGE');
     FND_MESSAGE.SET_TOKEN('MESSAGE' ,
         'Procedure :fv_sla_processing_pkg.get_prior_year_status'|| CRLF||
         'Error     :Federal setup is incomplete');
     FND_MSG_PUB.ADD;
     APP_EXCEPTION.RAISE_EXCEPTION;

  WHEN OTHERS THEN
     l_debug_info := 'Error in Federal SLA processing ' || SQLERRM ;
     trace(C_STATE_LEVEL, l_procedure_name, l_debug_info);
     FND_MESSAGE.SET_NAME('FND', 'FND_GENERIC_MESSAGE');
     FND_MESSAGE.SET_TOKEN('MESSAGE' ,
         'Procedure :fv_sla_processing_pkg.get_prior_year_status'|| CRLF||
         'Error     :'||SQLERRM);
     FND_MSG_PUB.ADD;
     APP_EXCEPTION.RAISE_EXCEPTION;

END get_prior_year_status;


--
--
-- Function to derive the balance amount for the fund and antipicated segment
-- returns the period balances for the account
-- Logic
--    1. with the inputs constructs the CCID
--    2. queries the gl_balances for the period and returns the balances
--
--
FUNCTION get_anticipated_fund_amt( p_Fund_value        IN VARCHAR2,
                                   p_Balancing_segment IN NUMBER,
                                   p_Natural_segment   IN NUMBER,
                                   p_Ledger_id         IN NUMBER,
                                   p_coaid             IN  NUMBER,
                                   p_Period_name       IN  VARCHAR2)
RETURN NUMBER
IS
    l_debug_info                   VARCHAR2(240);
    l_procedure_name               VARCHAR2(100) :='.GET_ANTICIPATED_FUND_AMT';

     CURSOR c_anticipated_acct IS
     SELECT  ussgl_account --, template_id
     FROM  Fv_Facts_Ussgl_Accounts
     WHERE  anticipated_unanticipated = 'Y';

     CURSOR c_template_id is
     SELECT template_id
     FROM FV_PYA_FISCALYEAR_SEGMENT
     WHERE set_of_books_id = p_ledger_id;

     CURSOR c_currency_code IS
     SELECT currency_code
     FROM gl_ledgers
     WHERE ledger_id = p_Ledger_id;

     CURSOR c_period (c_ledger_id NUMBER,
                      c_period_name VARCHAR2) IS
     SELECT period_year, period_num
     FROM gl_period_statuses
     WHERE ledger_id = c_ledger_id
       AND application_id = 101
       AND period_name = c_period_name;

     --l_anticipated_acct        VARCHAR2(30);
     l_template_id             NUMBER;
     l_currency_code           VARCHAR2(30);
     l_ccid        Gl_Code_Combinations.code_combination_id%TYPE;
     l_fund_value  Fv_Fund_Parameters.fund_value%TYPE;
     l_amount      NUMBER;
     l_tot_amount NUMBER := 0;

     -- Variable declartions for Dynamic SQL
     l_fund_cur_id  INTEGER;
     l_fund_select  VARCHAR2(2000);
     l_fund_ret      INTEGER;
     l_period_year  NUMBER;
     l_period_num   NUMBER;

     template_id_exception exception;
     anticipated_exception exception;

BEGIN

    l_procedure_name := g_path_name || l_procedure_name;
    -------------------------------------------------------------------------
    l_debug_info := 'Begin of procedure '||l_procedure_name;
    trace(C_STATE_LEVEL, l_procedure_name, l_debug_info);
    -------------------------------------------------------------------------
    -------------------------------------------------------------------------
/*
    OPEN c_anticipated_acct;
    FETCH c_anticipated_acct INTO l_anticipated_acct;
    if c_anticipated_acct%notfound then
     CLOSE c_anticipated_acct;
     raise anticipated_exception;
    end if;
    CLOSE c_anticipated_acct;

    trace(C_STATE_LEVEL, l_procedure_name, 'l_anticipated_acct='||l_anticipated_acct);
*/

    OPEN c_template_id;
    FETCH c_template_id INTO l_template_id;
    if c_template_id%notfound then
      CLOSE c_template_id;
      raise template_id_exception;
    end if;
    CLOSE c_template_id;

    trace(C_STATE_LEVEL, l_procedure_name, 'l_template_id='||l_template_id);

    OPEN c_currency_code;
    FETCH c_currency_code into l_currency_code;
    CLOSE c_currency_code;

    trace(C_STATE_LEVEL, l_procedure_name, 'l_currency_code='||l_currency_code);

    OPEN c_period (p_Ledger_id, p_Period_name);
    FETCH c_period into l_period_year, l_period_num;
    CLOSE c_period;
    trace(C_STATE_LEVEL, l_procedure_name, 'l_period_year='||l_period_year);
    trace(C_STATE_LEVEL, l_procedure_name, 'l_period_num='||l_period_num);

    -- get the ccid that contains this fund in its balancing segment
    -- and this anticipated account in Natural account segment
    -- assumption is federal would set up summary template for the anticpated account

     l_fund_cur_id := DBMS_SQL.OPEN_CURSOR;

     --Build the Select statement for getting the fund values and ccids
     l_fund_select := 'SELECT code_combination_id ' ||
                      ' FROM  Gl_Code_Combinations ' ||
                      ' WHERE chart_of_accounts_id = :p_coaid AND '||
                      'segment'||p_balancing_segment || ' = :p_fund_value AND ' ||
                      'template_id = :p_template_id AND '||
                      'Summary_flag = ''Y''' ;
    -------------------------------------------------------------------------
    trace(C_STATE_LEVEL, l_procedure_name, 'p_coaid='||p_coaid);
    trace(C_STATE_LEVEL, l_procedure_name, 'p_fund_value='||p_fund_value);
    trace(C_STATE_LEVEL, l_procedure_name, 'l_template_id='||l_template_id);
    trace(C_STATE_LEVEL, l_procedure_name, 'l_fund_select='||l_fund_select);
    -------------------------------------------------------------------------

    -------------------------------------------------------------------------
    trace(C_STATE_LEVEL, l_procedure_name, 'parse');
    -------------------------------------------------------------------------
     DBMS_SQL.PARSE(l_fund_cur_id, l_fund_select, DBMS_SQL.Native);
     DBMS_SQL.BIND_VARIABLE(l_fund_cur_id, ':p_coaid', p_coaid);
     DBMS_SQL.BIND_VARIABLE(l_fund_cur_id, ':p_fund_value', p_fund_value, 25);
     DBMS_SQL.BIND_VARIABLE(l_fund_cur_id, ':p_template_id', l_template_id, 30);

    -------------------------------------------------------------------------
    trace(C_STATE_LEVEL, l_procedure_name, 'DEFINE_COLUMN');
    -------------------------------------------------------------------------
     DBMS_SQL.DEFINE_COLUMN(l_fund_cur_id,1,l_ccid);

     l_fund_ret := DBMS_SQL.EXECUTE(l_fund_cur_id);

     LOOP
     -- Fetch the ccid's  from Gl_Code_Combinations
    -------------------------------------------------------------------------
    trace(C_STATE_LEVEL, l_procedure_name, 'FETCH_ROWS');
    -------------------------------------------------------------------------
     IF DBMS_SQL.FETCH_ROWS(l_fund_cur_id) = 0 THEN
    -------------------------------------------------------------------------
    trace(C_STATE_LEVEL, l_procedure_name, 'EXIT');
    -------------------------------------------------------------------------
      EXIT;
          ELSE
    -------------------------------------------------------------------------
    trace(C_STATE_LEVEL, l_procedure_name, 'COLUMN_VALUE');
    -------------------------------------------------------------------------
       DBMS_SQL.COLUMN_VALUE(l_fund_cur_id, 1,l_ccid);
    END IF;


       /*SELECT SUM((begin_balance_dr - begin_balance_cr) +
                        (period_net_dr - period_net_cr))
       INTO  l_amount
             FROM  Gl_Balances
             WHERE    ledger_id          = p_Ledger_id
        --AND   currency_code       = vp_currency_code
       AND      code_combination_id = l_ccid
       AND    period_name        = p_period_name;

    SELECT  code_combination_id
    INTO    l_ccid
    FROM    gl_code_combinations
    WHERE   chart_of_accounts_id = p_coaid
        AND     template_id = l_template_id
     AND     summary_flag = 'Y';*/

      -------------------------------------------------------------------------
      l_debug_info := 'Before calling calc_funds';
      trace(C_PROC_LEVEL, l_procedure_name, l_debug_info);
      -------------------------------------------------------------------------
    -------------------------------------------------------------------------
    trace(C_STATE_LEVEL, l_procedure_name, 'l_ccid='||l_ccid);
    trace(C_STATE_LEVEL, l_procedure_name, 'l_template_id='||l_template_id);
    trace(C_STATE_LEVEL, l_procedure_name, 'p_ledger_id='||p_ledger_id);
    trace(C_STATE_LEVEL, l_procedure_name, 'p_period_name='||p_period_name);
    trace(C_STATE_LEVEL, l_procedure_name, 'l_currency_code='||l_currency_code);
    SELECT SUM((begin_balance_dr - begin_balance_cr) +
                        (period_net_dr - period_net_cr))
       INTO  l_amount
             FROM  Gl_Balances
             WHERE    ledger_id          = p_Ledger_id
        AND   currency_code       = l_currency_code
       AND      code_combination_id = l_ccid
       AND    period_name        = p_period_name;
    trace(C_STATE_LEVEL, l_procedure_name, ' gl_balances l_amount='||l_amount);
    -------------------------------------------------------------------------
/*     l_amount := 0;
     l_amount :=      gl_funds_available_pkg.calc_funds(
                                            l_ccid       ,
                                            l_template_id,
                                            p_ledger_id  ,
                                            p_period_name,
                                            l_currency_code);

    trace(C_STATE_LEVEL, l_procedure_name, ' gl_funds_available_pkg l_amount='||l_amount);
*/
      l_tot_amount := l_tot_amount + NVL(l_amount, 0);

    trace(C_STATE_LEVEL, l_procedure_name, ' gl_balances l_tot_amount='||l_tot_amount);

    SELECT SUM(NVL(accounted_dr,0) - NVL(accounted_cr,0))
       INTO  l_amount
             FROM  Gl_bc_packets gbc,
                   gl_account_hierarchies gah
             WHERE    gbc.ledger_id          = p_Ledger_id
               AND gah.ledger_id = p_Ledger_id
               AND gah.template_id = l_template_id
               AND gah.summary_code_combination_id = l_ccid
        AND   gbc.currency_code       = l_currency_code
       AND      gbc.code_combination_id = gah.detail_code_combination_id
       AND    gbc.period_year        = l_period_year
       AND gbc.period_num <= l_period_num
                   AND  gbc.status_code = 'A';
    trace(C_STATE_LEVEL, l_procedure_name, ' gl_bc_packets l_amount='||l_amount);

      l_tot_amount := l_tot_amount + NVL(l_amount, 0);

    trace(C_STATE_LEVEL, l_procedure_name, ' gl_bc_packets l_tot_amount='||l_tot_amount);
    END LOOP;
    dbms_sql.close_cursor (l_fund_cur_id);
      RETURN l_tot_amount;
      -------------------------------------------------------------------------
      l_debug_info := 'End of procedure '||l_procedure_name;
      trace(C_PROC_LEVEL, l_procedure_name, l_debug_info);
      -------------------------------------------------------------------------

EXCEPTION

  WHEN template_id_exception then
     l_debug_info := 'Error in Federal SLA processing ' || SQLERRM;
     trace(C_STATE_LEVEL, l_procedure_name, l_debug_info);
     FND_MESSAGE.SET_NAME('FND', 'FND_GENERIC_MESSAGE');
     FND_MESSAGE.SET_TOKEN('MESSAGE' ,
         'Get_Anticipated_Fund_Amt:No summary Template found for the ledger.Please Associate a Summary'||
     'Template to the ledger in the Federal Financial Options form.');
     FND_MSG_PUB.ADD;
     APP_EXCEPTION.RAISE_EXCEPTION;

  WHEN anticipated_exception then
     l_debug_info := 'Error in Federal SLA processing ' || SQLERRM;
     trace(C_STATE_LEVEL, l_procedure_name, l_debug_info);
     FND_MESSAGE.SET_NAME('FND', 'FND_GENERIC_MESSAGE');
     FND_MESSAGE.SET_TOKEN('MESSAGE' ,
         'Get_Anticipated_Fund_Amt:No anticipated account has been set. Please set an anticipated account in the USSGL Accounts form.');
     FND_MSG_PUB.ADD;
     APP_EXCEPTION.RAISE_EXCEPTION;


  WHEN OTHERS THEN
     l_debug_info := 'Error in Federal SLA processing ' || SQLERRM;
     trace(C_STATE_LEVEL, l_procedure_name, l_debug_info);
     FND_MESSAGE.SET_NAME('FND', 'FND_GENERIC_MESSAGE');
     FND_MESSAGE.SET_TOKEN('MESSAGE' ,
         'Procedure :fv_sla_processing_pkg.get_anticipated_fund_amt'|| CRLF||
         'Error     :'||SQLERRM);
     FND_MSG_PUB.ADD;
     APP_EXCEPTION.RAISE_EXCEPTION;

END get_anticipated_fund_amt;

PROCEDURE ap_extract
(
  p_application_id               IN            NUMBER,
  p_accounting_mode              IN            VARCHAR2
)
IS


  l_debug_info                   VARCHAR2(240);
  l_procedure_name               VARCHAR2(100):='.AP_EXTRACT';

    CURSOR c_ledger_info( p_event_id NUMBER ) IS
    SELECT chart_of_accounts_id coaid, gl.Ledger_id ledger_id
    FROM xla_events_gt xgt ,gl_ledgers gl
    WHERE gl.ledger_id = xgt.ledger_id
    AND   xgt.application_id = p_application_id
    AND   xgt.event_id = p_event_id;

    CURSOR c_ap_invoice_details IS
    SELECT  apinvdt.*
    FROM AP_EXTRACT_INVOICE_DTLS_BC_V apinvdt,
         XLA_EVENTS_GT xlagt
         where apinvdt.event_id = xlagt.event_id;

    CURSOR c_ap_invoice_header(p_event_id number) IS
    SELECT  apinvhd.*
    FROM AP_INVOICE_EXTRACT_HEADER_V apinvhd,
          XLA_EVENTS_GT xlagt
         where apinvhd.event_id = xlagt.event_id;

    CURSOR c_ap_payment_details IS
    SELECT  appaydd.*
    FROM AP_PAYMENT_EXTRACT_DETAILS_V appaydd,
         xla_events_gt xlagt
         where appaydd.event_id = xlagt.event_id;

    CURSOR c_ap_payment_header(p_event_id NUMBER) IS
    SELECT  appayhd.*
    FROM AP_PAYMENT_EXTRACT_HEADER_V appayhd,
       xla_events_gt xlagt
     where appayhd.event_id = xlagt.event_id;

    CURSOR c_po_dist_info(p_po_distribution_id NUMBER) IS
  SELECT *
  FROM po_distributions_all pod
  WHERE pod.po_distribution_id = p_po_distribution_id;

  CURSOR c_get_event_code(p_event_id NUMBER) IS
    SELECT  event_type_code
    FROM     xla_events_gt
    WHERE     event_id = p_event_id;

    CURSOR c_get_gl_fiscal_year(p_ledger_id NUMBER, p_gl_date DATE) IS
    SELECT period_year, period_name
    FROM    Gl_Period_Statuses
    WHERE   ledger_id = p_ledger_id
    AND     p_gl_date BETWEEN START_DATE AND end_date ;

    l_accounting_mode              VARCHAR2(20);
    l_ledger_info                  c_ledger_info%ROWTYPE;
    l_gl_balancing_segment         NUMBER;
    l_gl_account_segment           NUMBER;
    l_index                        NUMBER;
    l_federal_downward_amount      NUMBER;
    l_fv_extract_detail            fv_sla_utl_processing_pkg.fv_ref_detail;
    l_invoice_extract_detail_rec   c_ap_invoice_details%ROWTYPE;
    l_invoice_extract_header_rec   c_ap_invoice_header%ROWTYPE;
    l_payment_extract_detail_rec   c_ap_payment_details%ROWTYPE;
    l_payment_extract_header_rec   c_ap_payment_header%ROWTYPE;
    l_po_dist_info_rec             c_po_dist_info%ROWTYPE;
    l_get_event_code_rec           c_get_event_code%ROWTYPE;
    l_gl_date                   DATE;
    l_pya                          BOOLEAN;
    l_original_pya                 BOOLEAN;
    l_net_pya_adj_amt              NUMBER;
    l_balance_amt                  NUMBER;
    l_result               BOOLEAN;
    l_fund_value                   VARCHAR(30);
    l_transaction_year        c_get_gl_fiscal_year%ROWTYPE;

BEGIN

    l_procedure_name := g_path_name || l_procedure_name;
    -------------------------------------------------------------------------
    l_debug_info := 'Begin of procedure '||l_procedure_name;
    trace(C_STATE_LEVEL, l_procedure_name, l_debug_info);
    -------------------------------------------------------------------------

  IF (p_application_id <> 200) THEN
    RETURN;
  END IF;

         l_index:=0;
        --Process invoice events
        FOR xla_rec in (select * from XLA_EVENTS_GT) loop
          trace (C_STATE_LEVEL, l_procedure_name, 'line_number='||xla_rec.line_number);
          trace (C_STATE_LEVEL, l_procedure_name, 'entity_id='||xla_rec.entity_id);
          trace (C_STATE_LEVEL, l_procedure_name, 'application_id='||xla_rec.application_id);
          trace (C_STATE_LEVEL, l_procedure_name, 'transaction_number='||xla_rec.transaction_number);
          trace (C_STATE_LEVEL, l_procedure_name, 'event_id='||xla_rec.event_id);
          trace (C_STATE_LEVEL, l_procedure_name, 'event_type_code='||xla_rec.event_type_code);
          trace (C_STATE_LEVEL, l_procedure_name, 'budgetary_control_flag='||xla_rec.budgetary_control_flag);
        end loop;

        FOR l_invoice_extract_detail_rec IN c_ap_invoice_details LOOP
              -------------------------------------------------------------------------
             l_debug_info := 'Inside Federal extract loop';
             trace(C_PROC_LEVEL, l_procedure_name, l_debug_info);
             l_debug_info := 'inv dist id '|| l_invoice_extract_detail_rec.inv_distribution_identifier;
             trace(C_PROC_LEVEL, l_procedure_name, l_debug_info);
             l_debug_info := 'event  id '|| l_invoice_extract_detail_rec.event_id;
             trace(C_PROC_LEVEL, l_procedure_name, l_debug_info);
            -------------------------------------------------------------------------

             OPEN c_get_event_code( l_invoice_extract_detail_rec.event_id);
             FETCH c_get_event_code INTO l_get_event_code_rec;
             IF c_get_event_code%NOTFOUND THEN
                  CLOSE c_get_event_code;
                  RETURN;
             END IF;
             CLOSE c_get_event_code;

      -------------------------------------------------------------------------
         l_debug_info := 'l_event_type_code'||l_get_event_code_rec.event_type_code;
         trace(C_PROC_LEVEL, l_procedure_name, l_debug_info);
         -------------------------------------------------------------------------

             IF l_get_event_code_rec.event_type_code IN
                  ('CREDIT MEMO ADJUSTED', 'CREDIT MEMO VALIDATED', 'CREDIT MEMO CANCELLED',
                   'DEBIT MEMO ADJUSTED', 'DEBIT MEMO VALIDATED', 'DEBIT MEMO CANCELLED',
                   'INVOICE ADJUSTED', 'INVOICE VALIDATED', 'INVOICE CANCELLED','PREPAYMENT ADJUSTED',
                   'PREPAYMENT CANCELLED','PREPAYMENT VALIDATED')
             THEN

    -------------------------------------------------------------------------
         l_debug_info := 'Inside the IF condition';
         trace(C_PROC_LEVEL, l_procedure_name, l_debug_info);
         -------------------------------------------------------------------------

           OPEN c_ap_invoice_header(l_invoice_extract_detail_rec.event_id);
                 FETCH c_ap_invoice_header INTO l_invoice_extract_header_rec;
                 IF c_ap_invoice_header%NOTFOUND THEN
                      CLOSE c_ap_invoice_header;
                      RETURN;
                 END IF;
                 CLOSE c_ap_invoice_header;

                 OPEN c_po_dist_info(l_invoice_extract_detail_rec.po_distribution_id);
                 FETCH c_po_dist_info INTO l_po_dist_info_rec;
                 IF c_po_dist_info%NOTFOUND THEN
                      CLOSE c_po_dist_info; -- change this to null if no processing needed
--                      RETURN; comment by Senthil
                 END IF;
                 IF c_po_dist_info%ISOPEN THEN -- ashish
                 CLOSE c_po_dist_info;
                 END IF;

                 --
                 -- Get the chart of accounts from legder and identify the segement qualifers
                 -- gl_balancing and natural account
                 --
                 OPEN c_ledger_info( l_invoice_extract_detail_rec.event_id);
                 FETCH c_ledger_info INTO l_ledger_info;
                 IF c_ledger_info%NOTFOUND THEN
                      CLOSE c_ledger_info;
                      RETURN;
                 END IF;
                 CLOSE c_ledger_info;

                 l_index := l_index + 1;
                 l_fv_extract_detail(l_index).event_id := l_invoice_extract_detail_rec.event_id;
                 l_fv_extract_detail(l_index).Line_Number := l_invoice_extract_detail_rec.Line_number;
                 l_fv_extract_detail(l_index).Application_id := p_application_id;


                 l_fund_value := get_fund_value(l_ledger_info.coaid,
                                                case
                                                      when l_invoice_extract_detail_rec.po_distribution_id is Not null
                                                      Then
                                                          l_po_dist_info_rec.code_combination_id
                                                      else
                                                      l_invoice_extract_detail_rec.aid_dist_ccid
                                                   end ,
                                                l_gl_account_segment,
                                                l_gl_balancing_segment);
                 l_fv_extract_detail(l_index).fund_value :=l_fund_value;

                 --DEBUG('Budget CCID '|| l_po_dist_info_rec.code_combination_id);
                 --DEBUG('Fund Value'||  l_fund_value);

                   -- get the fund category and expiration date
                 get_fund_details( p_application_id,
                                   l_ledger_info.ledger_id,
           l_fund_value,
           l_invoice_extract_detail_rec.aid_accounting_date,
           l_fv_extract_detail(l_index).fund_category,
           l_fv_extract_detail(l_index).fund_expired_status
                                 );

                 -- prior year flag -- requsition donot have prior year transactions
                 l_fv_extract_detail(l_index).prior_year_flag := 'N';

                 /* If there is any reversal line which is pya orginially use a diff logic */
                 l_original_pya := FALSE;
                 FOR previous_dist_rec IN (SELECT *
                                             FROM ap_invoice_distributions_all
                                            WHERE invoice_distribution_id = l_invoice_extract_detail_rec.aid_parent_reversal_id) LOOP
                 l_original_pya := get_prior_year_status ( p_application_id,
                                                  l_ledger_info.ledger_id,
                                                  l_ledger_info.coaid,
                                      case
                                                      when l_invoice_extract_detail_rec.po_distribution_id is Not null
                                                      Then
                                                          l_po_dist_info_rec.code_combination_id
                                                      else
                                                      l_invoice_extract_detail_rec.aid_dist_ccid
                                                   end ,
                                                  previous_dist_rec.accounting_date
                          );
                 END LOOP;


                 l_pya := get_prior_year_status ( p_application_id,
                                                  l_ledger_info.ledger_id,
                                                  l_ledger_info.coaid,
                                      case
                                                      when l_invoice_extract_detail_rec.po_distribution_id is Not null
                                                      Then
                                                          l_po_dist_info_rec.code_combination_id
                                                      else
                                                      l_invoice_extract_detail_rec.aid_dist_ccid
                                                   end ,
                                                  l_invoice_extract_detail_rec.aid_accounting_date
                          );

                 IF l_pya THEN

                     l_fv_extract_detail(l_index).prior_year_flag := 'Y';
                     IF (l_invoice_extract_detail_rec.encumbrance_amount < 0 AND NOT l_original_pya) THEN
                         g_adjustment_type := 'Downward';

                         l_debug_info := 'Adjustment type set to Downward';
                         trace(C_PROC_LEVEL, l_procedure_name,l_debug_info);
        END IF;

                 END IF;

             END IF;

             /*Amount calculations*/
                IF l_invoice_extract_detail_rec.po_distribution_id is not null Then
                     l_fv_extract_detail(l_index).paid_unexpended_obligation   :=l_invoice_extract_detail_rec.encumbrance_base_amount;
                     l_fv_extract_detail(l_index).unpaid_unexpended_obligation :=l_invoice_extract_detail_rec.encumbrance_base_amount;
                 ELSE
                    l_fv_extract_detail(l_index).paid_unexpended_obligation   :=l_invoice_extract_detail_rec.aid_amount;
                    l_fv_extract_detail(l_index).unpaid_unexpended_obligation :=l_invoice_extract_detail_rec.aid_amount;
                END IF;
                 ---log to display the federal source values
                 -------------------------------------------------------
                  l_debug_info := 'start of federal source values'||l_index;
                 trace(C_PROC_LEVEL, l_procedure_name, l_debug_info);
                 l_debug_info := 'event_id.........................'||l_fv_extract_detail(l_index).event_id;
                 trace(C_PROC_LEVEL, l_procedure_name, l_debug_info);
                 l_debug_info := 'Line_Number......................'||l_fv_extract_detail(l_index).Line_Number;
                 trace(C_PROC_LEVEL, l_procedure_name, l_debug_info);
                 l_debug_info := 'fund_value.......................'||l_fv_extract_detail(l_index).fund_value;
                 trace(C_PROC_LEVEL, l_procedure_name, l_debug_info);
                 l_debug_info := 'fund_category....................'||l_fv_extract_detail(l_index).fund_category;
                 trace(C_PROC_LEVEL, l_procedure_name, l_debug_info);
                 l_debug_info := 'fund_expired_status..............'||l_fv_extract_detail(l_index).fund_expired_status;
                 trace(C_PROC_LEVEL, l_procedure_name, l_debug_info);
                 l_debug_info := 'prior_year_flag..................'||l_fv_extract_detail(l_index).prior_year_flag;
                 trace(C_PROC_LEVEL, l_procedure_name, l_debug_info);
                 l_debug_info := 'paid_unexpended_obligation.......'||l_fv_extract_detail(l_index).paid_unexpended_obligation;
                 trace(C_PROC_LEVEL, l_procedure_name, l_debug_info);
                 l_debug_info := 'unpaid_unexpended_obligation.....'||l_fv_extract_detail(l_index).unpaid_unexpended_obligation;
                 trace(C_PROC_LEVEL, l_procedure_name, l_debug_info);

                 -----------------------------------------------------------------

                ---- check for downward and upward adjustment if prior year
                l_fv_extract_detail(l_index).anticipation      := Null;
                l_fv_extract_detail(l_index).anticipated_amt   := Null;
                l_fv_extract_detail(l_index).unanticipated_amt := Null;

                If l_fv_extract_detail(l_index).prior_year_flag = 'Y' THEN

                   l_fv_extract_detail(l_index).anticipation := g_adjustment_type;
                   l_fv_extract_detail(l_index).adjustment_type :=g_adjustment_type;
                   ------------------------------------------------------------
                   l_debug_info := 'Prior Year =  YES..' || l_fv_extract_detail(l_index).prior_year_flag;
                   trace(C_STATE_LEVEL, l_procedure_name, l_debug_info);
                   ------------------------------------------------------------
                    If g_adjustment_type = 'Upward' THEN
                        l_fv_extract_detail(l_index).anticipated_amt :=l_invoice_extract_detail_rec.aid_amount;
                        ------------------------------------------------------------
                        l_debug_info := 'Adjustmemt Type =  ' || g_adjustment_type;
                        trace(C_STATE_LEVEL, l_procedure_name, l_debug_info);
                        l_debug_info := 'balance in the anticipated account =  ' || l_balance_amt;
                        trace(C_STATE_LEVEL, l_procedure_name, l_debug_info);
                        -------------------------------------------------------------
                    ---- end upward adjustment ---------
                    ELSIF (g_adjustment_type = 'Downward')   THEN
                           l_federal_downward_amount := l_invoice_extract_detail_rec.aid_amount;
                        -- Find the Anticipated Account
                       --   BEGIN  /* Anti Acct */
                       -- get the fiscal year for the GL_DATE of the transction
                       OPEN c_get_gl_fiscal_year( l_ledger_info.ledger_id,
                                          l_invoice_extract_detail_rec.aid_accounting_date);
                       FETCH c_get_gl_fiscal_year INTO l_transaction_year;
                       CLOSE c_get_gl_fiscal_year;

                        -- get the balances from account
                        l_balance_amt:=get_anticipated_fund_amt(p_Fund_value => l_fund_value,
                                                 p_Balancing_segment => l_gl_balancing_segment,
                                                 p_Natural_segment => l_gl_account_segment,
                                                 p_Ledger_id => l_ledger_info.ledger_id,
                                                 p_coaid     => l_ledger_info.coaid,
                                                 p_Period_name=> l_transaction_year.period_name);

                        l_balance_amt := Nvl(l_balance_amt,0);
                        --l_balance_amt := 0;
                        --psa_summ_det_combinations_v
                        l_fv_extract_detail(l_index).Anticipation      := Null;
                        l_fv_extract_detail(l_index).Anticipated_amt   := Null;
                        l_fv_extract_detail(l_index).UnAnticipated_amt := Null;
                        ------------------------------------------------------------
                        l_debug_info := 'Adjustmemt Type =  ' || g_adjustment_type;
                        trace(C_STATE_LEVEL, l_procedure_name, l_debug_info);
                        l_debug_info := 'balance in the anticipated account =  ' || l_balance_amt;
                        trace(C_STATE_LEVEL, l_procedure_name, l_debug_info);
                        -------------------------------------------------------------
                        IF l_balance_amt <= 0 THEN
                             -- unanticapted
                             l_fv_extract_detail(l_index).Anticipation := 'UnAnticipated';
                             l_fv_extract_detail(l_index).Anticipated_amt := 0;
                 --Bug#9219564
                             --l_fv_extract_detail(l_index).UnAnticipated_amt := abs(l_federal_downward_amount);
                             l_fv_extract_detail(l_index).UnAnticipated_amt := (l_federal_downward_amount);
                        ELSIF l_balance_amt > abs(l_federal_downward_amount) THEN
                            -- anticapted
                             l_fv_extract_detail(l_index).Anticipation := 'Anticipated';
                             l_fv_extract_detail(l_index).Anticipated_amt := abs(l_federal_downward_amount);
                             l_fv_extract_detail(l_index).UnAnticipated_amt := 0;
                        ELSIF l_balance_amt < abs(l_federal_downward_amount) THEN
                             l_fv_extract_detail(l_index).Anticipation := 'Partial';
                             l_fv_extract_detail(l_index).Anticipated_amt := abs(l_balance_amt);
                             l_fv_extract_detail(l_index).UnAnticipated_amt := abs(l_federal_downward_amount) - abs(l_balance_amt);
                        END IF; -- anticiaped values
                        ------------------------------------------------------------
                        l_debug_info := 'Anticipation =  ' || l_fv_extract_detail(l_index).Anticipation;
                        trace(C_STATE_LEVEL, l_procedure_name, l_debug_info);
                         l_debug_info := 'Anticipated Amount =  ' || l_fv_extract_detail(l_index).Anticipated_amt;
                        trace(C_STATE_LEVEL, l_procedure_name, l_debug_info);
                         l_debug_info := 'UnAnticipated Amount =  ' || l_fv_extract_detail(l_index).UnAnticipated_amt;
                        trace(C_STATE_LEVEL, l_procedure_name, l_debug_info);

                        -------------------------------------------------------------
                   -- end downward PYA adjustmemt
                    ELSE-- end downward anticipation
                        l_fv_extract_detail(l_index).Anticipation := Null;
                        l_fv_extract_detail(l_index).anticipated_amt := Null;
                        l_fv_extract_detail(l_index).unanticipated_amt :=Null;

                  END IF;
                END IF;
                -------------------------------------------------------------
                     l_debug_info := 'End of federal source............'||l_index;
                      trace(C_PROC_LEVEL, l_procedure_name, l_debug_info);
               -------------------------------------------------------------
         END LOOP;

       -- Process payment events
       -- Handled separtely in treasury confirmation
       -- start

              -------------------------------------------------------------
          l_debug_info := 'Begin of federal payment process.......sekhar.....'||l_index;
          trace(C_PROC_LEVEL, l_procedure_name, l_debug_info);
          -------------------------------------------------------------


       FOR l_payment_extract_detail_rec IN c_ap_payment_details LOOP
       -------------------------------------------------------------
          l_debug_info := 'Begin of federal payment process............'||l_index;
          trace(C_PROC_LEVEL, l_procedure_name, l_debug_info);
          -------------------------------------------------------------

             OPEN c_get_event_code( l_payment_extract_detail_rec.event_id);
             FETCH c_get_event_code INTO l_get_event_code_rec;
             IF c_get_event_code%NOTFOUND THEN
                  CLOSE c_get_event_code;
                  RETURN;
             END IF;
             CLOSE c_get_event_code;

             IF l_get_event_code_rec.event_type_code IN ('PAYMENT ADJUSTED', 'PAYMENT CREATED', 'PAYMENT CANCELLED') THEN

                 OPEN c_ap_payment_header(l_payment_extract_detail_rec.event_id);
                 FETCH c_ap_payment_header INTO l_payment_extract_header_rec;
                 IF c_ap_payment_header%NOTFOUND THEN
                      CLOSE c_ap_payment_header;
                      RETURN;
                 END IF;
                 CLOSE c_ap_payment_header;

                /* OPEN c_po_dist_info(l_payment_extract_detail_rec.po_distribution_id);
                 FETCH c_po_dist_info INTO l_po_dist_info_rec;
                 IF c_po_dist_info%NOTFOUND THEN
                      CLOSE c_po_dist_info;
                      RETURN;
                 END IF;
                 CLOSE c_po_dist_info;*/

                 --
                 -- Get the chart of accounts from legder and identify the segement qualifers
                 -- gl_balancing and natural account
                 --
                 OPEN c_ledger_info( l_payment_extract_detail_rec.event_id);
                 FETCH c_ledger_info INTO l_ledger_info;
                 IF c_ledger_info%NOTFOUND THEN
                      CLOSE c_ledger_info;
                      RETURN;
                 END IF;
                 CLOSE c_ledger_info;

                 l_index := l_index + 1;
                 l_fv_extract_detail(l_index).event_id := l_payment_extract_detail_rec.event_id;
                 l_fv_extract_detail(l_index).Line_Number := l_payment_extract_detail_rec.Line_number;
                 l_fv_extract_detail(l_index).Application_id := p_application_id;

                 --DEBUG('Event ID'|| l_rcv_extract_detail_rec.event_id);

                 l_fund_value := get_fund_value(l_ledger_info.coaid,
                                                l_payment_extract_detail_rec.AID_DIST_CCID,
                                                l_gl_account_segment,
                                                l_gl_balancing_segment);
                 l_fv_extract_detail(l_index).fund_value :=l_fund_value;

                 --DEBUG('Budget CCID '||l_po_dist_info_rec.code_combination_id);
                 --DEBUG('Fund Value'||  l_fund_value);

                   -- get the fund category and expiration date
                 get_fund_details( p_application_id,
                                   l_ledger_info.ledger_id,
           l_fund_value,
           l_payment_extract_header_rec.aph_accounting_date,
           l_fv_extract_detail(l_index).fund_category,
           l_fv_extract_detail(l_index).fund_expired_status
                                 );

                 -- prior year flag -- requsition donot have prior year transactions
                 l_fv_extract_detail(l_index).prior_year_flag := 'N';
                 l_pya := get_prior_year_status ( p_application_id,
                                                  l_ledger_info.ledger_id,
                                             l_ledger_info.coaid,
              l_payment_extract_detail_rec.AID_DIST_CCID,
                                              l_payment_extract_header_rec.aph_accounting_date
                          );
                 IF l_pya THEN
                     l_fv_extract_detail(l_index).prior_year_flag := 'Y';
                                            -- get the fiscal year for the GL_DATE of the transction
                           OPEN c_get_gl_fiscal_year( l_ledger_info.ledger_id,
                        l_payment_extract_header_rec.aph_accounting_date);
                           FETCH c_get_gl_fiscal_year INTO l_transaction_year;
                           CLOSE c_get_gl_fiscal_year;
                                            -- get the balances from account
                    /* l_balance_amt:=get_anticipated_fund_amt(p_Fund_value             => l_fund_value,
                                                             p_Balancing_segment      => l_gl_balancing_segment,
                                                             p_Natural_segment        => l_gl_account_segment,
                                                             p_Ledger_id              => l_ledger_info.ledger_id,
                                                             p_coaid                  => l_ledger_info.coaid,
                                                             p_Period_name            => l_transaction_year.period_name);*/
                 END IF;

             END IF;
         END LOOP;
         --- end
         -- Handled separtely in treasury confirmation

         FORALL  l_Index  IN l_fv_extract_detail.first..l_fv_extract_detail.last
            INSERT INTO FV_EXTRACT_DETAIL_GT VALUES l_fv_extract_detail(l_index);

         l_debug_info := 'Number of Rows inserted into FV_EXTRACT_DETAIL_GT: '|| SQL%ROWCOUNT;
         trace(C_STATE_LEVEL, l_procedure_name, l_debug_info );

         l_index := 0;

         -------------------------------------------------------------------------
         l_debug_info := 'End of procedure'||l_procedure_name;
         trace(C_PROC_LEVEL, l_procedure_name, l_debug_info);
         -------------------------------------------------------------------------


EXCEPTION

  WHEN OTHERS THEN
     l_debug_info := 'Error in Federal AP SLA processing ';
     trace(C_STATE_LEVEL, l_procedure_name, l_debug_info);
     FND_MESSAGE.SET_NAME('FND', 'FND_GENERIC_MESSAGE');
     FND_MESSAGE.SET_TOKEN('MESSAGE' ,
         'Procedure :fv_sla_processing_pkg.ap_extract'|| CRLF||
         'Error     :'||SQLERRM);
     FND_MSG_PUB.ADD;
     APP_EXCEPTION.RAISE_EXCEPTION;

END ap_extract;

  PROCEDURE extract
  (
    p_application_id               IN            NUMBER,
    p_accounting_mode              IN            VARCHAR2
  )
  IS

    l_debug_info                   VARCHAR2(240);
    l_procedure_name               VARCHAR2(100) :='.EXTRACT';

  BEGIN

    l_procedure_name := g_path_name || l_procedure_name;
    -------------------------------------------------------------------------
    l_debug_info := 'Begin of procedure '||l_procedure_name;
    trace(C_STATE_LEVEL, l_procedure_name, l_debug_info);
    -------------------------------------------------------------------------
    -------------------------------------------------------------------------


    IF (p_application_id = 200) THEN
        ap_extract(p_application_id, p_accounting_mode);
    ELSE
        RETURN;
    END IF;

    -------------------------------------------------------------------------
    l_debug_info := 'End of procedure '||l_procedure_name;
    trace(C_PROC_LEVEL, l_procedure_name, l_debug_info);
    -------------------------------------------------------------------------

  EXCEPTION
    WHEN OTHERS THEN
      l_debug_info := 'Error in Federal SLA Processing ' || SQLERRM;
      trace(C_STATE_LEVEL, l_procedure_name, l_debug_info);
      FND_MESSAGE.SET_NAME('FND', 'FND_GENERIC_MESSAGE');
      FND_MESSAGE.SET_TOKEN('MESSAGE' ,
          'Procedure :fv_sla_processing_pkg.extract'|| CRLF||
          'Error     :'||SQLERRM);
      FND_MSG_PUB.ADD;
      APP_EXCEPTION.RAISE_EXCEPTION;

  END extract;

  PROCEDURE preaccounting
  (
    p_application_id               IN            NUMBER,
    p_ledger_id                    IN            INTEGER,
    p_process_category             IN            VARCHAR2,
    p_end_date                     IN            DATE,
    p_accounting_mode              IN            VARCHAR2,
    p_valuation_method             IN            VARCHAR2,
    p_security_id_int_1            IN            INTEGER,
    p_security_id_int_2            IN            INTEGER,
    p_security_id_int_3            IN            INTEGER,
    p_security_id_char_1           IN            VARCHAR2,
    p_security_id_char_2           IN            VARCHAR2,
    p_security_id_char_3           IN            VARCHAR2,
    p_report_request_id            IN            INTEGER
  ) IS
  BEGIN
    NULL;
  END;

  PROCEDURE postprocessing
  (
    p_application_id               IN            NUMBER,
    p_accounting_mode              IN            VARCHAR2
  )
  IS
  BEGIN
    NULL;
  END;


  PROCEDURE postaccounting
  (
    p_application_id               IN            NUMBER,
    p_ledger_id                    IN            INTEGER,
    p_process_category             IN            VARCHAR2,
    p_end_date                     IN            DATE,
    p_accounting_mode              IN            VARCHAR2,
    p_valuation_method             IN            VARCHAR2,
    p_security_id_int_1            IN            INTEGER,
    p_security_id_int_2            IN            INTEGER,
    p_security_id_int_3            IN            INTEGER,
    p_security_id_char_1           IN            VARCHAR2,
    p_security_id_char_2           IN            VARCHAR2,
    p_security_id_char_3           IN            VARCHAR2,
    p_report_request_id            IN            INTEGER
  )
  IS
  BEGIN
    NULL;
  END;
BEGIN
  init;
END fv_sla_ap_processing_pkg;

/

--------------------------------------------------------
--  DDL for Package Body GL_FUNDS_AVAILABLE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_FUNDS_AVAILABLE_PKG" AS
/* $Header: glifundb.pls 120.10.12010000.3 2009/05/20 11:51:24 snama ship $ */



--
-- PUBLIC FUNCTIONS
--

FUNCTION is_po_installed RETURN BOOLEAN IS

  CURSOR c_po_install IS
    select 'found'
    from   fnd_product_installations fpi
    where  fpi.application_id = 201
    and    fpi.status = 'I';

    dummy VARCHAR2( 100 );

BEGIN

    OPEN  c_po_install;
    FETCH c_po_install INTO dummy;

    IF c_po_install%FOUND THEN
       CLOSE c_po_install;
       RETURN( TRUE );
    ELSE
       CLOSE c_po_install;
       RETURN( FALSE );
    END IF;

  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
        'gl_funds_available_pkg.is_po_installed');
      RAISE;

END is_po_installed;

--************************************************************************

PROCEDURE current_budget_info (
            x_ledger_id                 NUMBER,
            x_budget_version_id  IN OUT NOCOPY NUMBER,
            x_budget_name        IN OUT NOCOPY VARCHAR2,
            x_bj_required_flag   IN OUT NOCOPY VARCHAR2,
            x_budget_type        IN OUT NOCOPY VARCHAR2,
            x_budget_status      IN OUT NOCOPY VARCHAR2,
            x_latest_opened_year IN OUT NOCOPY NUMBER,
            x_first_valid_period IN OUT NOCOPY VARCHAR2,
            x_last_valid_period  IN OUT NOCOPY VARCHAR2,
            x_is_po_installed    IN OUT NOCOPY BOOLEAN,
            x_req_id             IN OUT NOCOPY NUMBER,
	    x_po_id              IN OUT NOCOPY NUMBER,
	    x_req_name           IN OUT NOCOPY VARCHAR2,
            x_po_name            IN OUT NOCOPY VARCHAR2,
	    x_oth_name           IN OUT NOCOPY VARCHAR2) IS
  BEGIN
    gl_budget_utils_pkg.get_current_budget(
      x_ledger_id,
      x_budget_version_id,
      x_budget_name,
      x_bj_required_flag);

    gl_budgets_pkg.select_columns(
      x_budget_name,
      x_ledger_id,
      x_budget_type,
      x_budget_status,
      x_bj_required_flag,
      x_latest_opened_year,
      x_first_valid_period,
      x_last_valid_period);

    x_is_po_installed := gl_funds_available_pkg.is_po_installed;

    IF (x_is_po_installed) THEN
      gl_feeder_info_pkg.get_enc_id_and_name(
            x_req_id,
	    x_po_id,
	    x_req_name,
            x_po_name,
	    x_oth_name);
    END IF;


  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
        'gl_funds_available_pkg.current_budget_info');
      RAISE;
  END current_budget_info;

-- **********************************************************************

PROCEDURE calc_funds(
            x_amount_type                   VARCHAR2,
            x_code_combination_id           NUMBER,
            x_account_type                  VARCHAR2,
            x_template_id                   NUMBER,
            x_ledger_id                     NUMBER,
            x_currency_code                 VARCHAR2,
            x_po_install_flag               VARCHAR2,
            x_accounted_period_type         VARCHAR2,
            x_period_set_name               VARCHAR2,
            x_period_name                   VARCHAR2,
            x_period_num                    NUMBER,
            x_quarter_num                   NUMBER,
            x_period_year                   NUMBER,
            x_closing_status                VARCHAR2,
            x_budget_version_id             NUMBER,
            x_encumbrance_type_id           NUMBER,
            x_req_encumbrance_id            NUMBER,
            x_po_encumbrance_id             NUMBER,
            x_budget                        IN OUT NOCOPY NUMBER,
            x_encumbrance                   IN OUT NOCOPY NUMBER,
            x_actual                        IN OUT NOCOPY NUMBER,
            x_funds_available               IN OUT NOCOPY NUMBER,
            x_req_encumbrance_amount        IN OUT NOCOPY NUMBER,
            x_po_encumbrance_amount         IN OUT NOCOPY NUMBER,
            x_other_encumbrance_amount      IN OUT NOCOPY NUMBER )  IS


  x_first_period_of_year_name     VARCHAR2(15);
  x_period_used_for_ext_actuals   VARCHAR2(15);
  x_num_used_for_ext_actuals      NUMBER;
  x_year_used_for_ext_actuals     NUMBER;
  x_quarter_used_for_ext_actuals  NUMBER;

/*
This balances SQL statement has the following explain plan:
Rows     Execution Plan
-------  ---------------------------------------------------
      0  SELECT STATEMENT   HINT: RULE
      2   SORT (AGGREGATE)
      0    CONCATENATION
      6     TABLE ACCESS   HINT: ANALYZED (BY ROWID) OF 'GL_BALANCES'
      7      INDEX   HINT: ANALYZED (RANGE SCAN) OF 'GL_BALANCES_N1' (NON-UNIQUE)
      6     TABLE ACCESS   HINT: ANALYZED (BY ROWID) OF 'GL_BALANCES'
      7      INDEX   HINT: ANALYZED (RANGE SCAN) OF 'GL_BALANCES_N1' (NON-UNIQUE)
*/


  CURSOR c_balances IS
    SELECT
      nvl(sum(decode(actual_flag, 'A',
                decode(x_amount_type,
                  'PTD',
                  decode(period_name, x_period_name,
                    nvl(period_net_dr,0) - nvl(period_net_cr,0), 0),
                  'QTDE',
                  decode(period_name, x_period_used_for_ext_actuals,
                    nvl(period_net_dr,0) - nvl(period_net_cr,0) +
                    nvl(quarter_to_date_dr,0) - nvl(quarter_to_date_cr,0),
                    0),
                  'YTDE',
                  decode(bal.period_name, x_first_period_of_year_name,
                    -(nvl(begin_balance_dr,0) - nvl(begin_balance_cr,0)), 0) +
                  decode(bal.period_name, x_period_used_for_ext_actuals,
                    nvl(begin_balance_dr,0) - nvl(begin_balance_cr,0) +
                    nvl(period_net_dr,0) - nvl(period_net_cr,0),0),
                  'PJTD',
                  decode(period_name, x_period_used_for_ext_actuals,
                    nvl(period_net_dr,0) - nvl(period_net_cr,0) +
                    nvl(project_to_date_dr,0) - nvl(project_to_date_cr,0),0),
                  0),0)),0),
      nvl(sum(decode(actual_flag, 'B',
                decode(period_name, x_period_name,
                  nvl(period_net_dr,0) - nvl(period_net_cr,0) +
                  decode(x_amount_type,
                    'QTDE',
                    nvl(quarter_to_date_dr,0) - nvl(quarter_to_date_cr,0),
                    'YTDE',
                    nvl(begin_balance_dr,0) - nvl(begin_balance_cr,0),
                    'PJTD',
                    nvl(project_to_date_dr,0) - nvl(project_to_date_cr,0),
                    0),0),0)),0),
      nvl(sum(decode(actual_flag, 'E',
                decode(period_name, x_period_name,
                  nvl(period_net_dr,0) - nvl(period_net_cr,0) +
                  decode(x_amount_type,
                    'QTDE',
                    nvl(quarter_to_date_dr,0) - nvl(quarter_to_date_cr,0),
                    'YTDE',
                    nvl(begin_balance_dr,0) - nvl(begin_balance_cr,0),
                    'PJTD',
                    nvl(project_to_date_dr,0) - nvl(project_to_date_cr,0),
                    0),0),0)),0),
      nvl(sum(decode(actual_flag, 'E',
                decode(period_name, x_period_name,
                  decode(encumbrance_type_id,
                    nvl(x_req_encumbrance_id,-2),
                    nvl(period_net_dr,0) - nvl(period_net_cr,0) +
                    decode(x_amount_type,
                      'QTDE',
                      nvl(quarter_to_date_dr,0) - nvl(quarter_to_date_cr,0),
                      'YTDE',
                      nvl(begin_balance_dr,0) - nvl(begin_balance_cr,0),
                      'PJTD',
                      nvl(project_to_date_dr,0) - nvl(project_to_date_cr,0),
                      0),0),0),0)),0),
      nvl(sum(decode(actual_flag, 'E',
                decode(period_name, x_period_name,
                  decode(encumbrance_type_id,
                    nvl(x_po_encumbrance_id,-2),
                    nvl(period_net_dr,0) - nvl(period_net_cr,0) +
                    decode(x_amount_type,
                      'QTDE',
                      nvl(quarter_to_date_dr,0) - nvl(quarter_to_date_cr,0),
                      'YTDE',
                      nvl(begin_balance_dr,0) - nvl(begin_balance_cr,0),
                      'PJTD',
                      nvl(project_to_date_dr,0) - nvl(project_to_date_cr,0),
                      0),0),0),0)),0)
    FROM
      gl_balances bal
    WHERE
          bal.ledger_id = x_ledger_id
      and bal.code_combination_id = x_code_combination_id
      --and bal.currency_code = decode(actual_flag, 'B', x_currency_code, bal.currency_code)
      and bal.currency_code = x_currency_code
      --and bal.currency_code <> 'STAT'
      and bal.period_name in (x_period_name, decode(x_amount_type, 'YTDE',
            x_period_used_for_ext_actuals,'QTDE', x_period_used_for_ext_actuals,
            'PJTD', x_period_used_for_ext_actuals, x_period_name)
           --, decode(x_amount_type, 'YTDE', x_first_period_of_year_name,
            --x_period_name)
	)
      and nvl(bal.budget_version_id, -1) = nvl(decode(actual_flag, 'B',
          x_budget_version_id, bal.budget_version_id),-1)
      and decode(actual_flag,
            'E',decode(x_encumbrance_type_id, -1, -1, bal.encumbrance_type_id),
            x_encumbrance_type_id) = x_encumbrance_type_id;

/*
  The packets cursor has the following explain plan:

Rows     Execution Plan
-------  ---------------------------------------------------
      0  SELECT STATEMENT   HINT: RULE
    165   SORT (AGGREGATE)
    165    NESTED LOOPS
    139     INDEX   HINT: ANALYZED (RANGE SCAN) OF 'GL_BC_PACKET_ARRIVAL_ORDER_U3' (UNIQUE)
    197     TABLE ACCESS   HINT: ANALYZED (BY ROWID) OF 'GL_BC_PACKETS'
    335      INDEX   HINT: ANALYZED (RANGE SCAN) OF 'GL_BC_PACKETS_N2' (NON-UNIQUE)
*/

  CURSOR c_packets IS
    SELECT
      nvl(sum(decode(actual_flag, 'A',
                nvl(accounted_dr,0) - nvl(accounted_cr,0),0)),0),
      nvl(sum(decode(actual_flag, 'B',
                nvl(accounted_dr,0) - nvl(accounted_cr,0),0)),0),
      nvl(sum(decode(actual_flag, 'E',
                nvl(accounted_dr,0) - nvl(accounted_cr,0),0)),0),
      nvl(sum(decode(actual_flag, 'E',
                decode(encumbrance_type_id,
                   nvl(x_req_encumbrance_id,-2),
                   nvl(accounted_dr,0) - nvl(accounted_cr,0),0),0)),0),
      nvl(sum(decode(actual_flag, 'E',
                decode(encumbrance_type_id,
                   nvl(x_po_encumbrance_id,-2),
                   nvl(accounted_dr,0) - nvl(accounted_cr,0),0),0)),0)
    FROM
      gl_bc_packets pac, gl_bc_packet_arrival_order arr
    WHERE
          pac.code_combination_id = x_code_combination_id
      and pac.currency_code = decode(pac.actual_flag, 'B', x_currency_code,  pac.currency_code)
      and pac.currency_code <> 'STAT'
      and ((x_amount_type = 'PJTD' and
            ((pac.period_year < x_period_year) or
             (pac.period_num <= x_period_num and
              pac.period_year = x_period_year))) or
           (x_amount_type = 'PTD' and
            pac.period_name = x_period_name) or
           (x_amount_type = 'YTDE' and
            pac.period_year = x_period_year and
            pac.period_num <= x_period_num) or
           (x_amount_type = 'QTDE' and
            pac.period_year = x_period_year and
            pac.quarter_num = x_quarter_num and
            pac.period_num <= x_period_num))
      and NVL(pac.funding_budget_version_id, x_budget_version_id) = x_budget_version_id
      and decode(actual_flag,
            'E',decode(x_encumbrance_type_id, -1, -1, pac.encumbrance_type_id),
             x_encumbrance_type_id) = x_encumbrance_type_id
      and pac.status_code   = 'A'
      and pac.ledger_id = arr.ledger_id
      and pac.packet_id = arr.packet_id
      and arr.ledger_id = x_ledger_id
      and arr.affect_funds_flag = 'Y';

cursor c_pjtd(x_application_id NUMBER) is
  select period_name, period_num, period_year, quarter_num
    from gl_period_statuses
   where application_id = x_application_id
     and ledger_id = x_ledger_id
     and period_name = (select latest_opened_period_name
                          from gl_ledgers
                         where ledger_id = x_ledger_id);

CURSOR c_account_category IS
  SELECT  st.account_category_code
  FROM    gl_summary_templates st
  WHERE   st.template_id = x_template_id
    AND   st.ledger_id = x_ledger_id;

  budget_1                        NUMBER;
  budget_2                        NUMBER;
  actual_1                        NUMBER;
  actual_2                        NUMBER;
  encumbrance_1                   NUMBER;
  encumbrance_2                   NUMBER;
  req_encumbrance_amount_1        NUMBER;
  req_encumbrance_amount_2        NUMBER;
  po_encumbrance_amount_1         NUMBER;
  po_encumbrance_amount_2         NUMBER;
  acct_cat                        VARCHAR2(1);

BEGIN
  IF (x_amount_type in ('QTDE', 'YTDE', 'PJTD')) THEN
    IF (x_amount_type = 'YTDE') THEN
      gl_period_statuses_pkg.select_year_1st_period(
        101,
        x_ledger_id,
        x_period_year,
        x_first_period_of_year_name );
    END IF;

    IF ( x_closing_status IN ( 'O', 'C', 'P' ) ) THEN
      x_period_used_for_ext_actuals := x_period_name;
      x_num_used_for_ext_actuals := x_period_num;
      x_year_used_for_ext_actuals := x_period_year;
      x_quarter_used_for_ext_actuals := x_quarter_num;
    ELSIF (x_amount_type = 'QTDE')  /* x_closing_status IN ( 'N', 'F' ) */
      THEN
        gl_period_statuses_pkg.get_extended_quarter(
          101,
          x_ledger_id,
          x_period_year,
          x_period_name,
          x_period_set_name,
          x_accounted_period_type,
          x_period_used_for_ext_actuals,
          x_num_used_for_ext_actuals,
          x_year_used_for_ext_actuals,
          x_quarter_used_for_ext_actuals );
    ELSIF x_amount_type = 'YTDE' then /* x_closing_status IN ('N', 'F') */
        gl_period_statuses_pkg.get_extended_year(
          101,
          x_ledger_id,
          x_period_year,
          x_accounted_period_type,
          x_period_used_for_ext_actuals,
          x_num_used_for_ext_actuals,
          x_year_used_for_ext_actuals,
          x_quarter_used_for_ext_actuals );
    ELSIF x_amount_type = 'PJTD' then
      open c_pjtd(101);

      fetch c_pjtd
       into x_period_used_for_ext_actuals,
            x_num_used_for_ext_actuals,
            x_year_used_for_ext_actuals,
            x_quarter_used_for_ext_actuals;

      close c_pjtd;

      if ((x_period_year * 10000 + x_period_num) <=
       (x_year_used_for_ext_actuals * 10000 + x_num_used_for_ext_actuals)) then
        x_period_used_for_ext_actuals := x_period_name;
        x_num_used_for_ext_actuals := x_period_num;
        x_year_used_for_ext_actuals := x_period_year;
        x_quarter_used_for_ext_actuals := x_quarter_num;
      end if;

    END IF;
  ELSE
    x_period_used_for_ext_actuals := x_period_name;
    x_num_used_for_ext_actuals := x_period_num;
    x_year_used_for_ext_actuals := x_period_year;
    x_quarter_used_for_ext_actuals := x_quarter_num;
  END IF;

  OPEN   c_balances;
  FETCH  c_balances  INTO actual_1, budget_1, encumbrance_1,
                          req_encumbrance_amount_1, po_encumbrance_amount_1;
  CLOSE  c_balances;

  OPEN   c_packets;
  FETCH  c_packets  INTO actual_2, budget_2, encumbrance_2,
                         req_encumbrance_amount_2, po_encumbrance_amount_2;
  CLOSE  c_packets;

  x_budget := nvl(budget_1,0) + nvl(budget_2,0);
  x_actual := nvl(actual_1,0) + nvl(actual_2,0);
  x_encumbrance := nvl(encumbrance_1,0) + nvl(encumbrance_2,0);

-- Remember that Req encumbrances cannot be turned on unless PO
-- encumbrances are also turned on

  IF ((x_encumbrance_type_id = -1) AND ( x_po_install_flag = 'Y' ) AND
      (x_po_encumbrance_id IS NOT NULL )) THEN
    x_po_encumbrance_amount := nvl(po_encumbrance_amount_1,0) +
                               nvl(po_encumbrance_amount_2,0);
    IF (x_req_encumbrance_id IS NULL) THEN
      x_req_encumbrance_amount := NULL;
    ELSE
      x_req_encumbrance_amount := nvl(req_encumbrance_amount_1,0) +
                                  nvl(req_encumbrance_amount_2,0);
    END IF;
    x_other_encumbrance_amount := x_encumbrance -
                                  nvl(x_req_encumbrance_amount,0) -
                                  x_po_encumbrance_amount;
  ELSE
    x_req_encumbrance_amount := NULL;
    x_po_encumbrance_amount := NULL;
    x_other_encumbrance_amount := NULL;
  END IF;

  IF ( x_template_id IS NULL ) THEN
    IF ( x_account_type IN ( 'C', 'D' ) ) THEN
      x_funds_available := x_actual;
    ELSE
      x_funds_available := x_budget - x_encumbrance - x_actual;
    END IF;
  ELSE
    OPEN   c_account_category;
    FETCH  c_account_category  INTO acct_cat;
    CLOSE  c_account_category;
    IF ( acct_cat = 'B' ) THEN
      x_funds_available := x_actual;
    ELSIF ( acct_cat = 'P' ) THEN
      x_funds_available := x_budget - x_encumbrance - x_actual;
    END IF;
  END IF;

  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
                            'gl_funds_available_pkg.calc_funds');
      RAISE;
END calc_funds;

-- ***********************************************************************************

PROCEDURE calc_funds_period(
            x_code_combination_id           NUMBER,
            x_account_type                  VARCHAR2,
            x_template_id                   NUMBER,
            x_ledger_id                     NUMBER,
            x_currency_code                 VARCHAR2,
            x_po_install_flag               VARCHAR2,
            x_accounted_period_type         VARCHAR2,
            x_period_set_name               VARCHAR2,
            x_period_name                   VARCHAR2,
            x_period_num                    NUMBER,
            x_quarter_num                   NUMBER,
            x_period_year                   NUMBER,
            x_closing_status                VARCHAR2,
            x_budget_version_id             NUMBER,
            x_encumbrance_type_id           NUMBER,
            x_req_encumbrance_id            NUMBER,
            x_po_encumbrance_id             NUMBER,
            x_budget                        IN OUT NOCOPY NUMBER,
            x_encumbrance                   IN OUT NOCOPY NUMBER,
            x_actual                        IN OUT NOCOPY NUMBER,
            x_funds_available               IN OUT NOCOPY NUMBER,
            x_req_encumbrance_amount        IN OUT NOCOPY NUMBER,
            x_po_encumbrance_amount         IN OUT NOCOPY NUMBER,
            x_other_encumbrance_amount      IN OUT NOCOPY NUMBER )  IS


  x_first_period_of_year_name     VARCHAR2(15);
  x_period_used_for_ext_actuals   VARCHAR2(15);
  x_num_used_for_ext_actuals      NUMBER;
  x_year_used_for_ext_actuals     NUMBER;
  x_quarter_used_for_ext_actuals  NUMBER;

/*
This balances SQL statement has the following explain plan:
Rows     Execution Plan
-------  ---------------------------------------------------
      0  SELECT STATEMENT   HINT: RULE
      2   SORT (AGGREGATE)
      0    CONCATENATION
      6     TABLE ACCESS   HINT: ANALYZED (BY ROWID) OF 'GL_BALANCES'
      7      INDEX   HINT: ANALYZED (RANGE SCAN) OF 'GL_BALANCES_N1' (NON-UNIQUE)
      6     TABLE ACCESS   HINT: ANALYZED (BY ROWID) OF 'GL_BALANCES'
      7      INDEX   HINT: ANALYZED (RANGE SCAN) OF 'GL_BALANCES_N1' (NON-UNIQUE)
*/


  CURSOR c_balances IS
    SELECT
      nvl(sum(decode(actual_flag, 'A',(nvl(period_net_dr,0) - nvl(period_net_cr,0)),0)),0),
      nvl(sum(decode(actual_flag, 'B',(nvl(period_net_dr,0) - nvl(period_net_cr,0)),0)),0),
      nvl(sum(decode(actual_flag, 'E',(nvl(period_net_dr,0) - nvl(period_net_cr,0)),0)),0),
      nvl(sum(decode(actual_flag, 'E', decode(encumbrance_type_id,
                          nvl(x_req_encumbrance_id,-2), nvl(period_net_dr,0) - nvl(period_net_cr,0)))),0),
      nvl(sum(decode(actual_flag, 'E', decode(encumbrance_type_id,
                          nvl(x_po_encumbrance_id,-2),  nvl(period_net_dr,0) - nvl(period_net_cr,0)))),0)
    FROM
      gl_balances bal
    WHERE
          bal.ledger_id = x_ledger_id
      and bal.code_combination_id = x_code_combination_id
      --and bal.currency_code = decode(actual_flag, 'B', x_currency_code, bal.currency_code)
      and bal.currency_code = x_currency_code
      --and bal.currency_code <> 'STAT'
      and bal.period_name = x_period_name
      and nvl(bal.budget_version_id, -1) = nvl(decode(actual_flag, 'B',
          x_budget_version_id, bal.budget_version_id),-1)
      and decode(actual_flag,
            'E',decode(x_encumbrance_type_id, -1, -1, bal.encumbrance_type_id),
            x_encumbrance_type_id) = x_encumbrance_type_id;

/*
  The packets cursor has the following explain plan:

Rows     Execution Plan
-------  ---------------------------------------------------
      0  SELECT STATEMENT   HINT: RULE
    165   SORT (AGGREGATE)
    165    NESTED LOOPS
    139     INDEX   HINT: ANALYZED (RANGE SCAN) OF 'GL_BC_PACKET_ARRIVAL_ORDER_U3' (UNIQUE)
    197     TABLE ACCESS   HINT: ANALYZED (BY ROWID) OF 'GL_BC_PACKETS'
    335      INDEX   HINT: ANALYZED (RANGE SCAN) OF 'GL_BC_PACKETS_N2' (NON-UNIQUE)
*/

  CURSOR c_packets IS
    SELECT
      nvl(sum(decode(actual_flag, 'A',
                nvl(accounted_dr,0) - nvl(accounted_cr,0),0)),0),
      nvl(sum(decode(actual_flag, 'B',
                nvl(accounted_dr,0) - nvl(accounted_cr,0),0)),0),
      nvl(sum(decode(actual_flag, 'E',
                nvl(accounted_dr,0) - nvl(accounted_cr,0),0)),0),
      nvl(sum(decode(actual_flag, 'E',
                decode(encumbrance_type_id,
                   nvl(x_req_encumbrance_id,-2),
                   nvl(accounted_dr,0) - nvl(accounted_cr,0),0),0)),0),
      nvl(sum(decode(actual_flag, 'E',
                decode(encumbrance_type_id,
                   nvl(x_po_encumbrance_id,-2),
                   nvl(accounted_dr,0) - nvl(accounted_cr,0),0),0)),0)
    FROM
      gl_bc_packets pac, gl_bc_packet_arrival_order arr
    WHERE
          pac.code_combination_id = x_code_combination_id
      and pac.currency_code = decode(pac.actual_flag, 'B', x_currency_code,  pac.currency_code)
      and pac.currency_code <> 'STAT'
      AND pac.period_name = x_period_name
      and NVL(pac.funding_budget_version_id, x_budget_version_id) = x_budget_version_id
      and decode(actual_flag,
            'E',decode(x_encumbrance_type_id, -1, -1, pac.encumbrance_type_id),
             x_encumbrance_type_id) = x_encumbrance_type_id
      and pac.status_code   = 'A'
      and pac.ledger_id = arr.ledger_id
      and pac.packet_id = arr.packet_id
      and arr.ledger_id = x_ledger_id
      and arr.affect_funds_flag = 'Y';


CURSOR c_account_category IS
  SELECT  st.account_category_code
  FROM    gl_summary_templates st
  WHERE   st.template_id = x_template_id
    AND   st.ledger_id = x_ledger_id;

  budget_1                        NUMBER;
  budget_2                        NUMBER;
  actual_1                        NUMBER;
  actual_2                        NUMBER;
  encumbrance_1                   NUMBER;
  encumbrance_2                   NUMBER;
  req_encumbrance_amount_1        NUMBER;
  req_encumbrance_amount_2        NUMBER;
  po_encumbrance_amount_1         NUMBER;
  po_encumbrance_amount_2         NUMBER;
  acct_cat                        VARCHAR2(1);

BEGIN

  OPEN   c_balances;
  FETCH  c_balances  INTO actual_1, budget_1, encumbrance_1,
                          req_encumbrance_amount_1, po_encumbrance_amount_1;
  CLOSE  c_balances;

  OPEN   c_packets;
  FETCH  c_packets  INTO actual_2, budget_2, encumbrance_2,
                         req_encumbrance_amount_2, po_encumbrance_amount_2;
  CLOSE  c_packets;

  x_budget := nvl(budget_1,0) + nvl(budget_2,0);
  x_actual := nvl(actual_1,0) + nvl(actual_2,0);
  x_encumbrance := nvl(encumbrance_1,0) + nvl(encumbrance_2,0);

-- Remember that Req encumbrances cannot be turned on unless PO
-- encumbrances are also turned on

  IF ((x_encumbrance_type_id = -1) AND ( x_po_install_flag = 'Y' ) AND
      (x_po_encumbrance_id IS NOT NULL )) THEN
    x_po_encumbrance_amount := nvl(po_encumbrance_amount_1,0) +
                               nvl(po_encumbrance_amount_2,0);
    IF (x_req_encumbrance_id IS NULL) THEN
      x_req_encumbrance_amount := NULL;
    ELSE
      x_req_encumbrance_amount := nvl(req_encumbrance_amount_1,0) +
                                  nvl(req_encumbrance_amount_2,0);
    END IF;
    x_other_encumbrance_amount := x_encumbrance -
                                  nvl(x_req_encumbrance_amount,0) -
                                  x_po_encumbrance_amount;
  ELSE
    x_req_encumbrance_amount := NULL;
    x_po_encumbrance_amount := NULL;
    x_other_encumbrance_amount := NULL;
  END IF;

  IF ( x_template_id IS NULL ) THEN
    IF ( x_account_type IN ( 'C', 'D' ) ) THEN
      x_funds_available := x_actual;
    ELSE
      x_funds_available := x_budget - x_encumbrance - x_actual;
    END IF;
  ELSE
    OPEN   c_account_category;
    FETCH  c_account_category  INTO acct_cat;
    CLOSE  c_account_category;
    IF ( acct_cat = 'B' ) THEN
      x_funds_available := x_actual;
    ELSIF ( acct_cat = 'P' ) THEN
      x_funds_available := x_budget - x_encumbrance - x_actual;
    END IF;
  END IF;

  EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
                            'gl_funds_available_pkg.calc_funds');
      RAISE;
END calc_funds_period;


-- ***********************************************************************************

FUNCTION calc_funds(
            p_ccid                          IN VARCHAR2,
            p_template_id                   IN NUMBER,
            p_ledger_id                     IN NUMBER,
            p_period_name                   IN VARCHAR2,
            p_currency_code                 IN VARCHAR2) RETURN NUMBER IS

    CURSOR  c_get_period_info(cp_ledger_id NUMBER, cp_period_name VARCHAR2) IS
    SELECT  period_num, quarter_num, period_year, closing_status
    FROM    Gl_Period_Statuses
    WHERE   application_id = 201
    AND     ledger_id = cp_ledger_id
    AND     period_name = cp_period_name;

    CURSOR c_get_ledger_info(cp_ledger_id NUMBER) IS
    SELECT period_set_name, accounted_period_type
    FROM gl_ledgers
    WHERE ledger_id = cp_ledger_id;

    CURSOR  c_get_template_info (cp_ledger_id NUMBER, cp_template_id NUMBER) IS
    SELECT  amount_type, funding_budget_version_id
    FROM    gl_summary_templates
    WHERE   ledger_id = cp_ledger_id
    AND     template_id = cp_template_id;

    l_amt_type                      VARCHAR2(30);
    l_amount_type                   VARCHAR2(30);
    l_accounted_period_type         VARCHAR2(30);
    l_period_set_name               VARCHAR2(30);
    l_period_num                    NUMBER;
    l_quarter_num                   NUMBER;
    l_period_year                   NUMBER;
    l_closing_status                VARCHAR2(1);
    l_budget_version_id             NUMBER := NULL;
    l_encumbrance_type_id           NUMBER := -1;
    l_req_encumbrance_id            NUMBER := -1;
    l_po_encumbrance_id             NUMBER := -1;
    l_budget                        NUMBER;
    l_encumbrance                   NUMBER;
    l_actual                        NUMBER;
    l_funds_available               NUMBER;
    l_req_encumbrance_amount        NUMBER;
    l_po_encumbrance_amount         NUMBER;
    l_other_encumbrance_amount      NUMBER;
BEGIN

    open c_get_template_info(p_ledger_id, p_template_id);
    fetch c_get_template_info into l_amt_type, l_budget_version_id;
    close c_get_template_info;

    open c_get_ledger_info(p_ledger_id);
    fetch c_get_ledger_info into l_period_set_name, l_accounted_period_type;
    close c_get_ledger_info;

    open c_get_period_info(p_ledger_id, p_period_name);
    fetch c_get_period_info into l_period_num, l_quarter_num, l_period_year, l_closing_status;
    close c_get_period_info;

    select decode(l_amt_type, 'YTD', 'YTDE', 'QTD', 'QTDE', l_amount_type)
    into l_amount_type
    from dual;

    gl_funds_available_pkg.calc_funds(
            x_amount_type                   => l_amount_type,
            x_code_combination_id           => p_ccid,
            x_account_type                  => NULL,
            x_template_id                   => p_template_id,
            x_ledger_id                     => p_Ledger_id ,
            x_currency_code                 => p_currency_code,
            x_po_install_flag               => 'Y',
            x_accounted_period_type         => l_accounted_period_type,
            x_period_set_name               => l_period_set_name,
            x_period_name                   => p_period_name,
            x_period_num                    => l_period_num,
            x_quarter_num                   => l_quarter_num,
            x_period_year                   => l_period_year,
            x_closing_status                => l_closing_status,
            x_budget_version_id             => l_budget_version_id,
            x_encumbrance_type_id           => l_encumbrance_type_id,
            x_req_encumbrance_id            => l_req_encumbrance_id,
            x_po_encumbrance_id             => l_po_encumbrance_id,
            x_budget                        => l_budget,
            x_encumbrance                   => l_encumbrance,
            x_actual                        => l_actual,
            x_funds_available               => l_funds_available,
            x_req_encumbrance_amount        => l_req_encumbrance_amount,
            x_po_encumbrance_amount         => l_po_encumbrance_amount,
            x_other_encumbrance_amount      => l_other_encumbrance_amount );

        return l_funds_available;
EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE',
                            'gl_funds_available_pkg.calc_funds FUNCTION');
      RAISE;
END calc_funds;

END gl_funds_available_pkg;

/

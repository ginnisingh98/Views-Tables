--------------------------------------------------------
--  DDL for Package Body GL_BUDGET_TRANSFER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_BUDGET_TRANSFER_PKG" AS
/* $Header: glibdxfb.pls 120.4 2005/05/05 01:02:40 kvora ship $ */

  --
  -- PUBLIC FUNCTIONS
  --
  PROCEDURE get_from_to_balance (balance_type		   VARCHAR2,
				 xledger_id                NUMBER,
				 xbc_enabled_flag          VARCHAR2,
				 xperiod_name              VARCHAR2,
                                 xbudget_version_id	   NUMBER,
                                 xcurrency_code		   VARCHAR2,
				 from_code_combination_id  NUMBER,
				 to_code_combination_id    NUMBER,
                                 from_balance              IN OUT NOCOPY NUMBER,
				 to_balance		   IN OUT NOCOPY NUMBER) IS

  BEGIN
    from_balance := get_balance(balance_type,
			        xledger_id,
				xbc_enabled_flag,
				xperiod_name,
				xbudget_version_id,
				xcurrency_code,
				from_code_combination_id);

    to_balance := get_balance(balance_type,
			      xledger_id,
			      xbc_enabled_flag,
			      xperiod_name,
			      xbudget_version_id,
			      xcurrency_code,
			      to_code_combination_id);
  END get_from_to_balance;

  FUNCTION get_balance  (balance_type		   VARCHAR2,
		         xledger_id                NUMBER,
		         xbc_enabled_flag          VARCHAR2,
		         xperiod_name              VARCHAR2,
                         xbudget_version_id	   NUMBER,
                         xcurrency_code		   VARCHAR2,
		         code_combination_id       NUMBER) RETURN NUMBER IS
    balance NUMBER := 0;
  BEGIN

    -- If budgetary control is enabled, get the balance
    -- from gl_bc_packets.  Otherwise, get the balance from
    -- gl_interface.
    IF (xbc_enabled_flag = 'Y') THEN
      balance   := get_bc_balance(balance_type,
                                  xledger_id,
                                  xperiod_name,
				  'B',
                                  xbudget_version_id,
                                  xcurrency_code,
                                  code_combination_id);
    END IF;

    -- Get the rest of the balance from gl_interface
    balance :=   balance
               + get_posted_balance(balance_type,
                                    xledger_id,
                                    xperiod_name,
				    'B',
                                    xbudget_version_id,
                                    xcurrency_code,
                                    code_combination_id);

    return(balance);
  END get_balance;

  PROCEDURE get_from_to_bc_balance(balance_type		     VARCHAR2,
				   xledger_id                NUMBER,
				   xperiod_name              VARCHAR2,
				   xactual_flag		     VARCHAR2,
                                   xbudget_version_id	     NUMBER,
                                   xcurrency_code            VARCHAR2,
				   from_code_combination_id  NUMBER,
				   to_code_combination_id    NUMBER,
                                   from_balance              IN OUT NOCOPY NUMBER,
				   to_balance		   IN OUT NOCOPY NUMBER) IS

  BEGIN

    from_balance := get_bc_balance(balance_type,
                                   xledger_id,
                                   xperiod_name,
		 	           xactual_flag,
                                   xbudget_version_id,
                                   xcurrency_code,
                                   from_code_combination_id);
    to_balance   := get_bc_balance(balance_type,
                                   xledger_id,
                                   xperiod_name,
 			           xactual_flag,
                                   xbudget_version_id,
                                   xcurrency_code,
                                   to_code_combination_id);
  END get_from_to_bc_balance;

  FUNCTION get_bc_balance (balance_type         VARCHAR2,
                           xledger_id           NUMBER,
			   xperiod_name         VARCHAR2,
			   xactual_flag		VARCHAR2,
                           xbudget_version_id	NUMBER,
                           xcurrency_code	VARCHAR2,
			   xcode_combination_id NUMBER) RETURN NUMBER IS

    CURSOR get_balance IS
        SELECT  sum(  nvl(pkt.entered_dr,0)
                    - nvl(pkt.entered_cr,0))
	FROM    gl_period_statuses per, gl_bc_packet_arrival_order ao,
                gl_bc_packets pkt
	WHERE   per.application_id = 101
        AND     per.ledger_id = xledger_id
        AND     per.period_name = xperiod_name
        AND     ao.ledger_id = per.ledger_id
        AND     ao.affect_funds_flag = 'Y'
        AND     pkt.packet_id = ao.packet_id
        AND     pkt.ledger_id = ao.ledger_id
        AND     pkt.period_year * 1000 + pkt.period_num
                  <= per.period_year * 1000 + per.period_num
        AND     pkt.period_year*1000000 + pkt.quarter_num*1000 + pkt.period_num
                  >= decode (balance_type,
                             'PTD',    per.period_year*1000000
                                     + per.quarter_num*1000
                                     + per.period_num,
                             'QTD',    per.period_year*1000000
                                     + per.quarter_num*1000,
                             'YTD',    per.period_year*1000000,
                             'PJTD', 0)
	AND	pkt.code_combination_id = xcode_combination_id
	AND	pkt.actual_flag = xactual_flag
	AND     (   pkt.budget_version_id = xbudget_version_id
                 OR xactual_flag IN ('A','E'))
	AND     (   pkt.encumbrance_type_id = xbudget_version_id
                 OR xactual_flag IN ('A','B'))
	AND	pkt.currency_code = xcurrency_code
        AND     pkt.status_code = 'A';

    temp_bal   NUMBER;
  BEGIN

    -- Get the from and to balances from gl_balances
    OPEN get_balance;
    FETCH get_balance INTO temp_bal;
    IF (get_balance%NOTFOUND) THEN
      CLOSE get_balance;
      RETURN(0);
    ELSE
      CLOSE get_balance;
      RETURN(nvl(temp_bal,0));
    END IF;

  END get_bc_balance;

  FUNCTION get_posted_balance (balance_type         VARCHAR2,
                               xledger_id           NUMBER,
			       xperiod_name         VARCHAR2,
			       xactual_flag	    VARCHAR2,
                               xbudget_version_id   NUMBER,
                               xcurrency_code	    VARCHAR2,
			       xcode_combination_id NUMBER) RETURN NUMBER IS

    CURSOR get_balance IS
        SELECT nvl(period_net_dr,0) - nvl(period_net_cr,0) PERIOD_NET,
               nvl(begin_balance_dr,0) - nvl(begin_balance_cr,0) BEGIN_BAL,
               nvl(quarter_to_date_dr,0)-nvl(quarter_to_date_cr,0) QUARTER_BAL,
               nvl(project_to_date_dr,0)-nvl(project_to_date_cr,0) PROJECT_BAL
	FROM   gl_balances bal
        WHERE  bal.ledger_id = xledger_id
        AND    bal.period_name = xperiod_name
	AND    bal.code_combination_id = xcode_combination_id
	AND    bal.actual_flag = xactual_flag
	AND     (   bal.budget_version_id = xbudget_version_id
                 OR xactual_flag IN ('A','E'))
	AND     (   bal.encumbrance_type_id = xbudget_version_id
                 OR xactual_flag IN ('A','B'))
	AND    bal.currency_code = xcurrency_code;

    period_net   NUMBER;
    begin_bal    NUMBER;
    quarter_bal  NUMBER;
    project_bal  NUMBER;
  BEGIN

    -- Get the from and to balances from gl_balances
    OPEN get_balance;
    FETCH get_balance INTO period_net, begin_bal, quarter_bal, project_bal;
    IF (get_balance%NOTFOUND) THEN
      CLOSE get_balance;
      RETURN(0);
    ELSE
      CLOSE get_balance;

      -- Calculate out the desired balance
      IF (balance_type = 'PTD') THEN
        RETURN(nvl(period_net,0));
      ELSIF (balance_type = 'QTD') THEN
        RETURN(nvl(quarter_bal,0) + nvl(period_net,0));
      ELSIF (balance_type = 'YTD') THEN
        RETURN(nvl(begin_bal,0) + nvl(period_net,0));
      ELSIF (balance_type = 'PJTD') THEN
        RETURN(nvl(project_bal,0) + nvl(period_net,0));
      END IF;
    END IF;

  END get_posted_balance;

END gl_budget_transfer_pkg;

/

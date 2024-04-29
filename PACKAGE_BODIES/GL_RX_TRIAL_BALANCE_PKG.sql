--------------------------------------------------------
--  DDL for Package Body GL_RX_TRIAL_BALANCE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_RX_TRIAL_BALANCE_PKG" as
/* $Header: glurxtbb.pls 120.5 2005/05/05 01:43:04 kvora ship $ */

PROCEDURE create_rows (
  errbuf                 out NOCOPY varchar2,
  retcode                out NOCOPY varchar2,
  p_ledger_name          in varchar2 ,
  p_period_name          in varchar2 ,
  p_account_from         in varchar2 default null,
  p_account_to           in varchar2 default null,
  p_balancing_value      in varchar2 default null,
  p_currency_code        in varchar2 default null,
  p_translated_flag      in varchar2 default 'N',
  p_summary_flag         in varchar2 default 'N',
  p_summary_digits       in number default 1,
  p_statutory_rfj_flag   in varchar2 default 'N') IS

  l_request_id                FND_CONCURRENT_REQUESTS.request_id%type;
  l_ledger_id                 GL_LEDGERS.ledger_id%type;
  l_functional_currency       GL_LEDGERS.currency_code%type;
  l_currency_code             GL_LEDGERS.currency_code%type;
  l_chart_of_accounts_id      GL_LEDGERS.chart_of_accounts_id%type;
  l_fiscal_year               GL_PERIOD_STATUSES.period_year%type;
  l_first_period_name         GL_PERIOD_STATUSES.period_name%type;
  l_adjustment_flag           GL_PERIOD_STATUSES.adjustment_period_flag%type;
  l_balancing_where           varchar2(240);
  l_account_from_where        varchar2(240);
  l_account_to_where          varchar2(240);
  l_translate_where           varchar2(240);
  l_application_id            FND_APPLICATION.application_id%type := 101;
  l_id_flex_code              FND_ID_FLEXS.id_flex_code%type := 'GL#';
  l_segnum                    FND_ID_FLEX_SEGMENTS.segment_num%type;
  l_segname                   FND_ID_FLEX_SEGMENTS.segment_name%type;
  l_prompt                    FND_ID_FLEX_SEGMENTS_TL.form_left_prompt%type;
  l_balancing_value_set       FND_FLEX_VALUE_SETS.flex_value_set_name%type;
  l_account_value_set         FND_FLEX_VALUE_SETS.flex_value_set_name%type;
  l_balancing_segment_column  FND_ID_FLEX_SEGMENTS.application_column_name%type;
  l_account_segment_column    FND_ID_FLEX_SEGMENTS.application_column_name%type;
  l_balancing_description     FND_FLEX_VALUES_TL.description%type;
  l_account_description       FND_FLEX_VALUES_TL.description%type;
  l_balancing                 GL_CODE_COMBINATIONS.segment1%type;
  l_account                   GL_CODE_COMBINATIONS.segment1%type;
  l_rowid                     rowid;
  l_dyn_stmt                  VARCHAR2(4000);
  l_dyn_cursor                number;
  l_dyn_rows                  number;
  segment_not_found           exception;
  debug_mode		      VARCHAR2(1);

  CURSOR 	c1 IS
  SELECT 	rowid,
		balancing_segment,
		account_segment
  FROM		gl_rx_trial_balance_itf
  WHERE		request_id = l_request_id;

BEGIN
  --
  -- Figure out the debug_mode
  -- This program will be running in debug mode when the Utilities: Trace
  -- Has been set to Yes.
  -- We cannot use "additional parameter" approach since the RX does not support hidden parameters
  --
  FND_PROFILE.get('SQL_TRACE',debug_mode);
  IF (debug_mode = 'Y') THEN
    -- dbms_output.put_line('> RXGLTB.create_rows');
    NULL;
  END IF;
  --
  -- use api to get the request id
  --
  l_request_id := FND_GLOBAL.conc_request_id();
  --
  -- get ledgers and period year info
  --
  SELECT 	led.ledger_id,
  		led.currency_code,
  		led.chart_of_accounts_id,
  		ps.period_year
  INTO 		l_ledger_id,
  		l_functional_currency,
  		l_chart_of_accounts_id,
  		l_fiscal_year
  FROM 		gl_ledgers led,
  		gl_period_statuses ps
  WHERE 	led.name 		= p_ledger_name
  AND 		led.ledger_id     	= ps.ledger_id
  AND		ps.application_id 	= l_application_id
  AND		ps.period_name 		= p_period_name;

  IF (p_currency_code is NULL) THEN
    l_currency_code := l_functional_currency;
  ELSE
    l_currency_code := p_currency_code;
  END IF;
  --
  -- get year's first period info
  --
  SELECT	period_name,
		adjustment_period_flag
  INTO 		l_first_period_name,
		l_adjustment_flag
  FROM		gl_period_statuses
  WHERE		application_id 	= l_application_id
  AND		ledger_id       = l_ledger_id
  AND		period_year 	= l_fiscal_year
  AND		period_num 	= (	SELECT 	MIN(period_num)
                    			FROM   	gl_period_statuses
                    			WHERE	application_id = l_application_id
                    			AND	ledger_id      = l_ledger_id
                    			AND	period_year = l_fiscal_year);
  --
  -- use apis to get the BALANCING segment info
  -- fnd_flex_apis.get_qualifier_segnum gets the segment number
  -- fnd_flex_apis.get_segment_info gets the column name
  --
  IF (FND_FLEX_APIS.get_qualifier_segnum(l_application_id,
					 l_id_flex_code,
            				 l_chart_of_accounts_id,
					 'GL_BALANCING',
            				 l_segnum)) THEN
    IF (FND_FLEX_APIS.get_segment_info(	l_application_id,
					l_id_flex_code,
                			l_chart_of_accounts_id,
					l_segnum,
                			l_balancing_segment_column,
					l_segname,
					l_prompt,
				        l_balancing_value_set)) THEN
      IF (debug_mode = 'Y') THEN
        -- dbms_output.put_line('successfully identified the balancing segment');
	NULL;
      END IF;
    ELSE
      --
      -- Failure in get_segment_info
      --
      IF (debug_mode = 'Y') THEN
        -- dbms_output.put_line('failure at FND_FLEX_APIS.get_segment_info for balancing segment');
	NULL;
      END IF;
      raise segment_not_found;
    END IF;
  ELSE
    IF (debug_mode = 'Y') THEN
      -- dbms_output.put_line('failure at FND_FLEX_APIS.get_qualifier segnum for balancing segment');
	NULL;
    END IF;
    raise segment_not_found;
  END IF;
  --
  -- use apis to get the ACCOUNT segment info
  -- fnd_flex_apis.get_qualifier_segnum gets the segment number
  -- fnd_flex_apis.get_segment_info gets the column name
  --
  IF (FND_FLEX_APIS.get_qualifier_segnum(	l_application_id,
						l_id_flex_code,
              					l_chart_of_accounts_id,
						'GL_ACCOUNT',
              					l_segnum)) THEN
    IF (FND_FLEX_APIS.get_segment_info (l_application_id,
					l_id_flex_code,
                			l_chart_of_accounts_id,
					l_segnum,
                			l_account_segment_column,
					l_segname,
					l_prompt,
                			l_account_value_set)) THEN
      IF (debug_mode = 'Y') THEN
        -- dbms_output.put_line('successfully identified the account segment');
	NULL;
      END IF;
    ELSE
      IF (debug_mode = 'Y') THEN
        -- dbms_output.put_line('failure at FND_FLEX_APIS.get_segment_info for account segment');
	NULL;
      END IF;
      raise segment_not_found;
    END IF;
  ELSE
    IF (debug_mode = 'Y') THEN
      -- dbms_output.put_line('failure at FND_FLEX_APIS.get_qualifier_segnum fore account segment');
      NULL;
    END IF;
    raise segment_not_found;
  END IF;
  --
  -- set the where clause conditions for the balancing segment and account
  --
  IF (p_balancing_value is not null) THEN
    l_balancing_where := ' and gcc.'||l_balancing_segment_column||' = '||''''||p_balancing_value||'''';
    IF (debug_mode = 'Y') THEN
      -- dbms_output.put_line('l_balancing_where = '||l_balancing_where);
      NULL;
    END IF;
  END IF;

  IF (p_account_from is not null) THEN
    l_account_from_where := ' and gcc.'||l_account_segment_column||' >= '||''''||p_account_from||'''';
    IF (debug_mode = 'Y') THEN
      -- dbms_output.put_line('l_account_from_where = '||l_account_from_where);
      NULL;
    END IF;
  END IF;

  IF (p_account_to is not null) THEN
    l_account_to_where := ' and gcc.'||l_account_segment_column||' <= '||''''||p_account_to||'''';
    IF (debug_mode = 'Y') THEN
      -- dbms_output.put_line('l_account_to_where = '||l_account_to_where);
      NULL;
    END IF;
  END IF;
  --
  -- set the where clause condition for the translated_flag
  --
  IF (l_currency_code in (l_functional_currency,'STAT')) THEN
    l_translate_where := ' and bal.translated_flag is null';
  ELSE
    IF (p_translated_flag = 'N') THEN
      l_translate_where := ' and bal.translated_flag = '||''''||'R'||'''';
    ELSE
      l_translate_where := ' and bal.translated_flag in ('||''''||'Y'||''''||','||''''||'N'||''''||')';
    END IF;
  END IF;
  IF (debug_mode = 'Y') THEN
    -- dbms_output.put_line('l_translate_where = '||l_translate_where);
    NULL;
  END IF;
  --
  -- set the sql statement for dynamic sql
  --
  l_dyn_stmt := 'insert into gl_rx_trial_balance_itf (
				request_id,
   				period_name,
   				ledger_id,
   				ledger_name,
   				chart_of_accounts_id,
   				currency_code,
   				balancing_segment,
   				account_segment,
   				summary_flag,
   				begin_year_balance_dr,
   				begin_year_balance_cr,
   				begin_adj_period_net_dr,
   				begin_adj_period_net_cr,
   				begin_period_balance_dr,
   				begin_period_balance_cr,
   				period_net_dr,
   				period_net_cr)
   		SELECT
   				'||to_char(l_request_id)||',
   				'||''''||p_period_name||''''||',
   				'||to_char(l_ledger_id)||',
   				'||''''||p_ledger_name||''''||',
   				'||to_char(l_chart_of_accounts_id)||',
   				'||''''||l_currency_code||''''||',
   				gcc.'||l_balancing_segment_column||',
   				'||'decode('||''''||p_summary_flag||''''||','||
   				''''||'N'||''''||','||'gcc.'||l_account_segment_column||','||
   				''''||'Y'||''''||',substr(gcc.'||l_account_segment_column||
   				',1,'||to_char(nvl(p_summary_digits,1))||')),
   				'||''''||p_summary_flag||''''||',
   				sum(decode(period_name,'||''''||l_first_period_name||''''||',
     				nvl(begin_balance_dr,0), 0)),
   				sum(decode(period_name,'||''''||l_first_period_name||''''||',
     				nvl(begin_balance_cr,0), 0)),
   				sum(decode('||''''||l_adjustment_flag||''''||',
     				'||''''||'Y'||''''||
     				', decode(period_name,'||''''||l_first_period_name||''''||',
     				nvl(period_net_dr,0), 0), 0)),
   				sum(decode('||''''||l_adjustment_flag||''''||',
     				'||''''||'Y'||''''||
     				', decode(period_name,'||''''||l_first_period_name||''''||',
     				nvl(period_net_cr,0), 0), 0)),
   				sum(decode(period_name,'||''''||p_period_name||''''||',
     				nvl(begin_balance_dr,0), 0)),
   				sum(decode(period_name,'||''''||p_period_name||''''||',
     				nvl(begin_balance_cr,0), 0)),
   				sum(decode(period_name,'||''''||p_period_name||''''||',
     				nvl(period_net_dr,0), 0)),
   				sum(decode(period_name,'||''''||p_period_name||''''||',
     				nvl(period_net_cr,0), 0))
   		FROM 		gl_balances bal,
   				gl_code_combinations gcc
   		WHERE		bal.code_combination_id = gcc.code_combination_id
   		AND		bal.ledger_id = '||to_char(l_ledger_id)||'
   		AND		bal.currency_code = '||''''||l_currency_code||''''||'
   		AND		bal.period_name in ('||''''||p_period_name||''''||','||
   				''''||l_first_period_name||''''||')
   		AND		bal.actual_flag = '||''''||'A'||''''||'
   		AND		gcc.chart_of_accounts_id = '||to_char(l_chart_of_accounts_id)||'
   		AND		gcc.template_id is null'||
   				l_balancing_where||
   				l_account_from_where||
   				l_account_to_where||
   				l_translate_where||'
   		GROUP BY
   				gcc.'||l_balancing_segment_column||',
   				decode('||''''||p_summary_flag||''''||','||
   				''''||'N'||''''||',gcc.'||l_account_segment_column||','||
   				''''||'Y'||''''||',substr(gcc.'||l_account_segment_column||',1,'||
   				to_char(nvl(p_summary_digits,1))||'))
  		HAVING
   				sum(decode(period_name,'||''''||l_first_period_name||''''||',
     				nvl(begin_balance_dr,0), 0)) <> 0 OR
   				sum(decode(period_name,'||''''||l_first_period_name||''''||',
     				nvl(begin_balance_cr,0), 0)) <> 0 OR
   				sum(decode('||''''||l_adjustment_flag||''''||',
     				'||''''||'Y'||''''||',decode(period_name,'||''''||l_first_period_name||''''||',
     				nvl(period_net_dr,0), 0), 0)) <> 0 OR
   				sum(decode('||''''||l_adjustment_flag||''''||',
    				'||''''||'Y'||''''||',decode(period_name,'||''''||l_first_period_name||''''||',
     				nvl(period_net_cr,0), 0), 0)) <> 0 OR
   				sum(decode(period_name,'||''''||p_period_name||''''||',
     				nvl(begin_balance_dr,0), 0)) <> 0 OR
  				sum(decode(period_name,'||''''||p_period_name||''''||',
     				nvl(begin_balance_cr,0), 0)) <> 0 OR
  				sum(decode(period_name,'||''''||p_period_name||''''||',
     				nvl(period_net_dr,0), 0)) <> 0 OR
  				sum(decode(period_name,'||''''||p_period_name||''''||',
    				nvl(period_net_cr,0), 0)) <> 0';

  IF (debug_mode = 'Y') THEN
    -- dbms_output.put_line('l_dyn_stm = '||l_dyn_stmt);
    NULL;
  END IF;
  --
  -- execute the dynamic sql
  --
  l_dyn_cursor := dbms_sql.open_cursor;
  dbms_sql.parse(l_dyn_cursor, l_dyn_stmt, dbms_sql.native);
  l_dyn_rows := dbms_sql.execute(l_dyn_cursor);
  dbms_sql.close_cursor(l_dyn_cursor);
  IF (debug_mode = 'Y') THEN
    -- dbms_output.put_line('Done with the main cursor');
    NULL;
  END IF;
  --
  -- if the statutory_rfj_flag = 'Y'
  -- and the beginning adjustment period is open
  -- subtract the previous year's balances
  -- This is because companies cannot run the Closing Journals functionality before
  -- they have recorded all the activity to the closing period.
  -- In some countries you can keep the closing period open for months.
  -- Until you run the Closing Journals, the balances are incorrectly rolled forward.
  -- This update updates the opening balances to 0, pretending that there are no opening balances
  -- (as if the Closing Journals program was already ran)
  --
  IF (p_statutory_rfj_flag = 'Y') THEN
    IF (debug_mode = 'Y') THEN
      -- dbms_output.put_line('Subtracting the opening year balances');
      NULL;
    END IF;
    UPDATE 	gl_rx_trial_balance_itf set
    		begin_year_balance_dr = 0,
    		begin_year_balance_cr = 0,
    		begin_period_balance_dr = (begin_period_balance_dr - begin_year_balance_dr),
    		begin_period_balance_cr = (begin_period_balance_cr - begin_year_balance_cr)
    WHERE	request_id = l_request_id;
  END IF;
  --
  -- update the descriptions and calculated columns in the interface table
  -- a cursor is needed due to pragma restrictions
  -- on fa_rx_shared_pkg.get_flex_val_meaning
  --
  IF (debug_mode = 'Y') THEN
    -- dbms_output.put_line('Opening the update cursor');
    NULL;
  END IF;
  OPEN c1;
  LOOP
    FETCH c1 INTO l_rowid, l_balancing, l_account;
    exit when c1%notfound;
    l_balancing_description 	:= fa_rx_shared_pkg.get_flex_val_meaning(NULL, l_balancing_value_set, 	l_balancing);
    l_account_description 	:= fa_rx_shared_pkg.get_flex_val_meaning(NULL, l_account_value_set, 	l_account);
    UPDATE gl_rx_trial_balance_itf SET
      balancing_description 		= l_balancing_description,
      account_description 		= l_account_description,
      prior_periods_net_dr 		= (begin_period_balance_dr - (begin_year_balance_dr + begin_adj_period_net_dr)),
      prior_periods_net_cr 		= (begin_period_balance_cr - (begin_year_balance_cr + begin_adj_period_net_cr)),
      year_to_date_balance_dr 		= (begin_period_balance_dr + period_net_dr),
      year_to_date_balance_cr 		= (begin_period_balance_cr + period_net_cr),
      year_to_date_net_difference_dr 	= DECODE(SIGN((begin_period_balance_dr + period_net_dr) -
                				      (begin_period_balance_cr + period_net_cr)), 1,
                                                     ((begin_period_balance_dr + period_net_dr) -
                			             (begin_period_balance_cr + period_net_cr)), 0),
      year_to_date_net_difference_cr 	= DECODE(SIGN((begin_period_balance_dr + period_net_dr) -
                				 (begin_period_balance_cr + period_net_cr)), -1,
						  abs((begin_period_balance_dr + period_net_dr) -
                   				 (begin_period_balance_cr + period_net_cr)), 0)
    WHERE
      rowid = l_rowid;
  END LOOP;
  CLOSE C1;

  COMMIT;
  retcode := 0;
  IF (debug_mode = 'Y') THEN
    -- dbms_output.put_line('< RXGLTB.create_rows');
    NULL;
  END IF;
EXCEPTION
  WHEN segment_not_found THEN
    retcode := 2;
  WHEN others THEN
    errbuf := SQLERRM;
    retcode := 2;
end create_rows;
end gl_rx_trial_balance_pkg;

/

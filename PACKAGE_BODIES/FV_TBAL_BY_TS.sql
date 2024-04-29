--------------------------------------------------------
--  DDL for Package Body FV_TBAL_BY_TS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FV_TBAL_BY_TS" AS
/* $Header: FVTBTRSB.pls 120.3.12010000.1 2008/07/28 06:32:03 appldev ship $ */

 g_module_name VARCHAR2(100) := 'fv.plsql.fv_tbal_by_ts.';
 errbuf        VARCHAR2(250);
 retcode       NUMBER;
 g_sob_id      NUMBER;

PROCEDURE purge_summary_txns;
PROCEDURE group_by_columns(x_report_id IN NUMBER,
                           x_attribute_set  IN VARCHAR2,
                           x_group_by OUT NOCOPY VARCHAR2);

PROCEDURE main  (errbuf  OUT NOCOPY     VARCHAR2,
                 retcode OUT NOCOPY     NUMBER  ,
                 p_ledger_id            NUMBER,
	         p_treasury_symbol_low  VARCHAR2,
		 p_treasury_symbol_high VARCHAR2,
		 p_period_name          VARCHAR2,
	         p_amount_type	        VARCHAR2,
		 p_currency_code        VARCHAR2,
                 p_report_id            NUMBER ,
                 p_attribute_set        VARCHAR2 ,
                 p_output_format        VARCHAR2)

IS

CURSOR Cur_ledger
IS
 SELECT name, chart_of_accounts_id FROM gl_ledgers_public_v
 WHERE  ledger_id = p_ledger_id;

CURSOR Cur_seg_name (p_chart_of_accounts_id number, p_attribute_type varchar2)
IS
/* Bug 6244171 - Current query for cursor commented out and new select statement added to fetch correct segment*/
/* SELECT fifsv.application_column_name
 FROM
        fnd_id_flex_segments_vl       fifsv,
        fnd_segment_attribute_values  fsav
 WHERE
        fifsv.application_id = 101
 AND    fifsv.id_flex_code   = 'GL#'
 AND    fifsv.id_flex_num    = fsav.id_flex_num
 AND    fifsv.id_flex_num    = p_chart_of_accounts_id
 AND    fsav.segment_attribute_type = p_attribute_type; */

 SELECT application_column_name
 FROM
        fnd_segment_attribute_values
 WHERE
        application_id = 101
 AND    id_flex_code   = 'GL#'
 AND    id_flex_num    = p_chart_of_accounts_id
 AND    segment_attribute_type = p_attribute_type
 AND    attribute_value = 'Y';

l_module_name           VARCHAR2(200) := g_module_name || 'main';
v_ledger_name           gl_ledgers_public_v.name%TYPE;
v_chart_of_accounts_id  NUMBER;
v_acc_seg_name  	VARCHAR2(25);
v_bal_seg_name		VARCHAR2(25);
v_statement		VARCHAR2(32767);
v_select_begin_balance  VARCHAR2(2000);
v_select_period_dr  	VARCHAR2(2000);
v_select_period_cr  	VARCHAR2(2000);
v_period_list		VARCHAR2(2000);
v_first_period  	VARCHAR2(15);
v_err_buf		VARCHAR2(132);
v_group_by		VARCHAR2(2000);
v_req_id		NUMBER;

BEGIN

    g_sob_id 	           := p_ledger_id;
    retcode		   := 0;

    OPEN  cur_ledger;
    FETCH cur_ledger INTO v_ledger_name, v_chart_of_accounts_id;
    CLOSE cur_ledger;

    OPEN  cur_seg_name (v_chart_of_accounts_id, 'GL_ACCOUNT');
    FETCH cur_seg_name INTO v_acc_seg_name;
    CLOSE cur_seg_name;

    OPEN  cur_seg_name (v_chart_of_accounts_id, 'GL_BALANCING');
    FETCH cur_seg_name INTO v_bal_seg_name ;
    CLOSE cur_seg_name;

    purge_summary_txns;

    group_by_columns(p_report_id, p_attribute_set, v_group_by);

    IF retcode <> 0
      THEN RETURN;
    END IF;

    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'v_group_by: '||v_group_by);
    END IF;

    IF p_amount_type = 'PTD'
     THEN
          v_select_begin_balance :=
                  'SUM(NVL(begin_balance_dr, 0) - NVL(begin_balance_cr, 0))';

          v_select_period_dr := 'SUM(NVL(period_net_dr, 0))';
          v_select_period_cr := 'SUM(NVL(period_net_cr, 0))';

          v_period_list := '(''' || p_period_name || ''')';
     ELSE

          BEGIN

    		fv_utility.gl_get_first_period(g_sob_id,
				               p_period_name,
                                               v_first_period,
					       v_err_buf);
                IF v_err_buf IS NOT NULL
                 THEN
                   retcode := -2;
                   errbuf  := v_err_buf;
                   RETURN;
                END IF;

    	        v_select_begin_balance :=
                     'SUM(DECODE(glb.period_name, ''' || v_first_period || ''',
                      NVL(begin_balance_dr, 0) - NVL(begin_balance_cr, 0), 0))';

                v_select_period_dr :=
                     'SUM(DECODE(glb.period_name, '''||p_period_name||''',
		      NVL(begin_balance_dr,0) + NVL(period_net_dr,0),0) + '||
		     'DECODE(glb.period_name, ''' ||v_first_period || ''',
                      - NVL(begin_balance_dr, 0),0))';

		v_select_period_cr :=
                     'SUM(DECODE(glb.period_name, ''' ||p_period_name||''',
                      NVL(begin_balance_cr,0) + NVL(period_net_cr,0),0) + '||
                     'DECODE(glb.period_name, ''' ||v_first_period || ''',
                      - NVL(begin_balance_cr, 0), 0))';

	        v_period_list :=
                     '(''' || p_period_name || ''','''
                     || v_first_period || ''')';
	   END;

      END IF;

    v_statement :=
	 ' INSERT INTO fv_facts_temp
		(treasury_symbol_id, sgl_acct_number, fct_int_record_category,
		 amount, amount1, amount2 '||
		 REPLACE(v_group_by, 'glcc.' )||')'||
         ' SELECT
                 fts.treasury_symbol_id,
                 glcc.'||v_acc_seg_name||', ''STBAL'','||
		 v_select_begin_balance||', '||
		 v_select_period_dr||', '||
		 v_select_period_cr||
		 v_group_by||
         ' FROM  gl_balances glb,
                 gl_code_combinations glcc,
                 fv_treasury_symbols fts,
                 fv_fund_parameters ffp
	   WHERE glcc.chart_of_accounts_id = '||v_chart_of_accounts_id||
         ' AND   glcc.template_id IS NULL
	   AND   glb.code_combination_id = glcc.code_combination_id
	   AND   fts.treasury_symbol_id = ffp.treasury_symbol_id
	   AND   fts.set_of_books_id = '||g_sob_id||
	 ' AND   ffp.fund_value      = glcc.'||v_bal_seg_name||
	 ' AND  (fts.treasury_symbol
                      BETWEEN '''||p_treasury_symbol_low||''' AND '''||
                                 p_treasury_symbol_high||''' )
           AND   glb.ledger_id = '||g_sob_id||
	 ' AND   glb.actual_flag = ''A''
           AND   glb.period_name IN '||v_period_list||'
	   AND   glb.currency_code = '''||p_currency_code||'''
           AND   (glb.translated_flag <> ''R''
			OR glb.translated_flag IS NULL)
	   GROUP BY fts.treasury_symbol_id, glcc.'||v_acc_seg_name ||
                    v_group_by ;

     IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'Select: '|| v_statement);
     END IF;

    EXECUTE IMMEDIATE v_statement;

    v_req_id :=
              fnd_request.submit_request ('FV','RXFVTBTS','','',FALSE,
                'DIRECT',
                p_report_id,
                p_attribute_set,
                p_output_format,
                v_ledger_name,
                p_currency_code,
                p_treasury_symbol_low,
                p_treasury_symbol_high,
                p_period_name,
                p_amount_type);

    IF v_req_id = 0 THEN
       retcode := -2;
       errbuf  := 'Error submitting Trial Balance report' ;
       FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name||'.exception1',errbuf);
    END IF;

 EXCEPTION WHEN OTHERS THEN
    retcode := sqlcode;
    errbuf  := SUBSTR(sqlerrm,1,250);
   FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',errbuf);
END main;
--------------------------------------------------------------------------------------
PROCEDURE purge_summary_txns IS
  l_module_name VARCHAR2(200) := g_module_name || 'purge_summary_txns';
BEGIN

     IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'Purging facts temp table');
     END IF;

     DELETE
     FROM   fv_facts_temp
     WHERE  fct_int_record_category = 'STBAL';
EXCEPTION
  WHEN OTHERS THEN
   retcode := -1;
   errbuf  := 'Error while grouping by: '||SUBSTR(sqlerrm,1,200);
   FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',errbuf);
   RAISE;
END purge_summary_txns;
--------------------------------------------------------------------------------
-- This procedure selects the break columns, which the user has setup for the
-- RXi report, and uses these columns as the group by columns in the main
-- select.
--------------------------------------------------------------------------------
PROCEDURE group_by_columns(x_report_id IN NUMBER,
                           x_attribute_set  IN VARCHAR2,
                           x_group_by OUT NOCOPY VARCHAR2)
IS
  l_module_name VARCHAR2(200) := g_module_name || 'group_by_columns';

     CURSOR c_group IS
        SELECT column_name
        FROM   fa_rx_rep_columns_b
        WHERE  report_id = x_report_id
        AND    attribute_set = x_attribute_set
        AND    break = 'Y';

BEGIN

   FOR crec IN c_group
     LOOP
         IF crec.column_name LIKE 'SEGMENT%'
          THEN
            IF x_group_by IS NOT NULL
              THEN
               x_group_by := x_group_by || ',' ;
            END IF;
            x_group_by := x_group_by || 'glcc.' || crec.column_name;
         END IF;

     END LOOP;

   IF x_group_by IS NOT NULL
       THEN
         x_group_by := ',' || x_group_by;
   END IF;
 EXCEPTION WHEN OTHERS THEN
   retcode := -1;
   errbuf  := 'Error while grouping by: '||SUBSTR(sqlerrm,1,200);
   FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||'.final_exception',errbuf);

END group_by_columns;
--------------------------------------------------------------------------------------
END fv_tbal_by_ts;

/

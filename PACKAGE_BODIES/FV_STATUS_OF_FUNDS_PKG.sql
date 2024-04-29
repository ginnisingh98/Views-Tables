--------------------------------------------------------
--  DDL for Package Body FV_STATUS_OF_FUNDS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FV_STATUS_OF_FUNDS_PKG" AS
/* $Header: FVXSFFDB.pls 120.10 2005/10/06 21:04:27 vtreiger ship $ | */

/*******************************************************************/
/*****        Variable Declaration For All Processes          ******/
/*******************************************************************/
g_module_name       varchar2(100)   :=  'fv.plsql.fv_status_of_funds_pkg.'	;
v_budget        	fv_fund_parameters.budget_authority%TYPE;
v_commitment    	fv_fund_parameters.unliquid_commitments%TYPE;
v_obligation    	fv_fund_parameters.unliquid_obligations%TYPE;
v_expenditure   	fv_fund_parameters.expended_amount%TYPE;
v_transfers_in		fv_fund_parameters.transfers_in%TYPE;
v_transfers_out		fv_fund_parameters.transfers_out%TYPE;
v_fund_value    	fv_fund_parameters.fund_value%TYPE;
v_fund_value1    	fv_fund_parameters.fund_value%TYPE;
v_treasury_symbol 	fv_fund_parameters.treasury_symbol%TYPE;
v_treasury_symbol1	fv_fund_parameters.treasury_symbol%TYPE;
v_statement      	varchar2(2);
err_message     	varchar2(300);
acct_flex_id    	fnd_flex_values.flex_value_id%TYPE;
v_ca_id			gl_sets_of_books.chart_of_accounts_id%TYPE;
x_period_num    	gl_period_statuses.period_num%TYPE;
v_segment_low_name  	number;
v_segment_num       	number;
parent_flag     	varchar2(1);
rollup_type     	varchar2(1);
bal_seg_name_num 	number(2);
acct_ff_low    		varchar2(2000);
acct_ff_high		varchar2(2000);
acct_seg_name_num 	number(2);
sob_id         		gl_balances.ledger_id%TYPE;
sob_id1         	gl_balances.ledger_id%TYPE;
curr_code      		gl_balances.currency_code%TYPE;
pd_name        		gl_balances.period_name%TYPE;
v_value_low    		varchar2(60);
v_value_high   		varchar2(60);
acct_seg_name    	varchar2(25);
bal_seg_name		varchar2(25);
v_pagebreak_seg1 	varchar2(25);
v_pagebreak_seg2 	varchar2(25);
v_pagebreak_seg3 	varchar2(25);
v_acct_type		varchar2(12);
v_trans_type		varchar2(12);
v_spend_type		varchar2(12);
v_sign			varchar2(1);

-- New variable declared by pkpatel to fix Bug.1575992
v_treasury_symbol_id fv_treasury_symbols.treasury_symbol_id%TYPE;
-- Bug 1575992 Variable temp_v_treasury_symbol_id defined
--to be used in the cursor c_treasury_fund_values
temp_v_treasury_symbol_id varchar2(20) ;
/*******************************************************************/
/*****       Cursor Declaration For All Processes             ******/
/*******************************************************************/

CURSOR c_segment_info IS
  SELECT UPPER(application_column_name) application_column_name
  FROM fnd_id_flex_segments
  WHERE application_id = 101
  AND id_flex_code   = 'GL#'
  AND id_flex_num    = v_ca_id
  ORDER BY segment_num;

CURSOR c_balances_spending IS
   SELECT  sum((nvl(glb.begin_balance_dr,0) - nvl(glb.begin_balance_cr,0)) +
           (nvl(glB.PERIOD_NET_DR,0) - nvl(glB.PERIOD_NET_cr,0))) bal_spend,
		decode(v_pagebreak_seg1,'SEGMENT1',glc.segment1,'SEGMENT2',glc.segment2,
				'SEGMENT3',glc.segment3,'SEGMENT4',glc.segment4,
				'SEGMENT5',glc.segment5,'SEGMENT6',glc.segment6,
				'SEGMENT7',glc.segment7,'SEGMENT8',glc.segment8,
				'SEGMENT9',glc.segment9,'SEGMENT10',glc.segment10,
				'SEGMENT11',glc.segment11,'SEGMENT12',glc.segment12,
				'SEGMENT13',glc.segment13,'SEGMENT14',glc.segment14,
				'SEGMENT15',glc.segment15,'SEGMENT16',glc.segment16,
				'SEGMENT17',glc.segment17,'SEGMENT18',glc.segment18,
				'SEGMENT19',glc.segment19,'SEGMENT20',glc.segment20,
				'SEGMENT21',glc.segment21,'SEGMENT22',glc.segment22,
				'SEGMENT23',glc.segment23,'SEGMENT24',glc.segment24,
				'SEGMENT25',glc.segment25,'SEGMENT26',glc.segment26,
				'SEGMENT27',glc.segment27,'SEGMENT28',glc.segment28,
				'SEGMENT29',glc.segment29,'SEGMENT30',glc.segment30) pg1,
		decode(v_pagebreak_seg2,'SEGMENT1',glc.segment1,'SEGMENT2',glc.segment2,
				'SEGMENT3',glc.segment3,'SEGMENT4',glc.segment4,
				'SEGMENT5',glc.segment5,'SEGMENT6',glc.segment6,
				'SEGMENT7',glc.segment7,'SEGMENT8',glc.segment8,
				'SEGMENT9',glc.segment9,'SEGMENT10',glc.segment10,
				'SEGMENT11',glc.segment11,'SEGMENT12',glc.segment12,
				'SEGMENT13',glc.segment13,'SEGMENT14',glc.segment14,
				'SEGMENT15',glc.segment15,'SEGMENT16',glc.segment16,
				'SEGMENT17',glc.segment17,'SEGMENT18',glc.segment18,
				'SEGMENT19',glc.segment19,'SEGMENT20',glc.segment20,
				'SEGMENT21',glc.segment21,'SEGMENT22',glc.segment22,
				'SEGMENT23',glc.segment23,'SEGMENT24',glc.segment24,
				'SEGMENT25',glc.segment25,'SEGMENT26',glc.segment26,
				'SEGMENT27',glc.segment27,'SEGMENT28',glc.segment28,
				'SEGMENT29',glc.segment29,'SEGMENT30',glc.segment30) pg2,
		decode(v_pagebreak_seg3,'SEGMENT1',glc.segment1,'SEGMENT2',glc.segment2,
				'SEGMENT3',glc.segment3,'SEGMENT4',glc.segment4,
				'SEGMENT5',glc.segment5,'SEGMENT6',glc.segment6,
				'SEGMENT7',glc.segment7,'SEGMENT8',glc.segment8,
				'SEGMENT9',glc.segment9,'SEGMENT10',glc.segment10,
				'SEGMENT11',glc.segment11,'SEGMENT12',glc.segment12,
				'SEGMENT13',glc.segment13,'SEGMENT14',glc.segment14,
				'SEGMENT15',glc.segment15,'SEGMENT16',glc.segment16,
				'SEGMENT17',glc.segment17,'SEGMENT18',glc.segment18,
				'SEGMENT19',glc.segment19,'SEGMENT20',glc.segment20,
				'SEGMENT21',glc.segment21,'SEGMENT22',glc.segment22,
				'SEGMENT23',glc.segment23,'SEGMENT24',glc.segment24,
				'SEGMENT25',glc.segment25,'SEGMENT26',glc.segment26,
				'SEGMENT27',glc.segment27,'SEGMENT28',glc.segment28,
				'SEGMENT29',glc.segment29,'SEGMENT30',glc.segment30) pg3
   FROM     gl_BALANCES               glB,
            gl_code_combinations      glc
   WHERE    glb.code_combination_id = glc.code_combination_id
   AND	    glc.chart_of_accounts_id 	 = v_ca_id
   AND      glb.ledger_id                = sob_id
   AND      glb.currency_code            = curr_code
   AND      glb.actual_flag              = 'A'
   AND      glc.enabled_flag             = 'Y'
   AND      glc.template_id  IS NULL
   AND      glb.period_name              = pd_name
   AND      decode(bal_seg_name,'SEGMENT1',glc.segment1,'SEGMENT2',glc.segment2,
				'SEGMENT3',glc.segment3,'SEGMENT4',glc.segment4,
				'SEGMENT5',glc.segment5,'SEGMENT6',glc.segment6,
				'SEGMENT7',glc.segment7,'SEGMENT8',glc.segment8,
				'SEGMENT9',glc.segment9,'SEGMENT10',glc.segment10,
				'SEGMENT11',glc.segment11,'SEGMENT12',glc.segment12,
				'SEGMENT13',glc.segment13,'SEGMENT14',glc.segment14,
				'SEGMENT15',glc.segment15,'SEGMENT16',glc.segment16,
				'SEGMENT17',glc.segment17,'SEGMENT18',glc.segment18,
				'SEGMENT19',glc.segment19,'SEGMENT20',glc.segment20,
				'SEGMENT21',glc.segment21,'SEGMENT22',glc.segment22,
				'SEGMENT23',glc.segment23,'SEGMENT24',glc.segment24,
				'SEGMENT25',glc.segment25,'SEGMENT26',glc.segment26,
				'SEGMENT27',glc.segment27,'SEGMENT28',glc.segment28,
				'SEGMENT29',glc.segment29,'SEGMENT30',glc.segment30) = v_fund_value
   AND 	decode(acct_seg_name,'SEGMENT1',glc.segment1,'SEGMENT2',glc.segment2,
				'SEGMENT3',glc.segment3,'SEGMENT4',glc.segment4,
				'SEGMENT5',glc.segment5,'SEGMENT6',glc.segment6,
				'SEGMENT7',glc.segment7,'SEGMENT8',glc.segment8,
				'SEGMENT9',glc.segment9,'SEGMENT10',glc.segment10,
				'SEGMENT11',glc.segment11,'SEGMENT12',glc.segment12,
				'SEGMENT13',glc.segment13,'SEGMENT14',glc.segment14,
				'SEGMENT15',glc.segment15,'SEGMENT16',glc.segment16,
				'SEGMENT17',glc.segment17,'SEGMENT18',glc.segment18,
				'SEGMENT19',glc.segment19,'SEGMENT20',glc.segment20,
				'SEGMENT21',glc.segment21,'SEGMENT22',glc.segment22,
				'SEGMENT23',glc.segment23,'SEGMENT24',glc.segment24,
				'SEGMENT25',glc.segment25,'SEGMENT26',glc.segment26,
				'SEGMENT27',glc.segment27,'SEGMENT28',glc.segment28,
				'SEGMENT29',glc.segment29,'SEGMENT30',glc.segment30)
				between v_value_low and v_value_high
   group by decode(v_pagebreak_seg1,'SEGMENT1',glc.segment1,'SEGMENT2',glc.segment2,
				'SEGMENT3',glc.segment3,'SEGMENT4',glc.segment4,
				'SEGMENT5',glc.segment5,'SEGMENT6',glc.segment6,
				'SEGMENT7',glc.segment7,'SEGMENT8',glc.segment8,
				'SEGMENT9',glc.segment9,'SEGMENT10',glc.segment10,
				'SEGMENT11',glc.segment11,'SEGMENT12',glc.segment12,
				'SEGMENT13',glc.segment13,'SEGMENT14',glc.segment14,
				'SEGMENT15',glc.segment15,'SEGMENT16',glc.segment16,
				'SEGMENT17',glc.segment17,'SEGMENT18',glc.segment18,
				'SEGMENT19',glc.segment19,'SEGMENT20',glc.segment20,
				'SEGMENT21',glc.segment21,'SEGMENT22',glc.segment22,
				'SEGMENT23',glc.segment23,'SEGMENT24',glc.segment24,
				'SEGMENT25',glc.segment25,'SEGMENT26',glc.segment26,
				'SEGMENT27',glc.segment27,'SEGMENT28',glc.segment28,
				'SEGMENT29',glc.segment29,'SEGMENT30',glc.segment30),
		   decode(v_pagebreak_seg2,'SEGMENT1',glc.segment1,'SEGMENT2',glc.segment2,
				'SEGMENT3',glc.segment3,'SEGMENT4',glc.segment4,
				'SEGMENT5',glc.segment5,'SEGMENT6',glc.segment6,
				'SEGMENT7',glc.segment7,'SEGMENT8',glc.segment8,
				'SEGMENT9',glc.segment9,'SEGMENT10',glc.segment10,
				'SEGMENT11',glc.segment11,'SEGMENT12',glc.segment12,
				'SEGMENT13',glc.segment13,'SEGMENT14',glc.segment14,
				'SEGMENT15',glc.segment15,'SEGMENT16',glc.segment16,
				'SEGMENT17',glc.segment17,'SEGMENT18',glc.segment18,
				'SEGMENT19',glc.segment19,'SEGMENT20',glc.segment20,
				'SEGMENT21',glc.segment21,'SEGMENT22',glc.segment22,
				'SEGMENT23',glc.segment23,'SEGMENT24',glc.segment24,
				'SEGMENT25',glc.segment25,'SEGMENT26',glc.segment26,
				'SEGMENT27',glc.segment27,'SEGMENT28',glc.segment28,
				'SEGMENT29',glc.segment29,'SEGMENT30',glc.segment30),
		    decode(v_pagebreak_seg3,'SEGMENT1',glc.segment1,'SEGMENT2',glc.segment2,
				'SEGMENT3',glc.segment3,'SEGMENT4',glc.segment4,
				'SEGMENT5',glc.segment5,'SEGMENT6',glc.segment6,
				'SEGMENT7',glc.segment7,'SEGMENT8',glc.segment8,
				'SEGMENT9',glc.segment9,'SEGMENT10',glc.segment10,
				'SEGMENT11',glc.segment11,'SEGMENT12',glc.segment12,
				'SEGMENT13',glc.segment13,'SEGMENT14',glc.segment14,
				'SEGMENT15',glc.segment15,'SEGMENT16',glc.segment16,
				'SEGMENT17',glc.segment17,'SEGMENT18',glc.segment18,
				'SEGMENT19',glc.segment19,'SEGMENT20',glc.segment20,
				'SEGMENT21',glc.segment21,'SEGMENT22',glc.segment22,
				'SEGMENT23',glc.segment23,'SEGMENT24',glc.segment24,
				'SEGMENT25',glc.segment25,'SEGMENT26',glc.segment26,
				'SEGMENT27',glc.segment27,'SEGMENT28',glc.segment28,
				'SEGMENT29',glc.segment29,'SEGMENT30',glc.segment30) ;


CURSOR c_balances_budget IS
   SELECT  sum((nvl(glb.begin_balance_dr,0) - nvl(glb.begin_balance_cr,0)) +
           (nvl(glB.PERIOD_NET_DR,0) - nvl(glB.PERIOD_NET_cr,0))) bal_bud,
		decode(v_pagebreak_seg1,'SEGMENT1',glc.segment1,'SEGMENT2',glc.segment2,
				'SEGMENT3',glc.segment3,'SEGMENT4',glc.segment4,
				'SEGMENT5',glc.segment5,'SEGMENT6',glc.segment6,
				'SEGMENT7',glc.segment7,'SEGMENT8',glc.segment8,
				'SEGMENT9',glc.segment9,'SEGMENT10',glc.segment10,
				'SEGMENT11',glc.segment11,'SEGMENT12',glc.segment12,
				'SEGMENT13',glc.segment13,'SEGMENT14',glc.segment14,
				'SEGMENT15',glc.segment15,'SEGMENT16',glc.segment16,
				'SEGMENT17',glc.segment17,'SEGMENT18',glc.segment18,
				'SEGMENT19',glc.segment19,'SEGMENT20',glc.segment20,
				'SEGMENT21',glc.segment21,'SEGMENT22',glc.segment22,
				'SEGMENT23',glc.segment23,'SEGMENT24',glc.segment24,
				'SEGMENT25',glc.segment25,'SEGMENT26',glc.segment26,
				'SEGMENT27',glc.segment27,'SEGMENT28',glc.segment28,
				'SEGMENT29',glc.segment29,'SEGMENT30',glc.segment30) pg1,
		decode(v_pagebreak_seg2,'SEGMENT1',glc.segment1,'SEGMENT2',glc.segment2,
				'SEGMENT3',glc.segment3,'SEGMENT4',glc.segment4,
				'SEGMENT5',glc.segment5,'SEGMENT6',glc.segment6,
				'SEGMENT7',glc.segment7,'SEGMENT8',glc.segment8,
				'SEGMENT9',glc.segment9,'SEGMENT10',glc.segment10,
				'SEGMENT11',glc.segment11,'SEGMENT12',glc.segment12,
				'SEGMENT13',glc.segment13,'SEGMENT14',glc.segment14,
				'SEGMENT15',glc.segment15,'SEGMENT16',glc.segment16,
				'SEGMENT17',glc.segment17,'SEGMENT18',glc.segment18,
				'SEGMENT19',glc.segment19,'SEGMENT20',glc.segment20,
				'SEGMENT21',glc.segment21,'SEGMENT22',glc.segment22,
				'SEGMENT23',glc.segment23,'SEGMENT24',glc.segment24,
				'SEGMENT25',glc.segment25,'SEGMENT26',glc.segment26,
				'SEGMENT27',glc.segment27,'SEGMENT28',glc.segment28,
				'SEGMENT29',glc.segment29,'SEGMENT30',glc.segment30) pg2,
		decode(v_pagebreak_seg3,'SEGMENT1',glc.segment1,'SEGMENT2',glc.segment2,
				'SEGMENT3',glc.segment3,'SEGMENT4',glc.segment4,
				'SEGMENT5',glc.segment5,'SEGMENT6',glc.segment6,
				'SEGMENT7',glc.segment7,'SEGMENT8',glc.segment8,
				'SEGMENT9',glc.segment9,'SEGMENT10',glc.segment10,
				'SEGMENT11',glc.segment11,'SEGMENT12',glc.segment12,
				'SEGMENT13',glc.segment13,'SEGMENT14',glc.segment14,
				'SEGMENT15',glc.segment15,'SEGMENT16',glc.segment16,
				'SEGMENT17',glc.segment17,'SEGMENT18',glc.segment18,
				'SEGMENT19',glc.segment19,'SEGMENT20',glc.segment20,
				'SEGMENT21',glc.segment21,'SEGMENT22',glc.segment22,
				'SEGMENT23',glc.segment23,'SEGMENT24',glc.segment24,
				'SEGMENT25',glc.segment25,'SEGMENT26',glc.segment26,
				'SEGMENT27',glc.segment27,'SEGMENT28',glc.segment28,
				'SEGMENT29',glc.segment29,'SEGMENT30',glc.segment30) pg3
   FROM     gl_BALANCES               glB,
            gl_code_combinations      glc
   WHERE    glb.code_combination_id = glc.code_combination_id
   AND	    glc.chart_of_accounts_id 	 = v_ca_id
   AND      glb.ledger_id           = sob_id
   AND      glb.currency_code       = curr_code
   AND      glb.actual_flag         = 'A'
   AND      glc.enabled_flag        = 'Y'
   AND      glc.template_id  IS NULL
   AND      glb.period_name         = pd_name
   AND      decode(bal_seg_name,'SEGMENT1',glc.segment1,'SEGMENT2',glc.segment2,
				'SEGMENT3',glc.segment3,'SEGMENT4',glc.segment4,
				'SEGMENT5',glc.segment5,'SEGMENT6',glc.segment6,
				'SEGMENT7',glc.segment7,'SEGMENT8',glc.segment8,
				'SEGMENT9',glc.segment9,'SEGMENT10',glc.segment10,
				'SEGMENT11',glc.segment11,'SEGMENT12',glc.segment12,
				'SEGMENT13',glc.segment13,'SEGMENT14',glc.segment14,
				'SEGMENT15',glc.segment15,'SEGMENT16',glc.segment16,
				'SEGMENT17',glc.segment17,'SEGMENT18',glc.segment18,
				'SEGMENT19',glc.segment19,'SEGMENT20',glc.segment20,
				'SEGMENT21',glc.segment21,'SEGMENT22',glc.segment22,
				'SEGMENT23',glc.segment23,'SEGMENT24',glc.segment24,
				'SEGMENT25',glc.segment25,'SEGMENT26',glc.segment26,
				'SEGMENT27',glc.segment27,'SEGMENT28',glc.segment28,
				'SEGMENT29',glc.segment29,'SEGMENT30',glc.segment30) = v_fund_value
   AND 	decode(acct_seg_name,'SEGMENT1',glc.segment1,'SEGMENT2',glc.segment2,
				'SEGMENT3',glc.segment3,'SEGMENT4',glc.segment4,
				'SEGMENT5',glc.segment5,'SEGMENT6',glc.segment6,
				'SEGMENT7',glc.segment7,'SEGMENT8',glc.segment8,
				'SEGMENT9',glc.segment9,'SEGMENT10',glc.segment10,
				'SEGMENT11',glc.segment11,'SEGMENT12',glc.segment12,
				'SEGMENT13',glc.segment13,'SEGMENT14',glc.segment14,
				'SEGMENT15',glc.segment15,'SEGMENT16',glc.segment16,
				'SEGMENT17',glc.segment17,'SEGMENT18',glc.segment18,
				'SEGMENT19',glc.segment19,'SEGMENT20',glc.segment20,
				'SEGMENT21',glc.segment21,'SEGMENT22',glc.segment22,
				'SEGMENT23',glc.segment23,'SEGMENT24',glc.segment24,
				'SEGMENT25',glc.segment25,'SEGMENT26',glc.segment26,
				'SEGMENT27',glc.segment27,'SEGMENT28',glc.segment28,
				'SEGMENT29',glc.segment29,'SEGMENT30',glc.segment30)
				between v_value_low and v_value_high
	group by decode(v_pagebreak_seg1,'SEGMENT1',glc.segment1,'SEGMENT2',glc.segment2,
				'SEGMENT3',glc.segment3,'SEGMENT4',glc.segment4,
				'SEGMENT5',glc.segment5,'SEGMENT6',glc.segment6,
				'SEGMENT7',glc.segment7,'SEGMENT8',glc.segment8,
				'SEGMENT9',glc.segment9,'SEGMENT10',glc.segment10,
				'SEGMENT11',glc.segment11,'SEGMENT12',glc.segment12,
				'SEGMENT13',glc.segment13,'SEGMENT14',glc.segment14,
				'SEGMENT15',glc.segment15,'SEGMENT16',glc.segment16,
				'SEGMENT17',glc.segment17,'SEGMENT18',glc.segment18,
				'SEGMENT19',glc.segment19,'SEGMENT20',glc.segment20,
				'SEGMENT21',glc.segment21,'SEGMENT22',glc.segment22,
				'SEGMENT23',glc.segment23,'SEGMENT24',glc.segment24,
				'SEGMENT25',glc.segment25,'SEGMENT26',glc.segment26,
				'SEGMENT27',glc.segment27,'SEGMENT28',glc.segment28,
				'SEGMENT29',glc.segment29,'SEGMENT30',glc.segment30),
		   decode(v_pagebreak_seg2,'SEGMENT1',glc.segment1,'SEGMENT2',glc.segment2,
				'SEGMENT3',glc.segment3,'SEGMENT4',glc.segment4,
				'SEGMENT5',glc.segment5,'SEGMENT6',glc.segment6,
				'SEGMENT7',glc.segment7,'SEGMENT8',glc.segment8,
				'SEGMENT9',glc.segment9,'SEGMENT10',glc.segment10,
				'SEGMENT11',glc.segment11,'SEGMENT12',glc.segment12,
				'SEGMENT13',glc.segment13,'SEGMENT14',glc.segment14,
				'SEGMENT15',glc.segment15,'SEGMENT16',glc.segment16,
				'SEGMENT17',glc.segment17,'SEGMENT18',glc.segment18,
				'SEGMENT19',glc.segment19,'SEGMENT20',glc.segment20,
				'SEGMENT21',glc.segment21,'SEGMENT22',glc.segment22,
				'SEGMENT23',glc.segment23,'SEGMENT24',glc.segment24,
				'SEGMENT25',glc.segment25,'SEGMENT26',glc.segment26,
				'SEGMENT27',glc.segment27,'SEGMENT28',glc.segment28,
				'SEGMENT29',glc.segment29,'SEGMENT30',glc.segment30),
		    decode(v_pagebreak_seg3,'SEGMENT1',glc.segment1,'SEGMENT2',glc.segment2,
				'SEGMENT3',glc.segment3,'SEGMENT4',glc.segment4,
				'SEGMENT5',glc.segment5,'SEGMENT6',glc.segment6,
				'SEGMENT7',glc.segment7,'SEGMENT8',glc.segment8,
				'SEGMENT9',glc.segment9,'SEGMENT10',glc.segment10,
				'SEGMENT11',glc.segment11,'SEGMENT12',glc.segment12,
				'SEGMENT13',glc.segment13,'SEGMENT14',glc.segment14,
				'SEGMENT15',glc.segment15,'SEGMENT16',glc.segment16,
				'SEGMENT17',glc.segment17,'SEGMENT18',glc.segment18,
				'SEGMENT19',glc.segment19,'SEGMENT20',glc.segment20,
				'SEGMENT21',glc.segment21,'SEGMENT22',glc.segment22,
				'SEGMENT23',glc.segment23,'SEGMENT24',glc.segment24,
				'SEGMENT25',glc.segment25,'SEGMENT26',glc.segment26,
				'SEGMENT27',glc.segment27,'SEGMENT28',glc.segment28,
				'SEGMENT29',glc.segment29,'SEGMENT30',glc.segment30) ;
--	group by SEGMENT1, SEGMENT3, SEGMENT30;

CURSOR c_balances_transfers IS
   SELECT  sum((nvl(glb.begin_balance_dr,0) - nvl(glb.begin_balance_cr,0)) +
           (nvl(glB.PERIOD_NET_DR,0) - nvl(glB.PERIOD_NET_cr,0))) bal_trans,
		decode(v_pagebreak_seg1,'SEGMENT1',glc.segment1,'SEGMENT2',glc.segment2,
				'SEGMENT3',glc.segment3,'SEGMENT4',glc.segment4,
				'SEGMENT5',glc.segment5,'SEGMENT6',glc.segment6,
				'SEGMENT7',glc.segment7,'SEGMENT8',glc.segment8,
				'SEGMENT9',glc.segment9,'SEGMENT10',glc.segment10,
				'SEGMENT11',glc.segment11,'SEGMENT12',glc.segment12,
				'SEGMENT13',glc.segment13,'SEGMENT14',glc.segment14,
				'SEGMENT15',glc.segment15,'SEGMENT16',glc.segment16,
				'SEGMENT17',glc.segment17,'SEGMENT18',glc.segment18,
				'SEGMENT19',glc.segment19,'SEGMENT20',glc.segment20,
				'SEGMENT21',glc.segment21,'SEGMENT22',glc.segment22,
				'SEGMENT23',glc.segment23,'SEGMENT24',glc.segment24,
				'SEGMENT25',glc.segment25,'SEGMENT26',glc.segment26,
				'SEGMENT27',glc.segment27,'SEGMENT28',glc.segment28,
				'SEGMENT29',glc.segment29,'SEGMENT30',glc.segment30) pg1,
		decode(v_pagebreak_seg2,'SEGMENT1',glc.segment1,'SEGMENT2',glc.segment2,
				'SEGMENT3',glc.segment3,'SEGMENT4',glc.segment4,
				'SEGMENT5',glc.segment5,'SEGMENT6',glc.segment6,
				'SEGMENT7',glc.segment7,'SEGMENT8',glc.segment8,
				'SEGMENT9',glc.segment9,'SEGMENT10',glc.segment10,
				'SEGMENT11',glc.segment11,'SEGMENT12',glc.segment12,
				'SEGMENT13',glc.segment13,'SEGMENT14',glc.segment14,
				'SEGMENT15',glc.segment15,'SEGMENT16',glc.segment16,
				'SEGMENT17',glc.segment17,'SEGMENT18',glc.segment18,
				'SEGMENT19',glc.segment19,'SEGMENT20',glc.segment20,
				'SEGMENT21',glc.segment21,'SEGMENT22',glc.segment22,
				'SEGMENT23',glc.segment23,'SEGMENT24',glc.segment24,
				'SEGMENT25',glc.segment25,'SEGMENT26',glc.segment26,
				'SEGMENT27',glc.segment27,'SEGMENT28',glc.segment28,
				'SEGMENT29',glc.segment29,'SEGMENT30',glc.segment30) pg2,
		decode(v_pagebreak_seg3,'SEGMENT1',glc.segment1,'SEGMENT2',glc.segment2,
				'SEGMENT3',glc.segment3,'SEGMENT4',glc.segment4,
				'SEGMENT5',glc.segment5,'SEGMENT6',glc.segment6,
				'SEGMENT7',glc.segment7,'SEGMENT8',glc.segment8,
				'SEGMENT9',glc.segment9,'SEGMENT10',glc.segment10,
				'SEGMENT11',glc.segment11,'SEGMENT12',glc.segment12,
				'SEGMENT13',glc.segment13,'SEGMENT14',glc.segment14,
				'SEGMENT15',glc.segment15,'SEGMENT16',glc.segment16,
				'SEGMENT17',glc.segment17,'SEGMENT18',glc.segment18,
				'SEGMENT19',glc.segment19,'SEGMENT20',glc.segment20,
				'SEGMENT21',glc.segment21,'SEGMENT22',glc.segment22,
				'SEGMENT23',glc.segment23,'SEGMENT24',glc.segment24,
				'SEGMENT25',glc.segment25,'SEGMENT26',glc.segment26,
				'SEGMENT27',glc.segment27,'SEGMENT28',glc.segment28,
				'SEGMENT29',glc.segment29,'SEGMENT30',glc.segment30) pg3
   FROM    gl_balances			glB,
	    gl_code_combinations	glc
   WHERE    glb.code_combination_id = glc.code_combination_id
   AND	    glc.chart_of_accounts_id 	 = v_ca_id
   AND      glb.ledger_id           = sob_id
   AND      glb.currency_code       = curr_code
   AND      glb.actual_flag         = 'A'
   AND      glc.enabled_flag        = 'Y'
   AND      glc.template_id  IS NULL
   AND      glb.period_name         = pd_name
   AND      decode(bal_seg_name,'SEGMENT1',glc.segment1,'SEGMENT2',glc.segment2,
				'SEGMENT3',glc.segment3,'SEGMENT4',glc.segment4,
				'SEGMENT5',glc.segment5,'SEGMENT6',glc.segment6,
				'SEGMENT7',glc.segment7,'SEGMENT8',glc.segment8,
				'SEGMENT9',glc.segment9,'SEGMENT10',glc.segment10,
				'SEGMENT11',glc.segment11,'SEGMENT12',glc.segment12,
				'SEGMENT13',glc.segment13,'SEGMENT14',glc.segment14,
				'SEGMENT15',glc.segment15,'SEGMENT16',glc.segment16,
				'SEGMENT17',glc.segment17,'SEGMENT18',glc.segment18,
				'SEGMENT19',glc.segment19,'SEGMENT20',glc.segment20,
				'SEGMENT21',glc.segment21,'SEGMENT22',glc.segment22,
				'SEGMENT23',glc.segment23,'SEGMENT24',glc.segment24,
				'SEGMENT25',glc.segment25,'SEGMENT26',glc.segment26,
				'SEGMENT27',glc.segment27,'SEGMENT28',glc.segment28,
				'SEGMENT29',glc.segment29,'SEGMENT30',glc.segment30) = v_fund_value
   AND 	decode(acct_seg_name,'SEGMENT1',glc.segment1,'SEGMENT2',glc.segment2,
				'SEGMENT3',glc.segment3,'SEGMENT4',glc.segment4,
				'SEGMENT5',glc.segment5,'SEGMENT6',glc.segment6,
				'SEGMENT7',glc.segment7,'SEGMENT8',glc.segment8,
				'SEGMENT9',glc.segment9,'SEGMENT10',glc.segment10,
				'SEGMENT11',glc.segment11,'SEGMENT12',glc.segment12,
				'SEGMENT13',glc.segment13,'SEGMENT14',glc.segment14,
				'SEGMENT15',glc.segment15,'SEGMENT16',glc.segment16,
				'SEGMENT17',glc.segment17,'SEGMENT18',glc.segment18,
				'SEGMENT19',glc.segment19,'SEGMENT20',glc.segment20,
				'SEGMENT21',glc.segment21,'SEGMENT22',glc.segment22,
				'SEGMENT23',glc.segment23,'SEGMENT24',glc.segment24,
				'SEGMENT25',glc.segment25,'SEGMENT26',glc.segment26,
				'SEGMENT27',glc.segment27,'SEGMENT28',glc.segment28,
				'SEGMENT29',glc.segment29,'SEGMENT30',glc.segment30)
				between v_value_low and v_value_high
	group by decode(v_pagebreak_seg1,'SEGMENT1',glc.segment1,'SEGMENT2',glc.segment2,
				'SEGMENT3',glc.segment3,'SEGMENT4',glc.segment4,
				'SEGMENT5',glc.segment5,'SEGMENT6',glc.segment6,
				'SEGMENT7',glc.segment7,'SEGMENT8',glc.segment8,
				'SEGMENT9',glc.segment9,'SEGMENT10',glc.segment10,
				'SEGMENT11',glc.segment11,'SEGMENT12',glc.segment12,
				'SEGMENT13',glc.segment13,'SEGMENT14',glc.segment14,
				'SEGMENT15',glc.segment15,'SEGMENT16',glc.segment16,
				'SEGMENT17',glc.segment17,'SEGMENT18',glc.segment18,
				'SEGMENT19',glc.segment19,'SEGMENT20',glc.segment20,
				'SEGMENT21',glc.segment21,'SEGMENT22',glc.segment22,
				'SEGMENT23',glc.segment23,'SEGMENT24',glc.segment24,
				'SEGMENT25',glc.segment25,'SEGMENT26',glc.segment26,
				'SEGMENT27',glc.segment27,'SEGMENT28',glc.segment28,
				'SEGMENT29',glc.segment29,'SEGMENT30',glc.segment30),
		   decode(v_pagebreak_seg2,'SEGMENT1',glc.segment1,'SEGMENT2',glc.segment2,
				'SEGMENT3',glc.segment3,'SEGMENT4',glc.segment4,
				'SEGMENT5',glc.segment5,'SEGMENT6',glc.segment6,
				'SEGMENT7',glc.segment7,'SEGMENT8',glc.segment8,
				'SEGMENT9',glc.segment9,'SEGMENT10',glc.segment10,
				'SEGMENT11',glc.segment11,'SEGMENT12',glc.segment12,
				'SEGMENT13',glc.segment13,'SEGMENT14',glc.segment14,
				'SEGMENT15',glc.segment15,'SEGMENT16',glc.segment16,
				'SEGMENT17',glc.segment17,'SEGMENT18',glc.segment18,
				'SEGMENT19',glc.segment19,'SEGMENT20',glc.segment20,
				'SEGMENT21',glc.segment21,'SEGMENT22',glc.segment22,
				'SEGMENT23',glc.segment23,'SEGMENT24',glc.segment24,
				'SEGMENT25',glc.segment25,'SEGMENT26',glc.segment26,
				'SEGMENT27',glc.segment27,'SEGMENT28',glc.segment28,
				'SEGMENT29',glc.segment29,'SEGMENT30',glc.segment30),
		    decode(v_pagebreak_seg3,'SEGMENT1',glc.segment1,'SEGMENT2',glc.segment2,
				'SEGMENT3',glc.segment3,'SEGMENT4',glc.segment4,
				'SEGMENT5',glc.segment5,'SEGMENT6',glc.segment6,
				'SEGMENT7',glc.segment7,'SEGMENT8',glc.segment8,
				'SEGMENT9',glc.segment9,'SEGMENT10',glc.segment10,
				'SEGMENT11',glc.segment11,'SEGMENT12',glc.segment12,
				'SEGMENT13',glc.segment13,'SEGMENT14',glc.segment14,
				'SEGMENT15',glc.segment15,'SEGMENT16',glc.segment16,
				'SEGMENT17',glc.segment17,'SEGMENT18',glc.segment18,
				'SEGMENT19',glc.segment19,'SEGMENT20',glc.segment20,
				'SEGMENT21',glc.segment21,'SEGMENT22',glc.segment22,
				'SEGMENT23',glc.segment23,'SEGMENT24',glc.segment24,
				'SEGMENT25',glc.segment25,'SEGMENT26',glc.segment26,
				'SEGMENT27',glc.segment27,'SEGMENT28',glc.segment28,
				'SEGMENT29',glc.segment29,'SEGMENT30',glc.segment30) ;


CURSOR c_packets_spending IS
   SELECT sum(nvl(accounted_dr,0) - nvl(accounted_cr,0)) pac_spend,
		decode(v_pagebreak_seg1,'SEGMENT1',glc.segment1,'SEGMENT2',glc.segment2,
				'SEGMENT3',glc.segment3,'SEGMENT4',glc.segment4,
				'SEGMENT5',glc.segment5,'SEGMENT6',glc.segment6,
				'SEGMENT7',glc.segment7,'SEGMENT8',glc.segment8,
				'SEGMENT9',glc.segment9,'SEGMENT10',glc.segment10,
				'SEGMENT11',glc.segment11,'SEGMENT12',glc.segment12,
				'SEGMENT13',glc.segment13,'SEGMENT14',glc.segment14,
				'SEGMENT15',glc.segment15,'SEGMENT16',glc.segment16,
				'SEGMENT17',glc.segment17,'SEGMENT18',glc.segment18,
				'SEGMENT19',glc.segment19,'SEGMENT20',glc.segment20,
				'SEGMENT21',glc.segment21,'SEGMENT22',glc.segment22,
				'SEGMENT23',glc.segment23,'SEGMENT24',glc.segment24,
				'SEGMENT25',glc.segment25,'SEGMENT26',glc.segment26,
				'SEGMENT27',glc.segment27,'SEGMENT28',glc.segment28,
				'SEGMENT29',glc.segment29,'SEGMENT30',glc.segment30) pg1,
		decode(v_pagebreak_seg2,'SEGMENT1',glc.segment1,'SEGMENT2',glc.segment2,
				'SEGMENT3',glc.segment3,'SEGMENT4',glc.segment4,
				'SEGMENT5',glc.segment5,'SEGMENT6',glc.segment6,
				'SEGMENT7',glc.segment7,'SEGMENT8',glc.segment8,
				'SEGMENT9',glc.segment9,'SEGMENT10',glc.segment10,
				'SEGMENT11',glc.segment11,'SEGMENT12',glc.segment12,
				'SEGMENT13',glc.segment13,'SEGMENT14',glc.segment14,
				'SEGMENT15',glc.segment15,'SEGMENT16',glc.segment16,
				'SEGMENT17',glc.segment17,'SEGMENT18',glc.segment18,
				'SEGMENT19',glc.segment19,'SEGMENT20',glc.segment20,
				'SEGMENT21',glc.segment21,'SEGMENT22',glc.segment22,
				'SEGMENT23',glc.segment23,'SEGMENT24',glc.segment24,
				'SEGMENT25',glc.segment25,'SEGMENT26',glc.segment26,
				'SEGMENT27',glc.segment27,'SEGMENT28',glc.segment28,
				'SEGMENT29',glc.segment29,'SEGMENT30',glc.segment30) pg2,
		decode(v_pagebreak_seg3,'SEGMENT1',glc.segment1,'SEGMENT2',glc.segment2,
				'SEGMENT3',glc.segment3,'SEGMENT4',glc.segment4,
				'SEGMENT5',glc.segment5,'SEGMENT6',glc.segment6,
				'SEGMENT7',glc.segment7,'SEGMENT8',glc.segment8,
				'SEGMENT9',glc.segment9,'SEGMENT10',glc.segment10,
				'SEGMENT11',glc.segment11,'SEGMENT12',glc.segment12,
				'SEGMENT13',glc.segment13,'SEGMENT14',glc.segment14,
				'SEGMENT15',glc.segment15,'SEGMENT16',glc.segment16,
				'SEGMENT17',glc.segment17,'SEGMENT18',glc.segment18,
				'SEGMENT19',glc.segment19,'SEGMENT20',glc.segment20,
				'SEGMENT21',glc.segment21,'SEGMENT22',glc.segment22,
				'SEGMENT23',glc.segment23,'SEGMENT24',glc.segment24,
				'SEGMENT25',glc.segment25,'SEGMENT26',glc.segment26,
				'SEGMENT27',glc.segment27,'SEGMENT28',glc.segment28,
				'SEGMENT29',glc.segment29,'SEGMENT30',glc.segment30) pg3
   FROM 	gl_bc_packets pac,
      	gl_code_combinations glc
   WHERE pac.code_combination_id = glc.code_combination_id
   AND	 glc.chart_of_accounts_id = v_ca_id
   AND      pac.ledger_id           = sob_id
   AND      pac.currency_code       = curr_code
   AND      pac.actual_flag         = 'A'
   AND      pac.status_code         in ('A','P')
   AND      glc.enabled_flag        = 'Y'
   AND      glc.template_id  IS NULL
   AND      substr(period_year,3,2) = substr(pd_name,8,2)
   AND      period_num between 1 and x_period_num
   AND      decode(bal_seg_name,'SEGMENT1',glc.segment1,'SEGMENT2',glc.segment2,
				'SEGMENT3',glc.segment3,'SEGMENT4',glc.segment4,
				'SEGMENT5',glc.segment5,'SEGMENT6',glc.segment6,
				'SEGMENT7',glc.segment7,'SEGMENT8',glc.segment8,
				'SEGMENT9',glc.segment9,'SEGMENT10',glc.segment10,
				'SEGMENT11',glc.segment11,'SEGMENT12',glc.segment12,
				'SEGMENT13',glc.segment13,'SEGMENT14',glc.segment14,
				'SEGMENT15',glc.segment15,'SEGMENT16',glc.segment16,
				'SEGMENT17',glc.segment17,'SEGMENT18',glc.segment18,
				'SEGMENT19',glc.segment19,'SEGMENT20',glc.segment20,
				'SEGMENT21',glc.segment21,'SEGMENT22',glc.segment22,
				'SEGMENT23',glc.segment23,'SEGMENT24',glc.segment24,
				'SEGMENT25',glc.segment25,'SEGMENT26',glc.segment26,
				'SEGMENT27',glc.segment27,'SEGMENT28',glc.segment28,
				'SEGMENT29',glc.segment29,'SEGMENT30',glc.segment30) = v_fund_value
   AND 	decode(acct_seg_name,'SEGMENT1',glc.segment1,'SEGMENT2',glc.segment2,
				'SEGMENT3',glc.segment3,'SEGMENT4',glc.segment4,
				'SEGMENT5',glc.segment5,'SEGMENT6',glc.segment6,
				'SEGMENT7',glc.segment7,'SEGMENT8',glc.segment8,
				'SEGMENT9',glc.segment9,'SEGMENT10',glc.segment10,
				'SEGMENT11',glc.segment11,'SEGMENT12',glc.segment12,
				'SEGMENT13',glc.segment13,'SEGMENT14',glc.segment14,
				'SEGMENT15',glc.segment15,'SEGMENT16',glc.segment16,
				'SEGMENT17',glc.segment17,'SEGMENT18',glc.segment18,
				'SEGMENT19',glc.segment19,'SEGMENT20',glc.segment20,
				'SEGMENT21',glc.segment21,'SEGMENT22',glc.segment22,
				'SEGMENT23',glc.segment23,'SEGMENT24',glc.segment24,
				'SEGMENT25',glc.segment25,'SEGMENT26',glc.segment26,
				'SEGMENT27',glc.segment27,'SEGMENT28',glc.segment28,
				'SEGMENT29',glc.segment29,'SEGMENT30',glc.segment30)
				between v_value_low and v_value_high
   group by decode(v_pagebreak_seg1,'SEGMENT1',glc.segment1,'SEGMENT2',glc.segment2,
				'SEGMENT3',glc.segment3,'SEGMENT4',glc.segment4,
				'SEGMENT5',glc.segment5,'SEGMENT6',glc.segment6,
				'SEGMENT7',glc.segment7,'SEGMENT8',glc.segment8,
				'SEGMENT9',glc.segment9,'SEGMENT10',glc.segment10,
				'SEGMENT11',glc.segment11,'SEGMENT12',glc.segment12,
				'SEGMENT13',glc.segment13,'SEGMENT14',glc.segment14,
				'SEGMENT15',glc.segment15,'SEGMENT16',glc.segment16,
				'SEGMENT17',glc.segment17,'SEGMENT18',glc.segment18,
				'SEGMENT19',glc.segment19,'SEGMENT20',glc.segment20,
				'SEGMENT21',glc.segment21,'SEGMENT22',glc.segment22,
				'SEGMENT23',glc.segment23,'SEGMENT24',glc.segment24,
				'SEGMENT25',glc.segment25,'SEGMENT26',glc.segment26,
				'SEGMENT27',glc.segment27,'SEGMENT28',glc.segment28,
				'SEGMENT29',glc.segment29,'SEGMENT30',glc.segment30),
		   decode(v_pagebreak_seg2,'SEGMENT1',glc.segment1,'SEGMENT2',glc.segment2,
				'SEGMENT3',glc.segment3,'SEGMENT4',glc.segment4,
				'SEGMENT5',glc.segment5,'SEGMENT6',glc.segment6,
				'SEGMENT7',glc.segment7,'SEGMENT8',glc.segment8,
				'SEGMENT9',glc.segment9,'SEGMENT10',glc.segment10,
				'SEGMENT11',glc.segment11,'SEGMENT12',glc.segment12,
				'SEGMENT13',glc.segment13,'SEGMENT14',glc.segment14,
				'SEGMENT15',glc.segment15,'SEGMENT16',glc.segment16,
				'SEGMENT17',glc.segment17,'SEGMENT18',glc.segment18,
				'SEGMENT19',glc.segment19,'SEGMENT20',glc.segment20,
				'SEGMENT21',glc.segment21,'SEGMENT22',glc.segment22,
				'SEGMENT23',glc.segment23,'SEGMENT24',glc.segment24,
				'SEGMENT25',glc.segment25,'SEGMENT26',glc.segment26,
				'SEGMENT27',glc.segment27,'SEGMENT28',glc.segment28,
				'SEGMENT29',glc.segment29,'SEGMENT30',glc.segment30),
		    decode(v_pagebreak_seg3,'SEGMENT1',glc.segment1,'SEGMENT2',glc.segment2,
				'SEGMENT3',glc.segment3,'SEGMENT4',glc.segment4,
				'SEGMENT5',glc.segment5,'SEGMENT6',glc.segment6,
				'SEGMENT7',glc.segment7,'SEGMENT8',glc.segment8,
				'SEGMENT9',glc.segment9,'SEGMENT10',glc.segment10,
				'SEGMENT11',glc.segment11,'SEGMENT12',glc.segment12,
				'SEGMENT13',glc.segment13,'SEGMENT14',glc.segment14,
				'SEGMENT15',glc.segment15,'SEGMENT16',glc.segment16,
				'SEGMENT17',glc.segment17,'SEGMENT18',glc.segment18,
				'SEGMENT19',glc.segment19,'SEGMENT20',glc.segment20,
				'SEGMENT21',glc.segment21,'SEGMENT22',glc.segment22,
				'SEGMENT23',glc.segment23,'SEGMENT24',glc.segment24,
				'SEGMENT25',glc.segment25,'SEGMENT26',glc.segment26,
				'SEGMENT27',glc.segment27,'SEGMENT28',glc.segment28,
				'SEGMENT29',glc.segment29,'SEGMENT30',glc.segment30) ;



CURSOR c_packets_budget IS
   SELECT	sum(nvl(accounted_dr,0) - nvl(accounted_cr,0)) pac_bud,
		decode(v_pagebreak_seg1,'SEGMENT1',glc.segment1,'SEGMENT2',glc.segment2,
				'SEGMENT3',glc.segment3,'SEGMENT4',glc.segment4,
				'SEGMENT5',glc.segment5,'SEGMENT6',glc.segment6,
				'SEGMENT7',glc.segment7,'SEGMENT8',glc.segment8,
				'SEGMENT9',glc.segment9,'SEGMENT10',glc.segment10,
				'SEGMENT11',glc.segment11,'SEGMENT12',glc.segment12,
				'SEGMENT13',glc.segment13,'SEGMENT14',glc.segment14,
				'SEGMENT15',glc.segment15,'SEGMENT16',glc.segment16,
				'SEGMENT17',glc.segment17,'SEGMENT18',glc.segment18,
				'SEGMENT19',glc.segment19,'SEGMENT20',glc.segment20,
				'SEGMENT21',glc.segment21,'SEGMENT22',glc.segment22,
				'SEGMENT23',glc.segment23,'SEGMENT24',glc.segment24,
				'SEGMENT25',glc.segment25,'SEGMENT26',glc.segment26,
				'SEGMENT27',glc.segment27,'SEGMENT28',glc.segment28,
				'SEGMENT29',glc.segment29,'SEGMENT30',glc.segment30) pg1,
		decode(v_pagebreak_seg2,'SEGMENT1',glc.segment1,'SEGMENT2',glc.segment2,
				'SEGMENT3',glc.segment3,'SEGMENT4',glc.segment4,
				'SEGMENT5',glc.segment5,'SEGMENT6',glc.segment6,
				'SEGMENT7',glc.segment7,'SEGMENT8',glc.segment8,
				'SEGMENT9',glc.segment9,'SEGMENT10',glc.segment10,
				'SEGMENT11',glc.segment11,'SEGMENT12',glc.segment12,
				'SEGMENT13',glc.segment13,'SEGMENT14',glc.segment14,
				'SEGMENT15',glc.segment15,'SEGMENT16',glc.segment16,
				'SEGMENT17',glc.segment17,'SEGMENT18',glc.segment18,
				'SEGMENT19',glc.segment19,'SEGMENT20',glc.segment20,
				'SEGMENT21',glc.segment21,'SEGMENT22',glc.segment22,
				'SEGMENT23',glc.segment23,'SEGMENT24',glc.segment24,
				'SEGMENT25',glc.segment25,'SEGMENT26',glc.segment26,
				'SEGMENT27',glc.segment27,'SEGMENT28',glc.segment28,
				'SEGMENT29',glc.segment29,'SEGMENT30',glc.segment30) pg2,
		decode(v_pagebreak_seg3,'SEGMENT1',glc.segment1,'SEGMENT2',glc.segment2,
				'SEGMENT3',glc.segment3,'SEGMENT4',glc.segment4,
				'SEGMENT5',glc.segment5,'SEGMENT6',glc.segment6,
				'SEGMENT7',glc.segment7,'SEGMENT8',glc.segment8,
				'SEGMENT9',glc.segment9,'SEGMENT10',glc.segment10,
				'SEGMENT11',glc.segment11,'SEGMENT12',glc.segment12,
				'SEGMENT13',glc.segment13,'SEGMENT14',glc.segment14,
				'SEGMENT15',glc.segment15,'SEGMENT16',glc.segment16,
				'SEGMENT17',glc.segment17,'SEGMENT18',glc.segment18,
				'SEGMENT19',glc.segment19,'SEGMENT20',glc.segment20,
				'SEGMENT21',glc.segment21,'SEGMENT22',glc.segment22,
				'SEGMENT23',glc.segment23,'SEGMENT24',glc.segment24,
				'SEGMENT25',glc.segment25,'SEGMENT26',glc.segment26,
				'SEGMENT27',glc.segment27,'SEGMENT28',glc.segment28,
				'SEGMENT29',glc.segment29,'SEGMENT30',glc.segment30) pg3
   FROM	gl_bc_packets pac,
      	gl_code_combinations glc
   WHERE pac.code_combination_id = glc.code_combination_id
   AND      pac.ledger_id           = sob_id
   AND	    glc.chart_of_accounts_id 	 = v_ca_id
   AND      pac.currency_code       = curr_code
   AND      pac.actual_flag         = 'A'
   AND      pac.status_code         in ('A','P')
   AND      glc.enabled_flag        = 'Y'
   AND      glc.template_id  IS NULL
   AND      substr(period_year,3,2) = substr(pd_name,8,2)
   AND      period_num between 1 and x_period_num
   AND      decode(bal_seg_name,'SEGMENT1',glc.segment1,'SEGMENT2',glc.segment2,
				'SEGMENT3',glc.segment3,'SEGMENT4',glc.segment4,
				'SEGMENT5',glc.segment5,'SEGMENT6',glc.segment6,
				'SEGMENT7',glc.segment7,'SEGMENT8',glc.segment8,
				'SEGMENT9',glc.segment9,'SEGMENT10',glc.segment10,
				'SEGMENT11',glc.segment11,'SEGMENT12',glc.segment12,
				'SEGMENT13',glc.segment13,'SEGMENT14',glc.segment14,
				'SEGMENT15',glc.segment15,'SEGMENT16',glc.segment16,
				'SEGMENT17',glc.segment17,'SEGMENT18',glc.segment18,
				'SEGMENT19',glc.segment19,'SEGMENT20',glc.segment20,
				'SEGMENT21',glc.segment21,'SEGMENT22',glc.segment22,
				'SEGMENT23',glc.segment23,'SEGMENT24',glc.segment24,
				'SEGMENT25',glc.segment25,'SEGMENT26',glc.segment26,
				'SEGMENT27',glc.segment27,'SEGMENT28',glc.segment28,
				'SEGMENT29',glc.segment29,'SEGMENT30',glc.segment30) = v_fund_value
   AND 	decode(acct_seg_name,'SEGMENT1',glc.segment1,'SEGMENT2',glc.segment2,
				'SEGMENT3',glc.segment3,'SEGMENT4',glc.segment4,
				'SEGMENT5',glc.segment5,'SEGMENT6',glc.segment6,
				'SEGMENT7',glc.segment7,'SEGMENT8',glc.segment8,
				'SEGMENT9',glc.segment9,'SEGMENT10',glc.segment10,
				'SEGMENT11',glc.segment11,'SEGMENT12',glc.segment12,
				'SEGMENT13',glc.segment13,'SEGMENT14',glc.segment14,
				'SEGMENT15',glc.segment15,'SEGMENT16',glc.segment16,
				'SEGMENT17',glc.segment17,'SEGMENT18',glc.segment18,
				'SEGMENT19',glc.segment19,'SEGMENT20',glc.segment20,
				'SEGMENT21',glc.segment21,'SEGMENT22',glc.segment22,
				'SEGMENT23',glc.segment23,'SEGMENT24',glc.segment24,
				'SEGMENT25',glc.segment25,'SEGMENT26',glc.segment26,
				'SEGMENT27',glc.segment27,'SEGMENT28',glc.segment28,
				'SEGMENT29',glc.segment29,'SEGMENT30',glc.segment30)
				between v_value_low and v_value_high
    group by decode(v_pagebreak_seg1,'SEGMENT1',glc.segment1,'SEGMENT2',glc.segment2,
				'SEGMENT3',glc.segment3,'SEGMENT4',glc.segment4,
				'SEGMENT5',glc.segment5,'SEGMENT6',glc.segment6,
				'SEGMENT7',glc.segment7,'SEGMENT8',glc.segment8,
				'SEGMENT9',glc.segment9,'SEGMENT10',glc.segment10,
				'SEGMENT11',glc.segment11,'SEGMENT12',glc.segment12,
				'SEGMENT13',glc.segment13,'SEGMENT14',glc.segment14,
				'SEGMENT15',glc.segment15,'SEGMENT16',glc.segment16,
				'SEGMENT17',glc.segment17,'SEGMENT18',glc.segment18,
				'SEGMENT19',glc.segment19,'SEGMENT20',glc.segment20,
				'SEGMENT21',glc.segment21,'SEGMENT22',glc.segment22,
				'SEGMENT23',glc.segment23,'SEGMENT24',glc.segment24,
				'SEGMENT25',glc.segment25,'SEGMENT26',glc.segment26,
				'SEGMENT27',glc.segment27,'SEGMENT28',glc.segment28,
				'SEGMENT29',glc.segment29,'SEGMENT30',glc.segment30),
		   decode(v_pagebreak_seg2,'SEGMENT1',glc.segment1,'SEGMENT2',glc.segment2,
				'SEGMENT3',glc.segment3,'SEGMENT4',glc.segment4,
				'SEGMENT5',glc.segment5,'SEGMENT6',glc.segment6,
				'SEGMENT7',glc.segment7,'SEGMENT8',glc.segment8,
				'SEGMENT9',glc.segment9,'SEGMENT10',glc.segment10,
				'SEGMENT11',glc.segment11,'SEGMENT12',glc.segment12,
				'SEGMENT13',glc.segment13,'SEGMENT14',glc.segment14,
				'SEGMENT15',glc.segment15,'SEGMENT16',glc.segment16,
				'SEGMENT17',glc.segment17,'SEGMENT18',glc.segment18,
				'SEGMENT19',glc.segment19,'SEGMENT20',glc.segment20,
				'SEGMENT21',glc.segment21,'SEGMENT22',glc.segment22,
				'SEGMENT23',glc.segment23,'SEGMENT24',glc.segment24,
				'SEGMENT25',glc.segment25,'SEGMENT26',glc.segment26,
				'SEGMENT27',glc.segment27,'SEGMENT28',glc.segment28,
				'SEGMENT29',glc.segment29,'SEGMENT30',glc.segment30),
		    decode(v_pagebreak_seg3,'SEGMENT1',glc.segment1,'SEGMENT2',glc.segment2,
				'SEGMENT3',glc.segment3,'SEGMENT4',glc.segment4,
				'SEGMENT5',glc.segment5,'SEGMENT6',glc.segment6,
				'SEGMENT7',glc.segment7,'SEGMENT8',glc.segment8,
				'SEGMENT9',glc.segment9,'SEGMENT10',glc.segment10,
				'SEGMENT11',glc.segment11,'SEGMENT12',glc.segment12,
				'SEGMENT13',glc.segment13,'SEGMENT14',glc.segment14,
				'SEGMENT15',glc.segment15,'SEGMENT16',glc.segment16,
				'SEGMENT17',glc.segment17,'SEGMENT18',glc.segment18,
				'SEGMENT19',glc.segment19,'SEGMENT20',glc.segment20,
				'SEGMENT21',glc.segment21,'SEGMENT22',glc.segment22,
				'SEGMENT23',glc.segment23,'SEGMENT24',glc.segment24,
				'SEGMENT25',glc.segment25,'SEGMENT26',glc.segment26,
				'SEGMENT27',glc.segment27,'SEGMENT28',glc.segment28,
				'SEGMENT29',glc.segment29,'SEGMENT30',glc.segment30) ;

/* Changed treasury_symbol to Treasury_symbol_id #bug 1575992
   Bug 1575992 Modified the decode statement
   Added treasury_symbol_id for Bug 1829771 */
CURSOR c_treasury_fund_values IS
   SELECT 	fp.fund_value,
		fp.budget_authority,
		fp.transfers_in,
		fp.transfers_out,
		fp.unliquid_commitments,
		fp.unliquid_obligations,
		fp.expended_amount ,
		fp.treasury_symbol_id
   FROM   fv_fund_parameters fp
   WHERE  fp.set_of_books_id = sob_id
   AND    decode(rollup_type,'T',to_char(fp.treasury_symbol_id),'F',fp.fund_value)
     		between decode(rollup_type,'T',nvl(temp_v_treasury_symbol_id,fp.treasury_symbol_id),
          	'F',nvl(acct_ff_low,fp.fund_value) )
     		and decode(rollup_type,'T',nvl(temp_v_treasury_symbol_id,fp.treasury_symbol_id),
          	'F',nvl(acct_ff_high,fp.fund_value) );


CURSOR c_get_temptable_info IS
    SELECT pagebk1,pagebk2,pagebk3,sum(acct_total) atot
    FROM fv_status_funds_temp
    GROUP BY pagebk1,pagebk2,pagebk3;

/******************************************************************/
/* This procedures sums the budget authority                      */
/******************************************************************/
PROCEDURE sum_children_budget
 (v_parent_value    IN fnd_flex_values.flex_value%TYPE,
  parent_value_id   IN fnd_flex_values.flex_value_id%TYPE,
  sob_id1		  IN gl_balances.ledger_id%TYPE,
  v_treasury_symbol1 IN fv_fund_parameters.treasury_symbol%TYPE,
  v_fund_value1	   IN fv_fund_parameters.fund_value%TYPE,
  v_treasury_symbol_id1 IN fv_treasury_symbols.treasury_symbol_id%TYPE ) --Changed to Fix 1575992
Is
 CURSOR c_parent_value_budget  IS
   	SELECT child_flex_value_low, child_flex_value_high
     	FROM fnd_flex_value_hierarchies
    	WHERE parent_flex_value = v_parent_value
      AND flex_value_set_id = parent_value_id;
 l_module_name varchar2(200)  := g_module_name || 'sum_children_budget';
 l_errbuf varchar2(300);
BEGIN
 parent_flag       := 'N';

 begin
   select substr(compiled_value_attributes,5,1)
   into v_sign
   from fnd_flex_values
   where flex_value = v_parent_value
   and flex_value_set_id = parent_value_id;

   EXCEPTION
     WHEN NO_DATA_FOUND THEN
      null;


 end;


 DELETE FROM fv_status_funds_temp;
 COMMIT;

 OPEN  c_parent_value_budget;
 LOOP
  FETCH c_parent_value_budget into v_value_low, v_value_high;

  IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'V_PARENT_VALUE FOR BUDGET'||V_PARENT_VALUE);
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'V_VALUE_LOW FOR BUDGET'||V_VALUE_LOW);
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'V_VALUE_HIGH FOR BUDGET'||V_VALUE_HIGH);
  END IF;

  IF c_parent_value_budget%FOUND THEN
	FOR c_balances_budget_rec IN c_balances_budget LOOP

  IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'V_PARENT_VALUE FOR BUDGET'||V_PARENT_VALUE);
  END IF;
		INSERT INTO fv_status_funds_temp
			(pagebk1,pagebk2,pagebk3,acct_total) VALUES
			(c_balances_budget_rec.pg1,c_balances_budget_rec.pg2,
			 c_balances_budget_rec.pg3,
                         c_balances_budget_rec.bal_bud);
	END LOOP;
	FOR c_packets_budget_rec IN c_packets_budget LOOP
		INSERT INTO fv_status_funds_temp
			(pagebk1,pagebk2,pagebk3,acct_total) VALUES
			(c_packets_budget_rec.pg1,c_packets_budget_rec.pg2,
			 c_packets_budget_rec.pg3,c_packets_budget_rec.pac_bud);
	END LOOP;
    parent_flag := 'Y';
  ELSE
    -- no child record found

    IF parent_flag = 'N' THEN
       -- since there are no children assign account to high and low
       v_value_low  := v_parent_value;
       v_value_high := v_parent_value;
       IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'IN THE LOOP WHERE NO CHILD FOUND');
       END IF;

      FOR c_balances_budget_rec IN c_balances_budget LOOP
		INSERT INTO fv_status_funds_temp
			(pagebk1,pagebk2,pagebk3,acct_total) VALUES
			(c_balances_budget_rec.pg1,c_balances_budget_rec.pg2,
			 c_balances_budget_rec.pg3,c_balances_budget_rec.bal_bud);
	IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'C_BAL_BUD_REC.PG1 :'||C_BALANCES_BUDGET_REC.PG1);
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'C_BAL_BUD_REC.PG2 :'||C_BALANCES_BUDGET_REC.PG2);
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'C_BAL_BUD_REC.PG3 :'||C_BALANCES_BUDGET_REC.PG3);
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'C_BAL_BUD_REC.BAL_BUD :'||C_BALANCES_BUDGET_REC.BAL_BUD);
	END IF;
	END LOOP;
	FOR c_packets_budget_rec IN c_packets_budget LOOP
		INSERT INTO fv_status_funds_temp
			(pagebk1,pagebk2,pagebk3,acct_total) VALUES
			(c_packets_budget_rec.pg1,c_packets_budget_rec.pg2,
			 c_packets_budget_rec.pg3,c_packets_budget_rec.pac_bud);
	IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'C_PACKATS.PG1 :'||C_PACKETS_BUDGET_REC.PG1);
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'C_PACKATES.PG2 :'||C_PACKETS_BUDGET_REC.PG2);
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'C_PACKETS.PG3 :'||C_PACKETS_BUDGET_REC.PG3);
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'C_PACKETS.PAC_BUD :'||C_PACKETS_BUDGET_REC.PAC_BUD);
	END IF;
	END LOOP;
	FOR c_get_temptable_info_rec IN c_get_temptable_info LOOP

	-- modified to Fix Bug.1575992
		INSERT INTO fv_status_funds_final
		  (set_of_books_id,treasury_symbol,fund,pagebreak_seg1,
		   pagebreak_seg2,pagebreak_seg3,
		   treasury_symbol_id,
		   budget_auth_total)
		VALUES (sob_id1,v_treasury_symbol1,v_fund_value1,
			  c_get_temptable_info_rec.pagebk1,
			  c_get_temptable_info_rec.pagebk2,
			  c_get_temptable_info_rec.pagebk3,
			  v_treasury_symbol_id1,
		          decode(v_sign,'C',(c_get_temptable_info_rec.atot*-1),c_get_temptable_info_rec.atot));

      IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'C_GET_TEMPTABLE_INFO_REC.PAGEBK1 :'||C_GET_TEMPTABLE_INFO_REC.PAGEBK1);
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'C_GET_TEMPTABLE_INFO_REC.PAGEBK2 :'||C_GET_TEMPTABLE_INFO_REC.PAGEBK2);
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'C_GET_TEMPTABLE_INFO_REC.PAGEBK3 :'||C_GET_TEMPTABLE_INFO_REC.PAGEBK3);
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'C_GET_TEMPTABLE_INFO_REC.ATOT :'||C_GET_TEMPTABLE_INFO_REC.ATOT);
      END IF;
	END LOOP;
    END IF;
    exit;
  END IF;
END LOOP;

CLOSE c_parent_value_budget;
IF parent_flag = 'Y' then
	FOR c_get_temptable_info_rec IN c_get_temptable_info LOOP

	--Modified to Fix bug.1575992
		INSERT INTO fv_status_funds_final
		  (set_of_books_id,treasury_symbol,treasury_symbol_id,fund,pagebreak_seg1,
		  pagebreak_seg2,pagebreak_seg3,budget_auth_total)
		VALUES (sob_id1,v_treasury_symbol1,v_treasury_symbol_id1,v_fund_value1,
			  c_get_temptable_info_rec.pagebk1,
			  c_get_temptable_info_rec.pagebk2,
			  c_get_temptable_info_rec.pagebk3,
		          decode(v_sign,'C',(c_get_temptable_info_rec.atot*-1),c_get_temptable_info_rec.atot));
	END LOOP;
END IF;
EXCEPTION
WHEN OTHERS THEN
    l_errbuf := SQLERRM;
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED,l_module_name||'.final_exception',l_errbuf);
    raise;
END sum_children_budget;


/******************************************************************/
/* This procedures sums the transfers accounts for the account    */
/* passed to it.				                  */
/******************************************************************/
PROCEDURE sum_children_transfers
 (v_parent_value    IN fnd_flex_values.flex_value%TYPE,
  parent_value_id   IN fnd_flex_values.flex_value_id%TYPE,
  v_trans_type	  IN VARCHAR2,
  sob_id1		  IN gl_balances.ledger_id%TYPE,
  v_treasury_symbol1 IN fv_fund_parameters.treasury_symbol%TYPE,
  v_fund_value1	   IN fv_fund_parameters.fund_value%TYPE,
  v_treasury_symbol_id1 IN fv_treasury_symbols.treasury_symbol_id%TYPE )--Added to fix bug.1575992

IS
  CURSOR c_parent_value_transfers  IS
   SELECT child_flex_value_low, child_flex_value_high
     FROM fnd_flex_value_hierarchies
    WHERE parent_flex_value = v_parent_value
      AND flex_value_set_id = parent_value_id;
  l_module_name varchar2(200) := g_module_name || 'sum_children_transfers';
  l_errbuf varchar2(300);

BEGIN
 parent_flag       := 'N';

 begin
   select substr(compiled_value_attributes,5,1)
   into v_sign
   from fnd_flex_values
   where flex_value = v_parent_value
   and flex_value_set_id = parent_value_id;

   EXCEPTION
     WHEN NO_DATA_FOUND THEN
      null;
 end;

 DELETE FROM fv_status_funds_temp;
 COMMIT;

 OPEN  c_parent_value_transfers;
 LOOP
  FETCH c_parent_value_transfers into v_value_low, v_value_high ;

  IF c_parent_value_transfers%FOUND THEN
    	FOR c_balances_transfers_rec IN c_balances_transfers LOOP
		INSERT INTO fv_status_funds_temp
		  (pagebk1,pagebk2,pagebk3,acct_total) VALUES
		  (c_balances_transfers_rec.pg1,c_balances_transfers_rec.pg2,
		  c_balances_transfers_rec.pg3,c_balances_transfers_rec.bal_trans);
	END LOOP;
	FOR c_packets_spending_rec IN c_packets_spending LOOP
		INSERT INTO fv_status_funds_temp
		  (pagebk1,pagebk2,pagebk3,acct_total) VALUES
		  (c_packets_spending_rec.pg1,c_packets_spending_rec.pg2,
		  c_packets_spending_rec.pg3,c_packets_spending_rec.pac_spend);
	END LOOP;

    parent_flag := 'Y';
  ELSE
    -- no child record found

    IF parent_flag = 'N' THEN
       -- since there are no children assign account to high and low
    	 v_value_low := v_parent_value;
       v_value_high:= v_parent_value;

	FOR c_balances_transfers_rec IN c_balances_transfers LOOP
		INSERT INTO fv_status_funds_temp
		  (pagebk1,pagebk2,pagebk3,acct_total) VALUES
		  (c_balances_transfers_rec.pg1,c_balances_transfers_rec.pg2,
		  c_balances_transfers_rec.pg3,c_balances_transfers_rec.bal_trans);
	IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'C_BAL_TRANS_REC.PG1 :'||C_BALANCES_TRANSFERS_REC.PG1);
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'C_BAL_TRANS_REC.PG2 :'||C_BALANCES_TRANSFERS_REC.PG2);
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'C_BAL_TRANS_REC.PG3 :'||C_BALANCES_TRANSFERS_REC.PG3);
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'C_BAL_TRANS_REC.BAL_TRANS :'||C_BALANCES_TRANSFERS_REC.BAL_TRANS);
	END IF;
	END LOOP;
	FOR c_packets_spending_rec IN c_packets_spending LOOP
		INSERT INTO fv_status_funds_temp
		  (pagebk1,pagebk2,pagebk3,acct_total) VALUES
		  (c_packets_spending_rec.pg1,c_packets_spending_rec.pg2,
		  c_packets_spending_rec.pg3,c_packets_spending_rec.pac_spend);
	END LOOP;
	FOR c_get_temptable_info_rec IN c_get_temptable_info LOOP
	  IF v_trans_type = 'TRANS_IN' THEN
	    UPDATE fv_status_funds_final SET
	      transfers_in_total = decode(v_sign,'C',(c_get_temptable_info_rec.atot*-1),c_get_temptable_info_rec.atot)
		WHERE pagebreak_seg1 = c_get_temptable_info_rec.pagebk1
		AND   set_of_books_id = sob_id1
		AND	pagebreak_seg2 = c_get_temptable_info_rec.pagebk2
		AND	pagebreak_seg3 = c_get_temptable_info_rec.pagebk3
		AND	fund = v_fund_value1;

      IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'TRANS_IN:C_GET_TEMPTABLE_INFO_REC.ATOT :'||C_GET_TEMPTABLE_INFO_REC.ATOT);
      END IF;

	-- Modified to fix Bug.1575992
			IF SQL%ROWCOUNT = 0 THEN
			  INSERT INTO fv_status_funds_final
			    (set_of_books_id,treasury_symbol,treasury_symbol_id,fund,pagebreak_seg1,
			    pagebreak_seg2,pagebreak_seg3,transfers_in_total)
			  VALUES (sob_id1,v_treasury_symbol1,v_treasury_symbol_id1,v_fund_value1,
                      c_get_temptable_info_rec.pagebk1,
			    c_get_temptable_info_rec.pagebk2,
			    c_get_temptable_info_rec.pagebk3,
			    decode(v_sign,'C',(c_get_temptable_info_rec.atot*-1),c_get_temptable_info_rec.atot));

      IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'TRANS_IN_2:C_GET_TEMPTABLE_INFO_REC.ATOT :'||C_GET_TEMPTABLE_INFO_REC.ATOT);
      END IF;
			END IF;
		ELSIF v_trans_type = 'TRANS_OUT' THEN
			UPDATE fv_status_funds_final SET
			  transfers_out_total =decode(v_sign,'C',(c_get_temptable_info_rec.atot*-1),c_get_temptable_info_rec.atot)
			WHERE pagebreak_seg1 = c_get_temptable_info_rec.pagebk1
			AND   set_of_books_id = sob_id1
			AND   pagebreak_seg2 = c_get_temptable_info_rec.pagebk2
			AND   pagebreak_seg3 = c_get_temptable_info_rec.pagebk3
			AND	fund = v_fund_value1;

			IF SQL%ROWCOUNT = 0 THEN
			--Modified to fix Bug.1575992
			  INSERT INTO fv_status_funds_final
			    (set_of_books_id,treasury_symbol,treasury_symbol_id,fund,pagebreak_seg1,
			    pagebreak_seg2,pagebreak_seg3,transfers_out_total)
			  VALUES (sob_id1,v_treasury_symbol1,v_treasury_symbol_id1,v_fund_value1,
                      c_get_temptable_info_rec.pagebk1,
			    c_get_temptable_info_rec.pagebk2,
			    c_get_temptable_info_rec.pagebk3,
			    decode(v_sign,'C',(c_get_temptable_info_rec.atot*-1),c_get_temptable_info_rec.atot));
			END IF;
		END IF;-- checking for trans type
	END LOOP;-- c_get_temptable_info 'for' loop
    END IF;
    exit;
  END IF;
END LOOP;

CLOSE c_parent_value_transfers;
   IF parent_flag = 'Y' THEN
	FOR c_get_temptable_info_rec IN c_get_temptable_info LOOP
		IF v_trans_type = 'TRANS_IN' THEN
			UPDATE fv_status_funds_final SET
			  transfers_in_total = decode(v_sign,'C',(c_get_temptable_info_rec.atot*-1),c_get_temptable_info_rec.atot)
			WHERE pagebreak_seg1 = c_get_temptable_info_rec.pagebk1
			AND   set_of_books_id = sob_id1
			AND   pagebreak_seg2 = c_get_temptable_info_rec.pagebk2
			AND   pagebreak_seg3 = c_get_temptable_info_rec.pagebk3
			AND   fund = v_fund_value1;

			IF SQL%ROWCOUNT = 0 THEN
		--Modified to Fix bug.1575992
			  INSERT INTO fv_status_funds_final
			    (set_of_books_id,treasury_symbol,treasury_symbol_id,fund,pagebreak_seg1,
			    pagebreak_seg2,pagebreak_seg3,transfers_in_total)
			  VALUES (sob_id1,v_treasury_symbol1,v_treasury_symbol_id1,v_fund_value1,
                      c_get_temptable_info_rec.pagebk1,
			    c_get_temptable_info_rec.pagebk2,
			    c_get_temptable_info_rec.pagebk3,
			    decode(v_sign,'C',(c_get_temptable_info_rec.atot*-1),c_get_temptable_info_rec.atot));

			END IF;
		ELSIF v_trans_type = 'TRANS_OUT' THEN
			UPDATE fv_status_funds_final SET
			  transfers_out_total = decode(v_sign,'C',(c_get_temptable_info_rec.atot*-1),c_get_temptable_info_rec.atot)
			WHERE pagebreak_seg1 = c_get_temptable_info_rec.pagebk1
			AND   pagebreak_seg2 = c_get_temptable_info_rec.pagebk2
			AND   pagebreak_seg3 = c_get_temptable_info_rec.pagebk3
			AND   set_of_books_id = sob_id1
			AND   fund = v_fund_value1;

			IF SQL%ROWCOUNT = 0 THEN
		--Modified to fix Bug.1575992
			  INSERT INTO fv_status_funds_final
			    (set_of_books_id,treasury_symbol,treasury_symbol_id,fund,pagebreak_seg1,
			    pagebreak_seg2,pagebreak_seg3,transfers_out_total)
			  VALUES (sob_id1,v_treasury_symbol1,v_treasury_symbol_id1,v_fund_value1,
                      c_get_temptable_info_rec.pagebk1,
			    c_get_temptable_info_rec.pagebk2,
			    c_get_temptable_info_rec.pagebk3,
			    decode(v_sign,'C',(c_get_temptable_info_rec.atot*-1),c_get_temptable_info_rec.atot));

			END IF;
		END IF;-- checking for trans type
	END LOOP;-- c_get_temptable_info 'for' loop
   END IF;
   EXCEPTION
   WHEN OTHERS THEN
    l_errbuf := SQLERRM;
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED,l_module_name||'.final_exception',l_errbuf);
    raise;
END sum_children_transfers;


/******************************************************************/
/* This procedure sums the spending accounts for the account      */
/* passed to it.                                                  */
/******************************************************************/
-- Modified to Fix bug.1575992
PROCEDURE sum_children_spending
 (v_parent_value    IN fnd_flex_values.flex_value%TYPE,
  parent_value_id   IN fnd_flex_values.flex_value_id%TYPE,
  v_spend_type	  IN varchar2,
  sob_id1		  IN gl_balances.ledger_id%TYPE,
  v_treasury_symbol1 IN fv_fund_parameters.treasury_symbol%TYPE,
  v_fund_value1	   IN fv_fund_parameters.fund_value%TYPE,
  v_treasury_symbol_id1 IN fv_treasury_symbols.treasury_symbol_id%TYPE )

IS
 CURSOR c_parent_value_spending  IS
   SELECT child_flex_value_low, child_flex_value_high
   FROM fnd_flex_value_hierarchies
   WHERE parent_flex_value = v_parent_value
   AND flex_value_set_id = parent_value_id;
 l_module_name varchar2(200) := g_module_name || 'sum_children_spending';
 l_errbuf varchar2(300);
BEGIN
 parent_flag  := 'N';

 DELETE FROM fv_status_funds_temp;
 COMMIT;

 OPEN  c_parent_value_spending;
 LOOP
  FETCH c_parent_value_spending into v_value_low, v_value_high;
  IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'V_VALUE_LOW '||V_VALUE_LOW);
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'V_VALUE_HIGH '||V_VALUE_HIGH);
  END IF;
  IF c_parent_value_spending%FOUND THEN
	FOR c_balances_spending_rec IN c_balances_spending LOOP
		INSERT INTO fv_status_funds_temp
		  (pagebk1,pagebk2,pagebk3,acct_total) VALUES
		  (c_balances_spending_rec.pg1,c_balances_spending_rec.pg2,
		  c_balances_spending_rec.pg3,c_balances_spending_rec.bal_spend);
	  IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'C_BAL_SPEND_REC.PG1 :'||C_BALANCES_SPENDING_REC.PG1);
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'C_BAL_SPEND_REC.PG2 :'||C_BALANCES_SPENDING_REC.PG2);
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'C_BAL_SPEND_REC.PG3 :'||C_BALANCES_SPENDING_REC.PG3);
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'C_BAL_SPEND_REC.BAL_SPEND :'||C_BALANCES_SPENDING_REC.BAL_SPEND);
	  END IF;

	END LOOP;
	FOR c_packets_spending_rec IN c_packets_spending LOOP
		INSERT INTO fv_status_funds_temp
		  (pagebk1,pagebk2,pagebk3,acct_total) VALUES
		  (c_packets_spending_rec.pg1,c_packets_spending_rec.pg2,
		  c_packets_spending_rec.pg3,c_packets_spending_rec.pac_spend);
	END LOOP;
    parent_flag := 'Y';
  ELSIF c_parent_value_spending%NOTFOUND THEN
    -- no child record found
    IF parent_flag = 'N' THEN
       -- since there are no children assign account to high and low
      v_value_low := v_parent_value;
      v_value_high := v_parent_value;

	FOR c_balances_spending_rec IN c_balances_spending LOOP
 		INSERT INTO fv_status_funds_temp
		  (pagebk1,pagebk2,pagebk3,acct_total) VALUES
		  (c_balances_spending_rec.pg1,c_balances_spending_rec.pg2,
		  c_balances_spending_rec.pg3,c_balances_spending_rec.bal_spend);
	END LOOP;
	FOR c_packets_spending_rec IN c_packets_spending LOOP
		INSERT INTO fv_status_funds_temp
		  (pagebk1,pagebk2,pagebk3,acct_total) VALUES
		  (c_packets_spending_rec.pg1,c_packets_spending_rec.pg2,
		  c_packets_spending_rec.pg3,c_packets_spending_rec.pac_spend);
	END LOOP;
	FOR c_get_temptable_info_rec IN c_get_temptable_info LOOP
		IF v_spend_type = 'UNLIQ_COMM' THEN
			UPDATE fv_status_funds_final SET
			  unliquid_comm_total = decode(v_sign,'C',nvl(c_get_temptable_info_rec.atot,0) * (-1),nvl(c_get_temptable_info_rec.atot,0))
			WHERE pagebreak_seg1 = c_get_temptable_info_rec.pagebk1
			AND   pagebreak_seg2 = c_get_temptable_info_rec.pagebk2
			AND   pagebreak_seg3 = c_get_temptable_info_rec.pagebk3
			AND   set_of_books_id = sob_id1
			AND   fund = v_fund_value1;

			IF SQL%ROWCOUNT = 0 THEN
		--Modified to Fix bug.1575992
			  INSERT INTO fv_status_funds_final
			    (set_of_books_id,treasury_symbol,treasury_symbol_id,fund,pagebreak_seg1,
                      pagebreak_seg2,pagebreak_seg3,unliquid_comm_total)
			  VALUES (sob_id1,v_treasury_symbol1,v_treasury_symbol_id1,v_fund_value1,
			    c_get_temptable_info_rec.pagebk1,
			    c_get_temptable_info_rec.pagebk2,
			    c_get_temptable_info_rec.pagebk3,
			    decode(v_sign,'C',nvl(c_get_temptable_info_rec.atot,0) * (-1),nvl(c_get_temptable_info_rec.atot,0)));
			END IF;
  	IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'C_GET_TEMP.PAGEBK1 :'||C_GET_TEMPTABLE_INFO_REC.PAGEBK1);
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'C_GET_TEMPTABLE_INFO_REC.PAGEBK2 :'||C_GET_TEMPTABLE_INFO_REC.PAGEBK2);
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'C_GET_TEMPTABLE_INFO_REC.PAGEBK3 :'||C_GET_TEMPTABLE_INFO_REC.PAGEBK3);
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'C_GET_TEMPTABLE_INFO_REC.ATOT :'||C_GET_TEMPTABLE_INFO_REC.ATOT);
  	END IF;
		ELSIF v_spend_type = 'UNLIQ_OBLIG' THEN
			UPDATE fv_status_funds_final SET
			  unliquid_oblig_total = decode(v_sign,'C',nvl(c_get_temptable_info_rec.atot,0) * (-1),nvl(c_get_temptable_info_rec.atot,0))
			WHERE pagebreak_seg1 = c_get_temptable_info_rec.pagebk1
			AND   pagebreak_seg2 = c_get_temptable_info_rec.pagebk2
			AND   pagebreak_seg3 = c_get_temptable_info_rec.pagebk3
			AND   set_of_books_id = sob_id1
			AND   fund = v_fund_value1;

			IF SQL%ROWCOUNT = 0 THEN
		--Modified to Fix bug.1575992
			  INSERT INTO fv_status_funds_final
			    (set_of_books_id,treasury_symbol,treasury_symbol_id,fund,pagebreak_seg1,
			    pagebreak_seg2,pagebreak_seg3,unliquid_oblig_total)
			  VALUES (sob_id1,v_treasury_symbol1,v_treasury_symbol_id1,v_fund_value1,
			    c_get_temptable_info_rec.pagebk1,
			    c_get_temptable_info_rec.pagebk2,
			    c_get_temptable_info_rec.pagebk3,
			    decode(v_sign,'C',nvl(c_get_temptable_info_rec.atot,0) * (-1),nvl(c_get_temptable_info_rec.atot,0)));
			END IF;
		ELSIF	v_spend_type = 'EXPEN_AMT' THEN
			UPDATE fv_status_funds_final SET
			  expen_amt_total = decode(v_sign,'C',nvl(c_get_temptable_info_rec.atot,0) * (-1),nvl(c_get_temptable_info_rec.atot,0))
			WHERE pagebreak_seg1 = c_get_temptable_info_rec.pagebk1
			AND   pagebreak_seg2 = c_get_temptable_info_rec.pagebk2
			AND   pagebreak_seg3 = c_get_temptable_info_rec.pagebk3
			AND   set_of_books_id = sob_id1
			AND   fund = v_fund_value1;

			IF SQL%ROWCOUNT = 0 THEN
		--Modified to fix Bug.1575992
			  INSERT INTO fv_status_funds_final
			    (set_of_books_id,treasury_symbol,treasury_symbol_id,fund,pagebreak_seg1,
			    pagebreak_seg2,pagebreak_seg3,expen_amt_total)
			  VALUES (sob_id1,v_treasury_symbol1,v_treasury_symbol_id1,v_fund_value1,
                      c_get_temptable_info_rec.pagebk1,
			    c_get_temptable_info_rec.pagebk2,
			    c_get_temptable_info_rec.pagebk3,
			    decode(v_sign,'C',nvl(c_get_temptable_info_rec.atot,0) * (-1),nvl(c_get_temptable_info_rec.atot,0)));
			END IF;
		END IF;-- checking for trans type
	END LOOP;-- c_get_temptable_info 'for' loop
    END IF;
    exit;
  END IF;
END LOOP;
CLOSE c_parent_value_spending;
IF parent_flag = 'Y' THEN
  FOR c_get_temptable_info_rec IN c_get_temptable_info LOOP
		IF v_spend_type = 'UNLIQ_COMM' THEN
			UPDATE fv_status_funds_final SET
			  unliquid_comm_total =  decode(v_sign,'C',nvl(c_get_temptable_info_rec.atot,0) * (-1),nvl(c_get_temptable_info_rec.atot,0))
			WHERE pagebreak_seg1 = c_get_temptable_info_rec.pagebk1
			AND   pagebreak_seg2 = c_get_temptable_info_rec.pagebk2
			AND   pagebreak_seg3 = c_get_temptable_info_rec.pagebk3
			AND   set_of_books_id = sob_id1
			AND   fund = v_fund_value1;

			IF SQL%ROWCOUNT = 0 THEN
		--Modified to fix bug.1575992
			  INSERT INTO fv_status_funds_final
			    (set_of_books_id,treasury_symbol,treasury_symbol_id,fund,pagebreak_seg1,
                      pagebreak_seg2,pagebreak_seg3,unliquid_comm_total)
			  VALUES (sob_id1,v_treasury_symbol1,v_treasury_symbol_id1,v_fund_value1,
			    c_get_temptable_info_rec.pagebk1,
			    c_get_temptable_info_rec.pagebk2,
			    c_get_temptable_info_rec.pagebk3,
			    decode(v_sign,'C',nvl(c_get_temptable_info_rec.atot,0) * (-1),nvl(c_get_temptable_info_rec.atot,0)));
			END IF;
		ELSIF v_spend_type = 'UNLIQ_OBLIG' THEN
			UPDATE fv_status_funds_final SET
			  unliquid_oblig_total =  decode(v_sign,'C',nvl(c_get_temptable_info_rec.atot,0) * (-1),nvl(c_get_temptable_info_rec.atot,0))
			WHERE pagebreak_seg1 = c_get_temptable_info_rec.pagebk1
			AND   pagebreak_seg2 = c_get_temptable_info_rec.pagebk2
			AND   pagebreak_seg3 = c_get_temptable_info_rec.pagebk3
			AND   set_of_books_id = sob_id1
			AND   fund = v_fund_value1;

			IF SQL%ROWCOUNT = 0 THEN
		--Modified to fix Bug.1575992
			  INSERT INTO fv_status_funds_final
			    (set_of_books_id,treasury_symbol,treasury_symbol_id,fund,pagebreak_seg1,
			    pagebreak_seg2,pagebreak_seg3,unliquid_oblig_total)
			  VALUES (sob_id1,v_treasury_symbol1,v_treasury_symbol_id1,v_fund_value1,
			    c_get_temptable_info_rec.pagebk1,
			    c_get_temptable_info_rec.pagebk2,
			    c_get_temptable_info_rec.pagebk3,
			    decode(v_sign,'C',nvl(c_get_temptable_info_rec.atot,0) * (-1),nvl(c_get_temptable_info_rec.atot,0)));

			END IF;
		ELSIF	v_spend_type = 'EXPEN_AMT' THEN
			UPDATE fv_status_funds_final SET
			  expen_amt_total = decode(v_sign,'C',nvl(c_get_temptable_info_rec.atot,0) * (-1),nvl(c_get_temptable_info_rec.atot,0))
			WHERE pagebreak_seg1 = c_get_temptable_info_rec.pagebk1
			AND   pagebreak_seg2 = c_get_temptable_info_rec.pagebk2
			AND   pagebreak_seg3 = c_get_temptable_info_rec.pagebk3
			AND   set_of_books_id = sob_id1
			ANd   fund = v_fund_value1;

			IF SQL%ROWCOUNT = 0 THEN
		--Modified to fix Bug.1575992
			  INSERT INTO fv_status_funds_final
			    (set_of_books_id,treasury_symbol,treasury_symbol_id,fund,pagebreak_seg1,
			    pagebreak_seg2,pagebreak_seg3,expen_amt_total)
			  VALUES (sob_id1,v_treasury_symbol1,v_treasury_symbol_id1,v_fund_value1,
                      c_get_temptable_info_rec.pagebk1,
			    c_get_temptable_info_rec.pagebk2,
			    c_get_temptable_info_rec.pagebk3,
			    decode(v_sign,'C',nvl(c_get_temptable_info_rec.atot,0) * (-1),nvl(c_get_temptable_info_rec.atot,0)));
			END IF;
		END IF;-- checking for trans type
	END LOOP;-- c_get_temptable_info 'for' loop
END IF;
EXCEPTION
WHEN OTHERS THEN
    l_errbuf := SQLERRM;
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED,l_module_name||'.final_exception',l_errbuf);
    raise;
END sum_children_spending;

/*************************************************************************/
/* This function finds the flex_value_id for the account being processed.*/
/*************************************************************************/
FUNCTION get_flex_value_id(v_flex_value fnd_flex_values.flex_value%TYPE)
  return number
IS
  v_flex_value_id fnd_flex_values.flex_value_id%TYPE;
  l_module_name varchar2(200) := g_module_name || 'get_flax_value_id';
BEGIN
  v_statement := 'L';
  SELECT flex_value_set_id
  INTO  v_flex_value_id
  FROM fnd_id_flex_segments_vl
  WHERE id_flex_num = v_ca_id
    AND application_id = 101
    AND application_column_name = acct_seg_name
    AND id_flex_code='GL#';


RETURN v_flex_value_id;
EXCEPTION
   when others then
     err_message := 'FV_FUNDS_AVAILABLE_PKG.GET_FLEX_VALUE_ID.L.'||sqlerrm;
     fnd_message.set_name('FV','FV_FAI_GENERAL');
     fnd_message.set_token('MGS',err_message);
     IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FV_UTILITY.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,l_module_name);
     END IF;
     app_exception.raise_exception;

END get_flex_value_id;

/***************************************************************************/
/* This procedure deletes all the rows from the fv_status_funds_final table.*/
/***************************************************************************/
PROCEDURE delete_from_final
IS
l_module_name varchar2(200) := g_module_name || 'delete_from_final';
l_errbuf varchar2(300);
BEGIN
	delete from fv_status_funds_final;
	commit;
EXCEPTION
WHEN OTHERS THEN
    l_errbuf := SQLERRM;
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED,l_module_name||'.final_exception',l_errbuf);
    raise;
END delete_from_final;


/*************************************************************************/
/* This procedure calc_funds calculates all the totals for the */
/* different accounts.       */
/*************************************************************************/
PROCEDURE calc_funds(
          	x_acct_ff_low			IN VARCHAR2,
	    	x_acct_ff_high			IN VARCHAR2,
	    	x_rollup_type			IN VARCHAR2,
	    	x_treasury_symbol		IN VARCHAR2,
        	x_balance_seg_name		IN VARCHAR2,
       	        x_acct_seg_name    		IN VARCHAR2,
                x_set_of_books_id               IN NUMBER,
                x_currency_code                 IN VARCHAR2,
                x_period_name                   IN VARCHAR2,
	        x_pagebreak_seg1	        IN VARCHAR2,
	        x_pagebreak_seg2		IN VARCHAR2,
	        x_pagebreak_seg3		IN VARCHAR2
		) IS
l_module_name varchar2(200) := g_module_name || 'calc_funds';


BEGIN
   -- delete all the rows from the final table
   delete_from_final;
   IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'BEGIN');
   END IF;
   -- reassign incoming variables
   acct_ff_low        := x_acct_ff_low;
   acct_ff_high	      := x_acct_ff_high;
   rollup_type        := x_rollup_type;
   sob_id             := x_set_of_books_id;
   curr_code          := x_currency_code;
   pd_name            := x_period_name;
   acct_seg_name_num  := to_number(substr(x_acct_seg_name,8,2));
   bal_seg_name_num   := to_number(substr(x_balance_seg_name,8,2));
   acct_seg_name      := x_acct_seg_name;
   bal_seg_name	    := x_balance_seg_name;
   v_treasury_symbol  := x_treasury_symbol;
   v_pagebreak_seg1   := x_pagebreak_seg1;
   v_pagebreak_seg2   := x_pagebreak_seg2;
   v_pagebreak_seg3   := x_pagebreak_seg3;
--Added to fix Bug.1575992
/* Bug 1829771 */
/* Added  a condition sob and checking for rollup type in If condition */
	IF v_treasury_symbol IS NOT NULL and rollup_type='T'
	THEN
	SELECT treasury_symbol_id
	INTO  v_treasury_symbol_id
	FROM  fv_treasury_symbols
	WHERE  treasury_symbol = v_treasury_symbol
        AND    set_of_books_id=sob_id;
	END IF;
temp_v_treasury_symbol_id := v_treasury_symbol_id ;
   v_statement := 'A';
   -- find period number
   SELECT distinct(period_num)
   INTO   x_period_num
   FROM   gl_period_statuses
   WHERE  period_name = x_period_name
   AND	  ledger_id = sob_id
   AND	  application_id = 101;

   v_statement := 'B';
   -- find chart of account id
   SELECT chart_of_accounts_id
   INTO v_ca_id
   FROM gl_ledgers_public_v
   WHERE ledger_id = sob_id;

   v_statement := 'C';
/*  Bug No 1829771 */
/* Added the treasury_symbol_id    */
FOR c_treasury_fund_value_rec IN c_treasury_fund_values LOOP
  -- assign fund and process
  v_fund_value 	   := c_treasury_fund_value_rec.fund_value;
  v_budget 	   := nvl(c_treasury_fund_value_rec.budget_authority,'-1');
  v_transfers_in   := nvl(c_treasury_fund_value_rec.transfers_in,'-1');
  v_transfers_out  := nvl(c_treasury_fund_value_rec.transfers_out,'-1');
  v_commitment 	   := nvl(c_treasury_fund_value_rec.unliquid_commitments,'-1');
  v_obligation 	   := nvl(c_treasury_fund_value_rec.unliquid_obligations,'-1');
  v_expenditure	   := nvl(c_treasury_fund_value_rec.expended_amount,'-1');
  v_treasury_symbol_id:=c_treasury_fund_value_rec.treasury_symbol_id ;
  	v_statement := 'D';
	IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'FUND VALUE :' ||V_FUND_VALUE);
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'BALANCING SEGMENT NAME :' ||BAL_SEG_NAME);
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'ACCOUNTING SEG NAME:' || ACCT_SEG_NAME);
	END IF;

  -- Processing the budget authority account

    -- Find flex_value_id
    acct_flex_id := get_flex_value_id(v_budget);
    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'BUDGET_ID = '||ACCT_FLEX_ID);
    END IF;
    --FV_UTILITY.DEBUG_MESG('budget = '||v_budget);

    -- sum budget authority accounts (parent and children)
	--Modified to fix Bug.1575992
    sum_children_budget(v_budget,acct_flex_id,sob_id,v_treasury_symbol,v_fund_value,v_treasury_symbol_id);

  -- Processing the transfers-in account

    -- Find flex_value_id
    acct_flex_id := get_flex_value_id(v_transfers_in);
    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'TRANSFERS_IN = '||V_TRANSFERS_IN);
    END IF;
    v_acct_type := 'TRANS_IN';

    -- sum transfers_in accounts (parent and children)
	--Modified to fix Bug.1575992
    sum_children_transfers(v_transfers_in,acct_flex_id,v_acct_type,sob_id,v_treasury_symbol,v_fund_value,v_treasury_symbol_id);

  -- Processing the transfers-out account

    -- Find flex_value_id
    acct_flex_id := get_flex_value_id(v_transfers_out);
    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'TRANSFERS_OUT = '||V_TRANSFERS_OUT);
    END IF;
    v_acct_type := 'TRANS_OUT';

    -- sum transfers_out accounts (parent and children)
	--Modified to fix Bug.1575992
    sum_children_transfers(v_transfers_out,acct_flex_id,v_acct_type,sob_id,v_treasury_symbol,v_fund_value,v_treasury_symbol_id);


  -- Processing the commitment account

    -- Find flex_value_id
    acct_flex_id := get_flex_value_id(v_commitment);
    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'COMMIT = '||V_COMMITMENT);
    END IF;
    v_acct_type := 'UNLIQ_COMM';

    -- sum commitment accounts (parent and children)
	--Modified to fix Bug.1575992
    sum_children_spending(v_commitment,acct_flex_id,v_acct_type,sob_id,v_treasury_symbol,v_fund_value,v_treasury_symbol_id);


  -- Processing the obligation account

    -- Find flex_value_id
    acct_flex_id := get_flex_value_id(v_obligation);
    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'OBL = '||V_OBLIGATION);
    END IF;
    v_acct_type := 'UNLIQ_OBLIG';

    -- sum obligation accounts (parent and children)
	--Modified to fix Bug.1575992
    sum_children_spending(v_obligation,acct_flex_id,v_acct_type,sob_id,v_treasury_symbol,v_fund_value,v_treasury_symbol_id);


  -- Processing the expenditure account

    -- Find flex_value_id
    acct_flex_id := get_flex_value_id(v_expenditure);
    IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'EXP = '||V_EXPENDITURE);
    END IF;
    v_acct_type := 'EXPEN_AMT';

    -- sum expenditure accounts (parent and children)
	--Modified to fix Bug.1575992
    sum_children_spending(v_expenditure,acct_flex_id,v_acct_type,sob_id,v_treasury_symbol,v_fund_value,v_treasury_symbol_id);

 END LOOP;

--  Calculating the values for total_budgetary, total_actuals and funds_available
--Update statement is modified as part of BE enhancement
	UPDATE fv_status_funds_final set
		--total_budgetary	= (nvl(budget_Auth_total,0) + nvl(transfers_in_total,0)) - nvl(transfers_out_total,0),
		total_budgetary	= (nvl(budget_Auth_total,0)) ,
		total_actuals	=  nvl(unliquid_comm_total,0) + nvl(unliquid_oblig_total,0) + nvl(expen_amt_total,0);
	UPDATE fv_status_funds_final set
		funds_available	= nvl(total_budgetary,0) - nvl(total_actuals,0);

EXCEPTION
 when others then
   IF c_treasury_fund_values%ISOPEN THEN
      close c_treasury_fund_values;
   END IF;
   IF ( FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,'ERROR = '||SQLERRM);
   END IF;
   err_message := 'FV_FUNDS_AVAILABLE_PKG.CALC_FUNDS.'||v_statement||'.'||sqlerrm;
   fnd_message.set_name('FV','FV_FAI_GENERAL');
   fnd_message.set_token('MSG',err_message);
   IF ( FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FV_UTILITY.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,l_module_name);
   END IF;
--   app_exception.raise_exception;

END calc_funds;
END fv_status_of_funds_pkg;

/

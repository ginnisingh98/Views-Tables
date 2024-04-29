--------------------------------------------------------
--  DDL for Package GLF02220_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GLF02220_PKG" AUTHID CURRENT_USER AS
/* $Header: glfbdens.pls 120.5 2005/05/05 02:04:44 kvora ship $ */
--
-- GLOBAL VARIABLES
--
	status_number		NUMBER;		-- status number to query
	currency_code		VARCHAR2(15);
	budget_version_id	NUMBER;
	period_year		NUMBER;
	start_period_num	NUMBER;
	end_period_num		NUMBER;

--
-- Package
--   glf02220_pkg
-- Purpose
--   Form package for Enter Budget Amounts/Journals form
-- History
--   01/12/94		R Ng		Created
--   11/02/94		E Vaynshteyn	Modified
--
  --
  -- Procedure
  --   get_balances_info
  -- Purpose
  --   Gets all necessary information for items from AMOUNT block which uses
  --   GL_BUDGET_ASSIGNMENTS as a base table rather then
  --   GL_BUDGET_RANGE_INTERIM_V view.
  -- This has been done to improve performance of GLF02220.
  -- History
  --   01/05/95	 	E Vaynshteyn	Created
  -- Arguments
  -- Example
  --   glf02220_pkg.get_balances_info( 	:BUDGET.ledger_id,
  --					:BUDGET.currency_code,
  --					:BUDGET.budget_version_id,
  --                                    :BUDGET.period_year,
  --                                    :BUDGET.start_period_num,
  --                                    :BUDGET.end_period_num,
  --				        status_num,
  --				        ...
  --				     );
  -- Notes
  -- This procedure is called from AMOUNT_PRIVATE5.get_period_balances
  --
  PROCEDURE get_balances_info(
				X_ledger_id		IN	NUMBER,
				X_bc_on			IN 	VARCHAR2,
				X_currency_code		IN	VARCHAR2,
				X_budget_version_id	IN	NUMBER,
				X_period_year		IN	NUMBER,
				X_start_period_num 	IN	NUMBER,
				X_end_period_num 	IN	NUMBER,
				X_status_num 		IN	NUMBER,
				X_code_combination_id	IN	NUMBER,
				X_row_id		IN OUT NOCOPY	VARCHAR2,
				X_DR_FLAG		IN OUT NOCOPY	VARCHAR2,
				X_STATUS_NUMBER		IN OUT NOCOPY	NUMBER,
				X_LAST_UPDATE_DATE 	IN OUT NOCOPY	DATE,
				X_LAST_UPDATED_BY	IN OUT NOCOPY	NUMBER,
				X_LAST_UPDATE_LOGIN	IN OUT NOCOPY	NUMBER,
				X_CREATION_DATE		IN OUT NOCOPY	DATE,
				X_CREATED_BY		IN OUT NOCOPY	NUMBER,
				X_ACCOUNT_TYPE		IN OUT NOCOPY	VARCHAR2,
				X_CC_ACTIVE_FLAG	IN OUT NOCOPY	VARCHAR2,
				X_CC_BUDGETING_ALLOWED_FLAG IN OUT NOCOPY VARCHAR2,
				X_PERIOD1_AMOUNT_QRY	IN OUT NOCOPY	NUMBER,
				X_PERIOD2_AMOUNT_QRY	IN OUT NOCOPY	NUMBER,
				X_PERIOD3_AMOUNT_QRY	IN OUT NOCOPY	NUMBER,
				X_PERIOD4_AMOUNT_QRY	IN OUT NOCOPY	NUMBER,
				X_PERIOD5_AMOUNT_QRY	IN OUT NOCOPY	NUMBER,
				X_PERIOD6_AMOUNT_QRY	IN OUT NOCOPY	NUMBER,
				X_PERIOD7_AMOUNT_QRY	IN OUT NOCOPY	NUMBER,
				X_PERIOD8_AMOUNT_QRY	IN OUT NOCOPY	NUMBER,
				X_PERIOD9_AMOUNT_QRY	IN OUT NOCOPY	NUMBER,
				X_PERIOD10_AMOUNT_QRY	IN OUT NOCOPY	NUMBER,
				X_PERIOD11_AMOUNT_QRY	IN OUT NOCOPY	NUMBER,
				X_PERIOD12_AMOUNT_QRY	IN OUT NOCOPY	NUMBER,
				X_PERIOD13_AMOUNT_QRY	IN OUT NOCOPY	NUMBER,
				X_OLD_PERIOD1_AMOUNT_QRY	IN OUT NOCOPY	NUMBER,
				X_OLD_PERIOD2_AMOUNT_QRY	IN OUT NOCOPY	NUMBER,
				X_OLD_PERIOD3_AMOUNT_QRY	IN OUT NOCOPY	NUMBER,
				X_OLD_PERIOD4_AMOUNT_QRY	IN OUT NOCOPY	NUMBER,
				X_OLD_PERIOD5_AMOUNT_QRY	IN OUT NOCOPY	NUMBER,
				X_OLD_PERIOD6_AMOUNT_QRY	IN OUT NOCOPY	NUMBER,
				X_OLD_PERIOD7_AMOUNT_QRY	IN OUT NOCOPY	NUMBER,
				X_OLD_PERIOD8_AMOUNT_QRY	IN OUT NOCOPY	NUMBER,
				X_OLD_PERIOD9_AMOUNT_QRY	IN OUT NOCOPY	NUMBER,
				X_OLD_PERIOD10_AMOUNT_QRY	IN OUT NOCOPY	NUMBER,
				X_OLD_PERIOD11_AMOUNT_QRY	IN OUT NOCOPY	NUMBER,
				X_OLD_PERIOD12_AMOUNT_QRY	IN OUT NOCOPY	NUMBER,
				X_OLD_PERIOD13_AMOUNT_QRY	IN OUT NOCOPY	NUMBER,
				X_SEGMENT1		IN OUT NOCOPY	VARCHAR2,
				X_SEGMENT2		IN OUT NOCOPY	VARCHAR2,
				X_SEGMENT3		IN OUT NOCOPY	VARCHAR2,
				X_SEGMENT4		IN OUT NOCOPY	VARCHAR2,
				X_SEGMENT5		IN OUT NOCOPY	VARCHAR2,
				X_SEGMENT6		IN OUT NOCOPY	VARCHAR2,
				X_SEGMENT7		IN OUT NOCOPY	VARCHAR2,
				X_SEGMENT8		IN OUT NOCOPY	VARCHAR2,
				X_SEGMENT9		IN OUT NOCOPY	VARCHAR2,
				X_SEGMENT10		IN OUT NOCOPY	VARCHAR2,
				X_SEGMENT11		IN OUT NOCOPY	VARCHAR2,
				X_SEGMENT12		IN OUT NOCOPY	VARCHAR2,
				X_SEGMENT13		IN OUT NOCOPY	VARCHAR2,
				X_SEGMENT14		IN OUT NOCOPY	VARCHAR2,
				X_SEGMENT15		IN OUT NOCOPY	VARCHAR2,
				X_SEGMENT16		IN OUT NOCOPY	VARCHAR2,
				X_SEGMENT17		IN OUT NOCOPY	VARCHAR2,
				X_SEGMENT18		IN OUT NOCOPY	VARCHAR2,
				X_SEGMENT19		IN OUT NOCOPY	VARCHAR2,
				X_SEGMENT20		IN OUT NOCOPY	VARCHAR2,
				X_SEGMENT21		IN OUT NOCOPY	VARCHAR2,
				X_SEGMENT22		IN OUT NOCOPY	VARCHAR2,
				X_SEGMENT23		IN OUT NOCOPY	VARCHAR2,
				X_SEGMENT24		IN OUT NOCOPY	VARCHAR2,
				X_SEGMENT25		IN OUT NOCOPY	VARCHAR2,
				X_SEGMENT26		IN OUT NOCOPY	VARCHAR2,
				X_SEGMENT27		IN OUT NOCOPY	VARCHAR2,
				X_SEGMENT28		IN OUT NOCOPY	VARCHAR2,
				X_SEGMENT29		IN OUT NOCOPY	VARCHAR2,
				X_SEGMENT30		IN OUT NOCOPY	VARCHAR2,
				X_JE_DRCR_SIGN_REFERENCE	IN OUT NOCOPY	VARCHAR2,
				X_JE_LINE_DESCRIPTION1	IN OUT NOCOPY	VARCHAR2,
				X_JE_LINE_DESCRIPTION2	IN OUT NOCOPY	VARCHAR2,
				X_JE_LINE_DESCRIPTION3	IN OUT NOCOPY	VARCHAR2,
				X_JE_LINE_DESCRIPTION4	IN OUT NOCOPY	VARCHAR2,
				X_JE_LINE_DESCRIPTION5	IN OUT NOCOPY	VARCHAR2,
				X_JE_LINE_DESCRIPTION6	IN OUT NOCOPY	VARCHAR2,
				X_JE_LINE_DESCRIPTION7	IN OUT NOCOPY	VARCHAR2,
				X_JE_LINE_DESCRIPTION8	IN OUT NOCOPY	VARCHAR2,
				X_JE_LINE_DESCRIPTION9	IN OUT NOCOPY	VARCHAR2,
				X_JE_LINE_DESCRIPTION10	IN OUT NOCOPY	VARCHAR2,
				X_JE_LINE_DESCRIPTION11	IN OUT NOCOPY	VARCHAR2,
				X_JE_LINE_DESCRIPTION12	IN OUT NOCOPY	VARCHAR2,
				X_JE_LINE_DESCRIPTION13	IN OUT NOCOPY	VARCHAR2,
				X_STAT_AMOUNT1		IN OUT NOCOPY	NUMBER,
				X_STAT_AMOUNT2		IN OUT NOCOPY	NUMBER,
				X_STAT_AMOUNT3		IN OUT NOCOPY	NUMBER,
				X_STAT_AMOUNT4		IN OUT NOCOPY	NUMBER,
				X_STAT_AMOUNT5		IN OUT NOCOPY	NUMBER,
				X_STAT_AMOUNT6		IN OUT NOCOPY	NUMBER,
				X_STAT_AMOUNT7		IN OUT NOCOPY	NUMBER,
				X_STAT_AMOUNT8		IN OUT NOCOPY	NUMBER,
				X_STAT_AMOUNT9		IN OUT NOCOPY	NUMBER,
				X_STAT_AMOUNT10		IN OUT NOCOPY	NUMBER,
				X_STAT_AMOUNT11		IN OUT NOCOPY	NUMBER,
				X_STAT_AMOUNT12		IN OUT NOCOPY	NUMBER,
				X_STAT_AMOUNT13		IN OUT NOCOPY	NUMBER,
				X_old_period1_amount	IN OUT NOCOPY	NUMBER,
				X_old_period2_amount	IN OUT NOCOPY	NUMBER,
				X_old_period3_amount	IN OUT NOCOPY	NUMBER,
				X_old_period4_amount	IN OUT NOCOPY	NUMBER,
				X_old_period5_amount	IN OUT NOCOPY	NUMBER,
				X_old_period6_amount	IN OUT NOCOPY	NUMBER,
				X_old_period7_amount	IN OUT NOCOPY	NUMBER,
				X_old_period8_amount	IN OUT NOCOPY	NUMBER,
				X_old_period9_amount	IN OUT NOCOPY	NUMBER,
				X_old_period10_amount	IN OUT NOCOPY	NUMBER,
				X_old_period11_amount	IN OUT NOCOPY	NUMBER,
				X_old_period12_amount	IN OUT NOCOPY	NUMBER,
				X_old_period13_amount	IN OUT NOCOPY	NUMBER,
				X_period1_amount	IN OUT NOCOPY	NUMBER,
				X_period2_amount	IN OUT NOCOPY	NUMBER,
				X_period3_amount	IN OUT NOCOPY	NUMBER,
				X_period4_amount	IN OUT NOCOPY	NUMBER,
				X_period5_amount	IN OUT NOCOPY	NUMBER,
				X_period6_amount	IN OUT NOCOPY	NUMBER,
				X_period7_amount	IN OUT NOCOPY	NUMBER,
				X_period8_amount	IN OUT NOCOPY	NUMBER,
				X_period9_amount	IN OUT NOCOPY	NUMBER,
				X_period10_amount	IN OUT NOCOPY	NUMBER,
				X_period11_amount	IN OUT NOCOPY	NUMBER,
				X_period12_amount	IN OUT NOCOPY	NUMBER,
				X_period13_amount	IN OUT NOCOPY	NUMBER);


  --
  -- Procedure
  --   get_period_prompts
  -- Purpose
  --   Gets period name prompts for the active periods within
  --   the selected budget period range.
  -- History
  --   01/12/94	 	R Ng		Created
  -- Arguments
  --   X_ledger_id           	Ledger ID
  --   X_period_year		Budget period year
  --   X_start_period_num	Start period number
  --   X_end_period_num		End period number
  --   X_period_namei		Period Name i (i in [1,13])
  --   X_adj_periodi_flag       Adjustment Period Flag
  --   X_num_adj_per_in_range   Number of adjustment periods w/i start and end period
  --   X_num_adj_per_before     Number of adjustment periods before the start period
  --   X_num_adj_per_total      Number of adjustment periods for the period year
  -- Example
  --   glf02220_pkg.get_period_prompts( :BUDGET.ledger_id,
  --                                    :BUDGET.period_year,
  --                                    :BUDGET.start_period_num,
  --                                    :BUDGET.end_period_num,
  --				        :WORLD.period1_name,
  --				        ...
  --				        :WORLD.period13_name );
  -- Notes
  --
  PROCEDURE get_period_prompts( X_ledger_id		IN NUMBER,
                           	X_period_year		IN NUMBER,
                           	X_start_period_num 	IN NUMBER,
                           	X_end_period_num	IN NUMBER,
                          	X_period1_name 		IN OUT NOCOPY VARCHAR2,
                          	X_period2_name 		IN OUT NOCOPY VARCHAR2,
                           	X_period3_name     	IN OUT NOCOPY VARCHAR2,
                           	X_period4_name     	IN OUT NOCOPY VARCHAR2,
                           	X_period5_name     	IN OUT NOCOPY VARCHAR2,
                           	X_period6_name     	IN OUT NOCOPY VARCHAR2,
                           	X_period7_name     	IN OUT NOCOPY VARCHAR2,
                           	X_period8_name     	IN OUT NOCOPY VARCHAR2,
                           	X_period9_name     	IN OUT NOCOPY VARCHAR2,
                           	X_period10_name     	IN OUT NOCOPY VARCHAR2,
                           	X_period11_name     	IN OUT NOCOPY VARCHAR2,
                           	X_period12_name     	IN OUT NOCOPY VARCHAR2,
                           	X_period13_name     	IN OUT NOCOPY VARCHAR2,
                           	X_adj_period1_flag	IN OUT NOCOPY VARCHAR2,
               		   	X_adj_period2_flag	IN OUT NOCOPY VARCHAR2,
             		   	X_adj_period3_flag	IN OUT NOCOPY VARCHAR2,
             		   	X_adj_period4_flag	IN OUT NOCOPY VARCHAR2,
             		   	X_adj_period5_flag	IN OUT NOCOPY VARCHAR2,
             		   	X_adj_period6_flag	IN OUT NOCOPY VARCHAR2,
             		   	X_adj_period7_flag	IN OUT NOCOPY VARCHAR2,
             		   	X_adj_period8_flag	IN OUT NOCOPY VARCHAR2,
             		   	X_adj_period9_flag	IN OUT NOCOPY VARCHAR2,
             		   	X_adj_period10_flag	IN OUT NOCOPY VARCHAR2,
             		   	X_adj_period11_flag	IN OUT NOCOPY VARCHAR2,
             		   	X_adj_period12_flag	IN OUT NOCOPY VARCHAR2,
             		   	X_adj_period13_flag	IN OUT NOCOPY VARCHAR2,
                                X_num_adj_per_in_range	IN OUT NOCOPY NUMBER,
                                X_num_adj_per_before	IN OUT NOCOPY NUMBER,
                                X_num_adj_per_total	IN OUT NOCOPY NUMBER );

  --
  -- Procedure
  --   add_approved_budget_amounts
  -- Purpose
  --   Adds GL_BC_PACKETS approved budget amounts to one ccid row just
  --   fetched from GL_BUDGET_RANGE_INTERIM_V during Post Query.
  -- History
  --   08/28/94	 	R Ng		Created
  -- Arguments
  --   X_ledger_id           	Ledger ID
  --   X_code_combination_id	Code combination ID
  --   X_currency_code		Currency Code (Monetary/Stat)
  --   X_budget_version_id	Budget version ID
  --   X_period_year		Budget period year
  --   X_start_period_num	Start period number
  --   X_end_period_num		End period number
  --   X_dr_sign		Dr Sign (1,-1)
  --   X_periodi_amount		Period i amount (i in [1,13])
  --   X_old_periodi_amount	Old Period i amount (i in [1,13])
  -- Example
  --   glf02220_pkg.add_approved_budget_amounts( :BUDGET.ledger_id,
  --                                             :AMOUNT.code_combination_id,
  --                            		 :BUDGET.currency_code,
  --				              	 :BUDGET.budget_version_id,
  --				              	 :BUDGET.period_year,
  --                                          	 :BUDGET.start_period_num,
  --                                          	 :BUDGET.end_period_num,
  --						 dr_sign,
  --                                          	 :AMOUNT.period1_amount,
  --					         ...
  --  						 :AMOUNT.period13_amount,
  --                                          	 :AMOUNT.old_period1_amount,
  --					         ...
  --  						 :AMOUNT.old_period13_amount );
  -- Notes
  --
  PROCEDURE add_approved_budget_amounts( X_ledger_id               IN NUMBER,
				      	 X_code_combination_id     IN NUMBER,
				      	 X_currency_code           IN VARCHAR2,
				      	 X_budget_version_id       IN NUMBER,
				      	 X_period_year             IN NUMBER,
				      	 X_start_period_num        IN NUMBER,
				      	 X_end_period_num          IN NUMBER,
					 X_dr_sign		   IN NUMBER,
				      	 X_period1_amount          IN OUT NOCOPY NUMBER,
				      	 X_period2_amount          IN OUT NOCOPY NUMBER,
				      	 X_period3_amount          IN OUT NOCOPY NUMBER,
				      	 X_period4_amount          IN OUT NOCOPY NUMBER,
				      	 X_period5_amount          IN OUT NOCOPY NUMBER,
				      	 X_period6_amount          IN OUT NOCOPY NUMBER,
				      	 X_period7_amount          IN OUT NOCOPY NUMBER,
				      	 X_period8_amount          IN OUT NOCOPY NUMBER,
				      	 X_period9_amount          IN OUT NOCOPY NUMBER,
				      	 X_period10_amount         IN OUT NOCOPY NUMBER,
				     	 X_period11_amount         IN OUT NOCOPY NUMBER,
				      	 X_period12_amount         IN OUT NOCOPY NUMBER,
				      	 X_period13_amount         IN OUT NOCOPY NUMBER,
					 X_old_period1_amount      IN OUT NOCOPY NUMBER,
					 X_old_period2_amount      IN OUT NOCOPY NUMBER,
					 X_old_period3_amount      IN OUT NOCOPY NUMBER,
					 X_old_period4_amount      IN OUT NOCOPY NUMBER,
					 X_old_period5_amount      IN OUT NOCOPY NUMBER,
					 X_old_period6_amount      IN OUT NOCOPY NUMBER,
					 X_old_period7_amount      IN OUT NOCOPY NUMBER,
					 X_old_period8_amount      IN OUT NOCOPY NUMBER,
					 X_old_period9_amount      IN OUT NOCOPY NUMBER,
					 X_old_period10_amount     IN OUT NOCOPY NUMBER,
					 X_old_period11_amount     IN OUT NOCOPY NUMBER,
					 X_old_period12_amount     IN OUT NOCOPY NUMBER,
					 X_old_period13_amount     IN OUT NOCOPY NUMBER );

  --
  -- Procedure
  --   get_brule_budget_amounts
  -- Purpose
  --   Gets budget amounts thru a budget-based budget rule.
  --   Valid budget rules are: 'PYBM', 'CYBM', 'PYBS', or 'CYBS'.
  -- History
  --   04/04/94	 	R Ng		Created
  -- Arguments
  --   X_budget_rule           	Budget rule code
  --   X_rule_amount           	Budget rule amount
  --   X_status_number		Status Number
  --   X_ledger_id           	Ledger ID
  --   X_bc_on			Y - BC is Enabled.  N - BC is disabled
  --   X_code_combination_id	Code combination ID
  --   X_currency_code		Currency Code (Monetary/Stat)
  --   X_budget_version_id	Budget version ID
  --   X_period_year		Budget period year
  --   X_start_period_num	Start period number
  --   X_end_period_num		End period number
  --   X_dr_sign		Dr Sign (1, -1)
  --   X_periodi_amount		Period i amount (i in [1,13])
  -- Example
  --   glf02220_pkg.get_brule_budget_amounts( :RULE.budget_rule,
  --                                          :RULE.amount,
  --					      0,
  --                                          :BUDGET.ledger_id,
  --					      'N',
  --                                          :RULE.code_combination_id,
  --                                          :BUDGET.currency_code,
  --				              :BUDGET.budget_version_id,
  --				              :BUDGET.period_year,
  --                                          :BUDGET.start_period_num,
  --                                          :BUDGET.end_period_num,
  --					      :RULE.dr_sign,
  --                                          :AMOUNT.period1_amount,
  --					      ...
  --				              :AMOUNT.period13_amount );
  -- Notes
  --
  PROCEDURE get_brule_budget_amounts( X_budget_rule		IN VARCHAR2,
				      X_rule_amount		IN NUMBER,
				      X_status_number		IN NUMBER,
				      X_ledger_id               IN NUMBER,
				      X_bc_on			IN VARCHAR2,
				      X_code_combination_id    	IN NUMBER,
				      X_currency_code          	IN VARCHAR2,
				      X_budget_version_id      	IN NUMBER,
				      X_period_year            	IN NUMBER,
				      X_start_period_num       	IN NUMBER,
				      X_end_period_num		IN NUMBER,
				      X_dr_sign			IN NUMBER,
				      X_period1_amount        	IN OUT NOCOPY NUMBER,
				      X_period2_amount        	IN OUT NOCOPY NUMBER,
				      X_period3_amount        	IN OUT NOCOPY NUMBER,
				      X_period4_amount        	IN OUT NOCOPY NUMBER,
				      X_period5_amount        	IN OUT NOCOPY NUMBER,
				      X_period6_amount        	IN OUT NOCOPY NUMBER,
				      X_period7_amount        	IN OUT NOCOPY NUMBER,
				      X_period8_amount        	IN OUT NOCOPY NUMBER,
				      X_period9_amount        	IN OUT NOCOPY NUMBER,
				      X_period10_amount        	IN OUT NOCOPY NUMBER,
				      X_period11_amount        	IN OUT NOCOPY NUMBER,
				      X_period12_amount        	IN OUT NOCOPY NUMBER,
				      X_period13_amount        	IN OUT NOCOPY NUMBER );

  --
  -- Procedure
  --   get_brule_actual_amounts
  -- Purpose
  --   Gets budget amounts thru an actual-based budget rule.
  --   Valid budget rules are: 'PYAM', 'CYAM', 'PYAS', or 'CYAS'.
  -- History
  --   04/04/94	 	R Ng		Created
  -- Arguments
  --   X_budget_rule           	Budget rule code
  --   X_rule_amount           	Budget rule amount
  --   X_ledger_id           	Ledger ID
  --   X_bc_on			Y - BC is Enabled.  N - BC is disabled
  --   X_code_combination_id	Code combination ID
  --   X_currency_code		Currency Code (Monetary/Stat)
  --   X_budget_version_id	Budget version ID
  --   X_period_year		Budget period year
  --   X_start_period_num	Start period number
  --   X_end_period_num		End period number
  --   X_dr_sign		Dr Sign (-1, 1)
  --   X_periodi_amount		Period i amount (i in [1,13])
  -- Example
  --   glf02220_pkg.get_brule_actual_amounts( :RULE.budget_rule,
  --                                          :RULE.amount,
  --                                          :BUDGET.ledger_id,
  --                                          'N',
  --                                          :RULE.code_combination_id,
  --                                          :BUDGET.currency_code,
  --				              :BUDGET.budget_version_id,
  --				              :BUDGET.period_year,
  --                                          :BUDGET.start_period_num,
  --                                          :BUDGET.end_period_num,
  --                                          -1,
  --                                          :AMOUNT.period1_amount,
  --					      ...
  --				              :AMOUNT.period13_amount );
  -- Notes
  --
  PROCEDURE get_brule_actual_amounts( X_budget_rule		IN VARCHAR2,
				      X_rule_amount		IN NUMBER,
				      X_ledger_id               IN NUMBER,
				      X_bc_on			IN VARCHAR2,
				      X_code_combination_id    	IN NUMBER,
				      X_currency_code          	IN VARCHAR2,
				      X_budget_version_id      	IN NUMBER,
				      X_period_year            	IN NUMBER,
				      X_start_period_num       	IN NUMBER,
				      X_end_period_num       	IN NUMBER,
				      X_dr_sign			IN NUMBER,
				      X_period1_amount        	IN OUT NOCOPY NUMBER,
				      X_period2_amount        	IN OUT NOCOPY NUMBER,
				      X_period3_amount        	IN OUT NOCOPY NUMBER,
				      X_period4_amount        	IN OUT NOCOPY NUMBER,
				      X_period5_amount        	IN OUT NOCOPY NUMBER,
				      X_period6_amount        	IN OUT NOCOPY NUMBER,
				      X_period7_amount        	IN OUT NOCOPY NUMBER,
				      X_period8_amount        	IN OUT NOCOPY NUMBER,
				      X_period9_amount        	IN OUT NOCOPY NUMBER,
				      X_period10_amount        	IN OUT NOCOPY NUMBER,
				      X_period11_amount        	IN OUT NOCOPY NUMBER,
				      X_period12_amount        	IN OUT NOCOPY NUMBER,
				      X_period13_amount        	IN OUT NOCOPY NUMBER );
  --
  -- Procedure
  --   get_cashe_data
  -- Purpose
  -- this is a combination of the three calls to the stored procedures which
  -- is being called only one time to improve performance
  -- History
  --   02/27/95	 	E Vaynshteyn		Created

  PROCEDURE get_cashe_data(     x_ledger_period_type 	IN OUT NOCOPY VARCHAR2,
  				x_num_periods_per_year	IN OUT NOCOPY NUMBER,
  				x_ledger_id 		NUMBER,
  				x_budget_version_id 	IN OUT NOCOPY NUMBER,
                               	x_budget_name 		IN OUT NOCOPY VARCHAR2,
                               	x_bj_required           IN OUT NOCOPY VARCHAR2,
                               	x_coa_id		NUMBER,
                               	x_account_column_name 	IN OUT NOCOPY VARCHAR2
  				);


  --
  -- Procedure
  --   get_cashe_data
  -- Purpose
  -- this is a combination of the two calls to the stored procedures which
  -- is being called only one time to improve performance
  -- History
  --   03/01/95	 	E Vaynshteyn		Created
   PROCEDURE DB_get_account_properties (
   				X_ledger_id			NUMBER,
				X_coa_id			NUMBER,
				X_code_combination_id		NUMBER,
				X_budget_version_id		NUMBER,
				X_budget_entity_id		NUMBER,
				X_check_is_acct_stat_enterable	VARCHAR2,
				X_check_is_account_frozen	VARCHAR2,
				X_cc_stat_enterable_flag	IN OUT NOCOPY VARCHAR2,
				X_cc_frozen_flag		IN OUT NOCOPY VARCHAR2,
                                X_currency_code                 VARCHAR2);

END glf02220_pkg;

 

/

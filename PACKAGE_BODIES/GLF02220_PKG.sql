--------------------------------------------------------
--  DDL for Package Body GLF02220_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GLF02220_PKG" AS
/* $Header: glfbdenb.pls 120.5 2005/05/05 02:04:37 kvora ship $ */

  --
  -- PRIVATE VARIABLES
  --
  maximum_allowed_amount_value   NUMBER := 999999999999999999999999;	 -- (24)9

  --
  -- PRIVATE PROCEDURES AND FUNCTIONS
  --

  PROCEDURE get_approved_budget_amounts(
              	X_ledger_id               IN NUMBER,
	      	X_code_combination_id     IN NUMBER,
	      	X_currency_code           IN VARCHAR2,
		X_actual_flag		  IN VARCHAR2,
		X_budget_version_id       IN NUMBER,
		X_period_year             IN NUMBER,
		X_start_period_num        IN NUMBER,
		X_end_period_num	  IN NUMBER,
		X_dr_sign		  IN NUMBER,
		X_data_found		  IN OUT NOCOPY NUMBER,
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
		X_period13_amount         IN OUT NOCOPY NUMBER) IS
    CURSOR gbp IS
      SELECT
	      nvl(sum(decode(PS.period_num,
	        floor((X_start_period_num-1)/13) * 13 + 1,
	        (nvl(BP.entered_dr,0)-nvl(BP.entered_cr,0))*X_dr_sign, 0)),0),
	      nvl(sum(decode(PS.period_num,
	        floor((X_start_period_num-1)/13) * 13 + 2,
	        (nvl(BP.entered_dr,0)-nvl(BP.entered_cr,0))*X_dr_sign, 0)),0),
	      nvl(sum(decode(PS.period_num,
	        floor((X_start_period_num-1)/13) * 13 + 3,
	        (nvl(BP.entered_dr,0)-nvl(BP.entered_cr,0))*X_dr_sign, 0)),0),
	      nvl(sum(decode(PS.period_num,
	        floor((X_start_period_num-1)/13) * 13 + 4,
	        (nvl(BP.entered_dr,0)-nvl(BP.entered_cr,0))*X_dr_sign, 0)),0),
	      nvl(sum(decode(PS.period_num,
	        floor((X_start_period_num-1)/13) * 13 + 5,
	        (nvl(BP.entered_dr,0)-nvl(BP.entered_cr,0))*X_dr_sign, 0)),0),
	      nvl(sum(decode(PS.period_num,
	        floor((X_start_period_num-1)/13) * 13 + 6,
	        (nvl(BP.entered_dr,0)-nvl(BP.entered_cr,0))*X_dr_sign, 0)),0),
	      nvl(sum(decode(PS.period_num,
	        floor((X_start_period_num-1)/13) * 13 + 7,
	        (nvl(BP.entered_dr,0)-nvl(BP.entered_cr,0))*X_dr_sign, 0)),0),
	      nvl(sum(decode(PS.period_num,
	        floor((X_start_period_num-1)/13) * 13 + 8,
	        (nvl(BP.entered_dr,0)-nvl(BP.entered_cr,0))*X_dr_sign, 0)),0),
	      nvl(sum(decode(PS.period_num,
	        floor((X_start_period_num-1)/13) * 13 + 9,
	        (nvl(BP.entered_dr,0)-nvl(BP.entered_cr,0))*X_dr_sign, 0)),0),
	      nvl(sum(decode(PS.period_num,
	        floor((X_start_period_num-1)/13) * 13 + 10,
	        (nvl(BP.entered_dr,0)-nvl(BP.entered_cr,0))*X_dr_sign, 0)),0),
	      nvl(sum(decode(PS.period_num,
	        floor((X_start_period_num-1)/13) * 13 + 11,
	        (nvl(BP.entered_dr,0)-nvl(BP.entered_cr,0))*X_dr_sign, 0)),0),
	      nvl(sum(decode(PS.period_num,
	        floor((X_start_period_num-1)/13) * 13 + 12,
	        (nvl(BP.entered_dr,0)-nvl(BP.entered_cr,0))*X_dr_sign, 0)),0),
	      nvl(sum(decode(PS.period_num,
	        floor((X_start_period_num-1)/13) * 13 + 13,
	        (nvl(BP.entered_dr,0)-nvl(BP.entered_cr,0))*X_dr_sign, 0)),0),
	      decode(max(BP.rowid), null, 0, 1)
      FROM
             GL_BC_PACKET_ARRIVAL_ORDER AO,
             GL_BC_PACKETS BP,
             GL_PERIOD_STATUSES PS
      WHERE
             PS.application_id = 101
         AND PS.ledger_id = X_ledger_id
         AND PS.period_year = X_period_year
         AND PS.period_num BETWEEN X_start_period_num
                           AND     X_end_period_num
         AND BP.code_combination_id = X_code_combination_id
         AND BP.period_name = PS.period_name||''
         AND BP.actual_flag = X_actual_flag
         AND nvl(BP.budget_version_id,-1) = decode(X_actual_flag,
                                                   'B', X_budget_version_id,
                                                   -1)
         AND BP.currency_code = X_currency_code
         AND BP.ledger_id = X_ledger_id
         AND BP.status_code = 'A'
         AND AO.packet_id = BP.packet_id
         AND AO.ledger_id = X_ledger_id
         AND AO.affect_funds_flag = 'Y';

  BEGIN
    OPEN gbp;
    FETCH gbp INTO X_period1_amount,
		   X_period2_amount,
		   X_period3_amount,
		   X_period4_amount,
		   X_period5_amount,
		   X_period6_amount,
		   X_period7_amount,
		   X_period8_amount,
		   X_period9_amount,
		   X_period10_amount,
		   X_period11_amount,
		   X_period12_amount,
		   X_period13_amount,
		   X_data_found;

    CLOSE gbp;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      NULL;
    WHEN OTHERS THEN
      app_exception.raise_exception;

  END get_approved_budget_amounts;

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
				X_CC_BUDGETING_ALLOWED_FLAG IN OUT NOCOPY	VARCHAR2,
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
				X_period13_amount	IN OUT NOCOPY	NUMBER)

  IS
	X_dr_sign	NUMBER;
  BEGIN

        -- this SELECT is part of the view glvbdrgi.sql which is not being used
	-- anymore in attempt to improve performance (bug #254358)
	SELECT
		BI.rowid,
		decode(CC.account_type,
	  		'A', 'Y',
	  		'E', 'Y',
	  		'D', 'Y', 'N'),
		nvl(BI.status_number,0),
		BI.last_update_date,
		BI.last_updated_by,
		BI.last_update_login,
		BI.creation_date,
		BI.created_by,
		CC.account_type,
		decode(CC.enabled_flag,
	  		'N', 'N',
	  		decode(sign(trunc(SYSDATE)-
			trunc(nvl(CC.start_date_active,SYSDATE))),
	   		-1, 'N',
	   		decode(sign(trunc(nvl(CC.end_date_active,SYSDATE))-
			trunc(SYSDATE)),
	     		-1, 'N','Y'))),
		CC.detail_budgeting_allowed_flag,
	  	nvl(BI.period1_amount,0)-nvl(BI.old_period1_amount,0),
	  	nvl(BI.period2_amount,0)-nvl(BI.old_period2_amount,0),
	  	nvl(BI.period3_amount,0)-nvl(BI.old_period3_amount,0),
	  	nvl(BI.period4_amount,0)-nvl(BI.old_period4_amount,0),
	  	nvl(BI.period5_amount,0)-nvl(BI.old_period5_amount,0),
	  	nvl(BI.period6_amount,0)-nvl(BI.old_period6_amount,0),
	  	nvl(BI.period7_amount,0)-nvl(BI.old_period7_amount,0),
	  	nvl(BI.period8_amount,0)-nvl(BI.old_period8_amount,0),
	  	nvl(BI.period9_amount,0)-nvl(BI.old_period9_amount,0),
	  	nvl(BI.period10_amount,0)-nvl(BI.old_period10_amount,0),
	  	nvl(BI.period11_amount,0)-nvl(BI.old_period11_amount,0),
	  	nvl(BI.period12_amount,0)-nvl(BI.old_period12_amount,0),
	  	nvl(BI.period13_amount,0)-nvl(BI.old_period13_amount,0),
          	0,
          	0,
          	0,
          	0,
          	0,
          	0,
          	0,
          	0,
          	0,
          	0,
          	0,
          	0,
          	0,
		CC.segment1,
		CC.segment2,
		CC.segment3,
		CC.segment4,
		CC.segment5,
		CC.segment6,
		CC.segment7,
		CC.segment8,
		CC.segment9,
		CC.segment10,
		CC.segment11,
		CC.segment12,
		CC.segment13,
		CC.segment14,
		CC.segment15,
		CC.segment16,
		CC.segment17,
		CC.segment18,
		CC.segment19,
		CC.segment20,
		CC.segment21,
		CC.segment22,
		CC.segment23,
		CC.segment24,
		CC.segment25,
		CC.segment26,
		CC.segment27,
		CC.segment28,
		CC.segment29,
		CC.segment30,
		BI.je_drcr_sign_reference,
		BI.je_line_description1,
		BI.je_line_description2,
		BI.je_line_description3,
		BI.je_line_description4,
		BI.je_line_description5,
		BI.je_line_description6,
		BI.je_line_description7,
		BI.je_line_description8,
		BI.je_line_description9,
		BI.je_line_description10,
		BI.je_line_description11,
		BI.je_line_description12,
		BI.je_line_description13,
		BI.stat_amount1,
		BI.stat_amount2,
		BI.stat_amount3,
		BI.stat_amount4,
		BI.stat_amount5,
		BI.stat_amount6,
		BI.stat_amount7,
		BI.stat_amount8,
		BI.stat_amount9,
		BI.stat_amount10,
		BI.stat_amount11,
		BI.stat_amount12,
		BI.stat_amount13
	INTO
		X_row_id,
		X_DR_FLAG,
		X_STATUS_NUMBER,
		X_LAST_UPDATE_DATE,
		X_LAST_UPDATED_BY,
		X_LAST_UPDATE_LOGIN,
		X_CREATION_DATE,
		X_CREATED_BY,
		X_ACCOUNT_TYPE,
		X_CC_ACTIVE_FLAG,
		X_CC_BUDGETING_ALLOWED_FLAG,
		X_PERIOD1_AMOUNT_QRY,
		X_PERIOD2_AMOUNT_QRY,
		X_PERIOD3_AMOUNT_QRY,
		X_PERIOD4_AMOUNT_QRY,
		X_PERIOD5_AMOUNT_QRY,
		X_PERIOD6_AMOUNT_QRY,
		X_PERIOD7_AMOUNT_QRY,
		X_PERIOD8_AMOUNT_QRY,
		X_PERIOD9_AMOUNT_QRY,
		X_PERIOD10_AMOUNT_QRY,
		X_PERIOD11_AMOUNT_QRY,
		X_PERIOD12_AMOUNT_QRY,
		X_PERIOD13_AMOUNT_QRY,
		X_OLD_PERIOD1_AMOUNT_QRY,
		X_OLD_PERIOD2_AMOUNT_QRY,
		X_OLD_PERIOD3_AMOUNT_QRY,
		X_OLD_PERIOD4_AMOUNT_QRY,
		X_OLD_PERIOD5_AMOUNT_QRY,
		X_OLD_PERIOD6_AMOUNT_QRY,
		X_OLD_PERIOD7_AMOUNT_QRY,
		X_OLD_PERIOD8_AMOUNT_QRY,
		X_OLD_PERIOD9_AMOUNT_QRY,
		X_OLD_PERIOD10_AMOUNT_QRY,
		X_OLD_PERIOD11_AMOUNT_QRY,
		X_OLD_PERIOD12_AMOUNT_QRY,
		X_OLD_PERIOD13_AMOUNT_QRY,
		X_SEGMENT1,
		X_SEGMENT2,
		X_SEGMENT3,
		X_SEGMENT4,
		X_SEGMENT5,
		X_SEGMENT6,
		X_SEGMENT7,
		X_SEGMENT8,
		X_SEGMENT9,
		X_SEGMENT10,
		X_SEGMENT11,
		X_SEGMENT12,
		X_SEGMENT13,
		X_SEGMENT14,
		X_SEGMENT15,
		X_SEGMENT16,
		X_SEGMENT17,
		X_SEGMENT18,
		X_SEGMENT19,
		X_SEGMENT20,
		X_SEGMENT21,
		X_SEGMENT22,
		X_SEGMENT23,
		X_SEGMENT24,
		X_SEGMENT25,
		X_SEGMENT26,
		X_SEGMENT27,
		X_SEGMENT28,
		X_SEGMENT29,
		X_SEGMENT30,
		X_JE_DRCR_SIGN_REFERENCE,
		X_JE_LINE_DESCRIPTION1,
		X_JE_LINE_DESCRIPTION2,
		X_JE_LINE_DESCRIPTION3,
		X_JE_LINE_DESCRIPTION4,
		X_JE_LINE_DESCRIPTION5,
		X_JE_LINE_DESCRIPTION6,
		X_JE_LINE_DESCRIPTION7,
		X_JE_LINE_DESCRIPTION8,
		X_JE_LINE_DESCRIPTION9,
		X_JE_LINE_DESCRIPTION10,
		X_JE_LINE_DESCRIPTION11,
		X_JE_LINE_DESCRIPTION12,
		X_JE_LINE_DESCRIPTION13,
		X_STAT_AMOUNT1,
		X_STAT_AMOUNT2,
		X_STAT_AMOUNT3,
		X_STAT_AMOUNT4,
		X_STAT_AMOUNT5,
		X_STAT_AMOUNT6,
		X_STAT_AMOUNT7,
		X_STAT_AMOUNT8,
		X_STAT_AMOUNT9,
		X_STAT_AMOUNT10,
		X_STAT_AMOUNT11,
		X_STAT_AMOUNT12,
		X_STAT_AMOUNT13
	FROM
		GL_BUDGET_RANGE_INTERIM BI,
		GL_CODE_COMBINATIONS CC
	WHERE
        	    BI.ledger_id (+) = X_ledger_id
		AND BI.code_combination_id (+) = CC.code_combination_id
		AND BI.currency_code (+) = X_currency_code
		AND BI.budget_version_id (+) = X_budget_version_id
		AND BI.period_year (+) = X_period_year
		AND BI.start_period_num (+) = X_start_period_num
		AND BI.status_number(+) = X_status_num
		AND CC.code_combination_id = X_code_combination_id;



	-- Get the account type of the flexfield we are analyzing
       	IF ( X_dr_flag = 'N' ) THEN
	 	X_dr_sign := -1;
	ELSE
	 	X_dr_sign := 1;
       	END IF;

       -- get period balances for each period. This SELECT was moved here from view to optimize
       -- performance
   SELECT
        nvl(sum(decode(GB.period_num,
          floor((X_start_period_num-1)/13) * 13 + 1,
          (nvl(GB.period_net_dr,0)-nvl(GB.period_net_cr,0)) * X_dr_sign, 0)),0),
        nvl(sum(decode(GB.period_num,
          floor((X_start_period_num-1)/13) * 13 + 2,
          (nvl(GB.period_net_dr,0)-nvl(GB.period_net_cr,0)) * X_dr_sign, 0)),0),
        nvl(sum(decode(GB.period_num,
          floor((X_start_period_num-1)/13) * 13 + 3,
          (nvl(GB.period_net_dr,0)-nvl(GB.period_net_cr,0)) * X_dr_sign, 0)),0),
        nvl(sum(decode(GB.period_num,
          floor((X_start_period_num-1)/13) * 13 + 4,
          (nvl(GB.period_net_dr,0)-nvl(GB.period_net_cr,0)) * X_dr_sign, 0)),0),
        nvl(sum(decode(GB.period_num,
          floor((X_start_period_num-1)/13) * 13 + 5,
          (nvl(GB.period_net_dr,0)-nvl(GB.period_net_cr,0)) * X_dr_sign, 0)),0),
        nvl(sum(decode(GB.period_num,
          floor((X_start_period_num-1)/13) * 13 + 6,
          (nvl(GB.period_net_dr,0)-nvl(GB.period_net_cr,0)) * X_dr_sign, 0)),0),
        nvl(sum(decode(GB.period_num,
          floor((X_start_period_num-1)/13) * 13 + 7,
          (nvl(GB.period_net_dr,0)-nvl(GB.period_net_cr,0)) * X_dr_sign, 0)),0),
        nvl(sum(decode(GB.period_num,
          floor((X_start_period_num-1)/13) * 13 + 8,
          (nvl(GB.period_net_dr,0)-nvl(GB.period_net_cr,0)) * X_dr_sign, 0)),0),
        nvl(sum(decode(GB.period_num,
          floor((X_start_period_num-1)/13) * 13 + 9,
          (nvl(GB.period_net_dr,0)-nvl(GB.period_net_cr,0)) * X_dr_sign, 0)),0),
        nvl(sum(decode(GB.period_num,
          floor((X_start_period_num-1)/13) * 13 + 10,
          (nvl(GB.period_net_dr,0)-nvl(GB.period_net_cr,0)) * X_dr_sign, 0)),0),
        nvl(sum(decode(GB.period_num,
          floor((X_start_period_num-1)/13) * 13 + 11,
          (nvl(GB.period_net_dr,0)-nvl(GB.period_net_cr,0)) * X_dr_sign, 0)),0),
        nvl(sum(decode(GB.period_num,
          floor((X_start_period_num-1)/13) * 13 + 12,
          (nvl(GB.period_net_dr,0)-nvl(GB.period_net_cr,0)) * X_dr_sign, 0)),0),
        nvl(sum(decode(GB.period_num,
          floor((X_start_period_num-1)/13) * 13 + 13,
          (nvl(GB.period_net_dr,0)-nvl(GB.period_net_cr,0)) * X_dr_sign, 0)),0)
      INTO X_old_period1_amount, X_old_period2_amount, X_old_period3_amount,
           X_old_period4_amount, X_old_period5_amount, X_old_period6_amount,
           X_old_period7_amount, X_old_period8_amount, X_old_period9_amount,
           X_old_period10_amount, X_old_period11_amount, X_old_period12_amount,
           X_old_period13_amount
      FROM GL_BALANCES GB
      WHERE GB.ledger_id (+) = X_ledger_id
      AND   GB.code_combination_id (+) = X_code_combination_id
      AND   GB.currency_code (+) = X_currency_code
      AND   GB.actual_flag (+) = 'B'
      AND   GB.budget_version_id (+) = X_budget_version_id
      AND   GB.period_year (+) = X_period_year
      AND   GB.period_num (+) BETWEEN X_start_period_num
                              AND     X_end_period_num;

    X_period1_amount := X_period1_amount_qry + X_old_period1_amount;
    X_period2_amount := X_period2_amount_qry + X_old_period2_amount;
    X_period3_amount := X_period3_amount_qry + X_old_period3_amount;
    X_period4_amount := X_period4_amount_qry + X_old_period4_amount;
    X_period5_amount := X_period5_amount_qry + X_old_period5_amount;
    X_period6_amount := X_period6_amount_qry + X_old_period6_amount;
    X_period7_amount := X_period7_amount_qry + X_old_period7_amount;
    X_period8_amount := X_period8_amount_qry + X_old_period8_amount;
    X_period9_amount := X_period9_amount_qry + X_old_period9_amount;
    X_period10_amount := X_period10_amount_qry + X_old_period10_amount;
    X_period11_amount := X_period11_amount_qry + X_old_period11_amount;
    X_period12_amount := X_period12_amount_qry + X_old_period12_amount;
    X_period13_amount := X_period13_amount_qry + X_old_period13_amount;

    -- here we are calling add_approved_budget_amounts depending on
    -- whether BudgetControl is On or Off
    IF (X_bc_on = 'Y') THEN
          glf02220_pkg.add_approved_budget_amounts( X_ledger_id,
                                                X_code_combination_id,
                            		        X_currency_code,
				              	X_budget_version_id,
				              	X_period_year,
                                          	X_start_period_num,
                                          	X_end_period_num,
						X_dr_sign,
                                          	X_period1_amount,
                                          	X_period2_amount,
                                          	X_period3_amount,
                                          	X_period4_amount,
                                          	X_period5_amount,
                                          	X_period6_amount,
                                          	X_period7_amount,
                                          	X_period8_amount,
                                          	X_period9_amount,
                                          	X_period10_amount,
                                          	X_period11_amount,
                                          	X_period12_amount,
  						X_period13_amount,
                                          	X_old_period1_amount,
                                          	X_old_period2_amount,
                                          	X_old_period3_amount,
                                          	X_old_period4_amount,
                                          	X_old_period5_amount,
                                          	X_old_period6_amount,
                                          	X_old_period7_amount,
                                          	X_old_period8_amount,
                                          	X_old_period9_amount,
                                          	X_old_period10_amount,
                                          	X_old_period11_amount,
                                          	X_old_period12_amount,
  						X_old_period13_amount );

    END IF;

   EXCEPTION
    WHEN app_exceptions.application_exception THEN
      RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL', 'GL_UNHANDLED_EXCEPTION');
      fnd_message.set_token('PROCEDURE', 'glf02220_pkg.get_balances_info');
      RAISE;
  END get_balances_info;

  --
  -- PUBLIC PROCEDURES
  --

  PROCEDURE get_period_prompts( X_ledger_id		IN NUMBER,
                           	X_period_year		IN NUMBER,
                           	X_start_period_num 	IN NUMBER,
                           	X_end_period_num	IN NUMBER,
                          	X_period1_name 		IN OUT NOCOPY VARCHAR2,
                          	X_period2_name 		IN OUT NOCOPY VARCHAR2,
                           	X_period3_name      	IN OUT NOCOPY VARCHAR2,
                           	X_period4_name      	IN OUT NOCOPY VARCHAR2,
                           	X_period5_name      	IN OUT NOCOPY VARCHAR2,
                           	X_period6_name      	IN OUT NOCOPY VARCHAR2,
                           	X_period7_name      	IN OUT NOCOPY VARCHAR2,
                           	X_period8_name      	IN OUT NOCOPY VARCHAR2,
                           	X_period9_name      	IN OUT NOCOPY VARCHAR2,
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
                                X_num_adj_per_total	IN OUT NOCOPY NUMBER   ) IS

    CURSOR gpp IS
      SELECT
	     max(decode(PS.period_num,
	       floor((X_start_period_num-1)/13) * 13 + 1, PS.period_name,
	       NULL)),
	     max(decode(PS.period_num,
	       floor((X_start_period_num-1)/13) * 13 + 2, PS.period_name,
	       NULL)),
	     max(decode(PS.period_num,
	       floor((X_start_period_num-1)/13) * 13 + 3, PS.period_name,
	       NULL)),
	     max(decode(PS.period_num,
	       floor((X_start_period_num-1)/13) * 13 + 4, PS.period_name,
	       NULL)),
	     max(decode(PS.period_num,
	       floor((X_start_period_num-1)/13) * 13 + 5, PS.period_name,
	       NULL)),
	     max(decode(PS.period_num,
	       floor((X_start_period_num-1)/13) * 13 + 6, PS.period_name,
	       NULL)),
	     max(decode(PS.period_num,
	       floor((X_start_period_num-1)/13) * 13 + 7, PS.period_name,
	       NULL)),
	     max(decode(PS.period_num,
	       floor((X_start_period_num-1)/13) * 13 + 8, PS.period_name,
	       NULL)),
	     max(decode(PS.period_num,
	       floor((X_start_period_num-1)/13) * 13 + 9, PS.period_name,
	       NULL)),
	     max(decode(PS.period_num,
	       floor((X_start_period_num-1)/13) * 13 + 10, PS.period_name,
	       NULL)),
	     max(decode(PS.period_num,
	       floor((X_start_period_num-1)/13) * 13 + 11, PS.period_name,
	       NULL)),
	     max(decode(PS.period_num,
	       floor((X_start_period_num-1)/13) * 13 + 12, PS.period_name,
	       NULL)),
	     max(decode(PS.period_num,
	       floor((X_start_period_num-1)/13) * 13 + 13, PS.period_name,
	       NULL)),
	     max(decode(PS.period_num,
	       floor((X_start_period_num-1)/13) * 13 + 1, PS.adjustment_period_flag,
	       NULL)),
	     max(decode(PS.period_num,
	       floor((X_start_period_num-1)/13) * 13 + 2, PS.adjustment_period_flag,
	       NULL)),
	     max(decode(PS.period_num,
	       floor((X_start_period_num-1)/13) * 13 + 3, PS.adjustment_period_flag,
	       NULL)),
	     max(decode(PS.period_num,
	       floor((X_start_period_num-1)/13) * 13 + 4, PS.adjustment_period_flag,
	       NULL)),
	     max(decode(PS.period_num,
	       floor((X_start_period_num-1)/13) * 13 + 5, PS.adjustment_period_flag,
	       NULL)),
	     max(decode(PS.period_num,
	       floor((X_start_period_num-1)/13) * 13 + 6, PS.adjustment_period_flag,
	       NULL)),
	     max(decode(PS.period_num,
	       floor((X_start_period_num-1)/13) * 13 + 7, PS.adjustment_period_flag,
	       NULL)),
	     max(decode(PS.period_num,
	       floor((X_start_period_num-1)/13) * 13 + 8, PS.adjustment_period_flag,
	       NULL)),
	     max(decode(PS.period_num,
	       floor((X_start_period_num-1)/13) * 13 + 9, PS.adjustment_period_flag,
	       NULL)),
	     max(decode(PS.period_num,
	       floor((X_start_period_num-1)/13) * 13 + 10, PS.adjustment_period_flag,
	       NULL)),
	     max(decode(PS.period_num,
	       floor((X_start_period_num-1)/13) * 13 + 11, PS.adjustment_period_flag,
	       NULL)),
	     max(decode(PS.period_num,
	       floor((X_start_period_num-1)/13) * 13 + 12, PS.adjustment_period_flag,
	       NULL)),
	     max(decode(PS.period_num,
	       floor((X_start_period_num-1)/13) * 13 + 13, PS.adjustment_period_flag,
	       NULL)),
             sum(decode(PS.adjustment_period_flag,'Y',1,0)),
	     max(PS.application_id)
      FROM
	     GL_PERIOD_STATUSES PS
      WHERE
	     PS.application_id = 101
	 AND PS.ledger_id = X_ledger_id
	 AND PS.period_year = X_period_year
	 AND PS.period_num BETWEEN X_start_period_num and X_end_period_num;

    dummy	NUMBER := NULL;	  -- for testing NO_DATA_FOUND only

  BEGIN
    OPEN gpp;
    FETCH gpp INTO X_period1_name,
		   X_period2_name,
		   X_period3_name,
		   X_period4_name,
		   X_period5_name,
		   X_period6_name,
		   X_period7_name,
		   X_period8_name,
		   X_period9_name,
		   X_period10_name,
		   X_period11_name,
		   X_period12_name,
		   X_period13_name,
                   X_adj_period1_flag,
		   X_adj_period2_flag,
		   X_adj_period3_flag,
		   X_adj_period4_flag,
		   X_adj_period5_flag,
		   X_adj_period6_flag,
		   X_adj_period7_flag,
		   X_adj_period8_flag,
		   X_adj_period9_flag,
		   X_adj_period10_flag,
		   X_adj_period11_flag,
		   X_adj_period12_flag,
		   X_adj_period13_flag,
                   X_num_adj_per_in_range,
		   dummy;
    CLOSE gpp;

    -- Check explicitly here for null row returned, i.e. NO_DATA_FOUND,
    -- since the group function always returns at least one row
    IF (dummy IS NULL) THEN
      RAISE NO_DATA_FOUND;
    END IF;

    SELECT
           count(*),
           nvl(sum(decode(sign(X_start_period_num-period_num),1,1,0)),0)
    INTO   X_num_adj_per_total,X_num_adj_per_before
    FROM
           GL_PERIOD_STATUSES PS
    WHERE
        PS.application_id = 101
    AND PS.ledger_id = X_ledger_id
    AND PS.period_year = X_period_year
    AND PS.adjustment_period_flag = 'Y';


  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      fnd_message.set_name('SQLGL', 'GL_BUD_PERIODS_NOTFOUND');
      fnd_message.set_token('FUNCTION', 'glf02220_pkg.get_period_prompts',
			    FALSE);
      app_exception.raise_exception;
    WHEN OTHERS THEN
      app_exception.raise_exception;

  END get_period_prompts;


  PROCEDURE add_approved_budget_amounts(
		X_ledger_id                  IN NUMBER,
		X_code_combination_id     IN NUMBER,
		X_currency_code           IN VARCHAR2,
		X_budget_version_id       IN NUMBER,
		X_period_year             IN NUMBER,
		X_start_period_num        IN NUMBER,
		X_end_period_num	  IN NUMBER,
		X_dr_sign		  IN NUMBER,
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
		X_old_period13_amount     IN OUT NOCOPY NUMBER ) IS
    amt1  NUMBER;
    amt2  NUMBER;
    amt3  NUMBER;
    amt4  NUMBER;
    amt5  NUMBER;
    amt6  NUMBER;
    amt7  NUMBER;
    amt8  NUMBER;
    amt9  NUMBER;
    amt10 NUMBER;
    amt11 NUMBER;
    amt12 NUMBER;
    amt13 NUMBER;

    X_found_amounts NUMBER;
  BEGIN
    get_approved_budget_amounts( X_ledger_id,
				 X_code_combination_id,
				 X_currency_code,
				 'B',
		   		 X_budget_version_id,
		   		 X_period_year,
				 X_start_period_num,
				 X_end_period_num,
				 X_dr_sign,
				 X_found_amounts,
				 amt1,
				 amt2,
				 amt3,
				 amt4,
				 amt5,
				 amt6,
				 amt7,
				 amt8,
				 amt9,
				 amt10,
				 amt11,
				 amt12,
				 amt13);

    X_period1_amount := X_period1_amount + amt1;
    X_period2_amount := X_period2_amount + amt2;
    X_period3_amount := X_period3_amount + amt3;
    X_period4_amount := X_period4_amount + amt4;
    X_period5_amount := X_period5_amount + amt5;
    X_period6_amount := X_period6_amount + amt6;
    X_period7_amount := X_period7_amount + amt7;
    X_period8_amount := X_period8_amount + amt8;
    X_period9_amount := X_period9_amount + amt9;
    X_period10_amount := X_period10_amount + amt10;
    X_period11_amount := X_period11_amount + amt11;
    X_period12_amount := X_period12_amount + amt12;
    X_period13_amount := X_period13_amount + amt13;
    X_old_period1_amount := X_old_period1_amount + amt1;
    X_old_period2_amount := X_old_period2_amount + amt2;
    X_old_period3_amount := X_old_period3_amount + amt3;
    X_old_period4_amount := X_old_period4_amount + amt4;
    X_old_period5_amount := X_old_period5_amount + amt5;
    X_old_period6_amount := X_old_period6_amount + amt6;
    X_old_period7_amount := X_old_period7_amount + amt7;
    X_old_period8_amount := X_old_period8_amount + amt8;
    X_old_period9_amount := X_old_period9_amount + amt9;
    X_old_period10_amount := X_old_period10_amount + amt10;
    X_old_period11_amount := X_old_period11_amount + amt11;
    X_old_period12_amount := X_old_period12_amount + amt12;
    X_old_period13_amount := X_old_period13_amount + amt13;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      NULL;
    WHEN OTHERS THEN
      app_exception.raise_exception;

  END add_approved_budget_amounts;


  PROCEDURE get_brule_budget_amounts(
		X_budget_rule		IN VARCHAR2,
		X_rule_amount		IN NUMBER,
		X_status_number		IN NUMBER,
		X_ledger_id                IN NUMBER,
		X_bc_on			IN VARCHAR2,
		X_code_combination_id   IN NUMBER,
		X_currency_code         IN VARCHAR2,
		X_budget_version_id     IN NUMBER,
		X_period_year           IN NUMBER,
		X_start_period_num      IN NUMBER,
		X_end_period_num	IN NUMBER,
		X_dr_sign		IN NUMBER,
		X_period1_amount        IN OUT NOCOPY NUMBER,
		X_period2_amount        IN OUT NOCOPY NUMBER,
		X_period3_amount        IN OUT NOCOPY NUMBER,
		X_period4_amount        IN OUT NOCOPY NUMBER,
		X_period5_amount        IN OUT NOCOPY NUMBER,
		X_period6_amount        IN OUT NOCOPY NUMBER,
		X_period7_amount        IN OUT NOCOPY NUMBER,
		X_period8_amount        IN OUT NOCOPY NUMBER,
		X_period9_amount        IN OUT NOCOPY NUMBER,
		X_period10_amount       IN OUT NOCOPY NUMBER,
		X_period11_amount       IN OUT NOCOPY NUMBER,
		X_period12_amount       IN OUT NOCOPY NUMBER,
		X_period13_amount       IN OUT NOCOPY NUMBER ) IS

    -- hold defined currency
    defined_currency GL_BALANCES.currency_code%TYPE;

    CURSOR gbi IS
      SELECT
	sum(decode(GB.period_num,
	  floor((X_start_period_num-1)/13) * 13 + 1,
	  (nvl(GB.period_net_dr,0)-nvl(GB.period_net_cr,0)) * X_dr_sign, 0)) +
	  max(nvl(BI.period1_amount,0)-nvl(BI.old_period1_amount,0)),
	sum(decode(GB.period_num,
	  floor((X_start_period_num-1)/13) * 13 + 2,
	  (nvl(GB.period_net_dr,0)-nvl(GB.period_net_cr,0)) * X_dr_sign, 0)) +
	  max(nvl(BI.period2_amount,0)-nvl(BI.old_period2_amount,0)),
	sum(decode(GB.period_num,
	  floor((X_start_period_num-1)/13) * 13 + 3,
	  (nvl(GB.period_net_dr,0)-nvl(GB.period_net_cr,0)) * X_dr_sign, 0)) +
	  max(nvl(BI.period3_amount,0)-nvl(BI.old_period3_amount,0)),
	sum(decode(GB.period_num,
	  floor((X_start_period_num-1)/13) * 13 + 4,
	  (nvl(GB.period_net_dr,0)-nvl(GB.period_net_cr,0)) * X_dr_sign, 0)) +
	  max(nvl(BI.period4_amount,0)-nvl(BI.old_period4_amount,0)),
	sum(decode(GB.period_num,
	  floor((X_start_period_num-1)/13) * 13 + 5,
	  (nvl(GB.period_net_dr,0)-nvl(GB.period_net_cr,0)) * X_dr_sign, 0)) +
	  max(nvl(BI.period5_amount,0)-nvl(BI.old_period5_amount,0)),
	sum(decode(GB.period_num,
	  floor((X_start_period_num-1)/13) * 13 + 6,
	  (nvl(GB.period_net_dr,0)-nvl(GB.period_net_cr,0)) * X_dr_sign, 0)) +
	  max(nvl(BI.period6_amount,0)-nvl(BI.old_period6_amount,0)),
	sum(decode(GB.period_num,
	  floor((X_start_period_num-1)/13) * 13 + 7,
	  (nvl(GB.period_net_dr,0)-nvl(GB.period_net_cr,0)) * X_dr_sign, 0)) +
	  max(nvl(BI.period7_amount,0)-nvl(BI.old_period7_amount,0)),
	sum(decode(GB.period_num,
	  floor((X_start_period_num-1)/13) * 13 + 8,
	  (nvl(GB.period_net_dr,0)-nvl(GB.period_net_cr,0)) * X_dr_sign, 0)) +
	  max(nvl(BI.period8_amount,0)-nvl(BI.old_period8_amount,0)),
	sum(decode(GB.period_num,
	  floor((X_start_period_num-1)/13) * 13 + 9,
	  (nvl(GB.period_net_dr,0)-nvl(GB.period_net_cr,0)) * X_dr_sign, 0)) +
	  max(nvl(BI.period9_amount,0)-nvl(BI.old_period9_amount,0)),
	sum(decode(GB.period_num,
	  floor((X_start_period_num-1)/13) * 13 + 10,
	  (nvl(GB.period_net_dr,0)-nvl(GB.period_net_cr,0)) * X_dr_sign, 0)) +
	  max(nvl(BI.period10_amount,0)-nvl(BI.old_period10_amount,0)),
	sum(decode(GB.period_num,
	  floor((X_start_period_num-1)/13) * 13 + 11,
	  (nvl(GB.period_net_dr,0)-nvl(GB.period_net_cr,0)) * X_dr_sign, 0)) +
	  max(nvl(BI.period11_amount,0)-nvl(BI.old_period11_amount,0)),
	sum(decode(GB.period_num,
	  floor((X_start_period_num-1)/13) * 13 + 12,
	  (nvl(GB.period_net_dr,0)-nvl(GB.period_net_cr,0)) * X_dr_sign, 0)) +
	  max(nvl(BI.period12_amount,0)-nvl(BI.old_period12_amount,0)),
	sum(decode(GB.period_num,
	  floor((X_start_period_num-1)/13) * 13 + 13,
	  (nvl(GB.period_net_dr,0)-nvl(GB.period_net_cr,0)) * X_dr_sign, 0)) +
	  max(nvl(BI.period13_amount,0)-nvl(BI.old_period13_amount,0)),
	decode(max(nvl(GB.rowid, BI.rowid)), null, 0, 1)
      FROM
        GL_CODE_COMBINATIONS CC,
	GL_BALANCES GB,
	GL_BUDGET_RANGE_INTERIM BI
      WHERE CC.code_combination_id = X_code_combination_id
      AND   GB.ledger_id (+) = X_ledger_id
      AND   GB.code_combination_id (+) = CC.code_combination_id
      AND   GB.currency_code (+) = defined_currency
      AND   GB.actual_flag (+) = 'B'
      AND   GB.budget_version_id (+) = X_budget_version_id
      AND   GB.period_year (+) = X_period_year -
				   decode(X_budget_rule,
					  'PYBS', 1,
					  'PYBM', 1,
					  0)
      AND   GB.period_num (+) BETWEEN X_start_period_num
			      AND     X_end_period_num
/* */
      AND   BI.ledger_id (+) = X_ledger_id
      AND   BI.code_combination_id (+) = CC.code_combination_id
      AND   BI.currency_code (+) = defined_currency
      AND   BI.budget_version_id (+) = X_budget_version_id
      AND   BI.period_year (+) = X_period_year -
				   decode(X_budget_rule,
					  'PYBS', 1,
					  'PYBM', 1,
					  0)
      AND   BI.start_period_num (+) = X_start_period_num
      AND   BI.status_number(+) = X_status_number;

    p1_amount	NUMBER := 0;
    p2_amount	NUMBER := 0;
    p3_amount	NUMBER := 0;
    p4_amount	NUMBER := 0;
    p5_amount	NUMBER := 0;
    p6_amount	NUMBER := 0;
    p7_amount	NUMBER := 0;
    p8_amount	NUMBER := 0;
    p9_amount	NUMBER := 0;
    p10_amount	NUMBER := 0;
    p11_amount	NUMBER := 0;
    p12_amount	NUMBER := 0;
    p13_amount	NUMBER := 0;

    /* Keep track of whether or not balance and
       funds reservation data was found */
    bal_data_found NUMBER := 0;
    res_data_found NUMBER := 0;

    -- variables for keeping temporary values of X_periodi_amount
    p_period1_amount	NUMBER;
    p_period2_amount	NUMBER;
    p_period3_amount	NUMBER;
    p_period4_amount	NUMBER;
    p_period5_amount	NUMBER;
    p_period6_amount	NUMBER;
    p_period7_amount	NUMBER;
    p_period8_amount	NUMBER;
    p_period9_amount	NUMBER;
    p_period10_amount	NUMBER;
    p_period11_amount	NUMBER;
    p_period12_amount	NUMBER;
    p_period13_amount	NUMBER;

    eff_period_year 	NUMBER := X_period_year;

  BEGIN

   -- define currency code to pass to get_approved_budget_amounts
    IF (X_budget_rule = 'PYBS'  OR X_budget_rule = 'CYBS') THEN
       defined_currency := 'STAT';
    ELSE
       defined_currency := X_currency_code;
    END IF;

    OPEN gbi;
    FETCH gbi INTO p_period1_amount,
		   p_period2_amount,
		   p_period3_amount,
		   p_period4_amount,
		   p_period5_amount,
		   p_period6_amount,
		   p_period7_amount,
		   p_period8_amount,
		   p_period9_amount,
		   p_period10_amount,
		   p_period11_amount,
		   p_period12_amount,
		   p_period13_amount,
		   bal_data_found;
    CLOSE gbi;

    -- Add the reserved amounts, if necessary.
    IF (X_bc_on = 'Y') THEN
      IF (X_budget_rule IN ('PYBS', 'PYBM')) THEN
	eff_period_year := X_period_year - 1;
      END IF;
      get_approved_budget_amounts( X_ledger_id,
				   X_code_combination_id,
				   defined_currency,
				   'B',
		   		   X_budget_version_id,
				   eff_period_year,
				   X_start_period_num,
				   X_end_period_num,
				   X_dr_sign,
				   res_data_found,
				   p1_amount,
				   p2_amount,
				   p3_amount,
				   p4_amount,
				   p5_amount,
				   p6_amount,
				   p7_amount,
				   p8_amount,
				   p9_amount,
				   p10_amount,
				   p11_amount,
				   p12_amount,
				   p13_amount);

    END IF;

    -- If no data has been found, then error out.
    IF (    (bal_data_found = 0)
	AND (res_data_found = 0)
       ) THEN
      RAISE No_Data_Found;
    END IF;

    -- Calculate the new amounts and put the resilts into the temporary variables
    p_period1_amount := round(  (  nvl(p_period1_amount, 0)
				 + nvl(p1_amount, 0))
                              * X_rule_amount, 2);
    p_period2_amount := round(  (  nvl(p_period2_amount, 0)
				 + nvl(p2_amount, 0))
			      * X_rule_amount, 2);
    p_period3_amount := round(  (  nvl(p_period3_amount, 0)
				 + nvl(p3_amount, 0))
			      * X_rule_amount, 2);
    p_period4_amount := round(  (  nvl(p_period4_amount, 0)
				 + nvl(p4_amount, 0))
			      * X_rule_amount, 2);
    p_period5_amount := round(  (  nvl(p_period5_amount, 0)
				 + nvl(p5_amount, 0))
			      * X_rule_amount, 2);
    p_period6_amount := round(  (  nvl(p_period6_amount, 0)
				 + nvl(p6_amount, 0))
			      * X_rule_amount, 2);
    p_period7_amount := round(  (  nvl(p_period7_amount, 0)
				 + nvl(p7_amount, 0))
			      * X_rule_amount, 2);
    p_period8_amount := round(  (  nvl(p_period8_amount, 0)
				 + nvl(p8_amount, 0))
			      * X_rule_amount, 2);
    p_period9_amount := round(  (  nvl(p_period9_amount, 0)
				 + nvl(p9_amount, 0))
			      * X_rule_amount, 2);
    p_period10_amount := round(  (  nvl(p_period10_amount, 0)
				  + nvl(p10_amount, 0))
			      * X_rule_amount, 2);
    p_period11_amount := round(  (  nvl(p_period11_amount, 0)
				  + nvl(p11_amount, 0))
			      * X_rule_amount, 2);
    p_period12_amount := round(  (  nvl(p_period12_amount, 0)
				  + nvl(p12_amount, 0))
			      * X_rule_amount, 2);
    p_period13_amount := round(  (  nvl(p_period13_amount, 0)
				  + nvl(p13_amount, 0))
			      * X_rule_amount, 2);

    -- if at least one the temporary variables exceeds the maximum allowed
    -- (by FORMS implemetation) value, give a message and leave old values
    IF(	p_period1_amount > maximum_allowed_amount_value OR
	p_period2_amount > maximum_allowed_amount_value OR
	p_period3_amount > maximum_allowed_amount_value OR
	p_period4_amount > maximum_allowed_amount_value OR
	p_period5_amount > maximum_allowed_amount_value OR
	p_period6_amount > maximum_allowed_amount_value OR
	p_period7_amount > maximum_allowed_amount_value OR
	p_period8_amount > maximum_allowed_amount_value OR
	p_period9_amount > maximum_allowed_amount_value OR
	p_period10_amount > maximum_allowed_amount_value OR
	p_period11_amount > maximum_allowed_amount_value OR
	p_period12_amount > maximum_allowed_amount_value OR
	p_period13_amount > maximum_allowed_amount_value
     ) THEN
      fnd_message.set_name('SQLGL', 'GL_BUD_RULE_TOO_BIG_AMOUNT');
      app_exception.raise_exception;
     ELSE
        X_period1_amount := p_period1_amount;
        X_period2_amount := p_period2_amount;
        X_period3_amount := p_period3_amount;
        X_period4_amount := p_period4_amount;
        X_period5_amount := p_period5_amount;
        X_period6_amount := p_period6_amount;
        X_period7_amount := p_period7_amount;
        X_period8_amount := p_period8_amount;
        X_period9_amount := p_period9_amount;
        X_period10_amount := p_period10_amount;
        X_period11_amount := p_period11_amount;
        X_period12_amount := p_period12_amount;
        X_period13_amount := p_period13_amount;
     END IF;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      fnd_message.set_name('SQLGL', 'GL_BUD_RULE_NO_DATA_FOUND');
      app_exception.raise_exception;
    WHEN OTHERS THEN
      app_exception.raise_exception;

  END get_brule_budget_amounts;


  PROCEDURE get_brule_actual_amounts(
		X_budget_rule		IN VARCHAR2,
		X_rule_amount		IN NUMBER,
		X_ledger_id                IN NUMBER,
		X_bc_on			IN VARCHAR2,
		X_code_combination_id   IN NUMBER,
		X_currency_code         IN VARCHAR2,
		X_budget_version_id     IN NUMBER,
		X_period_year           IN NUMBER,
		X_start_period_num      IN NUMBER,
		X_end_period_num       	IN NUMBER,
		X_dr_sign		IN NUMBER,
		X_period1_amount        IN OUT NOCOPY NUMBER,
		X_period2_amount        IN OUT NOCOPY NUMBER,
		X_period3_amount        IN OUT NOCOPY NUMBER,
		X_period4_amount        IN OUT NOCOPY NUMBER,
		X_period5_amount        IN OUT NOCOPY NUMBER,
		X_period6_amount        IN OUT NOCOPY NUMBER,
		X_period7_amount        IN OUT NOCOPY NUMBER,
		X_period8_amount        IN OUT NOCOPY NUMBER,
		X_period9_amount        IN OUT NOCOPY NUMBER,
		X_period10_amount       IN OUT NOCOPY NUMBER,
		X_period11_amount       IN OUT NOCOPY NUMBER,
		X_period12_amount       IN OUT NOCOPY NUMBER,
		X_period13_amount       IN OUT NOCOPY NUMBER ) IS

    CURSOR gbl IS
      SELECT
	sum(decode(GB.period_num,
	    floor((X_start_period_num-1)/13) * 13 + 1,
	    (nvl(GB.period_net_dr,0)-nvl(GB.period_net_cr,0)) * X_dr_sign,0)),
	sum(decode(GB.period_num,
	    floor((X_start_period_num-1)/13) * 13 + 2,
	    (nvl(GB.period_net_dr,0)-nvl(GB.period_net_cr,0)) * X_dr_sign,0)),
	sum(decode(GB.period_num,
	    floor((X_start_period_num-1)/13) * 13 + 3,
	    (nvl(GB.period_net_dr,0)-nvl(GB.period_net_cr,0)) * X_dr_sign,0)),
	sum(decode(GB.period_num,
	    floor((X_start_period_num-1)/13) * 13 + 4,
	    (nvl(GB.period_net_dr,0)-nvl(GB.period_net_cr,0)) * X_dr_sign,0)),
	sum(decode(GB.period_num,
	    floor((X_start_period_num-1)/13) * 13 + 5,
	    (nvl(GB.period_net_dr,0)-nvl(GB.period_net_cr,0)) * X_dr_sign,0)),
	sum(decode(GB.period_num,
	    floor((X_start_period_num-1)/13) * 13 + 6,
	    (nvl(GB.period_net_dr,0)-nvl(GB.period_net_cr,0)) * X_dr_sign,0)),
	sum(decode(GB.period_num,
	    floor((X_start_period_num-1)/13) * 13 + 7,
	    (nvl(GB.period_net_dr,0)-nvl(GB.period_net_cr,0)) * X_dr_sign,0)),
	sum(decode(GB.period_num,
	    floor((X_start_period_num-1)/13) * 13 + 8,
	    (nvl(GB.period_net_dr,0)-nvl(GB.period_net_cr,0)) * X_dr_sign,0)),
	sum(decode(GB.period_num,
	    floor((X_start_period_num-1)/13) * 13 + 9,
	    (nvl(GB.period_net_dr,0)-nvl(GB.period_net_cr,0)) * X_dr_sign,0)),
	sum(decode(GB.period_num,
            floor((X_start_period_num-1)/13) * 13 + 10,
	    (nvl(GB.period_net_dr,0)-nvl(GB.period_net_cr,0)) * X_dr_sign,0)),
	sum(decode(GB.period_num,
	    floor((X_start_period_num-1)/13) * 13 + 11,
	    (nvl(GB.period_net_dr,0)-nvl(GB.period_net_cr,0)) * X_dr_sign,0)),
	sum(decode(GB.period_num,
	    floor((X_start_period_num-1)/13) * 13 + 12,
	    (nvl(GB.period_net_dr,0)-nvl(GB.period_net_cr,0)) * X_dr_sign,0)),
	sum(decode(GB.period_num,
	    floor((X_start_period_num-1)/13) * 13 + 13,
	    (nvl(GB.period_net_dr,0)-nvl(GB.period_net_cr,0)) * X_dr_sign,0)),
	decode(max(GB.rowid), null, 0, 1)
      FROM
	     GL_BALANCES GB
      WHERE
	     GB.ledger_id = X_ledger_id
	 AND GB.code_combination_id = X_code_combination_id
	 AND GB.currency_code = decode(X_budget_rule,
				  'PYAS', 'STAT', 'CYAS', 'STAT',
				  X_currency_code)
	 AND GB.actual_flag = 'A'
	 AND GB.period_year = X_period_year -
				decode(X_budget_rule, 'PYAS', 1, 'PYAM', 1, 0)
	 AND GB.period_num BETWEEN X_start_period_num AND X_end_period_num
	 AND nvl(GB.translated_flag, 'R') NOT IN ('Y', 'N');

    p1_amount	NUMBER := 0;
    p2_amount	NUMBER := 0;
    p3_amount	NUMBER := 0;
    p4_amount	NUMBER := 0;
    p5_amount	NUMBER := 0;
    p6_amount	NUMBER := 0;
    p7_amount	NUMBER := 0;
    p8_amount	NUMBER := 0;
    p9_amount	NUMBER := 0;
    p10_amount	NUMBER := 0;
    p11_amount	NUMBER := 0;
    p12_amount	NUMBER := 0;
    p13_amount	NUMBER := 0;


    /* Keep track of whether or not balance and
       funds reservation data was found */
    bal_data_found  NUMBER := 0;
    res_data_found  NUMBER := 0;

    eff_period_year NUMBER := X_period_year;

  BEGIN

    OPEN gbl;
    FETCH gbl INTO X_period1_amount,
		   X_period2_amount,
		   X_period3_amount,
		   X_period4_amount,
		   X_period5_amount,
		   X_period6_amount,
		   X_period7_amount,
		   X_period8_amount,
		   X_period9_amount,
		   X_period10_amount,
		   X_period11_amount,
		   X_period12_amount,
		   X_period13_amount,
		   bal_data_found;
    CLOSE gbl;

    -- Add the reserved amounts, if necessary.
    IF (X_bc_on = 'Y') THEN
      IF (X_budget_rule IN ('PYAS', 'PYAM')) THEN
	eff_period_year := X_period_year - 1;
      END IF;
      get_approved_budget_amounts( X_ledger_id,
				   X_code_combination_id,
				   X_currency_code,
				   'A',
		   		   -1,
				   eff_period_year,
				   X_start_period_num,
				   X_end_period_num,
				   X_dr_sign,
				   res_data_found,
				   p1_amount,
				   p2_amount,
				   p3_amount,
				   p4_amount,
				   p5_amount,
				   p6_amount,
				   p7_amount,
				   p8_amount,
				   p9_amount,
				   p10_amount,
				   p11_amount,
				   p12_amount,
				   p13_amount);
    END IF;

    -- If no data has been found, then error out.
    IF (    (bal_data_found = 0)
	AND (res_data_found = 0)
       ) THEN
      RAISE No_Data_Found;
    END IF;

    -- Calculate the new amounts
    X_period1_amount := round(  (  nvl(X_period1_amount, 0)
                                 + nvl(p1_amount, 0))
                              * X_rule_amount, 2);
    X_period2_amount := round(  (  nvl(X_period2_amount, 0)
				 + nvl(p2_amount, 0))
			      * X_rule_amount, 2);
    X_period3_amount := round(  (  nvl(X_period3_amount, 0)
  				 + nvl(p3_amount, 0))
			      * X_rule_amount, 2);
    X_period4_amount := round(  (  nvl(X_period4_amount, 0)
				 + nvl(p4_amount, 0))
			      * X_rule_amount, 2);
    X_period5_amount := round(  (  nvl(X_period5_amount, 0)
				 + nvl(p5_amount, 0))
			      * X_rule_amount, 2);
    X_period6_amount := round(  (  nvl(X_period6_amount, 0)
				 + nvl(p6_amount, 0))
			      * X_rule_amount, 2);
    X_period7_amount := round(  (  nvl(X_period7_amount, 0)
				 + nvl(p7_amount, 0))
			      * X_rule_amount, 2);
    X_period8_amount := round(  (  nvl(X_period8_amount, 0)
				 + nvl(p8_amount, 0))
			      * X_rule_amount, 2);
    X_period9_amount := round(  (  nvl(X_period9_amount, 0)
				 + nvl(p9_amount, 0))
			      * X_rule_amount, 2);
    X_period10_amount := round(  (  nvl(X_period10_amount, 0)
				  + nvl(p10_amount, 0))
			      * X_rule_amount, 2);
    X_period11_amount := round(  (  nvl(X_period11_amount, 0)
				  + nvl(p11_amount, 0))
			      * X_rule_amount, 2);
    X_period12_amount := round(  (  nvl(X_period12_amount, 0)
				  + nvl(p12_amount, 0))
			      * X_rule_amount, 2);
    X_period13_amount := round(  (  nvl(X_period13_amount, 0)
				  + nvl(p13_amount, 0))
			      * X_rule_amount, 2);

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      fnd_message.set_name('SQLGL', 'GL_BUD_RULE_NO_DATA_FOUND');
      app_exception.raise_exception;
    WHEN OTHERS THEN
      app_exception.raise_exception;

  END get_brule_actual_amounts;

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
                                        X_currency_code                 VARCHAR2)
  IS
  BEGIN

   IF X_check_is_acct_stat_enterable = 'Y' THEN
      -- Call server side function to check whether you can
      -- enter STAT amount for this account
     IF ( gl_budget_assignment_pkg.is_acct_stat_enterable(
	     X_ledger_id,
	     X_code_combination_id )) THEN
	 X_cc_stat_enterable_flag := 'Y';
      END IF;
   END IF;

   IF X_check_is_account_frozen ='Y' THEN
      -- Call server side function to check whether it's a frozen account
      -- w.r.t. the selected budget and org, if it hasn't been checked before
      -- Bug Fix 3866812
      -- Added X_ledger_id and X_currency_code parameters in the function call
      IF (gl_budget_utils_pkg.frozen_account(X_coa_id,
					     X_budget_version_id,
					     X_budget_entity_id,
					     X_code_combination_id,
                                             X_ledger_id,
					     X_currency_code)) THEN
         X_cc_frozen_flag := 'Y';
      ELSE
	 X_cc_frozen_flag := 'N';
      END IF;
   END IF;

  END DB_get_account_properties;

  PROCEDURE get_cashe_data(     x_ledger_period_type 	IN OUT NOCOPY VARCHAR2,
  				x_num_periods_per_year	IN OUT NOCOPY NUMBER,
  				x_ledger_id 		NUMBER,
  				x_budget_version_id 	IN OUT NOCOPY NUMBER,
                               	x_budget_name 		IN OUT NOCOPY VARCHAR2,
                               	x_bj_required           IN OUT NOCOPY VARCHAR2,
                               	x_coa_id		NUMBER,
                               	x_account_column_name 	IN OUT NOCOPY VARCHAR2
  				) IS
    tmpbuf   VARCHAR2(100);
BEGIN

    -- Initialize num_periods_per_year (for 445/454/544 budget rules)
    gl_period_types_pkg.select_columns(x_ledger_period_type, tmpbuf, tmpbuf,
				       x_num_periods_per_year);
    -- Default Budget Name to current budget
    gl_budget_utils_pkg.get_current_budget(x_ledger_id,
    			       	      	   x_budget_version_id,
   			      	      	   x_budget_name,
    			      	           x_bj_required);
    -- Initialize ACCOUNT segment column name with flex API
    IF ( NOT fnd_flex_apis.get_segment_column( 101,
    					      'GL#',
    					      x_coa_id,
    					      'GL_ACCOUNT',
    					      x_account_column_name )) THEN
      fnd_message.set_name('SQLGL', 'GL_NO_ACCOUNT_SEG_DEFINED');
      app_exception.raise_exception;
    END IF;

    END get_cashe_data;

END glf02220_pkg;

/

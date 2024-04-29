--------------------------------------------------------
--  DDL for Package Body PSP_ST_EXT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSP_ST_EXT" as
/* $Header: PSPTREXB.pls 120.4 2006/12/22 19:35:44 vdharmap noship $ */

 /* PROCEDURE summary_extension AS
 BEGIN
  -- Write the user extension  here
  null;
 END summary_extension;  */


--- 2968684: commented above procedure and created following 4 procedures.
--
-- WARNING:
--         1) Please note that any PL/SQL statements that cause Commit/Rollback
--          are not allowed in the user extension code. Commit/Rollback's
--          will interfere with the Commit cycle of the main
--          process and Restart/Recover process will not work properly.
--
--         2) If you raise user defined exception in any of the user hook (except
--         in function get_enc_amount) please populate the error string g_api_error_path,
--         this helps in trouble shooting in case of problems. See the example code
--          below. You cannot use the variable g_error_api_path in function get_enc_amount,
--          since the variable is not defined in the scope of this function.
--
--          Example code to show usage of "g_error_api_path"
--          Procedure summary_ext_actual
--          -------------------------------------------------------
--                :
--                :
--            if <CONDITION> then
--               raise <USER_DEFINED_EXCEPTION>;
--            end if;
--                :
--                :
--         exception
--           when <USER_DEFINED_EXCEPTION> then
--                psp_sum_trans.g_error_api_path :=  'SUMMARY_EXT_ACTUAL'||psp_sum_trans.g_error_api_path;
--                raise;
--           when others then
--             psp_sum_trans.g_error_api_path := 'SUMMARY_EXT_ACTUAL'||psp_sum_trans.g_error_api_path;
--             fnd_msg_pub.add_exc_msg('PSP_SUM_TRANS','SUMMARY_EXT_ADJUSTMENT');
--             raise;
--          end;
--         ------------------------------------------------------
--
--
--

--====== Extension for Summarize And Transfer Adjustments =======
 procedure summary_ext_adjustment(p_adj_sum_batch_name IN VARCHAR2,
                                  p_business_group_id  IN NUMBER,
                                  p_set_of_books_id    IN NUMBER) as
 begin
    -- Write the user extension code here;
    --
    -- The parameter "p_adj_sum_batch_name" has the batch name entered
    -- while submitting the Summarize and Transfer Adjustments process.
    null;
 exception
   when others then
      psp_sum_adj.g_error_api_path := 'SUMMARY_EXT_ADJUSTMENT'||psp_sum_adj.g_error_api_path;
      fnd_msg_pub.add_exc_msg('PSP_SUM_ADJ','SUMMARY_EXT_ADJUSTMENT');
      raise;
 end;


 ---===== Extension for Summarize and Transfer Payroll Distributions =======
 procedure summary_ext_actual(p_source_type        IN VARCHAR2,
                              p_source_code        IN VARCHAR2,
                              p_payroll_id         IN NUMBER,
                              p_time_period_id     IN NUMBER,
                              p_batch_name         IN VARCHAR2,
                              p_business_group_id  IN NUMBER,
                              p_set_of_books_id    IN NUMBER) as
 begin
   -- Write the user extension code here;
   --
   -- parameters:
   --   p_source_type is 'O' for oracle, 'N' for Non-Oracle, 'P' for Pre-Gen
   --   p_source_code is user defined source code for the source type
   --   p_payroll_id  is payroll id.
   --   p_time_period_id is time period id.
   --   p_batch_name is Non-Oracle or Pre-gen Batch name
   --
   -- WARNING: Only 2 parameters (business group, set of books) are always guaranteed
   --          to be NOT NULL, rest of the paramters may have null values.
   --
   --        For example if user submits the process without entering any parameters,
   --        then only the implicit parameters business group, and set of books are
   --        available, all the remaining parameters have null values.
   --
   --
   null;
 exception
    when others then
      psp_sum_trans.g_error_api_path := 'SUMMARY_EXT_ACTUAL'||psp_sum_trans.g_error_api_path;
      fnd_msg_pub.add_exc_msg('PSP_SUM_TRANS','SUMMARY_EXT_ADJUSTMENT');
      raise;
 end;

 --======= Extension for Summarize and Transfer Encumbrances =====
 procedure summary_ext_encumber(p_payroll_id        IN NUMBER,
                                p_business_group_id IN NUMBER,
                                p_set_of_books_id   IN NUMBER) as
 begin
   -- Write the user extension code here;
   null;
 exception
   when others then
      psp_enc_sum_tran.g_error_api_path := 'SUMMARY_EXT_ENCUMBER'||psp_enc_sum_tran.g_error_api_path;
      fnd_msg_pub.add_exc_msg('PSP_ENC_SUM_TRAN','SUMMARY_EXT_ENCUMBER');
      raise;
 end;

 --====== Extension for Encumbrance Liquidation ==============
 procedure summary_ext_encumber_liq(p_payroll_id        IN  NUMBER,
                                    p_action_type       IN VARCHAR2,
                                    p_business_group_id IN NUMBER,
                                    p_set_of_books_id   IN NUMBER) as
 begin
   -- Write the user extension code here;
   --
   -- parameter p_action_type has value L for Liquidation,
   --                                   U if Liquidation is called from Update Encumbrance
   --                                   Q if Liquidation is called from Quick Update Encumbrance
   null;
 exception
   when others then
      psp_enc_liq_tran.g_error_api_path := 'SUMMARY_EXT_ENCUMBER_LIQ'||psp_enc_liq_tran.g_error_api_path;
      fnd_msg_pub.add_exc_msg('PSP_ENC_LIQ_TRAN','SUMMARY_EXT_ENCUMBER_LIQ');
      raise;
 end;


FUNCTION 	get_enc_amount( p_assignment_id 	IN 	NUMBER ,
			        p_element_type_id	IN	NUMBER,
			        p_time_period_id 	IN	NUMBER,
   	        		p_asg_start_date	IN	DATE,
       			        p_asg_end_date		IN	DATE )

   return NUMBER IS
   BEGIN
    	Return (0);
    	 -- Write the user extension  here
   	 -- It is mandatory for the function to return a NOT NULL value.
   exception
       when others then
          fnd_msg_pub.add_exc_msg('PSP_ENC_LIQ_TRAN','SUMMARY_EXT_ENCUMBER_LIQ');
          raise;
   END get_enc_amount;


PROCEDURE get_labor_enc_dates	(p_project_id			IN	NUMBER,
				p_task_id			IN	NUMBER,
				p_award_id			IN	NUMBER,
				p_expenditure_type		IN	VARCHAR2,
				p_expenditure_organization_id	IN	NUMBER,
				p_payroll_id			IN	NUMBER,
				p_start_date			OUT NOCOPY	DATE,
				p_end_date			OUT NOCOPY	DATE) IS
BEGIN
	p_start_date := fnd_date.canonical_to_date('1800/01/01');
	p_end_date := fnd_date.canonical_to_date('4712/12/31');
END get_labor_enc_dates;

--- added following procedure for 5643110
PROCEDURE tieback_actual(p_payroll_control_id   IN  NUMBER,
                        p_source_type        IN  VARCHAR2,
                        p_period_end_date    IN  DATE,
                        p_gms_batch_name     IN  VARCHAR2,
                        p_txn_source         in varchar2,
                        p_business_group_id  IN NUMBER,
                        p_set_of_books_id    IN NUMBER) is
 begin
   -- Write the user extension code here;
   --
   null;
 exception
    when others then
      psp_sum_trans.g_error_api_path := 'TIEBACK_ACTUAL'||psp_sum_trans.g_error_api_path;
      fnd_msg_pub.add_exc_msg('PSP_SUM_TRANS','TIEBACK_ACTUAL');
      raise;
 end;
/*
 --- following code is for Award Funding pattern implementation in LD.
  -- this code should be moved into the tieback_actual procedure.

 l_default_dist_award_id NUMBER;
 l_summary_line_id       NUMBER;
 l_sum_summary_amt       NUMBER;
 l_sum_dist_amt          NUMBER;
 l_pg_summary_line_id    NUMBER;
 l_pg_sum_summary_amt    NUMBER;
 l_pg_sum_dist_amt       NUMBER;

 -- get the summary_line_id's where distribution amount does not match with summary amount
 CURSOR get_unmatched_summary_lines is
 SELECT pdl.summary_line_id, psl.summary_amount,
sum(pdl.distribution_amount)
 FROM psp_distribution_lines pdl,
      psp_summary_lines psl
 WHERE pdl.summary_line_id = psl.summary_line_id
 AND  psl.payroll_control_id = p_payroll_control_id
 AND  psl.status_code = 'N'
 AND  psl.attribute29 is not null
 ANd  psl.attribute30 is not null
 GROUP BY pdl.summary_line_id, psl.summary_amount
 HAVING summary_amount - sum(distribution_amount) <> 0;

 -- get the summary_line_id's where pre gen distribution amount does not match with summary amount
 CURSOR get_unmatched_pg_summary_lines is
 SELECT ppgl.summary_line_id, psl.summary_amount,
sum(ppgl.distribution_amount)
 FROM psp_pre_gen_dist_lines ppgl,
      psp_summary_lines psl
 WHERE ppgl.summary_line_id = psl.summary_line_id
 AND  psl.payroll_control_id = p_payroll_control_id
 AND  psl.status_code = 'N'
 AND  psl.attribute29 is not null
 ANd  psl.attribute30 is not null
 GROUP BY ppgl.summary_line_id, psl.summary_amount
 HAVING summary_amount - sum(distribution_amount) <> 0;

 CURSOR get_unmatched_summary_splits is
 SELECT to_number(attribute30) old_summary_amount,
        attribute29 old_summary_line_id,
        sum(summary_amount) new_summary_amount,
        max(summary_line_id) new_summary_line_id
   FROM psp_summary_lines
  WHERE attribute29 is not null
    AND attribute30 is not null
    AND gms_batch_name = p_gms_batch_name
    AND status_code <> 'S'
  GROUP BY attribute29, attribute30
  HAVING sum(summary_amount) <> to_number(attribute30);

 summary_split_rec get_unmatched_summary_splits%rowtype;

BEGIN

SELECT default_dist_award_id
INTO   l_default_dist_award_id
FROM   gms_implementations;

-- create new summary lines from PA/GMS interface table for award distribution lines
hr_utility.trace('Actual Tieback userhook before inserting into Summary lines');

INSERT INTO psp_summary_lines
( SUMMARY_LINE_ID,
SOURCE_TYPE,
SOURCE_CODE,
TIME_PERIOD_ID,
INTERFACE_BATCH_NAME,
PERSON_ID,
ASSIGNMENT_ID,
EFFECTIVE_DATE,
PAYROLL_CONTROL_ID,
GL_CODE_COMBINATION_ID,
PROJECT_ID,
EXPENDITURE_ORGANIZATION_ID,
EXPENDITURE_TYPE,
TASK_ID,
AWARD_ID,
SUMMARY_AMOUNT,
DR_CR_FLAG,
GROUP_ID,
INTERFACE_STATUS,
ATTRIBUTE_CATEGORY,
ATTRIBUTE1,
ATTRIBUTE2,
ATTRIBUTE3,
ATTRIBUTE4,
ATTRIBUTE5,
ATTRIBUTE6,
ATTRIBUTE7,
ATTRIBUTE8,
ATTRIBUTE9,
ATTRIBUTE10,
ATTRIBUTE11,
ATTRIBUTE12,
ATTRIBUTE13,
ATTRIBUTE14,
ATTRIBUTE15,
ATTRIBUTE16,
ATTRIBUTE17,
ATTRIBUTE18,
ATTRIBUTE19,
ATTRIBUTE20,
ATTRIBUTE21,
ATTRIBUTE22,
ATTRIBUTE23,
ATTRIBUTE24,
ATTRIBUTE25,
ATTRIBUTE26,
ATTRIBUTE27,
ATTRIBUTE28,
ATTRIBUTE29,
ATTRIBUTE30,
LAST_UPDATE_DATE,
LAST_UPDATED_BY,
LAST_UPDATE_LOGIN,
CREATED_BY,
CREATION_DATE,
SET_OF_BOOKS_ID,
BUSINESS_GROUP_ID,
STATUS_CODE,
GMS_BATCH_NAME,
GMS_POSTING_EFFECTIVE_DATE,
EXPENDITURE_ENDING_DATE ,
EXPENDITURE_ID,
INTERFACE_ID,
EXPENDITURE_ITEM_ID,
TXN_INTERFACE_ID,
ACTUAL_SUMMARY_AMOUNT,
ACCOUNTING_DATE,
EXCHANGE_RATE_TYPE)
SELECT
PSP_SUMMARY_LINES_S.NEXTVAL,
psl.SOURCE_TYPE,
psl.SOURCE_CODE,
psl.TIME_PERIOD_ID,
psl.INTERFACE_BATCH_NAME,
psl.PERSON_ID,
psl.ASSIGNMENT_ID,
psl.EFFECTIVE_DATE,
psl.PAYROLL_CONTROL_ID,
psl.GL_CODE_COMBINATION_ID,
psl.PROJECT_ID,
psl.EXPENDITURE_ORGANIZATION_ID,
psl.EXPENDITURE_TYPE,
psl.TASK_ID,
gti.AWARD_ID,
pti.denom_raw_cost,      -- putting new value in the summary_amount column
psl.DR_CR_FLAG,
psl.GROUP_ID,
psl.INTERFACE_STATUS,
psl.ATTRIBUTE_CATEGORY,
psl.ATTRIBUTE1,
psl.ATTRIBUTE2,
psl.ATTRIBUTE3,
psl.ATTRIBUTE4,
psl.ATTRIBUTE5,
psl.ATTRIBUTE6,
psl.ATTRIBUTE7,
psl.ATTRIBUTE8,
psl.ATTRIBUTE9,
psl.ATTRIBUTE10,
psl.ATTRIBUTE11,
psl.ATTRIBUTE12,
psl.ATTRIBUTE13,
psl.ATTRIBUTE14,
psl.ATTRIBUTE15,
psl.ATTRIBUTE16,
psl.ATTRIBUTE17,
psl.ATTRIBUTE18,
psl.ATTRIBUTE19,
psl.ATTRIBUTE20,
psl.ATTRIBUTE21,
psl.ATTRIBUTE22,
psl.ATTRIBUTE23,
psl.ATTRIBUTE24,
psl.ATTRIBUTE25,
psl.ATTRIBUTE26,
psl.ATTRIBUTE27,
psl.ATTRIBUTE28,
psl.SUMMARY_LINE_ID, -- storing in attribute29
psl.SUMMARY_AMOUNT,  -- storing in attribute30
psl.LAST_UPDATE_DATE,
psl.LAST_UPDATED_BY,
psl.LAST_UPDATE_LOGIN,
psl.CREATED_BY,
psl.CREATION_DATE,
psl.SET_OF_BOOKS_ID,
psl.BUSINESS_GROUP_ID,
psl.STATUS_CODE,
psl.GMS_BATCH_NAME,
psl.GMS_POSTING_EFFECTIVE_DATE,
psl.EXPENDITURE_ENDING_DATE ,
psl.EXPENDITURE_ID,
psl.INTERFACE_ID,
psl.EXPENDITURE_ITEM_ID,
pti.TXN_INTERFACE_ID,        -- insert the new txn_reference_id from pa_transaction_interface_all
psl.ACTUAL_SUMMARY_AMOUNT,
psl.ACCOUNTING_DATE,
psl.EXCHANGE_RATE_TYPE
FROM pa_transaction_interface_all pti,
     gms_transaction_interface_all gti,
     psp_summary_lines psl
WHERE pti.txn_interface_id = gti.txn_interface_id
AND   pti.orig_transaction_reference = psl.summary_line_id
AND   psl.award_id = l_default_dist_award_id
AND   pti.batch_name = p_gms_batch_name
AND   pti.transaction_source = 'GOLD';

--- subsequent code applicable only if Default Award is involved.
if sql%rowcount > 0 then

UPDATE psp_summary_lines
   SET status_code = 'S'
WHERE award_id = l_default_dist_award_id
AND summary_line_id IN (SELECT orig_transaction_reference
                        FROM pa_transaction_interface_all pti
                        WHERE pti.batch_name = p_gms_batch_name
                        AND pti.transaction_source = 'GOLD');

hr_utility.trace('summary line split rounding fixes');
open get_unmatched_summary_splits;
hr_utility.trace('summary line split rounding fixes-2');
loop
  fetch get_unmatched_summary_splits into summary_split_rec;
  if get_unmatched_summary_splits%notfound then
     close get_unmatched_summary_splits;
     exit;
  end if;
  update psp_summary_lines
     set summary_amount  = summary_split_rec.old_summary_amount - summary_split_rec.new_summary_amount + summary_amount
   where summary_line_id = summary_split_rec.new_summary_line_id;
 end loop;


hr_utility.trace('Updating xface table');

-- update the new orig_transaction_reference in pa_transaction_interface_all table
-- gms_tie_back procedure in Summarize and Transfer process expects one record in pa/gms interface table for one summary line
UPDATE pa_transaction_interface_all pti
SET pti.orig_transaction_reference = (SELECT summary_line_id
                                    FROM psp_summary_lines psl
                                   WHERE psl.txn_interface_id = pti.txn_interface_id
                                     AND psl.status_code = 'N'
                                     AND psl.gms_batch_name = p_gms_batch_name)
WHERE pti.batch_name = p_gms_batch_name
AND pti.transaction_source = 'GOLD'
AND pti.orig_transaction_reference in (SELECT to_char(summary_line_id)
                                         FROM  psp_summary_lines
                                       WHERE  status_code = 'S'
                                         AND  gms_batch_name = p_gms_batch_name) ;
hr_utility.trace('After Updating xface table');

 --create distribution lines for the new summary lines if source_type = 'O' or 'N'

INSERT INTO PSP_DISTRIBUTION_LINES(
DISTRIBUTION_LINE_ID,
DISTRIBUTION_DATE,
EFFECTIVE_DATE,
DISTRIBUTION_AMOUNT,
STATUS_CODE,
DEFAULT_REASON_CODE,
SUSPENSE_REASON_CODE,
EFFORT_REPORT_ID,
PAYROLL_SUB_LINE_ID,
SCHEDULE_LINE_ID,
DEFAULT_ORG_ACCOUNT_ID,
SUSPENSE_ORG_ACCOUNT_ID,
ELEMENT_ACCOUNT_ID,
ORG_SCHEDULE_ID,
GL_PROJECT_FLAG,
REVERSAL_ENTRY_FLAG,
PRE_DISTRIBUTION_RUN_FLAG,
SUMMARY_LINE_ID,
SET_OF_BOOKS_ID,
VERSION_NUM,
USER_DEFINED_FIELD,
AUTO_EXPENDITURE_TYPE,
AUTO_GL_CODE_COMBINATION_ID,
BUSINESS_GROUP_ID,
ATTRIBUTE_CATEGORY,
ATTRIBUTE1,
ATTRIBUTE2,
ATTRIBUTE3,
ATTRIBUTE4,
ATTRIBUTE5,
ATTRIBUTE6,
ATTRIBUTE7,
ATTRIBUTE8,
ATTRIBUTE9,
ATTRIBUTE10,
CAP_EXCESS_DIST_LINE_ID,
CAP_EXCESS_GLCCID,
CAP_EXCESS_AWARD_ID,
CAP_EXCESS_PROJECT_ID,
CAP_EXCESS_TASK_ID,
CAP_EXCESS_EXP_ORG_ID,
CAP_EXCESS_EXP_TYPE,
FUNDING_SOURCE_CODE,
ANNUAL_SALARY_CAP,
SUSPENSE_AUTO_GLCCID,
SUSPENSE_AUTO_EXP_TYPE,
ADJ_ACCOUNT_FLAG)
SELECT
PSP_DISTRIBUTION_LINES_S.NEXTVAL,
pdl.DISTRIBUTION_DATE,
pdl.EFFECTIVE_DATE,
pdl.DISTRIBUTION_AMOUNT*psl.SUMMARY_AMOUNT/psl.ATTRIBUTE30,
pdl.STATUS_CODE,
pdl.DEFAULT_REASON_CODE,
pdl.SUSPENSE_REASON_CODE,
pdl.EFFORT_REPORT_ID,
pdl.PAYROLL_SUB_LINE_ID,
pdl.SCHEDULE_LINE_ID,
pdl.DEFAULT_ORG_ACCOUNT_ID,
pdl.SUSPENSE_ORG_ACCOUNT_ID,
pdl.ELEMENT_ACCOUNT_ID,
pdl.ORG_SCHEDULE_ID,
pdl.GL_PROJECT_FLAG,
pdl.REVERSAL_ENTRY_FLAG,
pdl.PRE_DISTRIBUTION_RUN_FLAG,
psl.SUMMARY_LINE_ID,
pdl.SET_OF_BOOKS_ID,
pdl.VERSION_NUM,
pdl.USER_DEFINED_FIELD,
pdl.AUTO_EXPENDITURE_TYPE,
pdl.AUTO_GL_CODE_COMBINATION_ID,
pdl.BUSINESS_GROUP_ID,
pdl.ATTRIBUTE_CATEGORY,
pdl.ATTRIBUTE1,
pdl.ATTRIBUTE2,
pdl.ATTRIBUTE3,
pdl.ATTRIBUTE4,
pdl.ATTRIBUTE5,
pdl.ATTRIBUTE6,
pdl.ATTRIBUTE7,
pdl.ATTRIBUTE8,
pdl.ATTRIBUTE9,
pdl.DISTRIBUTION_LINE_ID, -- storing in attribute10
pdl.CAP_EXCESS_DIST_LINE_ID,
pdl.CAP_EXCESS_GLCCID,
pdl.CAP_EXCESS_AWARD_ID,
pdl.CAP_EXCESS_PROJECT_ID,
pdl.CAP_EXCESS_TASK_ID,
pdl.CAP_EXCESS_EXP_ORG_ID,
pdl.CAP_EXCESS_EXP_TYPE,
pdl.FUNDING_SOURCE_CODE,
pdl.ANNUAL_SALARY_CAP,
pdl.SUSPENSE_AUTO_GLCCID,
pdl.SUSPENSE_AUTO_EXP_TYPE,
pdl.ADJ_ACCOUNT_FLAG
FROM psp_distribution_lines pdl,
     psp_summary_lines psl
WHERE pdl.summary_line_id = psl.attribute29
AND   psl.gms_batch_name = p_gms_batch_name
AND   (source_type = 'O'
OR    source_type = 'N');

-- adjust the rounding off amount on the last distribution line within a summary line
OPEN get_unmatched_summary_lines;
LOOP
 FETCH get_unmatched_summary_lines INTO l_summary_line_id, l_sum_summary_amt, l_sum_dist_amt;
 FETCH get_unmatched_summary_lines INTO l_summary_line_id, l_sum_summary_amt, l_sum_dist_amt;
 IF get_unmatched_summary_lines%NOTFOUND THEN
   CLOSE get_unmatched_summary_lines;
   EXIT;
 END IF;

      hr_utility.trace('get_unmatched_summary_lines ='|| l_summary_line_id||','|| l_sum_summary_amt||','|| l_sum_dist_amt);

 IF l_sum_summary_amt != l_sum_dist_amt THEN
   UPDATE psp_distribution_lines pdl
   SET distribution_amount = distribution_amount+l_sum_summary_amt-l_sum_dist_amt
   WHERE distribution_line_id = (SELECT max(distribution_line_id)
                                  FROM psp_distribution_lines pdl1
                                  WHERE pdl.summary_line_id = l_summary_line_id);
 END IF;
END LOOP;

-- create pre-gen lines for the new summary lines if source_type = 'P'
INSERT INTO psp_pre_gen_dist_lines(
PRE_GEN_DIST_LINE_ID,
DISTRIBUTION_INTERFACE_ID,
PERSON_ID,
ASSIGNMENT_ID,
ELEMENT_TYPE_ID,
DISTRIBUTION_DATE,
EFFECTIVE_DATE,
DISTRIBUTION_AMOUNT,
DR_CR_FLAG,
PAYROLL_CONTROL_ID,
SOURCE_TYPE,
SOURCE_CODE,
TIME_PERIOD_ID,
BATCH_NAME,
STATUS_CODE,
SET_OF_BOOKS_ID,
GL_CODE_COMBINATION_ID,
PROJECT_ID,
EXPENDITURE_ORGANIZATION_ID,
EXPENDITURE_TYPE,
TASK_ID,
AWARD_ID,
SUSPENSE_ORG_ACCOUNT_ID,
SUSPENSE_REASON_CODE,
EFFORT_REPORT_ID,
VERSION_NUM,
SUMMARY_LINE_ID,
REVERSAL_ENTRY_FLAG,
USER_DEFINED_FIELD,
BUSINESS_GROUP_ID,
ATTRIBUTE_CATEGORY,
ATTRIBUTE1,
ATTRIBUTE2,
ATTRIBUTE3,
ATTRIBUTE4,
ATTRIBUTE5,
ATTRIBUTE6,
ATTRIBUTE7,
ATTRIBUTE8,
ATTRIBUTE9,
ATTRIBUTE10,
SUSPENSE_AUTO_GLCCID,
SUSPENSE_AUTO_EXP_TYPE)
SELECT
PSP_DISTRIBUTION_LINES_S.NEXTVAL,
ppgl.DISTRIBUTION_INTERFACE_ID,
ppgl.PERSON_ID,
ppgl.ASSIGNMENT_ID,
ppgl.ELEMENT_TYPE_ID,
ppgl.DISTRIBUTION_DATE,
ppgl.EFFECTIVE_DATE,
ppgl.DISTRIBUTION_AMOUNT*psl.SUMMARY_AMOUNT/psl.ATTRIBUTE30,
ppgl.DR_CR_FLAG,
ppgl.PAYROLL_CONTROL_ID,
ppgl.SOURCE_TYPE,
ppgl.SOURCE_CODE,
ppgl.TIME_PERIOD_ID,
ppgl.BATCH_NAME,
ppgl.STATUS_CODE,
ppgl.SET_OF_BOOKS_ID,
ppgl.GL_CODE_COMBINATION_ID,
ppgl.PROJECT_ID,
ppgl.EXPENDITURE_ORGANIZATION_ID,
ppgl.EXPENDITURE_TYPE,
ppgl.TASK_ID,
psl.AWARD_ID,                  -- update the new award_id
ppgl.SUSPENSE_ORG_ACCOUNT_ID,
ppgl.SUSPENSE_REASON_CODE,
ppgl.EFFORT_REPORT_ID,
ppgl.VERSION_NUM,
psl.SUMMARY_LINE_ID,           -- update the new summary_line_id
ppgl.REVERSAL_ENTRY_FLAG,
ppgl.USER_DEFINED_FIELD,
ppgl.BUSINESS_GROUP_ID,
ppgl.ATTRIBUTE_CATEGORY,
ppgl.ATTRIBUTE1,
ppgl.ATTRIBUTE2,
ppgl.ATTRIBUTE3,
ppgl.ATTRIBUTE4,
ppgl.ATTRIBUTE5,
ppgl.ATTRIBUTE6,
ppgl.ATTRIBUTE7,
ppgl.ATTRIBUTE8,
ppgl.PRE_GEN_DIST_LINE_ID,     -- attribute9
ppgl.DISTRIBUTION_AMOUNT,      -- attribute10
ppgl.SUSPENSE_AUTO_GLCCID,
ppgl.SUSPENSE_AUTO_EXP_TYPE
FROM psp_pre_gen_dist_lines ppgl,
     psp_summary_lines psl
WHERE ppgl.summary_line_id = psl.attribute29
AND   psl.payroll_control_id = p_payroll_control_id
AND   psl.source_type = 'P';

-- adjust the rounding off amount on the last pre gen distribution line within a summary line
OPEN get_unmatched_pg_summary_lines;
LOOP
 FETCH get_unmatched_pg_summary_lines INTO l_pg_summary_line_id,
l_pg_sum_summary_amt, l_pg_sum_dist_amt;
 IF get_unmatched_pg_summary_lines%NOTFOUND THEN
   CLOSE get_unmatched_pg_summary_lines;
   EXIT;
 END IF;

 IF l_pg_sum_summary_amt != l_pg_sum_dist_amt THEN
   UPDATE psp_pre_gen_dist_lines
   SET distribution_amount = distribution_amount+l_pg_sum_summary_amt-l_pg_sum_dist_amt
   WHERE pre_gen_dist_line_id = (SELECT max(pre_gen_dist_line_id)
                                  FROM psp_pre_gen_dist_lines
                                  WHERE summary_line_id = l_pg_summary_line_id);
 END IF;
END LOOP;

DELETE psp_distribution_lines
 WHERE summary_line_id in
        (select summary_line_id
           from psp_summary_lines
          where gms_batch_name = p_gms_batch_name
            and award_id = l_default_dist_award_id
            and status_code = 'S');

-- delete the original pre-gen distribution lines
DELETE psp_pre_gen_dist_lines
 WHERE summary_line_id in
        (select summary_line_id
           from psp_summary_lines
          where gms_batch_name = p_gms_batch_name
            and award_id = l_default_dist_award_id
            and status_code = 'S');

 DELETE psp_summary_lines
  WHERE gms_batch_name = p_gms_batch_name
    and status_code = 'S';
else
  hr_utility.trace('tieback_actual userhook..no default awards found to process');
end if;   --- default awards involved in PRC import
 exception
    when others then
      psp_sum_trans.g_error_api_path := 'TIEBACK_ACTUAL'||psp_sum_trans.g_error_api_path;
      fnd_msg_pub.add_exc_msg('PSP_SUM_TRANS','TIEBACK_ACTUAL');
      raise;

END;
*/

----- new procedure for 5463110
PROCEDURE tieback_adjustment(p_payroll_control_id   IN  NUMBER,
                             p_adjutment_batch_name in varchar2,
                             p_gms_batch_name     IN  VARCHAR2,
                             p_business_group_id  IN NUMBER,
                             p_set_of_books_id    IN NUMBER) is
 begin
   -- Write the user extension code here;
   --
   null;
 exception
    when others then
      psp_sum_trans.g_error_api_path := 'TIEBACK_ACTUAL'||psp_sum_trans.g_error_api_path;
      fnd_msg_pub.add_exc_msg('PSP_SUM_TRANS','TIEBACK_ADJUSTMENTL');
      raise;
 end;

/*
  --- following code is for Award Funding pattern implementation in LD.
 --- this code should be moved into tieback_adjustments.

 l_default_dist_award_id NUMBER;
 l_summary_line_id       NUMBER;
 l_sum_summary_amt       NUMBER;
 l_sum_dist_amt          NUMBER;

 -- get the summary_line_id's where  adj line  amount does not match with summary amount
 CURSOR get_unmatched_summary_lines is
 SELECT pal.summary_line_id, psl.summary_amount, sum(pal.distribution_amount)
 FROM psp_adjustment_lines pal,
      psp_summary_lines psl
 WHERE pal.summary_line_id = psl.summary_line_id
 AND  psl.payroll_control_id = p_payroll_control_id
 AND  psl.status_code = 'N'
 AND  psl.attribute29 is not null
 ANd  psl.attribute30 is not null
 GROUP BY pal.summary_line_id, psl.summary_amount
 HAVING summary_amount - sum(distribution_amount) <> 0;

 CURSOR get_unmatched_summary_splits is
 SELECT to_number(attribute30) old_summary_amount,
        attribute29 old_summary_line_id,
        sum(summary_amount) new_summary_amount,
        max(summary_line_id) new_summary_line_id
   FROM psp_summary_lines
  WHERE attribute29 is not null
    AND attribute30 is not null
    AND gms_batch_name = p_gms_batch_name
    AND status_code <> 'S'
  GROUP BY attribute29, attribute30
  HAVING sum(summary_amount) <> to_number(attribute30);

 summary_split_rec get_unmatched_summary_splits%rowtype;

BEGIN

hr_utility.trace( 'ENTERING TIEBACK_ADJUSTMENT GMS_BATCH_NAME = '||p_gms_batch_name);

SELECT default_dist_award_id
INTO   l_default_dist_award_id
FROM   gms_implementations;
hr_utility.trace( ' adjustment tieback userhook l_default_dist_award_id='|| l_default_dist_award_id);

-- create new summary lines from PA/GMS interface table for award distribution lines

INSERT INTO psp_summary_lines
(SUMMARY_LINE_ID,
SOURCE_TYPE,
SOURCE_CODE,
TIME_PERIOD_ID,
INTERFACE_BATCH_NAME,
PERSON_ID,
ASSIGNMENT_ID,
EFFECTIVE_DATE,
PAYROLL_CONTROL_ID,
GL_CODE_COMBINATION_ID,
PROJECT_ID,
EXPENDITURE_ORGANIZATION_ID,
EXPENDITURE_TYPE,
TASK_ID,
AWARD_ID,
SUMMARY_AMOUNT,
DR_CR_FLAG,
GROUP_ID,
INTERFACE_STATUS,
ATTRIBUTE_CATEGORY,
ATTRIBUTE1,
ATTRIBUTE2,
ATTRIBUTE3,
ATTRIBUTE4,
ATTRIBUTE5,
ATTRIBUTE6,
ATTRIBUTE7,
ATTRIBUTE8,
ATTRIBUTE9,
ATTRIBUTE10,
ATTRIBUTE11,
ATTRIBUTE12,
ATTRIBUTE13,
ATTRIBUTE14,
ATTRIBUTE15,
ATTRIBUTE16,
ATTRIBUTE17,
ATTRIBUTE18,
ATTRIBUTE19,
ATTRIBUTE20,
ATTRIBUTE21,
ATTRIBUTE22,
ATTRIBUTE23,
ATTRIBUTE24,
ATTRIBUTE25,
ATTRIBUTE26,
ATTRIBUTE27,
ATTRIBUTE28,
ATTRIBUTE29,
ATTRIBUTE30,
LAST_UPDATE_DATE,
LAST_UPDATED_BY,
LAST_UPDATE_LOGIN,
CREATED_BY,
CREATION_DATE,
SET_OF_BOOKS_ID,
BUSINESS_GROUP_ID,
STATUS_CODE,
GMS_BATCH_NAME,
GMS_POSTING_EFFECTIVE_DATE,
EXPENDITURE_ENDING_DATE ,
EXPENDITURE_ID,
INTERFACE_ID,
EXPENDITURE_ITEM_ID,
TXN_INTERFACE_ID,
ACTUAL_SUMMARY_AMOUNT,
ACCOUNTING_DATE,
EXCHANGE_RATE_TYPE)
SELECT
PSP_SUMMARY_LINES_S.NEXTVAL,
psl.SOURCE_TYPE,
psl.SOURCE_CODE,
psl.TIME_PERIOD_ID,
psl.INTERFACE_BATCH_NAME,
psl.PERSON_ID,
psl.ASSIGNMENT_ID,
psl.EFFECTIVE_DATE,
psl.PAYROLL_CONTROL_ID,
psl.GL_CODE_COMBINATION_ID,
psl.PROJECT_ID,
psl.EXPENDITURE_ORGANIZATION_ID,
psl.EXPENDITURE_TYPE,
psl.TASK_ID,
gti.AWARD_ID,
pti.denom_raw_cost,      -- putting new value in the summary_amount column
psl.DR_CR_FLAG,
psl.GROUP_ID,
psl.INTERFACE_STATUS,
psl.ATTRIBUTE_CATEGORY,
psl.ATTRIBUTE1,
psl.ATTRIBUTE2,
psl.ATTRIBUTE3,
psl.ATTRIBUTE4,
psl.ATTRIBUTE5,
psl.ATTRIBUTE6,
psl.ATTRIBUTE7,
psl.ATTRIBUTE8,
psl.ATTRIBUTE9,
psl.ATTRIBUTE10,
psl.ATTRIBUTE11,
psl.ATTRIBUTE12,
psl.ATTRIBUTE13,
psl.ATTRIBUTE14,
psl.ATTRIBUTE15,
psl.ATTRIBUTE16,
psl.ATTRIBUTE17,
psl.ATTRIBUTE18,
psl.ATTRIBUTE19,
psl.ATTRIBUTE20,
psl.ATTRIBUTE21,
psl.ATTRIBUTE22,
psl.ATTRIBUTE23,
psl.ATTRIBUTE24,
psl.ATTRIBUTE25,
psl.ATTRIBUTE26,
psl.ATTRIBUTE27,
psl.ATTRIBUTE28,
psl.SUMMARY_LINE_ID, -- storing in attribute29
psl.SUMMARY_AMOUNT,  -- storing in attribute30
psl.LAST_UPDATE_DATE,
psl.LAST_UPDATED_BY,
psl.LAST_UPDATE_LOGIN,
psl.CREATED_BY,
psl.CREATION_DATE,
psl.SET_OF_BOOKS_ID,
psl.BUSINESS_GROUP_ID,
psl.STATUS_CODE,
psl.GMS_BATCH_NAME,
psl.GMS_POSTING_EFFECTIVE_DATE,
psl.EXPENDITURE_ENDING_DATE ,
psl.EXPENDITURE_ID,
psl.INTERFACE_ID,
psl.EXPENDITURE_ITEM_ID,
pti.TXN_INTERFACE_ID,        -- insert the new txn_reference_id from pa_transaction_interface_all
psl.ACTUAL_SUMMARY_AMOUNT,
psl.ACCOUNTING_DATE,
psl.EXCHANGE_RATE_TYPE
FROM pa_transaction_interface_all pti,
     gms_transaction_interface_all gti,
     psp_summary_lines psl
WHERE pti.txn_interface_id = gti.txn_interface_id
AND   pti.orig_transaction_reference = psl.summary_line_id
AND   psl.award_id = l_default_dist_award_id
AND   pti.batch_name = p_gms_batch_name
AND   pti.transaction_source = 'GOLD';

if sql%rowcount > 0 then

UPDATE psp_summary_lines
   SET status_code = 'S'
WHERE award_id = l_default_dist_award_id
AND summary_line_id IN (SELECT orig_transaction_reference
                        FROM pa_transaction_interface_all pti
                        WHERE pti.batch_name = p_gms_batch_name
                        AND pti.transaction_source = 'GOLD');

hr_utility.trace('summary line split rounding fixes ADJ');
open get_unmatched_summary_splits;
hr_utility.trace('summary line split rounding fixes ADJ2');
loop
hr_utility.trace('summary line split rounding fixes ADJ2.2');
  fetch get_unmatched_summary_splits into summary_split_rec;
hr_utility.trace('summary line split rounding fixes ADJ3');
  if get_unmatched_summary_splits%notfound then
     close get_unmatched_summary_splits;
     exit;
  end if;
hr_utility.trace('summary line split rounding fixes ADJ4');
  update psp_summary_lines
     set summary_amount  = summary_split_rec.old_summary_amount - summary_split_rec.new_summary_amount + summary_amount
   where summary_line_id = summary_split_rec.new_summary_line_id;
   null;
 end loop;

hr_utility.trace('Update of pa xface table');
-- update the new orig_transaction_reference in pa_transaction_interface_all table
-- gms_tie_back procedure in Summarize and Transfer process expects one record in pa/gms interface table for one summary line
UPDATE pa_transaction_interface_all pti
SET pti.orig_transaction_reference = (SELECT summary_line_id FROM psp_summary_lines psl
                                  WHERE psl.txn_interface_id = pti.txn_interface_id
                                  AND   psl.status_code = 'N'
                                  AND   psl.gms_batch_name = p_gms_batch_name)
WHERE pti.batch_name = p_gms_batch_name
AND pti.transaction_source = 'GOLD'
AND pti.orig_transaction_reference in (SELECT to_char(summary_line_id)
                                         FROM  psp_summary_lines
                                       WHERE  status_code = 'S'
                                         AND  gms_batch_name = p_gms_batch_name) ;

INSERT INTO PSP_ADJUSTMENT_LINES(
 ADJUSTMENT_LINE_ID ,
 PERSON_ID         ,
 ASSIGNMENT_ID    ,
 ELEMENT_TYPE_ID ,
 DISTRIBUTION_DATE ,
 EFFECTIVE_DATE     ,
 DISTRIBUTION_AMOUNT ,
 DR_CR_FLAG   ,
 SOURCE_CODE ,
 SOURCE_TYPE  ,
 TIME_PERIOD_ID ,
 BATCH_NAME  ,
 STATUS_CODE                    ,
 SET_OF_BOOKS_ID               ,
 GL_CODE_COMBINATION_ID       ,
 PROJECT_ID                  ,
 EXPENDITURE_ORGANIZATION_ID,
 EXPENDITURE_TYPE          ,
 TASK_ID                  ,
 AWARD_ID                ,
 SUSPENSE_ORG_ACCOUNT_ID,
 SUSPENSE_REASON_CODE  ,
 EFFORT_REPORT_ID                     ,
 VERSION_NUM                         ,
 SUMMARY_LINE_ID                    ,
 REVERSAL_ENTRY_FLAG               ,
 ORIGINAL_LINE_FLAG               ,
 USER_DEFINED_FIELD              ,
 PERCENT                        ,
 ORIG_SOURCE_TYPE              ,
 ORIG_LINE_ID                             ,
 ATTRIBUTE_CATEGORY                       ,
 ATTRIBUTE1                               ,
 ATTRIBUTE2                               ,
 ATTRIBUTE3                               ,
 ATTRIBUTE4                               ,
 ATTRIBUTE5                               ,
 ATTRIBUTE6                               ,
 ATTRIBUTE7                               ,
 ATTRIBUTE8                               ,
 ATTRIBUTE9                               ,
 ATTRIBUTE10                              ,
 ATTRIBUTE11                              ,
 ATTRIBUTE12                              ,
 ATTRIBUTE13                              ,
 ATTRIBUTE14                              ,
 ATTRIBUTE15                              ,
 LAST_UPDATE_DATE                ,
 LAST_UPDATED_BY                 ,
 LAST_UPDATE_LOGIN              ,
 CREATED_BY                       ,
 CREATION_DATE                    ,
 PAYROLL_CONTROL_ID               ,
 BUSINESS_GROUP_ID)
SELECT
PSP_ADJUSTMENT_LINES_S.NEXTVAL,
 pal.PERSON_ID         ,
 pal.ASSIGNMENT_ID    ,
 pal.ELEMENT_TYPE_ID ,
 pal.DISTRIBUTION_DATE          ,
 pal.EFFECTIVE_DATE            ,
 pal.DISTRIBUTION_AMOUNT * psl.SUMMARY_AMOUNT/psl.ATTRIBUTE30,
 pal.DR_CR_FLAG              ,
 pal.SOURCE_CODE            ,
 pal.SOURCE_TYPE           ,
 pal.TIME_PERIOD_ID       ,
 pal.BATCH_NAME         ,
 pal.STATUS_CODE                    ,
 pal.SET_OF_BOOKS_ID               ,
 pal.GL_CODE_COMBINATION_ID       ,
 pal.PROJECT_ID                  ,
 pal.EXPENDITURE_ORGANIZATION_ID,
 pal.EXPENDITURE_TYPE          ,
 pal.TASK_ID                  ,
 psl.AWARD_ID                ,    --- new award_id
 pal.SUSPENSE_ORG_ACCOUNT_ID,
 pal.SUSPENSE_REASON_CODE  ,
 pal.EFFORT_REPORT_ID                     ,
 pal.VERSION_NUM                         ,
 psl.SUMMARY_LINE_ID                    ,  -- new sum line_id
 pal.REVERSAL_ENTRY_FLAG               ,
 pal.ORIGINAL_LINE_FLAG               ,
 pal.USER_DEFINED_FIELD              ,
 pal.PERCENT                        ,
 pal.ORIG_SOURCE_TYPE              ,
 pal.ORIG_LINE_ID                             ,
 pal.ATTRIBUTE_CATEGORY                       ,
 pal.ATTRIBUTE1  ,
 pal.ATTRIBUTE2  ,
 pal.ATTRIBUTE3  ,
 pal.ATTRIBUTE4  ,
 pal.ATTRIBUTE5  ,
 pal.ATTRIBUTE6  ,
 pal.ATTRIBUTE7  ,
 pal.ATTRIBUTE8  ,
 pal.ATTRIBUTE9  ,
 pal.ATTRIBUTE10  ,
 pal.ATTRIBUTE11  ,
 pal.ATTRIBUTE12,
 pal.ATTRIBUTE13,
 pal.adjustment_LINE_ID,  --- line_id
 pal.distribution_amount,   -- dist_amount
 pal.LAST_UPDATE_DATE                ,
 pal.LAST_UPDATED_BY                 ,
 pal.LAST_UPDATE_LOGIN              ,
 pal.CREATED_BY                       ,
 pal.CREATION_DATE                    ,
 pal.PAYROLL_CONTROL_ID               ,
 pal.BUSINESS_GROUP_ID
FROM psp_adjustment_lines pal,
     psp_summary_lines psl
WHERE pal.summary_line_id = psl.attribute29
AND   psl.gms_batch_name = p_gms_batch_name;

-- adjust the rounding off amount on the last distribution line within a summary line
hr_utility.trace('GEt unmatched summary lines csr');
OPEN get_unmatched_summary_lines;
hr_utility.trace('GEt unmatched summary lines csr2');
LOOP
 FETCH get_unmatched_summary_lines INTO l_summary_line_id, l_sum_summary_amt, l_sum_dist_amt;
 FETCH get_unmatched_summary_lines INTO l_summary_line_id, l_sum_summary_amt, l_sum_dist_amt;
 IF get_unmatched_summary_lines%NOTFOUND THEN
   CLOSE get_unmatched_summary_lines;
   EXIT;
 END IF;

 IF l_sum_summary_amt != l_sum_dist_amt THEN
   UPDATE psp_adjustment_lines pal
   SET distribution_amount = distribution_amount+l_sum_summary_amt-l_sum_dist_amt
   WHERE adjustment_line_id = (SELECT max(adjustment_line_id)
                                  FROM psp_adjustment_lines pal1
                                  WHERE pal1.summary_line_id = l_summary_line_id);
 END IF;
END LOOP;
hr_utility.trace('GEt unmatched summary lines csr4');

--- delete the original adjustment lines
DELETE psp_adjustment_lines
where summary_line_id IN (SELECT summary_line_id FROM psp_summary_lines
                          WHERE payroll_control_id = p_payroll_control_id
                          AND status_code = 'S');

DELETE psp_summary_lines
 WHERE status_code = 'S'
   and payroll_control_id = p_payroll_control_id;
else
  hr_utility.trace('tieback_actual userhook..no default awards found to process');
end if;
 exception
    when others then
      psp_sum_trans.g_error_api_path := 'TIEBACK_ADJUSTMENT'||psp_sum_trans.g_error_api_path;
      fnd_msg_pub.add_exc_msg('PSP_SUM_TRANS','TIEBACK_ADJUSTMENT');
      raise;
END tieback_adjustment;
*/
END PSP_ST_EXT;

/

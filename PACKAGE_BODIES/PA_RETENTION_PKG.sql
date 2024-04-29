--------------------------------------------------------
--  DDL for Package Body PA_RETENTION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_RETENTION_PKG" AS
/* $Header: PAXIRTNB.pls 120.6.12000000.2 2007/07/24 11:36:25 jjgeorge ship $ */


-- Function 	Get_Invoice_Max_Line
-- Purpose	Get the Maximum Invoice line Number for a given project, invoice number

g1_debug_mode varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

FUNCTION Get_Invoice_Max_Line(p_project_id IN NUMBER,
                              p_draft_invoice_num IN NUMBER) RETURN NUMBER IS
	last_line_num	NUMBER;
BEGIN

	IF g1_debug_mode  = 'Y' THEN
		pa_retention_util.write_log('Entering pa_retention_pkg.Get_Invoice_Max_Line');
	END IF;

	SELECT  NVL(MAX(line_num),0) +1
	  INTO last_line_num
	 FROM  pa_draft_invoice_items
	WHERE  project_id = p_project_id
	  AND  draft_invoice_num = p_draft_invoice_num;

	IF g1_debug_mode  = 'Y' THEN
		pa_retention_util.write_log('Get_Invoice_Max_Line : ' || last_line_num);
		pa_retention_util.write_log('Leaving pa_retention_pkg.Get_Invoice_Max_Line');
	END IF;
  RETURN (last_line_num);

END Get_Invoice_Max_Line;

/* This function is added as netzero lines are coming up before retention lines in project invoices
   net zero line num is cached. It is updated to its negative value */
FUNCTION Get_NetZero_Line(p_project_id IN NUMBER,
                              p_draft_invoice_num IN NUMBER) RETURN NUMBER IS
	NetZero_line_num	NUMBER;
BEGIN

	IF g1_debug_mode  = 'Y' THEN
		pa_retention_util.write_log('Entering pa_retention_pkg.Get_NetZero_Line');
	END IF;

	SELECT  line_num
	  INTO NetZero_line_num
	 FROM  pa_draft_invoice_items
	WHERE  project_id = p_project_id
	  AND  draft_invoice_num = p_draft_invoice_num
          AND invoice_line_type = 'NET ZERO ADJUSTMENT';

	IF g1_debug_mode  = 'Y' THEN
		pa_retention_util.write_log('Get_NetZero_Line : ' || NetZero_line_num);
	END IF;

        Update pa_draft_invoice_items
        set line_num = NetZero_line_num * (-1)
	WHERE  project_id = p_project_id
	  AND  draft_invoice_num = p_draft_invoice_num
          AND invoice_line_type = 'NET ZERO ADJUSTMENT';


  RETURN (NetZero_line_num);

EXCEPTION
   WHEN NO_DATA_FOUND THEN
        RETURN (0);

END Get_NetZero_Line;

-- Function Get_Proj_Inv_Retn_Format
-- Purpose  Function to return the project invoice retention line format

Function Get_Proj_Inv_Retn_Format(p_project_id NUMBER) RETURN pa_retention_pkg.TabInvRetnLineFormat IS

CURSOR cur_inv_group_columns IS SELECT 	grp.column_code column_code,
					fmtdet.text text,
					fmtdet.start_position start_position,
					fmtdet.end_position end_position,
					NVL(fmtdet.right_justify_flag,'N') right_justify_flag
				FROM 	pa_invoice_group_columns grp,
					pa_invoice_formats fmt,
					pa_invoice_format_details fmtdet,
					pa_projects_all pr
    				WHERE   pr.retention_invoice_format_id = fmt.invoice_format_id
				  AND   fmt.invoice_format_id = fmtdet.invoice_format_id
				  AND	grp.invoice_group_column_id = fmtdet.invoice_group_column_id
				  and   pr.project_id =p_project_id
				ORDER BY fmtdet.start_position;

Cnt		NUMBER :=0;

InvGroupColumnsRec	cur_Inv_Group_columns%ROWTYPE;

TmpRetnLineFmt		pa_retention_pkg.TabInvRetnLineFormat;

BEGIN
	IF g1_debug_mode  = 'Y' THEN
		pa_retention_util.write_log('Entering pa_retention_pkg.Get_Proj_Inv_Retn_Format');
	END IF;

	OPEN cur_inv_group_columns;
	LOOP
	FETCH cur_inv_group_columns INTO InvGroupColumnsRec;
	EXIT WHEN cur_inv_group_columns%NOTFOUND;
	cnt  := cnt +1;
	TmpRetnLineFmt(Cnt).column_code :=InvGroupColumnsRec.column_code;
	TmpRetnLineFmt(Cnt).usertext := InvGroupColumnsRec.text;
	TmpRetnLineFmt(Cnt).start_position := InvGroupColumnsRec.start_position;
	TmpRetnLineFmt(Cnt).end_position := InvGroupColumnsRec.end_position;
	TmpRetnLineFmt(Cnt).right_justify_flag := InvGroupColumnsRec.right_justify_flag;

	IF g1_debug_mode  = 'Y' THEN
		pa_retention_util.write_log('Get_Proj_Inv_Retn_Format: ' || 'Format Column  : ' || InvGroupColumnsRec.column_code);
		pa_retention_util.write_log('Get_Proj_Inv_Retn_Format: ' || 'User  TExt     : ' || InvGroupColumnsRec.text);
	END IF;

	END LOOP;
	CLOSE cur_inv_group_columns;

	IF g1_debug_mode  = 'Y' THEN
		pa_retention_util.write_log('Leaving pa_retention_pkg.Get_Proj_Inv_Retn_Format');
	END IF;

RETURN TmpRetnLineFmt;

END Get_Proj_Inv_Retn_Format;

-- Procedure to Update the retention balances
-- Update the pa_project_retentions, pa_proj_retn_rules, pa_summary_project_retn

/*PROCEDURE Update_Retention_Balances(	p_retention_rule_id 	IN NUMBER DEFAULT NULL, bug 2681003,
	removed the default values to ensure GSCC complaince */
PROCEDURE Update_Retention_Balances(	p_retention_rule_id 	IN NUMBER ,
				        p_project_id		IN NUMBER ,
				        /*p_task_id		IN NUMBER DEFAULT NULL,
					removed the default values to ensure GSCC complaince */
				        p_task_id		IN NUMBER ,
				  	p_agreement_id	  	IN NUMBER,
				  	p_customer_id	  	IN NUMBER,
				  	p_amount		IN NUMBER,
				 	p_change_type 	  	IN VARCHAR2,
					p_request_id      	IN NUMBER ,
					p_invproc_currency	IN VARCHAR2,
					p_project_currency	IN VARCHAR2,
					p_project_amount 	IN NUMBER,
					p_projfunc_currency	IN VARCHAR2,
					p_projfunc_amount	IN NUMBER,
					p_funding_currency	IN VARCHAR2,
					p_funding_amount	IN NUMBER) IS

TmpFlag		VARCHAR2(1):='N';
l_program_id                  NUMBER:= fnd_global.conc_program_id;
l_program_application_id      NUMBER:= fnd_global.prog_appl_id;
l_program_update_date         DATE  := sysdate;
l_last_update_date            DATE  := sysdate;
l_last_updated_by             NUMBER:= fnd_global.user_id;
l_last_update_login           NUMBER:= fnd_global.login_id;
l_project_retn_id	      NUMBER;

ok_found	EXCEPTION;
spr_found	EXCEPTION;

BEGIN
	IF g1_debug_mode  = 'Y' THEN
		pa_retention_util.write_log('Entering pa_retention_pkg.Update_Retention_Balances');
	END IF;

	IF p_change_type = 'RETAINED' THEN

	IF g1_debug_mode  = 'Y' THEN
		pa_retention_util.write_log('Update_Retention_Balances: ' || 'Update Retained Amount');
	END IF;

	  -- For Old Invoice Credit memo retention rule id will be null, so no action is needed

	   IF p_retention_rule_id IS NOT NULL THEN

         	IF g1_debug_mode  = 'Y' THEN
         		pa_retention_util.write_log('Update_Retention_Balances: ' || 'Update Retained Amount');
         	END IF;

		-- Before update the retained amount, make sure there is a record for this agreement
                -- , rule, project id.

		BEGIN
			SELECT 'Y' INTO 	TmpFlag
			FROM pa_project_retentions
			WHERE project_id = p_project_id
			  AND retention_rule_id = p_retention_rule_id
			  AND agreement_id	= p_agreement_id
		          AND NVL(task_id,-99)	= NVL(p_task_id,-99);

		     	IF sql%FOUND THEN

				RAISE ok_found;

		     	END IF;

			EXCEPTION

			WHEN NO_DATA_FOUND THEN

			        SELECT pa_project_retentions_s.NEXTVAL
				  INTO l_project_retn_id
				  FROM DUAL;

				IF g1_debug_mode  = 'Y' THEN
					pa_retention_util.write_log('Update_Retention_Balances: ' || 'Insert NEW Record Project Retentions');
					pa_retention_util.write_log('Update_Retention_Balances: ' || 'Project Amount :  ' || p_project_amount);
					pa_retention_util.write_log('Update_Retention_Balances: ' || 'Projfunc Amount :  ' || p_projfunc_amount);
					pa_retention_util.write_log('Update_Retention_Balances: ' || 'Funding Amount :  ' || p_funding_amount);
				END IF;

				INSERT INTO pa_project_retentions
					( PROJECT_RETENTION_ID,
 					  PROJECT_ID,
 					  TASK_ID,
 					  AGREEMENT_ID,
					  RETENTION_RULE_ID,
 					  INVPROC_CURRENCY_CODE,
 					  TOTAL_RETAINED,
 					  PROJFUNC_CURRENCY_CODE,
 					  PROJFUNC_TOTAL_RETAINED,
 					  PROJECT_CURRENCY_CODE,
 					  PROJECT_TOTAL_RETAINED,
 				          FUNDING_CURRENCY_CODE,
 					  FUNDING_TOTAL_RETAINED,
 					  PROGRAM_APPLICATION_ID,
 					  PROGRAM_UPDATE_DATE,
 					  REQUEST_ID,
 					  CREATION_DATE,
 					  CREATED_BY,
 					  LAST_UPDATE_DATE,
 					  LAST_UPDATED_BY)
				VALUES(l_project_retn_id,
				       p_project_id,
					p_task_id,
					p_agreement_id,
					p_retention_rule_id,
					p_invproc_currency,
					PA_CURRENCY.ROUND_TRANS_CURRENCY_AMT(p_amount, p_invproc_currency),
					p_projfunc_currency,
					PA_CURRENCY.ROUND_TRANS_CURRENCY_AMT(p_projfunc_amount,p_projfunc_currency),
					p_project_currency,
					PA_CURRENCY.ROUND_TRANS_CURRENCY_AMT(p_project_amount,p_project_currency),
					p_funding_currency,
					PA_CURRENCY.ROUND_TRANS_CURRENCY_AMT(p_funding_amount,p_funding_currency),
					l_program_application_id,
					l_program_update_date,
					p_request_id,
					sysdate,
					l_last_updated_by,
				        l_last_update_date,
					l_last_updated_by);

			WHEN ok_found THEN

				IF g1_debug_mode  = 'Y' THEN
					pa_retention_util.write_log('Update_Retention_Balances: ' || 'Update Project Retentions');
					pa_retention_util.write_log('Update_Retention_Balances: ' || 'Project Amount :  ' || p_project_amount);
					pa_retention_util.write_log('Update_Retention_Balances: ' || 'Projfunc Amount :  ' || p_projfunc_amount);
					pa_retention_util.write_log('Update_Retention_Balances: ' || 'Funding Amount :  ' || p_funding_amount);
				END IF;

			  UPDATE pa_project_retentions
		   	    SET total_retained = PA_CURRENCY.ROUND_TRANS_CURRENCY_AMT(
							NVL(total_retained,0) + NVL(p_amount,0), invproc_currency_code),
		   	        project_total_retained =PA_CURRENCY.ROUND_TRANS_CURRENCY_AMT(
					 NVL(project_total_retained,0) + NVL(p_project_amount,0),project_currency_code),
		   	        projfunc_total_retained =PA_CURRENCY.ROUND_TRANS_CURRENCY_AMT(
					 NVL(projfunc_total_retained,0) + NVL(p_projfunc_amount,0),projfunc_currency_code),
		   	        funding_total_retained =PA_CURRENCY.ROUND_TRANS_CURRENCY_AMT(
				 NVL(funding_total_retained,0) + NVL(p_funding_amount,0), funding_currency_code)
				 WHERE project_id = p_project_id
		  		   AND agreement_id = p_agreement_id
		  		   AND retention_rule_id = p_retention_rule_id;

		    END;

		-- Update the project,agreement and task level balance

		BEGIN
				IF g1_debug_mode  = 'Y' THEN
					pa_retention_util.write_log('Update_Retention_Balances: ' || 'Update SPR ');
				END IF;

			SELECT 'Y' INTO 	TmpFlag
			FROM pa_summary_project_retn
			WHERE project_id = p_project_id
			  AND nvl(task_id,-99) = NVL(p_task_id,-99)
			  AND agreement_id	= p_agreement_id;

		     	IF sql%FOUND THEN

				RAISE spr_found;

		     	END IF;

			EXCEPTION

			WHEN NO_DATA_FOUND THEN

				IF g1_debug_mode  = 'Y' THEN
					pa_retention_util.write_log('Update_Retention_Balances: ' || 'Insert New Record SPR ');
					pa_retention_util.write_log('Update_Retention_Balances: ' || 'Project Amount :  ' || p_project_amount);
					pa_retention_util.write_log('Update_Retention_Balances: ' || 'Projfunc Amount :  ' || p_projfunc_amount);
					pa_retention_util.write_log('Update_Retention_Balances: ' || 'Funding Amount :  ' || p_funding_amount);
				END IF;

				INSERT INTO pa_summary_project_retn
					(
 					  PROJECT_ID,
 					  TASK_ID,
 					  AGREEMENT_ID,
 					  CUSTOMER_ID,
 					  INVPROC_CURRENCY_CODE,
 					  TOTAL_RETAINED,
 					  PROJFUNC_CURRENCY_CODE,
 					  PROJFUNC_TOTAL_RETAINED,
 					  PROJECT_CURRENCY_CODE,
 					  PROJECT_TOTAL_RETAINED,
 				          FUNDING_CURRENCY_CODE,
 					  FUNDING_TOTAL_RETAINED,
 					  PROGRAM_APPLICATION_ID,
 					  PROGRAM_UPDATE_DATE,
 					  REQUEST_ID,
 					  CREATION_DATE,
 					  CREATED_BY,
 					  LAST_UPDATE_DATE,
 					  LAST_UPDATED_BY)
				VALUES(
				       p_project_id,
					p_task_id,
					p_agreement_id,
					p_customer_id,
					p_invproc_currency,
					PA_CURRENCY.ROUND_TRANS_CURRENCY_AMT(p_amount,p_invproc_currency),
					p_projfunc_currency,
					PA_CURRENCY.ROUND_TRANS_CURRENCY_AMT(p_projfunc_amount,p_projfunc_currency),
					p_project_currency,
					PA_CURRENCY.ROUND_TRANS_CURRENCY_AMT(p_project_amount,p_project_currency),
					p_funding_currency,
					PA_CURRENCY.ROUND_TRANS_CURRENCY_AMT(p_funding_amount, p_funding_currency),
					l_program_application_id,
					l_program_update_date,
					p_request_id,
					sysdate,
					l_last_updated_by,
				        l_last_update_date,
					l_last_updated_by);

			WHEN spr_found THEN

				IF g1_debug_mode  = 'Y' THEN
					pa_retention_util.write_log('Update_Retention_Balances: ' || 'Update SPR ');
					pa_retention_util.write_log('Update_Retention_Balances: ' || 'Project Amount :  ' || p_project_amount);
					pa_retention_util.write_log('Update_Retention_Balances: ' || 'Projfunc Amount :  ' || p_projfunc_amount);
					pa_retention_util.write_log('Update_Retention_Balances: ' || 'Funding Amount :  ' || p_funding_amount);
				END IF;

			  UPDATE pa_summary_project_retn
		   	   SET total_retained = PA_CURRENCY.ROUND_TRANS_CURRENCY_AMT(
				 NVL(total_retained,0) + NVL(p_amount,0), invproc_currency_code),
		   	     project_total_retained = PA_CURRENCY.ROUND_TRANS_CURRENCY_AMT(
				 NVL(project_total_retained,0) + NVL(p_project_amount,0),project_currency_code),
		   	     projfunc_total_retained =PA_CURRENCY.ROUND_TRANS_CURRENCY_AMT(
				 NVL(projfunc_total_retained,0) + NVL(p_projfunc_amount,0),projfunc_currency_code),
		   	      funding_total_retained =PA_CURRENCY.ROUND_TRANS_CURRENCY_AMT(
				 NVL(funding_total_retained,0) + NVL(p_funding_amount,0),funding_currency_code)
				 WHERE project_id = p_project_id
				   AND NVL(task_id,-99) = NVL(p_task_id,-99)
		  		   AND agreement_id = p_agreement_id;

		END;

		IF g1_debug_mode  = 'Y' THEN
			pa_retention_util.write_log('Update_Retention_Balances: ' || 'Update Rule level Balance ');
		END IF;
		-- Update the rule level balance
				IF g1_debug_mode  = 'Y' THEN
					pa_retention_util.write_log('Update_Retention_Balances: ' || 'Projfunc Amount :  ' || p_projfunc_amount);
					pa_retention_util.write_log('Update_Retention_Balances: ' || 'Funding Amount :  ' || p_funding_amount);
					pa_retention_util.write_log('Update_Retention_Balances: ' || 'Funding Amount :  ' || p_funding_amount);
				END IF;


		UPDATE pa_proj_retn_rules
		   SET total_retained = NVL(total_retained,0) +
					PA_CURRENCY.ROUND_TRANS_CURRENCY_AMT( NVL(p_amount,0),p_invproc_currency),
		       projfunc_total_retained = PA_CURRENCY.ROUND_TRANS_CURRENCY_AMT(
					 NVL(projfunc_total_retained,0) + NVL(p_projfunc_amount,0), p_projfunc_currency),
		       project_total_retained = PA_CURRENCY.ROUND_TRANS_CURRENCY_AMT(
				 NVL(project_total_retained,0) + NVL(p_project_amount,0), p_project_currency)
		WHERE retention_rule_id = p_retention_rule_id;

         END IF;  -- Handle the old Credit memos

	ELSIF p_change_type = 'BILLED' THEN

		-- Update project or top task, agreement level
		IF g1_debug_mode  = 'Y' THEN
			pa_retention_util.write_log('Update_Retention_Balances: ' || 'Update SPR for Billed Amount ');
			pa_retention_util.write_log('Update_Retention_Balances: ' || 'Project_id   :  ' || p_project_id);
			pa_retention_util.write_log('Update_Retention_Balances: ' || 'Agreement Id :  ' || p_agreement_id);
			pa_retention_util.write_log('Update_Retention_Balances: ' || 'Task  Id     :  ' || p_task_id);
			pa_retention_util.write_log('Update_Retention_Balances: ' || 'Invproc Amount :  ' || p_amount);
			pa_retention_util.write_log('Update_Retention_Balances: ' || 'Projfunc Amount :  ' || p_projfunc_amount);
			pa_retention_util.write_log('Update_Retention_Balances: ' || 'Funding Amount :  ' || p_funding_amount);
			pa_retention_util.write_log('Update_Retention_Balances: ' || 'Project Amount :  ' || p_project_amount);
			pa_retention_util.write_log('Update_Retention_Balances: ' || 'Invproc Amount :  ' || p_amount);
		END IF;

		UPDATE pa_summary_project_retn
		   SET total_billed = NVL(total_billed,0) +
                                 PA_CURRENCY.ROUND_TRANS_CURRENCY_AMT( NVL(p_amount,0),p_invproc_currency),
		      project_total_billed = NVL(project_total_billed,0) +
                                 PA_CURRENCY.ROUND_TRANS_CURRENCY_AMT( NVL(p_project_amount,0),p_project_currency),
		      projfunc_total_billed = NVL(projfunc_total_billed,0) +
                                 PA_CURRENCY.ROUND_TRANS_CURRENCY_AMT(NVL(p_projfunc_amount,0),p_projfunc_currency),
		      funding_total_billed = NVL(funding_total_billed,0) +
                                 PA_CURRENCY.ROUND_TRANS_CURRENCY_AMT(NVL(p_funding_amount,0), p_funding_currency)
		 WHERE project_id = p_project_id
		   AND NVL(task_id,-99) = NVL(p_task_id,-99)
		   AND agreement_id = p_agreement_id;

	IF g1_debug_mode  = 'Y' THEN
	pa_retention_util.write_log('No of Records are Updated : ' || sql%rowcount);
	END IF;

	END IF;



	/*
	    Bug: 2385742.
           Since the billing invoice will refer this table to find the retention rule id
           it should not be deleted

        Delete the 0 Amount Summary Retn Records and project_retention records
	IF g1_debug_mode  = 'Y' THEN
		pa_retention_util.write_log('Update_Retention_Balances: ' || 'Delete from pa_project_retentions ');
	END IF;

	  DELETE FROM pa_project_retentions
	WHERE project_id = p_project_id
	  AND NVL(task_id,-99) = NVL(p_task_id,-99)
	  AND agreement_id = p_agreement_id
	  AND retention_rule_id = p_retention_rule_id
	  AND NVL(total_retained,0) = 0
	  AND NVL(project_total_retained,0) = 0
	  AND NVL(projfunc_total_retained,0) = 0
	  AND NVL(funding_total_retained,0) = 0;


	IF g1_debug_mode  = 'Y' THEN
		pa_retention_util.write_log('No of Records are deleted : ' || sql%rowcount);
		pa_retention_util.write_log('Update_Retention_Balances: ' || 'Delete from pa_summary_project_retn ');
	END IF;

	DELETE FROM pa_summary_project_retn
	WHERE project_id = p_project_id
	  AND NVL(task_id,-99) = NVL(p_task_id,-99)
	  AND agreement_id = p_agreement_id
	  AND NVL(total_retained,0) = 0
	  AND NVL(project_total_retained,0) = 0
	  AND NVL(projfunc_total_retained,0) = 0
	  AND NVL(funding_total_retained,0) = 0
	  AND NVL(total_billed,0) = 0
	  AND NVL(project_total_billed,0) = 0
	  AND NVL(projfunc_total_billed,0) = 0
	  AND NVL(funding_total_billed,0) = 0;

	IF g1_debug_mode  = 'Y' THEN
	pa_retention_util.write_log('No of Records are deleted : ' || sql%rowcount);
	END IF;

	 Bug: 2385742  end of the code changes */

	IF g1_debug_mode  = 'Y' THEN
		pa_retention_util.write_log('Update_Retention_Balances: ' || 'Leaving from Update Retention Balances ');
	END IF;
EXCEPTION
WHEN OTHERS THEN
IF g1_debug_mode  = 'Y' THEN
	pa_retention_util.write_log('Update_Retention_Balances: ' || 'Oracle Error ' || sqlerrm);
END IF;
   RAISE;

END Update_Retention_Balances;
-- Procedure Update_Retn_Bill_Trans_Amount
-- Purpose   Bill trans amount should be updated only if the project is invoice by bill trans currency

PROCEDURE Update_Retn_Bill_Trans_Amount(p_project_id            IN NUMBER,
                                        p_draft_invoice_num     IN NUMBER,
				        p_bill_trans_currency   IN VARCHAR2,
                                        p_request_id            IN NUMBER) IS

BEGIN
	UPDATE pa_draft_invoice_items
	    SET bill_trans_currency_code = p_bill_trans_currency,
		inv_amount =PA_CURRENCY.ROUND_TRANS_CURRENCY_AMT(bill_trans_bill_amount, trim(p_bill_trans_currency)),
		request_id = p_request_id
	WHERE DRAFT_invoice_num = p_draft_invoice_num
          AND invoice_line_type = 'RETENTION'
          AND project_id = p_project_id;

EXCEPTION
WHEN OTHERS THEN
IF g1_debug_mode  = 'Y' THEN
	pa_retention_util.write_log('Update_Retn_Bill_Trans_Amount: ' || 'Oracle Error ' || sqlerrm);
END IF;
  RAISE;

END Update_Retn_Bill_Trans_Amount;


--- Procedure Create_Proj_Inv_Retn_lines
--- Create Project Invoice Retention Lines

PROCEDURE Create_Proj_Inv_Retn_Lines(	p_project_id  		IN  	NUMBER,
					p_customer_id		IN	NUMBER,
					p_agreement_id		IN	NUMBER,
                           		p_draft_invoice_num 	IN 	NUMBER,
					p_cust_retn_level	IN	VARCHAR2,
                           		p_request_id		IN 	NUMBER,
                                        p_output_tax_code       IN     VARCHAR2,
                                        p_Output_tax_exempt_flag    IN VARCHAR2,
                                        p_Output_tax_exempt_number  IN VARCHAR2,
                                        p_Output_exempt_reason_code IN VARCHAR2) IS

TYPE RuleAndInvoiced IS RECORD
				(retention_rule_id	NUMBER,
				 source_type		VARCHAR2(10),
				 Invoice_Amount		NUMBER,
				 PFC_Invoice_Amount	NUMBER,
				 PC_Invoice_Amount	NUMBER,
				 FC_Invoice_Amount	NUMBER,
				 BTC_Invoice_Amount	NUMBER);

TYPE TabRuleAndInvoiced IS TABLE OF RuleAndInvoiced
INDEX BY BINARY_INTEGER;

TmpRuleAndInvoiced TabRuleAndInvoiced;

AgreementId		NUMBER:=p_agreement_id;

TmpRetainAmount		NUMBER:=0;
RetentionRuleId		NUMBER:=0;
NewRetentionRuleId	NUMBER:=0;
InvoiceAmount		NUMBER:=0;
PFCInvoiceAmount	NUMBER:=0;
PCInvoiceAmount		NUMBER:=0;
FCInvoiceAmount		NUMBER:=0;
BTCInvoiceAmount	NUMBER:=0;

CurRetainAmount		NUMBER:=0;
PFCCurRetainAmount	NUMBER:=0;
PCCurRetainAmount	NUMBER:=0;
FCCurRetainAmount	NUMBER:=0;
BTCCurRetainAmount	NUMBER:=0;

LastUpdatedBy		NUMBER:= fnd_global.user_id;
l_created_by		NUMBER:= fnd_global.user_id;
l_program_id                  NUMBER:= fnd_global.conc_program_id;
l_program_application_id      NUMBER:= fnd_global.prog_appl_id;
l_program_update_date         DATE  := sysdate;
l_last_update_date            DATE  := sysdate;
l_last_updated_by             NUMBER:= fnd_global.user_id;
l_last_update_login           NUMBER:= fnd_global.login_id;

ProjectCurrency		VARCHAR2(15);
ProjFuncCurrency	VARCHAR2(15);
FundingCurrency		VARCHAR2(15);
InvProcCurrency		VARCHAR2(15);
InvProcCurrType		VARCHAR2(30); --Added for Bug3604143
BillTransCurrency	VARCHAR2(15);

InvRetnLineFmt		Pa_Retention_Pkg.TabInvRetnLineFormat;

TmpCnt			BINARY_INTEGER:=0;
UpdateRDL		BOOLEAN := FALSE;
UpdateERDL		BOOLEAN := FALSE;
UpdateDII		BOOLEAN := FALSE;
LastLineNum		NUMBER:=0;
RetnRemainAmount	NUMBER:=0;
RetnLineText		VARCHAR(500);
RetnRuleText		VARCHAR(300); /** Increased Length to 300 from 120 bug 2318898 **/
LastEndPosition		NUMBER :=0;


CURSOR cur_invoice IS
	SELECT  AMT.retention_rule_id retention_rule_id,
		 AMT.source_type source_type,
		 AMT.invoice_amount invoice_amount,
		 AMT.pfc_invoice_amount pfc_invoice_amount,
		 AMT.pc_invoice_amount pc_invoice_amount,
		 AMT.fc_invoice_amount fc_invoice_amount,
		 AMT.btc_invoice_amount btc_invoice_amount
	  FROM ( SELECT rdl.retention_rule_id retention_rule_id,'RDL' source_type,
		       SUM(rdl.bill_amount) invoice_amount,
		       SUM(rdl.projfunc_bill_amount) pfc_invoice_amount,
		       SUM(rdl.project_bill_amount)  pc_invoice_amount,
		       SUM(rdl.funding_bill_amount)  fc_invoice_amount,
		       SUM(rdl.bill_trans_bill_amount)  btc_invoice_amount
  		  FROM pa_cust_rev_dist_lines_all rdl
  		 WHERE rdl.project_id = p_project_id
   		   AND  rdl.request_id = p_request_id
   		   AND  rdl.draft_invoice_num = p_draft_invoice_num
		     GROUP BY rdl.retention_rule_id
   		UNION
		SELECT erdl.retention_rule_id retention_rule_id,
			'ERDL' source_type,
                       --SUM(erdl.amount) invoice_amount, --Modified for Bug3604143
		       decode(InvProcCurrType, 'PROJECT_CURRENCY', SUM(erdl.project_bill_amount),
                                               'PROJFUNC_CURRENCY', SUM(erdl.projfunc_bill_amount),
                                               'FUNDING_CURRENCY', SUM(erdl.funding_bill_amount)) invoice_amount,
		       SUM(erdl.projfunc_bill_amount) pfc_invoice_amount,
		       SUM(erdl.project_bill_amount)  pc_invoice_amount,
		       SUM(erdl.funding_bill_amount)  fc_invoice_amount,
		       SUM(erdl.bill_trans_amount)  btc_invoice_amount
  		FROM pa_cust_event_rdl_all erdl
  		 WHERE erdl.project_id = p_project_id
   		   AND  erdl.request_id = p_request_id
   		   AND  erdl.draft_invoice_num = p_draft_invoice_num
		     GROUP BY erdl.retention_rule_id
		UNION
 		SELECT dii.retention_rule_id retention_rule_id,
			'EVENT' source_type,
			 SUM(dii.amount) invoice_amount,
		       SUM(dii.projfunc_bill_amount) pfc_invoice_amount,
		       SUM(dii.project_bill_amount)  pc_invoice_amount,
		       SUM(dii.funding_bill_amount)  fc_invoice_amount,
		       SUM(dii.bill_trans_bill_amount)  btc_invoice_amount
		FROM pa_draft_invoice_items dii
		WHERE dii.project_id = p_project_id
		  AND dii.request_id = p_request_id
		  AND dii.draft_invoice_num = p_draft_invoice_num
		  AND dii.event_num IS NOT NULL
		GROUP BY dii.retention_rule_id ) AMT,
			PA_PROJ_RETN_RULES  RT
		where amt.retention_rule_id = RT.retention_rule_id
		ORDER BY RT.task_id, RT.expenditure_category, RT.expenditure_type, RT.NON_LABOR_RESOURCE,
                         RT.REVENUE_CATEGORY_CODE, RT.EVENT_TYPE, RT.EFFECTIVE_START_DATE, RT.EFFECTIVE_END_DATE;

invoice_rec	cur_invoice%ROWTYPE;

CURSOR cur_retn_rule IS
		SELECT 	rt.retention_rule_id retention_rule_id,
			rt.retention_percentage retention_percentage,
		       	rt.retention_amount retention_amount,
			rt.threshold_amount threshold_amount ,
			rt.total_retained total_retained,
		       	rt.retention_level_code retention_level_code,
		       	rt.non_labor_resource non_labor_resource,
			rt.expenditure_type expenditure_type,
		       	rt.expenditure_category expenditure_category,
			rt.event_type event_type,
		       	rt.revenue_category_code revenue_category_code,
		       	rt.effective_start_date effective_start_date,
		       	rt.effective_end_date effective_end_date ,
			tsk.task_number task_number,
			tsk.task_name task_name,
			rt.task_id task_id
		  FROM pa_proj_retn_rules rt,  pa_tasks tsk
		 WHERE rt.retention_rule_id = RetentionRuleID
		   AND rt.task_id = tsk.task_id(+);

retn_rule_rec cur_retn_rule%ROWTYPE;

BEGIN

	IF g1_debug_mode  = 'Y' THEN
		pa_retention_util.write_log('Entering Create_Proj_Inv_Retn_Lines');
		pa_retention_util.write_log('Create_Proj_Inv_Retn_Lines: ' || 'Project Id : ' || p_project_id);
		pa_retention_util.write_log('Create_Proj_Inv_Retn_Lines: ' || 'Request Id : ' || p_request_id);
		pa_retention_util.write_log('Create_Proj_Inv_Retn_Lines: ' || 'Invoice Num  : ' || p_draft_invoice_num);
		pa_retention_util.write_log('Create_Proj_Inv_Retn_Lines: ' || 'Agrrement Id  : ' || AgreementId);
	END IF;

--Moved the following code here for Bug3604143
	   -- Select the Funding Currency

	      SELECT agreement_currency_code
		INTO FundingCurrency
		FROM pa_agreements_all agr,pa_draft_invoices_all di
	       WHERE agr.agreement_id = di.agreement_id
		 AND di.project_id =  p_project_id
		 AND di.draft_invoice_num =  p_draft_invoice_num;

	      SELECT pr.project_currency_code,
  		     pr.projfunc_currency_code,
 		     decode(pr.invproc_currency_type,'PROJECT_CURRENCY', pr.project_currency_code,
     			'PROJFUNC_CURRENCY',pr.projfunc_currency_code,
    			'FUNDING_CURRENCY', FundingCurrency) Invproc_currency, pr.invproc_currency_type
		INTO ProjectCurrency, ProjFuncCUrrency, InvProcCurrency, InvProcCurrType
	 	FROM pa_projects_all pr
	        WHERE pr.project_id = p_project_id;
--till here for Bug3604143

	OPEN cur_invoice;
		IF g1_debug_mode  = 'Y' THEN
			pa_retention_util.write_log('Create_Proj_Inv_Retn_Lines: ' || 'Build PL/SQL Table for Rules ');
		END IF;
	LOOP
		FETCH cur_invoice INTO invoice_rec;
		EXIT WHEN cur_invoice%NOTFOUND;
		TmpCnt :=  NVL(TmpCnt,0) +1;
		IF g1_debug_mode  = 'Y' THEN
			pa_retention_util.write_log('Create_Proj_Inv_Retn_Lines: ' || 'Rule Table for ' || TmpCnt);
		END IF;

		TmpRuleAndInvoiced(TmpCnt).retention_rule_id 	:= invoice_rec.retention_rule_id;
		TmpRuleAndInvoiced(TmpCnt).source_type 		:= invoice_rec.source_type;
		TmpRuleAndInvoiced(TmpCnt).invoice_amount 	:= invoice_rec.invoice_amount;
		TmpRuleAndInvoiced(TmpCnt).pfc_invoice_amount 	:= invoice_rec.pfc_invoice_amount;
		TmpRuleAndInvoiced(TmpCnt).pc_invoice_amount 	:= invoice_rec.pc_invoice_amount;
		TmpRuleAndInvoiced(TmpCnt).fc_invoice_amount 	:= invoice_rec.fc_invoice_amount;
		TmpRuleAndInvoiced(TmpCnt).btc_invoice_amount 	:= invoice_rec.btc_invoice_amount;

		IF g1_debug_mode  = 'Y' THEN
			pa_retention_util.write_log('Create_Proj_Inv_Retn_Lines: ' || 'Rule ID      :  ' || invoice_rec.retention_rule_id);
			pa_retention_util.write_log('Create_Proj_Inv_Retn_Lines: ' || 'Source Type  :  ' || invoice_rec.source_type);
			pa_retention_util.write_log('Create_Proj_Inv_Retn_Lines: ' || 'invoice_amount  :  ' || invoice_rec.invoice_amount);
			pa_retention_util.write_log('Create_Proj_Inv_Retn_Lines: ' || 'pfc_invoice_amount  :  ' || invoice_rec.pfc_invoice_amount);
			pa_retention_util.write_log('Create_Proj_Inv_Retn_Lines: ' || 'pc_invoice_amount  :  ' || invoice_rec.pc_invoice_amount);
			pa_retention_util.write_log('Create_Proj_Inv_Retn_Lines: ' || 'fc_invoice_amount :  ' || invoice_rec.fc_invoice_amount);
			pa_retention_util.write_log('Create_Proj_Inv_Retn_Lines: ' || 'btc_invoice_amount :  ' || invoice_rec.btc_invoice_amount);
		END IF;

        END LOOP;

	CLOSE cur_invoice;

	IF NVL(TmpCnt,0) <> 0 THEN    -- Count is not equal zero

		IF NVL(TmpCnt,0) >= 2 THEN

			IF TmpRuleAndInvoiced(TmpCnt).retention_rule_id <>
			   TmpRuleAndInvoiced(TmpCnt-1).retention_rule_id THEN

				TmpCnt := NVL(TmpCnt,0)+1;

				TmpRuleAndInvoiced(TmpCnt).retention_rule_id 	:=  TmpRuleAndInvoiced(TmpCnt-1).retention_rule_id ;
				TmpRuleAndInvoiced(TmpCnt).source_type 		:= TmpRuleAndInvoiced(TmpCnt-1).source_type;
				TmpRuleAndInvoiced(TmpCnt).invoice_amount 	:= 0;
				TmpRuleAndInvoiced(TmpCnt).pfc_invoice_amount 	:= 0;
				TmpRuleAndInvoiced(TmpCnt).pc_invoice_amount 	:= 0;
				TmpRuleAndInvoiced(TmpCnt).fc_invoice_amount 	:= 0;
				TmpRuleAndInvoiced(TmpCnt).btc_invoice_amount 	:= 0;

			END IF;

		END IF;


		IF g1_debug_mode  = 'Y' THEN
			pa_retention_util.write_log('Create_Proj_Inv_Retn_Lines: ' || 'Select Funding Currency ');
		END IF;

/* Commented and moved this code in the beginning for Bug3604143
	   -- Select the Funding Currency

	      SELECT agreement_currency_code
		INTO FundingCurrency
		FROM pa_agreements_all agr,pa_draft_invoices_all di
	       WHERE agr.agreement_id = di.agreement_id
		 AND di.project_id =  p_project_id
		 AND di.draft_invoice_num =  p_draft_invoice_num;
*/

		IF g1_debug_mode  = 'Y' THEN
			pa_retention_util.write_log('Create_Proj_Inv_Retn_Lines: ' || 'Funding Currency  : ' || FundingCurrency);
		END IF;

	   -- Get all the currency code for this project

		IF g1_debug_mode  = 'Y' THEN
			pa_retention_util.write_log('Create_Proj_Inv_Retn_Lines: ' || 'Finding Invoice Processing Currency');
		END IF;

/* Commented and moved this code in the beginning for Bug3604143
	      SELECT pr.project_currency_code,
  		     pr.projfunc_currency_code,
 		     decode(pr.invproc_currency_type,'PROJECT_CURRENCY', pr.project_currency_code,
     			'PROJFUNC_CURRENCY',pr.projfunc_currency_code,
    			'FUNDING_CURRENCY', FundingCurrency) Invproc_currency
		INTO ProjectCurrency, ProjFuncCUrrency, InvProcCurrency
	 	FROM pa_projects_all pr
	        WHERE pr.project_id = p_project_id;
*/

		IF g1_debug_mode  = 'Y' THEN
			pa_retention_util.write_log('Create_Proj_Inv_Retn_Lines: ' || 'Invoice Processing Currency : ' || InvProcCurrency);
			pa_retention_util.write_log('Create_Proj_Inv_Retn_Lines: ' || 'Calling Get_Proj_Inv_Retn_Format');
		END IF;

		 InvRetnLineFmt := Get_Proj_Inv_Retn_Format(p_project_id =>p_project_id);


		IF g1_debug_mode  = 'Y' THEN
			pa_retention_util.write_log('Create_Proj_Inv_Retn_Lines: ' || 'Processing Rules');
		END IF;

	FOR j IN 1..TmpCnt LOOP  -- For loop starts for Retention Rules

	    IF g1_debug_mode  = 'Y' THEN
	    	pa_retention_util.write_log('Create_Proj_Inv_Retn_Lines: ' || 'Row Num  : ' || j);
	    	pa_retention_util.write_log('Create_Proj_Inv_Retn_Lines: ' || 'Current RetentionRuleId    : ' || TmpRuleAndInvoiced(j).retention_rule_id);
	    	pa_retention_util.write_log('Create_Proj_Inv_Retn_Lines: ' || 'RetentionRuleId    : ' || RetentionRuleId);
	    	pa_retention_util.write_log('Create_Proj_Inv_Retn_Lines: ' || 'NewRetentionRuleId : ' || NewRetentionRuleId);
	        	pa_retention_util.write_log('Create_Proj_Inv_Retn_Lines: ' || 'Source Type : ' || TmpRuleAndInvoiced(j).source_type);
	        END IF;

	    IF NVL(RetentionRuleId,0) = 0 and NVL(NewRetentionRuleID,0) =0 THEN -- If it is a first run

	         IF g1_debug_mode  = 'Y' THEN
	         	pa_retention_util.write_log('Create_Proj_Inv_Retn_Lines: ' || 'For First Rule ');
	         END IF;

		NewRetentionRuleId := TmpRuleAndInvoiced(j).retention_rule_id;
		RetentionRuleId := TmpRuleAndInvoiced(j).retention_rule_id;
		InvoiceAmount	:=0;
		PFCInvoiceAmount:=0;
		PCInvoiceAmount	:=0;
		FCInvoiceAmount	:=0;
		BTCInvoiceAmount :=0;  --For Bug 5194917

	        IF g1_debug_mode  = 'Y' THEN
	        	pa_retention_util.write_log('Create_Proj_Inv_Retn_Lines: ' || '1st run RetentionRuleId    : ' || RetentionRuleId);
	        	pa_retention_util.write_log('Create_Proj_Inv_Retn_Lines: ' || '1st run NewRetentionRuleId : ' || NewRetentionRuleId);
	        	pa_retention_util.write_log('Create_Proj_Inv_Retn_Lines: ' || '1st run Source Type : ' || TmpRuleAndInvoiced(j).source_type);
	        END IF;

		IF RTRIM(TmpRuleAndInvoiced(j).source_type) ='RDL' THEN

		    UpdateRDL		:= TRUE;
		    IF g1_debug_mode  = 'Y' THEN
		    	pa_retention_util.write_log('Create_Proj_Inv_Retn_Lines: ' || 'UpdateRDL= True');
		    END IF;

		ELSIF RTRIM(TmpRuleAndInvoiced(j).source_type) ='ERDL' THEN

		      UpdateERDL	:= TRUE;

		    IF g1_debug_mode  = 'Y' THEN
		    	pa_retention_util.write_log('Create_Proj_Inv_Retn_Lines: ' || 'UpdateERDL= True');
		    END IF;

		ELSIF RTRIM(TmpRuleAndInvoiced(j).source_type) ='EVENT' THEN

		     UpdateDII	:= TRUE;

		    IF g1_debug_mode  = 'Y' THEN
		    	pa_retention_util.write_log('Create_Proj_Inv_Retn_Lines: ' || 'UpdateDII= True');
		    END IF;

		END IF;

            ELSE     -- for rule is different
		NewRetentionRuleId := TmpRuleAndInvoiced(j).retention_rule_id;

	     END IF;

	    IF NVL(RetentionRuleID,0) = NVL(NewRetentionRuleId,0) THEN  -- if the rule is same

			InvoiceAmount	:= InvoiceAmount + NVL(TmpRuleAndInvoiced(j).Invoice_Amount,0);
			PFCInvoiceAmount:= PFCInvoiceAmount + NVL(TmpRuleAndInvoiced(j).PFC_Invoice_Amount,0);
			PCInvoiceAmount	:= PCInvoiceAmount + NVL(TmpRuleAndInvoiced(j).PC_Invoice_Amount,0);
			FCInvoiceAmount	:= FCInvoiceAmount + NVL(TmpRuleAndInvoiced(j).FC_Invoice_Amount,0);
			BTCInvoiceAmount:= BTCInvoiceAmount + NVL(TmpRuleAndInvoiced(j).BTC_Invoice_Amount,0);

			IF RTRIM(TmpRuleAndInvoiced(j).source_type) ='RDL' THEN

			      UpdateRDL		:= TRUE;

		    	      IF g1_debug_mode  = 'Y' THEN
		    	      	pa_retention_util.write_log('Create_Proj_Inv_Retn_Lines: ' || 'UpdateRDL= True');
		    	      END IF;

			ELSIF RTRIM(TmpRuleAndInvoiced(j).source_type) ='ERDL' THEN

			      UpdateERDL	:= TRUE;
		    	      IF g1_debug_mode  = 'Y' THEN
		    	      	pa_retention_util.write_log('Create_Proj_Inv_Retn_Lines: ' || 'UpdateERDL= True');
		    	      END IF;

			ELSIF RTRIM(TmpRuleAndInvoiced(j).source_type) ='EVENT' THEN

			      UpdateDII	:= TRUE;
		    	      IF g1_debug_mode  = 'Y' THEN
		    	      	pa_retention_util.write_log('Create_Proj_Inv_Retn_Lines: ' || 'UpdateDII= True');
		    	      END IF;

			END IF;

		END IF;

		IF (RetentionRuleID <> NewRetentionRuleId) OR (j=TmpCnt) THEN -- rule changes

		    	      IF g1_debug_mode  = 'Y' THEN
		    	      	pa_retention_util.write_log('Create_Proj_Inv_Retn_Lines: ' || 'Create Retention Line ');
		    	      END IF;

	      		BEGIN
				OPEN cur_retn_rule;
				FETCH cur_retn_rule INTO retn_rule_rec;

					-- Find the whethoer any amounts to be retained or not

		    	      IF g1_debug_mode  = 'Y' THEN
		    	      	pa_retention_util.write_log('Create_Proj_Inv_Retn_Lines: ' || 'Check Threshold');
		    	      END IF;

				   IF ( ( NVL(retn_rule_rec.threshold_amount,0) >
				 	NVL(retn_rule_rec.total_retained,0) )
					OR (NVL(retn_rule_rec.threshold_amount,0)=0) ) THEN

		    	      		IF g1_debug_mode  = 'Y' THEN
		    	      			pa_retention_util.write_log('Create_Proj_Inv_Retn_Lines: ' || ' If NVL(retn_rule_rec.threshold_amount,0) >
                                        NVL(retn_rule_rec.total_retained,0)');
		    	      		END IF;

					-- Remaining amount to retain

					IF NVL(retn_rule_rec.threshold_amount,0)<> 0  THEN

		    	      		IF g1_debug_mode  = 'Y' THEN
		    	      			pa_retention_util.write_log('Create_Proj_Inv_Retn_Lines: ' || ' IF NVL(retn_rule_rec.threshold_amount,0)<> 0 ');
		    	      		END IF;

						RetnRemainAmount :=NVL(retn_rule_rec.threshold_amount,0) -
						NVL(retn_rule_rec.total_retained,0);
		    	      		IF g1_debug_mode  = 'Y' THEN
		    	      			pa_retention_util.write_log('Create_Proj_Inv_Retn_Lines: ' || 'retn_rule_rec.threshold_amount:  ' || retn_rule_rec.threshold_amount);
		    	      			pa_retention_util.write_log('Create_Proj_Inv_Retn_Lines: ' || 'retn_rule_rec.total_retained:  ' || retn_rule_rec.total_retained);
		    	      			pa_retention_util.write_log('Create_Proj_Inv_Retn_Lines: ' || 'RetnRemainAmount:  ' || RetnRemainAmount);
		    	      		END IF;

					END IF;

		    	      		IF g1_debug_mode  = 'Y' THEN
		    	      			pa_retention_util.write_log('Create_Proj_Inv_Retn_Lines: ' || 'RetnRemainAmount:  ' || RetnRemainAmount);
		    	      		END IF;

					-- Check if the retention percentage is not equal to zero

					IF NVL(retn_rule_rec.retention_percentage,0) <> 0 THEN
		    	      		IF g1_debug_mode  = 'Y' THEN
		    	      			pa_retention_util.write_log('Create_Proj_Inv_Retn_Lines: ' || 'If the percentage is not equal to zero' );
		    	      		END IF;

						TmpRetainAmount := NVL(InvoiceAmount,0) *
				             	(NVL(retn_rule_rec.retention_percentage,0)/100);
		    	      		IF g1_debug_mode  = 'Y' THEN
		    	      			pa_retention_util.write_log('Create_Proj_Inv_Retn_Lines: ' || 'TmpRetainAmount:  ' || TmpRetainAmount);
		    	      		END IF;
					--For Bug 5194917
			/*		ELSIF NVL(retn_rule_rec.retention_percentage,0) = 0 THEN
		    	      		IF g1_debug_mode  = 'Y' THEN
		    	      			pa_retention_util.write_log('Create_Proj_Inv_Retn_Lines: ' || 'If the percentage is equal to zero' );
		    	      		END IF;

						TmpRetainAmount := 0;
		    	      		IF g1_debug_mode  = 'Y' THEN
		    	      			pa_retention_util.write_log('Create_Proj_Inv_Retn_Lines: ' || 'TmpRetainAmount:  ' || TmpRetainAmount);
		    	      		END IF; Commented for Bug  6152291*/
					--End of changes for Bug 5194917
					ELSIF NVL(retn_rule_rec.retention_amount,0) <> 0 THEN

						-- Check if the retention amount is not equal to zero
		    	      		IF g1_debug_mode  = 'Y' THEN
		    	      			pa_retention_util.write_log('Create_Proj_Inv_Retn_Lines: ' || 'If the retention amount is not equal to zero' );
		    	      		END IF;

						TmpRetainAmount := NVL(retn_rule_rec.retention_amount,0);
		    	      		IF g1_debug_mode  = 'Y' THEN
		    	      			pa_retention_util.write_log('Create_Proj_Inv_Retn_Lines: ' || 'TmpRetainAmount:  ' || TmpRetainAmount);
		    	      		END IF;

						IF NVL(retn_rule_rec.retention_amount,0) > NVL(InvoiceAmount,0) THEN
		    	      		           IF g1_debug_mode  = 'Y' THEN
		    	      		           	pa_retention_util.write_log('Create_Proj_Inv_Retn_Lines: ' || 'Retention Amount > InvoiceAmount');
		    	      		           END IF;
						   TmpRetainAmount := NVL(InvoiceAmount,0);
		    	      			  IF g1_debug_mode  = 'Y' THEN
		    	      			  	pa_retention_util.write_log('Create_Proj_Inv_Retn_Lines: ' || 'TmpRetainAmount:  ' || TmpRetainAmount);
		    	      			  END IF;
						END IF;
					--For Bug 5194917
					ELSIF NVL(retn_rule_rec.retention_amount,0) = 0 and NVL(retn_rule_rec.retention_percentage,0) = 0 THEN /* Added and condition for bug 6152291*/

						-- Check if the retention amount is equal to zero
		    	      		IF g1_debug_mode  = 'Y' THEN
		    	      			pa_retention_util.write_log('Create_Proj_Inv_Retn_Lines: ' || 'If the retention amount is equal to zero' );
		    	      		END IF;

						TmpRetainAmount := 0;
		    	      		IF g1_debug_mode  = 'Y' THEN
		    	      			pa_retention_util.write_log('Create_Proj_Inv_Retn_Lines: ' || 'TmpRetainAmount:  ' || TmpRetainAmount);
		    	      		END IF;
					--End of Bug 5194917
					END IF;

					-- There is no threshold,retain full amount

					IF NVL(retn_rule_rec.threshold_amount,0)<> 0  THEN

					-- If the Current Retain amount is less or equal
		    	      		IF g1_debug_mode  = 'Y' THEN
		    	      			pa_retention_util.write_log('Create_Proj_Inv_Retn_Lines: ' || 'If threshold is not equal to zero ');
		    	      		END IF;

						IF NVL(TmpRetainAmount,0) <= NVL(RetnRemainAmount,0) THEN
		    	      		        IF g1_debug_mode  = 'Y' THEN
		    	      		        	pa_retention_util.write_log('Create_Proj_Inv_Retn_Lines: ' || 'If TmpRetainAmount <= RetnRemainAmount ');
		    	      		        END IF;

							CurRetainAmount	:=  NVL(TmpRetainAmount,0);

		    	      		        	IF g1_debug_mode  = 'Y' THEN
		    	      		        		pa_retention_util.write_log('Create_Proj_Inv_Retn_Lines: ' || 'CurRetainAmount :' || CurRetainAmount );
		    	      		        	END IF;


						ELSIF NVL(TmpRetainAmount,0) > NVL(RetnRemainAmount,0) THEN

							-- If the Current Retain amount is less or equal
		    	      		        IF g1_debug_mode  = 'Y' THEN
		    	      		        	pa_retention_util.write_log('Create_Proj_Inv_Retn_Lines: ' || 'If TmpRetainAmount > RetnRemainAmount ');
		    	      		        END IF;

							CurRetainAmount	:=  NVL(RetnRemainAmount,0);
		    	      		        	IF g1_debug_mode  = 'Y' THEN
		    	      		        		pa_retention_util.write_log('Create_Proj_Inv_Retn_Lines: ' || 'CurRetainAmount :' || CurRetainAmount );
		    	      		        	END IF;

						END IF;
					ELSE
		    	      		        	IF g1_debug_mode  = 'Y' THEN
		    	      		        		pa_retention_util.write_log('Create_Proj_Inv_Retn_Lines: ' || 'No threshold');
		    	      		        	END IF;
							CurRetainAmount	:=  NVL(TmpRetainAmount,0);
		    	      		        	IF g1_debug_mode  = 'Y' THEN
		    	      		        		pa_retention_util.write_log('Create_Proj_Inv_Retn_Lines: ' || 'CurRetainAmount :' || CurRetainAmount );
		    	      		        	END IF;
					END IF;


					CurRetainAmount := PA_CURRENCY.ROUND_TRANS_CURRENCY_AMT(
						NVL(CurRetainAmount,0),InvProcCurrency);

/* Changed for bug 3132449 .This is done to handle invoices with 0 amount   */

       IF NVL(CurRetainAmount,0) <>0 THEN

					PFCCurRetainAmount := PA_CURRENCY.ROUND_TRANS_CURRENCY_AMT(
							  (NVL(CurRetainAmount,0)/
						     NVL(InvoiceAmount,0)) * NVL(PFCInvoiceAmount,0),ProjfuncCurrency);

					PCCurRetainAmount := PA_CURRENCY.ROUND_TRANS_CURRENCY_AMT(
						 ( NVL(CurRetainAmount,0)/
						     NVL(InvoiceAmount,0)) * NVL(PCInvoiceAmount,0),ProjectCurrency);

					FCCurRetainAmount := PA_CURRENCY.ROUND_TRANS_CURRENCY_AMT(
							( NVL(CurRetainAmount,0)/
						     NVL(InvoiceAmount,0)) * NVL(FCInvoiceAmount,0), FundingCurrency);

					BTCCurRetainAmount :=( NVL(CurRetainAmount,0)/
						     NVL(InvoiceAmount,0)) * NVL(BTCInvoiceAmount,0);

     ELSE

                                        PFCCurRetainAmount :=0;
                                        PCCurRetainAmount  :=0;
                                        FCCurRetainAmount  :=0;
                                        BTCCurRetainAmount :=0;
     END IF;  /*CurRetainAmount */

		    	      		IF g1_debug_mode  = 'Y' THEN
		    	      			pa_retention_util.write_log('Create_Proj_Inv_Retn_Lines: ' || 'InvoiceAmount   : ' || InvoiceAmount);
		    	      			pa_retention_util.write_log('Create_Proj_Inv_Retn_Lines: ' || 'CurRetainAmount : ' || CurRetainAmount
									 ||'  ' || InvProcCurrency);
		    	      			pa_retention_util.write_log('Create_Proj_Inv_Retn_Lines: ' || 'PFCCurRetainAmount :  ' || PFCCurRetainAmount
									 ||'  ' || ProjFuncCUrrency);
		    	      			pa_retention_util.write_log('Create_Proj_Inv_Retn_Lines: ' || 'PCCurRetainAmount  : ' || PCCurRetainAmount
									 ||'  ' || ProjectCurrency);
		    	      			pa_retention_util.write_log('Create_Proj_Inv_Retn_Lines: ' || 'FCCurRetainAmount 	: ' || FCCurRetainAmount
									 ||'  ' || FundingCurrency);
		    	      			pa_retention_util.write_log('Create_Proj_Inv_Retn_Lines: ' || 'BTCCurRetainAmount : ' || BTCCurRetainAmount);
		    	      		END IF;

				END IF;

				IF NVL(CurRetainAmount,0) <>0 THEN

				-- Building the Invoice Retention Line Format
		    	      		IF g1_debug_mode  = 'Y' THEN
		    	      			pa_retention_util.write_log('Create_Proj_Inv_Retn_Lines: ' || 'IF NVL(CurRetainAmount,0) <>0  ');
		    	      		END IF;

				    IF InvRetnLineFmt.count <> 0 THEN
		    	      		IF g1_debug_mode  = 'Y' THEN
		    	      			pa_retention_util.write_log('Create_Proj_Inv_Retn_Lines: ' || 'InvRetnLineFmt.count : ' ||
						 InvRetnLineFmt.count);
		    	      		END IF;

				    	FOR k IN 1..InvRetnLineFmt.Count LOOP

						-- Set the last end position
				        	IF  NVL(k,0) = 1 THEN
						    LastEndPosition := InvRetnLineFmt(k).end_position;
						    RetnLineText := RPAD(RetnLineText,
								 InvRetnLineFmt(k).start_position
								-1,' ');
						ELSE
						    RetnLineText :=
							RetnLineText ||
							 RPAD(' ',
								 InvRetnLineFmt(k).start_position
								-LastEndPosition,' ');
						    LastEndPosition := InvRetnLineFmt(k).end_position;

						END IF;
		    	      		IF g1_debug_mode  = 'Y' THEN
		    	      			pa_retention_util.write_log('Create_Proj_Inv_Retn_Lines: ' || 'InvRetnLineFmt Row : ' || k);
		    	      			pa_retention_util.write_log('Create_Proj_Inv_Retn_Lines: ' || 'InvRetnLineFmt Column : ' || InvRetnLineFmt(k).column_code);
		    	      		END IF;

					IF InvRetnLineFmt(k).column_code = 'RETENTION PERCENTAGE' THEN

						IF InvRetnLineFmt(k).right_justify_flag = 'N' THEN
							RetnLineText := RetnLineText ||
					           	RPAD(TO_CHAR(NVL(retn_rule_rec.retention_percentage,
								   retn_rule_rec.retention_amount)),
							InvRetnLineFmt(k).end_position-
							InvRetnLineFmt(k).start_position,' ');
						ELSE
							RetnLineText := RetnLineText ||
					           	LPAD(TO_CHAR(NVL(retn_rule_rec.retention_percentage,
								     retn_rule_rec.retention_amount)),
							InvRetnLineFmt(k).end_position-
							InvRetnLineFmt(k).start_position,' ');
						END IF;
		    	      		IF g1_debug_mode  = 'Y' THEN
		    	      			pa_retention_util.write_log('Create_Proj_Inv_Retn_Lines: ' || 'Fmt Text : ' || RetnLineText);
		    	      		END IF;

					ELSIF InvRetnLineFmt(k).column_code = 'TEXT' THEN

						IF InvRetnLineFmt(k).right_justify_flag = 'Y' THEN
							RetnLineText := RetnLineText ||
					           	RPAD(InvRetnLineFmt(k).UserText,
							InvRetnLineFmt(k).end_position-
							InvRetnLineFmt(k).start_position,' ');
						ELSE
							RetnLineText := RetnLineText ||
					           	LPAD( InvRetnLineFmt(k).UserText,
							InvRetnLineFmt(k).end_position-
							InvRetnLineFmt(k).start_position,' ');
						END IF;

					ELSIF InvRetnLineFmt(k).column_code = 'RETENTION BASIS AMOUNT' THEN

				 		IF InvRetnLineFmt(k).right_justify_flag = 'Y' THEN

                                                        RetnLineText := RetnLineText ||
                                                        RPAD(TO_CHAR(InvoiceAmount),
							InvRetnLineFmt(k).end_position-
                                                        InvRetnLineFmt(k).start_position,' ');
				 		ELSE
                                                        RetnLineText := RetnLineText ||
                                                        LPAD(TO_CHAR(InvoiceAmount),
							InvRetnLineFmt(k).end_position-
                                                        InvRetnLineFmt(k).start_position,' ');

					         END IF;

					ELSIF InvRetnLineFmt(k).column_code = 'INVPROC CURRENCY CODE' THEN

				 		IF InvRetnLineFmt(k).right_justify_flag = 'Y' THEN

                                                        RetnLineText := RetnLineText ||
                                                        RPAD(InvProcCurrency,
							InvRetnLineFmt(k).end_position-
                                                        InvRetnLineFmt(k).start_position,' ');

				 		ELSE
                                                        RetnLineText := RetnLineText ||
                                                        LPAD(InvProcCurrency,
							InvRetnLineFmt(k).end_position-
                                                        InvRetnLineFmt(k).start_position,' ');

					         END IF;

					ELSIF InvRetnLineFmt(k).column_code = 'RETENTION RULE' THEN

						RetnRuleText :=NULL;

						IF p_cust_retn_level ='TOP_TASK' THEN

						    RetnRuleText := retn_rule_rec.task_name
								    || ', ';
						END IF;

					       IF retn_rule_rec.retention_level_code ='PROJECT'
						   OR retn_rule_rec.retention_level_code ='TOP_TASK' THEN

                                                   /* Release 12 :  ATG Changes : adding date format for to_char */

						  RetnRuleText :=  RetnRuleText ||
							 TO_CHAR(retn_rule_rec.effective_start_date, 'YYYY/MM/DD') || ' - ' ||
							 TO_CHAR(retn_rule_rec.effective_end_date,'YYYY/MM/DD') ;


						ELSIF retn_rule_rec.retention_level_code ='NON_LABOR' THEN

						  RetnRuleText := RetnRuleText ||
							retn_rule_rec.expenditure_category|| ', ' ||
							retn_rule_rec.expenditure_type|| ', ' ||
							retn_rule_rec.non_labor_resource || ',' ||
							 TO_CHAR(retn_rule_rec.effective_start_date,'YYYY/MM/DD')
							 || ' - ' ||
							 TO_CHAR(retn_rule_rec.effective_end_date,'YYYY/MM/DD') ;

						ELSIF retn_rule_rec.retention_level_code ='EXPENDITURE_TYPE' THEN

						  RetnRuleText := RetnRuleText ||
							retn_rule_rec.expenditure_category|| ', ' ||
							retn_rule_rec.expenditure_type|| ', ' ||
							 TO_CHAR(retn_rule_rec.effective_start_date,'YYYY/MM/DD')
							 || ' - ' ||
							 TO_CHAR(retn_rule_rec.effective_end_date,'YYYY/MM/DD') ;


						ELSIF retn_rule_rec.retention_level_code ='EXPENDITURE_CATEGORY' THEN

						  RetnRuleText := RetnRuleText ||
							retn_rule_rec.expenditure_category|| ', ' ||
							 TO_CHAR(retn_rule_rec.effective_start_date,'YYYY/MM/DD') || ' - ' ||
							 TO_CHAR(retn_rule_rec.effective_end_date,'YYYY/MM/DD') ;


						ELSIF retn_rule_rec.retention_level_code ='EVENT_TYPE' THEN
						    /*The following code has been added to fix bug 3168266 */
                                                   DECLARE
                                                    l_revenue_category_meaning pa_lookups.meaning%TYPE;
                                                   BEGIN
                                                         SELECT meaning
                                                           INTO l_revenue_category_meaning
                                                           FROM pa_lookups
                                                          WHERE lookup_code =retn_rule_rec.revenue_category_code
                                                            AND lookup_type = 'REVENUE CATEGORY';
						  RetnRuleText := RetnRuleText ||
							l_revenue_category_meaning|| ', ' ||
							retn_rule_rec.event_type|| ', ' ||
							TO_CHAR(retn_rule_rec.effective_start_date,'YYYY/MM/DD')
							|| ' - ' ||
							TO_CHAR(retn_rule_rec.effective_end_date,'YYYY/MM/DD') ;
                                                    EXCEPTION
                                                         WHEN OTHERS THEN
                                                                NULL;
                                                    END;
						  /*  RetnRuleText := RetnRuleText ||
							retn_rule_rec.revenue_category_code|| ', ' ||
							retn_rule_rec.event_type|| ', ' ||
							TO_CHAR(retn_rule_rec.effective_start_date,'YYYY/MM/DD')
							|| ' - ' ||
							TO_CHAR(retn_rule_rec.effective_end_date,'YYYY/MM/DD') ;  commented for 3168266 */

						ELSIF retn_rule_rec.retention_level_code ='REVENUE_CATEGORY'
								 THEN
						    /*The following code has been added to fix bug 3168266 */
                                                   DECLARE
                                                    l_revenue_category_meaning1 pa_lookups.meaning%TYPE;
                                                   begin
                                                         SELECT meaning
                                                           INTO l_revenue_category_meaning1
                                                           FROM pa_lookups
                                                          WHERE lookup_code =retn_rule_rec.revenue_category_code
                                                            AND lookup_type = 'REVENUE CATEGORY';
                                                  RetnRuleText := RetnRuleText ||
                                                        l_revenue_category_meaning1|| ', ' ||
                                                        TO_CHAR(retn_rule_rec.effective_start_date,'YYYY/MM/DD')
                                                        || ' - ' ||
                                                        TO_CHAR(retn_rule_rec.effective_end_date,'YYYY/MM/DD') ;

                                                    EXCEPTION
                                                         WHEN OTHERS THEN
                                                                NULL;
                                                    END;

						/* RetnRuleText := RetnRuleText ||
							retn_rule_rec.revenue_category_code|| ', ' ||
							 TO_CHAR(retn_rule_rec.effective_start_date,'YYYY/MM/DD')
							 || ' - ' ||
							 TO_CHAR(retn_rule_rec.effective_end_date,'YYYY/MM/DD') ; commented for bug 3168266 */

						END IF;

						IF InvRetnLineFmt(k).right_justify_flag = 'Y' THEN
							RetnRuleText :=  RPAD(RetnRuleText,
							InvRetnLineFmt(k).end_position-
							InvRetnLineFmt(k).start_position,' ');
						ELSE
							RetnRuleText :=  LPAD( RetnRuleText,
							InvRetnLineFmt(k).end_position-
							InvRetnLineFmt(k).start_position,' ');
						END IF;

						RetnLineText := RetnLineText ||
								RetnRuleText;

					END IF;

					END LOOP;

				   END IF;


				   IF g1_debug_mode  = 'Y' THEN
				   	pa_retention_util.write_log('Create_Proj_Inv_Retn_Lines: ' || 'Line Text :  ' || RetnLineText);
					pa_retention_util.write_log('Create_Proj_Inv_Retn_Lines: ' || 'Calling Get_Invoice_Max_Line');
				   END IF;
				-- Get the Last Invoice Line Number
				LastLineNum := Get_Invoice_Max_Line(p_project_id=>p_project_id,
				     				 p_draft_invoice_num=>p_draft_invoice_num);

				IF g1_debug_mode  = 'Y' THEN
					pa_retention_util.write_log('Create_Proj_Inv_Retn_Lines: ' || 'Invoice_Max_Line  : ' || LastLineNum);
		                	pa_retention_util.write_log('Create_Proj_Inv_Retn_Lines: ' || 'Project Id  : '||p_project_id);
		                	pa_retention_util.write_log('Create_Proj_Inv_Retn_Lines: ' || 'Invoice Nun : '||p_draft_invoice_num);
		                END IF;

				-- Insert a Retention Line

			           INSERT INTO pa_draft_invoice_items
						( PROJECT_ID,
 						  DRAFT_INVOICE_NUM,
 						  LINE_NUM,
 						  AMOUNT,
 						  TEXT,
 						  INVOICE_LINE_TYPE,
 						  TASK_ID,
 						  PROJFUNC_CURRENCY_CODE,
 						  PROJFUNC_BILL_AMOUNT,
 						  PROJECT_CURRENCY_CODE,
 						  PROJECT_BILL_AMOUNT,
 						  FUNDING_CURRENCY_CODE,
 						  FUNDING_BILL_AMOUNT,
 						  BILL_TRANS_BILL_AMOUNT,
 						  INVPROC_CURRENCY_CODE,
 						  RETENTION_RULE_ID,
 						  LAST_UPDATE_LOGIN,
 						  LAST_UPDATE_DATE,
 						  LAST_UPDATED_BY,
 						  CREATION_DATE,
 						  CREATED_BY,
 						  REQUEST_ID,
 						  PROGRAM_APPLICATION_ID,
 					          PROGRAM_ID,
 						  PROGRAM_UPDATE_DATE,
                                                  OUTPUT_TAX_CLASSIFICATION_CODE,
                                  		  OUTPUT_TAX_EXEMPT_FLAG,
/* Bug 3087998 Code and number order is different in values list. Changing here to match the same
                                  		  OUTPUT_TAX_EXEMPT_REASON_CODE,
                                  		  OUTPUT_TAX_EXEMPT_NUMBER
*/
                                  		  OUTPUT_TAX_EXEMPT_NUMBER,
                                  		  OUTPUT_TAX_EXEMPT_REASON_CODE
						 )
					VALUES   (p_project_id,
						  p_draft_invoice_num,
						  LastLineNum,
						 PA_CURRENCY.ROUND_TRANS_CURRENCY_AMT(
						   (-1) * CurRetainAmount, InvProcCurrency),
						  SUBSTR(RetnLineText,1,240),
						  'RETENTION',
						  retn_rule_rec.task_id,
						  ProjFuncCUrrency,
						 PA_CURRENCY.ROUND_TRANS_CURRENCY_AMT(
						  (-1) *  PFCCurRetainAmount,ProjfuncCurrency),
						  ProjectCurrency,
						  PA_CURRENCY.ROUND_TRANS_CURRENCY_AMT(
						  (-1) * PCCurRetainAmount,ProjectCurrency),
						  FundingCurrency,
						  PA_CURRENCY.ROUND_TRANS_CURRENCY_AMT(
						  (-1) * FCCurRetainAmount,FundingCurrency),
						  (-1) * BTCCurRetainAmount,
						  InvProcCurrency,
						  RetentionRuleId,
						  l_last_update_login,
						  sysdate,
						  l_last_updated_by,
						  sysdate,
						  l_created_by,
						  p_request_id,
						  l_program_application_id,
						  l_program_id,
						  sysdate,
 						  p_Output_tax_code,
                                        	  p_Output_tax_exempt_flag,
                                        	  p_Output_tax_exempt_number,
                                        	  p_Output_exempt_reason_code);
				   IF g1_debug_mode  = 'Y' THEN
				   	pa_retention_util.write_log('Rows Inserted : '||sql%rowcount);
				   	pa_retention_util.write_log('Create_Proj_Inv_Retn_Lines: ' || 'Call Update_Retention_Balances');
				   	pa_retention_util.write_log('Create_Proj_Inv_Retn_Lines: ' || 'Retention Rule Id ' || retn_rule_rec.retention_rule_id);
				   END IF;

 		Update_Retention_Balances(p_retention_rule_id=>retn_rule_rec.retention_rule_id,
                                          p_project_id     =>p_project_id,
                                          p_task_id        =>retn_rule_rec.task_id,
                                          p_agreement_id     =>AgreementId,
                                          p_customer_id     =>p_customer_id,
                                          p_amount           =>CurRetainAmount,
                                          p_change_type      =>'RETAINED',
                                          p_request_id       =>p_request_id,
                                          p_invproc_currency =>InvProcCurrency,
                                          p_project_currency =>ProjectCurrency,
                                          p_project_amount   => PCCurRetainAmount,
                                          p_projfunc_currency =>ProjFuncCurrency,
                                          p_projfunc_amount   =>PFCCurRetainAmount,
                                          p_funding_currency  =>FundingCurrency,
                                          p_funding_amount    =>FCCurRetainAmount);

					-- UPDATE  RDL

					IF (UpdateRDL) THEN

						IF g1_debug_mode  = 'Y' THEN
							pa_retention_util.write_log('Create_Proj_Inv_Retn_Lines: ' || 'Update RDLs ');
						END IF;

					   UPDATE pa_cust_rev_dist_lines_all
					     SET retn_draft_invoice_num = p_draft_invoice_num,
						 retn_draft_invoice_line_num = LastLineNum,
						 retained_amount  =
						PA_CURRENCY.ROUND_TRANS_CURRENCY_AMT(
						 ((NVL(bill_amount,0)/NVL(InvoiceAmount,0))
							 * NVL(CurRetainAmount,0)),invproc_currency_code)
						WHERE retention_rule_id = retn_rule_rec.retention_rule_id
						  AND draft_invoice_num = p_draft_invoice_num
						  AND request_id	= p_request_id
					          AND project_id	= p_project_id;

					END IF;

					-- Update ERDL

					IF (UpdateERDL) THEN
						IF g1_debug_mode  = 'Y' THEN
							pa_retention_util.write_log('Create_Proj_Inv_Retn_Lines: ' || 'Update ERDLs ');
						END IF;

					   UPDATE pa_cust_event_rdl_all
					     SET retn_draft_invoice_num = p_draft_invoice_num,
						 retn_draft_invoice_line_num = LastLineNum,
						 retained_amount  =
						PA_CURRENCY.ROUND_TRANS_CURRENCY_AMT(
							 ((NVL(amount,0)/NVL(InvoiceAmount,0))
							 * NVL(CurRetainAmount,0)),invproc_currency_code)
						WHERE retention_rule_id = retn_rule_rec.retention_rule_id
						  AND draft_invoice_num = p_draft_invoice_num
						  AND request_id	= p_request_id
					          AND project_id	= p_project_id;

					END IF;

					-- Update DII

					IF (UpdateDII) THEN

						IF g1_debug_mode  = 'Y' THEN
							pa_retention_util.write_log('Create_Proj_Inv_Retn_Lines: ' || 'Update DII ');
						END IF;

					   UPDATE pa_draft_invoice_items
					     SET retn_draft_invoice_num = p_draft_invoice_num,
						 retn_draft_invoice_line_num = LastLineNum,
						 retained_amount  =
						PA_CURRENCY.ROUND_TRANS_CURRENCY_AMT(
							 ((NVL(amount,0)/NVL(InvoiceAmount,0))
							 * NVL(CurRetainAmount,0)), invproc_currency_code)
						WHERE retention_rule_id = retn_rule_rec.retention_rule_id
						  AND draft_invoice_num = p_draft_invoice_num
						  AND request_id	= p_request_id
					          AND project_id	= p_project_id
					          AND invoice_line_type <> 'RETENTION';

					END IF;

			END IF;

		   NewRetentionRuleId := TmpRuleAndInvoiced(j).retention_rule_id;
		   RetentionRuleId    := TmpRuleAndInvoiced(j).retention_rule_id;
		   InvoiceAmount      :=  NVL(TmpRuleAndInvoiced(j).Invoice_Amount,0);
		   PFCInvoiceAmount   :=  NVL(TmpRuleAndInvoiced(j).PFC_Invoice_Amount,0);
		   PCInvoiceAmount    :=  NVL(TmpRuleAndInvoiced(j).PC_Invoice_Amount,0);
		   FCInvoiceAmount    :=  NVL(TmpRuleAndInvoiced(j).FC_Invoice_Amount,0);
                   BTCInvoiceAmount   :=  NVL(TmpRuleAndInvoiced(j).BTC_Invoice_Amount,0); /* Bug 4947076: Invoice amounts are incorrect when
                                                                                            Invoice by BTC option is enabled */
		      	UpdateRDL	:= FALSE;
		      	UpdateERDL	:= FALSE;
		      	UpdateDII	:= FALSE;

			IF RTRIM(TmpRuleAndInvoiced(j).source_type) ='RDL' THEN

			      UpdateRDL	:= TRUE;

			ELSIF RTRIM(TmpRuleAndInvoiced(j).source_type) ='ERDL' THEN

			      UpdateERDL:= TRUE;

			ELSIF RTRIM(TmpRuleAndInvoiced(j).source_type) ='EVENT' THEN

			      UpdateDII	:= TRUE;

			END IF;

		   CLOSE cur_retn_rule;

		  END;

	        END IF;	-- new is not equal to current

	    IF g1_debug_mode  = 'Y' THEN
	    	pa_retention_util.write_log('Create_Proj_Inv_Retn_Lines: ' || 'Continue Row Num  : ' || j);
	    END IF;

	   END LOOP; -- For loop ends for Retention Rules

	END IF; -- Count is not equal to zero
IF g1_debug_mode  = 'Y' THEN
	pa_retention_util.write_log('Leaving Create_Proj_Inv_Retn_Lines ');
END IF;
EXCEPTION
WHEN OTHERS THEN
IF g1_debug_mode  = 'Y' THEN
	pa_retention_util.write_log('Create_Proj_Inv_Retn_Lines: ' || 'Oracle Error ' || sqlerrm);
END IF;
  RAISE;

END Create_Proj_Inv_Retn_Lines;
-- Procdure	Proj_Invoice_Retn_PRocessing
-- Purpose	To retain the retention amount.
--		This will be called after project invoice generation

PROCEDURE Proj_Invoice_Retn_Processing(	p_project_id	IN 	NUMBER,
				       	p_request_id 	IN 	NUMBER,
					x_return_status OUT	NOCOPY VARCHAR2) IS --File.Sql.39 bug 4440895

-- Cursor to select to projects for retention
CURSOR cur_proj_cust IS SELECT pc.project_id project_id,
		       pc.customer_id customer_id,
		       pc.retention_level_code retention_level,
		       pc.bill_to_address_id bill_to_address_id,
                       pc.ship_to_address_id ship_to_address_id,
		       imp.set_of_books_id set_of_books_id,
                       pc.bill_to_customer_id bill_to_customer_id,
                       pc.ship_to_customer_id ship_to_customer_id,/*Added for customer account relation*/
/* TCA changes
                       ras.site_use_id  bill_site_use_id,
                       ras1.site_use_id ship_site_use_id
*/
                       hz_site.site_use_id  bill_site_use_id,
                       hz_site1.site_use_id ship_site_use_id
		FROM pa_project_customers pc,
                     pa_projects_all pr,
                     pa_implementations_all imp,
/* TCA changes
                     ra_site_uses ras,
                     ra_site_uses ras1
*/
                     hz_cust_site_uses hz_site,
                     hz_cust_site_uses hz_site1
		WHERE EXISTS (SELECT NULL
				 FROM  pa_draft_invoices_all di,
				       pa_agreements_all agr, pa_proj_retn_rules rt
				WHERE  di.project_id = p_project_id
				  AND  di.request_id = p_request_id
				  AND di.agreement_id = agr.agreement_id
				  AND agr.customer_id = pc.customer_id
				  AND rt.project_id = pc.project_id
				  AND rt.customer_id = pc.customer_id
				  AND ( (NVL(rt.threshold_amount,0) - NVL(rt.total_retained,0)) > 0
					OR NVL(threshold_amount,0) =0) )
		AND pc.project_id = p_project_id
		AND pc.project_id = pr.project_id
/* Shared services changes: removed NVL from the org_id join.*/
		AND pr.org_id = imp.org_id
/*Added for bug 2938422*/
/* TCA changes
                and   ras.address_id = pc.bill_to_address_id
                and   ras.site_use_code  = 'BILL_TO'
                and   ras.status = 'A'
                and   ras1.address_id = pc.ship_to_address_id
                and   ras1.site_use_code = 'SHIP_TO'
                and   ras1.status = 'A';
*/
                and   hz_site.cust_acct_site_id = pc.bill_to_address_id
                and   hz_site.site_use_code  = 'BILL_TO'
                and   hz_site.status = 'A'
                and   hz_site1.cust_acct_site_id = pc.ship_to_address_id
                and   hz_site1.site_use_code = 'SHIP_TO'
                and   hz_site1.status = 'A';

/*End of change for bug 2938422*/

ProjCustRec	cur_proj_cust%ROWTYPE;

CURSOR cur_proj_inv IS SELECT di.project_id,
			      di.draft_invoice_num,
			      agr.agreement_id agreement_id,
			      NVL(pr.inv_by_bill_trans_curr_flag,'N') inv_by_bill_trans_curr_flag,
			      di.inv_currency_code invoice_currency_code
	  FROM pa_draft_invoices_all di, pa_agreements_all agr,
	       pa_projects_all pr
	 WHERE NVL(di.canceled_flag,'N') ='N'
	   AND NVL(di.cancel_credit_memo_flag ,'N') ='N'
           AND NVL(di.draft_invoice_num_credited,0) = 0
	   AND di.request_id = p_request_id
	   AND di.project_id = p_project_id
	   AND agr.agreement_id = di.agreement_id
	   AND agr.customer_id  = ProjCustRec.customer_id
	   and di.project_id = pr.project_id;

ProjInvRec	cur_proj_inv%ROWTYPE;

CustomerID	NUMBER;
DraftInvoiceNum	number;

--Tmp_Output_vat_tax_id              NUMBER;
Tmp_output_Tax_code                VARCHAR2(30);
Tmp_Output_tax_exempt_flag         VARCHAR2(2);
-- Tmp_Output_tax_exempt_number       VARCHAR2(30); --Modified for Bug3128094
Tmp_Output_tax_exempt_number       VARCHAR2(80);
Tmp_Output_exempt_reason_code      VARCHAR2(30);
TmpSetOfBooks           	   NUMBER;
TmpBillToAddressID      NUMBER;
TmpShipToAddressID      NUMBER;
TmpUserId               NUMBER:= fnd_global.user_id;
TmpBillToCustomerId     NUMBER;
TmpShipToCustomerId     NUMBER;/*Added for customer account relation*/
TmpSiteUSeId1           NUMBER;
TmpSiteUSeId2           NUMBER;/*Added for bug 2938422*/


NetZeroLineNum		NUMBER:=0;
LastLineNum		NUMBER:=0;

BEGIN
	IF g1_debug_mode  = 'Y' THEN
		pa_retention_util.write_log('Entering Proj_Invoice_Retn_Processing ');
	END IF;

	OPEN cur_proj_cust;
	LOOP
	   FETCH cur_proj_cust INTO ProjCustRec;
	   EXIT  WHEN cur_proj_cust%NOTFOUND;

	   CustomerId := ProjCustRec.customer_id;
	   TmpBillToAddressID := ProjCustRec.bill_to_address_id;
	   TmpShipToAddressID := ProjCustRec.ship_to_address_id;
	   TmpSetOfBooks := ProjCustRec.set_of_books_id;
           TmpBillToCustomerId :=ProjCustRec.Bill_to_customer_id;
           TmpShipToCustomerId :=ProjCustRec.Ship_to_customer_id;/*Added for customer account relation*/
           TmpSiteUSeId1 :=ProjCustRec.Bill_site_use_id;
           TmpSiteUSeId2 :=ProjCustRec.Ship_site_use_id;
	   IF g1_debug_mode  = 'Y' THEN
	   	pa_retention_util.write_log('Proj_Invoice_Retn_Processing: ' || 'Customer ID : ' || CustomerId);
	   END IF;

		OPEN cur_proj_inv;
		LOOP
		 FETCH cur_proj_inv INTO ProjInvRec;
	         EXIT  WHEN cur_proj_inv%NOTFOUND;

		  DraftInvoiceNum := ProjInvRec.draft_invoice_num;

	   	  IF g1_debug_mode  = 'Y' THEN
	   	  	pa_retention_util.write_log('Proj_Invoice_Retn_Processing: ' || 'Invoice Number : ' || DraftInvoiceNum);
	   	  	pa_retention_util.write_log('Proj_Invoice_Retn_Processing: ' || 'Bill To Addres Id :  ' || TmpBillToAddressID);
	   	  	pa_retention_util.write_log('Proj_Invoice_Retn_Processing: ' || 'Ship To Addres Id :  ' || TmpShipToAddressID);
	   	  	pa_retention_util.write_log('Proj_Invoice_Retn_Processing: ' || 'Set Of Boooks Id :  ' || TmpSetOfBooks);
	   	  END IF;

		    --- Call Tax Information
/*Last two parameters added for customer account relation enhancement*/
/*The siteuseid is passed instead of addressid for bug 2938422*/
        		PA_OUTPUT_TAX.GET_DEFAULT_TAX_INFO
           				( P_Project_Id=>p_project_id,
             				P_Draft_Inv_Num=>DraftInvoiceNum,
             				P_Customer_Id  =>CustomerId,
             				P_Bill_to_site_use_id=>TmpSiteUSeId1,
             				P_Ship_to_site_use_id=>TmpSiteUSeId2,
             				P_Sets_of_books_id   =>TmpSetOfBooks,
             				P_User_Id  =>TmpUserId,
             				P_Request_id =>P_request_id,
--             				X_Output_vat_tax_id=>Tmp_Output_vat_tax_id,
                                        X_output_Tax_code => Tmp_Output_tax_code,
             				X_Output_tax_exempt_flag=>Tmp_Output_tax_exempt_flag ,
             				X_Output_tax_exempt_number =>Tmp_Output_tax_exempt_number,
             				X_Output_exempt_reason_code =>Tmp_Output_exempt_reason_code,
                                        Pbill_to_customer_id => TmpBillToCustomerId,
                                        Pship_to_customer_id => TmpShipToCustomerId);

           	IF g1_debug_mode  = 'Y' THEN
           		pa_retention_util.write_log('Proj_Invoice_Retn_Processing: ' || 'Tax Information: ');
--           		pa_retention_util.write_log('Proj_Invoice_Retn_Processing: ' || 'Tmp_Output_vat_tax_id : ' || Tmp_Output_vat_tax_id);
           		pa_retention_util.write_log('Proj_Invoice_Retn_Processing: ' || 'Tmp_Output_tax_code : ' || Tmp_Output_tax_code);
           		pa_retention_util.write_log('Proj_Invoice_Retn_Processing: ' || 'Tmp_Output_tax_exempt_flag : ' || Tmp_Output_tax_exempt_flag);
           		pa_retention_util.write_log('Proj_Invoice_Retn_Processing: ' || 'Tmp_Output_tax_exempt_number : ' || Tmp_Output_tax_exempt_number);
           		pa_retention_util.write_log('Proj_Invoice_Retn_Processing: ' || 'Tmp_Output_exempt_reason_code : ' || Tmp_Output_exempt_reason_code);
           	END IF;


	   	IF ProjCustRec.retention_level ='PROJECT' THEN

		      IF g1_debug_mode  = 'Y' THEN
		      	pa_retention_util.write_log('Proj_Invoice_Retn_Processing: ' || 'PROJECT Level ');
		      END IF;

			-- 1. Update the Non Labor Resource Override in RDLs

			UPDATE pa_cust_rev_dist_lines_all rdl
			   SET rdl.retention_rule_id=
				( SELECT DECODE(NVL(rt.threshold_amount,0),0,
						rt.retention_rule_id,
					 DECODE(SIGN(NVL(rt.total_retained,0) - NVL(rt.threshold_amount,0)),
					-1,rt.retention_rule_id,-99))
				    FROM pa_proj_retn_rules rt, pa_expenditure_items_all ei
				   WHERE rt.customer_id = ProjCustRec.customer_id
				     AND rt.project_id = p_project_id
				     AND rt.retention_level_code='NON_LABOR'
				     AND rdl.expenditure_item_id = ei.expenditure_item_id
			  	     AND rdl.draft_invoice_num = ProjInvRec.draft_invoice_num
				     AND ei.non_labor_resource = rt.non_labor_resource
				     AND trunc(ei.expenditure_item_date) BETWEEN
					 rt.effective_start_date and  NVL(rt.effective_end_date,ei.expenditure_item_date+1))
			WHERE rdl.project_id = p_project_id
			  AND rdl.request_id = p_request_id
			  AND rdl.draft_invoice_num = ProjInvRec.draft_invoice_num
			  AND exists (select null  FROM pa_proj_retn_rules rt, pa_expenditure_items_all ei
                                   WHERE rt.customer_id = ProjCustRec.customer_id
                                     AND rt.project_id = p_project_id
                                     AND rt.retention_level_code='NON_LABOR'
                                     AND rdl.expenditure_item_id = ei.expenditure_item_id
                                     AND rdl.draft_invoice_num = ProjInvRec.draft_invoice_num
                                     AND ei.non_labor_resource = rt.non_labor_resource
                                     AND trunc(ei.expenditure_item_date) BETWEEN
                                         rt.effective_start_date and NVL(rt.effective_end_date,ei.expenditure_item_date+1)) ;

		    IF g1_debug_mode  = 'Y' THEN
		      pa_retention_util.write_log('RDL: No Records Update At Non Labor Level ' ||sql%rowcount);
		    END IF;


	      		-- 2. Update the Expenditure Type Level Override in RDLs

			UPDATE pa_cust_rev_dist_lines_all rdl
			   SET rdl.retention_rule_id=
				( SELECT DECODE(NVL(rt.threshold_amount,0),0,
						rt.retention_rule_id,
 					DECODE(SIGN(NVL(rt.total_retained,0) - NVL(rt.threshold_amount,0)),
					-1,rt.retention_rule_id,-99))
				    FROM pa_proj_retn_rules rt, pa_expenditure_items_all ei
				   WHERE rt.customer_id = ProjCustRec.customer_id
				     AND rt.project_id = p_project_id
				     AND rt.expenditure_type = ei.expenditure_type
				     AND rt.retention_level_code='EXPENDITURE_TYPE'
				     AND rdl.expenditure_item_id = ei.expenditure_item_id
				     AND rdl.draft_invoice_num =  ProjInvRec.draft_invoice_num
				     AND trunc(ei.expenditure_item_date) BETWEEN
					 rt.effective_start_date and NVL(rt.effective_end_date,ei.expenditure_item_date+1))
			WHERE rdl.project_id = p_project_id
			  AND rdl.request_id = p_request_id
			  AND rdl.draft_invoice_num = ProjInvRec.draft_invoice_num
			  AND rdl.retention_rule_id IS NULL
			  AND EXISTS( select null
			 FROM pa_proj_retn_rules rt, pa_expenditure_items_all ei
                                   WHERE rt.customer_id = ProjCustRec.customer_id
                                     AND rt.project_id = p_project_id
                                     AND rt.expenditure_type = ei.expenditure_type
                                     AND rt.retention_level_code='EXPENDITURE_TYPE'
                                     AND rdl.expenditure_item_id = ei.expenditure_item_id
                                     AND rdl.draft_invoice_num =  ProjInvRec.draft_invoice_num
                                     AND trunc(ei.expenditure_item_date) BETWEEN
                                         rt.effective_start_date and NVL(rt.effective_end_date,ei.expenditure_item_date+1));
		IF g1_debug_mode  = 'Y' THEN
		      pa_retention_util.write_log('RDL: No Records Update At Expenditure Type Level ' ||sql%rowcount);
		END IF;

	      		-- 3. Update the Expenditure Category Level Override in RDLs

			UPDATE pa_cust_rev_dist_lines_all rdl
			   SET rdl.retention_rule_id=
				( SELECT DECODE(NVL(rt.threshold_amount,0),0,
						rt.retention_rule_id,
				 DECODE(SIGN(NVL(rt.total_retained,0) - NVL(rt.threshold_amount,0)),
					-1,rt.retention_rule_id,-99) )
				    FROM pa_proj_retn_rules rt,
					 pa_expenditure_items_all ei,
					 pa_expenditure_types et
				   WHERE rt.customer_id = ProjCustRec.customer_id
				     AND rt.project_id = p_project_id
				     -- AND rt.expenditure_type = ei.expenditure_type
				     AND ei.expenditure_type = et.expenditure_type
				     AND et.expenditure_category = rt.expenditure_category
				     AND rt.retention_level_code='EXPENDITURE_CATEGORY'
				     AND rdl.expenditure_item_id = ei.expenditure_item_id
				     AND rdl.draft_invoice_num	= ProjInvRec.draft_invoice_num
				     AND trunc(ei.expenditure_item_date) BETWEEN
					 rt.effective_start_date and NVL(rt.effective_end_date,ei.expenditure_item_date +1))
			WHERE rdl.project_id = p_project_id
			  AND rdl.request_id = p_request_id
			  AND rdl.draft_invoice_num = ProjInvRec.draft_invoice_num
			  AND rdl.retention_rule_id IS NULL
			  AND EXISTS (SELECT NULL
			  FROM pa_proj_retn_rules rt,
                                         pa_expenditure_items_all ei,
                                         pa_expenditure_types et
                                   WHERE rt.customer_id = ProjCustRec.customer_id
                                     AND rt.project_id = p_project_id
                                    -- AND rt.expenditure_type = ei.expenditure_type
                                     AND ei.expenditure_type = et.expenditure_type
                                     AND et.expenditure_category = rt.expenditure_category
                                     AND rt.retention_level_code='EXPENDITURE_CATEGORY'
                                     AND rdl.expenditure_item_id = ei.expenditure_item_id
                                     AND rdl.draft_invoice_num  = ProjInvRec.draft_invoice_num
                                     AND trunc(ei.expenditure_item_date) BETWEEN
                                         rt.effective_start_date and NVL(rt.effective_end_date,ei.expenditure_item_date +1));
		IF g1_debug_mode  = 'Y' THEN
		      pa_retention_util.write_log('RDL: No Records Update At Expenditure Category Level ' ||sql%rowcount);
		END IF;


	      		-- 4. Update the Project Level Retention Setup in RDLs

			UPDATE pa_cust_rev_dist_lines_all rdl
			   SET rdl.retention_rule_id=
				( SELECT DECODE(NVL(rt.threshold_amount,0),0,
						rt.retention_rule_id,
				         DECODE(SIGN(NVL(rt.total_retained,0) - NVL(rt.threshold_amount,0)),
					-1,rt.retention_rule_id,-99))
				    FROM pa_proj_retn_rules rt,
					 pa_expenditure_items_all ei
				   WHERE rt.customer_id = ProjCustRec.customer_id
				     AND rt.project_id = p_project_id
				     AND rt.retention_level_code='PROJECT'
				     AND rdl.expenditure_item_id = ei.expenditure_item_id
				     AND rdl.draft_invoice_num	= ProjInvRec.draft_invoice_num
				     AND trunc(ei.expenditure_item_date) BETWEEN
					 rt.effective_start_date and NVL(rt.effective_end_date,ei.expenditure_item_date))
			WHERE rdl.project_id = p_project_id
			  AND rdl.request_id = p_request_id
			  AND rdl.draft_invoice_num = ProjInvRec.draft_invoice_num
		          AND rdl.retention_rule_id IS NULL
			  AND EXISTS( SELECT NULL
				 FROM pa_proj_retn_rules rt,
                                         pa_expenditure_items_all ei
                                   WHERE rt.customer_id = ProjCustRec.customer_id
                                     AND rt.project_id = p_project_id
                                     AND rt.retention_level_code='PROJECT'
                                     AND rdl.expenditure_item_id = ei.expenditure_item_id
                                     AND rdl.draft_invoice_num  = ProjInvRec.draft_invoice_num
                                     AND trunc(ei.expenditure_item_date) BETWEEN
                                         rt.effective_start_date and NVL(rt.effective_end_date,ei.expenditure_item_date));

		IF g1_debug_mode  = 'Y' THEN
		      pa_retention_util.write_log('RDL: No Records Update At Project Level ' ||sql%rowcount);
		END IF;


	      	-- 1. Update the Event Type Level Retention Setup in ERDLs

			UPDATE pa_cust_event_rdl_all erdl
			   SET erdl.retention_rule_id=
				( SELECT DECODE(NVL(rt.threshold_amount,0),0,
						rt.retention_rule_id,
				 DECODE(SIGN(NVL(rt.total_retained,0) - NVL(rt.threshold_amount,0)),
					-1,rt.retention_rule_id,-99) )
				    FROM pa_proj_retn_rules rt,
					 pa_events evt,
					 pa_event_types evttyp
				   WHERE rt.customer_id = ProjCustRec.customer_id
				     AND rt.project_id = p_project_id
				     AND rt.retention_level_code='EVENT_TYPE'
				     AND erdl.event_num = evt.event_num
				     AND nvl(erdl.task_id,-99) = nvl(evt.task_id,-99)
				     AND erdl.project_id = evt.project_id
				     AND trunc(evt.completion_date) BETWEEN
					 rt.effective_start_date and NVL(rt.effective_end_date, evt.completion_date+1)
				     AND evt.event_type = evttyp.event_type
				     AND evt.event_type = rt.event_type
				     and erdl.draft_invoice_num = ProjInvRec.draft_invoice_num
				     AND evttyp.revenue_category_code= rt.revenue_category_code)
			WHERE erdl.project_id = p_project_id
			  AND erdl.request_id = p_request_id
			  AND erdl.draft_invoice_num = ProjInvRec.draft_invoice_num
		          AND erdl.retention_rule_id IS NULL
			  AND EXISTS(SELECT NULL
				 FROM pa_proj_retn_rules rt,
                                         pa_events evt,
                                         pa_event_types evttyp
                                   WHERE rt.customer_id = ProjCustRec.customer_id
                                     AND rt.project_id = p_project_id
                                     AND rt.retention_level_code='EVENT_TYPE'
                                     AND erdl.event_num = evt.event_num
                                     AND nvl(erdl.task_id,-99) = nvl(evt.task_id,-99)
                                     AND erdl.project_id = evt.project_id
                                     AND trunc(evt.completion_date) BETWEEN
                                         rt.effective_start_date and NVL(rt.effective_end_date, evt.completion_date+1)
                                     AND evt.event_type = evttyp.event_type
                                     AND evt.event_type = rt.event_type
                                     and erdl.draft_invoice_num = ProjInvRec.draft_invoice_num
                                     AND evttyp.revenue_category_code= rt.revenue_category_code);

		IF g1_debug_mode  = 'Y' THEN
		      pa_retention_util.write_log('ERDL: No Records Update At Event Type Level ' ||sql%rowcount);
		END IF;
	      -- 2. Update the Revenue Category Level Retention Setup in ERDLs

			UPDATE pa_cust_event_rdl_all erdl
			   SET erdl.retention_rule_id=
				( SELECT DECODE(NVL(rt.threshold_amount,0),0,
						rt.retention_rule_id,
				 DECODE(SIGN(NVL(rt.total_retained,0) -NVL(rt.threshold_amount,0)),
					-1,rt.retention_rule_id,-99))
				    FROM pa_proj_retn_rules rt,
					 pa_events evt,
					 pa_event_types evttyp
				   WHERE rt.customer_id = ProjCustRec.customer_id
				     AND rt.project_id = p_project_id
				     AND rt.retention_level_code='REVENUE_CATEGORY'
				     AND erdl.event_num = evt.event_num
				     AND nvl(erdl.task_id,-99) = nvl(evt.task_id,-99)
				     AND erdl.project_id = evt.project_id
				     AND trunc(evt.completion_date) BETWEEN
					 rt.effective_start_date and NVL(rt.effective_end_date,evt.completion_date+1)
				     AND evt.event_type = evttyp.event_type
				     AND erdl.draft_invoice_num= ProjInvRec.draft_invoice_num
				     AND evttyp.revenue_category_code= rt.revenue_category_code)
			WHERE erdl.project_id = p_project_id
			  AND erdl.request_id = p_request_id
			  AND erdl.draft_invoice_num = ProjInvRec.draft_invoice_num
		          AND erdl.retention_rule_id IS NULL
			  AND EXISTS (SELECT NULL
			         FROM pa_proj_retn_rules rt,
                                         pa_events evt,
                                         pa_event_types evttyp
                                   WHERE rt.customer_id = ProjCustRec.customer_id
                                     AND rt.project_id = p_project_id
                                     AND rt.retention_level_code='REVENUE_CATEGORY'
                                     AND erdl.event_num = evt.event_num
                                     AND nvl(erdl.task_id,-99) = nvl(evt.task_id,-99)
                                     AND erdl.project_id = evt.project_id
                                     AND trunc(evt.completion_date) BETWEEN
                                         rt.effective_start_date and NVL(rt.effective_end_date,evt.completion_date+1)
                                     AND evt.event_type = evttyp.event_type
                                     AND erdl.draft_invoice_num= ProjInvRec.draft_invoice_num
                                     AND evttyp.revenue_category_code= rt.revenue_category_code);

		IF g1_debug_mode  = 'Y' THEN
		      pa_retention_util.write_log('ERDL: No Records Update At Revenue Category Level ' ||sql%rowcount);
		END IF;
	      -- 3. Update the Project Level Retention Setup in ERDLs

			UPDATE pa_cust_event_rdl_all erdl
			   SET erdl.retention_rule_id=
				( SELECT DECODE(NVL(rt.threshold_amount,0),0,
						rt.retention_rule_id,
				 DECODE(SIGN(NVL(rt.total_retained,0) - NVL(rt.threshold_amount,0)),
					-1,rt.retention_rule_id,-99))
				    FROM pa_proj_retn_rules rt,
					 pa_events evt
				   WHERE rt.customer_id = ProjCustRec.customer_id
				     AND rt.project_id = p_project_id
				     AND rt.retention_level_code='PROJECT'
				     AND erdl.event_num = evt.event_num
				     AND nvl(erdl.task_id,-99) = nvl(evt.task_id,-99)
				     AND erdl.project_id = evt.project_id
				     AND erdl.draft_invoice_num=ProjInvRec.draft_invoice_num
				     AND TRUNC(evt.completion_date) BETWEEN
					 rt.effective_start_date and NVL(rt.effective_end_date,evt.completion_date+1))
			WHERE erdl.project_id = p_project_id
			  AND erdl.request_id = p_request_id
			  AND erdl.draft_invoice_num = ProjInvRec.draft_invoice_num
		          AND erdl.retention_rule_id IS NULL
			  AND EXISTS(SELECT NULL
			    FROM pa_proj_retn_rules rt,
                                         pa_events evt
                                   WHERE rt.customer_id = ProjCustRec.customer_id
                                     AND rt.project_id = p_project_id
                                     AND rt.retention_level_code='PROJECT'
                                     AND erdl.event_num = evt.event_num
                                     AND nvl(erdl.task_id,-99) = nvl(evt.task_id,-99)
                                     AND erdl.project_id = evt.project_id
                                     AND erdl.draft_invoice_num=ProjInvRec.draft_invoice_num
                                     AND trunc(evt.completion_date) BETWEEN
                                         rt.effective_start_date and NVL(rt.effective_end_date,evt.completion_date+1));
		IF g1_debug_mode  = 'Y' THEN
		      pa_retention_util.write_log('ERDL: No Records Update At Project Level ' ||sql%rowcount);
		END IF;
	      -- 1. Update the Event Type Level Retention Setup in DII only for EVENTS
	      /* Bug 3258414: The update statements below are done only for Events of type MANUAL or AUTOMATIC.
	         The WRITE ON events are already updated using the ERDL table above. */

			 UPDATE pa_draft_invoice_items dii
			   SET dii.retention_rule_id=
				( SELECT DECODE(NVL(rt.threshold_amount,0),0,
						rt.retention_rule_id,
					DECODE(SIGN(NVL(rt.total_retained,0) - NVL(rt.threshold_amount,0)),
					-1,rt.retention_rule_id,-99))
				    FROM pa_proj_retn_rules rt,
					 pa_events evt,
					 pa_event_types evttyp
				   WHERE rt.customer_id = ProjCustRec.customer_id
				     AND rt.project_id = p_project_id
				     AND rt.retention_level_code='EVENT_TYPE'
				     AND dii.event_num = evt.event_num
				     AND nvl(dii.event_task_id,-99) = nvl(evt.task_id,-99)
				     AND dii.project_id = evt.project_id
				     AND trunc(evt.completion_date) BETWEEN
					 rt.effective_start_date and NVL(rt.effective_end_date,evt.completion_date+1)
				     AND evt.event_type = evttyp.event_type
				     AND evt.event_type = rt.event_type
				     AND evttyp.revenue_category_code= rt.revenue_category_code
		/*		     AND evttyp.event_type_classification in ('MANUAL', 'AUTOMATIC') Bug 3258414 - Changed for bug3478802*/
				     AND evttyp.event_type_classification <> 'WRITE ON'
				     AND dii.event_num is NOT NULL
				     AND dii.draft_invoice_num=ProjInvRec.draft_invoice_num)
			WHERE dii.project_id = p_project_id
			  AND dii.request_id = p_request_id
			  AND dii.draft_invoice_num = ProjInvRec.draft_invoice_num
			  AND dii.event_num IS NOT NULL
		          AND dii.retention_rule_id IS NULL
			  AND EXISTS( SELECT NULL
                                    FROM pa_proj_retn_rules rt,
                                         pa_events evt,
                                         pa_event_types evttyp
                                   WHERE rt.customer_id = ProjCustRec.customer_id
                                     AND rt.project_id = p_project_id
                                     AND rt.retention_level_code='EVENT_TYPE'
                                     AND dii.event_num = evt.event_num
                                     AND nvl(dii.event_task_id,-99) = nvl(evt.task_id,-99)
                                     AND dii.project_id = evt.project_id
                                     AND trunc(evt.completion_date) BETWEEN
                                         rt.effective_start_date and NVL(rt.effective_end_date,evt.completion_date +1)
                                     AND evt.event_type = evttyp.event_type
                                     AND evt.event_type = rt.event_type
                                     AND evttyp.revenue_category_code= rt.revenue_category_code
		/*		     AND evttyp.event_type_classification in ('MANUAL', 'AUTOMATIC') Bug 3258414 - Changed for bug3478802*/
				     AND evttyp.event_type_classification <> 'WRITE ON'
                                     AND dii.event_num is NOT NULL
                                     AND dii.draft_invoice_num=ProjInvRec.draft_invoice_num);

		IF g1_debug_mode  = 'Y' THEN
		      pa_retention_util.write_log('DII: No Records Update At Event Type Level ' ||sql%rowcount);
		END IF;

	      -- 2. Update the Revenue Category Level Retention Setup in DII for events

			 UPDATE pa_draft_invoice_items dii
			   SET dii.retention_rule_id=
				( SELECT DECODE(NVL(rt.threshold_amount,0),0,
						rt.retention_rule_id,
					DECODE(SIGN(NVL(rt.total_retained,0) - NVL(rt.threshold_amount,0)),
					-1,rt.retention_rule_id,-99))
				    FROM pa_proj_retn_rules rt,
					 pa_events evt,
					 pa_event_types evttyp
				   WHERE rt.customer_id = ProjCustRec.customer_id
				     AND rt.project_id = p_project_id
				     AND rt.retention_level_code='REVENUE_CATEGORY'
				     AND dii.event_num = evt.event_num
				     AND nvl(dii.event_task_id,-99) = nvl(evt.task_id,-99)
				     AND dii.project_id = evt.project_id
				     AND trunc(evt.completion_date) BETWEEN
					 rt.effective_start_date and NVL(rt.effective_end_date,evt.completion_date+1)
				     AND evt.event_type = evttyp.event_type
				     AND evttyp.revenue_category_code= rt.revenue_category_code
		/*		     AND evttyp.event_type_classification in ('MANUAL', 'AUTOMATIC') Bug 3258414 - Changed for bug3478802*/
				     AND evttyp.event_type_classification <> 'WRITE ON'
				     AND dii.event_num IS NOT NULL
				     AND dii.draft_invoice_num=ProjInvRec.draft_invoice_num)
			WHERE dii.project_id = p_project_id
			  AND dii.request_id = p_request_id
			  AND dii.draft_invoice_num = ProjInvRec.draft_invoice_num
			  AND dii.event_num IS NOT NULL
		          AND dii.retention_rule_id IS NULL
			  AND exists (SELECT NULL
                                    FROM pa_proj_retn_rules rt,
                                         pa_events evt,
                                         pa_event_types evttyp
                                   WHERE rt.customer_id = ProjCustRec.customer_id
                                     AND rt.project_id = p_project_id
                                     AND rt.retention_level_code='REVENUE_CATEGORY'
                                     AND dii.event_num = evt.event_num
                                     AND nvl(dii.event_task_id,-99) = nvl(evt.task_id,-99)
                                     AND dii.project_id = evt.project_id
                                     AND trunc(evt.completion_date) BETWEEN
                                         rt.effective_start_date and NVL(rt.effective_end_date,evt.completion_date+1)
                                     AND evt.event_type = evttyp.event_type
                                     AND evttyp.revenue_category_code= rt.revenue_category_code
		/*		     AND evttyp.event_type_classification in ('MANUAL', 'AUTOMATIC') Bug 3258414 - Changed for bug3478802*/
				     AND evttyp.event_type_classification <> 'WRITE ON'
                                     AND dii.event_num IS NOT NULL
                                     AND dii.draft_invoice_num=ProjInvRec.draft_invoice_num);

		IF g1_debug_mode  = 'Y' THEN
		      pa_retention_util.write_log('DII: No Records Update At Revenue Category Level ' ||sql%rowcount);
		END IF;

	      -- 3. Update the Project Level Retention Setup in DIIs for Events
		IF g1_debug_mode  = 'Y' THEN
			pa_retention_util.write_log('Proj_Invoice_Retn_Processing: ' || 'PROJECT Defaults Level ');
		END IF;

			UPDATE pa_draft_invoice_items dii
			   SET dii.retention_rule_id=
				( SELECT DECODE(NVL(rt.threshold_amount,0),0,
						rt.retention_rule_id,
				 	DECODE(SIGN(NVL(rt.total_retained,0) - NVL(rt.threshold_amount,0)),
					-1,rt.retention_rule_id,-99))
				    FROM pa_proj_retn_rules rt,
					 pa_events evt ,
					 pa_event_types evttyp /* Bug 3258414 */
				   WHERE rt.customer_id = ProjCustRec.customer_id
				     AND rt.project_id = p_project_id
				     AND rt.retention_level_code='PROJECT'
				     AND dii.event_num = evt.event_num
				     AND nvl(dii.event_task_id,-99) = nvl(evt.task_id,-99)
				     AND dii.project_id = evt.project_id
				     AND trunc(evt.completion_date) BETWEEN
					 rt.effective_start_date and NVL(rt.effective_end_date,evt.completion_date+1)
				     AND dii.event_num IS NOT NULL
				     AND evt.event_type = evttyp.event_type  /* Bug 3258414 */
		/*		     AND evttyp.event_type_classification in ('MANUAL', 'AUTOMATIC') Bug 3258414 - Changed for bug3478802*/
				     AND evttyp.event_type_classification <> 'WRITE ON'
				     AND dii.draft_invoice_num=ProjInvRec.draft_invoice_num)
			WHERE dii.project_id = p_project_id
			  AND dii.request_id = p_request_id
			  AND dii.draft_invoice_num = ProjInvRec.draft_invoice_num
			  AND dii.event_num IS NOT NULL
		          AND dii.retention_rule_id IS NULL
                          AND EXISTS(SELECT NULL
                                    FROM pa_proj_retn_rules rt,
                                         pa_events evt,
					 pa_event_types evttyp /* Bug 3258414 */
                                   WHERE rt.customer_id = ProjCustRec.customer_id
                                     AND rt.project_id = p_project_id
                                     AND rt.retention_level_code='PROJECT'
                                     AND dii.event_num = evt.event_num
                                     AND nvl(dii.event_task_id,-99) = nvl(evt.task_id,-99)
                                     AND dii.project_id = evt.project_id
                                     AND trunc(evt.completion_date) BETWEEN
                                         rt.effective_start_date and NVL(rt.effective_end_date,evt.completion_date+1)
                                     AND dii.event_num IS NOT NULL
                                     AND evt.event_type = evttyp.event_type  /* Bug 3258414 */
		/*		     AND evttyp.event_type_classification in ('MANUAL', 'AUTOMATIC') Bug 3258414 - Changed for bug3478802*/
				     AND evttyp.event_type_classification <> 'WRITE ON'
                                     AND dii.draft_invoice_num=ProjInvRec.draft_invoice_num);

		IF g1_debug_mode  = 'Y' THEN
		      pa_retention_util.write_log('DII: No Records Update At Project Level ' ||sql%rowcount);
		END IF;

	  ELSIF ProjCustRec.retention_level ='TOP_TASK' THEN

		      IF g1_debug_mode  = 'Y' THEN
		      	pa_retention_util.write_log('Proj_Invoice_Retn_Processing: ' || 'TOP_TASK Level ');
		      END IF;

			-- 1. Update the Non Labor Resource Override in RDLs

			UPDATE pa_cust_rev_dist_lines_all rdl
			   SET rdl.retention_rule_id=
				( SELECT DECODE(NVL(rt.threshold_amount,0),0,
						rt.retention_rule_id,
				 	DECODE(SIGN(NVL(rt.total_retained,0) - NVL(rt.threshold_amount,0)),
					-1,rt.retention_rule_id,-99))
				    FROM pa_proj_retn_rules rt,
					 pa_expenditure_items_all ei,
					 pa_tasks tsk
				   WHERE tsk.task_id = ei.task_id
				     AND tsk.top_task_id = rt.task_id
				     AND rt.customer_id = ProjCustRec.customer_id
				     AND rt.project_id = p_project_id
				     AND rt.retention_level_code='NON_LABOR'
				     AND rdl.expenditure_item_id = ei.expenditure_item_id
			  	     AND rdl.draft_invoice_num = ProjInvRec.draft_invoice_num
				     AND ei.non_labor_resource = rt.non_labor_resource
				     AND trunc(ei.expenditure_item_date) BETWEEN
					 rt.effective_start_date and NVL(rt.effective_end_date,ei.expenditure_item_date+1))
			WHERE rdl.project_id = p_project_id
			  AND rdl.request_id = p_request_id
			  AND rdl.draft_invoice_num = ProjInvRec.draft_invoice_num
			  AND EXISTS(
			      SELECT NULL
			  	FROM pa_proj_retn_rules rt,
                                         pa_expenditure_items_all ei,
                                         pa_tasks tsk
                                   WHERE tsk.task_id = ei.task_id
                                     AND tsk.top_task_id = rt.task_id
                                     AND rt.customer_id = ProjCustRec.customer_id
                                     AND rt.project_id = p_project_id
                                     AND rt.retention_level_code='NON_LABOR'
                                     AND rdl.expenditure_item_id = ei.expenditure_item_id
                                     AND rdl.draft_invoice_num = ProjInvRec.draft_invoice_num
                                     AND ei.non_labor_resource = rt.non_labor_resource
                                     AND trunc(ei.expenditure_item_date) BETWEEN
                                         rt.effective_start_date and NVL(rt.effective_end_date,ei.expenditure_item_date+1));
		IF g1_debug_mode  = 'Y' THEN
		      pa_retention_util.write_log('RDL: No Records Update At Non Labor Level ' ||sql%rowcount);
		END IF;
	      		-- 2. Update the Expenditure Type Level Override in RDLs

			UPDATE pa_cust_rev_dist_lines_all rdl
			   SET rdl.retention_rule_id=
				( SELECT DECODE(NVL(rt.threshold_amount,0),0,
						rt.retention_rule_id,
				 	DECODE(SIGN(NVL(rt.total_retained,0) - NVL(rt.threshold_amount,0)),
					-1,rt.retention_rule_id,-99))
				    FROM pa_proj_retn_rules rt,
					 pa_expenditure_items_all ei,
					 pa_tasks tsk
				   WHERE tsk.task_id = ei.task_id
				     AND tsk.top_task_id = rt.task_id
				     AND rt.customer_id = ProjCustRec.customer_id
				     AND rt.project_id = p_project_id
				     AND rt.expenditure_type = ei.expenditure_type
				     AND rt.retention_level_code='EXPENDITURE_TYPE'
				     AND rdl.expenditure_item_id = ei.expenditure_item_id
				     AND rdl.draft_invoice_num =  ProjInvRec.draft_invoice_num
				     AND trunc(ei.expenditure_item_date) BETWEEN
					 rt.effective_start_date and NVL(rt.effective_end_date,ei.expenditure_item_date+1))
			WHERE rdl.project_id = p_project_id
			  AND rdl.request_id = p_request_id
			  AND rdl.draft_invoice_num = ProjInvRec.draft_invoice_num
			  AND rdl.retention_rule_id IS NULL
			  AND EXISTS(
				SELECT NULL
			 	FROM pa_proj_retn_rules rt,
                                         pa_expenditure_items_all ei,
                                         pa_tasks tsk
                                   WHERE tsk.task_id = ei.task_id
                                     AND tsk.top_task_id = rt.task_id
                                     AND rt.customer_id = ProjCustRec.customer_id
                                     AND rt.project_id = p_project_id
                                     AND rt.expenditure_type = ei.expenditure_type
                                     AND rt.retention_level_code='EXPENDITURE_TYPE'
                                     AND rdl.expenditure_item_id = ei.expenditure_item_id
                                     AND rdl.draft_invoice_num =  ProjInvRec.draft_invoice_num
                                     AND trunc(ei.expenditure_item_date) BETWEEN
                                         rt.effective_start_date and NVL(rt.effective_end_date,ei.expenditure_item_date+1));
		IF g1_debug_mode  = 'Y' THEN
		      pa_retention_util.write_log('RDL: No Records Update At Expenditure Type Level ' ||sql%rowcount);
		END IF;

	      		-- 3. Update the Expenditure Category Level Override in RDLs

			UPDATE pa_cust_rev_dist_lines_all rdl
			   SET rdl.retention_rule_id=
				( SELECT DECODE(NVL(rt.threshold_amount,0),0,
						rt.retention_rule_id,
				 	DECODE(SIGN(NVL(rt.total_retained,0) - NVL(rt.threshold_amount,0)),
					-1,rt.retention_rule_id,-99))
				    FROM pa_proj_retn_rules rt,
					 pa_expenditure_items_all ei,
					 pa_expenditure_types et,
					 pa_tasks tsk
				   WHERE tsk.task_id = ei.task_id
				     AND tsk.top_task_id = rt.task_id
				     AND rt.customer_id = ProjCustRec.customer_id
				     AND rt.project_id = p_project_id
				     -- AND rt.expenditure_type = ei.expenditure_type
				     AND ei.expenditure_type = et.expenditure_type
				     AND et.expenditure_category = rt.expenditure_category
				     AND rt.retention_level_code='EXPENDITURE_CATEGORY'
				     AND rdl.expenditure_item_id = ei.expenditure_item_id
				     AND rdl.draft_invoice_num	= ProjInvRec.draft_invoice_num
				     AND trunc(ei.expenditure_item_date) BETWEEN
					 rt.effective_start_date and NVL(rt.effective_end_date,ei.expenditure_item_date+1))
			WHERE rdl.project_id = p_project_id
			  AND rdl.request_id = p_request_id
			  AND rdl.draft_invoice_num = ProjInvRec.draft_invoice_num
			  AND rdl.retention_rule_id IS NULL
			  AND EXISTS(
				SELECT NULL
				  FROM pa_proj_retn_rules rt,
                                         pa_expenditure_items_all ei,
                                         pa_expenditure_types et,
                                         pa_tasks tsk
                                   WHERE tsk.task_id = ei.task_id
                                     AND tsk.top_task_id = rt.task_id
                                     AND rt.customer_id = ProjCustRec.customer_id
                                     AND rt.project_id = p_project_id
                                     -- AND rt.expenditure_type = ei.expenditure_type
                                     AND ei.expenditure_type = et.expenditure_type
                                     AND et.expenditure_category = rt.expenditure_category
                                     AND rt.retention_level_code='EXPENDITURE_CATEGORY'
                                     AND rdl.expenditure_item_id = ei.expenditure_item_id
                                     AND rdl.draft_invoice_num  = ProjInvRec.draft_invoice_num
                                     AND trunc(ei.expenditure_item_date) BETWEEN
                                         rt.effective_start_date and NVL(rt.effective_end_date,ei.expenditure_item_date+1));
		IF g1_debug_mode  = 'Y' THEN
		      pa_retention_util.write_log('RDL: No Records Update At Expenditure Category Level ' ||sql%rowcount);
		END IF;
	      		-- 4. Update the Project Level Retention Setup in RDLs

			UPDATE pa_cust_rev_dist_lines_all rdl
			   SET rdl.retention_rule_id=
				( SELECT DECODE(NVL(rt.threshold_amount,0),0,
						rt.retention_rule_id,
				 	DECODE(SIGN(NVL(rt.total_retained,0) -NVL(rt.threshold_amount,0)),
					-1,rt.retention_rule_id,-99))
				    FROM pa_proj_retn_rules rt,
					 pa_expenditure_items_all ei,
				         pa_tasks tsk
				   WHERE tsk.task_id = ei.task_id
				     AND tsk.top_task_id = rt.task_id
				     AND rt.customer_id = ProjCustRec.customer_id
				     AND rt.project_id = p_project_id
				     AND rt.retention_level_code='TOP_TASK'
				     AND rdl.expenditure_item_id = ei.expenditure_item_id
				     AND rdl.draft_invoice_num	= ProjInvRec.draft_invoice_num
				     AND  trunc(ei.expenditure_item_date) BETWEEN
					 rt.effective_start_date and NVL(rt.effective_end_date,ei.expenditure_item_date+1))
			WHERE rdl.project_id = p_project_id
			  AND rdl.request_id = p_request_id
			  AND rdl.draft_invoice_num = ProjInvRec.draft_invoice_num
		          AND rdl.retention_rule_id IS NULL
			  AND EXISTS(SELECT NULL
		FROM pa_proj_retn_rules rt,
                                         pa_expenditure_items_all ei,
                                         pa_tasks tsk
                                   WHERE tsk.task_id = ei.task_id
                                     AND tsk.top_task_id = rt.task_id
                                     AND rt.customer_id = ProjCustRec.customer_id
                                     AND rt.project_id = p_project_id
                                     AND rt.retention_level_code='TOP_TASK'
                                     AND rdl.expenditure_item_id = ei.expenditure_item_id
                                     AND rdl.draft_invoice_num  = ProjInvRec.draft_invoice_num
                                     AND trunc(ei.expenditure_item_date) BETWEEN
                                         rt.effective_start_date and NVL(rt.effective_end_date,ei.expenditure_item_date+1));

		IF g1_debug_mode  = 'Y' THEN
		      pa_retention_util.write_log('RDL: No Records Update At Project Level ' ||sql%rowcount);
		END IF;

	      	-- 1. Update the Event Type Level Retention Setup in ERDLs

			UPDATE pa_cust_event_rdl_all erdl
			   SET erdl.retention_rule_id=
				( SELECT DECODE(NVL(rt.threshold_amount,0),0,
						rt.retention_rule_id,
				 	DECODE(SIGN(NVL(rt.total_retained,0) - NVL(rt.threshold_amount,0)),
					-1,rt.retention_rule_id,-99))
				    FROM pa_proj_retn_rules rt,
					 pa_events evt,
					 pa_event_types evttyp,
					 pa_tasks tsk
				   WHERE tsk.task_id = evt.task_id
				     AND tsk.top_task_id = rt.task_id
				     AND rt.customer_id = ProjCustRec.customer_id
				     AND rt.project_id = p_project_id
				     AND rt.retention_level_code='EVENT_TYPE'
				     AND erdl.event_num = evt.event_num
				     AND nvl(erdl.task_id,-99) = nvl(evt.task_id,-99)
				     AND erdl.project_id = evt.project_id
				     AND trunc(evt.completion_date) BETWEEN
					 rt.effective_start_date and nvl(rt.effective_end_date,evt.completion_date+1)
				     AND evt.event_type = evttyp.event_type
				     AND evt.event_type = rt.event_type
				     and erdl.draft_invoice_num = ProjInvRec.draft_invoice_num
				     AND evttyp.revenue_category_code= rt.revenue_category_code)
			WHERE erdl.project_id = p_project_id
			  AND erdl.request_id = p_request_id
			  AND erdl.draft_invoice_num = ProjInvRec.draft_invoice_num
		          AND erdl.retention_rule_id IS NULL
			  AND EXISTS
				(SELECT NULL
		   		FROM pa_proj_retn_rules rt,
                                         pa_events evt,
                                         pa_event_types evttyp,
                                         pa_tasks tsk
                                   WHERE tsk.task_id = evt.task_id
                                     AND tsk.top_task_id = rt.task_id
                                     AND rt.customer_id = ProjCustRec.customer_id
                                     AND rt.project_id = p_project_id
                                     AND rt.retention_level_code='EVENT_TYPE'
                                     AND erdl.event_num = evt.event_num
                                     AND nvl(erdl.task_id,-99) = nvl(evt.task_id,-99)
                                     AND erdl.project_id = evt.project_id
                                     AND trunc(evt.completion_date) BETWEEN
                                         rt.effective_start_date and nvl(rt.effective_end_date,evt.completion_date+1)
                                     AND evt.event_type = evttyp.event_type
                                     AND evt.event_type = rt.event_type
                                     and erdl.draft_invoice_num = ProjInvRec.draft_invoice_num
                                     AND evttyp.revenue_category_code= rt.revenue_category_code);

		IF g1_debug_mode  = 'Y' THEN
		      pa_retention_util.write_log('ERDL: No Records Update At Event Type Level ' ||sql%rowcount);
		END IF;

	      -- 2. Update the Revenue Category Level Retention Setup in ERDLs

			UPDATE pa_cust_event_rdl_all erdl
			   SET erdl.retention_rule_id=
				( SELECT DECODE(NVL(rt.threshold_amount,0),0,
						rt.retention_rule_id,
				 	DECODE(SIGN(NVL(rt.total_retained,0) - NVL(rt.threshold_amount,0)),
					-1,rt.retention_rule_id,-99))
				    FROM pa_proj_retn_rules rt,
					 pa_events evt,
					 pa_event_types evttyp,
					 pa_tasks tsk
				   WHERE tsk.task_id = evt.task_id
				     AND tsk.top_task_id = rt.task_id
				     AND rt.customer_id = ProjCustRec.customer_id
				     AND rt.project_id = p_project_id
				     AND rt.retention_level_code='REVENUE_CATEGORY'
				     AND erdl.event_num = evt.event_num
				     AND nvl(erdl.task_id,-99) = nvl(evt.task_id,-99)
				     AND erdl.project_id = evt.project_id
				     AND trunc(evt.completion_date) BETWEEN
					 rt.effective_start_date and NVL(rt.effective_end_date,evt.completion_date+1)
				     AND evt.event_type = evttyp.event_type
				     AND erdl.draft_invoice_num= ProjInvRec.draft_invoice_num
				     AND evttyp.revenue_category_code= rt.revenue_category_code)
			WHERE erdl.project_id = p_project_id
			  AND erdl.request_id = p_request_id
			  AND erdl.draft_invoice_num = ProjInvRec.draft_invoice_num
		          AND erdl.retention_rule_id IS NULL
			  AND EXISTS (SELECT NULL
			   FROM pa_proj_retn_rules rt,
                                         pa_events evt,
                                         pa_event_types evttyp,
                                         pa_tasks tsk
                                   WHERE tsk.task_id = evt.task_id
                                     AND tsk.top_task_id = rt.task_id
                                     AND rt.customer_id = ProjCustRec.customer_id
                                     AND rt.project_id = p_project_id
                                     AND rt.retention_level_code='REVENUE_CATEGORY'
                                     AND erdl.event_num = evt.event_num
                                     AND nvl(erdl.task_id,-99) = nvl(evt.task_id,-99)
                                     AND erdl.project_id = evt.project_id
                                     AND trunc(evt.completion_date) BETWEEN
                                         rt.effective_start_date and NVL(rt.effective_end_date,evt.completion_date+1)
                                     AND evt.event_type = evttyp.event_type
                                     AND erdl.draft_invoice_num= ProjInvRec.draft_invoice_num
                                     AND evttyp.revenue_category_code= rt.revenue_category_code);


		IF g1_debug_mode  = 'Y' THEN
		      pa_retention_util.write_log('ERDL: No Records Update At Revenue Category Level ' ||sql%rowcount);
		END IF;

	      -- 3. Update the Top Task Level Retention Setup in ERDLs

			UPDATE pa_cust_event_rdl_all erdl
			   SET erdl.retention_rule_id=
				( SELECT DECODE(NVL(rt.threshold_amount,0),0,
						rt.retention_rule_id,
					DECODE(SIGN(NVL(rt.total_retained,0) - NVL(rt.threshold_amount,0)),
					-1,rt.retention_rule_id,-99))
				    FROM pa_proj_retn_rules rt,
					 pa_events evt,
					 pa_tasks tsk
				   WHERE tsk.task_id = evt.task_id
				     AND tsk.top_task_id = rt.task_id
				     AND rt.customer_id = ProjCustRec.customer_id
				     AND rt.project_id = p_project_id
				     AND rt.retention_level_code='TOP_TASK'
				     AND erdl.event_num = evt.event_num
				     AND nvl(erdl.task_id,-99) = nvl(evt.task_id,-99)
				     AND erdl.project_id = evt.project_id
				     AND erdl.draft_invoice_num=ProjInvRec.draft_invoice_num
				     AND trunc(evt.completion_date) BETWEEN
					 rt.effective_start_date and NVL(rt.effective_end_date,evt.completion_date+1))
			WHERE erdl.project_id = p_project_id
			  AND erdl.request_id = p_request_id
			  AND erdl.draft_invoice_num = ProjInvRec.draft_invoice_num
		          AND erdl.retention_rule_id IS NULL
			  AND EXISTS( SELECT NULL
				     FROM pa_proj_retn_rules rt,
                                         pa_events evt,
                                         pa_tasks tsk
                                   WHERE tsk.task_id = evt.task_id
                                     AND tsk.top_task_id = rt.task_id
                                     AND rt.customer_id = ProjCustRec.customer_id
                                     AND rt.project_id = p_project_id
                                     AND rt.retention_level_code='TOP_TASK'
                                     AND erdl.event_num = evt.event_num
                                     AND nvl(erdl.task_id,-99) = nvl(evt.task_id,-99)
                                     AND erdl.project_id = evt.project_id
                                     AND erdl.draft_invoice_num=ProjInvRec.draft_invoice_num
                                     AND trunc(evt.completion_date) BETWEEN
                                         rt.effective_start_date and NVL(rt.effective_end_date,evt.completion_date+1));

		IF g1_debug_mode  = 'Y' THEN
		      pa_retention_util.write_log('ERDL: No Records Update At Project Level ' ||sql%rowcount);
		END IF;


	      -- 1. Update the Event Type Level Retention Setup in DII only for EVENTS

			UPDATE pa_draft_invoice_items dii
			   SET dii.retention_rule_id=
				( SELECT DECODE(NVL(rt.threshold_amount,0),0,
						rt.retention_rule_id,
				 	DECODE(SIGN(NVL(rt.total_retained,0) - NVL(rt.threshold_amount,0)),
					-1,rt.retention_rule_id,-99))
				    FROM pa_proj_retn_rules rt,
					 pa_events evt,
					 pa_event_types evttyp,
					 pa_tasks tsk
				   WHERE tsk.task_id = evt.task_id
				     AND tsk.top_task_id = rt.task_id
				     AND rt.customer_id = ProjCustRec.customer_id
				     AND rt.project_id = p_project_id
				     AND rt.retention_level_code='EVENT_TYPE'
				     AND dii.event_num = evt.event_num
				     AND nvl(dii.event_task_id,-99) = nvl(evt.task_id,-99)
				     AND dii.project_id = evt.project_id
				     AND trunc(evt.completion_date) BETWEEN
					 rt.effective_start_date and NVL(rt.effective_end_date,evt.completion_date+1)
				     AND evt.event_type = evttyp.event_type
				     AND evt.event_type = rt.event_type
				     AND evttyp.revenue_category_code= rt.revenue_category_code
		/*		     AND evttyp.event_type_classification in ('MANUAL', 'AUTOMATIC') Bug 3258414 - Changed for bug3478802*/
				     AND evttyp.event_type_classification <> 'WRITE ON'
				     AND dii.event_num is NOT NULL
				     AND dii.draft_invoice_num=ProjInvRec.draft_invoice_num)
			WHERE dii.project_id = p_project_id
			  AND dii.request_id = p_request_id
			  AND dii.draft_invoice_num = ProjInvRec.draft_invoice_num
			  AND dii.event_num IS NOT NULL
		          AND dii.retention_rule_id IS NULL
			  AND EXISTS( SELECT  NULL
  					FROM pa_proj_retn_rules rt,
                                         pa_events evt,
                                         pa_event_types evttyp,
                                         pa_tasks tsk
                                   WHERE tsk.task_id = evt.task_id
                                     AND tsk.top_task_id = rt.task_id
                                     AND rt.customer_id = ProjCustRec.customer_id
                                     AND rt.project_id = p_project_id
                                     AND rt.retention_level_code='EVENT_TYPE'
                                     AND dii.event_num = evt.event_num
                                     AND nvl(dii.event_task_id,-99) = nvl(evt.task_id,-99)
                                     AND dii.project_id = evt.project_id
                                     AND trunc(evt.completion_date) BETWEEN
                                         rt.effective_start_date and NVL(rt.effective_end_date,evt.completion_date+1)
                                     AND evt.event_type = evttyp.event_type
                                     AND evt.event_type = rt.event_type
                                     AND evttyp.revenue_category_code= rt.revenue_category_code
		/*		     AND evttyp.event_type_classification in ('MANUAL', 'AUTOMATIC') Bug 3258414 - Changed for bug3478802*/
				     AND evttyp.event_type_classification <> 'WRITE ON'
                                     AND dii.event_num is NOT NULL
                                     AND dii.draft_invoice_num=ProjInvRec.draft_invoice_num)
		;
		IF g1_debug_mode  = 'Y' THEN
		      pa_retention_util.write_log('DII: No Records Update At Event Type Level ' ||sql%rowcount);
		END IF;

	      -- 2. Update the Revenue Category Level Retention Setup in DII for events

			UPDATE pa_draft_invoice_items dii
			   SET dii.retention_rule_id=
				( SELECT DECODE(NVL(rt.threshold_amount,0),0,
						rt.retention_rule_id,
				 	DECODE(SIGN(NVL(rt.total_retained,0) - NVL(rt.threshold_amount,0)),
					-1,rt.retention_rule_id,-99))
				    FROM pa_proj_retn_rules rt,
					 pa_events evt,
					 pa_event_types evttyp,
					 pa_tasks tsk
				   WHERE tsk.task_id = evt.task_id
				     AND tsk.top_task_id = rt.task_id
				     AND rt.customer_id = ProjCustRec.customer_id
				     AND rt.project_id = p_project_id
				     AND rt.retention_level_code='REVENUE_CATEGORY'
				     AND dii.event_num = evt.event_num
				     AND nvl(dii.event_task_id,-99) = nvl(evt.task_id,-99)
				     AND dii.project_id = evt.project_id
				     AND trunc(evt.completion_date) BETWEEN
					 rt.effective_start_date and NVL(rt.effective_end_date,evt.completion_date+1)
				     AND evt.event_type = evttyp.event_type
				     AND evttyp.revenue_category_code= rt.revenue_category_code
		/*		     AND evttyp.event_type_classification in ('MANUAL', 'AUTOMATIC') Bug 3258414 - Changed for bug3478802*/
				     AND evttyp.event_type_classification <> 'WRITE ON'
				     AND dii.event_num IS NOT NULL
				     AND dii.draft_invoice_num=ProjInvRec.draft_invoice_num)
			WHERE dii.project_id = p_project_id
			  AND dii.request_id = p_request_id
			  AND dii.draft_invoice_num = ProjInvRec.draft_invoice_num
			  AND dii.event_num IS NOT NULL
		          AND dii.retention_rule_id IS NULL
			  AND EXISTS( SELECT NULL
			 FROM pa_proj_retn_rules rt,
                                         pa_events evt,
                                         pa_event_types evttyp,
                                         pa_tasks tsk
                                   WHERE tsk.task_id = evt.task_id
                                     AND tsk.top_task_id = rt.task_id
                                     AND rt.customer_id = ProjCustRec.customer_id
                                     AND rt.project_id = p_project_id
                                     AND rt.retention_level_code='REVENUE_CATEGORY'
                                     AND dii.event_num = evt.event_num
                                     AND nvl(dii.event_task_id,-99) = nvl(evt.task_id,-99)
                                     AND dii.project_id = evt.project_id
                                     AND trunc(evt.completion_date) BETWEEN
                                         rt.effective_start_date and NVL(rt.effective_end_date,evt.completion_date+1)
                                     AND evt.event_type = evttyp.event_type
                                     AND evttyp.revenue_category_code= rt.revenue_category_code
		/*		     AND evttyp.event_type_classification in ('MANUAL', 'AUTOMATIC') Bug 3258414 - Changed for bug3478802*/
				     AND evttyp.event_type_classification <> 'WRITE ON'
                                     AND dii.event_num IS NOT NULL
                                     AND dii.draft_invoice_num=ProjInvRec.draft_invoice_num);

		IF g1_debug_mode  = 'Y' THEN
		      pa_retention_util.write_log('DII: No Records Update At Revenue Category Level ' ||sql%rowcount);
		END IF;


	      -- 3. Update the Top Task Level Retention Setup in DIIs for Events

			UPDATE pa_draft_invoice_items dii
			   SET dii.retention_rule_id=
				( SELECT DECODE(NVL(rt.threshold_amount,0),0,
						rt.retention_rule_id,
					DECODE(SIGN(NVL(rt.total_retained,0) - NVL(rt.threshold_amount,0)),
					-1,rt.retention_rule_id,-99))
				    FROM pa_proj_retn_rules rt,
					 pa_events evt,
					 pa_event_types evttyp,  /* Bug 3258414 */
					 pa_tasks tsk
				   WHERE tsk.task_id = evt.task_id
				     AND tsk.top_task_id = rt.task_id
				     AND rt.customer_id = ProjCustRec.customer_id
				     AND rt.project_id = p_project_id
				     AND rt.retention_level_code='TOP_TASK'
				     AND dii.event_num = evt.event_num
				     AND nvl(dii.event_task_id,-99) = nvl(evt.task_id,-99)
				     AND dii.project_id = evt.project_id
				     AND trunc(evt.completion_date) BETWEEN
					 rt.effective_start_date and NVL(rt.effective_end_date,evt.completion_date +1)
				     AND dii.event_num IS NOT NULL
				     AND evttyp.event_type=evt.event_type /* Bug 3258414 */
		/*		     AND evttyp.event_type_classification in ('MANUAL', 'AUTOMATIC') Bug 3258414 - Changed for bug3478802*/
				     AND evttyp.event_type_classification <> 'WRITE ON'
				     AND dii.draft_invoice_num=ProjInvRec.draft_invoice_num)
			WHERE dii.project_id = p_project_id
			  AND dii.request_id = p_request_id
			  AND dii.draft_invoice_num = ProjInvRec.draft_invoice_num
			  AND dii.event_num IS NOT NULL
		          AND dii.retention_rule_id IS NULL
			  AND EXISTS
			   (SELECT NULL FROM pa_proj_retn_rules rt,
                                         pa_events evt,
					 pa_event_types evttyp,  /* Bug 3258414 */
                                         pa_tasks tsk
                                   WHERE tsk.task_id = evt.task_id
                                     AND tsk.top_task_id = rt.task_id
                                     AND rt.customer_id = ProjCustRec.customer_id
                                     AND rt.project_id = p_project_id
                                     AND rt.retention_level_code='TOP_TASK'
                                     AND dii.event_num = evt.event_num
                                     AND nvl(dii.event_task_id,-99) = nvl(evt.task_id,-99)
                                     AND dii.project_id = evt.project_id
                                     AND trunc(evt.completion_date) BETWEEN
                                         rt.effective_start_date and NVL(rt.effective_end_date,evt.completion_date +1)
                                     AND dii.event_num IS NOT NULL
				     AND evttyp.event_type=evt.event_type /* Bug 3258414 */
                                /* AND evttyp.event_type_classification in ('MANUAL','AUTOMATIC') Bug 3258414 - changed for bug 3478802*/
                                     AND evttyp.event_type_classification <> 'WRITE ON'
                                     AND dii.draft_invoice_num=ProjInvRec.draft_invoice_num);

		IF g1_debug_mode  = 'Y' THEN
		      pa_retention_util.write_log('DII: No Records Update At Project Level ' ||sql%rowcount);
		END IF;

	END IF;

	       IF g1_debug_mode  = 'Y' THEN
		  pa_retention_util.write_log('proj_invoice_retn_processing: ' || 'Calling Get_NetZero_Line');
	       END IF;

               /* Since net zero line comes up before retention line, net zero line num is cached here.
                  After retention lines are generated , last line num is updated onto this cached line */

               NetZeroLineNum:= Get_NetZero_Line(p_project_id => p_project_id,
				     		 p_draft_invoice_num=>draftinvoicenum);

		IF g1_debug_mode  = 'Y' THEN
			pa_retention_util.write_log('Proj_Invoice_Retn_Processing: ' || 'NetZero_Line  : ' || NetZeroLineNum);
			pa_retention_util.write_log('Proj_Invoice_Retn_Processing: ' || 'Call Create_Proj_Inv_Retn_Lines ');
		END IF;
		Create_Proj_Inv_Retn_Lines(p_project_id=>p_project_id,
                                           p_customer_id=>CustomerId,
                                           p_agreement_id=>ProjInvRec.agreement_id,
                                           p_draft_invoice_num=>DraftInvoiceNum,
					   p_cust_retn_level =>ProjCustRec.retention_level,
                                           p_request_id       =>p_request_id,
--	 				   p_Output_vat_tax_id =>Tmp_Output_vat_tax_id   ,
	 				   p_Output_tax_code =>Tmp_Output_tax_code ,
                                           p_Output_tax_exempt_flag=>Tmp_Output_tax_exempt_flag,
                                           p_Output_tax_exempt_number=>Tmp_Output_tax_exempt_number  ,
                                           p_Output_exempt_reason_code=>Tmp_Output_exempt_reason_code );

                If NetZeroLineNum <> 0 THEN

                   LastLineNum := Get_Invoice_Max_Line(p_project_id=>p_project_id,
                                                       p_draft_invoice_num=>DraftInvoiceNum);

                    /* Update net zero line to the last line after retention lines */

                   UPDATE PA_DRAFT_INVOICE_ITEMS
                   SET LINE_NUM = LastLineNum
                   WHERE PROJECT_ID = p_project_id
                   AND DRAFT_INVOICE_NUM = draftinvoicenum
                   AND LINE_NUM = NetZeroLineNum * (-1);

                   UPDATE PA_CUST_REV_DIST_LINES
                   SET DRAFT_INVOICE_ITEM_LINE_NUM = LastLineNum
                   WHERE PROJECT_ID = p_project_id
                   AND DRAFT_INVOICE_NUM = draftinvoicenum
                   AND DRAFT_INVOICE_ITEM_LINE_NUM = NetZeroLineNum;

                   UPDATE PA_CUST_EVENT_REV_DIST_LINES
                   SET DRAFT_INVOICE_ITEM_LINE_NUM = LastLineNum
                   WHERE PROJECT_ID = p_project_id
                   AND DRAFT_INVOICE_NUM = draftinvoicenum
                   AND DRAFT_INVOICE_ITEM_LINE_NUM = NetZeroLineNum;
                end If;



		IF ProjInvRec.inv_by_bill_trans_curr_flag ='Y' THEN

			IF g1_debug_mode  = 'Y' THEN
				pa_retention_util.write_log('Proj_Invoice_Retn_Processing: ' || 'Call Update_Retn_Bill_Trans_Amount ');
			END IF;

			Update_Retn_Bill_Trans_Amount(p_project_id=>p_project_id,
						      p_draft_invoice_num =>DraftInvoiceNum,
						      p_bill_trans_currency =>ProjInvRec.invoice_currency_code,
						      p_request_id =>p_request_id);

		END IF;

	END LOOP;

	CLOSE cur_proj_inv;

 END LOOP;

  IF g1_debug_mode  = 'Y' THEN
  	pa_retention_util.write_log('Leaving Proj_Invoice_Retn_Processing ');
  END IF;

CLOSE cur_proj_cust;
EXCEPTION
WHEN OTHERS THEN
IF g1_debug_mode  = 'Y' THEN
	pa_retention_util.write_log('Proj_Invoice_Retn_Processing: ' || 'Oracle Error ' || sqlerrm);
END IF;
 RAISE;

END Proj_Invoice_Retn_Processing;
--- Procedure   proj_invoice_credit_memo
--- Purpose     to build the credit memo retention lines

PROCEDURE Proj_Invoice_Credit_Memo(p_request_id                 IN NUMBER,
				   p_project_id			IN NUMBER,
                                   x_return_status             OUT NOCOPY VARCHAR2) IS --File.Sql.39 bug 4440895
LastLineNum	NUMBER:=0;
LastUpdatedBy		NUMBER:= fnd_global.user_id;
l_created_by		NUMBER:= fnd_global.user_id;
l_program_id                  NUMBER:= fnd_global.conc_program_id;
l_program_application_id      NUMBER:= fnd_global.prog_appl_id;
l_program_update_date         DATE  := sysdate;
l_last_update_date            DATE  := sysdate;
l_last_updated_by             NUMBER:= fnd_global.user_id;
l_last_update_login           NUMBER:= fnd_global.login_id;

ProjectCurrency		VARCHAR2(15);
l_credit_invoice_num	NUMBER:=0;
l_org_invoice_num	NUMBER:=0;

/* Select all the creditmemo invoices */

CURSOR cur_cm_invoice IS
	SELECT draft_invoice_num credit_invoice_num,
	       draft_invoice_num_credited org_invoice_num
	FROM pa_draft_invoices_all
	WHERE project_id = p_project_id
	  AND request_id = p_request_id
          AND draft_invoice_num_credited IS NOT NULL
      ORDER BY draft_invoice_num;

          --AND (CANCEL_CREDIT_MEMO_FLAG,'N') ='Y';

CmInvoiceRec cur_cm_invoice%ROWTYPE;

-- Select Credit RDLS. For old RDLS, process will use the old percentage

/* Commented and rewritten for bug 3958970
CURSOR  cur_credit_memo IS
          SELECT NVL(rdl.retention_rule_id,-1) retention_rule_id,
                 SUM(DECODE(NVL(rdl.retention_rule_id,-1) ,-1,
		     NVL(rdl.bill_amount,0)  ,NVL(rdl.retained_amount,0) ) ) invoice_amount
           FROM pa_cust_rev_dist_lines_all rdl
           WHERE rdl.project_id = p_project_id
        --         AND  rdl.request_id = p_request_id
                 AND  rdl.draft_invoice_num = l_credit_invoice_num
                 GROUP BY NVL(rdl.retention_rule_id,-1); */

CURSOR  cur_credit_memo IS
         SELECT retention_rule_id, sum(invoice_amount) invoice_amount
         FROM
          (SELECT NVL(rdl.retention_rule_id,-1) retention_rule_id,
                 SUM(DECODE(NVL(rdl.retention_rule_id,-1) ,-1,
                     NVL(rdl.bill_amount,0)  ,NVL(rdl.retained_amount,0) ) ) invoice_amount
           FROM pa_cust_rev_dist_lines_all rdl
           WHERE rdl.project_id = p_project_id
           AND  rdl.draft_invoice_num = l_credit_invoice_num
          GROUP BY NVL(rdl.retention_rule_id,-1)
          UNION
          SELECT NVL(di.retention_rule_id,-1) retention_rule_id,
                 SUM(DECODE(NVL(di.retention_rule_id,-1) ,-1,
                     NVL(di.amount,0)  ,NVL(di.retained_amount,0) ) ) invoice_amount
           FROM pa_draft_invoice_items di
           WHERE di.project_id = p_project_id
           AND  di.draft_invoice_num = l_credit_invoice_num
           AND  di.event_num is not null
           GROUP BY NVL(di.retention_rule_id,-1)) CR_RET
         GROUP BY retention_rule_id;

CreditMemoRec cur_credit_memo%ROWTYPE;
l_retention_percentage  NUMBER:=0;

BEGIN
  IF g1_debug_mode  = 'Y' THEN
  	pa_retention_util.write_log('Proj_Invoice_Credit_Memo: ' || ' Processing Credit Memos ');
  END IF;

     OPEN cur_cm_invoice;
     LOOP
       FETCH cur_cm_invoice INTO CmInvoiceRec;
       EXIT WHEN cur_cm_invoice%NOTFOUND;

	l_credit_invoice_num := CmInvoiceRec.credit_invoice_num;
	   l_org_invoice_num := CmInvoiceRec.org_invoice_num;

          IF g1_debug_mode  = 'Y' THEN
          	pa_retention_util.write_log('Proj_Invoice_Credit_Memo: ' || 'New Credit Invoice  :' || l_credit_invoice_num);
          	pa_retention_util.write_log('Proj_Invoice_Credit_Memo: ' || 'Old Orginal Invoice :' || l_org_invoice_num);
          END IF;

	-- This percentage will be used for old Rdls

		SELECT NVL(retention_percentage,0)/100
		  INTO l_retention_percentage
		 FROM pa_draft_invoices
		WHERE project_id = p_project_id
		  AND draft_invoice_num = l_org_invoice_num;

	OPEN cur_credit_memo;
	LOOP
	  FETCH cur_credit_memo INTO CreditMemoRec;
	  EXIT WHEN cur_credit_memo%NOTFOUND;

		LastLineNum := Get_Invoice_Max_Line(p_project_id=>p_project_id,
                                     p_draft_invoice_num=>l_credit_invoice_num);

                IF g1_debug_mode  = 'Y' THEN
                	pa_retention_util.write_log('Proj_Invoice_Credit_Memo: ' || 'New Credit Memo Retn Line  :' || LastLineNum);
                END IF;

		IF CreditMemoRec.retention_rule_id = -1 THEN

                        IF g1_debug_mode  = 'Y' THEN
                        	pa_retention_util.write_log('Proj_Invoice_Credit_Memo: ' || ' For Old RDLS use the old retn pct :' || l_retention_percentage);
                        END IF;

			CreditMemoRec.Invoice_amount := NVL( CreditMemoRec.Invoice_amount,0) * nvl(l_retention_percentage,0);

		END IF;

		FOR InvoiceLines IN
			(
			  SELECT CreditMemoRec.invoice_amount invoice_amount,
				   dii.text text,
 			           dii.invoice_line_type invoice_line_type,
 			           dii.task_id task_id,
 			  	   dii.event_task_id event_task_id,
			           dii.event_num event_num,
			           dii.ship_to_address_id ship_to_address_id,
 			  	   dii.taxable_flag taxable_flag,
-- 			  	   dii.output_vat_tax_id output_vat_tax_id,
 			  	   dii.output_tax_classification_code output_tax_code,
				   dii.output_tax_exempt_flag output_tax_exempt_flag,
 			  	   dii.output_tax_exempt_reason_code output_tax_exempt_reason_code,
				   dii.output_tax_exempt_number output_tax_exempt_number,
 			  	   dii.translated_text translated_text,
				   dii.projfunc_currency_code projfunc_currency_code,
			  	   ((dii.projfunc_bill_amount/dii.amount) *
					CreditMemoRec.invoice_amount) projfunc_bill_amount,
 			  dii.project_currency_code project_currency_code,
			  ((dii.project_bill_amount/dii.amount) * CreditMemoRec.invoice_amount) project_bill_amount,
			  dii.funding_currency_code funding_currency_code,
			  ((dii.funding_bill_amount/dii.amount) * CreditMemoRec.invoice_amount) funding_bill_amount,
			  dii.funding_rate_date funding_rate_date, dii.funding_exchange_rate funding_exchange_rate,
 			  dii.funding_rate_type funding_rate_type,dii.invproc_currency_code invproc_currency_code ,
			  dii.bill_trans_currency_code bill_trans_currency_code,
 			  --dii.bill_trans_bill_amount bill_trans_bill_amount, --Modified for Bug3558364
 			  ((dii.bill_trans_bill_amount/dii.amount) * CreditMemoRec.invoice_amount) bill_trans_bill_amount,
			  dii.retention_rule_id retention_rule_id,
		          di.agreement_id agreement_id,
			  agr.customer_id customer_id,
                          rtn.task_id rtn_task_id,
                          dii.line_num line_num_credited
			FROM  pa_draft_invoice_items dii, pa_draft_invoices_all di,
			      pa_agreements_all agr,
                              pa_proj_retn_rules rtn
			WHERE dii.project_id = p_project_id
			  AND dii.draft_invoice_num = l_org_invoice_num
			  AND dii.project_id = di.project_id
			  AND dii.draft_invoice_num = di.draft_invoice_num
			  AND di.agreement_id = agr.agreement_id
                          and dii.retention_rule_id = rtn.retention_rule_id
			  AND dii.retention_rule_id = CreditMemoRec.Retention_rule_id
                          AND dii.invoice_line_type ='RETENTION'
			  UNION
			  SELECT CreditMemoRec.invoice_amount invoice_amount,
				   dii.text text,
 			           dii.invoice_line_type invoice_line_type,
 			           dii.task_id task_id,
 			  	   dii.event_task_id event_task_id,
			           dii.event_num event_num,
			           dii.ship_to_address_id ship_to_address_id,
 			  	   dii.taxable_flag taxable_flag,
-- 			  	   dii.output_vat_tax_id output_vat_tax_id,
 			  	   dii.output_tax_classification_code output_tax_code,
				   dii.output_tax_exempt_flag output_tax_exempt_flag,
 			  	   dii.output_tax_exempt_reason_code output_tax_exempt_reason_code,
				   dii.output_tax_exempt_number output_tax_exempt_number,
 			  	   dii.translated_text translated_text,
				   dii.projfunc_currency_code projfunc_currency_code,
			  	   ((dii.projfunc_bill_amount/dii.amount) *
					CreditMemoRec.invoice_amount) projfunc_bill_amount,
 			  dii.project_currency_code project_currency_code,
			  ((dii.project_bill_amount/dii.amount) * CreditMemoRec.invoice_amount) project_bill_amount,
			  dii.funding_currency_code funding_currency_code,
			  ((dii.funding_bill_amount/dii.amount) * CreditMemoRec.invoice_amount) funding_bill_amount,
			  dii.funding_rate_date funding_rate_date, dii.funding_exchange_rate funding_exchange_rate,
 			  dii.funding_rate_type funding_rate_type,dii.invproc_currency_code invproc_currency_code ,
			  dii.bill_trans_currency_code bill_trans_currency_code,
 			  --dii.bill_trans_bill_amount bill_trans_bill_amount, --Modified for Bug3558364
 			  ((dii.bill_trans_bill_amount/dii.amount) * CreditMemoRec.invoice_amount) bill_trans_bill_amount,
			  dii.retention_rule_id retention_rule_id,
		          di.agreement_id agreement_id,
			  agr.customer_id customer_id,
                          dii.retention_rule_id rtn_task_id,  -- To get the retention lines
                          dii.line_num line_num_credited
			FROM  pa_draft_invoice_items dii, pa_draft_invoices_all di,
			      pa_agreements_all agr
			WHERE dii.project_id = p_project_id
			  AND dii.draft_invoice_num = l_org_invoice_num
			  AND dii.project_id = di.project_id
			  AND dii.draft_invoice_num = di.draft_invoice_num
			  AND di.agreement_id = agr.agreement_id
			  AND NVL(dii.retention_rule_id,-1) = -1
			  AND CreditMemoRec.Retention_rule_id = -1
                          AND dii.invoice_line_type ='RETENTION'
				) LOOP

                        IF g1_debug_mode  = 'Y' THEN
                        	pa_retention_util.write_log('Proj_Invoice_Credit_Memo: ' || 'New Credit Memo Retn Line RuleId  :' || CreditMemoRec.Retention_rule_id);
                        	pa_retention_util.write_log('Proj_Invoice_Credit_Memo: ' || 'Orgional Invoice  :' || l_org_invoice_num);
                        	pa_retention_util.write_log('Proj_Invoice_Credit_Memo: ' || 'Retn Line Credited  :' || InvoiceLines.line_num_credited);
                        	pa_retention_util.write_log('Proj_Invoice_Credit_Memo: ' || 'New Invoice  :' || l_credit_invoice_num);
                        	pa_retention_util.write_log('Proj_Invoice_Credit_Memo: ' || 'Retn Line Credited  :' || lastlinenum);
                        END IF;

		INSERT INTO pa_draft_invoice_items
			( PROJECT_ID,  DRAFT_INVOICE_NUM, LINE_NUM,
 			  LAST_UPDATE_DATE, LAST_UPDATED_BY, CREATION_DATE,
 			  CREATED_BY, AMOUNT,  TEXT,
 			  INVOICE_LINE_TYPE, REQUEST_ID, PROGRAM_APPLICATION_ID,
 			  PROGRAM_ID, PROGRAM_UPDATE_DATE, TASK_ID,
 			  EVENT_TASK_ID, EVENT_NUM, SHIP_TO_ADDRESS_ID,
 			  TAXABLE_FLAG,  LAST_UPDATE_LOGIN,
 			  INV_AMOUNT, OUTPUT_TAX_CLASSIFICATION_CODE, OUTPUT_TAX_EXEMPT_FLAG,
 			  OUTPUT_TAX_EXEMPT_REASON_CODE, OUTPUT_TAX_EXEMPT_NUMBER,
 			   TRANSLATED_TEXT, PROJFUNC_CURRENCY_CODE, PROJFUNC_BILL_AMOUNT,
 			  PROJECT_CURRENCY_CODE, PROJECT_BILL_AMOUNT, FUNDING_CURRENCY_CODE,
 			  FUNDING_BILL_AMOUNT, FUNDING_RATE_DATE, FUNDING_EXCHANGE_RATE,
 			  FUNDING_RATE_TYPE , INVPROC_CURRENCY_CODE, BILL_TRANS_CURRENCY_CODE,
 			  BILL_TRANS_BILL_AMOUNT, RETENTION_RULE_ID,
			  DRAFT_INV_LINE_NUM_CREDITED)
			VALUES(
			  p_project_id,  l_credit_invoice_num, lastlinenum,
 			  sysdate, LASTUPDATEDBY, SYSDATE,
 			  l_created_by,
			  (-1) * InvoiceLines.invoice_amount,
			  InvoiceLines.text,
 			  InvoiceLines.invoice_line_type, p_request_id, l_program_application_id,
 			  l_program_id, sysdate, InvoiceLines.task_id,
 			  InvoiceLines.event_task_id, InvoiceLines.event_num, InvoiceLines.ship_to_address_id,
 			  InvoiceLines.taxable_flag,  l_last_update_login,
 			  null, InvoiceLines.output_tax_code, InvoiceLines.output_tax_exempt_flag,
 			  InvoiceLines.output_tax_exempt_reason_code, InvoiceLines.output_tax_exempt_number,
 			  InvoiceLines.translated_text, InvoiceLines.projfunc_currency_code,
			  PA_CURRENCY.ROUND_TRANS_CURRENCY_AMT(  (-1) * InvoiceLines.projfunc_bill_amount,
 			  invoicelines.projfunc_currency_code),
 			  invoicelines.project_currency_code,
			  PA_CURRENCY.ROUND_TRANS_CURRENCY_AMT((-1) * invoicelines.project_bill_amount,
 			  invoicelines.project_currency_code),
			  InvoiceLines.funding_currency_code,
			  PA_CURRENCY.ROUND_TRANS_CURRENCY_AMT((-1) * InvoiceLines.funding_bill_amount,
			  InvoiceLines.funding_currency_code),
			  InvoiceLines.funding_rate_date, InvoiceLines.funding_exchange_rate,
 			  InvoiceLines.funding_rate_type ,InvoiceLines.invproc_currency_code,
			  InvoiceLines.bill_trans_currency_code,
 			  DECODE(NVL(InvoiceLines.bill_trans_bill_amount,0),0,0,
				   PA_CURRENCY.ROUND_TRANS_CURRENCY_AMT((-1) * InvoiceLines.bill_trans_bill_amount,
				InvoiceLines.bill_trans_currency_code)),
			    InvoiceLines.retention_rule_id,
			    InvoiceLines.line_num_credited);

			IF  NVL(InvoiceLines.retention_rule_id,-1) <> -1 THEN

          		        IF g1_debug_mode  = 'Y' THEN
          		        	pa_retention_util.write_log('Proj_Invoice_Credit_Memo: ' || 'Calling Update_Retention_Balances ');
          		        END IF;

 				Update_Retention_Balances(p_retention_rule_id =>InvoiceLines.Retention_rule_id     ,
                                        p_project_id =>p_project_id           ,
                                        p_task_id    =>InvoiceLines.rtn_Task_id,
                                        p_agreement_id =>InvoiceLines.agreement_id,
                                        p_customer_id  =>InvoiceLines.customer_id,
                                        p_amount       => InvoiceLines.invoice_amount,
                                        p_change_type  => 'RETAINED' ,
                                        p_request_id   =>p_request_id,
                                        p_invproc_currency =>InvoiceLines.invproc_currency_code      ,
                                        p_project_currency =>InvoiceLines.project_currency_code,
                                        p_project_amount   => InvoiceLines.project_bill_amount,
                                        p_projfunc_currency =>InvoiceLines.projfunc_currency_code,
                                        p_projfunc_amount   =>InvoiceLines.projfunc_bill_amount,
                                        p_funding_currency  =>InvoiceLines.funding_currency_code   ,
                                        p_funding_amount    =>InvoiceLines.funding_bill_amount);


          		        IF g1_debug_mode  = 'Y' THEN
          		        	pa_retention_util.write_log('Proj_Invoice_Credit_Memo: ' || 'Update RDL with new Retention Line Number');
          		        	pa_retention_util.write_log('Proj_Invoice_Credit_Memo: ' || 'Invoice Number   : ' || l_credit_invoice_num);
          		        	pa_retention_util.write_log('Proj_Invoice_Credit_Memo: ' || 'Rule Id   : ' ||
							 InvoiceLines.Retention_rule_id);
          		        	pa_retention_util.write_log('Proj_Invoice_Credit_Memo: ' || 'Project  Id  : ' || p_project_id);
          		        END IF;

				-- Update the RDL

			 		UPDATE pa_cust_rev_dist_lines_all
                                             SET retn_draft_invoice_num = l_credit_invoice_num,
                                                 retn_draft_invoice_line_num = LastLineNum
                                                WHERE retention_rule_id = InvoiceLines.Retention_rule_id
                                                  AND draft_invoice_num = l_credit_invoice_num
                                                  AND project_id        = p_project_id;

		IF g1_debug_mode  = 'Y' THEN
          		        pa_retention_util.write_log('RDL Number of rows updated  : ' || sql%rowcount);
		END IF;

                                  -- Update the DII - Added for bug 3958970

                                UPDATE pa_draft_invoice_items
                                SET retn_draft_invoice_num = l_credit_invoice_num,
                                    retn_draft_invoice_line_num = LastLineNum
                                WHERE retention_rule_id = InvoiceLines.Retention_rule_id
                                AND draft_invoice_num = l_credit_invoice_num
                                AND project_id        = p_project_id
				AND invoice_line_type <> 'RETENTION';

                                IF g1_debug_mode  = 'Y' THEN
                                     pa_retention_util.write_log('DII Number of rows updated  : ' || sql%rowcount);
                                END IF;
			END IF;


		END LOOP;


	END LOOP;

	CLOSE cur_credit_memo;

    END LOOP;

  CLOSE cur_cm_invoice;
 x_return_status :=FND_API.G_RET_STS_SUCCESS;
EXCEPTION
WHEN OTHERS THEN
 x_return_status :='E';
IF g1_debug_mode  = 'Y' THEN
	pa_retention_util.write_log('Proj_Invoice_Credit_Memo: ' || 'Oracle Error ' || sqlerrm);
END IF;
      RAISE;

END Proj_Invoice_Credit_Memo;
-- Procedure Retn_Invoice_Cancel
-- Purpose   Cancel the retention invoice
PROCEDURE Invoice_Cancel_Action(p_request_id                    IN NUMBER,
			 	p_invoice_type			IN VARCHAR2,
                         	p_project_id                    IN NUMBER,
                         	p_draft_invoice_num             IN NUMBER,
                         	x_return_status                 OUT NOCOPY VARCHAR2) IS --File.Sql.39 bug 4440895
TmpInvoiceNum	NUMBER:=0;
LastUpdatedBy		NUMBER:= fnd_global.user_id;
l_created_by		NUMBER:= fnd_global.user_id;
l_program_id                  NUMBER:= fnd_global.conc_program_id;
l_program_application_id      NUMBER:= fnd_global.prog_appl_id;
l_program_update_date         DATE  := sysdate;
l_last_update_date            DATE  := sysdate;
l_last_updated_by             NUMBER:= fnd_global.user_id;
l_last_update_login           NUMBER:= fnd_global.login_id;
TmpInvoiceDate          DATE:= TO_DATE(pa_billing.globvars.InvoiceDate,'YYYY/MM/DD');
TmpBillThruDate         DATE:= TO_DATE(pa_billing.globvars.BillThruDate,'YYYY/MM/DD');
TmpPADate               DATE:= TO_DATE(pa_billing.globvars.PADate,'YYYY/MM/DD');
TmpGLDate               DATE:= TO_DATE(pa_billing.globvars.GLDate,'YYYY/MM/DD');


BEGIN
	IF p_invoice_type ='RETENTION' THEN
		-- Cancel the retention invoice
		-- Reverse the retention invoice
                -- Update the balances
		-- Setting the cancel invoice

		 UPDATE PA_DRAFT_INVOICES
               		SET CANCELED_FLAG = 'Y',
                            INVOICE_COMMENT =
                        (select rtrim(upper(l.meaning)||' '||
                                      rtrim(SUBSTRB(i.invoice_comment,1,232)))
                         from   pa_lookups l,
                                pa_draft_invoices i
                         where  i.project_Id = p_project_id
                         and    i.draft_invoice_num = p_draft_invoice_num
                         and    l.lookup_type = 'INVOICE_CREDIT_TYPE'
                         and    l.lookup_code = 'CANCEL')
                WHERE PROJECT_ID = p_project_id
                AND DRAFT_INVOICE_NUM = p_draft_invoice_num
                AND nvl(CANCELED_FLAG, 'N') <> 'Y';

		-- Get the new draft invoice num

         	SELECT NVL( MAX(p.draft_invoice_num) + 1, 1)
                  INTO TmpInvoiceNum
                  FROM pa_draft_invoices_all p
                 WHERE p.project_id = p_project_id;

                  IF g1_debug_mode  = 'Y' THEN
                  	pa_retention_util.write_log('Invoice_Cancel_Action: ' || 'New Invoice Num   : ' || TmpInvoiceNum);
                  END IF;

		-- Copy the Header as it is
			INSERT INTO pa_draft_invoices_all
			(
			PROJECT_ID                   ,
 			DRAFT_INVOICE_NUM            ,
 			LAST_UPDATE_DATE             ,
 			LAST_UPDATED_BY              ,
 			CREATION_DATE                ,
 			CREATED_BY                   ,
 			TRANSFER_STATUS_CODE         ,
 			GENERATION_ERROR_FLAG        ,
 			AGREEMENT_ID                 ,
 			PA_DATE                      ,
 			REQUEST_ID                   ,
 			PROGRAM_APPLICATION_ID       ,
 			PROGRAM_ID                   ,
 			 PROGRAM_UPDATE_DATE          ,
 			CUSTOMER_BILL_SPLIT          ,
 			BILL_THROUGH_DATE            ,
 			INVOICE_COMMENT              ,
 			INVOICE_DATE                 ,
 			GL_DATE                      ,
 			CANCELED_FLAG                ,
 			LAST_UPDATE_LOGIN            ,
 			ATTRIBUTE_CATEGORY           ,
 			ATTRIBUTE1                   ,
 			ATTRIBUTE2                   ,
 			ATTRIBUTE3                   ,
 			ATTRIBUTE4                   ,
 			ATTRIBUTE5                   ,
 			ATTRIBUTE6                   ,
 			ATTRIBUTE7                   ,
 			ATTRIBUTE8                   ,
 			ATTRIBUTE9                   ,
 			ATTRIBUTE10                  ,
 			RETENTION_PERCENTAGE         ,
 			--INVOICE_SET_ID             ,  /*  Commented for Bug 2448872 */
 			ORG_ID                       ,
 			INV_CURRENCY_CODE            ,
 			INV_RATE_TYPE                ,
 			INV_RATE_DATE                ,
 			INV_EXCHANGE_RATE            ,
 			BILL_TO_ADDRESS_ID           ,
 			SHIP_TO_ADDRESS_ID           ,
 			ACCTD_CURR_CODE              ,
 			ACCTD_RATE_TYPE              ,
 			ACCTD_RATE_DATE              ,
			 ACCTD_EXCHG_RATE             ,
			 LANGUAGE                     ,
			 INVPROC_CURRENCY_CODE        ,
			 PROJFUNC_INVTRANS_RATE_TYPE  ,
			 PROJFUNC_INVTRANS_RATE_DATE  ,
			 PROJFUNC_INVTRANS_EX_RATE    ,
			 PA_PERIOD_NAME               ,
			 GL_PERIOD_NAME               ,
			 RETENTION_INVOICE_FLAG       ,
			 DRAFT_INVOICE_NUM_CREDITED   ,
			 CANCEL_CREDIT_MEMO_FLAG      , -- Added for Bug 2448872
                         APPROVED_BY_PERSON_ID        , -- Added for Bug 2448872
                         APPROVED_DATE                ,  -- Added for Bug 2448872
                         CUSTOMER_ID                  ,
                         BILL_TO_CUSTOMER_ID          ,
                         SHIP_TO_CUSTOMER_ID          ,
                         BILL_TO_CONTACT_ID           ,
                         SHIP_TO_CONTACT_ID        )
			SELECT
				p_project_id ,
			 	TmpInvoiceNum,
			 	SYSDATE,
			 	LastUpdatedBy,
			 	sysdate,
				l_created_by,
			 	'P',
			 	'N',
			 	di.agreement_id,
			 	TmpPaDate,
				p_request_id,
			 	l_program_application_id,
			 	l_program_id,
				sysdate,
			 	di.customer_bill_split,
			 	di.bill_through_date,
			 	di.INVOICE_COMMENT,
			 	TmpInvoiceDate,
			 	TmpGlDate,
			 	'N' ,
			 	l_last_update_login,
			 	di.ATTRIBUTE_CATEGORY,
				di.ATTRIBUTE1,
				di.ATTRIBUTE2,
			 	di.ATTRIBUTE3,
			 	di.ATTRIBUTE4,
			 	di.ATTRIBUTE5,
			 	di.ATTRIBUTE6,
			 	di.ATTRIBUTE7,
			 	di.ATTRIBUTE8,
			 	di.ATTRIBUTE9,
			 	di.ATTRIBUTE10,
			 	di.RETENTION_PERCENTAGE,
			-- 	di.INVOICE_SET_ID,  /*  Commented for Bug 2448872 */
			 	di.ORG_ID,
			 	di.INV_CURRENCY_CODE,
			 	di.INV_RATE_TYPE,
			 	di.INV_RATE_DATE,
			 	di.INV_EXCHANGE_RATE,
			 	di.BILL_TO_ADDRESS_ID,
			 	di.SHIP_TO_ADDRESS_ID,
			 	di.ACCTD_CURR_CODE,
			 	di.ACCTD_RATE_TYPE,
			 	di.ACCTD_RATE_DATE,
			 	di.ACCTD_EXCHG_RATE,
			 	di.LANGUAGE,
				di.INVPROC_CURRENCY_CODE        ,
			 	di.PROJFUNC_INVTRANS_RATE_TYPE  ,
			 	di.PROJFUNC_INVTRANS_RATE_DATE  ,
			 	di.PROJFUNC_INVTRANS_EX_RATE    ,
			 	pa_billing.getpaperiodname,
                	        pa_billing.getglperiodname ,
			 	di.RETENTION_INVOICE_FLAG,
				p_draft_invoice_num,
				'Y',                        -- Added for Bug 2448872
				di.approved_by_person_id,   -- Added for Bug 2448872
				di.approved_date,           -- Added for Bug 2448872
                                di.customer_id,
                                di.bill_to_customer_id,
                                di.ship_to_customer_id,
                                di.bill_to_contact_id,
                                di.ship_to_contact_id    /*last 3 columns added for
                                                       customer account relation enhancement*/
			FROM pa_draft_invoices_all di
			WHERE di.project_id = p_project_id
			  AND di.draft_invoice_num = p_draft_invoice_num;

		 FOR InvoiceLines IN (SELECT dii.line_num line_Num ,
					    dii. invproc_currency_code invproc_currency_code,
					    dii.amount amount,
					    dii.projfunc_currency_code projfunc_currency_code,
					    dii.projfunc_bill_amount projfunc_bill_amount,
					    dii.project_currency_code project_currency_code,
					    dii.project_bill_amount project_bill_amount,
					    dii.funding_currency_code funding_currency_code,
					    dii.funding_bill_amount funding_bill_amount,
					    dii.event_task_id event_task_id,
					    dii.taxable_flag taxable_flag,
					    --dii.output_vat_tax_id output_vat_tax_id,
                                            dii.output_tax_classification_code,
					    dii.funding_rate_date funding_rate_date,
					    dii.funding_rate_type funding_rate_type,
					    dii.funding_exchange_rate funding_exchange_rate,
					    dii.invoice_line_type invoice_line_type,
					    dii.output_tax_exempt_flag output_tax_exempt_flag,
                          		    dii.output_tax_exempt_reason_code output_tax_exempt_reason_code,
					    dii.output_tax_exempt_number output_tax_exempt_number,
                          		    dii.translated_text translated_text,
                          		    dii.text text,
                          		    dii.event_num event_num,
					    dii.task_id task_id,
					    dii.retention_rule_id retention_rule_id,
					    dii.ship_to_address_id ship_to_address_id,
					    dii.bill_trans_currency_code bill_trans_currency_code,
					    dii.bill_trans_bill_amount bill_trans_bill_amount,
					    di.agreement_id agreement_id,
					   agr.customer_id customer_id,
                                           nvl(rtn.task_id, dii.task_id)  rtn_task_id,
                                           dii.inv_amount inv_amount
					 FROM pa_draft_invoice_items dii, pa_draft_invoices_all di,
					      pa_agreements_all agr,
                                              pa_proj_retn_rules rtn
					WHERE di.project_id = p_project_id
					  AND di.draft_invoice_num = p_draft_invoice_num
					  AND di.agreement_id = agr.agreement_id
					  AND di.project_id = dii.project_id
					  AND di.draft_invoice_num = dii.draft_invoice_num
					  AND dii.retention_rule_id = rtn.retention_rule_id(+)) LOOP

			INSERT INTO pa_draft_invoice_items
			( PROJECT_ID,  DRAFT_INVOICE_NUM, LINE_NUM,
 			  LAST_UPDATE_DATE, LAST_UPDATED_BY, CREATION_DATE,
 			  CREATED_BY, AMOUNT,  TEXT,
 			  INVOICE_LINE_TYPE, REQUEST_ID, PROGRAM_APPLICATION_ID,
 			  PROGRAM_ID, PROGRAM_UPDATE_DATE, TASK_ID,
 			  EVENT_TASK_ID, EVENT_NUM, SHIP_TO_ADDRESS_ID,
 			  TAXABLE_FLAG,  LAST_UPDATE_LOGIN,
 			  INV_AMOUNT, OUTPUT_TAX_CLASSIFICATION_CODE, OUTPUT_TAX_EXEMPT_FLAG,
 			  OUTPUT_TAX_EXEMPT_REASON_CODE, OUTPUT_TAX_EXEMPT_NUMBER,
 			   TRANSLATED_TEXT, PROJFUNC_CURRENCY_CODE, PROJFUNC_BILL_AMOUNT,
 			  PROJECT_CURRENCY_CODE, PROJECT_BILL_AMOUNT, FUNDING_CURRENCY_CODE,
 			  FUNDING_BILL_AMOUNT, FUNDING_RATE_DATE, FUNDING_EXCHANGE_RATE,
 			  FUNDING_RATE_TYPE , INVPROC_CURRENCY_CODE, BILL_TRANS_CURRENCY_CODE,
 			  BILL_TRANS_BILL_AMOUNT, RETENTION_RULE_ID,
			  DRAFT_INV_LINE_NUM_CREDITED
			  )
			VALUES(
			  p_project_id,  TmpInvoiceNum, InvoiceLines.line_num,
 			  sysdate, LastUpdatedBy, SYSDATE,
 			  l_created_by, (-1) *  InvoiceLines.amount, InvoiceLines.text,
 			  InvoiceLines.invoice_line_type, p_request_id, l_program_application_id,
 			  l_program_id, sysdate, InvoiceLines.task_id,
 			  InvoiceLines.event_task_id, InvoiceLines.event_num,
			  InvoiceLines.ship_to_address_id,
 			  InvoiceLines.taxable_flag,  l_last_update_login,
 			  (-1) * InvoiceLines.inv_amount, InvoiceLines.output_tax_classification_code,
			  InvoiceLines.output_tax_exempt_flag,
 			  InvoiceLines.output_tax_exempt_reason_code, InvoiceLines.output_tax_exempt_number,
 			  InvoiceLines.translated_text, InvoiceLines.projfunc_currency_code,
			  (-1) * InvoiceLines.projfunc_bill_amount,
 			  InvoiceLines.project_currency_code, (-1) * InvoiceLines.project_bill_amount,
			  InvoiceLines.funding_currency_code,
			  (-1) * InvoiceLines.funding_bill_amount,
			  InvoiceLines.funding_rate_date, InvoiceLines.funding_exchange_rate,
 			  InvoiceLines.funding_rate_type ,InvoiceLines.invproc_currency_code,
			  InvoiceLines.bill_trans_currency_code,
 			  InvoiceLines.bill_trans_bill_amount, InvoiceLines.retention_rule_id,
			  InvoiceLines.line_num
			  );

		 pa_mc_currency_pkg.invoice_action := 'CANCEL';

 		Update_Retention_Balances(p_retention_rule_id =>InvoiceLines.Retention_rule_id     ,
                                        p_project_id =>p_project_id           ,
                                        p_task_id    =>InvoiceLines.rtn_Task_id,
                                        p_agreement_id =>InvoiceLines.agreement_id,
                                        p_customer_id  =>InvoiceLines.customer_id,
                                        p_amount       => (-1) * InvoiceLines.amount,
                                        p_change_type  => 'BILLED' ,
                                        p_request_id   =>p_request_id,
                                        p_invproc_currency =>InvoiceLines.invproc_currency_code      ,
                                        p_project_currency =>InvoiceLines.project_currency_code,
                                        p_project_amount   => (-1) * InvoiceLines.project_bill_amount,
                                        p_projfunc_currency =>InvoiceLines.projfunc_currency_code,
                                        p_projfunc_amount   => (-1) * InvoiceLines.projfunc_bill_amount,
                                        p_funding_currency  => InvoiceLines.funding_currency_code   ,
                                        p_funding_amount    => (-1) * InvoiceLines.funding_bill_amount);

		END LOOP;

		-- Reverse Retention Invoice Details

		INSERT INTO pa_retn_invoice_details
			( RETN_INVOICE_DETAIL_ID, PROJECT_ID, DRAFT_INVOICE_NUM,
 			  LINE_NUM , PROJECT_RETENTION_ID, TOTAL_RETAINED,
 			  INVPROC_CURRENCY_CODE, PROJFUNC_CURRENCY_CODE,
 			  PROJFUNC_TOTAL_RETAINED, PROJECT_CURRENCY_CODE,
 			  PROJECT_TOTAL_RETAINED , FUNDING_CURRENCY_CODE,
 			  FUNDING_TOTAL_RETAINED, PROGRAM_APPLICATION_ID ,
 			  PROGRAM_UPDATE_DATE, REQUEST_ID,
 			  CREATION_DATE, CREATED_BY,
 			  LAST_UPDATE_DATE,
 			  LAST_UPDATED_BY,
 			  PROGRAM_ID )
			SELECT
				pa_retn_invoice_details_s.nextval,
			       p_project_id,
			       TmpInvoiceNum,
			       rtndet.line_num,
			       rtndet.project_retention_id,
			       rtndet.total_retained,
			       rtndet.invproc_currency_code,
			       rtndet.projfunc_currency_code,
			       rtndet.projfunc_total_retained,
			       rtndet.project_currency_code,
			       rtndet.project_total_retained,
			       rtndet.funding_currency_code,
			       rtndet.funding_total_retained,
			       l_program_application_id,
			       sysdate, p_request_id,
			       sysdate, l_created_by,
				sysdate, LastUpdatedBy,
			       l_program_id
			 FROM pa_retn_invoice_details rtndet
			WHERE rtndet.project_id = p_project_id
			  AND rtndet.draft_invoice_num = p_draft_invoice_num;

	ELSIF p_invoice_type ='PROJECT_INVOICE' THEN

		 FOR InvoiceLines IN (SELECT
					    dii. invproc_currency_code invproc_currency_code,
					    dii.amount amount, dii.projfunc_currency_code projfunc_currency_code,
					    dii.projfunc_bill_amount projfunc_bill_amount,
					    dii.project_currency_code project_currency_code,
					    dii.project_bill_amount project_bill_amount,
					    dii.funding_currency_code funding_currency_code,
					    dii.funding_bill_amount funding_bill_amount,
					    dii.task_id task_id,
					    dii.retention_rule_id retention_rule_id,
					    di.agreement_id agreement_id,
					   agr.customer_id customer_id,
				 	   rtn.task_id rtn_task_id
					 FROM pa_draft_invoice_items dii,
					      pa_draft_invoices_all di,
					      pa_agreements_all agr,
                                              pa_proj_retn_rules rtn
					WHERE di.project_id = p_project_id
					  AND di.draft_invoice_num = p_draft_invoice_num
					  AND di.agreement_id = agr.agreement_id
					  AND di.project_id = dii.project_id
					  AND di.draft_invoice_num = dii.draft_invoice_num
					  AND dii.invoice_line_type = 'RETENTION'
						-- # Fix for 2366314
					  AND dii.retention_rule_id = rtn.retention_rule_id
				          AND dii.retention_rule_id is not null) LOOP

 		Update_Retention_Balances(p_retention_rule_id =>InvoiceLines.Retention_rule_id     ,
                                        p_project_id =>p_project_id           ,
                                        p_task_id    =>InvoiceLines.rtn_Task_id,
                                        p_agreement_id =>InvoiceLines.agreement_id,
                                        p_customer_id  =>InvoiceLines.customer_id,
                        		p_amount       => InvoiceLines.amount,
					  -- # Fix for 2366314 (-1) * InvoiceLines.amount,
                                        p_change_type  => 'RETAINED' ,
                                        p_request_id   =>p_request_id,
                                        p_invproc_currency =>InvoiceLines.invproc_currency_code      ,
                                        p_project_currency =>InvoiceLines.project_currency_code,
                        p_project_amount   => InvoiceLines.project_bill_amount,
			-- # Fix for 2366314 (-1) * InvoiceLines.project_bill_amount,
                                        p_projfunc_currency =>InvoiceLines.projfunc_currency_code,
                        p_projfunc_amount   => InvoiceLines.projfunc_bill_amount,
			-- # Fix for 2366314 (-1) * InvoiceLines.projfunc_bill_amount,
                                        p_funding_currency  => InvoiceLines.funding_currency_code   ,
                        p_funding_amount    => InvoiceLines.funding_bill_amount);
			-- # Fix for 2366314 (-1) * InvoiceLines.funding_bill_amount);

	         END LOOP;
	END IF;

END Invoice_Cancel_Action;
-- Procedure Invoice_Delete_Action
PROCEDURE Invoice_Delete_Action(p_request_id                    IN NUMBER,
			 	p_invoice_type			IN VARCHAR2,
                         	p_project_id                    IN NUMBER,
                         	p_draft_invoice_num             IN NUMBER,
                         	x_return_status                 OUT NOCOPY VARCHAR2) IS --File.Sql.39 bug 4440895
TmpChangeType		VARCHAR2(15);

BEGIN
 IF g1_debug_mode  = 'Y' THEN
 	pa_retention_util.write_log('Invoice_Delete_Action ');
 END IF;

    IF p_invoice_type ='PROJECT_INVOICE' THEN

	tmpChangeType := 'RETAINED';

    ELSIF p_invoice_type ='RETENTION' THEN

	tmpChangeType := 'BILLED';

    END IF;

	IF g1_debug_mode  = 'Y' THEN
		pa_retention_util.write_log('Invoice_Delete_Action: ' || 'Change Type  : ' || tmpChangeType);
	END IF;

	    FOR InvoiceLines IN (SELECT
		       decode(tmpChangeType,'BILLED', -1 *   dii.amount ,
				dii.amount ) amount,
		          dii.task_id task_id,
	        	  dii.invproc_currency_code invproc_currency_code,
	        	  decode(tmpChangeType,'BILLED', -1 * dii.projfunc_bill_amount,
				dii.projfunc_bill_amount) projfunc_bill_amount,
	        	  dii.projfunc_currency_code projfunc_currency_code,
			  decode(tmpChangeType,'BILLED', -1 * dii.project_bill_amount,
				dii.project_bill_amount) project_bill_amount,
	        	  dii.project_currency_code project_currency_code,
	        	  dii.funding_currency_code funding_currency_code,
	        	  decode( tmpChangeType,'BILLED', -1 * dii.funding_bill_amount,
					dii.funding_bill_amount) funding_bill_amount,
			  dii.retention_rule_id retention_rule_id,
			  di.agreement_id agreement_id,
			  agr.customer_id customer_id,
			  NVL(rtn.task_id,dii.task_id) rtn_task_id
		    FROM pa_draft_invoice_items dii,
			 pa_draft_invoices_all di,
			 pa_agreements_all agr,
			 pa_proj_retn_rules rtn
		WHERE di.project_id = p_project_id
		  AND di.draft_invoice_num = p_draft_invoice_num
		  AND di.agreement_id = agr.agreement_id
		  AND di.project_id = dii.project_id
		  AND di.draft_invoice_num = dii.draft_invoice_num
		  AND dii.retention_rule_id = rtn.retention_rule_id (+)
		  AND dii.invoice_line_type='RETENTION') LOOP

		IF g1_debug_mode  = 'Y' THEN
			pa_retention_util.write_log('Invoice_Delete_Action: ' || 'Invoice Number : ' || p_draft_invoice_num);
			pa_retention_util.write_log('Invoice_Delete_Action: ' || 'Project Id     : ' || p_project_id);
			pa_retention_util.write_log('Invoice_Delete_Action: ' || 'Retention Rule : ' || InvoiceLines.Retention_rule_id);
			pa_retention_util.write_log('Invoice_Delete_Action: ' || 'Invoice Amount : ' || InvoiceLines.amount);
			pa_retention_util.write_log('Invoice_Delete_Action: ' || 'PFC Invoice Amount : ' || InvoiceLines.projfunc_bill_amount);
			pa_retention_util.write_log('Invoice_Delete_Action: ' || 'PC Invoice Amount : ' || InvoiceLines.project_bill_amount);
			pa_retention_util.write_log('Invoice_Delete_Action: ' || 'FC Invoice Amount : ' || InvoiceLines.funding_bill_amount);
		END IF;


 		Update_Retention_Balances(p_retention_rule_id =>InvoiceLines.Retention_rule_id,
                                        p_project_id =>p_project_id,
                                        p_task_id    =>InvoiceLines.rtn_Task_id,
                                        p_agreement_id =>InvoiceLines.agreement_id,
                                        p_customer_id  =>InvoiceLines.customer_id,
                                        p_amount       =>InvoiceLines.amount,
                                        p_change_type  => TmpChangeType ,
                                        p_request_id   =>p_request_id,
                                        p_invproc_currency =>InvoiceLines.invproc_currency_code,
                                        p_project_currency =>InvoiceLines.project_currency_code,
                                        p_project_amount   => InvoiceLines.project_bill_amount,
                                        p_projfunc_currency =>InvoiceLines.projfunc_currency_code,
                                        p_projfunc_amount   => InvoiceLines.projfunc_bill_amount,
                                        p_funding_currency  => InvoiceLines.funding_currency_code ,
                                        p_funding_amount    => InvoiceLines.funding_bill_amount);

		END LOOP;

    IF TmpChangeType ='BILLED' THEN

	  -- Delete the retention invoice details

		IF g1_debug_mode  = 'Y' THEN
			pa_retention_util.write_log('Invoice_Delete_Action: ' || 'Delete Retention Invoice Details ');
		END IF;

		DELETE FROM pa_retn_invoice_details
		      WHERE project_id = p_project_id
		        AND draft_invoice_num = p_draft_invoice_num;

	-- Call to delete the mc records
		IF g1_debug_mode  = 'Y' THEN
			pa_retention_util.write_log('Invoice_Delete_Action: ' || 'Delete MRC Retention Invoice Details ');
		END IF;
	     PA_MC_RETN_INV_DETAIL_PKG.Process_RetnInvDetails(
                                       p_project_id=>p_project_id,
                                       p_draft_invoice_num=>p_draft_invoice_num,
                                       p_action=>'DELETE',
                                       p_request_id=>p_request_id);


    END IF;

 x_return_status :=FND_API.G_RET_STS_SUCCESS;

EXCEPTION
WHEN OTHERS THEN
      x_return_status := 'E';
IF g1_debug_mode  = 'Y' THEN
	pa_retention_util.write_log('Invoice_Delete_Action: ' || 'Oracle Error ' || sqlerrm);
END IF;
      RAISE;

END Invoice_Delete_Action;

/* Added for bug 2770738 */
/* Renamed the procedure from invoice_write_off to update_credit_retn_balances for Bug3525910 */
PROCEDURE update_credit_retn_balances(p_request_id          IN NUMBER,
                            p_invoice_type                  IN VARCHAR2,
                            p_credit_action                 IN VARCHAR2, --Added this parameter for Bug3525910
                            p_project_id                    IN NUMBER,
                            p_draft_invoice_num             IN NUMBER,
                            x_return_status                 OUT NOCOPY VARCHAR2) IS --File.Sql.39 bug 4440895

BEGIN

     IF p_credit_action = 'WRITE_OFF' OR  p_credit_action = 'CONCESSION' THEN  --Added this IF condition for Bug3525910,
                                                                               --Added concession check for 4290823

	IF p_invoice_type ='PROJECT_INVOICE' THEN

		 FOR InvoiceLines IN (SELECT
					    dii. invproc_currency_code invproc_currency_code,
					    dii.amount amount, dii.projfunc_currency_code projfunc_currency_code,
					    dii.projfunc_bill_amount projfunc_bill_amount,
					    dii.project_currency_code project_currency_code,
					    dii.project_bill_amount project_bill_amount,
					    dii.funding_currency_code funding_currency_code,
					    dii.funding_bill_amount funding_bill_amount,
					    dii.task_id task_id,
					    dii.retention_rule_id retention_rule_id,
					    di.agreement_id agreement_id,
					   agr.customer_id customer_id,
				 	   rtn.task_id rtn_task_id
					 FROM pa_draft_invoice_items dii,
					      pa_draft_invoices_all di,
					      pa_agreements_all agr,
                                              pa_proj_retn_rules rtn
					WHERE di.project_id = p_project_id
					  AND di.draft_invoice_num = p_draft_invoice_num
					  AND di.agreement_id = agr.agreement_id
					  AND di.project_id = dii.project_id
					  AND di.draft_invoice_num = dii.draft_invoice_num
					  AND dii.invoice_line_type = 'RETENTION'
						-- # Fix for 2366314
					  AND dii.retention_rule_id = rtn.retention_rule_id
				          AND dii.retention_rule_id is not null) LOOP

 		Update_Retention_Balances(p_retention_rule_id =>InvoiceLines.Retention_rule_id     ,
                                        p_project_id =>p_project_id           ,
                                        p_task_id    =>InvoiceLines.rtn_Task_id,
                                        p_agreement_id =>InvoiceLines.agreement_id,
                                        p_customer_id  =>InvoiceLines.customer_id,
                        		p_amount       => (-1) * InvoiceLines.amount,
                                        p_change_type  => 'RETAINED' ,
                                        p_request_id   =>p_request_id,
                                        p_invproc_currency =>InvoiceLines.invproc_currency_code      ,
                                        p_project_currency =>InvoiceLines.project_currency_code,
                                        p_project_amount   => (-1) * InvoiceLines.project_bill_amount,
                                        p_projfunc_currency =>InvoiceLines.projfunc_currency_code,
                                        p_projfunc_amount   => (-1) * InvoiceLines.projfunc_bill_amount,
                                        p_funding_currency  => InvoiceLines.funding_currency_code   ,
                                        p_funding_amount    => (-1) * InvoiceLines.funding_bill_amount);

	         END LOOP;
	END IF;

     ELSIF p_credit_action = 'CONCESSION' THEN  --Added this condition for Bug3525910

        IF p_invoice_type ='RETENTION' THEN

                 FOR InvoiceLines IN (SELECT
                                            dii. invproc_currency_code invproc_currency_code,
                                            dii.amount amount, dii.projfunc_currency_code projfunc_currency_code,
                                            dii.projfunc_bill_amount projfunc_bill_amount,
                                            dii.project_currency_code project_currency_code,
                                            dii.project_bill_amount project_bill_amount,
                                            dii.funding_currency_code funding_currency_code,
                                            dii.funding_bill_amount funding_bill_amount,
                                            dii.task_id task_id,
                                            dii.retention_rule_id retention_rule_id,
                                            di.agreement_id agreement_id,
                                           agr.customer_id customer_id,
                                           dii.task_id dii_task_id
                                         FROM pa_draft_invoice_items dii,
                                              pa_draft_invoices_all di,
                                              pa_agreements_all agr
                                        WHERE di.project_id = p_project_id
                                          AND di.draft_invoice_num = p_draft_invoice_num
                                          AND di.agreement_id = agr.agreement_id
                                          AND di.project_id = dii.project_id
                                          AND di.draft_invoice_num = dii.draft_invoice_num
                                          AND dii.invoice_line_type = 'RETENTION') LOOP

                Update_Retention_Balances(p_retention_rule_id =>InvoiceLines.Retention_rule_id     ,
                                        p_project_id =>p_project_id           ,
                                        p_task_id    =>InvoiceLines.dii_Task_id,
                                        p_agreement_id =>InvoiceLines.agreement_id,
                                        p_customer_id  =>InvoiceLines.customer_id,
                                        p_amount       =>InvoiceLines.amount,
                                        p_change_type  => 'BILLED' ,
                                        p_request_id   =>p_request_id,
                                        p_invproc_currency =>InvoiceLines.invproc_currency_code      ,
                                        p_project_currency =>InvoiceLines.project_currency_code,
                                        p_project_amount   => InvoiceLines.project_bill_amount,
                                        p_projfunc_currency =>InvoiceLines.projfunc_currency_code,
                                        p_projfunc_amount   =>InvoiceLines.projfunc_bill_amount,
                                        p_funding_currency  =>InvoiceLines.funding_currency_code   ,
                                        p_funding_amount    =>InvoiceLines.funding_bill_amount);

                 END LOOP;
        END IF;

     END IF;

END update_credit_retn_balances;

-- Procedure added for bug 3889175
PROCEDURE Delete_Unused_Retention_Lines(
	P_Project_ID		IN NUMBER,
	P_Task_ID		IN NUMBER,
        X_Return_Status		OUT NOCOPY VARCHAR2)  --File.Sql.39 bug 4440895
IS
	l_Cust_Top_Task_Flag 		VARCHAR2(1);
	l_Inv_Method_Top_Task_Flag 	VARCHAR2(1);
BEGIN
	Select ENABLE_TOP_TASK_CUSTOMER_FLAG, ENABLE_TOP_TASK_INV_MTH_FLAG
	Into   l_Cust_Top_Task_Flag, l_Inv_Method_Top_Task_Flag
	From   PA_Projects_All
	Where  Project_ID = P_Project_ID;

	-- Dbms_Output.Put_Line('Flag value 1 : '|| l_Cust_Top_Task_Flag);
	-- Dbms_Output.Put_Line('Flag value 2 : '|| l_Inv_Method_Top_Task_Flag);

	If l_Cust_Top_Task_Flag = 'Y' OR l_Inv_Method_Top_Task_Flag = 'Y' Then
	  Delete From PA_Proj_Retn_Rules -- PA_Project_Retentions
	  Where  Project_ID = P_Project_ID
	  And    Task_ID    = P_Task_ID;
          X_Return_Status := FND_API.G_RET_STS_SUCCESS;
	End If;

EXCEPTION
	WHEN OTHERS THEN
      		x_return_status := 'E';
	IF g1_debug_mode  = 'Y' THEN
		pa_retention_util.write_log('Retention_Delete_Action: ' || 'Oracle Error ' || sqlerrm);
	END IF;
      	RAISE;

END Delete_Unused_Retention_Lines;

END pa_retention_pkg;

/

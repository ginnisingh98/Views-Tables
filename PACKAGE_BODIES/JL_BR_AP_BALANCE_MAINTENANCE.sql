--------------------------------------------------------
--  DDL for Package Body JL_BR_AP_BALANCE_MAINTENANCE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JL_BR_AP_BALANCE_MAINTENANCE" as
/* $Header: jlbrpbmb.pls 115.10 2002/09/23 14:21:19 kpvs ship $ */

/**************************************************************************
 *                                                                        *
 * Name       : JL_BR_MESSAGE	 		                  	  *
 * Purpose    : This procedure will put the message given in the log file *
 *              							  *
 *              			         			  *
 *                                                                        *
 **************************************************************************/

PROCEDURE jl_br_message( p_message_code   VARCHAR2,
		       p_token_1        VARCHAR2 DEFAULT NULL,
		       p_token_1_value  VARCHAR2 DEFAULT NULL,
		       p_token_2        VARCHAR2 DEFAULT NULL,
		       p_token_2_value  VARCHAR2 DEFAULT NULL,
		       p_token_3        VARCHAR2 DEFAULT NULL,
		       p_token_3_value  VARCHAR2 DEFAULT NULL,
		       p_token_4        VARCHAR2 DEFAULT NULL,
		       p_token_4_value  VARCHAR2 DEFAULT NULL
		       ) IS
BEGIN

      FND_MESSAGE.SET_NAME('JL',p_message_code);
      IF p_token_1 IS NOT NULL THEN
	 fnd_message.set_token(p_token_1, p_token_1_value);
      END IF;

      IF p_token_2 IS NOT NULL THEN
	 fnd_message.set_token(p_token_2, p_token_2_value);
      END IF;

      IF p_token_3 IS NOT NULL THEN
	 fnd_message.set_token(p_token_3, p_token_3_value);
      END IF;

      IF p_token_4 IS NOT NULL THEN
	 fnd_message.set_token(p_token_4, p_token_4_value);
      END IF;

	fnd_file.put_line(fnd_file.Log,fnd_message.get);


END jl_br_message;


/*----------------------------------------------------------------------------*
 |   PUBLIC FUNCTIONS/PROCEDURES                                              |
 *----------------------------------------------------------------------------*/

/*----------------------------------------------------------------------------*
 | PROCEDURE                                                                  |
 |    JL_BR_AP_BAL_MAINTENANCE                                                |
 |                                                                            |
 | DESCRIPTION                                                                |
 | XLA process calls this routine several times depending on a commit cycle   |
 |  which basically for each iteration has a different start date and end date|
 |  GL transfer run id and request id remains the same for the entire commit  |
 |  cycle.								      |
 |  SOB cycle creates a different GL transfer run ID.			      |
 |  COMMIT OR ROLLBACK control is in xla package.                             |
 | XLA process transactions in two cycles, the outer is for different SOBs    |
 |  and the inner cycle is for different range of dates.                      |
 |                                                                            |
 |  Note: This process is considered for Accrual Basis Method and only        |
 |  accounts for Liability and Gain and Loss lines.                           |
 |  Changes must be made for some other case outside this scope.              |
 |                                                                            |
 | PARAMETERS                                                                 |
 |   INPUT      							      |
 |  p_request_id contains the concurrent program request id                   |
 |  p_transfer_run_id contains the Transfer Run ID for a batch                |
 |  p_start_date contains the start date of current commit cycle iteration.   |
 |  p_end_date contains the end date of current commit cycle iteration.       |
 |                                                                            |
 |                                                                            |
 |   OUTPUT                                                                   |
 |                                                                            |
 |                                                                            |
 | HISTORY                                                                    |
 |    11-AUG-99    Rafael Guerrero    Created.                                |
 *----------------------------------------------------------------------------*/

/*----------------------------------------------------------------------------*/
/*<<<<<            JL_BR_AP_BAL_MAINTENANCE                              >>>>>*/
/*----------------------------------------------------------------------------*/

PROCEDURE	JL_BR_AP_BAL_MAINTENANCE (p_request_id 		NUMBER,
					  p_transfer_run_id 	NUMBER,
					  p_start_date 		DATE,
					  p_end_date   		DATE)
IS

    l_user_id		    NUMBER;
    l_curr_calling_sequence VARCHAR2(240);
    l_debug_info            VARCHAR2(1000);
    l_parameters            VARCHAR2(1000);

	cursor c_bmb 		is
	-- Extract Liability credit lines
	Select /*+ ORDERED */
	aeh.set_of_books_id sob,
	aeh.period_name per,
	gp.period_year pyear,
	gp.period_num pnum,
	gs.period_set_name perset,
	ael.code_combination_id ccid,
	ael.third_party_id ven,
	ael.third_party_sub_id site,
        ael.currency_code cur,
	aeh.accounting_date accd,
	ai.invoice_num num,
	ael.source_id invid, -- invoice_id
	ai.invoice_date idat,
	'Entrada/Estorno Docto' hist,
	ael.ae_line_id inst,
	decode(nvl(ael.accounted_Cr,0),0,decode(nvl(ael.entered_Cr,0),0,'D','C'),'C') isign,
	decode(nvl(ael.accounted_Cr,0),0,decode(nvl(ael.entered_Cr,0),0,decode(nvl(ael.accounted_Dr,0),0,ael.entered_Dr,ael.accounted_Dr),ael.entered_Cr),ael.accounted_Cr) ival,
	ab.batch_name bat,
	ab.batch_id batid,
        ai.org_id
	From ap_ae_headers aeh,
         ap_ae_lines ael,
         ap_invoices ai,
         gl_periods  gp,
         gl_sets_of_books  gs,
         ap_batches  ab
	Where
	-- Validate Data Conditions
	aeh.ae_category = 'Purchase Invoices'
	and aeh.gl_transfer_Run_id = p_transfer_run_id -- create journals entries for those invoices being transfered.
	and aeh.accounting_date between p_start_date and p_end_date
	and ael.ae_line_type_code ='LIABILITY'
	-- Join Conditions
	and  aeh.ae_header_id = ael.ae_header_id
	and  ael.source_id = ai.invoice_id
	and  aeh.set_of_books_id	= gs.set_of_books_id
	and  gs.period_set_name	       = gp.period_set_name
	and  gp.period_name	       = aeh.period_name
	and  ai.batch_id   =  ab.batch_id(+)
	UNION ALL
	-- Extract Liability debit lines
	Select /*+ ORDERED */
	aeh.set_of_books_id sob,
	aeh.period_name per,
	gp.period_year pyear,
	gp.period_num pnum,
	gs.period_set_name perset,
	ael.code_combination_id ccid,
	ael.third_party_id ven,
	ael.third_party_sub_id site,
        ael.currency_code cur,
	aeh.accounting_date accd,
	ai.invoice_num num,
	ael.source_id invid,
	ai.invoice_date idat,
	'Pagto/Estorno Docto' hist,
	ael.ae_line_id inst,
	decode(nvl(accounted_Cr,0),0,decode(nvl(entered_Cr,0),0,'D','C'),'C') isign,
	decode(nvl(accounted_Cr,0),0,decode(nvl(entered_Cr,0),0,decode(nvl(accounted_Dr,0),0,entered_Dr,accounted_Dr),entered_Cr),accounted_Cr) ival,
	ac.checkrun_name bat,
	0 batid,
	ai.org_id
	From ap_ae_headers aeh,
         ap_ae_lines ael,
         ap_invoice_payments aip,
         ap_invoices ai,
         ap_checks ac,
         gl_periods  gp,
         gl_sets_of_books  gs
	WHERE
	-- Validate Data Conditions
	aeh.ae_category = 'Payments'
	and aeh.gl_transfer_Run_id = p_transfer_run_id -- create journals entries for those invoices being transfered.
	and aeh.accounting_date between p_start_date and p_end_date
	and ael.ae_line_type_code in ('LIABILITY','GAIN','LOSS') -- gain and loss are related to payment
	and  ( nvl(ac.payment_method_lookup_code, 'OLD') not in ('FUTURE DATED', 'MANUAL FUTURE DATED')
        	OR ( nvl(ac.payment_method_lookup_code, 'OLD') in ('FUTURE DATED', 'MANUAL FUTURE DATED')
	      		AND nvl(aip.future_pay_posted_flag, 'N') = 'N') )
	-- Join Conditons
	and aeh.ae_header_id = ael.ae_header_id
	and ael.source_id = aip.invoice_payment_id
	and aip.invoice_id = ai.invoice_id
	and aip.check_id = ac.check_id
	and aeh.set_of_books_id	= gs.set_of_books_id
	and gs.period_set_name	= gp.period_set_name
	and gp.period_name	= aeh.period_name;

BEGIN
-- fix for bug # 2587958
if fnd_profile.value('JGZZ_PRODUCT_CODE') <> 'JL' or  fnd_profile.value('JGZZ_COUNTRY_CODE') <> 'BR' then
    return;
end if;

    l_curr_calling_sequence:='JL_BR_AP_BALANCE_MAINTENANCE.jl_br_ap_bal_maintenance';
    l_parameters:=' p_request_id =' || to_char(p_request_id) || ' p_transfer_run_id= ' || TO_CHAR(p_transfer_run_id) ||
	  	  ' p_start_date= ' || TO_CHAR(p_start_date) || ' p_end_date= ' || TO_CHAR(p_end_date);

    jl_br_message('JL_BR_ZZ_CREATE_JOURNALS');
    l_user_id    := FND_GLOBAL.user_id;
    l_debug_info:='Inserting records into jl_br_journals table...';

    FOR r_bmb in c_bmb LOOP

	   INSERT INTO JL_BR_JOURNALS (
	   APPLICATION_ID ,
	   SET_OF_BOOKS_ID ,
	   PERIOD_SET_NAME ,
	   PERIOD_NAME ,
	   CODE_COMBINATION_ID ,
	   PERSONNEL_ID ,
	   TRANS_CURRENCY_CODE ,
	   BATCH_ID ,
	   BATCH_NAME ,
	   ACCOUNTING_DATE ,
	   TRANS_ID ,
	   TRANS_NUM ,
	   TRANS_DATE ,
	   TRANS_DESCRIPTION ,
	   INSTALLMENT ,
	   TRANS_VALUE_SIGN ,
	   TRANS_VALUE ,
  	   JOURNAL_BALANCE_FLAG,
	   LAST_UPDATE_DATE ,
	   LAST_UPDATED_BY ,
	   LAST_UPDATE_LOGIN ,
	   CREATION_DATE ,
	   CREATED_BY,
	   ORG_ID )
	  VALUES       (
            	200,
		r_bmb.sob,
		r_bmb.perset,
		r_bmb.per,
		r_bmb.ccid,
		r_bmb.ven,
                r_bmb.cur,
		r_bmb.batid,
		r_bmb.bat,
                r_bmb.accd,
		r_bmb.invid,
		r_bmb.num,
		r_bmb.idat,
		r_bmb.hist,
		r_bmb.inst,
                r_bmb.isign,
		r_bmb.ival,
		'N',
		sysdate,
		l_user_id,
		'',
		sysdate,
		l_user_id,
		r_bmb.org_id);

    END LOOP;

	EXCEPTION
	WHEN OTHERS THEN
	  jl_br_message('JL_ZZ_AP_DEBUG','ERROR',SQLERRM,'CALLING_SEQUENCE',l_curr_calling_sequence,
			'PARAMETERS', l_parameters,'DEBUG_INFO',l_debug_info);
	  APP_EXCEPTION.RAISE_EXCEPTION;

END JL_BR_AP_BAL_MAINTENANCE;

END JL_BR_AP_BALANCE_MAINTENANCE;

/

--------------------------------------------------------
--  DDL for Package Body PA_MC_RETN_INV_DETAIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_MC_RETN_INV_DETAIL_PKG" as
/* $Header: PAMCRIDB.pls 120.2 2005/08/26 11:28:39 skannoji noship $*/
g1_debug_mode varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

PROCEDURE Process_RetnInvDetails(p_project_id 		IN NUMBER,
			         p_draft_invoice_num	IN NUMBER,
				 p_action		IN VARCHAR2,
				 p_request_id		IN NUMBER) IS


 /* R12 :  Ledger Architecture Changes : The table gl_mc_reporting_options will be  obsolete, replace with
     new table gl_alc_ledger_rships_v and corresponding columns */

 /* CURSOR c_reporting_sob ( p_set_of_books_id IN NUMBER, in_org_id IN NUMBER) IS
    SELECT reporting_set_of_books_id,
	   reporting_currency_code,
	   conversion_type
    FROM   gl_mc_reporting_options
    WHERE  primary_set_of_books_id = p_set_of_books_id
    AND    application_id = 275
    AND    org_id = NVL(in_org_id,-99)
    AND    enabled_flag = 'Y';  */


    CURSOR c_reporting_sob ( p_set_of_books_id IN NUMBER, in_org_id IN NUMBER) IS
    SELECT ledger_id  reporting_set_of_books_id,
           currency_code reporting_currency_code,
           alc_default_conv_rate_type conversion_type
    FROM   gl_alc_ledger_rships_v
    WHERE  source_ledger_id = p_set_of_books_id
    AND    application_id = 275
    AND    (org_id = -99  OR  org_id = in_org_id)
    AND    relationship_enabled_flag  = 'Y';


    currency               VARCHAR2(30);
    sob                    NUMBER;
    l_org_id		   NUMBER;
    l_program_id                  NUMBER:= fnd_global.conc_program_id;
    l_program_application_id      NUMBER:= fnd_global.prog_appl_id;
    l_program_update_date         DATE  := sysdate;
    l_last_update_date            DATE  := sysdate;
    l_last_updated_by             NUMBER:= fnd_global.user_id;
    l_created_by                 NUMBER:= fnd_global.user_id;
    l_last_update_login           NUMBER:= fnd_global.login_id;
    l_invoice_date		  DATE;


BEGIN
IF g1_debug_mode  = 'Y' THEN
	pa_retention_util.write_log('Entering pa_mc_retn_inv_detail_pkg.Process_RetnInvDetails');
END IF;

 IF NOT gl_mc_currency_pkg.G_PA_UPGRADE_MODE THEN

	IF p_action ='INSERT' THEN /* Inserting new record  */

-- pa_retention_util.write_log('Leaving pa_mc_retn_inv_detail_pkg.Process_RetnInvDetails');

			SELECT p.org_id, p.projfunc_currency_code  ,
			      imp.set_of_books_id sob,
			      di.invoice_date invoice_date
	 		  INTO l_org_id, currency, sob, l_invoice_date
	 		  FROM pa_projects_all p, pa_implementations imp,
			       pa_draft_invoices_all di
	                 WHERE  di.project_id = p.project_id
			   AND  di.draft_invoice_num = p_draft_invoice_num
			   AND  p.project_id = p_project_id
 /* Shared services changes: removed NVL from the org_id join.*/
                           AND  imp.org_id = p.org_id;

    	FOR v_rsob IN c_reporting_sob( sob,l_org_id) LOOP

       		DECLARE

			l_temp_val                NUMBER := 0;
          		l_err_code                NUMBER := 0;
          		x_err_stack               VARCHAR2(2000);
          		x_err_code                NUMBER := 0;
          		x_err_stage               VARCHAR2(2000);
          		l_result_code             VARCHAR2(15);
          		l_exchange_rate           NUMBER :=0;
          		l_x_exchange_rate         NUMBER :=0;
          		l_denominator_rate        NUMBER;
          		l_numerator_rate          NUMBER;
          		l_exchange_rate_date           DATE;
          		l_exchange_rate_type      VARCHAR2(30);
          		l_report_amount          NUMBER := 0;


			BEGIN

			 l_exchange_rate_date     := l_invoice_date;
			 l_exchange_rate_type := v_rsob.conversion_type;

  		IF g1_debug_mode  = 'Y' THEN
  			pa_retention_util.write_log('Process_RetnInvDetails: ' || 'Primary SOB        : ' || sob );
         		pa_retention_util.write_log('Process_RetnInvDetails: ' || 'Reporting SOB      : ' || v_rsob.reporting_set_of_books_id );
         		pa_retention_util.write_log('Process_RetnInvDetails: ' || 'Completion date    : ' || to_char(l_invoice_date) );
         		pa_retention_util.write_log('Process_RetnInvDetails: ' || 'Org Id             : ' || l_org_id);
         		pa_retention_util.write_log('Process_RetnInvDetails: ' || 'Projfunc Currency: ' || currency );
         		pa_retention_util.write_log('Process_RetnInvDetails: ' || 'Exchange rate Type : ' ||l_exchange_rate_type );
         		pa_retention_util.write_log('Process_RetnInvDetails: ' || 'Exchange rate      : ' ||l_exchange_rate );
         		pa_retention_util.write_log('Process_RetnInvDetails: ' || 'Exchange date      : ' ||to_char(l_exchange_rate_date));
         	END IF;



	  			gl_mc_currency_pkg.get_rate(p_primary_set_of_books_id     => sob,
                                      p_reporting_set_of_books_id   => v_rsob.reporting_set_of_books_id,
                                      p_trans_date                  => l_invoice_date,
                                      p_trans_currency_code         => currency,
                                      p_trans_conversion_type       => l_exchange_rate_type,
                                      p_trans_conversion_date       => l_exchange_rate_date,
                                      p_trans_conversion_rate       => l_exchange_rate,
                                      p_application_id              => 275,
                                      p_org_id                      => l_org_id,
                                      p_fa_book_type_code           => NULL,
                                      p_je_source_name              => NULL,
                                      p_je_category_name            => NULL,
                                      p_result_code                 => l_result_code,
                                      p_denominator_rate            => l_denominator_rate,
                                      p_numerator_rate              => l_numerator_rate);

         	IF g1_debug_mode  = 'Y' THEN
         		pa_retention_util.write_log('Process_RetnInvDetails: ' || 'After the Rate API ');
         		pa_retention_util.write_log('Process_RetnInvDetails: ' || 'Exchange rate Type : ' ||l_exchange_rate_type );
         		pa_retention_util.write_log('Process_RetnInvDetails: ' || 'Exchange rate      : ' ||l_exchange_rate );
         		pa_retention_util.write_log('Process_RetnInvDetails: ' || 'Exchange date      : ' ||to_char(l_exchange_rate_date));
         		pa_retention_util.write_log('Process_RetnInvDetails: ' || 'p_draft_invoice_num : '|| p_draft_invoice_num);
         	END IF;

			FOR InvDetRec IN (SELECT
					    retn_invoice_detail_id,
					    project_id,
					    draft_invoice_num,
					    line_num,
					    projfunc_currency_code,
					    projfunc_total_retained
					  FROM pa_retn_invoice_details
					  WHERE project_id =  p_project_id
					    AND draft_invoice_num = p_draft_invoice_num)
			LOOP

          			l_report_amount := 0;

				l_report_amount := pa_mc_currency_pkg.CurrRound((
					(InvDetRec.projfunc_total_retained/ l_denominator_rate)*
                                  	 l_numerator_rate),v_rsob.reporting_currency_code);

         	IF g1_debug_mode  = 'Y' THEN
         		pa_retention_util.write_log('Process_RetnInvDetails: ' || 'Before inserting into pa_mc_retn_inv_details');
       		pa_retention_util.write_log('Process_RetnInvDetails: ' || '------------------------------');
       	END IF;

	/* Bug 2976939: Added set_of_books_id check in the select below.Since this check was not there
	only for one RSOB record will be inserted. */

				BEGIN
                                    NULL;
				   END;
         	IF g1_debug_mode  = 'Y' THEN
         		pa_retention_util.write_log('Process_RetnInvDetails: ' || 'After inserting into pa_mc_retn_inv_details');
         	END IF;

     				END LOOP;  -- End of invoice loop

   			END;

		END LOOP;  -- End of Reporting set of books

	  ELSIF p_action='DELETE' THEN

		IF g1_debug_mode  = 'Y' THEN
			pa_retention_util.write_log('Process_RetnInvDetails: ' || 'Delete Invoice Details');
		END IF;
	END IF;

	END IF; /* Not MRC Upgrade */
IF g1_debug_mode  = 'Y' THEN
	pa_retention_util.write_log('Leaving pa_mc_retn_inv_detail_pkg.Process_RetnInvDetails');
END IF;

END Process_RetnInvDetails;

END PA_MC_RETN_INV_DETAIL_PKG;

/

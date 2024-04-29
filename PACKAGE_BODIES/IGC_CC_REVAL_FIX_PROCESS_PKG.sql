--------------------------------------------------------
--  DDL for Package Body IGC_CC_REVAL_FIX_PROCESS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGC_CC_REVAL_FIX_PROCESS_PKG" AS
/*$Header: IGCCREFB.pls 120.16.12010000.2 2008/08/29 13:14:52 schakkin ship $*/

  --Bug 3199488 Start Block
    l_debug_level number:=FND_LOG.G_CURRENT_RUNTIME_LEVEL;

    l_state_level number:=FND_LOG.LEVEL_STATEMENT;
    l_proc_level number:=FND_LOG.LEVEL_PROCEDURE;
    l_event_level number:=FND_LOG.LEVEL_EVENT;
    l_excep_level number:=FND_LOG.LEVEL_EXCEPTION;
    l_error_level number:=FND_LOG.LEVEL_ERROR;
    l_unexp_level number:=FND_LOG.LEVEL_UNEXPECTED;
  --Bug 3199488 End Block

  G_PKG_NAME CONSTANT VARCHAR2(30):= 'IGC_CC_REVAL_FIX_PROCESS_PKG';

  -- The flag determines whether to print debug information or not.
  l_debug_mode        VARCHAR2(1) := NVL(FND_PROFILE.VALUE('IGC_DEBUG_ENABLED'),'N');
  --g_debug_flag        VARCHAR2(1) := 'N' ;
  g_debug_msg         VARCHAR2(10000) := NULL;

--
-- Generic Procedure for putting out NOCOPY debug information
--
/* commented out as per bug 3299548
PROCEDURE Output_Debug (
   p_debug_msg        IN VARCHAR2
);
*/

/* Checks whether contract commitment is eligible for revalution fix*/
FUNCTION revalue_fix
(
  p_cc_header_id                        IN       NUMBER
) RETURN BOOLEAN
IS
	l_cc_headers_rec                igc_cc_headers%ROWTYPE;
	l_cc_acct_lines_rec             igc_cc_acct_lines_v%ROWTYPE;
	l_cc_pmt_fcst_rec               igc_cc_det_pf_v%ROWTYPE;

	/* Contract Commitment detail payment forecast  */
	CURSOR c_payment_forecast(t_cc_acct_line_id NUMBER) IS
        -- Performance Tuning, replaced the view igc_cc_det_pf_v
        -- with igc_cc_det_pf
	-- SELECT *
	-- FROM igc_cc_det_pf_v
	-- WHERE cc_acct_line_id =  t_cc_acct_line_id;

        SELECT ccdpf.ROWID,
               ccdpf.cc_det_pf_line_id,
               ccdpf.cc_det_pf_line_num,
               NULL  cc_acct_line_num,
               ccdpf.cc_acct_line_id,
               NULL  parent_det_pf_line_num,
               ccdpf.parent_det_pf_line_id,
               ccdpf.Parent_acct_line_id,
               ccdpf.cc_det_pf_entered_amt,
               ccdpf.cc_det_pf_func_amt,
               ccdpf.cc_det_pf_date,
               IGC_CC_COMP_AMT_PKG.COMPUTE_PF_BILLED_AMT(ccdpf.cc_det_pf_line_id,  ccdpf.cc_det_pf_line_num, ccdpf.cc_acct_line_id) cc_det_pf_billed_amt,
               IGC_CC_COMP_AMT_PKG.COMPUTE_PF_FUNC_BILLED_AMT(ccdpf.cc_det_pf_line_id,  ccdpf.cc_det_pf_line_num, ccdpf.cc_acct_line_id) cc_det_pf_func_billed_amt,
               ccdpf.cc_det_pf_unbilled_amt,
               IGC_CC_COMP_AMT_PKG.COMPUTE_FUNCTIONAL_AMT(p_cc_header_id,NVL(ccdpf.cc_det_pf_entered_amt,0)) cc_det_pf_comp_func_amt,
               ccdpf.cc_det_pf_encmbrnc_amt,
               ( IGC_CC_COMP_AMT_PKG.COMPUTE_FUNCTIONAL_AMT ( p_cc_header_id,  NVL(ccdpf.cc_det_pf_entered_amt,0) ) - NVL(ccdpf.cc_det_pf_encmbrnc_amt,0) )  cc_det_pf_unencmbrd_amt ,
               ccdpf.cc_det_pf_encmbrnc_date,
               ccdpf.cc_det_pf_encmbrnc_status,
               ccdpf.context,
               ccdpf.attribute1,
               ccdpf.attribute2,
               ccdpf.attribute3,
               ccdpf.attribute4,
               ccdpf.attribute5,
               ccdpf.attribute6,
               ccdpf.attribute7,
               ccdpf.attribute8,
               ccdpf.attribute9,
               ccdpf.attribute10,
               ccdpf.attribute11,
               ccdpf.attribute12,
               ccdpf.attribute13,
               ccdpf.attribute14,
               ccdpf.attribute15,
               ccdpf.last_update_date,
               ccdpf.last_updated_by,
               ccdpf.last_update_login,
               ccdpf.creation_date,
               ccdpf.created_by
        FROM igc_cc_det_pf ccdpf
	WHERE cc_acct_line_id =  t_cc_acct_line_id;


	/* Contract Commitment account lines  */

	CURSOR c_account_lines(t_cc_header_id NUMBER) IS
	-- Replaced the folllowing query with the one below for
	-- performance tuning fixes.
	-- The record definition of l_cc_acct_lines_rec is still based on
	-- view igc_cc_acct_lines_v. Instead of selecting from the view,
	-- select is being done from the base table, but all the columns
	-- as defined in the view are retained even though they are not used.
	-- This is just so that minimal change is made to the code.
	/*
	SELECT *
        FROM  igc_cc_acct_lines_v ccac
        WHERE ccac.cc_header_id = t_cc_header_id;
	*/

	SELECT ccal.ROWID,
	       ccal.cc_header_id,
	       NULL org_id,
	       NULL cc_type,
	       NULL cc_type_code,
	       NULL cc_num,
	       ccal.cc_acct_line_id,
	       ccal.cc_acct_line_num,
	       ccal.cc_acct_desc,
	       ccal.parent_header_id,
	       ccal.parent_acct_line_id,
	       NULL parent_cc_acct_line_num,
	       NULL cc_budget_acct_desc,
	       ccal.cc_budget_code_combination_id,
	       NULL cc_charge_acct_desc,
	       ccal.cc_charge_code_combination_id,
	       ccal.cc_acct_entered_amt,
	       ccal.cc_acct_func_amt,
	       IGC_CC_COMP_AMT_PKG.COMPUTE_ACCT_BILLED_AMT( ccal.cc_acct_line_id) cc_acct_billed_amt,
	       IGC_CC_COMP_AMT_PKG.COMPUTE_ACCT_FUNC_BILLED_AMT( ccal.cc_acct_line_id) cc_acct_func_billed_amt,
	       ccal.cc_acct_encmbrnc_amt,
	       ( IGC_CC_COMP_AMT_PKG.COMPUTE_FUNCTIONAL_AMT ( ccal.cc_header_id, NVL(ccal.cc_acct_entered_amt,0) ) -  NVL(ccal.cc_acct_encmbrnc_amt,0) ) cc_acct_unencmrd_amt,
	       ccal.cc_acct_unbilled_amt,
	       IGC_CC_COMP_AMT_PKG.COMPUTE_FUNCTIONAL_AMT(ccal.cc_header_id, NVL(ccal.cc_acct_entered_amt,0)) cc_acct_comp_func_amt,
	       NULL project_number ,
	       ccal.project_id,
	       NULL task_number,
	       ccal.task_id,
	       ccal.expenditure_type,
	       NULL expenditure_org_name,
	       ccal.expenditure_org_id,
	       ccal.expenditure_item_date,
	       ccal.cc_acct_taxable_flag,
	       NULL tax_name,
	       NULL tax_id, --  Added for Bug 6472296 r12 EBtax uptake for CC
	       ccal.cc_acct_encmbrnc_status,
	       ccal.cc_acct_encmbrnc_date,
	       ccal.context,
	       ccal.attribute1,
	       ccal.attribute2,
	       ccal.attribute3,
	       ccal.attribute4,
	       ccal.attribute5,
	       ccal.attribute6,
	       ccal.attribute7,
	       ccal.attribute8,
	       ccal.attribute9,
	       ccal.attribute10,
	       ccal.attribute11,
	       ccal.attribute12,
	       ccal.attribute13,
	       ccal.attribute14,
	       ccal.attribute15,
	       ccal.created_by,
	       ccal.creation_date,
	       ccal.last_updated_by,
	       ccal.last_update_date,
	       ccal.last_update_login,
	       ccal.cc_func_withheld_amt,
	       ccal.cc_ent_withheld_amt,
	       IGC_CC_COMP_AMT_PKG.COMPUTE_FUNCTIONAL_AMT(ccal.cc_header_id,
	       NVL(ccal.cc_func_withheld_amt,0)) cc_comp_func_whld_amt,
              ccal.TAX_CLASSIF_CODE  /*  Bug 6472296 for r12 EBtax uptake for CC */
	FROM igc_cc_acct_lines ccal
        WHERE ccal.cc_header_id = t_cc_header_id;

	reval_fix BOOLEAN := FALSE;

BEGIN

	reval_fix := FALSE;

	SELECT *
        INTO l_cc_headers_rec
	FROM igc_cc_headers
        WHERE cc_header_id = p_cc_header_id;

	OPEN c_account_lines(p_cc_header_id);

	LOOP
		FETCH c_account_lines INTO l_cc_acct_lines_rec;

		EXIT WHEN c_account_lines%NOTFOUND;

		OPEN c_payment_forecast(l_cc_acct_lines_rec.cc_acct_line_id);

		LOOP
			FETCH c_payment_forecast INTO l_cc_pmt_fcst_rec;

			EXIT WHEN c_payment_forecast%NOTFOUND;

			IF
                           (
                             ROUND((l_cc_pmt_fcst_rec.cc_det_pf_entered_amt - l_cc_pmt_fcst_rec.cc_det_pf_billed_amt)
                             *
                             l_cc_headers_rec.conversion_rate,2)
                            )
                           <>
                             (ROUND(l_cc_pmt_fcst_rec.cc_det_pf_func_amt,2) - ROUND(l_cc_pmt_fcst_rec.cc_det_pf_func_billed_amt,2))
			THEN
				RETURN(TRUE);

			END IF;


		END LOOP;

		CLOSE c_payment_forecast;

	END LOOP;

	CLOSE c_account_lines;

	RETURN(reval_fix);

END revalue_fix;

/* Commented out as per bug 3299548
--
-- Output_Debug Procedure is the Generic procedure designed for outputting debug
-- information that is required from this procedure.
--
-- Parameters :
--
-- p_debug_msg ==> Record to be output into the debug log file.
--
PROCEDURE Output_Debug (
   p_debug_msg      IN VARCHAR2
) IS

-- Constants :

   l_prod             VARCHAR2(3)           := 'IGC';
   l_sub_comp         VARCHAR2(6)           := 'CC_RVF';
   l_profile_name     VARCHAR2(255)         := 'IGC_DEBUG_LOG_DIRECTORY';
   l_Return_Status    VARCHAR2(1);
   l_api_name         CONSTANT VARCHAR2(30) := 'Output_Debug';

BEGIN

   IGC_MSGS_PKG.Put_Debug_Msg (p_debug_message    => p_debug_msg,
                               p_profile_log_name => l_profile_name,
                               p_prod             => l_prod,
                               p_sub_comp         => l_sub_comp,
                               p_filename_val     => NULL,
                               x_Return_Status    => l_Return_Status
                              );

   IF (l_Return_Status <> FND_API.G_RET_STS_SUCCESS) THEN
      raise FND_API.G_EXC_ERROR;
   END IF;

   RETURN;

-- --------------------------------------------------------------------
-- Exception handler section for the Output_Debug procedure.
-- --------------------------------------------------------------------
EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
       RETURN;

   WHEN OTHERS THEN
       IF (FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
          FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
       END IF;
       RETURN;

END Output_Debug;

*/

/* Checks whether all the invoices related to
Contract Commitment are either approved or cancelled */

FUNCTION validate_params(p_process_phase      IN VARCHAR2,
			 p_sob_id             IN NUMBER,
			 p_org_id             IN NUMBER,
                         p_cc_header_id       IN NUMBER,
                         p_revalue_fix_date   IN DATE,
                         p_request_id         IN NUMBER)
RETURN BOOLEAN
IS
	l_period_status gl_period_statuses.closing_status%TYPE;
	l_cc_period_status igc_cc_periods.cc_period_status%TYPE;
	l_rate  NUMBER;
	l_message igc_cc_process_exceptions.exception_reason%TYPE;
	l_cc_num  igc_cc_headers.cc_num%TYPE;
BEGIN

        BEGIN

           SELECT cc_num
	     INTO l_cc_num
	     FROM igc_cc_headers
	    WHERE cc_header_id = p_cc_header_id;

        EXCEPTION
           WHEN OTHERS THEN
              IF (FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
                  FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, 'Validate_Params');
              END IF;

              -- bug 3199488, start block
              IF (l_unexp_level >= l_debug_level) THEN
                  FND_MESSAGE.SET_NAME('IGC','IGC_LOGGING_UNEXP_ERROR');
                  FND_MESSAGE.SET_TOKEN('CODE',sqlcode);
                  FND_MESSAGE.SET_TOKEN('MSG',sqlerrm);
                  FND_LOG.MESSAGE(l_unexp_level, 'igc.plsql.igc_cc_reval_fix_process_pkg.validate_params.Unexp1',TRUE);
             END IF;
             -- bug 3199488, end block

              RETURN (FALSE);
        END;

	IF (p_process_phase = 'F')
	THEN

		IF (NOT revalue_fix(p_cc_header_id))
		THEN
			l_message := NULL;
			FND_MESSAGE.SET_NAME('IGC','IGC_CC_HAS_NO_REV_VARIANCES');
                	FND_MESSAGE.SET_TOKEN('CC_NUM', l_cc_num ,TRUE);
                	l_message  := FND_MESSAGE.GET;

			INSERT INTO
			igc_cc_process_exceptions
			(   process_type,
	 		    process_phase,
	 		    cc_header_id,
	 		    cc_acct_line_id,
	 		    cc_det_pf_line_id,
	 		    exception_reason,
	 		    org_id,
	 		    set_of_books_id,
                            request_id
                        )
                        VALUES
                        (
			    'F',
	 		    'F',
			    NULL,
			    NULL,
			    NULL,
			    l_message,
			    p_org_id,
			    p_sob_id,
                            p_request_id
                        );

			COMMIT;

			RETURN(FALSE);

		END IF;

		IF (p_revalue_fix_date IS NOT NULL)
                THEN

			/* Check whether GL period is open */

			BEGIN
				SELECT  gps.closing_status
				INTO    l_period_status
				FROM    gl_period_statuses gps,
				        gl_periods gp,
				        gl_sets_of_books gb,
				        gl_period_types gpt,
				        fnd_application fa
				WHERE
					gb.set_of_books_id        = p_sob_id AND
               				gp.period_set_name        = gb.period_set_name AND
					gp.period_type            = gb.accounted_period_type AND
                                        /* Begin fix for bug 1569324 */
                       		        gp.adjustment_period_flag  = 'N'                      AND
                                        /* End fix for bug 1569324 */
					gpt.period_type           = gp.period_type AND
					gps.set_of_books_id       = gb.set_of_books_id AND
					gps.period_name           = gp.period_name AND
					gps.application_id        = fa.application_id AND
				        fa.application_short_name = 'SQLGL' AND
					(gp.start_date <= p_revalue_fix_date AND gp.end_date >= p_revalue_fix_date);
			EXCEPTION
				WHEN NO_DATA_FOUND
				THEN
					NULL;

			END;
		END IF;

		IF (l_period_status IS NULL) OR ( NVL(l_period_status,'X') <> 'O') OR (p_revalue_fix_date IS NULL)
		THEN
			l_message := NULL;
			FND_MESSAGE.SET_NAME('IGC','IGC_CC_REV_VAR_FIX_DATE');
                        FND_MESSAGE.SET_TOKEN('DATE',to_char( p_revalue_fix_date,'DD-MON-YYYY') ,TRUE);
                        l_message  := FND_MESSAGE.GET;

			INSERT INTO
			igc_cc_process_exceptions
			(  process_type,
	 		   process_phase,
	 		   cc_header_id,
	 		   cc_acct_line_id,
	 		   cc_det_pf_line_id,
	 		   exception_reason,
	 		   org_id,
	 		   set_of_books_id,
                           request_id
                        )
                        VALUES
                        ( 'F',
	 		  'F',
		     	  NULL,
			  NULL,
			  NULL,
			  l_message,
			  p_org_id,
			  p_sob_id,
                          p_request_id
                        );

			COMMIT;

			RETURN(FALSE);
		END IF;

		/* Check whether CC period is open */
		BEGIN
        		SELECT ccp.cc_period_status
			INTO   l_cc_period_status
          		FROM   igc_cc_periods   ccp,
               		       gl_periods       gp ,
		       	       gl_sets_of_books gb
          		WHERE
                       		ccp.period_set_name        = gp.period_set_name       AND
                       		gp.period_set_name         = gb.period_set_name       AND
                       		ccp.org_id                 = p_org_id                 AND
                       		ccp.period_name            = gp.period_name           AND
		       		gp.period_type             = gb.accounted_period_type AND
                       		gp.adjustment_period_flag  = 'N'                      AND
				gb.set_of_books_id         = p_sob_id                 AND
		       		(gp.start_date <= p_revalue_fix_date AND gp.end_date >= p_revalue_fix_date);
		EXCEPTION
			WHEN NO_DATA_FOUND
			THEN
				RETURN(FALSE);
		END;

		IF (l_cc_period_status IS NULL) OR (NVL(l_cc_period_status,'X') <> 'O')
		THEN
			l_message := NULL;
			FND_MESSAGE.SET_NAME('IGC','IGC_CC_REV_VAR_FIX_DATE');
                        FND_MESSAGE.SET_TOKEN('DATE',to_char( p_revalue_fix_date,'DD-MON-YYYY') ,TRUE);
                        l_message  := FND_MESSAGE.GET;

			INSERT INTO
			igc_cc_process_exceptions
			(  process_type,
	 		   process_phase,
	 		   cc_header_id,
	 		   cc_acct_line_id,
	 		   cc_det_pf_line_id,
	 		   exception_reason,
	 		   org_id,
	 		   set_of_books_id,
                           request_id
                        )
                        VALUES
                        (  'F',
	 		   'F',
			   NULL,
			   NULL,
			   NULL,
			   l_message,
			   p_org_id,
			   p_sob_id,
                           p_request_id
                        );

			COMMIT;

			RETURN(FALSE);
		END IF;

	END IF;

	RETURN(TRUE);

END validate_params;

FUNCTION lock_cc_po(p_sob_id       IN NUMBER,
		    p_org_id       IN NUMBER,
                    p_cc_header_id IN NUMBER,
                    p_request_id   IN NUMBER)
RETURN BOOLEAN
IS
	l_lock_cc  BOOLEAN := TRUE;
	l_lock_po  BOOLEAN := TRUE;
	l_message  igc_cc_process_exceptions.exception_reason%TYPE;
	l_cc_num   igc_cc_headers.cc_num%TYPE;
BEGIN

	SELECT cc_num
	INTO   l_cc_num
	FROM   igc_cc_headers
	WHERE  cc_header_id = p_cc_header_id;

	l_lock_cc := TRUE;
	l_lock_po := TRUE;

	/* Lock all contract commitment being re-valued */
	l_lock_cc := IGC_CC_REP_YEP_PVT.lock_cc(p_cc_header_id);

	IF (NOT l_lock_cc)
	THEN

		l_message := NULL;
		FND_MESSAGE.SET_NAME('IGC','IGC_CC_LOCK_FAILURE');
                FND_MESSAGE.SET_TOKEN('CC_NUM', l_cc_num ,TRUE);
                l_message  := FND_MESSAGE.GET;

		INSERT
		INTO igc_cc_process_exceptions
		(  process_type,
	 	   process_phase,
	 	   cc_header_id,
	 	   cc_acct_line_id,
	 	   cc_det_pf_line_id,
	 	   exception_reason,
	 	   org_id,
	 	   set_of_books_id,
                   request_id
                )
                VALUES
                (  'F',
	 	   'F',
		   p_cc_header_id,
		   NULL,
		   NULL,
		   l_message,
		   p_org_id,
		   p_sob_id,
                   p_request_id
                );

	END IF;



	/* Lock all purchase orders related to contract commitments being re-valued */
	l_lock_po := IGC_CC_REP_YEP_PVT.lock_po(p_cc_header_id);

	IF (NOT l_lock_po)
	THEN

		l_message := NULL;
		FND_MESSAGE.SET_NAME('IGC','IGC_CC_PO_LOCK_FAILURE');
                FND_MESSAGE.SET_TOKEN('CC_NUM', l_cc_num ,TRUE);
                l_message  := FND_MESSAGE.GET;

		INSERT
		INTO igc_cc_process_exceptions
		(  process_type,
	 	   process_phase,
	 	   cc_header_id,
	 	   cc_acct_line_id,
	 	   cc_det_pf_line_id,
	 	   exception_reason,
	 	   org_id,
	 	   set_of_books_id,
                   request_id
                )
                VALUES
                (  'F',
	       	   'F',
		   p_cc_header_id,
		   NULL,
		   NULL,
		   l_message,
		   p_org_id,
		   p_sob_id,
                   p_request_id
		);

	END IF;

	IF (l_lock_po = TRUE) AND (l_lock_cc = TRUE)
	THEN
		RETURN(TRUE);
	ELSE
		RETURN(FALSE);

	END IF;
EXCEPTION
	WHEN OTHERS
	THEN
		RETURN(FALSE);

END lock_cc_po;

FUNCTION reval_fix_update(p_cc_header_id        IN NUMBER,
                          p_rel_cc_header_id    IN NUMBER,
		          p_revalue_fix_date    IN DATE,
		          p_sob_id              IN NUMBER,
		          p_org_id              IN NUMBER,
			  p_sbc_on              IN BOOLEAN,
			  p_cbc_on              IN BOOLEAN,
			  p_prov_enc_on         IN BOOLEAN,
			  p_conf_enc_on         IN BOOLEAN,
                          p_validate_only       IN VARCHAR2,
                          p_request_id          IN NUMBER,
                          p_message             OUT NOCOPY VARCHAR2,
                          p_err_header_id       OUT NOCOPY NUMBER,
                          p_err_acct_line_id    OUT NOCOPY NUMBER,
                          p_err_det_pf_line_id  OUT NOCOPY NUMBER
                          )
RETURN VARCHAR2
IS

	l_cc_headers_rec              igc_cc_headers%ROWTYPE;
	l_rel_cc_headers_rec          igc_cc_headers%ROWTYPE;
	l_cc_acct_lines_rec           igc_cc_acct_lines_v%ROWTYPE;
	l_cc_pmt_fcst_rec             igc_cc_det_pf_v%ROWTYPE;
	l_exception                   igc_cc_process_exceptions.exception_reason%TYPE;
	l_action_hist_msg             igc_cc_actions.cc_action_notes%TYPE;


	CURSOR c_acct_lines(p_cc_header_id NUMBER)
	IS
                -- Replaced the folllowing query with the one below for
                -- performance tuning fixes.
                -- The record definition of l_cc_acct_lines_rec is still based on
                -- view igc_cc_acct_lines_v. Instead of selecting from the view,
                -- select is being done from the base table, but all the columns
                -- as defined in the view are retained even though they are not used.
                -- This is just so that minimal change is made to the code.

		-- SELECT *
		-- FROM   igc_cc_acct_lines_v
		-- WHERE  cc_header_id = p_cc_header_id;


                SELECT ccal.ROWID,
                       ccal.cc_header_id,
                       NULL org_id,
                       NULL cc_type,
                       NULL cc_type_code,
                       NULL cc_num,
                       ccal.cc_acct_line_id,
                       ccal.cc_acct_line_num,
                       ccal.cc_acct_desc,
                       ccal.parent_header_id,
                       ccal.parent_acct_line_id,
                       NULL parent_cc_acct_line_num,
                       NULL cc_budget_acct_desc,
                       ccal.cc_budget_code_combination_id,
                       NULL cc_charge_acct_desc,
                       ccal.cc_charge_code_combination_id,
                       ccal.cc_acct_entered_amt,
                       ccal.cc_acct_func_amt,
                       IGC_CC_COMP_AMT_PKG.COMPUTE_ACCT_BILLED_AMT( ccal.cc_acct_line_id) cc_acct_billed_amt,
                       IGC_CC_COMP_AMT_PKG.COMPUTE_ACCT_FUNC_BILLED_AMT( ccal.cc_acct_line_id) cc_acct_func_billed_amt,
                       ccal.cc_acct_encmbrnc_amt,
                       ( IGC_CC_COMP_AMT_PKG.COMPUTE_FUNCTIONAL_AMT ( ccal.cc_header_id, NVL(ccal.cc_acct_entered_amt,0) ) -  NVL(ccal.cc_acct_encmbrnc_amt,0) ) cc_acct_unencmrd_amt,
                       ccal.cc_acct_unbilled_amt,
                       IGC_CC_COMP_AMT_PKG.COMPUTE_FUNCTIONAL_AMT(ccal.cc_header_id, NVL(ccal.cc_acct_entered_amt,0)) cc_acct_comp_func_amt,
                       NULL project_number ,
                       ccal.project_id,
                       NULL task_number,
                       ccal.task_id,
                       ccal.expenditure_type,
                       NULL expenditure_org_name,
                       ccal.expenditure_org_id,
                       ccal.expenditure_item_date,
                       ccal.cc_acct_taxable_flag,
                       NULL tax_name,
                       NULL tax_id, -- Bug 6472296 for r12 EBtax uptake for CC
                       ccal.cc_acct_encmbrnc_status,
                       ccal.cc_acct_encmbrnc_date,
                       ccal.context,
                       ccal.attribute1,
                       ccal.attribute2,
                       ccal.attribute3,
                       ccal.attribute4,
                       ccal.attribute5,
                       ccal.attribute6,
                       ccal.attribute7,
                       ccal.attribute8,
                       ccal.attribute9,
                       ccal.attribute10,
                       ccal.attribute11,
                       ccal.attribute12,
                       ccal.attribute13,
                       ccal.attribute14,
                       ccal.attribute15,
                       ccal.created_by,
                       ccal.creation_date,
                       ccal.last_updated_by,
                       ccal.last_update_date,
                       ccal.last_update_login,
                       ccal.cc_func_withheld_amt,
                       ccal.cc_ent_withheld_amt,
                       IGC_CC_COMP_AMT_PKG.COMPUTE_FUNCTIONAL_AMT(ccal.cc_header_id,
                       NVL(ccal.cc_func_withheld_amt,0)) cc_comp_func_whld_amt,
                       ccal.TAX_CLASSIF_CODE  /* Bug No : 6341012. E-BTax uptake.New field is ebing added to Account_Lines Table R12 */
                FROM igc_cc_acct_lines ccal
		WHERE  cc_header_id = p_cc_header_id;

	CURSOR c_pf_lines(p_cc_acct_line_id NUMBER)
	IS
        -- Performance Tuning, replaced view igc_cc_det_pf_v with igc_cc_det_pf
	-- SELECT *
	-- FROM   igc_cc_det_pf_v
	-- WHERE  cc_acct_line_id = p_cc_acct_line_id;

        SELECT ccdpf.ROWID,
               ccdpf.cc_det_pf_line_id,
               ccdpf.cc_det_pf_line_num,
               NULL  cc_acct_line_num,
               ccdpf.cc_acct_line_id,
               NULL  parent_det_pf_line_num,
               ccdpf.parent_det_pf_line_id,
               ccdpf.parent_acct_line_id,
               ccdpf.cc_det_pf_entered_amt,
               ccdpf.cc_det_pf_func_amt,
               ccdpf.cc_det_pf_date,
               IGC_CC_COMP_AMT_PKG.COMPUTE_PF_BILLED_AMT(ccdpf.cc_det_pf_line_id,  ccdpf.cc_det_pf_line_num, ccdpf.cc_acct_line_id) cc_det_pf_billed_amt,
               IGC_CC_COMP_AMT_PKG.COMPUTE_PF_FUNC_BILLED_AMT(ccdpf.cc_det_pf_line_id,  ccdpf.cc_det_pf_line_num, ccdpf.cc_acct_line_id) cc_det_pf_func_billed_amt,
               ccdpf.cc_det_pf_unbilled_amt,
               IGC_CC_COMP_AMT_PKG.COMPUTE_FUNCTIONAL_AMT(p_cc_header_id,NVL(ccdpf.cc_det_pf_entered_amt,0)) cc_det_pf_comp_func_amt,
               ccdpf.cc_det_pf_encmbrnc_amt,
               ( IGC_CC_COMP_AMT_PKG.COMPUTE_FUNCTIONAL_AMT ( p_cc_header_id,  NVL(ccdpf.cc_det_pf_entered_amt,0) ) - NVL(ccdpf.cc_det_pf_encmbrnc_amt,0) )  cc_det_pf_unencmbrd_amt ,
               ccdpf.cc_det_pf_encmbrnc_date,
               ccdpf.cc_det_pf_encmbrnc_status,
               ccdpf.context,
               ccdpf.attribute1,
               ccdpf.attribute2,
               ccdpf.attribute3,
               ccdpf.attribute4,
               ccdpf.attribute5,
               ccdpf.attribute6,
               ccdpf.attribute7,
               ccdpf.attribute8,
               ccdpf.attribute9,
               ccdpf.attribute10,
               ccdpf.attribute11,
               ccdpf.attribute12,
               ccdpf.attribute13,
               ccdpf.attribute14,
               ccdpf.attribute15,
               ccdpf.last_update_date,
               ccdpf.last_updated_by,
               ccdpf.last_update_login,
               ccdpf.creation_date,
               ccdpf.created_by
        FROM igc_cc_det_pf ccdpf
	WHERE  ccdpf.cc_acct_line_id = p_cc_acct_line_id;

	l_hdr_row_id               VARCHAR2(18);
	l_hist_hdr_row_id          VARCHAR2(18);
	l_acct_row_id              VARCHAR2(18);
	l_hist_acct_row_id         VARCHAR2(18);
	l_pf_row_id                VARCHAR2(18);
	l_hist_pf_row_id           VARCHAR2(18);
        l_action_row_id            VARCHAR2(18);


	l_new_cc_det_pf_func_amt   igc_cc_det_pf.cc_det_pf_func_amt%TYPE;
	l_new_cc_acct_func_amt     igc_cc_acct_lines.cc_acct_func_amt%TYPE;

	l_api_version              CONSTANT NUMBER  :=  1.0;
	l_init_msg_list            VARCHAR2(1)      := FND_API.G_FALSE;
	l_commit                   VARCHAR2(1)      := FND_API.G_FALSE;
	l_validation_level         NUMBER           := FND_API.G_VALID_LEVEL_FULL;
	l_return_status            VARCHAR2(1);
	l_msg_count                NUMBER;
	l_msg_data                 VARCHAR2(2000);
	G_FLAG                     VARCHAR2(1);

	l_approval_status         igc_cc_process_data.old_approval_status%TYPE;

        l_Last_Updated_By         NUMBER := FND_GLOBAL.USER_ID;
        l_Last_Update_Login       NUMBER := FND_GLOBAL.LOGIN_ID;
        l_Created_By              NUMBER := FND_GLOBAL.USER_ID;

	l_cc_acct_date            igc_cc_headers.cc_acct_date%TYPE;
        l_conversion_date         igc_cc_headers.conversion_date%TYPE;
        l_conversion_rate         igc_cc_headers.conversion_rate%TYPE;
        l_cc_version_num          igc_cc_headers.cc_version_num%TYPE;
        l_cc_apprvl_status        igc_cc_headers.cc_apprvl_status%TYPE;

	l_cc_acct_func_amt        igc_cc_acct_lines.cc_acct_func_amt%TYPE;
        l_cc_acct_encmbrnc_date   igc_cc_acct_lines.cc_acct_encmbrnc_date%TYPE;
        l_cc_acct_encmbrnc_amt    igc_cc_acct_lines.cc_acct_encmbrnc_amt%TYPE ;

	l_cc_det_pf_date          igc_cc_det_pf.cc_det_pf_date%TYPE;
        l_cc_det_pf_encmbrnc_date igc_cc_det_pf.cc_det_pf_encmbrnc_date%TYPE;
	l_cc_det_pf_func_amt      igc_cc_det_pf.cc_det_pf_func_amt%TYPE;
        l_cc_det_pf_encmbrnc_amt  igc_cc_det_pf.cc_det_pf_encmbrnc_amt%TYPE;

	l_det_pf_func_amt_total   igc_cc_det_pf.cc_det_pf_func_amt%TYPE;

	l_cc_acct_func_amt_total  igc_cc_acct_lines.cc_acct_func_amt%TYPE;

	l_rel_conversion_rate     igc_cc_headers.conversion_rate%TYPE;

BEGIN

	SELECT *
	INTO l_cc_headers_rec
	FROM igc_cc_headers
	WHERE cc_header_id = p_cc_header_id;


	SELECT  old_approval_status
      	INTO    l_approval_status
        FROM    igc_cc_process_data
        WHERE   cc_header_id  = p_cc_header_id AND
                request_id    = p_request_id ;

	IF (p_validate_only = 'N')
	THEN
		IF (l_cc_headers_rec.cc_type = 'C')
		THEN
			SELECT conversion_rate
               		INTO l_rel_conversion_rate
			FROM igc_cc_headers
                	WHERE cc_header_id = p_rel_cc_header_id;
		END IF;


		/* Update Header History */
		l_return_status := FND_API.G_RET_STS_SUCCESS;

        	IGC_CC_HEADER_HISTORY_PKG.Insert_Row(
                                             l_api_version,
                                             l_init_msg_list,
                                             l_commit,
                                             l_validation_level,
                                             l_return_status,
                                             l_msg_count,
                                             l_msg_data,
                                             l_hist_hdr_row_id,
                                             l_cc_headers_rec.CC_HEADER_ID,
					     l_cc_headers_rec.ORG_ID,
                                             l_cc_headers_rec.CC_TYPE,
                                             l_cc_headers_rec.CC_NUM,
                                             l_cc_headers_rec.CC_VERSION_NUM,
                                             'R',
                                             l_cc_headers_rec.CC_STATE,
                                             l_cc_headers_rec.PARENT_HEADER_ID,
                                             l_cc_headers_rec.CC_CTRL_STATUS,
                                             l_cc_headers_rec.CC_ENCMBRNC_STATUS,
                                             l_approval_status,
                                             l_cc_headers_rec.VENDOR_ID,
                                             l_cc_headers_rec.VENDOR_SITE_ID,
                                             l_cc_headers_rec.VENDOR_CONTACT_ID,
                                             l_cc_headers_rec.TERM_ID,
                                             l_cc_headers_rec.LOCATION_ID,
                                             l_cc_headers_rec.SET_OF_BOOKS_ID,
                                             l_cc_headers_rec.CC_ACCT_DATE,
                                             l_cc_headers_rec.CC_DESC,
                                             l_cc_headers_rec.CC_START_DATE,
                                             l_cc_headers_rec.CC_END_DATE,
                                             l_cc_headers_rec.CC_OWNER_USER_ID,
                                             l_cc_headers_rec.CC_PREPARER_USER_ID,
                                             l_cc_headers_rec.CURRENCY_CODE,
                                             l_cc_headers_rec.CONVERSION_TYPE,
                                             l_cc_headers_rec.CONVERSION_DATE,
                                             l_cc_headers_rec.CONVERSION_RATE,
                                             l_cc_headers_rec.LAST_UPDATE_DATE,
                                             l_cc_headers_rec.LAST_UPDATED_BY,
                                             l_cc_headers_rec.LAST_UPDATE_LOGIN,
                                             l_cc_headers_rec.CREATED_BY,
                                             l_cc_headers_rec.CREATION_DATE,
                                             l_cc_headers_rec.WF_ITEM_TYPE,
                                             l_cc_headers_rec.WF_ITEM_KEY,
                                             l_cc_headers_rec.CC_CURRENT_USER_ID,
-- Context should be after attributes, so moved below - ssmales 18/10/01
--                                           l_cc_headers_rec.CONTEXT,
                                             l_cc_headers_rec.ATTRIBUTE1,
                                             l_cc_headers_rec.ATTRIBUTE2,
                                             l_cc_headers_rec.ATTRIBUTE3,
                                             l_cc_headers_rec.ATTRIBUTE4,
                                             l_cc_headers_rec.ATTRIBUTE5,
                                             l_cc_headers_rec.ATTRIBUTE6,
                                             l_cc_headers_rec.ATTRIBUTE7,
                                             l_cc_headers_rec.ATTRIBUTE8,
                                             l_cc_headers_rec.ATTRIBUTE9,
                                             l_cc_headers_rec.ATTRIBUTE10,
                                             l_cc_headers_rec.ATTRIBUTE11,
                                             l_cc_headers_rec.ATTRIBUTE12,
                                             l_cc_headers_rec.ATTRIBUTE13,
                                             l_cc_headers_rec.ATTRIBUTE14,
                                             l_cc_headers_rec.ATTRIBUTE15,
                                             l_cc_headers_rec.CONTEXT,
                                             l_cc_headers_rec.CC_GUARANTEE_FLAG,
                                             G_FLAG);

		IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)
		THEN

        		l_EXCEPTION := NULL;
               		FND_MESSAGE.SET_NAME('IGC','IGC_CC_YEP_HEADER_HST_INSERT');
                	l_EXCEPTION := FND_MESSAGE.GET;
			p_message   := l_exception;
                        p_err_header_id := l_cc_headers_rec.cc_header_id;
                        p_err_acct_line_id := NULL;
                        p_err_det_pf_line_id := NULL;

			RETURN 'F';
		END IF;

		OPEN c_acct_lines(l_cc_headers_rec.cc_header_id);
		LOOP
			FETCH c_acct_lines INTO l_cc_acct_lines_rec;
			EXIT WHEN c_acct_lines%NOTFOUND;

               		l_new_cc_acct_func_amt := 0;

			l_cc_acct_func_amt_total := 0;

			OPEN c_pf_lines(l_cc_acct_lines_rec.cc_acct_line_id);
			LOOP
				FETCH c_pf_lines INTO l_cc_pmt_fcst_rec;
				EXIT WHEN c_pf_lines%NOTFOUND;

				l_new_cc_det_pf_func_amt := 0;

				IF (l_cc_headers_rec.cc_type = 'C')
				THEN
					l_det_pf_func_amt_total := 0;

					BEGIN
                                        -- Performance Tuning, replaced view igc_cc_det_pf_v
                                        -- with igc_cc_det_pf_v and replaced the
                                        -- following line.
                                        --  - (a.cc_det_pf_func_amt - a.cc_det_pf_func_billed_amt)
					SELECT
                                      	( ( ( a.cc_det_pf_entered_amt - IGC_CC_COMP_AMT_PKG.COMPUTE_PF_BILLED_AMT(a.cc_det_pf_line_id, a.cc_det_pf_line_num, a.cc_acct_line_id))
                                           * l_rel_conversion_rate
                                         )
                                         - (a.cc_det_pf_func_amt - IGC_CC_COMP_AMT_PKG.COMPUTE_PF_FUNC_BILLED_AMT(a.cc_det_pf_line_id,  a.cc_det_pf_line_num, a.cc_acct_line_id))
                                        )
                                	INTO   l_det_pf_func_amt_total
			        	FROM   igc_cc_det_pf a,
                                       	       igc_cc_acct_lines b
                                	WHERE  a.parent_det_pf_line_id = l_cc_pmt_fcst_rec.cc_det_pf_line_id AND
                                       	       a.cc_acct_line_id       = b.cc_acct_line_id AND
                                               b.cc_header_id          = p_rel_cc_header_id;
					EXCEPTION
						WHEN NO_DATA_FOUND
						THEN
							l_det_pf_func_amt_total := 0;
                                	END;

					l_new_cc_det_pf_func_amt := l_det_pf_func_amt_total;
                                	l_cc_acct_func_amt_total := l_cc_acct_func_amt_total + l_new_cc_det_pf_func_amt;
				END IF;

				IF (l_cc_headers_rec.cc_type = 'S') OR (l_cc_headers_rec.cc_type = 'R')
				THEN
                        		l_new_cc_det_pf_func_amt :=
                                      	( ( ( l_cc_pmt_fcst_rec.cc_det_pf_entered_amt -
                                              l_cc_pmt_fcst_rec.cc_det_pf_billed_amt)
                                           * l_cc_headers_rec.conversion_rate
                                         )
                                         - (l_cc_pmt_fcst_rec.cc_det_pf_func_amt -
                                            l_cc_pmt_fcst_rec.cc_det_pf_func_billed_amt)
                                        );
                                	l_cc_acct_func_amt_total := l_cc_acct_func_amt_total + l_new_cc_det_pf_func_amt;
				END IF;

				IF (l_new_cc_det_pf_func_amt <> 0)
				THEN

					/* Update PF Line History */

					l_return_status := FND_API.G_RET_STS_SUCCESS;

                      			IGC_CC_DET_PF_HISTORY_PKG.Insert_Row(
                                        l_api_version,
                                        l_init_msg_list,
                                        l_commit,
                                        l_validation_level,
                                        l_return_status,
                                        l_msg_count,
                                        l_msg_data,
                                        l_hist_pf_row_id,
                                        l_cc_pmt_fcst_rec.CC_Det_PF_Line_Id,
                                        l_cc_pmt_fcst_rec.CC_Det_PF_Line_Num,
                                        l_cc_pmt_fcst_rec.CC_Acct_Line_Id,
                                        l_cc_pmt_fcst_rec.Parent_Acct_Line_Id,
                                        l_cc_pmt_fcst_rec.Parent_Det_PF_Line_Id,
                                        l_cc_headers_rec.cc_version_num,
                                        'U',
                                        l_cc_pmt_fcst_rec.CC_Det_PF_Entered_Amt,
                                        l_cc_pmt_fcst_rec.CC_Det_PF_Func_Amt,
                                        l_cc_pmt_fcst_rec.CC_Det_PF_Date,
                                        l_cc_pmt_fcst_rec.CC_Det_PF_Billed_Amt,
                                        l_cc_pmt_fcst_rec.CC_Det_PF_Unbilled_Amt,
                                        l_cc_pmt_fcst_rec.CC_Det_PF_Encmbrnc_Amt,
                                        l_cc_pmt_fcst_rec.CC_Det_PF_Encmbrnc_Date,
                                        l_cc_pmt_fcst_rec.CC_Det_PF_Encmbrnc_Status,
                                        l_cc_pmt_fcst_rec.Last_Update_Date,
		                        l_cc_pmt_fcst_rec.Last_Updated_By,
		                        l_cc_pmt_fcst_rec.Last_Update_Login,
		                        l_cc_pmt_fcst_rec.Creation_Date,
                                        l_cc_pmt_fcst_rec.Created_By,
                                        l_cc_pmt_fcst_rec.Attribute1,
		                        l_cc_pmt_fcst_rec.Attribute2,
		                        l_cc_pmt_fcst_rec.Attribute3,
		                        l_cc_pmt_fcst_rec.Attribute4,
		                        l_cc_pmt_fcst_rec.Attribute5,
		                        l_cc_pmt_fcst_rec.Attribute6,
		                        l_cc_pmt_fcst_rec.Attribute7,
		                        l_cc_pmt_fcst_rec.Attribute8,
		                        l_cc_pmt_fcst_rec.Attribute9,
		                        l_cc_pmt_fcst_rec.Attribute10,
		                        l_cc_pmt_fcst_rec.Attribute11,
		                        l_cc_pmt_fcst_rec.Attribute12,
		                        l_cc_pmt_fcst_rec.Attribute13,
		                        l_cc_pmt_fcst_rec.Attribute14,
		                        l_cc_pmt_fcst_rec.Attribute15,
                                        l_cc_pmt_fcst_rec.Context,
                                        G_FLAG       );

					IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)
					THEN

                               	 		l_EXCEPTION := NULL;
                                		FND_MESSAGE.SET_NAME('IGC','IGC_CC_YEP_DET_PF_HST_INSERT');
                                		l_EXCEPTION := FND_MESSAGE.GET;

			                        p_message   := l_exception;
                                                p_err_header_id := l_cc_headers_rec.cc_header_id;
                                                p_err_acct_line_id := l_cc_acct_lines_rec.CC_ACCT_LINE_ID;
                                                p_err_det_pf_line_id := l_cc_pmt_fcst_rec.CC_Det_PF_Line_Id;

						RETURN 'F';
					END IF;


					l_new_cc_det_pf_func_amt :=
					                   l_cc_pmt_fcst_rec.cc_det_pf_func_amt    +
                                                           l_new_cc_det_pf_func_amt;


					IF (( ( (l_cc_headers_rec.cc_state = 'PR')
                                             OR (l_cc_headers_rec.cc_state = 'CL') )
                     		              AND (p_sbc_on = TRUE) AND (p_prov_enc_on = TRUE)
                   	                   ) OR
		  	                  ( ( (l_cc_headers_rec.cc_state = 'CM')
                                            OR (l_cc_headers_rec.cc_state = 'CT') )
                     		             AND (p_sbc_on = TRUE)  AND (p_conf_enc_on = TRUE)
                                          ))
                                         /* Fix for bug  1634793 */
                                         AND (l_cc_headers_rec.cc_type <> 'R')
		                        THEN
						IF (l_cc_pmt_fcst_rec.cc_det_pf_date <= p_revalue_fix_date)
						THEN
							l_cc_det_pf_date          := p_revalue_fix_date;
                               				l_cc_det_pf_encmbrnc_date := p_revalue_fix_date;
						END IF;

						IF (l_cc_pmt_fcst_rec.cc_det_pf_date > p_revalue_fix_date)
						THEN
							l_cc_det_pf_date          := l_cc_pmt_fcst_rec.cc_det_pf_date;
                               				l_cc_det_pf_encmbrnc_date := l_cc_pmt_fcst_rec.cc_det_pf_encmbrnc_date;
						END IF;
					ELSE
						l_cc_det_pf_date          := l_cc_pmt_fcst_rec.cc_det_pf_date;
                               			l_cc_det_pf_encmbrnc_date := l_cc_pmt_fcst_rec.cc_det_pf_encmbrnc_date;

					END IF;

					l_cc_det_pf_func_amt      := l_new_cc_det_pf_func_amt;

					SELECT rowid
                        		INTO   l_pf_row_id
                        		FROM   igc_cc_det_pf
                        		WHERE  cc_det_pf_line_id = l_cc_pmt_fcst_rec.cc_det_pf_line_id;

                        		IGC_CC_DET_PF_PKG.Update_Row(
                                        l_api_version,
                                        l_init_msg_list,
                                        l_commit,
                                        l_validation_level,
                                        l_return_status,
                                        l_msg_count,
                                        l_msg_data,
                                        l_pf_row_id,
                                        l_cc_pmt_fcst_rec.CC_Det_PF_Line_Id,
                                        l_cc_pmt_fcst_rec.CC_Det_PF_Line_Num,
                                        l_cc_pmt_fcst_rec.CC_Acct_Line_Id,
                                        l_cc_pmt_fcst_rec.Parent_Acct_Line_Id,
                                        l_cc_pmt_fcst_rec.Parent_Det_PF_Line_Id,
                                        l_cc_pmt_fcst_rec.CC_Det_PF_Entered_Amt,
                                        l_cc_det_pf_func_amt,
                                        l_cc_det_pf_date,
                                        l_cc_pmt_fcst_rec.CC_Det_PF_Billed_Amt,
                                        l_cc_pmt_fcst_rec.CC_Det_PF_Unbilled_Amt,
                                        l_cc_pmt_fcst_rec.cc_det_pf_encmbrnc_amt,
                                        l_cc_det_pf_encmbrnc_date,
                                        l_cc_pmt_fcst_rec.CC_Det_PF_Encmbrnc_Status,
                                        sysdate,
                                        l_Last_Updated_By,
                                        l_Last_Update_Login,
                                        l_cc_pmt_fcst_rec.Creation_Date,
                                        l_cc_pmt_fcst_rec.Created_By,
                                        l_cc_pmt_fcst_rec.Attribute1,
                                        l_cc_pmt_fcst_rec.Attribute2,
                                        l_cc_pmt_fcst_rec.Attribute3,
                                        l_cc_pmt_fcst_rec.Attribute4,
                                        l_cc_pmt_fcst_rec.Attribute5,
                                        l_cc_pmt_fcst_rec.Attribute6,
                                        l_cc_pmt_fcst_rec.Attribute7,
                                        l_cc_pmt_fcst_rec.Attribute8,
                                        l_cc_pmt_fcst_rec.Attribute9,
                                        l_cc_pmt_fcst_rec.Attribute10,
                                        l_cc_pmt_fcst_rec.Attribute11,
                                        l_cc_pmt_fcst_rec.Attribute12,
                                        l_cc_pmt_fcst_rec.Attribute13,
                                        l_cc_pmt_fcst_rec.Attribute14,
                                        l_cc_pmt_fcst_rec.Attribute15,
                                        l_cc_pmt_fcst_rec.Context,
                                        G_FLAG       );


                    			IF     (l_return_status <> FND_API.G_RET_STS_SUCCESS)
                    			THEN

                                		l_EXCEPTION := NULL;
                                		FND_MESSAGE.SET_NAME('IGC','IGC_CC_YEP_DET_PF_UPDATE');
                                		l_EXCEPTION := FND_MESSAGE.GET;

			                        p_message   := l_exception;
                                                p_err_header_id      := l_cc_headers_rec.cc_header_id;
                                                p_err_acct_line_id   := l_cc_acct_lines_rec.CC_ACCT_LINE_ID;
                                                p_err_det_pf_line_id := l_cc_pmt_fcst_rec.CC_Det_PF_Line_Id;

                           			RETURN 'F';
                    			END IF;
				END IF;

			END LOOP;

			CLOSE c_pf_lines;

                	l_new_cc_acct_func_amt := l_cc_acct_func_amt_total;

			IF (l_new_cc_acct_func_amt <> 0)
                	THEN
				/* Update Account Line History*/
				l_return_status := FND_API.G_RET_STS_SUCCESS;

				IGC_CC_ACCT_LINE_HISTORY_PKG.Insert_Row(
                       		l_api_version ,
                       		l_init_msg_list,
                                l_commit,
                                l_validation_level,
                                l_return_status,
                                l_msg_count,
                                l_msg_data,
                                l_hist_acct_row_id,
                                l_cc_acct_lines_rec.CC_Acct_Line_Id,
                                l_cc_acct_lines_rec.CC_Header_Id,
                                l_cc_acct_lines_rec.Parent_Header_Id,
                                l_cc_acct_lines_rec.Parent_Acct_Line_Id ,
                                l_cc_acct_lines_rec.CC_Acct_Line_Num,
                                l_cc_headers_rec.cc_version_num,
                                'U',
                                l_cc_acct_lines_rec.CC_Charge_Code_Combination_Id,
                                l_cc_acct_lines_rec.CC_Budget_Code_Combination_Id,
                                l_cc_acct_lines_rec.CC_Acct_Entered_Amt ,
                                l_cc_acct_lines_rec.CC_Acct_Func_Amt,
                                l_cc_acct_lines_rec.CC_Acct_Desc ,
                                l_cc_acct_lines_rec.CC_Acct_Billed_Amt ,
                                l_cc_acct_lines_rec.CC_Acct_Unbilled_Amt,
                                l_cc_acct_lines_rec.CC_Acct_Taxable_Flag,
                                l_cc_acct_lines_rec.Tax_Id,
                                l_cc_acct_lines_rec.CC_Acct_Encmbrnc_Amt,
                                l_cc_acct_lines_rec.CC_Acct_Encmbrnc_Date,
                                l_cc_acct_lines_rec.CC_Acct_Encmbrnc_Status,
                                l_cc_acct_lines_rec.Project_Id,
                                l_cc_acct_lines_rec.Task_Id,
                                l_cc_acct_lines_rec.Expenditure_Type,
                                l_cc_acct_lines_rec.Expenditure_Org_Id,
                                l_cc_acct_lines_rec.Expenditure_Item_Date,
                                l_cc_acct_lines_rec.Last_Update_Date,
                                l_cc_acct_lines_rec.Last_Updated_By,
                                l_cc_acct_lines_rec.Last_Update_Login ,
                                l_cc_acct_lines_rec.Creation_Date ,
                                l_cc_acct_lines_rec.Created_By ,
                                l_cc_acct_lines_rec.Attribute1,
                                l_cc_acct_lines_rec.Attribute2,
                                l_cc_acct_lines_rec.Attribute3,
                                l_cc_acct_lines_rec.Attribute4,
                                l_cc_acct_lines_rec.Attribute5,
                                l_cc_acct_lines_rec.Attribute6,
                                l_cc_acct_lines_rec.Attribute7,
                                l_cc_acct_lines_rec.Attribute8,
                                l_cc_acct_lines_rec.Attribute9,
                                l_cc_acct_lines_rec.Attribute10 ,
                                l_cc_acct_lines_rec.Attribute11,
                                l_cc_acct_lines_rec.Attribute12,
                                l_cc_acct_lines_rec.Attribute13,
                                l_cc_acct_lines_rec.Attribute14,
                                l_cc_acct_lines_rec.Attribute15,
                                l_cc_acct_lines_rec.Context,
                                l_cc_acct_lines_rec.CC_Func_Withheld_Amt,
                                l_cc_acct_lines_rec.CC_Ent_Withheld_Amt,
                                G_FLAG,
				l_cc_acct_lines_rec.TAX_CLASSIF_CODE  /* r12 EBtax uptake for CC */
	                         );

				IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)
				THEN

                        		l_EXCEPTION := NULL;
                        		FND_MESSAGE.SET_NAME('IGC','IGC_CC_YEP_ACT_LINE_HST_INSERT');
                        		l_EXCEPTION := FND_MESSAGE.GET;

			                p_message             := l_exception;
                                        p_err_header_id       := l_cc_headers_rec.cc_header_id;
                                        p_err_acct_line_id    := l_cc_acct_lines_rec.CC_ACCT_LINE_ID;
                                        p_err_det_pf_line_id  := NULL;

					RETURN 'F';
				END IF;


				l_new_cc_acct_func_amt :=
		       				l_cc_acct_lines_rec.cc_acct_func_amt +
                                                l_new_cc_acct_func_amt;

				l_cc_acct_func_amt      := l_new_cc_acct_func_amt;

				IF ( ( (l_cc_headers_rec.cc_state = 'PR')  OR (l_cc_headers_rec.cc_state = 'CL') )
                     		    AND (p_cbc_on = TRUE) AND (p_prov_enc_on = TRUE)
                   	           ) OR
		  	        ( ( (l_cc_headers_rec.cc_state = 'CM')  OR (l_cc_headers_rec.cc_state = 'CT') )
                     		   AND (p_cbc_on = TRUE)  AND (p_conf_enc_on = TRUE)
                                )
		                THEN
       		       			l_cc_acct_encmbrnc_date := p_revalue_fix_date;
				END IF;

				SELECT rowid
                	        INTO l_acct_row_id
			        FROM igc_cc_acct_lines
			        WHERE cc_acct_line_id = l_cc_acct_lines_rec.cc_acct_line_id;

                	        IGC_CC_ACCT_LINES_PKG.Update_Row(
                       	        l_api_version ,
                       	        l_init_msg_list,
                       	        l_commit,
                       	        l_validation_level,
                       	        l_return_status,
                       	        l_msg_count,
                       	        l_msg_data,
                       	        l_acct_row_id,
                       	        l_cc_acct_lines_rec.CC_Acct_Line_Id,
                       	        l_cc_acct_lines_rec.CC_Header_Id,
                       	        l_cc_acct_lines_rec.Parent_Header_Id,
                       	        l_cc_acct_lines_rec.Parent_Acct_Line_Id ,
                       	        l_cc_acct_lines_rec.CC_Charge_Code_Combination_Id,
                       	        l_cc_acct_lines_rec.CC_Acct_Line_Num,
                       	        l_cc_acct_lines_rec.CC_Budget_Code_Combination_Id,
                       	        l_cc_acct_lines_rec.CC_Acct_Entered_Amt ,
                       	        l_cc_acct_func_amt,
                       	        l_cc_acct_lines_rec.CC_Acct_Desc ,
                       	        l_cc_acct_lines_rec.CC_Acct_Billed_Amt ,
                       	        l_cc_acct_lines_rec.CC_Acct_Unbilled_Amt,
                       	        l_cc_acct_lines_rec.CC_Acct_Taxable_Flag,
                       	        l_cc_acct_lines_rec.Tax_Id,
                       	        l_cc_acct_lines_rec.cc_acct_encmbrnc_amt,
                       	        l_cc_acct_encmbrnc_date,
                       	        l_cc_acct_lines_rec.CC_Acct_Encmbrnc_Status,
                       	        l_cc_acct_lines_rec.Project_Id,
                       	        l_cc_acct_lines_rec.Task_Id,
                       	        l_cc_acct_lines_rec.Expenditure_Type,
                       	        l_cc_acct_lines_rec.Expenditure_Org_Id,
                       	        l_cc_acct_lines_rec.Expenditure_Item_Date,
                       	        sysdate,
                       	        l_Last_Updated_By,
                       	        l_Last_Update_Login ,
                       	        l_cc_acct_lines_rec.Creation_Date ,
                       	        l_cc_acct_lines_rec.Created_By ,
                       	        l_cc_acct_lines_rec.Attribute1,
                       	        l_cc_acct_lines_rec.Attribute2,
                       	        l_cc_acct_lines_rec.Attribute3,
                       	        l_cc_acct_lines_rec.Attribute4,
                       	        l_cc_acct_lines_rec.Attribute5,
                       	        l_cc_acct_lines_rec.Attribute6,
                       	        l_cc_acct_lines_rec.Attribute7,
                       	        l_cc_acct_lines_rec.Attribute8,
                       	        l_cc_acct_lines_rec.Attribute9,
                       	        l_cc_acct_lines_rec.Attribute10 ,
                       	        l_cc_acct_lines_rec.Attribute11,
                       	        l_cc_acct_lines_rec.Attribute12,
                       	        l_cc_acct_lines_rec.Attribute13,
                       	        l_cc_acct_lines_rec.Attribute14,
                       	        l_cc_acct_lines_rec.Attribute15,
                       	        l_cc_acct_lines_rec.Context,
                                l_cc_acct_lines_rec.CC_Func_Withheld_Amt,
                                l_cc_acct_lines_rec.CC_Ent_Withheld_Amt,
                       	        G_FLAG,
				l_cc_acct_lines_rec.TAX_CLASSIF_CODE  /*  Bug 6472296 for r12 EBtax uptake for CC  */
				);


                		IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)
                		THEN

                        		l_EXCEPTION := NULL;
                        		FND_MESSAGE.SET_NAME('IGC','IGC_CC_YEP_ACT_LINES_UPDATE');
                        		l_EXCEPTION := FND_MESSAGE.GET;

			                p_message             := l_exception;
                                        p_err_header_id      := l_cc_headers_rec.cc_header_id;
                                        p_err_acct_line_id   := l_cc_acct_lines_rec.CC_ACCT_LINE_ID;
                                        p_err_det_pf_line_id := NULL;

                       			RETURN 'F';
                		END IF;
			END IF;

		END LOOP;

		CLOSE c_acct_lines;

	END IF;

	IF (p_validate_only = 'N')
	THEN

		IF ( ( (l_cc_headers_rec.cc_state = 'PR')  OR (l_cc_headers_rec.cc_state = 'CL') )
                     AND (p_cbc_on = TRUE) AND (p_prov_enc_on = TRUE)
                   ) OR
		  ( ( (l_cc_headers_rec.cc_state = 'CM')  OR (l_cc_headers_rec.cc_state = 'CT') )
                     AND (p_cbc_on = TRUE)  AND (p_conf_enc_on = TRUE)
                   )
		THEN
			IF (l_cc_headers_rec.cc_acct_date IS NOT NULL)
			THEN
				IF (l_cc_headers_rec.cc_acct_date <= p_revalue_fix_date)
				THEN
					l_cc_acct_date         := p_revalue_fix_date;
				ELSIF (l_cc_headers_rec.cc_acct_date > p_revalue_fix_date)
				THEN
					l_cc_acct_date         := l_cc_headers_rec.cc_acct_date;
				END IF;
			END IF;

			IF (l_cc_headers_rec.cc_acct_date IS NULL)
			THEN
				l_cc_acct_date         := l_cc_headers_rec.cc_acct_date;
			END IF;
		ELSE

			l_cc_acct_date         := l_cc_headers_rec.cc_acct_date;
		END IF;

                l_cc_version_num       := l_cc_headers_rec.cc_version_num + 1;
                l_cc_apprvl_status     := l_approval_status;

                SELECT rowid
                INTO   l_hdr_row_id
                FROM   igc_cc_headers
                WHERE  CC_HEADER_ID = l_cc_headers_rec.cc_header_id;

	        IGC_CC_HEADERS_PKG.Update_Row(
                         l_api_version,
                         l_init_msg_list,
                         l_commit,
                         l_validation_level,
                         l_return_status,
                         l_msg_count,
                         l_msg_data,
                         l_hdr_row_id,
                         l_cc_headers_rec.CC_HEADER_ID,
                         l_cc_headers_rec.ORG_ID,
                         l_cc_headers_rec.CC_TYPE,
                         l_cc_headers_rec.CC_NUM,
                         l_cc_version_num,
                         l_cc_headers_rec.PARENT_HEADER_ID,
                         l_cc_headers_rec.CC_STATE,
                         l_cc_headers_rec.CC_CTRL_STATUS,
                         l_cc_headers_rec.CC_ENCMBRNC_STATUS,
                         l_cc_apprvl_status,
                         l_cc_headers_rec.VENDOR_ID,
                         l_cc_headers_rec.VENDOR_SITE_ID,
                         l_cc_headers_rec.VENDOR_CONTACT_ID,
                         l_cc_headers_rec.TERM_ID,
                         l_cc_headers_rec.LOCATION_ID,
                         l_cc_headers_rec.SET_OF_BOOKS_ID,
                         l_cc_acct_date,
                         l_cc_headers_rec.CC_DESC,
                         l_cc_headers_rec.CC_START_DATE,
                         l_cc_headers_rec.CC_END_DATE,
                         l_cc_headers_rec.CC_OWNER_USER_ID,
                         l_cc_headers_rec.CC_PREPARER_USER_ID,
                         l_cc_headers_rec.CURRENCY_CODE,
                         l_cc_headers_rec.CONVERSION_TYPE,
                         l_cc_headers_rec.conversion_date,
                         l_cc_headers_rec.conversion_rate,
                         sysdate,
                         l_LAST_UPDATED_BY,
                         l_LAST_UPDATE_LOGIN,
                         l_cc_headers_rec.CREATED_BY,
                         l_cc_headers_rec.CREATION_DATE,
                         l_cc_headers_rec.CC_CURRENT_USER_ID,
                         l_cc_headers_rec.WF_ITEM_TYPE,
                         l_cc_headers_rec.WF_ITEM_KEY,
                         l_cc_headers_rec.ATTRIBUTE1,
                         l_cc_headers_rec.ATTRIBUTE2,
                         l_cc_headers_rec.ATTRIBUTE3,
                         l_cc_headers_rec.ATTRIBUTE4,
                         l_cc_headers_rec.ATTRIBUTE5,
                         l_cc_headers_rec.ATTRIBUTE6,
                         l_cc_headers_rec.ATTRIBUTE7,
                         l_cc_headers_rec.ATTRIBUTE8,
                         l_cc_headers_rec.ATTRIBUTE9,
                         l_cc_headers_rec.ATTRIBUTE10,
                         l_cc_headers_rec.ATTRIBUTE11,
                         l_cc_headers_rec.ATTRIBUTE12,
                         l_cc_headers_rec.ATTRIBUTE13,
                         l_cc_headers_rec.ATTRIBUTE14,
                         l_cc_headers_rec.ATTRIBUTE15,
                         l_cc_headers_rec.CONTEXT,
                         l_cc_headers_rec.CC_Guarantee_Flag,
                         G_FLAG);

		IF      (l_return_status <> FND_API.G_RET_STS_SUCCESS)
		THEN

                	l_EXCEPTION := NULL;
                	FND_MESSAGE.SET_NAME('IGC','IGC_CC_YEP_HEADERS_UPDATE');
                	l_EXCEPTION := FND_MESSAGE.GET;


	                p_message             := l_exception;
                        p_err_header_id := l_cc_headers_rec.cc_header_id;
                        p_err_acct_line_id := NULL;
                        p_err_det_pf_line_id := NULL;

			RETURN 'F';
		END IF;


	 ELSIF (p_validate_only = 'Y')
	 THEN
		UPDATE igc_cc_headers
		SET cc_apprvl_status = l_approval_status
		WHERE cc_header_id   = p_cc_header_id;
	 END IF;



	/* Update Corresponding PO */

	IF ( (l_cc_headers_rec.cc_type = 'S') OR
	     (l_cc_headers_rec.cc_type = 'R')    )  AND
            /* Changed l_cc_headers_rec.cc_apprvl_status to l_approval_status to fix bug 1632984 */
	   ( ( (l_cc_headers_rec.cc_state = 'CM') AND (l_approval_status = 'AP') ) OR
	     (l_cc_headers_rec.cc_state = 'CT')  )
	THEN
		l_return_status := FND_API.G_RET_STS_SUCCESS;

		IGC_CC_PO_INTERFACE_PKG.Convert_CC_TO_PO(1.0,
			                FND_API.G_FALSE,
				        FND_API.G_TRUE,
                                        FND_API.G_VALID_LEVEL_NONE,
				        l_return_status,
                                        l_msg_count,
				        l_msg_data,
					l_cc_headers_rec.cc_header_id);

		IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)
		THEN
			RETURN 'F';
		END IF;
	END IF;

        /* added following code to remove hard coded message */
        /* begin */
	l_action_hist_msg := NULL;
        /* end */

        IGC_CC_ACTIONS_PKG.Insert_Row(
                                l_api_version,
                                l_init_msg_list,
                                l_commit,
                                l_validation_level,
                                l_return_status,
                                l_msg_count,
                                l_msg_data,
                                l_action_row_id,
                                l_cc_headers_rec.CC_HEADER_ID,
                                l_cc_version_num,
                                'RF',
                                l_cc_headers_rec.CC_STATE,
                                l_cc_headers_rec.CC_CTRL_STATUS,
                                l_cc_apprvl_status,
                                l_action_hist_msg,
                                Sysdate,
                                l_Last_Updated_By,
                                l_Last_Update_Login,
                                Sysdate,
                                l_Created_By);

	IF      (l_return_status <> FND_API.G_RET_STS_SUCCESS)
	THEN

              l_EXCEPTION := NULL;
              FND_MESSAGE.SET_NAME('IGC','IGC_CC_YEP_ACTION_HST_INSERT');
              l_EXCEPTION := FND_MESSAGE.GET;


	      p_message             := l_exception;
              p_err_header_id := l_cc_headers_rec.cc_header_id;
              p_err_acct_line_id := NULL;
              p_err_det_pf_line_id := NULL;

              RETURN 'F';
	END IF;

	/* Update validation status, in temporary table*/
	UPDATE igc_cc_process_data
	SET
		processed = 'Y'
	WHERE   request_id        = p_request_id AND
		cc_header_id      = P_cc_header_id ;

	RETURN 'P';

EXCEPTION
	WHEN OTHERS
	THEN
		RETURN 'F';

END  reval_fix_update;


PROCEDURE populate_errors(p_cc_header_id   NUMBER,
			  p_process_phase  VARCHAR2,
                          p_sob_id         NUMBER,
                          p_org_id         NUMBER,
                          p_request_id     NUMBER)
IS
	l_message igc_cc_process_exceptions.exception_reason%TYPE;
BEGIN
	/* Update validation_status to 'F' in temporary table for releases */

	UPDATE igc_cc_process_data a
	SET    a.validation_status   = 'F'
	WHERE  a.cc_header_id        = p_cc_header_id AND
               request_id            = p_request_id;

	l_message := NULL;
	FND_MESSAGE.SET_NAME('IGC','IGC_CC_AVAILABLE_AMT_EXCEEDED');
        l_message  := FND_MESSAGE.GET;

	INSERT
	INTO igc_cc_process_exceptions
		(process_type,
	 	process_phase,
	 	cc_header_id,
	 	cc_acct_line_id,
	 	cc_det_pf_line_id,
	 	exception_reason,
	 	org_id,
	 	set_of_books_id,
                request_id)
		SELECT 'F',
		        p_process_phase,
			b.cc_header_id,
			NULL,
			NULL,
			l_message,
			p_org_id,
			p_sob_id,
                        p_request_id
		FROM    igc_cc_headers b,
	       		igc_cc_process_data a
		WHERE
			b.parent_header_id   = p_cc_header_id   AND
			b.cc_header_id       = a.cc_header_id   AND
                        a.request_id         = p_request_id;
END populate_errors;

PROCEDURE revalue_fix_main( ERRBUF               OUT NOCOPY VARCHAR2,
			    RETCODE              OUT NOCOPY VARCHAR2,
/*Bug No : 6341012. MOAC Uptake. SOB_ID,ORG_ID are retrieved from Packages rather than from Profile values*/
--			    p_sob_id             IN  NUMBER,
--			    p_org_id             IN  NUMBER,
			    p_cc_header_id       IN  NUMBER,
                            p_revalue_fix_date   IN  VARCHAR2)
IS
	l_cc_headers_rec              igc_cc_headers%ROWTYPE;
	l_rel_cc_headers_rec          igc_cc_headers%ROWTYPE;
	l_cc_acct_lines_rec           igc_cc_acct_lines_v%ROWTYPE;
	l_rel_cc_acct_lines_rec       igc_cc_acct_lines_v%ROWTYPE;
	l_cc_pmt_fcst_rec             igc_cc_det_pf_v%ROWTYPE;
	l_rel_cc_pmt_fcst_rec         igc_cc_det_pf_v%ROWTYPE;

/*Bug No : 6341012. MOAC Uptake. Local variables for SOB_ID,ORG_ID,SOB_NAME */
	l_sob_id		NUMBER;
	l_org_id		NUMBER;
	l_sob_name	VARCHAR2(30);

        l_revalue_fix_date            DATE;

	l_budg_status                 BOOLEAN;
	l_validation_status           VARCHAR2(1);
	l_curr_validation_status      VARCHAR2(1);
	l_reservation_status          VARCHAR2(1);
	l_processed                   VARCHAR2(1);
	l_validate_only               VARCHAR2(1);
	l_process_flag                VARCHAR2(1);
	l_message                     igc_cc_process_exceptions.exception_reason%TYPE;

	l_cc_count                    NUMBER  := 0;
	l_invalid_cc_count            NUMBER  := 0;
	l_po_count                    NUMBER  := 0;

	l_cc_cover_count              NUMBER  := 0;

	l_request_id2                 NUMBER  := 0;
	l_request_id1                 NUMBER  := 79000;

	l_lock_cc_po                  BOOLEAN := FALSE;
	l_cover_not_found             BOOLEAN := FALSE;
	l_cc_not_found                BOOLEAN := FALSE;

	l_currency_code               gl_sets_of_books.currency_code%TYPE;
	l_cover_currency_code         gl_sets_of_books.currency_code%TYPE;
	l_sbc_on 		      BOOLEAN;
	l_cbc_on 		      BOOLEAN;
	l_prov_enc_on                 BOOLEAN;
	l_conf_enc_on                 BOOLEAN;
/*Bug No : 6341012. SLA Uptake. Encumbrance Type IDs are not required */
--	l_req_encumbrance_type_id     NUMBER;
--	l_purch_encumbrance_type_id   NUMBER;
--	l_cc_prov_enc_type_id         NUMBER;
--	l_cc_conf_enc_type_id         NUMBER;

	l_non_reval_acct_amt_total    NUMBER := 0;
	l_reval_acct_amt_total        NUMBER := 0;
	l_non_reval_pf_amt_total      NUMBER := 0;
	l_reval_pf_amt_total          NUMBER := 0;
	l_cover_acct_func_amt         NUMBER := 0;
	l_cover_pf_func_amt           NUMBER := 0;
        l_msg_count                   NUMBER := 0;
        l_msg_data                    VARCHAR2(12000);
        l_error_text                  VARCHAR2(12000);
	l_usr_msg                     igc_cc_process_exceptions.exception_reason%TYPE;

        l_err_header_id               NUMBER;
	l_err_acct_line_id            NUMBER;
        l_err_det_pf_line_id          NUMBER;

	p_process_phase               VARCHAR2(1) := 'F';

        -- 01/03/02, CC enabled in IGI
        l_option_name                 VARCHAR2(80);
        lv_message                    VARCHAR2(1000);
----Variables related to XML report
   l_terr                      VARCHAR2(10):='US';
   l_lang                      VARCHAR2(10):='en';
   l_layout                    BOOLEAN;

	/* Cursor for fetching all contract commitments eligible for re-valuation */

	CURSOR c_revalue_process_cc(p_cc_header_id       NUMBER)
	IS

		SELECT *
		FROM   igc_cc_headers a
		WHERE  a.cc_header_id = p_cc_header_id;

	/* Fetch the cover-relase both revalued data from temporary table */
	CURSOR c_cover_reval_data(p_request_id NUMBER)
	IS
		SELECT a.cc_header_id
		FROM   igc_cc_process_data a ,
		       igc_cc_headers b
                WHERE  a.request_id   = p_request_id     AND
                       a.cc_header_id = b.cc_header_id AND
                       b.cc_type      = 'C';


	/* Fetch the cover-standard data from temporary table */
	CURSOR c_reval_data(p_request_id NUMBER)
	IS
		SELECT a.cc_header_id
		FROM   igc_cc_process_data a ,
		       igc_cc_headers b
                WHERE  a.request_id     = p_request_id       AND
                       a.cc_header_id   = b.cc_header_id     AND
                       (b.cc_type       = 'C' OR b.cc_type = 'S');

	CURSOR C_ALL_RELEASES1(p_cc_header_id  NUMBER)
	IS
		SELECT *
		FROM  igc_cc_headers
		WHERE parent_header_id = p_cc_header_id;

	CURSOR C_ALL_RELEASES(p_cc_header_id  NUMBER)
	IS
		SELECT a.cc_header_id
		FROM igc_cc_headers a
		WHERE a.parent_header_id = p_cc_header_id;

	CURSOR C_RELEASES(p_cc_header_id  NUMBER)
	IS
		SELECT a.cc_header_id
		FROM igc_cc_headers a
		WHERE a.parent_header_id = p_cc_header_id;

	CURSOR C_ACCT_LINES(p_cc_header_id NUMBER)
	IS
                -- Replaced the folllowing query with the one below for
                -- performance tuning fixes.
                -- The record definition of l_cc_acct_lines_rec is still based on
                -- view igc_cc_acct_lines_v. Instead of selecting from the view,
                -- select is being done from the base table, but all the columns
                -- as defined in the view are retained even though they are not used.
                -- This is just so that minimal change is made to the code.
                /*
		SELECT *
		FROM igc_cc_acct_lines_v
		WHERE cc_header_id = p_cc_header_id;
                */

                SELECT ccal.ROWID,
                       ccal.cc_header_id,
                       NULL org_id,
                       NULL cc_type,
                       NULL cc_type_code,
                       NULL cc_num,
                       ccal.cc_acct_line_id,
                       ccal.cc_acct_line_num,
                       ccal.cc_acct_desc,
                       ccal.parent_header_id,
                       ccal.parent_acct_line_id,
                       NULL parent_cc_acct_line_num,
                       NULL cc_budget_acct_desc,
                       ccal.cc_budget_code_combination_id,
                       NULL cc_charge_acct_desc,
                       ccal.cc_charge_code_combination_id,
                       ccal.cc_acct_entered_amt,
                       ccal.cc_acct_func_amt,
                       IGC_CC_COMP_AMT_PKG.COMPUTE_ACCT_BILLED_AMT( ccal.cc_acct_line_id) cc_acct_billed_amt,
                       IGC_CC_COMP_AMT_PKG.COMPUTE_ACCT_FUNC_BILLED_AMT( ccal.cc_acct_line_id) cc_acct_func_billed_amt,
                       ccal.cc_acct_encmbrnc_amt,
                       ( IGC_CC_COMP_AMT_PKG.COMPUTE_FUNCTIONAL_AMT ( ccal.cc_header_id, NVL(ccal.cc_acct_entered_amt,0) ) -  NVL(ccal.cc_acct_encmbrnc_amt,0) ) cc_acct_unencmrd_amt,
                       ccal.cc_acct_unbilled_amt,
                       IGC_CC_COMP_AMT_PKG.COMPUTE_FUNCTIONAL_AMT(ccal.cc_header_id, NVL(ccal.cc_acct_entered_amt,0)) cc_acct_comp_func_amt,
                       NULL project_number ,
                       ccal.project_id,
                       NULL task_number,
                       ccal.task_id,
                       ccal.expenditure_type,
                       NULL expenditure_org_name,
                       ccal.expenditure_org_id,
                       ccal.expenditure_item_date,
                       ccal.cc_acct_taxable_flag,
                       NULL tax_name,
                       NULL tax_id, --  Bug 6472296 for r12 EBtax uptake for CC
                       ccal.cc_acct_encmbrnc_status,
                       ccal.cc_acct_encmbrnc_date,
                       ccal.context,
                       ccal.attribute1,
                       ccal.attribute2,
                       ccal.attribute3,
                       ccal.attribute4,
                       ccal.attribute5,
                       ccal.attribute6,
                       ccal.attribute7,
                       ccal.attribute8,
                       ccal.attribute9,
                       ccal.attribute10,
                       ccal.attribute11,
                       ccal.attribute12,
                       ccal.attribute13,
                       ccal.attribute14,
                       ccal.attribute15,
                       ccal.created_by,
                       ccal.creation_date,
                       ccal.last_updated_by,
                       ccal.last_update_date,
                       ccal.last_update_login,
                       ccal.cc_func_withheld_amt,
                       ccal.cc_ent_withheld_amt,
                       IGC_CC_COMP_AMT_PKG.COMPUTE_FUNCTIONAL_AMT(ccal.cc_header_id,
                       NVL(ccal.cc_func_withheld_amt,0)) cc_comp_func_whld_amt,
		      ccal.TAX_CLASSIF_CODE  /* Bug No : 6341012. E-BTax uptake.New field is ebing added to Account_Lines Table R12 */
                FROM igc_cc_acct_lines ccal
		WHERE cc_header_id = p_cc_header_id;

	CURSOR C_PF_LINES(p_cc_acct_line_id NUMBER)
	IS
	-- SELECT *
	-- FROM igc_cc_det_pf_v
	-- WHERE cc_acct_line_id = p_cc_acct_line_id;

        SELECT ccdpf.ROWID,
               ccdpf.cc_det_pf_line_id,
               ccdpf.cc_det_pf_line_num,
               NULL  cc_acct_line_num,
               ccdpf.cc_acct_line_id,
               NULL  parent_det_pf_line_num,
               ccdpf.parent_det_pf_line_id,
               ccdpf.parent_acct_line_id,
               ccdpf.cc_det_pf_entered_amt,
               ccdpf.cc_det_pf_func_amt,
               ccdpf.cc_det_pf_date,
               IGC_CC_COMP_AMT_PKG.COMPUTE_PF_BILLED_AMT(ccdpf.cc_det_pf_line_id,  ccdpf.cc_det_pf_line_num, ccdpf.cc_acct_line_id) cc_det_pf_billed_amt,
               IGC_CC_COMP_AMT_PKG.COMPUTE_PF_FUNC_BILLED_AMT(ccdpf.cc_det_pf_line_id,  ccdpf.cc_det_pf_line_num, ccdpf.cc_acct_line_id) cc_det_pf_func_billed_amt,
               ccdpf.cc_det_pf_unbilled_amt,
               IGC_CC_COMP_AMT_PKG.COMPUTE_FUNCTIONAL_AMT(p_cc_header_id,NVL(ccdpf.cc_det_pf_entered_amt,0)) cc_det_pf_comp_func_amt,
               ccdpf.cc_det_pf_encmbrnc_amt,
               ( IGC_CC_COMP_AMT_PKG.COMPUTE_FUNCTIONAL_AMT (p_cc_header_id,  NVL(ccdpf.cc_det_pf_entered_amt,0) ) - NVL(ccdpf.cc_det_pf_encmbrnc_amt,0) )  cc_det_pf_unencmbrd_amt ,
               ccdpf.cc_det_pf_encmbrnc_date,
               ccdpf.cc_det_pf_encmbrnc_status,
               ccdpf.context,
               ccdpf.attribute1,
               ccdpf.attribute2,
               ccdpf.attribute3,
               ccdpf.attribute4,
               ccdpf.attribute5,
               ccdpf.attribute6,
               ccdpf.attribute7,
               ccdpf.attribute8,
               ccdpf.attribute9,
               ccdpf.attribute10,
               ccdpf.attribute11,
               ccdpf.attribute12,
               ccdpf.attribute13,
               ccdpf.attribute14,
               ccdpf.attribute15,
               ccdpf.last_update_date,
               ccdpf.last_updated_by,
               ccdpf.last_update_login,
               ccdpf.creation_date,
               ccdpf.created_by
        FROM igc_cc_det_pf ccdpf
	WHERE ccdpf.cc_acct_line_id = p_cc_acct_line_id;

	l_cc_header_id      igc_cc_headers.cc_header_id%TYPE;
	l_rel_cc_header_id  igc_cc_headers.cc_header_id%TYPE;
	l_cc_acct_line_id   igc_cc_acct_lines.cc_acct_line_id%TYPE;
        l_debug             VARCHAR2(1);

	insert_data EXCEPTION;
BEGIN


   -- 01/03/02, check to see if CC is installed
   IF NOT igi_gen.is_req_installed('CC') THEN

      SELECT meaning
      INTO l_option_name
      FROM igi_lookups
      WHERE lookup_code = 'CC'
      AND lookup_type = 'GCC_DESCRIPTION';

      FND_MESSAGE.SET_NAME('IGI', 'IGI_GEN_PROD_NOT_INSTALLED');
      FND_MESSAGE.SET_TOKEN('OPTION_NAME', l_option_name);
      lv_message := fnd_message.get;
      errbuf := lv_message;
      retcode := 2;
      return;
   END IF;

  /*Bug No : 6341012. MOAC Uptake. ORG_ID,SOB_ID are retrieved from packages */
	l_org_id := MO_GLOBAL.get_current_org_id;
	MO_UTILS.get_ledger_info(l_org_id,l_sob_id,l_sob_name);

	RETCODE := '0';

	l_request_id1   := fnd_global.conc_request_id;
        p_process_phase := 'F';

      -- Bug 1914745, clear any old records from the igc_cc_interface table
      -- DELETE FROM igc_cc_interface
      -- WHERE  to_date(creation_date,'DD/MM/YYYY') <= to_date((sysdate - interval '2' day), 'DD/MM/YYYY');

        -- Bug 2872060. Above Delete commented out due to compilation probs in Oracle8i
        DELETE FROM igc_cc_interface
        WHERE  to_date(creation_date,'DD/MM/YYYY') <= to_date(sysdate ,'DD/MM/YYYY') - 2;

        /* Begin bug fix 1591845 */
	/* Added TRUNC to statement below to remove time portion of p_revalue_fix_date to fix bug 1632975.*/

        l_revalue_fix_date := TRUNC(to_date (p_revalue_fix_date, 'YYYY/MM/DD HH24:MI:SS'));

        /* End  bug fix 1591845 */
	SAVEPOINT REVALUE1;

	l_currency_code              := NULL;
	l_sbc_on 		     := NULL;
	l_cbc_on 		     := NULL;
	l_prov_enc_on                := NULL;
	l_conf_enc_on                := NULL;
/*Bug No : 6341012. SLA Uptake. Encumbrance Type IDs are not required */
--	l_req_encumbrance_type_id    := NULL;
--	l_purch_encumbrance_type_id  := NULL;
--	l_cc_prov_enc_type_id        := NULL;
--	l_cc_conf_enc_type_id        := NULL;

--
-- Setup debug information based upon profile setup options.
--
/*
        l_debug       := FND_PROFILE.VALUE('IGC_DEBUG_ENABLED');
        IF (l_debug = 'Y') THEN
           l_debug := FND_API.G_TRUE;
        ELSE
           l_debug := FND_API.G_FALSE;
        END IF;
        IGC_MSGS_PKG.g_debug_mode := FND_API.TO_BOOLEAN(l_debug);
*/

	/* Get Budgetary Control information */

	/* Begin fix for bug 1576023 */
	l_msg_data  := NULL;
	l_msg_count := 0;
	l_usr_msg   := NULL;

	l_budg_status := IGC_CC_REP_YEP_PVT.get_budg_ctrl_params(
  /* Bug No : 6341012. R12 Uptake. p_sob_id,p_org_id are changed to l_sob_id,l_org_id */
			   l_sob_id,
			   l_org_id,
			   l_currency_code,
			   l_sbc_on,
			   l_cbc_on,
			   l_prov_enc_on,
			   l_conf_enc_on,
  /* Bug No : 6341012. R12 Uptake. Encumbrance Type IDs are not required */
	--		   l_req_encumbrance_type_id,
	--		   l_purch_encumbrance_type_id,
	--		   l_cc_prov_enc_type_id,
	--		   l_cc_conf_enc_type_id,
                           l_msg_data,
                           l_msg_count,
                           l_usr_msg
			   ) ;


	IF (l_budg_status = FALSE) AND (l_usr_msg IS NOT NULL)
        THEN
		INSERT INTO
		igc_cc_process_exceptions
		(process_type,
	 	process_phase,
	 	cc_header_id,
	 	cc_acct_line_id,
	 	cc_det_pf_line_id,
	 	exception_reason,
	 	org_id,
	 	set_of_books_id,
                request_id)
		VALUES
                ( 'F',
	 	  p_process_phase,
		  NULL,
		  NULL,
		  NULL,
		  l_usr_msg,
  /* Bug No : 6341012. R12 Uptake. p_sob_id,p_org_id are changed to l_sob_id,l_org_id */
		  l_org_id,
		  l_sob_id,
                  l_request_id1);

		COMMIT;

	END IF;

	IF ( l_budg_status = FALSE AND l_usr_msg IS NOT NULL)
	THEN
  /*Bug No : 6341012. MOAC Uptake. Need to set org_id before submiting a request*/
	        Fnd_request.set_org_id(l_org_id);
		l_request_id2 := FND_REQUEST.SUBMIT_REQUEST(
                                'IGC',
               	                'IGCCRVFR',
                                NULL,
                                NULL,
                                FALSE,
  /* Bug No : 6341012. R12 Uptake. p_sob_id,p_org_id are changed to l_sob_id,l_org_id */
                                l_sob_id,
                                l_org_id,
                                p_process_phase,
                                'F',
                                l_request_id1);
-----------------------
-- Start of XML Report
-----------------------
            IF IGC_CC_COMMON_UTILS_PVT.xml_report_enabled THEN
                  IGC_CC_COMMON_UTILS_PVT.get_xml_layout_info(
                                            l_lang,
                                            l_terr,
                                            'IGCCRVFR_XML',
                                            'IGC',
                                            'IGCCRVFR_XML' );
                  l_layout :=  FND_REQUEST.ADD_LAYOUT(
                                            'IGC',
                                            'IGCCRVFR_XML',
                                            l_lang,
                                            l_terr,
                                            'RTF');
                  IF l_layout then
                       l_request_id2 := FND_REQUEST.SUBMIT_REQUEST(
                                'IGC',
               	                'IGCCRVFR_XML',
                                NULL,
                                NULL,
                                FALSE,
                  /* Bug No : 6341012. R12 Uptake. p_sob_id,p_org_id are changed to l_sob_id,l_org_id */
                                l_sob_id,
                                l_org_id,
                                p_process_phase,
                                'F',
                                l_request_id1);
                  END IF;
             END IF;

--------------------
-- End of XML Report
--------------------

    END IF;

-- ------------------------------------------------------------------------------------
-- Ensure that any exceptions raised are output into the log file to be reported to
-- the user if any are present.
-- ------------------------------------------------------------------------------------
	IF ( l_budg_status = FALSE )
	THEN
        	FND_MSG_PUB.Count_And_Get ( p_count => l_msg_count,
                                    	    p_data  => l_msg_data );

        	IF (l_msg_count > 0)
		THEN
        		l_error_text := '';

               		 FOR l_cur IN 1..l_msg_count
			 LOOP
                         	l_error_text := ' Mesg No : '|| l_cur ||' '|| FND_MSG_PUB.GET(l_cur, FND_API.G_FALSE);
--                      		fnd_file.put_line (FND_FILE.LOG,
--                               	                   l_error_text);
                                      -- bug 3199488 start block
                                      IF (l_state_level >= l_debug_level) THEN
                                          FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_reval_fix_process_pkg.revalue_fix_main.Excp1',
                                                                        l_error_text);
                                      END IF;
                                      -- bug 3199488, end block

                	END LOOP;
        	END IF;
	END IF;

	IF (l_usr_msg IS NULL AND l_budg_status = FALSE)
	THEN
        	RETCODE := 2;
	END IF;

	IF ( l_budg_status = FALSE )
	THEN
		RETURN;
	END IF;

	/* End fix for bug 1576023 */


	IF ( NOT    validate_params(p_process_phase,
  /* Bug No : 6341012. R12 Uptake. p_sob_id,p_org_id are changed to l_sob_id,l_org_id */
	         	            l_sob_id,
			            l_org_id,
	                            p_cc_header_id,
                                    l_revalue_fix_date,
                                    l_request_id1)
	    )
	THEN
/*Bug No : 6341012. MOAC Uptake. Need to set org_id before submiting a request*/
	        Fnd_request.set_org_id(l_org_id);
		l_request_id2 := FND_REQUEST.SUBMIT_REQUEST(
                                'IGC',
               	                'IGCCRVFR',
                                NULL,
                                NULL,
                                FALSE,
/* Bug No : 6341012. R12 Uptake. p_sob_id,p_org_id are changed to l_sob_id,l_org_id */
                                l_sob_id,
			        l_org_id,
                                p_process_phase,
                                'F',
                                l_request_id1);
-----------------------
-- Start of XML Report
-----------------------
       IF IGC_CC_COMMON_UTILS_PVT.xml_report_enabled THEN
               IGC_CC_COMMON_UTILS_PVT.get_xml_layout_info(
                                            l_lang,
                                            l_terr,
                                            'IGCCRVFR_XML',
                                            'IGC',
                                            'IGCCRVFR_XML' );
               l_layout :=  FND_REQUEST.ADD_LAYOUT(
                                            'IGC',
                                            'IGCCRVFR_XML',
                                            l_lang,
                                            l_terr,
                                            'RTF');
               IF l_layout then
                   l_request_id2 := FND_REQUEST.SUBMIT_REQUEST(
                                'IGC',
               	                'IGCCRVFR_XML',
                                NULL,
                                NULL,
                                FALSE,
                             /* Bug No : 6341012. R12 Uptake. p_sob_id,p_org_id are changed to l_sob_id,l_org_id */
                                l_sob_id,
                                l_org_id,
                                p_process_phase,
                                'F',
                                l_request_id1);
              END IF;
      END IF;
--------------------
-- End of XML Report
--------------------
-- ------------------------------------------------------------------------------------
-- Ensure that any exceptions raised are output into the log file to be reported to
-- the user if any are present.
-- ------------------------------------------------------------------------------------
                FND_MSG_PUB.Count_And_Get ( p_count => l_msg_count,
                                            p_data  => l_msg_data );

                IF (l_msg_count > 0) THEN
                   l_error_text := '';
                   FOR l_cur IN 1..l_msg_count LOOP
                      l_error_text := ' Mesg No : '|| l_cur ||' '|| FND_MSG_PUB.GET(l_cur, FND_API.G_FALSE);
--                      fnd_file.put_line (FND_FILE.LOG,
--                                         l_error_text);
                   -- bug 3199488 start block
                   IF (l_state_level >= l_debug_level) THEN
                       FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_reval_fix_process_pkg.revalue_fix_main.Excp2',
                                                     l_error_text);
                   END IF;
                   -- bug 3199488, end block
                   END LOOP;
                END IF;

		RETURN;
	END IF;

	SAVEPOINT REVALUE3;

	/* Populate temporary table */

	OPEN c_revalue_process_cc(p_cc_header_id);
	LOOP
		FETCH c_revalue_process_cc
		INTO l_cc_headers_rec;

       		EXIT WHEN c_revalue_process_cc%NOTFOUND;

		/* Begin Standard Revaluation */
		IF (l_cc_headers_rec.cc_type = 'S')
		THEN
			INSERT INTO igc_cc_process_data
                       	(
			process_type,
			process_phase,
			cc_header_id,
			validation_status,
			reservation_status,
			processed,
			old_approval_status,
			org_id,
			set_of_books_id,
                        validate_only,
                        request_id)
			VALUES
			( 'F',
			p_process_phase,
		 	l_cc_headers_rec.cc_header_id,
		 	'I',
		 	'F',
		 	'N',
		 	NULL,
/* Bug No : 6341012. R12 Uptake. p_sob_id,p_org_id are changed to l_sob_id,l_org_id */
		 	l_org_id,
		 	l_sob_id,
                        'Y',
                        l_request_id1);

			COMMIT;

		END IF;
		/* End Standard Revaluation */

		/* Begin release Revaluation */

		IF (l_cc_headers_rec.cc_type = 'R')
		THEN
			SELECT currency_code
                        INTO l_cover_currency_code
			FROM igc_cc_headers
			WHERE cc_header_id = l_cc_headers_rec.parent_header_id;

			/* Functional Currency Cover */
			IF (l_currency_code = l_cover_currency_code)
			THEN
				INSERT INTO igc_cc_process_data
                       		(
				process_type,
				process_phase,
				cc_header_id,
				validation_status,
				reservation_status,
				processed,
				old_approval_status,
				org_id,
				set_of_books_id,
                               	validate_only,
                               	request_id)
				VALUES
				( 'F',
			 	p_process_phase,
		 		l_cc_headers_rec.parent_header_id,
		 		'I',
		 		'F',
		 		'N',
		 		NULL,
/* Bug No : 6341012. R12 Uptake. p_sob_id,p_org_id are changed to l_sob_id,l_org_id */
		 		l_org_id,
		 		l_sob_id,
                               	'Y',
                               	l_request_id1);
				COMMIT;
			END IF;


			/* Non Functional Currency Cover */
			IF (l_currency_code <> l_cover_currency_code)
			THEN
				INSERT INTO igc_cc_process_data
                       		(
				process_type,
				process_phase,
				cc_header_id,
				validation_status,
				reservation_status,
				processed,
				old_approval_status,
				org_id,
				set_of_books_id,
                               	validate_only,
                               	request_id)
				VALUES
				( 'F',
			 	p_process_phase,
		 		l_cc_headers_rec.parent_header_id,
		 		'I',
		 		'F',
		 		'N',
		 		NULL,
/* Bug No : 6341012. R12 Uptake. p_sob_id,p_org_id are changed to l_sob_id,l_org_id */
		 		l_org_id,
		 		l_sob_id,
                               	'N',
                               	l_request_id1);
				COMMIT;
			END IF;


			OPEN c_all_releases(l_cc_headers_rec.parent_header_id);
			LOOP
				FETCH c_all_releases INTO l_cc_header_id;
				EXIT WHEN c_all_releases%NOTFOUND;

				IF (l_cc_header_id = l_cc_headers_rec.cc_header_id)
				THEN

					INSERT INTO igc_cc_process_data
                       			(
					process_type,
					process_phase,
					cc_header_id,
					validation_status,
					reservation_status,
					processed,
					old_approval_status,
					org_id,
					set_of_books_id,
                                       	validate_only,
                                        request_id)
			        	VALUES
					( 'F',
			 		p_process_phase,
		 			l_cc_header_id,
		 			'I',
		 			'F',
		 			'N',
		 			NULL,
/* Bug No : 6341012. R12 Uptake. p_sob_id,p_org_id are changed to l_sob_id,l_org_id */
		 			l_org_id,
		 			l_sob_id,
                                        'N',
                                        l_request_id1);
				ELSE
					INSERT INTO igc_cc_process_data
                       			(
					process_type,
					process_phase,
					cc_header_id,
					validation_status,
					reservation_status,
					processed,
					old_approval_status,
					org_id,
					set_of_books_id,
                                       	validate_only,
                                        request_id)
					VALUES
					( 'F',
			 		p_process_phase,
		 			l_cc_header_id,
		 			'I',
		 			'F',
		 			'N',
		 			NULL,
/* Bug No : 6341012. R12 Uptake. p_sob_id,p_org_id are changed to l_sob_id,l_org_id */
		 			l_org_id,
		 			l_sob_id,
                                       	'Y',
                                        l_request_id1);
				END IF;

			END LOOP;

			CLOSE c_all_releases;

			COMMIT;

		END IF;
		/* End release */

	END LOOP;

	CLOSE c_revalue_process_cc;

	COMMIT;

	/* Begin  Lock CC and PO */
	/* Lock Contract Commitments and related PO's If Phase = 'Final' */

	IF (p_process_phase = 'F')
	THEN

		OPEN c_reval_data(l_request_id1);
		LOOP
			FETCH c_reval_data INTO l_cc_header_id;
       			EXIT WHEN c_reval_data%NOTFOUND;

			/* Get Contract Details */
			SELECT *
			INTO l_cc_headers_rec
			FROM igc_cc_headers
			WHERE cc_header_id = l_cc_header_id;

			l_lock_cc_po := TRUE;

			/* Standard */
			IF (l_cc_headers_rec.cc_type = 'S')
			THEN
/* Bug No : 6341012. R12 Uptake. p_sob_id,p_org_id are changed to l_sob_id,l_org_id */
				l_lock_cc_po := lock_cc_po(l_sob_id,l_org_id,l_cc_header_id, l_request_id1);

			END IF;

			IF (l_lock_cc_po = FALSE)
			THEN
				COMMIT;
				EXIT;
			END IF;

			/* Cover Relase */

			IF (l_cc_headers_rec.cc_type = 'C')
			THEN
				OPEN c_releases(l_cc_headers_rec.cc_header_id);
				LOOP
					FETCH c_releases INTO l_rel_cc_header_id;
					EXIT WHEN c_releases%NOTFOUND;

					IF (l_lock_cc_po = TRUE)
					THEN
/* Bug No : 6341012. R12 Uptake. p_sob_id,p_org_id are changed to l_sob_id,l_org_id */
						l_lock_cc_po := lock_cc_po(l_sob_id,l_org_id,l_rel_cc_header_id,l_request_id1);
					END IF;

					IF (l_lock_cc_po = FALSE)
					THEN
						COMMIT;
						EXIT;
					END IF;

				END LOOP;
				CLOSE c_releases;


				IF (l_lock_cc_po = TRUE)
				THEN
/* Bug No : 6341012. R12 Uptake. p_sob_id,p_org_id are changed to l_sob_id,l_org_id */
					l_lock_cc_po := lock_cc_po(l_sob_id,l_org_id,l_cc_header_id,l_request_id1);
				END IF;

				IF (l_lock_cc_po = FALSE)
				THEN
					COMMIT;
					EXIT;
				END IF;


			END IF;

		END LOOP;
		CLOSE c_reval_data;

	END IF;

	/* End Lock CC and PO */

	IF (p_process_phase = 'P') OR ( (p_process_phase = 'F' AND l_lock_cc_po = TRUE))
	THEN


	/* Functional Currency Cover */
	IF (l_currency_code = l_cover_currency_code)
	THEN
		/* Validate all functional currency covers for available amount  */
		OPEN c_cover_reval_data(l_request_id1);
		LOOP

			FETCH c_cover_reval_data INTO l_cc_header_id;
			EXIT WHEN c_cover_reval_data%NOTFOUND;

			/* Get Contract Details */
			SELECT *
			INTO l_cc_headers_rec
			FROM igc_cc_headers
			WHERE cc_header_id = l_cc_header_id;

			OPEN c_acct_lines(l_cc_header_id);
			LOOP
				FETCH c_acct_lines INTO l_cc_acct_lines_rec;
				EXIT WHEN c_acct_lines%NOTFOUND;

				l_cover_acct_func_amt      := 0;
				l_non_reval_acct_amt_total := 0;
				l_reval_acct_amt_total     := 0;

				BEGIN
					SELECT NVL(SUM(NVL(CC_ACCT_FUNC_AMT,0)),0)
					INTO   l_non_reval_acct_amt_total
					FROM   igc_cc_acct_lines a,
			       	       	       igc_cc_headers b
			        	WHERE  NVL(parent_acct_line_id,0) = l_cc_acct_lines_rec.cc_acct_line_id AND
			               	       a.cc_header_id             = b.cc_header_id AND
                                               NVL(b.parent_header_id,0)  = l_cc_header_id AND
				               b.cc_header_id             <> p_cc_header_id;
				EXCEPTION
					WHEN NO_DATA_FOUND
					THEN
						l_non_reval_acct_amt_total := 0;
				END;

				BEGIN

					SELECT SUM(
						NVL(a.cc_acct_func_amt,0) +
                                      	        ( ( ( a.cc_acct_entered_amt -
                                                      --a.cc_acct_billed_amt)
                                                      IGC_CC_COMP_AMT_PKG.COMPUTE_ACCT_BILLED_AMT( a.cc_acct_line_id))
                                                     * b.conversion_rate
                                                   )
                                                   -
                                                   (a.cc_acct_func_amt -
                                                    -- a.cc_acct_func_billed_amt)
                                                    IGC_CC_COMP_AMT_PKG.COMPUTE_ACCT_FUNC_BILLED_AMT( a.cc_acct_line_id))
                                                )
					       )
					INTO   l_reval_acct_amt_total
					FROM   igc_cc_acct_lines a,
			       	       	       igc_cc_headers b
			        	WHERE  NVL(parent_acct_line_id,0) = l_cc_acct_lines_rec.cc_acct_line_id AND
			                       a.cc_header_id      = b.cc_header_id AND
				               b.cc_header_id      = p_cc_header_id;
				EXCEPTION
					WHEN NO_DATA_FOUND
					THEN
						l_reval_acct_amt_total := 0;
				END;

				l_cover_acct_func_amt := l_cc_acct_lines_rec.cc_acct_func_amt;

				IF (l_non_reval_acct_amt_total + l_reval_acct_amt_total)
		            	>  (l_cover_acct_func_amt)
				THEN
					populate_errors(l_cc_headers_rec.cc_header_id,
                               		                 p_process_phase,
/* Bug No : 6341012. R12 Uptake. p_sob_id,p_org_id are changed to l_sob_id,l_org_id */
		                                	 l_sob_id,
		                                         l_org_id,
                                                         l_request_id1);
					EXIT;
				END IF;

				OPEN c_pf_lines(l_cc_acct_lines_rec.cc_acct_line_id);
				LOOP
					FETCH c_pf_lines INTO l_cc_pmt_fcst_rec;
					EXIT  WHEN c_pf_lines%NOTFOUND;

					l_non_reval_pf_amt_total := 0;
					l_reval_pf_amt_total     := 0;
					l_cover_pf_func_amt      := 0;


					BEGIN
						SELECT SUM(NVL(CC_DET_PF_FUNC_AMT,0))
						INTO   l_non_reval_pf_amt_total
						FROM   igc_cc_det_pf a,
					       	       igc_cc_acct_lines b,
			       	       	               igc_cc_headers c
			                	WHERE  NVL(a.parent_acct_line_id,0)   =
                                                       l_cc_acct_lines_rec.cc_acct_line_id AND
					               NVL(a.parent_det_pf_line_id,0) =
                                                       l_cc_pmt_fcst_rec.cc_det_pf_line_id AND
					       	       a.cc_acct_line_id          =   b.cc_acct_line_id AND
			                               b.cc_header_id             =   c.cc_header_id AND
                                                       NVL(c.parent_header_id,0)  =   l_cc_header_id AND
					               c.cc_header_id             <>   p_cc_header_id;
					EXCEPTION
						WHEN NO_DATA_FOUND
						THEN
							l_non_reval_pf_amt_total := 0;
					END;


					BEGIN
                                                -- Replaced view igc_cc_det_pf_v with
                                                -- igc_cc_det_pf
					        -- (a.cc_det_pf_func_amt - a.cc_det_pf_func_billed_amt)

						SELECT SUM( NVL(a.cc_det_pf_func_amt,0) +
                                      	                    ( ( ( a.cc_det_pf_entered_amt - IGC_CC_COMP_AMT_PKG.COMPUTE_PF_BILLED_AMT(a.cc_det_pf_line_id, a.cc_det_pf_line_num, a.cc_acct_line_id))
                                                                 * c.conversion_rate
                                                               )
                                                               -
                                                               (a.cc_det_pf_func_amt - IGC_CC_COMP_AMT_PKG.COMPUTE_PF_FUNC_BILLED_AMT(a.cc_det_pf_line_id,  a.cc_det_pf_line_num, a.cc_acct_line_id))
                                                             )
						            )
						INTO   l_reval_pf_amt_total
						FROM   igc_cc_det_pf a,
					        igc_cc_acct_lines b,
			       	       	        igc_cc_headers c
			                        WHERE  NVL(a.parent_acct_line_id,0)   =
                                                       l_cc_acct_lines_rec.cc_acct_line_id AND
					               NVL(a.parent_det_pf_line_id,0) =
                                                       l_cc_pmt_fcst_rec.cc_det_pf_line_id AND
					               a.cc_acct_line_id       = b.cc_acct_line_id AND
			                               b.cc_header_id          = c.cc_header_id AND
/* Bug No : 6341012. R12 Uptake. p_org_id is changed to l_org_id */
                                                       c.org_id                = l_org_id AND
					               c.cc_header_id          = p_cc_header_id;
					EXCEPTION
						WHEN NO_DATA_FOUND
						THEN
							l_reval_pf_amt_total := 0;
					END;

					l_cover_pf_func_amt := l_cc_pmt_fcst_rec.cc_det_pf_func_amt;

					IF (l_non_reval_pf_amt_total + l_reval_pf_amt_total)
				           > (l_cover_pf_func_amt)
					THEN
						/* Update validation_status to 'F' in temporary table for releases */

						populate_errors(l_cc_headers_rec.cc_header_id,
								p_process_phase,
/* Bug No : 6341012. R12 Uptake. p_sob_id,p_org_id are changed to l_sob_id,l_org_id */
			                                	l_sob_id,
			                                	l_org_id,
                                                        	l_request_id1);
						EXIT;
					END IF;

				END LOOP; /* payment forecast */

				CLOSE c_pf_lines;

			END LOOP; /* Account Lines */

			CLOSE c_acct_lines;

		END LOOP; /* Cover Contract Commitments */

		CLOSE c_cover_reval_data;

	END IF; /* Functional Currency Cover */


	/* Validate all contract commitments subject to correct revaluation varainces */

	OPEN c_reval_data(l_request_id1);
	LOOP
		FETCH  c_reval_data
		INTO   l_cc_header_id;

       		EXIT WHEN c_reval_data%NOTFOUND;

		/* Get Contract Details */
		SELECT *
		INTO l_cc_headers_rec
		FROM igc_cc_headers
		WHERE cc_header_id = l_cc_header_id;

		l_validation_status := 'P';

		/* Validate Contract Commitment */

		IF (l_cc_headers_rec.cc_type = 'C')
		THEN
			SELECT validation_status
			INTO   l_curr_validation_status
			FROM   igc_cc_process_data
			WHERE  cc_header_id = l_cc_header_id AND
                               request_id   = l_request_id1;
		END IF;



		l_validation_status := IGC_CC_REP_YEP_PVT.validate_cc(p_process_phase   => p_process_phase,
						                      p_process_type    => 'F',
			                                              p_cc_header_id    =>l_cc_header_id,
/* Bug No : 6341012. R12 Uptake. p_sob_id,p_org_id are changed to l_sob_id,l_org_id */
								      p_sob_id          => l_sob_id,
								      p_org_id          => l_org_id,
								      p_year            => NULL,
                                                                      p_prov_enc_on     => l_prov_enc_on,
                                                                      p_request_id      => l_request_id1);


		IF (l_cc_headers_rec.cc_type = 'C')
		THEN
			IF (l_curr_validation_status <> 'I')
			THEN
				l_validation_status := l_curr_validation_status;
			END IF;
		END IF;

		/* Preliminary phase */
		IF (p_process_phase = 'P')
		THEN
			/* Update validation status in temporary table*/


			BEGIN
				UPDATE igc_cc_process_data
				SET
					validation_status = l_validation_Status,
                               	 	processed         = 'Y'
				WHERE
                                        request_id        = l_request_id1 AND
					cc_header_id      = l_cc_header_id;
			EXCEPTION
				WHEN NO_DATA_FOUND
				THEN
					NULL;
			END;

			IF (l_cc_headers_rec.cc_type = 'C')
			THEN
				UPDATE igc_cc_process_data
				SET
					validation_status  = l_validation_Status,
                               	 	processed          = 'Y'
				WHERE
                                        request_id         = l_request_id1 AND
					cc_header_id      IN (SELECT cc_header_id
							      FROM igc_cc_headers
							      WHERE parent_header_id = l_cc_header_id);

			 END IF;

			 COMMIT;

		END IF; /* Preliminary Phase */

		/* Final phase */

		IF (p_process_phase = 'F')
		THEN
			/* Passed Validation */

			IF (l_validation_status = 'P')
			THEN
				/* Update validation status, store old status in temporary table */

				IF (l_cc_headers_rec.cc_type = 'C') OR (l_cc_headers_rec.cc_type = 'S')
				THEN
					BEGIN
						UPDATE igc_cc_process_data
						SET
							validation_status    = l_validation_Status,
							old_approval_status  = l_cc_headers_rec.cc_apprvl_status
						WHERE
                                                        request_id           = l_request_id1 AND
							cc_header_id         = l_cc_header_id;

					EXCEPTION
						WHEN NO_DATA_FOUND
						THEN
							NULL;
					END;
				END IF;

				IF (l_cc_headers_rec.cc_type = 'C') OR (l_cc_headers_rec.cc_type = 'S')
				THEN
					UPDATE   igc_cc_headers
					SET      cc_apprvl_status = 'IP'
					WHERE    cc_header_id     = l_cc_header_id;
				END IF;



				/* Added the following code for bug 1632984 */
				/* Change begin */

				IF (l_cc_headers_rec.cc_type = 'S')
				THEN

					l_po_count := 0;

					BEGIN
						SELECT count(po_header_id)
						INTO l_po_count
						FROM   po_headers_all
						WHERE  segment1         = l_cc_headers_rec.cc_num AND
                                       	                org_id           = l_cc_headers_rec.org_id AND
                                        	        type_lookup_code = 'STANDARD' ;
					EXCEPTION
						WHEN NO_DATA_FOUND
						THEN
							l_po_count := 0;
					END;

					IF (l_po_count = 1)
					THEN

						BEGIN
							UPDATE po_headers_all
							SET    approved_flag    = 'N'
							WHERE  segment1         = l_cc_headers_rec.cc_num AND
					       		       org_id           = l_cc_headers_rec.org_id AND
					       		       type_lookup_code = 'STANDARD'              AND
					               	       approved_flag    = 'Y';
						END;
					END IF;

				END IF;
				/* Change end */


				IF (l_cc_headers_rec.cc_type = 'C')
				THEN
					OPEN c_all_releases1(l_cc_header_id);
					LOOP
						FETCH c_all_releases1 INTO l_rel_cc_headers_rec;
						EXIT WHEN c_all_releases1%NOTFOUND;

						UPDATE igc_cc_process_data
						SET
							validation_status    = l_validation_Status,
							old_approval_status  = l_rel_cc_headers_rec.cc_apprvl_status
						WHERE   request_id           = l_request_id1 AND
							cc_header_id         = l_rel_cc_headers_rec.cc_header_id;

						UPDATE   igc_cc_headers
						SET      cc_apprvl_status = 'IP'
						WHERE    cc_header_id     = l_rel_cc_headers_rec.cc_header_id ;

						l_po_count := 0;


						BEGIN
							SELECT count(po_header_id)
							INTO l_po_count
							FROM   po_headers_all
							WHERE  segment1         = l_rel_cc_headers_rec.cc_num AND
                                       		                org_id           = l_rel_cc_headers_rec.org_id AND
                                               		        type_lookup_code = 'STANDARD' ;
						EXCEPTION
							WHEN NO_DATA_FOUND
							THEN
								l_po_count := 0;
						END;

						IF (l_po_count = 1)
						THEN

							BEGIN
								UPDATE po_headers_all
								SET    approved_flag    = 'N'
								WHERE  segment1         = l_rel_cc_headers_rec.cc_num AND
					       			       org_id           = l_rel_cc_headers_rec.org_id AND
					       			       type_lookup_code = 'STANDARD'               AND
                            /* Changed statement below from approved_flag = N to approved_flag = Y to fix bug 1632984 */
					       	        	       approved_flag    = 'Y';
							END;
						END IF;

					END LOOP;

					CLOSE c_all_releases1;
				END IF;


			ELSIF (l_validation_status = 'F') /* Failed Validation */
			THEN
				/* Update validation status, in temporary table*/

				IF (l_cc_headers_rec.cc_type = 'C') OR (l_cc_headers_rec.cc_type = 'S')
				THEN
					UPDATE igc_cc_process_data
					SET
						validation_status = l_validation_Status ,
                                		processed         = 'Y'
					WHERE   request_id        = l_request_id1 AND
						cc_header_id      = l_cc_header_id;
				END IF;

				IF (l_cc_headers_rec.cc_type = 'C')
				THEN
					UPDATE igc_cc_process_data
					SET
						validation_status  = l_validation_Status ,
                                		processed          = 'Y'
					WHERE   request_id         = l_request_id1 AND
						cc_header_id      IN (SELECT cc_header_id
								      FROM igc_cc_headers
								      WHERE parent_header_id = l_cc_header_id);
				END IF;

			END IF;

		END IF; /* Final Phase */

	END LOOP;

	CLOSE c_reval_data;
	COMMIT;

	/* End Validation Phase */

	/* Begin Reservation phase */
	IF (p_process_phase = 'F')
	THEN
		/* Perform Funds Reservation for Contract Commitments */


		SELECT *
		INTO l_cc_headers_rec
		FROM igc_cc_headers
		WHERE cc_header_id = p_cc_header_id;


		SELECT  validation_status
		INTO    l_validation_status
		FROM    igc_cc_process_data
	        WHERE   request_id     = l_request_id1 AND
			cc_header_id   = p_cc_header_id ;

		IF (l_validation_status = 'P')
		THEN

			l_reservation_status := 'P';

			/* Perform funds reservation in Forced mode for  Contract Commitment */

		         IF ( ( (l_cc_headers_rec.cc_state = 'CM')  OR (l_cc_headers_rec.cc_state = 'CT')
                               )
                  	       AND (l_sbc_on = TRUE)  AND (l_conf_enc_on = TRUE)
                             )
			 THEN

				IF ( ((l_cc_headers_rec.cc_type = 'R') AND (l_currency_code <> l_cover_currency_code) )
                                   OR
                       	           (l_cc_headers_rec.cc_type = 'S') )
		                THEN
					l_reservation_status :=
					IGC_CC_REP_YEP_PVT.Encumber_CC
				        (
  					p_process_type 			=> 'F',
  					p_cc_header_id 			=> p_cc_header_id,
  					p_sbc_on       			=> l_sbc_on,
  					p_cbc_on       			=> l_cbc_on,
/* Bug No : 6341012. SLA Uptake. Encumbrance Type IDs are not required */
  			--		p_cc_prov_enc_type_id 		=> l_cc_prov_enc_type_id,
  			--		p_cc_conf_enc_type_id 		=> l_cc_conf_enc_type_id,
                       	--		p_req_encumbrance_type_id 	=> l_req_encumbrance_type_id,
  			--		p_purch_encumbrance_type_id 	=> l_purch_encumbrance_type_id,
  					p_currency_code 		=> l_currency_code,
  					p_yr_start_date 		=> NULL,
  					p_yr_end_date 			=> NULL,
  					p_yr_end_cr_date                => NULL,
  					p_yr_end_dr_date                => NULL,
  					p_rate_date                     => NULL,
  					p_rate                          => NULL,
  					p_revalue_fix_date              => l_revalue_fix_date);
                                  END IF;
                        ELSE
                              l_reservation_status := 'P';
			END IF;


			IF (l_reservation_status = 'F')
			THEN
				l_message := NULL;
				FND_MESSAGE.SET_NAME('IGC','IGC_CC_ENCUMBRANCE_FAILURE');
                        	l_message  := FND_MESSAGE.GET;

				INSERT INTO
				igc_cc_process_exceptions
				(  process_type,
	 			   process_phase,
	 			   cc_header_id,
	 			   cc_acct_line_id,
	 			   cc_det_pf_line_id,
	 			   exception_reason,
	 			   org_id,
	 			   set_of_books_id,
                        	   request_id
                                )
                                VALUES
                                (  'F',
	 			   'F',
				   l_cc_headers_rec.parent_header_id,
				   NULL,
				   NULL,
				   l_message,
/* Bug No : 6341012. R12 Uptake. p_sob_id,p_org_id are changed to l_sob_id,l_org_id */
				   l_org_id,
				   l_sob_id,
                        	   l_request_id1
                                );

				COMMIT;
			END IF;

			/* Update validation status, in temporary table*/

			IF (l_cc_headers_rec.cc_type = 'S')
			THEN
				UPDATE igc_cc_process_data
				SET
					reservation_status  = l_reservation_Status
				WHERE
                       		 	request_id        = l_request_id1 AND
					cc_header_id      = p_cc_header_id ;
			END IF;

			IF (l_cc_headers_rec.cc_type = 'R')
			THEN
				/* Update Cover */
				UPDATE igc_cc_process_data
				SET
					reservation_status  = l_reservation_Status
				WHERE
                       		 	request_id        = l_request_id1 AND
					cc_header_id      = l_cc_headers_rec.parent_header_id ;

				/* Update Relases */
				UPDATE igc_cc_process_data
				SET
					reservation_status  = l_reservation_Status
				WHERE
                               	        request_id          = l_request_id1 AND
					cc_header_id      IN (SELECT cc_header_id
							      FROM igc_cc_headers
							      WHERE parent_header_id =
                                                                    l_cc_headers_rec.parent_header_id);
			END IF;

			COMMIT;

			/* Process Cover release */
			IF (l_cc_headers_rec.cc_type = 'R')
			THEN
				SAVEPOINT REVALUE5;

				l_process_flag := 'P';

				/* Process the cover */

				l_validate_only := 'Y';

				SELECT validate_only
				INTO   l_validate_only
				FROM   igc_cc_process_data
				WHERE  request_id    = l_request_id1 AND
			       	       cc_header_id  = l_cc_headers_rec.parent_header_id;


				IF (l_reservation_status = 'P')
				THEN


					l_message := NULL;
					l_err_header_id := NULL;
					l_err_acct_line_id := NULL;
				        l_err_det_pf_line_id := NULL;

					l_process_flag := reval_fix_update(l_cc_headers_rec.parent_header_id,
                                                                           p_cc_header_id,
		      			                                   l_revalue_fix_date,
/* Bug No : 6341012. R12 Uptake. p_sob_id,p_org_id are changed to l_sob_id,l_org_id */
		      			                                   l_sob_id,
		      			                                   l_org_id,
			   						   l_sbc_on,
			   						   l_cbc_on,
			   						   l_prov_enc_on,
			   						   l_conf_enc_on,
                               	                                           l_validate_only,
                                                       	                   l_request_id1,
                                                                           l_message,
                                                                           l_err_header_id,
                                                                           l_err_acct_line_id,
                                                                           l_err_det_pf_line_id);
					IF  (l_process_flag = 'F')
					THEN
						ROLLBACK TO REVALUE5;

                                		INSERT INTO IGC_CC_PROCESS_EXCEPTIONS
							(PROCESS_TYPE,
							PROCESS_PHASE,
							CC_HEADER_ID,
							CC_ACCT_LINE_ID,
							CC_DET_PF_LINE_ID,
							EXCEPTION_REASON,
							ORG_ID,
							SET_OF_BOOKS_ID,
							REQUEST_ID)
							VALUES (
                                                              'F',
                                                              'F',
                                                              l_err_header_id,
                                                              l_err_acct_line_id,
                                                              l_err_det_pf_line_id,
                                                              l_message,
/* Bug No : 6341012. R12 Uptake. p_sob_id,p_org_id are changed to l_sob_id,l_org_id */
                                                              l_org_id,
                                                              l_sob_id,
                                                              l_REQUEST_ID1);
						COMMIT;
					END IF;

				ELSIF (l_reservation_status = 'F')
				THEN

					l_message := NULL;
					l_err_header_id := NULL;
					l_err_acct_line_id := NULL;
				        l_err_det_pf_line_id := NULL;

					l_process_flag := reval_fix_update(l_cc_headers_rec.parent_header_id,
                                                                           NULL,
		      			                                   l_revalue_fix_date,
/* Bug No : 6341012. R12 Uptake. p_sob_id,p_org_id are changed to l_sob_id,l_org_id */
		      			                                   l_sob_id,
		      			                                   l_org_id,
			   						   l_sbc_on,
			   						   l_cbc_on,
			   						   l_prov_enc_on,
			   						   l_conf_enc_on,
                               	                                           'Y',
                                                       	                   l_request_id1,
                                                                           l_message,
                                                                           l_err_header_id,
                                                                           l_err_acct_line_id,
                                                                           l_err_det_pf_line_id);


					IF  (l_process_flag = 'F')
					THEN
						ROLLBACK TO REVALUE5;

                                		INSERT INTO IGC_CC_PROCESS_EXCEPTIONS
							(PROCESS_TYPE,
							PROCESS_PHASE,
							CC_HEADER_ID,
							CC_ACCT_LINE_ID,
							CC_DET_PF_LINE_ID,
							EXCEPTION_REASON,
							ORG_ID,
							SET_OF_BOOKS_ID,
							REQUEST_ID)
							VALUES (
                                                              'F',
                                                              'F',
                                                              l_err_header_id,
                                                              l_err_acct_line_id,
                                                              l_err_det_pf_line_id,
                                                              l_message,
/* Bug No : 6341012. R12 Uptake. p_sob_id,p_org_id are changed to l_sob_id,l_org_id */
                                                              l_org_id,
                                                              l_sob_id,
                                                              l_REQUEST_ID1);
						COMMIT;
					END IF;

				END IF; /* Reservation status */


				/* Process the releases */
				IF (l_process_flag = 'P')
				THEN
					OPEN c_all_releases(l_cc_headers_rec.parent_header_id);
					LOOP
						FETCH c_all_releases INTO l_rel_cc_header_id;
						EXIT WHEN c_all_releases%NOTFOUND;


						l_validate_only := 'Y';

						SELECT validate_only
						INTO   l_validate_only
						FROM   igc_cc_process_data
						WHERE  request_id    = l_request_id1 AND
			       			       cc_header_id  = l_rel_cc_header_id;


						IF (l_reservation_status = 'P')
						THEN


							l_message := NULL;
							l_err_header_id := NULL;
							l_err_acct_line_id := NULL;
						        l_err_det_pf_line_id := NULL;

							l_process_flag := reval_fix_update(l_rel_cc_header_id,
                                                                                           NULL,
			      				                                   l_revalue_fix_date,
/* Bug No : 6341012. R12 Uptake. p_sob_id,p_org_id are changed to l_sob_id,l_org_id */
			      				                                   l_sob_id,
			      				                                   l_org_id,
			   						   		   l_sbc_on,
			   						                   l_cbc_on,
			   						                   l_prov_enc_on,
			   						                   l_conf_enc_on,
       	                        	                                                   l_validate_only,
       	                                        	                                   l_request_id1,
                                                                                           l_message,
                                                                                           l_err_header_id,
                                                                                           l_err_acct_line_id,
                                                                                           l_err_det_pf_line_id);
						ELSIF (l_reservation_status = 'F')
						THEN


							l_message := NULL;
							l_err_header_id := NULL;
							l_err_acct_line_id := NULL;
						        l_err_det_pf_line_id := NULL;

							l_process_flag := reval_fix_update(l_rel_cc_header_id,
                                                                                           NULL,
			      				                                   l_revalue_fix_date,
/* Bug No : 6341012. R12 Uptake. p_sob_id,p_org_id are changed to l_sob_id,l_org_id */
			      				                                   l_sob_id,
			      				                                   l_org_id,
			   						   		   l_sbc_on,
			   						                   l_cbc_on,
			   						                   l_prov_enc_on,
			   						                   l_conf_enc_on,
       	                        	                                                   'Y',
       	                                        	                                   l_request_id1,
                                                                                           l_message,
                                                                                           l_err_header_id,
                                                                                           l_err_acct_line_id,
                                                                                           l_err_det_pf_line_id);
						END IF;

						IF  (l_process_flag = 'F')
						THEN
							/* Rollback changes to contract commitments */
							ROLLBACK TO REVALUE5;

							/* Populate exceptions table */

							INSERT INTO IGC_CC_PROCESS_EXCEPTIONS
							(PROCESS_TYPE,
							PROCESS_PHASE,
							CC_HEADER_ID,
							CC_ACCT_LINE_ID,
							CC_DET_PF_LINE_ID,
							EXCEPTION_REASON,
							ORG_ID,
							SET_OF_BOOKS_ID,
							REQUEST_ID)
							VALUES (
                                                              'F',
                                                              'F',
                                                              l_err_header_id,
                                                              l_err_acct_line_id,
                                                              l_err_det_pf_line_id,
                                                              l_message,
/* Bug No : 6341012. R12 Uptake. p_sob_id,p_org_id are changed to l_sob_id,l_org_id */
                                                              l_org_id,
                                                              l_sob_id,
                                                              l_REQUEST_ID1);

					                COMMIT;

							EXIT;
						END IF;

					END LOOP;

					CLOSE c_all_releases;

				END IF;

				IF  (l_process_flag = 'P')
				THEN
					COMMIT;
				END IF;


			ELSIF (l_cc_headers_rec.cc_type = 'S')
			THEN
				SAVEPOINT REVALUE6;

				l_process_flag := 'F';


				IF (l_reservation_status = 'P')
				THEN


					l_message := NULL;
					l_err_header_id := NULL;
					l_err_acct_line_id := NULL;
				        l_err_det_pf_line_id := NULL;

					l_process_flag := reval_fix_update(l_cc_headers_rec.cc_header_id,
                                                                           NULL,
		      					                   l_revalue_fix_date,
/* Bug No : 6341012. R12 Uptake. p_sob_id,p_org_id are changed to l_sob_id,l_org_id */
		      					                   l_sob_id,
		      					                   l_org_id,
			   						   l_sbc_on,
			   						   l_cbc_on,
			   						   l_prov_enc_on,
			   						   l_conf_enc_on,
                               	       	                                   'N',
                               		     	                           l_request_id1,
                                                                           l_message,
                                                                           l_err_header_id,
                                                                           l_err_acct_line_id,
                                                                           l_err_det_pf_line_id);
					IF  (l_process_flag = 'F')
					THEN
						ROLLBACK TO REVALUE6;

						/* Populate exceptions table */

						INSERT INTO IGC_CC_PROCESS_EXCEPTIONS
							(PROCESS_TYPE,
							PROCESS_PHASE,
							CC_HEADER_ID,
							CC_ACCT_LINE_ID,
							CC_DET_PF_LINE_ID,
							EXCEPTION_REASON,
							ORG_ID,
							SET_OF_BOOKS_ID,
							REQUEST_ID)
							VALUES (
                                                              'F',
                                                              'F',
                                                              l_err_header_id,
                                                              l_err_acct_line_id,
                                                              l_err_det_pf_line_id,
                                                              l_message,
/* Bug No : 6341012. R12 Uptake. p_sob_id,p_org_id are changed to l_sob_id,l_org_id */
                                                              l_org_id,
                                                              l_org_id,
                                                              l_REQUEST_ID1);

						COMMIT;

					END IF;
				ELSIF (l_reservation_status = 'F')
				THEN


					l_message := NULL;
					l_err_header_id := NULL;
					l_err_acct_line_id := NULL;
				        l_err_det_pf_line_id := NULL;

					l_process_flag := reval_fix_update(l_cc_headers_rec.cc_header_id,
                                                                           NULL,
		      					                   l_revalue_fix_date,
/* Bug No : 6341012. R12 Uptake. p_sob_id,p_org_id are changed to l_sob_id,l_org_id */
		      					                   l_sob_id,
		      					                   l_org_id,
			   						   l_sbc_on,
			   						   l_cbc_on,
			   						   l_prov_enc_on,
			   						   l_conf_enc_on,
                               	       	                                   'Y',
                               		     	                           l_request_id1,
                                                                           l_message,
                                                                           l_err_header_id,
                                                                           l_err_acct_line_id,
                                                                           l_err_det_pf_line_id);


					IF  (l_process_flag = 'F')
					THEN
						ROLLBACK TO REVALUE6;

						/* Populate exceptions table */

						INSERT INTO IGC_CC_PROCESS_EXCEPTIONS
							(PROCESS_TYPE,
							PROCESS_PHASE,
							CC_HEADER_ID,
							CC_ACCT_LINE_ID,
							CC_DET_PF_LINE_ID,
							EXCEPTION_REASON,
							ORG_ID,
							SET_OF_BOOKS_ID,
							REQUEST_ID)
							VALUES (
                                                              'F',
                                                              'F',
                                                              l_err_header_id,
                                                              l_err_acct_line_id,
                                                              l_err_det_pf_line_id,
                                                              l_message,
/* Bug No : 6341012. R12 Uptake. p_sob_id,p_org_id are changed to l_sob_id,l_org_id */
                                                              l_org_id,
                                                              l_sob_id,
                                                              l_REQUEST_ID1);

						COMMIT;

					END IF;

				END IF;  /* reservation status = F */

				IF  (l_process_flag = 'P')
				THEN
					COMMIT;
				END IF;

			END IF;   /* cc_type = STANDARD */
		END IF; /* validation_status = P */

	END IF; /* Final Phase */
		/* End Reservation Phase */

	END IF;

	COMMIT;

/*Bug No : 6341012. MOAC Uptake. Need to set org_id before submiting a request*/
        Fnd_request.set_org_id(l_org_id);
	l_request_id2 := FND_REQUEST.SUBMIT_REQUEST(
                        	                   'IGC',
                               		            'IGCCRVFR',
                                       		    NULL,
                                            	    NULL,
                                            	    FALSE,
/* Bug No : 6341012. R12 Uptake. p_sob_id,p_org_id are changed to l_sob_id,l_org_id */
                                            	    l_sob_id,
                                                    l_org_id,
                                                    p_process_phase,
                                                    'F',
                                                    l_request_id1);
-----------------------
-- Start of XML Report
-----------------------
         IF IGC_CC_COMMON_UTILS_PVT.xml_report_enabled THEN
               IGC_CC_COMMON_UTILS_PVT.get_xml_layout_info(
                                            l_lang,
                                            l_terr,
                                            'IGCCRVFR_XML',
                                            'IGC',
                                            'IGCCRVFR_XML' );
               l_layout :=  FND_REQUEST.ADD_LAYOUT(
                                             'IGC',
                                            'IGCCRVFR_XML',
                                            l_lang,
                                            l_terr,
                                            'RTF');
               IF l_layout then
                   l_request_id2 := FND_REQUEST.SUBMIT_REQUEST(
                                'IGC',
               	                'IGCCRVFR_XML',
                                NULL,
                                NULL,
                                FALSE,
  /* Bug No : 6341012. R12 Uptake. p_sob_id,p_org_id are changed to l_sob_id,l_org_id */
                                l_sob_id,
                                l_org_id,
                                p_process_phase,
                                'F',
                                l_request_id1);
              END IF;
         END IF;

--------------------
-- End of XML Report
--------------------
-- ------------------------------------------------------------------------------------
-- Ensure that any exceptions raised are output into the log file to be reported to
-- the user if any are present.
-- ------------------------------------------------------------------------------------
   FND_MSG_PUB.Count_And_Get ( p_count => l_msg_count,
                               p_data  => l_msg_data );

   IF (l_msg_count > 0) THEN
      l_error_text := '';
      FOR l_cur IN 1..l_msg_count LOOP
          l_error_text := ' Mesg No : '|| l_cur ||' '|| FND_MSG_PUB.GET(l_cur, FND_API.G_FALSE);
--          fnd_file.put_line (FND_FILE.LOG,
--                             l_error_text);
       -- bug 3199488 start block
       IF (l_state_level >= l_debug_level) THEN
           FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_reval_fix_process_pkg.revalue_fix_main.Excp3',
                                          l_error_text);
       END IF;
       -- bug 3199488, end block
      END LOOP;
   END IF;

EXCEPTION

	WHEN insert_data
	THEN
                IF (FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
                   FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, 'revalue_fix_main');
                END IF;
                -- bug 3199488 start block
                IF (l_unexp_level >= l_debug_level) THEN
                     FND_LOG.MESSAGE(l_unexp_level, 'igc.plsql.igc_cc_reval_fix_process_pkg.revalue_fix_main.Unexp1',TRUE);
                END IF;
                -- bug 3199488, end block
                FND_MSG_PUB.Count_And_Get ( p_count => l_msg_count,
                                            p_data  => l_msg_data );

                IF (l_msg_count > 0) THEN

                   l_error_text := '';
                   FOR l_cur IN 1..l_msg_count LOOP
                       l_error_text := ' Mesg No : '|| l_cur ||' '|| FND_MSG_PUB.GET(l_cur, FND_API.G_FALSE);
--                       fnd_file.put_line (FND_FILE.LOG,
--                                          l_error_text);
                        -- bug 3199488 start block
                        IF (l_state_level >= l_debug_level) THEN
                            FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_reval_fix_process_pkg.revalue_fix_main.Excp4',
                                                          l_error_text);
                        END IF;
                        -- bug 3199488, end block
                   END LOOP;
                ELSE
                   l_error_text := 'Error Returned but Error stack has no data';
--                   fnd_file.put_line (FND_FILE.LOG,
--                                      l_error_text);
                   -- bug 3199488 start block
                   IF (l_state_level >= l_debug_level) THEN
                       FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_reval_fix_process_pkg.revalue_fix_main.Excp5',
                                                      l_error_text);
                   END IF;
                   -- bug 3199488, end block
                END IF;
		ROLLBACK TO REVALUE3;

        WHEN OTHERS THEN
                IF (FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
                   FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, 'revalue_fix_main');
                END IF;
                -- bug 3199488, start block
                IF (l_unexp_level >= l_debug_level) THEN
                    FND_MESSAGE.SET_NAME('IGC','IGC_LOGGING_UNEXP_ERROR');
                    FND_MESSAGE.SET_TOKEN('CODE',sqlcode);
                    FND_MESSAGE.SET_TOKEN('MSG',sqlerrm);
                    FND_LOG.MESSAGE(l_unexp_level, 'igc.plsql.igc_cc_reval_fix_process_pkg.revalue_fix_main.Unexp2',TRUE);
                END IF;
                -- bug 3199488, end block

                FND_MSG_PUB.Count_And_Get ( p_count => l_msg_count,
                                            p_data  => l_msg_data );

                IF (l_msg_count > 0) THEN

                   l_error_text := '';
                   FOR l_cur IN 1..l_msg_count LOOP
                       l_error_text := ' Mesg No : '|| l_cur ||' '|| FND_MSG_PUB.GET(l_cur, FND_API.G_FALSE);
--                       fnd_file.put_line (FND_FILE.LOG,
--                                          l_error_text);
                     -- bug 3199488 start block
                     IF (l_state_level >= l_debug_level) THEN
                         FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_reval_fix_process_pkg.revalue_fix_main.Excp6',
                                                        l_error_text);
                     END IF;
                     -- bug 3199488, end block
                   END LOOP;
                ELSE
                   l_error_text := 'Error Returned but Error stack has no data';
--                   fnd_file.put_line (FND_FILE.LOG,
--                                      l_error_text);
                   -- bug 3199488 start block
                   IF (l_state_level >= l_debug_level) THEN
                       FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_reval_fix_process_pkg.revalue_fix_main.Excp7',
                                                      l_error_text);
                   END IF;
                   -- bug 3199488, end block
                END IF;

END revalue_fix_main;

END IGC_CC_REVAL_FIX_PROCESS_PKG;

/

--------------------------------------------------------
--  DDL for Package Body IGC_CC_REVALUE_PROCESS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGC_CC_REVALUE_PROCESS_PKG" AS
/*$Header: IGCCREPB.pls 120.21.12010000.2 2008/08/29 13:16:25 schakkin ship $*/

  --Bug 3199488 Start Block
    l_debug_level number;

    l_state_level number;
    l_proc_level number;
    l_event_level number;
    l_excep_level number;
    l_error_level number;
    l_unexp_level number;
  --Bug 3199488 End Block

  G_PKG_NAME CONSTANT VARCHAR2(30):= 'IGC_CC_REVALUE_PROCESS_PKG';
  l_debug_mode        VARCHAR2(1);

  -- The flag determines whether to print debug information or not.
  g_debug_flag        VARCHAR2(1);
  g_debug_msg         VARCHAR2(10000);

--
-- Generic Procedure for putting out debug information
--
/* Commented out as per bug 3199488
PROCEDURE Output_Debug (
   p_debug_msg        IN VARCHAR2
);


/* Checks whether all the invoices related to
Contract Commitment are either approved or cancelled */

FUNCTION validate_params(p_process_phase      IN VARCHAR2,
			 p_sob_id             IN NUMBER,
			 p_org_id             IN NUMBER,
                         p_currency_code      IN VARCHAR2,
                         p_func_currency_code IN VARCHAR2,
			 p_rate_type          IN VARCHAR2,
		         p_rate               IN NUMBER,
                         p_rate_date          IN DATE,
                         p_request_id         IN NUMBER)
RETURN BOOLEAN
IS
	l_period_status gl_period_statuses.closing_status%TYPE;
	l_cc_period_status igc_cc_periods.cc_period_status%TYPE;
	l_rate  NUMBER;
	l_message igc_cc_process_exceptions.exception_reason%TYPE;
BEGIN

--        IF l_debug_mode = 'Y' THEN
--           Output_Debug (' IGCCREPB -- Validate Params begins ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
--        END IF;

        -- bug 3199488, start block
        IF (l_state_level >= l_debug_level) THEN
            FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_revalue_process_pkg.validate_params.Msg1',
                                          ' IGCCREPB -- Validate Params begins ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
        END IF;
        -- bug 3199488, end block

		IF (p_rate_type <> 'User') AND (p_rate > 0)
		THEN
			l_rate := 0;

			BEGIN

				SELECT conversion_rate
                        	INTO   l_rate
                                FROM   gl_daily_rates
				WHERE from_currency      = p_currency_code            AND
                              	      to_currency        = p_func_currency_code       AND
                                      conversion_type    = p_rate_type                AND
                                      conversion_date    = p_rate_date;

                                -- If length of rate is greater than 38
                                -- round it off to 30
                                -- as that is the maximum precision of p_rate
                                -- the input parameter)
                                -- Bug 1808755, Bidisha S, 13 July 01
                                IF LENGTH(l_rate) > 38
                                THEN
                                    l_rate := ROUND(l_rate, 30);
                                END IF;
			EXCEPTION
				WHEN NO_DATA_FOUND
				THEN
					l_rate := 0;
			END;

		END IF;

		/* Check the rate */
		IF (NVL(p_rate,-9999) <= 0)  OR (p_rate IS NULL)
		OR
                    ( (p_rate > 0) AND (p_rate_type <> 'User')
                AND (l_rate <> p_rate))
		THEN
			l_message := NULL;
			FND_MESSAGE.SET_NAME('IGC','IGC_CC_INVALID_RATE');
                        FND_MESSAGE.SET_TOKEN('RATE',TO_CHAR(p_rate),TRUE);
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
                        (  'R',
	 		   p_process_phase,
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

		l_period_status := NULL;

		IF (p_rate_date IS NOT NULL)
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
                                        /* begin fix for bug 1569051*/
                                        gp.adjustment_period_flag = 'N' AND
                                        /* end fix for bug 1569051*/
					gpt.period_type           = gp.period_type AND
					gps.set_of_books_id       = gb.set_of_books_id AND
					gps.period_name           = gp.period_name AND
					gps.application_id        = fa.application_id AND
				        fa.application_short_name = 'SQLGL' AND
					(gp.start_date <= p_rate_date AND gp.end_date >= p_rate_date);
			EXCEPTION
				WHEN NO_DATA_FOUND
				THEN
					NULL;

			END;
		END IF;

		IF (l_period_status IS NULL) OR ( NVL(l_period_status,'X') <> 'O') OR (p_rate_date IS NULL)
		THEN
			l_message := NULL;
			FND_MESSAGE.SET_NAME('IGC','IGC_CC_REVALUATION_DATE');
                        FND_MESSAGE.SET_TOKEN('DATE',to_char(p_rate_date ,'DD-MON-YYYY') ,TRUE);
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
                        (  'R',
	 		   p_process_phase,
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
		       		(gp.start_date <= p_rate_date AND gp.end_date >= p_rate_date);
		EXCEPTION
			WHEN NO_DATA_FOUND
			THEN
				RETURN(FALSE);
		END;

		IF (l_cc_period_status IS NULL) OR (NVL(l_cc_period_status,'X') <> 'O')
		THEN
			l_message := NULL;
			FND_MESSAGE.SET_NAME('IGC','IGC_CC_REVALUATION_DATE');
                        FND_MESSAGE.SET_TOKEN('DATE',to_char(p_rate_date ,'DD-MON-YYYY') ,TRUE);
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
                        (  'R',
	 		   p_process_phase,
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

--        IF l_debug_mode = 'Y' THEN
--           Output_Debug (' IGCCREPB -- Validate Params ends ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
--        END IF;

        -- bug 3199488, start block
        IF (l_state_level >= l_debug_level) THEN
            FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_revalue_process_pkg.validate_params.Msg2',
                                          ' IGCCREPB -- Validate Params ends ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
        END IF;
        -- bug 3199488, end block

	RETURN(TRUE);

END validate_params;

FUNCTION lock_cc_po(p_sob_id       IN NUMBER,
		    p_org_id       IN NUMBER,
                    p_cc_header_id IN NUMBER,
                    p_request_id   IN NUMBER)
RETURN BOOLEAN
IS
	l_lock_cc  BOOLEAN;
	l_lock_po  BOOLEAN;
	l_message  igc_cc_process_exceptions.exception_reason%TYPE;
	l_cc_num   igc_cc_headers.cc_num%TYPE;
BEGIN

--GSCC Warnings Fixed

	l_lock_cc  := TRUE;
	l_lock_po  := TRUE;

--        IF l_debug_mode = 'Y' THEN
--           Output_Debug (' IGCCREPB -- Lock CC PO Begins ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
--        END IF;

        -- bug 3199488, start block
        IF (l_state_level >= l_debug_level) THEN
            FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_revalue_process_pkg.lock_cc_po.Msg1',
                                          ' IGCCREPB -- Lock CC PO Begins ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
        END IF;
        -- bug 3199488, end block

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
                (  'R',
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
                (  'R',
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

--        IF l_debug_mode = 'Y' THEN
--           Output_Debug (' IGCCREPB -- Lock CC PO Ends ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
--        END IF;

        -- bug 3199488, start block
        IF (l_state_level >= l_debug_level) THEN
            FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_revalue_process_pkg.lock_cc_po.Msg2',
                                          ' IGCCREPB -- Lock CC PO Ends ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
        END IF;
        -- bug 3199488, end block

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

FUNCTION reval_update(p_cc_header_id        IN NUMBER,
		      p_rate_date           IN DATE,
		      p_rate                IN NUMBER,
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
                /*
		SELECT *
		FROM   igc_cc_acct_lines_v
		WHERE  cc_header_id = p_cc_header_id;
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
                       NULL tax_id, -- Bug 6472296 Ebtax uptake for cc
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
		       ccal.tax_classif_code -- added Bug 6472296 Ebtax uptake for cc
                FROM igc_cc_acct_lines ccal
		WHERE  ccal.cc_header_id = p_cc_header_id;

	CURSOR c_pf_lines(p_cc_acct_line_id NUMBER)
	IS
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
        FROM   igc_cc_det_pf ccdpf
	WHERE  cc_acct_line_id = p_cc_acct_line_id
	AND    ccdpf.cc_det_pf_entered_amt <> IGC_CC_COMP_AMT_PKG.COMPUTE_PF_BILLED_AMT(ccdpf.cc_det_pf_line_id,ccdpf.cc_det_pf_line_num,
																				ccdpf.cc_acct_line_id); -- Bug 3856265

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
	l_init_msg_list            VARCHAR2(1);
	l_commit                   VARCHAR2(1);
	l_validation_level         NUMBER;
	l_return_status            VARCHAR2(1);
	l_msg_count                NUMBER;
	l_msg_data                 VARCHAR2(2000);
	G_FLAG                     VARCHAR2(1);

	l_approval_status         igc_cc_process_data.old_approval_status%TYPE;

        l_Last_Updated_By         NUMBER;
        l_Last_Update_Login       NUMBER;
        l_Created_By              NUMBER;

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

-- bug 2043221 ssmales - added two variable declarations below
        l_new_cc_func_withheld_amt  igc_cc_acct_lines.cc_func_withheld_amt%TYPE;
        l_cc_func_withheld_amt      igc_cc_acct_lines.cc_func_withheld_amt%TYPE;


BEGIN

--GSCC Warnings Fixed

	l_init_msg_list           := FND_API.G_FALSE;
	l_commit                  := FND_API.G_FALSE;
	l_validation_level        := FND_API.G_VALID_LEVEL_FULL;
        l_Last_Updated_By         := FND_GLOBAL.USER_ID;
        l_Last_Update_Login       := FND_GLOBAL.LOGIN_ID;
        l_Created_By              := FND_GLOBAL.USER_ID;

--        IF l_debug_mode = 'Y' THEN
--           Output_Debug (' IGCCREPB -- Reval Update Begins ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
--        END IF;

        -- bug 3199488, start block
        IF (l_state_level >= l_debug_level) THEN
            FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_revalue_process_pkg.reval_update.Msg1',
                                          ' IGCCREPB -- Reval Update Begins ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
        END IF;
        -- bug 3199488, end block

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
--bug 4137743 changed the position
                                             l_cc_headers_rec.CONTEXT,
-- bug 2043221 ssmales - added Guarantee Flag argument in line below
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

--                IF l_debug_mode = 'Y' THEN
--                Output_Debug (' IGCCREPB -- Reval Update Ends 9 ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
--                END IF;

                -- bug 3199488, start block
                IF (l_state_level >= l_debug_level) THEN
                    FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_revalue_process_pkg.reval_update.Msg2',
                                                  ' IGCCREPB -- Reval Update Ends 9 ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
                END IF;
                -- bug 3199488, end block

		RETURN 'F';

	END IF;

	OPEN c_acct_lines(l_cc_headers_rec.cc_header_id);
	LOOP
		FETCH c_acct_lines INTO l_cc_acct_lines_rec;
		EXIT WHEN c_acct_lines%NOTFOUND;

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
-- bug 2043221 ssmales - added argument for Ent Withheld and Func Withheld amts in 2 lines below
                       l_cc_acct_lines_rec.CC_Func_Withheld_Amt,
                       l_cc_acct_lines_rec.CC_Ent_Withheld_Amt,
                       G_FLAG,
		       l_cc_acct_lines_rec.tax_classif_code -- added for Bug 6472296 Ebtax uptake for cc
		       );

		IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)
		THEN
			l_EXCEPTION := NULL;
                        FND_MESSAGE.SET_NAME('IGC','IGC_CC_YEP_ACT_LINE_HST_INSERT');
                	l_EXCEPTION := FND_MESSAGE.GET;
                        p_message   := l_exception;
                        p_err_header_id := l_cc_headers_rec.cc_header_id;
                        p_err_acct_line_id := NULL;
                        p_err_det_pf_line_id := NULL;

--        IF l_debug_mode = 'Y' THEN
--           Output_Debug (' IGCCREPB -- Reval Update Ends 8 ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
--        END IF;

        -- bug 3199488, start block
        IF (l_state_level >= l_debug_level) THEN
            FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_revalue_process_pkg.reval_update.Msg3',
                                          ' IGCCREPB -- Reval Update Ends 8 ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
        END IF;
        -- bug 3199488, end block

		         RETURN 'F';
		END IF;

		l_new_cc_acct_func_amt := 0;

		l_new_cc_acct_func_amt :=
		       			l_cc_acct_lines_rec.cc_acct_func_amt +
			                  (   ( (l_cc_acct_lines_rec.cc_acct_func_amt -
			                          l_cc_acct_lines_rec.cc_acct_func_billed_amt) /  l_cc_headers_rec.conversion_rate
                                               ) * (p_rate - l_cc_headers_rec.conversion_rate)
					   );

		l_cc_acct_func_amt      := l_new_cc_acct_func_amt;

-- bug 2043221 ssmales - start block

                l_new_cc_func_withheld_amt := 0;
                l_new_cc_func_withheld_amt := (l_cc_acct_lines_rec.cc_func_withheld_amt * p_rate) / l_cc_headers_rec.conversion_rate;
                l_cc_func_withheld_amt     := l_new_cc_func_withheld_amt;

-- bug 2043221 ssmales - end block


		/* Update cc_acct_encmbrnc_date,cc_acct_encmbrnc_amt depending on budgetary control set up */

		IF ( ( (l_cc_headers_rec.cc_state = 'PR')  OR (l_cc_headers_rec.cc_state = 'CL') )
                     AND (p_cbc_on = TRUE) AND (p_prov_enc_on = TRUE)
                   ) OR
		  ( ( (l_cc_headers_rec.cc_state = 'CM')  OR (l_cc_headers_rec.cc_state = 'CT') )
                     AND (p_cbc_on = TRUE)  AND (p_conf_enc_on = TRUE)
                   )
		THEN
                	l_cc_acct_encmbrnc_date := p_rate_date;
                	l_cc_acct_encmbrnc_amt  := (l_cc_acct_lines_rec.cc_acct_entered_amt * p_rate);
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
                       l_cc_acct_encmbrnc_amt,
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
                       l_cc_func_withheld_amt,
                       l_cc_acct_lines_rec.CC_Ent_Withheld_Amt,
                       G_FLAG,
		       l_cc_acct_lines_rec.tax_classif_code);


                IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)
                THEN
                        l_EXCEPTION := NULL;
                        FND_MESSAGE.SET_NAME('IGC','IGC_CC_YEP_ACT_LINES_UPDATE');
                        l_EXCEPTION := FND_MESSAGE.GET;
                        p_message   := l_exception;
                        p_err_header_id := l_cc_headers_rec.cc_header_id;
                        p_err_acct_line_id := l_cc_acct_lines_rec.CC_ACCT_LINE_ID;
                        p_err_det_pf_line_id := NULL;

--        IF l_debug_mode = 'Y' THEN
--           Output_Debug (' IGCCREPB -- Reval Update Ends 7 ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
--        END IF;

        -- bug 3199488, start block
        IF (l_state_level >= l_debug_level) THEN
            FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_revalue_process_pkg.reval_update.Msg4',
                                          ' IGCCREPB -- Reval Update Ends 7 ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
        END IF;
        -- bug 3199488, end block

                        RETURN 'F';
                END IF;


		OPEN c_pf_lines(l_cc_acct_lines_rec.cc_acct_line_id);
		LOOP
			FETCH c_pf_lines INTO l_cc_pmt_fcst_rec;
			EXIT WHEN c_pf_lines%NOTFOUND;

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

--        IF l_debug_mode = 'Y' THEN
--           Output_Debug (' IGCCREPB -- Reval Update Ends 6 ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
--        END IF;

        -- bug 3199488, start block
        IF (l_state_level >= l_debug_level) THEN
            FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_revalue_process_pkg.reval_update.Msg5',
                                          ' IGCCREPB -- Reval Update Ends 6 ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
        END IF;
        -- bug 3199488, end block

				RETURN 'F';
			END IF;


			l_new_cc_det_pf_func_amt :=
				                   l_cc_pmt_fcst_rec.cc_det_pf_func_amt    +
				                   (  (  ( l_cc_pmt_fcst_rec.cc_det_pf_func_amt -
				                           l_cc_pmt_fcst_rec.cc_det_pf_func_billed_amt)  /  l_cc_headers_rec.conversion_rate
                                                        ) * (p_rate - l_cc_headers_rec.conversion_rate )
						     );

			IF ( ( (l_cc_headers_rec.cc_state = 'PR')  OR (l_cc_headers_rec.cc_state = 'CL') )
                     		AND (p_sbc_on = TRUE) AND (p_prov_enc_on = TRUE)
                   	   ) OR
		  	   ( ( (l_cc_headers_rec.cc_state = 'CM')  OR (l_cc_headers_rec.cc_state = 'CT') )
                     		AND (p_sbc_on = TRUE)  AND (p_conf_enc_on = TRUE)
                   	   )
			THEN
                                l_cc_det_pf_encmbrnc_amt  := (l_cc_pmt_fcst_rec.cc_det_pf_entered_amt * p_rate);
			        /* Bug fix for 1634793 */
			        IF (l_cc_headers_rec.cc_type <> 'R')
				THEN
					IF (l_cc_pmt_fcst_rec.cc_det_pf_date <= p_rate_date)
					THEN
						l_cc_det_pf_date          := p_rate_date;
                               			l_cc_det_pf_encmbrnc_date := p_rate_date;
			 		END IF;

			 		IF (l_cc_pmt_fcst_rec.cc_det_pf_date > p_rate_date)
			 		THEN
						l_cc_det_pf_date          := l_cc_pmt_fcst_rec.cc_det_pf_date;
                                		l_cc_det_pf_encmbrnc_date := l_cc_pmt_fcst_rec.cc_det_pf_encmbrnc_date;
					END IF;
			        ELSIF (l_cc_headers_rec.cc_type = 'R')
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
                                        l_cc_det_pf_encmbrnc_amt,
                                        l_cc_det_pf_encmbrnc_date,
                                        l_cc_pmt_fcst_rec.CC_Det_PF_Encmbrnc_Status,
                                        sysdate,
                                        l_Last_Updated_By,
                                        l_last_Update_Login,
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
                           p_err_header_id := l_cc_headers_rec.cc_header_id;
                           p_err_acct_line_id := l_cc_acct_lines_rec.CC_ACCT_LINE_ID;
                           p_err_det_pf_line_id := l_cc_pmt_fcst_rec.CC_Det_PF_Line_Id;

--        IF l_debug_mode = 'Y' THEN
--           Output_Debug (' IGCCREPB -- Reval Update Ends 5 ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
--        END IF;

        -- bug 3199488, start block
        IF (l_state_level >= l_debug_level) THEN
            FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_revalue_process_pkg.reval_update.Msg6',
                                          ' IGCCREPB -- Reval Update Ends 5 ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
        END IF;
        -- bug 3199488, end block

                           RETURN 'F';
                    END IF;

		END LOOP;

		CLOSE c_pf_lines;

	END LOOP;

	CLOSE c_acct_lines;

	END IF;

	IF (p_validate_only = 'N')
	THEN
		/* Fix for bug 1498700
                   Update Accounting date at CC Header if Account Date <= rate_date
                 */

		IF ( ( (l_cc_headers_rec.cc_state = 'PR')  OR (l_cc_headers_rec.cc_state = 'CL') )
                     AND (p_cbc_on = TRUE) AND (p_prov_enc_on = TRUE)
                   ) OR
		  ( ( (l_cc_headers_rec.cc_state = 'CM')  OR (l_cc_headers_rec.cc_state = 'CT') )
                     AND (p_cbc_on = TRUE)  AND (p_conf_enc_on = TRUE)
                   )
		THEN

			IF (l_cc_headers_rec.cc_acct_date IS NOT NULL)
			THEN
				IF (l_cc_headers_rec.cc_acct_date <= p_rate_date)
				THEN
					l_cc_acct_date         := p_rate_date;
				ELSIF (l_cc_headers_rec.cc_acct_date > p_rate_date)
				THEN
					l_cc_acct_date         := l_cc_headers_rec.cc_acct_date;
				END IF;
			END IF;

			IF (l_cc_headers_rec.cc_acct_date IS NULL)
			THEN
				l_cc_acct_date := l_cc_headers_rec.cc_acct_date;
			END IF;
		ELSE

			l_cc_acct_date := l_cc_headers_rec.cc_acct_date;
		END IF;

                l_conversion_date      := p_rate_date;
               	l_conversion_rate      := p_rate;
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
                         l_conversion_date,
                         l_conversion_rate,
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
                         l_cc_headers_rec.CC_GUARANTEE_FLAG,
                         G_FLAG);

		IF      (l_return_status <> FND_API.G_RET_STS_SUCCESS)
		THEN

                	l_EXCEPTION := NULL;
                	FND_MESSAGE.SET_NAME('IGC','IGC_CC_YEP_HEADERS_UPDATE');
                	l_EXCEPTION := FND_MESSAGE.GET;
			p_message   := l_exception;
                        p_err_header_id := l_cc_headers_rec.cc_header_id;
                        p_err_acct_line_id := NULL;
                        p_err_det_pf_line_id := NULL;

--        IF l_debug_mode = 'Y' THEN
--           Output_Debug (' IGCCREPB -- Reval Update Ends 4 ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
--        END IF;

        -- bug 3199488, start block
        IF (l_state_level >= l_debug_level) THEN
            FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_revalue_process_pkg.reval_update.Msg7',
                                          ' IGCCREPB -- Reval Update Ends 4 ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
        END IF;
        -- bug 3199488, end block

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
            /* Changed l_cc_headers_rec.cc_apprvl_status to l_approval_status in the following line to fix bug 1613811 */
	   (  ( (l_cc_headers_rec.cc_state = 'CM') AND (l_approval_status = 'AP') ) OR
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
--        IF l_debug_mode = 'Y' THEN
--           Output_Debug (' IGCCREPB -- Reval Update Ends 3 ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
--        END IF;

        -- bug 3199488, start block
        IF (l_state_level >= l_debug_level) THEN
            FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_revalue_process_pkg.reval_update.Msg8',
                                          ' IGCCREPB -- Reval Update Ends 3 ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
        END IF;
        -- bug 3199488, end block

			RETURN 'F';
		END IF;
	END IF;

        /* added following code to remove hard coded message */
	/* begin */
	l_action_hist_msg := NULL;
       	FND_MESSAGE.SET_NAME('IGC','IGC_CC_REP_ACT_HIST_MSG');
        FND_MESSAGE.SET_TOKEN ('REVAL_RATE', p_rate);
        FND_MESSAGE.SET_TOKEN ('REVAL_DATE_RATE', to_char(p_rate_date, 'DD-MON-YYYY'));
       	l_action_hist_msg := FND_MESSAGE.GET;
	/*end */

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
                                'RP',
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
              p_message   := l_exception;
              p_err_header_id := l_cc_headers_rec.cc_header_id;
              p_err_acct_line_id := NULL;
              p_err_det_pf_line_id := NULL;

--        IF l_debug_mode = 'Y' THEN
--           Output_Debug (' IGCCREPB -- Reval Update Ends 1 ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
--        END IF;

        -- bug 3199488, start block
        IF (l_state_level >= l_debug_level) THEN
            FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_revalue_process_pkg.reval_update.Msg9',
                                          ' IGCCREPB -- Reval Update Ends 1 ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
        END IF;
        -- bug 3199488, end block

              RETURN 'F';
	END IF;

	/* Update validation status, in temporary table*/
	UPDATE igc_cc_process_data
	SET
		processed = 'Y'
	WHERE   request_id        = p_request_id AND
		cc_header_id      = P_cc_header_id ;

	RETURN 'P';
--        IF l_debug_mode = 'Y' THEN
--           Output_Debug (' IGCCREPB -- Reval Update Ends 2 ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
--        END IF;

       -- bug 3199488, start block
        IF (l_state_level >= l_debug_level) THEN
            FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_revalue_process_pkg.reval_update.Msg10',
                                          ' IGCCREPB -- Reval Update Ends 2 ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
        END IF;
        -- bug 3199488, end block

EXCEPTION
	WHEN OTHERS
	THEN
--        IF l_debug_mode = 'Y' THEN
--           Output_Debug (' IGCCREPB -- Reval Update Ends 10 ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
--        END IF;

        -- bug 3199488, start block
        IF (l_state_level >= l_debug_level) THEN
            FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_revalue_process_pkg.reval_update.Msg11',
                                          ' IGCCREPB -- Reval Update Ends 10 ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
        END IF;
        -- bug 3199488, end block

		RETURN 'F';

END  reval_update;

/* Commented out as per bug 3199488
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

   l_prod             VARCHAR2(3);
   l_sub_comp         VARCHAR2(6);
   l_profile_name     VARCHAR2(255);
   l_Return_Status    VARCHAR2(1);
   l_api_name         CONSTANT VARCHAR2(30) := 'Output_Debug';

BEGIN

--GSCC Warnings fixed
   l_prod             := 'IGC';
   l_sub_comp         := 'CC_RVL';
   l_profile_name     := 'IGC_DEBUG_LOG_DIRECTORY';

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

PROCEDURE populate_errors(p_cc_header_id   NUMBER,
			  p_process_phase  VARCHAR2,
                          p_currency_code  VARCHAR2,
                          p_rate_type      VARCHAR2,
                          p_sob_id         NUMBER,
                          p_org_id         NUMBER,
                          p_request_id     NUMBER)
IS
	l_message igc_cc_process_exceptions.exception_reason%TYPE;
BEGIN
	/* Update validation_status to 'F' in temporary table for releases */

--        IF l_debug_mode = 'Y' THEN
--           Output_Debug (' IGCCREPB -- Populate Error Begins ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
--        END IF;

        -- bug 3199488, start block
        IF (l_state_level >= l_debug_level) THEN
            FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_revalue_process_pkg.populate_errors.Msg1',
                                          ' IGCCREPB -- Populate Error Begins ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
        END IF;
        -- bug 3199488, end block

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
		SELECT 'R',
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
			NVL(b.parent_header_id,0)   = p_cc_header_id   AND
			b.cc_header_id       = a.cc_header_id   AND
			b.currency_code      = p_currency_code  AND
	        	b.conversion_type    = p_rate_type      AND
                        a.request_id         = p_request_id;
--        IF l_debug_mode = 'Y' THEN
--           Output_Debug (' IGCCREPB -- Populate Error Ends ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
--        END IF;

        -- bug 3199488, start block
        IF (l_state_level >= l_debug_level) THEN
            FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_revalue_process_pkg.populate_errors.Msg2',
                                          ' IGCCREPB -- Populate Error Ends ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
        END IF;
        -- bug 3199488, end block

END populate_errors;


PROCEDURE revalue_main( ERRBUF          OUT NOCOPY VARCHAR2,
			RETCODE         OUT NOCOPY VARCHAR2,
			p_process_phase IN VARCHAR2,
			p_currency_code IN VARCHAR2,
			p_rate_type     IN VARCHAR2,
			p_rate_date     IN VARCHAR2,
			p_rate          IN VARCHAR2,
			p_cc_header_id  IN NUMBER)
IS
	l_cc_headers_rec              igc_cc_headers%ROWTYPE;
	l_rel_cc_headers_rec          igc_cc_headers%ROWTYPE;
	l_cc_acct_lines_rec           igc_cc_acct_lines_v%ROWTYPE;
	l_rel_cc_acct_lines_rec       igc_cc_acct_lines_v%ROWTYPE;
	l_cc_pmt_fcst_rec             igc_cc_det_pf_v%ROWTYPE;
	l_rel_cc_pmt_fcst_rec         igc_cc_det_pf_v%ROWTYPE;
        l_err_header_id               NUMBER;
	l_err_acct_line_id            NUMBER;
        l_err_det_pf_line_id          NUMBER;

        l_rate_date                   DATE;

	l_budg_status                 BOOLEAN;
	l_validation_status           VARCHAR2(1);
	l_curr_validation_status      VARCHAR2(1);
	l_reservation_status          VARCHAR2(1);
	l_processed                   VARCHAR2(1);
	l_validate_only               VARCHAR2(1);
	l_process_flag                VARCHAR2(1);

	l_org_id                      NUMBER;
        l_sob_id                      NUMBER;
	/*Bug No : 6341012. SLA Uptake. l_sob_name is added to get SOB Name*/
	l_sob_name		   VARCHAR2(30);

	l_process_data_count          NUMBER;
	l_cc_count                    NUMBER;
	l_invalid_cc_count            NUMBER;
	l_po_count                    NUMBER;

	l_cc_cover_count              NUMBER;

	l_request_id2                 NUMBER;
	l_request_id1                 NUMBER;

	l_lock_cc_po                  BOOLEAN;
	l_cover_not_found             BOOLEAN;
	l_cc_not_found                BOOLEAN;
       	l_approval_status             VARCHAR2(2);

	l_message                     igc_cc_process_exceptions.exception_reason%TYPE;
--        l_debug                       VARCHAR2(1);

	l_currency_code               gl_sets_of_books.currency_code%TYPE;
	l_sbc_on 		      BOOLEAN;
	l_cbc_on 		      BOOLEAN;
	l_prov_enc_on                 BOOLEAN;
	l_conf_enc_on                 BOOLEAN;
/*Bug No : 6341012. SLA Uptake. Encumbrance Type ID are not required*/
--	l_req_encumbrance_type_id     NUMBER;
--	l_purch_encumbrance_type_id   NUMBER;
--	l_cc_prov_enc_type_id         NUMBER;
--	l_cc_conf_enc_type_id         NUMBER;

	l_non_reval_acct_amt_total    NUMBER;
	l_reval_acct_amt_total        NUMBER;
	l_non_reval_pf_amt_total      NUMBER;
	l_reval_pf_amt_total          NUMBER;
	l_cover_acct_func_amt         NUMBER;
	l_cover_pf_func_amt           NUMBER;
        l_msg_count                   NUMBER;
        l_msg_data                    VARCHAR2(12000);
        l_error_text                  VARCHAR2(12000);
        l_usr_msg                     igc_cc_process_exceptions.exception_reason%TYPE;

        -- Bug 2441322
        l_rate                     NUMBER;

       -- 01/03/02, add code to check if CC is enabled for IGI
        l_option_name                 VARCHAR2(80);
        lv_message                    VARCHAR2(1000);
   -- Varibles used for xml report
l_terr                     VARCHAR2(10):='US';
l_lang                     VARCHAR2(10):='en';
l_layout                   BOOLEAN;
	/* Cursor for fetching all contract commitments eligible for re-valuation */

	CURSOR c_revalue_process_cc(p_process_phase      VARCHAR2,
                                    p_sob_id             NUMBER,
				    p_org_id             NUMBER,
				    p_currency_code      VARCHAR2,
				    p_rate_type          VARCHAR2,
                                    p_rate               NUMBER,
                                    p_func_currency_code VARCHAR2,
                                    p_cc_header_id       NUMBER)
	IS

		SELECT *
		FROM   igc_cc_headers a
		WHERE
                      ( (a.cc_state = 'PR') OR
                        (a.cc_state = 'CM') OR
                        ( (a.cc_state = 'CT') AND (a.cc_apprvl_status <> 'AP')) OR
                        ( (a.cc_state = 'CL') AND (a.cc_apprvl_status <> 'AP'))
                      ) AND
                     (

		      (  (a.org_id                     = p_org_id                     AND
		          a.set_of_books_id            = p_sob_id                     AND
		          a.currency_code              = p_currency_code              AND
                          ( p_process_phase          = 'P' OR
		            (p_process_phase         = 'F' AND
		             a.conversion_rate         <> NVL(p_rate, -99999))
                           )                                                        AND
		          a.conversion_type            = p_rate_type                  AND
			  ( (a.cc_type                   = 'C') OR
                            (a.cc_type                   = 'S') OR
                            ( (a.cc_type                   = 'R') AND
                               EXISTS (SELECT 'x'
                                       FROM igc_cc_headers b
                                       WHERE b.cc_header_id = NVL(a.parent_header_id,0) AND
                                             b.currency_code = p_func_currency_code)
                            )
                          )
                          )                                                         AND
                          p_cc_header_id IS NULL
                      )
                      OR
		      (  (a.org_id                     = p_org_id                     AND
		          a.set_of_books_id            = p_sob_id                     AND
		          a.currency_code              = p_currency_code              AND
                          a.cc_header_id               = NVL(p_cc_header_id,-999999)  AND
                          ( p_process_phase          = 'P' OR
		            (p_process_phase         = 'F' AND
		             a.conversion_rate         <> NVL(p_rate, -99999))
                           )                                                       AND
		          a.conversion_type      = p_rate_type
                          )                                                        AND
                          p_cc_header_id IS NOT NULL
                      )
                     );

	/* Fetch the cover-relase both revalued data from temporary table */
	CURSOR c_cover_reval_data(p_request_id NUMBER)
	IS
		SELECT a.cc_header_id
		FROM   igc_cc_process_data a ,
		       igc_cc_headers b
                WHERE  a.request_id   = p_request_id     AND
                       a.cc_header_id = b.cc_header_id AND
                       /* bug 1622969 */
                       a.validation_status = 'I' AND
                       /* bug 1622969 */
                       b.cc_type      = 'C';


	/* Fetch the cover-standard data from temporary table */
	CURSOR c_reval_data(p_request_id NUMBER)
	IS
		SELECT a.cc_header_id
		FROM   igc_cc_process_data a ,
		       igc_cc_headers b
                WHERE  a.request_id     = p_request_id       AND
                       a.cc_header_id   = b.cc_header_id     AND
                       /* bug 1622969 */
                       (a.validation_status = 'I' OR a.validation_status = 'P') AND
                       /* bug 1622969 */
                       (b.cc_type       = 'C' OR b.cc_type = 'S');

	CURSOR C_ALL_RELEASES1(p_cc_header_id  NUMBER)
	IS
		SELECT *
		FROM  igc_cc_headers
		WHERE NVL(parent_header_id,0) = p_cc_header_id;

	CURSOR C_ALL_RELEASES(p_cc_header_id  NUMBER)
	IS
		SELECT a.cc_header_id
		FROM igc_cc_headers a
		WHERE NVL(a.parent_header_id,0) = p_cc_header_id;

	CURSOR C_RELEASES(p_cc_header_id  NUMBER,
			  p_currency_code VARCHAR2,
			  p_rate_type     VARCHAR2)
	IS
		SELECT a.cc_header_id
		FROM igc_cc_headers a
		WHERE NVL(a.parent_header_id,0) = p_cc_header_id    AND
		      a.currency_code    = p_currency_code   AND
		      a.conversion_type  = p_rate_type     ;

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
                       NULL tax_id, -- added for Bug 6472296 Ebtax uptake for cc
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
			 ccal.tax_classif_code -- added for Bug 6472296 Ebtax uptake for cc
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
        FROM   igc_cc_det_pf ccdpf
	WHERE cc_acct_line_id = p_cc_acct_line_id
	AND   ccdpf.cc_det_pf_entered_amt <> IGC_CC_COMP_AMT_PKG.COMPUTE_PF_BILLED_AMT(ccdpf.cc_det_pf_line_id,ccdpf.cc_det_pf_line_num,
																				ccdpf.cc_acct_line_id); -- Bug 3856265


	l_cc_header_id      igc_cc_headers.cc_header_id%TYPE;
	l_rel_cc_header_id  igc_cc_headers.cc_header_id%TYPE;
	l_cc_acct_line_id   igc_cc_acct_lines.cc_acct_line_id%TYPE;

	insert_data EXCEPTION;
BEGIN

--GSCC Warnings Fixed
	l_process_data_count          := 0;
	l_cc_count                    := 0;
	l_invalid_cc_count            := 0;
	l_po_count                    := 0;
	l_cc_cover_count              := 0;
	l_request_id2                 := 0;
	l_request_id1                 := 79000;
	l_lock_cc_po                  := FALSE;
	l_cover_not_found             := FALSE;
	l_cc_not_found                := FALSE;
	l_non_reval_acct_amt_total    := 0;
	l_reval_acct_amt_total        := 0;
	l_non_reval_pf_amt_total      := 0;
	l_reval_pf_amt_total          := 0;
	l_cover_acct_func_amt         := 0;
	l_cover_pf_func_amt           := 0;
        l_msg_count            		  := 0;

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

   -- Bug 2441322, get the numeric rate
   l_rate := Fnd_number.canonical_to_number(canonical => p_rate) ;

/*Bug No : 6341012. MOAC Uptake. ORG_ID,SOB_ID are not retrieved from Profile values
But from other packages...
-- Get the profile values
        l_org_id := TO_NUMBER(FND_PROFILE.VALUE('ORG_ID'));
        l_sob_id := TO_NUMBER(FND_PROFILE.VALUE('GL_SET_OF_BKS_ID'));
*/
	l_org_id := MO_GLOBAL.get_current_org_id;
	MO_UTILS.get_ledger_info(l_org_id,l_sob_id,l_sob_name);

--
-- Setup debug information based upon profile setup options.
--
--        l_debug       := FND_PROFILE.VALUE('IGC_DEBUG_ENABLED');
--        IF (l_debug = 'Y') THEN
--           l_debug := FND_API.G_TRUE;
--        ELSE
--           l_debug := FND_API.G_FALSE;
--        END IF;
--        IGC_MSGS_PKG.g_debug_mode := FND_API.TO_BOOLEAN(l_debug);

--      IF l_debug_mode = 'Y' THEN
--      Output_Debug (' IGCCREPB -- ************ Starting Revalue CC '|| to_char(sysdate,'DD-MON-YY:MI:SS') || ' *************************');
--      END IF;

      -- bug 3199488, start block
      IF (l_state_level >= l_debug_level) THEN
          FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_revalue_process_pkg.revalue_main.Msg1',
                                        ' IGCCREPB -- Starting Revalue CC ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
      END IF;
      -- bug 3199488, end block

	RETCODE := '0';

      -- Bug 1914745, clear any old records from the igc_cc_interface table
      -- DELETE FROM igc_cc_interface
      -- WHERE  to_date(creation_date,'DD/MM/YYYY') <= to_date((sysdate - interval '2' day), 'DD/MM/YYYY');

        --Bug 2872060. Above delete commented out. Was causing compilation probs in Oracle8i
          DELETE FROM igc_cc_interface
          WHERE  to_date(creation_date,'DD/MM/YYYY') <= to_date(sysdate ,'DD/MM/YYYY') - 2;


        /* Begin fix bug 1591845 */

        l_rate_date := trunc(to_date (p_rate_date, 'YYYY/MM/DD HH24:MI:SS'));

        /* Begin fix bug 1591845 */

	l_request_id1 := fnd_global.conc_request_id;

	SAVEPOINT REVALUE1;

	l_currency_code              := NULL;
	l_sbc_on 		     := NULL;
	l_cbc_on 		     := NULL;
	l_prov_enc_on                := NULL;
	l_conf_enc_on                := NULL;
/*Bug No : 6341012. SLA Uptake. Encumbrance Type ID are not required*/
--	l_req_encumbrance_type_id    := NULL;
--	l_purch_encumbrance_type_id  := NULL;
--	l_cc_prov_enc_type_id        := NULL;
--	l_cc_conf_enc_type_id        := NULL;


	/* Get Budgetary Control information */
--        IF l_debug_mode = 'Y' THEN
--        Output_Debug (' IGCCREPB -- Calling get_budg_ctrl_params ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
--        END IF;

        -- bug 3199488, start block
        IF (l_state_level >= l_debug_level) THEN
            FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_revalue_process_pkg.revalue_main.Msg2',
                                          ' IGCCREPB -- Calling get_budg_ctrl_params ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
        END IF;
        -- bug 3199488, end block

        /* Begin fix for bug 1576023 */
	l_msg_data  := NULL;
	l_msg_count := 0;
	l_usr_msg   := NULL;

  l_budg_status := IGC_CC_REP_YEP_PVT.get_budg_ctrl_params(
			   l_sob_id,
			   l_org_id,
			   l_currency_code,
			   l_sbc_on,
			   l_cbc_on,
			   l_prov_enc_on,
			   l_conf_enc_on,
/*Bug No : 6341012. SLA Uptake. Encumbrance Type ID are not required */
		--	   l_req_encumbrance_type_id,
		--	   l_purch_encumbrance_type_id,
		--	   l_cc_prov_enc_type_id,
		--	   l_cc_conf_enc_type_id ,
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
                ( 'R',
	 	  p_process_phase,
		  NULL,
		  NULL,
		  NULL,
		  l_usr_msg,
		  l_org_id,
		  l_sob_id,
                  l_request_id1);

		COMMIT;

	END IF;

	IF (l_budg_status = FALSE AND l_usr_msg IS NOT NULL)
	THEN

                --IF l_debug_mode = 'Y' THEN
                --Output_Debug (' IGCCREPB -- Submitting request ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
                --END IF;

                -- bug 3199488, start block
                IF (l_state_level >= l_debug_level) THEN
                    FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_revalue_process_pkg.revalue_main.Msg3',
                                                  ' IGCCREPB -- Submitting request ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
                END IF;
                -- bug 3199488, end block


/*Bug No : 6341012. MOAC Uptake. Need to set org_id before submiting a request*/
	        Fnd_request.set_org_id(l_org_id);
		l_request_id2 := FND_REQUEST.SUBMIT_REQUEST(
                                'IGC',
               	                'IGCCRVPR',
                                NULL,
                                NULL,
                                FALSE,
                                l_sob_id,
                                l_org_id,
                                p_process_phase,
                                'R',
                                l_request_id1);
-----------------------
-- Start of XML Report
-----------------------
       IF IGC_CC_COMMON_UTILS_PVT.xml_report_enabled THEN
               IGC_CC_COMMON_UTILS_PVT.get_xml_layout_info(
                                            l_lang,
                                            l_terr,
                                            'IGCCRVPR_XML',
                                            'IGC',
                                            'IGCCRVPR_XML' );

                l_layout :=  FND_REQUEST.ADD_LAYOUT(
                                            'IGC',
                                            'IGCCRVPR_XML',
                                            l_lang,
                                            l_terr,
                                            'RTF');

                 IF l_layout then
                 l_request_id2 := FND_REQUEST.SUBMIT_REQUEST(
                                'IGC',
               	                'IGCCRVPR_XML',
                                NULL,
                                NULL,
                                FALSE,
                                l_sob_id,
                                l_org_id,
                                p_process_phase,
                                'R',
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
	IF (l_budg_status = FALSE )
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
--                                         	   l_error_text);
                                      -- bug 3199488 start block
                                      IF (l_state_level >= l_debug_level) THEN
                                          FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_revalue_process_pkg.revalue_main.Excp1',
                                                                        l_error_text);
                                      END IF;
                                      -- bug 3199488, end block
                	END LOOP;
        	END IF;
	END IF;

	IF (l_budg_status = FALSE AND l_usr_msg IS NULL)
	THEN
		RETCODE := 2;
	END IF;

	IF (l_budg_status = FALSE )
	THEN
		RETURN;
	END IF;

        /* End fix for bug 1576023 */


        --IF l_debug_mode = 'Y' THEN
        --   Output_Debug (' IGCCREPB -- Calling validate_params ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
        --END IF;

        -- bug 3199488, start block
        IF (l_state_level >= l_debug_level) THEN
            FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_revalue_process_pkg.revalue_main.Msg4',
                                          ' IGCCREPB -- Calling validate_params ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
        END IF;
        -- bug 3199488, end block

	IF ( NOT    validate_params(p_process_phase,
	         	            l_sob_id,
			            l_org_id,
			            p_currency_code,
			            l_currency_code,
                                    p_rate_type,
		                    l_rate,
                                    l_rate_date,
                                    l_request_id1)
	    )
	THEN

                --IF l_debug_mode = 'Y' THEN
                --Output_Debug (' IGCCREPB -- Submitting request ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
                --END IF;

                -- bug 3199488, start block
                IF (l_state_level >= l_debug_level) THEN
                    FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_revalue_process_pkg.revalue_main.Msg5',
                                                  ' IGCCREPB -- Submitting request ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
                END IF;
                -- bug 3199488, end block

/*Bug No : 6341012. MOAC Uptake. Need to set org_id before submiting a request*/
        Fnd_request.set_org_id(l_org_id);
	l_request_id2 := FND_REQUEST.SUBMIT_REQUEST(
                                'IGC',
               	                'IGCCRVPR',
                                NULL,
                                NULL,
                                FALSE,
                                l_sob_id,
                                l_org_id,
                                p_process_phase,
                                'R',
                                l_request_id1);
-----------------------
-- Start of XML Report
-----------------------
      IF IGC_CC_COMMON_UTILS_PVT.xml_report_enabled THEN
               IGC_CC_COMMON_UTILS_PVT.get_xml_layout_info(
                                            l_lang,
                                            l_terr,
                                            'IGCCRVPR_XML',
                                            'IGC',
                                            'IGCCRVPR_XML' );

                 l_layout :=  FND_REQUEST.ADD_LAYOUT(
                                            'IGC',
                                            'IGCCRVPR_XML',
                                            l_lang,
                                            l_terr,
                                            'RTF');

                 IF l_layout then
                 l_request_id2 := FND_REQUEST.SUBMIT_REQUEST(
                                'IGC',
               	                'IGCCRVPR_XML',
                                NULL,
                                NULL,
                                FALSE,
                                l_sob_id,
                                l_org_id,
                                p_process_phase,
                                'R',
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
                          FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_revalue_process_pkg.revalue_main.Excp2',
                                                        l_error_text);
                      END IF;
                      -- bug 3199488, end block
                   END LOOP;
                END IF;

		RETURN;
	END IF;

	SAVEPOINT REVALUE3;

	l_process_data_count := 0;
	/* Populate temporary table */

--        IF l_debug_mode = 'Y' THEN
--        Output_Debug (' IGCCREPB -- Opening revalue_process_cc cursor ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
--        END IF;

        -- bug 3199488, start block
        IF (l_state_level >= l_debug_level) THEN
            FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_revalue_process_pkg.revalue_main.Msg6',
                                          ' IGCCREPB -- Opening revalue_process_cc_cursor ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
        END IF;
        -- bug 3199488, end block

	OPEN c_revalue_process_cc(p_process_phase,
                                  l_sob_id,
		                  l_org_id,
				  p_currency_code,   /* Non functional currency code */
				  p_rate_type,
				  l_rate,
                                  l_currency_code,   /* Functional Currency Code */
                                  p_cc_header_id);
	LOOP
		FETCH c_revalue_process_cc
		INTO l_cc_headers_rec;

       		EXIT WHEN c_revalue_process_cc%NOTFOUND;

		l_process_data_count := l_process_data_count + 1;

		/* Begin Standard Revaluation */
		IF (l_cc_headers_rec.cc_type = 'S')
		THEN
--                 IF l_debug_mode = 'Y' THEN
--                 Output_Debug (' IGCCREPB -- Inserting CC type S record into process data table ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
--                 END IF;

                        -- bug 3199488, start block
                        IF (l_state_level >= l_debug_level) THEN
                            FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_revalue_process_pkg.revalue_main.Msg7',
                                                          ' IGCCREPB -- Inserting CC type S record into process data table  ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
                        END IF;
                        -- bug 3199488, end block

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
			( 'R',
			p_process_phase,
		 	l_cc_headers_rec.cc_header_id,
		 	'I',
		 	'F',
		 	'N',
		 	NULL,
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
--                        IF l_debug_mode = 'Y' THEN
--                        Output_Debug (' IGCCREPB -- Checking R CC Type record ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
--                        END IF;

                        -- bug 3199488, start block
                        IF (l_state_level >= l_debug_level) THEN
                            FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_revalue_process_pkg.revalue_main.Msg8',
                                                          ' IGCCREPB -- Checking R CC Type record  ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
                        END IF;
                        -- bug 3199488, end block

			l_processed          := 'N';
			l_cover_not_found    := FALSE;

			BEGIN
				SELECT NVL(processed,'N')
				INTO   l_processed
				FROM   igc_cc_process_data a
				WHERE  a.cc_header_id   = NVL(l_cc_headers_rec.parent_header_id,0) AND
                                       a.request_id     = l_request_id1;
			EXCEPTION
				WHEN NO_DATA_FOUND
				THEN
--                                        IF l_debug_mode = 'Y' THEN
--                                        Output_Debug (' IGCCREPB -- Cover not found ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
--                                        END IF;

                                        -- bug 3199488, start block
                                        IF (l_state_level >= l_debug_level) THEN
                                           FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_revalue_process_pkg.revalue_main.Msg9',
                                                          ' IGCCREPB -- Cover not found ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
                                        END IF;
                                        -- bug 3199488, end block

					l_cover_not_found    := TRUE;
			END;

			IF (l_cover_not_found = TRUE)
			THEN
--                              IF l_debug_mode = 'Y' THEN
--                              Output_Debug (' IGCCREPB -- Inserting cover into process data table ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
--                              END IF;

                                -- bug 3199488, start block
                                IF (l_state_level >= l_debug_level) THEN
                                    FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_revalue_process_pkg.revalue_main.Msg10',
                                                                  ' IGCCREPB -- Inserting cover into process data table ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
                                END IF;
                                -- bug 3199488, end block

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
				( 'R',
			 	p_process_phase,
		 		l_cc_headers_rec.parent_header_id,
		 		'I',
		 		'F',
		 		'N',
		 		NULL,
		 		l_org_id,
		 		l_sob_id,
                                'Y',
                                l_request_id1);
				COMMIT;
			END IF;

			IF (l_cover_not_found = TRUE)
			THEN
--                                IF l_debug_mode = 'Y' THEN
--                                Output_Debug (' IGCCREPB -- Opening all releases Cursor ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
--                                END IF;

                                -- bug 3199488, start block
                                IF (l_state_level >= l_debug_level) THEN
                                    FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_revalue_process_pkg.revalue_main.Msg11',
                                                                  ' IGCCREPB -- Opening all releases Cursor ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
                                END IF;
                                -- bug 3199488, end block

				OPEN c_all_releases(l_cc_headers_rec.parent_header_id);
				LOOP
					FETCH c_all_releases INTO l_cc_header_id;
					EXIT WHEN c_all_releases%NOTFOUND;

--                                        IF l_debug_mode = 'Y' THEN
--                          Output_Debug (' IGCCREPB -- Inserting release into process data table ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
--                                       END IF;

                                        -- bug 3199488, start block
                                        IF (l_state_level >= l_debug_level) THEN
                                           FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_revalue_process_pkg.revalue_main.Msg12',
                                                                         ' IGCCREPB -- Inserting release into process data table ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
                                        END IF;
                                        -- bug 3199488, end block

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
						( 'R',
			 			p_process_phase,
		 				l_cc_header_id,
		 				'I',
		 				'F',
		 				'N',
		 				NULL,
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
						( 'R',
			 			p_process_phase,
		 				l_cc_header_id,
		 				'I',
		 				'F',
		 				'N',
		 				NULL,
		 				l_org_id,
		 				l_sob_id,
                                        	'Y',
                                                l_request_id1);
					END IF;

				END LOOP;

				CLOSE c_all_releases;

				COMMIT;

			END IF;

			IF  (l_cover_not_found = FALSE)
			THEN
--                                IF l_debug_mode = 'Y' THEN
--                                Output_Debug (' IGCCREPB -- Attempting lock CC PO ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
--                                END IF;

                                -- bug 3199488, start block
                                IF (l_state_level >= l_debug_level) THEN
                                    FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_revalue_process_pkg.revalue_main.Msg13',
                                                                  ' IGCCREPB -- Attempting lock CC PO ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
                                END IF;
                                -- bug 3199488, end block

				l_lock_cc_po := FALSE;
				l_lock_cc_po := lock_cc_po(l_sob_id,l_org_id,l_cc_headers_rec.parent_header_id,l_request_id1);

				IF (l_lock_cc_po = TRUE)
				THEN
					UPDATE igc_cc_process_data a
					SET
						validate_only = 'N'
					WHERE   a.request_id    = l_request_id1 AND
						a.cc_header_id  = l_cc_headers_rec.cc_header_id;
					COMMIT;
				END IF;

			END IF;
		END IF;
		/* End release Revaluation */

		/* Begin Cover Revaluation */

		IF (l_cc_headers_rec.cc_type = 'C')
		THEN
--                        IF l_debug_mode = 'Y' THEN
--                        Output_Debug (' IGCCREPB -- Begin Cover revaluation ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
--                        END IF;

                        -- bug 3199488, start block
                        IF (l_state_level >= l_debug_level) THEN
                            FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_revalue_process_pkg.revalue_main.Msg14',
                                                          ' IGCCREPB -- Begin Cover revaluation ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
                        END IF;
                        -- bug 3199488, end block

			l_processed          := 'N';
			l_cover_not_found    := FALSE;

			BEGIN
				SELECT NVL(processed,'N')
				INTO   l_processed
				FROM   igc_cc_process_data a
				WHERE  a.cc_header_id     = l_cc_headers_rec.cc_header_id AND
                                       a.request_id       = l_request_id1;
			EXCEPTION
				WHEN NO_DATA_FOUND
				THEN
--                                        IF l_debug_mode = 'Y' THEN
--                                        Output_Debug (' IGCCREPB -- Cover not found ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
--                                        END IF;

                                          -- bug 3199488, start block
                                          IF (l_state_level >= l_debug_level) THEN
                                              FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_revalue_process_pkg.revalue_main.Msg15',
                                                                            ' IGCCREPB -- Cover not found ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
                                          END IF;
                                          -- bug 3199488, end block

					l_cover_not_found    := TRUE;
			END;

			IF  (l_cover_not_found = TRUE)
			THEN
--                                IF l_debug_mode = 'Y' THEN
--                                Output_Debug (' IGCCREPB -- Obtaining releases cursor ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
--                                END IF;

                                -- bug 3199488, start block
                                IF (l_state_level >= l_debug_level) THEN
                                    FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_revalue_process_pkg.revalue_main.Msg16',
                                                                  ' IGCCREPB -- Obtaining releases cursor ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
                                END IF;
                                -- bug 3199488, end block

				OPEN c_all_releases(l_cc_headers_rec.cc_header_id);
				LOOP
					FETCH c_all_releases INTO l_cc_header_id;
					EXIT WHEN c_all_releases%NOTFOUND;
--                                    IF l_debug_mode = 'Y' THEN
--                                    Output_Debug (' IGCCREPB -- Inserting into process data table ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
--                                    END IF;

                                        -- bug 3199488, start block
                                        IF (l_state_level >= l_debug_level) THEN
                                            FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_revalue_process_pkg.revalue_main.Msg17',
                                                                          ' IGCCREPB -- Inserting into process data table  ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
                                        END IF;
                                        -- bug 3199488, end block

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
					( 'R',
			 		p_process_phase,
		 			l_cc_header_id,
		 			'I',
		 			'F',
		 			'N',
		 			NULL,
		 			l_org_id,
		 			l_sob_id,
                                        'N',
                                         l_request_id1);
				END LOOP;
				CLOSE c_all_releases;
--                                IF l_debug_mode = 'Y' THEN
--                                Output_Debug (' IGCCREPB -- Done with releases ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
--                                Output_Debug (' IGCCREPB -- Inserting cover into process data ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
--                                END IF;

                                -- bug 3199488, start block
                                IF (l_state_level >= l_debug_level) THEN
                                    FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_revalue_process_pkg.revalue_main.Msg18',
                                                                  ' IGCCREPB -- Done with releases ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
                                    FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_revalue_process_pkg.revalue_main.Msg19',
                                                                  ' IGCCREPB -- Inserting cover into process data ' || to_char(sysdate,'DD-MON-YY:MI:SS'));

                                END IF;
                                -- bug 3199488, end block

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
				( 'R',
			 	p_process_phase,
		 		l_cc_headers_rec.cc_header_id,
		 		'I',
		 		'F',
		 		'N',
		 		NULL,
		 		l_org_id,
		 		l_sob_id,
                                'N',
                                l_request_id1);

				COMMIT;
			END IF;

		END IF;
		/* End Cover revaluation */

	END LOOP;

	CLOSE c_revalue_process_cc;
--        IF l_debug_mode = 'Y' THEN
--        Output_Debug (' IGCCREPB -- Done with revalue process CC ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
--        END IF;

         -- bug 3199488, start block
         IF (l_state_level >= l_debug_level) THEN
             FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_revalue_process_pkg.revalue_main.Msg20',
                                           ' IGCCREPB -- Done with revalue process CC ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
         END IF;
        -- bug 3199488, end block

	COMMIT;

	/* Begin  Lock CC and PO */
	/* Lock Contract Commitments and related PO's If Phase = 'Final' */
--        IF l_debug_mode = 'Y' THEN
--           Output_Debug (' IGCCREPB -- Checking Final Phase ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
--        END IF;

        -- bug 3199488, start block
        IF (l_state_level >= l_debug_level) THEN
            FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_revalue_process_pkg.revalue_main.Msg21',
                                          ' IGCCREPB -- Checking Final Phase ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
        END IF;
        -- bug 3199488, end block

	IF (p_process_phase = 'F') AND (l_process_data_count > 0)
	THEN
--                IF l_debug_mode = 'Y' THEN
--                Output_Debug (' IGCCREPB -- Final Phase Starts ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
--                END IF;

                -- bug 3199488, start block
                IF (l_state_level >= l_debug_level) THEN
                    FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_revalue_process_pkg.revalue_main.Msg22',
                                                  ' IGCCREPB -- Final Phase Starts ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
                END IF;
                -- bug 3199488, end block

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
--                                IF l_debug_mode = 'Y' THEN
--                                Output_Debug (' IGCCREPB -- Attempting lock cc po ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
--                                END IF;

                                -- bug 3199488, start block
                                IF (l_state_level >= l_debug_level) THEN
                                   FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_revalue_process_pkg.revalue_main.Msg23',
                                                                 ' IGCCREPB -- Attempting lock cc po ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
                                END IF;
                                -- bug 3199488, end block

				l_lock_cc_po := lock_cc_po(l_sob_id,l_org_id,l_cc_header_id, l_request_id1);

			END IF;

			IF (l_lock_cc_po = FALSE)
			THEN
--                                IF l_debug_mode = 'Y' THEN
--                                Output_Debug (' IGCCREPB -- lock cc po FALSE ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
--                                END IF;

                                -- bug 3199488, start block
                                IF (l_state_level >= l_debug_level) THEN
                                   FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_revalue_process_pkg.revalue_main.Msg24',
                                                                 ' IGCCREPB -- Attempting lock cc po FALSE ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
                                END IF;
                                -- bug 3199488, end block

				/* bug 1622969 */
				UPDATE igc_cc_process_data
				SET validation_status = 'F',
				    processed = 'Y'
				WHERE cc_header_id = l_cc_header_id AND
                                      request_id   = l_request_id1;
				/* bug 1622969 */

			END IF;

			/* Cover Relase */
--                        IF l_debug_mode = 'Y' THEN
--                        Output_Debug (' IGCCREPB -- Checking Cover Type ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
--                        END IF;

                        -- bug 3199488, start block
                        IF (l_state_level >= l_debug_level) THEN
                            FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_revalue_process_pkg.revalue_main.Msg25',
                                                          ' IGCCREPB -- Checking Cover Type ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
                        END IF;
                        -- bug 3199488, end block

			IF (l_cc_headers_rec.cc_type = 'C')
			THEN
--                                IF l_debug_mode = 'Y' THEN
--                                Output_Debug (' IGCCREPB -- Getting Releases ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
--                                END IF;

                                -- bug 3199488, start block
                                IF (l_state_level >= l_debug_level) THEN
                                    FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_revalue_process_pkg.revalue_main.Msg26',
                                                                  ' IGCCREPB -- Getting Releases ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
                                END IF;
                                -- bug 3199488, end block

				OPEN c_all_releases(l_cc_headers_rec.cc_header_id);
				LOOP
					FETCH c_all_releases INTO l_rel_cc_header_id;
					EXIT WHEN c_all_releases%NOTFOUND;

			                l_lock_cc_po := TRUE;

					IF (l_lock_cc_po = TRUE)
					THEN
--                                             IF l_debug_mode = 'Y' THEN
--                                            Output_Debug (' IGCCREPB -- locking cc po for release ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
--                                                END IF;

                                                -- bug 3199488, start block
                                                IF (l_state_level >= l_debug_level) THEN
                                                   FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_revalue_process_pkg.revalue_main.Msg27',' IGCCREPB -- locking cc po for release ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
                                                END IF;
                                                -- bug 3199488, end block

						l_lock_cc_po := lock_cc_po(l_sob_id,l_org_id,l_rel_cc_header_id,l_request_id1);
					END IF;

					IF (l_lock_cc_po = FALSE)
					THEN
--                                                IF l_debug_mode = 'Y' THEN
--                                         Output_Debug (' IGCCREPB -- lock cc po for release FALSE ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
--                                                END IF;

                                                 -- bug 3199488, start block
                                                IF (l_state_level >= l_debug_level) THEN
                                                   FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_revalue_process_pkg.revalue_main.Msg28',
                                                                                 ' IGCCREPB -- locking cc po for release FALSE' || to_char(sysdate,'DD-MON-YY:MI:SS'));
                                                END IF;
                                                -- bug 3199488, end block

				               /* bug 1622969 */

						/* Update releases status in igc_cc_process_data */
				                UPDATE igc_cc_process_data
				                SET validation_status = 'F',
				                    processed = 'Y'
			                	WHERE cc_header_id = l_rel_cc_header_id AND
                                                      request_id   = l_request_id1;

						/* Update cover status in igc_cc_process_data */
				        	UPDATE igc_cc_process_data
				        	SET    validation_status = 'F',
				                       processed = 'Y'
			                        WHERE cc_header_id = l_cc_header_id AND
                                                	request_id   = l_request_id1;

						/* bug 1622969 */
					END IF;

				END LOOP;
				CLOSE c_all_releases;

--                                IF l_debug_mode = 'Y' THEN
--                                Output_Debug (' IGCCREPB -- Done with releases ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
--                                END IF;

                                -- bug 3199488, start block
                                IF (l_state_level >= l_debug_level) THEN
                                    FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_revalue_process_pkg.revalue_main.Msg29',
                                                                  ' IGCCREPB -- Done with releases ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
                                END IF;
                                -- bug 3199488, end block

			        l_lock_cc_po := TRUE;

				IF (l_lock_cc_po = TRUE)
				THEN
--                                        IF l_debug_mode = 'Y' THEN
--                                        Output_Debug (' IGCCREPB -- lock cc po TRUE ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
--                                        END IF;

                                        -- bug 3199488, start block
                                        IF (l_state_level >= l_debug_level) THEN
                                            FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_revalue_process_pkg.revalue_main.Msg30',
                                                                          ' IGCCREPB -- lock cc po TRUE ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
                                        END IF;
                                        -- bug 3199488, end block

					l_lock_cc_po := lock_cc_po(l_sob_id,l_org_id,l_cc_header_id,l_request_id1);
				END IF;

				IF (l_lock_cc_po = FALSE)
				THEN
--                                        IF l_debug_mode = 'Y' THEN
--                                        Output_Debug (' IGCCREPB -- Lock cc po FALSE ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
--                                        END IF;

                                        -- bug 3199488, start block
                                        IF (l_state_level >= l_debug_level) THEN
                                            FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_revalue_process_pkg.revalue_main.Msg31',
                                                                          ' IGCCREPB -- lock cc po FALSE ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
                                        END IF;
                                        -- bug 3199488, end block

				        /* bug 1622969 */

					/* Update cover status in igc_cc_process_data */
				        UPDATE igc_cc_process_data
				        SET    validation_status = 'F',
				               processed = 'Y'
			                WHERE cc_header_id = l_cc_header_id AND
                                              request_id   = l_request_id1;

					/* Update releases statuses in igc_cc_process_data */
					UPDATE igc_cc_process_data
					SET
						validation_status  = 'F' ,
                                		processed          = 'Y'
					WHERE   request_id         = l_request_id1 AND
						cc_header_id      IN (SELECT cc_header_id
								      FROM igc_cc_headers
								      WHERE NVL(parent_header_id,0) = l_cc_header_id);
				      /* bug 1622969 */
				END IF;


			END IF;

		END LOOP;
		CLOSE c_reval_data;
--                IF l_debug_mode = 'Y' THEN
--                Output_Debug (' IGCCREPB -- Done with reval_data ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
--                END IF;

                -- bug 3199488, start block
                IF (l_state_level >= l_debug_level) THEN
                    FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_revalue_process_pkg.revalue_main.Msg32',
                                                  ' IGCCREPB -- Done with reval_data ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
                END IF;
                -- bug 3199488, end block

	END IF;

	/* End Lock CC and PO */
--        IF l_debug_mode = 'Y' THEN
--           Output_Debug (' IGCCREPB -- Done with Lock CC and PO ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
--        END IF;

        -- bug 3199488, start block
        IF (l_state_level >= l_debug_level) THEN
            FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_revalue_process_pkg.revalue_main.Msg33',
                                          ' IGCCREPB -- Done with lock CC and PO ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
        END IF;
        -- bug 3199488, end block

	IF ((p_process_phase = 'P') OR (p_process_phase = 'F')) AND (l_process_data_count > 0)
	THEN
--        IF l_debug_mode = 'Y' THEN
--        Output_Debug (' IGCCREPB -- Validate Cover for avail amount ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
--        END IF;

        -- bug 3199488, start block
        IF (l_state_level >= l_debug_level) THEN
            FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_revalue_process_pkg.revalue_main.Msg34',
                                          ' IGCCREPB -- Validate Cover for avail amount ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
        END IF;
        -- bug 3199488, end block

	/* Validate all covers for available amount subject to re_valuation */
	OPEN c_cover_reval_data(l_request_id1);
	LOOP

		FETCH c_cover_reval_data INTO l_cc_header_id;
		EXIT WHEN c_cover_reval_data%NOTFOUND;

		/* Get Contract Details */
		SELECT *
		INTO l_cc_headers_rec
		FROM igc_cc_headers
		WHERE cc_header_id = l_cc_header_id;

--                IF l_debug_mode = 'Y' THEN
--                Output_Debug (' IGCCREPB -- Getting account lines ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
--                END IF;

                -- bug 3199488, start block
                IF (l_state_level >= l_debug_level) THEN
                FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_revalue_process_pkg.revalue_main.Msg35',
                                              ' IGCCREPB -- Getting account lines ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
                END IF;
                -- bug 3199488, end block

		OPEN c_acct_lines(l_cc_header_id);
		LOOP
			FETCH c_acct_lines INTO l_cc_acct_lines_rec;
			EXIT WHEN c_acct_lines%NOTFOUND;

			l_cover_acct_func_amt      := 0;
			l_non_reval_acct_amt_total := 0;
			l_reval_acct_amt_total     := 0;

			/* Single release revaluation */
			IF (l_cc_headers_rec.cc_header_id <> NVL(p_cc_header_id,-9999) ) AND (p_cc_header_id IS NOT NULL)
			THEN
--                               IF l_debug_mode = 'Y' THEN
--                               Output_Debug (' IGCCREPB -- Single release revaluation ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
--                               END IF;

                               -- bug 3199488, start block
                               IF (l_state_level >= l_debug_level) THEN
                                   FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_revalue_process_pkg.revalue_main.Msg36',
                                                                ' IGCCREPB -- Getting account lines ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
                               END IF;
                               -- bug 3199488, end block

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
--                                                IF l_debug_mode = 'Y' THEN
--                                                Output_Debug (' IGCCREPB -- Amt total 0 ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
--                                                END IF;

                                                -- bug 3199488, start block
                                                IF (l_state_level >= l_debug_level) THEN
                                                    FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_revalue_process_pkg.revalue_main.Msg37',' IGCCREPB -- Amt total 0 ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
                                                END IF;
                                                -- bug 3199488, end block

						l_non_reval_acct_amt_total := 0;
				END;

				BEGIN

				SELECT SUM(
						NVL(a.cc_acct_func_amt,0) +
						(
						(   (  NVL(a.cc_acct_func_amt,0) -
                                                           -- a.cc_acct_func_billed_amt)
                                                           IGC_CC_COMP_AMT_PKG.COMPUTE_ACCT_FUNC_BILLED_AMT( a.cc_acct_line_id)) / b.conversion_rate
						)     *  (l_rate - b.conversion_rate )
						)
					  )
				INTO   l_reval_acct_amt_total
				--FROM   igc_cc_acct_lines_v a,
				FROM   igc_cc_acct_lines a,
			       	       igc_cc_headers b
			        WHERE  NVL(parent_acct_line_id,0) = l_cc_acct_lines_rec.cc_acct_line_id AND
			               a.cc_header_id      = b.cc_header_id AND
				       b.cc_header_id      = p_cc_header_id;
				EXCEPTION
				WHEN NO_DATA_FOUND
				THEN
--                                        IF l_debug_mode = 'Y' THEN
--                                        Output_Debug (' IGCCREPB -- Amt total 0 ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
--                                        END IF;
                                        -- bug 3199488, start block
                                        IF (l_state_level >= l_debug_level) THEN
                                            FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_revalue_process_pkg.revalue_main.Msg38',
                                                                          ' IGCCREPB -- Amt total 0 ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
                                        END IF;
                                        -- bug 3199488, end block
					l_reval_acct_amt_total := 0;
				END;

				l_cover_acct_func_amt := l_cc_acct_lines_rec.cc_acct_func_amt;
			END IF;

			l_validate_only := 'Y';

			SELECT validate_only
			INTO   l_validate_only
			FROM   igc_cc_process_data
			WHERE  request_id    = l_request_id1 AND
			       cc_header_id  = l_cc_headers_rec.cc_header_id;

			/* Release revaluation only */

			IF (p_cc_header_id IS NULL) AND (l_validate_only = 'Y')
			THEN
				/* added NVL to SUM function below to fix bug 1606212 */
--                                IF l_debug_mode = 'Y' THEN
--                                Output_Debug (' IGCCREPB -- Revalue ONLY ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
--                                END IF;

                                -- bug 3199488, start block
                                IF (l_state_level >= l_debug_level) THEN
                                    FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_revalue_process_pkg.revalue_main.Msg39',
                                                                  ' IGCCREPB -- Revalue ONLY ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
                                END IF;
                                -- bug 3199488, end block

				BEGIN
				SELECT NVL(SUM(NVL(CC_ACCT_FUNC_AMT,0)),0)
				INTO   l_non_reval_acct_amt_total
				FROM   igc_cc_acct_lines a,
			       	       igc_cc_headers b
			        WHERE  NVL(parent_acct_line_id,0) = l_cc_acct_lines_rec.cc_acct_line_id AND
			               a.cc_header_id      = b.cc_header_id AND
                                       NVL(b.parent_header_id,0)  = l_cc_header_id AND
			               ( (b.currency_code = p_currency_code AND b.conversion_type   <> p_rate_type) OR
			                 (b.currency_code <> p_currency_code)  )   ;
				EXCEPTION
				WHEN NO_DATA_FOUND
				THEN
--                                        IF l_debug_mode = 'Y' THEN
--                                        Output_Debug (' IGCCREPB -- NON Revalue amt total 0 ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
--                                        END IF;

                                        -- bug 3199488, start block
                                        IF (l_state_level >= l_debug_level) THEN
                                            FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_revalue_process_pkg.revalue_main.Msg40',
                                                                  ' IGCCREPB -- NON Revalue amt total 0 ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
                                        END IF;
                                        -- bug 3199488, end block

					l_non_reval_acct_amt_total := 0;
				END;

				BEGIN
				SELECT SUM(
						NVL(a.cc_acct_func_amt,0) +
						(
						(   (  NVL(a.cc_acct_func_amt,0) -
                                                       -- a.cc_acct_func_billed_amt)
                                                        IGC_CC_COMP_AMT_PKG.COMPUTE_ACCT_FUNC_BILLED_AMT( a.cc_acct_line_id)) / b.conversion_rate
						)     * (l_rate - b.conversion_rate )
						)
					  )
				INTO   l_reval_acct_amt_total
				--FROM   igc_cc_acct_lines_v a,
				FROM   igc_cc_acct_lines a,
			       	       igc_cc_headers b
			        WHERE  NVL(a.parent_acct_line_id,0) = l_cc_acct_lines_rec.cc_acct_line_id AND
			               a.cc_header_id        = b.cc_header_id AND
                                       NVL(b.parent_header_id,0)  = l_cc_header_id AND
			               ( (b.currency_code    = p_currency_code) AND
					 ( b.conversion_type   =  p_rate_type));
				EXCEPTION
				WHEN NO_DATA_FOUND
				THEN
--                                        IF l_debug_mode = 'Y' THEN
--                                        Output_Debug (' IGCCREPB -- Revalue amt total 0 ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
--                                        END IF;

                                         -- bug 3199488, start block
                                        IF (l_state_level >= l_debug_level) THEN
                                            FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_revalue_process_pkg.revalue_main.Msg41',
                                                                  ' IGCCREPB -- Revalue amt total 0 ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
                                        END IF;
                                        -- bug 3199488, end block

					l_reval_acct_amt_total := 0;
				END;

				l_cover_acct_func_amt := l_cc_acct_lines_rec.cc_acct_func_amt;
			END IF;

			/* Cover  and release revaluation */
			IF (p_cc_header_id IS NOT NULL) AND (l_validate_only = 'N') AND
                            (l_cc_headers_rec.cc_header_id = NVL(p_cc_header_id,-9999) )
			THEN
--                                IF l_debug_mode = 'Y' THEN
--                                Output_Debug (' IGCCREPB -- Cover AND Release revaluation ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
--                                END IF;

                                -- bug 3199488, start block
                                IF (l_state_level >= l_debug_level) THEN
                                    FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_revalue_process_pkg.revalue_main.Msg42',
                                                                ' IGCCREPB -- Cover AND Release revaluation ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
                                END IF;
                                -- bug 3199488, end block

				BEGIN
				SELECT SUM(NVL(CC_ACCT_FUNC_AMT,0))
				INTO   l_non_reval_acct_amt_total
				FROM   igc_cc_acct_lines a,
			       	       igc_cc_headers b
			        WHERE  NVL(parent_acct_line_id,0) = l_cc_acct_lines_rec.cc_acct_line_id AND
                                       NVL(b.parent_header_id,0)  = l_cc_header_id AND
			               a.cc_header_id      = b.cc_header_id AND
			               ( (b.currency_code = p_currency_code AND b.conversion_type   <> p_rate_type) OR
			                 (b.currency_code <> p_currency_code)  )   ;
				EXCEPTION
				WHEN NO_DATA_FOUND
				THEN
--                                        IF l_debug_mode = 'Y' THEN
--                                        Output_Debug (' IGCCREPB -- NON reval acct amt 0 ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
--                                        END IF;

                                        -- bug 3199488, start block
                                        IF (l_state_level >= l_debug_level) THEN
                                            FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_revalue_process_pkg.revalue_main.Msg43',
                                                                          ' IGCCREPB -- NON reval acct amt 0 ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
                                        END IF;
                                        -- bug 3199488, end block

					l_non_reval_acct_amt_total := 0;
				END;

				BEGIN
				SELECT SUM(
						NVL(a.cc_acct_func_amt,0) +
						(
						(   (  NVL(a.cc_acct_func_amt,0) -
                                                       --a.cc_acct_func_billed_amt)
                                                       IGC_CC_COMP_AMT_PKG.COMPUTE_ACCT_FUNC_BILLED_AMT( a.cc_acct_line_id)) /	b.conversion_rate
						)     * (l_rate - b.conversion_rate )
						)
					  )
				INTO   l_reval_acct_amt_total
				--FROM   igc_cc_acct_lines_v a,
				FROM   igc_cc_acct_lines a,
			       	       igc_cc_headers b
			        WHERE  NVL(a.parent_acct_line_id,0) = l_cc_acct_lines_rec.cc_acct_line_id AND
			               a.cc_header_id        = b.cc_header_id AND
			               ( (b.currency_code    = p_currency_code) AND
					 ( b.conversion_type   =  p_rate_type));
				EXCEPTION
				WHEN NO_DATA_FOUND
				THEN
--                                        IF l_debug_mode = 'Y' THEN
--                                        Output_Debug (' IGCCREPB -- reval acct amt 0 ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
--                                        END IF;
                                        -- bug 3199488, start block
                                        IF (l_state_level >= l_debug_level) THEN
                                        FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_revalue_process_pkg.revalue_main.Msg44',
                                                                     ' IGCCREPB -- reval acct amt 0 ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
                                        END IF;
                                        -- bug 3199488, end block
					l_reval_acct_amt_total := 0;
				END;

				l_cover_acct_func_amt :=
					( l_cc_acct_lines_rec.cc_acct_func_amt +
				          ( ( ( l_cc_acct_lines_rec.cc_acct_func_amt -
					        l_cc_acct_lines_rec.cc_acct_func_billed_amt
			                      ) /  l_cc_headers_rec.conversion_rate
				             )  * (l_rate - l_cc_headers_rec.conversion_rate )
				          )
					);
			END IF;

			IF (l_non_reval_acct_amt_total + l_reval_acct_amt_total)
		            >  (l_cover_acct_func_amt)
			THEN
--                                IF l_debug_mode = 'Y' THEN
--                                Output_Debug (' IGCCREPB -- Populating error for amounts ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
--                                END IF;
                                -- bug 3199488, start block
                                IF (l_state_level >= l_debug_level) THEN
                                   FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_revalue_process_pkg.revalue_main.Msg45',
                                                                 ' IGCCREPB -- Populating error for amounts ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
                                END IF;
                                -- bug 3199488, end block

				populate_errors(l_cc_headers_rec.cc_header_id,
                                                p_process_phase,
                                                p_currency_code,
                                                p_rate_type,
		                                l_sob_id,
		                                l_org_id,
                                                l_request_id1);
				EXIT;
			END IF;
--                        IF l_debug_mode = 'Y' THEN
--                        Output_Debug (' IGCCREPB -- Getting PF Lines ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
--                        END IF;

                        -- bug 3199488, start block
                        IF (l_state_level >= l_debug_level) THEN
                            FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_revalue_process_pkg.revalue_main.Msg46',
                                                          ' IGCCREPB -- Getting PF Lines ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
                        END IF;
                        -- bug 3199488, end block

			OPEN c_pf_lines(l_cc_acct_lines_rec.cc_acct_line_id);
			LOOP
				FETCH c_pf_lines INTO l_cc_pmt_fcst_rec;
				EXIT  WHEN c_pf_lines%NOTFOUND;

				l_non_reval_pf_amt_total := 0;
				l_reval_pf_amt_total     := 0;
				l_cover_pf_func_amt      := 0;

			        /* Single release revaluation */
				IF (l_cc_headers_rec.cc_header_id <> NVL(p_cc_header_id,-9999) )
                                    AND (p_cc_header_id IS NOT NULL)
				THEN
--                                        IF l_debug_mode = 'Y' THEN
--                                        Output_Debug (' IGCCREPB -- Single Release revaluation ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
--                                        END IF;

                                        -- bug 3199488, start block
                                        IF (l_state_level >= l_debug_level) THEN
                                            FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_revalue_process_pkg.revalue_main.Msg47',
                                                                          ' IGCCREPB -- Single Release revaluation ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
                                        END IF;
                                        -- bug 3199488, end block

					BEGIN
					SELECT NVL(SUM(NVL(CC_DET_PF_FUNC_AMT,0)),0)
					INTO   l_non_reval_pf_amt_total
					FROM   igc_cc_det_pf a,
					       igc_cc_acct_lines b,
			       	       	       igc_cc_headers c
			                WHERE  NVL(a.parent_acct_line_id,0)   = l_cc_acct_lines_rec.cc_acct_line_id AND
					       NVL(a.parent_det_pf_line_id,0) = l_cc_pmt_fcst_rec.cc_det_pf_line_id AND
					       a.cc_acct_line_id          =   b.cc_acct_line_id AND
			                       b.cc_header_id             =   c.cc_header_id AND
                                               NVL(c.parent_header_id,0)  =   l_cc_header_id AND
					       c.cc_header_id             <>   p_cc_header_id;
					EXCEPTION
					WHEN NO_DATA_FOUND
					THEN
--                                                IF l_debug_mode = 'Y' THEN
--                                                Output_Debug (' IGCCREPB -- Non reval PF amount 0 ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
--                                                END IF;
                                                -- bug 3199488, start block
                                                IF (l_state_level >= l_debug_level) THEN
                                                    FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_revalue_process_pkg.revalue_main.Msg48',
                                                                                  ' IGCCREPB -- Non reval PF amount 0 ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
                                                END IF;
                                                -- bug 3199488, end block
						l_non_reval_pf_amt_total := 0;
					END;


					BEGIN
                                        -- Replaced the view igc_cc_det_pf_v with
                                        -- igc_cc_det_pf.
                                        -- Also replaced the following line.
				        -- ( NVL(a.cc_det_pf_func_amt,0) - a.cc_det_pf_func_billed_amt

					SELECT SUM( NVL(a.cc_det_pf_func_amt,0) +
						   (
						   (
						     ( NVL(a.cc_det_pf_func_amt,0) -
                                                       NVL(IGC_CC_COMP_AMT_PKG.COMPUTE_PF_FUNC_BILLED_AMT(a.cc_det_pf_line_id,  a.cc_det_pf_line_num, a.cc_acct_line_id),0)
					              ) / c.conversion_rate
                                                    ) * (l_rate - c.conversion_rate)
						   )
						  )
					INTO   l_reval_pf_amt_total
					FROM   igc_cc_det_pf a,
					       igc_cc_acct_lines b,
			       	       	       igc_cc_headers c
			                WHERE  NVL(a.parent_acct_line_id,0)   = l_cc_acct_lines_rec.cc_acct_line_id AND
					       NVL(a.parent_det_pf_line_id,0) = l_cc_pmt_fcst_rec.cc_det_pf_line_id AND
					       a.cc_acct_line_id       = b.cc_acct_line_id AND
			                       b.cc_header_id          = c.cc_header_id AND
                                               c.org_id                = l_org_id AND
					       c.cc_header_id          = p_cc_header_id;
					EXCEPTION
					WHEN NO_DATA_FOUND
					THEN
--                                                IF l_debug_mode = 'Y' THEN
--                                                Output_Debug (' IGCCREPB -- reval PF amount 0 ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
--                                                END IF;
                                                -- bug 3199488, start block
                                                IF (l_state_level >= l_debug_level) THEN
                                                    FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_revalue_process_pkg.revalue_main.Msg49', ' IGCCREPB -- reval PF amount 0 ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
                                                END IF;
                                                -- bug 3199488, end block

						l_reval_pf_amt_total := 0;
					END;

					l_cover_pf_func_amt := l_cc_pmt_fcst_rec.cc_det_pf_func_amt;

				END IF;

			        /* Cover  and release revaluation */
				IF (p_cc_header_id IS NOT NULL) AND (l_validate_only = 'N') AND
                                   (l_cc_headers_rec.cc_header_id =  NVL(p_cc_header_id,-9999) )
				THEN
--                                        IF l_debug_mode = 'Y' THEN
--                                        Output_Debug (' IGCCREPB -- Cover AND release reval ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
--                                        END IF;

                                        -- bug 3199488, start block
                                        IF (l_state_level >= l_debug_level) THEN
                                            FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_revalue_process_pkg.revalue_main.Msg50',
                                                                          ' IGCCREPB -- Cover AND release reval ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
                                        END IF;
                                        -- bug 3199488, end block

					BEGIN
					SELECT SUM(NVL(CC_DET_PF_FUNC_AMT,0))
					INTO   l_non_reval_pf_amt_total
					FROM   igc_cc_det_pf a,
					       igc_cc_acct_lines b,
			       	       	       igc_cc_headers c
			                WHERE  NVL(a.parent_acct_line_id,0)   = l_cc_acct_lines_rec.cc_acct_line_id AND
					       NVL(a.parent_det_pf_line_id,0) = l_cc_pmt_fcst_rec.cc_det_pf_line_id AND
                                               NVL(c.parent_header_id,0)  =   l_cc_header_id AND
					              a.cc_acct_line_id       = b.cc_acct_line_id AND
			                              b.cc_header_id          = c.cc_header_id AND
			               ( (c.currency_code = p_currency_code AND c.conversion_type   <> p_rate_type) OR
			                 (c.currency_code <> p_currency_code)  )   ;
					EXCEPTION
					WHEN NO_DATA_FOUND
					THEN
--                                                IF l_debug_mode = 'Y' THEN
--                                                Output_Debug (' IGCCREPB -- NON reval PF amt 0 ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
--                                                END IF;

                                                -- bug 3199488, start block
                                                IF (l_state_level >= l_debug_level) THEN
                                                    FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_revalue_process_pkg.revalue_main.Msg51',' IGCCREPB -- NON reval PF amt 0 ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
                                                END IF;
                                                -- bug 3199488, end block

						l_non_reval_pf_amt_total := 0;
					END;


					BEGIN
                                        -- Replaced view igc_cc_det_pf_v with
                                        -- igc_cc_det_pf. Also replaced the following
                                        -- line.
				        -- ( NVL(a.cc_det_pf_func_amt,0) - a.cc_det_pf_func_billed_amt
					SELECT SUM( NVL(a.cc_det_pf_func_amt,0) +
						   (
						   (
						     ( NVL(a.cc_det_pf_func_amt,0) -
                                                       NVL(IGC_CC_COMP_AMT_PKG.COMPUTE_PF_FUNC_BILLED_AMT(a.cc_det_pf_line_id,  a.cc_det_pf_line_num, a.cc_acct_line_id),0)
					              )  /  c.conversion_rate
                                                    )   *  (l_rate - c.conversion_rate)
						   )
						  )
					INTO   l_reval_pf_amt_total
					FROM   igc_cc_det_pf a,
					       igc_cc_acct_lines b,
			       	       	       igc_cc_headers c
			                WHERE  NVL(a.parent_acct_line_id,0)   = l_cc_acct_lines_rec.cc_acct_line_id AND
					       NVL(a.parent_det_pf_line_id,0) = l_cc_pmt_fcst_rec.cc_det_pf_line_id AND
                                               NVL(c.parent_header_id,0)  =   l_cc_header_id AND
					       a.cc_acct_line_id       = b.cc_acct_line_id AND
			                       b.cc_header_id          = c.cc_header_id AND
			               		(  c.currency_code = p_currency_code AND
						   c.conversion_type   = p_rate_type)    ;
					EXCEPTION
					WHEN NO_DATA_FOUND
					THEN
--                                                IF l_debug_mode = 'Y' THEN
--                                                Output_Debug (' IGCCREPB -- reval PF amt 0 ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
--                                                END IF;
                                                -- bug 3199488, start block
                                                IF (l_state_level >= l_debug_level) THEN
                                                    FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_revalue_process_pkg.revalue_main.Msg52',' IGCCREPB -- reval PF amt 0 ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
                                                END IF;
                                                -- bug 3199488, end block
						l_reval_pf_amt_total := 0;
					END;

					l_cover_pf_func_amt :=
					( l_cc_pmt_fcst_rec.cc_det_pf_func_amt +
				           ( ( ( l_cc_pmt_fcst_rec.cc_det_pf_func_amt -
						 l_cc_pmt_fcst_rec.cc_det_pf_func_billed_amt
			                       ) / l_cc_headers_rec.conversion_rate
				             )   * (l_rate - l_cc_headers_rec.conversion_rate )
				          )
					);

				END IF;

			        /* Release revaluation only */
				IF (p_cc_header_id IS NULL) AND (l_validate_only = 'Y')
				THEN
--                                        IF l_debug_mode = 'Y' THEN
--                                        Output_Debug (' IGCCREPB -- Release REVAL Only ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
--                                        END IF;
                                        -- bug 3199488, start block
                                        IF (l_state_level >= l_debug_level) THEN
                                            FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_revalue_process_pkg.revalue_main.Msg53',
                                                                          ' IGCCREPB -- Release REVAL Only ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
                                        END IF;
                                        -- bug 3199488, end block

					BEGIN
					SELECT NVL(SUM(NVL(CC_DET_PF_FUNC_AMT,0)),0)
					INTO   l_non_reval_pf_amt_total
					FROM   igc_cc_det_pf a,
					       igc_cc_acct_lines b,
			       	       	       igc_cc_headers c
			                WHERE  NVL(a.parent_acct_line_id,0)   = l_cc_acct_lines_rec.cc_acct_line_id AND
					       NVL(a.parent_det_pf_line_id,0) = l_cc_pmt_fcst_rec.cc_det_pf_line_id AND
                                               NVL(c.parent_header_id,0)  =   l_cc_header_id AND
					       a.cc_acct_line_id       = b.cc_acct_line_id AND
			                       b.cc_header_id          = c.cc_header_id AND
			               ( (c.currency_code = p_currency_code AND c.conversion_type   <> p_rate_type) OR
			                 (c.currency_code <> p_currency_code)  )   ;
					EXCEPTION
					WHEN NO_DATA_FOUND
					THEN
--                                                IF l_debug_mode = 'Y' THEN
--                                                Output_Debug (' IGCCREPB -- NON raval PF amt 0 ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
--                                                END IF;
                                                -- bug 3199488, start block
                                                IF (l_state_level >= l_debug_level) THEN
                                                    FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_revalue_process_pkg.revalue_main.Msg54',
                                                                                  ' IGCCREPB -- Non raval PF amt 0 ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
                                                END IF;
                                                -- bug 3199488, end block
						l_non_reval_pf_amt_total := 0;
					END;


					BEGIN

                                        -- Replaced the view igc_cc_det_pf_v with
                                        -- igc_cc_det_pf and replaced the
                                        -- following line.
				        -- ( NVL(a.cc_det_pf_func_amt,0) - a.cc_det_pf_func_billed_amt
					SELECT SUM( NVL(a.cc_det_pf_func_amt,0) +
						   (
						   (
						     ( NVL(a.cc_det_pf_func_amt,0) -
                                                       Nvl(IGC_CC_COMP_AMT_PKG.COMPUTE_PF_FUNC_BILLED_AMT(a.cc_det_pf_line_id,  a.cc_det_pf_line_num, a.cc_acct_line_id),0)
					              ) / c.conversion_rate
                                                    )  *   (l_rate - c.conversion_rate)
						   )
						  )
					INTO   l_reval_pf_amt_total
					FROM   igc_cc_det_pf a,
					       igc_cc_acct_lines b,
			       	       	       igc_cc_headers c
			                WHERE  NVL(a.parent_acct_line_id,0)   = l_cc_acct_lines_rec.cc_acct_line_id AND
					       NVL(a.parent_det_pf_line_id,0) = l_cc_pmt_fcst_rec.cc_det_pf_line_id AND
                                               NVL(c.parent_header_id,0)  =   l_cc_header_id AND
					       a.cc_acct_line_id       = b.cc_acct_line_id AND
			                       b.cc_header_id          = c.cc_header_id AND
			               		(  c.currency_code = p_currency_code AND
						   c.conversion_type   = p_rate_type)    ;
					EXCEPTION
					WHEN NO_DATA_FOUND
					THEN
--                                                IF l_debug_mode = 'Y' THEN
--                                                Output_Debug (' IGCCREPB -- raval PF amt 0 ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
--                                                END IF;
                                                -- bug 3199488, start block
                                                IF (l_state_level >= l_debug_level) THEN
                                                    FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_revalue_process_pkg.revalue_main.Msg55',
                                                                                  ' IGCCREPB -- Non raval PF amt 0 ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
                                                END IF;
                                                -- bug 3199488, end block
						l_reval_pf_amt_total := 0;
					END;

					l_cover_pf_func_amt := l_cc_pmt_fcst_rec.cc_det_pf_func_amt;

				END IF;

				IF (l_non_reval_pf_amt_total + l_reval_pf_amt_total)
			           > (l_cover_pf_func_amt)
				THEN
					/* Update validation_status to 'F' in temporary table for releases */
--                                        IF l_debug_mode = 'Y' THEN
--                                        Output_Debug (' IGCCREPB -- Populate error PF amt ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
--                                        END IF;

                                        -- bug 3199488, start block
                                        IF (l_state_level >= l_debug_level) THEN
                                            FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_revalue_process_pkg.revalue_main.Msg56',
                                                                          ' IGCCREPB -- Populate error PF amt ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
                                        END IF;
                                        -- bug 3199488, end block

					populate_errors(l_cc_headers_rec.cc_header_id,
							p_process_phase,
                                                        p_currency_code,
                                                        p_rate_type,
			                                l_sob_id,
			                                l_org_id,
                                                        l_request_id1);
					EXIT;
				END IF;

			END LOOP; /* payment forecast */
			CLOSE c_pf_lines;
--                        IF l_debug_mode = 'Y' THEN
--                        Output_Debug (' IGCCREPB -- Done with PF line cursor ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
--                        END IF;

                        -- bug 3199488, start block
                        IF (l_state_level >= l_debug_level) THEN
                            FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_revalue_process_pkg.revalue_main.Msg57',
                                                          ' IGCCREPB -- Done with PF line cursor ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
                        END IF;
                        -- bug 3199488, end block

		END LOOP; /* Account Lines */
		CLOSE c_acct_lines;
--                IF l_debug_mode = 'Y' THEN
--                Output_Debug (' IGCCREPB -- Done with ACCT line cursor ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
--                END IF;

                -- bug 3199488, start block
                IF (l_state_level >= l_debug_level) THEN
                    FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_revalue_process_pkg.revalue_main.Msg58',
                                                  ' IGCCREPB -- Done with ACCT line cursor ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
                END IF;
                -- bug 3199488, end block

	END LOOP; /* Cover Contract Commitments */

	CLOSE c_cover_reval_data;
--        IF l_debug_mode = 'Y' THEN
--        Output_Debug (' IGCCREPB -- Done with cover reval cursor ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
--        END IF;

        -- bug 3199488, start block
        IF (l_state_level >= l_debug_level) THEN
            FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_revalue_process_pkg.revalue_main.Msg59',
                                          ' IGCCREPB -- Done with cover reval cursor ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
        END IF;
        -- bug 3199488, end block

	/* Validate Contract Commitments */

	/* Validate all contract commitments subject to re_valuation */
--        IF l_debug_mode = 'Y' THEN
--        Output_Debug (' IGCCREPB -- Validate contract commitment cursor ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
--        END IF;

        -- bug 3199488, start block
        IF (l_state_level >= l_debug_level) THEN
            FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_revalue_process_pkg.revalue_main.Msg60',
                                          ' IGCCREPB -- Validate contract commitment cursor ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
        END IF;
        -- bug 3199488, end block

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

--                IF l_debug_mode = 'Y' THEN
--                Output_Debug (' IGCCREPB -- calling Validate CC ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
--                END IF;

                -- bug 3199488, start block
                IF (l_state_level >= l_debug_level) THEN
                    FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_revalue_process_pkg.revalue_main.Msg61',
                                                  ' IGCCREPB -- calling Validate CC ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
                END IF;
                -- bug 3199488, end block

		l_validation_status := IGC_CC_REP_YEP_PVT.validate_cc(p_process_phase   => p_process_phase,
						                      p_process_type    => 'R',
			                                              p_cc_header_id    =>l_cc_header_id,
								      p_sob_id          => l_sob_id,
								      p_org_id          => l_org_id,
								      p_year            => NULL,
                                                                      p_prov_enc_on     => l_prov_enc_on,
                                                                      p_request_id      => l_request_id1);

--                IF l_debug_mode = 'Y' THEN
--                Output_Debug (' IGCCREPB -- Done calling Validate CC ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
--                END IF;

                -- bug 3199488, start block
                IF (l_state_level >= l_debug_level) THEN
                    FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_revalue_process_pkg.revalue_main.Msg62',
                                                  ' IGCCREPB -- Done calling Validate CC ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
                END IF;
                -- bug 3199488, end block

		IF (l_cc_headers_rec.cc_type = 'C')
		THEN
			IF (l_curr_validation_status <> 'I')
			THEN
				l_validation_status := l_curr_validation_status;
			END IF;
		END IF;

		/* Preliminary phase */
--                IF l_debug_mode = 'Y' THEN
--                Output_Debug (' IGCCREPB -- Checking Preliminary Phase ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
--                END IF;

                -- bug 3199488, start block
                IF (l_state_level >= l_debug_level) THEN
                    FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_revalue_process_pkg.revalue_main.Msg63',
                                                  ' IGCCREPB -- Checking Preliminary Phase ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
                END IF;
                -- bug 3199488, end block

		IF (p_process_phase = 'P')
		THEN
			/* Update validation status in temporary table*/

--                        IF l_debug_mode = 'Y' THEN
--                        Output_Debug (' IGCCREPB -- Preliminary Phase ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
--                        END IF;

                        -- bug 3199488, start block
                        IF (l_state_level >= l_debug_level) THEN
                            FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_revalue_process_pkg.revalue_main.Msg64',
                                                          ' IGCCREPB -- Preliminary Phase ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
                        END IF;
                        -- bug 3199488, end block

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
--                        IF l_debug_mode = 'Y' THEN
--                        Output_Debug (' IGCCREPB -- Checking Cover header type ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
--                        END IF;

                        -- bug 3199488, start block
                        IF (l_state_level >= l_debug_level) THEN
                            FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_revalue_process_pkg.revalue_main.Msg65',
                                                          ' IGCCREPB -- Checking Cover header type ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
                        END IF;
                        -- bug 3199488, end block

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
							      WHERE NVL(parent_header_id,0) = l_cc_header_id);

			 END IF;

			 COMMIT;
--                         IF l_debug_mode = 'Y' THEN
--                         Output_Debug (' IGCCREPB -- Done prelim phase ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
--                         END IF;

                        -- bug 3199488, start block
                        IF (l_state_level >= l_debug_level) THEN
                            FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_revalue_process_pkg.revalue_main.Msg66',
                                                          ' IGCCREPB -- Done prelim phase ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
                        END IF;
                        -- bug 3199488, end block

		END IF; /* Preliminary Phase */

		/* Final phase */
--                IF l_debug_mode = 'Y' THEN
--                Output_Debug (' IGCCREPB -- Checking if Final Phase ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
--                END IF;

                -- bug 3199488, start block
                IF (l_state_level >= l_debug_level) THEN
                    FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_revalue_process_pkg.revalue_main.Msg67',
                                                  ' IGCCREPB -- Checking if Final Phase ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
                END IF;
                -- bug 3199488, end block

		IF (p_process_phase = 'F')
		THEN
			/* Passed Validation */
--                        IF l_debug_mode = 'Y' THEN
--                        Output_Debug (' IGCCREPB -- Final Phase ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
--                        END IF;

                        -- bug 3199488, start block
                        IF (l_state_level >= l_debug_level) THEN
                            FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_revalue_process_pkg.revalue_main.Msg68',
                                                          ' IGCCREPB -- Final Phase ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
                        END IF;
                        -- bug 3199488, end block

			IF (l_validation_status = 'P')
			THEN
				/* Update validation status, store old status in temporary table */
--                                IF l_debug_mode = 'Y' THEN
--                                Output_Debug (' IGCCREPB -- Passed validation ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
--                                END IF;

                                -- bug 3199488, start block
                                IF (l_state_level >= l_debug_level) THEN
                                    FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_revalue_process_pkg.revalue_main.Msg69',
                                                          ' IGCCREPB -- Passed validation ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
                                END IF;
                                -- bug 3199488, end block

				IF (l_cc_headers_rec.cc_type = 'C') OR (l_cc_headers_rec.cc_type = 'S')
				THEN
--                                        IF l_debug_mode = 'Y' THEN
--                                        Output_Debug (' IGCCREPB -- Updating process data table ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
--                                        END IF;

                                        -- bug 3199488, start block
                                        IF (l_state_level >= l_debug_level) THEN
                                            FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_revalue_process_pkg.revalue_main.Msg70',
                                                          ' IGCCREPB -- Updating process data table ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
                                        END IF;
                                        -- bug 3199488, end block

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
--                                        IF l_debug_mode = 'Y' THEN
--                                        Output_Debug (' IGCCREPB -- Updating Headers table ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
--                                        END IF;
                                        -- bug 3199488, start block
                                        IF (l_state_level >= l_debug_level) THEN
                                            FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_revalue_process_pkg.revalue_main.Msg71',
                                                          ' IGCCREPB -- Updating Headers table ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
                                        END IF;
                                        -- bug 3199488, end block
					UPDATE   igc_cc_headers
					SET      cc_apprvl_status = 'IP'
					WHERE    cc_header_id     = l_cc_header_id;
				END IF;

				/* Added the following code for bug 1613811 */
				/* Change begin */
--                                IF l_debug_mode = 'Y' THEN
--                                Output_Debug (' IGCCREPB -- Checking CC type Standard ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
--                                END IF;

                                -- bug 3199488, start block
                                IF (l_state_level >= l_debug_level) THEN
                                    FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_revalue_process_pkg.revalue_main.Msg72',
                                                                  ' IGCCREPB -- Checking CC type Standard ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
                                END IF;
                                -- bug 3199488, end block

				IF (l_cc_headers_rec.cc_type = 'S')
				THEN
--                                        IF l_debug_mode = 'Y' THEN
--                                    Output_Debug (' IGCCREPB -- Standard CC getting PO line count ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
--                                        END IF;

                                        -- bug 3199488, start block
                                        IF (l_state_level >= l_debug_level) THEN
                                            FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_revalue_process_pkg.revalue_main.Msg73',
                                                                  ' IGCCREPB -- Standard CC getting PO line count ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
                                        END IF;
                                        -- bug 3199488, end block

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

--                                        IF l_debug_mode = 'Y' THEN
--                                        Output_Debug (' IGCCREPB -- Checking PO line count ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
--                                        END IF;
                                        -- bug 3199488, start block
                                        IF (l_state_level >= l_debug_level) THEN
                                            FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_revalue_process_pkg.revalue_main.Msg74',
                                                                  ' IGCCREPB -- Checking PO line count ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
                                        END IF;
                                        -- bug 3199488, end block
					IF (l_po_count = 1)
					THEN

						BEGIN
--                                                    IF l_debug_mode = 'Y' THEN
--                                           Output_Debug (' IGCCREPB -- Updating PO Headers ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
--                                                        END IF;
                                                        -- bug 3199488, start block
                                                        IF (l_state_level >= l_debug_level) THEN
                                                            FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_revalue_process_pkg.revalue_main.Msg75',' IGCCREPB -- Updating PO Headers ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
                                                        END IF;
                                                        -- bug 3199488, end block
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

--                                IF l_debug_mode = 'Y' THEN
--                                Output_Debug (' IGCCREPB -- Checking if Cover Type ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
--                                END IF;

                                -- bug 3199488, start block
                                IF (l_state_level >= l_debug_level) THEN
                                    FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_revalue_process_pkg.revalue_main.Msg76',
                                                                  ' IGCCREPB -- Checking if Cover Type ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
                                END IF;
                                -- bug 3199488, end block

				IF (l_cc_headers_rec.cc_type = 'C')
				THEN
--                                        IF l_debug_mode = 'Y' THEN
--                                        Output_Debug (' IGCCREPB -- Obtain all releases ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
--                                        END IF;

                                        -- bug 3199488, start block
                                        IF (l_state_level >= l_debug_level) THEN
                                            FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_revalue_process_pkg.revalue_main.Msg77',
                                                                  ' IGCCREPB -- Obtain all releases ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
                                        END IF;
                                        -- bug 3199488, end block

					OPEN c_all_releases1(l_cc_header_id);
					LOOP
						FETCH c_all_releases1 INTO l_rel_cc_headers_rec;
						EXIT WHEN c_all_releases1%NOTFOUND;

--                                              IF l_debug_mode = 'Y' THEN
--                                            Output_Debug (' IGCCREPB -- Update process data ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
--                                              END IF;

                                                -- bug 3199488, start block
                                                IF (l_state_level >= l_debug_level) THEN
                                                    FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_revalue_process_pkg.revalue_main.Msg78',' IGCCREPB -- Update process data ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
                                                END IF;
                                                -- bug 3199488, end block

						UPDATE igc_cc_process_data
						SET
							validation_status    = l_validation_Status,
							old_approval_status  = l_rel_cc_headers_rec.cc_apprvl_status
						WHERE   request_id           = l_request_id1 AND
							cc_header_id         = l_rel_cc_headers_rec.cc_header_id;

--                                                IF l_debug_mode = 'Y' THEN
--                                             Output_Debug (' IGCCREPB -- Update Header data ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
--                                                END IF;

                                                -- bug 3199488, start block
                                                IF (l_state_level >= l_debug_level) THEN
                                                    FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_revalue_process_pkg.revalue_main.Msg79',' IGCCREPB -- Update Header data ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
                                                END IF;
                                                -- bug 3199488, end block

						UPDATE   igc_cc_headers
						SET      cc_apprvl_status = 'IP'
						WHERE    cc_header_id     = l_rel_cc_headers_rec.cc_header_id ;

						l_po_count := 0;

--                                              IF l_debug_mode = 'Y' THEN
--                                          Output_Debug (' IGCCREPB -- Getting PO line count ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
--                                                END IF;

                                                -- bug 3199488, start block
                                                IF (l_state_level >= l_debug_level) THEN
                                                    FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_revalue_process_pkg.revalue_main.Msg80',' IGCCREPB -- Getting PO line count ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
                                                END IF;
                                                -- bug 3199488, end block

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
--                                                IF l_debug_mode = 'Y' THEN
--                                          Output_Debug (' IGCCREPB -- Update PO Header data ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
--                                              END IF;

                                                -- bug 3199488, start block
                                                IF (l_state_level >= l_debug_level) THEN
                                                    FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_revalue_process_pkg.revalue_main.Msg81',' IGCCREPB -- Update PO Header data ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
                                                END IF;
                                                -- bug 3199488, end block

							BEGIN
								UPDATE po_headers_all
								SET    approved_flag    = 'N'
								WHERE  segment1         = l_rel_cc_headers_rec.cc_num AND
					       			       org_id           = l_rel_cc_headers_rec.org_id AND
					       			       type_lookup_code = 'STANDARD'                  AND
				/* Changed condition below from approved_flag = Y to approved flag = N to fix bug 1613811 */
					       	        	       approved_flag    = 'Y';
							END;
						END IF;

					END LOOP;

					CLOSE c_all_releases1;
--                                        IF l_debug_mode = 'Y' THEN
--                                        Output_Debug (' IGCCREPB -- End Releases Loop ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
--                                        END IF;

                                        -- bug 3199488, start block
                                        IF (l_state_level >= l_debug_level) THEN
                                            FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_revalue_process_pkg.revalue_main.Msg82',
                                                                          ' IGCCREPB -- End Releases Loop ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
                                        END IF;
                                        -- bug 3199488, end block

				END IF;


			ELSIF (l_validation_status = 'F') /* Failed Validation */
			THEN
				/* Update validation status, in temporary table*/
--                                IF l_debug_mode = 'Y' THEN
--                                Output_Debug (' IGCCREPB -- Failed validation ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
--                                END IF;

                                -- bug 3199488, start block
                                IF (l_state_level >= l_debug_level) THEN
                                    FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_revalue_process_pkg.revalue_main.Msg83',
                                                                          ' IGCCREPB -- Failed validation ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
                                END IF;
                                -- bug 3199488, end block

				IF (l_cc_headers_rec.cc_type = 'C') OR (l_cc_headers_rec.cc_type = 'S')
				THEN
--                                        IF l_debug_mode = 'Y' THEN
--                    Output_Debug (' IGCCREPB -- Updating Cover or Standard in process data ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
--                                        END IF;
                                        -- bug 3199488, start block
                                        IF (l_state_level >= l_debug_level) THEN
                                            FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_revalue_process_pkg.revalue_main.Msg84',
                                                                          ' IGCCREPB -- Updating cover or Standard in process data ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
                                        END IF;
                                        -- bug 3199488, end block

					UPDATE igc_cc_process_data
					SET
						validation_status = l_validation_Status ,
                                		processed         = 'Y'
					WHERE   request_id        = l_request_id1 AND
						cc_header_id      = l_cc_header_id;
				END IF;

				IF (l_cc_headers_rec.cc_type = 'C')
				THEN
--                                        IF l_debug_mode = 'Y' THEN
--                                    Output_Debug (' IGCCREPB -- Updating Cover process data ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
--                                        END IF;

                                        -- bug 3199488, start block
                                        IF (l_state_level >= l_debug_level) THEN
                                            FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_revalue_process_pkg.revalue_main.Msg85',
                                                                          ' IGCCREPB -- Updating Cover process data ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
                                        END IF;
                                        -- bug 3199488, end block

					UPDATE igc_cc_process_data
					SET
						validation_status  = l_validation_Status ,
                                		processed          = 'Y'
					WHERE   request_id         = l_request_id1 AND
						cc_header_id      IN (SELECT cc_header_id
								      FROM igc_cc_headers
								      WHERE NVL(parent_header_id,0) = l_cc_header_id);
				END IF;

			END IF;

		END IF; /* Final Phase */

	END LOOP;

	CLOSE c_reval_data;
	COMMIT;
--        IF l_debug_mode = 'Y' THEN
--        Output_Debug (' IGCCREPB -- Done c_reval_data ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
--        END IF;

        -- bug 3199488, start block
        IF (l_state_level >= l_debug_level) THEN
            FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_revalue_process_pkg.revalue_main.Msg86',
                                          ' IGCCREPB -- Done c_reval data ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
        END IF;
        -- bug 3199488, end block

	/* End Validation Phase */

	/* Begin Reservation phase */
--        IF l_debug_mode = 'Y' THEN
--        Output_Debug (' IGCCREPB -- Check if reservation phase is to begin ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
--        END IF;

        -- bug 3199488, start block
        IF (l_state_level >= l_debug_level) THEN
            FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_revalue_process_pkg.revalue_main.Msg87',
                                          ' IGCCREPB -- Check if reservation phase is to begin ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
        END IF;
        -- bug 3199488, end block

	IF (p_process_phase = 'F')
	THEN
		/* Perform Funds Reservation for Contract Commitments */

--                IF l_debug_mode = 'Y' THEN
--                Output_Debug (' IGCCREPB -- reservation phase begins ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
--                END IF;

                -- bug 3199488, start block
                IF (l_state_level >= l_debug_level) THEN
                    FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_revalue_process_pkg.revalue_main.Msg88',
                                                  ' IGCCREPB -- reservation phase begins ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
                END IF;
                -- bug 3199488, end block

		OPEN c_reval_data(l_request_id1);
		LOOP
			FETCH c_reval_data INTO l_cc_header_id;
       			EXIT WHEN c_reval_data%NOTFOUND;

			SELECT *
			INTO l_cc_headers_rec
			FROM igc_cc_headers
			WHERE cc_header_id = l_cc_header_id;


			SELECT  validation_status
			INTO    l_validation_status
			FROM    igc_cc_process_data
		        WHERE   request_id        = l_request_id1 AND
				cc_header_id      = l_cc_header_id ;

			IF (l_validation_status = 'P')
			THEN
--                                IF l_debug_mode = 'Y' THEN
--                                Output_Debug (' IGCCREPB -- Validation status P ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
--                                END IF;

                                -- bug 3199488, start block
                                IF (l_state_level >= l_debug_level) THEN
                                    FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_revalue_process_pkg.revalue_main.Msg89',
                                                            ' IGCCREPB -- Validation status P ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
                                END IF;
                                -- bug 3199488, end block

				l_validate_only := 'Y';

				SELECT validate_only
				INTO   l_validate_only
				FROM   igc_cc_process_data
				WHERE  request_id    = l_request_id1 AND
				       cc_header_id  = l_cc_headers_rec.cc_header_id;


				l_reservation_status := 'P';

				/* Perform funds reservation in Forced mode for  Contract Commitment */


				IF ( ((l_cc_headers_rec.cc_type = 'C') AND (l_validate_only = 'N') ) OR
                       	           (l_cc_headers_rec.cc_type = 'S') )
		        	THEN
--                                        IF l_debug_mode = 'Y' THEN
--                          Output_Debug (' IGCCREPB -- Reservation in Forced mode beginning ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
--                                       END IF;

                                        -- bug 3199488, start block
                                        IF (l_state_level >= l_debug_level) THEN
                                            FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_revalue_process_pkg.revalue_main.Msg90',
                                                                          ' IGCCREPB -- Reservation in Forced mode beginning ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
                                        END IF;
                                        -- bug 3199488, end block

					IF (l_sbc_on = TRUE)
					THEN
						IF ( ( (l_cc_headers_rec.cc_state = 'PR')
                                                       OR (l_cc_headers_rec.cc_state = 'CL') )
                                                       AND (l_prov_enc_on = TRUE)
                                                    )
					           OR
					           ( ( (l_cc_headers_rec.cc_state = 'CM')
                                                       OR (l_cc_headers_rec.cc_state = 'CT') )
                                                       AND (l_conf_enc_on = TRUE)
                                                    )
						THEN
--                                                        IF l_debug_mode = 'Y' THEN
--                                              Output_Debug (' IGCCREPB -- Encumber CC call ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
--                                                       END IF;

                                                        -- bug 3199488, start block
                                                        IF (l_state_level >= l_debug_level) THEN
                                                            FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_revalue_process_pkg.revalue_main.Msg91', ' IGCCREPB -- Encumber CC call ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
                                                       END IF;
                                                        -- bug 3199488, end block

							-- fix bug 2124590 start 1
							UPDATE igc_cc_headers
							SET    cc_version_num = cc_version_num + 1
							WHERE  cc_header_id = l_cc_header_id;

							COMMIT;
							-- fix bug 2124590 end 1

							l_reservation_status :=
							IGC_CC_REP_YEP_PVT.Encumber_CC
							(
  							p_process_type 			=> 'R',
  							p_cc_header_id 			=> l_cc_header_id,
  							p_sbc_on       			=> l_sbc_on,
  							p_cbc_on       			=> l_cbc_on,
							/*Bug No : 6341012. SLA Uptake. Encumbrance Type ID are not required*/
  						--	p_cc_prov_enc_type_id 		=> l_cc_prov_enc_type_id,
  						--	p_cc_conf_enc_type_id 		=> l_cc_conf_enc_type_id,
                       				--	p_req_encumbrance_type_id 	=> l_req_encumbrance_type_id,
  						--	p_purch_encumbrance_type_id 	=> l_purch_encumbrance_type_id,
  							p_currency_code 		=> l_currency_code,
  							p_yr_start_date 		=> NULL,
  							p_yr_end_date 			=> NULL,
  							p_yr_end_cr_date                => NULL,
  							p_yr_end_dr_date                => NULL,
  							p_rate_date                     => l_rate_date,
  							p_rate                          => l_rate,
                                        		p_revalue_fix_date              => NULL );

							-- fix bug 2124590 start 2
							UPDATE igc_cc_headers
							SET    cc_version_num = cc_version_num - 1
							WHERE  cc_header_id = l_cc_header_id;

							COMMIT;
							-- fix bug 2124590 end 2
						ELSE
							l_reservation_status := 'P';
						END IF;
					ELSE
							l_reservation_status := 'P';
					END IF;


				END IF;

				IF (l_reservation_status = 'F')
				THEN

                                    l_approval_status := NULL;

				    select old_approval_status
				    into l_approval_status
				    from igc_cc_process_data
				    where cc_header_id = l_cc_headers_rec.cc_header_id
				    and request_id = l_request_id1;

				    update igc_cc_headers
				    set    cc_apprvl_status = l_approval_status
                                    WHERE    cc_header_id     = l_cc_headers_rec.cc_header_id;


					l_message := NULL;
					FND_MESSAGE.SET_NAME('IGC','IGC_CC_ENCUMBRANCE_FAILURE');
                        		l_message  := FND_MESSAGE.GET;

--                                        IF l_debug_mode = 'Y' THEN
--                           Output_Debug (' IGCCREPB -- Reval Cover Fail process exceptions ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
--                                        END IF;

                                        -- bug 3199488, start block
                                        IF (l_state_level >= l_debug_level) THEN
                                            FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_revalue_process_pkg.revalue_main.Msg92',
                                                                          ' IGCCREPB -- Reval Cover Fail process exceptions ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
                                        END IF;
                                        -- bug 3199488, end block

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
                                        (
					   'R',
	 				   'F',
					   l_cc_headers_rec.cc_header_id,
					   NULL,
					   NULL,
					   l_message,
					   l_org_id,
					   l_sob_id,
                        		   l_request_id1
					);

				END IF;

				/* Update validation status, in temporary table*/
--                                IF l_debug_mode = 'Y' THEN
--                       Output_Debug (' IGCCREPB -- Updating process data after encumber CC ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
--                                END IF;

                                -- bug 3199488, start block
                                IF (l_state_level >= l_debug_level) THEN
                                    FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_revalue_process_pkg.revalue_main.Msg93',
                                                                 ' IGCCREPB -- Updating process data after encumber CC ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
                                END IF;
                                -- bug 3199488, end block

				UPDATE igc_cc_process_data
				SET
					reservation_status  = l_reservation_Status
				WHERE
                               		request_id        = l_request_id1 AND
					cc_header_id      = l_cc_header_id ;

				IF (l_cc_headers_rec.cc_type = 'C')
				THEN
--                                        IF l_debug_mode = 'Y' THEN
--              Output_Debug (' IGCCREPB -- Updating process data after encumber CC for Cover ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
--                                        END IF;

                                        -- bug 3199488, start block
                                        IF (l_state_level >= l_debug_level) THEN
                                            FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_revalue_process_pkg.revalue_main.Msg94',
                                                                 ' IGCCREPB -- Updating process data after encumber CC for Cover ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
                                        END IF;
                                        -- bug 3199488, end block

					UPDATE igc_cc_process_data
					SET
						reservation_status  = l_reservation_Status
					WHERE
                               		        request_id          = l_request_id1 AND
						cc_header_id      IN (SELECT cc_header_id
								      FROM igc_cc_headers
								      WHERE NVL(parent_header_id,0) = l_cc_header_id);
				END IF;

				COMMIT;

				/* Process Cover release */
				IF (l_cc_headers_rec.cc_type = 'C')
				THEN
--                                        IF l_debug_mode = 'Y' THEN
--                                 Output_Debug (' IGCCREPB -- Getting all releases for Cover ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
--                                        END IF;

                                        -- bug 3199488, start block
                                        IF (l_state_level >= l_debug_level) THEN
                                            FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_revalue_process_pkg.revalue_main.Msg95',
                                                                          ' IGCCREPB -- Getting all releases for Cover ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
                                        END IF;
                                        -- bug 3199488, end block

					/* Process the releases */
					l_process_flag := 'P';

					SAVEPOINT REVALUE5;

					OPEN c_all_releases(l_cc_headers_rec.cc_header_id);
					LOOP
						FETCH c_all_releases INTO l_rel_cc_header_id;
						EXIT WHEN c_all_releases%NOTFOUND;


						l_validate_only := 'Y';

						SELECT validate_only
						INTO   l_validate_only
						FROM   igc_cc_process_data
						WHERE  request_id    = l_request_id1 AND
			       			       cc_header_id  = l_rel_cc_header_id;

						l_process_flag := 'P';

						IF (l_reservation_status = 'P')
						THEN

--                                                     IF l_debug_mode = 'Y' THEN
--                                         Output_Debug (' IGCCREPB -- Calling reval_update P ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
--                                                        END IF;
                                                        -- bug 3199488, start block
                                                        IF (l_state_level >= l_debug_level) THEN
                                                            FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_revalue_process_pkg.revalue_main.Msg96',' IGCCREPB -- Calling reval_update P ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
                                                        END IF;
                                                        -- bug 3199488, end block
							l_message := NULL;
							l_err_header_id := NULL;
							l_err_acct_line_id := NULL;
						        l_err_det_pf_line_id := NULL;

							l_process_flag := reval_update(l_rel_cc_header_id,
		      					                       l_rate_date,
		      					                       p_rate,
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
--                                                        IF l_debug_mode = 'Y' THEN
--                                         Output_Debug (' IGCCREPB -- Calling reval_update F ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
--                                                        END IF;

                                                        -- bug 3199488, start block
                                                        IF (l_state_level >= l_debug_level) THEN
                                                            FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_revalue_process_pkg.revalue_main.Msg97',' IGCCREPB -- Calling reval_update F ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
                                                        END IF;
                                                        -- bug 3199488, end block

							l_message := NULL;
							l_err_header_id := NULL;
							l_err_acct_line_id := NULL;
						        l_err_det_pf_line_id := NULL;

							l_process_flag := reval_update(l_rel_cc_header_id,
		      					                       l_rate_date,
		      					                       l_rate,
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
--                                                        IF l_debug_mode = 'Y' THEN
--                                         Output_Debug (' IGCCREPB -- Rolling back Revalues ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
--                                                        END IF;
                                                        -- bug 3199488, start block
                                                        IF (l_state_level >= l_debug_level) THEN
                                                            FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_revalue_process_pkg.revalue_main.Msg98',' IGCCREPB -- Rolling back Revalues ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
                                                        END IF;
                                                        -- bug 3199488, end block
							EXIT;
						END IF;

					END LOOP;

					CLOSE c_all_releases;
--                                        IF l_debug_mode = 'Y' THEN
--                                        Output_Debug (' IGCCREPB -- Done with releases ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
--                                        END IF;

                                        -- bug 3199488, start block
                                        IF (l_state_level >= l_debug_level) THEN
                                            FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_revalue_process_pkg.revalue_main.Msg99',' IGCCREPB -- Done with releases ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
                                        END IF;
                                        -- bug 3199488, end block

					/* Process the cover */
--                                        IF l_debug_mode = 'Y' THEN
--                                      Output_Debug (' IGCCREPB -- Checking to process Cover ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
--                                        END IF;

                                        -- bug 3199488, start block
                                        IF (l_state_level >= l_debug_level) THEN
                                            FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_revalue_process_pkg.revalue_main.Msg100',' IGCCREPB -- Checking to process Cover ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
                                        END IF;
                                        -- bug 3199488, end block

					IF (l_process_flag = 'P')
					THEN
						l_validate_only := 'Y';

--                                                IF l_debug_mode = 'Y' THEN
--                                                Output_Debug (' IGCCREPB -- process Cover ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
--                                                END IF;

                                                -- bug 3199488, start block
                                                IF (l_state_level >= l_debug_level) THEN
                                                    FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_revalue_process_pkg.revalue_main.Msg101','IGCCREPB -- process Cover ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
                                                END IF;
                                                -- bug 3199488, end block

						SELECT validate_only
						INTO   l_validate_only
						FROM   igc_cc_process_data
						WHERE  request_id    = l_request_id1 AND
			       			       cc_header_id  = l_cc_headers_rec.cc_header_id;


						IF (l_reservation_status = 'P')
						THEN
--                                                IF l_debug_mode = 'Y' THEN
--                                           Output_Debug (' IGCCREPB -- Reval Cover Update P ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
--                                                END IF;
                                                 -- bug 3199488, start block
                                                IF (l_state_level >= l_debug_level) THEN
                                                    FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_revalue_process_pkg.revalue_main.Msg102','IGCCREPB -- Reval Cover Update P ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
                                                END IF;
                                                 -- bug 3199488, end block

							l_message := NULL;
							l_err_header_id := NULL;
							l_err_acct_line_id := NULL;
						        l_err_det_pf_line_id := NULL;

							l_process_flag := reval_update(l_cc_headers_rec.cc_header_id,
		      					                       l_rate_date,
		      					                       l_rate,
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
--                                                IF l_debug_mode = 'Y' THEN
--                                           Output_Debug (' IGCCREPB -- Reval Cover Update F ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
--                                                END IF;
                                                -- bug 3199488, start block
                                                IF (l_state_level >= l_debug_level) THEN
                                                    FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_revalue_process_pkg.revalue_main.Msg103','IGCCREPB -- Reval Cover Update F ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
                                                END IF;
                                                 -- bug 3199488, end block

							l_message := NULL;
							l_err_header_id := NULL;
							l_err_acct_line_id := NULL;
						        l_err_det_pf_line_id := NULL;

							l_process_flag := reval_update(l_cc_headers_rec.cc_header_id,
		      					                       l_rate_date,
		      					                       l_rate,
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
					END IF;

					IF  (l_process_flag = 'F')
					THEN
--                                                IF l_debug_mode = 'Y' THEN
--                                              Output_Debug (' IGCCREPB -- Rollback Revalues ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
--                                                END IF;

                                                -- bug 3199488, start block
                                                IF (l_state_level >= l_debug_level) THEN
                                                    FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_revalue_process_pkg.revalue_main.Msg104','IGCCREPB -- Rollback Revalues ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
                                                END IF;
                                                -- bug 3199488, end block

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
						VALUES(
                                                          'R',
                                                          'F',
                                                           l_err_header_id,
                                                           l_err_acct_line_id,
                                                           l_err_det_pf_line_id,
                                                           l_message,
                                                           l_ORG_ID,
                                                           l_SOB_ID,
                                                           l_REQUEST_ID1);
						COMMIT;
					ELSIF (l_process_flag = 'P')
					THEN
--                                                IF l_debug_mode = 'Y' THEN
--                                                Output_Debug (' IGCCREPB -- Commit Revalues ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
--                                                END IF;

                                                -- bug 3199488, start block
                                                IF (l_state_level >= l_debug_level) THEN
                                                    FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_revalue_process_pkg.revalue_main.Msg105','IGCCREPB -- Commit Revalues ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
                                                END IF;
                                                -- bug 3199488, end block

						COMMIT;
					END IF;
				ELSIF (l_cc_headers_rec.cc_type = 'S')
				THEN
--                                        IF l_debug_mode = 'Y' THEN
--                                        Output_Debug (' IGCCREPB -- Standard reval ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
--                                        END IF;

                                        -- bug 3199488, start block
                                        IF (l_state_level >= l_debug_level) THEN
                                            FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_revalue_process_pkg.revalue_main.Msg106','IGCCREPB -- Standard reval ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
                                        END IF;
                                        -- bug 3199488, end block

					SAVEPOINT REVALUE6;

					l_process_flag := 'F';


					IF (l_reservation_status = 'P')
					THEN
--                                        IF l_debug_mode = 'Y' THEN
--                                        Output_Debug (' IGCCREPB -- Standard reval P ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
--                                        END IF;
                                          -- bug 3199488, start block
                                        IF (l_state_level >= l_debug_level) THEN
                                            FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_revalue_process_pkg.revalue_main.Msg107','IGCCREPB -- Standard reval P ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
                                        END IF;
                                        -- bug 3199488, end block
						l_message := NULL;
						l_err_header_id := NULL;
						l_err_acct_line_id := NULL;
						l_err_det_pf_line_id := NULL;

						l_process_flag := reval_update(l_cc_headers_rec.cc_header_id,
		      						               l_rate_date,
		      						               l_rate,
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
					ELSIF (l_reservation_status = 'F')
					THEN
--                                        IF l_debug_mode = 'Y' THEN
--                                        Output_Debug (' IGCCREPB -- Standard reval F ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
--                                        END IF;
                                          -- bug 3199488, start block
                                          IF (l_state_level >= l_debug_level) THEN
                                              FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_revalue_process_pkg.revalue_main.Msg108',
                                                             'IGCCREPB -- Standard reval F ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
                                          END IF;
                                          -- bug 3199488, end block

						l_message := NULL;
						l_err_header_id := NULL;
						l_err_acct_line_id := NULL;
						l_err_det_pf_line_id := NULL;

						l_process_flag := reval_update(l_cc_headers_rec.cc_header_id,
		      						               l_rate_date,
		      						               l_rate,
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
--                                        IF l_debug_mode = 'Y' THEN
--                                      Output_Debug (' IGCCREPB -- Standard Rollback revalue ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
--                                        END IF;
                                          -- bug 3199488, start block
                                          IF (l_state_level >= l_debug_level) THEN
                                              FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_revalue_process_pkg.revalue_main.Msg109',
                                                             'IGCCREPB -- Standard Rollback revalue ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
                                          END IF;
                                          -- bug 3199488, end block
						ROLLBACK TO REVALUE6;

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
						VALUES(
                                                          'R',
                                                          'F',
                                                           l_err_header_id,
                                                           l_err_acct_line_id,
                                                           l_err_det_pf_line_id,
                                                           l_message,
                                                           l_ORG_ID,
                                                           l_SOB_ID,
                                                           l_REQUEST_ID1);
						COMMIT;
					ELSIF (l_process_flag = 'P')
					THEN

--                                        IF l_debug_mode = 'Y' THEN
--                                        Output_Debug (' IGCCREPB -- Standard Commit revalue ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
--                                        END IF;
                                          -- bug 3199488, start block
                                          IF (l_state_level >= l_debug_level) THEN
                                              FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_revalue_process_pkg.revalue_main.Msg110',
                                                                            'IGCCREPB -- Standard Commit revalue ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
                                          END IF;
                                          -- bug 3199488, end block
						COMMIT;
					END IF;

				END IF; /* STANDARD */
			END IF; /* validation_status = P */

		END LOOP;

		CLOSE c_reval_data;
--                IF l_debug_mode = 'Y' THEN
--                Output_Debug (' IGCCREPB -- Close revalue Cursor ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
--                END IF;

                -- bug 3199488, start block
                IF (l_state_level >= l_debug_level) THEN
                    FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_revalue_process_pkg.revalue_main.Msg111',
                                                  'IGCCREPB -- Close revalue Cursor ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
                END IF;
                -- bug 3199488, end block

	END IF; /* Final Phase */
		/* End Reservation Phase */

	END IF;

	/* Begin fix for bug 1609006 */
	IF (l_process_data_count = 0)
	THEN
		l_message := NULL;
        	FND_MESSAGE.SET_NAME('IGC','IGC_CC_REP_NO_CC_SELECTED');
        	l_message := FND_MESSAGE.GET;

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
						VALUES(
                                                          'R',
                                                           p_process_phase,
                                                           NULL,
                                                           NULL,
                                                           NULL,
                                                           l_message,
                                                           l_ORG_ID,
                                                           l_SOB_ID,
                                                           l_REQUEST_ID1);
	END IF;
	/* End fix for bug 1609006 */

	COMMIT;
--        IF l_debug_mode = 'Y' THEN
--           Output_Debug (' IGCCREPB -- End Main submit request ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
--        END IF;

        -- bug 3199488, start block
        IF (l_state_level >= l_debug_level) THEN
            FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_revalue_process_pkg.revalue_main.Msg112',
                                          'IGCCREPB -- End Main submit request ' || to_char(sysdate,'DD-MON-YY:MI:SS'));
        END IF;
        -- bug 3199488, end block

/*Bug No : 6341012. MOAC Uptake. Need to set org_id before submiting a request*/
        Fnd_request.set_org_id(l_org_id);
	l_request_id2 := FND_REQUEST.SUBMIT_REQUEST(
                        	                   'IGC',
                               		            'IGCCRVPR',
                                       		    NULL,
                                            	    NULL,
                                            	    FALSE,
                                            	    l_sob_id,
                                                    l_org_id,
                                                    p_process_phase,
                                                    'R',
                                                    l_request_id1);

-----------------------
-- Start of XML Report
-----------------------

      IF IGC_CC_COMMON_UTILS_PVT.xml_report_enabled THEN
               IGC_CC_COMMON_UTILS_PVT.get_xml_layout_info(
                                            l_lang,
                                            l_terr,
                                            'IGCCRVPR_XML',
                                            'IGC',
                                            'IGCCRVPR_XML' );

               l_layout :=  FND_REQUEST.ADD_LAYOUT(
                                            'IGC',
                                            'IGCCRVPR_XML',
                                            l_lang,
                                            l_terr,
                                            'RTF');

                IF l_layout then
                l_request_id2 := FND_REQUEST.SUBMIT_REQUEST(
                                'IGC',
               	                'IGCCRVPR_XML',
                                NULL,
                                NULL,
                                FALSE,
                                l_sob_id,
                                l_org_id,
                                p_process_phase,
                                'R',
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
              FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_revalue_process_pkg.revalue_main.Excp3',
                                             l_error_text);
          END IF;
          -- bug 3199488, end block
      END LOOP;
   END IF;

EXCEPTION

	WHEN insert_data
	THEN
                IF (FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
                   FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, 'revalue_main');
                END IF;
                -- bug 3199488 start block
                IF (l_unexp_level >= l_debug_level) THEN
                     FND_LOG.MESSAGE(l_unexp_level, 'igc.plsql.igc_cc_revalue_process_pkg.revalue_main.Unexp1',TRUE);
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
                           FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_revalue_process_pkg.revalue_main.Excp4',
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
                       FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_revalue_process_pkg.revalue_main.Excp5',
                                                     l_error_text);
                   END IF;
                   -- bug 3199488, end block
                END IF;
		ROLLBACK TO REVALUE3;

        WHEN OTHERS THEN
                IF (FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
                   FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, 'revalue_main');
                END IF;
                -- bug 3199488, start block
                IF (l_unexp_level >= l_debug_level) THEN
                    FND_MESSAGE.SET_NAME('IGC','IGC_LOGGING_UNEXP_ERROR');
                    FND_MESSAGE.SET_TOKEN('CODE',sqlcode);
                    FND_MESSAGE.SET_TOKEN('MSG',sqlerrm);
                    FND_LOG.MESSAGE(l_unexp_level, 'igc.plsql.igc_cc_revalue_process_pkg.revalue_main.Unexp2',TRUE);
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
                           FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_revalue_process_pkg.revalue_main.Excp6',
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
                       FND_LOG.STRING(l_state_level, 'igc.plsql.igc_cc_revalue_process_pkg.revalue_main.Excp7',
                                                     l_error_text);
                   END IF;
                   -- bug 3199488, end block
                END IF;

END revalue_main;
BEGIN
    l_debug_level  := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
    l_state_level  := FND_LOG.LEVEL_STATEMENT;
    l_proc_level   := FND_LOG.LEVEL_PROCEDURE;
    l_event_level  := FND_LOG.LEVEL_EVENT;
    l_excep_level  := FND_LOG.LEVEL_EXCEPTION;
    l_error_level  := FND_LOG.LEVEL_ERROR;
    l_unexp_level  := FND_LOG.LEVEL_UNEXPECTED;

    l_debug_mode   := NVL(FND_PROFILE.VALUE('IGC_DEBUG_ENABLED'),'N');
    g_debug_flag   := 'N' ;
    g_debug_msg    := NULL;


END IGC_CC_REVALUE_PROCESS_PKG;

/

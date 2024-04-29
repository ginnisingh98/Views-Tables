--------------------------------------------------------
--  DDL for Package Body PSP_ENC_LIQ_TRAN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSP_ENC_LIQ_TRAN" AS
/* $Header: PSPENLQB.pls 120.12.12010000.3 2008/10/17 11:31:15 pvelugul ship $  */

--	##########################################################################
--	This procedure initiates the encumbrance liquidation processes gl/ogm
--	##########################################################################

g_bg_id		NUMBER(15);
g_sob_id	NUMBER(15);
g_payroll_id number;            -- Bug 2039196: Introduced g_payroll_id, g_action_type
g_currency_code   VARCHAR2(15); -- Bug no 2478000 :Qubec Fixes
--g_action_type varchar(1);				Commented for bug fix 4625734 as its no longer used in the process
g_control_rec_found VARCHAR2(10) := 'TRUE';
l_phase_status      number := 0 ;
--G_GMS_AVAILABLE	    BOOLEAN DEFAULT FALSE;	Commented for bug fix 4625734 as its no longer used in the process
g_person_id number(15):= null;  --- added for 3413373
g_term_period_id integer := null; --- added for 3413373
g_actual_term_date date := null;  --- added for 3413373
--g_fatal     NUMBER := 0;				Commented for bug fix 4625734 as its no longer used in the process
g_gms_batch_name varchar2(10); -- 3473294
g_rejected_group_id       integer :=null; -- 3473294
g_accepted_group_id       integer :=null; -- 3473294
--g_invalid_suspense varchar2(1) DEFAULT 'N';       -- Introduced for Restart Update/Quick Update Encumbrance Lines Enh. Commented for Enh. 2768298
			        -- To Check if Encumbrance Liquidation encounters invalid suspense account
g_enable_enc_summ_gl	VARCHAR2(1)	DEFAULT	NVL(fnd_profile.value('PSP_ENABLE_ENC_SUMM_GL'), 'N'); -- Introduced for bug 2259310

/* Introduced the following for bug 2935850 */
  g_insert_str		VARCHAR2(5000);
/* End of Bug 2935850 */

g_gl_run			BOOLEAN;	-- Introduced for Enh. Removal of suspense posting in Liq.
g_liq_has_failed_transactions	BOOLEAN;	-- Introduced for Enh. Removal of suspense posting in Liq.

g_dff_grouping_option		CHAR(1);	-- Introduced for bug fix 2908859
g_request_id			NUMBER(15);	-- Introduced for bug fix 4625734

/*****Commented the following for Create and Update multi thread enh.
PROCEDURE enc_liq_trans(errbuf  OUT NOCOPY VARCHAR2,
                        retcode OUT NOCOPY VARCHAR2,
			p_payroll_action_id IN  NUMBER,
			p_payroll_id IN  NUMBER,
			p_action_type IN VARCHAR2,
			p_business_group_id IN NUMBER,
			p_set_of_books_id IN NUMBER
			) IS

    l_return_status	VARCHAR2(10);
    l_msg_count		NUMBER;
    l_msg_data		VARCHAR2(2000);
 BEGIN
	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Entering ENC_LIQ_TRANS
	p_payroll_id: ' || p_payroll_id || '
	p_action_type: ' || p_action_type || '
	p_business_group_id: ' || p_business_group_id || '
	p_set_of_books_id: ' || p_set_of_books_id);
   g_error_api_path := '';
   fnd_msg_pub.initialize;
   psp_general.TRANSACTION_CHANGE_PURGEBLE;    -- 2431917
		fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	PA Transaction Purgeble Flag set');
   g_bg_id := p_business_group_id;
   g_sob_id := p_set_of_books_id;
   / *Introduced  g_payroll_id global initializations for Restart Update/Quick Update Encumbrance Lines Enh.* /
   g_payroll_id:=p_payroll_id;
   g_currency_code := psp_general.get_currency_code(p_business_group_id);

	g_dff_grouping_option := psp_general.get_enc_dff_grouping_option(p_business_group_id);	-- Introduced for bug fix 2908859
	g_gl_run := FALSE;
	g_liq_has_failed_transactions := FALSE;
	g_request_id := fnd_global.conc_request_id;

	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	g_bg_id: ' || g_bg_id || '
	g_sob_id: ' || g_sob_id || '
	g_payroll_id: ' || g_payroll_id || '
	g_currency_code: ' || g_currency_code || '
	g_control_rec_found: TRUE
	l_phase_status: 0
	g_person_id: ' || g_person_id || '
	g_term_period_id: ' || g_term_period_id || '
	g_actual_term_date: ' || g_actual_term_date || '
	g_gms_batch_name: ' || g_gms_batch_name ||'
	g_rejected_group_id: NULL
	g_accepted_group_id: NULL
	g_enable_enc_summ_gl: ' || g_enable_enc_summ_gl || '
	g_insert_str: ' || g_insert_str || '
	g_dff_grouping_option: ' || g_dff_grouping_option || '
	g_request_id: ' || g_request_id || '
	g_gl_run: FALSE
	g_g_liq_has_failed_transactions: FALSE');
	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Calling enc_batch_begin');

   enc_batch_begin(p_payroll_action_id, p_payroll_id, p_action_type, l_return_status);

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	After enc_batch_begin');
/ ******* No control record found. Exiting from the program successfully ******* /
    IF g_control_rec_found = 'FALSE'
    THEN
          --insert into psp_Stout values(99, 'no control rec found');
	  fnd_message.set_name('PSP','PSP_ENC_NO_LIQ_REC_FOUND');
	  fnd_msg_pub.add;
	  retcode := FND_API.G_RET_STS_SUCCESS;

	  -- Added code for error message handler by Bijoy , 27-Jul-1999

          / *psp_message_s.print_error(p_mode => FND_FILE.LOG,
                                  p_print_header => FND_API.G_TRUE);* /
          if p_action_type IN ('L', 'T') then
          PSP_MESSAGE_S.Print_success;
          end if;
	  return;
    END IF;


/ * Added for Position Control Integration Enh 2505778 * /

 IF p_action_type in ('U','Q') then
     if fnd_profile.value('PSP_ENC_ENABLE_PQH') ='Y' then
	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Calling pqh_psp_integration.relieve_budget_commitments');
        pqh_psp_integration.relieve_budget_commitments('L', l_return_status);
        If l_return_status <>FND_API.G_RET_STS_SUCCESS THEN
	  	fnd_message.set_name('PSP','PSP_ENC_PQH_ERROR');
		fnd_msg_pub.add;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;


       end if;
	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	After pqh_psp_integration.relieve_budget_commitments');
    end if;
 end if;




	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Calling create_gl_enc_liq_lines');
    -- FIRST NORMAL RUN
    -- initiate the gl encumbrance summarization and transfer
    create_gl_enc_liq_lines(p_payroll_id,
                            p_action_type,
			l_return_status
			);

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      --insert into psp_stout values(11,'unex error in gl_enc');
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	After create_gl_enc_liq_lines');
    l_phase_status  :=  11 ;  / * gl enc liq lines created in ist run * /
       --	     insert into psp_stout values( 'l_phase '||l_phase_status );
      -- 	     insert into psp_stout values( 11 ,l_phase_status );

     -- call the user extension to populate attribute1 through attribute30
    IF FND_PROFILE.VALUE('PSP_ST_EXTENSION_ENABLE') = 'Y' THEN
      -- 2968684 added params to following proc
	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Calling psp_st_ext.summary_ext_encumber_liq');
      psp_st_ext.summary_ext_encumber_liq(p_payroll_id,
                                          p_action_type     ,
                                          p_business_group_id,
                                          p_set_of_books_id);
	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	After psp_st_ext.summary_ext_encumber_liq');
    END IF;

	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Calling tr_to_gl_int');
    tr_to_gl_int(	p_payroll_id,
    			p_action_type, -- Added for Restart Update Enh.
			l_return_status
			);

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	After tr_to_gl_int
	Calling create_gms_enc_liq_lines');


    l_phase_status  :=  12 ;  / * gl transfer success  in ist run * /
       --	     insert into psp_stout values( 12 ,l_phase_status );

    -- initiate the ogm encumbrance summarization and transfer
    create_gms_enc_liq_lines(p_payroll_id,
                            p_action_type,
			l_return_status
			);

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	After create_gms_enc_liq_lines');

   l_phase_status  :=  13 ;  / * gms enc liq lines created in ist run * /
       	     --insert_into_psp_stout( 'l_phase '||l_phase_status );
       --	     insert into psp_stout values( 13 ,l_phase_status );

   -- call the user extension to populate attribute1 through attribute30
    IF FND_PROFILE.VALUE('PSP_ST_EXTENSION_ENABLE') = 'Y' THEN
      -- 2968684 added params to following proc
	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Calling psp_st_ext.summary_ext_encumber_liq');
      psp_st_ext.summary_ext_encumber_liq(p_payroll_id,
                                          p_action_type     ,
                                          p_business_group_id,
                                          p_set_of_books_id);
	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	After psp_st_ext.summary_ext_encumber_liq');
    END IF;

--    if (G_GMS_AVAILABLE) then   commented it out as tr_to_gl may still be required even
-- if no records are created in craete_gms_enc

	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Calling tr_to_gms_int');
    	tr_to_gms_int(	p_payroll_id,
    			p_action_type, -- Added for Restart Update Enh.
			l_return_status
			);


    	IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    	END IF;
 --  end if;
	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	After tr_to_gms_int');

    --G_GMS_AVAILABLE := FALSE;		Commented for bug fix 4625734 as its no longer used in the process

    l_phase_status  :=  14 ;  / * gms transfer success ist run * /
       	     --insert_into_psp_stout( 'l_phase '||l_phase_status );

       	--     insert into psp_stout values( 14 ,l_phase_status );

--	Introduced the following for Enh. Removal of Suspense Posting in Liq.
	IF (g_gl_run) THEN
		fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Calling tr_to_gl_int');
		tr_to_gl_int	(p_payroll_id,
				p_action_type,
				l_return_status);

		IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;
		fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	After tr_to_gl_int');

		l_phase_status  :=  16 ;  / * gl transfer success  in 2nd run * /
	END IF;

/ *****	Commented the following for Enh. Removal of Suspense Posting in Liq.
    -- SECOND RUN TO TAKE CARE OF TIE-BACK
    -- initiate the gl summarization

    create_gl_enc_liq_lines(p_payroll_id,
                           p_action_type,
			l_return_status
			);

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    l_phase_status  :=  15 ;  / *  gl enc liq lines created in 2nd run  * /
       	     --insert_into_psp_stout( 'l_phase '||l_phase_status );
       	 --    insert into psp_stout values( 15 ,l_phase_status );

    -- call the user extension to populate attribute1 through attribute30
    IF FND_PROFILE.VALUE('PSP_ST_EXTENSION_ENABLE') = 'Y' THEN
      -- 2968684 added params to following proc
      psp_st_ext.summary_ext_encumber_liq(p_payroll_id,
                                          p_action_type     ,
                                          p_business_group_id,
                                          p_set_of_books_id);
    END IF;

    tr_to_gl_int(	p_payroll_id,
    			p_action_type, -- Added for Restart Update Enh.
			l_return_status
			);

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    l_phase_status  :=  16 ;  / *  gl transfer success  in 2nd run  * /
       	     --insert_into_psp_stout( 'l_phase '||l_phase_status );
       	  --   insert into psp_stout values( 16 ,l_phase_status );

        create_gms_enc_liq_lines(p_payroll_id,
                                p_action_type,
				l_return_status
				);

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    l_phase_status  :=  17 ;  / *  gms enc liq lines created in 2nd run  * /
       	     --insert_into_psp_stout( 'l_phase '||l_phase_status );
       	   --  insert into psp_stout values( 17 ,l_phase_status );

    -- call the user extension to populate attribute1 through attribute30
    IF FND_PROFILE.VALUE('PSP_ST_EXTENSION_ENABLE') = 'Y' THEN
      -- 2968684 added params to following proc
      psp_st_ext.summary_ext_encumber_liq(p_payroll_id,
                                          p_action_type     ,
                                          p_business_group_id,
                                          p_set_of_books_id);
    END IF;

 --   if (G_GMS_AVAILABLE) then

    	tr_to_gms_int(	p_payroll_id,
    			p_action_type, -- Added for Restart Update Enh.
			l_return_status
			);

    	IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    	END IF;
 --   end if;

    l_phase_status  :=  18 ;  / *  gms transfer success 2nd run  * /
       	     --insert_into_psp_stout( 'l_phase '||l_phase_status );
       	   --  insert into psp_stout values( 18 ,l_phase_status );

	End of comment for Enh. Removal of Suspense posting in Liq	***** /

	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Calling enc_batch_end');
    enc_batch_end(	p_payroll_action_id,
                    p_payroll_id,
                        p_Action_type,
                        'N',       -- added param Bug 2039196
                        g_bg_id,
                        g_sob_id,
			l_return_status
			);

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	After enc_batch_end');
--      retcode := FND_API.G_RET_STS_SUCCESS;
--	Replaced default successful return status with warning / success based on failed transactions check
	IF (g_liq_has_failed_transactions) THEN
		fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	g_liq_has_failed_transactions: TRUE');
		retcode := fnd_api.g_ret_sts_error;
		fnd_message.set_name('PSP','PSP_ENC_LIQ_TRANS_FAILED');
		fnd_msg_pub.add;
		psp_message_s.print_error(p_mode => FND_FILE.LOG,
			p_print_header => FND_API.G_TRUE);
	ELSE
		fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	g_liq_has_failed_transactions: FALSE');
		retcode := FND_API.G_RET_STS_SUCCESS;
	END IF;
--	End of changes for Enh. removal of suspense posting in liquidation.

	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Leaving ENC_LIQ_TRANS');
	-- Added code for error message handler by Bijoy , 27-Jul-1999

          / *psp_message_s.print_error(p_mode => FND_FILE.LOG,
                                  p_print_header => FND_API.G_TRUE);* /
          if p_action_type ='L' then
          PSP_MESSAGE_S.Print_success;
          end if;
 EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     / * Bug 20393936: commented call to batch_end proc and introduced ROLLBACK * /
      ROLLBACK;
      / *
      enc_batch_end(	p_payroll_id,
                        p_Action_type,
			l_return_status
			);

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF; * /

      g_error_api_path := 'ENC_LIQ_TRANS:'||g_error_api_path;
      fnd_msg_pub.add_exc_msg('PSP_ENC_LIQ_TRAN','ENC_LIQ_TRANS');
      retcode := 2;
	-- Added code for error message handler by Bijoy , 27-Jul-1999

	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Leaving ENC_LIQ_TRANS');
          psp_message_s.print_error(p_mode => FND_FILE.LOG,
                                  p_print_header => FND_API.G_TRUE);
          return;
    WHEN OTHERS THEN
     / * Bug 20393936: commented call to batch_end proc and introduced ROLLBACK * /
      ROLLBACK;
      / *
      enc_batch_end(	p_payroll_id,
                        p_Action_type,
			l_return_status
			);

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF; * /

      g_error_api_path := 'ENC_LIQ_TRANS:'||g_error_api_path;
      fnd_msg_pub.add_exc_msg('PSP_ENC_LIQ_TRAN','ENC_LIQ_TRANS');
      retcode := 2;
	-- Added code for error message handler by Bijoy , 27-Jul-1999

	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Leaving ENC_LIQ_TRANS');
          psp_message_s.print_error(p_mode => FND_FILE.LOG,
                                  p_print_header => FND_API.G_TRUE);
          return;
 END enc_liq_trans;
	End of comment for create and update multi thread enh.	*****/

--	Introduced the following for Create and Update multi thread enh.
PROCEDURE enc_liq_trans(p_payroll_action_id		IN 		NUMBER,
			p_business_group_id	IN		NUMBER,
			p_set_of_books_id	IN		NUMBER,
			p_return_status		OUT NOCOPY VARCHAR2) IS
l_return_status		VARCHAR2(10);
l_msg_count		NUMBER;
l_msg_data		VARCHAR2(2000);
BEGIN
	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Entering LIQ_TRANS
	p_payroll_action_id: ' || p_payroll_action_id || '
	p_business_group_id: ' || p_business_group_id || '
	p_set_of_books_id: ' || p_set_of_books_id);
	g_error_api_path := '';

	psp_general.TRANSACTION_CHANGE_PURGEBLE;
	g_bg_id := p_business_group_id;
	g_sob_id := p_set_of_books_id;
	g_gl_run := FALSE;
	g_liq_has_failed_transactions := FALSE;
	g_request_id := fnd_global.conc_request_id;
	g_currency_code := psp_general.get_currency_code(p_business_group_id);
	g_dff_grouping_option := psp_general.get_enc_dff_grouping_option(p_business_group_id);	-- Introduced for bug fix 2908859

	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	PA Transaction Purgeble Flag set');

	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	g_control_rec_found: TRUE
	g_person_id: ' || g_person_id || '
	g_bg_id: ' || g_bg_id || '
	g_sob_id: ' || g_sob_id || '
	g_term_period_id: ' || g_term_period_id || '
	g_actual_term_date: ' || g_actual_term_date || '
	g_gms_batch_name: ' || g_gms_batch_name ||'
	g_rejected_group_id: NULL
	g_accepted_group_id: NULL
	g_enable_enc_summ_gl: ' || g_enable_enc_summ_gl || '
	g_dff_grouping_option: ' || g_dff_grouping_option || '
	g_request_id: ' || g_request_id || '
	g_gl_run: FALSE
	g_g_liq_has_failed_transactions: FALSE');

	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Calling enc_batch_begin');
	enc_batch_begin(p_payroll_action_id, l_return_status);
	IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	After enc_batch_begin');

	IF (g_control_rec_found = 'FALSE') THEN
		fnd_message.set_name('PSP','PSP_ENC_NO_LIQ_REC_FOUND');
		fnd_msg_pub.add;
		p_return_status := FND_API.G_RET_STS_SUCCESS;
		RETURN;
	END IF;

	IF (fnd_profile.value('PSP_ENC_ENABLE_PQH') ='Y') THEN
		fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Calling pqh_psp_integration.relieve_budget_commitments');
		pqh_psp_integration.relieve_budget_commitments('L', l_return_status);

		IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
			fnd_message.set_name('PSP','PSP_ENC_PQH_ERROR');
			fnd_msg_pub.add;
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;
		fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	After pqh_psp_integration.relieve_budget_commitments');
	END IF;

	IF fnd_profile.value('PSP_ST_EXTENSION_ENABLE') = 'Y' THEN
		fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Calling psp_st_ext.summary_ext_encumber_liq');
		psp_st_ext.summary_ext_encumber_liq(p_payroll_action_id, 'U', p_business_group_id, p_set_of_books_id);
		fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	After psp_st_ext.summary_ext_encumber_liq');
	END IF;

	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Calling tr_to_gl_int');
	tr_to_gl_int(p_payroll_action_id, l_return_status);

	IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	After tr_to_gl_int');

	IF FND_PROFILE.VALUE('PSP_ST_EXTENSION_ENABLE') = 'Y' THEN
		fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Calling psp_st_ext.summary_ext_encumber_liq');
		psp_st_ext.summary_ext_encumber_liq(p_payroll_action_id, 'U', p_business_group_id, p_set_of_books_id);
		fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	After psp_st_ext.summary_ext_encumber_liq');
	END IF;

	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Calling tr_to_gms_int');
    	tr_to_gms_int(p_payroll_action_id, l_return_status);

	IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	After tr_to_gms_int');

	IF (g_gl_run) THEN
		fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Calling tr_to_gl_int');
		tr_to_gl_int	(p_payroll_action_id, l_return_status);

		IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;
		fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	After tr_to_gl_int');
	END IF;

	IF (g_liq_has_failed_transactions) THEN
		fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	g_liq_has_failed_transactions: TRUE');
		fnd_message.set_name('PSP','PSP_ENC_LIQ_TRANS_FAILED');
		fnd_msg_pub.add;
		psp_message_s.print_error(p_mode => FND_FILE.LOG, p_print_header => FND_API.G_TRUE);
		p_return_status := fnd_api.g_ret_sts_error;
	ELSE
		fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	g_liq_has_failed_transactions: FALSE');
		p_return_status := FND_API.G_RET_STS_SUCCESS;
	END IF;

	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Calling enc_batch_end');
	enc_batch_end(p_payroll_action_id, p_business_group_id, p_set_of_books_id, l_return_status);
	IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	After enc_batch_end');
	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Leaving LIQ_TRANS');
EXCEPTION
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		g_error_api_path := 'ENC_LIQ_TRANS:'||g_error_api_path;
		fnd_msg_pub.add_exc_msg('PSP_ENC_LIQ_TRAN','ENC_LIQ_TRANS');
		fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Leaving ENC_LIQ_TRANS');
		psp_message_s.print_error(p_mode => FND_FILE.LOG, p_print_header => FND_API.G_TRUE);
		p_return_status := fnd_api.g_ret_sts_unexp_error;
	WHEN OTHERS THEN
		g_error_api_path := 'ENC_LIQ_TRANS:'||g_error_api_path;
		fnd_msg_pub.add_exc_msg('PSP_ENC_LIQ_TRAN','ENC_LIQ_TRANS');
		fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Leaving ENC_LIQ_TRANS');
		psp_message_s.print_error(p_mode => FND_FILE.LOG, p_print_header => FND_API.G_TRUE);
		p_return_status := fnd_api.g_ret_sts_unexp_error;
END enc_liq_trans;
--	End of changes for Create and update multi thread enh.
--	#######################################################################
--	This procedure begins the encumbrance liquidation process

--	Included action_code 'Q' for Quick Update
--      This procedure identifies whether the call is for update ('Q', 'U') or
--	liquidate 'L' and picks up the necessary rows from PSP_ENC_CONTROLS,
--	generates a RUN_ID and updates PSP_ENC_CONTROLS table with
--      the RUN_ID and sets the ACTION_CODE = 'I' where
--      ACTION_TYPE in ('N', 'U', 'Q') and ACTION_CODE = 'P'

--	If the call is for update it will retireve all the rows with time_period_id
--	greater than the last time period for which payroll has been run and if the
--	call is for liquidate, it will retrieve all the rows with time_period_id
--	less than or equal to that of the time period for which payroll was run
--	##########################################################################

 PROCEDURE enc_batch_begin(p_payroll_action_id IN NUMBER,
--			   p_payroll_id IN NUMBER,
--			   p_action_type IN VARCHAR2,
			p_return_status  OUT NOCOPY VARCHAR2
			) IS
l_payroll_run_date	DATE;
l_payroll_id		NUMBER(15);

CURSOR	payroll_id_cur IS
SELECT	DISTINCT payroll_id
FROM	psp_enc_controls
WHERE	payroll_action_id = p_payroll_action_id;

/* Bug 5642002: Replaced earned date with period end date */
CURSOR	payroll_run_date_cur IS
SELECT 	/*+ use_nl(PTP) */ Max(ptp.end_date)
FROM	pay_payroll_actions ppa,
        pay_assignment_actions paa,
        per_time_periods ptp
WHERE  ppa.payroll_action_id = paa.payroll_action_id
   and  ppa.business_group_id = g_bg_id
   AND	ppa.payroll_id	= l_payroll_id
   AND  ppa.action_type	IN ( 'R','Q')
   AND	paa.action_status = 'C'
   and ppa.date_earned between ptp.start_date and ptp.end_date
   and ptp.payroll_id = ppa.payroll_id;

/* Added for bug 2259310 */
CURSOR 	max_period_cur IS
SELECT 	NVL(MAX(time_period_id),0)
FROM	per_time_periods
WHERE	end_date = l_payroll_run_date
/*****	Commented for bug fix 4625734
		(SELECT	MAX(date_earned)
		FROM	pay_payroll_actions ppa
		WHERE	ppa.business_group_id = p_business_group_id
		AND	payroll_id = pec.payroll_id
		AND	action_type = 'R'
		AND	action_status = 'C')
	End of comment for bug fix 4625734	*****/
AND	payroll_id = l_payroll_id;

l_max_time_period  	NUMBER DEFAULT 0;

--	Introduced the following for bug fix 4625734
	CURSOR	enc_control_status_cur1 IS
	SELECT	SUM(number_of_dr),
		SUM(number_of_cr),
		SUM(total_dr_amount),
		SUM(total_cr_amount),
		SUM(gl_dr_amount),
		SUM(gl_cr_amount),
		SUM(ogm_dr_amount),
		SUM(ogm_cr_amount),
		SUM(summ_gl_dr_amount),
		SUM(summ_gl_cr_amount),
		SUM(summ_ogm_dr_amount),
		SUM(summ_ogm_cr_amount),
		MIN(time_period_id),
		MAX(time_period_id),
		COUNT(1),
		action_code,
		action_type,
		NVL(run_id, 0),
		gl_phase,
		gms_phase,
		batch_name
	FROM	psp_enc_controls pec
   	WHERE	payroll_action_id = p_payroll_action_id
--   	WHERE	payroll_id = p_payroll_id
	AND	(total_dr_amount IS NOT NULL OR total_cr_amount IS NOT NULL)
   	AND	action_type IN ('N', 'U', 'Q')
   	AND	action_code IN ('P', 'IL', 'IU')
--	AND	business_group_id = g_bg_id
--	AND	set_of_books_id = g_sob_id
	AND	time_period_id <= l_max_time_period
	GROUP BY	action_code,
		action_type,
		NVL(run_id, 0),
		gl_phase,
		gms_phase,
		batch_name;

	CURSOR	enc_control_status_cur2 IS
	SELECT	SUM(number_of_dr),
		SUM(number_of_cr),
		SUM(total_dr_amount),
		SUM(total_cr_amount),
		SUM(gl_dr_amount),
		SUM(gl_cr_amount),
		SUM(ogm_dr_amount),
		SUM(ogm_cr_amount),
		SUM(summ_gl_dr_amount),
		SUM(summ_gl_cr_amount),
		SUM(summ_ogm_dr_amount),
		SUM(summ_ogm_cr_amount),
		MIN(time_period_id),
		MAX(time_period_id),
		COUNT(1),
		action_code,
		action_type,
		NVL(run_id, 0),
		gl_phase,
		gms_phase,
		batch_name
	FROM	psp_enc_controls pec
   	WHERE	payroll_action_id = p_payroll_action_id
--   	WHERE	payroll_id = p_payroll_id
	AND	(total_dr_amount IS NOT NULL OR total_cr_amount IS NOT NULL)
   	AND	action_type IN ('N', 'U', 'Q')
   	AND	action_code IN ('P', 'IU', 'IL')
--	AND	business_group_id = g_bg_id
--	AND	set_of_books_id = g_sob_id
	AND	time_period_id > l_max_time_period
	GROUP BY	action_code,
		action_type,
		NVL(run_id, 0),
		gl_phase,
		gms_phase,
		batch_name;

/*****	Commented for Create and Update multi thread enh.
	CURSOR	enc_control_status_cur3 IS
	SELECT	SUM(number_of_dr),
		SUM(number_of_cr),
		SUM(total_dr_amount),
		SUM(total_cr_amount),
		SUM(gl_dr_amount),
		SUM(gl_cr_amount),
		SUM(ogm_dr_amount),
		SUM(ogm_cr_amount),
		SUM(summ_gl_dr_amount),
		SUM(summ_gl_cr_amount),
		SUM(summ_ogm_dr_amount),
		SUM(summ_ogm_cr_amount),
		MIN(time_period_id),
		MAX(time_period_id),
		COUNT(1),
		action_code,
		action_type,
		NVL(run_id, 0),
		gl_phase,
		gms_phase,
		batch_name
	FROM	psp_enc_controls pec
   	WHERE	payroll_id = p_payroll_id
	AND	(total_dr_amount IS NOT NULL OR total_cr_amount IS NOT NULL)
   	AND	action_type IN ('N', 'U', 'Q')
   	AND	action_code IN ('P', 'IT')
	AND	business_group_id = g_bg_id
	AND	set_of_books_id = g_sob_id
	AND	time_period_id >= g_term_period_id
	GROUP BY	action_code,
		action_type,
		NVL(run_id, 0),
		gl_phase,
		gms_phase,
		batch_name;
	End of comment for Create and Update multi threa enh.	*****/

	CURSOR	summary_lines_cur IS
	SELECT	pesl.person_id,
		SUBSTR(ppf.full_name, 1, 50) full_name,
		ppf.employee_number,
		pesl.assignment_id,
		paf.assignment_number,
		DECODE(pesl.gl_project_flag, 'G', 'GL', 'Project') gl_project_flag,
		NVL(TO_CHAR(pesl.group_id), ' '),
		NVL(pesl.gms_batch_name, ' '),
		DECODE(pesl.dr_cr_flag, 'D', 'Debit', 'Credit') dr_cr_flag,
		DECODE(pesl.status_code, 'A', 'Accepted', 'L', 'Liquidated', 'S', 'Superceded', 'N', 'New', 'R', 'Rejected', pesl.status_code) status_code,
		SUM(pesl.summary_amount),
		COUNT(1)
	FROM	psp_enc_summary_lines pesl,
		psp_enc_controls pec,
		per_assignments_f paf,
		per_people_f ppf
	WHERE	pesl.enc_control_id = pec.enc_control_id
	AND	paf.assignment_id = pesl.assignment_id
	AND	pesl.effective_date BETWEEN paf.effective_start_date AND paf.effective_end_date
	AND	ppf.person_id = pesl.person_id
	AND	pesl.effective_date BETWEEN ppf.effective_start_date AND ppf.effective_end_date
	AND	pec.payroll_action_id = p_payroll_action_id
--	AND	pec.run_id = g_run_id
--	AND	(	g_person_id IS NULL
--		OR	pesl.person_id = g_person_id)
	GROUP BY	pesl.person_id,
		ppf.full_name,
		ppf.employee_number,
		pesl.assignment_id,
		paf.assignment_number,
		DECODE(pesl.gl_project_flag, 'G', 'GL', 'Project'),
		NVL(TO_CHAR(pesl.group_id), ' '),
		NVL(pesl.gms_batch_name, ' '),
		DECODE(pesl.dr_cr_flag, 'D', 'Debit', 'Credit'),
		DECODE(pesl.status_code, 'A', 'Accepted', 'L', 'Liquidated', 'S', 'Superceded', 'N', 'New', 'R', 'Rejected', pesl.status_code);

TYPE t_number IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE t_number_15 IS TABLE OF NUMBER(15) INDEX BY BINARY_INTEGER;
TYPE t_char_300 IS TABLE OF VARCHAR2(300) INDEX BY BINARY_INTEGER;

TYPE r_enc_control_rec IS RECORD
		(number_of_dr		t_number_15,
		number_of_cr		t_number_15,
		total_dr_amount		t_number,
		total_cr_amount		t_number,
		gl_dr_amount		t_number,
		gl_cr_amount		t_number,
		ogm_dr_amount		t_number,
		ogm_cr_amount		t_number,
		summ_gl_dr_amount	t_number,
		summ_gl_cr_amount	t_number,
		summ_ogm_dr_amount	t_number,
		summ_ogm_cr_amount	t_number,
		min_time_period_id	t_number_15,
		max_time_period_id	t_number_15,
		enc_control_rec_count	t_number,
		action_code		t_char_300,
		action_type		t_char_300,
		run_id			t_number_15,
		gl_phase		t_char_300,
		gms_phase		t_char_300,
		batch_name		t_char_300);
r_enc_controls	r_enc_control_rec;

TYPE r_summary_lines_rec IS RECORD
	(person_id		t_number_15,
	full_name		t_char_300,
	employee_number		t_char_300,
	assignment_id		t_number_15,
	assignment_number	t_char_300,
	gl_project_flag		t_char_300,
	group_id		t_char_300,
	gms_batch_name		t_char_300,
	dr_cr_flag		t_char_300,
	status_code		t_char_300,
	summary_amount		t_number,
	summary_lines_count	t_number_15);

r_summary_lines		r_summary_lines_rec;
--	End of changes for bug fix 4625734

/*****	Commented for bug fix 4625734
   	CURSOR 	enc_control_cur1(p_max_time_period NUMBER) IS
   	SELECT 	enc_control_id,
          	payroll_id,
          	time_period_id
   	FROM   	psp_enc_controls pec
   	WHERE  	payroll_id = nvl(p_payroll_id, payroll_id)
	AND	(total_dr_amount IS NOT NULL OR total_cr_amount IS NOT NULL)
   	AND	action_type in ('N', 'U', 'Q') -- Included 'Q' for Enh. 2143723
   	AND    	action_code in ('P','IL')   --- added 'IL' for 2444657
	AND	business_group_id = g_bg_id
	AND	set_of_books_id = g_sob_id
	AND	time_period_id <=p_max_time_period;

         ---- added cursor for Liq enc for emp termination bug 3413373
        CURSOR  enc_control_cur3 IS
        SELECT  enc_control_id,
                payroll_id,
                time_period_id
        FROM    psp_enc_controls pec
        WHERE   payroll_id = nvl(p_payroll_id, payroll_id)
        AND     (total_dr_amount IS NOT NULL OR total_cr_amount IS NOT NULL)
        AND     action_type in ('N', 'U', 'Q')
        AND     action_code in ('P','IL')
        AND     business_group_id = g_bg_id
        AND     set_of_books_id = g_sob_id
        AND     time_period_id >=  g_term_period_id;   --- g_term_period_id is global var
	End of comment for bug fix 4625734	*****/


	/* Commented for bug 2259310 *******
	(select max(time_period_id) from per_time_periods
	--for bug fix 1971612	where end_date = (select max(effective_date)
				where end_date = (select max(date_earned)
						from pay_payroll_actions
						where business_group_id = g_bg_id
--						and   set_of_books_id = g_sob_id
-- above commented out as there is no set of books column
-- in pay_payroll_actions will go as part of bug 1971612
							and   payroll_id = p_payroll_id
							and   action_type = 'R'
							and   action_status = 'C')
					and payroll_id = p_payroll_id);
/ *	Commented the following for Enh. 2143723 as Super Summarization is obsolete
	Includes Restart Update process fix.
                                        AND EXISTS
                                         (SELECT pelh.assignment_id from psp_enc_summary_lines pesl,
                                                 psp_Enc_lines_history pelh where
                                                 pelh.enc_control_id=pec.enc_control_id and
                                                 pelh.enc_summary_line_id=pesl.enc_summary_line_id
                                           AND pesl.enc_control_id=pec.enc_control_id AND
                                                 pesl.status_code='A');
	End of Enh. fix 2143723 (Includes Restart Update process fix)	* /
	***** Commented for bug 2259310 **/

/*****	Commented for bug fix 4625734
	CURSOR 	enc_control_cur2 (p_max_time_period NUMBER)IS
   	SELECT 	enc_control_id,
          	payroll_id,
          	time_period_id
   	FROM   	psp_enc_controls pec
   	WHERE  	payroll_id = nvl(p_payroll_id, payroll_id)
	AND	(total_dr_amount IS NOT NULL OR total_cr_amount IS NOT NULL)
   	AND	action_type in ('N', 'U', 'Q') -- Included 'Q' for Enh. 2143723
   	AND    	action_code in ('P','IU')  --- added 'IU' for 2444657
	AND	business_group_id = g_bg_id
	AND	set_of_books_id = g_sob_id
	AND	time_period_id > p_max_time_period;
	End of comment for bugfix 4625734	*****/

	/* Commented for bug 2259310   *****************************************
				(select max(time_period_id) from per_time_periods
--for bug fix 1971612		where end_date = (select max(effective_date)
					where end_date = (select max(date_earned)
							from pay_payroll_actions
							where business_group_id = g_bg_id
--				and   set_of_books_id = g_sob_id
-- above commented out as there is no set of books column
-- in pay_payroll_actions, will go as part of bug 1971612
							and   payroll_id = p_payroll_id
							and   action_type = 'R'
							and   action_status = 'C')
					and payroll_id = p_payroll_id);
/ *	Commented the following for Enh. 2143723 as Super Summarization is obsolete
	Includes Restart Update process fix.
                       AND EXISTS          (SELECT pelh.assignment_id from psp_enc_summary_lines pesl,
                                                psp_enc_lines_history pelh WHERE
                                                pelh.enc_control_id=pec.enc_control_id AND
                                                pelh.enc_summary_line_id =pesl.enc_summary_line_id AND
                                                pesl.enc_control_id=pec.enc_control_id AND
                                                pesl.status_code='A' and
                                                pelh.change_flag='N');
	End of Enh. fix 2143723 (Includes Restart Update process fix)	* /
	********************************************  Commented for bug 2259310 */

/*****	Commented for big fix 4625734
	enc_control_rec1		enc_control_cur1%ROWTYPE;
	enc_control_rec2		enc_control_cur2%ROWTYPE;
	enc_control_rec3		enc_control_cur3%ROWTYPE;  --- added for 3413373
	End of comment for bug fix 4625734	*****/
BEGIN
	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Entering ENC_BATCH_BEGIN');
/*****	Commented the following for bug fix 4625734
  if g_person_id is null then    --- 3413373
     	/ * Added for bug 2259310 * /
     	OPEN 	max_period_cur;
     	FETCH 	max_period_cur INTO l_max_time_period;
     	IF max_period_cur%NOTFOUND THEN
     		l_max_time_period := 0;
     	END IF;
     	CLOSE max_period_cur;

     	IF
     		p_action_type  = 'L' THEN
		SELECT psp_st_run_id_s.nextval
  		INTO g_run_id
  		FROM dual;
  			OPEN enc_control_cur1(l_max_time_period);
  			LOOP
   				FETCH enc_control_cur1 INTO enc_control_rec1;
   				IF enc_control_cur1%rowcount = 0
				then
					g_control_rec_found := 'FALSE';
					p_return_status	:= fnd_api.g_ret_sts_success;
					EXIT;
				end if;
   				IF enc_control_cur1%NOTFOUND THEN
     				CLOSE enc_control_cur1;
     				EXIT;
   				END IF;

				UPDATE psp_enc_controls
   				SET action_code = 'IL', / * Changed from 'I' for Restart Update/Quick Update Encumbrance Lines * /
       				run_id = g_run_id
                              --  gms_phase = null,
                              --  gl_phase = null   commented null for 2444657
   				WHERE enc_control_id = enc_control_rec1.enc_control_id;

  			END LOOP;
  	ELSIF 	p_action_type IN ('U', 'Q') THEN -- Included 'Q' for Enh. 2143723
		SELECT psp_st_run_id_s.nextval
  		INTO g_run_id
  		FROM dual;
  			OPEN enc_control_cur2(l_max_time_period);
  			LOOP
   				FETCH enc_control_cur2 INTO enc_control_rec2;
				IF enc_control_cur2%rowcount = 0
				then
					g_control_rec_found := 'FALSE';
					p_return_status	:= fnd_api.g_ret_sts_success;
					EXIT;
				end if;
   				IF enc_control_cur2%NOTFOUND THEN
     				CLOSE enc_control_cur2;
     				EXIT;
   				END IF;

				UPDATE psp_enc_controls
   				SET action_code = 'IU',/ * Changed from 'I' for Restart Update/Quick Update Encumbrance Lines * /
       				run_id = g_run_id
   				WHERE enc_control_id = enc_control_rec2.enc_control_id;
                           --insert into psp_stout values(55,'after updating psp_enc_controls');
                                 ----commit; Bug 2039196: commented this unnecessary commit.
  			END LOOP;
	END IF;
     else    --- introduced else for 3413373
               SELECT psp_st_run_id_s.nextval
                INTO g_run_id
                FROM dual;

                        OPEN enc_control_cur3;
                        LOOP
                                FETCH enc_control_cur3 INTO enc_control_rec3;
                                IF enc_control_cur3%rowcount = 0
                                then
                                        g_control_rec_found := 'FALSE';
                                        p_return_status := fnd_api.g_ret_sts_success;
                                        EXIT;
                                end if;
                                IF enc_control_cur3%NOTFOUND THEN
                                CLOSE enc_control_cur3;
                                EXIT;
                                END IF;

                                UPDATE psp_enc_controls
                                SET action_code = 'IL',
                                    run_id = g_run_id
                                WHERE enc_control_id = enc_control_rec3.enc_control_id;

                        END LOOP;
       end if;

	--COMMIT:
	End of Comment for bug fix 4625734	*****/

	SELECT psp_st_run_id_s.nextval INTO g_run_id FROM dual;

	OPEN payroll_id_cur;
	LOOP
		FETCH payroll_id_cur INTO l_payroll_id;
		EXIT WHEN payroll_id_cur%NOTFOUND;

		OPEN payroll_run_date_cur;
		FETCH payroll_run_date_cur INTO l_payroll_run_date;
		CLOSE payroll_run_date_cur;

/****	Commented the following for Create and Update multi threading enh.
	IF (g_person_id IS NULL) THEN

		OPEN max_period_cur;
		FETCH max_period_cur INTO l_max_time_period;
		IF max_period_cur%NOTFOUND THEN
			l_max_time_period := 0;
		END IF;
     		CLOSE max_period_cur;

		IF (p_action_type = 'L') THEN
	End of comment for Create and Update multi threading enh.	****/

		OPEN enc_control_status_cur1;
		FETCH enc_control_status_cur1 BULK COLLECT INTO r_enc_controls.number_of_dr,
				r_enc_controls.number_of_cr,		r_enc_controls.total_dr_amount,
				r_enc_controls.total_cr_amount,		r_enc_controls.gl_dr_amount,
				r_enc_controls.gl_cr_amount,		r_enc_controls.ogm_dr_amount,
				r_enc_controls.ogm_cr_amount,		r_enc_controls.summ_gl_dr_amount,
				r_enc_controls.summ_gl_cr_amount,	r_enc_controls.summ_ogm_dr_amount,
				r_enc_controls.summ_ogm_cr_amount,	r_enc_controls.min_time_period_id,
				r_enc_controls.max_time_period_id,	r_enc_controls.enc_control_rec_count,
				r_enc_controls.action_code,		r_enc_controls.action_type,
				r_enc_controls.run_id,			r_enc_controls.gl_phase,
				r_enc_controls.gms_phase,		r_enc_controls.batch_name;
		CLOSE enc_control_status_cur1;

		UPDATE	psp_enc_controls pec
		SET	action_code = 'IL',
			run_id = g_run_id,
			liquidate_request_id = g_request_id
		WHERE	payroll_id = l_payroll_id
		AND	(total_dr_amount IS NOT NULL OR total_cr_amount IS NOT NULL)
		AND	action_type in ('N', 'U', 'Q')
		AND	action_code in ('P','IL', 'IU')
		AND	payroll_action_id = p_payroll_action_id
		AND	time_period_id <= l_max_time_period;

		IF SQL%ROWCOUNT > 0 THEN
			g_control_rec_found := 'TRUE';
		END IF;
--		ELSIF (p_action_type IN ('U', 'Q')) THEN	Commented for Create and Update multi thread enh.
		OPEN enc_control_status_cur2;
		FETCH enc_control_status_cur2 BULK COLLECT INTO r_enc_controls.number_of_dr,
				r_enc_controls.number_of_cr,		r_enc_controls.total_dr_amount,
				r_enc_controls.total_cr_amount,		r_enc_controls.gl_dr_amount,
				r_enc_controls.gl_cr_amount,		r_enc_controls.ogm_dr_amount,
				r_enc_controls.ogm_cr_amount,		r_enc_controls.summ_gl_dr_amount,
				r_enc_controls.summ_gl_cr_amount,	r_enc_controls.summ_ogm_dr_amount,
				r_enc_controls.summ_ogm_cr_amount,	r_enc_controls.min_time_period_id,
				r_enc_controls.max_time_period_id,	r_enc_controls.enc_control_rec_count,
				r_enc_controls.action_code,		r_enc_controls.action_type,
				r_enc_controls.run_id,			r_enc_controls.gl_phase,
				r_enc_controls.gms_phase,		r_enc_controls.batch_name;
		CLOSE enc_control_status_cur2;

		UPDATE	psp_enc_controls pec
		SET	action_code = 'IU',
			run_id = g_run_id,
			liquidate_request_id = g_request_id
		WHERE	payroll_id = l_payroll_id
		AND	(total_dr_amount IS NOT NULL OR total_cr_amount IS NOT NULL)
		AND	action_type in ('N', 'U', 'Q')
		AND	action_code in ('P','IU', 'IL')
		AND	payroll_action_id = p_payroll_action_id
		AND	time_period_id > l_max_time_period;

		IF SQL%ROWCOUNT > 0 THEN
			g_control_rec_found := 'TRUE';
		END IF;
	END LOOP;
	CLOSE payroll_id_cur;

/****	Commented the following for Create and Update multi threading enh.
		END IF;
	ELSE
		OPEN enc_control_status_cur3;
		FETCH enc_control_status_cur3 BULK COLLECT INTO r_enc_controls.number_of_dr,
			r_enc_controls.number_of_cr,		r_enc_controls.total_dr_amount,
			r_enc_controls.total_cr_amount,		r_enc_controls.gl_dr_amount,
			r_enc_controls.gl_cr_amount,		r_enc_controls.ogm_dr_amount,
			r_enc_controls.ogm_cr_amount,		r_enc_controls.summ_gl_dr_amount,
			r_enc_controls.summ_gl_cr_amount,	r_enc_controls.summ_ogm_dr_amount,
			r_enc_controls.summ_ogm_cr_amount,	r_enc_controls.min_time_period_id,
			r_enc_controls.max_time_period_id,	r_enc_controls.enc_control_rec_count,
			r_enc_controls.action_code,		r_enc_controls.action_type,
			r_enc_controls.run_id,			r_enc_controls.gl_phase,
			r_enc_controls.gms_phase,		r_enc_controls.batch_name;
		CLOSE enc_control_status_cur3;

   		UPDATE	psp_enc_controls pec
		SET	action_code = 'IT',
			run_id = g_run_id,
			liquidate_request_id = g_request_id
   		WHERE	payroll_id = p_payroll_id
		AND	(total_dr_amount IS NOT NULL OR total_cr_amount IS NOT NULL)
   		AND	action_type in ('N', 'U', 'Q')
   		AND	action_code in ('P','IT')
		AND	business_group_id = g_bg_id
		AND	set_of_books_id = g_sob_id
		AND	time_period_id >= g_term_period_id;

		IF SQL%ROWCOUNT = 0 THEN
			g_control_rec_found := 'FALSE';
		END IF;
	END IF;
	End of comment for Create and Update multi threading enh.	****/

	fnd_file.put_line(fnd_file.output, 'Liquidation Batch Processing, Started at: ' ||
		fnd_date.date_to_canonical(SYSDATE) || '
Run ID: ' || g_run_id || '
Payroll Action Id: ' || p_payroll_action_id || '	Last payroll run date: ' || l_payroll_run_date || '

Encumbrance control record(s) status prior to liquidation processing');
		fnd_file.put_line(fnd_file.output, LPAD('Run ID', 15, ' ') || '	' ||
			RPAD('Action Code', 15, ' ') || '	' ||
			RPAD('Action Type', 15, ' ') || '	' ||
			RPAD('GL Phase', 15, ' ') || '	' ||
			RPAD('GMS Phase', 15, ' ') || '	' ||
			RPAD('Batch Name', 23, ' ') || '	' ||
			LPAD('No of Dr', 15, ' ') || '	' ||
			LPAD('No of Cr', 15, ' ') || '	' ||
			LPAD('Total Dr', 15, ' ') || '	' ||
			LPAD('Total Cr', 15, ' ') || '	' ||
			LPAD('Total GL Dr', 15, ' ') || '	' ||
			LPAD('Total GL Cr', 15, ' ') || '	' ||
			LPAD('Total GMS Dr', 15, ' ') || '	' ||
			LPAD('Total GMS Cr', 15, ' ') || '	' ||
			LPAD('Summary GL Dr', 15, ' ') || '	' ||
			LPAD('Summary GL Cr', 15, ' ') || '	' ||
			LPAD('Summary GMS Dr', 15, ' ') || '	' ||
			LPAD('Summary GMS Cr', 15, ' ') || '	' ||
			LPAD('Control Records', 15, ' ') || '	' ||
			LPAD('Min Time Period', 15, ' ') || '	' ||
			LPAD('Max Time Period', 15, ' '));
		fnd_file.put_line(fnd_file.output, LPAD('-', 15, '-') || '	' || RPAD('-', 15, '-') || '	' ||
			RPAD('-', 15, '-') || '	' || RPAD('-', 15, '-') || '	' || RPAD('-', 15, '-') || '	' ||
			RPAD('-', 23, '-') || '	' || LPAD('-', 15, '-') || '	' || LPAD('-', 15, '-') || '	' ||
			LPAD('-', 15, '-') || '	' || LPAD('-', 15, '-') || '	' || LPAD('-', 15, '-') || '	' ||
			LPAD('-', 15, '-') || '	' || LPAD('-', 15, '-') || '	' || LPAD('-', 15, '-') || '	' ||
			LPAD('-', 15, '-') || '	' || LPAD('-', 15, '-') || '	' || LPAD('-', 15, '-') || '	' ||
			LPAD('-', 15, '-') || '	' || LPAD('-', 15, '-') || '	' || LPAD('-', 15, '-') || '	' ||
			LPAD('-', 15, '-'));
	FOR recno IN 1..r_enc_controls.run_id.COUNT
	LOOP
		fnd_file.put_line(fnd_file.output, LPAD(r_enc_controls.run_id(recno), 15, ' ') || '	' ||
			RPAD(r_enc_controls.action_code(recno), 15, ' ') || '	' ||
			RPAD(r_enc_controls.action_type(recno), 15, ' ') || '	' ||
			RPAD(r_enc_controls.gl_phase(recno), 15, ' ') || '	' ||
			RPAD(r_enc_controls.gms_phase(recno), 15, ' ') || '	' ||
			RPAD(r_enc_controls.batch_name(recno), 23, ' ') || '	' ||
			LPAD(r_enc_controls.number_of_dr(recno), 15, ' ') || '	' ||
			LPAD(r_enc_controls.number_of_cr(recno), 15, ' ') || '	' ||
			LPAD(r_enc_controls.total_dr_amount(recno), 15, ' ') || '	' ||
			LPAD(r_enc_controls.total_cr_amount(recno), 15, ' ') || '	' ||
			LPAD(r_enc_controls.gl_dr_amount(recno), 15, ' ') || '	' ||
			LPAD(r_enc_controls.gl_cr_amount(recno), 15, ' ') || '	' ||
			LPAD(r_enc_controls.ogm_dr_amount(recno), 15, ' ') || '	' ||
			LPAD(r_enc_controls.ogm_cr_amount(recno), 15, ' ') || '	' ||
			LPAD(r_enc_controls.summ_gl_dr_amount(recno), 15, ' ') || '	' ||
			LPAD(r_enc_controls.summ_gl_cr_amount(recno), 15, ' ') || '	' ||
			LPAD(r_enc_controls.summ_ogm_dr_amount(recno), 15, ' ') || '	' ||
			LPAD(r_enc_controls.summ_ogm_cr_amount(recno), 15, ' ') || '	' ||
			LPAD(r_enc_controls.enc_control_rec_count(recno), 15, ' ') || '	' ||
			LPAD(r_enc_controls.min_time_period_id(recno), 15, ' ') || '	' ||
			LPAD(r_enc_controls.max_time_period_id(recno), 15, ' '));
	END LOOP;

	OPEN summary_lines_cur;
	FETCH summary_lines_cur BULK COLLECT INTO r_summary_lines.person_id,	r_summary_lines.full_name,
		r_summary_lines.employee_number,	r_summary_lines.assignment_id,
		r_summary_lines.assignment_number,	r_summary_lines.gl_project_flag,
		r_summary_lines.group_id,		r_summary_lines.gms_batch_name,
		r_summary_lines.dr_cr_flag,		r_summary_lines.status_code,
		r_summary_lines.summary_amount,		r_summary_lines.summary_lines_count;
	CLOSE summary_lines_cur;

	fnd_file.put_line(fnd_file.output, '
Encumbrance summary line(s) status prior to liquidation processing');
	fnd_file.put_line(fnd_file.output, RPAD('Employee Name', 50, ' ') || '	' ||
		RPAD('Employee Number', 30, ' ') || '	' || RPAD('Assignment Number', 30, ' ') || '	' ||
		RPAD('GL Project Flag', 15, ' ') || '	' || LPAD('Group ID', 15, ' ') || '	' ||
		RPAD('GMS Batch Name', 15, ' ') || '	' || RPAD('Dr/Cr Flag', 10, ' ') || '	' ||
		RPAD('Status Code', 15, ' ') || '	' || LPAD('Summary Amount', 15, ' ') || '	' ||
		LPAD('Summary Lines', 15, ' '));

	fnd_file.put_line(fnd_file.output, RPAD('-', 50, '-') || '	' || RPAD('-', 30, '-') || '	' ||
		RPAD('-', 30, '-') || '	' || RPAD('-', 15, '-') || '	' || LPAD('-', 15, '-') || '	' ||
		RPAD('-', 15, '-') || '	' || RPAD('-', 10, '-') || '	' || RPAD('-', 15, '-') || '	' ||
		LPAD('-', 15, '-') || '	' || LPAD('-', 15, '-'));

	FOR recno IN 1..r_summary_lines.person_id.COUNT
	LOOP
		fnd_file.put_line(fnd_file.output, RPAD(r_summary_lines.full_name(recno), 50, ' ') || '	' ||
			RPAD(r_summary_lines.employee_number(recno), 30, ' ') || '	' ||
			RPAD(r_summary_lines.assignment_number(recno), 30, ' ') || '	' ||
			RPAD(r_summary_lines.gl_project_flag(recno), 15, ' ') || '	' ||
			LPAD(r_summary_lines.group_id(recno), 15, ' ') || '	' ||
			RPAD(r_summary_lines.gms_batch_name(recno), 15, ' ') || '	' ||
			RPAD(r_summary_lines.dr_cr_flag(recno), 10, ' ') || '	' ||
			RPAD(r_summary_lines.status_code(recno), 15, ' ') || '	' ||
			LPAD(r_summary_lines.summary_amount(recno), 15, ' ') || '	' ||
			LPAD(r_summary_lines.summary_lines_count(recno), 15, ' '));
	END LOOP;

	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Leaving ENC_BATCH_BEGIN');
	p_return_status	:= fnd_api.g_ret_sts_success;
 END enc_batch_begin;

--	##########################################################################
--	This procedure ends the encumbrance liquidation process

--      This procedure updates the table PSP_ENC_CONTROLS with ACTION_CODE = 'L',
--	if the program is completed with a return code of success and if the
--      return code is failed it updates ACTION_CODE = 'P'

--      When the program returns a failure status, it also updates
--      PSP_ENC_SUMMARY_LINES with STATUS_CODE = 'R'

--	##########################################################################
PROCEDURE enc_batch_end	(p_payroll_action_id		IN	NUMBER,
--			p_payroll_id		IN	NUMBER,
--			p_action_type		IN	VARCHAR2,
--			p_mode			IN	VARCHAR2,
			p_business_group_id	IN	NUMBER,
			p_set_of_books_id	IN	NUMBER,
			p_return_status		OUT	NOCOPY VARCHAR2) IS
CURSOR	enc_control_cur IS
SELECT	DISTINCT enc_control_id
--FROM	psp_enc_controls
FROM	psp_enc_summary_lines
--WHERE	payroll_id = p_payroll_id
WHERE	payroll_action_id = p_payroll_action_id
--AND   run_id = g_run_id
AND	superceded_line_id IS NOT NULL
AND	business_group_id = p_business_group_id
AND	set_of_books_id = p_set_of_books_id;

TYPE t_number IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE t_number_15 IS TABLE OF NUMBER(15) INDEX BY BINARY_INTEGER;
TYPE t_char_300 IS TABLE OF VARCHAR2(300) INDEX BY BINARY_INTEGER;

t_enc_control_id	t_number_15;

CURSOR	enc_control_status_cur IS
SELECT	SUM(number_of_dr),
	SUM(number_of_cr),
	SUM(total_dr_amount),
	SUM(total_cr_amount),
	SUM(gl_dr_amount),
	SUM(gl_cr_amount),
	SUM(ogm_dr_amount),
	SUM(ogm_cr_amount),
	SUM(summ_gl_dr_amount),
	SUM(summ_gl_cr_amount),
	SUM(summ_ogm_dr_amount),
	SUM(summ_ogm_cr_amount),
	MIN(time_period_id),
	MAX(time_period_id),
	COUNT(1),
	action_code,
	action_type,
	run_id,
	gl_phase,
	gms_phase,
	batch_name
FROM	psp_enc_controls pec
--WHERE	payroll_id = p_payroll_id
WHERE	payroll_action_id = p_payroll_action_id
AND	run_id = g_run_id
AND	business_group_id = g_bg_id
AND	set_of_books_id = g_sob_id
GROUP BY	action_code,
	action_type,
	run_id,
	gl_phase,
	gms_phase,
	batch_name;

CURSOR	summary_lines_cur IS
SELECT	pesl.person_id,
	SUBSTR(ppf.full_name, 1, 50) full_name,
	ppf.employee_number,
	pesl.assignment_id,
	paf.assignment_number,
	DECODE(pesl.gl_project_flag, 'G', 'GL', 'Project') gl_project_flag,
	NVL(TO_CHAR(pesl.group_id), ' '),
	NVL(pesl.gms_batch_name, ' '),
	DECODE(pesl.dr_cr_flag, 'D', 'Debit', 'Credit') dr_cr_flag,
	DECODE(pesl.status_code, 'A', 'Accepted', 'L', 'Liquidated', 'S', 'Superceded', 'N', 'New', 'R', 'Rejected', pesl.status_code) status_code,
	SUM(pesl.summary_amount),
	COUNT(1)
FROM	psp_enc_summary_lines pesl,
	psp_enc_controls pec,
	per_assignments_f paf,
	per_people_f ppf
WHERE	pesl.enc_control_id = pec.enc_control_id
AND	paf.assignment_id = pesl.assignment_id
AND	pesl.effective_date BETWEEN paf.effective_start_date AND paf.effective_end_date
AND	ppf.person_id = pesl.person_id
AND	pesl.effective_date BETWEEN ppf.effective_start_date AND ppf.effective_end_date
AND	pec.run_id = g_run_id
AND	(	g_person_id IS NULL
	OR	pesl.person_id = g_person_id)
GROUP BY	pesl.person_id,
	ppf.full_name,
	ppf.employee_number,
	pesl.assignment_id,
	paf.assignment_number,
	DECODE(pesl.gl_project_flag, 'G', 'GL', 'Project'),
	NVL(TO_CHAR(pesl.group_id), ' '),
	NVL(pesl.gms_batch_name, ' '),
	DECODE(pesl.dr_cr_flag, 'D', 'Debit', 'Credit'),
	DECODE(pesl.status_code, 'A', 'Accepted', 'L', 'Liquidated', 'S', 'Superceded', 'N', 'New', 'R', 'Rejected', pesl.status_code);

TYPE r_enc_control_rec IS RECORD
		(number_of_dr		t_number_15,
		number_of_cr		t_number_15,
		total_dr_amount		t_number,
		total_cr_amount		t_number,
		gl_dr_amount		t_number,
		gl_cr_amount		t_number,
		ogm_dr_amount		t_number,
		ogm_cr_amount		t_number,
		summ_gl_dr_amount	t_number,
		summ_gl_cr_amount	t_number,
		summ_ogm_dr_amount	t_number,
		summ_ogm_cr_amount	t_number,
		min_time_period_id	t_number_15,
		max_time_period_id	t_number_15,
		enc_control_rec_count	t_number,
		action_code		t_char_300,
		action_type		t_char_300,
		run_id			t_number_15,
		gl_phase		t_char_300,
		gms_phase		t_char_300,
		batch_name		t_char_300);
r_enc_controls	r_enc_control_rec;

TYPE r_summary_lines_rec IS RECORD
	(person_id		t_number_15,
	full_name		t_char_300,
	employee_number		t_char_300,
	assignment_id		t_number_15,
	assignment_number	t_char_300,
	gl_project_flag		t_char_300,
	group_id		t_char_300,
	gms_batch_name		t_char_300,
	dr_cr_flag		t_char_300,
	status_code		t_char_300,
	summary_amount		t_number,
	summary_lines_count	t_number_15);
r_summary_lines		r_summary_lines_rec;
BEGIN
	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Entering ENC_BATCH_END');
	OPEN enc_control_cur;
	FETCH enc_control_cur BULK COLLECT INTO t_enc_control_id;
	CLOSE enc_control_cur;

	FORALL recno IN 1..t_enc_control_id.COUNT
	UPDATE	psp_enc_lines_history pelh
	SET	change_flag = 'U'
	WHERE	EXISTS	(SELECT	1
			FROM	psp_enc_summary_lines pesl
			WHERE	status_code = 'A'
			AND	pesl.enc_control_id = t_enc_control_id(recno)
			AND	EXISTS	(SELECT	1
					FROM	psp_enc_summary_lines pesl2
					WHERE	pesl2.status_code = 'L'
					AND	pesl2.enc_control_id = t_enc_control_id(recno)
					AND	pesl2.superceded_line_id = pesl.enc_summary_line_id))
	AND	pelh.enc_control_id = t_enc_control_id(recno);

	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Updated status_code to ''S'' in psp_enc_summary_lines for superceded lines SQL%ROWCOUNT: ' || SQL%ROWCOUNT);

	FORALL recno IN 1..t_enc_control_id.COUNT
	UPDATE	psp_enc_summary_lines pesl
	SET		status_code = 'S'
	WHERE	EXISTS	(SELECT	1
					FROM	psp_enc_summary_lines pesl3
					WHERE	pesl3.status_code = 'L'
					AND	pesl3.enc_control_id = t_enc_control_id(recno)
					AND	pesl3.superceded_line_id = pesl.enc_summary_line_id)
	AND	pesl.enc_control_id = t_enc_control_id(recno);

	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Updated status_code to ''S'' in psp_enc_summary_lines for superceded lines SQL%ROWCOUNT: ' || SQL%ROWCOUNT);

	FORALL recno IN 1..t_enc_control_id.COUNT
	UPDATE	psp_enc_summary_lines pesl
	SET	status_code = 'A'
	WHERE	status_code = 'S'
	AND	pesl.enc_summary_line_id IN	(SELECT	pesl2.superceded_line_id
						FROM	psp_enc_summary_lines pesl2
						WHERE	pesl2.status_code = 'N'
						AND	pesl2.enc_control_id = t_enc_control_id(recno))
	AND	NOT EXISTS	(SELECT	1
				FROM	psp_enc_summary_lines pesl3
				WHERE	pesl3.status_code = 'L'
				AND	pesl3.enc_control_id = t_enc_control_id(recno)
				AND	pesl3.superceded_line_id = pesl.enc_summary_line_id)
	AND	pesl.enc_control_id = t_enc_control_id(recno);

	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Updated status_code to ''A'' in psp_enc_summary_lines for lines rejected or not imported into target systems, SQL%ROWCOUNT: ' || SQL%ROWCOUNT);

	FORALL recno IN 1..t_enc_control_id.COUNT
	UPDATE	psp_enc_lines_history pelh
	SET	change_flag = 'L'
	WHERE	pelh.enc_summary_line_id IN	(SELECT	pesl.superceded_line_id
						FROM	psp_enc_summary_lines pesl
						WHERE	pesl.status_code = 'L'
						AND	pesl.enc_control_id = t_enc_control_id(recno))
	AND	pelh.enc_control_id = t_enc_control_id(recno);

	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Updated change_flag to ''L'' in psp_enc_lines_history for lines that are liquidated');

	FORALL recno IN 1..t_enc_control_id.COUNT
	UPDATE	psp_enc_controls
	SET	action_code = 'L'
	WHERE	enc_control_id = t_enc_control_id(recno)
	AND	NOT EXISTS	(SELECT	1
				FROM	psp_enc_summary_lines pesl
				WHERE	pesl.enc_control_id = t_enc_control_id(recno)
				AND	status_code IN ('N','R','A'));

	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Updated action_code to ''L'' in psp_enc_controls for control records whose enc summary lines are completely liquidated');

	FORALL recno IN 1..t_enc_control_id.COUNT
	UPDATE	psp_enc_controls
	SET	action_code = 'P'
	WHERE	enc_control_id = t_enc_control_id(recno)
	AND	EXISTS	(SELECT	1
			FROM	psp_enc_summary_lines pesl
			WHERE	pesl.enc_control_id = t_enc_control_id(recno)
			AND	status_code = 'A');

	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Updated action_code to ''P'' in psp_enc_controls for control records whose enc summary lines aren''t completely liquidated');

	UPDATE	psp_enc_processes
	SET	process_phase = 'completed',
		process_status = 'P'
	WHERE	payroll_action_id = p_payroll_action_id
	AND	process_code = 'ST'
	AND	NOT EXISTS	(SELECT	1
				FROM	psp_enc_summary_lines pesl
				WHERE	pesl.payroll_action_id = p_payroll_action_id
				AND	pesl.status_code = 'N');

	IF (SQL%ROWCOUNT> 0) THEN
		fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Updated process_phase to completed as no summarize and transfer is required');
	END IF;

	UPDATE	psp_enc_processes
	SET	process_phase = 'summarize_transfer'
	WHERE	payroll_action_id = p_payroll_action_id
	AND	process_code = 'ST'
	AND	EXISTS	(SELECT	1
			FROM	psp_enc_summary_lines pesl
			WHERE	pesl.payroll_action_id = p_payroll_action_id
			AND	pesl.status_code = 'N'
			AND	pesl.superceded_line_id IS NULL);

	IF (SQL%ROWCOUNT> 0) THEN
		fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Updated process_phase to summarize_transfer as there are new lines to be suimmarized and transferred');
	END IF;

	UPDATE	psp_enc_processes
	SET	process_phase = 'liquidate'
	WHERE	payroll_action_id = p_payroll_action_id
	AND	process_code = 'ST'
	AND	EXISTS	(SELECT	1
			FROM	psp_enc_summary_lines pesl
			WHERE	pesl.payroll_action_id = p_payroll_action_id
			AND	pesl.status_code = 'N'
			AND	pesl.superceded_line_id IS NOT NULL);
	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Updated process_phase to liquidate as liquidation process isn''t complete');

/*****	Commented for Create and Update multi thread enh.
	IF  p_action_type in ('U','Q') THEN
		IF NOT NVL(g_liq_has_failed_transactions, FALSE) THEN
			fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Calling psp_enc_update_lines.cleanup_on_success');
			psp_enc_update_lines.cleanup_on_success(p_action_type,
				p_payroll_id,
				p_business_group_id,
				p_set_of_books_id,
				'N',
				p_return_status);
		ELSE
			fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Calling psp_enc_update_lines.cleanup_on_success');
			psp_enc_update_lines.rollback_rejected_asg (p_payroll_id ,
				p_action_type,
				g_gms_batch_name,
				g_accepted_group_id,
				g_rejected_group_id,
				g_run_id,
				p_business_group_id,
				p_set_of_books_id,
				p_return_status);
		END IF;

		IF p_return_status <> fnd_api.g_ret_sts_success THEN
			RAISE fnd_api.g_exc_unexpected_error;
		END IF;
	END IF;
	End of comment for Create and Update multi thread	*****/

	UPDATE	psp_enc_process_assignments pepa
	SET	assignment_status = 'P'
	WHERE	payroll_action_id = p_payroll_action_id
	AND	NOT EXISTS	(SELECT	1
				FROM	psp_enc_summary_lines pesl
				WHERE	pesl.payroll_action_id = p_payroll_action_id
				AND	pesl.assignment_id = pepa.assignment_id
				AND	pesl.payroll_id = pepa.payroll_id
				AND	pesl.status_code = 'N');

	UPDATE	psp_enc_process_assignments pepa
	SET	assignment_status = 'S'
	WHERE	payroll_action_id = p_payroll_action_id
	AND	EXISTS	(SELECT	1
			FROM	psp_enc_summary_lines pesl
			WHERE	pesl.payroll_action_id = p_payroll_action_id
			AND	pesl.assignment_id = pepa.assignment_id
			AND	pesl.payroll_id = pepa.payroll_id
			AND	pesl.status_code = 'N'
			AND	pesl.superceded_line_id IS NULL);

	UPDATE	psp_enc_process_assignments pepa
	SET	assignment_status = 'L'
	WHERE	payroll_action_id = p_payroll_action_id
	AND	EXISTS	(SELECT	1
			FROM	psp_enc_summary_lines pesl
			WHERE	pesl.payroll_action_id = p_payroll_action_id
			AND	pesl.assignment_id = pepa.assignment_id
			AND	pesl.payroll_id = pepa.payroll_id
			AND	pesl.status_code = 'N'
			AND	pesl.superceded_line_id IS NOT NULL);

	COMMIT;
	p_return_status := fnd_api.g_ret_sts_success;

	OPEN summary_lines_cur;
	FETCH summary_lines_cur BULK COLLECT INTO r_summary_lines.person_id,	r_summary_lines.full_name,
		r_summary_lines.employee_number,	r_summary_lines.assignment_id,
		r_summary_lines.assignment_number,	r_summary_lines.gl_project_flag,
		r_summary_lines.group_id,		r_summary_lines.gms_batch_name,
		r_summary_lines.dr_cr_flag,		r_summary_lines.status_code,
		r_summary_lines.summary_amount,		r_summary_lines.summary_lines_count;
	CLOSE summary_lines_cur;

	fnd_file.put_line(fnd_file.output, '
Encumbrance summary line(s) status after liquidation processing');
	fnd_file.put_line(fnd_file.output, RPAD('Employee Name', 50, ' ') || '	' ||
		RPAD('Employee Number', 30, ' ') || '	' || RPAD('Assignment Number', 30, ' ') || '	' ||
		RPAD('GL Project Flag', 15, ' ') || '	' || LPAD('Group ID', 15, ' ') || '	' ||
		RPAD('GMS Batch Name', 15, ' ') || '	' || RPAD('Dr/Cr Flag', 10, ' ') || '	' ||
		RPAD('Status Code', 15, ' ') || '	' || LPAD('Summary Amount', 15, ' ') || '	' ||
		LPAD('Summary Lines', 15, ' '));

	fnd_file.put_line(fnd_file.output, RPAD('-', 50, '-') || '	' || RPAD('-', 30, '-') || '	' ||
		RPAD('-', 30, '-') || '	' || RPAD('-', 15, '-') || '	' || LPAD('-', 15, '-') || '	' ||
		RPAD('-', 15, '-') || '	' || RPAD('-', 10, '-') || '	' || RPAD('-', 15, '-') || '	' ||
		LPAD('-', 15, '-') || '	' || LPAD('-', 15, '-'));

	FOR recno IN 1..r_summary_lines.person_id.COUNT
	LOOP
		fnd_file.put_line(fnd_file.output, RPAD(r_summary_lines.full_name(recno), 50, ' ') || '	' ||
			RPAD(r_summary_lines.employee_number(recno), 30, ' ') || '	' ||
			RPAD(r_summary_lines.assignment_number(recno), 30, ' ') || '	' ||
			RPAD(r_summary_lines.gl_project_flag(recno), 15, ' ') || '	' ||
			LPAD(r_summary_lines.group_id(recno), 15, ' ') || '	' ||
			RPAD(r_summary_lines.gms_batch_name(recno), 15, ' ') || '	' ||
			RPAD(r_summary_lines.dr_cr_flag(recno), 10, ' ') || '	' ||
			RPAD(r_summary_lines.status_code(recno), 15, ' ') || '	' ||
			LPAD(r_summary_lines.summary_amount(recno), 15, ' ') || '	' ||
			LPAD(r_summary_lines.summary_lines_count(recno), 15, ' '));
	END LOOP;

	OPEN enc_control_status_cur;
	FETCH enc_control_status_cur BULK COLLECT INTO r_enc_controls.number_of_dr,
		r_enc_controls.number_of_cr,		r_enc_controls.total_dr_amount,
		r_enc_controls.total_cr_amount,		r_enc_controls.gl_dr_amount,
		r_enc_controls.gl_cr_amount,		r_enc_controls.ogm_dr_amount,
		r_enc_controls.ogm_cr_amount,		r_enc_controls.summ_gl_dr_amount,
		r_enc_controls.summ_gl_cr_amount,	r_enc_controls.summ_ogm_dr_amount,
		r_enc_controls.summ_ogm_cr_amount,	r_enc_controls.min_time_period_id,
		r_enc_controls.max_time_period_id,	r_enc_controls.enc_control_rec_count,
		r_enc_controls.action_code,		r_enc_controls.action_type,
		r_enc_controls.run_id,			r_enc_controls.gl_phase,
		r_enc_controls.gms_phase,		r_enc_controls.batch_name;
	CLOSE enc_control_status_cur;

	fnd_file.put_line(fnd_file.output, '
Encumbrance control record(s) status after liquidation processing');
	fnd_file.put_line(fnd_file.output, LPAD('Run ID', 15, ' ') || '	' || RPAD('Action Code', 15, ' ') || '	' ||
		RPAD('Action Type', 15, ' ') || '	' || RPAD('GL Phase', 15, ' ') || '	' ||
		RPAD('GMS Phase', 15, ' ') || '	' || RPAD('Batch Name', 23, ' ') || '	' ||
		LPAD('No of Dr', 15, ' ') || '	' || LPAD('No of Cr', 15, ' ') || '	' ||
		LPAD('Total Dr', 15, ' ') || '	' || LPAD('Total Cr', 15, ' ') || '	' ||
		LPAD('Total GL Dr', 15, ' ') || '	' || LPAD('Total GL Cr', 15, ' ') || '	' ||
		LPAD('Total GMS Dr', 15, ' ') || '	' || LPAD('Total GMS Cr', 15, ' ') || '	' ||
		LPAD('Summary GL Dr', 15, ' ') || '	' || LPAD('Summary GL Cr', 15, ' ') || '	' ||
		LPAD('Summary GMS Dr', 15, ' ') || '	' || LPAD('Summary GMS Cr', 15, ' ') || '	' ||
		LPAD('Control Records', 15, ' ') || '	' || LPAD('Min Time Period', 15, ' ') || '	' ||
		LPAD('Max Time Period', 15, ' '));
	fnd_file.put_line(fnd_file.output, LPAD('-', 15, '-') || '	' || RPAD('-', 15, '-') || '	' ||
		RPAD('-', 15, '-') || '	' || RPAD('-', 15, '-') || '	' || RPAD('-', 15, '-') || '	' ||
		RPAD('-', 23, '-') || '	' || LPAD('-', 15, '-') || '	' || LPAD('-', 15, '-') || '	' ||
		LPAD('-', 15, '-') || '	' || LPAD('-', 15, '-') || '	' || LPAD('-', 15, '-') || '	' ||
		LPAD('-', 15, '-') || '	' || LPAD('-', 15, '-') || '	' || LPAD('-', 15, '-') || '	' ||
		LPAD('-', 15, '-') || '	' || LPAD('-', 15, '-') || '	' || LPAD('-', 15, '-') || '	' ||
		LPAD('-', 15, '-') || '	' || LPAD('-', 15, '-') || '	' || LPAD('-', 15, '-') || '	' ||
		LPAD('-', 15, '-'));
	FOR recno IN 1..r_enc_controls.run_id.COUNT
	LOOP
		fnd_file.put_line(fnd_file.output, LPAD(r_enc_controls.run_id(recno), 15, ' ') || '	' ||
			RPAD(r_enc_controls.action_code(recno), 15, ' ') || '	' ||
			RPAD(r_enc_controls.action_type(recno), 15, ' ') || '	' ||
			RPAD(r_enc_controls.gl_phase(recno), 15, ' ') || '	' ||
			RPAD(r_enc_controls.gms_phase(recno), 15, ' ') || '	' ||
			RPAD(r_enc_controls.batch_name(recno), 23, ' ') || '	' ||
			LPAD(r_enc_controls.number_of_dr(recno), 15, ' ') || '	' ||
			LPAD(r_enc_controls.number_of_cr(recno), 15, ' ') || '	' ||
			LPAD(r_enc_controls.total_dr_amount(recno), 15, ' ') || '	' ||
			LPAD(r_enc_controls.total_cr_amount(recno), 15, ' ') || '	' ||
			LPAD(r_enc_controls.gl_dr_amount(recno), 15, ' ') || '	' ||
			LPAD(r_enc_controls.gl_cr_amount(recno), 15, ' ') || '	' ||
			LPAD(r_enc_controls.ogm_dr_amount(recno), 15, ' ') || '	' ||
			LPAD(r_enc_controls.ogm_cr_amount(recno), 15, ' ') || '	' ||
			LPAD(r_enc_controls.summ_gl_dr_amount(recno), 15, ' ') || '	' ||
			LPAD(r_enc_controls.summ_gl_cr_amount(recno), 15, ' ') || '	' ||
			LPAD(r_enc_controls.summ_ogm_dr_amount(recno), 15, ' ') || '	' ||
			LPAD(r_enc_controls.summ_ogm_cr_amount(recno), 15, ' ') || '	' ||
			LPAD(r_enc_controls.enc_control_rec_count(recno), 15, ' ') || '	' ||
			LPAD(r_enc_controls.min_time_period_id(recno), 15, ' ') || '	' ||
			LPAD(r_enc_controls.max_time_period_id(recno), 15, ' '));
	END LOOP;

	fnd_file.put_line(fnd_file.output, 'Liquidation Batch Processing completed at: ' || fnd_date.date_to_canonical(SYSDATE));
	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Leaving ENC_BATCH_END');
END enc_batch_end;

/*****	Commented for bug fix 4625734
 PROCEDURE enc_batch_end(p_payroll_id IN NUMBER,
                          p_action_type IN VARCHAR2,
                          p_mode IN varchar2,                 --- Bug 2039196
                          p_business_group_id in number,
                          p_set_of_books_id in number,
			p_return_status  OUT NOCOPY VARCHAR2
			) IS

   	CURSOR 	enc_control_cur IS
   	SELECT 	enc_control_id,
          	payroll_id,
          	time_period_id,
            gl_phase,
            gms_phase
   	FROM   	psp_enc_controls
   	WHERE 	payroll_id = nvl(p_payroll_id, payroll_id)
	AND	(total_dr_amount IS NOT NULL OR total_cr_amount IS NOT NULL)
   	AND	action_type in ('N', 'U', 'Q') -- Included 'Q' for Enh. 2143723
   	AND    	action_code = DECODE(p_action_type,'U','IU','Q','IU','IL')  / * Restart Update/Quick Update Encumbrance Lines Changes * /
   	AND    	(run_id = g_run_id or p_mode = 'R') --- bug 2039196: introduced p_mode = 'R'
	AND	business_group_id = p_business_group_id
	AND	set_of_books_id = p_set_of_books_id;

/ * Bug 2039196:
	AND	business_group_id = g_bg_id
	AND	set_of_books_id = g_sob_id; * /

   	CURSOR 	rej_enc_summary_lines_cur(P_ENC_CONTROL_ID  IN  NUMBER) IS
   	SELECT 	status_code,superceded_line_id
   	FROM 	psp_enc_summary_lines
   	WHERE 	enc_control_id = p_enc_control_id
	AND	status_code <> 'A';

	enc_control_rec		enc_control_cur%ROWTYPE;
   	l_enc_summary_line_id		NUMBER(10);
        l_sup_enc_summary_line_id       NUMBER(10);
 	l_status_code 	VARCHAR2(1);
        l_line_count number;
        l_new_line_count	NUMBER;	-- Introduced for Enh. 2143723

--	Included the following cursors for Enh. 2143723
	CURSOR	summary_line_count_cur IS
	SELECT	count(*)
	FROM	psp_enc_summary_lines
	WHERE	enc_control_id = enc_control_rec.enc_control_id
	AND	status_code  = 'A';

	CURSOR	pending_enc_lines_cur Is
	SELECT	count(*)
	FROM	psp_enc_lines
	WHERE	payroll_id = p_payroll_id
	AND	rownum = 1;

	BEGIN
 --insert_into_psp_stout( 'enc batch end' );
       OPEN enc_control_cur;
       LOOP
   		FETCH enc_control_cur INTO enc_control_rec;
   		IF enc_control_cur%NOTFOUND THEN
     			CLOSE enc_control_cur;
     			EXIT;
   		END IF;

         -- This part is used to mark the status_code of non-transferred summary lines to 'R'

   			UPDATE 	psp_enc_summary_lines
    			SET 	status_code = 'R'
    			WHERE 	enc_control_id = enc_control_rec.enc_control_id
    			AND 	status_code = 'N';


         -- This part is used to delete the rejected summary lines, mark the action_type
          -- in psp_payroll_controls to 'P' or 'N',delete the zero line reversal entry records

       		OPEN rej_enc_summary_lines_cur(enc_control_rec.enc_control_id);
   		LOOP
    			FETCH rej_enc_summary_lines_cur INTO l_status_code,l_sup_enc_summary_line_id;
    			IF rej_enc_summary_lines_cur %NOTFOUND THEN
      			CLOSE rej_enc_summary_lines_cur;
      			EXIT;
    			END IF;

			IF l_status_code = 'R' THEN
                           if l_sup_enc_summary_line_id <>0 then

                              UPDATE psp_Enc_summary_lines S1 set S1.status_code='A' where
                              S1.enc_summary_line_id=l_sup_enc_summary_line_id and
                              S1.status_code='S' and not exists
                                     -- added code to ensure there is no L line before reverting S
                                     -- for 2479579
                                      (select 1 from psp_enc_summary_lines S2
                                       where S2.status_code = 'L' and S1.enc_control_id = S2.enc_control_id
                                             and S2.superceded_line_id = l_sup_enc_summary_line_id);
                               / * mark the change_flag in psp_Enc_lineS_history as well * /
--				Update the change_flag to 'U' as per HQ review comment for Enh. 2143723
/ *****	Commented for Enh. 2768298 Removal of suspense posting in Liquidation
			     	 IF g_invalid_suspense ='N' THEN --Added for bug 2330057.
                              		update psp_Enc_lines_history
					set	change_flag= DECODE(p_action_type, 'Q', 'U', p_action_type)
					where	enc_summary_line_id=l_sup_enc_summary_line_id
					and	change_flag='N';
				END IF;
	End of comment for Enh. removal of suspense posting ni Liquidation	***** /

                           end if;
                           / * Start Bug#2142865 Added delete to delete  rejected records * /
                          / * reverted the delete for 2445196
                           DELETE 	FROM psp_enc_summary_lines
        		   WHERE 	enc_control_id = enc_control_rec.enc_control_id
        		   AND 	status_code = 'R'; * /
			/ * Commented for Restart Update/Quick Update Encumbrance Lines Enh.
			   DELETE 	FROM psp_enc_summary_lines
        		   WHERE 	enc_control_id = enc_control_rec.enc_control_id
        		   AND 	status_code = 'R';

                          -- update status_code to 'P' in psp_payroll_controls

			   UPDATE 	psp_enc_controls
        		   SET 	action_code = 'P',
            			run_id = NULL
        		   WHERE 	enc_control_id = enc_control_rec.enc_control_id;
                       ELSIF l_status_code = 'L' THEN
                     --   NULL;
                         if p_Action_type='L' and p_mode = 'N' then   -- added p_mode for Bug 2039196

                           UPDATE  psp_enc_controls
                           SET     action_code = 'L',
                                   run_id = NULL
                           WHERE   enc_control_id = enc_control_rec.enc_control_id;
                           update psp_enc_Controls set action_code='L' where
                           time_period_id=enc_control_rec.time_period_id and
                           payroll_id=p_payroll_id;

                            --required to update all previous records as well for this T.p to liquidated
                            --with delta postings
                        end if;  -- only for liquidate * /

-- Commented this out as the liquidated status here is misleading


     			END IF;
     		END LOOP; --rejected lines

/ *	Generalising the following set of code for Enh. 2143723
	Control Records will have a status of 'L' if no accepted SummaryLines exist
	OR to 'P', if present, regardless of whether it is invoked in 'L', 'Q' and 'U' modes
          / * Added so that status not left in I * /
        if p_action_type IN ('Q', 'U') then  -- Included 'Q' for Enh. 2143723
           update psp_enc_controls set action_code='P', run_id=null
            where enc_control_id=enc_control_rec.enc_control_id;
         elsif p_action_type = 'L'  and p_mode ='R' then   --- Bug 2039196: Introduced this condition

--	Moved the following SELECT into cursor summary_line_count_cur
            SELECT  count(*)
            into l_line_count
            FROM    psp_enc_summary_lines
            WHERE   enc_control_id = enc_control_rec.enc_control_id
                   and status_code = 'A';
End of Enh. fix 2143723	* /

--	Included the following for Enh. 2143723
	OPEN	summary_line_count_cur;
	FETCH	summary_line_count_cur INTO l_line_count;
	CLOSE	summary_line_count_cur;

            if l_line_count = 0 then
               update psp_enc_controls set action_code='L' ---, run_id=null ...commented run_id = null for 3473294
               where enc_control_id=enc_control_rec.enc_control_id;
            else
                --- removed the code that leaves controls at IU for 3473294
                update psp_enc_controls set action_code='P' ---, run_id=null
               where enc_control_id=enc_control_rec.enc_control_id;
            end if;
--        end if; Commented this for enh. 2143723
     END LOOP; --enc control cur
     if  p_action_type in ('U','Q')  then
     if not nvl(g_liq_has_failed_transactions,FALSE) then
       psp_enc_update_lines.cleanup_on_success(p_action_type,
       					       p_payroll_id,
       					       p_business_group_id,
       					       p_set_of_books_id,
       					       'N',	-- Replaced g_invalid_suspense with 'N' for Enh. 2768298
       					       p_return_status);
    else   --- added call for bug fix 3473294
       psp_enc_update_lines.rollback_rejected_asg (p_payroll_id ,
                                                 p_action_type,
                                                 g_gms_batch_name,
                                                 g_accepted_group_id,
                                                 g_rejected_group_id,
                                                 g_run_id,
                                                 p_business_group_id,
                                                 p_set_of_books_id,
                                                 p_return_status);
     end if;
     IF p_return_status = fnd_api.g_ret_sts_success THEN
        COMMIT;
     ELSE
	RAISE fnd_api.g_exc_unexpected_error;
     END IF;
     end if;
     ---END IF;

     / * Added For Restart Update/Quick Update Encumbrance Lines Enh. * /
     p_return_status := fnd_api.g_ret_sts_success;/ * pulled this line from below commit * /
     ---IF p_mode = 'N' THEN  / * Call the house keeping step only in normal mode * /

/ * Commented for  Restart Update/Quick Update Encumbrance Lines Enh.
   and the same code is moved to PSPENUPB
--	the foll. code is moved from PSPENUPB to here as part of Quick Update Enc. Enh. 2143723
--	This fix also includes the Restart Update Enc. Enh. fix
	IF p_action_type IN ('Q', 'U') THEN
		OPEN	pending_enc_lines_cur;
		FETCH	pending_enc_lines_cur INTO l_new_line_count;
		CLOSE	pending_enc_lines_cur;

		IF (l_new_line_count = 0) THEN
			DELETE FROM psp_enc_controls
			WHERE	action_type = p_action_type
			AND	payroll_id = p_payroll_id
			AND	action_code = 'N';
		END IF;

--	After Liquidation, Identify and update the liquidated records and mark the unchanged records to 'N'
--	to be picked up in a susequent update run
		UPDATE	psp_enc_lines_history
		SET	change_flag = 'L'
		WHERE	change_flag = 'N'
		AND	payroll_id = p_payroll_id;

--	Introduced IF stmt instead of DECODE in WHERE clause for Quick Update Enh. 2143723 (perf. issue)
--	As per HQ review comment, change_flag for Quick Update will be 'U' and not 'Q'
		IF (p_action_type = 'Q') THEN
			UPDATE	psp_enc_lines_history
			SET	change_flag = 'N'
			WHERE	change_flag = 'U'
			AND	payroll_id = p_payroll_id;
		ELSE
			UPDATE	psp_enc_lines_history
			SET	change_flag = 'N'
			WHERE	change_flag = p_action_type
			AND	payroll_id = p_payroll_id;
		END IF;

--		Calling move_qkupd_rec_to_hist procedure, Quick Update Enc. Enh. 2143723
		IF (p_action_type in ('Q', 'U')) THEN
			move_qkupd_rec_to_hist	(p_payroll_id,
						p_action_type,
						p_business_group_id,
						p_set_of_books_id,
						l_status_code);
			IF (l_status_code <> fnd_api.g_ret_sts_success) THEN
				g_error_api_path := 'MOVE_QKUPD_REC_TO_HIST: ' || g_error_api_path;
				RAISE fnd_api.g_exc_unexpected_error;
			END IF;
		END IF;
		COMMIT;
	END IF;
--	End of Enh. fix 2143723

	p_return_status	:= fnd_api.g_ret_sts_success;
* /
 END enc_batch_end;
	End of comment for bug fix 4625734	****/

--	##########################################################################
--	This procedure liquidates the summary lines by creating new lines in
--		psp_enc_summary_lines and sending them to GL

--	This procedure reverses the summary lines with STATUS_CODE = 'A' by creating
--	new lines in PSP_ENC_SUMMARY_LINES
--	##########################################################################
--	Commented the existing create_gl_enc_liq_lines procedure and created new procedure that made use of BULK FETCH
--	statements to improve on performance of the liquidation process.
--	Introduced the foolowing for bug fix 4625734
PROCEDURE create_gl_enc_liq_lines	(p_payroll_id	IN		NUMBER,
					p_action_type	IN		VARCHAR2,
					p_return_status	OUT NOCOPY	VARCHAR2) IS
CURSOR	enc_liq_cur IS
SELECT	pesl.enc_summary_line_id,
	pesl.effective_date,
	enc_control_id,
	time_period_id,
	pesl.set_of_books_id,
	pesl.gl_code_combination_id,
	pesl.summary_amount,
	DECODE(pesl.dr_cr_flag, 'C', 'D', 'D', 'C') dr_cr_flag,
	pesl.person_id,
	pesl.assignment_id,
	pesl.gl_project_flag,
	DECODE(g_dff_grouping_option, 'Y', pesl.attribute_category, NULL) attribute_category,
	DECODE(g_dff_grouping_option, 'Y', pesl.attribute1, NULL) attribute1,
	DECODE(g_dff_grouping_option, 'Y', pesl.attribute2, NULL) attribute2,
	DECODE(g_dff_grouping_option, 'Y', pesl.attribute3, NULL) attribute3,
	DECODE(g_dff_grouping_option, 'Y', pesl.attribute4, NULL) attribute4,
	DECODE(g_dff_grouping_option, 'Y', pesl.attribute5, NULL) attribute5,
	DECODE(g_dff_grouping_option, 'Y', pesl.attribute6, NULL) attribute6,
	DECODE(g_dff_grouping_option, 'Y', pesl.attribute7, NULL) attribute7,
	DECODE(g_dff_grouping_option, 'Y', pesl.attribute8, NULL) attribute8,
	DECODE(g_dff_grouping_option, 'Y', pesl.attribute9, NULL) attribute9,
	DECODE(g_dff_grouping_option, 'Y', pesl.attribute10, NULL) attribute10
FROM	psp_enc_summary_lines pesl
WHERE	pesl.enc_control_id IN (SELECT	pec.enc_control_id
		FROM	psp_enc_controls pec
		WHERE	pec.payroll_id = nvl(p_payroll_id, pec.payroll_id)
		AND	(pec.total_dr_amount IS NOT NULL OR pec.total_cr_amount IS NOT NULL)
		AND	pec.run_id = g_run_id
		AND	pec.business_group_id = g_bg_id
		AND	pec.set_of_books_id = g_sob_id
		AND	(pec.gl_phase IS NULL or pec.gl_phase = 'TieBack'))
AND	pesl.gl_project_flag = 'G'
AND	pesl.status_code = 'A'
AND	EXISTS (SELECT	1
		FROM	psp_enc_lines_history pelh
		WHERE	pelh.change_flag  = 'N'
		AND	pelh.enc_summary_line_id = pesl.enc_summary_line_id);

CURSOR	enc_upd_liq_cur IS
SELECT	pesl.enc_summary_line_id,
	pesl.effective_date,
	enc_control_id,
	time_period_id,
	pesl.set_of_books_id,
	pesl.gl_code_combination_id,
	pesl.summary_amount,
	DECODE(pesl.dr_cr_flag, 'C', 'D', 'D', 'C') dr_cr_flag,
	pesl.person_id,
	pesl.assignment_id,
	pesl.gl_project_flag,
	DECODE(g_dff_grouping_option, 'Y', pesl.attribute_category, NULL) attribute_category,
	DECODE(g_dff_grouping_option, 'Y', pesl.attribute1, NULL) attribute1,
	DECODE(g_dff_grouping_option, 'Y', pesl.attribute2, NULL) attribute2,
	DECODE(g_dff_grouping_option, 'Y', pesl.attribute3, NULL) attribute3,
	DECODE(g_dff_grouping_option, 'Y', pesl.attribute4, NULL) attribute4,
	DECODE(g_dff_grouping_option, 'Y', pesl.attribute5, NULL) attribute5,
	DECODE(g_dff_grouping_option, 'Y', pesl.attribute6, NULL) attribute6,
	DECODE(g_dff_grouping_option, 'Y', pesl.attribute7, NULL) attribute7,
	DECODE(g_dff_grouping_option, 'Y', pesl.attribute8, NULL) attribute8,
	DECODE(g_dff_grouping_option, 'Y', pesl.attribute9, NULL) attribute9,
	DECODE(g_dff_grouping_option, 'Y', pesl.attribute10, NULL) attribute10
FROM	psp_enc_summary_lines pesl
WHERE	pesl.enc_control_id IN (SELECT	pec.enc_control_id
		FROM	psp_enc_controls pec
		WHERE	pec.payroll_id = nvl(p_payroll_id, pec.payroll_id)
		AND	(pec.total_dr_amount IS NOT NULL OR pec.total_cr_amount IS NOT NULL)
		AND	pec.run_id = g_run_id
		AND	pec.business_group_id = g_bg_id
		AND	pec.set_of_books_id = g_sob_id
		AND	(pec.gl_phase IS NULL or pec.gl_phase = 'TieBack'))
AND	pesl.gl_project_flag = 'G'
AND	pesl.status_code = 'A'
AND	EXISTS (SELECT	1 FROM	psp_enc_changed_assignments peca
		WHERE	peca.assignment_id = pesl.assignment_id
		AND	peca.request_id IS NOT NULL
                AND	peca.payroll_id =p_payroll_id)
AND	EXISTS (SELECT	1
		FROM	psp_enc_lines_history pelh
		WHERE	pelh.change_flag  = 'N'
		AND	pelh.enc_summary_line_id = pesl.enc_summary_line_id);

CURSOR	enc_qupd_liq_cur IS
SELECT	pesl.enc_summary_line_id,
	pesl.effective_date,
	enc_control_id,
	time_period_id,
	pesl.set_of_books_id,
	pesl.gl_code_combination_id,
	pesl.summary_amount,
	DECODE(pesl.dr_cr_flag, 'C', 'D', 'D', 'C') dr_cr_flag,
	pesl.person_id,
	pesl.assignment_id,
	pesl.gl_project_flag,
	DECODE(g_dff_grouping_option, 'Y', pesl.attribute_category, NULL) attribute_category,
	DECODE(g_dff_grouping_option, 'Y', pesl.attribute1, NULL) attribute1,
	DECODE(g_dff_grouping_option, 'Y', pesl.attribute2, NULL) attribute2,
	DECODE(g_dff_grouping_option, 'Y', pesl.attribute3, NULL) attribute3,
	DECODE(g_dff_grouping_option, 'Y', pesl.attribute4, NULL) attribute4,
	DECODE(g_dff_grouping_option, 'Y', pesl.attribute5, NULL) attribute5,
	DECODE(g_dff_grouping_option, 'Y', pesl.attribute6, NULL) attribute6,
	DECODE(g_dff_grouping_option, 'Y', pesl.attribute7, NULL) attribute7,
	DECODE(g_dff_grouping_option, 'Y', pesl.attribute8, NULL) attribute8,
	DECODE(g_dff_grouping_option, 'Y', pesl.attribute9, NULL) attribute9,
	DECODE(g_dff_grouping_option, 'Y', pesl.attribute10, NULL) attribute10
FROM	psp_enc_summary_lines pesl
WHERE	pesl.enc_control_id IN (SELECT	pec.enc_control_id
		FROM	psp_enc_controls pec
		WHERE	pec.payroll_id = nvl(p_payroll_id, pec.payroll_id)
		AND	(pec.total_dr_amount IS NOT NULL OR pec.total_cr_amount IS NOT NULL)
		AND	pec.run_id = g_run_id
		AND	pec.business_group_id = g_bg_id
		AND	pec.set_of_books_id = g_sob_id
		AND	(pec.gl_phase IS NULL or pec.gl_phase = 'TieBack'))
AND	pesl.gl_project_flag = 'G'
AND	pesl.status_code = 'A'
AND	EXISTS (SELECT	1 FROM	psp_enc_changed_assignments peca
		WHERE	peca.assignment_id = pesl.assignment_id
		AND	peca.request_id IS NOT NULL
		AND	peca.payroll_id = p_payroll_id
		AND	peca.change_type IN ('LS', 'ET', 'AS', 'QU'))
AND	EXISTS (SELECT	1
		FROM	psp_enc_lines_history pelh
		WHERE	pelh.change_flag  = 'N'
		AND	pelh.enc_summary_line_id = pesl.enc_summary_line_id);

CURSOR	emp_term_enc_liq_cur IS
SELECT	enc_summary_line_id,
	effective_date,
	enc_control_id,
	time_period_id,
	set_of_books_id,
	gl_code_combination_id,
	summary_amount,
	DECODE(pesl.dr_cr_flag, 'C', 'D', 'D', 'C') dr_cr_flag,
	person_id,
	assignment_id,
	gl_project_flag,
	DECODE(g_dff_grouping_option, 'Y', pesl.attribute_category, NULL) attribute_category,
	DECODE(g_dff_grouping_option, 'Y', pesl.attribute1, NULL) attribute1,
	DECODE(g_dff_grouping_option, 'Y', pesl.attribute2, NULL) attribute2,
	DECODE(g_dff_grouping_option, 'Y', pesl.attribute3, NULL) attribute3,
	DECODE(g_dff_grouping_option, 'Y', pesl.attribute4, NULL) attribute4,
	DECODE(g_dff_grouping_option, 'Y', pesl.attribute5, NULL) attribute5,
	DECODE(g_dff_grouping_option, 'Y', pesl.attribute6, NULL) attribute6,
	DECODE(g_dff_grouping_option, 'Y', pesl.attribute7, NULL) attribute7,
	DECODE(g_dff_grouping_option, 'Y', pesl.attribute8, NULL) attribute8,
	DECODE(g_dff_grouping_option, 'Y', pesl.attribute9, NULL) attribute9,
	DECODE(g_dff_grouping_option, 'Y', pesl.attribute10, NULL) attribute10
FROM	psp_enc_summary_lines pesl
WHERE	enc_control_id IN (SELECT	pec.enc_control_id
		FROM	psp_enc_controls pec
		WHERE	pec.payroll_id = NVL(p_payroll_id, pec.payroll_id)
		AND	(pec.total_dr_amount IS NOT NULL OR pec.total_cr_amount IS NOT NULL)
		AND	pec.run_id = g_run_id
		AND	pec.business_group_id = g_bg_id
		AND	pec.set_of_books_id = g_sob_id
		AND	(pec.gl_phase IS NULL OR pec.gl_phase = 'TieBack'))
AND	gl_project_flag = 'G'
AND	status_code = 'A'
AND	person_id = g_person_id
AND	EXISTS (SELECT	1
		FROM	psp_enc_lines_history pelh
		WHERE	pelh.change_flag  = 'N'
		AND	pelh.enc_summary_line_id = pesl.enc_summary_line_id);

TYPE t_number IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE t_number_15 IS TABLE OF NUMBER(15) INDEX BY BINARY_INTEGER;
TYPE t_date IS TABLE OF DATE INDEX BY BINARY_INTEGER;
TYPE t_char_300 IS TABLE OF VARCHAR2(300) INDEX BY BINARY_INTEGER;

TYPE r_liq_lines_rec IS RECORD
	(enc_summary_line_id	t_number_15,
	enc_control_id		t_number_15,
	time_period_id		t_number_15,
	effective_date		t_date,
	set_of_books_id		t_number_15,
	gl_code_combination_id	t_number_15,
	summary_amount		t_number,
	dr_cr_flag		t_char_300,
	person_id		t_number_15,
	assignment_id		t_number_15,
	gl_project_flag		t_char_300,
	attribute_category	t_char_300,
	attribute1		t_char_300,
	attribute2		t_char_300,
	attribute3		t_char_300,
	attribute4		t_char_300,
	attribute5		t_char_300,
	attribute6		t_char_300,
	attribute7		t_char_300,
	attribute8		t_char_300,
	attribute9		t_char_300,
	attribute10		t_char_300);
r_liq_lines	r_liq_lines_rec;

l_last_updated_by	NUMBER(15);
l_last_update_login	NUMBER(15);
BEGIN
	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Entering CREATE_GL_ENC_LIQ_LINES');

	l_last_updated_by := fnd_global.user_id;
	l_last_update_login := fnd_global.login_id;

	IF (g_person_id IS NOT NULL) THEN
		OPEN emp_term_enc_liq_cur;
		FETCH emp_term_enc_liq_cur BULK COLLECT INTO r_liq_lines.enc_summary_line_id,	r_liq_lines.effective_date,
			r_liq_lines.enc_control_id,	r_liq_lines.time_period_id,
			r_liq_lines.set_of_books_id,	r_liq_lines.gl_code_combination_id,
			r_liq_lines.summary_amount,	r_liq_lines.dr_cr_flag,
			r_liq_lines.person_id,		r_liq_lines.assignment_id,
			r_liq_lines.gl_project_flag,	r_liq_lines.attribute_category,
			r_liq_lines.attribute1,		r_liq_lines.attribute2,
			r_liq_lines.attribute3,		r_liq_lines.attribute4,
			r_liq_lines.attribute5,		r_liq_lines.attribute6,
			r_liq_lines.attribute7,		r_liq_lines.attribute8,
			r_liq_lines.attribute9,		r_liq_lines.attribute10;
		CLOSE emp_term_enc_liq_cur;
	ELSIF (g_person_id IS NULL AND p_action_type = 'L') THEN
		OPEN enc_liq_cur;
		FETCH enc_liq_cur BULK COLLECT INTO r_liq_lines.enc_summary_line_id,	r_liq_lines.effective_date,
			r_liq_lines.enc_control_id,	r_liq_lines.time_period_id,
			r_liq_lines.set_of_books_id,	r_liq_lines.gl_code_combination_id,
			r_liq_lines.summary_amount,	r_liq_lines.dr_cr_flag,
			r_liq_lines.person_id,		r_liq_lines.assignment_id,
			r_liq_lines.gl_project_flag,	r_liq_lines.attribute_category,
			r_liq_lines.attribute1,		r_liq_lines.attribute2,
			r_liq_lines.attribute3,		r_liq_lines.attribute4,
			r_liq_lines.attribute5,		r_liq_lines.attribute6,
			r_liq_lines.attribute7,		r_liq_lines.attribute8,
			r_liq_lines.attribute9,		r_liq_lines.attribute10;
		CLOSE enc_liq_cur;
	ELSIF (p_action_type = 'U') THEN
		OPEN enc_upd_liq_cur;
		FETCH enc_upd_liq_cur BULK COLLECT INTO r_liq_lines.enc_summary_line_id,	r_liq_lines.effective_date,
			r_liq_lines.enc_control_id,	r_liq_lines.time_period_id,
			r_liq_lines.set_of_books_id,	r_liq_lines.gl_code_combination_id,
			r_liq_lines.summary_amount,	r_liq_lines.dr_cr_flag,
			r_liq_lines.person_id,		r_liq_lines.assignment_id,
			r_liq_lines.gl_project_flag,	r_liq_lines.attribute_category,
			r_liq_lines.attribute1,		r_liq_lines.attribute2,
			r_liq_lines.attribute3,		r_liq_lines.attribute4,
			r_liq_lines.attribute5,		r_liq_lines.attribute6,
			r_liq_lines.attribute7,		r_liq_lines.attribute8,
			r_liq_lines.attribute9,		r_liq_lines.attribute10;
		CLOSE enc_upd_liq_cur;
	ELSIF (p_action_type = 'Q') THEN
		OPEN enc_qupd_liq_cur;
		FETCH enc_qupd_liq_cur BULK COLLECT INTO r_liq_lines.enc_summary_line_id,	r_liq_lines.effective_date,
			r_liq_lines.enc_control_id,	r_liq_lines.time_period_id,
			r_liq_lines.set_of_books_id,	r_liq_lines.gl_code_combination_id,
			r_liq_lines.summary_amount,	r_liq_lines.dr_cr_flag,
			r_liq_lines.person_id,		r_liq_lines.assignment_id,
			r_liq_lines.gl_project_flag,	r_liq_lines.attribute_category,
			r_liq_lines.attribute1,		r_liq_lines.attribute2,
			r_liq_lines.attribute3,		r_liq_lines.attribute4,
			r_liq_lines.attribute5,		r_liq_lines.attribute6,
			r_liq_lines.attribute7,		r_liq_lines.attribute8,
			r_liq_lines.attribute9,		r_liq_lines.attribute10;
		CLOSE enc_qupd_liq_cur;
	END IF;

	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	r_liq_lines.enc_summary_line_id.COUNT: ' || r_liq_lines.enc_summary_line_id.COUNT);

	FORALL recno IN 1..r_liq_lines.enc_summary_line_id.COUNT
	INSERT INTO psp_enc_summary_lines
		(enc_summary_line_id,		business_group_id,		enc_control_id,
		time_period_id,			person_id,			assignment_id,
		effective_date,			set_of_books_id,		gl_code_combination_id,
		summary_amount,			dr_cr_flag,			status_code,
		payroll_id,			gl_project_flag,		superceded_line_id,
		attribute_category,		attribute1,			attribute2,
		attribute3,			attribute4,			attribute5,
		attribute6,			attribute7,			attribute8,
		attribute9,			attribute10,			liquidate_request_id,
		proposed_termination_date,	last_update_date,		last_updated_by,
		last_update_login,		created_by,			creation_date)
	VALUES	(psp_enc_summary_lines_s.NEXTVAL,		g_bg_id,
		r_liq_lines.enc_control_id(recno),		r_liq_lines.time_period_id(recno),
		r_liq_lines.person_id(recno),			r_liq_lines.assignment_id(recno),
		r_liq_lines.effective_date(recno),		r_liq_lines.set_of_books_id(recno),
		r_liq_lines.gl_code_combination_id(recno),	r_liq_lines.summary_amount(recno),
		r_liq_lines.dr_cr_flag(recno),			'N',
		p_payroll_id,					r_liq_lines.gl_project_flag(recno),
		r_liq_lines.enc_summary_line_id(recno),		r_liq_lines.attribute_category(recno),
		r_liq_lines.attribute1(recno),			r_liq_lines.attribute2(recno),
		r_liq_lines.attribute3(recno),			r_liq_lines.attribute4(recno),
		r_liq_lines.attribute5(recno),			r_liq_lines.attribute6(recno),
		r_liq_lines.attribute7(recno),			r_liq_lines.attribute8(recno),
		r_liq_lines.attribute9(recno),			r_liq_lines.attribute10(recno),
		g_request_id,					g_actual_term_date,
		SYSDATE,	l_last_updated_by,	l_last_update_login,	l_last_updated_by,	SYSDATE);

	FORALL recno IN 1..r_liq_lines.enc_summary_line_id.COUNT
	UPDATE	psp_enc_summary_lines
	SET	status_code = 'S'
	WHERE	enc_summary_line_id= r_liq_lines.enc_summary_line_id(recno);

	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Updated status_code to ''S'' in psp_enc_summary_lines');

	FORALL recno IN 1..r_liq_lines.enc_summary_line_id.COUNT
	UPDATE	psp_enc_controls
	SET	gl_phase = 'Summarize'
	WHERE	enc_control_id = r_liq_lines.enc_control_id(recno);

	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Updated gl_phase to ''Summarize'' in psp_enc_controls');

	p_return_status	:= fnd_api.g_ret_sts_success;

	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Leaving CREATE_GL_ENC_LIQ_LINES');
EXCEPTION
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		g_error_api_path := 'CREATE_GL_ENC_LIQ_LINES:'||g_error_api_path;
		p_return_status := fnd_api.g_ret_sts_unexp_error;
		fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Leaving CREATE_GL_ENC_LIQ_LINES');
	WHEN OTHERS THEN
		g_error_api_path := 'CREATE_GL_ENC_LIQ_LINES:'||g_error_api_path;
		fnd_msg_pub.add_exc_msg('PSP_ENC_LIQ_TRAN','CREATE_GL_ENC_LIQ_LINES');
		p_return_status := fnd_api.g_ret_sts_unexp_error;
		fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Leaving CREATE_GL_ENC_LIQ_LINES');
END create_gl_enc_liq_lines;
--	End of changes for bg fix 4625734

/*****	Commented the following for bug fix 4625734
PROCEDURE create_gl_enc_liq_lines(p_payroll_id IN NUMBER,
                                   p_action_type IN VARCHAR2,
				p_return_status	OUT NOCOPY  VARCHAR2
				) IS

	CURSOR 	enc_control_cur IS
   	SELECT 	enc_control_id,
          	payroll_id,
          	time_period_id
   	FROM   	psp_enc_controls
   	WHERE 	payroll_id = nvl(p_payroll_id, payroll_id)
	AND	(total_dr_amount IS NOT NULL OR total_cr_amount IS NOT NULL)
   	AND	action_type in ('N', 'U', 'Q') -- Included 'Q' for Enh. 2143723
   	AND    	action_code IN ('IL','IU') -- Replaced I with IL and IU for Bug#2142865
   	AND    	run_id = g_run_id
	AND	business_group_id = g_bg_id
	AND	set_of_books_id = g_sob_id
        AND     (gl_phase is null or gl_phase = 'TieBack');   --- added this line for 2444657

	l_request_id	NUMBER DEFAULT fnd_global.conc_request_id;	-- Introduced for bug 2259310

	CURSOR 	enc_liq_cur(p_enc_control_id IN NUMBER) IS
    	SELECT 	DISTINCT pesl.enc_summary_line_id,
		pesl.effective_date,
		pesl.set_of_books_id,
		pesl.gl_code_combination_id,
		pesl.summary_amount,
		pesl.dr_cr_flag,
		pesl.person_id,
		pesl.assignment_id,
		pesl.gl_project_flag,
		DECODE(g_dff_grouping_option, 'Y', pesl.attribute_category, NULL) attribute_category,	-- Introduced DFF columns for bug fix 2908859
		DECODE(g_dff_grouping_option, 'Y', pesl.attribute1, NULL) attribute1,
		DECODE(g_dff_grouping_option, 'Y', pesl.attribute2, NULL) attribute2,
		DECODE(g_dff_grouping_option, 'Y', pesl.attribute3, NULL) attribute3,
		DECODE(g_dff_grouping_option, 'Y', pesl.attribute4, NULL) attribute4,
		DECODE(g_dff_grouping_option, 'Y', pesl.attribute5, NULL) attribute5,
		DECODE(g_dff_grouping_option, 'Y', pesl.attribute6, NULL) attribute6,
		DECODE(g_dff_grouping_option, 'Y', pesl.attribute7, NULL) attribute7,
		DECODE(g_dff_grouping_option, 'Y', pesl.attribute8, NULL) attribute8,
		DECODE(g_dff_grouping_option, 'Y', pesl.attribute9, NULL) attribute9,
		DECODE(g_dff_grouping_option, 'Y', pesl.attribute10, NULL) attribute10
        FROM  psp_enc_summary_lines pesl
        WHERE  pesl.enc_control_id = p_enc_control_id
  --- changed pelh to pesl for performance ..3684930
         AND pesl.gl_project_flag = 'G'
         AND pesl.status_code = 'A'
         AND ((p_action_type='L' and g_person_id is null)    --- g_person_id null check for 3413373
            OR (g_person_id is not null AND peSL.person_id = g_person_id
                    AND   EXISTS  (SELECT 1 FROM PSP_ENC_LINES_HISTORY PELH WHERE PELH.ENC_SUMMARY_LINE_ID = PESL.ENC_SUMMARY_LINE_ID
                                   AND PELH.CHANGE_FLAG = 'N')
                    AND peSL.time_period_id >= g_term_period_id)
            OR
                 (p_action_type IN ('Q', 'U') AND EXISTS
                                   (SELECT 1 FROM PSP_ENC_LINES_HISTORY PELH WHERE PELH.ENC_SUMMARY_LINE_ID = PESL.ENC_SUMMARY_LINE_ID
                                   AND PELH.CHANGE_FLAG = 'N')
                                        AND     EXISTS  (SELECT 1 FROM psp_enc_changed_assignments peca
                                                WHERE   peca.assignment_id = pesl.assignment_id
                                                AND peca.request_id IS NOT NULL
                                                AND     peca.payroll_id =p_payroll_id
                                                AND         ((p_action_type = 'Q'  and peca.change_type IN ('LS', 'ET', 'AS', 'QU'))
                                                                OR p_action_type = 'U')
                                                         )
                                )
                        );
/ *
 and pelh.change_flag='N';
        AND (p_action_type='L' or
             (p_action_type='U' and
            pelh.assignment_id IN
         (SELECT distinct pelh.assignment_id FROM
          psp_enc_lines_history pelh, psp_enc_controls pec
        WHERE pec.enc_control_id=p_enc_control_id AND
        pelh.time_period_id=pec.time_period_id and pelh.change_flag='N')));
   Above cursor modified for bug fixes 1832670 and 1776752

* /
	l_return_status		VARCHAR2(10);
	l_enc_summary_line_id		NUMBER(10);
	enc_control_rec			enc_control_cur%ROWTYPE;
   	enc_liq_rec		enc_liq_cur%ROWTYPE;
	l_count		number:=0;   --- existing variable, initialized to 0 for 2444657
BEGIN
	OPEN enc_control_cur;
  	LOOP
   		FETCH enc_control_cur INTO enc_control_rec;
   		IF enc_control_cur%NOTFOUND THEN
     		CLOSE enc_control_cur;
     		EXIT;
   		END IF;

		OPEN enc_liq_cur(enc_control_rec.enc_control_id);
		LOOP
			FETCH enc_liq_cur INTO enc_liq_rec;
			IF enc_liq_cur%NOTFOUND THEN
			CLOSE enc_liq_cur;
			EXIT;
			END IF;

             --insert into psp_stout values(1,'sline id '||to_char(enc_liq_rec.enc_summary_line_id));
  --insert into psp_stout values(2,'ccid is '||to_char(enc_liq_rec.gl_code_combination_id));

			if (enc_liq_rec.dr_cr_flag = 'D') then
			    enc_liq_rec.dr_cr_flag := 'C';
			elsif enc_liq_rec.dr_cr_flag = 'C' then
			    enc_liq_rec.dr_cr_flag := 'D';
			end if;

				insert_into_enc_sum_lines(
							l_enc_summary_line_id,
							g_bg_id,
							enc_control_rec.enc_control_id,
							enc_control_rec.time_period_id,
							enc_liq_rec.person_id,
							enc_liq_rec.assignment_id,
                					enc_liq_rec.effective_date,
							enc_liq_rec.set_of_books_id,
							enc_liq_rec.gl_code_combination_id,
 							NULL,
 							NULL,
 							NULL,
 							NULL,
 							NULL,
 							enc_liq_rec.summary_amount,
 							enc_liq_rec.dr_cr_flag,
							'N',
							enc_control_rec.payroll_id,
 							NULL,
							enc_liq_rec.gl_project_flag,
                                                        NULL,
                                                        enc_liq_rec.enc_summary_line_id,
                                                        NULL,
                                                        NULL,
							enc_liq_rec.attribute_category,	-- Introduced DFF columns for bug fix 2908859
							enc_liq_rec.attribute1,
							enc_liq_rec.attribute2,
							enc_liq_rec.attribute3,
							enc_liq_rec.attribute4,
							enc_liq_rec.attribute5,
							enc_liq_rec.attribute6,
							enc_liq_rec.attribute7,
							enc_liq_rec.attribute8,
							enc_liq_rec.attribute9,
							enc_liq_rec.attribute10,
							NULL,				-- Bug 4068182
							l_return_status);

				IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
					RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
				END IF;

   / * Flag  the original line as Superceded* /
                              update psp_enc_summary_lines set status_code='S'
                              where enc_summary_line_id=enc_liq_rec.enc_summary_line_id;



			l_count := l_count + 1;
		END LOOP;

	    if l_count > 0 then
            update psp_enc_controls
               set gl_phase = 'Summarize' --- replaced  NULL for 2444657
             where enc_control_id = enc_control_rec.enc_control_id;
	     l_count := 0;
	   end if;

			IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
				RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
			END IF;
	END LOOP;
	--COMMIT;
	p_return_status	:= fnd_api.g_ret_sts_success;

EXCEPTION
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     		g_error_api_path := 'CREATE_GL_ENC_LIQ_LINES:'||g_error_api_path;
     		p_return_status := fnd_api.g_ret_sts_unexp_error;
	WHEN OTHERS THEN
     		g_error_api_path := 'CREATE_GL_ENC_LIQ_LINES:'||g_error_api_path;
     		fnd_msg_pub.add_exc_msg('PSP_ENC_LIQ_TRAN','CREATE_GL_ENC_LIQ_LINES');
     		p_return_status := fnd_api.g_ret_sts_unexp_error;
END create_gl_enc_liq_lines;
	End of comment for bug fix 4625734	*****/

/*****	Commented the following procedure as it is no longer used (for bug fix 4625734)
--	##########################################################################
--	This procedure inserts records into psp_enc_summary_lines
--	##########################################################################

PROCEDURE insert_into_enc_sum_lines(
				p_enc_summary_line_id	OUT NOCOPY NUMBER,
				p_business_group_id	IN  NUMBER,
				p_enc_control_id	IN  NUMBER,
				p_time_period_id	IN  NUMBER,
				p_person_id		IN  NUMBER,
				p_assignment_id		IN  NUMBER,
				p_effective_date	IN  DATE,
				p_set_of_books_id	IN  NUMBER,
				p_gl_code_combination_id IN  NUMBER,
				p_project_id		IN  NUMBER,
				p_expenditure_organization_id IN  NUMBER,
				p_expenditure_type	IN  VARCHAR2,
				p_task_id		IN  NUMBER,
				p_award_id		IN  NUMBER,
				p_summary_amount	IN  NUMBER,
				p_dr_cr_flag		IN  VARCHAR2,
				p_status_code		IN  VARCHAR2,
				p_payroll_id		IN  NUMBER,
				p_gl_period_id		IN  NUMBER,
				p_gl_project_flag	IN  VARCHAR2,
                                p_suspense_org_account_id IN NUMBER,
                                p_superceded_line_id      IN NUMBER,
                                p_gms_posting_override_date IN DATE,
                                p_gl_posting_override_date IN DATE,
				p_attribute_category	IN	VARCHAR2,	-- Introduced DFF columns for bug fix 2908859
				p_attribute1		IN	VARCHAR2,
				p_attribute2		IN	VARCHAR2,
				p_attribute3		IN	VARCHAR2,
				p_attribute4		IN	VARCHAR2,
				p_attribute5		IN	VARCHAR2,
				p_attribute6		IN	VARCHAR2,
				p_attribute7		IN	VARCHAR2,
				p_attribute8		IN	VARCHAR2,
				p_attribute9		IN	VARCHAR2,
				p_attribute10		IN	VARCHAR2,
				p_expenditure_item_id	IN	NUMBER,		-- bug 4068182
				p_return_status		OUT NOCOPY  VARCHAR2
				) IS
BEGIN
	SELECT PSP_ENC_SUMMARY_LINES_S.NEXTVAL
    	INTO P_ENC_SUMMARY_LINE_ID
    	FROM DUAL;
    		INSERT INTO PSP_ENC_SUMMARY_LINES(
						ENC_SUMMARY_LINE_ID,
						BUSINESS_GROUP_ID,
						ENC_CONTROL_ID,
						TIME_PERIOD_ID,
						PERSON_ID,
						ASSIGNMENT_ID,
						EFFECTIVE_DATE,
						SET_OF_BOOKS_ID,
						GL_CODE_COMBINATION_ID,
						PROJECT_ID,
						EXPENDITURE_ORGANIZATION_ID,
						EXPENDITURE_TYPE,
						TASK_ID,
						AWARD_ID,
						SUMMARY_AMOUNT,
						DR_CR_FLAG,
						STATUS_CODE,
						PAYROLL_ID,
						GL_PERIOD_ID,
						GL_PROJECT_FLAG,
                                                SUSPENSE_ORG_ACCOUNT_ID,
                                                SUPERCEDED_LINE_ID,
                                                GMS_POSTING_OVERRIDE_DATE,
                                                GL_POSTING_OVERRIDE_DATE,
						ATTRIBUTE_CATEGORY,		-- Introduced DFF columns for bug fix 2908859
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
						expenditure_item_id,			-- bug 4068182
						LAST_UPDATE_DATE,
						LAST_UPDATED_BY,
						LAST_UPDATE_LOGIN,
						CREATED_BY,
						CREATION_DATE)
    					VALUES(
						p_enc_summary_line_id,
						p_business_group_id,
						p_enc_control_id,
						p_time_period_id,
						nvl(p_person_id,NULL),
						nvl(p_assignment_id,NULL),
						p_effective_date,
						nvl(p_set_of_books_id,NULL),
						p_gl_code_combination_id,
						p_project_id,
						p_expenditure_organization_id,
						p_expenditure_type,
						p_task_id,
						p_award_id,
						p_summary_amount,
						p_dr_cr_flag,
						p_status_code,
						p_payroll_id,
						p_gl_period_id,
						p_gl_project_flag,
                                                p_suspense_org_account_id,
                                                p_superceded_line_id,
                                                p_gms_posting_override_date,
                                                p_gl_posting_override_date,
						p_attribute_category,		-- Introduced DFF columns for bug fix 2908859
						p_attribute1,
						p_attribute2,
						p_attribute3,
						p_attribute4,
						p_attribute5,
						p_attribute6,
						p_attribute7,
						p_attribute8,
						p_attribute9,
						p_attribute10,
						p_expenditure_item_id,			-- bug 4068182
						SYSDATE,
						FND_GLOBAL.USER_ID,
						FND_GLOBAL.LOGIN_ID,
						FND_GLOBAL.USER_ID,
						SYSDATE);
		p_return_status	:= fnd_api.g_ret_sts_success;

EXCEPTION
	WHEN OTHERS THEN
		--dbms_output.put_line('Insert into psp_enc_summary_lines failed');
     		g_error_api_path := 'insert_into_enc_sum_lines:'||g_error_api_path;
     		fnd_msg_pub.add_exc_msg('PSP_ENC_LIQ_TRAN','INSERT_INTO_ENC_SUM_LINES');
     		p_return_status := fnd_api.g_ret_sts_unexp_error;
END insert_into_enc_sum_lines;
	End of comment for bug fix 4625734	*****/

--	##########################################################################
--	This procedure transfers the liquidated lines from psp_enc_summary_lines
--		with gl_project_flag = 'G' to gl_interface

--      This procedure transfers the liquidated lines from PSP_ENC_SUMMARY_LINES table
--      to GL_INTERFACE table and kicks off the JOURNAL IMPORT program in GL and sends
--      ENC_CONTROL_ID and END_DATE for the relevant TIME_PERIOD_ID
--      and GROUP_ID into the tie back procedure
--	##########################################################################

PROCEDURE tr_to_gl_int( p_payroll_action_id    IN NUMBER,
--			p_action_type	IN  VARCHAR2, -- Added for Restart Update Enh.
			p_return_status	OUT NOCOPY  VARCHAR2
			) IS
/*****	Commented for bug fix 4625734
	CURSOR 	enc_control_cur IS
   	SELECT 	enc_control_id,
          	payroll_id,
          	time_period_id,
                gl_phase                  ---added for 2444657
   	FROM   	psp_enc_controls
   	WHERE 	payroll_id = nvl(p_payroll_id, payroll_id)
   	AND	(total_dr_amount IS NOT NULL OR total_cr_amount IS NOT NULL)
   	AND	action_type in ('N', 'Q', 'U') -- Included 'Q' for Enh. 2143723
   	AND    	action_code IN ('IT', 'IL','IU') -- Replaced I with IL and IU for Bug#2142865
   	AND    	run_id = g_run_id
   	AND	business_group_id = g_bg_id
	AND	set_of_books_id = g_sob_id
        AND     gl_phase in  ('Summarize','Transfer');   --- added for 2444657

	CURSOR	int_cur(l_enc_control_id	IN  NUMBER) IS	Removed l_enc_control_id parameter for bug fix 4625734
	SELECT	pesl.enc_summary_line_id,
		pesl.enc_control_id,
		pesl.effective_date,
		pesl.gl_code_combination_id,
		TO_NUMBER(DECODE(pesl.dr_cr_flag, 'D', pesl.summary_amount, NULL)) debit_amount,
		TO_NUMBER(DECODE(pesl.dr_cr_flag, 'C', pesl.summary_amount, NULL)) credit_amount,
		pesl.dr_cr_flag,
		pesl.set_of_books_id,
	  	pesl.attribute1,
          	pesl.attribute2,
          	pesl.attribute3,
          	pesl.attribute4,
          	pesl.attribute5,
          	pesl.attribute6,
          	pesl.attribute7,
          	pesl.attribute8,
          	pesl.attribute9,
          	pesl.attribute10,
          	pesl.attribute11,
          	pesl.attribute12,
          	pesl.attribute13,
          	pesl.attribute14,
          	pesl.attribute15,
          	pesl.attribute16,
          	pesl.attribute17,
          	pesl.attribute18,
          	pesl.attribute19,
          	pesl.attribute20,
          	pesl.attribute21,
          	pesl.attribute22,
          	pesl.attribute23,
          	pesl.attribute24,
          	pesl.attribute25,
          	pesl.attribute26,
          	pesl.attribute27,
          	pesl.attribute28,
          	pesl.attribute29,
          	pesl.attribute30
	FROM	psp_enc_summary_lines pesl
	WHERE 	pesl.status_code = 'N'
	AND	pesl.gl_code_combination_id is NOT NULL
	AND	pesl.enc_control_id = l_enc_control_id;
	End of comment for bug fix 4625734	*****/

--	enc_control_rec		enc_control_cur%ROWTYPE;	Commented for bug fix 4625734
--	int_rec			int_cur%ROWTYPE;		Commented for bug fix 4625734

--	l_sob_id		NUMBER(15);
--	l_status		VARCHAR2(50);
--	l_acc_date		DATE;
	l_user_je_cat	 	VARCHAR2(25);
	l_user_je_source	VARCHAR2(25);
--	l_period_name		VARCHAR2(35);
--	l_period_end_dt		DATE;
	l_enc_type_id		NUMBER(15);
--	l_ent_dr		NUMBER;
--	l_ent_cr		NUMBER;
	l_group_id		NUMBER;
	l_int_run_id		NUMBER;
--	l_ref1			VARCHAR2(100);
--	l_ref4			VARCHAR2(100);

	l_return_status		VARCHAR2(10);
	req_id			NUMBER(15);
	call_status		BOOLEAN;
	rphase			VARCHAR2(30);
	rstatus			VARCHAR2(30);
	dphase			VARCHAR2(30);
	dstatus			VARCHAR2(30);
	message			VARCHAR2(240);
/*****Commented the following for bug fix 4625734
	p_errbuf		VARCHAR2(32767);
	p_retcode		VARCHAR2(32767);
	return_back		EXCEPTION;
	l_rec_count		NUMBER := 0;
	l_error			VARCHAR2(100);
	l_product		VARCHAR2(3);
	l_value			VARCHAR2(200);
	l_table			VARCHAR2(100);
	l_rec_no                number := 0;

        TYPE GL_TIE_RECTYPE IS RECORD (
                R_CONTROL_ID    NUMBER,
                R_END_DATE      DATE,
                R_GROUP_ID      NUMBER);   --- added group_id for 2444657

        GL_TIE_REC      GL_TIE_RECTYPE;

        TYPE GL_TIE_TABTYPE IS TABLE OF GL_TIE_REC%TYPE INDEX BY BINARY_INTEGER;

        GL_TIE_TAB      GL_TIE_TABTYPE;
	End of comment for bug fix 4625734	*****/

       l_tie_back_failed varchar2(1) := NULL;   -- 2479579

--	Introduced the following for bug fix 4507892
TYPE t_number_15 IS TABLE OF NUMBER(15) INDEX BY BINARY_INTEGER;

TYPE r_enc_controls_rec IS RECORD (enc_control_id	t_number_15);
r_enc_controls	r_enc_controls_rec;

TYPE r_group_rec IS RECORD (group_id	t_number_15);
r_groups	r_group_rec;

l_created_by	NUMBER(15);

CURSOR	gl_group_id_cur IS
SELECT	DISTINCT group_id
FROM	psp_enc_summary_lines pesl
WHERE	pesl.payroll_action_id = p_payroll_action_id
/*WHERE	enc_control_id IN	(SELECT 	pec.enc_control_id
   				FROM   	psp_enc_controls pec
   				WHERE 	pec.payroll_id = NVL(p_payroll_id, pec.payroll_id)
				AND	action_type IN ('N', 'U', 'Q')
				AND	action_code IN ('IT', 'IL', 'IU')
   				AND    	pec.run_id = g_run_id
   				AND	pec.business_group_id = g_bg_id
				AND	pec.set_of_books_id = g_sob_id
        			AND     pec.gl_phase = 'Transfer')*/
AND	status_code = 'N'
AND	gl_code_combination_id IS NOT NULL;

CURSOR	enc_control_id_cur IS
SELECT	DISTINCT enc_control_id
FROM	psp_enc_summary_lines
WHERE	group_id = l_group_id;
--	End of changes for bug fix 4507892
BEGIN
	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Entering Transfer to GL Interface');

	l_created_by := fnd_global.user_id;

--        gl_tie_tab.delete;		Commented for bug fix 4625734

	gl_je_source(	l_user_je_source,
			l_return_status);
	IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	l_user_je_source: ' || l_user_je_source);

	gl_je_cat(	l_user_je_cat,
			l_return_status);
	IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	l_user_je_cat: ' || l_user_je_cat);

	enc_type(	l_enc_type_id,
			l_return_status);
	IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	l_enc_type_id: ' || l_enc_type_id);

	SELECT 	gl_interface_control_s.nextval
	INTO	l_group_id
	FROM 	dual;

	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	l_group_id: ' || l_group_id);

	UPDATE	psp_enc_summary_lines
	SET	group_id = l_group_id
	WHERE 	status_code = 'N'
	AND	gl_code_combination_id IS NOT NULL
	AND	superceded_line_id IS NOT NULL
	AND	payroll_action_id = p_payroll_action_id;
/*	AND	enc_control_id IN	(SELECT 	pec.enc_control_id
					FROM	psp_enc_controls pec
					WHERE	pec.payroll_id = nvl(p_payroll_id, pec.payroll_id)
					AND	(pec.total_dr_amount IS NOT NULL OR pec.total_cr_amount IS NOT NULL)
					AND	action_type IN ('N', 'U', 'Q')
					AND	action_code IN ('IT', 'IL', 'IU')
					AND	pec.run_id = g_run_id
					AND	pec.business_group_id = g_bg_id
					AND	pec.set_of_books_id = g_sob_id
					AND	pec.gl_phase = 'Summarize');*/

	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Updated group_id in psp_enc_summary_lines for new liquidation lines');


	INSERT INTO gl_interface
		(status,		set_of_books_id,		accounting_date,
		currency_code,		date_created,			created_by,
		actual_flag,		user_je_category_name,		user_je_source_name,
		encumbrance_type_id,	code_combination_id,		entered_dr,
		entered_cr,		group_id,			reference1,
		reference2,		reference4,			reference6,
		reference10,		attribute1,			attribute2,
		attribute3,		attribute4,			attribute5,
		attribute6,		attribute7,			attribute8,
		attribute9,		attribute10,			attribute11,
		attribute12,		attribute13,			attribute14,
		attribute15,		attribute16,			attribute17,
		attribute18,		attribute19,			attribute20,
		reference21,		reference22,			reference23,
		reference24,		reference25,			reference26,
		reference27,		reference28,			reference29,
		reference30)
	SELECT	'NEW',			pesl.set_of_books_id,		pesl.effective_date,
		DECODE(pec.uom, 'M', g_currency_code, 'STAT'),	SYSDATE,	l_created_by,
		'E',			l_user_je_cat,		l_user_je_source,
		l_enc_type_id,			pesl.gl_code_combination_id,
			TO_NUMBER(DECODE(pesl.dr_cr_flag, 'D', pesl.summary_amount, NULL)) debit_amount,
		TO_NUMBER(DECODE(pesl.dr_cr_flag, 'C', pesl.summary_amount, NULL)) credit_amount,
					l_group_id,			pesl.enc_control_id,
		pesl.enc_control_id,	'LD ENCUMBRANCE',		'E:' || pesl.enc_summary_line_id,
		'LD ENCUMBRANCE',	attribute1,			attribute2,
          	attribute3,		attribute4,			attribute5,
          	attribute6,		attribute7,			attribute8,
          	attribute9,		attribute10,			attribute11,
          	attribute12,		attribute13,			attribute14,
          	attribute15,		attribute16,			attribute17,
          	attribute18,		attribute19,			attribute20,
          	attribute21,		attribute22,			attribute23,
          	attribute24,		attribute25,			attribute26,
          	attribute27,		attribute28,			attribute29,
          	attribute30
	FROM	psp_enc_summary_lines pesl,
		psp_enc_controls pec
	WHERE 	pec.enc_control_id = pesl.enc_control_id
	AND	pesl.status_code = 'N'
	AND	pesl.gl_code_combination_id is NOT NULL
	AND	superceded_line_id IS NOT NULL
	AND	pesl.payroll_action_id = p_payroll_action_id;
/*	AND	enc_control_id IN	(SELECT 	pec.enc_control_id
					FROM	psp_enc_controls pec
					WHERE	pec.payroll_id = nvl(p_payroll_id, pec.payroll_id)
					AND	(pec.total_dr_amount IS NOT NULL OR pec.total_cr_amount IS NOT NULL)
					AND	action_type IN ('N', 'U', 'Q')
					AND	action_code IN ('IT', 'IL', 'IU')
					AND	pec.run_id = g_run_id
					AND	pec.business_group_id = g_bg_id
					AND	pec.set_of_books_id = g_sob_id
					AND	pec.gl_phase = 'Summarize');*/

	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Number of records inserted into GL_INTERFACE: ' || SQL%ROWCOUNT);

/*****	Commented the following as part of bug fix 4625734
	OPEN enc_control_cur;
  	LOOP
   		FETCH enc_control_cur INTO enc_control_rec;
   		IF enc_control_cur%NOTFOUND THEN
     		CLOSE enc_control_cur;
     		EXIT;
   		END IF;


                      --- moved this code out of int_cur loop for 2444657
			BEGIN
			SELECT	period_name, end_date
			INTO	l_period_name, l_period_end_dt
			FROM 	per_time_periods
			WHERE	time_period_id = enc_control_rec.time_period_id ;
		        EXCEPTION
			WHEN NO_DATA_FOUND THEN
			l_value := 'time period id =';
			l_table := 'PER_TIME_PERIODS';
			fnd_message.set_name('PSP','PSP_TR_VALUE_NOT_FOUND');
			fnd_message.set_token('VALUE','l_value');
			fnd_message.set_token('TABLE','l_table');
			fnd_msg_pub.add;
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		        END;
              If enc_control_rec.gl_phase = 'Summarize' then --- added for 2444657
		UPDATE	psp_enc_summary_lines
		SET	group_id = l_group_id
		WHERE	status_code = 'N'
		AND	gl_code_combination_id is NOT NULL
		AND	enc_control_id = enc_control_rec.enc_control_id;

		l_ref1		:=	enc_control_rec.enc_control_id;
		l_ref4		:=	'LD ENCUMBRANCE';
		---l_rec_count := 0;   commented for 2444657

		OPEN int_cur(enc_control_rec.enc_control_id);
		LOOP
			FETCH int_cur into int_rec;
			IF int_cur%NOTFOUND THEN
			CLOSE int_cur;
			EXIT;
			END IF;
			l_sob_id := int_rec.set_of_books_id;
                    --    insert into psp_stout values(11,'one int re  found');
--dbms_output.put_line('sob='||l_sob_id);

-- For Bug 2478000
-- Commented the following code
/ *
			BEGIN
			SELECT	currency_code
			INTO	l_cur_code
			FROM 	gl_sets_of_books
			WHERE	set_of_books_id = l_sob_id;
			EXCEPTION
			WHEN NO_DATA_FOUND THEN
			l_error := 'CURRENCY CODE';
			l_product := 'GL';
			fnd_message.set_name('PSP','PSP_TR_NOT_SET_UP');
			fnd_message.set_token('ERROR','l_error');
			fnd_message.set_token('PRODUCT','l_product');
			fnd_msg_pub.add;
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
			END;* /
-- End of Comments for bug 2478000



--dbms_output.put_line('cur code='||l_cur_code);

			l_rec_count 	:=	l_rec_count + 1;

			IF int_rec.dr_cr_flag = 'C' THEN
				l_ent_cr	:=	int_rec.summary_amount;
				l_ent_dr	:=	NULL;
			ELSIF int_rec.dr_cr_flag = 'D' THEN
				l_ent_cr	:=	NULL;
				l_ent_dr	:=	int_rec.summary_amount;
			END IF;
   --insert into psp_stout values(3, 'before inserting into gl interface');
  -- insert into psp_stout values(4, 'sline id is '||to_char(int_rec.enc_summary_line_id));


				insert_into_gl_int(
						L_SOB_ID,
						INT_REC.EFFECTIVE_DATE,
						G_CURRENCY_CODE,
                				L_USER_JE_CAT,
						L_USER_JE_SOURCE,
						L_ENC_TYPE_ID,
		    				INT_REC.GL_CODE_COMBINATION_ID,
						L_ENT_DR,
						L_ENT_CR,
                				l_group_id,
						L_REF1,
						L_REF1,
						L_REF4,
                				'E:' || INT_REC.ENC_SUMMARY_LINE_ID,
	                			L_REF4,
						INT_REC.ATTRIBUTE1,
						INT_REC.ATTRIBUTE2,
                				INT_REC.ATTRIBUTE3,
						INT_REC.ATTRIBUTE4,
                				INT_REC.ATTRIBUTE5,
						INT_REC.ATTRIBUTE6,
		    				INT_REC.ATTRIBUTE7,
						INT_REC.ATTRIBUTE8,
                				INT_REC.ATTRIBUTE9,
						INT_REC.ATTRIBUTE10,
                				INT_REC.ATTRIBUTE11,
						INT_REC.ATTRIBUTE12,
                				INT_REC.ATTRIBUTE13,
						INT_REC.ATTRIBUTE14,
                				INT_REC.ATTRIBUTE15,
						INT_REC.ATTRIBUTE16,
		    				INT_REC.ATTRIBUTE17,
						INT_REC.ATTRIBUTE18,
                				INT_REC.ATTRIBUTE19,
						INT_REC.ATTRIBUTE20,
                				INT_REC.ATTRIBUTE21,
						INT_REC.ATTRIBUTE22,
                				INT_REC.ATTRIBUTE23,
						INT_REC.ATTRIBUTE24,
                				INT_REC.ATTRIBUTE25,
						INT_REC.ATTRIBUTE26,
		    				INT_REC.ATTRIBUTE27,
						INT_REC.ATTRIBUTE28,
                				INT_REC.ATTRIBUTE29,
						INT_REC.ATTRIBUTE30,
                				L_RETURN_STATUS);

       			IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         		--dbms_output.put_line('Insert into gl_interface failed');
         		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       			END IF;

		END LOOP;	--int_cur loop
               end if; --- phase = 'Summarize'  ... for 2444657

               if enc_control_rec.gl_phase = 'Summarize' then -- replaced l_rec_count >0 ..2444657

		     l_rec_no := l_rec_no + 1;
                  --   insert into psp_stout values(11, 'one record found for tp');
		     gl_tie_tab(l_rec_no).r_end_date := l_period_end_dt;
		  gl_tie_tab(l_rec_no).r_control_id := enc_control_rec.enc_control_id;
                  gl_tie_tab(l_rec_no).r_group_id := l_group_id;  --- 2444657

              else   --- added.. phase is 'Transfer' ... 2444657
		     l_rec_no := l_rec_no + 1;
                  gl_tie_tab(l_rec_no).r_end_date := l_period_end_dt;
                  gl_tie_tab(l_rec_no).r_control_id := enc_control_rec.enc_control_id;
                  select group_id
                  into  gl_tie_tab(l_rec_no).r_group_id
                  from psp_enc_summary_lines
                  where status_code = 'N'
                    and gl_code_combination_id is not null
                    and rownum = 1;
               end if;  --- 2444657

	END LOOP;	-- enc_cur loop
	End of comment for bug fix 4625734	*****/

	IF (SQL%ROWCOUNT > 0) THEN
--     		IF l_rec_count > 0 THEN   --- uncommented for 2444657	Changed the check for bug fix 4625734
                 --    if l_rec_no > 0 then  commented for 2444657
           --      insert into psp_stout values(91, 'kicking gl journal import');

     		SELECT 	GL_JOURNAL_IMPORT_S.NEXTVAL
     		INTO 	l_int_run_id
     		FROM 	dual;

		fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	l_int_run_id: ' || l_int_run_id);

     			insert into gl_interface_control(
         					je_source_name,
        					status,
      						interface_run_id,
        					group_id,
                  				set_of_books_id)
       					VALUES (
                  				l_user_je_source,
         					'S',
                  				l_int_run_id,
                  				l_group_id,
                  				g_sob_id
          	       				);

		fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Inserted control record into gl_interface_control');
		fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Before submitting Journal Import');

     			req_id := fnd_request.submit_request(
	    							'SQLGL',
         							'GLLEZL',
         							'',
         							'',
         							FALSE,
           							to_char(l_int_run_id),
            							to_char(g_sob_id),
           							'N',
          							'',
            							'',
          							g_enable_enc_summ_gl,
           							'W');		-- Changed 'N' to 'W' for bug fix 2908859
--dbms_output.put_line('Req id = '||to_char(req_id));

     		IF req_id = 0 THEN
			fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Journal Import submission failed');
   -- insert into psp_stout values(0, 'req did not get submitted');

       		fnd_message.set_name('PSP','PSP_TR_GL_IMP_FAILED');
       		fnd_msg_pub.add;
       		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

     		ELSE
			fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Submitted Journal Import (req_id: ' || req_id || ')');
        --    insert into psp_stout values(94, 'transfer in Gl');
/*****	Converted the following UPDATE TO BULK for R12 performance fixes (bug 4507892)
            update psp_enc_controls
               set gl_phase = 'Transfer'
             where enc_control_id in (select distinct enc_control_id
                                        from psp_enc_summary_lines
                                       where group_id = l_group_id);
	End of comment for bug fix 4507892	*****/
--	Introduced the following for bug fix 4507892
		OPEN enc_control_id_cur;
		FETCH enc_control_id_cur BULK COLLECT INTO r_enc_controls.enc_control_id;
		CLOSE enc_control_id_cur;

		fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	r_enc_controls.enc_control_id.COUNT: ' || r_enc_controls.enc_control_id.COUNT);

		FORALL I IN 1..r_enc_controls.enc_control_id.COUNT
		UPDATE	psp_enc_controls
		SET	gl_phase = 'Transfer'
		WHERE	enc_control_id = r_enc_controls.enc_control_id(I);

		fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Updated gl_phase to ''Transfer'' in psp_enc_controls');

		r_enc_controls.enc_control_id.DELETE;
--	End of Changes for bug fix 4507892

    --insert into psp_stout values(5, ' request submitted ');
       		COMMIT;

		fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Calling gather_table_stats for psp_enc_summary_lines');
		fnd_stats.gather_table_stats('PSP', 'PSP_ENC_SUMMARY_LINES');
		fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Completed gather_table_stats for psp_enc_summary_lines');

		fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Waiting for Journal Import request to complete');

       		call_status := fnd_concurrent.wait_for_request(req_id, 10, 0,
                rphase, rstatus, dphase, dstatus, message);

       			IF call_status = FALSE then
			fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Journal Import failed');
         		fnd_message.set_name('PSP','PSP_TR_GL_IMP_FAILED');
         		fnd_msg_pub.add;
         		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       			END IF;
		fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Journal Import completed');
     		END IF;
		END IF; -- l_rec_count > 0 moved this from below tie back for 2444657 (checks interface.COUNT bug 4625734)

/*****	Commented the following for bug fix 4625734
		for i in 1..gl_tie_tab.count
		loop
            --     insert into psp_stout values(94,'gl_enc_tie_back');
     		gl_enc_tie_back(gl_tie_tab(i).r_control_id,
                            gl_tie_tab(i).r_end_date,
                            gl_tie_tab(i).r_group_id, --- replaced l_group_id, ...2444657
                            g_bg_id,
                            g_sob_id,
                            'N',          -- Bug 2039196: new parameter.
                            p_action_type, -- Added for Restart Update Enh.
                            l_return_status);
     		IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN   --- moved this stmnt inside loop
                        l_tie_back_failed := 'Y';   -- 2479579
     		END IF;
		end loop;
	end of comment for bug fix 4625734	*****/

--	Introduced the following for bug fix 4625734
		OPEN gl_group_id_cur;
		FETCH gl_group_id_cur BULK COLLECT INTO r_groups.group_id;
		CLOSE gl_group_id_cur;

		fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	r_groups.group_id.COUNT: ' || r_groups.group_id.COUNT);

		FOR recno IN 1..r_groups.group_id.COUNT
		LOOP
			fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Calling gl_enc_tie_back for group_id: ' || r_groups.group_id(recno));

			gl_enc_tie_back(NULL,		-- Enc Control id isnt reqd as tie back is by each group
					NULL,		-- Period end date isnt reqd as tie back doesnt post to  suspense
					r_groups.group_id(recno),
					g_bg_id,
					g_sob_id,
					'N',
					NULL, --p_action_type,
					l_return_status);

			IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
				fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	gl_enc_tie_back failed for group_id: ' || r_groups.group_id(recno));
			ELSE
				fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	gl_enc_tie_back successful for group_id: ' || r_groups.group_id(recno));
			END IF;
		END LOOP;
--	End of changes for bug fix 4625734

/*****	Commented the following for bug fix 4625734 as the distinct group is fetched as prt of bug fix 4625734
 --- added this wrapper LOOP on delete gl_interface for 2444657
  --- this is to ensure that all interface recs are purged, in case
  -- the previous Liquidation did not.
 for i in 1..gl_tie_tab.count
 loop
   if gl_tie_tab(i).r_group_id is not null then
    delete gl_interface
    where group_id = gl_tie_tab(i).r_group_id
    and user_je_source_name = l_user_je_source
    and set_of_books_id = l_sob_id;

        for k in 1..gl_tie_tab.count
        loop
          if gl_tie_tab(i).r_group_id = gl_tie_tab(k).r_group_id and
             i <> k then
               gl_tie_tab(k).r_group_id := null;
          end if;
        end loop;

        gl_tie_tab(i).r_group_id := null;
    end if;
 end loop;
	End of comment for bug fix 4625734	*****/

--	Introduced the following for bug fix 4625734
	FORALL recno IN 1..r_groups.group_id.COUNT
	DELETE	gl_interface
	WHERE	group_id = r_groups.group_id(recno)
	AND	user_je_source_name = l_user_je_source
	AND	set_of_books_id = g_sob_id;

	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Deleted groups from gl_interface for which gl_enc_tie_back is complete');
--	End of changes for bug fix 4625734

     	COMMIT;   -- moved commit below del stmnt for 2479579

	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	COMMITted gl_enc_tie_back');

/*****	commented for Enh. 2768298 Removal of suspense posting in liquidation
   if g_invalid_suspense = 'Y' then   -- introduced this IF-ELSE for 2479579
        enc_batch_end(g_payroll_id,p_action_type,'N',g_bg_id,g_sob_id,l_return_status);
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    end if;
	End of comment for Enh. 2768298	Removal of suspense posting in Liquidation *****/

   p_return_status := fnd_api.g_ret_sts_success;
	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Leaving TR_TO_GL_INT');
EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   	--dbms_output.put_line('Gone to one level top ..................');
     	g_error_api_path := 'TR_TO_GL_INT:'||g_error_api_path;
     	p_return_status := fnd_api.g_ret_sts_unexp_error;
	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Leaving TR_TO_GL_INT');
/*****	Commented for bug fix 4625734
   WHEN RETURN_BACK THEN
     	p_return_status := fnd_api.g_ret_sts_success;
	End of comment for bug fix 4625734	*****/
   WHEN OTHERS THEN
     	g_error_api_path := 'TR_TO_GL_INT:'||g_error_api_path;
     	fnd_msg_pub.add_exc_msg('PSP_ENC_LIQ_TRAN','TR_TO_GL_INT');
     	p_return_status := fnd_api.g_ret_sts_unexp_error;
	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Leaving TR_TO_GL_INT');
END tr_to_gl_int;

--	##########################################################################
--	This procedure retrieves the user_je_source_name from gl_je_sources
--	##########################################################################

PROCEDURE gl_je_source(	P_USER_JE_SOURCE_NAME  OUT NOCOPY  VARCHAR2,
                        P_RETURN_STATUS        OUT NOCOPY  VARCHAR2) IS
   l_error	VARCHAR2(100);
   l_product	VARCHAR2(3);
 BEGIN
   SELECT user_je_source_name
   INTO   p_user_je_source_name
   FROM   gl_je_sources
   WHERE  je_source_name = 'OLD';
 EXCEPTION
  WHEN NO_DATA_FOUND THEN
   l_error := 'JE SOURCES = OLD';
   l_product := 'GL';
   fnd_message.set_name('PSP','PSP_TR_NOT_SET_UP');
   fnd_message.set_token('ERROR',l_error);
   fnd_message.set_token('PRODUCT',l_product);
   fnd_msg_pub.add;
   p_return_status := fnd_api.g_ret_sts_unexp_error;
  WHEN OTHERS THEN
    g_error_api_path := 'gl_je_source:'||g_error_api_path;
    fnd_msg_pub.add_exc_msg('psp_enc_liq_tran','gl_je_source');
    p_return_status := fnd_api.g_ret_sts_unexp_error;
 END gl_je_source;

--	##########################################################################
--	This procedure retrieves the user_je_category_name from gl_je_categories
--	##########################################################################

PROCEDURE gl_je_cat(	P_USER_JE_CATEGORY_NAME  OUT NOCOPY  VARCHAR2,
                        P_RETURN_STATUS          OUT NOCOPY  VARCHAR2) IS
   l_error	VARCHAR2(100);
   l_product	VARCHAR2(3);
 BEGIN
   SELECT user_je_category_name
   INTO   p_user_je_category_name
   FROM   gl_je_categories
   WHERE  je_category_name = 'OLD';
 EXCEPTION
  WHEN NO_DATA_FOUND THEN
   l_error := 'JE CATEGORY = OLD';
   l_product := 'GL';
   fnd_message.set_name('PSP','PSP_TR_NOT_SET_UP');
   fnd_message.set_token('ERROR',l_error);
   fnd_message.set_token('PRODUCT',l_product);
   fnd_msg_pub.add;
   p_return_status := fnd_api.g_ret_sts_unexp_error;
  WHEN OTHERS THEN
    g_error_api_path := 'gl_je_cat:'||g_error_api_path;
    fnd_msg_pub.add_exc_msg('psp_enc_liq_tran','gl_je_cat');
    p_return_status := fnd_api.g_ret_sts_unexp_error;
 END gl_je_cat;

--	##########################################################################
--	This procedure retrieves the encumbrance_type_id from gl_encumbrance_types
--	##########################################################################

PROCEDURE enc_type(	P_ENCUMBRANCE_TYPE_ID  OUT NOCOPY  VARCHAR2,
                        P_RETURN_STATUS        OUT NOCOPY  VARCHAR2) IS
   l_error	VARCHAR2(100);
   l_product	VARCHAR2(3);

 BEGIN
   SELECT encumbrance_type_id
   INTO   p_encumbrance_type_id
   FROM   gl_encumbrance_types
   WHERE  encumbrance_type = 'OLD'
   AND    enabled_flag = 'Y';

 EXCEPTION
  WHEN NO_DATA_FOUND THEN
   l_error := 'ENCUMBRANCE TYPE = OLD';
   l_product := 'GL';
   fnd_message.set_name('PSP','PSP_TR_NOT_SET_UP');
   fnd_message.set_token('ERROR',l_error);
   fnd_message.set_token('PRODUCT',l_product);
   fnd_msg_pub.add;
   p_return_status := fnd_api.g_ret_sts_unexp_error;
  WHEN OTHERS THEN
    g_error_api_path := 'enc_type:'||g_error_api_path;
    fnd_msg_pub.add_exc_msg('psp_enc_liq_tran','enc_type');
    p_return_status := fnd_api.g_ret_sts_unexp_error;

END enc_type;

--	##########################################################################
--	This procedure ties back all the transactions posted into Oracle General Ledger
--		with Oracle Labor Distribution where the journal import is successful.
--	In case of failure the transactions in Oracle Labor Distribution are turned
--		back into their original state.
--	##########################################################################

PROCEDURE gl_enc_tie_back(
				p_enc_control_id	IN	NUMBER,
				p_period_end_date 	IN 	DATE,
				p_group_id		IN	NUMBER,
                                p_business_group_id IN  NUMBER,
                                p_set_of_books_id   IN  NUMBER,
                                p_mode                  IN      varchar2,      ---Bug 2039196: new param
				p_action_type 		IN 	VARCHAR2, -- Added for Restart Update Enh.
				p_return_status		OUT NOCOPY	VARCHAR2
				) IS
CURSOR	int_count_cur IS
SELECT	COUNT(1)
FROM	gl_interface
WHERE	user_je_source_name = 'OLD'
AND	set_of_books_id = p_set_of_books_id
AND	group_id = p_group_id;

   CURSOR gl_tie_back_success_cur IS
   SELECT enc_summary_line_id,
		enc_control_id,
          dr_cr_flag,
	  summary_amount
   FROM   psp_enc_summary_lines
   WHERE  group_id = p_group_id;
--   and    enc_control_id = p_enc_control_id;		Commented for bug fix 4625734

   CURSOR gl_tie_back_reject_cur IS
   SELECT status,
          to_number(trim(substr(reference6,3)))   --- 4072324
   FROM   gl_interface
   WHERE  user_je_source_name = 'OLD'
     AND  set_of_books_id = p_set_of_books_id
     AND  group_id = p_group_id;
/***** Commented for bug fix 4625734
        AND     reference6 IN   (SELECT 'E:' || enc_summary_line_id -- Introduced for bug fix 3953230
                                FROM    psp_enc_summary_lines pesl
                                WHERE   pesl.enc_control_id = p_enc_control_id);
	End of comment for bug fix 4625734	*****/

/*****	Commented for Enh. 2768298 Removal of suspense posting in Liquidation
   CURSOR assign_susp_ac_cur(P_ENC_LINE_ID	IN	NUMBER) IS
   SELECT pel.rowid,
          pel.effective_date,
          --pel.attribute30
          pel.suspense_org_account_id,
          pel.superceded_line_id
   FROM   psp_enc_summary_lines pel
   WHERE  pel.enc_summary_line_id = p_enc_line_id
   and pel.enc_control_id=p_enc_control_id
   and pel.status_code='N';

-- Get the Organization details ...

   CURSOR get_susp_org_cur(P_ORG_ID	IN	VARCHAR2) IS
   SELECT hou.organization_id, hou.name, poa.gl_code_combination_id
     FROM hr_all_organization_units hou, psp_organization_accounts poa
    WHERE hou.organization_id = poa.organization_id
      AND poa.business_group_id = p_business_group_id
      AND poa.set_of_books_id = p_set_of_books_id
      AND poa.organization_account_id = p_org_id;
	End of comment for bug fix 2768298	*****/

/*****	Commented for bug fix 4625734
   CURSOR get_org_id_cur(P_LINE_ID	IN	NUMBER) IS
   SELECT hou.organization_id, hou.name
   FROM   hr_all_organization_units hou,
  	      per_assignments_f paf,
          psp_enc_summary_lines pel
   WHERE  pel.enc_summary_line_id = p_line_id
    AND pel.enc_control_id=p_enc_control_id
--   AND    pel.assignment_id = paf.assignment_id
    AND pel.person_id= paf.person_id
     AND paf.primary_flag='Y'
   AND    pel.effective_date BETWEEN paf.effective_start_date AND paf.effective_end_date
   AND    paf.organization_id = hou.organization_id
   AND    pel.effective_date between
		  hou.date_from and nvl(hou.date_to,pel.effective_date);

  l_orig_org_name		hr_all_organization_units_tl.name%TYPE; -- Bug 2447912: Modified declaration
  l_orig_org_id			number;
  l_superceded_line_id          number;

-- End of Get org id cursor  Ravindra
	End of comment for bug fix 4625734	*****/

/*
   CURSOR assign_susp_ac_cur IS
   SELECT hou.name,
          hou.organization_id,
          pel.rowid,
          pel.assignment_id,
          pel.effective_date,
          pel.attribute30,
          pel.gl_code_combination_id
   FROM   hr_all_organization_units hou,
          per_assignments_f paf,
          psp_enc_summary_lines pel
   WHERE  pel.enc_control_id = p_enc_control_id
   AND	  pel.gl_project_flag = 'G'
   AND	  pel.status_code = 'A'
   AND    pel.assignment_id = paf.assignment_id(+)
   AND    pel.effective_date BETWEEN paf.effective_start_date AND paf.effective_end_date
   AND	  pel.business_group_id = g_bg_id
   AND	  pel.set_of_books_id = g_sob_id
   AND    paf.organization_id = hou.organization_id
   AND    pel.effective_date between hou.date_from and nvl(hou.date_to,pel.effective_date);
*/

/*****	Commented for Enh. 2768298 Removal of suspense posting in Liquidation

   CURSOR org_susp_ac_cur(P_ORGANIZATION_ID	IN	NUMBER,
                          P_ENCUMBRANCE_DATE	IN	DATE) IS
   SELECT poa.organization_account_id,
          poa.gl_code_combination_id,
          poa.project_id,
          poa.expenditure_organization_id,
          poa.expenditure_type,
          poa.award_id,
          poa.task_id
   FROM   psp_organization_accounts poa
   WHERE  poa.organization_id = p_organization_id
   AND    poa.account_type_code = 'S'
   AND	  poa.business_group_id = g_bg_id
   AND	  poa.set_of_books_id = g_sob_id
   AND    p_encumbrance_date BETWEEN poa.start_date_active AND
                                      nvl(poa.end_date_active,p_encumbrance_date);

   -- CURSOR global_susp_ac_cur(P_ENCUMBRANCE_DATE	IN	DATE) IS
   CURSOR global_susp_ac_cur(P_ORGANIZATION_ACCOUNT_ID  IN	NUMBER) IS  --BUG 2056877
   SELECT poa.organization_account_id,
          poa.gl_code_combination_id,
          poa.project_id,
          poa.expenditure_organization_id,
          poa.expenditure_type,
          poa.award_id,
          poa.task_id
   FROM   psp_organization_accounts poa
   WHERE
   / * poa.account_type_code = 'G'
   AND	  poa.business_group_id = g_bg_id
   AND	  poa.set_of_books_id = g_sob_id
   AND    p_encumbrance_date BETWEEN poa.start_date_active AND
                                      nvl(poa.end_date_active,p_encumbrance_date); Bug 2056877.* /
          organization_account_id = p_organization_account_id; --Added for bug 2056877.
	End of comment for Enh. Removal of suspense posting in Liquidation	*****/

--   l_organization_name		hr_all_organization_units_tl.name%TYPE; -- Bug 2447912: Modified declaration
--   l_organization_id		NUMBER(15);
--   l_rowid				ROWID;
--   l_assignment_id		NUMBER(9);
--   l_encumbrance_date		DATE;
--   l_suspense_org_account_id  NUMBER(9);		Commented for Enh. 2768298 Removal of suspense posting in Liquidation
--   l_lines_glccid			NUMBER(15);
--   l_organization_account_id	NUMBER(9);
--   l_susp_glccid			NUMBER(15);	Commented for Enh. 2768298 Removal of suspense posting in Liquidation
--   l_project_id			NUMBER(15);
--   l_award_id			NUMBER(15);
--   l_task_id			NUMBER(15);
--   l_status				VARCHAR2(50);
--   l_reference6			VARCHAR2(100);
   l_cnt_gl_interface		NUMBER;
--   l_enc_summary_line_id		NUMBER(10);
--   l_gl_project_flag		VARCHAR2(1);
--   l_suspense_ac_failed		VARCHAR2(1) := 'N';	Commented for Enh. 2768298 Removal of suspense posting in Liquidation
--   l_reversal_ac_failed		VARCHAR2(1) := 'N';
--	   l_suspense_ac_not_found	VARCHAR2(1) := 'N';	Commented for Enh. 2768298 Removal of suspense posting in Liquidation
--   l_susp_ac_found		VARCHAR2(10) := 'TRUE';		Commented for Enh. 2768298 Removal of suspense posting in Liquidation
--   l_summary_amount		NUMBER;
--   l_dr_summary_amount		NUMBER := 0;
--   l_cr_summary_amount		NUMBER := 0;
--   l_dr_cr_flag			VARCHAR2(1);
--   l_effective_date		DATE;

/*****	Commented for Enh. 2768298 Removal of suspense posting in Liquidation
   x_susp_failed_org_name	hr_all_organization_units_tl.name%TYPE; -- Bug 2447912: Modified declaration
   x_susp_failed_status		VARCHAR2(50);
   x_susp_failed_date		DATE;
   x_susp_nf_org_name	       hr_all_organization_units_tl.name%TYPE; -- Bug 2447912: Modified declaration
   x_susp_nf_date			DATE;
	End of comment for Enh. 2768298 Removal of suspense posting in Liquidation	*****/
/*****	Commented for bug fix 4625734
   x_lines_glccid			NUMBER(15);
   l_return_status		VARCHAR2(10);
   l_enc_ref			VARCHAR2(15);
   l_expenditure_organization_id NUMBER(15);
   l_expenditure_type            VARCHAR2(30);
   l_return_value               VARCHAR2(30); --Added for bug 2056877.
   no_profile_exists            EXCEPTION;    --Added for bug 2056877.
   no_val_date_matches          EXCEPTION;    --Added for bug 2056877.
   no_global_acct_exists        EXCEPTION;    --Added for bug 2056877.
	End of comment for bug fix 4625734	****/

TYPE t_number IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE t_number_15 IS TABLE OF NUMBER(15) INDEX BY BINARY_INTEGER;
TYPE t_char_300 IS TABLE OF VARCHAR2(300) INDEX BY BINARY_INTEGER;

TYPE r_interface_rec IS RECORD
	(status			t_char_300,
	enc_summary_line_id	t_number_15,
	dr_cr_flag		t_char_300,
	summary_amount		t_number,
	enc_control_id		t_number_15);
r_interface	r_interface_rec;

FUNCTION PROCESS_COMPLETE RETURN BOOLEAN IS
    l_cnt       NUMBER;
--	Introduced the following for bug fix 4625734
CURSOR	int_count_cur IS
SELECT	COUNT(1)
FROM	gl_interface
WHERE	user_je_source_name = 'OLD'
AND	set_of_books_id = p_set_of_books_id
AND	group_id = p_group_id
AND	status = 'NEW';

TYPE t_number_15 IS TABLE OF NUMBER(15) INDEX BY BINARY_INTEGER;

TYPE r_enc_control_rec IS RECORD
	(enc_control_id	t_number_15);
r_enc_controls	r_enc_control_rec;

TYPE r_superceded_line_rec IS RECORD (superceded_line_id        t_number_15);
r_superceded_lines	r_superceded_line_rec;

CURSOR	superceded_line_id_cur IS
SELECT	superceded_line_id
FROM	psp_enc_summary_lines
WHERE	group_id = p_group_id;

CURSOR	enc_controls_cur IS
SELECT	DISTINCT enc_control_id
FROM	psp_enc_summary_lines
WHERE	group_id = p_group_id;
--	End of changes for bug fix 4625734
 begin
/*****	Changed the following SELECT into CURSOR for bug fix 4625734
   select count(*)
     into l_cnt
     from gl_interface
    where user_je_source_name = 'OLD'
      and set_of_books_id = p_set_of_books_id
      and group_id = p_group_id
      and status = 'NEW';
	End of comment for bug fix 4625734	*****/

	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Entering GL_ENC_TIE_BACK.PROCESS_COMPLETE');

	OPEN int_count_cur;
	FETCH int_count_cur INTO l_cnt;
	CLOSE int_count_cur;

	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	l_cnt: ' || l_cnt);

   if l_cnt = 0 then
	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Leaving GL_ENC_TIE_BACK.PROCESS_COMPLETE');
     return TRUE;
   elsif l_cnt > 0 then

-- -------------------------------------------------------------------------------------------
-- If status = 'NEW' then the journal import process did not kick off
-- for some reason. Return FALSE in this case. So cleanup the tables and try to transfer
-- again after summarization in the second pass.
-- -------------------------------------------------------------------------------------------

     delete from gl_interface
      where user_je_source_name = 'OLD'
	and set_of_books_id = p_set_of_books_id
        and group_id = p_group_id;

	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Deleted from gl_interface');

--	Introduced the following for bug fix 4625734
	OPEN superceded_line_id_cur;
	FETCH superceded_line_id_cur BULK COLLECT INTO r_superceded_lines.superceded_line_id;
	CLOSE superceded_line_id_cur;

	FORALL recno IN 1..r_superceded_lines.superceded_line_id.COUNT
	UPDATE	psp_enc_summary_lines
	SET	status_code = 'A'
	WHERE	enc_summary_line_id = r_superceded_lines.superceded_line_id(recno);

r_superceded_lines.superceded_line_id.DELETE;

	OPEN enc_controls_cur;
	FETCH enc_controls_cur BULK COLLECT INTO r_enc_controls.enc_control_id;
	CLOSE enc_controls_cur;

	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	r_enc_controls.enc_control_id.COUNT: ' || r_enc_controls.enc_control_id.COUNT);
--	End of changes for bug fix 4625734

     delete from psp_enc_summary_lines
      where group_id = p_group_id;
--	and enc_control_id = p_enc_control_id;		Commented for bug fix 4625734

	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Deleted from psp_enc_summary_lines');

--	Introduced the following for bug fix 4625734
	FORALL recno IN 1..r_enc_controls.enc_control_id.COUNT
	UPDATE	psp_enc_controls pec
	SET	gl_phase = 'TieBack'
	WHERE	enc_control_id = r_enc_controls.enc_control_id(recno);
--	End of changes for bug fix 4625734

	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Reset gl_phase to ''TieBack''');

	r_enc_controls.enc_control_id.DELETE;
	g_liq_has_failed_transactions := TRUE;

	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Leaving GL_ENC_TIE_BACK.PROCESS_COMPLETE');

     return FALSE;
   end if;
 exception
 when others then
	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Leaving GL_ENC_TIE_BACK.PROCESS_COMPLETE');
   return TRUE;
 end PROCESS_COMPLETE;

 BEGIN
--insert_into_psp_stout( 'gl enc tie back' );
	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Entering GL_ENC_TIE_BACK procedure');
	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	p_group_id: ' || p_group_id);

   IF (PROCESS_COMPLETE) THEN

/*****	Commented the following for bug fix 4625734
   SELECT count(*)
     INTO l_cnt_gl_interface
     FROM gl_interface
    WHERE user_je_source_name = 'OLD'
      AND set_of_books_id = p_set_of_books_id
      AND group_id = p_group_id;
	End of comment for bug fix 4625734	*****/

	OPEN int_count_cur;
	FETCH int_count_cur INTO l_cnt_gl_interface;
	CLOSE int_count_cur;

	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	l_cnt_gl_interface: ' || l_cnt_gl_interface);

	IF (l_cnt_gl_interface > 0) THEN
		OPEN gl_tie_back_reject_cur;
		FETCH gl_tie_back_reject_cur BULK COLLECT INTO r_interface.status, r_interface.enc_summary_line_id;
		CLOSE gl_tie_back_reject_cur;

		fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	r_interface.status.COUNT: ' || r_interface.status.COUNT);

		FOR recno IN 1..r_interface.status.COUNT
                LOOP
                  if (r_interface.status(recno) = 'P' OR SUBSTR(r_interface.status(recno), 1, 1) = 'W') and
                      not g_gl_run then
			g_gl_run := TRUE;
                   end if;
                END LOOP;
                if g_gl_run then
		  fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	g_gl_run: TRUE');
                end if;


		FORALL recno IN 1..r_interface.status.COUNT
		UPDATE	psp_enc_summary_lines
		SET	interface_status = r_interface.status(recno)
--			status_code = 'R'
		WHERE	enc_summary_line_id = r_interface.enc_summary_line_id(recno)
		AND	r_interface.status(recno) <> 'P'
                AND     SUBSTR(r_interface.status(recno), 1, 1) <> 'W';

		IF (SQL%ROWCOUNT > 0) THEN
			g_liq_has_failed_transactions := TRUE;
			g_rejected_group_id := p_group_id;
			fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	g_liq_has_failed_transactions: TRUE');
		END IF;

		fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	g_rejected_group_id: ' || g_rejected_group_id);
		fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	SQL%ROWCOUNT: ' || SQL%ROWCOUNT);

		FORALL recno IN 1..r_interface.status.COUNT
		UPDATE	psp_enc_controls
		SET	gl_phase = 'TieBack'
		WHERE	enc_control_id IN	(SELECT	pesl.enc_control_id
						FROM	psp_enc_summary_lines pesl
						WHERE	pesl.enc_summary_line_id = r_interface.enc_summary_line_id(recno));

		fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	TieBack SQL%ROWCOUNT: ' || SQL%ROWCOUNT);

		FORALL recno IN 1..r_interface.status.COUNT
		UPDATE	psp_enc_controls
		SET	gl_phase = 'Summarize'
		WHERE	enc_control_id IN	(SELECT	pesl.enc_control_id
						FROM	psp_enc_summary_lines pesl
						WHERE	pesl.enc_summary_line_id = r_interface.enc_summary_line_id(recno)
						AND	pesl.status_code = 'N');

		fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Summarize SQL%ROWCOUNT: ' || SQL%ROWCOUNT);
	ELSIF (l_cnt_gl_interface = 0) THEN
		g_accepted_group_id := p_group_id;

		fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	g_accepted_group_id: ' || g_accepted_group_id);

		OPEN gl_tie_back_success_cur;
		FETCH gl_tie_back_success_cur BULK COLLECT INTO r_interface.enc_summary_line_id, r_interface.enc_control_id, r_interface.dr_cr_flag, r_interface.summary_amount;
		CLOSE gl_tie_back_success_cur;

		fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	r_interface.enc_summary_line_id.COUNT: ' || r_interface.enc_summary_line_id.COUNT);

		FORALL recno IN 1..r_interface.enc_summary_line_id.COUNT
		UPDATE	psp_enc_summary_lines
		SET	status_code = 'L'
		WHERE	enc_summary_line_id = r_interface.enc_summary_line_id(recno)
		AND	status_code = 'N';

		IF (g_person_id IS NOT NULL) THEN
			FORALL recno IN 1..r_interface.enc_summary_line_id.COUNT
			UPDATE	psp_enc_lines_history
			SET	change_flag = 'L'
			WHERE	enc_summary_line_id = (SELECT	pesl2.superceded_line_id
						FROM	psp_enc_summary_lines pesl2
						WHERE	pesl2.enc_summary_line_id = r_interface.enc_summary_line_id(recno));
			fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Updated respective lines in psp_enc_lines_history to ''L'' status SQL%ROWCOUNT: ' || SQL%ROWCOUNT);
		END IF;

		FORALL recno IN 1..r_interface.enc_control_id.COUNT
		UPDATE	psp_enc_controls pec
		SET	gl_phase = 'TieBack',
			summ_gl_dr_amount = NVL(summ_gl_dr_amount, 0) + DECODE(r_interface.dr_cr_flag(recno), 'D', r_interface.summary_amount(recno), 0),
			summ_gl_cr_amount = NVL(summ_gl_cr_amount, 0) + DECODE(r_interface.dr_cr_flag(recno), 'C', r_interface.summary_amount(recno), 0)
		WHERE	enc_control_id = r_interface.enc_control_id(recno);
		fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Updated gl_phase, summ_gl_dr_amount, summ_gl_cr_amount in psp_enc_controls SQL%ROWCOUNT: ' || SQL%ROWCOUNT);
	END IF;

/*****	Commented the following for bug fix 4625734
   IF l_cnt_gl_interface > 0 THEN

     OPEN gl_tie_back_reject_cur;
     LOOP
	FETCH gl_tie_back_reject_cur INTO l_status,l_enc_ref;
	IF gl_tie_back_reject_cur%NOTFOUND THEN
         CLOSE gl_tie_back_reject_cur;
         EXIT;
        END IF;

         --    insert into psp_stout values(19,'in tie back reject cursor');
	  l_reference6 := substr(l_enc_ref, 3);

--	Introduced the following for Enh. 2768298 Removal of suspense posting in Enc. Liquidation
	IF (l_status = 'P' OR substr(l_status,1,1) = 'W') THEN
		UPDATE	psp_enc_summary_lines
		SET	status_code='N'
		WHERE	enc_summary_line_id = TO_NUMBER(l_reference6);
		g_gl_run := TRUE;
	ELSE
		UPDATE	psp_enc_summary_lines
		SET	interface_status = l_status,
			status_code='R'
		WHERE	enc_summary_line_id = TO_NUMBER(l_reference6);

		UPDATE psp_enc_summary_lines
		SET	status_code='A'
		WHERE	enc_summary_line_id IN (SELECT	superceded_line_id
		FROM	psp_enc_summary_lines
		WHERE	enc_summary_line_id = TO_NUMBER(l_reference6));
                g_rejected_group_id := p_group_id; --- for 3477373
	END IF;
--	End of changes for  Enh. 2768298 Removal of suspense posting in Enc. Liquidation.

/ *****	Commented the following for Enh. Removal of suspense posting in Liq.
	  -- update enc_summary_lines with the reject status code
       UPDATE 	psp_enc_summary_lines
       SET 	interface_status = l_status
	--,	status_code = 'R'
       WHERE 	enc_summary_line_id = to_number(l_reference6);
/ *
	 AND	enc_control_id = p_enc_control_id;
       if sql%notfound then
        null;
       end if;
    commented out for bug fix 1832670
 * /
       OPEN assign_susp_ac_cur(to_number(l_reference6));
       LOOP

         FETCH assign_susp_ac_cur INTO l_rowid, l_encumbrance_date,l_suspense_org_account_id,
         l_superceded_line_id;

	       IF assign_susp_ac_cur%NOTFOUND THEN
          --   insert into psp_stout values(22,'assign susp ac cursor not found');
             CLOSE assign_susp_ac_cur;
             EXIT;
         END IF;
          --   insert into psp_stout values(25,'assign susp ac cursor  found');

 	       if l_suspense_org_account_id is not null  then
	         OPEN get_susp_org_cur(l_suspense_org_account_id);
	         FETCH get_susp_org_cur into l_organization_id, l_organization_name,
				                         l_lines_glccid;
                 if get_susp_org_cur%notfound then null;
                 end if;
/ *  for summarization at gl ccid level etc:, assignment info is
   not availible  * /
	         CLOSE get_susp_org_cur;
       end if;

  	 IF l_status = 'P' OR substr(l_status,1,1) = 'W'  THEN
          --   insert into psp_stout values(29,'stauts in P or W ');

           UPDATE psp_enc_summary_lines
          --  SET status_code = 'A'
          --    set status_code='L'
              set status_code='N'    ---- changed to NEW for 2479579
            WHERE rowid = l_rowid;



 -- if the suspense a/c failed,update the status of the whole batch and display the error

  	 ELSIF l_suspense_org_account_id IS NOT NULL AND
               (l_status <> 'P' OR substr(l_status,1,1) <> 'W')  THEN
          --   insert into psp_stout values(31,'susp has failed ');

           x_susp_failed_org_name := l_organization_name;
           x_susp_failed_status   := l_status;
           x_susp_failed_date     := l_encumbrance_date;
           l_suspense_ac_failed := 'Y';

		UPDATE psp_enc_summary_lines
            SET reject_reason_code = l_status,
          --      status_code = 'A'
                  status_code='R'
            WHERE rowid = l_rowid;

         update psp_enc_summary_lines set status_code='A' where
         enc_summary_line_id in (select superceded_line_id from
         psp_Enc_summary_lines where rowid=l_rowid);

         ELSE
           --insert_into_psp_stout( 'stick susp a/c        ');
           l_susp_ac_found := 'TRUE';
            -- insert into psp_stout values(25,'in teh else part for suspense account');


	       OPEN get_org_id_cur(to_number(l_reference6));
	       FETCH get_org_id_cur into l_orig_org_id, l_orig_org_name;
   	       CLOSE get_org_id_cur;

       / *    if get_org_id_cur%NOTFOUND then
            -- insert into psp_stout values(20,'get_org_id itself not  found');
            OPEN global_susp_ac_cur(l_encumbrance_date);
            FETCH global_susp_ac_cur INTO l_organization_account_id,l_susp_glccid,l_project_id,l_expenditure_organization_id,l_expenditure_type,l_award_id, l_task_id;
            IF global_susp_ac_cur%NOTFOUND THEN
             --insert into psp_stout values(23,'globalsusp for gl not found');
              --insert_into_psp_stout( 'glob sus a/c not found ');
              l_susp_ac_found := 'FALSE';
              l_suspense_ac_not_found := 'Y';
              x_susp_nf_org_name := l_orig_org_name;
              x_susp_nf_date     := l_encumbrance_date;
            END IF;
            CLOSE global_susp_ac_cur;
	   else         Commented for bug 2056877  * /
           OPEN org_susp_ac_cur(l_orig_org_id,l_encumbrance_date);
           FETCH org_susp_ac_cur INTO l_organization_account_id,l_susp_glccid,l_project_id,l_expenditure_organization_id,l_expenditure_type,l_award_id,l_task_id;

           IF org_susp_ac_cur%NOTFOUND  THEN
        --     insert into psp_stout values(21,'org susp for gl not found');
           / *  Following code is added for bug 2056877 ,Added validation for generic suspense account  * /
              l_return_value := psp_general.find_global_suspense(l_encumbrance_date,
							  p_business_group_id,
                                                          p_set_of_books_id,
                                                          l_organization_account_id );
      	  / *  --------------------------------------------------------------------
      	   Valid return values are
      	   PROFILE_VAL_DATE_MATCHES       Profile and Value and Date matching 'G'
      	   NO_PROFILE_EXISTS              No Profile
       	   NO_VAL_DATE_MATCHES            Profile and Either Value/date do not
            		                  match with 'G'
   	   NO_GLOBAL_ACCT_EXISTS          No 'G' exists
     	    ----------------------------------------------------------------------  * /
             / * Introduced for Restart Update/Quick Update Encumbrance Lines enh.
               Record for invalid suspense reason in control record record so
               that  Restart Update can derive the failed point * /
	      IF l_return_value <> 'PROFILE_VAL_DATE_MATCHES' THEN
	        IF p_action_type IN  ('Q','U') THEN
	           UPDATE psp_enc_controls
	           SET gl_phase = 'INVALID_SUSPENSE'
	           WHERE enc_control_id = p_enc_control_id;
	        END IF;
	        g_invalid_suspense:='Y';
	    / *     IF p_mode='N' THEN
	          enc_batch_end(g_payroll_id,p_action_type,'N',g_bg_id,g_sob_id,l_return_status);
	        END IF;  * /   --- commented for 2479579
	      END IF ;

              IF   l_return_value = 'PROFILE_VAL_DATE_MATCHES' THEN
            --	   OPEN global_susp_ac_cur(l_encumbrance_date);
            	   OPEN global_susp_ac_cur(l_organization_account_id); --Added for bug 2056877
           	   FETCH global_susp_ac_cur INTO l_organization_account_id,l_susp_glccid,l_project_id,l_expenditure_organization_id,l_expenditure_type,l_award_id, l_task_id;
	          IF global_susp_ac_cur%NOTFOUND THEN
	      	  / * 	l_susp_ac_found := 'FALSE';
              		l_suspense_ac_not_found := 'Y';
              		x_susp_nf_org_name := l_orig_org_name;
             		x_susp_nf_date     := l_encumbrance_date;  Commented for bug 2056877  * /
             		/ *  Added for Restart Update/Quick Update Encumbrance Lines Enh. * /
             		IF p_action_type IN ('Q','U') THEN
             		  UPDATE psp_enc_controls
             		  SET gl_phase = 'INVALID_SUSPENSE'
             		  WHERE enc_control_id = p_enc_control_id;
             		END IF;
             		g_invalid_suspense:='Y';
                        / *    commented for 2479579
             		IF p_mode ='N' THEN
             		  enc_batch_end(g_payroll_id,p_action_type,'N',g_bg_id,g_sob_id,l_return_status);
             		END IF;  * /
             		RAISE no_global_acct_exists; --Added for bug 2056877
                   END IF;
                   CLOSE global_susp_ac_cur;
              ELSIF l_return_value = 'NO_GLOBAL_ACCT_EXISTS' THEN
    		     RAISE no_global_acct_exists;
             ELSIF l_return_value = 'NO_VAL_DATE_MATCHES' THEN
         	    RAISE no_val_date_matches;
             ELSIF l_return_value = 'NO_PROFILE_EXISTS' THEN
         	    RAISE no_profile_exists;
             END IF; -- Bug 2056877.
         END IF;
         CLOSE org_susp_ac_cur;
--   end if;  --Commented for bug 2056877.
--   close get_org_id_cur;  --Commented for bug 2056877.

           IF l_susp_ac_found = 'TRUE' THEN


             IF l_susp_glccid IS NOT NULL THEN
               l_gl_project_flag := 'G';
               l_effective_date := p_period_end_date;
             ELSE
               l_gl_project_flag := 'P';

               psp_general.poeta_effective_date(l_encumbrance_date,
                                    l_project_id,
                                    l_award_id,
                                    l_task_id,
                                    l_effective_date,
                                    l_return_status);
               IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                   --insert_into_psp_stout( 'poeta call failed      ');
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
               END IF;

             END IF;

             -- assign the organization suspense account and gl status
	      UPDATE psp_enc_summary_lines
              SET suspense_org_account_id = l_organization_account_id,
                  reject_reason_code ='EL:'||l_status,
                  gl_project_flag = l_gl_project_flag,
		  gl_code_combination_id = decode(l_gl_project_flag, 'P', null, l_susp_glccid),
		  project_id = decode(l_gl_project_flag, 'P', l_project_id, null),
		  expenditure_organization_id = decode(l_gl_project_flag, 'P', l_expenditure_organization_id, null),
		  expenditure_type = decode(l_gl_project_flag, 'P', l_expenditure_type, null),
		  task_id = decode(l_gl_project_flag, 'P', l_task_id, null),
		  award_id = decode(l_gl_project_flag, 'P', l_award_id, null),
--                   status_code = 'A'
                status_code='N'
              WHERE rowid = l_rowid;

   --  insert into psp_stout values(99, 'after updating the suspense account');
--insert into psp_Stout values(99,'gl:= '||l_susp_glccid);
-- insert into psp_stout values (99, 'project_id is '||l_project_id);
-- insert into psp_stout values (99, 'award id  is '||l_award_id);
     --- modified the update for 2530853, flipping the sign of amount if 'C'
    if l_gl_project_flag ='P' then
     update psp_Enc_summary_lines set       ------dr_cr_flag='D',
     summary_amount= decode(dr_cr_flag,'C',-summary_amount,summary_amount)
     where rowid=l_rowid;
    end if;

/ * ************************************************************************
           UPDATE psp_enc_summary_lines
              SET attribute30 = l_organization_account_id,
                  reject_reason_code = 'EL:' ||l_status,
                  gl_project_flag = l_gl_project_flag,
                  effective_date = l_encumbrance_date,
                  status_code = 'A'
              WHERE rowid = l_rowid;


Original code modified  so that the suspense account is stamped

*************************************************************************** * /


           END IF;
         END IF;

       END LOOP;
	End of comment for Enh. 2768298 Removal of suspense posting in Enc. Liquidation	***** /

     END LOOP;
    if nvl(g_gl_run,FALSE) then
     update psp_enc_controls
        set gl_phase = 'Summarize' --- replaced 'TieBack'  .... for 2444657
      where enc_control_id = p_enc_control_id;
    else
      update psp_enc_controls   --- introduced else part for 3413373
        set gl_phase =  'TieBack'
      where enc_control_id = p_enc_control_id;
    end if;
/ *  commented: Bug 2039196
     IF l_reversal_ac_failed = 'Y' THEN
       fnd_message.set_name('PSP','PSP_GL_REVERSE_AC_REJECT');
       fnd_message.set_token('GLCCID',x_lines_glccid);
       fnd_msg_pub.add;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF; * /

/ *****	Commented for Enh. 2768298 Removal of suspense posting in Liquidation
     IF l_suspense_ac_failed = 'Y' THEN
       / * Added for Restart Update/Quick Update Encumbrance Lines Enh. * /
       IF p_action_type IN ('Q','U') THEN
          UPDATE psp_enc_controls
          SET gl_phase = 'INVALID_SUSPENSE'
          WHERE enc_control_id = p_enc_control_id;
       END IF;
        -- removed statement set invalid susp to 'Y' for 2479579
       fnd_message.set_name('PSP','PSP_TR_GL_SUSP_AC_REJECT');
       fnd_message.set_token('ORG_NAME',x_susp_failed_org_name);
       fnd_message.set_token('PAYROLL_DATE',x_susp_failed_date);
       fnd_message.set_token('ERROR_MSG',x_susp_failed_status);
       fnd_msg_pub.add;
            -- removed call enc_batch_end from here moved it to tr_to_gl for 2479579
     END IF;
	End of comment for Enh. Removal of suspense posting in Liquidation	***** /

/ *Commented for Restart Update/Quick Update Encumbrance Lines Enh.
  because of the introduction of get global suspense in previous fix 2056877
     IF l_suspense_ac_not_found = 'Y' THEN
       fnd_message.set_name('PSP','PSP_LD_SUSPENSE_AC_NOT_EXIST');
       fnd_message.set_token('ORG_NAME',x_susp_nf_org_name);
       fnd_message.set_token('PAYROLL_DATE',x_susp_nf_date);
       fnd_msg_pub.add;
       -- Bug 2039196: Introduced the if condn.
       if p_mode = 'N' then
         enc_batch_end(g_payroll_id,p_action_type, 'N',g_bg_id, g_sob_id,l_return_status);
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       end if;
     END IF;
* /

   ELSIF l_cnt_gl_interface = 0 THEN
      g_accepted_group_id := p_group_id;   --- for 3477373
     --
     OPEN gl_tie_back_success_cur;
     LOOP
       FETCH gl_tie_back_success_cur INTO l_enc_summary_line_id,
       l_dr_cr_flag,l_summary_amount;
       IF gl_tie_back_success_cur%NOTFOUND THEN
         CLOSE gl_tie_back_success_cur;
         EXIT;
       END IF;
     -- insert into psp_stout values(11,'in tie back success cur -- PROBLEM');
       -- update records in psp_enc_summary_lines as 'A'
       UPDATE psp_enc_summary_lines
       SET status_code = 'L'
       WHERE enc_summary_line_id = l_enc_summary_line_id
	and status_code = 'N';

        if g_person_id is not null then
        --- added following for 3477373
         update psp_enc_lines_history
         set change_flag = 'L'
         where enc_summary_line_id = ( select superceded_line_id
                                      from psp_enc_summary_lines
                                      where  enc_summary_line_id = l_enc_summary_line_id);
        end if;


       IF l_dr_cr_flag = 'D' THEN
         l_dr_summary_amount := l_dr_summary_amount + l_summary_amount;
       ELSIF l_dr_cr_flag = 'C' THEN
         l_cr_summary_amount := l_cr_summary_amount + l_summary_amount;
       END IF;

      END LOOP;
/ *
	UPDATE psp_enc_summary_lines
	SET status_code = 'P'
--	WHERE enc_summary_line_id = l_enc_summary_line_id
       WHERE enc_control_id = p_enc_control_id
      and group_id=p_group_id
	and gl_project_flag = 'G'
	and status_code = 'A';

* /

    if l_dr_cr_flag = 'D' then
	UPDATE psp_enc_controls
       SET summ_gl_cr_amount = l_dr_summary_amount
       WHERE enc_control_id = p_enc_control_id;
    elsif l_dr_cr_flag = 'C' then
	UPDATE psp_enc_controls
           SET summ_gl_dr_amount = l_cr_summary_amount
       WHERE enc_control_id = p_enc_control_id;
    end if;
  --- moved this stmnt from below endif..for 2444657
   update psp_enc_controls
      set gl_phase = 'TieBack'
    where enc_control_id = p_enc_control_id;

   END IF;
	End of comment for bug fix 4625734	*****/

   --
   END IF; -- IF (PROCESS_COMPLETE)

   p_return_status := fnd_api.g_ret_sts_success;
	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Leaving GL_ENC_TIE_BACK');
 EXCEPTION

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     --dbms_output.put_line('Gone to one level top ..................');
     g_error_api_path := 'GL_ENC_TIE_BACK:'||g_error_api_path;
     p_return_status := fnd_api.g_ret_sts_unexp_error;
	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Leaving GL_ENC_TIE_BACK');
/*****	Commented the following as part of bug fix 4625734
     / * Added Exceptions for bug 2056877 * /
     WHEN NO_PROFILE_EXISTS THEN
      g_error_api_path := SUBSTR('GL_ENC_TIE_BACK:'||g_error_api_path,1,230);
      fnd_message.set_name('PSP','PSP_NO_PROFILE_EXISTS');
      fnd_msg_pub.add;
   p_return_status := fnd_api.g_ret_sts_success;  --- changed error to success for 2479579

   WHEN NO_VAL_DATE_MATCHES THEN
      g_error_api_path := SUBSTR('GL_ENC_TIE_BACK:'||g_error_api_path,1,230);
      fnd_message.set_name('PSP','PSP_NO_VAL_DATE_MATCHES');
      fnd_message.set_token('ORG_NAME',l_orig_org_name);
      fnd_message.set_token('PAYROLL_DATE',l_encumbrance_date);
      fnd_msg_pub.add;
      p_return_status := fnd_api.g_ret_sts_unexp_error;
   p_return_status := fnd_api.g_ret_sts_success;  --- changed error to success for 2479579

   WHEN NO_GLOBAL_ACCT_EXISTS THEN
      g_error_api_path := SUBSTR('GL_ENC_TIE_BACK:'||g_error_api_path,1,230);
      fnd_message.set_name('PSP','PSP_NO_GLOBAL_ACCT_EXISTS');
      fnd_message.set_token('ORG_NAME',l_orig_org_name);
      fnd_message.set_token('PAYROLL_DATE',l_encumbrance_date);
      fnd_msg_pub.add;
      p_return_status := fnd_api.g_ret_sts_unexp_error;  --End of Modification forBug 2056877.
   p_return_status := fnd_api.g_ret_sts_success;  --- changed error to success for 2479579
	end of comment for bug fix 4625734	*****/

   WHEN OTHERS THEN
      g_error_api_path := 'GL_ENC_TIE_BACK:'||g_error_api_path;
      fnd_msg_pub.add_exc_msg('PSP_ENC_LIQ_TRAN','GL_ENC_TIE_BACK');
      p_return_status := fnd_api.g_ret_sts_unexp_error;
	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Leaving GL_ENC_TIE_BACK');

END gl_enc_tie_back;

/*****	Commented the following procedure as part of bug fix 4625734
--*	##########################################################################
--	This procedure inserts data into gl_interface
--	##########################################################################

PROCEDURE insert_into_gl_int (
			P_SET_OF_BOOKS_ID 		IN	NUMBER,
			P_ACCOUNTING_DATE			IN	DATE,
			P_CURRENCY_CODE			IN	VARCHAR2,
			P_USER_JE_CATEGORY_NAME		IN	VARCHAR2,
			P_USER_JE_SOURCE_NAME		IN	VARCHAR2,
			P_ENCUMBRANCE_TYPE_ID		IN	NUMBER,
			P_CODE_COMBINATION_ID		IN	NUMBER,
			P_ENTERED_DR			IN	NUMBER,
			P_ENTERED_CR			IN	NUMBER,
			P_GROUP_ID				IN	NUMBER,
			P_REFERENCE1			IN	VARCHAR2,
			P_REFERENCE2			IN	VARCHAR2,
			P_REFERENCE4			IN	VARCHAR2,
			P_REFERENCE6			IN	VARCHAR2,
			P_REFERENCE10			IN	VARCHAR2,
			P_ATTRIBUTE1			IN	VARCHAR2,
			P_ATTRIBUTE2			IN	VARCHAR2,
			P_ATTRIBUTE3			IN	VARCHAR2,
			P_ATTRIBUTE4			IN	VARCHAR2,
			P_ATTRIBUTE5			IN	VARCHAR2,
			P_ATTRIBUTE6			IN	VARCHAR2,
			P_ATTRIBUTE7			IN	VARCHAR2,
			P_ATTRIBUTE8			IN	VARCHAR2,
			P_ATTRIBUTE9			IN	VARCHAR2,
			P_ATTRIBUTE10			IN	VARCHAR2,
			P_ATTRIBUTE11			IN	VARCHAR2,
			P_ATTRIBUTE12			IN	VARCHAR2,
			P_ATTRIBUTE13			IN	VARCHAR2,
			P_ATTRIBUTE14			IN	VARCHAR2,
			P_ATTRIBUTE15			IN	VARCHAR2,
			P_ATTRIBUTE16			IN	VARCHAR2,
			P_ATTRIBUTE17			IN	VARCHAR2,
			P_ATTRIBUTE18			IN	VARCHAR2,
			P_ATTRIBUTE19			IN	VARCHAR2,
			P_ATTRIBUTE20			IN	VARCHAR2,
			P_ATTRIBUTE21			IN	VARCHAR2,
			P_ATTRIBUTE22			IN	VARCHAR2,
			P_ATTRIBUTE23			IN	VARCHAR2,
			P_ATTRIBUTE24			IN	VARCHAR2,
			P_ATTRIBUTE25			IN	VARCHAR2,
			P_ATTRIBUTE26			IN	VARCHAR2,
			P_ATTRIBUTE27			IN	VARCHAR2,
			P_ATTRIBUTE28			IN	VARCHAR2,
			P_ATTRIBUTE29			IN	VARCHAR2,
			P_ATTRIBUTE30			IN	VARCHAR2,
			P_RETURN_STATUS			OUT NOCOPY	VARCHAR2) IS
 BEGIN

   INSERT INTO GL_INTERFACE(
	STATUS,
	SET_OF_BOOKS_ID,
	ACCOUNTING_DATE,
	CURRENCY_CODE,
	DATE_CREATED,
	CREATED_BY,
	ACTUAL_FLAG,
	USER_JE_CATEGORY_NAME,
	USER_JE_SOURCE_NAME,
	ENCUMBRANCE_TYPE_ID,
	CODE_COMBINATION_ID,
	ENTERED_DR,
	ENTERED_CR,
	GROUP_ID,
	REFERENCE1,
	REFERENCE2,
	REFERENCE4,
	REFERENCE6,
	REFERENCE10,
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
	REFERENCE21,
	REFERENCE22,
	REFERENCE23,
	REFERENCE24,
	REFERENCE25,
	REFERENCE26,
	REFERENCE27,
	REFERENCE28,
	REFERENCE29,
	REFERENCE30)
   VALUES(
	'NEW',
	P_SET_OF_BOOKS_ID,
	P_ACCOUNTING_DATE,
	P_CURRENCY_CODE,
	SYSDATE,
	FND_GLOBAL.USER_ID,
	'E',
	P_USER_JE_CATEGORY_NAME,
	P_USER_JE_SOURCE_NAME,
	P_ENCUMBRANCE_TYPE_ID,
	P_CODE_COMBINATION_ID,
	P_ENTERED_DR,
	P_ENTERED_CR,
	P_GROUP_ID,
	P_REFERENCE1,
	P_REFERENCE2,
	P_REFERENCE4,
	P_REFERENCE6,
	P_REFERENCE10,
	P_ATTRIBUTE1,
	P_ATTRIBUTE2,
	P_ATTRIBUTE3,
	P_ATTRIBUTE4,
	P_ATTRIBUTE5,
	P_ATTRIBUTE6,
	P_ATTRIBUTE7,
	P_ATTRIBUTE8,
	P_ATTRIBUTE9,
	P_ATTRIBUTE10,
	P_ATTRIBUTE11,
	P_ATTRIBUTE12,
	P_ATTRIBUTE13,
	P_ATTRIBUTE14,
	P_ATTRIBUTE15,
	P_ATTRIBUTE16,
	P_ATTRIBUTE17,
	P_ATTRIBUTE18,
	P_ATTRIBUTE19,
	P_ATTRIBUTE20,
	P_ATTRIBUTE21,
	P_ATTRIBUTE22,
	P_ATTRIBUTE23,
	P_ATTRIBUTE24,
	P_ATTRIBUTE25,
	P_ATTRIBUTE26,
	P_ATTRIBUTE27,
	P_ATTRIBUTE28,
	P_ATTRIBUTE29,
	P_ATTRIBUTE30);
    --dbms_output.put_line('Insert into gl_interface successful.................');

    p_return_status := fnd_api.g_ret_sts_success;

EXCEPTION
   WHEN OTHERS THEN
      --dbms_output.put_line('Error while inserting into gl_interface..........');
      g_error_api_path := 'insert_into_gl_int:'||g_error_api_path;
      fnd_msg_pub.add_exc_msg('psp_enc_liq_tran','insert_into_gl_int');
      p_return_status := fnd_api.g_ret_sts_unexp_error;


END insert_into_gl_int;
	End of comment for bug fix 4625734	*****/

--	##########################################################################
--	This procedure liquidates all the lines from  psp_enc_summary_lines
--		where gl_project_flag = 'P' by creating new lines
--			in psp_enc_summary_lines
--	##########################################################################
--	Introduced the following for bug fix 4625734
PROCEDURE create_gms_enc_liq_lines	(p_payroll_id	IN		NUMBER,
					p_action_type	IN		VARCHAR2,
					p_return_status	OUT NOCOPY	VARCHAR2) IS
CURSOR	enc_liq_cur IS
SELECT	enc_summary_line_id,
	effective_date,
	enc_control_id,
	time_period_id,
	set_of_books_id,
	project_id,
	task_id,
	award_id,
	expenditure_organization_id,
	expenditure_type,
	expenditure_item_id,
	-summary_amount,
	DECODE(dr_cr_flag, 'C', 'D', 'D', 'C') dr_cr_flag,
	person_id,
	assignment_id,
	gl_project_flag,
	DECODE(g_dff_grouping_option, 'Y', attribute_category, NULL) attribute_category,
	DECODE(g_dff_grouping_option, 'Y', attribute1, NULL) attribute1,
	DECODE(g_dff_grouping_option, 'Y', attribute2, NULL) attribute2,
	DECODE(g_dff_grouping_option, 'Y', attribute3, NULL) attribute3,
	DECODE(g_dff_grouping_option, 'Y', attribute4, NULL) attribute4,
	DECODE(g_dff_grouping_option, 'Y', attribute5, NULL) attribute5,
	DECODE(g_dff_grouping_option, 'Y', attribute6, NULL) attribute6,
	DECODE(g_dff_grouping_option, 'Y', attribute7, NULL) attribute7,
	DECODE(g_dff_grouping_option, 'Y', attribute8, NULL) attribute8,
	DECODE(g_dff_grouping_option, 'Y', attribute9, NULL) attribute9,
	DECODE(g_dff_grouping_option, 'Y', attribute10, NULL) attribute10
FROM	psp_enc_summary_lines pesl
WHERE	enc_control_id IN (SELECT	pec.enc_control_id
		FROM	psp_enc_controls pec
		WHERE	pec.payroll_id = nvl(p_payroll_id, pec.payroll_id)
		AND	(pec.total_dr_amount IS NOT NULL OR pec.total_cr_amount IS NOT NULL)
		AND	action_type IN ('N', 'U', 'Q')
		AND	action_code = 'IL'
		AND	pec.run_id = g_run_id
		AND	pec.business_group_id = g_bg_id
		AND	pec.set_of_books_id = g_sob_id
		AND	(pec.gms_phase IS NULL or pec.gms_phase = 'TieBack'))
AND	gl_project_flag = 'P'
AND	status_code = 'A'
AND	EXISTS (SELECT	1
		FROM	psp_enc_lines_history pelh
		WHERE	pelh.change_flag  = 'N'
		AND	pelh.enc_summary_line_id = pesl.enc_summary_line_id);

CURSOR	enc_upd_liq_cur IS
SELECT	enc_summary_line_id,
	effective_date,
	enc_control_id,
	time_period_id,
	set_of_books_id,
	project_id,
	task_id,
	award_id,
	expenditure_organization_id,
	expenditure_type,
	expenditure_item_id,
	-summary_amount,
	DECODE(dr_cr_flag, 'C', 'D', 'D', 'C') dr_cr_flag,
	person_id,
	assignment_id,
	gl_project_flag,
	DECODE(g_dff_grouping_option, 'Y', attribute_category, NULL) attribute_category,
	DECODE(g_dff_grouping_option, 'Y', attribute1, NULL) attribute1,
	DECODE(g_dff_grouping_option, 'Y', attribute2, NULL) attribute2,
	DECODE(g_dff_grouping_option, 'Y', attribute3, NULL) attribute3,
	DECODE(g_dff_grouping_option, 'Y', attribute4, NULL) attribute4,
	DECODE(g_dff_grouping_option, 'Y', attribute5, NULL) attribute5,
	DECODE(g_dff_grouping_option, 'Y', attribute6, NULL) attribute6,
	DECODE(g_dff_grouping_option, 'Y', attribute7, NULL) attribute7,
	DECODE(g_dff_grouping_option, 'Y', attribute8, NULL) attribute8,
	DECODE(g_dff_grouping_option, 'Y', attribute9, NULL) attribute9,
	DECODE(g_dff_grouping_option, 'Y', attribute10, NULL) attribute10
FROM	psp_enc_summary_lines pesl
WHERE	enc_control_id IN (SELECT	pec.enc_control_id
		FROM	psp_enc_controls pec
		WHERE	pec.payroll_id = nvl(p_payroll_id, pec.payroll_id)
		AND	(pec.total_dr_amount IS NOT NULL OR pec.total_cr_amount IS NOT NULL)
		AND	action_type IN ('N', 'U', 'Q')
		AND	action_code  = 'IU'
		AND	pec.run_id = g_run_id
		AND	pec.business_group_id = g_bg_id
		AND	pec.set_of_books_id = g_sob_id
		AND	(pec.gms_phase IS NULL or pec.gms_phase = 'TieBack'))
AND	gl_project_flag = 'P'
AND	status_code = 'A'
AND	EXISTS (SELECT	1 FROM	psp_enc_changed_assignments peca
		WHERE	peca.assignment_id = pesl.assignment_id
		AND	peca.request_id IS NOT NULL
		AND	peca.payroll_id = p_payroll_id)
AND	EXISTS (SELECT	1
		FROM	psp_enc_lines_history pelh
		WHERE	pelh.change_flag  = 'N'
		AND	pelh.enc_summary_line_id = pesl.enc_summary_line_id);

CURSOR	enc_qupd_liq_cur IS
SELECT	enc_summary_line_id,
	effective_date,
	enc_control_id,
	time_period_id,
	set_of_books_id,
	project_id,
	task_id,
	award_id,
	expenditure_organization_id,
	expenditure_type,
	expenditure_item_id,
	-summary_amount,
	DECODE(dr_cr_flag, 'C', 'D', 'D', 'C') dr_cr_flag,
	person_id,
	assignment_id,
	gl_project_flag,
	DECODE(g_dff_grouping_option, 'Y', attribute_category, NULL) attribute_category,
	DECODE(g_dff_grouping_option, 'Y', attribute1, NULL) attribute1,
	DECODE(g_dff_grouping_option, 'Y', attribute2, NULL) attribute2,
	DECODE(g_dff_grouping_option, 'Y', attribute3, NULL) attribute3,
	DECODE(g_dff_grouping_option, 'Y', attribute4, NULL) attribute4,
	DECODE(g_dff_grouping_option, 'Y', attribute5, NULL) attribute5,
	DECODE(g_dff_grouping_option, 'Y', attribute6, NULL) attribute6,
	DECODE(g_dff_grouping_option, 'Y', attribute7, NULL) attribute7,
	DECODE(g_dff_grouping_option, 'Y', attribute8, NULL) attribute8,
	DECODE(g_dff_grouping_option, 'Y', attribute9, NULL) attribute9,
	DECODE(g_dff_grouping_option, 'Y', attribute10, NULL) attribute10
FROM	psp_enc_summary_lines pesl
WHERE	enc_control_id IN (SELECT	pec.enc_control_id
		FROM	psp_enc_controls pec
		WHERE	pec.payroll_id = nvl(p_payroll_id, pec.payroll_id)
		AND	(pec.total_dr_amount IS NOT NULL OR pec.total_cr_amount IS NOT NULL)
		AND	action_type IN ('N', 'U', 'Q')
		AND	action_code  = 'IU'
		AND	pec.run_id = g_run_id
		AND	pec.business_group_id = g_bg_id
		AND	pec.set_of_books_id = g_sob_id
		AND	(pec.gms_phase IS NULL or pec.gms_phase = 'TieBack'))
AND	gl_project_flag = 'P'
AND	status_code = 'A'
AND	EXISTS (SELECT	1 FROM	psp_enc_changed_assignments peca
		WHERE	peca.assignment_id = pesl.assignment_id
		AND	peca.request_id IS NOT NULL
		AND	peca.payroll_id = p_payroll_id
AND	peca.change_type IN ('LS', 'ET', 'AS', 'QU'))
AND	EXISTS (SELECT	1
		FROM	psp_enc_lines_history pelh
		WHERE	pelh.change_flag  = 'N'
		AND	pelh.enc_summary_line_id = pesl.enc_summary_line_id);

CURSOR	emp_term_enc_liq_cur IS
SELECT	enc_summary_line_id,
	effective_date,
	enc_control_id,
	time_period_id,
	set_of_books_id,
	project_id,
	task_id,
	award_id,
	expenditure_organization_id,
	expenditure_type,
	expenditure_item_id,
	-summary_amount,
	DECODE(dr_cr_flag, 'C', 'D', 'D', 'C') dr_cr_flag,
	person_id,
	assignment_id,
	gl_project_flag,
	DECODE(g_dff_grouping_option, 'Y', attribute_category, NULL) attribute_category,
	DECODE(g_dff_grouping_option, 'Y', attribute1, NULL) attribute1,
	DECODE(g_dff_grouping_option, 'Y', attribute2, NULL) attribute2,
	DECODE(g_dff_grouping_option, 'Y', attribute3, NULL) attribute3,
	DECODE(g_dff_grouping_option, 'Y', attribute4, NULL) attribute4,
	DECODE(g_dff_grouping_option, 'Y', attribute5, NULL) attribute5,
	DECODE(g_dff_grouping_option, 'Y', attribute6, NULL) attribute6,
	DECODE(g_dff_grouping_option, 'Y', attribute7, NULL) attribute7,
	DECODE(g_dff_grouping_option, 'Y', attribute8, NULL) attribute8,
	DECODE(g_dff_grouping_option, 'Y', attribute9, NULL) attribute9,
	DECODE(g_dff_grouping_option, 'Y', attribute10, NULL) attribute10
FROM	psp_enc_summary_lines pesl
WHERE	enc_control_id IN (SELECT	pec.enc_control_id
		FROM	psp_enc_controls pec
		WHERE	pec.payroll_id = NVL(p_payroll_id, pec.payroll_id)
		AND	(pec.total_dr_amount IS NOT NULL OR pec.total_cr_amount IS NOT NULL)
		AND	action_type IN ('N', 'U', 'Q')
		AND	action_code  = 'IT'
		AND	pec.run_id = g_run_id
		AND	pec.business_group_id = g_bg_id
		AND	pec.set_of_books_id = g_sob_id
		AND	(pec.gms_phase IS NULL OR pec.gms_phase = 'TieBack'))
AND	gl_project_flag = 'P'
AND	status_code = 'A'
AND	person_id = g_person_id
AND	EXISTS (SELECT	1
		FROM	psp_enc_lines_history pelh
		WHERE	pelh.change_flag  = 'N'
		AND	pelh.enc_summary_line_id = pesl.enc_summary_line_id);

TYPE t_number IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE t_number_15 IS TABLE OF NUMBER(15) INDEX BY BINARY_INTEGER;
TYPE t_date IS TABLE OF DATE INDEX BY BINARY_INTEGER;
TYPE t_char_300 IS TABLE OF VARCHAR2(300) INDEX BY BINARY_INTEGER;

TYPE r_liq_lines_rec IS RECORD
	(enc_summary_line_id	t_number_15,
	enc_control_id		t_number_15,
	time_period_id		t_number_15,
	effective_date		t_date,
	set_of_books_id		t_number_15,
	project_id		t_number_15,
	task_id			t_number_15,
	award_id		t_number_15,
	expenditure_org_id	t_number_15,
	expenditure_type	t_char_300,
	expenditure_item_id	t_number_15,
	summary_amount		t_number,
	dr_cr_flag		t_char_300,
	person_id		t_number_15,
	assignment_id		t_number_15,
	gl_project_flag		t_char_300,
	attribute_category	t_char_300,
	attribute1		t_char_300,
	attribute2		t_char_300,
	attribute3		t_char_300,
	attribute4		t_char_300,
	attribute5		t_char_300,
	attribute6		t_char_300,
	attribute7		t_char_300,
	attribute8		t_char_300,
	attribute9		t_char_300,
	attribute10		t_char_300);
r_liq_lines	r_liq_lines_rec;

l_last_updated_by	NUMBER(15);
l_last_update_login	NUMBER(15);
BEGIN
	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Entering CREATE_GMS_ENC_LIQ_LINES');

	l_last_updated_by := fnd_global.user_id;
	l_last_update_login := fnd_global.login_id;

	IF (g_person_id IS NOT NULL) THEN
		fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Fetching Liquidation for Emplopyee Termination Lines');
		OPEN emp_term_enc_liq_cur;
		FETCH emp_term_enc_liq_cur BULK COLLECT INTO r_liq_lines.enc_summary_line_id,
			r_liq_lines.effective_date,	r_liq_lines.enc_control_id,
			r_liq_lines.time_period_id,	r_liq_lines.set_of_books_id,
			r_liq_lines.project_id,		r_liq_lines.task_id,
			r_liq_lines.award_id,		r_liq_lines.expenditure_org_id,
			r_liq_lines.expenditure_type,	r_liq_lines.expenditure_item_id,
			r_liq_lines.summary_amount,	r_liq_lines.dr_cr_flag,
			r_liq_lines.person_id,		r_liq_lines.assignment_id,
			r_liq_lines.gl_project_flag,	r_liq_lines.attribute_category,
			r_liq_lines.attribute1,		r_liq_lines.attribute2,
			r_liq_lines.attribute3,		r_liq_lines.attribute4,
			r_liq_lines.attribute5,		r_liq_lines.attribute6,
			r_liq_lines.attribute7,		r_liq_lines.attribute8,
			r_liq_lines.attribute9,		r_liq_lines.attribute10;
		CLOSE emp_term_enc_liq_cur;
	ELSIF (g_person_id IS NULL AND p_action_type = 'L') THEN
		fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Fetching Regular Liquidation Lines');
		OPEN enc_liq_cur;
		FETCH enc_liq_cur BULK COLLECT INTO r_liq_lines.enc_summary_line_id,
			r_liq_lines.effective_date,	r_liq_lines.enc_control_id,
			r_liq_lines.time_period_id,	r_liq_lines.set_of_books_id,
			r_liq_lines.project_id,		r_liq_lines.task_id,
			r_liq_lines.award_id,		r_liq_lines.expenditure_org_id,
			r_liq_lines.expenditure_type,	r_liq_lines.expenditure_item_id,
			r_liq_lines.summary_amount,	r_liq_lines.dr_cr_flag,
			r_liq_lines.person_id,		r_liq_lines.assignment_id,
			r_liq_lines.gl_project_flag,	r_liq_lines.attribute_category,
			r_liq_lines.attribute1,		r_liq_lines.attribute2,
			r_liq_lines.attribute3,		r_liq_lines.attribute4,
			r_liq_lines.attribute5,		r_liq_lines.attribute6,
			r_liq_lines.attribute7,		r_liq_lines.attribute8,
			r_liq_lines.attribute9,		r_liq_lines.attribute10;
		CLOSE enc_liq_cur;
	ELSIF (p_action_type = 'U') THEN
		fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Fetching Update Liquidation Lines');
		OPEN enc_upd_liq_cur;
		FETCH enc_upd_liq_cur BULK COLLECT INTO r_liq_lines.enc_summary_line_id,
			r_liq_lines.effective_date,	r_liq_lines.enc_control_id,
			r_liq_lines.time_period_id,	r_liq_lines.set_of_books_id,
			r_liq_lines.project_id,		r_liq_lines.task_id,
			r_liq_lines.award_id,		r_liq_lines.expenditure_org_id,
			r_liq_lines.expenditure_type,	r_liq_lines.expenditure_item_id,
			r_liq_lines.summary_amount,	r_liq_lines.dr_cr_flag,
			r_liq_lines.person_id,		r_liq_lines.assignment_id,
			r_liq_lines.gl_project_flag,	r_liq_lines.attribute_category,
			r_liq_lines.attribute1,		r_liq_lines.attribute2,
			r_liq_lines.attribute3,		r_liq_lines.attribute4,
			r_liq_lines.attribute5,		r_liq_lines.attribute6,
			r_liq_lines.attribute7,		r_liq_lines.attribute8,
			r_liq_lines.attribute9,		r_liq_lines.attribute10;
		CLOSE enc_upd_liq_cur;
	ELSIF (p_action_type = 'Q') THEN
		fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Fetching Quick Update Liquidation Lines');
		OPEN enc_qupd_liq_cur;
		FETCH enc_qupd_liq_cur BULK COLLECT INTO r_liq_lines.enc_summary_line_id,
			r_liq_lines.effective_date,	r_liq_lines.enc_control_id,
			r_liq_lines.time_period_id,	r_liq_lines.set_of_books_id,
			r_liq_lines.project_id,		r_liq_lines.task_id,
			r_liq_lines.award_id,		r_liq_lines.expenditure_org_id,
			r_liq_lines.expenditure_type,	r_liq_lines.expenditure_item_id,
			r_liq_lines.summary_amount,	r_liq_lines.dr_cr_flag,
			r_liq_lines.person_id,		r_liq_lines.assignment_id,
			r_liq_lines.gl_project_flag,	r_liq_lines.attribute_category,
			r_liq_lines.attribute1,		r_liq_lines.attribute2,
			r_liq_lines.attribute3,		r_liq_lines.attribute4,
			r_liq_lines.attribute5,		r_liq_lines.attribute6,
			r_liq_lines.attribute7,		r_liq_lines.attribute8,
			r_liq_lines.attribute9,		r_liq_lines.attribute10;
		CLOSE enc_qupd_liq_cur;
	END IF;

	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	r_liq_lines.enc_summary_line_id.COUNT: ' || r_liq_lines.enc_summary_line_id.COUNT);

	FORALL recno IN 1..r_liq_lines.enc_summary_line_id.COUNT
	INSERT INTO psp_enc_summary_lines
		(enc_summary_line_id,		business_group_id,		enc_control_id,
		time_period_id,			person_id,			assignment_id,
		effective_date,			set_of_books_id,		project_id,
		task_id,			award_id,			expenditure_organization_id,
		expenditure_type,		expenditure_item_id,
		summary_amount,			dr_cr_flag,			status_code,
		payroll_id,			gl_project_flag,		superceded_line_id,
		attribute_category,		attribute1,			attribute2,
		attribute3,			attribute4,			attribute5,
		attribute6,			attribute7,			attribute8,
		attribute9,			attribute10,			liquidate_request_id,
		proposed_termination_date,	last_update_date,		last_updated_by,
		last_update_login,		created_by,			creation_date)
	VALUES	(psp_enc_summary_lines_s.NEXTVAL,		g_bg_id,
		r_liq_lines.enc_control_id(recno),		r_liq_lines.time_period_id(recno),
		r_liq_lines.person_id(recno),			r_liq_lines.assignment_id(recno),
		r_liq_lines.effective_date(recno),		r_liq_lines.set_of_books_id(recno),
		r_liq_lines.project_id(recno),			r_liq_lines.task_id(recno),
		r_liq_lines.award_id(recno),			r_liq_lines.expenditure_org_id(recno),
		r_liq_lines.expenditure_type(recno),		r_liq_lines.expenditure_item_id(recno),
		r_liq_lines.summary_amount(recno),		r_liq_lines.dr_cr_flag(recno),		'N',
		p_payroll_id,					r_liq_lines.gl_project_flag(recno),
		r_liq_lines.enc_summary_line_id(recno),		r_liq_lines.attribute_category(recno),
		r_liq_lines.attribute1(recno),			r_liq_lines.attribute2(recno),
		r_liq_lines.attribute3(recno),			r_liq_lines.attribute4(recno),
		r_liq_lines.attribute5(recno),			r_liq_lines.attribute6(recno),
		r_liq_lines.attribute7(recno),			r_liq_lines.attribute8(recno),
		r_liq_lines.attribute9(recno),			r_liq_lines.attribute10(recno),
		g_request_id,					g_actual_term_date,
		SYSDATE,	l_last_updated_by,	l_last_update_login,	l_last_updated_by,	SYSDATE);

	FORALL recno IN 1..r_liq_lines.enc_summary_line_id.COUNT
	UPDATE	psp_enc_summary_lines
	SET	status_code = 'S'
	WHERE	enc_summary_line_id= r_liq_lines.enc_summary_line_id(recno);

	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Updated status_code to ''S'' in psp_enc_summary_lines');

	FORALL recno IN 1..r_liq_lines.enc_summary_line_id.COUNT
	UPDATE	psp_enc_controls
	SET	gms_phase = 'Summarize'
	WHERE	enc_control_id = r_liq_lines.enc_control_id(recno);

	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Updated gms_phase to ''Summarize'' in psp_enc_controls');

	p_return_status	:= fnd_api.g_ret_sts_success;

	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Leaving CREATE_GMS_ENC_LIQ_LINES');
EXCEPTION
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		g_error_api_path := 'CREATE_GMS_ENC_LIQ_LINES:'||g_error_api_path;
		p_return_status := fnd_api.g_ret_sts_unexp_error;
		fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Leaving CREATE_GMS_ENC_LIQ_LINES');
	WHEN OTHERS THEN
		g_error_api_path := 'CREATE_GMS_ENC_LIQ_LINES:'||g_error_api_path;
		fnd_msg_pub.add_exc_msg('PSP_ENC_LIQ_TRAN','CREATE_GMS_ENC_LIQ_LINES');
		p_return_status := fnd_api.g_ret_sts_unexp_error;
		fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Leaving CREATE_GMS_ENC_LIQ_LINES');
END create_gms_enc_liq_lines;
--	End of changes for bug fix 4625734

/*****	Commented the following procedure for revamping it using BULK FETCH features for bug fix 4625734
PROCEDURE create_gms_enc_liq_lines(	p_payroll_id IN NUMBER,
                                        p_action_type IN VARCHAR2,
					p_return_status	OUT NOCOPY  VARCHAR2
					) IS

	CURSOR 	enc_control_cur IS
   	SELECT 	enc_control_id,
          	payroll_id,
		time_period_id
   	FROM   	psp_enc_controls
   	WHERE 	payroll_id = nvl(p_payroll_id, payroll_id)
   	AND	(total_dr_amount IS NOT NULL OR total_cr_amount IS NOT NULL)
   	AND	action_type in ('N', 'Q', 'U') -- Included 'Q' for Enh. 2143723
   	AND    	action_code IN ('IL','IU') -- Replaced I with IL and IU for Bug#2142865
   	AND    	run_id = g_run_id
	AND	business_group_id = g_bg_id
	AND	set_of_books_id = g_sob_id
        AND     (gms_phase  = 'TieBack' or gms_phase is null);   --- added for 2444657

	l_request_id	NUMBER DEFAULT fnd_global.conc_request_id;	-- Introduced for bug 2259310

   	CURSOR 	enc_liq_cur(p_enc_control_id IN NUMBER) IS
    	SELECT distinct	pesl.enc_summary_line_id,
		pesl.effective_date,
		pesl.project_id,
		pesl.expenditure_organization_id,
		pesl.expenditure_type,
		pesl.task_id,
		pesl.award_id,
		pesl.summary_amount,
		pesl.dr_cr_flag,
		pesl.person_id,
		pesl.assignment_id,
		pesl.gl_project_flag,
		DECODE(g_dff_grouping_option, 'Y', pesl.attribute_category, NULL) attribute_category,	-- Introduced DFF columns for bug fix 2908859
		DECODE(g_dff_grouping_option, 'Y', pesl.attribute1, NULL) attribute1,
		DECODE(g_dff_grouping_option, 'Y', pesl.attribute2, NULL) attribute2,
		DECODE(g_dff_grouping_option, 'Y', pesl.attribute3, NULL) attribute3,
		DECODE(g_dff_grouping_option, 'Y', pesl.attribute4, NULL) attribute4,
		DECODE(g_dff_grouping_option, 'Y', pesl.attribute5, NULL) attribute5,
		DECODE(g_dff_grouping_option, 'Y', pesl.attribute6, NULL) attribute6,
		DECODE(g_dff_grouping_option, 'Y', pesl.attribute7, NULL) attribute7,
		DECODE(g_dff_grouping_option, 'Y', pesl.attribute8, NULL) attribute8,
		DECODE(g_dff_grouping_option, 'Y', pesl.attribute9, NULL) attribute9,
		DECODE(g_dff_grouping_option, 'Y', pesl.attribute10, NULL) attribute10,
		pesl.expenditure_item_id			-- 4068182
        --- removed history table from the from clause.. performace 3953230
        FROM  psp_enc_summary_lines pesl
        WHERE  pesl.enc_control_id = p_enc_control_id
  --- changed pelh to pesl for performance ..3684930
         AND pesl.gl_project_flag = 'P'
        AND     pesl.status_code = 'A'
    	AND	pesl.gl_code_combination_id is NULL
         AND    ( (p_action_type='L' and g_person_id is null)    --- g_person_id null check for 3413373
                 OR (g_person_id is not null AND peSL.person_id = g_person_id
                    AND   EXISTS  (SELECT 1 FROM PSP_ENC_LINES_HISTORY PELH WHERE PELH.ENC_SUMMARY_LINE_ID = PESL.ENC_SUMMARY_LINE_ID
                                   AND PELH.CHANGE_FLAG = 'N')
                    AND peSL.time_period_id >= g_term_period_id)
          OR
                 (p_action_type IN ('Q', 'U') AND EXISTS
                                   (SELECT 1 FROM PSP_ENC_LINES_HISTORY PELH WHERE PELH.ENC_SUMMARY_LINE_ID = PESL.ENC_SUMMARY_LINE_ID
                                   AND PELH.CHANGE_FLAG = 'N')
                                        AND     EXISTS  (SELECT 1 FROM psp_enc_changed_assignments peca
                                                WHERE   peca.assignment_id = pesl.assignment_id
                                                AND     peca.request_id IS NOT NULL
                                                AND     peca.payroll_id =p_payroll_id
                                                AND         ((p_action_type = 'Q'  and peca.change_type IN ('LS', 'ET', 'AS', 'QU'))
                                                                OR p_action_type = 'U'))
                                )
                        );

/ *
        AND outer.change_flag='N';

         AND (p_action_type='L') or
(p_action_type='U' and
pesl.assignment_id in (select pelh.assignment_id FROM psp_enc_lines_history pelh,
psp_enc_controls pec
where pec.enc_control_id=p_enc_control_id AND
pelh.time_period_id=pec.time_period_id
and pelh.change_flag='N'));

   Above cursor modified for bug fixes 1832670 and 1776752


* /
	l_para_value		VARCHAR2(1);

	enc_control_rec		enc_control_cur%ROWTYPE;
     	enc_liq_rec		enc_liq_cur%ROWTYPE;
	l_enc_summary_line_id		NUMBER(10);
	l_return_status			VARCHAR2(10);
    l_gms_cnt               NUMBER := 0;

BEGIN
	OPEN enc_control_cur;
  	LOOP
   		FETCH enc_control_cur INTO enc_control_rec;
   		IF enc_control_cur%NOTFOUND THEN
     		CLOSE enc_control_cur;
     		EXIT;
   		END IF;

		OPEN enc_liq_cur(enc_control_rec.enc_control_id);
		LOOP
			FETCH enc_liq_cur INTO enc_liq_rec;
			IF enc_liq_cur%ROWCOUNT = 0 THEN
			  G_GMS_AVAILABLE := FALSE;
			  CLOSE enc_liq_cur;
			  EXIT;
    			ELSIF enc_liq_cur%NOTFOUND THEN
			  update psp_enc_controls
			     set gms_phase = 'Summarize' --- replaced NULL...for  2444657
			   where enc_control_id = enc_control_rec.enc_control_id;

			   G_GMS_AVAILABLE := TRUE;

       			  CLOSE enc_liq_cur;
       			  EXIT;
     			END IF;


	            ----IF enc_liq_rec.dr_cr_flag = 'D' THEN commented for 2530853
				enc_liq_rec.summary_amount := 0 - enc_liq_rec.summary_amount;
		    ----END IF;
                        --- flipping the flag for 2530853
                        if enc_liq_rec.dr_cr_flag = 'D' then
                          enc_liq_rec.dr_cr_flag := 'C';
                        else
                          enc_liq_rec.dr_cr_flag := 'D';
                        end if;

    				insert_into_enc_sum_lines(
							l_enc_summary_line_id,
							g_bg_id,
							enc_control_rec.enc_control_id,
							enc_control_rec.time_period_id,
							enc_liq_rec.person_id,
							enc_liq_rec.assignment_id, -- Included for Enh. 2143723
                					enc_liq_rec.effective_date,
							g_sob_id,
							NULL,
 							enc_liq_rec.project_id,
 							enc_liq_rec.expenditure_organization_id,
 							enc_liq_rec.expenditure_type,
							enc_liq_rec.task_id,
 							enc_liq_rec.award_id,
 							enc_liq_rec.summary_amount,
 							enc_liq_rec.dr_cr_flag,
							'N',
							enc_control_rec.payroll_id,
 							NULL,
							enc_liq_rec.gl_project_flag,
                                                        NULL,
                                                        enc_liq_rec.enc_summary_line_id,
                                                        NULL,
                                                        NULL,
							enc_liq_rec.attribute_category,	-- Introduced DFF columns for bug fix 2908859
							enc_liq_rec.attribute1,
							enc_liq_rec.attribute2,
							enc_liq_rec.attribute3,
							enc_liq_rec.attribute4,
							enc_liq_rec.attribute5,
							enc_liq_rec.attribute6,
							enc_liq_rec.attribute7,
							enc_liq_rec.attribute8,
							enc_liq_rec.attribute9,
							enc_liq_rec.attribute10,
							enc_liq_rec.expenditure_item_id,	-- Introduced for bug 4068182
							p_return_status);
				IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
				END IF;

                             / * Flag  the original line as Superceded* /
                              update psp_enc_summary_lines set status_code='S'
                              where enc_summary_line_id=enc_liq_rec.enc_summary_line_id;
     		END LOOP;

	END LOOP;

	p_return_status	:= fnd_api.g_ret_sts_success;
EXCEPTION
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     		g_error_api_path := 'CREATE_GMS_ENC_LIQ_LINES:'||g_error_api_path;
     		p_return_status := fnd_api.g_ret_sts_unexp_error;
	WHEN OTHERS THEN
     		g_error_api_path := 'CREATE_GMS_ENC_LIQ_LINES:'||g_error_api_path;
     		fnd_msg_pub.add_exc_msg('PSP_ENC_LIQ_TRAN','CREATE_GMS_ENC_LIQ_LINES');
     		p_return_status := fnd_api.g_ret_sts_unexp_error;
END create_gms_enc_liq_lines;
	End of comment for bug fix 4625734	*****/

--	##########################################################################
--	This procedure transfers liquidated lines from psp_enc_summary_lines
--		with gl_project_flag = 'P' to pa_transaction_interface

--      This procedure transfers lines from PSP_ENC_SUMMARY_LINES into PA_TRANSACTION_INTERFACE,
--      kicks off the TRANSACTION IMPORT program in GMS and sends ENC_CONTROL_ID, END_DATE for
--      the relevant TIME_PERIOD_ID and GMS_BATCH_NAME into the tie back procedure
--	##########################################################################

PROCEDURE tr_to_gms_int(p_payroll_action_id    IN NUMBER,
--			p_action_type	IN  VARCHAR2, -- Added for Restart Update Enh.
			p_return_status	OUT NOCOPY  VARCHAR2
			) IS

/*****	Commented for Create and Update multi thread enh.
	CURSOR 	enc_control_cur IS
   	SELECT 	DISTINCT pec.enc_control_id,
          	pec.payroll_id,
          	pec.time_period_id,
                pec.gms_phase,   ---- added for 2444657
		ptp.end_date
		per_time_periods ptp
   	WHERE 	pec.payroll_id = nvl(p_payroll_id, pec.payroll_id)
   	AND	(pec.total_dr_amount IS NOT NULL OR pec.total_cr_amount IS NOT NULL)
   	AND	pec.action_type in ('N', 'Q', 'U') -- Included 'Q' for Enh. 2143723
   	AND    	pec.action_code IN ('IT', 'IL','IU') -- Replaced I with IL and IU for Bug#2142865
   	AND    	pec.run_id = g_run_id
   	AND	pec.business_group_id = g_bg_id
	AND	pec.set_of_books_id = g_sob_id
        AND     pec.gms_phase in ('Summarize','Transfer')
	AND	ptp.time_period_id = pec.time_period_id;
	End of Comment for Create and Update multi thread enh.	*****/

--	CURSOR	int_cur(p_enc_control_id IN NUMBER) IS
	CURSOR	int_cur IS
	SELECT	pa_txn_interface_s.NEXTVAL,
		pesl.enc_summary_line_id,
		pesl.effective_date,
		pesl.time_period_id,
		pesl.person_id,
		pesl.project_id,
		pesl.task_id,
		pesl.award_id,
		pesl.expenditure_type,
		pesl.expenditure_organization_id,
		DECODE(pec.uom, 'M', g_currency_code, 'STAT') currency_code,
		TO_NUMBER(DECODE(pec.uom, 'H', pesl.summary_amount, 1)) quantity,
		TO_NUMBER(DECODE(pec.uom, 'M', pesl.summary_amount, 0)) summary_amount,
		pesl.dr_cr_flag,
		pesl.attribute2,
		pesl.attribute3,
		pesl.attribute6,
		pesl.attribute7,
		pesl.attribute8,
		pesl.attribute9,
		pesl.attribute10,
		pesl.superceded_line_id,	                -- Introduced for bug fix 6062628
		hou.name exp_org_name,				-- Introduced the following columns for bug fix 4625734
		ppa.segment1 project_number,
		ppa.org_id operating_unit,
		pt.task_number,
		TO_CHAR(pesl.enc_control_id) || ':' || ptp.period_name expenditure_comment,
		ptp.period_name,
		ptp.end_date,
		pesl.effective_date,
		papf.employee_number,
		pesl.gms_batch_name			--6146805
	FROM	psp_enc_summary_lines pesl,
		hr_organization_units hou,			-- Introduced the following tables as part of bug fix 4625734
		pa_projects_all ppa,
		pa_tasks pt,
		per_time_periods ptp,
		per_all_people_f papf,
		psp_enc_controls pec
	WHERE 	pesl.payroll_action_id = p_payroll_action_id
	AND	pec.enc_control_id = pesl.enc_control_id
	AND	pesl.status_code = 'N'
	AND	pesl.gl_code_combination_id is NULL
	AND	superceded_line_id IS NOT NULL
	AND	pesl.award_id IS NOT NULL
	AND	pesl.expenditure_organization_id = hou.organization_id (+)
	AND	pesl.project_id = ppa.project_id (+)
	AND	pesl.task_id = pt.task_id (+)
	AND	pesl.time_period_id = ptp.time_period_id
	AND	papf.person_id = pesl.person_id
	AND	pesl.effective_date BETWEEN papf.effective_start_date AND papf.effective_end_date
	AND	pesl.gms_batch_name IS NOT NULL;     --6146805
--	AND	pesl.enc_control_id = p_enc_control_id;	Removed enc_control_id check as part of bug fix 4625734

--	enc_control_rec		enc_control_cur%ROWTYPE;
--	int_rec			int_cur%ROWTYPE;
--	l_enc_type_id		NUMBER(15);
	l_tr_source		VARCHAR2(30);
--	l_exp_comment		VARCHAR2(240);
--	l_emp_num		VARCHAR2(30);
--	l_org_name 		hr_all_organization_units_tl.name%TYPE; -- Bug 2447912: Modified declaration
--	l_seg1			VARCHAR2(25);
--	l_task_number		VARCHAR2(25);
	----l_gms_batch_name	VARCHAR2(10); replaced usage with global var for 3473294
	l_exp_end_dt		DATE;
--	l_period_name		VARCHAR2(35);
--	l_period_end_dt		DATE;
	l_return_status		VARCHAR2(50);	-- Increased width from 10 to 50 for bug fix 2643228/2671594
   	req_id				NUMBER(15);
   	call_status			BOOLEAN;
   	rphase				VARCHAR2(30);
   	rstatus				VARCHAR2(30);
   	dphase				VARCHAR2(30);
   	dstatus				VARCHAR2(30);
   	message				VARCHAR2(240);
   	p_errbuf				VARCHAR2(32767);
   	p_retcode			VARCHAR2(32767);
   	return_back			EXCEPTION;
   	l_rec_count			NUMBER := 0;
   	l_error				VARCHAR2(100);
   	l_product			VARCHAR2(3);
   	l_value				VARCHAR2(200);
   	l_table				VARCHAR2(100);
	l_rec_no        NUMBER := 0;
        l_effective_date   DATE;
        l_tie_back_failed varchar2(1) := NULL;    -- 2479579

    TYPE GMS_TIE_RECTYPE IS RECORD (
                                    R_CONTROL_ID    NUMBER,
                                    R_END_DATE      DATE,
                                    R_GMS_BATCH_NAME VARCHAR2(80));    --- added batch_name for 2444657

    GMS_TIE_REC     GMS_TIE_RECTYPE;

        TYPE GMS_TIE_TABTYPE IS TABLE OF GMS_TIE_REC%TYPE
                INDEX BY BINARY_INTEGER;

        GMS_TIE_TAB     GMS_TIE_TABTYPE;
	gms_rec		gms_transaction_interface_all%ROWTYPE;
	l_txn_source	varchar2(30);
	l_gms_transaction_source VARCHAR2(30);
	l_org_id	NUMBER(15);
	l_txn_interface_id	NUMBER;
	l_gms_install	BOOLEAN	DEFAULT	gms_install.enabled;		-- Introduced for bug fix 2908859

--	Introduced the following for R12 performance fixes (4507892)
TYPE t_number IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE t_number_15 IS TABLE OF NUMBER(15) INDEX BY BINARY_INTEGER;
TYPE t_char_300 IS TABLE OF VARCHAR2(300) INDEX BY BINARY_INTEGER;
TYPE t_date IS TABLE OF DATE INDEX BY BINARY_INTEGER;

TYPE r_enc_control_rec IS RECORD (enc_control_id	t_number_15);
r_enc_controls	r_enc_control_rec;

CURSOR	enc_control_id_cur IS
SELECT	DISTINCT enc_control_id
FROM	psp_enc_summary_lines
WHERE	gms_batch_name = g_gms_batch_name;
--	End of changes for bug fix 4507892

--	Introduced the following for bug fix 4625734
CURSOR	transaction_source_cur IS
SELECT	transaction_source
FROM	pa_transaction_sources
WHERE	transaction_source = 'GOLDE';

CURSOR	gms_batch_name_cur IS
SELECT	DISTINCT gms_batch_name
FROM	psp_enc_summary_lines pesl
WHERE	pesl.payroll_action_id = p_payroll_action_id
/*WHERE	enc_control_id IN	(SELECT 	pec.enc_control_id
   				FROM   	psp_enc_controls pec
   				WHERE 	pec.payroll_id = nvl(p_payroll_id, pec.payroll_id)
   				AND    	pec.run_id = g_run_id
   				AND	pec.business_group_id = g_bg_id
				AND	pec.set_of_books_id = g_sob_id
        			AND     pec.gms_phase = 'Transfer')*/
AND	status_code = 'N'
AND	gl_code_combination_id IS NULL;

TYPE r_gms_batch_rec IS RECORD (gms_batch_name	t_char_300);
r_gms_batch	r_gms_batch_rec;

TYPE t_person IS RECORD
	(person_id	t_number_15,
	employee_number	t_char_300);
r_person	t_person;

/*****	Commented for Create and Update multi thread enh.
TYPE t_enc_control IS RECORD
	(enc_control_id	t_number_15,
	payroll_id	t_number_15,
	time_period_id	t_number_15,
	gms_phase	t_char_300,
	end_date	t_date);
r_enc_control	t_enc_control;
	End of Comment for Create and Update multi thread enh.	*****/

TYPE t_interface IS RECORD
	(txn_interface_id		t_number_15,
	enc_summary_line_id		t_number_15,
	effective_date			t_date,
	time_period_id			t_number_15,
	person_id			t_number_15,
	project_id			t_number_15,
	task_id				t_number_15,
	award_id			t_number_15,
	expenditure_type		t_char_300,
	expenditure_organization_id	t_number_15,
	currency_code			t_char_300,
	quantity			t_number,
	summary_amount			t_number,
	dr_cr_flag			t_char_300,
	attribute2			t_char_300,
	attribute3			t_char_300,
	attribute6			t_char_300,
	attribute7			t_char_300,
	attribute8			t_char_300,
	attribute9			t_char_300,
	attribute10			t_char_300,
	superceded_line_id		t_number_15,	--Bug 6062628
	employee_number			t_char_300,
	exp_org_name			t_char_300,
	project_number			t_char_300,
	operating_unit			t_char_300,
	task_number			t_char_300,
	expenditure_comment		t_char_300,
	period_name			t_char_300,
	end_date			t_date,
	gms_overriding_date		t_date,
	exp_end_date			t_date,
	gms_batch_name                  t_number_15);

r_interface	t_interface;

l_expenditure_item_id	psp_enc_summary_lines.expenditure_item_id%TYPE;	--Bug 6062628

l_raise_error	BOOLEAN;
--	End of changes for bug fix 4625734


 -- R12 MOAC Uptake
TYPE org_id_type IS TABLE OF NUMBER(15) INDEX BY BINARY_INTEGER;
org_id_tab    org_id_type;

TYPE gms_batch_name_type IS TABLE OF VARCHAR2(10) INDEX BY BINARY_INTEGER;
gms_batch_name_tab gms_batch_name_type;

TYPE req_id_TYPE is TABLE OF 	NUMBER(15) INDEX BY BINARY_INTEGER;
req_id_tab req_id_TYPE;

TYPE call_status_TYPE IS TABLE OF BOOLEAN INDEX BY BINARY_INTEGER;
call_status_tab call_status_TYPE;

CURSOR  operating_unit_csr IS
SELECT  distinct org_id
FROM    psp_enc_summary_lines
WHERE	status_code = 'N'
AND	gl_code_combination_id IS NULL
AND	gms_batch_name IS NULL
AND	payroll_action_id = p_payroll_action_id;

BEGIN
	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Entering TR_TO_GMS_INT');

--   gms_tie_tab.delete;		Commented for bug fix 4625734

--   if (gms_install.site_enabled) then	-- Commented for bug fix 2908859
   if (l_gms_install) then		-- Introduced for bug fix 2908859
/*****	Converted the following code as part of bug fix 4625734
   BEGIN
     SELECT transaction_source
     INTO   l_gms_transaction_source
     FROM   pa_transaction_sources
     WHERE  transaction_source = 'GOLDE';
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       l_error := 'TRANSACTION SOURCE = GOLDE';
       l_product := 'GMS';
       fnd_message.set_name('PSP','PSP_TR_NOT_SET_UP');
       fnd_message.set_token('ERROR',l_error);
       fnd_message.set_token('PRODUCT',l_product);
       fnd_msg_pub.add;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END;
	End of comment for bug fix 4625734	*****/
	OPEN transaction_source_cur;
	FETCH transaction_source_cur INTO l_gms_transaction_source;
	CLOSE transaction_source_cur;

	IF (l_gms_transaction_source IS NULL) THEN
		fnd_message.set_name('PSP','PSP_TR_NOT_SET_UP');
		fnd_message.set_token('ERROR','TRANSACTION SOURCE = GOLDE');
		fnd_message.set_token('PRODUCT','GMS');
		fnd_msg_pub.add;
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
   end if;

/*****	Commented as part of bug fix 4625734
	enc_type(	l_enc_type_id,
			l_return_status);
	IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
	--dbms_output.put_line('enc type='||l_enc_type_id);
	End of comment for bg fix 4625734	*****/

	 -- R12 MOAC Uptake
	org_id_tab.delete;
	gms_batch_name_tab.delete;
	req_id_tab.delete;
	call_status_tab.delete;

	OPEN operating_unit_csr;
	FETCH operating_unit_csr BULK COLLECT INTO org_id_tab;
	CLOSE operating_unit_csr;


/*****	SELECT 	to_char(psp_gms_batch_name_s.nextval)
		INTO 	g_gms_batch_name --- replaced with global for 3473294
		FROM 	dual;   *****/

	FOR I in 1..org_id_tab.count
	LOOP
		SELECT to_char(psp_gms_batch_name_s.nextval)
		INTO gms_batch_name_tab(i)
		FROM dual;
		fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || 'gms_batch_name_tab(' || I || '): ' || gms_batch_name_tab(i));
	END LOOP;


/*****	Commented for Create and Update multi thread enh.
	OPEN enc_control_cur;
	FETCH enc_control_cur BULK COLLECT INTO r_enc_control.enc_control_id, r_enc_control.payroll_id,
				r_enc_control.time_period_id, r_enc_control.gms_phase, r_enc_control.end_date;
	CLOSE enc_control_cur;

	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	r_enc_control.enc_control_id.COUNT: ' || r_enc_control.enc_control_id.COUNT);
	End of Comment for Create and Update multi thread enh.	*****/

--	FORALL recno IN 1..r_enc_control.enc_control_id.COUNT
	FORALL I IN 1..org_id_tab.count
	UPDATE 	psp_enc_summary_lines
	SET 	gms_batch_name = gms_batch_name_tab(i)
	WHERE 	status_code = 'N'
	AND 	gl_code_combination_id is NULL
	AND	superceded_line_id IS NOT NULL
--	AND	enc_control_id = r_enc_control.enc_control_id(recno)
	AND	payroll_action_id = p_payroll_action_id
	AND     org_id = org_id_tab(i);
--	AND	r_enc_control.gms_phase(recno) = 'Summarize';

	OPEN int_cur;
	FETCH int_cur BULK COLLECT INTO r_interface.txn_interface_id,	r_interface.enc_summary_line_id,
			r_interface.effective_date,		r_interface.time_period_id,
			r_interface.person_id,			r_interface.project_id,
			r_interface.task_id,			r_interface.award_id,
			r_interface.expenditure_type,		r_interface.expenditure_organization_id,
			r_interface.currency_code,		r_interface.quantity,
			r_interface.summary_amount,		r_interface.dr_cr_flag,
			r_interface.attribute2,			r_interface.attribute3,
			r_interface.attribute6,			r_interface.attribute7,
			r_interface.attribute8,			r_interface.attribute9,
			r_interface.attribute10,		r_interface.superceded_line_id,
			r_interface.exp_org_name,		r_interface.project_number,
			r_interface.operating_unit,		r_interface.task_number,
			r_interface.expenditure_comment,	r_interface.period_name,
			r_interface.end_date,			r_interface.gms_overriding_date,
			r_interface.employee_number,		r_interface.gms_batch_name;
	CLOSE int_cur;

	FOR I IN 1..r_interface.txn_interface_id.count
	LOOP
		FOR J IN 1..org_id_tab.count
		LOOP
			IF org_id_tab(J) = r_interface.operating_unit(I) THEN
				r_interface.gms_batch_name(I) := gms_batch_name_tab(J);
				EXIT;
			END IF;
		END LOOP;
	END LOOP;

	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	r_interface.txn_interface_id.COUNT: ' || r_interface.txn_interface_id.COUNT);
	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Verifying interface records for errors');

	l_raise_error := FALSE;
	FOR recno IN 1..r_interface.txn_interface_id.COUNT
	LOOP
		IF r_interface.employee_number(recno) IS NULL THEN
			fnd_message.set_name('PSP','PSP_TR_VALUE_NOT_FOUND');
			fnd_message.set_token('VALUE', 'person_id: ' || r_interface.person_id(recno));
			fnd_message.set_token('TABLE', 'PER_PEOPLE_F');
			fnd_msg_pub.add;
			l_raise_error := TRUE;
		END IF;

		IF r_interface.exp_org_name(recno) IS NULL THEN
			fnd_message.set_name('PSP','PSP_TR_VALUE_NOT_FOUND');
			fnd_message.set_token('VALUE', 'org_id: ' || r_interface.expenditure_organization_id(recno));
			fnd_message.set_token('TABLE', 'HR_ORGANIZATION_UNITS');
			fnd_msg_pub.add;
			l_raise_error := TRUE;
		END IF;

		IF r_interface.operating_unit(recno) IS NULL THEN
			fnd_message.set_name('PSP','PSP_ORG_VALUE_NOT_FOUND');
			fnd_message.set_token('VALUE', 'operating_unit: ' || r_interface.operating_unit(recno));
			fnd_message.set_token('TABLE', 'PA_PROJECTS_ALL');
			fnd_msg_pub.add;
			l_raise_error := TRUE;
		END IF;

		IF r_interface.project_number(recno) IS NULL THEN
			fnd_message.set_name('PSP','PSP_TR_VALUE_NOT_FOUND');
			fnd_message.set_token('VALUE', 'project_id: ' || r_interface.project_id(recno));
			fnd_message.set_token('TABLE', 'PA_PROJECTS_ALL');
			fnd_msg_pub.add;
			l_raise_error := TRUE;
		END IF;

		IF r_interface.task_number(recno) IS NULL THEN
			fnd_message.set_name('PSP','PSP_TR_VALUE_NOT_FOUND');
			fnd_message.set_token('VALUE', 'task_id: ' || r_interface.task_id(recno));
			fnd_message.set_token('TABLE', 'PA_TASKS');
			fnd_msg_pub.add;
			l_raise_error := TRUE;
		END IF;
	END LOOP;

	IF l_raise_error THEN
		fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Interface records have errors');
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Completed interface records for errors');
	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Computing PA week ending date(s)');

	FOR recno IN 1..r_interface.txn_interface_id.COUNT
	LOOP
		psp_general.get_gms_effective_date(r_interface.person_id(recno), r_interface.gms_overriding_date(recno));
		-- set the context to single to call pa_utils function
		mo_global.set_policy_context('S', r_interface.operating_unit(recno) );
		r_interface.exp_end_date(recno) := pa_utils.getweekending(r_interface.gms_overriding_date(recno));
	END LOOP;
	-- set the context again to multiple
	mo_global.set_policy_context('M', null);

	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Completed computation of PA week ending date(s)');

	FORALL recno IN 1..r_interface.txn_interface_id.COUNT
	UPDATE	psp_enc_summary_lines pesl
	SET	gms_posting_override_date = r_interface.gms_overriding_date(recno)
	WHERE	pesl.enc_summary_line_id = r_interface.enc_summary_line_id(recno)
	AND	TRUNC(r_interface.effective_date(recno)) <> TRUNC(r_interface.gms_overriding_date(recno));

	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Updated GMS Override Date');

	FORALL recno IN 1..r_interface.txn_interface_id.COUNT
	INSERT INTO pa_transaction_interface_all
		(txn_interface_id,				transaction_source,
		batch_name,					expenditure_ending_date,
		employee_number,				organization_name,
		expenditure_item_date,				project_number,
		task_number,					expenditure_type,
		quantity,					raw_cost,
		expenditure_comment,				transaction_status_code,
		orig_transaction_reference,			org_id,
		denom_currency_code,				denom_raw_cost,
		attribute1,					attribute2,
		attribute3,					attribute6,
		attribute7,					attribute8,
		attribute9,					attribute10,
		person_business_group_id)
	VALUES	(r_interface.txn_interface_id(recno),		l_gms_transaction_source,
		r_interface.gms_batch_name(recno),		r_interface.exp_end_date(recno),
		r_interface.employee_number(recno),		r_interface.exp_org_name(recno),
		r_interface.gms_overriding_date(recno),		r_interface.project_number(recno),
		r_interface.task_number(recno),			r_interface.expenditure_type(recno),
		1,						r_interface.summary_amount(recno),
		r_interface.expenditure_comment(recno),		'P',
		'E:' || r_interface.enc_summary_line_id(recno),	r_interface.operating_unit(recno),
		g_currency_code,				r_interface.summary_amount(recno),
		NULL,						NULL,
		r_interface.attribute3(recno),			r_interface.attribute6(recno),
		r_interface.attribute7(recno),			r_interface.attribute8(recno),
		r_interface.attribute9(recno),			r_interface.attribute10(recno),
		g_bg_id);

	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Inserted into pa_transaction_interface_all');

	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	r_interface.txn_interface_id.COUNT: ' || r_interface.txn_interface_id.COUNT);

	FOR recno IN 1..r_interface.txn_interface_id.COUNT
	LOOP

		SELECT   expenditure_item_id
	  	INTO     l_expenditure_item_id
		FROM     psp_enc_summary_lines
		WHERE    enc_summary_line_id = r_interface.superceded_line_id(recno);   --Bug 6062628


		GMS_REC.TXN_INTERFACE_ID		:= r_interface.txn_interface_id(recno);
		GMS_REC.BATCH_NAME			:= r_interface.gms_batch_name(recno);
		GMS_REC.TRANSACTION_SOURCE		:= l_gms_transaction_source;
		GMS_REC.EXPENDITURE_ENDING_DATE		:= r_interface.exp_end_date(recno);
		GMS_REC.EXPENDITURE_ITEM_DATE		:= r_interface.effective_date(recno);
		GMS_REC.PROJECT_NUMBER			:= r_interface.project_number(recno);
		GMS_REC.TASK_NUMBER			:= r_interface.task_number(recno);
		GMS_REC.AWARD_ID			:= r_interface.award_id(recno);
		GMS_REC.EXPENDITURE_TYPE		:= r_interface.expenditure_type(recno);
		GMS_REC.TRANSACTION_STATUS_CODE		:= 'P';
		GMS_REC.ORIG_TRANSACTION_REFERENCE	:= 'E:'|| r_interface.enc_summary_line_id(recno);
		GMS_REC.ORG_ID				:= r_interface.operating_unit(recno);
		GMS_REC.SYSTEM_LINKAGE			:= NULL;
		GMS_REC.USER_TRANSACTION_SOURCE		:= NULL;
		GMS_REC.TRANSACTION_TYPE		:= NULL;
		GMS_REC.BURDENABLE_RAW_COST		:= r_interface.summary_amount(recno);
		GMS_REC.FUNDING_PATTERN_ID		:= NULL;
		GMS_REC.ORIGINAL_ENCUMBRANCE_ITEM_ID	:= l_expenditure_item_id;      --Bug 6062628

		gms_transactions_pub.LOAD_GMS_XFACE_API(gms_rec, l_return_status);

		IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
			fnd_message.set_name('PSP','PSP_GMS_XFACE_FAILED');
			fnd_msg_pub.add;
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;
	END LOOP;
	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Inserted into gms_transaction_interface_all');

/*****	Commented the following for bug fix 4625734
  	LOOP
   		FETCH enc_control_cur INTO enc_control_rec;
   		IF enc_control_cur%NOTFOUND THEN
     		CLOSE enc_control_cur;
     		EXIT;
   		END IF;
/ *
		l_rec_no := l_rec_no + 1;
		gms_tie_tab(l_rec_no).r_control_id := enc_control_rec.enc_control_id;
* /
                -- moved this code from below update enc summary lines.. for 2444657
		SELECT 	period_name, end_date
		INTO	l_period_name, l_period_end_dt
		FROM	per_time_periods
		WHERE 	time_period_id = enc_control_rec.time_period_id;

             if enc_control_rec.gms_phase = 'Summarize' then --- 2444657
		UPDATE 	psp_enc_summary_lines
		SET 	gms_batch_name = g_gms_batch_name --- replaced with global for 3473294
		WHERE 	status_code = 'N'
		AND 	gl_code_combination_id is NULL
		AND	enc_control_id = enc_control_rec.enc_control_id;
		--dbms_output.put_line('batch='||g_gms_batch_name --- replaced with global for 3473294);
             --    insert into psp_stout values(97,'after updating summary batch name');

--	Changed_l_period_name to enc_control_rec.period_name as part of bug fix 4625734
		l_exp_comment	:=	enc_control_rec.enc_control_id||':'|| enc_control_rec.period_name;

                ---l_rec_count:=0;    commented for 2444657
		OPEN int_cur(enc_control_rec.enc_control_id);
		--l_rec_count :=	0;
		LOOP
			FETCH int_cur into int_rec;
			IF int_cur%NOTFOUND THEN
			CLOSE int_cur;
			EXIT;
			END IF;
--			l_rec_count :=	l_rec_count + 1;
	--insert_into_psp_stout( 'fetched int cur in tr to gms int');
			BEGIN
				SELECT	employee_number
				INTO	l_emp_num
				FROM	per_people_f
				WHERE	person_id = int_rec.person_id
				AND	int_rec.effective_date between effective_start_date and effective_end_date;
			EXCEPTION
				WHEN NO_DATA_FOUND THEN
				l_value		:=	'Person id ='||to_char(int_rec.person_id);
				l_table 	:=	'PER_PEOPLE_F';
				fnd_message.set_name('PSP','PSP_TR_VALUE_NOT_FOUND');
				fnd_message.set_token('VALUE',l_value);
				fnd_message.set_token('TABLE',l_table);
				fnd_msg_pub.add;
				RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
			END;
			--dbms_output.put_line('emp num='||l_emp_num);

			BEGIN
				SELECT	name    --Removed substr,bug 2447912.
				INTO 	l_org_name
				FROM	hr_all_organization_units
				WHERE	organization_id = int_rec.expenditure_organization_id;
			EXCEPTION
				WHEN NO_DATA_FOUND THEN
					l_value		:=	'Org id ='||to_char(int_rec.expenditure_organization_id);
					l_table 	:=	'HR_ORGANIZATION_UNITS';
					fnd_message.set_name('PSP','PSP_TR_VALUE_NOT_FOUND');
					fnd_message.set_token('VALUE',l_value);
					fnd_message.set_token('TABLE',l_table);
					fnd_msg_pub.add;
					RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
			END;
			--dbms_output.put_line('org name='||l_org_name);

			BEGIN
				SELECT 	org_id
				INTO	l_org_id
				FROM 	pa_projects_all
				WHERE	project_id = int_rec.project_id;
			EXCEPTION
				WHEN NO_DATA_FOUND THEN
					l_value		:=	'Project id ='||to_char(int_rec.project_id);
					l_table 	:=	'PA_PROJECTS_ALL';
					fnd_message.set_name('PSP','PSP_ORG_VALUE_NOT_FOUND');
					fnd_message.set_token('VALUE',l_value);
					fnd_message.set_token('TABLE',l_table);
					fnd_msg_pub.add;
					RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
			END;

			BEGIN
				SELECT 	segment1
				INTO	l_seg1
				FROM 	pa_projects_all
				WHERE	project_id = int_rec.project_id;
			EXCEPTION
				WHEN NO_DATA_FOUND THEN
					l_value		:=	'Project id ='||to_char(int_rec.project_id);
					l_table 	:=	'PA_PROJECTS_ALL';
					fnd_message.set_name('PSP','PSP_TR_VALUE_NOT_FOUND');
					fnd_message.set_token('VALUE',l_value);
					fnd_message.set_token('TABLE',l_table);
					fnd_msg_pub.add;
					RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
			END;
			--dbms_output.put_line('seg1='||l_seg1);

			BEGIN
				SELECT	task_number
				INTO	l_task_number
				FROM	pa_tasks
				WHERE	task_id = int_rec.task_id;
			EXCEPTION
				WHEN NO_DATA_FOUND THEN
					l_value		:=	'Task id ='||to_char(int_rec.task_id);
					l_table 	:=	'PA_TASKS';
					fnd_message.set_name('PSP','PSP_TR_VALUE_NOT_FOUND');
					fnd_message.set_token('VALUE',l_value);
					fnd_message.set_token('TABLE',l_table);
					fnd_msg_pub.add;
					RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
			END;
			--dbms_output.put_line('task='||l_task_number);
			l_rec_count :=	l_rec_count + 1;

/ *   Liquidation Fix
			l_exp_end_dt := pa_utils.getweekending(int_rec.effective_date);

*********************************************************************************************** /
   l_effective_date:=int_rec.effective_date;
   psp_general.get_gms_effective_date(int_rec.person_id ,l_effective_date);

  / *
     Call to get Effective Date of posting :- Will be the most recent date on which the
     employee's primary assignment was active prior to effective date of GMS posting
   * /

-- Replaced != by <> ib the foll. condn. for GSCC warning.
   if trunc(l_effective_date) <> trunc(int_rec.effective_date)
      then
          update psp_Enc_summary_lines set gms_posting_override_date=l_effective_date
          where enc_summary_line_id=int_rec.enc_summary_line_id;
   end if;

          l_exp_end_dt := pa_utils.getweekending(l_effective_date);


/ *****************************************************************************************************

 SUNY-RF Suspension/Termination of Primary Assignment Fix

 End Modified code
****************************************************************************************************** /

--  Get the transaction_interface_id. We need this to populate the gms_interface table.

     select pa_txn_interface_s.nextval
       into l_txn_interface_id
       from dual;
------Bug 2039196: Swapped the order of PA/GMS population
 --      dbms_output.put_line('Inserting into pa interface.............');

--	if int_rec.award_id is not null then	Commented for bug fix 2908859
	IF (l_gms_install) THEN			-- Introduced for bug fix 2908859
	  l_txn_source := l_gms_transaction_source;

			insert_into_pa_int(
						l_txn_interface_id,
						l_txn_source,
						g_gms_batch_name, --- replaced with global for 3473294
						l_exp_end_dt,
						l_emp_num,
						l_org_name,
						--int_rec.effective_date,
                                                l_effective_date,
						l_seg1,
						l_task_number,
						int_rec.expenditure_type,
						1,
						int_rec.summary_amount,
						l_exp_comment,
						'P',
						'E:' || int_rec.enc_summary_line_id,
						l_org_id,
						G_CURRENCY_CODE,
						int_rec.summary_amount,
-----Award attr put into gms_txn		int_rec.award_id,
-----Award attr put into gms_txn		l_enc_type_id,
						null,
						null,
						int_rec.attribute3,
						int_rec.attribute6,
						int_rec.attribute7,
						int_rec.attribute8,
						int_rec.attribute9,
						int_rec.attribute10,
						g_bg_id, -- Introduced for  Bug 2935850
						l_return_status);

			IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
			END IF;
	end if; --- If award id is not null

-- insert into gms_interface table if there are awards..

--	if int_rec.award_id is not null then	Commented for bug fix 2908859
	IF (l_gms_install) THEN			-- Introduced for bug fix 2908859

    GMS_REC.TXN_INTERFACE_ID 	    :=  l_txn_interface_id;
	GMS_REC.BATCH_NAME 	            := g_gms_batch_name; --- replaced with global for 3473294
	GMS_REC.TRANSACTION_SOURCE 	    := l_gms_transaction_source;
	GMS_REC.EXPENDITURE_ENDING_DATE     := l_exp_end_dt;
	GMS_REC.EXPENDITURE_ITEM_DATE 	    := l_effective_date;
	GMS_REC.PROJECT_NUMBER 	  	    := l_seg1;
	GMS_REC.TASK_NUMBER 	  	    := l_task_number;
	GMS_REC.AWARD_ID 	    	    := int_rec.award_id;
	GMS_REC.EXPENDITURE_TYPE 	    := int_rec.expenditure_type;
	GMS_REC.TRANSACTION_STATUS_CODE     := 'P';
	GMS_REC.ORIG_TRANSACTION_REFERENCE  := 'E:'|| int_rec.enc_summary_line_id;
	GMS_REC.ORG_ID 	  		    := l_org_id;
	GMS_REC.SYSTEM_LINKAGE		    := NULL;
	GMS_REC.USER_TRANSACTION_SOURCE     := NULL;
	GMS_REC.TRANSACTION_TYPE 	    := NULL;
	GMS_REC.BURDENABLE_RAW_COST 	    := int_rec.summary_amount;
	GMS_REC.FUNDING_PATTERN_ID 	    := NULL;
	GMS_REC.ORIGINAL_ENCUMBRANCE_ITEM_ID:= int_rec.expenditure_item_id;	-- Introduced for bug fix 4033329

	gms_transactions_pub.LOAD_GMS_XFACE_API(gms_rec, l_return_status);

       IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       	  fnd_message.set_name('PSP','PSP_GMS_XFACE_FAILED');
       	  fnd_msg_pub.add;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

       end if;

		END LOOP;	-- int_cur loop
       end if;  --- phase = summarize ...2444657
                   ---if l_rec_count > 0 then
               if enc_control_rec.gms_phase = 'Summarize' then   --- changed from above if... for 2444657
		l_rec_no := l_rec_no + 1;
		gms_tie_tab(l_rec_no).r_control_id := enc_control_rec.enc_control_id;
		gms_tie_tab(l_rec_no).r_end_date := l_period_end_dt;
                gms_tie_tab(l_rec_no).r_gms_batch_name := g_gms_batch_name; --- replaced with global for 3473294 ---added for 2444657
              else  ---- phase = 'Transfer'  ---added this part for 2444657
                l_rec_no := l_rec_no + 1;
                gms_tie_tab(l_rec_no).r_control_id := enc_control_rec.enc_control_id;
		gms_tie_tab(l_rec_no).r_end_date := l_period_end_dt;
                select gms_batch_name
                into gms_tie_tab(l_rec_no).r_gms_batch_name
                from psp_enc_summary_lines
                where enc_control_id =  enc_control_rec.enc_control_id
                  and status_code = 'N'
                  and gl_code_combination_id is null
                  and rownum = 1;
               end if;

	END LOOP;	-- enc_cur loop

	End of comment for bug fix 4625734	*****/
	IF r_interface.txn_interface_id.COUNT > 0 THEN	-- Introduced for bug fix 4625734
--	IF l_rec_count > 0 THEN    -- uncommented this line and commented the line below for 2444657 Commented for bug fix 4625734
           ---      if l_rec_no >0 then

		FOR request_counter IN 1..org_id_tab.count
		LOOP
			-- set the context to single to call submit_request
			mo_global.set_policy_context('S', org_id_tab(request_counter) );
			fnd_request.set_org_id (org_id_tab(request_counter) );

			req_id_tab(request_counter)  := fnd_request.submit_request(
                                 				'PA',
                                 				'PAXTRTRX',
                                			 	NULL,
                                 				NULL,
                                 				FALSE,
                                 				l_gms_transaction_source,
                                 				gms_batch_name_tab(request_counter)); --- replaced with global for 3473294


     		--dbms_output.put_line('Req id = '||to_char(req_id));

     			IF req_id_tab(request_counter) = 0 THEN
				fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Submission of Transaction Import Failed');
       				fnd_message.set_name('PSP','PSP_TR_GMS_IMP_FAILED');
	       			fnd_msg_pub.add;
       				RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     			ELSE
				fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Submitted Transaction Import');

				/*****	Modified teh following update to BULK UPDATE for R12 performance fixes (bug 4507892)
				update psp_enc_controls
				   set gms_phase = 'Transfer'
				 where enc_control_id in (select distinct enc_control_id
							    from psp_enc_summary_lines
							   where gms_batch_name = g_gms_batch_name); --- replaced with global for 3473294
				End of comment for bug fix 4507892	*****/
				--	Introduced the following for bug fix 4507892
				OPEN enc_control_id_cur;
				FETCH enc_control_id_cur BULK COLLECT INTO r_enc_controls.enc_control_id;
				CLOSE enc_control_id_cur;

				FORALL I IN 1..r_enc_controls.enc_control_id.COUNT
				UPDATE	psp_enc_controls
				SET	gms_phase = 'Transfer'
				WHERE	enc_control_id = r_enc_controls.enc_control_id(I);

				fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Updated gms_phase to ''Transfer'' in psp_enc_controls SQL%ROWCOUNT: ' || SQL%ROWCOUNT);

				r_enc_controls.enc_control_id.DELETE;
			--	End of changes for bug fix 4507892
			END IF;
		END LOOP;
		COMMIT;
		-- set the context again to multiple
		mo_global.set_policy_context('M', null);

		fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Calling gather_table_stats for psp_enc_summary_lines');
		fnd_stats.gather_table_stats('PSP', 'PSP_ENC_SUMMARY_LINES');
		fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Completed gather_table_stats for psp_enc_summary_lines');

		FOR I IN 1..org_id_tab.count
		LOOP
                --    insert into psp_Stout values(96, 'gms transfer started');
			fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Waiting for comlpetion of Transaction Import');
       			call_status := fnd_concurrent.wait_for_request(req_id_tab(I), 10, 0,
                			rphase, rstatus, dphase, dstatus, message);

       			IF call_status = FALSE then
				fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Transaction Import failed');
	               		fnd_message.set_name('PSP','PSP_TR_GMS_IMP_FAILED');
		 		fnd_msg_pub.add;
         			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       			END IF;
			fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Transaction Import completed');
     		END LOOP;
    	END IF; --record_count > 0   ...move this line from below delete xface...for 2444657


    -- mark the successfully transferred records as 'A' in psp_summary_lines and psp_enc_lines
    -- and transfer the successful records to the history table

/*****	Commented the following to make tie back runn for gms batch instead of each enc control id as a batch comprise of
	more than one enc control id in which case when the Transaction import isnt kicked off or if its cancelled, the
	process sets the enc controls of the same batch to different statuses. This results in the restart process to
	error out.
		for i in 1..gms_tie_tab.count
		loop
              --  insert into psp_stout values(18,'inside tie back loop');
     		gms_enc_tie_back(gms_tie_tab(i).r_control_id,
                             gms_tie_tab(i).r_end_date,
                             gms_tie_tab(i).r_gms_batch_name,
                             g_bg_id,
                             g_sob_id,
                             'N',               ---Bug 2039196: introduced this param
                             p_action_type, -- Added for Restart Update Enh.
                             l_return_status);
                -- moved this check into the loop for 2479579
     		IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                        l_tie_back_failed := 'Y';   --- introduced for 2479579
     		END IF;
     		end loop;
	End of comment for bug fix 4625734	*****/

--	Introduced the following for bug fix 4625734
		OPEN gms_batch_name_cur;
		FETCH gms_batch_name_cur BULK COLLECT INTO r_gms_batch.gms_batch_name;
		CLOSE gms_batch_name_cur;

		fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	r_gms_batch.gms_batch_name.COUNT: ' || r_gms_batch.gms_batch_name.COUNT);

		FOR recno IN 1..r_gms_batch.gms_batch_name.COUNT
		LOOP
			fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Calling gms_enc_tie_back for gms_batch_name: ' || r_gms_batch.gms_batch_name(recno));
			gms_enc_tie_back(NULL,		-- Tieback is by batch and not by enc_control_id
					NULL,		-- Period end date isnt required as liq doesnt have suspense posting
					r_gms_batch.gms_batch_name(recno),
					g_bg_id,
					g_sob_id,
					'N',
					NULL, --p_action_type,
					l_return_status);

			IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
				fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	gms_enc_tie_back failed for gms_batch_name: ' || r_gms_batch.gms_batch_name(recno));
				RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
			END IF;
			fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	gms_enc_tie_back successful for gms_batch_name: ' || r_gms_batch.gms_batch_name(recno));
		END LOOP;
--	End of changes for bug fix 4625734

/****	Commented the following LOOP to convert it into a proper gms batch loop for bug fix 4625734
 for i in 1..gms_tie_tab.count
    loop
      if  gms_tie_tab(i).r_gms_batch_name is not null then   --- this logic is to ensure that (2444657)
                                                             --- given gms_batch is processed only once
    -- added update stmnt and two del stmnts for 2445196
	End of comment for bug fix 4625734	*****/

--	Introduced the folowing for bug fix 4625734
	FORALL recno IN 1..r_gms_batch.gms_batch_name.COUNT
	UPDATE	psp_enc_summary_lines pesl
	SET	(pesl.expenditure_id, pesl.expenditure_item_id, pesl.expenditure_ending_date,
		pesl.txn_interface_id, pesl.interface_id) =
			(SELECT	ptxn.expenditure_id, ptxn.expenditure_item_id, ptxn.expenditure_ending_date,
				ptxn.txn_interface_id, ptxn.interface_id
			FROM	pa_transaction_interface_all ptxn
			WHERE	ptxn.transaction_source = 'GOLDE'
			AND	ptxn.batch_name = r_gms_batch.gms_batch_name(recno)
			AND	ptxn.orig_transaction_reference = 'E:' || TO_CHAR(pesl.enc_summary_line_id))
	WHERE	pesl.gms_batch_name = r_gms_batch.gms_batch_name(recno);

	FORALL recno IN 1..r_gms_batch.gms_batch_name.COUNT
	DELETE	pa_transaction_interface_all
	WHERE	batch_name = r_gms_batch.gms_batch_name(recno)
	AND	transaction_source = 'GOLDE';

	FORALL recno IN 1..r_gms_batch.gms_batch_name.COUNT
	DELETE	gms_transaction_interface_all
	WHERE	batch_name = r_gms_batch.gms_batch_name(recno)
	AND	transaction_source = 'GOLDE';
--	End of changes for bug fix 4625734

/*****	Commented the following as there will be distinct gms batch names (as part of bug fix 4625734)
      for k in 1..gms_tie_tab.count
        loop
          if gms_tie_tab(i).r_gms_batch_name = gms_tie_tab(k).r_gms_batch_name and
             i <> k then
               gms_tie_tab(k).r_gms_batch_name := null;
          end if;
        end loop;
        gms_tie_tab(i).r_gms_batch_name := null;
    end if;
    end loop;
	End of Comment for bug fix 4625734	*****/

		COMMIT;  -- moved this commit below for 2479579

/*****	Commented for Enh. 2768298 Removal of suspense posting in Liquidation
    if g_invalid_suspense = 'Y' then   -- introduced this IF-ELSE for 2479579
	enc_batch_end(g_payroll_id,p_action_type,'N',g_bg_id,g_sob_id,l_return_status);
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    end if;
	End of somment for Enh. Removal of suspense posting in Liquidation	*****/


     p_return_status := fnd_api.g_ret_sts_success;
EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     g_error_api_path := 'TR_TO_GMS_INT:'||g_error_api_path;
     p_return_status := fnd_api.g_ret_sts_unexp_error;

   WHEN RETURN_BACK THEN
     p_return_status := fnd_api.g_ret_sts_success;

   WHEN OTHERS THEN
     g_error_api_path := 'TR_TO_GMS_INT:'||g_error_api_path;
     fnd_msg_pub.add_exc_msg('PSP_ENC_LIQ_TRAN','TR_TO_GMS_INT');
     p_return_status := fnd_api.g_ret_sts_unexp_error;

END tr_to_gms_int;

--	##########################################################################
--	This procedure ties back all the transactions posted into Oracle Grants Mgmt.
--		with Oracle Labor Distribution where the import is successful.
--	In case of failure the transactions in Oracle Labor Distribution are turned
--		back into their original state.
--	##########################################################################

PROCEDURE gms_enc_tie_back( p_enc_control_id	IN  NUMBER,
			    p_period_end_date     IN  DATE,
               	            p_gms_batch_name	    IN  VARCHAR2,
                            p_business_group_id IN  NUMBER,
                            p_set_of_books_id   IN  NUMBER,
                            p_mode              in  Varchar2, -- Bug 2039196: introduced param
                            p_action_type 	IN  VARCHAR2, -- Added for Restart Update Enh.
                            p_return_status	OUT NOCOPY VARCHAR2) IS

   CURSOR gms_tie_back_success_cur IS
   SELECT enc_control_id,
	enc_summary_line_id,
          dr_cr_flag,
	  TO_NUMBER(DECODE(dr_cr_flag, 'C', -summary_amount, summary_amount)) summary_amount
   FROM   psp_enc_summary_lines
   WHERE  gms_batch_name = p_gms_batch_name;
--   and    enc_control_id = p_enc_control_id;		Removed enc_control_id check as part of bug fix 4625734


   CURSOR gms_tie_back_reject_cur IS
   SELECT nvl(transaction_rejection_code,'P'),
          TO_NUMBER(SUBSTR(orig_transaction_reference, 3)),	-- Introuduced TO_NUMBER and SUBSTR for bug fix 4625734
	  transaction_status_code
   FROM   pa_transaction_interface_all
   WHERE  transaction_source = 'GOLDE'
     AND  batch_name = p_gms_batch_name;
/*****	Commented the following condition as Tie Back is by per gms batch and not by enc_control_id (for bug fix 4625734)
     AND  orig_transaction_reference IN   (SELECT 'E:' || enc_summary_line_id             -- Introduced for bug fix 3953230
                                                FROM    psp_enc_summary_lines pesl
                                                WHERE   pesl.enc_control_id = p_enc_control_id);
	End of comment for bug fix 4625734	*****/


/*****	Commented for Enh. 2768298 Removal of Suspense Posting in Liquidation
   CURSOR assign_susp_ac_cur(P_ENC_LINE_ID	IN	NUMBER) IS
   SELECT pel.rowid,
          pel.effective_date,
        --  pel.attribute30
           pel.suspense_org_account_id,
          pel.superceded_line_id
   FROM   psp_enc_summary_lines pel
   WHERE  pel.enc_summary_line_id = p_enc_line_id
 and pel.enc_control_id=p_enc_control_id
and pel.gl_project_flag='P' and
  pel.status_code='N';

-- Get the Organization details ...

   CURSOR get_susp_org_cur(P_ORG_ID	IN	VARCHAR2) IS
   SELECT hou.organization_id, hou.name
     FROM hr_all_organization_units hou, psp_organization_accounts poa
    WHERE hou.organization_id = poa.organization_id
      AND poa.business_group_id = p_business_group_id
      AND poa.set_of_books_id = p_set_of_books_id
      AND poa.organization_account_id = p_org_id;
	End of Comment for Enh. 2768298 Removal of suspense posting in Liquidation	*****/

/*****	Commented the following cursor as it isnt used in the procedure (for bug fix 4625734)
   CURSOR get_org_id_cur(P_LINE_ID	IN	NUMBER) IS
   SELECT hou.organization_id, hou.name
   FROM   hr_all_organization_units hou,
  	      per_assignments_f paf,
          psp_enc_summary_lines pel
   WHERE  pel.enc_summary_line_id = p_line_id
   AND pel.enc_control_id=p_enc_control_id
  -- AND    pel.assignment_id = paf.assignment_id
    and pel.person_id=paf.person_id
    and paf.primary_flag='Y'
   AND    pel.effective_date BETWEEN paf.effective_start_date AND paf.effective_end_date
   AND    paf.organization_id = hou.organization_id
   AND    pel.effective_date between
		  hou.date_from and nvl(hou.date_to,pel.effective_date);

  l_orig_org_name		hr_all_organization_units_tl.name%TYPE; -- Bug 2447912: Modified declaration
  l_orig_org_id			number;
  l_superceded_line_id          number;

-- End of Get org id cursor  Ravindra
	End of comment for bug fix 4625734	*****/

/*   CURSOR assign_susp_ac_cur IS
   SELECT hou.name,
          hou.organization_id,
          pel.rowid,
          pel.assignment_id,
          pel.effective_date,
          pel.attribute30
   FROM   hr_all_organization_units hou,
          per_assignments_f paf,
          psp_enc_summary_lines pel
   WHERE  pel.enc_control_id = p_enc_control_id
   AND	  pel.gl_project_flag = 'P'
   AND	  pel.status_code = 'A'
   AND    pel.assignment_id = paf.assignment_id(+)
   AND	  pel.business_group_id = p_business_group_id
   AND	  pel.set_of_books_id = p_set_of_books_id
   AND    pel.effective_date BETWEEN paf.effective_start_date AND paf.effective_end_date
   AND    paf.organization_id = hou.organization_id;
*/

/*****	Commented for Enh. 2768298 Removal of suspense posting in Liquidation
   CURSOR org_susp_ac_cur(P_ORGANIZATION_ID	IN	NUMBER,
                          P_ENCUMBRANCE_DATE	IN	DATE) IS
   SELECT poa.organization_account_id,
          poa.gl_code_combination_id,
          poa.project_id,
          poa.award_id,
          poa.task_id,
          poa.expenditure_type,
          poa.expenditure_organization_id
   FROM   psp_organization_accounts poa
   WHERE  poa.organization_id = p_organization_id
   AND    poa.account_type_code = 'S'
   AND	  poa.business_group_id = p_business_group_id
   AND	  poa.set_of_books_id = p_set_of_books_id
   AND    p_encumbrance_date BETWEEN poa.start_date_active AND
                                    nvl(poa.end_date_active,p_encumbrance_date);

 --CURSOR global_susp_ac_cur(P_ENCUMBRANCE_DATE	IN	DATE) IS
   CURSOR global_susp_ac_cur(P_ORGANIZATION_ACCOUNT_ID	IN	NUMBER) IS --BUG 2056877.
   SELECT poa.organization_account_id,
          poa.gl_code_combination_id,
          poa.project_id,
          poa.award_id,
          poa.task_id,
          poa.expenditure_type,
          poa.expenditure_organization_id
   FROM   psp_organization_accounts poa
   WHERE
   / *     poa.account_type_code = 'G'
   AND	  poa.business_group_id = p_business_group_id
   AND	  poa.set_of_books_id = p_set_of_books_id
   AND    p_encumbrance_date BETWEEN poa.start_date_active AND
                                      nvl(poa.end_date_active,p_encumbrance_date); Bug 2056877 * /
          organization_account_id = p_organization_account_id;   --Added for bug 2056877.
	End of comment for Enh. 2768298 Removal of suspense postingin liquidation	*****/

   l_organization_name		hr_all_organization_units_tl.name%TYPE; -- Bug 2447912: Modified declaration
   l_organization_id		NUMBER(15);
   l_rowid				ROWID;
   l_assignment_id		NUMBER(9);
   l_encumbrance_date		DATE;
--   l_suspense_org_account_id  NUMBER(9);	Commented for Enh. 2768298 Removal of suspense posting in Liquidation

   l_organization_account_id	NUMBER(9);
   l_gl_code_combination_id   NUMBER(15);
   l_project_id			NUMBER(15);
   l_award_id			NUMBER(15);
   l_task_id			NUMBER(15);
   l_expenditure_type           VARCHAR2(30);
   l_exp_org_id                 NUMBER(15);
   l_cnt_gms_interface		NUMBER;
   l_enc_summary_line_id		NUMBER(10);
   l_gl_project_flag		VARCHAR2(1);
/*****	Commented for Enh. 2768298 Removal of suspense posting in Liquidation
   l_suspense_ac_failed		VARCHAR2(1) := 'N';
   l_suspense_ac_not_found	VARCHAR2(1) := 'N';
   l_susp_ac_found		VARCHAR2(10) := 'TRUE';
	End of comment for Enh. 2768298 Removal of suspense posting in Liquidation
 *****/
/*****	Commented for bug fix 4625734
   l_summary_amount		NUMBER;
   l_dr_summary_amount		NUMBER := 0;
   l_cr_summary_amount		NUMBER := 0;
   l_dr_cr_flag			VARCHAR2(1);
   l_trx_reject_code		VARCHAR2(30);
   l_orig_trx_reference		VARCHAR2(30);
   l_effective_date		DATE;
	End of comment for bug fix 4625734	*****/

/*****	Commented for Enh. 2768298 Removal of suspense posting in Liquidation
   x_susp_failed_org_name	hr_all_organization_units_tl.name%TYPE; -- Bug 2447912: Modified declaration;
   x_susp_failed_reject_code	VARCHAR2(30);
   x_susp_failed_date		DATE;
   x_susp_nf_org_name		hr_all_organization_units_tl.name%TYPE; -- Bug 2447912: Modified declaration
   x_susp_nf_date			DATE;
	End of comment for Enh. 2768298 Removal of suspense posting in Liquidation	*****/

   l_return_status		VARCHAR2(10);
/*****	Commented for bug fix 4625734
   l_trx_status_code		VARCHAR2(2); -- Bug 2039196: increased size to 2.
   l_enc_ref			VARCHAR2(15);
   l_return_value               VARCHAR2(30);  --Added for bug 2056877.
   no_profile_exists            EXCEPTION;     --Added for bug 2056877.
   no_val_date_matches          EXCEPTION;     --Added for bug 2056877.
   no_global_acct_exists        EXCEPTION;     --Added for bug 2056877.
	End of comment for bug fix 4625734	*****/

--	Introduced the following for bug fix 4625734
CURSOR	txn_interface_count_cur IS
SELECT	COUNT(1)
FROM	pa_transaction_interface_all
WHERE	transaction_source = 'GOLDE'
AND	batch_name = p_gms_batch_name
AND	transaction_status_code in ('R', 'PI', 'PO', 'PR');

CURSOR	get_success_recs_cur IS
SELECT	enc_control_id,
	enc_summary_line_id,
	dr_cr_flag,
	TO_NUMBER(DECODE(dr_cr_flag, 'C', -summary_amount, summary_amount)) summary_amount
FROM	psp_enc_summary_lines
WHERE	gms_batch_name = p_gms_batch_name
AND	status_code = 'L';

TYPE t_number_15 IS TABLE OF NUMBER(15) INDEX BY BINARY_INTEGER;
TYPE t_number IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE t_char_100 IS TABLE OF VARCHAR2(100) INDEX BY BINARY_INTEGER;

TYPE r_tieback_rec IS RECORD
	(enc_summary_line_id	t_number_15,
	enc_control_id		t_number_15,
	reason_code		t_char_100,
	txn_status_code		t_char_100,
	dr_cr_flag		t_char_100,
	summary_amount		t_number);

r_reject_recs	r_tieback_rec;
r_success_recs	r_tieback_rec;
--	End of changes for bug fix 4625734

 FUNCTION PROCESS_COMPLETE RETURN BOOLEAN IS
    l_cnt       NUMBER;
    l_status    VARCHAR2(30);

--	Introduced the following for bug fix 4507892
TYPE t_number_15 IS TABLE OF NUMBER(15) INDEX BY BINARY_INTEGER;
TYPE r_superceded_line_rec IS RECORD (superceded_line_id	t_number_15);
r_superceded_lines	r_superceded_line_rec;

CURSOR	superceded_line_id_cur IS
SELECT	superceded_line_id
FROM	psp_enc_summary_lines
WHERE	gms_batch_name = p_gms_batch_name;
--	End of changes for bug fix 4507892

--	Introduced the following for bug fix 4625734
TYPE r_enc_control_rec IS RECORD
	(enc_control_id	t_number_15);
r_enc_controls	r_enc_control_rec;

CURSOR	enc_controls_cur IS
SELECT	DISTINCT enc_control_id
FROM	psp_enc_summary_lines
WHERE	gms_batch_name = p_gms_batch_name;

CURSOR	transaction_status_cur IS
SELECT	COUNT(*),
	transaction_status_code
FROM	pa_transaction_interface_all
WHERE	transaction_source='GOLDE'
AND	batch_name = p_gms_batch_name
AND	transaction_Status_code in ('P','I')
GROUP BY transaction_status_code;
--	End of changes for bug fix 4625734
 begin
	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Entering GMS_ENC_TIE_BACK.PROCESS_COMPLETE');
/*
   select count(*), transaction_status_code
     into l_cnt, l_status
     from pa_transaction_interface_all
    where transaction_source = 'GOLDE'
      and batch_name = (select distinct gms_batch_name
                          from psp_enc_summary_lines
                         where enc_control_id = p_enc_control_id
                           and gms_batch_name is not null)
      and transaction_status_code in ('P', 'I')
    group by transaction_status_code  ;
*/

/****	Converted the following code in CURSOR for bug fix 4625734
 select count(*), transaction_status_code into l_cnt,l_status from
 pa_transaction_interface_all where transaction_source='GOLDE' and
 batch_name=p_gms_batch_name and transaction_Status_code in ('P','I')
 group by transaction_status_code;
	End of comment for bug fix 4625734	*****/

	OPEN transaction_status_cur;
	FETCH transaction_status_cur INTO l_cnt, l_status;
		IF (transaction_status_cur%ROWCOUNT = 0) THEN
			l_cnt := 0;
		END IF;
	CLOSE transaction_status_cur;

	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	l_cnt: ' || l_cnt);

   if l_cnt = 0 then
	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Leaving GMS_ENC_TIE_BACK.PROCESS_COMPLETE');
     return TRUE;
   elsif l_cnt > 0 then
     if l_status = 'P' then

-- -------------------------------------------------------------------------------------------
-- If transaction_status_code = 'P' then the transaction import process did not kick off
-- for some reason. Return 'NOT_RUN' in this case. So cleanup the tables and try to transfer
-- again after summarization in the second pass.
-- -------------------------------------------------------------------------------------------
        delete from pa_transaction_interface_all
         where transaction_source = 'GOLDE'
           and batch_name = p_gms_batch_name;

	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Deleted from pa_trancsaction_interface_all');

        delete from gms_transaction_interface_all
         where transaction_source = 'GOLDE'
	   and batch_name = p_gms_batch_name;

	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Deleted from gms_trancsaction_interface_all');

/*****	Converted the following UPDATE to BULK for R12 performance fixes (bug 4507892)
update psp_enc_summary_lines set status_code ='A' where
enc_summary_line_id in (select superceded_line_id from
psp_enc_summary_lines where gms_batch_name=p_gms_batch_name);
	End of comment for bug fix 4507892	*****/
--	Introduced the following fo bug fix 4507892
	OPEN superceded_line_id_cur;
	FETCH superceded_line_id_cur BULK COLLECT INTO r_superceded_lines.superceded_line_id;
	CLOSE superceded_line_id_cur;

	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	r_superceded_lines.superceded_line_id.COUNT: ' || r_superceded_lines.superceded_line_id.COUNT);

	FORALL I IN 1..r_superceded_lines.superceded_line_id.COUNT
	UPDATE	psp_enc_summary_lines
	SET	status_code = 'A'
	WHERE	enc_summary_line_id = r_superceded_lines.superceded_line_id(I);

	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Updated original lines to status_code ''A'' in psp_enc_summary_lines');

	r_superceded_lines.superceded_line_id.DELETE;
--	End of changes for bug fix 4507892

--	Introduced the folowing for bug fix 4625734
	OPEN enc_controls_cur;
	FETCH enc_controls_cur BULK COLLECT INTO r_enc_controls.enc_control_id;
	CLOSE enc_controls_cur;
--	End of changes for bug fix 4625734

	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	r_enc_controls.enc_control_id.COUNT: ' || r_enc_controls.enc_control_id.COUNT);

        delete from psp_enc_summary_lines
         where gms_batch_name = p_gms_batch_name;
   --        and enc_control_id = p_enc_control_id;

	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Deleted from psp_enc_summary_lines');

--	Introduced the folowing for bug fix 4625734
	FORALL recno IN 1..r_enc_controls.enc_control_id.COUNT
	UPDATE	psp_enc_controls pec
	SET	gms_phase = 'TieBack'
	WHERE	enc_control_id = r_enc_controls.enc_control_id(recno);

	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Updated gms_phase to ''TieBack'' in psp_enc_controls');

	r_enc_controls.enc_control_id.DELETE;
	g_liq_has_failed_transactions := TRUE;
--	End of changes for bug fix 4625734

	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Leaving GMS_ENC_TIE_BACK.PROCESS_COMPLETE');
        return FALSE;

     elsif l_status = 'I' then

-- -------------------------------------------------------------------------------------------
-- If transaction_status_code = 'I' then the transaction import process did not complete
-- the Post Processing extension. So return 'NOT_COMPLETE' in this case. User needs to complete
-- this process by running the transaction import manually and re-start the LD process.
-- -------------------------------------------------------------------------------------------

	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Leaving GMS_ENC_TIE_BACK.PROCESS_COMPLETE');
        return FALSE;

     end if;
   end if;

 exception
 when others then
   return TRUE;
 end PROCESS_COMPLETE;

 BEGIN
	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Entering GMS_ENC_TIE_BACK');

   if (PROCESS_COMPLETE) then
/*****	Changed the following SELECT into CURSOR for bug fix 4625734
   SELECT count(*)
     INTO l_cnt_gms_interface
     FROM pa_transaction_interface_all
    WHERE transaction_source = 'GOLDE'
      AND batch_name = p_gms_batch_name
      AND transaction_status_code in ('R', 'PI', 'PO', 'PR');
	End of comment for bug fix 4625734	*****/

--	Introduced the following for bug fix 4625734
	OPEN txn_interface_count_cur;
	FETCH txn_interface_count_cur INTO l_cnt_gms_interface;
	CLOSE txn_interface_count_cur;
--	End of changes for bug fix 4625734
	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	l_cnt_gms_interface: ' || l_cnt_gms_interface);

   IF l_cnt_gms_interface > 0 THEN
--	Introduced the following for bug fix 4625734
	OPEN gms_tie_back_reject_cur;
	FETCH gms_tie_back_reject_cur BULK COLLECT INTO r_reject_recs.reason_code, r_reject_recs.enc_summary_line_id,
			r_reject_recs.txn_status_code;
	CLOSE gms_tie_back_reject_cur;

	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	r_reject_recs.enc_summary_line_id.COUNT: ' || r_reject_recs.enc_summary_line_id.COUNT);

	FOR recno IN 1..r_reject_recs.enc_summary_line_id.COUNT
	LOOP
		fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	r_reject_recs.reason_code(' || recno || '): ' || r_reject_recs.reason_code(recno));
		IF (r_reject_recs.txn_status_code(recno) IN ('R', 'PI', 'PO', 'PR')) THEN
			fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	g_liq_has_failed_transactions: TRUE');
			g_liq_has_failed_transactions := TRUE;
			EXIT;
		END IF;
	END LOOP;

	FORALL recno IN 1..r_reject_recs.enc_summary_line_id.COUNT
	UPDATE	psp_enc_summary_lines
	SET	interface_status = r_reject_recs.reason_code(recno)
	WHERE	enc_summary_line_id = r_reject_recs.enc_summary_line_id(recno)
	AND	r_reject_recs.txn_status_code(recno) IN ('R', 'PI', 'PO', 'PR');

	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Updated interface_status with reject reason code in psp_enc_summary_lines');

	FORALL recno IN 1..r_reject_recs.enc_summary_line_id.COUNT
	UPDATE	psp_enc_summary_lines
	SET	interface_status = r_reject_recs.reason_code(recno),
		status_code = 'L'
	WHERE	enc_summary_line_id = r_reject_recs.enc_summary_line_id(recno)
	AND	r_reject_recs.txn_status_code(recno) = 'A';

	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Updated status_code to ''L'' for accepted records in psp_enc_summary_lines');

	IF (g_person_id IS NOT NULL) THEN
		FORALL recno IN 1..r_reject_recs.enc_summary_line_id.COUNT
		UPDATE	psp_enc_lines_history
		SET	change_flag = 'L'
		WHERE	enc_summary_line_id IN	(SELECT	superceded_line_id
						FROM	psp_enc_summary_lines pesl
						WHERE	pesl.enc_summary_line_id =  r_reject_recs.enc_summary_line_id(recno))
		AND	r_reject_recs.txn_status_code(recno) = 'A';
		fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Updated change_flag to ''L'' in psp_enc_lines_history for employee level encumbrance liquidation');
	END IF;

	OPEN get_success_recs_cur;
	FETCH get_success_recs_cur BULK COLLECT INTO r_success_recs.enc_control_id, r_success_recs.enc_summary_line_id,
			r_success_recs.dr_cr_flag, r_success_recs.summary_amount;
	CLOSE get_success_recs_cur;

	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	r_success_recs.enc_summary_line_id.COUNT: ' || r_success_recs.enc_summary_line_id.COUNT);

	FORALL recno IN 1..r_success_recs.enc_summary_line_id.COUNT
	UPDATE	psp_enc_controls pec
	SET	gms_phase = 'TieBack',
		summ_ogm_dr_amount = NVL(pec.summ_ogm_dr_amount, 0) + DECODE(r_success_recs.dr_cr_flag(recno), 'D', r_success_recs.summary_amount(recno), 0),
		summ_ogm_cr_amount = NVL(pec.summ_ogm_cr_amount, 0) + DECODE(r_success_recs.dr_cr_flag(recno), 'C', r_success_recs.summary_amount(recno), 0)
	WHERE	enc_control_id = r_success_recs.enc_control_id(recno);

	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Update summ_ogm_cr_amount, summ_ogm_dr_amount in psp_enc_controls');

	r_reject_recs.enc_summary_line_id.DELETE;
	r_reject_recs.enc_control_id.DELETE;
	r_reject_recs.reason_code.DELETE;
	r_reject_recs.txn_status_code.DELETE;

	r_success_recs.enc_summary_line_id.DELETE;
	r_success_recs.enc_control_id.DELETE;
	r_success_recs.reason_code.DELETE;
	r_success_recs.txn_status_code.DELETE;
--	End of changes for bug fix 4625734

/*****	Commented the following for bug fix 4625734
     OPEN gms_tie_back_reject_cur;
     LOOP
       FETCH gms_tie_back_reject_cur INTO l_trx_reject_code,l_enc_ref, l_trx_status_code;
       IF gms_tie_back_reject_cur%NOTFOUND THEN
         CLOSE gms_tie_back_reject_cur;
         EXIT;
       END IF;

       l_orig_trx_reference := substr(l_enc_ref, 3);

       -- update summary_lines with the reject status code
      IF l_trx_status_code in ('R', 'PI', 'PO', 'PR') THEN

       UPDATE psp_enc_summary_lines
       SET interface_status = l_trx_reject_code
--    , status_code = 'R'
       WHERE enc_summary_line_id = to_number(l_orig_trx_reference);

	g_liq_has_failed_transactions := TRUE;	-- Introduced for Enh. 2768298 Removal of suspense posting in Liquidation.

/ *
    Commented out for bug fix 1832670
       and enc_control_id=p_enc_Control_id;

        if sql%notfound then null;
        end if;
* /
      ELSIF l_trx_status_code = 'A' THEN

	UPDATE psp_enc_summary_lines
	SET interface_status = l_trx_reject_code, status_code = 'L'
	WHERE enc_summary_line_id = to_number(l_orig_trx_reference);
 --       and enc_control_id=p_enc_control_id;

         ---- added for 3477373
        if g_person_id is not null then
          update psp_enc_lines_history
         set change_flag = 'L'
         where enc_summary_line_id = ( select superceded_line_id
                                      from psp_enc_summary_lines
                                      where  enc_summary_line_id = to_number(l_orig_trx_reference));
         end if;


           if sql%notfound then null;
           end if;
/ ************************************************************************************************************
For Bug 2290051 : Interface Lines shall not be deleted for accepeted summary lines
	 DELETE from pa_transaction_interface_all
	  where transaction_source = 'GOLDE'
	    and batch_name = p_gms_batch_name
	    and transaction_status_code = 'A'
	    and orig_transaction_reference = l_enc_ref;

           if sql%notfound then null;
           end if;

	 DELETE from gms_transaction_interface_all
	  where batch_name = p_gms_batch_name
	    and transaction_status_code = 'A'
	    and orig_transaction_reference = l_enc_ref;

           if sql%notfound then null;
           end if;
*********************************************************************************************************************** /
      END IF;
       -- delete the rejected batch records from gms_interface

	SELECT summary_amount, dr_cr_flag
	INTO l_summary_amount, l_dr_cr_flag
	FROM psp_enc_summary_lines
	WHERE enc_summary_line_id = to_number(l_orig_trx_reference);

	IF l_dr_cr_flag = 'D' THEN
	l_dr_summary_amount := l_dr_summary_amount + l_summary_amount;
	ELSIF l_dr_cr_flag = 'C' THEN
	l_cr_summary_amount := l_cr_summary_amount - l_summary_amount;
	END If;

/ *****	Commented the following for Enh. 2768298 Removal of suspense posting in Enc. Liquidation
       OPEN assign_susp_ac_cur(l_orig_trx_reference);
       LOOP

         FETCH assign_susp_ac_cur INTO l_rowid, l_encumbrance_date,l_suspense_org_account_id
         ,l_superceded_line_id;
         IF assign_susp_ac_cur%NOTFOUND THEN
           CLOSE assign_susp_ac_cur;
           EXIT;
         END IF;

        -- IF l_trx_reject_code = 'P'  THEN

      	IF l_trx_status_code = 'A' THEN

            UPDATE psp_enc_summary_lines
          --  SET status_code = 'P'
            set status_code='L'
            WHERE rowid = l_rowid;

 -- if a suspense a/c failed,update the status of the whole batch and display the error

         ELSIF l_suspense_org_account_id IS NOT NULL AND l_trx_status_code <> 'A'  THEN

	       OPEN get_susp_org_cur(l_suspense_org_account_id);
	       FETCH get_susp_org_cur into l_organization_id, l_organization_name;
	       CLOSE get_susp_org_cur;

           x_susp_failed_org_name    := l_organization_name;
           x_susp_failed_reject_code := l_trx_reject_code;
           x_susp_failed_date        := l_encumbrance_date;
           l_suspense_ac_failed := 'Y';

         UPDATE psp_enc_summary_lines
            SET reject_reason_code = 'EL:' || l_trx_reject_code,
          --      status_code = 'A'
            status_code = 'R'
            WHERE rowid = l_rowid;

         update psp_enc_summary_lines set status_code='A' where
         enc_summary_line_id in (select superceded_line_id from
         psp_Enc_summary_lines where rowid=l_rowid);

         ELSE
           l_susp_ac_found := 'TRUE';
	       OPEN get_org_id_cur(to_number(l_orig_trx_reference));
	       FETCH get_org_id_cur into l_orig_org_id, l_orig_org_name;

	       IF get_org_id_cur%NOTFOUND then
	           CLOSE get_org_id_cur;
                  exit;
	       END IF;
               close get_org_id_cur;


           OPEN org_susp_ac_cur(l_orig_org_id, l_encumbrance_date);
           FETCH org_susp_ac_cur INTO l_organization_account_id,l_gl_code_combination_id,l_project_id,l_award_id,l_task_id,l_expenditure_type, l_exp_org_id;

           IF org_susp_ac_cur%NOTFOUND  THEN
		/ *  Following code is added for bug 2056877 ,Added validation for generic suspense account  * /
		l_return_value := psp_general.find_global_suspense(l_encumbrance_date,
							  p_business_group_id,
                                                          p_set_of_books_id,
                                                          l_organization_account_id);
      	  / *  --------------------------------------------------------------------
      	   Valid return values are
      	   PROFILE_VAL_DATE_MATCHES       Profile and Value and Date matching 'G'
      	   NO_PROFILE_EXISTS              No Profile
       	   NO_VAL_DATE_MATCHES            Profile and Either Value/date do not
            		                  match with 'G'
   	   NO_GLOBAL_ACCT_EXISTS          No 'G' exists
     	    ----------------------------------------------------------------------  * /
             / *  Added for Restart Update/Quick Update Encumbrance Lines Enh.  * /
              IF  l_return_value <> 'PROFILE_VAL_DATE_MATCHES' THEN
                 IF p_action_type IN ('Q','U') THEN
                    UPDATE psp_enc_controls
                    SET gms_phase='INVALID_SUSPENSE'
                    WHERE enc_control_id=p_enc_control_id;
                 END IF;
                 g_invalid_suspense:='Y';
                 / * IF p_mode='N' THEN  commented for 2479579
                    enc_batch_end(g_payroll_id,p_action_type,'N',g_bg_id,g_sob_id,l_return_status);
                 END IF;  * /
              END IF;


              IF  l_return_value = 'PROFILE_VAL_DATE_MATCHES' THEN
                  	        --	OPEN global_susp_ac_cur(l_encumbrance_date);
            	 	OPEN global_susp_ac_cur(l_organization_account_id); -- Bug 2056877.
        	  	FETCH global_susp_ac_cur INTO l_organization_account_id,l_gl_code_combination_id,l_project_id,l_award_id, l_task_id,l_expenditure_type, l_exp_org_id;
           		IF global_susp_ac_cur%NOTFOUND THEN
             		/ * 	  l_susp_ac_found := 'FALSE';
	            		  l_suspense_ac_not_found := 'Y';
           		          x_susp_nf_org_name := l_orig_org_name;
              		          x_susp_nf_date     := l_encumbrance_date;  Bug 2056877 * /
              		          / *  Added for Restart Update/Quick Update Encumbrance Lines  * /
              		          IF p_action_type IN ('Q','U') THEN
              		             UPDATE psp_enc_controls
              		             SET gms_phase = 'INVALID_SUSPENSE'
              		             WHERE enc_control_id = p_enc_control_id;
              		          END IF;
              		          g_invalid_suspense:='Y';
              		          / * IF p_mode='N' THEN
              		            enc_batch_end(g_payroll_id,p_action_type,'N',g_bg_id,g_sob_id,l_return_status);
              		          END IF;   commented for 2479579 * /
              		          RAISE no_global_acct_exists;	 --Added for bug 2056877.
	            	END IF;
		        CLOSE global_susp_ac_cur;
	     ELSIF l_return_value = 'NO_GLOBAL_ACCT_EXISTS' THEN
    		     RAISE no_global_acct_exists;
             ELSIF l_return_value = 'NO_VAL_DATE_MATCHES' THEN
         	    RAISE no_val_date_matches;
             ELSIF l_return_value = 'NO_PROFILE_EXISTS' THEN
         	    RAISE no_profile_exists;
             END IF; -- Bug 2056877.
         END IF;
         CLOSE org_susp_ac_cur;

           IF l_susp_ac_found = 'TRUE' THEN

             --CLOSE org_susp_ac_cur;
            IF l_gl_code_combination_id IS NOT NULL THEN
              l_gl_project_flag := 'G';
              l_effective_date := p_period_end_date;
            ELSE
              l_gl_project_flag := 'P';
		psp_general.poeta_effective_date(l_encumbrance_date,
                                   l_project_id,
                                   l_award_id,
                                   l_task_id,
                                   l_effective_date,
                                   l_return_status);
              IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;


            END IF;

            -- assign the organization suspense account and gl status
            --dbms_output.put_line('Updating enc_lines ....NULL..');

	      UPDATE psp_enc_summary_lines
              SET suspense_org_account_id = l_organization_account_id,
                  reject_reason_code ='EL:'||l_trx_status_code,
                  gl_project_flag = l_gl_project_flag,
		  gl_code_combination_id = decode(l_gl_project_flag, 'P', null, l_gl_code_combination_id ),
		  project_id = decode(l_gl_project_flag, 'P', l_project_id, null),
		  expenditure_organization_id = decode(l_gl_project_flag, 'P', l_exp_org_id, null),
		  expenditure_type = decode(l_gl_project_flag, 'P', l_expenditure_type, null),
		  task_id = decode(l_gl_project_flag, 'P', l_task_id, null),
		  award_id = decode(l_gl_project_flag, 'P', l_award_id, null),
--                   status_code = 'A'
                status_code='N'
              WHERE rowid = l_rowid;

    -- insert into psp_stout values(99, 'after updating the suspense account');
--insert into psp_Stout values(99,'gl:= '||l_gl_code_combination_id);
-- insert into psp_stout values (99, 'project_id is '||l_project_id);
-- insert into psp_stout values (99, 'award id  is '||l_award_id);
     --- modified the update for 2530853, flipping the sign of amount if 'C'
    if l_gl_project_flag ='G' then
     update psp_Enc_summary_lines set   ----- dr_cr_flag='C',
     summary_amount=decode(dr_cr_flag,'C', -summary_amount,summary_amount)
      where rowid=l_rowid;
    end if;

/ *
            UPDATE psp_enc_summary_lines
              SET attribute30 = l_organization_account_id,
                  reject_reason_code = 'EL:' || l_trx_reject_code,
                  gl_project_flag = l_gl_project_flag,
                  effective_date = l_encumbrance_date,
                  status_code = 'A'
              WHERE rowid = l_rowid;

 * /
            END IF;
         END IF;

       END LOOP;
	End of comment for Enh. 2768298 Removal of suspense posting in Enc. Liquidation	***** /
     END LOOP;

	UPDATE psp_enc_controls
	SET summ_ogm_cr_amount = nvl(summ_ogm_cr_amount, 0) + l_cr_summary_amount,
	    summ_ogm_dr_amount = nvl(summ_ogm_dr_amount, 0) + l_dr_summary_amount,
        gms_phase = 'TieBack'
	WHERE enc_control_id = p_enc_control_id;
	End of Comment for bug fix 4625734	*****/

/*****	Commented for Enh. 2768298 Removal of suspense posting in Liquidation
     IF l_suspense_ac_failed = 'Y' THEN
       fnd_message.set_name('PSP','PSP_TR_GMS_SUSP_AC_REJECT');
       fnd_message.set_token('ORG_NAME',x_susp_failed_org_name);
       fnd_message.set_token('PAYROLL_DATE',x_susp_failed_date);
       fnd_message.set_token('ERROR_MSG',x_susp_failed_reject_code);
       fnd_msg_pub.add;
       / * Added the below IF condition for Restart Update/Quick Update Encumbrance Lines Enh. * /
       IF p_action_type IN ('Q','U') THEN
   	  UPDATE psp_enc_controls
   	  SET gms_phase = 'INVALID_SUSPENSE'
   	  WHERE enc_control_id = p_enc_control_id;
       END IF;
       --g_invalid_suspense:='Y';	         commented for 2479579
          --removed call to enc_batch_end for 2479579, this call will be made at tr_to_gms
     END IF;
	End of comment for Enh. Removal of suspense posting in Liquidation	*****/

   /* Commented  for Restart Update/Quick Update Encumbrance Lines
      because global suspense function introduced,this situation is handled there.
     IF l_suspense_ac_not_found = 'Y' THEN
        fnd_message.set_name('PSP','PSP_LD_SUSPENSE_AC_NOT_EXIST');
        fnd_message.set_token('ORG_NAME',x_susp_nf_org_name);
        fnd_message.set_token('PAYROLL_DATE',x_susp_nf_date);
        fnd_msg_pub.add;
       -- Bug 2039196: Introduced the if condn.
       if p_mode = 'N' then
         enc_batch_end(g_payroll_id,g_action_type, 'N',g_bg_id, g_sob_id,l_return_status);
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       end if;
     END IF;
   */
   ELSIF l_cnt_gms_interface = 0 THEN
--	Introduced the following for bug fix 4625734
	OPEN gms_tie_back_success_cur;
	FETCH gms_tie_back_success_cur BULK COLLECT INTO r_success_recs.enc_control_id, r_success_recs.enc_summary_line_id,
		r_success_recs.dr_cr_flag, r_success_recs.summary_amount;
	CLOSE gms_tie_back_success_cur;

	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	r_success_recs.enc_summary_line_id.COUNT: ' || r_success_recs.enc_summary_line_id.COUNT);

	FORALL recno IN 1..r_success_recs.enc_summary_line_id.COUNT
	UPDATE	psp_enc_summary_lines
	SET	status_code = 'L'
	WHERE	enc_summary_line_id = r_success_recs.enc_summary_line_id(recno);

	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Updated status_code to ''L'' in psp_enc_summary_lines');

	IF (g_person_id IS NOT NULL) THEN
		FORALL recno IN 1..r_success_recs.enc_summary_line_id.COUNT
		UPDATE	psp_enc_lines_history
		SET	change_flag = 'L'
		WHERE	enc_summary_line_id IN	(SELECT	superceded_line_id
					FROM	psp_enc_summary_lines pesl
					WHERE	pesl.enc_summary_line_id =  r_success_recs.enc_summary_line_id(recno));
		fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Updated change_flag to ''L'' in psp_enc_lines_history for employee level liquidation');
	END IF;

	FORALL recno IN 1..r_success_recs.enc_summary_line_id.COUNT
	UPDATE	psp_enc_controls pec
	SET	gms_phase = 'TieBack',
		summ_ogm_dr_amount = NVL(pec.summ_ogm_dr_amount, 0) + DECODE(r_success_recs.dr_cr_flag(recno), 'D', r_success_recs.summary_amount(recno), 0),
		summ_ogm_cr_amount = NVL(pec.summ_ogm_cr_amount, 0) + DECODE(r_success_recs.dr_cr_flag(recno), 'C', r_success_recs.summary_amount(recno), 0)
	WHERE	enc_control_id = r_success_recs.enc_control_id(recno);

	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Updated summ_ogm_cr_amount, summ_ogm_dr_amount, gms_phase in psp_enc_controls');

	r_success_recs.enc_summary_line_id.DELETE;
	r_success_recs.enc_control_id.DELETE;
	r_success_recs.reason_code.DELETE;
	r_success_recs.txn_status_code.DELETE;
--	End of changes for bug fix 4625734

/*****	Commented the following as part of bug fix 4625734
     OPEN gms_tie_back_success_cur;
     LOOP
       FETCH gms_tie_back_success_cur INTO l_enc_summary_line_id,
        l_dr_cr_flag,l_summary_amount;

       IF gms_tie_back_success_cur%NOTFOUND THEN
         CLOSE gms_tie_back_success_cur;
         EXIT;
       END IF;
       -- update records in psp_summary_lines as 'A'
       UPDATE psp_enc_summary_lines
       SET status_code = 'L'
       WHERE enc_summary_line_id = l_enc_summary_line_id
	and status_code = 'N';

                 ---- added for 3477373
        if g_person_id is not null then
          update psp_enc_lines_history
         set change_flag = 'L'
         where enc_summary_line_id = ( select superceded_line_id
                                      from psp_enc_summary_lines
                                      where  enc_summary_line_id = l_enc_summary_line_id);
       end if;


/ ************************************************************************************************************
For Bug 2290051 : Interface Lines shall not be deleted for accepeted summary lines

	 DELETE from pa_transaction_interface_all
	  where transaction_source = 'GOLDE'
	    and batch_name = p_gms_batch_name
	    and transaction_status_code = 'A'
	    and orig_transaction_reference =  'E:' || to_char(l_enc_summary_line_id);

	 DELETE from gms_transaction_interface_all
	  where transaction_source = 'GOLDE'
	    and batch_name = p_gms_batch_name
	    and transaction_status_code = 'A'
	    and orig_transaction_reference =  'E:' || to_char(l_enc_summary_line_id);
******************************************************************************************************* /
       IF l_dr_cr_flag = 'D' THEN
         l_dr_summary_amount := l_dr_summary_amount + l_summary_amount;
       ELSIF l_dr_cr_flag = 'C' THEN
         -- credit is marked as -ve for posting to Oracle Projects
         l_cr_summary_amount := l_cr_summary_amount - l_summary_amount;
       END IF;

     END LOOP;
/ *
	UPDATE psp_enc_summary_lines
	SET status_code = 'P'
	where enc_control_id = p_enc_control_id
	and gl_project_flag = 'P'
        and gms_batch_name=p_gms_batch_name
	and status_code = 'A';
* /
     UPDATE psp_enc_controls
     SET summ_ogm_cr_amount = l_cr_summary_amount,
         summ_ogm_dr_amount = l_dr_summary_amount,
         gms_phase = 'TieBack'
     WHERE enc_control_id = p_enc_control_id;
    --COMMIT;
	End of comment for bug fix 4625734	*****/
   END IF;
   --
   END IF; -- IF (PROCESS_COMPLETE)

   p_return_status := fnd_api.g_ret_sts_success;
	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Leaving GMS_ENC_TIE_BACK');
 EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     --dbms_output.put_line('Gone to one level top ..................');
     g_error_api_path := 'GMS_ENC_TIE_BACK:'||g_error_api_path;
     p_return_status := fnd_api.g_ret_sts_unexp_error;
	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Leaving GMS_ENC_TIE_BACK');

   /* Added Exceptions for Bug 2056877 */
/*****	Commented the following for bgu fix 4625734
   WHEN NO_PROFILE_EXISTS THEN
      g_error_api_path := SUBSTR('GMS_ENC_TIE_BACK:'||g_error_api_path,1,230);
      fnd_message.set_name('PSP','PSP_NO_PROFILE_EXISTS');
      fnd_msg_pub.add;
      --p_return_status := fnd_api.g_ret_sts_unexp_error;
      p_return_status := fnd_api.g_ret_sts_success;   --- replaced error with success for 2479579

   WHEN NO_VAL_DATE_MATCHES THEN
      g_error_api_path := SUBSTR('GMS_ENC_TIE_BACK:'||g_error_api_path,1,230);
      fnd_message.set_name('PSP','PSP_NO_VAL_DATE_MATCHES');
      fnd_message.set_token('ORG_NAME',l_orig_org_name);
      fnd_message.set_token('PAYROLL_DATE',l_encumbrance_date);
      fnd_msg_pub.add;
      --p_return_status := fnd_api.g_ret_sts_unexp_error;
      p_return_status := fnd_api.g_ret_sts_success;   --- replaced error with success for 2479579

   WHEN NO_GLOBAL_ACCT_EXISTS THEN
      g_error_api_path := SUBSTR('GMS_ENC_TIE_BACK:'||g_error_api_path,1,230);
      fnd_message.set_name('PSP','PSP_NO_GLOBAL_ACCT_EXISTS');
      fnd_message.set_token('ORG_NAME',l_orig_org_name);
      fnd_message.set_token('PAYROLL_DATE',l_encumbrance_date);
      fnd_msg_pub.add;
      --p_return_status := fnd_api.g_ret_sts_unexp_error;  --End of Modification for Bug 2056877.
      p_return_status := fnd_api.g_ret_sts_success;   --- replaced error with success for 2479579
	End of comment for bug fix 4625734	*****/

   WHEN OTHERS THEN
      g_error_api_path := 'GMS_ENC_TIE_BACK:'||g_error_api_path;
      fnd_msg_pub.add_exc_msg('PSP_ENC_LIQ_TRAN','GMS_ENC_TIE_BACK');
      p_return_status := fnd_api.g_ret_sts_unexp_error;
	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Leaving GMS_ENC_TIE_BACK');

END gms_enc_tie_back;

/* Commented the procedure below as part of "Zero work days " enhancement Bug 1994421 */

/* PROCEDURE get_effective_date(p_person_id in number, p_effective_date in out date)
IS
l_effective_date DATE;
l_count number:= 0;
BEGIN

select 1 into l_count from
per_all_assignments_f ainner,
per_assignment_status_types binner
where ainner.person_id=p_person_id
and ainner.primary_flag='Y'
and ainner.assignment_status_type_id=binner.assignment_status_type_id
and binner.per_system_status='ACTIVE_ASSIGN'
and p_effective_date between ainner.effective_start_date and ainner.effective_end_date;

exception
when no_data_found then
begin
select  max(a.effective_end_date) into l_effective_date
from per_all_assignments_f a, per_assignment_status_types b
where a.person_id=p_person_id
and a.primary_flag='Y'
and a.assignment_status_type_id=b.assignment_status_type_id
and b.per_system_status='ACTIVE_ASSIGN' and
(trunc(a.effective_end_date) <= trunc(p_effective_date));

p_effective_date:=l_effective_date;
END get_effective_date;
END;
*/


/*
------------------ INSERT INTO PSP_STOUT -----------------------------------------------

 PROCEDURE insert_into_psp_stout(
	P_MSG			IN	VARCHAR2) IS
	l_msg_id	number(9);
 BEGIN
   SELECT PSP_STOUT_S.NEXTVAL
    INTO l_msg_id
    FROM DUAL;
   INSERT INTO PSP_STOUT(
	MSG_ID,
	MSG)
   VALUES(
	l_msg_id,
	P_MSG);
 END insert_into_psp_stout;
*/

/*************************************************************
Created By	:	spchakra
Created Date	:	10-Jan-2002
Purpose		:	This procedure has been introduced for the Bug 2110930 -Quick Update Encumbrance
			Enhancement. The procedure shall be invoked in Q (quick update) or U (update) mode
			to move the processed assignments to history.

Known limitations, enhancements or remarks

Change History
Who		When		What
spchakra	10-Jan-2002	Created

**************************************************************/
/* Commented the below procedure for Restart Update/Quick Update Encumbrance Lines Enhancement
PROCEDURE	move_qkupd_rec_to_hist
			(p_payroll_id		IN	NUMBER,
			p_action_type		IN	VARCHAR2,
			p_business_group_id	IN	NUMBER,
			p_set_of_books_id	IN	NUMBER,
			p_return_status		OUT NOCOPY	VARCHAR2)
IS

no_of_asg	 NUMBER  DEFAULT  0;

CURSOR	get_rec_to_move IS
SELECT	DISTINCT peca.assignment_id,
	peca.change_type
FROM	psp_enc_changed_assignments peca
WHERE	peca.payroll_id	= p_payroll_id;


CURSOR	get_no_asg_to_move IS
SELECT	COUNT(DISTINCT peca.assignment_id)
FROM	psp_enc_changed_assignments peca
WHERE	peca.payroll_id = p_payroll_id;

get_rec_to_move_rec	get_rec_to_move%ROWTYPE;

BEGIN
	IF p_action_type ='Q' THEN
		OPEN	get_no_asg_to_move;
		FETCH	get_no_asg_to_move INTO no_of_asg;
		CLOSE	get_no_asg_to_move;
	END IF;

--	Cursor get_rec_to_move would be used for each distinct assignment_id ,change_type combination,
--	Only total distinct assignment ids would be logged

	OPEN get_rec_to_move;
	LOOP
		FETCH get_rec_to_move INTO get_rec_to_move_rec;
		EXIT WHEN get_rec_to_move%NOTFOUND;

		INSERT INTO psp_enc_changed_asg_history
			(assignment_id,
			payroll_id,
			change_type,
			processing_module,
			created_by,
			creation_date,
			processed_flag)
		VALUES	(get_rec_to_move_rec.assignment_id,
			p_payroll_id,
			get_rec_to_move_rec.change_type,
			p_action_type,
			fnd_global.user_id,
			sysdate,
			NULL);

		DELETE	FROM	psp_enc_changed_assignments peca
		WHERE	peca.assignment_id = get_rec_to_move_rec.assignment_id
 		AND	peca.change_type   = get_rec_to_move_rec.change_type
		AND	peca.payroll_id	   = p_payroll_id;

	END LOOP;
	CLOSE get_rec_to_move;

	IF p_action_type = 'Q' THEN
		fnd_message.set_name('PSP','PSP_ENC_NUM_ASG');
		fnd_message.set_token('NUM_ASG',no_of_asg);
		fnd_msg_pub.add;
		psp_message_s.print_error	(p_mode		=>	FND_FILE.LOG,
						p_print_header	=>	FND_API.G_FALSE);
	END IF;

	p_return_status	:= FND_API.G_RET_STS_SUCCESS;

EXCEPTION
	WHEN OTHERS THEN
		g_error_api_path := SUBSTR('MOVE_QKUPD_REC_TO_HIST:'||g_error_api_path,1,230);
		fnd_msg_pub.add_exc_msg('PSP_ENC_UPDATE_LINES','MOVE_QKUPD_REC_TO_HIST');
		p_return_status := fnd_api.g_ret_sts_unexp_error;
END move_qkupd_rec_to_hist;
*/

--- Bug 3413373: Created a new wrapper procedure
/*****	Commented for Create and Update multi thread enh.
Procedure liquidate_emp_term(errbuf  OUT NOCOPY VARCHAR2,
                             retcode OUT NOCOPY VARCHAR2,
                             p_business_group_id in number,
                             p_set_of_books_id   in number,
                             p_person_id         in number,
                             p_actual_term_date  in date)  is
---- there is no index on person/assignment on psp_enc_summary_lines
--- psp_enc_lines_history has index on assignment
cursor get_enc_hist_lines_cur is
select ESL.payroll_id  payroll_id,
       min(ESL.time_period_id) time_period_id
from psp_enc_lines_history ELH,
     psp_enc_summary_lines ESL,
     per_all_assignments_f ASG
where ASG.person_id = p_person_id
  and ASG.assignment_id = ELH.assignment_id
  and ELH.enc_summary_line_id = ESL.enc_summary_line_id
  and ESL.status_code = 'A'
  and ESL.effective_date > p_actual_term_date
  and p_actual_term_date between ASG.effective_start_date and ASG.effective_end_date
group by ESL.payroll_id;


--- previous cursor may not pull summary lines if
--- previous Liquidation failed, becuase they could be
--- left with 'S'
/ *****	Modified the following cursor for bug fix 4625734
cursor inprogress_controls_cur is
select CTRL.payroll_id, min(CTRL.time_period_id) time_period_id
from psp_enc_controls CTRL
where CTRL.action_code = 'IT'
  and (CTRL.payroll_id, CTRL.time_period_id) in
      (select ASG.payroll_id, min(PER.time_period_id)
       from per_all_assignments_f ASG,
            per_time_periods PER
       where ASG.payroll_id = PER.payroll_id
         and ASG.person_id = p_person_id
         and p_Actual_term_date between PER.start_date and PER.end_date
         group by ASG.payroll_id)
group by CTRL.payroll_id;
	End of comment for bug fix 4625734	***** /

--	Introduced the following for bug fix 4625734
CURSOR	inprogress_controls_cur IS
SELECT	pec.liquidate_request_id,
	pec.payroll_id,
	MIN(pec.time_period_id),
	MIN(enc_control_id)
FROM	psp_enc_controls pec
WHERE	pec.action_code = 'IT'
GROUP BY	pec.liquidate_request_id, pec.payroll_id;

l_request_id		NUMBER(15);
l_enc_control_id	NUMBER(15);

CURSOR	term_employee_cur IS
SELECT	TO_NUMBER(argument3),
	fnd_date.canonical_to_date(fnd_date.date_to_canonical(argument4))
FROM	fnd_concurrent_requests fcr
WHERE	fcr.request_id = l_request_id;

CURSOR	enc_control_cur IS
SELECT	DISTINCT enc_control_id
FROM	psp_enc_lines
WHERE	person_id = p_person_id
AND	encumbrance_date > p_actual_term_date;

TYPE t_number_15 IS TABLE OF NUMBER(15) INDEX BY BINARY_INTEGER;

t_enc_control_id	t_number_15;
--	End of changes for bug fix 4625734

l_payroll_id     integer;
l_errbuf         VARCHAR2(32767);
l_retcode        VARCHAR2(32767);

l_person_id1		NUMBER(15);
l_full_name1		VARCHAR2(240);
l_termination_date1	DATE;
l_full_name2		VARCHAR2(240);

CURSOR	get_full_name_cur	(p_person_id		IN	NUMBER,
				p_effective_date	IN	DATE) IS
SELECT	full_name
FROM	per_all_people_f
WHERE	person_id = p_person_id
AND	p_effective_date BETWEEN effective_start_date AND effective_end_date;
begin
	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Entering LIQUIDATE_EMP_TERM');

   g_person_id := p_person_id;  --- added for 3413373
   g_actual_term_date := p_actual_term_date; --- added for 3413373

     --- if any records are left due to previous aborted run
	OPEN inprogress_controls_cur;
	LOOP
		FETCH inprogress_controls_cur INTO l_request_id, l_payroll_id, g_term_period_id, l_enc_control_id;
		EXIT WHEN inprogress_controls_cur%NOTFOUND;

		fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	l_request_id: ' || l_request_id || '
	l_payroll_id: ' || l_payroll_id || '
	g_term_period_id: ' || g_term_period_id || '
	l_enc_control_id: ' || l_enc_control_id);

		OPEN term_employee_cur;
		FETCH term_employee_cur INTO l_person_id1, l_termination_date1;
		CLOSE term_employee_cur;

		fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	l_person_id1: ' || l_person_id1 || ';l_termination_date1: ' || fnd_date.date_to_canonical(l_termination_date1));

		IF ((l_person_id1 <> p_person_id) OR (l_termination_date1 <> p_actual_term_date)) THEN
			OPEN get_full_name_cur(l_person_id1, l_termination_date1);
			FETCH get_full_name_cur INTO l_full_name1;
			CLOSE get_full_name_cur;

			OPEN get_full_name_cur(p_person_id, p_actual_term_date);
			FETCH get_full_name_cur INTO l_full_name2;
			CLOSE get_full_name_cur;

			fnd_message.set_name('PSP', 'PSP_ENC_LIQ_TERM_EMP_MISMATCH');
			fnd_message.set_token('PERSON1', l_full_name1);
			fnd_message.set_token('TERMDATE1', l_termination_date1);
			fnd_message.set_token('PERSON2', l_full_name2);
			fnd_message.set_token('TERMDATE2', p_actual_term_date);
			fnd_msg_pub.add;

			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;

		fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Calling enc_liq_trans');

            psp_enc_liq_tran.enc_liq_trans(
                      errbuf            => l_errbuf,
                      retcode           => l_retcode,
                      p_payroll_action_id => NULL,
                      p_payroll_id      => l_payroll_id,
                      p_action_type     => 'T' ,
                      p_business_group_id => p_business_group_id,
                      p_set_of_books_id => p_set_of_books_id);
               IF l_retcode <> FND_API.G_RET_STS_SUCCESS THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
               END IF;
		fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	After enc_liq_trans');
      end loop;

	OPEN enc_control_cur;
	FETCH enc_control_cur BULK COLLECT INTO t_enc_control_id;
	CLOSE enc_control_cur;

	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	t_enc_control_id.COUNT: ' || t_enc_control_id.COUNT);

	FORALL recno IN 1..t_enc_control_id.COUNT
	UPDATE	psp_enc_controls
	SET	number_of_dr	=	(SELECT	number_of_dr - COUNT(1)
					FROM	psp_enc_lines
					WHERE	enc_control_id = t_enc_control_id(recno)
					AND	dr_cr_flag = 'D'
					AND	person_id = p_person_id
					AND	encumbrance_date > p_actual_term_date),
		number_of_cr	=	(SELECT	number_of_cr - COUNT(1)
					FROM	psp_enc_lines
					WHERE	enc_control_id = t_enc_control_id(recno)
					AND	dr_cr_flag = 'C'
					AND	person_id = p_person_id
					AND	encumbrance_date > p_actual_term_date),
		total_dr_amount	=	(SELECT	total_dr_amount - SUM(encumbrance_amount)
					FROM	psp_enc_lines
					WHERE	enc_control_id = t_enc_control_id(recno)
					AND	dr_cr_flag = 'D'
					AND	person_id = p_person_id
					AND	encumbrance_date > p_actual_term_date),
		total_cr_amount	=	(SELECT	total_cr_amount - SUM(encumbrance_amount)
					FROM	psp_enc_lines
					WHERE	enc_control_id = t_enc_control_id(recno)
					AND	dr_cr_flag = 'C'
					AND	person_id = p_person_id
					AND	encumbrance_date > p_actual_term_date),
		gl_dr_amount	=	(SELECT	gl_dr_amount - SUM(encumbrance_amount)
					FROM	psp_enc_lines
					WHERE	enc_control_id = t_enc_control_id(recno)
					AND	dr_cr_flag = 'D'
					AND	gl_project_flag = 'G'
					AND	person_id = p_person_id
					AND	encumbrance_date > p_actual_term_date),
		gl_cr_amount	=	(SELECT	gl_cr_amount - SUM(encumbrance_amount)
					FROM	psp_enc_lines
					WHERE	enc_control_id = t_enc_control_id(recno)
					AND	dr_cr_flag = 'C'
					AND	gl_project_flag = 'G'
					AND	person_id = p_person_id
					AND	encumbrance_date > p_actual_term_date),
		ogm_dr_amount	=	(SELECT	ogm_dr_amount - SUM(encumbrance_amount)
					FROM	psp_enc_lines
					WHERE	enc_control_id = t_enc_control_id(recno)
					AND	dr_cr_flag = 'D'
					AND	gl_project_flag = 'P'
					AND	person_id = p_person_id
					AND	encumbrance_date > p_actual_term_date),
		ogm_cr_amount	=	(SELECT	ogm_cr_amount - SUM(encumbrance_amount)
					FROM	psp_enc_lines
					WHERE	enc_control_id = t_enc_control_id(recno)
					AND	dr_cr_flag = 'C'
					AND	gl_project_flag = 'P'
					AND	person_id = p_person_id
					AND	encumbrance_date > p_actual_term_date)
	WHERE	enc_control_id = t_enc_control_id(recno);

	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Updated number_of_dr, number_of_cr, total_dr_amount, total_cr_amount, gl_dr_amount, gl_cr_amount, ogm_dr_amount, ogm_cr_cmount in psp_enc_controls');

	DELETE	psp_enc_lines
	WHERE	person_id = p_person_id
	AND	encumbrance_date > p_actual_term_date;

	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Deleted in psp_enc_lines');

	IF (inprogress_controls_cur%ROWCOUNT = 0) THEN
		open get_enc_hist_lines_cur;
		loop
			fetch get_enc_hist_lines_cur into l_payroll_id, g_term_period_id;
			if get_enc_hist_lines_cur%notfound then
				close get_enc_hist_lines_cur;
				exit;
			end if;
			fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Calling enc_liq_trans');

			psp_enc_liq_tran.enc_liq_trans(
				errbuf            => l_errbuf,
				retcode           => l_retcode,
				p_payroll_action_id => NULL,
				p_payroll_id      => l_payroll_id,
				p_action_type     => 'T' ,
				p_business_group_id => p_business_group_id,
				p_set_of_books_id => p_set_of_books_id);
			IF l_retcode <> FND_API.G_RET_STS_SUCCESS THEN
				RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
			END IF;
			fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	After enc_liq_trans');
		END LOOP;
	END IF;

	CLOSE inprogress_controls_cur;

	retcode := 0;
	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Leaving LIQUIDATE_EMP_TERM');
exception
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      fnd_msg_pub.add_exc_msg('PSP_ENC_LIQ_TRAN','LIQUIDATE_EMP_TERM');
      fnd_msg_pub.add;
      psp_message_s.print_error(p_mode => FND_FILE.LOG,
                               p_print_header => FND_API.G_TRUE);
      ROLLBACK;
      retcode := 2;

   when others then
      fnd_msg_pub.add_exc_msg('PSP_ENC_LIQ_TRAN','LIQUIDATE_EMP_TERM');
      fnd_msg_pub.add;
      psp_message_s.print_error(p_mode => FND_FILE.LOG,
                               p_print_header => FND_API.G_TRUE);
      ROLLBACK;
      errbuf := sqlerrm;
      retcode := 2;
end;
	End of comment for create and Update multi thread enh.	*****/

END psp_enc_liq_tran;

/

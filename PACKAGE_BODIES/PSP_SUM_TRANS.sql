--------------------------------------------------------
--  DDL for Package Body PSP_SUM_TRANS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSP_SUM_TRANS" as
/* $Header: PSPTRSTB.pls 120.17.12010000.5 2010/01/22 07:45:19 amakrish ship $ */
--- g_gms_avail	VARCHAR2(1) := 'N'; removed the usage of this variable, because
---        transfer_to_gms has checks on GMS phase. bug 2444657
/* Following three global variables introduced to faciliate calling mark_batch_end procedure
   from GL_TIE_BACK procedure: Bug 1929317 */
 g_source_code Varchar2(30);
 g_batch_name  Varchar2(30);
 g_time_period_id number;
 g_payroll_id integer;    --- added for ER enhancment.
-- g_currency_code   Varchar2(15); -- added for bug no 2478000 Commented for Bug 2916848

-- Introduced the following for bug 2259310
  g_enable_enc_summ_gl        VARCHAR2(1) DEFAULT NVL(fnd_profile.value('PSP_ENABLE_ENC_SUMM_GL'), 'N');

   g_insert_str	VARCHAR2(5000); -- Introduced for Bug fix 2935850

g_dff_grouping_option	CHAR(1);			-- Introduced for bug fix 2908859
 g_suspense_autopop  varchar2(1);  -- 5080403

  -- Introduced the following for Bug 6902514
 g_create_stat_batch_in_gms  VARCHAR(1);      -- change
 g_skip_flag_gms	     varchar(1);       -- change


 PROCEDURE sum_and_transfer(errbuf	         OUT NOCOPY VARCHAR2,
                            retcode	         OUT NOCOPY VARCHAR2,
                            p_source_type     	 IN VARCHAR2,
                            p_source_code     	 IN VARCHAR2,
			    p_payroll_id	 IN NUMBER,
                            p_time_period_id  	 IN NUMBER,
                            p_batch_name      	 IN VARCHAR2,
			    p_business_group_id  	 IN NUMBER,
			    p_set_of_books_id      	 IN NUMBER) IS

    l_return_status	VARCHAR2(10);
    l_msg_count		NUMBER;
    l_msg_data		VARCHAR2(2000);
  --- introduced for 5080403
  cursor autopop_config_cur is
  select pcv_information7 suspense_account
    from pqp_configuration_values
   where pcv_information_category = 'PSP_ENABLE_AUTOPOPULATION'
     and legislation_code is null
     and nvl(business_group_id, p_business_group_id) = p_business_group_id;


   /* Added for bug 6902514    -- change
      Introduced "Transfer and Create STAT Batch in GMS" configuration type and the flexfield is named
      PSP_CREATE_STAT_BATCH_IN_GMS,

      If the config type value = N,
      STAT batch is not created on GMS side but tieback happens on LD tables as if GMS batch has been created for STAT data

      If the config type value = Y,
      STAT batch gets created on GMS side, but the data cannot be distributed/costed as Grants product does not support STAT
      transactions.
    */

   CURSOR	create_stat_batch_in_gms_cur IS
   SELECT	NVL(pcv_information1,'N')
   FROM	pqp_configuration_values
   WHERE	pcv_information_category = 'PSP_CREATE_STAT_BATCH_IN_GMS'
   AND	legislation_code IS NULL
   AND	NVL(business_group_id, p_business_group_id) = p_business_group_id;      -- change

 BEGIN
---hr_utility.trace_on('Y','SandT');
   g_error_api_path := '';
   fnd_msg_pub.initialize;
   psp_general.TRANSACTION_CHANGE_PURGEBLE;

/* Following three variables initialized to faciliate calling mark_batch_end procedure
   from GL_TIE_BACK procedure: Bug 1929317 */

 g_source_code :=  p_source_code;
 g_batch_name  :=  p_batch_name;
 g_time_period_id := p_time_period_id;
 g_payroll_id := p_payroll_id;
 -- g_currency_code := psp_general.get_currency_code(p_business_group_id); -- Commented the following code for Bug 2916848

 open autopop_config_cur; -- 5080403
 fetch autopop_config_cur into g_suspense_autopop;
 close autopop_config_cur;

/*Added the following cursor open-fetch-close for Bug 6902514*/  -- change
 open create_stat_batch_in_gms_cur;
 fetch create_stat_batch_in_gms_cur into g_create_stat_batch_in_gms;
 close create_stat_batch_in_gms_cur;  -- change


	g_dff_grouping_option := psp_general.get_act_dff_grouping_option(p_business_group_id);	-- Introduced for bug fix 2908859

 mark_batch_begin(p_source_type,
                    p_source_code,
         	    p_payroll_id,
                    p_time_period_id,
                    p_batch_name,
		    p_business_group_id,
		    p_set_of_books_id,
                    l_return_status);

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


    -- FIRST NORMAL RUN
    -- initiate the gl summarization and transfer
    create_gl_sum_lines(p_source_type,
                        p_source_code,
                        p_time_period_id,
                        p_batch_name,
			p_business_group_id,
			p_set_of_books_id,
                        l_return_status);
    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- call the user extension to populate attribute1 through attribute30
    IF FND_PROFILE.VALUE('PSP_ST_EXTENSION_ENABLE') = 'Y' THEN
      --- 2968684 added params and exception handlers to the following proc.
      psp_st_ext.summary_ext_actual(p_source_type,
                              p_source_code     ,
                              p_payroll_id      ,
                              p_time_period_id  ,
                              p_batch_name      ,
                              p_business_group_id,
                              p_set_of_books_id  );
    END IF;

    transfer_to_gl_interface(p_source_type,
                             p_source_code,
                             p_time_period_id,
                             p_batch_name,
			     p_business_group_id,
			     p_set_of_books_id,
                             l_return_status);

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    create_gms_sum_lines(p_source_type,
                         p_source_code,
                         p_time_period_id,
                         p_batch_name,
			 p_business_group_id,
			 p_set_of_books_id,
                         l_return_status);
    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Call the user extension to populate  attribute1 thru attribute 30.
	IF FND_PROFILE.VALUE('PSP_ST_EXTENSION_ENABLE') = 'Y' THEN
             --- 2968684 added params and exception handlers to the following proc.
             psp_st_ext.summary_ext_actual(p_source_type,
                              p_source_code     ,
                              p_payroll_id      ,
                              p_time_period_id  ,
                              p_batch_name      ,
                              p_business_group_id,
                              p_set_of_books_id  );
	END IF;

    transfer_to_gms_interface(p_source_type,
                              p_source_code,
                              p_time_period_id,
                              p_batch_name,
			      p_business_group_id,
			      p_set_of_books_id,
                              l_return_status);

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- SECOND RUN TO TAKE CARE OF TIE-BACK
    -- initiate the gl summarization
    create_gl_sum_lines(p_source_type,
                        p_source_code,
                        p_time_period_id,
                        p_batch_name,
			p_business_group_id,
			p_set_of_books_id,
                        l_return_status);

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Call the user extension to populate  attribute1 thru attribute 30.
	IF FND_PROFILE.VALUE('PSP_ST_EXTENSION_ENABLE') = 'Y' THEN
             --- 2968684 added params and exception handlers to the following proc.
            psp_st_ext.summary_ext_actual(p_source_type,
                              p_source_code     ,
                              p_payroll_id      ,
                              p_time_period_id  ,
                              p_batch_name      ,
                              p_business_group_id,
                              p_set_of_books_id  );
	END IF;

    transfer_to_gl_interface(p_source_type,
                             p_source_code,
                             p_time_period_id,
                             p_batch_name,
			     p_business_group_id,
			     p_set_of_books_id,
                             l_return_status);

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;



    create_gms_sum_lines(p_source_type,
                         p_source_code,
                         p_time_period_id,
                         p_batch_name,
			 p_business_group_id,
			 p_set_of_books_id,
                         l_return_status);

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- call the user extension to populate attribute1 through attribute30
    IF FND_PROFILE.VALUE('PSP_ST_EXTENSION_ENABLE') = 'Y' THEN
       --- 2968684 added params and exception handlers to the following proc.
      psp_st_ext.summary_ext_actual(p_source_type,
                              p_source_code     ,
                              p_payroll_id      ,
                              p_time_period_id  ,
                              p_batch_name      ,
                              p_business_group_id,
                              p_set_of_books_id  );
    END IF;


    transfer_to_gms_interface(p_source_type,
                              p_source_code,
                              p_time_period_id,
                              p_batch_name,
			      p_business_group_id,
			      p_set_of_books_id,
                              l_return_status);

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    mark_batch_end(p_source_type,
                   p_source_code,
                   p_time_period_id,
                   p_batch_name,
		   p_business_group_id,
		   p_set_of_books_id,
                   l_return_status);

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

          PSP_MESSAGE_S.Print_success;

 EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

	/* Introduced as part of bug fix #1776606 */
	ROLLBACK;
	/* Commented as part of Bug fix #1776606
      mark_batch_end(p_source_type,
                     p_source_code,
                     p_time_period_id,
                     p_batch_name,
		     p_business_group_id,
		     p_set_of_books_id,
                     l_return_status);

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      fnd_msg_pub.get(p_msg_index     =>  FND_MSG_PUB.G_FIRST,
                      p_encoded       =>  FND_API.G_FALSE,
                      p_data          =>  l_msg_data,
                      p_msg_index_out =>  l_msg_count); */

      g_error_api_path := 'SUM_AND_TRANSFER:'||g_error_api_path;
      errbuf := SUBSTR(l_msg_data || fnd_global.local_chr(10) ||fnd_global.local_chr(10)||g_error_api_path,1,230);
          psp_message_s.print_error(p_mode => FND_FILE.LOG,
                                  p_print_header => FND_API.G_TRUE);
      retcode := 2;
    WHEN OTHERS THEN

	/* Introduced as part of Bug fix #1776606 */
	ROLLBACK;
	/* Commented as part of Bug fix #1776606

      mark_batch_end(p_source_type,
                     p_source_code,
                     p_time_period_id,
                     p_batch_name,
		     p_business_group_id,
		     p_set_of_books_id,
                     l_return_status);

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      fnd_msg_pub.add_exc_msg('PSP_SUM_TRANS','SUM_AND_TRANSFER');
      fnd_msg_pub.get(p_msg_index     =>  FND_MSG_PUB.G_FIRST,
                      p_encoded       =>  FND_API.G_FALSE,
                      p_data          =>  l_msg_data,
                      p_msg_index_out =>  l_msg_count); */

      g_error_api_path := 'SUM_AND_TRANSFER:'||g_error_api_path;
      errbuf := SUBSTR(l_msg_data || fnd_global.local_chr(10) ||fnd_global.local_chr(10)||g_error_api_path,1,230);
          psp_message_s.print_error(p_mode => FND_FILE.LOG,
                                  p_print_header => FND_API.G_TRUE);
      retcode := 2;
 END;

-------------------- MARK BATCH BEGIN --------------------------------------------

 PROCEDURE mark_batch_begin(p_source_type     IN VARCHAR2,
                            p_source_code     IN VARCHAR2,
                            p_payroll_id      IN NUMBER,
                            p_time_period_id  IN NUMBER,
      			    p_batch_name      IN VARCHAR2,
			    p_business_group_id    IN NUMBER,
			    p_set_of_books_id      IN NUMBER,
                            p_return_status  OUT NOCOPY VARCHAR2) IS

   CURSOR payroll_control_cur2 IS
   SELECT payroll_control_id
   FROM   psp_payroll_controls
   WHERE  source_type = nvl(p_source_type,source_type)
   AND    payroll_source_code = nvl(p_source_code,payroll_source_code)
   AND    payroll_id    =  NVL (p_payroll_id, payroll_id)     -- Bug 7137063
   AND    time_period_id = nvl(p_time_period_id,time_period_id)
   AND    nvl(batch_name,'N') = nvl(nvl(p_batch_name,batch_name),'N')
   AND    (dist_dr_amount IS NOT NULL OR dist_cr_amount IS NOT NULL)
   AND    status_code in ('N','I')  --- added 'I' for 2444657
   AND    business_group_id = p_business_group_id
   AND    set_of_books_id = p_set_of_books_id
   AND    source_type <> 'A'  -- Adjustments are delinked.
   AND    parent_payroll_control_id is null;

  l_payroll_control_id integer;

   CURSOR payroll_control_cur IS
   SELECT payroll_control_id,
          source_type,
          payroll_source_code,
          time_period_id,
          batch_name,
          phase
   FROM   psp_payroll_controls
    where status_code in ('N','I')
    and   source_type <> 'A'
    and   payroll_control_id = l_payroll_control_id
    or    parent_payroll_control_id = l_payroll_control_id;

   payroll_control_rec		payroll_control_cur%ROWTYPE;
   l_gms_batch_name		NUMBER(15);
   l_ti_not_complete		NUMBER(15);

 BEGIN
  SELECT psp_st_run_id_s.nextval
  INTO g_run_id
  FROM dual;
 open payroll_control_cur2;
 loop
  fetch payroll_control_cur2 into l_payroll_control_id;
  if payroll_control_cur2%notfound then
    close payroll_control_cur2;
    exit;
  end if;
  OPEN payroll_control_cur;
  LOOP
   FETCH payroll_control_cur INTO payroll_control_rec;
   IF payroll_control_cur%NOTFOUND THEN
     CLOSE payroll_control_cur;
     EXIT;
   END IF;
   UPDATE psp_payroll_controls
   SET status_code = 'I',
       run_id = g_run_id
   WHERE payroll_control_id = payroll_control_rec.payroll_control_id;

   if (payroll_control_rec.phase = 'Submitted_TI_Request') then
     select max(gms_batch_name)
       into l_gms_batch_name
       from psp_summary_lines
      where payroll_control_id = payroll_control_rec.payroll_control_id;

      select count(*)
	into l_ti_not_complete
	from pa_transaction_interface_all
       where transaction_status_code = 'I'
	 and batch_name = to_char(l_gms_batch_name)
	 and transaction_source in ('GOLD', 'OLD');

     if (l_ti_not_complete > 0) then
         fnd_message.set_name('PSP','PSP_TI_DID_NOT_COMPLETE');
         fnd_message.set_token('PAYROLL_CONTROL_ID', payroll_control_rec.payroll_control_id);
         fnd_message.set_token('GMS_BATCH_NAME', l_gms_batch_name);
         fnd_msg_pub.add;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     end if;

   end if;

  END LOOP;
 end loop;
  /* Introduced as part of Bug fix #1776606 */
 EXCEPTION
	WHEN OTHERS THEN
		g_error_api_path := 'MARK_BATCH_BEGIN: ' || g_error_api_path;
		fnd_msg_pub.add_exc_msg('PSP_SUM_TRANS','MARK_BATCH_BEGIN');
		p_return_status := fnd_api.g_ret_sts_unexp_error;
		RAISE;
 END;
-------------------- MARK BATCH END ---------------------------------------------

 PROCEDURE mark_batch_end(p_source_type     IN VARCHAR2,
                          p_source_code     IN VARCHAR2,
                          p_time_period_id  IN NUMBER,
                          p_batch_name      IN VARCHAR2,
			  p_business_group_id IN NUMBER,
			  p_set_of_books_id   IN NUMBER,
                          p_return_status  OUT NOCOPY VARCHAR2) IS

   CURSOR payroll_control_cur IS
   SELECT payroll_control_id,
          source_type,
          payroll_source_code,
          time_period_id,
          batch_name,
          phase
   FROM   psp_payroll_controls
   WHERE  status_code = 'I'
   AND    run_id = g_run_id
   AND    source_type <> 'A';

   payroll_control_rec		payroll_control_cur%ROWTYPE;
   l_summary_line_id		NUMBER(10);
   l_phase_counter             NUMBER (10) DEFAULT 0 ;

--**************************************************************
   l_line_counter			NUMBER DEFAULT 0;
--**************************************************************
  l_return_status varchar2(10);
  errbuf varchar2(1000);
  retcode varchar2(1000);

/* Start of Changes to check for migration before Supercedence */

  l_migration_status BOOLEAN:= psp_general.is_effort_report_migrated;


  /*  End of Changes to check for migration before Supercedence   */

 BEGIN
  --- call to supercede Effort reports


IF l_migration_status THEN


-- Introduced the above for checking on migration status

  SUPERCEDE_ER(g_run_id,
               errbuf,
               retcode,
               p_source_type   ,
               p_source_code   ,
               p_time_period_id,
               p_batch_name,
               l_return_status);
  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;


End IF;




-- raise no_data_found;			Commented for bug fix 408937
  OPEN payroll_control_cur;
  LOOP
   FETCH payroll_control_cur INTO payroll_control_rec;
   IF payroll_control_cur%NOTFOUND THEN
     CLOSE payroll_control_cur;
     EXIT;
   END IF;


	---- Bug 2444657: removed the code that was trying to reset the
	--- distribution lines status code to N for summary lines with status=N
	 --- becos this is redundant, anyway the dist lines will be with 'N'
	 --- Also removed update statment that makes summary lines status = R
	  -- whenever status = 'N', becos there is a new phase Summarize

   -- This part is used to delete the rejected summary lines, mark the status_code
   -- in psp_payroll_controls to 'P' or 'N',delete the zero line reversal entry records
/* Bug 1929317.. Did some changes here...deleted the original code.....Look into previous version
   to compare ..  Basically to check the number of lines in dist lines ...instead of summing on dist amount
   for deciding wether to change control rec status to either 'P' or 'N'  */
   IF payroll_control_rec.source_type = 'O' OR payroll_control_rec.source_type = 'N' THEN

      DELETE FROM psp_distribution_lines
        WHERE distribution_amount = 0
        AND payroll_sub_line_id IN (
          select payroll_sub_line_id from psp_payroll_sub_lines where payroll_line_id IN (
          select payroll_line_id from psp_payroll_lines where payroll_control_id IN (
          select payroll_control_id from psp_payroll_controls where payroll_control_id=
           payroll_control_rec.payroll_control_id)));

     SELECT count(*)
     INTO l_line_counter
     FROM psp_distribution_lines  pdl,
          psp_payroll_sub_lines   ppsl,
          psp_payroll_lines       ppl
     WHERE ppl.payroll_control_id = payroll_control_rec.payroll_control_id
     AND   ppl.payroll_line_id = ppsl.payroll_line_id
     AND   ppsl.payroll_sub_line_id = pdl.payroll_sub_line_id;

     If l_line_counter = 0 then

       /* commented for 2445196
        -- delete any rejected summary lines
        DELETE FROM psp_summary_lines
        WHERE payroll_control_id = payroll_control_rec.payroll_control_id
        AND status_code = 'R';
       */

        -- update status_code to 'P' in psp_payroll_controls
        UPDATE psp_payroll_controls
        SET status_code = 'P',
            run_id = NULL,
	    phase = NULL
        WHERE payroll_control_id = payroll_control_rec.payroll_control_id;
     ELSE
        UPDATE psp_payroll_controls
        SET status_code = 'N',
            run_id = NULL
        WHERE payroll_control_id = payroll_control_rec.payroll_control_id;
     END IF;
   ELSIF payroll_control_rec.source_type = 'P' THEN

        -- delete the zero amount reversal lines
        DELETE FROM psp_pre_gen_dist_lines
        WHERE distribution_amount = 0
        AND reversal_entry_flag = 'Y'
        AND payroll_control_id = payroll_control_rec.payroll_control_id;

     SELECT count(*)
     INTO l_line_counter
     FROM psp_pre_gen_dist_lines ppgd
     WHERE ppgd.payroll_control_id = payroll_control_rec.payroll_control_id;

     IF l_line_counter = 0 THEN
       /* commented for  2445196
        DELETE FROM psp_summary_lines
        WHERE payroll_control_id = payroll_control_rec.payroll_control_id
        AND status_code = 'R';
       */

        UPDATE psp_payroll_controls
        SET status_code = 'P',
            run_id = NULL,
	    phase = NULL
        WHERE payroll_control_id = payroll_control_rec.payroll_control_id;
     ELSE
        UPDATE psp_payroll_controls
        SET status_code = 'N',
            run_id = NULL
        WHERE payroll_control_id = payroll_control_rec.payroll_control_id;
     END IF;
   END IF;
  END LOOP;
  COMMIT;

  /* Introduced as part of Bug fix #1776606 */
 EXCEPTION
	WHEN OTHERS THEN
		g_error_api_path := 'MARK_BATCH_END: ' || g_error_api_path;
		fnd_msg_pub.add_exc_msg('PSP_SUM_TRANS','MARK_BATCH_END');
		p_return_status := fnd_api.g_ret_sts_unexp_error;
		RAISE;
 END;
-------------------- CREATE GL SUM LINES -----------------------------------------------

 PROCEDURE create_gl_sum_lines(p_source_type     IN VARCHAR2,
                               p_source_code     IN VARCHAR2,
                               p_time_period_id  IN NUMBER,
                               p_batch_name      IN VARCHAR2,
			       p_business_group_id IN NUMBER,
			       p_set_of_books_id   IN NUMBER,
                               p_return_status  OUT NOCOPY VARCHAR2) IS

   CURSOR payroll_control_cur IS
   SELECT payroll_control_id,
          source_type,
          payroll_source_code,
          time_period_id,
          batch_name,
          gl_posting_override_date,
          business_group_id,
          set_of_books_id,
          currency_code -- Introduced for Bug 2916848 Ilo Mrc
   FROM   psp_payroll_controls
   WHERE source_type <> 'A'
   AND    run_id = g_run_id
   AND    (phase is null or
           phase in ('GMS_Tie_Back', 'GL_Tie_Back'));  ---- added for 2444657

   CURSOR gl_sum_lines_cursor(P_PAYROLL_CONTROL_ID  IN  NUMBER)  IS
   SELECT ppl.person_id,
          ppl.assignment_id,
          decode(pdl.reversal_entry_flag,'Y',ppl.gl_code_combination_id,NULL,
           nvl(pdl.suspense_auto_glccid,     --- 5080403
              nvl(pos.gl_code_combination_id,
                  nvl(pdl.auto_gl_code_combination_id,   --- added for 2663344
                  nvl(psl.gl_code_combination_id,
                  nvl(pod.gl_code_combination_id,
                  nvl(pea.gl_code_combination_id,
                      pdls.gl_code_combination_id))))))) gl_ccid,
          decode(pdl.reversal_entry_flag,'Y',decode(ppl.dr_cr_flag,'D','C','C','D'),NULL,ppl.dr_cr_flag) dr_cr_flag,
          pdl.effective_date,
          nvl(ppc.gl_posting_override_date, ppl.accounting_date)  accounting_date,
          nvl(ppl.exchange_rate_type,ppc.exchange_rate_type) exchange_rate_type, --- added for 3108109
          pdl.distribution_amount,
          pdl.distribution_line_id,
	  pdl.auto_gl_code_combination_id,
          'D' tab_flag,
	DECODE(g_dff_grouping_option, 'Y', DECODE(pdl.suspense_org_account_id, NULL, pdl.attribute_category, pos.attribute_category), NULL) attribute_category,	-- Introduced DFF columns for bug fix 2908859
	DECODE(g_dff_grouping_option, 'Y', DECODE(pdl.suspense_org_account_id, NULL, pdl.attribute1, pos.attribute8), NULL) attribute1,
	DECODE(g_dff_grouping_option, 'Y', DECODE(pdl.suspense_org_account_id, NULL, pdl.attribute2, pos.attribute8), NULL) attribute2,
	DECODE(g_dff_grouping_option, 'Y', DECODE(pdl.suspense_org_account_id, NULL, pdl.attribute3, pos.attribute8), NULL) attribute3,
	DECODE(g_dff_grouping_option, 'Y', DECODE(pdl.suspense_org_account_id, NULL, pdl.attribute4, pos.attribute8), NULL) attribute4,
	DECODE(g_dff_grouping_option, 'Y', DECODE(pdl.suspense_org_account_id, NULL, pdl.attribute5, pos.attribute8), NULL) attribute5,
	DECODE(g_dff_grouping_option, 'Y', DECODE(pdl.suspense_org_account_id, NULL, pdl.attribute6, pos.attribute8), NULL) attribute6,
	DECODE(g_dff_grouping_option, 'Y', DECODE(pdl.suspense_org_account_id, NULL, pdl.attribute7, pos.attribute8), NULL) attribute7,
	DECODE(g_dff_grouping_option, 'Y', DECODE(pdl.suspense_org_account_id, NULL, pdl.attribute8, pos.attribute8), NULL) attribute8,
	DECODE(g_dff_grouping_option, 'Y', DECODE(pdl.suspense_org_account_id, NULL, pdl.attribute9, pos.attribute9), NULL) attribute9,
	DECODE(g_dff_grouping_option, 'Y', DECODE(pdl.suspense_org_account_id, NULL, pdl.attribute10, pos.attribute10), NULL) attribute10
          ---decode(pdl.suspense_org_account_id, NULL, 'N', 'Y') Suspense_Flag  commented for 2663344
   FROM   psp_schedule_lines              psl,
          psp_organization_accounts       pod,
          psp_organization_accounts       pos,
          psp_element_type_accounts       pea,
          psp_default_labor_schedules     pdls,
          psp_payroll_controls            ppc,
          psp_payroll_lines               ppl,
          psp_payroll_sub_lines           ppsl,
          psp_distribution_lines          pdl
   WHERE  pdl.status_code = 'N'
   AND    pdl.payroll_sub_line_id = ppsl.payroll_sub_line_id
   AND    ppsl.payroll_line_id = ppl.payroll_line_id
   AND    ppl.payroll_control_id = ppc.payroll_control_id
   AND    pdl.gl_project_flag = 'G'
   AND    pdl.distribution_amount <> 0
   AND    ppc.payroll_control_id = p_payroll_control_id
   AND    ppc.business_group_id = p_business_group_id
   AND	  ppc.set_of_books_id = p_set_of_books_id
   AND    pdl.schedule_line_id = psl.schedule_line_id(+)
   AND    pdl.default_org_account_id = pod.organization_account_id(+)
   AND    pdl.element_account_id = pea.element_account_id(+)
   AND    pdl.org_schedule_id = pdls.org_schedule_id(+)
   AND    pdl.suspense_org_account_id = pos.organization_account_id(+)
   AND    pdl.cap_excess_glccid is null
   UNION
   SELECT ppg.person_id,
          ppg.assignment_id,
           nvl(ppg.suspense_auto_glccid,
          nvl(pos.gl_code_combination_id,
              ppg.gl_code_combination_id)) gl_ccid,
	  decode(ppg.reversal_entry_flag, 'Y', decode(ppg.dr_cr_flag, 'C', 'D', 'D', 'C'), ppg.dr_cr_flag) dr_cr_flag,
          ppg.effective_date,
          ppc.gl_posting_override_date accounting_date, --- 3108109
          ppc.exchange_rate_type, --- added for 3108109
          ppg.distribution_amount,
          ppg.pre_gen_dist_line_id distribution_line_id,
	  to_number(NULL)  auto_gl_code_combination_id, -- Place holder for auto pop details
          'P' tab_flag,
	DECODE(g_dff_grouping_option, 'Y', DECODE(ppg.suspense_org_account_id, NULL, ppg.attribute_category, pos.attribute_category), NULL) attribute_category,	-- Introduced DFF columns for bug fix 2908859
	DECODE(g_dff_grouping_option, 'Y', DECODE(ppg.suspense_org_account_id, NULL, ppg.attribute1, pos.attribute1), NULL) attribute1,
	DECODE(g_dff_grouping_option, 'Y', DECODE(ppg.suspense_org_account_id, NULL, ppg.attribute2, pos.attribute2), NULL) attribute2,
	DECODE(g_dff_grouping_option, 'Y', DECODE(ppg.suspense_org_account_id, NULL, ppg.attribute3, pos.attribute3), NULL) attribute3,
	DECODE(g_dff_grouping_option, 'Y', DECODE(ppg.suspense_org_account_id, NULL, ppg.attribute4, pos.attribute4), NULL) attribute4,
	DECODE(g_dff_grouping_option, 'Y', DECODE(ppg.suspense_org_account_id, NULL, ppg.attribute5, pos.attribute5), NULL) attribute5,
	DECODE(g_dff_grouping_option, 'Y', DECODE(ppg.suspense_org_account_id, NULL, ppg.attribute6, pos.attribute6), NULL) attribute6,
	DECODE(g_dff_grouping_option, 'Y', DECODE(ppg.suspense_org_account_id, NULL, ppg.attribute7, pos.attribute7), NULL) attribute7,
	DECODE(g_dff_grouping_option, 'Y', DECODE(ppg.suspense_org_account_id, NULL, ppg.attribute8, pos.attribute8), NULL) attribute8,
	DECODE(g_dff_grouping_option, 'Y', DECODE(ppg.suspense_org_account_id, NULL, ppg.attribute9, pos.attribute9), NULL) attribute9,
	DECODE(g_dff_grouping_option, 'Y', DECODE(ppg.suspense_org_account_id, NULL, ppg.attribute10, pos.attribute10), NULL) attribute10
          ---decode(ppg.suspense_org_Account_id, NULL, 'N', 'Y') Suspense_Flag   commented for 2663344
   FROM   psp_pre_gen_dist_lines     ppg,
          psp_organization_accounts  pos,
          psp_payroll_controls       ppc
   WHERE  ppg.status_code = 'N'
   /* changed following condition for bug 2007521 */
   AND    ((ppg.gl_code_combination_id IS NOT NULL  and pos.project_id is null)
          OR pos.gl_code_combination_id IS NOT NULL)
   AND    ppg.suspense_org_account_id = pos.organization_account_id(+)
   AND    ppg.payroll_control_id = p_payroll_control_id
   AND    ppg.business_group_id = p_business_group_id
   AND	  ppg.set_of_books_id = p_set_of_books_id
   AND    ppc.payroll_control_id = p_payroll_control_id
   UNION
   SELECT ppl.person_id,
          ppl.assignment_id,
          decode(pdl.reversal_entry_flag,'Y',ppl.gl_code_combination_id,NULL,
              nvl(pos.gl_code_combination_id,
                  nvl(pdl.auto_gl_code_combination_id, pdl.cap_excess_glccid))) gl_ccid,
          decode(pdl.reversal_entry_flag,'Y',decode(ppl.dr_cr_flag,'D','C','C','D'),NULL,ppl.dr_cr_flag) dr_cr_flag,
          pdl.effective_date,
          nvl(ppc.gl_posting_override_date, ppl.accounting_date)  accounting_date,
          nvl(ppl.exchange_rate_type,ppc.exchange_rate_type) exchange_rate_type, --- added for 3108109
          pdl.distribution_amount,
          pdl.distribution_line_id,
	  pdl.auto_gl_code_combination_id,
          'D' tab_flag,
	DECODE(g_dff_grouping_option, 'Y', DECODE(pdl.suspense_org_account_id, NULL, pdl.attribute_category, pos.attribute_category), NULL) attribute_category,
	DECODE(g_dff_grouping_option, 'Y', DECODE(pdl.suspense_org_account_id, NULL, pdl.attribute1, pos.attribute8), NULL) attribute1,
	DECODE(g_dff_grouping_option, 'Y', DECODE(pdl.suspense_org_account_id, NULL, pdl.attribute2, pos.attribute8), NULL) attribute2,
	DECODE(g_dff_grouping_option, 'Y', DECODE(pdl.suspense_org_account_id, NULL, pdl.attribute3, pos.attribute8), NULL) attribute3,
	DECODE(g_dff_grouping_option, 'Y', DECODE(pdl.suspense_org_account_id, NULL, pdl.attribute4, pos.attribute8), NULL) attribute4,
	DECODE(g_dff_grouping_option, 'Y', DECODE(pdl.suspense_org_account_id, NULL, pdl.attribute5, pos.attribute8), NULL) attribute5,
	DECODE(g_dff_grouping_option, 'Y', DECODE(pdl.suspense_org_account_id, NULL, pdl.attribute6, pos.attribute8), NULL) attribute6,
	DECODE(g_dff_grouping_option, 'Y', DECODE(pdl.suspense_org_account_id, NULL, pdl.attribute7, pos.attribute8), NULL) attribute7,
	DECODE(g_dff_grouping_option, 'Y', DECODE(pdl.suspense_org_account_id, NULL, pdl.attribute8, pos.attribute8), NULL) attribute8,
	DECODE(g_dff_grouping_option, 'Y', DECODE(pdl.suspense_org_account_id, NULL, pdl.attribute9, pos.attribute9), NULL) attribute9,
	DECODE(g_dff_grouping_option, 'Y', DECODE(pdl.suspense_org_account_id, NULL, pdl.attribute10, pos.attribute10), NULL) attribute10
   FROM   psp_payroll_controls            ppc,
          psp_payroll_lines               ppl,
          psp_payroll_sub_lines           ppsl,
          psp_organization_accounts       pos,
          psp_distribution_lines          pdl
   WHERE  pdl.status_code = 'N'
   AND    pdl.payroll_sub_line_id = ppsl.payroll_sub_line_id
   AND    ppsl.payroll_line_id = ppl.payroll_line_id
   AND    ppl.payroll_control_id = ppc.payroll_control_id
   AND    pdl.gl_project_flag = 'G'
   AND    pdl.distribution_amount <> 0
   AND    ppc.payroll_control_id = p_payroll_control_id
   AND    ppc.business_group_id = p_business_group_id
   AND	  ppc.set_of_books_id = p_set_of_books_id
   AND    pdl.suspense_org_account_id = pos.organization_account_id(+)
   AND    pdl.cap_excess_glccid is not null
   AND    pdl.reversal_entry_flag is null
   ORDER BY 1,2,3,4,6,7,12,13,14,15,16,17,18,19,20,21,22,5;
      --- order by accounting_date, exchange_rate_type for 3108109
      --- order by attribute_category, attribute1 through attribute 10 for BUG 6007017


--   l_sob_id			NUMBER(15) := FND_PROFILE.VALUE('PSP_SET_OF_BOOKS');  -- This comes as a param
   l_person_id			NUMBER(9);
   l_assignment_id		NUMBER(9);
   l_gl_ccid			NUMBER(15);
   l_dr_cr_flag			VARCHAR2(1);
   l_effective_date		DATE;
   l_distribution_amount	NUMBER;
   l_rec_count			NUMBER := 0;
   l_summary_amount		NUMBER := 0;

   l_summary_line_id		NUMBER(10);
   gl_sum_lines_rec		gl_sum_lines_cursor%ROWTYPE;

   l_attribute_category			VARCHAR2(30);			-- Introduced variables for storing DFF values for bug fix 2908859
   l_attribute1				VARCHAR2(150);
   l_attribute2				VARCHAR2(150);
   l_attribute3				VARCHAR2(150);
   l_attribute4				VARCHAR2(150);
   l_attribute5				VARCHAR2(150);
   l_attribute6				VARCHAR2(150);
   l_attribute7				VARCHAR2(150);
   l_attribute8				VARCHAR2(150);
   l_attribute9				VARCHAR2(150);
   l_attribute10			VARCHAR2(150);

   TYPE dist_id IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
   dist_line_id			dist_id;
   l_dist_line_id			NUMBER;
   i					BINARY_INTEGER := 0;
   j					NUMBER;
   l_return_status		VARCHAR2(10);
   payroll_control_rec		payroll_control_cur%ROWTYPE;
   l_precision			NUMBER;
   l_ext_precision		NUMBER;
   l_accounting_date            DATE;  --- added 6 variables for 3108109
   l_exchange_rate_type         VARCHAR2(30);
   l_value                      VARCHAR2(200);
   l_table                      VARCHAR2(100);
   l_period_end_date            DATE;
   l_begin_of_time              DATE := to_date('01/01/1900','dd/mm/yyyy');

 BEGIN
  OPEN payroll_control_cur;
  LOOP
   FETCH payroll_control_cur INTO payroll_control_rec;
   IF payroll_control_cur%NOTFOUND THEN
     CLOSE payroll_control_cur;
     EXIT;
   END IF;

      -- added for 3108109
     BEGIN
       SELECT end_date
       INTO l_period_end_date
       FROM per_time_periods
       WHERE time_period_id = payroll_control_rec.time_period_id;
     EXCEPTION
       WHEN NO_DATA_FOUND THEN
         l_value := 'Time Period Id = '||to_char(payroll_control_rec.time_period_id);
         l_table := 'PER_TIME_PERIODS';
         fnd_message.set_name('PSP','PSP_TR_VALUE_NOT_FOUND');
         fnd_message.set_token('VALUE',l_value);
         fnd_message.set_token('TABLE',l_table);
         fnd_msg_pub.add;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END;


-- Made the following call for Bug 2916848 to populate l_precision , l_ext_precision
   psp_general.get_currency_precision(payroll_control_rec.currency_code,l_precision,l_ext_precision);

   -- create balancing transactions for GL
   gl_balance_transaction(payroll_control_rec.source_type,
                          payroll_control_rec.payroll_control_id,
                          p_business_group_id,
                          p_set_of_books_id,
			  l_precision,-- Introduced for Bug 2916848
                          l_return_status);

   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   OPEN gl_sum_lines_cursor(payroll_control_rec.payroll_control_id);
   l_rec_count := 0;
   l_summary_amount := 0;
   i := 0;
   LOOP
     FETCH gl_sum_lines_cursor INTO gl_sum_lines_rec;
     l_rec_count := l_rec_count + 1;

     IF gl_sum_lines_cursor%ROWCOUNT = 0 THEN
       CLOSE gl_sum_lines_cursor;
       EXIT;
     ELSIF gl_sum_lines_cursor%NOTFOUND THEN
      update psp_payroll_controls set phase = 'Summarize_GL_Lines' ---2444657:changed from NULL
       where payroll_control_id = payroll_control_rec.payroll_control_id;
       CLOSE gl_sum_lines_cursor;
       EXIT;
     END IF;
     --

     IF l_rec_count = 1 THEN
       l_person_id		:= gl_sum_lines_rec.person_id;
       l_assignment_id		:= gl_sum_lines_rec.assignment_id;
       l_gl_ccid		:= gl_sum_lines_rec.gl_ccid;
       l_dr_cr_flag		:= gl_sum_lines_rec.dr_cr_flag;
       l_effective_date		:= nvl(payroll_control_rec.gl_posting_override_date,gl_sum_lines_rec.effective_date);
       l_accounting_date        := gl_sum_lines_rec.accounting_date;   -- added for 3108109
       l_exchange_rate_type     := gl_sum_lines_rec.exchange_rate_type;    --- added for 3108109
	l_attribute_category	:= gl_sum_lines_rec.attribute_category;		-- Introduced DFF columns for bug fix 2908859
	l_attribute1		:= gl_sum_lines_rec.attribute1;
	l_attribute2		:= gl_sum_lines_rec.attribute2;
	l_attribute3		:= gl_sum_lines_rec.attribute3;
	l_attribute4		:= gl_sum_lines_rec.attribute4;
	l_attribute5		:= gl_sum_lines_rec.attribute5;
	l_attribute6		:= gl_sum_lines_rec.attribute6;
	l_attribute7		:= gl_sum_lines_rec.attribute7;
	l_attribute8		:= gl_sum_lines_rec.attribute8;
	l_attribute9		:= gl_sum_lines_rec.attribute9;
	l_attribute10		:= gl_sum_lines_rec.attribute10;
     END IF;

     IF l_person_id <> gl_sum_lines_rec.person_id OR
        l_assignment_id <> gl_sum_lines_rec.assignment_id OR
        l_gl_ccid <> gl_sum_lines_rec.gl_ccid OR
        l_dr_cr_flag <> gl_sum_lines_rec.dr_cr_flag OR
	(NVL(l_attribute_category, 'NULL') <> NVL(gl_sum_lines_rec.attribute_category, 'NULL')) OR	-- Introduced DFF columns checks for bug fix 2908859
	(NVL(l_attribute1, 'NULL') <> NVL(gl_sum_lines_rec.attribute1, 'NULL')) OR
	(NVL(l_attribute2, 'NULL') <> NVL(gl_sum_lines_rec.attribute2, 'NULL')) OR
	(NVL(l_attribute3, 'NULL') <> NVL(gl_sum_lines_rec.attribute3, 'NULL')) OR
	(NVL(l_attribute4, 'NULL') <> NVL(gl_sum_lines_rec.attribute4, 'NULL')) OR
	(NVL(l_attribute5, 'NULL') <> NVL(gl_sum_lines_rec.attribute5, 'NULL')) OR
	(NVL(l_attribute6, 'NULL') <> NVL(gl_sum_lines_rec.attribute6, 'NULL')) OR
	(NVL(l_attribute7, 'NULL') <> NVL(gl_sum_lines_rec.attribute7, 'NULL')) OR
	(NVL(l_attribute8, 'NULL') <> NVL(gl_sum_lines_rec.attribute8, 'NULL')) OR
	(NVL(l_attribute9, 'NULL') <> NVL(gl_sum_lines_rec.attribute9, 'NULL')) OR
	(NVL(l_attribute10, 'NULL') <> NVL(gl_sum_lines_rec.attribute10, 'NULL')) OR
        nvl(l_accounting_date,l_begin_of_time) <>
             nvl(gl_sum_lines_rec.accounting_date,l_begin_of_time) OR  --------- added two condns for 3108109
        nvl(l_exchange_rate_type,'-999') <>
             nvl(gl_sum_lines_rec.exchange_rate_type,'-999') THEN

        -- insert into summary lines
        insert_into_summary_lines(
            l_summary_line_id,
		l_person_id,
		l_assignment_id,
            payroll_control_rec.time_period_id,
 		l_effective_date,
                nvl(l_accounting_date,l_period_end_date),
                l_exchange_rate_type,  --- added 2 vars for 3108109
            payroll_control_rec.source_type,
 		payroll_control_rec.payroll_source_code,
	    payroll_control_rec.set_of_books_id,
 		l_gl_ccid,
 		NULL,
 		NULL,
 		NULL,
 		NULL,
 		NULL,
 		round(l_summary_amount,l_precision), -- For Bug 2916848 Ilo Mrc Ehn
 		l_dr_cr_flag,
 		'N',
            payroll_control_rec.batch_name,
            payroll_control_rec.payroll_control_id,
	    payroll_control_rec.business_group_id,
		l_attribute_category,			-- Introduced DFF columns for bug fix 2908859
		l_attribute1,
		l_attribute2,
		l_attribute3,
		l_attribute4,
		l_attribute5,
		l_attribute6,
		l_attribute7,
		l_attribute8,
		l_attribute9,
		l_attribute10,
            l_return_status);

       IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;


       FOR j IN 1 .. dist_line_id.COUNT LOOP
         l_dist_line_id := dist_line_id(j);

         IF gl_sum_lines_rec.tab_flag = 'D' THEN
           UPDATE psp_distribution_lines
           SET summary_line_id = l_summary_line_id WHERE distribution_line_id = l_dist_line_id;
         ELSIF gl_sum_lines_rec.tab_flag = 'P' THEN
           UPDATE psp_pre_gen_dist_lines
           SET summary_line_id = l_summary_line_id WHERE pre_gen_dist_line_id = l_dist_line_id;
         END IF;
       END LOOP;

       -- initialise the summary amount and dist_line_id
       l_summary_amount := 0;
       dist_line_id.delete;
       i := 0;
     END IF;

     l_person_id			:= gl_sum_lines_rec.person_id;
     l_assignment_id		:= gl_sum_lines_rec.assignment_id;
     l_gl_ccid			:= gl_sum_lines_rec.gl_ccid;
     l_dr_cr_flag			:= gl_sum_lines_rec.dr_cr_flag;
     l_exchange_rate_type       := gl_sum_lines_rec.exchange_rate_type; --- added for 3108109
     l_accounting_date          := gl_sum_lines_rec.accounting_date;
	l_attribute_category	:= gl_sum_lines_rec.attribute_category;		-- Introduced DFF columns for bug fix 2908859
	l_attribute1		:= gl_sum_lines_rec.attribute1;
	l_attribute2		:= gl_sum_lines_rec.attribute2;
	l_attribute3		:= gl_sum_lines_rec.attribute3;
	l_attribute4		:= gl_sum_lines_rec.attribute4;
	l_attribute5		:= gl_sum_lines_rec.attribute5;
	l_attribute6		:= gl_sum_lines_rec.attribute6;
	l_attribute7		:= gl_sum_lines_rec.attribute7;
	l_attribute8		:= gl_sum_lines_rec.attribute8;
	l_attribute9		:= gl_sum_lines_rec.attribute9;
	l_attribute10		:= gl_sum_lines_rec.attribute10;
-- If gl_posting_override_date is given, use it first
     l_effective_date		:= nvl(payroll_control_rec.gl_posting_override_date,gl_sum_lines_rec.effective_date);
-- If gl_posting_override_date is given, use it first

     l_summary_amount := l_summary_amount + gl_sum_lines_rec.distribution_amount;
     i := i + 1;
     dist_line_id(i) := gl_sum_lines_rec.distribution_line_id;

   END LOOP;

   IF l_rec_count > 1 THEN
     -- insert into summary lines
     insert_into_summary_lines(
            l_summary_line_id,
		l_person_id,
		l_assignment_id,
            payroll_control_rec.time_period_id,
 		l_effective_date,
                nvl(l_accounting_date,l_period_end_date), --- added for 3108109
                l_exchange_rate_type,
            payroll_control_rec.source_type,
 		payroll_control_rec.payroll_source_code,
	    payroll_control_rec.set_of_books_id,
 		l_gl_ccid,
 		NULL,
 		NULL,
 		NULL,
 		NULL,
 		NULL,
 		round(l_summary_amount, l_precision),
 		l_dr_cr_flag,
 		'N',
            payroll_control_rec.batch_name,
            payroll_control_rec.payroll_control_id,
            payroll_control_rec.business_group_id,
		l_attribute_category,			-- Introduced DFF columns for bug fix 2908859
		l_attribute1,
		l_attribute2,
		l_attribute3,
		l_attribute4,
		l_attribute5,
		l_attribute6,
		l_attribute7,
		l_attribute8,
		l_attribute9,
		l_attribute10,
            l_return_status);


     IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;



     FOR j IN 1 .. dist_line_id.COUNT LOOP
       l_dist_line_id := dist_line_id(j);

       IF gl_sum_lines_rec.tab_flag = 'D' THEN
         UPDATE psp_distribution_lines
         SET summary_line_id = l_summary_line_id,
             status_code = 'N'
         WHERE distribution_line_id = l_dist_line_id;
       ELSIF gl_sum_lines_rec.tab_flag = 'P' THEN
         UPDATE psp_pre_gen_dist_lines
         SET summary_line_id = l_summary_line_id,
             status_code = 'N'
         WHERE pre_gen_dist_line_id = l_dist_line_id;
       END IF;
     END LOOP;

     dist_line_id.delete;
   END IF;

  END LOOP;
  --
  p_return_status := fnd_api.g_ret_sts_success;

 EXCEPTION

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     g_error_api_path := 'CREATE_GL_SUM_LINES:'||g_error_api_path;
     p_return_status := fnd_api.g_ret_sts_unexp_error;
   WHEN OTHERS THEN
     g_error_api_path := 'CREATE_GL_SUM_LINES:'||g_error_api_path;
     fnd_msg_pub.add_exc_msg('PSP_SUM_TRANS','CREATE_GL_SUM_LINES');
     p_return_status := fnd_api.g_ret_sts_unexp_error;

 END;


---------------------- I N S E R T   S T A T E M E N T  ------------------------------------
 PROCEDURE insert_into_summary_lines(
		P_SUMMARY_LINE_ID			OUT NOCOPY	NUMBER,
		P_PERSON_ID				IN	NUMBER,
		P_ASSIGNMENT_ID			IN	NUMBER,
		P_TIME_PERIOD_ID			IN	NUMBER,
 		P_EFFECTIVE_DATE			IN	DATE,
                P_ACCOUNTING_DATE               IN      DATE,   --- added 2 vars for 3108109
                P_EXCHANGE_RATE_TYPE            IN      VARCHAR2,
            P_SOURCE_TYPE			IN	VARCHAR2,
 		P_SOURCE_CODE			IN	VARCHAR2,
		P_SET_OF_BOOKS_ID			IN	NUMBER,
 		P_GL_CODE_COMBINATION_ID	IN	NUMBER,
 		P_PROJECT_ID			IN	NUMBER,
 		P_EXPENDITURE_ORGANIZATION_ID	IN	NUMBER,
 		P_EXPENDITURE_TYPE		IN	VARCHAR2,
 		P_TASK_ID				IN	NUMBER,
 		P_AWARD_ID				IN	NUMBER,
 		P_SUMMARY_AMOUNT			IN	NUMBER,
 		P_DR_CR_FLAG			IN	VARCHAR2,
 		P_STATUS_CODE			IN	VARCHAR2,
            P_INTERFACE_BATCH_NAME		IN	VARCHAR2,
		P_PAYROLL_CONTROL_ID		IN	NUMBER,
		P_BUSINESS_GROUP_ID		IN	NUMBER,
		p_attribute_category		IN	VARCHAR2,			-- Introduced DFF parameters for bug fix 2908859
		p_attribute1			IN	VARCHAR2,
		p_attribute2			IN	VARCHAR2,
		p_attribute3			IN	VARCHAR2,
		p_attribute4			IN	VARCHAR2,
		p_attribute5			IN	VARCHAR2,
		p_attribute6			IN	VARCHAR2,
		p_attribute7			IN	VARCHAR2,
		p_attribute8			IN	VARCHAR2,
		p_attribute9			IN	VARCHAR2,
		p_attribute10			IN	VARCHAR2,
        P_RETURN_STATUS			OUT NOCOPY   VARCHAR2,
		P_ORG_ID				IN	NUMBER DEFAULT NULL			-- R12 MOAc uptake
		) IS
            l_gms_posting_effective_date	DATE;
 BEGIN

-- Code added for Enhancement Employee Assignment with Zero Work Days
 IF P_PROJECT_ID IS NOT NULL THEN
 	l_gms_posting_effective_date:= p_effective_date;
 	psp_general.get_gms_effective_date(p_person_id,l_gms_posting_effective_date);
 END IF;
-- Code ended for Enhancement Employee Assignment with Zero Work Days

    SELECT PSP_SUMMARY_LINES_S.NEXTVAL
    INTO P_SUMMARY_LINE_ID
    FROM DUAL;
    INSERT INTO PSP_SUMMARY_LINES(
		SUMMARY_LINE_ID,
		PERSON_ID,
		ASSIGNMENT_ID,
		TIME_PERIOD_ID,
 		EFFECTIVE_DATE,
                ACCOUNTING_DATE, --- added 2 vars for 3108109
                EXCHANGE_RATE_TYPE,
 		GMS_POSTING_EFFECTIVE_DATE, /* New column added for Enhancement Employee Assignment with Zero Work Days */
            	SOURCE_TYPE,
 		SOURCE_CODE,
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
            	INTERFACE_BATCH_NAME,
            	PAYROLL_CONTROL_ID,
		BUSINESS_GROUP_ID,
		LAST_UPDATE_DATE,
		LAST_UPDATED_BY,
		LAST_UPDATE_LOGIN,
		CREATED_BY,
		CREATION_DATE,
		ACTUAL_SUMMARY_AMOUNT,   --For Bug 2496661
		attribute_category,				-- Introduced for bug fix 2908859
		attribute1,
		attribute2,
		attribute3,
		attribute4,
		attribute5,
		attribute6,
		attribute7,
		attribute8,
		attribute9,
		attribute10,
		org_id			-- R12 MOAc uptake
		)
    VALUES(
            P_SUMMARY_LINE_ID,
		P_PERSON_ID,
		P_ASSIGNMENT_ID,
		P_TIME_PERIOD_ID,
 		P_EFFECTIVE_DATE,
                P_ACCOUNTING_DATE,  -- added 2 vars for 3108109
                P_EXCHANGE_RATE_TYPE,
 		L_GMS_POSTING_EFFECTIVE_DATE, /* New column added for Enhancement Employee Assignment with Zero Work Days */
            	P_SOURCE_TYPE,
 		P_SOURCE_CODE,
		P_SET_OF_BOOKS_ID,
 		P_GL_CODE_COMBINATION_ID,
 		P_PROJECT_ID,
 		P_EXPENDITURE_ORGANIZATION_ID,
 		P_EXPENDITURE_TYPE,
 		P_TASK_ID,
 		P_AWARD_ID,
 		P_SUMMARY_AMOUNT,
 		P_DR_CR_FLAG,
 		P_STATUS_CODE,
            P_INTERFACE_BATCH_NAME,
            P_PAYROLL_CONTROL_ID,
		P_BUSINESS_GROUP_ID,
		SYSDATE,
		FND_GLOBAL.USER_ID,
		FND_GLOBAL.LOGIN_ID,
		FND_GLOBAL.USER_ID,
		SYSDATE,
		DECODE(P_PROJECT_ID, NULL,P_SUMMARY_AMOUNT, DECODE(P_DR_CR_FLAG,'C',0 - P_SUMMARY_AMOUNT,P_SUMMARY_AMOUNT)), --For Bug 2496661
		p_attribute_category,				-- Introduced for bug fix 2908859
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
		p_org_id			-- R12 MOAC uptake
		);
    --
    p_return_status := fnd_api.g_ret_sts_success;
 EXCEPTION
   WHEN OTHERS THEN
      --dbms_output.put_line('Errrrrrrrrrrrrrrrrrrrrrrrrrrorrrrrrrrrrr.........');
      g_error_api_path := 'INSERT_INTO_SUMMARY_LINES:'||g_error_api_path;
      fnd_msg_pub.add_exc_msg('PSP_SUM_TRANS','INSERT_INTO_SUMMARY_LINES');
      p_return_status := fnd_api.g_ret_sts_unexp_error;
 END;

------------------------ GL INTERFACE --------------------------------------------------

 PROCEDURE transfer_to_gl_interface(p_source_type     IN VARCHAR2,
                                    p_source_code     IN VARCHAR2,
                                    p_time_period_id  IN NUMBER,
                                    p_batch_name      IN VARCHAR2,
				    p_business_group_id IN NUMBER,
				    p_set_of_books_id   IN NUMBER,
                                    p_return_status  OUT NOCOPY VARCHAR2) IS

 /* Broke the gl_batch_cursor into gl_batch_cursor,gl_payroll_control_cursor  for Bug 3112053 */
   CURSOR gl_batch_cursor IS
   SELECT DISTINCT source_type,
          payroll_source_code,
          time_period_id,
          batch_name,
          phase  --- 2444657, to separate the old and new gl imports
                 --- S and T can pull control recs with statuses 'I' and 'N' now
   FROM   psp_payroll_controls
   WHERE  status_code = 'I'
   AND    source_type <> 'A'
   AND    run_id = g_run_id
   AND    phase in ('Summarize_GL_Lines', 'Submitted_JI_Request');  --- 2444657: added the condition


   CURSOR gl_payroll_control_cursor(p_source_type in varchar2, p_source_code in varchar2,
				     p_time_period_id in number, p_batch_name in varchar2,
                                     p_phase varchar2) IS

   SELECT payroll_control_id,
	  currency_code,
	  exchange_rate_type,
          phase    --- 2444657: added
   FROM   psp_payroll_controls
   WHERE  source_type = p_source_type
   AND    payroll_source_code = p_source_code
   AND    time_period_id = p_time_period_id
   AND    nvl(batch_name,'N') = nvl(nvl(p_batch_name,batch_name),'N')
   AND    (dist_dr_amount IS NOT NULL OR dist_cr_amount IS NOT NULL)
   AND    status_code = 'I'
   AND    source_type <> 'A'
   AND    business_group_id = p_business_group_id
   AND    set_of_books_id = p_set_of_books_id
   AND    run_id = g_run_id
   AND    phase = p_phase;  --- 2444657:  added the condition;

/* End of code changes for bug 3112053 */

   CURSOR gl_interface_cursor(l_payroll_control_id	IN	NUMBER) IS
   SELECT psl.summary_line_id,
          psl.source_code,
          psl.effective_date,
          psl.accounting_date, -- added 2 cols for 3108109
          psl.exchange_Rate_type,
          psl.set_of_books_id,
          psl.gl_code_combination_id,
          psl.summary_amount,
          psl.dr_cr_flag,
          psl.attribute1,
          psl.attribute2,
          psl.attribute3,
          psl.attribute4,
          psl.attribute5,
          psl.attribute6,
          psl.attribute7,
          psl.attribute8,
          psl.attribute9,
          psl.attribute10,
          psl.attribute11,
          psl.attribute12,
          psl.attribute13,
          psl.attribute14,
          psl.attribute15,
          psl.attribute16,
          psl.attribute17,
          psl.attribute18,
          psl.attribute19,
          psl.attribute20,
          psl.attribute21,
          psl.attribute22,
          psl.attribute23,
          psl.attribute24,
          psl.attribute25,
          psl.attribute26,
          psl.attribute27,
          psl.attribute28,
          psl.attribute29,
          psl.attribute30
   FROM  psp_summary_lines  psl
   WHERE psl.status_code = 'N'
   AND   psl.gl_code_combination_id IS NOT NULL
   AND   psl.payroll_control_id = l_payroll_control_id;

   gl_batch_rec			gl_batch_cursor%ROWTYPE;
   gl_payroll_control_rec	gl_payroll_control_cursor%ROWTYPE; -- Introduced for Bug 3112053
   gl_interface_rec		gl_interface_cursor%ROWTYPE;

   l_user_je_source_name	VARCHAR2(25);
   l_user_je_category_name	VARCHAR2(25);
   l_period_name		VARCHAR2(35);
   l_period_end_date            DATE; ------ Bug 2663344: reverted commenting
   l_encumbrance_type_id	NUMBER(15);
   l_entered_dr			NUMBER;
   l_entered_cr			NUMBER;
   l_group_id			NUMBER;
   l_int_run_id			NUMBER;
   l_reference1			VARCHAR2(100);
   l_reference4			VARCHAR2(100);
   l_return_status		VARCHAR2(10);
   req_id			NUMBER(15);
   call_status			BOOLEAN;
   rphase			VARCHAR2(30);
   rstatus			VARCHAR2(30);
   dphase			VARCHAR2(30);
   dstatus			VARCHAR2(30);
   message			VARCHAR2(240);
   p_errbuf			VARCHAR2(32767);
   p_retcode			VARCHAR2(32767);
   return_back			EXCEPTION;
   l_rec_count			NUMBER := 0;
   l_error			VARCHAR2(100);
   l_product			VARCHAR2(3);
   l_value			VARCHAR2(200);
   l_table			VARCHAR2(100);
 BEGIN

   -- get the source name
   get_gl_je_sources(l_user_je_source_name,
                     l_return_status);
   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- get the category name
   get_gl_je_categories(l_user_je_category_name,
                        l_return_status);
   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   /* Changed the following code for Bug 3112053 , so as to submit one journal import for a batch having same
      source_code,source_type,time_period_id,batch_name combination */

   OPEN gl_batch_cursor;
   LOOP

     FETCH gl_batch_cursor INTO gl_batch_rec;

     IF gl_batch_cursor%NOTFOUND THEN
        CLOSE gl_batch_cursor;
        EXIT;
     END IF;

     -- get the group_id

     SELECT 	gl_interface_control_s.nextval
     INTO 	l_group_id
     FROM 	dual;

     BEGIN
       --- uncommented the end date for 2663344
       SELECT substr(period_name,1,35),end_date
       INTO l_period_name, l_period_end_date
       FROM per_time_periods
       WHERE time_period_id = gl_batch_rec.time_period_id;
     EXCEPTION
       WHEN NO_DATA_FOUND THEN
         l_value := 'Time Period Id = '||to_char(gl_batch_rec.time_period_id);
         l_table := 'PER_TIME_PERIODS';
         fnd_message.set_name('PSP','PSP_TR_VALUE_NOT_FOUND');
         fnd_message.set_token('VALUE',l_value);
         fnd_message.set_token('TABLE',l_table);
         fnd_msg_pub.add;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END;

   If gl_batch_rec.phase = 'Summarize_GL_Lines' then --- added for 2444657
     l_reference1 := gl_batch_rec.source_type||':'||gl_batch_rec.payroll_source_code||':'||l_period_name||':'||gl_batch_rec.batch_name;

       l_reference4 := 'LD ACTUALS DISTRIBUTION';

     OPEN gl_payroll_control_cursor(gl_batch_rec.source_type, gl_batch_rec.payroll_source_code,
				    gl_batch_rec.time_period_id, gl_batch_rec.batch_name, gl_batch_rec.phase);

	l_rec_count := 0;

	LOOP
		FETCH gl_payroll_control_cursor INTO gl_payroll_control_rec;
		EXIT WHEN gl_payroll_control_cursor%NOTFOUND;
		-- update psp_summary_lines with group_id

		UPDATE psp_summary_lines
     		SET group_id = l_group_id
     		WHERE status_code = 'N'
     		AND   gl_code_combination_id IS NOT NULL
     		AND   payroll_control_id = gl_payroll_control_rec.payroll_control_id;

      		OPEN gl_interface_cursor(gl_payroll_control_rec.payroll_control_id);
     		LOOP
		       FETCH gl_interface_cursor INTO gl_interface_rec;
		       IF gl_interface_cursor%NOTFOUND THEN
		          CLOSE gl_interface_cursor;
         		  EXIT;
		       END IF;

       		       l_rec_count := l_rec_count + 1;

       			IF gl_interface_rec.dr_cr_flag = 'D' THEN
		           l_entered_dr := gl_interface_rec.summary_amount;
                 	   l_entered_cr := NULL;
       			ELSIF gl_interface_rec.dr_cr_flag = 'C' THEN
         		   l_entered_dr := NULL;
         		   l_entered_cr := gl_interface_rec.summary_amount;
       			END IF;

      -- dbms_output.put_line('Inserting into gl interface .............');

      -- Changed The parameter g_currency_code to gl_batch_rec.currency_code, Introduced exchange_rate_type
      -- and conversion_date for Bug fix 2916848
       			insert_into_gl_interface(
		    	  P_SET_OF_BOOKS_ID, GL_INTERFACE_REC.EFFECTIVE_DATE,
			  gl_payroll_control_rec.CURRENCY_CODE,
                	  L_USER_JE_CATEGORY_NAME,L_USER_JE_SOURCE_NAME,L_ENCUMBRANCE_TYPE_ID,
		          GL_INTERFACE_REC.GL_CODE_COMBINATION_ID,L_ENTERED_DR,L_ENTERED_CR,
                          L_GROUP_ID,L_REFERENCE1,L_REFERENCE1,L_REFERENCE4,
                          GL_INTERFACE_REC.SUMMARY_LINE_ID,L_REFERENCE4,
                	  GL_INTERFACE_REC.ATTRIBUTE1,GL_INTERFACE_REC.ATTRIBUTE2,
                	  GL_INTERFACE_REC.ATTRIBUTE3,GL_INTERFACE_REC.ATTRIBUTE4,
                	  GL_INTERFACE_REC.ATTRIBUTE5,GL_INTERFACE_REC.ATTRIBUTE6,
		          GL_INTERFACE_REC.ATTRIBUTE7,GL_INTERFACE_REC.ATTRIBUTE8,
                 	  GL_INTERFACE_REC.ATTRIBUTE9,GL_INTERFACE_REC.ATTRIBUTE10,
                	  GL_INTERFACE_REC.ATTRIBUTE11,GL_INTERFACE_REC.ATTRIBUTE12,
                	  GL_INTERFACE_REC.ATTRIBUTE13,GL_INTERFACE_REC.ATTRIBUTE14,
                	  GL_INTERFACE_REC.ATTRIBUTE15,GL_INTERFACE_REC.ATTRIBUTE16,
		    	  GL_INTERFACE_REC.ATTRIBUTE17,GL_INTERFACE_REC.ATTRIBUTE18,
                	  GL_INTERFACE_REC.ATTRIBUTE19,GL_INTERFACE_REC.ATTRIBUTE20,
                	  GL_INTERFACE_REC.ATTRIBUTE21,GL_INTERFACE_REC.ATTRIBUTE22,
                	  GL_INTERFACE_REC.ATTRIBUTE23,GL_INTERFACE_REC.ATTRIBUTE24,
                	  GL_INTERFACE_REC.ATTRIBUTE25,GL_INTERFACE_REC.ATTRIBUTE26,
		    	  GL_INTERFACE_REC.ATTRIBUTE27,GL_INTERFACE_REC.ATTRIBUTE28,
                	  GL_INTERFACE_REC.ATTRIBUTE29,GL_INTERFACE_REC.ATTRIBUTE30,
			  GL_INTERFACE_REC.EXCHANGE_RATE_TYPE,  -- modified for 3108109
                          GL_INTERFACE_REC.ACCOUNTING_DATE,
			-- Introduced for Bug 2916848
                	  L_RETURN_STATUS);

       			IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         		--dbms_output.put_line('Faaaaaaiiiiiiilllllllleeeeeeeeeddddddd......');
         	   	   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	        	END IF;

     		END LOOP; -- End of gl_interface_cursor

	END LOOP; -- End of gl_payroll_control_cursor
	CLOSE gl_payroll_control_cursor;

	else    --- 2444657 ...phase = Submitted_JI_Request
                 select group_id
                 into l_group_id
                 from psp_summary_lines
                 where payroll_control_id in
                     (SELECT payroll_control_id
                       FROM   psp_payroll_controls
                      WHERE  source_type = gl_batch_rec.source_type
                        AND    payroll_source_code = gl_batch_rec.payroll_source_code
                        AND    time_period_id = gl_batch_rec.time_period_id
                        AND    nvl(batch_name,'N') = nvl(nvl(gl_batch_rec.batch_name,batch_name),'N')
                        AND    (dist_dr_amount IS NOT NULL OR dist_cr_amount IS NOT NULL)
                        AND    status_code = 'I'
                        AND    business_group_id = p_business_group_id
                        AND    set_of_books_id = p_set_of_books_id
                        AND    run_id = g_run_id
                        AND    phase =  'Submitted_JI_Request')
                   and gl_code_combination_id is not null
                   and rownum = 1;
    end if;  --- 2444657

    IF l_rec_count > 0  and gl_batch_rec.phase = 'Summarize_GL_Lines' THEN   ---added phase for 2444657

     	-- Call the gather table statistics here....
     	BEGIN

       		FND_STATS.Gather_Table_Stats(ownname => 'GL',
				    	     tabname => 'GL_INTERFACE');
        	/* commented for , 2476829
			  		     percent => 10,
				    	     tmode   => 'TEMPORARY'); */

     	EXCEPTION

       	WHEN others THEN
	          NULL;
     	END;

    	 -- insert into gl_interface_control

     	SELECT 	GL_JOURNAL_IMPORT_S.NEXTVAL
     	INTO 	l_int_run_id
     	FROM 	dual;

     	INSERT into gl_interface_control(je_source_name,status,interface_run_id,
        				 group_id,set_of_books_id)
       		VALUES	(l_user_je_source_name, 'S',l_int_run_id,
                  	 l_group_id,p_set_of_books_id);

	  --dbms_output.put_line('Calling GL .............');

     	req_id := fnd_request.submit_request(
	    			'SQLGL',
         			'GLLEZL',
         			'',
         			'',
         			FALSE,
           			to_char(l_int_run_id),
--     	       			to_char(l_sob_id), -- Changed for MO
            			to_char(p_set_of_books_id),
           			'N',
          			'',
          			'', -- added for bug fix 2365769
            		      	g_enable_enc_summ_gl,   --      changed from '' for bug 2259310
          			'W'    -- removed extra 'N' for bug 2365769	Changed 'N' tp 'W' for bug fix 2908859
           			);

     	IF req_id = 0 THEN

       		fnd_message.set_name('PSP','PSP_TR_GL_IMP_FAILED');
       		fnd_msg_pub.add;
       		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

     	ELSE

		-- Added the update for Rollback purposes.
       		UPDATE 	psp_payroll_controls
       		SET 	phase = 'Submitted_JI_Request'
--	Introduced selective payroll control filter for bug fix 3157895
		WHERE  source_type = NVL(gl_batch_rec.source_type, source_type)
		AND    payroll_source_code = NVL(gl_batch_rec.payroll_source_code, payroll_source_code)
		AND    time_period_id = NVL(gl_batch_rec.time_period_id, time_period_id)
		AND    NVL(batch_name,'N') = NVL(NVL(gl_batch_rec.batch_name, batch_name), 'N')
		AND    status_code = 'I'
		AND    business_group_id = p_business_group_id
		AND    set_of_books_id = p_set_of_books_id
		AND    run_id = g_run_id;
		commit;

            gl_batch_rec.phase := 'Submitted_JI_Request';   ---2444657
       		call_status := fnd_concurrent.wait_for_request(req_id, 20, 0,
                		rphase, rstatus, dphase, dstatus, message);

       		IF call_status = FALSE THEN

         	  fnd_message.set_name('PSP','PSP_TR_GL_IMP_FAILED');
         	  fnd_msg_pub.add;
         	  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

       		END IF;

     	END IF; -- End for check req_id = 0
       END IF; --- 2444657

	/* Performing Gl tie Back for a set of control_ids having the same source_type,
	  payroll_source_code, time_period_id, batch_name combination */


		OPEN gl_payroll_control_cursor(gl_batch_rec.source_type,
		     gl_batch_rec.payroll_source_code, gl_batch_rec.time_period_id,
		     gl_batch_rec.batch_name, gl_batch_rec.phase);
		LOOP
			FETCH gl_payroll_control_cursor INTO gl_payroll_control_rec;
			EXIT WHEN gl_payroll_control_cursor%NOTFOUND;


    	-- mark the successfully transferred records as 'A' in psp_summary_lines and psp_distribution_lines
    	-- and transfer the successful records to the history table
  	-- 1874696:changed l_period_end_date to NULL in tie back call
  	-- Bug 22663344 reverted null value to l_period_end_date
     			gl_tie_back(gl_payroll_control_rec.payroll_control_id,
		    	    	gl_batch_rec.source_type,
                    	    	l_period_end_date,
		            	l_group_id,
		    	    	p_business_group_id,
		      	    	p_set_of_books_id,
		    	    	'N',
		    	    	l_return_status);

     		/* Bug 1617846 LD Recovery LOV not showing up fialed S and T */
     		/* introduced ELSE clause */

     			IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
				CLOSE gl_payroll_control_cursor;
        			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		     	END IF;

		END LOOP;
		CLOSE gl_payroll_control_cursor;

     		COMMIT;

   END LOOP; -- End of gl_batch_csr

   /* End of code changes for Bug 3112053 */

   p_return_status := fnd_api.g_ret_sts_success;

EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     --dbms_output.put_line('Gone to one level top ..................');
     g_error_api_path := 'TRANSFER_TO_GL_INTERFACE:'||g_error_api_path;
     p_return_status := fnd_api.g_ret_sts_unexp_error;

   WHEN RETURN_BACK THEN
     p_return_status := fnd_api.g_ret_sts_success;

   WHEN OTHERS THEN
     g_error_api_path := 'TRANSFER_TO_GL_INTERFACE:'||g_error_api_path;
     fnd_msg_pub.add_exc_msg('PSP_SUM_TRANS','TRANSFER_TO_GL_INTERFACE');
     p_return_status := fnd_api.g_ret_sts_unexp_error;
 END;

---------------------- GET_GL_JE_SOURCES --------------------------------------------------
 PROCEDURE get_gl_je_sources(P_USER_JE_SOURCE_NAME  OUT NOCOPY  VARCHAR2,
                             P_RETURN_STATUS        OUT NOCOPY  VARCHAR2) IS
   l_error		VARCHAR2(100);
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
    g_error_api_path := 'GL_JE_SOURCES:'||g_error_api_path;
    fnd_msg_pub.add_exc_msg('PSP_SUM_TRANS','GL_JE_SOURCES');
    p_return_status := fnd_api.g_ret_sts_unexp_error;
 END;

---------------------- GET_GL_CATEGORIES --------------------------------------------------
 PROCEDURE get_gl_je_categories(P_USER_JE_CATEGORY_NAME  OUT NOCOPY  VARCHAR2,
                                P_RETURN_STATUS          OUT NOCOPY  VARCHAR2) IS
   l_error		VARCHAR2(100);
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
    g_error_api_path := 'GL_JE_CATEGORY_NAME:'||g_error_api_path;
    fnd_msg_pub.add_exc_msg('PSP_SUM_TRANS','GL_JE_CATEGORY_NAME');
    p_return_status := fnd_api.g_ret_sts_unexp_error;
 END;

---------------------- GET_ENCUM_TYPE_ID -----------------------------------------------
 PROCEDURE get_encum_type_id(P_ENCUMBRANCE_TYPE_ID  OUT NOCOPY  VARCHAR2,
                             P_RETURN_STATUS        OUT NOCOPY  VARCHAR2) IS
   l_error		VARCHAR2(100);
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
    g_error_api_path := 'ENCUMBRANCE_TYPE_ID:'||g_error_api_path;
    fnd_msg_pub.add_exc_msg('PSP_SUM_TRANS','ENCUMBRANCE_TYPE_ID');
    p_return_status := fnd_api.g_ret_sts_unexp_error;
 END;


-------------------- GL TIE BACK -----------------------------------------------------
 PROCEDURE gl_tie_back(p_payroll_control_id IN	NUMBER,
                       p_source_type        IN  VARCHAR2,
                       p_period_end_date    IN  DATE,
                       p_group_id		  IN	NUMBER,
		       p_business_group_id  IN NUMBER,
		       p_set_of_books_id    IN NUMBER,
		       p_mode               IN VARCHAR2,	--Introduced as part of Bug fix #1776606
                       p_return_status	 OUT NOCOPY	VARCHAR2) IS
   CURSOR gl_tie_back_success_cur IS
   SELECT summary_line_id,
          dr_cr_flag,summary_amount
   FROM   psp_summary_lines
   WHERE  group_id = p_group_id
     AND  payroll_control_id = p_payroll_control_id;

   CURSOR gl_tie_back_reject_cur IS
   SELECT status,
          reference6
   FROM   gl_interface
   WHERE  group_id = p_group_id
     AND  set_of_books_id = p_set_of_books_id
     AND  user_je_source_name = 'OLD'
     AND reference6 in(select summary_line_id FROM psp_summary_lines   -- Bug 7376898
                              WHERE GROUP_ID = p_group_id
                              AND payroll_control_id = p_payroll_control_id);


   CURSOR assign_susp_ac_cur(P_SUMMARY_LINE_ID	IN	NUMBER) IS
   SELECT pdl.rowid,
	  pdl.distribution_line_id line_id,
          pdl.distribution_date,
          pdl.suspense_org_account_id,
          pdl.reversal_entry_flag,
          pdl.effective_date	-- Bug 7040943 Added
   FROM   psp_distribution_lines pdl
   WHERE  pdl.summary_line_id = p_summary_line_id
   UNION
   SELECT ppgd.rowid,
	  ppgd.pre_gen_dist_line_id line_id,
          ppgd.distribution_date,
          ppgd.suspense_org_account_id,
          ppgd.reversal_entry_flag,
          ppgd.effective_date    -- Bug 7040943 Added
   FROM   psp_pre_gen_dist_lines ppgd
   WHERE  ppgd.summary_line_id = p_summary_line_id;

-- Get the Organization details ...

   CURSOR get_susp_org_cur(P_ORG_ID	IN	VARCHAR2) IS
   SELECT hou.organization_id, hou.name, poa.gl_code_combination_id
     FROM hr_all_organization_units hou, psp_organization_accounts poa
    WHERE hou.organization_id = poa.organization_id
      AND poa.business_group_id = p_business_group_id
      AND poa.set_of_books_id = p_set_of_books_id
      AND poa.organization_account_id = p_org_id;

   CURSOR get_org_id_cur(P_LINE_ID	IN	NUMBER) IS
   SELECT hou.organization_id, hou.name
   FROM   hr_all_organization_units hou,
  	  per_assignments_f paf,
  	  psp_payroll_lines ppl,
  	  psp_payroll_sub_lines ppsl,
          psp_distribution_lines pdl
   WHERE  pdl.payroll_sub_line_id = ppsl.payroll_sub_line_id
   AND    ppsl.payroll_line_id = ppl.payroll_line_id
   AND    pdl.distribution_line_id = p_line_id
   AND    ppl.assignment_id = paf.assignment_id
   AND    pdl.distribution_date BETWEEN paf.effective_start_date AND paf.effective_end_date
   AND    paf.organization_id = hou.organization_id
   AND    pdl.distribution_date between
		hou.date_from and nvl(hou.date_to,pdl.distribution_date)
   UNION
   SELECT hou.organization_id, hou.name
   FROM   hr_all_organization_units hou,
          per_assignments_f paf,
          psp_pre_gen_dist_lines ppgd
   WHERE  ppgd.pre_gen_dist_line_id = p_line_id
   AND    ppgd.assignment_id = paf.assignment_id
   AND    ppgd.distribution_date BETWEEN paf.effective_start_date AND paf.effective_end_date
   AND	  paf.organization_id = hou.organization_id;

  l_orig_org_name	hr_all_organization_units_tl.name%TYPE;	-- Bug 2447912: Modified declaration
  l_orig_org_id		number;

-- End of Get org id cursor  Ravindra

   CURSOR org_susp_ac_cur(P_ORGANIZATION_ID	IN	NUMBER,
                          P_DISTRIBUTION_DATE	IN	DATE) IS
   SELECT poa.organization_account_id,
          poa.gl_code_combination_id,
          poa.project_id,
          poa.award_id,
          poa.task_id,
          poa.expenditure_organization_id,
          poa.expenditure_type
   FROM   psp_organization_accounts poa
   WHERE  poa.organization_id = p_organization_id
   AND    poa.account_type_code = 'S'
   AND    poa.business_group_id = p_business_group_id
   AND    poa.set_of_books_id = p_set_of_books_id
   AND    p_distribution_date BETWEEN poa.start_date_active AND
                                      nvl(poa.end_date_active,p_distribution_date);


-- CURSOR global_susp_ac_cur(P_DISTRIBUTION_DATE	IN	DATE) IS
   CURSOR global_susp_ac_cur(P_ORGANIZATION_ACCOUNT_ID  IN	NUMBER) IS  --BUG 2056877
   SELECT poa.organization_account_id,
          poa.gl_code_combination_id,
          poa.project_id,
          poa.award_id,
          poa.task_id,
          poa.expenditure_organization_id,
          poa.expenditure_type
   FROM   psp_organization_accounts poa
   WHERE
/* poa.account_type_code = 'G'
   AND    poa.business_group_id = p_business_group_id
   AND    poa.set_of_books_id = p_set_of_books_id
   AND    p_distribution_date BETWEEN poa.start_date_active AND
                                      nvl(poa.end_date_active,p_distribution_date);  Bug 2056877.*/
          organization_account_id = p_organization_account_id; --Added for bug 2056877.

   l_organization_name		hr_all_organization_units_tl.name%TYPE;	-- Bug 2447912: Modified declaration
   l_organization_id		NUMBER(15);
   l_rowid				ROWID;
   l_assignment_id		NUMBER(15);
   l_distribution_date		DATE;
   l_suspense_org_account_id  NUMBER(9);
   l_reversal_entry_flag	VARCHAR2(1);
   l_lines_glccid			NUMBER(15);
   --
   l_organization_account_id	NUMBER(9);
   l_susp_glccid			NUMBER(15);
   l_project_id			NUMBER(15);
   l_award_id			NUMBER(15);
   l_task_id                    NUMBER(15);
   --
   l_status				VARCHAR2(50);
   l_reference6			VARCHAR2(100);
   --
   l_cnt_gl_interface		NUMBER;
   l_summary_line_id		NUMBER(10);
   l_gl_project_flag		VARCHAR2(1);
   l_suspense_ac_failed		VARCHAR2(1) := 'N';
   l_reversal_ac_failed		VARCHAR2(1) := 'N';
   l_suspense_ac_not_found	VARCHAR2(1) := 'N';
   l_susp_ac_found		VARCHAR2(10) := 'TRUE';
   l_summary_amount		NUMBER;
   l_dr_summary_amount		NUMBER := 0;
   l_cr_summary_amount		NUMBER := 0;
   l_dr_cr_flag			VARCHAR2(1);
   l_effective_date		DATE;
   x_susp_failed_org_name	hr_all_organization_units_tl.name%TYPE;	-- Bug 2447912: Modified declaration
   x_susp_failed_status		VARCHAR2(50);
   x_susp_failed_date		DATE;
   x_lines_glccid			NUMBER(15);
   x_susp_nf_org_name		hr_all_organization_units_tl.name%TYPE;	-- Bug 2447912: Modified declaration
   x_susp_nf_date			DATE;
   l_return_status		VARCHAR2(10);
   x_line_id			NUMBER;
   l_no_run			number;
   l_return_value               VARCHAR2(30); --Added for bug 2056877.
   no_profile_exists            EXCEPTION;    --Added for bug 2056877.
   no_val_date_matches          EXCEPTION;    --Added for bug 2056877.
   no_global_acct_exists        EXCEPTION;    --Added for bug 2056877.
   l_user_je_source_name             varchar2(25); ---added for 2445196
   l_susp_exception               varchar2(50); -- 2479579
   l_expenditure_type           varchar2(100);  -- introduced vars for 5080403
   l_exp_org_id                 number;
   l_new_expenditure_type       varchar2(100);
   l_new_glccid                 number;
   l_acct_type                  varchar2(1);
   l_auto_pop_status            varchar2(100);
   l_auto_status                varchar2(100);
   l_person_id                  number;
   l_element_type_id            number;
   l_assignment_number          varchar2(100);
   l_element_type               varchar2(200);
   l_person_name                varchar2(300);
   l_account                    varchar2(1000);
   l_auto_org_name              hr_all_organization_units_tl.name%TYPE; -- Bug 2447912: Modified declaration

   l_pay_action_type           psp_payroll_lines.payroll_action_type%TYPE; -- Bug 7040943

 cursor get_element_type is
   select ppl.element_type_id,
          ppl.assignment_id,
          ppl.person_id
    from  psp_payroll_lines ppl,
          psp_payroll_sub_lines ppsl,
          psp_distribution_lines pdl
    where pdl.distribution_line_id = x_line_id
      and pdl.payroll_sub_line_id = ppsl.payroll_sub_line_id
      and ppsl.payroll_line_id = ppl.payroll_line_id
   union all
   select ppg.element_type_id,
          ppg.assignment_id,
          ppg.person_id
     from psp_pre_gen_dist_lines ppg
    where pre_gen_dist_line_id = x_line_id;

 cursor get_asg_details is
   select ppf.full_name,
          paf.assignment_number,
          pet.element_name,
          hou.name
     from per_all_people_f ppf,
          per_all_assignments_f paf,
          pay_element_types_f pet,
          hr_all_organization_units hou
    where ppf.person_id = l_person_id
      and l_distribution_date between ppf.effective_start_date and ppf.effective_end_date
      and paf.assignment_id = l_assignment_id
      and l_distribution_date between paf.effective_start_date and paf.effective_end_date
      and pet.element_type_id = l_element_type_id
      and l_distribution_date between pet.effective_start_date and pet.effective_end_date
      and hou.organization_id = paf.organization_id;

 BEGIN

   select count(*)
     into l_no_run
     from gl_interface
    where status = 'NEW'
      and group_id = p_group_id
      and user_je_source_name = 'OLD'
     AND reference6 in(select summary_line_id FROM psp_summary_lines   -- Bug 7376898
                        WHERE GROUP_ID = p_group_id
                        AND payroll_control_id = p_payroll_control_id);

   if l_no_run > 0 then

     delete from gl_interface
      where group_id = p_group_id
	and user_je_source_name = 'OLD'
        AND reference6 in(select summary_line_id FROM psp_summary_lines   -- Bug 7376898
                           WHERE GROUP_ID = p_group_id
                           AND payroll_control_id = p_payroll_control_id);


     delete from psp_summary_lines
      where payroll_control_id = p_payroll_control_id
	and group_id = p_group_id;

     --- bug 4328598 -- fix begin

        -- get the source name
   get_gl_je_sources(l_user_je_source_name,
                     l_return_status);
   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

     delete gl_interface_Control
     where group_id = p_group_id
       and je_source_name = l_user_je_source_name;

     update psp_payroll_controls
        set phase = null
      where payroll_control_id = p_payroll_control_id;

     commit;
     --- bug 4328598--- fix end


	fnd_message.set_name('PSP','PSP_JI_DID_NOT_RUN');
	fnd_message.set_token('PAYROLL_CONTROL_ID',p_payroll_control_id);
        fnd_message.set_token('GROUP_ID',p_group_id);
        fnd_msg_pub.add;
        -- uncommented following statement for 2444657
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

   end if;

   SELECT count(*)
   INTO l_cnt_gl_interface
   FROM gl_interface
   WHERE group_id = p_group_id
     AND user_je_source_name = 'OLD'
     AND set_of_books_id = p_set_of_books_id
     AND reference6 in(select summary_line_id FROM psp_summary_lines   -- Bug 7376898
                       WHERE GROUP_ID = p_group_id
                       AND payroll_control_id = p_payroll_control_id);


--- moved this statement from transfer_to_gl procedure to the beginning of this
-- procedure, becuase it not being set when user defined exceptions are occuring
--- like invalid suspense FATAL error. Since there is a single commit for TIE-BACK
-- this will work fine... for Bug fix 2444657
	UPDATE 	psp_payroll_controls
	SET    	phase = 'GL_Tie_Back'
	WHERE	payroll_control_id = p_payroll_control_id;

   IF l_cnt_gl_interface > 0 THEN
     --
     OPEN gl_tie_back_reject_cur;
     LOOP
       FETCH gl_tie_back_reject_cur INTO l_status,l_reference6;
       IF gl_tie_back_reject_cur%NOTFOUND THEN
         CLOSE gl_tie_back_reject_cur;
         EXIT;
       END IF;
       -- update summary_lines with the reject status code
       UPDATE psp_summary_lines
       SET interface_status = l_status, status_code = 'R'
       WHERE summary_line_id = to_number(l_reference6);

       OPEN assign_susp_ac_cur(to_number(l_reference6));
       LOOP

         FETCH assign_susp_ac_cur INTO l_rowid, x_line_id, l_distribution_date,
		l_suspense_org_account_id, l_reversal_entry_flag,
		l_effective_date;  --Bug 7040943;

         IF assign_susp_ac_cur%NOTFOUND THEN
           CLOSE assign_susp_ac_cur;
           EXIT;
         END IF;

	-- Bug 9307730
	IF p_source_type IN('O', 'N') THEN
         -- Bug 7376898
         SELECT payroll_action_type
           INTO l_pay_action_type
           FROM psp_payroll_lines
          WHERE payroll_control_id = p_payroll_control_id
            and payroll_line_id = (select payroll_line_id from psp_payroll_sub_lines
                                    where payroll_sub_line_id = (select payroll_sub_line_id
                                                                   from psp_distribution_lines
                                                                  where distribution_line_id = x_line_id));
	END IF;

-- Get the name and gl_ccid of the suspense account used
	if l_suspense_org_account_id is not null  then
	 OPEN get_susp_org_cur(l_suspense_org_account_id);
	 FETCH get_susp_org_cur into l_organization_id, l_organization_name,
				     l_lines_glccid;
	 CLOSE get_susp_org_cur;
	end if;


      IF  (l_status <> 'P' AND substr(l_status,1,1) <> 'W')  THEN -- moved this condition from elseif:Bug2205224

         IF l_suspense_org_account_id IS NOT NULL THEN

           x_susp_failed_org_name := l_organization_name;
           x_susp_failed_status   := l_status;
           x_susp_failed_date     := l_distribution_date;
           l_suspense_ac_failed := 'Y';

         -- if the reversing a/c failed,update the status of the whole batch and display the error
         ELSIF l_reversal_entry_flag = 'Y' THEN

          ---x_lines_glccid := l_lines_glccid;  commented this line and introduced
                                        ---      if-endif statment below for 2663344
          l_reversal_ac_failed := 'Y';

          if x_lines_glccid is null then
            select gl_code_combination_id into x_lines_glccid
            from psp_summary_lines where summary_line_id = to_number(l_reference6);
          end if;

         ELSE

           l_susp_ac_found := 'TRUE';
	   OPEN get_org_id_cur(x_line_id);
	   FETCH get_org_id_cur into l_orig_org_id, l_orig_org_name;
	   CLOSE get_org_id_cur;

	   --Bug 7040943 Starts
	   IF l_pay_action_type = 'L' THEN
	    	l_distribution_date := l_effective_date;
	   END IF;
           --Bug 7040943 End

           OPEN org_susp_ac_cur(l_orig_org_id,l_distribution_date);
           FETCH org_susp_ac_cur INTO l_organization_account_id,l_susp_glccid,l_project_id,l_award_id,l_task_id,
                                     l_exp_org_id, l_expenditure_type;
           IF org_susp_ac_cur%NOTFOUND  THEN
           /* Following code is added for bug 2056877 ,Added validation for generic suspense account */
              l_return_value := psp_general.find_global_suspense(l_distribution_date,
							  p_business_group_id,
                                                          p_set_of_books_id,
                                                          l_organization_account_id );
      	  /* --------------------------------------------------------------------
      	   Valid return values are
      	   PROFILE_VAL_DATE_MATCHES       Profile and Value and Date matching 'G'
      	   NO_PROFILE_EXISTS              No Profile
       	   NO_VAL_DATE_MATCHES            Profile and Either Value/date do not
            		                  match with 'G'
   	   NO_GLOBAL_ACCT_EXISTS          No 'G' exists
     	    ---------------------------------------------------------------------- */
              IF  l_return_value = 'PROFILE_VAL_DATE_MATCHES' THEN
                --  OPEN global_susp_ac_cur(l_distribution_date);
                    OPEN global_susp_ac_cur(l_organization_account_id); --Bug 2056877
                    FETCH global_susp_ac_cur INTO l_organization_account_id,l_susp_glccid,l_project_id,l_award_id,l_task_id,
                                                  l_exp_org_id, l_expenditure_type;
	              IF global_susp_ac_cur%NOTFOUND THEN
        		 /*      l_susp_ac_found := 'FALSE';
		                 l_suspense_ac_not_found := 'Y';
                		 x_susp_nf_org_name := l_orig_org_name;
		                 x_susp_nf_date     := l_distribution_date;  Commented for bug 2056877 */
		          --- commented for 2479579      RAISE no_global_acct_exists; --Added for bug 2056877
                           -- added following lines for 2479579
                              l_susp_ac_found := 'NO_G_AC';
		              l_suspense_ac_not_found := 'Y';
		      END IF;
              	      CLOSE global_susp_ac_cur;
	      ELSIF l_return_value = 'NO_GLOBAL_ACCT_EXISTS' THEN
    		     --- RAISE no_global_acct_exists; commented this line added following 2 lines for 2479579
	             l_suspense_ac_not_found := 'Y';
                     l_susp_ac_found := 'NO_G_AC';
              ELSIF l_return_value = 'NO_VAL_DATE_MATCHES' THEN
         	    --- RAISE no_val_date_matches;  commented this line added following 2 lines for 2479579
	            l_suspense_ac_not_found := 'Y';
                    l_susp_ac_found := 'NO_DT_MCH';
              ELSIF l_return_value = 'NO_PROFILE_EXISTS' THEN
         	    --- RAISE no_profile_exists;  commented this line added following 2 lines for 2479579
	             l_suspense_ac_not_found := 'Y';
                     l_susp_ac_found := 'NO_PROFL';
              END IF; -- Bug 2056877.
        END IF;
       CLOSE org_susp_ac_cur;
  -- introduced for 5080403
       if g_suspense_autopop = 'Y' and l_organization_account_id is not null then
            if l_susp_glccid is null then
                l_acct_type:='E';
            else
                l_acct_type:='N';
            end if;
            open get_element_type;
            fetch get_element_type into l_element_type_id, l_assignment_id, l_person_id;
            close get_element_type;
              psp_autopop.main( p_acct_type                   => l_acct_type,
                                p_person_id                   => l_person_id,
                                p_assignment_id               => l_assignment_id,
                                p_element_type_id             => l_element_type_id,
                                p_project_id                  => l_project_id,
                                p_expenditure_organization_id => l_exp_org_id,
                                p_task_id                     => l_task_id,
                                p_award_id                    => l_award_id,
                                p_expenditure_type            => l_expenditure_type,
                                p_gl_code_combination_id      => l_susp_glccid,
                                p_payroll_date                => l_distribution_date,
                                p_set_of_books_id             => p_set_of_books_id,
                                p_business_group_id           => p_business_group_id,
                                ret_expenditure_type          => l_new_expenditure_type,
                                ret_gl_code_combination_id    => l_new_glccid,
                                retcode                       => l_auto_pop_status);
           IF (l_auto_pop_status = FND_API.G_RET_STS_UNEXP_ERROR) OR
             (l_auto_pop_status = FND_API.G_RET_STS_ERROR) THEN
             IF l_auto_pop_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
               if l_acct_type ='N'  then
                    l_auto_status := 'AUTO_POP_NA_ERROR';
               else
                    l_auto_status :='AUTO_POP_EXP_ERROR';
               end if;
             elsif l_auto_pop_status = FND_API.G_RET_STS_ERROR THEN
               l_auto_status := 'AUTO_POP_NO_VALUE';
             end if;
             open get_asg_details;
             fetch get_asg_details into l_person_name, l_assignment_number, l_element_type, l_auto_org_name;
             close get_asg_details;
             psp_enc_crt_xml.p_set_of_books_id := p_set_of_books_id;
             psp_enc_crt_xml.p_business_group_id := p_business_group_id;
             if l_acct_type = 'N' then
                 l_account :=
                     psp_enc_crt_xml.cf_charging_instformula(l_susp_glccid,
                                                             null,
                                                             null,
                                                             null,
                                                             null,
                                                             null);
              else
                 l_account :=
                     psp_enc_crt_xml.cf_charging_instformula(null,
                                                             l_project_id,
                                                             l_task_id,
                                                             l_award_id,
                                                             l_expenditure_type,
                                                             l_exp_org_id);
              end if;
                   fnd_message.set_name('PSP','PSP_SUSPENSE_AUTOPOP_FAIL');
                   fnd_message.set_token('ORG_NAME',l_auto_org_name);
                   fnd_message.set_token('EMPLOYEE_NAME',l_person_name);
                   fnd_message.set_token('ASG_NUM',l_assignment_number);
                   fnd_message.set_token('CHARGING_ACCOUNT',l_account);
                   fnd_message.set_token('AUTOPOP_ERROR',l_auto_status);
                   fnd_message.set_token('EFF_DATE',l_distribution_date);
                   fnd_msg_pub.add;
         else
           if l_acct_type = 'E' then
              l_expenditure_type := l_new_expenditure_type;
           else
              l_susp_glccid := l_new_glccid;
           end if;
         end if;
        end if;

           IF l_susp_ac_found = 'TRUE' THEN

             IF l_susp_glccid IS NOT NULL THEN
               l_gl_project_flag := 'G';
               -- l_effective_date := p_period_end_date;   ---  uncommented for 22663344  --Bug 7040943

             ELSE
               l_gl_project_flag := 'P';

           /* Bug 1874696: deleted the procedure call for psp_general.poeta_effective_date
           */
                l_effective_date := l_distribution_date;   --- added for Bug 2663344

             END IF;

             -- assign the organization suspense account and gl status
             --dbms_output.put_line('Updating distribution_lines ....NULL..');

            IF p_source_type = 'O' OR p_source_type = 'N' THEN

	     /* Added the following for Bug 3065866 */

	     UPDATE PSP_DISTRIBUTION_LINES
	     SET    pre_distribution_run_flag = gl_project_flag
      	     WHERE  rowid = l_rowid;

	     /* End of code changes for Bug 3065866 */

             UPDATE psp_distribution_lines
              SET suspense_org_account_id = l_organization_account_id,
                  suspense_reason_code = 'ST:' || l_status,
                  gl_project_flag = l_gl_project_flag,
                  status_code = 'N',
                   effective_date = l_effective_date,  --- for  Bug 2663344
               suspense_auto_glccid = l_new_glccid,    --- added suspense_auto for 5080403
                  suspense_auto_exp_type = l_new_expenditure_type
              WHERE rowid = l_rowid;
            ELSIF p_source_type = 'P' THEN
               UPDATE psp_pre_gen_dist_lines
                 SET suspense_org_account_id = l_organization_account_id,
                     suspense_reason_code = 'ST:' || l_status,
                     status_code = 'N',
                      effective_date = l_effective_date,  --- for  Bug 2663344
               suspense_auto_glccid = l_new_glccid,    --- added suspense_auto for 5080403
                  suspense_auto_exp_type = l_new_expenditure_type
                 WHERE rowid = l_rowid;
            END IF;
           ELSE  -- introduced for 2479579
              l_susp_exception := l_susp_ac_found;
           END IF;
         END IF;
     END IF;  -- Bug 2205224, status not in (P,W)


       END LOOP;
     END LOOP;
      ---2445196: cleanup gl interface b'cos rejection is available in rejected summary lines
         get_gl_je_sources(l_user_je_source_name,
                     l_return_status);
        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

      delete gl_interface
      where group_id = p_group_id
       and set_of_books_id = p_set_of_books_id
       AND user_je_source_name = l_user_je_source_name
       and reference6 in(select summary_line_id FROM psp_summary_lines   -- Bug 7376898
                         WHERE GROUP_ID = p_group_id
                         AND payroll_control_id = p_payroll_control_id);

     IF l_reversal_ac_failed = 'Y' THEN
       fnd_message.set_name('PSP','PSP_GL_REVERSE_AC_REJECT');
       fnd_message.set_token('GLCCID',x_lines_glccid);
       fnd_msg_pub.add;

     /* Added the following for the Bug 3065866 */

	IF p_source_type = 'O' OR p_source_type = 'N' THEN
		UPDATE 	psp_distribution_lines
		SET 	suspense_org_account_id = NULL,
			suspense_reason_code = NULL,
                        gl_project_flag = pre_distribution_run_flag,
                        effective_date = decode(pre_distribution_run_flag,'G',
						p_period_end_date,distribution_date)
		WHERE	suspense_reason_code like 'ST:%'
		AND	summary_line_id
			IN (SELECT 	summary_line_id
			    FROM 	psp_summary_lines
			    WHERE 	payroll_control_id = p_payroll_control_id);
	ELSIF p_source_type = 'P' THEN

		UPDATE	psp_pre_gen_dist_lines
		SET	suspense_org_account_id = NULL,
			suspense_reason_code = NULL,
                       effective_date = decode(NVL(gl_code_combination_id,-999),gl_code_combination_id,
					p_period_end_date,distribution_date)
		WHERE	suspense_reason_code like 'ST:%'
		AND	summary_line_id
			IN (SELECT 	summary_line_id
			    FROM	psp_summary_lines
			    WHERE	payroll_control_id = p_payroll_control_id);
	END IF;

	/* End of code for Bug 3065856 */


	/* Introduced the following check as part of Bug fix #1776606 */
       if p_mode = 'N' then
          /* introduced mark batch end Bug: 1929317 */
          mark_batch_end(p_source_type,
                   g_source_code,
                   g_time_period_id,
                   g_batch_name,
                   p_business_group_id,
                   p_set_of_books_id,
                   l_return_status);
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       end if;
     END IF;

     IF l_suspense_ac_failed = 'Y' or
        nvl(l_auto_status,'X') in ('AUTO_POP_NA_ERROR', 'AUTO_POP_EXP_ERROR', 'AUTO_POP_NO_VALUE') then
                   --- above check for autopop error 5080403
       if nvl(l_suspense_ac_failed,'N') = 'Y' then
       fnd_message.set_name('PSP','PSP_TR_GL_SUSP_AC_REJECT');
       fnd_message.set_token('ORG_NAME',x_susp_failed_org_name);
       fnd_message.set_token('PAYROLL_DATE',x_susp_failed_date);
       fnd_message.set_token('ERROR_MSG',x_susp_failed_status);
       fnd_msg_pub.add;
       end if;

	/* Added the following for Bug 3065866 */

	IF p_source_type = 'O' OR p_source_type = 'N' THEN


		UPDATE 	psp_distribution_lines
	 	SET	suspense_org_account_id = NULL,
			suspense_reason_code = NULL,
			gl_project_flag = pre_distribution_run_flag,
                        effective_date = decode(pre_distribution_run_flag,'G',
                                                p_period_end_date,distribution_date)
		WHERE	suspense_reason_code like 'ST:%'
		AND	summary_line_id
			IN (SELECT	summary_line_id
			    FROM	psp_summary_lines
			    WHERE	payroll_control_id = p_payroll_control_id );
	ELSIF p_source_type = 'P' THEN
		UPDATE	psp_pre_gen_dist_lines
		SET	suspense_org_account_id = NULL,
			suspense_reason_code = NULL,
			effective_date = decode(NVL(gl_code_combination_id,-999),gl_code_combination_id,
                                        p_period_end_date,distribution_date)
		WHERE	suspense_reason_code like 'ST:%'
		AND	summary_line_id
			IN ( SELECT	summary_line_id
			     FROM 	psp_summary_lines
			     WHERE	payroll_control_id = p_payroll_control_id );
	END IF;

	/* End of code for Bug 3065866 */

	/* Introduced the following check as part of Bug fix #1776606 */
       if p_mode = 'N' then
         /* introduced mark batch end Bug: 1929317 */
         mark_batch_end(p_source_type,
                   g_source_code,
                   g_time_period_id,
                   g_batch_name,
                   p_business_group_id,
                   p_set_of_books_id,
                   l_return_status);
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       end if;
     END IF;

     IF l_suspense_ac_not_found = 'Y' THEN
       /* commented following code for 2479579
       fnd_message.set_name('PSP','PSP_LD_SUSPENSE_AC_NOT_EXIST');
       fnd_message.set_token('ORG_NAME',x_susp_nf_org_name);
       fnd_message.set_token('PAYROLL_DATE',x_susp_nf_date);
       fnd_msg_pub.add; */

	/* Introduced the following check as part of Bug fix #1776606 */
       if p_mode = 'N' then
         /* introduced mark batch end Bug: 1929317 */
         mark_batch_end(p_source_type,
                   g_source_code,
                   g_time_period_id,
                   g_batch_name,
                   p_business_group_id,
                   p_set_of_books_id,
                   l_return_status);
          --- RAISE FND_API.G_EXC_UNEXPECTED_ERROR; commented for  2479579
          -- introduced following if stmnt  for  2479579
          if l_susp_exception = 'NO_G_AC' then
                     RAISE no_global_acct_exists;
          elsif  l_susp_exception = 'NO_DT_MCH' then
                     RAISE no_val_date_matches;
          elsif l_susp_exception =  'NO_PROFL' then
                     RAISE no_profile_exists;
          end if;

       end if;
     END IF;


   ELSIF l_cnt_gl_interface = 0  and l_no_run = 0 THEN
     --
     OPEN gl_tie_back_success_cur;
     LOOP
       FETCH gl_tie_back_success_cur INTO l_summary_line_id,
       l_dr_cr_flag,l_summary_amount;
       IF gl_tie_back_success_cur%NOTFOUND THEN
         CLOSE gl_tie_back_success_cur;
         EXIT;
       END IF;
       -- update records in psp_summary_lines as 'A'
       UPDATE psp_summary_lines
       SET status_code = 'A'
       WHERE summary_line_id = l_summary_line_id;

       IF l_dr_cr_flag = 'D' THEN
         l_dr_summary_amount := l_dr_summary_amount + l_summary_amount;
       ELSIF l_dr_cr_flag = 'C' THEN
         l_cr_summary_amount := l_cr_summary_amount + l_summary_amount;
       END IF;

       IF p_source_type = 'O' OR p_source_type = 'N' THEN

         UPDATE psp_distribution_lines
         SET status_code = 'A' WHERE summary_line_id = l_summary_line_id;

         -- move the transferred records to psp_distribution_lines_history
         INSERT INTO psp_distribution_lines_history
         (distribution_line_id,payroll_sub_line_id,distribution_date,
          effective_date,distribution_amount,status_code,suspense_reason_code,
          effort_report_id,version_num,schedule_line_id,
          summary_line_id,default_org_account_id,suspense_org_account_id,
          element_account_id,org_schedule_id,
          user_defined_field,default_reason_code,reversal_entry_flag,gl_project_flag,
	  auto_gl_code_combination_id, business_group_id, set_of_books_id,
	attribute_category,	attribute1,	attribute2,	attribute3,
	attribute4,		attribute5,	attribute6,	attribute7,
	attribute8,		attribute9,	attribute10,
         cap_excess_glccid, cap_excess_award_id, cap_excess_task_id,
        cap_excess_project_id,    cap_excess_exp_type, cap_excess_exp_org_id,
        funding_source_code, annual_salary_cap, cap_excess_dist_line_id,
        suspense_auto_exp_type, suspense_auto_glccid, adj_account_flag)   --- added 2 cols for 508040
         SELECT distribution_line_id,payroll_sub_line_id,distribution_date,
          effective_date,distribution_amount,status_code,suspense_reason_code,
          effort_report_id,version_num,schedule_line_id,
          summary_line_id,default_org_account_id,suspense_org_account_id,
          element_account_id,org_schedule_id,
          user_defined_field,default_reason_code,reversal_entry_flag,gl_project_flag,
	  auto_gl_code_combination_id, business_group_id, set_of_books_id,
	attribute_category,	attribute1,	attribute2,	attribute3,
	attribute4,		attribute5,	attribute6,	attribute7,
	attribute8,		attribute9,	attribute10,
         cap_excess_glccid, cap_excess_award_id, cap_excess_task_id,
        cap_excess_project_id,    cap_excess_exp_type, cap_excess_exp_org_id,
        funding_source_code, annual_salary_cap, cap_excess_dist_line_id,
          suspense_auto_exp_type, suspense_auto_glccid, adj_account_flag
         FROM psp_distribution_lines
         WHERE status_code = 'A'
         AND  summary_line_id = l_summary_line_id;

         DELETE FROM psp_distribution_lines
         WHERE status_code = 'A'
         AND summary_line_id = l_summary_line_id;

       ELSIF p_source_type = 'P' THEN

         UPDATE psp_pre_gen_dist_lines
         SET status_code = 'A' WHERE summary_line_id = l_summary_line_id;

         -- move the transferred records to psp_pre_gen_dist_lines_history
	-- Introduced DFF columns for bug fix 2908859
         INSERT INTO psp_pre_gen_dist_lines_history
         (pre_gen_dist_line_id,distribution_interface_id,person_id,assignment_id,
          element_type_id,distribution_date,effective_date,distribution_amount,
          dr_cr_flag,payroll_control_id,source_type,source_code,time_period_id,
          batch_name,status_code,set_of_books_id,
          gl_code_combination_id,project_id,expenditure_organization_id,
          expenditure_type,task_id,award_id,suspense_reason_code,
          effort_report_id,version_num,summary_line_id,suspense_org_account_id,
          user_defined_field,reversal_entry_flag, business_group_id,
	attribute_category,	attribute1,	attribute2,	attribute3,
	attribute4,		attribute5,	attribute6,	attribute7,
	attribute8,		attribute9,	attribute10,
         suspense_auto_exp_type, suspense_auto_glccid)    -- added 2 cols for 5080403
         SELECT pre_gen_dist_line_id,distribution_interface_id,person_id,assignment_id,
          element_type_id,distribution_date,effective_date,distribution_amount,
          dr_cr_flag,payroll_control_id,source_type,source_code,time_period_id,
          batch_name,status_code,set_of_books_id,
          gl_code_combination_id,project_id,expenditure_organization_id,
          expenditure_type,task_id,award_id,suspense_reason_code,
          effort_report_id,version_num,summary_line_id,suspense_org_account_id,
          user_defined_field,reversal_entry_flag, business_group_id,
	attribute_category,	attribute1,	attribute2,	attribute3,
	attribute4,		attribute5,	attribute6,	attribute7,
        attribute8,             attribute9,     attribute10,
         suspense_auto_exp_type, suspense_auto_glccid
         FROM psp_pre_gen_dist_lines
         WHERE status_code = 'A'
         AND summary_line_id = l_summary_line_id;

         DELETE FROM psp_pre_gen_dist_lines
         WHERE status_code = 'A'
         AND summary_line_id = l_summary_line_id;

       END IF;

     END LOOP;

       UPDATE psp_payroll_controls
       SET gl_dr_amount = nvl(gl_dr_amount,0) + l_dr_summary_amount,
           gl_cr_amount = nvl(gl_cr_amount,0) + l_cr_summary_amount
       WHERE payroll_control_id = p_payroll_control_id;

   END IF;
   --
   p_return_status := fnd_api.g_ret_sts_success;
 EXCEPTION

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     --dbms_output.put_line('Gone to one level top ..................');
     g_error_api_path := 'GL_TIE_BACK:'||g_error_api_path;
     p_return_status := fnd_api.g_ret_sts_unexp_error;

     /* Added Exceptions for bug 2056877 */
     WHEN NO_PROFILE_EXISTS THEN
      g_error_api_path := SUBSTR('GL_TIE_BACK:'||g_error_api_path,1,230);
      fnd_message.set_name('PSP','PSP_NO_PROFILE_EXISTS');
      fnd_msg_pub.add;
      p_return_status := fnd_api.g_ret_sts_unexp_error;

   WHEN NO_VAL_DATE_MATCHES THEN
      g_error_api_path := SUBSTR('GL_TIE_BACK:'||g_error_api_path,1,230);
      fnd_message.set_name('PSP','PSP_NO_VAL_DATE_MATCHES');
      fnd_message.set_token('ORG_NAME',l_orig_org_name);
      fnd_message.set_token('PAYROLL_DATE',l_distribution_date);
      fnd_msg_pub.add;
      p_return_status := fnd_api.g_ret_sts_unexp_error;

   WHEN NO_GLOBAL_ACCT_EXISTS THEN
      g_error_api_path := SUBSTR('GL_TIE_BACK:'||g_error_api_path,1,230);
      fnd_message.set_name('PSP','PSP_NO_GLOBAL_ACCT_EXISTS');
      fnd_message.set_token('ORG_NAME',l_orig_org_name);
      fnd_message.set_token('PAYROLL_DATE',l_distribution_date);
      fnd_msg_pub.add;
      p_return_status := fnd_api.g_ret_sts_unexp_error;  --End of Changes for Bug 2056877.

   WHEN OTHERS THEN
      g_error_api_path := 'GL_TIE_BACK:'||g_error_api_path;
      fnd_msg_pub.add_exc_msg('PSP_SUM_TRANS','GL_TIE_BACK');
      p_return_status := fnd_api.g_ret_sts_unexp_error;
 END;


------------------ CREATE BALANCING TRANSACTIONS FOR GL ------------------------------

 PROCEDURE gl_balance_transaction(
			P_SOURCE_TYPE 		IN	VARCHAR2,
			P_PAYROLL_CONTROL_ID	IN	NUMBER,
			P_BUSINESS_GROUP_ID	IN	NUMBER,
			P_SET_OF_BOOKS_ID	IN	NUMBER,
			P_PRECISION		IN	NUMBER,-- Introduced this parameter For Bug 2916848
                  P_RETURN_STATUS        OUT NOCOPY VARCHAR2) IS

   CURSOR dist_reversal_entry_cur(P_PAYROLL_CONTROL_ID IN NUMBER) IS
   SELECT pdl.payroll_sub_line_id,pdl.effective_date,
          round(sum(pdl.distribution_amount), p_precision) reversal_dist_amount,-- Changed rounding from 2 to p_precision
-- For Bug 2916848
	  pdl.business_group_id,
	  pdl.set_of_books_id
   FROM   psp_distribution_lines  pdl,
          psp_payroll_sub_lines   ppsl,
          psp_payroll_lines       ppl,
          psp_payroll_controls    ppc
   WHERE  ppc.payroll_control_id = p_payroll_control_id
   AND    ppc.payroll_control_id = ppl.payroll_control_id
   AND    ppl.payroll_line_id = ppsl.payroll_line_id
   AND    ppsl.payroll_sub_line_id = pdl.payroll_sub_line_id
   AND    nvl(pdl.reversal_entry_flag,'N') = 'N'
   AND    pdl.gl_project_flag = 'G'
   AND    pdl.status_code = 'N'
   GROUP BY pdl.payroll_sub_line_id, pdl.effective_date, pdl.business_group_id, pdl.set_of_books_id;

   CURSOR pg_reversal_entry_cur(P_PAYROLL_CONTROL_ID IN NUMBER) IS
   SELECT ppgd.distribution_interface_id,
	  ppgd.person_id,
	  ppgd.assignment_id,
	  ppgd.element_type_id,
	  ppgd.dr_cr_flag,
	  ppgd.distribution_date,
	  ppgd.effective_date,
	  ppgd.source_type,
	  ppgd.source_code,
	  ppgd.time_period_id,
	  ppgd.batch_name,
	  ppgd.set_of_books_id,
	  ppgd.business_group_id,
	  round(sum(ppgd.distribution_amount), p_precision) reversal_dist_amount -- For Bug 2916848 changed to p_precision
     FROM psp_pre_gen_dist_lines ppgd,
	  psp_organization_accounts pos
    WHERE ppgd.payroll_control_id = p_payroll_control_id
      AND nvl(ppgd.reversal_entry_flag,'N') = 'N'
      AND ((ppgd.gl_code_combination_id IS NOT NULL and pos.project_id is null ) OR  -- Bug 2007521 Changed condn
            pos.gl_code_combination_id IS NOT NULL)
      AND ppgd.suspense_org_account_id = pos.organization_account_id(+)
      AND ppgd.status_code = 'N'
--      AND ppgd.business_group_id = p_business_group_id
--      AND ppgd.set_of_books_id = p_set_of_books_id
 GROUP BY ppgd.distribution_interface_id, ppgd.person_id,
	  ppgd.assignment_id, ppgd.element_type_id,
	  ppgd.dr_cr_flag, ppgd.distribution_date, ppgd.effective_date,
	  ppgd.source_type, ppgd.source_code,
	  ppgd.time_period_id, ppgd.batch_name, ppgd.set_of_books_id, ppgd.business_group_id;

   dist_reversal_entry_rec	dist_reversal_entry_cur%ROWTYPE;
   pg_reversal_entry_rec	pg_reversal_entry_cur%ROWTYPE;
   l_reversal_dist_amount	NUMBER;
   l_clrg_account_glccid	NUMBER(15);
   l_cr_amount			NUMBER;
   l_dr_amount			NUMBER;

   l_payroll_id                 NUMBER(9);   -- Added for bug 5592964

 BEGIN

     IF p_source_type = 'O' OR p_source_type = 'N' THEN

       DELETE FROM psp_distribution_lines
       WHERE reversal_entry_flag = 'Y'
       AND status_code = 'N'
       AND payroll_sub_line_id IN (
        select payroll_sub_line_id from psp_payroll_sub_lines where payroll_line_id IN (
        select payroll_line_id from psp_payroll_lines where payroll_control_id IN (
        select payroll_control_id from psp_payroll_controls where payroll_control_id=
         p_payroll_control_id)));


       -- recalculate and update the reversal sub-line amounts
       OPEN dist_reversal_entry_cur(p_payroll_control_id);
       LOOP
         FETCH dist_reversal_entry_cur INTO dist_reversal_entry_rec;
         IF dist_reversal_entry_cur%NOTFOUND THEN
           CLOSE dist_reversal_entry_cur;
           EXIT;
         END IF;

         -- insert the reversal entry record into distribution lines
         insert into psp_distribution_lines
           (distribution_line_id,payroll_sub_line_id,distribution_date,effective_date,
            distribution_amount,status_code,gl_project_flag,reversal_entry_flag,
	    business_group_id, set_of_books_id)
         values
           (PSP_DISTRIBUTION_LINES_S.NEXTVAL,dist_reversal_entry_rec.payroll_sub_line_id,
            dist_reversal_entry_rec.effective_date,dist_reversal_entry_rec.effective_date,
            dist_reversal_entry_rec.reversal_dist_amount,'N','G','Y',
	    dist_reversal_entry_rec.business_group_id, dist_reversal_entry_rec.set_of_books_id);

       END LOOP;

       select sum(decode(reversal_entry_flag, 'Y', distribution_amount, 0)) cr_amount,
	      sum(decode(reversal_entry_flag, 'Y', 0, distribution_amount)) dr_amount
	 INTO l_cr_amount, l_dr_amount
	 FROM psp_distribution_lines  pdl,
	      psp_payroll_sub_lines   ppsl,
	      psp_payroll_lines       ppl,
	      psp_payroll_controls    ppc
        WHERE ppc.payroll_control_id = p_payroll_control_id
	  AND ppc.payroll_control_id = ppl.payroll_control_id
	  AND ppl.payroll_line_id = ppsl.payroll_line_id
	  AND ppsl.payroll_sub_line_id = pdl.payroll_sub_line_id
	  AND pdl.gl_project_flag = 'G'
	  AND pdl.status_code = 'N';

	IF l_cr_amount <> l_dr_amount then
	  fnd_message.set_name('PSP','PSP_GL_REV_AMT_NOT_EQUAL');
	  fnd_msg_pub.add;
	  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

     ELSIF p_source_type = 'P' THEN
       SELECT payroll_id INTO l_payroll_id
       FROM  psp_payroll_controls
       WHERE payroll_control_id = p_payroll_control_id;

       BEGIN
	 SELECT reversing_gl_ccid
	   INTO l_clrg_account_glccid
	   FROM PSP_CLEARING_ACCOUNT
	  WHERE set_of_books_id = p_set_of_books_id
	    AND business_group_id = p_business_group_id -- Changed for MO.
	    AND payroll_id = l_payroll_id;              -- Added for bug 5592964
	EXCEPTION
	WHEN NO_DATA_FOUND THEN
	  fnd_message.set_name('PSP','PSP_TR_CLRG_AC_NOT_SET_UP');
	  fnd_msg_pub.add;
	 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END;

	delete from psp_pre_gen_dist_lines
	 where reversal_entry_flag = 'Y'
	   and status_code = 'N'
	   and source_type = 'P'
	   and payroll_control_id = p_payroll_control_id;

       -- recalculate and update the reversal amounts
       OPEN pg_reversal_entry_cur(p_payroll_control_id);
       LOOP
         FETCH pg_reversal_entry_cur INTO pg_reversal_entry_rec;
         IF pg_reversal_entry_cur%NOTFOUND THEN
           CLOSE pg_reversal_entry_cur;
           EXIT;
         END IF;

-- Bug# 1140217
--         UPDATE psp_pre_gen_dist_lines
--         SET distribution_amount = pg_reversal_entry_rec.reversal_dist_amount
--         WHERE distribution_interface_id = pg_reversal_entry_rec.distribution_interface_id
--         AND   reversal_entry_flag = 'Y';


	insert into psp_pre_gen_dist_lines
		(pre_gen_dist_line_id, distribution_interface_id, person_id, assignment_id,
		element_type_id, distribution_date, effective_date, distribution_amount,
		dr_cr_flag, payroll_control_id, source_type, source_code, time_period_id,
		batch_name, status_code, set_of_books_id, business_group_id, gl_code_combination_id,
		reversal_entry_flag)
	values (psp_distribution_lines_s.nextval, pg_reversal_entry_rec.distribution_interface_id,
		pg_reversal_entry_rec.person_id, pg_reversal_entry_rec.assignment_id,
		pg_reversal_entry_rec.element_type_id, pg_reversal_entry_rec.distribution_date,
		pg_reversal_entry_rec.effective_date, pg_reversal_entry_rec.reversal_dist_amount,
		pg_reversal_entry_rec.dr_cr_flag, p_payroll_control_id, pg_reversal_entry_rec.source_type,
		pg_reversal_entry_rec.source_code, pg_reversal_entry_rec.time_period_id,
		pg_reversal_entry_rec.batch_name, 'N', pg_reversal_entry_rec.set_of_books_id,
		pg_reversal_entry_rec.business_group_id, l_clrg_account_glccid, 'Y');

       END LOOP;

        select sum(decode(reversal_entry_flag, 'Y', distribution_amount, 0)),
	       sum(decode(reversal_entry_flag, 'Y', 0, distribution_amount))
	  into l_cr_amount, l_dr_amount
	  from psp_pre_gen_dist_lines ppgd, psp_organization_accounts pos
	 where payroll_control_id = p_payroll_control_id
	   and ppgd.status_code = 'N'
	   and ppgd.suspense_org_account_id = pos.organization_account_id(+)
            AND ((ppgd.gl_code_combination_id IS NOT NULL and ppgd.suspense_org_account_id is null ) OR
            pos.gl_code_combination_id IS NOT NULL);
           /* Bug 2007521: replaced following condn with above condn
	   and (ppgd.gl_code_combination_id is not null or (ppgd.suspense_org_account_id is not null
	   						    and pos.gl_code_combination_id is not null)); */

	IF l_cr_amount <> l_dr_amount then
	   fnd_message.set_name('PSP','PSP_GL_UNBALANCED_BATCH');
	   fnd_msg_pub.add;
	   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

     END IF;
     --
     p_return_status := fnd_api.g_ret_sts_success;
 EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     g_error_api_path := 'GL_BALANCE_TRANSACTION:'||g_error_api_path;
     p_return_status := fnd_api.g_ret_sts_unexp_error;

   WHEN OTHERS THEN
      g_error_api_path := 'GL_BALANCE_TRANSACTION:'||g_error_api_path;
      fnd_msg_pub.add_exc_msg('PSP_SUM_TRANS','GL_BALANCE_TRANSACTION');
      p_return_status := fnd_api.g_ret_sts_unexp_error;
 END;

------------------ INSERT INTO GL INTERFACE -----------------------------------------------

 PROCEDURE insert_into_gl_interface(
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
			P_CURRENCY_CONVERSION_TYPE	IN	VARCHAR2, -- Introduced for bug fix 2916848
			P_CURRENCY_CONVERSION_DATE	IN	DATE, -- Introduced for bug fix 2916848
			P_RETURN_STATUS			OUT NOCOPY	VARCHAR2) IS
 BEGIN

   --dbms_output.put_line('sob id='||to_char(p_set_of_books_id));
  -- dbms_output.put_line('a date='||to_char(p_accounting_date));
  -- dbms_output.put_line('curren='||p_currency_code);
   --dbms_output.put_line('category='||p_user_je_category_name);
   --dbms_output.put_line('source='||p_user_je_source_name);

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
	REFERENCE30,
--      Introduced the following columns for bug fix 2916848
	USER_CURRENCY_CONVERSION_TYPE,
	CURRENCY_CONVERSION_DATE)
   VALUES(
	'NEW',
	P_SET_OF_BOOKS_ID,
	P_ACCOUNTING_DATE,
	P_CURRENCY_CODE,
	SYSDATE,
	FND_GLOBAL.USER_ID,
	'A',
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
	P_ATTRIBUTE30,
	P_CURRENCY_CONVERSION_TYPE,-- Introduced the following code for Bug fix 2916848
	DECODE(p_currency_conversion_type, NULL, NULL, P_CURRENCY_CONVERSION_DATE));-- Introduced the following code for Bug fix 2916848
    --dbms_output.put_line('DDDDDDDDDDDDDDDDDGL Interface Inserted ....................');
    p_return_status := fnd_api.g_ret_sts_success;
 EXCEPTION
   WHEN OTHERS THEN
      --dbms_output.put_line('Error while inserting .........................');
      g_error_api_path := 'INSERT_INTO_GL_INTERFACE:'||g_error_api_path;
      fnd_msg_pub.add_exc_msg('PSP_SUM_TRANS','INSERT_INTO_GL_INTERFACE');
      p_return_status := fnd_api.g_ret_sts_unexp_error;
 END;

-------------------- CREATE GMS SUM LINES -----------------------------------------------
 PROCEDURE create_gms_sum_lines(p_source_type     IN VARCHAR2,
                                p_source_code     IN VARCHAR2,
                                p_time_period_id  IN NUMBER,
                                p_batch_name      IN VARCHAR2,
				p_business_group_id IN NUMBER,
				p_set_of_books_id   IN NUMBER,
                                p_return_status  OUT NOCOPY VARCHAR2) IS

   CURSOR payroll_control_cur IS
   SELECT payroll_control_id,
          source_type,
          payroll_source_code,
          time_period_id,
          batch_name,
          business_group_id,
          set_of_books_id
   FROM   psp_payroll_controls
   WHERE  status_code = 'I'
   AND    source_type <> 'A'
   AND    run_id = g_run_id
   AND    (phase is null or
           phase in ('GMS_Tie_Back', 'GL_Tie_Back'));  ---  added for 2444657

   CURSOR gms_sum_lines_cursor(P_PAYROLL_CONTROL_ID  IN  NUMBER) IS
   SELECT ppl.person_id,
          ppl.assignment_id,
          nvl(pos.project_id,
              nvl(psl.project_id,
              nvl(pod.project_id,
              nvl(pea.project_id,
                  pdls.project_id)))) project_id,
          nvl(pos.expenditure_organization_id,
              nvl(psl.expenditure_organization_id,
              nvl(pod.expenditure_organization_id,
              nvl(pea.expenditure_organization_id,
                  pdls.expenditure_organization_id)))) expenditure_organization_id,
          nvl(pdl.suspense_auto_exp_type,   --- added for 5080403
          nvl(pos.expenditure_type,
              nvl(pdl.auto_expenditure_type,   --- added for 2663344
              nvl(psl.expenditure_type,
              nvl(pod.expenditure_type,
              nvl(pea.expenditure_type,
                  pdls.expenditure_type)))))) expenditure_type,
          nvl(pos.task_id,
              nvl(psl.task_id,
              nvl(pod.task_id,
              nvl(pea.task_id,
                  pdls.task_id)))) task_id,
          nvl(pos.award_id,
              nvl(psl.award_id,
              nvl(pod.award_id,
              nvl(pea.award_id,
                  pdls.award_id)))) award_id,
          ppl.dr_cr_flag,
          pdl.effective_date,
          nvl(ppc.gl_posting_override_date,ppl.accounting_date) accounting_date, --- added for 3108109
          nvl(ppc.exchange_rate_type,ppl.exchange_rate_type) exchange_rate_type,   --- added for 3108109
          pdl.distribution_amount,
          pdl.distribution_line_id  distribution_line_id,
	  pdl.auto_expenditure_type,
          'D' tab_flag,
	DECODE(g_dff_grouping_option, 'Y', DECODE(pdl.suspense_org_account_id, NULL, pdl.attribute_category, pos.attribute_category), NULL) attribute_category,	-- Introduced DFF columns for bug fix 2908859
	DECODE(g_dff_grouping_option, 'Y', DECODE(pdl.suspense_org_account_id, NULL, pdl.attribute1, pos.attribute8), NULL) attribute1,
	DECODE(g_dff_grouping_option, 'Y', DECODE(pdl.suspense_org_account_id, NULL, pdl.attribute2, pos.attribute8), NULL) attribute2,
	DECODE(g_dff_grouping_option, 'Y', DECODE(pdl.suspense_org_account_id, NULL, pdl.attribute3, pos.attribute8), NULL) attribute3,
	DECODE(g_dff_grouping_option, 'Y', DECODE(pdl.suspense_org_account_id, NULL, pdl.attribute4, pos.attribute8), NULL) attribute4,
	DECODE(g_dff_grouping_option, 'Y', DECODE(pdl.suspense_org_account_id, NULL, pdl.attribute5, pos.attribute8), NULL) attribute5,
	DECODE(g_dff_grouping_option, 'Y', DECODE(pdl.suspense_org_account_id, NULL, pdl.attribute6, pos.attribute8), NULL) attribute6,
	DECODE(g_dff_grouping_option, 'Y', DECODE(pdl.suspense_org_account_id, NULL, pdl.attribute7, pos.attribute8), NULL) attribute7,
	DECODE(g_dff_grouping_option, 'Y', DECODE(pdl.suspense_org_account_id, NULL, pdl.attribute8, pos.attribute8), NULL) attribute8,
	DECODE(g_dff_grouping_option, 'Y', DECODE(pdl.suspense_org_account_id, NULL, pdl.attribute9, pos.attribute9), NULL) attribute9,
	DECODE(g_dff_grouping_option, 'Y', DECODE(pdl.suspense_org_account_id, NULL, pdl.attribute10, pos.attribute10), NULL) attribute10
          ---decode(pdl.suspense_org_account_id, NULL, 'N', 'Y') Suspense_Flag uncommented for 2663344
   FROM   psp_schedule_lines              psl,
          psp_organization_accounts       pod,
          psp_organization_accounts       pos,
          psp_element_type_accounts       pea,
          psp_default_labor_schedules     pdls,
          psp_payroll_controls            ppc,
          psp_payroll_lines               ppl,
          psp_payroll_sub_lines           ppsl,
          psp_distribution_lines          pdl
   WHERE  pdl.status_code = 'N'
   AND    pdl.payroll_sub_line_id = ppsl.payroll_sub_line_id
   AND    ppsl.payroll_line_id = ppl.payroll_line_id
   AND    ppl.payroll_control_id = ppc.payroll_control_id
   AND    pdl.schedule_line_id = psl.schedule_line_id(+)
   AND    pdl.default_org_account_id = pod.organization_account_id(+)
   AND    pdl.element_account_id = pea.element_account_id(+)
   AND    pdl.org_schedule_id = pdls.org_schedule_id(+)
   AND    pdl.suspense_org_account_id = pos.organization_account_id(+)
   AND    pdl.gl_project_flag = 'P'
   AND    ppc.business_group_id = p_business_group_id
   AND    ppc.set_of_books_id = p_set_of_books_id
   AND    ppc.payroll_control_id = p_payroll_control_id
   ANd    pdl.cap_excess_project_id is null
   UNION
   SELECT ppg.person_id,
          ppg.assignment_id,
          nvl(pos.project_id,
              ppg.project_id) project_id,
          nvl(pos.expenditure_organization_id,
              ppg.expenditure_organization_id) expenditure_organization_id,
          nvl(ppg.suspense_auto_exp_type,    --- 5080403
          nvl(pos.expenditure_type,
              ppg.expenditure_type)) expenditure_type,
          nvl(pos.task_id,
              ppg.task_id) task_id,
          nvl(pos.award_id,
              ppg.award_id) award_id,
          ppg.dr_cr_flag,
          ppg.effective_date,
          ppc.gl_posting_override_date accounting_date,   -- for 3108109
          ppc.exchange_rate_type, -- added for 3108109
          ppg.distribution_amount,
          ppg.pre_gen_dist_line_id distribution_line_id,
	  NULL, -- Place holder for autopop details
          'P' tab_flag,
	DECODE(g_dff_grouping_option, 'Y', DECODE(ppg.suspense_org_account_id, NULL, ppg.attribute_category, pos.attribute_category), NULL) attribute_category,	-- Introduced DFF columns for bug fix 2908859
	DECODE(g_dff_grouping_option, 'Y', DECODE(ppg.suspense_org_account_id, NULL, ppg.attribute1, pos.attribute8), NULL) attribute1,
	DECODE(g_dff_grouping_option, 'Y', DECODE(ppg.suspense_org_account_id, NULL, ppg.attribute2, pos.attribute8), NULL) attribute2,
	DECODE(g_dff_grouping_option, 'Y', DECODE(ppg.suspense_org_account_id, NULL, ppg.attribute3, pos.attribute8), NULL) attribute3,
	DECODE(g_dff_grouping_option, 'Y', DECODE(ppg.suspense_org_account_id, NULL, ppg.attribute4, pos.attribute8), NULL) attribute4,
	DECODE(g_dff_grouping_option, 'Y', DECODE(ppg.suspense_org_account_id, NULL, ppg.attribute5, pos.attribute8), NULL) attribute5,
	DECODE(g_dff_grouping_option, 'Y', DECODE(ppg.suspense_org_account_id, NULL, ppg.attribute6, pos.attribute8), NULL) attribute6,
	DECODE(g_dff_grouping_option, 'Y', DECODE(ppg.suspense_org_account_id, NULL, ppg.attribute7, pos.attribute8), NULL) attribute7,
	DECODE(g_dff_grouping_option, 'Y', DECODE(ppg.suspense_org_account_id, NULL, ppg.attribute8, pos.attribute8), NULL) attribute8,
	DECODE(g_dff_grouping_option, 'Y', DECODE(ppg.suspense_org_account_id, NULL, ppg.attribute9, pos.attribute9), NULL) attribute9,
	DECODE(g_dff_grouping_option, 'Y', DECODE(ppg.suspense_org_account_id, NULL, ppg.attribute10, pos.attribute10), NULL) attribute10
          ---decode(ppg.suspense_org_Account_id, NULL, 'N', 'Y') Suspense_Flag   commented for 2663344
   FROM   psp_pre_gen_dist_lines     ppg,
          psp_organization_accounts  pos,
          psp_payroll_controls       ppc
   WHERE  ppg.status_code = 'N'
   /* changed following condn. First Pass can have suspense: Bug 2007521 */
   AND    ((ppg.gl_code_combination_id IS NULL  and pos.gl_code_combination_id is null) OR
		pos.project_id is not null)
   AND    ppc.payroll_control_id = p_payroll_control_id  --- 3108109
   AND    ppg.suspense_org_account_id = pos.organization_account_id(+)
   AND    ppg.payroll_control_id = p_payroll_control_id
   AND    ppg.set_of_books_id = p_set_of_books_id
   AND    ppg.payroll_control_id = p_payroll_control_id
   union
   SELECT ppl.person_id,
          ppl.assignment_id,
          nvl(pos.project_id, pdl.cap_excess_project_id) project_id,
          nvl(pos.expenditure_organization_id, pdl.cap_excess_exp_org_id) expenditure_organization_id,
          nvl(pos.expenditure_type, nvl(pdl.auto_expenditure_type, pdl.cap_excess_exp_type)) expenditure_type,
          nvl(pos.task_id, pdl.cap_excess_task_id) task_id,
          nvl(pos.award_id, pdl.cap_excess_award_id) award_id,
          ppl.dr_cr_flag,
          pdl.effective_date,
          nvl(ppc.gl_posting_override_date,ppl.accounting_date) accounting_date, --- added for 3108109
          nvl(ppc.exchange_rate_type,ppl.exchange_rate_type) exchange_rate_type,   --- added for 3108109
          pdl.distribution_amount,
          pdl.distribution_line_id  distribution_line_id,
	  pdl.auto_expenditure_type,
          'D' tab_flag,
	DECODE(g_dff_grouping_option, 'Y', DECODE(pdl.suspense_org_account_id, NULL, pdl.attribute_category, pos.attribute_category), NULL) attribute_category,	-- Introduced DFF columns for bug fix 2908859
	DECODE(g_dff_grouping_option, 'Y', DECODE(pdl.suspense_org_account_id, NULL, pdl.attribute1, pos.attribute8), NULL) attribute1,
	DECODE(g_dff_grouping_option, 'Y', DECODE(pdl.suspense_org_account_id, NULL, pdl.attribute2, pos.attribute8), NULL) attribute2,
	DECODE(g_dff_grouping_option, 'Y', DECODE(pdl.suspense_org_account_id, NULL, pdl.attribute3, pos.attribute8), NULL) attribute3,
	DECODE(g_dff_grouping_option, 'Y', DECODE(pdl.suspense_org_account_id, NULL, pdl.attribute4, pos.attribute8), NULL) attribute4,
	DECODE(g_dff_grouping_option, 'Y', DECODE(pdl.suspense_org_account_id, NULL, pdl.attribute5, pos.attribute8), NULL) attribute5,
	DECODE(g_dff_grouping_option, 'Y', DECODE(pdl.suspense_org_account_id, NULL, pdl.attribute6, pos.attribute8), NULL) attribute6,
	DECODE(g_dff_grouping_option, 'Y', DECODE(pdl.suspense_org_account_id, NULL, pdl.attribute7, pos.attribute8), NULL) attribute7,
	DECODE(g_dff_grouping_option, 'Y', DECODE(pdl.suspense_org_account_id, NULL, pdl.attribute8, pos.attribute8), NULL) attribute8,
	DECODE(g_dff_grouping_option, 'Y', DECODE(pdl.suspense_org_account_id, NULL, pdl.attribute9, pos.attribute9), NULL) attribute9,
	DECODE(g_dff_grouping_option, 'Y', DECODE(pdl.suspense_org_account_id, NULL, pdl.attribute10, pos.attribute10), NULL) attribute10
          ---decode(pdl.suspense_org_account_id, NULL, 'N', 'Y') Suspense_Flag uncommented for 2663344
   FROM   psp_organization_accounts       pos,
          psp_payroll_controls            ppc,
          psp_payroll_lines               ppl,
          psp_payroll_sub_lines           ppsl,
          psp_distribution_lines          pdl
   WHERE  pdl.status_code = 'N'
   AND    pdl.payroll_sub_line_id = ppsl.payroll_sub_line_id
   AND    ppsl.payroll_line_id = ppl.payroll_line_id
   AND    ppl.payroll_control_id = ppc.payroll_control_id
   AND    pdl.suspense_org_account_id = pos.organization_account_id(+)
   AND    pdl.gl_project_flag = 'P'
   AND    ppc.business_group_id = p_business_group_id
   AND    ppc.set_of_books_id = p_set_of_books_id
   AND    ppc.payroll_control_id = p_payroll_control_id
   AND    pdl.cap_excess_project_id is not null
   ORDER BY 1,2,3,4,5,6,7,8,10,11,16,17,18,19,20,21,22,23,24,25,26,9;

      --- added the order by attribute_category, attribute1 through attribute10 columns for BUG 6007017


   gms_sum_lines_rec			gms_sum_lines_cursor%ROWTYPE;
   payroll_control_rec			payroll_control_cur%ROWTYPE;

   l_person_id				NUMBER(9);
   l_assignment_id			NUMBER(9);
   l_project_id				NUMBER(15);
   l_expenditure_organization_id	NUMBER(15);
   l_expenditure_type			VARCHAR2(30);
   l_task_id				NUMBER(15);
   l_award_id				NUMBER(15);
   l_dr_cr_flag				VARCHAR2(1);
   l_effective_date			DATE;
   l_distribution_amount		NUMBER;
   l_rec_count				NUMBER := 0;
   l_summary_amount			NUMBER := 0;
   l_summary_line_id			NUMBER(10);

   l_attribute_category			VARCHAR2(30);			-- Introduced variables for storing DFF values for bug fix 2908859
   l_attribute1				VARCHAR2(150);
   l_attribute2				VARCHAR2(150);
   l_attribute3				VARCHAR2(150);
   l_attribute4				VARCHAR2(150);
   l_attribute5				VARCHAR2(150);
   l_attribute6				VARCHAR2(150);
   l_attribute7				VARCHAR2(150);
   l_attribute8				VARCHAR2(150);
   l_attribute9				VARCHAR2(150);
   l_attribute10			VARCHAR2(150);

   TYPE dist_id IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
   dist_line_id				dist_id;
   l_dist_line_id			      NUMBER;
   i					      BINARY_INTEGER := 0;
   j					      NUMBER;
   l_return_status			VARCHAR2(10);
   --- added following variables for 3108109
   l_exchange_rate_type                 VARCHAR2(30);
   l_accounting_date            DATE;
   l_value                      VARCHAR2(200);
   l_table                      VARCHAR2(100);
   l_period_end_date            DATE;
   l_begin_of_time              DATE := to_date('01/01/1900','dd/mm/yyyy');

  -- R12 MOAC Uptake
   l_org_id Number(15);

 BEGIN
  OPEN payroll_control_cur;
  LOOP
   FETCH payroll_control_cur INTO payroll_control_rec;
   IF payroll_control_cur%NOTFOUND THEN
     CLOSE payroll_control_cur;
     EXIT;
   END IF;
   -- added for 3108109
     BEGIN
       SELECT end_date
       INTO l_period_end_date
       FROM per_time_periods
       WHERE time_period_id = payroll_control_rec.time_period_id;
     EXCEPTION
       WHEN NO_DATA_FOUND THEN
         l_value := 'Time Period Id = '||to_char(payroll_control_rec.time_period_id);
         l_table := 'PER_TIME_PERIODS';
         fnd_message.set_name('PSP','PSP_TR_VALUE_NOT_FOUND');
         fnd_message.set_token('VALUE',l_value);
         fnd_message.set_token('TABLE',l_table);
         fnd_msg_pub.add;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END;


   OPEN gms_sum_lines_cursor(payroll_control_rec.payroll_control_id);
   l_rec_count := 0;
   l_summary_amount := 0;
   i := 0;
   LOOP
     FETCH gms_sum_lines_cursor INTO gms_sum_lines_rec;
     l_rec_count := l_rec_count + 1;
     IF gms_sum_lines_cursor%ROWCOUNT = 0 THEN
       CLOSE gms_sum_lines_cursor;
       EXIT;
     ELSIF gms_sum_lines_cursor%NOTFOUND THEN
       if (l_rec_count > 1) then
         update psp_payroll_controls
	    set phase =  'Summarize_GMS_Lines' ----2444657: Replaced NULL
          where payroll_control_id = payroll_control_rec.payroll_control_id;
       end if;
       CLOSE gms_sum_lines_cursor;
       EXIT;
     END IF;
     --

     IF l_rec_count = 1 THEN
       l_person_id		:= gms_sum_lines_rec.person_id;
       l_assignment_id		:= gms_sum_lines_rec.assignment_id;
       l_project_id             := gms_sum_lines_rec.project_id;
       l_expenditure_organization_id := gms_sum_lines_rec.expenditure_organization_id;
       l_expenditure_type       := gms_sum_lines_rec.expenditure_type;
       l_task_id                := gms_sum_lines_rec.task_id;
       l_award_id               := gms_sum_lines_rec.award_id;
       l_dr_cr_flag		:= gms_sum_lines_rec.dr_cr_flag;
       l_effective_date		:= gms_sum_lines_rec.effective_date;
       l_accounting_date        := gms_sum_lines_rec.accounting_date;  -- added 2 vars for 3108109
       l_exchange_rate_type     := gms_sum_lines_rec.exchange_rate_type;
	l_attribute_category	:= gms_sum_lines_rec.attribute_category;	-- Introduced DFF variable mapping for bug fix 2908859
	l_attribute1		:= gms_sum_lines_rec.attribute1;
	l_attribute2		:= gms_sum_lines_rec.attribute2;
	l_attribute3		:= gms_sum_lines_rec.attribute3;
	l_attribute4		:= gms_sum_lines_rec.attribute4;
	l_attribute5		:= gms_sum_lines_rec.attribute5;
	l_attribute6		:= gms_sum_lines_rec.attribute6;
	l_attribute7		:= gms_sum_lines_rec.attribute7;
	l_attribute8		:= gms_sum_lines_rec.attribute8;
	l_attribute9		:= gms_sum_lines_rec.attribute9;
	l_attribute10		:= gms_sum_lines_rec.attribute10;
     END IF;

     IF l_person_id <> gms_sum_lines_rec.person_id OR
        l_assignment_id <> gms_sum_lines_rec.assignment_id OR
        l_project_id <> gms_sum_lines_rec.project_id OR
        l_expenditure_organization_id <> gms_sum_lines_rec.expenditure_organization_id OR
        l_expenditure_type <> gms_sum_lines_rec.expenditure_type OR
        l_task_id <> gms_sum_lines_rec.task_id OR
        l_award_id <> gms_sum_lines_rec.award_id OR
        l_dr_cr_flag <> gms_sum_lines_rec.dr_cr_flag  OR
	(NVL(l_attribute_category, 'NULL') <> NVL(gms_sum_lines_rec.attribute_category, 'NULL')) OR	-- Introduced DFF columns checks for bug fix 2908859
	(NVL(l_attribute1, 'NULL') <> NVL(gms_sum_lines_rec.attribute1, 'NULL')) OR
	(NVL(l_attribute2, 'NULL') <> NVL(gms_sum_lines_rec.attribute2, 'NULL')) OR
	(NVL(l_attribute3, 'NULL') <> NVL(gms_sum_lines_rec.attribute3, 'NULL')) OR
	(NVL(l_attribute4, 'NULL') <> NVL(gms_sum_lines_rec.attribute4, 'NULL')) OR
	(NVL(l_attribute5, 'NULL') <> NVL(gms_sum_lines_rec.attribute5, 'NULL')) OR
	(NVL(l_attribute6, 'NULL') <> NVL(gms_sum_lines_rec.attribute6, 'NULL')) OR
	(NVL(l_attribute7, 'NULL') <> NVL(gms_sum_lines_rec.attribute7, 'NULL')) OR
	(NVL(l_attribute8, 'NULL') <> NVL(gms_sum_lines_rec.attribute8, 'NULL')) OR
	(NVL(l_attribute9, 'NULL') <> NVL(gms_sum_lines_rec.attribute9, 'NULL')) OR
	(NVL(l_attribute10, 'NULL') <> NVL(gms_sum_lines_rec.attribute10, 'NULL')) OR
        nvl(l_accounting_date,l_begin_of_time) <>
              nvl(gms_sum_lines_rec.accounting_date,l_begin_of_time) OR
        nvl(l_exchange_rate_type,'-999') <>
              nvl(gms_sum_lines_rec.exchange_rate_type,'-999')
	THEN

        -- If it is a Debit entry, it is passed as a +ve entry to Oracle Projects
        -- If it is a Credit entry, it is passed as a -ve entry to Oracle Projects
        IF l_dr_cr_flag = 'C' THEN
          l_summary_amount := 0 - l_summary_amount;
        END IF;

-- R12 MOAC Uptake
	l_org_id := psp_general.Get_transaction_org_id (l_project_id,l_expenditure_organization_id);

		-- insert into summary lines
        insert_into_summary_lines(
            l_summary_line_id,
		l_person_id,
		l_assignment_id,
            payroll_control_rec.time_period_id,
 		l_effective_date,
                nvl(l_accounting_date,l_period_end_date), --- added for 3108109
                l_exchange_rate_type,
            payroll_control_rec.source_type,
 		payroll_control_rec.payroll_source_code,
            payroll_control_rec.set_of_books_id,
            NULL,
 		l_project_id,
 		l_expenditure_organization_id,
 		l_expenditure_type,
 		l_task_id,
 		l_award_id,
 		l_summary_amount,
 		l_dr_cr_flag,
 		'N',
            payroll_control_rec.batch_name,
            payroll_control_rec.payroll_control_id,
	    payroll_control_rec.business_group_id,
		l_attribute_category,			-- Introduced DFF columns for bug fix 2908859
		l_attribute1,
		l_attribute2,
		l_attribute3,
		l_attribute4,
		l_attribute5,
		l_attribute6,
		l_attribute7,
		l_attribute8,
		l_attribute9,
		l_attribute10,
        l_return_status,
		l_org_id       -- R12 MOAC Uptake
		);

       IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

       FOR j IN 1 .. dist_line_id.COUNT LOOP
         l_dist_line_id := dist_line_id(j);
         --dbms_output.put_line('Dist_line_id to be updated = '||to_char(l_dist_line_id));

         IF gms_sum_lines_rec.tab_flag = 'D' THEN
           UPDATE psp_distribution_lines
           SET summary_line_id = l_summary_line_id WHERE distribution_line_id = l_dist_line_id;
         ELSIF gms_sum_lines_rec.tab_flag = 'P' THEN
           UPDATE psp_pre_gen_dist_lines
           SET summary_line_id = l_summary_line_id WHERE pre_gen_dist_line_id = l_dist_line_id;
         END IF;
       END LOOP;

       -- initialise the summary amount and dist_line_id
       l_summary_amount := 0;
       dist_line_id.delete;
       i := 0;
     END IF;

     l_person_id			:= gms_sum_lines_rec.person_id;
     l_assignment_id		:= gms_sum_lines_rec.assignment_id;
     l_project_id               := gms_sum_lines_rec.project_id;
     l_expenditure_organization_id := gms_sum_lines_rec.expenditure_organization_id;
     l_expenditure_type         := gms_sum_lines_rec.expenditure_type;
     l_task_id                  := gms_sum_lines_rec.task_id;
     l_award_id                 := gms_sum_lines_rec.award_id;
     l_dr_cr_flag			:= gms_sum_lines_rec.dr_cr_flag;
     l_effective_date		:= gms_sum_lines_rec.effective_date;
     l_accounting_date          := gms_sum_lines_rec.accounting_date;  --- 3108109
     l_exchange_rate_type       := gms_sum_lines_rec.exchange_rate_type;
	l_attribute_category	:= gms_sum_lines_rec.attribute_category;	-- Introduced DFF variable mapping for bug fix 2908859
	l_attribute1		:= gms_sum_lines_rec.attribute1;
	l_attribute2		:= gms_sum_lines_rec.attribute2;
	l_attribute3		:= gms_sum_lines_rec.attribute3;
	l_attribute4		:= gms_sum_lines_rec.attribute4;
	l_attribute5		:= gms_sum_lines_rec.attribute5;
	l_attribute6		:= gms_sum_lines_rec.attribute6;
	l_attribute7		:= gms_sum_lines_rec.attribute7;
	l_attribute8		:= gms_sum_lines_rec.attribute8;
	l_attribute9		:= gms_sum_lines_rec.attribute9;
	l_attribute10		:= gms_sum_lines_rec.attribute10;

     l_summary_amount := l_summary_amount + gms_sum_lines_rec.distribution_amount;
     i := i + 1;
     dist_line_id(i) := gms_sum_lines_rec.distribution_line_id;


   END LOOP;

   IF l_dr_cr_flag = 'C' Then
	l_summary_amount := 0 - l_summary_amount;
   END IF;

   IF l_rec_count > 1 THEN
     -- insert into summary lines

-- R12 MOAC Uptake
	l_org_id := psp_general.Get_transaction_org_id (l_project_id,l_expenditure_organization_id);

	 insert_into_summary_lines(
            l_summary_line_id,
		l_person_id,
		l_assignment_id,
            payroll_control_rec.time_period_id,
 		l_effective_date,
                nvl(l_accounting_date,l_period_end_date),  --- 3108109
                l_exchange_rate_type,
            payroll_control_rec.source_type,
 		payroll_control_rec.payroll_source_code,
            payroll_control_rec.set_of_books_id,
 		NULL,
 		l_project_id,
 		l_expenditure_organization_id,
 		l_expenditure_type,
 		l_task_id,
 		l_award_id,
 		l_summary_amount,
 		l_dr_cr_flag,
 		'N',
            payroll_control_rec.batch_name,
            payroll_control_rec.payroll_control_id,
	    payroll_control_rec.business_group_id,
		l_attribute_category,			-- Introduced DFF columns for bug fix 2908859
		l_attribute1,
		l_attribute2,
		l_attribute3,
		l_attribute4,
		l_attribute5,
		l_attribute6,
		l_attribute7,
		l_attribute8,
		l_attribute9,
		l_attribute10,
        l_return_status,
		l_org_id		-- R12 MOAC uptake
		);

     IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

     FOR j IN 1 .. dist_line_id.COUNT LOOP
       l_dist_line_id := dist_line_id(j);
       --dbms_output.put_line('Dist_line_id to be updated = '||to_char(l_dist_line_id));

       IF gms_sum_lines_rec.tab_flag = 'D' THEN
         UPDATE psp_distribution_lines
         SET summary_line_id = l_summary_line_id,
             status_code = 'N'
         WHERE distribution_line_id = l_dist_line_id;
       ELSIF gms_sum_lines_rec.tab_flag = 'P' THEN
         UPDATE psp_pre_gen_dist_lines
         SET summary_line_id = l_summary_line_id,
             status_code = 'N'
         WHERE pre_gen_dist_line_id = l_dist_line_id;
       END IF;
     END LOOP;
     dist_line_id.delete;
   END IF;
  END LOOP;
  --
  p_return_status := fnd_api.g_ret_sts_success;


 EXCEPTION

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     g_error_api_path := 'CREATE_GMS_SUM_LINES:'||g_error_api_path;
     p_return_status := fnd_api.g_ret_sts_unexp_error;
   WHEN OTHERS THEN
     g_error_api_path := 'CREATE_GMS_SUM_LINES:'||g_error_api_path;
     fnd_msg_pub.add_exc_msg('PSP_SUM_TRANS','CREATE_GMS_SUM_LINES');
     p_return_status := fnd_api.g_ret_sts_unexp_error;

 END;

----------------------------- GMS INTERFACE ---------------------------------------------
 PROCEDURE transfer_to_gms_interface(p_source_type     IN VARCHAR2,
                                     p_source_code     IN VARCHAR2,
                                     p_time_period_id  IN NUMBER,
                                     p_batch_name      IN VARCHAR2,
				     p_business_group_id IN NUMBER,
				     p_set_of_books_id   IN NUMBER,
                                     p_return_status  OUT NOCOPY VARCHAR2) IS

   CURSOR gms_batch_cursor IS
   SELECT payroll_control_id,
          source_type,
          payroll_source_code,
          time_period_id,
          batch_name,
--      Introduced the following currency_code,exchange_rate_type  for bug 2916848
          Currency_code,
          exchange_rate_type,
          phase                   --- added for 2444657
   FROM   psp_payroll_controls
   WHERE status_code = 'I'
   AND    source_type <> 'A'
   AND    run_id = g_run_id
   AND    phase in ('Summarize_GMS_Lines','Submitted_TI_Request');

   CURSOR gms_interface_cursor(P_PAYROLL_CONTROL_ID  IN  NUMBER) IS
   SELECT psl.summary_line_id,
          psl.source_code,
          psl.person_id,
          psl.assignment_id,
          NVL(psl.gms_posting_effective_date,psl.effective_date) effective_date, /* Column modified for Enhancement Employee Assignment with Zero Work Days */
          psl.accounting_date, --- added 2 cols for 3108109
          psl.exchange_Rate_type,
          psl.project_id,
          psl.expenditure_organization_id,
          psl.expenditure_type,
          psl.task_id,
          psl.award_id,
          psl.summary_amount,
          psl.dr_cr_flag,
          psl.attribute1,		-- Introduced attributes 1, 4 and 5 for bug fix 2908859
          psl.attribute2,
          psl.attribute3,
          psl.attribute4,
          psl.attribute5,
          psl.attribute6,
          psl.attribute7,
          psl.attribute8,
          psl.attribute9,
          psl.attribute10,
		  org_id
   FROM  psp_summary_lines  psl
   WHERE psl.status_code = 'N'
   AND   psl.gl_code_combination_id IS NULL
   AND   psl.payroll_control_id = p_payroll_control_id;

   gms_batch_rec			gms_batch_cursor%ROWTYPE;
   gms_interface_rec		gms_interface_cursor%ROWTYPE;
   l_transaction_source		VARCHAR2(30);
   l_expenditure_comment	VARCHAR2(240);
   l_employee_number		VARCHAR2(30);
   l_org_name			hr_all_organization_units_tl.name%TYPE;	-- Bug 2447912: Modified declaration
   l_segment1			VARCHAR2(25);
   l_task_number			VARCHAR2(25);
   l_gms_batch_name		VARCHAR2(10);
   l_expenditure_ending_date	DATE;
   l_period_name			VARCHAR2(35);
   l_period_end_date		DATE;               ----uncommented for 2663344
   l_return_status		VARCHAR2(50);  --- increased the size from 10 for 2671594
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
-- Populate the GMS_TRANSACTION_INTERFACE table also.
   gms_rec			gms_transaction_interface_all%ROWTYPE;
   l_gms_transaction_source	VARCHAR2(20);
   l_txn_source			VARCHAR2(30);
--   l_org_id			NUMBER(15);       -- Commented for R12 MOAC uptake
   l_txn_interface_id		NUMBER(15);
	l_gms_install		BOOLEAN	DEFAULT gms_install.enabled;

 -- R12 MOAC Uptake
	TYPE ORG_ID_TYPE IS TABLE OF NUMBER(15) INDEX BY BINARY_INTEGER;
    ORG_ID_TAB  ORG_ID_TYPE;

	TYPE gms_batch_name_TYPE IS TABLE OF varchar2(10) INDEX BY BINARY_INTEGER;
    gms_batch_name_TAB gms_batch_name_TYPE;

 	TYPE req_id_TYPE is TABLE OF 	NUMBER(15) INDEX BY BINARY_INTEGER;
    req_id_TAB req_id_TYPE;

	TYPE call_status_TYPE IS TABLE OF BOOLEAN INDEX BY BINARY_INTEGER;
    call_status_TAB call_status_TYPE;


	Cursor operating_unit_csr(p_payroll_control_id  IN  NUMBER) IS  -- change
	SELECT Distinct org_id
	FROM  psp_summary_lines  psl
	WHERE psl.status_code = 'N'
	AND   psl.gl_code_combination_id IS NULL
	AND   psl.payroll_control_id = p_payroll_control_id;

	temp_org_id Number(15);

 BEGIN

   -- get the source name
   BEGIN
     SELECT transaction_source
     INTO   l_transaction_source
     FROM   pa_transaction_sources
     WHERE  transaction_source = 'OLD';
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       l_error := 'TRANSACTION SOURCE = OLD';
       l_product := 'PA';
       fnd_message.set_name('PSP','PSP_TR_NOT_SET_UP');
       fnd_message.set_token('ERROR',l_error);
       fnd_message.set_token('PRODUCT',l_product);
       fnd_msg_pub.add;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END;

   if (l_gms_install) then			-- Changed site_enabled check to l_gms_install check for bug fix 2908859
   BEGIN
     SELECT transaction_source
     INTO   l_gms_transaction_source
     FROM   pa_transaction_sources
     WHERE  transaction_source = 'GOLD';
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       l_error := 'TRANSACTION SOURCE = GOLD';
       l_product := 'GMS';
       fnd_message.set_name('PSP','PSP_TR_NOT_SET_UP');
       fnd_message.set_token('ERROR',l_error);
       fnd_message.set_token('PRODUCT',l_product);
       fnd_msg_pub.add;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END;
   end if;

   OPEN gms_batch_cursor;
   LOOP
     FETCH gms_batch_cursor INTO gms_batch_rec;
     IF gms_batch_cursor%NOTFOUND THEN
       CLOSE gms_batch_cursor;
       EXIT;
     END IF ;


	 -- get the period_name (moved this statement from below for 2444657)
     BEGIN
      -- uncommented period end date for 2663344
       SELECT substr(period_name ,1,35),end_date
       INTO l_period_name ,l_period_end_date
       FROM per_time_periods
       WHERE time_period_id = gms_batch_rec.time_period_id;
     EXCEPTION
       WHEN NO_DATA_FOUND THEN
         l_value := 'Time Period Id = '||to_char(gms_batch_rec.time_period_id);
         l_table := 'PER_TIME_PERIODS';
         fnd_message.set_name('PSP','PSP_TR_VALUE_NOT_FOUND');
         fnd_message.set_token('VALUE',l_value);
         fnd_message.set_token('TABLE',l_table);
         fnd_msg_pub.add;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END;

	-- R12 MOAC Uptake .. org_id array to always populate 5090047
        -- moved If condin  below
	ORG_ID_TAB.delete;
	gms_batch_name_TAB.delete;
	req_id_TAB.delete;
	call_status_TAB.delete;

	OPEN  operating_unit_csr(gms_batch_rec.payroll_control_id);  -- change
	FETCH operating_unit_csr BULK COLLECT INTO org_id_tab;
	CLOSE operating_unit_csr ;

    IF gms_batch_rec.phase = 'Summarize_GMS_Lines' then  --2444657

	FOR I in 1..org_id_tab.count
	LOOP
	 SELECT to_char(psp_gms_batch_name_s.nextval)
     INTO gms_batch_name_tab(i)
     FROM dual;
	END LOOP;
/*
	 -- get the group_id
	 SELECT to_char(psp_gms_batch_name_s.nextval)
     INTO l_gms_batch_name
     FROM dual;
*/
	-- R12 MOAC Uptake. Moved this code to loop
	 -- update psp_summary_lines with gms batch name
    FOR I in 1..org_id_tab.count
	LOOP
		 UPDATE psp_summary_lines
		 SET gms_batch_name = gms_batch_name_tab(i)				 -- R12 MOAC uptake. changed from l_gms_batch_name
		 WHERE payroll_control_id = gms_batch_rec.payroll_control_id
		 AND   status_code = 'N'
		 AND   gl_code_combination_id IS NULL
		 AND   org_id = org_id_tab(i);  	-- R12 MOAC uptake
	END LOOP;


     l_expenditure_comment := gms_batch_rec.source_type||':'||gms_batch_rec.payroll_source_code||':'||l_period_name||':'||gms_batch_rec.batch_name;

--     l_interface_id := pa_txn_interface_s.nextval;

     OPEN gms_interface_cursor(gms_batch_rec.payroll_control_id);
     l_rec_count := 0;
     LOOP
       FETCH gms_interface_cursor INTO gms_interface_rec;
       IF gms_interface_cursor%NOTFOUND THEN
         CLOSE gms_interface_cursor;
         EXIT;
       END IF;
       l_rec_count := l_rec_count + 1;

       -- get the employee number
       BEGIN
         SELECT employee_number
         INTO l_employee_number
         FROM per_people_f
         WHERE person_id = gms_interface_rec.person_id
         AND gms_interface_rec.effective_date BETWEEN effective_start_date AND effective_end_date;
       EXCEPTION
         WHEN NO_DATA_FOUND THEN
           l_value := 'Person Id = '||to_char(gms_interface_rec.person_id);
           l_table := 'PER_PEOPLE_F';
           fnd_message.set_name('PSP','PSP_TR_VALUE_NOT_FOUND');
           fnd_message.set_token('VALUE',l_value);
           fnd_message.set_token('TABLE',l_table);
           fnd_msg_pub.add;
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END;

       -- get the employee's organization name
       BEGIN
--        SELECT substr(name,1,60)	Commented for bug fix 2447912
        SELECT name			-- Removed SUBSTR for bug fix 2447912
        INTO  l_org_name
        FROM  hr_all_organization_units hou
        WHERE organization_id = gms_interface_rec.expenditure_organization_id;
       EXCEPTION
         WHEN NO_DATA_FOUND THEN
           l_value := 'Organization Id = '||to_char(gms_interface_rec.expenditure_organization_id);
           l_table := 'HR_ORGANIZATION_UNITS';
           fnd_message.set_name('PSP','PSP_TR_VALUE_NOT_FOUND');
           fnd_message.set_token('VALUE',l_value);
           fnd_message.set_token('TABLE',l_table);
           fnd_msg_pub.add;
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           --l_org_name := NULL;
           --l_org_name := 'LDM_ORG_NAME_INVALID';
       END;

       -- get the project number
	 BEGIN
         SELECT segment1
         INTO   l_segment1
         FROM   pa_projects_all
         WHERE  project_id = gms_interface_rec.project_Id;
       EXCEPTION
         WHEN NO_DATA_FOUND THEN
           l_value := 'Project Id = '||to_char(gms_interface_rec.project_Id);
           l_table := 'PA_PROJECTS_ALL';
           fnd_message.set_name('PSP','PSP_TR_VALUE_NOT_FOUND');
           fnd_message.set_token('VALUE',l_value);
           fnd_message.set_token('TABLE',l_table);
           fnd_msg_pub.add;
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END;

-- R12 MOAC Uptake. Org_id is stored in psp_summary_line Table
/*
-- get the org_id for the project..
	 BEGIN
         SELECT org_id
         INTO   l_org_id
         FROM   pa_projects_all
         WHERE  project_id = gms_interface_rec.project_Id;
       EXCEPTION
         WHEN NO_DATA_FOUND THEN
           l_value := 'Project Id = '||to_char(gms_interface_rec.project_Id);
           l_table := 'PA_PROJECTS_ALL';
           fnd_message.set_name('PSP','PSP_ORG_VALUE_NOT_FOUND');
           fnd_message.set_token('VALUE',l_value);
           fnd_message.set_token('TABLE',l_table);
           fnd_msg_pub.add;
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END;
*/

       -- get the task number
       BEGIN
         SELECT task_number
         INTO  l_task_number
         FROM  pa_tasks
         WHERE task_id = gms_interface_rec.task_id;
       EXCEPTION
         WHEN NO_DATA_FOUND THEN
           l_value := 'Task Id = '||to_char(gms_interface_rec.task_id);
           l_table := 'PA_TASKS';
           fnd_message.set_name('PSP','PSP_TR_VALUE_NOT_FOUND');
           fnd_message.set_token('VALUE',l_value);
           fnd_message.set_token('TABLE',l_table);
           fnd_msg_pub.add;
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END;

--  Get the transaction_interface_id. We need this to populate the gms_interface table.

     select pa_txn_interface_s.nextval
       into l_txn_interface_id
       from dual;

       -- get the expenditure week ending date

	-- set the context to single to call pa_utils function
	mo_global.set_policy_context('S', gms_interface_rec.org_id );

       l_expenditure_ending_date := pa_utils.GetWeekending(gms_interface_rec.effective_date);

	-- set the context again to multiple
	mo_global.set_policy_context('M', null);


--

 --      dbms_output.put_line('Inserting into pa interface.............');

--	if gms_interface_rec.award_id is not null then		Commented for bug fix 2908859
	if (l_gms_install) then		-- Introduced for bug fix 2908859
	   l_txn_source := l_gms_transaction_source;
	else
	   l_txn_source := l_transaction_source;
	end if;

 --R12 MOAC Uptake
	FOR I in 1..org_id_tab.count
	LOOP
		IF org_id_tab(I) = gms_interface_rec.org_id THEN
			l_gms_batch_name := gms_batch_name_tab(I);
			EXIT;
		END IF;
	END LOOP;



--  Modified g_currency_code to gms_batch_rec.currency_code,Introduced Actual_exchange_rate_type
--  actual rate_date for Bug 2916848

IF (gms_batch_rec.currency_code <> 'STAT') THEN
       insert_into_pa_interface(l_txn_interface_id,
	l_txn_source, L_GMS_BATCH_NAME,L_EXPENDITURE_ENDING_DATE,
	L_EMPLOYEE_NUMBER,L_ORG_NAME,GMS_INTERFACE_REC.EFFECTIVE_DATE,
	L_SEGMENT1,L_TASK_NUMBER,GMS_INTERFACE_REC.EXPENDITURE_TYPE,
	1,GMS_INTERFACE_REC.SUMMARY_AMOUNT,L_EXPENDITURE_COMMENT,
--	'P',GMS_INTERFACE_REC.SUMMARY_LINE_ID,GMS_INTERFACE_REC.AWARD_ID,
-- Award details are populated into GMS_INT
	'P', GMS_INTERFACE_REC.SUMMARY_LINE_ID, GMS_INTERFACE_REC.ORG_ID,gms_batch_rec.CURRENCY_CODE ,
	GMS_INTERFACE_REC.SUMMARY_AMOUNT, gms_interface_rec.attribute1, 	--Changed NULL vale for Attribute1 to interface value for bug fix 2908859
	GMS_INTERFACE_REC.ATTRIBUTE2,GMS_INTERFACE_REC.ATTRIBUTE3,
	GMS_INTERFACE_REC.ATTRIBUTE4,GMS_INTERFACE_REC.ATTRIBUTE5,		-- Introduced attributes 4 and 5 for bug fix 2908859
	GMS_INTERFACE_REC.ATTRIBUTE6,GMS_INTERFACE_REC.ATTRIBUTE7,
	GMS_INTERFACE_REC.ATTRIBUTE8,GMS_INTERFACE_REC.ATTRIBUTE9,
	GMS_INTERFACE_REC.ATTRIBUTE10,
        GMS_INTERFACE_REC.EXCHANGE_RATE_TYPE,
        gms_interface_rec.accounting_date,-- Introduced for bug 2916848 Ilo Ehn Mrc
	p_business_group_id,--Introduced for bug 2935850
	L_RETURN_STATUS);

       IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         --dbms_output.put_line('Faaaaaaiiiiiiilllllllleeeeeeeeeddddddd......');
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

  ELSE
    insert_into_pa_interface(l_txn_interface_id,
	l_txn_source, L_GMS_BATCH_NAME,L_EXPENDITURE_ENDING_DATE,
	L_EMPLOYEE_NUMBER,L_ORG_NAME,GMS_INTERFACE_REC.EFFECTIVE_DATE,
	L_SEGMENT1,L_TASK_NUMBER,GMS_INTERFACE_REC.EXPENDITURE_TYPE,
	GMS_INTERFACE_REC.SUMMARY_AMOUNT, 0,L_EXPENDITURE_COMMENT,
	'P', GMS_INTERFACE_REC.SUMMARY_LINE_ID, GMS_INTERFACE_REC.ORG_ID,gms_batch_rec.CURRENCY_CODE ,
	GMS_INTERFACE_REC.SUMMARY_AMOUNT, gms_interface_rec.attribute1, 	--Changed NULL vale for Attribute1 to interface value for bug fix 2908859
	GMS_INTERFACE_REC.ATTRIBUTE2,GMS_INTERFACE_REC.ATTRIBUTE3,
	GMS_INTERFACE_REC.ATTRIBUTE4,GMS_INTERFACE_REC.ATTRIBUTE5,		-- Introduced attributes 4 and 5 for bug fix 2908859
	GMS_INTERFACE_REC.ATTRIBUTE6,GMS_INTERFACE_REC.ATTRIBUTE7,
	GMS_INTERFACE_REC.ATTRIBUTE8,GMS_INTERFACE_REC.ATTRIBUTE9,
	GMS_INTERFACE_REC.ATTRIBUTE10,
        GMS_INTERFACE_REC.EXCHANGE_RATE_TYPE,
        gms_interface_rec.accounting_date,-- Introduced for bug 2916848 Ilo Ehn Mrc
	p_business_group_id,--Introduced for bug 2935850
	L_RETURN_STATUS);

	 IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	 END IF;

  END IF;


	if (gms_interface_rec.award_id is not null) then

        GMS_REC.TXN_INTERFACE_ID 	    :=  l_txn_interface_id;
	GMS_REC.BATCH_NAME 	            := l_gms_batch_name;
	GMS_REC.TRANSACTION_SOURCE 	    := l_gms_transaction_source;
	GMS_REC.EXPENDITURE_ENDING_DATE     := l_expenditure_ending_date;
	GMS_REC.EXPENDITURE_ITEM_DATE 	    := gms_interface_rec.effective_date;
	GMS_REC.PROJECT_NUMBER 	  	    := l_segment1;
	GMS_REC.TASK_NUMBER 	  	    := l_task_number;
	GMS_REC.AWARD_ID 	    	    := gms_interface_rec.award_id;
	GMS_REC.EXPENDITURE_TYPE 	    := gms_interface_rec.expenditure_type;
	GMS_REC.TRANSACTION_STATUS_CODE     := 'P';
	GMS_REC.ORIG_TRANSACTION_REFERENCE  := gms_interface_rec.summary_line_id;
	GMS_REC.ORG_ID 	  		    := GMS_INTERFACE_REC.org_id;
	GMS_REC.SYSTEM_LINKAGE		    := NULL;
	GMS_REC.USER_TRANSACTION_SOURCE     := NULL;
	GMS_REC.TRANSACTION_TYPE 	    := NULL;
	GMS_REC.BURDENABLE_RAW_COST 	    := gms_interface_rec.summary_amount;
	GMS_REC.FUNDING_PATTERN_ID 	    := NULL;

	gms_transactions_pub.LOAD_GMS_XFACE_API(gms_rec, l_return_status);

       IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

       end if;

     END LOOP;
    else --- 2444657   --- phase = 'Submitted_TI_Request'
     for i in 1..org_id_tab.count
     loop
     select gms_batch_name
     into gms_batch_name_tab(i)  -- change
     from psp_summary_lines
     where payroll_control_id = gms_batch_rec.payroll_control_id
       and org_id = org_id_tab(i)
       and project_id is not null
       and rownum = 1;
     end loop;
       if (l_gms_install) then   --- fix for 5090047
          l_txn_source := l_gms_transaction_source;
       else
          l_txn_source := l_transaction_source;
       end if;
       hr_utility.trace(' deriving l_txn_source = '|| l_txn_source);
    end if; --- phase = 'Summarize_GL_Lines' ..2444657
    IF l_rec_count > 0 and gms_batch_rec.phase = 'Summarize_GMS_Lines' THEN ---2444657  -- change

    g_skip_flag_gms := 'N';

    IF (g_create_stat_batch_in_gms = 'N' and gms_batch_rec.CURRENCY_CODE = 'STAT') then
                -- Added this IF for bug 6902514
               g_skip_flag_gms := 'Y';
           req_id := 1;

    ELSE

    		g_skip_flag_gms := 'N'; -- added for bug 6902514

     		FOR I in 1..org_id_tab.count
		LOOP
			l_gms_batch_name := gms_batch_name_tab(I);

			-- set the context to single to submit_request
			mo_global.set_policy_context('S', org_id_tab(I) );
			fnd_request.set_org_id (org_id_tab(I) );

			 req_id_tab(i) := fnd_request.submit_request(
                                 'PA',
                                 'PAXTRTRX',
                                 NULL,
                                 NULL,
                                 FALSE,
                                 l_txn_source, -- should be  l_txn_source rather than l_transaction_source,
                                 l_gms_batch_name);

		    IF req_id = 0 THEN
		       fnd_message.set_name('PSP','PSP_TR_GMS_IMP_FAILED');
		       fnd_msg_pub.add;
		       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
			END IF;
		END LOOP;

   END IF; -- g_create_stat_batch_in_gms  -- change

		update psp_payroll_controls
		set phase = 'Submitted_TI_Request'
		WHERE payroll_control_id = gms_batch_rec.payroll_control_id;

		commit;

		IF g_skip_flag_gms = 'N' THEN  -- bug 6902514  -- change

		 FOR I in 1..org_id_tab.count
		 LOOP
			call_status_tab(I) := fnd_concurrent.wait_for_request(req_id_tab(I), 20, 0,
				                rphase, rstatus, dphase, dstatus, message);
			IF call_status_tab(I) = FALSE then
				 fnd_message.set_name('PSP','PSP_TR_GMS_IMP_FAILED');
		         fnd_msg_pub.add;
				 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
			END IF;
		 END LOOP;

		END IF; -- g_skip_flag_gms  -- change

       gms_batch_rec.phase := 'Submitted_TI_Request'; ---2444657
    END IF;   --- 2444657 end rec_count > 0

	-- set the context again to multiple
	mo_global.set_policy_context('M', null);

   IF gms_batch_rec.phase =  'Submitted_TI_Request' then  --2444657
             ---- added below for 5742525
	IF FND_PROFILE.VALUE('PSP_ST_EXTENSION_ENABLE') = 'Y' THEN
              psp_st_ext.tieback_actual(gms_batch_rec.payroll_control_id ,
                           gms_batch_rec.source_type        ,
                           l_period_end_date    ,
                           l_gms_batch_name     ,
                           l_txn_source,
                           p_business_group_id  ,
                           p_set_of_books_id    );
         ENd if;

    -- mark the successfully transferred records as 'A' in psp_summary_lines and psp_distribution_lines
    -- and transfer the successful records to the history table
--- Bug 2663344 reverted  NULL to l_period_end_date in tie back call
          hr_utility.trace(' before loop for gms_tie_back');
		FOR I in 1..org_id_tab.count
		LOOP
          hr_utility.trace(' tab_count ='||i);
			l_gms_batch_name := gms_batch_name_tab(I);
          hr_utility.trace(' tab_count 2nd time='||i);

			gms_tie_back(gms_batch_rec.payroll_control_id,
						gms_batch_rec.source_type,
						l_period_end_date,
						l_gms_batch_name,
						p_business_group_id,
						p_set_of_books_id,
						l_txn_source,
						'N',		--Introduced as part of Bug fix #1776606
						l_return_status);
          hr_utility.trace(' after tie back call to  gms_tie_back');

     /* Bug 1617846 LD Recovery LOV not showing up fialed S and T */
     /* introduced ELSE clause */

			IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
				RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
--			ELSE   --Commented for R12 MOAc uptake;
        --- moved update psp_payroll_control phase = Tie back inside gms_tie_back
         --- for 2444657
--				commit;    --Commented for R12 MOAc uptake
		     END IF;
		END LOOP;
		commit; -- R12 MOAc uptake; moved commit from above
	END IF;
   END LOOP;

   --
   p_return_status := fnd_api.g_ret_sts_success;
 EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     g_error_api_path := 'TRANSFER_TO_GMS_INTERFACE:'||g_error_api_path;
     p_return_status := fnd_api.g_ret_sts_unexp_error;

   WHEN RETURN_BACK THEN
     p_return_status := fnd_api.g_ret_sts_success;

   WHEN OTHERS THEN
     g_error_api_path := 'TRANSFER_TO_GMS_INTERFACE:'||g_error_api_path;
     fnd_msg_pub.add_exc_msg('PSP_SUM_TRANS','TRANSFER_TO_GMS_INTERFACE');
     p_return_status := fnd_api.g_ret_sts_unexp_error;
 END;


------------------------- GMS TIE BACK ---------------------------------------------------
 PROCEDURE gms_tie_back(p_payroll_control_id  IN  NUMBER,
                        p_source_type         IN  VARCHAR2,
                        p_period_end_date     IN  DATE,
                        p_gms_batch_name	    IN  VARCHAR2,
			p_business_group_id  IN NUMBER,
			p_set_of_books_id    IN NUMBER,
			p_txn_source	     IN VARCHAR2,
			p_mode 		     IN VARCHAR2,	--Introduced as part of Bug fix #1776606
                        p_return_status	   OUT NOCOPY  VARCHAR2) IS
   CURSOR gms_tie_back_success_cur IS
   SELECT summary_line_id,
          dr_cr_flag,summary_amount
   FROM   psp_summary_lines
   WHERE  gms_batch_name = p_gms_batch_name;


   CURSOR gms_tie_back_reject_cur IS
--- SELECT nvl(transaction_rejection_code,'P'),  *****Bug 1866362***
   select transaction_rejection_code,
          orig_transaction_reference,
          transaction_status_code,
          expenditure_ending_date,   -- added following five columns for 2445196
          expenditure_id,
          interface_id,
          expenditure_item_id,
          txn_interface_id
   FROM   pa_transaction_interface_all
   WHERE  batch_name = p_gms_batch_name
     AND  transaction_source = p_txn_source;

   CURSOR assign_susp_ac_cur(P_SUMMARY_LINE_ID	IN	NUMBER) IS
   SELECT pdl.rowid,
	  pdl.distribution_line_id line_id,
          pdl.distribution_date,
          pdl.suspense_org_account_id
   FROM   psp_distribution_lines pdl
   WHERE  pdl.summary_line_id = p_summary_line_id
   UNION
   SELECT ppgd.rowid,
	  ppgd.pre_gen_dist_line_id line_id,
          ppgd.distribution_date,
          ppgd.suspense_org_account_id
   FROM   psp_pre_gen_dist_lines ppgd
   WHERE  ppgd.summary_line_id = p_summary_line_id;

   CURSOR get_susp_org_cur1 (P_ORG_ID	IN	VARCHAR2) IS
	  SELECT hou.organization_id, hou.name
	    FROM hr_all_organization_units hou, psp_organization_accounts poa
	   WHERE hou.organization_id = poa.organization_id
	     AND poa.business_group_id = p_business_group_id
	     AND poa.set_of_books_id = p_set_of_books_id
	     AND poa.organization_account_id = p_org_id;

   CURSOR get_org_id_cur1 (P_LINE_ID	IN	NUMBER) IS
	  SELECT hou.organization_id, hou.name
	    FROM hr_all_organization_units hou,
		 per_assignments_f paf,
		 psp_payroll_lines ppl,
		 psp_payroll_sub_lines ppsl,
		 psp_distribution_lines pdl
	   WHERE paf.assignment_id = ppl.assignment_id
	     AND hou.organization_id = paf.organization_id
	     AND pdl.distribution_line_id = p_line_id
	     AND ppsl.payroll_sub_line_id = pdl.payroll_sub_line_id
	     AND ppl.payroll_line_id = ppsl.payroll_line_id
	     AND pdl.distribution_date between paf.effective_start_date and paf.effective_end_date
	 UNION
	  SELECT hou.organization_id, hou.name
	    FROM hr_all_organization_units hou,
		 per_assignments_f paf,
		 psp_pre_gen_dist_lines ppgdl
	   WHERE paf.assignment_id = ppgdl.assignment_id
	     AND hou.organization_id = paf.organization_id
	     AND ppgdl.pre_gen_dist_line_id = p_line_id
	     AND ppgdl.distribution_date between paf.effective_start_date and paf.effective_end_date;

l_orig_org_name1	hr_all_organization_units_tl.name%TYPE;	-- Bug 2447912: Modified declaration
l_orig_org_id1		number;

   CURSOR org_susp_ac_cur(P_ORGANIZATION_ID	IN	NUMBER,
                          P_DISTRIBUTION_DATE	IN	DATE) IS
   SELECT poa.organization_account_id,
          poa.gl_code_combination_id,
          poa.project_id,
          poa.award_id,
          poa.task_id,   -- Line added by pvelamur for bug fix 897553
          poa.expenditure_organization_id,
          poa.expenditure_type
   FROM   psp_organization_accounts poa
   WHERE  poa.organization_id = p_organization_id
   AND    poa.account_type_code = 'S'
   AND    poa.business_group_id = p_business_group_id
   AND    poa.set_of_books_id = p_set_of_books_id
   AND    p_distribution_date BETWEEN poa.start_date_active AND
                                      nvl(poa.end_date_active,p_distribution_date);


-- CURSOR global_susp_ac_cur(P_DISTRIBUTION_DATE	IN	DATE) IS
   CURSOR global_susp_ac_cur(P_ORGANIZATION_ACCOUNT_ID	IN	NUMBER) IS --BUG 2056877.
   SELECT poa.organization_account_id,
          poa.gl_code_combination_id,
          poa.project_id,
          poa.award_id,
          poa.task_id,       -- Line added by pvelamur for bugfix 897553
          poa.expenditure_organization_id,
          poa.expenditure_type
   FROM   psp_organization_accounts poa
   WHERE
        /* poa.account_type_code = 'G'
   AND    poa.business_group_id = p_business_group_id
   AND    poa.set_of_books_id = p_set_of_books_id
   AND    p_distribution_date BETWEEN poa.start_date_active AND
                                      nvl(poa.end_date_active,p_distribution_date);Bug 2056877 */
          organization_account_id = p_organization_account_id;   --Added for bug 2056877.

   l_organization_name		hr_all_organization_units_tl.name%TYPE;	-- Bug 2447912: Modified declaration
   l_organization_id		NUMBER(15);
   l_rowid				ROWID;
   l_assignment_id		NUMBER(15);
   l_distribution_date		DATE;
   l_suspense_org_account_id  NUMBER(9);
   --
   l_organization_account_id	NUMBER(9);
   l_gl_code_combination_id   NUMBER(15);
   l_project_id			NUMBER(15);
   l_award_id			NUMBER(15);
   l_task_id                    NUMBER(15);
   --
   l_cnt_gms_interface		NUMBER;
   l_summary_line_id		NUMBER(10);
   l_gl_project_flag		VARCHAR2(1);
   l_suspense_ac_failed		VARCHAR2(1) := 'N';
   l_suspense_ac_not_found	VARCHAR2(1) := 'N';
   l_susp_ac_found		VARCHAR2(10) := 'TRUE';
   l_summary_amount		NUMBER;
   l_dr_summary_amount		NUMBER := 0;
   l_cr_summary_amount		NUMBER := 0;
   l_dr_cr_flag			VARCHAR2(1);
   --
   l_trx_status_code            VARCHAR2(2); /* Bug 1938458: Increased size from 1 to 2*/
   l_trx_reject_code		VARCHAR2(30);
   l_orig_trx_reference		VARCHAR2(30);
   l_effective_date		DATE;

   x_susp_failed_org_name	hr_all_organization_units_tl.name%TYPE;	-- Bug 2447912: Modified declaration
   x_susp_failed_reject_code	VARCHAR2(30);
   x_susp_failed_date		DATE;
   x_susp_nf_org_name		hr_all_organization_units_tl.name%TYPE;	-- Bug 2447912: Modified declaration
   x_susp_nf_date			DATE;
   l_return_status		VARCHAR2(10);
   x_line_id			NUMBER;
   l_no_run			NUMBER;
   l_trx_source			VARCHAR2(40);
   l_no_run_status		VARCHAR2(2);
   l_return_value               VARCHAR2(30);  --Added for bug 2056877.
   no_profile_exists            EXCEPTION;     --Added for bug 2056877.
   no_val_date_matches          EXCEPTION;     --Added for bug 2056877.
   no_global_acct_exists        EXCEPTION;     --Added for bug 2056877.
   l_expenditure_ending_date      date; -- added five variables for 2445196
   l_expenditure_id               number;
   l_interface_id                 number;
   l_expenditure_item_id          number;
   l_txn_interface_id             number;
   l_susp_exception               varchar2(50); -- 2479579

   l_expenditure_type           varchar2(100);  -- introduced vars for 5080403
   l_exp_org_id                 number;
   l_new_expenditure_type       varchar2(100);
   l_new_glccid                 number;
   l_acct_type                  varchar2(1);
   l_auto_pop_status            varchar2(100);
   l_auto_status                varchar2(100);
   l_person_id                  number;
   l_element_type_id            number;
   l_assignment_number          varchar2(100);
   l_element_type               varchar2(200);
   l_person_name                varchar2(300);
   l_account                    varchar2(1000);
   l_auto_org_name              hr_all_organization_units_tl.name%TYPE;
   l_pay_action_type           psp_payroll_lines.payroll_action_type%TYPE; -- Bug 7040943

 cursor get_element_type is
   select ppl.element_type_id,
          ppl.assignment_id,
          ppl.person_id
    from  psp_payroll_lines ppl,
          psp_payroll_sub_lines ppsl,
          psp_distribution_lines pdl
    where pdl.distribution_line_id = x_line_id
      and pdl.payroll_sub_line_id = ppsl.payroll_sub_line_id
      and ppsl.payroll_line_id = ppl.payroll_line_id
   union all
   select ppg.element_type_id,
          ppg.assignment_id,
          ppg.person_id
     from psp_pre_gen_dist_lines ppg
    where pre_gen_dist_line_id = x_line_id;

 cursor get_asg_details is
   select ppf.full_name,
          paf.assignment_number,
          pet.element_name,
          hou.name
     from per_all_people_f ppf,
          per_all_assignments_f paf,
          pay_element_types_f pet,
          hr_all_organization_units hou
    where ppf.person_id = l_person_id
      and l_distribution_date between ppf.effective_start_date and ppf.effective_end_date
      and paf.assignment_id = l_assignment_id
      and l_distribution_date between paf.effective_start_date and paf.effective_end_date
      and pet.element_type_id = l_element_type_id
      and l_distribution_date between pet.effective_start_date and pet.effective_end_date
      and hou.organization_id = paf.organization_id;


-- Bug 4369939: Performance fix START
TYPE t_varchar2_10_type IS TABLE OF varchar2(10)  INDEX BY BINARY_INTEGER;
TYPE t_varchar2_30_type IS TABLE OF varchar2(30)  INDEX BY BINARY_INTEGER;
TYPE t_number_type IS TABLE OF NUMBER  INDEX BY BINARY_INTEGER;
type SUMMARY_LINES_TYPE  is record
  (
    L_SUMMARY_LINE_ID t_number_type,
    L_SUMMARY_LINE_ID_CHAR t_varchar2_30_type,
    L_GMS_BATCH_NAME t_varchar2_10_type
  );

summary_lines_rec   SUMMARY_LINES_TYPE;

Cursor SUMMARY_LINES_csr IS
Select SUMMARY_LINE_ID, to_CHAR(SUMMARY_LINE_ID) , GMS_BATCH_NAME
From PSP_SUMMARY_LINES PSL
where PSL.GMS_BATCH_NAME = p_gms_batch_name;
-- Bug 4369939: Performance fix END


 FUNCTION PROCESS_COMPLETE RETURN BOOLEAN IS

   cursor get_completion is
   select count(*), transaction_status_code
     from pa_transaction_interface_all
    where batch_name = p_gms_batch_name
      and transaction_source = p_txn_source
      and transaction_status_code in ('P', 'I')
    group by transaction_status_code  ;

  get_completion_rec	get_completion%ROWTYPE;

 begin

   open get_completion;
   loop
   fetch get_completion into get_completion_rec;

   if get_completion%ROWCOUNT = 0 then
     close get_completion;
     return TRUE;
   elsif get_completion%NOTFOUND then
     close get_completion;
     return FALSE;
   end if;

   if (get_completion_rec.transaction_status_code = 'P' AND  -- change
       g_skip_flag_gms = 'N') then -- bug 6902514

-- -------------------------------------------------------------------------------------------
-- If transaction_status_code = 'P' then the transaction import process did not kick off
-- for some reason. Return 'NOT_RUN' in this case. So cleanup the tables and try to transfer
-- again after summarization in the second pass.
-- -------------------------------------------------------------------------------------------

     delete from pa_transaction_interface_all
      where batch_name = p_gms_batch_name
	and transaction_source = p_txn_source;

     if p_txn_source = 'GOLD' then
       delete from gms_transaction_interface_all
        where batch_name = p_gms_batch_name
	  and transaction_source = 'GOLD';
     end if;

     delete from psp_summary_lines
      where gms_batch_name = to_number(p_gms_batch_name)
	and payroll_control_id = p_payroll_control_id;


   elsif (get_completion_rec.transaction_status_code = 'I' AND  -- change
          g_skip_flag_gms = 'N') then -- Bug 6902514

-- -------------------------------------------------------------------------------------------
-- If transaction_status_code = 'I' then the transaction import process did not complete
-- the Post Processing extension. So return 'NOT_COMPLETE' in this case. User needs to complete
-- this process by running the transaction import manually and re-start the LD process.
-- -------------------------------------------------------------------------------------------

     l_no_run_status := 'I';

     NULL; --- Return False here.

   end if;

   end loop;

 exception
 when others then
   return FALSE;
 end PROCESS_COMPLETE;

 BEGIN

hr_utility.trace('entered gms_tie_back');


     if NOT PROCESS_COMPLETE then
	if (l_no_run_status = 'I') then
     	   fnd_message.set_name('PSP','PSP_PRC_DID_NOT_RUN');
     	   fnd_message.set_token('PAYROLL_CONTROL_ID',p_payroll_control_id);
     	   fnd_message.set_token('GMS_BATCH_NAME',p_gms_batch_name);
     	   fnd_msg_pub.add;
     	   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	end if;
     end if;
hr_utility.trace('entered gms_tie_back2');

--  Status codes have been added to transaction import process,
--  to accomodate pre and post import extensions in 11i
--  to following select statement

   SELECT count(*)
     INTO l_cnt_gms_interface
     FROM pa_transaction_interface_all
    WHERE batch_name = p_gms_batch_name
      AND transaction_source = p_txn_source
      AND transaction_status_code in ('R', 'PO', 'PI', 'PR');

     /* moved this statement to beginning for 2444657 */
     UPDATE 	psp_payroll_controls
        SET    	phase = 'GL_Tie_Back'
      WHERE	payroll_control_id = p_payroll_control_id;
hr_utility.trace('entered gms_tie_back3');

   IF l_cnt_gms_interface > 0 THEN
     --
     OPEN gms_tie_back_reject_cur;
     LOOP
       FETCH gms_tie_back_reject_cur INTO l_trx_reject_code,l_orig_trx_reference,l_trx_status_code,
                                          l_expenditure_ending_date,l_expenditure_id,  -- added 5 vars for 2445196
                                          l_interface_id,l_expenditure_item_id, l_txn_interface_id;



       IF gms_tie_back_reject_cur%NOTFOUND THEN
         CLOSE gms_tie_back_reject_cur;
         EXIT;
       END IF;

       -- update summary_lines with the reject status code
       IF l_trx_status_code in ('R', 'PO', 'PI', 'PR') THEN
          UPDATE psp_summary_lines
          SET interface_status = l_trx_reject_code, status_code = 'R',
              expenditure_ending_date = l_expenditure_ending_date,  -- added 5 fields for 2445196
              expenditure_id = l_expenditure_id, interface_id=l_interface_id,
              expenditure_item_id=l_expenditure_item_id, txn_interface_id=l_txn_interface_id
          WHERE summary_line_id = to_number(l_orig_trx_reference);
       ELSIF l_trx_status_code = 'A' THEN
          UPDATE psp_summary_lines
          SET interface_status = l_trx_reject_code, status_code = 'A',
              expenditure_ending_date = l_expenditure_ending_date,  -- added 5 fields for 2445196
              expenditure_id = l_expenditure_id, interface_id=l_interface_id,
              expenditure_item_id=l_expenditure_item_id, txn_interface_id=l_txn_interface_id
          WHERE summary_line_id = to_number(l_orig_trx_reference);

       SELECT summary_amount,dr_cr_flag
       INTO l_summary_amount,l_dr_cr_flag
       FROM psp_summary_lines
       WHERE summary_line_id = to_number(l_orig_trx_reference) ;
hr_utility.trace('entered gms_tie_back4');
         IF l_dr_cr_flag = 'D' THEN
           l_dr_summary_amount := l_dr_summary_amount + l_summary_amount;
         ELSIF l_dr_cr_flag = 'C' THEN
           -- credit is marked as -ve for posting to Oracle Projects
           l_cr_summary_amount := l_cr_summary_amount - l_summary_amount;
         END IF;
       END IF;
 hr_utility.trace('before open assign_susp_ac_cur');
       OPEN assign_susp_ac_cur(l_orig_trx_reference);
       LOOP

         FETCH assign_susp_ac_cur INTO l_rowid, x_line_id, l_distribution_date, l_suspense_org_account_id;

         IF assign_susp_ac_cur%NOTFOUND THEN
           CLOSE assign_susp_ac_cur;
           EXIT;
         END IF;

	  -- Bug 9307730
	 IF p_source_type IN('O', 'N') THEN
         /*Bug 7376898*/
	   SELECT payroll_action_type, effective_date
	   INTO l_pay_action_type, l_effective_date
	   FROM psp_payroll_lines
	   WHERE payroll_control_id = p_payroll_control_id
	   and payroll_line_id = (select payroll_line_id from psp_payroll_sub_lines
	                           where payroll_sub_line_id = (select payroll_sub_line_id
	                                                        from psp_distribution_lines
	                                                        where distribution_line_id = x_line_id));
	 /*Bug 7376898 End*/
	 END IF;

hr_utility.trace('entered gms_tie_back5');

         IF l_trx_status_code = 'A'  THEN
          IF p_source_type = 'O' OR p_source_type = 'N' THEN
           UPDATE psp_distribution_lines
            SET status_code = 'A'
            WHERE rowid = l_rowid;

            INSERT INTO psp_distribution_lines_history
             (distribution_line_id,payroll_sub_line_id,distribution_date,
          effective_date,distribution_amount,status_code,suspense_reason_code,
          effort_report_id,version_num,schedule_line_id,summary_line_id,
          default_org_account_id,suspense_org_account_id,
          element_account_id,org_schedule_id,user_defined_field,
          default_reason_code,reversal_entry_flag,gl_project_flag,
	  auto_expenditure_type, business_group_id, set_of_books_id,
	attribute_category,	attribute1,	attribute2,	attribute3,
	attribute4,		attribute5,	attribute6,	attribute7,
	attribute8,		attribute9,	attribute10,
         cap_excess_glccid, cap_excess_award_id, cap_excess_task_id,
        cap_excess_project_id,    cap_excess_exp_type, cap_excess_exp_org_id,
        funding_source_code, annual_salary_cap, cap_excess_dist_line_id,
          suspense_auto_exp_type, suspense_auto_glccid, adj_account_flag)
         SELECT distribution_line_id,payroll_sub_line_id,distribution_date,
          effective_date,distribution_amount,status_code,suspense_reason_code,
          effort_report_id,version_num,schedule_line_id,summary_line_id,
          default_org_account_id,suspense_org_account_id,
          element_account_id,org_schedule_id,user_defined_field,
          default_reason_code,reversal_entry_flag,gl_project_flag,
	  auto_expenditure_type, business_group_id, set_of_books_id,
	attribute_category,	attribute1,	attribute2,	attribute3,
	attribute4,		attribute5,	attribute6,	attribute7,
	attribute8,		attribute9,	attribute10,
         cap_excess_glccid, cap_excess_award_id, cap_excess_task_id,
        cap_excess_project_id,    cap_excess_exp_type, cap_excess_exp_org_id,
        funding_source_code, annual_salary_cap, cap_excess_dist_line_id,
          suspense_auto_exp_type, suspense_auto_glccid, adj_account_flag
         FROM psp_distribution_lines
         WHERE status_code = 'A'
         AND  summary_line_id = to_number(l_orig_trx_reference);

 hr_utility.trace('after insert into dist lines');
         DELETE FROM psp_distribution_lines
         WHERE status_code = 'A'
         AND summary_line_id = to_number(l_orig_trx_reference);

         --moved  the two del stmnts above for 2445196

           ELSIF p_source_type = 'P' THEN
             UPDATE psp_pre_gen_dist_lines
              SET status_code = 'A'
              WHERE rowid = l_rowid;

-- move the transferred records to psp_pre_gen_dist_lines_history
         INSERT INTO psp_pre_gen_dist_lines_history
         (pre_gen_dist_line_id,distribution_interface_id,person_id,assignment_id,
          element_type_id,distribution_date,effective_date,distribution_amount,
          dr_cr_flag,payroll_control_id,source_type,source_code,time_period_id,
          batch_name,status_code,set_of_books_id,
          gl_code_combination_id,project_id,expenditure_organization_id,
          expenditure_type,task_id,award_id,suspense_reason_code,
          effort_report_id,version_num,summary_line_id,suspense_org_account_id,
          user_defined_field,reversal_entry_flag, business_group_id,
	attribute_category,	attribute1,	attribute2,	attribute3,
	attribute4,		attribute5,	attribute6,	attribute7,
        attribute8,             attribute9,     attribute10,
          suspense_auto_exp_type, suspense_auto_glccid)
         SELECT pre_gen_dist_line_id,distribution_interface_id,person_id,assignment_id,
          element_type_id,distribution_date,effective_date,distribution_amount,
          dr_cr_flag,payroll_control_id,source_type,source_code,time_period_id,
          batch_name,status_code,set_of_books_id,
          gl_code_combination_id,project_id,expenditure_organization_id,
          expenditure_type,task_id,award_id,suspense_reason_code,
          effort_report_id,version_num,summary_line_id,suspense_org_account_id,
          user_defined_field,reversal_entry_flag, business_group_id,
	attribute_category,	attribute1,	attribute2,	attribute3,
	attribute4,		attribute5,	attribute6,	attribute7,
        attribute8,             attribute9,     attribute10,
          suspense_auto_exp_type, suspense_auto_glccid
         FROM psp_pre_gen_dist_lines
         WHERE status_code = 'A'
         AND summary_line_id = to_number(l_orig_trx_reference);

 hr_utility.trace('after insert into pregen lines');
         DELETE FROM psp_pre_gen_dist_lines
         WHERE status_code = 'A'
         AND summary_line_id = to_number(l_orig_trx_reference);
        END IF;
         --- moved  the two del stmnts below for 2445196, earlier commented for 2290051

             /* Bug 1866362, S and T Failing with Fatal error Suspense A/C invalid, eventhough Suspense A/C is valid.
               Introduced reject_code not null condition, stick suspense only if this condition satisified */
         -- if a suspense a/c failed,update the status of the whole batch and display the error
         ELSIF l_trx_status_code <> 'A' and  l_trx_reject_code is not NULL then
          -- introduced following IF by splitting from above ELSIF stmt: 2428953.
         If l_suspense_org_account_id is NOT NULL then

	OPEN get_susp_org_cur1(l_suspense_org_account_id);
	FETCH get_susp_org_cur1 into l_organization_id, l_organization_name;
	CLOSE get_susp_org_cur1;

           x_susp_failed_org_name    := l_organization_name;
           x_susp_failed_reject_code := l_trx_reject_code;
           x_susp_failed_date        := l_distribution_date;
           l_suspense_ac_failed := 'Y';

         /*  Commented For Bug 3065866

	 IF p_source_type = 'O' OR p_source_type = 'N' THEN
           UPDATE psp_distribution_lines
            SET suspense_reason_code = l_trx_reject_code,
                status_code = 'N'
            WHERE rowid = l_rowid;
          ELSIF p_source_type = 'P' THEN
             UPDATE psp_pre_gen_dist_lines
               SET suspense_reason_code = l_trx_reject_code,
                   status_code = 'N'
               WHERE rowid = l_rowid;
          END IF;   Enf of commenting for BUg 3065866 */

         ELSE  -- suspense org is null and rejected xface rec
            l_susp_ac_found := 'TRUE';

	   OPEN get_org_id_cur1(x_line_id);
	   FETCH get_org_id_cur1 into l_orig_org_id1, l_orig_org_name1;
	  --dbms_output.put_line('orig ord id is ' || l_orig_org_id1);
	   IF get_org_id_cur1%NOTFOUND then
	--	dbms_output.put_line('Didnot get any data');
           null;
	   END IF;
	   CLOSE get_org_id_cur1;

           --Bug 7040943 Starts
	   IF l_pay_action_type = 'L' THEN
		l_distribution_date := l_effective_date;
	   END IF;
           --Bug 7040943 End

           OPEN org_susp_ac_cur(l_orig_org_id1, l_distribution_date);
           FETCH org_susp_ac_cur INTO l_organization_account_id,l_gl_code_combination_id,l_project_id,l_award_id,l_task_id,
                                      l_exp_org_id, l_expenditure_type;

           IF org_susp_ac_cur%NOTFOUND  THEN
             /* Following code is added for bug 2056877 ,Added validation for generic suspense account */
		l_return_value := psp_general.find_global_suspense(l_distribution_date,
							  p_business_group_id,
                                                          p_set_of_books_id,
                                                          l_organization_account_id);
      	  /* --------------------------------------------------------------------
      	   Valid return values are
      	   PROFILE_VAL_DATE_MATCHES       Profile and Value and Date matching 'G'
      	   NO_PROFILE_EXISTS              No Profile
       	   NO_VAL_DATE_MATCHES            Profile and Either Value/date do not
            		                  match with 'G'
   	   NO_GLOBAL_ACCT_EXISTS          No 'G' exists
     	    ---------------------------------------------------------------------- */
               IF  l_return_value = 'PROFILE_VAL_DATE_MATCHES' THEN
            --	   OPEN global_susp_ac_cur(l_distribution_date);
            	   OPEN global_susp_ac_cur(l_organization_account_id); -- Bug 2056877.
                   FETCH global_susp_ac_cur INTO l_organization_account_id,l_gl_code_combination_id,l_project_id,l_award_id,
                         l_task_id, l_exp_org_id, l_expenditure_type;

             IF   global_susp_ac_cur%NOTFOUND THEN
              	   /*  l_susp_ac_found := 'FALSE';
                       l_suspense_ac_not_found := 'Y';
                       x_susp_nf_org_name := l_organization_name;
                       x_susp_nf_org_name := l_orig_org_name1;
                       x_susp_nf_date     := l_distribution_date; */ --Commented for bug 2056877.
                       --- commented for 2479579      RAISE no_global_acct_exists; --Added for bug 2056877
                       -- added following lines for 2479579
                              l_susp_ac_found := 'NO_G_AC';
                              l_suspense_ac_not_found := 'Y';
                      END IF;
                      CLOSE global_susp_ac_cur;
              ELSIF l_return_value = 'NO_GLOBAL_ACCT_EXISTS' THEN
                     --- RAISE no_global_acct_exists; commented this line added following 2 lines for 2479579
                     l_suspense_ac_not_found := 'Y';
                     l_susp_ac_found := 'NO_G_AC';
              ELSIF l_return_value = 'NO_VAL_DATE_MATCHES' THEN
                    --- RAISE no_val_date_matches;  commented this line added following 2 lines for 2479579
                    l_suspense_ac_not_found := 'Y';
                    l_susp_ac_found := 'NO_DT_MCH';
              ELSIF l_return_value = 'NO_PROFILE_EXISTS' THEN
                    --- RAISE no_profile_exists;  commented this line added following 2 lines for 2479579
                     l_suspense_ac_not_found := 'Y';
                     l_susp_ac_found := 'NO_PROFL';
              END IF; -- Bug 2056877.
          END IF;
          CLOSE org_susp_ac_cur;
       -- introduced for 5080403
       if g_suspense_autopop = 'Y' and l_organization_account_id is not null then
            if l_gl_code_combination_id is null then
                l_acct_type:='E';
            else
                l_acct_type:='N';
            end if;
            open get_element_type;
            fetch get_element_type into l_element_type_id, l_assignment_id, l_person_id;
            close get_element_type;
              psp_autopop.main( p_acct_type                   => l_acct_type,
                                p_person_id                   => l_person_id,
                                p_assignment_id               => l_assignment_id,
                                p_element_type_id             => l_element_type_id,
                                p_project_id                  => l_project_id,
                                p_expenditure_organization_id => l_exp_org_id,
                                p_task_id                     => l_task_id,
                                p_award_id                    => l_award_id,
                                p_expenditure_type            => l_expenditure_type,
                                p_gl_code_combination_id      => l_gl_code_combination_id,
                                p_payroll_date                => l_distribution_date,
                                p_set_of_books_id             => p_set_of_books_id,
                                p_business_group_id           => p_business_group_id,
                                ret_expenditure_type          => l_new_expenditure_type,
                                ret_gl_code_combination_id    => l_new_glccid,
                                retcode                       => l_auto_pop_status);
           IF (l_auto_pop_status = FND_API.G_RET_STS_UNEXP_ERROR) OR
             (l_auto_pop_status = FND_API.G_RET_STS_ERROR) THEN
             IF l_auto_pop_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
               if l_acct_type ='N'  then
                    l_auto_status := 'AUTO_POP_NA_ERROR';
               else
                    l_auto_status :='AUTO_POP_EXP_ERROR';
               end if;
             elsif l_auto_pop_status = FND_API.G_RET_STS_ERROR THEN
               l_auto_status := 'AUTO_POP_NO_VALUE';
             end if;
             open get_asg_details;
             fetch get_asg_details into l_person_name, l_assignment_number, l_element_type, l_auto_org_name;
             close get_asg_details;
             psp_enc_crt_xml.p_set_of_books_id := p_set_of_books_id;
             psp_enc_crt_xml.p_business_group_id := p_business_group_id;
             if l_acct_type = 'N' then
                 l_account :=
                     psp_enc_crt_xml.cf_charging_instformula(l_new_glccid,
                                                             null,
                                                             null,
                                                             null,
                                                             null,
                                                             null);
              else
                 l_account :=
                     psp_enc_crt_xml.cf_charging_instformula(null,
                                                             l_project_id,
                                                             l_task_id,
                                                             l_award_id,
                                                             l_new_expenditure_type,
                                                             l_exp_org_id);
              end if;
                   fnd_message.set_name('PSP','PSP_SUSPENSE_AUTOPOP_FAIL');
                   fnd_message.set_token('ORG_NAME',l_auto_org_name);
                   fnd_message.set_token('EMPLOYEE_NAME',l_person_name);
                   fnd_message.set_token('ASG_NUM',l_assignment_number);
                   fnd_message.set_token('CHARGING_ACCOUNT',l_account);
                   fnd_message.set_token('AUTOPOP_ERROR',l_auto_status);
                   fnd_message.set_token('EFF_DATE',l_distribution_date);
                   fnd_msg_pub.add;
         else
           if l_acct_type = 'E' then
              l_expenditure_type := l_new_expenditure_type;
           else
              l_gl_code_combination_id := l_new_glccid;
           end if;
           end if;
         end if;

          if l_susp_ac_found = 'TRUE' then
            IF l_gl_code_combination_id IS NOT NULL THEN
              l_gl_project_flag := 'G';
               -- l_effective_date := p_period_end_date; --- uncommented for Bug 2663344  COMMENTED by Bug 7040943
            ELSE
              l_gl_project_flag := 'P';
               l_effective_date := l_distribution_date;   --- added for Bug 2663344
            END IF;


            IF p_source_type = 'O' OR p_source_type = 'N' THEN

	/* Added for Bug 3065866 */

	     UPDATE psp_distribution_lines
	     SET    pre_distribution_run_flag = gl_project_flag
	     WHERE rowid = l_rowid;

       /* End of changes for Bug 3065866*/

             UPDATE psp_distribution_lines
              SET suspense_org_account_id = l_organization_account_id,
                  suspense_reason_code = 'ST:' || l_trx_reject_code,
                  gl_project_flag = l_gl_project_flag,
                  status_code = 'N',
                  effective_date = l_effective_date, ---uncommented this line for Bug 2663344
                  suspense_auto_glccid = l_new_glccid,    --- added suspense_auto for 5080403
                  suspense_auto_exp_type = l_new_expenditure_type
              WHERE rowid = l_rowid;
            ELSIF p_source_type = 'P' THEN
               UPDATE psp_pre_gen_dist_lines
                 SET suspense_org_account_id = l_organization_account_id,
                     suspense_reason_code = 'ST:' || l_trx_reject_code,
                     status_code = 'N',
                     effective_date = l_effective_date, ---uncommented this line for Bug 2663344
                  suspense_auto_glccid = l_new_glccid,
                  suspense_auto_exp_type = l_new_expenditure_type
                 WHERE rowid = l_rowid;

            END IF;
           else -- added for 2479579
                l_susp_exception := l_susp_ac_found;
           end if;
          END IF;   --- for 2428953
         END IF;

       END LOOP;
     END LOOP;
 hr_utility.trace('update control record');
     UPDATE psp_payroll_controls
     SET ogm_dr_amount = nvl(ogm_dr_amount,0) + l_dr_summary_amount,
         ogm_cr_amount = nvl(ogm_cr_amount,0) + l_cr_summary_amount
     WHERE payroll_control_id = p_payroll_control_id;

--	Introduced for bug fix 2643228
	DELETE	pa_transaction_interface_all
	WHERE	transaction_source = p_txn_source
	AND	batch_name = p_gms_batch_name;

	DELETE	gms_transaction_interface_all
	WHERE	transaction_source = p_txn_source
	AND	batch_name = p_gms_batch_name;
--	End of bug fix 2643228
     IF l_suspense_ac_failed = 'Y' or
        nvl(l_auto_status,'X') in ('AUTO_POP_NA_ERROR', 'AUTO_POP_EXP_ERROR', 'AUTO_POP_NO_VALUE') then
                   --- above check for autopop error 5080403
       if nvl(l_suspense_ac_failed,'N') = 'Y' then
       fnd_message.set_name('PSP','PSP_TR_GMS_SUSP_AC_REJECT');
       fnd_message.set_token('ORG_NAME',x_susp_failed_org_name);
       fnd_message.set_token('PAYROLL_DATE',x_susp_failed_date);
       fnd_message.set_token('ERROR_MSG',x_susp_failed_reject_code);
       fnd_msg_pub.add;
       end if;

	/* Added this code for Bug 3065866 */
		IF p_source_type = 'O' OR p_source_type = 'N' THEN



		 	UPDATE psp_distribution_lines
		 	SET	suspense_org_account_id = NULL,
				suspense_reason_code = NULL,
				gl_project_flag = pre_distribution_run_flag,
                        	effective_date = decode(pre_distribution_run_flag,'G',
                                                p_period_end_date,distribution_date)
			WHERE	suspense_reason_code like 'ST:%'
			AND	summary_line_id
				IN ( SELECT 	summary_line_id
				     FROM	psp_summary_lines
				     WHERE	payroll_control_id = p_payroll_control_id);
		ELSIF p_source_type = 'P' THEN
			UPDATE 	psp_pre_gen_dist_lines
			SET	suspense_org_account_id = NULL,
				suspense_reason_code = NULL,
				effective_date = decode(NVL(gl_code_combination_id,-999),gl_code_combination_id,
                                        p_period_end_date,distribution_date)
			WHERE	suspense_reason_code like 'ST:%'
			AND	summary_line_id
				IN (SELECT	summary_line_id
				    FROM	psp_summary_lines
			   	    WHERE	payroll_control_id = p_payroll_control_id);

		END IF;
	/* End of code for Bug 3065866 */

	/* Introduced the followinbg check as part of Bug fix #1776606 */
	if p_mode = 'N' then
          /* introduced mark batch end Bug: 1929317 */
          mark_batch_end(p_source_type,
                   g_source_code,
                   g_time_period_id,
                   g_batch_name,
                   p_business_group_id,
                   p_set_of_books_id,
                   l_return_status);
       	    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	end if;
     END IF;

     IF l_suspense_ac_not_found = 'Y' THEN
       /* commented for 2479579
        fnd_message.set_name('PSP','PSP_LD_SUSPENSE_AC_NOT_EXIST');
        fnd_message.set_token('ORG_NAME',x_susp_nf_org_name);
        fnd_message.set_token('PAYROLL_DATE',x_susp_nf_date);
        fnd_msg_pub.add; */

	/* Added the following code for Bug 3065866 */

		IF p_source_type = 'O' OR p_source_type = 'N' THEN
			UPDATE	psp_distribution_lines
			SET	suspense_org_account_id = NULL,
				suspense_reason_code = NULL
			WHERE	suspense_reason_code like 'ST:%'
			AND	summary_line_id
				IN( SELECT	summary_line_id
				    FROM	psp_summary_lines
				    WHERE	payroll_control_id = p_payroll_control_id);
		ELSIF p_source_type = 'P' THEN
			UPDATE	psp_pre_gen_dist_lines
			SET	suspense_org_account_id = NULL,
				suspense_reason_code = NULL
			WHERE	suspense_reason_code like 'ST:%'
                        AND     summary_line_id
                                IN( SELECT      summary_line_id
                                    FROM        psp_summary_lines
                                    WHERE       payroll_control_id = p_payroll_control_id);
		END IF;
	/* End of Bug 3065866 */


	/* Introduced the followinbg check as part of Bug fix #1776606 */
	if p_mode = 'N' then
          /* introduced mark batch end Bug: 1929317 */
             mark_batch_end(p_source_type,
                   g_source_code,
                   g_time_period_id,
                   g_batch_name,
                   p_business_group_id,
                   p_set_of_books_id,
                   l_return_status);
           --- RAISE FND_API.G_EXC_UNEXPECTED_ERROR; commented for  2479579
          -- introduced following if stmnt  for  2479579
          if l_susp_exception = 'NO_G_AC' then
                     RAISE no_global_acct_exists;
          elsif  l_susp_exception = 'NO_DT_MCH' then
                     RAISE no_val_date_matches;
          elsif l_susp_exception =  'NO_PROFL' then
                     RAISE no_profile_exists;
          end if;

	end if;
     END IF;

   ELSIF l_cnt_gms_interface = 0  THEN

-- Bug 4369939: Performance fix START
	OPEN SUMMARY_LINES_CSR;
	FETCH SUMMARY_LINES_CSR bulk Collect into SUMMARY_LINES_REC.L_SUMMARY_LINE_ID,
	SUMMARY_LINES_rec.L_SUMMARY_LINE_ID_CHAR, SUMMARY_LINES_REC.L_GMS_BATCH_NAME;
	CLOSE SUMMARY_LINES_CSR;

	FORALL i in 1.. SUMMARY_LINES_REC.L_SUMMARY_LINE_ID.count
	UPDATE PSP_SUMMARY_LINES PSL
	Set (PSL.STATUS_CODE, PSL.EXPENDITURE_ENDING_DATE,PSL.EXPENDITURE_ID,
	   PSL.INTERFACE_ID,PSL.EXPENDITURE_ITEM_ID,PSL.TXN_INTERFACE_ID) =
	   ( SELECT 'A', PTXN.EXPENDITURE_ENDING_DATE,PTXN.EXPENDITURE_ID, PTXN.INTERFACE_ID,
		PTXN.EXPENDITURE_ITEM_ID,PTXN.TXN_INTERFACE_ID
		FROM PA_TRANSACTION_INTERFACE_ALL PTXN
		WHERE PTXN.TRANSACTION_SOURCE = p_txn_source
		AND PTXN.ORIG_TRANSACTION_REFERENCE= SUMMARY_LINES_REC.L_SUMMARY_LINE_ID_CHAR(i)
		AND PTXN.BATCH_NAME = SUMMARY_LINES_REC.L_GMS_BATCH_NAME(i)
	   )
	  WHERE --GMS_BATCH_NAME = SUMMARY_LINES_REC.L_GMS_BATCH_NAME(i)  AND
		 PSL.SUMMARY_LINE_ID = SUMMARY_LINES_REC.L_SUMMARY_LINE_ID(i);

/*
      -- changed to update all sum lines at one shot for 2445196
       UPDATE psp_summary_lines  PSL
       SET (PSL.status_code, PSL.expenditure_ending_date,PSL.expenditure_id,
               PSL.interface_id,PSL.expenditure_item_id,PSL.txn_interface_id)  =
            (select 'A', PTXN.expenditure_ending_date,PTXN.expenditure_id,
               PTXN.interface_id,PTXN.expenditure_item_id,PTXN.txn_interface_id
             from pa_transaction_interface_all PTXN
             where PTXN.transaction_source = p_txn_source
               and PTXN.orig_transaction_reference= to_char(PSL.summary_line_id)
               and PTXN.batch_name = p_gms_batch_name)
       WHERE gms_batch_name = p_gms_batch_name;
*/
-- Bug 4369939: Performance fix END

     OPEN gms_tie_back_success_cur;
     LOOP
       FETCH gms_tie_back_success_cur INTO l_summary_line_id,
        l_dr_cr_flag,l_summary_amount;

       IF gms_tie_back_success_cur%NOTFOUND THEN
         CLOSE gms_tie_back_success_cur;
         EXIT;
       END IF;

       -- update records in psp_summary_lines as 'A' moved this stmnt from here to above for 2445196.

       IF l_dr_cr_flag = 'D' THEN
         l_dr_summary_amount := l_dr_summary_amount + l_summary_amount;
       ELSIF l_dr_cr_flag = 'C' THEN
         -- credit is marked as -ve for posting to Oracle Projects
         l_cr_summary_amount := l_cr_summary_amount - l_summary_amount;
       END IF;

       IF p_source_type = 'O' OR p_source_type = 'N' THEN

         UPDATE psp_distribution_lines
         SET status_code = 'A' WHERE summary_line_id = l_summary_line_id;

         -- move the transferred records to psp_distribution_lines_history
         INSERT INTO psp_distribution_lines_history
         (distribution_line_id,payroll_sub_line_id,distribution_date,
          effective_date,distribution_amount,status_code,suspense_reason_code,
          effort_report_id,version_num,schedule_line_id,summary_line_id,
          default_org_account_id,suspense_org_account_id,
          element_account_id,org_schedule_id,user_defined_field,
          default_reason_code,reversal_entry_flag,gl_project_flag,
	  auto_expenditure_type, business_group_id, set_of_books_id,
        attribute_category,     attribute1,     attribute2,     attribute3,
        attribute4,             attribute5,     attribute6,     attribute7,
        attribute8,             attribute9,     attribute10,
         cap_excess_glccid, cap_excess_award_id, cap_excess_task_id,
        cap_excess_project_id,    cap_excess_exp_type, cap_excess_exp_org_id,
        funding_source_code, annual_salary_cap, cap_excess_dist_line_id,
        suspense_auto_exp_type, suspense_auto_glccid, adj_account_flag)
         SELECT distribution_line_id,payroll_sub_line_id,distribution_date,
          effective_date,distribution_amount,status_code,suspense_reason_code,
          effort_report_id,version_num,schedule_line_id,summary_line_id,
          default_org_account_id,suspense_org_account_id,
          element_account_id,org_schedule_id,user_defined_field,
          default_reason_code,reversal_entry_flag,gl_project_flag,
	  auto_expenditure_type, business_group_id, set_of_books_id,
        attribute_category,     attribute1,     attribute2,     attribute3,
        attribute4,             attribute5,     attribute6,     attribute7,
        attribute8,             attribute9,     attribute10,
         cap_excess_glccid, cap_excess_award_id, cap_excess_task_id,
        cap_excess_project_id,    cap_excess_exp_type, cap_excess_exp_org_id,
        funding_source_code, annual_salary_cap, cap_excess_dist_line_id,
          suspense_auto_exp_type, suspense_auto_glccid, adj_account_flag
         FROM psp_distribution_lines
         WHERE status_code = 'A'
         AND  summary_line_id = l_summary_line_id;

         DELETE FROM psp_distribution_lines
         WHERE status_code = 'A'
         AND summary_line_id = l_summary_line_id;
         -- Moved the purging of xface lines from here below LOOP, for Bug 2445196
       ELSIF p_source_type = 'P' THEN

         UPDATE psp_pre_gen_dist_lines
         SET status_code = 'A' WHERE summary_line_id = l_summary_line_id;

         -- move the transferred records to psp_pre_gen_dist_lines_history
         INSERT INTO psp_pre_gen_dist_lines_history
         (pre_gen_dist_line_id,distribution_interface_id,person_id,assignment_id,
          element_type_id,distribution_date,effective_date,distribution_amount,
          dr_cr_flag,payroll_control_id,source_type,source_code,time_period_id,
          batch_name,status_code,set_of_books_id,
          gl_code_combination_id,project_id,expenditure_organization_id,
          expenditure_type,task_id,award_id,suspense_reason_code,
          effort_report_id,version_num,summary_line_id,suspense_org_account_id,
          user_defined_field,reversal_entry_flag, business_group_id,
        attribute_category,     attribute1,     attribute2,     attribute3,
        attribute4,             attribute5,     attribute6,     attribute7,
        attribute8,             attribute9,     attribute10,
         suspense_auto_exp_type, suspense_auto_glccid)
         SELECT pre_gen_dist_line_id,distribution_interface_id,person_id,assignment_id,
          element_type_id,distribution_date,effective_date,distribution_amount,
          dr_cr_flag,payroll_control_id,source_type,source_code,time_period_id,
          batch_name,status_code,set_of_books_id,
          gl_code_combination_id,project_id,expenditure_organization_id,
          expenditure_type,task_id,award_id,suspense_reason_code,
          effort_report_id,version_num,summary_line_id,suspense_org_account_id,
          user_defined_field,reversal_entry_flag, business_group_id,
        attribute_category,     attribute1,     attribute2,     attribute3,
        attribute4,             attribute5,     attribute6,     attribute7,
        attribute8,             attribute9,     attribute10,
         suspense_auto_exp_type, suspense_auto_glccid
         FROM psp_pre_gen_dist_lines
         WHERE status_code = 'A'
         AND summary_line_id = l_summary_line_id;

         DELETE FROM psp_pre_gen_dist_lines
         WHERE status_code = 'A'
         AND summary_line_id = l_summary_line_id;
         --Moved delete xface stmnts from here to below for bug 2445196:
       END IF;
     END LOOP;

     UPDATE psp_payroll_controls
     SET ogm_dr_amount = nvl(ogm_dr_amount,0) + l_dr_summary_amount,
         ogm_cr_amount = nvl(ogm_cr_amount,0) + l_cr_summary_amount
     WHERE payroll_control_id = p_payroll_control_id;

--	Introduced for bug fix 2643228
	DELETE	pa_transaction_interface_all
	WHERE	transaction_source = p_txn_source
	AND	batch_name = p_gms_batch_name;

	DELETE	gms_transaction_interface_all
	WHERE	transaction_source = p_txn_source
	AND	batch_name = p_gms_batch_name;
--	End of bug fix 2643228
   END IF;
/*****	Commented for bug fix 2643228
    -- introduced for 2445196
    delete pa_transaction_interface_all
     where transaction_source = p_txn_source
       and batch_name = p_gms_batch_name;

     delete gms_transaction_interface_all
     where transaction_source = p_txn_source
       and batch_name = p_gms_batch_name;
	End of bug fix 2643228	*****/
   p_return_status := fnd_api.g_ret_sts_success;
 EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     --dbms_output.put_line('Gone to one level top ..................');
     g_error_api_path := 'GMS_TIE_BACK:'||g_error_api_path;
     p_return_status := fnd_api.g_ret_sts_unexp_error;
   /* Added Exceptions for bug 2056877 */
   WHEN NO_PROFILE_EXISTS THEN
      g_error_api_path := SUBSTR('GMS_TIE_BACK:'||g_error_api_path,1,230);
      fnd_message.set_name('PSP','PSP_NO_PROFILE_EXISTS');
      fnd_msg_pub.add;
      p_return_status := fnd_api.g_ret_sts_unexp_error;

   WHEN NO_VAL_DATE_MATCHES THEN
      g_error_api_path := SUBSTR('GMS_TIE_BACK:'||g_error_api_path,1,230);
      fnd_message.set_name('PSP','PSP_NO_VAL_DATE_MATCHES');
      fnd_message.set_token('ORG_NAME',l_orig_org_name1);
      fnd_message.set_token('PAYROLL_DATE',l_distribution_date);
      fnd_msg_pub.add;
      p_return_status := fnd_api.g_ret_sts_unexp_error;

   WHEN NO_GLOBAL_ACCT_EXISTS THEN
      g_error_api_path := SUBSTR('GMS_TIE_BACK:'||g_error_api_path,1,230);
      fnd_message.set_name('PSP','PSP_NO_GLOBAL_ACCT_EXISTS');
      fnd_message.set_token('ORG_NAME',l_orig_org_name1);
      fnd_message.set_token('PAYROLL_DATE',l_distribution_date);
      fnd_msg_pub.add;
      p_return_status := fnd_api.g_ret_sts_unexp_error;  --End of Modification for Bug 2056877.

   WHEN OTHERS THEN
      g_error_api_path := 'GMS_TIE_BACK:'||g_error_api_path;
      fnd_msg_pub.add_exc_msg('PSP_SUM_TRANS','GMS_TIE_BACK');
      p_return_status := fnd_api.g_ret_sts_unexp_error;
 END;

------------------ INSERT INTO GMS INTERFACE -----------------------------------------------

 PROCEDURE insert_into_pa_interface(
	P_TRANSACTION_INTERFACE_ID	IN	NUMBER,
	P_TRANSACTION_SOURCE		IN	VARCHAR2,
	P_BATCH_NAME			IN	VARCHAR2,
	P_EXPENDITURE_ENDING_DATE	IN	DATE,
	P_EMPLOYEE_NUMBER			IN	VARCHAR2,
	P_ORGANIZATION_NAME		IN	VARCHAR2,
	P_EXPENDITURE_ITEM_DATE		IN	DATE,
	P_PROJECT_NUMBER			IN	VARCHAR2,
	P_TASK_NUMBER			IN	VARCHAR2,
	P_EXPENDITURE_TYPE		IN	VARCHAR2,
	P_QUANTITY				IN	NUMBER,
	P_RAW_COST				IN	NUMBER,
	P_EXPENDITURE_COMMENT		IN	VARCHAR2,
	P_TRANSACTION_STATUS_CODE	IN	VARCHAR2,
	P_ORIG_TRANSACTION_REFERENCE	IN	VARCHAR2,
	P_ORG_ID			IN	NUMBER,
	P_DENOM_CURRENCY_CODE		IN	VARCHAR2,
	P_DENOM_RAW_COST		IN	NUMBER,
	P_ATTRIBUTE1			IN	VARCHAR2,
	P_ATTRIBUTE2			IN	VARCHAR2,
	P_ATTRIBUTE3			IN	VARCHAR2,
	P_ATTRIBUTE4			IN	VARCHAR2,		-- Introduced attributes 4 and 5 for bug fix 2908859
	P_ATTRIBUTE5			IN	VARCHAR2,
	P_ATTRIBUTE6			IN	VARCHAR2,
	P_ATTRIBUTE7			IN	VARCHAR2,
	P_ATTRIBUTE8			IN	VARCHAR2,
	P_ATTRIBUTE9			IN	VARCHAR2,
	P_ATTRIBUTE10			IN	VARCHAR2,
	P_ACCT_RATE_TYPE                IN      VARCHAR2,       -- Introduced for bug fix 2916848
        P_ACCT_RATE_DATE                IN      DATE,           -- Introduced for bug fix 2916848
	P_PERSON_BUSINESS_GROUP_ID	IN	NUMBER,		-- Introduced for bug 2935850
	P_RETURN_STATUS			OUT NOCOPY	VARCHAR2) IS
l_unmatched_nve_txn_flag	char(1);  -- Bug 8984069
 BEGIN

-- Bug 8984069
	IF (p_quantity < 0) THEN
		l_unmatched_nve_txn_flag := 'Y';
	END IF;

--   dbms_output.put_line('batch name='||p_batch_name);

   INSERT INTO PA_TRANSACTION_INTERFACE_ALL(
	TXN_INTERFACE_ID,
	TRANSACTION_SOURCE,
	BATCH_NAME,
	EXPENDITURE_ENDING_DATE,
	EMPLOYEE_NUMBER,
	ORGANIZATION_NAME,
	EXPENDITURE_ITEM_DATE,
	PROJECT_NUMBER,
	TASK_NUMBER,
	EXPENDITURE_TYPE,
	QUANTITY,
	RAW_COST,
	EXPENDITURE_COMMENT,
	TRANSACTION_STATUS_CODE,
	ORIG_TRANSACTION_REFERENCE,
	ORG_ID,
	DENOM_CURRENCY_CODE,
	DENOM_RAW_COST,
	ATTRIBUTE1,
	ATTRIBUTE2,
	ATTRIBUTE3,
	ATTRIBUTE4,		-- Introduced attributes 4 and 5 for bug fix 2908859
	ATTRIBUTE5,
	ATTRIBUTE6,
	ATTRIBUTE7,
	ATTRIBUTE8,
	ATTRIBUTE9,
	ATTRIBUTE10,
	PERSON_BUSINESS_GROUP_ID,
	--  Introduced the following columns for bug fix 2916848
        ACCT_RATE_TYPE,
        ACCT_RATE_DATE,
        -- Bug 8984069
        UNMATCHED_NEGATIVE_TXN_FLAG)
   VALUES(
	P_TRANSACTION_INTERFACE_ID,
	P_TRANSACTION_SOURCE,
	P_BATCH_NAME,
	P_EXPENDITURE_ENDING_DATE,
	P_EMPLOYEE_NUMBER,
	P_ORGANIZATION_NAME,
	P_EXPENDITURE_ITEM_DATE,
	P_PROJECT_NUMBER,
	P_TASK_NUMBER,
	P_EXPENDITURE_TYPE,
	P_QUANTITY,
	P_RAW_COST,
	P_EXPENDITURE_COMMENT,
	P_TRANSACTION_STATUS_CODE,
	P_ORIG_TRANSACTION_REFERENCE,
	P_ORG_ID,
	P_DENOM_CURRENCY_CODE,
	P_DENOM_RAW_COST,
	P_ATTRIBUTE1,
	P_ATTRIBUTE2,
	P_ATTRIBUTE3,
	P_ATTRIBUTE4,		-- Introduced attributes 4 and 5 for bug fix 2908859
	P_ATTRIBUTE5,
	P_ATTRIBUTE6,
	P_ATTRIBUTE7,
	P_ATTRIBUTE8,
	P_ATTRIBUTE9,
	P_ATTRIBUTE10,
	P_PERSON_BUSINESS_GROUP_ID,
--      Introduced the following columns for bug fix 2916848
        P_ACCT_RATE_TYPE,
        DECODE(p_acct_rate_type, NULL, NULL, P_ACCT_RATE_DATE),
        -- Bug 8984069
        l_unmatched_nve_txn_flag);

    p_return_status := fnd_api.g_ret_sts_success;
 EXCEPTION

   WHEN OTHERS THEN
   --   dbms_output.put_line('Error while inserting .........................');
      g_error_api_path := 'INSERT_INTO_PA_INTERFACE:'||g_error_api_path;
      fnd_msg_pub.add_exc_msg('PSP_SUM_TRANS','INSERT_INTO_PA_INTERFACE');
      p_return_status := fnd_api.g_ret_sts_unexp_error;
 END;

/* Created this procedure on 4-Nov-2004.
 Following procedure is introduced for Effort reports Enhancement.
 Purpose of this procedure: Supercede employee effort report(s) if this
 S_AND_T processes distributions for  persons/time periods
 for which effort reports already exist.

 There is no COMMIT statement in this procedure, it will be called
 from mark_batch_end, and the calling procedure will COMMIT the data.

 The volume of ERs superceded is expected to be low, normally
 customer generates ER only when all transactions are imported,
 and hence employees superceded are low.

  Logic:
    - get all the ER requests that can potentially be superceded,
      by comparing the time periods of this process with ER periods.
    - get all persons for this ER request, for whom this S_AND_T has
      distributions
    - if no tolerance is setup, then all emps processed by S_and_T
      are superceded.
    - If tolerance is set as zero, then supercede all those persons
      whose new ER changed w.r.t to old (compare old and Fresh ER)
    - If tolerance is non-zero, but specified as either % or
      absolute amount, then re-create ER, and compare. If
      difference exceeds tolerance then supercede
*/
 PROCEDURE SUPERCEDE_ER(p_run_id        in  integer,
                        errbuf          in out nocopy varchar2,
                        retcode         in out nocopy varchar2,
                        p_source_type   in varchar2,
                        p_source_code   in varchar2,
                        p_time_period_id in integer,
                        p_batch_name     in varchar2,
                        p_return_status out nocopy varchar2) is

  l_supercede_reqid_str varchar2(9000); --Bug 6037692
  l_run_id          integer;
  i                 integer;
  j                 integer;
  t_person_table    t_num_15_type;
  t_efforts_table   t_num_15_type;
  t_sum_line_id     t_num_15_type;
  t_tolerance_per   t_num_15_type;
  t_tolerance_req   t_num_15_type;
  TYPE t_num_15_type_ind   IS TABLE OF NUMBER(15) INDEX BY BINARY_INTEGER;
  t_tolerance_sline t_num_15_type_ind;
  t_request_id      t_num_15_type_ind;
  t_template_id     t_num_15_type_ind;
  t_tolerance_erid  t_num_15_type_ind;
  l_S_and_T_reqid integer;
  l_sql_string    varchar2(12000);   --Bug 6037692
  l_tolerance_amt number;
  l_tolerance_percent number;
  l_superceded_flag boolean := false ;

  --- get all ER template runs, that overlapp S_AND_T time periods.
  cursor check_er_template_h is
   Select distinct pth.template_id,
          pth.request_id
   From psp_payroll_controls ppc,
        Psp_report_templates_h pth,
        Per_time_periods ptp
   Where ppc.run_id = p_run_id
     And ppc.time_period_id = ptp.time_period_id
     And  fnd_date.canonical_to_date(fnd_date.date_to_canonical(pth.parameter_value_3)) >= ptp.start_date
     And  fnd_date.canonical_to_date(fnd_date.date_to_canonical(pth.parameter_value_2)) <= ptp.end_date;

  cursor supercede_tolerance(p_template_id in integer) is
  select nvl(sprcd_tolerance_amt,-999),
         nvl(sprcd_tolerance_percent,-999)
    from psp_report_templates
   where template_id = p_template_id;



   cursor adj_er_supercede is
          Select per.effort_report_id,
                per.person_id,
                min(pal.summary_line_id) summary_line_id
          From psp_adjustment_lines_history pal,
               Psp_eff_reports per,
               Psp_payroll_controls ppc
          Where pal.distribution_date between per.start_date and per.end_date
            And per.request_id in ( select -person_id from psp_supercede_persons_gt  where person_id < 0)
            And ppc.run_id = p_run_id
            And pal.person_id = per.person_id
            And ppc.payroll_control_id = pal.payroll_control_id
            And per.status_code not in ('S','R')
            And pal.element_type_id in
                ((select petr.element_type_id from pay_element_type_rules petr, psp_report_template_details_h prth where
                  petr.include_or_exclude ='I' and
                  prth.request_id =per.request_id and prth.criteria_lookup_code='EST' and
                  petr.element_Set_id = prth.criteria_value1 )
                  union all (select pet1.element_type_id from
                  pay_element_types_f pet1, pay_ele_classification_rules pecr,
                  psp_report_template_details_h prth1
                  where pet1.classification_id = pecr.classification_id and
                  prth1.criteria_lookup_code='EST'  and prth1.request_id =per.request_id and
                        pecr.element_Set_id = prth1.criteria_value1 ))
            And pal.element_type_id not in
                 (select petr1.element_type_id from pay_element_type_rules petr1,
                  psp_report_template_Details_h prth2
                  where petr1.include_or_exclude='E'
                  and prth2.request_id = per.request_id
                  and prth2.criteria_lookup_code='EST' and prth2.criteria_value1= petr1.element_Set_id )
          group by per.person_id, per.effort_report_id;

  cursor pregen_er_supercede is
        Select  per.effort_report_id,
                per.person_id,
                min(pregen.summary_line_id)
          From psp_pre_gen_dist_lines_history pregen,
               Psp_eff_reports per,
               Psp_payroll_controls ppc
          Where pregen.distribution_date between per.start_date and per.end_date
            And per.request_id in (select -person_id from psp_supercede_persons_gt where person_id < 0)
            And ppc.run_id = p_run_id
            And pregen.person_id = per.person_id
            And ppc.payroll_control_id = pregen.payroll_control_id
            And per.status_code not in ('S','R')
            And pregen.element_type_id in
                ((select petr.element_type_id from pay_element_type_rules petr, psp_report_template_details_h prth where
                  petr.include_or_exclude ='I' and
                  prth.request_id =per.request_id and prth.criteria_lookup_code='EST' and
                  petr.element_Set_id = prth.criteria_value1
                  )
                  union all
                  (select pet1.element_type_id from
                  pay_element_types_f pet1, pay_ele_classification_rules pecr,
                  psp_report_template_details_h prth1
                  where pet1.classification_id = pecr.classification_id and
                  prth1.criteria_lookup_code='EST'  and prth1.request_id =per.request_id and
                  pecr.element_Set_id = prth1.criteria_value1
                  ))
            And pregen.element_type_id not in
                 (select petr1.element_type_id from pay_element_type_rules petr1,
                  psp_report_template_Details_h prth2
                  where petr1.include_or_exclude='E'
                  and prth2.request_id = per.request_id
                  and prth2.criteria_lookup_code='EST' and prth2.criteria_value1= petr1.element_Set_id
                  )
          group by per.person_id,per.effort_report_id;

   cursor payroll_er_supercede is
        Select  per.effort_report_id,
                per.person_id,
                MIN(dlh.summary_line_id) summary_line_id
        From psp_eff_reports per,
             Psp_distribution_lines_history DLH,
             Psp_payroll_controls ppc,
             psp_payroll_sub_lines psub,
             psp_payroll_lines ppl
        Where dlh.payroll_sub_line_id = psub.payroll_sub_line_id
          And per.request_id in (select -person_id from psp_supercede_persons_gt where person_id < 0)
          And psub.payroll_line_id = ppl.payroll_line_id
          And ppl.person_id = per.person_id
          And dlh.distribution_date between per.start_date and per.end_date
          And ppc.run_id =   p_run_id
          And ppc.payroll_control_id = ppl.payroll_control_id
          And per.status_code not in ('S','R')
          And ppl.element_type_id in
              ((select petr.element_type_id from pay_element_type_rules petr, psp_report_template_details_h prth where
                  petr.include_or_exclude ='I' and
                  prth.request_id =per.request_id and prth.criteria_lookup_code='EST' and
                  petr.element_Set_id = prth.criteria_value1
                  )
                  union all
                  (select pet1.element_type_id from
                  pay_element_types_f pet1, pay_ele_classification_rules pecr,
                  psp_report_template_details_h prth1
                  where pet1.classification_id = pecr.classification_id and
                  prth1.criteria_lookup_code='EST' and prth1.request_id =per.request_id and
                  pecr.element_Set_id = prth1.criteria_value1
                  ))
          And ppl.element_type_id not in
                 (select petr1.element_type_id from pay_element_type_rules petr1,
                  psp_report_template_Details_h prth2
                  where petr1.include_or_exclude='E'
                  and prth2.request_id = per.request_id
                  and prth2.criteria_lookup_code='EST' and prth2.criteria_value1= petr1.element_Set_id
                  )
          group by per.person_id,per.effort_report_id;

   cursor all_er_supercede is
        select effort_report_id,
               person_id,
               min(summary_line_id) summary_line_id
        from (
        Select  per.effort_report_id,
                per.person_id,
                dlh.summary_line_id summary_line_id
        From psp_eff_reports per,
             Psp_distribution_lines_history DLH,
             Psp_payroll_controls ppc,
             psp_payroll_sub_lines psub,
             psp_payroll_lines ppl
        Where dlh.payroll_sub_line_id = psub.payroll_sub_line_id
          And per.request_id in (select -person_id from psp_supercede_persons_gt)
          And psub.payroll_line_id = ppl.payroll_line_id
          And ppl.person_id = per.person_id
          And dlh.distribution_date between per.start_date and per.end_date
          And ppc.run_id =   p_run_id
          And ppc.payroll_control_id = ppl.payroll_control_id
          And per.status_code not in ('S','R')
          And ppl.element_type_id in
              ((select petr.element_type_id from pay_element_type_rules petr, psp_report_template_details_h prth where
                  petr.include_or_exclude ='I' and
                  prth.request_id =per.request_id and prth.criteria_lookup_code='EST' and
                  petr.element_Set_id = prth.criteria_value1
                  )
                  union all
                  (select pet1.element_type_id from
                  pay_element_types_f pet1, pay_ele_classification_rules pecr,
                  psp_report_template_details_h prth1
                  where pet1.classification_id = pecr.classification_id and
                  prth1.criteria_lookup_code='EST'  and prth1.request_id =per.request_id
                  and pecr.element_Set_id = prth1.criteria_value1
                  ))
          And ppl.element_type_id not in
                 (select petr1.element_type_id from pay_element_type_rules petr1,
                  psp_report_template_Details_h prth2
                  where petr1.include_or_exclude='E'
                  and prth2.request_id = per.request_id
                  and prth2.criteria_lookup_code='EST' and prth2.criteria_value1= petr1.element_Set_id
                  )
        UNION ALL
        Select  per.effort_report_id,
                per.person_id,
                pregen.summary_line_id summary_line_id
          From psp_pre_gen_dist_lines_history pregen,
               Psp_eff_reports per,
               Psp_payroll_controls ppc
          Where pregen.distribution_date between per.start_date and per.end_date
            And per.request_id in ( select -person_id from psp_supercede_persons_gt )
            And ppc.run_id = p_run_id
            And pregen.person_id = per.person_id
            And ppc.payroll_control_id = pregen.payroll_control_id
            And per.status_code not in ('S','R')
            And pregen.element_type_id in
                ((select petr.element_type_id from pay_element_type_rules petr, psp_report_template_details_h prth where
                  petr.include_or_exclude ='I' and
                  prth.request_id =per.request_id and prth.criteria_lookup_code='EST'
                  and petr.element_Set_id = prth.criteria_value1
                  )
                  union all
                  (select pet1.element_type_id from
                  pay_element_types_f pet1, pay_ele_classification_rules pecr,
                  psp_report_template_details_h prth1
                  where pet1.classification_id = pecr.classification_id and
                  prth1.criteria_lookup_code='EST'  and prth1.request_id =per.request_id
                  and pecr.element_Set_id = prth1.criteria_value1
                  ))
            And pregen.element_type_id not in
                 (select petr1.element_type_id from pay_element_type_rules petr1,
                  psp_report_template_Details_h prth2
                  where petr1.include_or_exclude='E'
                  and prth2.request_id = per.request_id
                  and prth2.criteria_lookup_code='EST' and prth2.criteria_value1= petr1.element_Set_id
                  ))
          group by person_id,effort_report_id;

 --- included asg check for uva asg matching
   cursor adj_asg_er_supercede is
          Select per.effort_report_id,
                per.person_id,
                min(pal.summary_line_id) summary_line_id
          From psp_adjustment_lines_history pal,
               Psp_eff_reports per,
               Psp_payroll_controls ppc,
               psp_eff_report_details perd
          Where pal.distribution_date between per.start_date and per.end_date
            and perd.effort_report_id = per.effort_report_id
            and perd.assignment_id = pal.assignment_id
            And per.request_id in ( select -person_id from psp_supercede_persons_gt  where person_id < 0)
            And ppc.run_id = p_run_id
            And pal.person_id = per.person_id
            And ppc.payroll_control_id = pal.payroll_control_id
            And per.status_code not in ('S','R')
            And pal.element_type_id in
                ((select petr.element_type_id from pay_element_type_rules petr, psp_report_template_details_h prth where
                  petr.include_or_exclude ='I'
                  and prth.request_id =per.request_id and prth.criteria_lookup_code='EST'
                  and petr.element_Set_id = prth.criteria_value1 )
                  union all (select pet1.element_type_id from
                  pay_element_types_f pet1, pay_ele_classification_rules pecr,
                  psp_report_template_details_h prth1
                  where pet1.classification_id = pecr.classification_id
                  and prth1.criteria_lookup_code='EST'  and prth1.request_id =per.request_id
                  and pecr.element_Set_id = prth1.criteria_value1 ))
            And pal.element_type_id not in
                 (select petr1.element_type_id from pay_element_type_rules petr1,
                  psp_report_template_Details_h prth2
                  where petr1.include_or_exclude='E'
                  and prth2.request_id = per.request_id
                  and prth2.criteria_lookup_code='EST' and prth2.criteria_value1= petr1.element_Set_id )
          group by per.person_id, per.effort_report_id;

  cursor pregen_asg_er_supercede is
        Select  per.effort_report_id,
                per.person_id,
                min(pregen.summary_line_id)
          From psp_pre_gen_dist_lines_history pregen,
               Psp_eff_reports per,
               Psp_payroll_controls ppc,
               psp_eff_report_details perd
          Where pregen.distribution_date between per.start_date and per.end_date
            and perd.effort_report_id = per.effort_report_id
            and perd.assignment_id = pregen.assignment_id
            And per.request_id in (select -person_id from psp_supercede_persons_gt where person_id < 0)
            And ppc.run_id = p_run_id
            And pregen.person_id = per.person_id
            And ppc.payroll_control_id = pregen.payroll_control_id
            And per.status_code not in ('S','R')
            And pregen.element_type_id in
                ((select petr.element_type_id from pay_element_type_rules petr, psp_report_template_details_h prth where
                  petr.include_or_exclude ='I' and
                  prth.request_id =per.request_id and prth.criteria_lookup_code='EST'
                  and petr.element_Set_id = prth.criteria_value1
                  )
                  union all
                  (select pet1.element_type_id from
                  pay_element_types_f pet1, pay_ele_classification_rules pecr,
                  psp_report_template_details_h prth1
                  where pet1.classification_id = pecr.classification_id and
                  prth1.criteria_lookup_code='EST'  and prth1.request_id =per.request_id
                  and pecr.element_Set_id = prth1.criteria_value1
                  ))
            And pregen.element_type_id not in
                 (select petr1.element_type_id from pay_element_type_rules petr1,
                  psp_report_template_Details_h prth2
                  where petr1.include_or_exclude='E'
                  and prth2.request_id = per.request_id
                  and prth2.criteria_lookup_code='EST' and prth2.criteria_value1= petr1.element_Set_id
                  )
          group by per.person_id,per.effort_report_id;

   cursor payroll_asg_er_supercede is
        Select  per.effort_report_id,
                per.person_id,
                MIN(dlh.summary_line_id) summary_line_id
        From psp_eff_reports per,
             Psp_distribution_lines_history DLH,
             Psp_payroll_controls ppc,
             psp_payroll_sub_lines psub,
             psp_payroll_lines ppl,
             psp_eff_report_details perd
        Where dlh.payroll_sub_line_id = psub.payroll_sub_line_id
          and perd.effort_report_id = per.effort_report_id
          and perd.assignment_id = ppl.assignment_id
          And per.request_id in (select -person_id from psp_supercede_persons_gt where person_id < 0)
          And psub.payroll_line_id = ppl.payroll_line_id
          And ppl.person_id = per.person_id
          And dlh.distribution_date between per.start_date and per.end_date
          And ppc.run_id =   p_run_id
          And ppc.payroll_control_id = ppl.payroll_control_id
          And per.status_code not in ('S','R')
          And ppl.element_type_id in
              ((select petr.element_type_id from pay_element_type_rules petr, psp_report_template_details_h prth where
                  petr.include_or_exclude ='I'
                   and prth.request_id =per.request_id and prth.criteria_lookup_code='EST'
                  and petr.element_Set_id = prth.criteria_value1
                  )
                  union all
                  (select pet1.element_type_id from
                  pay_element_types_f pet1, pay_ele_classification_rules pecr,
                  psp_report_template_details_h prth1
                  where pet1.classification_id = pecr.classification_id and
                  prth1.criteria_lookup_code='EST'  and prth1.request_id =per.request_id
                  and pecr.element_Set_id = prth1.criteria_value1
                  ))
          And ppl.element_type_id not in
                 (select petr1.element_type_id from pay_element_type_rules petr1,
                  psp_report_template_Details_h prth2
                  where petr1.include_or_exclude='E'
                  and prth2.request_id = per.request_id
                  and prth2.criteria_lookup_code='EST' and prth2.criteria_value1= petr1.element_Set_id
                  )
          group by per.person_id,per.effort_report_id;


   cursor all_asg_er_supercede is
        select effort_report_id,
               person_id,
               min(summary_line_id) summary_line_id
        from (
        Select  per.effort_report_id,
                per.person_id,
                dlh.summary_line_id summary_line_id
        From psp_eff_reports per,
             Psp_distribution_lines_history DLH,
             Psp_payroll_controls ppc,
             psp_payroll_sub_lines psub,
             psp_payroll_lines ppl,
             psp_eff_report_details perd
        Where dlh.payroll_sub_line_id = psub.payroll_sub_line_id
          and perd.effort_report_id = per.effort_report_id
          and perd.assignment_id = ppl.assignment_id
          And per.request_id in (select -person_id from psp_supercede_persons_gt)
          And psub.payroll_line_id = ppl.payroll_line_id
          And ppl.person_id = per.person_id
          And dlh.distribution_date between per.start_date and per.end_date
          And ppc.run_id =   p_run_id
          And ppc.payroll_control_id = ppl.payroll_control_id
          And per.status_code not in ('S','R')
          And ppl.element_type_id in
              ((select petr.element_type_id from pay_element_type_rules petr, psp_report_template_details_h prth where
                  petr.include_or_exclude ='I' and
                  prth.request_id =per.request_id and prth.criteria_lookup_code='EST'
                  and petr.element_Set_id = prth.criteria_value1
                  )
                  union all
                  (select pet1.element_type_id from
                  pay_element_types_f pet1, pay_ele_classification_rules pecr,
                  psp_report_template_details_h prth1
                  where pet1.classification_id = pecr.classification_id
                  and prth1.criteria_lookup_code='EST'  and prth1.request_id =per.request_id
                  and pecr.element_Set_id = prth1.criteria_value1
                  ))
          And ppl.element_type_id not in
                 (select petr1.element_type_id from pay_element_type_rules petr1,
                  psp_report_template_Details_h prth2
                  where petr1.include_or_exclude='E'
                  and prth2.request_id = per.request_id
                  and prth2.criteria_lookup_code='EST' and prth2.criteria_value1= petr1.element_Set_id
                  )
        UNION ALL
        Select  per.effort_report_id,
                per.person_id,
                pregen.summary_line_id summary_line_id
          From psp_pre_gen_dist_lines_history pregen,
               Psp_eff_reports per,
               Psp_payroll_controls ppc,
             psp_eff_report_details perd
          Where pregen.distribution_date between per.start_date and per.end_date
            and perd.effort_report_id = per.effort_report_id
            and perd.assignment_id = pregen.assignment_id
            And per.request_id in ( select -person_id from psp_supercede_persons_gt )
            And ppc.run_id = p_run_id
            And pregen.person_id = per.person_id
            And ppc.payroll_control_id = pregen.payroll_control_id
            And per.status_code not in ('S','R')
            And pregen.element_type_id in
                ((select petr.element_type_id from pay_element_type_rules petr, psp_report_template_details_h prth where
                  petr.include_or_exclude ='I'
                  and prth.request_id =per.request_id and prth.criteria_lookup_code='EST'
                  and petr.element_Set_id = prth.criteria_value1
                  )
                  union all
                  (select pet1.element_type_id from
                  pay_element_types_f pet1, pay_ele_classification_rules pecr,
                  psp_report_template_details_h prth1
                  where pet1.classification_id = pecr.classification_id
                  and prth1.criteria_lookup_code='EST'  and prth1.request_id =per.request_id
                  and pecr.element_Set_id = prth1.criteria_value1
                  ))
            And pregen.element_type_id not in
                 (select petr1.element_type_id from pay_element_type_rules petr1,
                  psp_report_template_Details_h prth2
                  where petr1.include_or_exclude='E'
                  and prth2.request_id = per.request_id
                  and prth2.criteria_lookup_code='EST' and prth2.criteria_value1= petr1.element_Set_id
                  ))
          group by person_id,effort_report_id;
  cursor check_emp_overlap is
  select count(*)
    from psp_Eff_reports per,
         psp_summary_lines psl
   where per.person_id = psl.person_id
     and psl.payroll_control_id in
            (select payroll_control_id
               from psp_payroll_controls
              where run_id = p_run_id)
     and rownum = 1
     and per.request_id in
            (select abs(person_id)
               from psp_supercede_persons_gt
              where person_id < 0);
   l_emp_overlap_count integer;

 -- uva isue, supercede for matching asg option
    cursor check_emp_match_option is
    select count(*)
      from psp_report_templates_h
     where  request_id in  ( select -person_id from psp_supercede_persons_gt )
       and selection_match_level  =  'EMP';

 l_count_emp_match integer;

  cursor get_eff_id(p_req_id in integer, p_per_id in integer) is
  select effort_report_id
    from psp_eff_reports
   where request_id = p_req_id and person_id = p_per_id;
  l_eff_id integer;

    l_proj_segment varchar2(30);
    l_tsk_segment varchar2(30);
    l_awd_sgement varchar2(30);
    l_exp_org_segment varchar2(30);
    l_exp_type_segment varchar2(30);
    l_profile_bg_id Number   := FND_PROFILE.VALUE('PER_BUSINESS_GROUP_ID');

  CURSOR get_Con_Program_name_csr IS
  SELECT USER_CONCURRENT_PROGRAM_NAME
  FROM  fnd_concurrent_programs_vl fcp
  WHERE CONCURRENT_PROGRAM_ID = fnd_global.CONC_PROGRAM_ID;
  l_Con_Program_name varchar2(240);


  PROCEDURE SEND_NOTIFICATIONS(p_supercede_reqid_str in varchar2,
                               p_template_id         in integer,
                               p_SandT_reqid         in integer,
                               p_batch_name          in varchar2,
                               p_source_type         in varchar2,
                               p_source_code         in varchar2,
                               p_time_period_id      in varchar2) is


   l_role_display varchar2(500);
   l_member_rname varchar2(500);
   l_approver_notify boolean;
   l_employee_notify boolean;
   l_init_notify boolean;
   l_frp_notify boolean;
   t_wf_roles  t_varchar2_400_type;
   t_person_id t_num_15_type;
   l_template_name varchar2(240);
   l_distribution_source varchar2(260);
   l_time_period_name    varchar2(100);

   cursor get_template_name is
   select template_name
     from psp_report_templates
    where template_id = p_template_id;

   cursor get_superceding_source is
   select description
    from  psp_payroll_sources
   where source_type = p_source_type
     and source_code = p_source_code;

   cursor get_time_period_name is
   select period_name
     from per_time_periods
    where time_period_id = p_time_period_id;

   cursor get_frp_wf_names is
           select distinct wf.name,
                  wf.orig_system_id
            from wf_roles wf,
                 psp_report_templates_h h,
                 psp_report_template_details_h dtl
           where wf.orig_system = 'PER'
             and to_char(wf.orig_system_id) = dtl.criteria_value1
             and dtl.criteria_lookup_type = 'PSP_SELECTION_CRITERIA'
             and dtl.criteria_lookup_code = 'FRP'
             and dtl.request_id = h.request_id
             and h.request_id in ( select -person_id
                                     from psp_supercede_persons_gt
                                    where person_id < 0)
             and h.final_recip_notified_flag = 'Y';

   cursor get_init_wf_names is
           select distinct wf.name,
                  wf.orig_system_id
            from wf_roles wf,
                 psp_report_templates_h h
           where wf.orig_system = 'PER'
             and wf.orig_system_id = h.initiator_person_id
             and h.request_id in ( select -person_id
                                     from psp_supercede_persons_gt
                                    where person_id < 0)
              and exists (select 1 from psp_eff_reports per
                          where per.request_id = h.request_id
                            and per.superceding_request_id = p_SandT_reqid);

   cursor get_per_wf_names is
           select distinct wf.name,
                  er.person_id
            from wf_roles wf,
                 psp_eff_reports er,
                 psp_report_templates_h h
           where wf.orig_system = 'PER'
             and wf.orig_system_id = er.person_id
             and h.request_id = er.request_id
             and h.initiator_accept_flag = 'Y'
             and er.request_id in ( select -person_id
                                      from psp_supercede_persons_gt
                                     where person_id < 0)
             and er.superceding_request_id = p_SandT_reqid;

   cursor get_app_wf_names is
          select distinct era.wf_role_name
            from psp_eff_report_approvals era,
                 psp_eff_report_details erd,
                 psp_eff_reports er,
                 psp_report_templates_h h
           where erd.effort_report_detail_id = era.effort_report_detail_id
            and erd.effort_report_id = er.effort_report_id
            and er.request_id in ( select -person_id from psp_supercede_persons_gt where person_id < 0 )
            and er.superceding_request_id  = p_SandT_reqid
            and era.approval_status <> 'R'
            and er.request_id = h.request_id
            and h.initiator_accept_flag = 'Y';

  PROCEDURE      GET_RECEIVER_TYPES(p_template_id         in integer,
                                    p_initiator_notify    out nocopy boolean,
                                    p_final_recip_notify  out nocopy boolean,
                                    p_approver_notify     out nocopy boolean,
                                    p_employee_notify     out nocopy boolean) is
    cursor get_notify_types is
    select criteria_lookup_code
      from psp_report_template_details
     where template_id = p_template_id
       and criteria_lookup_type = 'PSP_SUPERCEDED_NOTIFICATION';

   notify_type        varchar2(10);

  BEGIN
     p_approver_notify    := false;
     p_initiator_notify   := false;
     p_final_recip_notify := false;
     p_employee_notify  := false;
    open get_notify_types;
    loop
      fetch get_notify_types into notify_type;
      if get_notify_types%notfound then
         if get_notify_types%rowcount = 0 then
           close get_notify_types;
           hr_utility.trace( 'SandT_Supercede--> GET_RECIVER_TYPES--> Superceded notifier types not found');
           return;
         end if;
         close get_notify_types;
         exit;
       end if;
       if notify_type = 'A' then
           p_approver_notify := true;
           hr_utility.trace( 'SandT_Supercede--> GET_RECIVER_TYPES--> p_apporver_notify');
       elsif notify_type = 'I' then
           p_initiator_notify := true;
           hr_utility.trace( 'SandT_Supercede--> GET_RECIVER_TYPES--> initiator_notify');
       elsif notify_type = 'F' then
           p_final_recip_notify  := true;
           hr_utility.trace( 'SandT_Supercede--> GET_RECIVER_TYPES--> final_recip_notify');
       elsif notify_type = 'E' then
           p_employee_notify := true;
           hr_utility.trace( 'SandT_Supercede--> GET_RECIVER_TYPES--> p_employee_notify');
       end if;
    end loop;

   EXCEPTION
   when others then

     hr_utility.trace( 'SandT_Supercede-->send notifications --> GET_RECEIVER_TYPES when others '||sqlerrm);
     fnd_msg_pub.add_exc_msg('PSP_SUM_TRANS','GET_RECEIVER_TYPES');
     raise;
  END GET_RECEIVER_TYPES;

  PROCEDURE CALL_WF(p_supercede_reqid_str in varchar2,
                    p_wf_user          in varchar2,
                    p_SandT_reqid      in integer,
                    p_person_id        in integer,
                    p_approver_type    in varchar2,
                    p_template_name    in varchar2,
                    p_batch_name       in varchar2,
                    p_superceding_source in varchar2,
                    p_time_period_name   in varchar2,
                    p_source_type        in varchar2,
                    p_source_code        in varchar2,
                    p_time_period_id     in varchar2) is

     l_wf_itemkey integer;
     l_superceding_process varchar2(200);
     l_superceding_proc_param varchar2(500);

   BEGIN

       hr_utility.trace('SandT_Supercede--> send_notifications --> call_wf Parameters: p_supercede_reqid_str = '||
                    p_supercede_reqid_str||',  p_wf_user ='|| p_wf_user||',  p_SandT_reqid='||
                     p_SandT_reqid||
                    ', p_person_id='||p_person_id||', p_approver_type = '||p_approver_type||
                    ', p_source_type='|| p_source_type ||', p_source_code='|| p_source_code||
                    ', p_time_period_id='||p_time_period_id);

       select psp_wf_item_key_s.nextval
       into  l_wf_itemkey
       from dual;

       if p_source_type = 'A' then
           l_superceding_process := 'PSP: Summarize And Transfer Adjustments';
           l_superceding_proc_param := p_batch_name;
       else
           l_superceding_process := 'PSP: Summarize And Transfer Payroll Distributions';
           l_superceding_proc_param := p_source_type||', '||p_source_code||', '||
                         g_payroll_id||', '||p_time_period_id||', '||p_batch_name;
       end if;

       wf_engine.CreateProcess(itemtype => 'PSPERAVL',
                               itemkey  => l_wf_itemkey,
                               process  => 'SUPERCEDE_PROCESS');


       /*Added for bug 7004679 */
        wf_engine.setitemowner(itemtype => 'PSPERAVL',
                               itemkey  => l_wf_itemkey,
                               owner    => p_wf_user);



       wf_engine.SetItemAttrText(itemtype => 'PSPERAVL',
                                 itemkey  => l_wf_itemkey,
                                 aname    => 'SUPERCEDING_PROC_NAME',
                                 avalue   => l_superceding_process);

       wf_engine.SetItemAttrText(itemtype => 'PSPERAVL',
                                 itemkey  => l_wf_itemkey,
                                 aname    => 'SUPERCEDING_PAYROLL_SOURCE',
                                 avalue   => p_source_type);

       wf_engine.SetItemAttrText(itemtype => 'PSPERAVL',
                                 itemkey  => l_wf_itemkey,
                                 aname    => 'SUPERCEDING_PROC_PARAM',
                                 avalue   => l_superceding_proc_param);

       wf_engine.SetItemAttrText(itemtype => 'PSPERAVL',
                                 itemkey  => l_wf_itemkey,
                                 aname    => 'SUPERCEDED_ER_REQ_ID_STR',
                                 avalue   => p_supercede_reqid_str);

       wf_engine.SetItemAttrNumber(itemtype => 'PSPERAVL',
                                  itemkey  => l_wf_itemkey,
                                  aname    => 'SUPERCEDING_S_AND_T_REQID',
                                  avalue   => p_SandT_reqid);

       wf_engine.SetItemAttrText(itemtype => 'PSPERAVL',
                                 itemkey  => l_wf_itemkey,
                                 aname    => 'SUPERCEDE_RECIPIENT_TYPE',
                                 avalue   => p_approver_type);   --- initiatior, final recipients,
                                                                ---- employee, past approvers
       wf_engine.SetItemAttrText(itemType => 'PSPERAVL',
                                 itemkey  => l_wf_itemkey,
                                 aname    => 'TEMPLATE_NAME',
                                 avalue   => l_template_name);

          wf_engine.SetItemAttrNumber(itemtype => 'PSPERAVL',
                                    itemkey  => l_wf_itemkey,
                                    aname    => 'PERSON_ID',
                                    avalue   => p_person_id);

          wf_engine.SetItemAttrText(itemtype => 'PSPERAVL',
                                    itemkey  => l_wf_itemkey,
                                    aname    => 'APPROVER_ROLE_NAME',
                                    avalue   => p_wf_user);

      wf_engine.StartProcess(itemtype => 'PSPERAVL',
                             itemkey  => l_wf_itemkey);
   EXCEPTION
   when others then
     hr_utility.trace( 'SandT_Supercede-->send notifications --> call_wf  when others '||sqlerrm);
     fnd_msg_pub.add_exc_msg('PSP_SUM_TRANS','CALL_WF');
     raise;
   END CALL_WF;


  BEGIN  -- send notifications
    hr_utility.trace( 'SandT_Supercede--> send_notifications-->  Begin params : p_supercede_reqid_str= '||
                    p_supercede_reqid_str ||', p_template_id        = '||p_template_id ||
                     ', p_SandT_reqid        = '||p_SandT_reqid ||
                     ', p_batch_name         = '||p_batch_name ||
                     ', p_source_type        = '||p_source_type ||
                     ', p_source_code        = '|| p_source_code ||
                     ', p_time_period_id   = '|| p_time_period_id );
   hr_utility.trace( 'SandT_Supercede--> send_notifications-->get_receiver_types');
    get_receiver_types(p_template_id,
                       l_init_notify,
                       l_frp_notify,
                       l_approver_notify,
                       l_employee_notify);

    open get_template_name;
    fetch get_template_name into l_template_name;
    close get_template_name;

    open get_superceding_source;
    fetch get_superceding_source into l_distribution_source;
    close get_superceding_source;

    if l_init_notify then
            open get_init_wf_names;
            fetch get_init_wf_names bulk collect into t_wf_roles, t_person_id;
            close get_init_wf_names;

             for i in 1..t_wf_roles.count
             loop
               CALL_WF(p_supercede_reqid_str,
                       t_wf_roles(i),
                       p_SandT_reqid,
                       t_person_id(i),
                       'INIT',
                       l_template_name,
                       p_batch_name,
                       l_distribution_source,
                       l_time_period_name,
                       p_source_type,
                       p_source_code,
                       p_time_period_id);
             end loop;
    end if;

    if l_frp_notify then
            open  get_frp_wf_names;
            fetch get_frp_wf_names bulk collect into t_wf_roles, t_person_id;
            close get_frp_wf_names;

             for i in 1..t_wf_roles.count
             loop
               CALL_WF(p_supercede_reqid_str,
                       t_wf_roles(i),
                       p_SandT_reqid,
                       t_person_id(i),
                       'FRP',
                       l_template_name,
                       p_batch_name,
                       l_distribution_source,
                       l_time_period_name,
                       p_source_type,
                       p_source_code,
                       p_time_period_id);
             end loop;
     end if;


       if l_employee_notify then
            open get_per_wf_names;
            fetch get_per_wf_names bulk collect into t_wf_roles, t_person_id;
            close get_per_wf_names;

             for i in 1..t_wf_roles.count
             loop
                 CALL_WF(p_supercede_reqid_str,
                         t_wf_roles(i),
                         p_SandT_reqid,
                         t_person_id(i),
                         'EMP',
                          l_template_name,
                          p_batch_name,
                          l_distribution_source,
                          l_time_period_name,
                          p_source_type,
                          p_source_code,
                          p_time_period_id);
             end loop;
       end if;

    hr_utility.trace( 'SandT_Supercede-->send_notifications--> has dynamic part for approver start');
       if l_approver_notify then
            open get_app_wf_names;
            fetch get_app_wf_names bulk collect into t_wf_roles;
            close get_app_wf_names;
             for i in 1..t_wf_roles.count
             loop
                 CALL_WF(p_supercede_reqid_str,
                         t_wf_roles(i),
                         p_SandT_reqid,
                         null,
                         'APP',
                         l_template_name,
                         p_batch_name,
                         l_distribution_source,
                         l_time_period_name,
                         p_source_type,
                         p_source_code,
                         p_time_period_id);
             end loop;
       end if;
  EXCEPTION
   when others then
     hr_utility.trace( 'SandT_Supercede-->send notifications when others '||sqlerrm);
     fnd_msg_pub.add_exc_msg('PSP_SUM_TRANS','SEND_NOTIFICATIONS');
     raise;
  END SEND_NOTIFICATIONS;
 BEGIN   ----SUPERCEDE_ER
--- comment trace.. debug
---hr_utility.trace_on('Y','ZX');
 hr_utility.trace( 'SandT_Supercede--> Begin  p_run_id='||p_run_id);
 fnd_signon.set_session(to_char(sysdate,'dd-mon-yyyy'));
  p_return_status := fnd_api.g_ret_sts_success;
  l_S_and_T_reqid := fnd_global.conc_request_id;
      fnd_stats.gather_table_stats(ownname => 'PSP',
                                   tabname => 'PSP_SUPERCEDE_PERSONS_GT');
  open check_er_template_h;
  fetch check_er_template_h bulk collect into t_template_id, t_request_id;
  close check_er_template_h;

  if t_template_id.count = 0 then
    return;  --- no template found to supercede
  end if;

  hr_utility.trace( 'SandT_Supercede--> template_id.count='||t_template_id.count);

  l_supercede_reqid_str := null;

  delete psp_supercede_persons_gt;
  for k in 1..t_template_id.count
  loop
    if t_template_id.count = k or   --- supercede for distinct template
       (t_template_id.count >  k  and t_template_id(k) <> t_template_id(k+1)) then
       if l_supercede_reqid_str is null then
          l_supercede_reqid_str := t_request_id(k);
       else
          l_supercede_reqid_str := l_supercede_reqid_str ||', '|| t_request_id(k);
       end if;
       insert into psp_supercede_persons_gt
		(person_id)
	values	( -t_request_id(k));

       open check_emp_overlap;
       fetch check_emp_overlap into l_emp_overlap_count;
       close check_emp_overlap;
    ---fnd_file.put_line(fnd_file.log,'before emp count');
    if l_emp_overlap_count > 0 then

      open check_emp_match_option;
      fetch check_emp_match_option into l_count_emp_match;
      close check_emp_match_option;
      ---fnd_file.put_line(fnd_file.log,'l_count_emp_match = '||l_count_emp_match);
       hr_utility.trace( 'SandT_Supercede--> Main Loop Entered');
       hr_utility.trace( 'SandT_Supercede-->  reqid string, p_source_type, template_id ='||
                  l_supercede_reqid_str||':'||p_source_type||':'||t_template_id(k));
     if l_count_emp_match > 0 then
     if p_source_type = 'A' then    --- from adjustments s_and_t process.
        open adj_er_supercede;
        fetch adj_er_supercede bulk collect into t_efforts_table, t_person_table, t_sum_line_id;
        close adj_er_Supercede;
     elsif p_source_type = 'P' then
        open pregen_er_supercede;
        fetch pregen_er_supercede bulk collect into t_efforts_table, t_person_table, t_sum_line_id;
        close pregen_er_Supercede;
     elsif p_source_type in ('N','O') then	-- Introduced MIN() for bug fix 4024794
        open payroll_er_supercede;
        fetch payroll_er_supercede bulk collect into t_efforts_table, t_person_table, t_sum_line_id;
        close payroll_er_Supercede;
     else
        open all_er_supercede;
        fetch all_er_supercede bulk collect into t_efforts_table, t_person_table, t_sum_line_id;
        close all_er_Supercede;
      end if; --- source type adjustments
     else
     if p_source_type = 'A' then    --- from adjustments s_and_t process.
        open adj_asg_er_supercede;
        fetch adj_asg_er_supercede bulk collect into t_efforts_table, t_person_table, t_sum_line_id;
        close adj_asg_er_Supercede;
     elsif p_source_type = 'P' then
        open pregen_asg_er_supercede;
        fetch pregen_asg_er_supercede bulk collect into t_efforts_table, t_person_table, t_sum_line_id;
        close pregen_asg_er_Supercede;
     elsif p_source_type in ('N','O') then
        open payroll_asg_er_supercede;
        fetch payroll_asg_er_supercede bulk collect into t_efforts_table, t_person_table, t_sum_line_id;
        close payroll_asg_er_Supercede;
        ---fnd_file.put_line(fnd_file.log,'t_efforts_table '||t_efforts_table.count);
     else
        open all_asg_er_supercede;
        fetch all_asg_er_supercede bulk collect into t_efforts_table, t_person_table, t_sum_line_id;
        close all_asg_er_Supercede;
      end if; --- source type adjustments
     end if;
    hr_utility.trace( 'SandT_Supercede-->  loaded the superceded persons, count ='|| t_efforts_table.count);
        --fnd_file.put_line(fnd_file.log, 'SandT_Supercede-->  loaded the superceded persons, count ='|| t_efforts_table.count);
    open supercede_tolerance(t_template_id(k));
    fetch supercede_tolerance into l_tolerance_amt, l_tolerance_percent;
    close supercede_tolerance;
    hr_utility.trace( 'SandT_Supercede--> get_tolerance limits AMT, %'||
             nvl(l_tolerance_amt,0)||','|| nvl(l_tolerance_percent,0));

    if t_efforts_table.count > 0 then
       hr_utility.trace( 'SandT_Supercede-->  t_efforts_table.count > 0');
       if l_tolerance_amt = -999 and l_tolerance_percent = -999 then
         --- if tolerance is not setup then all emps are superceded
         --- Summarize/Transfer run will be superceeded.

         hr_utility.trace( 'SandT_Supercede--> Before update Eff table 1');
          i := 1;
         loop
            if i >  t_efforts_table.count then
              exit;
            end if;
            hr_utility.trace( 'SandT_Supercede-->  Effort report id ='||t_efforts_table(i));

            OPEN get_Con_Program_name_csr;
            FETCH get_Con_Program_name_csr into l_Con_Program_name;
            CLOSE get_Con_Program_name_csr;

--Bug 4339561
-- Pupulating Column superceding_program_name
            update psp_eff_reports
               set status_code = 'S',
                   superceding_summary_line_id = t_sum_line_id(i),
                   superceding_request_id      = l_S_and_T_reqid,
                   superceding_program_name = l_Con_Program_name
             where effort_report_id = t_efforts_table(i);

             if sql%rowcount > 0 then
                l_superceded_flag := true;
             end if;
            hr_utility.trace( 'SandT_Supercede--> Updated the ER table, to put S');
                 i := i + 1;
         end loop;
       else  -- tolerance set to non null value
          --- load session temp table
          hr_utility.trace( 'SandT_Supercede--> purge GT table - 1');
          forall i in 1..t_person_table.count
          insert into psp_supercede_persons_gt
			(person_id)
          values	(t_person_table(i));
          hr_utility.trace( 'SandT_Supercede--> insert into GT potential persons Number of recodrs=' ||t_person_table.count||'person_id =' ||t_person_table(1));
          savepoint populate_er_tables;

           -- create fresh ER for comparison
          hr_utility.trace( 'SandT_Supercede--> before call to psp_create_eff_reports.populate_eff_tables');
          for n in 1..t_template_id.count
          loop
             if t_template_id(n) = t_template_id(k) then
                hr_utility.trace('SandT_Supercede--> call CREATE_EFF params : superced_request='||
                  t_request_id(n)||' , template_id = '||t_template_id(n));
                psp_create_eff_reports.populate_eff_tables(errBuf ,
                                                           retCode,
                                                           null,
                                                           t_request_id(n),
                                                           null,
                                                           'Y');
                hr_utility.trace('SandT_Supercede--> g_summarization_criteria = '|| PSP_CREATE_EFF_REPORTS.g_summarization_criteria);

             end if;
          end loop;
          hr_utility.trace( 'SandT_Supercede--> after call to psp_create_eff_reports.populate_eff_tables');

          if l_tolerance_amt <> -999 then  --- tolerance_amt is not null then
             l_sql_string := ' begin
                              select distinct er.request_id, er.person_id
                                bulk collect into :reqtable, :pertable
                                from psp_eff_report_details erd,
                                     psp_supercede_persons_gt gt,
                                     psp_eff_reports er
                               where er.status_code not in
                                      ('||''''||'S'||''''||','||''''||'R'||''''||')
                                 and er.request_id in ('||l_supercede_reqid_str||')
                                 and er.effort_report_id = erd.effort_report_id
                                 and gt.person_id = er.person_id
                               group by er.request_id, er.person_id '|| PSP_CREATE_EFF_REPORTS.g_summarization_criteria ||
                              ' having abs(sum(decode(er.status_code,'||''''|| 'T'||''''||',
                                           -erd.actual_salary_amt,
                                            erd.actual_salary_amt))) > :l_tolerance_amt;
                              end;';

--Bug 4319874 START
-- Replacing the Dynamic Sql based on Configuration value
		IF PSP_GENERAL.GET_CONFIGURATION_OPTION_VALUE(l_profile_bg_id,'PSP_USE_GL_PTAOE_MAPPING') = 'Y' THEN
				PSP_GENERAL.GET_GL_PTAOE_MAPPING(p_business_group_id => l_profile_bg_id,
					      p_proj_segment => l_proj_segment,
					      p_tsk_segment => l_tsk_segment,
					      p_awd_sgement => l_awd_sgement,
					      p_exp_org_segment=> l_exp_org_segment,
					      p_exp_type_segment => l_exp_type_segment);
			IF (l_proj_segment is null) OR   (l_tsk_segment is null) OR (l_awd_sgement is null) OR
			    (l_exp_org_segment is null) OR (l_exp_type_segment is null) THEN
			     fnd_message.set_name('PSP', 'PSP_GL_PTAOE_NOT_MAPPED');
			      raise fnd_api.g_exc_unexpected_error;
			END IF;
				      l_sql_string := replace(l_sql_string,'psl','erd');
				      l_sql_string := replace(l_sql_string,'gcc','erd');
				      l_sql_string := replace(l_sql_string,l_proj_segment,'PROJECT_ID');
				      l_sql_string := replace(l_sql_string,l_tsk_segment,'TASK_ID');
				      l_sql_string := replace(l_sql_string,l_awd_sgement,'AWARD_ID');
				      l_sql_string := replace(l_sql_string,l_exp_org_segment,'EXPENDITURE_ORGANIZATION_ID');
				      l_sql_string := replace(l_sql_string,l_exp_type_segment,'EXPENDITURE_TYPE');
		ELSE
				      l_sql_string := replace(l_sql_string,'psl','erd');
				      l_sql_string := replace(l_sql_string,'gcc','erd');
				      l_sql_string := replace(l_sql_string,'SEGMENT','GL_SEGMENT');
		END IF;
-- Bug 4319874 : END


              hr_utility.trace( 'SandT_Supercede--> before exec immediate for tol amt'||l_sql_string);
              hr_utility.trace( 'SandT_Supercede--> sql_string ='||l_sql_string);
              execute immediate l_sql_string
                using out t_tolerance_req,
                      out t_tolerance_per,
                       in abs(l_tolerance_amt);
              hr_utility.trace( 'SandT_Supercede--> after exec immediate for tol amt = '||abs(l_tolerance_amt));
           else
             l_sql_string := ' begin
                              select distinct er.request_id, er.person_id
                                bulk collect into :reqtable, :pertable
                                from psp_eff_report_details erd,
                                     psp_supercede_persons_gt gt,
                                     psp_eff_reports er
                               where er.status_code not in
                                      ('||''''||'S'||''''||','||''''||'R'||''''||')
                                 and er.request_id in ('||l_supercede_reqid_str||')
                                 and gt.person_id = er.person_id
                                 and er.effort_report_id = erd.effort_report_id
                               group by er.request_id, er.person_id '||PSP_CREATE_EFF_REPORTS.g_summarization_criteria ||
                              ' having abs(sum(decode(er.status_code,'||''''|| 'T'||''''||',
                                           -erd.payroll_percent,
                                            erd.payroll_percent))) > :l_tolerance_percent;
                               end;';
--Bug 4319874 START
-- Replacing the Dynamic Sql based on Configuration value
		IF PSP_GENERAL.GET_CONFIGURATION_OPTION_VALUE(l_profile_bg_id,'PSP_USE_GL_PTAOE_MAPPING') = 'Y' THEN
				PSP_GENERAL.GET_GL_PTAOE_MAPPING(p_business_group_id => l_profile_bg_id,
					      p_proj_segment => l_proj_segment,
					      p_tsk_segment => l_tsk_segment,
					      p_awd_sgement => l_awd_sgement,
					      p_exp_org_segment=> l_exp_org_segment,
					      p_exp_type_segment => l_exp_type_segment);
			IF (l_proj_segment is null) OR   (l_tsk_segment is null) OR (l_awd_sgement is null) OR
			    (l_exp_org_segment is null) OR (l_exp_type_segment is null) THEN
			     fnd_message.set_name('PSP', 'PSP_GL_PTAOE_NOT_MAPPED');
			      raise fnd_api.g_exc_unexpected_error;
			END IF;
				      l_sql_string := replace(l_sql_string,'psl','erd');
				      l_sql_string := replace(l_sql_string,'gcc','erd');
				      l_sql_string := replace(l_sql_string,l_proj_segment,'PROJECT_ID');
				      l_sql_string := replace(l_sql_string,l_tsk_segment,'TASK_ID');
				      l_sql_string := replace(l_sql_string,l_awd_sgement,'AWARD_ID');
				      l_sql_string := replace(l_sql_string,l_exp_org_segment,'EXPENDITURE_ORGANIZATION_ID');
				      l_sql_string := replace(l_sql_string,l_exp_type_segment,'EXPENDITURE_TYPE');
		ELSE
				      l_sql_string := replace(l_sql_string,'psl','erd');
				      l_sql_string := replace(l_sql_string,'gcc','erd');
				      l_sql_string := replace(l_sql_string,'SEGMENT','GL_SEGMENT');
		END IF;
-- Bug 4319874 : END


              hr_utility.trace( 'SandT_Supercede--> before exec immediate for tol %');
              hr_utility.trace( 'SandT_Supercede--> sql_string ='||l_sql_string);
              execute immediate l_sql_string
                using out t_tolerance_req,
                      out t_tolerance_per,
                       in abs(l_tolerance_percent);
              hr_utility.trace( 'SandT_Supercede--> after exec immediate for tol %');
           end if;
              ---- debug;
              ---commit;  --- remove commit;
              rollback to populate_er_tables;
              hr_utility.trace( 'SandT_Supercede--> before tolerance_req.count = '||t_tolerance_req.count);
            for i in 1..t_tolerance_req.count
            loop
              hr_utility.trace( 'SandT999_Supercede--> before tolerance_req.count = '||t_tolerance_req.count);
              open get_eff_id(t_tolerance_req(i), t_tolerance_per(i));
              fetch get_eff_id into l_eff_id;
              close get_eff_id;
              hr_utility.trace( 'SandTTTTTTupercede--> before tolerance_req.count = '||t_tolerance_req.count);
              t_tolerance_erid(i) := l_eff_id;
              hr_utility.trace( 'Sand%%%%%%%%%%cede--> before tolerance_req.count = '||t_tolerance_req.count);
            end loop;

              hr_utility.trace( 'SandT_Supercede--> before tolerance_erid.count = '||t_tolerance_erid.count);
           if t_tolerance_erid.count > 0 then
              for i in 1..t_tolerance_erid.count
              loop
                hr_utility.trace( 'SandT_Supercede--> tolerance_erid='||t_tolerance_erid(i));
                for j in 1..t_efforts_table.count
                loop
                   if t_tolerance_erid(i) = t_efforts_table(j) then
                      hr_utility.trace( 'SandT_Supercede--> MATCH t_Efforts_Table ='|| t_efforts_table(j));
                      t_tolerance_sline(i) := t_sum_line_id(j);
                   end if;
                end loop;
              end loop;
                -- found ERs to be superceded.
              i := 1;
              loop
                if i > t_tolerance_erid.count then
                  exit;
                end if;
                hr_utility.trace( 'SandT_Supercede--> erid='|| t_tolerance_erid(i));
                if t_tolerance_sline.exists(i) then
                -- found ERs to be superceded.

            OPEN get_Con_Program_name_csr;
            FETCH get_Con_Program_name_csr into l_Con_Program_name;
            CLOSE get_Con_Program_name_csr;
--Bug 4339561
-- Pupulating Column superceding_program_name

                update psp_eff_reports
                   set status_code = 'S',
                       superceding_summary_line_id = t_tolerance_sline(i),
                       superceding_request_id      = l_S_and_T_reqid,
                       superceding_program_name = l_Con_Program_name
                 where effort_report_id = t_tolerance_erid(i);
                hr_utility.trace( 'SandT_Supercede--> Updated erid='|| t_tolerance_erid(i));
                if sql%rowcount > 0 then
                   l_superceded_flag := true;
                end if;
                end if;
                 i := i + 1;
             end loop;
           end if; --- non zero tolerance persons count > 0
       end if;  -- tolerance = 0
       --- delete persons .. retain -persons_ids.. the request_ids.
       delete psp_supercede_persons_gt where person_id > 0;
       if l_superceded_flag then
       -- send superceding notifications
       send_notifications(l_supercede_reqid_str,
                          t_template_id(k),
                          l_S_and_T_reqid,
                          p_batch_name ,
                          p_source_type,
                          p_source_code,
                          p_time_period_id);
        l_superceded_flag := false;
      end if;
    end if;  -- supercede persons count > 0
    l_supercede_reqid_str := null;
    delete psp_supercede_persons_gt;
   else
    l_supercede_reqid_str := null;
    delete psp_supercede_persons_gt;
   end if;   --- only if s_and_t processes emps in er
   else   ---  more than on reqid for Template_id
       insert into psp_supercede_persons_gt (person_id) values ( -t_request_id(k));
       if l_supercede_reqid_str is null then
          l_supercede_reqid_str := t_request_id(k);
       else
          l_supercede_reqid_str := l_supercede_reqid_str ||', '|| t_request_id(k);
       end if;
   end if; -- new template
  end loop;
  delete psp_supercede_persons_gt;
  t_person_table    := t_num_15_type(null);
  t_efforts_table   := t_num_15_type(null);
  t_sum_line_id     := t_num_15_type(null);
  t_person_table.delete;
  t_efforts_table.delete;
  t_sum_line_id.delete ;
  t_tolerance_erid.delete;
  t_request_id.delete;
  t_template_id.delete;
  t_tolerance_sline.delete;
  hr_utility.trace( 'SandT_Supercede--> EXITING');
 EXCEPTION
  when others then
     hr_utility.trace( 'SandT_Supercede--> when others in supercede_er'||sqlerrm) ;
     fnd_msg_pub.add_exc_msg('PSP_SUM_TRANS', 'SUPERCEDE_ER');
     p_return_status := fnd_api.g_ret_sts_unexp_error;
 END supercede_er;

END PSP_SUM_TRANS;

/

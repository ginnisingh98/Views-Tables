--------------------------------------------------------
--  DDL for Package Body PSP_SUM_ADJ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSP_SUM_ADJ" as
/* $Header: PSPADSTB.pls 120.11.12010000.5 2010/04/01 06:15:02 amakrish ship $ */
    g_gms_avail      varchar2(1) := 'N';
    g_fatal	     number;
    g_gms_batch_name varchar2(10); /* bug 1662816 */
    g_run_type           varchar2(1);  --- restart = R, normal = N, Replaces p_run_type -2444657

-- Introduced the following for bug 2259310
    g_enable_enc_summ_gl	VARCHAR2(1) DEFAULT NVL(fnd_profile.value('PSP_ENABLE_ENC_SUMM_GL'), 'N');

--Introduced for Bug no 2478000 Qubec fixes
--  g_currency_code VARCHAR2(15);-- for Bug no 2478000 by tbalacha	Commented for bug fix 2916848

	g_dff_grouping_option	CHAR(1);			-- Introduced for bug fix 2908859


 -- Introduced the following for bug 6902514   -- change
  g_create_stat_batch_in_gms  VARCHAR(1);
  g_skip_flag_gms	      varchar(1);


 -- removed run_type parameter  .. for 2444657.
 PROCEDURE sum_transfer_adj(errbuf	      OUT NOCOPY VARCHAR2,
                            retcode	      OUT NOCOPY VARCHAR2,
                            p_adj_sum_batch_name      IN VARCHAR2,
			    p_business_group_id IN NUMBER,
			    p_set_of_books_id   IN NUMBER) IS

    l_return_status	VARCHAR2(10);
    l_msg_count		NUMBER;
    l_msg_data		VARCHAR2(2000);


    /* LD Added for bug 6902514   -- change
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
       AND	NVL(business_group_id, p_business_group_id) = p_business_group_id;



 BEGIN

   g_error_api_path := '';
   fnd_msg_pub.initialize;
   psp_general.TRANSACTION_CHANGE_PURGEBLE;

--  g_currency_code := psp_general.get_currency_code(p_business_group_id); -- Added for Bug 2478000 commented for bug fix 2916848

	g_dff_grouping_option := psp_general.get_act_dff_grouping_option(p_business_group_id);	-- Introduced for bug fix 2908859

   /*Added the following cursor open-fetch-close for Bug 6902514*/
    open create_stat_batch_in_gms_cur;
    fetch create_stat_batch_in_gms_cur into g_create_stat_batch_in_gms;
    close create_stat_batch_in_gms_cur;


   mark_batch_begin(p_adj_sum_batch_name,
		    p_business_group_id,
		    p_set_of_books_id,
                    l_return_status);

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    -- Bug:  1994421.Commented the retcode and return statement as part of Zero work days enhancement.
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      --retcode := 2;
      --return;
    END IF;

      psp_message_s.print_error(p_mode => FND_FILE.LOG,
				p_print_header => FND_API.G_FALSE);

   fnd_msg_pub.initialize;

    create_gms_sum_lines(p_adj_sum_batch_name,
    			 p_business_group_id,
    			 p_set_of_books_id,
                         l_return_status);

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- call the user extension to populate attribute1 through attribute30
    IF FND_PROFILE.VALUE('PSP_ST_EXTENSION_ENABLE') = 'Y' THEN
      --- 2968684: added params and exception handler to proc.
          psp_st_ext.summary_ext_adjustment(p_adj_sum_batch_name,
                                            p_business_group_id ,
                                            p_set_of_books_id  );
    END IF;

    if g_run_type = 'R' then
    check_interface_status('GMS', p_adj_sum_batch_name);
    end if;

    -- initiate the ogm summarization and transfer
    if (g_gms_avail = 'Y' OR g_run_type = 'R') then
    transfer_to_gms_interface(p_adj_sum_batch_name,
			      p_business_group_id,
			      p_set_of_books_id,
                              l_return_status);

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      check_interface_status('GMS', p_adj_sum_batch_name);
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

-- Check the target system status and do the tieback
    gms_tie_back(p_adj_sum_batch_name,
		 p_business_group_id,
		 p_set_of_books_id,
                 l_return_status);

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    end if; ---- end if for g_gms_avail = 'Y'
    -- initiate the gl summarization and transfer
    create_gl_sum_lines(p_adj_sum_batch_name,
			p_business_group_id,
			p_set_of_books_id,
                        l_return_status);
    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- call the user extension to populate attribute1 through attribute30
    IF FND_PROFILE.VALUE('PSP_ST_EXTENSION_ENABLE') = 'Y' THEN
      --- 2968684: added params and exception handler to proc.
          psp_st_ext.summary_ext_adjustment(p_adj_sum_batch_name,
                                            p_business_group_id ,
                                            p_set_of_books_id  );
    END IF;

    if g_run_type = 'R' then
    check_interface_status('GL', p_adj_sum_batch_name);
    end if;

    transfer_to_gl_interface(p_adj_sum_batch_name,
			     p_business_group_id,
			     p_set_of_books_id,
                             l_return_status);

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS
    THEN
      check_interface_status('GL', p_adj_sum_batch_name);
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

--   dbms_output.put_line('Going to gl_tie_back');

    gl_tie_back(p_adj_sum_batch_name,
		p_business_group_id,
		p_set_of_books_id,
		l_return_status);

      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      end if;

    mark_batch_end(p_adj_sum_batch_name,
		   p_business_group_id,
		   p_set_of_books_id,
                   l_return_status);

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

      if fnd_msg_pub.Count_Msg > 0 then
        psp_message_s.print_error(p_mode => FND_FILE.LOG,
				p_print_header => FND_API.G_FALSE);
      else
        PSP_MESSAGE_S.Print_success;
      end if;

    retcode := FND_API.G_RET_STS_SUCCESS;
 EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
-- Bug 1776606 :  Introduced Rollback ,
      rollback;

      psp_message_s.print_error(p_mode => FND_FILE.LOG,
				p_print_header => FND_API.G_TRUE);
      retcode := 2;
    WHEN OTHERS THEN
--Bug 1776606 : Introduced Rollback
      rollback;
      psp_message_s.print_error(p_mode => FND_FILE.LOG,
				p_print_header => FND_API.G_TRUE);
      retcode := 2;
 END;

-------------------- MARK BATCH BEGIN --------------------------------------------

 PROCEDURE mark_batch_begin(p_adj_sum_batch_name      IN VARCHAR2,
			    p_business_group_id  IN  NUMBER,
			    p_set_of_books_id	 IN	NUMBER,
                            p_return_status  	OUT NOCOPY VARCHAR2) IS
   --- replaced p_run_type with g_run_type for 244657
   CURSOR pc_batch_cur IS
   SELECT distinct ppc.batch_name
     FROM psp_payroll_controls ppc,
          psp_adjustment_control_table pact
    WHERE ppc.status_code = decode(g_run_type, 'N', 'N', 'R', 'I')
      AND ppc.source_type = 'A'
      AND ppc.batch_name = pact.adjustment_batch_name
      AND (g_run_type = 'N' OR (g_run_type = 'R' and
           ppc.adj_sum_batch_name = p_adj_sum_batch_name))
      AND (dist_dr_amount is not null or dist_cr_amount is not null)
      AND ppc.business_group_id = p_business_group_id
      AND ppc.set_of_books_id = p_set_of_books_id
      AND (pact.approver_id is not null and pact.approver_id <> -999);

   pc_batch_rec		pc_batch_cur%ROWTYPE;

   --- removed the pc_recover_cur  ... for  2444657

   CURSOR payroll_control_cur(p_batch_name IN VARCHAR2) IS
   SELECT payroll_control_id,
          source_type,
          payroll_source_code,
          time_period_id,
          batch_name,
	  gms_phase
   FROM   psp_payroll_controls
   WHERE  source_type = 'A'
   AND    ((adj_sum_batch_name is null) OR
		(adj_sum_batch_name is not null and run_id is not null))
   AND    (dist_dr_amount IS NOT NULL OR dist_cr_amount IS NOT NULL)
   AND    batch_name = p_batch_name
   AND    business_group_id = p_business_group_id
   AND    set_of_books_id = p_set_of_books_id
   AND    status_code in ( 'N','I');   --- added 'I' for 2444657

   --- added cursor for 2444657
   CURSOR derive_run_mode IS
   select decode(count(*), 0, 'N', 'R')
   from psp_payroll_controls
   where source_type = 'A'
     and adj_sum_batch_name = p_adj_sum_batch_name
     and status_code = 'I';

   CURSOR	batch_name_exist_cur IS
   SELECT	count(*)
   FROM		psp_payroll_controls
   WHERE	adj_sum_batch_name = p_adj_sum_batch_name
   AND          source_type = 'A'     -- Bug 2133056
   AND		g_run_type <> 'R';

   payroll_control_rec		payroll_control_cur%ROWTYPE;
   l_batch_name_exists 		number;
   l_batch_cnt			NUMBER := 0;
   l_error			VARCHAR2(80);
   l_return_status		VARCHAR2(80);
   l_batch_details_failed	BOOLEAN;

 BEGIN
-- Replaced the following lines of code for bug fix 1769610 and included new set of codes

   SELECT	psp_st_run_id_s.nextval
   INTO		g_run_id
   FROM		DUAL;


   --- 2444657: derive run-mode
   open derive_run_mode;
   fetch derive_run_mode into g_run_type;
   close derive_run_mode;

--dbms_output.put_line('Getting the existence of the batch name');
-- Replaced the following lines and included new set of lines for bug fix 1765678

   OPEN batch_name_exist_cur;
   FETCH batch_name_exist_cur INTO l_batch_name_exists;
   IF (batch_name_exist_cur%NOTFOUND) THEN
      CLOSE batch_name_exist_cur;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   CLOSE batch_name_exist_cur;

  if l_batch_name_exists > 0 then
         fnd_message.set_name('PSP','PSP_GB_NAME_EXISTS');
	 fnd_message.set_token('GB_NAME', p_adj_sum_batch_name);
         fnd_msg_pub.add;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;

open pc_batch_cur;
loop
fetch pc_batch_cur into pc_batch_rec;
  if pc_batch_cur%ROWCOUNT = 0 then
  	fnd_message.set_name('PSP', 'PSP_NO_BATCHES_EXIST');
  	fnd_msg_pub.add;
     close pc_batch_cur;
     exit;
  elsif pc_batch_cur%NOTFOUND then
     close pc_batch_cur;
     exit;
  end if;

 l_batch_details_failed := FALSE;
 l_batch_cnt := l_batch_cnt + 1;
 fnd_message.set_name('PSP','PSP_GB_NAME');
 fnd_message.set_token('GB_NAME',p_adj_sum_batch_name);
 get_the_batch_details(pc_batch_rec.batch_name, l_return_status);
 fnd_msg_pub.add;

   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     l_batch_details_failed := TRUE;
   ELSE
     l_batch_details_failed := FALSE;
   END IF; -- If Successful

 --- removed call to obsoleted cursor from here ,,,2444657
  OPEN payroll_control_cur(pc_batch_rec.batch_name);
  LOOP
   FETCH payroll_control_cur INTO payroll_control_rec;
   IF payroll_control_cur%NOTFOUND THEN
     CLOSE payroll_control_cur;
     EXIT;
   END IF;

   if (l_batch_details_failed) then
     cleanup_batch_details(payroll_control_rec.payroll_control_id,null);
     /* Included as part of Bug fix #1776606 : Cleanup is  at small batch level,
	hence there is no need to call in loop*/
      CLOSE payroll_control_cur;
      EXIT;
   else
     if g_run_type = 'N' then
       UPDATE psp_payroll_controls
       SET status_code = 'I',
         adj_sum_batch_name = p_adj_sum_batch_name,
         run_id = g_run_id
       WHERE payroll_control_id = payroll_control_rec.payroll_control_id;
     else
       UPDATE psp_payroll_controls
       SET run_id = g_run_id
       WHERE payroll_control_id = payroll_control_rec.payroll_control_id;
     end if;
   end if;

  END LOOP;
end loop;
--commit;
    p_return_status := fnd_api.g_ret_sts_success;
	--Included as part of Bug fix #1776606
    EXCEPTION
	WHEN OTHERS THEN
	   fnd_msg_pub.add_exc_msg('PSP_SUM_ADJ','MARK_BATCH_BEGIN');
	   raise;
 END;
-------------------- MARK BATCH END ---------------------------------------------

 PROCEDURE mark_batch_end(p_adj_sum_batch_name      IN VARCHAR2,
			  p_business_group_id	IN	NUMBER,
			  p_set_of_books_id	IN	NUMBER,
                          p_return_status  OUT NOCOPY VARCHAR2) IS

   CURSOR pc_batch_cur IS
   SELECT distinct batch_name
     FROM psp_payroll_controls
    WHERE source_type = 'A'
      AND adj_sum_batch_name = p_adj_sum_batch_name
      AND (dist_dr_amount is not null or dist_cr_amount is not null)
--      AND (gl_phase = 'GL_Tie_Back' OR gms_phase = 'GMS_Tie_Back') : Bug 1776606 : Commented out
-- Bug 1776606 : Added the next two conditions..Phase =Null or GMS_TIE_BACK /GL_TIE_BACK
      AND (gms_phase is null or gms_phase = 'GMS_Tie_Back')
      AND (gl_phase is null or gl_phase = 'GL_Tie_Back')
      AND status_code = 'I'
      AND business_group_id = p_business_group_id
      AND set_of_books_id = p_set_of_books_id
      AND run_id = nvl(g_run_id, run_id);

   pc_batch_rec		pc_batch_cur%ROWTYPE;

   CURSOR payroll_control_cur(p_batch_name IN VARCHAR2) IS
   SELECT payroll_control_id,
          source_type,
          payroll_source_code,
          time_period_id,
          batch_name,
	  gl_phase,
	  gms_phase
   FROM   psp_payroll_controls
   WHERE  source_type = 'A'
   AND    batch_name = p_batch_name
   AND    (dist_dr_amount IS NOT NULL OR dist_cr_amount IS NOT NULL)
   AND    status_code = 'I'
   AND    run_id = g_run_id;


--Bug 1776606 : Introduced the two cursors
   CURSOR sum_lines_cur(P_PAYROLL_CONTROL_ID  IN  NUMBER) IS
   SELECT count(*)
   FROM   psp_summary_lines
   WHERE  payroll_control_id = p_payroll_control_id
   AND    status_code <> 'A';

   CURSOR adj_lines_cur(P_PAYROLL_CONTROL_ID IN NUMBER) IS
   SELECT count(*)
     FROM psp_adjustment_lines
    WHERE payroll_control_id = p_payroll_control_id
      AND gl_code_combination_id is not null
      AND status_code <> 'A';


   payroll_control_rec		payroll_control_cur%ROWTYPE;
   l_errbuf			VARCHAR2(2000);

--Bug 1776606 : Introducing the variables
  l_sum_count			NUMBER := 0;
  l_adj_count			NUMBER := 0;
  retcode  varchar2(500);
  l_return_status	VARCHAR2(10);

/* Start of Changes to check migration to OAF Effort Reporting before Supercedence  */

   l_migration_status BOOLEAN:= psp_general.is_effort_report_migrated;


/* End of Cahnges to check migration to OAF Effort Reporting before Supercedence  */

 BEGIN

  --- call to supercede Effort reports



/* Start of Changes to check migration to OAF Effort Reporting before Supercedence  */

IF l_migration_status  THEN


  PSP_SUM_TRANS.SUPERCEDE_ER(g_run_id,
                             l_errbuf,
                             retcode,
                             'A'   ,
                             'Adjustments',
                             null,
                             p_adj_sum_batch_name,
                             l_return_status);
  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;


 END IF;

/* End Changes to check migration to OAF Effort Reporting before Supercedence  */

  /* Bug 2133056: Moved this stmt from Tie Back process */

   DELETE FROM pa_transaction_interface_all
--   WHERE batch_name = g_gms_batch_name
   WHERE batch_name IN (SELECT GMS_BATCH_NAME
                        FROM psp_summary_lines
                        WHERE  PAYROLL_CONTROL_ID IN(SELECT payroll_control_id
                                                    FROM    psp_payroll_controls
                                                    WHERE   adj_sum_batch_name =p_adj_sum_batch_name))
    ---AND transaction_status_code = 'A'   delete 'R' also, for  2445196
    AND transaction_source in ('OLD', 'GOLD');

  -- introduced following stmnt for  2445196
   delete from gms_transaction_interface_all
--   where batch_name = g_gms_batch_name
   WHERE batch_name IN (SELECT GMS_BATCH_NAME
                        FROM psp_summary_lines
                        WHERE  PAYROLL_CONTROL_ID IN(SELECT payroll_control_id
                                                    FROM    psp_payroll_controls
                                                    WHERE   adj_sum_batch_name =p_adj_sum_batch_name))
     and transaction_source = 'GOLD';

  OPEN pc_batch_cur;
  LOOP
  FETCH pc_batch_cur into pc_batch_rec;
  if pc_batch_cur%NOTFOUND then
     close pc_batch_cur;
     exit;
  end if;


  OPEN payroll_control_cur(pc_batch_rec.batch_name);
  LOOP
   FETCH payroll_control_cur INTO payroll_control_rec;
   IF payroll_control_cur%NOTFOUND THEN
     CLOSE payroll_control_cur;
     EXIT;
   END IF;

-- Bug 1776606 : Intoduced the following code
  l_sum_count  := 0;
  l_adj_count := 0;
  OPEN sum_lines_cur(payroll_control_rec.payroll_control_id);
  FETCH sum_lines_cur INTO l_sum_count;
  CLOSE sum_lines_cur;

  OPEN adj_lines_cur(payroll_control_rec.payroll_control_id);
  FETCH adj_lines_cur INTO l_adj_count;
  CLOSE adj_lines_cur;

  IF (l_sum_count =0) and (l_adj_count =0) THEN
   UPDATE psp_payroll_controls
   SET status_code = 'P'
   WHERE payroll_control_id = payroll_control_rec.payroll_control_id;
  END IF;

  END LOOP;
  END LOOP;

  COMMIT;

 EXCEPTION
 WHEN OTHERS THEN
-- Bug 1776606 : Modifying the message to be displayed
 --  FND_MSG_PUB.ADD_EXC_MSG('PSP_SUM_ADJ', SQLERRM);
    fnd_msg_pub.add_exc_msg('PSP_SUM_ADJ','MARK_BATCH_END');
   raise;
 END;


-------------------- CREATE GL SUM LINES -----------------------------------------------

 PROCEDURE create_gl_sum_lines(p_adj_sum_batch_name      IN VARCHAR2,
			       p_business_group_id	 IN NUMBER,
			       p_set_of_books_id	 IN NUMBER,
                               p_return_status  OUT NOCOPY VARCHAR2) IS

   CURSOR pc_batch_cur IS
   SELECT distinct batch_name
     FROM psp_payroll_controls
    WHERE source_type = 'A'
      AND status_code = 'I'
      AND run_id = nvl(g_run_id, run_id)
      AND gl_phase is null
      AND adj_sum_batch_name = p_adj_sum_batch_name
      AND business_group_id = p_business_group_id
      AND set_of_books_id = p_set_of_books_id
      AND (dist_dr_amount is not null or dist_cr_amount is not null);

   pc_batch_rec		pc_batch_cur%ROWTYPE;

   CURSOR payroll_control_cur(p_batch_name IN VARCHAR2) IS
   SELECT payroll_control_id,
          source_type,
          payroll_source_code,
          time_period_id,
          batch_name,
	  gl_posting_override_date
   FROM   psp_payroll_controls
   WHERE  batch_name = p_batch_name
   AND    (dist_dr_amount IS NOT NULL OR dist_cr_amount IS NOT NULL)
   AND    source_type = 'A'
   AND    status_code = 'I'
   AND    run_id = nvl(g_run_id, run_id);

  CURSOR gl_sum_lines_cursor(P_PAYROLL_CONTROL_ID  IN  NUMBER)  IS
   SELECT pal.person_id,
          pal.assignment_id,
          pal.gl_code_combination_id gl_ccid,
          pal.dr_cr_flag,
          pal.effective_date,
          psl.accounting_date,   -- removed nvl on a/c date for 4734810
          psl.exchange_rate_type,
          pal.distribution_amount,
          pal.adjustment_line_id distribution_line_id,
          'A' tab_flag,
	DECODE(g_dff_grouping_option, 'Y', pal.attribute_category, NULL) attribute_category,	-- Introduced DFF columns for bug fix 2908859
	DECODE(g_dff_grouping_option, 'Y', pal.attribute1, NULL) attribute1,
	DECODE(g_dff_grouping_option, 'Y', pal.attribute2, NULL) attribute2,
	DECODE(g_dff_grouping_option, 'Y', pal.attribute3, NULL) attribute3,
	DECODE(g_dff_grouping_option, 'Y', pal.attribute4, NULL) attribute4,
	DECODE(g_dff_grouping_option, 'Y', pal.attribute5, NULL) attribute5,
	DECODE(g_dff_grouping_option, 'Y', pal.attribute6, NULL) attribute6,
	DECODE(g_dff_grouping_option, 'Y', pal.attribute7, NULL) attribute7,
	DECODE(g_dff_grouping_option, 'Y', pal.attribute8, NULL) attribute8,
	DECODE(g_dff_grouping_option, 'Y', pal.attribute9, NULL) attribute9,
	DECODE(g_dff_grouping_option, 'Y', pal.attribute10, NULL) attribute10
   FROM   psp_adjustment_lines       pal,
          psp_distribution_lines_history pdlh,
          psp_summary_lines psl
   WHERE  pal.status_code = 'N'
   AND    pal.gl_code_combination_id is not null
   AND    pal.payroll_control_id = p_payroll_control_id
   AND    pal.orig_source_type = 'D'
   AND    pal.orig_line_id = pdlh.distribution_line_id
   AND    pdlh.summary_line_id = psl.summary_line_id
   UNION    --- added union to get accounting dates -- 3108109
   SELECT pal.person_id,
          pal.assignment_id,
          pal.gl_code_combination_id gl_ccid,
          pal.dr_cr_flag,
          pal.effective_date,
          psl.accounting_date,  ---3108109
          psl.exchange_rate_type,
          pal.distribution_amount,
          pal.adjustment_line_id distribution_line_id,
          'A' tab_flag,
	DECODE(g_dff_grouping_option, 'Y', pal.attribute_category, NULL) attribute_category,	-- Introduced DFF columns for bug fix 2908859
	DECODE(g_dff_grouping_option, 'Y', pal.attribute1, NULL) attribute1,
	DECODE(g_dff_grouping_option, 'Y', pal.attribute2, NULL) attribute2,
	DECODE(g_dff_grouping_option, 'Y', pal.attribute3, NULL) attribute3,
	DECODE(g_dff_grouping_option, 'Y', pal.attribute4, NULL) attribute4,
	DECODE(g_dff_grouping_option, 'Y', pal.attribute5, NULL) attribute5,
	DECODE(g_dff_grouping_option, 'Y', pal.attribute6, NULL) attribute6,
	DECODE(g_dff_grouping_option, 'Y', pal.attribute7, NULL) attribute7,
	DECODE(g_dff_grouping_option, 'Y', pal.attribute8, NULL) attribute8,
	DECODE(g_dff_grouping_option, 'Y', pal.attribute9, NULL) attribute9,
	DECODE(g_dff_grouping_option, 'Y', pal.attribute10, NULL) attribute10
   FROM   psp_adjustment_lines       pal,
          psp_adjustment_lines_history palh,
          psp_summary_lines psl
   WHERE  pal.status_code = 'N'
   AND    pal.gl_code_combination_id is not null
   AND    pal.payroll_control_id = p_payroll_control_id
   AND    pal.orig_source_type = 'A'
   AND    pal.orig_line_id = palh.adjustment_line_id
   AND    palh.summary_line_id = psl.summary_line_id
   UNION
   SELECT pal.person_id,
          pal.assignment_id,
          pal.gl_code_combination_id gl_ccid,
          pal.dr_cr_flag,
          pal.effective_date,
          psl.accounting_date, ---3108109
          psl.exchange_rate_type,
          pal.distribution_amount,
          pal.adjustment_line_id distribution_line_id,
          'A' tab_flag,
	DECODE(g_dff_grouping_option, 'Y', pal.attribute_category, NULL) attribute_category,	-- Introduced DFF columns for bug fix 2908859
	DECODE(g_dff_grouping_option, 'Y', pal.attribute1, NULL) attribute1,
	DECODE(g_dff_grouping_option, 'Y', pal.attribute2, NULL) attribute2,
	DECODE(g_dff_grouping_option, 'Y', pal.attribute3, NULL) attribute3,
	DECODE(g_dff_grouping_option, 'Y', pal.attribute4, NULL) attribute4,
	DECODE(g_dff_grouping_option, 'Y', pal.attribute5, NULL) attribute5,
	DECODE(g_dff_grouping_option, 'Y', pal.attribute6, NULL) attribute6,
	DECODE(g_dff_grouping_option, 'Y', pal.attribute7, NULL) attribute7,
	DECODE(g_dff_grouping_option, 'Y', pal.attribute8, NULL) attribute8,
	DECODE(g_dff_grouping_option, 'Y', pal.attribute9, NULL) attribute9,
	DECODE(g_dff_grouping_option, 'Y', pal.attribute10, NULL) attribute10
   FROM   psp_adjustment_lines       pal,
          psp_pre_gen_dist_lines_history pglh,
          psp_summary_lines psl
   WHERE  pal.status_code = 'N'
   AND    pal.gl_code_combination_id is not null
   AND    pal.payroll_control_id = p_payroll_control_id
   AND    pal.orig_source_type = 'P'
   AND    pal.orig_line_id = pglh.pre_gen_dist_line_id
   AND    pglh.summary_line_id = psl.summary_line_id
   ORDER BY 1,2,3,4,6,7,11,12,13,14,15,16,17,18,19,20,21,5;
      --- added 2 columns for 3108109
    --- changed the order by clause for 6007017

--   l_sob_id			NUMBER(15) := FND_PROFILE.VALUE('PSP_SET_OF_BOOKS'); --Passed as a parameter.
   l_sob_id			NUMBER(15) := p_set_of_books_id;
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
   TYPE dist_id IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
   dist_line_id			dist_id;
   l_dist_line_id		NUMBER;
   i				BINARY_INTEGER := 0;
   j				NUMBER;
   l_return_status		VARCHAR2(10);
   payroll_control_rec		payroll_control_cur%ROWTYPE;
	l_msg_id	number(9);
   l_accounting_date            date; --- added for 3108109
   l_exchange_rate_type         varchar2(30);
	l_attribute_category	VARCHAR2(30);		-- Introduced DFF variables for bug fix 2908859
	l_attribute1		VARCHAR2(150);
	l_attribute2		VARCHAR2(150);
	l_attribute3		VARCHAR2(150);
	l_attribute4		VARCHAR2(150);
	l_attribute5		VARCHAR2(150);
	l_attribute6		VARCHAR2(150);
	l_attribute7		VARCHAR2(150);
	l_attribute8		VARCHAR2(150);
	l_attribute9		VARCHAR2(150);
	l_attribute10		VARCHAR2(150);
 BEGIN

  OPEN pc_batch_cur;
  LOOP
  FETCH pc_batch_cur into pc_batch_rec;
   IF pc_batch_cur%NOTFOUND THEN
     CLOSE pc_batch_cur;
     EXIT;
   END IF;

  OPEN payroll_control_cur(pc_batch_rec.batch_name);
  LOOP
   FETCH payroll_control_cur INTO payroll_control_rec;
   IF payroll_control_cur%NOTFOUND THEN
     CLOSE payroll_control_cur;
     EXIT;
   END IF;
/*  move this procedure below for 3108109
   -- create balancing transactions for GL
   gl_balance_transaction(payroll_control_rec.source_type,
                          payroll_control_rec.payroll_control_id,
			  p_business_group_id,
			  p_set_of_books_id,
                          l_return_status);

   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
*/

   OPEN gl_sum_lines_cursor(payroll_control_rec.payroll_control_id);
   l_rec_count := 0;
   l_summary_amount := 0;
   i := 0;
   LOOP
     FETCH gl_sum_lines_cursor INTO gl_sum_lines_rec;
     l_rec_count := l_rec_count + 1;
     IF gl_sum_lines_cursor%NOTFOUND THEN
	if (l_rec_count > 1) then
   	update psp_payroll_controls
      	   set gl_phase = 'Summarize_GL_Lines'
    	where payroll_control_id = payroll_control_rec.payroll_control_id;
	end if;
       CLOSE gl_sum_lines_cursor;
       EXIT;
     END IF;
     --
     IF l_rec_count = 1 THEN
       l_person_id		:= gl_sum_lines_rec.person_id;
       l_assignment_id		:= gl_sum_lines_rec.assignment_id;
       l_gl_ccid		:= gl_sum_lines_rec.gl_ccid;
       l_dr_cr_flag		:= gl_sum_lines_rec.dr_cr_flag;
       l_effective_date		:= nvl(payroll_control_rec.gl_posting_override_date,
 					gl_sum_lines_rec.effective_date);
       l_accounting_date        := gl_sum_lines_rec.accounting_date;  ---  added for 3108109
       l_exchange_rate_type     := gl_sum_lines_rec.exchange_rate_type;
	l_attribute_category	:= gl_sum_lines_rec.attribute_category;		-- Introduced DFF variables for bug fix 2908859
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
	(NVL(l_attribute_category, 'NULL') <> NVL(gl_sum_lines_rec.attribute_category, 'NULL')) OR	-- Introduced DFF check for bug fix 2908859
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
        --- added accounting_date condn for 3108109, 4734810
        nvl(l_accounting_date, fnd_date.canonical_to_date('1800/01/31')) <>
           nvl( gl_sum_lines_rec.accounting_date, fnd_date.canonical_to_date('1800/01/31')) OR
        nvl(l_exchange_rate_type,'-999') <>
            nvl(gl_sum_lines_rec.exchange_rate_type,'-999') THEN

        insert_into_summary_lines(
            	l_summary_line_id,
		l_person_id,
		l_assignment_id,
            	payroll_control_rec.time_period_id,
 		l_effective_date,
                l_accounting_date,    -- added for 3108109
                l_exchange_rate_type,
            	payroll_control_rec.source_type,
 		payroll_control_rec.payroll_source_code,
            	l_sob_id,
 		l_gl_ccid,
 		NULL,
 		NULL,
 		NULL,
 		NULL,
 		NULL,
 		l_summary_amount,
 		l_dr_cr_flag,
 		'N',
            	payroll_control_rec.batch_name,
            	payroll_control_rec.payroll_control_id,
		p_business_group_id,
		l_attribute_category,				-- Introduced DFF parameters for bug fix 2908859
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

	IF gl_sum_lines_rec.tab_flag = 'A' THEN
           UPDATE psp_adjustment_lines
              SET summary_line_id = l_summary_line_id
	    WHERE adjustment_line_id = l_dist_line_id;
         END IF;

       END LOOP;

       -- initialise the summary amount and dist_line_id
       l_summary_amount := 0;
       dist_line_id.delete;
       i := 0;
     END IF;

     l_person_id		:= gl_sum_lines_rec.person_id;
     l_assignment_id		:= gl_sum_lines_rec.assignment_id;
     l_gl_ccid			:= gl_sum_lines_rec.gl_ccid;
     l_dr_cr_flag		:= gl_sum_lines_rec.dr_cr_flag;
     l_effective_date		:= nvl(payroll_control_rec.gl_posting_override_date,
 					gl_sum_lines_rec.effective_date);
     l_accounting_date           := gl_sum_lines_rec.accounting_date;   --- added for 3108109
     l_exchange_rate_type        := gl_sum_lines_rec.exchange_rate_type;
	l_attribute_category	:= gl_sum_lines_rec.attribute_category;		-- Introduced DFF variables for bug fix 2908859
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
                l_accounting_date, --- added for 3108109
                l_exchange_rate_type,
            	payroll_control_rec.source_type,
 		payroll_control_rec.payroll_source_code,
            	l_sob_id,
 		l_gl_ccid,
 		NULL,
 		NULL,
 		NULL,
 		NULL,
 		NULL,
 		l_summary_amount,
 		l_dr_cr_flag,
 		'N',
            payroll_control_rec.batch_name,
            payroll_control_rec.payroll_control_id,
	    p_business_group_id,
		l_attribute_category,				-- Introduced DFF parameters for bug fix 2908859
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

       IF gl_sum_lines_rec.tab_flag = 'A' THEN
         UPDATE psp_adjustment_lines
         SET summary_line_id = l_summary_line_id,
             status_code = 'N'
         WHERE adjustment_line_id = l_dist_line_id;
       END IF;
     END LOOP;
     -- moved this code from above for 3108109
     if dist_line_id.count > 0 then
        gl_balance_transaction(payroll_control_rec.source_type,
                          payroll_control_rec.payroll_control_id,
                          p_business_group_id,
                          p_set_of_books_id,
                          l_return_status);

            IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
     end if;
     dist_line_id.delete;
   END IF;
  END LOOP; -- end loop for payroll_control_cur
  END LOOP; -- end loop for pc_batch_cur

  --
  p_return_status := fnd_api.g_ret_sts_success;

 EXCEPTION

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     g_error_api_path := 'CREATE_GL_SUM_LINES:'||g_error_api_path;
     fnd_msg_pub.add_exc_msg('PSP_SUM_ADJ','CREATE_GL_SUM_LINES');
     p_return_status := fnd_api.g_ret_sts_unexp_error;
   WHEN OTHERS THEN
     g_error_api_path := 'CREATE_GL_SUM_LINES:'||g_error_api_path;
     fnd_msg_pub.add_exc_msg('PSP_SUM_ADJ','CREATE_GL_SUM_LINES');
     p_return_status := fnd_api.g_ret_sts_unexp_error;

 END;


---------------------- I N S E R T   S T A T E M E N T  ------------------------------------
 PROCEDURE insert_into_summary_lines(
		P_SUMMARY_LINE_ID		OUT NOCOPY	NUMBER,
		P_PERSON_ID			IN	NUMBER,
		P_ASSIGNMENT_ID			IN	NUMBER,
		P_TIME_PERIOD_ID		IN	NUMBER,
 		P_EFFECTIVE_DATE		IN	DATE,
                P_ACCOUNTING_DATE               IN      DATE, ---added-> 3108109
                P_EXCHANGE_RATE_TYPE            IN      VARCHAR2,
            	P_SOURCE_TYPE			IN	VARCHAR2,
 		P_SOURCE_CODE			IN	VARCHAR2,
		P_SET_OF_BOOKS_ID		IN	NUMBER,
 		P_GL_CODE_COMBINATION_ID	IN	NUMBER,
 		P_PROJECT_ID			IN	NUMBER,
 		P_EXPENDITURE_ORGANIZATION_ID	IN	NUMBER,
 		P_EXPENDITURE_TYPE		IN	VARCHAR2,
 		P_TASK_ID			IN	NUMBER,
 		P_AWARD_ID			IN	NUMBER,
 		P_SUMMARY_AMOUNT		IN	NUMBER,
 		P_DR_CR_FLAG			IN	VARCHAR2,
 		P_STATUS_CODE			IN	VARCHAR2,
            	P_INTERFACE_BATCH_NAME		IN	VARCHAR2,
		P_PAYROLL_CONTROL_ID		IN	NUMBER,
		P_BUSINESS_GROUP_ID		IN	NUMBER,
		p_attribute_category		IN	VARCHAR2,		-- Introduced DFF parameters for bug fix 2908859
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
            	P_RETURN_STATUS			OUT NOCOPY   	VARCHAR2,
		P_ORG_ID			IN  NUMBER DEFAULT NULL     -- R12 MOAc uptake
		) IS
	l_msg_id 	number(9);
	l_gms_posting_effective_date	DATE;	/* Bug: 1994421 Variable Initialized. */
 BEGIN

 -- Bug 1994421
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
                ACCOUNTING_DATE,
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
		ACTUAL_SUMMARY_AMOUNT,    --For Bug 2496661
		attribute_category,			-- Introduced DFF columns for bug fix 2908859
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
		org_id              -- R12 MOAc uptake
		)
    VALUES(
            	P_SUMMARY_LINE_ID,
		P_PERSON_ID,
		P_ASSIGNMENT_ID,
		P_TIME_PERIOD_ID,
 		P_EFFECTIVE_DATE,
                P_ACCOUNTING_DATE,  --- 3108109
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
		p_attribute_category,			-- Introduced DFF columns for bug fix 2908859
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
		P_ORG_ID              -- R12 MOAc uptake
		);
    --
    p_return_status := fnd_api.g_ret_sts_success;
 EXCEPTION
   WHEN OTHERS THEN
      g_error_api_path := 'INSERT_INTO_SUMMARY_LINES:'||g_error_api_path;
      fnd_msg_pub.add_exc_msg('PSP_SUM_ADJ','INSERT_INTO_SUMMARY_LINES');
      p_return_status := fnd_api.g_ret_sts_unexp_error;
 END;

------------------------ GL INTERFACE --------------------------------------------------

 PROCEDURE transfer_to_gl_interface(p_adj_sum_batch_name      IN VARCHAR2,
				    p_business_group_id	      IN NUMBER,
				    p_set_of_books_id	      IN NUMBER,
                                    p_return_status  OUT NOCOPY VARCHAR2) IS

   CURSOR pc_batch_cur IS
   SELECT distinct batch_name
     FROM psp_payroll_controls
    WHERE adj_sum_batch_name = p_adj_sum_batch_name
      AND source_type = 'A'
      AND (dist_dr_amount IS NOT NULL OR dist_cr_amount IS NOT NULL)
      AND status_code = 'I'
      AND gl_phase = 'Summarize_GL_Lines'
      AND business_group_id = p_business_group_id
      AND set_of_books_id = p_set_of_books_id
      AND run_id = nvl(g_run_id, run_id);
 pc_batch_rec	pc_batch_cur%ROWTYPE;

   CURSOR gl_batch_cursor(p_batch_name IN VARCHAR2) IS
   SELECT payroll_control_id,
          source_type,
          payroll_source_code,
          time_period_id,
          batch_name,
--	Introduced for bug fix 2916848
	  currency_code
   FROM   psp_payroll_controls
   WHERE  batch_name = p_batch_name
   AND    source_type = 'A'
   AND    (dist_dr_amount IS NOT NULL OR dist_cr_amount IS NOT NULL)
   AND    status_code = 'I'
   AND    gl_phase = 'Summarize_GL_Lines'
   AND    run_id = g_run_id;


   CURSOR gl_interface_cursor(p_payroll_control_id      IN      NUMBER) IS
   SELECT psl.summary_line_id,
          psl.source_code,
          psl.effective_date,
          psl.accounting_date,  --- added for 3108109
          psl.exchange_rate_type,
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
          psl.attribute30,
          psl.person_id	--Included this column as part of bug fix 1828519
   FROM  psp_summary_lines  psl
   WHERE psl.status_code = 'N'
   AND   psl.gl_code_combination_id IS NOT NULL
   AND   psl.payroll_control_id = p_payroll_control_id;

   gl_batch_rec			gl_batch_cursor%ROWTYPE;
   gl_interface_rec		gl_interface_cursor%ROWTYPE;
--   l_sob_id			NUMBER(15) := FND_PROFILE.VALUE('PSP_SET_OF_BOOKS');
   l_sob_id			NUMBER(15) := p_set_of_books_id;
   l_user_je_source_name	VARCHAR2(25);
   l_user_je_category_name	VARCHAR2(25);
   l_period_name		VARCHAR2(35);
   l_period_end_date		DATE;
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
	l_msg_id	number(9);
--   l_batch_cnt			NUMBER(10); Commented the variable.. Bug 1977939
   l_person_name		VARCHAR2(240); -- Included for bug fix 1828519

-- Included the following cursors here for referring local variables for bug fix 1765678
   CURSOR	time_period_cur IS
   SELECT	period_name, end_date
   FROM		per_time_periods
   WHERE	time_period_id = gl_batch_rec.time_period_id;

/***	Commented this as part of bug fix 2916848
   CURSOR	currency_code_cur IS
   SELECT	currency_code
   FROM		gl_sets_of_books
   WHERE	set_of_books_id = l_sob_id;
	End of bug fix 2916848	***/

--Included the flollowing cursor for bug fix 1828519
   CURSOR	employee_name_cur IS
   SELECT	full_name
   FROM		per_people_f ppf
   WHERE	ppf.person_id = (SELECT	pal.person_id
				FROM	psp_adjustment_lines pal
                                WHERE pal.payroll_control_id = gl_batch_rec.payroll_control_id
                                  AND rownum = 1); --Bug 2133056 removed distinct and replace batch_name with payroll_control_id

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

     -- get the currency_code
-- Replaced the following and included new set of code for bug fix 1765678

   OPEN pc_batch_cur;
   LOOP
   FETCH pc_batch_cur into pc_batch_rec;
   if pc_batch_cur%NOTFOUND then
     close pc_batch_cur;
     exit;
   end if;
     -- get the group_id. Moved the group id out of payroll control id loop. Bug 1977939
     SELECT	gl_interface_control_s.nextval
     INTO	l_group_id
     FROM	DUAL;

     l_rec_count := 0;   -- MOVED this stmt, from inside the payroll control loop id Bug 1977939.
   OPEN gl_batch_cursor(pc_batch_rec.batch_name);
   LOOP
     FETCH gl_batch_cursor INTO gl_batch_rec;
     IF gl_batch_cursor%NOTFOUND THEN
       CLOSE gl_batch_cursor;
       EXIT;
     END IF;


     -- update psp_summary_lines with group_id
     UPDATE psp_summary_lines
     SET group_id = l_group_id
     WHERE status_code = 'N'
     AND   gl_code_combination_id IS NOT NULL
     AND   payroll_control_id = gl_batch_rec.payroll_control_id;

     -- get the period_name
     -- Replaced the earlier 'select stmt.' code with new 'cursor' code for bug fix 1765678

      OPEN time_period_cur;
      FETCH time_period_cur INTO l_period_name, l_period_end_date;
      IF (time_period_cur%NOTFOUND) THEN
         CLOSE time_period_cur;
--	Included the following code for bug fix 1828519
	 OPEN employee_name_cur;
	 FETCH employee_name_cur INTO l_person_name;
	 CLOSE employee_name_cur;
--	End of bug fix 1828519
         l_value := 'Time Period Id = '||to_char(gl_batch_rec.time_period_id);
         l_table := 'PER_TIME_PERIODS';
         fnd_message.set_name('PSP','PSP_TR_VALUE_NOT_FOUND');
         fnd_message.set_token('VALUE',l_value);
         fnd_message.set_token('TABLE',l_table);
         fnd_message.set_token('BATCH_NAME',pc_batch_rec.batch_name); -- Included for bug fix 1828519
         fnd_message.set_token('PERSON_NAME',l_person_name); -- Included for bug fix 1828519
         fnd_msg_pub.add;
--	Commented the following message for bug fix 1828519
--	 fnd_message.set_name('PSP', 'PSP_ADJ_GL_FAILED');
--	 fnd_message.set_token('ERR_NAME', 'TIME PERIOD NOT FOUND');
--	 get_the_batch_details(pc_batch_rec.batch_name, l_return_status);
--         fnd_msg_pub.add;
         cleanup_batch_details(gl_batch_rec.payroll_control_id,null);
--         l_batch_cnt := l_batch_cnt - 1;
         close gl_batch_cursor;
         exit;
       END IF;
       CLOSE time_period_cur;


     l_reference1 := gl_batch_rec.source_type || ':' || gl_batch_rec.payroll_source_code ||
			':' || l_period_name || ':' || gl_batch_rec.batch_name;

     IF gl_batch_rec.source_type = 'A' THEN
       l_reference4 := 'LD ADJUSTMENTS DISTRIBUTION';
     END IF;

     OPEN gl_interface_cursor(gl_batch_rec.payroll_control_id);
     LOOP
       FETCH gl_interface_cursor INTO gl_interface_rec;
       IF gl_interface_cursor%NOTFOUND THEN
         CLOSE gl_interface_cursor;
         EXIT;
       END IF;

     --l_batch_cnt := l_batch_cnt + 1; commented for Bug 1977939

       l_rec_count := l_rec_count + 1;
       IF gl_interface_rec.dr_cr_flag = 'D' THEN
         l_entered_dr := gl_interface_rec.summary_amount;
         l_entered_cr := NULL;
       ELSIF gl_interface_rec.dr_cr_flag = 'C' THEN
         l_entered_dr := NULL;
         l_entered_cr := gl_interface_rec.summary_amount;
       END IF;

--	Corrected currency_code reference and introduced exchange_rate_type and conversion_date for bug fix 2916848
       insert_into_gl_interface(
		L_SOB_ID,GL_INTERFACE_REC.EFFECTIVE_DATE, gl_batch_rec.currency_code,
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
		gl_interface_rec.exchange_rate_type,
                GL_INTERFACE_REC.accounting_date, --- added for 3108109
                L_RETURN_STATUS);

       IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

     END LOOP; -- Interface table loop.

   END LOOP; -- Payroll control id loop.
   --Moved the following IF..END IF stmt outside the Payroll control id loop to SB LOOP, Bug 1977939.
   IF l_rec_count > 0 THEN

     -- Gather the table statistics here ...

-- Commented for bug 9543455
/*     begin
       FND_STATS.Gather_Table_Stats (ownname => 'GL',
				     tabname => 'GL_INTERFACE');
--				     percent => 10,
--				     tmode   => 'TEMPORARY');
--   Above two parameters commented out for bug fix 2476829

     exception
       when others then
	null;

     end;*/

     -- insert into gl_interface_control
     SELECT	GL_JOURNAL_IMPORT_S.NEXTVAL
     INTO	l_int_run_id
     FROM	DUAL;

     insert into gl_interface_control(
         		je_source_name,
        		status,
      			interface_run_id,
        		group_id,
                  	set_of_books_id)
       		VALUES (
                  	l_user_je_source_name,
         		'S',
                  	l_int_run_id,
                  	l_group_id,
                  	l_sob_id
          	       );

     req_id := fnd_request.submit_request('SQLGL',
					'GLLEZL',
					'',
					'',
					FALSE,
					to_char(l_int_run_id),
					to_char(l_sob_id),
					'N',
					'',
					'',
					g_enable_enc_summ_gl,	--	Introduced as part of bug 2259310
					'W');		-- changed 'N' to 'W' for bug fix 2908859

     IF req_id = 0 THEN
	fnd_message.set_name('PSP', 'PSP_TR_GL_IMP_FAILED');
	fnd_msg_pub.add;
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSE
       update psp_payroll_controls
          set gl_phase = 'Submitted_Import_Request'
        --where payroll_control_id = gl_batch_rec.payroll_control_id;  Replaced this line for Bug 2133056
          where source_type = 'A'
            and batch_name = pc_batch_rec.batch_name;


        commit;
	call_status := fnd_concurrent.wait_for_request(req_id, 20, 0, rphase, rstatus,
							dphase, dstatus, message);
	if call_status = FALSE then
	   fnd_message.set_name('PSP', 'PSP_TR_GL_IMP_FAILED');
	   fnd_msg_pub.add;
	   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	end if;
     END IF;
   END IF;
  END LOOP; -- Small batch loop
   --
   p_return_status := fnd_api.g_ret_sts_success;
 EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     g_error_api_path := 'TRANSFER_TO_GL_INTERFACE:'||g_error_api_path;
     fnd_msg_pub.add_exc_msg('PSP_SUM_ADJ','TRANSFER_TO_GL_INTERFACE');
     p_return_status := fnd_api.g_ret_sts_unexp_error;

   WHEN RETURN_BACK THEN
     p_return_status := fnd_api.g_ret_sts_success;

   WHEN OTHERS THEN
     g_error_api_path := 'TRANSFER_TO_GL_INTERFACE:'||g_error_api_path;
     fnd_msg_pub.add_exc_msg('PSP_SUM_ADJ','TRANSFER_TO_GL_INTERFACE');
     p_return_status := fnd_api.g_ret_sts_unexp_error;
 END;

---------------------- GET_GL_JE_SOURCES --------------------------------------------------
 PROCEDURE get_gl_je_sources(P_USER_JE_SOURCE_NAME  OUT NOCOPY  VARCHAR2,
                             P_RETURN_STATUS        OUT NOCOPY  VARCHAR2) IS
-- Included the following cursor for bug fix 1765678
   CURSOR	user_je_source_name IS
   SELECT	user_je_source_name
   FROM		gl_je_sources
   WHERE	je_source_name = 'OLD';
   l_error		VARCHAR2(100);
   l_product	VARCHAR2(3);
 BEGIN
-- Replaced the earlier 'select stmt.' code with new 'cursor' code for bug fix 1765678

  OPEN user_je_source_name;
  FETCH user_je_source_name INTO p_user_je_source_name;
  IF (user_je_source_name%NOTFOUND) THEN
     CLOSE user_je_source_name;
     l_error := 'JE SOURCES = OLD';
     l_product := 'GL';
     fnd_message.set_name('PSP','PSP_TR_NOT_SET_UP');
     fnd_message.set_token('ERROR',l_error);
     fnd_message.set_token('PRODUCT',l_product);
     fnd_msg_pub.add;
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  CLOSE user_je_source_name;

 EXCEPTION
  WHEN NO_DATA_FOUND THEN
-- Obsoleted the following code as it gets handled by the new code inserted above for bug fix 1765678
--     l_error := 'JE SOURCES = OLD';
--     l_product := 'GL';
--     fnd_message.set_name('PSP','PSP_TR_NOT_SET_UP');
--     fnd_message.set_token('ERROR',l_error);
--     fnd_message.set_token('PRODUCT',l_product);
--     fnd_msg_pub.add;
    g_error_api_path := 'GL_JE_SOURCES:'||g_error_api_path;
    fnd_msg_pub.add_exc_msg('PSP_SUM_ADJ','GL_JE_SOURCES');
    p_return_status := fnd_api.g_ret_sts_unexp_error;
  WHEN OTHERS THEN
    g_error_api_path := 'GL_JE_SOURCES:'||g_error_api_path;
    fnd_msg_pub.add_exc_msg('PSP_SUM_ADJ','GL_JE_SOURCES');
    p_return_status := fnd_api.g_ret_sts_unexp_error;
 END;

---------------------- GET_GL_CATEGORIES --------------------------------------------------
 PROCEDURE get_gl_je_categories(P_USER_JE_CATEGORY_NAME  OUT NOCOPY  VARCHAR2,
                                P_RETURN_STATUS          OUT NOCOPY  VARCHAR2) IS
-- Included the following cursor for bug fix 1765678
   CURSOR gl_je_category_cur IS
   SELECT user_je_category_name
   FROM   gl_je_categories
   WHERE  je_category_name = 'OLD';
   l_error		VARCHAR2(100);
   l_product	VARCHAR2(3);
 BEGIN
   OPEN gl_je_category_cur;
   FETCH gl_je_category_cur INTO   p_user_je_category_name;
   IF (gl_je_category_cur%NOTFOUND) THEN
      CLOSE gl_je_category_cur;
      l_error := 'JE CATEGORY = OLD';
      l_product := 'GL';
      fnd_message.set_name('PSP','PSP_TR_NOT_SET_UP');
      fnd_message.set_token('ERROR',l_error);
      fnd_message.set_token('PRODUCT',l_product);
      fnd_msg_pub.add;
      p_return_status := fnd_api.g_ret_sts_unexp_error;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   CLOSE gl_je_category_cur;

 EXCEPTION
  WHEN NO_DATA_FOUND THEN
-- Obsoleted the following code as the exception is handled in the cursor%NOTFOUND area for bug fix 1765678
--   l_error := 'JE CATEGORY = OLD';
--   l_product := 'GL';
--   fnd_message.set_name('PSP','PSP_TR_NOT_SET_UP');
--   fnd_message.set_token('ERROR',l_error);
--   fnd_message.set_token('PRODUCT',l_product);
--   fnd_msg_pub.add;
   p_return_status := fnd_api.g_ret_sts_unexp_error;
  WHEN OTHERS THEN
    g_error_api_path := 'GL_JE_CATEGORY_NAME:'||g_error_api_path;
    fnd_msg_pub.add_exc_msg('PSP_SUM_ADJ','GL_JE_CATEGORY_NAME');
    p_return_status := fnd_api.g_ret_sts_unexp_error;
 END;

-------------------- GL TIE BACK -----------------------------------------------------
 PROCEDURE gl_tie_back(p_adj_sum_batch_name IN VARCHAR2,
		       p_business_group_id  IN NUMBER,
		       p_set_of_books_id    IN NUMBER,
                       p_return_status	 OUT NOCOPY	VARCHAR2) IS

   CURSOR pc_batch_cur IS
   SELECT distinct batch_name
     FROM psp_payroll_controls
    WHERE adj_sum_batch_name = p_adj_sum_batch_name
      AND (dist_dr_amount is not null and dist_cr_amount is not null)
      AND source_type = 'A'
      AND status_code = 'I'
      AND gl_phase = 'Submitted_Import_Request'
      AND business_group_id = p_business_group_id
      AND set_of_books_id = p_set_of_books_id
      AND run_id = nvl(g_run_id, run_id);

   pc_batch_rec		pc_batch_cur%ROWTYPE;

   CURSOR gl_tie_back_success_cur(p_group_id           IN NUMBER,
                                  p_payroll_control_id IN NUMBER ) IS  ----added for Bug 2133056
   SELECT summary_line_id,
          dr_cr_flag,summary_amount
   FROM   psp_summary_lines
   WHERE  group_id = p_group_id
     AND  payroll_control_id = p_payroll_control_id;

   CURSOR gl_reversal_cur(p_summary_line_id IN NUMBER) IS
   SELECT reversal_entry_flag
     FROM psp_adjustment_lines
    WHERE summary_line_id = p_summary_line_id;

   CURSOR gl_tie_back_cur(p_batch_name IN VARCHAR2) IS
   SELECT payroll_control_id,
	  source_type
     FROM psp_payroll_controls
    WHERE batch_name = p_batch_name
      AND (dist_dr_amount is not null and dist_cr_amount is not null)
      AND source_type = 'A'
      AND status_code = 'I'
      AND business_group_id = p_business_group_id
      AND set_of_books_id = p_set_of_books_id
      AND gl_phase = 'Submitted_Import_Request'
      AND run_id = nvl(g_run_id, run_id);

  gl_tie_back_rec	gl_tie_back_cur%ROWTYPE;

  l_orig_org_name		hr_all_organization_units_tl.name%TYPE;	-- Bug 2447912: Modified declaration
  l_orig_org_id			number;

   l_organization_name		hr_all_organization_units_tl.name%TYPE;	-- Bug 2447912: Modified declaration
   l_organization_id		NUMBER(15);
   l_rowid			ROWID;
   l_assignment_id		NUMBER(9);
   l_distribution_date		DATE;
   l_reversal_entry_flag	VARCHAR2(1);
   l_lines_glccid		NUMBER(15);
   --
   l_organization_account_id	NUMBER(9);
   l_susp_glccid		NUMBER(15);
   l_project_id			NUMBER(15);
   l_award_id			NUMBER(15);
   l_task_id			NUMBER(15);
   --
   l_status			VARCHAR2(50);
   l_reference6			VARCHAR2(100);
   --
   l_cnt_gl_interface		NUMBER;
   l_summary_line_id		NUMBER(10);
   l_gl_project_flag		VARCHAR2(1);
   l_reversal_ac_failed		VARCHAR2(1) := 'N';
   l_summary_amount		NUMBER;
   l_dr_summary_amount		NUMBER := 0;
   l_cr_summary_amount		NUMBER := 0;
   l_dr_cr_flag			VARCHAR2(1);
   l_effective_date		DATE;
   x_lines_glccid		NUMBER(15);
   l_return_status		VARCHAR2(10);
	l_msg_id		number(9);
   l_dist_line_id		number(9);
   l_group_id			number(15);
--
   l_adjustment_batch_name      varchar2(50);
   l_person_id			number;
   l_person_name		varchar2(80);
--   l_assignment_id		number;
   l_assignment_number		number;
   l_element_type_id		number;
---   l_element_name		varchar2(80);
   l_distribution_start_date	date;
   l_distribution_end_date	date;
   l_err_status			varchar2(80);

-- Included the following cursors here for accessing local varibales for bug fix 1765678
   CURSOR	summary_group_cur IS
   SELECT	PSL.group_id
   FROM		psp_summary_lines PSL,
                psp_payroll_controls PPC
   WHERE        PPC.payroll_control_id = PSL.payroll_control_id
-- WHERE	payroll_control_id = gl_tie_back_rec.payroll_control_id
     AND        PPC.batch_name =  pc_batch_rec.batch_name
     AND        PPC.source_type = 'A'
     AND	PSL.group_id IS NOT NULL
     AND        rownum =1;  -- Removed max function on group_id and introduced rownum=1 Bug 2133056

   CURSOR	gl_interface_group_cur IS
   SELECT	count(*)
   FROM		gl_interface
   WHERE	group_id = l_group_id
   AND		set_of_books_id = p_set_of_books_id
   AND		user_je_source_name = 'OLD';

-- Bug 2133056: Changes related to handle situation of GL import leaving some xface recs in 'NEW'
  CURSOR       gl_interface_status_cur IS
   SELECT       count(*)
   FROM         gl_interface
   WHERE        group_id = l_group_id
   AND          user_je_source_name = 'OLD'
   AND          status = 'NEW';
   l_status_new integer;

 BEGIN

   OPEN pc_batch_cur;
   LOOP
   FETCH pc_batch_cur into pc_batch_rec;
   if pc_batch_cur%NOTFOUND then
     close pc_batch_cur;
     exit;
   end if;

   /* Moved the following cursor outside payroll control id LOOP for 2133056 */
   OPEN summary_group_cur;
   FETCH summary_group_cur INTO l_group_id;
   IF (summary_group_cur%NOTFOUND) THEN
	CLOSE summary_group_cur;
        g_error_api_path := 'GL_TIE_BACK:'||g_error_api_path;
        fnd_msg_pub.add_exc_msg('PSP_SUM_ADJ','GL_TIE_BACK');
        p_return_status := fnd_api.g_ret_sts_unexp_error;
	EXIT;
   END IF;
   CLOSE summary_group_cur;

    /* Bug 2133056: to handle situation of GL import left lines untouched */
     OPEN gl_interface_status_cur;
     FETCH gl_interface_status_cur INTO l_status_new;
     IF (gl_interface_status_cur%NOTFOUND) THEN
       CLOSE gl_interface_status_cur;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;
     CLOSE gl_interface_status_cur;

     if l_status_new > 0 then
          update psp_payroll_controls
            set gl_phase = 'Summarize_GL_Lines'
          where gl_phase = 'Submitted_Import_Request'
            and batch_name =  pc_batch_rec.batch_name; --- 3184075
            ---and adj_sum_batch_name = p_adj_sum_batch_name;

          delete from gl_interface
           where group_id = l_group_id
             and user_je_source_name = 'OLD';

          delete from gl_interface_control
           where group_id = l_group_id
             and je_source_name = 'OLD';

          commit;

	   fnd_message.set_name('PSP', 'PSP_TR_GL_IMP_FAILED');
	   fnd_msg_pub.add;
	   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

     end if;


   OPEN gl_tie_back_cur(pc_batch_rec.batch_name);
   LOOP
   FETCH gl_tie_back_cur into gl_tie_back_rec;
   IF gl_tie_back_cur%NOTFOUND then
     CLOSE gl_tie_back_cur;
     EXIT;
   END IF;
   UPDATE psp_payroll_controls
      SET gl_phase = 'GL_Tie_Back'
    WHERE payroll_control_id = gl_tie_back_rec.payroll_control_id;

-- Replaced the earlier 'select stmt.' code with new 'cursor' code for bug fix 1765678


   OPEN gl_interface_group_cur;
   FETCH gl_interface_group_cur INTO l_cnt_gl_interface;
   IF (gl_interface_group_cur%NOTFOUND) THEN
	CLOSE gl_interface_group_cur;
        g_error_api_path := 'GL_TIE_BACK:'||g_error_api_path;
        fnd_msg_pub.add_exc_msg('PSP_SUM_ADJ','GL_TIE_BACK');
        p_return_status := fnd_api.g_ret_sts_unexp_error;
	EXIT;
   END IF;
   CLOSE gl_interface_group_cur;

   IF l_cnt_gl_interface > 0 THEN


	   fnd_message.set_name('PSP','PSP_ADJ_GL_FAILED');
	   get_the_batch_details(pc_batch_rec.batch_name, l_return_status);
	   fnd_msg_pub.add;

    	   cleanup_batch_details(gl_tie_back_rec.payroll_control_id,l_group_id); -- added group id for 2133056
--	Commented the following as cursor is not at all used
--	Uncommented the following code as the code would fail if more than one GL batch fails along bug fix 1828519
    	   close gl_tie_back_cur;
    	   exit;

   ELSIF l_cnt_gl_interface = 0 THEN
     OPEN gl_tie_back_success_cur(l_group_id,gl_tie_back_rec.payroll_control_id); --Added control id for 2133056
     l_dr_summary_amount := 0;  --- Bug 2133056, initialized the amounts
     l_cr_summary_amount := 0;
     LOOP
       FETCH gl_tie_back_success_cur INTO l_summary_line_id,
       l_dr_cr_flag,l_summary_amount;
       IF gl_tie_back_success_cur%NOTFOUND THEN
         CLOSE gl_tie_back_success_cur;
         EXIT;
       END IF;

   --dbms_output.put_line('Am in the success loop');

       -- update records in psp_summary_lines as 'A'
       UPDATE psp_summary_lines
       SET status_code = 'A'
       WHERE summary_line_id = l_summary_line_id;

       IF l_dr_cr_flag = 'D' THEN
         l_dr_summary_amount := l_dr_summary_amount + l_summary_amount;
       ELSIF l_dr_cr_flag = 'C' THEN
         l_cr_summary_amount := l_cr_summary_amount + l_summary_amount;
       END IF;

         UPDATE psp_adjustment_lines
         SET status_code = 'A' WHERE summary_line_id = l_summary_line_id;

      -- move the transferred records to psp_adjustment_lines_history
         INSERT INTO psp_adjustment_lines_history
         (adjustment_line_id,person_id,assignment_id,element_type_id,
          distribution_date,effective_date,distribution_amount,
          dr_cr_flag,payroll_control_id,source_type,source_code,time_period_id,
          batch_name,status_code,set_of_books_id,gl_code_combination_id,project_id,
          expenditure_organization_id,expenditure_type,task_id,award_id,
          suspense_org_account_id,suspense_reason_code,effort_report_id,version_num,
          summary_line_id, reversal_entry_flag, original_line_flag, user_defined_field, percent,
 	  orig_source_type,
          orig_line_id,attribute_category,attribute1,attribute2,attribute3,attribute4,
          attribute5,attribute6,attribute7,attribute8,attribute9,attribute10,attribute11,
          attribute12,attribute13,attribute14,attribute15,last_update_date,
          last_updated_by,last_update_login,created_by,creation_date, business_group_id,
          adj_set_number, line_number)   ---   added cols 2634557 DA Multiple element Enh
         SELECT adjustment_line_id,person_id,assignment_id,element_type_id,
          distribution_date,effective_date,distribution_amount,
          dr_cr_flag,payroll_control_id,source_type,source_code,time_period_id,
          batch_name,status_code,set_of_books_id,gl_code_combination_id,project_id,
          expenditure_organization_id,expenditure_type,task_id,award_id,
          suspense_org_account_id,suspense_reason_code,effort_report_id,version_num,
          summary_line_id, reversal_entry_flag, original_line_flag, user_defined_field, percent,
 	  orig_source_type,
          orig_line_id,attribute_category,attribute1,attribute2,attribute3,attribute4,
          attribute5,attribute6,attribute7,attribute8,attribute9,attribute10,attribute11,
          attribute12,attribute13,attribute14,attribute15,SYSDATE,FND_GLOBAL.USER_ID,
          FND_GLOBAL.LOGIN_ID,FND_GLOBAL.USER_ID,SYSDATE, business_group_id,
          adj_set_number, line_number  ---   added cols 2634557 DA Multiple element Enh
         FROM psp_adjustment_lines
         WHERE status_code = 'A'
         AND summary_line_id = l_summary_line_id;

         DELETE FROM psp_adjustment_lines
         WHERE status_code = 'A'
         AND summary_line_id = l_summary_line_id;

     END LOOP;

       UPDATE psp_payroll_controls
       SET gl_dr_amount = nvl(gl_dr_amount,0) + l_dr_summary_amount,
           gl_cr_amount = nvl(gl_cr_amount,0) + l_cr_summary_amount
       WHERE payroll_control_id = gl_tie_back_rec.payroll_control_id;

   END IF;
 END LOOP; -- end loop for gl_tie_back_cur
 commit;
 END LOOP; -- end loop for pc_batch_cur

   --
   p_return_status := fnd_api.g_ret_sts_success;
 EXCEPTION

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     g_error_api_path := 'GL_TIE_BACK:'||g_error_api_path;
-- Included the following for bug fix 1765678
     fnd_msg_pub.add_exc_msg('PSP_SUM_ADJ','GL_TIE_BACK');
     p_return_status := fnd_api.g_ret_sts_unexp_error;

   WHEN OTHERS THEN
      g_error_api_path := 'GL_TIE_BACK:'||g_error_api_path;
      fnd_msg_pub.add_exc_msg('PSP_SUM_ADJ','GL_TIE_BACK');
      p_return_status := fnd_api.g_ret_sts_unexp_error;
 END;

------------------ CREATE BALANCING TRANSACTIONS FOR GL ------------------------------

 PROCEDURE gl_balance_transaction(P_SOURCE_TYPE		IN	VARCHAR2,
				  P_PAYROLL_CONTROL_ID	IN	NUMBER,
				  P_BUSINESS_GROUP_ID	IN	NUMBER,
				  P_SET_OF_BOOKS_ID	IN	NUMBER,
                  		  P_RETURN_STATUS       OUT NOCOPY VARCHAR2) IS
   --- changed the cursor for 3108109
   CURSOR ad_reversal_entry_cur(P_PAYROLL_CONTROL_ID IN NUMBER) IS
   SELECT person_id,
          assignment_id,
          to_number(null) element_type_id,
          dr_cr_flag,
          effective_date,
          accounting_date,
          exchange_rate_type,
          source_type,
          source_code,
          time_period_id,
          summary_amount reversal_dist_amount,
          interface_batch_name,
          summary_line_id
   FROM   psp_summary_lines
   WHERE  payroll_control_id = p_payroll_control_id
   AND    gl_code_combination_id IS NOT NULL
   AND    status_code = 'N'
   AND	  business_group_id = p_business_group_id
   AND	  set_of_books_id = p_set_of_books_id;
/*
   GROUP BY person_id,assignment_id,element_type_id,dr_cr_flag,effective_date,
            source_type,source_code,time_period_id,batch_name; */

   l_payroll_id           NUMBER(9);   -- Added for bug 5592964

-- Included the following cursor for bug fix 1765678
   CURSOR	reversing_gl_ccid_cur IS
   SELECT	reversing_gl_ccid
   FROM		psp_clearing_account
   WHERE	set_of_books_id = p_set_of_books_id
   AND		business_group_id = p_business_group_id
   AND		payroll_id = l_payroll_id;              -- Added for bug 5592964


-- Redundant balancing lines created for GL Balanced Batch Bug 1977893
-- Added following two cursors and two variables for credit amount and debit amount
   cursor  control_rec_debit_amount_cur is
   select sum(nvl(distribution_amount,0))
   from   psp_adjustment_lines
   where dr_cr_flag = 'D'
    and gl_code_combination_id is not null
    and  payroll_control_id = p_payroll_control_id;

   cursor  control_rec_credit_amount_cur is
   select sum(nvl(distribution_amount,0))
   from   psp_adjustment_lines
   where dr_cr_flag = 'C'
   and gl_code_combination_id is not null
   and  payroll_control_id = p_payroll_control_id;

   l_control_rec_credit number;
   l_control_rec_debit number;
--- Bug 1977893 changes end.

   --- added following cursor for 3108109
   cursor get_element_type_id(p_summary_line_id number) is
   select element_type_id
   from psp_adjustment_lines
   where summary_line_id = p_summary_line_id
   and rownum = 1;


   ad_reversal_entry_rec	ad_reversal_entry_cur%ROWTYPE;
   ---l_reversal_dist_amount	NUMBER; Bug 1976999
   l_clrg_account_glccid	NUMBER(15);
	l_msg_id	number(9);
   l_summary_line_id           NUMBER;   -- added for 3108109
   l_return_status      varchar2(10);  -- added for 3108109

 BEGIN
  open  control_rec_debit_amount_cur;
  fetch  control_rec_debit_amount_cur into l_control_rec_debit;
  close control_rec_debit_amount_cur;
  open  control_rec_credit_amount_cur;
  fetch control_rec_credit_amount_cur into l_control_rec_credit;
  close control_rec_credit_amount_cur;
  if (l_control_rec_debit is null      and l_control_rec_credit is not null) or
      (l_control_rec_debit is not null and l_control_rec_credit is null) or
      (l_control_rec_credit <> l_control_rec_debit)  then  /* Bug 1977893 */
   IF p_source_type = 'A' THEN

       SELECT payroll_id INTO l_payroll_id
       FROM  psp_payroll_controls
       WHERE payroll_control_id = p_payroll_control_id;

       BEGIN
      -- Replaced the earlier 'select stmt.' code with new 'cursor' code , inserted new code for bug fix 1765678
         OPEN reversing_gl_ccid_cur;
         FETCH reversing_gl_ccid_cur INTO l_clrg_account_glccid;
         IF (reversing_gl_ccid_cur%NOTFOUND) THEN
               CLOSE reversing_gl_ccid_cur;
               fnd_message.set_name('PSP','PSP_TR_CLRG_AC_NOT_SET_UP');
               fnd_msg_pub.add;
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
         CLOSE reversing_gl_ccid_cur;
       END;

       DELETE FROM psp_adjustment_lines
       WHERE reversal_entry_flag = 'Y'
       AND status_code = 'N'
       AND payroll_control_id = p_payroll_control_id;

       -- recalculate and update the reversal sub-line amounts
       OPEN ad_reversal_entry_cur(p_payroll_control_id);
       LOOP
         FETCH ad_reversal_entry_cur INTO ad_reversal_entry_rec;
         IF ad_reversal_entry_cur%NOTFOUND THEN
           CLOSE ad_reversal_entry_cur;
           EXIT;
         END IF;
         IF ad_reversal_entry_rec.reversal_dist_amount <> 0 THEN
           /* bug 1976999 */
           if ad_reversal_entry_rec.dr_cr_flag = 'C' then
             ad_reversal_entry_rec.dr_cr_flag := 'D';
           else
             ad_reversal_entry_rec.dr_cr_flag := 'C';
           end if;
           --l_reversal_dist_amount := 0 - ad_reversal_entry_rec.reversal_dist_amount; Bug 1976999
         --END IF;

           open get_element_type_id(ad_reversal_entry_rec.summary_line_id);
           fetch get_element_type_id into ad_reversal_entry_rec.element_type_id;
           if get_element_type_id%notfound then
               close get_element_type_id;
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           end if;
           close get_element_type_id;

             insert_into_summary_lines(
                l_summary_line_id,
                ad_reversal_entry_rec.person_id,
                ad_reversal_entry_rec.assignment_id,
                ad_reversal_entry_rec.time_period_id,
                ad_reversal_entry_rec.effective_date,
                ad_reversal_entry_rec.accounting_date,
                ad_reversal_entry_rec.exchange_rate_type,
                'A',
                ad_reversal_entry_rec.source_code,
                p_set_of_books_id,
                l_clrg_account_glccid,
                NULL,
                NULL,
                NULL,
                NULL,
                NULL,
                ad_reversal_entry_rec.reversal_dist_amount,
                ad_reversal_entry_rec.dr_cr_flag,
                'N',
                ad_reversal_entry_rec.interface_batch_name,
                p_payroll_control_id,
                p_business_group_id,
--	Introduced NULL for DFF parameters as clearing a/c doesnt require DFF values as part bug fix 2908859
		NULL,
		NULL,
		NULL,
		NULL,
		NULL,
		NULL,
		NULL,
		NULL,
		NULL,
		NULL,
		NULL,
                l_return_status);

                 IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                 END IF;

         -- insert the reversal entry record into distribution lines
         insert into psp_adjustment_lines
           (adjustment_line_id,person_id,assignment_id,element_type_id,
            distribution_date,effective_date,distribution_amount,dr_cr_flag,
            payroll_control_id,source_type,source_code,time_period_id,batch_name,
            status_code,gl_code_combination_id,reversal_entry_flag,last_update_date,last_updated_by,
            last_update_login,created_by,creation_date, business_group_id, set_of_books_id,
            summary_line_id)
         values
           (PSP_ADJUSTMENT_LINES_S.NEXTVAL,ad_reversal_entry_rec.person_id,
            ad_reversal_entry_rec.assignment_id,ad_reversal_entry_rec.element_type_id,
            ad_reversal_entry_rec.effective_date,ad_reversal_entry_rec.effective_date,
             ad_reversal_entry_rec.reversal_dist_amount, ----l_reversal_dist_amount, Bug 1976999
            ad_reversal_entry_rec.dr_cr_flag,
            p_payroll_control_id,ad_reversal_entry_rec.source_type,
            ad_reversal_entry_rec.source_code,ad_reversal_entry_rec.time_period_id,
            ad_reversal_entry_rec.interface_batch_name,'N',l_clrg_account_glccid,'Y',
	SYSDATE,FND_GLOBAL.USER_ID,FND_GLOBAL.LOGIN_ID,FND_GLOBAL.USER_ID,SYSDATE,
	p_business_group_id, p_set_of_books_id, l_summary_line_id);
         END IF;
       END LOOP;
     END IF;
   end if;  -- control_rec_debit <> control_rec_credit
     --
     p_return_status := fnd_api.g_ret_sts_success;
 EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     g_error_api_path := 'GL_BALANCE_TRANSACTION:'||g_error_api_path;
-- Included the following line for bug fix 1765678
     fnd_msg_pub.add_exc_msg('PSP_SUM_ADJ','GL_BALANCE_TRANSACTION');
     p_return_status := fnd_api.g_ret_sts_unexp_error;

   WHEN OTHERS THEN
      g_error_api_path := 'GL_BALANCE_TRANSACTION:'||g_error_api_path;
      fnd_msg_pub.add_exc_msg('PSP_SUM_ADJ','GL_BALANCE_TRANSACTION');
      p_return_status := fnd_api.g_ret_sts_unexp_error;
 END;

------------------ INSERT INTO GL INTERFACE -----------------------------------------------

 PROCEDURE insert_into_gl_interface(
			P_SET_OF_BOOKS_ID 		IN	NUMBER,
			P_ACCOUNTING_DATE		IN	DATE,
			P_CURRENCY_CODE			IN	VARCHAR2,
			P_USER_JE_CATEGORY_NAME		IN	VARCHAR2,
			P_USER_JE_SOURCE_NAME		IN	VARCHAR2,
			P_ENCUMBRANCE_TYPE_ID		IN	NUMBER,
			P_CODE_COMBINATION_ID		IN	NUMBER,
			P_ENTERED_DR			IN	NUMBER,
			P_ENTERED_CR			IN	NUMBER,
			P_GROUP_ID			IN	NUMBER,
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
			P_CURRENCY_CONVERSION_TYPE	IN	VARCHAR2,	-- Introduced for bug fix 2916848
			P_CURRENCY_CONVERSION_DATE		IN	DATE,	-- Introduced for bug fix 2916848
			P_RETURN_STATUS			OUT NOCOPY	VARCHAR2) IS
	l_msg_id	number(9);
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
	REFERENCE30,
--	Introduced teh following columns for bug fix 2916848
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
--	Introduced the following columns for bug fix 2916848
	P_CURRENCY_CONVERSION_TYPE,
	DECODE(p_currency_conversion_type, NULL, NULL, P_CURRENCY_CONVERSION_DATE));
--
    p_return_status := fnd_api.g_ret_sts_success;
 EXCEPTION
   WHEN OTHERS THEN
      g_error_api_path := 'INSERT_INTO_GL_INTERFACE:'||g_error_api_path;
      fnd_msg_pub.add_exc_msg('PSP_SUM_ADJ','INSERT_INTO_GL_INTERFACE');
      p_return_status := fnd_api.g_ret_sts_unexp_error;
 END;

-------------------- CREATE GMS SUM LINES -----------------------------------------------
 PROCEDURE create_gms_sum_lines(p_adj_sum_batch_name      IN VARCHAR2,
				p_business_group_id	  IN NUMBER,
				p_set_of_books_id	  IN NUMBER,
                                p_return_status  OUT NOCOPY VARCHAR2) IS

   CURSOR pc_batch_cur IS
   SELECT distinct batch_name
   FROM   psp_payroll_controls
   WHERE  adj_sum_batch_name = p_adj_sum_batch_name
   AND    source_type = 'A'
   AND    (dist_dr_amount IS NOT NULL OR dist_cr_amount IS NOT NULL)
   AND    status_code = 'I'
   AND    run_id = nvl(g_run_id, run_id)
   AND	  business_group_id = p_business_group_id
   AND	  set_of_books_id = p_set_of_books_id
   AND     gms_phase is null;

   pc_batch_rec		pc_batch_cur%ROWTYPE;

   CURSOR payroll_control_cur(p_batch_name IN VARCHAR2) IS
   SELECT payroll_control_id,
          source_type,
          payroll_source_code,
          time_period_id,
          batch_name
   FROM   psp_payroll_controls
   WHERE  batch_name = p_batch_name
   AND    source_type = 'A'
   AND    (dist_dr_amount IS NOT NULL OR dist_cr_amount IS NOT NULL)
   AND    status_code = 'I'
   AND    run_id = nvl(g_run_id, run_id);

   CURSOR gms_sum_lines_cursor(P_PAYROLL_CONTROL_ID  IN  NUMBER) IS
   SELECT pal.person_id,
          pal.assignment_id,
	  pal.project_id project_id,
	  pal.expenditure_organization_id,
	  pal.expenditure_type,
	  pal.task_id,
	  pal.award_id,
          pal.dr_cr_flag,
          pal.effective_date,
          psl.accounting_date,  -- new column 3108109, removed nvl for 4734810
          psl.exchange_rate_type,
	  pal.distribution_amount,
          pal.adjustment_line_id distribution_line_id,
          'A' tab_flag,
	DECODE(g_dff_grouping_option, 'Y', pal.attribute_category, NULL) attribute_category,	-- Introduced DFF columns for bug fix 2908859
	DECODE(g_dff_grouping_option, 'Y', pal.attribute1, NULL) attribute1,
	DECODE(g_dff_grouping_option, 'Y', pal.attribute2, NULL) attribute2,
	DECODE(g_dff_grouping_option, 'Y', pal.attribute3, NULL) attribute3,
	DECODE(g_dff_grouping_option, 'Y', pal.attribute4, NULL) attribute4,
	DECODE(g_dff_grouping_option, 'Y', pal.attribute5, NULL) attribute5,
	DECODE(g_dff_grouping_option, 'Y', pal.attribute6, NULL) attribute6,
	DECODE(g_dff_grouping_option, 'Y', pal.attribute7, NULL) attribute7,
	DECODE(g_dff_grouping_option, 'Y', pal.attribute8, NULL) attribute8,
	DECODE(g_dff_grouping_option, 'Y', pal.attribute9, NULL) attribute9,
	DECODE(g_dff_grouping_option, 'Y', pal.attribute10, NULL) attribute10
   FROM   psp_adjustment_lines       pal,
          psp_distribution_lines_history pdh,
          psp_summary_lines psl
   WHERE  pal.status_code = 'N'
   AND    pal.gl_code_combination_id IS NULL
   AND    pal.payroll_control_id = p_payroll_control_id
   AND    pdh.distribution_line_id = pal.orig_line_id
   AND    pal.orig_source_type = 'D'
   AND    psl.summary_line_id = pdh.summary_line_id
   UNION
   SELECT pal.person_id,
          pal.assignment_id,
	  pal.project_id project_id,
	  pal.expenditure_organization_id,
	  pal.expenditure_type,
	  pal.task_id,
	  pal.award_id,
          pal.dr_cr_flag,
          pal.effective_date,
          psl.accounting_date,  -- new column 3108109
          psl.exchange_rate_type,
	  pal.distribution_amount,
          pal.adjustment_line_id distribution_line_id,
          'A' tab_flag,
	DECODE(g_dff_grouping_option, 'Y', pal.attribute_category, NULL) attribute_category,	-- Introduced DFF columns for bug fix 2908859
	DECODE(g_dff_grouping_option, 'Y', pal.attribute1, NULL) attribute1,
	DECODE(g_dff_grouping_option, 'Y', pal.attribute2, NULL) attribute2,
	DECODE(g_dff_grouping_option, 'Y', pal.attribute3, NULL) attribute3,
	DECODE(g_dff_grouping_option, 'Y', pal.attribute4, NULL) attribute4,
	DECODE(g_dff_grouping_option, 'Y', pal.attribute5, NULL) attribute5,
	DECODE(g_dff_grouping_option, 'Y', pal.attribute6, NULL) attribute6,
	DECODE(g_dff_grouping_option, 'Y', pal.attribute7, NULL) attribute7,
	DECODE(g_dff_grouping_option, 'Y', pal.attribute8, NULL) attribute8,
	DECODE(g_dff_grouping_option, 'Y', pal.attribute9, NULL) attribute9,
	DECODE(g_dff_grouping_option, 'Y', pal.attribute10, NULL) attribute10
   FROM   psp_adjustment_lines       pal,
          psp_adjustment_lines_history pal2,
          psp_summary_lines psl
   WHERE  pal.status_code = 'N'
   AND    pal.gl_code_combination_id IS NULL
   AND    pal.payroll_control_id = p_payroll_control_id
   AND    pal2.adjustment_line_id = pal.orig_line_id
   AND    pal.orig_source_type = 'A'
   AND    psl.summary_line_id = pal2.summary_line_id
   union
   SELECT pal.person_id,
          pal.assignment_id,
	  pal.project_id project_id,
	  pal.expenditure_organization_id,
	  pal.expenditure_type,
	  pal.task_id,
	  pal.award_id,
          pal.dr_cr_flag,
          pal.effective_date,
          psl.accounting_date,   -- new column 3108109
          psl.exchange_rate_type,
	  pal.distribution_amount,
          pal.adjustment_line_id distribution_line_id,
          'A' tab_flag,
	DECODE(g_dff_grouping_option, 'Y', pal.attribute_category, NULL) attribute_category,	-- Introduced DFF columns for bug fix 2908859
	DECODE(g_dff_grouping_option, 'Y', pal.attribute1, NULL) attribute1,
	DECODE(g_dff_grouping_option, 'Y', pal.attribute2, NULL) attribute2,
	DECODE(g_dff_grouping_option, 'Y', pal.attribute3, NULL) attribute3,
	DECODE(g_dff_grouping_option, 'Y', pal.attribute4, NULL) attribute4,
	DECODE(g_dff_grouping_option, 'Y', pal.attribute5, NULL) attribute5,
	DECODE(g_dff_grouping_option, 'Y', pal.attribute6, NULL) attribute6,
	DECODE(g_dff_grouping_option, 'Y', pal.attribute7, NULL) attribute7,
	DECODE(g_dff_grouping_option, 'Y', pal.attribute8, NULL) attribute8,
	DECODE(g_dff_grouping_option, 'Y', pal.attribute9, NULL) attribute9,
	DECODE(g_dff_grouping_option, 'Y', pal.attribute10, NULL) attribute10
   FROM   psp_adjustment_lines       pal,
          psp_pre_gen_dist_lines_history pgh,
          psp_summary_lines psl
   WHERE  pal.status_code = 'N'
   AND    pal.gl_code_combination_id IS NULL
   AND    pal.payroll_control_id = p_payroll_control_id
   AND    pgh.pre_gen_dist_line_id = pal.orig_line_id
   AND    pal.orig_source_type = 'P'
   AND    psl.summary_line_id = pgh.summary_line_id
   ORDER BY 1,2,3,4,5,6,7,8,10,11,15,16,17,18,19,20,21,22,23,24,25,9;
      --- added 2 new cols for 3108109
   --- changed the order by clause for 6007017

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

   TYPE dist_id IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
   dist_line_id				dist_id;
   l_dist_line_id			      NUMBER;
   i					      BINARY_INTEGER := 0;
   j					      NUMBER;
   l_return_status			VARCHAR2(10);
	l_msg_id	number(9);
   l_accounting_date                    DATE; --- added for 3108109
   l_exchange_rate_type                 VARCHAR2(30);
	l_attribute_category	VARCHAR2(30);		-- Introduced DFF variables for bug fix 2908859
	l_attribute1		VARCHAR2(150);
	l_attribute2		VARCHAR2(150);
	l_attribute3		VARCHAR2(150);
	l_attribute4		VARCHAR2(150);
	l_attribute5		VARCHAR2(150);
	l_attribute6		VARCHAR2(150);
	l_attribute7		VARCHAR2(150);
	l_attribute8		VARCHAR2(150);
	l_attribute9		VARCHAR2(150);
	l_attribute10		VARCHAR2(150);

	-- R12 MOAC Uptake
	l_org_id number(15);
 BEGIN
  OPEN pc_batch_cur;
  LOOP
  FETCH pc_batch_cur into pc_batch_rec;
  IF pc_batch_cur%NOTFOUND THEN
     CLOSE pc_batch_cur;
     EXIT;
  END IF;

  OPEN payroll_control_cur(pc_batch_rec.batch_name);
  LOOP
   FETCH payroll_control_cur INTO payroll_control_rec;
   IF payroll_control_cur%NOTFOUND THEN
     CLOSE payroll_control_cur;
     EXIT;
   END IF;

   OPEN gms_sum_lines_cursor(payroll_control_rec.payroll_control_id);
   l_rec_count := 0;
   l_summary_amount := 0;
   i := 0;
   LOOP
     FETCH gms_sum_lines_cursor INTO gms_sum_lines_rec;
     l_rec_count := l_rec_count + 1;
     IF gms_sum_lines_cursor%NOTFOUND THEN
	if (l_rec_count > 1 ) then
	  g_gms_avail := 'Y';
          UPDATE psp_payroll_controls
             SET gms_phase = 'Summarize_GMS_Lines'
           WHERE payroll_control_id = payroll_control_rec.payroll_control_id;
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
       l_accounting_date        := gms_sum_lines_rec.accounting_date; --3108109
       l_exchange_rate_type     := gms_sum_lines_rec.exchange_rate_type;
	l_attribute_category	:= gms_sum_lines_rec.attribute_category;		-- Introduced DFF variables for bug fix 2908859
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
        l_dr_cr_flag <> gms_sum_lines_rec.dr_cr_flag OR
	(NVL(l_attribute_category, 'NULL') <> NVL(gms_sum_lines_rec.attribute_category, 'NULL')) OR	-- Introduced DFF check for bug fix 2908859
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
        nvl(l_accounting_date, fnd_date.canonical_to_date('1800/01/31')) <>
           nvl( gms_sum_lines_rec.accounting_date, fnd_date.canonical_to_date('1800/01/31')) OR
        nvl(l_exchange_rate_type,'-999') <> nvl(gms_sum_lines_rec.exchange_rate_type,'-999') THEN --3108109

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
                l_accounting_date,   --- 3108109
                l_exchange_rate_type,
            	payroll_control_rec.source_type,
 		payroll_control_rec.payroll_source_code,
            	p_set_of_books_id,
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
		p_business_group_id,
		l_attribute_category,				-- Introduced DFF parameters for bug fix 2908859
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
		l_org_id			-- R12 MOAC Uptake
		);

       IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

       FOR j IN 1 .. dist_line_id.COUNT LOOP
         l_dist_line_id := dist_line_id(j);
         IF gms_sum_lines_rec.tab_flag = 'A' THEN
           UPDATE psp_adjustment_lines
           SET summary_line_id = l_summary_line_id WHERE adjustment_line_id = l_dist_line_id;
         END IF;
       END LOOP;

       -- initialise the summary amount and dist_line_id
       l_summary_amount := 0;
       dist_line_id.delete;
       i := 0;
     END IF;

     l_person_id		:= gms_sum_lines_rec.person_id;
     l_assignment_id		:= gms_sum_lines_rec.assignment_id;
     l_project_id               := gms_sum_lines_rec.project_id;
     l_expenditure_organization_id := gms_sum_lines_rec.expenditure_organization_id;
     l_expenditure_type         := gms_sum_lines_rec.expenditure_type;
     l_task_id                  := gms_sum_lines_rec.task_id;
     l_award_id                 := gms_sum_lines_rec.award_id;
     l_dr_cr_flag		:= gms_sum_lines_rec.dr_cr_flag;
     l_effective_date		:= gms_sum_lines_rec.effective_date;
     l_accounting_date          := gms_sum_lines_rec.accounting_date; --3108109
     l_exchange_rate_type       := gms_sum_lines_rec.exchange_rate_type;
	l_attribute_category	:= gms_sum_lines_rec.attribute_category;		-- Introduced DFF variables for bug fix 2908859
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
	-- R12 MOAC Uptake
	l_org_id := psp_general.Get_transaction_org_id (l_project_id,l_expenditure_organization_id);

	 -- insert into summary lines
     insert_into_summary_lines(
            	l_summary_line_id,
		l_person_id,
		l_assignment_id,
            	payroll_control_rec.time_period_id,
 		l_effective_date,
                l_accounting_date, --- added for 3108109
                l_exchange_rate_type,
            	payroll_control_rec.source_type,
 		payroll_control_rec.payroll_source_code,
            	p_set_of_books_id,
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
		p_business_group_id,
		l_attribute_category,				-- Introduced DFF parameters for bug fix 2908859
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
		l_org_id 		-- R12 MOAC Uptake
		);

     IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

     FOR j IN 1 .. dist_line_id.COUNT LOOP
       l_dist_line_id := dist_line_id(j);

       IF gms_sum_lines_rec.tab_flag = 'A' THEN
         UPDATE psp_adjustment_lines
         SET summary_line_id = l_summary_line_id,
             status_code = 'N'
         WHERE adjustment_line_id = l_dist_line_id;
       END IF;
     END LOOP;
     dist_line_id.delete;
   END IF;

  END LOOP; --- End loop for payroll_control_cur
  END LOOP; --- End loop for pc_batch_cur
  --
  p_return_status := fnd_api.g_ret_sts_success;

 EXCEPTION

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     g_error_api_path := 'CREATE_GMS_SUM_LINES:'||g_error_api_path;
-- Included the following code for bug fix 1765678
     fnd_msg_pub.add_exc_msg('PSP_SUM_ADJ','CREATE_GMS_SUM_LINES');
     p_return_status := fnd_api.g_ret_sts_unexp_error;
   WHEN OTHERS THEN
     g_error_api_path := 'CREATE_GMS_SUM_LINES:'||g_error_api_path;
     fnd_msg_pub.add_exc_msg('PSP_SUM_ADJ','CREATE_GMS_SUM_LINES');
     p_return_status := fnd_api.g_ret_sts_unexp_error;

 END;

----------------------------- GMS INTERFACE ---------------------------------------------
 PROCEDURE transfer_to_gms_interface(p_adj_sum_batch_name      IN VARCHAR2,
				     p_business_group_id	IN NUMBER,
				     p_set_of_books_id		IN NUMBER,
                                     p_return_status  OUT NOCOPY VARCHAR2) IS

   CURSOR pc_batch_cur IS
   SELECT distinct batch_name
   FROM   psp_payroll_controls
   WHERE  adj_sum_batch_name = p_adj_sum_batch_name
   AND    source_type = 'A'
   AND    (dist_dr_amount IS NOT NULL OR dist_cr_amount IS NOT NULL)
   AND    gms_phase = 'Summarize_GMS_Lines'
   AND    status_code = 'I'
   AND	  business_group_id = p_business_group_id
   AND	  set_of_books_id = p_set_of_books_id
   AND    run_id = nvl(g_run_id, run_id);

   pc_batch_rec		pc_batch_cur%ROWTYPE;

   CURSOR gms_batch_cursor(p_batch_name IN VARCHAR2) IS
   SELECT payroll_control_id,
          source_type,
          payroll_source_code,
          time_period_id,
          batch_name,
--	Introduced the following for bug fix 2916848
	  currency_code
   FROM   psp_payroll_controls
   WHERE  batch_name = p_batch_name
   AND    source_type = 'A'
   AND    (dist_dr_amount IS NOT NULL OR dist_cr_amount IS NOT NULL)
   AND    gms_phase = 'Summarize_GMS_Lines'
   AND    status_code = 'I'
   AND    run_id = g_run_id;


   CURSOR gms_interface_cursor(P_PAYROLL_CONTROL_ID  IN  NUMBER) IS
   SELECT psl.summary_line_id,
          psl.source_code,
          psl.person_id,
          psl.assignment_id,
          NVL(psl.gms_posting_effective_date,psl.effective_date) effective_date, /* Bug: 1994421 Column modified for Enhancement Employee Assignment with Zero Work Days */
          psl.accounting_date, --- 3108109
          psl.exchange_rate_type,
          psl.project_id,
          psl.expenditure_organization_id,
          psl.expenditure_type,
          psl.task_id,
          psl.award_id,
          psl.summary_amount,
          psl.dr_cr_flag,
          psl.attribute1,			-- Introduced attributes 1, 4 * 5 for bug fix 29098859
          psl.attribute2,
          psl.attribute3,
          psl.attribute4,
          psl.attribute5,
          psl.attribute6,
          psl.attribute7,
          psl.attribute8,
          psl.attribute9,
          psl.attribute10,
		  org_id			-- R12 MOAC uptake
   FROM  psp_summary_lines  psl
   WHERE psl.status_code = 'N'
   AND   psl.gl_code_combination_id IS NULL
   AND   psl.payroll_control_id = p_payroll_control_id;

-- Included the following cursors for bug fix 1765678
   CURSOR	transaction_source_cur IS
   SELECT	transaction_source
   FROM		pa_transaction_sources
   WHERE	transaction_source = 'OLD';

   CURSOR	site_transaction_source_cur IS
   SELECT	transaction_source
   FROM		pa_transaction_sources
   WHERE	transaction_source = 'GOLD';

   gms_batch_rec		gms_batch_cursor%ROWTYPE;
   gms_interface_rec		gms_interface_cursor%ROWTYPE;
   l_transaction_source		VARCHAR2(30);
   l_expenditure_comment	VARCHAR2(240);
   l_employee_number		VARCHAR2(30);
   l_org_name			hr_all_organization_units_tl.name%TYPE;	-- Bug 2447912: Modified declaration
   l_segment1			VARCHAR2(25);
   l_task_number		VARCHAR2(25);
   l_gms_batch_name		VARCHAR2(10);

   -- Bug 6902514  -- change
   l_gms_stat_batch_name	VARCHAR2(10); -- Bug 6902514
   l_stat_count			NUMBER;       -- Bug 6902514
   l_not_stat_count		NUMBER;	      -- Bug 6902514


   l_expenditure_ending_date	DATE;
   l_period_name		VARCHAR2(35);
   l_period_end_date		DATE;
   l_return_status              VARCHAR2(50);  --- increased the size from 10 for WVU bug 2671594
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
	l_msg_id	number(9);
   l_batch_cnt			NUMBER(9) := 0;
   l_org_id			NUMBER(15);
   l_gms_transaction_source	VARCHAR2(30);
   l_txn_source			VARCHAR2(30);
   gms_rec			gms_transaction_interface_all%ROWTYPE;
   l_txn_interface_id		number(15);
   l_person_name		VARCHAR2(240); -- Included for bug fix 1828519
	l_gms_install		BOOLEAN	DEFAULT gms_install.enabled;		-- Introduced for bug fix 2908859

-- Included the following cursor here for acessing local variables for bug fix 1765678
   CURSOR	time_period_cur IS
   SELECT	period_name, end_date
   FROM		per_time_periods
   WHERE	time_period_id = gms_batch_rec.time_period_id;

   CURSOR	employee_cur IS
   SELECT	employee_number
   FROM		per_people_f
   WHERE	person_id = gms_interface_rec.person_id
   AND		gms_interface_rec.effective_date BETWEEN effective_start_date AND effective_end_date;

   CURSOR	task_number_cur IS
   SELECT	task_number
   FROM		pa_tasks
   WHERE	task_id = gms_interface_rec.task_id;

   CURSOR	emp_org_name_cur IS
   SELECT	name					--	Bug 2447912: Removed SUBSTR function
   FROM		hr_all_organization_units hou
   WHERE	organization_id = gms_interface_rec.expenditure_organization_id;

   CURSOR	project_number_cur IS
   SELECT	segment1, org_id
   FROM		pa_projects_all
   WHERE 	project_id = gms_interface_rec.project_Id;

-- Included the following cursor for bug fix 1828519
   CURSOR	employee_name_cur IS
   SELECT	full_name
   FROM		per_people_f ppf
   WHERE	ppf.person_id = (SELECT	pal.person_id
				FROM	psp_adjustment_lines pal
				WHERE	pal.payroll_control_id = gms_batch_rec.payroll_control_id
                                 AND    rownum = 1); -- Bug 2133056 Replaced batch_name with payroll_control_id and removed DISTINCT
--   WHERE	ppf.person_id = gms_interface_cur.person_id; Commented this cond. as part of 1828519

--	Introduced the following for bug fix 4507892
TYPE t_number_15_type IS TABLE OF NUMBER(15) INDEX BY BINARY_INTEGER;
TYPE payroll_control_rec IS RECORD (payroll_control_id	t_number_15_type);
r_payroll_controls	payroll_control_rec;

CURSOR	payroll_control_id_cur IS
SELECT	DISTINCT payroll_control_id
FROM	psp_summary_lines
WHERE	gms_batch_name = l_gms_batch_name;
--	End of changes for bug fix 4507892

-- R12 MOAC Uptake

	TYPE org_id_type IS TABLE OF NUMBER(15) INDEX BY BINARY_INTEGER;
    org_id_tab  org_id_type;

   TYPE gms_batch_name_type IS TABLE OF varchar2(10) INDEX BY BINARY_INTEGER;
    gms_batch_name_tab gms_batch_name_type;

 	TYPE req_id_type IS TABLE OF 	NUMBER(15) INDEX BY BINARY_INTEGER;
    req_id_tab req_id_type;

    TYPE call_status_type IS TABLE OF BOOLEAN INDEX BY BINARY_INTEGER;
    call_status_tab call_status_type;

   CURSOR operating_unit_csr IS
   SELECT distinct org_id
   FROM   psp_payroll_controls ppc,
   psp_summary_lines  psl
   WHERE  ppc.payroll_control_id = psl.payroll_control_id
   AND    ppc.adj_sum_batch_name = p_adj_sum_batch_name
   AND    ppc.source_type = 'A'
   AND    (ppc.dist_dr_amount IS NOT NULL OR ppc.dist_cr_amount IS NOT NULL)
   AND    ppc.gms_phase = 'Summarize_GMS_Lines'
   AND    ppc.status_code = 'I'
   AND	  ppc.business_group_id = p_business_group_id
   AND	  ppc.set_of_books_id = p_set_of_books_id
   AND    run_id = nvl(g_run_id, run_id)
   AND	  psl.status_code = 'N'
   AND    psl.gl_code_combination_id IS NULL;

 BEGIN
   -- get the source name
-- Replaced the earlier 'select stmt.' code with new 'cursor' code for bug fix 1765678
     OPEN transaction_source_cur;
     FETCH transaction_source_cur INTO l_transaction_source;
     IF (transaction_source_cur%NOTFOUND) THEN
        CLOSE transaction_source_cur;
        l_error := 'TRANSACTION SOURCE = OLD';
        l_product := 'GMS';
        fnd_message.set_name('PSP','PSP_TR_NOT_SET_UP');
        fnd_message.set_token('ERROR',l_error);
        fnd_message.set_token('PRODUCT',l_product);
        fnd_msg_pub.add;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;
     CLOSE transaction_source_cur;

   -- get the gms source name
   if (l_gms_install) then		-- replaced site-enabled call with l_gms_install as part of bug fix 2908859
   BEGIN
-- Replaced the earlier 'select stmt.' code with new 'cursor' code for bug fix 1765678

     OPEN site_transaction_source_cur;
     FETCH site_transaction_source_cur INTO l_gms_transaction_source;
     IF (site_transaction_source_cur%NOTFOUND) THEN
        CLOSE site_transaction_source_cur;
        l_error := 'TRANSACTION SOURCE = OLD';
        l_product := 'GMS';
        fnd_message.set_name('PSP','PSP_TR_NOT_SET_UP');
        fnd_message.set_token('ERROR',l_error);
        fnd_message.set_token('PRODUCT',l_product);
        fnd_msg_pub.add;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;
     CLOSE site_transaction_source_cur;
   END;
   end if;

-- R12 MOAC Uptake
	OPEN operating_unit_csr;
	FETCH operating_unit_csr BULK COLLECT INTO org_id_tab;
	CLOSE operating_unit_csr;

	FOR i in 1..org_id_tab.count
	LOOP
		SELECT 	to_char(psp_gms_batch_name_s.nextval)
		INTO 	gms_batch_name_tab(i)
		FROM 	dual;
	END LOOP;
/*
-- get the gms_batch_name for the summary batch
   SELECT	to_char(psp_gms_batch_name_s.nextval)
   INTO		l_gms_batch_name
   FROM		DUAL;
*/
   OPEN pc_batch_cur;
   LOOP
   FETCH pc_batch_cur into pc_batch_rec;
     IF pc_batch_cur%NOTFOUND THEN
       CLOSE pc_batch_cur;
       EXIT;
     END IF;

   OPEN gms_batch_cursor(pc_batch_rec.batch_name);
   LOOP
     FETCH gms_batch_cursor INTO gms_batch_rec;
     IF gms_batch_cursor%NOTFOUND THEN
       CLOSE gms_batch_cursor;
       EXIT;
     END IF;

   l_batch_cnt := l_batch_cnt + 1;

-- R12 MOAC Uptake. Moved this code to loop
    FOR I in 1..org_id_tab.count
	LOOP
		 UPDATE psp_summary_lines
		 SET gms_batch_name = gms_batch_name_tab(i)                   --  l_gms_batch_name
		 WHERE payroll_control_id = gms_batch_rec.payroll_control_id
		 AND   status_code = 'N'
		 AND   gl_code_combination_id IS NULL
		 AND    org_id = org_id_tab(i);			-- R12 MOAC uptake
	END LOOP;

	FOR i in 1..org_id_tab.count
	LOOP
		 -- update psp_summary_lines with gms batch name
		 UPDATE psp_summary_lines
		 SET gms_batch_name = gms_batch_name_tab(i)                   --  l_gms_batch_name
		 WHERE payroll_control_id = gms_batch_rec.payroll_control_id
		 AND   status_code = 'N'
		 AND   gl_code_combination_id IS NULL
		 AND    org_id = org_id_tab(i);			-- R12 MOAC uptake
	END LOOP;

     -- get the period_name
-- Replaced the earlier 'select stmt.' code with new 'cursor' code for bug fix 1765678

      OPEN time_period_cur;
      FETCH time_period_cur INTO l_period_name, l_period_end_date;
      IF (time_period_cur%NOTFOUND) THEN
         CLOSE time_period_cur;
--	Included the following code for bug fix 1828519
	 OPEN employee_name_cur;
	 FETCH employee_name_cur INTO l_person_name;
	 CLOSE employee_name_cur;
--	End of bug fix 1828519
         l_value := 'Time Period Id = '||to_char(gms_batch_rec.time_period_id);
         l_table := 'PER_TIME_PERIODS';
         fnd_message.set_name('PSP','PSP_TR_VALUE_NOT_FOUND');
         fnd_message.set_token('VALUE',l_value);
         fnd_message.set_token('TABLE',l_table);
         fnd_message.set_token('BATCH_NAME',pc_batch_rec.batch_name); -- Included for bug fix 1828519
         fnd_message.set_token('PERSON_NAME',l_person_name); -- Included for bug fix 1828519
         fnd_msg_pub.add;
--	Commented the following code for bug fix 1828519
--	 get_the_batch_details(pc_batch_rec.batch_name, l_return_status);
--	 fnd_msg_pub.add;
	 cleanup_batch_details(gms_batch_rec.payroll_control_id,null);
	 close gms_batch_cursor;
	 l_batch_cnt := l_batch_cnt - 1;
	 exit;
      END IF;
      CLOSE time_period_cur;

     l_expenditure_comment := gms_batch_rec.source_type || ':' || gms_batch_rec.payroll_source_code
				|| ':' || l_period_name || ':' || gms_batch_rec.batch_name;

     OPEN gms_interface_cursor(gms_batch_rec.payroll_control_id);
     l_rec_count := 0;
     LOOP
       FETCH gms_interface_cursor INTO gms_interface_rec;
       IF gms_interface_cursor%NOTFOUND THEN
--	  if (l_rec_count > 0) then
--     		UPDATE psp_payroll_controls
--        	   SET gms_phase = 'Transfer_GMS_Lines'
--      		WHERE payroll_control_id = gms_batch_rec.payroll_control_id;
--	  end if;
         CLOSE gms_interface_cursor;
         EXIT;
       END IF;

       -- get the employee number
-- Replaced the earlier 'select stmt.' code with new 'cursor' code for bug fix 1765678

         OPEN employee_cur;
         FETCH employee_cur INTO l_employee_number;
         IF (employee_cur%NOTFOUND)THEN
           CLOSE employee_cur;
           l_value := 'Person Id = '||to_char(gms_interface_rec.person_id);
           l_table := 'PER_PEOPLE_F';
--	Included the following code for bug fix 1828519
	   l_person_name := 'PERSON ID NOT FOUND';
--	End of bug fix 1828519
           fnd_message.set_name('PSP','PSP_TR_VALUE_NOT_FOUND');
           fnd_message.set_token('VALUE',l_value);
           fnd_message.set_token('TABLE',l_table);
           fnd_message.set_token('BATCH_NAME',pc_batch_rec.batch_name); --Included for bug fix 1828519
           fnd_message.set_token('PERSON_NAME',l_person_name); --Included for bug fix 1828519
           fnd_msg_pub.add;
	   l_batch_cnt := l_batch_cnt - 1;
--	Commented the following message as part of bug fix 1828519
--	   fnd_message.set_name('PSP', 'PSP_ADJ_GMS_FAILED');
--	   fnd_message.set_token('ERR_NAME', 'PERSON ID NOT FOUND');
--	   get_the_batch_details(pc_batch_rec.batch_name, l_return_status);
--	   fnd_msg_pub.add;
	   cleanup_batch_details(gms_batch_rec.payroll_control_id,null);
	   close gms_interface_cursor;
	   exit;
         END IF;
         CLOSE employee_cur;

       -- get the employee's organization name
-- Replaced the earlier 'select stmt.' code with new 'cursor' code for bug fix 1765678

         OPEN emp_org_name_cur;
         FETCH emp_org_name_cur INTO l_org_name;
         IF (emp_org_name_cur%NOTFOUND) THEN
           CLOSE emp_org_name_cur;
--	Included the following code for bug fix 1828519
	   OPEN employee_name_cur;
	   FETCH employee_name_cur INTO l_person_name;
	   CLOSE employee_name_cur;
--	End of bug fix 1828519
           l_value := 'Organization Id = '||to_char(gms_interface_rec.expenditure_organization_id);
           l_table := 'HR_ORGANIZATION_UNITS';
           fnd_message.set_name('PSP','PSP_TR_VALUE_NOT_FOUND');
           fnd_message.set_token('VALUE',l_value);
           fnd_message.set_token('TABLE',l_table);
           fnd_message.set_token('BATCH_NAME',pc_batch_rec.batch_name); -- Included for bug fix 1828519
           fnd_message.set_token('PERSON_NAME',l_person_name); -- Included for bug fix 1828519
           fnd_msg_pub.add;
	   l_batch_cnt := l_batch_cnt - 1;
--	Commented the following message as part of bug fix 1828519
--	   fnd_message.set_name('PSP', 'PSP_ADJ_GMS_FAILED');
--	   fnd_message.set_token('ERR_NAME', 'ORGANIZATION NOT FOUND');
--	   get_the_batch_details(pc_batch_rec.batch_name, l_return_status);
--	   fnd_msg_pub.add;
	   cleanup_batch_details(gms_batch_rec.payroll_control_id,null);
	   close gms_interface_cursor;
	   exit;
       END IF;
       CLOSE emp_org_name_cur;

       -- get the project number
-- Replaced the earlier 'select stmt.' code with new 'cursor' code for bug fix 1765678

       OPEN project_number_cur;
       FETCH project_number_cur INTO l_segment1, l_org_id;
       IF (project_number_cur%NOTFOUND) THEN
          CLOSE project_number_cur;
--	Included the following code for bug fix 1828519
	   OPEN employee_name_cur;
	   FETCH employee_name_cur INTO l_person_name;
	   CLOSE employee_name_cur;
--	End of bug fix 1828519
           l_value := 'Project Id = '||to_char(gms_interface_rec.project_Id);
           l_table := 'PA_PROJECTS_ALL';
           fnd_message.set_name('PSP','PSP_TR_VALUE_NOT_FOUND');
           fnd_message.set_token('VALUE',l_value);
           fnd_message.set_token('TABLE',l_table);
           fnd_message.set_token('BATCH_NAME',pc_batch_rec.batch_name); -- Included for bug fix 1828519
           fnd_message.set_token('PERSON_NAME',l_person_name); -- Included for bug fix 1828519
           fnd_msg_pub.add;
	   l_batch_cnt := l_batch_cnt - 1;
--	Commented the following message as part of bug fix 1828519
--	   fnd_message.set_name('PSP', 'PSP_ADJ_GMS_FAILED');
--	   fnd_message.set_token('ERR_NAME', 'ORGANIZATION NOT FOUND');
--	   get_the_batch_details(pc_batch_rec.batch_name, l_return_status);
--	   fnd_msg_pub.add;
	   cleanup_batch_details(gms_batch_rec.payroll_control_id,null);
	   close gms_interface_cursor;
	   exit;
       END IF;
       CLOSE project_number_cur;

       -- get the task number
-- Replaced the earlier 'select stmt.' code with new 'cursor' code for bug fix 1765678

         OPEN task_number_cur;
         FETCH task_number_cur INTO l_task_number;
         IF (task_number_cur%NOTFOUND) THEN
           CLOSE task_number_cur;
--	Included the following code for bug fix 1828519
	   OPEN employee_name_cur;
	   FETCH employee_name_cur INTO l_person_name;
	   CLOSE employee_name_cur;
--	End of bug fix 1828519
           l_value := 'Task Id = '||to_char(gms_interface_rec.task_id);
           l_table := 'PA_TASKS';
           fnd_message.set_name('PSP','PSP_TR_VALUE_NOT_FOUND');
           fnd_message.set_token('VALUE',l_value);
           fnd_message.set_token('TABLE',l_table);
           fnd_message.set_token('BATCH_NAME',pc_batch_rec.batch_name); -- Included for bug fix 1828519
           fnd_message.set_token('PERSON_NAME',l_person_name); -- Included for bug fix 1828519
           fnd_msg_pub.add;
	   l_batch_cnt := l_batch_cnt - 1;
--	Commented the following message as part of bug fix 1828519
--	   fnd_message.set_name('PSP', 'PSP_ADJ_GMS_FAILED');
--	   fnd_message.set_token('ERR_NAME', 'ORGANIZATION NOT FOUND');
--	   get_the_batch_details(pc_batch_rec.batch_name, l_return_status);
--	   fnd_msg_pub.add;
	   cleanup_batch_details(gms_batch_rec.payroll_control_id,null);
	   close gms_interface_cursor;
	   exit;
         END IF;
         CLOSE task_number_cur;

       l_rec_count := l_rec_count + 1;

     select pa_txn_interface_s.nextval
       into l_txn_interface_id
       from dual;

	-- set the context to single to call pa_utils function
	mo_global.set_policy_context('S', gms_interface_rec.org_id );

       l_expenditure_ending_date := pa_utils.GetWeekending(gms_interface_rec.effective_date);

	-- set the context again to multiple
	mo_global.set_policy_context('M', null);

        --- moved this code from below 2671594
--	if gms_interface_rec.award_id is not null then
	if (l_gms_install) then			-- Changed award_id check to gms_install check as part of bug fix 2908859
	   l_txn_source := l_gms_transaction_source;
	else
	   l_txn_source := l_transaction_source;
	end if;


	FOR i in 1..org_id_tab.count
	LOOP
		IF org_id_tab(i) = gms_interface_rec.org_id THEN
			l_gms_batch_name := gms_batch_name_tab(i);
		END IF;
	END LOOP;
		g_gms_batch_name := l_gms_batch_name; /* 1662816 */




--	Corrected currency code value, introduced acct_rate_type and acct_rate_date values for bug fix 2916848
IF (gms_batch_rec.currency_code <> 'STAT') THEN  -- code changes for bug 5167562
       insert_into_pa_interface(l_txn_interface_id,
	L_TXN_SOURCE,L_GMS_BATCH_NAME,L_EXPENDITURE_ENDING_DATE,
	L_EMPLOYEE_NUMBER,L_ORG_NAME,GMS_INTERFACE_REC.EFFECTIVE_DATE,
	L_SEGMENT1,L_TASK_NUMBER,GMS_INTERFACE_REC.EXPENDITURE_TYPE,
	1,GMS_INTERFACE_REC.SUMMARY_AMOUNT,L_EXPENDITURE_COMMENT,
	'P',GMS_INTERFACE_REC.SUMMARY_LINE_ID, GMS_INTERFACE_REC.ORG_ID,
--	GMS_INTERFACE_REC.AWARD_ID, GMS_INTERFACE_REC.ATTRIBUTE2,
--	gms_attr are sent to gms_interface
	gms_batch_rec.currency_code, GMS_INTERFACE_REC.SUMMARY_AMOUNT,
	gms_interface_rec.attribute1, gms_interface_rec.attribute2, GMS_INTERFACE_REC.ATTRIBUTE3,
	gms_interface_rec.attribute4, GMS_INTERFACE_REC.ATTRIBUTE5,
	GMS_INTERFACE_REC.ATTRIBUTE6,GMS_INTERFACE_REC.ATTRIBUTE7,
	GMS_INTERFACE_REC.ATTRIBUTE8,GMS_INTERFACE_REC.ATTRIBUTE9,
	GMS_INTERFACE_REC.ATTRIBUTE10, gms_interface_rec.exchange_rate_type,
        GMS_INTERFACE_REC.ACCOUNTING_DATE, --- 3108109
	p_business_group_id, -- Introduced for the Bug fix 2935850
	L_RETURN_STATUS);

       IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
             --- moved code ends
	ELSE
		insert_into_pa_interface(l_txn_interface_id,
			L_TXN_SOURCE,L_GMS_BATCH_NAME,L_EXPENDITURE_ENDING_DATE,
			L_EMPLOYEE_NUMBER,L_ORG_NAME,GMS_INTERFACE_REC.EFFECTIVE_DATE,
			L_SEGMENT1,L_TASK_NUMBER,GMS_INTERFACE_REC.EXPENDITURE_TYPE,
			GMS_INTERFACE_REC.SUMMARY_AMOUNT, 1, L_EXPENDITURE_COMMENT,
			'P',GMS_INTERFACE_REC.SUMMARY_LINE_ID, GMS_INTERFACE_REC.ORG_ID,
			gms_batch_rec.currency_code, GMS_INTERFACE_REC.SUMMARY_AMOUNT,
			gms_interface_rec.attribute1, gms_interface_rec.attribute2,
			GMS_INTERFACE_REC.ATTRIBUTE3, gms_interface_rec.attribute4,
			GMS_INTERFACE_REC.ATTRIBUTE5, GMS_INTERFACE_REC.ATTRIBUTE6,
			GMS_INTERFACE_REC.ATTRIBUTE7, GMS_INTERFACE_REC.ATTRIBUTE8,
			GMS_INTERFACE_REC.ATTRIBUTE9, GMS_INTERFACE_REC.ATTRIBUTE10,
			gms_interface_rec.exchange_rate_type,
			GMS_INTERFACE_REC.ACCOUNTING_DATE,
			p_business_group_id,
			L_RETURN_STATUS);

		IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;
	END IF;

	if gms_interface_rec.award_id is not null then

        GMS_REC.TXN_INTERFACE_ID 	    := l_txn_interface_id;
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
--	For a failed small batch spanning more than one payroll control id, Transaction import is kicked off,
--	Fixed this issue thru the following code along with bug fix 1828519
     IF (l_batch_cnt = 0) THEN
	CLOSE gms_batch_cursor;
	EXIT;
     END IF;
   END LOOP;
 END LOOP;

 IF l_batch_cnt > 0 THEN  -- change 6902514

    -- Bug 6902514 Start

        SELECT	to_char(psp_gms_batch_name_s.nextval)
       	INTO		l_gms_stat_batch_name
       	FROM		DUAL;

           UPDATE pa_transaction_interface_all
           SET  BATCH_NAME = l_gms_stat_batch_name
           where DENOM_CURRENCY_CODE = 'STAT'
          	  and BATCH_NAME = l_gms_batch_name
    	  and TRANSACTION_SOURCE = l_txn_source;


           UPDATE psp_summary_lines
           SET gms_batch_name = l_gms_stat_batch_name
           WHERE payroll_control_id IN(select payroll_control_id from psp_payroll_controls
               			   where run_id = g_run_id
         				   and currency_code = 'STAT')
            AND gms_batch_name = l_gms_batch_name
            AND   status_code = 'N'
            AND   gl_code_combination_id IS NULL;



            SELECT count(*) INTO l_not_stat_count
            FROM pa_transaction_interface_all
            WHERE BATCH_NAME = l_gms_batch_name;

            fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) ||'l_gms_batch_name'||l_gms_batch_name);
            fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) ||'l_gms_stat_batch_name'||l_gms_stat_batch_name);
            fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) ||'l_not_stat_count'||l_not_stat_count);




       IF l_not_stat_count<>0 THEN


	FOR I in 1..org_id_tab.count
	LOOP
		l_gms_batch_name := gms_batch_name_tab(I);

	-- set the context to single to submit_request
	mo_global.set_policy_context('S', org_id_tab(I) );
	fnd_request.set_org_id (org_id_tab(I) );

	     req_id_tab(i) := 	fnd_request.submit_request(
                                 'PA',
                                 'PAXTRTRX',
                                 NULL,
                                 NULL,
                                 FALSE,
                                 l_txn_source, ----l_transaction_source,
                                 l_gms_batch_name);

		 IF req_id = 0 THEN
		   fnd_message.set_name('PSP','PSP_TR_GMS_IMP_FAILED');
		   fnd_msg_pub.add;
		   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

		END IF;
	 END LOOP;


		OPEN payroll_control_id_cur;
		FETCH payroll_control_id_cur BULK COLLECT INTO r_payroll_controls.payroll_control_id;
		CLOSE payroll_control_id_cur;

		FORALL I IN 1..r_payroll_controls.payroll_control_id.COUNT
		UPDATE	psp_payroll_controls
		SET	gms_phase = 'Submitted_Import_Request'
		WHERE	payroll_control_id = r_payroll_controls.payroll_control_id(I);
		Commit;

		r_payroll_controls.payroll_control_id.DELETE;
	--	End of changes for bug fix 4507892

	-- set the context again to multiple
	mo_global.set_policy_context('M', null);


		FOR I in 1..org_id_tab.count
		LOOP
		   call_status_tab(i) := fnd_concurrent.wait_for_request(req_id_tab(i), 20, 0,
					rphase, rstatus, dphase, dstatus, message);

		   IF call_status = FALSE then
			 fnd_message.set_name('PSP','PSP_TR_GMS_IMP_FAILED');
			 fnd_msg_pub.add;
			 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

		   END IF;
		END LOOP;

	END IF; -- l_not_stat_count


	SELECT count(*) INTO l_stat_count   -- change
	               FROM pa_transaction_interface_all
           WHERE BATCH_NAME = l_gms_stat_batch_name;

        g_skip_flag_gms := 'N';

       l_gms_batch_name := l_gms_stat_batch_name;


	IF l_stat_count <> 0 THEN

	g_skip_flag_gms := 'Y';

	IF (g_create_stat_batch_in_gms = 'Y') THEN
             fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) ||'STAT entrance');

	g_skip_flag_gms := 'N';

	FOR I in 1..org_id_tab.count
		LOOP
			l_gms_batch_name := gms_batch_name_tab(I);

		-- set the context to single to submit_request
		mo_global.set_policy_context('S', org_id_tab(I) );
		fnd_request.set_org_id (org_id_tab(I) );

		     req_id_tab(i) := 	fnd_request.submit_request(
	                                 'PA',
	                                 'PAXTRTRX',
	                                 NULL,
	                                 NULL,
	                                 FALSE,
	                                 l_txn_source, ----l_transaction_source,
	                                 l_gms_batch_name);

			 IF req_id = 0 THEN
			   fnd_message.set_name('PSP','PSP_TR_GMS_IMP_FAILED');
			   fnd_msg_pub.add;
			   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

			END IF;
	 END LOOP;

	END IF; -- g_create_stat_batch_in_gms

	OPEN payroll_control_id_cur;
			FETCH payroll_control_id_cur BULK COLLECT INTO r_payroll_controls.payroll_control_id;
			CLOSE payroll_control_id_cur;

			FORALL I IN 1..r_payroll_controls.payroll_control_id.COUNT
			UPDATE	psp_payroll_controls
			SET	gms_phase = 'Submitted_Import_Request'
			WHERE	payroll_control_id = r_payroll_controls.payroll_control_id(I);
			Commit;

			r_payroll_controls.payroll_control_id.DELETE;
		--	End of changes for bug fix 4507892

		-- set the context again to multiple
	mo_global.set_policy_context('M', null);

	IF g_skip_flag_gms = 'N' then

	    		FOR I in 1..org_id_tab.count
	   		LOOP
	   		   call_status_tab(i) := fnd_concurrent.wait_for_request(req_id_tab(i), 20, 0,
	   					rphase, rstatus, dphase, dstatus, message);

	   		   IF call_status = FALSE then
	   			 fnd_message.set_name('PSP','PSP_TR_GMS_IMP_FAILED');
	   			 fnd_msg_pub.add;
	   			 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

	   		   END IF;
	   		END LOOP;

	END IF; -- g_skip_flag_gms




	END IF; -- l_stat_count


END IF; -- l_batch_cnt -- end of changes for 6902514

   p_return_status := fnd_api.g_ret_sts_success;
 EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     g_error_api_path := 'TRANSFER_TO_GMS_INTERFACE:'||g_error_api_path;
 --Bug 1776606 : Building error Stack
    fnd_msg_pub.add_exc_msg('PSP_SUM_ADJ','TRANSFER_TO_GMS_INTERFACE');
     p_return_status := fnd_api.g_ret_sts_unexp_error;

   WHEN OTHERS THEN
     g_error_api_path := 'TRANSFER_TO_GMS_INTERFACE:'||g_error_api_path;
     fnd_msg_pub.add_exc_msg('PSP_SUM_ADJ','TRANSFER_TO_GMS_INTERFACE');
     p_return_status := fnd_api.g_ret_sts_unexp_error;
 END;

------------------------- GMS TIE BACK ---------------------------------------------------
/*  We want to maintain the control at the adjustment batch level.
    For the super batch, for each payroll control id check the results.
    If there are any rejects for a given adjustment batch, then clean up the tables.
    If the whole adj batch is accepted, then move them to the history.
*/

 PROCEDURE gms_tie_back(p_adj_sum_batch_name   IN  VARCHAR2,
			p_business_group_id	IN NUMBER,
			p_set_of_books_id	IN NUMBER,
                        p_return_status	   OUT NOCOPY  VARCHAR2) IS

   CURSOR pc_batch_cur IS
   SELECT distinct batch_name
   FROM   psp_payroll_controls
   WHERE  adj_sum_batch_name = p_adj_sum_batch_name
   AND    (dist_dr_amount is not null and dist_cr_amount is not null)
   AND    source_type = 'A'
   AND    status_code = 'I'
   AND    gms_phase = 'Submitted_Import_Request'
   AND	  business_group_id = p_business_group_id
   AND	  set_of_books_id = p_set_of_books_id
   AND    run_id = nvl(g_run_id, run_id);

   pc_batch_rec		pc_batch_cur%ROWTYPE;

   CURSOR gms_tie_back_cur(p_batch_name IN VARCHAR2) IS
   SELECT payroll_control_id,
          source_type,
          payroll_source_code,
          time_period_id,
          batch_name,
          currency_code -- 6902514
   FROM   psp_payroll_controls
   WHERE  batch_name = p_batch_name
   AND    (dist_dr_amount is not null and dist_cr_amount is not null)
   AND    source_type = 'A'
   AND    status_code = 'I'
   AND    gms_phase = 'Submitted_Import_Request'
   AND    run_id = nvl(g_run_id, run_id);

 gms_tie_back_rec	gms_tie_back_cur%ROWTYPE;

   CURSOR gms_tie_back_success_cur(p_gms_batch_name number, p_payroll_control_id number) IS
   SELECT summary_line_id,
          dr_cr_flag,summary_amount
   FROM   psp_summary_lines
   WHERE  gms_batch_name = p_gms_batch_name
   AND	  payroll_control_id = p_payroll_control_id;


   CURSOR gms_tie_back_reject_cur(p_gms_batch_name number, p_payroll_control_id number, p_txn_src varchar2) IS
   SELECT nvl(transaction_rejection_code,'P'),
          orig_transaction_reference,
          transaction_status_code
   FROM   pa_transaction_interface_all
   WHERE  batch_name = to_char(p_gms_batch_name)
   AND	  transaction_status_code in ('R', 'PO', 'PI', 'PR')
   AND	  transaction_source = p_txn_src
   AND	  orig_transaction_reference in
	 (select to_char(summary_line_id)
	    from psp_summary_lines
	   where payroll_control_id = p_payroll_control_id
	     and gms_batch_name = p_gms_batch_name);

l_orig_org_name1	hr_all_organization_units_tl.name%TYPE;	-- Bug 2447912: Modified declaration
l_orig_org_id1		number;

   l_organization_name		hr_all_organization_units_tl.name%TYPE;	-- Bug 2447912: Modified declaration
   l_organization_id		NUMBER(15);
   l_rowid				ROWID;
   l_assignment_id		NUMBER(9);
   l_distribution_date		DATE;
   l_suspense_org_account_id  	NUMBER(9);
   --
   l_organization_account_id	NUMBER(9);
   l_gl_code_combination_id   	NUMBER(15);
   l_project_id			NUMBER(15);
   l_award_id			NUMBER(15);
   l_task_id			NUMBER(15);
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
   l_trx_status_code          	VARCHAR2(1);
   l_trx_reject_code		VARCHAR2(30);
   l_orig_trx_reference		VARCHAR2(30);
   l_effective_date		DATE;

   x_susp_failed_org_name	hr_all_organization_units_tl.name%TYPE;	-- Bug 2447912: Modified declaration
   x_susp_failed_reject_code	VARCHAR2(30);
   x_susp_failed_date		DATE;
   x_susp_nf_org_name		hr_all_organization_units_tl.name%TYPE;	-- Bug 2447912: Modified declaration
   x_susp_nf_date		DATE;
   l_return_status		VARCHAR2(10);
   l_msg_id			number(9);
   x_update_count		number(9);
   x_insert_count		number(9);
   x_delete_count		number(9);
   l_dist_line_id1		number(9);
   l_gms_batch_name		number(15);
   l_gms_batch_name1		varchar2(10);                            --Bug 6118274
--
   l_adjustment_batch_name      varchar2(50);
   l_person_id			number;
   l_person_name		varchar2(80);
--   l_assignment_id		number;
   l_assignment_number		number;
   l_element_type_id		number;
---   l_element_name		varchar2(80);
   l_distribution_start_date	date;
   l_distribution_end_date	date;
   l_trx_rejection_code		varchar2(80);
   l_no_run			number := 0;
   l_status_i			number := 0;
   l_transaction_source		varchar2(40);
   TI_DID_NOT_COMPLETE		EXCEPTION;
   l_control_id			number;
   l_txn_source			varchar2(30);


-- the following cursors are included here for accessing the local variables for bug fix 1765678
   CURSOR	gms_batch_name_cur IS
   SELECT	DISTINCT gms_batch_name
   FROM		psp_summary_lines
   WHERE	payroll_control_id = gms_tie_back_rec.payroll_control_id
   AND		gms_batch_name IS NOT NULL;

   CURSOR	transaction_source_cur IS
   SELECT	transaction_source
   FROM		pa_transaction_interface_all
   WHERE	batch_name = TO_CHAR(l_gms_batch_name);

   CURSOR	cnt_gms_interface_cur IS
   SELECT	count(*)
   FROM		pa_transaction_interface_all
   WHERE	batch_name = TO_CHAR(l_gms_batch_name)
   AND		transaction_source = l_txn_source
   AND		transaction_status_code IN ('R', 'PO', 'PI', 'PR')
   AND		orig_transaction_reference IN	(SELECT	TO_CHAR(summary_line_id)
						FROM	psp_summary_lines
						WHERE	payroll_control_id = gms_tie_back_rec.payroll_control_id
						AND	gms_batch_name = l_gms_batch_name);
 FUNCTION PROCESS_COMPLETE RETURN BOOLEAN IS

   cursor get_completion is
   select count(*), transaction_status_code
     from pa_transaction_interface_all
    where batch_name = to_char(l_gms_batch_name)
      and transaction_source = l_txn_source
      and transaction_status_code in ('P', 'I')
    group by transaction_status_code  ;

  get_completion_rec	get_completion%ROWTYPE;
 --- Bug 2133056, purge the PA Side items, if PA post import user extension failed.
   CURSOR  group_name_cur IS
         select expenditure_group
                from pa_expenditures_all
                where expenditure_id in
                     (select expenditure_id
                      from pa_transaction_interface_all
                      where transaction_source in ('OLD', 'GOLD') and
                            transaction_rejection_code is null and
                            batch_name = l_gms_batch_name )
               and expenditure_group is not null;

    l_exp_group_name varchar2(20) := NULL;
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

   if get_completion_rec.transaction_status_code = 'P' then

-- -------------------------------------------------------------------------------------------
-- If transaction_status_code = 'P' then the transaction import process did not kick off
-- for some reason. Return 'NOT_RUN' in this case. So cleanup the tables and try to transfer
-- again after summarization in the second pass.
-- -------------------------------------------------------------------------------------------

     delete from pa_transaction_interface_all
      where batch_name = to_char(l_gms_batch_name)
	and transaction_source = l_txn_source;

     if (l_txn_source = 'GOLD') then
     delete from gms_transaction_interface_all
      where batch_name = to_char(l_gms_batch_name)
	and transaction_source = 'GOLD';
    end if;

     /* Commented for 2133056, Let recover start from Import and not Summarize
     delete from psp_summary_lines
      where gms_batch_name = l_gms_batch_name
	and payroll_control_id = gms_tie_back_rec.payroll_control_id;
     */
     -- Added following update for 2133056
     update psp_payroll_controls
       set gms_phase = 'Summarize_GMS_Lines'
     where gms_phase is not null
      and  adj_sum_batch_name = p_adj_sum_batch_name;

      commit;
      return false;
   elsif get_completion_rec.transaction_status_code = 'I' then

-- -------------------------------------------------------------------------------------------
-- If transaction_status_code = 'I' then the transaction import process did not complete
-- the Post Processing extension. So return 'NOT_COMPLETE' in this case.
-- In this case purging the GMS/PA side expenditures, and resetting the payroll control recs
-- to fresh, so that user can run the Restart Adj S and T process.
-- -------------------------------------------------------------------------------------------
    /* Added the delete statements for EXP, EXP items, EXP groups etc for bug 2133056 */
     OPEN group_name_cur;
     FETCH group_name_cur into l_exp_group_name ;
     CLOSE group_name_cur;

     if l_exp_group_name is not null then

       delete gms_award_distributions
         where  document_type = 'EXP'
           and  expenditure_item_id in
            ( select expenditure_item_id
              from pa_expenditure_items_all
              where transaction_source = 'GOLD'
                and expenditure_id in
               (select expenditure_id
                from  pa_expenditures_all
                where expenditure_group = l_exp_group_name));

        delete pa_expenditure_items_all
         where transaction_source in ('OLD','GOLD')
           and expenditure_id in
              (select expenditure_id
               from pa_expenditures_all
               where expenditure_group = l_exp_group_name);

        delete pa_expenditures_all
               where expenditure_group = l_exp_group_name;

        delete pa_expenditure_Groups_all
         where expenditure_group = l_exp_group_name;
     end if;

      if (l_txn_source = 'GOLD') then
         delete gms_transaction_interface_all
           where transaction_source in ('GOLD') and
                 batch_name = l_gms_batch_name;
      end if;

         delete pa_transaction_interface_all
          where transaction_source in ('GOLD','OLD') and
                 batch_name = l_gms_batch_name;

         delete psp_summary_lines
         where payroll_control_id in
         (select payroll_control_id
          from psp_payroll_controls
          where source_type = 'A'
            and adj_sum_batch_name = p_adj_sum_batch_name);

       update psp_payroll_controls
       set gms_phase = null
       where gms_phase is not null
        and source_type = 'A'
        and  adj_sum_batch_name = p_adj_sum_batch_name;

      commit;
      return false;


   end if;

   end loop;

 exception
 when others then
      fnd_msg_pub.add_exc_msg('PSP_SUM_ADJ','GET_PROCESS');
   return FALSE;
 end PROCESS_COMPLETE;

 BEGIN

   open pc_batch_cur;
   loop
   fetch pc_batch_cur into pc_batch_rec;
   if pc_batch_cur%NOTFOUND then
      close pc_batch_cur;
      exit;
   end if;

  --dbms_output.put_line('Getting the batches..' || pc_batch_rec.batch_name);

  -- Added for bug 9481186
   IF gms_tie_back_cur%ISOPEN THEN
     close gms_tie_back_cur;
   END IF;

   open gms_tie_back_cur(pc_batch_rec.batch_name);
   loop
   fetch gms_tie_back_cur into gms_tie_back_rec;
   if gms_tie_back_cur%NOTFOUND then
     close gms_tie_back_cur;
     exit;
   end if;

  --dbms_output.put_line('Getting the payroll.. ' || to_char(gms_tie_back_rec.payroll_control_id));
-- Replaced the earlier 'select stmt.' code with new 'cursor' code for bug fix 1765678

   OPEN gms_batch_name_cur;
   LOOP
   FETCH gms_batch_name_cur INTO l_gms_batch_name;
   IF (gms_batch_name_cur%NOTFOUND) THEN
      CLOSE gms_batch_name_cur;
      EXIT;
   END IF;
--   CLOSE gms_batch_name_cur;

 hr_utility.trace('before userhook - l_gms_batch_name='||l_gms_batch_name);
 ----- new procedure for 5463110
 psp_st_ext.tieback_adjustment(gms_tie_back_rec.payroll_control_id,
                               pc_batch_rec.batch_name,
                               l_gms_batch_name ,
                               p_business_group_id,
                               p_set_of_books_id  );
   --fnd_file.put_line(fnd_file.log, 'after user hook');
   hr_utility.trace('after userhook - ');


   OPEN transaction_source_cur;
   FETCH transaction_source_cur INTO l_txn_source;
   IF (transaction_source_cur%NOTFOUND) THEN
      CLOSE transaction_source_cur;
      EXIT;
   END IF;
   CLOSE transaction_source_cur;


      IF ((gms_tie_back_rec.currency_code <> 'STAT') OR   -- 6902514
      		(gms_tie_back_rec.currency_code = 'STAT' and g_create_stat_batch_in_gms = 'Y')) THEN


	 if NOT PROCESS_COMPLETE then

                ----- changed message tag for bug 2133056
       		fnd_message.set_name('PSP','PSP_TR_GMS_IMP_FAILED');
       		fnd_msg_pub.add;
		close gms_tie_back_cur;
		CLOSE gms_batch_name_cur;
                RAISE TI_DID_NOT_COMPLETE;  --- Added this for Bug 2133056

         end if;

      END IF; -- gms_tie_back_rec.currency_code

-- Replaced the earlier 'select stmt.' code with new 'cursor' code for bug fix 1765678

   OPEN cnt_gms_interface_cur;
   FETCH cnt_gms_interface_cur INTO l_cnt_gms_interface;
   IF (cnt_gms_interface_cur%NOTFOUND) THEN
      CLOSE cnt_gms_interface_cur;
      EXIT;
   END IF;
   CLOSE cnt_gms_interface_cur;

  --dbms_output.put_line('Getting the count .. ' || to_char(l_cnt_gms_interface));

   IF l_cnt_gms_interface > 0 THEN
--	Commented the following loop for finding rejection reason code as part of bug fix 1828519
--     OPEN gms_tie_back_reject_cur(l_gms_batch_name, gms_tie_back_rec.payroll_control_id, l_txn_source);
--     LOOP
--       FETCH gms_tie_back_reject_cur INTO l_trx_reject_code,l_orig_trx_reference,l_trx_status_code;
--       IF gms_tie_back_reject_cur%NOTFOUND THEN
--         CLOSE gms_tie_back_reject_cur;
--         EXIT;
--       END IF;

--	   l_trx_rejection_code := l_trx_reject_code;
--     END LOOP;

	fnd_message.set_name('PSP','PSP_ADJ_GMS_FAILED');
--	Commented the following token as part of bug fix 1828519
--	fnd_message.set_token('ERR_NAME', l_trx_rejection_code);
	get_the_batch_details(pc_batch_rec.batch_name, l_return_status);
	fnd_msg_pub.add;
        /* 1685685  added update statement...to clean pa tables in cleanup_batch_details..Venkat.*/
        update psp_payroll_controls
          set gms_phase = 'GMS_Tie_Back'
        where payroll_control_id = gms_tie_back_rec.payroll_control_id;
	cleanup_batch_details(gms_tie_back_rec.payroll_control_id,null);
	close gms_tie_back_cur;
	CLOSE gms_batch_name_cur;
	exit;


   ELSIF l_cnt_gms_interface = 0 THEN

      l_gms_batch_name1 := l_gms_batch_name;	--Bug 6118274
      --- moved this stmnt from the loop below, and modified for 2445196.
      UPDATE psp_summary_lines  PSL
       SET (PSL.status_code, PSL.expenditure_ending_date,PSL.expenditure_id,
               PSL.interface_id,PSL.expenditure_item_id,PSL.txn_interface_id)  =
            (select 'A', PTXN.expenditure_ending_date,PTXN.expenditure_id,
               PTXN.interface_id,PTXN.expenditure_item_id,PTXN.txn_interface_id
             from pa_transaction_interface_all PTXN
             where PTXN.transaction_source = l_txn_source
               and PTXN.orig_transaction_reference= to_char(PSL.summary_line_id)
               and PTXN.batch_name = l_gms_batch_name1)
       WHERE PSL.gms_batch_name = l_gms_batch_name1;   --- changed g_gms_batch_name to l_gms_batch_name for 2444657


     OPEN gms_tie_back_success_cur(l_gms_batch_name, gms_tie_back_rec.payroll_control_id);
     l_dr_summary_amount := 0; --- Bug 2133056, initialized the amounts
     l_cr_summary_amount := 0;
     LOOP
  --dbms_output.put_line('Getting the success .. ' );
       l_control_id := gms_tie_back_rec.payroll_control_id;
       FETCH gms_tie_back_success_cur INTO l_summary_line_id,
        l_dr_cr_flag,l_summary_amount;

       IF gms_tie_back_success_cur%ROWCOUNT = 0 then
	  close gms_tie_back_success_cur;
	  exit;
       ELSIF gms_tie_back_success_cur%NOTFOUND THEN

   	  UPDATE psp_payroll_controls
      	     SET gms_phase = 'GMS_Tie_Back'
           WHERE payroll_control_id = l_control_id;

         CLOSE gms_tie_back_success_cur;
         EXIT;
       END IF;

       -- update records in psp_summary_lines as 'A' , moved this stmnt above for 2445196

       IF l_dr_cr_flag = 'D' THEN
         l_dr_summary_amount := l_dr_summary_amount + l_summary_amount;
       ELSIF l_dr_cr_flag = 'C' THEN
         l_cr_summary_amount := l_cr_summary_amount - l_summary_amount;
       END IF;

         UPDATE psp_adjustment_lines
         SET status_code = 'A' WHERE summary_line_id = l_summary_line_id;

         -- move the transferred records to psp_adjustment_lines_history
         INSERT INTO psp_adjustment_lines_history
         (adjustment_line_id,person_id,assignment_id,element_type_id,
          distribution_date,effective_date,distribution_amount,
          dr_cr_flag,payroll_control_id,source_type,source_code,time_period_id,
          batch_name,status_code,set_of_books_id,gl_code_combination_id,project_id,
          expenditure_organization_id,expenditure_type,task_id,award_id,
          suspense_org_account_id,suspense_reason_code,effort_report_id,version_num,
          summary_line_id, reversal_entry_flag, original_line_flag, user_defined_field, percent,
	  orig_source_type,
          orig_line_id,attribute_category,attribute1,attribute2,attribute3,attribute4,
          attribute5,attribute6,attribute7,attribute8,attribute9,attribute10,attribute11,
          attribute12,attribute13,attribute14,attribute15,last_update_date,
          last_updated_by,last_update_login,created_by,creation_date, business_group_id,
          adj_set_number, line_number)  ---   added cols 2634557 DA Multiple element Enh
         SELECT adjustment_line_id,person_id,assignment_id,element_type_id,
          distribution_date,effective_date,distribution_amount,
          dr_cr_flag,payroll_control_id,source_type,source_code,time_period_id,
          batch_name,status_code,set_of_books_id,gl_code_combination_id,project_id,
          expenditure_organization_id,expenditure_type,task_id,award_id,
          suspense_org_account_id,suspense_reason_code,effort_report_id,version_num,
          summary_line_id, reversal_entry_flag, original_line_flag, user_defined_field, percent,
 	  orig_source_type,
          orig_line_id,attribute_category,attribute1,attribute2,attribute3,attribute4,
          attribute5,attribute6,attribute7,attribute8,attribute9,attribute10,attribute11,
          attribute12,attribute13,attribute14,attribute15,SYSDATE,FND_GLOBAL.USER_ID,
          FND_GLOBAL.LOGIN_ID,FND_GLOBAL.USER_ID,SYSDATE, business_group_id,
          adj_set_number, line_number  ---   added cols 2634557 DA Multiple element Enh
         FROM psp_adjustment_lines
         WHERE status_code = 'A'
         AND summary_line_id = l_summary_line_id
	 AND payroll_control_id = gms_tie_back_rec.payroll_control_id;

         DELETE FROM psp_adjustment_lines
         WHERE status_code = 'A'
         AND summary_line_id = l_summary_line_id
	 AND payroll_control_id = gms_tie_back_rec.payroll_control_id;

	 /* Bug 2133056: Moving this statment into Mark Batch End process, for del exp stmt to work.
          DELETE FROM pa_transaction_interface_all
	  WHERE orig_transaction_reference = to_char(l_summary_line_id)
	    AND transaction_status_code = 'A'
	    AND transaction_source = l_txn_source; */

     END LOOP; -- End loop for gms_tie_back_success_cur

     UPDATE psp_payroll_controls
     SET ogm_dr_amount = nvl(ogm_dr_amount,0) + l_dr_summary_amount,
         ogm_cr_amount = nvl(ogm_cr_amount,0) + l_cr_summary_amount
     WHERE payroll_control_id = gms_tie_back_rec.payroll_control_id;

   END IF;
   END LOOP; -- End Loop for gms_batch_name_cur
   END LOOP; -- End loop for gms_tie_back_cur

commit;
 END LOOP; -- End loop for pc_batch_cur
   --
   p_return_status := fnd_api.g_ret_sts_success;
 EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     g_error_api_path := 'GMS_TIE_BACK:'||g_error_api_path;
     fnd_msg_pub.add_exc_msg('PSP_SUM_ADJ','GMS_TIE_BACK');
     p_return_status := fnd_api.g_ret_sts_unexp_error;

   WHEN TI_DID_NOT_COMPLETE THEN
     g_error_api_path := 'GMS_TIE_BACK:' || 'Transaction Import did not complete for some batches';
     fnd_msg_pub.add_exc_msg('PSP_ST_ADJ', 'GMS_TIE_BACK');
     p_return_status := fnd_api.g_ret_sts_unexp_error;

   WHEN OTHERS THEN
      g_error_api_path := 'GMS_TIE_BACK:'||g_error_api_path;
      fnd_msg_pub.add_exc_msg('PSP_SUM_ADJ','GMS_TIE_BACK');
      p_return_status := fnd_api.g_ret_sts_unexp_error;
 END;

------------------ INSERT INTO GMS INTERFACE -----------------------------------------------

 PROCEDURE insert_into_pa_interface(
	P_INTERFACE_ID			IN	NUMBER,
	P_TRANSACTION_SOURCE		IN	VARCHAR2,
	P_BATCH_NAME			IN	VARCHAR2,
	P_EXPENDITURE_ENDING_DATE	IN	DATE,
	P_EMPLOYEE_NUMBER		IN	VARCHAR2,
	P_ORGANIZATION_NAME		IN	VARCHAR2,
	P_EXPENDITURE_ITEM_DATE		IN	DATE,
	P_PROJECT_NUMBER		IN	VARCHAR2,
	P_TASK_NUMBER			IN	VARCHAR2,
	P_EXPENDITURE_TYPE		IN	VARCHAR2,
	P_QUANTITY			IN	NUMBER,
	P_RAW_COST			IN	NUMBER,
	P_EXPENDITURE_COMMENT		IN	VARCHAR2,
	P_TRANSACTION_STATUS_CODE	IN	VARCHAR2,
	P_ORIG_TRANSACTION_REFERENCE	IN	VARCHAR2,
	P_ORG_ID			IN	NUMBER,
	P_DENOM_CURRENCY_CODE		IN	VARCHAR2,
	P_DENOM_RAW_COST		IN	NUMBER,
	P_ATTRIBUTE1			IN	VARCHAR2,
	P_ATTRIBUTE2			IN	VARCHAR2,
	P_ATTRIBUTE3			IN	VARCHAR2,
	P_ATTRIBUTE4			IN	VARCHAR2,	-- Introduced attributes 4,5 for bug fix 2908859
	P_ATTRIBUTE5			IN	VARCHAR2,
	P_ATTRIBUTE6			IN	VARCHAR2,
	P_ATTRIBUTE7			IN	VARCHAR2,
	P_ATTRIBUTE8			IN	VARCHAR2,
	P_ATTRIBUTE9			IN	VARCHAR2,
	P_ATTRIBUTE10			IN	VARCHAR2,
	P_ACCT_RATE_TYPE		IN	VARCHAR2,	-- Introduced for bug fix 2916848
	P_ACCT_RATE_DATE		IN	DATE,		-- Introduced for bug fix 2916848
	P_PERSON_BUSINESS_GROUP_ID	IN	NUMBER,		-- Introduced for Bug fix 2935850
	P_RETURN_STATUS			OUT NOCOPY	VARCHAR2) IS
	l_msg_id	number(9);
	l_unmatched_nve_txn_flag	char(1);

 BEGIN

 IF (p_quantity < 0) THEN
		l_unmatched_nve_txn_flag := 'Y';
 END IF;

  /* Intoduced  the following for Bug 2935850 */

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
	ATTRIBUTE4,			-- Introduced attributes 4,5 for bug fix 2908859
	ATTRIBUTE5,
	ATTRIBUTE6,
	ATTRIBUTE7,
	ATTRIBUTE8,
	ATTRIBUTE9,
	ATTRIBUTE10,
	PERSON_BUSINESS_GROUP_ID,
--	Introduced the following columns for bug fix 2916848
	ACCT_RATE_TYPE,
	ACCT_RATE_DATE,
	UNMATCHED_NEGATIVE_TXN_FLAG)
   VALUES(
	P_INTERFACE_ID,
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
	P_ATTRIBUTE4,			-- Introduced attributes 4,5 for bug fix 2908859
	P_ATTRIBUTE5,
	P_ATTRIBUTE6,
	P_ATTRIBUTE7,
	P_ATTRIBUTE8,
	P_ATTRIBUTE9,
	P_ATTRIBUTE10,
	P_PERSON_BUSINESS_GROUP_ID,
--	Introduced the following columns for bug fix 2916848
	P_ACCT_RATE_TYPE,
        DECODE(p_acct_rate_type, NULL, NULL, P_ACCT_RATE_DATE),
	l_unmatched_nve_txn_flag);

    p_return_status := fnd_api.g_ret_sts_success;


 EXCEPTION
   WHEN OTHERS THEN
      g_error_api_path := 'INSERT_INTO_PA_INTERFACE:'||g_error_api_path;
      fnd_msg_pub.add_exc_msg('PSP_SUM_ADJ','INSERT_INTO_PA_INTERFACE');
      p_return_status := fnd_api.g_ret_sts_unexp_error;
 END;

--------------------------------------- CLEANUP BATCH DETAILS --------------------------
PROCEDURE cleanup_batch_details (p_payroll_control_id IN NUMBER,
                                 p_group_id IN NUMBER) IS    /*  added for bug 2133056 */
l_batch_name varchar2(30);
l_gms_phase varchar2(30);
l_gl_phase varchar2(30);
l_exp_group_name  varchar2(20); /*  1685685  */
l_user_je_source_name        VARCHAR2(25); -- added for 2133056
l_return_status              VARCHAR2(5);  -- Added for Bug 2133056

cursor adj_batch_cur (p_batch_name IN VARCHAR2) IS
select orig_source_type,
       orig_line_id
from psp_adjustment_lines pal,
     psp_payroll_controls ppc
WHERE   ppc.source_type          ='A'
AND     ppc.batch_name           = p_batch_name
AND     pal.payroll_control_id   = ppc.payroll_control_id
AND     pal.reversal_entry_flag IS NULL
UNION ALL -- added hist table for 2133056
SELECT palh.orig_source_type,
       palh.orig_line_id
FROM   psp_adjustment_lines_history palh,
       psp_payroll_controls  ppc
WHERE  palh.reversal_entry_flag IS NULL
AND    ppc.source_type          ='A'
AND    ppc.batch_name           = p_batch_name
AND    palh.payroll_control_id  = ppc.payroll_control_id
AND  palh.reversal_entry_flag IS NULL;



-- Included the following cursors for bug fix 1765678
   CURSOR	gl_gms_phase_batch_name_cur IS
   SELECT	gl_phase, gms_phase, batch_name
   FROM		psp_payroll_controls
   WHERE	payroll_control_id = p_payroll_control_id;

-- Tuned following stmt  2133056
   CURSOR  group_name_cur IS
         select expenditure_group
                from pa_expenditures_all
                where expenditure_id in
                     (select expenditure_id
                      from pa_transaction_interface_all
                      where transaction_source in ('OLD', 'GOLD') and
                            transaction_status_code = 'A' and
--                            batch_name = g_gms_batch_name and
			      batch_name IN (SELECT gms_batch_name FROM psp_summary_lines WHERE  payroll_control_id = p_payroll_control_id) and
                            rownum = 1);

adj_batch_rec	adj_batch_cur%ROWTYPE;
BEGIN
-- Replaced the earlier 'select stmt.' code with new 'cursor' code for bug fix 1765678

   OPEN gl_gms_phase_batch_name_cur;
   FETCH gl_gms_phase_batch_name_cur INTO l_gl_phase, l_gms_phase, l_batch_name;
   IF (gl_gms_phase_batch_name_cur%NOTFOUND) THEN
      CLOSE gl_gms_phase_batch_name_cur;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   CLOSE gl_gms_phase_batch_name_cur;

--Added the following group_name_cur for bug 1685685.
   OPEN group_name_cur;
     FETCH group_name_cur into l_exp_group_name ;
     CLOSE group_name_cur;

   if (l_gms_phase = 'GMS_Tie_Back') then
-- Rearranged the Delete statments, so as to delete items first and tuned DEL exp stmt for 2133056

         delete gms_award_distributions
         where  document_type = 'EXP'
           and  expenditure_item_id in
            (select expenditure_item_id
            from pa_expenditure_items_all
            where transaction_source = 'GOLD'
               and orig_transaction_reference in
             (select to_char(summary_line_id)
                   from psp_summary_lines
                    where payroll_control_id in
                     (select payroll_control_id
                      from psp_payroll_controls
                       where batch_name = l_batch_name
                        and source_type='A')));  ----- Added this delete for Bug 2133056


	delete from pa_expenditure_items_all
	 where transaction_source in ('OLD','GOLD')
	   and orig_transaction_reference in
        	(select to_char(summary_line_id)
		   from psp_summary_lines
 		    where payroll_control_id in
		     (select payroll_control_id
		      from psp_payroll_controls
		       where batch_name = l_batch_name
		        and source_type='A'));    --Added for bug 1685685

/***********************************************************************
BUG 2290051 : Commenting the following -purging of Interface lines
  delete gms_transaction_interface_all
    where transaction_source in ('GOLD') and
          batch_name = g_gms_batch_name and
          orig_transaction_reference in
                (select to_char(summary_line_id)
                   from psp_summary_lines
                  where payroll_control_id in
                        (select payroll_control_id
                           from psp_payroll_controls
                          where batch_name = l_batch_name
                             and source_type = 'A'));
********************************************************************************/

-- Bug 2133056.. Corrected not to delete non-orphan expenditures
 delete pa_expenditures_all EXP
    where EXP.expenditure_id in
        (select XFACE.expenditure_id
         from pa_transaction_interface_all XFACE
          where XFACE.transaction_source in('OLD','GOLD')
          and XFACE.orig_transaction_reference in
          (select to_char(PSL.summary_line_id)
           from psp_summary_lines PSL
              where PSL.payroll_control_id in
                (select PPC.payroll_control_id
                  from psp_payroll_controls PPC
                   where PPC.batch_name=l_batch_name
                    and PPC.source_type='A')))
       and 0 = (select count(*)
                from pa_expenditure_items_all ITEMS
                where ITEMS.expenditure_id = EXP.expenditure_id);

/*****************************************************************************
Commenting the following for the Bug 2290051
  delete pa_transaction_interface_all
       where transaction_source in ('OLD','GOLD') and
             batch_name = g_gms_batch_name and
            orig_transaction_reference in
                (select to_char(summary_line_id)
                   from psp_summary_lines
                  where payroll_control_id in
                        (select payroll_control_id
                           from psp_payroll_controls
                          where batch_name = l_batch_name
                           and source_type = 'A'));
******************************************************************************/
-- 1662816 start
    delete pa_expenditure_groups_all
    where transaction_source in('OLD','GOLD')
     and (0) = (select count(*) from pa_expenditures_all where expenditure_group=l_exp_group_name)
     and expenditure_group = l_exp_group_name;


   end if;

   if (l_gl_phase = 'GL_Tie_Back') then
 -- get the source name  -- Added for 2133056
   get_gl_je_sources(l_user_je_source_name,
                     l_return_status);
   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   --  Used the group_id parameter, instead of deriving it from summary lines table: Bug 2133056
   -- Removed all other deletion of gl tables, because of bug 2133056 fix.
	delete from gl_interface
	 where user_je_source_name = l_user_je_source_name
	   and group_id  = p_group_id ;

        --- Added this stmt for Bug 2133056
        delete from gl_interface_control
        where je_source_name = l_user_je_source_name
          and group_id = p_group_id;

   end if;

  open adj_batch_cur (l_batch_name);
   loop
   fetch adj_batch_cur into adj_batch_rec;
   if adj_batch_cur%NOTFOUND then
      close adj_batch_cur;
      exit;
   end if;
      if (adj_batch_rec.orig_source_type = 'D') then
	 update psp_distribution_lines_history
	    set adjustment_batch_name = NULL
	  where distribution_line_id = adj_batch_rec.orig_line_id;
      elsif adj_batch_rec.orig_source_type = 'P' then
	 update psp_pre_gen_dist_lines_history
	    set adjustment_batch_name = NULL
	  where pre_gen_dist_line_id = adj_batch_rec.orig_line_id;
      elsif adj_batch_rec.orig_source_type = 'A' then
	 update psp_adjustment_lines_history
	    set adjustment_batch_name = NULL
	  where adjustment_line_id = adj_batch_rec.orig_line_id;
      end if;
   end loop;

   delete from psp_adjustment_lines_history
    where payroll_control_id in        --- Corrected this statment 2133056
           ( SELECT ppc.payroll_control_id
          FROM   psp_payroll_controls ppc
          WHERE  ppc.batch_name = l_batch_name
          AND    ppc.source_type = 'A');


   delete from psp_adjustment_lines
    where batch_name = l_batch_name;

   delete from psp_summary_lines
    where payroll_control_id in (select payroll_control_id
				  from psp_payroll_controls
				 where batch_name = l_batch_name
                                   and source_type = 'A'); --- added this condn 2133056

   delete from psp_payroll_controls
    where batch_name = l_batch_name and
          source_type = 'A';       --- added this condn 2133056

   delete from psp_adjustment_control_table
    where adjustment_batch_name = l_batch_name;

EXCEPTION
  WHEN OTHERS THEN
     g_error_api_path := 'CLEANUP_BATCH_DETAILS:'||g_error_api_path;
     fnd_msg_pub.add_exc_msg('PSP_SUM_ADJ','CLEANUP_BATCH_DETAILS');
END;
-------------------------------------
PROCEDURE check_interface_status(p_target_name 		IN VARCHAR2,
                                 p_adj_sum_batch_name   IN VARCHAR2) IS
CURSOR pc_batch_cur IS
SELECT distinct batch_name
  FROM psp_payroll_controls
 WHERE source_type = 'A'
   AND adj_sum_batch_name = p_adj_sum_batch_name
   AND status_code = 'I';

CURSOR payroll_control_cur(p_batch_name IN VARCHAR2) IS
SELECT payroll_control_id
  FROM psp_payroll_controls
 WHERE batch_name = p_batch_name
   AND status_code = 'I'
   AND decode(p_target_name, 'GL', gl_phase, gms_phase) = 'Submitted_Import_Request'
   AND source_type = 'A';

pc_batch_rec	pc_batch_cur%ROWTYPE;
payroll_control_rec  payroll_control_cur%ROWTYPE;
l_group_id	number;
l_gms_batch_name	number;
l_status_new	number;
l_status_p		number;
l_status_i		number;
l_no_complete		number := 0;
l_transaction_source	VARCHAR2(40);

-- Included the following cursors here for accessing the local variables for bug fix 1765678
   CURSOR	summary_group_cur IS
   SELECT	MAX(group_id)
   FROM		psp_summary_lines
   WHERE	payroll_control_id = payroll_control_rec.payroll_control_id
   AND		group_id IS NOT NULL;

   CURSOR	gl_interface_status_cur IS
   SELECT	count(*)
   FROM		gl_interface
   WHERE	group_id = l_group_id
   AND		user_je_source_name = 'OLD'
   AND		status = 'NEW';

   CURSOR	gms_batch_name_cur IS
   SELECT	MAX(gms_batch_name)
   FROM		psp_summary_lines
   WHERE	payroll_control_id = payroll_control_rec.payroll_control_id
   AND		gms_batch_name IS NOT NULL;

   CURSOR	pa_txn_int_status_p_cur IS
   SELECT	count(*)
   FROM		pa_transaction_interface
   WHERE	batch_name = TO_CHAR(l_gms_batch_name)
   AND		transaction_status_code = 'P'
   AND          transaction_source in ('OLD','GOLD');   --- Added condn for Bug 2133056

   CURSOR	pa_txn_int_status_i_cur IS
   SELECT	count(*)
   FROM		pa_transaction_interface_all
   WHERE	batch_name = TO_CHAR(l_gms_batch_name)
   AND          transaction_source in ('OLD','GOLD')
   AND		transaction_status_code = 'I';          --- Added condn for Bug 2133056

begin
  open pc_batch_cur;
  loop
  fetch pc_batch_cur into pc_batch_rec;
  if pc_batch_cur%NOTFOUND then
     close pc_batch_cur;
     exit;
  end if;

  open payroll_control_cur(pc_batch_rec.batch_name);
  loop
  fetch payroll_control_cur into payroll_control_rec;
  if payroll_control_cur%NOTFOUND then
    close payroll_control_cur;
    exit;
  end if;

  if (p_target_name = 'GL') then
  begin
-- Replaced the earlier 'select stmt.' code with new 'cursor' code for bug fix 1765678

   OPEN summary_group_cur;
   FETCH summary_group_cur INTO l_group_id;
   IF (summary_group_cur%NOTFOUND) THEN
      CLOSE summary_group_cur;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   CLOSE summary_group_cur;

   OPEN gl_interface_status_cur;
   FETCH gl_interface_status_cur INTO l_status_new;
   IF (gl_interface_status_cur%NOTFOUND) THEN
      CLOSE gl_interface_status_cur;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   CLOSE gl_interface_status_cur;

    if l_status_new > 0 then
	 update psp_payroll_controls
            set gl_phase = 'Summarize_GL_Lines'
	  where gl_phase = 'Submitted_Import_Request'
	    and payroll_control_id = payroll_control_rec.payroll_control_id;

          delete from gl_interface
           where group_id = l_group_id
             and user_je_source_name = 'OLD';

          delete from gl_interface_control
           where group_id = l_group_id
             and je_source_name = 'OLD';
    end if;

  exception
	when NO_DATA_FOUND then
	  NULL;
  end;
elsif (p_target_name = 'GMS') then
       begin
-- Replaced the earlier 'select stmt.' code with new 'cursor' code for bug fix 1765678

       OPEN gms_batch_name_cur;
       FETCH gms_batch_name_cur INTO l_gms_batch_name;
       IF (gms_batch_name_cur%NOTFOUND) THEN
          CLOSE gms_batch_name_cur;
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
       CLOSE gms_batch_name_cur;

       OPEN pa_txn_int_status_p_cur;
       FETCH pa_txn_int_status_p_cur INTO l_status_p;
       IF (pa_txn_int_status_p_cur%NOTFOUND) THEN
          CLOSE pa_txn_int_status_p_cur;
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
       CLOSE pa_txn_int_status_p_cur;

	  if (l_status_p > 0) then
	    update psp_payroll_controls
		 set gms_phase = NULL
	     where payroll_control_id = payroll_control_rec.payroll_control_id
	       and gms_phase = 'Submitted_Import_Request';

	   delete from pa_transaction_interface_all
	    where batch_name = to_char(l_gms_batch_name)
	      and transaction_source in ('GOLD', 'OLD');

	   delete from gms_transaction_interface_all
	    where batch_name = to_char(l_gms_batch_name)
	      and transaction_source = 'GOLD';

	   delete from psp_summary_lines
	    where payroll_control_id = payroll_control_rec.payroll_control_id
	      and gms_batch_name = l_gms_batch_name;


	  end if;
	exception
	  when NO_DATA_FOUND then
		null;
	end;
-- Replaced the earlier 'select stmt.' code with new 'cursor' code for bug fix 1765678

         OPEN pa_txn_int_status_i_cur;
         FETCH pa_txn_int_status_i_cur INTO l_status_i;
         IF (pa_txn_int_status_i_cur%NOTFOUND) THEN
            CLOSE pa_txn_int_status_i_cur;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
         CLOSE pa_txn_int_status_i_cur;

	 if l_status_i > 0 then
		l_no_complete := l_no_complete + 1;
       		fnd_message.set_name('PSP','PSP_PRC_DID_NOT_COMPLETE');
       		fnd_message.set_token('PAYROLL_CONTROL_ID',payroll_control_rec.payroll_control_id);
       		fnd_message.set_token('GMS_BATCH_NAME', l_gms_batch_name);
       		fnd_msg_pub.add;
	  end if;

end if;
end loop;
end loop;

     if (l_no_complete > 0) then
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     end if;
exception
when others then
  fnd_msg_pub.add_exc_msg('PSP_ST_ADJ', 'CHECK_INTERFACE_STATUS');
end CHECK_INTERFACE_STATUS;
-----------------------------------Get the Batch Details --------------------------------
PROCEDURE get_the_batch_details(p_batch_name	IN	VARCHAR2,
				p_return_status	OUT NOCOPY	VARCHAR2) IS

l_adjustment_batch_name	VARCHAR2(30);
l_person_id		NUMBER;
l_assignment_id		NUMBER;
l_assignment_number	VARCHAR2(30);
l_element_type_id	NUMBER;
-- For bug fix 1765678, increased the size of element name from 30 to 80.
-- l_element_name		VARCHAR2(80);   commented for 2634557 DA Multiple element Enh
l_distribution_start_date	DATE;
l_distribution_end_date		DATE;
l_person_name		VARCHAR2(80);
l_error			VARCHAR2(200);
l_currency_code		psp_payroll_controls.currency_code%TYPE;

-- Included the following cursors here for accessing local variables for bug fix 1765678
   CURSOR	adjustment_control_cur IS
   SELECT	adjustment_batch_name, person_id, assignment_id, element_type_id,
		distribution_start_date, distribution_end_date,
		currency_code	-- Introduced for bug fix 2916848
   FROM		psp_adjustment_control_table
   WHERE	adjustment_batch_name = p_batch_name;

   CURSOR	person_name_cur IS
   SELECT	substr(full_name, 1, 80)
   FROM		per_people_f ppf1
   WHERE	person_id = l_person_id
   AND		trunc(sysdate) BETWEEN effective_start_date and effective_end_date ;


   CURSOR	assignment_number_cur IS
   SELECT	assignment_number
   FROM		per_all_assignments_f paf1
   WHERE	assignment_id = l_assignment_id
   AND		effective_start_date =	(SELECT	MAX(effective_start_date)
					FROM	per_all_assignments_f paf2
					WHERE	paf2.assignment_id = l_assignment_id
					AND	paf2.effective_start_date < trunc(sysdate));

   CURSOR	element_name_cur IS
   SELECT	element_name
   FROM		pay_element_types_f pet1
   WHERE	element_type_id = l_element_type_id
   AND		effective_start_date =	(SELECT	MAX(effective_start_date)
					FROM	pay_element_types_f pet2
					WHERE	pet2.element_type_id = l_element_type_id
					AND	pet2.effective_start_date < trunc(sysdate));

begin
-- Replaced the earlier 'select stmt.' code with new 'cursor' code for bug fix 1765678

    OPEN adjustment_control_cur;
    FETCH adjustment_control_cur INTO l_adjustment_batch_name, l_person_id, l_assignment_id, l_element_type_id,
	l_distribution_start_date, l_distribution_end_date,
	l_currency_code;	-- Introduced currency for bug 2916848
    IF (adjustment_control_cur%NOTFOUND) THEN
       CLOSE adjustment_control_cur;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    CLOSE adjustment_control_cur;

	    l_error := 'Batch : ' || p_batch_name || ' Person Id ' || l_person_id;

-- for bug fix 1765678, truncated person full name to 80 characters
-- Replaced the earlier 'select stmt.' code with new 'cursor' code for bug fix 1765678

    OPEN person_name_cur;
    FETCH person_name_cur INTO l_person_name;
    IF (person_name_cur%NOTFOUND) THEN
       CLOSE person_name_cur;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    CLOSE person_name_cur;

	    l_error := 'Batch : ' || p_batch_name || ' Assign ID ' || l_assignment_id;

-- Replaced the earlier 'select stmt.' code with new 'cursor' code for bug fix 1765678

    OPEN assignment_number_cur;
    FETCH assignment_number_cur INTO l_assignment_number;
    IF (assignment_number_cur%NOTFOUND) THEN
       CLOSE assignment_number_cur;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    CLOSE assignment_number_cur;

	    l_error := 'Batch : ' || p_batch_name || ' Elem Type ' || l_element_type_id;

-- Replaced the earlier 'select stmt.' code with new 'cursor' code for bug fix 1765678
/*  commented for 2634557 DA Multiple element Enh
    OPEN element_name_cur;
    FETCH element_name_cur INTO l_element_name;
    IF (element_name_cur%NOTFOUND) THEN
       CLOSE element_name_cur;
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    CLOSE element_name_cur;
*/

	    l_error := 'Batch : ' || p_batch_name || ' Setting Tokens ' ;

           fnd_message.set_token('BATCH_NAME',l_adjustment_batch_name);
           fnd_message.set_token('PERSON_NAME',l_person_name);
           fnd_message.set_token('ASSIGNMENT_NUMBER',l_assignment_number);
  ---         fnd_message.set_token('ELEMENT_TYPE',l_element_name);   commented for 2634557 DA Multiple element Enh
           fnd_message.set_token('DISTRIBUTION_START_DATE', to_char(l_distribution_start_date));
           fnd_message.set_token('DISTRIBUTION_END_DATE', to_char(l_distribution_end_date));
	fnd_message.set_token('CURRENCY_CODE', l_currency_code);	-- Introduced for bug fix 2916848
       	   fnd_msg_pub.add;

      	   p_return_status := fnd_api.g_ret_sts_success;

exception
  when no_data_found then
--      raise_application_error(-20001, l_error || ' No Data Found');
      fnd_message.set_token('BATCH_NAME', l_error || ' No data found');
-- Included the following line for bug fix 1765678
      fnd_msg_pub.add;
      p_return_status := fnd_api.g_ret_sts_unexp_error;
  when too_many_rows then
--      raise_application_error(-20001, l_error || ' ' || sqlerrm);
      fnd_message.set_token('BATCH_NAME', l_error || ' Too many rows');
-- Included the following line for bug fix 1765678
      fnd_msg_pub.add;
      p_return_status := fnd_api.g_ret_sts_unexp_error;
  when others then
--Bug :1776606 : Building error stack
     fnd_message.set_token('BATCH_NAME',l_error||'Unexpected Oracle error occured ORA -'||sqlcode);
     fnd_msg_pub.add;
     fnd_msg_pub.add_exc_msg('PSP_SUM_ADJ','GET_THE_BATCH_DETAILS');
-- Included the following line for bug fix 1765678
      p_return_status := fnd_api.g_ret_sts_unexp_error;
      raise;
-- Bug 1776606 : Commented the following line
--     raise_application_error(sqlcode, l_error || ' ' || sqlerrm);
end get_the_batch_details;
------------------ INSERT INTO PSP_STOUT -----------------------------------------------
/* DEBUGGIN PROCEDURE
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
 END;
 */

END PSP_SUM_ADJ;

/

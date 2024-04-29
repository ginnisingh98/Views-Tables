--------------------------------------------------------
--  DDL for Package Body PSP_DRT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSP_DRT_PKG" AS
/* $Header: PSPDRTB.pls 120.0.12010000.11 2018/05/08 08:20:41 asrajago noship $ */


  g_error_msg    VARCHAR2(30) := 'PSP_DRC_VLD_ERR';


  --
  --- Implement helper procedure add record corresponding to an error/warning/error
  --
		PROCEDURE add_to_results
		  (person_id   IN            number
		 , entity_type IN            varchar2
		 , status      IN            varchar2
		 , msg_code     IN            varchar2
		 , msg_appl_id    IN            number
		 , result_tbl  IN OUT NOCOPY per_drt_pkg.result_tbl_type) IS
		  n number(15);
		BEGIN
		  n := result_tbl.count + 1;

		  result_tbl (n).person_id := person_id;

		  result_tbl (n).entity_type := entity_type;

		  result_tbl (n).status := status;

		  result_tbl (n).msgcode := msg_code;

		  result_tbl (n).msgaplid := msg_appl_id;

		END add_to_results;



		PROCEDURE psp_hr_drc
		  (p_person_id  IN         number
		 , p_result_tbl OUT NOCOPY per_drt_pkg.result_tbl_type) IS

		BEGIN

		  write_log ('Entered psp_hr_drc');

		  ld_drc (p_person_id, p_result_tbl);

		  write_log ('Exiting psp_hr_drc');

		END psp_hr_drc;

              -- DRC procedure.

		PROCEDURE ld_drc
		  (p_person_id  IN         number
		 , p_result_tbl OUT NOCOPY per_drt_pkg.result_tbl_type) IS

		  p_result varchar2(10);
		  l_pending_da number DEFAULT 0;
		  l_pending_sum_lines number DEFAULT 0;
		  CURSOR pending_da_csr IS
		    SELECT  effort_report_id
		    FROM    psp_effort_reports outer
		          , psp_effort_report_templates pert
		          , per_all_people_f ppf
		          , psp_adjustment_control_table pal
		          , per_business_groups pbg
		    WHERE   outer.person_id = pal.person_id
		    AND     pert.end_date >= pal.distribution_start_date
		    AND     pert.begin_date <= pal.distribution_end_date
		    AND     pal.approver_id IS NULL
		    AND     outer.status_code IN ('S')
		    AND     outer.person_id = ppf.person_id
		    AND     ppf.person_id = p_person_id
		    AND     outer.template_id = pert.template_id
		    AND     ppf.effective_start_date =
		            (
		            SELECT  max (ppf2.effective_start_date)
		            FROM    per_all_people_f ppf2
		            WHERE   ppf.person_id = ppf2.person_id
		            AND     ppf2.effective_start_date <= pert.end_date
		            AND     ppf2.effective_end_date >= pert.begin_date
		            )
		    AND     pbg.business_group_id = pert.business_group_id
		    AND     pal.void IS NULL;

		  CURSOR pending_sum_lines_csr IS
		    SELECT  count (enc_summary_line_id)
		    FROM    psp_enc_summary_lines
		    WHERE   person_id = p_person_id
		    AND     status_code = 'N'
		    AND     effective_date > add_months (sysdate, - 120);

                  -- Bug 27969878
                  CURSOR pending_dist_sum_lines(p_person_id  NUMBER)
                      IS SELECT 1
                           FROM psp_summary_lines
                          WHERE person_id = p_person_id
                            AND status_code = 'N'
                            AND effective_date > add_months(sysdate,-120);


                 -- Bug 27969878
                 CURSOR pending_dist_lines(p_person_id  NUMBER)
                     IS SELECT 1
                          FROM psp_payroll_lines ppl,
                               psp_payroll_sub_lines psl,
                               psp_distribution_lines pdl
                         where ppl.person_id = p_person_id
                           and ppl.payroll_line_id = psl.payroll_line_id
                           and pdl.payroll_sub_line_id = psl.payroll_sub_line_id
                           AND pdl.effective_date > add_months(sysdate,-120)
                           and pdl.status_code = 'N';


                 -- Bug 27969878
                 CURSOR pending_adj_lines(p_person_id  NUMBER)
                     IS select 1
                          from psp_summary_lines psl,
                               psp_distribution_lines_history pdlh,
                               psp_adjustment_lines pal
                         where psl.person_id = p_person_id
                           and psl.summary_line_id = pdlh.summary_line_id
                           and pdlh.distribution_line_id = pal.orig_line_id
                           and pal.status_code = 'N'
                           and pal.effective_date > add_months(sysdate,-120);


                 l_exists   NUMBER;


		BEGIN

		  write_log ('Entered ld_drc');

		  write_log ('Validation in progress for person Id: '
		             || p_person_id);

		  write_log ('1 . Validating if any pending distribution adjustments exist for this person : ');


                  -- Bug 27969878
                  OPEN pending_dist_sum_lines(p_person_id);
                  FETCH pending_dist_sum_lines INTO l_exists;
                  IF pending_dist_sum_lines%FOUND
                  THEN
                     write_log('Dist sum lines exist - S&T must re run ');
                     add_to_results
                               (person_id   => p_person_id
                              , entity_type => 'HR'
                              , status      => 'E'
                              , msg_code    => g_error_msg
                              , msg_appl_id => 8403
                              , result_tbl  => p_result_tbl );
                     RETURN;
                  END IF;
                  CLOSE pending_dist_sum_lines;

                  -- Bug 27969878
                  OPEN pending_dist_lines(p_person_id);
                  FETCH pending_dist_lines INTO l_exists;
                  IF pending_dist_lines%FOUND
                  THEN
                     write_log('Dist lines exist - S&T must run');
                     add_to_results
                               (person_id   => p_person_id
                              , entity_type => 'HR'
                              , status      => 'E'
                              , msg_code    => g_error_msg
                              , msg_appl_id => 8403
                              , result_tbl  => p_result_tbl );
                     RETURN;
                  END IF;
                  CLOSE pending_dist_lines;

                  -- Bug 27969878
                  OPEN pending_adj_lines(p_person_id);
                  FETCH pending_adj_lines INTO l_exists;
                  IF pending_adj_lines%FOUND
                  THEN
                     write_log('Adjustment lines exist - S&T must run');
                     add_to_results
                               (person_id   => p_person_id
                              , entity_type => 'HR'
                              , status      => 'E'
                              , msg_code    => g_error_msg
                              , msg_appl_id => 8403
                              , result_tbl  => p_result_tbl );
                     RETURN;
                  END IF;
                  CLOSE pending_adj_lines;



		  OPEN pending_da_csr;

		  FETCH pending_da_csr
		    BULK COLLECT INTO eff_master_rec.effort_report_id;

		  CLOSE pending_da_csr;

		  l_pending_da := eff_master_rec.effort_report_id.count;

		  write_log ('Pending distribution adjustments ='
		             || l_pending_da);

		  -- Bug 27890184
		  -- IF (l_pending_da IS NOT NULL) THEN
		  IF (l_pending_da > 0) THEN
		    write_log ('Pending distribution adjustments exist for this person Id');

		    add_to_results
		                    (person_id   => p_person_id
		                   , entity_type => 'HR'           -- Bug 27890184
		                   , status      => 'E'
		                   , msg_code    => g_error_msg
		                   , msg_appl_id => 8403
		                   , result_tbl  => p_result_tbl );

		  ELSE

		    write_log ('No Pending distribution adjustments. Continuing Validation');

		    write_log ('2 . Validating if any pending summary lines exist for this person : ');

		    OPEN pending_sum_lines_csr;

		    FETCH pending_sum_lines_csr
		      INTO    l_pending_sum_lines;

		    CLOSE pending_sum_lines_csr;

		    IF (l_pending_sum_lines > 0) THEN
		      write_log ('Transactions pending to be summarized and Transferred');

		      add_to_results
		                      (person_id   => p_person_id
		                     , entity_type => 'HR'        -- Bug 27890184
		                     , status      => 'E'
		                     , msg_code    => g_error_msg
		                     , msg_appl_id => 8403
		                     , result_tbl  => p_result_tbl );
		    ELSE
		      write_log ('No Pending Transactions to be summarized and Transferred');
		    END IF;

		  END IF;

	    	write_log ('Validation Complete. Exiting ld_drc');

		EXCEPTION
		  WHEN others THEN
		    write_log (dbms_utility.format_error_backtrace);
		    write_log ('Exiting ld_drc from exception block');
		END ld_drc;

  PROCEDURE write_log
    (p_log_message IN varchar2) IS

  BEGIN

      fnd_file.put_line (fnd_file.log, fnd_date.date_to_canonical (sysdate)
                                     || p_log_message);

      hr_utility.trace (p_log_message);

  END write_log;

/*

  PROCEDURE remove_adj_data
    (p_person_id IN number) IS
  BEGIN
    write_log ('Entered remove_adj_data');

    DELETE
    FROM    psp_adjustment_lines
    WHERE   person_id = p_person_id;

    DELETE
    FROM    psp_adjustment_lines_history
    WHERE   person_id = p_person_id;

    DELETE
    FROM    psp_adjustment_lines_arch
    WHERE   person_id = p_person_id;

    write_log ('Adjustments data Removed');
  END remove_adj_data;

  PROCEDURE remove_enc_data
    (p_person_id IN number) IS
  BEGIN
    write_log ('Entered remove_enc_data');

    DELETE
    FROM    psp_enc_lines
    WHERE   person_id = p_person_id;

    DELETE
    FROM    psp_enc_lines_history
    WHERE   person_id = p_person_id;

    DELETE
    FROM    psp_enc_lines_arch
    WHERE   person_id = p_person_id;

    DELETE
    FROM    psp_enc_summary_lines_arch
    WHERE   person_id = p_person_id;

    DELETE
    FROM    psp_enc_summary_lines
    WHERE   person_id = p_person_id;

    write_log ('Encumbrance data Removed');
  END remove_enc_data;

  PROCEDURE remove_actuals_data
    (p_person_id IN number) IS
  BEGIN
    write_log ('Entered remove_actuals_data');

    DELETE
    FROM    psp_pre_gen_dist_lines
    WHERE   person_id = p_person_id;

    DELETE
    FROM    psp_pre_gen_dist_lines_history
    WHERE   person_id = p_person_id;

    DELETE
    FROM    psp_pre_gen_dist_lines_arch
    WHERE   person_id = p_person_id;

    DELETE
    FROM    psp_distribution_lines_history
    WHERE   schedule_line_id IN
            (
            SELECT  schedule_line_id
            FROM    psp_schedule_lines
            WHERE   schedule_hierarchy_id IN
                    (
                    SELECT  schedule_hierarchy_id
                    FROM    psp_schedule_hierarchy
                    WHERE   assignment_id IN
                            (
                            SELECT  assignment_id
                            FROM    per_all_assignments_f
                            WHERE   person_id = p_person_id
                            )
                    )
            );

    DELETE
    FROM    psp_distribution_lines_arch
    WHERE   schedule_line_id IN
            (
            SELECT  schedule_line_id
            FROM    psp_schedule_lines
            WHERE   schedule_hierarchy_id IN
                    (
                    SELECT  schedule_hierarchy_id
                    FROM    psp_schedule_hierarchy
                    WHERE   assignment_id IN
                            (
                            SELECT  assignment_id
                            FROM    per_all_assignments_f
                            WHERE   person_id = p_person_id
                            )
                    )
            );

    DELETE
    FROM    psp_distribution_lines
    WHERE   schedule_line_id IN
            (
            SELECT  schedule_line_id
            FROM    psp_schedule_lines
            WHERE   schedule_hierarchy_id IN
                    (
                    SELECT  schedule_hierarchy_id
                    FROM    psp_schedule_hierarchy
                    WHERE   assignment_id IN
                            (
                            SELECT  assignment_id
                            FROM    per_all_assignments_f
                            WHERE   person_id = p_person_id
                            )
                    )
            );

    DELETE
    FROM    psp_payroll_sub_lines
    WHERE   payroll_line_id IN
            (
            SELECT  payroll_line_id
            FROM    psp_payroll_lines
            WHERE   person_id = p_person_id
            );

    DELETE
    FROM    psp_payroll_lines
    WHERE   person_id = p_person_id;

    write_log ('Actuals data Removed');
  END remove_actuals_data;

  PROCEDURE remove_sched_data
    (p_person_id IN number) IS
  BEGIN
    write_log ('Entered remove_sched_data');

    DELETE
    FROM    psp_schedule_lines
    WHERE   schedule_hierarchy_id IN
            (
            SELECT  schedule_hierarchy_id
            FROM    psp_schedule_hierarchy
            WHERE   assignment_id IN
                    (
                    SELECT  assignment_id
                    FROM    per_all_assignments_f
                    WHERE   person_id = p_person_id
                    )
            );

    DELETE
    FROM    psp_schedule_hierarchy
    WHERE   assignment_id IN
            (
            SELECT  assignment_id
            FROM    per_all_assignments_f
            WHERE   person_id = p_person_id
            );

    DELETE
    FROM    psp_schedules
    WHERE   person_id = p_person_id;

    write_log ('Schedule data Removed');
  END remove_sched_data;

  FUNCTION clear_lab_data
    (p_person_id IN number) RETURN varchar2 IS
    l_val_result varchar2(10);
    l_return_code varchar2(10);
  BEGIN
    write_log ('Entered clear_lab_data');

    write_log ('Validating pending transactions for person ID : '
               || p_person_id);

    l_val_result := ld_drc (p_person_id);

    IF l_val_result = 'S' THEN
      write_log ('Starting data clearance for person ID : '
                 || p_person_id);

      remove_enc_data (p_person_id);

      remove_actuals_data (p_person_id);

      remove_sched_data (p_person_id);

      remove_adj_data (p_person_id);

      write_log ('Complete LD data removed for person ID : '
                 || p_person_id);

      l_return_code := 'S';
    ELSE
      l_return_code := 'E';

      write_log ('person ID : '
                 || p_person_id
                 || 'has pending transactions. No data is cleared');
    END IF;
  EXCEPTION
    WHEN others THEN
      l_return_code := 'E';

      write_log ('Exiting clear_lab_data');
  END clear_lab_data;

*/

END psp_drt_pkg;

/

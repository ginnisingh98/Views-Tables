--------------------------------------------------------
--  DDL for Package Body PSP_ROLLBACK_DIST_LINES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSP_ROLLBACK_DIST_LINES" AS
/*$Header: PSPRBDLB.pls 120.0.12010000.5 2009/09/18 06:34:02 amakrish ship $*/

PROCEDURE DELETE_LINES(errbuf			OUT NOCOPY 	VARCHAR2,
		       retcode			OUT NOCOPY	VARCHAR2,
		       p_source_type		IN	VARCHAR2,
		       p_source_code		IN	VARCHAR2,
		       p_payroll_id		IN	NUMBER,
		       p_time_period_id		IN	NUMBER,
		       p_batch_name		IN	VARCHAR2,
		       p_business_group_id 	IN	NUMBER,
		       p_set_of_books_id	IN	NUMBER) IS

	CURSOR payroll_control_cur IS    -- Bug 6686483
	 select payroll_control_id,status_code,time_period_id
		from psp_payroll_controls
		where business_group_id = p_business_group_id
		AND   set_of_books_id   = p_set_of_books_id
		AND   source_type = nvl(p_source_type,source_type)
		AND   source_type <> 'A'    -- Bug 7136917
		AND   payroll_source_code = nvl(p_source_code,payroll_source_code)
	        AND   payroll_id = nvl(p_payroll_id,payroll_id)
		AND   time_period_id = nvl(p_time_period_id,time_period_id)
		AND   nvl(batch_name,'N') = nvl(nvl(p_batch_name,batch_name),'N')
	        AND   parent_payroll_control_id IS NULL
	      UNION
	        select payroll_control_id,status_code,time_period_id
		from psp_payroll_controls ppc1
		where  ppc1.parent_payroll_control_id in(select payroll_control_id
	                                from psp_payroll_controls
					where business_group_id = p_business_group_id
					AND   set_of_books_id   = p_set_of_books_id
					AND   source_type = nvl(p_source_type,source_type)
					AND   source_type <> 'A'    -- Bug 7136917
					AND   payroll_source_code = nvl(p_source_code,payroll_source_code)
	        			AND   payroll_id = nvl(p_payroll_id,payroll_id)
					AND   time_period_id = nvl(p_time_period_id,time_period_id)
					AND   nvl(batch_name,'N') = nvl(nvl(p_batch_name,batch_name),'N'));

	payroll_control_rec		payroll_control_cur%ROWTYPE;
	l_period_name			VARCHAR2(80);
	l_payroll_name			VARCHAR2(80);  -- Bug 6686483
	l_deleted			BOOLEAN := TRUE;
	cnt				NUMBER := 0;
BEGIN
	fnd_msg_pub.initialize;

	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	Rollback CDL parameters :' );
	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	p_source_type = ' || p_source_type);
	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	p_source_code = ' || p_source_code);
	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	p_payroll_id = ' || p_payroll_id);
	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	p_time_period_id = ' || p_time_period_id);
	fnd_file.put_line(fnd_file.log, fnd_date.date_to_canonical(SYSDATE) || '	p_batch_name = ' || p_batch_name);

	fnd_file.put_line(fnd_file.log,'');


	OPEN payroll_control_cur;
	LOOP
	  FETCH payroll_control_cur INTO payroll_control_rec;
	  IF  payroll_control_cur%NOTFOUND
	  THEN
		CLOSE payroll_control_cur;
		commit;
		EXIT;
	  END IF;
	  BEGIN

	        -- Fix for bug 8922889
	  	SELECT ptp.period_name, ppf.payroll_name  into l_period_name, l_payroll_name
		  FROM per_time_periods ptp, pay_payrolls_f ppf
		  WHERE ptp.time_period_id = payroll_control_rec.time_period_id
		  and ptp.payroll_id = ppf.payroll_id
		  and trunc(sysdate) between ppf.effective_start_date and ppf.effective_end_date;

		/* Record has been processed by Summarise and Transfer */
	     	IF payroll_control_rec.status_code in ('P','I')
		THEN
			fnd_message.set_name('PSP','PSP_DL_ALREADY_PROCESSED');
			fnd_message.set_token('TIME_PERIOD',l_period_name);
			fnd_msg_pub.add;
			l_deleted := FALSE;
	     	ELSIF payroll_control_rec.status_code = 'N'
		THEN
			SELECT COUNT(*) INTO cnt
			FROM psp_summary_lines
			WHERE payroll_control_id = payroll_control_rec.payroll_control_id;
			IF cnt = 0  /* lines not yet processed  */
			THEN
			   BEGIN
				DELETE FROM PSP_DISTRIBUTION_LINES
				WHERE payroll_sub_line_id in (select payroll_sub_line_id
				  from psp_payroll_sub_lines
				  where payroll_line_id in (
					select payroll_line_id from psp_payroll_lines
					where payroll_control_id = payroll_control_rec.payroll_control_id));
				UPDATE PSP_PAYROLL_CONTROLS
				SET dist_dr_amount = NULL,
				    dist_cr_amount = NULL,
                                    cdl_payroll_action_id = NULL  --- salary cap 4304623
				WHERE payroll_control_id = payroll_control_rec.payroll_control_id;

				fnd_file.put_line(fnd_file.log,'***** Completed Rollback Distribution Lines for ' || l_payroll_name || ' , ' || l_period_name);

			   END;
			ELSE  /* count(*) != 0 */
			/* Though the payroll control record are having status N
			   but the lines have processed by ST but failed. */

			   fnd_message.set_name('PSP','PSP_DL_ALREADY_PROCESSED');
			   fnd_message.set_token('TIME_PERIOD',l_period_name);
			   fnd_msg_pub.add;
			   l_deleted := FALSE;
			END IF;  /* count(*) = 0 */
		END IF;
	  END;
	END LOOP;
	if l_deleted = FALSE
	THEN
		psp_message_s.print_error(p_mode => FND_FILE.LOG,
					  p_print_header => FND_API.G_TRUE);
	END IF;
--Introduced For the Bug 2665152
		retcode:=0;
                psp_message_s.print_success;
--End of Bug fix 2665152
	EXCEPTION
		WHEN OTHERS
		THEN
			ROLLBACK;
			fnd_message.set_name('PSP','PSP_SQL_ERROR');
			fnd_message.set_token('SQLERROR',sqlerrm);
			fnd_msg_pub.add;
--For Bug 2665152 : Introduced the Error Message and assigned value to retcode
                	psp_message_s.print_error(p_mode => FND_FILE.LOG,
                           			 p_print_header => FND_API.G_TRUE);
			  retcode:=2;

END delete_lines;
END psp_rollback_dist_lines;

/

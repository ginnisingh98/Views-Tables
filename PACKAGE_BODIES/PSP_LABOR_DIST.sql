--------------------------------------------------------
--  DDL for Package Body PSP_LABOR_DIST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSP_LABOR_DIST" as
/* $Header: PSPLDCDB.pls 120.33.12010000.4 2008/10/17 07:48:08 aniagarw ship $ */

g_dist_line_id		NUMBER;
/* Following variables are added for bug 2374680 */
g_assignment_number     VARCHAR2(30);
g_employee_number       VARCHAR2(30);
g_gl_effective_date       date;  -- introduced for 2663344

--	Introduced the following for bug fix 2916848
g_precision	NUMBER := 2; -- Assigned a default value of 2 for bug fix 4067668
g_ext_precision	NUMBER;
--	End of bug fix 2916848

g_sub_line_id           integer; --- added for 3813688
/* Following procedure is added for bug 2374680. */
g_retro_parent_element_id integer; ---- 5090002
PROCEDURE Get_assign_number
          (p_assignment_id                IN  NUMBER,
           p_payroll_start_date           IN  DATE,
           p_assignment_number            OUT NOCOPY VARCHAR2,
           p_employee_number              OUT NOCOPY VARCHAR2 ) IS

  CURSOR assign_num_cur IS
    SELECT paf.assignment_number,
     ppf.employee_number
     FROM
     per_assignments_f paf,per_people_f ppf
     WHERE paf.assignment_id =p_assignment_id
     AND   paf.person_id =ppf.person_id
     and   paf.assignment_type = 'E'
     AND   p_payroll_start_date between paf.effective_start_date and paf.effective_end_date
     AND  p_payroll_start_date between ppf.effective_start_date and ppf.effective_end_date;

BEGIN
    OPEN assign_num_cur;
    FETCH assign_num_cur INTO p_assignment_number,p_employee_number;
    CLOSE assign_num_cur;

END get_assign_number;

------------------------- M A I N    P R O C E D U R E -------------------------------

 PROCEDURE create_lines (errbuf           	OUT NOCOPY VARCHAR2,
                         retcode          	OUT NOCOPY VARCHAR2,
                         p_source_type     	IN VARCHAR2,
                         p_source_code     	IN VARCHAR2,
			 p_payroll_id		IN NUMBER,
                         p_time_period_id  	IN NUMBER,
                         p_batch_name      	IN VARCHAR2,
			 p_business_group_id	IN NUMBER,
			 p_set_of_books_id	IN NUMBER,
                         p_start_asg_id         IN NUMBER,
                         p_end_asg_id           IN NUMBER) IS


  --- changed cursor for 5454270
CURSOR payroll_control_cur IS
  SELECT payroll_control_id,
         source_type,        /* Bug 1874696 Introduced source type */
	 currency_code	-- Introduced for bug fix 2916848
  FROM   psp_payroll_controls
  WHERE  cdl_payroll_Action_id = g_payroll_action_id;


/* Bug 2663344 reverted change done for 1874696,re-introduced per_time_periods */
  CURSOR payroll_cur(P_PAYROLL_CONTROL_ID  IN  NUMBER) IS
  SELECT ptp.end_date,           --- added for 2663344
         ppl.payroll_line_id,
         ppl.assignment_id,
         ppl.element_type_id,
         ppl.dr_cr_flag,
         nvl(ppl.accounting_date, ppl.effective_Date) effective_date,
         ppsl.payroll_sub_line_id,
         ppsl.sub_line_start_date,
         ppsl.sub_line_end_date,
         ppl.cost_id,  --- 5090002
	DECODE(g_dff_grouping_option, 'Y', ppsl.attribute_category, NULL) attribute_category,	-- Introduced DFF columns for bug fix 2908859
	DECODE(g_dff_grouping_option, 'Y', ppsl.attribute1, NULL) attribute1,
	DECODE(g_dff_grouping_option, 'Y', ppsl.attribute2, NULL) attribute2,
	DECODE(g_dff_grouping_option, 'Y', ppsl.attribute3, NULL) attribute3,
	DECODE(g_dff_grouping_option, 'Y', ppsl.attribute4, NULL) attribute4,
	DECODE(g_dff_grouping_option, 'Y', ppsl.attribute5, NULL) attribute5,
	DECODE(g_dff_grouping_option, 'Y', ppsl.attribute6, NULL) attribute6,
	DECODE(g_dff_grouping_option, 'Y', ppsl.attribute7, NULL) attribute7,
	DECODE(g_dff_grouping_option, 'Y', ppsl.attribute8, NULL) attribute8,
	DECODE(g_dff_grouping_option, 'Y', ppsl.attribute9, NULL) attribute9,
	DECODE(g_dff_grouping_option, 'Y', ppsl.attribute10, NULL) attribute10,
         round(ppsl.daily_rate, g_ext_precision) daily_rate,  -- Get only 2 decimal places Modified to currency extended precision for bug fix 2916848
         round(ppsl.pay_amount, g_precision) pay_amount,	-- Bug 2916848: Modified to currency precision (from 2)
         ppl.person_id,
         ppl.payroll_action_type,
	or_gl_code_combination_id,
	or_project_id,
	or_task_id,
	or_award_id,
	or_expenditure_org_id,
	or_expenditure_type
  FROM   psp_payroll_lines ppl,
         psp_payroll_sub_lines ppsl,
         per_time_periods ptp,
         psp_payroll_controls ppc
  WHERE  ppl.payroll_line_id = ppsl.payroll_line_id
  AND    ppl.status_code = 'N'
  AND    ppsl.pay_amount <> 0
  AND    ppl.payroll_control_id = p_payroll_control_id
  AND    ppc.time_period_id = ptp.time_period_id
  AND    ppc.payroll_control_id = ppl.payroll_control_id
  AND    ppl.assignment_id between p_start_asg_id and p_end_asg_id
  ORDER BY ppl.person_id,ppl.assignment_id,ppl.payroll_line_id, ppl.element_type_id;


  l_org_def_labor_schedule   VARCHAR2(3)  := psp_general.get_specific_profile('PSP_DEFAULT_SCHEDULE');
  l_org_def_account          VARCHAR2(3)  := psp_general.get_specific_profile('PSP_DEFAULT_ACCOUNT');
  --
  l_element_type_id          NUMBER(9);
  l_payroll_sub_line_id      NUMBER(10);
  l_sub_line_start_date      DATE;
  l_sub_line_end_date        DATE;
  l_daily_rate               NUMBER;
  l_payroll_start_date       DATE;
  l_proc_executed            VARCHAR2(10);
  l_batch_count              NUMBER  := 0;
  --
  l_return_status            VARCHAR2(1);
  l_msg_count                NUMBER;
  l_msg_data                 VARCHAR2(2000);
  l_msg_index_out            NUMBER;
  --
  l_dist_message             VARCHAR2(200);
  --
  payroll_control_rec		payroll_control_cur%ROWTYPE;
  payroll_rec			payroll_cur%ROWTYPE;
  l_total_dist_dr_amount	NUMBER := 0;
  l_total_dist_cr_amount	NUMBER := 0;
  l_sub_line_dist_amount	NUMBER := 0;
  l_effective_date		DATE;
  -- exception corresponding to ORA-000054
  RECORD_ALREADY_LOCKED		EXCEPTION;
  EXCESS_SALARY_FOUND           EXCEPTION;
  PRAGMA EXCEPTION_INIT (RECORD_ALREADY_LOCKED, -54);
  l_dummy_id			NUMBER(10);
  l_no_business_days		NUMBER;
---
  l_excess_sal                  VARCHAR2(12);
  l_emp_name                    VARCHAR2(30);
  l_source_type_desc            VARCHAR2(15);
  l_sub_start_dt                VARCHAR2(12);
  l_sub_end_dt                  VARCHAR2(12);
  l_total_dr_pay_amount		number := 0;
  l_total_cr_pay_amount		number := 0;
  l_last_working_date		DATE;
  l_count                       integer;
  l_prev_payroll_line_id        integer;   --- 5090002

  cursor check_adj_exists is
  select count(1)
    from psp_adjustment_lines_history
   where assignment_id = payroll_rec.assignment_id
     and distribution_date = l_payroll_start_date
     and adjustment_batch_name is null
     and reversal_entry_flag is null
     and element_type_id = payroll_rec.element_type_id
     and original_line_flag = 'N';
  cursor get_adjusted_percentages is
  select project_id,
         task_id,
         award_id,
         expenditure_type,
         expenditure_organization_id,
         gl_code_combination_id,
         sum(decode(dr_Cr_Flag, 'D', distribution_amount, - distribution_amount)) sum_dist_amount,
          attribute_category,
                  attribute1,
                  attribute2,
                  attribute3,
                  attribute4,
                  attribute5,
                  attribute6,
                  attribute7,
                  attribute8,
                  attribute9,
                  attribute10
    from ( select psl.project_id,
                  psl.task_id,
                  psl.award_id,
                  psl.expenditure_organization_id,
                  psl.expenditure_type,
                  psl.gl_code_combination_id,
                  pdl.distribution_amount,
                  psl.dr_Cr_flag,
                  pdl.attribute_category,
                  pdl.attribute1,
                  pdl.attribute2,
                  pdl.attribute3,
                  pdl.attribute4,
                  pdl.attribute5,
                  pdl.attribute6,
                  pdl.attribute7,
                  pdl.attribute8,
                  pdl.attribute9,
                  pdl.attribute10
             from psp_summary_lines psl,
                  psp_distribution_lines_history pdl,
                  psp_payroll_lines ppl,
                  psp_payroll_sub_lines ppsl
            where pdl.summary_line_id = psl.summary_line_id
              and pdl.reversal_entry_flag is null
              and pdl.adjustment_batch_name is null
              and psl.person_id = payroll_rec.person_id
              and psl.assignment_id = payroll_rec.assignment_id
              and pdl.distribution_date = l_payroll_start_date
              and pdl.payroll_sub_line_id = ppsl.payroll_sub_line_id
              and ppsl.payroll_line_id = ppl.payroll_line_id
              and ppl.element_type_id = payroll_rec.element_type_id
            union all
           select project_id,
                  task_id,
                  award_id,
                  expenditure_organization_id,
                  expenditure_type,
                  gl_code_combination_id,
                  distribution_amount,
                  dr_Cr_flag,
                  attribute_category,
                  attribute1,
                  attribute2,
                  attribute3,
                  attribute4,
                  attribute5,
                  attribute6,
                  attribute7,
                  attribute8,
                  attribute9,
                  attribute10
             from psp_adjustment_lines_history
            where reversal_entry_flag is null
              and adjustment_batch_name is null
              and assignment_id = payroll_rec.assignment_id
              and distribution_date = l_payroll_start_date
              and original_line_flag = 'N'
              and element_type_id = payroll_rec.element_type_id)
      group by project_id,
               task_id,
               award_id,
               expenditure_organization_id,
               expenditure_type,
               gl_code_combination_id,
                attribute_category,
                  attribute1,
                  attribute2,
                  attribute3,
                  attribute4,
                  attribute5,
                  attribute6,
                  attribute7,
                  attribute8,
                  attribute9,
                  attribute10;
TYPE v_num_array IS TABLE OF NUMBER(15) INDEX BY BINARY_INTEGER;
TYPE v_num2_array IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE v_char_array IS TABLE OF varchar2(150) INDEX BY BINARY_INTEGER;
    project_id_array  v_num_array;
    award_id_array v_num_array;
    task_id_array v_num_array;
    exp_org_array v_num_array;
    gl_ccid_array v_num_array;
    exp_type_array v_char_array;
    adj_amount_array v_num2_array;
    adj_percent_array v_num_array;
    attribute_category_array v_char_array;
    attribute1_array v_char_array;
    attribute2_array v_char_array;
   attribute3_array v_char_array;
   attribute4_array v_char_array;
   attribute5_array v_char_array;
   attribute6_array v_char_array;
   attribute7_array v_char_array;
   attribute8_array v_char_array;
   attribute9_array v_char_array;
   attribute10_array v_char_array;
    l_adj_dff_flag varchar2(1);
    l_sum_adj_amount number;
    l_tot_dist_amount number;
    l_dist_amount number;
    l_gl_project_flag varchar2(1);
    l_action_parameter_group   VARCHAR2(30)  := psp_general.get_specific_profile('ACTION_PARAMETER_GROUPS'); --6661707

    cursor get_tgl_revb_acc_date  is
    select nvl(parameter_value, 'P') parameter_value
    from PAY_ACTION_PARAMETER_VALUES
    where parameter_name = 'TGL_REVB_ACC_DATE'
    and action_parameter_group_id = l_action_parameter_group;

    l_tgl_revb_acc_date varchar2(10);

 BEGIN
  hr_utility.trace('CDL procedure begin');
  g_msg := '';
  g_error_api_path := '';

   hr_utility.trace('CDL procedure: g_cap_element_set_id = '||g_cap_element_set_id);
   hr_utility.trace('CDL procedure: g_salary_cap_option='|| g_salary_cap_option);

   open get_tgl_revb_acc_date;
   fetch get_tgl_revb_acc_date into l_TGL_REVB_ACC_DATE;
   if get_tgl_revb_acc_date%NOTFOUND then
     l_TGL_REVB_ACC_DATE := 'P';
   end if;
   close get_tgl_revb_acc_date;

  fnd_msg_pub.initialize;
  OPEN payroll_control_cur;
  LOOP
   l_total_dr_pay_amount		:= 0;
   l_total_cr_pay_amount		:= 0;
   FETCH payroll_control_cur INTO payroll_control_rec;
   IF payroll_control_cur%NOTFOUND THEN
    CLOSE payroll_control_cur;
    EXIT;
   END IF;
   BEGIN

--	Introduced the following for bug fix 2916848
	psp_general.get_currency_precision(payroll_control_rec.currency_code, g_precision, g_ext_precision);
--	End of bug fix 2916848

    OPEN  payroll_cur(payroll_control_rec.payroll_control_id);
   LOOP
     l_sub_line_dist_amount := 0;
     g_tot_dist_amount := 0;
     FETCH payroll_cur INTO payroll_rec;
     hr_utility.trace('CDL procedure: payroll_rec='|| payroll_control_rec.payroll_control_id);
    --#fnd_file.put_line(fnd_file.log,'asg id, payroll_sub_line_id ='|| payroll_Rec.assignment_id||','||payroll_rec.payroll_sub_line_id);

     IF payroll_cur%NOTFOUND
     THEN
	-- dbms_output.put_line('in ayroll_cur');
        CLOSE payroll_cur;
        EXIT;
     END IF;

     --- 5090002 get retro element parent
     if nvl(payroll_rec.payroll_action_type,'X') = 'L' then
        if nvl(l_prev_payroll_line_id, -999) <> payroll_rec.payroll_line_id then
             l_prev_payroll_line_id := payroll_rec.payroll_line_id;
              g_retro_parent_element_id := get_retro_parent_element_id(payroll_rec.cost_id);
        end if;
     else
        if g_retro_parent_element_id is not null then
           g_retro_parent_element_id := null;
         end if;
     end if;

     l_payroll_sub_line_id	:= payroll_rec.payroll_sub_line_id;
     ---
    l_effective_date := payroll_rec.effective_date;
    if payroll_control_rec.source_type = 'N' then
      if g_use_eff_date = 'Y' then
         null;
      else
         l_effective_date := payroll_rec.end_date;
      end if;
    end if;
    g_gl_effective_date := l_effective_date;

     l_payroll_start_date := payroll_rec.sub_line_start_date;
     -- FInd out NOCOPY the last working date for a period
     l_last_working_date := psp_general.last_working_date(payroll_rec.sub_line_end_date);


     IF payroll_rec.daily_rate = 0 THEN
       l_no_business_days := psp_general.business_days(payroll_rec.sub_line_start_date,payroll_rec.sub_line_end_date,payroll_rec.assignment_id);
	   IF NVL(l_no_business_days,0)=0 THEN
	      l_no_business_days := 1;
	   END IF;
       l_daily_rate := round((payroll_rec.pay_amount / l_no_business_days), g_ext_precision);   -- Modified to currency extended precision for bug fix 2916848, 3109943
        -- 4304623
        update psp_payroll_sub_lines
           set daily_rate = l_daily_rate
         where payroll_sub_line_id = payroll_rec.payroll_sub_line_id;
     ELSE
       l_daily_rate  := round(payroll_rec.daily_rate, g_ext_precision); -- Modified to currency extended precision for bug fix 2916848 ,3109943

     END IF;

     LOOP
       -- For each date within each payroll sub-line, find the appropriate schedule hierarchy
       -- Skip the processing if the date encountered is a Saturday or Sunday
       /*Bug 5557724: to_char(some_date,'D') returns a number indicating the weekday. However, for a given date, this number
       returned varies with NLS_TERRITORY. So replaced it with to_char(some_date,'DY') that gives the abbreviated day. */
--       IF to_char(l_payroll_start_date, 'DY', 'nls_date_language=english') NOT IN ('SUN', 'SAT')
         IF (psp_general.business_days(l_payroll_start_date, l_payroll_start_date, payroll_rec.assignment_id) > 0)
           OR payroll_rec.sub_line_start_date = payroll_rec.sub_line_end_date THEN
       --For Bug 1994421 : Zero work Days build :Introduced the above OR condtion

          -- changed the if condn for 2663344
          if payroll_control_rec.source_type <> 'N' OR nvl(g_use_eff_date,'N') <> 'Y' then
            l_effective_date := l_payroll_start_date;
          end if;

          if payroll_rec.payroll_action_type <> 'R' and l_tgl_revb_acc_date = 'C' then
            l_effective_date := payroll_rec.effective_date;
          end if;
          l_count := 0;
          if payroll_rec.payroll_action_type <> 'R' then  --- only for non regular runs
           hr_utility.trace('l_payroll_action_type ='||payroll_rec.payroll_action_type||'start date, assig id ='|| l_payroll_start_date||','||payroll_rec.assignment_id);
               open check_adj_exists;
               fetch check_adj_exists into l_count;
               close check_adj_exists;
           end if;

           -- Introduced BEGIN, EXCEPTION, END for bug 7041286
          BEGIN
          fnd_file.put_line (fnd_file.LOG,'Entering begin inside loop3');

           if payroll_rec.payroll_action_type <> 'R' and l_count > 0 then  --- only for non regular runs and pre-adjusted
                    hr_utility.trace('l_count = '||l_count);
                    open get_adjusted_percentages;
                    Fetch get_adjusted_percentages bulk collect into project_id_array,
                                                             Task_id_array,
                                                            award_id_array,
                                                            exp_type_array,
                                                             exp_org_array,
                                                             gl_ccid_array,
                                                             adj_amount_array,
                                                             attribute_category_array ,
                                                             attribute1_array ,
                                                             attribute2_array ,
                                                            attribute3_array ,
                                                            attribute4_array ,
                                                            attribute5_array ,
                                                            attribute6_array ,
                                                            attribute7_array ,
                                                            attribute8_array ,
                                                            attribute9_array ,
                                                            attribute10_array;
                     close get_adjusted_percentages;
                     begin
                        if project_id_array.count = 0 and gl_ccid_array.count = 0 then
                                raise fnd_api.g_exc_unexpected_error;
                        end if;
                     exception
                     when others then
                             fnd_msg_pub.add_exc_msg('PSP_LABOR_DIST','ADJUSTED_PERCENTAGES');
                             raise;
                     end;
                     hr_utility.trace('Close get_adjusted_percentages array_size='||project_id_array.count);
                     l_sum_adj_amount := 0;
                     for I in 1..adj_amount_array.count
                     loop
                       l_sum_adj_amount := l_sum_adj_amount + adj_amount_array(i);
                     end loop;
                     for I in 1..adj_amount_array.count
                     loop
                        adj_percent_array(i) := adj_amount_array(i) * 100 / l_sum_adj_amount;
                     end loop;
                     hr_utility.trace('adj_amount_array-100');
                -----create distributions based on this array.
                L_tot_dist_amount :=  0;
                for I in 1..adj_amount_array.count
                loop
                 hr_utility.trace('Entered array loop.. adj array');
                if project_id_array(i) is null then
                    l_gl_project_flag :='G';
                    if nvl(g_use_eff_date, 'N') <> 'Y' then
                        l_effective_date := g_gl_effective_date;
                    end if;
                else
                   l_gl_project_flag := 'P';
                end if;
                if i < adj_amount_array.count then
                    l_dist_amount := round((l_daily_rate * adj_percent_array(i)/100), g_precision);
                    hr_utility.trace('l_daily_rate, l_dist_amount, adj_percent ='|| l_daily_rate||','||l_dist_amount||','||adj_percent_array(i));
                    l_tot_dist_amount := l_tot_dist_amount + l_dist_amount;
                else   --- last line will have the remaining amount.
                   l_dist_amount :=l_daily_rate - l_tot_dist_amount;
                   l_dist_amount := round(l_dist_amount, g_precision);
                end if;
                g_tot_dist_amount := g_tot_dist_amount + l_dist_amount;
      if (      attribute_category_array(i) is not null or
                attribute1_array(i) is not null or
                attribute2_array(i) is not null or
                attribute3_array(i) is not null or
                attribute4_array(i) is not null or
                attribute5_array(i) is not null or
                attribute6_array(i) is not null or
                attribute7_array(i) is not null or
                attribute8_array(i) is not null or
                attribute9_array(i) is not null or
                attribute10_array(i) is not null) then
            l_adj_dff_flag := 'Y';
        else
            l_adj_dff_flag := 'N';
        end if;
        INSERT INTO PSP_DISTRIBUTION_LINES(
                DISTRIBUTION_LINE_ID,
                PAYROLL_SUB_LINE_ID,
                DISTRIBUTION_DATE,
                EFFECTIVE_DATE,
                DISTRIBUTION_AMOUNT,
                STATUS_CODE,
                GL_PROJECT_FLAG,
                business_group_id,
                set_of_books_id,
                attribute_category,                     -- Introduced DFF columns for bug fix 2908859
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
                adj_account_flag,
                CAP_EXCESS_GLCCID ,
                CAP_EXCESS_PROJECT_ID,
                CAP_EXCESS_AWARD_ID,
                CAP_EXCESS_TASK_ID,
                CAP_EXCESS_EXP_ORG_ID,
                CAP_EXCESS_EXP_TYPE)
        VALUES(
                PSP_DISTRIBUTION_LINES_S.NEXTVAL,
                payroll_rec.PAYROLL_SUB_LINE_ID,
                L_payroll_start_DATE,
                L_EFFECTIVE_DATE,
                L_DIST_AMOUNT,
                'N',
                L_GL_PROJECT_FLAG,
                P_BUSINESS_GROUP_ID,
                P_SET_OF_BOOKS_ID,
                decode(l_adj_dff_flag,'Y', attribute_category_array(i), payroll_rec.attribute_category),
                decode(l_adj_dff_flag,'Y', attribute1_array(i), payroll_rec.attribute1),
                decode(l_adj_dff_flag,'Y', attribute2_array(i), payroll_rec.attribute2),
                decode(l_adj_dff_flag,'Y', attribute3_array(i), payroll_rec.attribute3),
                decode(l_adj_dff_flag,'Y', attribute4_array(i), payroll_rec.attribute4),
                decode(l_adj_dff_flag,'Y', attribute5_array(i), payroll_rec.attribute5),
                decode(l_adj_dff_flag,'Y', attribute6_array(i), payroll_rec.attribute6),
                decode(l_adj_dff_flag,'Y', attribute7_array(i), payroll_rec.attribute7),
                decode(l_adj_dff_flag,'Y', attribute8_array(i), payroll_rec.attribute8),
                decode(l_adj_dff_flag,'Y', attribute9_array(i), payroll_rec.attribute9),
                decode(l_adj_dff_flag,'Y', attribute10_array(i), payroll_rec.attribute10),
                'Y',
                gl_ccid_array(i),
                project_id_array(i),
                award_id_array(i),
                Task_id_array(i),
                exp_org_array(i),
                exp_type_array(i));

             end loop;

               else
        -- dbms_output.put_line('before get dist lines');
           hr_utility.trace('Calling Get_distribution_lines');
          Get_Distribution_Lines
                      (p_proc_executed       => l_proc_executed,
                       p_person_id           => payroll_rec.person_id,
                       p_sub_line_id         => payroll_rec.payroll_sub_line_id,
                       p_assignment_id       => payroll_rec.assignment_id,
                       p_element_type_id     => payroll_rec.element_type_id,
                       p_payroll_start_date  => l_payroll_start_date ,
                       p_daily_rate          => l_daily_rate,
                       p_effective_date      => l_effective_date,
                       p_mode                => 'I',
		       p_business_group_id   => p_business_group_id,
		       p_set_of_books_id     => p_set_of_books_id,
			p_attribute_category	=>	payroll_rec.attribute_category,		-- Introduced DFF columns for bug fix 2908859
			p_attribute1		=>	payroll_rec.attribute1,
			p_attribute2		=>	payroll_rec.attribute2,
			p_attribute3		=>	payroll_rec.attribute3,
			p_attribute4		=>	payroll_rec.attribute4,
			p_attribute5		=>	payroll_rec.attribute5,
			p_attribute6		=>	payroll_rec.attribute6,
			p_attribute7		=>	payroll_rec.attribute7,
			p_attribute8		=>	payroll_rec.attribute8,
			p_attribute9		=>	payroll_rec.attribute9,
			p_attribute10		=>	payroll_rec.attribute10,
			p_or_gl_ccid		=>	payroll_rec.or_gl_code_combination_id,
			p_or_project_id		=>	payroll_rec.or_project_id,
			p_or_task_id		=>	payroll_rec.or_task_id,
			p_or_award_id		=>	payroll_rec.or_award_id,
			p_or_expenditure_org_id	=>	payroll_rec.or_expenditure_org_id,
			p_or_expenditure_type	=>	payroll_rec.or_expenditure_type,
                       p_return_status       => l_return_status);

	   end if;

          EXCEPTION   ---- Introduced BEGIN, EXCEPTION, END for bug 7041286

	  	WHEN ZERO_DIVIDE
	  	THEN
	  	    fnd_file.put_line (fnd_file.LOG,
	                           'Calling Get_distribution_lines for sub line id - '
	                              || payroll_rec.payroll_sub_line_id );

	            get_distribution_lines (
	               p_proc_executed=> l_proc_executed,
	               p_person_id=> payroll_rec.person_id,
	               p_sub_line_id=> payroll_rec.payroll_sub_line_id,
	               p_assignment_id=> payroll_rec.assignment_id,
	               p_element_type_id=> payroll_rec.element_type_id,
	               p_payroll_start_date=> l_payroll_start_date,
	               p_daily_rate=> l_daily_rate,
	               p_effective_date=> l_effective_date,
	               p_mode=> 'I',
	               p_business_group_id=> p_business_group_id,
	               p_set_of_books_id=> p_set_of_books_id,
	               p_attribute_category=> payroll_rec.attribute_category,
	               p_attribute1=> payroll_rec.attribute1,
	               p_attribute2=> payroll_rec.attribute2,
	               p_attribute3=> payroll_rec.attribute3,
	               p_attribute4=> payroll_rec.attribute4,
	               p_attribute5=> payroll_rec.attribute5,
	               p_attribute6=> payroll_rec.attribute6,
	               p_attribute7=> payroll_rec.attribute7,
	               p_attribute8=> payroll_rec.attribute8,
	               p_attribute9=> payroll_rec.attribute9,
	               p_attribute10=> payroll_rec.attribute10,
	               p_or_gl_ccid=> payroll_rec.or_gl_code_combination_id,
	               p_or_project_id=> payroll_rec.or_project_id,
	               p_or_task_id=> payroll_rec.or_task_id,
	               p_or_award_id=> payroll_rec.or_award_id,
	               p_or_expenditure_org_id=> payroll_rec.or_expenditure_org_id,
	               p_or_expenditure_type=> payroll_rec.or_expenditure_type,
	               p_return_status=> l_return_status
	            );



	            WHEN OTHERS THEN
      			ROLLBACK;

      			fnd_msg_pub.add_exc_msg('PSP_LABOR_DIST','CREATE_LINES2');
       			fnd_message.set_name('PSP','PSP_LD_BATCH_DISTRIBUTED');
      			fnd_message.set_token('NUMB_BATCHES',l_batch_count);
      			fnd_msg_pub.add;
      			retcode := 2;
      			psp_message_s.print_error(p_mode => FND_FILE.LOG,
			    p_print_header => FND_API.G_TRUE);
      			raise;
          END;    -- Introduced BEGIN, EXCEPTION, END for bug 7041286

           IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
               --dbms_output.put_line('error in get dist line sproc ');
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;


          l_sub_line_dist_amount := round((l_sub_line_dist_amount + l_daily_rate), g_precision);	-- Bug 2916848: Modified to currency precision (from 2)

        END IF;             -- ENDIF to_char(l_payroll_start_date, 'D') IN (1, 7)
       l_payroll_start_date := l_payroll_start_date + 1;

       IF trunc(l_payroll_start_date) = trunc(l_last_working_date) THEN
          l_daily_rate := payroll_rec.pay_amount - g_tot_dist_amount;
       ELSIF l_payroll_start_date > payroll_rec.sub_line_end_date THEN
         EXIT;
       END IF;
     END LOOP;

     if payroll_rec.pay_amount <> g_tot_dist_amount
     then
        UPDATE psp_distribution_lines
        SET distribution_amount = distribution_amount +
                                  (payroll_rec.pay_amount - g_tot_dist_amount)
        WHERE distribution_line_id = (select max(distribution_line_id)    -- 2470954 added this SQL
                                      from psp_distribution_lines
                                       where payroll_rec.payroll_sub_line_id = payroll_sub_line_id);
      end if;
	-- total of pay_amout to check at the end for the
	-- difference amount
	if payroll_rec.dr_cr_flag = 'D'
	then
		l_total_dr_pay_amount := l_total_dr_pay_amount +
			payroll_rec.pay_amount;
	elsif payroll_rec.dr_cr_flag = 'C'
	then
		l_total_cr_pay_amount := l_total_cr_pay_amount +
			payroll_rec.pay_amount;
	end if;
	-- dbms_output.put_line('after update ');
     -- END IF;
   END LOOP;
--- changed the if condition to use new globals for 5080403
 if g_asg_autopop = 'Y' or g_asg_element_autopop = 'Y' or g_asg_ele_group_autopop = 'Y' then
         update_dist_schedule_autopop(p_payroll_control_id =>payroll_control_rec.payroll_control_id, p_business_group_id=>p_business_group_id, p_set_of_books_id=>p_Set_of_books_id,p_start_asg_id=>p_start_asg_id, p_end_asg_id=>p_end_asg_id,
                                p_return_Status =>l_return_status);
  end if;

          IF l_org_def_labor_schedule = 'Y' and g_org_schedule_autopop = 'Y' THEN

             update_dist_odls_autopop(p_payroll_control_id => payroll_control_rec.payroll_control_id, p_business_group_id=>p_business_group_id, p_set_of_books_id =>p_set_of_books_id,p_start_asg_id=>p_start_asg_id, p_end_asg_id=>p_end_asg_id,
                                       p_return_status => l_return_status);
          END IF;


     hr_utility.trace(' CDL --> create lines --> before call to apply_salary_cap, g_salary_cap = '||g_salary_cap_option);
     -- if Salary Cap is set to Y then call Apply_salary_cap. Enh 4304623
     If g_salary_cap_option = 'Y' then
         apply_salary_cap(payroll_control_rec.payroll_control_id,
                          payroll_control_rec.currency_code,
                          p_business_group_id,
                          p_Set_of_books_id,
                          p_start_asg_id,
                          p_end_asg_id);

         --- added for 4304623
          if g_excess_account_autopop = 'Y' then
         excess_account_autopop( payroll_control_rec.payroll_control_id,
                                 p_business_group_id,
                                 p_set_of_books_id,
                                 p_start_asg_id,
                                 p_end_asg_id,
                                 l_return_status);
          end if;
     End if;
         --- autopop calls for global element, default account, suspense account .. 5080403
          if g_global_element_autopop = 'Y' then
               generic_account_autopop( payroll_control_rec.payroll_control_id,
                                       p_business_group_id,
                                       p_set_of_books_id,
                                       p_start_asg_id,
                                       p_end_asg_id,
                                       'GLOBAL_ELEMENT');
          end if;
          if g_default_account_autopop = 'Y' and l_org_def_account = 'Y' then
               generic_account_autopop( payroll_control_rec.payroll_control_id,
                                       p_business_group_id,
                                       p_set_of_books_id,
                                       p_start_asg_id,
                                       p_end_asg_id,
                                       'DEFAULT_ACCOUNT');
          end if;
          if g_suspense_account_autopop = 'Y' then
               generic_account_autopop( payroll_control_rec.payroll_control_id,
                                       p_business_group_id,
                                       p_set_of_books_id,
                                       p_start_asg_id,
                                       p_end_asg_id,
                                       'SUSPENSE');
          end if;

   l_batch_count := l_batch_count + 1;
   --
   EXCEPTION
    WHEN RECORD_ALREADY_LOCKED THEN
      NULL;
   END;

  END LOOP;

  fnd_message.set_name('PSP','PSP_LD_BATCH_DISTRIBUTED');
  fnd_message.set_token('NUMB_BATCHES',l_batch_count);
  -- l_dist_message := fnd_message.get;
  -- return success to the concurrent program
  -- errbuf  := SUBSTR(g_msg || chr(10) || l_dist_message,1,230);
  retcode := 0;
  /*********************************************************************
  ** Added by Bijoy - 08/06/99 to display error in consurrent log
  *******************************************************************/
  fnd_msg_pub.add;
  psp_message_s.print_success;

  EXCEPTION
WHEN EXCESS_SALARY_FOUND THEN
      ROLLBACK;
      g_error_api_path := SUBSTR('CREATE_LINES 1:'||g_error_api_path,1,230);
      fnd_message.set_name('PSP','PSP_EXCESS_SALARY_FOUND');
      fnd_message.set_token('EXCESS_SAL',l_excess_sal);
      fnd_message.set_token('EMP_NAME',l_emp_name);
      fnd_message.set_token('SOURCE_DESC',l_source_type_desc);
      fnd_message.set_token('START_DATE',l_sub_start_dt);
      fnd_message.set_token('END_DATE',l_sub_end_dt);
  /*********************************************************************
  ** Added by Bijoy - 08/06/99 to display error in consurrent log
  *******************************************************************/
      fnd_msg_pub.add;
      retcode := 2;
      psp_message_s.print_error(p_mode => FND_FILE.LOG,
			    p_print_header => FND_API.G_TRUE);
      -- l_dist_message := fnd_message.get;

      -- errbuf := SUBSTR(g_msg || chr(10) || l_msg_data || chr(10) || l_dist_message||chr(10)||chr(10)||g_error_api_path,1,230);
        raise;    --- for nih sal cap 4304623
       WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK;
  /*********************************************************************
  ** Added by Bijoy - 08/06/99 to display error in consurrent log
  *******************************************************************/
      g_error_api_path := SUBSTR('CREATE_LINES:'||g_error_api_path,1,230);
      /* fnd_msg_pub.get(p_msg_index     =>  FND_MSG_PUB.G_FIRST,
                      p_encoded       =>  FND_API.G_FALSE,
                      p_data          =>  l_msg_data,
                      p_msg_index_out =>  l_msg_count); */

      fnd_message.set_name('PSP','PSP_LD_BATCH_DISTRIBUTED');
      fnd_message.set_token('NUMB_BATCHES',l_batch_count);
      fnd_msg_pub.add;
      -- l_dist_message := fnd_message.get;

      -- errbuf := SUBSTR(g_msg || chr(10) || l_msg_data || chr(10) || l_dist_message||chr(10)||chr(10)||g_error_api_path,1,230);
      retcode := 2;
      psp_message_s.print_error(p_mode => FND_FILE.LOG,
			    p_print_header => FND_API.G_TRUE);

        raise;    --- for nih sal cap 4304623
    WHEN OTHERS THEN
      ROLLBACK;
      -- g_error_api_path := SUBSTR('CREATE_LINES:'||g_error_api_path,1,230);
      fnd_msg_pub.add_exc_msg('PSP_LABOR_DIST','CREATE_LINES2');
      /* fnd_msg_pub.get(p_msg_index     =>  FND_MSG_PUB.G_FIRST,
                      p_encoded       =>  FND_API.G_FALSE,
                      p_data          =>  l_msg_data,
                      p_msg_index_out =>  l_msg_count); */

      fnd_message.set_name('PSP','PSP_LD_BATCH_DISTRIBUTED');
      fnd_message.set_token('NUMB_BATCHES',l_batch_count);
      fnd_msg_pub.add;
      -- l_dist_message := fnd_message.get;

      /* errbuf := SUBSTR(g_msg || chr(10) || l_msg_data || chr(10) || l_dist_message||chr(10)||chr(10)||g_error_api_path,1,230); */
      retcode := 2;
      psp_message_s.print_error(p_mode => FND_FILE.LOG,
			    p_print_header => FND_API.G_TRUE);
        raise;    --- for nih sal cap 4304623
  END;

---------------------- G L O B A L   E A R N I N G S   E L E M E N T -----------------------

 PROCEDURE global_earnings_element(p_proc_executed       OUT NOCOPY VARCHAR2,
                                   p_person_id           IN  NUMBER,
                                   p_sub_line_id         IN  NUMBER,
                                   p_assignment_id       IN  NUMBER,
                                   p_element_type_id     IN  NUMBER,
                                   p_payroll_start_date  IN  DATE,
                                   p_daily_rate          IN  NUMBER,
                                   p_org_def_account     IN  VARCHAR2,
                                   p_effective_date      IN  DATE,
                                   p_mode                IN  VARCHAR2 := 'I',
				   p_business_group_id	 IN  NUMBER,
				   p_set_of_books_id	 IN  NUMBER,
				p_attribute_category	IN	VARCHAR2,		-- Introduced DFF parameters for bug fix 2908859
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
                                   p_return_status       OUT NOCOPY VARCHAR2) IS

 CURSOR global_element_cur(P_ELEMENT_TYPE_ID    NUMBER,
                           P_PAYROLL_START_DATE DATE) IS
 SELECT element_account_id,
        peta.gl_code_combination_id,
        peta.project_id,
        peta.task_id,
        peta.award_id,
        round(peta.percent,2) percent,
        peta.expenditure_type,
        peta.expenditure_organization_id,
        peta.start_date_active,
        peta.end_date_active,   --- added decode below for 5014193
	decode(g_dff_grouping_option, 'Y', NVL(p_attribute_category, peta.attribute_category)) attribute_category,		-- Introduced DFF columns for bug fix 2908859
	decode(g_dff_grouping_option, 'Y', NVL(p_attribute1, peta.attribute1)) attribute1,
	decode(g_dff_grouping_option, 'Y', NVL(p_attribute2, peta.attribute2)) attribute2,
	decode(g_dff_grouping_option, 'Y', NVL(p_attribute3, peta.attribute3)) attribute3,
	decode(g_dff_grouping_option, 'Y', NVL(p_attribute4, peta.attribute4)) attribute4,
	decode(g_dff_grouping_option, 'Y', NVL(p_attribute5, peta.attribute5)) attribute5,
	decode(g_dff_grouping_option, 'Y', NVL(p_attribute6, peta.attribute6)) attribute6,
	decode(g_dff_grouping_option, 'Y', NVL(p_attribute7, peta.attribute7)) attribute7,
	decode(g_dff_grouping_option, 'Y', NVL(p_attribute8, peta.attribute8)) attribute8,
	decode(g_dff_grouping_option, 'Y', NVL(p_attribute9, peta.attribute9)) attribute9,
	decode(g_dff_grouping_option, 'Y', NVL(p_attribute10, peta.attribute10)) attribute10
 FROM   psp_element_type_accounts peta
 WHERE  business_group_id = p_business_group_id
 AND    set_of_books_id  = p_set_of_books_id
 AND    peta.element_type_id = p_element_type_id
 AND    p_payroll_start_date BETWEEN peta.start_date_active AND
                                         nvl(peta.end_date_active,p_payroll_start_date) ;


  l_dist_amount                    NUMBER       := 0;
  l_tot_dist_amount                NUMBER       := 0;
  l_bal_dist_amount                NUMBER       := 0;
  l_tot_percent                    NUMBER       := 0;

  l_element_account_id             NUMBER(9);
  l_gl_code_combination_id         NUMBER(15);
  l_project_id                     NUMBER(15);
  l_task_id                        NUMBER(15);
  l_award_id                       NUMBER(15);
  l_expenditure_type               VARCHAR2(30);
  l_expenditure_org_id             NUMBER(15);
  l_schedule_percent               NUMBER;
  l_effective_start_date           DATE;
  l_effective_end_date             DATE;
	l_attribute_category	VARCHAR2(30);			-- Introduced DFF variables for bug fix 2908859
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
  x_proc_executed                  VARCHAR2(10) := 'TRUE';
  l_rec_count                      NUMBER := 0;
  l_return_status                  VARCHAR2(1);
  -- l_effective_date                 DATE; Bug 1874696
  l_gl_project_flag                VARCHAR2(1);
  l_linkage_status                 VARCHAR2(50);
  l_patc_status                    VARCHAR2(50);
  l_billable_flag                  VARCHAR2(1);

  l_msg_count     NUMBER;

  l_msg_app       VARCHAR2(2000);
  l_msg_type      varchar2(2000);
  l_msg_token1    varchar2(2000);
  l_msg_token2    varchar2(2000);
  l_msg_token3    varchar2(2000);
  --l_award_status  varchar2(50);  -- for bug fix 1931680
  l_award_status  varchar2(200);

 BEGIN

     p_proc_executed := 'TRUE';

     -- For the payroll date passed to the procedure, check if there is global element
     -- override. If exists, then fetch the schedule percent and calculate the
     -- total distribution amount by adding the distribution amount in each of the lines.
     -- If global element override does not exist,set the p_proc_executed flag as FALSE

     OPEN global_element_cur(p_element_type_id,p_payroll_start_date);
     LOOP
           l_patc_status   := NULL;
           l_linkage_status:= NULL;
           l_billable_flag := NULL;
	   l_award_status  := NULL;

           FETCH global_element_cur INTO
				l_element_account_id,
                                l_gl_code_combination_id,
  				l_project_id,
  				l_task_id,
  				l_award_id,
  				l_schedule_percent,
                                l_expenditure_type,
                                l_expenditure_org_id,
                                l_effective_start_date,
                                l_effective_end_date,
				l_attribute_category,
				l_attribute1,
				l_attribute2,
				l_attribute3,
				l_attribute4,
				l_attribute5,
				l_attribute6,
				l_attribute7,
				l_attribute8,
				l_attribute9,
				l_attribute10;

           l_rec_count := l_rec_count + 1;
           IF global_element_cur%NOTFOUND THEN
             IF l_rec_count = 1 THEN
               p_proc_executed := 'FALSE';
               CLOSE global_element_cur ;
               RETURN;
             ELSE
               CLOSE global_element_cur ;
               EXIT;
             END IF;
           END IF;

           l_tot_percent := l_tot_percent + l_schedule_percent;
           IF l_tot_percent <= 100 THEN
             l_dist_amount := round((p_daily_rate * l_schedule_percent/100), g_precision); 	-- Bug 2916848: Modified to currency precision (from 2)
           -- ELSIF l_tot_percent = 100 THEN
           --  l_dist_amount := round((p_daily_rate - l_tot_dist_amount),2);
           ELSIF l_tot_percent > 100 THEN
	     	Get_assign_number(p_assignment_id
			      ,p_payroll_start_date
			      ,g_assignment_number
			      ,g_employee_number);--Bug 2374680
             	fnd_message.set_name('PSP','PSP_LD_PERCENT_GREATER_100');
             	fnd_message.set_token('PAYROLL_DATE',p_payroll_start_date);
--          	fnd_message.set_token('ASSIGNMENT_ID',p_assignment_id); --Commented for bug 2374680
            	 /* Added assignment_number and employee_number inplace of assignment_id*/
             	fnd_message.set_token('ASSIGNMENT_NUMBER',g_assignment_number);
             	fnd_message.set_token('EMPLOYEE_NUMBER',g_employee_number);
             	fnd_msg_pub.add;
--		Commented for bug fix 2267098 (return status set in exception)
--             p_return_status := fnd_api.g_ret_sts_unexp_error;
		RAISE fnd_api.g_exc_unexpected_error;	-- Introduced for bug 2267098

           END IF;

           l_tot_dist_amount := round((l_tot_dist_amount + l_dist_amount), g_precision);	-- Bug 2916848: Modified to currency precision (from 2)

           IF l_gl_code_combination_id IS NOT NULL THEN
              -- l_effective_date := p_effective_date; Bug 1874696
              l_gl_project_flag := 'G';

              -- insert the record in psp_distribution_lines
              insert_into_distribution_lines(
		P_SUB_LINE_ID,                  -- payroll sub-lines id
 		P_PAYROLL_START_DATE,           -- distribution date
                g_gl_EFFECTIVE_DATE,              -- replaced p_effective_date     -- Bug 2663344
 		L_DIST_AMOUNT,                  -- distribution amount
 		'N',                            -- status code
                NULL,                           -- suspense reason code
                NULL,                           -- default reason code
          	NULL,                           -- schedule line id
 		NULL,                           -- default organization a/c
 		NULL,                           -- suspense organization a/c
 		L_ELEMENT_ACCOUNT_ID,           -- global element type
		NULL,                           -- org default schedule id
                L_GL_PROJECT_FLAG,              -- gl project flag
                NULL,                           -- reversal entry flag
                l_gl_code_combination_id,       -- gl_code_combination_id
                l_project_id,                   -- project_id,
                l_task_id   ,                   -- task_id,
                l_award_id  ,                   -- award_id,
                l_expenditure_org_id,           -- expenditure org id
                l_expenditure_type,             -- expenditure_type
                l_effective_start_date,         -- Eff start date of schedule
                l_effective_end_date,           -- Eff start date of schedule
                p_mode,                         -- 'I' for LD ,'R' for others
	 	p_business_group_id,		-- Business Group Id
		p_set_of_books_id,		-- Set of Books Id
		l_attribute_category,		-- Introduced DFF columns for bug fix 2908859
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

           ELSIF l_gl_code_combination_id IS NULL THEN
            IF g_global_element_autopop = 'Y' THEN   -- introduced for 5080403
                   l_gl_project_flag:='P';

                    insert_into_distribution_lines(
 			P_SUB_LINE_ID,             -- payroll sub-line_id
 			P_PAYROLL_START_DATE,      -- distribution date
                        P_EFFECTIVE_DATE,          -- effective date     Bug 1874696 Changed from l_Effective_date
 			L_DIST_AMOUNT,             -- distribution amount
 			'N',                       -- status code
                        NULL,                      -- suspense reason code
                        NULL,                      -- default reason code
      			NULL,        -- schedule line id
 			NULL,                      -- default organization a/c
 			NULL,                      -- suspense organization a/c
			l_element_account_id,      -- global element type
			NULL,                      -- org default schedule id
                        L_GL_PROJECT_FLAG,         -- gl project flag
                        NULL,                      -- reversal entry flag
                        l_gl_code_combination_id,  -- gl_code_combination_id
                        l_project_id,              -- project_id,
                        l_task_id   ,              -- task_id,
                        l_award_id  ,              -- award_id,
                        l_expenditure_org_id,      -- expenditure org id
                        l_expenditure_type,        -- expenditure_type
                        l_effective_start_date,    -- Eff start date of schedule
                        l_effective_end_date,      -- Eff start date of schedule
                        p_mode,                    -- 'I' for LD ,'R' for others
			p_business_group_id,       -- Business Group Id
                        p_set_of_books_id,         -- Set of Books Id
			l_attribute_category,		-- Introduced DFF columns for bug fix 2908859
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
            ELSE

	    -- modified as per 11i changes
	   -- dbms_output.put_line('Project id 1 '|| to_char(l_project_id));
	   -- dbms_output.put_line('task id 1 '|| to_char(l_task_id));
	   -- dbms_output.put_line('Type 1 '|| p_payroll_start_date);
	   -- dbms_output.put_line('person_id 1 '|| to_char(p_person_id));

	    pa_transactions_pub.validate_transaction(
			x_project_id		=> l_project_id,
			x_task_id		=> l_task_id,
			x_ei_date		=> p_effective_date,  --p_payroll_start_date, Bug 1874696
			x_expenditure_type	=> l_expenditure_type,
			x_non_labor_resource	=> null,
			x_person_id		=> p_person_id,
			x_incurred_by_org_id	=> l_expenditure_org_id,
			x_calling_module	=> 'PSPLDCDB',
			x_msg_application	=> l_msg_app,
			x_msg_type		=> l_msg_type,
			x_msg_token1		=> l_msg_token1,
			x_msg_token2		=> l_msg_token2,
			x_msg_token3		=> l_msg_token3,
			x_msg_count		=> l_msg_count,
			x_msg_data		=> l_patc_status,
			x_billable_flag		=> l_billable_flag,
			p_sys_link_function     => 'ST');            --Bug 5639589: Added parameter


	   -- dbms_output.put_line('patc stat 1 '|| l_patc_status);

	     -- GMS is enabled, PATC validation went fine
	     if l_award_id is not null and l_patc_status is null
	     then
		 gms_transactions_pub.validate_transaction
				(l_project_id,
			   	l_task_id,
				l_award_id,
			   	l_expenditure_type,
				p_effective_date, ---p_payroll_start_date, Bug 1874696
				'PSPLDCDB',
				l_award_status);

/************************************************************
		 if l_award_status is null
		 then
 			project_award_linkage(l_project_id,
                                  l_award_id,
                                  l_linkage_status,
                                  l_return_status);
		else -- fix 2054610
****************************************************************/
                     if l_award_status IS NOT NULL then
		--	l_patc_status := l_award_status;  for bug fix 1931680
                        l_patc_status  := substr(l_award_status,1,50);
	        end if;
	     end if;
             IF ( l_patc_status IS NOT NULL ) OR
--- ( l_linkage_status IS NOT NULL ) OR  2054610
		(l_award_status is not null ) THEN
                suspense_account(
                         x_proc_executed,
                         p_person_id,
                         p_sub_line_id,
                         p_assignment_id,
                         p_payroll_start_date,
                         l_dist_amount,
                         l_patc_status,
                         NULL,
                         NULL,
                         l_element_account_id,
                         NULL,
                         p_effective_date,
                         p_mode,
			 p_business_group_id,
			 p_set_of_books_id,
                         NULL,   ---    for autopop perf. patch
                         l_return_status);

                 IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                 END IF;

              ELSIF (l_patc_status IS NULL) OR
--- (l_linkage_status IS NULL) OR
			(l_award_status is null) THEN
                /* Commented for Bug 1874696
		if l_award_id is not null
		then
                   psp_general.poeta_effective_date(p_payroll_start_date,
                                     l_project_id,
                                     l_award_id,
				     l_task_id,
                                     l_effective_date,
                                     l_return_status);
		elsif l_award_id is null then
                   psp_general.poeta_effective_date(p_payroll_start_date,
                                     l_project_id,
				     l_task_id,
                                     l_effective_date,
                                     l_return_status);
		end if;
                   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                   END IF; */
                   l_gl_project_flag := 'P';

                   -- insert the record in psp_distribution_lines
                   insert_into_distribution_lines(
 		       P_SUB_LINE_ID,              -- payroll sub-lines id
	               P_PAYROLL_START_DATE,       -- distribution date
                       P_EFFECTIVE_DATE,           -- effective date     changed from l_effective_date Bug 1874696
 		       L_DIST_AMOUNT,              -- distribution amount
 		       'N',                        -- status code
                        NULL,                      -- suspense reason code
                        NULL,                      -- default reason code
      			NULL,                      -- schedule line id
 			NULL,                      -- default organization a/c
 			NULL,                      -- suspense organization a/c
 			L_ELEMENT_ACCOUNT_ID,      -- global element type
			NULL,                      -- org default schedule id
                        L_GL_PROJECT_FLAG,         -- gl project flag
                        NULL,                      -- reversal entry flag
                        l_gl_code_combination_id,  -- gl_code_combination_id
                        l_project_id,              -- project_id,
                        l_task_id   ,              -- task_id,
                        l_award_id  ,              -- award_id,
                        l_expenditure_org_id,      -- expenditure org id
                        l_expenditure_type,        -- expenditure_type
                        l_effective_start_date,    -- Eff start date of schedule
                        l_effective_end_date,      -- Eff start date of schedule
                        p_mode,                    -- 'I' for LD ,'R' for others
			p_business_group_id,	   -- Business group Id
			p_set_of_books_id,	   -- Set of Books Id
			l_attribute_category,		-- Introduced DFF columns for bug fix 2908859
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
                END IF;
             END IF;
           END IF;

         END LOOP; -- loop through all the schedule lines having the payroll period date

         l_bal_dist_amount  := round((p_daily_rate - l_tot_dist_amount), g_precision);	-- Bug 2916848: Modified to currency precision (from 2)

         -- IF abs(l_bal_dist_amount) > 0 THEN  -- #1339616
         IF l_tot_percent < 100 THEN

           IF p_org_def_account = 'Y' then
             default_account(
                            x_proc_executed,
                            p_person_id,
                            p_sub_line_id,
                            p_assignment_id,
                            p_payroll_start_date,
                            l_bal_dist_amount,
                            '1',---'LDM_BAL_NOT_100_PERCENT',
                            p_effective_date,
                            p_mode,
			    p_business_group_id,
			    p_attribute_category,	-- Introduced DFF columns for bug fix 2908859
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
			    p_set_of_books_id,
                            l_return_status);
             IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
             END IF;

             IF x_proc_executed = 'FALSE' then
                suspense_account(
                                 x_proc_executed,
                                 p_person_id,
                                 p_sub_line_id,
                                 p_assignment_id,
                                 p_payroll_start_date,
                                 l_bal_dist_amount,
                                 'LDM_BAL_NOT_100_PERCENT',
                                 NULL,
                                 NULL,
                                 NULL,
                                 NULL,
                                 p_effective_date,
                                 p_mode,
			         p_business_group_id,
			         p_set_of_books_id,
                                 NULL,   ---    for autopop perf. patch
                                 l_return_status);
                 IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                 END IF;
               END IF;
           ELSE
                suspense_account(
                                 x_proc_executed,
                                 p_person_id,
                                 p_sub_line_id,
                                 p_assignment_id,
                                 p_payroll_start_date,
                                 l_bal_dist_amount,
                                 'LDM_BAL_NOT_100_PERCENT',
                                 NULL,
                                 NULL,
                                 NULL,
                                 NULL,
                                 p_effective_date,
                                 p_mode,
			         p_business_group_id,
			         p_set_of_books_id,
                                 NULL,   ---    for autopop perf. patch
                                 l_return_status);
                 IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                 END IF;
           END IF;
         END IF;
   --
   p_return_status := fnd_api.g_ret_sts_success;

 EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      g_error_api_path := SUBSTR('GLOBAL_EARNINGS_ELEMENT:'||g_error_api_path,1,230);
      p_return_status := fnd_api.g_ret_sts_unexp_error;

   WHEN OTHERS THEN
      g_error_api_path := SUBSTR('GLOBAL_EARNINGS_ELEMENT:'||g_error_api_path,1,230);
      fnd_msg_pub.add_exc_msg('PSB_LABOR_DIST','GLOBAL_EARNINGS_ELEMENT');
      p_return_status := fnd_api.g_ret_sts_unexp_error;
 END;

----------------------------- E L E M E N T   T Y P E --------------------------------------

 PROCEDURE element_type_hierarchy(p_proc_executed      OUT NOCOPY  VARCHAR2,
                                  p_person_id           IN NUMBER,
                                  p_sub_line_id         IN  NUMBER,
                                  p_assignment_id       IN  NUMBER,
                                  p_element_type_id     IN  NUMBER,
                                  p_payroll_start_date  IN  DATE,
                                  p_daily_rate          IN  NUMBER,
                                  p_org_def_account     IN  VARCHAR2,
                                  p_effective_date      IN  DATE,
                                  p_mode                IN  VARCHAR2 := 'I',
				  p_business_group_id	IN  NUMBER,
				  p_set_of_books_id	IN  NUMBER,
				p_attribute_category	IN	VARCHAR2,		-- Introduced DFF parameters for bug fix 2908859
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
                                  p_return_status       OUT NOCOPY VARCHAR2) IS



  CURSOR sch_lines_element_type_cur(P_ASSIGNMENT_ID      NUMBER,
                                    P_ELEMENT_TYPE_ID    NUMBER,
                                    P_PAYROLL_START_DATE DATE) IS
  SELECT psl.schedule_line_id,
         psl.gl_code_combination_id,
         psl.project_id,
         psl.task_id,
         psl.award_id,
         round(psl.schedule_percent,2) schedule_percent,
         psl.expenditure_type,
         psl.expenditure_organization_id,
         psl.schedule_begin_date,
         nvl(psl.schedule_begin_date,p_payroll_start_date),
          ---- added decode for 5014193
	decode(g_dff_grouping_option, 'Y',NVL(p_attribute_category, psl.attribute_category)) attribute_category,		-- Introduced DFF columns for bug fix 2908859
	decode(g_dff_grouping_option, 'Y',NVL(p_attribute1, psl.attribute1)) attribute1,
	decode(g_dff_grouping_option, 'Y',NVL(p_attribute2, psl.attribute2)) attribute2,
	decode(g_dff_grouping_option, 'Y',NVL(p_attribute3, psl.attribute3)) attribute3,
	decode(g_dff_grouping_option, 'Y',NVL(p_attribute4, psl.attribute4)) attribute4,
	decode(g_dff_grouping_option, 'Y',NVL(p_attribute5, psl.attribute5)) attribute5,
	decode(g_dff_grouping_option, 'Y',NVL(p_attribute6, psl.attribute6)) attribute6,
	decode(g_dff_grouping_option, 'Y',NVL(p_attribute7, psl.attribute7)) attribute7,
	decode(g_dff_grouping_option, 'Y',NVL(p_attribute8, psl.attribute8)) attribute8,
	decode(g_dff_grouping_option, 'Y',NVL(p_attribute9, psl.attribute9)) attribute9,
	decode(g_dff_grouping_option, 'Y',NVL(p_attribute10, psl.attribute10)) attribute10
  FROM   psp_schedule_hierarchy psh,
         psp_schedule_lines     psl
  WHERE  psh.business_group_id = p_business_group_id
  AND    psh.set_of_books_id = p_set_of_books_id
  AND    psh.business_group_id = psl.business_group_id
  AND    psh.set_of_books_id = psl.set_of_books_id
  AND    psh.assignment_id = p_assignment_id
  AND    psh.element_type_id = p_element_type_id
  AND    psh.schedule_hierarchy_id = psl.schedule_hierarchy_id
  AND    p_payroll_start_date BETWEEN psl.schedule_begin_date AND
                                      nvl(psl.schedule_end_date,p_payroll_start_date)
  AND    psl.default_flag IS NULL;

  l_dist_amount                    NUMBER       := 0;
  l_tot_dist_amount                NUMBER       := 0;
  l_bal_dist_amount                NUMBER       := 0;
  l_tot_percent                    NUMBER       := 0;

  l_schedule_line_id               NUMBER(15);
  l_gl_code_combination_id         NUMBER(15);
  l_project_id                     NUMBER(15);
  l_task_id                        NUMBER(15);
  l_award_id                       NUMBER(15);
  l_schedule_percent               NUMBER;
  l_expenditure_type               VARCHAR2(30);
  l_expenditure_org_id             NUMBER(15);
  l_effective_start_date           DATE;
  l_effective_end_date             DATE;
	l_attribute_category	VARCHAR2(30);			-- Introduced DFF variables for bug fix 2908859
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
  x_proc_executed                  VARCHAR2(10) := 'TRUE';
  l_rec_count                      NUMBER := 0;
  l_return_status                  VARCHAR2(1);
  --  l_effective_date                 DATE;  Bug 1874696
  l_gl_project_flag                VARCHAR2(1);
  l_linkage_status                 VARCHAR2(50);
  l_patc_status                    VARCHAR2(50);
  l_billable_flag                  VARCHAR2(1);
  l_msg_count                      NUMBER;
  l_msg_app                        VARCHAR2(2000);
  l_msg_type                       varchar2(2000);
  l_msg_token1                     varchar2(2000);
  l_msg_token2                     varchar2(2000);
  l_msg_token3                     varchar2(2000);
  --l_award_status  varchar2(50);  -- for bug fix 1931680
  l_award_status  varchar2(200);

 BEGIN
         p_proc_executed := 'TRUE';

         -- For the payroll date passed to the procedure, check if there are schedule line(s).
         -- If the schedule line(s) exists, then fetch the schedule percent and calculate the
         -- total distribution amount by adding the distribution amount in each of the lines.
         -- If the schedule line(s) does not exist,set the p_proc_executed flag as FALSE

         OPEN sch_lines_element_type_cur(p_assignment_id,p_element_type_id,p_payroll_start_date);

         LOOP
           l_linkage_status:= NULL;
           l_patc_status   := NULL;
           l_billable_flag := NULL;
	   l_award_status  := NULL;

           FETCH sch_lines_element_type_cur INTO
				l_schedule_line_id,
                                l_gl_code_combination_id,
  				l_project_id,
  				l_task_id,
  				l_award_id,
  				l_schedule_percent,
                                l_expenditure_type,
                                l_expenditure_org_id,
                                l_effective_start_date,
                                l_effective_end_date,
				l_attribute_category,			-- Introduced DFf variable for bug fix 2908859
				l_attribute1,
				l_attribute2,
				l_attribute3,
				l_attribute4,
				l_attribute5,
				l_attribute6,
				l_attribute7,
				l_attribute8,
				l_attribute9,
				l_attribute10;

           l_rec_count := l_rec_count + 1;
           IF sch_lines_element_type_cur%NOTFOUND THEN
             IF l_rec_count = 1 THEN
               p_proc_executed := 'FALSE';
               CLOSE sch_lines_element_type_cur;
               RETURN;
             ELSE
               CLOSE sch_lines_element_type_cur;
               EXIT;
             END IF;
           END IF;


           l_tot_percent := l_tot_percent + l_schedule_percent;
           IF l_tot_percent <= 100 THEN
             l_dist_amount := round((p_daily_rate * l_schedule_percent/100), g_precision); 	-- Bug 2916848: Modified to currency precision (from 2)
           -- ELSIF l_tot_percent = 100 THEN
           --   l_dist_amount := round((p_daily_rate - l_tot_dist_amount),2);
           ELSIF l_tot_percent > 100 THEN
	     	Get_assign_number(p_assignment_id
			      ,p_payroll_start_date
			      ,g_assignment_number
			      ,g_employee_number);--Bug 2374680
             	fnd_message.set_name('PSP','PSP_LD_PERCENT_GREATER_100');
             	fnd_message.set_token('PAYROLL_DATE',p_payroll_start_date);
--          	fnd_message.set_token('ASSIGNMENT_ID',p_assignment_id); --Commented for bug 2374680
               /* Added assignment_number and employee_number inplace of assignment_id*/
            	fnd_message.set_token('ASSIGNMENT_NUMBER',g_assignment_number);
             	fnd_message.set_token('EMPLOYEE_NUMBER',g_employee_number);
             	fnd_msg_pub.add;
--		Commented for bug fix 2267098 (return status set in exception)
--             p_return_status := fnd_api.g_ret_sts_unexp_error;
		RAISE fnd_api.g_exc_unexpected_error;	-- Introduced for bug 2267098
           END IF;

           l_tot_dist_amount := round((l_tot_dist_amount + l_dist_amount), g_precision);	-- Bug 2916848: Modified to currency precision (from 2)

           IF l_gl_code_combination_id IS NOT NULL THEN
              -- l_effective_date := p_effective_date; Bug 1874696
              l_gl_project_flag := 'G';

              -- insert the record in psp_distribution_lines
              insert_into_distribution_lines(
 			P_SUB_LINE_ID,              -- payroll sub-lines id
 			P_PAYROLL_START_DATE,       -- distribution date
                        G_GL_EFFECTIVE_DATE,        --  changed from p_effective_date Bug 2663344
 			L_DIST_AMOUNT,              -- distribution amount
 			'N',                        -- status code
                        NULL,                       -- suspense reason code
                        NULL,                       -- default reason code
      			L_SCHEDULE_LINE_ID,         -- schedule line id
 			NULL,                       -- default organization a/c
 			NULL,                       -- suspense organization a/c
 			NULL,                       -- global element type
			NULL,                       -- org default schedule id
                        L_GL_PROJECT_FLAG,          -- gl project flag
                        NULL,                       -- reversal entry flag
                        l_gl_code_combination_id,   -- gl_code_combination_id
                        l_project_id,               -- project_id,
                        l_task_id   ,               -- task_id,
                        l_award_id  ,               -- award_id,
                        l_expenditure_org_id,       -- expenditure org id
                        l_expenditure_type,         -- expenditure_type
                        l_effective_start_date,    -- Eff start date of schedule
                        l_effective_end_date,      -- Eff start date of schedule
                        p_mode,                    -- 'I' for LD ,'R' for others
			p_business_group_id,       -- Business Group Id
                        p_set_of_books_id,         -- Set of Books Id
			l_attribute_category,		-- Introduced DFF columns for bug fix 2908859
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
           --  END IF; -- Auto Population ON/OFF  for bug fix 2023955


           ELSIF l_gl_code_combination_id IS NULL THEN

               --IF (g_auto_population = 'Y' AND p_mode='I') THEN
               IF (g_asg_element_autopop = 'Y' ) THEN
                    l_gl_project_flag:='P';

                    insert_into_distribution_lines(
 			P_SUB_LINE_ID,             -- payroll sub-lines id
 			P_PAYROLL_START_DATE,      -- distribution date
                        P_EFFECTIVE_DATE,          -- effective date    Changed from l_effective_date Bug 1874696
 			L_DIST_AMOUNT,             -- distribution amount
 			'N',                       -- status code
                        NULL,                      -- suspense reason code
                        NULL,                      -- default reason code
      			L_SCHEDULE_LINE_ID,        -- schedule line id
 			NULL,                      -- default organization a/c
 			NULL,                      -- suspense organization a/c
 			NULL,                      -- global element type
			NULL,                      -- org default schedule id
                        L_GL_PROJECT_FLAG,         -- gl project flag
                        NULL,                      -- reversal entry flag
                        l_gl_code_combination_id,  -- gl_code_combination_id
                        l_project_id,              -- project_id,
                        l_task_id   ,              -- task_id,
                        l_award_id  ,              -- award_id,
                        l_expenditure_org_id,      -- expenditure org id
                        l_expenditure_type,        -- expenditure_type
                        l_effective_start_date,    -- Eff start date of schedule
                        l_effective_end_date,      -- Eff start date of schedule
                        p_mode,                    -- 'I' for LD ,'R' for others
			p_business_group_id,       -- Business Group Id
                        p_set_of_books_id,         -- Set of Books Id
			l_attribute_category,		-- Introduced DFF columns for bug fix 2908859
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

            ELSE
	  -- Auto-Population is OFF. Get project status and insert record.

	      -- modified as per 11i changes
	   -- dbms_output.put_line('Project id 2 '|| to_char(l_project_id));
	   -- dbms_output.put_line('task id 2 '|| to_char(l_task_id));
	   -- dbms_output.put_line('Type 2 '|| l_expenditure_type);
	   -- dbms_output.put_line('Dt 2 '|| to_char(p_payroll_start_date));
	   -- dbms_output.put_line('person_id 2 '|| to_char(p_person_id));
	    pa_transactions_pub.validate_transaction(
			x_project_id		=> l_project_id,
			x_task_id		=> l_task_id,
			x_ei_date		=> p_effective_date, ----p_payroll_start_date, Bug 1874696
			x_expenditure_type	=> l_expenditure_type,
			x_non_labor_resource	=> null,
			x_person_id		=> p_person_id,
			x_incurred_by_org_id	=> l_expenditure_org_id,
			x_calling_module	=> 'PSPLDCDB',
			x_msg_application	=> l_msg_app,
			x_msg_type		=> l_msg_type,
			x_msg_token1		=> l_msg_token1,
			x_msg_token2		=> l_msg_token2,
			x_msg_token3		=> l_msg_token3,
			x_msg_count		=> l_msg_count,
			x_msg_data		=> l_patc_status,
			x_billable_flag		=> l_billable_flag,
			p_sys_link_function     => 'ST');            --Bug 5639589: Added parameter


	   -- dbms_output.put_line('patc stat 2 '|| l_patc_status);
	    -- GMS is enabled and PATC validation went through
	    if l_award_id is not null and l_patc_status is null
             then
                 gms_transactions_pub.validate_transaction
                                (l_project_id,
                                l_task_id,
				l_award_id,
                                l_expenditure_type,
                                p_effective_date, ---p_payroll_start_date, Bug 1874696
                                'PSPLDCDB',
                                l_award_status);
/*****************************************************************

                 if l_award_status is null
                 then
                        project_award_linkage(l_project_id,
                                  l_award_id,
                                  l_linkage_status,
                                  l_return_status);
		 else

-- bug fxi 2054610
******************************************************************/

                if l_award_status is not null then
		--	l_patc_status := l_award_status;  for bug fix 1931680
                        l_patc_status  := substr(l_award_status,1,50);
                 end if;
            end if;

             IF (l_patc_status IS NOT NULL) OR
---  (l_linkage_status IS NOT NULL) OR   2054610
		(l_award_status is not null) THEN
                suspense_account(
                         x_proc_executed,
                         p_person_id,
                         p_sub_line_id,
                         p_assignment_id,
                         p_payroll_start_date,
                         l_dist_amount,
                         l_patc_status,
                         l_schedule_line_id,
                         NULL,
                         NULL,
                         NULL,
                         p_effective_date,
                         p_mode,
			 p_business_group_id,
                         p_set_of_books_id,
                         NULL,   ---    for autopop perf. patch
                         l_return_status);

                 IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                 END IF;

              ELSIF (l_patc_status IS NULL) OR
--- (l_linkage_status IS NULL) OR
		    (l_award_status is null) THEN
               /* Bug 1874696
		 if l_award_id is not null
		 then
                    psp_general.poeta_effective_date(p_payroll_start_date,
                                     l_project_id,
                                     l_award_id,
  				     l_task_id,
                                     l_effective_date,
                                     l_return_status);
		 elsif l_award_id is null
		 then
                    psp_general.poeta_effective_date(p_payroll_start_date,
                                     l_project_id,
  				     l_task_id,
                                     l_effective_date,
                                     l_return_status);
		 end if;
                    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                    END IF; */
                    l_gl_project_flag := 'P';

                    -- insert the record in psp_distribution_lines
                    insert_into_distribution_lines(
 			P_SUB_LINE_ID,             -- payroll sub-lines id
 			P_PAYROLL_START_DATE,      -- distribution date
                        P_EFFECTIVE_DATE,          -- effective date    Changed from l_effective_date Bug 1874696
 			L_DIST_AMOUNT,             -- distribution amount
 			'N',                       -- status code
                        NULL,                      -- suspense reason code
                        NULL,                      -- default reason code
      			L_SCHEDULE_LINE_ID,        -- schedule line id
 			NULL,                      -- default organization a/c
 			NULL,                      -- suspense organization a/c
 			NULL,                      -- global element type
			NULL,                      -- org default schedule id
                        L_GL_PROJECT_FLAG,         -- gl project flag
                        NULL,                      -- reversal entry flag
                        l_gl_code_combination_id,  -- gl_code_combination_id
                        l_project_id,              -- project_id,
                        l_task_id   ,              -- task_id,
                        l_award_id  ,              -- award_id,
                        l_expenditure_org_id,      -- expenditure org id
                        l_expenditure_type,        -- expenditure_type
                        l_effective_start_date,    -- Eff start date of schedule
                        l_effective_end_date,      -- Eff start date of schedule
                        p_mode,                    -- 'I' for LD ,'R' for others
			p_business_group_id,       -- Business Group Id
                        p_set_of_books_id,         -- Set of Books Id
			l_attribute_category,		-- Introduced DFF columns for bug fix 2908859
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
             END IF;
           END IF;  -- Auto-Population ON/OFF
         END IF;

         END LOOP; -- loop through all the schedule lines having the payroll period date

         l_bal_dist_amount  := round((p_daily_rate - l_tot_dist_amount), g_precision);	-- Bug 2916848: Modified to currency precision (from 2)

         -- IF abs(l_bal_dist_amount) > 0 THEN  -- #1339616
         IF l_tot_percent < 100 THEN

           IF p_org_def_account = 'Y' then
             default_account(
                            x_proc_executed,
                            p_person_id,
                            p_sub_line_id,
                            p_assignment_id,
                            p_payroll_start_date,
                            l_bal_dist_amount,
                            '1',---'LDM_BAL_NOT_100_PERCENT',
                            p_effective_date,
                            p_mode,
			    p_business_group_id,
                            p_set_of_books_id,
			p_attribute_category,	-- Introduced DFF columns for bug fix 2908859
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
                            l_return_status);

             IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
             END IF;

             IF x_proc_executed = 'FALSE' then
                suspense_account(
                                 x_proc_executed,
                                 p_person_id,
                                 p_sub_line_id,
                                 p_assignment_id,
                                 p_payroll_start_date,
                                 l_bal_dist_amount,
                                 'LDM_BAL_NOT_100_PERCENT',
                                 NULL,
                                 NULL,
                                 NULL,
                                 NULL,
                                 p_effective_date,
                                 p_mode,
				 p_business_group_id,
                                 p_set_of_books_id,
                                 NULL,   ---    for autopop perf. patch
                                 l_return_status);

                 IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                 END IF;
               END IF;
           ELSE
                suspense_account(
                                 x_proc_executed,
                                 p_person_id,
                                 p_sub_line_id,
                                 p_assignment_id,
                                 p_payroll_start_date,
                                 l_bal_dist_amount,
                                 'LDM_BAL_NOT_100_PERCENT',
                                 NULL,
                                 NULL,
                                 NULL,
                                 NULL,
                                 p_effective_date,
                                 p_mode,
				 p_business_group_id,
                                 p_set_of_books_id,
                                 NULL, -- for autopop perf. patch 2023955
                                 l_return_status);

                 IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                 END IF;
           END IF;
         END IF;
   --
   p_return_status := fnd_api.g_ret_sts_success;

 EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      g_error_api_path := SUBSTR('ELEMENT_TYPE_HIERARCHY:'||g_error_api_path,1,230);
      p_return_status := fnd_api.g_ret_sts_unexp_error;

   WHEN OTHERS THEN
      g_error_api_path := SUBSTR('ELEMENT_TYPE_HIERARCHY:'||g_error_api_path,1,230);
      fnd_msg_pub.add_exc_msg('PSB_LABOR_DIST','ELEMENT_TYPE_HIERARCHY');
      p_return_status := fnd_api.g_ret_sts_unexp_error;
 END;

----------------------------- E L E M E N T   C L A S S --------------------------------------

 PROCEDURE element_class_hierarchy(p_proc_executed      OUT NOCOPY  VARCHAR2,
                                  p_person_id           IN  NUMBER,
                                  p_sub_line_id         IN  NUMBER,
                                  p_assignment_id       IN  NUMBER,
                                  p_element_type_id     IN  NUMBER,
                                  p_payroll_start_date  IN  DATE,
                                  p_daily_rate          IN  NUMBER,
                                  p_org_def_account     IN  VARCHAR2,
                                  p_effective_date      IN  DATE,
                                  p_mode                IN  VARCHAR2 := 'I',
				  p_business_group_id   IN  NUMBER,
                                  p_set_of_books_id     IN  NUMBER,
				p_attribute_category	IN	VARCHAR2,		-- Introduced DFF parameters for bug fix 2908859
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
                                  p_return_status       OUT NOCOPY VARCHAR2) IS



  CURSOR sch_lines_element_class_cur(P_ASSIGNMENT_ID      NUMBER,
                                     P_ELEMENT_TYPE_ID    NUMBER,
                                     P_PAYROLL_START_DATE DATE) IS
  SELECT psl.schedule_line_id,
         psl.gl_code_combination_id,
         psl.project_id,
         psl.task_id,
         psl.award_id,
         round(psl.schedule_percent,2) schedule_percent,
         psl.expenditure_type,
         psl.expenditure_organization_id,
         pet.start_date_active,
         nvl(pet.end_date_active,p_payroll_start_date),
          ---- introduced decode for 5014193
	 decode(g_dff_grouping_option, 'Y',NVL(p_attribute_category, psl.attribute_category)) attribute_category,		-- Introduced DFF columns for bug fix 2908859
	 decode(g_dff_grouping_option, 'Y',NVL(p_attribute1, psl.attribute1)) attribute1,
	 decode(g_dff_grouping_option, 'Y',NVL(p_attribute2, psl.attribute2)) attribute2,
	 decode(g_dff_grouping_option, 'Y',NVL(p_attribute3, psl.attribute3)) attribute3,
	 decode(g_dff_grouping_option, 'Y',NVL(p_attribute4, psl.attribute4)) attribute4,
	 decode(g_dff_grouping_option, 'Y',NVL(p_attribute5, psl.attribute5)) attribute5,
	 decode(g_dff_grouping_option, 'Y',NVL(p_attribute6, psl.attribute6)) attribute6,
	 decode(g_dff_grouping_option, 'Y',NVL(p_attribute7, psl.attribute7)) attribute7,
	 decode(g_dff_grouping_option, 'Y',NVL(p_attribute8, psl.attribute8)) attribute8,
	 decode(g_dff_grouping_option, 'Y',NVL(p_attribute9, psl.attribute9)) attribute9,
	 decode(g_dff_grouping_option, 'Y',NVL(p_attribute10, psl.attribute10)) attribute10
  FROM   psp_element_types      pet,
         psp_group_element_list pgel,
         psp_schedule_hierarchy psh,
         psp_schedule_lines     psl
  WHERE  pet.element_type_id = p_element_type_id
--	Introduced the following BG/SOB check for bug fix 3098050
  AND	 pet.business_group_id = p_business_group_id
  AND	 pet.set_of_books_id = p_set_of_books_id
  AND    p_payroll_start_date BETWEEN pet.start_date_active AND
                                      nvl(pet.end_date_active,p_payroll_start_date)
  AND    pet.element_type_id = pgel.element_type_id
  AND    pet.start_date_active = pgel.start_date_active
  AND    pgel.element_group_id = psh.element_group_id
  AND    psl.business_group_id = p_business_group_id
  AND    psl.set_of_books_id   = p_set_of_books_id
  AND    psh.assignment_id = p_assignment_id
  AND    psh.schedule_hierarchy_id = psl.schedule_hierarchy_id
  AND    p_payroll_start_date BETWEEN psl.schedule_begin_date AND
                                      nvl(psl.schedule_end_date,p_payroll_start_date);


  x_proc_executed            	     VARCHAR2(10) := 'TRUE';
  l_dist_amount                    NUMBER       := 0;
  l_tot_dist_amount                NUMBER       := 0;
  l_bal_dist_amount                NUMBER       := 0;
  l_tot_percent                    NUMBER       := 0;

  l_schedule_line_id               NUMBER(15);
  l_gl_code_combination_id         NUMBER(15);
  l_project_id                     NUMBER(15);
  l_task_id                        NUMBER(15);
  l_award_id                       NUMBER(15);
  l_expenditure_type               VARCHAR2(30);
  l_schedule_percent               NUMBER;
  l_expenditure_org_id             NUMBER(15);
  l_effective_start_date           DATE;
  l_effective_end_date             DATE;
	l_attribute_category	VARCHAR2(30);			-- Introduced DFF variables for bug fix 2908859
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
  l_rec_count                      NUMBER := 0;
  l_return_status                  VARCHAR2(1);
  --l_effective_date                 DATE;    Bug 1874696
  l_gl_project_flag                VARCHAR2(1);
  l_linkage_status                 VARCHAR2(50);
  l_patc_status                    VARCHAR2(50);
  l_billable_flag                  VARCHAR2(1);
  l_msg_count                      NUMBER;
  l_msg_app                        VARCHAR2(2000);
  l_msg_type                       varchar2(2000);
  l_msg_token1                     varchar2(2000);
  l_msg_token2                     varchar2(2000);
  l_msg_token3                     varchar2(2000);
  --l_award_status  varchar2(50);  -- for bug fix 1931680
  l_award_status  varchar2(200);

 BEGIN
         p_proc_executed := 'TRUE';

         -- For the payroll date passed to the procedure, check if there are schedule line(s).
         -- If the schedule line(s) exists, then fetch the schedule percent and calculate the
         -- total distribution amount by adding the distribution amount in each of the lines.
         -- If the schedule line(s) does not exist,set the p_proc_executed flag as FALSE

         OPEN sch_lines_element_class_cur(p_assignment_id,p_element_type_id,p_payroll_start_date);

         LOOP
           l_linkage_status := NULL;
           l_patc_status    := NULL;
           l_billable_flag  := NULL;
	   l_award_status   := NULL;

           FETCH sch_lines_element_class_cur INTO
		        l_schedule_line_id,
                        l_gl_code_combination_id,
  			l_project_id,
  			l_task_id,
  			l_award_id,
  			l_schedule_percent,
                        l_expenditure_type,
                        l_expenditure_org_id,
                        l_effective_start_date,
                        l_effective_end_date,
			l_attribute_category,			-- Introduced DFf variable for bug fix 2908859
			l_attribute1,
			l_attribute2,
			l_attribute3,
			l_attribute4,
			l_attribute5,
			l_attribute6,
			l_attribute7,
			l_attribute8,
			l_attribute9,
			l_attribute10;

           l_rec_count := l_rec_count + 1;
           IF sch_lines_element_class_cur%NOTFOUND THEN
             IF l_rec_count = 1 THEN
               p_proc_executed := 'FALSE';
               CLOSE sch_lines_element_class_cur;
               RETURN;
             ELSE
               CLOSE sch_lines_element_class_cur;
               EXIT;
             END IF;
           END IF;

           l_tot_percent := l_tot_percent + l_schedule_percent;
           IF l_tot_percent <= 100 THEN
             l_dist_amount := round((p_daily_rate * l_schedule_percent/100), g_precision); 	-- Bug 2916848: Modified to currency precision (from 2)
           -- ELSIF l_tot_percent = 100 THEN
           --   l_dist_amount := round((p_daily_rate - l_tot_dist_amount),2);
           ELSIF l_tot_percent > 100 THEN
	      	Get_assign_number(p_assignment_id
	 		       ,p_payroll_start_date
			       ,g_assignment_number
			       ,g_employee_number);--Bug 2374680
              	fnd_message.set_name('PSP','PSP_LD_PERCENT_GREATER_100');
              	fnd_message.set_token('PAYROLL_DATE',p_payroll_start_date);
--            	fnd_message.set_token('ASSIGNMENT_ID',p_assignment_id); --Commented for bug 2374680
              	/* Added assignment_number and employee_number inplace of assignment_id*/
              	fnd_message.set_token('ASSIGNMENT_NUMBER',g_assignment_number);
              	fnd_message.set_token('EMPLOYEE_NUMBER',g_employee_number);
              	fnd_msg_pub.add;
--		Commented for bug fix 2267098 (return status set in exception)
--             	p_return_status := fnd_api.g_ret_sts_unexp_error;
		RAISE fnd_api.g_exc_unexpected_error;	-- Introduced for bug 2267098

           END IF;

           l_tot_dist_amount := round((l_tot_dist_amount + l_dist_amount), g_precision);	-- Bug 2916848: Modified to currency precision (from 2)


           IF l_gl_code_combination_id IS NOT NULL THEN
              -- l_effective_date := p_effective_date; Bug 1874696
              l_gl_project_flag := 'G';


              insert_into_distribution_lines(
 			P_SUB_LINE_ID,         -- payroll sub-lines id
 			P_PAYROLL_START_DATE,  -- distribution date
                        G_GL_EFFECTIVE_DATE,   --  Changed from P_Effective_date Bug 2663344
 			L_DIST_AMOUNT,         -- distribution amount
 			'N',                   -- status code
                        NULL,                  -- suspense reason code
                        NULL,                  -- default reason code
      	                L_SCHEDULE_LINE_ID,    -- schedule line id
 			NULL,                  -- default organization a/c
 			NULL,                  -- suspense organization a/c
 			NULL,                  -- global element type
			NULL,                  -- org default schedule id
                        L_GL_PROJECT_FLAG,     -- gl project flag
                        NULL,                  -- reversal entry flag
                        l_gl_code_combination_id,  -- gl_code_combination_id
                        l_project_id,          -- project_id,
                        l_task_id   ,          -- task_id,
                        l_award_id  ,          -- award_id,
                        l_expenditure_org_id,  -- expenditure org id
                        l_expenditure_type,    -- expenditure_type
                        l_effective_start_date,-- Eff start date of schedule
                        l_effective_end_date,  -- Eff start date of schedule
                        p_mode,                -- 'I' for LD ,'R' for others
			p_business_group_id,   -- Business Group Id
                        p_set_of_books_id,     -- Set of books Id
			l_attribute_category,		-- Introduced DFF columns for bug fix 2908859
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

           ELSIF l_gl_code_combination_id IS NULL THEN
             --IF g_auto_population = 'Y' THEN

             IF (g_asg_ele_group_autopop = 'Y')THEN  --- 5080403
              -- insert the record in psp_distribution_lines  bug 2023955
                   l_gl_project_flag:='P';

              insert_into_distribution_lines(
 			P_SUB_LINE_ID,         -- payroll sub-lines id
 			P_PAYROLL_START_DATE,  -- distribution date
                        P_EFFECTIVE_DATE,      -- effective date     Changed from l_Effective_date Bug 1874696
 			L_DIST_AMOUNT,         -- distribution amount
 			'N',                   -- status code
                        NULL,                  -- suspense reason code
                        NULL,                  -- default reason code
      	                L_SCHEDULE_LINE_ID,    -- schedule line id
 			NULL,                  -- default organization a/c
 			NULL,                  -- suspense organization a/c
 			NULL,                  -- global element type
			NULL,                  -- org default schedule id
                        L_GL_PROJECT_FLAG,     -- gl project flag
                        NULL,                  -- reversal entry flag
                        l_gl_code_combination_id,  -- gl_code_combination_id
                        l_project_id,          -- project_id,
                        l_task_id   ,          -- task_id,
                        l_award_id  ,          -- award_id,
                        l_expenditure_org_id,  -- expenditure org id
                        l_expenditure_type,    -- expenditure_type
                        l_effective_start_date,-- Eff start date of schedule
                        l_effective_end_date,  -- Eff start date of schedule
                        p_mode,                -- 'I' for LD ,'R' for others
			p_business_group_id,   -- Business Group Id
                        p_set_of_books_id,     -- Set of books Id
			l_attribute_category,		-- Introduced DFF columns for bug fix 2908859
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
          --  END IF; -- Auto-Population ON/OFF  Commented out NOCOPY for bug fxi 2023955


           ELSE


/*

  Commented out NOCOPY  for Bug fix 2023955

               autopop(p_acct_type                   => 'E',
		       p_person_id                   => p_person_id,
		       p_assignment_id               => p_assignment_id,
		       p_element_type_id             => p_element_type_id,
		       p_project_id                  => l_project_id,
		       p_expenditure_organization_id => l_expenditure_org_id,
		       p_task_id                     => l_task_id,
		       p_award_id                    => l_award_id,
                       p_expenditure_type            => l_expenditure_type,
		       p_gl_code_combination_id      => null,
		       p_payroll_start_date          => p_payroll_start_date,
		       p_effective_date              => p_effective_date,
		       p_dist_amount                 => l_dist_amount,
                       p_schedule_line_id            => l_schedule_line_id,
		       p_org_schedule_id             => null,
		       p_sub_line_id                 => p_sub_line_id,
                       p_effective_start_date        => l_effective_start_date,
                       p_effective_end_date          => l_effective_end_date,
                       p_mode                        => p_mode,
		       p_business_group_id           => p_business_group_id,
                       p_set_of_books_id             => p_set_of_books_id,
		       p_return_status 		     => l_return_status);

	       IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
               END IF;
*/
--            ELSE
		  -- Auto-Population is OFF. Get project status and insert record.
	     -- modified as per 11i changes
	   -- dbms_output.put_line('Project id 3 '|| to_char(l_project_id));
	   -- dbms_output.put_line('task id 3 '|| to_char(l_task_id));
	   -- dbms_output.put_line('Type 3 '|| l_expenditure_type);
	   -- dbms_output.put_line('Dt 3 '|| to_char(p_payroll_start_date));
	   -- dbms_output.put_line('person_id 3 '|| to_char(p_person_id));

	    pa_transactions_pub.validate_transaction(
			x_project_id		=> l_project_id,
			x_task_id		=> l_task_id,
			x_ei_date		=> p_effective_date, ----p_payroll_start_date, Bug 1874696
			x_expenditure_type	=> l_expenditure_type,
			x_non_labor_resource	=> null,
			x_person_id		=> p_person_id,
			x_incurred_by_org_id	=> l_expenditure_org_id,
			x_calling_module	=> 'PSPLDCDB',
			x_msg_application	=> l_msg_app,
			x_msg_type		=> l_msg_type,
			x_msg_token1		=> l_msg_token1,
			x_msg_token2		=> l_msg_token2,
			x_msg_token3		=> l_msg_token3,
			x_msg_count		=> l_msg_count,
			x_msg_data		=> l_patc_status,
			x_billable_flag		=> l_billable_flag,
			p_sys_link_function     => 'ST');            --Bug 5639589: Added parameter


	   -- dbms_output.put_line('patc stat 3 '|| l_patc_status);
	    -- GMS is enabled and PATC went through
	    if l_award_id is not null and l_patc_status is null
             then
                 gms_transactions_pub.validate_transaction
                                (l_project_id,
                                l_task_id,
				l_award_id,
                                l_expenditure_type,
                                p_effective_date, ----p_payroll_start_date, Bug 1874696
                                'PSPLDCDB',
                                l_award_status);
/************************************************************************

                 if l_award_status is null
                 then
                        project_award_linkage(l_project_id,
                                  l_award_id,
                                  l_linkage_status,
                                  l_return_status);
		 else
 --  Bug 2054610
*************************************************************************/

                 if l_award_status is not null then
		--	l_patc_status := l_award_status;  for bug fix 1931680
                        l_patc_status  := substr(l_award_status,1,50);
                 end if;
             end if;

             IF (l_patc_status IS NOT NULL) OR
--- (l_linkage_status IS NOT NULL) OR
		(l_award_status is not null) THEN
                suspense_account(
                         x_proc_executed,
                         p_person_id,
                         p_sub_line_id,
                         p_assignment_id,
                         p_payroll_start_date,
                         l_dist_amount,
                         l_patc_status,
                         l_schedule_line_id,
                         NULL,
                         NULL,
                         NULL,
                         p_effective_date,
                         p_mode,
			 p_business_group_id,
                         p_set_of_books_id,
                         NULL,   ---    for autopop perf. patch
                         l_return_status);

                 IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                 END IF;

              ELSIF (l_patc_status IS NULL) OR
--- (l_linkage_status IS NULL) OR
		    (l_award_status is null)  THEN
                /* Bug 1874696
		if l_award_id is not null
		then
                   psp_general.poeta_effective_date(p_payroll_start_date,
                                     l_project_id,
                                     l_award_id,
  				     l_task_id,
                                     l_effective_date,
                                     l_return_status);
		elsif l_award_id is null
		then
                   psp_general.poeta_effective_date(p_payroll_start_date,
                                     l_project_id,
  				     l_task_id,
                                     l_effective_date,
                                     l_return_status);
		end if;
                   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                   END IF; */
                   l_gl_project_flag := 'P';

                    -- insert the record in psp_distribution_lines
                    insert_into_distribution_lines(
 			P_SUB_LINE_ID,             -- payroll sub-lines id
 			P_PAYROLL_START_DATE,      -- distribution date
                        P_EFFECTIVE_DATE,          -- effective date     Changed from l_effective_date Bug 1874696
 			L_DIST_AMOUNT,             -- distribution amount
 			'N',                       -- status code
                        NULL,                      -- suspense reason code
                        NULL,                      -- default reason code
      			L_SCHEDULE_LINE_ID,        -- schedule line id
 			NULL,                      -- default organization a/c
 			NULL,                      -- suspense organization a/c
 			NULL,                      -- global element type
			NULL,                      -- org default schedule id
                        L_GL_PROJECT_FLAG,         -- gl project flag
                        NULL,                      -- reversal entry flag
                        l_gl_code_combination_id,  -- gl_code_combination_id
                        l_project_id,              -- project_id,
                        l_task_id   ,              -- task_id,
                        l_award_id  ,              -- award_id,
                        l_expenditure_org_id    ,  -- expenditure org id
                        l_expenditure_type,             -- expenditure_type
                        l_effective_start_date,    -- Eff start date of schedule
                        l_effective_end_date,      -- Eff start date of schedule
                        p_mode,                    -- 'I' for LD ,'R' for others
			p_business_group_id,       -- Business_group_id
                        p_set_of_books_id,         -- Set of Books Id
			l_attribute_category,		-- Introduced DFF columns for bug fix 2908859
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
             END IF;
           END IF; -- g_auto_population = 'Y'
          END IF;
         END LOOP; -- loop through all the schedule lines having the payroll period date

         l_bal_dist_amount  := round((p_daily_rate - l_tot_dist_amount), g_precision);	-- Bug 2916848: Modified to currency precision (from 2)

         -- IF abs(l_bal_dist_amount) > 0 THEN  -- #1339616
         IF l_tot_percent <  100 THEN

           IF p_org_def_account = 'Y' then
             default_account(
                            x_proc_executed,
                            p_person_id,
                            p_sub_line_id,
                            p_assignment_id,
                            p_payroll_start_date,
                            l_bal_dist_amount,
                            '1',---'LDM_BAL_NOT_100_PERCENT',
                            p_effective_date,
                            p_mode,
			    p_business_group_id,
                            p_set_of_books_id,
			p_attribute_category,	-- Introduced DFF columns for bug fix 2908859
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
                            l_return_status);
              IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;


              IF x_proc_executed = 'FALSE' then
                suspense_account(
                                 x_proc_executed,
                                 p_person_id,
                                 p_sub_line_id,
                                 p_assignment_id,
                                 p_payroll_start_date,
                                 l_bal_dist_amount,
                                 'LDM_BAL_NOT_100_PERCENT',
                                 NULL,
                                 NULL,
                                 NULL,
                                 NULL,
                                 p_effective_date,
                                 p_mode,
				 p_business_group_id,
                                 p_set_of_books_id,
                                 NULL,   ---    for autopop perf. patch
                                 l_return_status);
                 IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                 END IF;

               END IF;
           ELSE
                suspense_account(
                                 x_proc_executed,
                                 p_person_id,
                                 p_sub_line_id,
                                 p_assignment_id,
                                 p_payroll_start_date,
                                 l_bal_dist_amount,
                                 'LDM_BAL_NOT_100_PERCENT',
                                 NULL,
                                 NULL,
                                 NULL,
                                 NULL,
                                 p_effective_date,
                                 p_mode,
				 p_business_group_id,
                                 p_set_of_books_id,
                                 NULL,   ---    for autopop perf. patch
                                 l_return_status);
                 IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                 END IF;

           END IF;
         END IF;
   --
   p_return_status := fnd_api.g_ret_sts_success;

 EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      g_error_api_path := SUBSTR('ELEMENT_CLASS_HIERARCHY:'||g_error_api_path,1,230);
      p_return_status := fnd_api.g_ret_sts_unexp_error;

   WHEN OTHERS THEN
      g_error_api_path := SUBSTR('ELEMENT_CLASS_HIERARCHY:'||g_error_api_path,1,230);
      fnd_msg_pub.add_exc_msg('PSB_LABOR_DIST','ELEMENT_CLASS_HIERARCHY');
      p_return_status := fnd_api.g_ret_sts_unexp_error;

 END;

----------------------------- A S S I G N M E N T --------------------------------------




 PROCEDURE assignment_hierarchy(p_proc_executed      OUT NOCOPY  VARCHAR2,
                                p_person_id           IN  NUMBER,
                                p_sub_line_id         IN  NUMBER,
                                p_assignment_id       IN  NUMBER,
                                p_element_type_id     IN  NUMBER,
                                p_payroll_start_date  IN  DATE,
                                p_daily_rate          IN  NUMBER,
                                p_org_def_account     IN  VARCHAR2,
                                p_effective_date      IN  DATE,
                                p_mode                IN  VARCHAR2 := 'I',
				p_business_group_id   IN  NUMBER,
                                p_set_of_books_id     IN  NUMBER,
				p_attribute_category	IN	VARCHAR2,		-- Introduced DFF parameters for bug fix 2908859
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
                                p_return_status       OUT NOCOPY VARCHAR2) IS


  CURSOR sch_lines_assignment_cur(P_ASSIGNMENT_ID      NUMBER,
                                  P_PAYROLL_START_DATE DATE) IS
  SELECT psl.schedule_line_id,
         psl.gl_code_combination_id,
         psl.project_id,
         psl.task_id,
         psl.award_id,
         round(psl.schedule_percent,2) schedule_percent,
         psl.expenditure_type,
         psl.expenditure_organization_id,
         psl.schedule_begin_date,
         nvl(psl.schedule_end_date,p_payroll_start_date),
	 decode(g_dff_grouping_option, 'Y',NVL(p_attribute_category, psl.attribute_category)) attribute_category,		-- Introduced DFF columns for bug fix 2908859
	 decode(g_dff_grouping_option, 'Y',NVL(p_attribute1, psl.attribute1)) attribute1,
	 decode(g_dff_grouping_option, 'Y',NVL(p_attribute2, psl.attribute2)) attribute2,
	 decode(g_dff_grouping_option, 'Y',NVL(p_attribute3, psl.attribute3)) attribute3,
	 decode(g_dff_grouping_option, 'Y',NVL(p_attribute4, psl.attribute4)) attribute4,
	 decode(g_dff_grouping_option, 'Y',NVL(p_attribute5, psl.attribute5)) attribute5,
	 decode(g_dff_grouping_option, 'Y',NVL(p_attribute6, psl.attribute6)) attribute6,
	 decode(g_dff_grouping_option, 'Y',NVL(p_attribute7, psl.attribute7)) attribute7,
	 decode(g_dff_grouping_option, 'Y',NVL(p_attribute8, psl.attribute8)) attribute8,
	 decode(g_dff_grouping_option, 'Y',NVL(p_attribute9, psl.attribute9)) attribute9,
	 decode(g_dff_grouping_option, 'Y',NVL(p_attribute10, psl.attribute10)) attribute10
  FROM   psp_schedule_hierarchy psh,
         psp_schedule_lines     psl
  WHERE  psh.business_group_id = p_business_group_id
  AND    psh.set_of_books_id   = p_set_of_books_id
  AND	 psh.scheduling_types_code = 'A'
  AND    psh.element_group_id IS NULL
  AND    psh.element_type_id IS NULL
  AND    psh.assignment_id = p_assignment_id
  AND    psh.schedule_hierarchy_id = psl.schedule_hierarchy_id
  AND	 psl.business_group_id = psh.business_group_id
  AND    psl.set_of_books_id   = psh.set_of_books_id
  AND    p_payroll_start_date BETWEEN psl.schedule_begin_date AND
                                      nvl(psl.schedule_end_date,p_payroll_start_date);


  x_proc_executed                  VARCHAR2(10) := 'TRUE';
  l_dist_amount                    NUMBER       := 0;
  l_tot_dist_amount                NUMBER       := 0;
  l_bal_dist_amount                NUMBER       := 0;
  l_tot_percent                    NUMBER       := 0;

  l_schedule_line_id               NUMBER(15);
  l_gl_code_combination_id         NUMBER(15);
  l_project_id                     NUMBER(15);
  l_task_id                        NUMBER(15);
  l_award_id                       NUMBER(15);
  l_schedule_percent               NUMBER;
  l_expenditure_type               VARCHAR2(30);
  l_expenditure_org_id             NUMBER(15);
  l_effective_start_date           DATE;
  l_effective_end_date             DATE;
	l_attribute_category	VARCHAR2(30);			-- Introduced DFF variables for bug fix 2908859
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
  l_rec_count                      NUMBER := 0;
  l_return_status                  VARCHAR2(1);
  ---  l_effective_date                 DATE; Bug 1874696
  l_gl_project_flag                VARCHAR2(1);
  l_linkage_status                 VARCHAR2(50);
  l_patc_status                    VARCHAR2(50);
  l_billable_flag                  VARCHAR2(1);
  l_msg_count                      NUMBER;
  l_msg_app                        VARCHAR2(2000);
  l_msg_type                       varchar2(2000);
  l_msg_token1                     varchar2(2000);
  l_msg_token2                     varchar2(2000);
  l_msg_token3                     varchar2(2000);
  --l_award_status  varchar2(50);  -- for bug fix 1931680
  l_award_status  varchar2(200);
 BEGIN
        -- dbms_output.put_line('asg hierarchy sub_line_id = '|| p_sub_line_id);
         p_proc_executed := 'TRUE';

         -- For the payroll date passed to the procedure, check if there are schedule line(s).
         -- If the schedule line(s) exists, then fetch the schedule percent and calculate the
         -- total distribution amount by adding the distribution amount in each of the lines.
         -- If the schedule line(s) does not exist,set the p_proc_executed flag as FALSE

         OPEN sch_lines_assignment_cur(p_assignment_id,p_payroll_start_date);

         LOOP
           l_linkage_status  := NULL;
           l_patc_status     := NULL;
           l_billable_flag   := NULL;
	   l_award_status    := NULL;

           FETCH sch_lines_assignment_cur INTO
		        l_schedule_line_id,
                        l_gl_code_combination_id,
  			l_project_id,
  			l_task_id,
  			l_award_id,
  			l_schedule_percent,
                        l_expenditure_type,
                        l_expenditure_org_id,
                        l_effective_start_date,
                        l_effective_end_date,
			l_attribute_category,			-- Introduced DFf variable for bug fix 2908859
			l_attribute1,
			l_attribute2,
			l_attribute3,
			l_attribute4,
			l_attribute5,
			l_attribute6,
			l_attribute7,
			l_attribute8,
			l_attribute9,
			l_attribute10;

           l_rec_count := l_rec_count + 1;
           IF sch_lines_assignment_cur%NOTFOUND THEN
             IF l_rec_count = 1 THEN
               p_proc_executed := 'FALSE';
               CLOSE sch_lines_assignment_cur;
               RETURN;
             ELSE
               CLOSE sch_lines_assignment_cur;
               EXIT;
             END IF;
           END IF;
          -- dbms_output.put_line('asg hiearchy l_schedule_line_id='||l_schedule_line_id);
           l_tot_percent := l_tot_percent + l_schedule_percent;
           IF l_tot_percent <= 100 THEN
             l_dist_amount := round((p_daily_rate * l_schedule_percent/100), g_precision); 	-- Bug 2916848: Modified to currency precision (from 2)
           -- ELSIF l_tot_percent = 100 THEN
           --   l_dist_amount := round((p_daily_rate - l_tot_dist_amount),2);
           ELSIF l_tot_percent > 100 THEN
	    	 Get_assign_number(p_assignment_id
			      ,p_payroll_start_date
			      ,g_assignment_number
			      ,g_employee_number);--Bug 2374680
             	fnd_message.set_name('PSP','PSP_LD_PERCENT_GREATER_100');
             	fnd_message.set_token('PAYROLL_DATE',p_payroll_start_date);
--           	fnd_message.set_token('ASSIGNMENT_ID',p_assignment_id); --Commented for bug 2374680
             	/* Added assignment_number and employee_number inplace of assignment_id*/
            	fnd_message.set_token('ASSIGNMENT_NUMBER',g_assignment_number);
            	fnd_message.set_token('EMPLOYEE_NUMBER',g_employee_number);
             	fnd_msg_pub.add;
--		Commented for bug fix 2267098 (return status set in exception)
--             	p_return_status := fnd_api.g_ret_sts_unexp_error;
		RAISE fnd_api.g_exc_unexpected_error;	-- Introduced for bug 2267098

           END IF;

           l_tot_dist_amount := round((l_tot_dist_amount + l_dist_amount), g_precision);	-- Bug 2916848: Modified to currency precision (from 2)


           IF l_gl_code_combination_id IS NOT NULL THEN
              --- l_effective_date := p_effective_date; 1874696
              l_gl_project_flag := 'G';

              -- insert the record in psp_distribution_lines
              insert_into_distribution_lines(
 			P_SUB_LINE_ID,             -- payroll sub-lines id
 			P_PAYROLL_START_DATE,      -- distribution date
                        G_GL_EFFECTIVE_DATE,       -- changed fron p_effective date  --- Bug 2663344
 			L_DIST_AMOUNT,             -- distribution amount
 			'N',                       -- status code
                        NULL,                      -- suspense reason code
                        NULL,                      -- default reason code
      			L_SCHEDULE_LINE_ID,        -- schedule line id
 			NULL,                      -- default organization a/c
 			NULL,                      -- suspense organization a/c
 			NULL,                      -- global element type
			NULL,                      -- org default schedule id
                        L_GL_PROJECT_FLAG,         -- gl project flag
                        NULL,                      -- reversal entry flag
                        l_gl_code_combination_id,  -- gl_code_combination_id
                        l_project_id,              -- project_id,
                        l_task_id   ,              -- task_id,
                        l_award_id  ,              -- award_id,
                        l_expenditure_org_id,      -- expenditure org id
                        l_expenditure_type,        -- expenditure_type
                        l_effective_start_date,    -- Eff start date of schedule
                        l_effective_end_date,      -- Eff start date of schedule
                        p_mode,                    -- 'I' for LD ,'R' for others
			p_business_group_id,       -- Business Group Id
                        p_set_of_books_id,         -- Set of Books Id
			l_attribute_category,		-- Introduced DFF columns for bug fix 2908859
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
--            END IF; -- g_auto_population = 'Y'   bug fix 2023955


           ELSIF l_gl_code_combination_id IS NULL THEN

            --- IF (g_auto_population = 'Y'  and p_mode= 'I' ) THEN   5080403
            IF g_asg_autopop = 'Y' THEN
                   l_gl_project_flag:='P';

                    insert_into_distribution_lines(
 			P_SUB_LINE_ID,             -- payroll sub-line_id
 			P_PAYROLL_START_DATE,      -- distribution date
                        P_EFFECTIVE_DATE,          -- effective date     Bug 1874696 Changed from l_Effective_date
 			L_DIST_AMOUNT,             -- distribution amount
 			'N',                       -- status code
                        NULL,                      -- suspense reason code
                        NULL,                      -- default reason code
      			L_SCHEDULE_LINE_ID,        -- schedule line id
 			NULL,                      -- default organization a/c
 			NULL,                      -- suspense organization a/c
			NULL,                      -- global element type
			NULL,                      -- org default schedule id
                        L_GL_PROJECT_FLAG,         -- gl project flag
                        NULL,                      -- reversal entry flag
                        l_gl_code_combination_id,  -- gl_code_combination_id
                        l_project_id,              -- project_id,
                        l_task_id   ,              -- task_id,
                        l_award_id  ,              -- award_id,
                        l_expenditure_org_id,      -- expenditure org id
                        l_expenditure_type,        -- expenditure_type
                        l_effective_start_date,    -- Eff start date of schedule
                        l_effective_end_date,      -- Eff start date of schedule
                        p_mode,                    -- 'I' for LD ,'R' for others
			p_business_group_id,       -- Business Group Id
                        p_set_of_books_id,         -- Set of Books Id
			l_attribute_category,		-- Introduced DFF columns for bug fix 2908859
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

            ELSE
		  -- Auto-Population is OFF. Get project status and insert record.

	 -- modified as per 11i changes
	   -- dbms_output.put_line('Project id 4 '|| to_char(l_project_id));
	   -- dbms_output.put_line('task id 4 '|| to_char(l_task_id));
	   -- dbms_output.put_line('Type 4 '|| l_expenditure_type);
	   -- dbms_output.put_line('Dt 4 '|| to_char(p_payroll_start_date));
	   -- dbms_output.put_line('person_id 4 '|| to_char(p_person_id));

	    pa_transactions_pub.validate_transaction(
			x_project_id		=> l_project_id,
			x_task_id		=> l_task_id,
			x_ei_date		=> p_effective_date, --- Bug 1874696 p_payroll_start_date,
			x_expenditure_type	=> l_expenditure_type,
			x_non_labor_resource	=> null,
			x_person_id		=> p_person_id,
			x_incurred_by_org_id	=> l_expenditure_org_id,
			x_calling_module	=> 'PSPLDCDB',
			x_msg_application	=> l_msg_app,
			x_msg_type		=> l_msg_type,
			x_msg_token1		=> l_msg_token1,
			x_msg_token2		=> l_msg_token2,
			x_msg_token3		=> l_msg_token3,
			x_msg_count		=> l_msg_count,
			x_msg_data		=> l_patc_status,
			x_billable_flag		=> l_billable_flag,
			p_sys_link_function     => 'ST');            --Bug 5639589: Added parameter


	   -- dbms_output.put_line('patc stat 4 '|| l_patc_status|| ' p_eff_date='||p_effective_date);
	    -- GMS is enabled and patc went through
	     if l_award_id is not null and l_patc_status is null
             then
                 gms_transactions_pub.validate_transaction
                                (l_project_id,
                                l_task_id,
				l_award_id,
                                l_expenditure_type,
                                p_effective_date, ----p_payroll_start_date, Bug 1874696
                                'PSPLDCDB',
                                l_award_status);

/**************************************************************
                 if l_award_status is null
                 then
                        project_award_linkage(l_project_id,
                                  l_award_id,
                                  l_linkage_status,
                                  l_return_status);
		 else
 bug 2054610

***************************************************************/
                   if l_award_status is not null then
		--	l_patc_status := l_award_status;  for bug fix 1931680
                        l_patc_status  := substr(l_award_status,1,50);
                 end if;
             end if;

             IF (l_patc_status IS NOT NULL)
--  2054610 OR (l_linkage_status IS NOT NULL)
		OR (l_award_status is not null) THEN
                suspense_account(
                         x_proc_executed,
                         p_person_id,
                         p_sub_line_id,
                         p_assignment_id,
                         p_payroll_start_date,
                         l_dist_amount,
                         l_patc_status,
                         l_schedule_line_id,
                         NULL,
                         NULL,
                         NULL,
                         p_effective_date,
                         p_mode,
			 p_business_group_id,
                         p_set_of_books_id,
                         NULL,   ---    for autopop perf. patch
                         l_return_status);

                 IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                 END IF;

              ELSIF (l_patc_status IS NULL)
---- OR (l_linkage_status IS NULL)
 OR
			(l_award_status is null) THEN
                /* Bug 1874696
		if l_award_id is not null
		then
                    psp_general.poeta_effective_date(p_payroll_start_date,
                                     l_project_id,
                                     l_award_id,
				     l_task_id,
                                     l_effective_date,
                                     l_return_status);
		elsif l_award_id is null
		then
                    psp_general.poeta_effective_date(p_payroll_start_date,
                                     l_project_id,
				     l_task_id,
                                     l_effective_date,
                                     l_return_status);
		end if;
                    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                    END IF; */
                    l_gl_project_flag := 'P';

                    -- insert the record in psp_distribution_lines
                    insert_into_distribution_lines(
 			P_SUB_LINE_ID,             -- payroll sub-line_id
 			P_PAYROLL_START_DATE,      -- distribution date
                        P_EFFECTIVE_DATE,          -- effective date     Bug 1874696 Changed from l_Effective_date
 			L_DIST_AMOUNT,             -- distribution amount
 			'N',                       -- status code
                        NULL,                      -- suspense reason code
                        NULL,                      -- default reason code
      			L_SCHEDULE_LINE_ID,        -- schedule line id
 			NULL,                      -- default organization a/c
 			NULL,                      -- suspense organization a/c
			NULL,                      -- global element type
			NULL,                      -- org default schedule id
                        L_GL_PROJECT_FLAG,         -- gl project flag
                        NULL,                      -- reversal entry flag
                        l_gl_code_combination_id,  -- gl_code_combination_id
                        l_project_id,              -- project_id,
                        l_task_id   ,              -- task_id,
                        l_award_id  ,              -- award_id,
                        l_expenditure_org_id,      -- expenditure org id
                        l_expenditure_type,        -- expenditure_type
                        l_effective_start_date,    -- Eff start date of schedule
                        l_effective_end_date,      -- Eff start date of schedule
                        p_mode,                    -- 'I' for LD ,'R' for others
			p_business_group_id,       -- Business Group Id
                        p_set_of_books_id,         -- Set of Books Id
			l_attribute_category,		-- Introduced DFF columns for bug fix 2908859
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
             END IF;
           END IF; -- g_auto_population = 'Y'
          END IF;

         END LOOP; -- loop through all the schedule lines having the payroll period date

         l_bal_dist_amount  := round((p_daily_rate - l_tot_dist_amount), g_precision);	-- Bug 2916848: Modified to currency precision (from 2)

         -- IF abs(l_bal_dist_amount) > 0 THEN  -- #1339616
         IF l_tot_percent < 100 THEN

           IF p_org_def_account = 'Y' then
             default_account(
                            x_proc_executed,
                            p_person_id,
                            p_sub_line_id,
                            p_assignment_id,
                            p_payroll_start_date,
                            l_bal_dist_amount,
                            '1',---'LDM_BAL_NOT_100_PERCENT',
                            p_effective_date,
                            p_mode,
			    p_business_group_id,
                            p_set_of_books_id,
				p_attribute_category,	-- Introduced DFF columns for bug fix 2908859
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
                            l_return_status);

               IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
               END IF;

              IF x_proc_executed = 'FALSE' then
                suspense_account(
                                 x_proc_executed,
                                 p_person_id,
                                 p_sub_line_id,
                                 p_assignment_id,
                                 p_payroll_start_date,
                                 l_bal_dist_amount,
                                 'LDM_BAL_NOT_100_PERCENT',
                                 NULL,
                                 NULL,
                                 NULL,
                                 NULL,
                                 p_effective_date,
                                 p_mode,
				 p_business_group_id,
                                 p_set_of_books_id,
                                 NULL,   ---    for autopop perf. patch
                                 l_return_status);

                 IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                 END IF;

               END IF;
           ELSE
                suspense_account(
                                 x_proc_executed,
                                 p_person_id,
                                 p_sub_line_id,
                                 p_assignment_id,
                                 p_payroll_start_date,
                                 l_bal_dist_amount,
                                 'LDM_BAL_NOT_100_PERCENT',
                                 NULL,
                                 NULL,
                                 NULL,
                                 NULL,
                                 p_effective_date,
                                 p_mode,
				 p_business_group_id,
                                 p_set_of_books_id,
                                 NULL,   ---    for autopop perf. patch
                                 l_return_status);

                 IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                 END IF;

           END IF;
         END IF;
   --
   p_return_status := fnd_api.g_ret_sts_success;

 EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     -- dbms_output.put_line(' asg hiearchy unexpected error');
      g_error_api_path := SUBSTR('ASSIGNMENT_HIERARCHY:'||g_error_api_path,1,230);
      p_return_status := fnd_api.g_ret_sts_unexp_error;

   WHEN OTHERS THEN
     -- dbms_output.put_line(' asg hiearchy when others ='||sqlerrm);
      g_error_api_path := SUBSTR('ASSIGNMENT_HIERARCHY:'||g_error_api_path,1,230);
      fnd_msg_pub.add_exc_msg('PSB_LABOR_DIST','ASSIGNMENT_HIERARCHY');
      p_return_status := fnd_api.g_ret_sts_unexp_error;

 END;

--------------------------  ORGANIZATION DEFAULT LABOR SCHEDULE   --------------------------
 PROCEDURE org_labor_schedule_hierarchy(
                           p_proc_executed      OUT NOCOPY  VARCHAR2,
                           p_person_id           IN  NUMBER,
                           p_sub_line_id         IN  NUMBER,
                           p_assignment_id       IN  NUMBER,
                           p_element_type_id     IN  NUMBER,
                           p_payroll_start_date  IN  DATE,
                           p_daily_rate          IN  NUMBER,
                           p_org_def_account     IN  VARCHAR2,
                           p_effective_date      IN  DATE,
                           p_mode                IN  VARCHAR2 := 'I',
			   p_business_group_id   IN  NUMBER,
                           p_set_of_books_id     IN  NUMBER,
				p_attribute_category	IN	VARCHAR2,		-- Introduced DFF parameters for bug fix 2908859
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
                           p_return_status       OUT NOCOPY VARCHAR2) IS


  CURSOR org_labor_schedule_cur(P_ASSIGNMENT_ID      NUMBER,
                                P_PAYROLL_START_DATE DATE) IS
  SELECT pdls.org_schedule_id,
         pdls.gl_code_combination_id,
         pdls.project_id,
         pdls.task_id,
         pdls.award_id,
         round(pdls.schedule_percent,2) schedule_percent,
         pdls.expenditure_type,
         pdls.expenditure_organization_id,
         pdls.schedule_begin_date,
         nvl(pdls.schedule_end_date,p_payroll_start_date),
            --- introduced decode for 5014193
	 decode(g_dff_grouping_option, 'Y',NVL(p_attribute_category, pdls.attribute_category)) attribute_category,		-- Introduced DFF columns for bug fix 2908859
	 decode(g_dff_grouping_option, 'Y',NVL(p_attribute1, pdls.attribute1)) attribute1,
	 decode(g_dff_grouping_option, 'Y',NVL(p_attribute2, pdls.attribute2)) attribute2,
	 decode(g_dff_grouping_option, 'Y',NVL(p_attribute3, pdls.attribute3)) attribute3,
	 decode(g_dff_grouping_option, 'Y',NVL(p_attribute4, pdls.attribute4)) attribute4,
	 decode(g_dff_grouping_option, 'Y',NVL(p_attribute5, pdls.attribute5)) attribute5,
	 decode(g_dff_grouping_option, 'Y',NVL(p_attribute6, pdls.attribute6)) attribute6,
	 decode(g_dff_grouping_option, 'Y',NVL(p_attribute7, pdls.attribute7)) attribute7,
	 decode(g_dff_grouping_option, 'Y',NVL(p_attribute8, pdls.attribute8)) attribute8,
	 decode(g_dff_grouping_option, 'Y',NVL(p_attribute9, pdls.attribute9)) attribute9,
	 decode(g_dff_grouping_option, 'Y',NVL(p_attribute10, pdls.attribute10)) attribute10
  FROM   per_assignments_f paf,
         psp_default_labor_schedules pdls
  WHERE  pdls.business_group_id = p_business_group_id
  AND    pdls.set_of_books_id   = p_set_of_books_id
  and    paf.assignment_type = 'E'
  AND    pdls.organization_id = paf.organization_id
  AND    paf.assignment_id = p_assignment_id
  AND    p_payroll_start_date BETWEEN paf.effective_start_date AND paf.effective_end_date
  AND    p_payroll_start_date BETWEEN pdls.schedule_begin_date AND
                                      nvl(pdls.schedule_end_date,p_payroll_start_date);

  x_proc_executed                  VARCHAR2(10) := 'TRUE';
  l_dist_amount                    NUMBER       := 0;
  l_tot_dist_amount                NUMBER       := 0;
  l_bal_dist_amount                NUMBER       := 0;
  l_tot_percent                    NUMBER       := 0;

  l_org_schedule_id                NUMBER(9);
  l_gl_code_combination_id         NUMBER(15);
  l_project_id                     NUMBER(15);
  l_task_id                        NUMBER(15);
  l_award_id                       NUMBER(15);
  l_expenditure_type               VARCHAR2(30);
  l_expenditure_org_id             NUMBER(15);
  l_effective_start_date           DATE;
  l_effective_end_date             DATE;
	l_attribute_category	VARCHAR2(30);			-- Introduced DFF variables for bug fix 2908859
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
  l_schedule_percent               NUMBER;
  l_rec_count                      NUMBER := 0;
  l_return_status                  VARCHAR2(1);
  ---l_effective_date                 DATE; Bug 1874696
  l_gl_project_flag                VARCHAR2(1);
  l_linkage_status                 VARCHAR2(50);
  l_patc_status                    VARCHAR2(50);
  l_billable_flag                  VARCHAR2(1);
  l_msg_count                      NUMBER;
  l_msg_app                        VARCHAR2(2000);
  l_msg_type                       varchar2(2000);
  l_msg_token1                     varchar2(2000);
  l_msg_token2                     varchar2(2000);
  l_msg_token3                     varchar2(2000);
  --l_award_status  varchar2(50);  -- for bug fix 1931680
  l_award_status  varchar2(200);

 BEGIN
         p_proc_executed := 'TRUE';

         -- For the payroll date passed to the procedure, check if there are schedule line(s).
         -- If the schedule line(s) exists, then fetch the schedule percent and calculate the
         -- total distribution amount by adding the distribution amount in each of the lines.
         -- If the schedule line(s) does not exist,set the p_proc_executed flag as FALSE

         OPEN org_labor_schedule_cur(p_assignment_id,p_payroll_start_date);
         hr_utility.trace('entered org labor schedules proce');

         LOOP
           l_linkage_status  := NULL;
           l_patc_status     := NULL;
           l_billable_flag   := NULL;
	   l_award_status    := NULL;

           FETCH org_labor_schedule_cur INTO
		        l_org_schedule_id,
                        l_gl_code_combination_id,
  			l_project_id,
  			l_task_id,
  			l_award_id,
  			l_schedule_percent,
                        l_expenditure_type,
                        l_expenditure_org_id,
                        l_effective_start_date,
                        l_effective_end_date,
			l_attribute_category,			-- Introduced DFf variable for bug fix 2908859
			l_attribute1,
			l_attribute2,
			l_attribute3,
			l_attribute4,
			l_attribute5,
			l_attribute6,
			l_attribute7,
			l_attribute8,
			l_attribute9,
			l_attribute10;

           l_rec_count := l_rec_count + 1;
           IF org_labor_schedule_cur%NOTFOUND THEN
             IF l_rec_count = 1 THEN
               p_proc_executed := 'FALSE';
               CLOSE org_labor_schedule_cur;
               RETURN;
             ELSE
               CLOSE org_labor_schedule_cur;
               EXIT;
             END IF;
           END IF;

           l_tot_percent := l_tot_percent + l_schedule_percent;
           IF l_tot_percent <= 100 THEN
             l_dist_amount := round((p_daily_rate * l_schedule_percent/100), g_precision); 	-- Bug 2916848: Modified to currency precision (from 2)
           -- ELSIF l_tot_percent = 100 THEN
           --   l_dist_amount := round((p_daily_rate - l_tot_dist_amount),2);
           ELSIF l_tot_percent > 100 THEN
	     	Get_assign_number(p_assignment_id
			      ,p_payroll_start_date
			      ,g_assignment_number
			      ,g_employee_number);--Bug 2374680
             	fnd_message.set_name('PSP','PSP_LD_PERCENT_GREATER_100');
             	fnd_message.set_token('PAYROLL_DATE',p_payroll_start_date);
--           	fnd_message.set_token('ASSIGNMENT_ID',p_assignment_id); --Commented for bug 2374680
             	/* Added assignment_number and employee_number inplace of assignment_id*/
             	fnd_message.set_token('ASSIGNMENT_NUMBER',g_assignment_number);
             	fnd_message.set_token('EMPLOYEE_NUMBER',g_employee_number);
             	fnd_msg_pub.add;
--		Commented for bug fix 2267098 (return status set in exception)
--             p_return_status := fnd_api.g_ret_sts_unexp_error;
		RAISE fnd_api.g_exc_unexpected_error;	-- Introduced for bug 2267098

           END IF;

           l_tot_dist_amount := round((l_tot_dist_amount + l_dist_amount), g_precision);	-- Bug 2916848: Modified to currency precision (from 2)

           IF l_gl_code_combination_id IS NOT NULL THEN
              --- l_effective_date := p_effective_date; Bug 1874696
              l_gl_project_flag := 'G';

              -- insert the record in psp_distribution_lines
         hr_utility.trace('inserting dist line for g_org_schedule_autopop ='||g_org_schedule_autopop);
              insert_into_distribution_lines(
 			P_SUB_LINE_ID,              -- payroll sub-lines id
 			P_PAYROLL_START_DATE,       -- distribution date
                        G_GL_EFFECTIVE_DATE,        -- changed from p_effective date  Bug 2663344
 			L_DIST_AMOUNT,              -- distribution amount
 			'N',                        -- status code
                        NULL,                       -- suspense reason code
                        NULL,                       -- default reason code
      			NULL,                       -- schedule line id
 			NULL,                       -- default organization a/c
 			NULL,                       -- suspense organization a/c
 			NULL,                       -- global element type
			L_ORG_SCHEDULE_ID,          -- org default schedule id
                        L_GL_PROJECT_FLAG,          -- gl project flag
                        NULL,                       -- reversal entry flag
                        l_gl_code_combination_id,   -- gl_code_combination_id
                        l_project_id,               -- project_id,
                        l_task_id   ,               -- task_id,
                        l_award_id  ,               -- award_id,
                        l_expenditure_org_id,       -- expenditure org id
                        l_expenditure_type,         -- expenditure_type
                        l_effective_start_date,    -- Eff start date of schedule
                        l_effective_end_date,      -- Eff start date of schedule
                        p_mode,                    -- 'I' for LD ,'R' for others
			p_business_group_id,       -- Business Group Id
                        p_set_of_books_id,         -- Set of Books Id
			l_attribute_category,		-- Introduced DFF columns for bug fix 2908859
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
 --           END IF; -- g_auto_population = 'Y'  for bug fix 2023955

           ELSIF l_gl_code_combination_id IS NULL THEN

  		  ---IF (g_auto_population = 'Y' and p_mode='I') THEN -- commented for 5080403
                  if (g_org_schedule_autopop = 'Y') then
         hr_utility.trace('g_org_schedule_autopop = Y');

 -- bug fix  2023955
                   l_gl_project_flag:='P';

 ---- Insert the record into psp_distribution_lines

              insert_into_distribution_lines(
 			P_SUB_LINE_ID,              -- payroll sub-lines id
 			P_PAYROLL_START_DATE,       -- distribution date
                        P_EFFECTIVE_DATE,           -- effective date     Bug 1874696
 			L_DIST_AMOUNT,              -- distribution amount
 			'N',                        -- status code
                        NULL,                       -- suspense reason code
                        NULL,                       -- default reason code
      			NULL,                       -- schedule line id
 			NULL,                       -- default organization a/c
 			NULL,                       -- suspense organization a/c
 			NULL,                       -- global element type
			L_ORG_SCHEDULE_ID,          -- org default schedule id
                        L_GL_PROJECT_FLAG,          -- gl project flag
                        NULL,                       -- reversal entry flag
                        l_gl_code_combination_id,   -- gl_code_combination_id
                        l_project_id,               -- project_id,
                        l_task_id   ,               -- task_id,
                        l_award_id  ,               -- award_id,
                        l_expenditure_org_id,       -- expenditure org id
                        l_expenditure_type,         -- expenditure_type
                        l_effective_start_date,    -- Eff start date of schedule
                        l_effective_end_date,      -- Eff start date of schedule
                        p_mode,                    -- 'I' for LD ,'R' for others
			p_business_group_id,       -- Business Group id
                        p_set_of_books_id,         -- Set of Books Id
			l_attribute_category,		-- Introduced DFF columns for bug fix 2908859
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

ELSE --   bug fix 2023955

	-- modified as per 11i changes
	   -- dbms_output.put_line('Project id 5 '|| to_char(l_project_id));
	   -- dbms_output.put_line('task id 5 '|| to_char(l_task_id));
	   -- dbms_output.put_line('Type 5 '|| l_expenditure_type);
	   -- dbms_output.put_line('Dt 5 '|| to_char(p_payroll_start_date));
	   -- dbms_output.put_line('person_id 5 '|| to_char(p_person_id));
	    pa_transactions_pub.validate_transaction(
			x_project_id		=> l_project_id,
			x_task_id		=> l_task_id,
			x_ei_date		=> p_effective_date, ---p_payroll_start_date, Bug 1874696
			x_expenditure_type	=> l_expenditure_type,
			x_non_labor_resource	=> null,
			x_person_id		=> p_person_id,
			x_incurred_by_org_id	=> l_expenditure_org_id,
			x_calling_module	=> 'PSPLDCDB',
			x_msg_application	=> l_msg_app,
			x_msg_type		=> l_msg_type,
			x_msg_token1		=> l_msg_token1,
			x_msg_token2		=> l_msg_token2,
			x_msg_token3		=> l_msg_token3,
			x_msg_count		=> l_msg_count,
			x_msg_data		=> l_patc_status,
			x_billable_flag		=> l_billable_flag,
			p_sys_link_function     => 'ST');            --Bug 5639589: Added parameter


	   -- dbms_output.put_line('patc stat 5 '|| l_patc_status);
	    -- GMS is enabled and patc went through
	    if l_award_id is not null and l_patc_status is null
             then
                 gms_transactions_pub.validate_transaction
                                (l_project_id,
                                l_task_id,
				l_award_id,
                                l_expenditure_type,
                                p_effective_date, ----p_payroll_start_date, Bug 1874696
                                'PSPLDCDB',
                                l_award_status);

/****************************************************************************************
                 if l_award_status is null
                 then
                        project_award_linkage(l_project_id,
                                  l_award_id,
                                  l_linkage_status,
                                  l_return_status);
		 else


****************************************************************************************/

                if l_award_status IS NOT NULL then
		--	l_patc_status := l_award_status;  for bug fix 1931680
                        l_patc_status  := substr(l_award_status,1,50);
                 end if;
             end if;

             IF (l_patc_status IS NOT NULL) OR
---  (l_linkage_status IS NOT NULL) OR
		(l_award_status IS NOT NULL) THEN
                suspense_account(
                         x_proc_executed,
                         p_person_id,
                         p_sub_line_id,
                         p_assignment_id,
                         p_payroll_start_date,
                         l_dist_amount,
                         l_patc_status,
                         NULL,
                         NULL,
                         NULL,
                         l_org_schedule_id,
                         p_effective_date,
                         p_mode,
			 p_business_group_id,
                         p_set_of_books_id,
                         NULL,   ---    for autopop perf. patch
                         l_return_status);

                 IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                 END IF;

              ELSIF (l_patc_status IS NULL) OR
----  (l_linkage_status IS NULL) OR
		    (l_award_status IS NULL) THEN
                /* Bug 1874696
		if l_award_id is not null
		then
                    psp_general.poeta_effective_date(p_payroll_start_date,
                                     l_project_id,
                                     l_award_id,
				     l_task_id,
                                     l_effective_date,
                                     l_return_status);
		elsif l_award_id is null
		then
                    psp_general.poeta_effective_date(p_payroll_start_date,
                                     l_project_id,
				     l_task_id,
                                     l_effective_date,
                                     l_return_status);
		end if;
                    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                    END IF; */
                    l_gl_project_flag := 'P';

                    -- insert the record in psp_distribution_lines
              insert_into_distribution_lines(
 			P_SUB_LINE_ID,              -- payroll sub-lines id
 			P_PAYROLL_START_DATE,       -- distribution date
                        P_EFFECTIVE_DATE,           -- effective date     Bug 1874696
 			L_DIST_AMOUNT,              -- distribution amount
 			'N',                        -- status code
                        NULL,                       -- suspense reason code
                        NULL,                       -- default reason code
      			NULL,                       -- schedule line id
 			NULL,                       -- default organization a/c
 			NULL,                       -- suspense organization a/c
 			NULL,                       -- global element type
			L_ORG_SCHEDULE_ID,          -- org default schedule id
                        L_GL_PROJECT_FLAG,          -- gl project flag
                        NULL,                       -- reversal entry flag
                        l_gl_code_combination_id,   -- gl_code_combination_id
                        l_project_id,               -- project_id,
                        l_task_id   ,               -- task_id,
                        l_award_id  ,               -- award_id,
                        l_expenditure_org_id,       -- expenditure org id
                        l_expenditure_type,         -- expenditure_type
                        l_effective_start_date,    -- Eff start date of schedule
                        l_effective_end_date,      -- Eff start date of schedule
                        p_mode,                    -- 'I' for LD ,'R' for others
			p_business_group_id,       -- Business Group id
                        p_set_of_books_id,         -- Set of Books Id
			l_attribute_category,		-- Introduced DFF columns for bug fix 2908859
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
             END IF;
           END IF; -- g_auto_population = 'Y'
         END IF;

         END LOOP; -- loop through all the schedule lines having the payroll period date

         l_bal_dist_amount  := round((p_daily_rate - l_tot_dist_amount), g_precision);	-- Bug 2916848: Modified to currency precision (from 2)

         -- IF abs(l_bal_dist_amount) > 0 THEN  -- #1339616
         IF l_tot_percent < 100 THEN

           IF p_org_def_account = 'Y' then
             default_account(
                            x_proc_executed,
                            p_person_id,
                            p_sub_line_id,
                            p_assignment_id,
                            p_payroll_start_date,
                            l_bal_dist_amount,
                            '1',---'LDM_BAL_NOT_100_PERCENT',
                            p_effective_date,
                            p_mode,
			    p_business_group_id,
                            p_set_of_books_id,
				p_attribute_category,	-- Introduced DFF columns for bug fix 2908859
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
                            l_return_status);
              IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;

              IF x_proc_executed = 'FALSE' then
                suspense_account(
                                 x_proc_executed,
                                 p_person_id,
                                 p_sub_line_id,
                                 p_assignment_id,
                                 p_payroll_start_date,
                                 l_bal_dist_amount,
                                 'LDM_BAL_NOT_100_PERCENT',
                                 NULL,
                                 NULL,
                                 NULL,
                                 NULL,
                                 p_effective_date,
                                 p_mode,
				 p_business_group_id,
                                 p_set_of_books_id,
                                 NULL,   ---    for autopop perf. patch
                                 l_return_status);

                 IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                 END IF;

               END IF;
           ELSE
                suspense_account(
                                 x_proc_executed,
                                 p_person_id,
                                 p_sub_line_id,
                                 p_assignment_id,
                                 p_payroll_start_date,
                                 l_bal_dist_amount,
                                 'LDM_BAL_NOT_100_PERCENT',
                                 NULL,
                                 NULL,
                                 NULL,
                                 NULL,
                                 p_effective_date,
                                 p_mode,
				 p_business_group_id,
                                 p_set_of_books_id,
                                 NULL,   ---    for autopop perf. patch
                                 l_return_status);

                 IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                 END IF;

           END IF;
         END IF;
   --
   p_return_status := fnd_api.g_ret_sts_success;

 EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      g_error_api_path := SUBSTR('ORG_LABOR_SCHEDULE_HIERARCHY:'||g_error_api_path,1,230);
      p_return_status := fnd_api.g_ret_sts_unexp_error;

   WHEN OTHERS THEN
      g_error_api_path := SUBSTR('ORG_LABOR_SCHEDULE_HIERARCHY:'||g_error_api_path,1,230);
      fnd_msg_pub.add_exc_msg('PSB_LABOR_DIST','ORG_LABOR_SCHEDULE_HIERARCHY');
      p_return_status := fnd_api.g_ret_sts_unexp_error;
 END;

------------------------------ D E F A U L T   A / C --------------------------------------
 PROCEDURE default_account(
                           p_proc_executed      OUT NOCOPY  VARCHAR2,
                           p_person_id           IN  NUMBER,
                           p_sub_line_id         IN  NUMBER,
                           p_assignment_id       IN  NUMBER,
                           p_payroll_start_date  IN  DATE,
                           p_daily_rate          IN  NUMBER,
                           p_default_reason_code IN  VARCHAR2,
                           p_effective_date      IN  DATE,
                           p_mode                IN  VARCHAR2 := 'I',
			   p_business_group_id   IN  NUMBER,
                           p_set_of_books_id     IN  NUMBER,
				p_attribute_category	IN	VARCHAR2,		-- Introduced DFF parameters for bug fix 2908859
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
                           p_return_status      OUT NOCOPY  VARCHAR2) IS

  CURSOR default_account_cur(P_PAYROLL_START_DATE	IN	DATE,
                             P_ASSIGNMENT_ID		IN	NUMBER) IS
      SELECT poa.organization_account_id,
             poa.gl_code_combination_id,
             poa.project_id,
             poa.task_id,
             poa.award_id,
             poa.expenditure_type,
             poa.expenditure_organization_id,
             poa.start_date_active,
             nvl(poa.end_date_active,p_payroll_start_date),    --- decode for 5014193
		 decode(g_dff_grouping_option, 'Y',NVL(p_attribute_category, poa.attribute_category)) attribute_category,		-- Introduced DFF columns for bug fix 2908859
		 decode(g_dff_grouping_option, 'Y',NVL(p_attribute1, poa.attribute1)) attribute1,
		 decode(g_dff_grouping_option, 'Y',NVL(p_attribute2, poa.attribute2)) attribute2,
		 decode(g_dff_grouping_option, 'Y',NVL(p_attribute3, poa.attribute3)) attribute3,
		 decode(g_dff_grouping_option, 'Y',NVL(p_attribute4, poa.attribute4)) attribute4,
		 decode(g_dff_grouping_option, 'Y',NVL(p_attribute5, poa.attribute5)) attribute5,
		 decode(g_dff_grouping_option, 'Y',NVL(p_attribute6, poa.attribute6)) attribute6,
		 decode(g_dff_grouping_option, 'Y',NVL(p_attribute7, poa.attribute7)) attribute7,
		 decode(g_dff_grouping_option, 'Y',NVL(p_attribute8, poa.attribute8)) attribute8,
		 decode(g_dff_grouping_option, 'Y',NVL(p_attribute9, poa.attribute9)) attribute9,
		 decode(g_dff_grouping_option, 'Y',NVL(p_attribute10, poa.attribute10)) attribute10
      FROM   per_assignments_f paf,
             psp_organization_accounts poa
      WHERE  poa.business_group_id = p_business_group_id
      AND    poa.set_of_books_id   = p_set_of_books_id
      and    paf.assignment_type = 'E'
      AND    paf.assignment_id = p_assignment_id
      AND    p_payroll_start_date BETWEEN paf.effective_start_date AND paf.effective_end_date
      AND    poa.organization_id = paf.organization_id
      AND    poa.account_type_code ||' '= 'D' ||' '
      AND    p_payroll_start_date BETWEEN poa.start_date_active AND
                                          nvl(poa.end_date_active,p_payroll_start_date);

  x_proc_executed                  VARCHAR2(10) := 'TRUE';
  l_organization_account_id        NUMBER(15);
  l_gl_code_combination_id         NUMBER(15);
  l_project_id                     NUMBER(15);
  l_task_id                        NUMBER(15);
  l_award_id                       NUMBER(15);
  l_expenditure_type               VARCHAR2(30);
  l_expenditure_org_id             NUMBER(15);
  l_effective_start_date           DATE;
  l_effective_end_date             DATE;
	l_attribute_category	VARCHAR2(30);			-- Introduced DFF variables for bug fix 2908859
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
  l_return_status                  VARCHAR2(1);
  -- l_effective_date                 DATE; Bug 1874696
  default_ac_not_found             EXCEPTION;
  l_gl_project_flag                VARCHAR2(1);
  l_linkage_status                 VARCHAR2(50) := NULL;
  l_patc_status                    VARCHAR2(50) := NULL;
  l_billable_flag                  VARCHAR2(1)  := NULL;
  l_msg_count                      NUMBER;
  l_msg_app                        VARCHAR2(2000);
  l_msg_type                       varchar2(2000);
  l_msg_token1                     varchar2(2000);
  l_msg_token2                     varchar2(2000);
  l_msg_token3                     varchar2(2000);
  --l_award_status  varchar2(50);  -- for bug fix 1931680
  l_award_status  varchar2(200);

  BEGIN
      p_proc_executed := 'TRUE';
      OPEN default_account_cur(p_payroll_start_date,p_assignment_id);
      FETCH default_account_cur INTO
             l_organization_account_id,
             l_gl_code_combination_id,
             l_project_id,
             l_task_id,
             l_award_id,
             l_expenditure_type,
             l_expenditure_org_id,
             l_effective_start_date,
             l_effective_end_date,
		l_attribute_category,			-- Introduced DFf variable for bug fix 2908859
		l_attribute1,
		l_attribute2,
		l_attribute3,
		l_attribute4,
		l_attribute5,
		l_attribute6,
		l_attribute7,
		l_attribute8,
		l_attribute9,
		l_attribute10;

      IF default_account_cur%NOTFOUND THEN
        RAISE default_ac_not_found;
      END IF;


           IF l_gl_code_combination_id IS NOT NULL THEN
              --l_effective_date := p_effective_date; commented for bug 1874696
              l_gl_project_flag := 'G';

              -- insert the record in psp_distribution_lines
              insert_into_distribution_lines(
		P_SUB_LINE_ID,                  -- payroll sub-lines id
 		P_PAYROLL_START_DATE,           -- distribution date
                G_GL_EFFECTIVE_DATE,            -- effective date     Changed from p_effective_date Bug 2663344
 		ROUND(P_DAILY_RATE, g_precision),-- distribution amount Introduced rounding for bug 3109943
 		'N',                            -- status code
                NULL,                           -- suspense reason code
                P_DEFAULT_REASON_CODE,          -- default reason code
          	NULL,                           -- schedule line id
 		L_ORGANIZATION_ACCOUNT_ID,      -- default organization a/c
 		NULL,                           -- suspense organization a/c
 		NULL                ,           -- global element type
		NULL,                           -- org default schedule id
                L_GL_PROJECT_FLAG,              -- gl project flag
                NULL,                           -- reversal entry flag
                l_gl_code_combination_id,       -- gl_code_combination_id
                l_project_id,                   -- project_id,
                l_task_id   ,                   -- task_id,
                l_award_id  ,                   -- award_id,
                l_expenditure_org_id,           -- expenditure org id
                l_expenditure_type,             -- expenditure_type
                l_effective_start_date,         -- Eff start date of schedule
                l_effective_end_date,           -- Eff start date of schedule
                p_mode,                         -- 'I' for LD ,'R' for others
		p_business_group_id,            -- Business Group Id
                p_set_of_books_id,              -- Set of Books Id
		l_attribute_category,		-- Introduced DFF columns for bug fix 2908859
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

           ELSIF l_gl_code_combination_id IS NULL THEN
            IF g_default_account_autopop = 'Y' THEN   -- introduced for 5080403
                   l_gl_project_flag:='P';

                    insert_into_distribution_lines(
 			P_SUB_LINE_ID,             -- payroll sub-line_id
 			P_PAYROLL_START_DATE,      -- distribution date
                        P_EFFECTIVE_DATE,          -- effective date     Bug 1874696 Changed from l_Effective_date
 			ROUND(P_DAILY_RATE, g_precision),-- distribution amount Introduced rounding for bug 3109943
 			'N',                       -- status code
                        NULL,                      -- suspense reason code
                        p_default_Reason_code,     -- default reason code
      			NULL,        -- schedule line id
 			l_organization_account_id, -- default organization a/c
 			NULL,                      -- suspense organization a/c
			NULL,                      -- global element type
			NULL,                      -- org default schedule id
                        L_GL_PROJECT_FLAG,         -- gl project flag
                        NULL,                      -- reversal entry flag
                        l_gl_code_combination_id,  -- gl_code_combination_id
                        l_project_id,              -- project_id,
                        l_task_id   ,              -- task_id,
                        l_award_id  ,              -- award_id,
                        l_expenditure_org_id,      -- expenditure org id
                        l_expenditure_type,        -- expenditure_type
                        l_effective_start_date,    -- Eff start date of schedule
                        l_effective_end_date,      -- Eff start date of schedule
                        p_mode,                    -- 'I' for LD ,'R' for others
			p_business_group_id,       -- Business Group Id
                        p_set_of_books_id,         -- Set of Books Id
			l_attribute_category,		-- Introduced DFF columns for bug fix 2908859
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
            ELSE


	   -- modified as per 11i changes
	   -- dbms_output.put_line('Project id 6 '|| to_char(l_project_id));
	   -- dbms_output.put_line('task id 6 '|| to_char(l_task_id));
	   -- dbms_output.put_line('Type 6 '|| l_expenditure_type);
	   -- dbms_output.put_line('Dt 6 '|| to_char(p_payroll_start_date));
	   -- dbms_output.put_line('person_id 6 '|| to_char(p_person_id));
	    pa_transactions_pub.validate_transaction(
			x_project_id		=> l_project_id,
			x_task_id		=> l_task_id,
			x_ei_date		=> p_effective_date, ----p_payroll_start_date, Bug 1874696
			x_expenditure_type	=> l_expenditure_type,
			x_non_labor_resource	=> null,
			x_person_id		=> p_person_id,
			x_incurred_by_org_id	=> l_expenditure_org_id,
			x_calling_module	=> 'PSPLDCDB',
			x_msg_application	=> l_msg_app,
			x_msg_type		=> l_msg_type,
			x_msg_token1		=> l_msg_token1,
			x_msg_token2		=> l_msg_token2,
			x_msg_token3		=> l_msg_token3,
			x_msg_count		=> l_msg_count,
			x_msg_data		=> l_patc_status,
			x_billable_flag		=> l_billable_flag,
			p_sys_link_function     => 'ST');            --Bug 5639589: Added parameter


	   -- dbms_output.put_line('patc stat 6 '|| l_patc_status);
	    -- GMS is enabled and patc went through
	     if l_award_id is not null and l_patc_status is null
             then
                 gms_transactions_pub.validate_transaction
                                (l_project_id,
                                l_task_id,
				l_award_id,
                                l_expenditure_type,
                                p_effective_date, ----p_payroll_start_date, Bug 1874696
                                'PSPLDCDB',
                                l_award_status);

/*********************************************************************
                 if l_award_status is null
                 then
                        project_award_linkage(l_project_id,
                                  l_award_id,
                                  l_linkage_status,
                                  l_return_status);
		 else

*************************************************************************/

                if l_award_status IS NOT NULL then
		--	l_patc_status := l_award_status;  for bug fix 1931680
                        l_patc_status  := substr(l_award_status,1,50);
                 end if;
             end if;

             IF (l_patc_status IS NOT NULL) OR
----  (l_linkage_status IS NOT NULL) OR
		(l_award_status is not null) THEN
                suspense_account(
                         x_proc_executed,
                         p_person_id,
                         p_sub_line_id,
                         p_assignment_id,
                         p_payroll_start_date,
                         p_daily_rate,
                         l_patc_status,
                         NULL,
                         l_organization_account_id,
                         NULL,
                         NULL,
                         p_effective_date,
                         p_mode,
			 p_business_group_id,
                         p_set_of_books_id,
                        NULL,   ---    for autopop perf. patch
                         l_return_status);

                 IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                 END IF;

              ELSIF (l_patc_status IS NULL)
---OR (l_linkage_status IS NULL) OR
                OR
			(l_award_status is null) THEN
                /* Bug 1874696
		if l_award_id is not null
		then
                    psp_general.poeta_effective_date(p_payroll_start_date,
                                     l_project_id,
                                     l_award_id,
				     l_task_id,
                                     l_effective_date,
                                     l_return_status);
		elsif l_award_id is null
		then
                    psp_general.poeta_effective_date(p_payroll_start_date,
                                     l_project_id,
				     l_task_id,
                                     l_effective_date,
                                     l_return_status);
		end if;

                    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                    END IF; */
                    l_gl_project_flag := 'P';

                    -- insert the record in psp_distribution_lines
                    insert_into_distribution_lines(
			P_SUB_LINE_ID,             -- payroll sub-lines id
 			P_PAYROLL_START_DATE,      -- distribution date
                        P_EFFECTIVE_DATE,          -- effective date     Bug 1874696 changed from l_Effective_date
 			ROUND(P_DAILY_RATE, g_precision),-- distribution amount Introduced rounding for bug 3109943
 			'N',                       -- status code
                        NULL,                      -- suspense reason code
                        P_DEFAULT_REASON_CODE,     -- default reason code
      			NULL,                      -- schedule line id
 			L_ORGANIZATION_ACCOUNT_ID, -- default organization a/c
 			NULL,                      -- suspense organization a/c
 			NULL,                      -- global element type
			NULL,                      -- org default schedule id
                        L_GL_PROJECT_FLAG,         -- gl project flag
                        NULL,                      -- reversal entry flag
                        l_gl_code_combination_id,  -- gl_code_combination_id
                        l_project_id,              -- project_id,
                        l_task_id   ,              -- task_id,
                        l_award_id  ,              -- award_id,
                        l_expenditure_org_id,      -- expenditure org id
                        l_expenditure_type,        -- expenditure_type
                        l_effective_start_date,    -- Eff start date of schedule
                        l_effective_end_date,      -- Eff start date of schedule
                        p_mode,                    -- 'I' for LD ,'R' for others
			p_business_group_id,       -- Business Group Id
                        p_set_of_books_id,         -- Set of Books Id
			l_attribute_category,		-- Introduced DFF columns for bug fix 2908859
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
                END IF;
             END IF;
           END IF;
   --
   p_return_status := fnd_api.g_ret_sts_success;

  EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      g_error_api_path := SUBSTR('DEFAULT_ACCOUNT:'||g_error_api_path,1,230);
      p_return_status := fnd_api.g_ret_sts_unexp_error;

    WHEN DEFAULT_AC_NOT_FOUND THEN
      g_error_api_path := SUBSTR('DEFAULT_ACCOUNT:'||g_error_api_path,1,230);
      fnd_message.set_name('PSP','PSP_LD_DEFAULT_AC_NOT_SET_UP');
      fnd_msg_pub.add;
      g_msg := SUBSTR(fnd_message.get,1,230);
      --- Next line added by Abhijit as a patch on 7/24/98.
      p_proc_executed := 'FALSE';
      p_return_status := fnd_api.g_ret_sts_success;

    WHEN OTHERS THEN
      g_error_api_path := SUBSTR('DEFAULT_ACCOUNT:'||g_error_api_path,1,230);
      fnd_msg_pub.add_exc_msg('PSB_LABOR_DIST','DEFAULT_ACCOUNT');
      p_return_status := fnd_api.g_ret_sts_unexp_error;

  END;

------------------------- S U S P E N S E  A / C --------------------------------------
 PROCEDURE suspense_account (
                             p_proc_executed          OUT NOCOPY  VARCHAR2,
                             p_person_id               IN NUMBER,
                             p_sub_line_id             IN  NUMBER,
                             p_assignment_id           IN  NUMBER,
                             p_payroll_start_date      IN  DATE,
                             p_daily_rate              IN  NUMBER,
                             p_suspense_reason_code    IN  VARCHAR2,
                             p_schedule_line_id        IN  NUMBER,
                             p_default_org_account_id  IN  NUMBER,
                             p_element_account_id      IN  NUMBER,
                             p_org_schedule_id         IN  NUMBER,
                             p_effective_date          IN  DATE,
                             p_mode                    IN  VARCHAR2 := 'I',
			     p_business_group_id       IN  NUMBER,
                             p_set_of_books_id         IN  NUMBER,
                             p_dist_line_id            IN NUMBER,
                             p_return_status          OUT NOCOPY  VARCHAR2) IS

  CURSOR org_name_cur(P_PAYROLL_START_DATE	IN	DATE,
                      P_ASSIGNMENT_ID		IN	NUMBER) IS
    SELECT hou.organization_id,
           hou.name
    FROM   hr_organization_units hou,
           per_assignments_f paf
    WHERE  paf.business_group_id = p_business_group_id
    AND    paf.assignment_id = p_assignment_id
    and    paf.assignment_type = 'E'
    AND    paf.business_group_id = hou.business_group_id
    AND    p_payroll_start_date BETWEEN paf.effective_start_date AND paf.effective_end_date
    AND    hou.organization_id = paf.organization_id
    AND    p_payroll_start_date between date_from and nvl(date_to,p_payroll_start_date);


   CURSOR suspense_account_cur(L_ORGANIZATION_ID	IN	NUMBER,
                               P_PAYROLL_START_DATE	IN	DATE,
                               L_ACCOUNT_TYPE_CODE	IN	VARCHAR2) IS
   SELECT poa.organization_account_id,
          poa.gl_code_combination_id,
          poa.project_id,
          poa.task_id,
          poa.award_id,
          poa.expenditure_type,
          poa.expenditure_organization_id,
          poa.start_date_active,
          nvl(poa.end_date_active,p_payroll_start_date),    ---- introduced decode below for 5014193
          decode(g_dff_grouping_option, 'Y',	poa.attribute_category),-- Introduced DFF columns for bug fix 2908859
	 decode(g_dff_grouping_option, 'Y',poa.attribute1),
	 decode(g_dff_grouping_option, 'Y',poa.attribute2),
	 decode(g_dff_grouping_option, 'Y',poa.attribute3),
	 decode(g_dff_grouping_option, 'Y',poa.attribute4),
	 decode(g_dff_grouping_option, 'Y',poa.attribute5),
	 decode(g_dff_grouping_option, 'Y',poa.attribute6),
	 decode(g_dff_grouping_option, 'Y',poa.attribute7),
	 decode(g_dff_grouping_option, 'Y',poa.attribute8),
	 decode(g_dff_grouping_option, 'Y',poa.attribute9),
	 decode(g_dff_grouping_option, 'Y',poa.attribute10)
   FROM   psp_organization_accounts poa
   WHERE  business_group_id = p_business_group_id
   AND    set_of_books_id = p_set_of_books_id
   AND    poa.organization_id = l_organization_id
   AND    poa.account_type_code = l_account_type_code
   AND    p_payroll_start_date BETWEEN poa.start_date_active AND
                                       nvl(poa.end_date_active,p_payroll_start_date);

 /* Following cursor is added for bug 2514611 */
   CURSOR employee_name_cur IS
   SELECT full_name
   FROM   per_people_f
   WHERE  person_id =p_person_id;

/*
   CURSOR global_susp_account_cur(P_PAYROLL_START_DATE IN	DATE) IS
   SELECT poa.organization_account_id,
          poa.gl_code_combination_id,
          poa.project_id,
          poa.task_id,
          poa.award_id,
          poa.expenditure_type,
          poa.expenditure_organization_id
   FROM   psp_organization_accounts poa
   WHERE  poa.account_type_code = 'G'
   AND    p_payroll_start_date BETWEEN poa.start_date_active AND
                                       nvl(poa.end_date_active,p_payroll_start_date);
*/


  l_organization_id                NUMBER(15);
  l_organization_name              hr_all_organization_units_tl.name%TYPE; -- Bug 2447912: Modified declaration
  l_gl_code_combination_id         NUMBER(15);
  l_project_id                     NUMBER(15);
  l_task_id                        NUMBER(15);
  l_award_id                       NUMBER(15);
  l_expenditure_type               VARCHAR2(30);
  l_expenditure_org_id             NUMBER(15);
  l_effective_start_date           DATE;
  l_effective_end_date             DATE;
	l_attribute_category	VARCHAR2(30);			-- Introduced DFF variable for bug fix 2908859
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
  l_return_status                  VARCHAR2(1);
  ---l_effective_date                 DATE; Bug 1874696
  profile_val_date_matches         EXCEPTION;
  no_profile_exists                EXCEPTION;
  no_val_date_matches              EXCEPTION;
  no_global_acct_exists            EXCEPTION;
  suspense_ac_invalid              EXCEPTION;
  NO_REC_IN_GMS_AWARDS_V           EXCEPTION;
  PROJECT_AWARD_NOT_LNKD           EXCEPTION;
  l_gl_project_flag                VARCHAR2(1);
  l_organization_account_id        NUMBER(9);
  l_return_value                   VARCHAR2(30);
  l_linkage_status                 VARCHAR2(50) := NULL;
  l_patc_status                    VARCHAR2(50) := NULL;
  l_billable_flag                  VARCHAR2(1)  := NULL;
  l_msg_count                      NUMBER;
  l_msg_app                        VARCHAR2(2000);
  l_msg_type                       varchar2(2000);
  l_msg_token1                     varchar2(2000);
  l_msg_token2                     varchar2(2000);
  l_msg_token3                     varchar2(2000);
  --l_award_status  varchar2(50);  -- for bug fix 1931680
  l_employee_name  VARCHAR2(240); --Added for bug 2514611
  l_award_status  varchar2(200);

 BEGIN
    -- dbms_output.put_line('Entereing suspense');
     hr_utility.trace('CDL process --> suspense account proc entered');
     p_proc_executed := 'TRUE';
     OPEN org_name_cur(p_payroll_start_date,p_assignment_id);
        FETCH org_name_cur INTO l_organization_id,l_organization_name;
     CLOSE org_name_cur;
     --
     OPEN suspense_account_cur(l_organization_id,p_payroll_start_date,'S');
     FETCH suspense_account_cur INTO
           l_organization_account_id,
           l_gl_code_combination_id,
           l_project_id,
           l_task_id,
           l_award_id,
           l_expenditure_type,
           l_expenditure_org_id,
           l_effective_start_date,
           l_effective_end_date,
	l_attribute_category,			-- Introduced DFF variables for bug fix 2908859
	l_attribute1,
	l_attribute2,
	l_attribute3,
	l_attribute4,
	l_attribute5,
	l_attribute6,
	l_attribute7,
	l_attribute8,
	l_attribute9,
	l_attribute10;

     IF suspense_account_cur%NOTFOUND THEN
       CLOSE suspense_account_cur;
       ---
       l_return_value := psp_general.find_global_suspense(p_payroll_start_date,
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
       IF l_return_value = 'PROFILE_VAL_DATE_MATCHES' THEN
          BEGIN
             SELECT gl_code_combination_id,
                    project_id,
                    task_id,
                    award_id,
                    expenditure_type,
                    expenditure_organization_id,
                    start_date_active,
                    end_date_active,
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
			attribute10
             INTO   l_gl_code_combination_id,
                    l_project_id,
                    l_task_id,
                    l_award_id,
                    l_expenditure_type,
                    l_expenditure_org_id,
                    l_effective_start_date,
                    l_effective_end_date,
			l_attribute_category,			-- Introduced DFF variables for bug fix 2908859
			l_attribute1,
			l_attribute2,
			l_attribute3,
			l_attribute4,
			l_attribute5,
			l_attribute6,
			l_attribute7,
			l_attribute8,
			l_attribute9,
			l_attribute10
             FROM   psp_organization_accounts
             WHERE  organization_account_id = l_organization_account_id;

          EXCEPTION
             WHEN OTHERS THEN
                RAISE no_global_acct_exists;
          END;
       ELSIF l_return_value = 'NO_GLOBAL_ACCT_EXISTS' THEN
         RAISE no_global_acct_exists;
       ELSIF l_return_value = 'NO_VAL_DATE_MATCHES' THEN
         RAISE no_val_date_matches;
       ELSIF l_return_value = 'NO_PROFILE_EXISTS' THEN
         RAISE no_profile_exists;
       END IF;
     END IF;
/*
       OPEN global_susp_account_cur(p_payroll_start_date);
       FETCH global_susp_account_cur INTO
             l_organization_account_id,
             l_gl_code_combination_id,
             l_project_id,
             l_task_id,
             l_award_id,
             l_expenditure_type,
             l_expenditure_org_id;
       IF global_susp_account_cur%NOTFOUND THEN
         CLOSE global_susp_account_cur;
         RAISE suspense_ac_not_found;
       END IF;
   -- dbms_output.put_line('Project id ='||to_char(l_project_id));
   -- dbms_output.put_line('Task id ='||to_char(l_task_id));
   -- dbms_output.put_line('Payroll date ='||to_char(p_payroll_start_date));
   -- dbms_output.put_line('Exp. type ='||l_expenditure_type);
   -- dbms_output.put_line('Award id ='||to_char(l_award_id));
*/
     hr_utility.trace('CDL process --> suspense account --> suspense l_gl_project_flag ='||l_gl_project_flag);
    IF l_gl_code_combination_id IS NOT NULL THEN
       ---l_effective_date := p_effective_date; Bug 1874696
       l_gl_project_flag := 'G';

 -- if (g_auto_population= 'Y' and p_mode='I') then  --- for autopop perf bug fixing

  if p_dist_line_id is not null then
       -- commented first check and introduced above for bug fix 2463092
     hr_utility.trace('CDL process --> suspense account --> dist line not null ='||p_dist_line_id);

      update psp_distribution_lines set
          suspense_org_account_id = l_organization_account_id,
          suspense_reason_code= p_suspense_reason_code,
          gl_project_flag = l_gl_project_flag,
          effective_date = g_gl_effective_date, --- added for 2663344
	attribute_category	=	l_attribute_category,		-- Introduced DFF columns for bug fix 2908859
	attribute1		=	l_attribute1,
	attribute2		=	l_attribute2,
	attribute3		=	l_attribute3,
	attribute4		=	l_attribute4,
	attribute5		=	l_attribute5,
	attribute6		=	l_attribute6,
	attribute7		=	l_attribute7,
	attribute8		=	l_attribute8,
	attribute9		=	l_attribute9,
	attribute10		=	l_attribute10
      where distribution_line_id = p_dist_line_id;

  else

       -- insert rows into psp_distribution_lines
       insert_into_distribution_lines(
 		P_SUB_LINE_ID,                  -- payroll sub-lines id
 		P_PAYROLL_START_DATE,           -- distribution date
                G_GL_EFFECTIVE_DATE,            -- effective_date  changed from p_Effective_date Bug 2663344
 		ROUND(P_DAILY_RATE, g_precision),-- distribution amount. Introduced rounding for bug 3109943
 		'N',                            -- status code
                P_SUSPENSE_REASON_CODE,         -- suspense reason code
                NULL,                           -- default reason code
      	        P_SCHEDULE_LINE_ID,             -- schedule line id
 		P_DEFAULT_ORG_ACCOUNT_ID,       -- default organization a/c
 		L_ORGANIZATION_ACCOUNT_ID,      -- suspense organization a/c
 		P_ELEMENT_ACCOUNT_ID,           -- global element type
		P_ORG_SCHEDULE_ID,              -- org default schedule id
                L_GL_PROJECT_FLAG,              -- gl project flag
                NULL,                           -- reversal entry flag
                l_gl_code_combination_id,       -- gl_code_combination_id
                l_project_id,                   -- project_id,
                l_task_id   ,                   -- task_id,
                l_award_id  ,                   -- award_id,
                l_expenditure_org_id,           -- expenditure org id
                l_expenditure_type,             -- expenditure_type
                l_effective_start_date,         -- Eff start date of schedule
                l_effective_end_date,           -- Eff start date of schedule
                p_mode,                         -- 'I' for LD ,'R' for others
		p_business_group_id,            -- Business Group Id
                p_set_of_books_id,              -- Set of Books Id
		l_attribute_category,		-- Introduced DFF columns for bug fix 2908859
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
  end if;

     ELSIF l_gl_code_combination_id IS NULL THEN
        IF g_suspense_account_autopop = 'Y'  then--- 5080403
                   l_gl_project_flag:='P';
        if p_dist_line_id is null then

       insert_into_distribution_lines(
 		P_SUB_LINE_ID,                  -- payroll sub-lines id
 		P_PAYROLL_START_DATE,           -- distribution date
                P_EFFECTIVE_DATE,            -- effective_date  changed from p_Effective_date Bug 2663344
 		ROUND(P_DAILY_RATE, g_precision),-- distribution amount. Introduced rounding for bug 3109943
 		'N',                            -- status code
                P_SUSPENSE_REASON_CODE,         -- suspense reason code
                NULL,                           -- default reason code
      	        P_SCHEDULE_LINE_ID,             -- schedule line id
 		P_DEFAULT_ORG_ACCOUNT_ID,       -- default organization a/c
 		L_ORGANIZATION_ACCOUNT_ID,      -- suspense organization a/c
 		P_ELEMENT_ACCOUNT_ID,           -- global element type
		P_ORG_SCHEDULE_ID,              -- org default schedule id
                L_GL_PROJECT_FLAG,              -- gl project flag
                NULL,                           -- reversal entry flag
                l_gl_code_combination_id,       -- gl_code_combination_id
                l_project_id,                   -- project_id,
                l_task_id   ,                   -- task_id,
                l_award_id  ,                   -- award_id,
                l_expenditure_org_id,           -- expenditure org id
                l_expenditure_type,             -- expenditure_type
                l_effective_start_date,         -- Eff start date of schedule
                l_effective_end_date,           -- Eff start date of schedule
                p_mode,                         -- 'I' for LD ,'R' for others
		p_business_group_id,            -- Business Group Id
                p_set_of_books_id,              -- Set of Books Id
		l_attribute_category,		-- Introduced DFF columns for bug fix 2908859
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
             else
                 update psp_distribution_lines set
                        suspense_reason_code= p_suspense_reason_code,
                        suspense_org_Account_id= l_organization_account_id,
                        gl_project_flag = l_gl_project_flag,
                        effective_date = p_effective_date,
		          attribute_category	=	l_attribute_category,
		          attribute1		=	l_attribute1,
		          attribute2		=	l_attribute2,
		          attribute3		=	l_attribute3,
		          attribute4		=	l_attribute4,
		          attribute5		=	l_attribute5,
		          attribute6		=	l_attribute6,
		          attribute7		=	l_attribute7,
		          attribute8		=	l_attribute8,
		          attribute9		=	l_attribute9,
		          attribute10		=	l_attribute10
                    where distribution_line_id=p_dist_line_id;
             end if;

            ELSE

	    pa_transactions_pub.validate_transaction(
			x_project_id		=> l_project_id,
			x_task_id		=> l_task_id,
			x_ei_date		=> p_effective_date, ---p_payroll_start_date, Bug 1874696
			x_expenditure_type	=> l_expenditure_type,
			x_non_labor_resource	=> null,
			x_person_id		=> p_person_id,
			x_incurred_by_org_id	=> l_expenditure_org_id,
			x_calling_module	=> 'PSPLDCDB',
			x_msg_application	=> l_msg_app,
			x_msg_type		=> l_msg_type,
			x_msg_token1		=> l_msg_token1,
			x_msg_token2		=> l_msg_token2,
			x_msg_token3		=> l_msg_token3,
			x_msg_count		=> l_msg_count,
			x_msg_data		=> l_patc_status,
			x_billable_flag		=> l_billable_flag,
			p_sys_link_function     => 'ST');            --Bug 5639589: Added parameter


	   -- dbms_output.put_line('patc stat 7 '|| l_patc_status);
	     -- GMS is enabled and patc went fine
	     if l_award_id is not null  and l_patc_status is null
             then
                 gms_transactions_pub.validate_transaction
                                (l_project_id,
                                l_task_id,
				l_award_id,
                                l_expenditure_type,
                                p_effective_date, ----p_payroll_start_date, Bug 1874696
                                'PSPLDCDB',
                                l_award_status);

/************************************************************************************
                 if l_award_status is null
                 then
                        project_award_linkage(l_project_id,
                                  l_award_id,
                                  l_linkage_status,
                                  l_return_status);
		 else

***************************************************************************************/

                 if l_award_status IS NOT NULL THEN
		--	l_patc_status := l_award_status;  for bug fix 1931680
                        l_patc_status  := substr(l_award_status,1,50);
                 end if;
             end if;

/**********************************************************************

       IF l_linkage_status = 'PSP_GMS_AWARDS_V_NO_RECS'  THEN
          RAISE NO_REC_IN_GMS_AWARDS_V;
       ELSIF l_linkage_status = 'PSP_PROJ_AWRD_NOT_LNKD' THEN
          RAISE PROJECT_AWARD_NOT_LNKD;
       ELSIF l_patc_status IS NOT NULL THEN

***************************************************************/

       IF l_patc_status IS NOT NULL THEN
          RAISE SUSPENSE_AC_INVALID;
       END IF;
       ---
       IF (l_patc_status IS NULL) OR
---  OR (l_linkage_status IS NULL) OR
		(l_award_status IS NULL) THEN
        /* Bug 1874696
	if l_award_id is not null
	then
            psp_general.poeta_effective_date(p_payroll_start_date,
                               l_project_id,
                               l_award_id,
			       l_task_id,
                               l_effective_date,
                               l_return_status);
	elsif l_award_id is null
	then
            psp_general.poeta_effective_date(p_payroll_start_date,
                               l_project_id,
			       l_task_id,
                               l_effective_date,
                               l_return_status);
	end if; */
             l_gl_project_flag := 'P';
             IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
             END IF;

  -- if (g_auto_population='Y' and p_mode='I')then

         -- commented above and introduced if condition below for bug fix 2463092

   if p_dist_line_id is not null  then
      update psp_distribution_lines set
              suspense_reason_code= p_suspense_reason_code,
              suspense_org_Account_id= l_organization_account_id,
              gl_project_flag = l_gl_project_flag,
              effective_date = p_effective_date, --- added for 2663344
		attribute_category	=	l_attribute_category,		-- Introduced DFF columns for bug fix 2908859
		attribute1		=	l_attribute1,
		attribute2		=	l_attribute2,
		attribute3		=	l_attribute3,
		attribute4		=	l_attribute4,
		attribute5		=	l_attribute5,
		attribute6		=	l_attribute6,
		attribute7		=	l_attribute7,
		attribute8		=	l_attribute8,
		attribute9		=	l_attribute9,
		attribute10		=	l_attribute10
      where distribution_line_id=p_dist_line_id;



   else
              -- insert rows into psp_distribution_lines
              insert_into_distribution_lines(
 		P_SUB_LINE_ID,                  -- payroll sub-lines id
 		P_PAYROLL_START_DATE,           -- distribution date
                P_EFFECTIVE_DATE,               -- effective_date     Bug 1874696
  		ROUND(P_DAILY_RATE, g_precision),-- distribution amount. Introduced rounding for bug 3109943
 		'N',                            -- status code
                P_SUSPENSE_REASON_CODE,         -- suspense reason code
                NULL,                           -- default reason code
      	        P_SCHEDULE_LINE_ID,             -- schedule line id
 	        P_DEFAULT_ORG_ACCOUNT_ID,       -- default organization a/c
 		L_ORGANIZATION_ACCOUNT_ID,      -- suspense organization a/c
 		P_ELEMENT_ACCOUNT_ID,           -- global element type
		P_ORG_SCHEDULE_ID,              -- org default schedule id
                L_GL_PROJECT_FLAG,              -- gl project flag
                NULL,                           -- reversal entry flag
                l_gl_code_combination_id,       -- gl_code_combination_id
                l_project_id,                   -- project_id,
                l_task_id   ,                   -- task_id,
                l_award_id  ,                   -- award_id,
                l_expenditure_org_id,           -- expenditure org id
                l_expenditure_type,             -- expenditure_type
                l_effective_start_date,         -- Eff start date of schedule
                l_effective_end_date,           -- Eff start date of schedule
                p_mode,                         -- 'I' for LD ,'R' for others
		p_business_group_id,            -- Business Group Id
                p_set_of_books_id,              -- Set of Books Id
		l_attribute_category,		-- Introduced DFF columns for bug fix 2908859
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
     END IF;
   END IF;
  END IF;
 END IF;
     p_return_status := fnd_api.g_ret_sts_success;

 EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      g_error_api_path := SUBSTR('SUSPENSE_ACCOUNT:'||g_error_api_path,1,230);
      p_return_status := fnd_api.g_ret_sts_unexp_error;

   WHEN NO_PROFILE_EXISTS THEN
      g_error_api_path := SUBSTR('SUSPENSE_ACCOUNT:'||g_error_api_path,1,230);
      fnd_message.set_name('PSP','PSP_NO_PROFILE_EXISTS');
      fnd_msg_pub.add;
      p_return_status := fnd_api.g_ret_sts_unexp_error;

   WHEN NO_VAL_DATE_MATCHES THEN
      g_error_api_path := SUBSTR('SUSPENSE_ACCOUNT:'||g_error_api_path,1,230);
      fnd_message.set_name('PSP','PSP_NO_VAL_DATE_MATCHES');
      fnd_message.set_token('ORG_NAME',l_organization_name);
      fnd_message.set_token('PAYROLL_DATE',p_payroll_start_date);
      fnd_msg_pub.add;
      p_return_status := fnd_api.g_ret_sts_unexp_error;

   WHEN NO_GLOBAL_ACCT_EXISTS THEN
      g_error_api_path := SUBSTR('SUSPENSE_ACCOUNT:'||g_error_api_path,1,230);
      fnd_message.set_name('PSP','PSP_NO_GLOBAL_ACCT_EXISTS');
      fnd_message.set_token('ORG_NAME',l_organization_name);
      fnd_message.set_token('PAYROLL_DATE',p_payroll_start_date);
      fnd_msg_pub.add;
      p_return_status := fnd_api.g_ret_sts_unexp_error;

   WHEN NO_REC_IN_GMS_AWARDS_V THEN
      g_error_api_path := SUBSTR('SUSPENSE_ACCOUNT:'||g_error_api_path,1,230);
      fnd_message.set_name('PSP','PSP_NO_REC_IN_GMS_AWARDS_V');
      fnd_msg_pub.add;
      p_return_status := fnd_api.g_ret_sts_unexp_error;

   WHEN PROJECT_AWARD_NOT_LNKD THEN
      g_error_api_path := SUBSTR('SUSPENSE_ACCOUNT:'||g_error_api_path,1,230);
      fnd_message.set_name('PSP','PSP_PROJECT_AWARD_NOT_LINKED');
      fnd_message.set_token('PROJECT_NAME',to_char(l_project_id));
      fnd_message.set_token('AWARD_NAME',to_char(l_award_id));
      fnd_msg_pub.add;
      p_return_status := fnd_api.g_ret_sts_unexp_error;

   WHEN SUSPENSE_AC_INVALID THEN
     /* Following added for bug 2514611 */
      OPEN   employee_name_cur;
      FETCH  employee_name_cur INTO l_employee_name;
      CLOSE  employee_name_cur;

      g_error_api_path := SUBSTR('SUSPENSE_ACCOUNT:'||g_error_api_path,1,230);
      fnd_message.set_name('PSP','PSP_LD_SUSPENSE_AC_INVALID');
      fnd_message.set_token('ORG_NAME',l_organization_name);
      fnd_message.set_token('PATC_STATUS',l_patc_status);
      fnd_message.set_token('EMPLOYEE_NAME',l_employee_name); --Bug 2514611
      fnd_msg_pub.add;
      p_return_status := fnd_api.g_ret_sts_unexp_error;

   WHEN OTHERS THEN
      g_error_api_path := SUBSTR('SUSPENSE_ACCOUNT:'||g_error_api_path,1,230);
      fnd_msg_pub.add_exc_msg('PSB_LABOR_DIST','SUSPENSE_ACCOUNT');
      p_return_status := fnd_api.g_ret_sts_unexp_error;

 END;

/*

 Commented out NOCOPY  for autopop performance optimization


--------------- A U T O - P O P U L A T I O N -----------------------------------------
PROCEDURE autopop(p_acct_type                   IN VARCHAR2,
		  p_person_id                   IN NUMBER,
		  p_assignment_id               IN NUMBER,
		  p_element_type_id             IN NUMBER,
		  p_project_id                  IN NUMBER,
		  p_expenditure_organization_id IN NUMBER,
		  p_task_id                     IN NUMBER,
		  p_award_id                    IN NUMBER,
                  p_expenditure_type            IN VARCHAR2,
		  p_gl_code_combination_id      IN NUMBER,
		  p_payroll_start_date          IN DATE,
		  p_effective_date              IN DATE,
 		  p_dist_amount                 IN NUMBER,
		  p_schedule_line_id            IN NUMBER,
                  p_org_schedule_id             IN NUMBER,
		  p_sub_line_id                 IN NUMBER,
                  p_effective_start_date        IN DATE ,
                  p_effective_end_date          IN DATE ,
                  p_mode                        IN VARCHAR2 := 'I',
		  p_business_group_id           IN NUMBER,
                  p_set_of_books_id             IN NUMBER,
		  p_return_status 		OUT NOCOPY VARCHAR2) IS

l_new_gl_code_combination_id     NUMBER(15);
l_new_expenditure_type	         VARCHAR2(30);
--g_distribution_line_id           NUMBER(10); 2470954
l_auto_pop_status		         VARCHAR2(1);
l_gl_project_flag                VARCHAR2(1);
l_auto_status                    VARCHAR2(20) := null;
l_return_status                  VARCHAR2(1);
l_patc_status			   VARCHAR2(50);
x_proc_executed                  VARCHAR2(10) := 'TRUE';
l_billable_flag                  VARCHAR2(1);
l_effective_date                 DATE;
l_msg_count                      NUMBER;
l_msg_app                        VARCHAR2(2000);
l_msg_type                       varchar2(2000);
l_msg_token1                     varchar2(2000);
l_msg_token2                     varchar2(2000);
l_msg_token3                     varchar2(2000);
  --l_award_status  varchar2(50);  -- for bug fix 1931680
  l_award_status  varchar2(200);
l_linkage_status                 VARCHAR2(50) := NULL;


BEGIN

   IF p_acct_type = 'N' THEN
     l_gl_project_flag := 'G';

  --dbms_output.put_line('params are '||p_person_id,' '||p_assignment_id||' '||p_element_type_id );
-- dbms_output.put_line('ccid is '||p_gl_code_combination_id||' '||p_payroll_start_date||' ');
-- dbms_output.put_line(' bg is '||p_business_group_id||' '||p_ste_of_books_id);

     psp_autopop.main(
                    p_acct_type                   => p_acct_type,
		    p_person_id                   => p_person_id,
	            p_assignment_id               => p_assignment_id,
		    p_element_type_id             => p_element_type_id,
		    p_project_id                  => null,
		    p_expenditure_organization_id => null,
		    p_task_id                     => null,
		    p_award_id                    => null,
                    p_expenditure_type            => null,
		    p_gl_code_combination_id      => p_gl_code_combination_id,
		    p_payroll_date                => p_payroll_start_date,
		    p_set_of_books_id             => p_set_of_books_id,
                    p_business_group_id           => p_business_group_id,
		    ret_expenditure_type          => l_new_expenditure_type,
		    ret_gl_code_combination_id    => l_new_gl_code_combination_id,
		    retcode 			  => l_auto_pop_status);

     IF (l_auto_pop_status = FND_API.G_RET_STS_UNEXP_ERROR) OR
       (l_auto_pop_status = FND_API.G_RET_STS_ERROR) THEN
       IF l_auto_pop_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         l_auto_status := 'AUTO_POP_NA_ERROR';
       ELSIF l_auto_pop_status = FND_API.G_RET_STS_ERROR THEN
         l_auto_status := 'AUTO_POP_NO_VALUE';
       END IF;

       -- Auto-Population returned an error or no value. Use Suspense Acct.
         suspense_account(x_proc_executed,
                        p_person_id,
                        p_sub_line_id,
                        p_assignment_id,
                        p_payroll_start_date,
                        p_dist_amount,
                        l_auto_status,
                        p_schedule_line_id,
                        NULL,
                        NULL,
                        p_org_schedule_id,
                        p_effective_date,
                        p_mode,
			p_business_group_id,
                        p_set_of_books_id,
                        l_return_status);

         IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;

     ELSIF l_auto_pop_status = FND_API.G_RET_STS_SUCCESS THEN
 	 -- insert the record in psp_distribution_lines
       insert_into_distribution_lines(
	          P_SUB_LINE_ID,                  -- payroll sub-lines id
 	          P_PAYROLL_START_DATE,           -- distribution date
                  P_EFFECTIVE_DATE,               -- effective date
 		  P_DIST_AMOUNT,                  -- distribution amount
 		  'N',                            -- status code
                  NULL,                           -- suspense reason code
                  NULL,                           -- default reason code
      		  P_SCHEDULE_LINE_ID,             -- schedule line id
 		  NULL,                           -- default organization a/c
 		  NULL,                           -- suspense organization a/c
 		  NULL,                           -- global element type
	          P_ORG_SCHEDULE_ID,              -- org default schedule id
                  l_gl_project_flag,              -- gl project flag
                  NULL,                           -- reversal entry flag
                  l_new_gl_code_combination_id,   -- gl_code_combination_id
                  p_project_id,                   -- project_id,
                  p_task_id   ,                   -- task_id,
                  p_award_id  ,                   -- award_id,
                  p_expenditure_organization_id,  -- expenditure org id
                  p_expenditure_type,             -- expenditure_type
                  p_effective_start_date,         -- Eff start date of schedule
                  p_effective_end_date,           -- Eff start date of schedule
                  p_mode,                         -- 'I' for LD ,'R' for others
		  p_business_group_id,            -- Business Group Id
                  p_set_of_books_id,              -- Set of Books Id
		l_attribute_category,		-- Introduced DFF columns for bug fix 2908859
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
        insert_into_autopop_results(
				    G_DIST_LINE_ID,
				    NULL,
				    L_NEW_GL_CODE_COMBINATION_ID,
				    l_return_status);
        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

      END IF; -- l_auto_pop_status = FND_API.G_RET_STS_SUCCESS

  ELSIF p_acct_type = 'E' THEN
    psp_autopop.main(p_acct_type                   => 'E',
	  p_person_id                    => p_person_id,
	  p_assignment_id                => p_assignment_id,
	  p_element_type_id              => p_element_type_id,
	  p_project_id                   => p_project_id,
	  p_expenditure_organization_id  => p_expenditure_organization_id,
	  p_task_id                      => p_task_id,
	  p_award_id                     => p_award_id,
          p_expenditure_type             => p_expenditure_type,
          p_gl_code_combination_id       => null,
          p_payroll_date                 => p_payroll_start_date,
	  p_set_of_books_id              => p_set_of_books_id,
          p_business_group_id            => p_business_group_id,
          ret_expenditure_type           => l_new_expenditure_type,
          ret_gl_code_combination_id     => l_new_gl_code_combination_id,
	  retcode 		         => l_auto_pop_status);

    IF (l_auto_pop_status = FND_API.G_RET_STS_UNEXP_ERROR) OR
       (l_auto_pop_status = FND_API.G_RET_STS_ERROR) THEN
       IF l_auto_pop_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         l_auto_status := 'AUTO_POP_NA_ERROR';
       ELSIF l_auto_pop_status = FND_API.G_RET_STS_ERROR THEN
         l_auto_status := 'AUTO_POP_NO_VALUE';
       END IF;

       -- Auto-Population returned an error or no value. Use Suspense Acct.
       suspense_account(x_proc_executed,
                       p_person_id,
                       p_sub_line_id,
                       p_assignment_id,
                       p_payroll_start_date,
                       p_dist_amount,
                       l_auto_status,
                       p_schedule_line_id,
                       NULL,
                       NULL,
                       NULL,
                       p_effective_date,
                       p_mode,
		       p_business_group_id,
                       p_set_of_books_id,
                       l_return_status);

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

    ELSIF l_auto_pop_status = FND_API.G_RET_STS_SUCCESS THEN
	-- modified as per 11i changes
	   -- dbms_output.put_line('Project id 8 '|| to_char(p_project_id));
	   -- dbms_output.put_line('task id 8 '|| to_char(p_task_id));
	   -- dbms_output.put_line('Dte id 8 '|| to_char(p_payroll_start_date));
	   -- dbms_output.put_line('Type 8 '|| l_new_expenditure_type);
	   -- dbms_output.put_line('person_id 8 '|| to_char(p_person_id));

	    pa_transactions_pub.validate_transaction(
			x_project_id		=> p_project_id,
			x_task_id		=> p_task_id,
			x_ei_date		=> p_effective_date, ---p_payroll_start_date, Bug 1874696
			x_expenditure_type	=> l_new_expenditure_type,
			x_non_labor_resource	=> null,
			x_person_id		=> p_person_id,
			x_incurred_by_org_id	=> p_expenditure_organization_id,
			x_calling_module	=> 'PSPLDCDB',
			x_msg_application	=> l_msg_app,
			x_msg_type		=> l_msg_type,
			x_msg_token1		=> l_msg_token1,
			x_msg_token2		=> l_msg_token2,
			x_msg_token3		=> l_msg_token3,
			x_msg_count		=> l_msg_count,
			x_msg_data		=> l_patc_status,
			x_billable_flag		=> l_billable_flag,
			p_sys_link_function     => 'ST');            --Bug 5639589: Added parameter


	   -- dbms_output.put_line('patc stat 8 '|| l_patc_status);
	    -- GMS is enabled and patc went through
	     if p_award_id is not null and l_patc_status is null
             then
                 gms_transactions_pub.validate_transaction
                                (p_project_id,
                                p_task_id,
				p_award_id,
                                l_new_expenditure_type,
                                p_effective_date, ---- p_payroll_start_date, Bug 1874696
                                'PSPLDCDB',
                                l_award_status);

                 if l_award_status is null
                 then
                        project_award_linkage(p_project_id,
                                  p_award_id,
                                  l_linkage_status,
                                  l_return_status);
		 else


                   if l_award_status IS NOT NULL

		--	l_patc_status := l_award_status;  for bug fix 1931680
                        l_patc_status  := substr(l_award_status,1,50);
                 end if;
             end if;


      IF l_patc_status IS NOT NULL OR l_award_status is not null
--	or 	l_linkage_status is not null
        THEN
        suspense_account(x_proc_executed,
                         p_person_id,
                         p_sub_line_id,
                         p_assignment_id,
                         p_payroll_start_date,
                         p_dist_amount,
                         l_patc_status,
                         p_schedule_line_id,
                         NULL,
                         NULL,
                         p_org_schedule_id,
                         p_effective_date,
                         p_mode,
			 p_business_group_id,
                         p_set_of_books_id,
                         l_return_status);

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

	ELSIF l_patc_status IS NULL
--  OR l_linkage_status IS NULL   2014950
		OR l_award_status is null THEN
      -- Bug 1874696
--	if p_award_id is not null
--	then
  --          psp_general.poeta_effective_date(p_payroll_start_date,
   --                          p_project_id,
    --                         p_award_id,
   --			     P_task_id,
    --                         l_effective_date,
                             l_return_status);
--	elsif p_award_id is null
--	then
 --           psp_general.poeta_effective_date(p_payroll_start_date,
  --                           p_project_id,
   --			     P_task_id,
                             l_effective_date,
    --                         l_return_status);
--	end if;
 --       IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
  --        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   --     END IF;
        l_gl_project_flag := 'P';

        -- insert the record in psp_distribution_lines
        insert_into_distribution_lines(
	      	P_SUB_LINE_ID,                  -- payroll sub-lines id
       	        P_PAYROLL_START_DATE,           -- distribution date
                P_EFFECTIVE_DATE,               -- effective date, changed from l_Effective_date for 1874696
 	      	P_DIST_AMOUNT,                  -- distribution amount
 	       'N',                             -- status code
                NULL,                           -- suspense reason code
                NULL,                           -- default reason code
      	        P_SCHEDULE_LINE_ID,             -- schedule line id
 	      	NULL,                           -- default organization a/c
 	      	NULL,                           -- suspense organization a/c
 	      	NULL,                           -- global element type
    	        P_ORG_SCHEDULE_ID,              -- org default schedule id
                L_GL_PROJECT_FLAG,              -- gl project flag
                NULL,                           -- reversal entry flag
                p_gl_code_combination_id,       -- gl_code_combination_id
                p_project_id,                   -- project_id,
                p_task_id   ,                   -- task_id,
                p_award_id  ,                   -- award_id,
                p_expenditure_organization_id,  -- expenditure org id
                l_new_expenditure_type,         -- expenditure_type
                p_effective_start_date,    -- Eff start date of schedule
                p_effective_end_date,      -- Eff start date of schedule
                p_mode,                    -- 'I' for LD ,'R' for others
		p_business_group_id,            -- Business Group id
                p_set_of_books_id,              -- Set of Books Id
		l_attribute_category,		-- Introduced DFF columns for bug fix 2908859
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

	   insert_into_autopop_results(
				      G_DIST_LINE_ID,
				      L_NEW_EXPENDITURE_TYPE,
				      NULL,
				      l_return_status);
         IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
       END IF; -- l_patc_status IS NOT NULL

     END IF; -- l_auto_pop_status = FND_API.G_RET_STS_SUCCESS


   END IF;

p_return_status := fnd_api.g_ret_sts_success;

 EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      g_error_api_path := SUBSTR('AUTOPOP:'||g_error_api_path,1,1000);
      p_return_status := fnd_api.g_ret_sts_unexp_error;

   WHEN OTHERS THEN
      g_error_api_path := SUBSTR('AUTOPOP:'||g_error_api_path,1,1000);
      p_return_status := fnd_api.g_ret_sts_unexp_error;


END autopop;



************************************************************************************/


---------------------- I N S E R T   S T A T E M E N T  ------------------------------------
 PROCEDURE insert_into_distribution_lines(
 	   L_PAYROLL_SUB_LINE_ID  	 IN	NUMBER,
 	   L_DISTRIBUTION_DATE		 IN	DATE,
	   L_EFFECTIVE_DATE		 IN	DATE,
 	   L_DISTRIBUTION_AMOUNT	 IN	NUMBER,
 	   L_STATUS_CODE		 IN	VARCHAR2,
 	   L_SUSPENSE_REASON_CODE	 IN	VARCHAR2,
           L_DEFAULT_REASON_CODE	 IN	VARCHAR2,
 	   L_SCHEDULE_LINE_ID		 IN	NUMBER,
 	   L_DEFAULT_ORG_ACCOUNT_ID	 IN	NUMBER,
           L_SUSPENSE_ORG_ACCOUNT_ID	 IN	NUMBER,
 	   L_ELEMENT_ACCOUNT_ID		 IN	NUMBER,
 	   L_ORG_SCHEDULE_ID		 IN	NUMBER,
           L_GL_PROJECT_FLAG		 IN	VARCHAR2,
           L_REVERSAL_ENTRY_FLAG         IN	VARCHAR2,
           P_GL_CODE_COMBINATION_ID      IN     NUMBER,	-- := FND_API.G_MISS_NUM, Commented initialization for bug fix 2916848
           P_PROJECT_ID                  IN     NUMBER,	-- := FND_API.G_MISS_NUM, Commented initialization for bug fix 2916848
           P_TASK_ID                     IN     NUMBER,	-- := FND_API.G_MISS_NUM, Commented initialization for bug fix 2916848
           P_AWARD_ID                    IN     NUMBER,	-- := FND_API.G_MISS_NUM, Commented initialization for bug fix 2916848
           P_EXPENDITURE_ORGANIZATION_ID IN     NUMBER,	-- := FND_API.G_MISS_NUM, Commented initialization for bug fix 2916848
           P_EXPENDITURE_TYPE            IN     VARCHAR2,	-- := FND_API.G_MISS_CHAR, Commented initialization for bug fix 2916848
           P_EFFECTIVE_START_DATE        IN     DATE,	-- := FND_API.G_MISS_DATE, Commented initialization for bug fix 2916848
           P_EFFECTIVE_END_DATE          IN     DATE,	-- := FND_API.G_MISS_DATE, Commented initialization for bug fix 2916848
           P_MODE                        IN     VARCHAR2 := 'I',
	   P_BUSINESS_GROUP_ID           IN     NUMBER,
           P_SET_OF_BOOKS_ID             IN     NUMBER,
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
	P_RETURN_STATUS               OUT NOCOPY    VARCHAR2,
	P_CAP_EXCESS_GLCCID		IN	NUMBER	DEFAULT NULL,
	P_CAP_EXCESS_PROJECT_ID		IN	NUMBER	DEFAULT NULL,
	P_CAP_EXCESS_TASK_ID		IN	NUMBER	DEFAULT NULL,
	P_CAP_EXCESS_AWARD_ID		IN	NUMBER	DEFAULT NULL,
	P_CAP_EXCESS_EXP_ORG_ID		IN	NUMBER	DEFAULT NULL,
	P_CAP_EXCESS_EXP_TYPE		IN	VARCHAR2 DEFAULT NULL ) IS

-- l_description   VARCHAR2(180);		Commented for bug fix 2447912
 l_description	 VARCHAR2(360) DEFAULT  '';	-- Bug 2447912: Increased Width to accomodate Org Name increase
 l_return_status VARCHAR2(1);

 BEGIN
 -- dbms_output.put_line('inserting into dist lines table');
  --- inserting into table for PSB mode also, 3813688
	g_tot_dist_amount := g_tot_dist_amount + l_distribution_amount;
	INSERT INTO PSP_DISTRIBUTION_LINES(
 		DISTRIBUTION_LINE_ID,
 		PAYROLL_SUB_LINE_ID,
 		DISTRIBUTION_DATE,
            	EFFECTIVE_DATE,
 		DISTRIBUTION_AMOUNT,
 		STATUS_CODE,
 		SUSPENSE_REASON_CODE,
            	DEFAULT_REASON_CODE,
 		SCHEDULE_LINE_ID,
 		DEFAULT_ORG_ACCOUNT_ID,
            	SUSPENSE_ORG_ACCOUNT_ID,
 		ELEMENT_ACCOUNT_ID,
 		ORG_SCHEDULE_ID,
		GL_PROJECT_FLAG,
            	REVERSAL_ENTRY_FLAG,
		business_group_id,
		set_of_books_id,
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
		CAP_EXCESS_GLCCID,
                CAP_EXCESS_PROJECT_ID,
                CAP_EXCESS_AWARD_ID,
                CAP_EXCESS_TASK_ID,
                CAP_EXCESS_EXP_ORG_ID,
                CAP_EXCESS_EXP_TYPE)
	VALUES(
                PSP_DISTRIBUTION_LINES_S.NEXTVAL,
 		L_PAYROLL_SUB_LINE_ID,
 		L_DISTRIBUTION_DATE,
                L_EFFECTIVE_DATE,
 		L_DISTRIBUTION_AMOUNT,
 		L_STATUS_CODE,
 		L_SUSPENSE_REASON_CODE,
            	L_DEFAULT_REASON_CODE,
 		L_SCHEDULE_LINE_ID,
 		L_DEFAULT_ORG_ACCOUNT_ID,
            	L_SUSPENSE_ORG_ACCOUNT_ID,
 		L_ELEMENT_ACCOUNT_ID,
 		L_ORG_SCHEDULE_ID,
		L_GL_PROJECT_FLAG,
            	L_REVERSAL_ENTRY_FLAG,
		P_BUSINESS_GROUP_ID,
            	P_SET_OF_BOOKS_ID,
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
		P_CAP_EXCESS_GLCCID,
                P_CAP_EXCESS_PROJECT_ID,
                P_CAP_EXCESS_AWARD_ID,
                P_CAP_EXCESS_TASK_ID,
                P_CAP_EXCESS_EXP_ORG_ID,
                P_CAP_EXCESS_EXP_TYPE);
       -- dbms_output.put_line('rowcount dist lines insert ='||sql%rowcount);
        p_return_status := fnd_api.g_ret_sts_success;
 EXCEPTION
   WHEN OTHERS THEN
     -- dbms_output.put_line('inert into dist lines = '||sqlerrm);
      fnd_msg_pub.add_exc_msg('PSB_LABOR_DIST','INSERT_INTO_DISTRIBUTION_LINES');
      p_return_status := fnd_api.g_ret_sts_unexp_error;

 END insert_into_distribution_lines;

/*

 PROCEDURE insert_into_autopop_results(
 		P_DISTRIBUTION_LINE_ID		IN	NUMBER,
                P_NEW_EXPENDITURE_TYPE          IN VARCHAR2,
                P_NEW_GL_CODE_COMBINATION_ID    IN NUMBER,
            p_return_status              OUT NOCOPY    VARCHAR2) IS
 BEGIN
     --********************************************************************
	INSERT INTO PSP_AUTO_POPULATION_RESULTS(
 		DISTRIBUTION_LINE_ID,
 		EXPENDITURE_TYPE,
 		GL_CODE_COMBINATION_ID)
	VALUES(
            P_DISTRIBUTION_LINE_ID,
 		P_NEW_EXPENDITURE_TYPE,
 		P_NEW_GL_CODE_COMBINATION_ID);
   --  ***************************************************************************
       UPDATE PSP_DISTRIBUTION_LINES
	SET auto_expenditure_type = p_new_expenditure_type,
	    auto_gl_code_combination_id = p_new_gl_code_combination_id
	WHERE distribution_line_id = p_distribution_line_id;

      p_return_status := fnd_api.g_ret_sts_success;

 EXCEPTION
   WHEN OTHERS THEN
      fnd_msg_pub.add_exc_msg('PSB_LABOR_DIST','INSERT_INTO_AUTOPOP_RESULTS');
      p_return_status := fnd_api.g_ret_sts_unexp_error;

 END insert_into_autopop_results;

*/

 PROCEDURE Get_Distribution_Lines
               (p_proc_executed       OUT NOCOPY VARCHAR2,
                p_person_id           IN  NUMBER,	-- := FND_API.G_MISS_NUM, Commented initialization for bug fix 2916848
                p_sub_line_id         IN  NUMBER,	-- := FND_API.G_MISS_NUM, Commented initialization 2916848
                p_assignment_id       IN  NUMBER,	-- := FND_API.G_MISS_NUM, Commented initialization for bug fix 2916848
                p_element_type_id     IN  NUMBER,	-- := FND_API.G_MISS_NUM, Commented initialization for bug fix 2916848
                p_payroll_start_date  IN  DATE,	--   := FND_API.G_MISS_DATE, Commented initialization for bug fix 2916848
                p_daily_rate          IN  NUMBER,	-- := FND_API.G_MISS_NUM, Commented initialization for bug fix 2916848
                p_effective_date      IN  DATE,	--   := FND_API.G_MISS_DATE, Commented initialization for bug fix 2916848
                p_mode                IN  VARCHAR2 := 'I',
		p_business_group_id   IN  NUMBER,
                p_set_of_books_id     IN  NUMBER,
		p_attribute_category	IN	VARCHAR2 default null,		-- Introduced DFF parameters for bug fix 2908859
		p_attribute1		IN	VARCHAR2 default null,
		p_attribute2		IN	VARCHAR2 default null,
		p_attribute3		IN	VARCHAR2 default null,
		p_attribute4		IN	VARCHAR2 default null,
		p_attribute5		IN	VARCHAR2 default null,
		p_attribute6		IN	VARCHAR2 default null,
		p_attribute7		IN	VARCHAR2 default null,
		p_attribute8		IN	VARCHAR2 default null,
		p_attribute9		IN	VARCHAR2 default null,
		p_attribute10		IN	VARCHAR2 default null,
		p_or_gl_ccid		IN	NUMBER DEFAULT NULL,
		p_or_project_id		IN	NUMBER DEFAULT NULL,
		p_or_task_id		IN	NUMBER DEFAULT NULL,
		p_or_award_id		IN	NUMBER DEFAULT NULL,
		p_or_expenditure_org_id	IN	NUMBER DEFAULT NULL,
		p_or_expenditure_type	IN	VARCHAR2 DEFAULT NULL,
                p_return_status       OUT NOCOPY VARCHAR2) IS

   -- variables for 3813688
   l_payroll_control_id integer;

    cursor get_control_id is
    select ppl.payroll_control_id
      from psp_payroll_lines ppl,
           psp_payroll_sub_lines ppsl
     where ppl.payroll_line_id = ppsl.payroll_line_id
       and ppsl.payroll_sub_line_id = g_sub_line_id;

  l_proc_executed  varchar2(10);
  l_org_def_labor_schedule   VARCHAR2(3)  := psp_general.get_specific_profile('PSP_DEFAULT_SCHEDULE');
  l_org_def_account          VARCHAR2(3)  := psp_general.get_specific_profile('PSP_DEFAULT_ACCOUNT');
  l_return_status            VARCHAR2(1);


x_proc_executed		VARCHAR2(10) := 'TRUE';
l_linkage_status	VARCHAR2(50);
l_patc_status		VARCHAR2(50);
l_billable_flag		VARCHAR2(1);
l_msg_count		NUMBER;
l_msg_app		VARCHAR2(2000);
l_msg_type		VARCHAR2(2000);
l_msg_token1		VARCHAR2(2000);
l_msg_token2		VARCHAR2(2000);
l_msg_token3		VARCHAR2(2000);
l_award_status		VARCHAR2(200);

 --- new procedure for PSB array bug 3813688
procedure create_master_lines( p_assignment_id in integer,
                              p_daily_rate in number,
                              p_payroll_start_date in date,
                              p_business_group_id in integer,
                              p_set_of_books_id in integer,
                              p_element_type_id in integer) is
   l_line_id integer;
   l_control_id integer;
   --- introduced for 5080403
  cursor autopop_config_cur is
  select pcv_information1 global_element_autopop,
         pcv_information2 element_type_autopop,
         pcv_information3 element_class_autopop,
         pcv_information4 assignment_autopop,
         pcv_information5 default_schedule_autopop,
         pcv_information6 default_account_autopop,
         pcv_information7 suspense_account,
         pcv_information10 excess_account
    from pqp_configuration_values
   where pcv_information_category = 'PSP_ENABLE_AUTOPOPULATION'
     and legislation_code is null
     and nvl(business_group_id, p_business_group_id) = p_business_group_id;

begin

savepoint psp_create_pay_paysub_lines;   --- 4639139
   open autopop_config_cur;
   fetch autopop_config_cur into g_global_element_autopop,
                                 g_asg_element_autopop,
                                 g_asg_ele_group_autopop,
                                 g_asg_autopop,
                                 g_org_schedule_autopop,
                                 g_default_account_autopop,
                                 g_suspense_account_autopop,
                                 g_excess_account_autopop;
   close autopop_config_cur;

-- dbms_output.put_line('Entered create master');
 select psp_payroll_lines_s.nextval,
        psp_payroll_sub_lines_s.nextval,
        psp_payroll_controls_s.nextval
   into l_line_id,
        g_sub_line_id,
        l_control_id
   from dual;

 insert into psp_payroll_lines
   (payroll_line_id,
    set_of_books_id,
    assignment_id,
    person_id,
    element_type_id,
    pay_amount,
    status_code,
    payroll_control_id,
    dr_cr_flag,
    last_update_date,
    last_updated_by,
    last_update_login,
    created_by,
    creation_date,
    effective_date)
  select l_line_id,
    p_set_of_books_id,
    p_assignment_id,
    person_id,
    p_element_type_id,
    p_daily_rate,
    'N',
    l_control_id,
    'D',
    sysdate,
    0,
    0,
    0,
    sysdate,
    sysdate
  from per_all_assignments_f
  where assignment_id = p_assignment_id
    and assignment_type = 'E'
    and rownum = 1;

-- dbms_output.put_line('Create master payroll_line rowcount='||sql%rowcount);
 insert into psp_payroll_sub_lines
    (payroll_sub_line_id,
     sub_line_start_date,
     sub_line_end_date,
     pay_amount,
     daily_rate,
     salary_used,
    last_update_date,
    last_updated_by,
    last_update_login,
    created_by,
    creation_date,
    payroll_line_id)
  values ( g_sub_line_id,
           p_payroll_start_date,
           p_payroll_start_date,
           p_daily_rate,
           p_daily_rate,
           0,
           sysdate,
           0,
           0,
           0,
           sysdate,
           l_line_id);

-- dbms_output.put_line('Create master payroll sub line rowcount='||sql%rowcount);
-- dbms_output.put_line('Create master payroll sub line id='||g_sub_line_id);
end create_master_lines;

 --- new procedure for PSB array bug 3813688
procedure fill_psb_array(p_payroll_sub_line_id in integer) is
cursor get_ci_percents (p_payroll_sub_line_id in integer) is
select  pdl.distribution_amount Amount,
	nvl(poa2.start_date_active, nvl(psl.schedule_begin_date, nvl(poa.start_date_active,
            nvl(peta.start_date_active, pdls.schedule_begin_date)))) start_date,
	nvl(poa2.end_date_active, nvl(psl.schedule_end_date, nvl(poa.end_date_active,
           nvl(peta.start_date_active, nvl(pdls.schedule_end_date, pdl.distribution_date))))) end_date,
	DECODE(pdl.gl_project_flag, 'G', DECODE(pdl.suspense_org_Account_id, NULL,
						nvl(pdl.auto_gl_code_combination_id,
						nvl(psl.gl_code_combination_id,
              					nvl(poa.gl_code_combination_id,
              					nvl(peta.gl_code_combination_id,
                  			pdls.gl_code_combination_id)))),
                                             nvl(pdl.suspense_auto_glccid, poa2.gl_code_combination_id)), --5080403
					NULL) glccid,
	DECODE(pdl.gl_project_flag, 'P', DECODE(pdl.suspense_org_account_id, NULL,
              				     	nvl(psl.project_id,
              					nvl(poa.project_id,
              					nvl(peta.project_id,
                  				pdls.project_id))),poa2.project_id),
					NULL) project_id,
	DECODE(pdl.gl_project_flag, 'P', decode(pdl.suspense_org_account_id, NULL,
              					nvl(psl.task_id,
              					nvl(poa.task_id,
              					nvl(peta.task_id,
                  				pdls.task_id))),poa2.task_id),
					NULL) task_id,
	DECODE(pdl.gl_project_flag, 'P', decode(pdl.suspense_org_account_id, NULL,
              					nvl(psl.award_id,
              					nvl(poa.award_id,
             					nvl(peta.award_id,
                  				pdls.award_id))),poa2.award_id),
					NULL) award_id,
	DECODE(pdl.gl_project_flag, 'P', decode(pdl.suspense_org_account_id, NULL,
						nvl(pdl.auto_expenditure_type,
						nvl(psl.expenditure_type,
                    				nvl(poa.expenditure_type,
                        				nvl(peta.expenditure_type,
                              			pdls.expenditure_type)))),
                                             nvl(pdl.suspense_auto_exp_type,poa2.expenditure_type)), --5080403
					NULL) expenditure_type,
	DECODE(pdl.gl_project_flag, 'P', decode(pdl.suspense_org_account_id, NULL,
              					nvl(psl.expenditure_organization_id,
              					nvl(poa.expenditure_organization_id,
              					nvl(peta.expenditure_organization_id,
                  				pdls.expenditure_organization_id))),
        poa2.expenditure_organization_id), NULL) exp_org_id
FROM	Psp_distribution_lines pdl,
	psp_payroll_sub_lines ppsl,
	psp_payroll_lines ppl,
	psp_schedule_lines psl,
	psp_organization_accounts poa,
	psp_element_type_accounts peta,
	psp_default_labor_Schedules pdls,
	psp_organization_accounts poa2
WHERE	ppsl.payroll_sub_line_id = pdl.payroll_sub_line_id
AND	ppsl.payroll_line_id 	= ppl.payroll_line_id
AND    	pdl.schedule_line_id = psl.schedule_line_id(+)
AND    	pdl.default_org_account_id = poa.organization_account_id(+)
AND    	pdl.element_account_id = peta.element_account_id(+)
AND    	pdl.org_schedule_id = pdls.org_schedule_id(+)
AND    	pdl.suspense_org_account_id = poa2.organization_account_id(+)
AND 	(pdl.reversal_entry_flag = 'N' OR pdl.reversal_entry_flag IS NULL)
AND		pdl.status_code = 'N'
AND     ppsl.payroll_sub_line_id = p_payroll_sub_line_id;
 l_description varchar2(360);
 l_return_status varchar2(10);
begin
 g_num_dist := 1;
 open get_ci_percents(p_payroll_sub_line_id);
 loop
   fetch get_ci_percents into
            g_charging_instructions(g_num_dist).percent,
            g_charging_instructions(g_num_dist).effective_start_date,
            g_charging_instructions(g_num_dist).effective_end_date,
            g_charging_instructions(g_num_dist).gl_code_combination_id,
            g_charging_instructions(g_num_dist).project_id,
            g_charging_instructions(g_num_dist).task_id,
            g_charging_instructions(g_num_dist).award_id,
            g_charging_instructions(g_num_dist).expenditure_type,
            g_charging_instructions(g_num_dist).expenditure_organization_id;
    if get_ci_percents%notfound then
       close get_ci_percents;
       g_num_dist := g_num_dist - 1;
       exit;
    end if;
  -- dbms_output.put_line(' fetching get_ci_percents');
   l_description := '';
   if (g_charging_instructions(g_num_dist).gl_code_combination_id is null) then
       get_poeta_description
              (p_project_id       => g_charging_instructions(g_num_dist).project_id,
               p_award_id         => g_charging_instructions(g_num_dist).award_id,
               p_task_id          => g_charging_instructions(g_num_dist).task_id,
               p_organization_id  => g_charging_instructions(g_num_dist).expenditure_organization_id,
               p_description      => l_description,
               p_return_status    => l_return_status);

      IF (l_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
           g_charging_instructions(g_num_dist).description    := l_description;
      end if;

   end if;
   g_num_dist := g_num_dist + 1;
 end loop;
 rollback to psp_create_pay_paysub_lines; --- 4639139
end fill_psb_array;

BEGIN
 -- dbms_output.put_line('Entered get_dist');
  -- create master records payroll line, subline  -  only for PSB, bug 3813688
  if p_mode = 'D' then
   g_gl_effective_date := p_effective_date;
   create_master_lines( p_assignment_id,
                       p_daily_rate,
                       p_payroll_start_date,
                       p_business_group_id,
                       p_set_of_books_id,
                       p_element_type_id);
  -- dbms_output.put_line('G Sub line Id '||g_sub_line_id);
  else

    -- dbms_output.put_line('CANNOT enter for PSB mode');
     g_sub_line_id := p_sub_line_id;
  end if;

  -- dbms_output.put_line('Inside hierarchy Check');
   g_num_dist := 0;
   ----g_auto_population := psp_general.get_specific_profile('PSP_USE_AUTO_POPULATION');  commented for 5080403

   if g_charging_instructions.count > 0 then
      g_charging_instructions.delete;
   end if;

  -- dbms_output.put_line('Before Global Earnings ');
  -- dbms_output.put_line('Person id '||p_person_id);
  -- dbms_output.put_line('Sub line Id '||p_sub_line_id);
  -- dbms_output.put_line('Assignment id '||p_assignment_id);
  -- dbms_output.put_line(' Element type id '||p_element_type_id);
  -- dbms_output.put_line('Payroll STart date '||p_payroll_start_date);




IF (p_or_gl_ccid IS NOT NULL) THEN
		insert_into_distribution_lines
			(P_SUB_LINE_ID,
			P_PAYROLL_START_DATE,
			g_gl_EFFECTIVE_DATE,
			ROUND(p_daily_rate, g_precision),
			'N',
			NULL,
			NULL,
			NULL,
			NULL,
			NULL,
			NULL,
			NULL,
			'G',
			NULL,
			p_or_gl_ccid,
			NULL,
			NULL,
			NULL,
			NULL,
			NULL,
			NULL,
			NULL,
			p_mode,
			p_business_group_id,
			p_set_of_books_id,
			p_attribute_category,
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
			l_return_status,
			p_or_gl_ccid,
			NULL,
			NULL,
			NULL,
			NULL,
			NULL);

		IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;
	ELSIF (p_or_project_id IS NOT NULL) THEN
		pa_transactions_pub.validate_transaction
			(x_project_id		=> p_or_project_id,
			x_task_id		=> p_or_task_id,
			x_ei_date		=> p_effective_date,
			x_expenditure_type	=> p_or_expenditure_type,
			x_non_labor_resource	=> NULL,
			x_person_id		=> p_person_id,
			x_incurred_by_org_id	=> p_or_expenditure_org_id,
			x_calling_module	=> 'PSPLDCDB',
			x_msg_application	=> l_msg_app,
			x_msg_type		=> l_msg_type,
			x_msg_token1		=> l_msg_token1,
			x_msg_token2		=> l_msg_token2,
			x_msg_token3		=> l_msg_token3,
			x_msg_count		=> l_msg_count,
			x_msg_data		=> l_patc_status,
			x_billable_flag		=> l_billable_flag,
			p_sys_link_function	=> 'ST');

		IF ((p_or_award_id IS NOT NULL) AND (l_patc_status IS NULL)) THEN
			gms_transactions_pub.validate_transaction
				(p_or_project_id,
				p_or_task_id,
				p_or_award_id,
				p_or_expenditure_type,
				p_effective_date,
				'PSPLDCDB',
				l_award_status);

			IF l_award_status IS NOT NULL THEN
				l_patc_status := substr(l_award_status,1,50);
			END IF;
		END IF;

		IF ((l_patc_status IS NOT NULL ) OR (l_award_status IS NOT NULL)) THEN
			suspense_account(x_proc_executed,
				p_person_id,
				p_sub_line_id,
				p_assignment_id,
				p_payroll_start_date,
				ROUND(p_daily_rate, g_precision),
				l_patc_status,
				NULL,
				NULL,
				NULL,
				NULL,
				p_effective_date,
				p_mode,
				p_business_group_id,
				p_set_of_books_id,
				NULL,
				l_return_status);

			IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
				RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
			END IF;
		ELSIF ((l_patc_status IS NULL) OR (l_award_status IS NULL)) THEN
			insert_into_distribution_lines
				(P_SUB_LINE_ID,
				P_PAYROLL_START_DATE,
				P_EFFECTIVE_DATE,
				ROUND(p_daily_rate, g_precision),
				'N',
				NULL,
				NULL,
				NULL,
				NULL,
				NULL,
				NULL,
				NULL,
				'P',
				NULL,
				NULL,
				p_or_project_id,
				p_or_task_id	,
				p_or_award_id ,
				p_or_expenditure_org_id,
				p_or_expenditure_type,
				NULL,
				NULL,
				p_mode,
				p_business_group_id,
				p_set_of_books_id,
				p_attribute_category,
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
				l_return_status,
				NULL,
				p_or_project_id,
				p_or_task_id,
				p_or_award_id,
				p_or_expenditure_org_id,
				p_or_expenditure_type);

			IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
				RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
			END IF;
		END IF;
	ELSE	--	else part of EE overrides
  -- Search for the global earnings element


         global_earnings_element(
                                 l_proc_executed,
                                 p_person_id,
                                 g_sub_line_id,
                                 p_assignment_id,
                                 p_element_type_id,
                                 p_payroll_start_date,
                                 p_daily_rate,
                                 l_org_def_account,
                                 p_effective_date,
                                 p_mode,
				 p_business_group_id,
                                 p_set_of_books_id,
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
                                 l_return_status);

       -- dbms_output.put_line('Output of global earnings = '||l_proc_executed);

         IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           -- dbms_output.put_line('G_Error '||g_error_api_path);
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;

        ---5090002 retro parent element.
        if g_retro_parent_element_id is not null
          and l_proc_executed = 'FALSE' then
                global_earnings_element(l_proc_executed,
                                        p_person_id,
                                        g_sub_line_id,
                                        p_assignment_id,
                                        g_retro_parent_element_id,
                                        p_payroll_start_date,
                                        p_daily_rate,
                                        l_org_def_account,
                                        p_effective_date,
                                        p_mode,
                                        p_business_group_id,
                                        p_set_of_books_id,
                                        p_attribute_category,
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
                                        l_return_status);
           if l_return_status <> fnd_api.g_ret_sts_success then
              raise fnd_api.g_exc_unexpected_error;
           end if;
        end if;

      -- dbms_output.put_line('Before Element Earnings ');
         IF l_proc_executed = 'FALSE' THEN
         -- Search for the assignment's element type in psp_schedule_lines

           element_type_hierarchy(
                                 l_proc_executed,
                                 p_person_id,
                                 g_sub_line_id,
                                 p_assignment_id,
                                 p_element_type_id,
                                 p_payroll_start_date,
                                 p_daily_rate,
                                 l_org_def_account,
                                 p_effective_date,
                                 p_mode,
				 p_business_group_id,
                                 p_set_of_books_id,
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
                                 l_return_status);

      -- dbms_output.put_line('Output of element hierarchy = '||l_proc_executed);
           IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;
        ---5090002 retro parent element.
        if g_retro_parent_element_id is not null
          and l_proc_executed = 'FALSE' then
      hr_utility.trace('Before calling element_type hierarchy-100 parent element id = '||g_retro_parent_element_id);
           element_type_hierarchy(
                                 l_proc_executed,
                                 p_person_id,
                                 g_sub_line_id,
                                 p_assignment_id,
                                 g_retro_parent_element_id,
                                 p_payroll_start_date,
                                 p_daily_rate,
                                 l_org_def_account,
                                 p_effective_date,
                                 p_mode,
                                 p_business_group_id,
                                 p_set_of_books_id,
                                 p_attribute_category,
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
                                 l_return_status);
           if l_return_status <> fnd_api.g_ret_sts_success then
              raise fnd_api.g_exc_unexpected_error;
           end if;
        end if;


      -- dbms_output.put_line('Before Element Class ');
           IF l_proc_executed = 'FALSE' THEN
             element_class_hierarchy(
                                 l_proc_executed,
                                 p_person_id,
                                 g_sub_line_id,
                                 p_assignment_id,
                                 p_element_type_id,
                                 p_payroll_start_date,
                                 p_daily_rate,
                                 l_org_def_account,
                                 p_effective_date,
                                 p_mode,
				 p_business_group_id,
                                 p_set_of_books_id,
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
                                 l_return_status);

      -- dbms_output.put_line('Output of element class hierarchy = '||l_proc_executed);
             IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
             END IF;
        ---5090002 retro parent element.
        if  g_retro_parent_element_id is not null
          and l_proc_executed = 'FALSE' then
             element_class_hierarchy(
                                 l_proc_executed,
                                 p_person_id,
                                 g_sub_line_id,
                                 p_assignment_id,
                                 g_retro_parent_element_id,
                                 p_payroll_start_date,
                                 p_daily_rate,
                                 l_org_def_account,
                                 p_effective_date,
                                 p_mode,
                                 p_business_group_id,
                                 p_set_of_books_id,
                                 p_attribute_category,
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
                                l_return_status);
           if l_return_status <> fnd_api.g_ret_sts_success then
              raise fnd_api.g_exc_unexpected_error;
           end if;
        end if;


             IF l_proc_executed = 'FALSE' THEN

      -- dbms_output.put_line('Before Assignment g_sub_line_id   = '||g_sub_line_id   );
               assignment_hierarchy(
                                 l_proc_executed,
                                 p_person_id,
                                 g_sub_line_id,
                                 p_assignment_id,
                                 p_element_type_id,
                                 p_payroll_start_date,
                                 p_daily_rate,
                                 l_org_def_account,
                                 p_effective_date,
                                 p_mode,
				 p_business_group_id,
                                 p_set_of_books_id,
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
                                 l_return_status);

         -- dbms_output.put_line('The output of assignment hierarchy = '||l_proc_executed);

               IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
               END IF;


               IF l_proc_executed = 'FALSE' THEN
                 IF l_org_def_labor_schedule = 'Y' THEN
                   org_labor_schedule_hierarchy(
                                         l_proc_executed,
                                         p_person_id,
                                         g_sub_line_id,
                                         p_assignment_id,
                                         p_element_type_id,
                                         p_payroll_start_date,
                                         p_daily_rate,
                                         l_org_def_account,
                                         p_effective_date,
                                         p_mode,
				 	p_business_group_id,
                                 	p_set_of_books_id,
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
                                         l_return_status);
                 END IF;

         -- dbms_output.put_line('The output of org labor = '||l_proc_executed);

                 IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                 END IF;

                 IF l_proc_executed = 'FALSE' THEN
                   IF l_org_def_account = 'Y' THEN
                     default_account(
                           l_proc_executed,
                           p_person_id,
                           g_sub_line_id,
                           p_assignment_id,
                           p_payroll_start_date,
                           p_daily_rate,
                           '3',    ---'LDM_NO_CI_FOUND',
                           p_effective_date,
                           p_mode,
			   p_business_group_id,
                           p_set_of_books_id,
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
                           l_return_status);

                    END IF;

    -- dbms_output.put_line('The output of default account = '||l_proc_executed);
                   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                   END IF;

                   IF l_proc_executed = 'FALSE' THEN
                      suspense_account (
                             l_proc_executed,
                             p_person_id,
                             g_sub_line_id,
                             p_assignment_id,
                             p_payroll_start_date,
                             p_daily_rate,
                             'LDM_NO_CI_FOUND',
                             NULL,
                             NULL,
                             NULL,
                             NULL,
                             p_effective_date,
                             p_mode,
			     p_business_group_id,
                             p_set_of_books_id,
                             NULL,   ---    for autopop perf. patch
                             l_return_status);

                      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                      END IF;

                    END IF; -- suspense account
                  END IF;   -- default account
                END IF;     -- default org labor schedule
              END IF;       -- assignment class
            END IF;         -- element group
          END IF;           -- element type
      END IF;			-- Global Element Introduced for Element Entry Overrides


if p_mode = 'D' then   --- introduced for 3813688
  ---g_auto_population := FND_PROFILE.value('PSP_USE_AUTO_POPULATION');
    open get_control_id;
    fetch get_control_id into l_payroll_control_id;
    close get_control_id;

    --#fnd_file.put_line(fnd_file.log,'autopop is ON and control_id ='||l_payroll_control_id);
    if g_asg_autopop = 'Y' or g_asg_element_autopop = 'Y' or g_asg_ele_group_autopop = 'Y' then
    update_dist_schedule_autopop(p_payroll_control_id =>l_payroll_control_id,
                                 p_business_group_id=>p_business_group_id,
                                 p_set_of_books_id=>p_Set_of_books_id,
                                 p_start_asg_id=>p_assignment_id,
                                 p_end_asg_id=>p_assignment_id,
                                 p_return_Status =>l_return_status);
    end if;

    if l_org_def_labor_schedule = 'Y'  and g_org_schedule_autopop = 'Y' THEN
             update_dist_odls_autopop(p_payroll_control_id => l_payroll_control_id,
                                      p_business_group_id=> p_business_group_id,
                                      p_set_of_books_id => p_set_of_books_id,
                                      p_start_asg_id=> p_assignment_id,
                                      p_end_asg_id=> p_assignment_id,
                                      p_return_status => l_return_status);
    end if;
          --- autopop calls for global element, default account, suspense account .. 5080403
          if g_global_element_autopop = 'Y' then
               generic_account_autopop( l_payroll_control_id,
                                       p_business_group_id,
                                       p_set_of_books_id,
                                       p_assignment_id,
                                       p_assignment_id,
                                       'GLOBAL_ELEMENT');
          end if;
          if g_default_account_autopop = 'Y' and l_org_def_account = 'Y' then
               generic_account_autopop( l_payroll_control_id,
                                       p_business_group_id,
                                       p_set_of_books_id,
                                       p_assignment_id,
                                       p_assignment_id,
                                       'DEFAULT_ACCOUNT');
          end if;
          if g_suspense_account_autopop = 'Y' then
               generic_account_autopop( l_payroll_control_id,
                                       p_business_group_id,
                                       p_set_of_books_id,
                                       p_assignment_id,
                                       p_assignment_id,
                                       'SUSPENSE');
          end if;
 -- dbms_output.put_line(' before call to fill_psb_array g_sub_line_id = ' || g_sub_line_id);
  fill_psb_array(g_sub_line_id);
end if;

   p_return_status := FND_API.G_RET_STS_SUCCESS;

  EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
    -- dbms_output.put_line('error occured d = 1');
      g_error_api_path := SUBSTR('GET DISTRIBUTION LINES:'||g_error_api_path,1,230);
      p_return_status := FND_API.G_RET_STS_ERROR;


   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    -- dbms_output.put_line('error occured d ='||sqlerrm);
    -- dbms_output.put_line('error occured d = 2');
      g_error_api_path := SUBSTR('GET_DISTRIBUTION LINES :'||g_error_api_path,1,230);
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   WHEN OTHERS THEN
    -- dbms_output.put_line('error occured d ='||sqlerrm);
      g_error_api_path := SUBSTR('GET_DISTRIBUTION LINES:'||g_error_api_path,1,230);

      /*if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then

       FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
                                l_api_name);
      end if; */

     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

end Get_Distribution_Lines;



PROCEDURE update_dist_schedule_autopop(p_payroll_control_id IN NUMBER,
                         p_business_group_id IN NUMBER,
                         p_set_of_books_id IN NUMBER,
                         p_start_asg_id in integer,
                         p_end_asg_id   in integer,
                                       p_return_status OUT NOCOPY VARCHAR2)  IS

CURSOR autopop_exc_cur(P_PAYROLL_CONTROL_ID  IN  NUMBER) IS
  SELECT pdl.payroll_sub_line_id ,
         max(pdl.distribution_date) max_dist_date,  --5592789
         max(pdl.effective_date) effective_date,
         ppl.person_id,
         ppl.assignment_id,
         ppl.element_type_id,
psl.project_id,
psl.expenditure_organization_id,
psl.expenditure_type,
psl.task_id,
psl.award_id,
psl.gl_code_combination_id,
pdl.schedule_line_id schedule_line_id,
ppl.cost_id,
ppl.payroll_action_type
  FROM   psp_distribution_lines pdl,
         psp_payroll_lines ppl,
         psp_payroll_sub_lines ppsl,
         psp_Schedule_lines psl,
         psp_schedule_hierarchy psh
  WHERE
     ppl.payroll_control_id = p_payroll_control_id
  AND    ppl.payroll_line_id = ppsl.payroll_line_id
and ppsl.payroll_sub_line_id=pdl.payroll_sub_line_id
  and pdl.suspense_org_account_id is null
 and pdl.schedule_line_id=psl.schedule_line_id
 and ppl.assignment_id between p_start_asg_id and p_end_asg_id
 and psh.schedule_hierarchy_id = psl.schedule_hierarchy_id
 and psh.scheduling_types_code in (decode(g_asg_autopop,'Y','A') ,
                                   decode(g_asg_element_autopop,'Y','ET'),
                                   decode(g_asg_ele_group_autopop,'Y','EG'))
  and pdl.adj_account_flag is null
group by
ppl.cost_id,
ppl.payroll_action_type,
pdl.payroll_Sub_line_id,
ppl.person_id,
ppl.assignment_id,
ppl.element_type_id ,
psl.PROJECT_ID ,
psl.EXPENDITURE_ORGANIZATION_ID,
psl.EXPENDITURE_TYPE,
psl.TASK_ID,
psl.AWARD_ID,
psl.gl_code_combination_id,
pdl.schedule_line_id;


autopop_exc_rec autopop_exc_cur%ROWTYPE;

 CURSOR dist_line_psl_cur(p_payroll_sub_line_id in number , p_schedule_line_id in number ) is
select distribution_line_id , effective_date, distribution_amount from psp_distribution_lines pdl
where payroll_sub_line_id= p_payroll_sub_line_id and
      schedule_line_id= p_schedule_line_id
      and suspense_org_account_id is null
order by effective_date;

  l_dist_amount                  NUMBER:=0;
  l_acct_type                   VARCHAR2(1);
l_auto_pop_status		         VARCHAR2(1);
 l_new_expenditure_type         VARCHAR2(30);
 l_new_gl_code_combination_id                  NUMBER(15);
l_auto_status                    VARCHAR2(20) := null;
 l_dist_line_id                 NUMBER(9);
  l_linkage_status                 VARCHAR2(50);
  l_patc_status                    VARCHAR2(50);
  x_proc_executed                  VARCHAR2(10) := 'TRUE';
  l_billable_flag                  VARCHAR2(1);
 l_mode                         VARCHAR2(1) := 'I';
l_effective_date                DATE;
  l_return_status            VARCHAR2(1);
l_dbg_ctr number :=0;
  l_msg_count                      NUMBER;
  l_msg_app                        VARCHAR2(2000);
  l_msg_type                       varchar2(2000);
  l_msg_token1                     varchar2(2000);
  l_msg_token2                     varchar2(2000);
  l_msg_token3                     varchar2(2000);
  --l_award_status  varchar2(50);  -- for bug fix 1931680
  l_award_status  varchar2(200);
  ---
   l_prev_cost_id                   integer;

begin

open autopop_exc_cur(p_payroll_control_id);
loop
 fetch autopop_exc_cur into autopop_exc_rec;
 if autopop_exc_cur%notfound then exit;
 end if;
 if nvl(autopop_exc_rec.payroll_action_type,'X') = 'L' then --- 5090002
   if nvl(l_prev_cost_id, -999) <> autopop_exc_rec.cost_id then
       l_prev_cost_id :=  autopop_exc_rec.cost_id;
       g_retro_parent_element_id := nvl(get_retro_parent_element_id(autopop_exc_rec.cost_id), autopop_exc_rec.element_type_id);
   end if;
       autopop_exc_rec.element_type_id := g_retro_parent_element_id;
  hr_utility.trace(' 201 Parent element id = '||autopop_exc_rec.element_type_id);
 end if;
    --#fnd_file.put_line(fnd_file.log,'autopop for sched lines  exp type, glccid, psob, pbg  ='|| autopop_exc_rec.expenditure_type||','||autopop_exc_rec.gl_code_combination_id||','|| p_set_of_books_id||','||p_business_group_id);
if autopop_exc_rec.gl_code_combination_id is null then
    l_acct_type:='E';
else
  l_acct_type:='N';
end if;
if nvl(g_use_eff_date,'N') = 'Y' then    --- added if condn for 5505041
   null;
else
   autopop_exc_rec.effective_date := autopop_exc_rec.max_dist_date;
end if;

/*
   l_dbg_ctr:=l_dbg_ctr+1;
   insert into psp_stout values(l_dbg_ctr, 'inside schedule lines');
*/

     psp_autopop.main(
                    p_acct_type                   => l_acct_type,
		    p_person_id                   => autopop_exc_rec.person_id,
	            p_assignment_id               => autopop_exc_rec.assignment_id,
		    p_element_type_id             => autopop_exc_rec.element_type_id,
		    p_project_id                  => autopop_exc_rec.project_id,
		    p_expenditure_organization_id => autopop_exc_rec.expenditure_organization_id,
		    p_task_id                     => autopop_exc_rec.task_id,
		    p_award_id                    => autopop_exc_rec.award_id,
                    p_expenditure_type            => autopop_exc_rec.expenditure_type,
		    p_gl_code_combination_id      => autopop_exc_rec.gl_code_combination_id,
		    p_payroll_date                => autopop_exc_rec.effective_date,
		    p_set_of_books_id             => p_set_of_books_id,
                    p_business_group_id           => p_business_group_id,
		    ret_expenditure_type          => l_new_expenditure_type,
		    ret_gl_code_combination_id    => l_new_gl_code_combination_id,
		    retcode 			  => l_auto_pop_status);

    --#fnd_file.put_line(fnd_file.log,'autopop status='|| l_auto_pop_status);
--insert into psp_stout values(1, 'after autopop call');

     IF (l_auto_pop_status = FND_API.G_RET_STS_UNEXP_ERROR) OR
       (l_auto_pop_status = FND_API.G_RET_STS_ERROR) THEN
         --dbms_output.put_line('autopop returned an error ');
       IF l_auto_pop_status = FND_API.G_RET_STS_UNEXP_ERROR THEN

         if l_acct_type ='N'  then
              l_auto_status := 'AUTO_POP_NA_ERROR';
         else
-- new code for expenditure type error as part of autopop performance patch
              l_auto_status :='AUTO_POP_EXP_ERROR';
         end if;

       ELSIF l_auto_pop_status = FND_API.G_RET_STS_ERROR THEN
         l_auto_status := 'AUTO_POP_NO_VALUE';
       END IF;

    open dist_line_psl_cur(autopop_exc_rec.payroll_sub_line_id, autopop_exc_rec.schedule_line_id);

 loop
   fetch dist_line_psl_cur into l_dist_line_id , l_effective_date, l_dist_amount;

      if dist_line_psl_cur%notfound then exit;
         else

                suspense_account(
                         x_proc_executed,
                         autopop_exc_rec.person_id,
                         autopop_exc_rec.payroll_sub_line_id,
                         autopop_exc_rec.assignment_id,
                       --l  p_payroll_start_date,loop thru for each day
                         l_effective_date,
                         l_dist_amount, -- will be distribution_amount
                         l_auto_status,
                         NULL,
                         NULL,
                         NULL,
                         NULL,
                         l_effective_date,
                         l_mode,
          --               l_dist_line_id,   bug fix  2126171
                         p_business_group_id,
                         p_set_of_books_id,
                         l_dist_line_id,
                         l_return_status
                          );
       end if;
  end loop;
      --dbms_output.put_line('after inserting into suspense account');
   close dist_line_psl_cur;

else   --- autopop is successful
    if l_acct_type= 'E' then
       --dbms_output.put_line(' For expenditure type ');
            open dist_line_psl_cur(autopop_exc_rec.payroll_sub_line_id,autopop_exc_rec.schedule_line_id);

    loop
          fetch dist_line_psl_cur into l_dist_line_id , l_effective_date, l_dist_amount;

               if dist_line_psl_cur%notfound then exit;
                     else

	    pa_transactions_pub.validate_transaction(
			x_project_id		=> autopop_exc_rec.project_id,
			x_task_id		=> autopop_exc_rec.task_id,
			x_ei_date		=> l_effective_date,
			x_expenditure_type	=> l_new_expenditure_type,   --- changed from old exp type.. for 5080403
			x_non_labor_resource	=> null,
			x_person_id		=> autopop_exc_rec.person_id,
			x_incurred_by_org_id	=> autopop_exc_rec.expenditure_organization_id,
			x_calling_module	=> 'PSPLDCDB',
			x_msg_application	=> l_msg_app,
			x_msg_type		=> l_msg_type,
			x_msg_token1		=> l_msg_token1,
			x_msg_token2		=> l_msg_token2,
			x_msg_token3		=> l_msg_token3,
			x_msg_count		=> l_msg_count,
			x_msg_data		=> l_patc_status,
			x_billable_flag		=> l_billable_flag,
			p_sys_link_function     => 'ST');            --Bug 5639589: Added parameter


	   -- dbms_output.put_line('patc stat 1 '|| l_patc_status);

	     -- GMS is enabled, PATC validation went fine
	     if autopop_exc_rec.award_id is not null and l_patc_status is null
	     then
		 gms_transactions_pub.validate_transaction
				(autopop_exc_rec.project_id,
			   	autopop_exc_rec.task_id,
				autopop_exc_rec.award_id,
			   	l_new_expenditure_type,
				l_effective_date, ---p_payroll_start_date, Bug 1874696
				'PSPLDCDB',
				l_award_status);

/********************************************************************
		 if l_award_status is null
		 then
 			project_award_linkage(autopop_exc_rec.project_id,
                                  autopop_exc_rec.award_id,
                                  l_linkage_status,
                                  l_return_status);
		else
*****************************************************************************/

                if l_award_status IS NOT NULL then
		--	l_patc_status := l_award_status;  for bug fix 1931680
                        l_patc_status  := substr(l_award_status,1,50);
	        end if;
	     end if;
             IF ( l_patc_status IS NOT NULL ) OR
--- ( l_linkage_status IS NOT NULL ) OR
		(l_award_status is not null ) THEN


/*

    open dist_line_psl_cur;

 loop
   fetch dist_line_psl_cur into l_dist_line_id , l_effective_date, l_dist_amount;

      if dist_line_psl_cur%notfound then exit;
         else


*/
 -- added following update for 5080403
 update psp_distribution_lines  set auto_expenditure_type  = l_new_expenditure_type
 where distribution_line_id=l_dist_line_id;
                suspense_account(
                         x_proc_executed,
                         autopop_exc_rec.person_id,
                         autopop_exc_rec.payroll_sub_line_id,
                         autopop_exc_rec.assignment_id,
                         l_effective_date,
                         l_dist_amount,
                         l_patc_status,
                         NULL,
                         NULL,
                         NULL,
                         NULL,
                         l_effective_date,
                         l_mode,
                  --       l_dist_line_id,   bug fix 2126171
                         p_business_group_id,
                         p_set_of_books_id,
                         l_dist_line_id,
                         l_return_status);

                 IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                 END IF;

--   end if;
--  end loop;
--   close dist_line_psl_cur;

else  -- linkage status is successful

  --dbms_output.put_line(' linkage status is successful');

 update psp_distribution_lines  set auto_expenditure_type  = l_new_expenditure_type
 where
distribution_line_id=l_dist_line_id;
 --- check the above that  it is necessary and sufficient
-- commit; ---- after -- to debug -- will be removed later

   end if;   -- patc status
  end if ;  -- dist_line_csr not found;
end loop;
close dist_line_psl_cur;

   else   --  if natural account then


  ---dbms_output.put_line(' oops --  this  is natural account');

 update psp_distribution_lines  set auto_gl_code_combination_id  = l_new_gl_code_combination_id
 where
payroll_sub_line_id=autopop_exc_rec.payroll_sub_line_id
and schedule_line_id =
autopop_exc_rec.schedule_line_id  and suspense_org_account_id is null;

 end if; -- end natural account
 end if;  -- end of autopop successful

 end loop;
  close autopop_exc_cur;

end;

PROCEDURE update_dist_odls_autopop(p_payroll_control_id IN NUMBER,
                                   p_business_group_id IN NUMBER,
                                   p_Set_of_books_id IN NUMBER,
                                   p_start_asg_id in integer,
                                   p_end_asg_id   in integer,
                                   p_return_status OUT NOCOPY VARCHAR2) IS

CURSOR autopop_odls_cur(p_payroll_control_id in number) is
  SELECT pdl.payroll_sub_line_id ,
         max(pdl.distribution_date) max_dist_date,
         max(pdl.effective_date) effective_date,
         ppl.person_id,
         ppl.assignment_id,
         ppl.element_type_id
,
   pdls.project_id,
    pdls.expenditure_organization_id,
    pdls.expenditure_type,
    pdls.task_id,
    pdls.award_id,
    pdls.gl_code_combination_id,
    pdls.org_schedule_id,
    ppl.cost_id,
    ppl.payroll_action_type
  FROM   psp_distribution_lines pdl,
         psp_payroll_lines ppl,
         psp_payroll_sub_lines ppsl,
         psp_default_labor_schedules pdls
  WHERE
     ppl.payroll_control_id = p_payroll_control_id
 and ppl.assignment_id between p_start_asg_id and p_end_asg_id
  AND    ppl.payroll_line_id = ppsl.payroll_line_id
and ppsl.payroll_sub_line_id=pdl.payroll_sub_line_id
  and pdl.suspense_org_account_id is null and
   pdl.org_schedule_id= pdls.org_schedule_id
  and pdl.adj_account_flag is null
group by
ppl.cost_id,
ppl.payroll_action_type,
pdl.payroll_Sub_line_id,
ppl.person_id,
ppl.assignment_id,
ppl.element_type_id ,
pdls.PROJECT_ID,
pdls.EXPENDITURE_ORGANIZATION_ID,
pdls.EXPENDITURE_TYPE,
pdls.TASK_ID,
pdls.AWARD_ID,
pdls.gl_code_combination_id,
pdls.org_schedule_id;


autopop_odls_rec autopop_odls_cur%ROWTYPE;

  CURSOR dist_line_odls_cur(p_payroll_sub_line_id in number  ,p_org_schedule_id in number) is
select distribution_line_id , effective_date, distribution_amount from psp_distribution_lines pdl
where payroll_sub_line_id= autopop_odls_rec.payroll_sub_line_id and
      org_schedule_id= autopop_odls_rec.org_schedule_id
      and suspense_org_account_id is null
order by effective_date;

  l_dist_amount                  NUMBER:=0;
  l_acct_type                   VARCHAR2(1);
l_auto_pop_status		         VARCHAR2(1);
 l_new_expenditure_type         VARCHAR2(30);
 l_new_gl_code_combination_id                  NUMBER(15);
l_auto_status                    VARCHAR2(20) := null;
 l_dist_line_id                 NUMBER(9);
  l_linkage_status                 VARCHAR2(50);
  l_patc_status                    VARCHAR2(50);
  x_proc_executed                  VARCHAR2(10) := 'TRUE';
 l_mode                         VARCHAR2(1) := 'I';
 l_effective_date               DATE;
  l_return_status            VARCHAR2(1);
   l_dbg_ctr                number :=0;
  l_billable_flag                  VARCHAR2(1)  := NULL;
  l_msg_count                      NUMBER;
  l_msg_app                        VARCHAR2(2000);
  l_msg_type                       varchar2(2000);
  l_msg_token1                     varchar2(2000);
  l_msg_token2                     varchar2(2000);
  l_msg_token3                     varchar2(2000);
  l_award_status  varchar2(200);
  ---
   l_prev_cost_id    integer;
begin

open autopop_odls_cur(p_payroll_control_id);
loop
 fetch autopop_odls_cur into autopop_odls_rec;
 if autopop_odls_cur%notfound then exit;
 end if;
 if nvl(autopop_odls_rec.payroll_action_type,'X') = 'L' then --- 5090002
   if nvl(l_prev_cost_id, -999) <> autopop_odls_rec.cost_id then
       l_prev_cost_id :=  autopop_odls_rec.cost_id;
       g_retro_parent_element_id := nvl(get_retro_parent_element_id(autopop_odls_rec.cost_id), autopop_odls_rec.element_type_id);
   end if;
       autopop_odls_rec.element_type_id := g_retro_parent_element_id;
 end if;

if autopop_odls_rec.gl_code_combination_id is null then
    l_acct_type:='E';
else
  l_acct_type:='N';
end if;
if nvl(g_use_eff_date,'N') = 'Y' then    --- added if condn for 5505041
   null;
else
   autopop_odls_rec.effective_date := autopop_odls_rec.max_dist_date;
end if;

/*

l_dbg_ctr:=l_dbg_ctr+1;
insert into psp_stout values(l_dbg_ctr,'inside odls');
*/

     psp_autopop.main(
                    p_acct_type                   => l_acct_type,
		    p_person_id                   => autopop_odls_rec.person_id,
	            p_assignment_id               => autopop_odls_rec.assignment_id,
		    p_element_type_id             => autopop_odls_rec.element_type_id,
		    p_project_id                  => autopop_odls_rec.project_id,
		    p_expenditure_organization_id => autopop_odls_rec.expenditure_organization_id,
		    p_task_id                     => autopop_odls_rec.task_id,
		    p_award_id                    => autopop_odls_rec.award_id,
                    p_expenditure_type            => autopop_odls_rec.expenditure_type,
		    p_gl_code_combination_id      => autopop_odls_rec.gl_code_combination_id,
		    p_payroll_date                => autopop_odls_rec.effective_date,
		    p_set_of_books_id             => p_set_of_books_id,
                    p_business_group_id           => p_business_group_id,
		    ret_expenditure_type          => l_new_expenditure_type,
		    ret_gl_code_combination_id    => l_new_gl_code_combination_id,
		    retcode 			  => l_auto_pop_status);

--insert into psp_stout values(1, 'after autopop call');
     IF (l_auto_pop_status = FND_API.G_RET_STS_UNEXP_ERROR) OR
       (l_auto_pop_status = FND_API.G_RET_STS_ERROR) THEN
       IF l_auto_pop_status = FND_API.G_RET_STS_UNEXP_ERROR THEN

         if l_acct_type='N' then
            l_auto_status := 'AUTO_POP_NA_ERROR';
         else
            l_auto_status :='AUTO_POP_EXP_ERROR';

-- new code for autopop error for expenditure type

         end if;

       ELSIF l_auto_pop_status = FND_API.G_RET_STS_ERROR THEN
         l_auto_status := 'AUTO_POP_NO_VALUE';
       END IF;

    open dist_line_odls_cur(autopop_odls_rec.payroll_sub_line_id, autopop_odls_rec.org_schedule_id);

 loop
   fetch dist_line_odls_cur into l_dist_line_id , l_effective_date, l_dist_amount;

      if dist_line_odls_cur%notfound then exit;
         else
 --          insert into psp_stout values(11, 'before suspense postings');
                suspense_account(
                         x_proc_executed,
                         autopop_odls_rec.person_id,
                         autopop_odls_rec.payroll_sub_line_id,
                         autopop_odls_rec.assignment_id,
                       --l  p_payroll_start_date,loop thru for each day
                         l_effective_date,
                         l_dist_amount, -- will be distribution_amount
                         l_auto_status,
                         NULL,
                         NULL,
                         NULL,
                         NULL,
                         l_effective_date,
                         l_mode,
                         p_business_group_id,
                         p_set_of_books_id,
                         l_dist_line_id,
                         l_return_status
                          );
       end if;
  end loop;
  close dist_line_odls_cur;

else   --- autopop is successful
    if l_acct_type= 'E' then

    open dist_line_odls_cur(autopop_odls_rec.payroll_sub_line_id, autopop_odls_rec.org_schedule_id);

 loop
   fetch dist_line_odls_cur into l_dist_line_id , l_effective_date, l_dist_amount;

      if dist_line_odls_cur%notfound then exit;
         else
        --   insert into psp_stout values(12, 'inside patc status ');

	    pa_transactions_pub.validate_transaction(
			x_project_id		=> autopop_odls_rec.project_id,
			x_task_id		=> autopop_odls_rec.task_id,
			x_ei_date		=> l_effective_date,
			x_expenditure_type	=> l_new_expenditure_type,
			x_non_labor_resource	=> null,
			x_person_id		=> autopop_odls_rec.person_id,
			x_incurred_by_org_id	=> autopop_odls_rec.expenditure_organization_id,
			x_calling_module	=> 'PSPLDCDB',
			x_msg_application	=> l_msg_app,
			x_msg_type		=> l_msg_type,
			x_msg_token1		=> l_msg_token1,
			x_msg_token2		=> l_msg_token2,
			x_msg_token3		=> l_msg_token3,
			x_msg_count		=> l_msg_count,
			x_msg_data		=> l_patc_status,
			x_billable_flag		=> l_billable_flag,
			p_sys_link_function     => 'ST');            --Bug 5639589: Added parameter


	   -- dbms_output.put_line('patc stat 1 '|| l_patc_status);

	     -- GMS is enabled, PATC validation went fine
	     if autopop_odls_rec.award_id is not null and l_patc_status is null
	     then
		 gms_transactions_pub.validate_transaction
				(autopop_odls_rec.project_id,
			   	autopop_odls_rec.task_id,
				autopop_odls_rec.award_id,
			   	l_new_expenditure_type,
				l_effective_date, ---p_payroll_start_date, Bug 1874696
				'PSPLDCDB',
				l_award_status);

/****************************************************************************
		 if l_award_status is null
		 then
 			project_award_linkage(autopop_odls_rec.project_id,
                                 autopop_odls_rec.award_id,
                                  l_linkage_status,
                                  l_return_status);
		else
********************************************************************************/

                 if l_award_status IS NOT NULL THEN
		--	l_patc_status := l_award_status;  for bug fix 1931680
                        l_patc_status  := substr(l_award_status,1,50);
	        end if;
	     end if;
             IF ( l_patc_status IS NOT NULL ) OR
----    ( l_linkage_status IS NOT NULL ) OR
		(l_award_status is not null ) THEN




/*

	    patc.get_status(x_project_id	=> autopop_odls_rec.project_id,
			    x_task_id		=> autopop_odls_rec.task_id,
			    x_ei_date		=> l_effective_date,
			    x_expenditure_type	=> l_new_expenditure_type,
			    x_non_labor_resource => null,
			    x_person_id		=> autopop_odls_rec.person_id,
			    x_status		=> l_patc_status,
			    x_billable_flag	=> l_billable_flag,
			    x_incurred_by_org_id => autopop_odls_rec.expenditure_organization_id,
			    x_calling_module	=> 'PSPLDCDB',
			    x_attribute1	=> to_char(autopop_odls_rec.award_id));

             project_award_linkage(autopop_odls_rec.project_id,
                                  autopop_odls_rec.award_id,
                                  l_linkage_status,
                                  l_return_status);

             IF ( l_patc_status IS NOT NULL ) OR ( l_linkage_status IS NOT NULL ) THEN


*/
--    open dist_line_odls_cur;

 --loop
  -- fetch dist_line_odls_cur into l_dist_line_id , l_effective_date, l_dist_amount;


 --- added for 5080403
 update psp_distribution_lines  set auto_expenditure_type  = l_new_expenditure_type
 where distribution_line_id =l_dist_line_id;

                suspense_account(
                         x_proc_executed,
                         autopop_odls_rec.person_id,
                         autopop_odls_rec.payroll_sub_line_id,
                         autopop_odls_rec.assignment_id,
                         l_effective_date,
                         l_dist_amount,
                         l_patc_status,
                         NULL,
                         NULL,
                         NULL,
                         NULL,
                         l_effective_date,
                         l_mode,
                         p_business_group_id,
                         p_set_of_books_id,
                         l_dist_line_id,
                         l_return_status);

                 IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                 END IF;

-- end if;  --
--  end loop;
--   close dist_line_odls_cur;

else  -- linkage status is successful

 update psp_distribution_lines  set auto_expenditure_type  = l_new_expenditure_type
 where
 distribution_line_id =l_dist_line_id;
 --- check the above that  it is necessary and sufficient
-- commit; ---- after -- to debug -- will be removed later

   end if;   -- end of linkage status is sucessful
   end if; --  end of dist_line_csr
  end loop;
 close dist_line_odls_cur;

   else   --  if natural account then

 update psp_distribution_lines  set auto_gl_code_combination_id  = l_new_gl_code_combination_id
 where
payroll_sub_line_id=autopop_odls_rec.payroll_sub_line_id
and org_schedule_id =
autopop_odls_rec.org_schedule_id  and suspense_org_account_id is null;

 end if; -- end natural account
 end if;  -- end of autopop successful

 end loop;
  close autopop_odls_cur;

end;

PROCEDURE Get_Poeta_Description
          (p_project_id       IN NUMBER,
           p_task_id          IN NUMBER,
           p_award_id         IN NUMBER,
           p_organization_id  IN NUMBER,
           p_description     OUT NOCOPY VARCHAR2,
           p_return_status   OUT NOCOPY VARCHAR2)

IS

--l_description VARCHAR2(180) := '';		Commented for bug fix Bug 2447912
l_description VARCHAR2(360) DEFAULT  '';	-- Bug 2447912: Increased Width to accomodate Org Name increase

/*  Comented the following code for Bug 3263333
 Cursor C_proj is
  Select project_number
    from gms_projects_expend_v
   where project_id = p_project_id; */

-- Introduced the following code for Bug 3263333

 Cursor C_proj is
  Select segment1 Project_number
    from pa_projects_all
   where project_id = p_project_id;


 /*  Comented the following code for Bug 3263333
Cursor C_task is
  Select task_number
    from pa_tasks_expend_v
   where task_id = p_task_id; */

-- Introduced the following code for Bug 3263333

Cursor C_task is
  Select task_number
    from pa_tasks
   where task_id = p_task_id;

/* Comented the following code for Bug 3263333
Cursor C_award is
  Select award_number
    from gms_awards_basic_v
   where award_id = p_award_id
     and rownum = 1;
*/

 -- Introduced the following code for Bug 3263333

 Cursor C_award is
  Select award_number
    from gms_awards_all
   where award_id = p_award_id
     and rownum = 1;

Cursor C_org is
  Select name
    from pa_organizations_expend_v
   where organization_id = p_organization_id
   and   active_flag = 'Y';  -- #1339622

BEGIN

 l_description := null;

 For C_proj_rec in C_proj
 Loop
   l_description := l_description||'#;'||C_proj_rec.project_number;
 End Loop;

 For C_task_rec in C_task
 Loop
   l_description := l_description||'#;'||C_task_rec.task_number;
 End Loop;

 if p_award_id is not null
 then
 For C_award_rec in C_award
 Loop
   l_description := l_description||'#;'||C_award_rec.award_number;
 End Loop;
 else
   l_description := l_description||'#;';   ---- for 5215280
 end if;
 For C_org_rec in C_org
 Loop
   l_description := l_description||'#;'||C_org_rec.name;
 End Loop;

   l_description := l_description||'#;';

   p_description := l_description;
   p_return_status := FND_API.G_RET_STS_SUCCESS;

 Exception
   WHEN OTHERS THEN
      p_return_status := FND_API.G_RET_STS_ERROR;
END;
--- NIH Salary Cap enhancement.
Procedure apply_salary_cap(p_payroll_control_id in integer,
                           p_currency_code      in varchar2,
                           p_business_group_id IN NUMBER,
                           p_Set_of_books_id IN NUMBER,
                           p_start_asg_id in integer,
                           p_end_asg_id in integer) is

cursor get_units_per_year(p_payroll_id integer) is
select type.number_per_fiscal_year
  from per_time_period_types type,
       pay_all_payrolls_f pay
 where pay.payroll_id = p_payroll_id
   and pay.period_type = type.period_type;

l_tp_start_date        date;
l_tp_end_date          date;
l_no_units_per_year    integer;
l_tp_no_of_work_days   integer;
l_sponsor_str          varchar2(4000);
l_parent_sponsor_sql_str varchar2(4000);
l_sponsor_code         varchar2(30);
l_sponsor_id           integer;
l_element_sql_str      varchar2(4000);
l_sql_str              varchar2(4000);
l_account_id           integer;
no_excess_account      exception;
l_full_name            varchar2(400);
l_asg_number            varchar2(200);
l_person_id            integer;


cursor get_asg_number(p_asg_id integer) is
select person_id, assignment_number
  from per_all_assignments_f
 where assignment_id = p_asg_id
   and assignment_type = 'E'
 order by effective_end_date desc;

cursor get_person_name(p_person_id integer) is
select full_name
 from per_all_people_f
where person_id = p_person_id;

cursor get_control_details(p_payroll_control_id integer) is
select time_period_id,
       payroll_id,
       currency_code
  from psp_payroll_controls
 where payroll_control_id = p_payroll_control_id;

control_details_rec get_control_details%rowtype;

cursor get_salary_cap_setups is
select cap.start_date start_date,
       cap.end_date end_date,
       project_id,
       substr(l_sponsor_str, instr(l_sponsor_str,fnd.lookup_code)+length(fnd.lookup_code),15) sponsor_id,
       cap.annual_salary_cap / l_no_units_per_year / l_tp_no_of_work_days daily_cap_rate,
       funding_source_code,
       annual_salary_cap
  from psp_salary_cap_overrides cap,
       fnd_lookup_values fnd
 where cap.start_date < l_tp_end_date
   and cap.end_date > l_tp_start_date
   and cap.funding_source_code = fnd.lookup_code
   and fnd.lookup_type = 'PSP_SPONSOR_NAMES'
   and fnd.language = userenv('LANG')
   and fnd.enabled_flag = 'Y'
   and l_tp_start_date between fnd.start_date_active and nvl(fnd.end_date_active, fnd_date.canonical_to_date('4000/01/31'))
   and cap.currency_code = control_details_rec.currency_code
union all
select cap2.start_date start_date,
       cap2.end_date end_date,
       null,
       substr(l_sponsor_str, instr(l_sponsor_str,fnd2.lookup_code)+length(fnd2.lookup_code),15) sponsor_id,
       cap2.annual_salary_cap / l_no_units_per_year / l_tp_no_of_work_days daily_cap_rate,
       funding_source_code,
       annual_salary_cap
 from psp_salary_caps cap2,
       fnd_lookup_values fnd2
where cap2.start_date < l_tp_end_date
  and cap2.end_date > l_tp_start_date
  and fnd2.enabled_flag = 'Y'
  and l_tp_start_date between fnd2.start_date_active and nvl(fnd2.end_date_active, fnd_date.canonical_to_date('4000/01/31'))
  and cap2.funding_source_code = fnd2.lookup_code
  and fnd2.lookup_type = 'PSP_SPONSOR_NAMES'
  and fnd2.language = userenv('LANG')
  and cap2.currency_code = control_details_rec.currency_code
order by project_id, sponsor_id;

cap_rec get_salary_cap_setups%rowtype;

cursor get_period_dates(p_time_period_id integer) is
select start_date,
       end_date
  from per_time_periods
 where time_period_id = p_time_period_id;

cursor org_excess_act(p_asg_id    integer,
                      p_dist_date date,
                      p_funding_source_code varchar2) is
select org.organization_account_id
  from psp_organization_accounts org,
       per_all_assignments_f paf
 where org.account_type_code in ( 'ORG_EXCESS')
   and p_dist_date between org.start_date_active and nvl(org.end_date_active, fnd_date.canonical_to_date('4000/01/31'))
   and paf.assignment_type = 'E'
   and paf.assignment_id = p_asg_id
   and p_dist_date between paf.effective_Start_date and paf.effective_end_date
   and paf.organization_id = org.organization_id
   and org.funding_source_code = p_funding_source_code;   --- added condn for 4744285

cursor generic_excess_act(p_dist_date date,
                          p_excess_org_id number,
                          p_funding_source_code varchar2) is
select organization_account_id
  from psp_organization_accounts
 where p_dist_date between start_date_active and nvl(end_date_active, fnd_date.canonical_to_date('4000/01/31'))
   and account_type_code = 'ORG_EXCESS'
   and organization_id = p_excess_org_id
   and p_funding_source_code = funding_source_code;

cursor get_funding_source_codes(p_tp_start_date date) is
select distinct lookup_code
  from fnd_lookup_values
 where lookup_type = 'PSP_SPONSOR_NAMES'
   and language = userenv('LANG')
   and enabled_flag = 'Y'
   and p_tp_start_date between start_date_active and  nvl(end_date_active, fnd_date.canonical_to_date('4000/01/31'));

 t_dist_line_id  psp_sql_tab_number15;
 t_dist_date     psp_sql_tab_date;
 t_dist_amount   psp_sql_tab_number;
 t_assignment_id  psp_sql_tab_number15;
 t_excess_line_id  psp_sql_tab_number15;
 t_excess_account  psp_sql_tab_number15;
 t_cap_sched_amount psp_sql_tab_number;

cursor check_excess_poeta(p_dist_line_id number) is
select pdl.cap_excess_project_id,
       pdl.cap_excess_task_id,
       pdl.cap_excess_award_id,
       pdl.cap_excess_exp_type,
       pdl.cap_excess_exp_org_id,
       pdl.effective_date,
       ppl.person_id,
       ppl.assignment_id,
       pdl.distribution_date,
       pdl.set_of_books_id,
       pdl.distribution_amount,
       pdl.business_group_id,
       psl.payroll_sub_line_id,
       pdl.distribution_line_id
  from psp_distribution_lines pdl,
       psp_payroll_sub_lines psl,
       psp_payroll_lines ppl
 where pdl.gl_projecT_flag = 'P'
   and psl.payroll_sub_line_id = pdl.payroll_sub_line_id
   and pdl.distribution_line_id = p_dist_line_id
   and psl.payroll_line_id = ppl.payroll_line_id;

check_excess_poeta_rec check_excess_poeta%rowtype;

  x_proc_executed     VARCHAR2(10) := 'TRUE';
  l_return_status     VARCHAR2(1);
  l_gl_project_flag   VARCHAR2(1);
  l_patc_status       VARCHAR2(50);
  l_billable_flag     VARCHAR2(1);
  l_msg_count     NUMBER;
  l_msg_app       VARCHAR2(2000);
  l_msg_type      varchar2(2000);
  l_msg_token1    varchar2(2000);
  l_msg_token2    varchar2(2000);
  l_msg_token3    varchar2(2000);
  l_award_status  varchar2(200);
begin

hr_utility.trace('CDL procedure: --> apply_salary_cap proc Start');

open get_control_details(p_payroll_control_id);
fetch get_control_details into control_details_rec;
close get_control_details;

open get_period_dates(control_details_rec.time_period_id);
fetch get_period_dates into l_tp_start_date, l_tp_end_date;
close get_period_dates;

 hr_utility.trace('CDL program --> apply_salary_cap l_tp_start and end date ='||
          l_tp_start_date||','||l_tp_end_date);

open get_units_per_year(control_details_rec.payroll_id);
fetch get_units_per_year into l_no_units_per_year;
close get_units_per_year;

l_tp_no_of_work_days := psp_general.business_days(l_tp_start_date, l_tp_end_date);
l_sponsor_str := null;

open get_funding_source_codes(l_tp_start_date);
loop
 fetch get_funding_source_codes into l_sponsor_code;
 hr_utility.trace('CDL program --> apply_salary_cap l_sponsor_code (lkup)= '||l_sponsor_code );
 if get_funding_source_codes%notfound then
   close get_funding_source_codes;
   exit;
 end if;
 l_sponsor_id :=
   psp_general.get_configuration_option_value(p_business_group_id,
                                              'PSP_SET_SPONSORS_FOR_CAPPING',
                                              l_sponsor_code);
 l_sponsor_str := l_sponsor_str ||'@@@'|| l_sponsor_code||rpad(to_char(l_sponsor_id),15);
 hr_utility.trace('CDL program --> apply_salary_cap WITHIN LOOP l_sponsor_str= '||l_sponsor_str );
end loop;

 hr_utility.trace('CDL program --> apply_salary_cap l_sponsor_str= '||l_sponsor_str );
l_sponsor_id := 0;
open get_salary_cap_setups;
loop
  fetch get_salary_cap_setups into cap_rec;
  if get_salary_cap_setups%notfound then
      close get_salary_cap_setups;
      exit;
  end if;

  hr_utility.trace('CDL program --> apply_salary_cap cap_rec.sponsor_id, cap_rec.project_id, cap_rec.start_date, cap_rec.enc_date, cap_rec.annual_salary_cap , daily_cap_rate = '||
  cap_rec.sponsor_id||','||cap_rec.project_id||','|| cap_rec.start_date||','|| cap_rec.end_date||','|| cap_rec.annual_salary_cap||' , '||cap_rec.daily_cap_rate);

    --#fnd_file.put_line(fnd_file.log,
  ---'CDL program --> apply_salary_cap cap_rec.sponsor_id, cap_rec.project_id, cap_rec.start_date, cap_rec.enc_date, cap_rec.annual_salary_cap , daily_cap_rate , l_no_units_per_year , l_tp_no_of_work_days= '
---|| cap_rec.sponsor_id||','||cap_rec.project_id||','|| cap_rec.start_date||','|| cap_rec.end_date||','|| cap_rec.annual_salary_cap||' , '||cap_rec.daily_cap_rate||' , '||l_no_units_per_year ||' , '||l_tp_no_of_work_days);

--- removed hard coded strings and replaced with parameters. 5530231
     hr_utility.trace('CDL program --> apply_salary_cap constructiong element_str');
  ---  added assignment_type = E check for 5575398
   if g_cap_element_set_id is null then
      l_element_sql_str :=
         'and (ppl.assignment_id, ppl.element_type_id) in
        (select paf.assignment_id, min(piv.element_type_id)
           From per_all_assignments_f paf,
                per_pay_bases         ppb,
                pay_input_values_f    piv
          where paf.payroll_id = '||control_details_rec.payroll_id||'
            and ('||''''||l_tp_start_date ||''''||'    between paf.effective_start_date  and paf.effective_end_date
                or '||''''||l_tp_end_date   ||''''||' between  paf.effective_start_date  and paf.effective_end_date )
            and paf.assignment_id between '||p_start_asg_id||'  and '||p_end_asg_id||'
            and paf.pay_basis_id = ppb.pay_basis_id
            and paf.assignment_type =  '||''''||'E'||''''||'
            and ppb.input_value_id = piv.input_value_id
            group by paf.assignment_id, paf.pay_basis_id);';
   else
      l_element_sql_str :=
       'and  ppl.element_type_id in
                ((select petr.element_type_id
                    from pay_element_type_rules petr
                   where petr.include_or_exclude = '||''''||'I'||''''||'
                     and petr.element_Set_id = '||g_cap_element_set_id||')
                  union all
                  (select pet1.element_type_id
                     from pay_element_types_f pet1,
                          pay_ele_classification_rules pecr
                    where pet1.classification_id = pecr.classification_id
                      and pecr.element_set_id = '||g_cap_element_set_id||' ))
        and ppl.element_type_id not in
                 (select petr1.element_type_id
                    from pay_element_type_rules petr1
                   where petr1.include_or_exclude='||''''||'E'||''''||'
                     and petr1.element_set_id = '||g_cap_element_set_id||');';
   end if;
     hr_utility.trace('CDL program --> apply_salary_cap DONE constructiong element_str');
  if cap_rec.project_id is not null then
     hr_utility.trace('CDL program --> apply_salary_cap cap project not null id='||cap_rec.project_id);
   l_sql_str :=
   'Select pdl.distribution_line_id,
           pdl.distribution_date,
           pdl.distribution_amount,
           round(nvl(psl.schedule_percent, nvl(pdls.schedule_percent, nvl(pea.percent, (100 * pdl.distribution_amount)/ppsl.daily_rate )))/100 * '||
              fnd_number.number_to_canonical(cap_rec.daily_cap_rate)||', '||g_precision||') capped_schedule_amount,
           ppl.assignment_id,
           null excess_account_id,
           null excess_line_id
       bulk collect
       into  :t_dist_line_id,
             :t_dist_date,
             :t_dist_amount,
             :t_capped_sched_amount,
             :t_assignment_id,
             :t_excess_account,
             :t_excess_line_id
      From psp_schedule_lines          psl,
           psp_organization_accounts   pod,
           psp_element_type_accounts   pea,
           psp_default_labor_schedules pdls,
           psp_payroll_controls        ppc,
           psp_payroll_lines           ppl,
           psp_payroll_sub_lines       ppsl,
           gms_awards_all              awd,
           psp_distribution_lines      pdl
     where pdl.status_code = '||''''||'N'||''''||'
       and pdl.payroll_sub_line_id = ppsl.payroll_sub_line_id
       and ppsl.payroll_line_id = ppl.payroll_line_id
       and ppl.payroll_control_id = ppc.payroll_control_id
       and pdl.schedule_line_id = psl.schedule_line_id(+)
       and pdl.default_org_account_id = pod.organization_account_id(+)
       and pdl.element_account_id = pea.element_account_id(+)
       and pdl.suspense_org_account_id is null
       and pdl.org_schedule_id = pdls.org_schedule_id(+)
       and pdl.gl_project_flag = '||''''||'P'||''''||'
       and pdl.distribution_amount <> 0
       and ppc.payroll_control_id = '||p_payroll_control_id||'
       and ppc.business_group_id = '||p_business_group_id||'
       and ppc.set_of_books_id = '||p_set_of_books_id||'
       and ppsl.daily_rate > '||cap_rec.daily_cap_rate||'
       and ppl.dr_cr_flag = '||''''||'D'||''''||'
       and ppl.assignment_id between '||p_start_asg_id||' and '||p_end_asg_id||'
       and pdl.cap_excess_dist_line_id is null
       and pdl.distribution_date between '||''''||cap_rec.start_date||''''||' and '||''''||cap_rec.end_date||''''||'
       and nvl(psl.award_id,
           nvl(pod.award_id,
           nvl(pea.award_id, pdls.award_id))) = awd.award_id
       and nvl(psl.project_id,
           nvl(pod.project_id,
           nvl(pea.project_id,
              pdls.project_id)))  = '||cap_rec.project_id;
 else  --- sponsor_id is not null
     hr_utility.trace('CDL program --> apply_salary_cap capping for sponsor ');
   l_sql_str :=
   '  select pdl.distribution_line_id,
             pdl.distribution_date,
             pdl.distribution_amount,
             round(nvl(psl.schedule_percent, nvl(pdls.schedule_percent, nvl(pea.percent, (100 * pdl.distribution_amount)/ppsl.daily_rate )))/100 * '||
              fnd_number.number_to_canonical(cap_rec.daily_cap_rate)||', '||g_precision||') capped_schedule_amount,
             ppl.assignment_id,
             null excess_account_id,
             null excess_line_id
       bulk collect
       into  :t_dist_line_id,
             :t_dist_date,
             :t_dist_amount,
             :t_capped_sched_amount,
             :t_assignment_id,
             :t_excess_account,
             :t_excess_line_id
       From  psp_schedule_lines        psl,
             psp_organization_accounts    pod,
             psp_element_type_accounts       pea,
             psp_default_labor_schedules     pdls,
             psp_payroll_controls            ppc,
             psp_payroll_lines               ppl,
             psp_payroll_sub_lines           ppsl,
             psp_distribution_lines          pdl,
             gms_awards_all                   awd
       where pdl.status_code = '||''''||'N'||''''||'
         AND pdl.payroll_sub_line_id = ppsl.payroll_sub_line_id
         AND ppsl.payroll_line_id = ppl.payroll_line_id
         AND ppl.payroll_control_id = ppc.payroll_control_id
         AND pdl.schedule_line_id = psl.schedule_line_id(+)
         AND pdl.default_org_account_id = pod.organization_account_id(+)
         AND pdl.element_account_id = pea.element_account_id(+)
         AND pdl.org_schedule_id = pdls.org_schedule_id(+)
         and pdl.suspense_org_account_id is null
         AND pdl.gl_project_flag = '||''''||'P'||''''||'
         AND pdl.distribution_amount <> 0
         and ppc.payroll_control_id = '||p_payroll_control_id||'
         and ppc.business_group_id = '||p_business_group_id||'
         and ppc.set_of_books_id = '||p_set_of_books_id||'
         and ppsl.daily_rate > '||cap_rec.daily_cap_rate||'
         AND ppl.dr_cr_flag = '||''''||'D'||''''||'
         and pdl.cap_excess_dist_line_id is null
         and pdl.distribution_date between '||''''||cap_rec.start_date||''''||' and '||''''||cap_rec.end_date||''''||'
         and ppl.assignment_id between '||p_start_asg_id||' and '||p_end_asg_id||'
         and nvl(psl.award_id,
             nvl(pod.award_id,
             nvl(pea.award_id, pdls.award_id))) = awd.award_id
         and not exists
           (select 1
              from psp_salary_cap_overrides over
             where nvl(psl.project_id, nvl(pod.project_id, nvl(pea.project_id, pdls.project_id)))
                               = over.project_id
                   and over.currency_code = ppc.currency_code
                   and over.funding_source_code = '||''''||cap_rec.funding_source_code||''''||'
                   and pdl.distribution_date between over.start_date and over.end_date)';
    end if;

     hr_utility.trace('CDL program --> After the dist line string is built');
    --#fnd_file.put_line(fnd_file.log,'l_sql_str0 ='||l_sql_str);
    if psp_salary_cap_custom.g_parent_sponsor_field is null then
        -- by default gms.funding_source_id has sponsor.
         l_parent_sponsor_sql_str :=
            ' AND awd.funding_source_id = '||cap_rec.sponsor_id;
     else
        /*  l_parent_sponsor_sql_str :=
        ' AND (awd.'||rtrim(ltrim(psp_salary_cap_custom.g_parent_sponsor_field))||' = '
                   ||cap_rec.sponsor_id || ' or awd.funding_source_id = '||cap_rec.sponsor_id||')'; */
          l_parent_sponsor_sql_str :=
        ' AND awd.'||rtrim(ltrim(psp_salary_cap_custom.g_parent_sponsor_field))||' = ' ||cap_rec.sponsor_id;
     end if;

  l_sql_str := ' begin '|| l_sql_str ||' '
                        || l_parent_sponsor_sql_str ||' '
                        || l_element_sql_str ||' '||
               ' end; ';


   hr_utility.trace('CDL program --> apply_salary_cap --> l_sql_str=');
   hr_utility.trace(substr(l_sql_str,1,200));
   hr_utility.trace(substr(l_sql_str,201,200));
   hr_utility.trace(substr(l_sql_str,401,200));
   hr_utility.trace(substr(l_sql_str,601,200));
   hr_utility.trace(substr(l_sql_str,801,200));
   hr_utility.trace(substr(l_sql_str,1001,200));
   hr_utility.trace(substr(l_sql_str,1201,200));
   hr_utility.trace(substr(l_sql_str,1401,200));
   hr_utility.trace(substr(l_sql_str,1601,200));
   hr_utility.trace(substr(l_sql_str,1801,200));
   hr_utility.trace(substr(l_sql_str,2001,200));
   hr_utility.trace(substr(l_sql_str,2201,200));
   hr_utility.trace(substr(l_sql_str,2401,200));
   hr_utility.trace(substr(l_sql_str,2601,200));
   hr_utility.trace(substr(l_sql_str,2801,200));
            --- added more trace for 5899407
   if substr(l_sql_str,3000,200) is not null then
     hr_utility.trace(substr(l_sql_str,3000,200));
   end if;
   if substr(l_sql_str,3201,200) is not null then
     hr_utility.trace(substr(l_sql_str,3201,200));
   end if;
   if substr(l_sql_str,3401,200) is not null then
     hr_utility.trace(substr(l_sql_str,3401,200));
   end if;

    --#fnd_file.put_line(fnd_file.log,' before exec immediate l_sql_str ='||l_sql_str);
  execute immediate l_sql_str
  using out t_dist_line_id,
        out t_dist_date,
        out t_dist_amount,
        out t_cap_sched_amount,
        out t_assignment_id,
        out t_excess_account,
        out t_excess_line_id;

  hr_utility.trace('CDL program --> apply_salary_cap --> dist_line_id.count='||t_dist_line_id.count);
  for i in 1..t_dist_line_id.count
  loop
     open org_excess_act(t_assignment_id(i), t_dist_date(i), cap_rec.funding_source_code);  -- introduced sponsor 4744285
     fetch org_excess_act into l_account_id;
     if org_excess_act%notfound then
        open generic_excess_act(t_dist_date(i), g_gen_excess_org_id,
cap_rec.funding_source_code);
        fetch generic_excess_act into l_account_id;
        if generic_excess_act%notfound then
          close org_excess_act;
          close generic_excess_act;
          hr_utility.trace('CDL program --> apply_salary_cap --> NO_EXCESS_ACCOUNT for asg, date ='||t_assignment_id(i)||','|| t_dist_date(i));

          open get_asg_number(t_assignment_id(i));
          fetch get_asg_number into l_person_id, l_asg_number;
          close get_asg_number;

          open get_person_name(l_person_id);
          fetch get_person_name into l_full_name;
          close get_person_name;

          fnd_message.set_name('PSP','PSP_NO_EXCESS_ACCOUNT');
          fnd_message.set_token('ENAME',l_full_name);
          fnd_message.set_token('ASGNUM',l_asg_number);
          fnd_message.set_token('DISTDATE',t_dist_date(i));
          fnd_msg_pub.add;
          raise no_excess_account;
        end if;
        close generic_excess_act;
        close org_excess_act;
     else
       close org_excess_act;
     end if;
     t_excess_account(i) := l_account_id;
   end loop;

   for i in 1..t_dist_line_id.count
   loop
   select psp_distribution_lines_s.nextval
     into t_excess_line_id(i)
     from dual;
   end loop;

   forall i in 1..t_dist_line_id.count
   Insert into psp_distribution_lines(distribution_line_id,
                                      distribution_date,
                                      distribution_amount,
                                      effective_date,
                                      status_code,
                                      payroll_sub_line_id,
                                      business_group_id,
                                      set_of_books_id,
                                      gl_project_flag,
                                      cap_excess_glccid,
                                      cap_excess_project_id,
                                      cap_excess_award_id,
                                      cap_excess_task_id,
                                      cap_excess_exp_org_id,
                                      cap_excess_exp_type,
                                      funding_source_code,
                                      annual_salary_cap)
   select t_excess_line_id(i),
          pdl.distribution_date,
          pdl.distribution_amount - t_cap_sched_amount(i),
          decode(exc.gl_code_combination_id,null,pdl.effective_date,g_gl_effective_date),
          pdl.status_code,
          pdl.payroll_sub_line_id,
          pdl.business_group_id,
          pdl.set_of_books_id,
          decode(exc.gl_code_combination_id,null,'P','G'),
          exc.gl_code_combination_id,
          exc.project_id,
          exc.award_id,
          exc.task_id,
          exc.expenditure_organization_id,
          exc.expenditure_type,
          cap_rec.funding_source_code,
          cap_rec.annual_salary_cap
     from psp_distribution_lines  pdl,
          psp_organization_accounts exc
    where pdl.distribution_line_id = t_dist_line_id(i)
      and exc.organization_account_id = t_excess_account(i);

   forall i in 1..t_dist_line_id.count
   update psp_distribution_lines pdl
      set distribution_amount = t_cap_sched_amount(i),
          cap_excess_dist_line_id = t_excess_line_id(i),
          funding_source_code = cap_rec.funding_source_code,
          annual_salary_cap = cap_rec.annual_salary_cap
    where distribution_line_id = t_dist_line_id(i);

  hr_utility.trace('CDL Program --> apply_salary_cap -->  Excess array count='||t_excess_line_id.count);
for i in 1..t_excess_line_id.count
loop
  open check_excess_poeta(t_excess_line_id(i));
  fetch check_excess_poeta into check_excess_poeta_rec;
  if check_excess_poeta%found then
          hr_utility.trace(
          'CDL program --> apply_salary_cap --> Excess account Suspense check for dist line id ='||
                           t_excess_line_id(i));

          hr_utility.trace(
          'CDL program --> apply_salary_cap --> calling pa_txn_pub  x_project_id=>'||
                         check_excess_poeta_rec.cap_excess_project_id||
                 ', x_task_id=>'|| check_excess_poeta_rec.cap_excess_task_id||
                 ', x_ei_date=>'|| check_excess_poeta_rec.effective_date||
                 ', x_expenditure_type	=> '||check_excess_poeta_rec.cap_excess_exp_type||
                 ', x_person_id		=> '||check_excess_poeta_rec.person_id||
                 ', x_incurred_by_org_id=> '||check_excess_poeta_rec.cap_excess_exp_org_id);
                      pa_transactions_pub.validate_transaction(
			x_project_id		=> check_excess_poeta_rec.cap_excess_project_id,
			x_task_id		=> check_excess_poeta_rec.cap_excess_task_id,
			x_ei_date		=> check_excess_poeta_rec.effective_date,
			x_expenditure_type	=> check_excess_poeta_rec.cap_excess_exp_type,
			x_non_labor_resource	=> null,
			x_person_id		=> check_excess_poeta_rec.person_id,
			x_incurred_by_org_id	=> check_excess_poeta_rec.cap_excess_exp_org_id,
			x_calling_module	=> 'PSPLDCDB',
			x_msg_application	=> l_msg_app,
			x_msg_type		=> l_msg_type,
			x_msg_token1		=> l_msg_token1,
			x_msg_token2		=> l_msg_token2,
			x_msg_token3		=> l_msg_token3,
			x_msg_count		=> l_msg_count,
			x_msg_data		=> l_patc_status,
			x_billable_flag		=> l_billable_flag,
			p_sys_link_function     => 'ST');            --Bug 5639589: Added parameter


          hr_utility.trace(
          'CDL program --> apply_salary_cap --> Excess account Suspense l_patc ='||l_patc_status);
	     if check_excess_poeta_rec.cap_excess_award_id is not null and l_patc_status is null
	     then
		 gms_transactions_pub.validate_transaction
				(check_excess_poeta_rec.cap_excess_project_id,
			   	check_excess_poeta_rec.cap_excess_task_id,
				check_excess_poeta_rec.cap_excess_award_id,
			   	check_excess_poeta_rec.cap_excess_exp_type,
				check_excess_poeta_rec.effective_date,
				'PSPLDCDB',
				l_award_status);

                      hr_utility.trace(
                      'CDL program --> apply_salary_cap --> Excess account Suspense l_award_status ='||
                      l_award_status);

                     if l_award_status IS NOT NULL then
                        l_patc_status  := substr(l_award_status,1,50);
	             end if;
	     end if;
             IF ( l_patc_status IS NOT NULL ) OR
		(l_award_status is not null ) THEN

                 hr_utility.trace( 'CDL program --> apply_salary_cap --> invoke suspense_acc prarams ='||
                         check_excess_poeta_rec.person_id||','||
                         check_excess_poeta_rec.payroll_sub_line_id||','||
                         check_excess_poeta_rec.assignment_id||','||
                         check_excess_poeta_rec.distribution_date||','||
                         check_excess_poeta_rec.distribution_amount||','||
                         l_patc_status||','||
                         check_excess_poeta_rec.effective_date||','||
			 check_excess_poeta_rec.business_group_id||','||
			 check_excess_poeta_rec.set_of_books_id||','||
                         check_excess_poeta_rec.distribution_line_id);

                suspense_account(
                         x_proc_executed,
                         check_excess_poeta_rec.person_id,
                         check_excess_poeta_rec.payroll_sub_line_id,
                         check_excess_poeta_rec.assignment_id,
                         check_excess_poeta_rec.distribution_date,
                         check_excess_poeta_rec.distribution_amount,
                         l_patc_status,
                         NULL,
                         NULL,
                         NULL,
                         NULL,
                         check_excess_poeta_rec.effective_date,
                         'I',
			 check_excess_poeta_rec.business_group_id,
			 check_excess_poeta_rec.set_of_books_id,
                         check_excess_poeta_rec.distribution_line_id,
                         l_return_status);

                 IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                 END IF;
               END IF;
   end if;
  close check_excess_poeta;
end loop;  ---  apply suspense

End loop;  --- salary Cap array.
 t_dist_line_id  := psp_sql_tab_number15(null);
 t_dist_date     := psp_sql_tab_date(null);
 t_dist_amount   := psp_sql_tab_number(null);
 t_assignment_id  := psp_sql_tab_number15(null);
 t_excess_line_id  := psp_sql_tab_number15(null);
 t_excess_account  := psp_sql_tab_number15(null);
 t_cap_sched_amount := psp_sql_tab_number(null);
 t_dist_line_id.delete;
 t_dist_date.delete;
 t_dist_amount.delete;
 t_assignment_id.delete;
 t_excess_line_id.delete;
 t_excess_account.delete;
 t_cap_sched_amount.delete;

exception
when others then
   fnd_msg_pub.add_exc_msg('PSB_LABOR_DIST','APPLY_SALARY_CAP');
   raise;
End apply_salary_cap;

procedure excess_account_autopop(p_payroll_control_id in number,
                                 p_business_group_id  in number,
                                 p_set_of_books_id    in number,
                                 p_start_asg_id       in integer,
                                 p_end_asg_id         in integer,
                                 p_return_status      out nocopy varchar2)  is

cursor autopop_exc_cur(p_payroll_control_id in number) IS
select pdl.payroll_sub_line_id ,
       max(pdl.distribution_date) max_dist_date, ---5505041
       max(pdl.effective_date) effective_date,
       ppl.person_id,
       ppl.assignment_id,
       ppl.element_type_id,
       pdl.cap_excess_project_id project_id,
       pdl.cap_excess_exp_org_id expenditure_organization_id,
       pdl.cap_excess_exp_type expenditure_type,
       pdl.cap_excess_task_id task_id,
       pdl.cap_excess_award_id award_id,
       pdl.cap_excess_glccid gl_code_combination_id,
       ppl.cost_id,
       ppl.payroll_action_type
  from psp_distribution_lines pdl,
       psp_payroll_lines ppl,
       psp_payroll_sub_lines ppsl
 where ppl.payroll_control_id = p_payroll_control_id
   and ppl.payroll_line_id = ppsl.payroll_line_id
   and ppsl.payroll_sub_line_id = pdl.payroll_sub_line_id
   and pdl.suspense_org_account_id is null
   and (pdl.cap_excess_glccid is not null or
        pdl.cap_excess_project_id is not null)
   and ppl.assignment_id between p_start_asg_id and p_end_Asg_id
   and pdl.adj_account_flag is null
 group by ppl.cost_id,
          ppl.payroll_action_type,
          pdl.payroll_sub_line_id,
          ppl.person_id,
          ppl.assignment_id,
          ppl.element_type_id,
          pdl.cap_excess_project_id,
          pdl.cap_excess_exp_org_id,
          pdl.cap_excess_exp_type,
          pdl.cap_excess_task_id,
          pdl.cap_excess_award_id,
          pdl.cap_excess_glccid;

autopop_exc_rec autopop_exc_cur%ROWTYPE;

cursor dist_line_exc_cur(p_payroll_sub_line_id in number,
                         p_cap_excess_project_id in number,
                         p_cap_excess_exp_org_id in number,
                         p_cap_excess_exp_type in varchar2,
                         p_cap_excess_task_id in number,
                         p_cap_excess_award_id in number,
                         p_cap_excess_glccid in number) is

select distribution_line_id,
       effective_date,
       distribution_amount
  from psp_distribution_lines pdl
 where payroll_sub_line_id = p_payroll_sub_line_id
   and ((   p_cap_excess_glccid is not null
       and p_cap_excess_glccid  = pdl.cap_excess_glccid)
       or
        (p_cap_excess_project_id = pdl.cap_excess_project_id
        and p_cap_excess_exp_org_id = pdl.cap_excess_exp_org_id
        and p_cap_excess_exp_type = pdl.cap_excess_exp_type
        and p_cap_excess_task_id  = pdl.cap_excess_task_id
        and nvl(p_cap_excess_award_id,-1)  = nvl(pdl.cap_excess_award_id,-1)))
order by effective_date;

  l_dist_amount                 NUMBER:=0;
  l_acct_type                   VARCHAR2(1);
  l_auto_pop_status		VARCHAR2(1);
  l_new_expenditure_type        VARCHAR2(30);
  l_new_gl_code_combination_id  NUMBER(15);
  l_auto_status                 VARCHAR2(20) := null;
  l_dist_line_id                NUMBER(9);
  l_linkage_status              VARCHAR2(50);
  l_patc_status                 VARCHAR2(50);
  x_proc_executed               VARCHAR2(10) := 'TRUE';
  l_billable_flag               VARCHAR2(1);
  l_mode                        VARCHAR2(1) := 'I';
  l_effective_date              DATE;
  l_return_status               VARCHAR2(1);
  l_dbg_ctr                     number :=0;
  l_msg_count                   NUMBER;
  l_msg_app                     VARCHAR2(2000);
  l_msg_type                    varchar2(2000);
  l_msg_token1                  varchar2(2000);
  l_msg_token2                  varchar2(2000);
  l_msg_token3                  varchar2(2000);
  l_award_status                varchar2(200);
  l_prev_cost_id                integer; ---- for 5090002

begin

open autopop_exc_cur(p_payroll_control_id);
loop
 fetch autopop_exc_cur into autopop_exc_rec;
 if autopop_exc_cur%notfound then exit;
 end if;
 if nvl(autopop_exc_rec.payroll_action_type,'X') = 'L' then --- 5090002
   if nvl(l_prev_cost_id, -999) <> autopop_exc_rec.cost_id then
       l_prev_cost_id :=  autopop_exc_rec.cost_id;
       g_retro_parent_element_id := nvl(get_retro_parent_element_id(autopop_exc_rec.cost_id), autopop_exc_rec.element_type_id);
   end if;
       autopop_exc_rec.element_type_id := g_retro_parent_element_id;
 end if;

if autopop_exc_rec.gl_code_combination_id is null then
    l_acct_type:='E';
else
    l_acct_type:='N';
end if;
if nvl(g_use_eff_date,'N') = 'Y' then    --- added if condn for 5505041
   null;
else
   autopop_exc_rec.effective_date := autopop_exc_rec.max_dist_date;
end if;


     psp_autopop.main(
                    p_acct_type                   => l_acct_type,
		    p_person_id                   => autopop_exc_rec.person_id,
	            p_assignment_id               => autopop_exc_rec.assignment_id,
		    p_element_type_id             => autopop_exc_rec.element_type_id,
		    p_project_id                  => autopop_exc_rec.project_id,
		    p_expenditure_organization_id => autopop_exc_rec.expenditure_organization_id,
		    p_task_id                     => autopop_exc_rec.task_id,
		    p_award_id                    => autopop_exc_rec.award_id,
                    p_expenditure_type            => autopop_exc_rec.expenditure_type,
		    p_gl_code_combination_id      => autopop_exc_rec.gl_code_combination_id,
		    p_payroll_date                => autopop_exc_rec.effective_date,
		    p_set_of_books_id             => p_set_of_books_id,
                    p_business_group_id           => p_business_group_id,
		    ret_expenditure_type          => l_new_expenditure_type,
		    ret_gl_code_combination_id    => l_new_gl_code_combination_id,
		    retcode 			  => l_auto_pop_status);

     IF (l_auto_pop_status = FND_API.G_RET_STS_UNEXP_ERROR) OR
       (l_auto_pop_status = FND_API.G_RET_STS_ERROR) THEN
       IF l_auto_pop_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         if l_acct_type ='N'  then
              l_auto_status := 'AUTO_POP_NA_ERROR';
         else
              l_auto_status :='AUTO_POP_EXP_ERROR';
         end if;
       ELSIF l_auto_pop_status = FND_API.G_RET_STS_ERROR THEN
         l_auto_status := 'AUTO_POP_NO_VALUE';
       END IF;

    open dist_line_exc_cur(autopop_exc_rec.payroll_sub_line_id,
                           autopop_exc_rec.project_id,
                           autopop_exc_rec.expenditure_organization_id,
                           autopop_exc_rec.expenditure_type,
                           autopop_exc_rec.task_id,
                           autopop_exc_rec.award_id,
                           autopop_exc_rec.gl_code_combination_id);
    loop
    fetch dist_line_exc_cur into l_dist_line_id, l_effective_date, l_dist_amount;

      if dist_line_exc_cur%notfound then exit;
         else
                suspense_account(
                         x_proc_executed,
                         autopop_exc_rec.person_id,
                         autopop_exc_rec.payroll_sub_line_id,
                         autopop_exc_rec.assignment_id,
                         l_effective_date,
                         l_dist_amount, -- will be distribution_amount
                         l_auto_status,
                         NULL,
                         NULL,
                         NULL,
                         NULL,
                         l_effective_date,
                         l_mode,
                         p_business_group_id,
                         p_set_of_books_id,
                         l_dist_line_id,
                         l_return_status);
       end if;
    end loop;
   close dist_line_exc_cur;

else   --- autopop is successful
    if l_acct_type= 'E' then
    open dist_line_exc_cur(autopop_exc_rec.payroll_sub_line_id,
                           autopop_exc_rec.project_id,
                           autopop_exc_rec.expenditure_organization_id,
                           autopop_exc_rec.expenditure_type,
                           autopop_exc_rec.task_id,
                           autopop_exc_rec.award_id,
                           autopop_exc_rec.gl_code_combination_id);
    loop
          fetch dist_line_exc_cur into l_dist_line_id , l_effective_date, l_dist_amount;

               if dist_line_exc_cur%notfound then exit;
                     else

	    pa_transactions_pub.validate_transaction(
			x_project_id		=> autopop_exc_rec.project_id,
			x_task_id		=> autopop_exc_rec.task_id,
			x_ei_date		=> l_effective_date,
			x_expenditure_type	=> l_new_expenditure_type,
			x_non_labor_resource	=> null,
			x_person_id		=> autopop_exc_rec.person_id,
			x_incurred_by_org_id	=> autopop_exc_rec.expenditure_organization_id,
			x_calling_module	=> 'PSPLDCDB',
			x_msg_application	=> l_msg_app,
			x_msg_type		=> l_msg_type,
			x_msg_token1		=> l_msg_token1,
			x_msg_token2		=> l_msg_token2,
			x_msg_token3		=> l_msg_token3,
			x_msg_count		=> l_msg_count,
			x_msg_data		=> l_patc_status,
			x_billable_flag		=> l_billable_flag,
			p_sys_link_function     => 'ST');            --Bug 5639589: Added parameter


	     if autopop_exc_rec.award_id is not null and l_patc_status is null
	     then
		 gms_transactions_pub.validate_transaction
				(autopop_exc_rec.project_id,
			   	autopop_exc_rec.task_id,
				autopop_exc_rec.award_id,
			   	l_new_expenditure_type,
				l_effective_date, ---p_payroll_start_date, Bug 1874696
				'PSPLDCDB',
				l_award_status);

                if l_award_status IS NOT NULL then
                        l_patc_status  := substr(l_award_status,1,50);
	        end if;
	     end if;
             IF ( l_patc_status IS NOT NULL ) OR
		(l_award_status is not null ) THEN


                suspense_account(
                         x_proc_executed,
                         autopop_exc_rec.person_id,
                         autopop_exc_rec.payroll_sub_line_id,
                         autopop_exc_rec.assignment_id,
                         l_effective_date,
                         l_dist_amount,
                         l_patc_status,
                         NULL,
                         NULL,
                         NULL,
                         NULL,
                         l_effective_date,
                         l_mode,
                         p_business_group_id,
                         p_set_of_books_id,
                         l_dist_line_id,
                         l_return_status);

                 IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                 END IF;

else  -- linkage status is successful

 update psp_distribution_lines  set auto_expenditure_type  = l_new_expenditure_type
 where distribution_line_id=l_dist_line_id;

   end if;   -- patc status
  end if ;  -- dist_line_csr not found;
end loop;
close dist_line_exc_cur;

   else   --  if natural account then

 update psp_distribution_lines  set auto_gl_code_combination_id  = l_new_gl_code_combination_id
 where payroll_sub_line_id = autopop_exc_rec.payroll_sub_line_id
   and  cap_excess_glccid = autopop_exc_rec.gl_code_combination_id
   and suspense_org_account_id is null;

 end if; -- end natural account
 end if;  -- end of autopop successful

 end loop;
  close autopop_exc_cur;
exception
when others then
   fnd_msg_pub.add_exc_msg('PSB_LABOR_DIST','EXCESS_ACCOUNT_AUTOPOP');
   raise;
end excess_account_autopop;
------------- introduced for 5080403
procedure generic_account_autopop(p_payroll_control_id in number,
                                  p_business_group_id  in number,
                                  p_set_of_books_id    in number,
                                  p_start_asg_id       in integer,
                                  p_end_asg_id         in integer,
                                  p_schedule_type      in varchar2)  is
  cursor org_default_account_cur is
  select pdl.payroll_sub_line_id,
         decode(g_use_eff_date, 'Y', max(pdl.effective_date) ,
               max(pdl.distribution_date)) effective_date,   --- 5505041
         ppl.person_id,
         ppl.assignment_id,
         ppl.element_type_id,
         poa.project_id,
         poa.expenditure_organization_id,
         poa.expenditure_type,
         poa.task_id,
         poa.award_id,
         poa.gl_code_combination_id,
         poa.organization_account_id,
         ppl.payroll_action_type,
         ppl.cost_id
    from psp_distribution_lines pdl,
         psp_payroll_lines ppl,
         psp_payroll_sub_lines ppsl,
         psp_organization_accounts poa
   where ppl.payroll_control_id = p_payroll_control_id
     and ppl.assignment_id between p_start_asg_id and p_end_asg_id
     and ppl.payroll_line_id = ppsl.payroll_line_id
     and ppsl.payroll_sub_line_id = pdl.payroll_sub_line_id
     and pdl.suspense_org_account_id is null
     and pdl.default_org_account_id = poa.organization_account_id
     and pdl.adj_account_flag is null
group by ppl.cost_id,
         ppl.payroll_action_type,
         pdl.payroll_Sub_line_id,
         ppl.person_id,
         ppl.assignment_id,
         ppl.element_type_id ,
         poa.project_id,
         poa.expenditure_organization_id,
         poa.expenditure_type,
         poa.task_id,
         poa.award_id,
         poa.gl_code_combination_id,
         poa.organization_account_id;

  cursor suspense_account_cur is
  select pdl.payroll_sub_line_id,
         decode(g_use_eff_date, 'Y', max(pdl.effective_date) ,
               max(pdl.distribution_date)) effective_date,   --- 5505041
         ppl.person_id,
         ppl.assignment_id,
         ppl.element_type_id,
         poa.project_id,
         poa.expenditure_organization_id,
         poa.expenditure_type,
         poa.task_id,
         poa.award_id,
         poa.gl_code_combination_id,
         poa.organization_account_id,
         ppl.payroll_action_type,
         ppl.cost_id
    from psp_distribution_lines pdl,
         psp_payroll_lines ppl,
         psp_payroll_sub_lines ppsl,
         psp_organization_accounts poa
   where ppl.payroll_control_id = p_payroll_control_id
     and ppl.assignment_id between p_start_asg_id and p_end_asg_id
     and ppl.payroll_line_id = ppsl.payroll_line_id
     and ppsl.payroll_sub_line_id = pdl.payroll_sub_line_id
     and pdl.suspense_org_account_id = poa.organization_account_id
     and pdl.adj_account_flag is null
group by ppl.cost_id,
         ppl.payroll_action_type,
         pdl.payroll_Sub_line_id,
         ppl.person_id,
         ppl.assignment_id,
         ppl.element_type_id ,
         poa.project_id,
         poa.expenditure_organization_id,
         poa.expenditure_type,
         poa.task_id,
         poa.award_id,
         poa.gl_code_combination_id,
         poa.organization_account_id;

  cursor global_elem_account_cur is
  select pdl.payroll_sub_line_id,
         decode(g_use_eff_date, 'Y', max(pdl.effective_date) ,
               max(pdl.distribution_date)) effective_date,   --- 5505041
         ppl.person_id,
         ppl.assignment_id,
         ppl.element_type_id,
         ele.project_id,
         ele.expenditure_organization_id,
         ele.expenditure_type,
         ele.task_id,
         ele.award_id,
         ele.gl_code_combination_id,
         ele.element_account_id,
         ppl.payroll_action_type,
         ppl.cost_id
    from psp_distribution_lines pdl,
         psp_payroll_lines ppl,
         psp_payroll_sub_lines ppsl,
         psp_element_type_accounts ele
   where ppl.payroll_control_id = p_payroll_control_id
     and ppl.assignment_id between p_start_asg_id and p_end_asg_id
     and ppl.payroll_line_id = ppsl.payroll_line_id
     and ppsl.payroll_sub_line_id = pdl.payroll_sub_line_id
     and pdl.suspense_org_account_id is null
     and pdl.element_account_id = ele.element_account_id
     and pdl.adj_account_flag is null
group by ppl.cost_id,
         ppl.payroll_action_type,
         pdl.payroll_Sub_line_id,
         ppl.person_id,
         ppl.assignment_id,
         ppl.element_type_id,
         ele.project_id,
         ele.expenditure_organization_id,
         ele.expenditure_type,
         ele.task_id,
         ele.award_id,
         ele.gl_code_combination_id,
         ele.element_account_id;

  l_dist_sql_string             VARCHAR2(4000);
  l_dist_amount                 NUMBER:=0;
  l_acct_type                   VARCHAR2(1);
  l_auto_pop_status		VARCHAR2(1);
  l_new_expenditure_type        VARCHAR2(30);
  l_new_gl_code_combination_id  NUMBER(15);
  l_auto_status                 VARCHAR2(20) := null;
  l_dist_line_id                NUMBER(9);
  l_linkage_status              VARCHAR2(50);
  l_patc_status                 VARCHAR2(50);
  x_proc_executed               VARCHAR2(10) := 'TRUE';
  l_billable_flag               VARCHAR2(1);
  l_mode                        VARCHAR2(1) := 'I';
  l_effective_date              DATE;
  l_return_status               VARCHAR2(1);
  l_dbg_ctr                     number :=0;
  l_msg_count                   NUMBER;
  l_msg_app                     VARCHAR2(2000);
  l_msg_type                    varchar2(2000);
  l_msg_token1                  varchar2(2000);
  l_msg_token2                  varchar2(2000);
  l_msg_token3                  varchar2(2000);
  l_award_status                varchar2(200);
  l_organization_name           varchar2(400);
  l_employee_name               varchar2(400);
  l_asg_num                     varchar2(400);
  l_account                     varchar2(800);
  l_prev_cost_id                integer;


  type ref_cur_type is ref cursor;
  dist_line_cur ref_cur_type;
  SUSPENSE_AUTOPOP_FAIL exception;
  cursor get_person_details (p_person_id in number,
                             p_assignment_id in number,
                             p_eff_date in date) is
   select ppf.full_name,
          paf.assignment_number,
          hou.name
     from per_all_people_f ppf,
          per_all_assignments_f paf,
          hr_all_organization_units hou
    where ppf.person_id = p_person_id
      and p_eff_date between ppf.effective_start_date and ppf.effective_end_date
      and paf.assignment_type = 'E'
      and paf.assignment_id = p_assignment_id
      and p_eff_date between paf.effective_start_date and paf.effective_end_date
      and paf.organization_id = hou.organization_id;
begin
hr_utility.trace('Entering generic_account_autopop');

if p_schedule_type = 'GLOBAL_ELEMENT' then
  open  global_elem_account_cur;
  fetch global_elem_account_cur bulk collect into t_payroll_sub_line_id,
                                                  t_effective_date     ,
                                                  t_person_id          ,
                                                  t_assignment_id      ,
                                                  t_element_type_id    ,
                                                  t_project_id         ,
                                                  t_expenditure_organization_id,
                                                  t_expenditure_type         ,
                                                  t_task_id                  ,
                                                  t_award_id                 ,
                                                  t_gl_code_combination_id   ,
                                                  t_account_id,
                                                  t_payroll_action_type,
                                                  t_cost_id;

  close global_elem_account_cur;
elsif p_schedule_type = 'DEFAULT_ACCOUNT' then
  open  org_default_account_cur;
  fetch org_default_account_cur bulk collect into t_payroll_sub_line_id,
                                                  t_effective_date     ,
                                                  t_person_id          ,
                                                  t_assignment_id      ,
                                                  t_element_type_id    ,
                                                  t_project_id         ,
                                                  t_expenditure_organization_id,
                                                  t_expenditure_type         ,
                                                  t_task_id                  ,
                                                  t_award_id                 ,
                                                  t_gl_code_combination_id   ,
                                                  t_account_id,
                                                  t_payroll_action_type,
                                                  t_cost_id;

  close org_default_account_cur;
else
  ---fnd_file.put_line(fnd_file.log, 'before suspense cursor');
  open  suspense_account_cur;
  fetch suspense_account_cur bulk collect into t_payroll_sub_line_id,
                                               t_effective_date     ,
                                               t_person_id          ,
                                               t_assignment_id      ,
                                               t_element_type_id    ,
                                               t_project_id         ,
                                               t_expenditure_organization_id,
                                               t_expenditure_type         ,
                                               t_task_id                  ,
                                               t_award_id                 ,
                                               t_gl_code_combination_id   ,
                                               t_account_id,
                                                  t_payroll_action_type,
                                                  t_cost_id;

  close suspense_account_cur;
end if;
if t_payroll_sub_line_id.count > 0 then
   if p_schedule_type = 'DEFAULT_ACCOUNT' then
     l_dist_sql_string :=
           'select pdl.distribution_line_id,
                   pdl.effective_date,
                   pdl.distribution_amount
              from psp_distribution_lines pdl
             where pdl.payroll_sub_line_id = :1
               and pdl.default_org_account_id = :2
               and pdl.suspense_org_account_id is null';
   elsif p_schedule_type = 'GLOBAL_ELEMENT' then
      l_dist_sql_string :=
              'select pdl.distribution_line_id,
                      pdl.effective_date,
                      pdl.distribution_amount
                 from psp_distribution_lines pdl
                where pdl.payroll_sub_line_id = :1
                  and pdl.element_account_id = :2
                  and pdl.suspense_org_account_id is null';
   else
      l_dist_sql_string :=
              'select pdl.distribution_line_id,
                      pdl.effective_date,
                      pdl.distribution_amount
                 from psp_distribution_lines pdl
                where pdl.payroll_sub_line_id = :1
                  and pdl.suspense_org_account_id = :2';
  ---#fnd_file.put_line(fnd_file.log, 'Suspense sql string l_dist_sql_string='||l_dist_sql_string||', count='||t_payroll_sub_line_id.count);
   end if;
end if;
   for i in 1..t_payroll_sub_line_id.count
   loop
      if t_gl_code_combination_id(i) is null then
          l_acct_type:='E';
      else
          l_acct_type:='N';
      end if;
      if nvl(t_payroll_action_type(i),'X') = 'L' then
        if nvl(l_prev_cost_id, -999) <> t_cost_id(i) then
            l_prev_cost_id :=  t_cost_id(i);
            g_retro_parent_element_id := nvl(get_retro_parent_element_id(t_cost_id(i)), t_element_type_id(i));
        end if;
            t_element_type_id(i) := g_retro_parent_element_id;
      end if;
  ---fnd_file.put_line(fnd_file.log, 'Generic_account_autopop.. Suspense.. before autopop call');
      psp_autopop.main(
                    p_acct_type                   => l_acct_type,
		    p_person_id                   => t_person_id(i),
	            p_assignment_id               => t_assignment_id(i),
		    p_element_type_id             => t_element_type_id(i),
		    p_project_id                  => t_project_id(i),
		    p_expenditure_organization_id => t_expenditure_organization_id(i),
		    p_task_id                     => t_task_id(i),
		    p_award_id                    => t_award_id(i),
                    p_expenditure_type            => t_expenditure_type(i),
		    p_gl_code_combination_id      => t_gl_code_combination_id(i),
		    p_payroll_date                => t_effective_date(i),
		    p_set_of_books_id             => p_set_of_books_id,
                    p_business_group_id           => p_business_group_id,
		    ret_expenditure_type          => l_new_expenditure_type,
		    ret_gl_code_combination_id    => l_new_gl_code_combination_id,
		    retcode 			  => l_auto_pop_status);
  ---fnd_file.put_line(fnd_file.log, 'Generic_account_autopop.. Suspense.. After autopop call');

    IF (l_auto_pop_status = FND_API.G_RET_STS_UNEXP_ERROR) OR
        (l_auto_pop_status = FND_API.G_RET_STS_ERROR) THEN
       IF l_auto_pop_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         if l_acct_type ='N'  then
              l_auto_status := 'AUTO_POP_NA_ERROR';
         else
              l_auto_status :='AUTO_POP_EXP_ERROR';
         end if;
       ELSIF l_auto_pop_status = FND_API.G_RET_STS_ERROR THEN
         l_auto_status := 'AUTO_POP_NO_VALUE';
       END IF;

      ----fnd_file.put_line(fnd_file.log,'error in  autopop main in generic_account_autopop code='||l_auto_status||' sched type='||p_Schedule_type);
      open dist_line_cur for l_dist_sql_string using t_payroll_sub_line_id(i), t_account_id(i);
      loop
         fetch dist_line_cur into l_dist_line_id, l_effective_date, l_dist_amount;
         if dist_line_cur%notfound then exit;
         else
            if p_schedule_type = 'SUSPENSE' then
                   open get_person_details(t_person_id(i), t_assignment_id(i), l_effective_date);
                   fetch get_person_details into l_employee_name, l_asg_num, l_organization_name;
                   close get_person_details;
                   hr_utility.trace('generic_account_autopop gl_ccid = '||t_gl_code_combination_id(i));
                   psp_enc_crt_xml.p_set_of_books_id := p_set_of_books_id;
                   psp_enc_crt_xml.p_business_group_id := p_business_group_id;
                   l_account :=
                     psp_enc_crt_xml.cf_charging_instformula(t_gl_code_combination_id(i),
                                                             t_project_id(i),
                                                             t_task_id(i),
                                                             t_award_id(i),
                                                             t_expenditure_organization_id(i),
                                                             t_expenditure_type(i));
                   fnd_message.set_name('PSP','PSP_SUSPENSE_AUTOPOP_FAIL');
                   fnd_message.set_token('ORG_NAME',l_organization_name);
                   fnd_message.set_token('EMPLOYEE_NAME',l_employee_name);
                   fnd_message.set_token('ASG_NUM',l_asg_num);
                   fnd_message.set_token('CHARGING_ACCOUNT',l_account);
                   fnd_message.set_token('AUTOPOP_ERROR',l_auto_status);
                   fnd_message.set_token('EFF_DATE',l_effective_date);
                   fnd_msg_pub.add;
                   raise suspense_autopop_fail;
            else
                suspense_account(
                         x_proc_executed,
                         t_person_id(i),
                         t_payroll_sub_line_id(i),
                         t_assignment_id(i),
                         l_effective_date,
                         l_dist_amount, -- will be distribution_amount
                         l_auto_status,
                         NULL,
                         NULL,
                         NULL,
                         NULL,
                         l_effective_date,
                         l_mode,
                         p_business_group_id,
                         p_set_of_books_id,
                         l_dist_line_id,
                         l_return_status);
                       IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                       END IF;
            end if;
       end if;
      end loop;
      close dist_line_cur;

   else   --- autopop is successful
      ----fnd_file.put_line(fnd_file.log,'SUCCESS in  autopop main in generic_account_autopop code='||l_auto_status);
    if l_acct_type= 'E' then
      open dist_line_cur for l_dist_sql_string using t_payroll_sub_line_id(i), t_account_id(i);
      loop
         fetch dist_line_cur into l_dist_line_id, l_effective_date, l_dist_amount;
         if dist_line_cur%notfound then exit;
         else

	    pa_transactions_pub.validate_transaction(
			x_project_id		=> t_project_id(i),
			x_task_id		=> t_task_id(i),
			x_ei_date		=> l_effective_date,
			x_expenditure_type	=> l_new_expenditure_type,
			x_non_labor_resource	=> null,
			x_person_id		=> t_person_id(i),
			x_incurred_by_org_id	=> t_expenditure_organization_id(i),
			x_calling_module	=> 'PSPLDCDB',
			x_msg_application	=> l_msg_app,
			x_msg_type		=> l_msg_type,
			x_msg_token1		=> l_msg_token1,
			x_msg_token2		=> l_msg_token2,
			x_msg_token3		=> l_msg_token3,
			x_msg_count		=> l_msg_count,
			x_msg_data		=> l_patc_status,
			x_billable_flag		=> l_billable_flag,
			p_sys_link_function     => 'ST');            --Bug 5639589: Added parameter


	     if t_award_id(i) is not null and l_patc_status is null
	     then
		 gms_transactions_pub.validate_transaction
				(t_project_id(i),
			   	t_task_id(i),
				t_award_id(i),
			   	l_new_expenditure_type,
				l_effective_date, ---p_payroll_start_date, Bug 1874696
				'PSPLDCDB',
				l_award_status);

                if l_award_status IS NOT NULL then
                        l_patc_status  := substr(l_award_status,1,50);
	        end if;
	     end if;
             IF ( l_patc_status IS NOT NULL ) OR
		(l_award_status is not null ) THEN
                   open get_person_details(t_person_id(i), t_assignment_id(i), l_effective_date);
                   fetch get_person_details into l_employee_name, l_asg_num, l_organization_name;
                   close get_person_details;
                   ---fnd_file.put_line(fnd_file.log,'failure in _autopop code='||l_auto_status||' person_id, asgid, edate='||
                        ---t_person_id(i)||' ,  '|| t_assignment_id(i)||' ,  '|| l_effective_date);

                if p_schedule_type = 'SUSPENSE' then
                    fnd_message.set_name('PSP','PSP_LD_SUSPENSE_AC_INVALID');
                    fnd_message.set_token('ORG_NAME',l_organization_name);
                    fnd_message.set_token('PATC_STATUS',l_patc_status);
                    fnd_message.set_token('EMPLOYEE_NAME',l_employee_name); --Bug 2514611
                    fnd_msg_pub.add;
                    raise suspense_autopop_fail;
                else
                    update psp_distribution_lines
                       set auto_expenditure_type  = l_new_expenditure_type
                     where distribution_line_id=l_dist_line_id;
                     suspense_account(
                           x_proc_executed,
                           t_person_id(i),
                           t_payroll_sub_line_id(i),
                           t_assignment_id(i),
                           l_effective_date,
                           l_dist_amount,
                           l_patc_status,
                           NULL,
                           NULL,
                           NULL,
                           NULL,
                           l_effective_date,
                           l_mode,
                           p_business_group_id,
                           p_set_of_books_id,
                           l_dist_line_id,
                           l_return_status);

                       IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                       END IF;
                  end if;
             else  -- linkage status is successful
                if p_schedule_type = 'SUSPENSE' then
                 update psp_distribution_lines
                    set suspense_auto_exp_type  = l_new_expenditure_type
                  where distribution_line_id=l_dist_line_id;
                else
                 update psp_distribution_lines
                    set auto_expenditure_type  = l_new_expenditure_type
                  where distribution_line_id=l_dist_line_id;
                 end if;

             end if;   -- patc status
        end if ;  -- dist_line_csr not found;
      end loop;
      close dist_line_cur;

    else   --  if natural account then
      ----fnd_file.put_line(fnd_file.log,'SUCCESS-NA in  autopop main in generic_account_autopop code='||l_auto_status);
      if p_schedule_type = 'SUSPENSE' then
          update psp_distribution_lines
             set suspense_auto_glccid  = l_new_gl_code_combination_id
          where payroll_sub_line_id = t_payroll_sub_line_id(i)
            and suspense_org_account_id = t_account_id(i);
       elsif p_schedule_type = 'GLOBAL_ELEMENT' then
          update psp_distribution_lines
             set auto_gl_code_combination_id  = l_new_gl_code_combination_id
          where payroll_sub_line_id = t_payroll_sub_line_id(i)
            and element_account_id = t_account_id(i)
            and suspense_org_account_id is null;
       else
          update psp_distribution_lines
             set auto_gl_code_combination_id  = l_new_gl_code_combination_id
          where payroll_sub_line_id = t_payroll_sub_line_id(i)
            and default_org_account_id= t_account_id(i)
            and suspense_org_account_id is null;
       end if;

     end if; -- end natural account
 end if;  -- end of autopop successful
 end loop;
 t_payroll_sub_line_id.delete;
 t_effective_date.delete;
 t_person_id.delete;
 t_assignment_id.delete;
 t_element_type_id.delete;
 t_project_id.delete;
 t_expenditure_organization_id.delete;
 t_expenditure_type.delete;
 t_task_id.delete;
 t_award_id.delete;
 t_gl_code_combination_id.delete;
 t_account_id.delete;
 t_payroll_action_type.delete;
 t_cost_id.delete;
                   ---fnd_file.put_line(fnd_file.log,'Xiting generic_account_autop');
exception
   when suspense_autopop_fail then
      t_payroll_sub_line_id.delete;
      t_effective_date.delete;
      t_person_id.delete;
      t_assignment_id.delete;
      t_element_type_id.delete;
      t_project_id.delete;
      t_expenditure_organization_id.delete;
      t_expenditure_type.delete;
      t_task_id.delete;
      t_award_id.delete;
      t_gl_code_combination_id.delete;
      t_account_id.delete;
      close dist_line_cur;
      fnd_msg_pub.add_exc_msg('PSB_LABOR_DIST','GENERIC_ACCOUNT_AUTOPOP');
      raise;
   when others then
      if dist_line_cur%isopen then
        close dist_line_cur;
      end if;
      if t_payroll_sub_line_id.count > 0 then
         t_payroll_sub_line_id.delete;
         t_effective_date.delete;
         t_person_id.delete;
         t_assignment_id.delete;
         t_element_type_id.delete;
         t_project_id.delete;
         t_expenditure_organization_id.delete;
         t_expenditure_type.delete;
         t_task_id.delete;
         t_award_id.delete;
         t_gl_code_combination_id.delete;
         t_account_id.delete;
      end if;
      fnd_msg_pub.add_exc_msg('PSB_LABOR_DIST','GENERIC_ACCOUNT_AUTOPOP:'||p_schedule_type);
      raise;
end generic_account_autopop;
------------------------------------------

   function get_parameter(name           in varchar2,
                          parameter_list in varchar2) return varchar2
   is
     start_ptr number;
     end_ptr   number;
     token_val pay_payroll_actions.legislative_parameters%type;
     par_value pay_payroll_actions.legislative_parameters%type;
   begin
        token_val := name||'=';
         ---dbms_output.put_line('CDL--> Get Param --> Token, Paramlist='||token_val||','||parameter_list);
         ---dbms_output.put_line('Paramlist='||parameter_list);
        start_ptr := instr(parameter_list, token_val) + length(token_val);
        if token_val in ('BATCH_NAME=','SOURCE_CODE=') then
         ---dbms_output.put_line('CDL--> Get Param --> BATCH_NAME start_ptr='||start_ptr);
          if start_ptr + 30 > length(parameter_list) then
              end_ptr := 0;
          else
              end_ptr := start_ptr + 30;
          end if;
        else
           end_ptr := instr(parameter_list, ' ',start_ptr);
        end if;
        if end_ptr = 0 then
           end_ptr := length(parameter_list)+1;
        end if;
         ---dbms_output.put_line('CDL-->Get param stptr, endptr = '||start_ptr||','|| end_ptr);
        if instr(parameter_list, token_val) = 0 then
          par_value := NULL;
        else
          par_value := trim(substr(parameter_list, start_ptr, end_ptr -
start_ptr));
        end if;
        return par_value;
   end get_parameter;

procedure cdl_init(p_payroll_action_id in number) IS
 --- introduced for 5080403
  cursor autopop_config_cur is
  select pcv_information1 global_element_autopop,
         pcv_information2 element_type_autopop,
         pcv_information3 element_class_autopop,
         pcv_information4 assignment_autopop,
         pcv_information5 default_schedule_autopop,
         pcv_information6 default_account_autopop,
         pcv_information7 suspense_account,
         pcv_information10 excess_account
    from pqp_configuration_values
   where pcv_information_category = 'PSP_ENABLE_AUTOPOPULATION'
     and legislation_code is null
     and nvl(business_group_id, g_business_group_id) = g_business_group_id;

begin
    ---hr_utility.trace_on('Y','CDL-1');
     select get_parameter('SOURCE_TYPE',ppa.legislative_parameters) ,
          get_parameter('SOURCE_CODE',ppa.legislative_parameters)  ,
          get_parameter('TIME_PERIOD_ID',ppa.legislative_parameters),
          get_parameter('BATCH_NAME',ppa.legislative_parameters),
          get_parameter('PAYROLL_ID',ppa.legislative_parameters)
     into g_source_type,
          g_source_code,
          g_time_period_id,
          g_batch_name,
          g_payroll_id
     from pay_payroll_actions ppa
    where ppa.payroll_action_id = p_payroll_action_id;

    if g_time_period_id is not null and g_payroll_id is null then
    select payroll_id
      into g_payroll_id
     from per_time_periods
    where time_period_id = g_time_period_id;
    end if;

 g_set_of_books_id :=  FND_PROFILE.VALUE('GL_SET_OF_BKS_ID');
 g_business_group_id  := FND_PROFILE.VALUE('PER_BUSINESS_GROUP_ID');
    --#fnd_file.put_line(fnd_file.log,'########CDL_INIT#######PACTID, g_business_group_id,  g_set_of_books_id ,g_source_type, g_time_period_id, g_batch_name=');
    --#fnd_file.put_line(fnd_file.log, p_payroll_action_id||','|| g_business_group_id||','||  g_set_of_books_id ||','||g_source_type||','|| psp_labor_dist.g_time_period_id||','|| g_batch_name);

-- moved from archive part .. 4744285, commented for 5080403 and introduced below cursor
  ---g_auto_population := FND_PROFILE.value('PSP_USE_AUTO_POPULATION');
   open autopop_config_cur;
   fetch autopop_config_cur into g_global_element_autopop,
                                 g_asg_element_autopop,
                                 g_asg_ele_group_autopop,
                                 g_asg_autopop,
                                 g_org_schedule_autopop,
                                 g_default_account_autopop,
                                 g_suspense_account_autopop,
                                 g_excess_account_autopop;
   close autopop_config_cur;

  --dbms_output.put_line('value of profile is '||g_auto_population);

  g_use_eff_date := FND_PROFILE.VALUE('PSP_USE_NON_ORACLE_EFFECTIVE_DATE'); /* bug 1874696 */

   g_dff_grouping_option := psp_general.get_act_dff_grouping_option(g_business_group_id);	-- Introduced for bug fix 2908859

   g_salary_cap_option := psp_general.get_configuration_option_value(g_business_group_id, 'PSP_ENABLE_SALARY_CAP');
   hr_utility.trace('CDL procedure: setting g_cap_element_set_id');
   if g_salary_cap_option = 'Y' then
     g_cap_element_set_id  := psp_general.get_configuration_option_value(g_business_group_id, 'PSP_CAP_ELEMENT_SET_ID');
     g_gen_excess_org_id :=   -- 4744285
            psp_general.get_configuration_option_value(g_business_group_id, 'PSP_GENERIC_EXCESS_ACCT_ORG');
   end if;
END;

procedure range_code (pactid IN NUMBER, sqlstr out nocopy varchar2) is

l_count integer;
l_begin_dist_date date;
l_end_dist_date date;
l_sponsor_code varchar2(10);
l_sponsor_name varchar2(200);
l_sponsor_id   integer;

cursor check_generic_excess(p_date in date,
                            p_excess_org_id in number,
                            p_business_group_id in number) is
select count(*)
  from psp_organization_accounts
 where account_type_code = 'ORG_EXCESS'
   and p_date between trunc(start_date_active) and trunc(end_date_active)
   and organization_id = p_excess_org_id
   and business_group_id = p_business_group_id ;

cursor get_min_max_dist_date is
                select min(ptp.start_date), max(ptp.end_date)
                  from psp_payroll_controls ppc,
                       per_time_periods ptp
                 where  ppc.source_type = g_source_type
                   and  ppc.payroll_source_code = g_source_code
                   and (ppc.batch_name = nvl(g_batch_name, ppc.batch_name)
                       or (ppc.batch_name is null and g_batch_name is null))
                   and  ppc.time_period_id = nvl(g_time_period_id, ppc.time_period_id)
                   and  ppc.payroll_id = nvl(g_payroll_id, ppc.payroll_id)
                   and  ppc.cdl_payroll_action_id = pactid
                   and  ppc.status_code = 'N'
                   and  ppc.dist_dr_amount is null
                   and  ppc.dist_cr_amount is null
                   and  ppc.business_group_id = g_business_group_id
                   and  ppc.set_of_books_id   = g_set_of_books_id
                   and  ptp.time_period_id = ppc.time_period_id;

cursor get_sponsor_codes(p_begin_date date) is
select distinct lookup_code, meaning
  from fnd_lookup_values
 where lookup_type = 'PSP_SPONSOR_NAMES'
   and language = 'US'
   and p_begin_date between start_date_active and  nvl(end_date_active, fnd_date.canonical_to_date('4000/01/31'))
   and enabled_flag = 'Y';

cursor check_salary_cap_exists(p_sponsor_code in varchar2,
                                       p_date in date) is
select 1
  from psp_salary_caps
 where funding_source_code = p_sponsor_code
   and p_date between start_date and end_date;

 l_error_flag varchar2(1);
 l_gen_excess_org_id number;   -- 4744285

 cursor get_control_ids is
 select payroll_control_id
   from psp_payroll_controls ppc
  where ppc.source_type = g_source_type
    and  ppc.payroll_source_code = g_source_code
    and (ppc.batch_name = nvl(g_batch_name, ppc.batch_name)
     or (ppc.batch_name is null and g_batch_name is null))
    and  ppc.time_period_id = nvl(g_time_period_id, ppc.time_period_id)
    and  ppc.payroll_id = nvl(g_payroll_id, ppc.payroll_id)
    and  ppc.cdl_payroll_action_id is null
    and  ppc.status_code = 'N'
    and  ppc.dist_dr_amount is null
    and  ppc.dist_cr_amount is null
    and  ppc.business_group_id = g_business_group_id
    and  ppc.parent_payroll_control_id is null
    and  ppc.set_of_books_id   = g_set_of_books_id;

 l_payroll_control_id integer;

begin
   --- hr_utility.trace_on('Y','CDL-2');
     select get_parameter('SOURCE_TYPE',ppa.legislative_parameters) ,
          get_parameter('SOURCE_CODE',ppa.legislative_parameters)  ,
          get_parameter('TIME_PERIOD_ID',ppa.legislative_parameters),
          get_parameter('BATCH_NAME',ppa.legislative_parameters),
          get_parameter('PAYROLL_ID',ppa.legislative_parameters)
     into g_source_type,
          g_source_code,
          g_time_period_id,
          g_batch_name,
          g_payroll_id
     from pay_payroll_actions ppa
    where ppa.payroll_action_id = pactid;

 g_business_group_id  := FND_PROFILE.VALUE('PER_BUSINESS_GROUP_ID');
 g_set_of_books_id :=  FND_PROFILE.VALUE('GL_SET_OF_BKS_ID');


    --#fnd_file.put_line(fnd_file.log,'########ENTERED RangeCode#######pactid, g_source_code='||pactid||','|| g_source_code);
 open get_control_ids;
 loop
    fetch get_control_ids into l_payroll_control_id;
    if get_control_ids%notfound then
           close get_control_ids;
           exit;
     end if;
     update psp_payroll_controls ppc
        set ppc.cdl_payroll_action_id = pactid
      where payroll_control_id = l_payroll_control_id
         or parent_payroll_control_id = l_payroll_control_id;
 end loop;

    if sql%rowcount > 0 then

 if psp_general.get_configuration_option_value(g_business_group_id, 'PSP_ENABLE_SALARY_CAP') = 'Y' then
   l_error_flag := 'N';

   hr_utility.trace('CDL process --> range_code --> source_type, source_code, time_period_id, batch_name = '||
      g_source_code||','||g_source_type||','||g_time_period_id||','||g_batch_name);

   open get_min_max_dist_date;
   fetch get_min_max_dist_date into l_begin_dist_date, l_end_dist_date;
   close get_min_max_dist_date;

   --fnd_file.put_line(fnd_file.log,'  l_begin_dist_date = '||l_begin_dist_date||' , l_end_dist_date='||l_end_dist_date);
   hr_utility.trace('CDL process --> range_code --> l_begin_dist_date = '||l_begin_dist_date);

   l_gen_excess_org_id :=   -- 4744285
   psp_general.get_configuration_option_value(g_business_group_id,
                                              'PSP_GENERIC_EXCESS_ACCT_ORG');
   if l_gen_excess_org_id is null then
      fnd_message.set_name('PSP','PSP_SET_GEN_EXCESS_ORG');
      fnd_msg_pub.add;
      l_error_flag := 'Y';
   else

      open check_generic_excess(l_begin_dist_date, l_gen_excess_org_id, g_business_group_id);
      fetch check_generic_excess into l_count;
      close check_generic_excess;

      if l_count = 0 then
         fnd_message.set_name('PSP', 'PSP_SET_GEN_EXCESS_ACNT');
         fnd_message.set_token('BDATE',l_begin_dist_date);
         fnd_msg_pub.add;
         l_error_flag := 'Y';
      else
         open check_generic_excess(l_end_dist_date, l_gen_excess_org_id, g_business_group_id);
         fetch check_generic_excess into l_count;
         close check_generic_excess;

         if l_count = 0 then
            fnd_message.set_name('PSP', 'PSP_SET_GEN_EXCESS_ACNT');
            fnd_message.set_token('BDATE',l_end_dist_date);
            fnd_msg_pub.add;
            l_error_flag := 'Y';
         end if;
      end if;
    end if;

   open get_sponsor_codes(l_begin_dist_date);
   loop

       fetch get_sponsor_codes into l_sponsor_code, l_sponsor_name;

      if get_sponsor_codes%notfound then
         close get_sponsor_codes;
         exit;
      end if;

       -- replaced the cursor get_map_sponsor, with following function call
       l_sponsor_id := null;
       l_sponsor_id := psp_general.get_configuration_option_value(g_business_group_id,
                                       'PSP_SET_SPONSORS_FOR_CAPPING', l_sponsor_code);
      if l_sponsor_id is null then
         l_error_flag := 'Y';
         fnd_message.set_name('PSP', 'PSP_MAP_SAL_CAP_SPONSOR');
         fnd_message.set_token('SPONSOR_NAME', l_sponsor_name);
         fnd_msg_pub.add;
      end if;

      open check_salary_cap_exists(l_sponsor_code, l_begin_dist_date);
      fetch check_salary_cap_exists into l_count;
      if check_salary_cap_exists%notfound then
         l_error_flag := 'Y';
         fnd_message.set_name('PSP', 'PSP_NO_SALARY_CAP_DATA');
         fnd_message.set_token('SPONSOR_NAME', l_sponsor_name);
         fnd_message.set_token('XDATE', l_begin_dist_date);
         fnd_message.set_token('BDATE', l_begin_dist_date);
         fnd_message.set_token('EDATE', l_end_dist_date);
         fnd_msg_pub.add;
         close check_salary_cap_exists;
      else
         close check_salary_cap_exists;
         open check_salary_cap_exists(l_sponsor_code, l_end_dist_date);
         fetch check_salary_cap_exists into l_count;
         if check_salary_cap_exists%notfound then
            l_error_flag := 'Y';
            fnd_message.set_name('PSP', 'PSP_NO_SALARY_CAP_DATA');
            fnd_message.set_token('SPONSOR_NAME', l_sponsor_name);
            fnd_message.set_token('XDATE', l_end_dist_date);
            fnd_message.set_token('BDATE', l_begin_dist_date);
            fnd_message.set_token('EDATE', l_end_dist_date);
            fnd_msg_pub.add;
         end if;
         close check_salary_cap_exists;
      end if;
    end loop;

  if l_error_flag = 'Y' then
      psp_message_s.print_error(p_mode => FND_FILE.LOG,
                                p_print_header => FND_API.G_TRUE);
    rollback;
    raise fnd_api.g_exc_unexpected_error;
  end if;
 end if;
     g_time_period_id := nvl(g_time_period_id, -999);
     g_payroll_id     := nvl(g_payroll_id, -999);

     --- introduced distinct for 4614640
     sqlstr := 'select distinct ppl.assignment_id
                  from psp_payroll_lines ppl,
                       psp_payroll_controls ppc
                 where ppc.payroll_control_id = ppl.payroll_control_id
                   and  ppc.cdl_payroll_action_id = :payroll_action_id
                 order by ppl.assignment_id';

--- comment it
   --- fnd_file.put_line(fnd_file.log,' sqlstr ='||sqlstr);
    else
          fnd_msg_pub.add_exc_msg('PSB_LABOR_DIST','RANGE_CODE-NO RECORDS');
          psp_message_s.print_error(p_mode => FND_FILE.LOG,
                                    p_print_header => FND_API.G_TRUE);
          raise fnd_api.g_exc_unexpected_error;
    end if;


end range_code;

procedure cdl_archive(p_payroll_action_id in number,
                           p_chunk_number in number) IS

  l_start_asg integer;
  l_end_asg   integer;
  errBuf      varchar2(240);
  retcode     varchar2(1);

  cursor get_chunk_status is
   select action_status
     from pay_temp_object_actions
    where payroll_action_id = p_payroll_action_id
      and chunk_number = p_chunk_number;

  l_chunk_status varchar2(10);

Begin

  open get_chunk_status;
  fetch get_chunk_status into l_chunk_status;

   hr_utility.trace('CHUNK_STATUS = '||l_chunk_status);
  if l_chunk_status <> 'C' then

    hr_utility.trace('########START_ARCHIVE##### g_source_type, g_source_code, g_payroll_id, g_time_period_id, g_batch_name, g_business_group_id, l_chunk_status)='|| g_source_type||','||
                               g_source_code||','||
                               g_payroll_id||','||
                               g_time_period_id||','||
                               g_batch_name||','||
                               g_business_group_id||','||
                               g_set_of_books_id||','||
                               g_set_of_books_id||','||l_chunk_status);


  select min(object_id), max(object_id)
    into l_start_asg, l_end_asg
    from pay_temp_object_actions
   where payroll_action_id = p_payroll_action_id
     and chunk_number = p_chunk_number;

  --#fnd_file.put_line(fnd_file.log,'ENTERED ARCHIVE start, end asg='||l_start_asg||','||l_end_asg);
  ---#fnd_file.put_line(fnd_file.log,'ENTERED ARCHIVE start, end asg='||l_start_asg||','||l_end_asg||' chunk_number='||p_chunk_number);

/*
   --- #fnd_file.put_line(fnd_file.log,'########START_ARCHIVE##### g_source_type, g_source_code, g_payroll_id, g_time_period_id, g_batch_name, g_business_group_id, l_chunk_status)='|| g_source_type||','||
                               g_source_code||','||
                               g_payroll_id||','||
                               g_time_period_id||','||
                               g_batch_name||','||
                               g_business_group_id||','||
                               g_set_of_books_id||','||
                               g_set_of_books_id||','||l_chunk_status);  */

   psp_labor_dist.g_payroll_action_id := p_payroll_Action_id;
   psp_labor_dist.create_lines(errbuf  ,
                               retcode ,
                               g_source_type,
                               g_source_code,
                               g_payroll_id,
                               g_time_period_id,
                               g_batch_name,
                               g_business_group_id,
                               g_set_of_books_id,
                               l_start_asg,
                               l_end_asg);
   /*if 12467 between l_start_asg and l_end_asg then
    hr_utility.trace('########START_ARCHIVE#####SLEEP');
       raise no_data_found;
   end if;   */
end if;
close get_chunk_status;
End;
procedure asg_action_code (p_pactid IN NUMBER,
                           stasg IN NUMBER,
                           endasg IN NUMBER,
                           p_chunk_num IN NUMBER) IS

l_asgactid  number;

cursor get_assignments(p_pactid number, stasg number, endasg number,
p_time_period_id number)  is
select  distinct ppl.assignment_id
  FROM   psp_payroll_controls ppc,
         psp_payroll_lines ppl
 WHERE   ppc.business_group_id = g_business_group_id
  AND    ppc.set_of_books_id   = g_set_of_books_id
  AND    ppc.source_type = nvl(g_source_type,ppc.source_type)
  AND    ppc.payroll_source_code = nvl(g_source_code,ppc.payroll_source_code)
  AND    ppc.time_period_id <= nvl(p_time_period_id, ppc.time_period_id)   -- Bug 6733614
  AND    ppc.payroll_id = nvl(g_payroll_id, ppc.payroll_id)
  AND    nvl(ppc.batch_name,'N') = nvl(nvl(g_batch_name,ppc.batch_name),'N')
  AND    (ppc.sublines_dr_amount IS NOT NULL OR ppc.sublines_cr_amount IS NOT NULL)
  AND    (ppc.dist_dr_amount IS NULL AND ppc.dist_cr_amount IS NULL)
  AND    ppl.payroll_control_id = ppc.payroll_control_id
  AND    ppl.assignment_id between stasg and endasg;
begin
     select get_parameter('SOURCE_TYPE',ppa.legislative_parameters) ,
          get_parameter('SOURCE_CODE',ppa.legislative_parameters)  ,
          get_parameter('TIME_PERIOD_ID',ppa.legislative_parameters),
          get_parameter('BATCH_NAME',ppa.legislative_parameters),
          get_parameter('PAYROLL_ID',ppa.legislative_parameters)
     into g_source_type,
          g_source_code,
          g_time_period_id,
          g_batch_name,
          g_payroll_id
     from pay_payroll_actions ppa
    where ppa.payroll_action_id = p_pactid;

    if g_time_period_id is not null and g_payroll_id is null then
    --#fnd_file.put_line(fnd_file.log,'########AssignCode2#######');
    select payroll_id
      into g_payroll_id
     from per_time_periods
    where time_period_id = g_time_period_id;
    end if;
 g_business_group_id  := FND_PROFILE.VALUE('PER_BUSINESS_GROUP_ID');
 g_set_of_books_id :=  FND_PROFILE.VALUE('GL_SET_OF_BKS_ID');
    --#fnd_file.put_line(fnd_file.log,'########asg_action_code#######PACTID, g_business_group_id,  g_set_of_books_id ,g_source_type, g_time_period_id, g_batch_name=');
    --#fnd_file.put_line(fnd_file.log,p_pactid||','|| g_business_group_id||','||  g_set_of_books_id ||','||g_source_type||','|| psp_labor_dist.g_time_period_id||','|| g_batch_name);

  open get_assignments(p_pactid, stasg, endasg, psp_labor_dist.g_time_period_id);
  fetch get_assignments bulk collect into t_asg_array;
  close get_assignments;
  for i in 1..t_asg_array.count
  loop
    --#fnd_file.put_line(fnd_file.log,'########asg_action_code#######PACTID, asg_id='||p_pactid||','|| t_asg_array(i));
  select pay_assignment_actions_s.nextval into l_asgactid from dual;

  hr_nonrun_asact.insact( l_asgactid ,
                          pactid =>       p_pactid,
                          chunk =>        p_chunk_num,
                          object_id =>    t_asg_array(i),
                          object_type =>      'ASG',
                          p_transient_action =>      TRUE);
  end loop;
 --#fnd_file.put_line(fnd_file.log,'leaving asg action');

end;

procedure deinit_code(pactid in number) as

  CURSOR payroll_control_cur IS
  SELECT payroll_control_id
  FROM   psp_payroll_controls
  WHERE  cdl_payroll_action_id = pactid;

  l_total_dist_dr_amount number;
  l_total_dist_cr_amount number;
  payroll_control_rec payroll_control_cur%rowtype;
  l_count_fail_actions integer;

begin
   select get_parameter('SOURCE_TYPE',ppa.legislative_parameters) ,
          get_parameter('SOURCE_CODE',ppa.legislative_parameters)  ,
          get_parameter('TIME_PERIOD_ID',ppa.legislative_parameters),
          get_parameter('BATCH_NAME',ppa.legislative_parameters),
          get_parameter('PAYROLL_ID',ppa.legislative_parameters)
     into g_source_type,
          g_source_code,
          g_time_period_id,
          g_batch_name,
          g_payroll_id
     from pay_payroll_actions ppa
    where ppa.payroll_action_id = pactid;

    g_business_group_id  := FND_PROFILE.VALUE('PER_BUSINESS_GROUP_ID');
    g_set_of_books_id :=  FND_PROFILE.VALUE('GL_SET_OF_BKS_ID');
    --#fnd_file.put_line(fnd_file.log,'DEINIT source_type ='||g_source_type);
    --#fnd_file.put_line(fnd_file.log,'DEINIT source_code ='||g_source_code);
    --#fnd_file.put_line(fnd_file.log,'DEINIT batch_name ='||g_batch_name);
    --#fnd_file.put_line(fnd_file.log,'DEINIT payroll_id ='||g_payroll_id);
    --#fnd_file.put_line(fnd_file.log,'DEINIT time_period_id ='||g_time_period_id);
    --#fnd_file.put_line(fnd_file.log,'DEINIT set_of_books ='||g_business_group_id);
    --#fnd_file.put_line(fnd_file.log,'DEINIT bg_id ='||g_set_of_books_id);


  select count(*)
   into  l_count_fail_actions
   from  pay_payroll_actions
  where  payroll_action_id = pactid
    and  action_status <> 'C';

  if l_count_fail_actions = 0 then

   select count(*)
     into l_count_fail_actions
     from pay_temp_object_actions
    where payroll_action_id = pactid
      and action_status <> 'C';

  end if;


  --#fnd_file.put_line(fnd_file.log,'########entered deinit#######');
  hr_utility.trace('CDL process --> deinit action_status ='||l_count_fail_actions);

 if l_count_fail_actions = 0 then
open payroll_control_cur;
loop
   fetch payroll_control_cur into payroll_control_rec;
   if payroll_control_cur%notfound then
     close payroll_control_cur;
     exit;
   end if;
   SELECT nvl(sum(distribution_amount),0)
   INTO l_total_dist_dr_amount
   FROM psp_distribution_lines  pdl,
        psp_payroll_sub_lines   ppsl,
        psp_payroll_lines       ppl,
        psp_payroll_controls    ppc
   WHERE ppc.payroll_control_id = payroll_control_rec.payroll_control_id
   AND   ppc.payroll_control_id = ppl.payroll_control_id
   AND   ppl.payroll_line_id = ppsl.payroll_line_id
   AND   ppsl.payroll_sub_line_id = pdl.payroll_sub_line_id
   AND   pdl.reversal_entry_flag IS NULL
   AND   ppl.dr_cr_flag = 'D';

   SELECT nvl(sum(distribution_amount),0)
   INTO l_total_dist_cr_amount
   FROM psp_distribution_lines  pdl,
        psp_payroll_sub_lines   ppsl,
        psp_payroll_lines       ppl,
        psp_payroll_controls    ppc
   WHERE ppc.payroll_control_id = payroll_control_rec.payroll_control_id
   AND   ppc.payroll_control_id = ppl.payroll_control_id
   AND   ppl.payroll_line_id = ppsl.payroll_line_id
   AND   ppsl.payroll_sub_line_id = pdl.payroll_sub_line_id
   AND   pdl.reversal_entry_flag IS NULL
   AND   ppl.dr_cr_flag = 'C';

   UPDATE psp_payroll_controls
   SET dist_dr_amount = l_total_dist_dr_amount,
       dist_cr_amount = l_total_dist_cr_amount
   WHERE payroll_control_id = payroll_control_rec.payroll_control_id;
end loop;
end if;

end;
function get_retro_parent_element_id(p_cost_id integer) return integer is
  cursor retro_parent_cur is
  select epd.source_element_type_id
    from pay_entry_process_details epd,
         pay_run_results prr,
         pay_costs pc
   where epd.element_entry_id = prr.source_id
     and prr.run_result_id = pc.run_result_id
     and pc.cost_id = p_cost_id;
begin
   g_retro_parent_element_id := null;
   open retro_parent_cur;
   fetch retro_parent_cur into g_retro_parent_element_id;
   close retro_parent_cur;
   return g_retro_parent_element_id;
end get_retro_parent_element_id;


END PSP_LABOR_DIST;

/

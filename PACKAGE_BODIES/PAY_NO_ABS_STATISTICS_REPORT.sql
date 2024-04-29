--------------------------------------------------------
--  DDL for Package Body PAY_NO_ABS_STATISTICS_REPORT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_NO_ABS_STATISTICS_REPORT" AS
/* $Header: pynoabsr.pkb 120.0.12000000.1 2007/05/22 05:47:46 rajesrin noship $ */
    	absmale abstab;
	absfemale abstab;
	abstotal abstab;
   FUNCTION get_archive_payroll_action_id (p_payroll_action_id IN NUMBER)
      RETURN NUMBER
   IS
      l_payroll_action_id   NUMBER;
   BEGIN
      IF p_payroll_action_id IS NULL
      THEN
         BEGIN
            SELECT payroll_action_id
              INTO l_payroll_action_id
              FROM pay_payroll_actions ppa,
                   fnd_conc_req_summary_v fcrs,
                   fnd_conc_req_summary_v fcrs1
             WHERE fcrs.request_id = fnd_global.conc_request_id
               AND fcrs.priority_request_id = fcrs1.priority_request_id
               AND ppa.request_id BETWEEN fcrs1.request_id
                                      AND fcrs.request_id
               AND ppa.request_id = fcrs1.request_id;
         EXCEPTION
            WHEN OTHERS
            THEN
               NULL;
         END;
      ELSE
         l_payroll_action_id := p_payroll_action_id;
      END IF;
      RETURN l_payroll_action_id;
   END;
   PROCEDURE get_data (
      p_business_group_id  in varchar2,
      p_payroll_action_id   IN              VARCHAR2,
      p_template_name       IN              VARCHAR2,
      p_xml                 OUT NOCOPY      CLOB
   )
   IS
      /*  Start of declaration*/
      -- Variables needed for the report
      l_sum                 NUMBER;
      l_counter             NUMBER  := 1;
      l_payroll_action_id   pay_action_information.action_information1%TYPE;
      l_legal_employer_id number;
      l_legal_employer HR_ORGANIZATION_UNITS.name%type;
      l_quater VARCHAR2(3);
      l_quater_flag VARCHAR2(2):='Y';
      l_quater_count NUMBER:=0;
      l_actual_working_days NUMBER;
      l_absent_days NUMBER;
      l_sickness_percentage NUMBER;
      l_effective_date date;

      CURSOR csr_legal_employer is select o.name,fnd_date.canonical_to_date(pai.action_information5) action_information5
      				   from
					HR_ORGANIZATION_UNITS o,
					HR_ORGANIZATION_INFORMATION hoi1,
					pay_action_information pai
					where pai.action_context_id = l_payroll_action_id
					and pai.action_information_category ='EMEA REPORT DETAILS'
					and o.organization_id = pai.action_information2
					and hoi1.organization_id = o.organization_id
					and hoi1.org_information_context = 'CLASS'
					and hoi1.org_information1 = 'HR_LEGAL_EMPLOYER';

      CURSOR csr_abs_stat_data (csr_v_pa_id IN VARCHAR2)
            IS
            select  pai.action_information1 report_type,
                    pai.action_information3 quater,
                    pai.action_information4 possible_working_days,
                    pai.action_information5 sex,
                    pai.action_information6 occur_1_3_days_sc,
                    pai.action_information7 sc_1_3_abs_days,
                    pai.action_information8 dc_1_3_days_Occur,
                    pai.action_information9 dc_1_3_abs_days,
                    pai.action_information10 sick_4_16_days_Occur,
                    pai.action_information11 sick_4_16_abs_days,
                    pai.action_information12 More_Than_16days_Occur,
                    pai.action_information13 More_Than_16days_Abs,
                    pai.action_information14 Child_Minders_Ocrs,
                    pai.action_information15 Child_Minders_Days,
                    pai.action_information16 Paternal_Leave_ocrs,
                    pai.action_information17 Paternal_leave_days,
                    pai.action_information18 other_leave_ocrs,
                    pai.action_information19 other_leave_days,
                    pai.action_information20 sick_more_8w_ocrs,
                    pai.action_information21 sick_more_8w_days,
                    pai.action_information22 other_abs_paid_ocrs,
                    pai.action_information23 other_abs_paid_days,
                    pai.action_information24 business_group_id
            from pay_action_information pai
            where pai.action_context_id = csr_v_pa_id
            and action_information_category ='EMEA REPORT INFORMATION'
	    and action_information1 = 'PYNOABSA'
	    order by pai.action_information3;

   BEGIN

      l_payroll_action_id :=  get_archive_payroll_action_id (p_payroll_action_id);

      open csr_legal_employer;
      fetch csr_legal_employer into l_legal_employer,l_effective_date;
      close csr_legal_employer;

	absmale(0).initialized:='N';
	absfemale(0).initialized:='N';
	abstotal(0).initialized:='N';
	abstotal(1).initialized:='N';
	abstotal(2).initialized:='N';
	abstotal(3).initialized:='N';
	abstotal(4).initialized:='N';

      gplsqltable (0).tagname := 'LEGAL_EMPLOYER';
      gplsqltable (0).tagvalue := l_legal_employer;
	gplsqltable (l_counter).tagname := 'EFFECTIVE_DATE';
	gplsqltable (l_counter).tagvalue := to_char(l_effective_date,'DD.Mon.YYYY');
	l_counter := l_counter+ 1;
      FOR csr_abs_stat_datas IN csr_abs_stat_data (l_payroll_action_id)
      LOOP
	 IF l_quater_flag = 'Y' THEN
	    l_quater := csr_abs_stat_datas.quater;
	    l_quater_flag := 'N';
	 END IF;
	 IF l_quater <> csr_abs_stat_datas.quater THEN

	        l_actual_working_days := nvl(abstotal(l_quater_count).possible_working_days,0)
	        				- nvl(abstotal(l_quater_count).sick_1_3_days_sc,0)
	        				- nvl(abstotal(l_quater_count).sick_1_3_days_dc,0)
	        				- nvl(abstotal(l_quater_count).sick_4_16_days,0)
	        				- nvl(abstotal(l_quater_count).sick_more_16_days,0)
	        				- nvl(abstotal(l_quater_count).cms_abs_days,0)
	        				- nvl(abstotal(l_quater_count).parental_abs_days,0)
	        				- nvl(abstotal(l_quater_count).other_abs_days,0)
	        				- nvl(abstotal(l_quater_count).other_abs_paid_days,0);

	        l_absent_days := nvl(abstotal(l_quater_count).sick_1_3_days_sc,0)
	        				+ nvl(abstotal(l_quater_count).sick_1_3_days_dc,0)
	        				+ nvl(abstotal(l_quater_count).sick_4_16_days,0)
	        				+ nvl(abstotal(l_quater_count).sick_more_16_days,0);

      		If nvl(abstotal(l_quater_count).possible_working_days,0) <> 0 then
      			l_sickness_percentage := (l_absent_days /abstotal(l_quater_count).possible_working_days)*100;
	        end if;

	 	gplsqltable (l_counter).tagname := 'QUARTER';
		gplsqltable (l_counter).tagvalue := l_quater;
		l_counter := l_counter+ 1;

		 gplsqltable (l_counter).tagname := 'START';
		 gplsqltable (l_counter).tagvalue:= 'START';
		 l_counter :=   l_counter+ 1;
		 gplsqltable (l_counter).tagname :=  'Q_SEX';
		 gplsqltable (l_counter).tagvalue:= abstotal(l_quater_count).quatertag||' '||l_quater;
		 l_counter :=   l_counter+ 1;

		 l_quater := csr_abs_stat_datas.quater;

		 gplsqltable (l_counter).tagname := 'Q_POSSIBLE_WORKING_DAYS';
		 gplsqltable (l_counter).tagvalue:= round(abstotal(l_quater_count).possible_working_days);
		 l_counter :=   l_counter + 1;
		 gplsqltable (l_counter).tagname := 'Q_ACTUAL_WORKING_DAYS';
		 gplsqltable (l_counter).tagvalue:= round(l_actual_working_days);
		 l_counter :=   l_counter + 1;
		 gplsqltable (l_counter).tagname := 'Q_OCCUR_1_3_DAYS_SC';
		 gplsqltable (l_counter).tagvalue := abstotal(l_quater_count).sick_1_3_ocr_sc;
		 l_counter :=   l_counter + 1;
		 gplsqltable (l_counter).tagname := 'Q_SC_1_3_ABS_DAYS';
		 gplsqltable (l_counter).tagvalue := round(abstotal(l_quater_count).sick_1_3_days_sc);
		 l_counter :=   l_counter + 1;
		 gplsqltable (l_counter).tagname := 'Q_DC_1_3_DAYS_OCCUR';
		 gplsqltable (l_counter).tagvalue:= abstotal(l_quater_count).sick_1_3_ocr_dc;
		 l_counter :=   l_counter + 1;
		 gplsqltable (l_counter).tagname := 'Q_DC_1_3_ABS_DAYS';
		 gplsqltable (l_counter).tagvalue := round(abstotal(l_quater_count).sick_1_3_days_dc);
		 l_counter :=   l_counter + 1;
		 gplsqltable (l_counter).tagname := 'Q_SICK_4_16_DAYS_OCCUR';
		 gplsqltable (l_counter).tagvalue:= abstotal(l_quater_count).sick_4_16_ocrs;
		 l_counter :=   l_counter+ 1;
		 gplsqltable (l_counter).tagname := 'Q_SICK_4_16_ABS_DAYS';
		 gplsqltable (l_counter).tagvalue:= round(abstotal(l_quater_count).sick_4_16_days);
		 l_counter :=   l_counter + 1;
		 gplsqltable (l_counter).tagname := 'Q_MORE_THAN_16DAYS_OCCUR';
		 gplsqltable (l_counter).tagvalue := abstotal(l_quater_count).sick_more_16_ocrs;
		 l_counter :=   l_counter + 1;
		 gplsqltable (l_counter).tagname := 'Q_MORE_THAN_16DAYS_ABS';
		 gplsqltable (l_counter).tagvalue := round(abstotal(l_quater_count).sick_more_16_days);
		 l_counter :=   l_counter + 1;

		 gplsqltable (l_counter).tagname := 'Q_MORE_THAN_8W_OCCUR';
		 gplsqltable (l_counter).tagvalue := abstotal(l_quater_count).sick_more_8w_ocrs;
		 l_counter :=   l_counter + 1;

		 gplsqltable (l_counter).tagname := 'Q_MORE_THAN_8W_DAYS';
		 gplsqltable (l_counter).tagvalue := round(abstotal(l_quater_count).sick_more_8w_days);
		 l_counter :=   l_counter + 1;

		 gplsqltable (l_counter).tagname := 'Q_CHILD_MINDERS_OCRS';
		 gplsqltable (l_counter).tagvalue := abstotal(l_quater_count).cms_abs_ocrs;
		 l_counter :=   l_counter + 1;
		 gplsqltable (l_counter).tagname := 'Q_CHILD_MINDERS_DAYS';
		 gplsqltable (l_counter).tagvalue := round(abstotal(l_quater_count).cms_abs_days);
		 l_counter :=   l_counter + 1;
		 gplsqltable (l_counter).tagname := 'Q_PATERNAL_LEAVE_OCRS';
		 gplsqltable (l_counter).tagvalue := abstotal(l_quater_count).parental_abs_ocrs;
		 l_counter :=   l_counter + 1;
		 gplsqltable (l_counter).tagname := 'Q_PATERNAL_LEAVE_DAYS';
		 gplsqltable (l_counter).tagvalue := round(abstotal(l_quater_count).parental_abs_days);
		 l_counter :=   l_counter + 1;
		 gplsqltable (l_counter).tagname := 'Q_OTHER_LEAVE_OCRS';
		 gplsqltable (l_counter).tagvalue := abstotal(l_quater_count).other_abs_ocrs;
		 l_counter :=   l_counter + 1;
		 gplsqltable (l_counter).tagname := 'Q_OTHER_LEAVE_DAYS';
		 gplsqltable (l_counter).tagvalue := round(abstotal(l_quater_count).other_abs_days);
		 l_counter :=   l_counter + 1;

		 gplsqltable (l_counter).tagname := 'Q_OTHER_PAID_LEAVE_OCRS';
		 gplsqltable (l_counter).tagvalue := abstotal(l_quater_count).other_abs_paid_ocrs;
		 l_counter :=   l_counter + 1;
		 gplsqltable (l_counter).tagname := 'Q_OTHER_PAID_LEAVE_DAYS';
		 gplsqltable (l_counter).tagvalue := round(abstotal(l_quater_count).other_abs_paid_days);
		 l_counter :=   l_counter + 1;

		 gplsqltable (l_counter).tagname := 'Q_SICK_PERCENTAGE';
		 gplsqltable (l_counter).tagvalue := round(l_sickness_percentage,1);
		 l_counter :=   l_counter + 1;

		 gplsqltable (l_counter).tagname := 'END';
		 gplsqltable (l_counter).tagvalue := 'END';
		 l_counter :=   l_counter + 1;
	 END IF;
	 l_quater_count := to_number(substr(csr_abs_stat_datas.quater,2))-1;

	 l_actual_working_days := nvl(csr_abs_stat_datas.possible_working_days,0)
	 	        				- nvl(csr_abs_stat_datas.sc_1_3_abs_days,0)
	 	        				- nvl(csr_abs_stat_datas.dc_1_3_abs_days,0)
	 	        				- nvl(csr_abs_stat_datas.sick_4_16_Abs_Days,0)
	 	        				- nvl(csr_abs_stat_datas.More_Than_16days_Abs,0)
	 	        				- nvl(csr_abs_stat_datas.Child_Minders_Days,0)
	 	        				- nvl(csr_abs_stat_datas.Paternal_leave_days,0)
	        					- nvl(csr_abs_stat_datas.other_leave_days,0)
	        					- nvl(csr_abs_stat_datas.other_abs_paid_days,0);


	l_absent_days := nvl(csr_abs_stat_datas.sc_1_3_abs_days,0)
	 	        				+ nvl(csr_abs_stat_datas.dc_1_3_abs_days,0)
	 	        				+ nvl(csr_abs_stat_datas.sick_4_16_Abs_Days,0)
	 	        				+ nvl(csr_abs_stat_datas.More_Than_16days_Abs,0);

      	If nvl(csr_abs_stat_datas.possible_working_days,0) <> 0 then
      	  l_sickness_percentage := (l_absent_days /nvl(csr_abs_stat_datas.possible_working_days,0))*100;
      	End if;


         abstotal(4).initialized:='Y';
	 abstotal(4).quatertag:= hr_general.decode_lookup('NO_FORM_LABELS','ASR04');
	 gplsqltable (l_counter).tagname := 'QUARTER';
	 gplsqltable (l_counter).tagvalue := csr_abs_stat_datas.quater;
	 l_counter := l_counter+ 1;
         gplsqltable (l_counter).tagname := 'START';
         gplsqltable (l_counter).tagvalue := 'START';
         l_counter :=   l_counter+ 1;
         gplsqltable (l_counter).tagname := csr_abs_stat_datas.sex||'_SEX';
         gplsqltable (l_counter).tagvalue := hr_general.decode_lookup('SEX',csr_abs_stat_datas.sex);
         l_counter :=   l_counter+ 1;
         gplsqltable (l_counter).tagname  := csr_abs_stat_datas.sex||'_POSSIBLE_WORKING_DAYS';
         gplsqltable (l_counter).tagvalue := csr_abs_stat_datas.possible_working_days;
         abstotal(4).possible_working_days:=nvl(abstotal(4).possible_working_days,0)+nvl(csr_abs_stat_datas.possible_working_days,0);
         l_counter :=   l_counter + 1;

         gplsqltable (l_counter).tagname  := csr_abs_stat_datas.sex||'_ACTUAL_WORKING_DAYS';
	 gplsqltable (l_counter).tagvalue := l_actual_working_days;
	 l_counter :=   l_counter + 1;

         gplsqltable (l_counter).tagname := csr_abs_stat_datas.sex||'_OCCUR_1_3_DAYS_SC';
         gplsqltable (l_counter).tagvalue:= csr_abs_stat_datas.occur_1_3_days_sc;
         abstotal(4).sick_1_3_ocr_sc	 :=nvl(abstotal(4).sick_1_3_ocr_sc,0)+nvl(csr_abs_stat_datas.occur_1_3_days_sc,0);
         l_counter :=   l_counter + 1;
         gplsqltable (l_counter).tagname := csr_abs_stat_datas.sex||'_SC_1_3_ABS_DAYS';
         gplsqltable (l_counter).tagvalue:= csr_abs_stat_datas.sc_1_3_abs_days;
         abstotal(4).sick_1_3_days_sc	 := nvl(abstotal(4).sick_1_3_days_sc,0)+nvl(csr_abs_stat_datas.sc_1_3_abs_days,0);
         l_counter :=   l_counter + 1;
         gplsqltable (l_counter).tagname := csr_abs_stat_datas.sex||'_DC_1_3_DAYS_OCCUR';
         gplsqltable (l_counter).tagvalue:=csr_abs_stat_datas.dc_1_3_days_Occur;
         abstotal(4).sick_1_3_ocr_dc	 :=nvl(abstotal(4).sick_1_3_ocr_dc,0)+nvl(csr_abs_stat_datas.dc_1_3_days_Occur,0);
         l_counter :=   l_counter + 1;
         gplsqltable (l_counter).tagname := csr_abs_stat_datas.sex||'_DC_1_3_ABS_DAYS';
         gplsqltable (l_counter).tagvalue:= csr_abs_stat_datas.dc_1_3_abs_days;
         abstotal(4).sick_1_3_days_dc	 :=nvl(abstotal(4).sick_1_3_days_dc,0)+nvl(csr_abs_stat_datas.dc_1_3_abs_days,0);
         l_counter :=   l_counter + 1;
         gplsqltable (l_counter).tagname := csr_abs_stat_datas.sex||'_SICK_4_16_DAYS_OCCUR';
         gplsqltable (l_counter).tagvalue:=csr_abs_stat_datas.sick_4_16_days_Occur;
         abstotal(4).sick_4_16_ocrs	 :=nvl(abstotal(4).sick_4_16_ocrs,0)+nvl(csr_abs_stat_datas.sick_4_16_days_Occur,0);
         l_counter :=   l_counter+ 1;
         gplsqltable (l_counter).tagname := csr_abs_stat_datas.sex||'_SICK_4_16_ABS_DAYS';
         gplsqltable (l_counter).tagvalue:=csr_abs_stat_datas.sick_4_16_abs_days;
         abstotal(4).sick_4_16_days	 :=nvl(abstotal(4).sick_4_16_days,0)+nvl(csr_abs_stat_datas.sick_4_16_Abs_Days,0);
         l_counter :=   l_counter + 1;

         gplsqltable (l_counter).tagname := csr_abs_stat_datas.sex||'_MORE_THAN_16DAYS_OCCUR';
         gplsqltable (l_counter).tagvalue:= csr_abs_stat_datas.More_Than_16days_Occur;
         abstotal(4).sick_more_16_ocrs	 :=nvl(abstotal(4).sick_more_16_ocrs,0)+nvl(csr_abs_stat_datas.More_Than_16days_Occur,0);
         l_counter :=   l_counter + 1;
         gplsqltable (l_counter).tagname := csr_abs_stat_datas.sex||'_MORE_THAN_16DAYS_ABS';
	 gplsqltable (l_counter).tagvalue:= csr_abs_stat_datas.More_Than_16days_Abs;
	 abstotal(4).sick_more_16_days	 :=nvl(abstotal(4).sick_more_16_days,0)+nvl(csr_abs_stat_datas.More_Than_16days_Abs,0);
	 l_counter :=   l_counter + 1;

	 gplsqltable (l_counter).tagname := csr_abs_stat_datas.sex||'_MORE_THAN_8W_OCCUR';
	 gplsqltable (l_counter).tagvalue:= csr_abs_stat_datas.sick_more_8w_ocrs;
	 abstotal(4).sick_more_8w_ocrs	 :=nvl(abstotal(4).sick_more_8w_ocrs,0)+nvl(csr_abs_stat_datas.sick_more_8w_ocrs,0);
	 l_counter :=   l_counter + 1;

	 gplsqltable (l_counter).tagname := csr_abs_stat_datas.sex||'_MORE_THAN_8W_DAYS';
	 gplsqltable (l_counter).tagvalue:= csr_abs_stat_datas.sick_more_8w_days;
	 abstotal(4).sick_more_8w_days	 :=nvl(abstotal(4).sick_more_8w_days,0)+nvl(csr_abs_stat_datas.sick_more_8w_days,0);
	 l_counter :=   l_counter + 1;


         gplsqltable (l_counter).tagname := csr_abs_stat_datas.sex||'_CHILD_MINDERS_OCRS';
	 gplsqltable (l_counter).tagvalue:= csr_abs_stat_datas.Child_Minders_Ocrs;
	 abstotal(4).cms_abs_ocrs	 :=nvl(abstotal(4).cms_abs_ocrs,0)+nvl(csr_abs_stat_datas.Child_Minders_Ocrs,0);
	 l_counter :=   l_counter + 1;
         gplsqltable (l_counter).tagname := csr_abs_stat_datas.sex||'_CHILD_MINDERS_DAYS';
	 gplsqltable (l_counter).tagvalue:= csr_abs_stat_datas.Child_Minders_Days;
	 abstotal(4).cms_abs_days	 :=nvl(abstotal(4).cms_abs_days,0)+nvl(csr_abs_stat_datas.Child_Minders_Days,0);
	 l_counter :=   l_counter + 1;
	 gplsqltable (l_counter).tagname := csr_abs_stat_datas.sex||'_PATERNAL_LEAVE_OCRS';
	 gplsqltable (l_counter).tagvalue:= csr_abs_stat_datas.Paternal_Leave_ocrs;
	 abstotal(4).parental_abs_ocrs	 :=nvl(abstotal(4).parental_abs_ocrs,0)+nvl(csr_abs_stat_datas.Paternal_Leave_ocrs,0);
	 l_counter :=   l_counter + 1;
	 gplsqltable (l_counter).tagname := csr_abs_stat_datas.sex||'_PATERNAL_LEAVE_DAYS';
	 gplsqltable (l_counter).tagvalue:= csr_abs_stat_datas.Paternal_leave_days;
	 abstotal(4).parental_abs_days	 :=nvl(abstotal(4).parental_abs_days,0)+nvl(csr_abs_stat_datas.Paternal_leave_days,0);
	 l_counter :=   l_counter + 1;
	 gplsqltable (l_counter).tagname := csr_abs_stat_datas.sex||'_OTHER_LEAVE_OCRS';
	 gplsqltable (l_counter).tagvalue:= csr_abs_stat_datas.other_leave_ocrs;
	 abstotal(4).other_abs_ocrs	 :=nvl(abstotal(4).other_abs_ocrs,0)+nvl(csr_abs_stat_datas.other_leave_ocrs,0);
	 l_counter :=   l_counter + 1;
         gplsqltable (l_counter).tagname := csr_abs_stat_datas.sex||'_OTHER_LEAVE_DAYS';
	 gplsqltable (l_counter).tagvalue:= csr_abs_stat_datas.other_leave_days;
	 abstotal(4).other_abs_days	 :=nvl(abstotal(4).other_abs_days,0)+nvl(csr_abs_stat_datas.other_leave_days,0);
	 l_counter :=   l_counter + 1;

	 gplsqltable (l_counter).tagname := csr_abs_stat_datas.sex||'_OTHER_PAID_LEAVE_OCRS';
	 gplsqltable (l_counter).tagvalue:= csr_abs_stat_datas.other_abs_paid_ocrs;
	 abstotal(4).other_abs_paid_ocrs :=nvl(abstotal(4).other_abs_paid_ocrs,0)+nvl(csr_abs_stat_datas.other_abs_paid_ocrs,0);
	 l_counter :=   l_counter + 1;
	  gplsqltable (l_counter).tagname := csr_abs_stat_datas.sex||'_OTHER_PAID_LEAVE_DAYS';
	 gplsqltable (l_counter).tagvalue:= csr_abs_stat_datas.other_abs_paid_days;
	 abstotal(4).other_abs_paid_days :=nvl(abstotal(4).other_abs_paid_days,0)+nvl(csr_abs_stat_datas.other_abs_paid_days,0);
	 l_counter :=   l_counter + 1;

	 gplsqltable (l_counter).tagname := csr_abs_stat_datas.sex||'_SICK_PERCENTAGE';
	 gplsqltable (l_counter).tagvalue := round(l_sickness_percentage,1);
	 l_counter :=   l_counter + 1;

         gplsqltable (l_counter).tagname := 'END';
         gplsqltable (l_counter).tagvalue := 'END';
         l_counter :=   l_counter + 1;
         IF csr_abs_stat_datas.sex = 'M' THEN
		  absmale(0).initialized:='Y';
		  absmale(0).quatertag:=hr_general.decode_lookup('NO_FORM_LABELS','ASR02');
		  absmale(0).possible_working_days:= nvl(absmale(0).possible_working_days,0)+nvl(csr_abs_stat_datas.possible_working_days,0);
		  absmale(0).sick_1_3_ocr_sc	:=nvl(absmale(0).sick_1_3_ocr_sc,0)+nvl(csr_abs_stat_datas.occur_1_3_days_sc,0);
		  absmale(0).sick_1_3_days_sc	:=nvl(absmale(0).sick_1_3_days_sc,0)+nvl(csr_abs_stat_datas.sc_1_3_abs_days,0);
		  absmale(0).sick_1_3_ocr_dc	:=nvl(absmale(0).sick_1_3_ocr_dc,0)+nvl(csr_abs_stat_datas.dc_1_3_days_Occur,0);
		  absmale(0).sick_1_3_days_dc	:=nvl(absmale(0).sick_1_3_days_dc,0)+nvl(csr_abs_stat_datas.dc_1_3_abs_days,0);
		  absmale(0).sick_4_16_ocrs	:=nvl(absmale(0).sick_4_16_ocrs,0)+nvl(csr_abs_stat_datas.sick_4_16_days_Occur,0);
		  absmale(0).sick_4_16_days	:=nvl(absmale(0).sick_4_16_days,0)+nvl(csr_abs_stat_datas.sick_4_16_Abs_Days,0);
		  absmale(0).sick_more_16_ocrs	:=nvl(absmale(0).sick_more_16_ocrs,0)+nvl(csr_abs_stat_datas.More_Than_16days_Occur,0);
		  absmale(0).sick_more_16_days	:=nvl(absmale(0).sick_more_16_days,0)+nvl(csr_abs_stat_datas.More_Than_16days_Abs,0);
		  absmale(0).cms_abs_ocrs	:=nvl(absmale(0).cms_abs_ocrs,0)+nvl(csr_abs_stat_datas.Child_Minders_Ocrs,0);
		  absmale(0).cms_abs_days	:=nvl(absmale(0).cms_abs_days,0)+nvl(csr_abs_stat_datas.Child_Minders_Days,0);
		  absmale(0).parental_abs_ocrs	:=nvl(absmale(0).parental_abs_ocrs,0)+nvl(csr_abs_stat_datas.Paternal_Leave_ocrs,0);
		  absmale(0).parental_abs_days	:=nvl(absmale(0).parental_abs_days,0)+nvl(csr_abs_stat_datas.Paternal_leave_days,0);
		  absmale(0).other_abs_ocrs	:=nvl(absmale(0).other_abs_ocrs,0)+nvl(csr_abs_stat_datas.other_leave_ocrs,0);
          	  absmale(0).other_abs_days	:=nvl(absmale(0).other_abs_days,0)+nvl(csr_abs_stat_datas.other_leave_days,0);
          	  absmale(0).sick_more_8w_ocrs	:=nvl(absmale(0).sick_more_8w_ocrs,0)+nvl(csr_abs_stat_datas.sick_more_8w_ocrs,0);
          	  absmale(0).sick_more_8w_days	:=nvl(absmale(0).sick_more_8w_days,0)+nvl(csr_abs_stat_datas.sick_more_8w_days,0);
          	  absmale(0).other_abs_paid_ocrs:=nvl(absmale(0).other_abs_paid_ocrs,0)+nvl(csr_abs_stat_datas.other_abs_paid_ocrs,0);
          	  absmale(0).other_abs_paid_days:=nvl(absmale(0).other_abs_paid_days,0)+nvl(csr_abs_stat_datas.other_abs_paid_days,0);
         ELSIF csr_abs_stat_datas.sex = 'F' THEN
		  absfemale(0).initialized:='Y';
		  absfemale(0).quatertag:=hr_general.decode_lookup('NO_FORM_LABELS','ASR03');
		  absfemale(0).possible_working_days	:=nvl(absfemale(0).possible_working_days,0)+nvl(csr_abs_stat_datas.possible_working_days,0);
		  absfemale(0).sick_1_3_ocr_sc		:=nvl(absfemale(0).sick_1_3_ocr_sc,0)+nvl(csr_abs_stat_datas.occur_1_3_days_sc,0);
		  absfemale(0).sick_1_3_days_sc		:=nvl(absfemale(0).sick_1_3_days_sc,0)+nvl(csr_abs_stat_datas.sc_1_3_abs_days,0);
		  absfemale(0).sick_1_3_ocr_dc		:=nvl(absfemale(0).sick_1_3_ocr_dc,0)+nvl(csr_abs_stat_datas.dc_1_3_days_Occur,0);
		  absfemale(0).sick_1_3_days_dc		:=nvl(absfemale(0).sick_1_3_days_dc,0)+nvl(csr_abs_stat_datas.dc_1_3_abs_days,0);
		  absfemale(0).sick_4_16_ocrs		:=nvl(absfemale(0).sick_4_16_ocrs,0)+nvl(csr_abs_stat_datas.sick_4_16_days_Occur,0);
		  absfemale(0).sick_4_16_days		:=nvl(absfemale(0).sick_4_16_days,0)+nvl(csr_abs_stat_datas.sick_4_16_Abs_Days,0);
		  absfemale(0).sick_more_16_ocrs	:=nvl(absfemale(0).sick_more_16_ocrs,0)+nvl(csr_abs_stat_datas.More_Than_16days_Occur,0);
		  absfemale(0).sick_more_16_days	:=nvl(absfemale(0).sick_more_16_days,0)+nvl(csr_abs_stat_datas.More_Than_16days_Abs,0);
		  absfemale(0).cms_abs_ocrs		:=nvl(absfemale(0).cms_abs_ocrs,0)+nvl(csr_abs_stat_datas.Child_Minders_Ocrs,0);
		  absfemale(0).cms_abs_days		:=nvl(absfemale(0).cms_abs_days,0)+nvl(csr_abs_stat_datas.Child_Minders_Days,0);
		  absfemale(0).parental_abs_ocrs	:=nvl(absfemale(0).parental_abs_ocrs,0)+nvl(csr_abs_stat_datas.Paternal_Leave_ocrs,0);
		  absfemale(0).parental_abs_days	:=nvl(absfemale(0).parental_abs_days,0)+nvl(csr_abs_stat_datas.Paternal_leave_days,0);
		  absfemale(0).other_abs_ocrs		:=nvl(absfemale(0).other_abs_ocrs,0)+nvl(csr_abs_stat_datas.other_leave_ocrs,0);
		  absfemale(0).other_abs_days		:=nvl(absfemale(0).other_abs_days,0)+nvl(csr_abs_stat_datas.other_leave_days,0);
		  absfemale(0).sick_more_8w_ocrs	:=nvl(absfemale(0).sick_more_8w_ocrs,0)+nvl(csr_abs_stat_datas.sick_more_8w_ocrs,0);
          	  absfemale(0).sick_more_8w_days	:=nvl(absfemale(0).sick_more_8w_days,0)+nvl(csr_abs_stat_datas.sick_more_8w_days,0);
          	  absfemale(0).other_abs_paid_ocrs	:=nvl(absfemale(0).other_abs_paid_ocrs,0)+nvl(csr_abs_stat_datas.other_abs_paid_ocrs,0);
          	  absfemale(0).other_abs_paid_days	:=nvl(absfemale(0).other_abs_paid_days,0)+nvl(csr_abs_stat_datas.other_abs_paid_days,0);
         END IF;

	  abstotal(l_quater_count).initialized:='Y';
	  abstotal(l_quater_count).quatertag:=hr_general.decode_lookup('NO_FORM_LABELS','ASR01');
	  abstotal(l_quater_count).possible_working_days	:=nvl(abstotal(l_quater_count).possible_working_days,0)+nvl(csr_abs_stat_datas.possible_working_days,0);
	  abstotal(l_quater_count).sick_1_3_ocr_sc		:=nvl(abstotal(l_quater_count).sick_1_3_ocr_sc,0)+nvl(csr_abs_stat_datas.occur_1_3_days_sc,0);
	  abstotal(l_quater_count).sick_1_3_days_sc		:=nvl(abstotal(l_quater_count).sick_1_3_days_sc,0)+nvl(csr_abs_stat_datas.sc_1_3_abs_days,0);
	  abstotal(l_quater_count).sick_1_3_ocr_dc		:=nvl(abstotal(l_quater_count).sick_1_3_ocr_dc,0)+nvl(csr_abs_stat_datas.dc_1_3_days_Occur,0);
	  abstotal(l_quater_count).sick_1_3_days_dc		:=nvl(abstotal(l_quater_count).sick_1_3_days_dc,0)+nvl(csr_abs_stat_datas.dc_1_3_abs_days,0);
	  abstotal(l_quater_count).sick_4_16_ocrs		:=nvl(abstotal(l_quater_count).sick_4_16_ocrs,0)+nvl(csr_abs_stat_datas.sick_4_16_days_Occur,0);
	  abstotal(l_quater_count).sick_4_16_days		:=nvl(abstotal(l_quater_count).sick_4_16_days,0)+nvl(csr_abs_stat_datas.sick_4_16_Abs_Days,0);
	  abstotal(l_quater_count).sick_more_16_ocrs		:=nvl(abstotal(l_quater_count).sick_more_16_ocrs,0)+nvl(csr_abs_stat_datas.More_Than_16days_Occur,0);
	  abstotal(l_quater_count).sick_more_16_days		:=nvl(abstotal(l_quater_count).sick_more_16_days,0)+nvl(csr_abs_stat_datas.More_Than_16days_Abs,0);
	  abstotal(l_quater_count).cms_abs_ocrs			:=nvl(abstotal(l_quater_count).cms_abs_ocrs,0)+nvl(csr_abs_stat_datas.Child_Minders_Ocrs,0);
	  abstotal(l_quater_count).cms_abs_days			:=nvl(abstotal(l_quater_count).cms_abs_days,0)+nvl(csr_abs_stat_datas.Child_Minders_Days,0);
	  abstotal(l_quater_count).parental_abs_ocrs		:=nvl(abstotal(l_quater_count).parental_abs_ocrs,0)+nvl(csr_abs_stat_datas.Paternal_Leave_ocrs,0);
	  abstotal(l_quater_count).parental_abs_days		:=nvl(abstotal(l_quater_count).parental_abs_days,0)+nvl(csr_abs_stat_datas.Paternal_leave_days,0);
	  abstotal(l_quater_count).other_abs_ocrs		:=nvl(abstotal(l_quater_count).other_abs_ocrs,0)+nvl(csr_abs_stat_datas.other_leave_ocrs,0);
	  abstotal(l_quater_count).other_abs_days		:=nvl(abstotal(l_quater_count).other_abs_days,0)+nvl(csr_abs_stat_datas.other_leave_days,0);
	  abstotal(l_quater_count).sick_more_8w_ocrs		:=nvl(abstotal(l_quater_count).sick_more_8w_ocrs,0)+nvl(csr_abs_stat_datas.sick_more_8w_ocrs,0);
	  abstotal(l_quater_count).sick_more_8w_days		:=nvl(abstotal(l_quater_count).sick_more_8w_days,0)+nvl(csr_abs_stat_datas.sick_more_8w_days,0);
	  abstotal(l_quater_count).other_abs_paid_ocrs		:=nvl(abstotal(l_quater_count).other_abs_paid_ocrs,0)+nvl(csr_abs_stat_datas.other_abs_paid_ocrs,0);
          abstotal(l_quater_count).other_abs_paid_days		:=nvl(abstotal(l_quater_count).other_abs_paid_days,0)+nvl(csr_abs_stat_datas.other_abs_paid_days,0);
      END LOOP;

     /* Start of Last Quater Total */

     		l_actual_working_days := nvl(abstotal(l_quater_count).possible_working_days,0)
     	        				- nvl(abstotal(l_quater_count).sick_1_3_days_sc,0)
     	        				- nvl(abstotal(l_quater_count).sick_1_3_days_dc,0)
     	        				- nvl(abstotal(l_quater_count).sick_4_16_days,0)
     	        				- nvl(abstotal(l_quater_count).sick_more_16_days,0)
     	        				- nvl(abstotal(l_quater_count).cms_abs_days,0)
     	        				- nvl(abstotal(l_quater_count).parental_abs_days,0)
     	        				- nvl(abstotal(l_quater_count).other_abs_days,0)
     	        				- nvl(abstotal(l_quater_count).other_abs_paid_days,0);

     	        l_absent_days := nvl(abstotal(l_quater_count).sick_1_3_days_sc,0)
     	        				+ nvl(abstotal(l_quater_count).sick_1_3_days_dc,0)
     	        				+ nvl(abstotal(l_quater_count).sick_4_16_days,0)
     	        				+ nvl(abstotal(l_quater_count).sick_more_16_days,0);

           	If nvl(abstotal(l_quater_count).possible_working_days,0) <> 0 then
           		l_sickness_percentage := (l_absent_days /abstotal(l_quater_count).possible_working_days)*100;
          	End if;


     	 	gplsqltable (l_counter).tagname := 'QUARTER';
     		gplsqltable (l_counter).tagvalue := l_quater;
     		l_counter := l_counter+ 1;

     		 gplsqltable (l_counter).tagname := 'START';
     		 gplsqltable (l_counter).tagvalue:= 'START';
     		 l_counter :=   l_counter+ 1;
     		 gplsqltable (l_counter).tagname :=  'Q_SEX';
     		 gplsqltable (l_counter).tagvalue:= abstotal(l_quater_count).quatertag||' '||l_quater;
     		 l_counter :=   l_counter+ 1;
     		 gplsqltable (l_counter).tagname := 'Q_POSSIBLE_WORKING_DAYS';
     		 gplsqltable (l_counter).tagvalue:= round(abstotal(l_quater_count).possible_working_days);
     		 l_counter :=   l_counter + 1;
     		 gplsqltable (l_counter).tagname := 'Q_ACTUAL_WORKING_DAYS';
     		 gplsqltable (l_counter).tagvalue:= round(l_actual_working_days);
     		 l_counter :=   l_counter + 1;
     		 gplsqltable (l_counter).tagname := 'Q_OCCUR_1_3_DAYS_SC';
     		 gplsqltable (l_counter).tagvalue := abstotal(l_quater_count).sick_1_3_ocr_sc;
     		 l_counter :=   l_counter + 1;
     		 gplsqltable (l_counter).tagname := 'Q_SC_1_3_ABS_DAYS';
     		 gplsqltable (l_counter).tagvalue := round(abstotal(l_quater_count).sick_1_3_days_sc);
     		 l_counter :=   l_counter + 1;
     		 gplsqltable (l_counter).tagname := 'Q_DC_1_3_DAYS_OCCUR';
     		 gplsqltable (l_counter).tagvalue:= abstotal(l_quater_count).sick_1_3_ocr_dc;
     		 l_counter :=   l_counter + 1;
     		 gplsqltable (l_counter).tagname := 'Q_DC_1_3_ABS_DAYS';
     		 gplsqltable (l_counter).tagvalue := round(abstotal(l_quater_count).sick_1_3_days_dc);
     		 l_counter :=   l_counter + 1;
     		 gplsqltable (l_counter).tagname := 'Q_SICK_4_16_DAYS_OCCUR';
     		 gplsqltable (l_counter).tagvalue:= abstotal(l_quater_count).sick_4_16_ocrs;
     		 l_counter :=   l_counter+ 1;
     		 gplsqltable (l_counter).tagname := 'Q_SICK_4_16_ABS_DAYS';
     		 gplsqltable (l_counter).tagvalue:= round(abstotal(l_quater_count).sick_4_16_days);
     		 l_counter :=   l_counter + 1;
     		 gplsqltable (l_counter).tagname := 'Q_MORE_THAN_16DAYS_OCCUR';
     		 gplsqltable (l_counter).tagvalue := abstotal(l_quater_count).sick_more_16_ocrs;
     		 l_counter :=   l_counter + 1;
     		 gplsqltable (l_counter).tagname := 'Q_MORE_THAN_16DAYS_ABS';
     		 gplsqltable (l_counter).tagvalue := round(abstotal(l_quater_count).sick_more_16_days);
     		 l_counter :=   l_counter + 1;

     		 gplsqltable (l_counter).tagname := 'Q_MORE_THAN_8W_OCCUR';
     		 gplsqltable (l_counter).tagvalue := abstotal(l_quater_count).sick_more_8w_ocrs;
     		 l_counter :=   l_counter + 1;

     		 gplsqltable (l_counter).tagname := 'Q_MORE_THAN_8W_DAYS';
     		 gplsqltable (l_counter).tagvalue := round(abstotal(l_quater_count).sick_more_8w_days);
     		 l_counter :=   l_counter + 1;

     		 gplsqltable (l_counter).tagname := 'Q_CHILD_MINDERS_OCRS';
     		 gplsqltable (l_counter).tagvalue := abstotal(l_quater_count).cms_abs_ocrs;
     		 l_counter :=   l_counter + 1;
     		 gplsqltable (l_counter).tagname := 'Q_CHILD_MINDERS_DAYS';
     		 gplsqltable (l_counter).tagvalue := round(abstotal(l_quater_count).cms_abs_days);
     		 l_counter :=   l_counter + 1;
     		 gplsqltable (l_counter).tagname := 'Q_PATERNAL_LEAVE_OCRS';
     		 gplsqltable (l_counter).tagvalue := abstotal(l_quater_count).parental_abs_ocrs;
     		 l_counter :=   l_counter + 1;
     		 gplsqltable (l_counter).tagname := 'Q_PATERNAL_LEAVE_DAYS';
     		 gplsqltable (l_counter).tagvalue := round(abstotal(l_quater_count).parental_abs_days);
     		 l_counter :=   l_counter + 1;
     		 gplsqltable (l_counter).tagname := 'Q_OTHER_LEAVE_OCRS';
     		 gplsqltable (l_counter).tagvalue := abstotal(l_quater_count).other_abs_ocrs;
     		 l_counter :=   l_counter + 1;
     		 gplsqltable (l_counter).tagname := 'Q_OTHER_LEAVE_DAYS';
     		 gplsqltable (l_counter).tagvalue := round(abstotal(l_quater_count).other_abs_days);
     		 l_counter :=   l_counter + 1;

     		 gplsqltable (l_counter).tagname := 'Q_OTHER_PAID_LEAVE_OCRS';
		 gplsqltable (l_counter).tagvalue := abstotal(l_quater_count).other_abs_paid_ocrs;
		 l_counter :=   l_counter + 1;
		 gplsqltable (l_counter).tagname := 'Q_OTHER_PAID_LEAVE_DAYS';
		 gplsqltable (l_counter).tagvalue := round(abstotal(l_quater_count).other_abs_paid_days);
     		 l_counter :=   l_counter + 1;

     		 gplsqltable (l_counter).tagname := 'Q_SICK_PERCENTAGE';
     		 gplsqltable (l_counter).tagvalue := round(l_sickness_percentage,1);
     		 l_counter :=   l_counter + 1;

     		 gplsqltable (l_counter).tagname := 'END';
     		 gplsqltable (l_counter).tagvalue := 'END';
		 l_counter :=   l_counter + 1;
     /* End of Last Quater Total*/
     /*   Start of Male Total */

     	  l_actual_working_days := nvl(absmale(0).possible_working_days,0)
	 	        				- nvl(absmale(0).sick_1_3_days_sc,0)
	 	        				- nvl(absmale(0).sick_1_3_days_dc,0)
	 	        				- nvl(absmale(0).sick_4_16_days,0)
	 	        				- nvl(absmale(0).sick_more_16_days,0)
	 	        				- nvl(absmale(0).cms_abs_days,0)
	 	        				- nvl(absmale(0).parental_abs_days,0)
	        					- nvl(absmale(0).other_abs_days,0)
	        					- nvl(absmale(0).other_abs_paid_days,0);

	l_absent_days := nvl(absmale(0).sick_1_3_days_sc,0)
	        				+ nvl(absmale(0).sick_1_3_days_dc,0)
	        				+ nvl(absmale(0).sick_4_16_days,0)
	        				+ nvl(absmale(0).sick_more_16_days,0);

      	If nvl(absmale(0).possible_working_days,0) <> 0 then
	           l_sickness_percentage := (l_absent_days /absmale(0).possible_working_days)*100;
	End if;


     	 gplsqltable (l_counter).tagname := 'QUARTER';
	 gplsqltable (l_counter).tagvalue := 'Total';
	 l_counter := l_counter+ 1;
         gplsqltable (l_counter).tagname := 'START';
	 gplsqltable (l_counter).tagvalue:= 'START';
	 l_counter :=   l_counter+ 1;
	 gplsqltable (l_counter).tagname := 'M_SEX';
	 gplsqltable (l_counter).tagvalue:= absmale(0).quatertag;
	 l_counter :=   l_counter+ 1;
	 gplsqltable (l_counter).tagname := 'M_POSSIBLE_WORKING_DAYS';
	 gplsqltable (l_counter).tagvalue:= round(absmale(0).possible_working_days);
	 l_counter :=   l_counter + 1;

	 gplsqltable (l_counter).tagname := 'M_ACTUAL_WORKING_DAYS';
	 gplsqltable (l_counter).tagvalue:= round(l_actual_working_days);
	 l_counter :=   l_counter + 1;

	 gplsqltable (l_counter).tagname := 'M_OCCUR_1_3_DAYS_SC';
	 gplsqltable (l_counter).tagvalue := absmale(0).sick_1_3_ocr_sc;
	 l_counter :=   l_counter + 1;
	 gplsqltable (l_counter).tagname := 'M_SC_1_3_ABS_DAYS';
	 gplsqltable (l_counter).tagvalue := round(absmale(0).sick_1_3_days_sc);
	 l_counter :=   l_counter + 1;
	 gplsqltable (l_counter).tagname := 'M_DC_1_3_DAYS_OCCUR';
	 gplsqltable (l_counter).tagvalue:= absmale(0).sick_1_3_ocr_dc;
	 l_counter :=   l_counter + 1;
	 gplsqltable (l_counter).tagname := 'M_DC_1_3_ABS_DAYS';
	 gplsqltable (l_counter).tagvalue := round(absmale(0).sick_1_3_days_dc);
	 l_counter :=   l_counter + 1;
	 gplsqltable (l_counter).tagname := 'M_SICK_4_16_DAYS_OCCUR';
	 gplsqltable (l_counter).tagvalue:= absmale(0).sick_4_16_ocrs;
	 l_counter :=   l_counter+ 1;
	 gplsqltable (l_counter).tagname := 'M_SICK_4_16_ABS_DAYS';
	 gplsqltable (l_counter).tagvalue:= round(absmale(0).sick_4_16_days);
	 l_counter :=   l_counter + 1;
	 gplsqltable (l_counter).tagname := 'M_MORE_THAN_16DAYS_OCCUR';
	 gplsqltable (l_counter).tagvalue := absmale(0).sick_more_16_ocrs;
	 l_counter :=   l_counter + 1;
	 gplsqltable (l_counter).tagname := 'M_MORE_THAN_16DAYS_ABS';
	 gplsqltable (l_counter).tagvalue := round(absmale(0).sick_more_16_days);
	 l_counter :=   l_counter + 1;

	 gplsqltable (l_counter).tagname := 'M_MORE_THAN_8W_OCCUR';
	 gplsqltable (l_counter).tagvalue := absmale(0).sick_more_8w_ocrs;
	 l_counter :=   l_counter + 1;
	 gplsqltable (l_counter).tagname := 'M_MORE_THAN_8W_DAYS';
	 gplsqltable (l_counter).tagvalue := round(absmale(0).sick_more_8w_days);
	 l_counter :=   l_counter + 1;

	 gplsqltable (l_counter).tagname := 'M_CHILD_MINDERS_OCRS';
	 gplsqltable (l_counter).tagvalue := absmale(0).cms_abs_ocrs;
	 l_counter :=   l_counter + 1;
	 gplsqltable (l_counter).tagname := 'M_CHILD_MINDERS_DAYS';
	 gplsqltable (l_counter).tagvalue := round(absmale(0).cms_abs_days);
	 l_counter :=   l_counter + 1;
	 gplsqltable (l_counter).tagname := 'M_PATERNAL_LEAVE_OCRS';
	 gplsqltable (l_counter).tagvalue := absmale(0).parental_abs_ocrs;
	 l_counter :=   l_counter + 1;
	 gplsqltable (l_counter).tagname := 'M_PATERNAL_LEAVE_DAYS';
	 gplsqltable (l_counter).tagvalue := round(absmale(0).parental_abs_days);
	 l_counter :=   l_counter + 1;
	 gplsqltable (l_counter).tagname := 'M_OTHER_LEAVE_OCRS';
	 gplsqltable (l_counter).tagvalue := absmale(0).other_abs_ocrs;
	 l_counter :=   l_counter + 1;
	 gplsqltable (l_counter).tagname := 'M_OTHER_LEAVE_DAYS';
	 gplsqltable (l_counter).tagvalue := round(absmale(0).other_abs_days);
	 l_counter :=   l_counter + 1;

	 gplsqltable (l_counter).tagname := 'M_OTHER_PAID_LEAVE_OCRS';
	 gplsqltable (l_counter).tagvalue := absmale(0).other_abs_paid_ocrs;
	 l_counter :=   l_counter + 1;
	 gplsqltable (l_counter).tagname := 'M_OTHER_PAID_LEAVE_DAYS';
	 gplsqltable (l_counter).tagvalue := round(absmale(0).other_abs_paid_days);
	 l_counter :=   l_counter + 1;

	 gplsqltable (l_counter).tagname := 'M_SICK_PERCENTAGE';
	 gplsqltable (l_counter).tagvalue := round(l_sickness_percentage,1);
	 l_counter :=   l_counter + 1;

	 gplsqltable (l_counter).tagname := 'END';
	 gplsqltable (l_counter).tagvalue := 'END';
	 l_counter :=   l_counter + 1;
	 /*   End of Male Total */
	 /*   Start of Female Total */

	 l_actual_working_days := nvl(absfemale(0).possible_working_days,0)
							- nvl(absfemale(0).sick_1_3_days_sc,0)
							- nvl(absfemale(0).sick_1_3_days_dc,0)
							- nvl(absfemale(0).sick_4_16_days,0)
							- nvl(absfemale(0).sick_more_16_days,0)
							- nvl(absfemale(0).cms_abs_days,0)
							- nvl(absfemale(0).parental_abs_days,0)
	        					- nvl(absfemale(0).other_abs_days,0)
	        					- nvl(absfemale(0).other_abs_paid_days,0);

	l_absent_days := nvl(absfemale(0).sick_1_3_days_sc,0)
	        				+ nvl(absfemale(0).sick_1_3_days_dc,0)
	        				+ nvl(absfemale(0).sick_4_16_days,0)
	        				+ nvl(absfemale(0).sick_more_16_days,0);

	If nvl(absfemale(0).possible_working_days,0) <> 0 then
	      	l_sickness_percentage := (l_absent_days /absfemale(0).possible_working_days)*100;
	end if;

	 gplsqltable (l_counter).tagname := 'START';
	 gplsqltable (l_counter).tagvalue:= 'START';
	 l_counter :=   l_counter+ 1;
	 gplsqltable (l_counter).tagname := 'F_SEX';
	 gplsqltable (l_counter).tagvalue:= absfemale(0).quatertag;
	 l_counter :=   l_counter+ 1;
	 gplsqltable (l_counter).tagname := 'F_POSSIBLE_WORKING_DAYS';
	 gplsqltable (l_counter).tagvalue:= round(absfemale(0).possible_working_days);
	 l_counter :=   l_counter + 1;
	 gplsqltable (l_counter).tagname := 'F_ACTUAL_WORKING_DAYS';
	 gplsqltable (l_counter).tagvalue:= round(l_actual_working_days);
	 l_counter :=   l_counter + 1;
	 gplsqltable (l_counter).tagname := 'F_OCCUR_1_3_DAYS_SC';
	 gplsqltable (l_counter).tagvalue := absfemale(0).sick_1_3_ocr_sc;
	 l_counter :=   l_counter + 1;
	 gplsqltable (l_counter).tagname := 'F_SC_1_3_ABS_DAYS';
	 gplsqltable (l_counter).tagvalue := round(absfemale(0).sick_1_3_days_sc);
	 l_counter :=   l_counter + 1;
	 gplsqltable (l_counter).tagname := 'F_DC_1_3_DAYS_OCCUR';
	 gplsqltable (l_counter).tagvalue:= absfemale(0).sick_1_3_ocr_dc;
	 l_counter :=   l_counter + 1;
	 gplsqltable (l_counter).tagname := 'F_DC_1_3_ABS_DAYS';
	 gplsqltable (l_counter).tagvalue := round(absfemale(0).sick_1_3_days_dc);
	 l_counter :=   l_counter + 1;
	 gplsqltable (l_counter).tagname := 'F_SICK_4_16_DAYS_OCCUR';
	 gplsqltable (l_counter).tagvalue:= absfemale(0).sick_4_16_ocrs;
	 l_counter :=   l_counter+ 1;
	 gplsqltable (l_counter).tagname := 'F_SICK_4_16_ABS_DAYS';
	 gplsqltable (l_counter).tagvalue:= round(absfemale(0).sick_4_16_days);
	 l_counter :=   l_counter + 1;
	 gplsqltable (l_counter).tagname := 'F_MORE_THAN_16DAYS_OCCUR';
	 gplsqltable (l_counter).tagvalue := absfemale(0).sick_more_16_ocrs;
	 l_counter :=   l_counter + 1;
	 gplsqltable (l_counter).tagname := 'F_MORE_THAN_16DAYS_ABS';
	 gplsqltable (l_counter).tagvalue := round(absfemale(0).sick_more_16_days);
	 l_counter :=   l_counter + 1;
	 gplsqltable (l_counter).tagname := 'F_MORE_THAN_8W_OCCUR';
	 gplsqltable (l_counter).tagvalue := absfemale(0).sick_more_8w_ocrs;
	 l_counter :=   l_counter + 1;
	 gplsqltable (l_counter).tagname := 'F_MORE_THAN_8W_DAYS';
	 gplsqltable (l_counter).tagvalue := round(absfemale(0).sick_more_8w_days);
	 l_counter :=   l_counter + 1;
	 gplsqltable (l_counter).tagname := 'F_CHILD_MINDERS_OCRS';
	 gplsqltable (l_counter).tagvalue := absfemale(0).cms_abs_ocrs;
	 l_counter :=   l_counter + 1;
	 gplsqltable (l_counter).tagname := 'F_CHILD_MINDERS_DAYS';
	 gplsqltable (l_counter).tagvalue := round(absfemale(0).cms_abs_days);
	 l_counter :=   l_counter + 1;
	 gplsqltable (l_counter).tagname := 'F_PATERNAL_LEAVE_OCRS';
	 gplsqltable (l_counter).tagvalue := absfemale(0).parental_abs_ocrs;
	 l_counter :=   l_counter + 1;
	 gplsqltable (l_counter).tagname := 'F_PATERNAL_LEAVE_DAYS';
	 gplsqltable (l_counter).tagvalue := round(absfemale(0).parental_abs_days);
	 l_counter :=   l_counter + 1;
	 gplsqltable (l_counter).tagname := 'F_OTHER_LEAVE_OCRS';
	 gplsqltable (l_counter).tagvalue := absfemale(0).other_abs_ocrs;
	 l_counter :=   l_counter + 1;
	 gplsqltable (l_counter).tagname := 'F_OTHER_LEAVE_DAYS';
	 gplsqltable (l_counter).tagvalue := round(absfemale(0).other_abs_days);
	 l_counter :=   l_counter + 1;

	 gplsqltable (l_counter).tagname := 'F_OTHER_PAID_LEAVE_OCRS';
	 gplsqltable (l_counter).tagvalue := absfemale(0).other_abs_paid_ocrs;
	 l_counter :=   l_counter + 1;
	 gplsqltable (l_counter).tagname := 'F_OTHER_PAID_LEAVE_DAYS';
	 gplsqltable (l_counter).tagvalue := round(absfemale(0).other_abs_paid_days);
	 l_counter :=   l_counter + 1;

	 gplsqltable (l_counter).tagname := 'F_SICK_PERCENTAGE';
	 gplsqltable (l_counter).tagvalue := round(l_sickness_percentage,1);
	 l_counter :=   l_counter + 1;

	 gplsqltable (l_counter).tagname := 'END';
	 gplsqltable (l_counter).tagvalue := 'END';
	 l_counter :=   l_counter + 1;
         /*   End of Female Total */
         /*   Start of Yearly Total */

         l_actual_working_days := nvl(abstotal(4).possible_working_days,0)
							- nvl(abstotal(4).sick_1_3_days_sc,0)
							- nvl(abstotal(4).sick_1_3_days_dc,0)
							- nvl(abstotal(4).sick_4_16_days,0)
							- nvl(abstotal(4).sick_more_16_days,0)
							- nvl(abstotal(4).cms_abs_days,0)
							- nvl(abstotal(4).parental_abs_days,0)
	        					- nvl(abstotal(4).other_abs_days,0)
	        					- nvl(abstotal(4).other_abs_paid_days,0);

	l_absent_days := nvl(abstotal(4).sick_1_3_days_sc,0)
	        				+ nvl(abstotal(4).sick_1_3_days_dc,0)
	        				+ nvl(abstotal(4).sick_4_16_days,0)
	        				+ nvl(abstotal(4).sick_more_16_days,0);

      	If nvl(abstotal(4).possible_working_days,0) <> 0 then
      		l_sickness_percentage := (l_absent_days /abstotal(4).possible_working_days)*100;
	end if;

         gplsqltable (l_counter).tagname := 'START';
	 gplsqltable (l_counter).tagvalue:= 'START';
	 l_counter :=   l_counter+ 1;
	 gplsqltable (l_counter).tagname := 'Q_SEX';
	 gplsqltable (l_counter).tagvalue:= abstotal(4).quatertag;
	 l_counter :=   l_counter+ 1;
	 gplsqltable (l_counter).tagname := 'Q_POSSIBLE_WORKING_DAYS';
	 gplsqltable (l_counter).tagvalue:= round(abstotal(4).possible_working_days);
	 l_counter :=   l_counter + 1;
	 gplsqltable (l_counter).tagname := 'Q_ACTUAL_WORKING_DAYS';
	 gplsqltable (l_counter).tagvalue:= round(l_actual_working_days);
	 l_counter :=   l_counter + 1;
	 gplsqltable (l_counter).tagname := 'Q_OCCUR_1_3_DAYS_SC';
	 gplsqltable (l_counter).tagvalue := abstotal(4).sick_1_3_ocr_sc;
	 l_counter :=   l_counter + 1;
	 gplsqltable (l_counter).tagname := 'Q_SC_1_3_ABS_DAYS';
	 gplsqltable (l_counter).tagvalue := round(abstotal(4).sick_1_3_days_sc);
	 l_counter :=   l_counter + 1;
	 gplsqltable (l_counter).tagname := 'Q_DC_1_3_DAYS_OCCUR';
	 gplsqltable (l_counter).tagvalue:= abstotal(4).sick_1_3_ocr_dc;
	 l_counter :=   l_counter + 1;
	 gplsqltable (l_counter).tagname := 'Q_DC_1_3_ABS_DAYS';
	 gplsqltable (l_counter).tagvalue := round(abstotal(4).sick_1_3_days_dc);
	 l_counter :=   l_counter + 1;
	 gplsqltable (l_counter).tagname := 'Q_SICK_4_16_DAYS_OCCUR';
	 gplsqltable (l_counter).tagvalue:= abstotal(4).sick_4_16_ocrs;
	 l_counter :=   l_counter+ 1;
	 gplsqltable (l_counter).tagname := 'Q_SICK_4_16_ABS_DAYS';
	 gplsqltable (l_counter).tagvalue:= round(abstotal(4).sick_4_16_days);
	 l_counter :=   l_counter + 1;
	 gplsqltable (l_counter).tagname := 'Q_MORE_THAN_16DAYS_OCCUR';
	 gplsqltable (l_counter).tagvalue := abstotal(4).sick_more_16_ocrs;
	 l_counter :=   l_counter + 1;
	 gplsqltable (l_counter).tagname := 'Q_MORE_THAN_16DAYS_ABS';
	 gplsqltable (l_counter).tagvalue := round(abstotal(4).sick_more_16_days);
	 l_counter :=   l_counter + 1;

	 gplsqltable (l_counter).tagname := 'Q_MORE_THAN_8W_OCCUR';
	 gplsqltable (l_counter).tagvalue := abstotal(4).sick_more_8w_ocrs;
	 l_counter :=   l_counter + 1;
	 gplsqltable (l_counter).tagname := 'Q_MORE_THAN_8W_DAYS';
	 gplsqltable (l_counter).tagvalue := round(abstotal(4).sick_more_8w_days);
	 l_counter :=   l_counter + 1;

	 gplsqltable (l_counter).tagname := 'Q_CHILD_MINDERS_OCRS';
	 gplsqltable (l_counter).tagvalue := abstotal(4).cms_abs_ocrs;
	 l_counter :=   l_counter + 1;
	 gplsqltable (l_counter).tagname := 'Q_CHILD_MINDERS_DAYS';
	 gplsqltable (l_counter).tagvalue := round(abstotal(4).cms_abs_days);
	 l_counter :=   l_counter + 1;
	 gplsqltable (l_counter).tagname := 'Q_PATERNAL_LEAVE_OCRS';
	 gplsqltable (l_counter).tagvalue := abstotal(4).parental_abs_ocrs;
	 l_counter :=   l_counter + 1;
	 gplsqltable (l_counter).tagname := 'Q_PATERNAL_LEAVE_DAYS';
	 gplsqltable (l_counter).tagvalue := round(abstotal(4).parental_abs_days);
	 l_counter :=   l_counter + 1;
	 gplsqltable (l_counter).tagname := 'Q_OTHER_LEAVE_OCRS';
	 gplsqltable (l_counter).tagvalue := abstotal(4).other_abs_ocrs;
	 l_counter :=   l_counter + 1;
	 gplsqltable (l_counter).tagname := 'Q_OTHER_LEAVE_DAYS';
	 gplsqltable (l_counter).tagvalue := round(abstotal(4).other_abs_days);
	 l_counter :=   l_counter + 1;

	 gplsqltable (l_counter).tagname := 'Q_OTHER_PAID_LEAVE_OCRS';
	 gplsqltable (l_counter).tagvalue := abstotal(4).other_abs_paid_ocrs;
	 l_counter :=   l_counter + 1;
	 gplsqltable (l_counter).tagname := 'Q_OTHER_PAID_LEAVE_DAYS';
	 gplsqltable (l_counter).tagvalue := round(abstotal(4).other_abs_paid_days);
	 l_counter :=   l_counter + 1;

	 gplsqltable (l_counter).tagname := 'Q_SICK_PERCENTAGE';
	 gplsqltable (l_counter).tagvalue := round(l_sickness_percentage,1);
	 l_counter :=   l_counter + 1;

	 gplsqltable (l_counter).tagname := 'END';
	 gplsqltable (l_counter).tagvalue := 'END';
	 l_counter :=   l_counter + 1;
      writetoclob (p_xml);

   END get_data;
-----------------------------------------------------------------------------------------------------------------
   PROCEDURE writetoclob (p_xfdf_clob OUT NOCOPY CLOB)
   IS
      l_xfdf_string   CLOB;
      l_str1          VARCHAR2 (1000);
      l_str2          VARCHAR2 (20);
      l_str3          VARCHAR2 (20);
      l_str4          VARCHAR2 (20);
      l_str5          VARCHAR2 (20);
      l_str6          VARCHAR2 (30);
      l_str7          VARCHAR2 (1000);
      l_str8          VARCHAR2 (240);
      l_str9          VARCHAR2 (240);
      l_str10         VARCHAR2 (20);
      l_str11         VARCHAR2 (20);
      l_str12         VARCHAR2 (20);
      current_index   PLS_INTEGER;
      l_counter       PLS_INTEGER;
      l_IANA_charset VARCHAR2 (50);
      l_quater varchar2(30);
      l_quater_flag VARCHAR2(3):='Y';
   BEGIN
     l_IANA_charset :=hr_no_utility.get_IANA_charset ;
      hr_utility.set_location ('Entering WritetoCLOB ', 70);
      l_str1 := '<?xml version="1.0" encoding="'||l_IANA_charset||'"?> <ROOT>';
      l_str2 := '<';
      l_str3 := '>';
      l_str4 := '</';
      l_str5 := '>';
      l_str6 := '</ROOT>';
      l_str7 := '<?xml version="1.0" encoding="'||l_IANA_charset||'"?> <ROOT></ROOT>';
      l_str10 := '<QUARTER>';
      l_str11 := '</QUARTER>';
      l_str12 := 'QUARTER_VAL';
      DBMS_LOB.createtemporary (l_xfdf_string, FALSE, DBMS_LOB.CALL);
      DBMS_LOB.OPEN (l_xfdf_string, DBMS_LOB.lob_readwrite);
      current_index := 0;
      IF gplsqltable.COUNT > 0 THEN
         DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str1), l_str1);
         FOR table_counter IN gplsqltable.FIRST .. gplsqltable.LAST
         LOOP
            l_str8 := gplsqltable (table_counter).tagname;
            l_str9 := gplsqltable (table_counter).tagvalue;
           hr_utility.set_location(' l_quater : '||l_quater,10);
           hr_utility.set_location(' l_str8 : '||l_str8,20);
           hr_utility.set_location(' l_str9 : '||l_str9,30);
           IF l_quater <> gplsqltable (table_counter).tagvalue and l_str8 = 'QUARTER' and l_quater is not null THEN
           	DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str4), l_str4);
		DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str8), l_str8);
                DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str5), l_str5);
                l_quater := gplsqltable (table_counter).tagvalue;
                l_quater_flag:='Y';
           END IF;
           IF l_str8 = 'QUARTER' and l_quater_flag = 'Y' then
               l_quater:=gplsqltable (table_counter).tagvalue;
               IF l_str9 IS NOT NULL   THEN
		       DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str2), l_str2);
		       DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str8), l_str8);
		       DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str3), l_str3);
		       DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str2), l_str2);
		       DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str12), l_str12);
		       DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str3), l_str3);
		       DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str9), l_str9);
		       DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str4), l_str4);
		       DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str12), l_str12);
		       DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str5), l_str5);

		Else
			DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str2), l_str2);
		       DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str8), l_str8);
		       DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str3), l_str3);
		       DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str2), l_str2);
		       DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str12), l_str12);
		       DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str3), l_str3);
		       DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str4), l_str4);
		       DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str12), l_str12);
		       DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str5), l_str5);

		End if;
               l_quater_flag:='N';
            End if;
            IF l_str8 <> 'QUARTER' THEN

		/*    IF l_str9 = 'END' THEN
		       DBMS_LOB.writeappend (l_xfdf_string,LENGTH (l_str11),l_str11);
		    ELSIF l_str9 = 'START' THEN
		       DBMS_LOB.writeappend (l_xfdf_string,LENGTH (l_str10),l_str10);*/

		    IF l_str9 IS NOT NULL   THEN
		       DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str2), l_str2);
		       DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str8), l_str8);
		       DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str3), l_str3);
		       DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str9), l_str9);
		       DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str4), l_str4);
		       DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str8), l_str8);
		       DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str5), l_str5);
		    ELSE
		       DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str2), l_str2);
		       DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str8), l_str8);
		       DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str3), l_str3);
		       DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str4), l_str4);
		       DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str8), l_str8);
		       DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str5), l_str5);
		    END IF;
	    END IF;
            IF table_counter = gplsqltable.LAST THEN
              DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str4), l_str4);
	      DBMS_LOB.writeappend (l_xfdf_string, LENGTH ('QUARTER'), 'QUARTER');
              DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str5), l_str5);
            END IF;
         END LOOP;
         DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str6), l_str6);
      ELSE
         DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str7), l_str7);
      END IF;
      p_xfdf_clob := l_xfdf_string;

   EXCEPTION
      WHEN OTHERS
      THEN
         hr_utility.TRACE (   'sqlerrm '
                           || SQLERRM);
         hr_utility.raise_error;
   END writetoclob;
END PAY_NO_ABS_STATISTICS_REPORT;

/

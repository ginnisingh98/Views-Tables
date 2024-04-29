--------------------------------------------------------
--  DDL for Package Body PAY_KW_CHEQUE_REPORT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_KW_CHEQUE_REPORT" AS
/* $Header: pykwchqr.pkb 120.0.12000000.1 2007/02/21 11:19:24 spendhar noship $ */

  lg_format_mask varchar2(50);
  PROCEDURE set_currency_mask
    (p_business_group_id IN NUMBER) IS
    /* Cursor to retrieve Currency */
    CURSOR csr_currency IS
    SELECT org_information10
    FROM   hr_organization_information
    WHERE  organization_id = p_business_group_id
    AND    org_information_context = 'Business Group Information';
    l_currency VARCHAR2(40);
  BEGIN
    OPEN csr_currency;
    FETCH csr_currency into l_currency;
    CLOSE csr_currency;
    lg_format_mask := FND_CURRENCY.GET_FORMAT_MASK(l_currency,40);
  END set_currency_mask;
-------------------------------------------------------------------------------------------
  FUNCTION get_lookup_meaning
    (p_lookup_type varchar2
    ,p_lookup_code varchar2)
    RETURN VARCHAR2 IS
    CURSOR csr_lookup IS
    select meaning
    from   hr_lookups
    where  lookup_type = p_lookup_type
    and    lookup_code = p_lookup_code;
    l_meaning hr_lookups.meaning%type;
  BEGIN
    OPEN csr_lookup;
    FETCH csr_lookup INTO l_Meaning;
    CLOSE csr_lookup;
    RETURN l_meaning;
  END get_lookup_meaning;
------------------------------------------------------------------------------------------
  PROCEDURE CHEQUE_LISTING
    (p_request_id              NUMBER
    ,p_report                  VARCHAR2
    ,p_business_group_id       NUMBER
    ,p_pact_id                 NUMBER
    ,p_sort                VARCHAR2
    ,l_xfdf_blob               OUT NOCOPY BLOB
    )
   AS


	/* Cursor to fetch date_earned for the payroll action */
	CURSOR csr_get_DE (l_pact_id number) IS
	SELECT nvl(date_earned,effective_date)
	FROM pay_payroll_actions
	WHERE payroll_action_id = l_pact_id;

	/* Cursor to fetch payroll_name for the payroll action */
	CURSOR csr_get_PY (l_pact_id number) IS
	SELECT payroll_name
	FROM pay_all_payrolls_f pap, pay_payroll_actions ppa
	WHERE   ppa.payroll_action_id = l_pact_id
	AND	ppa.payroll_id = pap.payroll_id;


/*** ORDER BY ORG ***/
	/* Cursor for fetching assignment action id and assignment id for current payroll action id order by org name */


/*
	CURSOR csr_get_assact_det_ORG (l_pact_id number , l_date date)  IS
	select paa.assignment_action_id , paa.assignment_id
	from pay_assignment_actions paa , per_all_assignments_f paf, hr_all_organization_units hou
	where paa.payroll_action_id = p_pact_id
	and   paa.action_status = 'C'
	and   not exists ( select 1
		  	  		 from pay_assignment_actions paa1, pay_payroll_actions ppa1, pay_action_interlocks lck
					 where lck.locked_action_id = paa.assignment_action_id
					 and lck.locking_action_id = paa1.assignment_action_id
					 and ppa1.payroll_action_id = paa1.payroll_action_id
					 and ppa1.action_type = 'D'
					 and ppa1.action_status = 'C'
				 	and paa1.action_status = 'C')
	and   paa.assignment_id = paf.assignment_id
	and   trunc(l_date,'MM') between trunc(paf.effective_start_date,'MM') and paf.effective_end_date
	and   paf.organization_id = hou.organization_id
	and   trunc(l_date,'MM') between trunc(hou.date_from,'MM') and nvl(hou.date_to, to_date('31/12/4712','DD/MM/YYYY'))
	order by hou.name;
*/

	CURSOR csr_get_assact_det_ORG (l_pact_id number , l_date date)  IS
	select paa.assignment_action_id , paa.assignment_id
	from pay_assignment_actions paa , per_all_assignments_f paf, hr_all_organization_units hou, per_all_people_f ppf
	where paa.payroll_action_id = p_pact_id
	and   paa.action_status = 'C'
	and   not exists ( select 1
		  	  		 from pay_assignment_actions paa1, pay_payroll_actions ppa1, pay_action_interlocks lck
					 where lck.locked_action_id = paa.assignment_action_id
					 and lck.locking_action_id = paa1.assignment_action_id
					 and ppa1.payroll_action_id = paa1.payroll_action_id
					 and ppa1.action_type = 'D'
					 and ppa1.action_status = 'C'
				 	and paa1.action_status = 'C')
	and   paa.assignment_id = paf.assignment_id
	and   trunc(l_date,'MM') between trunc(paf.effective_start_date,'MM') and paf.effective_end_date
	and   paf.person_id = ppf.person_id
        and   trunc(l_date,'MM') between trunc(ppf.effective_start_date,'MM') and ppf.effective_end_date
	and   paf.organization_id = hou.organization_id
	and   trunc(l_date,'MM') between trunc(hou.date_from,'MM') and nvl(hou.date_to, to_date('31/12/4712','DD/MM/YYYY'))
	order by hou.name, ppf.full_name;


/*** ORDER BY EMPNO ***/
	/* Cursor for fetching assignment action id and assignment id for current payroll action id order by emp no*/
	CURSOR csr_get_assact_det_EMPNO (l_pact_id number , l_date date)  IS
	select paa.assignment_action_id , paa.assignment_id
	from pay_assignment_actions paa , per_all_assignments_f paf, per_all_people_f ppf
	where paa.payroll_action_id = p_pact_id
	and   paa.action_status = 'C'
	and   not exists ( select 1
		  	  		 from pay_assignment_actions paa1, pay_payroll_actions ppa1, pay_action_interlocks lck
					 where lck.locked_action_id = paa.assignment_action_id
					 and lck.locking_action_id = paa1.assignment_action_id
					 and ppa1.payroll_action_id = paa1.payroll_action_id
					 and ppa1.action_type = 'D'
					 and ppa1.action_status = 'C'
				 	and paa1.action_status = 'C')
	and   paa.assignment_id = paf.assignment_id
	and   trunc(l_date,'MM') between trunc(paf.effective_start_date,'MM') and paf.effective_end_date
	and   paf.person_id = ppf.person_id
	and   trunc(l_date,'MM') between trunc(ppf.effective_start_date,'MM') and ppf.effective_end_date
	order by ppf.employee_number;

/*** ORDER BY PAYDATE ***/
	/* Cursor for fetching assignment action id and assignment id for current payroll action id order by payment date*/


/*
	CURSOR csr_get_assact_det_PD (l_pact_id number)  IS
	select paa.assignment_action_id , paa.assignment_id
	from pay_assignment_actions paa , pay_payroll_actions ppa , pay_pre_payments ppp , pay_assignment_actions paa1
	where paa.payroll_action_id = p_pact_id
	and   paa.action_status = 'C'
	and   not exists ( select 1
		  	  		 from pay_assignment_actions paa1, pay_payroll_actions ppa1, pay_action_interlocks lck
					 where lck.locked_action_id = paa.assignment_action_id
					 and lck.locking_action_id = paa1.assignment_action_id
					 and ppa1.payroll_action_id = paa1.payroll_action_id
					 and ppa1.action_type = 'D'
					 and ppa1.action_status = 'C'
				 	and paa1.action_status = 'C')
	and  paa.pre_payment_id = ppp.pre_payment_id
	and  ppp.assignment_action_id = paa1.assignment_action_id
	and  paa1.action_status = 'C'
	and  ppa.payroll_action_id = paa1.payroll_action_id
	and  ppa.action_status = 'C'
	and  ppa.action_type in ('P','U')
	order by nvl(ppa.date_earned,ppa.effective_date);
*/

	CURSOR csr_get_assact_det_PD (l_pact_id number,l_date date)  IS
	select paa.assignment_action_id , paa.assignment_id
	from pay_assignment_actions paa , pay_payroll_actions ppa , pay_pre_payments ppp , pay_assignment_actions paa1,
	     per_all_people_f ppf, per_all_assignments_f paf
	where paa.payroll_action_id = p_pact_id
	and   paa.action_status = 'C'
	and   not exists ( select 1
		  	  		 from pay_assignment_actions paa1, pay_payroll_actions ppa1, pay_action_interlocks lck
					 where lck.locked_action_id = paa.assignment_action_id
					 and lck.locking_action_id = paa1.assignment_action_id
					 and ppa1.payroll_action_id = paa1.payroll_action_id
					 and ppa1.action_type = 'D'
					 and ppa1.action_status = 'C'
				 	and paa1.action_status = 'C')
	and  paa.pre_payment_id = ppp.pre_payment_id
	and  ppp.assignment_action_id = paa1.assignment_action_id
	and  paa1.action_status = 'C'
	and  ppa.payroll_action_id = paa1.payroll_action_id
	and  ppa.action_status = 'C'
	and  ppa.action_type in ('P','U')
        and   paa.assignment_id = paf.assignment_id
        and   trunc(l_date,'MM') between trunc(paf.effective_start_date,'MM') and paf.effective_end_date
        and   paf.person_id = ppf.person_id
        and   trunc(l_date,'MM') between trunc(ppf.effective_start_date,'MM') and ppf.effective_end_date
	order by nvl(ppa.date_earned,ppa.effective_date),ppf.full_name;


	/* Cursor for fetching the details for the assignments */
	CURSOR csr_get_per_det (l_assignment_id number , l_date date) IS
	SELECT  ppf.full_name , ppf.employee_number , paf.job_id , paf.organization_id
	FROM    per_all_people_f ppf, per_all_assignments_f paf
	WHERE   paf.assignment_id = l_assignment_id
	AND	paf.person_id = ppf.person_id
	AND	trunc(l_date,'MM') between trunc(paf.effective_start_date,'MM') and paf.effective_end_date
	AND	trunc(l_date,'MM') between trunc(ppf.effective_start_date,'MM') and ppf.effective_end_date;

	/* Cursor for fetching the Cheque details */
	CURSOR csr_chq_det (l_assact_id number,l_date date) IS
	SELECT	serial_number, value
	FROM	pay_pre_payments_v2 pv2
	WHERE 	pv2.business_group_id+0 = p_business_group_id
	AND	pv2.assignment_action_id = l_assact_id
	AND     pv2.pre_payment_id in (select ppp.pre_payment_id
                                       from pay_pre_payments ppp,pay_action_interlocks lck , pay_org_payment_methods_f org ,
                                            pay_payment_types pt,pay_assignment_actions paa1
				       where lck.locking_action_id =  l_assact_id
							and   lck.locked_action_id = ppp.assignment_action_id
							and   paa1.assignment_action_id = lck.locking_action_id
							and   paa1.pre_payment_id = ppp.pre_payment_id
							and   paa1.action_status = 'C'
							and   ppp.org_payment_method_id = org.org_payment_method_id
							and   org.payment_type_id = pt.payment_type_id
							and   pt.category = 'CH')
	AND     trunc(l_date ,'MM') between trunc(opm_effective_start_date,'MM') and opm_effective_end_date;

	/* Cursor for fetching the job name */
	CURSOR csr_job (l_job number, l_date date) IS
	SELECT	name
	FROM	per_jobs
	WHERE 	job_id = l_job
	AND     trunc(l_date,'MM') between date_from and nvl(date_to, to_date('31/12/4712','DD/MM/YYYY'));

	/* Cursor for fetching the Organization name */
	CURSOR csr_org (l_org_id number,l_date date) IS
	SELECT	name
	FROM	hr_all_organization_units
	WHERE 	organization_id = l_org_id
	AND	trunc(l_date,'MM') between date_from and nvl(date_to, to_date('31/12/4712','DD/MM/YYYY'));

	/* Cursor for fetching the payment date of the pre payment for cheques */
	CURSOR csr_pay_date (l_assact_id number) IS
	select nvl(ppa.date_earned,ppa.effective_date)
	from   pay_payroll_actions ppa, pay_assignment_actions paa, pay_pre_payments ppp, pay_assignment_actions paa1
	where  paa.assignment_action_id = l_assact_id
	and    paa.action_status = 'C'
	and    paa.pre_payment_id = ppp.pre_payment_id
	and    ppp.assignment_action_id = paa1.assignment_action_id
	and    paa1.action_status = 'C'
	and    paa1.payroll_action_id = ppa.payroll_action_id
	and    ppa.action_type in ('P','U')
	and    ppa.action_status = 'C';


    TYPE assact_rec IS RECORD
    (assignment_action_id       NUMBER
    ,assignment_id		NUMBER);

    TYPE t_assact_table IS TABLE OF assact_rec INDEX BY BINARY_INTEGER;

    t_store_assact   t_assact_table;

    rec_get_assact csr_get_assact_det_ORG%ROWTYPE;

    l_input_date date;
    l_effective_date date;

    i number;
    j number;

    l_assact_id number;
    l_assignment_id number;

    l_date_earned date;

    l_full_name varchar2(240);
    l_employee_number varchar2(30);
    l_organization_id	number(15);
    l_organization 	varchar2(240);
    l_job varchar2(240);
    l_job_id number(15);
    l_amount number(15,2);
    l_amount_fm varchar2(40);
    l_chq_number  number;
    l_chq_date date;
    l_pay_date date;
    l_py_name varchar2(240);

    seq number;


    l_str_py_name varchar2(400);
    l_str_seq varchar2(400);
    l_str_er_name1 varchar2(400);
    l_str_er_name2 varchar2(400);
    l_str_er_name3 varchar2(400);
    l_str_er_name4 varchar2(400);
    l_str_er_name5 varchar2(400);
    l_str_er_name6 varchar2(400);
    l_str_er_name7 varchar2(400);

    l_str_rep_label varchar2(100);
    l_str_py_label varchar2(100);
    l_str_n varchar2(100);
    l_str_name_l varchar2(100);
    l_str_amt_l varchar2(100);
    l_str_job_l varchar2(100);
    l_str_org_l varchar2(100);
    l_str_eno_l varchar2(100);
    l_str_chq_l varchar2(100);
    l_str_pd_l varchar2(100);

    l_xfdf_string              CLOB;


  BEGIN

    set_currency_mask(p_business_group_id);

    OPEN csr_get_DE (p_pact_id);
    FETCH csr_get_DE into l_input_date;
    CLOSE csr_get_DE;

    OPEN csr_get_PY(p_pact_id);
    FETCH csr_get_PY into l_py_name;
    CLOSE csr_get_PY;

    l_effective_date := last_day(l_input_date);

    INSERT INTO fnd_sessions (session_id, effective_date)
    VALUES (userenv('sessionid'), l_effective_date);

    -- To clear the PL/SQL Table values.

    vXMLTable.DELETE;
    vCtr := 1;

    dbms_lob.createtemporary(l_xfdf_string,FALSE,DBMS_LOB.CALL);
    dbms_lob.open(l_xfdf_string,dbms_lob.lob_readwrite);
    DBMS_LOB.CREATETEMPORARY(l_xfdf_blob,TRUE);
    clob_to_blob(l_xfdf_string,l_xfdf_blob);
    dbms_lob.writeAppend( l_xfdf_string, length('<START>'),'<START>');


    l_str_rep_label := '<REP_LABEL>' || get_lookup_meaning('KW_FORM_LABELS','KW_CHQR') || '</REP_LABEL>';
    dbms_lob.writeAppend( l_xfdf_string, length(l_str_rep_label),l_str_rep_label);

    l_str_py_label := '<PY_LABEL>' || get_lookup_meaning('KW_FORM_LABELS','PY_LABEL') || '</PY_LABEL>';
    dbms_lob.writeAppend( l_xfdf_string, length(l_str_py_label),l_str_py_label);

    l_str_py_name := '<PY_NAME>' || l_py_name || '</PY_NAME>';
    dbms_lob.writeAppend( l_xfdf_string, length(l_str_py_name),l_str_py_name);

    l_str_n := '<N>' || get_lookup_meaning('KW_FORM_LABELS','S_NO') || '</N>';
    dbms_lob.writeAppend( l_xfdf_string, length(l_str_n),l_str_n);

    l_str_name_l := '<NAME_L>' || get_lookup_meaning('KW_FORM_LABELS','NAME') || '</NAME_L>';
    dbms_lob.writeAppend( l_xfdf_string, length(l_str_name_l),l_str_name_l);

    l_str_eno_l := '<ENO_L>' || get_lookup_meaning('KW_FORM_LABELS','EMP_NO') || '</ENO_L>';
    dbms_lob.writeAppend( l_xfdf_string, length(l_str_eno_l),l_str_eno_l);

    l_str_org_l := '<ORG_L>' || get_lookup_meaning('KW_FORM_LABELS','ORG_L') || '</ORG_L>';
    dbms_lob.writeAppend( l_xfdf_string, length(l_str_org_l),l_str_org_l);

    l_str_job_l := '<JOB_L>' || get_lookup_meaning('KW_FORM_LABELS','JOB_L') || '</JOB_L>';
    dbms_lob.writeAppend( l_xfdf_string, length(l_str_job_l),l_str_job_l);

    l_str_amt_l := '<AMT_L>' || get_lookup_meaning('KW_FORM_LABELS','AMOUNT') || '</AMT_L>';
    dbms_lob.writeAppend( l_xfdf_string, length(l_str_amt_l),l_str_amt_l);

    l_str_chq_l := '<CHQ_L>' || get_lookup_meaning('KW_FORM_LABELS','CHQ_L') || '</CHQ_L>';
    dbms_lob.writeAppend( l_xfdf_string, length(l_str_chq_l),l_str_chq_l);

    l_str_pd_l := '<PD_L>' || get_lookup_meaning('KW_FORM_LABELS','PD_L') || '</PD_L>';
    dbms_lob.writeAppend( l_xfdf_string, length(l_str_pd_l),l_str_pd_l);



    hr_utility.set_location('Entering CHQR ',10);

    i := 0;

    If p_sort = 'ORG' then

 	open csr_get_assact_det_ORG (p_pact_id,l_effective_date);

 	LOOP
 		FETCH csr_get_assact_det_ORG INTO rec_get_assact;
 		EXIT WHEN csr_get_assact_det_ORG%NOTFOUND ;

 		i := i + 1;

 		t_store_assact(i).assignment_action_id := rec_get_assact.assignment_action_id;
 		t_store_assact(i).assignment_id := rec_get_assact.assignment_id;
 	END LOOP;

 	CLOSE csr_get_assact_det_ORG;

    Elsif p_sort = 'EMPNO' then
 	open csr_get_assact_det_EMPNO (p_pact_id,l_effective_date);

 	LOOP
 		FETCH csr_get_assact_det_EMPNO INTO rec_get_assact;
 		EXIT WHEN csr_get_assact_det_EMPNO%NOTFOUND ;

 		i := i + 1;

 		t_store_assact(i).assignment_action_id := rec_get_assact.assignment_action_id;
 		t_store_assact(i).assignment_id := rec_get_assact.assignment_id;
 	END LOOP;

 	CLOSE csr_get_assact_det_EMPNO;

    Elsif p_sort = 'DATE' then
 	open csr_get_assact_det_PD (p_pact_id,l_effective_date);

 	LOOP
 		FETCH csr_get_assact_det_PD INTO rec_get_assact;
 		EXIT WHEN csr_get_assact_det_PD%NOTFOUND ;

 		i := i + 1;

 		t_store_assact(i).assignment_action_id := rec_get_assact.assignment_action_id;
 		t_store_assact(i).assignment_id := rec_get_assact.assignment_id;
 	END LOOP;

 	CLOSE csr_get_assact_det_PD;
    End If;

 	j := 1;

 	seq := 1;

 	If i > 0 then

 		WHILE j <= i LOOP

			l_full_name := null;
			l_employee_number := null;
			l_organization_id	:= null;
			l_organization 	:= null;
			l_job := null;
			l_job_id := null;
			l_amount := null;
			l_chq_number  := null;
			l_chq_date := null;

			OPEN csr_get_DE (p_pact_id);
			FETCH csr_get_DE into l_chq_date;
			CLOSE csr_get_DE;

			OPEN csr_pay_date (t_store_assact(j).assignment_action_id);
			FETCH csr_pay_date into l_pay_date;
			CLOSE csr_pay_date;

			OPEN csr_get_per_det(t_store_assact(j).assignment_id , l_chq_date);
			FETCH csr_get_per_det into l_full_name,l_employee_number,l_job_id,l_organization_id;
			CLOSE csr_get_per_det;

			If l_job_id is not null then
				OPEN csr_job(l_job_id,l_chq_date);
				FETCH csr_job into l_job;
				CLOSE csr_job;
			End If;

			OPEN csr_org (l_organization_id,l_chq_date);
			FETCH csr_org INTO l_organization;
			close csr_org;

			OPEN csr_chq_det (t_store_assact(j).assignment_action_id,l_chq_date);
		     LOOP
			FETCH csr_chq_det into l_chq_number,l_amount;
			Exit when csr_chq_det%NOTFOUND;

				l_amount_fm := to_char(l_amount,lg_format_mask);

				dbms_lob.writeAppend( l_xfdf_string, length('<RECORD>'),'<RECORD>');

				l_str_seq := '<SNO>'||seq||'</SNO>';
				l_str_er_name1 := '<EENAME>'||substr(l_full_name,1,60)||'</EENAME>';
				l_str_er_name2 := '<EENO>'||l_employee_number||'</EENO>';
				l_str_er_name3 := '<EEORG>'||substr(l_organization,1,40)||'</EEORG>';
				l_str_er_name4 := '<EEJOB>'||substr(l_job,1,40)||'</EEJOB>';
				l_str_er_name5 := '<EEAMOUNT>'||l_amount_fm||'</EEAMOUNT>';
				l_str_er_name6 := '<EECHQ>'||l_chq_number||'</EECHQ>';
				l_str_er_name7 := '<EEDATE>'||l_pay_date||'</EEDATE>';

				dbms_lob.writeAppend( l_xfdf_string, length(l_str_seq), l_str_seq);
				dbms_lob.writeAppend( l_xfdf_string, length(l_str_er_name1), l_str_er_name1);
				dbms_lob.writeAppend( l_xfdf_string, length(l_str_er_name2), l_str_er_name2);
				dbms_lob.writeAppend( l_xfdf_string, length(l_str_er_name3), l_str_er_name3);
				dbms_lob.writeAppend( l_xfdf_string, length(l_str_er_name4), l_str_er_name4);
				dbms_lob.writeAppend( l_xfdf_string, length(l_str_er_name5), l_str_er_name5);
				dbms_lob.writeAppend( l_xfdf_string, length(l_str_er_name6), l_str_er_name6);
				dbms_lob.writeAppend( l_xfdf_string, length(l_str_er_name7), l_str_er_name7);

				dbms_lob.writeAppend( l_xfdf_string, length('</RECORD>'),'</RECORD>');
				seq := seq + 1;
		     END LOOP;
 			CLOSE csr_chq_det;
				j := j + 1;

 		END LOOP;
 	End If;

 	dbms_lob.writeAppend( l_xfdf_string, length('</START>'),'</START>');

    hr_utility.set_location('Finished creating xml data for Procedure CHQR ',20);

    DBMS_LOB.CREATETEMPORARY(l_xfdf_blob,TRUE);
    clob_to_blob(l_xfdf_string,l_xfdf_blob);


/*EXCEPTION
        WHEN utl_file.invalid_path then
                hr_utility.set_message(8301, 'GHR_38830_INVALID_UTL_FILE_PATH');
                fnd_file.put_line(fnd_file.log,HR_UTILITY.get_message);
                hr_utility.raise_error;
--
    WHEN utl_file.invalid_mode then
        hr_utility.set_message(8301, 'GHR_38831_INVALID_FILE_MODE');
        fnd_file.put_line(fnd_file.log,HR_UTILITY.get_message);
                hr_utility.raise_error;
--
    WHEN utl_file.invalid_filehandle then
        hr_utility.set_message(8301, 'GHR_38832_INVALID_FILE_HANDLE');
        fnd_file.put_line(fnd_file.log,HR_UTILITY.get_message);
                hr_utility.raise_error;
--
    WHEN utl_file.invalid_operation then
        hr_utility.set_message(8301, 'GHR_38833_INVALID_OPER');
        fnd_file.put_line(fnd_file.log,HR_UTILITY.get_message);
                hr_utility.raise_error;
--
    WHEN utl_file.read_error then
        hr_utility.set_message(8301, 'GHR_38834_FILE_READ_ERROR');
        fnd_file.put_line(fnd_file.log,HR_UTILITY.get_message);
                hr_utility.raise_error;
--
    WHEN others THEN
       hr_utility.set_message(800,'FFU10_GENERAL_ORACLE_ERROR');
       hr_utility.set_message_token('2',substr(sqlerrm,1,200));
       fnd_file.put_line(fnd_file.log,HR_UTILITY.get_message);
           hr_utility.raise_error;*/
  END CHEQUE_LISTING;
-------------------------------------------------------------------------------------------

  PROCEDURE WritetoCLOB
    (p_xfdf_blob out nocopy blob)
  IS
    l_xfdf_string clob;
    l_str1 varchar2(1000);
    l_str2 varchar2(20);
    l_str3 varchar2(20);
    l_str4 varchar2(20);
    l_str5 varchar2(20);
    l_str6 varchar2(30);
    l_str7 varchar2(1000);
    l_str8 varchar2(240);
    l_str9 varchar2(240);
  BEGIN
    hr_utility.set_location('Entered Procedure Write to clob ',100);
    l_str1 := '<?xml version="1.0" encoding="UTF-8"?>
      		 <xfdf xmlns="http://ns.adobe.com/xfdf/" xml:space="preserve">
      		 <fields> ' ;
    l_str2 := '<field name="';
    l_str3 := '">';
    l_str4 := '<value>' ;
    l_str5 := '</value> </field>' ;
    l_str6 := '</fields> </xfdf>';
    l_str7 := '<?xml version="1.0" encoding="UTF-8"?>
	       <xfdf xmlns="http://ns.adobe.com/xfdf/" xml:space="preserve">
       	       <fields>
       	       </fields> </xfdf>';
    dbms_lob.createtemporary(l_xfdf_string,FALSE,DBMS_LOB.CALL);
    dbms_lob.open(l_xfdf_string,dbms_lob.lob_readwrite);
    if vXMLTable.COUNT > 0 then
      dbms_lob.writeAppend( l_xfdf_string, length(l_str1), l_str1 );
      FOR ctr_table IN vXMLTable.FIRST .. vXMLTable.LAST LOOP
        l_str8 := vXMLTable(ctr_table).TagName;
        l_str9 := vXMLTable(ctr_table).TagValue;
        if (l_str9 is not null) then
	  dbms_lob.writeAppend( l_xfdf_string, length(l_str2), l_str2 );
	  dbms_lob.writeAppend( l_xfdf_string, length(l_str8),l_str8);
	  dbms_lob.writeAppend( l_xfdf_string, length(l_str3), l_str3 );
	  dbms_lob.writeAppend( l_xfdf_string, length(l_str4), l_str4 );
	  dbms_lob.writeAppend( l_xfdf_string, length(l_str9), l_str9);
	  dbms_lob.writeAppend( l_xfdf_string, length(l_str5), l_str5 );
	elsif (l_str9 is null and l_str8 is not null) then
	  dbms_lob.writeAppend(l_xfdf_string,length(l_str2),l_str2);
	  dbms_lob.writeAppend(l_xfdf_string,length(l_str8),l_str8);
	  dbms_lob.writeAppend(l_xfdf_string,length(l_str3),l_str3);
	  dbms_lob.writeAppend(l_xfdf_string,length(l_str4),l_str4);
	  dbms_lob.writeAppend(l_xfdf_string,length(l_str5),l_str5);
	else
	  null;
	end if;
      END LOOP;
      dbms_lob.writeAppend( l_xfdf_string, length(l_str6), l_str6 );
    else
      dbms_lob.writeAppend( l_xfdf_string, length(l_str7), l_str7 );
    end if;
    DBMS_LOB.CREATETEMPORARY(p_xfdf_blob,TRUE);
    clob_to_blob(l_xfdf_string,p_xfdf_blob);
    hr_utility.set_location('Finished Procedure Write to CLOB ,Before clob to blob ',110);
	--return p_xfdf_blob;
  EXCEPTION
    WHEN OTHERS then
      HR_UTILITY.TRACE('sqleerm ' || SQLERRM);
      HR_UTILITY.RAISE_ERROR;
  END WritetoCLOB;
----------------------------------------------------------------
  Procedure  clob_to_blob
    (p_clob clob,
    p_blob IN OUT NOCOPY Blob)
  is
    l_length_clob number;
    l_offset pls_integer;
    l_varchar_buffer varchar2(32767);
    l_raw_buffer raw(32767);
    l_buffer_len number;
    l_chunk_len number;
    l_blob blob;
    g_nls_db_char varchar2(60);
    l_raw_buffer_len pls_integer;
    l_blob_offset    pls_integer := 1;
  begin
    l_buffer_len := 20000;
    hr_utility.set_location('Entered Procedure clob to blob',120);
    select userenv('LANGUAGE') into g_nls_db_char from dual;
    l_length_clob := dbms_lob.getlength(p_clob);
    l_offset := 1;
    while l_length_clob > 0 loop
      hr_utility.trace('l_length_clob '|| l_length_clob);
      if l_length_clob < l_buffer_len then
        l_chunk_len := l_length_clob;
      else
        l_chunk_len := l_buffer_len;
      end if;
      DBMS_LOB.READ(p_clob,l_chunk_len,l_offset,l_varchar_buffer);
      fnd_file.put_line(fnd_file.log,l_varchar_buffer);
      --l_raw_buffer := utl_raw.cast_to_raw(l_varchar_buffer);
      l_raw_buffer := utl_raw.convert(utl_raw.cast_to_raw(l_varchar_buffer),'American_America.UTF8',g_nls_db_char);
      l_raw_buffer_len := utl_raw.length(utl_raw.convert(utl_raw.cast_to_raw(l_varchar_buffer),'American_America.UTF8',g_nls_db_char));
      hr_utility.trace('l_varchar_buffer '|| l_varchar_buffer);
      --dbms_lob.write(p_blob,l_chunk_len, l_offset, l_raw_buffer);
      dbms_lob.write(p_blob,l_raw_buffer_len, l_blob_offset, l_raw_buffer);
      l_blob_offset := l_blob_offset + l_raw_buffer_len;
      l_offset := l_offset + l_chunk_len;
      l_length_clob := l_length_clob - l_chunk_len;
      hr_utility.trace('l_length_blob '|| dbms_lob.getlength(p_blob));
    end loop;
    hr_utility.set_location('Finished Procedure clob to blob ',130);
  end clob_to_blob;
------------------------------------------------------------------
  Procedure fetch_pdf_blob
	(p_report in varchar2,
	 p_pdf_blob OUT NOCOPY blob)
  IS
  BEGIN
    IF (p_report='CHQR') THEN
      Select file_data
      Into p_pdf_blob
      From fnd_lobs
      Where file_id = (select max(file_id) from fnd_lobs where file_name like '%PAY_CHQ_ar_KW.rtf');
    END IF;

  EXCEPTION
    when no_data_found then
      null;
  END fetch_pdf_blob;
-------------------------------------------------------------------
END pay_kw_cheque_report;

/

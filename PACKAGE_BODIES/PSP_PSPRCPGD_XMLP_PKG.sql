--------------------------------------------------------
--  DDL for Package Body PSP_PSPRCPGD_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSP_PSPRCPGD_XMLP_PKG" AS
/* $Header: PSPRCPGDB.pls 120.4 2007/10/29 07:27:29 amakrish noship $ */

--function cf_assignment_numberformula(assignment_id in number) return varchar2 is
function cf_assignment_numberformula(v_assignment_id in number) return varchar2 is
  x_assignment_number	VARCHAR2(30);
begin


	  select assignment_number
	  into x_assignment_number
	  from per_assignments_f
--	  where assignment_id = assignment_id
	  where assignment_id = v_assignment_id
	  AND	assignment_type ='E'		  and rownum < 2; 	  	  	  return(x_assignment_number);


RETURN NULL; exception
  when no_data_found then
  return('no_data_found');
  when too_many_rows then
  return('too many rows');
  when others then
  return('error');
end;

--function cf_person_nameformula(person_id in number) return varchar2 is
function cf_person_nameformula(v_person_id in number) return varchar2 is
  x_person_name		VARCHAR2(240);
  x_end_date		DATE;
begin
  select end_date into x_end_date
  from per_time_periods
  where time_period_id = p_time_period_id;

  select full_name into x_person_name
  from per_people_f
--  where person_id = person_id
  where person_id = v_person_id
  and x_end_date BETWEEN effective_start_date and effective_end_date;

  return(x_person_name);
RETURN NULL; exception
  when no_data_found then
  return('no data found');
  when too_many_rows then
  return('too many rows');
end;

function AfterPForm return boolean is
begin
--  orientation := 'LANDSCAPE';



  select start_date into p_start_date
  from per_time_periods
  where time_period_id = p_time_period_id;
  return (TRUE);
  RETURN NULL; exception when no_data_found then
    /*srw.message(1,'Start Date not found for the selected time period id');*/null;

    return (FALSE);
  when too_many_rows then
    /*srw.message(2,'Too many rows found for the selected time period id');*/null;

    return (FALSE);
  when others then
    /*srw.message(3,'Others exception raised');*/null;

  return (FALSE);



end;

function cf_mismatch_eltformula(cf_amt_dl_d in number, sl_debit_amount in number, cf_amt_sl_c in number) return varchar2 is
begin


if NVL(cf_amt_dl_d,0) <> NVL(sl_debit_amount,0)
or NVL(cp_credit_amount_pgdl,0) <> NVL(cf_amt_sl_c,0)
then
	return('Mismatch');
end if;

RETURN NULL;
end;

function cf_mismatch_assgformula(sum_dl_d_assg in number, sum_sl_d_assg in number, sum_dl_c_assg in number, sum_sl_c_assg in number) return varchar2 is
begin
  if NVL(sum_dl_d_assg,0) <> NVL(sum_sl_d_assg,0) or NVL(sum_dl_c_assg,0) <> NVL(sum_sl_c_assg,0) then
	return('Mismatch');
  end if;
RETURN NULL; end;

function cf_mismatch_personformula(sum_dl_d_person in number, sum_sl_d_person in number, sum_dl_c_person in number, sum_sl_c_person in number) return varchar2 is
begin
  if NVL(sum_dl_d_person,0) <> NVL(sum_sl_d_person,0) or NVL(sum_dl_c_person,0) <> NVL(sum_sl_c_person,0) then
	return('Mismatch');
  end if;
RETURN NULL; end;

function cf_mismatch_reportformula(sum_dl_d_total in number, sum_sl_d_total in number, sum_dl_c_total in number, sum_sl_c_total in number) return varchar2 is
begin
  if NVL(sum_dl_d_total,0) <> NVL(sum_sl_d_total,0) or NVL(sum_dl_c_total,0) <> NVL(sum_sl_c_total,0) then
	return('Mismatch');
  end if;
RETURN NULL; end;

function cf_amt_sl_cformula(gl_code_combination_id in number, sl_credit_amount in number) return number is
   x_amount_summary	NUMBER ; begin


IF   gl_code_combination_id	IS NULL	THEN
	x_amount_summary := ABS(sl_credit_amount);
ELSE
	x_amount_summary := sl_credit_amount;
END IF;
	return(x_amount_summary);









RETURN NULL; exception
  when no_data_found then
  return(null);
end;

--function cf_amt_dl_dformula(gl_code_combination_id in number) return number is
function cf_amt_dl_dformula(v_person_id in number, v_assignment_id in number, v_gl_code_combination_id in number, v_project_id in number, v_task_id in number,
v_award_id in number, v_expenditure_type in varchar2, v_expenditure_organization_id in number) return number is
  	v_debit_amount_pgdl	NUMBER := 0 ;
 	v_suspense_code	VARCHAR2(500) :='';
	v_cr			NUMBER  := 0 ; 	v_dr			NUMBER  := 0; 	i			PLS_INTEGER   := 0;

			CURSOR	c_suspense_gl
	IS
	SELECT 	sum(decode(a.dr_cr_flag, 'C',b.distribution_amount,0)) pgdl_Credit_Amount,
		sum(decode(a.dr_cr_flag, 'D',b.distribution_amount,0)) pgdl_Debit_Amount,
		B.suspense_reason_code		FROM 	PSP_SUMMARY_LINES A,
		PSP_PRE_GEN_DIST_LINES_HISTORY B
	WHERE 	A.SUMMARY_LINE_ID 	= B.SUMMARY_LINE_ID
	AND 	A.STATUS_CODE 		= 'A' AND B.STATUS_CODE = 'A'
	AND	a.source_type 		= p_source_type
	and 	a.source_code 		= p_source_code
	and 	a.time_period_id 	= p_time_period_id
	and 	(a.interface_batch_name = p_batch_name or a.interface_batch_name IS NULL)
--	and 	a.person_id 		= person_id
--	and 	a.assignment_id 	= assignment_id
--	and 	a.gl_code_combination_id = gl_code_combination_id
	and 	a.person_id 		= v_person_id
	and 	a.assignment_id 	= v_assignment_id
	and 	a.gl_code_combination_id = v_gl_code_combination_id
	GROUP BY	B.suspense_reason_code;


	CURSOR	c_suspense_poeta
	IS
	SELECT 	sum(decode(a.dr_cr_flag, 'C',b.distribution_amount,0)) pgdl_Credit_Amount,
		sum(decode(a.dr_cr_flag, 'D',b.distribution_amount,0)) pgdl_Debit_Amount,
		B.suspense_reason_code 	FROM 	PSP_SUMMARY_LINES A,
		PSP_PRE_GEN_DIST_LINES_HISTORY B
	WHERE 	A.SUMMARY_LINE_ID 	= B.SUMMARY_LINE_ID
	AND 	A.STATUS_CODE 		= 'A' AND B.STATUS_CODE = 'A'
	AND	a.source_type 		= p_source_type
	and 	a.source_code 		= p_source_code
	and 	a.time_period_id 	= p_time_period_id
	and 	(a.interface_batch_name = p_batch_name or a.interface_batch_name IS NULL)
--	and 	a.person_id 		= person_id
--	and 	a.assignment_id 	= assignment_id
--	and 	A.project_id 		= project_id
--	and 	a.task_id 		= task_id
--	and 	(	a.award_id 		= award_id
--		OR	(a.award_id IS NULL AND award_id IS NULL))
--	and 	a.expenditure_type 	= expenditure_type
--	and 	a.expenditure_organization_id = expenditure_organization_id
	and 	a.person_id 		= v_person_id
	and 	a.assignment_id 	= v_assignment_id
	and 	A.project_id 		= v_project_id
	and 	a.task_id 		= v_task_id
	and 	(	a.award_id 		= v_award_id
--		OR	(a.award_id IS NULL AND award_id IS NULL))
		OR	(a.award_id IS NULL AND v_award_id IS NULL))
	and 	a.expenditure_type 	= v_expenditure_type
	and 	a.expenditure_organization_id = v_expenditure_organization_id
	GROUP BY	B.suspense_reason_code;


BEGIN


	cp_credit_amount_pgdl  := 0;
	cp_suspense         	:= '';


--	IF gl_code_combination_id IS NOT NULL THEN
	IF v_gl_code_combination_id IS NOT NULL THEN

				OPEN c_suspense_gl;
		LOOP

		    FETCH c_suspense_gl
		    INTO  v_cr, v_dr, v_suspense_code;

		    EXIT WHEN c_suspense_gl%NOTFOUND;

		    cp_credit_amount_pgdl := cp_credit_amount_pgdl  + v_cr;
		    v_debit_amount_pgdl    := v_debit_amount_pgdl + v_dr;

		    IF    v_suspense_code IS NOT NULL
		    THEN
			    i := i+1;
			    IF 	  i = 1
			    THEN
				  cp_suspense := 'Suspense Reason: '||v_suspense_code;
			    ELSE
				   				  cp_suspense := cp_suspense||', '||v_suspense_code;
			    END IF;
		    END IF;

		END LOOP;
		CLOSE c_suspense_gl;

	ELSE
				OPEN c_suspense_poeta;
		LOOP

		    FETCH c_suspense_poeta
		    INTO  v_cr, v_dr, v_suspense_code;

		    EXIT WHEN c_suspense_poeta%NOTFOUND;

		    cp_credit_amount_pgdl := cp_credit_amount_pgdl    + v_cr;
		    v_debit_amount_pgdl    := v_debit_amount_pgdl    + v_dr;

		    IF    v_suspense_code IS NOT NULL
		    THEN
			    i := i + 1;

			    IF 	  i = 1
			    THEN
				  cp_suspense := 'Suspense Reason: '||v_suspense_code;
			    ELSE
				   				  cp_suspense := cp_suspense||', '||v_suspense_code;
			    END IF;
		    END IF;

		END LOOP;
		CLOSE c_suspense_poeta;

	END IF;

return(v_debit_amount_pgdl);
RETURN NULL;

EXCEPTION
WHEN NO_DATA_FOUND THEN
	return(null);

END;

function CF_org_reportFormula return VARCHAR2 is
  x_org_name 	hr_all_organization_units_tl.name%TYPE;	  x_org_id	varchar2(15);
begin
  fnd_profile.get('PSP_ORG_REPORT', x_org_id);
  if x_org_id is not null then
	select name into x_org_name from hr_organization_units				where organization_id = TO_NUMBER(x_org_id);
	return(x_org_name);
  end if;

  RETURN NULL;


EXCEPTION
	WHEN NO_DATA_FOUND
	THEN
		RETURN('Organization Defined in Profile Not Found');


end;

function BeforeReport return boolean is
begin

--	hr_standard.event('BEFORE REPORT');
  return (TRUE);
end;

function CF_source_typeFormula return VARCHAR2 is
  x_source_type		varchar2(80);
begin
  select meaning into x_source_type from psp_lookups
  where lookup_type = 'PSP_SOURCE_TYPE' and lookup_code = p_source_type;
  return(x_source_type);
end;

function CF_time_periodFormula return VARCHAR2 is
  x_time_period		varchar2(35);
begin
  if p_time_period_id is not null then
  	select period_name into x_time_period from per_time_periods
  	where time_period_id = p_time_period_id;
  	return(x_time_period);
  end if;
RETURN NULL; end;

--function cf_charging_instructionsformu(project_id in number, task_id in number, award_id in number, expenditure_organization_id in number, gl_code_combination_id in number) return char is
function cf_charging_instructionsformu(v_project_id in number, v_task_id in number, v_award_id in number, v_expenditure_organization_id in number, v_gl_code_combination_id in number, v_expenditure_type in varchar2) return char is
 	v_retcode 		NUMBER;
	l_project_name 		VARCHAR2(30);
	l_award_number		VARCHAR2(15);
	l_task_number		VARCHAR2(25);
	l_org_name		hr_all_organization_units_tl.name%TYPE;		l_poeta			VARCHAR2(360);					l_gl_flex_values 	VARCHAR2(2000);

	CURSOR c_project_name
	IS
	SELECT ppa.name
	FROM   pa_projects_all ppa
--	WHERE  ppa.project_id = project_id;
	WHERE  ppa.project_id = v_project_id;

	CURSOR	c_task_number
	IS
	SELECT	pt.task_number
	FROM 	pa_tasks pt
--	WHERE   pt.task_id = task_id;
	WHERE   pt.task_id = v_task_id;

	CURSOR  c_award_number
	IS
	SELECT	gma.award_number
	FROM	gms_awards_all gma
--	WHERE	gma.award_id = award_id;
	WHERE	gma.award_id = v_award_id;

	CURSOR	c_org_name
	IS
	SELECT	haou.name
	FROM	hr_all_organization_units haou
--	WHERE	haou.organization_id = expenditure_organization_id;
	WHERE	haou.organization_id = v_expenditure_organization_id;

BEGIN

--		IF gl_code_combination_id IS NOT NULL
		IF v_gl_code_combination_id IS NOT NULL
	THEN
--	l_gl_flex_values := psp_general.get_gl_values(to_number(p_set_of_books_id),gl_code_combination_id);
	l_gl_flex_values := psp_general.get_gl_values(to_number(p_set_of_books_id),v_gl_code_combination_id);
	RETURN (l_gl_flex_values);

	ELSE

--						IF project_id IS NOT NULL
				IF v_project_id IS NOT NULL
			        THEN

				OPEN 	c_project_name;
				FETCH   c_project_name INTO   l_project_name;
				CLOSE	c_project_name;

				OPEN 	c_task_number;
				FETCH	c_task_number	INTO	 l_task_number;
				CLOSE	c_task_number;


--				IF award_id IS NOT NULL
				IF v_award_id IS NOT NULL
				THEN
					OPEN    c_award_number;
					FETCH   c_award_number	INTO	 l_award_number;
					CLOSE	c_award_number;
				ELSE
					l_award_number := '';
				END IF;

					OPEN 	c_org_name;
					FETCH	c_org_name 	INTO	 l_org_name;
					CLOSE	c_org_name;


--	l_poeta := l_project_name||' '||l_task_number||' '||l_award_number||' '||l_org_name||' '||expenditure_type;
	l_poeta := l_project_name||' '||l_task_number||' '||l_award_number||' '||l_org_name||' '||v_expenditure_type;

			 				ELSE
				l_poeta := '';
			END IF;

	RETURN(l_poeta);
	END IF;
END;

function cf_currency_codeformula(currency_code in varchar2) return char is
begin

  /*srw.reference(currency_code);*/null;

  RETURN('(' || currency_code || ')');


end;

function cf_currency_formatformula(currency_code in varchar2) return char is
begin

  /*srw.reference(currency_code);*/null;

  RETURN(fnd_currency.get_format_mask(currency_code,30));

end;

function cf_sum_sl_d_total_dspformula(cs_sum_sl_d_total in number, cf_currency_format in varchar2) return char is
begin

   /*srw.reference(cs_sum_sl_d_total);*/null;

   /*srw.reference(cf_currency_format);*/null;

   RETURN(TO_CHAR(cs_sum_sl_d_total,cf_currency_format));


end;

function cf_sum_sl_c_total_dspformula(cs_sum_sl_c_total in number, cf_currency_format in varchar2) return char is
begin

   /*srw.reference(cs_sum_sl_c_total);*/null;

   /*srw.reference(cf_currency_format);*/null;

   RETURN(TO_CHAR(cs_sum_sl_c_total,cf_currency_format));

end;

function cf_sum_dl_d_total_dspformula(cs_sum_dl_d_total in number, cf_currency_format in varchar2) return char is
begin

   /*srw.reference(cs_sum_dl_d_total);*/null;

   /*srw.reference(cf_currency_format);*/null;

   RETURN(TO_CHAR(cs_sum_dl_d_total,cf_currency_format));


end;

function cf_sum_dl_c_total_dspformula(cs_sum_dl_c_total in number, cf_currency_format in varchar2) return char is
begin

   /*srw.reference(cs_sum_dl_c_total);*/null;

   /*srw.reference(cf_currency_format);*/null;

   RETURN(TO_CHAR(cs_sum_dl_c_total,cf_currency_format));


end;

function cf_mismatch_currency_totalform(cs_sum_dl_d_total in number, cs_sum_sl_d_total in number, cs_sum_dl_c_total in number, cs_sum_sl_c_total in number) return char is
begin

if NVL(cs_sum_dl_d_total,0) <> NVL(cs_sum_sl_d_total,0) or NVL(cs_sum_dl_c_total,0) <> NVL(cs_sum_sl_c_total,0) then
	return('Mismatch');
  end if;
RETURN NULL;

end;

function cf_sum_sl_d_person_dspformula(sum_sl_d_person in number, cf_currency_format in varchar2) return char is
begin

    /*srw.reference(sum_sl_d_person);*/null;

    /*srw.reference(cf_currency_format);*/null;

    RETURN(TO_CHAR(sum_sl_d_person,cf_currency_format));

end;

function cf_sum_sl_c_person_dspformula(sum_sl_c_person in number, cf_currency_format in varchar2) return char is
begin

    /*srw.reference(sum_sl_c_person);*/null;

    /*srw.reference(cf_currency_format);*/null;

    RETURN(TO_CHAR(sum_sl_c_person,cf_currency_format));

end;

function cf_sum_dl_d_person_dspformula(sum_dl_d_person in number, cf_currency_format in varchar2) return char is
begin

    /*srw.reference(sum_dl_d_person);*/null;

    /*srw.reference(cf_currency_format);*/null;

    RETURN(TO_CHAR(sum_dl_d_person,cf_currency_format));

end;

function cf_sum_dl_c_person_dspformula(sum_dl_c_person in number, cf_currency_format in varchar2) return char is
begin

    /*srw.reference(sum_dl_c_person);*/null;

    /*srw.reference(cf_currency_format);*/null;

    RETURN(TO_CHAR(sum_dl_c_person,cf_currency_format));

end;

function cf_sum_sl_d_assg_dspformula(sum_sl_d_assg in number, cf_currency_format in varchar2) return char is
begin

    /*srw.reference(sum_sl_d_assg);*/null;

    /*srw.reference(cf_currency_format);*/null;

    RETURN(TO_CHAR(sum_sl_d_assg,cf_currency_format));

end;

function cf_sum_sl_c_assg_dspformula(sum_sl_c_assg in number, cf_currency_format in varchar2) return char is
begin

    /*srw.reference(sum_sl_c_assg);*/null;

    /*srw.reference(cf_currency_format);*/null;

    RETURN(TO_CHAR(sum_sl_c_assg,cf_currency_format));

end;

function cf_sum_dl_d_assg_dspformula(sum_dl_d_assg in number, cf_currency_format in varchar2) return char is
begin

    /*srw.reference(sum_dl_d_assg);*/null;

    /*srw.reference(cf_currency_format);*/null;

    RETURN(TO_CHAR(sum_dl_d_assg,cf_currency_format));

end;

function cf_sum_dl_c_assg_dspformula(sum_dl_c_assg in number, cf_currency_format in varchar2) return char is
begin

    /*srw.reference(sum_dl_c_assg);*/null;

    /*srw.reference(cf_currency_format);*/null;

    RETURN(TO_CHAR(sum_dl_c_assg,cf_currency_format));

end;

function cf_amt_dl_d_dspformula(cf_amt_dl_d in number, cf_currency_format in varchar2) return char is
begin

   /*srw.reference(cf_amt_dl_d);*/null;

   /*srw.reference(cf_currency_format);*/null;

   RETURN(TO_CHAR(cf_amt_dl_d,cf_currency_format));

end;

function cf_sl_debit_amount_dspformula(sl_debit_amount in number, cf_currency_format in varchar2) return char is
begin

  /*srw.reference(sl_debit_amount);*/null;

  /*srw.reference(cf_currency_format);*/null;

  RETURN(TO_CHAR(sl_debit_amount,cf_currency_format));

end;

function cf_amt_sl_c_dspformula(cf_amt_sl_c in number, cf_currency_format in varchar2) return char is
begin

  /*srw.reference(cf_amt_sl_c);*/null;

  /*srw.reference(cf_currency_format);*/null;

  RETURN(TO_CHAR(cf_amt_sl_c,cf_currency_format));

end;

function cf_credit_amount_pgdl_dspformu(cf_currency_format in varchar2) return char is
begin

  /*srw.reference(cp_credit_amount_pgdl);*/null;

  /*srw.reference(cf_currency_format);*/null;

  RETURN(TO_CHAR(cp_credit_amount_pgdl,cf_currency_format));

end;

function AfterReport return boolean is
begin
--	hr_standard.event('AFTER REPORT');
  return (TRUE);
end;

--Functions to refer Oracle report placeholders--

 Function CP_suspense_p return varchar2 is
	Begin
	 return CP_suspense;
	 END;
 Function CP_credit_amount_pgdl_p return number is
	Begin
	 return CP_credit_amount_pgdl;
	 END;
END PSP_PSPRCPGD_XMLP_PKG ;

/

--------------------------------------------------------
--  DDL for Package Body PQH_TENURE_DETAIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_TENURE_DETAIL" AS
/* $Header: pqhusprn.pkb 120.2 2005/08/17 11:25:18 nsanghal noship $ */

  PROCEDURE  getPersonInfo (
		p_person_id 	  IN	NUMBER,
		p_employee_number OUT NOCOPY  VARCHAR2,
		p_full_name	 OUT NOCOPY VARCHAR2,
		p_last_name	 OUT NOCOPY VARCHAR2,
		p_title		 OUT NOCOPY VARCHAR2,
		p_email_addr	 OUT NOCOPY VARCHAR2,
		p_start_date	 OUT NOCOPY DATE ) IS

	CURSOR	emp_cur IS
	SELECT	employee_number, full_name, last_name, title, email_address, start_date
	FROM	per_all_people_f
	WHERE	SYSDATE	BETWEEN effective_start_date and effective_end_date
	AND	person_id 	= p_person_id;

	l_title	VARCHAR2(30);
  BEGIN
  	OPEN	emp_cur;
	FETCH	emp_cur INTO  p_employee_number,p_full_name, p_last_name, l_title, p_email_addr, p_start_date;
	CLOSE	emp_cur;
	p_title	:= hr_general.decode_lookup(p_lookup_type => 'TITLE',p_lookup_code => l_title);
exception
 when others then
   p_employee_number := null;
   p_full_name	 := null;
   p_last_name	 := null;
   p_title       := null;
   p_email_addr	 := null;
   p_start_date	 := null;
  END;

  PROCEDURE  getPersonTenure (
		p_person_id 	IN	NUMBER,
		p_tenure_status OUT NOCOPY VARCHAR2,
		p_date_determine OUT NOCOPY VARCHAR2,
		p_adjust_date	 OUT NOCOPY VARCHAR2,
		p_remain_years	OUT NOCOPY VARCHAR2,
		p_remain_months	OUT NOCOPY VARCHAR2,
		p_completed_years OUT NOCOPY VARCHAR2,
		p_completed_months OUT NOCOPY VARCHAR2 ) IS

	CURSOR 	emp_tenure_cur IS
	SELECT	pei_information1 tenure_status,
		FND_DATE.canonical_to_date(PEI_INFORMATION2) date_determined,
		FND_DATE.canonical_to_date(nvl(PEI_INFORMATION4,PEI_INFORMATION3))  adjusted_tenure_date
	FROM	per_people_extra_info
	WHERE	person_id	= p_person_id
	AND	information_type = 'PQH_TENURE_STATUS' ;

/*   Join with HR_LOOKUPS to get the Tenure Status Description. */
  l_date_determine	date;
  l_adjust_date	        date;

  BEGIN
		OPEN	emp_tenure_cur;
		FETCH	emp_tenure_cur INTO p_tenure_status, l_date_determine, l_adjust_date;
		CLOSE	emp_tenure_cur;

		p_date_determine := fnd_date.date_to_displaydate(l_date_determine);
		p_adjust_date	 := fnd_date.date_to_displaydate(l_adjust_date);

		p_remain_years	 := TRUNC((l_adjust_date - trunc(SYSDATE) ) / 365 );
		p_remain_months	 := ROUND( MOD ((l_adjust_date - trunc(SYSDATE)) , 365) / 30 );

		p_completed_years  := TRUNC((trunc(SYSDATE) - l_date_determine) / 365 );
		p_completed_months := ROUND( MOD ((trunc(SYSDATE) - l_date_determine),365) / 30);

exception when others then
p_tenure_status := null;
p_date_determine := null;
p_adjust_date	 := null;
p_remain_years	 := null;
p_remain_months	 := null;
p_completed_years := null;
p_completed_months := null;
  END;

  FUNCTION getPersonAddress (
		p_person_id	IN	NUMBER,
		p_bgroup_id	IN	NUMBER ) RETURN VARCHAR2 IS

	CURSOR	emp_addr_cur IS
	SELECT	address_line1||DECODE(NVL(address_line2,'X'),'X',FND_GLOBAL.local_chr(10),', '||address_line2||
		FND_GLOBAL.local_chr(10))|| DECODE(NVL(address_line3,'X'),'X','',address_line3||FND_GLOBAL.local_chr(10))||
		town_or_city||', '||region_2||' '||postal_code
	FROM	per_addresses
	WHERE	SYSDATE 	        BETWEEN date_from AND NVL(date_to,SYSDATE)
	AND	person_id  		= p_person_id
	AND	business_group_id	= p_bgroup_id
	AND	primary_flag 		= 'Y';

	l_address		VARCHAR2(1000);
  BEGIN
	OPEN	emp_addr_cur;
	FETCH	emp_addr_cur INTO l_address;
	CLOSE	emp_addr_cur;

	RETURN	l_address;
  END;

  FUNCTION getPersonSupervisor ( p_person_id 	IN 	NUMBER ) RETURN NUMBER IS

 	CURSOR	emp_super_cur IS
	SELECT	supervisor_id
	FROM	per_all_assignments_f
	WHERE	person_id	= p_person_id
	AND	primary_flag	= 'Y'
	AND	SYSDATE		BETWEEN effective_start_date and effective_end_date;

	 l_supervisor_id	NUMBER;
  BEGIN

	OPEN	emp_super_cur;
	FETCH	emp_super_cur INTO l_supervisor_id;
	CLOSE	emp_super_cur;
	RETURN	l_supervisor_id;
  END;

  FUNCTION getPersonRank (p_person_id 	 IN 	NUMBER ) RETURN VARCHAR2 IS

	CURSOR 	emp_rank_cur IS
	SELECT	hr_general.decode_lookup('PQH_ACADEMIC_RANK',pei_information1)
	FROM	per_people_extra_info
	WHERE	person_id		= p_person_id
	AND	information_type	= 'PQH_ACADEMIC_RANK' ;

	l_academic_rank hr_lookups.meaning%type;

 	BEGIN
	   OPEN	emp_rank_cur;
	   FETCH emp_rank_cur INTO l_academic_rank;
	   CLOSE emp_rank_cur;
	   RETURN l_academic_rank;
	END;

  FUNCTION getPersonJobPosition ( p_person_id	IN NUMBER ) RETURN VARCHAR2 IS

	CURSOR	prim_asg	IS
	SELECT	assignment_id,job_id,position_id
	FROM	per_all_assignments_f	paf
	WHERE 	paf.person_id		= p_person_id
        and     sysdate between effective_start_date and effective_end_date
        and     primary_flag = 'Y'
        and     assignment_type = 'E';

	l_assignment_id	number;
        l_job_id number;
        l_position_id number;
        l_job_name per_jobs.name%type;
        l_position_name hr_all_positions_f.name%type;
	BEGIN
 -- fetch the primary assignment
	   OPEN	prim_asg;
	   FETCH prim_asg INTO l_assignment_id,l_job_id,l_position_id;
	   CLOSE prim_asg;
           if l_position_id is not null then
              l_position_name := hr_general.decode_position_latest_name(l_position_id);
           elsif l_job_id is not null then
              l_job_name := hr_general.decode_job(l_job_id);
           end if;
	   RETURN nvl(l_job_name,l_position_name);
	END;

  FUNCTION getManagerSequence RETURN NUMBER IS
	BEGIN
	   managerSeq	:= managerSeq	+ 1;
	   RETURN (managerSeq);
	END;

  FUNCTION  getSupStatusCount (
		p_supervisor_id		IN NUMBER,
		p_tenure_status		IN VARCHAR2,
		p_effective_date		IN DATE     ) RETURN NUMBER IS

	/* Headcount of Tenure status till now for a supervisor */
	CURSOR	prsn_status_cnt_cur	IS
	SELECT	COUNT(paf.person_id)
	FROM	per_all_assignments_f	paf,
		per_people_extra_info	ppe
	WHERE	paf.person_id		 = ppe.person_id
        and     primary_flag ='Y'          -- primary assignments only
        and     assignment_type ='E'       -- only employees
	AND	ppe.information_type = 'PQH_TENURE_STATUS'
	AND	ppe.pei_information1 = p_tenure_status
	AND	SYSDATE	BETWEEN paf.effective_start_date AND paf.effective_end_date
	AND	FND_DATE.canonical_to_date(PEI_INFORMATION2) <= p_effective_date
	AND	paf.supervisor_id  	= p_supervisor_id ;

	l_status_count	NUMBER;

	BEGIN
		OPEN	prsn_status_cnt_cur;
		FETCH	prsn_status_cnt_cur  INTO  l_status_count;
		CLOSE	prsn_status_cnt_cur;

		RETURN	l_status_count;
	END;

  FUNCTION  getPeriodStatusCount (
		p_supervisor_id		IN NUMBER,
		p_tenure_status		IN VARCHAR2,
		p_start_date		IN DATE,
		p_end_date		IN DATE     ) RETURN NUMBER IS

	/* 4Faculty count of Tenure status till now for a supervisor */
	CURSOR	prsn_status_cnt_cur	IS
	SELECT	count(person_id)
	FROM	per_all_assignments_f paf
	WHERE assignment_type ='E'
	 and exists (
	    SELECT	null
	    FROM	per_people_extra_info	ppe
	    WHERE	ppe.information_type = 'PQH_TENURE_STATUS'
	    AND	ppe.pei_information1 = p_tenure_status
	    AND paf.person_id = ppe.person_id
	    AND	FND_DATE.canonical_to_date(PPE.PEI_INFORMATION2) BETWEEN p_start_date AND p_end_date)
	  and exists (
	    SELECT	null
	    FROM	per_people_extra_info	eiar
	    WHERE	eiar.information_type = 'PQH_ACADEMIC_RANK'
	    AND paf.person_id = eiar.person_id
	 AND	SYSDATE BETWEEN FND_DATE.canonical_to_date(eiar.PEI_INFORMATION2)  AND
	 	NVL(FND_DATE.canonical_to_date(eiar.PEI_INFORMATION3),SYSDATE))
	CONNECT BY PRIOR person_id = supervisor_id
	AND	SYSDATE	BETWEEN effective_start_date AND effective_end_date
	AND     primary_flag ='Y'
	START   WITH     supervisor_id = p_supervisor_id
	  AND	SYSDATE	BETWEEN effective_start_date AND effective_end_date
	  and     primary_flag ='Y';

	l_status_count	NUMBER;

	BEGIN
		OPEN	prsn_status_cnt_cur;
		FETCH	prsn_status_cnt_cur  INTO  l_status_count;
		CLOSE	prsn_status_cnt_cur;

		RETURN	l_status_count;
	END;

  FUNCTION  getStatusCount (
		p_supervisor_id		IN NUMBER,
		p_tenure_status		IN VARCHAR2 ) RETURN NUMBER IS

	/* Faculty count of Tenure status till now for a supervisor */
	CURSOR	prsn_status_cnt_cur	IS
	SELECT	count(person_id)
	FROM	per_all_assignments_f paf
	WHERE assignment_type ='E'
	 and exists (
	    SELECT	null
	    FROM	per_people_extra_info	ppe
	    WHERE	ppe.information_type = 'PQH_TENURE_STATUS'
	    AND	ppe.pei_information1 = p_tenure_status
	    AND paf.person_id = ppe.person_id
	    AND	fnd_date.canonical_to_date(ppe.pei_information2) <= SYSDATE)
	CONNECT BY PRIOR person_id = supervisor_id
	AND	SYSDATE	BETWEEN effective_start_date AND effective_end_date
	AND     primary_flag ='Y'
	START   WITH     supervisor_id = p_supervisor_id
	AND	SYSDATE	BETWEEN effective_start_date AND effective_end_date
	  and     primary_flag ='Y';

	l_status_count	NUMBER;

	BEGIN
		OPEN	prsn_status_cnt_cur;
		FETCH	prsn_status_cnt_cur  INTO  l_status_count;
		CLOSE	prsn_status_cnt_cur;

		RETURN	l_status_count;
	END;

  PROCEDURE getTenuredCount (
		p_supervisor_id		IN	NUMBER,
		p_top_level		IN	VARCHAR2,	-- Top level info T-Top only, S-Supervisor only B-Both
		p_start_academic_dt	IN	DATE,	-- Academic Year start date
		p_end_academic_dt	IN 	DATE,	-- Academic Year End date
		p_total_cnt		 OUT NOCOPY NUMBER,	-- Total count
		p_tenured_cnt		 OUT NOCOPY NUMBER,	-- Total Tenured
		p_tenured_sup_cnt	 OUT NOCOPY NUMBER,	-- Tenured tenured for supervisor
		p_tt_cnt			 OUT NOCOPY NUMBER,	-- Tenure-track
		p_tt_sup_cnt		 OUT NOCOPY NUMBER,	-- Tenure-track for supervisor
		p_tt_final_yr_cnt	 OUT NOCOPY NUMBER,	-- Tenure-track in Final Year
		p_tt_final_yr_sup_cnt    OUT NOCOPY NUMBER,	-- Tenure-track for supervisor in Final Year
		p_ten_cur_yr_cnt	 OUT NOCOPY NUMBER,	-- Tenured for the acdemic year
		p_ten_cur_yr_sup_cnt     OUT NOCOPY NUMBER,	-- Tenured for supervisor for acdemic year
		p_te_cur_yr_cnt	         OUT NOCOPY NUMBER,	-- Tenure-eligible duing the academic year
		p_te_cur_yr_sup_cnt	 OUT NOCOPY NUMBER,	-- Tenure-eligible for supervisor for academic year
		p_td_cur_yr_cnt	         OUT NOCOPY  NUMBER,	-- Tenure-denied for academic year
		p_td_cur_yr_sup_cnt	 OUT NOCOPY NUMBER)IS -- Tenure-denied for supervisor for academic year

	l_tenure_status	VARCHAR2(20);
	l_effective_date	DATE;

	/* Total Faculty count irrespective of Tenure status */
	CURSOR 	prsn_cnt_cur IS
	SELECT 	COUNT(person_id)
	FROM 	per_all_assignments_f
	WHERE	SYSDATE	BETWEEN	effective_start_date AND effective_end_date
          and   primary_flag ='Y'
          -- 2005/08/08: NS: Performance fix: fetch the count for the business group
          and   business_group_id = hr_general.get_business_group_id
          and   assignment_type ='E';

	/* Faculty count of Tenured/Tenure-track status in final year of consideration*/
	CURSOR	prsn_tt_cnt_cur	IS
	SELECT	COUNT(paf.person_id)
	FROM	per_all_assignments_f	paf,
		per_people_extra_info	ppe
	WHERE	paf.person_id		= ppe.person_id
	AND	ppe.information_type = 'PQH_TENURE_STATUS'
        and     primary_flag ='Y'
        and     assignment_type ='E'
	AND	ppe.pei_information1 = l_tenure_status
	AND	paf.effective_start_date <= SYSDATE
	AND     paf.effective_end_date >= SYSDATE
	AND	nvl(fnd_date.canonical_to_date(NVL(ppe.pei_information4,ppe.pei_information3)),sysdate)
		BETWEEN  p_start_academic_dt AND p_end_academic_dt;

	/* Faculty count of Tenure Status for current Year */
	CURSOR	prsn_ed_cnt_cur	IS
	SELECT	COUNT(paf.person_id)
	FROM	per_all_assignments_f	paf,
		per_people_extra_info	ppe
	WHERE	paf.person_id		= ppe.person_id
        and     primary_flag ='Y'
        and     assignment_type ='E'
	AND	ppe.information_type= 'PQH_TENURE_STATUS'
	AND	ppe.pei_information1= l_tenure_status
	AND	SYSDATE	BETWEEN paf.effective_start_date AND paf.effective_end_date
	AND	fnd_date.canonical_to_date(ppe.pei_information2) BETWEEN
                p_start_academic_dt AND p_end_academic_dt;

	/* Faculty count of Tenure Status upto to start date */
	CURSOR	prsn_cnt_tillnow_cur	IS
	SELECT	COUNT(paf.person_id)
	FROM	per_all_assignments_f	paf,
		per_people_extra_info	ppe
	WHERE	paf.person_id		= ppe.person_id
	AND	ppe.information_type = 'PQH_TENURE_STATUS'
        and     primary_flag ='Y'
        and     assignment_type ='E'
	AND	ppe.pei_information1= l_tenure_status
	AND	SYSDATE	BETWEEN	paf.effective_start_date AND paf.effective_end_date
	AND	fnd_date.canonical_to_date(ppe.pei_information2) <=  l_effective_date;

	/*Faculty count of Tenured/Tenure-track status for current/upcoming/previous years */
	CURSOR	prsn_tt_sup_cnt_cur	IS
	SELECT	count(person_id)
	FROM	per_all_assignments_f paf
	WHERE assignment_type ='E'
	  and exists (
	    SELECT	null
	    FROM	per_people_extra_info	ppe
	    WHERE	ppe.information_type = 'PQH_TENURE_STATUS'
	    AND	ppe.pei_information1 = l_tenure_status
            AND paf.person_id = ppe.person_id
	    AND nvl(fnd_date.canonical_to_date(
	               NVL(ppe.pei_information4,ppe.pei_information3)),SYSDATE)
	        BETWEEN  p_start_academic_dt AND p_end_academic_dt)
	CONNECT BY PRIOR person_id = supervisor_id
	AND	SYSDATE	BETWEEN effective_start_date AND effective_end_date
	AND     primary_flag ='Y'
	START   WITH     supervisor_id = p_supervisor_id
	AND	SYSDATE	BETWEEN effective_start_date AND effective_end_date
	  and     primary_flag ='Y';

	/* Faculty count of Tenure eligible/denied status for current year */
	CURSOR	prsn_ed_sup_cnt_cur	IS
	SELECT	count(person_id)
	FROM	per_all_assignments_f paf
	WHERE assignment_type ='E'
	  and exists (
	    SELECT	null
	    FROM	per_people_extra_info	ppe
	    WHERE	ppe.information_type = 'PQH_TENURE_STATUS'
	    AND	ppe.pei_information1 = l_tenure_status
	    AND paf.person_id = ppe.person_id
	    AND	fnd_date.canonical_to_date(ppe.pei_information2)
	        BETWEEN  p_start_academic_dt AND p_end_academic_dt)
	CONNECT BY PRIOR person_id = supervisor_id
	AND	SYSDATE	BETWEEN effective_start_date AND effective_end_date
	AND     primary_flag ='Y'
	START   WITH     supervisor_id = p_supervisor_id
	AND	SYSDATE	BETWEEN effective_start_date AND effective_end_date
	  and     primary_flag ='Y';

	/* Faculty count of Tenure status till now for a supervisor */
	CURSOR	prsn_sup_cnt_tillnow_cur	IS
	SELECT	count(person_id)
	FROM	per_all_assignments_f paf
	WHERE assignment_type ='E'
	  and exists (
	    SELECT	null
	    FROM	per_people_extra_info	ppe
	    WHERE	ppe.information_type = 'PQH_TENURE_STATUS'
	    AND	ppe.pei_information1 = l_tenure_status
	    AND paf.person_id = ppe.person_id
	    AND	fnd_date.canonical_to_date(ppe.pei_information2) <= l_effective_date)
	CONNECT BY PRIOR person_id = supervisor_id
	AND	SYSDATE	BETWEEN effective_start_date AND effective_end_date
	AND     primary_flag ='Y'
	START   WITH     supervisor_id = p_supervisor_id
	AND	SYSDATE	BETWEEN effective_start_date AND effective_end_date
	  and     primary_flag ='Y';
BEGIN
	IF p_top_level IN ('T','B') THEN
		OPEN prsn_cnt_cur;
		FETCH prsn_cnt_cur INTO p_total_cnt;
		CLOSE prsn_cnt_cur;
	END IF;

/* 	******** TENURED FACULTY COUNT ******** -- */
	l_tenure_status	:= '01';

	/* Upto the starting of the academic Year */
	IF p_top_level IN ('T','B') THEN
		IF  p_start_academic_dt IS NOT NULL THEN
		    l_effective_date	:= p_start_academic_dt;
	    	ELSE
		    l_effective_date	:= SYSDATE;
	    	END IF;

		OPEN prsn_cnt_tillnow_cur;
		FETCH prsn_cnt_tillnow_cur INTO p_tenured_cnt;
		CLOSE prsn_cnt_tillnow_cur;
	END IF;

	/* For specific Supervisor */
	IF p_top_level IN ('S','B') THEN
		IF  p_start_academic_dt IS NOT NULL THEN
		    l_effective_date	:= p_start_academic_dt;
	    	ELSE
		    l_effective_date	:= SYSDATE;
	    	END IF;

		OPEN prsn_sup_cnt_tillnow_cur;
		FETCH prsn_sup_cnt_tillnow_cur INTO p_tenured_sup_cnt;
		CLOSE prsn_sup_cnt_tillnow_cur;
	END IF;

	/* During the academic year */
	IF p_top_level IN ('T','B') THEN
		OPEN prsn_ed_cnt_cur;
		FETCH prsn_ed_cnt_cur INTO p_ten_cur_yr_cnt;
		CLOSE prsn_ed_cnt_cur;
	END IF;

	/* During the academic year for specific supervisor */
	IF p_top_level IN ('S','B') THEN
		OPEN prsn_ed_sup_cnt_cur;
		FETCH prsn_ed_sup_cnt_cur INTO p_ten_cur_yr_sup_cnt;
		CLOSE prsn_ed_sup_cnt_cur;
	END IF;

/* 	******** TENURE TRACK FACULTY COUNT ******** -- */
	l_tenure_status	:= '02';

	/* Upto the starting of the academic Year */
	IF p_top_level IN ('T','B') THEN
		OPEN prsn_cnt_tillnow_cur;
		FETCH prsn_cnt_tillnow_cur INTO p_tt_cnt;
		CLOSE prsn_cnt_tillnow_cur;
	END IF;

	/* For specific Supervisor */
	IF p_top_level IN ('S','B') THEN
		OPEN prsn_sup_cnt_tillnow_cur;
		FETCH prsn_sup_cnt_tillnow_cur INTO p_tt_sup_cnt;
		CLOSE prsn_sup_cnt_tillnow_cur;
	END IF;

	/* Final year for tenure consideration  */
	IF p_top_level IN ('T','B') THEN
		OPEN prsn_tt_cnt_cur;
		FETCH prsn_tt_cnt_cur INTO p_tt_final_yr_cnt;
		CLOSE prsn_tt_cnt_cur;
	END IF;

	/* Final year for tenure consideration for specific supervisor */
	IF p_top_level IN ('S','B') THEN
		OPEN prsn_tt_sup_cnt_cur;
		FETCH prsn_tt_sup_cnt_cur INTO p_tt_final_yr_sup_cnt;
		CLOSE prsn_tt_sup_cnt_cur;
	END IF;

/* 	******** TENURE ELIGIBLE FACULTY COUNT ******** -- */
	l_tenure_status	:= '04';

	/* Tenure-Eligible this academic year */
	IF p_top_level IN ('T','B') THEN
		OPEN prsn_ed_cnt_cur;
		FETCH prsn_ed_cnt_cur INTO p_te_cur_yr_cnt;
		CLOSE prsn_ed_cnt_cur;
	END IF;

	/* Tenure-eligible this academic year for specific supervisor */
	IF p_top_level IN ('S','B') THEN
		OPEN prsn_ed_sup_cnt_cur;
		FETCH prsn_ed_sup_cnt_cur INTO p_te_cur_yr_sup_cnt;
		CLOSE prsn_ed_sup_cnt_cur;
	END IF;

/* 	******** TENURE DENIED FACULTY COUNT ******** --*/
	l_tenure_status	:= '05';

	/* Tenure-denied this academic year*/
	IF p_top_level IN ('T','B') THEN
		OPEN prsn_ed_cnt_cur;
		FETCH prsn_ed_cnt_cur INTO p_td_cur_yr_cnt;
		CLOSE prsn_ed_cnt_cur;
	END IF;

	/* Tenure-denied this academic year for specific supervisor */
	IF p_top_level IN ('S','B') THEN
		OPEN prsn_ed_sup_cnt_cur;
		FETCH prsn_ed_sup_cnt_cur INTO p_td_cur_yr_sup_cnt;
		CLOSE prsn_ed_sup_cnt_cur;
	END IF;
exception when others then
p_total_cnt		 := null;
p_tenured_cnt		 := null;
p_tenured_sup_cnt	 := null;
p_tt_cnt		:= null;
p_tt_sup_cnt		:= null;
p_tt_final_yr_cnt	:= null;
p_tt_final_yr_sup_cnt   := null;
p_ten_cur_yr_cnt	:= null;
p_ten_cur_yr_sup_cnt    := null;
p_te_cur_yr_cnt	        := null;
p_te_cur_yr_sup_cnt	:= null;
p_td_cur_yr_cnt	        := null;
p_td_cur_yr_sup_cnt	 := null;
  END getTenuredCount;

  PROCEDURE  getReportBodyText (
		p_report_id          IN  VARCHAR2,
		p_body_regards      OUT NOCOPY  VARCHAR2,
		p_body_text1        OUT NOCOPY  VARCHAR2,
		p_body_text2        OUT NOCOPY  VARCHAR2,
		p_body_text3        OUT NOCOPY  VARCHAR2,
		p_body_text4        OUT NOCOPY  VARCHAR2,
		p_body_text5        OUT NOCOPY  VARCHAR2,
		p_body_text6        OUT NOCOPY  VARCHAR2,
		p_body_text7        OUT NOCOPY  VARCHAR2,
		p_body_text8        OUT NOCOPY  VARCHAR2 ) IS

	BEGIN
		p_body_regards		:= fnd_message.get_string('PQH','PQH_RGDS_TENURE_RPT_TXT');

		IF 		p_report_id  = 'NT' THEN		-- Non-Tenure

			p_body_text1			:=  fnd_message.get_string('PQH','PQH_NT_TENURE_RPT_TXT');

		ELSIF 	p_report_id  = 'TS' THEN		-- Tenure Status
			p_body_text1			:=  fnd_message.get_string('PQH','PQH_TS_TENURE_RPT_TXT');

		ELSIF 	p_report_id  = 'TT' THEN		-- Tenure Track
			p_body_text1			:=  fnd_message.get_string('PQH','PQH_TT_TENURE_RPT_TXT1');

			p_body_text2			:=  fnd_message.get_string('PQH','PQH_TT_TENURE_RPT_TXT2');

			p_body_text3			:=  fnd_message.get_string('PQH','PQH_TT_TENURE_RPT_TXT3');

			p_body_text4			:=  fnd_message.get_string('PQH','PQH_TT_TENURE_RPT_TXT4');

                 ELSIF 	p_report_id  = 'RW' THEN		-- Review

			p_body_text1			:=  fnd_message.get_string('PQH','PQH_RW_TENURE_RPT_TXT1');

			p_body_text2			:=  fnd_message.get_string('PQH','PQH_RW_TENURE_RPT_TXT2');

		ELSIF 	p_report_id  = 'AS' THEN		-- Annual Status

			p_body_text1			:=  fnd_message.get_string('PQH','PQH_AS_TENURE_RPT_TXT1');

			p_body_text2			:=  fnd_message.get_string('PQH','PQH_AS_TENURE_RPT_TXT2');

			p_body_text3			:=  fnd_message.get_string('PQH','PQH_AS_TENURE_RPT_TXT3');

			p_body_text4			:=  fnd_message.get_string('PQH','PQH_AS_TENURE_RPT_TXT4');

			p_body_text5			:=  fnd_message.get_string('PQH','PQH_AS_TENURE_RPT_TXT5');

                        p_body_text6                    :=  fnd_message.get_string('PQH','PQH_AS_TENURE_RPT_TXT6');

                        p_body_text7                    :=  fnd_message.get_string('PQH','PQH_AS_TENURE_RPT_TXT7');

		ELSIF	p_report_id	= 'CE' THEN

			p_body_text1			:=  fnd_message.get_string('PQH','PQH_CE_TENURE_RPT_TXT');
		END IF;

	END;
END pqh_tenure_detail;

/

--------------------------------------------------------
--  DDL for Package Body GHR_462
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_462" AS
/* $Header: gh462sum.pkb 115.14 2003/09/08 22:03:10 sumarimu noship $ */
--
	PROCEDURE populate_sum(
	   p_request_id IN NUMBER
	  ,p_agency_code  IN VARCHAR2
	  ,p_fiscal_year IN NUMBER
	  ,p_from_date   IN VARCHAR2
	  ,p_to_date     IN VARCHAR2
	  ,p_output_fname OUT NOCOPY VARCHAR2)
	IS
	l_file_name varchar2(50);
	l_audit_log_dir varchar2(500);
	l_from_date date;
	l_to_date date;
	l_fiscal_year varchar2(4);
	BEGIN


	-- To clear the PL/SQL Table values.
	vXMLTable.DELETE;
	vCtr := 1;
	-- Changing the date parameters from canonical format to date format.
	l_from_date:= fnd_date.canonical_to_date(p_from_date);
	l_to_date := fnd_date.canonical_to_date(p_to_date);
	l_fiscal_year := to_number(to_char(l_to_date,'YYYY'));
	-- Populate the Part 1 of 462 Report
	fnd_file.put_line(fnd_file.log,'Calling Procedure to Populate Part1');
	populate_part1(
		l_from_date,
		l_to_date,
		p_agency_code);
	fnd_file.put_line(fnd_file.log,'Calling Procedure to Populate Part2');
	-- Populate the Part 2 of 462 Report
	populate_part2(
		l_from_date,
		l_to_date,
		p_agency_code);
	PopulatePart4Matrix;
	-- Populate the Part 4 of 462 Report
	fnd_file.put_line(fnd_file.log,'Calling Procedure to Populate Part4');
	populate_part4(
		l_from_date,
		l_to_date,
		p_agency_code);
	-- Populate the Part 5 of 462 Report
	fnd_file.put_line(fnd_file.log,'Calling Procedure to Populate Part5');
	populate_part5(
		l_from_date,
		l_to_date,
		p_agency_code);
	-- Populate the Part 6 of 462 Report
	fnd_file.put_line(fnd_file.log,'Calling Procedure to Populate Part6');
	populate_part6(
		l_from_date,
		l_to_date,
		p_agency_code);
	-- Populate the Part 7 of 462 Report
	fnd_file.put_line(fnd_file.log,'Calling Procedure to Populate Part7');
	populate_part7(
		l_from_date,
		l_to_date,
		p_agency_code);
	-- Populate the Part 8 of 462 Report
	fnd_file.put_line(fnd_file.log,'Calling Procedure to Populate Part8');
	populate_part8(
		l_from_date,
		l_to_date,
		p_agency_code);
	-- Populate the Part 10 of 462 Report
	fnd_file.put_line(fnd_file.log,'Calling Procedure to Populate Part10');
	populate_part10(
		l_from_date,
		l_to_date,
		p_agency_code);
	-- Populate the Part 11 of 462 Report
	fnd_file.put_line(fnd_file.log,'Calling Procedure to Populate Part11');
	populate_part11(
		l_from_date,
		l_to_date,
		p_agency_code);
	-- Write the values to XML File
	fnd_file.put_line(fnd_file.log,'Calling Procedure to write into XML File');
	WritetoXML(
	p_request_id,
	p_agency_code,
	l_fiscal_year,
    l_from_date,
	l_to_date,
	l_file_name);
	p_output_fname := l_file_name;
	fnd_file.put_line(fnd_file.log,'------------Output XML File----------------');
	fnd_file.put_line(fnd_file.log,'File' || l_file_name );
	fnd_file.put_line(fnd_file.log,'-------------------------------------------');

--	COMMIT;
EXCEPTION
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
	   hr_utility.raise_error;
END populate_sum;

--------------------------------------------

-- Procedure to populate the Part1 of the Report 462
PROCEDURE populate_part1(
    p_from_date   in date,
	p_to_date     in date,
	p_agency_code in varchar2)
IS

	l_p1_a number;
	l_p1_a1 number;
	l_p1_a2 number;
	l_p1_a3 number;
	l_p1_a4 number;

	l_p1_bnum1 number;
	l_p1_bnum2 number;
	l_p1_bnum3 number;
	l_p1_bnum4 number;
	l_p1_bnum5 number;
	l_p1_bamt1 number;
	l_p1_bamt2 number;
	l_p1_bamt3 number;
	l_p1_bamt4 number;
	l_p1_bamt5 number;
	l_p1_c number;

	-- Cursor to populate Part 1.A
	CURSOR cur_p1_a(c_from_date IN DATE,c_to_date IN DATE, c_agency_code ghr_complaints2.agency_code%type) IS
	SELECT COUNT(*) pl_a_cnt
	FROM GHR_COMPLAINTS2 cmp
	WHERE ((cmp.pcom_init BETWEEN c_from_date AND c_to_date
	AND cmp.final_interview BETWEEN cmp.pcom_init AND cmp.pcom_init + 30
	AND cmp.final_interview <= c_to_date)
	OR ( (cmp.final_interview >= c_from_date AND cmp.final_interview <= c_to_date)
	AND cmp.pcom_init BETWEEN cmp.final_interview - 30 AND cmp.final_interview))
	AND cmp.agency_code = c_agency_code
	AND cmp.formal_com_filed IS NULL ;

	-- Cursor to populate Part 1.B
	CURSOR cur_p1_b(c_from_date IN DATE,c_to_date IN DATE, c_agency_code ghr_complaints2.agency_code%type) IS
	SELECT COUNT(*) p1_b_cnt
	FROM GHR_COMPLAINTS2 cmp
	WHERE ((cmp.pcom_init BETWEEN c_from_date AND c_to_date
	AND cmp.final_interview BETWEEN cmp.pcom_init + 31 AND cmp.pcom_init + 90
	AND cmp.final_interview <= c_to_date)
	OR ( (cmp.final_interview >= c_from_date AND cmp.final_interview <= c_to_date)
	AND cmp.pcom_init BETWEEN cmp.final_interview - 90 AND cmp.final_interview - 31))
	AND cmp.agency_code = c_agency_code
	AND cmp.formal_com_filed IS NULL ;

	-- Cursor to populate Part 1.C
	-- Added Parameter c_to_date in case Final interview is null -- Sundar 07Aug2003
	CURSOR cur_p1_c(c_from_date IN DATE,c_to_date IN DATE, c_agency_code ghr_complaints2.agency_code%type) IS
	SELECT COUNT(*) p1_c_cnt
	FROM GHR_COMPLAINTS2 cmp
	WHERE ((cmp.pcom_init BETWEEN c_from_date AND c_to_date
	       AND NVL(cmp.final_interview,c_to_date) > cmp.pcom_init + 90
		   AND cmp.final_interview <= c_to_date)
	OR ((cmp.final_interview >= c_from_date AND cmp.final_interview <= c_to_date)
     	AND cmp.pcom_init < NVL(cmp.final_interview,c_to_date) - 90))
	AND cmp.agency_code = c_agency_code
	AND cmp.formal_com_filed IS NULL ;

	-- Cursor to populate Part 1.D
	CURSOR cur_p1_d(c_from_date IN DATE,c_to_date IN DATE, c_agency_code ghr_complaints2.agency_code%type) IS
	SELECT COUNT(*) p1_d_cnt
	FROM GHR_COMPLAINTS2 cmp	, GHR_COMPL_AGENCY_APPEALS apa
	WHERE apa.complaint_id = cmp.complaint_id
    AND apa.decision IN ('30','40')
   	AND cmp.init_counselor_interview >= cmp.formal_com_filed
	AND cmp.init_counselor_interview BETWEEN c_from_date AND c_to_date
	AND cmp.agency_code = c_agency_code;

	-- Cursor to populate both Counts and Amounts for Section B of Part 1.
	-- Remand condition added
	CURSOR cur_p1_2(c_from_date IN DATE,c_to_date IN DATE,c_payment_type IN GHR_COMPL_CA_DETAILS.payment_type%TYPE, c_agency_code ghr_complaints2.agency_code%type) IS
	SELECT COUNT(distinct cmp.complaint_id) p1_2_cnt, nvl(SUM(CEIL(ca.amount)),0) p1_2_sum_amount
	FROM GHR_COMPLAINTS2 cmp, GHR_COMPL_CA_HEADERS cah, GHR_COMPL_CA_DETAILS ca
	WHERE ca.compl_ca_header_id = cah.compl_ca_header_id
	AND cah.complaint_id = cmp.complaint_id
	AND ca.category = '10'
	AND ca.phase = '20' -- Added Phase after Test plan Review
	AND ca.payment_type = c_payment_type
	AND cmp.precom_closure_nature IN ('30','50')
	AND cmp.precom_closed BETWEEN c_from_date AND c_to_date
	AND (
			(cmp.formal_com_filed IS NULL OR cmp.formal_com_filed > c_to_date)
			 OR (cmp.init_counselor_interview >= cmp.formal_com_filed
			 AND cmp.init_counselor_interview BETWEEN c_from_date AND c_to_date)
		)
	AND cmp.agency_code = c_agency_code;

	-- Cursor to populate both Counts and Amounts for Section B of Part 1.
	CURSOR cur_compensatory(c_from_date IN DATE,c_to_date IN DATE, c_agency_code ghr_complaints2.agency_code%type) IS
	SELECT COUNT(distinct cmp.complaint_id) p1_2_cnt, NVL(SUM(CEIL(ca.amount)),0) p1_2_sum_amount
	FROM GHR_COMPLAINTS2 cmp, GHR_COMPL_CA_HEADERS cah, GHR_COMPL_CA_DETAILS ca
	WHERE ca.compl_ca_header_id = cah.compl_ca_header_id
	AND cah.complaint_id = cmp.complaint_id
	AND ca.phase = '20' -- Added Phase after Test plan Review
	AND ca.category = '10'
	AND ca.payment_type IN ('30','40')
	AND cmp.precom_closure_nature IN ('30','50')
	AND cmp.precom_closed BETWEEN c_from_date AND c_to_date
	AND (
		(cmp.formal_com_filed IS NULL OR cmp.formal_com_filed > c_to_date)
		OR (cmp.init_counselor_interview >= cmp.formal_com_filed
		AND cmp.init_counselor_interview BETWEEN c_from_date AND c_to_date)
		)
	AND cmp.agency_code = c_agency_code;

	-- Cursor to populate Section C of Part 1
	CURSOR cur_p1_3(c_from_date IN DATE,c_to_date IN DATE, c_agency_code ghr_complaints2.agency_code%type) IS
	SELECT COUNT(distinct cmp.complaint_id) p1_c_cnt
	FROM GHR_COMPLAINTS2 cmp, GHR_COMPL_CA_HEADERS cah, GHR_COMPL_CA_DETAILS ca
	WHERE ca.compl_ca_header_id = cah.compl_ca_header_id
	AND cah.complaint_id = cmp.complaint_id
	AND ca.phase = '20' -- Added Phase after Test plan Review
	AND ca.category = '20'
	AND cmp.precom_closure_nature IN ('40','50')
	AND cmp.precom_closed BETWEEN c_from_date AND c_to_date
	AND ((cmp.formal_com_filed IS NULL OR cmp.formal_com_filed > c_to_date)
	OR (cmp.init_counselor_interview >= cmp.formal_com_filed
	AND cmp.init_counselor_interview BETWEEN c_from_date AND c_to_date))
	AND cmp.agency_code = c_agency_code;

BEGIN
	-----------------------------------------------------------------------------
	-- Section 1 - Counseling
	-----------------------------------------------------------------------------

	-- Part 1.A.1 No. of Individuals whose counseling completed within 30 days
	FOR c_comp1 IN cur_p1_a(p_from_date, p_to_date, p_agency_code) LOOP
	   l_p1_a1 := c_comp1.pl_a_cnt;
	END LOOP;

    vXMLTable(vCtr).TagName := 'P1_a1';
	vXMLTable(vCtr).TagValue := to_char(l_p1_a1);
	vCtr := vCtr + 1;
	fnd_file.put_line(fnd_file.log,'Finished Populating Part 1.A.1 - No. of Individuals whose counseling completed within 30 days ');

	-- Part 1.A.2 No. of Individuals counseled within 31 to 90 days.
	FOR c_comp1 IN cur_p1_b(p_from_date, p_to_date, p_agency_code) LOOP
	   l_p1_a2 := c_comp1.p1_b_cnt;
	END LOOP;

	vXMLTable(vCtr).TagName := 'P1_a2';
	vXMLTable(vCtr).TagValue := to_char(l_p1_a2);
	vCtr := vCtr + 1;
	fnd_file.put_line(fnd_file.log,'Finished Populating Part 1.A.2 - No. of Individuals counseled within 31 to 90 days.');

	-- Part 1.A.3 No. of Individuals counseled beyond 90 days.
	FOR c_comp1 IN cur_p1_c(p_from_date, p_to_date, p_agency_code) LOOP
	   l_p1_a3 := c_comp1.p1_c_cnt;
	END LOOP;

	vXMLTable(vCtr).TagName := 'P1_a3';
	vXMLTable(vCtr).TagValue := to_char(l_p1_a3);
	vCtr := vCtr + 1;
	fnd_file.put_line(fnd_file.log,'Finished Populating Part 1.A.3 - No. of Individuals counseled beyond 90 days.');

	-- Part 1.A.4 No. of Individuals counseled due to remands.

	FOR c_comp1 IN cur_p1_d(p_from_date, p_to_date, p_agency_code) LOOP
	   l_p1_a4 := c_comp1.p1_d_cnt;
	END LOOP;

	vXMLTable(vCtr).TagName := 'P1_a4';
	vXMLTable(vCtr).TagValue := to_char(l_p1_a4);
	vCtr := vCtr + 1;
	fnd_file.put_line(fnd_file.log,'Finished Populating Part 1.A.4 - No. of Individuals counseled due to remands');

	-- Part 1 Total No. of individuals counseled.
	l_p1_a := l_p1_a1 + l_p1_a2 + l_p1_a3 + l_p1_a4;

	vXMLTable(vCtr).TagName := 'P1_a';
	vXMLTable(vCtr).TagValue := to_char(l_p1_a);
	vCtr := vCtr + 1;
	fnd_file.put_line(fnd_file.log,'Finished populating Part1 - Total No. of individuals counseled');
	-----------------------------------------------------------------------------
	--Section 2 Non-ADR Settlements during Counseling
	-----------------------------------------------------------------------------
	-- Populating Counts
	-- Compensatory Damages
	FOR c_comp1 IN cur_compensatory(p_from_date, p_to_date, p_agency_code) LOOP
		l_p1_bnum1 := c_comp1.p1_2_cnt;
		l_p1_bamt1 := c_comp1.p1_2_sum_amount;
	END LOOP;

	-- BackPay and FrontPay
	FOR c_comp1 IN cur_p1_2(p_from_date, p_to_date,'20', p_agency_code) LOOP
		l_p1_bnum2 := c_comp1.p1_2_cnt;
		l_p1_bamt2 := c_comp1.p1_2_sum_amount;
	END LOOP;

	-- Lump Sum Payments
	FOR c_comp1 IN cur_p1_2(p_from_date, p_to_date,'50', p_agency_code) LOOP
		l_p1_bnum3 := c_comp1.p1_2_cnt;
		l_p1_bamt3 := c_comp1.p1_2_sum_amount;
	END LOOP;

	-- Attorney Fees and Costs
	FOR c_comp1 IN cur_p1_2(p_from_date, p_to_date,'10', p_agency_code) LOOP
		l_p1_bnum4 := c_comp1.p1_2_cnt;
		l_p1_bamt4 := c_comp1.p1_2_sum_amount;
	END LOOP;

	-- Others
	FOR c_comp1 IN cur_p1_2(p_from_date, p_to_date,'60', p_agency_code) LOOP
		l_p1_bnum5 := c_comp1.p1_2_cnt;
		l_p1_bamt5 := c_comp1.p1_2_sum_amount;
	END LOOP;

	vXMLTable(vCtr).TagName := 'P1_bnum1';
	vXMLTable(vCtr).TagValue := to_char(l_p1_bnum1);
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P1_bamt1';
	vXMLTable(vCtr).TagValue := to_char(l_p1_bamt1);
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P1_bnum2';
	vXMLTable(vCtr).TagValue := to_char(l_p1_bnum2);
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P1_bamt2';
	vXMLTable(vCtr).TagValue := to_char(l_p1_bamt2);
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P1_bnum3';
	vXMLTable(vCtr).TagValue := to_char(l_p1_bnum3);
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P1_bamt3';
	vXMLTable(vCtr).TagValue := to_char(l_p1_bamt3);
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P1_bnum4';
	vXMLTable(vCtr).TagValue := to_char(l_p1_bnum4);
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P1_bamt4';
	vXMLTable(vCtr).TagValue := to_char(l_p1_bamt4);
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P1_bnum5';
	vXMLTable(vCtr).TagValue := to_char(l_p1_bnum5);
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P1_bamt5';
	vXMLTable(vCtr).TagValue := to_char(l_p1_bamt5);
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P1_bnum6';
	vXMLTable(vCtr).TagValue := '0';
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P1_bamt6';
	vXMLTable(vCtr).TagValue := '0';
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P1_bnum7';
	vXMLTable(vCtr).TagValue := '0';
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P1_bamt7';
	vXMLTable(vCtr).TagValue := '0';
	vCtr := vCtr + 1;

	fnd_file.put_line(fnd_file.log,'Finished populating Part 1 Section 2 - Non-ADR Settlements during Counseling');
	-----------------------------------------------------------------------------
	-- Section 3 Non-ADR Settlements with Non-Monetory Benefits
	-----------------------------------------------------------------------------

	FOR c_comp1 IN cur_p1_3(p_from_date,p_to_date, p_agency_code) LOOP
	   l_p1_c := c_comp1.p1_c_cnt;
	END LOOP;

	vXMLTable(vCtr).TagName := 'P1_c';
	vXMLTable(vCtr).TagValue := to_char(l_p1_c);
	vCtr := vCtr + 1;
	fnd_file.put_line(fnd_file.log,'Finished populating Part 1 - Section 3');
	fnd_file.put_line(fnd_file.log,'------------End of Part1----------------');

END populate_part1;

PROCEDURE populate_part2(
    p_from_date   in date,
	p_to_date     in date,
	p_agency_code in varchar2)
IS
-- Cursor to populate Section 1 of Part 2 - Complaints on hand before the reporting period
CURSOR cur_p2_1(c_from_date date ,c_agency_code ghr_complaints2.agency_code%type) IS
   SELECT COUNT(*) p2_1_cnt
   FROM GHR_COMPLAINTS2 cmp
   WHERE cmp.formal_com_filed IS NOT NULL
   AND cmp.formal_com_filed < c_from_date
   AND cmp.agency_code = c_agency_code
   AND (cmp.complaint_closed IS NULL OR cmp.complaint_closed > c_from_date);

-- Cursor to populate Section 2 of Part 2 - Complaints filed
	-- Remanded complaints to be removed from this condition - Done after Test plan review
CURSOR cur_p2_2(c_from_date date, c_to_date date ,c_agency_code ghr_complaints2.agency_code%type) IS
   SELECT COUNT(*) p2_2_cnt
   FROM GHR_COMPLAINTS2 cmp
   WHERE cmp.formal_com_filed BETWEEN c_from_date AND c_to_date
   AND cmp.agency_code = c_agency_code
   AND (NOT EXISTS(SELECT 1 FROM GHR_COMPL_AGENCY_APPEALS apa
   	   				   WHERE apa.complaint_id = cmp.complaint_id
					   AND apa.decision_date BETWEEN c_from_date AND c_to_date
					   AND apa.decision IN ('30','40'))
	AND	NOT EXISTS(SELECT 1 FROM GHR_COMPL_APPEALS ap
   	   				   WHERE ap.complaint_id = cmp.complaint_id
					   AND ap.decision_date BETWEEN c_from_date AND c_to_date
					   AND ap.decision IN ('30','40')));

-- Cursor to populate Section 3 of Part 2 - Remanded Complaints
-- Including Agency appeal decision date.
CURSOR cur_p2_3(c_from_date date, c_to_date date ,c_agency_code ghr_complaints2.agency_code%type) IS
 SELECT COUNT(*) p2_3_cnt
   FROM GHR_COMPLAINTS2 cmp
   WHERE  cmp.formal_com_filed BETWEEN c_from_date AND c_to_date
   AND cmp.agency_code = c_agency_code
   AND (cmp.complaint_closed NOT BETWEEN c_from_date AND c_to_date
		OR cmp.complaint_closed IS NULL)
   AND (EXISTS(SELECT 1 FROM GHR_COMPL_AGENCY_APPEALS apa
   	   				   WHERE apa.complaint_id = cmp.complaint_id
					   AND apa.decision_date BETWEEN c_from_date AND c_to_date
					   AND apa.decision IN ('30','40'))
	OR EXISTS(SELECT 1 FROM GHR_COMPL_APPEALS ap
   	   				   WHERE ap.complaint_id = cmp.complaint_id
					   AND ap.decision_date BETWEEN c_from_date AND c_to_date
					   AND ap.decision IN ('30','40')));

-- Cursor to populate complaints that were not consolidated
-- To exclude remands outside closure period
CURSOR cur_p2_5(c_from_date date, c_to_date date ,c_agency_code ghr_complaints2.agency_code%type) IS
SELECT COUNT(*) p2_5_cnt FROM
(
	SELECT cmp.*
	   FROM GHR_COMPLAINTS2 cmp
	   WHERE cmp.formal_com_filed IS NOT NULL
	   AND cmp.formal_com_filed < c_from_date
	   AND cmp.agency_code = c_agency_code
	   AND (cmp.complaint_closed IS NULL OR cmp.complaint_closed > c_from_date)
UNION ALL
	SELECT cmp.*
	   FROM GHR_COMPLAINTS2 cmp
	   WHERE cmp.formal_com_filed BETWEEN c_from_date AND c_to_date
	   AND cmp.agency_code = c_agency_code
	   AND (NOT EXISTS(SELECT 1 FROM GHR_COMPL_AGENCY_APPEALS apa
						   WHERE apa.complaint_id = cmp.complaint_id
						   AND apa.decision_date BETWEEN c_from_date AND c_to_date
						   AND apa.decision IN ('30','40'))
	   AND	NOT EXISTS(SELECT 1 FROM GHR_COMPL_APPEALS ap
						   WHERE ap.complaint_id = cmp.complaint_id
						   AND ap.decision_date BETWEEN c_from_date AND c_to_date
						   AND ap.decision IN ('30','40')))
UNION ALL
	SELECT cmp.*
	   FROM GHR_COMPLAINTS2 cmp
	   WHERE  cmp.formal_com_filed BETWEEN c_from_date AND c_to_date
	   AND cmp.agency_code = c_agency_code
	   AND (cmp.complaint_closed NOT BETWEEN c_from_date AND c_to_date
			OR cmp.complaint_closed IS NULL)
	   AND (EXISTS(SELECT 1 FROM GHR_COMPL_AGENCY_APPEALS apa
						   WHERE apa.complaint_id = cmp.complaint_id
						   AND apa.decision_date BETWEEN c_from_date AND c_to_date
						   AND apa.decision IN ('30','40'))
		OR EXISTS(SELECT 1 FROM GHR_COMPL_APPEALS ap
						   WHERE ap.complaint_id = cmp.complaint_id
						   AND ap.decision_date BETWEEN c_from_date AND c_to_date
						   AND ap.decision IN ('30','40')))
) cmp1
WHERE cmp1.consolidated IS NULL
AND (cmp1.complaint_closed IS NULL OR cmp1.complaint_closed > c_to_date)
;

-- Cursor to populate Section 6 - No. of unconsolidated complaints that were closed

CURSOR cur_p2_6(c_from_date date, c_to_date date ,c_agency_code ghr_complaints2.agency_code%type) IS
	SELECT COUNT(*) p2_6_cnt
	FROM (
			SELECT cmp.*
			   FROM GHR_COMPLAINTS2 cmp
			   WHERE cmp.formal_com_filed IS NOT NULL
			   AND cmp.formal_com_filed < c_from_date
			   AND cmp.agency_code = c_agency_code
			   AND (cmp.complaint_closed IS NULL OR cmp.complaint_closed > c_from_date)
			UNION ALL
			SELECT cmp.*
			   FROM GHR_COMPLAINTS2 cmp
			   WHERE cmp.formal_com_filed BETWEEN c_from_date AND c_to_date
			   AND cmp.agency_code = c_agency_code
			   AND (NOT EXISTS(SELECT 1 FROM GHR_COMPL_AGENCY_APPEALS apa
								   WHERE apa.complaint_id = cmp.complaint_id
								   AND apa.decision_date BETWEEN c_from_date AND c_to_date
								   AND apa.decision IN ('30','40'))
			   AND	NOT EXISTS(SELECT 1 FROM GHR_COMPL_APPEALS ap
								   WHERE ap.complaint_id = cmp.complaint_id
								   AND ap.decision_date BETWEEN c_from_date AND c_to_date
								   AND ap.decision IN ('30','40')))
			UNION ALL
			SELECT cmp.*
			   FROM GHR_COMPLAINTS2 cmp
			   WHERE  cmp.formal_com_filed BETWEEN c_from_date AND c_to_date
			   AND cmp.agency_code = c_agency_code
			   AND (cmp.complaint_closed NOT BETWEEN c_from_date AND c_to_date
					OR cmp.complaint_closed IS NULL)
			   AND (EXISTS(SELECT 1 FROM GHR_COMPL_AGENCY_APPEALS apa
								   WHERE apa.complaint_id = cmp.complaint_id
								   AND apa.decision_date BETWEEN c_from_date AND c_to_date
								   AND apa.decision IN ('30','40'))
				OR EXISTS(SELECT 1 FROM GHR_COMPL_APPEALS ap
								   WHERE ap.complaint_id = cmp.complaint_id
								   AND ap.decision_date BETWEEN c_from_date AND c_to_date
								   AND ap.decision IN ('30','40')))
		  ) cmp1
	WHERE (cmp1.consolidated IS NULL OR cmp1.consolidated NOT BETWEEN c_from_date AND c_to_date)
	AND complaint_closed BETWEEN c_from_date AND c_to_date;

CURSOR cur_p2_7(c_from_date date, c_to_date date ,c_agency_code ghr_complaints2.agency_code%type) IS
SELECT COUNT(*) p2_7_cnt FROM
(
SELECT cmp.*
   FROM GHR_COMPLAINTS2 cmp
   WHERE cmp.formal_com_filed IS NOT NULL
   AND cmp.formal_com_filed < c_from_date
   AND cmp.agency_code = c_agency_code
   AND (cmp.complaint_closed IS NULL OR cmp.complaint_closed > c_from_date)
UNION ALL
SELECT cmp.*
   FROM GHR_COMPLAINTS2 cmp
   WHERE cmp.formal_com_filed BETWEEN c_from_date AND c_to_date
   AND cmp.agency_code = c_agency_code
   AND (NOT EXISTS(SELECT 1 FROM GHR_COMPL_AGENCY_APPEALS apa
					   WHERE apa.complaint_id = cmp.complaint_id
					   AND apa.decision_date BETWEEN c_from_date AND c_to_date
					   AND apa.decision IN ('30','40'))
   AND	NOT EXISTS(SELECT 1 FROM GHR_COMPL_APPEALS ap
					   WHERE ap.complaint_id = cmp.complaint_id
					   AND ap.decision_date BETWEEN c_from_date AND c_to_date
					   AND ap.decision IN ('30','40')))
UNION ALL
SELECT cmp.*
   FROM GHR_COMPLAINTS2 cmp
   WHERE  cmp.formal_com_filed BETWEEN c_from_date AND c_to_date
   AND cmp.agency_code = c_agency_code
   AND (cmp.complaint_closed NOT BETWEEN c_from_date AND c_to_date
		OR cmp.complaint_closed IS NULL)
   AND (EXISTS(SELECT 1 FROM GHR_COMPL_AGENCY_APPEALS apa
					   WHERE apa.complaint_id = cmp.complaint_id
					   AND apa.decision_date BETWEEN c_from_date AND c_to_date
					   AND apa.decision IN ('30','40'))
	OR EXISTS(SELECT 1 FROM GHR_COMPL_APPEALS ap
					   WHERE ap.complaint_id = cmp.complaint_id
					   AND ap.decision_date BETWEEN c_from_date AND c_to_date
					   AND ap.decision IN ('30','40')))
) cmp1
WHERE cmp1.consolidated IS NOT NULL
AND (cmp1.complaint_closed IS NULL OR cmp1.complaint_closed > c_to_date)
;

CURSOR cur_p2_8(c_from_date date, c_to_date date ,c_agency_code ghr_complaints2.agency_code%type) IS
SELECT COUNT(*) p2_8_cnt FROM
(
	SELECT cmp.*
	   FROM GHR_COMPLAINTS2 cmp
	   WHERE cmp.formal_com_filed IS NOT NULL
	   AND cmp.formal_com_filed < c_from_date
	   AND cmp.agency_code = c_agency_code
	   AND (cmp.complaint_closed IS NULL OR cmp.complaint_closed > c_from_date)
	UNION ALL
	SELECT cmp.*
	   FROM GHR_COMPLAINTS2 cmp
	   WHERE cmp.formal_com_filed BETWEEN c_from_date AND c_to_date
	   AND cmp.agency_code = c_agency_code
	   AND (NOT EXISTS(SELECT 1 FROM GHR_COMPL_AGENCY_APPEALS apa
						   WHERE apa.complaint_id = cmp.complaint_id
						   AND apa.decision_date BETWEEN c_from_date AND c_to_date
						   AND apa.decision IN ('30','40'))
	   AND	NOT EXISTS(SELECT 1 FROM GHR_COMPL_APPEALS ap
						   WHERE ap.complaint_id = cmp.complaint_id
						   AND ap.decision_date BETWEEN c_from_date AND c_to_date
						   AND ap.decision IN ('30','40')))
	UNION ALL
	SELECT cmp.*
	   FROM GHR_COMPLAINTS2 cmp
	   WHERE  cmp.formal_com_filed BETWEEN c_from_date AND c_to_date
	   AND cmp.agency_code = c_agency_code
	   AND (cmp.complaint_closed NOT BETWEEN c_from_date AND c_to_date
			OR cmp.complaint_closed IS NULL)
	   AND (EXISTS(SELECT 1 FROM GHR_COMPL_AGENCY_APPEALS apa
						   WHERE apa.complaint_id = cmp.complaint_id
						   AND apa.decision_date BETWEEN c_from_date AND c_to_date
						   AND apa.decision IN ('30','40'))
		OR EXISTS(SELECT 1 FROM GHR_COMPL_APPEALS ap
						   WHERE ap.complaint_id = cmp.complaint_id
						   AND ap.decision_date BETWEEN c_from_date AND c_to_date
						   AND ap.decision IN ('30','40')))
) cmp1
WHERE cmp1.consolidated IS NOT NULL
AND complaint_closed BETWEEN c_from_date AND c_to_date;


-- Cursor to populate section 10 - Total Individuals filing complaints
CURSOR cur_p2_10(c_from_date date, c_to_date date ,c_agency_code ghr_complaints2.agency_code%type) IS
   SELECT count(distinct nvl(cmp.complainant_person_id,0)) p2_10_cnt
   FROM GHR_COMPLAINTS2 cmp
   WHERE cmp.formal_com_filed BETWEEN c_from_date AND c_to_date
   AND cmp.agency_code = c_agency_code;

-- Cursor to Populate Section 11 - No. of Joint processing Units from consolidation of complaints
CURSOR cur_p2_11(c_from_date date, c_to_date date,c_agency_code ghr_complaints2.agency_code%type) IS
   SELECT count(distinct cmp.consolidated_complaint_id) p2_11_cnt
   FROM GHR_COMPLAINTS2 cmp
   WHERE cmp.consolidated BETWEEN c_from_date AND c_to_date
   AND cmp.consolidated_flag = 'Y'
   AND cmp.agency_code = c_agency_code;


l_p2_a number;
l_p2_b number;
l_p2_c number;
l_p2_d number;
l_p2_e number;
l_p2_f number;
l_p2_g number;
l_p2_h number;
l_p2_i number;

BEGIN
	-- Section 1 No. of complaints on hand at beginning of the reporting period.
	FOR cur_ctr IN cur_p2_1(p_from_date, p_agency_code) LOOP
	   l_p2_a := cur_ctr.p2_1_cnt;
	   vXMLTable(vCtr).TagName := 'P2_a';
	   vXMLTable(vCtr).TagValue := to_char(l_p2_a);
	   vCtr := vCtr + 1;
	END LOOP;
	fnd_file.put_line(fnd_file.log,'Finished populating Part2 Section 1 - No. of complaints on hand at beginning of the reporting period.');
	-- Section 2 - Complaints filed
	FOR cur_ctr IN cur_p2_2(p_from_date,p_to_date, p_agency_code) LOOP
	   l_p2_b := cur_ctr.p2_2_cnt;
	   vXMLTable(vCtr).TagName := 'P2_b';
	   vXMLTable(vCtr).TagValue := to_char(l_p2_b);
	   vCtr := vCtr + 1;
	END LOOP;
	fnd_file.put_line(fnd_file.log,'Finished populating Part2 Section 2 - Complaints filed');
	-- Section 3 - Remand
	FOR cur_ctr IN cur_p2_3(p_from_date,p_to_date, p_agency_code) LOOP
	   l_p2_c := cur_ctr.p2_3_cnt;
	   vXMLTable(vCtr).TagName := 'P2_c';
	   vXMLTable(vCtr).TagValue := to_char(l_p2_c);
	   vCtr := vCtr + 1;
	END LOOP;
	fnd_file.put_line(fnd_file.log,'Finished populating Part2 Section 3 - Remand');
	-- Section 4 - Total Complaints
	l_p2_d := l_p2_a + l_p2_b + l_p2_c;

	vXMLTable(vCtr).TagName := 'P2_d';
	vXMLTable(vCtr).TagValue := to_char(l_p2_d);
	vCtr := vCtr + 1;
	fnd_file.put_line(fnd_file.log,'Finished populating Part2 Section 4 - Total Complaints');
	-- Section 5 - Total Complaints that were not consolidated.
	FOR cur_ctr IN cur_p2_5(p_from_date,p_to_date, p_agency_code) LOOP
		l_p2_e := cur_ctr.p2_5_cnt;
		vXMLTable(vCtr).TagName := 'P2_e';
		vXMLTable(vCtr).TagValue := to_char(l_p2_e);
		vCtr := vCtr + 1;
	END LOOP;
	fnd_file.put_line(fnd_file.log,'Finished populating Part2 Section 5 - Total Complaints that were not consolidated.');
	-- Section 6 - Total Complaints that were not consolidated and closed.
	FOR cur_ctr IN cur_p2_6(p_from_date,p_to_date, p_agency_code) LOOP
		l_p2_f := cur_ctr.p2_6_cnt;
		vXMLTable(vCtr).TagName := 'P2_f';
		vXMLTable(vCtr).TagValue := to_char(l_p2_f);
		vCtr := vCtr + 1;
	END LOOP;
	fnd_file.put_line(fnd_file.log,'Finished populating Part2 Section 6 - Total Complaints that were not consolidated and closed.');
	-- Section 7 -  No. of consolidated complaints
	FOR cur_ctr IN cur_p2_7(p_from_date,p_to_date, p_agency_code) LOOP
		l_p2_g := cur_ctr.p2_7_cnt;
		vXMLTable(vCtr).TagName := 'P2_g';
		vXMLTable(vCtr).TagValue := to_char(l_p2_g);
		vCtr := vCtr + 1;
	END LOOP;
	fnd_file.put_line(fnd_file.log,'Finished populating Part2 Section 7 - No. of consolidated complaints');
	-- Section 8 - Total Complaints that were consolidated and closed.
	FOR cur_ctr IN cur_p2_8(p_from_date,p_to_date, p_agency_code) LOOP
		l_p2_h := cur_ctr.p2_8_cnt;
		vXMLTable(vCtr).TagName := 'P2_h';
		vXMLTable(vCtr).TagValue := to_char(l_p2_h);
		vCtr := vCtr + 1;
	END LOOP;
	fnd_file.put_line(fnd_file.log,'Finished populating Part2 Section 8 - Total Complaints that were consolidated and closed');
	-- Section 9 - Complaints on hand at end of reporting period :=   line 4 - (line 6 + line 8)
	l_p2_i := l_p2_d - (l_p2_f + l_p2_h);
	vXMLTable(vCtr).TagName := 'P2_i';
	vXMLTable(vCtr).TagValue := to_char(l_p2_i);
	vCtr := vCtr + 1;
	fnd_file.put_line(fnd_file.log,'Finished populating Part2 Section 9 - Complaints on hand at end of reporting period');
	-- Section 10 Individual filing complaints
	FOR cur_ctr IN cur_p2_10(p_from_date,p_to_date, p_agency_code) LOOP
		vXMLTable(vCtr).TagName := 'P2_j';
		vXMLTable(vCtr).TagValue := to_char(cur_ctr.p2_10_cnt);
		vCtr := vCtr + 1;
	END LOOP;
	fnd_file.put_line(fnd_file.log,'Finished populating Part2 Section 10 - Individual filing complaints');
	-- Section 11 No. of Joint Processing Units from Consolidation of Complaints
	FOR cur_ctr IN cur_p2_11(p_from_date,p_to_date, p_agency_code) LOOP
		vXMLTable(vCtr).TagName := 'P2_k';
		vXMLTable(vCtr).TagValue := to_char(cur_ctr.p2_11_cnt);
		vCtr := vCtr + 1;
	END LOOP;
	fnd_file.put_line(fnd_file.log,'Finished populating Part2 Section 11 - No. of Joint Processing Units from Consolidation of Complaints');
	fnd_file.put_line(fnd_file.log,'-----------End of Part 2----------------');
	-- End of Part 2
END populate_part2;


PROCEDURE populate_part4(
    p_from_date   in date,
	p_to_date     in date,
	p_agency_code in varchar2)
IS
CURSOR cur_p4(c_from_date date, c_to_date date, c_claim GHR_COMPL_CLAIMS.claim%type, c_basis GHR_COMPL_BASES.basis%type, c_value GHR_COMPL_BASES.value%type,c_agency_code ghr_complaints2.agency_code%type) IS
   SELECT COUNT(*) p4_cnt
   FROM GHR_COMPLAINTS2 cmp,GHR_COMPL_CLAIMS claims, GHR_COMPL_BASES bases
   WHERE bases.compl_claim_id = claims.compl_claim_id
   AND claims.complaint_id = cmp.complaint_id
   AND claims.claim = c_claim
   AND claims.phase IN (20,30)
   AND bases.basis = c_basis
   AND bases.value = c_value
   AND cmp.agency_code = c_agency_code
   AND cmp.formal_com_filed BETWEEN c_from_date AND c_to_date;

CURSOR cur_p4_novalue(c_from_date date, c_to_date date, c_claim GHR_COMPL_CLAIMS.claim%type, c_basis GHR_COMPL_BASES.basis%type,c_agency_code ghr_complaints2.agency_code%type) IS
SELECT COUNT(*) p4_cnt
   FROM GHR_COMPLAINTS2 cmp,GHR_COMPL_CLAIMS claims, GHR_COMPL_BASES bases
   WHERE bases.compl_claim_id = claims.compl_claim_id
   AND claims.complaint_id = cmp.complaint_id
   AND claims.claim = c_claim
   AND claims.phase IN (20,30)
   AND bases.basis = c_basis
   AND cmp.agency_code = c_agency_code
   AND cmp.formal_com_filed BETWEEN c_from_date AND c_to_date;

-- Only for Pay including overtime
CURSOR cur_p4_tot_pic_issue(c_from_date date, c_to_date date, c_claim GHR_COMPL_CLAIMS.claim%type,c_agency_code ghr_complaints2.agency_code%type) IS
SELECT COUNT(distinct nvl(cmp.complainant_person_id,0)) p4_prsn_cnt, COUNT(distinct cmp.complaint_id) p4_cnt
   FROM GHR_COMPLAINTS2 cmp,GHR_COMPL_CLAIMS claims
   WHERE claims.complaint_id = cmp.complaint_id
   AND claims.claim = c_claim
   AND claims.phase IN (20,30)
   AND cmp.agency_code = c_agency_code
   AND cmp.formal_com_filed BETWEEN c_from_date AND c_to_date;

CURSOR cur_p4_tot_discip_issue(c_from_date date, c_to_date date,c_agency_code ghr_complaints2.agency_code%type) IS
SELECT COUNT(distinct nvl(cmp.complainant_person_id,0)) p4_prsn_cnt, COUNT(distinct cmp.complaint_id) p4_cnt
   FROM GHR_COMPLAINTS2 cmp,GHR_COMPL_CLAIMS claims
   WHERE claims.complaint_id = cmp.complaint_id
   AND claims.claim IN ('50','60','70','80','90')
   AND claims.phase IN (20,30)
   AND cmp.agency_code = c_agency_code
   AND cmp.formal_com_filed BETWEEN c_from_date AND c_to_date;

CURSOR cur_p4_tot_harass_issue(c_from_date date, c_to_date date,c_agency_code ghr_complaints2.agency_code%type) IS
SELECT COUNT(distinct nvl(cmp.complainant_person_id,0)) p4_prsn_cnt, COUNT(distinct cmp.complaint_id) p4_cnt
   FROM GHR_COMPLAINTS2 cmp,GHR_COMPL_CLAIMS claims
   WHERE claims.complaint_id = cmp.complaint_id
   AND claims.claim IN ('130','140')
   AND claims.phase IN (20,30)
   AND cmp.agency_code = c_agency_code
   AND cmp.formal_com_filed BETWEEN c_from_date AND c_to_date;

/*CURSOR cur_p4_tot_harass_issue(c_from_date date, c_to_date date,c_agency_code ghr_complaints2.agency_code%type) IS
SELECT COUNT(distinct nvl(cmp.complainant_person_id,0)) p4_prsn_cnt, COUNT(distinct cmp.complaint_id) p4_cnt
   FROM GHR_COMPLAINTS2 cmp,GHR_COMPL_CLAIMS claims,  GHR_COMPL_BASES bases
   WHERE bases.compl_claim_id = claims.compl_claim_id
   AND claims.complaint_id = cmp.complaint_id
   AND claims.claim IN ('130','140')
   AND claims.phase IN (20,30)
   AND DECODE(claims.claim,130,bases.basis,'#') NOT IN  DECODE(claims.claim,130,'SEX','1')
   AND DECODE(claims.claim,140,bases.basis,'#') IN  DECODE(claims.claim,140,'(''GHR_US_COM_REP_BASIS'',''GHR_US_COM_SEX_BASIS'')','#')
   AND cmp.agency_code = c_agency_code
   AND cmp.formal_com_filed BETWEEN c_from_date AND c_to_date;
*/
CURSOR cur_p4_tot_reassign_issue(c_from_date date, c_to_date date,c_agency_code ghr_complaints2.agency_code%type) IS
SELECT COUNT(distinct nvl(cmp.complainant_person_id,0)) p4_prsn_cnt, COUNT(distinct cmp.complaint_id) p4_cnt
   FROM GHR_COMPLAINTS2 cmp,GHR_COMPL_CLAIMS claims
   WHERE claims.complaint_id = cmp.complaint_id
   AND claims.claim IN ('180','190')
   AND claims.phase IN (20,30)
   AND cmp.agency_code = c_agency_code
   AND cmp.formal_com_filed BETWEEN c_from_date AND c_to_date;

CURSOR cur_p4_totprsn_basis(c_from_date date, c_to_date date, c_basis GHR_COMPL_BASES.basis%type,c_agency_code ghr_complaints2.agency_code%type) IS
SELECT COUNT(distinct nvl(cmp.complainant_person_id,0)) p4_prsn_cnt, COUNT(distinct cmp.complaint_id) p4_cnt
   FROM GHR_COMPLAINTS2 cmp,GHR_COMPL_CLAIMS claims, GHR_COMPL_BASES bases
   WHERE bases.compl_claim_id = claims.compl_claim_id
   AND claims.complaint_id = cmp.complaint_id
   AND claims.phase IN (20,30)
   AND bases.basis = c_basis
   AND cmp.agency_code = c_agency_code
   AND cmp.formal_com_filed BETWEEN c_from_date AND c_to_date;

CURSOR cur_p4_totprsn_basis_value(c_from_date date, c_to_date date, c_basis GHR_COMPL_BASES.basis%type,c_value GHR_COMPL_BASES.value%type, c_agency_code ghr_complaints2.agency_code%type) IS
SELECT COUNT(distinct nvl(cmp.complainant_person_id,0)) p4_prsn_cnt,COUNT(distinct cmp.complaint_id) p4_cnt
   FROM GHR_COMPLAINTS2 cmp,GHR_COMPL_CLAIMS claims, GHR_COMPL_BASES bases
   WHERE bases.compl_claim_id = claims.compl_claim_id
   AND claims.complaint_id = cmp.complaint_id
   AND claims.phase IN (20,30)
   AND bases.basis = c_basis
   AND bases.value = c_value
   AND cmp.agency_code = c_agency_code
   AND cmp.formal_com_filed BETWEEN c_from_date AND c_to_date;

-------- Specific Total Cursors
-- Total By issues
-- For Most of the issues except pay including overtime, harassment, reassignment
CURSOR cur_p4_totprsn_issue(c_from_date date, c_to_date date, c_claim GHR_COMPL_CLAIMS.claim%type,c_agency_code ghr_complaints2.agency_code%type) IS
SELECT COUNT(distinct nvl(cmp.complainant_person_id,0)) p4_prsn_cnt, COUNT(distinct cmp.complaint_id) p4_cnt
   FROM GHR_COMPLAINTS2 cmp,GHR_COMPL_CLAIMS claims, GHR_COMPL_BASES bases
   WHERE bases.compl_claim_id = claims.compl_claim_id
   AND claims.complaint_id = cmp.complaint_id
   AND claims.claim = c_claim
   AND claims.phase IN (20,30)
   AND bases.basis <> 'SEX'
   AND cmp.agency_code = c_agency_code
   AND cmp.formal_com_filed BETWEEN c_from_date AND c_to_date;

-- For harassment Sexual
CURSOR cur_p4_tot_harass_sex_issue(c_from_date date, c_to_date date, c_claim GHR_COMPL_CLAIMS.claim%type,c_agency_code ghr_complaints2.agency_code%type) IS
SELECT COUNT(distinct nvl(cmp.complainant_person_id,0)) p4_prsn_cnt, COUNT(distinct cmp.complaint_id) p4_cnt
   FROM GHR_COMPLAINTS2 cmp,GHR_COMPL_CLAIMS claims, GHR_COMPL_BASES bases
   WHERE  bases.compl_claim_id = claims.compl_claim_id
   AND claims.complaint_id = cmp.complaint_id
   AND claims.claim = c_claim
   AND claims.phase IN (20,30)
   AND bases.basis IN ('GHR_US_COM_SEX_BASIS','GHR_US_COM_REP_BASIS')
   AND cmp.agency_code = c_agency_code
   AND cmp.formal_com_filed BETWEEN c_from_date AND c_to_date;

-- for reasonable accommodation
CURSOR cur_p4_tot_reacc_issue(c_from_date date, c_to_date date, c_claim GHR_COMPL_CLAIMS.claim%type,c_agency_code ghr_complaints2.agency_code%type) IS
SELECT COUNT(distinct nvl(cmp.complainant_person_id,0)) p4_prsn_cnt, COUNT(distinct cmp.complaint_id) p4_cnt
   FROM GHR_COMPLAINTS2 cmp,GHR_COMPL_CLAIMS claims, GHR_COMPL_BASES bases
   WHERE bases.compl_claim_id = claims.compl_claim_id
   AND claims.complaint_id = cmp.complaint_id
   AND claims.claim = c_claim
   AND claims.phase IN (20,30)
   AND bases.basis IN ('GHR_US_COM_REL_BASIS','GHR_US_COM_REP_BASIS','GHR_US_COM_HC_BASIS')
   AND cmp.agency_code = c_agency_code
   AND cmp.formal_com_filed BETWEEN c_from_date AND c_to_date;

-- For Race, National Origin

CURSOR cur_p4_totprsn_rcno_value(c_from_date date, c_to_date date, c_basis GHR_COMPL_BASES.basis%type,c_value GHR_COMPL_BASES.value%type, c_agency_code ghr_complaints2.agency_code%type) IS
SELECT COUNT(distinct nvl(cmp.complainant_person_id,0)) p4_prsn_cnt,COUNT(distinct cmp.complaint_id) p4_cnt
   FROM GHR_COMPLAINTS2 cmp,GHR_COMPL_CLAIMS claims, GHR_COMPL_BASES bases
   WHERE bases.compl_claim_id = claims.compl_claim_id
   AND claims.complaint_id = cmp.complaint_id
   AND claims.phase IN (20,30)
   AND claims.claim NOT IN ('140','200')
   AND bases.basis = c_basis
   AND bases.value = c_value
   AND cmp.agency_code = c_agency_code
   AND cmp.formal_com_filed BETWEEN c_from_date AND c_to_date;

--Color, Age
CURSOR cur_p4_tot_colage_basis(c_from_date date, c_to_date date, c_basis GHR_COMPL_BASES.basis%type,c_agency_code ghr_complaints2.agency_code%type) IS
SELECT COUNT(distinct nvl(cmp.complainant_person_id,0)) p4_prsn_cnt, COUNT(distinct cmp.complaint_id) p4_cnt
   FROM GHR_COMPLAINTS2 cmp,GHR_COMPL_CLAIMS claims, GHR_COMPL_BASES bases
   WHERE bases.compl_claim_id = claims.compl_claim_id
   AND claims.complaint_id = cmp.complaint_id
   AND claims.phase IN (20,30)
   AND claims.claim NOT IN ('140','200')
   AND bases.basis = c_basis
   AND cmp.agency_code = c_agency_code
   AND cmp.formal_com_filed BETWEEN c_from_date AND c_to_date;

-- For Religion
CURSOR cur_p4_tot_rel_basis(c_from_date date, c_to_date date, c_basis GHR_COMPL_BASES.basis%type,c_agency_code ghr_complaints2.agency_code%type) IS
SELECT COUNT(distinct nvl(cmp.complainant_person_id,0)) p4_prsn_cnt, COUNT(distinct cmp.complaint_id) p4_cnt
   FROM GHR_COMPLAINTS2 cmp,GHR_COMPL_CLAIMS claims, GHR_COMPL_BASES bases
   WHERE bases.compl_claim_id = claims.compl_claim_id
   AND claims.complaint_id = cmp.complaint_id
   AND claims.phase IN (20,30)
   AND claims.claim NOT IN ('140')
   AND bases.basis = c_basis
   AND cmp.agency_code = c_agency_code
   AND cmp.formal_com_filed BETWEEN c_from_date AND c_to_date;

-- Disability
CURSOR cur_p4_totprsn_disab_value(c_from_date date, c_to_date date, c_basis GHR_COMPL_BASES.basis%type,c_value GHR_COMPL_BASES.value%type, c_agency_code ghr_complaints2.agency_code%type) IS
SELECT COUNT(distinct nvl(cmp.complainant_person_id,0)) p4_prsn_cnt,COUNT(distinct cmp.complaint_id) p4_cnt
   FROM GHR_COMPLAINTS2 cmp,GHR_COMPL_CLAIMS claims, GHR_COMPL_BASES bases
   WHERE bases.compl_claim_id = claims.compl_claim_id
   AND claims.complaint_id = cmp.complaint_id
   AND claims.phase IN (20,30)
   AND claims.claim NOT IN ('140')
   AND bases.basis = c_basis
   AND bases.value = c_value
   AND cmp.agency_code = c_agency_code
   AND cmp.formal_com_filed BETWEEN c_from_date AND c_to_date;

-- For Sex
CURSOR cur_p4_tot_sex_basis(c_from_date date, c_to_date date, c_basis GHR_COMPL_BASES.basis%type,c_value GHR_COMPL_BASES.value%type, c_agency_code ghr_complaints2.agency_code%type) IS
SELECT COUNT(distinct nvl(cmp.complainant_person_id,0)) p4_prsn_cnt, COUNT(distinct cmp.complaint_id) p4_cnt
   FROM GHR_COMPLAINTS2 cmp,GHR_COMPL_CLAIMS claims, GHR_COMPL_BASES bases
   WHERE bases.compl_claim_id = claims.compl_claim_id
   AND claims.complaint_id = cmp.complaint_id
   AND claims.phase IN (20,30)
   AND claims.claim NOT IN ('200')
   AND bases.basis = c_basis
   AND bases.value = c_value
   AND cmp.agency_code = c_agency_code
   AND cmp.formal_com_filed BETWEEN c_from_date AND c_to_date;


-- For equal pay act
CURSOR cur_p4_tot_eqpay_basis(c_from_date date, c_to_date date, c_basis GHR_COMPL_BASES.basis%type,c_value GHR_COMPL_BASES.value%type,c_agency_code ghr_complaints2.agency_code%type) IS
SELECT COUNT(distinct nvl(cmp.complainant_person_id,0)) p4_prsn_cnt, COUNT(distinct cmp.complaint_id) p4_cnt
   FROM GHR_COMPLAINTS2 cmp,GHR_COMPL_CLAIMS claims, GHR_COMPL_BASES bases
   WHERE bases.compl_claim_id = claims.compl_claim_id
   AND claims.complaint_id = cmp.complaint_id
   AND claims.phase IN (20,30)
   AND claims.claim = '160'
   AND bases.basis = c_basis
   AND bases.value = c_value
   AND cmp.agency_code = c_agency_code
   AND cmp.formal_com_filed BETWEEN c_from_date AND c_to_date;
----

l_P4_a17 NUMBER := 0;
l_P4_a18 NUMBER := 0;
l_P4_a19 NUMBER := 0;
l_P4_b17 NUMBER := 0;
l_P4_b18 NUMBER := 0;
l_P4_b19 NUMBER := 0;
l_P4_c17 NUMBER := 0;
l_P4_c18 NUMBER := 0;
l_P4_c19 NUMBER := 0;
l_P4_d17 NUMBER := 0;
l_P4_d18 NUMBER := 0;
l_P4_d19 NUMBER := 0;
l_P4_e1_17 NUMBER := 0;
l_P4_e1_18 NUMBER := 0;
l_P4_e1_19 NUMBER := 0;
l_P4_e2_17 NUMBER := 0;
l_P4_e2_18 NUMBER := 0;
l_P4_e2_19 NUMBER := 0;
l_P4_e3_17 NUMBER := 0;
l_P4_e3_18 NUMBER := 0;
l_P4_e3_19 NUMBER := 0;
l_P4_e4_17 NUMBER := 0;
l_P4_e4_18 NUMBER := 0;
l_P4_e4_19 NUMBER := 0;
l_P4_e5_17 NUMBER := 0;
l_P4_e5_18 NUMBER := 0;
l_P4_e5_19 NUMBER := 0;
l_P4_f17 NUMBER := 0;
l_P4_f18 NUMBER := 0;
l_P4_f19 NUMBER := 0;
l_P4_g17 NUMBER := 0;
l_P4_g18 NUMBER := 0;
l_P4_g19 NUMBER := 0;
l_P4_h17 NUMBER := 0;
l_P4_h18 NUMBER := 0;
l_P4_h19 NUMBER := 0;
l_P4_i1_17 NUMBER := 0;
l_P4_i1_18 NUMBER := 0;
l_P4_i1_19 NUMBER := 0;
l_P4_i2_17 NUMBER := 0;
l_P4_i2_18 NUMBER := 0;
l_P4_i2_19 NUMBER := 0;
l_P4_j17 NUMBER := 0;
l_P4_j18 NUMBER := 0;
l_P4_j19 NUMBER := 0;
l_P4_k17 NUMBER := 0;
l_P4_k18 NUMBER := 0;
l_P4_k19 NUMBER := 0;
l_P4_l17 NUMBER := 0;
l_P4_l18 NUMBER := 0;
l_P4_l19 NUMBER := 0;
l_P4_m1_17 NUMBER := 0;
l_P4_m1_18 NUMBER := 0;
l_P4_m1_19 NUMBER := 0;
l_P4_m2_17 NUMBER := 0;
l_P4_m2_18 NUMBER := 0;
l_P4_m2_19 NUMBER := 0;
l_P4_n17 NUMBER := 0;
l_P4_n18 NUMBER := 0;
l_P4_n19 NUMBER := 0;
l_P4_o17 NUMBER := 0;
l_P4_o18 NUMBER := 0;
l_P4_o19 NUMBER := 0;
l_P4_p17 NUMBER := 0;
l_P4_p18 NUMBER := 0;
l_P4_p19 NUMBER := 0;
l_P4_q17 NUMBER := 0;
l_P4_q18 NUMBER := 0;
l_P4_q19 NUMBER := 0;
l_P4_r17 NUMBER := 0;
l_P4_r18 NUMBER := 0;
l_P4_r19 NUMBER := 0;
l_P4_s17 NUMBER := 0;
l_P4_s18 NUMBER := 0;
l_P4_s19 NUMBER := 0;
l_P4_t17 NUMBER := 0;
l_P4_t18 NUMBER := 0;
l_P4_t19 NUMBER := 0;
l_P4_u17 NUMBER := 0;
l_P4_u18 NUMBER := 0;
l_P4_u19 NUMBER := 0;

--  summary columns
l_tot1_1 NUMBER := 0;
l_tot2_1 NUMBER := 0;
l_tot3_1 NUMBER := 0;
l_tot1_2 NUMBER := 0;
l_tot2_2 NUMBER := 0;
l_tot3_2 NUMBER := 0;
l_tot1_3 NUMBER := 0;
l_tot2_3 NUMBER := 0;
l_tot3_3 NUMBER := 0;
l_tot1_4 NUMBER := 0;
l_tot2_4 NUMBER := 0;
l_tot3_4 NUMBER := 0;
l_tot1_5 NUMBER := 0;
l_tot2_5 NUMBER := 0;
l_tot3_5 NUMBER := 0;
l_tot1_6 NUMBER := 0;
l_tot2_6 NUMBER := 0;
l_tot3_6 NUMBER := 0;
l_tot1_7 NUMBER := 0;
l_tot2_7 NUMBER := 0;
l_tot3_7 NUMBER := 0;
l_tot1_8 NUMBER := 0;
l_tot2_8 NUMBER := 0;
l_tot3_8 NUMBER := 0;
l_tot1_9 NUMBER := 0;
l_tot2_9 NUMBER := 0;
l_tot3_9 NUMBER := 0;
l_tot1_10 NUMBER := 0;
l_tot2_10 NUMBER := 0;
l_tot3_10 NUMBER := 0;
l_tot1_11 NUMBER := 0;
l_tot2_11 NUMBER := 0;
l_tot3_11 NUMBER := 0;
l_tot1_12 NUMBER := 0;
l_tot2_12 NUMBER := 0;
l_tot3_12 NUMBER := 0;
l_tot1_13 NUMBER := 0;
l_tot2_13 NUMBER := 0;
l_tot3_13 NUMBER := 0;
l_tot1_14 NUMBER := 0;
l_tot2_14 NUMBER := 0;
l_tot3_14 NUMBER := 0;
l_tot1_15 NUMBER := 0;
l_tot2_15 NUMBER := 0;
l_tot3_15 NUMBER := 0;
l_tot1_16 NUMBER := 0;
l_tot2_16 NUMBER := 0;
l_tot3_16 NUMBER := 0;
-- Newly added fields
l_P4_e1 NUMBER := 0;
l_P4_e2 NUMBER := 0;
l_P4_e3 NUMBER := 0;
l_P4_e4 NUMBER := 0;
l_P4_e5 NUMBER := 0;
l_P4_e6 NUMBER := 0;
l_P4_e7 NUMBER := 0;
l_P4_e8 NUMBER := 0;
l_P4_e9 NUMBER := 0;
l_P4_e10 NUMBER := 0;
l_P4_e11 NUMBER := 0;
l_P4_e14 NUMBER := 0;
l_P4_e15 NUMBER := 0;
l_P4_e16 NUMBER := 0;
l_P4_e17 NUMBER := 0;
l_P4_e18 NUMBER := 0;
l_P4_e19 NUMBER := 0;

l_P4_m1 NUMBER := 0;
l_P4_m2 NUMBER := 0;
l_P4_m3 NUMBER := 0;
l_P4_m4 NUMBER := 0;
l_P4_m5 NUMBER := 0;
l_P4_m6 NUMBER := 0;
l_P4_m7 NUMBER := 0;
l_P4_m8 NUMBER := 0;
l_P4_m9 NUMBER := 0;
l_P4_m10 NUMBER := 0;
l_P4_m11 NUMBER := 0;
l_P4_m14 NUMBER := 0;
l_P4_m15 NUMBER := 0;
l_P4_m16 NUMBER := 0;
l_P4_m17 NUMBER := 0;
l_P4_m18 NUMBER := 0;
l_P4_m19 NUMBER := 0;

l_P4_i1 NUMBER := 0;
l_P4_i2 NUMBER := 0;
l_P4_i3 NUMBER := 0;
l_P4_i4 NUMBER := 0;
l_P4_i5 NUMBER := 0;
l_P4_i6 NUMBER := 0;
l_P4_i7 NUMBER := 0;
l_P4_i8 NUMBER := 0;
l_P4_i9 NUMBER := 0;
l_P4_i10 NUMBER := 0;
l_P4_i11 NUMBER := 0;
l_P4_i12 NUMBER := 0;
l_P4_i14 NUMBER := 0;
l_P4_i15 NUMBER := 0;
l_P4_i16 NUMBER := 0;
l_P4_i17 NUMBER := 0;
l_P4_i18 NUMBER := 0;
l_P4_i19 NUMBER := 0;

BEGIN
	fnd_file.put_line(fnd_file.log,'Starting Part4 - Fields');
	-- Loop through p4 matrix PL/SQL tables
	FOR p4_ctr IN v_P4Matrix.FIRST .. v_P4Matrix.LAST LOOP
		-- If value is null, call the cursor cur_p4_novalue, else call the cursor cur_p4
		IF TRIM(v_P4Matrix(p4_ctr).basevalues) IS NULL THEN
		    FOR cur_ctr IN cur_p4_novalue(p_from_date,p_to_date,v_P4Matrix(p4_ctr).claims,v_P4Matrix(p4_ctr).bases, p_agency_code) LOOP
				vXMLTable(vCtr).TagName := v_P4Matrix(p4_ctr).fieldname;
				vXMLTable(vCtr).TagValue := to_char(cur_ctr.p4_cnt);
	--			vCtr := vCtr + 1;
		--		fnd_file.put_line(fnd_file.log,'Finished populating Part4 ' || vXMLTable(vCtr).TagName);

				IF SUBSTR(vXMLTable(vCtr).TagName,1,4) = 'P4_e' THEN
					IF SUBSTR(vXMLTable(vCtr).TagName,LENGTH(vXMLTable(vCtr).TagName)-1) = '_1'  THEN
					   l_P4_e1 := l_P4_e1 + vXMLTable(vCtr).TagValue;
					END IF;
					IF SUBSTR(vXMLTable(vCtr).TagName,LENGTH(vXMLTable(vCtr).TagName)-1) = '_2'  THEN
					   l_P4_e2 := l_P4_e2 + vXMLTable(vCtr).TagValue;
					END IF;
					IF SUBSTR(vXMLTable(vCtr).TagName,LENGTH(vXMLTable(vCtr).TagName)-1) = '_3'  THEN
					   l_P4_e3 := l_P4_e3 + vXMLTable(vCtr).TagValue;
					END IF;
					IF SUBSTR(vXMLTable(vCtr).TagName,LENGTH(vXMLTable(vCtr).TagName)-1) = '_4'  THEN
					   l_P4_e4 := l_P4_e4 + vXMLTable(vCtr).TagValue;
					END IF;
					IF SUBSTR(vXMLTable(vCtr).TagName,LENGTH(vXMLTable(vCtr).TagName)-1) = '_5'  THEN
					   l_P4_e5 := l_P4_e5 + vXMLTable(vCtr).TagValue;
					END IF;
					IF SUBSTR(vXMLTable(vCtr).TagName,LENGTH(vXMLTable(vCtr).TagName)-1) = '_6'  THEN
					   l_P4_e6 := l_P4_e6 + vXMLTable(vCtr).TagValue;
					END IF;
					IF SUBSTR(vXMLTable(vCtr).TagName,LENGTH(vXMLTable(vCtr).TagName)-1) = '_7'  THEN
					   l_P4_e7 := l_P4_e7 + vXMLTable(vCtr).TagValue;
					END IF;
					IF SUBSTR(vXMLTable(vCtr).TagName,LENGTH(vXMLTable(vCtr).TagName)-1) = '_8'  THEN
					   l_P4_e8 := l_P4_e8 + vXMLTable(vCtr).TagValue;
					END IF;
					IF SUBSTR(vXMLTable(vCtr).TagName,LENGTH(vXMLTable(vCtr).TagName)-1) = '_9'  THEN
					   l_P4_e9 := l_P4_e9 + vXMLTable(vCtr).TagValue;
					END IF;
					IF SUBSTR(vXMLTable(vCtr).TagName,LENGTH(vXMLTable(vCtr).TagName)-2) = '_10'  THEN
					   l_P4_e10 := l_P4_e10 + vXMLTable(vCtr).TagValue;
					END IF;
					IF SUBSTR(vXMLTable(vCtr).TagName,LENGTH(vXMLTable(vCtr).TagName)-2) = '_11'  THEN
					   l_P4_e11 := l_P4_e11 + vXMLTable(vCtr).TagValue;
					END IF;
					IF SUBSTR(vXMLTable(vCtr).TagName,LENGTH(vXMLTable(vCtr).TagName)-2) = '_14'  THEN
					   l_P4_e14 := l_P4_e14 + vXMLTable(vCtr).TagValue;
					END IF;
					IF SUBSTR(vXMLTable(vCtr).TagName,LENGTH(vXMLTable(vCtr).TagName)-2) = '_15'  THEN
					   l_P4_e15 := l_P4_e15 + vXMLTable(vCtr).TagValue;
					END IF;
					IF SUBSTR(vXMLTable(vCtr).TagName,LENGTH(vXMLTable(vCtr).TagName)-2) = '_16'  THEN
					   l_P4_e16 := l_P4_e16 + vXMLTable(vCtr).TagValue;
					END IF;
				END IF;

				IF SUBSTR(vXMLTable(vCtr).TagName,1,4) = 'P4_m' THEN
					IF SUBSTR(vXMLTable(vCtr).TagName,LENGTH(vXMLTable(vCtr).TagName)-1) = '_1'  THEN
					   l_P4_m1 := l_P4_m1 + vXMLTable(vCtr).TagValue;
					END IF;
					IF SUBSTR(vXMLTable(vCtr).TagName,LENGTH(vXMLTable(vCtr).TagName)-1) = '_2'  THEN
					   l_P4_m2 := l_P4_m2 + vXMLTable(vCtr).TagValue;
					END IF;
					IF SUBSTR(vXMLTable(vCtr).TagName,LENGTH(vXMLTable(vCtr).TagName)-1) = '_3'  THEN
					   l_P4_m3 := l_P4_m3 + vXMLTable(vCtr).TagValue;
					END IF;
					IF SUBSTR(vXMLTable(vCtr).TagName,LENGTH(vXMLTable(vCtr).TagName)-1) = '_4'  THEN
					   l_P4_m4 := l_P4_m4 + vXMLTable(vCtr).TagValue;
					END IF;
					IF SUBSTR(vXMLTable(vCtr).TagName,LENGTH(vXMLTable(vCtr).TagName)-1) = '_5'  THEN
					   l_P4_m5 := l_P4_m5 + vXMLTable(vCtr).TagValue;
					END IF;
					IF SUBSTR(vXMLTable(vCtr).TagName,LENGTH(vXMLTable(vCtr).TagName)-1) = '_6'  THEN
					   l_P4_m6 := l_P4_m6 + vXMLTable(vCtr).TagValue;
					END IF;
					IF SUBSTR(vXMLTable(vCtr).TagName,LENGTH(vXMLTable(vCtr).TagName)-1) = '_7'  THEN
					   l_P4_m7 := l_P4_m7 + vXMLTable(vCtr).TagValue;
					END IF;
					IF SUBSTR(vXMLTable(vCtr).TagName,LENGTH(vXMLTable(vCtr).TagName)-1) = '_8'  THEN
					   l_P4_m8 := l_P4_m8 + vXMLTable(vCtr).TagValue;
					END IF;
					IF SUBSTR(vXMLTable(vCtr).TagName,LENGTH(vXMLTable(vCtr).TagName)-1) = '_9'  THEN
					   l_P4_m9 := l_P4_m9 + vXMLTable(vCtr).TagValue;
					END IF;
					IF SUBSTR(vXMLTable(vCtr).TagName,LENGTH(vXMLTable(vCtr).TagName)-2) = '_10'  THEN
					   l_P4_m10 := l_P4_m10 + vXMLTable(vCtr).TagValue;
					END IF;
					IF SUBSTR(vXMLTable(vCtr).TagName,LENGTH(vXMLTable(vCtr).TagName)-2) = '_11'  THEN
					   l_P4_m11 := l_P4_m11 + vXMLTable(vCtr).TagValue;
					END IF;
					IF SUBSTR(vXMLTable(vCtr).TagName,LENGTH(vXMLTable(vCtr).TagName)-2) = '_14'  THEN
					   l_P4_m14 := l_P4_m14 + vXMLTable(vCtr).TagValue;
					END IF;
					IF SUBSTR(vXMLTable(vCtr).TagName,LENGTH(vXMLTable(vCtr).TagName)-2) = '_15'  THEN
					   l_P4_m15 := l_P4_m15 + vXMLTable(vCtr).TagValue;
					END IF;
					IF SUBSTR(vXMLTable(vCtr).TagName,LENGTH(vXMLTable(vCtr).TagName)-2) = '_16'  THEN
					   l_P4_m16 := l_P4_m16 + vXMLTable(vCtr).TagValue;
					END IF;
				END IF;

				IF (vXMLTable(vCtr).TagName = 'P4_i1_1') THEN
					l_P4_i1 :=  vXMLTable(vCtr).TagValue;
				END IF;

				IF (vXMLTable(vCtr).TagName = 'P4_i1_2') THEN
					l_P4_i2 :=  vXMLTable(vCtr).TagValue;
				END IF;

				IF (vXMLTable(vCtr).TagName = 'P4_i1_3') THEN
					l_P4_i3 :=  vXMLTable(vCtr).TagValue;
				END IF;

				IF (vXMLTable(vCtr).TagName = 'P4_i1_4') THEN
					l_P4_i4 :=  vXMLTable(vCtr).TagValue;
				END IF;

				IF (vXMLTable(vCtr).TagName = 'P4_i1_5') THEN
					l_P4_i5 :=  vXMLTable(vCtr).TagValue;
				END IF;

				IF (vXMLTable(vCtr).TagName = 'P4_i1_6') THEN
					l_P4_i6 :=  vXMLTable(vCtr).TagValue;
				END IF;

				IF (vXMLTable(vCtr).TagName = 'P4_i1_10') THEN
					l_P4_i10 :=  vXMLTable(vCtr).TagValue;
				END IF;

				IF (vXMLTable(vCtr).TagName = 'P4_i1_11') THEN
					l_P4_i11 :=  vXMLTable(vCtr).TagValue;
				END IF;

				IF (vXMLTable(vCtr).TagName = 'P4_i1_14') THEN
					l_P4_i14 :=  vXMLTable(vCtr).TagValue;
				END IF;

				IF (vXMLTable(vCtr).TagName = 'P4_i1_15') THEN
					l_P4_i15 :=  vXMLTable(vCtr).TagValue;
				END IF;

				IF (vXMLTable(vCtr).TagName = 'P4_i1_16') THEN
					l_P4_i16 :=  vXMLTable(vCtr).TagValue;
				END IF;

				IF SUBSTR(vXMLTable(vCtr).TagName,1,4) = 'P4_i' THEN
					IF SUBSTR(vXMLTable(vCtr).TagName,LENGTH(vXMLTable(vCtr).TagName)-1) = '_7'  THEN
					   l_P4_i7 := l_P4_i7 + vXMLTable(vCtr).TagValue;
					END IF;
					IF SUBSTR(vXMLTable(vCtr).TagName,LENGTH(vXMLTable(vCtr).TagName)-1) = '_8'  THEN
					   l_P4_i8 := l_P4_i8 + vXMLTable(vCtr).TagValue;
					END IF;
					IF SUBSTR(vXMLTable(vCtr).TagName,LENGTH(vXMLTable(vCtr).TagName)-1) = '_9'  THEN
					   l_P4_i9 := l_P4_i9 + vXMLTable(vCtr).TagValue;
					END IF;
				END IF;

				-- Populating the summary columns by Looping through rowwise
				-- If Claim is Assignment
				IF v_P4Matrix(p4_ctr).claims = '10' THEN
				   l_P4_a17 := l_P4_a17 + cur_ctr.p4_cnt;
				-- Complainants by Issue
					IF (l_P4_a19 > 0) AND (l_P4_a18 > 0) THEN
					   NULL;
					ELSE
						FOR cur_totissue IN cur_p4_totprsn_issue(p_from_date,p_to_date,v_P4Matrix(p4_ctr).claims, p_agency_code) LOOP
						   l_P4_a19 := cur_totissue.p4_prsn_cnt;
						   l_P4_a18 := cur_totissue.p4_cnt;
						END LOOP;
					END IF;
				-- If Claim is Assignment of Duties
				ELSIF v_P4Matrix(p4_ctr).claims = '20' THEN
                    l_P4_b17 := l_P4_b17 + cur_ctr.p4_cnt;
					-- Complainants by Issue
					IF (l_P4_b19 > 0) AND (l_P4_b18 > 0) THEN
					   NULL;
					ELSE
						FOR cur_totissue IN cur_p4_totprsn_issue(p_from_date,p_to_date,v_P4Matrix(p4_ctr).claims, p_agency_code) LOOP
						   l_P4_b19 := cur_totissue.p4_prsn_cnt;
						   l_P4_b18 := cur_totissue.p4_cnt;
						END LOOP;
					END IF;
				-- If Claim is Awards
				ELSIF v_P4Matrix(p4_ctr).claims = '30' THEN
                    l_P4_c17 := l_P4_c17 + cur_ctr.p4_cnt;
					-- Complainants by Issue
					IF (l_P4_c19 > 0) AND (l_P4_c18 > 0) THEN
					   NULL;
					ELSE
						FOR cur_totissue IN cur_p4_totprsn_issue(p_from_date,p_to_date,v_P4Matrix(p4_ctr).claims, p_agency_code) LOOP
						   l_P4_c19 := cur_totissue.p4_prsn_cnt;
						   l_P4_c18 := cur_totissue.p4_cnt;
						END LOOP;
					END IF;
				-- If Claim is Awards
				-- If Claim is Conversion to full time.
				ELSIF v_P4Matrix(p4_ctr).claims = '40' THEN
                    l_P4_d17 := l_P4_d17 + cur_ctr.p4_cnt;
					-- Complainants by Issue
					IF (l_P4_d19 > 0) AND (l_P4_d18 > 0)  THEN
					   NULL;
					ELSE
						FOR cur_totissue IN cur_p4_totprsn_issue(p_from_date,p_to_date,v_P4Matrix(p4_ctr).claims, p_agency_code) LOOP
						   l_P4_d19 := cur_totissue.p4_prsn_cnt;
						   l_P4_d18 := cur_totissue.p4_cnt;
						END LOOP;
					END IF;
				-- If Claim is Awards
				ELSIF v_P4Matrix(p4_ctr).claims = '50' THEN
                    l_P4_e1_17 := l_P4_e1_17 + cur_ctr.p4_cnt;
		--			l_P4_e17 := l_P4_e17 + l_P4_e1_17;
					-- Complainants by Issue
					IF (l_P4_e1_19 > 0) AND (l_P4_e1_18 > 0) THEN
					   NULL;
					ELSE
						FOR cur_totissue IN cur_p4_totprsn_issue(p_from_date,p_to_date,v_P4Matrix(p4_ctr).claims, p_agency_code) LOOP
						   l_P4_e1_19 := cur_totissue.p4_prsn_cnt;
						   l_P4_e1_18 := cur_totissue.p4_cnt;
						END LOOP;
					END IF;
				-- If Claim is Awards
				ELSIF v_P4Matrix(p4_ctr).claims = '60' THEN
                    l_P4_e2_17 := l_P4_e2_17 + cur_ctr.p4_cnt;
		--			l_P4_e17 := l_P4_e17 + l_P4_e2_17;
					-- Complainants by Issue
					IF (l_P4_e2_19 > 0) AND (l_P4_e2_18 > 0) THEN
					   NULL;
					ELSE
						FOR cur_totissue IN cur_p4_totprsn_issue(p_from_date,p_to_date,v_P4Matrix(p4_ctr).claims, p_agency_code) LOOP
						   l_P4_e2_19 := cur_totissue.p4_prsn_cnt;
						   l_P4_e2_18 := cur_totissue.p4_cnt;
						END LOOP;
					END IF;
				ELSIF v_P4Matrix(p4_ctr).claims = '70' THEN
                    l_P4_e3_17 := l_P4_e3_17 + cur_ctr.p4_cnt;
		--			l_P4_e17 := l_P4_e17 + l_P4_e3_17;
					-- Complainants by Issue
					IF (l_P4_e3_19 > 0) AND (l_P4_e3_18 > 0) THEN
					   NULL;
					ELSE
						FOR cur_totissue IN cur_p4_totprsn_issue(p_from_date,p_to_date,v_P4Matrix(p4_ctr).claims, p_agency_code) LOOP
						   l_P4_e3_19 := cur_totissue.p4_prsn_cnt;
						   l_P4_e3_18 := cur_totissue.p4_cnt;
						END LOOP;
					END IF;
				ELSIF v_P4Matrix(p4_ctr).claims = '80' THEN
                    l_P4_e4_17 := l_P4_e4_17 + cur_ctr.p4_cnt;
		--			l_P4_e17 := l_P4_e17 + l_P4_e4_17;

					-- Complainants by Issue
					IF (l_P4_e4_19 > 0) AND (l_P4_e4_18 > 0) THEN
					   NULL;
					ELSE
						FOR cur_totissue IN cur_p4_totprsn_issue(p_from_date,p_to_date,v_P4Matrix(p4_ctr).claims, p_agency_code) LOOP
						   l_P4_e4_19 := cur_totissue.p4_prsn_cnt;
						   l_P4_e4_18 := cur_totissue.p4_cnt;
						END LOOP;
					END IF;
				ELSIF v_P4Matrix(p4_ctr).claims = '90' THEN
                    l_P4_e5_17 := l_P4_e5_17 + cur_ctr.p4_cnt;
		--			l_P4_e17 := l_P4_e17 + l_P4_e5_17;

					-- Complainants by Issue
					IF (l_P4_e5_19 > 0) AND (l_P4_e5_18 > 0) THEN
					   NULL;
					ELSE
						FOR cur_totissue IN cur_p4_totprsn_issue(p_from_date,p_to_date,v_P4Matrix(p4_ctr).claims, p_agency_code) LOOP
						   l_P4_e5_19 := cur_totissue.p4_prsn_cnt;
						   l_P4_e5_18 := cur_totissue.p4_cnt;
						END LOOP;
					END IF;
				ELSIF v_P4Matrix(p4_ctr).claims = '100' THEN
                    l_P4_f17 := l_P4_f17 + cur_ctr.p4_cnt;
					-- Complainants by Issue
					IF (l_P4_f19 > 0) AND (l_P4_f18 > 0) THEN
					   NULL;
					ELSE
						FOR cur_totissue IN cur_p4_totprsn_issue(p_from_date,p_to_date,v_P4Matrix(p4_ctr).claims, p_agency_code) LOOP
						   l_P4_f19 := cur_totissue.p4_prsn_cnt;
						   l_P4_f18 := cur_totissue.p4_cnt;
						END LOOP;
					END IF;
				ELSIF v_P4Matrix(p4_ctr).claims = '110' THEN
                    l_P4_g17 := l_P4_g17 + cur_ctr.p4_cnt;
					-- Complainants by Issue
					IF (l_P4_g19 > 0) AND (l_P4_g18 > 0) THEN
					   NULL;
					ELSE
						FOR cur_totissue IN cur_p4_totprsn_issue(p_from_date,p_to_date,v_P4Matrix(p4_ctr).claims, p_agency_code) LOOP
						   l_P4_g19 := cur_totissue.p4_prsn_cnt;
						   l_P4_g18 := cur_totissue.p4_cnt;
						END LOOP;
					END IF;
				ELSIF v_P4Matrix(p4_ctr).claims = '120' THEN
                    l_P4_h17 := l_P4_h17 + cur_ctr.p4_cnt;
					-- Complainants by Issue
					IF (l_P4_h19 > 0) AND (l_P4_h18 > 0) THEN
					   NULL;
					ELSE
						FOR cur_totissue IN cur_p4_totprsn_issue(p_from_date,p_to_date,v_P4Matrix(p4_ctr).claims, p_agency_code) LOOP
						   l_P4_h19 := cur_totissue.p4_prsn_cnt;
						   l_P4_h18 := cur_totissue.p4_cnt;
						END LOOP;
					END IF;
				ELSIF v_P4Matrix(p4_ctr).claims = '130' THEN
                    l_P4_i1_17 := l_P4_i1_17 + cur_ctr.p4_cnt;
		--			l_P4_i17 := l_P4_i17 + l_P4_i1_17;
					-- Complainants by Issue
					IF (l_P4_i1_19 > 0) AND (l_P4_i1_18 > 0) THEN
					   NULL;
					ELSE
						FOR cur_totissue IN cur_p4_totprsn_issue(p_from_date,p_to_date,v_P4Matrix(p4_ctr).claims, p_agency_code) LOOP
						   l_P4_i1_19 := cur_totissue.p4_prsn_cnt;
						   l_P4_i1_18 := cur_totissue.p4_cnt;
						END LOOP;
					END IF;
				ELSIF v_P4Matrix(p4_ctr).claims = '140' THEN
                    l_P4_i2_17 := l_P4_i2_17 + cur_ctr.p4_cnt;
		--			l_P4_i17 := l_P4_i17 + l_P4_i2_17;
					-- Complainants by Issue
					IF (l_P4_i2_19 > 0) AND (l_P4_i2_18 > 0) THEN
					   NULL;
					ELSE
						FOR cur_totissue IN cur_p4_tot_harass_sex_issue(p_from_date,p_to_date,v_P4Matrix(p4_ctr).claims, p_agency_code) LOOP
						   l_P4_i2_19 := cur_totissue.p4_prsn_cnt;
						   l_P4_i2_18 := cur_totissue.p4_cnt;
						END LOOP;
					END IF;
				ELSIF v_P4Matrix(p4_ctr).claims = '150' THEN
                    l_P4_j17 := l_P4_j17 + cur_ctr.p4_cnt;
					-- Complainants by Issue
					IF (l_P4_j19 > 0) AND (l_P4_j18 > 0) THEN
					   NULL;
					ELSE
						FOR cur_totissue IN cur_p4_totprsn_issue(p_from_date,p_to_date,v_P4Matrix(p4_ctr).claims, p_agency_code) LOOP
						   l_P4_j19 := cur_totissue.p4_prsn_cnt;
						   l_P4_j18 := cur_totissue.p4_cnt;
						END LOOP;
					END IF;
				ELSIF v_P4Matrix(p4_ctr).claims = '160' THEN
                    l_P4_k17 := l_P4_k17 + cur_ctr.p4_cnt;
					-- Complainants by Issue
					IF (l_P4_k19 > 0) AND (l_P4_k18 > 0) THEN
					   NULL;
					ELSE
						FOR cur_totissue IN cur_p4_tot_pic_issue(p_from_date,p_to_date,v_P4Matrix(p4_ctr).claims, p_agency_code) LOOP
						   l_P4_k19 := cur_totissue.p4_prsn_cnt;
						   l_P4_k18 := cur_totissue.p4_cnt;
						END LOOP;
					END IF;
				ELSIF v_P4Matrix(p4_ctr).claims = '170' THEN
                    l_P4_l17 := l_P4_l17 + cur_ctr.p4_cnt;
					-- Complainants by Issue
					IF (l_P4_l19 > 0) AND (l_P4_l18 > 0) THEN
					   NULL;
					ELSE
						FOR cur_totissue IN cur_p4_totprsn_issue(p_from_date,p_to_date,v_P4Matrix(p4_ctr).claims, p_agency_code) LOOP
						   l_P4_l19 := cur_totissue.p4_prsn_cnt;
						   l_P4_l18 := cur_totissue.p4_cnt;
						END LOOP;
					END IF;
				ELSIF v_P4Matrix(p4_ctr).claims = '180' THEN
                    l_P4_m1_17 := l_P4_m1_17 + cur_ctr.p4_cnt;
		--			l_P4_m17 := l_P4_m17 + l_P4_m1_17;
					-- Complainants by Issue
					IF (l_P4_m1_19 > 0) AND (l_P4_m1_18 > 0) THEN
					   NULL;
					ELSE
						FOR cur_totissue IN cur_p4_totprsn_issue(p_from_date,p_to_date,v_P4Matrix(p4_ctr).claims, p_agency_code) LOOP
						   l_P4_m1_19 := cur_totissue.p4_prsn_cnt;
						   l_P4_m1_18 := cur_totissue.p4_cnt;
						END LOOP;
					END IF;
				ELSIF v_P4Matrix(p4_ctr).claims = '190' THEN
                    l_P4_m2_17 := l_P4_m2_17 + cur_ctr.p4_cnt;
			--		l_P4_m17 := l_P4_m17 + l_P4_m2_17;
					-- Complainants by Issue
					IF (l_P4_m2_19 > 0) AND (l_P4_m2_18 > 0) THEN
					   NULL;
					ELSE
						FOR cur_totissue IN cur_p4_totprsn_issue(p_from_date,p_to_date,v_P4Matrix(p4_ctr).claims, p_agency_code) LOOP
						   l_P4_m2_19 := cur_totissue.p4_prsn_cnt;
						   l_P4_m2_18 := cur_totissue.p4_cnt;
						END LOOP;
					END IF;
				ELSIF v_P4Matrix(p4_ctr).claims = '200' THEN
                    l_P4_n17 := l_P4_n17 + cur_ctr.p4_cnt;
					-- Complainants by Issue
					IF (l_P4_n19 > 0) AND (l_P4_n18 > 0) THEN
					   NULL;
					ELSE
						FOR cur_totissue IN cur_p4_tot_reacc_issue(p_from_date,p_to_date,v_P4Matrix(p4_ctr).claims, p_agency_code) LOOP
						   l_P4_n19 := cur_totissue.p4_prsn_cnt;
						   l_P4_n18 := cur_totissue.p4_cnt;
						END LOOP;
					END IF;
				ELSIF v_P4Matrix(p4_ctr).claims = '210' THEN
                    l_P4_o17 := l_P4_o17 + cur_ctr.p4_cnt;
					-- Complainants by Issue
					IF (l_P4_o19 > 0) AND (l_P4_o18 > 0)THEN
					   NULL;
					ELSE
						FOR cur_totissue IN cur_p4_totprsn_issue(p_from_date,p_to_date,v_P4Matrix(p4_ctr).claims, p_agency_code) LOOP
						   l_P4_o19 := cur_totissue.p4_prsn_cnt;
						   l_P4_o18 := cur_totissue.p4_cnt;
						END LOOP;
					END IF;
				ELSIF v_P4Matrix(p4_ctr).claims = '220' THEN
                    l_P4_p17 := l_P4_p17 + cur_ctr.p4_cnt;
					-- Complainants by Issue
					IF (l_P4_p19 > 0) AND (l_P4_p18 > 0) THEN
					   NULL;
					ELSE
						FOR cur_totissue IN cur_p4_totprsn_issue(p_from_date,p_to_date,v_P4Matrix(p4_ctr).claims, p_agency_code) LOOP
						   l_P4_p19 := cur_totissue.p4_prsn_cnt;
						   l_P4_p18 := cur_totissue.p4_cnt;
						END LOOP;
					END IF;
				ELSIF v_P4Matrix(p4_ctr).claims = '230' THEN
                    l_P4_q17 := l_P4_q17 + cur_ctr.p4_cnt;
					-- Complainants by Issue
					IF (l_P4_q19 > 0) AND (l_P4_q18 > 0) THEN
					   NULL;
					ELSE
						FOR cur_totissue IN cur_p4_totprsn_issue(p_from_date,p_to_date,v_P4Matrix(p4_ctr).claims, p_agency_code) LOOP
						   l_P4_q19 := cur_totissue.p4_prsn_cnt;
						   l_P4_q18 := cur_totissue.p4_cnt;
						END LOOP;
					END IF;
				ELSIF v_P4Matrix(p4_ctr).claims = '240' THEN
                    l_P4_r17 := l_P4_r17 + cur_ctr.p4_cnt;
					-- Complainants by Issue
					IF (l_P4_r19 > 0) AND (l_P4_r18 > 0) THEN
					   NULL;
					ELSE
						FOR cur_totissue IN cur_p4_totprsn_issue(p_from_date,p_to_date,v_P4Matrix(p4_ctr).claims, p_agency_code) LOOP
						   l_P4_r19 := cur_totissue.p4_prsn_cnt;
						   l_P4_r18 := cur_totissue.p4_cnt;
						END LOOP;
					END IF;
				ELSIF v_P4Matrix(p4_ctr).claims = '250' THEN
                    l_P4_s17 := l_P4_s17 + cur_ctr.p4_cnt;
					-- Complainants by Issue
					IF (l_P4_s19 > 0) AND (l_P4_s18 > 0) THEN
					   NULL;
					ELSE
						FOR cur_totissue IN cur_p4_totprsn_issue(p_from_date,p_to_date,v_P4Matrix(p4_ctr).claims, p_agency_code) LOOP
						   l_P4_s19 := cur_totissue.p4_prsn_cnt;
						   l_P4_s18 := cur_totissue.p4_cnt;
						END LOOP;
					END IF;
				ELSIF v_P4Matrix(p4_ctr).claims = '260' THEN
                    l_P4_t17 := l_P4_t17 + cur_ctr.p4_cnt;
					-- Complainants by Issue
					IF (l_P4_t19 > 0) AND (l_P4_t18 > 0) THEN
					   NULL;
					ELSE
						FOR cur_totissue IN cur_p4_totprsn_issue(p_from_date,p_to_date,v_P4Matrix(p4_ctr).claims, p_agency_code) LOOP
						   l_P4_t19 := cur_totissue.p4_prsn_cnt;
						   l_P4_t18 := cur_totissue.p4_cnt;
						END LOOP;
					END IF;
				ELSIF v_P4Matrix(p4_ctr).claims = '270' THEN
                    l_P4_u17 := l_P4_u17 + cur_ctr.p4_cnt;
					-- Complainants by Issue
					IF (l_P4_u19 > 0) AND (l_P4_u18 > 0) THEN
					   NULL;
					ELSE
						FOR cur_totissue IN cur_p4_totprsn_issue(p_from_date,p_to_date,v_P4Matrix(p4_ctr).claims, p_agency_code) LOOP
						   l_P4_u19 := cur_totissue.p4_prsn_cnt;
						   l_P4_u18 := cur_totissue.p4_cnt;
						END LOOP;
					END IF;
				END IF;

				-- Populate Summary Rows by looping columns
				IF (v_P4Matrix(p4_ctr).bases = 'GHR_US_COM_REL_BASIS')  THEN
					l_tot1_6 := l_tot1_6 + cur_ctr.p4_cnt;
					-- Complainants by Basis
					IF (l_tot3_6 > 0) AND (l_tot2_6 > 0) THEN
					   NULL;
					ELSE
						FOR cur_totissue IN cur_p4_tot_rel_basis(p_from_date,p_to_date,v_P4Matrix(p4_ctr).bases, p_agency_code) LOOP
						   l_tot3_6 := cur_totissue.p4_prsn_cnt;
						   l_tot2_6 := cur_totissue.p4_cnt;
						END LOOP;
					END IF;
				ELSIF (v_P4Matrix(p4_ctr).bases = 'YES_NO') THEN
					l_tot1_5 := l_tot1_5 + cur_ctr.p4_cnt;
					-- Complainants by Basis
					IF (l_tot3_5 > 0) AND (l_tot2_5 > 0) THEN
					   NULL;
					ELSE
						FOR cur_totissue IN cur_p4_tot_colage_basis(p_from_date,p_to_date,v_P4Matrix(p4_ctr).bases, p_agency_code) LOOP
						   l_tot3_5 := cur_totissue.p4_prsn_cnt;
						   l_tot2_5 := cur_totissue.p4_cnt;
						END LOOP;
					END IF;
				ELSIF (v_P4Matrix(p4_ctr).bases = 'GHR_US_COM_REP_BASIS') THEN
					l_tot1_7 := l_tot1_7 + cur_ctr.p4_cnt;
					-- Complainants by Basis
					IF (l_tot3_7 > 0) AND (l_tot2_7 > 0) THEN
					   NULL;
					ELSE
						FOR cur_totissue IN cur_p4_totprsn_basis(p_from_date,p_to_date,v_P4Matrix(p4_ctr).bases, p_agency_code) LOOP
						   l_tot3_7 := cur_totissue.p4_prsn_cnt;
						   l_tot2_7 := cur_totissue.p4_cnt;
						END LOOP;
					END IF;
				ELSIF (v_P4Matrix(p4_ctr).bases = 'GHR_US_COM_AGE_BASIS') THEN
					l_tot1_14 := l_tot1_14 + cur_ctr.p4_cnt;
					-- Complainants by Basis
					IF (l_tot3_14 > 0) AND (l_tot2_14 > 0) THEN
					   NULL;
					ELSE
						FOR cur_totissue IN cur_p4_tot_colage_basis(p_from_date,p_to_date,v_P4Matrix(p4_ctr).bases, p_agency_code) LOOP
						   l_tot3_14 := cur_totissue.p4_prsn_cnt;
						   l_tot2_14 := cur_totissue.p4_cnt;
						END LOOP;
					END IF;
				END IF;

				vCtr := vCtr + 1;
			END LOOP;
		ELSE
		    FOR cur_ctr IN cur_p4(p_from_date,p_to_date,v_P4Matrix(p4_ctr).claims,v_P4Matrix(p4_ctr).bases,v_P4Matrix(p4_ctr).basevalues, p_agency_code) LOOP
				vXMLTable(vCtr).TagName := v_P4Matrix(p4_ctr).fieldname;
				vXMLTable(vCtr).TagValue := to_char(cur_ctr.p4_cnt);
--				vCtr := vCtr + 1;
--				fnd_file.put_line(fnd_file.log,'Finished populating Part4 ' || vXMLTable(vCtr).TagName);

				IF SUBSTR(vXMLTable(vCtr).TagName,1,4) = 'P4_e' THEN
					IF SUBSTR(vXMLTable(vCtr).TagName,LENGTH(vXMLTable(vCtr).TagName)-1) = '_1'  THEN
					   l_P4_e1 := l_P4_e1 + vXMLTable(vCtr).TagValue;
					END IF;
					IF SUBSTR(vXMLTable(vCtr).TagName,LENGTH(vXMLTable(vCtr).TagName)-1) = '_2'  THEN
					   l_P4_e2 := l_P4_e2 + vXMLTable(vCtr).TagValue;
					END IF;
					IF SUBSTR(vXMLTable(vCtr).TagName,LENGTH(vXMLTable(vCtr).TagName)-1) = '_3'  THEN
					   l_P4_e3 := l_P4_e3 + vXMLTable(vCtr).TagValue;
					END IF;
					IF SUBSTR(vXMLTable(vCtr).TagName,LENGTH(vXMLTable(vCtr).TagName)-1) = '_4'  THEN
					   l_P4_e4 := l_P4_e4 + vXMLTable(vCtr).TagValue;
					END IF;
					IF SUBSTR(vXMLTable(vCtr).TagName,LENGTH(vXMLTable(vCtr).TagName)-1) = '_5'  THEN
					   l_P4_e5 := l_P4_e5 + vXMLTable(vCtr).TagValue;
					END IF;
					IF SUBSTR(vXMLTable(vCtr).TagName,LENGTH(vXMLTable(vCtr).TagName)-1) = '_6'  THEN
					   l_P4_e6 := l_P4_e6 + vXMLTable(vCtr).TagValue;
					END IF;
					IF SUBSTR(vXMLTable(vCtr).TagName,LENGTH(vXMLTable(vCtr).TagName)-1) = '_7'  THEN
					   l_P4_e7 := l_P4_e7 + vXMLTable(vCtr).TagValue;
					END IF;
					IF SUBSTR(vXMLTable(vCtr).TagName,LENGTH(vXMLTable(vCtr).TagName)-1) = '_8'  THEN
					   l_P4_e8 := l_P4_e8 + vXMLTable(vCtr).TagValue;
					END IF;
					IF SUBSTR(vXMLTable(vCtr).TagName,LENGTH(vXMLTable(vCtr).TagName)-1) = '_9'  THEN
					   l_P4_e9 := l_P4_e9 + vXMLTable(vCtr).TagValue;
					END IF;
					IF SUBSTR(vXMLTable(vCtr).TagName,LENGTH(vXMLTable(vCtr).TagName)-2) = '_10'  THEN
					   l_P4_e10 := l_P4_e10 + vXMLTable(vCtr).TagValue;
					END IF;
					IF SUBSTR(vXMLTable(vCtr).TagName,LENGTH(vXMLTable(vCtr).TagName)-2) = '_11'  THEN
					   l_P4_e11 := l_P4_e11 + vXMLTable(vCtr).TagValue;
					END IF;
					IF SUBSTR(vXMLTable(vCtr).TagName,LENGTH(vXMLTable(vCtr).TagName)-2) = '_14'  THEN
					   l_P4_e14 := l_P4_e14 + vXMLTable(vCtr).TagValue;
					END IF;
					IF SUBSTR(vXMLTable(vCtr).TagName,LENGTH(vXMLTable(vCtr).TagName)-2) = '_15'  THEN
					   l_P4_e15 := l_P4_e15 + vXMLTable(vCtr).TagValue;
					END IF;
					IF SUBSTR(vXMLTable(vCtr).TagName,LENGTH(vXMLTable(vCtr).TagName)-2) = '_16'  THEN
					   l_P4_e16 := l_P4_e16 + vXMLTable(vCtr).TagValue;
					END IF;
				END IF;

				IF SUBSTR(vXMLTable(vCtr).TagName,1,4) = 'P4_m' THEN
					IF SUBSTR(vXMLTable(vCtr).TagName,LENGTH(vXMLTable(vCtr).TagName)-1) = '_1'  THEN
					   l_P4_m1 := l_P4_m1 + vXMLTable(vCtr).TagValue;
					END IF;
					IF SUBSTR(vXMLTable(vCtr).TagName,LENGTH(vXMLTable(vCtr).TagName)-1) = '_2'  THEN
					   l_P4_m2 := l_P4_m2 + vXMLTable(vCtr).TagValue;
					END IF;
					IF SUBSTR(vXMLTable(vCtr).TagName,LENGTH(vXMLTable(vCtr).TagName)-1) = '_3'  THEN
					   l_P4_m3 := l_P4_m3 + vXMLTable(vCtr).TagValue;
					END IF;
					IF SUBSTR(vXMLTable(vCtr).TagName,LENGTH(vXMLTable(vCtr).TagName)-1) = '_4'  THEN
					   l_P4_m4 := l_P4_m4 + vXMLTable(vCtr).TagValue;
					END IF;
					IF SUBSTR(vXMLTable(vCtr).TagName,LENGTH(vXMLTable(vCtr).TagName)-1) = '_5'  THEN
					   l_P4_m5 := l_P4_m5 + vXMLTable(vCtr).TagValue;
					END IF;
					IF SUBSTR(vXMLTable(vCtr).TagName,LENGTH(vXMLTable(vCtr).TagName)-1) = '_6'  THEN
					   l_P4_m6 := l_P4_m6 + vXMLTable(vCtr).TagValue;
					END IF;
					IF SUBSTR(vXMLTable(vCtr).TagName,LENGTH(vXMLTable(vCtr).TagName)-1) = '_7'  THEN
					   l_P4_m7 := l_P4_m7 + vXMLTable(vCtr).TagValue;
					END IF;
					IF SUBSTR(vXMLTable(vCtr).TagName,LENGTH(vXMLTable(vCtr).TagName)-1) = '_8'  THEN
					   l_P4_m8 := l_P4_m8 + vXMLTable(vCtr).TagValue;
					END IF;
					IF SUBSTR(vXMLTable(vCtr).TagName,LENGTH(vXMLTable(vCtr).TagName)-1) = '_9'  THEN
					   l_P4_m9 := l_P4_m9 + vXMLTable(vCtr).TagValue;
					END IF;
					IF SUBSTR(vXMLTable(vCtr).TagName,LENGTH(vXMLTable(vCtr).TagName)-2) = '_10'  THEN
					   l_P4_m10 := l_P4_m10 + vXMLTable(vCtr).TagValue;
					END IF;
					IF SUBSTR(vXMLTable(vCtr).TagName,LENGTH(vXMLTable(vCtr).TagName)-2) = '_11'  THEN
					   l_P4_m11 := l_P4_m11 + vXMLTable(vCtr).TagValue;
					END IF;
					IF SUBSTR(vXMLTable(vCtr).TagName,LENGTH(vXMLTable(vCtr).TagName)-2) = '_14'  THEN
					   l_P4_m14 := l_P4_m14 + vXMLTable(vCtr).TagValue;
					END IF;
					IF SUBSTR(vXMLTable(vCtr).TagName,LENGTH(vXMLTable(vCtr).TagName)-2) = '_15'  THEN
					   l_P4_m15 := l_P4_m15 + vXMLTable(vCtr).TagValue;
					END IF;
					IF SUBSTR(vXMLTable(vCtr).TagName,LENGTH(vXMLTable(vCtr).TagName)-2) = '_16'  THEN
					   l_P4_m16 := l_P4_m16 + vXMLTable(vCtr).TagValue;
					END IF;
				END IF;


				IF (vXMLTable(vCtr).TagName = 'P4_i1_1') THEN
					l_P4_i1 :=  vXMLTable(vCtr).TagValue;
				END IF;

				IF (vXMLTable(vCtr).TagName = 'P4_i1_2') THEN
					l_P4_i2 :=  vXMLTable(vCtr).TagValue;
				END IF;

				IF (vXMLTable(vCtr).TagName = 'P4_i1_3') THEN
					l_P4_i3 :=  vXMLTable(vCtr).TagValue;
				END IF;

				IF (vXMLTable(vCtr).TagName = 'P4_i1_4') THEN
					l_P4_i4 :=  vXMLTable(vCtr).TagValue;
				END IF;

				IF (vXMLTable(vCtr).TagName = 'P4_i1_5') THEN
					l_P4_i5 :=  vXMLTable(vCtr).TagValue;
				END IF;

				IF (vXMLTable(vCtr).TagName = 'P4_i1_6') THEN
					l_P4_i6 :=  vXMLTable(vCtr).TagValue;
				END IF;

				IF (vXMLTable(vCtr).TagName = 'P4_i1_10') THEN
					l_P4_i10 :=  vXMLTable(vCtr).TagValue;
				END IF;

				IF (vXMLTable(vCtr).TagName = 'P4_i1_11') THEN
					l_P4_i11 :=  vXMLTable(vCtr).TagValue;
				END IF;

				IF (vXMLTable(vCtr).TagName = 'P4_i1_14') THEN
					l_P4_i14 :=  vXMLTable(vCtr).TagValue;
				END IF;

				IF (vXMLTable(vCtr).TagName = 'P4_i1_15') THEN
					l_P4_i15 :=  vXMLTable(vCtr).TagValue;
				END IF;

				IF (vXMLTable(vCtr).TagName = 'P4_i1_16') THEN
					l_P4_i16 :=  vXMLTable(vCtr).TagValue;
				END IF;

				IF SUBSTR(vXMLTable(vCtr).TagName,1,4) = 'P4_i' THEN
					IF SUBSTR(vXMLTable(vCtr).TagName,LENGTH(vXMLTable(vCtr).TagName)-1) = '_7'  THEN
					   l_P4_i7 := l_P4_i7 + vXMLTable(vCtr).TagValue;
					END IF;
					IF SUBSTR(vXMLTable(vCtr).TagName,LENGTH(vXMLTable(vCtr).TagName)-1) = '_8'  THEN
					   l_P4_i8 := l_P4_i8 + vXMLTable(vCtr).TagValue;
					END IF;
					IF SUBSTR(vXMLTable(vCtr).TagName,LENGTH(vXMLTable(vCtr).TagName)-1) = '_9'  THEN
					   l_P4_i9 := l_P4_i9 + vXMLTable(vCtr).TagValue;
					END IF;
				END IF;

				-- Populating the summary columns by Looping through rowwise
				-- If Claim is Assignment
				IF v_P4Matrix(p4_ctr).claims = '10' THEN
				   l_P4_a17 := l_P4_a17 + cur_ctr.p4_cnt;

				   -- Complainants by Issue
					IF (l_P4_a19 > 0) AND (l_P4_a18 > 0) THEN
					   NULL;
					ELSE
						FOR cur_totissue IN cur_p4_totprsn_issue(p_from_date,p_to_date,v_P4Matrix(p4_ctr).claims, p_agency_code) LOOP
						   l_P4_a19 := cur_totissue.p4_prsn_cnt;
						   l_P4_a18 := cur_totissue.p4_cnt;
						END LOOP;
					END IF;
				-- If Claim is Assignment of Duties
				ELSIF v_P4Matrix(p4_ctr).claims = '20' THEN
                    l_P4_b17 := l_P4_b17 + cur_ctr.p4_cnt;
					-- Complainants by Issue
					IF (l_P4_b19 > 0) AND (l_P4_b18 > 0) THEN
					   NULL;
					ELSE
						FOR cur_totissue IN cur_p4_totprsn_issue(p_from_date,p_to_date,v_P4Matrix(p4_ctr).claims, p_agency_code) LOOP
						   l_P4_b19 := cur_totissue.p4_prsn_cnt;
						   l_P4_b18 := cur_totissue.p4_cnt;
						END LOOP;
					END IF;
				-- If Claim is Awards
				ELSIF v_P4Matrix(p4_ctr).claims = '30' THEN
                    l_P4_c17 := l_P4_c17 + cur_ctr.p4_cnt;
					-- Complainants by Issue
					IF (l_P4_c19 > 0) AND (l_P4_c18 > 0) THEN
					   NULL;
					ELSE
						FOR cur_totissue IN cur_p4_totprsn_issue(p_from_date,p_to_date,v_P4Matrix(p4_ctr).claims, p_agency_code) LOOP
						   l_P4_c19 := cur_totissue.p4_prsn_cnt;
						   l_P4_c18 := cur_totissue.p4_cnt;
						END LOOP;
					END IF;
				-- If Claim is Conversion to full time.
				ELSIF v_P4Matrix(p4_ctr).claims = '40' THEN
                    l_P4_d17 := l_P4_d17 + cur_ctr.p4_cnt;
					-- Complainants by Issue
					IF (l_P4_d19 > 0) AND (l_P4_d18 > 0) THEN
					   NULL;
					ELSE
						FOR cur_totissue IN cur_p4_totprsn_issue(p_from_date,p_to_date,v_P4Matrix(p4_ctr).claims, p_agency_code) LOOP
						   l_P4_d19 := cur_totissue.p4_prsn_cnt;
						   l_P4_d18 := cur_totissue.p4_cnt;
						END LOOP;
					END IF;
				ELSIF v_P4Matrix(p4_ctr).claims = '50' THEN
                    l_P4_e1_17 := l_P4_e1_17 + cur_ctr.p4_cnt;
		--			l_P4_e17 := l_P4_e17 + l_P4_e1_17;
 					-- Complainants by Issue
					IF (l_P4_e1_19 > 0) AND (l_P4_e1_18 > 0) THEN
					   NULL;
					ELSE
						FOR cur_totissue IN cur_p4_totprsn_issue(p_from_date,p_to_date,v_P4Matrix(p4_ctr).claims, p_agency_code) LOOP
						   l_P4_e1_19 := cur_totissue.p4_prsn_cnt;
						   l_P4_e1_18 := cur_totissue.p4_cnt;
						END LOOP;
					END IF;
				ELSIF v_P4Matrix(p4_ctr).claims = '60' THEN
                    l_P4_e2_17 := l_P4_e2_17 + cur_ctr.p4_cnt;
		--			l_P4_e17 := l_P4_e17 + l_P4_e2_17;

					-- Complainants by Issue
					IF (l_P4_e2_19 > 0) AND (l_P4_e2_18 > 0) THEN
					   NULL;
					ELSE
						FOR cur_totissue IN cur_p4_totprsn_issue(p_from_date,p_to_date,v_P4Matrix(p4_ctr).claims, p_agency_code) LOOP
						   l_P4_e2_19 := cur_totissue.p4_prsn_cnt;
						   l_P4_e2_18 := cur_totissue.p4_cnt;
						END LOOP;
					END IF;
				ELSIF v_P4Matrix(p4_ctr).claims = '70' THEN
                    l_P4_e3_17 := l_P4_e3_17 + cur_ctr.p4_cnt;
		--			l_P4_e17 := l_P4_e17 + l_P4_e3_17;

					-- Complainants by Issue
					IF (l_P4_e3_19 > 0) AND (l_P4_e3_18 > 0) THEN
					   NULL;
					ELSE
						FOR cur_totissue IN cur_p4_totprsn_issue(p_from_date,p_to_date,v_P4Matrix(p4_ctr).claims, p_agency_code) LOOP
						   l_P4_e3_19 := cur_totissue.p4_prsn_cnt;
						   l_P4_e3_18 := cur_totissue.p4_cnt;
						END LOOP;
					END IF;
				ELSIF v_P4Matrix(p4_ctr).claims = '80' THEN
                    l_P4_e4_17 := l_P4_e4_17 + cur_ctr.p4_cnt;
		--			l_P4_e17 := l_P4_e17 + l_P4_e4_17;

					-- Complainants by Issue
					IF (l_P4_e4_19 > 0) AND (l_P4_e4_18 > 0) THEN
					   NULL;
					ELSE
						FOR cur_totissue IN cur_p4_totprsn_issue(p_from_date,p_to_date,v_P4Matrix(p4_ctr).claims, p_agency_code) LOOP
						   l_P4_e4_19 := cur_totissue.p4_prsn_cnt;
						   l_P4_e4_18 := cur_totissue.p4_cnt;
						END LOOP;
					END IF;
				ELSIF v_P4Matrix(p4_ctr).claims = '90' THEN
                    l_P4_e5_17 := l_P4_e5_17 + cur_ctr.p4_cnt;
			--		l_P4_e17 := l_P4_e17 + l_P4_e5_17;
					-- Complainants by Issue
					IF (l_P4_e5_19 > 0) AND (l_P4_e5_18 > 0) THEN
					   NULL;
					ELSE
						FOR cur_totissue IN cur_p4_totprsn_issue(p_from_date,p_to_date,v_P4Matrix(p4_ctr).claims, p_agency_code) LOOP
						   l_P4_e5_19 := cur_totissue.p4_prsn_cnt;
						   l_P4_e5_18 := cur_totissue.p4_cnt;
						END LOOP;
					END IF;
				ELSIF v_P4Matrix(p4_ctr).claims = '100' THEN
                    l_P4_f17 := l_P4_f17 + cur_ctr.p4_cnt;
					-- Complainants by Issue
					IF (l_P4_f19 > 0) AND (l_P4_f18 > 0) THEN
					   NULL;
					ELSE
						FOR cur_totissue IN cur_p4_totprsn_issue(p_from_date,p_to_date,v_P4Matrix(p4_ctr).claims, p_agency_code) LOOP
						   l_P4_f19 := cur_totissue.p4_prsn_cnt;
						   l_P4_f18 := cur_totissue.p4_cnt;
						END LOOP;
					END IF;
				ELSIF v_P4Matrix(p4_ctr).claims = '110' THEN
                    l_P4_g17 := l_P4_g17 + cur_ctr.p4_cnt;
					-- Complainants by Issue
					IF (l_P4_g19 > 0) AND (l_P4_g18 > 0) THEN
					   NULL;
					ELSE
						FOR cur_totissue IN cur_p4_totprsn_issue(p_from_date,p_to_date,v_P4Matrix(p4_ctr).claims, p_agency_code) LOOP
						   l_P4_g19 := cur_totissue.p4_prsn_cnt;
						   l_P4_g18 := cur_totissue.p4_cnt;
						END LOOP;
					END IF;
				ELSIF v_P4Matrix(p4_ctr).claims = '120' THEN
                    l_P4_h17 := l_P4_h17 + cur_ctr.p4_cnt;
					-- Complainants by Issue
					IF (l_P4_h19 > 0) AND (l_P4_h18 > 0) THEN
					   NULL;
					ELSE
						FOR cur_totissue IN cur_p4_totprsn_issue(p_from_date,p_to_date,v_P4Matrix(p4_ctr).claims, p_agency_code) LOOP
						   l_P4_h19 := cur_totissue.p4_prsn_cnt;
						   l_P4_h18 := cur_totissue.p4_cnt;
						END LOOP;
					END IF;
				ELSIF v_P4Matrix(p4_ctr).claims = '130' THEN
                    l_P4_i1_17 := l_P4_i1_17 + cur_ctr.p4_cnt;
	--				l_P4_i17 := l_P4_i17 + l_P4_i1_17;
					-- Complainants by Issue
					IF (l_P4_i1_19 > 0) AND (l_P4_i1_18 > 0) THEN
					   NULL;
					ELSE
						FOR cur_totissue IN cur_p4_totprsn_issue(p_from_date,p_to_date,v_P4Matrix(p4_ctr).claims, p_agency_code) LOOP
						   l_P4_i1_19 := cur_totissue.p4_prsn_cnt;
						   l_P4_i1_18 := cur_totissue.p4_cnt;
						END LOOP;
					END IF;
				ELSIF v_P4Matrix(p4_ctr).claims = '140' THEN
                    l_P4_i2_17 := l_P4_i2_17 + cur_ctr.p4_cnt;
	--				l_P4_i17 := l_P4_i17 + l_P4_i2_17;
					-- Complainants by Issue
					IF (l_P4_i2_19 > 0) AND (l_P4_i2_18 > 0) THEN
					   NULL;
					ELSE
						FOR cur_totissue IN cur_p4_tot_harass_sex_issue(p_from_date,p_to_date,v_P4Matrix(p4_ctr).claims, p_agency_code) LOOP
						   l_P4_i2_19 := cur_totissue.p4_prsn_cnt;
						   l_P4_i2_18 := cur_totissue.p4_cnt;
						END LOOP;
					END IF;
				ELSIF v_P4Matrix(p4_ctr).claims = '150' THEN
                    l_P4_j17 := l_P4_j17 + cur_ctr.p4_cnt;
					-- Complainants by Issue
					IF (l_P4_j19 > 0) AND (l_P4_j18 > 0) THEN
					   NULL;
					ELSE
						FOR cur_totissue IN cur_p4_totprsn_issue(p_from_date,p_to_date,v_P4Matrix(p4_ctr).claims, p_agency_code) LOOP
						   l_P4_j19 := cur_totissue.p4_prsn_cnt;
						   l_P4_j18 := cur_totissue.p4_cnt;
						END LOOP;
					END IF;
				ELSIF v_P4Matrix(p4_ctr).claims = '160' THEN
                    l_P4_k17 := l_P4_k17 + cur_ctr.p4_cnt;
					-- Complainants by Issue
					IF (l_P4_k19 > 0) AND (l_P4_k18 > 0) THEN
					   NULL;
					ELSE
						FOR cur_totissue IN cur_p4_tot_pic_issue(p_from_date,p_to_date,v_P4Matrix(p4_ctr).claims, p_agency_code) LOOP
						   l_P4_k19 := cur_totissue.p4_prsn_cnt;
						   l_P4_k18 := cur_totissue.p4_cnt;
						END LOOP;
					END IF;
				ELSIF v_P4Matrix(p4_ctr).claims = '170' THEN
                    l_P4_l17 := l_P4_l17 + cur_ctr.p4_cnt;
					-- Complainants by Issue
					IF (l_P4_l19 > 0) AND (l_P4_l18 > 0) THEN
					   NULL;
					ELSE
						FOR cur_totissue IN cur_p4_totprsn_issue(p_from_date,p_to_date,v_P4Matrix(p4_ctr).claims, p_agency_code) LOOP
						   l_P4_l19 := cur_totissue.p4_prsn_cnt;
						   l_P4_l18 := cur_totissue.p4_cnt;
						END LOOP;
					END IF;
				ELSIF v_P4Matrix(p4_ctr).claims = '180' THEN
                    l_P4_m1_17 := l_P4_m1_17 + cur_ctr.p4_cnt;
		--			l_P4_m17 := l_P4_m17 + l_P4_m1_17;
					-- Complainants by Issue
					IF (l_P4_m1_19 > 0) AND (l_P4_m1_18 > 0) THEN
					   NULL;
					ELSE
						FOR cur_totissue IN cur_p4_totprsn_issue(p_from_date,p_to_date,v_P4Matrix(p4_ctr).claims, p_agency_code) LOOP
						   l_P4_m1_19 := cur_totissue.p4_prsn_cnt;
						   l_P4_m1_18 := cur_totissue.p4_cnt;
						END LOOP;
					END IF;
				ELSIF v_P4Matrix(p4_ctr).claims = '190' THEN
                    l_P4_m2_17 := l_P4_m2_17 + cur_ctr.p4_cnt;
		--			l_P4_m17 := l_P4_m17 + l_P4_m2_17;
					-- Complainants by Issue
					IF (l_P4_m2_19 > 0) AND (l_P4_m2_18 > 0) THEN
					   NULL;
					ELSE
						FOR cur_totissue IN cur_p4_totprsn_issue(p_from_date,p_to_date,v_P4Matrix(p4_ctr).claims, p_agency_code) LOOP
						   l_P4_m2_19 := cur_totissue.p4_prsn_cnt;
   						   l_P4_m2_18 := cur_totissue.p4_cnt;
						END LOOP;
					END IF;
				ELSIF v_P4Matrix(p4_ctr).claims = '200' THEN
                    l_P4_n17 := l_P4_n17 + cur_ctr.p4_cnt;
					-- Complainants by Issue
					IF (l_P4_n19 > 0) AND (l_P4_n18 > 0)  THEN
					   NULL;
					ELSE
						FOR cur_totissue IN cur_p4_tot_reacc_issue(p_from_date,p_to_date,v_P4Matrix(p4_ctr).claims, p_agency_code) LOOP
						   l_P4_n19 := cur_totissue.p4_prsn_cnt;
						   l_P4_n18 := cur_totissue.p4_cnt;
						END LOOP;
					END IF;
				ELSIF v_P4Matrix(p4_ctr).claims = '210' THEN
                    l_P4_o17 := l_P4_o17 + cur_ctr.p4_cnt;
					-- Complainants by Issue
					IF (l_P4_o19 > 0) AND (l_P4_o18 > 0) THEN
					   NULL;
					ELSE
						FOR cur_totissue IN cur_p4_totprsn_issue(p_from_date,p_to_date,v_P4Matrix(p4_ctr).claims, p_agency_code) LOOP
						   l_P4_o19 := cur_totissue.p4_prsn_cnt;
						   l_P4_o18 := cur_totissue.p4_cnt;
						END LOOP;
					END IF;
				ELSIF v_P4Matrix(p4_ctr).claims = '220' THEN
                    l_P4_p17 := l_P4_p17 + cur_ctr.p4_cnt;
					-- Complainants by Issue
					IF (l_P4_p19 > 0) THEN
					   NULL;
					ELSE
						FOR cur_totissue IN cur_p4_totprsn_issue(p_from_date,p_to_date,v_P4Matrix(p4_ctr).claims, p_agency_code) LOOP
						   l_P4_p19 := cur_totissue.p4_prsn_cnt;
						   l_P4_p18 := cur_totissue.p4_cnt;
						END LOOP;
					END IF;
				ELSIF v_P4Matrix(p4_ctr).claims = '230' THEN
                    l_P4_q17 := l_P4_q17 + cur_ctr.p4_cnt;
					-- Complainants by Issue
					IF (l_P4_q19 > 0) AND (l_P4_q18 > 0) THEN
					   NULL;
					ELSE
						FOR cur_totissue IN cur_p4_totprsn_issue(p_from_date,p_to_date,v_P4Matrix(p4_ctr).claims, p_agency_code) LOOP
						   l_P4_q19 := cur_totissue.p4_prsn_cnt;
						   l_P4_q18 := cur_totissue.p4_cnt;
						END LOOP;
					END IF;
				ELSIF v_P4Matrix(p4_ctr).claims = '240' THEN
                    l_P4_r17 := l_P4_r17 + cur_ctr.p4_cnt;
					-- Complainants by Issue
					IF (l_P4_r19 > 0) AND (l_P4_r18 > 0) THEN
					   NULL;
					ELSE
						FOR cur_totissue IN cur_p4_totprsn_issue(p_from_date,p_to_date,v_P4Matrix(p4_ctr).claims, p_agency_code) LOOP
						   l_P4_r19 := cur_totissue.p4_prsn_cnt;
						   l_P4_r18 := cur_totissue.p4_cnt;
						END LOOP;
					END IF;
				ELSIF v_P4Matrix(p4_ctr).claims = '250' THEN
                    l_P4_s17 := l_P4_s17 + cur_ctr.p4_cnt;
					-- Complainants by Issue
					IF (l_P4_s19 > 0) AND (l_P4_s18 > 0) THEN
					   NULL;
					ELSE
						FOR cur_totissue IN cur_p4_totprsn_issue(p_from_date,p_to_date,v_P4Matrix(p4_ctr).claims, p_agency_code) LOOP
						   l_P4_s19 := cur_totissue.p4_prsn_cnt;
						   l_P4_s18 := cur_totissue.p4_cnt;
						END LOOP;
					END IF;
				ELSIF v_P4Matrix(p4_ctr).claims = '260' THEN
                    l_P4_t17 := l_P4_t17 + cur_ctr.p4_cnt;
					-- Complainants by Issue
					IF (l_P4_t19 > 0) AND (l_P4_t18 > 0) THEN
					   NULL;
					ELSE
						FOR cur_totissue IN cur_p4_totprsn_issue(p_from_date,p_to_date,v_P4Matrix(p4_ctr).claims, p_agency_code) LOOP
						   l_P4_t19 := cur_totissue.p4_prsn_cnt;
						   l_P4_t18 := cur_totissue.p4_cnt;
						END LOOP;
					END IF;
				ELSIF v_P4Matrix(p4_ctr).claims = '270' THEN
                    l_P4_u17 := l_P4_u17 + cur_ctr.p4_cnt;
					-- Complainants by Issue
					IF (l_P4_u19 > 0) AND (l_P4_u18 > 0) THEN
					   NULL;
					ELSE
						FOR cur_totissue IN cur_p4_totprsn_issue(p_from_date,p_to_date,v_P4Matrix(p4_ctr).claims, p_agency_code) LOOP
						   l_P4_u19 := cur_totissue.p4_prsn_cnt;
						   l_P4_u18 := cur_totissue.p4_cnt;
						END LOOP;
					END IF;
				END IF;

				-- Populate Summary Rows by looping columns
				IF (v_P4Matrix(p4_ctr).bases = 'GHR_US_COM_RC_BASIS' AND v_P4Matrix(p4_ctr).basevalues = '10') THEN
					l_tot1_1 := l_tot1_1 + cur_ctr.p4_cnt;
					-- Complainants by Basis
					IF (l_tot3_1 > 0) AND (l_tot2_1 > 0) THEN
					   NULL;
					ELSE
						FOR cur_totissue IN cur_p4_totprsn_rcno_value(p_from_date,p_to_date,v_P4Matrix(p4_ctr).bases,'10', p_agency_code) LOOP
						   l_tot3_1 := cur_totissue.p4_prsn_cnt;
						   l_tot2_1 := cur_totissue.p4_cnt;
						END LOOP;
					END IF;
				ELSIF (v_P4Matrix(p4_ctr).bases = 'GHR_US_COM_RC_BASIS' AND v_P4Matrix(p4_ctr).basevalues = '20') THEN
					l_tot1_2 := l_tot1_2 + cur_ctr.p4_cnt;
					-- Complainants by Basis
					IF (l_tot3_2 > 0) AND (l_tot2_2 > 0) THEN
					   NULL;
					ELSE
						FOR cur_totissue IN cur_p4_totprsn_rcno_value(p_from_date,p_to_date,v_P4Matrix(p4_ctr).bases,'20', p_agency_code) LOOP
						   l_tot3_2 := cur_totissue.p4_prsn_cnt;
						   l_tot2_2 := cur_totissue.p4_cnt;
						END LOOP;
					END IF;
				ELSIF (v_P4Matrix(p4_ctr).bases = 'GHR_US_COM_RC_BASIS' AND v_P4Matrix(p4_ctr).basevalues = '30') THEN
					l_tot1_3 := l_tot1_3 + cur_ctr.p4_cnt;
					-- Complainants by Basis
					IF (l_tot3_3 > 0) AND (l_tot2_3 > 0) THEN
					   NULL;
					ELSE
						FOR cur_totissue IN cur_p4_totprsn_rcno_value(p_from_date,p_to_date,v_P4Matrix(p4_ctr).bases, '30',p_agency_code) LOOP
						   l_tot3_3 := cur_totissue.p4_prsn_cnt;
						   l_tot2_3 := cur_totissue.p4_cnt;
						END LOOP;
					END IF;
				ELSIF (v_P4Matrix(p4_ctr).bases = 'GHR_US_COM_RC_BASIS' AND v_P4Matrix(p4_ctr).basevalues = '40') THEN
					l_tot1_4 := l_tot1_4 + cur_ctr.p4_cnt;
					-- Complainants by Basis
					IF (l_tot3_4 > 0) AND (l_tot2_4 > 0) THEN
					   NULL;
					ELSE
						FOR cur_totissue IN cur_p4_totprsn_rcno_value(p_from_date,p_to_date,v_P4Matrix(p4_ctr).bases,'40', p_agency_code) LOOP
						   l_tot3_4 := cur_totissue.p4_prsn_cnt;
						   l_tot2_4 := cur_totissue.p4_cnt;
						END LOOP;
					END IF;
				ELSIF (v_P4Matrix(p4_ctr).bases = 'GHR_US_COM_SEX_BASIS' AND v_P4Matrix(p4_ctr).basevalues = '10') THEN
					l_tot1_8 := l_tot1_8 + cur_ctr.p4_cnt;
					-- Complainants by Basis
					IF (l_tot3_8 > 0) AND (l_tot2_8 > 0) THEN
					   NULL;
					ELSE
						FOR cur_totissue IN cur_p4_tot_sex_basis(p_from_date,p_to_date,v_P4Matrix(p4_ctr).bases,'10', p_agency_code) LOOP
						   l_tot3_8 := cur_totissue.p4_prsn_cnt;
						   l_tot2_8 := cur_totissue.p4_cnt;
						END LOOP;
					END IF;
				ELSIF (v_P4Matrix(p4_ctr).bases = 'GHR_US_COM_SEX_BASIS' AND v_P4Matrix(p4_ctr).basevalues = '20') THEN
					l_tot1_9 := l_tot1_9 + cur_ctr.p4_cnt;
					-- Complainants by Basis
					IF (l_tot3_9 > 0) AND (l_tot2_9 > 0) THEN
					   NULL;
					ELSE
						FOR cur_totissue IN cur_p4_tot_sex_basis(p_from_date,p_to_date,v_P4Matrix(p4_ctr).bases, '20',p_agency_code) LOOP
						   l_tot3_9 := cur_totissue.p4_prsn_cnt;
						   l_tot2_9 := cur_totissue.p4_cnt;
						END LOOP;
					END IF;
				ELSIF (v_P4Matrix(p4_ctr).bases = 'GHR_US_COM_NO_BASIS' AND v_P4Matrix(p4_ctr).basevalues = '10') THEN
					l_tot1_10 := l_tot1_10 + cur_ctr.p4_cnt;
					-- Complainants by Basis
					IF (l_tot3_10 > 0) AND (l_tot2_10 > 0) THEN
					   NULL;
					ELSE
						FOR cur_totissue IN cur_p4_totprsn_rcno_value(p_from_date,p_to_date,v_P4Matrix(p4_ctr).bases,'10', p_agency_code) LOOP
						   l_tot3_10 := cur_totissue.p4_prsn_cnt;
						   l_tot2_10 := cur_totissue.p4_cnt;
						END LOOP;
					END IF;
				ELSIF (v_P4Matrix(p4_ctr).bases = 'GHR_US_COM_NO_BASIS' AND v_P4Matrix(p4_ctr).basevalues = '20') THEN
					l_tot1_11 := l_tot1_11 + cur_ctr.p4_cnt;
					-- Complainants by Basis
					IF (l_tot3_11 > 0) AND (l_tot2_11 > 0) THEN
					   NULL;
					ELSE
						FOR cur_totissue IN cur_p4_totprsn_rcno_value(p_from_date,p_to_date,v_P4Matrix(p4_ctr).bases, '20', p_agency_code) LOOP
						   l_tot3_11 := cur_totissue.p4_prsn_cnt;
						   l_tot2_11 := cur_totissue.p4_cnt;
						END LOOP;
					END IF;
				ELSIF (v_P4Matrix(p4_ctr).bases = 'SEX' AND v_P4Matrix(p4_ctr).basevalues = 'M') THEN
					l_tot1_12 := l_tot1_12 + cur_ctr.p4_cnt;
					--Complainants by Basis
					IF (l_tot3_12 > 0) AND (l_tot2_12 > 0) THEN
					   NULL;
					ELSE
						FOR cur_totissue IN cur_p4_tot_eqpay_basis(p_from_date,p_to_date,v_P4Matrix(p4_ctr).bases, 'M',p_agency_code) LOOP
						   l_tot3_12 := cur_totissue.p4_prsn_cnt;
						   l_tot2_12 := cur_totissue.p4_cnt;
						END LOOP;
					END IF;
				ELSIF (v_P4Matrix(p4_ctr).bases = 'SEX' AND v_P4Matrix(p4_ctr).basevalues = 'F') THEN
					l_tot1_13 := l_tot1_13 + cur_ctr.p4_cnt;
					-- Complainants by Basis
					IF (l_tot3_13 > 0) AND (l_tot2_13 > 0) THEN
					   NULL;
					ELSE
						FOR cur_totissue IN cur_p4_tot_eqpay_basis(p_from_date,p_to_date,v_P4Matrix(p4_ctr).bases,'F', p_agency_code) LOOP
						   l_tot3_13 := cur_totissue.p4_prsn_cnt;
						   l_tot2_13 := cur_totissue.p4_cnt;
						END LOOP;
					END IF;
				ELSIF (v_P4Matrix(p4_ctr).bases = 'GHR_US_COM_HC_BASIS' AND v_P4Matrix(p4_ctr).basevalues = '10') THEN
					l_tot1_15 := l_tot1_15 + cur_ctr.p4_cnt;
					-- Complainants by Basis
					IF (l_tot3_15 > 0) AND (l_tot2_15 > 0) THEN
					   NULL;
					ELSE
						FOR cur_totissue IN cur_p4_totprsn_disab_value(p_from_date,p_to_date,v_P4Matrix(p4_ctr).bases,'10', p_agency_code) LOOP
						   l_tot3_15 := cur_totissue.p4_prsn_cnt;
						   l_tot2_15 := cur_totissue.p4_cnt;
						END LOOP;
					END IF;
				ELSIF (v_P4Matrix(p4_ctr).bases = 'GHR_US_COM_HC_BASIS' AND v_P4Matrix(p4_ctr).basevalues = '20') THEN
					l_tot1_16 := l_tot1_16 + cur_ctr.p4_cnt;
					-- Complainants by Basis
					IF (l_tot3_16 > 0) AND (l_tot2_16 > 0) THEN
					   NULL;
					ELSE
						FOR cur_totissue IN cur_p4_totprsn_disab_value(p_from_date,p_to_date,v_P4Matrix(p4_ctr).bases,'20', p_agency_code) LOOP
						   l_tot3_16 := cur_totissue.p4_prsn_cnt;
						   l_tot2_16 := cur_totissue.p4_cnt;
						END LOOP;
					END IF;
				END IF;
			vCtr := vCtr + 1;
			END LOOP;
		END IF;
	END LOOP;
	fnd_file.put_line(fnd_file.log,'Finished populating Part4 - Fields');

	l_P4_e17 := l_P4_e1 + l_P4_e2 + l_P4_e3 + l_P4_e4 + l_P4_e5 + l_P4_e6 + l_P4_e7 + l_P4_e8 + l_P4_e9 + l_P4_e10 + l_P4_e11 + l_P4_e14 + l_P4_e15 + l_P4_e16;
	l_P4_m17 := l_P4_m1 + l_P4_m2 + l_P4_m3 + l_P4_m4 + l_P4_m5 + l_P4_m6 + l_P4_m7 + l_P4_m8 + l_P4_m9 + l_P4_m10 + l_P4_m11 + l_P4_m14 + l_P4_m15 + l_P4_m16;
	l_P4_i17 := l_P4_i1 + l_P4_i2 + l_P4_i3 + l_P4_i4 + l_P4_i5 + l_P4_i6 + l_P4_i7 + l_P4_i8 + l_P4_i9 + l_P4_i10 + l_P4_i11 + l_P4_i14 + l_P4_i15 + l_P4_i16;

	-- Calculating the header row for disciplinary action.
	FOR cur_totissue IN cur_p4_tot_discip_issue(p_from_date,p_to_date,p_agency_code) LOOP
	   l_P4_e19 := cur_totissue.p4_prsn_cnt;
	   l_P4_e18 := cur_totissue.p4_cnt;
	END LOOP;

	-- Calculating the header row for Reassignment
	FOR cur_totissue IN cur_p4_tot_reassign_issue(p_from_date,p_to_date,p_agency_code) LOOP
	   l_P4_m19 := cur_totissue.p4_prsn_cnt;
	   l_P4_m18 := cur_totissue.p4_cnt;
	END LOOP;

	-- Calculating the header row for  Harassment
	FOR cur_totissue IN cur_p4_tot_harass_issue(p_from_date,p_to_date,p_agency_code) LOOP
	   l_P4_i19 := cur_totissue.p4_prsn_cnt;
	   l_P4_i18 := cur_totissue.p4_cnt;
	END LOOP;

	-- Added after test plan review
	vXMLTable(vCtr).TagName := 'P4_e1';
	vXMLTable(vCtr).TagValue := to_char(l_P4_e1);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_e2';
	vXMLTable(vCtr).TagValue := to_char(l_P4_e2);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_e3';
	vXMLTable(vCtr).TagValue := to_char(l_P4_e3);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_e4';
	vXMLTable(vCtr).TagValue := to_char(l_P4_e4);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_e5';
	vXMLTable(vCtr).TagValue := to_char(l_P4_e5);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_e6';
	vXMLTable(vCtr).TagValue := to_char(l_P4_e6);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_e7';
	vXMLTable(vCtr).TagValue := to_char(l_P4_e7);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_e8';
	vXMLTable(vCtr).TagValue := to_char(l_P4_e8);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_e9';
	vXMLTable(vCtr).TagValue := to_char(l_P4_e9);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_e10';
	vXMLTable(vCtr).TagValue := to_char(l_P4_e10);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_e11';
	vXMLTable(vCtr).TagValue := to_char(l_P4_e11);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_e14';
	vXMLTable(vCtr).TagValue := to_char(l_P4_e14);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_e15';
	vXMLTable(vCtr).TagValue := to_char(l_P4_e15);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_e16';
	vXMLTable(vCtr).TagValue := to_char(l_P4_e16);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_e17';
	vXMLTable(vCtr).TagValue := to_char(l_P4_e17);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_e18';
	vXMLTable(vCtr).TagValue := to_char(l_P4_e18);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_e19';
	vXMLTable(vCtr).TagValue := to_char(l_P4_e19);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_m1';
	vXMLTable(vCtr).TagValue := to_char(l_P4_m1);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_m2';
	vXMLTable(vCtr).TagValue := to_char(l_P4_m2);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_m3';
	vXMLTable(vCtr).TagValue := to_char(l_P4_m3);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_m4';
	vXMLTable(vCtr).TagValue := to_char(l_P4_m4);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_m5';
	vXMLTable(vCtr).TagValue := to_char(l_P4_m5);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_m6';
	vXMLTable(vCtr).TagValue := to_char(l_P4_m6);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_m7';
	vXMLTable(vCtr).TagValue := to_char(l_P4_m7);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_m8';
	vXMLTable(vCtr).TagValue := to_char(l_P4_m8);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_m9';
	vXMLTable(vCtr).TagValue := to_char(l_P4_m9);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_m10';
	vXMLTable(vCtr).TagValue := to_char(l_P4_m10);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_m11';
	vXMLTable(vCtr).TagValue := to_char(l_P4_m11);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_m14';
	vXMLTable(vCtr).TagValue := to_char(l_P4_m14);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_m15';
	vXMLTable(vCtr).TagValue := to_char(l_P4_m15);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_m16';
	vXMLTable(vCtr).TagValue := to_char(l_P4_m16);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_m17';
	vXMLTable(vCtr).TagValue := to_char(l_P4_m17);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_m18';
	vXMLTable(vCtr).TagValue := to_char(l_P4_m18);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_m19';
	vXMLTable(vCtr).TagValue := to_char(l_P4_m19);
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P4_i1';
	vXMLTable(vCtr).TagValue := to_char(l_P4_i1);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_i2';
	vXMLTable(vCtr).TagValue := to_char(l_P4_i2);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_i3';
	vXMLTable(vCtr).TagValue := to_char(l_P4_i3);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_i4';
	vXMLTable(vCtr).TagValue := to_char(l_P4_i4);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_i5';
	vXMLTable(vCtr).TagValue := to_char(l_P4_i5);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_i6';
	vXMLTable(vCtr).TagValue := to_char(l_P4_i6);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_i7';
	vXMLTable(vCtr).TagValue := to_char(l_P4_i7);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_i8';
	vXMLTable(vCtr).TagValue := to_char(l_P4_i8);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_i9';
	vXMLTable(vCtr).TagValue := to_char(l_P4_i9);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_i10';
	vXMLTable(vCtr).TagValue := to_char(l_P4_i10);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_i11';
	vXMLTable(vCtr).TagValue := to_char(l_P4_i11);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_i14';
	vXMLTable(vCtr).TagValue := to_char(l_P4_i14);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_i15';
	vXMLTable(vCtr).TagValue := to_char(l_P4_i15);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_i16';
	vXMLTable(vCtr).TagValue := to_char(l_P4_i16);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_i17';
	vXMLTable(vCtr).TagValue := to_char(l_P4_i17);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_i18';
	vXMLTable(vCtr).TagValue := to_char(l_P4_i18);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_i19';
	vXMLTable(vCtr).TagValue := to_char(l_P4_i19);
	vCtr := vCtr + 1;

	-- Populating values into the PL/SQL Table
	vXMLTable(vCtr).TagName := 'P4_a17';
	vXMLTable(vCtr).TagValue := to_char(l_P4_a17);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_a18';
	vXMLTable(vCtr).TagValue := to_char(l_P4_a18);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_a19';
	vXMLTable(vCtr).TagValue := to_char(l_P4_a19);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_b17';
	vXMLTable(vCtr).TagValue := to_char(l_P4_b17);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_b18';
	vXMLTable(vCtr).TagValue := to_char(l_P4_b18);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_b19';
	vXMLTable(vCtr).TagValue := to_char(l_P4_b19);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_c17';
	vXMLTable(vCtr).TagValue := to_char(l_P4_c17);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_c18';
	vXMLTable(vCtr).TagValue := to_char(l_P4_c18);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_c19';
	vXMLTable(vCtr).TagValue := to_char(l_P4_c19);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_d17';
	vXMLTable(vCtr).TagValue := to_char(l_P4_d17);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_d18';
	vXMLTable(vCtr).TagValue := to_char(l_P4_d18);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_d19';
	vXMLTable(vCtr).TagValue := to_char(l_P4_d19);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_e1_17';
	vXMLTable(vCtr).TagValue := to_char(l_P4_e1_17);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_e1_18';
	vXMLTable(vCtr).TagValue := to_char(l_P4_e1_18);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_e1_19';
	vXMLTable(vCtr).TagValue := to_char(l_P4_e1_19);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_e2_17';
	vXMLTable(vCtr).TagValue := to_char(l_P4_e2_17);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_e2_18';
	vXMLTable(vCtr).TagValue := to_char(l_P4_e2_18);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_e2_19';
	vXMLTable(vCtr).TagValue := to_char(l_P4_e2_19);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_e3_17';
	vXMLTable(vCtr).TagValue := to_char(l_P4_e3_17);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_e3_18';
	vXMLTable(vCtr).TagValue := to_char(l_P4_e3_18);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_e3_19';
	vXMLTable(vCtr).TagValue := to_char(l_P4_e3_19);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_e4_17';
	vXMLTable(vCtr).TagValue := to_char(l_P4_e4_17);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_e4_18';
	vXMLTable(vCtr).TagValue := to_char(l_P4_e4_18);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_e4_19';
	vXMLTable(vCtr).TagValue := to_char(l_P4_e4_19);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_e5_17';
	vXMLTable(vCtr).TagValue := to_char(l_P4_e5_17);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_e5_18';
	vXMLTable(vCtr).TagValue := to_char(l_P4_e5_18);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_e5_19';
	vXMLTable(vCtr).TagValue := to_char(l_P4_e5_19);
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P4_e5_17';
	vXMLTable(vCtr).TagValue := to_char(l_P4_e5_17);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_e5_18';
	vXMLTable(vCtr).TagValue := to_char(l_P4_e5_18);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_e5_19';
	vXMLTable(vCtr).TagValue := to_char(l_P4_e5_19);
	vCtr := vCtr + 1;

	-- Filling zeros for other fields
	FOR cur_ctr IN 1..19 LOOP
		IF (cur_ctr = 12) OR (cur_ctr = 13) THEN
			NULL;
		ELSE
		   vXMLTable(vCtr).TagName := 'P4_e6_' || cur_ctr;
		   vXMLTable(vCtr).TagValue := '0';
		   vCtr := vCtr + 1;
		END IF;
	END LOOP;

	FOR cur_ctr IN 1..19 LOOP
		IF (cur_ctr = 12) OR (cur_ctr = 13) THEN
			NULL;
		ELSE
		   vXMLTable(vCtr).TagName := 'P4_e7_' || cur_ctr;
		   vXMLTable(vCtr).TagValue := '0';
		   vCtr := vCtr + 1;
		END IF;
	END LOOP;

	vXMLTable(vCtr).TagName := 'P4_f17';
	vXMLTable(vCtr).TagValue := to_char(l_P4_f17);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_f18';
	vXMLTable(vCtr).TagValue := to_char(l_P4_f18);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_f19';
	vXMLTable(vCtr).TagValue := to_char(l_P4_f19);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_g17';
	vXMLTable(vCtr).TagValue := to_char(l_P4_g17);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_g18';
	vXMLTable(vCtr).TagValue := to_char(l_P4_g18);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_g19';
	vXMLTable(vCtr).TagValue := to_char(l_P4_g19);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_h17';
	vXMLTable(vCtr).TagValue := to_char(l_P4_h17);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_h18';
	vXMLTable(vCtr).TagValue := to_char(l_P4_h18);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_h19';
	vXMLTable(vCtr).TagValue := to_char(l_P4_h19);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_i1_17';
	vXMLTable(vCtr).TagValue := to_char(l_P4_i1_17);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_i1_18';
	vXMLTable(vCtr).TagValue := to_char(l_P4_i1_18);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_i1_19';
	vXMLTable(vCtr).TagValue := to_char(l_P4_i1_19);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_i2_17';
	vXMLTable(vCtr).TagValue := to_char(l_P4_i2_17);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_i2_18';
	vXMLTable(vCtr).TagValue := to_char(l_P4_i2_18);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_i2_19';
	vXMLTable(vCtr).TagValue := to_char(l_P4_i2_19);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_j17';
	vXMLTable(vCtr).TagValue := to_char(l_P4_j17);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_j18';
	vXMLTable(vCtr).TagValue := to_char(l_P4_j18);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_j19';
	vXMLTable(vCtr).TagValue := to_char(l_P4_j19);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_k17';
	vXMLTable(vCtr).TagValue := to_char(l_P4_k17);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_k18';
	vXMLTable(vCtr).TagValue := to_char(l_P4_k18);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_k19';
	vXMLTable(vCtr).TagValue := to_char(l_P4_k19);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_l17';
	vXMLTable(vCtr).TagValue := to_char(l_P4_l17);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_l18';
	vXMLTable(vCtr).TagValue := to_char(l_P4_l18);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_l19';
	vXMLTable(vCtr).TagValue := to_char(l_P4_l19);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_m1_17';
	vXMLTable(vCtr).TagValue := to_char(l_P4_m1_17);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_m1_18';
	vXMLTable(vCtr).TagValue := to_char(l_P4_m1_18);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_m1_19';
	vXMLTable(vCtr).TagValue := to_char(l_P4_m1_19);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_m2_17';
	vXMLTable(vCtr).TagValue := to_char(l_P4_m2_17);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_m2_18';
	vXMLTable(vCtr).TagValue := to_char(l_P4_m2_18);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_m2_19';
	vXMLTable(vCtr).TagValue := to_char(l_P4_m2_19);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_n17';
	vXMLTable(vCtr).TagValue := to_char(l_P4_n17);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_n18';
	vXMLTable(vCtr).TagValue := to_char(l_P4_n18);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_n19';
	vXMLTable(vCtr).TagValue := to_char(l_P4_n19);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_o17';
	vXMLTable(vCtr).TagValue := to_char(l_P4_o17);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_o18';
	vXMLTable(vCtr).TagValue := to_char(l_P4_o18);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_o19';
	vXMLTable(vCtr).TagValue := to_char(l_P4_o19);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_p17';
	vXMLTable(vCtr).TagValue := to_char(l_P4_p17);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_p18';
	vXMLTable(vCtr).TagValue := to_char(l_P4_p18);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_p19';
	vXMLTable(vCtr).TagValue := to_char(l_P4_p19);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_q17';
	vXMLTable(vCtr).TagValue := to_char(l_P4_q17);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_q18';
	vXMLTable(vCtr).TagValue := to_char(l_P4_q18);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_q19';
	vXMLTable(vCtr).TagValue := to_char(l_P4_q19);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_r17';
	vXMLTable(vCtr).TagValue := to_char(l_P4_r17);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_r18';
	vXMLTable(vCtr).TagValue := to_char(l_P4_r18);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_r19';
	vXMLTable(vCtr).TagValue := to_char(l_P4_r19);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_s17';
	vXMLTable(vCtr).TagValue := to_char(l_P4_s17);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_s18';
	vXMLTable(vCtr).TagValue := to_char(l_P4_s18);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_s19';
	vXMLTable(vCtr).TagValue := to_char(l_P4_s19);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_t17';
	vXMLTable(vCtr).TagValue := to_char(l_P4_t17);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_t18';
	vXMLTable(vCtr).TagValue := to_char(l_P4_t18);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_t19';
	vXMLTable(vCtr).TagValue := to_char(l_P4_t19);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_u17';
	vXMLTable(vCtr).TagValue := to_char(l_P4_u17);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_u18';
	vXMLTable(vCtr).TagValue := to_char(l_P4_u18);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_u19';
	vXMLTable(vCtr).TagValue := to_char(l_P4_u19);
	vCtr := vCtr + 1;

	-- Filling zeros for other fields
	FOR cur_i IN 1..5 LOOP
	   FOR cur_j IN 1..19 LOOP
			IF (cur_j = 12) OR (cur_j = 13) THEN
				NULL;
			ELSE
				vXMLTable(vCtr).TagName := 'P4_u' ||cur_i || '_' || cur_j;
				vXMLTable(vCtr).TagValue := '0';
				vCtr := vCtr + 1;
			END IF;
	   END LOOP;
	END LOOP;

	fnd_file.put_line(fnd_file.log,'Finished populating Part4 - Total fields by Issues');
--------------
	vXMLTable(vCtr).TagName := 'P4_tot1_1';
	vXMLTable(vCtr).TagValue := to_char(l_tot1_1);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_tot2_1';
	vXMLTable(vCtr).TagValue := to_char(l_tot2_1);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_tot3_1';
	vXMLTable(vCtr).TagValue := to_char(l_tot3_1);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_tot1_2';
	vXMLTable(vCtr).TagValue := to_char(l_tot1_2);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_tot2_2';
	vXMLTable(vCtr).TagValue := to_char(l_tot2_2);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_tot3_2';
	vXMLTable(vCtr).TagValue := to_char(l_tot3_2);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_tot1_3';
	vXMLTable(vCtr).TagValue := to_char(l_tot1_3);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_tot2_3';
	vXMLTable(vCtr).TagValue := to_char(l_tot2_3);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_tot3_3';
	vXMLTable(vCtr).TagValue := to_char(l_tot3_3);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_tot1_4';
	vXMLTable(vCtr).TagValue := to_char(l_tot1_4);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_tot2_4';
	vXMLTable(vCtr).TagValue := to_char(l_tot2_4);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_tot3_4';
	vXMLTable(vCtr).TagValue := to_char(l_tot3_4);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_tot1_5';
	vXMLTable(vCtr).TagValue := to_char(l_tot1_5);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_tot2_5';
	vXMLTable(vCtr).TagValue := to_char(l_tot2_5);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_tot3_5';
	vXMLTable(vCtr).TagValue := to_char(l_tot3_5);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_tot1_6';
	vXMLTable(vCtr).TagValue := to_char(l_tot1_6);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_tot2_6';
	vXMLTable(vCtr).TagValue := to_char(l_tot2_6);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_tot3_6';
	vXMLTable(vCtr).TagValue := to_char(l_tot3_6);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_tot1_7';
	vXMLTable(vCtr).TagValue := to_char(l_tot1_7);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_tot2_7';
	vXMLTable(vCtr).TagValue := to_char(l_tot2_7);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_tot3_7';
	vXMLTable(vCtr).TagValue := to_char(l_tot3_7);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_tot1_8';
	vXMLTable(vCtr).TagValue := to_char(l_tot1_8);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_tot2_8';
	vXMLTable(vCtr).TagValue := to_char(l_tot2_8);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_tot3_8';
	vXMLTable(vCtr).TagValue := to_char(l_tot3_8);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_tot1_9';
	vXMLTable(vCtr).TagValue := to_char(l_tot1_9);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_tot2_9';
	vXMLTable(vCtr).TagValue := to_char(l_tot2_9);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_tot3_9';
	vXMLTable(vCtr).TagValue := to_char(l_tot3_9);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_tot1_10';
	vXMLTable(vCtr).TagValue := to_char(l_tot1_10);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_tot2_10';
	vXMLTable(vCtr).TagValue := to_char(l_tot2_10);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_tot3_10';
	vXMLTable(vCtr).TagValue := to_char(l_tot3_10);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_tot1_11';
	vXMLTable(vCtr).TagValue := to_char(l_tot1_11);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_tot2_11';
	vXMLTable(vCtr).TagValue := to_char(l_tot2_11);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_tot3_11';
	vXMLTable(vCtr).TagValue := to_char(l_tot3_11);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_tot1_12';
	vXMLTable(vCtr).TagValue := to_char(l_tot1_12);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_tot2_12';
	vXMLTable(vCtr).TagValue := to_char(l_tot2_12);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_tot3_12';
	vXMLTable(vCtr).TagValue := to_char(l_tot3_12);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_tot1_13';
	vXMLTable(vCtr).TagValue := to_char(l_tot1_13);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_tot2_13';
	vXMLTable(vCtr).TagValue := to_char(l_tot2_13);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_tot3_13';
	vXMLTable(vCtr).TagValue := to_char(l_tot3_13);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_tot1_14';
	vXMLTable(vCtr).TagValue := to_char(l_tot1_14);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_tot2_14';
	vXMLTable(vCtr).TagValue := to_char(l_tot2_14);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_tot3_14';
	vXMLTable(vCtr).TagValue := to_char(l_tot3_14);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_tot1_15';
	vXMLTable(vCtr).TagValue := to_char(l_tot1_15);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_tot2_15';
	vXMLTable(vCtr).TagValue := to_char(l_tot2_15);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_tot3_15';
	vXMLTable(vCtr).TagValue := to_char(l_tot3_15);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_tot1_16';
	vXMLTable(vCtr).TagValue := to_char(l_tot1_16);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_tot2_16';
	vXMLTable(vCtr).TagValue := to_char(l_tot2_16);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P4_tot3_16';
	vXMLTable(vCtr).TagValue := to_char(l_tot3_16);
	vCtr := vCtr + 1;
	fnd_file.put_line(fnd_file.log,'Finished populating Part4 - Total fields by Bases');
	fnd_file.put_line(fnd_file.log,'------------End of Part4----------------');

END populate_part4;

PROCEDURE populate_part5(
    p_from_date   in date,
	p_to_date     in date,
	p_agency_code in varchar2)
IS
CURSOR cur_p5(c_from_date date, c_to_date date, c_statute ghr_compl_bases.statute%type,c_agency_code ghr_complaints2.agency_code%type) IS
   SELECT COUNT(*) p5_cnt
   FROM GHR_COMPLAINTS2 cmp, GHR_COMPL_CLAIMS claims, GHR_COMPL_BASES bases
   WHERE bases.compl_claim_id = claims.compl_claim_id
   AND claims.complaint_id = cmp.complaint_id
   AND claims.phase IN (20,30)
   AND cmp.complaint_closed BETWEEN c_from_date AND c_to_date
   AND cmp.formal_com_filed IS NOT NULL
   AND cmp.agency_code = c_agency_code
   AND bases.statute = c_statute;

l_P5_a1 NUMBER;
l_P5_a2 NUMBER;
l_P5_a3 NUMBER;
l_P5_a4 NUMBER;
l_P5_b NUMBER;

BEGIN
	-- Title VII
	FOR cur_ctr IN cur_p5(p_from_date,p_to_date,'10', p_agency_code) LOOP
		vXMLTable(vCtr).TagName := 'P5_a1';
		vXMLTable(vCtr).TagValue := to_char(cur_ctr.p5_cnt);
		l_P5_a1 := cur_ctr.p5_cnt;
		vCtr := vCtr + 1;
	END LOOP;
	fnd_file.put_line(fnd_file.log,'Finished populating Part5 - Title VII');
	-- Age Discrimination
	FOR cur_ctr IN cur_p5(p_from_date,p_to_date,'20', p_agency_code) LOOP
		vXMLTable(vCtr).TagName := 'P5_a2';
		vXMLTable(vCtr).TagValue := to_char(cur_ctr.p5_cnt);
		l_P5_a2 := cur_ctr.p5_cnt;
		vCtr := vCtr + 1;
	END LOOP;
	fnd_file.put_line(fnd_file.log,'Finished populating Part5 - Age Discrimination');
	-- Rehabilitation act
	FOR cur_ctr IN cur_p5(p_from_date,p_to_date,'30', p_agency_code) LOOP
		vXMLTable(vCtr).TagName := 'P5_a3';
		vXMLTable(vCtr).TagValue := to_char(cur_ctr.p5_cnt);
		l_P5_a3 := cur_ctr.p5_cnt;
		vCtr := vCtr + 1;
	END LOOP;
	fnd_file.put_line(fnd_file.log,'Finished populating Part5 - Rehabilitation act');
	-- Equal Pay act.
	FOR cur_ctr IN cur_p5(p_from_date,p_to_date,'40', p_agency_code) LOOP
		vXMLTable(vCtr).TagName := 'P5_a4';
		vXMLTable(vCtr).TagValue := to_char(cur_ctr.p5_cnt);
		l_P5_a4 := cur_ctr.p5_cnt;
		vCtr := vCtr + 1;
	END LOOP;
	fnd_file.put_line(fnd_file.log,'Finished populating Part5 - Equal Pay act.');
	-- Total by statutes
	l_P5_b := l_P5_a1 + l_P5_a2 + l_P5_a3 + l_P5_a4;

	vXMLTable(vCtr).TagName := 'P5_b';
	vXMLTable(vCtr).TagValue := to_char(l_P5_b);
	vCtr := vCtr + 1;
	fnd_file.put_line(fnd_file.log,'Finished populating Part5 - Total by statutes');
	fnd_file.put_line(fnd_file.log,'------------End of Part5----------------');
END populate_part5;

PROCEDURE populate_part6(
    p_from_date   in date,
	p_to_date     in date,
	p_agency_code in varchar2)
IS
CURSOR cur_total_nodays(c_from_date date, c_to_date date, c_noc GHR_COMPLAINTS2.nature_of_closure%TYPE,c_agency_code ghr_complaints2.agency_code%type) IS
   SELECT COUNT(*) p6_cnt, NVL(SUM(ROUND((cmp.complaint_closed - cmp.formal_com_filed),0)+1),0) p6_sum
   FROM GHR_COMPLAINTS2 cmp
   WHERE cmp.formal_com_filed IS NOT NULL
   AND cmp.nature_of_closure = c_noc
   AND cmp.agency_code = c_agency_code
   AND cmp.complaint_closed BETWEEN c_from_date AND c_to_date;

CURSOR cur_settlements(c_from_date date, c_to_date date,c_agency_code ghr_complaints2.agency_code%type) IS
   SELECT COUNT(*) p6_cnt, NVL(SUM(ROUND((cmp.complaint_closed - cmp.formal_com_filed),0)+1),0) p6_sum
   FROM GHR_COMPLAINTS2 cmp
   WHERE cmp.formal_com_filed IS NOT NULL
   AND cmp.nature_of_closure IN (110,120,130,140,150,160)
   AND cmp.agency_code = c_agency_code
   AND cmp.complaint_closed BETWEEN c_from_date AND c_to_date;


l_P6_a1_num NUMBER;
l_P6_a1_day NUMBER;
l_P6_a2_num NUMBER;
l_P6_a2_day NUMBER;
l_P6_a3_num NUMBER;
l_P6_a3_day NUMBER;
l_P6_a_num NUMBER;
l_P6_a_day NUMBER;

l_P6_bnum NUMBER;
l_P6_bday NUMBER;
l_P6_b1_num NUMBER;
l_P6_b1_day NUMBER;
l_P6_b2_num NUMBER;
l_P6_b2_day NUMBER;
l_P6_b3_num NUMBER;
l_P6_b3_day NUMBER;

l_P6_cnum NUMBER;
l_P6_cday NUMBER;
l_P6_c1_num NUMBER;
l_P6_c1_day NUMBER;
l_P6_c1a_num NUMBER;
l_P6_c1a_day NUMBER;
l_P6_c1b_num NUMBER;
l_P6_c1b_day NUMBER;
l_P6_c2_num NUMBER;
l_P6_c2_day NUMBER;
l_P6_c2a_num NUMBER;
l_P6_c2a_day NUMBER;
l_P6_c2a_1num NUMBER;
l_P6_c2a_1day NUMBER;
l_P6_c2a_2num NUMBER;
l_P6_c2a_2day NUMBER;
l_P6_c2a_3num NUMBER;
l_P6_c2a_3day NUMBER;
l_P6_c2b_num NUMBER;
l_P6_c2b_day NUMBER;
l_P6_c3_num NUMBER;
l_P6_c3_day NUMBER;

-- Fields for average
l_P6_a1_avg NUMBER;
l_P6_a2_avg NUMBER;
l_P6_b1_avg NUMBER;
l_P6_b2_avg NUMBER;
l_P6_b3_avg NUMBER;
l_P6_c1a_avg NUMBER;
l_P6_c1b_avg NUMBER;
l_P6_c2a_1avg NUMBER;
l_P6_c2a_2avg NUMBER;
l_P6_c2a_3avg NUMBER;
l_P6_c2a_avg NUMBER;
l_P6_c2b_avg NUMBER;
l_P6_c3_avg NUMBER;
l_P6_a3_avg NUMBER;
l_P6_a_avg NUMBER;

BEGIN
	-- Withdrawals
	FOR cur_ctr IN cur_total_nodays(p_from_date,p_to_date,'170', p_agency_code) LOOP
	   l_P6_a1_num := cur_ctr.p6_cnt;
	   l_P6_a1_day := cur_ctr.p6_sum;
	END LOOP;
	vXMLTable(vCtr).TagName := 'P6_a1_num';
	vXMLTable(vCtr).TagValue := to_char(l_P6_a1_num);
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P6_a1_day';
	vXMLTable(vCtr).TagValue := to_char(l_P6_a1_day);
	vCtr := vCtr + 1;
	-- Average Days
/*	IF (l_P6_a1_num > 0) THEN
		l_P6_a1_avg := CEIL(l_P6_a1_day/l_P6_a1_num);
	ELSE
		l_P6_a1_avg := 0;
	END IF;
	vXMLTable(vCtr).TagName := 'P6_a1_avg';
	vXMLTable(vCtr).TagValue := to_char(l_P6_a1_avg);
	vCtr := vCtr + 1;
*/
	fnd_file.put_line(fnd_file.log,'Finished populating Part6 - Total no. of closures - Withdrawals');

	-- Settlements
	FOR cur_ctr IN cur_settlements(p_from_date,p_to_date, p_agency_code) LOOP
	   l_P6_a2_num := cur_ctr.p6_cnt;
	   l_P6_a2_day := cur_ctr.p6_sum;
	END LOOP;

	vXMLTable(vCtr).TagName := 'P6_a2_num';
	vXMLTable(vCtr).TagValue := to_char(l_P6_a2_num);
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P6_a2_day';
	vXMLTable(vCtr).TagValue := to_char(l_P6_a2_day);
	vCtr := vCtr + 1;
	fnd_file.put_line(fnd_file.log,'Finished populating Part6 - Total no. of closures - Settlements');

	-- Average Days
/*	IF (l_P6_a2_num > 0) THEN
		l_P6_a2_avg := CEIL(l_P6_a2_day/l_P6_a2_num);
	ELSE
		l_P6_a2_avg := 0;
	END IF;
	vXMLTable(vCtr).TagName := 'P6_a2_avg';
	vXMLTable(vCtr).TagValue := to_char(l_P6_a2_avg);
	vCtr := vCtr + 1;
*/
	-- Finding Discrimination
	FOR cur_ctr IN cur_total_nodays(p_from_date,p_to_date,'90', p_agency_code) LOOP
	   l_P6_b1_num := cur_ctr.p6_cnt;
	   l_P6_b1_day := cur_ctr.p6_sum;
	END LOOP;
	vXMLTable(vCtr).TagName := 'P6_b1_num';
	vXMLTable(vCtr).TagValue := to_char(l_P6_b1_num);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P6_b1_day';
	vXMLTable(vCtr).TagValue := to_char(l_P6_b1_day);
	vCtr := vCtr + 1;

	-- Average Day
/*	IF (l_P6_b1_num > 0) THEN
		l_P6_b1_avg := CEIL(l_P6_b1_day/l_P6_b1_num);
	ELSE
		l_P6_b1_avg := 0;
	END IF;

	vXMLTable(vCtr).TagName := 'P6_b1_avg';
	vXMLTable(vCtr).TagValue := to_char(l_P6_b1_avg);
	vCtr := vCtr + 1;
*/
	-- Finding No discrimination
	FOR cur_ctr IN cur_total_nodays(p_from_date,p_to_date,'100', p_agency_code) LOOP
	   l_P6_b2_num := cur_ctr.p6_cnt;
	   l_P6_b2_day := cur_ctr.p6_sum;
	END LOOP;
	vXMLTable(vCtr).TagName := 'P6_b2_num';
	vXMLTable(vCtr).TagValue := to_char(l_P6_b2_num);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P6_b2_day';
	vXMLTable(vCtr).TagValue := to_char(l_P6_b2_day);
	vCtr := vCtr + 1;

	-- Average Day
/*	IF (l_P6_b2_num > 0) THEN
		l_P6_b2_avg := CEIL(l_P6_b2_day/l_P6_b2_num);
	ELSE
		l_P6_b2_avg := 0;
	END IF;
	vXMLTable(vCtr).TagName := 'P6_b2_avg';
	vXMLTable(vCtr).TagValue := to_char(l_P6_b2_avg);
	vCtr := vCtr + 1;
*/
	-- Dismissal of complaints
	FOR cur_ctr IN cur_total_nodays(p_from_date,p_to_date,'80', p_agency_code) LOOP
	   l_P6_b3_num := cur_ctr.p6_cnt;
	   l_P6_b3_day := cur_ctr.p6_sum;
	END LOOP;
	vXMLTable(vCtr).TagName := 'P6_b3_num';
	vXMLTable(vCtr).TagValue := to_char(l_P6_b3_num);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P6_b3_day';
	vXMLTable(vCtr).TagValue := to_char(l_P6_b3_day);
	vCtr := vCtr + 1;

	-- Average Days
/*	IF (l_P6_b3_num > 0) THEN
		l_P6_b3_avg := CEIL(l_P6_b3_day/l_P6_b3_num);
	ELSE
		l_P6_b3_avg := 0;
	END IF;
	vXMLTable(vCtr).TagName := 'P6_b3_avg';
	vXMLTable(vCtr).TagValue := to_char(l_P6_b3_avg);
	vCtr := vCtr + 1;
*/

	-- Final Agency Actions without AJ Decisions
	l_P6_bnum := l_P6_b1_num + l_P6_b2_num + l_P6_b3_num;
	l_P6_bday := l_P6_b1_day + l_P6_b2_day + l_P6_b3_day;

	vXMLTable(vCtr).TagName := 'P6_b_num';
	vXMLTable(vCtr).TagValue := to_char(l_P6_bnum);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P6_b_day';
	vXMLTable(vCtr).TagValue := to_char(l_P6_bday);
	vCtr := vCtr + 1;
	fnd_file.put_line(fnd_file.log,'Finished populating Part6 - Final Agency Actions without AJ Decisions');
	-- Final Agency action with AJ Decision ---------

	-- AJ Decision Fully implemented - Finding Discrimination
	FOR cur_ctr IN cur_total_nodays(p_from_date,p_to_date,'20', p_agency_code) LOOP
	   l_P6_c1a_num := cur_ctr.p6_cnt;
	   l_P6_c1a_day := cur_ctr.p6_sum;
	END LOOP;

	vXMLTable(vCtr).TagName := 'P6_c1a_num';
	vXMLTable(vCtr).TagValue := to_char(l_P6_c1a_num);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P6_c1a_day';
	vXMLTable(vCtr).TagValue := to_char(l_P6_c1a_day);
	vCtr := vCtr + 1;

	-- Average Days
/*	IF (l_P6_c1a_num > 0) THEN
		l_P6_c1a_avg := CEIL(l_P6_c1a_day/l_P6_c1a_num);
	ELSE
		l_P6_c1a_avg := 0;
	END IF;
	vXMLTable(vCtr).TagName := 'P6_c1a_avg';
	vXMLTable(vCtr).TagValue := to_char(l_P6_c1a_avg);
	vCtr := vCtr + 1;
*/
	-- AJ Decision Fully implemented - Finding No Discrimination
	FOR cur_ctr IN cur_total_nodays(p_from_date,p_to_date,'30', p_agency_code) LOOP
	   l_P6_c1b_num := cur_ctr.p6_cnt;
	   l_P6_c1b_day := cur_ctr.p6_sum;
	END LOOP;

	vXMLTable(vCtr).TagName := 'P6_c1b_num';
	vXMLTable(vCtr).TagValue := to_char(l_P6_c1b_num);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P6_c1b_day';
	vXMLTable(vCtr).TagValue := to_char(l_P6_c1b_day);
	vCtr := vCtr + 1;

	-- Average Days
/*	IF (l_P6_c1b_num > 0) THEN
		l_P6_c1b_avg := CEIL(l_P6_c1b_day/l_P6_c1b_num);
	ELSE
		l_P6_c1b_avg := 0;
	END IF;
	vXMLTable(vCtr).TagName := 'P6_c1b_avg';
	vXMLTable(vCtr).TagValue := to_char(l_P6_c1b_avg);
	vCtr := vCtr + 1;
*/
	-- AJ Decision Fully implemented
	l_P6_c1_num := l_P6_c1a_num + l_P6_c1b_num;
	l_P6_c1_day := l_P6_c1a_day + l_P6_c1b_day;

	vXMLTable(vCtr).TagName := 'P6_c1_num';
	vXMLTable(vCtr).TagValue := to_char(l_P6_c1_num);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P6_c1_day';
	vXMLTable(vCtr).TagValue := to_char(l_P6_c1_day);
	vCtr := vCtr + 1;
	fnd_file.put_line(fnd_file.log,'Finished populating Part6 - AJ Decision Fully implemented');
	-- Finding Discrimination
	-- a. AGENCY APPEALED FINDING BUT NOT REMEDY
	FOR cur_ctr IN cur_total_nodays(p_from_date,p_to_date,'50', p_agency_code) LOOP
	   l_P6_c2a_1num := cur_ctr.p6_cnt;
	   l_P6_c2a_1day := cur_ctr.p6_sum;
	END LOOP;

	vXMLTable(vCtr).TagName := 'P6_c2a_1num';
	vXMLTable(vCtr).TagValue := to_char(l_P6_c2a_1num);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P6_c2a_1day';
	vXMLTable(vCtr).TagValue := to_char(l_P6_c2a_1day);
	vCtr := vCtr + 1;

	-- Average Days
/*	IF (l_P6_c2a_1num > 0) THEN
		l_P6_c2a_1avg := CEIL(l_P6_c2a_1day/l_P6_c2a_1num);
	ELSE
		l_P6_c2a_1avg := 0;
	END IF;
	vXMLTable(vCtr).TagName := 'P6_c2a_1avg';
	vXMLTable(vCtr).TagValue := to_char(l_P6_c2a_1avg);
	vCtr := vCtr + 1;
*/
	-- b. AGENCY APPEALED REMEDY BUT NOT FINDING
	FOR cur_ctr IN cur_total_nodays(p_from_date,p_to_date,'60', p_agency_code) LOOP
	   l_P6_c2a_2num := cur_ctr.p6_cnt;
	   l_P6_c2a_2day := cur_ctr.p6_sum;
	END LOOP;

	vXMLTable(vCtr).TagName := 'P6_c2a_2num';
	vXMLTable(vCtr).TagValue := to_char(l_P6_c2a_2num);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P6_c2a_2day';
	vXMLTable(vCtr).TagValue := to_char(l_P6_c2a_2day);
	vCtr := vCtr + 1;

	-- Average Days
/*	IF (l_P6_c2a_2num > 0) THEN
		l_P6_c2a_2avg := CEIL(l_P6_c2a_2day/l_P6_c2a_2num);
	ELSE
		l_P6_c2a_2avg := 0;
	END IF;
	vXMLTable(vCtr).TagName := 'P6_c2a_2avg';
	vXMLTable(vCtr).TagValue := to_char(l_P6_c2a_2avg);
	vCtr := vCtr + 1;
*/
	-- c. AGENCY APPEALED BOTH FINDING AND REMEDY
	FOR cur_ctr IN cur_total_nodays(p_from_date,p_to_date,'40', p_agency_code) LOOP
	   l_P6_c2a_3num := cur_ctr.p6_cnt;
	   l_P6_c2a_3day := cur_ctr.p6_sum;
	END LOOP;

	vXMLTable(vCtr).TagName := 'P6_c2a_3num';
	vXMLTable(vCtr).TagValue := to_char(l_P6_c2a_3num);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P6_c2a_3day';
	vXMLTable(vCtr).TagValue := to_char(l_P6_c2a_3day);
	vCtr := vCtr + 1;

	-- Average Days
/*	IF (l_P6_c2a_3num > 0) THEN
		l_P6_c2a_3avg := CEIL(l_P6_c2a_3day/l_P6_c2a_3num);
	ELSE
		l_P6_c2a_3avg := 0;
	END IF;
	vXMLTable(vCtr).TagName := 'P6_c2a_3avg';
	vXMLTable(vCtr).TagValue := to_char(l_P6_c2a_3avg);
	vCtr := vCtr + 1;
*/

	-- Finding Discrimination
	l_P6_c2a_num := l_P6_c2a_1num + l_P6_c2a_2num + l_P6_c2a_3num;
	l_P6_c2a_day := l_P6_c2a_1day + l_P6_c2a_2day + l_P6_c2a_3day;


	vXMLTable(vCtr).TagName := 'P6_c2a_num';
	vXMLTable(vCtr).TagValue := to_char(l_P6_c2a_num);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P6_c2a_day';
	vXMLTable(vCtr).TagValue := to_char(l_P6_c2a_day);
	vCtr := vCtr + 1;

	-- Average Days
/*	IF (l_P6_c2a_num > 0) THEN
		l_P6_c2a_avg := CEIL(l_P6_c2a_day/l_P6_c2a_num);
	ELSE
		l_P6_c2a_avg := 0;
	END IF;
	vXMLTable(vCtr).TagName := 'P6_c2a_avg';
	vXMLTable(vCtr).TagValue := to_char(l_P6_c2a_avg);
	vCtr := vCtr + 1;
*/

	-- AJ DECISION NOT FULLY IMPLEMENTED - FINDING NO DISCRIMINATION
	FOR cur_ctr IN cur_total_nodays(p_from_date,p_to_date,'70', p_agency_code) LOOP
	   l_P6_c2b_num := cur_ctr.p6_cnt;
	   l_P6_c2b_day := cur_ctr.p6_sum;
	END LOOP;

	vXMLTable(vCtr).TagName := 'P6_c2b_num';
	vXMLTable(vCtr).TagValue := to_char(l_P6_c2b_num);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P6_c2b_day';
	vXMLTable(vCtr).TagValue := to_char(l_P6_c2b_day);
	vCtr := vCtr + 1;

	-- Average Days
/*	IF (l_P6_c2b_num > 0) THEN
		l_P6_c2b_avg := CEIL(l_P6_c2b_day/l_P6_c2b_num);
	ELSE
		l_P6_c2b_avg := 0;
	END IF;
	vXMLTable(vCtr).TagName := 'P6_c2b_avg';
	vXMLTable(vCtr).TagValue := to_char(l_P6_c2b_avg);
	vCtr := vCtr + 1;
*/
	fnd_file.put_line(fnd_file.log,'Finished populating Part6 - AJ Decision Not fully implemented');
	-- Finding No Discrimination

	-- AJ Decision Fully Implemented
	l_P6_c2_num := l_P6_c2a_num + l_P6_c2b_num;
	l_P6_c2_day := l_P6_c2a_day + l_P6_c2b_day;

	vXMLTable(vCtr).TagName := 'P6_c2_num';
	vXMLTable(vCtr).TagValue := to_char(l_P6_c2_num);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P6_c2_day';
	vXMLTable(vCtr).TagValue := to_char(l_P6_c2_day);
	vCtr := vCtr + 1;

	-- Dismissal of complaints
	FOR cur_ctr IN cur_total_nodays(p_from_date,p_to_date,'10', p_agency_code) LOOP
	   l_P6_c3_num := cur_ctr.p6_cnt;
	   l_P6_c3_day := cur_ctr.p6_sum;
	END LOOP;

	vXMLTable(vCtr).TagName := 'P6_c3_num';
	vXMLTable(vCtr).TagValue := to_char(l_P6_c3_num);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P6_c3_day';
	vXMLTable(vCtr).TagValue := to_char(l_P6_c3_day);
	vCtr := vCtr + 1;

	-- Average Days
/*	IF (l_P6_c3_num > 0) THEN
		l_P6_c3_avg := CEIL(l_P6_c3_day/l_P6_c3_num);
	ELSE
		l_P6_c3_avg := 0;
	END IF;
	vXMLTable(vCtr).TagName := 'P6_c3_avg';
	vXMLTable(vCtr).TagValue := to_char(l_P6_c3_avg);
	vCtr := vCtr + 1;
*/
	-- FINAL AGENCY ACTIONS WITH AN ADMINISTRATIVE JUDGE (AJ) DECISION
	l_P6_cnum := l_P6_c1_num + l_P6_c2_num + l_P6_c3_num;
	l_P6_cday := l_P6_c1_day + l_P6_c2_day + l_P6_c3_day;

	vXMLTable(vCtr).TagName := 'P6_c_num';
	vXMLTable(vCtr).TagValue := to_char(l_P6_cnum);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P6_c_day';
	vXMLTable(vCtr).TagValue := to_char(l_P6_cday);
	vCtr := vCtr + 1;

	-- Final Agency Actions with AJ Decisions
	l_P6_a3_num := l_P6_bnum + l_P6_cnum;
	l_P6_a3_day := l_P6_bday + l_P6_cday;

	vXMLTable(vCtr).TagName := 'P6_a3_num';
	vXMLTable(vCtr).TagValue := to_char(l_P6_a3_num);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P6_a3_day';
	vXMLTable(vCtr).TagValue := to_char(l_P6_a3_day);
	vCtr := vCtr + 1;

	-- Average Days
/*	IF (l_P6_a3_num > 0) THEN
		l_P6_a3_avg := CEIL(l_P6_a3_day/l_P6_a3_num);
	ELSE
		l_P6_a3_avg := 0;
	END IF;
	vXMLTable(vCtr).TagName := 'P6_a3_avg';
	vXMLTable(vCtr).TagValue := to_char(l_P6_a3_avg);
	vCtr := vCtr + 1;
*/
	fnd_file.put_line(fnd_file.log,'Finished populating Part6 - Final Agency Actions with AJ Decisions');

-- Total No. of Closures
	l_P6_a_num := l_P6_a1_num + l_P6_a2_num + l_P6_a3_num;
	l_P6_a_day := l_P6_a1_day + l_P6_a2_day + l_P6_a3_day;

	vXMLTable(vCtr).TagName := 'P6_a_num';
	vXMLTable(vCtr).TagValue := to_char(l_P6_a_num);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P6_a_day';
	vXMLTable(vCtr).TagValue := to_char(l_P6_a_day);
	vCtr := vCtr + 1;

	-- Average Days
/*	IF (l_P6_a_num > 0) THEN
		l_P6_a_avg := CEIL(l_P6_a_day/l_P6_a_num);
	ELSE
		l_P6_a_avg := 0;
	END IF;
	vXMLTable(vCtr).TagName := 'P6_a_avg';
	vXMLTable(vCtr).TagValue := to_char(l_P6_a_avg);
	vCtr := vCtr + 1;
*/
	fnd_file.put_line(fnd_file.log,'Finished populating Part6 - Total No. of Closures');
	fnd_file.put_line(fnd_file.log,'------------End of Part6----------------');
END populate_part6;

PROCEDURE populate_part7(
    p_from_date   in date,
	p_to_date     in date,
	p_agency_code in varchar2)
IS
-- Cursor for total complaints with corrective actions
CURSOR cur_complaints_ca(c_from_date date, c_to_date date,c_agency_code ghr_complaints2.agency_code%type) IS
   SELECT COUNT(distinct cmp.complaint_id) p7_cnt
   FROM GHR_COMPLAINTS2 cmp, GHR_COMPL_CA_HEADERS cah, GHR_COMPL_CA_DETAILS ca
   WHERE ca.compl_ca_header_id = cah.compl_ca_header_id
   AND cah.complaint_id = cmp.complaint_id
   AND ca.phase = '10'
   AND cmp.formal_com_filed IS NOT NULL
   AND cmp.agency_code = c_agency_code
   AND cmp.complaint_closed BETWEEN c_from_date AND c_to_date;

-- Cursor for total Amount for all the complaints with Corrective actions
CURSOR cur_totamt_ca(c_from_date date, c_to_date date,c_agency_code ghr_complaints2.agency_code%type) IS
SELECT nvl(SUM(CEIL(ca.amount)),0) p7_amount
   FROM GHR_COMPLAINTS2 cmp, GHR_COMPL_CA_HEADERS cah, GHR_COMPL_CA_DETAILS ca
   WHERE ca.compl_ca_header_id = cah.compl_ca_header_id
   AND cah.complaint_id = cmp.complaint_id
   AND ca.phase = '10'
   AND cmp.formal_com_filed IS NOT NULL
   AND cmp.agency_code = c_agency_code
   AND cmp.complaint_closed BETWEEN c_from_date AND c_to_date;

-- Cursor for Closures with monetary benefits
CURSOR cur_complaints_ca_monetary(c_from_date date, c_to_date date,c_payment_type IN GHR_COMPL_CA_DETAILS.payment_type%TYPE,c_agency_code ghr_complaints2.agency_code%type) IS
	SELECT COUNT(distinct cmp.complaint_id) p7_cnt, nvl(SUM(CEIL(ca.amount)),0) p7_amount
	FROM GHR_COMPLAINTS2 cmp, GHR_COMPL_CA_HEADERS cah, GHR_COMPL_CA_DETAILS ca
	WHERE ca.compl_ca_header_id = cah.compl_ca_header_id
	AND cah.complaint_id = cmp.complaint_id
    AND ca.phase = '10'
	AND cmp.complaint_closed BETWEEN c_from_date AND c_to_date
	AND cmp.formal_com_filed IS NOT NULL
	AND cmp.agency_code = c_agency_code
	AND ca.category = '10'
	AND ca.payment_type = c_payment_type;

-- Cursor for Compensatory damages
CURSOR cur_compensatory(c_from_date date, c_to_date date,c_agency_code ghr_complaints2.agency_code%type) IS
	SELECT COUNT(distinct cmp.complaint_id) p7_cnt, nvl(SUM(CEIL(ca.amount)),0) p7_amount
	FROM GHR_COMPLAINTS2 cmp, GHR_COMPL_CA_HEADERS cah, GHR_COMPL_CA_DETAILS ca
	WHERE ca.compl_ca_header_id = cah.compl_ca_header_id
	AND cah.complaint_id = cmp.complaint_id
    AND ca.phase = '10'
	AND cmp.complaint_closed BETWEEN c_from_date AND c_to_date
	AND cmp.formal_com_filed IS NOT NULL
	AND cmp.agency_code = c_agency_code
	AND ca.category = '10'
	AND ca.payment_type IN ('30','40');


-- Cursor for Closures with non-monetary benefits
CURSOR cur_complaints_ca_nm(c_from_date date, c_to_date date,c_agency_code ghr_complaints2.agency_code%type) IS
	SELECT COUNT(distinct cmp.complaint_id) p7_cnt
	FROM GHR_COMPLAINTS2 cmp, GHR_COMPL_CA_HEADERS cah, GHR_COMPL_CA_DETAILS ca
	WHERE ca.compl_ca_header_id = cah.compl_ca_header_id
	AND cah.complaint_id = cmp.complaint_id
	AND ca.phase = '10'
	AND cmp.complaint_closed BETWEEN c_from_date AND c_to_date
	AND cmp.formal_com_filed IS NOT NULL
	AND cmp.agency_code = c_agency_code
	AND ca.category = '20';

-- Cursor for CA types
CURSOR cur_cmp_ca_action(c_from_date date, c_to_date date,c_category IN GHR_COMPL_CA_DETAILS.category%TYPE, c_action_type IN GHR_COMPL_CA_DETAILS.action_type%TYPE,c_agency_code ghr_complaints2.agency_code%type) IS
	SELECT COUNT(*) p7_cnt
	FROM GHR_COMPLAINTS2 cmp, GHR_COMPL_CA_HEADERS cah, GHR_COMPL_CA_DETAILS ca
	WHERE ca.compl_ca_header_id = cah.compl_ca_header_id
	AND cah.complaint_id = cmp.complaint_id
	AND ca.phase = '10'
	AND cmp.complaint_closed BETWEEN c_from_date AND c_to_date
	AND cmp.formal_com_filed IS NOT NULL
	AND cmp.agency_code = c_agency_code
	AND ca.category = c_category
	AND ca.action_type = c_action_type;

	l_P7_a_num NUMBER;
	l_P7_a_amt NUMBER;
	l_P7_b_amt NUMBER;
	l_P7_b_num NUMBER;

	l_P7_b1_num NUMBER;
	l_P7_b1_amt NUMBER;
	l_P7_b2_num NUMBER;
	l_P7_b2_amt NUMBER;
	l_P7_c_num NUMBER;
	l_P7_d_num NUMBER;
	l_P7_d_amt NUMBER;
	l_P7_e_num NUMBER;
	l_P7_e_amt NUMBER;
	l_P7_f1_num NUMBER;
	l_P7_f1_amt NUMBER;
	l_P7_f1a_num NUMBER;
	l_P7_f1a_amt NUMBER;
	l_P7_f1b_num NUMBER;
	l_P7_f1b_amt NUMBER;
	l_P7_f2_num NUMBER;
	l_P7_f2_amt NUMBER;
	l_P7_f2a_amt NUMBER;
	l_P7_f2a_num NUMBER;
	l_P7_f2b_num NUMBER;
	l_P7_f2b_amt NUMBER;
	l_P7_f3_num  NUMBER;
	l_P7_f3_amt  NUMBER;
	l_P7_f3a_num NUMBER;
	l_P7_f3a_amt NUMBER;
	l_P7_f3b_num NUMBER;
	l_P7_f3b_amt NUMBER;
	l_P7_f4_num NUMBER;
	l_P7_f4_amt NUMBER;
	l_P7_f5_num NUMBER;
	l_P7_f5_amt NUMBER;
	l_P7_f6_amt NUMBER;
	l_P7_f6_num NUMBER;
	l_P7_f7_num NUMBER;
	l_P7_f7_amt NUMBER;
	l_P7_f8_amt NUMBER;
	l_P7_f8_num NUMBER;
	l_P7_f9_num NUMBER;
	l_P7_f9_amt NUMBER;
	l_P7_f10_num NUMBER;
	l_P7_f10_amt NUMBER;
	l_P7_f11_num NUMBER;
	l_P7_f11_amt NUMBER;
BEGIN
	-- Total complaints closed with corrective actions.
	FOR cur_ctr IN cur_complaints_ca(p_from_date,p_to_date, p_agency_code) LOOP
	   l_P7_a_num := cur_ctr.p7_cnt;
	END LOOP;
	vXMLTable(vCtr).TagName := 'P7_a_num';
	vXMLTable(vCtr).TagValue := to_char(l_P7_a_num);
	vCtr := vCtr + 1;

	-- Total complaints closed with corrective actions.
	FOR cur_ctr IN cur_totamt_ca(p_from_date,p_to_date, p_agency_code) LOOP
	   l_P7_a_amt := cur_ctr.p7_amount;
	END LOOP;
	vXMLTable(vCtr).TagName := 'P7_a_amt';
	vXMLTable(vCtr).TagValue := to_char(l_P7_a_amt);
	vCtr := vCtr + 1;
	fnd_file.put_line(fnd_file.log,'Finished populating Part7 - Total Complaints closed with corrective actions');
	-- Closures with monetary benefits

	-- Back pay/Front Pay
	FOR cur_ctr IN cur_complaints_ca_monetary(p_from_date,p_to_date,'20', p_agency_code) LOOP
		l_P7_b1_num := cur_ctr.p7_cnt;
		l_P7_b1_amt := cur_ctr.p7_amount;
	END LOOP;

	vXMLTable(vCtr).TagName := 'P7_b1_num';
	vXMLTable(vCtr).TagValue := to_char(l_P7_b1_num);
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P7_b1_amt';
	vXMLTable(vCtr).TagValue := to_char(l_P7_b1_amt);
	vCtr := vCtr + 1;

	-- Lumpsum Payment
	FOR cur_ctr IN cur_complaints_ca_monetary(p_from_date,p_to_date,'50', p_agency_code) LOOP
		l_P7_b2_num := cur_ctr.p7_cnt;
		l_P7_b2_amt := cur_ctr.p7_amount;
	END LOOP;

	vXMLTable(vCtr).TagName := 'P7_b2_num';
	vXMLTable(vCtr).TagValue := to_char(l_P7_b2_num);
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P7_b2_amt';
	vXMLTable(vCtr).TagValue := to_char(l_P7_b2_amt);
	vCtr := vCtr + 1;

	l_P7_b_num := l_P7_b1_num + l_P7_b2_num;
	l_P7_b_amt := l_P7_b1_amt + l_P7_b2_amt;

	vXMLTable(vCtr).TagName := 'P7_b_num';
	vXMLTable(vCtr).TagValue := to_char(l_P7_b_num);
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P7_b_amt';
	vXMLTable(vCtr).TagValue := to_char(l_P7_b_amt);
	vCtr := vCtr + 1;

	fnd_file.put_line(fnd_file.log,'Finished populating Part7-  Complaints closed with monetary benefits');
	-- Closures with non-monetary benefits
	FOR cur_ctr IN cur_complaints_ca_nm(p_from_date,p_to_date, p_agency_code) LOOP
		l_P7_c_num := cur_ctr.p7_cnt;
	END LOOP;

	vXMLTable(vCtr).TagName := 'P7_c_num';
	vXMLTable(vCtr).TagValue := to_char(l_P7_c_num);
	vCtr := vCtr + 1;
	fnd_file.put_line(fnd_file.log,'Finished populating Part7 - Complaints closed with non-monetary benefits');
	-- Closures with compensatory damages
	FOR cur_ctr IN cur_compensatory(p_from_date,p_to_date, p_agency_code) LOOP
		l_P7_d_num := cur_ctr.p7_cnt;
		l_P7_d_amt := cur_ctr.p7_amount;
	END LOOP;

	vXMLTable(vCtr).TagName := 'P7_d_num';
	vXMLTable(vCtr).TagValue := to_char(l_P7_d_num);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P7_d_amt';
	vXMLTable(vCtr).TagValue := to_char(l_P7_d_amt);
	vCtr := vCtr + 1;
	fnd_file.put_line(fnd_file.log,'Finished populating Part7 - Complaints closed with compensatory damages');
	-- Closures with Attorney fees and costs
	FOR cur_ctr IN cur_complaints_ca_monetary(p_from_date,p_to_date,'10', p_agency_code) LOOP
		l_P7_e_num := cur_ctr.p7_cnt;
		l_P7_e_amt := cur_ctr.p7_amount;
	END LOOP;

	vXMLTable(vCtr).TagName := 'P7_e_num';
	vXMLTable(vCtr).TagValue := to_char(l_P7_e_num);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P7_e_amt';
	vXMLTable(vCtr).TagValue := to_char(l_P7_e_amt);
	vCtr := vCtr + 1;
	fnd_file.put_line(fnd_file.log,'Finished populating Part7 - Complaints closed with Attorney fees and costs');
	-- Types of Corrective action
	-- Hire Retroactive Monetary
	FOR cur_ctr IN cur_cmp_ca_action(p_from_date,p_to_date,'10','80', p_agency_code) LOOP
		l_P7_f1a_num := cur_ctr.p7_cnt;
	END LOOP;

	vXMLTable(vCtr).TagName := 'P7_f1a_num';
	vXMLTable(vCtr).TagValue := to_char(l_P7_f1a_num);
	vCtr := vCtr + 1;

	-- Hire Retroactive Non-Monetary
	FOR cur_ctr IN cur_cmp_ca_action(p_from_date,p_to_date,'20','80', p_agency_code) LOOP
		l_P7_f1a_amt := cur_ctr.p7_cnt;
	END LOOP;

	vXMLTable(vCtr).TagName := 'P7_f1a_amt';
	vXMLTable(vCtr).TagValue := to_char(l_P7_f1a_amt);
	vCtr := vCtr + 1;

	-- Hire Non-Retroactive Monetary
	FOR cur_ctr IN cur_cmp_ca_action(p_from_date,p_to_date,'10','70', p_agency_code) LOOP
		l_P7_f1b_num := cur_ctr.p7_cnt;
	END LOOP;

	vXMLTable(vCtr).TagName := 'P7_f1b_num';
	vXMLTable(vCtr).TagValue := to_char(l_P7_f1b_num);
	vCtr := vCtr + 1;

	-- Hire Non-Retroactive Non-Monetary
	FOR cur_ctr IN cur_cmp_ca_action(p_from_date,p_to_date,'20','70', p_agency_code) LOOP
		l_P7_f1b_amt := cur_ctr.p7_cnt;
	END LOOP;

	vXMLTable(vCtr).TagName := 'P7_f1b_amt';
	vXMLTable(vCtr).TagValue := to_char(l_P7_f1b_amt);
	vCtr := vCtr + 1;

	-- Total under Hire
	l_P7_f1_num := l_P7_f1a_num + l_P7_f1b_num;
	l_P7_f1_amt := l_P7_f1a_amt + l_P7_f1b_amt;

	vXMLTable(vCtr).TagName := 'P7_f1_num';
	vXMLTable(vCtr).TagValue := to_char(l_P7_f1_num);
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P7_f1_amt';
	vXMLTable(vCtr).TagValue := to_char(l_P7_f1_amt);
	vCtr := vCtr + 1;

	-- Promotion Retroactive Monetary
	FOR cur_ctr IN cur_cmp_ca_action(p_from_date,p_to_date,'10','140', p_agency_code) LOOP
		l_P7_f2a_num := cur_ctr.p7_cnt;
	END LOOP;

	vXMLTable(vCtr).TagName := 'P7_f2a_num';
	vXMLTable(vCtr).TagValue := to_char(l_P7_f2a_num);
	vCtr := vCtr + 1;

	-- Promotion Retroactive Non-Monetary
	FOR cur_ctr IN cur_cmp_ca_action(p_from_date,p_to_date,'20','140', p_agency_code) LOOP
		l_P7_f2a_amt := cur_ctr.p7_cnt;
	END LOOP;

	vXMLTable(vCtr).TagName := 'P7_f2a_amt';
	vXMLTable(vCtr).TagValue := to_char(l_P7_f2a_amt);
	vCtr := vCtr + 1;

	-- Promotion Non-Retroactive Monetary
	FOR cur_ctr IN cur_cmp_ca_action(p_from_date,p_to_date,'10','130', p_agency_code) LOOP
		l_P7_f2b_num := cur_ctr.p7_cnt;
	END LOOP;

	vXMLTable(vCtr).TagName := 'P7_f2b_num';
	vXMLTable(vCtr).TagValue := to_char(l_P7_f2b_num);
	vCtr := vCtr + 1;

	-- Promotion Non-Retroactive Non-Monetary
	FOR cur_ctr IN cur_cmp_ca_action(p_from_date,p_to_date,'20','130', p_agency_code) LOOP
		l_P7_f2b_amt := cur_ctr.p7_cnt;
	END LOOP;

	vXMLTable(vCtr).TagName := 'P7_f2b_amt';
	vXMLTable(vCtr).TagValue := to_char(l_P7_f2b_amt);
	vCtr := vCtr + 1;

	-- Total under Promotion
	l_P7_f2_num := l_P7_f2a_num + l_P7_f2b_num;
	l_P7_f2_amt := l_P7_f2a_amt + l_P7_f2b_amt;

	vXMLTable(vCtr).TagName := 'P7_f2_num';
	vXMLTable(vCtr).TagValue := to_char(l_P7_f2_num);
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P7_f2_amt';
	vXMLTable(vCtr).TagValue := to_char(l_P7_f2_amt);
	vCtr := vCtr + 1;

	-- Disciplinary Action Rescinded Monetary
	FOR cur_ctr IN cur_cmp_ca_action(p_from_date,p_to_date,'10','50', p_agency_code) LOOP
		l_P7_f3a_num := cur_ctr.p7_cnt;
	END LOOP;

	vXMLTable(vCtr).TagName := 'P7_f3a_num';
	vXMLTable(vCtr).TagValue := to_char(l_P7_f3a_num);
	vCtr := vCtr + 1;

	-- Disciplinary Action Rescinded Monetary
	FOR cur_ctr IN cur_cmp_ca_action(p_from_date,p_to_date,'20','50', p_agency_code) LOOP
		l_P7_f3a_amt := cur_ctr.p7_cnt;
	END LOOP;

	vXMLTable(vCtr).TagName := 'P7_f3a_amt';
	vXMLTable(vCtr).TagValue := to_char(l_P7_f3a_amt);
	vCtr := vCtr + 1;

	-- Disciplinary Action Modified Monetary
	FOR cur_ctr IN cur_cmp_ca_action(p_from_date,p_to_date,'10','40', p_agency_code) LOOP
		l_P7_f3b_num := cur_ctr.p7_cnt;
	END LOOP;

	vXMLTable(vCtr).TagName := 'P7_f3b_num';
	vXMLTable(vCtr).TagValue := to_char(l_P7_f3b_num);
	vCtr := vCtr + 1;

	-- Disciplinary Action Modified Non-Monetary
	FOR cur_ctr IN cur_cmp_ca_action(p_from_date,p_to_date,'20','40', p_agency_code) LOOP
		l_P7_f3b_amt := cur_ctr.p7_cnt;
	END LOOP;

	vXMLTable(vCtr).TagName := 'P7_f3b_amt';
	vXMLTable(vCtr).TagValue := to_char(l_P7_f3b_amt);
	vCtr := vCtr + 1;

	-- Total under Disciplinary Action
	l_P7_f3_num := l_P7_f3a_num + l_P7_f3b_num;
	l_P7_f3_amt := l_P7_f3a_amt + l_P7_f3b_amt;

	vXMLTable(vCtr).TagName := 'P7_f3_num';
	vXMLTable(vCtr).TagValue := to_char(l_P7_f3_num);
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P7_f3_amt';
	vXMLTable(vCtr).TagValue := to_char(l_P7_f3_amt);
	vCtr := vCtr + 1;

	-- Reinstatement Monetary
	FOR cur_ctr IN cur_cmp_ca_action(p_from_date,p_to_date,'10','160', p_agency_code) LOOP
		l_P7_f4_num := cur_ctr.p7_cnt;
	END LOOP;

	vXMLTable(vCtr).TagName := 'P7_f4_num';
	vXMLTable(vCtr).TagValue := to_char(l_P7_f4_num);
	vCtr := vCtr + 1;

	-- Reinstatement Non-Monetary
	FOR cur_ctr IN cur_cmp_ca_action(p_from_date,p_to_date,'20','160', p_agency_code) LOOP
		l_P7_f4_amt := cur_ctr.p7_cnt;
	END LOOP;

	vXMLTable(vCtr).TagName := 'P7_f4_amt';
	vXMLTable(vCtr).TagValue := to_char(l_P7_f4_amt);
	vCtr := vCtr + 1;

	-- Reassignment Monetary
	FOR cur_ctr IN cur_cmp_ca_action(p_from_date,p_to_date,'10','150', p_agency_code) LOOP
		l_P7_f5_num := cur_ctr.p7_cnt;
	END LOOP;

	vXMLTable(vCtr).TagName := 'P7_f5_num';
	vXMLTable(vCtr).TagValue := to_char(l_P7_f5_num);
	vCtr := vCtr + 1;

	-- Reassignment Non-Monetary
	FOR cur_ctr IN cur_cmp_ca_action(p_from_date,p_to_date,'20','150', p_agency_code) LOOP
		l_P7_f5_amt := cur_ctr.p7_cnt;
	END LOOP;

	vXMLTable(vCtr).TagName := 'P7_f5_amt';
	vXMLTable(vCtr).TagValue := to_char(l_P7_f5_amt);
	vCtr := vCtr + 1;

	-- Performance Evaluation Monetary
	FOR cur_ctr IN cur_cmp_ca_action(p_from_date,p_to_date,'10','110', p_agency_code) LOOP
		l_P7_f6_num := cur_ctr.p7_cnt;
	END LOOP;

	vXMLTable(vCtr).TagName := 'P7_f6_num';
	vXMLTable(vCtr).TagValue := to_char(l_P7_f6_num);
	vCtr := vCtr + 1;

	-- Performance Evaluation Non-Monetary
	FOR cur_ctr IN cur_cmp_ca_action(p_from_date,p_to_date,'20','110', p_agency_code) LOOP
		l_P7_f6_amt := cur_ctr.p7_cnt;
	END LOOP;

	vXMLTable(vCtr).TagName := 'P7_f6_amt';
	vXMLTable(vCtr).TagValue := to_char(l_P7_f6_amt);
	vCtr := vCtr + 1;

	-- Personnel File Purged Of Adverse Material Monetary
	FOR cur_ctr IN cur_cmp_ca_action(p_from_date,p_to_date,'10','120', p_agency_code) LOOP
		l_P7_f7_num := cur_ctr.p7_cnt;
	END LOOP;

	vXMLTable(vCtr).TagName := 'P7_f7_num';
	vXMLTable(vCtr).TagValue := to_char(l_P7_f7_num);
	vCtr := vCtr + 1;

	-- Personnel File Purged Of Adverse Material Non-Monetary
	FOR cur_ctr IN cur_cmp_ca_action(p_from_date,p_to_date,'20','120', p_agency_code) LOOP
		l_P7_f7_amt := cur_ctr.p7_cnt;
	END LOOP;

	vXMLTable(vCtr).TagName := 'P7_f7_amt';
	vXMLTable(vCtr).TagValue := to_char(l_P7_f7_amt);
	vCtr := vCtr + 1;


	-- Accomodation Monetary
	FOR cur_ctr IN cur_cmp_ca_action(p_from_date,p_to_date,'10','10', p_agency_code) LOOP
		l_P7_f8_num := cur_ctr.p7_cnt;
	END LOOP;

	vXMLTable(vCtr).TagName := 'P7_f8_num';
	vXMLTable(vCtr).TagValue := to_char(l_P7_f8_num);
	vCtr := vCtr + 1;

	-- Accomodation Non-Monetary
	FOR cur_ctr IN cur_cmp_ca_action(p_from_date,p_to_date,'20','10', p_agency_code) LOOP
		l_P7_f8_amt := cur_ctr.p7_cnt;
	END LOOP;

	vXMLTable(vCtr).TagName := 'P7_f8_amt';
	vXMLTable(vCtr).TagValue := to_char(l_P7_f8_amt);
	vCtr := vCtr + 1;

	-- Training/Tuition/Etc. Monetary
	FOR cur_ctr IN cur_cmp_ca_action(p_from_date,p_to_date,'10','180', p_agency_code) LOOP
		l_P7_f9_num := cur_ctr.p7_cnt;
	END LOOP;

	vXMLTable(vCtr).TagName := 'P7_f9_num';
	vXMLTable(vCtr).TagValue := to_char(l_P7_f9_num);
	vCtr := vCtr + 1;

	-- Training/Tuition/Etc. Non-Monetary
	FOR cur_ctr IN cur_cmp_ca_action(p_from_date,p_to_date,'20','180', p_agency_code) LOOP
		l_P7_f9_amt := cur_ctr.p7_cnt;
	END LOOP;

	vXMLTable(vCtr).TagName := 'P7_f9_amt';
	vXMLTable(vCtr).TagValue := to_char(l_P7_f9_amt);
	vCtr := vCtr + 1;

	-- Leave Restored Monetary
	FOR cur_ctr IN cur_cmp_ca_action(p_from_date,p_to_date,'10','90', p_agency_code) LOOP
		l_P7_f10_num := cur_ctr.p7_cnt;
	END LOOP;

	vXMLTable(vCtr).TagName := 'P7_f10_num';
	vXMLTable(vCtr).TagValue := to_char(l_P7_f10_num);
	vCtr := vCtr + 1;

	-- Leave Restored Non-Monetary
	FOR cur_ctr IN cur_cmp_ca_action(p_from_date,p_to_date,'20','90', p_agency_code) LOOP
		l_P7_f10_amt := cur_ctr.p7_cnt;
	END LOOP;

	vXMLTable(vCtr).TagName := 'P7_f10_amt';
	vXMLTable(vCtr).TagValue := to_char(l_P7_f10_amt);
	vCtr := vCtr + 1;

	-- Other
	FOR cur_ctr IN cur_cmp_ca_action(p_from_date,p_to_date,'10','100', p_agency_code) LOOP
		l_P7_f11_num := cur_ctr.p7_cnt;
	END LOOP;

	vXMLTable(vCtr).TagName := 'P7_f11_num';
	vXMLTable(vCtr).TagValue := to_char(l_P7_f11_num);
	vCtr := vCtr + 1;

	-- Other
	FOR cur_ctr IN cur_cmp_ca_action(p_from_date,p_to_date,'20','100', p_agency_code) LOOP
		l_P7_f11_amt := cur_ctr.p7_cnt;
	END LOOP;

	vXMLTable(vCtr).TagName := 'P7_f11_amt';
	vXMLTable(vCtr).TagValue := to_char(l_P7_f11_amt);
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P7_f12_num';
	vXMLTable(vCtr).TagValue := '0';
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P7_f12_amt';
	vXMLTable(vCtr).TagValue := '0';
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P7_f13_num';
	vXMLTable(vCtr).TagValue := '0';
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P7_f13_amt';
	vXMLTable(vCtr).TagValue := '0';
	vCtr := vCtr + 1;

	fnd_file.put_line(fnd_file.log,'Finished populating Part7 - Complaints closed with corrective actions');
	fnd_file.put_line(fnd_file.log,'------------End of Part7----------------');
END populate_part7;

PROCEDURE populate_part8(
    p_from_date   in date,
	p_to_date     in date,
	p_agency_code in varchar2)
IS
-- Complaints Pending written notification

CURSOR cur_notif(c_from_date date, c_to_date date,c_agency_code ghr_complaints2.agency_code%type) IS
SELECT COUNT(*) p8_cnt, NVL(SUM(ROUND((c_to_date - cmp.formal_com_filed),0)+1),0) p8_sum, NVL(MAX(ROUND((c_to_date - cmp.formal_com_filed),0)+1),0) p8_max
   FROM GHR_COMPLAINTS2 cmp
   WHERE (cmp.complaint_closed IS NULL OR cmp.complaint_closed > c_to_date)
   AND cmp.formal_com_filed <= c_to_date
   AND cmp.agency_code = c_agency_code
   AND cmp.letter_type IS NULL
   AND cmp.letter_date IS NULL;

CURSOR cur_investigation(c_from_date date, c_to_date date,c_agency_code ghr_complaints2.agency_code%type) IS
   SELECT COUNT(*) p8_cnt, NVL(SUM(ROUND((c_to_date - NVL(cmp.investigation_start,cmp.investigator_recvd_req)),0)+1),0) p8_sum, NVL(MAX(ROUND((c_to_date - NVL(cmp.investigation_start,cmp.investigator_recvd_req)),0)+1),0) p8_max
   FROM GHR_COMPLAINTS2 cmp
   WHERE (cmp.complaint_closed IS NULL OR cmp.complaint_closed > c_to_date)
   AND cmp.formal_com_filed IS NOT NULL
   AND cmp.agency_code = c_agency_code
   AND (
   (cmp.investigation_start < c_to_date) OR (cmp.investigator_recvd_req < c_to_date))
   AND investigation_end IS NULL;

CURSOR cur_hearing(c_from_date date, c_to_date date,c_agency_code ghr_complaints2.agency_code%type) IS
   SELECT COUNT(*) p8_cnt, NVL(SUM(ROUND((c_to_date - cmp.hearing_req),0)+1),0) p8_sum, NVL(MAX(ROUND((c_to_date - cmp.hearing_req),0)+1),0) p8_max
   FROM GHR_COMPLAINTS2 cmp
   WHERE cmp.formal_com_filed IS NOT NULL
   AND (cmp.complaint_closed IS NULL OR cmp.complaint_closed > c_to_date)
   AND cmp.hearing_req < c_to_date
   AND cmp.agency_code = c_agency_code
   AND (cmp.aj_merit_decision_date IS NULL OR cmp.aj_merit_decision_date > c_to_date)
   AND cmp.aj_ca_decision_date IS NULL;

CURSOR cur_agency(c_from_date date, c_to_date date,c_agency_code ghr_complaints2.agency_code%type) IS
   SELECT COUNT(*) p8_cnt, NVL(SUM(ROUND((c_to_date - NVL(cmp.fad_requested,cmp.fad_due)),0)+1),0) p8_sum, NVL(MAX(ROUND((c_to_date - NVL(cmp.fad_requested,cmp.fad_due)),0)+1),0) p8_max
   FROM GHR_COMPLAINTS2 cmp
   WHERE cmp.formal_com_filed IS NOT NULL
   AND (cmp.complaint_closed IS NULL OR cmp.complaint_closed > c_to_date)
   AND cmp.agency_code = c_agency_code
   AND NVL(cmp.fad_requested,cmp.fad_due) < c_to_date
   AND cmp.fad_date IS NULL;

	l_p8_a1_num NUMBER;
	l_p8_a1_day NUMBER;
	l_p8_a1_old NUMBER;
	l_P8_a1_avg NUMBER;
	l_p8_a2_num NUMBER;
	l_p8_a2_day NUMBER;
	l_p8_a2_old NUMBER;
	l_P8_a2_avg NUMBER;
	l_p8_a3_num NUMBER;
	l_p8_a3_day NUMBER;
	l_p8_a3_old NUMBER;
	l_P8_a3_avg NUMBER;
	l_p8_a4_num NUMBER;
	l_p8_a4_day NUMBER;
	l_p8_a4_old NUMBER;
	l_P8_a4_avg NUMBER;
	l_p8_a_num NUMBER;
	l_p8_a_day NUMBER;


BEGIN
	-- Complaints pending written notification
	FOR cur_ctr IN cur_notif(p_from_date, p_to_date, p_agency_code) LOOP
		l_p8_a1_num := cur_ctr.p8_cnt;
		l_p8_a1_day := cur_ctr.p8_sum;
		l_p8_a1_old := cur_ctr.p8_max;
	END LOOP;

	-- Average Days
/*	IF (l_p8_a1_num > 0) THEN
		l_P8_a1_avg := CEIL(l_p8_a1_day/l_p8_a1_num);
	ELSE
		l_P8_a1_avg := 0;
	END IF;
	vXMLTable(vCtr).TagName := 'P8_a1_avg';
	vXMLTable(vCtr).TagValue := to_char(l_P8_a1_avg);
	vCtr := vCtr + 1;
*/
	vXMLTable(vCtr).TagName := 'P8_a1_num';
	vXMLTable(vCtr).TagValue := to_char(l_p8_a1_num);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P8_a1_day';
	vXMLTable(vCtr).TagValue := to_char(l_p8_a1_day);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P8_a1_old';
	vXMLTable(vCtr).TagValue := to_char(l_p8_a1_old);
	vCtr := vCtr + 1;
	fnd_file.put_line(fnd_file.log,'Finished populating Part8 - Complaints pending written notification');
	-- Complaints Pending in investigation
	FOR cur_ctr IN cur_investigation(p_from_date, p_to_date, p_agency_code) LOOP
		l_p8_a2_num := cur_ctr.p8_cnt;
		l_p8_a2_day := cur_ctr.p8_sum;
		l_p8_a2_old := cur_ctr.p8_max;
	END LOOP;

	-- Average Days
/*	IF (l_p8_a2_num > 0) THEN
		l_P8_a2_avg := CEIL(l_p8_a2_day/l_p8_a2_num);
	ELSE
		l_P8_a2_avg := 0;
	END IF;
	vXMLTable(vCtr).TagName := 'P8_a2_avg';
	vXMLTable(vCtr).TagValue := to_char(l_P8_a2_avg);
	vCtr := vCtr + 1;
*/
	vXMLTable(vCtr).TagName := 'P8_a2_num';
	vXMLTable(vCtr).TagValue := to_char(l_p8_a2_num);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P8_a2_day';
	vXMLTable(vCtr).TagValue := to_char(l_p8_a2_day);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P8_a2_old';
	vXMLTable(vCtr).TagValue := to_char(l_p8_a2_old);
	vCtr := vCtr + 1;
	fnd_file.put_line(fnd_file.log,'Finished populating Part8 - Complaints Pending in investigation');
	-- Complaints Pending in hearing
	FOR cur_ctr IN cur_hearing(p_from_date, p_to_date, p_agency_code) LOOP
		l_p8_a3_num := cur_ctr.p8_cnt;
		l_p8_a3_day := cur_ctr.p8_sum;
		l_p8_a3_old := cur_ctr.p8_max;
	END LOOP;

	-- Average Days
/*	IF (l_p8_a3_num > 0) THEN
		l_P8_a3_avg := CEIL(l_p8_a3_day/l_p8_a3_num);
	ELSE
		l_P8_a3_avg := 0;
	END IF;
	vXMLTable(vCtr).TagName := 'P8_a3_avg';
	vXMLTable(vCtr).TagValue := to_char(l_P8_a3_avg);
	vCtr := vCtr + 1;
*/
	vXMLTable(vCtr).TagName := 'P8_a3_num';
	vXMLTable(vCtr).TagValue := to_char(l_p8_a3_num);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P8_a3_day';
	vXMLTable(vCtr).TagValue := to_char(l_p8_a3_day);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P8_a3_old';
	vXMLTable(vCtr).TagValue := to_char(l_p8_a3_old);
	vCtr := vCtr + 1;
	fnd_file.put_line(fnd_file.log,'Finished populating Part8 - Complaints Pending in hearing');
	-- Complaints Pending FAD
	FOR cur_ctr IN cur_agency(p_from_date, p_to_date, p_agency_code) LOOP
		l_p8_a4_num := cur_ctr.p8_cnt;
		l_p8_a4_day := cur_ctr.p8_sum;
		l_p8_a4_old := cur_ctr.p8_max;
	END LOOP;

	-- Average Days
/*	IF (l_p8_a4_num > 0) THEN
		l_P8_a4_avg := CEIL(l_p8_a4_day/l_p8_a4_num);
	ELSE
		l_P8_a4_avg := 0;
	END IF;
	vXMLTable(vCtr).TagName := 'P8_a4_avg';
	vXMLTable(vCtr).TagValue := to_char(l_P8_a4_avg);
	vCtr := vCtr + 1;
*/
	vXMLTable(vCtr).TagName := 'P8_a4_num';
	vXMLTable(vCtr).TagValue := to_char(l_p8_a4_num);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P8_a4_day';
	vXMLTable(vCtr).TagValue := to_char(l_p8_a4_day);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P8_a4_old';
	vXMLTable(vCtr).TagValue := to_char(l_p8_a4_old);
	vCtr := vCtr + 1;


	fnd_file.put_line(fnd_file.log,'Finished populating Part8 - Complaints Pending FAD');
	l_p8_a_num := l_p8_a1_num + l_p8_a2_num + l_p8_a3_num + l_p8_a4_num;
	l_p8_a_day := l_p8_a1_day + l_p8_a2_day + l_p8_a3_day + l_p8_a4_day;

	vXMLTable(vCtr).TagName := 'P8_a_num';
	vXMLTable(vCtr).TagValue := to_char(l_p8_a_num);
	vCtr := vCtr + 1;
	vXMLTable(vCtr).TagName := 'P8_a_day';
	vXMLTable(vCtr).TagValue := to_char(l_p8_a_day);
	vCtr := vCtr + 1;
	fnd_file.put_line(fnd_file.log,'Finished populating Part8 - Totals');
	fnd_file.put_line(fnd_file.log,'------------End of Part8----------------');
END populate_part8;

PROCEDURE populate_part10(
   p_from_date   in date,
   p_to_date     in date,
   p_agency_code in varchar2) IS

-- Cursor for ADR Pending from previous reporting period
CURSOR cur_adr_pending(c_from_date date, c_to_date date,c_stage ghr_compl_adrs.stage%TYPE,c_agency_code ghr_complaints2.agency_code%type) IS
   SELECT COUNT(distinct cmp.complaint_id) p10_cnt, COUNT(distinct nvl(cmp.complainant_person_id,0)) p10_prsn,    NVL(SUM(ROUND((c_to_date - NVL(adrs.date_accepted,adrs.start_date)) ,0) + 1),0) p10_days
   FROM GHR_COMPLAINTS2 cmp, GHR_COMPL_ADRS adrs
   WHERE adrs.complaint_id = cmp.complaint_id
   AND adrs.stage = c_stage
   AND cmp.agency_code = c_agency_code
   AND (cmp.formal_com_filed IS NULL OR cmp.formal_com_filed > c_to_date)
   AND (cmp.complaint_closed IS NULL OR cmp.complaint_closed > c_to_date)
   AND NVL(adrs.date_accepted,adrs.start_date) < c_from_date
   AND (adrs.end_date IS NULL OR adrs.end_date > c_to_date);

-- Cursor for Individuals counseled through ADR
CURSOR cur_adr(c_from_date date, c_to_date date,c_stage ghr_compl_adrs.stage%TYPE,c_agency_code ghr_complaints2.agency_code%type) IS
   SELECT COUNT(distinct cmp.complaint_id) p10_cnt, COUNT(distinct nvl(cmp.complainant_person_id,0)) p10_prsn,   NVL(SUM(ROUND((c_to_date - NVL(adrs.date_accepted,adrs.start_date)) ,0) + 1),0) p10_days
   FROM GHR_COMPLAINTS2 cmp, GHR_COMPL_ADRS adrs
   WHERE adrs.complaint_id = cmp.complaint_id
   AND adrs.stage = c_stage
   AND cmp.agency_code = c_agency_code
   AND (cmp.formal_com_filed IS NULL OR cmp.formal_com_filed > c_to_date)
   AND NVL(adrs.date_accepted,adrs.start_date) BETWEEN c_from_date AND c_to_date
   AND (adrs.end_date IS NULL OR adrs.end_date > c_to_date)
   AND cmp.counselor_asg IS NULL;

-- Cursor for ADR actions
CURSOR cur_adr_actions(c_from_date date, c_to_date date,c_stage ghr_compl_adrs.stage%TYPE,c_adr_offered ghr_compl_adrs.adr_offered%type,c_agency_code ghr_complaints2.agency_code%type) IS
   SELECT COUNT(distinct cmp.complaint_id) p10_cnt, COUNT(distinct nvl(cmp.complainant_person_id,0)) p10_prsn,   NVL(SUM(ROUND((NVL(adrs.end_date,c_to_date) - NVL(adrs.date_accepted,adrs.start_date)),0)+1),0) p10_days
   FROM GHR_COMPLAINTS2 cmp, GHR_COMPL_ADRS adrs
   WHERE adrs.complaint_id = cmp.complaint_id
   AND adrs.stage = c_stage
   AND cmp.agency_code = c_agency_code
   AND NVL(adrs.date_accepted,adrs.start_date) BETWEEN c_from_date AND c_to_date
   AND adrs.adr_offered = c_adr_offered
   AND NVL(adrs.date_accepted,adrs.start_date) = (SELECT MAX(nvl(date_accepted,start_date))
													FROM GHR_COMPL_ADRS adrs1
													WHERE adrs1.complaint_id = adrs.complaint_id
													AND adrs.stage = c_stage);

CURSOR cur_adr_offered(c_from_date date, c_to_date date,c_stage ghr_compl_adrs.stage%TYPE,c_agency_code ghr_complaints2.agency_code%type) IS
   SELECT COUNT(distinct cmp.complaint_id) p10_cnt, COUNT(distinct nvl(cmp.complainant_person_id,0)) p10_prsn,   NVL(SUM(ROUND((NVL(adrs.end_date,c_to_date) - NVL(adrs.date_accepted,adrs.start_date)),0)+1),0) p10_days
   FROM GHR_COMPLAINTS2 cmp, GHR_COMPL_ADRS adrs
   WHERE adrs.complaint_id = cmp.complaint_id
   AND adrs.stage = c_stage
   AND cmp.agency_code = c_agency_code
   AND NVL(adrs.date_accepted,adrs.start_date) BETWEEN c_from_date AND c_to_date
   AND adrs.adr_offered IN (10,20,30)
   AND NVL(adrs.date_accepted,adrs.start_date) = (SELECT MAX(nvl(date_accepted,start_date))
													FROM GHR_COMPL_ADRS adrs1
													WHERE adrs1.complaint_id = adrs.complaint_id
													AND adrs.stage = c_stage);
-- Cursor for Resources
CURSOR cur_resources(c_from_date date, c_to_date date, c_stage ghr_compl_adrs.stage%TYPE, c_resource ghr_compl_adrs.adr_resource%TYPE,c_agency_code ghr_complaints2.agency_code%type) IS
   SELECT COUNT(distinct cmp.complaint_id) p10_cnt, COUNT(distinct nvl(cmp.complainant_person_id,0)) p10_prsn
   FROM GHR_COMPLAINTS2 cmp, GHR_COMPL_ADRS adrs
   WHERE adrs.complaint_id = cmp.complaint_id
   AND cmp.agency_code = c_agency_code
   AND adrs.stage = c_stage
   AND adrs.adr_resource = c_resource
   AND NVL(adrs.date_accepted,adrs.start_date) BETWEEN c_from_date AND c_to_date;

-- Cursor for Multiple Resources
CURSOR cur_multires(c_from_date date, c_to_date date,c_stage ghr_compl_adrs.stage%TYPE,c_agency_code ghr_complaints2.agency_code%type) IS
SELECT cmp.complaint_id, adrs.adr_resource
   FROM GHR_COMPLAINTS2 cmp, GHR_COMPL_ADRS adrs
   WHERE adrs.complaint_id = cmp.complaint_id
   AND cmp.agency_code = c_agency_code
   AND adrs.stage = c_stage
   AND adrs.adr_resource IS NOT NULL
   AND NVL(adrs.date_accepted,adrs.start_date) BETWEEN c_from_date AND c_to_date
   ORDER BY cmp.complaint_id;

-- Cursor for Techniques
CURSOR cur_techniques(c_from_date date, c_to_date date,c_stage ghr_compl_adrs.stage%TYPE, c_technique ghr_compl_adrs.technique%TYPE,c_agency_code ghr_complaints2.agency_code%type) IS
   SELECT COUNT(distinct cmp.complaint_id) p10_cnt, COUNT(distinct nvl(cmp.complainant_person_id,0)) p10_prsn,
   NVL(SUM(ROUND((NVL(adrs.end_date,c_to_date) - NVL(adrs.date_accepted,adrs.start_date) ),0)+1),0) p10_days -- Check whether this is to date or from date.
   FROM GHR_COMPLAINTS2 cmp, GHR_COMPL_ADRS adrs
   WHERE adrs.complaint_id = cmp.complaint_id
   AND cmp.agency_code = c_agency_code
   AND adrs.stage = c_stage
   AND adrs.technique = c_technique
   AND NVL(adrs.date_accepted,adrs.start_date) BETWEEN c_from_date AND c_to_date;

-- Cursor for Multi-techniques
CURSOR cur_multitechniques(c_from_date date, c_to_date date,c_stage ghr_compl_adrs.stage%TYPE,c_agency_code ghr_complaints2.agency_code%type) IS
SELECT cmp.complaint_id, adrs.technique, NVL(ROUND((NVL(adrs.end_date,c_to_date) - NVL(adrs.date_accepted,adrs.start_date)),0)+1,0) p10_days
   FROM GHR_COMPLAINTS2 cmp, GHR_COMPL_ADRS adrs
   WHERE adrs.complaint_id = cmp.complaint_id
   AND adrs.stage = c_stage
   AND cmp.agency_code = c_agency_code
   AND adrs.technique IS NOT NULL
   AND NVL(adrs.date_accepted,adrs.start_date) BETWEEN c_from_date AND c_to_date
   ORDER BY cmp.complaint_id;

CURSOR cur_case_status(c_from_date date, c_to_date date,c_stage ghr_compl_adrs.stage%TYPE, c_closure_nature ghr_complaints2.precom_closure_nature%TYPE,c_agency_code ghr_complaints2.agency_code%type) IS
   SELECT COUNT(distinct cmp.complaint_id) p10_cnt, COUNT(distinct nvl(cmp.complainant_person_id,0)) p10_prsn, NVL(SUM(ROUND((precom_closed - NVL(adrs.date_accepted,adrs.start_date)),0)+1),0) P10_days
   FROM GHR_COMPLAINTS2 cmp, GHR_COMPL_ADRS adrs
   WHERE adrs.complaint_id = cmp.complaint_id
   AND cmp.agency_code = c_agency_code
   AND NVL(adrs.date_accepted,adrs.start_date) BETWEEN c_from_date AND c_to_date
   AND adrs.stage = c_stage
   AND adrs.adr_offered IS NOT NULL
   AND adrs.end_date <= c_to_date
   AND precom_closure_nature = c_closure_nature;

CURSOR cur_case_status_settle(c_from_date date, c_to_date date,c_stage ghr_compl_adrs.stage%TYPE,c_agency_code ghr_complaints2.agency_code%type) IS
   SELECT COUNT(distinct cmp.complaint_id) p10_cnt, COUNT(distinct nvl(cmp.complainant_person_id,0)) p10_prsn, NVL(SUM(ROUND((precom_closed - NVL(adrs.date_accepted,adrs.start_date)),0)+1),0 ) P10_days
   FROM GHR_COMPLAINTS2 cmp, GHR_COMPL_ADRS adrs
   WHERE adrs.complaint_id = cmp.complaint_id
   AND cmp.agency_code = c_agency_code
   AND NVL(adrs.date_accepted,adrs.start_date) BETWEEN c_from_date AND c_to_date
   AND adrs.stage = c_stage
   AND adrs.adr_offered IS NOT NULL
   AND adrs.end_date <= c_to_date
   AND precom_closure_nature IN (60,70,80);

CURSOR cur_open_inventory (c_from_date date, c_to_date date,c_stage ghr_compl_adrs.stage%TYPE,c_agency_code ghr_complaints2.agency_code%type) IS
   SELECT COUNT(distinct cmp.complaint_id) p10_cnt, COUNT(distinct nvl(cmp.complainant_person_id,0)) p10_prsn, NVL(SUM(ROUND((precom_closed - NVL(adrs.date_accepted,adrs.start_date)),0)+1),0) P10_days
   FROM GHR_COMPLAINTS2 cmp, GHR_COMPL_ADRS adrs
   WHERE adrs.complaint_id = cmp.complaint_id
   AND cmp.agency_code = c_agency_code
   AND NVL(adrs.date_accepted,adrs.start_date) BETWEEN c_from_date AND c_to_date
   AND adrs.stage = c_stage
   AND adrs.end_date IS NULL;

CURSOR cur_benefits (c_from_date date, c_to_date date,c_stage ghr_compl_adrs.stage%TYPE, c_phase ghr_compl_ca_details.phase%TYPE
, c_payment_type ghr_compl_ca_details.payment_type%TYPE,c_agency_code ghr_complaints2.agency_code%type) IS
   SELECT COUNT(distinct cmp.complaint_id) p10_cnt, COUNT(distinct nvl(cmp.complainant_person_id,0)) P10_prsn, NVL(SUM(CEIL(ca.amount)),0) p10_amt
   FROM GHR_COMPLAINTS2 cmp, GHR_COMPL_ADRS adrs, GHR_COMPL_CA_HEADERS cah, GHR_COMPL_CA_DETAILS ca
   WHERE ca.compl_ca_header_id = cah.compl_ca_header_id
   AND cah.complaint_id = cmp.complaint_id
   AND adrs.complaint_id = cmp.complaint_id
   AND cmp.agency_code = c_agency_code
   AND NVL(adrs.date_accepted,adrs.start_date) BETWEEN c_from_date AND c_to_date
   AND adrs.stage = c_stage
   AND ca.phase = c_phase
   AND ca.payment_type = c_payment_type
   AND ca.category = 10 -- Monetary
   AND adrs.end_date IS NOT NULL;

CURSOR cur_tot_benefits (c_from_date date, c_to_date date,c_stage ghr_compl_adrs.stage%TYPE, c_phase ghr_compl_ca_details.phase%TYPE
,c_agency_code ghr_complaints2.agency_code%type) IS
   SELECT COUNT(distinct cmp.complaint_id) p10_cnt, COUNT(distinct nvl(cmp.complainant_person_id,0)) P10_prsn
   FROM GHR_COMPLAINTS2 cmp, GHR_COMPL_ADRS adrs, GHR_COMPL_CA_HEADERS cah, GHR_COMPL_CA_DETAILS ca
   WHERE ca.compl_ca_header_id = cah.compl_ca_header_id
   AND cah.complaint_id = cmp.complaint_id
   AND adrs.complaint_id = cmp.complaint_id
   AND cmp.agency_code = c_agency_code
   AND NVL(adrs.date_accepted,adrs.start_date) BETWEEN c_from_date AND c_to_date
   AND adrs.stage = c_stage
   AND ca.phase = c_phase
   AND ca.payment_type IS NOT NULL
   AND ca.category = 10 -- Monetary
   AND adrs.end_date IS NOT NULL;


CURSOR cur_benefits_pt2 (c_from_date date, c_to_date date,c_stage ghr_compl_adrs.stage%TYPE, c_phase ghr_compl_ca_details.phase%TYPE,
c_payment_type1 ghr_compl_ca_details.payment_type%TYPE,c_payment_type2 ghr_compl_ca_details.payment_type%TYPE,c_agency_code ghr_complaints2.agency_code%type) IS
   SELECT COUNT(distinct cmp.complaint_id) p10_cnt, COUNT(distinct nvl(cmp.complainant_person_id,0)) P10_prsn, NVL(SUM(CEIL(ca.amount)),0) p10_amt
   FROM GHR_COMPLAINTS2 cmp, GHR_COMPL_ADRS adrs, GHR_COMPL_CA_HEADERS cah, GHR_COMPL_CA_DETAILS ca
   WHERE ca.compl_ca_header_id = cah.compl_ca_header_id
   AND cah.complaint_id = cmp.complaint_id
   AND adrs.complaint_id = cmp.complaint_id
   AND cmp.agency_code = c_agency_code
   AND NVL(adrs.date_accepted,adrs.start_date) BETWEEN c_from_date AND c_to_date
   AND adrs.stage = c_stage
   AND ca.phase = c_phase
   AND ca.payment_type IN (c_payment_type1,c_payment_type2)
   AND ca.category = 10 -- Monetary
   AND adrs.end_date IS NOT NULL;

CURSOR cur_benefits_nm (c_from_date date, c_to_date date,c_stage ghr_compl_adrs.stage%TYPE, c_phase ghr_compl_ca_details.phase%TYPE
, c_action_type ghr_compl_ca_details.action_type%TYPE,c_agency_code ghr_complaints2.agency_code%type) IS
   SELECT COUNT(distinct cmp.complaint_id) p10_cnt, COUNT(distinct nvl(cmp.complainant_person_id,0)) P10_prsn, NVL(SUM(CEIL(ca.amount)),0) p10_amt
   FROM GHR_COMPLAINTS2 cmp, GHR_COMPL_ADRS adrs, GHR_COMPL_CA_HEADERS cah, GHR_COMPL_CA_DETAILS ca
   WHERE ca.compl_ca_header_id = cah.compl_ca_header_id
   AND cah.complaint_id = cmp.complaint_id
   AND adrs.complaint_id = cmp.complaint_id
   AND cmp.agency_code = c_agency_code
   AND NVL(adrs.date_accepted,adrs.start_date) BETWEEN c_from_date AND c_to_date
   AND adrs.stage = c_stage
   AND ca.phase = c_phase
   AND ca.action_type = c_action_type
   AND ca.category = 20 -- Non-Monetary
   AND adrs.end_date IS NOT NULL;

CURSOR cur_benefits_nm_pt2 (c_from_date date, c_to_date date,c_stage ghr_compl_adrs.stage%TYPE, c_phase ghr_compl_ca_details.phase%TYPE,
c_action_type1 ghr_compl_ca_details.action_type%TYPE,c_action_type2 ghr_compl_ca_details.action_type%TYPE,c_agency_code ghr_complaints2.agency_code%type) IS
   SELECT COUNT(distinct cmp.complaint_id) p10_cnt, COUNT(distinct nvl(cmp.complainant_person_id,0)) P10_prsn
   FROM GHR_COMPLAINTS2 cmp, GHR_COMPL_ADRS adrs, GHR_COMPL_CA_HEADERS cah, GHR_COMPL_CA_DETAILS ca
   WHERE ca.compl_ca_header_id = cah.compl_ca_header_id
   AND cah.complaint_id = cmp.complaint_id
   AND adrs.complaint_id = cmp.complaint_id
   AND cmp.agency_code = c_agency_code
   AND NVL(adrs.date_accepted,adrs.start_date) BETWEEN c_from_date AND c_to_date
   AND adrs.stage = c_stage
   AND ca.phase = c_phase
   AND ca.action_type IN (c_action_type1,c_action_type2)
   AND ca.category = 20 -- Non-Monetary
   AND adrs.end_date IS NOT NULL;

 CURSOR cur_tot_benefits_nm (c_from_date date, c_to_date date,c_stage ghr_compl_adrs.stage%TYPE, c_phase ghr_compl_ca_details.phase%TYPE,c_agency_code ghr_complaints2.agency_code%type
) IS
   SELECT COUNT(distinct cmp.complaint_id) p10_cnt, COUNT(distinct nvl(cmp.complainant_person_id,0)) P10_prsn
   FROM GHR_COMPLAINTS2 cmp, GHR_COMPL_ADRS adrs, GHR_COMPL_CA_HEADERS cah, GHR_COMPL_CA_DETAILS ca
   WHERE ca.compl_ca_header_id = cah.compl_ca_header_id
   AND cah.complaint_id = cmp.complaint_id
   AND adrs.complaint_id = cmp.complaint_id
   AND cmp.agency_code = c_agency_code
   AND NVL(adrs.date_accepted,adrs.start_date) BETWEEN c_from_date AND c_to_date
   AND adrs.stage = c_stage
   AND ca.phase = c_phase
   AND ca.action_type IS NOT NULL
   AND ca.category = 20 -- Non-Monetary
   AND adrs.end_date IS NOT NULL;

l_p10_d_cmp NUMBER;
l_p10_d1_cmp NUMBER;
l_p10_d2_cmp NUMBER;
l_p10_d3_cmp NUMBER;
l_p10_d5_cmp NUMBER;
l_p10_d1_ant NUMBER;
l_p10_d2_ant NUMBER;
l_p10_d3_ant NUMBER;
l_p10_d5_ant NUMBER;
l_p10_e1_cmp NUMBER;
l_p10_e1_ant NUMBER;
l_p10_e1_day NUMBER;
l_p10_e2_cmp NUMBER;
l_p10_e2_ant NUMBER;
l_p10_e2_day NUMBER;
l_p10_e3_cmp NUMBER;
l_p10_e3_ant NUMBER;
l_p10_e3_day NUMBER;
l_p10_e4_cmp NUMBER;
l_p10_e4_ant NUMBER;
l_p10_e4_day NUMBER;
l_p10_e5_cmp NUMBER;
l_p10_e5_ant NUMBER;
l_p10_e5_day NUMBER;
l_p10_e6_cmp NUMBER;
l_p10_e6_ant NUMBER;
l_p10_e6_day NUMBER;
l_p10_e7_cmp NUMBER;
l_p10_e7_ant NUMBER;
l_p10_e7_day NUMBER;
l_p10_e8_cmp NUMBER;
l_p10_e8_ant NUMBER;
l_p10_e8_day NUMBER;
l_p10_e9_cmp NUMBER;
l_p10_e9_ant NUMBER;
l_p10_e9_day NUMBER;
l_p10_e_cmp NUMBER;
l_p10_e_ant NUMBER;
l_p10_e_day NUMBER;
l_p10_f1a_cmp NUMBER;
l_p10_f1a_ant NUMBER;
l_P10_f1a_avg NUMBER;
l_p10_f1a_day NUMBER;
l_p10_f1b_cmp NUMBER;
l_p10_f1b_ant NUMBER;
l_P10_f1b_avg NUMBER;
l_p10_f1b_day NUMBER;
l_p10_f1c_cmp NUMBER;
l_p10_f1c_ant NUMBER;
l_P10_f1c_avg NUMBER;
l_p10_f1c_day NUMBER;
l_p10_f1d_cmp NUMBER;
l_p10_f1d_ant NUMBER;
l_P10_f1d_avg NUMBER;
l_p10_f1d_day NUMBER;
l_p10_f1_cmp NUMBER;
l_p10_f1_ant NUMBER;
l_P10_f1_avg NUMBER;
l_p10_f1_day NUMBER;
l_p10_f2_cmp NUMBER;
l_p10_f2_ant NUMBER;
l_P10_f2_avg NUMBER;
l_p10_f2_day NUMBER;
l_p10_g1_cmp NUMBER;
l_p10_g1_ant NUMBER;
l_p10_g1_amt NUMBER;
l_p10_g1a_cmp NUMBER;
l_p10_g1a_ant NUMBER;
l_p10_g1a_amt NUMBER;
l_p10_g1b_cmp NUMBER;
l_p10_g1b_ant NUMBER;
l_p10_g1b_amt NUMBER;
l_p10_g1c_cmp NUMBER;
l_p10_g1c_ant NUMBER;
l_p10_g1c_amt NUMBER;
l_p10_g1d_cmp NUMBER;
l_p10_g1d_ant NUMBER;
l_p10_g1d_amt NUMBER;
l_p10_g1e_cmp NUMBER;
l_p10_g1e_ant NUMBER;
l_p10_g1e_amt NUMBER;
l_p10_g2a_cmp NUMBER;
l_p10_g2a_ant NUMBER;
l_p10_g2b_cmp NUMBER;
l_p10_g2b_ant NUMBER;
l_p10_g2c_cmp NUMBER;
l_p10_g2c_ant NUMBER;
l_p10_g2d_cmp NUMBER;
l_p10_g2d_ant NUMBER;
l_p10_g2e_cmp NUMBER;
l_p10_g2e_ant NUMBER;
l_p10_g2f_cmp NUMBER;
l_p10_g2f_ant NUMBER;
l_p10_g2g_cmp NUMBER;
l_p10_g2g_ant NUMBER;
l_p10_g2h_cmp NUMBER;
l_p10_g2h_ant NUMBER;
l_p10_g2i_cmp NUMBER;
l_p10_g2i_ant NUMBER;
l_p10_g2j_cmp NUMBER;
l_p10_g2j_ant NUMBER;
l_p10_g2_cmp NUMBER;
l_p10_g2_ant NUMBER;
l_p10_d_ant NUMBER;
l_p10_e1_avg NUMBER;
l_p10_e2_avg NUMBER;
l_p10_e3_avg NUMBER;
l_p10_e4_avg NUMBER;
l_p10_e5_avg NUMBER;
l_p10_e6_avg NUMBER;
l_p10_e7_avg NUMBER;
l_p10_e8_avg NUMBER;
l_p10_e9_avg NUMBER;
l_p10_e_avg NUMBER;
l_p10_e10_cmp NUMBER;
l_p10_e10_ant NUMBER;
l_p10_e10_day NUMBER;
l_p10_e10_avg NUMBER;
-- Variables for Multi-techniques
l_ctr NUMBER:= 1;
l_lb_flag NUMBER := 0;
l_total_count NUMBER := 0;
l_total_days NUMBER := 0;
l_old_cmp_id NUMBER(15) := 0;
l_old_days NUMBER := 0;
l_new_cmp_id NUMBER(15) := 0;
TYPE t_prsn_cur IS REF CURSOR;
l_prsn_cur t_prsn_cur;
l_tot_prsn NUMBER(15) := 0;
l_sql_str VARCHAR2(10000) := NULL;

l_p10_a_cmp NUMBER;
l_p10_a_ant  NUMBER;
l_p10_a_day  NUMBER;
l_p10_c1_cmp NUMBER;
l_p10_c1_ant NUMBER;
l_p10_c1_day NUMBER;
l_p10_c2_cmp NUMBER;
l_p10_c2_ant NUMBER;
l_p10_c2_day NUMBER;
l_p10_c3_cmp NUMBER;
l_p10_c3_ant  NUMBER;
l_p10_c3_day  NUMBER;
l_p10_c4_cmp NUMBER;
l_p10_c4_ant NUMBER;
l_p10_c4_day NUMBER;
l_p10_b_cmp NUMBER;
l_p10_b_ant NUMBER;

BEGIN
	-- ADR Pending from previous reporting period
	FOR cur_ctr IN cur_adr_pending(p_from_date, p_to_date,'10', p_agency_code) LOOP
	   l_p10_a_cmp := cur_ctr.p10_cnt;
	   l_p10_a_ant := cur_ctr.p10_prsn;
	   l_p10_a_day := cur_ctr.p10_days;
	END LOOP;

	vXMLTable(vCtr).TagName := 'P10_a_cmp';
	vXMLTable(vCtr).TagValue := to_char(l_p10_a_cmp);
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P10_a_ant';
	vXMLTable(vCtr).TagValue := to_char(l_p10_a_ant);
	vCtr := vCtr + 1;
	-- Bug#3124648
	IF (l_p10_a_day IS NULL) THEN
		l_p10_a_day := 0;
	END IF;

	fnd_file.put_line(fnd_file.log,'Finished populating Part10 - ADR Pending from previous reporting period');
	-- Individuals Counseled through ADR
	FOR cur_ctr IN cur_adr(p_from_date, p_to_date,'10', p_agency_code) LOOP
	   l_p10_b_cmp := cur_ctr.p10_cnt;
	   l_p10_b_ant := cur_ctr.p10_prsn;
	END LOOP;

	vXMLTable(vCtr).TagName := 'P10_b_cmp';
	vXMLTable(vCtr).TagValue := to_char(l_p10_b_cmp);
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P10_b_ant';
	vXMLTable(vCtr).TagValue := to_char(l_p10_b_ant);
	vCtr := vCtr + 1;
	fnd_file.put_line(fnd_file.log,'Finished populating Part10 - Individuals Counseled through ADR');

	-- ADR Actions for current reporting period
	-- ADR Offered
	FOR cur_ctr IN cur_adr_offered(p_from_date, p_to_date,'10', p_agency_code) LOOP
	   l_p10_c1_cmp := cur_ctr.p10_cnt;
	   l_p10_c1_ant := cur_ctr.p10_prsn;
	   l_p10_c1_day := cur_ctr.p10_days;
	END LOOP;

	vXMLTable(vCtr).TagName := 'P10_c1_cmp';
	vXMLTable(vCtr).TagValue := to_char(l_p10_c1_cmp);
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P10_c1_ant';
	vXMLTable(vCtr).TagValue := to_char(l_p10_c1_ant);
	vCtr := vCtr + 1;

	-- Bug#3124648
	IF (l_p10_c1_day IS NULL) THEN
		l_p10_c1_day := 0;
	END IF;

	fnd_file.put_line(fnd_file.log,'Finished populating Part10 - ADR Offered');

	-- Rejected by Complainant
	FOR cur_ctr IN cur_adr_actions(p_from_date, p_to_date,'10','20', p_agency_code) LOOP
	   l_p10_c2_cmp := cur_ctr.p10_cnt;
	   l_p10_c2_ant := cur_ctr.p10_prsn;
	   l_p10_c2_day := cur_ctr.p10_days;
	END LOOP;

	vXMLTable(vCtr).TagName := 'P10_c2_cmp';
	vXMLTable(vCtr).TagValue := to_char(l_p10_c2_cmp);
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P10_c2_ant';
	vXMLTable(vCtr).TagValue := to_char(l_p10_c2_ant);
	vCtr := vCtr + 1;

	-- Bug#3124648
	IF (l_p10_c2_day IS NULL) THEN
		l_p10_c2_day := 0;
	END IF;

	fnd_file.put_line(fnd_file.log,'Finished populating Part10 - Rejected by Complainant');

	-- Rejected by Agency
	FOR cur_ctr IN cur_adr_actions(p_from_date, p_to_date,'10','30', p_agency_code) LOOP
	   l_p10_c3_cmp := cur_ctr.p10_cnt;
	   l_p10_c3_ant := cur_ctr.p10_prsn;
	   l_p10_c3_day := cur_ctr.p10_days;
	END LOOP;

	vXMLTable(vCtr).TagName := 'P10_c3_cmp';
	vXMLTable(vCtr).TagValue := to_char(l_p10_c3_cmp);
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P10_c3_ant';
	vXMLTable(vCtr).TagValue := to_char(l_p10_c3_ant);
	vCtr := vCtr + 1;

	-- Bug#3124648
	IF (l_p10_c3_day IS NULL) THEN
		l_p10_c3_day := 0;
	END IF;

	fnd_file.put_line(fnd_file.log,'Finished populating Part10 - Rejected by Agency');

	-- Total ADR
	l_p10_c4_cmp := l_p10_c1_cmp - (l_p10_c2_cmp + l_p10_c3_cmp);
	l_p10_c4_ant := l_p10_c1_ant - (l_p10_c2_ant + l_p10_c3_ant);
	l_p10_c4_day := l_p10_c1_day - (l_p10_c2_day + l_p10_c3_day);

	vXMLTable(vCtr).TagName := 'P10_c4_cmp';
	vXMLTable(vCtr).TagValue := to_char(l_p10_c4_cmp);
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P10_c4_ant';
	vXMLTable(vCtr).TagValue := to_char(l_p10_c4_ant);
	vCtr := vCtr + 1;
	fnd_file.put_line(fnd_file.log,'Finished populating Part10 - Total ADR');
	-- Resources Used

	-- Inhouse
	FOR cur_ctr IN cur_resources(p_from_date, p_to_date,'10','20', p_agency_code) LOOP
		l_p10_d1_cmp := cur_ctr.p10_cnt;
		l_p10_d1_ant := cur_ctr.p10_prsn;
	END LOOP;

	vXMLTable(vCtr).TagName := 'P10_d1_cmp';
	vXMLTable(vCtr).TagValue := to_char(l_p10_d1_cmp);
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P10_d1_ant';
	vXMLTable(vCtr).TagValue := to_char(l_p10_d1_ant);
	vCtr := vCtr + 1;

	-- Another Federal Agency
	FOR cur_ctr IN cur_resources(p_from_date, p_to_date,'10','10', p_agency_code) LOOP
		l_p10_d2_cmp := cur_ctr.p10_cnt;
		l_p10_d2_ant := cur_ctr.p10_prsn;
	END LOOP;

	vXMLTable(vCtr).TagName := 'P10_d2_cmp';
	vXMLTable(vCtr).TagValue := to_char(l_p10_d2_cmp);
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P10_d2_ant';
	vXMLTable(vCtr).TagValue := to_char(l_p10_d2_ant);
	vCtr := vCtr + 1;

	-- Private Organization
	FOR cur_ctr IN cur_resources(p_from_date, p_to_date,'10','50', p_agency_code) LOOP
		l_p10_d3_cmp := cur_ctr.p10_cnt;
		l_p10_d3_ant := cur_ctr.p10_prsn;
	END LOOP;

	vXMLTable(vCtr).TagName := 'P10_d3_cmp';
	vXMLTable(vCtr).TagValue := to_char(l_p10_d3_cmp);
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P10_d3_ant';
	vXMLTable(vCtr).TagValue := to_char(l_p10_d3_ant);
	vCtr := vCtr + 1;

-- Multiple Resources

	l_total_count := 0;
	l_total_days := 0;
	l_old_cmp_id := 0;
	l_old_days := 0;
	v_temp.DELETE;
	l_ctr := 1;


	FOR cur_ctr IN cur_multires(p_from_date, p_to_date,'10', p_agency_code) LOOP
		IF (cur_ctr.adr_resource = '30') THEN
			v_temp(l_ctr).complaint_id := cur_ctr.complaint_id;
			l_total_count := l_total_count + 1;
			l_old_cmp_id := cur_ctr.complaint_id;
			l_ctr := l_ctr + 1;
		ELSE
			l_new_cmp_id := cur_ctr.complaint_id;

			IF (l_old_cmp_id = l_new_cmp_id) THEN

				-- Search whether entry for the same complaint exist already, if exists update the same.
				l_lb_flag := 0 ;
				IF (v_temp.COUNT>0) THEN
					FOR l_ctr1 IN v_temp.FIRST .. v_temp.LAST LOOP
					   IF (v_temp(l_ctr1).complaint_id = l_new_cmp_id) THEN
						  l_total_count := l_total_count + 1;
						  l_lb_flag := 1;
					   END IF;
					END LOOP;
				END IF;
				-- If the complaint doesnt exist already, add new entry.
				IF (l_lb_flag = 0) THEN
				    v_temp(l_ctr).complaint_id := cur_ctr.complaint_id;
					l_total_count := l_total_count + 2;
				END IF;
			END IF;
			l_old_cmp_id := cur_ctr.complaint_id;
		END IF;
	END LOOP;
	-- To Find out the complainants for these complaints
	l_sql_str := '';
	IF (v_temp.COUNT > 0) THEN
		l_sql_str := v_temp(1).complaint_id;
	END IF;

	IF (v_temp.COUNT > 1) THEN
		FOR l_ctr  IN 2 .. v_temp.COUNT LOOP
		   l_sql_str := l_sql_str || ',' || to_char(v_temp(l_ctr).complaint_id);
		END LOOP;
	END IF;
	IF (l_sql_str IS NOT NULL) THEN
		l_sql_str := 'SELECT COUNT(distinct nvl(cmp.complainant_person_id,0)) FROM GHR_COMPLAINTS2 cmp  WHERE cmp.complaint_id in (' || l_sql_str || ')';
		OPEN l_prsn_cur FOR l_sql_str;
		FETCH l_prsn_cur INTO l_tot_prsn;
		CLOSE l_prsn_cur;
	END IF;


	vXMLTable(vCtr).TagName := 'P10_d4_cmp';
	vXMLTable(vCtr).TagValue := to_char(l_total_count);
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P10_d4_ant';
	vXMLTable(vCtr).TagValue := to_char(l_tot_prsn);
	vCtr := vCtr + 1;

	--------- End Multiple Resources
	-- Other
	FOR cur_ctr IN cur_resources(p_from_date, p_to_date,'10','40', p_agency_code) LOOP
		l_p10_d5_cmp := cur_ctr.p10_cnt;
		l_p10_d5_ant := cur_ctr.p10_prsn;
	END LOOP;

	vXMLTable(vCtr).TagName := 'P10_d5_cmp';
	vXMLTable(vCtr).TagValue := to_char(l_p10_d5_cmp);
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P10_d5_ant';
	vXMLTable(vCtr).TagValue := to_char(l_p10_d5_ant);
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P10_d6_cmp';
	vXMLTable(vCtr).TagValue := '0';
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P10_d6_ant';
	vXMLTable(vCtr).TagValue := '0';
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P10_d7_cmp';
	vXMLTable(vCtr).TagValue := '0';
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P10_d7_ant';
	vXMLTable(vCtr).TagValue := '0';
	vCtr := vCtr + 1;

	-- Total Resources

	l_p10_d_cmp := l_p10_d1_cmp + l_p10_d2_cmp + l_p10_d3_cmp + l_total_count + l_p10_d5_cmp;
	l_p10_d_ant := l_p10_d1_ant + l_p10_d2_ant + l_p10_d3_ant + l_tot_prsn + l_p10_d5_ant;


	vXMLTable(vCtr).TagName := 'P10_d_cmp';
	vXMLTable(vCtr).TagValue := to_char(l_p10_d_cmp);
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P10_d_ant';
	vXMLTable(vCtr).TagValue := to_char(l_p10_d_ant);
	vCtr := vCtr + 1;
	fnd_file.put_line(fnd_file.log,'Finished populating Part10 - Resources');
	-- Techniques used
	-- Mediation
	FOR cur_ctr IN cur_techniques(p_from_date, p_to_date,'10','40', p_agency_code) LOOP
		l_p10_e1_cmp := cur_ctr.p10_cnt;
		l_p10_e1_ant := cur_ctr.p10_prsn;
		l_p10_e1_day := cur_ctr.p10_days;
	END LOOP;

	vXMLTable(vCtr).TagName := 'P10_e1_cmp';
	vXMLTable(vCtr).TagValue := to_char(l_p10_e1_cmp);
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P10_e1_ant';
	vXMLTable(vCtr).TagValue := to_char(l_p10_e1_ant);
	vCtr := vCtr + 1;

	IF (l_p10_e1_day IS NULL) THEN
	   l_p10_e1_day := 0;
	END IF;

	vXMLTable(vCtr).TagName := 'P10_e1_day';
	vXMLTable(vCtr).TagValue := to_char(l_p10_e1_day);
	vCtr := vCtr + 1;

	-- Average Days
/*	IF (l_p10_e1_cmp > 0) THEN
		l_P10_e1_avg := CEIL(l_p10_e1_day/l_p10_e1_cmp);
	ELSE
		l_P10_e1_avg := 0;
	END IF;
	vXMLTable(vCtr).TagName := 'P10_e1_avg';
	vXMLTable(vCtr).TagValue := to_char(l_P10_e1_avg);
	vCtr := vCtr + 1;
*/

	-- Settlement Conferences
	FOR cur_ctr IN cur_techniques(p_from_date, p_to_date,'10','100', p_agency_code) LOOP
		l_p10_e2_cmp := cur_ctr.p10_cnt;
		l_p10_e2_ant := cur_ctr.p10_prsn;
		l_p10_e2_day := cur_ctr.p10_days;
	END LOOP;

	vXMLTable(vCtr).TagName := 'P10_e2_cmp';
	vXMLTable(vCtr).TagValue := to_char(l_p10_e2_cmp);
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P10_e2_ant';
	vXMLTable(vCtr).TagValue := to_char(l_p10_e2_ant);
	vCtr := vCtr + 1;

	IF (l_p10_e2_day IS NULL) THEN
	   l_p10_e2_day := 0;
	END IF;

	vXMLTable(vCtr).TagName := 'P10_e2_day';
	vXMLTable(vCtr).TagValue := to_char(l_p10_e2_day);
	vCtr := vCtr + 1;

	-- Average Days
/*	IF (l_p10_e2_cmp > 0) THEN
		l_P10_e2_avg := CEIL(l_p10_e2_day/l_p10_e2_cmp);
	ELSE
		l_P10_e2_avg := 0;
	END IF;
	vXMLTable(vCtr).TagName := 'P10_e2_avg';
	vXMLTable(vCtr).TagValue := to_char(l_P10_e2_avg);
	vCtr := vCtr + 1;
*/
	-- Early Neutral evaluations
	FOR cur_ctr IN cur_techniques(p_from_date, p_to_date,'10','10', p_agency_code) LOOP
		l_p10_e3_cmp := cur_ctr.p10_cnt;
		l_p10_e3_ant := cur_ctr.p10_prsn;
		l_p10_e3_day := cur_ctr.p10_days;
	END LOOP;

	vXMLTable(vCtr).TagName := 'P10_e3_cmp';
	vXMLTable(vCtr).TagValue := to_char(l_p10_e3_cmp);
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P10_e3_ant';
	vXMLTable(vCtr).TagValue := to_char(l_p10_e3_ant);
	vCtr := vCtr + 1;

	IF (l_p10_e3_day IS NULL) THEN
	   l_p10_e3_day := 0;
	END IF;

	vXMLTable(vCtr).TagName := 'P10_e3_day';
	vXMLTable(vCtr).TagValue := to_char(l_p10_e3_day);
	vCtr := vCtr + 1;

	-- Average Days
/*	IF (l_p10_e3_cmp > 0) THEN
		l_P10_e3_avg := CEIL(l_p10_e3_day/l_p10_e3_cmp);
	ELSE
		l_P10_e3_avg := 0;
	END IF;
	vXMLTable(vCtr).TagName := 'P10_e3_avg';
	vXMLTable(vCtr).TagValue := to_char(l_P10_e3_avg);
	vCtr := vCtr + 1;
*/
	-- Factfinding

	FOR cur_ctr IN cur_techniques(p_from_date, p_to_date,'10','30', p_agency_code) LOOP
		l_p10_e4_cmp := cur_ctr.p10_cnt;
		l_p10_e4_ant := cur_ctr.p10_prsn;
		l_p10_e4_day := cur_ctr.p10_days;
	END LOOP;

	vXMLTable(vCtr).TagName := 'P10_e4_cmp';
	vXMLTable(vCtr).TagValue := to_char(l_p10_e4_cmp);
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P10_e4_ant';
	vXMLTable(vCtr).TagValue := to_char(l_p10_e4_ant);
	vCtr := vCtr + 1;

	IF (l_p10_e4_day IS NULL) THEN
	   l_p10_e4_day := 0;
	END IF;

	vXMLTable(vCtr).TagName := 'P10_e4_day';
	vXMLTable(vCtr).TagValue := to_char(l_p10_e4_day);
	vCtr := vCtr + 1;

	-- Average Days
/*	IF (l_p10_e4_cmp > 0) THEN
		l_P10_e4_avg := CEIL(l_p10_e4_day/l_p10_e4_cmp);
	ELSE
		l_P10_e4_avg := 0;
	END IF;
	vXMLTable(vCtr).TagName := 'P10_e4_avg';
	vXMLTable(vCtr).TagValue := to_char(l_P10_e4_avg);
	vCtr := vCtr + 1;
*/
	-- Facilitation
	FOR cur_ctr IN cur_techniques(p_from_date, p_to_date,'10','20', p_agency_code) LOOP
		l_p10_e5_cmp := cur_ctr.p10_cnt;
		l_p10_e5_ant := cur_ctr.p10_prsn;
		l_p10_e5_day := cur_ctr.p10_days;
	END LOOP;

	vXMLTable(vCtr).TagName := 'P10_e5_cmp';
	vXMLTable(vCtr).TagValue := to_char(l_p10_e5_cmp);
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P10_e5_ant';
	vXMLTable(vCtr).TagValue := to_char(l_p10_e5_ant);
	vCtr := vCtr + 1;

	IF (l_p10_e5_day IS NULL) THEN
	   l_p10_e5_day := 0;
	END IF;

	vXMLTable(vCtr).TagName := 'P10_e5_day';
	vXMLTable(vCtr).TagValue := to_char(l_p10_e5_day);
	vCtr := vCtr + 1;

	-- Average Days
/*	IF (l_p10_e5_cmp > 0) THEN
		l_P10_e5_avg := CEIL(l_p10_e5_day/l_p10_e5_cmp);
	ELSE
		l_P10_e5_avg := 0;
	END IF;
	vXMLTable(vCtr).TagName := 'P10_e5_avg';
	vXMLTable(vCtr).TagValue := to_char(l_P10_e5_avg);
	vCtr := vCtr + 1;
*/
	-- Ombudsman
	FOR cur_ctr IN cur_techniques(p_from_date, p_to_date,'10','80', p_agency_code) LOOP
		l_p10_e6_cmp := cur_ctr.p10_cnt;
		l_p10_e6_ant := cur_ctr.p10_prsn;
		l_p10_e6_day := cur_ctr.p10_days;
	END LOOP;

	vXMLTable(vCtr).TagName := 'P10_e6_cmp';
	vXMLTable(vCtr).TagValue := to_char(l_p10_e6_cmp);
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P10_e6_ant';
	vXMLTable(vCtr).TagValue := to_char(l_p10_e6_ant);
	vCtr := vCtr + 1;

	IF (l_p10_e6_day IS NULL) THEN
	   l_p10_e6_day := 0;
	END IF;

	vXMLTable(vCtr).TagName := 'P10_e6_day';
	vXMLTable(vCtr).TagValue := to_char(l_p10_e6_day);
	vCtr := vCtr + 1;

	-- Average Days
/*	IF (l_p10_e6_cmp > 0) THEN
		l_P10_e6_avg := CEIL(l_p10_e6_day/l_p10_e6_cmp);
	ELSE
		l_P10_e6_avg := 0;
	END IF;
	vXMLTable(vCtr).TagName := 'P10_e6_avg';
	vXMLTable(vCtr).TagValue := to_char(l_P10_e6_avg);
	vCtr := vCtr + 1;
*/
	-- Mini-trials
	FOR cur_ctr IN cur_techniques(p_from_date, p_to_date,'10','60', p_agency_code) LOOP
		l_p10_e7_cmp := cur_ctr.p10_cnt;
		l_p10_e7_ant := cur_ctr.p10_prsn;
		l_p10_e7_day := cur_ctr.p10_days;
	END LOOP;

	vXMLTable(vCtr).TagName := 'P10_e7_cmp';
	vXMLTable(vCtr).TagValue := to_char(l_p10_e7_cmp);
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P10_e7_ant';
	vXMLTable(vCtr).TagValue := to_char(l_p10_e7_ant);
	vCtr := vCtr + 1;

	IF (l_p10_e7_day IS NULL) THEN
	   l_p10_e7_day := 0;
	END IF;


	vXMLTable(vCtr).TagName := 'P10_e7_day';
	vXMLTable(vCtr).TagValue := to_char(l_p10_e7_day);
	vCtr := vCtr + 1;

	-- Average Days
/*	IF (l_p10_e7_cmp > 0) THEN
		l_P10_e7_avg := CEIL(l_p10_e7_day/l_p10_e7_cmp);
	ELSE
		l_P10_e7_avg := 0;
	END IF;
	vXMLTable(vCtr).TagName := 'P10_e7_avg';
	vXMLTable(vCtr).TagValue := to_char(l_P10_e7_avg);
	vCtr := vCtr + 1;
*/
	-- Peer review
	FOR cur_ctr IN cur_techniques(p_from_date, p_to_date,'10','90', p_agency_code) LOOP
		l_p10_e8_cmp := cur_ctr.p10_cnt;
		l_p10_e8_ant := cur_ctr.p10_prsn;
		l_p10_e8_day := cur_ctr.p10_days;
	END LOOP;

	vXMLTable(vCtr).TagName := 'P10_e8_cmp';
	vXMLTable(vCtr).TagValue := to_char(l_p10_e8_cmp);
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P10_e8_ant';
	vXMLTable(vCtr).TagValue := to_char(l_p10_e8_ant);
	vCtr := vCtr + 1;

	IF (l_p10_e8_day IS NULL) THEN
	   l_p10_e8_day := 0;
	END IF;

	vXMLTable(vCtr).TagName := 'P10_e8_day';
	vXMLTable(vCtr).TagValue := to_char(l_p10_e8_day);
	vCtr := vCtr + 1;

	-- Average Days
/*	IF (l_p10_e8_cmp > 0) THEN
		l_P10_e8_avg := CEIL(l_p10_e8_day/l_p10_e8_cmp);
	ELSE
		l_P10_e8_avg := 0;
	END IF;
	vXMLTable(vCtr).TagName := 'P10_e8_avg';
	vXMLTable(vCtr).TagValue := to_char(l_P10_e8_avg);
	vCtr := vCtr + 1;
*/
	-- Other

	FOR cur_ctr IN cur_techniques(p_from_date, p_to_date,'10','70', p_agency_code) LOOP
		l_p10_e10_cmp := cur_ctr.p10_cnt;
		l_p10_e10_ant := cur_ctr.p10_prsn;
		l_p10_e10_day := cur_ctr.p10_days;
	END LOOP;

	vXMLTable(vCtr).TagName := 'P10_e10_cmp';
	vXMLTable(vCtr).TagValue := to_char(l_p10_e10_cmp);
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P10_e10_ant';
	vXMLTable(vCtr).TagValue := to_char(l_p10_e10_ant);
	vCtr := vCtr + 1;

	IF (l_p10_e10_day IS NULL) THEN
	   l_p10_e10_day := 0;
	END IF;

	vXMLTable(vCtr).TagName := 'P10_e10_day';
	vXMLTable(vCtr).TagValue := to_char(l_p10_e10_day);
	vCtr := vCtr + 1;

	-- Average Days
/*	IF (l_p10_e10_cmp > 0) THEN
		l_P10_e10_avg := CEIL(l_p10_e10_day/l_p10_e10_cmp);
	ELSE
		l_P10_e10_avg := 0;
	END IF;
	vXMLTable(vCtr).TagName := 'P10_e10_avg';
	vXMLTable(vCtr).TagValue := to_char(l_P10_e10_avg);
	vCtr := vCtr + 1;
*/
	-- Multiple Techniques

	l_total_count := 0;
	l_total_days := 0;
	l_old_cmp_id := 0;
	l_old_days := 0;
	l_ctr := 1;
	v_temp.DELETE;


	FOR cur_ctr IN cur_multitechniques(p_from_date, p_to_date,'10', p_agency_code) LOOP
		IF (cur_ctr.technique = '50') THEN
			v_temp(l_ctr).complaint_id := cur_ctr.complaint_id;
			l_total_count := l_total_count + 1;
			l_total_days := l_total_days + cur_ctr.p10_days;
			l_old_cmp_id := cur_ctr.complaint_id;
			l_old_days := cur_ctr.p10_days;
			l_ctr := l_ctr + 1;
		ELSE
			l_new_cmp_id := cur_ctr.complaint_id;
			IF (l_old_cmp_id = l_new_cmp_id) THEN
				-- Search whether entry for the same complaint exist already, if exists update the same.
				l_lb_flag := 0 ;
				IF (v_temp.COUNT > 0) THEN
					FOR l_ctr1 IN v_temp.FIRST .. v_temp.LAST LOOP
					   IF (v_temp(l_ctr1).complaint_id = l_new_cmp_id) THEN
						  l_total_count := l_total_count + 1;
						  l_total_days := l_total_days + cur_ctr.p10_days;
						  l_lb_flag := 1;
					   END IF;
					END LOOP;
				END IF;
				-- If the complaint doesnt exist already, add new entry.
				IF (l_lb_flag = 0) THEN
				    v_temp(l_ctr).complaint_id := cur_ctr.complaint_id;
					l_total_count := l_total_count + 2;
					l_total_days := l_total_days + l_old_days + cur_ctr.p10_days;
				END IF;
			END IF;
			l_old_cmp_id := cur_ctr.complaint_id;
			l_old_days := cur_ctr.p10_days;
		END IF;
	END LOOP;

	-- To Find out the complainants for these complaints
	l_sql_str := '';

	IF (v_temp.COUNT > 0) THEN
		l_sql_str := v_temp(1).complaint_id;
	END IF;

	IF (v_temp.COUNT > 1) THEN
		FOR l_ctr  IN 2 .. v_temp.COUNT LOOP
		   l_sql_str := l_sql_str || ',' || to_char(v_temp(l_ctr).complaint_id);
		END LOOP;
	END IF;
	IF (l_sql_str IS NOT NULL) THEN
		l_sql_str := 'SELECT COUNT(distinct nvl(cmp.complainant_person_id,0)) FROM GHR_COMPLAINTS2 cmp  WHERE cmp.complaint_id in (' || l_sql_str || ')';
		OPEN l_prsn_cur FOR l_sql_str;
		FETCH l_prsn_cur INTO l_tot_prsn;
		CLOSE l_prsn_cur;
	END IF;

	--------- End Multiple Techniques

	vXMLTable(vCtr).TagName := 'P10_e9_cmp';
	vXMLTable(vCtr).TagValue := to_char(l_total_count);
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P10_e9_ant';
	vXMLTable(vCtr).TagValue := to_char(l_tot_prsn);
	vCtr := vCtr + 1;

	IF (l_total_days IS NULL) THEN
	   l_total_days := 0;
	END IF;

	vXMLTable(vCtr).TagName := 'P10_e9_day';
	vXMLTable(vCtr).TagValue := to_char(l_total_days);
	vCtr := vCtr + 1;

	-- Average Days
/*	IF (l_total_count > 0) THEN
		l_P10_e9_avg := CEIL(l_total_days/l_total_count);
	ELSE
		l_P10_e9_avg := 0;
	END IF;
	vXMLTable(vCtr).TagName := 'P10_e9_avg';
	vXMLTable(vCtr).TagValue := to_char(l_P10_e9_avg);
	vCtr := vCtr + 1;
*/
	-- Filling zeroes for other fields
	vXMLTable(vCtr).TagName := 'P10_e11_cmp';
	vXMLTable(vCtr).TagValue := '0';
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P10_e11_ant';
	vXMLTable(vCtr).TagValue := '0';
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P10_e11_day';
	vXMLTable(vCtr).TagValue := '0';
	vCtr := vCtr + 1;

/*	vXMLTable(vCtr).TagName := 'P10_e11_avg';
	vXMLTable(vCtr).TagValue := '0';
	vCtr := vCtr + 1;
*/
	vXMLTable(vCtr).TagName := 'P10_e12_cmp';
	vXMLTable(vCtr).TagValue := '0';
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P10_e12_ant';
	vXMLTable(vCtr).TagValue := '0';
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P10_e12_day';
	vXMLTable(vCtr).TagValue := '0';
	vCtr := vCtr + 1;

/*	vXMLTable(vCtr).TagName := 'P10_e12_avg';
	vXMLTable(vCtr).TagValue := '0';
	vCtr := vCtr + 1;
*/
	l_p10_e_cmp :=  l_p10_e1_cmp + l_p10_e2_cmp + l_p10_e3_cmp + l_p10_e4_cmp + l_p10_e5_cmp + l_p10_e6_cmp + l_p10_e7_cmp + l_p10_e8_cmp + l_total_count + l_p10_e10_cmp;
	l_p10_e_ant := l_p10_e1_ant + l_p10_e2_ant + l_p10_e3_ant + l_p10_e4_ant + l_p10_e5_ant + l_p10_e6_ant + l_p10_e7_ant + l_p10_e8_ant + l_tot_prsn + l_p10_e10_ant;
	l_p10_e_day := l_p10_e1_day + l_p10_e2_day + l_p10_e3_day + l_p10_e4_day + l_p10_e5_day + l_p10_e6_day + l_p10_e7_day + l_p10_e8_day + l_total_days + l_p10_e10_day;

	vXMLTable(vCtr).TagName := 'P10_e_cmp';
	vXMLTable(vCtr).TagValue := to_char(l_p10_e_cmp);
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P10_e_ant';
	vXMLTable(vCtr).TagValue := to_char(l_p10_e_ant);
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P10_e_day';
	vXMLTable(vCtr).TagValue := to_char(l_p10_e_day);
	vCtr := vCtr + 1;

	-- Average Days
/*	IF (l_p10_e_cmp > 0) THEN
		l_P10_e_avg := CEIL(l_p10_e_day/l_p10_e_cmp);
	END IF;
	vXMLTable(vCtr).TagName := 'P10_e_avg';
	vXMLTable(vCtr).TagValue := to_char(l_P10_e_avg);
	vCtr := vCtr + 1;
*/
	fnd_file.put_line(fnd_file.log,'Finished populating Part10 - Techniques');
	-- Status of Cases
	-- Settlement with benefits
	FOR cur_ctr IN cur_case_status_settle(p_from_date, p_to_date,'10', p_agency_code) LOOP
		l_p10_f1a_cmp := cur_ctr.p10_cnt;
		l_p10_f1a_ant := cur_ctr.p10_prsn;
		l_p10_f1a_day := cur_ctr.p10_days;
	END LOOP;

	vXMLTable(vCtr).TagName := 'P10_f1a_cmp';
	vXMLTable(vCtr).TagValue := to_char(l_p10_f1a_cmp);
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P10_f1a_ant';
	vXMLTable(vCtr).TagValue := to_char(l_p10_f1a_ant);
	vCtr := vCtr + 1;

	IF (l_p10_f1a_day IS NULL) THEN
	   l_p10_f1a_day := 0;
	END IF;

	vXMLTable(vCtr).TagName := 'P10_f1a_day';
	vXMLTable(vCtr).TagValue := to_char(l_p10_f1a_day);
	vCtr := vCtr + 1;

	-- Average Days
/*	IF (l_p10_f1a_cmp > 0) THEN
		l_P10_f1a_avg := CEIL(l_p10_f1a_day/l_p10_f1a_cmp);
	ELSE
		l_P10_f1a_avg := 0;
	END IF;
	vXMLTable(vCtr).TagName := 'P10_f1a_avg';
	vXMLTable(vCtr).TagValue := to_char(l_P10_f1a_avg);
	vCtr := vCtr + 1;
*/
	-- Notice of Right to file(Did not file formal complaint)
	FOR cur_ctr IN cur_case_status(p_from_date, p_to_date,'10','20', p_agency_code) LOOP
		l_p10_f1b_cmp := cur_ctr.p10_cnt;
		l_p10_f1b_ant := cur_ctr.p10_prsn;
		l_p10_f1b_day := cur_ctr.p10_days;
	END LOOP;

	vXMLTable(vCtr).TagName := 'P10_f1b_cmp';
	vXMLTable(vCtr).TagValue := to_char(l_p10_f1b_cmp);
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P10_f1b_ant';
	vXMLTable(vCtr).TagValue := to_char(l_p10_f1b_ant);
	vCtr := vCtr + 1;

	IF (l_p10_f1b_day IS NULL) THEN
	   l_p10_f1b_day := 0;
	END IF;

	vXMLTable(vCtr).TagName := 'P10_f1b_day';
	vXMLTable(vCtr).TagValue := to_char(l_p10_f1b_day);
	vCtr := vCtr + 1;

	-- Average Days
/*	IF (l_p10_f1b_cmp > 0) THEN
		l_P10_f1b_avg := CEIL(l_p10_f1b_day/l_p10_f1b_cmp);
	ELSE
		l_P10_f1b_avg := 0;
	END IF;
	vXMLTable(vCtr).TagName := 'P10_f1b_avg';
	vXMLTable(vCtr).TagValue := to_char(l_P10_f1b_avg);
	vCtr := vCtr + 1;
*/
	-- Notice of Right to file(Filed Formal complaint)
	FOR cur_ctr IN cur_case_status(p_from_date, p_to_date,'10','25', p_agency_code) LOOP
		l_p10_f1c_cmp := cur_ctr.p10_cnt;
		l_p10_f1c_ant := cur_ctr.p10_prsn;
		l_p10_f1c_day := cur_ctr.p10_days;
	END LOOP;

	vXMLTable(vCtr).TagName := 'P10_f1c_cmp';
	vXMLTable(vCtr).TagValue := to_char(l_p10_f1c_cmp);
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P10_f1c_ant';
	vXMLTable(vCtr).TagValue := to_char(l_p10_f1c_ant);
	vCtr := vCtr + 1;

	IF (l_p10_f1c_day IS NULL) THEN
	   l_p10_f1c_day := 0;
	END IF;

	vXMLTable(vCtr).TagName := 'P10_f1c_day';
	vXMLTable(vCtr).TagValue := to_char(l_p10_f1c_day);
	vCtr := vCtr + 1;

	-- Average Days
/*	IF (l_p10_f1c_cmp > 0) THEN
		l_P10_f1c_avg := CEIL(l_p10_f1c_day/l_p10_f1c_cmp);
	ELSE
		l_P10_f1c_avg := 0;
	END IF;
	vXMLTable(vCtr).TagName := 'P10_f1c_avg';
	vXMLTable(vCtr).TagValue := to_char(l_P10_f1c_avg);
	vCtr := vCtr + 1;
*/

	-- Other
	FOR cur_ctr IN cur_case_status(p_from_date, p_to_date,'10','90', p_agency_code) LOOP
		l_p10_f1d_cmp := cur_ctr.p10_cnt;
		l_p10_f1d_ant := cur_ctr.p10_prsn;
		l_p10_f1d_day := cur_ctr.p10_days;
	END LOOP;

	vXMLTable(vCtr).TagName := 'P10_f1d_cmp';
	vXMLTable(vCtr).TagValue := to_char(l_p10_f1d_cmp);
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P10_f1d_ant';
	vXMLTable(vCtr).TagValue := to_char(l_p10_f1d_ant);
	vCtr := vCtr + 1;

	IF (l_p10_f1d_day IS NULL) THEN
	   l_p10_f1d_day := 0;
	END IF;

	vXMLTable(vCtr).TagName := 'P10_f1d_day';
	vXMLTable(vCtr).TagValue := to_char(l_p10_f1d_day);
	vCtr := vCtr + 1;

	-- Average Days
/*	IF (l_p10_f1d_cmp > 0) THEN
		l_P10_f1d_avg := CEIL(l_p10_f1d_day/l_p10_f1d_cmp);
	ELSE
		l_P10_f1d_avg := 0;
	END IF;
	vXMLTable(vCtr).TagName := 'P10_f1d_avg';
	vXMLTable(vCtr).TagValue := to_char(l_P10_f1d_avg);
	vCtr := vCtr + 1;
*/
	vXMLTable(vCtr).TagName := 'P10_f1d_cmp';
	vXMLTable(vCtr).TagValue := to_char(l_p10_f1d_cmp);
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P10_f1d_ant';
	vXMLTable(vCtr).TagValue := to_char(l_p10_f1d_ant);
	vCtr := vCtr + 1;

	-- Filling zeroes for other fields

	vXMLTable(vCtr).TagName := 'P10_f1e_day';
	vXMLTable(vCtr).TagValue := '0';
	vCtr := vCtr + 1;

/*	vXMLTable(vCtr).TagName := 'P10_f1e_avg';
	vXMLTable(vCtr).TagValue := '0';
	vCtr := vCtr + 1;
*/
	vXMLTable(vCtr).TagName := 'P10_f1e_cmp';
	vXMLTable(vCtr).TagValue := '0';
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P10_f1e_ant';
	vXMLTable(vCtr).TagValue := '0';
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P10_f1f_day';
	vXMLTable(vCtr).TagValue := '0';
	vCtr := vCtr + 1;

/*	vXMLTable(vCtr).TagName := 'P10_f1f_avg';
	vXMLTable(vCtr).TagValue := '0';
	vCtr := vCtr + 1;
*/
	vXMLTable(vCtr).TagName := 'P10_f1f_cmp';
	vXMLTable(vCtr).TagValue := '0';
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P10_f1f_ant';
	vXMLTable(vCtr).TagValue := '0';
	vCtr := vCtr + 1;

	-- Total Closed
	l_p10_f1_cmp := l_p10_f1a_cmp + l_p10_f1b_cmp + l_p10_f1c_cmp + l_p10_f1d_cmp;
	l_p10_f1_ant := l_p10_f1a_ant + l_p10_f1b_ant + l_p10_f1c_ant + l_p10_f1d_ant;
	l_p10_f1_day := l_p10_f1a_day + l_p10_f1b_day + l_p10_f1c_day + l_p10_f1d_day;

	vXMLTable(vCtr).TagName := 'P10_f1_cmp';
	vXMLTable(vCtr).TagValue := to_char(l_p10_f1_cmp);
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P10_f1_ant';
	vXMLTable(vCtr).TagValue := to_char(l_p10_f1_ant);
	vCtr := vCtr + 1;

	IF (l_p10_f1_day IS NULL) THEN
	   l_p10_f1_day := 0;
	END IF;

	vXMLTable(vCtr).TagName := 'P10_f1_day';
	vXMLTable(vCtr).TagValue := to_char(l_p10_f1_day);
	vCtr := vCtr + 1;

	-- Average Days
/*	IF (l_p10_f1_cmp > 0) THEN
		l_P10_f1_avg := CEIL(l_p10_f1_day/l_p10_f1_cmp);
	ELSE
		l_P10_f1_avg := 0;
	END IF;
	vXMLTable(vCtr).TagName := 'P10_f1_avg';
	vXMLTable(vCtr).TagValue := to_char(l_P10_f1_avg);
	vCtr := vCtr + 1;
*/
	fnd_file.put_line(fnd_file.log,'Finished populating Part10 - Closed Complaints');

	-- Open inventory
	-- Formula changed to A + C4 - F1
/*	FOR cur_ctr IN cur_open_inventory(p_from_date, p_to_date,'10', p_agency_code) LOOP
		l_p10_f2_cmp := cur_ctr.p10_cnt;
		l_p10_f2_ant := cur_ctr.p10_prsn;
		l_p10_f2_day := cur_ctr.p10_days;
	END LOOP; */

	l_p10_f2_cmp := l_p10_a_cmp + l_p10_c4_cmp - l_p10_f1_cmp;
	l_p10_f2_ant := l_p10_a_ant + l_p10_c4_ant - l_p10_f1_ant;
	l_p10_f2_day := l_p10_a_day + l_p10_c4_day - l_p10_f1_day;

	vXMLTable(vCtr).TagName := 'P10_f2_cmp';
	vXMLTable(vCtr).TagValue := to_char(l_p10_f2_cmp);
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P10_f2_ant';
	vXMLTable(vCtr).TagValue := to_char(l_p10_f2_ant);
	vCtr := vCtr + 1;

	IF (l_p10_f2_day IS NULL) THEN
	   l_p10_f2_day := 0;
	END IF;

	vXMLTable(vCtr).TagName := 'P10_f2_day';
	vXMLTable(vCtr).TagValue := to_char(l_p10_f2_day);
	vCtr := vCtr + 1;

	-- Average Days
/*	IF (l_p10_f2_cmp > 0) THEN
		l_P10_f2_avg := CEIL(l_p10_f2_day/l_p10_f2_cmp);
	ELSE
		l_P10_f2_avg := 0;
	END IF;
	vXMLTable(vCtr).TagName := 'P10_f2_avg';
	vXMLTable(vCtr).TagValue := to_char(l_P10_f2_avg);
	vCtr := vCtr + 1;
*/
	fnd_file.put_line(fnd_file.log,'Finished populating Part10 - Open inventory');
	-- Benefits Received
	-- Compensatory Damages
	FOR cur_ctr IN cur_benefits_pt2(p_from_date, p_to_date,'10','40','30','40', p_agency_code) LOOP
		l_p10_g1a_cmp := cur_ctr.p10_cnt;
		l_p10_g1a_ant := cur_ctr.p10_prsn;
		l_p10_g1a_amt := cur_ctr.p10_amt;
	END LOOP;

	vXMLTable(vCtr).TagName := 'P10_g1a_cmp';
	vXMLTable(vCtr).TagValue := to_char(l_p10_g1a_cmp);
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P10_g1a_ant';
	vXMLTable(vCtr).TagValue := to_char(l_p10_g1a_ant);
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P10_g1a_amt';
	vXMLTable(vCtr).TagValue := to_char(l_p10_g1a_amt);
	vCtr := vCtr + 1;


	-- BackPay and front pay
	FOR cur_ctr IN cur_benefits(p_from_date, p_to_date,'10','40','20', p_agency_code) LOOP
		l_p10_g1b_cmp := cur_ctr.p10_cnt;
		l_p10_g1b_ant := cur_ctr.p10_prsn;
		l_p10_g1b_amt := cur_ctr.p10_amt;
	END LOOP;

	vXMLTable(vCtr).TagName := 'P10_g1b_cmp';
	vXMLTable(vCtr).TagValue := to_char(l_p10_g1b_cmp);
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P10_g1b_ant';
	vXMLTable(vCtr).TagValue := to_char(l_p10_g1b_ant);
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P10_g1b_amt';
	vXMLTable(vCtr).TagValue := to_char(l_p10_g1b_amt);
	vCtr := vCtr + 1;

	-- Lump Sum
	FOR cur_ctr IN cur_benefits(p_from_date, p_to_date,'10','40','50', p_agency_code) LOOP
		l_p10_g1c_cmp := cur_ctr.p10_cnt;
		l_p10_g1c_ant := cur_ctr.p10_prsn;
		l_p10_g1c_amt := cur_ctr.p10_amt;
	END LOOP;

	vXMLTable(vCtr).TagName := 'P10_g1c_cmp';
	vXMLTable(vCtr).TagValue := to_char(l_p10_g1c_cmp);
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P10_g1c_ant';
	vXMLTable(vCtr).TagValue := to_char(l_p10_g1c_ant);
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P10_g1c_amt';
	vXMLTable(vCtr).TagValue := to_char(l_p10_g1c_amt);
	vCtr := vCtr + 1;

	-- Attorney's fees and costs
	FOR cur_ctr IN cur_benefits(p_from_date, p_to_date,'10','40','10', p_agency_code) LOOP
		l_p10_g1d_cmp := cur_ctr.p10_cnt;
		l_p10_g1d_ant := cur_ctr.p10_prsn;
		l_p10_g1d_amt := cur_ctr.p10_amt;
	END LOOP;

	vXMLTable(vCtr).TagName := 'P10_g1d_cmp';
	vXMLTable(vCtr).TagValue := to_char(l_p10_g1d_cmp);
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P10_g1d_ant';
	vXMLTable(vCtr).TagValue := to_char(l_p10_g1d_ant);
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P10_g1d_amt';
	vXMLTable(vCtr).TagValue := to_char(l_p10_g1d_amt);
	vCtr := vCtr + 1;

	-- Other
	FOR cur_ctr IN cur_benefits(p_from_date, p_to_date,'10','40','60', p_agency_code) LOOP
		l_p10_g1e_cmp := cur_ctr.p10_cnt;
		l_p10_g1e_ant := cur_ctr.p10_prsn;
		l_p10_g1e_amt := cur_ctr.p10_amt;
	END LOOP;

	vXMLTable(vCtr).TagName := 'P10_g1e_cmp';
	vXMLTable(vCtr).TagValue := to_char(l_p10_g1e_cmp);
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P10_g1e_ant';
	vXMLTable(vCtr).TagValue := to_char(l_p10_g1e_ant);
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P10_g1e_amt';
	vXMLTable(vCtr).TagValue := to_char(l_p10_g1e_amt);
	vCtr := vCtr + 1;

	-- Filling zeroes in other fields

	vXMLTable(vCtr).TagName := 'P10_g1f_cmp';
	vXMLTable(vCtr).TagValue := '0';
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P10_g1f_ant';
	vXMLTable(vCtr).TagValue := '0';
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P10_g1f_amt';
	vXMLTable(vCtr).TagValue := '0';
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P10_g1g_cmp';
	vXMLTable(vCtr).TagValue := '0';
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P10_g1g_ant';
	vXMLTable(vCtr).TagValue := '0';
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P10_g1g_amt';
	vXMLTable(vCtr).TagValue := '0';
	vCtr := vCtr + 1;


	FOR cur_ctr IN cur_tot_benefits(p_from_date, p_to_date,'10','40', p_agency_code) LOOP
		l_p10_g1_cmp := cur_ctr.p10_cnt;
		l_p10_g1_ant := cur_ctr.p10_prsn;
	END LOOP;

--	l_p10_5a_cmp := l_p10_5a1_cmp + l_p10_5a2_cmp + l_p10_5a3_cmp + l_p10_5a4_cmp + l_p10_5a5_cmp;
--	l_p10_5a_ant := l_p10_5a1_ant + l_p10_5a2_ant + l_p10_5a3_ant + l_p10_5a4_ant + l_p10_5a5_ant;
	l_p10_g1_amt := l_p10_g1a_amt + l_p10_g1b_amt + l_p10_g1c_amt + l_p10_g1d_amt + l_p10_g1e_amt;

	vXMLTable(vCtr).TagName := 'P10_g1_cmp';
	vXMLTable(vCtr).TagValue := to_char(l_p10_g1_cmp);
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P10_g1_ant';
	vXMLTable(vCtr).TagValue := to_char(l_p10_g1_ant);
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P10_g1_amt';
	vXMLTable(vCtr).TagValue := to_char(l_p10_g1_amt);
	vCtr := vCtr + 1;
	fnd_file.put_line(fnd_file.log,'Finished populating Part10 - Benefits received Monetary');
	-- Non-Monetary
	-- New Hires
	FOR cur_ctr IN cur_benefits_nm_pt2(p_from_date, p_to_date,'10','40','70','80', p_agency_code) LOOP
		l_p10_g2a_cmp := cur_ctr.p10_cnt;
		l_p10_g2a_ant := cur_ctr.p10_prsn;
	END LOOP;

	vXMLTable(vCtr).TagName := 'P10_g2a_cmp';
	vXMLTable(vCtr).TagValue := to_char(l_p10_g2a_cmp);
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P10_g2a_ant';
	vXMLTable(vCtr).TagValue := to_char(l_p10_g2a_ant);
	vCtr := vCtr + 1;

	-- Promotions
	FOR cur_ctr IN cur_benefits_nm_pt2(p_from_date, p_to_date,'10','40','130','140', p_agency_code) LOOP
		l_p10_g2b_cmp := cur_ctr.p10_cnt;
		l_p10_g2b_ant := cur_ctr.p10_prsn;
	END LOOP;

	vXMLTable(vCtr).TagName := 'P10_g2b_cmp';
	vXMLTable(vCtr).TagValue := to_char(l_p10_g2b_cmp);
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P10_g2b_ant';
	vXMLTable(vCtr).TagValue := to_char(l_p10_g2b_ant);
	vCtr := vCtr + 1;

	-- Reinstatements
	FOR cur_ctr IN cur_benefits_nm(p_from_date, p_to_date,'10','40','160', p_agency_code) LOOP
		l_p10_g2c_cmp := cur_ctr.p10_cnt;
		l_p10_g2c_ant := cur_ctr.p10_prsn;
	END LOOP;

	vXMLTable(vCtr).TagName := 'P10_g2c_cmp';
	vXMLTable(vCtr).TagValue := to_char(l_p10_g2c_cmp);
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P10_g2c_ant';
	vXMLTable(vCtr).TagValue := to_char(l_p10_g2c_ant);
	vCtr := vCtr + 1;

	-- Expungements
	FOR cur_ctr IN cur_benefits_nm(p_from_date, p_to_date,'10','40','60', p_agency_code) LOOP
		l_p10_g2d_cmp := cur_ctr.p10_cnt;
		l_p10_g2d_ant := cur_ctr.p10_prsn;
	END LOOP;

	vXMLTable(vCtr).TagName := 'P10_g2d_cmp';
	vXMLTable(vCtr).TagValue := to_char(l_p10_g2d_cmp);
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P10_g2d_ant';
	vXMLTable(vCtr).TagValue := to_char(l_p10_g2d_ant);
	vCtr := vCtr + 1;

	-- Transfers
	FOR cur_ctr IN cur_benefits_nm(p_from_date, p_to_date,'10','40','190', p_agency_code) LOOP
		l_p10_g2e_cmp := cur_ctr.p10_cnt;
		l_p10_g2e_ant := cur_ctr.p10_prsn;
	END LOOP;

	vXMLTable(vCtr).TagName := 'P10_g2e_cmp';
	vXMLTable(vCtr).TagValue := to_char(l_p10_g2e_cmp);
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P10_g2e_ant';
	vXMLTable(vCtr).TagValue := to_char(l_p10_g2e_ant);
	vCtr := vCtr + 1;

	-- Removals Rescinded and Voluntary Resignations
	FOR cur_ctr IN cur_benefits_nm(p_from_date, p_to_date,'10','40','170', p_agency_code) LOOP
		l_p10_g2f_cmp := cur_ctr.p10_cnt;
		l_p10_g2f_ant := cur_ctr.p10_prsn;
	END LOOP;

	vXMLTable(vCtr).TagName := 'P10_g2f_cmp';
	vXMLTable(vCtr).TagValue := to_char(l_p10_g2f_cmp);
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P10_g2f_ant';
	vXMLTable(vCtr).TagValue := to_char(l_p10_g2f_ant);
	vCtr := vCtr + 1;

	-- Reasonable accomodations
	FOR cur_ctr IN cur_benefits_nm(p_from_date, p_to_date,'10','40','10', p_agency_code) LOOP
		l_p10_g2g_cmp := cur_ctr.p10_cnt;
		l_p10_g2g_ant := cur_ctr.p10_prsn;
	END LOOP;

	vXMLTable(vCtr).TagName := 'P10_g2g_cmp';
	vXMLTable(vCtr).TagValue := to_char(l_p10_g2g_cmp);
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P10_g2g_ant';
	vXMLTable(vCtr).TagValue := to_char(l_p10_g2g_ant);
	vCtr := vCtr + 1;


	-- Training
	FOR cur_ctr IN cur_benefits_nm(p_from_date, p_to_date,'10','40','180', p_agency_code) LOOP
		l_p10_g2h_cmp := cur_ctr.p10_cnt;
		l_p10_g2h_ant := cur_ctr.p10_prsn;
	END LOOP;

	vXMLTable(vCtr).TagName := 'P10_g2h_cmp';
	vXMLTable(vCtr).TagValue := to_char(l_p10_g2h_cmp);
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P10_g2h_ant';
	vXMLTable(vCtr).TagValue := to_char(l_p10_g2h_ant);
	vCtr := vCtr + 1;

	-- Apology
	FOR cur_ctr IN cur_benefits_nm(p_from_date, p_to_date,'10','40','20', p_agency_code) LOOP
		l_p10_g2i_cmp := cur_ctr.p10_cnt;
		l_p10_g2i_ant := cur_ctr.p10_prsn;
	END LOOP;

	vXMLTable(vCtr).TagName := 'P10_g2i_cmp';
	vXMLTable(vCtr).TagValue := to_char(l_p10_g2i_cmp);
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P10_g2i_ant';
	vXMLTable(vCtr).TagValue := to_char(l_p10_g2i_ant);
	vCtr := vCtr + 1;

	-- Other

	FOR cur_ctr IN cur_benefits_nm(p_from_date, p_to_date,'10','40','100', p_agency_code) LOOP
		l_p10_g2j_cmp := cur_ctr.p10_cnt;
		l_p10_g2j_ant := cur_ctr.p10_prsn;
	END LOOP;

	vXMLTable(vCtr).TagName := 'P10_g2j_cmp';
	vXMLTable(vCtr).TagValue := to_char(l_p10_g2j_cmp);
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P10_g2j_ant';
	vXMLTable(vCtr).TagValue := to_char(l_p10_g2j_ant);
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P10_g2k_cmp';
	vXMLTable(vCtr).TagValue := '0';
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P10_g2k_ant';
	vXMLTable(vCtr).TagValue := '0';
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P10_g2l_cmp';
	vXMLTable(vCtr).TagValue := '0';
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P10_g2l_ant';
	vXMLTable(vCtr).TagValue := '0';
	vCtr := vCtr + 1;

/*	l_p10_5b_cmp := l_p10_5b1_cmp + l_p10_5b2_cmp + l_p10_5b3_cmp + l_p10_5b4_cmp + l_p10_5b5_cmp + l_p10_5b6_cmp +
						l_p10_5b7_cmp + l_p10_5b8_cmp + l_p10_5b9_cmp;
	l_p10_5b_ant := l_p10_5b1_ant + l_p10_5b2_ant + l_p10_5b3_ant + l_p10_5b4_ant + l_p10_5b5_ant + l_p10_5b6_ant +
						l_p10_5b7_ant + l_p10_5b8_ant + l_p10_5b9_ant; */


	-- Total Non-Monetary Complaints and  Complainants
	FOR cur_ctr IN cur_tot_benefits_nm(p_from_date, p_to_date,'10','40', p_agency_code) LOOP
		l_p10_g2_cmp := cur_ctr.p10_cnt;
		l_p10_g2_ant := cur_ctr.p10_prsn;
	END LOOP;

	vXMLTable(vCtr).TagName := 'P10_g2_cmp';
	vXMLTable(vCtr).TagValue := to_char(l_p10_g2_cmp);
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P10_g2_ant';
	vXMLTable(vCtr).TagValue := to_char(l_p10_g2_ant);
	vCtr := vCtr + 1;
	fnd_file.put_line(fnd_file.log,'Finished populating Part10 - Benefits received Non-monetary');
	fnd_file.put_line(fnd_file.log,'------------End of Part10----------------');
END populate_part10;

PROCEDURE populate_part11(
   p_from_date   in date,
   p_to_date     in date,
   p_agency_code in varchar2) IS

-- Cursor for ADR Pending from previous reporting period
CURSOR cur_adr_pending(c_from_date date, c_to_date date,c_stage NUMBER,c_agency_code ghr_complaints2.agency_code%type) IS
   SELECT COUNT(distinct cmp.complaint_id) p11_cnt, COUNT(distinct nvl(cmp.complainant_person_id,0)) p11_prsn,NVL(SUM(ROUND((c_to_date - NVL(adrs.date_accepted,adrs.start_date)) ,0) + 1),0) p11_days
   FROM GHR_COMPLAINTS2 cmp, GHR_COMPL_ADRS adrs
   WHERE adrs.complaint_id = cmp.complaint_id
   AND adrs.stage in ('20','30','40','50','60','70','75')
   AND cmp.formal_com_filed IS NOT NULL
   AND (cmp.complaint_closed IS NULL OR cmp.complaint_closed > c_to_date)
   AND cmp.agency_code = c_agency_code
   AND NVL(adrs.date_accepted,adrs.start_date) < c_from_date
   AND (adrs.end_date IS NULL OR adrs.end_date > c_to_date);


-- Cursor for ADR actions
CURSOR cur_adr_actions(c_from_date date, c_to_date date,c_stage NUMBER,c_adr_offered ghr_compl_adrs.adr_offered%type,c_agency_code ghr_complaints2.agency_code%type) IS
   SELECT COUNT(distinct cmp.complaint_id) p11_cnt, COUNT(distinct nvl(cmp.complainant_person_id,0)) p11_prsn,NVL(SUM(ROUND((NVL(adrs.end_date,c_to_date) - NVL(adrs.date_accepted,adrs.start_date)),0)+1),0) p11_days
   FROM GHR_COMPLAINTS2 cmp, GHR_COMPL_ADRS adrs
   WHERE adrs.complaint_id = cmp.complaint_id
   AND cmp.agency_code = c_agency_code
   AND adrs.stage in ('20','30','40','50','60','70','75')
   AND NVL(adrs.date_accepted,adrs.start_date) BETWEEN c_from_date AND c_to_date
   AND adrs.adr_offered = c_adr_offered
   AND NVL(adrs.date_accepted,adrs.start_date) = (SELECT MAX(nvl(date_accepted,start_date))
													FROM GHR_COMPL_ADRS adrs1
													WHERE adrs1.complaint_id = adrs.complaint_id
													AND adrs.stage in ('20','30','40','50','60','70','75'));

CURSOR cur_adr_offered(c_from_date date, c_to_date date,c_stage NUMBER,c_agency_code ghr_complaints2.agency_code%type) IS
   SELECT COUNT(distinct cmp.complaint_id) p11_cnt, COUNT(distinct nvl(cmp.complainant_person_id,0)) p11_prsn,NVL(SUM(ROUND((NVL(adrs.end_date,c_to_date) - NVL(adrs.date_accepted,adrs.start_date)),0)+1),0) p11_days
   FROM GHR_COMPLAINTS2 cmp, GHR_COMPL_ADRS adrs
   WHERE adrs.complaint_id = cmp.complaint_id
   AND cmp.agency_code = c_agency_code
   AND adrs.stage in ('20','30','40','50','60','70','75')
   AND NVL(adrs.date_accepted,adrs.start_date) BETWEEN c_from_date AND c_to_date
   AND adrs.adr_offered IN (10,20,30)
   AND NVL(adrs.date_accepted,adrs.start_date) = (SELECT MAX(nvl(date_accepted,start_date))
													FROM GHR_COMPL_ADRS adrs1
													WHERE adrs1.complaint_id = adrs.complaint_id
													AND adrs.stage in ('20','30','40','50','60','70','75'));

-- Cursor for Resources
CURSOR cur_resources(c_from_date date, c_to_date date, c_stage NUMBER, c_resource ghr_compl_adrs.adr_resource%TYPE,c_agency_code ghr_complaints2.agency_code%type) IS
   SELECT COUNT(distinct cmp.complaint_id) p11_cnt, COUNT(distinct nvl(cmp.complainant_person_id,0)) p11_prsn
   FROM GHR_COMPLAINTS2 cmp, GHR_COMPL_ADRS adrs
   WHERE adrs.complaint_id = cmp.complaint_id
   AND cmp.agency_code = c_agency_code
   AND adrs.stage in ('20','30','40','50','60','70','75')
   AND adrs.adr_resource = c_resource
   AND NVL(adrs.date_accepted,adrs.start_date) BETWEEN c_from_date AND c_to_date;

-- Cursor for Multiple Resources
CURSOR cur_multires(c_from_date date, c_to_date date,c_stage NUMBER,c_agency_code ghr_complaints2.agency_code%type) IS
SELECT cmp.complaint_id, adrs.adr_resource
   FROM GHR_COMPLAINTS2 cmp, GHR_COMPL_ADRS adrs
   WHERE adrs.complaint_id = cmp.complaint_id
   AND cmp.agency_code = c_agency_code
   AND adrs.stage in ('20','30','40','50','60','70','75')
   AND adrs.adr_resource IS NOT NULL
   AND NVL(adrs.date_accepted,adrs.start_date) BETWEEN c_from_date AND c_to_date
   ORDER BY cmp.complaint_id;


-- Cursor for Techniques
CURSOR cur_techniques(c_from_date date, c_to_date date,c_stage NUMBER, c_technique ghr_compl_adrs.technique%TYPE,c_agency_code ghr_complaints2.agency_code%type) IS
   SELECT COUNT(distinct cmp.complaint_id) p11_cnt, COUNT(distinct nvl(cmp.complainant_person_id,0)) p11_prsn,
   NVL(SUM(ROUND((NVL(adrs.end_date,c_to_date) - NVL(adrs.date_accepted,adrs.start_date)),0)+1),0) p11_days -- Check whether this is to date or from date.
   FROM GHR_COMPLAINTS2 cmp, GHR_COMPL_ADRS adrs
   WHERE adrs.complaint_id = cmp.complaint_id
   AND cmp.agency_code = c_agency_code
   AND adrs.stage in ('20','30','40','50','60','70','75')
   AND adrs.technique = c_technique
   AND NVL(adrs.date_accepted,adrs.start_date) BETWEEN c_from_date AND c_to_date;

-- Cursor for Multi-techniques
CURSOR cur_multitechniques(c_from_date date, c_to_date date,c_stage NUMBER,c_agency_code ghr_complaints2.agency_code%type) IS
SELECT cmp.complaint_id, adrs.technique, NVL(ROUND((NVL(adrs.end_date,c_to_date) - NVL(adrs.date_accepted,adrs.start_date)),0)+1,0) p11_days
   FROM GHR_COMPLAINTS2 cmp, GHR_COMPL_ADRS adrs
   WHERE adrs.complaint_id = cmp.complaint_id
   AND cmp.agency_code = c_agency_code
   AND adrs.stage in ('20','30','40','50','60','70','75')
   AND adrs.technique IS NOT NULL
   AND NVL(adrs.date_accepted,adrs.start_date) BETWEEN c_from_date AND c_to_date
   ORDER BY cmp.complaint_id;

CURSOR cur_case_status(c_from_date date, c_to_date date,c_stage NUMBER, c_closure_nature ghr_complaints2.nature_of_closure%TYPE,c_agency_code ghr_complaints2.agency_code%type) IS
   SELECT COUNT(cmp.complaint_id) p11_cnt, COUNT(distinct nvl(cmp.complainant_person_id,0)) p11_prsn, NVL(SUM(ROUND((complaint_closed - NVL(adrs.date_accepted,adrs.start_date)),0)+1),0) p11_days
   FROM GHR_COMPLAINTS2 cmp, GHR_COMPL_ADRS adrs
   WHERE adrs.complaint_id = cmp.complaint_id
   AND cmp.agency_code = c_agency_code
   AND NVL(adrs.date_accepted,adrs.start_date) BETWEEN c_from_date AND c_to_date
   AND adrs.stage in ('20','30','40','50','60','70','75')
   AND adrs.end_date <= c_to_date
   AND cmp.nature_of_closure = c_closure_nature;

CURSOR cur_case_status_settle(c_from_date date, c_to_date date,c_stage NUMBER,c_agency_code ghr_complaints2.agency_code%type) IS
   SELECT COUNT(cmp.complaint_id) p11_cnt, COUNT(distinct nvl(cmp.complainant_person_id,0)) p11_prsn, NVL(SUM(ROUND((complaint_closed - NVL(adrs.date_accepted,adrs.start_date)),0)+1),0) p11_days
   FROM GHR_COMPLAINTS2 cmp, GHR_COMPL_ADRS adrs
   WHERE adrs.complaint_id = cmp.complaint_id
   AND cmp.agency_code = c_agency_code
   AND NVL(adrs.date_accepted,adrs.start_date) BETWEEN c_from_date AND c_to_date
   AND adrs.stage in ('20','30','40','50','60','70','75')
   AND adrs.end_date <= c_to_date
   AND cmp.nature_of_closure IN (140,150,160);

CURSOR cur_open_inventory (c_from_date date, c_to_date date,c_stage NUMBER,c_agency_code ghr_complaints2.agency_code%type) IS
   SELECT COUNT(cmp.complaint_id) p11_cnt, COUNT(distinct nvl(cmp.complainant_person_id,0)) p11_prsn, NVL(SUM(ROUND((complaint_closed - NVL(adrs.date_accepted,adrs.start_date)),0)+1),0) p11_days
   FROM GHR_COMPLAINTS2 cmp, GHR_COMPL_ADRS adrs
   WHERE adrs.complaint_id = cmp.complaint_id
   AND cmp.agency_code = c_agency_code
   AND NVL(adrs.date_accepted,adrs.start_date) BETWEEN c_from_date AND c_to_date
   AND adrs.stage in ('20','30','40','50','60','70','75')
   AND adrs.end_date IS NULL;

CURSOR cur_benefits (c_from_date date, c_to_date date,c_stage NUMBER, c_phase ghr_compl_ca_details.phase%TYPE
, c_payment_type ghr_compl_ca_details.payment_type%TYPE,c_agency_code ghr_complaints2.agency_code%type) IS
   SELECT COUNT(cmp.complaint_id) p11_cnt, COUNT(distinct nvl(cmp.complainant_person_id,0)) p11_prsn, NVL(SUM(CEIL(ca.amount)),0) p11_amt
   FROM GHR_COMPLAINTS2 cmp, GHR_COMPL_ADRS adrs, GHR_COMPL_CA_HEADERS cah, GHR_COMPL_CA_DETAILS ca
   WHERE ca.compl_ca_header_id = cah.compl_ca_header_id
   AND cah.complaint_id = cmp.complaint_id
   AND adrs.complaint_id = cmp.complaint_id
   AND cmp.agency_code = c_agency_code
   AND NVL(adrs.date_accepted,adrs.start_date) BETWEEN c_from_date AND c_to_date
   AND adrs.stage in ('20','30','40','50','60','70','75')
   AND ca.phase = c_phase
   AND ca.payment_type = c_payment_type
   AND ca.category = 10 -- Monetary
   AND adrs.end_date IS NOT NULL;

CURSOR cur_tot_benefits (c_from_date date, c_to_date date,c_stage NUMBER, c_phase ghr_compl_ca_details.phase%TYPE,c_agency_code ghr_complaints2.agency_code%type
) IS
   SELECT COUNT(distinct cmp.complaint_id) p11_cnt, COUNT(distinct nvl(cmp.complainant_person_id,0)) P11_prsn
   FROM GHR_COMPLAINTS2 cmp, GHR_COMPL_ADRS adrs, GHR_COMPL_CA_HEADERS cah, GHR_COMPL_CA_DETAILS ca
   WHERE ca.compl_ca_header_id = cah.compl_ca_header_id
   AND cah.complaint_id = cmp.complaint_id
   AND adrs.complaint_id = cmp.complaint_id
   AND cmp.agency_code = c_agency_code
   AND NVL(adrs.date_accepted,adrs.start_date) BETWEEN c_from_date AND c_to_date
   AND adrs.stage in ('20','30','40','50','60','70','75')
   AND ca.phase = c_phase
   AND ca.payment_type IN (10,20,30,40,50,60)
   AND ca.category = 10 -- Monetary
   AND adrs.end_date IS NOT NULL;

CURSOR cur_benefits_pt2 (c_from_date date, c_to_date date,c_stage NUMBER, c_phase ghr_compl_ca_details.phase%TYPE,
c_payment_type1 ghr_compl_ca_details.payment_type%TYPE,c_payment_type2 ghr_compl_ca_details.payment_type%TYPE,c_agency_code ghr_complaints2.agency_code%type) IS
   SELECT COUNT(cmp.complaint_id) p11_cnt, COUNT(distinct nvl(cmp.complainant_person_id,0)) p11_prsn, NVL(SUM(CEIL(ca.amount)),0) p11_amt
   FROM GHR_COMPLAINTS2 cmp, GHR_COMPL_ADRS adrs, GHR_COMPL_CA_HEADERS cah, GHR_COMPL_CA_DETAILS ca
   WHERE ca.compl_ca_header_id = cah.compl_ca_header_id
   AND cah.complaint_id = cmp.complaint_id
   AND adrs.complaint_id = cmp.complaint_id
   AND cmp.agency_code = c_agency_code
   AND NVL(adrs.date_accepted,adrs.start_date) BETWEEN c_from_date AND c_to_date
   AND adrs.stage in ('20','30','40','50','60','70','75')
   AND ca.phase = c_phase
   AND ca.payment_type IN (c_payment_type1,c_payment_type2)
   AND ca.category = 10 -- Monetary
   AND adrs.end_date IS NOT NULL;

CURSOR cur_benefits_nm (c_from_date date, c_to_date date,c_stage NUMBER, c_phase ghr_compl_ca_details.phase%TYPE
, c_action_type ghr_compl_ca_details.action_type%TYPE,c_agency_code ghr_complaints2.agency_code%type) IS
   SELECT COUNT(cmp.complaint_id) p11_cnt, COUNT(distinct nvl(cmp.complainant_person_id,0)) p11_prsn
   FROM GHR_COMPLAINTS2 cmp, GHR_COMPL_ADRS adrs, GHR_COMPL_CA_HEADERS cah, GHR_COMPL_CA_DETAILS ca
   WHERE ca.compl_ca_header_id = cah.compl_ca_header_id
   AND cah.complaint_id = cmp.complaint_id
   AND adrs.complaint_id = cmp.complaint_id
   AND cmp.agency_code = c_agency_code
   AND NVL(adrs.date_accepted,adrs.start_date) BETWEEN c_from_date AND c_to_date
   AND adrs.stage in ('20','30','40','50','60','70','75')
   AND ca.phase = c_phase
   AND ca.action_type = c_action_type
   AND ca.category = 20 -- Non-Monetary
   AND adrs.end_date IS NOT NULL;

CURSOR cur_benefits_nm_pt2 (c_from_date date, c_to_date date,c_stage NUMBER, c_phase ghr_compl_ca_details.phase%TYPE,
c_action_type1 ghr_compl_ca_details.action_type%TYPE,c_action_type2 ghr_compl_ca_details.action_type%TYPE,c_agency_code ghr_complaints2.agency_code%type) IS
   SELECT COUNT(cmp.complaint_id) p11_cnt, COUNT(distinct nvl(cmp.complainant_person_id,0)) p11_prsn
   FROM GHR_COMPLAINTS2 cmp, GHR_COMPL_ADRS adrs, GHR_COMPL_CA_HEADERS cah, GHR_COMPL_CA_DETAILS ca
   WHERE ca.compl_ca_header_id = cah.compl_ca_header_id
   AND cah.complaint_id = cmp.complaint_id
   AND adrs.complaint_id = cmp.complaint_id
   AND cmp.agency_code = c_agency_code
   AND NVL(adrs.date_accepted,adrs.start_date) BETWEEN c_from_date AND c_to_date
   AND adrs.stage in ('20','30','40','50','60','70','75')
   AND ca.phase = c_phase
   AND ca.action_type IN (c_action_type1,c_action_type2)
   AND ca.category = 20 -- Non-Monetary
   AND adrs.end_date IS NOT NULL;

CURSOR cur_tot_benefits_nm (c_from_date date, c_to_date date,c_stage NUMBER, c_phase ghr_compl_ca_details.phase%TYPE
,c_agency_code ghr_complaints2.agency_code%type) IS
   SELECT COUNT(distinct cmp.complaint_id) p11_cnt, COUNT(distinct nvl(cmp.complainant_person_id,0)) P11_prsn
   FROM GHR_COMPLAINTS2 cmp, GHR_COMPL_ADRS adrs, GHR_COMPL_CA_HEADERS cah, GHR_COMPL_CA_DETAILS ca
   WHERE ca.compl_ca_header_id = cah.compl_ca_header_id
   AND cah.complaint_id = cmp.complaint_id
   AND adrs.complaint_id = cmp.complaint_id
   AND cmp.agency_code = c_agency_code
   AND NVL(adrs.date_accepted,adrs.start_date) BETWEEN c_from_date AND c_to_date
   AND adrs.stage in ('20','30','40','50','60','70','75')
   AND ca.phase = c_phase
   AND ca.action_type IS NOT NULL
   AND ca.category = 20 -- Non-Monetary
   AND adrs.end_date IS NOT NULL;


l_p11_c1_cmp NUMBER;
l_p11_c1_ant NUMBER;
l_p11_c2_cmp NUMBER;
l_p11_c2_ant NUMBER;

l_p11_c_cmp NUMBER;
l_p11_c_ant NUMBER;

l_p11_1a_ant NUMBER;


l_p11_c3_cmp NUMBER;
l_p11_c3_ant NUMBER;
l_p11_c5_cmp NUMBER;
l_p11_c5_ant NUMBER;

l_p11_d_cmp NUMBER;
l_p11_d_ant NUMBER;
l_p11_d_day NUMBER;

l_p11_d1_cmp NUMBER;
l_p11_d1_ant NUMBER;
l_p11_d1_day NUMBER;
l_p11_d2_cmp NUMBER;
l_p11_d2_ant NUMBER;
l_p11_d2_day NUMBER;
l_p11_d3_cmp NUMBER;
l_p11_d3_ant NUMBER;
l_p11_d3_day NUMBER;
l_P11_d4_cmp NUMBER;
l_p11_d4_ant NUMBER;
l_p11_d4_day NUMBER;
l_p11_d5_cmp NUMBER;
l_p11_d5_ant NUMBER;
l_p11_d5_day NUMBER;
l_p11_d6_cmp NUMBER;
l_p11_d6_ant NUMBER;
l_p11_d6_day NUMBER;
l_p11_d7_cmp NUMBER;
l_p11_d7_ant NUMBER;
l_p11_d7_day NUMBER;
l_p11_d8_cmp  NUMBER;
l_p11_d8_ant  NUMBER;
l_p11_d8_day  NUMBER;
l_p11_3i_cmp NUMBER;
l_p11_3i_ant NUMBER;
l_p11_3i_day NUMBER;
l_p11_d10_cmp NUMBER;
l_p11_d10_ant NUMBER;
l_p11_d10_day NUMBER;
l_p11_e1a_cmp NUMBER;
l_p11_e1a_ant NUMBER;
l_p11_e1a_day NUMBER;
l_p11_e1b_cmp  NUMBER;
l_p11_e1b_ant  NUMBER;
l_p11_e1b_day  NUMBER;
l_p11_e1c_cmp NUMBER;
l_p11_e1c_ant NUMBER;
l_p11_e1c_day NUMBER;
l_p11_e1d_cmp NUMBER;
l_p11_e1d_ant NUMBER;
l_p11_e1d_day NUMBER;
l_p11_e1_cmp NUMBER;
l_p11_e1_ant NUMBER;
l_p11_e1_day NUMBER;
l_p11_e2_cmp NUMBER;
l_p11_e2_ant NUMBER;
l_p11_e2_day NUMBER;
l_p11_f1_cmp NUMBER;
l_p11_f1_ant NUMBER;
l_p11_f1_amt NUMBER;
l_p11_f1a_cmp NUMBER;
l_p11_f1a_ant NUMBER;
l_p11_f1a_amt NUMBER;
l_p11_f1b_cmp NUMBER;
l_p11_f1b_ant NUMBER;
l_p11_f1b_amt NUMBER;
l_p11_f1c_cmp NUMBER;
l_p11_f1c_ant NUMBER;
l_p11_f1c_amt NUMBER;
l_p11_f1d_cmp  NUMBER;
l_p11_f1d_ant  NUMBER;
l_p11_f1d_amt  NUMBER;
l_p11_f1e_cmp NUMBER;
l_p11_f1e_ant NUMBER;
l_p11_f1e_amt NUMBER;
l_p11_f2_cmp NUMBER;
l_p11_f2_ant NUMBER;
l_p11_f2a_cmp NUMBER;
l_p11_f2a_ant NUMBER;
l_p11_f2b_cmp NUMBER;
l_p11_f2b_ant NUMBER;
l_p11_f2c_cmp NUMBER;
l_p11_f2c_ant NUMBER;
l_p11_f2d_cmp NUMBER;
l_p11_f2d_ant NUMBER;
l_p11_f2e_cmp NUMBER;
l_p11_f2e_ant NUMBER;
l_p11_5b6_cmp NUMBER;
l_P11_f2f_ant NUMBER;
l_p11_f2g_cmp NUMBER;
l_p11_f2g_ant NUMBER;
l_p11_f2h_cmp  NUMBER;
l_p11_f2h_ant  NUMBER;
l_p11_f2i_cmp NUMBER;
l_p11_f2i_ant NUMBER;
l_p11_f2j_cmp NUMBER;
l_p11_f2j_ant NUMBER;

-- Average fields
l_P11_d1_avg NUMBER;
l_P11_d2_avg NUMBER;
l_P11_d3_avg NUMBER;
l_P11_d4_avg NUMBER;
l_P11_d5_avg NUMBER;
l_P11_d6_avg NUMBER;
l_P11_d7_avg NUMBER;
l_P11_d8_avg NUMBER;
l_P11_d9_avg NUMBER;
l_P11_d10_avg NUMBER;
l_P11_e1a_avg NUMBER;
l_P11_e1b_avg NUMBER;
l_P11_e1c_avg NUMBER;
l_P11_e1d_avg NUMBER;
l_P11_e2_avg NUMBER;
l_P11_d_avg NUMBER;
l_P11_e1_avg NUMBER;


-- Variables for Multi-techniques
l_ctr NUMBER:= 1;
l_lb_flag NUMBER := 0;
l_total_count NUMBER := 0;
l_total_days NUMBER := 0;
l_old_cmp_id NUMBER := 0;
l_old_days NUMBER := 0;
l_new_cmp_id NUMBER := 0;
TYPE t_prsn_cur IS REF CURSOR;
l_prsn_cur t_prsn_cur;
l_tot_prsn NUMBER(15) := 0;
l_sql_str VARCHAR2(10000) := NULL;

l_p11_a_cmp NUMBER;
l_p11_a_ant  NUMBER;
l_p11_a_day  NUMBER;
l_p11_b1_cmp NUMBER;
l_p11_b1_ant NUMBER;
l_p11_b1_day NUMBER;
l_p11_b2_cmp NUMBER;
l_p11_b2_ant NUMBER;
l_p11_b2_day NUMBER;
l_p11_b3_cmp NUMBER;
l_p11_b3_ant  NUMBER;
l_p11_b3_day  NUMBER;
l_p11_b4_cmp NUMBER;
l_p11_b4_ant NUMBER;
l_p11_b4_day NUMBER;

BEGIN
	--
	fnd_file.put_line(fnd_file.log,'Starting populating Part11 - Total accepted into ADR');
	-- ADR Pending from previous reporting period
	FOR cur_ctr IN cur_adr_pending(p_from_date, p_to_date,20, p_agency_code) LOOP
	   l_p11_a_cmp := cur_ctr.p11_cnt;
	   l_p11_a_ant := cur_ctr.p11_prsn;
	   l_p11_a_day := cur_ctr.p11_days;
	END LOOP;
	fnd_file.put_line(fnd_file.log,'Starting populating Part11 - End of cursor');

	vXMLTable(vCtr).TagName := 'P11_a_cmp';
	vXMLTable(vCtr).TagValue := to_char(l_p11_a_cmp);
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P11_a_ant';
	vXMLTable(vCtr).TagValue := to_char(l_p11_a_ant);
	vCtr := vCtr + 1;

	-- Bug#3124648
	IF (l_p11_a_day IS NULL) THEN
		l_p11_a_day := 0;
	END IF;

	fnd_file.put_line(fnd_file.log,'Finished populating Part11 - ADR Pending from previous reporting period');

	-- ADR Actions for current reporting period
	-- ADR Offered
	-- Cursor changed to included the rejected ones also. Bug#3126112
	FOR cur_ctr IN cur_adr_offered(p_from_date, p_to_date,20, p_agency_code) LOOP
	   l_p11_b1_cmp := cur_ctr.p11_cnt;
	   l_p11_b1_ant := cur_ctr.p11_prsn;
	   l_p11_b1_day := cur_ctr.p11_days;
	END LOOP;

	vXMLTable(vCtr).TagName := 'P11_b1_cmp';
	vXMLTable(vCtr).TagValue := to_char(l_p11_b1_cmp);
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P11_b1_ant';
	vXMLTable(vCtr).TagValue := to_char(l_p11_b1_ant);
	vCtr := vCtr + 1;

	-- Bug#3124648
	IF (l_p11_b1_day IS NULL) THEN
		l_p11_b1_day := 0;
	END IF;
	fnd_file.put_line(fnd_file.log,'Finished populating Part11 - ADR Offered');


	-- Bug#3122514 Phase shd be formal complaint 20 or above.
	-- Rejected by Complainant
	FOR cur_ctr IN cur_adr_actions(p_from_date, p_to_date,20,'20', p_agency_code) LOOP
	   l_p11_b2_cmp := cur_ctr.p11_cnt;
	   l_p11_b2_ant := cur_ctr.p11_prsn;
	   l_p11_b2_day := cur_ctr.p11_days;
	END LOOP;

	vXMLTable(vCtr).TagName := 'P11_b2_cmp';
	vXMLTable(vCtr).TagValue := to_char(l_p11_b2_cmp);
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P11_b2_ant';
	vXMLTable(vCtr).TagValue := to_char(l_p11_b2_ant);
	vCtr := vCtr + 1;

	-- Bug#3124648
	IF (l_p11_b2_day IS NULL) THEN
		l_p11_b2_day := 0;
	END IF;
	fnd_file.put_line(fnd_file.log,'Finished populating Part11 - Rejected by Complainant');

	-- Bug#3122514 Phase shd be formal complaint 20 or above.
	-- Rejected by Agency
	FOR cur_ctr IN cur_adr_actions(p_from_date, p_to_date,20,'30', p_agency_code) LOOP
	   l_p11_b3_cmp := cur_ctr.p11_cnt;
	   l_p11_b3_ant := cur_ctr.p11_prsn;
	   l_p11_b3_day := cur_ctr.p11_days;
	END LOOP;

	vXMLTable(vCtr).TagName := 'P11_b3_cmp';
	vXMLTable(vCtr).TagValue := to_char(l_p11_b3_cmp);
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P11_b3_ant';
	vXMLTable(vCtr).TagValue := to_char(l_p11_b3_ant);
	vCtr := vCtr + 1;

	-- Bug#3124648
	IF (l_p11_b3_day IS NULL) THEN
		l_p11_b3_day := 0;
	END IF;
	fnd_file.put_line(fnd_file.log,'Finished populating Part11 - Rejected by Agency');
	-- Total ADR
	l_p11_b4_cmp := l_p11_b1_cmp - (l_p11_b2_cmp + l_p11_b3_cmp);
	l_p11_b4_ant := l_p11_b1_ant - (l_p11_b2_ant + l_p11_b3_ant);
	l_p11_b4_day := l_p11_b1_day - (l_p11_b2_day + l_p11_b3_day);

	vXMLTable(vCtr).TagName := 'P11_b4_cmp';
	vXMLTable(vCtr).TagValue := to_char(l_p11_b4_cmp);
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P11_b4_ant';
	vXMLTable(vCtr).TagValue := to_char(l_p11_b4_ant);
	vCtr := vCtr + 1;

	fnd_file.put_line(fnd_file.log,'Finished populating Part11 - Total accepted into ADR');

	--------------------------------------------
	-- Resources Used
	-- Inhouse
	FOR cur_ctr IN cur_resources(p_from_date, p_to_date,20,'20', p_agency_code) LOOP
		l_p11_c1_cmp := cur_ctr.p11_cnt;
		l_p11_c1_ant := cur_ctr.p11_prsn;
	END LOOP;

	vXMLTable(vCtr).TagName := 'P11_c1_cmp';
	vXMLTable(vCtr).TagValue := to_char(l_p11_c1_cmp);
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P11_c1_ant';
	vXMLTable(vCtr).TagValue := to_char(l_p11_c1_ant);
	vCtr := vCtr + 1;

	-- Another Federal Agency
	FOR cur_ctr IN cur_resources(p_from_date, p_to_date,20,'10', p_agency_code) LOOP
		l_p11_c2_cmp := cur_ctr.p11_cnt;
		l_p11_c2_ant := cur_ctr.p11_prsn;
	END LOOP;

	vXMLTable(vCtr).TagName := 'P11_c2_cmp';
	vXMLTable(vCtr).TagValue := to_char(l_p11_c2_cmp);
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P11_c2_ant';
	vXMLTable(vCtr).TagValue := to_char(l_p11_c2_ant);
	vCtr := vCtr + 1;

	-- Private Organization
	FOR cur_ctr IN cur_resources(p_from_date, p_to_date,20,'50', p_agency_code) LOOP
		l_p11_c3_cmp := cur_ctr.p11_cnt;
		l_p11_c3_ant := cur_ctr.p11_prsn;
	END LOOP;

	vXMLTable(vCtr).TagName := 'P11_c3_cmp';
	vXMLTable(vCtr).TagValue := to_char(l_p11_c3_cmp);
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P11_c3_ant';
	vXMLTable(vCtr).TagValue := to_char(l_p11_c3_ant);
	vCtr := vCtr + 1;

-- Multiple Resources

	l_total_count := 0;
	l_total_days := 0;
	l_old_cmp_id := 0;
	l_old_days := 0;
	v_temp.DELETE;

	FOR cur_ctr IN cur_multires(p_from_date, p_to_date,20, p_agency_code) LOOP
		IF (cur_ctr.adr_resource = '30') THEN
			v_temp(l_ctr).complaint_id := cur_ctr.complaint_id;
			l_total_count := l_total_count + 1;
			l_old_cmp_id := cur_ctr.complaint_id;
			l_ctr := l_ctr + 1;
		ELSE
			l_new_cmp_id := cur_ctr.complaint_id;
			IF (l_old_cmp_id = l_new_cmp_id) THEN
				-- Search whether entry for the same complaint exist already, if exists update the same.
				l_lb_flag := 0 ;
				IF (v_temp.COUNT > 0) THEN
					FOR l_ctr1 IN v_temp.FIRST .. v_temp.LAST LOOP
					   IF (v_temp(l_ctr1).complaint_id = l_new_cmp_id) THEN
						  l_total_count := l_total_count + 1;
						  l_lb_flag := 1;
					   END IF;
					END LOOP;
				END IF;
				-- If the complaint doesnt exist already, add new entry.
				IF (l_lb_flag = 0) THEN
				    v_temp(l_ctr).complaint_id := cur_ctr.complaint_id;
					l_total_count := l_total_count + 2;
				END IF;
			END IF;
			l_old_cmp_id := cur_ctr.complaint_id;
		END IF;
	END LOOP;
	-- To Find out the complainants for these complaints
	l_sql_str := '';

	IF (v_temp.COUNT > 0) THEN
		l_sql_str := v_temp(1).complaint_id;
	END IF;

	IF (v_temp.COUNT > 1) THEN
		FOR l_ctr  IN 2 .. v_temp.COUNT LOOP
		   l_sql_str := l_sql_str || ',' || to_char(v_temp(l_ctr).complaint_id);
		END LOOP;
	END IF;
	IF (l_sql_str IS NOT NULL) THEN
		l_sql_str := 'SELECT COUNT(distinct nvl(cmp.complainant_person_id,0)) FROM GHR_COMPLAINTS2 cmp  WHERE cmp.complaint_id in (' || l_sql_str || ')';
		OPEN l_prsn_cur FOR l_sql_str;
		FETCH l_prsn_cur INTO l_tot_prsn;
		CLOSE l_prsn_cur;
	ELSE
		l_tot_prsn := 0;
	END IF;


	vXMLTable(vCtr).TagName := 'P11_c4_cmp';
	vXMLTable(vCtr).TagValue := to_char(l_total_count);
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P11_c4_ant';
	vXMLTable(vCtr).TagValue := to_char(l_tot_prsn);
	vCtr := vCtr + 1;

	-- Other
	FOR cur_ctr IN cur_resources(p_from_date, p_to_date,20,'40', p_agency_code) LOOP
		l_p11_c5_cmp := cur_ctr.p11_cnt;
		l_p11_c5_ant := cur_ctr.p11_prsn;
	END LOOP;

	vXMLTable(vCtr).TagName := 'P11_c5_cmp';
	vXMLTable(vCtr).TagValue := to_char(l_p11_c5_cmp);
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P11_c5_ant';
	vXMLTable(vCtr).TagValue := to_char(l_p11_c5_ant);
	vCtr := vCtr + 1;

	-- Filling zeroes for Other fields
	vXMLTable(vCtr).TagName := 'P11_c6_cmp';
	vXMLTable(vCtr).TagValue := '0';
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P11_c6_ant';
	vXMLTable(vCtr).TagValue := '0';
	vCtr := vCtr + 1;

/*	vXMLTable(vCtr).TagName := 'P11_d11_avg';
	vXMLTable(vCtr).TagValue := '0';
	vCtr := vCtr + 1;
*/
	vXMLTable(vCtr).TagName := 'P11_c7_cmp';
	vXMLTable(vCtr).TagValue := '0';
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P11_c7_ant';
	vXMLTable(vCtr).TagValue := '0';
	vCtr := vCtr + 1;



	--------- End Multiple Resources
	l_p11_c_cmp := l_p11_c1_cmp + l_p11_c2_cmp + l_p11_c3_cmp + l_total_count + l_p11_c5_cmp;
	l_p11_c_ant := l_p11_c1_ant + l_p11_c2_ant + l_p11_c3_ant + l_tot_prsn + l_p11_c5_ant;

	vXMLTable(vCtr).TagName := 'P11_c_cmp';
	vXMLTable(vCtr).TagValue := to_char(l_p11_c_cmp);
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P11_c_ant';
	vXMLTable(vCtr).TagValue := to_char(l_p11_c_ant);
	vCtr := vCtr + 1;
	fnd_file.put_line(fnd_file.log,'Finished populating Part11 - Resources');
	-- Techniques used
	-- Mediation
	FOR cur_ctr IN cur_techniques(p_from_date, p_to_date,20,'40', p_agency_code) LOOP
		l_p11_d1_cmp := cur_ctr.p11_cnt;
		l_p11_d1_ant := cur_ctr.p11_prsn;
		l_p11_d1_day := cur_ctr.p11_days;
	END LOOP;

	vXMLTable(vCtr).TagName := 'P11_d1_cmp';
	vXMLTable(vCtr).TagValue := to_char(l_p11_d1_cmp);
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P11_d1_ant';
	vXMLTable(vCtr).TagValue := to_char(l_p11_d1_ant);
	vCtr := vCtr + 1;

	IF (l_p11_d1_day IS NULL) THEN
	   l_p11_d1_day := 0;
	END IF;

	vXMLTable(vCtr).TagName := 'P11_d1_day';
	vXMLTable(vCtr).TagValue := to_char(l_p11_d1_day);
	vCtr := vCtr + 1;

	-- Average Days
/*	IF (l_p11_d1_cmp > 0) THEN
		l_P11_d1_avg := CEIL(l_p11_d1_day/l_p11_d1_cmp);
	ELSE
		l_P11_d1_avg := '0';
	END IF;
	vXMLTable(vCtr).TagName := 'P11_d1_avg';
	vXMLTable(vCtr).TagValue := to_char(l_P11_d1_avg);
	vCtr := vCtr + 1;
*/
	-- Settlement Conferences
	FOR cur_ctr IN cur_techniques(p_from_date, p_to_date,20,'100', p_agency_code) LOOP
		l_p11_d2_cmp := cur_ctr.p11_cnt;
		l_p11_d2_ant := cur_ctr.p11_prsn;
		l_p11_d2_day := cur_ctr.p11_days;
	END LOOP;

	vXMLTable(vCtr).TagName := 'P11_d2_cmp';
	vXMLTable(vCtr).TagValue := to_char(l_p11_d2_cmp);
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P11_d2_ant';
	vXMLTable(vCtr).TagValue := to_char(l_p11_d2_ant);
	vCtr := vCtr + 1;

	IF (l_p11_d2_day IS NULL) THEN
	   l_p11_d2_day := 0;
	END IF;


	vXMLTable(vCtr).TagName := 'P11_d2_day';
	vXMLTable(vCtr).TagValue := to_char(l_p11_d2_day);
	vCtr := vCtr + 1;

	-- Average Days
/*	IF (l_p11_d2_cmp > 0) THEN
		l_P11_d2_avg := CEIL(l_p11_d2_day/l_p11_d2_cmp);
	ELSE
		l_P11_d2_avg := '0';
	END IF;
	vXMLTable(vCtr).TagName := 'P11_d2_avg';
	vXMLTable(vCtr).TagValue := to_char(l_P11_d2_avg);
	vCtr := vCtr + 1;
*/
	-- Early Neutral evaluations
	FOR cur_ctr IN cur_techniques(p_from_date, p_to_date,20,'10', p_agency_code) LOOP
		l_p11_d3_cmp := cur_ctr.p11_cnt;
		l_p11_d3_ant := cur_ctr.p11_prsn;
		l_p11_d3_day := cur_ctr.p11_days;
	END LOOP;

	vXMLTable(vCtr).TagName := 'P11_d3_cmp';
	vXMLTable(vCtr).TagValue := to_char(l_p11_d3_cmp);
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P11_d3_ant';
	vXMLTable(vCtr).TagValue := to_char(l_p11_d3_ant);
	vCtr := vCtr + 1;

	IF (l_p11_d3_day IS NULL) THEN
	   l_p11_d3_day := 0;
	END IF;


	vXMLTable(vCtr).TagName := 'P11_d3_day';
	vXMLTable(vCtr).TagValue := to_char(l_p11_d3_day);
	vCtr := vCtr + 1;

	-- Average Days
/*	IF (l_p11_d3_cmp > 0) THEN
		l_P11_d3_avg := CEIL(l_p11_d3_day/l_p11_d3_cmp);
	ELSE
		l_P11_d3_avg := '0';
	END IF;
	vXMLTable(vCtr).TagName := 'P11_d3_avg';
	vXMLTable(vCtr).TagValue := to_char(l_P11_d3_avg);
	vCtr := vCtr + 1;
*/
	-- Factfinding
	FOR cur_ctr IN cur_techniques(p_from_date, p_to_date,20,'30', p_agency_code) LOOP
		l_P11_d4_cmp := cur_ctr.p11_cnt;
		l_p11_d4_ant := cur_ctr.p11_prsn;
		l_p11_d4_day := cur_ctr.p11_days;
	END LOOP;

	vXMLTable(vCtr).TagName := 'P11_d4_cmp';
	vXMLTable(vCtr).TagValue := to_char(l_P11_d4_cmp);
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P11_d4_ant';
	vXMLTable(vCtr).TagValue := to_char(l_p11_d4_ant);
	vCtr := vCtr + 1;

	IF (l_p11_d4_day IS NULL) THEN
	   l_p11_d4_day := 0;
	END IF;


	vXMLTable(vCtr).TagName := 'P11_d4_day';
	vXMLTable(vCtr).TagValue := to_char(l_p11_d4_day);
	vCtr := vCtr + 1;

	-- Average Days
/*	IF (l_P11_d4_cmp > 0) THEN
		l_P11_d4_avg := CEIL(l_p11_d4_day/l_P11_d4_cmp);
	ELSE
		l_P11_d4_avg := '0';
	END IF;
	vXMLTable(vCtr).TagName := 'P11_d4_avg';
	vXMLTable(vCtr).TagValue := to_char(l_P11_d4_avg);
	vCtr := vCtr + 1;
*/
	-- Facilitation
	FOR cur_ctr IN cur_techniques(p_from_date, p_to_date,20,'20', p_agency_code) LOOP
		l_p11_d5_cmp := cur_ctr.p11_cnt;
		l_p11_d5_ant := cur_ctr.p11_prsn;
		l_p11_d5_day := cur_ctr.p11_days;
	END LOOP;

	vXMLTable(vCtr).TagName := 'P11_d5_cmp';
	vXMLTable(vCtr).TagValue := to_char(l_p11_d5_cmp);
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P11_d5_ant';
	vXMLTable(vCtr).TagValue := to_char(l_p11_d5_ant);
	vCtr := vCtr + 1;

	IF (l_p11_d5_day IS NULL) THEN
	   l_p11_d5_day := 0;
	END IF;


	vXMLTable(vCtr).TagName := 'P11_d5_day';
	vXMLTable(vCtr).TagValue := to_char(l_p11_d5_day);
	vCtr := vCtr + 1;

	-- Average Days
/*	IF (l_p11_d5_cmp > 0) THEN
		l_P11_d5_avg := CEIL(l_p11_d5_day/l_p11_d5_cmp);
	ELSE
		l_P11_d5_avg := '0';
	END IF;
	vXMLTable(vCtr).TagName := 'P11_d5_avg';
	vXMLTable(vCtr).TagValue := to_char(l_P11_d5_avg);
	vCtr := vCtr + 1;
*/
	-- Ombudsman
	FOR cur_ctr IN cur_techniques(p_from_date, p_to_date,20,'80', p_agency_code) LOOP
		l_p11_d6_cmp := cur_ctr.p11_cnt;
		l_p11_d6_ant := cur_ctr.p11_prsn;
		l_p11_d6_day := cur_ctr.p11_days;
	END LOOP;

	vXMLTable(vCtr).TagName := 'P11_d6_cmp';
	vXMLTable(vCtr).TagValue := to_char(l_p11_d6_cmp);
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P11_d6_ant';
	vXMLTable(vCtr).TagValue := to_char(l_p11_d6_ant);
	vCtr := vCtr + 1;

	IF (l_p11_d6_day IS NULL) THEN
	   l_p11_d6_day := 0;
	END IF;


	vXMLTable(vCtr).TagName := 'P11_d6_day';
	vXMLTable(vCtr).TagValue := to_char(l_p11_d6_day);
	vCtr := vCtr + 1;

	-- Average Days
/*	IF (l_p11_d6_cmp > 0) THEN
		l_P11_d6_avg := CEIL(l_p11_d6_day/l_p11_d6_cmp);
	ELSE
		l_P11_d6_avg := '0';
	END IF;
	vXMLTable(vCtr).TagName := 'P11_d6_avg';
	vXMLTable(vCtr).TagValue := to_char(l_P11_d6_avg);
	vCtr := vCtr + 1;
*/
	-- Mini-trials
	FOR cur_ctr IN cur_techniques(p_from_date, p_to_date,20,'60', p_agency_code) LOOP
		l_p11_d7_cmp := cur_ctr.p11_cnt;
		l_p11_d7_ant := cur_ctr.p11_prsn;
		l_p11_d7_day := cur_ctr.p11_days;
	END LOOP;

	vXMLTable(vCtr).TagName := 'P11_d7_cmp';
	vXMLTable(vCtr).TagValue := to_char(l_p11_d7_cmp);
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P11_d7_ant';
	vXMLTable(vCtr).TagValue := to_char(l_p11_d7_ant);
	vCtr := vCtr + 1;

	IF (l_p11_d7_day IS NULL) THEN
	   l_p11_d7_day := 0;
	END IF;


	vXMLTable(vCtr).TagName := 'P11_d7_day';
	vXMLTable(vCtr).TagValue := to_char(l_p11_d7_day);
	vCtr := vCtr + 1;

	-- Average Days
/*	IF (l_p11_d7_cmp > 0) THEN
		l_P11_d7_avg := CEIL(l_p11_d7_day/l_p11_d7_cmp);
	ELSE
		l_P11_d7_avg := '0';
	END IF;
	vXMLTable(vCtr).TagName := 'P11_d7_avg';
	vXMLTable(vCtr).TagValue := to_char(l_P11_d7_avg);
	vCtr := vCtr + 1;
*/

	-- Peer review
	FOR cur_ctr IN cur_techniques(p_from_date, p_to_date,20,'90', p_agency_code) LOOP
		l_p11_d8_cmp := cur_ctr.p11_cnt;
		l_p11_d8_ant := cur_ctr.p11_prsn;
		l_p11_d8_day := cur_ctr.p11_days;
	END LOOP;

	vXMLTable(vCtr).TagName := 'P11_d8_cmp';
	vXMLTable(vCtr).TagValue := to_char(l_p11_d8_cmp);
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P11_d8_ant';
	vXMLTable(vCtr).TagValue := to_char(l_p11_d8_ant);
	vCtr := vCtr + 1;

	IF (l_p11_d8_day IS NULL) THEN
	   l_p11_d8_day := 0;
	END IF;

	vXMLTable(vCtr).TagName := 'P11_d8_day';
	vXMLTable(vCtr).TagValue := to_char(l_p11_d8_day);
	vCtr := vCtr + 1;

	-- Average Days
/*	IF (l_p11_d8_cmp > 0) THEN
		l_P11_d8_avg := CEIL(l_p11_d8_day/l_p11_d8_cmp);
	ELSE
		l_P11_d8_avg := '0';
	END IF;
	vXMLTable(vCtr).TagName := 'P11_d8_avg';
	vXMLTable(vCtr).TagValue := to_char(l_P11_d8_avg);
	vCtr := vCtr + 1;
*/
	-- Other

	FOR cur_ctr IN cur_techniques(p_from_date, p_to_date,20,'70', p_agency_code) LOOP
		l_p11_d10_cmp := cur_ctr.p11_cnt;
		l_p11_d10_ant := cur_ctr.p11_prsn;
		l_p11_d10_day := cur_ctr.p11_days;
	END LOOP;

	vXMLTable(vCtr).TagName := 'P11_d10_cmp';
	vXMLTable(vCtr).TagValue := to_char(l_p11_d10_cmp);
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P11_d10_ant';
	vXMLTable(vCtr).TagValue := to_char(l_p11_d10_ant);
	vCtr := vCtr + 1;

	IF (l_p11_d10_day IS NULL) THEN
	   l_p11_d10_day := 0;
	END IF;

	vXMLTable(vCtr).TagName := 'P11_d10_day';
	vXMLTable(vCtr).TagValue := to_char(l_p11_d10_day);
	vCtr := vCtr + 1;

	-- Average Days
/*	IF (l_p11_d10_cmp > 0) THEN
		l_P11_d10_avg := CEIL(l_p11_d10_day/l_p11_d10_cmp);
	ELSE
		l_P11_d10_avg := '0';
	END IF;
	vXMLTable(vCtr).TagName := 'P11_d10_avg';
	vXMLTable(vCtr).TagValue := to_char(l_P11_d10_avg);
	vCtr := vCtr + 1;
*/
	-- Multiple Techniques

	l_total_count := 0;
	l_total_days := 0;
	l_old_cmp_id := 0;
	l_old_days := 0;
	l_ctr := 1;
	v_temp.DELETE;


	FOR cur_ctr IN cur_multitechniques(p_from_date, p_to_date,20, p_agency_code) LOOP
		IF (cur_ctr.technique = '50') THEN
			v_temp(l_ctr).complaint_id := cur_ctr.complaint_id;
			l_total_count := l_total_count + 1;
			l_total_days := l_total_days + cur_ctr.p11_days;
			l_old_cmp_id := cur_ctr.complaint_id;
			l_old_days := cur_ctr.p11_days;
			l_ctr := l_ctr + 1;
		ELSE
			l_new_cmp_id := cur_ctr.complaint_id;
			IF (l_old_cmp_id = l_new_cmp_id) THEN
				-- Search whether entry for the same complaint exist already, if exists update the same.
				l_lb_flag := 0 ;
				IF (v_temp.COUNT > 0) THEN
					FOR l_ctr1 IN v_temp.FIRST .. v_temp.LAST LOOP
					   IF (v_temp(l_ctr1).complaint_id = l_new_cmp_id) THEN
						  l_total_count := l_total_count + 1;
						  l_total_days := l_total_days + cur_ctr.p11_days;
						  l_lb_flag := 1;
					   END IF;
					END LOOP;
				END IF;
				-- If the complaint doesnt exist already, add new entry.
				IF (l_lb_flag = 0) THEN
				    v_temp(l_ctr).complaint_id := cur_ctr.complaint_id;
					l_total_count := l_total_count + 2;
					l_total_days := l_total_days + l_old_days + cur_ctr.p11_days;
				END IF;
			END IF;
			l_old_cmp_id := cur_ctr.complaint_id;
			l_old_days := cur_ctr.p11_days;
		END IF;
	END LOOP;
	-- To Find out the complainants for these complaints
	l_sql_str := '';

	IF (v_temp.COUNT > 0) THEN
		l_sql_str := v_temp(1).complaint_id;
	END IF;

	IF (v_temp.COUNT > 1) THEN
		FOR l_ctr  IN 2 .. v_temp.COUNT LOOP
		   l_sql_str := l_sql_str || ',' || to_char(v_temp(l_ctr).complaint_id);
		END LOOP;
	END IF;
	IF (l_sql_str IS NOT NULL) THEN
		l_sql_str := 'SELECT COUNT(distinct nvl(cmp.complainant_person_id,0)) FROM GHR_COMPLAINTS2 cmp  WHERE cmp.complaint_id in (' || l_sql_str || ')';
		OPEN l_prsn_cur FOR l_sql_str;
		FETCH l_prsn_cur INTO l_tot_prsn;
		CLOSE l_prsn_cur;
	ELSE
		l_tot_prsn := 0;
	END IF;

	--------- End Multiple Techniques

	vXMLTable(vCtr).TagName := 'P11_d9_cmp';
	vXMLTable(vCtr).TagValue := to_char(l_total_count);
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P11_d9_ant';
	vXMLTable(vCtr).TagValue := to_char(l_tot_prsn);
	vCtr := vCtr + 1;

	IF (l_p11_3i_day IS NULL) THEN
	   l_p11_3i_day := 0;
	END IF;

	vXMLTable(vCtr).TagName := 'P11_d9_day';
	vXMLTable(vCtr).TagValue := to_char(l_total_days);
	vCtr := vCtr + 1;

	-- Average Days
/*	IF (l_total_count > 0) THEN
		l_P11_d9_avg := CEIL(l_total_days/l_total_count);
	ELSE
		l_P11_d9_avg := '0';
	END IF;
	vXMLTable(vCtr).TagName := 'P11_d9_avg';
	vXMLTable(vCtr).TagValue := to_char(l_P11_d9_avg);
	vCtr := vCtr + 1;
*/
	-- Filling zeroes for Other fields
	vXMLTable(vCtr).TagName := 'P11_d11_cmp';
	vXMLTable(vCtr).TagValue := '0';
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P11_d11_ant';
	vXMLTable(vCtr).TagValue := '0';
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P11_d11_day';
	vXMLTable(vCtr).TagValue := '0';
	vCtr := vCtr + 1;

/*	vXMLTable(vCtr).TagName := 'P11_d11_avg';
	vXMLTable(vCtr).TagValue := '0';
	vCtr := vCtr + 1;
*/
	vXMLTable(vCtr).TagName := 'P11_d12_cmp';
	vXMLTable(vCtr).TagValue := '0';
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P11_d12_ant';
	vXMLTable(vCtr).TagValue := '0';
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P11_d12_day';
	vXMLTable(vCtr).TagValue := '0';
	vCtr := vCtr + 1;

/*	vXMLTable(vCtr).TagName := 'P11_d12_avg';
	vXMLTable(vCtr).TagValue := '0';
	vCtr := vCtr + 1;
*/
	l_p11_d_cmp :=  l_p11_d1_cmp + l_p11_d2_cmp + l_p11_d3_cmp + l_P11_d4_cmp + l_p11_d5_cmp + l_p11_d6_cmp + l_p11_d7_cmp + l_p11_d8_cmp + l_total_count + l_p11_d10_cmp;
	l_p11_d_ant := l_p11_d1_ant + l_p11_d2_ant + l_p11_d3_ant + l_p11_d4_ant + l_p11_d5_ant + l_p11_d6_ant + l_p11_d7_ant + l_p11_d8_ant + l_tot_prsn + l_p11_d10_ant;
	l_p11_d_day := l_p11_d1_day + l_p11_d2_day + l_p11_d3_day + l_p11_d4_day + l_p11_d5_day + l_p11_d6_day + l_p11_d7_day + l_p11_d8_day + l_total_days + l_p11_d10_day;
	l_p11_d_avg := l_p11_d1_avg + l_p11_d2_avg + l_p11_d3_avg + l_p11_d4_avg + l_p11_d5_avg + l_p11_d6_avg + l_p11_d7_avg + l_p11_d8_avg + l_p11_d9_avg + l_p11_d10_avg;

	vXMLTable(vCtr).TagName := 'P11_d_cmp';
	vXMLTable(vCtr).TagValue := to_char(l_p11_d_cmp);
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P11_d_ant';
	vXMLTable(vCtr).TagValue := to_char(l_p11_d_ant);
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P11_d_day';
	vXMLTable(vCtr).TagValue := to_char(l_p11_d_day);
	vCtr := vCtr + 1;

/*	vXMLTable(vCtr).TagName := 'P11_d_avg';
	vXMLTable(vCtr).TagValue := to_char(l_p11_d_avg);
	vCtr := vCtr + 1;
*/
		fnd_file.put_line(fnd_file.log,'Finished populating Part11 - Techniques');
	-- Status of Cases
	-- Settlement with benefits
	FOR cur_ctr IN cur_case_status_settle(p_from_date, p_to_date,20, p_agency_code) LOOP
		l_p11_e1a_cmp := cur_ctr.p11_cnt;
		l_p11_e1a_ant := cur_ctr.p11_prsn;
		l_p11_e1a_day := cur_ctr.p11_days;
	END LOOP;

	vXMLTable(vCtr).TagName := 'P11_e1a_cmp';
	vXMLTable(vCtr).TagValue := to_char(l_p11_e1a_cmp);
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P11_e1a_ant';
	vXMLTable(vCtr).TagValue := to_char(l_p11_e1a_ant);
	vCtr := vCtr + 1;

	IF (l_p11_e1a_day IS NULL) THEN
	   l_p11_e1a_day := 0;
	END IF;


	vXMLTable(vCtr).TagName := 'P11_e1a_day';
	vXMLTable(vCtr).TagValue := to_char(l_p11_e1a_day);
	vCtr := vCtr + 1;

	-- Average Days
/*	IF (l_p11_e1a_cmp > 0) THEN
		l_P11_e1a_avg := CEIL(l_p11_e1a_day/l_p11_e1a_cmp);
	ELSE
		l_P11_e1a_avg := 0;
	END IF;
	vXMLTable(vCtr).TagName := 'P11_e1a_avg';
	vXMLTable(vCtr).TagValue := to_char(l_P11_e1a_avg);
	vCtr := vCtr + 1;
*/
	-- Withdrawals
	FOR cur_ctr IN cur_case_status(p_from_date, p_to_date,20,'170', p_agency_code) LOOP
		l_p11_e1b_cmp := cur_ctr.p11_cnt;
		l_p11_e1b_ant := cur_ctr.p11_prsn;
		l_p11_e1b_day := cur_ctr.p11_days;
	END LOOP;

	vXMLTable(vCtr).TagName := 'P11_e1b_cmp';
	vXMLTable(vCtr).TagValue := to_char(l_p11_e1b_cmp);
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P11_e1b_ant';
	vXMLTable(vCtr).TagValue := to_char(l_p11_e1b_ant);
	vCtr := vCtr + 1;

	IF (l_p11_e1b_day IS NULL) THEN
	   l_p11_e1b_day := 0;
	END IF;


	vXMLTable(vCtr).TagName := 'P11_e1b_day';
	vXMLTable(vCtr).TagValue := to_char(l_p11_e1b_day);
	vCtr := vCtr + 1;

	-- Average Days
/*	IF (l_p11_e1b_cmp > 0) THEN
		l_P11_e1b_avg := CEIL(l_p11_e1b_day/l_p11_e1b_cmp);
	ELSE
		l_P11_e1b_avg := 0;
	END IF;
	vXMLTable(vCtr).TagName := 'P11_e1b_avg';
	vXMLTable(vCtr).TagValue := to_char(l_P11_e1b_avg);
	vCtr := vCtr + 1;
*/
	-- No Resolution
	FOR cur_ctr IN cur_case_status(p_from_date, p_to_date,20,'220', p_agency_code) LOOP
		l_p11_e1c_cmp := cur_ctr.p11_cnt;
		l_p11_e1c_ant := cur_ctr.p11_prsn;
		l_p11_e1c_day := cur_ctr.p11_days;
	END LOOP;

	vXMLTable(vCtr).TagName := 'P11_e1c_cmp';
	vXMLTable(vCtr).TagValue := to_char(l_p11_e1c_cmp);
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P11_e1c_ant';
	vXMLTable(vCtr).TagValue := to_char(l_p11_e1c_ant);
	vCtr := vCtr + 1;

	IF (l_p11_e1c_day IS NULL) THEN
	   l_p11_e1c_day := 0;
	END IF;

	vXMLTable(vCtr).TagName := 'P11_e1c_day';
	vXMLTable(vCtr).TagValue := to_char(l_p11_e1c_day);
	vCtr := vCtr + 1;

	-- Average Days
/*	IF (l_p11_e1c_cmp > 0) THEN
		l_P11_e1c_avg := CEIL(l_p11_e1c_day/l_p11_e1c_cmp);
	ELSE
		l_P11_e1c_avg := 0;
	END IF;
	vXMLTable(vCtr).TagName := 'P11_e1c_avg';
	vXMLTable(vCtr).TagValue := to_char(l_P11_e1c_avg);
	vCtr := vCtr + 1;
*/

	-- Other
	FOR cur_ctr IN cur_case_status(p_from_date, p_to_date,20,'230', p_agency_code) LOOP
		l_p11_e1d_cmp := cur_ctr.p11_cnt;
		l_p11_e1d_ant := cur_ctr.p11_prsn;
		l_p11_e1d_day := cur_ctr.p11_days;
	END LOOP;

	vXMLTable(vCtr).TagName := 'P11_e1d_cmp';
	vXMLTable(vCtr).TagValue := to_char(l_p11_e1d_cmp);
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P11_e1d_ant';
	vXMLTable(vCtr).TagValue := to_char(l_p11_e1d_ant);
	vCtr := vCtr + 1;

	IF (l_p11_e1d_day IS NULL) THEN
	   l_p11_e1d_day := 0;
	END IF;

	vXMLTable(vCtr).TagName := 'P11_e1d_day';
	vXMLTable(vCtr).TagValue := to_char(l_p11_e1d_day);
	vCtr := vCtr + 1;

	-- Average Days
/*	IF (l_p11_e1d_cmp > 0) THEN
		l_P11_e1d_avg := CEIL(l_p11_e1d_day/l_p11_e1d_cmp);
	ELSE
		l_P11_e1d_avg := 0;
	END IF;
	vXMLTable(vCtr).TagName := 'P11_e1d_avg';
	vXMLTable(vCtr).TagValue := to_char(l_P11_e1d_avg);
	vCtr := vCtr + 1;
*/
	-- Filling zeroes for other fields

	vXMLTable(vCtr).TagName := 'P11_e1e_cmp';
	vXMLTable(vCtr).TagValue := '0';
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P11_e1e_ant';
	vXMLTable(vCtr).TagValue := '0';
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P11_e1e_day';
	vXMLTable(vCtr).TagValue := '0';
	vCtr := vCtr + 1;

/*	vXMLTable(vCtr).TagName := 'P11_e1e_avg';
	vXMLTable(vCtr).TagValue := '0';
	vCtr := vCtr + 1;
*/
	vXMLTable(vCtr).TagName := 'P11_e1f_cmp';
	vXMLTable(vCtr).TagValue := '0';
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P11_e1f_ant';
	vXMLTable(vCtr).TagValue := '0';
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P11_e1f_day';
	vXMLTable(vCtr).TagValue := '0';
	vCtr := vCtr + 1;

/*	vXMLTable(vCtr).TagName := 'P11_e1f_avg';
	vXMLTable(vCtr).TagValue := '0';
	vCtr := vCtr + 1;
*/
	-- Total Closed
	l_p11_e1_cmp := l_p11_e1a_cmp + l_p11_e1b_cmp + l_p11_e1c_cmp + l_p11_e1d_cmp;
	l_p11_e1_ant := l_p11_e1a_ant + l_p11_e1b_ant + l_p11_e1c_ant + l_p11_e1d_ant;
	l_p11_e1_day := l_p11_e1a_day + l_p11_e1b_day + l_p11_e1c_day + l_p11_e1d_day;
	l_p11_e1_avg := l_p11_e1a_avg + l_p11_e1b_avg + l_p11_e1c_avg + l_p11_e1d_avg;

	vXMLTable(vCtr).TagName := 'P11_e1_cmp';
	vXMLTable(vCtr).TagValue := to_char(l_p11_e1_cmp);
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P11_e1_ant';
	vXMLTable(vCtr).TagValue := to_char(l_p11_e1_ant);
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P11_e1_day';
	vXMLTable(vCtr).TagValue := to_char(l_p11_e1_day);
	vCtr := vCtr + 1;

/*	vXMLTable(vCtr).TagName := 'P11_e1_avg';
	vXMLTable(vCtr).TagValue := to_char(l_p11_e1_avg);
	vCtr := vCtr + 1;
*/
	fnd_file.put_line(fnd_file.log,'Finished populating Part11 - Closed Status');
	-- Open inventory
	-- Result of (A + B4 - E1)

	/*(FOR cur_ctr IN cur_open_inventory(p_from_date, p_to_date,'20', p_agency_code) LOOP
		l_p11_e2_cmp := cur_ctr.p11_cnt;
		l_p11_e2_ant := cur_ctr.p11_prsn;
		l_p11_e2_day := cur_ctr.p11_days;
	END LOOP; */
	l_p11_e2_cmp := l_p11_a_cmp + l_p11_b4_cmp - l_p11_e1_cmp;
	l_p11_e2_ant := l_p11_a_ant + l_p11_b4_ant - l_p11_e1_ant;
	l_p11_e2_day := l_p11_a_day + l_p11_b4_day - l_p11_e1_day;

	vXMLTable(vCtr).TagName := 'P11_e2_cmp';
	vXMLTable(vCtr).TagValue := to_char(l_p11_e2_cmp);
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P11_e2_ant';
	vXMLTable(vCtr).TagValue := to_char(l_p11_e2_ant);
	vCtr := vCtr + 1;

	IF (l_p11_e2_day IS NULL) THEN
		l_p11_e2_day := 0;
	END IF;

	vXMLTable(vCtr).TagName := 'P11_e2_day';
	vXMLTable(vCtr).TagValue := to_char(l_p11_e2_day);
	vCtr := vCtr + 1;

	-- Average Days
/*	IF (l_p11_e2_cmp > 0) THEN
		l_P11_e2_avg := CEIL(l_p11_e2_day/l_p11_e2_cmp);
	ELSE
		l_P11_e2_avg := 0;
	END IF;
	vXMLTable(vCtr).TagName := 'P11_e2_avg';
	vXMLTable(vCtr).TagValue := to_char(l_P11_e2_avg);
	vCtr := vCtr + 1;
*/

	fnd_file.put_line(fnd_file.log,'Finished populating Part11 - Open Inventory');
	-- Benefits Received
	-- Compensatory Damages
	FOR cur_ctr IN cur_benefits_pt2(p_from_date, p_to_date,20,'30','30','40', p_agency_code) LOOP
		l_p11_f1a_cmp := cur_ctr.p11_cnt;
		l_p11_f1a_ant := cur_ctr.p11_prsn;
		l_p11_f1a_amt := cur_ctr.p11_amt;
	END LOOP;

	vXMLTable(vCtr).TagName := 'P11_f1a_cmp';
	vXMLTable(vCtr).TagValue := to_char(l_p11_f1a_cmp);
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P11_f1a_ant';
	vXMLTable(vCtr).TagValue := to_char(l_p11_f1a_ant);
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P11_f1a_amt';
	vXMLTable(vCtr).TagValue := to_char(l_p11_f1a_amt);
	vCtr := vCtr + 1;

	-- BackPay and front pay
	FOR cur_ctr IN cur_benefits(p_from_date, p_to_date,20,'30','20', p_agency_code) LOOP
		l_p11_f1b_cmp := cur_ctr.p11_cnt;
		l_p11_f1b_ant := cur_ctr.p11_prsn;
		l_p11_f1b_amt := cur_ctr.p11_amt;
	END LOOP;

	vXMLTable(vCtr).TagName := 'P11_f1b_cmp';
	vXMLTable(vCtr).TagValue := to_char(l_p11_f1b_cmp);
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P11_f1b_ant';
	vXMLTable(vCtr).TagValue := to_char(l_p11_f1b_ant);
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P11_f1b_amt';
	vXMLTable(vCtr).TagValue := to_char(l_p11_f1b_amt);
	vCtr := vCtr + 1;

	-- Lump Sum
	FOR cur_ctr IN cur_benefits(p_from_date, p_to_date,20,'30','50', p_agency_code) LOOP
		l_p11_f1c_cmp := cur_ctr.p11_cnt;
		l_p11_f1c_ant := cur_ctr.p11_prsn;
		l_p11_f1c_amt := cur_ctr.p11_amt;
	END LOOP;

	vXMLTable(vCtr).TagName := 'P11_f1c_cmp';
	vXMLTable(vCtr).TagValue := to_char(l_p11_f1c_cmp);
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P11_f1c_ant';
	vXMLTable(vCtr).TagValue := to_char(l_p11_f1c_ant);
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P11_f1c_amt';
	vXMLTable(vCtr).TagValue := to_char(l_p11_f1c_amt);
	vCtr := vCtr + 1;

	-- Attorney's fees and costs
	FOR cur_ctr IN cur_benefits(p_from_date, p_to_date,20,'30','10', p_agency_code) LOOP
		l_p11_f1d_cmp := cur_ctr.p11_cnt;
		l_p11_f1d_ant := cur_ctr.p11_prsn;
		l_p11_f1d_amt := cur_ctr.p11_amt;
	END LOOP;

	vXMLTable(vCtr).TagName := 'P11_f1d_cmp';
	vXMLTable(vCtr).TagValue := to_char(l_p11_f1d_cmp);
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P11_f1d_ant';
	vXMLTable(vCtr).TagValue := to_char(l_p11_f1d_ant);
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P11_f1d_amt';
	vXMLTable(vCtr).TagValue := to_char(l_p11_f1d_amt);
	vCtr := vCtr + 1;

	-- Other
	FOR cur_ctr IN cur_benefits(p_from_date, p_to_date,20,'30','60', p_agency_code) LOOP
		l_p11_f1e_cmp := cur_ctr.p11_cnt;
		l_p11_f1e_ant := cur_ctr.p11_prsn;
		l_p11_f1e_amt := cur_ctr.p11_amt;
	END LOOP;

	vXMLTable(vCtr).TagName := 'P11_f1e_cmp';
	vXMLTable(vCtr).TagValue := to_char(l_p11_f1e_cmp);
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P11_f1e_ant';
	vXMLTable(vCtr).TagValue := to_char(l_p11_f1e_ant);
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P11_f1e_amt';
	vXMLTable(vCtr).TagValue := to_char(l_p11_f1e_amt);
	vCtr := vCtr + 1;

	-- Filling zeroes for other fields

	vXMLTable(vCtr).TagName := 'P11_f1f_cmp';
	vXMLTable(vCtr).TagValue := '0';
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P11_f1f_ant';
	vXMLTable(vCtr).TagValue := '0';
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P11_f1f_amt';
	vXMLTable(vCtr).TagValue := '0';
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P11_f1g_cmp';
	vXMLTable(vCtr).TagValue := '0';
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P11_f1g_ant';
	vXMLTable(vCtr).TagValue := '0';
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P11_f1g_amt';
	vXMLTable(vCtr).TagValue := '0';
	vCtr := vCtr + 1;


	-- Total
	FOR cur_ctr IN cur_tot_benefits(p_from_date, p_to_date,20,'30', p_agency_code) LOOP
		l_p11_f1_cmp := cur_ctr.p11_cnt;
		l_p11_f1_ant := cur_ctr.p11_prsn;
	END LOOP;
--	l_p11_f1_cmp := l_p11_f1a_cmp + l_p11_f1b_cmp + l_p11_f1c_cmp + l_p11_f1d_cmp + l_p11_f1e_cmp;
--	l_p11_f1_ant := l_p11_f1a_ant + l_p11_f1b_ant + l_p11_f1c_ant + l_p11_f1d_ant + l_p11_f1e_ant;
	l_p11_f1_amt := l_p11_f1a_amt + l_p11_f1b_amt + l_p11_f1c_amt + l_p11_f1d_amt + l_p11_f1e_amt;

	vXMLTable(vCtr).TagName := 'P11_f1_cmp';
	vXMLTable(vCtr).TagValue := to_char(l_p11_f1_cmp);
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P11_f1_ant';
	vXMLTable(vCtr).TagValue := to_char(l_p11_f1_ant);
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P11_f1_amt';
	vXMLTable(vCtr).TagValue := to_char(l_p11_f1_amt);
	vCtr := vCtr + 1;
	fnd_file.put_line(fnd_file.log,'Finished populating Part11 - Benefits Received Monetary');
	-- Non-Monetary
	-- New Hires
	FOR cur_ctr IN cur_benefits_nm_pt2(p_from_date, p_to_date,20,'30','70','80', p_agency_code) LOOP
		l_p11_f2a_cmp := cur_ctr.p11_cnt;
		l_p11_f2a_ant := cur_ctr.p11_prsn;
	END LOOP;

	vXMLTable(vCtr).TagName := 'P11_f2a_cmp';
	vXMLTable(vCtr).TagValue := to_char(l_p11_f2a_cmp);
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P11_f2a_ant';
	vXMLTable(vCtr).TagValue := to_char(l_p11_f2a_ant);
	vCtr := vCtr + 1;

	-- Promotions
	FOR cur_ctr IN cur_benefits_nm_pt2(p_from_date, p_to_date,20,'30','130','140', p_agency_code) LOOP
		l_p11_f2b_cmp := cur_ctr.p11_cnt;
		l_p11_f2b_ant := cur_ctr.p11_prsn;
	END LOOP;

	vXMLTable(vCtr).TagName := 'P11_f2b_cmp';
	vXMLTable(vCtr).TagValue := to_char(l_p11_f2b_cmp);
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P11_f2b_ant';
	vXMLTable(vCtr).TagValue := to_char(l_p11_f2b_ant);
	vCtr := vCtr + 1;

	-- Reinstatements
	FOR cur_ctr IN cur_benefits_nm(p_from_date, p_to_date,20,'30','160', p_agency_code) LOOP
		l_p11_f2c_cmp := cur_ctr.p11_cnt;
		l_p11_f2c_ant := cur_ctr.p11_prsn;
	END LOOP;

	vXMLTable(vCtr).TagName := 'P11_f2c_cmp';
	vXMLTable(vCtr).TagValue := to_char(l_p11_f2c_cmp);
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P11_f2c_ant';
	vXMLTable(vCtr).TagValue := to_char(l_p11_f2c_ant);
	vCtr := vCtr + 1;

	-- Expungements
	FOR cur_ctr IN cur_benefits_nm(p_from_date, p_to_date,20,'30','60', p_agency_code) LOOP
		l_p11_f2d_cmp := cur_ctr.p11_cnt;
		l_p11_f2d_ant := cur_ctr.p11_prsn;
	END LOOP;

	vXMLTable(vCtr).TagName := 'P11_f2d_cmp';
	vXMLTable(vCtr).TagValue := to_char(l_p11_f2d_cmp);
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P11_f2d_ant';
	vXMLTable(vCtr).TagValue := to_char(l_p11_f2d_ant);
	vCtr := vCtr + 1;

	-- Transfers
	FOR cur_ctr IN cur_benefits_nm(p_from_date, p_to_date,20,'30','190', p_agency_code) LOOP
		l_p11_f2e_cmp := cur_ctr.p11_cnt;
		l_p11_f2e_ant := cur_ctr.p11_prsn;
	END LOOP;

	vXMLTable(vCtr).TagName := 'P11_f2e_cmp';
	vXMLTable(vCtr).TagValue := to_char(l_p11_f2e_cmp);
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P11_f2e_ant';
	vXMLTable(vCtr).TagValue := to_char(l_p11_f2e_ant);
	vCtr := vCtr + 1;

	-- Removals Rescinded and Voluntary Resignations
	FOR cur_ctr IN cur_benefits_nm(p_from_date, p_to_date,20,'30','170', p_agency_code) LOOP
		l_p11_5b6_cmp := cur_ctr.p11_cnt;
		l_P11_f2f_ant := cur_ctr.p11_prsn;
	END LOOP;

	vXMLTable(vCtr).TagName := 'P11_f2f_cmp';
	vXMLTable(vCtr).TagValue := to_char(l_p11_5b6_cmp);
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P11_f2f_ant';
	vXMLTable(vCtr).TagValue := to_char(l_P11_f2f_ant);
	vCtr := vCtr + 1;

	-- Reasonable accomodations
	FOR cur_ctr IN cur_benefits_nm(p_from_date, p_to_date,20,'30','10', p_agency_code) LOOP
		l_p11_f2g_cmp := cur_ctr.p11_cnt;
		l_p11_f2g_ant := cur_ctr.p11_prsn;
	END LOOP;

	vXMLTable(vCtr).TagName := 'P11_f2g_cmp';
	vXMLTable(vCtr).TagValue := to_char(l_p11_f2g_cmp);
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P11_f2g_ant';
	vXMLTable(vCtr).TagValue := to_char(l_p11_f2g_ant);
	vCtr := vCtr + 1;


	-- Training
	FOR cur_ctr IN cur_benefits_nm(p_from_date, p_to_date,20,'30','180', p_agency_code) LOOP
		l_p11_f2h_cmp := cur_ctr.p11_cnt;
		l_p11_f2h_ant := cur_ctr.p11_prsn;
	END LOOP;

	vXMLTable(vCtr).TagName := 'P11_f2h_cmp';
	vXMLTable(vCtr).TagValue := to_char(l_p11_f2h_cmp);
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P11_f2h_ant';
	vXMLTable(vCtr).TagValue := to_char(l_p11_f2h_ant);
	vCtr := vCtr + 1;

	-- Apology

	FOR cur_ctr IN cur_benefits_nm(p_from_date, p_to_date,20,'30','20', p_agency_code) LOOP
		l_p11_f2i_cmp := cur_ctr.p11_cnt;
		l_p11_f2i_ant := cur_ctr.p11_prsn;
	END LOOP;

	vXMLTable(vCtr).TagName := 'P11_f2i_cmp';
	vXMLTable(vCtr).TagValue := to_char(l_p11_f2i_cmp);
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P11_f2i_ant';
	vXMLTable(vCtr).TagValue := to_char(l_p11_f2i_ant);
	vCtr := vCtr + 1;

	-- Other

	FOR cur_ctr IN cur_benefits_nm(p_from_date, p_to_date,20,'30','100', p_agency_code) LOOP
		l_p11_f2j_cmp := cur_ctr.p11_cnt;
		l_p11_f2j_ant := cur_ctr.p11_prsn;
	END LOOP;

	vXMLTable(vCtr).TagName := 'P11_f2j_cmp';
	vXMLTable(vCtr).TagValue := to_char(l_p11_f2j_cmp);
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P11_f2j_ant';
	vXMLTable(vCtr).TagValue := to_char(l_p11_f2j_ant);
	vCtr := vCtr + 1;



	vXMLTable(vCtr).TagName := 'P11_f2k_cmp';
	vXMLTable(vCtr).TagValue := '0';
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P11_f2k_ant';
	vXMLTable(vCtr).TagValue := '0';
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P11_f2l_cmp';
	vXMLTable(vCtr).TagValue := '0';
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P11_f2l_ant';
	vXMLTable(vCtr).TagValue := '0';
	vCtr := vCtr + 1;


/*	l_p11_f2_cmp := l_p11_f2a_cmp + l_p11_f2b_cmp + l_p11_f2c_cmp + l_p11_f2d_cmp + l_p11_f2e_cmp + l_p11_5b6_cmp +
						l_p11_f2g_cmp + l_p11_f2h_cmp + l_p11_f2i_cmp;
	l_p11_f2_ant := l_p11_f2a_ant + l_p11_f2b_ant + l_p11_f2c_ant + l_p11_f2d_ant + l_p11_f2e_ant + l_P11_f2f_ant +
						l_p11_f2g_ant + l_p11_f2h_ant + l_p11_f2i_ant; */

	-- Total Complaints and Complainants

	FOR cur_ctr IN cur_tot_benefits_nm(p_from_date, p_to_date,20,'30', p_agency_code) LOOP
		l_p11_f2_cmp := cur_ctr.p11_cnt;
		l_p11_f2_ant := cur_ctr.p11_prsn;
	END LOOP;

	vXMLTable(vCtr).TagName := 'P11_f2_cmp';
	vXMLTable(vCtr).TagValue := to_char(l_p11_f2_cmp);
	vCtr := vCtr + 1;

	vXMLTable(vCtr).TagName := 'P11_f2_ant';
	vXMLTable(vCtr).TagValue := to_char(l_p11_f2_ant);
	vCtr := vCtr + 1;
	fnd_file.put_line(fnd_file.log,'Finished populating Part11 - Benefits received Non Monetary');
	fnd_file.put_line(fnd_file.log,'------------End of Part11 ----------------');
END populate_part11;

PROCEDURE WritetoXML (
	p_request_id in number,
	p_agency_code   in varchar,
	p_fiscal_year in number,
    p_from_date   in date,
	p_to_date     in date,
	p_output_fname out nocopy varchar2)
IS
	p_l_fp UTL_FILE.FILE_TYPE;
	l_audit_log_dir varchar2(500) := '/sqlcom/outbound';
	l_file_name varchar2(50);
	l_agency_name varchar2(500);
	l_check_flag number;
BEGIN
	-----------------------------------------------------------------------------
	-- Writing into XML File
	-----------------------------------------------------------------------------
	-- Assigning the File name.
	l_file_name :=  to_char(p_request_id) || '.xml';
	-- Getting the Util file directory name.mostly it'll be /sqlcom/outbound )
	BEGIN
		SELECT value
		INTO l_audit_log_dir
		FROM v$parameter
		WHERE LOWER(name) = 'utl_file_dir';
		-- Check whether more than one util file directory is found
		IF INSTR(l_audit_log_dir,',') > 0 THEN
		   l_audit_log_dir := substr(l_audit_log_dir,1,instr(l_audit_log_dir,',')-1);
		END IF;
	EXCEPTION
		when no_data_found then
			null;
	END;
	-- Find out whether the OS is MS or Unix based
	-- If it's greater than 0, it's unix based environment
	IF INSTR(l_audit_log_dir,'/') > 0 THEN
		p_output_fname := l_audit_log_dir || '/' || l_file_name;
	ELSE
        p_output_fname := l_audit_log_dir || '\' || l_file_name;
	END IF;

	-- getting Agency name
	BEGIN
		SELECT meaning
		INTO l_agency_name
		FROM hr_lookups
		WHERE lookup_type = 'GHR_US_AGENCY_CODE_2'
		AND lookup_code = p_agency_code;
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
			l_agency_name := NULL;
	END;
	p_l_fp := utl_file.fopen(l_audit_log_dir,l_file_name,'w');
	utl_file.put_line(p_l_fp,'<?xml version="1.0" encoding="UTF-8"?>');
	utl_file.put_line(p_l_fp,'<xfdf xmlns="http://ns.adobe.com/xfdf/" xml:space="preserve">');
	-- Writing from and to dates
	utl_file.put_line(p_l_fp,'<fields>');
	-- Write the header fields to XML File.
	WriteXMLvalues(p_l_fp,'P0_from_date',to_char(p_from_date,'dd') || ' ' || trim(to_char(p_from_date,'Month')) || ' ' || to_char(p_from_date,'yyyy') );
	WriteXMLvalues(p_l_fp,'P0_to_date',to_char(p_to_date,'dd') || ' ' ||to_char(p_to_date,'Month') || ' ' || to_char(p_to_date,'yyyy') );
	WriteXMLvalues(p_l_fp,'P0_agency',l_agency_name);
	WriteXMLvalues(p_l_fp,'P0_year',p_fiscal_year);
	-- Loop through PL/SQL Table and write the values into the XML File.
	-- Need to try FORALL instead of FOR
	FOR ctr_table IN vXMLTable.FIRST .. vXMLTable.LAST LOOP
		WriteXMLvalues(p_l_fp,vXMLTable(ctr_table).TagName ,vXMLTable(ctr_table).TagValue);
	END LOOP;
	-- Write the end tag and close the XML File.
	utl_file.put_line(p_l_fp,'</fields>');
	utl_file.put_line(p_l_fp,'</xfdf>');
	utl_file.fclose(p_l_fp);

END WritetoXML;

PROCEDURE WriteXMLvalues(p_l_fp utl_file.file_type,p_tagname IN VARCHAR2, p_value IN VARCHAR2) IS
BEGIN
	-- Writing XML Tag and values to XML File
--	utl_file.put_line(p_l_fp,'<' || p_tagname || '>' || p_value || '</' || p_tagname || '>'  );
	-- New Format XFDF
	utl_file.put_line(p_l_fp,'<field name="' || p_tagname || '">');
	utl_file.put_line(p_l_fp,'<value>' || p_value || '</value>'  );
	utl_file.put_line(p_l_fp,'</field>');
END WriteXMLvalues;



PROCEDURE PopulatePart4Matrix
IS
v_ctr number := 1;
BEGIN
		-------- Claims : Appointment Bases : Race
	v_P4Matrix(v_ctr).claims := '10';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_RC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '10';
	v_P4Matrix(v_ctr).fieldname:= 'P4_a1';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '10';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_RC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '20';
	v_P4Matrix(v_ctr).fieldname:= 'P4_a2';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '10';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_RC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '30';
	v_P4Matrix(v_ctr).fieldname:= 'P4_a3';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '10';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_RC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '40';
	v_P4Matrix(v_ctr).fieldname:= 'P4_a4';
	v_ctr := v_ctr + 1;

	------- Claims : Appointment Bases: Color
	v_P4Matrix(v_ctr).claims := '10';
	v_P4Matrix(v_ctr).bases := 'YES_NO';
	v_P4Matrix(v_ctr).basevalues := NULL;
	v_P4Matrix(v_ctr).fieldname:= 'P4_a5';
	v_ctr := v_ctr + 1;

	-------- Claims : Appointment Bases : Religion
	v_P4Matrix(v_ctr).claims := '10';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_REL_BASIS';
	v_P4Matrix(v_ctr).basevalues := NULL;
	v_P4Matrix(v_ctr).fieldname:= 'P4_a6';
	v_ctr := v_ctr + 1;

	-------- Claims : Appointment Bases : Reprisal
	v_P4Matrix(v_ctr).claims := '10';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_REP_BASIS';
	v_P4Matrix(v_ctr).basevalues := NULL;
	v_P4Matrix(v_ctr).fieldname:= 'P4_a7';
	v_ctr := v_ctr + 1;

	-------- Claims : Appointment Bases : Sex
	v_P4Matrix(v_ctr).claims := '10';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_SEX_BASIS';
	v_P4Matrix(v_ctr).basevalues := '10';
	v_P4Matrix(v_ctr).fieldname:= 'P4_a8';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '10';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_SEX_BASIS';
	v_P4Matrix(v_ctr).basevalues := '20';
	v_P4Matrix(v_ctr).fieldname:= 'P4_a9';
	v_ctr := v_ctr + 1;

	-------- Claims : Appointment Bases : National Origin
	v_P4Matrix(v_ctr).claims := '10';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_NO_BASIS';
	v_P4Matrix(v_ctr).basevalues := '10';
	v_P4Matrix(v_ctr).fieldname:= 'P4_a10';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '10';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_NO_BASIS';
	v_P4Matrix(v_ctr).basevalues := '20';
	v_P4Matrix(v_ctr).fieldname:= 'P4_a11';
	v_ctr := v_ctr + 1;

	-------- No Equal pact (columns k and l) for appointment
	---- Claims : Appointment Bases : National Origin
	v_P4Matrix(v_ctr).claims := '10';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_AGE_BASIS';
	v_P4Matrix(v_ctr).basevalues := NULL;
	v_P4Matrix(v_ctr).fieldname:= 'P4_a14';
	v_ctr := v_ctr + 1;

	---- Claims : Appointment Bases : Disability
	v_P4Matrix(v_ctr).claims := '10';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_HC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '10';
	v_P4Matrix(v_ctr).fieldname:= 'P4_a15';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '10';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_HC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '20';
	v_P4Matrix(v_ctr).fieldname:= 'P4_a16';
	v_ctr := v_ctr + 1;

	-- End of Claim Appointment


	-------- Claims : Assignment of Duties Bases : Race
	v_P4Matrix(v_ctr).claims := '20';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_RC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '10';
	v_P4Matrix(v_ctr).fieldname:= 'P4_b1';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '20';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_RC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '20';
	v_P4Matrix(v_ctr).fieldname:= 'P4_b2';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '20';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_RC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '30';
	v_P4Matrix(v_ctr).fieldname:= 'P4_b3';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '20';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_RC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '40';
	v_P4Matrix(v_ctr).fieldname:= 'P4_b4';
	v_ctr := v_ctr + 1;


	------- Claims : Assignment of Duties Bases: Color
	v_P4Matrix(v_ctr).claims := '20';
	v_P4Matrix(v_ctr).bases := 'YES_NO';
	v_P4Matrix(v_ctr).basevalues := NULL;
	v_P4Matrix(v_ctr).fieldname:= 'P4_b5';
	v_ctr := v_ctr + 1;


	-------- Claims : Assignment of Duties Bases : Religion
	v_P4Matrix(v_ctr).claims := '20';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_REL_BASIS';
	v_P4Matrix(v_ctr).basevalues := NULL;
	v_P4Matrix(v_ctr).fieldname:= 'P4_b6';
	v_ctr := v_ctr + 1;

	-------- Claims : Assignment of Duties Bases : Reprisal
	v_P4Matrix(v_ctr).claims := '20';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_REP_BASIS';
	v_P4Matrix(v_ctr).basevalues := NULL;
	v_P4Matrix(v_ctr).fieldname:= 'P4_b7';
	v_ctr := v_ctr + 1;

	-------- Claims : Assignment of Duties Bases : Sex
	v_P4Matrix(v_ctr).claims := '20';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_SEX_BASIS';
	v_P4Matrix(v_ctr).basevalues := '10';
	v_P4Matrix(v_ctr).fieldname:= 'P4_b8';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '20';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_SEX_BASIS';
	v_P4Matrix(v_ctr).basevalues := '20';
	v_P4Matrix(v_ctr).fieldname:= 'P4_b9';
	v_ctr := v_ctr + 1;

	-------- Claims : Assignment of Duties Bases : National Origin
	v_P4Matrix(v_ctr).claims := '20';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_NO_BASIS';
	v_P4Matrix(v_ctr).basevalues := '10';
	v_P4Matrix(v_ctr).fieldname:= 'P4_b10';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '20';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_NO_BASIS';
	v_P4Matrix(v_ctr).basevalues := '20';
	v_P4Matrix(v_ctr).fieldname:= 'P4_b11';
	v_ctr := v_ctr + 1;

	-------- No Equal pact (columns k and l) for Assignment of Duties
	---- Claims : Assignment of Duties Bases : National Origin
	v_P4Matrix(v_ctr).claims := '20';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_AGE_BASIS';
	v_P4Matrix(v_ctr).basevalues := NULL;
	v_P4Matrix(v_ctr).fieldname:= 'P4_b14';
	v_ctr := v_ctr + 1;

	---- Claims : Assignment of Duties Bases : Disability
	v_P4Matrix(v_ctr).claims := '20';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_HC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '10';
	v_P4Matrix(v_ctr).fieldname:= 'P4_b15';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '20';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_HC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '20';
	v_P4Matrix(v_ctr).fieldname:= 'P4_b16';
	v_ctr := v_ctr + 1;

	-- End of Claim Assignment of Duties


	----------------------------------------
	-------- Claims : Awards Bases : Race
	v_P4Matrix(v_ctr).claims := '30';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_RC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '10';
	v_P4Matrix(v_ctr).fieldname:= 'P4_c1';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '30';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_RC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '20';
	v_P4Matrix(v_ctr).fieldname:= 'P4_c2';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '30';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_RC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '30';
	v_P4Matrix(v_ctr).fieldname:= 'P4_c3';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '30';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_RC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '40';
	v_P4Matrix(v_ctr).fieldname:= 'P4_c4';
	v_ctr := v_ctr + 1;

	------- Claims : Appointment Bases: Color
	v_P4Matrix(v_ctr).claims := '30';
	v_P4Matrix(v_ctr).bases := 'YES_NO';
	v_P4Matrix(v_ctr).basevalues := NULL;
	v_P4Matrix(v_ctr).fieldname:= 'P4_c5';
	v_ctr := v_ctr + 1;

	-------- Claims : Awards Bases : Religion
	v_P4Matrix(v_ctr).claims := '30';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_REL_BASIS';
	v_P4Matrix(v_ctr).basevalues := NULL;
	v_P4Matrix(v_ctr).fieldname:= 'P4_c6';
	v_ctr := v_ctr + 1;

	-------- Claims : Awards Bases : Reprisal
	v_P4Matrix(v_ctr).claims := '30';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_REP_BASIS';
	v_P4Matrix(v_ctr).basevalues := NULL;
	v_P4Matrix(v_ctr).fieldname:= 'P4_c7';
	v_ctr := v_ctr + 1;

	-------- Claims : Awards Bases : Sex
	v_P4Matrix(v_ctr).claims := '30';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_SEX_BASIS';
	v_P4Matrix(v_ctr).basevalues := '10';
	v_P4Matrix(v_ctr).fieldname:= 'P4_c8';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '30';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_SEX_BASIS';
	v_P4Matrix(v_ctr).basevalues := '20';
	v_P4Matrix(v_ctr).fieldname:= 'P4_c9';
	v_ctr := v_ctr + 1;

	-------- Claims : Awards Bases : National Origin
	v_P4Matrix(v_ctr).claims := '30';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_NO_BASIS';
	v_P4Matrix(v_ctr).basevalues := '10';
	v_P4Matrix(v_ctr).fieldname:= 'P4_c10';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '30';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_NO_BASIS';
	v_P4Matrix(v_ctr).basevalues := '20';
	v_P4Matrix(v_ctr).fieldname:= 'P4_c11';
	v_ctr := v_ctr + 1;

	-------- No Equal pact (columns k and l) for Awards
	---- Claims : Awards Bases : National Origin
	v_P4Matrix(v_ctr).claims := '30';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_AGE_BASIS';
	v_P4Matrix(v_ctr).basevalues := NULL;
	v_P4Matrix(v_ctr).fieldname:= 'P4_c14';
	v_ctr := v_ctr + 1;

	---- Claims : Awards Bases : Disability
	v_P4Matrix(v_ctr).claims := '30';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_HC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '10';
	v_P4Matrix(v_ctr).fieldname:= 'P4_c15';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '30';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_HC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '20';
	v_P4Matrix(v_ctr).fieldname:= 'P4_c16';
	v_ctr := v_ctr + 1;

	-- End of Claim Awards

	-------- Claims : Conversion to Full Time Bases : Race
	v_P4Matrix(v_ctr).claims := '40';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_RC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '10';
	v_P4Matrix(v_ctr).fieldname:= 'P4_d1';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '40';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_RC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '20';
	v_P4Matrix(v_ctr).fieldname:= 'P4_d2';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '40';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_RC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '30';
	v_P4Matrix(v_ctr).fieldname:= 'P4_d3';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '40';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_RC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '40';
	v_P4Matrix(v_ctr).fieldname:= 'P4_d4';
	v_ctr := v_ctr + 1;

	------- Claims : Appointment Bases: Color
	v_P4Matrix(v_ctr).claims := '40';
	v_P4Matrix(v_ctr).bases := 'YES_NO';
	v_P4Matrix(v_ctr).basevalues := NULL;
	v_P4Matrix(v_ctr).fieldname:= 'P4_d5';
	v_ctr := v_ctr + 1;


	-------- Claims : Conversion to Full Time Bases : Religion
	v_P4Matrix(v_ctr).claims := '40';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_REL_BASIS';
	v_P4Matrix(v_ctr).basevalues := NULL;
	v_P4Matrix(v_ctr).fieldname:= 'P4_d6';
	v_ctr := v_ctr + 1;

	-------- Claims : Conversion to Full Time Bases : Reprisal
	v_P4Matrix(v_ctr).claims := '40';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_REP_BASIS';
	v_P4Matrix(v_ctr).basevalues := NULL;
	v_P4Matrix(v_ctr).fieldname:= 'P4_d7';
	v_ctr := v_ctr + 1;

	-------- Claims : Conversion to Full Time Bases : Sex
	v_P4Matrix(v_ctr).claims := '40';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_SEX_BASIS';
	v_P4Matrix(v_ctr).basevalues := '10';
	v_P4Matrix(v_ctr).fieldname:= 'P4_d8';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '40';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_SEX_BASIS';
	v_P4Matrix(v_ctr).basevalues := '20';
	v_P4Matrix(v_ctr).fieldname:= 'P4_d9';
	v_ctr := v_ctr + 1;

	-------- Claims : Conversion to Full Time Bases : National Origin
	v_P4Matrix(v_ctr).claims := '40';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_NO_BASIS';
	v_P4Matrix(v_ctr).basevalues := '10';
	v_P4Matrix(v_ctr).fieldname:= 'P4_d10';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '40';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_NO_BASIS';
	v_P4Matrix(v_ctr).basevalues := '20';
	v_P4Matrix(v_ctr).fieldname:= 'P4_d11';
	v_ctr := v_ctr + 1;

	-------- No Equal pact (columns k and l) for Conversion to Full Time
	---- Claims : Conversion to Full Time Bases : National Origin
	v_P4Matrix(v_ctr).claims := '40';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_AGE_BASIS';
	v_P4Matrix(v_ctr).basevalues := NULL;
	v_P4Matrix(v_ctr).fieldname:= 'P4_d14';
	v_ctr := v_ctr + 1;

	---- Claims : Conversion to Full Time Bases : Disability
	v_P4Matrix(v_ctr).claims := '40';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_HC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '10';
	v_P4Matrix(v_ctr).fieldname:= 'P4_d15';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '40';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_HC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '20';
	v_P4Matrix(v_ctr).fieldname:= 'P4_d16';
	v_ctr := v_ctr + 1;

	-- End of Claim Conversion to Full Time


	-------- Claims : Disciplinary Action(Demotion) Bases : Race
	v_P4Matrix(v_ctr).claims := '50';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_RC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '10';
	v_P4Matrix(v_ctr).fieldname:= 'P4_e1_1';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '50';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_RC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '20';
	v_P4Matrix(v_ctr).fieldname:= 'P4_e1_2';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '50';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_RC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '30';
	v_P4Matrix(v_ctr).fieldname:= 'P4_e1_3';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '50';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_RC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '40';
	v_P4Matrix(v_ctr).fieldname:= 'P4_e1_4';
	v_ctr := v_ctr + 1;

	------- Claims : Appointment Bases: Color
	v_P4Matrix(v_ctr).claims := '50';
	v_P4Matrix(v_ctr).bases := 'YES_NO';
	v_P4Matrix(v_ctr).basevalues := NULL;
	v_P4Matrix(v_ctr).fieldname:= 'P4_e1_5';
	v_ctr := v_ctr + 1;


	-------- Claims : Disciplinary Action(Demotion) Bases : Religion
	v_P4Matrix(v_ctr).claims := '50';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_REL_BASIS';
	v_P4Matrix(v_ctr).basevalues := NULL;
	v_P4Matrix(v_ctr).fieldname:= 'P4_e1_6';
	v_ctr := v_ctr + 1;

	-------- Claims : Disciplinary Action(Demotion) Bases : Reprisal
	v_P4Matrix(v_ctr).claims := '50';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_REP_BASIS';
	v_P4Matrix(v_ctr).basevalues := NULL;
	v_P4Matrix(v_ctr).fieldname:= 'P4_e1_7';
	v_ctr := v_ctr + 1;

	-------- Claims : Disciplinary Action(Demotion) Bases : Sex
	v_P4Matrix(v_ctr).claims := '50';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_SEX_BASIS';
	v_P4Matrix(v_ctr).basevalues := '10';
	v_P4Matrix(v_ctr).fieldname:= 'P4_e1_8';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '50';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_SEX_BASIS';
	v_P4Matrix(v_ctr).basevalues := '20';
	v_P4Matrix(v_ctr).fieldname:= 'P4_e1_9';
	v_ctr := v_ctr + 1;

	-------- Claims : Disciplinary Action(Demotion) Bases : National Origin
	v_P4Matrix(v_ctr).claims := '50';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_NO_BASIS';
	v_P4Matrix(v_ctr).basevalues := '10';
	v_P4Matrix(v_ctr).fieldname:= 'P4_e1_10';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '50';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_NO_BASIS';
	v_P4Matrix(v_ctr).basevalues := '20';
	v_P4Matrix(v_ctr).fieldname:= 'P4_e1_11';
	v_ctr := v_ctr + 1;

	-------- No Equal pact (columns k and l) for Disciplinary Action(Demotion)
	---- Claims : Disciplinary Action(Demotion) Bases : National Origin
	v_P4Matrix(v_ctr).claims := '50';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_AGE_BASIS';
	v_P4Matrix(v_ctr).basevalues := NULL;
	v_P4Matrix(v_ctr).fieldname:= 'P4_e1_14';
	v_ctr := v_ctr + 1;

	---- Claims : Disciplinary Action(Demotion) Bases : Disability
	v_P4Matrix(v_ctr).claims := '50';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_HC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '10';
	v_P4Matrix(v_ctr).fieldname:= 'P4_e1_15';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '50';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_HC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '20';
	v_P4Matrix(v_ctr).fieldname:= 'P4_e1_16';
	v_ctr := v_ctr + 1;

	-- End of Claim Disciplinary Action(Demotion)

	-------- Claims : Disciplinary Action(Reprimand) Bases : Race
	v_P4Matrix(v_ctr).claims := '60';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_RC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '10';
	v_P4Matrix(v_ctr).fieldname:= 'P4_e2_1';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '60';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_RC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '20';
	v_P4Matrix(v_ctr).fieldname:= 'P4_e2_2';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '60';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_RC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '30';
	v_P4Matrix(v_ctr).fieldname:= 'P4_e2_3';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '60';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_RC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '40';
	v_P4Matrix(v_ctr).fieldname:= 'P4_e2_4';
	v_ctr := v_ctr + 1;

	------- Claims : Appointment Bases: Color
	v_P4Matrix(v_ctr).claims := '60';
	v_P4Matrix(v_ctr).bases := 'YES_NO';
	v_P4Matrix(v_ctr).basevalues := NULL;
	v_P4Matrix(v_ctr).fieldname:= 'P4_e2_5';
	v_ctr := v_ctr + 1;

	-------- Claims : Disciplinary Action(Reprimand) Bases : Religion
	v_P4Matrix(v_ctr).claims := '60';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_REL_BASIS';
	v_P4Matrix(v_ctr).basevalues := NULL;
	v_P4Matrix(v_ctr).fieldname:= 'P4_e2_6';
	v_ctr := v_ctr + 1;

	-------- Claims : Disciplinary Action(Reprimand) Bases : Reprisal
	v_P4Matrix(v_ctr).claims := '60';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_REP_BASIS';
	v_P4Matrix(v_ctr).basevalues := NULL;
	v_P4Matrix(v_ctr).fieldname:= 'P4_e2_7';
	v_ctr := v_ctr + 1;

	-------- Claims : Disciplinary Action(Reprimand) Bases : Sex
	v_P4Matrix(v_ctr).claims := '60';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_SEX_BASIS';
	v_P4Matrix(v_ctr).basevalues := '10';
	v_P4Matrix(v_ctr).fieldname:= 'P4_e2_8';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '60';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_SEX_BASIS';
	v_P4Matrix(v_ctr).basevalues := '20';
	v_P4Matrix(v_ctr).fieldname:= 'P4_e2_9';
	v_ctr := v_ctr + 1;

	-------- Claims : Disciplinary Action(Reprimand) Bases : National Origin
	v_P4Matrix(v_ctr).claims := '60';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_NO_BASIS';
	v_P4Matrix(v_ctr).basevalues := '10';
	v_P4Matrix(v_ctr).fieldname:= 'P4_e2_10';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '60';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_NO_BASIS';
	v_P4Matrix(v_ctr).basevalues := '20';
	v_P4Matrix(v_ctr).fieldname:= 'P4_e2_11';
	v_ctr := v_ctr + 1;

	-------- No Equal pact (columns k and l) for Disciplinary Action(Reprimand)
	---- Claims : Disciplinary Action(Reprimand) Bases : National Origin
	v_P4Matrix(v_ctr).claims := '60';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_AGE_BASIS';
	v_P4Matrix(v_ctr).basevalues := NULL;
	v_P4Matrix(v_ctr).fieldname:= 'P4_e2_14';
	v_ctr := v_ctr + 1;

	---- Claims : Disciplinary Action(Reprimand) Bases : Disability
	v_P4Matrix(v_ctr).claims := '60';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_HC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '10';
	v_P4Matrix(v_ctr).fieldname:= 'P4_e2_15';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '60';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_HC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '20';
	v_P4Matrix(v_ctr).fieldname:= 'P4_e2_16';
	v_ctr := v_ctr + 1;

	-- End of Claim Disciplinary Action(Reprimand)

	-------- Claims : Disciplinary Action(Suspension) Bases : Race
	v_P4Matrix(v_ctr).claims := '70';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_RC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '10';
	v_P4Matrix(v_ctr).fieldname:= 'P4_e3_1';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '70';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_RC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '20';
	v_P4Matrix(v_ctr).fieldname:= 'P4_e3_2';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '70';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_RC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '30';
	v_P4Matrix(v_ctr).fieldname:= 'P4_e3_3';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '70';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_RC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '40';
	v_P4Matrix(v_ctr).fieldname:= 'P4_e3_4';
	v_ctr := v_ctr + 1;

	------- Claims : Appointment Bases: Color
	v_P4Matrix(v_ctr).claims := '70';
	v_P4Matrix(v_ctr).bases := 'YES_NO';
	v_P4Matrix(v_ctr).basevalues := NULL;
	v_P4Matrix(v_ctr).fieldname:= 'P4_e3_5';
	v_ctr := v_ctr + 1;

	-------- Claims : Disciplinary Action(Suspension) Bases : Religion
	v_P4Matrix(v_ctr).claims := '70';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_REL_BASIS';
	v_P4Matrix(v_ctr).basevalues := NULL;
	v_P4Matrix(v_ctr).fieldname:= 'P4_e3_6';
	v_ctr := v_ctr + 1;

	-------- Claims : Disciplinary Action(Suspension) Bases : Reprisal
	v_P4Matrix(v_ctr).claims := '70';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_REP_BASIS';
	v_P4Matrix(v_ctr).basevalues := NULL;
	v_P4Matrix(v_ctr).fieldname:= 'P4_e3_7';
	v_ctr := v_ctr + 1;

	-------- Claims : Disciplinary Action(Suspension) Bases : Sex
	v_P4Matrix(v_ctr).claims := '70';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_SEX_BASIS';
	v_P4Matrix(v_ctr).basevalues := '10';
	v_P4Matrix(v_ctr).fieldname:= 'P4_e3_8';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '70';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_SEX_BASIS';
	v_P4Matrix(v_ctr).basevalues := '20';
	v_P4Matrix(v_ctr).fieldname:= 'P4_e3_9';
	v_ctr := v_ctr + 1;

	-------- Claims : Disciplinary Action(Suspension) Bases : National Origin
	v_P4Matrix(v_ctr).claims := '70';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_NO_BASIS';
	v_P4Matrix(v_ctr).basevalues := '10';
	v_P4Matrix(v_ctr).fieldname:= 'P4_e3_10';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '70';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_NO_BASIS';
	v_P4Matrix(v_ctr).basevalues := '20';
	v_P4Matrix(v_ctr).fieldname:= 'P4_e3_11';
	v_ctr := v_ctr + 1;

	-------- No Equal pact (columns k and l) for Disciplinary Action(Suspension)
	---- Claims : Disciplinary Action(Suspension) Bases : National Origin
	v_P4Matrix(v_ctr).claims := '70';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_AGE_BASIS';
	v_P4Matrix(v_ctr).basevalues := NULL;
	v_P4Matrix(v_ctr).fieldname:= 'P4_e3_14';
	v_ctr := v_ctr + 1;

	---- Claims : Disciplinary Action(Suspension) Bases : Disability
	v_P4Matrix(v_ctr).claims := '70';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_HC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '10';
	v_P4Matrix(v_ctr).fieldname:= 'P4_e3_15';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '70';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_HC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '20';
	v_P4Matrix(v_ctr).fieldname:= 'P4_e3_16';
	v_ctr := v_ctr + 1;

	-- End of Claim Disciplinary Action(Suspension)


	-------- Claims : Disciplinary Action(Removal) Bases : Race
	v_P4Matrix(v_ctr).claims := '80';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_RC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '10';
	v_P4Matrix(v_ctr).fieldname:= 'P4_e4_1';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '80';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_RC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '20';
	v_P4Matrix(v_ctr).fieldname:= 'P4_e4_2';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '80';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_RC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '30';
	v_P4Matrix(v_ctr).fieldname:= 'P4_e4_3';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '80';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_RC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '40';
	v_P4Matrix(v_ctr).fieldname:= 'P4_e4_4';
	v_ctr := v_ctr + 1;

	------- Claims : Appointment Bases: Color
	v_P4Matrix(v_ctr).claims := '80';
	v_P4Matrix(v_ctr).bases := 'YES_NO';
	v_P4Matrix(v_ctr).basevalues := NULL;
	v_P4Matrix(v_ctr).fieldname:= 'P4_e4_5';
	v_ctr := v_ctr + 1;


	-------- Claims : Disciplinary Action(Removal) Bases : Religion
	v_P4Matrix(v_ctr).claims := '80';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_REL_BASIS';
	v_P4Matrix(v_ctr).basevalues := NULL;
	v_P4Matrix(v_ctr).fieldname:= 'P4_e4_6';
	v_ctr := v_ctr + 1;

	-------- Claims : Disciplinary Action(Removal) Bases : Reprisal
	v_P4Matrix(v_ctr).claims := '80';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_REP_BASIS';
	v_P4Matrix(v_ctr).basevalues := NULL;
	v_P4Matrix(v_ctr).fieldname:= 'P4_e4_7';
	v_ctr := v_ctr + 1;

	-------- Claims : Disciplinary Action(Removal) Bases : Sex
	v_P4Matrix(v_ctr).claims := '80';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_SEX_BASIS';
	v_P4Matrix(v_ctr).basevalues := '10';
	v_P4Matrix(v_ctr).fieldname:= 'P4_e4_8';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '80';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_SEX_BASIS';
	v_P4Matrix(v_ctr).basevalues := '20';
	v_P4Matrix(v_ctr).fieldname:= 'P4_e4_9';
	v_ctr := v_ctr + 1;

	-------- Claims : Disciplinary Action(Removal) Bases : National Origin
	v_P4Matrix(v_ctr).claims := '80';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_NO_BASIS';
	v_P4Matrix(v_ctr).basevalues := '10';
	v_P4Matrix(v_ctr).fieldname:= 'P4_e4_10';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '80';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_NO_BASIS';
	v_P4Matrix(v_ctr).basevalues := '20';
	v_P4Matrix(v_ctr).fieldname:= 'P4_e4_11';
	v_ctr := v_ctr + 1;

	-------- No Equal pact (columns k and l) for Disciplinary Action(Removal)
	---- Claims : Disciplinary Action(Removal) Bases : National Origin
	v_P4Matrix(v_ctr).claims := '80';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_AGE_BASIS';
	v_P4Matrix(v_ctr).basevalues := NULL;
	v_P4Matrix(v_ctr).fieldname:= 'P4_e4_14';
	v_ctr := v_ctr + 1;

	---- Claims : Disciplinary Action(Removal) Bases : Disability
	v_P4Matrix(v_ctr).claims := '80';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_HC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '10';
	v_P4Matrix(v_ctr).fieldname:= 'P4_e4_15';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '80';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_HC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '20';
	v_P4Matrix(v_ctr).fieldname:= 'P4_e4_16';
	v_ctr := v_ctr + 1;

	-- End of Claim Disciplinary Action(Removal)


	-------- Claims : Disciplinary Action(Others) Bases : Race
	v_P4Matrix(v_ctr).claims := '90';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_RC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '10';
	v_P4Matrix(v_ctr).fieldname:= 'P4_e5_1';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '90';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_RC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '20';
	v_P4Matrix(v_ctr).fieldname:= 'P4_e5_2';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '90';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_RC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '30';
	v_P4Matrix(v_ctr).fieldname:= 'P4_e5_3';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '90';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_RC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '40';
	v_P4Matrix(v_ctr).fieldname:= 'P4_e5_4';
	v_ctr := v_ctr + 1;

	------- Claims : Appointment Bases: Color
	v_P4Matrix(v_ctr).claims := '90';
	v_P4Matrix(v_ctr).bases := 'YES_NO';
	v_P4Matrix(v_ctr).basevalues := NULL;
	v_P4Matrix(v_ctr).fieldname:= 'P4_e5_5';
	v_ctr := v_ctr + 1;

	-------- Claims : Disciplinary Action(Others) Bases : Religion
	v_P4Matrix(v_ctr).claims := '90';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_REL_BASIS';
	v_P4Matrix(v_ctr).basevalues := NULL;
	v_P4Matrix(v_ctr).fieldname:= 'P4_e5_6';
	v_ctr := v_ctr + 1;

	-------- Claims : Disciplinary Action(Others) Bases : Reprisal
	v_P4Matrix(v_ctr).claims := '90';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_REP_BASIS';
	v_P4Matrix(v_ctr).basevalues := NULL;
	v_P4Matrix(v_ctr).fieldname:= 'P4_e5_7';
	v_ctr := v_ctr + 1;

	-------- Claims : Disciplinary Action(Others) Bases : Sex
	v_P4Matrix(v_ctr).claims := '90';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_SEX_BASIS';
	v_P4Matrix(v_ctr).basevalues := '10';
	v_P4Matrix(v_ctr).fieldname:= 'P4_e5_8';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '90';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_SEX_BASIS';
	v_P4Matrix(v_ctr).basevalues := '20';
	v_P4Matrix(v_ctr).fieldname:= 'P4_e5_9';
	v_ctr := v_ctr + 1;

	-------- Claims : Disciplinary Action(Others) Bases : National Origin
	v_P4Matrix(v_ctr).claims := '90';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_NO_BASIS';
	v_P4Matrix(v_ctr).basevalues := '10';
	v_P4Matrix(v_ctr).fieldname:= 'P4_e5_10';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '90';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_NO_BASIS';
	v_P4Matrix(v_ctr).basevalues := '20';
	v_P4Matrix(v_ctr).fieldname:= 'P4_e5_11';
	v_ctr := v_ctr + 1;

	-------- No Equal pact (columns k and l) for Disciplinary Action(Others)
	---- Claims : Disciplinary Action(Others) Bases : National Origin
	v_P4Matrix(v_ctr).claims := '90';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_AGE_BASIS';
	v_P4Matrix(v_ctr).basevalues := NULL;
	v_P4Matrix(v_ctr).fieldname:= 'P4_e5_14';
	v_ctr := v_ctr + 1;

	---- Claims : Disciplinary Action(Others) Bases : Disability
	v_P4Matrix(v_ctr).claims := '90';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_HC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '10';
	v_P4Matrix(v_ctr).fieldname:= 'P4_e5_15';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '90';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_HC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '20';
	v_P4Matrix(v_ctr).fieldname:= 'P4_e5_16';
	v_ctr := v_ctr + 1;

	-- End of Claim Disciplinary Action(Others)

	-------- Claims : Duty Work Bases : Race
	v_P4Matrix(v_ctr).claims := '100';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_RC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '10';
	v_P4Matrix(v_ctr).fieldname:= 'P4_f1';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '100';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_RC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '20';
	v_P4Matrix(v_ctr).fieldname:= 'P4_f2';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '100';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_RC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '30';
	v_P4Matrix(v_ctr).fieldname:= 'P4_f3';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '100';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_RC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '40';
	v_P4Matrix(v_ctr).fieldname:= 'P4_f4';
	v_ctr := v_ctr + 1;

	------- Claims : Appointment Bases: Color
	v_P4Matrix(v_ctr).claims := '100';
	v_P4Matrix(v_ctr).bases := 'YES_NO';
	v_P4Matrix(v_ctr).basevalues := NULL;
	v_P4Matrix(v_ctr).fieldname:= 'P4_f5';
	v_ctr := v_ctr + 1;

	-------- Claims : Duty Work Bases : Religion
	v_P4Matrix(v_ctr).claims := '100';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_REL_BASIS';
	v_P4Matrix(v_ctr).basevalues := NULL;
	v_P4Matrix(v_ctr).fieldname:= 'P4_f6';
	v_ctr := v_ctr + 1;

	-------- Claims : Duty Work Bases : Reprisal
	v_P4Matrix(v_ctr).claims := '100';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_REP_BASIS';
	v_P4Matrix(v_ctr).basevalues := NULL;
	v_P4Matrix(v_ctr).fieldname:= 'P4_f7';
	v_ctr := v_ctr + 1;

	-------- Claims : Duty Work Bases : Sex
	v_P4Matrix(v_ctr).claims := '100';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_SEX_BASIS';
	v_P4Matrix(v_ctr).basevalues := '10';
	v_P4Matrix(v_ctr).fieldname:= 'P4_f8';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '100';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_SEX_BASIS';
	v_P4Matrix(v_ctr).basevalues := '20';
	v_P4Matrix(v_ctr).fieldname:= 'P4_f9';
	v_ctr := v_ctr + 1;

	-------- Claims : Duty Work Bases : National Origin
	v_P4Matrix(v_ctr).claims := '100';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_NO_BASIS';
	v_P4Matrix(v_ctr).basevalues := '10';
	v_P4Matrix(v_ctr).fieldname:= 'P4_f10';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '100';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_NO_BASIS';
	v_P4Matrix(v_ctr).basevalues := '20';
	v_P4Matrix(v_ctr).fieldname:= 'P4_f11';
	v_ctr := v_ctr + 1;

	-------- No Equal pact (columns k and l) for Duty Work
	---- Claims : Duty Work Bases : National Origin
	v_P4Matrix(v_ctr).claims := '100';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_AGE_BASIS';
	v_P4Matrix(v_ctr).basevalues := NULL;
	v_P4Matrix(v_ctr).fieldname:= 'P4_f14';
	v_ctr := v_ctr + 1;

	---- Claims : Duty Work Bases : Disability
	v_P4Matrix(v_ctr).claims := '100';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_HC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '10';
	v_P4Matrix(v_ctr).fieldname:= 'P4_f15';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '100';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_HC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '20';
	v_P4Matrix(v_ctr).fieldname:= 'P4_f16';
	v_ctr := v_ctr + 1;

	-- End of Claim Duty Work



	-------- Claims : Evaluation / Appraisal Bases : Race
	v_P4Matrix(v_ctr).claims := '110';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_RC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '10';
	v_P4Matrix(v_ctr).fieldname:= 'P4_g1';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '110';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_RC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '20';
	v_P4Matrix(v_ctr).fieldname:= 'P4_g2';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '110';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_RC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '30';
	v_P4Matrix(v_ctr).fieldname:= 'P4_g3';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '110';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_RC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '40';
	v_P4Matrix(v_ctr).fieldname:= 'P4_g4';
	v_ctr := v_ctr + 1;

	------- Claims : Appointment Bases: Color
	v_P4Matrix(v_ctr).claims := '110';
	v_P4Matrix(v_ctr).bases := 'YES_NO';
	v_P4Matrix(v_ctr).basevalues := NULL;
	v_P4Matrix(v_ctr).fieldname:= 'P4_g5';
	v_ctr := v_ctr + 1;


	-------- Claims : Evaluation / Appraisal Bases : Religion
	v_P4Matrix(v_ctr).claims := '110';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_REL_BASIS';
	v_P4Matrix(v_ctr).basevalues := NULL;
	v_P4Matrix(v_ctr).fieldname:= 'P4_g6';
	v_ctr := v_ctr + 1;

	-------- Claims : Evaluation / Appraisal Bases : Reprisal
	v_P4Matrix(v_ctr).claims := '110';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_REP_BASIS';
	v_P4Matrix(v_ctr).basevalues := NULL;
	v_P4Matrix(v_ctr).fieldname:= 'P4_g7';
	v_ctr := v_ctr + 1;

	-------- Claims : Evaluation / Appraisal Bases : Sex
	v_P4Matrix(v_ctr).claims := '110';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_SEX_BASIS';
	v_P4Matrix(v_ctr).basevalues := '10';
	v_P4Matrix(v_ctr).fieldname:= 'P4_g8';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '110';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_SEX_BASIS';
	v_P4Matrix(v_ctr).basevalues := '20';
	v_P4Matrix(v_ctr).fieldname:= 'P4_g9';
	v_ctr := v_ctr + 1;

	-------- Claims : Evaluation / Appraisal Bases : National Origin
	v_P4Matrix(v_ctr).claims := '110';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_NO_BASIS';
	v_P4Matrix(v_ctr).basevalues := '10';
	v_P4Matrix(v_ctr).fieldname:= 'P4_g10';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '110';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_NO_BASIS';
	v_P4Matrix(v_ctr).basevalues := '20';
	v_P4Matrix(v_ctr).fieldname:= 'P4_g11';
	v_ctr := v_ctr + 1;

	-------- No Equal pact (columns k and l) for Evaluation / Appraisal
	---- Claims : Evaluation / Appraisal Bases : National Origin
	v_P4Matrix(v_ctr).claims := '110';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_AGE_BASIS';
	v_P4Matrix(v_ctr).basevalues := NULL;
	v_P4Matrix(v_ctr).fieldname:= 'P4_g14';
	v_ctr := v_ctr + 1;

	---- Claims : Evaluation / Appraisal Bases : Disability
	v_P4Matrix(v_ctr).claims := '110';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_HC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '10';
	v_P4Matrix(v_ctr).fieldname:= 'P4_g15';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '110';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_HC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '20';
	v_P4Matrix(v_ctr).fieldname:= 'P4_g16';
	v_ctr := v_ctr + 1;

	-- End of Claim Evaluation / Appraisal


	-------- Claims : Examination / Test Bases : Race
	v_P4Matrix(v_ctr).claims := '120';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_RC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '10';
	v_P4Matrix(v_ctr).fieldname:= 'P4_h1';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '120';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_RC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '20';
	v_P4Matrix(v_ctr).fieldname:= 'P4_h2';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '120';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_RC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '30';
	v_P4Matrix(v_ctr).fieldname:= 'P4_h3';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '120';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_RC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '40';
	v_P4Matrix(v_ctr).fieldname:= 'P4_h4';
	v_ctr := v_ctr + 1;

	------- Claims : Appointment Bases: Color
	v_P4Matrix(v_ctr).claims := '120';
	v_P4Matrix(v_ctr).bases := 'YES_NO';
	v_P4Matrix(v_ctr).basevalues := NULL;
	v_P4Matrix(v_ctr).fieldname:= 'P4_h5';
	v_ctr := v_ctr + 1;


	-------- Claims : Examination / Test Bases : Religion
	v_P4Matrix(v_ctr).claims := '120';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_REL_BASIS';
	v_P4Matrix(v_ctr).basevalues := NULL;
	v_P4Matrix(v_ctr).fieldname:= 'P4_h6';
	v_ctr := v_ctr + 1;

	-------- Claims : Examination / Test Bases : Reprisal
	v_P4Matrix(v_ctr).claims := '120';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_REP_BASIS';
	v_P4Matrix(v_ctr).basevalues := NULL;
	v_P4Matrix(v_ctr).fieldname:= 'P4_h7';
	v_ctr := v_ctr + 1;

	-------- Claims : Examination / Test Bases : Sex
	v_P4Matrix(v_ctr).claims := '120';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_SEX_BASIS';
	v_P4Matrix(v_ctr).basevalues := '10';
	v_P4Matrix(v_ctr).fieldname:= 'P4_h8';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '120';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_SEX_BASIS';
	v_P4Matrix(v_ctr).basevalues := '20';
	v_P4Matrix(v_ctr).fieldname:= 'P4_h9';
	v_ctr := v_ctr + 1;

	-------- Claims : Examination / Test Bases : National Origin
	v_P4Matrix(v_ctr).claims := '120';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_NO_BASIS';
	v_P4Matrix(v_ctr).basevalues := '10';
	v_P4Matrix(v_ctr).fieldname:= 'P4_h10';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '120';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_NO_BASIS';
	v_P4Matrix(v_ctr).basevalues := '20';
	v_P4Matrix(v_ctr).fieldname:= 'P4_h11';
	v_ctr := v_ctr + 1;

	-------- No Equal pact (columns k and l) for Examination / Test
	---- Claims : Examination / Test Bases : National Origin
	v_P4Matrix(v_ctr).claims := '120';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_AGE_BASIS';
	v_P4Matrix(v_ctr).basevalues := NULL;
	v_P4Matrix(v_ctr).fieldname:= 'P4_h14';
	v_ctr := v_ctr + 1;

	---- Claims : Examination / Test Bases : Disability
	v_P4Matrix(v_ctr).claims := '120';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_HC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '10';
	v_P4Matrix(v_ctr).fieldname:= 'P4_h15';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '120';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_HC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '20';
	v_P4Matrix(v_ctr).fieldname:= 'P4_h16';
	v_ctr := v_ctr + 1;

	-- End of Claim Examination / Test


	-------- Claims : Harassment (Non Sexual) Bases : Race
	v_P4Matrix(v_ctr).claims := '130';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_RC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '10';
	v_P4Matrix(v_ctr).fieldname:= 'P4_i1_1';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '130';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_RC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '20';
	v_P4Matrix(v_ctr).fieldname:= 'P4_i1_2';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '130';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_RC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '30';
	v_P4Matrix(v_ctr).fieldname:= 'P4_i1_3';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '130';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_RC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '40';
	v_P4Matrix(v_ctr).fieldname:= 'P4_i1_4';
	v_ctr := v_ctr + 1;

	------- Claims : Appointment Bases: Color
	v_P4Matrix(v_ctr).claims := '130';
	v_P4Matrix(v_ctr).bases := 'YES_NO';
	v_P4Matrix(v_ctr).basevalues := NULL;
	v_P4Matrix(v_ctr).fieldname:= 'P4_i1_5';
	v_ctr := v_ctr + 1;


	-------- Claims : Harassment (Non Sexual) Bases : Religion
	v_P4Matrix(v_ctr).claims := '130';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_REL_BASIS';
	v_P4Matrix(v_ctr).basevalues := NULL;
	v_P4Matrix(v_ctr).fieldname:= 'P4_i1_6';
	v_ctr := v_ctr + 1;

	-------- Claims : Harassment (Non Sexual) Bases : Reprisal
	v_P4Matrix(v_ctr).claims := '130';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_REP_BASIS';
	v_P4Matrix(v_ctr).basevalues := NULL;
	v_P4Matrix(v_ctr).fieldname:= 'P4_i1_7';
	v_ctr := v_ctr + 1;

	-------- Claims : Harassment (Non Sexual) Bases : Sex
	v_P4Matrix(v_ctr).claims := '130';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_SEX_BASIS';
	v_P4Matrix(v_ctr).basevalues := '10';
	v_P4Matrix(v_ctr).fieldname:= 'P4_i1_8';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '130';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_SEX_BASIS';
	v_P4Matrix(v_ctr).basevalues := '20';
	v_P4Matrix(v_ctr).fieldname:= 'P4_i1_9';
	v_ctr := v_ctr + 1;

	-------- Claims : Harassment (Non Sexual) Bases : National Origin
	v_P4Matrix(v_ctr).claims := '130';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_NO_BASIS';
	v_P4Matrix(v_ctr).basevalues := '10';
	v_P4Matrix(v_ctr).fieldname:= 'P4_i1_10';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '130';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_NO_BASIS';
	v_P4Matrix(v_ctr).basevalues := '20';
	v_P4Matrix(v_ctr).fieldname:= 'P4_i1_11';
	v_ctr := v_ctr + 1;

	-------- No Equal pact (columns k and l) for Harassment (Non Sexual)
	---- Claims : Harassment (Non Sexual) Bases : National Origin
	v_P4Matrix(v_ctr).claims := '130';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_AGE_BASIS';
	v_P4Matrix(v_ctr).basevalues := NULL;
	v_P4Matrix(v_ctr).fieldname:= 'P4_i1_14';
	v_ctr := v_ctr + 1;

	---- Claims : Harassment (Non Sexual) Bases : Disability
	v_P4Matrix(v_ctr).claims := '130';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_HC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '10';
	v_P4Matrix(v_ctr).fieldname:= 'P4_i1_15';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '130';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_HC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '20';
	v_P4Matrix(v_ctr).fieldname:= 'P4_i1_16';
	v_ctr := v_ctr + 1;

	-- End of Claim Harassment (Non Sexual)


	-------- Claims : Harassment (Sexual) Bases : Race
/*	v_P4Matrix(v_ctr).claims := '140';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_RC_BASIS'
	v_P4Matrix(v_ctr).basevalues := '10'
	v_P4Matrix(v_ctr).fieldname:= 'P4_9b_a';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '140';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_RC_BASIS'
	v_P4Matrix(v_ctr).basevalues := '20'
	v_P4Matrix(v_ctr).fieldname:= 'P4_9b_b';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '140';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_RC_BASIS'
	v_P4Matrix(v_ctr).basevalues := '30'
	v_P4Matrix(v_ctr).fieldname:= 'P4_9b_c';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '140';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_RC_BASIS'
	v_P4Matrix(v_ctr).basevalues := '40'
	v_P4Matrix(v_ctr).fieldname:= 'P4_9b_d';
	v_ctr := v_ctr + 1;

	-------- Claims : Harassment (Sexual) Bases : Religion
	v_P4Matrix(v_ctr).claims := '140';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_REL_BASIS'
	v_P4Matrix(v_ctr).basevalues := NULL;
	v_P4Matrix(v_ctr).fieldname:= 'P4_9b_e';
	v_ctr := v_ctr + 1; */

	-------- Claims : Harassment (Sexual) Bases : Reprisal
	v_P4Matrix(v_ctr).claims := '140';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_REP_BASIS';
	v_P4Matrix(v_ctr).basevalues := NULL;
	v_P4Matrix(v_ctr).fieldname:= 'P4_i2_7';
	v_ctr := v_ctr + 1;

	-------- Claims : Harassment (Sexual) Bases : Sex
	v_P4Matrix(v_ctr).claims := '140';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_SEX_BASIS';
	v_P4Matrix(v_ctr).basevalues := '10';
	v_P4Matrix(v_ctr).fieldname:= 'P4_i2_8';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '140';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_SEX_BASIS';
	v_P4Matrix(v_ctr).basevalues := '20';
	v_P4Matrix(v_ctr).fieldname:= 'P4_i2_9';
	v_ctr := v_ctr + 1;

	-------- Claims : Harassment (Sexual) Bases : National Origin
/*	v_P4Matrix(v_ctr).claims := '140';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_NO_BASIS'
	v_P4Matrix(v_ctr).basevalues := '10';
	v_P4Matrix(v_ctr).fieldname:= 'P4_9b_i';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '140';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_NO_BASIS'
	v_P4Matrix(v_ctr).basevalues := '20';
	v_P4Matrix(v_ctr).fieldname:= 'P4_9b_j';
	v_ctr := v_ctr + 1; */

	-------- No Equal pact (columns k and l) for Harassment (Sexual)
	---- Claims : Harassment (Sexual) Bases : Ages
/*	v_P4Matrix(v_ctr).claims := '140';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_AGE_BASIS'
	v_P4Matrix(v_ctr).basevalues := NULL;
	v_P4Matrix(v_ctr).fieldname:= 'P4_9b_m';
	v_ctr := v_ctr + 1;

	---- Claims : Harassment (Sexual) Bases : Disability
	v_P4Matrix(v_ctr).claims := '140';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_HC_BASIS'
	v_P4Matrix(v_ctr).basevalues := '10';
	v_P4Matrix(v_ctr).fieldname:= 'P4_9b_n';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '140';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_HC_BASIS'
	v_P4Matrix(v_ctr).basevalues := '20';
	v_P4Matrix(v_ctr).fieldname:= 'P4_9b_o';
	v_ctr := v_ctr + 1; */

	-- End of Claim Harassment (Sexual)


	-------- Claims : Medical Examination Bases : Race
	v_P4Matrix(v_ctr).claims := '150';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_RC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '10';
	v_P4Matrix(v_ctr).fieldname:= 'P4_j1';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '150';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_RC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '20';
	v_P4Matrix(v_ctr).fieldname:= 'P4_j2';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '150';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_RC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '30';
	v_P4Matrix(v_ctr).fieldname:= 'P4_j3';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '150';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_RC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '40';
	v_P4Matrix(v_ctr).fieldname:= 'P4_j4';
	v_ctr := v_ctr + 1;

	------- Claims : Appointment Bases: Color
	v_P4Matrix(v_ctr).claims := '150';
	v_P4Matrix(v_ctr).bases := 'YES_NO';
	v_P4Matrix(v_ctr).basevalues := NULL;
	v_P4Matrix(v_ctr).fieldname:= 'P4_j5';
	v_ctr := v_ctr + 1;

	-------- Claims : Medical Examination Bases : Religion
	v_P4Matrix(v_ctr).claims := '150';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_REL_BASIS';
	v_P4Matrix(v_ctr).basevalues := NULL;
	v_P4Matrix(v_ctr).fieldname:= 'P4_j6';
	v_ctr := v_ctr + 1;

	-------- Claims : Medical Examination Bases : Reprisal
	v_P4Matrix(v_ctr).claims := '150';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_REP_BASIS';
	v_P4Matrix(v_ctr).basevalues := NULL;
	v_P4Matrix(v_ctr).fieldname:= 'P4_j7';
	v_ctr := v_ctr + 1;

	-------- Claims : Medical Examination Bases : Sex
	v_P4Matrix(v_ctr).claims := '150';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_SEX_BASIS';
	v_P4Matrix(v_ctr).basevalues := '10';
	v_P4Matrix(v_ctr).fieldname:= 'P4_j8';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '150';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_SEX_BASIS';
	v_P4Matrix(v_ctr).basevalues := '20';
	v_P4Matrix(v_ctr).fieldname:= 'P4_j9';
	v_ctr := v_ctr + 1;

	-------- Claims : Medical Examination Bases : National Origin
	v_P4Matrix(v_ctr).claims := '150';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_NO_BASIS';
	v_P4Matrix(v_ctr).basevalues := '10';
	v_P4Matrix(v_ctr).fieldname:= 'P4_j10';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '150';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_NO_BASIS';
	v_P4Matrix(v_ctr).basevalues := '20';
	v_P4Matrix(v_ctr).fieldname:= 'P4_j11';
	v_ctr := v_ctr + 1;

	-------- No Equal pact (columns k and l) for Medical Examination
	---- Claims : Medical Examination Bases : National Origin
	v_P4Matrix(v_ctr).claims := '150';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_AGE_BASIS';
	v_P4Matrix(v_ctr).basevalues := NULL;
	v_P4Matrix(v_ctr).fieldname:= 'P4_j14';
	v_ctr := v_ctr + 1;

	---- Claims : Medical Examination Bases : Disability
	v_P4Matrix(v_ctr).claims := '150';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_HC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '10';
	v_P4Matrix(v_ctr).fieldname:= 'P4_j15';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '150';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_HC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '20';
	v_P4Matrix(v_ctr).fieldname:= 'P4_j16';
	v_ctr := v_ctr + 1;

	-- End of Claim Medical Examination


	-------- Claims : Pay Including Overtime Bases : Race
	v_P4Matrix(v_ctr).claims := '160';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_RC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '10';
	v_P4Matrix(v_ctr).fieldname:= 'P4_k1';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '160';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_RC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '20';
	v_P4Matrix(v_ctr).fieldname:= 'P4_k2';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '160';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_RC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '30';
	v_P4Matrix(v_ctr).fieldname:= 'P4_k3';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '160';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_RC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '40';
	v_P4Matrix(v_ctr).fieldname:= 'P4_k4';
	v_ctr := v_ctr + 1;

	------- Claims : Appointment Bases: Color
	v_P4Matrix(v_ctr).claims := '160';
	v_P4Matrix(v_ctr).bases := 'YES_NO';
	v_P4Matrix(v_ctr).basevalues := NULL;
	v_P4Matrix(v_ctr).fieldname:= 'P4_k5';
	v_ctr := v_ctr + 1;

	-------- Claims : Pay Including Overtime Bases : Religion
	v_P4Matrix(v_ctr).claims := '160';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_REL_BASIS';
	v_P4Matrix(v_ctr).basevalues := NULL;
	v_P4Matrix(v_ctr).fieldname:= 'P4_k6';
	v_ctr := v_ctr + 1;

	-------- Claims : Pay Including Overtime Bases : Reprisal
	v_P4Matrix(v_ctr).claims := '160';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_REP_BASIS';
	v_P4Matrix(v_ctr).basevalues := NULL;
	v_P4Matrix(v_ctr).fieldname:= 'P4_k7';
	v_ctr := v_ctr + 1;

	-------- Claims : Pay Including Overtime Bases : Sex
	v_P4Matrix(v_ctr).claims := '160';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_SEX_BASIS';
	v_P4Matrix(v_ctr).basevalues := '10';
	v_P4Matrix(v_ctr).fieldname:= 'P4_k8';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '160';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_SEX_BASIS';
	v_P4Matrix(v_ctr).basevalues := '20';
	v_P4Matrix(v_ctr).fieldname:= 'P4_k9';
	v_ctr := v_ctr + 1;

	-------- Claims : Pay Including Overtime Bases : National Origin
	v_P4Matrix(v_ctr).claims := '160';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_NO_BASIS';
	v_P4Matrix(v_ctr).basevalues := '10';
	v_P4Matrix(v_ctr).fieldname:= 'P4_k10';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '160';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_NO_BASIS';
	v_P4Matrix(v_ctr).basevalues := '20';
	v_P4Matrix(v_ctr).fieldname:= 'P4_k11';
	v_ctr := v_ctr + 1;

	--------  Equal pact
	v_P4Matrix(v_ctr).claims := '160';
	v_P4Matrix(v_ctr).bases := 'SEX';
	v_P4Matrix(v_ctr).basevalues := 'M';
	v_P4Matrix(v_ctr).fieldname:= 'P4_k12';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '160';
	v_P4Matrix(v_ctr).bases := 'SEX';
	v_P4Matrix(v_ctr).basevalues := 'F';
	v_P4Matrix(v_ctr).fieldname:= 'P4_k13';
	v_ctr := v_ctr + 1;

	---- Claims : Pay Including Overtime Bases : National Origin
	v_P4Matrix(v_ctr).claims := '160';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_AGE_BASIS';
	v_P4Matrix(v_ctr).basevalues := NULL;
	v_P4Matrix(v_ctr).fieldname:= 'P4_k14';
	v_ctr := v_ctr + 1;

	---- Claims : Pay Including Overtime Bases : Disability
	v_P4Matrix(v_ctr).claims := '160';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_HC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '10';
	v_P4Matrix(v_ctr).fieldname:= 'P4_k15';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '160';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_HC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '20';
	v_P4Matrix(v_ctr).fieldname:= 'P4_k16';
	v_ctr := v_ctr + 1;

	-- End of Claim Pay Including Overtime


	-------- Claims : Promotion / Non Selection Bases : Race
	v_P4Matrix(v_ctr).claims := '170';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_RC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '10';
	v_P4Matrix(v_ctr).fieldname:= 'P4_l1';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '170';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_RC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '20';
	v_P4Matrix(v_ctr).fieldname:= 'P4_l2';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '170';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_RC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '30';
	v_P4Matrix(v_ctr).fieldname:= 'P4_l3';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '170';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_RC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '40';
	v_P4Matrix(v_ctr).fieldname:= 'P4_l4';
	v_ctr := v_ctr + 1;

	------- Claims :  Promotion / Non Selection Bases: Color
	v_P4Matrix(v_ctr).claims := '170';
	v_P4Matrix(v_ctr).bases := 'YES_NO';
	v_P4Matrix(v_ctr).basevalues := NULL;
	v_P4Matrix(v_ctr).fieldname:= 'P4_l5';
	v_ctr := v_ctr + 1;


	-------- Claims : Promotion / Non Selection Bases : Religion
	v_P4Matrix(v_ctr).claims := '170';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_REL_BASIS';
	v_P4Matrix(v_ctr).basevalues := NULL;
	v_P4Matrix(v_ctr).fieldname:= 'P4_l6';
	v_ctr := v_ctr + 1;

	-------- Claims : Promotion / Non Selection Bases : Reprisal
	v_P4Matrix(v_ctr).claims := '170';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_REP_BASIS';
	v_P4Matrix(v_ctr).basevalues := NULL;
	v_P4Matrix(v_ctr).fieldname:= 'P4_l7';
	v_ctr := v_ctr + 1;

	-------- Claims : Promotion / Non Selection Bases : Sex
	v_P4Matrix(v_ctr).claims := '170';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_SEX_BASIS';
	v_P4Matrix(v_ctr).basevalues := '10';
	v_P4Matrix(v_ctr).fieldname:= 'P4_l8';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '170';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_SEX_BASIS';
	v_P4Matrix(v_ctr).basevalues := '20';
	v_P4Matrix(v_ctr).fieldname:= 'P4_l9';
	v_ctr := v_ctr + 1;

	-------- Claims : Promotion / Non Selection Bases : National Origin
	v_P4Matrix(v_ctr).claims := '170';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_NO_BASIS';
	v_P4Matrix(v_ctr).basevalues := '10';
	v_P4Matrix(v_ctr).fieldname:= 'P4_l10';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '170';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_NO_BASIS';
	v_P4Matrix(v_ctr).basevalues := '20';
	v_P4Matrix(v_ctr).fieldname:= 'P4_l11';
	v_ctr := v_ctr + 1;

	-------- No Equal pact (columns k and l) for Promotion / Non Selection
	---- Claims : Promotion / Non Selection Bases : National Origin
	v_P4Matrix(v_ctr).claims := '170';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_AGE_BASIS';
	v_P4Matrix(v_ctr).basevalues := NULL;
	v_P4Matrix(v_ctr).fieldname:= 'P4_l14';
	v_ctr := v_ctr + 1;

	---- Claims : Promotion / Non Selection Bases : Disability
	v_P4Matrix(v_ctr).claims := '170';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_HC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '10';
	v_P4Matrix(v_ctr).fieldname:= 'P4_l15';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '170';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_HC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '20';
	v_P4Matrix(v_ctr).fieldname:= 'P4_l16';
	v_ctr := v_ctr + 1;

	-- End of Claim Promotion / Non Selection



	-------- Claims : Reassignment (Denied) Bases : Race
	v_P4Matrix(v_ctr).claims := '180';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_RC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '10';
	v_P4Matrix(v_ctr).fieldname:= 'P4_m1_1';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '180';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_RC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '20';
	v_P4Matrix(v_ctr).fieldname:= 'P4_m1_2';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '180';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_RC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '30';
	v_P4Matrix(v_ctr).fieldname:= 'P4_m1_3';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '180';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_RC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '40';
	v_P4Matrix(v_ctr).fieldname:= 'P4_m1_4';
	v_ctr := v_ctr + 1;

	------- Claims : Appointment Bases: Color
	v_P4Matrix(v_ctr).claims := '180';
	v_P4Matrix(v_ctr).bases := 'YES_NO';
	v_P4Matrix(v_ctr).basevalues := NULL;
	v_P4Matrix(v_ctr).fieldname:= 'P4_m1_5';
	v_ctr := v_ctr + 1;

	-------- Claims : Reassignment (Denied) Bases : Religion
	v_P4Matrix(v_ctr).claims := '180';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_REL_BASIS';
	v_P4Matrix(v_ctr).basevalues := NULL;
	v_P4Matrix(v_ctr).fieldname:= 'P4_m1_6';
	v_ctr := v_ctr + 1;

	-------- Claims : Reassignment (Denied) Bases : Reprisal
	v_P4Matrix(v_ctr).claims := '180';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_REP_BASIS';
	v_P4Matrix(v_ctr).basevalues := NULL;
	v_P4Matrix(v_ctr).fieldname:= 'P4_m1_7';
	v_ctr := v_ctr + 1;

	-------- Claims : Reassignment (Denied) Bases : Sex
	v_P4Matrix(v_ctr).claims := '180';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_SEX_BASIS';
	v_P4Matrix(v_ctr).basevalues := '10';
	v_P4Matrix(v_ctr).fieldname:= 'P4_m1_8';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '180';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_SEX_BASIS';
	v_P4Matrix(v_ctr).basevalues := '20';
	v_P4Matrix(v_ctr).fieldname:= 'P4_m1_9';
	v_ctr := v_ctr + 1;

	-------- Claims : Reassignment (Denied) Bases : National Origin
	v_P4Matrix(v_ctr).claims := '180';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_NO_BASIS';
	v_P4Matrix(v_ctr).basevalues := '10';
	v_P4Matrix(v_ctr).fieldname:= 'P4_m1_10';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '180';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_NO_BASIS';
	v_P4Matrix(v_ctr).basevalues := '20';
	v_P4Matrix(v_ctr).fieldname:= 'P4_m1_11';
	v_ctr := v_ctr + 1;

	-------- No Equal pact (columns k and l) for Reassignment (Denied)
	---- Claims : Reassignment (Denied) Bases : National Origin
	v_P4Matrix(v_ctr).claims := '180';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_AGE_BASIS';
	v_P4Matrix(v_ctr).basevalues := NULL;
	v_P4Matrix(v_ctr).fieldname:= 'P4_m1_14';
	v_ctr := v_ctr + 1;

	---- Claims : Reassignment (Denied) Bases : Disability
	v_P4Matrix(v_ctr).claims := '180';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_HC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '10';
	v_P4Matrix(v_ctr).fieldname:= 'P4_m1_15';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '180';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_HC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '20';
	v_P4Matrix(v_ctr).fieldname:= 'P4_m1_16';
	v_ctr := v_ctr + 1;

	-- End of Claim Reassignment (Denied)


	-------- Claims : Reassignment (Directed) Bases : Race
	v_P4Matrix(v_ctr).claims := '190';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_RC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '10';
	v_P4Matrix(v_ctr).fieldname:= 'P4_m2_1';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '190';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_RC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '20';
	v_P4Matrix(v_ctr).fieldname:= 'P4_m2_2';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '190';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_RC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '30';
	v_P4Matrix(v_ctr).fieldname:= 'P4_m2_3';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '190';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_RC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '40';
	v_P4Matrix(v_ctr).fieldname:= 'P4_m2_4';
	v_ctr := v_ctr + 1;

	------- Claims : Reassignment (Directed) Bases: Color
	v_P4Matrix(v_ctr).claims := '190';
	v_P4Matrix(v_ctr).bases := 'YES_NO';
	v_P4Matrix(v_ctr).basevalues := NULL;
	v_P4Matrix(v_ctr).fieldname:= 'P4_m2_5';
	v_ctr := v_ctr + 1;


	-------- Claims : Reassignment (Directed) Bases : Religion
	v_P4Matrix(v_ctr).claims := '190';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_REL_BASIS';
	v_P4Matrix(v_ctr).basevalues := NULL;
	v_P4Matrix(v_ctr).fieldname:= 'P4_m2_6';
	v_ctr := v_ctr + 1;

	-------- Claims : Reassignment (Directed) Bases : Reprisal
	v_P4Matrix(v_ctr).claims := '190';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_REP_BASIS';
	v_P4Matrix(v_ctr).basevalues := NULL;
	v_P4Matrix(v_ctr).fieldname:= 'P4_m2_7';
	v_ctr := v_ctr + 1;

	-------- Claims : Reassignment (Directed) Bases : Sex
	v_P4Matrix(v_ctr).claims := '190';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_SEX_BASIS';
	v_P4Matrix(v_ctr).basevalues := '10';
	v_P4Matrix(v_ctr).fieldname:= 'P4_m2_8';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '190';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_SEX_BASIS';
	v_P4Matrix(v_ctr).basevalues := '20';
	v_P4Matrix(v_ctr).fieldname:= 'P4_m2_9';
	v_ctr := v_ctr + 1;

	-------- Claims : Reassignment (Directed) Bases : National Origin
	v_P4Matrix(v_ctr).claims := '190';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_NO_BASIS';
	v_P4Matrix(v_ctr).basevalues := '10';
	v_P4Matrix(v_ctr).fieldname:= 'P4_m2_10';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '190';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_NO_BASIS';
	v_P4Matrix(v_ctr).basevalues := '20';
	v_P4Matrix(v_ctr).fieldname:= 'P4_m2_11';
	v_ctr := v_ctr + 1;

	-------- No Equal pact (columns k and l) for Reassignment (Directed)
	---- Claims : Reassignment (Directed) Bases : National Origin
	v_P4Matrix(v_ctr).claims := '190';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_AGE_BASIS';
	v_P4Matrix(v_ctr).basevalues := NULL;
	v_P4Matrix(v_ctr).fieldname:= 'P4_m2_14';
	v_ctr := v_ctr + 1;

	---- Claims : Reassignment (Directed) Bases : Disability
	v_P4Matrix(v_ctr).claims := '190';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_HC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '10';
	v_P4Matrix(v_ctr).fieldname:= 'P4_m2_15';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '190';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_HC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '20';
	v_P4Matrix(v_ctr).fieldname:= 'P4_m2_16';
	v_ctr := v_ctr + 1;

	-- End of Claim Reassignment (Directed)


	-------- Claims : Reasonable Accommodation Bases : Religion
	v_P4Matrix(v_ctr).claims := '200';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_REL_BASIS';
	v_P4Matrix(v_ctr).basevalues := NULL;
	v_P4Matrix(v_ctr).fieldname:= 'P4_n6';
	v_ctr := v_ctr + 1;

	-------- Claims : Reasonable Accommodation Bases : Reprisal
	v_P4Matrix(v_ctr).claims := '200';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_REP_BASIS';
	v_P4Matrix(v_ctr).basevalues := NULL;
	v_P4Matrix(v_ctr).fieldname:= 'P4_n7';
	v_ctr := v_ctr + 1;


	---- Claims : Reasonable Accommodation Bases : Disability
	v_P4Matrix(v_ctr).claims := '200';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_HC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '10';
	v_P4Matrix(v_ctr).fieldname:= 'P4_n15';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '200';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_HC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '20';
	v_P4Matrix(v_ctr).fieldname:= 'P4_n16';
	v_ctr := v_ctr + 1;

	-- End of Claim Reasonable Accommodation



	-------- Claims : Reinstatement Bases : Race
	v_P4Matrix(v_ctr).claims := '210';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_RC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '10';
	v_P4Matrix(v_ctr).fieldname:= 'P4_o1';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '210';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_RC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '20';
	v_P4Matrix(v_ctr).fieldname:= 'P4_o2';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '210';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_RC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '30';
	v_P4Matrix(v_ctr).fieldname:= 'P4_o3';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '210';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_RC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '40';
	v_P4Matrix(v_ctr).fieldname:= 'P4_o4';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '210';
	v_P4Matrix(v_ctr).bases := 'YES_NO';
	v_P4Matrix(v_ctr).basevalues := NULL;
	v_P4Matrix(v_ctr).fieldname:= 'P4_o5';
	v_ctr := v_ctr + 1;

	-------- Claims : Reinstatement Bases : Religion
	v_P4Matrix(v_ctr).claims := '210';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_REL_BASIS';
	v_P4Matrix(v_ctr).basevalues := NULL;
	v_P4Matrix(v_ctr).fieldname:= 'P4_o6';
	v_ctr := v_ctr + 1;

	-------- Claims : Reinstatement Bases : Reprisal
	v_P4Matrix(v_ctr).claims := '210';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_REP_BASIS';
	v_P4Matrix(v_ctr).basevalues := NULL;
	v_P4Matrix(v_ctr).fieldname:= 'P4_o7';
	v_ctr := v_ctr + 1;

	-------- Claims : Reinstatement Bases : Sex
	v_P4Matrix(v_ctr).claims := '210';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_SEX_BASIS';
	v_P4Matrix(v_ctr).basevalues := '10';
	v_P4Matrix(v_ctr).fieldname:= 'P4_o8';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '210';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_SEX_BASIS';
	v_P4Matrix(v_ctr).basevalues := '20';
	v_P4Matrix(v_ctr).fieldname:= 'P4_o9';
	v_ctr := v_ctr + 1;

	-------- Claims : Reinstatement Bases : National Origin
	v_P4Matrix(v_ctr).claims := '210';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_NO_BASIS';
	v_P4Matrix(v_ctr).basevalues := '10';
	v_P4Matrix(v_ctr).fieldname:= 'P4_o10';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '210';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_NO_BASIS';
	v_P4Matrix(v_ctr).basevalues := '20';
	v_P4Matrix(v_ctr).fieldname:= 'P4_o11';
	v_ctr := v_ctr + 1;

	-------- No Equal pact (columns k and l) for Reinstatement
	---- Claims : Reinstatement Bases : Age
	v_P4Matrix(v_ctr).claims := '210';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_AGE_BASIS';
	v_P4Matrix(v_ctr).basevalues := NULL;
	v_P4Matrix(v_ctr).fieldname:= 'P4_o14';
	v_ctr := v_ctr + 1;

	---- Claims : Reinstatement Bases : Disability
	v_P4Matrix(v_ctr).claims := '210';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_HC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '10';
	v_P4Matrix(v_ctr).fieldname:= 'P4_o15';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '210';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_HC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '20';
	v_P4Matrix(v_ctr).fieldname:= 'P4_o16';
	v_ctr := v_ctr + 1;

	-- End of Claim Reinstatement



	-------- Claims : Retirement Bases : Race
	v_P4Matrix(v_ctr).claims := '220';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_RC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '10';
	v_P4Matrix(v_ctr).fieldname:= 'P4_p1';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '220';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_RC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '20';
	v_P4Matrix(v_ctr).fieldname:= 'P4_p2';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '220';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_RC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '30';
	v_P4Matrix(v_ctr).fieldname:= 'P4_p3';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '220';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_RC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '40';
	v_P4Matrix(v_ctr).fieldname:= 'P4_p4';
	v_ctr := v_ctr + 1;

	------- Claims : Appointment Bases: Color
	v_P4Matrix(v_ctr).claims := '220';
	v_P4Matrix(v_ctr).bases := 'YES_NO';
	v_P4Matrix(v_ctr).basevalues := NULL;
	v_P4Matrix(v_ctr).fieldname:= 'P4_p5';
	v_ctr := v_ctr + 1;


	-------- Claims : Retirement Bases : Religion
	v_P4Matrix(v_ctr).claims := '220';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_REL_BASIS';
	v_P4Matrix(v_ctr).basevalues := NULL;
	v_P4Matrix(v_ctr).fieldname:= 'P4_p6';
	v_ctr := v_ctr + 1;

	-------- Claims : Retirement Bases : Reprisal
	v_P4Matrix(v_ctr).claims := '220';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_REP_BASIS';
	v_P4Matrix(v_ctr).basevalues := NULL;
	v_P4Matrix(v_ctr).fieldname:= 'P4_p7';
	v_ctr := v_ctr + 1;

	-------- Claims : Retirement Bases : Sex
	v_P4Matrix(v_ctr).claims := '220';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_SEX_BASIS';
	v_P4Matrix(v_ctr).basevalues := '10';
	v_P4Matrix(v_ctr).fieldname:= 'P4_p8';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '220';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_SEX_BASIS';
	v_P4Matrix(v_ctr).basevalues := '20';
	v_P4Matrix(v_ctr).fieldname:= 'P4_p9';
	v_ctr := v_ctr + 1;

	-------- Claims : Retirement Bases : National Origin
	v_P4Matrix(v_ctr).claims := '220';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_NO_BASIS';
	v_P4Matrix(v_ctr).basevalues := '10';
	v_P4Matrix(v_ctr).fieldname:= 'P4_p10';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '220';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_NO_BASIS';
	v_P4Matrix(v_ctr).basevalues := '20';
	v_P4Matrix(v_ctr).fieldname:= 'P4_p11';
	v_ctr := v_ctr + 1;

	-------- No Equal pact (columns k and l) for Retirement
	---- Claims : Retirement Bases : Age
	v_P4Matrix(v_ctr).claims := '220';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_AGE_BASIS';
	v_P4Matrix(v_ctr).basevalues := NULL;
	v_P4Matrix(v_ctr).fieldname:= 'P4_p14';
	v_ctr := v_ctr + 1;

	---- Claims : Retirement Bases : Disability
	v_P4Matrix(v_ctr).claims := '220';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_HC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '10';
	v_P4Matrix(v_ctr).fieldname:= 'P4_p15';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '220';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_HC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '20';
	v_P4Matrix(v_ctr).fieldname:= 'P4_p16';
	v_ctr := v_ctr + 1;

	-- End of Claim Retirement


	-------- Claims : Termination Bases : Race
	v_P4Matrix(v_ctr).claims := '230';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_RC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '10';
	v_P4Matrix(v_ctr).fieldname:= 'P4_q1';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '230';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_RC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '20';
	v_P4Matrix(v_ctr).fieldname:= 'P4_q2';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '230';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_RC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '30';
	v_P4Matrix(v_ctr).fieldname:= 'P4_q3';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '230';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_RC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '40';
	v_P4Matrix(v_ctr).fieldname:= 'P4_q4';
	v_ctr := v_ctr + 1;

	------- Claims : Termination Bases: Color
	v_P4Matrix(v_ctr).claims := '230';
	v_P4Matrix(v_ctr).bases := 'YES_NO';
	v_P4Matrix(v_ctr).basevalues := NULL;
	v_P4Matrix(v_ctr).fieldname:= 'P4_q5';
	v_ctr := v_ctr + 1;

	-------- Claims : Termination Bases : Religion
	v_P4Matrix(v_ctr).claims := '230';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_REL_BASIS';
	v_P4Matrix(v_ctr).basevalues := NULL;
	v_P4Matrix(v_ctr).fieldname:= 'P4_q6';
	v_ctr := v_ctr + 1;

	-------- Claims : Termination Bases : Reprisal
	v_P4Matrix(v_ctr).claims := '230';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_REP_BASIS';
	v_P4Matrix(v_ctr).basevalues := NULL;
	v_P4Matrix(v_ctr).fieldname:= 'P4_q7';
	v_ctr := v_ctr + 1;

	-------- Claims : Termination Bases : Sex
	v_P4Matrix(v_ctr).claims := '230';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_SEX_BASIS';
	v_P4Matrix(v_ctr).basevalues := '10';
	v_P4Matrix(v_ctr).fieldname:= 'P4_q8';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '230';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_SEX_BASIS';
	v_P4Matrix(v_ctr).basevalues := '20';
	v_P4Matrix(v_ctr).fieldname:= 'P4_q9';
	v_ctr := v_ctr + 1;

	-------- Claims : Termination Bases : National Origin
	v_P4Matrix(v_ctr).claims := '230';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_NO_BASIS';
	v_P4Matrix(v_ctr).basevalues := '10';
	v_P4Matrix(v_ctr).fieldname:= 'P4_q10';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '230';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_NO_BASIS';
	v_P4Matrix(v_ctr).basevalues := '20';
	v_P4Matrix(v_ctr).fieldname:= 'P4_q11';
	v_ctr := v_ctr + 1;

	-------- No Equal pact (columns k and l) for Termination
	---- Claims : Termination Bases : Age
	v_P4Matrix(v_ctr).claims := '230';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_AGE_BASIS';
	v_P4Matrix(v_ctr).basevalues := NULL;
	v_P4Matrix(v_ctr).fieldname:= 'P4_q14';
	v_ctr := v_ctr + 1;

	---- Claims : Termination Bases : Disability
	v_P4Matrix(v_ctr).claims := '230';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_HC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '10';
	v_P4Matrix(v_ctr).fieldname:= 'P4_q15';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '230';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_HC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '20';
	v_P4Matrix(v_ctr).fieldname:= 'P4_q16';
	v_ctr := v_ctr + 1;

	-- End of Claim Termination


	-------- Claims : Terms / Conditions of Employment Bases : Race
	v_P4Matrix(v_ctr).claims := '240';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_RC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '10';
	v_P4Matrix(v_ctr).fieldname:= 'P4_r1';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '240';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_RC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '20';
	v_P4Matrix(v_ctr).fieldname:= 'P4_r2';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '240';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_RC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '30';
	v_P4Matrix(v_ctr).fieldname:= 'P4_r3';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '240';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_RC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '40';
	v_P4Matrix(v_ctr).fieldname:= 'P4_r4';
	v_ctr := v_ctr + 1;

	------- Claims : Appointment Bases: Color
	v_P4Matrix(v_ctr).claims := '240';
	v_P4Matrix(v_ctr).bases := 'YES_NO';
	v_P4Matrix(v_ctr).basevalues := NULL;
	v_P4Matrix(v_ctr).fieldname:= 'P4_r5';
	v_ctr := v_ctr + 1;

	-------- Claims : Terms / Conditions of Employment Bases : Religion
	v_P4Matrix(v_ctr).claims := '240';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_REL_BASIS';
	v_P4Matrix(v_ctr).basevalues := NULL;
	v_P4Matrix(v_ctr).fieldname:= 'P4_r6';
	v_ctr := v_ctr + 1;

	-------- Claims : Terms / Conditions of Employment Bases : Reprisal
	v_P4Matrix(v_ctr).claims := '240';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_REP_BASIS';
	v_P4Matrix(v_ctr).basevalues := NULL;
	v_P4Matrix(v_ctr).fieldname:= 'P4_r7';
	v_ctr := v_ctr + 1;

	-------- Claims : Terms / Conditions of Employment Bases : Sex
	v_P4Matrix(v_ctr).claims := '240';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_SEX_BASIS';
	v_P4Matrix(v_ctr).basevalues := '10';
	v_P4Matrix(v_ctr).fieldname:= 'P4_r8';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '240';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_SEX_BASIS';
	v_P4Matrix(v_ctr).basevalues := '20';
	v_P4Matrix(v_ctr).fieldname:= 'P4_r9';
	v_ctr := v_ctr + 1;

	-------- Claims : Terms / Conditions of Employment Bases : National Origin
	v_P4Matrix(v_ctr).claims := '240';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_NO_BASIS';
	v_P4Matrix(v_ctr).basevalues := '10';
	v_P4Matrix(v_ctr).fieldname:= 'P4_r10';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '240';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_NO_BASIS';
	v_P4Matrix(v_ctr).basevalues := '20';
	v_P4Matrix(v_ctr).fieldname:= 'P4_r11';
	v_ctr := v_ctr + 1;

	-------- No Equal pact (columns k and l) for Terms / Conditions of Employment
	---- Claims : Terms / Conditions of Employment Bases : Age
	v_P4Matrix(v_ctr).claims := '240';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_AGE_BASIS';
	v_P4Matrix(v_ctr).basevalues := NULL;
	v_P4Matrix(v_ctr).fieldname:= 'P4_r14';
	v_ctr := v_ctr + 1;

	---- Claims : Terms / Conditions of Employment Bases : Disability
	v_P4Matrix(v_ctr).claims := '240';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_HC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '10';
	v_P4Matrix(v_ctr).fieldname:= 'P4_r15';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '240';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_HC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '20';
	v_P4Matrix(v_ctr).fieldname:= 'P4_r16';
	v_ctr := v_ctr + 1;

	-- End of Claim Terms / Conditions of Employment


	-------- Claims : Time and Attendance Bases : Race
	v_P4Matrix(v_ctr).claims := '250';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_RC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '10';
	v_P4Matrix(v_ctr).fieldname:= 'P4_s1';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '250';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_RC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '20';
	v_P4Matrix(v_ctr).fieldname:= 'P4_s2';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '250';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_RC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '30';
	v_P4Matrix(v_ctr).fieldname:= 'P4_s3';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '250';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_RC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '40';
	v_P4Matrix(v_ctr).fieldname:= 'P4_s4';
	v_ctr := v_ctr + 1;

	------- Claims : Appointment Bases: Color
	v_P4Matrix(v_ctr).claims := '250';
	v_P4Matrix(v_ctr).bases := 'YES_NO';
	v_P4Matrix(v_ctr).basevalues := NULL;
	v_P4Matrix(v_ctr).fieldname:= 'P4_s5';
	v_ctr := v_ctr + 1;

	-------- Claims : Time and Attendance Bases : Religion
	v_P4Matrix(v_ctr).claims := '250';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_REL_BASIS';
	v_P4Matrix(v_ctr).basevalues := NULL;
	v_P4Matrix(v_ctr).fieldname:= 'P4_s6';
	v_ctr := v_ctr + 1;

	-------- Claims : Time and Attendance Bases : Reprisal
	v_P4Matrix(v_ctr).claims := '250';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_REP_BASIS';
	v_P4Matrix(v_ctr).basevalues := NULL;
	v_P4Matrix(v_ctr).fieldname:= 'P4_s7';
	v_ctr := v_ctr + 1;

	-------- Claims : Time and Attendance Bases : Sex
	v_P4Matrix(v_ctr).claims := '250';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_SEX_BASIS';
	v_P4Matrix(v_ctr).basevalues := '10';
	v_P4Matrix(v_ctr).fieldname:= 'P4_s8';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '250';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_SEX_BASIS';
	v_P4Matrix(v_ctr).basevalues := '20';
	v_P4Matrix(v_ctr).fieldname:= 'P4_s9';
	v_ctr := v_ctr + 1;

	-------- Claims : Time and Attendance Bases : National Origin
	v_P4Matrix(v_ctr).claims := '250';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_NO_BASIS';
	v_P4Matrix(v_ctr).basevalues := '10';
	v_P4Matrix(v_ctr).fieldname:= 'P4_s10';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '250';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_NO_BASIS';
	v_P4Matrix(v_ctr).basevalues := '20';
	v_P4Matrix(v_ctr).fieldname:= 'P4_s11';
	v_ctr := v_ctr + 1;

	-------- No Equal pact (columns k and l) for Time and Attendance
	---- Claims : Time and Attendance Bases : Age
	v_P4Matrix(v_ctr).claims := '250';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_AGE_BASIS';
	v_P4Matrix(v_ctr).basevalues := NULL;
	v_P4Matrix(v_ctr).fieldname:= 'P4_s14';
	v_ctr := v_ctr + 1;

	---- Claims : Time and Attendance Bases : Disability
	v_P4Matrix(v_ctr).claims := '250';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_HC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '10';
	v_P4Matrix(v_ctr).fieldname:= 'P4_s15';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '250';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_HC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '20';
	v_P4Matrix(v_ctr).fieldname:= 'P4_s16';
	v_ctr := v_ctr + 1;

	-- End of Claim Time and Attendance


	-------- Claims : Training Bases : Race
	v_P4Matrix(v_ctr).claims := '260';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_RC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '10';
	v_P4Matrix(v_ctr).fieldname:= 'P4_t1';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '260';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_RC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '20';
	v_P4Matrix(v_ctr).fieldname:= 'P4_t2';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '260';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_RC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '30';
	v_P4Matrix(v_ctr).fieldname:= 'P4_t3';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '260';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_RC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '40';
	v_P4Matrix(v_ctr).fieldname:= 'P4_t4';
	v_ctr := v_ctr + 1;

	------- Claims : Appointment Bases: Color
	v_P4Matrix(v_ctr).claims := '260';
	v_P4Matrix(v_ctr).bases := 'YES_NO';
	v_P4Matrix(v_ctr).basevalues := NULL;
	v_P4Matrix(v_ctr).fieldname:= 'P4_t5';
	v_ctr := v_ctr + 1;


	-------- Claims : Training Bases : Religion
	v_P4Matrix(v_ctr).claims := '260';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_REL_BASIS';
	v_P4Matrix(v_ctr).basevalues := NULL;
	v_P4Matrix(v_ctr).fieldname:= 'P4_t6';
	v_ctr := v_ctr + 1;

	-------- Claims : Training Bases : Reprisal
	v_P4Matrix(v_ctr).claims := '260';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_REP_BASIS';
	v_P4Matrix(v_ctr).basevalues := NULL;
	v_P4Matrix(v_ctr).fieldname:= 'P4_t7';
	v_ctr := v_ctr + 1;

	-------- Claims : Training Bases : Sex
	v_P4Matrix(v_ctr).claims := '260';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_SEX_BASIS';
	v_P4Matrix(v_ctr).basevalues := '10';
	v_P4Matrix(v_ctr).fieldname:= 'P4_t8';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '260';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_SEX_BASIS';
	v_P4Matrix(v_ctr).basevalues := '20';
	v_P4Matrix(v_ctr).fieldname:= 'P4_t9';
	v_ctr := v_ctr + 1;

	-------- Claims : Training Bases : National Origin
	v_P4Matrix(v_ctr).claims := '260';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_NO_BASIS';
	v_P4Matrix(v_ctr).basevalues := '10';
	v_P4Matrix(v_ctr).fieldname:= 'P4_t10';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '260';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_NO_BASIS';
	v_P4Matrix(v_ctr).basevalues := '20';
	v_P4Matrix(v_ctr).fieldname:= 'P4_t11';
	v_ctr := v_ctr + 1;

	-------- No Equal pact (columns k and l) for Training
	---- Claims : Training Bases : Age
	v_P4Matrix(v_ctr).claims := '260';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_AGE_BASIS';
	v_P4Matrix(v_ctr).basevalues := NULL;
	v_P4Matrix(v_ctr).fieldname:= 'P4_t14';
	v_ctr := v_ctr + 1;

	---- Claims : Training Bases : Disability
	v_P4Matrix(v_ctr).claims := '260';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_HC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '10';
	v_P4Matrix(v_ctr).fieldname:= 'P4_t15';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '260';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_HC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '20';
	v_P4Matrix(v_ctr).fieldname:= 'P4_t16';
	v_ctr := v_ctr + 1;

	-- End of Claim Training
	-------- Claims : Other Bases : Race
	v_P4Matrix(v_ctr).claims := '270';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_RC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '10';
	v_P4Matrix(v_ctr).fieldname:= 'P4_u1';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '270';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_RC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '20';
	v_P4Matrix(v_ctr).fieldname:= 'P4_u2';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '270';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_RC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '30';
	v_P4Matrix(v_ctr).fieldname:= 'P4_u3';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '270';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_RC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '40';
	v_P4Matrix(v_ctr).fieldname:= 'P4_u4';
	v_ctr := v_ctr + 1;

	------- Claims : Appointment Bases: Color
	v_P4Matrix(v_ctr).claims := '270';
	v_P4Matrix(v_ctr).bases := 'YES_NO';
	v_P4Matrix(v_ctr).basevalues := NULL;
	v_P4Matrix(v_ctr).fieldname:= 'P4_u5';
	v_ctr := v_ctr + 1;

	-------- Claims : Other Bases : Religion
	v_P4Matrix(v_ctr).claims := '270';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_REL_BASIS';
	v_P4Matrix(v_ctr).basevalues := NULL;
	v_P4Matrix(v_ctr).fieldname:= 'P4_u6';
	v_ctr := v_ctr + 1;

	-------- Claims : Other Bases : Reprisal
	v_P4Matrix(v_ctr).claims := '270';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_REP_BASIS';
	v_P4Matrix(v_ctr).basevalues := NULL;
	v_P4Matrix(v_ctr).fieldname:= 'P4_u7';
	v_ctr := v_ctr + 1;

	-------- Claims : Other Bases : Sex
	v_P4Matrix(v_ctr).claims := '270';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_SEX_BASIS';
	v_P4Matrix(v_ctr).basevalues := '10';
	v_P4Matrix(v_ctr).fieldname:= 'P4_u8';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '270';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_SEX_BASIS';
	v_P4Matrix(v_ctr).basevalues := '20';
	v_P4Matrix(v_ctr).fieldname:= 'P4_u9';
	v_ctr := v_ctr + 1;

	-------- Claims : Other Bases : National Origin
	v_P4Matrix(v_ctr).claims := '270';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_NO_BASIS';
	v_P4Matrix(v_ctr).basevalues := '10';
	v_P4Matrix(v_ctr).fieldname:= 'P4_u10';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '270';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_NO_BASIS';
	v_P4Matrix(v_ctr).basevalues := '20';
	v_P4Matrix(v_ctr).fieldname:= 'P4_u11';
	v_ctr := v_ctr + 1;

	-------- No Equal pact (columns k and l) for Other
	---- Claims : Other Bases : Age
	v_P4Matrix(v_ctr).claims := '270';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_AGE_BASIS';
	v_P4Matrix(v_ctr).basevalues := NULL;
	v_P4Matrix(v_ctr).fieldname:= 'P4_u14';
	v_ctr := v_ctr + 1;

	---- Claims : Other Bases : Disability
	v_P4Matrix(v_ctr).claims := '270';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_HC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '10';
	v_P4Matrix(v_ctr).fieldname:= 'P4_u15';
	v_ctr := v_ctr + 1;

	v_P4Matrix(v_ctr).claims := '270';
	v_P4Matrix(v_ctr).bases := 'GHR_US_COM_HC_BASIS';
	v_P4Matrix(v_ctr).basevalues := '20';
	v_P4Matrix(v_ctr).fieldname:= 'P4_u16';
	v_ctr := v_ctr + 1;

	-- End of Claim Other

END PopulatePart4Matrix;


END ghr_462;

/

--------------------------------------------------------
--  DDL for Package Body PAY_NL_IZA_REPORT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_NL_IZA_REPORT" AS
/* $Header: paynliza.pkb 120.0 2005/05/29 02:40:37 appldev noship $ */

level_cnt NUMBER;

/*Counter for accessing the values in PAY_NL_XDO_REPORT.vXMLTable*/
vCtr NUMBER;

/*-------------------------------------------------------------------------------
|Name           : populate_iza_report_data                                      |
|Type		: Procedure						        |
|Description    : Procedure to generate the Annual Tax Statement Report         |
------------------------------------------------------------------------------*/

procedure populate_iza_report_data(p_bg_id IN NUMBER,
                                   p_bg_name IN VARCHAR2,
                                   p_eff_date IN VARCHAR2,
                                   p_org_struct_id IN NUMBER,
                                   p_org_struct IN VARCHAR2,
                                   p_process_month IN VARCHAR2,
                                   p_employer_id IN NUMBER,
                                   p_employer IN VARCHAR2,
                                   p_xfdf_blob OUT NOCOPY BLOB) IS


/*Cursors to fetch required data */

cursor csr_employer_data is
select 'EUR' currency , iza.payroll_center ,
       iza.province_code||' '||hr_general.decode_lookup('NL_IZA_PROVINCE',iza.province_code) province,
       lpad(employer_number,3,'0') employer_number , lpad(sub_employer_number,3,'0') sub_employer_number
from pay_nl_iza_upld_status iza
where iza.business_group_id = p_bg_id
and iza.organization_id = p_employer_id
and iza.process_year_month = last_day(to_date(p_process_month,'MMYYYY'));

cursor csr_employee_data is
select lpad(iza.employer_number,3,'0')||lpad(iza.sub_employer_number,3,'0')||'-'||lpad(iza.employee_number,9,'0') exchange_number,iza.process_status,
iza.employee_name name,
iza.date_of_birth dob,
iza.participant_number participant_number,
iza.contribution_1 iza_amt_1,iza.contribution_2 iza_amt_2,
iza.correction_contribution_1 corr_amt_1,iza.correction_contribution_2 corr_amt_2,
iza.date_correction_1,iza.date_correction_2,
decode(iza.process_status,'MISSING',hr_general.decode_lookup('NL_IZA_REJECT_REASON',iza.process_status),hr_general.decode_lookup('NL_IZA_REJECT_REASON',iza.reject_reason)) explanation
from pay_nl_iza_upld_status iza
where iza.business_group_id = p_bg_id
and iza.organization_id = p_employer_id
and iza.process_year_month = last_day(to_date(p_process_month,'MMYYYY'));

v_employer_data csr_employer_data%rowtype;
l_record_count number;
l_accepted_count number;
l_rejected_count number;
l_retro_count number;
l_missing_count number;
l_tape_amt_1 number;
l_accepted_amt_1 number;
l_rejected_amt_1 number;
l_retro_amt_1 number;
l_tape_amt_2 number;
l_accepted_amt_2 number;
l_rejected_amt_2 number;
l_retro_amt_2 number;
l_tape_corr_1 number;
l_accepted_corr_1 number;
l_rejected_corr_1 number;
l_retro_corr_1 number;
l_tape_corr_2 number;
l_accepted_corr_2 number;
l_rejected_corr_2 number;
l_retro_corr_2 number;
l_tape_total number;
l_accepted_total number;
l_rejected_total number;
l_retro_total number;
l_earliest_correction_date date;
l_earliest_correction_date1 varchar2(50);


/*Make calls to suppoting procedures to form the XML file*/

begin
        l_record_count := 0;
	l_accepted_count := 0;
	l_rejected_count := 0;
	l_retro_count := 0;
	l_missing_count := 0;
	l_tape_amt_1 := 0;
	l_accepted_amt_1 := 0;
	l_rejected_amt_1 := 0;
        l_retro_amt_1 := 0;
        l_tape_amt_2 := 0;
	l_accepted_amt_2 := 0;
	l_rejected_amt_2 := 0;
        l_retro_amt_2 := 0;
        l_tape_corr_1 := 0;
	l_accepted_corr_1 := 0;
	l_rejected_corr_1 := 0;
	l_retro_corr_1 := 0;
	l_tape_corr_2 := 0;
	l_accepted_corr_2 := 0;
	l_rejected_corr_2 := 0;
	l_retro_corr_2 := 0;
        l_tape_total := 0;
	l_accepted_total := 0;
	l_rejected_total := 0;
        l_retro_total := 0;
        l_earliest_correction_date := hr_general.end_of_time;


	open csr_employer_data;
	fetch csr_employer_data into v_employer_data;
	close csr_employer_data;

 	PAY_NL_XDO_REPORT.vXMLTable.DELETE;
 	vCtr := 0;

/*Get all the XML tags and values*/
        PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'BG_NAME';
	PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := p_bg_name;
	vCtr := vCtr + 1;
	PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'EFF_DATE';
	PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := to_char(fnd_date.canonical_to_date(p_eff_date),'DD-Mon-YYYY');
	vCtr := vCtr + 1;
	PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'ORG_HIERARCHY';
	PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := p_org_struct;
	vCtr := vCtr + 1;
	PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'EMPLOYER';
	PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := p_employer;
	vCtr := vCtr + 1;
	PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'PROCESS_MONTH';
	PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := to_char(to_date(p_process_month,'MMYYYY'),'YYYY / MM');
	vCtr := vCtr + 1;
	PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'CURRENCY';
	PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := v_employer_data.currency;
	vCtr := vCtr + 1;
	PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'PAYROLL_CENTER';
	PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := v_employer_data.payroll_center;
	vCtr := vCtr + 1;
	PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'PROVINCE';
	PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := v_employer_data.province;
	vCtr := vCtr + 1;
	PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'IZA_CLIENT_NUMBER';
	PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := v_employer_data.employer_number;
	vCtr := vCtr + 1;
	PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'SUB_EMPLOYER_NUMBER';
	PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := v_employer_data.sub_employer_number;

	for v_employee_data in csr_employee_data
	loop
	if (v_employee_data.process_status = 'REJECTED' or v_employee_data.process_status = 'MISSING') then
	vCtr := vCtr + 1;
	PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'G_CONTAINER_EMPLOYEE';
	PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := null;
	vCtr := vCtr + 1;
	PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'EXCHANGE_NUMBER';
	PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := v_employee_data.exchange_number;
	vCtr := vCtr + 1;
	PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'NAME';
	PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := v_employee_data.name;
	vCtr := vCtr + 1;
	PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'DOB';
	PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := to_char(v_employee_data.dob,'DD-MM-YY');
	vCtr := vCtr + 1;
	PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'PARTICIPANT_NUMBER';
	PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := v_employee_data.participant_number;
	vCtr := vCtr + 1;
	PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'IZA_AMT_1';
	PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := to_char(v_employee_data.iza_amt_1,'99G990D00MI');
	vCtr := vCtr + 1;
	PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'IZA_AMT_2';
	PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := to_char(v_employee_data.iza_amt_2,'99G990D00MI');
	vCtr := vCtr + 1;
	PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'CORR_AMT_1';
	PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := to_char(v_employee_data.corr_amt_1,'99G990D00MI');
	vCtr := vCtr + 1;
	PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'CORR_AMT_2';
	PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := to_char(v_employee_data.corr_amt_2,'99G990D00MI');
	vCtr := vCtr + 1;
	PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'EXPLANATION';
	PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := v_employee_data.explanation;
	vCtr := vCtr + 1;
	PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'G_CONTAINER_EMPLOYEE';
	PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := 'END';
	if v_employee_data.process_status = 'REJECTED' then
	   l_rejected_count := l_rejected_count + 1;
	   l_rejected_amt_1 := l_rejected_amt_1 + v_employee_data.iza_amt_1;
	   l_rejected_amt_2 := l_rejected_amt_2 + v_employee_data.iza_amt_2;
	   l_rejected_corr_1 := l_rejected_corr_1 + v_employee_data.corr_amt_1;
	   l_rejected_corr_2 := l_rejected_corr_2 + v_employee_data.corr_amt_2;
	else if v_employee_data.process_status = 'MISSING' then
	     l_missing_count := l_missing_count + 1;
	end if;
	end if;
	end if;
	if l_earliest_correction_date > v_employee_data.date_correction_1 and v_employee_data.process_status = 'PROCESSED' then
	   l_earliest_correction_date := v_employee_data.date_correction_1;
	end if;
	if l_earliest_correction_date > v_employee_data.date_correction_2 and v_employee_data.process_status = 'PROCESSED' then
		   l_earliest_correction_date := v_employee_data.date_correction_2;
	end if;
	if v_employee_data.process_status = 'PROCESSED' then
	     l_accepted_count := l_accepted_count + 1;
	     l_accepted_amt_1 := l_accepted_amt_1 + v_employee_data.iza_amt_1;
	     l_accepted_amt_2 := l_accepted_amt_2 + v_employee_data.iza_amt_2;
	     l_accepted_corr_1 := l_accepted_corr_1 + v_employee_data.corr_amt_1;
	     l_accepted_corr_2 := l_accepted_corr_2 + v_employee_data.corr_amt_2;
	end if;
	if ((v_employee_data.corr_amt_1 > 0 or v_employee_data.corr_amt_2 > 0) and v_employee_data.process_status = 'PROCESSED') then
	     l_retro_count := l_retro_count + 1;
	     l_retro_amt_1 := 0;
	     l_retro_amt_2 := 0;
	     l_retro_corr_1 := l_retro_corr_1 + v_employee_data.corr_amt_1;
	     l_retro_corr_2 := l_retro_corr_2 + v_employee_data.corr_amt_2;
	end if;
	end loop;

/*Fetch XML file as a BLOB*/
 vCtr := vCtr + 1;
 PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'ACCEPTED_COUNT';
 PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := l_accepted_count;
 vCtr := vCtr + 1;
 PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'REJECTED_COUNT';
 PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := l_rejected_count;
 vCtr := vCtr + 1;
 PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'MISSING_COUNT';
 PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := l_missing_count;
 l_Record_count := l_accepted_count + l_rejected_count;
 l_tape_amt_1 := l_accepted_amt_1 + l_rejected_amt_1;
 l_tape_amt_2 := l_accepted_amt_2 + l_rejected_amt_2;
 l_tape_corr_1 := l_accepted_corr_1 + l_rejected_corr_1;
 l_tape_corr_2 := l_accepted_corr_2 + l_rejected_corr_2;
 l_tape_total := l_tape_amt_1 + l_tape_amt_2 + l_tape_corr_1 + l_tape_corr_2;
 l_accepted_total := l_accepted_amt_1 + l_accepted_amt_2 + l_accepted_corr_1 + l_accepted_corr_2;
 l_rejected_total := l_rejected_amt_1 + l_rejected_amt_2 + l_rejected_corr_1 + l_rejected_corr_2;
 l_retro_total := l_retro_amt_1 + l_retro_amt_2 + l_retro_corr_1 + l_retro_corr_2;
 vCtr := vCtr + 1;
 PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'RECORD_COUNT';
 PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := l_record_count;
 vCtr := vCtr + 1;
 PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'RETRO_COUNT';
 PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := l_retro_count;
 vCtr := vCtr + 1;
 PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'TAPE_AMT_1';
 PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := to_char(l_tape_amt_1,'9G999G990D00MI');
 vCtr := vCtr + 1;
 PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'ACCEPTED_AMT_1';
 PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := to_char(l_accepted_amt_1,'9G999G990D00MI');
 vCtr := vCtr + 1;
 PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'REJECTED_AMT_1';
 PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := to_char(l_rejected_amt_1,'9G999G990D00MI');
 vCtr := vCtr + 1;
 PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'RETRO_AMT_1';
 PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := to_char(l_retro_amt_1,'9G999G990D00MI');
 vCtr := vCtr + 1;
 PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'TAPE_AMT_2';
 PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := to_char(l_tape_amt_2,'9G999G990D00MI');
 vCtr := vCtr + 1;
 PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'ACCEPTED_AMT_2';
 PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := to_char(l_accepted_amt_2,'9G999G990D00MI');
 vCtr := vCtr + 1;
 PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'REJECTED_AMT_2';
 PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := to_char(l_rejected_amt_2,'9G999G990D00MI');
 vCtr := vCtr + 1;
 PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'RETRO_AMT_2';
 PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := to_char(l_retro_amt_2,'9G999G990D00MI');
 vCtr := vCtr + 1;
 PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'TAPE_CORR_1';
 PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := to_char(l_tape_corr_1,'9G999G990D00MI');
 vCtr := vCtr + 1;
 PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'ACCEPTED_CORR_1';
 PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := to_char(l_accepted_corr_1,'9G999G990D00MI');
 vCtr := vCtr + 1;
 PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'REJECTED_CORR_1';
 PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := to_char(l_rejected_corr_1,'9G999G990D00MI');
 vCtr := vCtr + 1;
 PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'RETRO_CORR_1';
 PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := to_char(l_retro_corr_1,'9G999G990D00MI');
 vCtr := vCtr + 1;
 PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'TAPE_CORR_2';
 PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := to_char(l_tape_corr_2,'9G999G990D00MI');
 vCtr := vCtr + 1;
 PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'ACCEPTED_CORR_2';
 PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := to_char(l_accepted_corr_2,'9G999G990D00MI');
 vCtr := vCtr + 1;
 PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'REJECTED_CORR_2';
 PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := to_char(l_rejected_corr_2,'9G999G990D00MI');
 vCtr := vCtr + 1;
 PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'RETRO_CORR_2';
 PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := to_char(l_retro_corr_2,'9G999G990D00MI');
 vCtr := vCtr + 1;
 PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'TAPE_TOTAL';
 PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := to_char(l_tape_total,'99G999G999G990D00MI');
 vCtr := vCtr + 1;
 PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'ACCEPTED_TOTAL';
 PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := to_char(l_accepted_total,'99G999G999G990D00MI');
 vCtr := vCtr + 1;
 PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'REJECTED_TOTAL';
 PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := to_char(l_rejected_total,'99G999G999G990D00MI');
 vCtr := vCtr + 1;
 PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'RETRO_TOTAL';
 PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := to_char(l_retro_total,'99G999G999G990D00MI');
 vCtr := vCtr + 1;
 PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'EARLIEST_CORRECTION_DATE';
 l_earliest_correction_date1 := to_char(l_earliest_correction_date,'DD-MM-YY');
 if l_earliest_correction_date = hr_general.end_of_time then
    l_earliest_correction_date1 := NULL;
 end if;
 PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := l_earliest_correction_date1;

 pay_nl_xdo_Report.WritetoCLOB_rtf(p_xfdf_blob );

end populate_iza_report_data;


PROCEDURE record_4712(p_file_id NUMBER) IS

	l_upload_name       VARCHAR2(1000);
	l_file_name         VARCHAR2(1000);
	l_start_date        DATE := TO_DATE('01/01/0001', 'dd/mm/yyyy');
	l_end_date          DATE := TO_DATE('31/12/4712', 'dd/mm/yyyy');

BEGIN
	-- program_name will be used to store the file_name
	-- this is bcos the file_name in fnd_lobs contains
	-- the full patch of the doc and not just the file name
	SELECT program_name
	INTO l_file_name
	FROM fnd_lobs
	WHERE file_id = p_file_id;

	-- the delete will ensure that the patch is rerunnable
	DELETE FROM per_gb_xdo_templates
	WHERE file_name = l_file_name AND
	effective_start_date = l_start_date AND
	effective_end_date = l_end_date;

	INSERT INTO per_gb_xdo_templates
	(file_id,
	file_name,
	file_description,
	effective_start_date,
	effective_end_date)
	SELECT p_file_id, l_file_name, 'Template for year 0001-4712',
	l_start_date, l_end_date
	FROM fnd_lobs
	WHERE file_id = p_file_id;
END;


END PAY_NL_IZA_REPORT;

/

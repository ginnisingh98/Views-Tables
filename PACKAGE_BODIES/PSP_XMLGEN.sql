--------------------------------------------------------
--  DDL for Package Body PSP_XMLGEN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSP_XMLGEN" AS
/* $Header: PSPXMLGB.pls 120.29.12010000.6 2009/06/25 09:57:27 amakrish ship $ */

g_request_id	NUMBER(15, 0);

FUNCTION generate_approver_header_xml (p_request_id IN NUMBER DEFAULT NULL) RETURN CLOB IS
qryCtx1			dbms_xmlgen.ctxType;
query1			varchar2(4000);
xmlresult1		CLOB;
l_xml			CLOB DEFAULT empty_clob();
l_resultOffset		int;
l_icx_date_format	VARCHAR2(20);
l_gl_sob		NUMBER;

CURSOR	get_sob_cur IS
SELECT	set_of_books_id
FROM	psp_report_templates_h
WHERE	request_id = p_request_id;

CURSOR	add_report_error_cur (p_sqlerrm IN VARCHAR2) IS
SELECT	1
FROM	psp_report_errors
WHERE	request_id = p_request_id
AND	message_level = 'E'
AND	error_message = SUBSTR(p_sqlerrm, 1, 2000)
AND	pdf_request_id = g_request_id;

CURSOR	user_name_cur IS
SELECT	user_name
FROM	fnd_user fu,
	fnd_concurrent_requests fcr
WHERE	fu.user_id = fcr.requested_by
AND	fcr.request_id = p_request_id;

l_user_name	fnd_user.user_name%TYPE;
l_error_count	NUMBER;
l_return_status	CHAR(1);
l_language_code	VARCHAR2(30);
BEGIN
	g_request_id := fnd_global.conc_request_id;
	fnd_profile.get('ICX_DATE_FORMAT_MASK', l_icx_date_format);
	l_language_code := USERENV('LANG');

	OPEN get_sob_cur;
	FETCH get_sob_cur INTO l_gl_sob;
	CLOSE get_sob_cur;

	OPEN user_name_cur;
	FETCH user_name_cur INTO l_user_name;
	CLOSE user_name_cur;

	query1 := 'select xtt.template_name report_layout, prth.template_name, '
		|| 'TO_CHAR(fnd_date.canonical_to_date(fnd_date.date_to_canonical(prth.parameter_value_2)), ''' || l_icx_date_format
		|| ''') start_date, TO_CHAR(fnd_date.canonical_to_date(fnd_date.date_to_canonical(prth.parameter_value_3)), '''
		|| l_icx_date_format || ''') end_date, SUBSTR(prth.report_template_code, 6, 3) layout_type, flv1.meaning sort_option1, '
		|| 'flv2.meaning order_by1, flv3.meaning sort_option2, flv4.meaning order_by2, '
		|| 'flv5.meaning sort_option3, flv6.meaning order_by3, flv7.meaning sort_option4, flv8.meaning order_by4, '
		|| 'DECODE(prth.initiator_person_id, -1, ''' || l_user_name || ''', '
		|| 'psp_general.get_person_name(prth.initiator_person_id, TRUNC(SYSDATE))) initiated_by, '
		|| 'TO_CHAR(SYSDATE, ''' || l_icx_date_format || ''') run_date '
		|| 'FROM psp_report_templates_h prth, xdo_templates_tl xtt,  '
        	|| '(select * from psp_layout_lookup_code_v where set_of_books_id in (-1, ' || TO_CHAR(l_gl_sob) || ')) flv1, '
		|| '(select * from fnd_lookup_values where language = ''' || l_language_code || ''' AND lookup_type = ''PSP_ORDERING_CRITERIA'') flv2, '
		|| '(select * from psp_layout_lookup_code_v where set_of_books_id in (-1, ' || TO_CHAR(l_gl_sob) || ')) flv3, '
		|| '(select * from fnd_lookup_values where language = ''' || l_language_code || ''' AND lookup_type = ''PSP_ORDERING_CRITERIA'') flv4, '
        	|| '(select * from psp_layout_lookup_code_v where set_of_books_id in (-1, ' || TO_CHAR(l_gl_sob) || ')) flv5, '
		|| '(select * from fnd_lookup_values where language = ''' || l_language_code || ''' AND lookup_type = ''PSP_ORDERING_CRITERIA'') flv6, '
		|| '(select * from psp_layout_lookup_code_v where set_of_books_id in (-1, ' || TO_CHAR(l_gl_sob) || ')) flv7, '
		|| '(select * from fnd_lookup_values where language = ''' || l_language_code || ''' AND lookup_type = ''PSP_ORDERING_CRITERIA'') flv8 WHERE '
		|| 'prth.request_id = ' || TO_CHAR(p_request_id)
		|| 'AND flv1.lookup_code = prth.parameter_value_5 '
		|| 'AND flv2.lookup_code = prth.parameter_value_6 '
		|| 'AND flv3.lookup_code = prth.parameter_value_7 '
		|| 'AND flv4.lookup_code = prth.parameter_value_8 '
		|| 'AND flv5.lookup_code (+) = prth.parameter_value_9 '
		|| 'AND flv6.lookup_code (+) = prth.parameter_value_10 '
		|| 'AND flv7.lookup_code (+) = prth.parameter_value_11 '
		|| 'AND flv8.lookup_code (+) = prth.parameter_value_12 '
		|| 'AND xtt.language = ''' || l_language_code || ''' '
		|| 'AND xtt.template_code = prth.report_template_code AND xtt.application_short_name = ''PSP''';
	qryCtx1 := dbms_xmlgen.newContext(query1);
	dbms_xmlgen.setRowTag(qryCtx1, NULL);
	dbms_xmlgen.setRowSetTag(qryCtx1, 'G_REPORT_INFO');
	xmlresult1 := dbms_xmlgen.getXML(qryCtx1, dbms_xmlgen.NONE);
	dbms_xmlgen.closecontext(qryctx1);
	l_xml := xmlresult1;
	dbms_lob.write(l_xml, length('<?xml version="1.0" ?> '), 1, '<?xml version="1.0" ?> ');
	l_resultOffset := DBMS_LOB.INSTR(xmlresult1,'>');
	dbms_lob.copy(l_xml, xmlresult1, dbms_lob.getlength(xmlresult1) - l_resultOffset, length('<?xml version="1.0" ?> '), l_resultOffset +1);
	RETURN l_xml;
EXCEPTION
	WHEN OTHERS THEN
		OPEN add_report_error_cur(sqlerrm);
		FETCH add_report_error_cur INTO l_error_count;
		CLOSE add_report_error_cur;

		IF (NVL(l_error_count, 0) = 0) THEN
			psp_general.add_report_error
				(p_request_id		=>	p_request_id,
				p_message_level		=>	'E',
				p_source_id		=>	NULL,
				p_retry_request_id	=>	NULL,
				p_pdf_request_id	=>	g_request_id,
				p_error_message		=>	sqlerrm,
				p_return_status		=>	l_return_status);
		END IF;
		RAISE;
END generate_approver_header_xml;

FUNCTION generate_approver_xml (p_wf_item_key	IN	NUMBER,
				p_request_id	IN	NUMBER DEFAULT NULL) RETURN CLOB IS
qryCtx1			dbms_xmlgen.ctxType;
query1			varchar2(4000);
query2			varchar2(4000);
xmlresult1		CLOB;
l_xml			CLOB DEFAULT empty_clob();
l_person_xml		CLOB DEFAULT empty_clob();
l_resultOffset		int;

l_organization_id	NUMBER;
l_template_id		NUMBER;
l_sort_option1		VARCHAR2(1000);
l_sort_option2		VARCHAR2(1000);
l_criteria_value1	VARCHAR2(30);
l_emp_sort_option	VARCHAR2(1000);
l_sort_option_desc1	VARCHAR2(1000);
l_sort_option_desc2	VARCHAR2(1000);
l_order_by_desc1	VARCHAR2(100);
l_order_by_desc2	VARCHAR2(100);
l_layout_type		VARCHAR2(100);
l_request_id		NUMBER(15);
l_set_of_books_id	NUMBER;
l_segment_delimiter	CHAR(1);
l_gl_header		VARCHAR2(1000);
l_segment_header	VARCHAR2(200);
l_investigator_id	NUMBER(15);
l_investigator_name	psp_eff_report_details.investigator_name%TYPE;
l_investigator_org_name	psp_eff_report_details.investigator_org_name%TYPE;
l_investigator_primary_org_id	psp_eff_report_details.investigator_primary_org_id%TYPE;
l_total_pi_proposed_salary	VARCHAR2(50);
l_total_pi_actual_salary	VARCHAR2(50);
l_display_flag		psp_report_templates_h.display_all_emp_distrib_flag%TYPE;
l_report_info		VARCHAR2(4000);
l_icx_date_format	VARCHAR2(20);

CURSOR	sort_option_cur (p_request_id IN NUMBER) IS
SELECT	DISTINCT prtdh.criteria_value1,
	plo.value1 || ' ' || DECODE(prtdh.criteria_value2, 'A', 'ASC', 'DESC') sort_option,
	' ''' || flv1.meaning || ''' ' sort_option_description,
	' ''' || flv2.meaning || ''' ' order_by_description
FROM	psp_report_template_details_h prtdh,
	psp_report_templates_h prth,
        fnd_lookup_values flv1,
        fnd_lookup_values flv2,
        psp_layout_options plo
WHERE	prtdh.request_id = p_request_id
AND	prth.request_id = p_request_id
AND	plo.report_template_code = prth.report_template_code
AND     flv1.lookup_code = prtdh.criteria_lookup_code
AND	flv1.lookup_type = 'PSP_SORTING_CRITERIA'
AND	prtdh.criteria_lookup_type = 'PSP_SORTING_CRITERIA'
AND	flv2.lookup_type = 'PSP_ORDERING_CRITERIA'
AND     flv2.lookup_code = prtdh.criteria_value2
ANd     prtdh.criteria_lookup_code = plo.layout_lookup_code
AND	plo.value1 LIKE 'per.%'
ORDER BY prtdh.criteria_value1;

CURSOR	sort_option2_cur (p_request_id IN NUMBER) IS
SELECT	DISTINCT prtdh.criteria_value1,
	plo.value1 || ' ' || DECODE(prtdh.criteria_value2, 'A', 'ASC', 'DESC') sort_option,
	' ''' || flv1.meaning || ''' ' sort_option_description,
	' ''' || flv2.meaning || ''' ' order_by_description
FROM	psp_report_template_details_h prtdh,
	psp_report_templates_h prth,
        fnd_lookup_values flv1,
        fnd_lookup_values flv2,
        psp_layout_options plo
WHERE	prth.request_id = p_request_id
AND	prtdh.request_id = p_request_id
AND	plo.report_template_code = prth.report_template_code
AND     flv1.lookup_code = prtdh.criteria_lookup_code
AND	flv1.language = 'US'
AND	flv1.lookup_type = 'PSP_SORTING_CRITERIA'
AND	prtdh.criteria_lookup_type = 'PSP_SORTING_CRITERIA'
AND	plo.layout_lookup_type = 'PSP_SORTING_CRITERIA'
AND	flv2.language = 'US'
AND	flv2.lookup_type = 'PSP_ORDERING_CRITERIA'
AND     flv2.lookup_code = prtdh.criteria_value2
AND     prtdh.criteria_lookup_code = plo.layout_lookup_code --'PRINVESG'
--AND	plo.value1 LIKE 'perd.%'
AND	plo.layout_lookup_code IN ('PRINVESG', 'PIORG', 'PRJMGR', 'PMORG', 'TASKMGR', 'TMORG')
ORDER BY prtdh.criteria_value1;

CURSOR	layout_type_cur IS
SELECT	SUBSTR(report_template_code, 6, 3) layout_type,
	display_all_emp_distrib_flag display_flag
FROM	psp_report_templates_h prt
WHERE	request_id = l_request_id;

CURSOR	nls_date_format_cur IS
SELECT	value
FROM	nls_session_parameters
WHERE	parameter = 'NLS_DATE_FORMAT';

CURSOR	approver_info_cur IS
SELECT	DISTINCT pera.wf_role_display_name,
	haou.name
FROM	hr_all_organization_units haou,
	psp_eff_report_approvals pera,
	per_all_assignments_f paaf,
	fnd_user fu
WHERE	pera.wf_item_key = p_wf_item_key
AND	fu.employee_id = paaf.person_id
AND	fu.user_name = pera.wf_role_name
AND	paaf.primary_flag = 'Y'
AND	haou.organization_id = paaf.organization_id
AND	TRUNC(SYSDATE) BETWEEN paaf.effective_start_date AND paaf.effective_end_date;

CURSOR	template_id_cur IS
SELECT	per.template_id,
	per.request_id,
	per.set_of_books_id
FROM	psp_eff_report_details perd,
	psp_eff_report_approvals pera,
	psp_eff_reports per
WHERE	perd.effort_report_detail_id = pera.effort_report_detail_id
AND	perd.effort_report_id = per.effort_report_id
AND	pera.wf_item_key = p_wf_item_key
AND	ROWNUM = 1
UNION ALL
SELECT	per2.template_id,
	p_request_id,
	per2.set_of_books_id
FROM	psp_eff_reports per2
WHERE	per2.request_id = p_request_id
AND	ROWNUM = 1;

CURSOR	get_segment_delimeter_cur IS
SELECT	fnd_flex_ext.get_delimiter('SQLGL', 'GL#', gsob.chart_of_accounts_id)
FROM	gl_sets_of_books gsob
WHERE	gsob.set_of_books_id = l_set_of_books_id;

CURSOR	get_segment_header_cur IS
SELECT	fifs.segment_name || l_segment_delimiter segment_header
FROM	fnd_id_flex_segments fifs,
	gl_sets_of_books gsob,
	fnd_application fa
WHERE	gsob.set_of_books_id = l_set_of_books_id
AND	fifs.id_flex_num = gsob.chart_of_accounts_id
AND	fifs.id_flex_code = 'GL#'
AND	fifs.application_id = fa.application_id
AND	fa.application_short_name = 'SQLGL'
AND	EXISTS	(SELECT	1
		FROM	psp_report_template_details_h prtdh
		WHERE	prtdh.REQUEST_ID= p_request_id
		AND	prtdh.criteria_lookup_type = 'PSP_SUMMARIZATION_CRITERIA'
		AND	prtdh.criteria_lookup_code = fifs.application_column_name)
ORDER BY fifs.segment_num;

TYPE personxmlType IS REF CURSOR;
person_xml_cur	personxmlType;

TYPE investigatorType IS REF CURSOR;
investigator_cur	investigatorType;

CURSOR	add_report_error_cur (p_sqlerrm IN VARCHAR2) IS
SELECT	1
FROM	psp_report_errors
WHERE	request_id = p_request_id
AND	message_level = 'E'
AND	error_message = SUBSTR(p_sqlerrm, 1, 2000)
AND	pdf_request_id = g_request_id;

CURSOR	format_mask_cur(p_length IN NUMBER) IS
SELECT	fnd_currency.get_format_mask(currency_code, p_length)
FROM	psp_eff_reports
WHERE	request_id = l_request_id;

CURSOR show_hide_FYI_lines_csr(p_request_id IN NUMBER,p_investigator_person_id IN NUMBER) IS
SELECT 'Y'
FROM  psp_eff_report_details perd,
psp_eff_reports per ,
psp_eff_report_details perd2
WHERE per.effort_report_id = perd.effort_report_id
AND per.status_code IN ('N', 'A')
AND per.request_id = NVL(p_request_id,per.request_id)
AND perd.investigator_person_id  =p_investigator_person_id
AND per.effort_report_id = perd2.effort_report_id
AND perd.investigator_person_id <>  perd2.investigator_person_id;

l_show_hide_fyi_flag VARCHAR2(1);

l_num30_fmask	VARCHAR2(35);
l_error_count	NUMBER;
l_return_status	CHAR(1);
BEGIN

	g_request_id := fnd_global.conc_request_id;
	OPEN template_id_cur;
	FETCH template_id_cur INTO l_template_id, l_request_id, l_set_of_books_id;
	CLOSE template_id_cur;

	OPEN format_mask_cur(30);
	FETCH format_mask_cur INTO l_num30_fmask;
	CLOSE format_mask_cur;

	OPEN sort_option_cur(l_request_id);
	LOOP
		IF (sort_option_cur%ROWCOUNT = 0) THEN
			FETCH sort_option_cur INTO l_criteria_value1, l_sort_option1, l_sort_option_desc1, l_order_by_desc1;
		ELSE
			FETCH sort_option_cur INTO l_criteria_value1, l_sort_option2, l_sort_option_desc2, l_order_by_desc2;
		END IF;
		EXIT WHEN sort_option_cur%NOTFOUND;

		IF (sort_option_cur%ROWCOUNT = 1) THEN
			l_sort_option1 := ' ORDER BY ' || l_sort_option1;
		END IF;

		IF (l_sort_option2 IS NOT NULL) THEN
			l_sort_option1 := l_sort_option1 || ', ' || l_sort_option2 || ' ';
		END IF;
	END LOOP;
	CLOSE sort_option_cur;
	l_emp_sort_option := l_sort_option1;

	fnd_profile.get('ICX_DATE_FORMAT_MASK', l_icx_date_format);

	OPEN layout_type_cur;
	FETCH layout_type_cur INTO l_layout_type, l_display_flag;
	CLOSE layout_type_cur;

	OPEN get_segment_delimeter_cur;
	FETCH get_segment_delimeter_cur INTO l_segment_delimiter;
	CLOSE get_segment_delimeter_cur;

	OPEN get_segment_header_cur;
	l_gl_header := '';
	LOOP
		FETCH get_segment_header_cur INTO l_segment_header;
		EXIT WHEN get_segment_header_cur%NOTFOUND;

		l_gl_header := l_gl_header || l_segment_header;
	END LOOP;
	l_gl_header := SUBSTR(l_gl_header, 1, LENGTH(l_gl_header) - 1);
	CLOSE get_segment_header_cur;

	l_report_info := '<?xml version="1.0" ?><PSPERREP> ';

	query1 := 'SELECT TO_CHAR(fnd_date.canonical_to_date(fnd_date.date_to_canonical(prth.parameter_value_2)), ''' || l_icx_date_format
		|| ''') start_date, TO_CHAR(fnd_date.canonical_to_date(fnd_date.date_to_canonical(prth.parameter_value_3)), '''
		|| l_icx_date_format || ''') end_date, ''' || l_display_flag || ''' display_flag, ''' || l_gl_header || ''' gl_header, '
		|| 'TO_CHAR(SYSDATE, ''' || l_icx_date_format || ''') run_date '
		|| 'FROM psp_report_templates_h prth WHERE prth.request_id = ' || TO_CHAR(l_request_id);
	qryCtx1 := dbms_xmlgen.newContext(query1);
	dbms_xmlgen.setRowTag(qryCtx1, NULL);
	dbms_xmlgen.setRowSetTag(qryCtx1, 'G_REPORT_INFO');
	xmlresult1 := dbms_xmlgen.getXML(qryCtx1, dbms_xmlgen.NONE);
	dbms_xmlgen.closecontext(qryctx1);
	l_xml := xmlresult1;
	dbms_lob.write(l_xml, length(l_report_info), 1, l_report_info);
	l_resultOffset := DBMS_LOB.INSTR(xmlresult1,'>');
	dbms_lob.copy(l_xml, xmlresult1, dbms_lob.getlength(xmlresult1) - l_resultOffset, length(l_report_info), l_resultOffset +1);

	IF (l_layout_type = 'EMP') THEN

		dbms_lob.writeappend(l_xml, length('<LIST_G_PERSON> '), '<LIST_G_PERSON> ');

		IF (p_request_id IS NULL) THEN

			query1 := 'SELECT person_xml FROM psp_eff_reports per WHERE per.status_code IN (''A'', ''N'') '
				|| 'AND EXISTS (SELECT 1 FROM psp_eff_report_details perd, '
				|| 'psp_eff_report_approvals pera WHERE perd.effort_report_detail_id = pera.effort_report_detail_id AND '
				|| 'perd.effort_report_id = per.effort_report_id AND pera.wf_item_key = ' || TO_CHAR(p_wf_item_key)
				|| ' AND pera.approval_status <> ''R'')' || l_sort_option1;
		ELSE
			query1 := 'SELECT person_xml FROM psp_eff_reports per WHERE status_code IN (''A'', ''N'') AND '
				|| 'request_id = ' || TO_CHAR(l_request_id) || l_sort_option1;
		END IF;

		OPEN person_xml_cur FOR query1;
		LOOP
			FETCH person_xml_cur INTO l_person_xml;
			EXIT WHEN person_xml_cur%NOTFOUND;

			dbms_lob.copy(l_xml, l_person_xml, dbms_lob.getlength(l_person_xml), dbms_lob.getlength(l_xml), 1);
		END LOOP;
		CLOSE person_xml_cur;

		dbms_lob.writeappend(l_xml, length('</LIST_G_PERSON>'), '</LIST_G_PERSON>');
	ELSE

		OPEN sort_option2_cur(l_request_id);
		l_sort_option1 := NULL;
		l_sort_option2 := NULL;
		LOOP
			IF (sort_option2_cur%ROWCOUNT = 0) THEN
				FETCH sort_option2_cur INTO l_criteria_value1, l_sort_option1, l_sort_option_desc1, l_order_by_desc1;
			ELSE
				FETCH sort_option2_cur INTO l_criteria_value1, l_sort_option2, l_sort_option_desc2, l_order_by_desc2;
			END IF;
			EXIT WHEN sort_option2_cur%NOTFOUND;

			IF (sort_option2_cur%ROWCOUNT = 1) THEN
				l_sort_option1 := ' ORDER BY ' || l_sort_option1;
			END IF;

			IF (l_sort_option2 IS NOT NULL) THEN
				l_sort_option1 := l_sort_option1 || ', ' || l_sort_option2 || ' ';
			END IF;
		END LOOP;
		CLOSE sort_option2_cur;

		dbms_lob.writeappend(l_xml, length('<LIST_G_INVESTIGATOR> '), '<LIST_G_INVESTIGATOR> ');
		IF (p_request_id IS NULL) THEN
			query1 := 'SELECT investigator_person_id, investigator_name, investigator_org_name, investigator_primary_org_id, '
				|| 'TRIM(TO_CHAR(SUM(proposed_salary_amt), ''' || l_num30_fmask || ''')) total_pi_proposed_salary, '
				|| 'TRIM(TO_CHAR(SUM(actual_salary_amt), ''' || l_num30_fmask || ''')) total_pi_actual_salary FROM '
				|| 'psp_eff_report_details perd, psp_eff_report_approvals pera WHERE pera.effort_report_detail_id = '
				|| 'perd.effort_report_detail_id AND pera.wf_item_key = ' || TO_CHAR(p_wf_item_key)
				|| ' AND EXISTS (SELECT 1 FROM psp_eff_reports per WHERE per.effort_report_id = perd.effort_report_id '
				|| 'AND per.status_code IN (''A'', ''N'')) AND perd.investigator_person_id IS NOT NULL'
				|| ' GROUP BY investigator_person_id, investigator_name, investigator_org_name, investigator_primary_org_id'
				|| l_sort_option1;
		ELSE
			query1 := 'SELECT investigator_person_id, investigator_name, investigator_org_name, investigator_primary_org_id, '
				|| 'TRIM(TO_CHAR(SUM(proposed_salary_amt), ''' || l_num30_fmask || ''')) total_pi_proposed_salary, '
				|| 'TRIM(TO_CHAR(SUM(actual_salary_amt), ''' || l_num30_fmask || ''')) total_pi_actual_salary FROM '
				|| 'psp_eff_report_details perd, psp_eff_reports per WHERE per.effort_report_id = '
				|| 'perd.effort_report_id AND per.request_id = ' || TO_CHAR(p_request_id)
				|| ' AND per.status_code IN (''A'', ''N'') AND perd.investigator_person_id IS NOT NULL'
				|| ' GROUP BY investigator_person_id, investigator_name, investigator_org_name, investigator_primary_org_id'
				|| l_sort_option1;
		END IF;

		OPEN investigator_cur FOR query1;
		LOOP
			FETCH investigator_cur INTO l_investigator_id, l_investigator_name, l_investigator_org_name,
				l_investigator_primary_org_id, l_total_pi_proposed_salary, l_total_pi_actual_salary;
			EXIT WHEN investigator_cur%NOTFOUND;

			OPEN show_hide_FYI_lines_csr(p_request_id, l_investigator_id);
			FETCH show_hide_FYI_lines_csr INTO l_show_hide_fyi_flag ;
			IF (show_hide_FYI_lines_csr%NOTFOUND) THEN
			  l_show_hide_fyi_flag := 'N';
			END IF;
			CLOSE show_hide_FYI_lines_csr;


                        ---- 4429787
                     l_investigator_name := convert_xml_controls(l_investigator_name);
                     l_investigator_org_name := convert_xml_controls(l_investigator_org_name);

			dbms_lob.writeappend(l_xml, length('<G_INVESTIGATOR>
<INVESTIGATOR_PERSON_ID>' || TO_CHAR(l_investigator_id) || '</INVESTIGATOR_PERSON_ID>
<INVESTIGATOR_NAME>' || l_investigator_name || '</INVESTIGATOR_NAME>
<INVESTIGATOR_ORG_NAME>' || l_investigator_org_name || '</INVESTIGATOR_ORG_NAME>
<INVESTIGATOR_PRIMARY_ORG_ID>' || TO_CHAR(l_investigator_primary_org_id) || '</INVESTIGATOR_PRIMARY_ORG_ID>
<TOTAL_PI_PROPOSED_SALARY>' || l_total_pi_proposed_salary || '</TOTAL_PI_PROPOSED_SALARY>
<TOTAL_PI_ACTUAL_SALARY>' || l_total_pi_actual_salary || '</TOTAL_PI_ACTUAL_SALARY>
<SHOW_HIDE_FYI_LINES>' || l_show_hide_fyi_flag || '</SHOW_HIDE_FYI_LINES>
 '), '<G_INVESTIGATOR>
<INVESTIGATOR_PERSON_ID>' || TO_CHAR(l_investigator_id) || '</INVESTIGATOR_PERSON_ID>
<INVESTIGATOR_NAME>' || l_investigator_name || '</INVESTIGATOR_NAME>
<INVESTIGATOR_ORG_NAME>' || l_investigator_org_name || '</INVESTIGATOR_ORG_NAME>
<INVESTIGATOR_PRIMARY_ORG_ID>' || TO_CHAR(l_investigator_primary_org_id) || '</INVESTIGATOR_PRIMARY_ORG_ID>
<TOTAL_PI_PROPOSED_SALARY>' || l_total_pi_proposed_salary || '</TOTAL_PI_PROPOSED_SALARY>
<TOTAL_PI_ACTUAL_SALARY>' || l_total_pi_actual_salary || '</TOTAL_PI_ACTUAL_SALARY>
<SHOW_HIDE_FYI_LINES>' || l_show_hide_fyi_flag || '</SHOW_HIDE_FYI_LINES>
 ');

--			dbms_lob.writeappend(l_xml, length('<LIST_G_PERSON> '), '<LIST_G_PERSON> ');

			query2 := 'SELECT person_xml FROM psp_eff_reports per WHERE per.effort_report_id IN (SELECT perd.effort_report_id '
				|| 'FROM psp_eff_report_details perd WHERE perd.investigator_person_id = ' || TO_CHAR(l_investigator_id) || ')'
				||  '  AND request_id = ' || TO_CHAR(l_request_id) || ' AND status_code <> ''R''' || l_emp_sort_option;
			OPEN person_xml_cur FOR query2;
			LOOP
				FETCH person_xml_cur INTO l_person_xml;
				EXIT WHEN person_xml_cur%NOTFOUND;
				l_resultOffset := DBMS_LOB.INSTR(l_person_xml,'>');
				dbms_lob.copy(l_xml, l_person_xml, dbms_lob.getlength(l_person_xml), dbms_lob.getlength(l_xml), 1);
			END LOOP;
			CLOSE person_xml_cur;

--			dbms_lob.writeappend(l_xml, length('</LIST_G_PERSON> '), '</LIST_G_PERSON> ');

--Bug 4334816: START
-- Including the WorkFlow Note in Pdf

/*			query2 := 'SELECT DISTINCT approver_order_num approval_sequence, NVL(wf_role_display_name, wf_role_name) '
				|| 'approver_name, TO_CHAR(response_date, ''' || l_icx_date_format || ''')'
				|| ' approval_date FROM psp_eff_report_approvals pera, psp_eff_reports per'
				|| ',psp_eff_report_details perd WHERE perd.effort_report_detail_id=pera.effort_report_detail_id AND '
				|| 'per.effort_report_id = perd.effort_report_id AND per.request_id = ' || TO_CHAR(l_request_id)
				|| ' AND perd.investigator_person_id = ' || TO_CHAR(l_investigator_id)
				|| ' ORDER BY approver_order_num DESC';
*/

			query2 := 'SELECT DISTINCT approver_order_num approval_sequence, NVL(wf_role_display_name, wf_role_name) '
				|| 'approver_name, TO_CHAR(response_date, ''' || l_icx_date_format || ''')'
				|| ' approval_date, wfna.TEXT_VALUE note FROM psp_eff_report_approvals pera, psp_eff_reports per'
				|| ',psp_eff_report_details perd , WF_NOTIFICATION_ATTRIBUTES wfna WHERE perd.effort_report_detail_id=pera.effort_report_detail_id AND '
				|| 'per.effort_report_id = perd.effort_report_id AND per.request_id = ' || TO_CHAR(l_request_id)
				|| ' AND perd.investigator_person_id = ' || TO_CHAR(l_investigator_id)
		                ||' AND wfna.NAME(+) =''WF_NOTE'' AND wfna.NOTIFICATION_ID(+) = pera.NOTIFICATION_ID '
				|| ' ORDER BY approver_order_num DESC';
--Bug 4334816: END

			qryCtx1 := dbms_xmlgen.newContext(query2);
			dbms_xmlgen.setRowTag(qryCtx1, 'G_APPROVER');
			dbms_xmlgen.setRowSetTag(qryCtx1, 'LIST_G_APPROVER');
			xmlresult1 := dbms_xmlgen.getXML(qryCtx1, dbms_xmlgen.NONE);
			dbms_xmlgen.closecontext(qryctx1);
			IF (dbms_lob.getlength(xmlresult1) > 0) THEN
				l_resultOffset := DBMS_LOB.INSTR(xmlresult1,'>');
				dbms_lob.copy(l_xml, xmlresult1, dbms_lob.getlength(xmlresult1) - l_resultOffset, dbms_lob.getlength(l_xml), l_resultOffset +1);
			END IF;
			dbms_lob.writeappend(l_xml, length('</G_INVESTIGATOR> '), '</G_INVESTIGATOR> ');

		END LOOP;
		CLOSE investigator_cur;

		dbms_lob.writeappend(l_xml, length('</LIST_G_INVESTIGATOR> '), '</LIST_G_INVESTIGATOR> ');
	END IF;

	dbms_lob.writeappend(l_xml, length('</PSPERREP>'), '</PSPERREP>');

    RETURN l_xml;
EXCEPTION
	WHEN OTHERS THEN
		OPEN add_report_error_cur(sqlerrm);
		FETCH add_report_error_cur INTO l_error_count;
		CLOSE add_report_error_cur;

		IF (NVL(l_error_count, 0) = 0) THEN
			psp_general.add_report_error
				(p_request_id		=>	l_request_id,
				p_message_level		=>	'E',
				p_source_id		=>	NULL,
				p_retry_request_id	=>	NULL,
				p_pdf_request_id	=>	g_request_id,
				p_error_message		=>	sqlerrm,
				p_return_status		=>	l_return_status);
		END IF;
		RAISE;
END generate_approver_xml;

FUNCTION generate_person_xml	(p_person_id			IN	NUMBER,
				p_template_id			IN	NUMBER,
				p_effort_report_id		IN	NUMBER,
				p_request_id			IN	NUMBER,
				p_set_of_books_id		IN	NUMBER,
				p_full_name			IN	VARCHAR2,
				p_employee_number		IN	VARCHAR2,
				p_mailstop			IN	VARCHAR2,
				p_emp_primary_org_name		IN	VARCHAR2,
				p_emp_primary_org_id		IN	NUMBER,
				p_currency_code			IN	VARCHAR2
) RETURN CLOB IS
qryCtx1				dbms_xmlgen.ctxType;
qryCtx2				dbms_xmlquery.ctxType;
query1				VARCHAR2(8000);
xmlresult1			CLOB;
l_xml				CLOB;
l_resultOffset		INT;
l_assignment_id		NUMBER;
l_assignment_number	VARCHAR2(30);
l_er_check		VARCHAR2(1000);
l_assignment_check	VARCHAR2(1000);
l_sort_option1		VARCHAR2(200);
l_sort_option2		VARCHAR2(200);
l_criteria_value1	VARCHAR2(30);
l_employee_info		VARCHAR2(2000);
l_layout_type		CHAR(3);

CURSOR	layout_type_cur IS
SELECT	SUBSTR(report_template_code, 6, 3) layout_type
FROM	psp_report_templates_h prt
WHERE	request_id = p_request_id;

/*
CURSOR	sort_option_cur (p_template_id IN NUMBER) IS
SELECT	DISTINCT prtd.criteria_value1,
	plo.value1 || ' ' || DECODE(prtd.criteria_value2, 'A', 'ASC', 'DESC') sort_option
FROM	psp_report_template_details prtd,
        fnd_lookup_values flv1,
        fnd_lookup_values flv2,
        psp_layout_options plo
WHERE	prtd.template_id = p_template_id
AND     flv1.lookup_code = prtd.criteria_lookup_code
AND		flv1.lookup_type = 'PSP_SORTING_CRITERIA'
AND		prtd.criteria_lookup_type = 'PSP_SORTING_CRITERIA'
AND		flv2.lookup_type = 'PSP_ORDERING_CRITERIA'
AND     flv2.lookup_code = prtd.criteria_value2
ANd     prtd.criteria_lookup_code = plo.layout_lookup_code
AND		plo.value1 LIKE 'perd.%'
ORDER BY prtd.criteria_value1;
*/
-- Bug 4244924 YALE ENHANCEMENTS
CURSOR sort_option_cur (p_request_id IN NUMBER, p_business_group_id IN NUMBER) IS
select  prtdh.criteria_value1,
decode (substr(prtdh.CRITERIA_LOOKUP_CODE,1,7),'SEGMENT','GL_'||prtdh.CRITERIA_LOOKUP_CODE,plo.VALUE1)
|| ' ' || DECODE(criteria_value2, 'A', 'ASC', 'DESC')   --decode plo.VALUE1
from psp_report_template_details_h prtdh ,
psp_report_templates_h prth
,psp_layout_options plo
where prth.request_id= p_request_id-- 125338 --125188
and prth.request_id = prtdh.request_id
and prtdh.CRITERIA_LOOKUP_TYPE ='PSP_SORTING_CRITERIA'
and prtdh.CRITERIA_LOOKUP_TYPE  = plo.LAYOUT_LOOKUP_TYPE
and prth.REPORT_TEMPLATE_CODE = plo.REPORT_TEMPLATE_CODE
and plo.PTAOE_STORED_IN_GL_FLAG = PSP_GENERAL.GET_CONFIGURATION_OPTION_VALUE(p_business_group_id,'PSP_USE_GL_PTAOE_MAPPING')
and (plo.LAYOUT_LOOKUP_CODE = prtdh.CRITERIA_LOOKUP_CODE
    OR plo.LAYOUT_LOOKUP_CODE = 'GL' and prtdh.CRITERIA_LOOKUP_CODE like 'SEGMENT%')
AND plo.value1 LIKE 'perd.%'
ORDER BY prtdh.criteria_value1;


CURSOR	assign_cur (p_effort_report_id IN NUMBER) IS
SELECT	DISTINCT assignment_id,
		assignment_number
FROM	psp_eff_report_details
WHERE	effort_report_id = p_effort_report_id
ORDER BY assignment_number ASC;			-- Bug 4247734

CURSOR	add_report_error_cur (p_sqlerrm IN VARCHAR2) IS
SELECT	1
FROM	psp_report_errors
WHERE	request_id = p_request_id
AND	message_level = 'E'
AND	error_message = SUBSTR(p_sqlerrm, 1, 2000)
AND	pdf_request_id = g_request_id;

/* Added for Hospital effort report */
CURSOR grouping_category_csr(p_assignment_id IN NUMBER) IS
SELECT distinct perd.grouping_category, plo.layout_option_order
FROM   psp_eff_report_details perd,
psp_layout_options plo
WHERE  effort_report_id = p_effort_report_id
AND    NVL(assignment_id,-1) = NVL(p_assignment_id,-1)
AND    plo.layout_lookup_type ='PSP_EFFORT_CATEGORY'
AND    plo.LAYOUT_LOOKUP_CODE = perd.grouping_category
ORDER BY plo.layout_option_order;

/* Added for TGEN  Bug 6864426 for pre-approved effort report*/
CURSOR	initiator_name_cur IS
SELECT	ppf.full_name
FROM	per_people_f ppf,
        fnd_user fu,
	fnd_concurrent_requests fcr
WHERE	fu.user_id = fcr.requested_by
AND     fu.employee_id = ppf.person_id
AND	fcr.request_id = p_request_id;


l_num25_fmask	VARCHAR2(30);
l_icx_date_format	VARCHAR2(20);
l_error_count	NUMBER;
l_return_status	CHAR(1);
l_business_group_id Number := FND_PROFILE.VALUE('PER_BUSINESS_GROUP_ID');
l_grouping_category varchar2(30);   -- Added for Hospital effort report
l_layout_option_order Number;
l_approval_type  psp_report_templates.approval_type%TYPE; --Bug 6864426
l_initiator_name per_people_f.full_name%TYPE;   --Bug 6864426

BEGIN
	g_request_id := fnd_global.conc_request_id;
	OPEN layout_type_cur;
	FETCH layout_type_cur INTO l_layout_type;
	CLOSE layout_type_cur;

	--Bug 6864426
	OPEN initiator_name_cur;
	FETCH initiator_name_cur INTO l_initiator_name;
	CLOSE initiator_name_cur;


	l_num25_fmask := fnd_currency.get_format_mask(p_currency_code, 25);
	fnd_profile.get('ICX_DATE_FORMAT_MASK', l_icx_date_format);

	OPEN sort_option_cur(p_template_id, l_business_group_id);
	LOOP
		IF (sort_option_cur%ROWCOUNT = 0) THEN
			FETCH sort_option_cur INTO l_criteria_value1, l_sort_option1;
		ELSE
			FETCH sort_option_cur INTO l_criteria_value1, l_sort_option2;
		END IF;
		EXIT WHEN sort_option_cur%NOTFOUND;

		IF (sort_option_cur%ROWCOUNT = 1) THEN
			l_sort_option1 := ' ORDER BY ' || l_sort_option1;
		END IF;

		IF (l_sort_option2 IS NOT NULL) THEN
			l_sort_option1 := l_sort_option1 || ', ' || l_sort_option2;
		END IF;
	END LOOP;
	CLOSE sort_option_cur;

	l_er_check := ' AND NOT EXISTS (SELECT 1 FROM psp_eff_report_details perd1, psp_eff_report_approvals pera1 '
		|| 'WHERE perd.effort_report_id = perd1.effort_report_id AND perd1.effort_report_detail_id = pera1.effort_report_detail_id '
		|| 'AND pera1.approval_status = ''R'') '
		|| 'AND NVL(pera.approver_order_num, 1) = (SELECT NVL(MAX(pera1.approver_order_num), 1) FROM psp_eff_report_approvals pera1 '
		|| 'WHERE pera1.effort_report_detail_id = perd.effort_report_detail_id)';

	IF (l_layout_type = 'EMP') THEN
	l_employee_info := '
<G_PERSON>
<PERSON_ID>' || TO_CHAR(p_person_id) || '</PERSON_ID>
<EMPLOYEE_NAME>' || convert_xml_controls(p_full_name) || '</EMPLOYEE_NAME>
<EMPLOYEE_NUMBER>' || convert_xml_controls(p_employee_number) || '</EMPLOYEE_NUMBER>
<MAILSTOP>' || convert_xml_controls(p_mailstop) || '</MAILSTOP>
<ORGANIZATION_NAME>' || convert_xml_controls(p_emp_primary_org_name) || '</ORGANIZATION_NAME>
<ORGANIZATION_ID>' || p_emp_primary_org_id || '</ORGANIZATION_ID>
';

	query1 := 'select distinct pera.eff_information1, pera.eff_information2, pera.eff_information3,pera.eff_information4, pera.eff_information5, '
                || ' pera.eff_information6,pera.eff_information7, pera.eff_information8 , pera.eff_information9,pera.eff_information10, '
                || ' pera.eff_information11, pera.eff_information12, pera.eff_information13, pera.eff_information14, pera.eff_information15 '
                || ' FROM   psp_eff_report_details perd, '
                || ' psp_eff_report_approvals pera '
                || ' WHERE  perd.effort_report_detail_id = pera.effort_report_detail_id '
                || ' AND    perd.effort_report_id = ' || p_effort_report_id
                || ' AND    APPROVER_ORDER_NUM = (SELECT max(APPROVER_ORDER_NUM) '
                || '                             FROM   psp_eff_report_approvals pera2, '
                || '                             psp_eff_report_details perd2 '
                || '                             WHERE  pera2.effort_report_detail_id = perd2.effort_report_detail_id '
                || '                             AND    perd2.effort_report_id = perd.effort_report_id) ';

        qryCtx2 := dbms_xmlquery.newContext(query1);
	dbms_xmlquery.setRowTag(qryCtx2, NULL);
	dbms_xmlquery.setRowSetTag(qryCtx2, 'EMP_DFF');
	xmlresult1 := dbms_xmlquery.getXML(qryCtx2, dbms_xmlgen.NONE);
	dbms_xmlquery.closecontext(qryctx2);
    	l_xml := xmlresult1;
	dbms_lob.write(l_xml, length(l_employee_info), 1, l_employee_info);
    	l_resultOffset := DBMS_LOB.INSTR(xmlresult1,'>');
	dbms_lob.copy(l_xml, xmlresult1, dbms_lob.getlength(xmlresult1) - l_resultOffset, length(l_employee_info), l_resultOffset +1);



	query1 := 'select TRIM(TO_CHAR(SUM(NVL(proposed_salary_amt, 0)), ''' || l_num25_fmask || ''')) total_emp_proposed_salary, '
		|| 'TRIM(TO_CHAR(SUM(NVL(proposed_effort_percent, 0)), ''999G990D00'')) total_emp_proposed_effort, '
		|| 'TRIM(TO_CHAR(SUM(NVL(committed_cost_share, 0)), ''999G990D00'')) total_emp_cost_share, '
		|| 'TRIM(TO_CHAR(SUM(NVL(actual_salary_amt, 0)), ''' || l_num25_fmask || ''')) total_emp_actual_salary, '
		|| 'TRIM(TO_CHAR(SUM(NVL(payroll_percent, 0)), ''999G990D00'')) total_emp_actual_effort, '
		|| 'TRIM(TO_CHAR(SUM(NVL(pera.overwritten_effort_percent, 0)), ''999G990D00'')) total_emp_overwritten_effort, '
		|| 'TRIM(TO_CHAR(SUM(NVL(pera.actual_cost_share, 0)), ''999G990D00'')) total_emp_actual_cost_share '
		|| 'FROM psp_eff_report_details perd, psp_eff_report_approvals pera where '
		|| 'perd.effort_report_detail_id = pera.effort_report_detail_id (+) AND perd.effort_report_id = '
		|| TO_CHAR(p_effort_report_id) || ' AND NVL(pera.approval_status, ''A'') IN ( ''P'', ''A'')' || l_er_check;
        qryCtx1 := dbms_xmlgen.newContext(query1);
	dbms_xmlgen.setRowTag(qryCtx1, NULL);
	dbms_xmlgen.setRowSetTag(qryCtx1, 'TOTAL_EMP');
	xmlresult1 := dbms_xmlgen.getXML(qryCtx1, dbms_xmlgen.NONE);
	dbms_xmlgen.closecontext(qryctx1);
	l_resultOffset := DBMS_LOB.INSTR(xmlresult1,'>');
        dbms_lob.copy(l_xml, xmlresult1, dbms_lob.getlength(xmlresult1) - l_resultOffset, dbms_lob.getlength(l_xml), l_resultOffset +1);
	dbms_lob.writeappend(l_xml, length('<LIST_G_ASSIGNMENT> '), '<LIST_G_ASSIGNMENT> ');

	OPEN assign_cur(p_effort_report_id);
	LOOP
		FETCH assign_cur INTO l_assignment_id, l_assignment_number;
		EXIT WHEN assign_cur%NOTFOUND;

		l_assignment_check := l_er_check;
		IF (l_assignment_id IS NOT NULL) THEN
			l_assignment_check := l_assignment_check || ' AND assignment_id = ' || TO_CHAR(l_assignment_id);
		END IF;
                 --- applied strip controls for 4429787
		dbms_lob.writeappend(l_xml, length('<G_ASSIGNMENT><ASSIGNMENT_ID>' || TO_CHAR(l_assignment_id) ||
			'</ASSIGNMENT_ID><ASSIGNMENT_NUMBER>' || convert_xml_controls(l_assignment_number) || '</ASSIGNMENT_NUMBER> '),
			'<G_ASSIGNMENT><ASSIGNMENT_ID>' || TO_CHAR(l_assignment_id) || '</ASSIGNMENT_ID><ASSIGNMENT_NUMBER>' ||
			convert_xml_controls(l_assignment_number) || '</ASSIGNMENT_NUMBER> ');

		query1 := 'select TRIM(TO_CHAR(SUM(NVL(proposed_salary_amt, 0)), ''' || l_num25_fmask || ''')) total_asg_proposed_salary, '
			|| 'TRIM(TO_CHAR(SUM(NVL(proposed_effort_percent, 0)), ''999G990D00'')) total_asg_proposed_effort, '
			|| 'TRIM(TO_CHAR(SUM(NVL(committed_cost_share, 0)), ''999G990D00'')) total_asg_cost_share, '
			|| 'TRIM(TO_CHAR(SUM(NVL(actual_salary_amt, 0)), ''' || l_num25_fmask || ''')) total_asg_actual_salary, '
			|| 'TRIM(TO_CHAR(SUM(NVL(payroll_percent, 0)), ''999G990D00'')) total_asg_actual_effort, '
			|| 'TRIM(TO_CHAR(SUM(NVL(pera.overwritten_effort_percent, 0)), ''999G990D00'')) total_asg_overwritten_effort, '
			|| 'TRIM(TO_CHAR(SUM(NVL(pera.actual_cost_share, 0)), ''999G990D00'')) total_asg_actual_cost_share '
			|| 'FROM psp_eff_report_details perd, psp_eff_report_approvals pera where '
			|| 'perd.effort_report_detail_id = pera.effort_report_detail_id (+) AND perd.effort_report_id = '
			|| TO_CHAR(p_effort_report_id) || ' AND NVL(pera.approval_status, ''A'') IN (''P'', ''A'')' || l_assignment_check;
		qryCtx1 := dbms_xmlgen.newContext(query1);
		dbms_xmlgen.setRowTag(qryCtx1, NULL);
		dbms_xmlgen.setRowSetTag(qryCtx1, 'TOTAL_ASG');
		xmlresult1 := dbms_xmlgen.getXML(qryCtx1, dbms_xmlgen.NONE);
		dbms_xmlgen.closecontext(qryctx1);
		l_resultOffset := DBMS_LOB.INSTR(xmlresult1,'>');
		dbms_lob.copy(l_xml, xmlresult1, dbms_lob.getlength(xmlresult1) - l_resultOffset, dbms_lob.getlength(l_xml), l_resultOffset +1);


/* Changes for Hospital effort report :START  */
	dbms_lob.writeappend(l_xml, length('<LIST_G_CATEGORY> '), '<LIST_G_CATEGORY> ');

		OPEN grouping_category_csr(l_assignment_id);
		LOOP
  			FETCH grouping_category_csr INTO l_grouping_category, l_layout_option_order;
			EXIT WHEN grouping_category_csr%NOTFOUND;
			--dbms_lob.writeappend(l_xml, length('<G_CATEGORY> '), '<G_CATEGORY> ');

			query1 := 'select TRIM(TO_CHAR(SUM(NVL(proposed_salary_amt, 0)), ''' || l_num25_fmask || ''')) total_proposed_salary, '
				|| 'TRIM(TO_CHAR(SUM(NVL(proposed_effort_percent, 0)), ''999G990D00'')) total_proposed_effort, '
				|| 'TRIM(TO_CHAR(SUM(NVL(committed_cost_share, 0)), ''999G990D00'')) total_cost_share, '
				|| 'TRIM(TO_CHAR(SUM(NVL(actual_salary_amt, 0)), ''' || l_num25_fmask || ''')) total_actual_salary, '
				|| 'TRIM(TO_CHAR(SUM(NVL(payroll_percent, 0)), ''999G990D00'')) total_actual_effort, '
				|| 'TRIM(TO_CHAR(SUM(NVL(pera.overwritten_effort_percent, 0)), ''999G990D00'')) total_overwritten_effort, '
				|| 'TRIM(TO_CHAR(SUM(NVL(pera.actual_cost_share, 0)), ''999G990D00'')) total_actual_cost_share, '
				|| 'TRIM(MAX(lookup.lookup_code)) category_code, '
				|| 'TRIM(MAX(lookup.meaning)) category_desc '
				|| 'FROM psp_eff_report_details perd, psp_eff_report_approvals pera, '
				|| 'psp_layout_options plo,  fnd_lookup_values_vl lookup, psp_report_templates_h prth '
				|| 'WHERE perd.grouping_category = plo.layout_lookup_code '
				|| 'AND plo.layout_lookup_code = lookup.lookup_code '
				|| 'AND plo.layout_lookup_type =''PSP_EFFORT_CATEGORY'' '
				|| 'AND lookup.lookup_type = ''PSP_EFFORT_CATEGORY'' '
				|| 'AND lookup.enabled_flag = ''Y'' '
				|| 'AND sysdate between NVL(lookup.start_date_active,to_date(''01/01/1951'',''DD/MM/RRRR'')) '
				|| 'AND NVL(lookup.end_date_active,to_date(''31/12/4712'',''DD/MM/RRRR'')) '
                                || 'AND perd.grouping_category = ''' || l_grouping_category || ''' '
				|| 'AND prth.report_template_code = plo.report_template_code '
				|| 'AND prth.request_id = ' || p_request_id
				|| ' AND perd.effort_report_detail_id = pera.effort_report_detail_id (+) AND effort_report_id = '
				|| TO_CHAR(p_effort_report_id) || ' AND NVL(pera.approval_status, ''A'') IN (''P'', ''A'')' || l_assignment_check;

			qryCtx1 := dbms_xmlgen.newContext(query1);
			dbms_xmlgen.setRowTag(qryCtx1, 'G_CATEGORY');
			dbms_xmlgen.setRowSetTag(qryCtx1, NULL);
			xmlresult1 := dbms_xmlgen.getXML(qryCtx1, dbms_xmlgen.NONE);
			dbms_xmlgen.closecontext(qryctx1);
			xmlresult1 := SUBSTR(xmlresult1, 1, LENGTH(xmlresult1) - 15);
--			l_resultOffset := DBMS_LOB.INSTR(xmlresult1,'>');
			dbms_lob.copy(l_xml, xmlresult1, dbms_lob.getlength(xmlresult1) - l_resultOffset, dbms_lob.getlength(l_xml), l_resultOffset +1);


		query1 := 'SELECT TRIM(TO_CHAR(perd.ACTUAL_SALARY_AMT, ''' || l_num25_fmask || ''')) actual_salary_amt, '
			|| 'TRIM(TO_CHAR(perd.PAYROLL_PERCENT, ''999G990D00'')) payroll_percent, '
			|| 'TRIM(TO_CHAR(perd.PROPOSED_SALARY_AMT, ''' || l_num25_fmask || ''')) proposed_salary_amt, '
			|| 'TRIM(TO_CHAR(perd.PROPOSED_EFFORT_PERCENT, ''999G990D00'')) proposed_effort_percent, '
			|| 'TRIM(TO_CHAR(perd.COMMITTED_COST_SHARE, ''999G990D00'')) committed_cost_share, '
			|| 'TRIM(TO_CHAR(perd.SCHEDULE_START_DATE, ''' || l_icx_date_format || ''')) schedule_start_date, '
			|| 'TRIM(TO_CHAR(perd.SCHEDULE_END_DATE, ''' || l_icx_date_format || ''')) schedule_end_date, '
			|| 'perd.*, TRIM(TO_CHAR(NVL(pera.overwritten_effort_percent, 0), ''999G990D00'')) overwritten_effort_percent, '
			|| 'TRIM(TO_CHAR(NVL(pera.actual_cost_share, 0), ''999G990D00'')) actual_cost_share, '
			|| 'pera.pera_information1 pera_information1, pera.pera_information2, pera.pera_information3, pera.pera_information4, pera.pera_information5, '
			|| 'pera.pera_information6, pera.pera_information7, pera.pera_information8, pera.pera_information9, pera.pera_information10, '
			|| 'pera.pera_information11, pera.pera_information12, pera.pera_information13, pera.pera_information14, pera.pera_information15, '
			|| 'pera.pera_information16, pera.pera_information17, pera.pera_information8, pera.pera_information19, pera.pera_information20 '
			|| 'FROM psp_eff_report_details perd, '
			|| 'psp_eff_report_approvals pera WHERE perd.effort_report_detail_id = pera.effort_report_detail_id (+) AND effort_report_id = '
			|| TO_CHAR(p_effort_report_id) || ' AND NVL(pera.approval_status, ''A'') IN (''P'', ''A'')'
                        || 'AND perd.grouping_category = ''' || l_grouping_category || ''' '
                        || l_assignment_check || l_sort_option1;
		qryCtx1 := dbms_xmlgen.newContext(query1);
		dbms_xmlgen.setRowTag(qryCtx1, 'G_CATEGORYDETAILS');
		dbms_xmlgen.setRowSetTag(qryCtx1, 'LIST_G_CATEGORYDETAILS');
		xmlresult1 := dbms_xmlgen.getXML(qryCtx1, dbms_xmlgen.NONE);
		dbms_xmlgen.closecontext(qryctx1);
		IF (dbms_lob.getlength(xmlresult1) > 0) THEN
			l_resultOffset := DBMS_LOB.INSTR(xmlresult1,'>');
			dbms_lob.copy(l_xml, xmlresult1, dbms_lob.getlength(xmlresult1) - l_resultOffset, dbms_lob.getlength(l_xml), l_resultOffset +1);
		END IF;


			dbms_lob.writeappend(l_xml, length('</G_CATEGORY> '), '</G_CATEGORY> ');

		END LOOP;
		CLOSE grouping_category_csr;
	dbms_lob.writeappend(l_xml, length('</LIST_G_CATEGORY> '), '</LIST_G_CATEGORY> ');

/*

		query1 := 'select TRIM(TO_CHAR(SUM(NVL(proposed_salary_amt, 0)), ''' || l_num25_fmask || ''')) total_spon_proposed_salary, '
			|| 'TRIM(TO_CHAR(SUM(NVL(proposed_effort_percent, 0)), ''999G990D00'')) total_spon_proposed_effort, '
			|| 'TRIM(TO_CHAR(SUM(NVL(committed_cost_share, 0)), ''999G990D00'')) total_spon_cost_share, '
			|| 'TRIM(TO_CHAR(SUM(NVL(actual_salary_amt, 0)), ''' || l_num25_fmask || ''')) total_spon_actual_salary, '
			|| 'TRIM(TO_CHAR(SUM(NVL(payroll_percent, 0)), ''999G990D00'')) total_spon_actual_effort, '
			|| 'TRIM(TO_CHAR(SUM(NVL(pera.overwritten_effort_percent, 0)), ''999G990D00'')) total_spon_overwritten_effort, '
			|| 'TRIM(TO_CHAR(SUM(NVL(pera.actual_cost_share, 0)), ''999G990D00'')) total_spon_actual_cost_share '
			|| 'FROM psp_eff_report_details perd, psp_eff_report_approvals pera '
			|| 'WHERE (perd.project_id IS NOT NULL OR perd.task_id IS NOT NULL OR perd.award_id '
			|| 'IS NOT NULL OR perd.expenditure_organization_id IS NOT NULL OR perd.expenditure_type IS NOT NULL) AND EXISTS '
			|| '(SELECT 1 FROM pa_projects_all ppa, gms_project_types_all gpta WHERE gpta.project_type = ppa.project_type AND '
			|| 'ppa.project_id = perd.project_id AND ppa.project_type <> ''AWARD_PROJECT'' AND NVL(gpta.sponsored_flag, ''N'') ='
			|| '''Y'') AND perd.effort_report_detail_id = pera.effort_report_detail_id (+) AND effort_report_id = '
			|| TO_CHAR(p_effort_report_id) || ' AND NVL(pera.approval_status, ''A'') IN (''P'', ''A'')' || l_assignment_check;
		qryCtx1 := dbms_xmlgen.newContext(query1);
		dbms_xmlgen.setRowTag(qryCtx1, NULL);
		dbms_xmlgen.setRowSetTag(qryCtx1, 'TOTAL_SPONSORED');
		xmlresult1 := dbms_xmlgen.getXML(qryCtx1, dbms_xmlgen.NONE);
		dbms_xmlgen.closecontext(qryctx1);
		l_resultOffset := DBMS_LOB.INSTR(xmlresult1,'>');
		dbms_lob.copy(l_xml, xmlresult1, dbms_lob.getlength(xmlresult1) - l_resultOffset, dbms_lob.getlength(l_xml), l_resultOffset +1);

		query1 := 'select TRIM(TO_CHAR(SUM(NVL(proposed_salary_amt, 0)), ''' || l_num25_fmask || ''')) total_nspon_proposed_salary, '
			|| 'TRIM(TO_CHAR(SUM(NVL(proposed_effort_percent, 0)), ''999G990D00'')) total_nspon_proposed_effort, '
			|| 'TRIM(TO_CHAR(SUM(NVL(committed_cost_share, 0)), ''999G990D00'')) total_nspon_cost_share, '
			|| 'TRIM(TO_CHAR(SUM(NVL(actual_salary_amt, 0)), ''' || l_num25_fmask || ''')) total_nspon_actual_salary, '
			|| 'TRIM(TO_CHAR(SUM(NVL(payroll_percent, 0)), ''999G990D00'')) total_nspon_actual_effort, '
			|| 'TRIM(TO_CHAR(SUM(NVL(pera.overwritten_effort_percent, 0)), ''999G990D00'')) total_nspon_overwritten_effort, '
			|| 'TRIM(TO_CHAR(SUM(NVL(pera.actual_cost_share, 0)), ''999G990D00'')) total_nspon_actual_cost_share '
			|| 'FROM psp_eff_report_details perd, psp_eff_report_approvals pera '
			|| 'WHERE (perd.project_id IS NOT NULL OR perd.task_id IS NOT NULL OR perd.award_id '
			|| 'IS NOT NULL OR perd.expenditure_organization_id IS NOT NULL OR perd.expenditure_type IS NOT NULL) AND EXISTS '
			|| '(SELECT 1 FROM pa_projects_all ppa, gms_project_types_all gpta WHERE gpta.project_type (+) = ppa.project_type AND '
			|| 'ppa.project_id = perd.project_id AND ppa.project_type <> ''AWARD_PROJECT'' AND NVL(gpta.sponsored_flag, ''N'') ='
			|| '''N'') AND perd.effort_report_detail_id = pera.effort_report_detail_id (+) AND effort_report_id = '
			|| TO_CHAR(p_effort_report_id) || ' AND NVL(pera.approval_status, ''A'') IN (''P'', ''A'')' || l_assignment_check;
		qryCtx1 := dbms_xmlgen.newContext(query1);
		dbms_xmlgen.setRowTag(qryCtx1, NULL);
		dbms_xmlgen.setRowSetTag(qryCtx1, 'TOTAL_NON_SPONSORED');
		xmlresult1 := dbms_xmlgen.getXML(qryCtx1, dbms_xmlgen.NONE);
		dbms_xmlgen.closecontext(qryctx1);
		l_resultOffset := DBMS_LOB.INSTR(xmlresult1,'>');
		dbms_lob.copy(l_xml, xmlresult1, dbms_lob.getlength(xmlresult1) - l_resultOffset, dbms_lob.getlength(l_xml), l_resultOffset +1);

		query1 := 'select TRIM(TO_CHAR(SUM(NVL(proposed_salary_amt, 0)), ''' || l_num25_fmask || ''')) total_gl_proposed_salary, '
			|| 'TRIM(TO_CHAR(SUM(NVL(proposed_effort_percent, 0)), ''999G990D00'')) total_gl_proposed_effort, '
			|| 'TRIM(TO_CHAR(SUM(NVL(committed_cost_share, 0)), ''999G990D00'')) total_gl_cost_share, '
			|| 'TRIM(TO_CHAR(SUM(NVL(actual_salary_amt, 0)), ''' || l_num25_fmask || ''')) total_gl_actual_salary, '
			|| 'TRIM(TO_CHAR(SUM(NVL(payroll_percent, 0)), ''999G990D00'')) total_gl_actual_effort, '
			|| 'TRIM(TO_CHAR(SUM(NVL(pera.overwritten_effort_percent, 0)), ''999G990D00'')) total_gl_overwritten_effort, '
			|| 'TRIM(TO_CHAR(SUM(NVL(pera.actual_cost_share, 0)), ''999G990D00'')) total_gl_actual_cost_share '
			|| 'FROM psp_eff_report_details perd, psp_eff_report_approvals pera '
			|| 'WHERE perd.effort_report_detail_id = pera.effort_report_detail_id (+) AND '
			|| '(perd.gl_segment1 IS NOT NULL OR perd.gl_segment2 IS NOT NULL OR perd.gl_segment3 IS NOT NULL OR perd.gl_segment4 '
			|| 'IS NOT NULL OR perd.gl_segment5 IS NOT NULL OR perd.gl_segment6 IS NOT NULL OR perd.gl_segment7 IS NOT NULL OR '
			|| 'perd.gl_segment8 IS NOT NULL OR perd.gl_segment9 IS NOT NULL OR perd.gl_segment10 IS NOT NULL OR perd.gl_segment11'
			|| ' IS NOT NULL OR perd.gl_segment12 IS NOT NULL OR perd.gl_segment13 IS NOT NULL OR perd.gl_segment14 IS NOT NULL OR'
			|| ' perd.gl_segment15 IS NOT NULL OR perd.gl_segment16 IS NOT NULL OR perd.gl_segment17 IS NOT NULL OR '
			|| 'perd.gl_segment18 IS NOT NULL OR perd.gl_segment19 IS NOT NULL OR perd.gl_segment20 IS NOT NULL OR '
			|| 'perd.gl_segment21 IS NOT NULL OR perd.gl_segment22 IS NOT NULL OR perd.gl_segment23 IS NOT NULL OR '
			|| 'perd.gl_segment24 IS NOT NULL OR perd.gl_segment25 IS NOT NULL OR perd.gl_segment26 IS NOT NULL OR '
			|| 'perd.gl_segment27 IS NOT NULL OR perd.gl_segment28 IS NOT NULL OR perd.gl_segment29 IS NOT NULL OR '
			|| 'perd.gl_segment30 IS NOT NULL) AND effort_report_id = ' || TO_CHAR(p_effort_report_id)
			|| ' AND NVL(pera.approval_status, ''A'') IN (''P'', ''A'')' || l_assignment_check;
		qryCtx1 := dbms_xmlgen.newContext(query1);
		dbms_xmlgen.setRowTag(qryCtx1, NULL);
		dbms_xmlgen.setRowSetTag(qryCtx1, 'TOTAL_GL');
		xmlresult1 := dbms_xmlgen.getXML(qryCtx1, dbms_xmlgen.NONE);
		dbms_xmlgen.closecontext(qryctx1);
		l_resultOffset := DBMS_LOB.INSTR(xmlresult1,'>');
		dbms_lob.copy(l_xml, xmlresult1, dbms_lob.getlength(xmlresult1) - l_resultOffset, dbms_lob.getlength(l_xml), l_resultOffset +1);

		query1 := 'SELECT TRIM(TO_CHAR(perd.ACTUAL_SALARY_AMT, ''' || l_num25_fmask || ''')) actual_salary_amt, '
			|| 'TRIM(TO_CHAR(perd.PAYROLL_PERCENT, ''999G990D00'')) payroll_percent, '
			|| 'TRIM(TO_CHAR(perd.PROPOSED_SALARY_AMT, ''' || l_num25_fmask || ''')) proposed_salary_amt, '
			|| 'TRIM(TO_CHAR(perd.PROPOSED_EFFORT_PERCENT, ''999G990D00'')) proposed_effort_percent, '
			|| 'TRIM(TO_CHAR(perd.COMMITTED_COST_SHARE, ''999G990D00'')) committed_cost_share, '
			|| 'TRIM(TO_CHAR(perd.SCHEDULE_START_DATE, ''' || l_icx_date_format || ''')) schedule_start_date, '
			|| 'TRIM(TO_CHAR(perd.SCHEDULE_END_DATE, ''' || l_icx_date_format || ''')) schedule_end_date, '
			|| 'perd.*, TRIM(TO_CHAR(NVL(pera.overwritten_effort_percent, 0), ''999G990D00'')) overwritten_effort_percent, '
			|| 'TRIM(TO_CHAR(NVL(pera.actual_cost_share, 0), ''999G990D00'')) actual_cost_share FROM psp_eff_report_details perd, '
			|| 'psp_eff_report_approvals pera WHERE (perd.project_id IS NOT NULL OR perd.task_id IS NOT NULL OR perd.award_id '
			|| 'IS NOT NULL OR perd.expenditure_organization_id IS NOT NULL OR perd.expenditure_type IS NOT NULL) AND EXISTS '
			|| '(SELECT 1 FROM pa_projects_all ppa, gms_project_types_all gpta WHERE gpta.project_type = ppa.project_type AND '
			|| 'ppa.project_id = perd.project_id AND ppa.project_type <> ''AWARD_PROJECT'' AND NVL(gpta.sponsored_flag, ''N'') ='
			|| '''Y'') AND perd.effort_report_detail_id = pera.effort_report_detail_id (+) AND effort_report_id = '
			|| TO_CHAR(p_effort_report_id) || ' AND NVL(pera.approval_status, ''A'') IN (''P'', ''A'')' || l_assignment_check || l_sort_option1;
		qryCtx1 := dbms_xmlgen.newContext(query1);
		dbms_xmlgen.setRowTag(qryCtx1, 'G_SPONSORED');
		dbms_xmlgen.setRowSetTag(qryCtx1, 'LIST_G_SPONSORED');
		xmlresult1 := dbms_xmlgen.getXML(qryCtx1, dbms_xmlgen.NONE);
		dbms_xmlgen.closecontext(qryctx1);
		IF (dbms_lob.getlength(xmlresult1) > 0) THEN
			l_resultOffset := DBMS_LOB.INSTR(xmlresult1,'>');
			dbms_lob.copy(l_xml, xmlresult1, dbms_lob.getlength(xmlresult1) - l_resultOffset, dbms_lob.getlength(l_xml), l_resultOffset +1);
		END IF;

		query1 := 'SELECT TRIM(TO_CHAR(perd.ACTUAL_SALARY_AMT, ''' || l_num25_fmask || ''')) actual_salary_amt, '
			|| 'TRIM(TO_CHAR(perd.PAYROLL_PERCENT, ''999G990D00'')) payroll_percent, '
			|| 'TRIM(TO_CHAR(perd.PROPOSED_SALARY_AMT, ''' || l_num25_fmask || ''')) proposed_salary_amt, '
			|| 'TRIM(TO_CHAR(perd.PROPOSED_EFFORT_PERCENT, ''999G990D00'')) proposed_effort_percent, '
			|| 'TRIM(TO_CHAR(perd.COMMITTED_COST_SHARE, ''999G990D00'')) committed_cost_share, '
			|| 'TRIM(TO_CHAR(perd.SCHEDULE_START_DATE, ''' || l_icx_date_format || ''')) schedule_start_date, '
			|| 'TRIM(TO_CHAR(perd.SCHEDULE_END_DATE, ''' || l_icx_date_format || ''')) schedule_end_date, '
			|| 'perd.*, TRIM(TO_CHAR(NVL(pera.overwritten_effort_percent, 0), ''999G990D00'')) overwritten_effort_percent, '
			|| 'TRIM(TO_CHAR(NVL(pera.actual_cost_share, 0), ''999G990D00'')) actual_cost_share FROM psp_eff_report_details perd, '
			|| 'psp_eff_report_approvals pera WHERE (perd.project_id IS NOT NULL OR perd.task_id IS NOT NULL OR perd.award_id '
			|| 'IS NOT NULL OR perd.expenditure_organization_id IS NOT NULL OR perd.expenditure_type IS NOT NULL) AND EXISTS '
			|| '(SELECT 1 FROM pa_projects_all ppa, gms_project_types_all gpta WHERE gpta.project_type(+) = ppa.project_type AND '
			|| 'ppa.project_id = perd.project_id AND ppa.project_type <> ''AWARD_PROJECT'' AND NVL(gpta.sponsored_flag, ''N'') ='
			|| '''N'') AND perd.effort_report_detail_id = pera.effort_report_detail_id (+) AND effort_report_id = '
			|| TO_CHAR(p_effort_report_id) || ' AND NVL(pera.approval_status, ''A'') IN (''P'', ''A'')' || l_assignment_check || l_sort_option1;
		qryCtx1 := dbms_xmlgen.newContext(query1);
		dbms_xmlgen.setRowTag(qryCtx1, 'G_NON_SPONSORED');
		dbms_xmlgen.setRowSetTag(qryCtx1, 'LIST_G_NON_SPONSORED');
		xmlresult1 := dbms_xmlgen.getXML(qryCtx1, dbms_xmlgen.NONE);
		dbms_xmlgen.closecontext(qryctx1);
		IF (dbms_lob.getlength(xmlresult1) > 0) THEN
			l_resultOffset := DBMS_LOB.INSTR(xmlresult1,'>');
			dbms_lob.copy(l_xml, xmlresult1, dbms_lob.getlength(xmlresult1) - l_resultOffset, dbms_lob.getlength(l_xml), l_resultOffset +1);
		END IF;

		query1 := 'SELECT TRIM(TO_CHAR(perd.ACTUAL_SALARY_AMT, ''' || l_num25_fmask || ''')) actual_salary_amt, '
			|| 'TRIM(TO_CHAR(perd.PAYROLL_PERCENT, ''999G990D00'')) payroll_percent, '
			|| 'TRIM(TO_CHAR(perd.PROPOSED_SALARY_AMT, ''' || l_num25_fmask || ''')) proposed_salary_amt, '
			|| 'TRIM(TO_CHAR(perd.PROPOSED_EFFORT_PERCENT, ''999G990D00'')) proposed_effort_percent, '
			|| 'TRIM(TO_CHAR(perd.COMMITTED_COST_SHARE, ''999G990D00'')) committed_cost_share, '
			|| 'TRIM(TO_CHAR(perd.SCHEDULE_START_DATE, ''' || l_icx_date_format || ''')) schedule_start_date, '
			|| 'TRIM(TO_CHAR(perd.SCHEDULE_END_DATE, ''' || l_icx_date_format || ''')) schedule_end_date, '
			|| 'perd.*, TRIM(TO_CHAR(NVL(pera.overwritten_effort_percent, 0), ''999G990D00'')) overwritten_effort_percent, '
			|| 'TRIM(TO_CHAR(NVL(pera.actual_cost_share, 0), ''999G990D00'')) actual_cost_share FROM psp_eff_report_details perd, '
			|| 'psp_eff_report_approvals pera WHERE perd.effort_report_detail_id = pera.effort_report_detail_id (+) AND '
			|| '(perd.gl_segment1 IS NOT NULL OR perd.gl_segment2 IS NOT NULL OR perd.gl_segment3 IS NOT NULL OR '
			|| 'perd.gl_segment4 IS NOT NULL OR perd.gl_segment5 IS NOT NULL OR perd.gl_segment6 IS NOT NULL OR '
			|| 'perd.gl_segment7 IS NOT NULL OR perd.gl_segment8 IS NOT NULL OR perd.gl_segment9 IS NOT NULL OR '
			|| 'perd.gl_segment10 IS NOT NULL OR perd.gl_segment11 IS NOT NULL OR perd.gl_segment12 IS NOT NULL OR '
			|| 'perd.gl_segment13 IS NOT NULL OR perd.gl_segment14 IS NOT NULL OR perd.gl_segment15 IS NOT NULL OR '
			|| 'perd.gl_segment16 IS NOT NULL OR perd.gl_segment17 IS NOT NULL OR perd.gl_segment18 IS NOT NULL OR '
			|| 'perd.gl_segment19 IS NOT NULL OR perd.gl_segment20 IS NOT NULL OR perd.gl_segment21 IS NOT NULL OR '
			|| 'perd.gl_segment22 IS NOT NULL OR perd.gl_segment23 IS NOT NULL OR perd.gl_segment24 IS NOT NULL OR '
			|| 'perd.gl_segment25 IS NOT NULL OR perd.gl_segment26 IS NOT NULL OR perd.gl_segment27 IS NOT NULL OR '
			|| 'perd.gl_segment28 IS NOT NULL OR perd.gl_segment29 IS NOT NULL OR perd.gl_segment30 IS NOT NULL) '
			|| 'AND effort_report_id = ' || TO_CHAR(p_effort_report_id) || ' AND NVL(pera.approval_status, ''A'') IN (''P'', ''A'')'
			|| l_assignment_check || l_sort_option1;
		qryCtx1 := dbms_xmlgen.newContext(query1);
		dbms_xmlgen.setRowTag(qryCtx1, 'G_GL');
		dbms_xmlgen.setRowSetTag(qryCtx1, 'LIST_G_GL');
		xmlresult1 := dbms_xmlgen.getXML(qryCtx1, dbms_xmlgen.NONE);
		dbms_xmlgen.closecontext(qryctx1);
		IF (dbms_lob.getlength(xmlresult1) > 0) THEN
			l_resultOffset := DBMS_LOB.INSTR(xmlresult1,'>');
			dbms_lob.copy(l_xml, xmlresult1, dbms_lob.getlength(xmlresult1) - l_resultOffset, dbms_lob.getlength(l_xml), l_resultOffset +1);
		END IF;
*/
/* Changes for Hospital effort report : END */

		dbms_lob.writeappend(l_xml, length('</G_ASSIGNMENT> '), '</G_ASSIGNMENT> ');
	END LOOP;
	CLOSE assign_cur;
	dbms_lob.writeappend(l_xml, length('</LIST_G_ASSIGNMENT> '), '</LIST_G_ASSIGNMENT> ');

--Bug 4334816: START
-- Including the WorkFlow Note in Pdf
/*

	query1 := 'SELECT DISTINCT approver_order_num approval_sequence, NVL(wf_role_display_name, wf_role_name) approver_name, '
		|| 'TO_CHAR(response_date, ''' || l_icx_date_format || ''')'
		|| ' approval_date FROM psp_eff_report_approvals pera, psp_eff_report_details perd '
		|| 'WHERE perd.effort_report_detail_id = pera.effort_report_detail_id (+) AND perd.effort_report_id = '
		|| TO_CHAR(p_effort_report_id) || ' ORDER BY approver_order_num DESC';
*/


	/*TGEN bug 6864426*/

	SELECT distinct prt.approval_type INTO l_approval_type
	FROM psp_report_templates prt,
	     psp_eff_reports per
	where  per.effort_report_id = p_effort_report_id
	and    per.template_id = prt.template_id;


	IF  (l_approval_type <> 'PRE')  THEN
	  query1 := 'SELECT DISTINCT approver_order_num approval_sequence, NVL(wf_role_display_name, wf_role_name) approver_name, '
		|| 'TO_CHAR(response_date, ''' || l_icx_date_format || ''')'
		|| ' approval_date,  wfna.TEXT_VALUE note FROM psp_eff_report_approvals pera, psp_eff_report_details perd, WF_NOTIFICATION_ATTRIBUTES wfna '
		|| ' WHERE perd.effort_report_detail_id = pera.effort_report_detail_id (+) AND perd.effort_report_id = '
		|| TO_CHAR(p_effort_report_id) || ' AND wfna.NAME(+) =''WF_NOTE'' AND wfna.NOTIFICATION_ID(+) = pera.NOTIFICATION_ID '
		|| ' ORDER BY approver_order_num DESC';
	ELSE   -- Added this ELSE for TGEN bug 6864426
	  query1 := 'SELECT 1 approval_sequence, ''PRE-APPROVED'' approver_name, '
		|| 'TO_CHAR(sysdate, ''' || l_icx_date_format || ''')'
		|| 'approval_date,  ''Process Initiated by ''||''' || l_initiator_name || ''' note FROM DUAL';

	END IF;
--Bug 4334816: END

	qryCtx1 := dbms_xmlgen.newContext(query1);
	dbms_xmlgen.setRowTag(qryCtx1, 'G_APPROVER');
	dbms_xmlgen.setRowSetTag(qryCtx1, 'LIST_G_APPROVER');
	xmlresult1 := dbms_xmlgen.getXML(qryCtx1, dbms_xmlgen.NONE);
	dbms_xmlgen.closecontext(qryctx1);
	IF (dbms_lob.getlength(xmlresult1) > 0) THEN
		l_resultOffset := DBMS_LOB.INSTR(xmlresult1,'>');
		dbms_lob.copy(l_xml, xmlresult1, dbms_lob.getlength(xmlresult1) - l_resultOffset, dbms_lob.getlength(l_xml), l_resultOffset +1);
	END IF;

	dbms_lob.writeappend(l_xml, length('</G_PERSON> '), '</G_PERSON> ');
	ELSE
                ---- 4429787 : replaced variables with col names
		query1 := 'SELECT ' || TO_CHAR(p_person_id) || ' person_id,  er.full_name employee_name, employee_number '
			|| ' employee_number, '|| to_char(p_emp_primary_org_id) || ' organization_id, emp_primary_org_name '
			|| ' organization_name, mailstop mailstop, '
			|| 'TRIM(TO_CHAR(perd.ACTUAL_SALARY_AMT, ''' || l_num25_fmask || ''')) actual_salary_amt, '
			|| 'TRIM(TO_CHAR(perd.PAYROLL_PERCENT, ''999G990D00'')) payroll_percent, '
			|| 'TRIM(TO_CHAR(perd.PROPOSED_SALARY_AMT, ''' || l_num25_fmask || ''')) proposed_salary_amt, '
			|| 'TRIM(TO_CHAR(perd.PROPOSED_EFFORT_PERCENT, ''999G990D00'')) proposed_effort_percent, '
			|| 'TRIM(TO_CHAR(perd.COMMITTED_COST_SHARE, ''999G990D00'')) committed_cost_share, '
			|| 'TRIM(TO_CHAR(perd.SCHEDULE_START_DATE, ''' || l_icx_date_format || ''')) schedule_start_date, '
			|| 'TRIM(TO_CHAR(perd.SCHEDULE_END_DATE, ''' || l_icx_date_format || ''')) schedule_end_date, '
			|| 'perd.*, TRIM(TO_CHAR(NVL(pera.overwritten_effort_percent, 0), ''999G990D00'')) overwritten_effort_percent, '
			|| 'TRIM(TO_CHAR(NVL(pera.actual_cost_share, 0), ''999G990D00'')) actual_cost_share, '
			|| 'pera.pera_information1, pera.pera_information2, pera.pera_information3, pera.pera_information4, pera.pera_information5, '
			|| 'pera.pera_information6, pera.pera_information7, pera.pera_information8, pera.pera_information9, pera.pera_information10, '
			|| 'pera.pera_information11, pera.pera_information12, pera.pera_information13, pera.pera_information14, pera.pera_information15, '
			|| 'pera.pera_information16, pera.pera_information17, pera.pera_information8, pera.pera_information19, pera.pera_information20 '
			|| 'FROM psp_eff_Reports er, psp_eff_report_details perd, '
			|| 'psp_eff_report_approvals pera WHERE perd.effort_report_detail_id = pera.effort_report_detail_id (+) AND  er.effort_report_id = perd.effort_Report_id and '
			|| ' perd.effort_report_id = ' || TO_CHAR(p_effort_report_id) || ' AND NVL(pera.approval_status, ''A'') IN (''P'', ''A'')'
			|| l_er_check || l_sort_option1;

		qryCtx1 := dbms_xmlgen.newContext(query1);
		dbms_xmlgen.setRowsetTag(qryCtx1, 'LIST_G_PERSON');
		dbms_xmlgen.setRowTag(qryCtx1, 'G_PERSON');
		--dbms_xmlgen.setRowsetTag(qryCtx1, 'LIST_G_PERSON');
		l_xml := dbms_xmlgen.getXML(qryCtx1, dbms_xmlgen.NONE);
		l_resultOffset := DBMS_LOB.INSTR(l_xml,'>');
		dbms_lob.write(l_xml, LENGTH(RPAD(' ', l_resultOffset, ' ')), 1, RPAD(' ', l_resultOffset, ' '));
--		dbms_lob.copy(l_xml, xmlresult1, dbms_lob.getlength(xmlresult1) - l_resultOffset, 1, l_resultOffset +1);
		dbms_xmlgen.closecontext(qryctx1);
	END IF;

	RETURN l_xml;
EXCEPTION
	WHEN OTHERS THEN
		OPEN add_report_error_cur(sqlerrm);
		FETCH add_report_error_cur INTO l_error_count;
		CLOSE add_report_error_cur;

		IF (NVL(l_error_count, 0) = 0) THEN
			psp_general.add_report_error
				(p_request_id		=>	p_request_id,
				p_message_level		=>	'E',
				p_source_id		=>	p_person_id, --- person_id replaces NULL-- 4429787
				p_retry_request_id	=>	NULL,
				p_pdf_request_id	=>	g_request_id,
				p_error_message		=>	sqlerrm,
				p_return_status		=>	l_return_status);
		END IF;
		RAISE;
END generate_person_xml;

PROCEDURE store_pdf	(p_wf_item_key		IN		NUMBER,
			p_receiver_flag		IN		VARCHAR2,
			p_file_id		OUT NOCOPY	NUMBER,
			p_wf_Role_Name          IN              VARCHAR2) IS
l_category_id		NUMBER;
l_pdf_file_id		NUMBER;
l_request_id		NUMBER;
l_pdf_filename		VARCHAR2(100);
l_row_id_tmp		VARCHAR2(100);
l_document_id_tmp	NUMBER;

CURSOR	document_category_cur IS
SELECT	category_id
FROM	fnd_document_categories
WHERE	name = 'CUSTOM3788';

CURSOR	pdf_filename_cur IS
SELECT	message_text
FROM	fnd_new_messages fnm
WHERe	fnm.message_name = 'PSP_ER_PDF_FILENAME'
AND	language_code = USERENV('LANG');
CURSOR	add_report_error_cur (p_sqlerrm IN VARCHAR2) IS
SELECT	1
FROM	psp_report_errors
WHERE	request_id = l_request_id
AND	message_level = 'E'
AND	error_message = SUBSTR(p_sqlerrm, 1, 2000)
AND	pdf_request_id = g_request_id;

CURSOR	get_request_id_cur IS
SELECT	request_id
FROM	psp_eff_reports per
WHERE	EXISTS	(SELECT	1
		FROM	psp_eff_report_details perd,
			psp_eff_report_approvals pera
		WHERE	perd.effort_report_id = per.effort_report_id
		AND	perd.effort_report_detail_id = pera.effort_report_detail_id)
AND	ROWNUM = 1;

CURSOR	get_file_id_cur IS
SELECT	fl.file_id
FROM	fnd_lobs fl,
	fnd_attached_documents fad,
	fnd_documents_vl  fdl
WHERE	fad.pk1_value = TO_CHAR(p_wf_item_key)||p_wf_Role_Name
--AND     fad.pk3_value =  p_wf_role_name
AND	fdl.document_id = fad.document_id
AND	fdl.media_id = fl.file_id
AND	fad.entity_name = 'ERDETAILS'
AND	NVL(fad.pk2_value, 'AR') = NVL(p_receiver_flag, 'AR');

l_error_count	NUMBER;
l_return_status	CHAR(1);
BEGIN
	g_request_id := fnd_global.conc_request_id;

	OPEN get_request_id_cur;
	FETCH get_request_id_cur INTO l_request_id;
	CLOSE get_request_id_cur;

	OPEN document_category_cur;
	FETCH document_category_cur INTO l_category_id;
	CLOSE document_category_cur;

	OPEN pdf_filename_cur;
	FETCH pdf_filename_cur INTO l_pdf_filename;
	CLOSE pdf_filename_cur;

	OPEN get_file_id_cur;
	FETCH get_file_id_cur INTO l_pdf_file_id;
	CLOSE get_file_id_cur;

	IF (l_pdf_file_id IS NULL) THEN
		fnd_documents_pkg.insert_row
			(X_Rowid				=>	l_row_id_tmp,
			X_document_id				=>	l_document_id_tmp,
			X_creation_date				=>	SYSDATE,
			X_created_by				=>	1,
			X_last_update_date			=>	SYSDATE,
			X_last_updated_by			=>	1,
			X_last_update_login			=>	1,
			X_datatype_id				=>	6,
			X_category_id				=>	l_category_id,
			X_security_type				=>	1,
			X_security_id				=>	NULL,
			X_publish_flag				=>	'Y',
			X_image_type				=>	NULL,
			X_storage_type				=>	NULL,
			X_usage_type				=>	'O',
			X_start_date_active			=>	SYSDATE,
			X_end_date_active			=>	NULL,
			X_request_id				=>	NULL,
			X_program_application_id		=>	NULL,
			X_program_id				=>	NULL,
			X_program_update_date			=>	SYSDATE,
			X_language				=>	USERENV('LANG'),
			X_description				=>	NULL,
			X_file_name				=>	l_pdf_filename,
			X_media_id				=>	l_pdf_file_id);

		INSERT INTO fnd_lobs
			(file_id,		File_name,		file_content_type,
			upload_date,		expiration_date,	program_name,
			program_tag,		file_data,		language,
			oracle_charset,		file_format)
		VALUES
			(l_pdf_file_id,		l_pdf_filename,		'application/pdf',
			SYSDATE,		NULL,			'PSPERPDF',
			NULL,			empty_blob(),		USERENV('LANG'),
			NULL,			'binary');

		INSERT INTO fnd_attached_documents
			(attached_document_id,		document_id,		creation_date,
			created_by,			last_update_date,	last_updated_by,
			last_update_login,		seq_num,		entity_name,
			pk1_value,			pk2_value,		pk3_value,
			pk4_value,			pk5_value,		automatically_added_flag,
			program_application_id,		program_id,		program_update_date,
			request_id,			attribute_category,	attribute1,
			attribute2,			attribute3,		attribute4,
			attribute5,			attribute6,		attribute7,
			attribute8,			attribute9,		attribute10,
			attribute11,			attribute12,		attribute13,
			attribute14,			attribute15,		column1)
		VALUES	(fnd_attached_documents_s.nextval,	l_document_id_tmp,	SYSDATE,
			1,				SYSDATE,		1,
			NULL,				10,			'ERDETAILS',
			TO_CHAR(p_wf_item_key)||p_wf_Role_Name,		p_receiver_flag,	null,
			NULL,				NULL,			'N',
			NULL,				NULL,			SYSDATE,
			NULL,				NULL,			NULL,
			NULL,				NULL,			NULL,
			NULL,				NULL,			NULL,
			NULL,				NULL,			NULL,
			NULL,				NULL,			NULL,
			NULL,				NULL,			NULL);
	END IF;

	p_file_id := l_pdf_file_id;
EXCEPTION
	WHEN OTHERS THEN
		OPEN add_report_error_cur(sqlerrm);
		FETCH add_report_error_cur INTO l_error_count;
		CLOSE add_report_error_cur;

		IF (NVL(l_error_count, 0) = 0) THEN
			psp_general.add_report_error
				(p_request_id		=>	l_request_id,
				p_message_level		=>	'E',
				p_source_id		=>	NULL,
				p_retry_request_id	=>	NULL,
				p_pdf_request_id	=>	g_request_id,
				p_error_message		=>	sqlerrm,
				p_return_status		=>	l_return_status);
		END IF;
		RAISE;
END store_pdf;

PROCEDURE attach_pdf	(p_item_type_key	IN		VARCHAR2,
			content_type		IN		VARCHAR2,
			p_document		IN OUT	NOCOPY	BLOB,
			p_document_type		IN OUT	NOCOPY	VARCHAR2) IS
l_item_type		VARCHAR2(100);
l_item_key		VARCHAR2(100);
l_document_length	NUMBER;
l_pdf_file_id		NUMBER;
l_request_id		NUMBER;
l_document			BLOB;
CURSOR	add_report_error_cur (p_sqlerrm IN VARCHAR2) IS
SELECT	1
FROM	psp_report_errors
WHERE	request_id = l_request_id
AND	message_level = 'E'
AND	error_message = SUBSTR(p_sqlerrm, 1, 2000)
AND	pdf_request_id = g_request_id;

CURSOR	get_request_id_cur IS
SELECT	request_id
FROM	psp_eff_reports per
WHERE	EXISTS	(SELECT	1
		FROM	psp_eff_report_details perd,
			psp_eff_report_approvals pera
		WHERE	perd.effort_report_id = per.effort_report_id
		AND	perd.effort_report_detail_id = pera.effort_report_detail_id)
AND	ROWNUM = 1;

l_error_count	NUMBER;
l_return_status	CHAR(1);
l_rname  wf_roles.name%type;  -- Bug 7135471
l_file_name fnd_lobs.file_name%type; -- Bug 7229792

BEGIN
	OPEN get_request_id_cur;
	FETCH get_request_id_cur INTO l_request_id;
	CLOSE get_request_id_cur;

	hr_utility.trace('LD Debug p_item_type_key = '||p_item_type_key);

	g_request_id := fnd_global.conc_request_id;
	l_item_type := SUBSTR(p_item_type_key, 1, INSTR(p_item_type_key, ':') - 1);
	l_item_key := SUBSTR(p_item_type_key, INSTR(p_item_type_key, ':') + 1, length(p_item_type_key) - 2);

	hr_utility.trace('LD Debug l_item_type = '||l_item_type);
	hr_utility.trace('LD Debug l_item_key = '||l_item_key);

	l_rname := NVL(
	           wf_engine.GetItemAttrText(itemtype => l_item_type,
	                                     itemkey  => l_item_key,
                                             aname    => 'APPROVER_ROLE_NAME'), null);  -- Bug 7135471

	hr_utility.trace('LD Debug l_rname = '||l_rname);

	SELECT	file_data,
	        file_id  -- Bug 7135471
	INTO	l_document,
	        l_pdf_file_id -- Bug 7135471
	FROM	fnd_lobs fl,
		fnd_attached_documents fad,
		fnd_documents_vl  fdl
	WHERE	fad.pk1_value = l_item_key || l_rname
	AND	fdl.document_id = fad.document_id
	AND	fdl.media_id = fl.file_id
	AND	fad.entity_name = 'ERDETAILS'
	AND     fl.file_id = (select max(file_id) FROM	fnd_lobs fl,  -- Bug 7135471
							fnd_attached_documents fad,
							fnd_documents_vl  fdl
						WHERE	fad.pk1_value = l_item_key || l_rname
						AND	fdl.document_id = fad.document_id
						AND	fdl.media_id = fl.file_id
						AND	fad.entity_name = 'ERDETAILS');

	l_file_name := 'PSP_ER_' || l_item_key || '.pdf' ; 	-- Bug 7229792

	hr_utility.trace('LD Debug l_pdf_file_id = '||l_pdf_file_id);
	l_document_length := DBMS_LOB.getlength(l_document);
	DBMS_LOB.copy(p_document, l_document, l_document_length, 1, 1);
	p_document_type:='application/pdf; name='|| l_file_name;  -- Bug 7229792

EXCEPTION
   WHEN OTHERS THEN
      WF_CORE.Context('PSP_ER_XML','ATTACH_PDF', l_item_key,
                      content_type, p_document_type, sqlerrm);
		OPEN add_report_error_cur(sqlerrm);
		FETCH add_report_error_cur INTO l_error_count;
		CLOSE add_report_error_cur;

		IF (NVL(l_error_count, 0) = 0) THEN
			psp_general.add_report_error
				(p_request_id		=>	l_request_id,
				p_message_level		=>	'E',
				p_source_id		=>	NULL,
				p_retry_request_id	=>	NULL,
				p_pdf_request_id	=>	g_request_id,
				p_error_message		=>	sqlerrm,
				p_return_status		=>	l_return_status);
		END IF;
      RAISE;
END attach_pdf;

PROCEDURE	update_er_person_xml	(p_start_person		IN		NUMBER,
					p_end_person		IN		NUMBER,
					p_request_id		IN		NUMBER,
					p_retry_request_id	IN		NUMBER	DEFAULT NULL,
					p_return_status		OUT	NOCOPY	VARCHAR2) IS
CURSOR	add_report_error_cur (p_sqlerrm IN VARCHAR2) IS
SELECT	1
FROM	psp_report_errors
WHERE	request_id = p_request_id
AND	message_level = 'E'
AND	error_message = SUBSTR(p_sqlerrm, 1, 2000)
AND	pdf_request_id = g_request_id;
 --- added er_cur for 4429787
rec psp_Eff_reports%rowtype;
cursor er_cur is select effort_Report_id,
person_id, template_id,  request_id, set_of_books_id, full_name,
employee_number, mailstop, emp_primary_org_name, emp_primary_org_id, currency_code
from psp_Eff_reports where request_id = p_request_id
	AND	person_id BETWEEN p_start_person AND p_end_person
	AND	status_code <> 'R';
x_lob clob;
l_error_count	NUMBER;
l_return_status	CHAR(1);


BEGIN
	g_request_id := fnd_global.conc_request_id;
        --- replaced single bulk update with a loop b'cos of xml error
        ---ORA-29532, ORA-6512  for bug fix 4429787
        open er_cur;
	loop
	fetch er_cur into rec.effort_Report_id,
	      rec.person_id, rec.template_id, rec.request_id,
	         rec.set_of_books_id,  rec.full_name, rec.employee_number, rec.mailstop, rec.emp_primary_org_name,
	         rec.emp_primary_org_id, rec.currency_code;

	 if er_cur%notfound then
	    close er_cur;
		exit;
	 end if;

	   x_lob := psp_xmlgen.generate_person_xml(rec.person_id, rec.template_id,
                                                   rec.effort_report_id, rec.request_id,
                                                   rec.set_of_books_id, rec.full_name,
                                                   rec.employee_number, rec.mailstop,
                                                   rec.emp_primary_org_name, rec.emp_primary_org_id,
                                                   rec.currency_code );


	UPDATE	psp_eff_reports
	SET	person_xml = x_lob
	WHERE	effort_report_id = rec.effort_report_id;

    end loop;
	p_return_status := 'S';
EXCEPTION
	WHEN OTHERS THEN
		fnd_msg_pub.add_exc_msg('PSP_XMLGEN', 'UPDATE_ER_PERSON_XML', sqlerrm);
		OPEN add_report_error_cur(sqlerrm);
		FETCH add_report_error_cur INTO l_error_count;
		CLOSE add_report_error_cur;

		IF (NVL(l_error_count, 0) = 0) THEN
			psp_general.add_report_error
				(p_request_id		=>	p_request_id,
				p_message_level		=>	'E',
				p_source_id		=>	rec.person_id,
				p_retry_request_id	=>	p_retry_request_id,
				p_pdf_request_id	=>	g_request_id,
				p_error_message		=>	sqlerrm,
				p_return_status		=>	l_return_status);
		END IF;
		p_return_status := 'E';
END update_er_person_xml;

PROCEDURE	update_er_person_xml	(p_request_id	IN		NUMBER,
					p_return_status	OUT NOCOPY	VARCHAR2) IS
PRAGMA AUTONOMOUS_TRANSACTION;
CURSOR	add_report_error_cur (p_sqlerrm IN VARCHAR2) IS
SELECT	1
FROM	psp_report_errors
WHERE	request_id = p_request_id
AND	message_level = 'E'
AND	error_message = SUBSTR(p_sqlerrm, 1, 2000)
AND	pdf_request_id = g_request_id;

l_error_count	NUMBER;
l_return_status	CHAR(1);
BEGIN
	g_request_id := fnd_global.conc_request_id;
	UPDATE	psp_eff_reports
	SET	person_xml = generate_person_xml(person_id, template_id, effort_report_id, request_id, set_of_books_id, full_name, employee_number, mailstop, emp_primary_org_name, emp_primary_org_id, currency_code)
	WHERE	request_id = p_request_id
	AND	status_code <> 'R';

	COMMIT;

	p_return_status := 'S';
EXCEPTION
	WHEN OTHERS THEN
		fnd_msg_pub.add_exc_msg('PSP_XMLGEN', 'UPDATE_ER_PERSON_XML', sqlerrm);
		OPEN add_report_error_cur(sqlerrm);
		FETCH add_report_error_cur INTO l_error_count;
		CLOSE add_report_error_cur;

		IF (NVL(l_error_count, 0) = 0) THEN
			psp_general.add_report_error
				(p_request_id		=>	p_request_id,
				p_message_level		=>	'E',
				p_source_id		=>	NULL,
				p_retry_request_id	=>	NULL,
				p_pdf_request_id	=>	g_request_id,
				p_error_message		=>	sqlerrm,
				p_return_status		=>	l_return_status);
		END IF;
		p_return_status := 'E';
END update_er_person_xml;

PROCEDURE	update_er_person_xml	(p_wf_item_key	IN		NUMBER,
					p_return_status	OUT	NOCOPY	VARCHAR2) IS
CURSOR	get_request_id IS
SELECT	request_id
FROM	psp_eff_reports per,
	psp_eff_report_details perd,
	psp_eff_report_approvals pera
WHERE	perd.effort_report_detail_id = pera.effort_report_detail_id
AND	per.effort_report_id = perd.effort_report_id
AND	pera.wf_item_key = p_wf_item_key;

l_request_id	NUMBER;

CURSOR	add_report_error_cur (p_sqlerrm IN VARCHAR2) IS
SELECT	1
FROM	psp_report_errors
WHERE	request_id = l_request_id
AND	message_level = 'E'
AND	error_message = SUBSTR(p_sqlerrm, 1, 2000)
AND	pdf_request_id = g_request_id;

l_error_count	NUMBER;
l_return_status	CHAR(1);

CURSOR	person_cur IS
SELECT	person_id,
	template_id,
	effort_report_id,
	request_id,
	set_of_books_id,
	full_name,
	employee_number,
	mailstop,
	emp_primary_org_name,
	emp_primary_org_id,
	currency_code
FROM	psp_eff_reports
WHERE	effort_report_id IN	(SELECT	effort_report_id
				FROM	psp_eff_report_details perd,
					psp_eff_report_approvals pera
				WHERE	perd.effort_report_detail_id = pera.effort_report_detail_id
				AND	pera.wf_item_key = p_wf_item_key)
AND	status_code <> 'R';

person_rec	person_cur%ROWTYPE;
l_xml		CLOB;
BEGIN
	g_request_id := fnd_global.conc_request_id;

	OPEN person_cur;
	l_xml := empty_clob();
	LOOP
		FETCH person_cur INTO person_rec;
		EXIT WHEN person_cur%NOTFOUND;

		l_xml := generate_person_xml(person_rec.person_id,
				person_rec.template_id,
				person_rec.effort_report_id,
				person_rec.request_id,
				person_rec.set_of_books_id,
				person_rec.full_name,
				person_rec.employee_number,
				person_rec.mailstop,
				person_rec.emp_primary_org_name,
				person_rec.emp_primary_org_id,
				person_rec.currency_code );

		UPDATE	psp_eff_reports
		SET	person_xml = l_xml
		WHERE	effort_report_id = person_rec.effort_report_id;
	END LOOP;
	CLOSE person_cur;

/*****	Converted single xml clob update statement into row by row update
	UPDATE	psp_eff_reports
	SET	person_xml	= generate_person_xml(person_id, template_id, effort_report_id, request_id, set_of_books_id, full_name, employee_number, mailstop, emp_primary_org_name, emp_primary_org_id, currency_code)
	WHERE	effort_report_id IN	(SELECT	effort_report_id
					FROM	psp_eff_report_details perd,
						psp_eff_report_approvals pera
					WHERE	perd.effort_report_detail_id = pera.effort_report_detail_id
					AND	pera.wf_item_key = p_wf_item_key)
	AND	status_code <> 'R';
	End of changes for bug fix 4429787	*****/
	p_return_status := 'S';
EXCEPTION
	WHEN OTHERS THEN
		fnd_msg_pub.add_exc_msg('PSP_XMLGEN', 'UPDATE_ER_PERSON_XML', sqlerrm);
		OPEN get_request_id;
		FETCH get_request_id INTO l_request_id;
		CLOSE get_request_id;

		OPEN add_report_error_cur(sqlerrm);
		FETCH add_report_error_cur INTO l_error_count;
		CLOSE add_report_error_cur;

		IF (NVL(l_error_count, 0) = 0) THEN
			psp_general.add_report_error
				(p_request_id		=>	l_request_id,
				p_message_level		=>	'E',
				p_source_id		=>	NULL,
				p_retry_request_id	=>	NULL,
				p_pdf_request_id	=>	g_request_id,
				p_error_message		=>	sqlerrm,
				p_return_status		=>	l_return_status);
		END IF;
		p_return_status := 'E';
END update_er_person_xml;



PROCEDURE update_er_details	(p_start_person		IN		NUMBER,
				p_end_person		IN		NUMBER,
				p_request_id		IN		NUMBER,
				p_retry_request_id	IN		NUMBER	DEFAULT NULL,
				p_return_status		OUT	NOCOPY	VARCHAR2) IS
TYPE t_num_15_type	IS TABLE OF NUMBER(15)	INDEX BY BINARY_INTEGER;
TYPE t_date_type	IS TABLE OF DATE	INDEX BY BINARY_INTEGER;
TYPE effort_report_id_type IS RECORD
	(r_effort_report_id	t_num_15_type,
	r_start_date		t_date_type,
	r_end_date		t_date_type);

r_effort_report	effort_report_id_type;

l_layout_type			CHAR(3);
l_report_template_code		CHAR(80);
l_set_of_books_id		NUMBER;
l_segment_delimiter		CHAR(1);
l_query				VARCHAR2(4000);
l_segment_name			VARCHAR2(50);
l_template_id			NUMBER(15);

CURSOR	effort_report_id_cur IS
SELECT	effort_report_id,
	start_date,
	end_date
FROM	psp_eff_reports per
WHERE	person_id BETWEEN p_start_person AND p_end_person
AND	status_code <> 'R'
AND	request_id = p_request_id;

CURSOR	layout_type_cur IS
SELECT	SUBSTR(report_template_code, 6, 3) layout_type,
	per.template_id,
	per.set_of_books_id,
	prth.report_template_code
FROM	psp_eff_reports per,
	psp_report_templates_h prth
WHERE	per.request_id = p_request_id
AND	prth.request_id = per.request_id
AND	ROWNUM = 1;

CURSOR	get_segment_delimeter_cur IS
SELECT	fnd_flex_ext.get_delimiter('SQLGL', 'GL#', gsob.chart_of_accounts_id)
FROM	gl_sets_of_books gsob
WHERE	gsob.set_of_books_id = l_set_of_books_id;

CURSOR	get_segment_name_cur IS
SELECT	'GL_' || fifs.application_column_name || ' || ''' || l_segment_delimiter || ''' || ' segment_name
FROM	fnd_id_flex_segments fifs,
	gl_sets_of_books gsob,
	fnd_application fa
WHERE	gsob.set_of_books_id = l_set_of_books_id
AND	fifs.id_flex_num = gsob.chart_of_accounts_id
AND	fifs.id_flex_code = 'GL#'
AND	fifs.application_id = fa.application_id
AND	fa.application_short_name = 'SQLGL'
AND	EXISTS	(SELECT	1
		FROM	psp_report_template_details_h prtdh
		WHERE	prtdh.REQUEST_ID= p_request_id
		AND	prtdh.criteria_lookup_type = 'PSP_SUMMARIZATION_CRITERIA'
		AND	prtdh.criteria_lookup_code = fifs.application_column_name)
ORDER BY fifs.segment_num;

CURSOR	add_report_error_cur (p_sqlerrm IN VARCHAR2) IS
SELECT	1
FROM	psp_report_errors
WHERE	request_id = p_request_id
AND	message_level = 'E'
AND	error_message = SUBSTR(p_sqlerrm, 1, 2000)
AND	pdf_request_id = g_request_id;

l_error_count		NUMBER;
l_return_status		CHAR(1);
l_project_manager_role	VARCHAR2(30);

CURSOR	project_manager_role_cur IS
SELECT	layout_lookup_code
FROM	psp_layout_options
WHERE	report_template_code = TRIM(l_report_template_code)
AND	layout_lookup_type = 'PSP_PROJECT_MANAGER_ROLE';


BEGIN
	g_request_id := fnd_global.conc_request_id;
	OPEN effort_report_id_cur;
	FETCH effort_report_id_cur BULK COLLECT INTO r_effort_report.r_effort_report_id, r_effort_report.r_start_date, r_effort_report.r_end_date;
	CLOSE effort_report_id_cur;

	OPEN layout_type_cur;
	FETCH layout_type_cur INTO l_layout_type, l_template_id, l_set_of_books_id, l_report_template_code;
	CLOSE layout_type_cur;

	OPEN project_manager_role_cur;
	FETCH project_manager_role_cur INTO l_project_manager_role;
	CLOSE project_manager_role_cur;

	l_project_manager_role := NVL(l_project_manager_role, 'PROJECT MANAGER');

	IF (l_layout_type = 'EMP') THEN
		FORALL I IN 1..r_effort_report.r_effort_report_id.COUNT
		UPDATE	psp_eff_report_details perd
		SET	assignment_number = (SELECT assignment_number FROM per_all_assignments_f paaf, psp_eff_reports per
					WHERE per.effort_report_id = perd.effort_report_id AND paaf.assignment_id = perd.assignment_id
					AND paaf.effective_start_date <= r_effort_report.r_end_date(I)
					AND paaf.effective_end_date >= r_effort_report.r_start_date(I)
					AND paaf.assignment_number is not null    -- Bug 8540341
					AND ROWNUM = 1),
			(project_name, project_number) = (SELECT name, segment1 FROM pa_projects_all paa
							WHERE paa.project_id = perd.project_id),
			(award_short_name, award_number) = (SELECT award_short_name, award_number FROM gms_awards_all gaa
							WHERE gaa.award_id = perd.award_id),
			(task_name, task_number) = (SELECT task_name, task_number FROM pa_tasks pt WHERE pt.task_id = perd.task_id),
			exp_org_name = (SELECT name FROM hr_all_organization_units haou
					WHERE haou.organization_id = perd.expenditure_organization_id),
			actual_salary_amt = NVL(actual_salary_amt, 0),
			payroll_percent = NVL(payroll_percent, 0),
			proposed_salary_amt = NVL(proposed_salary_amt, 0),
			proposed_effort_percent = NVL(proposed_effort_percent, 0),
			committed_cost_share = NVL(committed_cost_share, 0)
		WHERE	perd.effort_report_id = r_effort_report.r_effort_report_id(I);

		OPEN get_segment_delimeter_cur;
		FETCH get_segment_delimeter_cur INTO l_segment_delimiter;
		CLOSE get_segment_delimeter_cur;

		OPEN get_segment_name_cur;
		l_query := '';
		LOOP
			FETCH get_segment_name_cur INTO l_segment_name;
			EXIT WHEN get_segment_name_cur%NOTFOUND;

			l_query := l_query || l_segment_name;
		END LOOP;
		l_query := SUBSTR(l_query, 1, LENGTH(l_query) - 11);
		CLOSE get_segment_name_cur;

		IF (l_query IS NOT NULL) THEN
			l_query := 'UPDATE psp_eff_report_details SET gl_sum_criteria_segment_name = ' || l_query
				|| ' WHERE effort_report_id IN (SELECT per.effort_report_id FROM psp_eff_reports per WHERE per.request_id = '
				|| TO_CHAR(p_request_id) || ' AND per.person_id BETWEEN '
				|| TO_CHAR(p_start_person) || ' AND ' || TO_CHAR(p_end_person) || ') AND '
				|| '(gl_segment1 IS NOT NULL OR gl_segment2 IS NOT NULL OR gl_segment3 IS NOT NULL OR '
				|| 'gl_segment4 IS NOT NULL OR gl_segment5 IS NOT NULL OR gl_segment6 IS NOT NULL OR '
				|| 'gl_segment7 IS NOT NULL OR gl_segment8 IS NOT NULL OR gl_segment9 IS NOT NULL OR '
				|| 'gl_segment10 IS NOT NULL OR gl_segment11 IS NOT NULL OR gl_segment12 IS NOT NULL OR '
				|| 'gl_segment13 IS NOT NULL OR gl_segment14 IS NOT NULL OR gl_segment15 IS NOT NULL OR '
				|| 'gl_segment16 IS NOT NULL OR gl_segment17 IS NOT NULL OR gl_segment18 IS NOT NULL OR '
				|| 'gl_segment19 IS NOT NULL OR gl_segment20 IS NOT NULL OR gl_segment21 IS NOT NULL OR '
				|| 'gl_segment22 IS NOT NULL OR gl_segment23 IS NOT NULL OR gl_segment24 IS NOT NULL OR '
				|| 'gl_segment25 IS NOT NULL OR gl_segment26 IS NOT NULL OR gl_segment27 IS NOT NULL OR '
				|| 'gl_segment28 IS NOT NULL OR gl_segment29 IS NOT NULL OR gl_segment30 IS NOT NULL)';

			EXECUTE IMMEDIATE l_query;

--			l_query := REPLACE(l_query, 'segment', 'description');
--			EXECUTE IMMEDIATE l_query;
		END IF;
	ELSIF (l_layout_type = 'PIV') THEN
		FORALL I IN 1..r_effort_report.r_effort_report_id.COUNT
		UPDATE	psp_eff_report_details perd
		SET	assignment_number = (SELECT assignment_number FROM per_all_assignments_f paaf, psp_eff_reports per
				WHERE per.effort_report_id = perd.effort_report_id AND paaf.assignment_id = perd.assignment_id
				AND paaf.effective_start_date <= r_effort_report.r_end_date(I)
				AND paaf.effective_end_date >= r_effort_report.r_start_date(I)
				AND paaf.assignment_number is not null    -- Bug 8540341
				AND ROWNUM = 1),
			(project_name, project_number) = (SELECT name, segment1 FROM pa_projects_all paa
				WHERE paa.project_id = perd.project_id),
			(award_short_name, award_number) = (SELECT award_short_name, award_number FROM gms_awards_all gaa
				WHERE gaa.award_id = perd.award_id),
			(task_name, task_number) = (SELECT task_name, task_number FROM pa_tasks pt WHERE pt.task_id = perd.task_id),
			exp_org_name = (SELECT name FROM hr_all_organization_units haou
				WHERE haou.organization_id = perd.expenditure_organization_id),
			(investigator_name, investigator_person_id) = (SELECT full_name, person_id FROM per_all_people_f papf
				WHERE papf.person_id = (SELECT person_id FROM gms_personnel gp
						WHERE	gp.award_id = perd.award_id AND gp.award_role = 'PI'
						AND	gp.start_date_active = (SELECT	MAX(gp2.start_date_active)
									FROM	gms_personnel gp2
									WHERE	gp2.award_id = perd.award_id
                                                                        AND gp2.award_role = 'PI'  --- added for uva fix
                                                                        AND     nvl(gp2.end_date_active,to_date('31-12-4712','dd-mm-yyyy')) >= r_effort_report.r_start_date(I)    --- uva fix
									AND	gp2.start_date_active <= r_effort_report.r_end_date(I))
						AND	ROWNUM = 1)
				AND papf.effective_start_date <= r_effort_report.r_end_date(I)
				AND papf.effective_end_date >= r_effort_report.r_start_date(I) AND ROWNUM = 1),
			actual_salary_amt = NVL(actual_salary_amt, 0),
			payroll_percent = NVL(payroll_percent, 0),
			proposed_salary_amt = NVL(proposed_salary_amt, 0),
			proposed_effort_percent = NVL(proposed_effort_percent, 0),
			committed_cost_share = NVL(committed_cost_share, 0)
		WHERE	perd.effort_report_id = r_effort_report.r_effort_report_id(I);
	ELSIF (l_layout_type = 'PMG') THEN
		FORALL I IN 1..r_effort_report.r_effort_report_id.COUNT
		UPDATE	psp_eff_report_details perd
		SET	assignment_number = (SELECT assignment_number FROM per_all_assignments_f paaf, psp_eff_reports per
				WHERE per.effort_report_id = perd.effort_report_id AND paaf.assignment_id = perd.assignment_id
				AND paaf.effective_start_date <= r_effort_report.r_end_date(I)
				AND paaf.effective_end_date >= r_effort_report.r_start_date(I)
				AND paaf.assignment_number is not null    -- Bug 8540341
				AND ROWNUM = 1),
			(project_name, project_number) = (SELECT name, segment1 FROM pa_projects_all paa
				WHERE paa.project_id = perd.project_id),
			(award_short_name, award_number) = (SELECT award_short_name, award_number FROM gms_awards_all gaa
				WHERE gaa.award_id = perd.award_id),
			(task_name, task_number) = (SELECT task_name, task_number FROM pa_tasks pt WHERE pt.task_id = perd.task_id),
			exp_org_name = (SELECT name FROM hr_all_organization_units haou
				WHERE haou.organization_id = perd.expenditure_organization_id),
			(investigator_name, investigator_person_id) = (SELECT full_name, person_id FROM per_all_people_f papf
   --- added max person_id for uva issue
				WHERE papf.person_id = (SELECT max(person_id) FROM pa_project_players pap
--						WHERE	pap.project_id = perd.project_id AND project_role_type = 'PROJECT MANAGER'
						WHERE	pap.project_id = perd.project_id AND project_role_type = l_project_manager_role
						AND	pap.start_date_active = (SELECT	MAX(pap2.start_date_active)
									FROM	pa_project_players pap2
									WHERE	pap2.project_id = perd.project_id
                                                                        AND     pap2.project_role_type = l_project_manager_role
                                                                        AND     nvl(pap2.end_date_active,to_date('31-12-4712','dd-mm-yyyy')) >= r_effort_report.r_start_date(I)    --- uva fix
									AND	pap2.start_date_active <= r_effort_report.r_end_date(I)))
				AND papf.effective_start_date <= r_effort_report.r_end_date(I)
				AND papf.effective_end_date >= r_effort_report.r_start_date(I) AND ROWNUM = 1),
			actual_salary_amt = NVL(actual_salary_amt, 0),
			payroll_percent = NVL(payroll_percent, 0),
			proposed_salary_amt = NVL(proposed_salary_amt, 0),
			proposed_effort_percent = NVL(proposed_effort_percent, 0),
			committed_cost_share = NVL(committed_cost_share, 0)
		WHERE	perd.effort_report_id = r_effort_report.r_effort_report_id(I);
	ELSIF (l_layout_type = 'TMG') THEN
		FORALL I IN 1..r_effort_report.r_effort_report_id.COUNT
		UPDATE	psp_eff_report_details perd
		SET	assignment_number = (SELECT assignment_number FROM per_all_assignments_f paaf, psp_eff_reports per
				WHERE per.effort_report_id = perd.effort_report_id AND paaf.assignment_id = perd.assignment_id
				AND paaf.effective_start_date <= per.end_date
				AND paaf.effective_end_date >= per.start_date
				AND paaf.assignment_number is not null    -- Bug 8540341
				AND ROWNUM = 1),
			(project_name, project_number) = (SELECT name, segment1 FROM pa_projects_all paa
				WHERE paa.project_id = perd.project_id),
			(award_short_name, award_number) = (SELECT award_short_name, award_number FROM gms_awards_all gaa
				WHERE gaa.award_id = perd.award_id),
			(task_name, task_number) = (SELECT task_name, task_number FROM pa_tasks pt WHERE pt.task_id = perd.task_id),
			exp_org_name = (SELECT name FROM hr_all_organization_units haou
				WHERE haou.organization_id = perd.expenditure_organization_id),
			(investigator_name, investigator_person_id) = (SELECT full_name, person_id FROM per_all_people_f papf
				WHERE papf.person_id = (select task_manager_person_id from pa_tasks pt WHERE pt.task_id = perd.task_id)
				AND papf.effective_start_date <= r_effort_report.r_end_date(I)
				AND papf.effective_end_date >= r_effort_report.r_start_date(I) AND ROWNUM = 1),
			actual_salary_amt = NVL(actual_salary_amt, 0),
			payroll_percent = NVL(payroll_percent, 0),
			proposed_salary_amt = NVL(proposed_salary_amt, 0),
			proposed_effort_percent = NVL(proposed_effort_percent, 0),
			committed_cost_share = NVL(committed_cost_share, 0)
		WHERE	perd.effort_report_id = r_effort_report.r_effort_report_id(I);
	END IF;

	FORALL I IN 1..r_effort_report.r_effort_report_id.COUNT
	UPDATE	psp_eff_report_details perd
	SET	(investigator_primary_org_id, investigator_org_name) = (SELECT haou.organization_id, haou.name
				FROM hr_all_organization_units haou, per_all_assignments_f paaf
				WHERE haou.organization_id = paaf.organization_id AND paaf.person_id = perd.investigator_person_id
				AND paaf.effective_start_date  <= r_effort_report.r_end_date(I)
				AND paaf.effective_end_date >= r_effort_report.r_start_date(I)
				AND paaf.primary_flag = 'Y' AND ROWNUM = 1)
	WHERE	perd.effort_report_id = r_effort_report.r_effort_report_id(I)
	AND	perd.investigator_person_id IS NOT NULL;

	FORALL I IN 1..r_effort_report.r_effort_report_id.COUNT
	UPDATE	psp_eff_reports per
	SET	(employee_number, full_name, mailstop) = (SELECT papf.employee_number, papf.full_name, papf.mailstop FROM per_all_people_f papf
				WHERE papf.person_id = per.person_id AND papf.effective_start_date <= per.end_date
				AND papf.effective_end_date >= per.start_date
				AND papf.employee_number is not NULL  -- Bug 8540341
				AND ROWNUM = 1),
		(emp_primary_org_id, emp_primary_org_name) = (SELECT haou.organization_id, haou.name
				FROM hr_all_organization_units haou, per_all_assignments_f paaf
				WHERE haou.organization_id = paaf.organization_id AND paaf.person_id = per.person_id
				AND paaf.effective_start_date  <= per.end_date AND paaf.effective_end_date >= per.start_date
				AND paaf.primary_flag = 'Y' AND ROWNUM = 1)
	WHERE	per.effort_report_id = r_effort_report.r_effort_report_id(I);

	p_return_status := 'S';
EXCEPTION
	WHEN OTHERS THEN
		fnd_msg_pub.add_exc_msg('PSP_XMLGEN', 'UPDATE_ER_DETAILS', sqlerrm);
		OPEN add_report_error_cur(sqlerrm);
		FETCH add_report_error_cur INTO l_error_count;
		CLOSE add_report_error_cur;

		IF (NVL(l_error_count, 0) = 0) THEN
			psp_general.add_report_error
				(p_request_id		=>	p_request_id,
				p_message_level		=>	'E',
				p_source_id		=>	NULL,
				p_retry_request_id	=>	p_retry_request_id,
				p_pdf_request_id	=>	g_request_id,
				p_error_message		=>	sqlerrm,
				p_return_status		=>	l_return_status);
		END IF;
		p_return_status := 'E';
END update_er_details;

PROCEDURE COPY_PTAOE_FROM_GL_SEGMENTS (p_start_person		IN		NUMBER,
				p_end_person		IN		NUMBER,
				p_request_id		IN		NUMBER,
				p_retry_request_id	IN		NUMBER	DEFAULT NULL,
                p_business_group_id IN          NUMBER,
				p_return_status		OUT	NOCOPY	VARCHAR2) IS

    CURSOR	effort_report_id_cur IS
    SELECT	effort_report_id
    FROM	psp_eff_reports per
    WHERE	person_id BETWEEN p_start_person AND p_end_person
    AND	status_code <> 'R'
    AND	request_id = p_request_id;

    CURSOR	add_report_error_cur (p_sqlerrm IN VARCHAR2) IS
    SELECT	1
    FROM	psp_report_errors
    WHERE	request_id = p_request_id
    AND	message_level = 'E'
    AND	error_message = SUBSTR(p_sqlerrm, 1, 2000)
    AND	pdf_request_id = g_request_id;

    l_proj_segment varchar2(30);
    l_tsk_segment varchar2(30);
    l_awd_sgement varchar2(30);
    l_exp_org_segment varchar2(30);
    l_exp_type_segment varchar2(30);
    sql_stmt varchar2(4000);
    l_error_count	NUMBER;
    l_return_status	CHAR(1);

BEGIN

     PSP_GENERAL.GET_GL_PTAOE_MAPPING(p_business_group_id => p_business_group_id,
--                      p_set_of_books_id => p_set_of_books_id,
                      p_proj_segment => l_proj_segment,
                      p_tsk_segment => l_tsk_segment,
                      p_awd_sgement => l_awd_sgement,
                      p_exp_org_segment=> l_exp_org_segment,
                      p_exp_type_segment => l_exp_type_segment);

 sql_stmt := ' Update psp_eff_report_details set project_id = GL_'||l_proj_segment ||
    ' , TASK_ID = GL_'|| l_tsk_segment || ' , AWARD_ID = GL_' || l_awd_sgement || ' , EXPENDITURE_ORGANIZATION_ID = GL_' || l_exp_org_segment
    || ' , EXPENDITURE_TYPE = GL_'|| l_exp_type_segment ||' WHERE effort_report_id in (select effort_report_id FROM psp_eff_reports per'
    || ' WHERE	person_id BETWEEN ' || p_start_person || ' AND ' || p_end_person
    || ' AND	status_code <> ''R'' AND	request_id = ' || p_request_id ||'  )';

 EXECUTE IMMEDIATE sql_stmt ;
 p_return_status := fnd_api.g_ret_sts_success;
EXCEPTION
	WHEN OTHERS THEN
		fnd_msg_pub.add_exc_msg('PSP_XMLGEN', 'COPY_PTAOE_FROM_GL_SEGMENTS', sqlerrm);
		OPEN add_report_error_cur(sqlerrm);
		FETCH add_report_error_cur INTO l_error_count;
		CLOSE add_report_error_cur;

		IF (NVL(l_error_count, 0) = 0) THEN
			psp_general.add_report_error
				(p_request_id		=>	p_request_id,
				p_message_level		=>	'E',
				p_source_id		=>	NULL,
				p_retry_request_id	=>	p_retry_request_id,
				p_pdf_request_id	=>	g_request_id,
				p_error_message		=>	sqlerrm,
				p_return_status		=>	l_return_status);
		END IF;
		p_return_status := fnd_api.g_ret_sts_error;
END COPY_PTAOE_FROM_GL_SEGMENTS;
--- function for uva issues.. this can be replace dbms_xmlgen.convert in future.
---- fix for bug 4429787
function convert_xml_controls(p_string varchar2) return varchar2 is
begin
  return  replace(replace(replace(replace(replace(p_string, '&', '&amp;'),'''','&apos;'),'"','&quot;'),'<','&lt;'),'>','&gt;');
end;

PROCEDURE	update_er_error_details	(p_request_id		IN		NUMBER,
					p_retry_request_id	IN		NUMBER,
					p_return_status		OUT	NOCOPY	VARCHAR2) IS

CURSOR	add_report_error_cur (p_sqlerrm IN VARCHAR2) IS
SELECT	1
FROM	psp_report_errors
WHERE	request_id = p_request_id
AND	message_level = 'E'
AND	error_message = SUBSTR(p_sqlerrm, 1, 2000)
AND	pdf_request_id = g_request_id;

CURSOR	er_dates_cur IS
SELECT	fnd_date.canonical_to_date(fnd_date.date_to_canonical(prth.parameter_value_2)) start_date,
	fnd_date.canonical_to_date(fnd_date.date_to_canonical(prth.parameter_value_3)) end_date
FROM	psp_report_templates_h prth
WHERE	prth.request_id = p_request_id;

l_start_date	DATE;
l_end_date	DATE;
l_return_status	CHAR(1);
l_error_count	NUMBER;

BEGIN
	OPEN er_dates_cur;
	FETCH er_dates_cur INTO l_start_date, l_end_date;
	CLOSE er_dates_cur;

	UPDATE	psp_report_errors pre
	SET	(source_name, parent_source_id, parent_source_name) =	(SELECT	full_name, emp_primary_org_id, emp_primary_org_name
							FROM	psp_eff_reports per
							WHERE	per.request_id = p_request_id
							AND	per.person_id = TO_NUMBER(pre.source_id))
	WHERE	pre.request_id = p_request_id
	AND	pre.source_id IS NOT NULL
	AND	pre.source_name IS NULL;

	UPDATE	psp_report_errors pre
	SET	(source_name, parent_source_id, parent_source_name) =	(SELECT	papf.full_name, paaf.organization_id, haou.name
							FROM	per_all_assignments_f paaf,
								per_all_people_f papf,
								hr_all_organization_units haou
							WHERE	haou.organization_id = paaf.organization_id
							AND	papf.person_id = TO_NUMBER(pre.source_id)
							AND	paaf.person_id = TO_NUMBER(pre.source_id)
							AND	paaf.primary_flag = 'Y'
							AND	paaf.effective_start_date = (SELECT	MAX(paaf2.effective_start_date)
											FROM	per_all_assignments_f paaf2
											WHERE	paaf2.effective_start_date <= l_end_date
											AND	paaf2.effective_end_date >= l_start_date
											AND	paaf2.person_id = TO_NUMBER(pre.source_id))
							AND	papf.effective_start_date = (SELECT	MAX(papf2.effective_start_date)
											FROM	per_all_people_f papf2
											WHERE	papf2.effective_start_date <= l_end_date
											AND	papf2.effective_end_date >= l_start_date
											AND	papf2.person_id = TO_NUMBER(pre.source_id)))
	WHERE	pre.request_id = p_request_id
	AND	pre.source_id IS NOT NULL
	AND	pre.source_name IS NULL;

	UPDATE	psp_report_errors pre
	SET	source_name =	(SELECT	papf.full_name
				FROM	per_all_people_f papf
				WHERE	papf.person_id = TO_NUMBER(pre.source_id)
				AND	papf.effective_start_date = (SELECT	MAX(papf2.effective_start_date)
									FROM	per_all_people_f papf2
									WHERE	papf2.effective_start_date <= l_end_date
									AND	papf2.effective_end_date >= l_start_date
									AND	papf2.person_id = TO_NUMBER(pre.source_id)))
	WHERE	pre.request_id = p_request_id
	AND	pre.source_id IS NOT NULL
	AND	pre.source_name IS NULL;

	UPDATE	psp_report_errors pre
	SET	source_name =	(SELECT	papf.full_name
				FROM	per_all_people_f papf
				WHERE	papf.person_id = TO_NUMBER(pre.source_id)
				AND	papf.effective_start_date = (SELECT	MIN(papf2.effective_start_date)
									FROM	per_all_people_f papf2
									WHERE	papf2.person_id = TO_NUMBER(pre.source_id)))
	WHERE	pre.request_id = p_request_id
	AND	pre.source_id IS NOT NULL
	AND	pre.source_name IS NULL;

	p_return_status := fnd_api.g_ret_sts_success;
EXCEPTION
	WHEN OTHERS THEN
		fnd_msg_pub.add_exc_msg('PSP_XMLGEN', 'UPDATE_ER_ERROR_DETAILS', sqlerrm);
		OPEN add_report_error_cur(sqlerrm);
		FETCH add_report_error_cur INTO l_error_count;
		CLOSE add_report_error_cur;

		IF (NVL(l_error_count, 0) = 0) THEN
			psp_general.add_report_error
				(p_request_id		=>	p_request_id,
				p_message_level		=>	'E',
				p_source_id		=>	NULL,
				p_retry_request_id	=>	p_retry_request_id,
				p_pdf_request_id	=>	NULL,
				p_error_message		=>	sqlerrm,
				p_return_status		=>	l_return_status);
		END IF;
		p_return_status := fnd_api.g_ret_sts_error;
END update_er_error_details;


/* Procedure Added for Hospital effort report */

PROCEDURE update_grouping_category (	p_start_person		IN		NUMBER,
					p_end_person		IN		NUMBER,
					p_request_id		IN		NUMBER,
					p_return_status		OUT	NOCOPY	VARCHAR2) IS

TYPE t_num_15_type	IS TABLE OF NUMBER(15)	INDEX BY BINARY_INTEGER;
effort_report_detail_id_rec t_num_15_type;
l_return_status		CHAR(1);

CURSOR	GLA_effort_report_detail_cur IS
SELECT	perd.effort_report_detail_id
FROM	psp_eff_reports per,
        psp_eff_report_details perd
WHERE	per.effort_report_id = perd.effort_report_id
AND     per.person_id BETWEEN p_start_person AND p_end_person
AND	request_id = p_request_id
AND    (perd.gl_segment1 IS NOT NULL OR perd.gl_segment2 IS NOT NULL
        OR perd.gl_segment3 IS NOT NULL OR perd.gl_segment4 IS NOT NULL
        OR perd.gl_segment5 IS NOT NULL OR perd.gl_segment6 IS NOT NULL
        OR perd.gl_segment7 IS NOT NULL OR perd.gl_segment8 IS NOT NULL
        OR perd.gl_segment9 IS NOT NULL OR perd.gl_segment10 IS NOT NULL
        OR perd.gl_segment11 IS NOT NULL OR perd.gl_segment12 IS NOT NULL
        OR perd.gl_segment13 IS NOT NULL OR perd.gl_segment14 IS NOT NULL
        OR perd.gl_segment15 IS NOT NULL OR perd.gl_segment16 IS NOT NULL
        OR perd.gl_segment17 IS NOT NULL OR perd.gl_segment18 IS NOT NULL
        OR perd.gl_segment19 IS NOT NULL OR perd.gl_segment20 IS NOT NULL
        OR perd.gl_segment21 IS NOT NULL OR perd.gl_segment22 IS NOT NULL
        OR perd.gl_segment23 IS NOT NULL OR perd.gl_segment24 IS NOT NULL
        OR perd.gl_segment25 IS NOT NULL OR perd.gl_segment26 IS NOT NULL
        OR perd.gl_segment27 IS NOT NULL OR perd.gl_segment28 IS NOT NULL
        OR perd.gl_segment29 IS NOT NULL OR perd.gl_segment30 IS NOT NULL);

CURSOR	SPO_effort_report_detail_cur IS
SELECT	perd.effort_report_detail_id
FROM	psp_eff_reports per,
        psp_eff_report_details perd
WHERE	per.effort_report_id = perd.effort_report_id
AND     per.person_id BETWEEN p_start_person AND p_end_person
AND	request_id = p_request_id
AND     (  perd.project_id IS NOT NULL OR perd.task_id IS NOT NULL
        OR perd.award_id IS NOT NULL OR perd.expenditure_organization_id IS NOT NULL
        OR perd.expenditure_type IS NOT NULL)
AND EXISTS (SELECT 1 FROM pa_projects_all ppa, gms_project_types gpta -- Changed from gms_project_types_all for bug 5503605
            WHERE gpta.project_type = ppa.project_type
	    AND ppa.project_id = perd.project_id
	    AND ppa.project_type <> 'AWARD_PROJECT' AND NVL(gpta.sponsored_flag, 'N') ='Y');

CURSOR	NSP_effort_report_detail_cur IS
SELECT	perd.effort_report_detail_id
FROM	psp_eff_reports per,
        psp_eff_report_details perd
WHERE	per.effort_report_id = perd.effort_report_id
AND     per.person_id BETWEEN p_start_person AND p_end_person
AND	request_id = p_request_id
AND     (  perd.project_id IS NOT NULL OR perd.task_id IS NOT NULL
        OR perd.award_id IS NOT NULL OR perd.expenditure_organization_id IS NOT NULL
        OR perd.expenditure_type IS NOT NULL)
AND EXISTS (SELECT 1 FROM pa_projects_all ppa, gms_project_types gpta -- Changed from gms_project_types_all for bug 5503605
            WHERE gpta.project_type(+) = ppa.project_type
	    AND ppa.project_id = perd.project_id
	    AND ppa.project_type <> 'AWARD_PROJECT' AND NVL(gpta.sponsored_flag, 'N') ='N');


BEGIN
	OPEN GLA_effort_report_detail_cur;
	FETCH GLA_effort_report_detail_cur BULK COLLECT INTO effort_report_detail_id_rec;
	CLOSE GLA_effort_report_detail_cur;

	FORALL I IN 1..effort_report_detail_id_rec.COUNT
	UPDATE psp_eff_report_details perd SET grouping_category = 'GLA'
	WHERE  effort_report_detail_id = effort_report_detail_id_rec(I);

	effort_report_detail_id_rec.delete;

	OPEN SPO_effort_report_detail_cur;
	FETCH SPO_effort_report_detail_cur BULK COLLECT INTO effort_report_detail_id_rec;
	CLOSE SPO_effort_report_detail_cur;

	FORALL I IN 1..effort_report_detail_id_rec.COUNT
	UPDATE psp_eff_report_details perd SET grouping_category = 'SPO'
	WHERE  effort_report_detail_id = effort_report_detail_id_rec(I);

	effort_report_detail_id_rec.delete;


	OPEN NSP_effort_report_detail_cur;
	FETCH NSP_effort_report_detail_cur BULK COLLECT INTO effort_report_detail_id_rec;
	CLOSE NSP_effort_report_detail_cur;

	FORALL I IN 1..effort_report_detail_id_rec.COUNT
	UPDATE psp_eff_report_details perd SET grouping_category = 'NSP'
	WHERE  effort_report_detail_id = effort_report_detail_id_rec(I);

	effort_report_detail_id_rec.delete;

	p_return_status := fnd_api.g_ret_sts_success;

EXCEPTION
	WHEN OTHERS THEN
		psp_general.add_report_error
			(p_request_id		=>	p_request_id,
			p_message_level		=>	'E',
			p_source_id		=>	NULL,
			p_error_message		=>	sqlerrm,
			p_return_status		=>	l_return_status);

		p_return_status := fnd_api.g_ret_sts_unexp_error;

END update_grouping_category;


END PSP_XMLGEN;

/

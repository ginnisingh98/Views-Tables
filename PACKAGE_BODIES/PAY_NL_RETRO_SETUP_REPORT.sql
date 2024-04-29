--------------------------------------------------------
--  DDL for Package Body PAY_NL_RETRO_SETUP_REPORT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_NL_RETRO_SETUP_REPORT" AS
/* $Header: pynlersr.pkb 120.1 2008/02/19 11:57:33 abhgangu noship $ */

-------------------------------------------------------------------------------
-- get_IANA_charset
-------------------------------------------------------------------------------
FUNCTION get_IANA_charset RETURN VARCHAR2 IS
    CURSOR csr_get_iana_charset IS
        SELECT tag
          FROM fnd_lookup_values
         WHERE lookup_type = 'FND_ISO_CHARACTER_SET_MAP'
           AND lookup_code = SUBSTR(USERENV('LANGUAGE'),
                                    INSTR(USERENV('LANGUAGE'), '.') + 1)
           AND language = 'US';

    lv_iana_charset fnd_lookup_values.tag%type;
BEGIN
    OPEN csr_get_iana_charset;
        FETCH csr_get_iana_charset INTO lv_iana_charset;
    CLOSE csr_get_iana_charset;

    hr_utility.trace('IANA Charset = '||lv_iana_charset);
    RETURN (lv_iana_charset);
END get_IANA_charset;

-------------------------------------------------------------------------------
-- Procedure to Generate XML Data
-------------------------------------------------------------------------------

PROCEDURE generate
	 		( 	p_business_group_id IN NUMBER,
	 			p_eff_date IN VARCHAR2,
	 			p_ele_records IN VARCHAR2,
	 			p_template_name IN VARCHAR2,
	 			p_xml OUT NOCOPY CLOB
	 		)
	 		IS

-- Cursor to get classifications of the elements.
CURSOR csr_get_ele_class(c_bg_id NUMBER,c_ele_rec VARCHAR2) IS

SELECT DISTINCT
		pec.classification_id,
		pec1.classification_name
FROM
		pay_element_classifications pec ,
		pay_element_classifications_tl pec1 ,
		pay_element_types_f pat
WHERE
		pec.legislation_code = 'NL'
AND  		pec.parent_classification_id IS NULL
AND		pec1.language = USERENV('LANG') -- Bug ref. 5837256
AND 		pat.classification_id = pec.classification_id
AND 		pat.business_group_id = c_bg_id
AND 		pec1.classification_id = pat.classification_id
AND		(EXISTS (SELECT NULL FROM pay_retro_component_usages prcu WHERE
			    pat.element_type_id = prcu.creator_id
		AND         prcu.creator_type   = 'ET') OR  c_ele_rec = 'A');

-- Cursor for getting element retro setup records
CURSOR csr_get_element_record(c_bg_id NUMBER,c_eff_date DATE, c_class_id NUMBER) IS

SELECT
            pat.element_name,
            prc.component_name,
            hr_general.decode_lookup('HR_NL_YES_NO',NVL(prcu.default_component,'N')) default_component,
            hr_general.decode_lookup('RETRO_REPROCESS_TYPE',prcu.reprocess_type) reprocess_type,
            hr_general.decode_lookup('HR_NL_YES_NO',NVL(prcu.replace_run_flag,'N')) replace_run_flag,
            hr_general.decode_lookup('HR_NL_YES_NO',NVL(prcu.use_override_dates,'N')) use_override_dates,
            pat1.element_name  Retro_Element,
            ptd1.definition_name Time_from ,
            ptd2.definition_name  Time_To ,
            pec.classification_name

FROM
            pay_element_types_f pat,
            pay_retro_component_usages prcu,
            pay_element_span_usages pesu,
            pay_time_spans pts,
            pay_time_definitions ptd1,
            pay_time_definitions ptd2,
            pay_element_types_f pat1,
            pay_retro_components prc,
            pay_element_classifications_tl pec

WHERE
            pat.business_group_id = c_bg_id
AND	    c_eff_date between pat.effective_start_date AND pat.effective_end_date
AND	    pat.classification_id = c_class_id
AND         pat.element_type_id = prcu.creator_id
AND         prcu.creator_type   = 'ET'
AND		pec.language = USERENV('LANG') -- Bug ref. 5837256
AND         prcu.retro_component_usage_id = pesu.retro_component_usage_id(+)
AND         pesu.time_span_id = pts.time_span_id(+)
AND         pts.start_time_def_id = ptd1.time_definition_id(+)
AND         pts.end_time_def_id  = ptd2.time_definition_id(+)
AND         pesu.retro_element_type_id = pat1.element_type_id(+)
AND         prcu.retro_component_id = prc.retro_component_id
AND 	    pat1.classification_id = pec.classification_id(+)
ORDER BY    pat.element_name, PRC.component_name	;

-- Cursor for getting elements without retro components

CURSOR csr_get_ele_without_ret(c_bg_id NUMBER,c_eff_date DATE, c_class_id NUMBER) IS
SELECT DISTINCT
	    pat.element_name
FROM
            pay_element_types_f pat,
            pay_retro_component_usages prcu
WHERE
            pat.business_group_id = c_bg_id
AND	    c_eff_date between pat.effective_start_date AND pat.effective_end_date
AND	    pat.classification_id = c_class_id
AND         pat.element_type_id = prcu.creator_id (+)
AND         prcu.creator_type (+)  = 'ET'
AND	    prcu.creator_id IS NULL;



-- Getting BG name
CURSOR csr_bg_name(c_bg_id per_business_groups.name%TYPE, c_eff_date DATE) IS

SELECT name FROM per_business_groups
WHERE business_group_id = c_bg_id
AND   c_eff_date BETWEEN date_from AND NVL(date_to,hr_general.end_of_time);

-- Local Variables
vCtr NUMBER := 0;
v_get_ele_class csr_get_ele_class%ROWTYPE;
v_get_ele_without_ret csr_get_ele_without_ret%ROWTYPE;
v_get_element_record csr_get_element_record%ROWTYPE;
l_element_name pay_element_types_f.element_name%TYPE := ' ';
l_show_element pay_element_types_f.element_name%TYPE := ' ';
l_component pay_retro_components.component_name%TYPE := ' ';
l_show_component pay_retro_components.component_name%TYPE := ' ';
l_default_comp pay_retro_component_usages.default_component%TYPE := ' ';
l_replace_run pay_retro_component_usages.replace_run_flag%TYPE := ' ';
l_override_dates pay_retro_component_usages.use_override_dates%TYPE := ' ';
l_reprocess_type pay_retro_component_usages.reprocess_type%TYPE := ' ';
l_bg_name csr_bg_name%ROWTYPE;
l_str VARCHAR2(7500);
l_str1 varchar2(1000);
l_str2 varchar2(20);
l_str3 varchar2(20);
l_str4 varchar2(20);
l_str5 varchar2(20);
l_str6 varchar2(30);
l_str7 varchar2(1000);
l_str8 varchar2(1000);
l_str9 varchar2(1000);
l_str10 varchar2(1000);
l_str11 varchar2(100);
l_effec_date DATE;
l_xml CLOB;


BEGIN

--hr_utility.trace_on(NULL,'ERSR');
hr_utility.set_location('Inside pay_nl_retro_setup_report.generate : Parameters',100);
hr_utility.set_location('Inside pay_nl_retro_setup_report.generate : p_eff_date'||p_eff_date,140);
hr_utility.set_location('Inside pay_nl_retro_setup_report.generate : p_ele_records'||p_ele_records,160);
hr_utility.set_location('Inside pay_nl_retro_setup_report.generate : p_business_group_id'||p_business_group_id,180);


l_effec_date := fnd_date.canonical_to_date(p_eff_date);

OPEN csr_bg_name(p_business_group_id,l_effec_date);
FETCH csr_bg_name INTO l_bg_name;
CLOSE csr_bg_name;

-- Setting PL/SQL table for tags and values of data be reported once.
PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'EFF_DATE';
PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := to_char(l_effec_date);
vCtr := vCtr + 1;

PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'BG_NAME';
PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := l_bg_name.name;
vCtr := vCtr + 1;

PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'ELE_RECORDS';
PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := hr_general.decode_lookup('HR_NL_ESR_ELE_REC',p_ele_records);
vCtr := vCtr + 1;

hr_utility.set_location('Inside pay_nl_retro_setup_report.generate : <EFF_DATE>'||to_char(l_effec_date),600);
hr_utility.set_location('Inside pay_nl_retro_setup_report.generate : <BG_NAME>'||l_bg_name.name,620);
hr_utility.set_location('Inside pay_nl_retro_setup_report.generate : <ELE_RECORDS>'||hr_general.decode_lookup('HR_NL_ESR_ELE_REC',p_ele_records),640);

-- Setting PL/SQL table for tags and values of the xml data for all the element records

FOR v_get_ele_class IN csr_get_ele_class(p_business_group_id,p_ele_records)
LOOP

	PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'G_CONTAINER_CLASS';
	PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := NULL;
	vCtr := vCtr + 1;

	PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'ELE_CLASS';
	PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := v_get_ele_class.classification_name ;
	vCtr := vCtr + 1;

	hr_utility.set_location('Inside pay_nl_retro_setup_report.generate : <G_CONTAINER_CLASS>',660);
	hr_utility.set_location('Inside pay_nl_retro_setup_report.generate : <ELE_CLASS>'||NVL(v_get_ele_class.classification_name,'NULL'),680);
	FOR v_get_element_record
	IN csr_get_element_record(p_business_group_id,l_effec_date,v_get_ele_class.classification_id)
	LOOP
		-- Donot repeat the element name if same.
		IF l_element_name <> v_get_element_record.element_name THEN
			l_element_name := v_get_element_record.element_name;
			l_show_element := v_get_element_record.element_name;
			l_show_component := v_get_element_record.component_name;
			l_component := v_get_element_record.component_name;
			l_default_comp := v_get_element_record.default_component;
			l_replace_run := v_get_element_record.replace_run_flag;
			l_override_dates := v_get_element_record.use_override_dates ;
			l_reprocess_type := v_get_element_record.reprocess_type;
		ELSE
			l_show_element := ' ';
			-- Donot repeat the component data if same
			IF l_component <> v_get_element_record.component_name THEN
				l_component := v_get_element_record.component_name;
				l_show_component := v_get_element_record.component_name;
				l_default_comp := v_get_element_record.default_component;
				l_replace_run := v_get_element_record.replace_run_flag;
				l_override_dates := v_get_element_record.use_override_dates ;
				l_reprocess_type := v_get_element_record.reprocess_type;
			ELSE
				l_show_component := ' ';
				l_default_comp := ' ';
				l_replace_run := ' ';
				l_override_dates := ' ';
				l_reprocess_type := ' ';

			END IF;
		END IF;

		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'G_CONTAINER_ELEMENT';
		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := NULL;
		vCtr := vCtr + 1;

		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'ELEMENT_NAME';
		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := l_show_element ;
		vCtr := vCtr + 1;
		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'COMPONENT';
		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := l_show_component;
		vCtr := vCtr + 1;
		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'REPROCESS_TYPE';
		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := l_reprocess_type;
		vCtr := vCtr + 1;
		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'DEFAULT_COMP';
		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := l_default_comp;
		vCtr := vCtr + 1;
		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'REPLACE_RUN';
		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := l_replace_run;
		vCtr := vCtr + 1;
		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'OVERRIDE_DATE';
		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := l_override_dates;
		vCtr := vCtr + 1;
		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'TIME_FROM';
		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := v_get_element_record.Time_From;
		vCtr := vCtr + 1;
		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'TIME_TO';
		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := v_get_element_record.Time_To;
		vCtr := vCtr + 1;
		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'RETRO_ELEMENT';
		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := v_get_element_record.Retro_Element;
		vCtr := vCtr + 1;
		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'RETRO_ELE_CLASS';
		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := v_get_element_record.classification_name;
		vCtr := vCtr + 1;
		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'G_CONTAINER_ELEMENT';
		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := 'END';
		vCtr := vCtr + 1;

		hr_utility.set_location('Inside pay_nl_retro_setup_report.generate : <G_CONTAINER_ELEMENT>',700);
		hr_utility.set_location('Inside pay_nl_retro_setup_report.generate : <ELEMENT_NAME>'||NVL(v_get_element_record.element_name,'NULL'),720);

	END LOOP;

	IF p_ele_records = 'A' THEN
		FOR v_get_ele_without_ret
		IN csr_get_ele_without_ret(p_business_group_id,l_effec_date,v_get_ele_class.classification_id)
		LOOP
			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'G_CONTAINER_ELEMENT';
			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := NULL;
			vCtr := vCtr + 1;

			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'ELEMENT_NAME';
			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := v_get_ele_without_ret.element_name ;
			vCtr := vCtr + 1;

			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'G_CONTAINER_ELEMENT';
			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := 'END';
			vCtr := vCtr + 1;

			hr_utility.set_location('Inside pay_nl_retro_setup_report.generate : <G_CONTAINER_ELEMENT>',740);
			hr_utility.set_location('Inside pay_nl_retro_setup_report.generate : <ELEMENT_NAME>'||NVL(v_get_ele_without_ret.element_name,'NULL'),760);
		END LOOP;
	END IF;

	PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'G_CONTAINER_CLASS';
	PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := 'END';
	vCtr := vCtr + 1;

END LOOP;

-- Generate XML data using the PL/SQL table.
hr_utility.set_location('Entered Procedure Write to clob ',100);
	l_str1 := '<fields>' ;
	l_str2 := '<';
	l_str3 := '>';
	l_str4 := '<value>' ;
	l_str5 := '</value> </' ;
	l_str6 := '</fields>';
	l_str7 := '<fields></fields>';
	l_str10 := '</';
	l_str11 := '<?xml version="1.0" encoding="' || get_IANA_charset ||'"?>';
	dbms_lob.createtemporary(l_xml,FALSE,DBMS_LOB.CALL);

	dbms_lob.open(l_xml,dbms_lob.lob_readwrite);
	dbms_lob.writeAppend( l_xml, length(l_str11), l_str11 );

	if PAY_NL_XDO_REPORT.vXMLTable.count > 0 then
		dbms_lob.writeAppend( l_xml, length(l_str1), l_str1 );
                hr_utility.set_location('Before Procedure Write to clob: before loop',102);
        	FOR ctr_table IN PAY_NL_XDO_REPORT.vXMLTable.FIRST .. PAY_NL_XDO_REPORT.vXMLTable.LAST LOOP
        		hr_utility.set_location('Before Procedure Write to clob: Inside loop'||PAY_NL_XDO_REPORT.vXMLTable(ctr_table).TagName,104);
        		l_str8 := PAY_NL_XDO_REPORT.vXMLTable(ctr_table).TagName;
        		l_str9 := PAY_NL_XDO_REPORT.vXMLTable(ctr_table).TagValue;
        		if (substr(l_str8,1,11) = 'G_CONTAINER') then
        		        if (l_str9 is null) then
					l_str :=  l_str2||l_str8||l_str3;

					/*dbms_lob.writeAppend( l_xml, length(l_str2), l_str2 );
					dbms_lob.writeAppend( l_xml, length(l_str8),l_str8);
					dbms_lob.writeAppend( l_xml, length(l_str3), l_str3 ); 	*/
				else
				if (l_str9 = 'END') then
					 l_str :=  l_str10||l_str8||l_str3;
					/* dbms_lob.writeAppend( l_xml, length(l_str10), l_str10 );
					 dbms_lob.writeAppend( l_xml, length(l_str8),l_str8);
					 dbms_lob.writeAppend( l_xml, length(l_str3), l_str3 ); */
				end if;
				end if;
		        else
        		if (l_str9 is not null) then

        		l_str :=  l_str2||l_str8||l_str3||l_str4||l_str9||l_str5||l_str8||l_str3;
			/*	dbms_lob.writeAppend( l_xml, length(l_str2), l_str2 );
				dbms_lob.writeAppend( l_xml, length(l_str8),l_str8);
				dbms_lob.writeAppend( l_xml, length(l_str3), l_str3 );
				dbms_lob.writeAppend( l_xml, length(l_str4), l_str4 );
				dbms_lob.writeAppend( l_xml, length(l_str9), l_str9);
				dbms_lob.writeAppend( l_xml, length(l_str5), l_str5 );
				dbms_lob.writeAppend( l_xml, length(l_str8),l_str8);
				dbms_lob.writeAppend( l_xml, length(l_str3),l_str3); */
			elsif (l_str9 is null and l_str8 is not null) then

			l_str :=  l_str2||l_str8||l_str3||l_str4||l_str5||l_str8||l_str3;
			/*	dbms_lob.writeAppend(l_xml,length(l_str2),l_str2);
				dbms_lob.writeAppend(l_xml,length(l_str8),l_str8);
				dbms_lob.writeAppend(l_xml,length(l_str3),l_str3);
				dbms_lob.writeAppend(l_xml,length(l_str4),l_str4);
				dbms_lob.writeAppend(l_xml,length(l_str5),l_str5);
				dbms_lob.writeAppend( l_xml, length(l_str8),l_str8);
				dbms_lob.writeAppend( l_xml, length(l_str3),l_str3); */
			else
			null;
			end if;
			end if;
			dbms_lob.writeAppend( l_xml, length(l_str),l_str);
			l_str := '';

		END LOOP;
		dbms_lob.writeAppend( l_xml, length(l_str6), l_str6 );
	else
		dbms_lob.writeAppend( l_xml, length(l_str7), l_str7 );
	end if;
--set return output variable to CLOB xml file
p_xml := l_xml;

/*begin
insert into my_table15 values(l_xml);
end;*/
EXCEPTION
	WHEN OTHERS then
	HR_UTILITY.TRACE('sqleerm ' || SQLERRM);
	HR_UTILITY.RAISE_ERROR;

END generate;

END pay_nl_retro_setup_report;

/

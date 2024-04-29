--------------------------------------------------------
--  DDL for Package Body PAY_NL_NWR_XML_EXTRACT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_NL_NWR_XML_EXTRACT_PKG" as
/* $Header: pynlwrep.pkb 120.8.12010000.11 2010/01/04 13:18:10 abraghun ship $ */
--

TYPE char_tab IS TABLE OF pay_action_information.action_information1%type INDEX BY BINARY_INTEGER;
g_xml_nwr   char_tab;
--
g_action_ctx_id     NUMBER;
sqlstr              DBMS_SQL.VARCHAR2S;
l_cntr_sql          NUMBER;
g_year              VARCHAR2(10);
g_report_type       VARCHAR2(20);
g_payroll_type      VARCHAR2(40) DEFAULT NULL; --8552196
EOL			  VARCHAR2(5)   := fnd_global.local_chr(10);	--7283669
--
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
--
-------------------------------------------------------------------------------
-- TO_UTF8
--------------------------------------------------------------------------------
FUNCTION TO_UTF8(str in varchar2 )RETURN VARCHAR2 AS
   db_charset varchar2(120);
BEGIN
    SELECT value
    INTO db_charset
    FROM nls_database_parameters
    WHERE parameter = 'NLS_CHARACTERSET';
    RETURN CONVERT(str,'UTF8',db_charset);
END;
-------------------------------------------------------------------------------
-- WRITETOCLOB
--------------------------------------------------------------------------------
PROCEDURE WritetoCLOB (p_xfdf_string out nocopy clob) IS
     l_str VARCHAR2(240);
     l_str1 VARCHAR2(4000);
     l_concat_str VARCHAR2(32000);
     l_len    NUMBER;
 BEGIN
     --l_str := '<?xml version="1.0" encoding="UTF-8"?> <Loonaangifte></Loonaangifte>';
     l_str := '<?xml version="1.0" encoding="' || get_IANA_charset || '"?> <Loonaangifte></Loonaangifte>';
     dbms_lob.createtemporary(p_xfdf_string,FALSE,DBMS_LOB.CALL);
     dbms_lob.open(p_xfdf_string,dbms_lob.lob_readwrite);
     IF g_xml_nwr.count > 0 THEN
       l_concat_str := '';
       FOR ctr_table IN g_xml_nwr.FIRST .. g_xml_nwr.LAST LOOP
           l_concat_str := l_concat_str || g_xml_nwr(ctr_table);
           l_len := length(l_concat_str);
           IF  l_len  > 28000 then
           dbms_lob.writeAppend( p_xfdf_string, l_len, l_concat_str);
           l_concat_str := '';
           END IF;
       END LOOP;
       IF length(l_concat_str) > 0 THEN
         dbms_lob.writeAppend( p_xfdf_string, LENGTH(l_concat_str), l_concat_str);
       END IF;
     ELSE
         --l_str1 := CONVERT(l_str,'UTF8');
         dbms_lob.writeAppend( p_xfdf_string, LENGTH(l_str), l_str );
     END IF;
 END WritetoCLOB;
-------------------------------------------------------------------------------
-- YES_NO
--------------------------------------------------------------------------------
FUNCTION yes_no(p_yn VARCHAR2) RETURN VARCHAR2 IS
BEGIN
	IF 	p_yn = 'J' THEN
	    RETURN  'Y';
	ELSE
	    RETURN p_yn;
	END IF;
END yes_no;
--------------------------------------------------------------------------------
--    Name        : GET_TAG_DESCRIPTION
--    Description : This Function returns the Tag Description when the tag name
--                  is provided   .
--------------------------------------------------------------------------------
FUNCTION get_tag_description(p_tag    VARCHAR2)
RETURN VARCHAR2
IS
CURSOR csr_get_tag_descr(l_tag VARCHAR2)
IS
SELECT  meaning
       ,nvl(start_date_active,fnd_date.canonical_to_date('0001/01/01 00:00:00'))  active_date
FROM   hr_lookups
WHERE lookup_type = 'NL_FORM_LABELS'
  --AND lookup_code like l_tag||'%'
  AND (lookup_code like l_tag||'%'||g_year OR lookup_code = l_tag)
  AND nvl(to_char(start_date_active,'RRRR'),'0001') <= g_year
  AND nvl(to_char(end_date_active,'RRRR'),'4712') >= g_year
  AND enabled_flag = 'Y'
--ORDER BY 2 desc;
  ORDER BY active_date desc, lookup_code desc ;

l_temp_data csr_get_tag_descr%ROWTYPE;
l_description   VARCHAR2(500);

BEGIN
  IF p_tag IS NOT NULL THEN
    OPEN csr_get_tag_descr(p_tag);
    FETCH csr_get_tag_descr INTO l_temp_data;
    IF csr_get_tag_descr%NOTFOUND THEN
      l_description := NULL;
    ELSE
      l_description := l_temp_data.meaning;
    END IF;
    CLOSE csr_get_tag_descr;
  ELSE
    l_description := NULL;
  END IF;
  RETURN l_description;
END get_tag_description;
--------------------------------------------------------------------------------
--    Name        : GET_TAG_NAME
--    Description : This Function returns the Tag Name when the context
--                  and column are specified.
--------------------------------------------------------------------------------
FUNCTION get_tag_name (p_context_code         VARCHAR2
                      ,p_node                 VARCHAR2) RETURN VARCHAR2 AS
    --
    CURSOR csr_get_tag_name IS
    SELECT TRANSLATE ((description), ' /','__') tag_name
    FROM  fnd_descr_flex_col_usage_tl
    WHERE application_id                = 801
    AND   source_lang = 'US'
    AND   descriptive_flexfield_name    = 'Action Information DF'
    AND   descriptive_flex_context_code = p_context_code
    AND   application_column_name       = UPPER(p_node);
    --
    CURSOR csr_inv_seg_check(l_tag VARCHAR2) IS
    SELECT 'N'
    FROM hr_lookups
    WHERE lookup_type = 'PAY_NL_INVALID_WR_TAGS'
    AND lookup_code   = upper(l_tag)
    AND description   =  l_tag
    AND enabled_flag  = 'Y'
    AND (to_char(start_date_active,'RRRR') <= g_year
         AND nvl(to_char(end_date_active,'RRRR'),'4712') >= g_year);

  l_tag_name  fnd_descr_flex_col_usage_tl.description%TYPE;
  l_display   VARCHAR2(1);
    --
BEGIN
    --
   IF (p_context_code <> p_node) THEN
    OPEN csr_get_tag_name;
        FETCH csr_get_tag_name INTO l_tag_name;
    CLOSE csr_get_tag_name;
   ELSE
     l_tag_name := p_node;
   END IF;
    --
     IF g_year >= '2008' THEN
      OPEN csr_inv_seg_check(l_tag_name);
      FETCH csr_inv_seg_check INTO l_display;
      IF csr_inv_seg_check%FOUND THEN
        l_tag_name := NULL;
      END IF;
      CLOSE csr_inv_seg_check;
    END IF;

   RETURN l_tag_name;
    --
END get_tag_name;
--
--------------------------------------------------------------------------------
--    Name        : LOAD_XML_INTERNAL
--    Description : This procedure loads the global XML cache.
--------------------------------------------------------------------------------
PROCEDURE load_xml_internal (P_NODE_TYPE         VARCHAR2
                            ,P_NODE              VARCHAR2
                            ,P_DATA              VARCHAR2) AS
    l_proc_name VARCHAR2(100);
    l_data      pay_action_information.action_information1%TYPE;
    --
BEGIN
    --
    IF p_node_type = 'CS' THEN
        g_xml_nwr (g_xml_nwr.count() + 1) := '<'||p_node||'>'||EOL;
    ELSIF p_node_type = 'CE' THEN
        g_xml_nwr (g_xml_nwr.count() + 1) := '</'||p_node||'>'||EOL;
    ELSIF p_node_type = 'D' AND p_data IS NOT NULL THEN
        /* Handle special charaters in data */
        l_data := REPLACE (p_data, '&', '&amp;');
        l_data := REPLACE (l_data, '>', '&gt;');
        l_data := REPLACE (l_data, '<', '&lt;');
        l_data := REPLACE (l_data, '''', '&apos;');
        l_data := REPLACE (l_data, '"', '&quot;');
        g_xml_nwr (g_xml_nwr.count() + 1) := '<'||p_node||'>'||l_data||'</'||p_node||'>'||EOL;
    ELSIF p_node_type = 'CD' AND p_data IS NOT NULL THEN
        l_data := p_data;
        g_xml_nwr (g_xml_nwr.count() + 1) := '<'||p_node||'><![CDATA['||l_data||']]></'||p_node||'>'||EOL;
    END IF;
    --
    END load_xml_internal;
--
--------------------------------------------------------------------------------
--    Name        : LOAD_XML
--    Description : This procedure loads the global XML cache.
--------------------------------------------------------------------------------
--
PROCEDURE load_xml (p_node_type     VARCHAR2
                   ,p_context_code  VARCHAR2
                   ,p_node          VARCHAR2
                   ,p_data          VARCHAR2) AS
    --
    CURSOR csr_get_tag_name IS
    SELECT TRANSLATE ((description), ' /','__') tag_name
    FROM  fnd_descr_flex_col_usage_tl
    WHERE application_id                = 801
    AND   source_lang = 'US'
    AND   descriptive_flexfield_name    = 'Action Information DF'
    AND   descriptive_flex_context_code = p_context_code
    AND   application_column_name       = UPPER (p_node);

    CURSOR csr_inv_seg_check(l_tag VARCHAR2) IS
    SELECT 'N'
    FROM hr_lookups
    WHERE lookup_type = 'PAY_NL_INVALID_WR_TAGS'
    AND lookup_code   = upper(l_tag)
    AND description   =  l_tag
    AND enabled_flag  = 'Y'
    AND (to_char(start_date_active,'RRRR') <= g_year
         AND nvl(to_char(end_date_active,'RRRR'),'4712') >= g_year);
    --

    l_proc_name VARCHAR2(100);
    l_tag_name  VARCHAR2(500);
    l_data      pay_action_information.action_information1%TYPE;
    l_display   VARCHAR2(1);

    --
BEGIN
    --
    l_display := 'Y';
    IF p_node_type in ('D','CD') THEN
        --
        -- Fetch segment names
        --
        OPEN csr_get_tag_name;
            FETCH csr_get_tag_name INTO l_tag_name;
        CLOSE csr_get_tag_name;
    END IF;
    --
    IF g_xml_nwr.count() <> 0 AND UPPER(p_node) NOT LIKE 'XAPI%' THEN
        l_tag_name := nvl(l_tag_name, TRANSLATE(p_node, ' /', '__'));
    ELSE
        l_tag_name := p_node;
    END IF;
    --
    IF g_year >= '2008'  THEN
      OPEN csr_inv_seg_check(l_tag_name);
      FETCH csr_inv_seg_check INTO l_display;
      IF csr_inv_seg_check%NOTFOUND THEN
        l_display := 'Y';
      ELSE
        l_display := 'N';
      END IF;
      CLOSE csr_inv_seg_check;
    END IF;
    IF l_display = 'Y' THEN
       l_data :=  p_data;
       IF p_node = 'Description' THEN     /***** for Description .. the tag name is fed through the p_data *****/
         l_data := get_tag_description(UPPER(p_data));
       END IF;
      IF g_report_type <> 'NLNWR_XML' AND p_context_code = 'NL_WR_INCOME_PERIOD' AND UPPER(l_tag_name) = 'CDAGH' THEN
      /** to avoid conflict between CdAGH in XML and CdAGH in the PDF output ***/
        l_data := NULL;
      END IF;
      load_xml_internal (p_node_type, l_tag_name, l_data);
    END IF;
    --
END load_xml;
--


--------------------------------------------------------------------------------
--    Name        : FLEX_SEG_ENABLED
--    Description : This function returns TRUE if an application column is
--                  registered with given context of Action Information DF.
--                  Otherwise, it returns false.
--------------------------------------------------------------------------------
--
FUNCTION flex_seg_enabled(p_context_code              VARCHAR2
                         ,p_application_column_name   VARCHAR2) RETURN BOOLEAN AS
    --
    CURSOR csr_seg_enabled IS
    SELECT 'Y'
    FROM fnd_descr_flex_col_usage_vl
    WHERE application_id                 = 801
    AND descriptive_flexfield_name  LIKE 'Action Information DF'
    AND descriptive_flex_context_code    =  p_context_code
    AND application_column_name       LIKE  p_application_column_name
    AND enabled_flag                     =  'Y';
    --
    l_exists    varchar2(1);
    --
BEGIN
    --
    OPEN csr_seg_enabled;
        FETCH csr_seg_enabled INTO l_exists;
    CLOSE csr_seg_enabled;
    --
    IF l_exists = 'Y' THEN
        RETURN (TRUE);
    ELSE
        RETURN (FALSE);
    END IF;
    --
END flex_seg_enabled;
--
--------------------------------------------------------------------------------
--    Name        : BUILD_SQL
--    Description : This procedure builds dynamic SQL string.
--------------------------------------------------------------------------------
--
PROCEDURE build_sql(p_sqlstr_tab    IN OUT NOCOPY DBMS_SQL.VARCHAR2S
                   ,p_cntr          IN OUT NOCOPY NUMBER
                   ,p_string        VARCHAR2) AS
    --
    l_proc_name varchar2(100);
    --
BEGIN
    p_sqlstr_tab(p_cntr) := p_string;
    p_cntr               := p_cntr + 1;
END;
--
--
--------------------------------------------------------------------------------
--    Name        : GET_LE_NAME
--    Description : This function returns the REPORTING NAME of the
--                  Legal Employer
--------------------------------------------------------------------------------
--
FUNCTION get_le_name(p_payroll_action_id      NUMBER) RETURN VARCHAR2 AS
    --
    CURSOR csr_get_name(p_organization_id NUMBER) IS
    SELECT hoi1.org_information14
    FROM hr_organization_units hou
        ,hr_organization_information hoi
        ,hr_organization_information hoi1
    WHERE hou.organization_id = hoi.organization_id
    AND	  hou.organization_id = hoi1.organization_id(+)
    AND	  hou.organization_id = p_organization_id
    AND	  hoi.org_information_context = 'CLASS'
    AND	  hoi1.org_information_context(+) = 'NL_ORG_INFORMATION';
    --
    l_name              hr_organization_information.org_information14%TYPE;
    l_legal_emplr_id    NUMBER(15);
    --
BEGIN
    --
    l_legal_emplr_id := pay_nl_wage_report_pkg.get_parameters(p_payroll_action_id, 'Legal_Employer');
    --
    OPEN csr_get_name(l_legal_emplr_id);
    FETCH csr_get_name INTO l_name;
    CLOSE csr_get_name;
    --
    RETURN l_name;
    --
END get_le_name;
--
--------------------------------------------------------------------------------
--    Name        : GENERATE_COLLECTIVE_REPORT
--    Description : This Procedure is used to generate the XML part for
--                  the tags in the Collective Report Part.
--------------------------------------------------------------------------------
--
PROCEDURE generate_collective_report( p_act_context_id       NUMBER
                                     ,p_type                 VARCHAR2
                                     ,p_start_date           VARCHAR2
                                     ,p_end_date             VARCHAR2
                                     ,p_in_not_in            VARCHAR2
                                     ,p_report_type          VARCHAR2) AS
--
BEGIN
--
   build_sql(sqlstr, l_cntr_sql, 'DECLARE l_col_tag fnd_descr_flex_col_usage_vl.description%TYPE; BEGIN ');

    --
    build_sql(sqlstr, l_cntr_sql, 'FOR csr_collective_info_rec IN pay_nl_nwr_xml_extract_pkg.csr_collective_info ('||p_act_context_id||',''NL_WR_COLLECTIVE_REPORT'','''|| p_type ||''','||p_start_date||','||p_end_date||') LOOP ');
    --
   --LC 2010 -- begin
    IF g_year >= '2010' THEN
	    build_sql(sqlstr, l_cntr_sql, 'IF csr_collective_info_rec.action_information2 '|| p_in_not_in ||'  (''IngBijdrZvw'',''PkAgh'',''PkNwArbvOudWn'',''PkInDnstOudWn'',''TotTeBet'') THEN ');
    ELSE
      build_sql(sqlstr, l_cntr_sql, 'IF csr_collective_info_rec.action_information2 '|| p_in_not_in ||'  (''IngBijdrZvw'',''AGHKort'',''TotTeBet'') THEN ');
    END IF;
   --LC 2010 -- end
    --
    IF p_report_type = 'NLNWR_XML' THEN
        build_sql(sqlstr, l_cntr_sql,
        'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', NULL, csr_collective_info_rec.action_information2, to_char(fnd_number.canonical_to_number(csr_collective_info_rec.action_information6)));');
    ELSE
        --
        build_sql(sqlstr, l_cntr_sql, 'l_col_tag :=  pay_nl_nwr_xml_extract_pkg.get_tag_name(csr_collective_info_rec.action_information2,csr_collective_info_rec.action_information2); ');
          build_sql(sqlstr, l_cntr_sql, 'IF l_col_tag IS NOT NULL THEN ');
           build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''CS'', NULL, ''CRRecords'', NULL);');
           build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', NULL, ''Tag'', csr_collective_info_rec.action_information2);');
            --build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', NULL, ''Description'', csr_collective_info_rec.action_information5);');
              build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', NULL, ''Description'', csr_collective_info_rec.action_information2);');
            build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', NULL, ''Amount'', to_char(fnd_number.canonical_to_number(csr_collective_info_rec.action_information6)));');
          --
           build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''CE'', NULL, ''CRRecords'', NULL);');
           build_sql(sqlstr, l_cntr_sql, 'END IF; ');
        END IF;
    --
    build_sql(sqlstr, l_cntr_sql, 'END IF;');
    --
    build_sql(sqlstr, l_cntr_sql, 'END LOOP;');
  build_sql(sqlstr, l_cntr_sql, 'END ;');

--
END generate_collective_report;
--
--------------------------------------------------------------------------------
--    Name        : GENERATE_IP_SRG_NR
--    Description : This Procedure is used to generate the XML part for
--                 (Income Period - Sector Rsik Group - Nominative Report).
--                  Instead of repeating it thrice, we call this Proc Thrice
--------------------------------------------------------------------------------
--
PROCEDURE generate_ip_srg_nr( p_action_context_id    NUMBER
                             ,p_type                 VARCHAR2
                             ,p_report_type          VARCHAR2) AS
--
BEGIN
--
    build_sql(sqlstr, l_cntr_sql, 'FOR csr_income_info_rec IN pay_nl_nwr_xml_extract_pkg.csr_income_info ('||p_action_context_id||',''NL_WR_INCOME_PERIOD'','''||p_type||''',csr_employment_info_rec.action_information_id) LOOP ');
    --
    -- Income Period <Inkomstenperiode>
    build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''CS'', NULL, ''Inkomstenperiode'', NULL);');
        --
        build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', ''NL_WR_INCOME_PERIOD'', ''ACTION_INFORMATION5'', TO_CHAR(fnd_date.canonical_to_date(csr_income_info_rec.action_information5),''YYYY-MM-DD''));');
        --
          FOR cntr in 6..19 LOOP --LC 2010 -- Split 6..30 to 6..19 20..27
            IF flex_seg_enabled ('NL_WR_INCOME_PERIOD', 'ACTION_INFORMATION'||cntr) THEN
                IF cntr = 13 THEN
                  IF g_year >= '2010' THEN
                --LC 2010--begin
                    build_sql(sqlstr, l_cntr_sql, 'IF csr_income_info_rec.action_information13 = ''1'' OR ');
                    build_sql(sqlstr, l_cntr_sql, 'csr_income_info_rec.action_information13 = ''2'' OR ');
                    build_sql(sqlstr, l_cntr_sql, 'csr_income_info_rec.action_information13 = ''3'' OR ');
                    build_sql(sqlstr, l_cntr_sql, 'csr_income_info_rec.action_information13 = ''4'' THEN ');
                    build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', NULL, ''IndPkAgh'', ''J'');');

                    build_sql(sqlstr, l_cntr_sql, 'ELSIF csr_income_info_rec.action_information13 = ''6'' THEN ');
                    build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', NULL, ''IndPkNwArbvOudWn'', ''J'');');

                    build_sql(sqlstr, l_cntr_sql, 'ELSIF csr_income_info_rec.action_information13 = ''7'' THEN ');
                    build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', NULL, ''IndPkInDnstOudWn'', ''J'');');

                    build_sql(sqlstr, l_cntr_sql, 'ELSIF csr_income_info_rec.action_information13 = ''8'' THEN ');
                    build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', NULL, ''IndPkAgh'', ''J'');');
                    build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', NULL, ''IndPkNwArbvOudWn'', ''J'');');

                    build_sql(sqlstr, l_cntr_sql, 'ELSIF csr_income_info_rec.action_information13 = ''9'' THEN ');
                    build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', NULL, ''IndPkAgh'', ''J'');');
                    build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', NULL, ''IndPkInDnstOudWn'', ''J'');');

                    build_sql(sqlstr, l_cntr_sql, 'END IF; ');
                --LC 2010--end
                  ELSIF g_year >= '2008' THEN
                    build_sql(sqlstr, l_cntr_sql, 'IF csr_income_info_rec.action_information13 IS NULL THEN ');
                      build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', ''NL_WR_INCOME_PERIOD'', ''ACTION_INFORMATION13'', NULL);');
                    build_sql(sqlstr, l_cntr_sql, 'ELSIF csr_income_info_rec.action_information13 = ''0'' THEN ');
                      build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', ''NL_WR_INCOME_PERIOD'', ''ACTION_INFORMATION13'', ''0'');');

                      --abraghun--7668628--LC 2009 changes Begin
                      IF g_year >= '2009' THEN

                        build_sql(sqlstr, l_cntr_sql, 'ELSIF csr_income_info_rec.action_information13 = ''1'' OR ');
                        build_sql(sqlstr, l_cntr_sql, 'csr_income_info_rec.action_information13 = ''2'' OR ');
                        build_sql(sqlstr, l_cntr_sql, 'csr_income_info_rec.action_information13 = ''3'' OR ');
                        build_sql(sqlstr, l_cntr_sql, 'csr_income_info_rec.action_information13 = ''4'' THEN ');
                        build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', ''NL_WR_INCOME_PERIOD'', ''ACTION_INFORMATION13'', ''5'');');
                        build_sql(sqlstr, l_cntr_sql, 'ELSIF csr_income_info_rec.action_information13 = ''6'' OR ');
                        build_sql(sqlstr, l_cntr_sql, 'csr_income_info_rec.action_information13 = ''7'' OR ');
                        build_sql(sqlstr, l_cntr_sql, 'csr_income_info_rec.action_information13 = ''8'' OR ');
                        build_sql(sqlstr, l_cntr_sql, 'csr_income_info_rec.action_information13 = ''9'' THEN ');
                        build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', ''NL_WR_INCOME_PERIOD'', ''ACTION_INFORMATION13'', csr_income_info_rec.action_information13);');

                      ELSE
                       build_sql(sqlstr, l_cntr_sql, 'ELSE ');
                        build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', ''NL_WR_INCOME_PERIOD'', ''ACTION_INFORMATION13'', ''5'');');
                      END IF;
                      --abraghun--7668628--LC 2009 changes End
              		    build_sql(sqlstr, l_cntr_sql, 'END IF; ');
                  ELSE
                    build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', ''NL_WR_INCOME_PERIOD'', ''ACTION_INFORMATION13'', csr_income_info_rec.action_information13);');
                  END IF;
                ELSE
                  build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', ''NL_WR_INCOME_PERIOD'', ''ACTION_INFORMATION'|| cntr ||''', csr_income_info_rec.action_information' || cntr ||');');
                END IF;
            END IF;
          END LOOP;
-- LC 2010 -- New Tags IndPma, IndWgldOudRegl begin
          IF g_year >= '2010' THEN
            FOR cntr in 28..29 LOOP --LC 2010 -- Split 6..30 to 6..19 28..29  20..27
              IF flex_seg_enabled ('NL_WR_INCOME_PERIOD', 'ACTION_INFORMATION'||cntr) THEN
                build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', ''NL_WR_INCOME_PERIOD'', ''ACTION_INFORMATION'|| cntr ||''', csr_income_info_rec.action_information' || cntr ||');');
              END IF;
            END LOOP;
          END IF;
-- LC 2010 -- New Tags IndPma, IndWgldOudRegl end
          FOR cntr in 20..27 LOOP --LC 2010 -- Split 6..30 to 6..19 28..29  20..27
            IF flex_seg_enabled ('NL_WR_INCOME_PERIOD', 'ACTION_INFORMATION'||cntr) THEN
                  build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', ''NL_WR_INCOME_PERIOD'', ''ACTION_INFORMATION'|| cntr ||''', csr_income_info_rec.action_information' || cntr ||');');
            END IF;
          END LOOP;

        IF p_report_type <> 'NLNWR_XML' THEN
        --
        --build_sql(sqlstr, l_cntr_sql, 'Declare l_code_contract VARCHAR2(50); Begin ');
        --build_sql(sqlstr, l_cntr_sql, 'IF csr_income_info_rec.action_information9 = ''O'' THEN l_code_contract := ''Permanent'' ; ELSIF csr_income_info_rec.action_information9 = ''B'' THEN l_code_contract := ''Fixed Term''; END IF; ');
        --build_sql(sqlstr, l_cntr_sql, 'End; ');

         build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', NULL, ''SrtIVM'', hr_general.decode_lookup(''NL_INCOME_CODE'', csr_income_info_rec.action_information6));');
         build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', NULL, ''CdAardM'', hr_general.decode_lookup(''NL_LABOR_RELATION_CODE'', csr_income_info_rec.action_information7));');
     --LC 2010-- begin
          build_sql(sqlstr, l_cntr_sql, 'IF csr_income_info_rec.action_information8 IN (''AF'',''BF'',''CF'',''DF'',''EF'') THEN ');
          build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', NULL, ''CdInvlVplM'',
          hr_general.decode_lookup(''NL_INFLUENCE_CODE'', SUBSTR(csr_income_info_rec.action_information8,1,1))||'' / ''||
          hr_general.decode_lookup(''NL_INFLUENCE_CODE'', ''F''));');
          build_sql(sqlstr, l_cntr_sql, 'ELSE pay_nl_nwr_xml_extract_pkg.load_xml(''D'', NULL, ''CdInvlVplM'', hr_general.decode_lookup(''NL_INFLUENCE_CODE'', csr_income_info_rec.action_information8));');
          build_sql(sqlstr, l_cntr_sql, 'END IF; ');
     --LC 2010-- end
         --build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', NULL, ''CdBepTdM'', hr_general.decode_lookup(''NL_EMPLOYMENT_CATG'', csr_income_info_rec.action_information9));');
         build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', NULL, ''CdBepTdM'', hr_general.decode_lookup(NVL(csr_message_info_rec.action_information12,''NL_EMPLOYMENT_CATG''), csr_income_info_rec.action_information9));');
         build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', NULL, ''FsIndFZM'', hr_general.decode_lookup(''NL_TEMP_LABOR_CODE'', csr_income_info_rec.action_information10));');
         build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', NULL, ''IndRglmArbM'', hr_general.decode_lookup(''YES_NO'',pay_nl_nwr_xml_extract_pkg.yes_no(csr_income_info_rec.action_information11)));');
         build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', NULL, ''CAOM'', hr_general.decode_lookup(''NL_COLLECTIVE_AGREEMENT'', csr_income_info_rec.action_information12));');
--
         IF g_year >= '2010' THEN
         --LC 2010--begin
          build_sql(sqlstr, l_cntr_sql, 'IF csr_income_info_rec.action_information13 = ''1'' OR ');
          build_sql(sqlstr, l_cntr_sql, 'csr_income_info_rec.action_information13 = ''2'' OR ');
          build_sql(sqlstr, l_cntr_sql, 'csr_income_info_rec.action_information13 = ''3'' OR ');
          build_sql(sqlstr, l_cntr_sql, 'csr_income_info_rec.action_information13 = ''4'' THEN ');
          build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', NULL, ''IndPkAghM'', hr_general.decode_lookup(''YES_NO'',''Y''));');

          build_sql(sqlstr, l_cntr_sql, 'ELSIF csr_income_info_rec.action_information13 = ''6'' THEN ');
          build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', NULL, ''IndPkNwArbvOudWnM'', hr_general.decode_lookup(''YES_NO'',''Y''));');

          build_sql(sqlstr, l_cntr_sql, 'ELSIF csr_income_info_rec.action_information13 = ''7'' THEN ');
          build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', NULL, ''IndPkInDnstOudWnM'', hr_general.decode_lookup(''YES_NO'',''Y''));');

          build_sql(sqlstr, l_cntr_sql, 'ELSIF csr_income_info_rec.action_information13 = ''8'' THEN ');
          build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', NULL, ''IndPkAghM'', hr_general.decode_lookup(''YES_NO'',''Y''));');
          build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', NULL, ''IndPkNwArbvOudWnM'', hr_general.decode_lookup(''YES_NO'',''Y''));');

          build_sql(sqlstr, l_cntr_sql, 'ELSIF csr_income_info_rec.action_information13 = ''9'' THEN ');
          build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', NULL, ''IndPkAghM'', hr_general.decode_lookup(''YES_NO'',''Y''));');
          build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', NULL, ''IndPkInDnstOudWnM'', hr_general.decode_lookup(''YES_NO'',''Y''));');

          build_sql(sqlstr, l_cntr_sql, 'END IF; ');
          --LC 2010--end
         ELSE
           IF g_year < '2008' THEN
             build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', NULL, ''CdAGH'', hr_general.decode_lookup(''NL_FORM_LABELS'',''CDAGH''));');
           ELSE
             build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', NULL, ''CdAGH'', hr_general.decode_lookup(''NL_FORM_LABELS'',''CDAGH_2008''));');
           END IF;
           IF g_year >= '2008' THEN
            build_sql(sqlstr, l_cntr_sql, 'IF csr_income_info_rec.action_information13 IS NULL THEN ');
             build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', NULL, ''CdAGHM'', NULL); ');
            build_sql(sqlstr, l_cntr_sql, 'ELSIF csr_income_info_rec.action_information13 = ''0'' THEN ');
             build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', NULL, ''CdAGHM'',csr_income_info_rec.action_information13||'' ''|| hr_general.decode_lookup(''NL_FORM_LABELS'',''LC0_CDAGH'')); ');
          --abraghun--7668628--LC 2009 changes Begin
            IF g_year >= '2009' THEN
              build_sql(sqlstr, l_cntr_sql, 'ELSIF csr_income_info_rec.action_information13 = ''1'' OR ');
              build_sql(sqlstr, l_cntr_sql, 'csr_income_info_rec.action_information13 = ''2'' OR ');
              build_sql(sqlstr, l_cntr_sql, 'csr_income_info_rec.action_information13 = ''3'' OR ');
              build_sql(sqlstr, l_cntr_sql, 'csr_income_info_rec.action_information13 = ''4'' THEN ');
              build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', NULL, ''CdAGHM'',''5 ''|| hr_general.decode_lookup(''NL_FORM_LABELS'',''LC5_CDAGH'')); ');

              build_sql(sqlstr, l_cntr_sql, 'ELSIF csr_income_info_rec.action_information13 = ''6'' THEN ');
              build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', NULL, ''CdAGHM'',''6 ''|| hr_general.decode_lookup(''NL_FORM_LABELS'',''LC6_CDAGH'')); ');

              build_sql(sqlstr, l_cntr_sql, 'ELSIF csr_income_info_rec.action_information13 = ''7'' THEN ');
              build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', NULL, ''CdAGHM'',''7 ''|| hr_general.decode_lookup(''NL_FORM_LABELS'',''LC7_CDAGH'')); ');

              build_sql(sqlstr, l_cntr_sql, 'ELSIF csr_income_info_rec.action_information13 = ''8'' THEN ');
              build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', NULL, ''CdAGHM'',''8 ''|| hr_general.decode_lookup(''NL_FORM_LABELS'',''LC8_CDAGH'')); ');

              build_sql(sqlstr, l_cntr_sql, 'ELSIF csr_income_info_rec.action_information13 = ''9'' THEN ');
              build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', NULL, ''CdAGHM'',''9 ''|| hr_general.decode_lookup(''NL_FORM_LABELS'',''LC9_CDAGH'')); ');

            ELSE
              build_sql(sqlstr, l_cntr_sql, 'ELSE ');
              build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', NULL, ''CdAGHM'',''5 ''|| hr_general.decode_lookup(''NL_FORM_LABELS'',''LC5_CDAGH'')); ');
            END IF;
           --abraghun--7668628--LC 2009 changes End
            build_sql(sqlstr, l_cntr_sql, 'END IF; ');
           ELSE
             build_sql(sqlstr, l_cntr_sql,
             'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', NULL, ''CdAGHM'',  csr_income_info_rec.action_information13||'' ''||hr_general.decode_lookup(''NL_LABOUR_HANDICAP_DISC_TYPE'',csr_income_info_rec.action_information13));');
           END IF;
         END IF; --LC 2010--
--
         build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', NULL, ''IndLhKortM'', hr_general.decode_lookup(''YES_NO'',pay_nl_nwr_xml_extract_pkg.yes_no(csr_income_info_rec.action_information14)));');
         build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', NULL, ''CdRdnGnBijtM'', hr_general.decode_lookup(''NL_COMPANY_CAR_USAGE_CODE'', csr_income_info_rec.action_information15));');
         --build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', NULL, ''LbTabM'', hr_general.decode_lookup(''NL_TAX_CODE'', csr_income_info_rec.action_information16));');
         IF g_year = '2006' THEN
            build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', NULL, ''IndWAOD'', hr_general.decode_lookup(''NL_FORM_LABELS'',''INDWAO_2006''));');
         ELSE
            build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', NULL, ''IndWAOD'', hr_general.decode_lookup(''NL_FORM_LABELS'',''INDWAO''));');
         END IF;
         build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', NULL, ''IndWAOM'', hr_general.decode_lookup(''YES_NO'',pay_nl_nwr_xml_extract_pkg.yes_no(csr_income_info_rec.action_information17)));');
         build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', NULL, ''IndWWM'', hr_general.decode_lookup(''YES_NO'',pay_nl_nwr_xml_extract_pkg.yes_no(csr_income_info_rec.action_information18)));');
         build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', NULL, ''IndZWM'', hr_general.decode_lookup(''YES_NO'',pay_nl_nwr_xml_extract_pkg.yes_no(csr_income_info_rec.action_information19)));');
        --LC 2010--begin New Tags from 2010.
         IF g_year >= '2010' THEN
         build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', NULL, ''IndPmaM'', hr_general.decode_lookup(''YES_NO'',pay_nl_nwr_xml_extract_pkg.yes_no(csr_income_info_rec.action_information28)));');
         build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', NULL, ''IndWgldOudReglM'', hr_general.decode_lookup(''YES_NO'',pay_nl_nwr_xml_extract_pkg.yes_no(csr_income_info_rec.action_information29)));');
         END IF;
        --LC 2010--end
         build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', NULL, ''CdZvwM'', hr_general.decode_lookup(''NL_ZVW_INSURED'', csr_income_info_rec.action_information20));');
         build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', NULL, ''IndVakBnM'', hr_general.decode_lookup(''YES_NO'',pay_nl_nwr_xml_extract_pkg.yes_no(csr_income_info_rec.action_information21)));');
         build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', NULL, ''IndSA71M'', hr_general.decode_lookup(''YES_NO'',pay_nl_nwr_xml_extract_pkg.yes_no(csr_income_info_rec.action_information22)));');
         build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', NULL, ''IndSA72M'', hr_general.decode_lookup(''YES_NO'',pay_nl_nwr_xml_extract_pkg.yes_no(csr_income_info_rec.action_information23)));');
         build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', NULL, ''IndSA43M'', hr_general.decode_lookup(''YES_NO'',pay_nl_nwr_xml_extract_pkg.yes_no(csr_income_info_rec.action_information24)));');
         build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', NULL, ''IndSA03M'', hr_general.decode_lookup(''YES_NO'',pay_nl_nwr_xml_extract_pkg.yes_no(csr_income_info_rec.action_information25)));');
         build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', NULL, ''CdIncInkVermM'', hr_general.decode_lookup(''NL_INCOME_DECREASE_CODE'', csr_income_info_rec.action_information26));');
         build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', NULL, ''IndAanvUitkM'', hr_general.decode_lookup(''YES_NO'',pay_nl_nwr_xml_extract_pkg.yes_no(csr_income_info_rec.action_information27)));');
        END IF;
        --
    -- Income Period </Inkomstenperiode>
    build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''CE'', NULL, ''Inkomstenperiode'', NULL);');
    --
    build_sql(sqlstr, l_cntr_sql, 'END LOOP;');
    --
    build_sql(sqlstr, l_cntr_sql, 'FOR csr_income_info_rec IN pay_nl_nwr_xml_extract_pkg.csr_income_info ('||p_action_context_id||',''NL_WR_SWMF_SECTOR_RISK_GROUP'',''SECTOR_RISK_GROUP'',csr_employment_info_rec.action_information_id) LOOP ');
    --
    -- Sector Risk Group <SectorRisicogroep>
    build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''CS'', NULL, ''SectorRisicogroep'', NULL);');
        --
             build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', ''NL_WR_SWMF_SECTOR_RISK_GROUP'', ''ACTION_INFORMATION5'', TO_CHAR(fnd_date.canonical_to_date(csr_income_info_rec.action_information5),''YYYY-MM-DD''));');
             build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', ''NL_WR_SWMF_SECTOR_RISK_GROUP'', ''ACTION_INFORMATION6'', TO_CHAR(fnd_date.canonical_to_date(csr_income_info_rec.action_information6),''YYYY-MM-DD''));');
        FOR cntr in 7..8 LOOP
            IF flex_seg_enabled ('NL_WR_SWMF_SECTOR_RISK_GROUP', 'ACTION_INFORMATION'||cntr) THEN
             build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', ''NL_WR_SWMF_SECTOR_RISK_GROUP'', ''ACTION_INFORMATION'|| cntr ||''', csr_income_info_rec.action_information' || cntr ||');');
            END IF;
        END LOOP;
        --
        --LC 2010-- begin
        --
        IF g_year >= '2010' THEN
          build_sql(sqlstr, l_cntr_sql, 'FOR csr_income_info_rec1 IN pay_nl_nwr_xml_extract_pkg.csr_income_info1 ('||p_action_context_id||',''NL_WR_NOMINATIVE_REPORT_ADD'','''||p_type||''',csr_employment_info_rec.action_information_id) LOOP ');
          --
          FOR cntr1 in 15..15 LOOP  --LC 2010 --  New Tag PrLnPrSectFnds
              IF flex_seg_enabled ('NL_WR_NOMINATIVE_REPORT_ADD', 'ACTION_INFORMATION'||cntr1) THEN
             build_sql(sqlstr, l_cntr_sql, 'IF csr_income_info_rec1.action_information' || cntr1 ||' IS NOT NULL THEN ');
             build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', ''NL_WR_NOMINATIVE_REPORT_ADD'',
	      ''ACTION_INFORMATION'|| cntr1 ||''', TO_CHAR(fnd_number.canonical_to_number(csr_income_info_rec1.action_information' || cntr1 ||'),''FM999999999999999999990.00''));');
             build_sql(sqlstr, l_cntr_sql, 'END IF; ');
               END IF;
          END LOOP;
          build_sql(sqlstr, l_cntr_sql, 'END LOOP; ');

          build_sql(sqlstr, l_cntr_sql, 'FOR csr_income_info_rec2 IN pay_nl_nwr_xml_extract_pkg.csr_income_info1 ('||p_action_context_id||',''NL_WR_NOMINATIVE_REPORT'','''||p_type||''',csr_employment_info_rec.action_information_id) LOOP ');
          FOR cntr2 in 19..19 LOOP  --From 2010, Tag moved from Employee Data Part (PrWgf).
              IF flex_seg_enabled ('NL_WR_NOMINATIVE_REPORT', 'ACTION_INFORMATION'||cntr2) THEN
               build_sql(sqlstr, l_cntr_sql, 'IF csr_income_info_rec2.action_information' || cntr2 ||' IS NOT NULL THEN ');
               build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', ''NL_WR_NOMINATIVE_REPORT'', ''ACTION_INFORMATION'|| cntr2 ||''',
	        TO_CHAR(fnd_number.canonical_to_number(csr_income_info_rec2.action_information' || cntr2 ||'),''FM999999999999999999990.00''));');
               build_sql(sqlstr, l_cntr_sql, 'END IF; ');
              END IF;
          END LOOP;
          build_sql(sqlstr, l_cntr_sql, 'END LOOP;');
        END IF;
        --
        --LC 2010-- end
    -- Sector Risk Group </SectorRisicogroep>
    build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''CE'', NULL, ''SectorRisicogroep'', NULL);');
    --
    build_sql(sqlstr, l_cntr_sql, 'END LOOP;');
    --
    build_sql(sqlstr, l_cntr_sql, 'DECLARE l_tag fnd_descr_flex_col_usage_vl.description%TYPE; BEGIN ');
    --
    -- Nominative Report <NominatieveAangifte>
    --build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''CS'', NULL, ''NominatieveAangifte'', NULL);');
    --
    build_sql(sqlstr, l_cntr_sql, 'FOR csr_income_info_rec IN pay_nl_nwr_xml_extract_pkg.csr_income_info ('||p_action_context_id||',''NL_WR_NOMINATIVE_REPORT'','''||p_type||''',csr_employment_info_rec.action_information_id) LOOP ');
    --
    -- Nominative Report <NominatieveAangifte>
    IF g_year = '2006' OR p_report_type <> 'NLNWR_XML' THEN
        build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''CS'', NULL, ''NominatieveAangifte'', NULL);');
    ELSE
        IF g_year >= '2008'
        AND  g_payroll_type <> 'YEARLY' --8552196
        THEN
          build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''CS'', NULL, ''Werknemersgegevens'', NULL);');
        ELSE
          build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''CS'', NULL, ''Werknemergegevens'', NULL);');
        END IF;
    END IF;
        --
        FOR cntr in 5..6 LOOP --LC 2010-- Changed from 5..14 to 5..6
            IF flex_seg_enabled ('NL_WR_NOMINATIVE_REPORT', 'ACTION_INFORMATION'||cntr) THEN
                --
                build_sql(sqlstr, l_cntr_sql, 'IF csr_income_info_rec.action_information' || cntr ||' IS NOT NULL THEN ');
                --
                IF p_report_type = 'NLNWR_XML' THEN
                     --
                     build_sql(sqlstr, l_cntr_sql,
'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', ''NL_WR_NOMINATIVE_REPORT'', ''ACTION_INFORMATION'|| cntr ||''', TO_CHAR(fnd_number.canonical_to_number(csr_income_info_rec.action_information' || cntr ||'),''FM999999999999999999990.00''));');
                     --
                ELSE

                    --
                    build_sql(sqlstr, l_cntr_sql, 'l_tag :=  pay_nl_nwr_xml_extract_pkg.get_tag_name(''NL_WR_NOMINATIVE_REPORT'',''ACTION_INFORMATION'|| cntr ||''');');
                    --
                      build_sql(sqlstr, l_cntr_sql, 'IF l_tag IS NOT NULL THEN ');
                      build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''CS'', NULL, ''NRRecords'', NULL);');
                        build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', NULL, ''Tag'', l_tag );');
                         build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', NULL, ''Description'', l_tag); ');
                        build_sql(sqlstr, l_cntr_sql,
                        'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', NULL, ''Amount'', TO_CHAR(fnd_number.canonical_to_number(csr_income_info_rec.action_information' || cntr ||'),''FM999999999999999999990.00''));');
                      build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''CE'', NULL, ''NRRecords'', NULL);');
                      build_sql(sqlstr, l_cntr_sql, 'END IF; ');
                    --

                END IF;
                --
             build_sql(sqlstr, l_cntr_sql, 'END IF; ');
             --
            END IF;
        END LOOP;
        --
        IF g_year >= '2010' THEN
          --LC 2010-- begin
          --New Tags introduced in 2010 PrLnWao(12), PrLnWaoWga(13), PrLnWwAwf(14),PrLnUfo(16)
          --
          -- Added for the New Context NL_WR_NOMINATIVE_REPORT_ADD
          --
          build_sql(sqlstr, l_cntr_sql, 'FOR csr_income_info_rec1 IN pay_nl_nwr_xml_extract_pkg.csr_income_info1 ('||p_action_context_id||',''NL_WR_NOMINATIVE_REPORT_ADD'','''||p_type||''',csr_employment_info_rec.action_information_id) LOOP ');
          --
          FOR cntr1 in 12..14 LOOP
              IF flex_seg_enabled ('NL_WR_NOMINATIVE_REPORT_ADD', 'ACTION_INFORMATION'||cntr1) THEN
                  --
                  build_sql(sqlstr, l_cntr_sql, 'IF csr_income_info_rec1.action_information' || cntr1 ||' IS NOT NULL THEN ');
                  --
                  IF p_report_type = 'NLNWR_XML' THEN
                       --
                       build_sql(sqlstr, l_cntr_sql,
      'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', ''NL_WR_NOMINATIVE_REPORT_ADD'', ''ACTION_INFORMATION'|| cntr1 ||''', TO_CHAR(fnd_number.canonical_to_number(csr_income_info_rec1.action_information' || cntr1 ||'),''FM999999999999999999990.00''));');
                       --
                  ELSE
                      --
                      build_sql(sqlstr, l_cntr_sql, 'l_tag :=  pay_nl_nwr_xml_extract_pkg.get_tag_name(''NL_WR_NOMINATIVE_REPORT_ADD'',''ACTION_INFORMATION'|| cntr1 ||''');');
                      --
                         build_sql(sqlstr, l_cntr_sql, 'IF l_tag IS NOT NULL THEN ');
                          build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''CS'', NULL, ''NRRecords'', NULL);');
                           build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', NULL, ''Tag'', l_tag );');
                           build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', NULL, ''Description'', l_tag); ');
                          build_sql(sqlstr, l_cntr_sql,
                          'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', NULL, ''Amount'', TO_CHAR(fnd_number.canonical_to_number(csr_income_info_rec1.action_information' || cntr1 ||'),''FM999999999999999999990.00''));');
                      build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''CE'', NULL, ''NRRecords'', NULL);');
                      build_sql(sqlstr, l_cntr_sql, 'END IF; ');
                      END IF;
                  --
               build_sql(sqlstr, l_cntr_sql, 'END IF; ');
               --
              END IF;
          END LOOP;
          FOR cntr1 in 16..16 LOOP  --PrLnUfo(16)
              IF flex_seg_enabled ('NL_WR_NOMINATIVE_REPORT_ADD', 'ACTION_INFORMATION'||cntr1) THEN
                  --
                  build_sql(sqlstr, l_cntr_sql, 'IF csr_income_info_rec1.action_information' || cntr1 ||' IS NOT NULL THEN ');
                  --
                  IF p_report_type = 'NLNWR_XML' THEN
                       --
                       build_sql(sqlstr, l_cntr_sql,
      'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', ''NL_WR_NOMINATIVE_REPORT_ADD'', ''ACTION_INFORMATION'|| cntr1 ||''', TO_CHAR(fnd_number.canonical_to_number(csr_income_info_rec1.action_information' || cntr1 ||'),''FM999999999999999999990.00''));');
                       --
                  ELSE
                      --
                      build_sql(sqlstr, l_cntr_sql, 'l_tag :=  pay_nl_nwr_xml_extract_pkg.get_tag_name(''NL_WR_NOMINATIVE_REPORT_ADD'',''ACTION_INFORMATION'|| cntr1 ||''');');
                      --
                         build_sql(sqlstr, l_cntr_sql, 'IF l_tag IS NOT NULL THEN ');
                          build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''CS'', NULL, ''NRRecords'', NULL);');
                           build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', NULL, ''Tag'', l_tag );');
                           build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', NULL, ''Description'', l_tag); ');
                          build_sql(sqlstr, l_cntr_sql,
                          'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', NULL, ''Amount'', TO_CHAR(fnd_number.canonical_to_number(csr_income_info_rec1.action_information' || cntr1 ||'),''FM999999999999999999990.00''));');
                      build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''CE'', NULL, ''NRRecords'', NULL);');
                      build_sql(sqlstr, l_cntr_sql, 'END IF; ');
                      END IF;
                  --
               build_sql(sqlstr, l_cntr_sql, 'END IF; ');
               --
              END IF;
          END LOOP;
          build_sql(sqlstr, l_cntr_sql, 'END LOOP;');
        --
        --LC 2010-- end
        END IF;
        --
        FOR cntr in 7..14 LOOP --LC 2010-- Splitted from 5..14 to 5..6 and 7..14
            IF flex_seg_enabled ('NL_WR_NOMINATIVE_REPORT', 'ACTION_INFORMATION'||cntr) THEN
                --
                build_sql(sqlstr, l_cntr_sql, 'IF csr_income_info_rec.action_information' || cntr ||' IS NOT NULL THEN ');
                --
                IF p_report_type = 'NLNWR_XML' THEN
                     --
                     build_sql(sqlstr, l_cntr_sql,
'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', ''NL_WR_NOMINATIVE_REPORT'', ''ACTION_INFORMATION'|| cntr ||''', TO_CHAR(fnd_number.canonical_to_number(csr_income_info_rec.action_information' || cntr ||'),''FM999999999999999999990.00''));');
                     --
                ELSE

                    --
                    build_sql(sqlstr, l_cntr_sql, 'l_tag :=  pay_nl_nwr_xml_extract_pkg.get_tag_name(''NL_WR_NOMINATIVE_REPORT'',''ACTION_INFORMATION'|| cntr ||''');');
                    --
                      build_sql(sqlstr, l_cntr_sql, 'IF l_tag IS NOT NULL THEN ');
                      build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''CS'', NULL, ''NRRecords'', NULL);');
                        build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', NULL, ''Tag'', l_tag );');
                         build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', NULL, ''Description'', l_tag); ');
                        build_sql(sqlstr, l_cntr_sql,
                        'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', NULL, ''Amount'', TO_CHAR(fnd_number.canonical_to_number(csr_income_info_rec.action_information' || cntr ||'),''FM999999999999999999990.00''));');
                      build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''CE'', NULL, ''NRRecords'', NULL);');
                      build_sql(sqlstr, l_cntr_sql, 'END IF; ');
                    --

                END IF;
                --
             build_sql(sqlstr, l_cntr_sql, 'END IF; ');
             --
            END IF;
        END LOOP;

        --
        -- Added for the New Context NL_WR_NOMINATIVE_REPORT_ADD
        --
        build_sql(sqlstr, l_cntr_sql, 'FOR csr_income_info_rec1 IN pay_nl_nwr_xml_extract_pkg.csr_income_info1 ('||p_action_context_id||',''NL_WR_NOMINATIVE_REPORT_ADD'','''||p_type||''',csr_employment_info_rec.action_information_id) LOOP ');
        --
        FOR cntr1 in 10..10 LOOP
            IF flex_seg_enabled ('NL_WR_NOMINATIVE_REPORT_ADD', 'ACTION_INFORMATION'||cntr1) THEN
                --
                build_sql(sqlstr, l_cntr_sql, 'IF csr_income_info_rec1.action_information' || cntr1 ||' IS NOT NULL THEN ');
                --
                IF p_report_type = 'NLNWR_XML' THEN
                     --
                     build_sql(sqlstr, l_cntr_sql,
    'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', ''NL_WR_NOMINATIVE_REPORT_ADD'', ''ACTION_INFORMATION'|| cntr1 ||''', TO_CHAR(fnd_number.canonical_to_number(csr_income_info_rec1.action_information' || cntr1 ||'),''FM999999999999999999990.00''));');
                     --
                ELSE
                    --
                    build_sql(sqlstr, l_cntr_sql, 'l_tag :=  pay_nl_nwr_xml_extract_pkg.get_tag_name(''NL_WR_NOMINATIVE_REPORT_ADD'',''ACTION_INFORMATION'|| cntr1 ||''');');
                    --
                       build_sql(sqlstr, l_cntr_sql, 'IF l_tag IS NOT NULL THEN ');
                        build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''CS'', NULL, ''NRRecords'', NULL);');
                         build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', NULL, ''Tag'', l_tag );');
                         build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', NULL, ''Description'', l_tag); ');
                        build_sql(sqlstr, l_cntr_sql,
                        'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', NULL, ''Amount'', TO_CHAR(fnd_number.canonical_to_number(csr_income_info_rec1.action_information' || cntr1 ||'),''FM999999999999999999990.00''));');
                    build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''CE'', NULL, ''NRRecords'', NULL);');
                    build_sql(sqlstr, l_cntr_sql, 'END IF; ');
                    END IF;
                --
             build_sql(sqlstr, l_cntr_sql, 'END IF; ');
             --
            END IF;
        END LOOP;
        build_sql(sqlstr, l_cntr_sql, 'END LOOP;');
        --
        --
        FOR cntr in 15..18 LOOP  --LC 2010 -- Changed 15..22 to 15..18 , 19..19, 20..22
            IF flex_seg_enabled ('NL_WR_NOMINATIVE_REPORT', 'ACTION_INFORMATION'||cntr) THEN
                --
                build_sql(sqlstr, l_cntr_sql, 'IF csr_income_info_rec.action_information' || cntr ||' IS NOT NULL THEN ');
                --
                IF p_report_type = 'NLNWR_XML' THEN
                     --
                     build_sql(sqlstr, l_cntr_sql,
'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', ''NL_WR_NOMINATIVE_REPORT'', ''ACTION_INFORMATION'|| cntr ||''', TO_CHAR(fnd_number.canonical_to_number(csr_income_info_rec.action_information' || cntr ||'),''FM999999999999999999990.00''));');
                     --
                ELSE
                     --
                    build_sql(sqlstr, l_cntr_sql, 'l_tag :=  pay_nl_nwr_xml_extract_pkg.get_tag_name(''NL_WR_NOMINATIVE_REPORT'',''ACTION_INFORMATION'|| cntr ||''');');
                    --
                      build_sql(sqlstr, l_cntr_sql, 'IF l_tag IS NOT NULL THEN ');
                       build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''CS'', NULL, ''NRRecords'', NULL);');
                        build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', NULL, ''Tag'', l_tag );');
                        IF cntr in (16,17) AND g_year = '2006' THEN
                            build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', NULL, ''Description'', hr_general.decode_lookup(''NL_FORM_LABELS'',UPPER(l_tag)'||'||''_2006'''||'));');
                        ELSE
                         build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', NULL, ''Description'',l_tag); ');
                        END IF;
                        build_sql(sqlstr, l_cntr_sql,
                        'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', NULL, ''Amount'', TO_CHAR(fnd_number.canonical_to_number(csr_income_info_rec.action_information' || cntr ||'),''FM999999999999999999990.00''));');
                     build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''CE'', NULL, ''NRRecords'', NULL);');
                     build_sql(sqlstr, l_cntr_sql, 'END IF; ');
                    --
                    END IF;
                --
             build_sql(sqlstr, l_cntr_sql, 'END IF; ');
             --
            END IF;
        END LOOP;
        --
        IF g_year < '2010' THEN --From 2010, Tag moved to Sect. Risk. Group section.
          FOR cntr in 19..19 LOOP  --LC 2010 -- Changed 15..22 to 15..18 , 19..19, 20..22
              IF flex_seg_enabled ('NL_WR_NOMINATIVE_REPORT', 'ACTION_INFORMATION'||cntr) THEN
                  --
                  build_sql(sqlstr, l_cntr_sql, 'IF csr_income_info_rec.action_information' || cntr ||' IS NOT NULL THEN ');
                  --
                  IF p_report_type = 'NLNWR_XML' THEN
                       --
                       build_sql(sqlstr, l_cntr_sql,
  'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', ''NL_WR_NOMINATIVE_REPORT'', ''ACTION_INFORMATION'|| cntr ||''', TO_CHAR(fnd_number.canonical_to_number(csr_income_info_rec.action_information' || cntr ||'),''FM999999999999999999990.00''));');
                       --
                  ELSE
                       --
                      build_sql(sqlstr, l_cntr_sql, 'l_tag :=  pay_nl_nwr_xml_extract_pkg.get_tag_name(''NL_WR_NOMINATIVE_REPORT'',''ACTION_INFORMATION'|| cntr ||''');');
                      --
                        build_sql(sqlstr, l_cntr_sql, 'IF l_tag IS NOT NULL THEN ');
                         build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''CS'', NULL, ''NRRecords'', NULL);');
                          build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', NULL, ''Tag'', l_tag );');
                           build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', NULL, ''Description'',l_tag); ');
                          build_sql(sqlstr, l_cntr_sql,
                          'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', NULL, ''Amount'', TO_CHAR(fnd_number.canonical_to_number(csr_income_info_rec.action_information' || cntr ||'),''FM999999999999999999990.00''));');
                       build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''CE'', NULL, ''NRRecords'', NULL);');
                       build_sql(sqlstr, l_cntr_sql, 'END IF; ');
                      --
                      END IF;
                  --
               build_sql(sqlstr, l_cntr_sql, 'END IF; ');
               --
              END IF;
          END LOOP;
        END IF;
        --
        FOR cntr in 20..22 LOOP  --LC 2010 -- Changed 15..22 to 15..18 , 19..19, 20..22
            IF flex_seg_enabled ('NL_WR_NOMINATIVE_REPORT', 'ACTION_INFORMATION'||cntr) THEN
                --
                build_sql(sqlstr, l_cntr_sql, 'IF csr_income_info_rec.action_information' || cntr ||' IS NOT NULL THEN ');
                --
                IF p_report_type = 'NLNWR_XML' THEN
                     --
                     build_sql(sqlstr, l_cntr_sql,
'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', ''NL_WR_NOMINATIVE_REPORT'', ''ACTION_INFORMATION'|| cntr ||''', TO_CHAR(fnd_number.canonical_to_number(csr_income_info_rec.action_information' || cntr ||'),''FM999999999999999999990.00''));');
                     --
                ELSE
                     --
                    build_sql(sqlstr, l_cntr_sql, 'l_tag :=  pay_nl_nwr_xml_extract_pkg.get_tag_name(''NL_WR_NOMINATIVE_REPORT'',''ACTION_INFORMATION'|| cntr ||''');');
                    --
                      build_sql(sqlstr, l_cntr_sql, 'IF l_tag IS NOT NULL THEN ');
                       build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''CS'', NULL, ''NRRecords'', NULL);');
                        build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', NULL, ''Tag'', l_tag );');
                         build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', NULL, ''Description'',l_tag); ');
                        build_sql(sqlstr, l_cntr_sql,
                        'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', NULL, ''Amount'', TO_CHAR(fnd_number.canonical_to_number(csr_income_info_rec.action_information' || cntr ||'),''FM999999999999999999990.00''));');
                     build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''CE'', NULL, ''NRRecords'', NULL);');
                     build_sql(sqlstr, l_cntr_sql, 'END IF; ');
                    --
                    END IF;
                --
             build_sql(sqlstr, l_cntr_sql, 'END IF; ');
             --
            END IF;
        END LOOP;

        --
        -- Added for the New Context NL_WR_NOMINATIVE_REPORT_ADD
        --
        build_sql(sqlstr, l_cntr_sql, 'FOR csr_income_info_rec1 IN pay_nl_nwr_xml_extract_pkg.csr_income_info1 ('||p_action_context_id||',''NL_WR_NOMINATIVE_REPORT_ADD'','''||p_type||''',csr_employment_info_rec.action_information_id) LOOP ');
        --
        FOR cntr1 in 5..9 LOOP
            IF flex_seg_enabled ('NL_WR_NOMINATIVE_REPORT_ADD', 'ACTION_INFORMATION'||cntr1) THEN
                --
                build_sql(sqlstr, l_cntr_sql, 'IF csr_income_info_rec1.action_information' || cntr1 ||' IS NOT NULL THEN ');
                --
                IF p_report_type = 'NLNWR_XML' THEN
                     --
                     build_sql(sqlstr, l_cntr_sql,
    'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', ''NL_WR_NOMINATIVE_REPORT_ADD'', ''ACTION_INFORMATION'|| cntr1 ||''', TO_CHAR(fnd_number.canonical_to_number(csr_income_info_rec1.action_information' || cntr1 ||'),''FM999999999999999999990.00''));');
                     --
                ELSE
                    --
                    build_sql(sqlstr, l_cntr_sql, 'l_tag :=  pay_nl_nwr_xml_extract_pkg.get_tag_name(''NL_WR_NOMINATIVE_REPORT_ADD'',''ACTION_INFORMATION'|| cntr1 ||''');');
                    --
                       build_sql(sqlstr, l_cntr_sql, 'IF l_tag IS NOT NULL THEN ');
                        build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''CS'', NULL, ''NRRecords'', NULL);');
                        build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', NULL, ''Tag'', l_tag );');
                         build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', NULL, ''Description'', l_tag); ');
                        build_sql(sqlstr, l_cntr_sql,
                        'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', NULL, ''Amount'', TO_CHAR(fnd_number.canonical_to_number(csr_income_info_rec1.action_information' || cntr1 ||'),''FM999999999999999999990.00''));');
                       --
                    build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''CE'', NULL, ''NRRecords'', NULL);');
                     build_sql(sqlstr, l_cntr_sql, 'END IF; ');
                 END IF;
                --
             build_sql(sqlstr, l_cntr_sql, 'END IF; ');
             --
            END IF;
        END LOOP;
        build_sql(sqlstr, l_cntr_sql, 'END LOOP;');
        --
        --
        FOR cntr in 23..24 LOOP
            IF flex_seg_enabled ('NL_WR_NOMINATIVE_REPORT', 'ACTION_INFORMATION'||cntr) THEN
                --
                build_sql(sqlstr, l_cntr_sql, 'IF csr_income_info_rec.action_information' || cntr ||' IS NOT NULL THEN ');
                --
                IF p_report_type = 'NLNWR_XML' THEN
                     --
                     build_sql(sqlstr, l_cntr_sql,
'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', ''NL_WR_NOMINATIVE_REPORT'', ''ACTION_INFORMATION'|| cntr ||''', TO_CHAR(fnd_number.canonical_to_number(csr_income_info_rec.action_information' || cntr ||'),''FM999999999999999999990.00''));');
                     --
                ELSE
                    --
                    build_sql(sqlstr, l_cntr_sql, 'l_tag :=  pay_nl_nwr_xml_extract_pkg.get_tag_name(''NL_WR_NOMINATIVE_REPORT'',''ACTION_INFORMATION'|| cntr ||''');');
                    --
                      build_sql(sqlstr, l_cntr_sql, 'IF l_tag IS NOT NULL THEN ');
                        build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''CS'', NULL, ''NRRecords'', NULL);');
                        build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', NULL, ''Tag'', l_tag );');
                         build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', NULL, ''Description'', l_tag); ');
                        build_sql(sqlstr, l_cntr_sql,
                        'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', NULL, ''Amount'', TO_CHAR(fnd_number.canonical_to_number(csr_income_info_rec.action_information' || cntr ||'),''FM999999999999999999990.00''));');
                       --
                    build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''CE'', NULL, ''NRRecords'', NULL);');
                    build_sql(sqlstr, l_cntr_sql, 'END IF; ');
                 END IF;
                --
             build_sql(sqlstr, l_cntr_sql, 'END IF; ');
             --
            END IF;
        END LOOP;
        --
        FOR cntr in 25..26 LOOP
            IF flex_seg_enabled ('NL_WR_NOMINATIVE_REPORT', 'ACTION_INFORMATION'||cntr) THEN
                --
                IF p_report_type = 'NLNWR_XML' THEN
                    build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', ''NL_WR_NOMINATIVE_REPORT'', ''ACTION_INFORMATION'|| cntr ||''', csr_income_info_rec.action_information' || cntr ||');');
                ELSE
                     --
                    build_sql(sqlstr, l_cntr_sql, 'l_tag :=  pay_nl_nwr_xml_extract_pkg.get_tag_name(''NL_WR_NOMINATIVE_REPORT'',''ACTION_INFORMATION'|| cntr ||''');');
                    --
                      build_sql(sqlstr, l_cntr_sql, 'IF l_tag IS NOT NULL THEN ');
                        build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''CS'', NULL, ''NRRecords'', NULL);');
                        build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', NULL, ''Tag'', l_tag);');
                         build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', NULL, ''Description'', l_tag); ');
                        build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', NULL, ''Amount'', csr_income_info_rec.action_information' || cntr ||');');
                       --
                    build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''CE'', NULL, ''NRRecords'', NULL);');
                    build_sql(sqlstr, l_cntr_sql, 'END IF; ');
               END IF;
                --
            END IF;
        END LOOP;
        --
        FOR cntr in 27..30 LOOP
            IF flex_seg_enabled ('NL_WR_NOMINATIVE_REPORT', 'ACTION_INFORMATION'||cntr) THEN
                --
                build_sql(sqlstr, l_cntr_sql, 'IF csr_income_info_rec.action_information' || cntr ||' IS NOT NULL THEN ');
                --
                IF p_report_type = 'NLNWR_XML' THEN
                     --
                     build_sql(sqlstr, l_cntr_sql,
'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', ''NL_WR_NOMINATIVE_REPORT'', ''ACTION_INFORMATION'|| cntr ||''', TO_CHAR(fnd_number.canonical_to_number(csr_income_info_rec.action_information' || cntr ||'),''FM999999999999999999990.00''));');
                     --
                ELSE
                    --
                    build_sql(sqlstr, l_cntr_sql, 'l_tag :=  pay_nl_nwr_xml_extract_pkg.get_tag_name(''NL_WR_NOMINATIVE_REPORT'',''ACTION_INFORMATION'|| cntr ||''');');
                    --
                      build_sql(sqlstr, l_cntr_sql, 'IF l_tag IS NOT NULL THEN ');
                        build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''CS'', NULL, ''NRRecords'', NULL);');
                        build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', NULL, ''Tag'', l_tag );');
                         build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', NULL, ''Description'', l_tag); ');
                        build_sql(sqlstr, l_cntr_sql,
                        'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', NULL, ''Amount'', TO_CHAR(fnd_number.canonical_to_number(csr_income_info_rec.action_information' || cntr ||'),''FM999999999999999999990.00''));');
                       --
                    build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''CE'', NULL, ''NRRecords'', NULL);');
                build_sql(sqlstr, l_cntr_sql, 'END IF; ');
                   END IF;
                --
                build_sql(sqlstr, l_cntr_sql, 'END IF; ');
                --
            END IF;
        END LOOP;
        --
    -- Nominative Report </NominatieveAangifte>
    IF g_year = '2006' OR p_report_type <> 'NLNWR_XML' THEN
        build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''CE'', NULL, ''NominatieveAangifte'', NULL);');
    ELSE
        IF g_year >= '2008'
        AND  g_payroll_type <> 'YEARLY' --8552196
        THEN
          build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''CE'', NULL, ''Werknemersgegevens'', NULL);');
        ELSE
          build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''CE'', NULL, ''Werknemergegevens'', NULL);');
        END IF;
    END IF;
    --
    build_sql(sqlstr, l_cntr_sql, 'END LOOP;');
    --
    -- Nominative Report </NominatieveAangifte>
    --build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''CE'', NULL, ''NominatieveAangifte'', NULL);');
    --
    build_sql(sqlstr, l_cntr_sql, 'END ;');
    --
END generate_ip_srg_nr;
--
--------------------------------------------------------------------------------
--    Name        : GENERATE_PERSON
--    Description : This Procedure is used to generate the XML part for
--                 (Person - Address/Foreign Address).
--------------------------------------------------------------------------------
--
PROCEDURE generate_person( p_action_context_id    NUMBER
                          ,p_type                 VARCHAR2
                          ,p_report_type          VARCHAR2) AS
--
BEGIN
--
    -- Person <NatuurlijkPersoon>
    build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''CS'', NULL, ''NatuurlijkPersoon'', NULL);');
        --
             build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', ''NL_WR_EMPLOYMENT_INFO'', ''ACTION_INFORMATION8'', csr_employment_info_rec.action_information8);');
        --
        FOR cntr in 9..11 LOOP
            IF flex_seg_enabled ('NL_WR_EMPLOYMENT_INFO', 'ACTION_INFORMATION'||cntr) THEN
             build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''CD'', ''NL_WR_EMPLOYMENT_INFO'', ''ACTION_INFORMATION'|| cntr ||''', csr_employment_info_rec.action_information' || cntr ||');');
            END IF;
        END LOOP;
        --
             build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', ''NL_WR_EMPLOYMENT_INFO'', ''ACTION_INFORMATION12'', TO_CHAR(fnd_date.canonical_to_date(csr_employment_info_rec.action_information12),''YYYY-MM-DD''));');
        --
        FOR cntr in 13..14 LOOP
            IF flex_seg_enabled ('NL_WR_EMPLOYMENT_INFO', 'ACTION_INFORMATION'||cntr) THEN
             build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', ''NL_WR_EMPLOYMENT_INFO'', ''ACTION_INFORMATION'|| cntr ||''', csr_employment_info_rec.action_information' || cntr ||');');
            END IF;
        END LOOP;
        --
        IF p_report_type IN ('NLNWR_IER','NLNWR_IERC','NLNWR_WER','NLNWR_COER','NLNWR_COMPLETE') THEN
        --
        build_sql(sqlstr, l_cntr_sql, 'Declare l_gender VARCHAR2(10); Begin ');
        build_sql(sqlstr, l_cntr_sql, ' l_gender := NULL ; ');
        build_sql(sqlstr, l_cntr_sql, 'IF csr_employment_info_rec.action_information14 = 1 THEN l_gender := ''M'' ; ELSIF csr_employment_info_rec.action_information14 = 2 THEN l_gender := ''F'' ; END IF;');
             --
             build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', NULL, ''NatM'', hr_general.decode_lookup(''NL_NATIONALITY'',LPAD(csr_employment_info_rec.action_information13,4,''0'')));');
             build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', NULL, ''GeslM'', hr_general.decode_lookup(''SEX'',l_gender));');
             -- This is for PersNr (Person Number) - only for Audit Reports
             build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', ''NL_WR_EMPLOYMENT_INFO'', ''ACTION_INFORMATION5'', csr_employment_info_rec.action_information5);');
             --
        build_sql(sqlstr, l_cntr_sql, 'END ;');
        END IF;
        --
    build_sql(sqlstr, l_cntr_sql, 'FOR csr_address_info_rec IN pay_nl_nwr_xml_extract_pkg.csr_address_info
                                    ('||p_action_context_id||',''ADDRESS DETAILS'','''||p_type||''',csr_employment_info_rec.action_information_id,csr_employment_info_rec.assignment_id) LOOP ');
    --
    build_sql(sqlstr, l_cntr_sql, 'IF csr_address_info_rec.action_information14 = ''EMPLOYEE'' THEN ');
    -- Address <AdresBinnenland>
    build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''CS'', NULL, ''AdresBinnenland'', NULL);');
    --
        --
         build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''CD'', NULL, ''Str'', csr_address_info_rec.action_information9);');
         build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''CD'', NULL, ''HuisNr'', csr_address_info_rec.action_information5);');
         build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''CD'', NULL, ''HuisNrToev'', csr_address_info_rec.action_information6);');
         build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''CD'', NULL, ''LocOms'', csr_address_info_rec.action_information11);');
         build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''CD'', NULL, ''Pc'', csr_address_info_rec.action_information12);');
         build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''CD'', NULL, ''Woonpl'', SUBSTR(hr_general.decode_lookup(''HR_NL_CITY'',csr_address_info_rec.action_information8),1,24));');
        --
    -- Address </AdresBinnenland>
    build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''CE'', NULL, ''AdresBinnenland'', NULL);');
    --
    build_sql(sqlstr, l_cntr_sql, 'END IF ; ');
    --
    build_sql(sqlstr, l_cntr_sql, 'IF csr_address_info_rec.action_information14 = ''EMPLOYEE FOREIGN'' THEN ');
    -- Foreign Address <AdresBuitenland>
    build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''CS'', NULL, ''AdresBuitenland'', NULL);');
    --
         --
         build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''CD'', NULL, ''Str'', csr_address_info_rec.action_information5);');
         build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''CD'', NULL, ''HuisNr'', csr_address_info_rec.action_information6);');
         build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''CD'', NULL, ''LocOms'', csr_address_info_rec.action_information7);');
         build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''CD'', NULL, ''Pc'', csr_address_info_rec.action_information12);');
         build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''CD'', NULL, ''Woonpl'', SUBSTR(csr_address_info_rec.action_information8,1,24));');
         build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''CD'', NULL, ''Reg'', SUBSTR(hr_general.decode_lookup(''NL_REGION'',csr_address_info_rec.action_information9),1,24));');
         build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''CD'', NULL, ''LandCd'', csr_address_info_rec.action_information13);');
        --
    -- Foreign Address </AdresBuitenland>
    build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''CE'', NULL, ''AdresBuitenland'', NULL);');
    --
    build_sql(sqlstr, l_cntr_sql, 'END IF ; ');
    --
    build_sql(sqlstr, l_cntr_sql, 'END LOOP;');
    -- Person </NatuurlijkPersoon>
    build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''CE'', NULL, ''NatuurlijkPersoon'', NULL);');
--
END generate_person;
--
--------------------------------------------------------------------------------
--  Name        : GENERATE
--  Description : This procedure interprets archived information and prints it
--                out to an XML file.
--------------------------------------------------------------------------------
--
PROCEDURE generate( p_action_context_id         NUMBER
                   ,p_nwr_report_type           VARCHAR2
                   --,p_xdo_output_type           VARCHAR2
                   ,p_assignment_set_id         NUMBER
                   ,p_sort_order                VARCHAR2
                   ,p_template_name             VARCHAR2
                   ,p_xml                       OUT NOCOPY CLOB) IS
    --
    CURSOR csr_inc_exc(p_assignment_set_id NUMBER) IS
    SELECT include_or_exclude
    FROM   hr_assignment_set_amendments hasa
    WHERE  hasa.assignment_set_id = p_assignment_set_id;
    --
    CURSOR get_year(c_payroll_action_id NUMBER) IS
    SELECT TO_CHAR(effective_date,'RRRR')
    FROM   pay_payroll_actions
    WHERE  payroll_action_id = c_payroll_action_id;
    --
    l_proc_name      VARCHAR2(100);
    l_xml            CLOB;
    csr              NUMBER;
    ret              NUMBER;
    l_inc_exc        VARCHAR2(1) DEFAULT 'X'; -- 'X' as some dummy value
    l_payroll_type   VARCHAR2(40) DEFAULT NULL;
    --
BEGIN
    --
    --hr_utility.trace_on(NULL,'NL_NWR');
    hr_utility.trace('p_nwr_report_type :'||p_nwr_report_type);
    hr_utility.trace('p_action_context_id :'||p_action_context_id);
    hr_utility.trace('p_template_name :'||p_template_name);
    hr_utility.trace('p_assignment_set_id :'||p_assignment_set_id);
    hr_utility.trace('p_sort_order :'||p_sort_order);
    --
    l_cntr_sql      := 1;
    g_action_ctx_id := p_action_context_id;
    --
    IF p_assignment_set_id IS NOT NULL THEN
        OPEN csr_inc_exc(p_assignment_set_id);
        FETCH csr_inc_exc INTO l_inc_exc;
        CLOSE csr_inc_exc;
    END IF;
    --
    OPEN  get_year(p_action_context_id);
    FETCH get_year INTO g_year;
    CLOSE get_year;
    --
    build_sql(sqlstr, l_cntr_sql, 'DECLARE  BEGIN ');
    --g_xml_nwr (g_xml_nwr.count() + 1) := '<?xml version="1.0" encoding="UTF-8"?>';
    g_xml_nwr (g_xml_nwr.count() + 1) := '<?xml version="1.0" encoding="' || get_IANA_charset ||'"?>';
    -- START <Loonaangifte>
    --# 0
    l_payroll_type := TO_CHAR(pay_nl_wage_report_pkg.get_parameters(p_action_context_id,'Payroll_Type'));
    g_payroll_type := l_payroll_type; --8552196
    IF p_nwr_report_type = 'NLNWR_XML' THEN
       -- l_payroll_type := TO_CHAR(pay_nl_wage_report_pkg.get_parameters(p_action_context_id,'Payroll_Type'));

        IF l_payroll_type = 'YEARLY' and g_year >= '2008' THEN  -- Bug# 8459982
              g_xml_nwr (g_xml_nwr.count() + 1) := '<Jaarloonopgaaf xmlns="http://xml.belastingdienst.nl/schemas/Jaarloonopgaaf/'||g_year||'/01" version="1.1">'||EOL ;
        ELSIF l_payroll_type = 'YEARLY' and g_year = '2007' THEN  -- Enh# 6968464
              g_xml_nwr (g_xml_nwr.count() + 1) := '<Jaarloonopgaaf xmlns="http://xml.belastingdienst.nl/schemas/Jaarloonopgaaf/'||g_year||'/01" version="1.2">'||EOL ;
        ELSIF l_payroll_type = 'YEARLY' THEN
              g_xml_nwr (g_xml_nwr.count() + 1) := '<Jaarloonopgaaf xmlns="http://xml.belastingdienst.nl/schemas/Loonaangifte/2006/01" version="4.0">'||EOL ;
        ELSIF g_year = '2006' THEN
              g_xml_nwr (g_xml_nwr.count() + 1) := '<Loonaangifte xmlns="http://xml.belastingdienst.nl/schemas/Loonaangifte/2006/01" version="4.0">'||EOL ;
        ELSE
            g_xml_nwr (g_xml_nwr.count() + 1) := '<Loonaangifte xmlns="http://xml.belastingdienst.nl/schemas/Loonaangifte/'||g_year||'/01" version="1.0">'||EOL ;
            --g_xml_nwr (g_xml_nwr.count() + 1) := '<version>1.0</version>' ;
        END IF;
    ELSE
        g_xml_nwr (g_xml_nwr.count() + 1) := '<Loonaangifte>'||EOL;
        g_xml_nwr (g_xml_nwr.count() + 1) := '<Year>'||g_year||'</Year>'||EOL; --LC2010-- Added for RTF Templates
    END IF;
    --# 0
    --
    -- Starting the Main Loop .. All the Other Loops come under this Loop only.
    --
    g_report_type := p_nwr_report_type;
    build_sql(sqlstr, l_cntr_sql, 'FOR csr_message_info_rec IN pay_nl_nwr_xml_extract_pkg.csr_message_info ('||p_action_context_id||',''NL_WR_EMPLOYER_INFO'') LOOP ');
    --# 1
    IF p_nwr_report_type = 'NLNWR_XML' THEN
    --#
        -- MESSAGE <Bericht>
        build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''CS'', NULL, ''Bericht'', NULL);');
            --
                 build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''CD'', ''NL_WR_EMPLOYER_INFO'', ''ACTION_INFORMATION2'', csr_message_info_rec.action_information2);');
            --
                 build_sql(sqlstr, l_cntr_sql,
'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', ''NL_WR_EMPLOYER_INFO'', ''ACTION_INFORMATION3'', REPLACE(TO_CHAR(fnd_date.canonical_to_date(csr_message_info_rec.action_information3),''YYYY-MM-DD HH24:MI:SS''),'' '',''T''));');
            --
            FOR cntr in 4..6 LOOP
                IF flex_seg_enabled ('NL_WR_EMPLOYER_INFO', 'ACTION_INFORMATION'||cntr) THEN
                 build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''CD'', ''NL_WR_EMPLOYER_INFO'', ''ACTION_INFORMATION'|| cntr ||''', csr_message_info_rec.action_information' || cntr ||');');
                END IF;
            END LOOP;
            --
--LC2010--
            IF g_year < '2010' THEN
                IF flex_seg_enabled ('NL_WR_EMPLOYER_INFO', 'ACTION_INFORMATION7') THEN
                 build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''CD'', ''NL_WR_EMPLOYER_INFO'', ''ACTION_INFORMATION7'', csr_message_info_rec.action_information7);');
                END IF;
            ELSE
                FOR cntr in 13..14 LOOP
                    IF flex_seg_enabled ('NL_WR_EMPLOYER_INFO', 'ACTION_INFORMATION'||cntr) THEN
                     build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''CD'', ''NL_WR_EMPLOYER_INFO'', ''ACTION_INFORMATION'|| cntr ||''', csr_message_info_rec.action_information' || cntr ||');');
                    END IF;
                END LOOP;
            END IF;
--LC2010--

        build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''CE'', NULL, ''Bericht'', NULL);');
        -- MESSAGE </Bericht>
    --# 1
    END IF;
    --#
    -- Administrative Unit <AdministratieveEenheid>
    build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''CS'', NULL, ''AdministratieveEenheid'', NULL);');
    build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''CD'', ''NL_WR_EMPLOYER_INFO'', ''ACTION_INFORMATION8'', csr_message_info_rec.action_information8);');
    build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''CD'', ''NL_WR_EMPLOYER_INFO'', ''ACTION_INFORMATION9'', csr_message_info_rec.action_information9);');
    -- Added to accomodate the changes in the collective and complete reports
    IF p_nwr_report_type IN ('NLNWR_CR','NLNWR_COMPLETE') THEN
        -- MESSAGE <Bericht>
             build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''CD'', ''NL_WR_EMPLOYER_INFO'', ''ACTION_INFORMATION2'', csr_message_info_rec.action_information2);');
             --
             build_sql(sqlstr, l_cntr_sql,
'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', ''NL_WR_EMPLOYER_INFO'', ''ACTION_INFORMATION3'', REPLACE(TO_CHAR(fnd_date.canonical_to_date(csr_message_info_rec.action_information3),''YYYY-MM-DD HH24:MI:SS''),'' '',''T''));');
            --
            FOR cntr in 4..6 LOOP
                IF flex_seg_enabled ('NL_WR_EMPLOYER_INFO', 'ACTION_INFORMATION'||cntr) THEN
                 build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''CD'', ''NL_WR_EMPLOYER_INFO'', ''ACTION_INFORMATION'|| cntr ||''', csr_message_info_rec.action_information' || cntr ||');');
                END IF;
            END LOOP;
--LC2010--
            IF g_year < '2010' THEN
                IF flex_seg_enabled ('NL_WR_EMPLOYER_INFO', 'ACTION_INFORMATION7') THEN
                 build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''CD'', ''NL_WR_EMPLOYER_INFO'', ''ACTION_INFORMATION7'', csr_message_info_rec.action_information7);');
                END IF;
            ELSE
                FOR cntr in 13..14 LOOP
                    IF flex_seg_enabled ('NL_WR_EMPLOYER_INFO', 'ACTION_INFORMATION'||cntr) THEN
                     build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''CD'', ''NL_WR_EMPLOYER_INFO'', ''ACTION_INFORMATION'|| cntr ||''', csr_message_info_rec.action_information' || cntr ||');');
                    END IF;
                END LOOP;
            END IF;
--LC2010--
            --
        -- MESSAGE </Bericht>
    END IF;
    --
    --# 2
    IF p_nwr_report_type IN ('NLNWR_XML','NLNWR_CR','NLNWR_IER','NLNWR_COMPLETE') THEN
    --#
        IF l_payroll_type = 'YEARLY' THEN
            -- Period Report <TijdvakCorrectie>
            build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''CS'', NULL, ''TijdvakCorrectie'', NULL);');
        ELSE
            -- Period Report <TijdvakAangifte>
            build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''CS'', NULL, ''TijdvakAangifte'', NULL);');
        END IF;
        --
        build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', ''NL_WR_EMPLOYER_INFO'', ''ACTION_INFORMATION10'', TO_CHAR(fnd_date.canonical_to_date(csr_message_info_rec.action_information10),''YYYY-MM-DD''));');
        build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', ''NL_WR_EMPLOYER_INFO'', ''ACTION_INFORMATION11'', TO_CHAR(fnd_date.canonical_to_date(csr_message_info_rec.action_information11),''YYYY-MM-DD''));');
        --
        IF l_payroll_type <> 'YEARLY' THEN
            -- Complete Report <VolledigeAangifte>
            build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''CS'', NULL, ''VolledigeAangifte'', NULL);');
        END IF;
        --# 2.1
        IF p_nwr_report_type IN ('NLNWR_XML','NLNWR_CR','NLNWR_COMPLETE') THEN
        --#
            -- Collective Report <CollectieveAangifte>
            build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''CS'', NULL, ''CollectieveAangifte'', NULL);');
            --
            generate_collective_report( p_act_context_id       => p_action_context_id
                                       ,p_type                 => 'COMPLETE'
                                       ,p_start_date           => 'csr_message_info_rec.action_information10'
                                       ,p_end_date             => 'csr_message_info_rec.action_information11'
                                       ,p_in_not_in            => 'NOT IN'
                                       ,p_report_type          => p_nwr_report_type);
            --
            build_sql(sqlstr, l_cntr_sql,
'FOR csr_swmf_info_rec IN pay_nl_nwr_xml_extract_pkg.csr_swmf_info ('||p_action_context_id||',''NL_WR_SWMF_SECTOR_RISK_GROUP'',''SWMF'',csr_message_info_rec.action_information10,csr_message_info_rec.action_information11) LOOP ');
            -- Specification waiting money fund contribution <Wgf>
            build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''CS'', NULL, ''Wgf'', NULL);');
                --
               --LC2010--begin - From 2010, Sect Tag Deleted. Only RisGrp
                IF g_year < '2010' THEN
                  FOR cntr in 7..8 LOOP
                      IF flex_seg_enabled ('NL_WR_SWMF_SECTOR_RISK_GROUP', 'ACTION_INFORMATION'||cntr) THEN
                       build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', ''NL_WR_SWMF_SECTOR_RISK_GROUP'', ''ACTION_INFORMATION'|| cntr ||''', csr_swmf_info_rec.action_information' || cntr ||');');
                      END IF;
                  END LOOP;
                ELSE
                  IF flex_seg_enabled ('NL_WR_SWMF_SECTOR_RISK_GROUP', 'ACTION_INFORMATION8') THEN
                    build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', ''NL_WR_SWMF_SECTOR_RISK_GROUP'', ''ACTION_INFORMATION8'', csr_swmf_info_rec.action_information8);');
                   END IF;
                END IF;
               --LC2010--End
--
                build_sql(sqlstr, l_cntr_sql,
                'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', ''NL_WR_SWMF_SECTOR_RISK_GROUP'', ''ACTION_INFORMATION9'', to_char(fnd_number.canonical_to_number(csr_swmf_info_rec.action_information9)));');
                build_sql(sqlstr, l_cntr_sql,
                'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', ''NL_WR_SWMF_SECTOR_RISK_GROUP'', ''ACTION_INFORMATION10'', to_char(fnd_number.canonical_to_number(csr_swmf_info_rec.action_information10)));');
            --
            -- Specification waiting money fund contribution </Wgf>
            build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''CE'', NULL, ''Wgf'', NULL);');
            --
            build_sql(sqlstr, l_cntr_sql, 'END LOOP;');
            --
            generate_collective_report( p_act_context_id       => p_action_context_id
                                       ,p_type                 => 'COMPLETE'
                                       ,p_start_date           => 'csr_message_info_rec.action_information10'
                                       ,p_end_date             => 'csr_message_info_rec.action_information11'
                                       ,p_in_not_in            => 'IN'
                                       ,p_report_type          => p_nwr_report_type);
            --
            build_sql(sqlstr, l_cntr_sql, 'FOR csr_corr_balance_info_rec IN pay_nl_nwr_xml_extract_pkg.csr_corr_balance_info ('||p_action_context_id||',''NL_WR_COLLECTIVE_REPORT'',''CORR_BALANCE'') LOOP ');
            --
            -- Correction balances prev. period <SaldoCorrectiesVoorgaandTijdvak>
            build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''CS'', NULL, ''SaldoCorrectiesVoorgaandTijdvak'', NULL);');
            build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', NULL, ''DatAanvTv'', TO_CHAR(fnd_date.canonical_to_date(csr_corr_balance_info_rec.action_information3),''YYYY-MM-DD''));');
            build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', NULL, ''DatEindTv'', TO_CHAR(fnd_date.canonical_to_date(csr_corr_balance_info_rec.action_information4),''YYYY-MM-DD''));');
            build_sql(sqlstr, l_cntr_sql,
            'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', NULL, csr_corr_balance_info_rec.action_information2, to_char(fnd_number.canonical_to_number(csr_corr_balance_info_rec.action_information6)));');
            --
            -- Correction balances prev. period </SaldoCorrectiesVoorgaandTijdvak>
            build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''CE'', NULL, ''SaldoCorrectiesVoorgaandTijdvak'', NULL);');
            build_sql(sqlstr, l_cntr_sql, 'END LOOP;');
            --
            -- General Total
            build_sql(sqlstr, l_cntr_sql,
'FOR csr_collective_info_rec IN pay_nl_nwr_xml_extract_pkg.csr_collective_info ('||p_action_context_id||',''NL_WR_COLLECTIVE_REPORT'',''TOTAL'',csr_message_info_rec.action_information10,csr_message_info_rec.action_information11) LOOP ');
            --
            build_sql(sqlstr, l_cntr_sql,
            'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', NULL, csr_collective_info_rec.action_information2, to_char(fnd_number.canonical_to_number(csr_collective_info_rec.action_information6)));');
            --
            build_sql(sqlstr, l_cntr_sql, 'END LOOP;');
            --
            -- Collective Report </CollectieveAangifte>
            build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''CE'', NULL, ''CollectieveAangifte'', NULL);');
            --
        --# 2.1
        END IF;
        --#
        --# 2.2
        IF p_nwr_report_type IN ('NLNWR_XML','NLNWR_IER','NLNWR_COMPLETE') THEN
        --#
            build_sql(sqlstr, l_cntr_sql,
'FOR csr_employment_info_rec IN pay_nl_nwr_xml_extract_pkg.csr_employment_info ('||
p_action_context_id||',''NL_WR_EMPLOYMENT_INFO'',''INITIAL'',csr_message_info_rec.action_information10,csr_message_info_rec.action_information11,'''|| p_sort_order ||''') LOOP ');
            --
            IF p_nwr_report_type <> 'NLNWR_XML' AND p_assignment_set_id IS NOT NULL AND l_inc_exc = 'I' THEN
            --
                build_sql(sqlstr, l_cntr_sql, 'FOR csr_assignment_filter_rec IN pay_nl_nwr_xml_extract_pkg.csr_assignment_filter ('||p_assignment_set_id||',csr_employment_info_rec.assignment_id) LOOP ');
                build_sql(sqlstr, l_cntr_sql, 'IF csr_assignment_filter_rec.INCLUDE_OR_EXCLUDE = ''I'' THEN ');
            END IF;
            --
            IF p_nwr_report_type <> 'NLNWR_XML' AND p_assignment_set_id IS NOT NULL AND l_inc_exc = 'E' THEN
            --
                build_sql(sqlstr, l_cntr_sql, 'DECLARE l_flag VARCHAR2(1) := ''Y'';  BEGIN ');
                build_sql(sqlstr, l_cntr_sql, 'FOR csr_assignment_filter_rec IN pay_nl_nwr_xml_extract_pkg.csr_assignment_filter ('||p_assignment_set_id||',csr_employment_info_rec.assignment_id) LOOP ');
                build_sql(sqlstr, l_cntr_sql, 'IF csr_assignment_filter_rec.INCLUDE_OR_EXCLUDE = ''E'' THEN  l_flag := ''N''; END IF; END LOOP; ');
                build_sql(sqlstr, l_cntr_sql, 'IF l_flag = ''Y'' THEN ');
            END IF;
            --
            -- Initial Employment Relation <InkomstenverhoudingInitieel>
            build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''CS'', NULL, ''InkomstenverhoudingInitieel'', NULL);');
                --
                IF p_nwr_report_type <> 'NLNWR_XML' THEN
                    --
                    build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', ''NL_WR_EMPLOYER_INFO'', ''ACTION_INFORMATION8'', csr_message_info_rec.action_information8);');
                    build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''CD'', ''NL_WR_EMPLOYER_INFO'', ''ACTION_INFORMATION9'', csr_message_info_rec.action_information9);');
                    build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', ''NL_WR_EMPLOYER_INFO'', ''ACTION_INFORMATION10'', TO_CHAR(fnd_date.canonical_to_date(csr_message_info_rec.action_information10),''YYYY-MM-DD''));');
                    build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', ''NL_WR_EMPLOYER_INFO'', ''ACTION_INFORMATION11'', TO_CHAR(fnd_date.canonical_to_date(csr_message_info_rec.action_information11),''YYYY-MM-DD''));');
                    --
                END IF;
                --
                     build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', ''NL_WR_EMPLOYMENT_INFO'', ''ACTION_INFORMATION18'', csr_employment_info_rec.action_information18);');
                     build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', ''NL_WR_EMPLOYMENT_INFO'', ''ACTION_INFORMATION4'', csr_employment_info_rec.action_information4);');
                     build_sql(sqlstr, l_cntr_sql,
                     'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', ''NL_WR_EMPLOYMENT_INFO'', ''ACTION_INFORMATION15'', TO_CHAR(fnd_date.canonical_to_date(csr_employment_info_rec.action_information15),''YYYY-MM-DD''));');
                     build_sql(sqlstr, l_cntr_sql,
                     'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', ''NL_WR_EMPLOYMENT_INFO'', ''ACTION_INFORMATION16'', TO_CHAR(fnd_date.canonical_to_date(csr_employment_info_rec.action_information16),''YYYY-MM-DD''));');
                --
                FOR cntr in REVERSE 5..6 LOOP
                    IF flex_seg_enabled ('NL_WR_EMPLOYMENT_INFO', 'ACTION_INFORMATION'||cntr) THEN
                     build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', ''NL_WR_EMPLOYMENT_INFO'', ''ACTION_INFORMATION'|| cntr ||''', csr_employment_info_rec.action_information' || cntr ||');');
                    END IF;
                END LOOP;
                --
            --
            generate_person(p_action_context_id,'INITIAL',p_nwr_report_type);
            --
            generate_ip_srg_nr(p_action_context_id,'INITIAL',p_nwr_report_type);
            --
            -- Initial Employment Relation </InkomstenverhoudingInitieel>
            build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''CE'', NULL, ''InkomstenverhoudingInitieel'', NULL);');
            --
            IF p_nwr_report_type <> 'NLNWR_XML' AND p_assignment_set_id IS NOT NULL AND l_inc_exc = 'I' THEN
                build_sql(sqlstr, l_cntr_sql, 'END IF; END LOOP; ');
            END IF;
            --
            IF p_nwr_report_type <> 'NLNWR_XML' AND p_assignment_set_id IS NOT NULL AND l_inc_exc = 'E' THEN
                build_sql(sqlstr, l_cntr_sql, ' END IF; END; ');
            END IF;
            --
            build_sql(sqlstr, l_cntr_sql, 'END LOOP;');
            --
        --# 2.2
        END IF;
        --#
        IF l_payroll_type <> 'YEARLY' THEN
            -- Complete Report </VolledigeAangifte>
            build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''CE'', NULL, ''VolledigeAangifte'', NULL);');
        END IF;
        IF l_payroll_type = 'YEARLY' THEN
            -- Period Report <TijdvakCorrectie>
            build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''CE'', NULL, ''TijdvakCorrectie'', NULL);');
        ELSE
            -- Period Report <TijdvakAangifte>
            build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''CE'', NULL, ''TijdvakAangifte'', NULL);');
        END IF;
        --
    --# 2
    END IF;
    --#
    --# 3
    IF p_nwr_report_type IN ('NLNWR_XML','NLNWR_CRC','NLNWR_IERC','NLNWR_WER','NLNWR_COER','NLNWR_COMPLETE') THEN
    --#
        build_sql(sqlstr, l_cntr_sql, 'FOR csr_correction_info_rec IN pay_nl_nwr_xml_extract_pkg.csr_correction_info ('||p_action_context_id||',''NL_WR_EMPLOYMENT_INFO'',''INITIAL'') LOOP ');
        --
        -- Correction Report <TijdvakCorrectie>
        build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''CS'', NULL, ''TijdvakCorrectie'', NULL);');
        --
        build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', NULL, ''DatAanvTv'', TO_CHAR(fnd_date.canonical_to_date(csr_correction_info_rec.start_date),''YYYY-MM-DD''));');
        build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', NULL, ''DatEindTv'', TO_CHAR(fnd_date.canonical_to_date(csr_correction_info_rec.end_date),''YYYY-MM-DD''));');
        --
        IF p_nwr_report_type IN ('NLNWR_CRC') THEN
            build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', ''NL_WR_EMPLOYER_INFO'', ''ACTION_INFORMATION8'', csr_message_info_rec.action_information8);');
            build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''CD'', ''NL_WR_EMPLOYER_INFO'', ''ACTION_INFORMATION9'', csr_message_info_rec.action_information9);');
        END IF;
        --
        --# 3.1
        IF p_nwr_report_type IN ('NLNWR_XML','NLNWR_CRC','NLNWR_COMPLETE') THEN
        --#
            -- Collective Report <CollectieveAangifte>
            build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''CS'', NULL, ''CollectieveAangifte'', NULL);');
            --
            generate_collective_report( p_act_context_id       => p_action_context_id
                                       ,p_type                 => 'CORRECTION'
                                       ,p_start_date           => 'csr_correction_info_rec.start_date'
                                       ,p_end_date             => 'csr_correction_info_rec.end_date'
                                       ,p_in_not_in            => 'NOT IN'
                                       ,p_report_type          => p_nwr_report_type);
            --
            build_sql(sqlstr, l_cntr_sql,
'FOR csr_swmf_info_rec IN pay_nl_nwr_xml_extract_pkg.csr_swmf_info ('||p_action_context_id||',''NL_WR_SWMF_SECTOR_RISK_GROUP'',''SWMF'',csr_correction_info_rec.start_date,csr_correction_info_rec.end_date) LOOP ');
            -- Specification waiting money fund contribution <Wgf>
            build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''CS'', NULL, ''Wgf'', NULL);');
                --
                FOR cntr in 7..8 LOOP
                    IF flex_seg_enabled ('NL_WR_SWMF_SECTOR_RISK_GROUP', 'ACTION_INFORMATION'||cntr) THEN
                     build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', ''NL_WR_SWMF_SECTOR_RISK_GROUP'', ''ACTION_INFORMATION'|| cntr ||''', csr_swmf_info_rec.action_information' || cntr ||');');
                    END IF;
                END LOOP;
                build_sql(sqlstr, l_cntr_sql,
                'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', ''NL_WR_SWMF_SECTOR_RISK_GROUP'', ''ACTION_INFORMATION9'', to_char(fnd_number.canonical_to_number(csr_swmf_info_rec.action_information9)));');
                build_sql(sqlstr, l_cntr_sql,
                'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', ''NL_WR_SWMF_SECTOR_RISK_GROUP'', ''ACTION_INFORMATION10'', to_char(fnd_number.canonical_to_number(csr_swmf_info_rec.action_information10)));');
                --
            -- Specification waiting money fund contribution </Wgf>
            build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''CE'', NULL, ''Wgf'', NULL);');
            --
            build_sql(sqlstr, l_cntr_sql, 'END LOOP;');
            --
            --
            generate_collective_report( p_act_context_id       => p_action_context_id
                                       ,p_type                 => 'CORRECTION'
                                       ,p_start_date           => 'csr_correction_info_rec.start_date'
                                       ,p_end_date             => 'csr_correction_info_rec.end_date'
                                       ,p_in_not_in            => 'IN'
                                       ,p_report_type          => p_nwr_report_type);
            --
            -- Collective Report </CollectieveAangifte>
            build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''CE'', NULL, ''CollectieveAangifte'', NULL);');
            --
        --# 3.1
        END IF;
        --#
        --# 3.2
        IF p_nwr_report_type IN ('NLNWR_XML','NLNWR_IERC','NLNWR_COMPLETE') THEN
        --#
            --
            build_sql(sqlstr, l_cntr_sql,
'FOR csr_employment_info_rec IN pay_nl_nwr_xml_extract_pkg.csr_employment_info ('||
p_action_context_id||',''NL_WR_EMPLOYMENT_INFO'',''CORRECTION'',csr_correction_info_rec.start_date,csr_correction_info_rec.end_date,'''|| p_sort_order ||''') LOOP ');
            --
            IF p_nwr_report_type <> 'NLNWR_XML' AND p_assignment_set_id IS NOT NULL AND l_inc_exc = 'I' THEN
            --
                build_sql(sqlstr, l_cntr_sql, 'FOR csr_assignment_filter_rec IN pay_nl_nwr_xml_extract_pkg.csr_assignment_filter ('||p_assignment_set_id||',csr_employment_info_rec.assignment_id) LOOP ');
                build_sql(sqlstr, l_cntr_sql, 'IF csr_assignment_filter_rec.INCLUDE_OR_EXCLUDE = ''I'' THEN ');
            END IF;
            --
            IF p_nwr_report_type <> 'NLNWR_XML' AND p_assignment_set_id IS NOT NULL AND l_inc_exc = 'E' THEN
            --
                build_sql(sqlstr, l_cntr_sql, 'DECLARE l_flag VARCHAR2(1) := ''Y'';  BEGIN ');
                build_sql(sqlstr, l_cntr_sql, 'FOR csr_assignment_filter_rec IN pay_nl_nwr_xml_extract_pkg.csr_assignment_filter ('||p_assignment_set_id||',csr_employment_info_rec.assignment_id) LOOP ');
                build_sql(sqlstr, l_cntr_sql, 'IF csr_assignment_filter_rec.INCLUDE_OR_EXCLUDE = ''E'' THEN  l_flag := ''N''; END IF; END LOOP; ');
                build_sql(sqlstr, l_cntr_sql, 'IF l_flag = ''Y'' THEN ');
            END IF;
            --
            -- Initial Employment Relation <InkomstenverhoudingInitieel>
            build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''CS'', NULL, ''InkomstenverhoudingInitieel'', NULL);');
                --
                IF p_nwr_report_type <> 'NLNWR_XML' THEN
                    --
                    build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', ''NL_WR_EMPLOYER_INFO'', ''ACTION_INFORMATION8'', csr_message_info_rec.action_information8);');
                    build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''CD'', ''NL_WR_EMPLOYER_INFO'', ''ACTION_INFORMATION9'', csr_message_info_rec.action_information9);');
                    --
                    build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', NULL, ''DatAanvTv'', TO_CHAR(fnd_date.canonical_to_date(csr_correction_info_rec.start_date),''YYYY-MM-DD''));');
                    build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', NULL, ''DatEindTv'', TO_CHAR(fnd_date.canonical_to_date(csr_correction_info_rec.end_date),''YYYY-MM-DD''));');
                    --
                END IF;
                --
                     build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', ''NL_WR_EMPLOYMENT_INFO'', ''ACTION_INFORMATION18'', csr_employment_info_rec.action_information18);');
                     build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', ''NL_WR_EMPLOYMENT_INFO'', ''ACTION_INFORMATION4'', csr_employment_info_rec.action_information4);');
                     build_sql(sqlstr, l_cntr_sql,
                     'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', ''NL_WR_EMPLOYMENT_INFO'', ''ACTION_INFORMATION15'', TO_CHAR(fnd_date.canonical_to_date(csr_employment_info_rec.action_information15),''YYYY-MM-DD''));');
                     build_sql(sqlstr, l_cntr_sql,
                     'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', ''NL_WR_EMPLOYMENT_INFO'', ''ACTION_INFORMATION16'', TO_CHAR(fnd_date.canonical_to_date(csr_employment_info_rec.action_information16),''YYYY-MM-DD''));');
                --
                FOR cntr in REVERSE 5..6 LOOP
                    IF flex_seg_enabled ('NL_WR_EMPLOYMENT_INFO', 'ACTION_INFORMATION'||cntr) THEN
                     build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', ''NL_WR_EMPLOYMENT_INFO'', ''ACTION_INFORMATION'|| cntr ||''', csr_employment_info_rec.action_information' || cntr ||');');
                    END IF;
                END LOOP;
                --
            --
            generate_person(p_action_context_id,'CORRECTION',p_nwr_report_type);
            --
            generate_ip_srg_nr(p_action_context_id,'CORRECTION',p_nwr_report_type);
            --
            -- Initial Employment Relation </InkomstenverhoudingInitieel>
            build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''CE'', NULL, ''InkomstenverhoudingInitieel'', NULL);');
            --
            IF p_nwr_report_type <> 'NLNWR_XML' AND p_assignment_set_id IS NOT NULL AND l_inc_exc = 'I' THEN
                build_sql(sqlstr, l_cntr_sql, 'END IF; END LOOP; ');
            END IF;
            --
            IF p_nwr_report_type <> 'NLNWR_XML' AND p_assignment_set_id IS NOT NULL AND l_inc_exc = 'E' THEN
                build_sql(sqlstr, l_cntr_sql, ' END IF; END; ');
            END IF;
            --
            build_sql(sqlstr, l_cntr_sql, 'END LOOP;');
            --
        --# 3.2
        END IF;
        --#
        --# 3.3
        IF p_nwr_report_type IN ('NLNWR_XML','NLNWR_WER','NLNWR_COMPLETE') THEN
        --#
            --
            build_sql(sqlstr, l_cntr_sql,
'FOR csr_employment_info_rec IN pay_nl_nwr_xml_extract_pkg.csr_employment_info ('||
p_action_context_id||',''NL_WR_EMPLOYMENT_INFO'',''WITHDRAWAL'',csr_correction_info_rec.start_date,csr_correction_info_rec.end_date,'''|| p_sort_order ||''') LOOP ');
            --
            IF p_nwr_report_type <> 'NLNWR_XML' AND p_assignment_set_id IS NOT NULL AND l_inc_exc = 'I' THEN
            --
                build_sql(sqlstr, l_cntr_sql, 'FOR csr_assignment_filter_rec IN pay_nl_nwr_xml_extract_pkg.csr_assignment_filter ('||p_assignment_set_id||',csr_employment_info_rec.assignment_id) LOOP ');
                build_sql(sqlstr, l_cntr_sql, 'IF csr_assignment_filter_rec.INCLUDE_OR_EXCLUDE = ''I'' THEN ');
            END IF;
            --
            IF p_nwr_report_type <> 'NLNWR_XML' AND p_assignment_set_id IS NOT NULL AND l_inc_exc = 'E' THEN
            --
                build_sql(sqlstr, l_cntr_sql, 'DECLARE l_flag VARCHAR2(1) := ''Y'';  BEGIN ');
                build_sql(sqlstr, l_cntr_sql, 'FOR csr_assignment_filter_rec IN pay_nl_nwr_xml_extract_pkg.csr_assignment_filter ('||p_assignment_set_id||',csr_employment_info_rec.assignment_id) LOOP ');
                build_sql(sqlstr, l_cntr_sql, 'IF csr_assignment_filter_rec.INCLUDE_OR_EXCLUDE = ''E'' THEN  l_flag := ''N''; END IF; END LOOP; ');
                build_sql(sqlstr, l_cntr_sql, 'IF l_flag = ''Y'' THEN ');
            END IF;
            --
            -- Withdrawal Employment Relation <InkomstenverhoudingIntrekking>
            build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''CS'', NULL, ''InkomstenverhoudingIntrekking'', NULL);');
                --
                IF p_nwr_report_type <> 'NLNWR_XML' THEN
                    --
                    build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', ''NL_WR_EMPLOYER_INFO'', ''ACTION_INFORMATION8'', csr_message_info_rec.action_information8);');
                    build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''CD'', ''NL_WR_EMPLOYER_INFO'', ''ACTION_INFORMATION9'', csr_message_info_rec.action_information9);');
                    --
                    build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', NULL, ''DatAanvTv'', TO_CHAR(fnd_date.canonical_to_date(csr_correction_info_rec.start_date),''YYYY-MM-DD''));');
                    build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', NULL, ''DatEindTv'', TO_CHAR(fnd_date.canonical_to_date(csr_correction_info_rec.end_date),''YYYY-MM-DD''));');
                    --
                    build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', ''NL_WR_EMPLOYMENT_INFO'', ''ACTION_INFORMATION18'', csr_employment_info_rec.action_information18);');
                    build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', ''NL_WR_EMPLOYMENT_INFO'', ''ACTION_INFORMATION4'', csr_employment_info_rec.action_information4);');
                    build_sql(sqlstr, l_cntr_sql,
                    'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', ''NL_WR_EMPLOYMENT_INFO'', ''ACTION_INFORMATION15'', TO_CHAR(fnd_date.canonical_to_date(csr_employment_info_rec.action_information15),''YYYY-MM-DD''));');
                    build_sql(sqlstr, l_cntr_sql,
                    'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', ''NL_WR_EMPLOYMENT_INFO'', ''ACTION_INFORMATION16'', TO_CHAR(fnd_date.canonical_to_date(csr_employment_info_rec.action_information16),''YYYY-MM-DD''));');
                    --
                    FOR cntr in 5..6 LOOP
                        IF flex_seg_enabled ('NL_WR_EMPLOYMENT_INFO', 'ACTION_INFORMATION'||cntr) THEN
                         build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', ''NL_WR_EMPLOYMENT_INFO'', ''ACTION_INFORMATION'|| cntr ||''', csr_employment_info_rec.action_information' || cntr ||');');
                        END IF;
                    END LOOP;
                    --
                    generate_person(p_action_context_id,'WITHDRAWAL',p_nwr_report_type);
                    --
                END IF;
                --
                IF p_nwr_report_type = 'NLNWR_XML' THEN
                    --
                    IF g_year = '2006' THEN
                        build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', ''NL_WR_EMPLOYMENT_INFO'', ''ACTION_INFORMATION4'', csr_employment_info_rec.action_information4);');
                        build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', ''NL_WR_EMPLOYMENT_INFO'', ''ACTION_INFORMATION5'', csr_employment_info_rec.action_information5);');
                        build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', ''NL_WR_EMPLOYMENT_INFO'', ''ACTION_INFORMATION8'', csr_employment_info_rec.action_information8);');
                    ELSE
                        build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', ''NL_WR_EMPLOYMENT_INFO'', ''ACTION_INFORMATION18'', csr_employment_info_rec.action_information18);');
                        build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', ''NL_WR_EMPLOYMENT_INFO'', ''ACTION_INFORMATION4'', csr_employment_info_rec.action_information4);');
                        build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', ''NL_WR_EMPLOYMENT_INFO'', ''ACTION_INFORMATION8'', csr_employment_info_rec.action_information8);');
                        build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', ''NL_WR_EMPLOYMENT_INFO'', ''ACTION_INFORMATION5'', csr_employment_info_rec.action_information5);');
                    END IF;
                    --
                END IF;
            --
            -- Withdrawal Employment Relation </InkomstenverhoudingIntrekking>
            build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''CE'', NULL, ''InkomstenverhoudingIntrekking'', NULL);');
            --
            IF p_nwr_report_type <> 'NLNWR_XML' AND p_assignment_set_id IS NOT NULL AND l_inc_exc = 'I' THEN
                build_sql(sqlstr, l_cntr_sql, 'END IF; END LOOP; ');
            END IF;
            --
            IF p_nwr_report_type <> 'NLNWR_XML' AND p_assignment_set_id IS NOT NULL AND l_inc_exc = 'E' THEN
                build_sql(sqlstr, l_cntr_sql, ' END IF; END; ');
            END IF;
            --
            build_sql(sqlstr, l_cntr_sql, 'END LOOP;');
            --
        --# 3.3
        END IF;
        --#
        --# 3.4
        IF p_nwr_report_type IN ('NLNWR_XML','NLNWR_COER','NLNWR_COMPLETE') THEN
        --#
            build_sql(sqlstr, l_cntr_sql,
'FOR csr_employment_info_rec IN pay_nl_nwr_xml_extract_pkg.csr_employment_info ('||
p_action_context_id||',''NL_WR_EMPLOYMENT_INFO'',''CORRECT'',csr_correction_info_rec.start_date,csr_correction_info_rec.end_date,'''|| p_sort_order ||''') LOOP ');
            --
            IF p_nwr_report_type <> 'NLNWR_XML' AND p_assignment_set_id IS NOT NULL AND l_inc_exc = 'I' THEN
            --
                build_sql(sqlstr, l_cntr_sql, 'FOR csr_assignment_filter_rec IN pay_nl_nwr_xml_extract_pkg.csr_assignment_filter ('||p_assignment_set_id||',csr_employment_info_rec.assignment_id) LOOP ');
                build_sql(sqlstr, l_cntr_sql, 'IF csr_assignment_filter_rec.INCLUDE_OR_EXCLUDE = ''I'' THEN ');
            END IF;
            --
            IF p_nwr_report_type <> 'NLNWR_XML' AND p_assignment_set_id IS NOT NULL AND l_inc_exc = 'E' THEN
            --
                build_sql(sqlstr, l_cntr_sql, 'DECLARE l_flag VARCHAR2(1) := ''Y'';  BEGIN ');
                build_sql(sqlstr, l_cntr_sql, 'FOR csr_assignment_filter_rec IN pay_nl_nwr_xml_extract_pkg.csr_assignment_filter ('||p_assignment_set_id||',csr_employment_info_rec.assignment_id) LOOP ');
                build_sql(sqlstr, l_cntr_sql, 'IF csr_assignment_filter_rec.INCLUDE_OR_EXCLUDE = ''E'' THEN  l_flag := ''N''; END IF; END LOOP; ');
                build_sql(sqlstr, l_cntr_sql, 'IF l_flag = ''Y'' THEN ');
            END IF;
            --
            -- Correction Employment relation <InkomstenverhoudingCorrectie>
            build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''CS'', NULL, ''InkomstenverhoudingCorrectie'', NULL);');
                --
                IF p_nwr_report_type <> 'NLNWR_XML' THEN
                    --
                    build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', ''NL_WR_EMPLOYER_INFO'', ''ACTION_INFORMATION8'', csr_message_info_rec.action_information8);');
                    build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''CD'', ''NL_WR_EMPLOYER_INFO'', ''ACTION_INFORMATION9'', csr_message_info_rec.action_information9);');
                    --
                    build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', NULL, ''DatAanvTv'', TO_CHAR(fnd_date.canonical_to_date(csr_correction_info_rec.start_date),''YYYY-MM-DD''));');
                    build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', NULL, ''DatEindTv'', TO_CHAR(fnd_date.canonical_to_date(csr_correction_info_rec.end_date),''YYYY-MM-DD''));');
                    --
                END IF;
                --
                     build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', ''NL_WR_EMPLOYMENT_INFO'', ''ACTION_INFORMATION4'', csr_employment_info_rec.action_information4);');
                     build_sql(sqlstr, l_cntr_sql,
                     'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', ''NL_WR_EMPLOYMENT_INFO'', ''ACTION_INFORMATION15'', TO_CHAR(fnd_date.canonical_to_date(csr_employment_info_rec.action_information15),''YYYY-MM-DD''));');
                     build_sql(sqlstr, l_cntr_sql,
                     'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', ''NL_WR_EMPLOYMENT_INFO'', ''ACTION_INFORMATION16'', TO_CHAR(fnd_date.canonical_to_date(csr_employment_info_rec.action_information16),''YYYY-MM-DD''));');
                     build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', ''NL_WR_EMPLOYMENT_INFO'', ''ACTION_INFORMATION6'', csr_employment_info_rec.action_information6);');
                     build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', ''NL_WR_EMPLOYMENT_INFO'', ''ACTION_INFORMATION5'', csr_employment_info_rec.action_information5);');
                     build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''D'', ''NL_WR_EMPLOYMENT_INFO'', ''ACTION_INFORMATION8'', csr_employment_info_rec.action_information8);');
            --
            IF p_nwr_report_type <> 'NLNWR_XML' THEN
                generate_person(p_action_context_id,'CORRECT',p_nwr_report_type);
            END IF;
            --
            generate_ip_srg_nr(p_action_context_id,'CORRECT',p_nwr_report_type);
            --
            -- Correction Employment relation </InkomstenverhoudingCorrectie>
            build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''CE'', NULL, ''InkomstenverhoudingCorrectie'', NULL);');
            --
            IF p_nwr_report_type <> 'NLNWR_XML' AND p_assignment_set_id IS NOT NULL AND l_inc_exc = 'I' THEN
                build_sql(sqlstr, l_cntr_sql, 'END IF; END LOOP; ');
            END IF;
            --
            IF p_nwr_report_type <> 'NLNWR_XML' AND p_assignment_set_id IS NOT NULL AND l_inc_exc = 'E' THEN
                build_sql(sqlstr, l_cntr_sql, ' END IF; END; ');
            END IF;
            --
            build_sql(sqlstr, l_cntr_sql, 'END LOOP;');
            --
        --# 3.4
        END IF;
        --#
        -- Correction Report </TijdvakCorrectie>
        build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''CE'', NULL, ''TijdvakCorrectie'', NULL);');
        --
        build_sql(sqlstr, l_cntr_sql, 'END LOOP;');
        --
    --# 3
    END IF;
    --#
    -- Administrative Unit </AdministratieveEenheid>
    build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''CE'', NULL, ''AdministratieveEenheid'', NULL);');
    --
    -- End of the Main Loop
    --
    build_sql(sqlstr, l_cntr_sql, 'END LOOP;');
    -- END </Loonaangifte>
    IF l_payroll_type = 'YEARLY' AND p_nwr_report_type = 'NLNWR_XML' THEN
      build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''CE'', NULL, ''Jaarloonopgaaf'', NULL);');
    ELSE
      build_sql(sqlstr, l_cntr_sql, 'pay_nl_nwr_xml_extract_pkg.load_xml(''CE'', NULL, ''Loonaangifte'', NULL);');
    END IF;
    build_sql(sqlstr, l_cntr_sql, 'END;');
    --
    csr := dbms_sql.open_cursor;
    dbms_sql.parse (csr,
                    sqlstr,
                    sqlstr.first(),
                    sqlstr.last(),
                    false,
                    dbms_sql.v7);
    ret := dbms_sql.execute(csr);
    dbms_sql.close_cursor(csr);
    --
    WritetoCLOB(p_xfdf_string => l_xml);
    --
    p_xml := l_xml;
    --
    dbms_lob.freeTemporary(l_xml);
    --
    g_xml_nwr.delete();
    --
END generate;
--
END pay_nl_nwr_xml_extract_pkg;

/

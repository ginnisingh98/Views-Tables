--------------------------------------------------------
--  DDL for Package Body GL_AS_POST_UPG_CHK_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_AS_POST_UPG_CHK_PKG" AS
/* $Header: gluasucb.pls 120.3 2006/07/28 21:56:44 mgowda noship $ */

-- -------------------------
-- Private Package Variables
-- -------------------------
  pc_log_level_statement  CONSTANT NUMBER := FND_LOG.level_statement;
  pc_log_level_procedure  CONSTANT NUMBER := FND_LOG.level_procedure;
  pc_log_level_event      CONSTANT NUMBER := FND_LOG.level_event;
  pc_log_level_exception  CONSTANT NUMBER := FND_LOG.level_exception;
  pc_log_level_error      CONSTANT NUMBER := FND_LOG.level_error;
  pc_log_level_unexpected CONSTANT NUMBER := FND_LOG.level_unexpected;

  pv_nl VARCHAR2(1);

  PRINT_ERROR EXCEPTION;

-- -------------------------------
-- Private Procedures Declarations
-- -------------------------------
PROCEDURE Print_Table_Header(  p_info_msg_name  IN VARCHAR2
							 , p_column_text    IN VARCHAR2);

-- -----------------
-- Public Procedures
-- -----------------

-- PROCEDURE
--   Verify_Setup()
--
-- DESCRIPTION:
--   This is the main function of this ASM Post-upgrade Check package.
PROCEDURE Verify_Setup(  x_errbuf  IN OUT NOCOPY VARCHAR2
                       , x_retcode IN OUT NOCOPY VARCHAR2) IS
   v_status_code   VARCHAR2(30);
   v_return_status BOOLEAN;
   v_column_text   VARCHAR2(500);

   CURSOR c_unassigned_alc IS
    SELECT '<tr align="left" valign="top" class="OraTableCellText">'
	        || '<td>' || NVL(lg.name, '&'||'nbsp;') || '</td>'
			|| '<td>' || NVL(curr.name, '&'||'nbsp;') || '</td>'
			|| '<td>' || NVL(lg.description,
			                 '&'||'nbsp;') || '</td></tr>' row_text
    FROM GL_LEDGERS lg,
         FND_CURRENCIES_TL curr
    WHERE lg.ledger_category_code = 'ALC'
    AND NOT EXISTS(SELECT 'Assigned'
	               FROM GL_LEDGER_RELATIONSHIPS rs
	               WHERE rs.target_ledger_id = lg.ledger_id
                   AND rs.target_ledger_category_code = 'ALC'
                   AND rs.relationship_type_code IN ('JOURNAL', 'SUBLEDGER'))
    AND curr.currency_code = lg.currency_code
    AND curr.language = USERENV('LANG')
    ORDER BY lg.name;

   CURSOR c_multi_src_alc IS
    SELECT distinct '<tr align="left" valign="top" class="OraTableCellText">'
	        || '<td>' || NVL(alc.name, '&'||'nbsp;') || '</td>'
			|| '<td>' || NVL(rcurr.name, '&'||'nbsp;') || '</td>'
	        || '<td>' || NVL(lkr.meaning, '&'||'nbsp;') || '</td>'
	        || '<td>' || NVL(src.name, '&'||'nbsp;') || '</td>'
	        || '<td>' || NVL(pcurr.name, '&'||'nbsp;') || '</td></tr>' row_text
    FROM GL_LEDGERS alc,
         GL_LEDGERS src,
         FND_CURRENCIES_TL pcurr,
         FND_CURRENCIES_TL rcurr,
         GL_LEDGER_RELATIONSHIPS rs,
         GL_LOOKUPS lkr
    WHERE src.ledger_id = rs.source_ledger_id
    AND alc.ledger_id = rs.target_ledger_id
    AND rcurr.currency_code = alc.currency_code
    AND rcurr.language = USERENV('LANG')
    AND pcurr.currency_code = src.currency_code
    AND pcurr.language = USERENV('LANG')
    AND rs.target_ledger_category_code = 'ALC'
    AND rs.relationship_type_code IN ('JOURNAL', 'SUBLEDGER')
    AND lkr.lookup_code = rs.relationship_type_code
    AND lkr.lookup_type = 'GL_ASF_ALC_RELATIONSHIP_LEVEL'
    AND rs.relationship_enabled_flag = 'Y'
    AND rs.target_ledger_id IN
	     (SELECT rs2.target_ledger_id
            FROM GL_LEDGER_RELATIONSHIPS rs2
           WHERE rs2.relationship_enabled_flag = 'Y'
             AND rs2.target_ledger_category_code = 'ALC'
             AND rs2.relationship_type_code IN ('JOURNAL', 'SUBLEDGER')
          HAVING COUNT(distinct rs2.source_ledger_id) > 1
          GROUP BY rs2.target_ledger_id)
    ORDER BY row_text;

   CURSOR c_alc_tcurr IS
    SELECT '<tr align="left" valign="top" class="OraTableCellText">'
			|| '<td>' || NVL(balrs.target_ledger_name, '&'||'nbsp;') || '</td>'
	        || '<td>' || NVL(tcurr.name, '&'||'nbsp;') || '</td>'
	        || '<td>' || NVL(src.name, '&'||'nbsp;') || '</td>'
			|| '<td>' || NVL(scurr.name, '&'||'nbsp;') || '</td></tr>' row_text
    FROM GL_LEDGERS src,
         GL_LEDGER_RELATIONSHIPS srcrs,
         GL_LEDGER_RELATIONSHIPS balrs,
         FND_CURRENCIES_TL scurr,
         FND_CURRENCIES_TL tcurr
    WHERE balrs.relationship_type_code = 'BALANCE'
    AND balrs.target_ledger_category_code = 'ALC'
    AND balrs.relationship_enabled_flag = 'Y'
    AND src.ledger_id = balrs.source_ledger_id
    AND src.ledger_category_code = 'ALC'
    AND srcrs.target_ledger_id (+) = balrs.source_ledger_id
    AND srcrs.target_ledger_category_code (+) = 'ALC'
    AND srcrs.relationship_type_code (+) <> 'NONE'
    AND srcrs.relationship_type_code (+) <> 'BALANCE'
    AND srcrs.application_id (+) = 101
    AND scurr.currency_code = src.currency_code
    AND scurr.language = USERENV('LANG')
    AND tcurr.currency_code = balrs.target_currency_code
    AND tcurr.language = USERENV('LANG')
    ORDER BY balrs.target_ledger_name, src.name;

   CURSOR c_journal_alc IS
    SELECT '<tr align="left" valign="top" class="OraTableCellText">'
	        || '<td>' || NVL(alc.name, '&'||'nbsp;') || '</td>'
			|| '<td>' || NVL(rcurr.name, '&'||'nbsp;') || '</td>'
	        || '<td>' || NVL(alc.description, '&'||'nbsp;') || '</td>'
	        || '<td>' || NVL(src.name, '&'||'nbsp;') || '</td>'
			|| '<td>' || NVL(pcurr.name, '&'||'nbsp;') || '</td></tr>' row_text
    FROM GL_LEDGER_RELATIONSHIPS rs,
         GL_LEDGERS alc,
         GL_LEDGERS src,
         FND_CURRENCIES_TL pcurr,
         FND_CURRENCIES_TL rcurr
    WHERE rs.relationship_type_code = 'JOURNAL'
    AND rs.target_ledger_category_code = 'ALC'
    AND alc.ledger_id = rs.target_ledger_id
    AND src.ledger_id = rs.source_ledger_id
    AND pcurr.currency_code = src.currency_code
    AND pcurr.language = USERENV('LANG')
    AND rcurr.currency_code = alc.currency_code
    AND rcurr.language = USERENV('LANG')
    AND EXISTS (SELECT 'Upgraded from MRC RSOB'
                  FROM GL_MC_BOOK_ASSIGNMENTS_11i
                 WHERE primary_set_of_books_id = rs.source_ledger_id
                   AND reporting_set_of_books_id = rs.target_ledger_id)
    ORDER BY alc.name, src.name;

   CURSOR c_crt_gl_rs IS
    SELECT '<tr align="left" valign="top" class="OraTableCellText">'
	        || '<td>' || NVL(rs.target_ledger_name, '&'||'nbsp;') || '</td>'
	        || '<td>' || NVL(src.name, '&'||'nbsp;') || '</td>'
	        || '<td>' || NVL(NVL(lkre.meaning, rs.relationship_enabled_flag),
                             '&'||'nbsp;') || '</td>'
   			|| '<td>' || NVL(NVL(dtype.user_conversion_type,
                                 rs.alc_default_conv_rate_type),
                             '&'||'nbsp;') || '</td>'
   			|| '<td>' || NVL(NVL(lknra.meaning, rs.alc_no_rate_action_code),
                             '&'||'nbsp;') || '</td>'
   			|| '<td>' || NVL(NVL(lkict.meaning, rs.alc_inherit_conversion_type),
                             '&'||'nbsp;') || '</td>'
   			|| '<td>' || NVL(NVL(lkico.meaning, rs.alc_init_conv_option_code),
                             '&'||'nbsp;') || '</td>'
   			|| '<td>' || NVL(rs.alc_init_period, '&'||'nbsp;') || '</td>'
   			|| '<td>' || DECODE(rs.alc_initializing_rate_date
                          , null, '&'||'nbsp;'
                                , TO_DATE(rs.alc_initializing_rate_date,
                                          'DD-MON-YYYY')) || '</td>'
   			|| '<td>' || NVL(NVL(itype.user_conversion_type,
                                 rs.alc_initializing_rate_type),
                             '&'||'nbsp;') || '</td></tr>' row_text
    FROM GL_LEDGERS src,
         GL_LEDGER_RELATIONSHIPS rs,
         GL_DAILY_CONVERSION_TYPES dtype,
         GL_DAILY_CONVERSION_TYPES itype,
         GL_LOOKUPS lkre,
         GL_LOOKUPS lknra,
         GL_LOOKUPS lkict,
         GL_LOOKUPS lkico
    WHERE rs.target_ledger_category_code = 'ALC'
    AND rs.relationship_type_code = 'SUBLEDGER'
    AND rs.application_id = 101
    AND rs.created_by = 1
    AND src.ledger_id = rs.source_ledger_id
    AND dtype.conversion_type (+) = rs.alc_default_conv_rate_type
    AND itype.conversion_type (+) = rs.alc_initializing_rate_type
    AND lkre.lookup_code (+) = rs.relationship_enabled_flag
    AND lkre.lookup_type (+) = 'YES/NO'
    AND lkre.enabled_flag (+) = 'Y'
    AND lknra.lookup_code (+) = rs.alc_no_rate_action_code
    AND lknra.lookup_type (+) = 'GL_ASF_ALC_RATE_ACTION'
    AND lknra.enabled_flag (+) = 'Y'
    AND lkict.lookup_code (+) = rs.alc_inherit_conversion_type
    AND lkict.lookup_type (+) = 'YES/NO'
    AND lkict.enabled_flag (+) = 'Y'
    AND lkico.lookup_code (+) = rs.alc_init_conv_option_code
    AND lkico.lookup_type (+) = 'GL_ASF_ALC_CONVERSION_OPTION'
    AND lkico.enabled_flag (+) = 'Y'
    AND NOT EXISTS (SELECT 'Exists in GL_MC_REPORTING_OPTIONS'
                      FROM GL_MC_REPORTING_OPTIONS_11i
                     WHERE primary_set_of_books_id = rs.source_ledger_id
                       AND reporting_set_of_books_id = rs.target_ledger_id
                       AND application_id = 101)
    ORDER BY rs.target_ledger_name, src.name;

   CURSOR c_invalid_jrule IS
    SELECT '<tr align="left" valign="top" class="OraTableCellText">'
	        || '<td>' || NVL(alc.name, '&'||'nbsp;') || '</td>'
	        || '<td>' || NVL(src.name, '&'||'nbsp;') || '</td>'
	        || '<td>' || NVL(appl.application_name, '&'||'nbsp;') || '</td>'
   			|| '<td>' || NVL(jes.user_je_source_name, '&'||'nbsp;') || '</td>'
   			|| '<td>' || NVL(jec.user_je_category_name,
			                 '&'||'nbsp;') || '</td></tr>' row_text
    FROM GL_LEDGERS alc,
         GL_LEDGERS src,
         GL_LEDGER_RELATIONSHIPS glrs,
         GL_LEDGER_RELATIONSHIPS sublgrs,
         GL_JE_INCLUSION_RULES jrule,
         GL_JE_SOURCES_VL jes,
         GL_JE_CATEGORIES_VL jec,
         FND_APPLICATION_TL appl
    WHERE alc.ledger_id = glrs.target_ledger_id
    AND src.ledger_id = glrs.source_ledger_id
    AND glrs.application_id = 101
    AND glrs.target_ledger_category_code = 'ALC'
    AND glrs.relationship_type_code = 'SUBLEDGER'
    AND glrs.relationship_enabled_flag = 'Y'
    AND glrs.gl_je_conversion_set_id = jrule.je_rule_set_id
    AND sublgrs.target_ledger_id = glrs.target_ledger_id
    AND sublgrs.source_ledger_id = glrs.source_ledger_id
    AND sublgrs.primary_ledger_id = glrs.primary_ledger_id
    AND sublgrs.target_ledger_category_code = 'ALC'
    AND sublgrs.relationship_type_code = 'SUBLEDGER'
    AND sublgrs.relationship_enabled_flag = 'Y'
    AND sublgrs.application_id = DECODE(jrule.je_source_name
                                  , 'Assets'            , 140
                                  , 'AR Translator'     , 222
                                  , 'Receivables'       , 222
                                  , 'Project Accounting', 275
                                  , 'Purchasing'        , 201
                                  , 'Payables'          , 200
                                  , 'AP Translator'     , 200
                                                        , -1)
    AND jes.je_source_name = jrule.je_source_name
    AND jec.je_category_name = jrule.je_category_name
    AND appl.application_id = sublgrs.application_id
    AND appl.language = USERENV('LANG')
    AND jrule.include_flag = 'Y'
    ORDER BY alc.name, src.name, appl.application_name,
	         jes.user_je_source_name, jec.user_je_category_name;

   CURSOR c_diff_setup_alc IS
    SELECT '<tr align="left" valign="top" class="OraTableCellText">'
	        || '<td>' || NVL(alc.name, '&'||'nbsp;') || '</td>'
	        || '<td>' || NVL(src.name, '&'||'nbsp;') || '</td>'
   			|| '<td>' || NVL(appl.application_name, '&'||'nbsp;') || '</td>'
	        || '<td>' || NVL(ou.name, '&'||'nbsp;') || '</td>'
   			|| '<td>' || NVL(NVL(ctype.user_conversion_type,
			                     rs.alc_default_conv_rate_type),
                             '&'||'nbsp;') || '</td>'
   			|| '<td>' || NVL(NVL(lk1.meaning,
			                     rs.alc_no_rate_action_code),
                             '&'||'nbsp;') || '</td>'
   			|| '<td>' || NVL(NVL(lk2.meaning,
			                     alc_inherit_conversion_type),
                             '&'||'nbsp;') || '</td></tr>' row_text
    FROM GL_LEDGERS alc,
         GL_LEDGERS src,
         GL_LEDGER_RELATIONSHIPS rs,
         FND_APPLICATION_TL appl,
         HR_OPERATING_UNITS ou,
         GL_DAILY_CONVERSION_TYPES ctype,
         GL_LOOKUPS lk1,
         GL_LOOKUPS lk2
    WHERE alc.ledger_id = rs.target_ledger_id
    AND src.ledger_id = rs.source_ledger_id
    AND appl.application_id = rs.application_id
    AND appl.language = USERENV('LANG')
    AND ou.set_of_books_id (+) = rs.primary_ledger_id
    AND ou.organization_id (+) = rs.org_id
    AND rs.target_ledger_category_code = 'ALC'
    AND rs.relationship_type_code = 'SUBLEDGER'
    AND ctype.conversion_type (+) = rs.alc_default_conv_rate_type
    AND lk1.lookup_code (+) = rs.alc_no_rate_action_code
    AND lk1.lookup_type (+) = 'GL_ASF_ALC_RATE_ACTION'
    AND lk1.enabled_flag (+) = 'Y'
    AND lk2.lookup_code (+) = rs.alc_inherit_conversion_type
    AND lk2.lookup_type (+) = 'YES/NO'
    AND lk2.enabled_flag (+) = 'Y'
    AND EXISTS (
         SELECT 'Different setup'
         FROM GL_LEDGER_RELATIONSHIPS rs2
         WHERE rs2.target_ledger_id = rs.target_ledger_id
         AND rs2.source_ledger_id = rs.source_ledger_id
         AND rs2.primary_ledger_id = rs.primary_ledger_id
         AND rs2.target_ledger_category_code = 'ALC'
         AND rs2.relationship_type_code = 'SUBLEDGER'
         AND rs2.relationship_id <> rs.relationship_id
         AND (   rs2.alc_default_conv_rate_type
		          <> rs.alc_default_conv_rate_type
              OR rs2.alc_no_rate_action_code
			      <> rs.alc_no_rate_action_code
              OR rs2.alc_inherit_conversion_type
			      <> rs.alc_inherit_conversion_type))
    ORDER BY alc.name, src.name, appl.application_name, ou.name;

   CURSOR c_partial_setup_alc IS
    SELECT '<tr align="left" valign="top" class="OraTableCellText">'
	        || '<td>' || NVL(alc.name, '&'||'nbsp;') || '</td>'
	        || '<td>' || NVL(src.name, '&'||'nbsp;') || '</td>'
   			|| '<td>' || NVL(appl.application_name, '&'||'nbsp;') || '</td>'
	        || '<td>' || NVL(ou.name, '&'||'nbsp;') || '</td></tr>' row_text
    FROM GL_LEDGERS alc,
         GL_LEDGERS src,
         FND_APPLICATION_TL appl,
         HR_OPERATING_UNITS ou,
         (SELECT DISTINCT source_ledger_id, target_ledger_id, primary_ledger_id
            FROM GL_LEDGER_RELATIONSHIPS
           WHERE target_ledger_category_code = 'ALC'
             AND relationship_type_code = 'SUBLEDGER'
             AND application_id <> 101
             AND relationship_enabled_flag = 'Y') qrs
    WHERE alc.ledger_id = qrs.target_ledger_id
    AND src.ledger_id = qrs.source_ledger_id
    AND ou.set_of_books_id (+) = qrs.primary_ledger_id
    AND appl.application_id IN (101, 140, 200, 201, 222, 275)
    AND appl.language = USERENV('LANG')
    AND NOT EXISTS
         (SELECT 'Enabled relatinoship defined'
          FROM GL_LEDGER_RELATIONSHIPS rs
          WHERE rs.target_ledger_category_code = 'ALC'
          AND rs.relationship_type_code = 'SUBLEDGER'
          AND rs.relationship_enabled_flag = 'Y'
          AND rs.application_id = appl.application_id
          AND rs.target_ledger_id = alc.ledger_id
          AND rs.source_ledger_id = src.ledger_id
          AND (   NVL(rs.org_id, -99) = -99
               OR rs.org_id = ou.organization_id))
    ORDER BY alc.name, src.name, appl.application_name, ou.name;

   v_func_name     VARCHAR2(100);
   v_module        VARCHAR2(100);

BEGIN
   -- Initialize the variables
   v_status_code   := 'INIT_VAR';
   v_module        := 'gl.plsql.gl_as_post_upg_chk_pkg.verify_setup';
   v_func_name     := 'GL_AS_POST_UPG_CHK_PKG.Verify_Setup';
   pv_nl           := '
';

   -- Log the procedure entry
   GL_MESSAGE.Func_Ent(func_name => v_func_name,
                       log_level => pc_log_level_procedure,
                       module    => v_module);

   -- Write the HTML header section
   v_status_code  := 'WRITE_HTML_HDR';

   FND_FILE.put_line
    (FND_FILE.output,
     '<html>'
      ||pv_nl||'<head>'
	  ||pv_nl||'<title>'
             ||FND_MESSAGE.Get_String('SQLGL', 'GL_ASU_POST_RPT_TITLE')
			 ||'</title>'
	  ||pv_nl||'<meta http-equiv="Content-Type" content="text/html; '
	         ||'charset=iso-8859-1">');

   FND_FILE.put_line
    (FND_FILE.output,
     pv_nl||'<STYLE TYPE="text/css">'
	  ||pv_nl||' .OraTableColumnHeader {font-family:Arial, Helvetica, Geneva, '
	         ||'sans-serif; font-size:10pt; font-weight:bold; '
			 ||'background-color:#cccc99; color:#336699; text-indent:1}'
      ||pv_nl||' .OraTableCellText {font-family:Arial, Helvetica, Geneva, '
	         ||'sans-serif; font-size:10pt; background-color:#f7f7e7; '
			 ||'color:#000000; text-indent:1}'
	  ||pv_nl||' .ASMHeaderText {font-family:Arial, Helvetica, Geneva, '
	         ||'sans-serif; color:#000000}'
	  ||pv_nl||' .ASMErrorText {font-family:Arial, Helvetica, Geneva, '
	         ||'sans-serif; font-size:10pt; font-weight:bold; color:#FF0000}'
	  ||pv_nl||' .ASMInfoText {font-family:Arial, Helvetica, Geneva, '
	         ||'sans-serif; font-size:10pt; color:#000000}'
	  ||pv_nl||'</STYLE>');

   FND_FILE.put_line
    (FND_FILE.output,
     pv_nl||'</head>'
	  ||pv_nl||'<body bgcolor="#FFFFFF">');

   -- Write the report title
   v_status_code  := 'WRITE_RPT_TITLE';

   FND_FILE.put_line
    (FND_FILE.output,
     pv_nl||'<h2><font class="ASMHeaderText">'
          ||FND_MESSAGE.Get_String('SQLGL', 'GL_ASU_POST_RPT_TITLE')
          ||'</font></h2>'
      ||pv_nl||'<h4><font class="ASMInfoText">As of '
	         ||TO_CHAR(SYSDATE, 'DD-MON-YY HH:MM:SS')||'</font></h4>');

   -- Print the message GL_ASU_ADDITIONAL_INFO
   FND_FILE.put_line
    (FND_FILE.output,
     pv_nl||'<br><font class="ASMInfoText">'
          ||FND_MESSAGE.Get_String('SQLGL', 'GL_ASU_ADDITIONAL_INFO')
	      ||'</font><br><br>');

   v_status_code := 'CHECK_UNASSIGNED_ALC';
   -- Check if there are any unassigned ALCs

   -- Print section title
   FND_FILE.put_line
    (FND_FILE.output,
     pv_nl||'<br><br><B><font class="ASMHeaderText">'
          ||FND_MESSAGE.Get_String('SQLGL', 'GL_ASU_POST_UNASSIGN_RC')
          ||'</front></B><br><br>');

   FOR v_unassigned_alc IN c_unassigned_alc
   LOOP
     IF (v_status_code = 'CHECK_UNASSIGNED_ALC')
     THEN
       -- Print the talbe header
       v_status_code := 'PRINT_UNASSIGNED_ALC_HDR';

       -- Build the column text
       v_column_text :=
	     '<td>'||FND_MESSAGE.Get_String('SQLGL',
		                                'GL_ASU_PRIMARY_LEDGER')
         ||'</td><td>'||FND_MESSAGE.Get_String('SQLGL',
		                                       'MRC_CURRSETUP_CURR')
         ||'</td><td>'||FND_MESSAGE.Get_String('FND',
		                                       'FND_MENU_DESC_LABEL')
         ||'</td>';

       -- Print the info text and table column
       Print_Table_Header(p_info_msg_name  => 'GL_ASU_POST_UNASSIGN_RC_INFO',
                          p_column_text    => v_column_text);

       -- Set the status so we won't print the header again
       v_status_code := 'PRINT_UNASSIGNED_ALC_ROW';

     END IF;

     -- Print the row text
     FND_FILE.put_line(FND_FILE.output, pv_nl||v_unassigned_alc.row_text);

   END LOOP;

   -- Check if we have print Unassigned ALC table
   IF (v_status_code = 'PRINT_UNASSIGNED_ALC_ROW')
   THEN
     -- Some rows are printed
     FND_FILE.put_line(FND_FILE.output, pv_nl||'</table><br><br>');
   ELSE
     -- No setup issues are found
     FND_FILE.put_line(FND_FILE.output,
	                   pv_nl||'<font class="ASMInfoText">'
                            ||FND_MESSAGE.Get_String('SQLGL',
		                                             'GL_ASU_NO_ISSUES')
                            ||'</font><br><br>');
   END IF;

   v_status_code := 'CHECK_MULTI_SRC_ALC';
   -- Check if there are any ALCs assigned to multiple Sources

   -- Print section title
   FND_FILE.put_line
    (FND_FILE.output,
     pv_nl||'<br><br><B><font class="ASMHeaderText">'
          ||FND_MESSAGE.Get_String('SQLGL', 'GL_ASU_POST_MULTI_SRC_RC')
          ||'</front></B><br><br>');

   FOR v_multi_src_alc IN c_multi_src_alc
   LOOP
     IF (v_status_code = 'CHECK_MULTI_SRC_ALC')
     THEN
       -- Print the table header and info text
       v_status_code := 'PRINT_MUTLI_SRC_ALC_HDR';

       -- Build the column text
       v_column_text :=
	     '<td>'||FND_MESSAGE.Get_String('SQLGL',
		                                'GL_ASU_RCURR')
         ||'</td><td>'||FND_MESSAGE.Get_String('SQLGL',
		                                       'MRC_CURRSETUP_CURR')
         ||'</td><td>'||FND_MESSAGE.Get_String('SQLGL',
		                                       'GL_ASU_POST_RC_LEVEL')
         ||'</td><td>'||FND_MESSAGE.Get_String('SQLGL',
          		                               'GL_ASU_POST_SRC_LG')
         ||'</td><td>'||FND_MESSAGE.Get_String('SQLGL',
		                                       'GL_ASU_POST_SRC_CURR')
         ||'</td>';

       -- Print the info text and table column
       Print_Table_Header(p_info_msg_name  => 'GL_ASU_POST_MULTI_SRC_RC_INFO',
                          p_column_text    => v_column_text);

       -- Set the status so we won't print the header again
       v_status_code := 'PRINT_MULTI_SRC_ALC_ROW';

     END IF;

     -- Print the row text
     FND_FILE.put_line(FND_FILE.output, pv_nl||v_multi_src_alc.row_text);

   END LOOP;

   -- Check if we have print Multi-Source ALC table
   IF (v_status_code = 'PRINT_MULTI_SRC_ALC_ROW')
   THEN
     -- Some rows are printed
     FND_FILE.put_line(FND_FILE.output, pv_nl||'</table><br><br>');
   ELSE
     -- No setup issues are found
     FND_FILE.put_line(FND_FILE.output,
	                   pv_nl||'<font class="ASMInfoText">'
                            ||FND_MESSAGE.Get_String('SQLGL',
		                                             'GL_ASU_NO_ISSUES')
                            ||'</font><br><br>');
   END IF;

   v_status_code := 'CHECK_ALC_TCURR';
   -- Check if any ALC Ledgers have Balance Level ALC

   -- Print section title
   FND_FILE.put_line
    (FND_FILE.output,
     pv_nl||'<br><br><B><font class="ASMHeaderText">'
          ||FND_MESSAGE.Get_String('SQLGL', 'GL_ASU_POST_BLRC_SRC')
          ||'</front></B><br><br>');

   FOR v_alc_tcurr IN c_alc_tcurr
   LOOP
     IF (v_status_code = 'CHECK_ALC_TCURR')
     THEN
       -- Print the table header and info text
       v_status_code := 'PRINT_ALC_TCURR_HDR';

       -- Build the column text
       v_column_text :=
	     '<td>'||FND_MESSAGE.Get_String('SQLGL',
		                                'GL_ASU_RCURR')||' '
               ||FND_MESSAGE.Get_String('SQLGL', 'GL_ASU_POST_BALANCE_LEVEL')
		 ||'</td><td>'||FND_MESSAGE.Get_String('SQLGL',
		                                       'MRC_CURRSETUP_CURR')
         ||'</td><td>'||FND_MESSAGE.Get_String('SQLGL',
		                                       'GL_ASU_POST_SRC_RC_JL_SL')
         ||'</td><td>'||FND_MESSAGE.Get_String('SQLGL',
		                                       'GL_ASU_POST_SRC_CURR')
         ||'</td>';

       -- Print the info text and table column
       Print_Table_Header(p_info_msg_name  => 'GL_ASU_POST_BLRC_SRC_INFO',
                          p_column_text    => v_column_text);

       -- Set the status so we won't print the header again
       v_status_code := 'PRINT_ALC_TCURR_ROW';

     END IF;

     -- Print the row text
     FND_FILE.put_line(FND_FILE.output, pv_nl||v_alc_tcurr.row_text);

   END LOOP;

   -- Check if we have print RSOB Translated Currencies table
   IF (v_status_code = 'PRINT_ALC_TCURR_ROW')
   THEN
     -- Some rows are printed
     FND_FILE.put_line(FND_FILE.output, pv_nl||'</table><br><br>');
   ELSE
     -- No setup issues are found
     FND_FILE.put_line(FND_FILE.output,
	                   pv_nl||'<font class="ASMInfoText">'
                            ||FND_MESSAGE.Get_String('SQLGL',
		                                             'GL_ASU_NO_ISSUES')
                            ||'</font><br><br>');
   END IF;

   v_status_code := 'CHECK_JOURNAL_ALC';
   -- Check if there are any journal level ALC Ledgers

   -- Print section title
   FND_FILE.put_line
    (FND_FILE.output,
     pv_nl||'<br><br><B><font class="ASMHeaderText">'
          ||FND_MESSAGE.Get_String('SQLGL', 'GL_ASU_POST_JLRC_REVIEW')
          ||'</front></B><br><br>');

   FOR v_journal_alc IN c_journal_alc
   LOOP
     IF (v_status_code = 'CHECK_JOURNAL_ALC')
     THEN
       -- Print the table header and info text
       v_status_code := 'PRINT_JOURNAL_ALC_HDR';

       -- Build the column text
       v_column_text :=
	     '<td>'||FND_MESSAGE.Get_String('SQLGL',
		                                'GL_ASU_RCURR')
         ||'</td><td>'||FND_MESSAGE.Get_String('SQLGL',
		                                       'MRC_CURRSETUP_CURR')
         ||'</td><td>'||FND_MESSAGE.Get_String('FND',
		                                       'FND_MENU_DESC_LABEL')
         ||'</td><td>'||FND_MESSAGE.Get_String('SQLGL',
          		                               'GL_ASU_POST_SRC_LG')
         ||'</td><td>'||FND_MESSAGE.Get_String('SQLGL',
		                                       'GL_ASU_POST_SRC_CURR')
         ||'</td>';

       -- Print the info text and table column
       Print_Table_Header(p_info_msg_name  => 'GL_ASU_POST_JLRC_REVIEW_INFO',
                          p_column_text    => v_column_text);

       -- Set the status so we won't print the header again
       v_status_code := 'PRINT_JOURNAL_ALC_ROW';

     END IF;

     -- Print the row text
     FND_FILE.put_line(FND_FILE.output, pv_nl||v_journal_alc.row_text);

   END LOOP;

   -- Check if we have print Journal Level ALC Ledgers table
   IF (v_status_code = 'PRINT_JOURNAL_ALC_ROW')
   THEN
     -- Some rows are printed
     FND_FILE.put_line(FND_FILE.output, pv_nl||'</table><br><br>');
   ELSE
     -- No setup issues are found
     FND_FILE.put_line(FND_FILE.output,
	                   pv_nl||'<font class="ASMInfoText">'
                            ||FND_MESSAGE.Get_String('SQLGL',
		                                             'GL_ASU_NO_ISSUES')
                            ||'</font><br><br>');
   END IF;

   v_status_code := 'CHECK_CRT_GL_RS';
   -- Check if there are any Subledger Level ALC GL relationships created by
   -- the Upgrade

   -- Print section title
   FND_FILE.put_line
    (FND_FILE.output,
     pv_nl||'<br><br><B><font class="ASMHeaderText">'
          ||FND_MESSAGE.Get_String('SQLGL', 'GL_ASU_POST_SLRC_GL_CRT')
          ||'</front></B><br><br>');

   FOR v_crt_gl_rs IN c_crt_gl_rs
   LOOP
     IF (v_status_code = 'CHECK_CRT_GL_RS')
     THEN
       -- Print the table header and info text
       v_status_code := 'PRINT_CRT_GL_RS_HDR';

       -- Build the column text
       v_column_text :=
	     '<td>'||FND_MESSAGE.Get_String('SQLGL',
		                                'GL_ASU_RCURR')
         ||'</td><td>'||FND_MESSAGE.Get_String('SQLGL',
          		                               'GL_ASU_POST_SRC_LG')
         ||'</td><td>'||FND_MESSAGE.Get_String('SQLGL',
		                                       'GL_ASU_POST_ENABLED')
         ||'</td><td>'||FND_MESSAGE.Get_String('SQLGL',
		                                       'GL_ASU_POST_DEFAULT_RTYPE')
         ||'</td><td>'||FND_MESSAGE.Get_String('SQLGL',
		                                       'GL_ASU_POST_MISSING_RATE')
         ||'</td><td>'||FND_MESSAGE.Get_String('SQLGL',
		                                       'GL_ASU_POST_INHERIT_RTYPE')
         ||'</td><td>'||FND_MESSAGE.Get_String('SQLGL',
		                                       'GL_ASU_POST_INIT_CONV_OPT')
         ||'</td><td>'||FND_MESSAGE.Get_String('SQLGL',
		                                       'GL_ASU_POST_INIT_PERIOD')
         ||'</td><td>'||FND_MESSAGE.Get_String('SQLGL',
		                                       'GL_ASU_POST_INIT_RDATE')
         ||'</td><td>'||FND_MESSAGE.Get_String('SQLGL',
		                                       'GL_ASU_POST_INIT_RTYPE')
         ||'</td>';

       -- Print the info text and table column
       Print_Table_Header(p_info_msg_name  => 'GL_ASU_POST_SLRC_GL_CRT_INFO',
                          p_column_text    => v_column_text);

       -- Set the status so we won't print the header again
       v_status_code := 'PRINT_CRT_GL_RS_ROW';

     END IF;

     FND_FILE.put_line(FND_FILE.output, pv_nl||v_crt_gl_rs.row_text);

   END LOOP;

   -- Check if we have print GL Setup Created by Upgrade table
   IF (v_status_code = 'PRINT_CRT_GL_RS_ROW')
   THEN
     -- Some rows are printed
     FND_FILE.put_line(FND_FILE.output, pv_nl||'</table><br><br>');
   ELSE
     -- No setup issues are found
     FND_FILE.put_line(FND_FILE.output,
	                   pv_nl||'<font class="ASMInfoText">'
                            ||FND_MESSAGE.Get_String('SQLGL',
		                                             'GL_ASU_NO_ISSUES')
                            ||'</font><br><br>');
   END IF;

   v_status_code := 'CHECK_INVALID_JRULE';
   -- Check if there are any invalid journal inclusion rules setup

   -- Print section title
   FND_FILE.put_line
    (FND_FILE.output,
     pv_nl||'<br><br><B><font class="ASMHeaderText">'
          ||FND_MESSAGE.Get_String('SQLGL', 'GL_ASU_POST_SLRC_JRULE')
          ||'</front></B><br><br>');

   FOR v_invalid_jrule IN c_invalid_jrule
   LOOP
     IF (v_status_code = 'CHECK_INVALID_JRULE')
     THEN
       -- Print the table header and info text
       v_status_code := 'PRINT_INVALID_JRULE_HDR';

       -- Build the column text
       v_column_text :=
	     '<td>'||FND_MESSAGE.Get_String('SQLGL',
		                                'GL_ASU_RCURR')
         ||'</td><td>'||FND_MESSAGE.Get_String('SQLGL',
          		                               'GL_ASU_POST_SRC_LG')
         ||'</td><td>'||FND_MESSAGE.Get_String('SQLGL',
		                                       'GL_ASU_PRODUCT')
         ||'</td><td>'||FND_MESSAGE.Get_String('SQLGL',
		                                       'GL_ASU_JE_SOURCE')
         ||'</td><td>'||FND_MESSAGE.Get_String('SQLGL',
		                                       'GL_ASU_JE_CATEGORY')
         ||'</td>';

       -- Print the info text and table column
       Print_Table_Header(p_info_msg_name  => 'GL_ASU_POST_SLRC_JRULE_INFO',
                          p_column_text    => v_column_text);

       -- Set the status so we won't print the header again
       v_status_code := 'PRINT_INVALID_JRULE_ROW';

     END IF;

     -- Print the row text
     FND_FILE.put_line(FND_FILE.output, pv_nl||v_invalid_jrule.row_text);

   END LOOP;

   -- Check if we have print Invalid Journal Inclusion Rules table
   IF (v_status_code = 'PRINT_INVALID_JRULE_ROW')
   THEN
     -- Some rows are printed
     FND_FILE.put_line(FND_FILE.output, pv_nl||'</table><br><br>');
   ELSE
     -- No setup issues are found
     FND_FILE.put_line(FND_FILE.output,
	                   pv_nl||'<font class="ASMInfoText">'
                            ||FND_MESSAGE.Get_String('SQLGL',
		                                             'GL_ASU_NO_ISSUES')
                            ||'</font><br><br>');
   END IF;

   v_status_code := 'CHECK_DIFF_SETUP_ALC';
   -- Check if there are any ALC with inconsistent setup

   -- Print section title
   FND_FILE.put_line
    (FND_FILE.output,
     pv_nl||'<br><br><B><font class="ASMHeaderText">'
          ||FND_MESSAGE.Get_String('SQLGL', 'GL_ASU_POST_SLRC_DIFF')
          ||'</front></B><br><br>');

   FOR v_diff_setup_alc IN c_diff_setup_alc
   LOOP
     IF (v_status_code = 'CHECK_DIFF_SETUP_ALC')
     THEN
       -- Print the table header and info text
       v_status_code := 'PRINT_DIFF_SETUP_ALC_HDR';

       -- Build the column text
       v_column_text :=
	     '<td>'||FND_MESSAGE.Get_String('SQLGL',
		                                'GL_ASU_RCURR')
         ||'</td><td>'||FND_MESSAGE.Get_String('SQLGL',
          		                               'GL_ASU_POST_SRC_LG')
         ||'</td><td>'||FND_MESSAGE.Get_String('SQLGL',
		                                       'GL_ASU_PRODUCT')
         ||'</td><td>'||FND_MESSAGE.Get_String('SQLGL',
		                                       'GL_ASU_OU')
         ||'</td><td>'||FND_MESSAGE.Get_String('SQLGL',
		                                       'GL_ASU_POST_DEFAULT_RTYPE')
         ||'</td><td>'||FND_MESSAGE.Get_String('SQLGL',
		                                       'GL_ASU_POST_MISSING_RATE')
         ||'</td><td>'||FND_MESSAGE.Get_String('SQLGL',
		                                       'GL_ASU_POST_INHERIT_RTYPE')
         ||'</td>';

       -- Print the info text and table column
       Print_Table_Header(p_info_msg_name  => 'GL_ASU_POST_SLRC_DIFF_INFO',
                          p_column_text    => v_column_text);

       -- Set the status so we won't print the header again
       v_status_code := 'PRINT_DIFF_SETUP_ALC_ROW';

     END IF;

     -- Print the row text
     FND_FILE.put_line(FND_FILE.output, pv_nl||v_diff_setup_alc.row_text);

   END LOOP;

   -- Check if we have print Inconsisent ALC Setup table
   IF (v_status_code = 'PRINT_DIFF_SETUP_ALC_ROW')
   THEN
     -- Some rows are printed
     FND_FILE.put_line(FND_FILE.output, pv_nl||'</table><br><br>');
   ELSE
     -- No setup issues are found
     FND_FILE.put_line(FND_FILE.output,
	                   pv_nl||'<font class="ASMInfoText">'
                            ||FND_MESSAGE.Get_String('SQLGL',
		                                             'GL_ASU_NO_ISSUES')
                            ||'</font><br><br>');
   END IF;

   v_status_code := 'CHECK_PARTIAL_SETUP_ALC';
   -- Check if there are any ALC Ledgers with partial setup only

   -- Print section title
   FND_FILE.put_line
    (FND_FILE.output,
     pv_nl||'<br><br><B><font class="ASMHeaderText">'
          ||FND_MESSAGE.Get_String('SQLGL', 'GL_ASU_POST_SLRC_PARTIAL')
          ||'</front></B><br><br>');

   FOR v_partial_setup_alc IN c_partial_setup_alc
   LOOP
     IF (v_status_code = 'CHECK_PARTIAL_SETUP_ALC')
     THEN
       -- Print the table header and info text
       v_status_code := 'PRINT_PARTIAL_SETUP_ALC_HDR';

       -- Build the column text
       v_column_text :=
	     '<td>'||FND_MESSAGE.Get_String('SQLGL',
		                                'GL_ASU_RCURR')
         ||'</td><td>'||FND_MESSAGE.Get_String('SQLGL',
          		                               'GL_ASU_POST_SRC_LG')
         ||'</td><td>'||FND_MESSAGE.Get_String('SQLGL',
		                                       'GL_ASU_PRODUCT')
         ||'</td><td>'||FND_MESSAGE.Get_String('SQLGL',
		                                       'GL_ASU_OU')
         ||'</td>';

       -- Print the info text and table column
       Print_Table_Header(p_info_msg_name  => 'GL_ASU_POST_SLRC_PARTIAL_INFO',
                          p_column_text    => v_column_text);

       -- Set the status so we won't print the header again
       v_status_code := 'PRINT_PARTIAL_SETUP_ALC_ROW';

     END IF;

     -- Print the row text
     FND_FILE.put_line(FND_FILE.output, pv_nl||v_partial_setup_alc.row_text);

   END LOOP;

   -- Check if we have print Incomplete ALC Setup table
   IF (v_status_code = 'PRINT_PARTIAL_SETUP_ALC_ROW')
   THEN
     -- Some rows are printed
     FND_FILE.put_line(FND_FILE.output, pv_nl||'</table><br><br>');
   ELSE
     -- No setup issues are found
     FND_FILE.put_line(FND_FILE.output,
	                   pv_nl||'<font class="ASMInfoText">'
                            ||FND_MESSAGE.Get_String('SQLGL',
		                                             'GL_ASU_NO_ISSUES')
                            ||'</font><br><br>');
   END IF;

   -- Complete the HTML report
   FND_FILE.put_line(FND_FILE.output, pv_nl||'</body></html>');

   -- Log the success exit
   GL_MESSAGE.Func_Succ(func_name => v_func_name,
                        log_level => pc_log_level_procedure,
                        module    => v_module);

   -- Set the concurrent program completion status before exit
   v_return_status := FND_CONCURRENT.Set_Completion_Status
                        (status => 'SUCCESS', message => NULL);

   -- Commit the changes and exit
   Commit;

EXCEPTION
  WHEN PRINT_ERROR THEN
    -- <<< Error rased when printing table header >>>

    -- Set the output parameters for the concurrent program
    x_errbuf  := SQLERRM;
    x_retcode := SQLCODE;

    -- Print the fatal error message
    FND_FILE.put_line
     (FND_FILE.output,
	  pv_nl||'<br><br><font class="ASMErrorText">'
           ||FND_MESSAGE.Get_String('SQLGL', 'GL_ASU_FATAL_ERROR')
           ||'</font><br><br>');
    -- Complete the HTML report
    FND_FILE.put_line(FND_FILE.output, pv_nl||'</body></html>');

    -- Log the error exit
    GL_MESSAGE.Func_Fail(func_name => v_func_name,
                         log_level => pc_log_level_procedure,
                         module    => v_module);
    -- Set the concurrent program completion status to ERROR
    v_return_status := FND_CONCURRENT.Set_Completion_Status
                         (status => 'ERROR', message => NULL);
    -- Commit the changes
    Commit;

  WHEN Others THEN
    -- <<< Unexpected database exceptions >>>

    -- Set the output parameters for the concurrent program
    x_errbuf  := SQLERRM;
    x_retcode := SQLCODE;

    -- Print the error message to program log file
    FND_FILE.put_line(FND_FILE.log, x_errbuf);
    -- Print the error message to FND Log
    GL_MESSAGE.Write_Fndlog_String(log_level => pc_log_leveL_unexpected,
                                   module    => v_module,
                                   message   => x_errbuf);

    -- Print the fatal error message
    FND_FILE.put_line
     (FND_FILE.output,
	  pv_nl||'<br><br><font class="ASMErrorText">'
           ||FND_MESSAGE.Get_String('SQLGL', 'GL_ASU_FATAL_ERROR')
           ||'</font><br><br>');
    -- Complete the HTML report
    FND_FILE.put_line(FND_FILE.output, pv_nl||'</body></html>');

    -- Log the error exit
    GL_MESSAGE.Func_Fail(func_name => v_func_name,
                         log_level => pc_log_level_procedure,
                         module    => v_module);
    -- Set the concurrent program completion status to ERROR
    v_return_status := FND_CONCURRENT.Set_Completion_Status
                         (status => 'ERROR', message => NULL);
    -- Commit the changes
    Commit;

END Verify_Setup;

-- PROCEDURE
--   Print_Table_Header()
--
-- DESCRIPTION:
--   This will print the passed info message and the table column text.
PROCEDURE Print_Table_Header(  p_info_msg_name  IN VARCHAR2
							 , p_column_text    IN VARCHAR2) IS
   v_func_name     VARCHAR2(100);
   v_module        VARCHAR2(100);
BEGIN
   -- Initialize the variables
   v_module        := 'gl.plsql.gl_as_post_upg_chk_pkg.print_table_header';
   v_func_name     := 'GL_AS_POST_UPG_CHK_PKG.Print_Table_Header';

   -- Log the procedure entry
   GL_MESSAGE.Func_Ent(func_name => v_func_name,
                       log_level => pc_log_level_procedure,
                       module    => v_module);

   IF (p_info_msg_name IS NOT NULL)
   THEN
     FND_FILE.put_line
	  (FND_FILE.output,
       pv_nl||'<font class="ASMInfoText">'
	        ||FND_MESSAGE.Get_String('SQLGL', p_info_msg_name)
			||'</font><br><br>');
   END IF;

   IF (p_column_text IS NOT NULL)
   THEN
     FND_FILE.put_line
 	  (FND_FILE.output,
       pv_nl||'<table align="center" width="95%" border="1">');
     FND_FILE.put_line
	  (FND_FILE.output,
	   pv_nl||'<tr align="left" valign="bottom" class="OraTableColumnHeader">');
     FND_FILE.put_line
 	  (FND_FILE.output,
	   pv_nl||p_column_text||'</tr>');
   END IF;

   -- Log the success exit
   GL_MESSAGE.Func_Succ(func_name => v_func_name,
                        log_level => pc_log_level_procedure,
                        module    => v_module);
EXCEPTION
  WHEN Others THEN
    -- <<< Unexpected database exceptions >>>

    -- Print the error message to program log file
    FND_FILE.put_line(FND_FILE.log, SQLERRM);
    -- Print the error message to FND Log
    GL_MESSAGE.Write_Fndlog_String(log_level => pc_log_leveL_unexpected,
                                   module    => v_module,
                                   message   => SQLERRM);
    -- Log the error exit
    GL_MESSAGE.Func_Fail(func_name => v_func_name,
                         log_level => pc_log_level_procedure,
                         module    => v_module);
    RAISE PRINT_ERROR;

END Print_Table_Header;

END GL_AS_POST_UPG_CHK_PKG;

/

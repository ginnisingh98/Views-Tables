--------------------------------------------------------
--  DDL for Package FND_FLEX_DIAGNOSE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_FLEX_DIAGNOSE" AUTHID CURRENT_USER AS
/* $Header: AFFFDGNS.pls 120.4.12010000.1 2008/07/25 14:13:54 appldev ship $ */


-- ***************************************************************************
-- * Common get_something() RETURN VARCHAR2; functions.
-- ***************************************************************************
-- ===========================================================================
-- Returns the database information.
--
FUNCTION get_db RETURN VARCHAR2;

-- ===========================================================================
-- Returns the release information.
--
FUNCTION get_rel RETURN VARCHAR2;

-- ===========================================================================
-- Returns the who information from the given table, and given rowid, or
-- concatenates the individual who columns.
--
-- Syntax  : 'CD:<creation_date>  CB:<created_by>  LUD:<last_update_date>
--            LUB:<last_updated_by>  LUL:<last_update_login>'
-- Example : 'CD:2000/01/01  CB:1  LUD:2000/01/02 LUB:1  LUL:123'
--
FUNCTION get_who(p_creation_date                IN DATE,
                 p_created_by                   IN NUMBER,
                 p_last_update_date             IN DATE,
                 p_last_updated_by              IN NUMBER,
                 p_last_update_login            IN NUMBER)
  RETURN VARCHAR2;
--
FUNCTION get_who(p_table_name                   IN VARCHAR2,
                 p_rowid                        IN ROWID)
  RETURN VARCHAR2;

-- ===========================================================================
-- Returns the application information.
--
-- Syntax  : '<application_id>/<application_short_name>/<application_name>'
-- Example : '0/FND/Application Object Library'
--
FUNCTION get_app(p_application_id               IN NUMBER)
  RETURN VARCHAR2;

-- ===========================================================================
-- Returns the table information.
--
-- Syntax  : '<table_owner>/<table_name>/<table_id>'
-- Example : 'GL/GL_CODE_COMBINATIONS/584'
--
FUNCTION get_tbl(p_application_id               IN NUMBER,
                 p_table_name                   IN VARCHAR2)
  RETURN VARCHAR2;

-- ===========================================================================
-- Returns the column information.
--
-- Syntax  : '<column_name>/<column_id>/<column_type>/<column_size>/
--            <flexfield_usage_code>/<flexfield_application_id>/
--            <flexfield_name>'
-- Example : 'ATTRIBUTE_CATEGORY/6406/C/60/C/101/GL_CODE_COMBINATIONS'
--
FUNCTION get_col(p_application_id               IN NUMBER,
                 p_table_name                   IN VARCHAR2,
                 p_column_name                  IN VARCHAR2)
  RETURN VARCHAR2;

-- ===========================================================================
-- Returns the language information.
--
-- Syntax  : '<language_code>/<installed_flag>/<nls_language>/<nls_territory>'
-- Example : 'TR/I/TURKISH/TURKEY'
--
FUNCTION get_lng(p_language_code                IN VARCHAR2)
  RETURN VARCHAR2;

-- ===========================================================================
-- Returns the responsibility information.
--
-- Syntax  : '<responsibility_id>/<responsibility_key>/<responsibility_name>'
-- Example : 'APPLICATION_DEVELOPER/Application Developer'
--
FUNCTION get_rsp(p_application_id               IN NUMBER,
                 p_responsibility_id            IN NUMBER)
  RETURN VARCHAR2;

-- ***************************************************************************
-- * FB get_fb_something() RETURN VARCHAR2; functions.
-- ***************************************************************************
-- ===========================================================================
-- Returns the flexbuilder function information.
--
-- Syntax : '<function_code>/<function_name>/<description>
-- Example: 'PO_REQ_VARIANCE_ACCOUNT/Requisition Variance Account/Desc'
--
FUNCTION get_fb_func(p_application_id IN NUMBER,
                     p_function_code  IN VARCHAR2)
  RETURN VARCHAR2;

-- ===========================================================================
-- Returns the kff application information for flexbuilder function.
--
-- Syntax  : see get_app
-- Example :
--
FUNCTION get_fb_kapp(p_application_id IN NUMBER,
                     p_function_code  IN VARCHAR2)
  RETURN VARCHAR2;

-- ===========================================================================
-- Returns the kff information for flexbuilder function.
--
-- Syntax  : see get_kff_flx
-- Example :
--
FUNCTION get_fb_kflx(p_application_id IN NUMBER,
                     p_function_code  IN VARCHAR2)
  RETURN VARCHAR2;

-- ===========================================================================
-- Returns the kff structure information for flexbuilder function.
--
-- Syntax  : see get_kff_str.
-- Example :
--
FUNCTION get_fb_kstr(p_application_id IN NUMBER,
                     p_function_code  IN VARCHAR2,
                     p_id_flex_num    IN NUMBER)
  RETURN VARCHAR2;


-- ***************************************************************************
-- * VST get_vst_something() RETURN VARCHAR2; functions.
-- ***************************************************************************
-- ===========================================================================
-- Returns the value set information.
--
-- Syntax : '<flex_value_set_id>/<flex_value_set_name>/<validation_type>/
--           <format_type>/<maximum_size>/<description>'
-- Example: '12345/FND_FLEX_TEST/I/C/10'
--
FUNCTION get_vst_set(p_flex_value_set_id            IN NUMBER)
  RETURN VARCHAR2;

-- ===========================================================================
-- Returns the value set table information.
--
-- Syntax : '<application_table_name>/
--           <value_column_name>/<value_column_type>/<value_column_size>/
--           <id_column_name>/<id_column_type>/<id_column_size>'
-- Example: 'FND_FLEX_TEST/VALUE/V/60/ID/N/22'
--
FUNCTION get_vst_tbl(p_flex_value_set_id            IN NUMBER)
  RETURN VARCHAR2;

-- ===========================================================================
-- Returns the value set event information.
--
-- Syntax : '<event_code>/<event_name>/<user_exit>'
-- Example: 'E/Edit/FND POPID ...'
--
FUNCTION get_vst_evt(p_flex_value_set_id            IN NUMBER,
                     p_event_code                   IN VARCHAR2)
  RETURN VARCHAR2;

-- ===========================================================================
-- Returns the security rule information.
--
-- Syntax  : '<flex_value_rule_id>/<flex_value_rule_name>/
--            <parent_flex_value_low>/<error_message>'
-- Example : '1234/MySecurity/<NULL>/Value 1000 is secured.'
--
FUNCTION get_vst_scr(p_flex_value_set_id            IN NUMBER,
                     p_flex_value_rule_id           IN NUMBER)
  RETURN VARCHAR2;

-- ===========================================================================
-- Returns the security rule line information.
--
-- Syntax  : '<include_exclude_indicator>/<parent_flex_value_low>/
--            <flex_value_low>/<flex_value_high>'
-- Example : 'I/<NULL>/00/ZZ'
--
FUNCTION get_vst_scl(p_flex_value_set_id            IN NUMBER,
                     p_flex_value_rule_id           IN NUMBER,
                     p_include_exclude_indicator    IN VARCHAR2,
                     p_flex_value_low               IN VARCHAR2,
                     p_flex_value_high              IN VARCHAR2)
  RETURN VARCHAR2;

-- ===========================================================================
-- Returns the security rule usage information.
--
-- Syntax  : '<flex_value_rule_id>/<application_id>/<responsibility_id>'
-- Example : '1234/0/100'
--
FUNCTION get_vst_scu(p_flex_value_set_id            IN NUMBER,
                     p_flex_value_rule_id           IN NUMBER,
                     p_application_id               IN NUMBER,
                     p_responsibility_id            IN NUMBER)
  RETURN VARCHAR2;

-- ===========================================================================
-- Returns the flex value information.
--
-- Syntax  : '<flex_value_id>/<parent_flex_value_low>/<flex_value>/
--            <enabled_flag>/<flex_value_meaning>/<description>'
-- Example : '1234/CA/SF/Y/{SF}/City of SF'
--
FUNCTION get_vst_val(p_flex_value_set_id            IN NUMBER,
                     p_flex_value_id                IN NUMBER)
  RETURN VARCHAR2;

-- ===========================================================================
-- Returns the rollup group information.
--
-- Syntax  : '<hierarchy_id>/<hierarchy_name>/<description>'
-- Example : '1234/MyHR/My hierarchy.'
--
FUNCTION get_vst_rlg(p_flex_value_set_id            IN NUMBER,
                     p_hierarchy_id                 IN NUMBER)
  RETURN VARCHAR2;

-- ===========================================================================
-- Returns the normalized value hierarchy information.
--
-- Syntax  : '<parent_flex_value>/<range_attribute>/
--             <child_flex_value_low>/<child_flex_value_high>'
-- Example : 'CA/P/SF/SF'
--
FUNCTION get_vst_fvn(p_flex_value_set_id            IN NUMBER,
                     p_parent_flex_value            IN VARCHAR2,
                     p_range_attribute              IN VARCHAR2,
                     p_child_flex_value_low         IN VARCHAR2,
                     p_child_flex_value_high        IN VARCHAR2)
  RETURN VARCHAR2;

-- ===========================================================================
-- Returns the de-normalized value hierarchy information.
--
-- Syntax  : '<parent_flex_value>/
--            <child_flex_value_low>/<child_flex_value_high>'
-- Example : 'CA/SF/SF'
--
FUNCTION get_vst_fvh(p_flex_value_set_id            IN NUMBER,
                     p_parent_flex_value            IN VARCHAR2,
                     p_child_flex_value_low         IN VARCHAR2,
                     p_child_flex_value_high        IN VARCHAR2)
  RETURN VARCHAR2;


-- ===========================================================================
-- Returns the PL/SQL code to fix a problem.
-- pk's are primary keys for the specific rule.
--
FUNCTION get_vst_fix(p_rule                         IN VARCHAR2,
                     p_pk1                          IN VARCHAR2 DEFAULT NULL,
                     p_pk2                          IN VARCHAR2 DEFAULT NULL,
                     p_pk3                          IN VARCHAR2 DEFAULT NULL,
                     p_pk4                          IN VARCHAR2 DEFAULT NULL,
                     p_pk5                          IN VARCHAR2 DEFAULT NULL,
                     p_pk6                          IN VARCHAR2 DEFAULT NULL)
  RETURN VARCHAR2;

-- ***************************************************************************
-- * VST validate_vst_something() functions
-- ***************************************************************************
-- ===========================================================================
-- Validates vset table definition
--
FUNCTION validate_vst_tbl(p_flex_value_set_id IN NUMBER)
  RETURN VARCHAR2;

-- ***************************************************************************
-- * VST fix_vst_something(); procedures.
-- ***************************************************************************
-- ===========================================================================
-- Fixes the integrity problems reported in VST check script.
-- See $FND_TOP/sql/afffcvst.sql
--
-- ===========================================================================
-- Rules : A.01, A.02, A.03, A.04, A.05, B.01, B.02
--
PROCEDURE fix_vst_set(p_rule                         IN VARCHAR2,
                      p_flex_value_set_id            IN NUMBER,
                      x_message                      OUT nocopy VARCHAR2);

-- ===========================================================================
-- Rules : C.01, C.02
--
PROCEDURE fix_vst_evt(p_rule                         IN VARCHAR2,
                      p_flex_value_set_id            IN NUMBER,
                      p_event_code                   IN VARCHAR2,
                      x_message                      OUT nocopy VARCHAR2);

-- ===========================================================================
-- Rules : D.03
--
PROCEDURE fix_vst_scr(p_rule                         IN VARCHAR2,
                      p_flex_value_set_id            IN NUMBER,
                      p_flex_value_rule_id           IN NUMBER,
                      x_message                      OUT nocopy VARCHAR2);


-- ===========================================================================
-- Rules : E.01, E.02
--
PROCEDURE fix_vst_scl(p_rule                         IN VARCHAR2,
                      p_flex_value_set_id            IN NUMBER,
                      p_flex_value_rule_id           IN NUMBER,
                      p_include_exclude_indicator    IN VARCHAR2,
                      p_flex_value_low               IN VARCHAR2,
                      p_flex_value_high              IN VARCHAR2,
                      x_message                      OUT nocopy VARCHAR2);


-- ===========================================================================
-- Rules : F.01, F.02, F.03
--
PROCEDURE fix_vst_scu(p_rule                         IN VARCHAR2,
                      p_flex_value_set_id            IN NUMBER,
                      p_flex_value_rule_id           IN NUMBER,
                      p_application_id               IN NUMBER,
                      p_responsibility_id            IN NUMBER,
                      x_message                      OUT nocopy VARCHAR2);


-- ===========================================================================
-- Rules : G.03, G.04
--
PROCEDURE fix_vst_val(p_rule                         IN VARCHAR2,
                      p_flex_value_set_id            IN NUMBER,
                      p_flex_value_id                IN NUMBER,
                      x_message                      OUT nocopy VARCHAR2);


-- ===========================================================================
-- Rules : H.03
--
PROCEDURE fix_vst_rlg(p_rule                         IN VARCHAR2,
                      p_flex_value_set_id            IN NUMBER,
                      p_hierarchy_id                 IN NUMBER,
                      x_message                      OUT nocopy VARCHAR2);

-- ===========================================================================
-- Rules : I.01
--
PROCEDURE fix_vst_fvn(p_rule                         IN VARCHAR2,
                      p_flex_value_set_id            IN NUMBER,
                      p_parent_flex_value            IN VARCHAR2,
                      p_range_attribute              IN VARCHAR2,
                      p_child_flex_value_low         IN VARCHAR2,
                      p_child_flex_value_high        IN VARCHAR2,
                      x_message                      OUT nocopy VARCHAR2);

-- ===========================================================================
-- Rules : J.01
--
PROCEDURE fix_vst_fvh(p_rule                         IN VARCHAR2,
                      p_flex_value_set_id            IN NUMBER,
                      p_parent_flex_value            IN VARCHAR2,
                      p_child_flex_value_low         IN VARCHAR2,
                      p_child_flex_value_high        IN VARCHAR2,
                      x_message                      OUT nocopy VARCHAR2);

-- ***************************************************************************
-- * DFF get_dff_something() RETURN VARCHAR2; functions.
-- ***************************************************************************
-- ===========================================================================
-- Returns the DFF information.
--
-- Syntax  : '<descriptive_flexfield_name>/<title>'
-- Example : 'FND_FLEX_TEST/Test Descriptive Flexfields'
--
FUNCTION get_dff_flx(p_application_id               IN NUMBER,
                     p_descriptive_flexfield_name   IN VARCHAR2)
  RETURN VARCHAR2;

-- ===========================================================================
-- Returns the DFF Context information.
--
-- Syntax  : '<descriptive_flex_context_code>/<global_flag>/<enabled_flag>/
--            <descriptive_flex_context_name>/<description>'
-- Example : 'Global Data Elements/Y/Y/Global Data Elements/Global Desc.'
--
FUNCTION get_dff_ctx(p_application_id               IN NUMBER,
                     p_descriptive_flexfield_name   IN VARCHAR2,
                     p_descriptive_flex_context_cod IN VARCHAR2)
  RETURN VARCHAR2;

-- ===========================================================================
-- Returns the DFF Segment information.
--
-- Syntax  : '<application_column_name>/<enabled_flag>/<display_flag>/
--            <end_user_column_name>/<form_left_prompt>/<description>'
-- Example : 'ATTRIBUTE1/Y/Y/My Column/ColPrompt/Desc.'
--
FUNCTION get_dff_seg(p_application_id               IN NUMBER,
                     p_descriptive_flexfield_name   IN VARCHAR2,
                     p_descriptive_flex_context_cod IN VARCHAR2,
                     p_application_column_name      IN VARCHAR2)
  RETURN VARCHAR2;

-- ===========================================================================
-- Returns the DFF Table Application information. Similar to get_app.
--
-- Syntax  : '<application_id>/<application_short_name>/<application_name>'
-- Example : '0/FND/Application Object Library'
--
FUNCTION get_dff_tap(p_application_id               IN NUMBER,
                     p_descriptive_flexfield_name   IN VARCHAR2)
  RETURN VARCHAR2;

-- ===========================================================================
-- Returns the DFF Table information. Similar to get_tbl.
--
-- Syntax  : '<table_owner>/<table_name>/<table_id>'
-- Example : 'GL/GL_CODE_COMBINATIONS/584'
--
FUNCTION get_dff_tbl(p_application_id               IN NUMBER,
                     p_descriptive_flexfield_name   IN VARCHAR2)
  RETURN VARCHAR2;

-- ===========================================================================
-- Returns the DFF Segment Column information. Similar to get_col.
--
-- Syntax  : '<column_name>/<column_id>/<column_type>/<column_size>/
--            <flexfield_usage_code>/<flexfield_application_id>/
--            <flexfield_name>'
-- Example : 'ATTRIBUTE1/6407/V/60/D/101/GL_CODE_COMBINATIONS'
--
--
FUNCTION get_dff_col(p_application_id               IN NUMBER,
                     p_descriptive_flexfield_name   IN VARCHAR2,
                     p_application_column_name      IN VARCHAR2)
  RETURN VARCHAR2;

-- ===========================================================================
-- Returns the PL/SQL code to fix a problem.
-- pk's are primary keys for the specific rule.
--
FUNCTION get_dff_fix(p_rule                         IN VARCHAR2,
                     p_pk1                          IN VARCHAR2 DEFAULT NULL,
                     p_pk2                          IN VARCHAR2 DEFAULT NULL,
                     p_pk3                          IN VARCHAR2 DEFAULT NULL,
                     p_pk4                          IN VARCHAR2 DEFAULT NULL,
                     p_pk5                          IN VARCHAR2 DEFAULT NULL)
  RETURN VARCHAR2;

-- ***************************************************************************
-- * DFF fix_dff_something(); procedures.
-- ***************************************************************************
-- ===========================================================================
-- Fixes the integrity problems reported in DFF check script.
-- See $FND_TOP/sql/afffcdff.sql
--
-- ===========================================================================
-- Rules : A.03, A.09, A.10, A.11, A.12, D.01
--
PROCEDURE fix_dff_flx(p_rule                         IN VARCHAR2,
                      p_application_id               IN NUMBER,
                      p_descriptive_flexfield_name   IN VARCHAR2,
                      x_message                      OUT nocopy VARCHAR2);

-- ===========================================================================
-- Rules : B.01
--
PROCEDURE fix_dff_ref(p_rule                         IN VARCHAR2,
                      p_application_id               IN NUMBER,
                      p_descriptive_flexfield_name   IN VARCHAR2,
                      p_default_context_field_name   IN VARCHAR2,
                      x_message                      OUT nocopy VARCHAR2);

-- ===========================================================================
-- Rules : C.03, C.04, C.05, C.06
--
PROCEDURE fix_dff_ctx(p_rule                         IN VARCHAR2,
                      p_application_id               IN NUMBER,
                      p_descriptive_flexfield_name   IN VARCHAR2,
                      p_descriptive_flex_context_cod IN VARCHAR2,
                      x_message                      OUT nocopy VARCHAR2);

-- ===========================================================================
-- Rules : E.03, E.06, E.07, E.08
--
PROCEDURE fix_dff_seg(p_rule                         IN VARCHAR2,
                      p_application_id               IN NUMBER,
                      p_descriptive_flexfield_name   IN VARCHAR2,
                      p_descriptive_flex_context_cod IN VARCHAR2,
                      p_application_column_name      IN VARCHAR2,
                      x_message                      OUT nocopy VARCHAR2);

-- ===========================================================================
-- Rules : F.01, F.02
--
PROCEDURE fix_dff_col(p_rule                         IN VARCHAR2,
                      p_application_id               IN NUMBER,
                      p_table_name                   IN VARCHAR2,
                      p_column_name                  IN VARCHAR2,
                      x_message                      OUT nocopy VARCHAR2);

-- ***************************************************************************
-- * KFF get_kff_something() RETURN VARCHAR2; functions.
-- ***************************************************************************
-- ===========================================================================
-- Returns the KFF information.
--
-- Syntax  : '<id_flex_code>/<id_flex_name>/<description>'
-- Example : 'GL#/Accounting Flexfield/Acct. Flex.'
--
FUNCTION get_kff_flx(p_application_id               IN NUMBER,
                     p_id_flex_code                 IN VARCHAR2)
  RETURN VARCHAR2;

-- ===========================================================================
-- Returns the KFF structure information.
--
-- Syntax  : '<id_flex_num>/<enabled_flag>/
--            <freeze_flex_definition_flag>/<concatenated_segment_delimiter>/
--            <id_flex_structure_name>'
-- Example : '101/Y/Y/./Operations Accounting Flexfield'
--
FUNCTION get_kff_str(p_application_id               IN NUMBER,
                     p_id_flex_code                 IN VARCHAR2,
                     p_id_flex_num                  IN NUMBER)
  RETURN VARCHAR2;

-- ===========================================================================
-- Returns the KFF Segment information.
--
-- Syntax  : '<application_column_name>/<enabled_flag>/<display_flag>/
--            <segment_name>/<form_left_prompt>/<description>'
-- Example : 'SEGMENT1/Y/Y/Company/Prompt/Desc'
--
FUNCTION get_kff_seg(p_application_id               IN NUMBER,
                     p_id_flex_code                 IN VARCHAR2,
                     p_id_flex_num                  IN NUMBER,
                     p_application_column_name      IN VARCHAR2)
  RETURN VARCHAR2;

-- ===========================================================================
-- Returns the KFF Shorthand Alias information.
--
-- Syntax  : '<alias_name>/<enabled_flag>/<concatenated_segments>/
--            <description>'
-- Example : 'Cash/Y/01.100/Cash Account'
--
FUNCTION get_kff_sha(p_application_id               IN NUMBER,
                     p_id_flex_code                 IN VARCHAR2,
                     p_id_flex_num                  IN NUMBER,
                     p_alias_name                   IN VARCHAR2)
  RETURN VARCHAR2;


-- ===========================================================================
-- Returns the KFF Cross Validation Rule information.
--
-- Syntax  : '<flex_validation_rule_name>/<enabled_flag>/
--            <error_message_text>/<description>'
-- Example : 'My_CVR/Y/Enter valid comb./My Cross Val'
--
FUNCTION get_kff_cvr(p_application_id               IN NUMBER,
                     p_id_flex_code                 IN VARCHAR2,
                     p_id_flex_num                  IN NUMBER,
                     p_flex_validation_rule_name    IN VARCHAR2)
  RETURN VARCHAR2;

-- ===========================================================================
-- Returns the KFF Cross Validation Line information.
--
-- Syntax  : '<rule_line_id>/<enabled_flag>/<include_exclude_indicator>/
--            <concatenated_segments_low>/<concatenated_segments_high>'
-- Example : '1234/Y/I/0.0.0/9.9.9'
--
FUNCTION get_kff_cvl(p_application_id               IN NUMBER,
                     p_id_flex_code                 IN VARCHAR2,
                     p_id_flex_num                  IN NUMBER,
                     p_flex_validation_rule_name    IN VARCHAR2,
                     p_rule_line_id                 IN NUMBER)
  RETURN VARCHAR2;

-- ===========================================================================
-- Returns the Flexfield Qualifier Information.
--
-- Syntax  : '<segment_attribute_type>/<global_flag>/
--            <required_flag>/<unique_flag>/<segment_prompt>'
-- Example : 'GL_GLOBAL/Y/Y/N/GL_GLOBAL'
--
FUNCTION get_kff_flq(p_application_id               IN NUMBER,
                     p_id_flex_code                 IN VARCHAR2,
                     p_segment_attribute_type       IN VARCHAR2)
  RETURN VARCHAR2;

-- ===========================================================================
-- Returns the Segment Qualifier Information.
--
-- Syntax  : '<value_attribute_type>/<application_column_name>/
--            <lookup_type>/<default_value>/<prompt>'
-- Example : 'GL_ACCOUNT_TYPE/ACCOUNT_TYPE/ACCOUNT_TYPE/E/Account Type'
--
FUNCTION get_kff_sgq(p_application_id               IN NUMBER,
                     p_id_flex_code                 IN VARCHAR2,
                     p_segment_attribute_type       IN VARCHAR2,
                     p_value_attribute_type         IN VARCHAR2)
  RETURN VARCHAR2;

-- ===========================================================================
-- Returns the KFF Table Application information. Similar to get_app.
--
-- Syntax  : '<application_id>/<application_short_name>/<application_name>'
-- Example : '101/SQLGL/Oracle General Ledger'
--
FUNCTION get_kff_tap(p_application_id               IN NUMBER,
                     p_id_flex_code                 IN VARCHAR2)
  RETURN VARCHAR2;

-- ===========================================================================
-- Returns the KFF Table information. Similar to get_tbl.
--
-- Syntax  : '<table_owner>/<table_name>/<table_id>'
-- Example : 'GL/GL_CODE_COMBINATIONS/584'
--
FUNCTION get_kff_tbl(p_application_id               IN NUMBER,
                     p_id_flex_code                 IN VARCHAR2)
  RETURN VARCHAR2;

-- ===========================================================================
-- Returns the KFF Segment Column information. Similar to get_col.
--
-- Syntax  : '<column_name>/<column_id>/<column_type>/<column_size>/
--            <flexfield_usage_code>/<flexfield_application_id>/
--            <flexfield_name>'
-- Example : 'ATTRIBUTE1/6407/V/60/D/101/GL_CODE_COMBINATIONS'
--
--
FUNCTION get_kff_col(p_application_id               IN NUMBER,
                     p_id_flex_code                 IN VARCHAR2,
                     p_application_column_name      IN VARCHAR2)
  RETURN VARCHAR2;

-- ===========================================================================
-- Returns the AG/WF Process details.
--
-- Syntax  : '<wf_item_type>/<wf_process_name>'
-- Example : 'POWFRQBA/DEFAULT_ACCOUNT_GENERATION'
--
FUNCTION get_kff_fwp(p_application_id               IN NUMBER,
                     p_id_flex_code                 IN VARCHAR2,
                     p_id_flex_num                  IN NUMBER,
                     p_wf_item_type                 IN VARCHAR2)
  RETURN VARCHAR2;

-- ===========================================================================
-- Returns the PL/SQL code to fix a problem.
--
FUNCTION get_kff_fix(p_rule                         IN VARCHAR2,
                     p_pk1                          IN VARCHAR2 DEFAULT NULL,
                     p_pk2                          IN VARCHAR2 DEFAULT NULL,
                     p_pk3                          IN VARCHAR2 DEFAULT NULL,
                     p_pk4                          IN VARCHAR2 DEFAULT NULL,
                     p_pk5                          IN VARCHAR2 DEFAULT NULL,
                     p_pk6                          IN VARCHAR2 DEFAULT NULL)
  RETURN VARCHAR2;


-- ***************************************************************************
-- * KFF fix_kff_something(); procedures.
-- ***************************************************************************
-- Fixes the integrity problems reported in KFF check script.
-- See $FND_TOP/sql/afffckff.sql
--
-- ===========================================================================
-- Rules : A.01, A.07, A.10, A.11, A.12, D.01
--
PROCEDURE fix_kff_flx(p_rule                         IN VARCHAR2,
                      p_application_id               IN NUMBER,
                      p_id_flex_code                 IN VARCHAR2,
                      x_message                      OUT nocopy VARCHAR2);

-- ===========================================================================
-- Rules : B.03, B.04, E.01, E.02, K.01, K.02
--
PROCEDURE fix_kff_str(p_rule                         IN VARCHAR2,
                      p_application_id               IN NUMBER,
                      p_id_flex_code                 IN VARCHAR2,
                      p_id_flex_num                  IN NUMBER,
                      x_message                      OUT nocopy VARCHAR2);

-- ===========================================================================
-- Rules : C.03, C.06, C.07, C.08
--
PROCEDURE fix_kff_seg(p_rule                         IN VARCHAR2,
                      p_application_id               IN NUMBER,
                      p_id_flex_code                 IN VARCHAR2,
                      p_id_flex_num                  IN NUMBER,
                      p_application_column_name      IN VARCHAR2,
                      x_message                      OUT nocopy VARCHAR2);

-- ===========================================================================
-- Rules : F.01, F.02
--
PROCEDURE fix_kff_sha(p_rule                         IN VARCHAR2,
                      p_application_id               IN NUMBER,
                      p_id_flex_code                 IN VARCHAR2,
                      p_id_flex_num                  IN NUMBER,
                      p_alias_name                   IN VARCHAR2,
                      x_message                      OUT nocopy VARCHAR2);

-- ===========================================================================
-- Rules : G.03, G.04, G.05, G.07
--
PROCEDURE fix_kff_cvr(p_rule                         IN VARCHAR2,
                      p_application_id               IN NUMBER,
                      p_id_flex_code                 IN VARCHAR2,
                      p_id_flex_num                  IN NUMBER,
                      p_flex_validation_rule_name    IN VARCHAR2,
                      x_message                      OUT nocopy VARCHAR2);

-- ===========================================================================
-- Rules : H.01, H.02, I.01, J.01
--
PROCEDURE fix_kff_cvl(p_rule                         IN VARCHAR2,
                      p_application_id               IN NUMBER,
                      p_id_flex_code                 IN VARCHAR2,
                      p_id_flex_num                  IN NUMBER,
                      p_flex_validation_rule_name    IN VARCHAR2,
                      p_rule_line_id                 IN NUMBER,
                      x_message                      OUT nocopy VARCHAR2);

-- ===========================================================================
-- Rules : G.06, H.03
--
PROCEDURE fix_kff_cvrls(p_rule                         IN VARCHAR2,
                        x_message                      OUT nocopy VARCHAR2);


-- ===========================================================================
-- Rules : L.01, L.02
--
PROCEDURE fix_kff_flq(p_rule                         IN VARCHAR2,
                      p_application_id               IN NUMBER,
                      p_id_flex_code                 IN VARCHAR2,
                      p_segment_attribute_type       IN VARCHAR2,
                      x_message                      OUT nocopy VARCHAR2);

-- ===========================================================================
-- Rules : M.01, M.02, M.03, M.04
--
PROCEDURE fix_kff_qlv(p_rule                         IN VARCHAR2,
                      p_application_id               IN NUMBER,
                      p_id_flex_code                 IN VARCHAR2,
                      p_id_flex_num                  IN NUMBER,
                      p_application_column_name      IN VARCHAR2,
                      p_segment_attribute_type       IN VARCHAR2,
                      x_message                      OUT nocopy VARCHAR2);

-- ===========================================================================
-- Rules : N.03, N.06, N.07
--
PROCEDURE fix_kff_sgq(p_rule                         IN VARCHAR2,
                      p_application_id               IN NUMBER,
                      p_id_flex_code                 IN VARCHAR2,
                      p_segment_attribute_type       IN VARCHAR2,
                      p_value_attribute_type         IN VARCHAR2,
                      x_message                      OUT nocopy VARCHAR2);

-- ===========================================================================
-- Rules : O.01, O.02
--
PROCEDURE fix_kff_fvq(p_rule                         IN VARCHAR2,
                      p_id_flex_application_id       IN NUMBER,
                      p_id_flex_code                 IN VARCHAR2,
                      p_segment_attribute_type       IN VARCHAR2,
                      p_value_attribute_type         IN VARCHAR2,
                      p_flex_value_set_id            IN NUMBER,
                      x_message                      OUT nocopy VARCHAR2);

-- ===========================================================================
-- Rules : P.01, P.02, P.03, P.04
--
PROCEDURE fix_kff_col(p_rule                         IN VARCHAR2,
                      p_application_id               IN NUMBER,
                      p_table_name                   IN VARCHAR2,
                      p_column_name                  IN VARCHAR2,
                      x_message                      OUT nocopy VARCHAR2);

-- ===========================================================================
-- Rules : R.01, R.02
--
PROCEDURE fix_kff_fwp(p_rule                         IN VARCHAR2,
                      p_application_id               IN NUMBER,
                      p_id_flex_code                 IN VARCHAR2,
                      p_id_flex_num                  IN NUMBER,
                      p_wf_item_type                 IN VARCHAR2,
                      x_message                      OUT nocopy VARCHAR2);

END fnd_flex_diagnose;

/

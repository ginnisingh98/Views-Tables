--------------------------------------------------------
--  DDL for Package FND_FLEX_UPGRADE_UTILITIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_FLEX_UPGRADE_UTILITIES" AUTHID CURRENT_USER AS
/* $Header: AFFFUPUS.pls 120.3.12010000.1 2008/07/25 14:14:38 appldev ship $ */


bad_parameter EXCEPTION;
PRAGMA EXCEPTION_INIT(bad_parameter, -06501);

-- ======================================================================
-- Function Return Codes
-- ======================================================================
g_ret_no_error              NUMBER := 0;
g_ret_critical_error        NUMBER := 1;
g_ret_ignored_errors        NUMBER := 2;
g_ret_date_conversion_error NUMBER := 3;
g_ret_no_need_to_clone      NUMBER := 4;
g_ret_already_cloned        NUMBER := 5;
g_ret_new_vset_exists       NUMBER := 6;


-- NO-ERROR              : Succesfull operation.
-- CRITICAL-ERROR        : Call get_message function.
-- IGNORED-ERRORS        : Some errors occured, but they are ignored.
--                         Must call get_message.
-- DATE-CONVERSION-ERROR : Function is succesfull, however there were some
--                         date value corruptions and conversion errors.
-- Ex. : to_char(to_date('01-JA-98','DD-MON-RR'),'YYYY/MM/YY HH24:MI:SS')
-- In this case to_date function will fail. These cases will be reported in
-- message, function will not stop for these errors. It will try to convert
-- as much as possible. Call get_message to see those errors.
-- NO-NEED-TO-CLONE      : You passed a value set other than 'D' or 'T'.
-- ALREADY-CLONED        : Old date value set was already cloned.
-- NEW-VSET-EXISTS       : New Value Set Already Exists with a different
--                         format type or maximum size.
--



-- ======================================================================
-- Messaging
-- ======================================================================
-- All errors will be reported in message.
-- Final successfull operations are also reported.
--
FUNCTION get_message RETURN VARCHAR2;

PROCEDURE set_messaging(p_flag IN BOOLEAN DEFAULT TRUE);


-- ======================================================================
-- Function : clone_date_vset
-- ======================================================================
-- Will create a clone of old value set.
-- Sub entities are not cloned. (i.e. values for indep/dep vasets,
-- hierarchies, etc...)
-- format_type and maximum_size will be changed as;
--
-- Date (D)(9,11)             -> Standard Date (X)(11)
-- Date-Time (T)(15,17,18,20) -> Standard Date-Time (Y)(20)
--
--
-- Return Codes : See Function Return Codes.
--
FUNCTION clone_date_vset
  (p_old_value_set_name    IN VARCHAR2,
   p_new_value_set_name    IN VARCHAR2,
   p_session_mode          IN VARCHAR2 DEFAULT 'customer_data')
  RETURN NUMBER;

-- ======================================================================
-- Function : upgrade_date_report_parameters
-- ======================================================================
-- Modifies Report Parameters.
-- All report parameters which are owned by p_appl_short_name application and
-- has p_value_set_from as validation value set will be updated to use
-- p_value_set_to as validation value set.
--
-- p_appl_short_name  : owner application.
-- p_value_set_from   : old type date/time value set.
-- p_value_set_to     : new (standard) type date/time value set.
-- p_session_mode     : 'seed_data' or 'customer_data' (for who columns.)
-- p_report_name_like : If passed, only this report parameters will be
--                      modified.
-- AND descriptive_flexfield_name LIKE '$SRS$.' || p_report_name_like
-- condition will be used in the query.
--
-- Return Codes : See Function Return Codes.
--
FUNCTION upgrade_date_report_parameters
  (p_appl_short_name  IN VARCHAR2,
   p_value_set_from   IN VARCHAR2,
   p_value_set_to     IN VARCHAR2,
   p_session_mode     IN VARCHAR2 DEFAULT 'customer_data',
   p_report_name_like IN VARCHAR2 DEFAULT '%')
  RETURN NUMBER;

-- ======================================================================
-- Function : upgrade_date_dff_segments
-- ======================================================================
-- Will upgrade Descriptive Flexfield Segments.
-- Transaction data should be upgraded by FNDFFUPG conc. program.
--
FUNCTION upgrade_date_dff_segments
  (p_appl_short_name   IN VARCHAR2,
   p_value_set_from    IN VARCHAR2,
   p_value_set_to      IN VARCHAR2,
   p_session_mode      IN VARCHAR2 DEFAULT 'customer_data',
   p_dff_name_like     IN VARCHAR2 DEFAULT '%',
   p_context_code_like IN VARCHAR2 DEFAULT '%')
  RETURN NUMBER;

-- ======================================================================
-- Function : upgrade_date_kff_segments
-- ======================================================================
-- Will upgrade Key Flexfield Segments.
-- Transaction data should be upgraded by FNDFFUPG conc. program.
--
FUNCTION upgrade_date_kff_segments
  (p_appl_short_name  IN VARCHAR2,
   p_id_flex_code     IN VARCHAR2,
   p_value_set_from   IN VARCHAR2,
   p_value_set_to     IN VARCHAR2,
   p_session_mode     IN VARCHAR2 DEFAULT 'customer_data',
   p_struct_num_like  IN VARCHAR2 DEFAULT '%',
   p_struct_name_like IN VARCHAR2 DEFAULT '%')
  RETURN NUMBER;

-- ======================================================================
-- Function : upgrade_vset_to_translatable
-- ======================================================================
-- Will convert vset to Translatable validation.
--
FUNCTION upgrade_vset_to_translatable
  (p_vset_name        IN VARCHAR2,
   p_session_mode     IN VARCHAR2 DEFAULT 'customer_data')
  RETURN NUMBER;


-- ======================================================================
-- NUMBER and DATE UPGRADES
-- ======================================================================
-- These functions can only be called from FNDFFUPG conc. program.
--
--
-- ======================================================================
-- Procedure : cp_init
-- ======================================================================
-- Used to init following settings.
-- 'SESSION_MODE'
-- 'NLS_NUMERIC_CHARACTERS'
--
PROCEDURE cp_init(p_param_name IN VARCHAR2,
                  p_param_value IN VARCHAR2);

-- ======================================================================
-- Procedure : cp_upgrade_value_set
-- ======================================================================
-- Upgrades Number and Date value set.
--
PROCEDURE cp_upgrade_value_set(p_flex_value_set_type IN VARCHAR2,
                               p_flex_value_set_name IN VARCHAR2);


-- ======================================================================
-- Procedure : cp_srs_upgrade_date_all
-- ======================================================================
-- Upgrades All Standard Date Value Sets. (called from SRS.)
--
PROCEDURE cp_srs_upgrade_date_all(errbuf  OUT nocopy VARCHAR2,
                                  retcode OUT nocopy VARCHAR2);


-- ======================================================================
-- Procedure : cp_srs_upgrade_number_all
-- ======================================================================
-- Upgrades All Number Value Sets. (called from SRS.)
--
PROCEDURE cp_srs_upgrade_number_all(errbuf                   OUT nocopy VARCHAR2,
                                    retcode                  OUT nocopy VARCHAR2,
                                    p_nls_numeric_characters IN VARCHAR2);


-- ======================================================================
-- Procedure : cp_srs_upgrade_date_one
-- ======================================================================
-- Upgrades One Standard Date or Standard DateTime Value Set.(called from SRS.)
--
PROCEDURE cp_srs_upgrade_date_one(errbuf                OUT nocopy VARCHAR2,
                                  retcode               OUT nocopy VARCHAR2,
                                  p_flex_value_set_name IN VARCHAR2);


-- ======================================================================
-- Procedure : cp_srs_upgrade_number_one
-- ======================================================================
-- Upgrades One Number Value Set. (called from SRS.)
--
PROCEDURE cp_srs_upgrade_number_one(errbuf                   OUT nocopy VARCHAR2,
                                    retcode                  OUT nocopy VARCHAR2,
                                    p_flex_value_set_name    IN VARCHAR2,
                                    p_nls_numeric_characters IN VARCHAR2);

-- ======================================================================
-- Procedure : cp_srs_list_date_usages
-- ======================================================================
-- Lists Date and DateTime Value Set Usages. (called from SRS.)
--
PROCEDURE cp_srs_list_date_usages(errbuf                   OUT nocopy VARCHAR2,
                                  retcode                  OUT nocopy VARCHAR2);



-- ======================================================================
-- Procedure : cp_srs_clone_date_vset
-- ======================================================================
-- Clones a Date or DateTime Value Set. (called from SRS.)
--
PROCEDURE cp_srs_clone_date_vset(errbuf               OUT nocopy VARCHAR2,
                                 retcode              OUT nocopy VARCHAR2,
                                 p_old_value_set_name IN VARCHAR2,
                                 p_new_value_set_name IN VARCHAR2);



-- ======================================================================
-- Procedure : afffupg1_get_prompt
-- ======================================================================
-- From $FND_TOP/sql/afffupg1.sql.
--
PROCEDURE afffupg1_get_prompt(p_menu_choice           IN NUMBER,
                              p_step                  IN NUMBER,
                              x_prompt                OUT nocopy VARCHAR2);



-- ======================================================================
-- Procedure : afffupg1_data_upgrade
-- ======================================================================
-- From $FND_TOP/sql/afffupg1.sql.
--
PROCEDURE afffupg1_data_upgrade(p_menu_choice         IN NUMBER,
                                p_param1              IN VARCHAR2,
                                p_param2              IN VARCHAR2,
                                p_param3              IN VARCHAR2,
                                p_param4              IN VARCHAR2,
                                p_param5              IN VARCHAR2,
                                p_param6              IN VARCHAR2,
                                x_prompt              IN OUT nocopy VARCHAR2);

END fnd_flex_upgrade_utilities;

/

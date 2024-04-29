--------------------------------------------------------
--  DDL for Package Body PAY_JP_DATA_MIGRATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_JP_DATA_MIGRATION_PKG" AS
/* $Header: pyjpdatamig.pkb 120.10 2008/06/20 13:52:53 keyazawa noship $ */
--
-- Global Utils
g_pkg    VARCHAR2(30) := 'pay_jp_data_migration_pkg';
g_traces BOOLEAN := hr_utility.debug_enabled; --See if hr_utility.traces should be output
g_dbg    BOOLEAN := FALSE; --Used for diagnosing issues by dev, more outputs
--
-- |-------------------------------------------------------------------|
-- |---------------------< migrate_input_values >----------------------|
-- |-------------------------------------------------------------------|
--
procedure migrate_input_values is
--
  type t_jp_input_names_tab is table of VARCHAR2(200) index by binary_integer;

  type t_input_names_tab is table of pay_input_values_f.name%TYPE index by binary_integer;

  l_jp_input_names_tab  t_jp_input_names_tab;
  l_input_names_tab     t_input_names_tab;

  l_proc                VARCHAR2(50) := g_pkg||'.migrate_input_values';

BEGIN

  l_jp_input_names_tab.DELETE;
  l_input_names_tab.DELETE;

  hr_utility.set_location(l_proc, 10);

  l_jp_input_names_tab(1) := '32E59B9EE79BAEE4BBA5E9998DE381AEE7A88EE9A18D';
  l_input_names_tab(1) := 'SUBSEQUENT_TAX';

  l_jp_input_names_tab(2) := 'E38395E382A1E382A4E383ABE794A8EFBCBFE4B88AE69BB8E3818D';
  l_input_names_tab(2) := 'OVERRIDE_FOR_FILE_FLAG';

  l_jp_input_names_tab(3) := 'E38395E382A1E382A4E383ABE794A8EFBCBFE69198E8A681E6AC84';
  l_input_names_tab(3) := 'DESC_FIELD_FOR_FILE';

  l_jp_input_names_tab(4) := 'E38395E382A1E382A4E383ABE794A8EFBCBFE69198E8A681E6AC8432';
  l_input_names_tab(4) := 'DESC_FIELD2_FOR_FILE';

  l_jp_input_names_tab(5) := 'E38395E382A1E382A4E383ABE794A8EFBCBFE69198E8A681E6AC8433';
  l_input_names_tab(5) := 'DESC_FIELD3_FOR_FILE';

  l_jp_input_names_tab(6) := 'E38395E382A1E382A4E383ABE794A8EFBCBFE69198E8A681E6AC8434';
  l_input_names_tab(6) := 'DESC_FIELD4_FOR_FILE';

  l_jp_input_names_tab(7) := 'E38395E382A1E382A4E383ABE794A8EFBCBFE69198E8A681E6AC8435';
  l_input_names_tab(7) := 'DESC_FIELD5_FOR_FILE';

  l_jp_input_names_tab(8) := 'E4B880E68BACE5BEB4E58F8EE58CBAE58886';
  l_input_names_tab(8) := 'LUMP_SUM_WITHHOLD_METHOD';

  l_jp_input_names_tab(9) := 'E4B880E888ACE381AEE7949FE591BDE4BF9DE999BAE69699';
  l_input_names_tab(9) := 'GEN_LIFE_INS_PREM';

  l_jp_input_names_tab(10) := 'E4B880E888ACE68EA7E999A4E5AFBEE8B1A1E9858DE581B6E88085E68EA7E999A4E9A18D';
  l_input_names_tab(10) := 'GEN_SPOUSE_EXM';

  l_jp_input_names_tab(11) := 'E4B880E888ACE99A9CE5AEB3E88085';
  l_input_names_tab(11) := 'NUM_OF_GEN_DISABLED';

  l_jp_input_names_tab(12) := 'E4B880E888ACE99A9CE5AEB3E88085E68EA7E999A4E9A18D';
  l_input_names_tab(12) := 'GEN_DISABLED_EXM';

  l_jp_input_names_tab(13) := 'E4B880E888ACE689B6E9A48AE68EA7E999A4E9A18D';
  l_input_names_tab(13) := 'GEN_DEP_EXM';

  l_jp_input_names_tab(14) := 'E9818BE8B383E79BB8E5BD93E9A18D';
  l_input_names_tab(14) := 'FARE_EQUIVALENT_AMT';

  l_jp_input_names_tab(15) := 'E5AFA1E5A9A6E58CBAE58886';
  l_input_names_tab(15) := 'WIDOW_TYPE';

  l_jp_input_names_tab(16) := 'E5AFA1E5A9A6E68EA7E999A4E9A18D';
  l_input_names_tab(16) := 'WIDOW_EXM';

  l_jp_input_names_tab(17) := 'E8AAB2E7A88EE5AFBEE8B1A1E9A18D';
  l_input_names_tab(17) := 'TXBL_ERN';

  l_jp_input_names_tab(18) := 'E9818EE4B88DE8B6B3E7A88EE9A18D';
  l_input_names_tab(18) := 'YEA_ITX';

  l_jp_input_names_tab(19) := 'E4BB8BE4BF9DE4BA8BE6A5ADE4B8BBE98080E881B7E69C88E58886E4BF9DE999BAE69699';
  l_input_names_tab(19) := 'CI_PREM_ER_TRM';

  l_jp_input_names_tab(20) := 'E4BB8BE4BF9DE4BA8BE6A5ADE4B8BBE58886E4BF9DE999BAE69699';
  l_input_names_tab(20) := 'CI_PREM_ER';

  l_jp_input_names_tab(21) := 'E4BB8BE4BF9DE789B9E5AE9AE8A2ABE4BF9DE999BAE88085';
  l_input_names_tab(21) := 'CI_SPECIFIC_INSURED_FLAG';

  l_jp_input_names_tab(22) := 'E4BB8BE4BF9DE8A2ABE4BF9DE999BAE88085E98080E881B7E69C88E58886E4BF9DE999BAE69699';
  l_input_names_tab(22) := 'CI_PREM_EE_TRM';

  l_jp_input_names_tab(23) := 'E4BB8BE4BF9DE8A2ABE4BF9DE999BAE88085E58886E4BF9DE999BAE69699';
  l_input_names_tab(23) := 'CI_PREM_EE';

  l_jp_input_names_tab(24) := 'E694B9E5AE9AE6A899E6BA96E5A0B1E985ACE69C88E9A18D';
  l_input_names_tab(24) := 'REVISED_SMR';

  l_jp_input_names_tab(25) := 'E694B9E5AE9AE5A0B1E985AC';
  l_input_names_tab(25) := 'REVISED_MR';

  l_jp_input_names_tab(26) := 'E9968BE5A78BE697A5';
  l_input_names_tab(26) := 'START_DATE';

  l_jp_input_names_tab(27) := 'E5A496E59BBDE4BABA';
  l_input_names_tab(27) := 'FOREIGNER_FLAG';

  l_jp_input_names_tab(28) := 'E59FBAE98791E58AA0E585A5E593A1E795AAE58FB7';
  l_input_names_tab(28) := 'WPF_MEMBERS_NUM';

  l_jp_input_names_tab(29) := 'E59FBAE98791E4BA8BE6A5ADE4B8BBE98080E881B7E69C88E58886E4BF9DE999BAE69699';
  l_input_names_tab(29) := 'WPF_PREM_ER_TRM';

  l_jp_input_names_tab(30) := 'E59FBAE98791E4BA8BE6A5ADE4B8BBE58886E4BF9DE999BAE69699';
  l_input_names_tab(30) := 'WPF_PREM_ER';

  l_jp_input_names_tab(31) := 'E59FBAE98791E4BA8BE6A5ADE68980';
  l_input_names_tab(31) := 'WPF_LOCATION';

  l_jp_input_names_tab(32) := 'E59FBAE98791E587A6E79086';
  l_input_names_tab(32) := 'WPF_PROC_FLAG';

  l_jp_input_names_tab(33) := 'E59FBAE98791E8A2ABE4BF9DE999BAE88085E98080E881B7E69C88E58886E4BF9DE999BAE69699';
  l_input_names_tab(33) := 'WPF_PREM_EE_TRM';

  l_jp_input_names_tab(34) := 'E59FBAE98791E8A2ABE4BF9DE999BAE88085E58886E4BF9DE999BAE69699';
  l_input_names_tab(34) := 'WPF_PREM_EE';

  l_jp_input_names_tab(35) := 'E59FBAE7A48EE68EA7E999A4E9A18D';
  l_input_names_tab(35) := 'BASIC_EXM';

  l_jp_input_names_tab(36) := 'E59FBAE7A48EE5B9B4E98791E795AAE58FB7';
  l_input_names_tab(36) := 'BASIC_PENSION_NUM';

  l_jp_input_names_tab(37) := 'E69C9FE99693';
  l_input_names_tab(37) := 'PERIOD';

  l_jp_input_names_tab(38) := 'E7B5A6E4B88EE9968BE5A78BE69C88';
  l_input_names_tab(38) := 'PAYROLL_START_MTH';

  l_jp_input_names_tab(39) := 'E7B5A6E4B88EE68EA7E999A4E5808BE4BABAE5B9B4E98791E4BF9DE999BAE69699';
  l_input_names_tab(39) := 'SAL_DCT_INDIVIDUAL_PENSION_PREM';

  l_jp_input_names_tab(40) := 'E7B5A6E4B88EE68EA7E999A4E7A4BEE4BC9AE4BF9DE999BAE69699';
  l_input_names_tab(40) := 'SAL_DCT_SI_PREM';

  l_jp_input_names_tab(41) := 'E7B5A6E4B88EE68EA7E999A4E5B08FE8A68FE6A8A1E4BC81E6A5ADE585B1E6B888E7AD89E68E9BE98791';
  l_input_names_tab(41) := 'SAL_DCT_SMALL_COMPANY_MUTUAL_AID_PREM';

  l_jp_input_names_tab(42) := 'E7B5A6E4B88EE68EA7E999A4E7949FE591BDE4BF9DE999BAE69699';
  l_input_names_tab(42) := 'SAL_DCT_LIFE_INS_PREM';

  l_jp_input_names_tab(43) := 'E7B5A6E4B88EE68EA7E999A4E79FADE69C9FE6908DE5AEB3E4BF9DE999BAE69699';
  l_input_names_tab(43) := 'SAL_DCT_SHORT_TERM_NONLIFE_INS_PREM';

  l_jp_input_names_tab(44) := 'E7B5A6E4B88EE68EA7E999A4E995B7E69C9FE6908DE5AEB3E4BF9DE999BAE69699';
  l_input_names_tab(44) := 'SAL_DCT_LONG_TERM_NONLIFE_INS_PREM';

  l_jp_input_names_tab(45) := 'E7B5A6E4B88EE7B582E4BA86E69C88';
  l_input_names_tab(45) := 'PAYROLL_END_MTH';

  l_jp_input_names_tab(46) := 'E7B5A6E4B88EE68980E5BE97';
  l_input_names_tab(46) := 'EMP_INCOME';

  l_jp_input_names_tab(47) := 'E7B5A6E4B88EE68980E5BE97E68EA7E999A4E5BE8CE381AEE98791E9A18D';
  l_input_names_tab(47) := 'AMT_AFTER_EMP_INCOME_DCT';

  l_jp_input_names_tab(48) := 'E7B5A6E4B88EE4BD93E7B3BBE5A489E69BB4';
  l_input_names_tab(48) := 'SAL_STRUCTURE_CHANGE';

  l_jp_input_names_tab(49) := 'E5B185E4BD8FE9968BE5A78BE697A5';
  l_input_names_tab(49) := 'RES_START_DATE';

  l_jp_input_names_tab(50) := 'E5B185E4BD8FE88085E381ABE381AAE3828BE697A5';
  l_input_names_tab(50) := 'PROJECTED_RES_DATE';

  l_jp_input_names_tab(51) := 'E8B79DE99BA2';
  l_input_names_tab(51) := 'DISTANCE';

  l_jp_input_names_tab(52) := 'E58BA4E7B69AE5B9B4E695B0';
  l_input_names_tab(52) := 'SERVICE_YEARS';

  l_jp_input_names_tab(53) := 'E58BA4E58AB4E5ADA6E7949FE58CBAE58886';
  l_input_names_tab(53) := 'WORKING_STUDENT_TYPE';

  l_jp_input_names_tab(54) := 'E58BA4E58AB4E5ADA6E7949FE68EA7E999A4E9A18D';
  l_input_names_tab(54) := 'WORKING_STUDENT_EXM';

  l_jp_input_names_tab(55) := 'E98791E9A18D';
  l_input_names_tab(55) := 'CMA_AMT';

  l_jp_input_names_tab(56) := 'E98791E98AAD';
  l_input_names_tab(56) := 'ERN_MONEY';

  l_jp_input_names_tab(57) := 'E98791E98AAD31E69C88E5898D';
  l_input_names_tab(57) := 'ERN_MONEY_1MTH_AGO';

  l_jp_input_names_tab(58) := 'E98791E98AAD32E69C88E5898D';
  l_input_names_tab(58) := 'ERN_MONEY_2MTH_AGO';

  l_jp_input_names_tab(59) := 'E98791E98AAD33E69C88E5898D';
  l_input_names_tab(59) := 'ERN_MONEY_3MTH_AGO';

  l_jp_input_names_tab(60) := 'E98791E98AAD34E69C88';
  l_input_names_tab(60) := 'ERN_MONEY_APR';

  l_jp_input_names_tab(61) := 'E98791E98AAD35E69C88';
  l_input_names_tab(61) := 'ERN_MONEY_MAY';

  l_jp_input_names_tab(62) := 'E98791E98AAD36E69C88';
  l_input_names_tab(62) := 'ERN_MONEY_JUN';

  l_jp_input_names_tab(63) := 'E98791E98AAD37E69C88';
  l_input_names_tab(63) := 'ERN_MONEY_JUL';

  l_jp_input_names_tab(64) := 'E7B58CE794B1';
  l_input_names_tab(64) := 'VIA';

  l_jp_input_names_tab(65) := 'E69C88EFBCBFE59BBAE5AE9AE79A84E8B383E98791';
  l_input_names_tab(65) := 'GEP_FIXED_WAGE';

  l_jp_input_names_tab(66) := 'E69C88EFBCBFE5A0B1E985ACE69C88E9A18D';
  l_input_names_tab(66) := 'GEP_MR';

  l_jp_input_names_tab(67) := 'E69C88E5A489EFBCBFE7B590E69E9CEFBCBFE59BBAE5AE9AE79A84E8B383E9879133E69C88E5898D';
  l_input_names_tab(67) := 'GEP_RSLT_FIXED_WAGE_3MTH_AGO';

  l_jp_input_names_tab(68) := 'E69C88E5A489EFBCBFE7B590E69E9CEFBCBFE59BBAE5AE9AE79A84E8B383E9879134E69C88E5898D';
  l_input_names_tab(68) := 'GEP_RSLT_FIXED_WAGE_4MTH_AGO';

  l_jp_input_names_tab(69) := 'E69C88E5A489EFBCBFE59BBAE5AE9AE79A84E8B383E9879131E69C88E5898D';
  l_input_names_tab(69) := 'GEP_FIXED_WAGE_1MTH_AGO';

  l_jp_input_names_tab(70) := 'E69C88E5A489EFBCBFE59BBAE5AE9AE79A84E8B383E9879132E69C88E5898D';
  l_input_names_tab(70) := 'GEP_FIXED_WAGE_2MTH_AGO';

  l_jp_input_names_tab(71) := 'E69C88E5A489EFBCBFE59BBAE5AE9AE79A84E8B383E9879133E69C88E5898D';
  l_input_names_tab(71) := 'GEP_FIXED_WAGE_3MTH_AGO';

  l_jp_input_names_tab(72) := 'E69C88E5A489E4BA88E5AE9AE69C88';
  l_input_names_tab(72) := 'GEP_MTH';

  l_jp_input_names_tab(73) := 'E581A5E5BAB7E4BF9DE999BAE69699';
  l_input_names_tab(73) := 'HI_PREM';

  l_jp_input_names_tab(74) := 'E581A5E5BAB7E4BF9DE999BAE69699EFBCBFE4BA8BE6A5ADE4B8BB';
  l_input_names_tab(74) := 'HI_PREM_ER';

  l_jp_input_names_tab(75) := 'E581A5E4BF9D';
  l_input_names_tab(75) := 'HI';

  l_jp_input_names_tab(76) := 'E581A5E4BF9DE59088E7AE97E5AFBEE8B1A1E98791E98AAD';
  l_input_names_tab(76) := 'HI_ERN_MONEY_SUBJ_SI_ACMLT';

  l_jp_input_names_tab(77) := 'E581A5E4BF9DE59088E7AE97E5AFBEE8B1A1E78FBEE789A9';
  l_input_names_tab(77) := 'HI_ERN_KIND_SUBJ_SI_ACMLT';

  l_jp_input_names_tab(78) := 'E581A5E4BF9DE4BA8BE6A5ADE4B8BBE58886E4BF9DE999BAE69699';
  l_input_names_tab(78) := 'HI_PREM_ER';

  l_jp_input_names_tab(79) := 'E581A5E4BF9DE4BA8BE6A5ADE68980';
  l_input_names_tab(79) := 'HI_LOCATION';

  l_jp_input_names_tab(80) := 'E581A5E4BF9DE8A2ABE4BF9DE999BAE88085E8A8BCE795AAE58FB7';
  l_input_names_tab(80) := 'HI_CARD_NUM';

  l_jp_input_names_tab(81) := 'E581A5E4BF9DE8A2ABE4BF9DE999BAE88085E58886E4BF9DE999BAE69699';
  l_input_names_tab(81) := 'HI_PREM_EE';

  l_jp_input_names_tab(82) := 'E6BA90E6B389E5BEB4E58F8EE7A88EE9A18D';
  l_input_names_tab(82) := 'WITHHOLD_TAX';

  l_jp_input_names_tab(83) := 'E78FBEE789A9';
  l_input_names_tab(83) := 'ERN_KIND';

  l_jp_input_names_tab(84) := 'E78FBEE789A931E69C88E5898D';
  l_input_names_tab(84) := 'ERN_KIND_1MTH_AGO';

  l_jp_input_names_tab(85) := 'E78FBEE789A932E69C88E5898D';
  l_input_names_tab(85) := 'ERN_KIND_2MTH_AGO';

  l_jp_input_names_tab(86) := 'E78FBEE789A933E69C88E5898D';
  l_input_names_tab(86) := 'ERN_KIND_3MTH_AGO';

  l_jp_input_names_tab(87) := 'E78FBEE789A934E69C88';
  l_input_names_tab(87) := 'ERN_KIND_APR';

  l_jp_input_names_tab(88) := 'E78FBEE789A935E69C88';
  l_input_names_tab(88) := 'ERN_KIND_MAY';

  l_jp_input_names_tab(89) := 'E78FBEE789A936E69C88';
  l_input_names_tab(89) := 'ERN_KIND_JUN';

  l_jp_input_names_tab(90) := 'E78FBEE789A937E69C88';
  l_input_names_tab(90) := 'ERN_KIND_JUL';

  l_jp_input_names_tab(91) := 'E78FBEE789A9E8AAB2E7A88EE9A18D';
  l_input_names_tab(91) := 'TXBL_ERN_KIND';

  l_jp_input_names_tab(92) := 'E78FBEE789A9E58886E8AAB2E7A88EE5AFBEE8B1A1E9A18D';
  l_input_names_tab(92) := 'TXBL_ERN_KIND';

  l_jp_input_names_tab(93) := 'E78FBEE789A9E58886E99D9EE8AAB2E7A88EE5AFBEE8B1A1E9A18D';
  l_input_names_tab(93) := 'NTXBL_ERN_KIND';

  l_jp_input_names_tab(94) := 'E5808BE4BABAE5B9B4E98791E4BF9DE999BAE69699';
  l_input_names_tab(94) := 'INDIVIDUAL_PENSION_PREM';

  l_jp_input_names_tab(95) := 'E5808BE4BABAE795AAE58FB7';
  l_input_names_tab(95) := 'PERSONAL_NUM';

  l_jp_input_names_tab(96) := 'E59BBAE5AE9AE79A84E8B383E9879133E69C88E5898D';
  l_input_names_tab(96) := 'FIXED_WAGE_3MTH_AGO';

  l_jp_input_names_tab(97) := 'E59BBAE5AE9AE79A84E8B383E9879134E69C88E5898D';
  l_input_names_tab(97) := 'FIXED_WAGE_4MTH_AGO';

  l_jp_input_names_tab(98) := 'E99B87E4BF9DE58AA0E585A5E58CBAE58886';
  l_input_names_tab(98) := 'EI_TYPE';

  l_jp_input_names_tab(99) := 'E99B87E4BF9DE4BA8BE6A5ADE4B8BB';
  l_input_names_tab(99) := 'EI_LOCATION';

  l_jp_input_names_tab(100) := 'E99B87E4BF9DE5AFBEE8B1A1E9A18DE69C88E589B2E8AABFE695B4';
  l_input_names_tab(100) := 'MTHLY_ERN_SUBJ_EI_ADJ';

  l_jp_input_names_tab(101) := 'E99B87E4BF9DE8A2ABE4BF9DE999BAE88085E795AAE58FB7';
  l_input_names_tab(101) := 'EI_NUM';

  l_jp_input_names_tab(102) := 'E99B87E794A8E4BF9DE999BAE5AFBEE8B1A1E8B383E98791';
  l_input_names_tab(102) := 'ERN_SUBJ_EI';

  l_jp_input_names_tab(103) := 'E99B87E794A8E4BF9DE999BAE69699';
  l_input_names_tab(103) := 'EI_PREM';

  l_jp_input_names_tab(104) := 'E58E9AE7949FE5B9B4E98791E59FBAE98791E4BF9DE999BAE69699';
  l_input_names_tab(104) := 'WPF_PREM';

  l_jp_input_names_tab(105) := 'E58E9AE7949FE5B9B4E98791E59FBAE98791E4BF9DE999BAE69699EFBCBFE4BA8BE6A5ADE4B8BB';
  l_input_names_tab(105) := 'WPF_PREM_ER';

  l_jp_input_names_tab(106) := 'E58E9AE7949FE5B9B4E98791E4BF9DE999BAE69699';
  l_input_names_tab(106) := 'WP_PREM';

  l_jp_input_names_tab(107) := 'E58E9AE7949FE5B9B4E98791E4BF9DE999BAE69699EFBCBFE4BA8BE6A5ADE4B8BB';
  l_input_names_tab(107) := 'WP_PREM_ER';

  l_jp_input_names_tab(108) := 'E58E9AE5B9B4';
  l_input_names_tab(108) := 'WP';

  l_jp_input_names_tab(109) := 'E58E9AE5B9B4E59088E7AE97E5AFBEE8B1A1E98791E98AAD';
  l_input_names_tab(109) := 'WP_ERN_MONEY_SUBJ_SI_ACMLT';

  l_jp_input_names_tab(110) := 'E58E9AE5B9B4E59088E7AE97E5AFBEE8B1A1E78FBEE789A9';
  l_input_names_tab(110) := 'WP_ERN_KIND_SUBJ_SI_ACMLT';

  l_jp_input_names_tab(111) := 'E58E9AE5B9B4E4BA8BE6A5ADE4B8BBE98080E881B7E69C88E58886E4BF9DE999BAE69699';
  l_input_names_tab(111) := 'WP_PREM_ER_TRM';

  l_jp_input_names_tab(112) := 'E58E9AE5B9B4E4BA8BE6A5ADE4B8BBE58886E4BF9DE999BAE69699';
  l_input_names_tab(112) := 'WP_PREM_ER';

  l_jp_input_names_tab(113) := 'E58E9AE5B9B4E4BA8BE6A5ADE68980';
  l_input_names_tab(113) := 'WP_LOCATION';

  l_jp_input_names_tab(114) := 'E58E9AE5B9B4E6898BE5B8B3E8AAB2E68980E7ACA6E58FB7';
  l_input_names_tab(114) := 'WP_BOOK_OFFICE_NUM';

  l_jp_input_names_tab(115) := 'E58E9AE5B9B4E6898BE5B8B3E8A2ABE4BF9DE999BAE88085E795AAE58FB7';
  l_input_names_tab(115) := 'WP_BOOK_NUM';

  l_jp_input_names_tab(116) := 'E58E9AE5B9B4E587A6E79086';
  l_input_names_tab(116) := 'WP_PROC_FLAG';

  l_jp_input_names_tab(117) := 'E58E9AE5B9B4E695B4E79086E795AAE58FB7';
  l_input_names_tab(117) := 'WP_SERIAL_NUM';

  l_jp_input_names_tab(118) := 'E58E9AE5B9B4E8A2ABE4BF9DE999BAE88085E98080E881B7E69C88E58886E4BF9DE999BAE69699';
  l_input_names_tab(118) := 'WP_PREM_EE_TRM';

  l_jp_input_names_tab(119) := 'E58E9AE5B9B4E8A2ABE4BF9DE999BAE88085E58886E4BF9DE999BAE69699';
  l_input_names_tab(119) := 'WP_PREM_EE';

  l_jp_input_names_tab(120) := 'E68EA7E999A4E9A18D';
  l_input_names_tab(120) := 'DCT';

  l_jp_input_names_tab(121) := 'E59088E7AE97E5AFBEE8B1A1E4BB8BE4BF9DE4BA8BE6A5ADE4B8BBE58886E4BF9DE999BAE69699';
  l_input_names_tab(121) := 'CI_PREM_ER_ACMLT';

  l_jp_input_names_tab(122) := 'E59088E7AE97E5AFBEE8B1A1E4BB8BE4BF9DE8A2ABE4BF9DE999BAE88085E58886E4BF9DE999BAE69699';
  l_input_names_tab(122) := 'CI_PREM_EE_ACMLT';

  l_jp_input_names_tab(123) := 'E59088E7AE97E5AFBEE8B1A1E59FBAE98791E4BA8BE6A5ADE4B8BBE58886E4BF9DE999BAE69699';
  l_input_names_tab(123) := 'WPF_PREM_ER_ACMLT';

  l_jp_input_names_tab(124) := 'E59088E7AE97E5AFBEE8B1A1E59FBAE98791E8A2ABE4BF9DE999BAE88085E58886E4BF9DE999BAE69699';
  l_input_names_tab(124) := 'WPF_PREM_EE_ACMLT';

  l_jp_input_names_tab(125) := 'E59088E7AE97E5AFBEE8B1A1E581A5E4BF9DE4BA8BE6A5ADE4B8BBE58886E4BF9DE999BAE69699';
  l_input_names_tab(125) := 'HI_PREM_ER_ACMLT';

  l_jp_input_names_tab(126) := 'E59088E7AE97E5AFBEE8B1A1E581A5E4BF9DE8A2ABE4BF9DE999BAE88085E58886E4BF9DE999BAE69699';
  l_input_names_tab(126) := 'HI_PREM_EE_ACMLT';

  l_jp_input_names_tab(127) := 'E59088E7AE97E5AFBEE8B1A1E58E9AE5B9B4E4BA8BE6A5ADE4B8BBE58886E4BF9DE999BAE69699';
  l_input_names_tab(127) := 'WP_PREM_ER_ACMLT';

  l_jp_input_names_tab(128) := 'E59088E7AE97E5AFBEE8B1A1E58E9AE5B9B4E8A2ABE4BF9DE999BAE88085E58886E4BF9DE999BAE69699';
  l_input_names_tab(128) := 'WP_PREM_EE_ACMLT';

  l_jp_input_names_tab(129) := 'E59BBDE5A496E4BD8FE68980';
  l_input_names_tab(129) := 'FOREIGN_ADDRESS';

  l_jp_input_names_tab(130) := 'E59BBDE5B9B4E6898BE5B8B3E8AAB2E68980E7ACA6E58FB7';
  l_input_names_tab(130) := 'NP_BOOK_OFFICE_NUM';

  l_jp_input_names_tab(131) := 'E59BBDE5B9B4E6898BE5B8B3E8A2ABE4BF9DE999BAE88085E795AAE58FB7';
  l_input_names_tab(131) := 'NP_BOOK_NUM';

  l_jp_input_names_tab(132) := 'E59BBDE6B091E5B9B4E98791E4BF9DE999BAE69699';
  l_input_names_tab(132) := 'NATIONAL_PENSION_PREM';

  l_jp_input_names_tab(133) := 'E5B7AEE5BC95E8AAB2E7A88EE7B5A6E4B88EE68980E5BE97E98791E9A18D';
  l_input_names_tab(133) := 'NET_TXBL_INCOME';

  l_jp_input_names_tab(134) := 'E5B7AEE5BC95E694AFE7B5A6E9A18D';
  l_input_names_tab(134) := 'NET_ERN';

  l_jp_input_names_tab(135) := 'E5B7AEE5BC95E5B9B4E7A88EE9A18D';
  l_input_names_tab(135) := 'NET_ANNUAL_TAX';

  l_jp_input_names_tab(136) := 'E69C80E7B582E59B9EE381AEE694AFE68995E69C88';
  l_input_names_tab(136) := 'LAST_PAY_MTH';

  l_jp_input_names_tab(137) := 'E7AE97EFBCBFE5A0B1E985ACE69C88E9A18D';
  l_input_names_tab(137) := 'SAN_MR';

  l_jp_input_names_tab(138) := 'E7AE97E5AE9AE69C88E5A489EFBCBFE7B5A6E4B88EE98791E98AAD';
  l_input_names_tab(138) := 'SAN_GEP_SAL_ERN_MONEY';

  l_jp_input_names_tab(139) := 'E7AE97E5AE9AE69C88E5A489EFBCBFE7B5A6E4B88EE78FBEE789A9';
  l_input_names_tab(139) := 'SAN_GEP_SAL_ERN_KIND';

  l_jp_input_names_tab(140) := 'E7AE97E5AE9AE69C88E5A489EFBCBFE98791E98AAD31E69C88E5898D';
  l_input_names_tab(140) := 'SAN_GEP_ERN_MONEY_1MTH_AGO';

  l_jp_input_names_tab(141) := 'E7AE97E5AE9AE69C88E5A489EFBCBFE98791E98AAD32E69C88E5898D';
  l_input_names_tab(141) := 'SAN_GEP_ERN_MONEY_2MTH_AGO';

  l_jp_input_names_tab(142) := 'E7AE97E5AE9AE69C88E5A489EFBCBFE98791E98AAD33E69C88E5898D';
  l_input_names_tab(142) := 'SAN_GEP_ERN_MONEY_3MTH_AGO';

  l_jp_input_names_tab(143) := 'E7AE97E5AE9AE69C88E5A489EFBCBFE7B590E69E9CEFBCBFE4BFAEE6ADA3E5B9B3E59D87';
  l_input_names_tab(143) := 'SAN_GEP_RSLT_CORRECT_AVG';

  l_jp_input_names_tab(144) := 'E7AE97E5AE9AE69C88E5A489EFBCBFE7B590E69E9CEFBCBFE58D98E7B494E5B9B3E59D87';
  l_input_names_tab(144) := 'SAN_GEP_RSLT_SIMPLE_AVG';

  l_jp_input_names_tab(145) := 'E7AE97E5AE9AE69C88E5A489EFBCBFE7B590E69E9CEFBCBFE697A5E695B031E69C88E5898D';
  l_input_names_tab(145) := 'SAN_GEP_RSLT_DAYS_1MTH_AGO';

  l_jp_input_names_tab(146) := 'E7AE97E5AE9AE69C88E5A489EFBCBFE7B590E69E9CEFBCBFE697A5E695B032E69C88E5898D';
 	l_input_names_tab(146) := 'SAN_GEP_RSLT_DAYS_2MTH_AGO';

  l_jp_input_names_tab(147) := 'E7AE97E5AE9AE69C88E5A489EFBCBFE7B590E69E9CEFBCBFE697A5E695B033E69C88E5898D';
  l_input_names_tab(147) := 'SAN_GEP_RSLT_DAYS_3MTH_AGO';

  l_jp_input_names_tab(148) := 'E7AE97E5AE9AE69C88E5A489EFBCBFE78FBEE789A931E69C88E5898D';
  l_input_names_tab(148) := 'SAN_GEP_ERN_KIND_1MTH_AGO';

  l_jp_input_names_tab(149) := 'E7AE97E5AE9AE69C88E5A489EFBCBFE78FBEE789A932E69C88E5898D';
  l_input_names_tab(149) := 'SAN_GEP_ERN_KIND_2MTH_AGO';

  l_jp_input_names_tab(150) := 'E7AE97E5AE9AE69C88E5A489EFBCBFE78FBEE789A933E69C88E5898D';
  l_input_names_tab(150) := 'SAN_GEP_ERN_KIND_3MTH_AGO';

  l_jp_input_names_tab(151) := 'E7AE97E5AE9AE69C88E5A489EFBCBFE694AFE68995E59FBAE7A48EE697A5E695B0';
  l_input_names_tab(151) := 'SAN_GEP_PAY_BASE_DAYS';

  l_jp_input_names_tab(152) := 'E7AE97E5AE9AE69C88E5A489EFBCBFE694AFE68995E59FBAE7A48EE697A5E695B031E69C88E5898D';
  l_input_names_tab(152) := 'SAN_GEP_PAY_BASE_DAYS_1MTH_AGO';

  l_jp_input_names_tab(153) := 'E7AE97E5AE9AE69C88E5A489EFBCBFE694AFE68995E59FBAE7A48EE697A5E695B032E69C88E5898D';
  l_input_names_tab(153) := 'SAN_GEP_PAY_BASE_DAYS_2MTH_AGO';

  l_jp_input_names_tab(154) := 'E7AE97E5AE9AE69C88E5A489EFBCBFE694AFE68995E59FBAE7A48EE697A5E695B033E69C88E5898D';
  l_input_names_tab(154) := 'SAN_GEP_PAY_BASE_DAYS_3MTH_AGO';

  l_jp_input_names_tab(155) := 'E7AE97E5AE9AE69C88E5A489EFBCBFE4BFAEE6ADA3E5B9B3E59D87E588A4E588A5';
  l_input_names_tab(155) := 'SAN_GEP_CORRECT_AVG_FLAG';

  l_jp_input_names_tab(156) := 'E7AE97E5AE9AE69C88E5A489EFBCBFE789B9E588A5E8B39EE4B88EE98791E98AAD';
  l_input_names_tab(156) := 'SAN_GEP_SPB_ERN_MONEY';

  l_jp_input_names_tab(157) := 'E7AE97E5AE9AE69C88E5A489EFBCBFE789B9E588A5E8B39EE4B88EE78FBEE789A9';
  l_input_names_tab(157) := 'SAN_GEP_SPB_ERN_KIND';

  l_jp_input_names_tab(158) := 'E5B882E58CBAE794BAE69D91E382B3E383BCE38389';
  l_input_names_tab(158) := 'MUNICIPAL_CODE';

  l_jp_input_names_tab(159) := 'E5B882E58CBAE794BAE69D91E7A88EE9A18D';
  l_input_names_tab(159) := 'MUNICIPAL_TAX';

  l_jp_input_names_tab(160) := 'E694AFE7B5A6E8AAB2E7A88EE9A18D';
  l_input_names_tab(160) := 'TXBL_ERN';

  l_jp_input_names_tab(161) := 'E694AFE7B5A6E9A18D';
  l_input_names_tab(161) := 'ERN';

  l_jp_input_names_tab(162) := 'E694AFE7B5A6E9A18DE59088E8A888';
  l_input_names_tab(162) := 'ERN_SUM';

  l_jp_input_names_tab(163) := 'E694AFE68995E59FBAE7A48EE697A5E695B031E69C88E5898D';
  l_input_names_tab(163) := 'PAY_BASE_DAYS_1MTH_AGO';

  l_jp_input_names_tab(164) := 'E694AFE68995E59FBAE7A48EE697A5E695B032E69C88E5898D';
  l_input_names_tab(164) := 'PAY_BASE_DAYS_2MTH_AGO';

  l_jp_input_names_tab(165) := 'E694AFE68995E59FBAE7A48EE697A5E695B033E69C88E5898D';
  l_input_names_tab(165) := 'PAY_BASE_DAYS_3MTH_AGO';

  l_jp_input_names_tab(166) := 'E694AFE68995E59FBAE7A48EE697A5E695B034E69C88';
  l_input_names_tab(166) := 'PAY_BASE_DAYS_APR';

  l_jp_input_names_tab(167) := 'E694AFE68995E59FBAE7A48EE697A5E695B035E69C88';
  l_input_names_tab(167) := 'PAY_BASE_DAYS_MAY';

  l_jp_input_names_tab(168) := 'E694AFE68995E59FBAE7A48EE697A5E695B036E69C88';
  l_input_names_tab(168) := 'PAY_BASE_DAYS_JUN';

  l_jp_input_names_tab(169) := 'E694AFE68995E59FBAE7A48EE697A5E695B037E69C88';
  l_input_names_tab(169) := 'PAY_BASE_DAYS_JUL';

  l_jp_input_names_tab(170) := 'E694AFE68995E98791E9A18D';
  l_input_names_tab(170) := 'PAY_AMT';

  l_jp_input_names_tab(171) := 'E694AFE68995E696B9E6B395';
  l_input_names_tab(171) := 'PAY_METHOD';

  l_jp_input_names_tab(172) := 'E4BA8BE6A5ADE4B8BBE98080E881B7E69C88E58886E4BF9DE999BAE69699';
  l_input_names_tab(172) := 'INS_PREM_ER_TRM';

  l_jp_input_names_tab(173) := 'E4BA8BE6A5ADE4B8BBE58886E4BF9DE999BAE69699';
  l_input_names_tab(173) := 'WP_PREM_ER';

  l_jp_input_names_tab(174) := 'E4BA8BE794B1';
  l_input_names_tab(174) := 'REASON';

  l_jp_input_names_tab(175) := 'E7A4BEE4BC9AE4BF9DE999BAE5AFBEE8B1A1E8B383E98791EFBCBFE98791E98AAD';
  l_input_names_tab(175) := 'ERN_MONEY_SUBJ_SI';

  l_jp_input_names_tab(176) := 'E7A4BEE4BC9AE4BF9DE999BAE5AFBEE8B1A1E8B383E98791EFBCBFE78FBEE789A9';
  l_input_names_tab(176) := 'ERN_KIND_SUBJ_SI';

  l_jp_input_names_tab(177) := 'E7A4BEE4BC9AE4BF9DE999BAE69699';
  l_input_names_tab(177) := 'SI_PREM';

  l_jp_input_names_tab(178) := 'E7A4BEE4BC9AE4BF9DE999BAE69699E68EA7E999A4E5BE8CE381AEE98791E9A18D';
  l_input_names_tab(178) := 'AMT_AFTER_SI_PREM_DCT';

  l_jp_input_names_tab(179) := 'E7A4BEE4BC9AE4BF9DE999BAE69699E7AD89E68EA7E999A4E9A18D';
  l_input_names_tab(179) := 'SI_PREM_DCT';

  l_jp_input_names_tab(180) := 'E7A4BEE4BF9DE9968BE5A78BE69C88';
  l_input_names_tab(180) := 'SI_START_MTH';

  l_jp_input_names_tab(181) := 'E7A4BEE4BF9DE78FBEE789A9E58886E5AFBEE8B1A1E9A18D';
  l_input_names_tab(181) := 'ERN_KIND_SUBJ_SI';

  l_jp_input_names_tab(182) := 'E7A4BEE4BF9DE78FBEE789A9E58886E5AFBEE8B1A1E9A18DE3839EE382A4E3838AE382B9E8AABFE695B4';
  l_input_names_tab(182) := 'ERN_KIND_SUBJ_SI_NEGATIVE_ADJ';

  l_jp_input_names_tab(183) := 'E7A4BEE4BF9DE59BBAE5AE9AE79A84E8B383E98791';
  l_input_names_tab(183) := 'SI_FIXED_WAGE';

  l_jp_input_names_tab(184) := 'E7A4BEE4BF9DE5AFBEE8B1A1E9A18D';
  l_input_names_tab(184) := 'ERN_SUBJ_SI';

  l_jp_input_names_tab(185) := 'E7A4BEE4BF9DE5AFBEE8B1A1E9A18DE3839EE382A4E3838AE382B9E8AABFE695B4';
  l_input_names_tab(185) := 'ERN_SUBJ_SI_NEGATIVE_ADJ';

  l_jp_input_names_tab(186) := 'E8BB8AE4B8A1E68385E5A0B1';
  l_input_names_tab(186) := 'VEHICLE_INFO';

  l_jp_input_names_tab(187) := 'E58F96E5BE97E58CBAE58886';
  l_input_names_tab(187) := 'QUALIFY_TYPE';

  l_jp_input_names_tab(188) := 'E58F96E5BE97E4BA8BE794B1';
  l_input_names_tab(188) := 'QUALIFY_REASON';

  l_jp_input_names_tab(189) := 'E58F96E5BE97E697A5';
  l_input_names_tab(189) := 'QUALIFY_DATE';

  l_jp_input_names_tab(190) := 'E58F96E5BE97E5A489E69BB4E58CBAE58886';
  l_input_names_tab(190) := 'QUALIFY_CHANGE_TYPE';

  l_jp_input_names_tab(191) := 'E7A8AEE588A5';
  l_input_names_tab(191) := 'SI_SEX';

  l_jp_input_names_tab(192) := 'E4BFAEE6ADA3E5B9B3E59D87';
  l_input_names_tab(192) := 'CORRECT_AVG';

  l_jp_input_names_tab(193) := 'E4BFAEE6ADA3E5B9B3E59D87E794A8E8AABFE695B4E9A18D';
  l_input_names_tab(193) := 'CORRECT_AVG_ADJ';

  l_jp_input_names_tab(194) := 'E7B582E4BA86E697A5';
  l_input_names_tab(194) := 'END_DATE';

  l_jp_input_names_tab(195) := 'E4BD8FE5AE85E68EA7E999A4E9A18D';
  l_input_names_tab(195) := 'HOUSING_LOAN_TAX_CREDIT';

  l_jp_input_names_tab(196) := 'E4BD8FE5AE85E68EA7E999A4E5AE9FE68EA7E999A4E9A18D';
  l_input_names_tab(196) := 'ACTUAL_HOUSING_LOAN_TAX_CREDIT';

  l_jp_input_names_tab(197) := 'E4BD8FE6B091E7A88EE9A18D';
  l_input_names_tab(197) := 'LTX';

  l_jp_input_names_tab(198) := 'E4BD8FE6B091E7A88EE9A18DEFBCBFE4B880E68BACE5BEB4E58F8E';
  l_input_names_tab(198) := 'LTX_LUMP_SUM_WITHHOLD';

  l_jp_input_names_tab(199) := 'E4BD8FE6B091E7A88EE9A18DEFBCBFE789B9E588A5E5BEB4E58F8EEFBCBFE5B882E58CBAE794BAE69D91';
  l_input_names_tab(199) := 'LTX_SP_WITHHOLD_MUNICIPALITY';

  l_jp_input_names_tab(200) := 'E4BD8FE6B091E7A88EE9A18DEFBCBFE789B9E588A5E5BEB4E58F8EEFBCBFE7A88EE9A18D';
  l_input_names_tab(200) := 'LTX_SP_WITHHOLD_TAX';

  l_jp_input_names_tab(201) := 'E4BD8FE6B091E7A88EE9A18DEFBCBFE789B9E588A5E5BEB4E58F8EEFBCBFE98080E881B7E68980E5BE97';
  l_input_names_tab(201) := 'LTX_SP_WITHHOLD_TRM_INCOME';

  l_jp_input_names_tab(202) := 'E4BD8FE6B091E7A88EE9A18DEFBCBFE789B9E588A5E5BEB4E58F8EEFBCBFE983BDE98193E5BA9CE79C8C';
  l_input_names_tab(202) := 'LTX_SP_WITHHOLD_PREFECTURE';

  l_jp_input_names_tab(203) := 'E5BE93E5898DE6A899E6BA96E5A0B1E985ACE69C88E9A18D';
  l_input_names_tab(203) := 'PRIOR_SMR';

  l_jp_input_names_tab(204) := 'E5BE93E5898DE5A0B1E985AC';
  l_input_names_tab(204) := 'PRIOR_MR';

  l_jp_input_names_tab(205) := 'E587BAE799BAE59CB0';
  l_input_names_tab(205) := 'DEPARTURE_PLACE';

  l_jp_input_names_tab(206) := 'E587A6E79086';
  l_input_names_tab(206) := 'PROCESS_FLAG';

  l_jp_input_names_tab(207) := 'E5889DE59B9EE381AEE694AFE68995E69C88';
  l_input_names_tab(207) := 'FIRST_PAY_MTH';

  l_jp_input_names_tab(208) := 'E5889DE59B9EE381AEE7A88EE9A18D';
  l_input_names_tab(208) := 'FIRST_TAX';

  l_jp_input_names_tab(209) := 'E68980E59CA8E59CB0';
  l_input_names_tab(209) := 'LOCATED_PLACE';

  l_jp_input_names_tab(210) := 'E68980E59CA8E59CB0EFBCBFE382ABE3838A';
  l_input_names_tab(210) := 'LOCATED_PLACE_KANA';

  l_jp_input_names_tab(211) := 'E68980E5BE97E68EA7E999A4E9A18D';
  l_input_names_tab(211) := 'INCOME_EXM';

  l_jp_input_names_tab(212) := 'E68980E5BE97E7A88E';
  l_input_names_tab(212) := 'ITX';

  l_jp_input_names_tab(213) := 'E68980E5BE97E7A88EE9A18D';
  l_input_names_tab(213) := 'ITX';

  l_jp_input_names_tab(214) := 'E68980E5BE97E7A88EE794A8E8A888E7AE97E59FBAE7A48EE697A5E695B0';
  l_input_names_tab(214) := 'ITX_CALC_BASE_DAYS';

  l_jp_input_names_tab(215) := 'E5B08FE8A68FE6A8A1E4BC81E6A5ADE585B1E6B888E7AD89E68E9BE98791';
  l_input_names_tab(215) := 'SMALL_COMPANY_MUTUAL_AID_PREM';

  l_jp_input_names_tab(216) := 'E69887E7B5A6E69C88';
  l_input_names_tab(216) := 'SAL_RAISE_MTH';

  l_jp_input_names_tab(217) := 'E69887E7B5A6E5B7AEE69C88E9A18D';
  l_input_names_tab(217) := 'MTHLY_SAL_RAISE_DIFF';

  l_jp_input_names_tab(218) := 'E4B88AE69BB8E3818D';
  l_input_names_tab(218) := 'OVERRIDE_FLAG';

  l_jp_input_names_tab(219) := 'E794B3E5918AE69BB8E68F90E587BA';
  l_input_names_tab(219) := 'SUBMIT_FLAG';

  l_jp_input_names_tab(220) := 'E794B3E5918AE58886E7A4BEE4BC9AE4BF9DE999BAE69699';
  l_input_names_tab(220) := 'DECLARE_SI_PREM';

  l_jp_input_names_tab(221) := 'E794B3E5918AE58886E5B08FE8A68FE6A8A1E4BC81E6A5ADE585B1E6B888E7AD89E68E9BE98791';
  l_input_names_tab(221) := 'DECLARE_SMALL_COMPANY_MUTUAL_AID_PREM';

  l_jp_input_names_tab(222) := 'E7949FE591BDE4BF9DE999BAE69699E68EA7E999A4E9A18D';
  l_input_names_tab(222) := 'LIFE_INS_PREM_EXM';

  l_jp_input_names_tab(223) := 'E7A88EE9A18DE8A1A8E58CBAE58886';
  l_input_names_tab(223) := 'ITX_TYPE';

  l_jp_input_names_tab(224) := 'E7A88EE78CB6E4BA88E589B2E59088';
  l_input_names_tab(224) := 'ITX_GRACE_RATE';

  l_jp_input_names_tab(225) := 'E7A88EE78E87E7AD89';
  l_input_names_tab(225) := 'ITX_RATE';

  l_jp_input_names_tab(226) := 'E888B9E4BF9DE6898BE5B8B3E8AAB2E68980E7ACA6E58FB7';
  l_input_names_tab(226) := 'SAILOR_INS_BOOK_OFFICE_NUM';

  l_jp_input_names_tab(227) := 'E888B9E4BF9DE6898BE5B8B3E8A2ABE4BF9DE999BAE88085E795AAE58FB7';
  l_input_names_tab(227) := 'SAILOR_INS_BOOK_NUM';

  l_jp_input_names_tab(228) := 'E5898DE881B7E68385E5A0B1EFBCBFE7B5A6E4B88EE68980E5BE97E9A18D';
  l_input_names_tab(228) := 'PREV_EMP_INCOME';

  l_jp_input_names_tab(229) := 'E5898DE881B7E68385E5A0B1EFBCBFE7A4BEE4BC9AE4BF9DE999BAE69699';
  l_input_names_tab(229) := 'PREV_EMP_SI_PREM';

  l_jp_input_names_tab(230) := 'E5898DE881B7E68385E5A0B1EFBCBFE68980E5BE97E7A88EE9A18D';
  l_input_names_tab(230) := 'PREV_EMP_ITX';

  l_jp_input_names_tab(231) := 'E5898DE881B7E68385E5A0B1EFBCBFE5B08FE8A68FE6A8A1E4BC81E6A5ADE585B1E6B888E7AD89E68E9BE98791';
  l_input_names_tab(231) := 'PREV_EMP_SMALL_COMPANY_MUTUAL_AID_PREM';

  l_jp_input_names_tab(232) := 'E5898DE881B7E58886E7B5A6E4B88EE68980E5BE97';
  l_input_names_tab(232) := 'PREV_EMP_INCOME';

  l_jp_input_names_tab(233) := 'E5898DE881B7E58886E7A4BEE4BC9AE4BF9DE999BAE69699';
  l_input_names_tab(233) := 'PREV_EMP_SI_PREM';

  l_jp_input_names_tab(234) := 'E5898DE881B7E58886E68980E5BE97E7A88E';
  l_input_names_tab(234) := 'PREV_EMP_ITX';

  l_jp_input_names_tab(235) := 'E5898DE881B7E58886E5B08FE8A68FE6A8A1E4BC81E6A5ADE585B1E6B888E7AD89E68E9BE98791';
  l_input_names_tab(235) := 'PREV_EMP_SMALL_COMPANY_MUTUAL_AID_PREM';

  l_jp_input_names_tab(236) := 'E585A8E4BD93E58886E4BF9DE999BAE69699';
  l_input_names_tab(236) := 'INS_PREM';

  l_jp_input_names_tab(237) := 'E981A1E58F8AE694AFE68995E9A18D';
  l_input_names_tab(237) := 'RETRO_PAY';

  l_jp_input_names_tab(238) := 'E981A1E58F8AE694AFE68995E9A18DE4B88AE69BB8E3818D';
  l_input_names_tab(238) := 'RETRO_PAY_OVERRIDE_FLAG';

  l_jp_input_names_tab(239) := 'E981A1E58F8AE694AFE68995E9A18DE8AABFE695B4';
  l_input_names_tab(239) := 'RETRO_PAY_ADJ';

  l_jp_input_names_tab(240) := 'E596AAE5A4B1E58E9FE59BA0';
  l_input_names_tab(240) := 'DISQUALIFY_CAUSE';

  l_jp_input_names_tab(241) := 'E596AAE5A4B1E4BA8BE794B1';
  l_input_names_tab(241) := 'DISQUALIFY_REASON';

  l_jp_input_names_tab(242) := 'E596AAE5A4B1E697A5';
  l_input_names_tab(242) := 'DISQUALIFY_DATE';

  l_jp_input_names_tab(243) := 'E7B78FE8A888';
  l_input_names_tab(243) := 'TOTAL';

  l_jp_input_names_tab(244) := 'E6908DE5AEB3E4BF9DE999BAE69699E68EA7E999A4E9A18D';
  l_input_names_tab(244) := 'NONLIFE_INS_PREM_EXM';

  l_jp_input_names_tab(245) := 'E5AFBEE8B1A1E58CBAE58886';
  l_input_names_tab(245) := 'INCLUDE_FLAG';

  l_jp_input_names_tab(246) := 'E5AFBEE8B1A1E58CBAE5888631E69C88E5898D';
  l_input_names_tab(246) := 'INCLUDE_FLAG_1MTH_AGO';

  l_jp_input_names_tab(247) := 'E5AFBEE8B1A1E58CBAE5888632E69C88E5898D';
  l_input_names_tab(247) := 'INCLUDE_FLAG_2MTH_AGO';

  l_jp_input_names_tab(248) := 'E5AFBEE8B1A1E58CBAE5888633E69C88E5898D';
  l_input_names_tab(248) := 'INCLUDE_FLAG_3MTH_AGO';

  l_jp_input_names_tab(249) := 'E5AFBEE8B1A1E58CBAE5888634E69C88';
  l_input_names_tab(249) := 'INCLUDE_FLAG_APR';

  l_jp_input_names_tab(250) := 'E5AFBEE8B1A1E58CBAE5888635E69C88';
  l_input_names_tab(250) := 'INCLUDE_FLAG_MAY';

  l_jp_input_names_tab(251) := 'E5AFBEE8B1A1E58CBAE5888636E69C88';
  l_input_names_tab(251) := 'INCLUDE_FLAG_JUN';

  l_jp_input_names_tab(252) := 'E5AFBEE8B1A1E58CBAE5888637E69C88';
  l_input_names_tab(252) := 'INCLUDE_FLAG_JUL';

  l_jp_input_names_tab(253) := 'E5AFBEE8B1A1E88085E58CBAE58886';
  l_input_names_tab(253) := 'INCLUDE_FLAG';

  l_jp_input_names_tab(254) := 'E5AFBEE8B1A1E88085E588A4E588A5';
  l_input_names_tab(254) := 'INCLUDE_FLAG';

  l_jp_input_names_tab(255) := 'E98080E881B7E68980E5BE97';
  l_input_names_tab(255) := 'TRM_INCOME';

  l_jp_input_names_tab(256) := 'E98080E881B7E697A5';
  l_input_names_tab(256) := 'TRM_DATE';

  l_jp_input_names_tab(257) := 'E58D98E7B494E5B9B3E59D87';
  l_input_names_tab(257) := 'SIMPLE_AVG';

  l_jp_input_names_tab(258) := 'E79FADE69C9FE6908DE5AEB3E4BF9DE999BAE69699';
  l_input_names_tab(258) := 'SHORT_TERM_NONLIFE_INS_PREM';

  l_jp_input_names_tab(259) := 'E79FADE69982E99693E58AB4E5838DE88085';
  l_input_names_tab(259) := 'SHORT_TIME_WORKER_FLAG';

  l_jp_input_names_tab(260) := 'E9A790E8BB8AE5A0B4E4BBA3E7AD89';
  l_input_names_tab(260) := 'PARKING_FEE';

  l_jp_input_names_tab(261) := 'E5BEB4E58F8EE7BEA9E58B99E88085';
  l_input_names_tab(261) := 'WITHHOLD_AGENT';

  l_jp_input_names_tab(262) := 'E5BEB4E58F8EE6B888E68980E5BE97E7A88E';
  l_input_names_tab(262) := 'WITHHOLD_ITX';

  l_jp_input_names_tab(263) := 'E5BEB4E58F8EE7A88EE9A18D';
  l_input_names_tab(263) := 'ITX';

  l_jp_input_names_tab(264) := 'E5BEB4E58F8EE78CB6E4BA88E7A88EE9A18D';
  l_input_names_tab(264) := 'GRACE_ITX';

  l_jp_input_names_tab(265) := 'E8AABFE695B4E58886E7B5A6E4B88EE68980E5BE97';
  l_input_names_tab(265) := 'ADJ_EMP_INCOME';

  l_jp_input_names_tab(266) := 'E8AABFE695B4E58886E7A4BEE4BC9AE4BF9DE999BAE69699';
  l_input_names_tab(266) := 'ADJ_SI_PREM';

  l_jp_input_names_tab(267) := 'E8AABFE695B4E58886E68980E5BE97E7A88E';
  l_input_names_tab(267) := 'ADJ_ITX';

  l_jp_input_names_tab(268) := 'E8AABFE695B4E58886E5B08FE8A68FE6A8A1E4BC81E6A5ADE585B1E6B888E7AD89E68E9BE98791';
  l_input_names_tab(268) := 'ADJ_SMALL_COMPANY_MUTUAL_AID_PREM';

  l_jp_input_names_tab(269) := 'E995B7E69C9FE6908DE5AEB3E4BF9DE999BAE69699';
  l_input_names_tab(269) := 'LONG_TERM_NONLIFE_INS_PREM';

  l_jp_input_names_tab(270) := 'E9809AE58BA4E6898BE6AEB5';
  l_input_names_tab(270) := 'COMMUTING_METHOD';

  l_jp_input_names_tab(271) := 'E69198E8A681E6AC84';
  l_input_names_tab(271) := 'DESC_FIELD';

  l_jp_input_names_tab(272) := 'E69198E8A681E6AC8432';
  l_input_names_tab(272) := 'DESC_FIELD2';

  l_jp_input_names_tab(273) := 'E69198E8A681E6AC8433';
  l_input_names_tab(273) := 'DESC_FIELD3';

  l_jp_input_names_tab(274) := 'E69198E8A681E6AC8434';
  l_input_names_tab(274) := 'DESC_FIELD4';

  l_jp_input_names_tab(275) := 'E69198E8A681E6AC8435';
  l_input_names_tab(275) := 'DESC_FIELD5';

  l_jp_input_names_tab(276) := 'E981A9E794A8E58CBAE58886';
  l_input_names_tab(276) := 'APPLY_TYPE';

  l_jp_input_names_tab(277) := 'E981A9E794A8E69C88';
  l_input_names_tab(277) := 'APPLY_MTH';

  l_jp_input_names_tab(278) := 'E981A9E794A8E999A4E5A496';
  l_input_names_tab(278) := 'EXCLUDE_FLAG';

  l_jp_input_names_tab(279) := 'E983BDE98193E5BA9CE79C8CE7A88EE9A18D';
  l_input_names_tab(279) := 'PREFECTURAL_TAX';

  l_jp_input_names_tab(280) := 'E588B0E79D80E59CB0';
  l_input_names_tab(280) := 'ARRIVAL_PLACE';

  l_jp_input_names_tab(281) := 'E5908CE5B185E789B9E588A5E99A9CE5AEB3E88085';
  l_input_names_tab(281) := 'NUM_OF_SEV_DISABLED_LT';

  l_jp_input_names_tab(282) := 'E5908CE5B185E789B9E588A5E99A9CE5AEB3E88085E68EA7E999A4E9A18D';
  l_input_names_tab(282) := 'SEV_DISABLED_LT_EXM';

  l_jp_input_names_tab(283) := 'E5908CE5B185E88081E8A6AAE7AD89';
  l_input_names_tab(283) := 'NUM_OF_ELDER_PARENT_LT';

  l_jp_input_names_tab(284) := 'E5908CE5B185E88081E8A6AAE7AD89E68EA7E999A4E9A18D';
  l_input_names_tab(284) := 'ELDER_PARENT_LT_EXM';

  l_jp_input_names_tab(285) := 'E789B9E5AE9AE689B6E9A48AE68EA7E999A4E9A18D';
  l_input_names_tab(285) := 'SPECIFIC_DEP_EXM';

  l_jp_input_names_tab(286) := 'E789B9E5AE9AE689B6E9A48AE8A6AAE6978F';
  l_input_names_tab(286) := 'NUM_OF_SPECIFIC_DEP';

  l_jp_input_names_tab(287) := 'E789B9E588A5E381AEE5AFA1E5A9A6E68EA7E999A4E9A18D';
  l_input_names_tab(287) := 'SP_WIDOW_EXM';

  l_jp_input_names_tab(288) := 'E789B9E588A5E99A9CE5AEB3E88085';
  l_input_names_tab(288) := 'NUM_OF_SEV_DISABLED';

  l_jp_input_names_tab(289) := 'E789B9E588A5E99A9CE5AEB3E88085E68EA7E999A4E9A18D';
  l_input_names_tab(289) := 'SEV_DISABLED_EXM';

  l_jp_input_names_tab(290) := 'E789B9E588A5E5BEB4E58F8EE58CBAE58886';
  l_input_names_tab(290) := 'SP_WITHHOLD_TYPE';

  l_jp_input_names_tab(291) := 'E789B9E588A5E4BF9DE999BAE69699E5AFBEE8B1A1E9A18D';
  l_input_names_tab(291) := 'AMT_SUBJ_SPECIAL_INS_PREM';

  l_jp_input_names_tab(292) := 'E5B9B4E5B091E689B6E9A48AE68EA7E999A4E9A18D';
  l_input_names_tab(292) := 'JUNIOR_DEP_EXM';

  l_jp_input_names_tab(293) := 'E5B9B4E5B091E689B6E9A48AE8A6AAE6978F';
  l_input_names_tab(293) := 'NUM_OF_JUNIOR_DEP';

  l_jp_input_names_tab(294) := 'E5B9B4E7A88EE9A18D';
  l_input_names_tab(294) := 'ANNUAL_TAX';

  l_jp_input_names_tab(295) := 'E5B9B4E8AABFE5AFBEE8B1A1E58CBAE58886';
  l_input_names_tab(295) := 'YEA_TYPE';

  l_jp_input_names_tab(296) := 'E5B9B4E8AABFE5AE9AE78E87E68EA7E999A4E9A18D';
  l_input_names_tab(296) := 'YEA_PROPORTIONAL_DCT';

  l_jp_input_names_tab(297) := 'E5B9B4E8AABFE5B9B4E7A88EE9A18D';
  l_input_names_tab(297) := 'YEA_ANNUAL_TAX';

  l_jp_input_names_tab(298) := 'E78783E8B2BB';
  l_input_names_tab(298) := 'FUEL_COST';

  l_jp_input_names_tab(299) := 'E9858DE581B6E88085E381AEE59088E8A888E68980E5BE97';
  l_input_names_tab(299) := 'SPOUSE_INCOME';

  l_jp_input_names_tab(300) := 'E9858DE581B6E88085E381AEE5B9B4E99693E58F8EE585A5';
  l_input_names_tab(300) := 'SPOUSE_ANNUAL_INCOME';

  l_jp_input_names_tab(301) := 'E9858DE581B6E88085E58CBAE58886';
  l_input_names_tab(301) := 'SPOUSE_TYPE';

  l_jp_input_names_tab(302) := 'E9858DE581B6E88085E99A9CE5AEB3E58CBAE58886';
  l_input_names_tab(302) := 'SPOUSE_DISABLE_TYPE';

  l_jp_input_names_tab(303) := 'E9858DE581B6E88085E789B9E588A5E68EA7E999A4E9A18D';
  l_input_names_tab(303) := 'SPOUSE_SP_EXM';

  l_jp_input_names_tab(304) := 'E9858DE581B6E88085E789B9E588A5E68EA7E999A4E5AFBEE8B1A1E5A496';
  l_input_names_tab(304) := 'SPOUSE_SP_EXM_EXCLUDE_FLAG';

  l_jp_input_names_tab(305) := 'E8A2ABE689B6E9A48AE88085E69C89';
  l_input_names_tab(305) := 'DEP_EXIST_FLAG';

  l_jp_input_names_tab(306) := 'E8A2ABE4BF9DE999BAE88085E381AEE5B9B4E99693E58F8EE585A5';
  l_input_names_tab(306) := 'ANNUAL_INCOME';

  l_jp_input_names_tab(307) := 'E8A2ABE4BF9DE999BAE88085E98080E881B7E69C88E58886E4BF9DE999BAE69699';
  l_input_names_tab(307) := 'INS_PREM_EE_TRM';

  l_jp_input_names_tab(308) := 'E8A2ABE4BF9DE999BAE88085E58886E4BF9DE999BAE69699';
  l_input_names_tab(308) := 'WP_PREM_EE';

  l_jp_input_names_tab(309) := 'E99D9EE8AAB2E7A88EE5AFBEE8B1A1E9A18D';
  l_input_names_tab(309) := 'NTXBL_ERN';

  l_jp_input_names_tab(310) := 'E99D9EE5B185E4BD8FE88085';
  l_input_names_tab(310) := 'NRES_FLAG';

  l_jp_input_names_tab(311) := 'E99D9EE5B185E4BD8FE88085EFBCBFE78FBEE789A9E8AAB2E7A88EE9A18D';
  l_input_names_tab(311) := 'TXBL_ERN_KIND_NRES';

  l_jp_input_names_tab(312) := 'E99D9EE5B185E4BD8FE88085EFBCBFE694AFE7B5A6E8AAB2E7A88EE9A18D';
  l_input_names_tab(312) := 'TXBL_ERN_MONEY_NRES';

  l_jp_input_names_tab(313) := 'E99D9EE5B185E4BD8FE88085E381A8E381AAE381A3E3819FE697A5';
  l_input_names_tab(313) := 'NRES_START_DATE';

  l_jp_input_names_tab(314) := 'E99D9EE5B185E4BD8FE88085E8AAB2E7A88EE5AFBEE8B1A1E9A18D';
  l_input_names_tab(314) := 'TXBL_ERN_MONEY_NRES';

  l_jp_input_names_tab(315) := 'E99D9EE5B185E4BD8FE88085E78FBEE789A9E58886E8AAB2E7A88EE5AFBEE8B1A1E9A18D';
  l_input_names_tab(315) := 'TXBL_ERN_KIND_NRES';

  l_jp_input_names_tab(316) := 'E58299E88083';
  l_input_names_tab(316) := 'RMKS';

  l_jp_input_names_tab(317) := 'E6A899E6BA96E8B39EE4B88EE9A18D';
  l_input_names_tab(317) := 'STD_BON';

  l_jp_input_names_tab(318) := 'E689B6E9A48AE8A6AAE6978F';
  l_input_names_tab(318) := 'NUM_OF_DEP';

  l_jp_input_names_tab(319) := 'E588A5E587BAE58A9B';
  l_input_names_tab(319) := 'OUTPUT_FLAG';

  l_jp_input_names_tab(320) := 'E5A489E69BB4E4BA8BE794B1';
  l_input_names_tab(320) := 'CHANGE_REASON';

  l_jp_input_names_tab(321) := 'E5A489E69BB4E5B9B4E69C88E697A5';
  l_input_names_tab(321) := 'CHANGE_DATE';

  l_jp_input_names_tab(322) := 'E4BF9DE999BAE69699';
  l_input_names_tab(322) := 'INS_PREM';

  l_jp_input_names_tab(323) := 'E4BF9DE999BAE69699E5AFBEE8B1A1E9A18D';
  l_input_names_tab(323) := 'ERN_SUBJ_SI';

  l_jp_input_names_tab(324) := 'E69CACE4BABAE99A9CE5AEB3E58CBAE58886';
  l_input_names_tab(324) := 'DISABLE_TYPE';

  l_jp_input_names_tab(325) := 'E5908DE7A7B0';
  l_input_names_tab(325) := 'NAME';

  l_jp_input_names_tab(326) := 'E5908DE7A7B0EFBCBFE382ABE3838A';
  l_input_names_tab(326) := 'NAME_KANA';

  l_jp_input_names_tab(327) := 'E99BA2E881B7E7A5A8E4BAA4E4BB98E5B88CE69C9B';
  l_input_names_tab(327) := 'TRM_REPORT_OUTPUT_FLAG';

  l_jp_input_names_tab(328) := 'E58AB4E781BDE58AA0E585A5E58CBAE58886';
  l_input_names_tab(328) := 'WAI_TYPE';

  l_jp_input_names_tab(329) := 'E58AB4E781BDE4BA8BE6A5ADE4B8BB';
  l_input_names_tab(329) := 'WAI_LOCATION';

  l_jp_input_names_tab(330) := 'E58AB4E781BDE4BF9DE999BAE5AFBEE8B1A1E8B383E98791';
  l_input_names_tab(330) := 'ERN_SUBJ_WAI';

  l_jp_input_names_tab(331) := 'E88081E4BABAE68EA7E999A4E5AFBEE8B1A1E9858DE581B6E88085E68EA7E999A4E9A18D';
  l_input_names_tab(331) := 'ELDER_SPOUSE_EXM';

  l_jp_input_names_tab(332) := 'E88081E4BABAE689B6E9A48AE68EA7E999A4E9A18D';
  l_input_names_tab(332) := 'ELDER_DEP_EXM';

  l_jp_input_names_tab(333) := 'E88081E4BABAE689B6E9A48AE8A6AAE6978F';
  l_input_names_tab(333) := 'NUM_OF_ELDER_DEP';

  l_jp_input_names_tab(334) := 'E88081E5B9B4E88085E58CBAE58886';
  l_input_names_tab(334) := 'ELDER_TYPE';

  l_jp_input_names_tab(335) := 'E88081E5B9B4E88085E68EA7E999A4E9A18D';
  l_input_names_tab(335) := 'ELDER_EXM';


  l_jp_input_names_tab(336) := '47656E6572616C204C69666520496E73205072656D';
  l_input_names_tab(336) := 'GEN_LIFE_INS_PREM';

  l_jp_input_names_tab(337) := '496E646976696475616C2050656E73205072656D';
  l_input_names_tab(337) := 'INDIVIDUAL_PENSION_PREM';

  l_jp_input_names_tab(338) := '4C6F6E67205465726D204E6F6E6C69666520496E73205072656D';
  l_input_names_tab(338) := 'LONG_TERM_NONLIFE_INS_PREM';

  l_jp_input_names_tab(339) := '53686F7274205465726D204E6F6E6C69666520496E73205072656D';
  l_input_names_tab(339) := 'SHORT_TERM_NONLIFE_INS_PREM';

  -- bug.5914738. Earthquake Insurance Premium input values
  l_jp_input_names_tab(340) := 'E59CB0E99C87E4BF9DE999BAE69699';
  l_input_names_tab(340) := 'EARTHQUAKE_INS_PREM';

  l_jp_input_names_tab(341) := '45617274687175616B6520496E73205072656D';
  l_input_names_tab(341) := 'EARTHQUAKE_INS_PREM';

  l_jp_input_names_tab(342) := 'E7B5A6E4B88EE68EA7E999A4E59CB0E99C87E4BF9DE999BAE69699';
  l_input_names_tab(342) := 'SAL_DCT_EARTHQUAKE_INS_PREM';

  l_jp_input_names_tab(343) := 'E8AABFE695B4E6A899E6BA96E8B39EE4B88EE9A18D';
  l_input_names_tab(343) := 'STD_BON_ADJ';

  l_jp_input_names_tab(344) := 'E5B9B4E99693E6A899E6BA96E8B39EE4B88EE9A18D';
  l_input_names_tab(344) := 'ANNUAL_STD_BON';

  hr_utility.set_location(l_proc, 20);

  if (g_dbg) then
    hr_utility.trace('| Input Value Count = ' || l_jp_input_names_tab.COUNT);
    hr_utility.trace('+--------------------------------------------+ ');
  end if;
--

  UPDATE pay_input_values_f
  SET    name = 'LTX'
  WHERE  name LIKE hr_jp_standard_pkg.hextochar('E5BEB4E58F8EE7A88EE9A18D','AL32UTF8')
  AND    legislation_code = 'JP'
  AND    element_type_id IN (
           SELECT element_type_id
           FROM   pay_element_types_f
           WHERE  element_name LIKE hr_jp_standard_pkg.hextochar('E585B1EFBCBFE59FBAE69CACEFBCBFE4BD8FE6B091E7A88EEFBCBFE4B880E68BACE5BEB4E58F8E','AL32UTF8')
           AND    legislation_code = 'JP' );

  UPDATE pay_input_values_f
  SET    name = 'INS_PREM_ER'
  WHERE  name LIKE hr_jp_standard_pkg.hextochar('E4BA8BE6A5ADE4B8BBE58886E4BF9DE999BAE69699','AL32UTF8')
  AND    legislation_code = 'JP'
  AND    element_type_id IN (
           SELECT element_type_id
           FROM   pay_element_types_f
           WHERE  element_name IN
                    (hr_jp_standard_pkg.hextochar('E7B5A6EFBCBFE59FBAE69CACEFBCBFE581A5E4BF9DEFBCBFE4BF9DE999BAE69699','AL32UTF8'),
                    hr_jp_standard_pkg.hextochar('E8B39EEFBCBFE59FBAE69CACEFBCBFE581A5E4BF9DEFBCBFE4BF9DE999BAE69699','AL32UTF8'),
                    hr_jp_standard_pkg.hextochar('E8B39EEFBCBFE59FBAE69CACEFBCBFE58E9AE5B9B4EFBCBFE4BF9DE999BAE69699','AL32UTF8'))
           AND    legislation_code = 'JP' );

  UPDATE pay_input_values_f
  SET    name = 'INS_PREM_EE'
  WHERE  name LIKE hr_jp_standard_pkg.hextochar('E8A2ABE4BF9DE999BAE88085E58886E4BF9DE999BAE69699','AL32UTF8')
  AND    legislation_code = 'JP'
  AND    element_type_id IN (
           SELECT element_type_id
           FROM   pay_element_types_f
           WHERE  element_name IN
                    (hr_jp_standard_pkg.hextochar('E7B5A6EFBCBFE59FBAE69CACEFBCBFE581A5E4BF9DEFBCBFE4BF9DE999BAE69699','AL32UTF8'),
                    hr_jp_standard_pkg.hextochar('E8B39EEFBCBFE59FBAE69CACEFBCBFE581A5E4BF9DEFBCBFE4BF9DE999BAE69699','AL32UTF8'),
                    hr_jp_standard_pkg.hextochar('E8B39EEFBCBFE59FBAE69CACEFBCBFE58E9AE5B9B4EFBCBFE4BF9DE999BAE69699','AL32UTF8'))
           AND    legislation_code = 'JP' );


  FORALL l_tab_cnt IN 1..l_jp_input_names_tab.COUNT

    UPDATE pay_input_values_f
    SET    name = l_input_names_tab(l_tab_cnt)
    WHERE  name LIKE hr_jp_standard_pkg.hextochar(l_jp_input_names_tab(l_tab_cnt),'AL32UTF8')
    AND    legislation_code = 'JP';


  hr_utility.set_location(l_proc, 30);

  if (g_dbg) then
    hr_utility.trace('| Total Input Values Updated = ' || SQL%ROWCOUNT);
    hr_utility.trace('+-------------------------------+ ');
  end if;
--
EXCEPTION

  WHEN OTHERS THEN

    hr_utility.set_location(l_proc, 40);

    raise;

END migrate_input_values;
--
-- |-------------------------------------------------------------------|
-- |---------------------< migrate_element_types >---------------------|
-- |-------------------------------------------------------------------|
--
procedure migrate_element_types is
--
  type t_jp_element_names_tab is table of VARCHAR2(200) index by binary_integer;

  type t_element_names_tab is table of pay_element_types_f.element_name%TYPE index by binary_integer;

  type t_element_desc_tab is table of pay_element_types_f.description%TYPE index by binary_integer;

  type t_element_rep_tab is table of pay_element_types_f.reporting_name%TYPE index by binary_integer;

  l_jp_element_names_tab  t_jp_element_names_tab;
  l_element_names_tab     t_element_names_tab;
  l_element_desc_tab      t_element_desc_tab;
  l_element_rep_tab       t_element_rep_tab;

  l_proc            VARCHAR2(50) := g_pkg||'.migrate_element_types';

BEGIN

  l_jp_element_names_tab.DELETE;
  l_element_names_tab.DELETE;
  l_element_desc_tab.DELETE;
  l_element_rep_tab.DELETE;

  hr_utility.set_location(l_proc, 10);

  l_jp_element_names_tab(1) := 'E7B5A6EFBCBFE59FBAE69CACEFBCBFE581A5E4BF9DEFBCBFE4BF9DE999BAE69699';
  l_element_names_tab(1) := 'SAL_HI_PREM_PROC';
  l_element_desc_tab(1) := 'Calculation of Health Insurance Premium on Salary';
  l_element_rep_tab(1) := 'Health Insurance Premium';

  l_jp_element_names_tab(2) := 'E7B5A6EFBCBFE59FBAE69CACEFBCBFE99B87E4BF9DEFBCBFE4BF9DE999BAE69699';
  l_element_names_tab(2) := 'SAL_EI_PREM_PROC';
  l_element_desc_tab(2) := 'Calculation of Employment Insurance Premium on Salary';
  l_element_rep_tab(2) := 'Employment Insurance Premium';

  l_jp_element_names_tab(3) := 'E7B5A6EFBCBFE59FBAE69CACEFBCBFE58E9AE5B9B4EFBCBFE4BF9DE999BAE69699';
  l_element_names_tab(3) := 'SAL_WP_PREM_PROC';
  l_element_desc_tab(3) := 'Calculation of Welfare Pension Insurance Premium on Salary';
  l_element_rep_tab(3) := 'Welfare Pension Insurance Premium';

  l_jp_element_names_tab(4) := 'E7B5A6EFBCBFE59FBAE69CACEFBCBFE68980E5BE97E7A88E';
  l_element_names_tab(4) := 'SAL_ITX_PROC';
  l_element_desc_tab(4) := 'Calculation of Income Tax on Salary';
  l_element_rep_tab(4) := 'Income Tax';

  l_jp_element_names_tab(5) := 'E7B5A6EFBCBFE7B590E69E9CEFBCBFE4BB8BE4BF9DEFBCBFE4BA8BE6A5ADE4B8BB';
  l_element_names_tab(5) := 'SAL_CI_PREM_ER';
  l_element_desc_tab(5) := 'Care Insurance Premium on Salary (Employer Burden)';
  l_element_rep_tab(5) := 'Care Insurance Premium (Employer)';

  l_jp_element_names_tab(6) := 'E7B5A6EFBCBFE7B590E69E9CEFBCBFE4BB8BE4BF9DEFBCBFE8A2ABE4BF9DE999BAE88085';
  l_element_names_tab(6) := 'SAL_CI_PREM_EE';
  l_element_desc_tab(6) := 'Care Insurance Premium on Salary (Insured Burden)';
  l_element_rep_tab(6) := 'Care Insurance Premium';

  l_jp_element_names_tab(7) := 'E7B5A6EFBCBFE7B590E69E9CEFBCBFE4BB8BE4BF9DEFBCBFE8A2ABE4BF9DE999BAE88085EFBCBFE99D9EE5B185E4BD8FE88085';
  l_element_names_tab(7) := 'SAL_CI_PREM_EE_NRES';
  l_element_desc_tab(7) := 'Care Insurance Premium on Salary not subject to Year End Adjustment (Non Resident)';
  l_element_rep_tab(7) := 'Care Insurance Premium (Non Resident)';

  l_jp_element_names_tab(8) := 'E7B5A6EFBCBFE7B590E69E9CEFBCBFE59FBAE98791EFBCBFE4BA8BE6A5ADE4B8BB';
  l_element_names_tab(8) := 'SAL_WPF_PREM_ER';
  l_element_desc_tab(8) := 'Welfare Pension Fund Insurance Premium on Salary (Employer Burden)';
  l_element_rep_tab(8) := 'Welfare Pension Fund Insurance Premium (Employer)';

  l_jp_element_names_tab(9) := 'E7B5A6EFBCBFE7B590E69E9CEFBCBFE59FBAE98791EFBCBFE8A2ABE4BF9DE999BAE88085';
  l_element_names_tab(9) := 'SAL_WPF_PREM_EE';
  l_element_desc_tab(9) := 'Welfare Pension Fund Insurance Premium on Salary (Insured Burden)';
  l_element_rep_tab(9) := 'Welfare Pension Fund Insurance Premium';

  l_jp_element_names_tab(10) := 'E7B5A6EFBCBFE7B590E69E9CEFBCBFE59FBAE98791EFBCBFE8A2ABE4BF9DE999BAE88085EFBCBFE99D9EE5B185E4BD8FE88085';
  l_element_names_tab(10) := 'SAL_WPF_PREM_EE_NRES';
  l_element_desc_tab(10) := 'Welfare Pension Fund Insurance Premium on Salary not subject to Year End Adjustment (Non Resident)';
  l_element_rep_tab(10) := 'Welfare Pension Fund Insurance Premium (Non Resident)';

  l_jp_element_names_tab(11) := 'E7B5A6EFBCBFE7B590E69E9CEFBCBFE581A5E4BF9DEFBCBFE4BA8BE6A5ADE4B8BB';
  l_element_names_tab(11) := 'SAL_HI_PREM_ER';
  l_element_desc_tab(11) := 'Health Insurance Premium on Salary (Employer Burden)';
  l_element_rep_tab(11) := 'Health Insurance Premium (Employer)';

  l_jp_element_names_tab(12) := 'E7B5A6EFBCBFE7B590E69E9CEFBCBFE581A5E4BF9DEFBCBFE8A2ABE4BF9DE999BAE88085';
  l_element_names_tab(12) := 'SAL_HI_PREM_EE';
  l_element_desc_tab(12) := 'Health Insurance Premium on Salary (Insured Burden)';
  l_element_rep_tab(12) := 'Health Insurance Premium';

  l_jp_element_names_tab(13) := 'E7B5A6EFBCBFE7B590E69E9CEFBCBFE581A5E4BF9DEFBCBFE8A2ABE4BF9DE999BAE88085EFBCBFE99D9EE5B185E4BD8FE88085';
  l_element_names_tab(13) := 'SAL_HI_PREM_EE_NRES';
  l_element_desc_tab(13) := 'Health Insurance Premium not subject to Year End Adjustment on Salary (Non Resident)';
  l_element_rep_tab(13) := 'Health Insurance Premium (Non Resident)';

  l_jp_element_names_tab(14) := 'E7B5A6EFBCBFE7B590E69E9CEFBCBFE99B87E4BF9DEFBCBFE8A2ABE4BF9DE999BAE88085';
  l_element_names_tab(14) := 'SAL_EI_PREM_EE';
  l_element_desc_tab(14) := 'Employment Insurance Premium on Salary (Insured Burden)';
  l_element_rep_tab(14) := 'Employment Insurance Premium';

  l_jp_element_names_tab(15) := 'E7B5A6EFBCBFE7B590E69E9CEFBCBFE99B87E4BF9DEFBCBFE8A2ABE4BF9DE999BAE88085EFBCBFE99D9EE5B185E4BD8FE88085';
  l_element_names_tab(15) := 'SAL_EI_PREM_EE_NRES';
  l_element_desc_tab(15) := 'Employment Insurance Premium on Salary not subject to Year End Adjustment (Non Resident)';
  l_element_rep_tab(15) := 'Employment Insurance Premium (Non Resident)';

  l_jp_element_names_tab(16) := 'E7B5A6EFBCBFE7B590E69E9CEFBCBFE58E9AE5B9B4EFBCBFE4BA8BE6A5ADE4B8BB';
  l_element_names_tab(16) := 'SAL_WP_PREM_ER';
  l_element_desc_tab(16) := 'Welfare Pension Insurance Premium on Salary (Employer Burden)';
  l_element_rep_tab(16) := 'Welfare Pension Insurance Premium (Employer)';

  l_jp_element_names_tab(17) := 'E7B5A6EFBCBFE7B590E69E9CEFBCBFE58E9AE5B9B4EFBCBFE8A2ABE4BF9DE999BAE88085';
  l_element_names_tab(17) := 'SAL_WP_PREM_EE';
  l_element_desc_tab(17) := 'Welfare Pension Insurance Premium on Salary (Insured Burden)';
  l_element_rep_tab(17) := 'Welfare Pension Insurance Premium';

  l_jp_element_names_tab(18) := 'E7B5A6EFBCBFE7B590E69E9CEFBCBFE58E9AE5B9B4EFBCBFE8A2ABE4BF9DE999BAE88085EFBCBFE99D9EE5B185E4BD8FE88085';
  l_element_names_tab(18) := 'SAL_WP_PREM_EE_NRES';
  l_element_desc_tab(18) := 'Welfare Pension Insurance Premium on Salary not subject to Year End Adjustment (Non Resident)';
  l_element_rep_tab(18) := 'Welfare Pension Insurance Premium (Non Resident)';

  l_jp_element_names_tab(19) := 'E7B5A6EFBCBFE7B590E69E9CEFBCBFE4BD8FE6B091E7A88EEFBCBFE4B880E68BACE5BEB4E58F8E';
  l_element_names_tab(19) := 'SAL_LTX_LUMP_SUM_WITHHOLD';
  l_element_desc_tab(19) := 'Lump Sum Collecting Local Tax on Salary';
  l_element_rep_tab(19) := 'Local Tax (Lump Sum Collection)';

  l_jp_element_names_tab(20) := 'E7B5A6EFBCBFE7B590E69E9CEFBCBFE68980E5BE97E7A88E';
  l_element_names_tab(20) := 'SAL_ITX';
  l_element_desc_tab(20) := 'Income Tax on Salary';
  l_element_rep_tab(20) := 'Income Tax';

  l_jp_element_names_tab(21) := 'E7B5A6EFBCBFE4BD8FE6B091E7A88E';
  l_element_names_tab(21) := 'SAL_LTX';
  l_element_desc_tab(21) := 'Local Tax on Salary';
  l_element_rep_tab(21) := 'Local Tax';

  l_jp_element_names_tab(22) := 'E7B5A6EFBCBFE68980E5BE97E7A88EEFBCBF31393939E5B9B4E7B5A6E4B88EE789B9E588A5E8AABFE695B4E68EA7E999A4';
  l_element_names_tab(22) := 'SAL_ITX_1999_SAL_SP_DCT';
  l_element_desc_tab(22) := 'Income Tax Special Adjustment Deduction in 1999 on Salary';
  l_element_rep_tab(22) := 'Income Tax Special Adjustment Deduction';

  l_jp_element_names_tab(23) := 'E7B5A6EFBCBFE68980E5BE97E7A88EEFBCBFE99D9EE5B185E4BD8FE88085';
  l_element_names_tab(23) := 'SAL_ITX_NRES';
  l_element_desc_tab(23) := 'Income Tax on Salary (Non Resident)';
  l_element_rep_tab(23) := 'Income Tax (Non Resident)';

  l_jp_element_names_tab(24) := 'E585B1EFBCBFE4BB8BE4BF9DEFBCBFE981A9E794A8E999A4E5A496E68385E5A0B1';
  l_element_names_tab(24) := 'COM_CI_EXCLUDE_INFO';
  l_element_desc_tab(24) := 'Determination Information for Calculation of Care Insurance';
  l_element_rep_tab(24) := 'Care Insurance Information of Exclusion from Application';

  l_jp_element_names_tab(25) := 'E585B1EFBCBFE59FBAE98791EFBCBFE8B387E6A0BCE68385E5A0B1';
  l_element_names_tab(25) := 'COM_WPF_QUALIFY_INFO';
  l_element_desc_tab(25) := 'Qualification Information of Welfare Pension Fund';
  l_element_rep_tab(25) := 'Qualification Information (Welfare Pension Fund)';

  l_jp_element_names_tab(26) := 'E585B1EFBCBFE59FBAE69CACEFBCBFE4BD8FE6B091E7A88EEFBCBFE4B880E68BACE5BEB4E58F8E';
  l_element_names_tab(26) := 'COM_LTX_LUMP_SUM_WITHHOLD_PROC';
  l_element_desc_tab(26) := 'Calculation of Lump Sum Collection Local Tax';
  l_element_rep_tab(26) := 'Local Tax (Lump Sum Collection)';

  l_jp_element_names_tab(27) := 'E585B1EFBCBFE59FBAE69CACEFBCBFE689B6E9A48AE68EA7E999A4E7AD89';
  l_element_names_tab(27) := 'YEA_DEP_EXM_PROC';
  l_element_desc_tab(27) := 'Calculation of Basic Exemption, Spouse Exemption, Dependent Exemption on Year End Adjustment';
  l_element_rep_tab(27) := 'Dependent Exemption etc Information';

  l_jp_element_names_tab(28) := 'E585B1EFBCBFE581A5E4BF9DEFBCBFE8B387E6A0BCE68385E5A0B1';
  l_element_names_tab(28) := 'COM_HI_QUALIFY_INFO';
  l_element_desc_tab(28) := 'Qualification Information of Health Insurance';
  l_element_rep_tab(28) := 'Qualification Information (Health Insurance)';

  l_jp_element_names_tab(29) := 'E585B1EFBCBFE581A5E4BF9DEFBCBFE6A899E6BA96E5A0B1E985ACE69C88E9A18D';
  l_element_names_tab(29) := 'COM_HI_SMR_INFO';
  l_element_desc_tab(29) := 'Monthly Remuneration Information of Health Insurance';
  l_element_rep_tab(29) := 'Standard Monthly Remuneration (Health Insurance)';

  l_jp_element_names_tab(30) := 'E585B1EFBCBFE99B87E4BF9DEFBCBFE8B387E6A0BCE68385E5A0B1';
  l_element_names_tab(30) := 'COM_EI_QUALIFY_INFO';
  l_element_desc_tab(30) := 'Qualification Information of Employment Insurance';
  l_element_rep_tab(30) := 'Qualification Information (Employment Insurance)';

  l_jp_element_names_tab(31) := 'E585B1EFBCBFE58E9AE5B9B4EFBCBFE8B387E6A0BCE68385E5A0B1';
  l_element_names_tab(31) := 'COM_WP_QUALIFY_INFO';
  l_element_desc_tab(31) := 'Qualification Information of Welfare Pension Insurance';
  l_element_rep_tab(31) := 'Qualification Information (Welfare Pension Insurance)';

  l_jp_element_names_tab(32) := 'E585B1EFBCBFE58E9AE5B9B4EFBCBFE6A899E6BA96E5A0B1E985ACE69C88E9A18D';
  l_element_names_tab(32) := 'COM_WP_SMR_INFO';
  l_element_desc_tab(32) := 'Monthly Remuneration Information of Welfare Pension Insurance';
  l_element_rep_tab(32) := 'Standard Monthly Remuneration (Welfare Pension Insurance)';

  l_jp_element_names_tab(33) := 'E585B1EFBCBFE7A4BEE4BF9DEFBCBFE8B387E6A0BCE58F96E5BE97E69982EFBCBFE5A0B1E985AC';
  l_element_names_tab(33) := 'COM_SI_MR_AT_QUALIFY_INFO';
  l_element_desc_tab(33) := 'Monthly Remuneration Information of Social Insurance at Qualified';
  l_element_rep_tab(33) := 'Monthly Remuneration (Qualified)';

  l_jp_element_names_tab(34) := 'E585B1EFBCBFE7A4BEE4BF9DEFBCBFE68385E5A0B1';
  l_element_names_tab(34) := 'COM_SI_INFO';
  l_element_desc_tab(34) := 'Location Information of Social Insurance';
  l_element_rep_tab(34) := 'Social Insurance Information';

  l_jp_element_names_tab(35) := 'E585B1EFBCBFE7A4BEE4BF9DEFBCBFE5B8B3E7A5A8';
  l_element_names_tab(35) := 'COM_SI_REPORT_INFO';
  l_element_desc_tab(35) := 'Information of Reporting Form Output of Social Insurance';
  l_element_rep_tab(35) := 'Social Insurance Reporting Form Information';

  l_jp_element_names_tab(36) := 'E585B1EFBCBFE7A4BEE4BF9DEFBCBFE5B9B4E98791E6898BE5B8B3E8A898E58FB7E795AAE58FB7E7AD89';
  l_element_names_tab(36) := 'COM_SI_PENSION_BOOK_NUM_INFO';
  l_element_desc_tab(36) := 'Information of Pension Book of Social Insurance';
  l_element_rep_tab(36) := 'Pension Book Symbol Number';

  l_jp_element_names_tab(37) := 'E585B1EFBCBFE4BD8FE6B091E7A88EEFBCBFE68385E5A0B1';
  l_element_names_tab(37) := 'COM_LTX_INFO';
  l_element_desc_tab(37) := 'Collection Information of Local Tax';
  l_element_rep_tab(37) := 'Local Tax Information';

  l_jp_element_names_tab(38) := 'E585B1EFBCBFE68980E5BE97E7A88EEFBCBF31393939E5B9B4E7B5A6E4B88EE789B9E588A5E8AABFE695B4E68EA7E999A4EFBCBFE68385E5A0B1';
  l_element_names_tab(38) := 'COM_ITX_1999_SAL_SP_DCT_INFO';
  l_element_desc_tab(38) := 'Information for Income Tax Special Adjustment Deduction in 1999';
  l_element_rep_tab(38) := 'Income Tax Adjustment Amount Information';

  l_jp_element_names_tab(39) := 'E585B1EFBCBFE68980E5BE97E7A88EEFBCBFE68385E5A0B1';
  l_element_names_tab(39) := 'COM_ITX_INFO';
  l_element_desc_tab(39) := 'Information of Tax Table, Year End Adjustment Subject Class etc on Income Tax';
  l_element_rep_tab(39) := 'Income Tax Information';

  l_jp_element_names_tab(40) := 'E585B1EFBCBFE98080E881B7E68385E5A0B1';
  l_element_names_tab(40) := 'COM_TRM_INFO';
  l_element_desc_tab(40) := 'File of Declaration about Receipt of Termination Income, Information about Lump Sum Collection of Local Tax';
  l_element_rep_tab(40) := 'Termination Information';

  l_jp_element_names_tab(41) := 'E585B1EFBCBFE58AB4E4BF9DEFBCBFE68385E5A0B1';
  l_element_names_tab(41) := 'COM_LI_INFO';
  l_element_desc_tab(41) := 'Location Information of Labor Insurance';
  l_element_rep_tab(41) := 'Labor Insurance Information';

  l_jp_element_names_tab(42) := 'E69C88EFBCBFE59FBAE69CACEFBCBFE5A0B1E985ACE69C88E9A18D';
  l_element_names_tab(42) := 'GEP_MR_PROC';
  l_element_desc_tab(42) := 'Calculation of Standard Monthly Remuneration on Unscheduled Revision';
  l_element_rep_tab(42) := 'Monthly Remuneration (Geppen)';

  l_jp_element_names_tab(43) := 'E69C88EFBCBFE7B590E69E9C';
  l_element_names_tab(43) := 'GEP_RSLT';
  l_element_desc_tab(43) := 'Monthly Remuneration etc on Unscheduled Revision';
  l_element_rep_tab(43) := 'Standard Monthly Remuneration (Geppen)';

  l_jp_element_names_tab(44) := 'E69C88EFBCBFE7B590E69E9CEFBCBFE59BBAE5AE9AE79A84E8B383E98791';
  l_element_names_tab(44) := 'GEP_FIXED_WAGE_RSLT';
  l_element_desc_tab(44) := 'Fixed Wage Result on Unscheduled Revision';
  l_element_rep_tab(44) := 'Fixed Wage (Geppen)';

  l_jp_element_names_tab(45) := 'E69C88EFBCBFE8AABFE695B4E68385E5A0B1';
  l_element_names_tab(45) := 'GEP_ADJ_INFO';
  l_element_desc_tab(45) := 'Adjustment Information of Remuneration Amount on Unscheduled Revision';
  l_element_rep_tab(45) := 'Adjustment Information (Geppen)';

  l_jp_element_names_tab(46) := 'E5868DE5B9B4EFBCBFE7B2BEE7AE97E9A18D';
  l_element_names_tab(46) := 'REY_ITX';
  l_element_desc_tab(46) := 'Liquidation Amount on Re-year End Adjustment';
  l_element_rep_tab(46) := 'Liquidation Amount';

  l_jp_element_names_tab(47) := 'E7AE97EFBCBFE59FBAE69CACEFBCBFE5A0B1E985ACE69C88E9A18D';
  l_element_names_tab(47) := 'SAN_MR_PROC';
  l_element_desc_tab(47) := 'Calculation of Standard Monthly Remuneration on Scheduled Revision';
  l_element_rep_tab(47) := 'Monthly Remuneration (Santei)';

  l_jp_element_names_tab(48) := 'E7AE97EFBCBFE7B590E69E9CEFBCBF32303033E5B9B433E69C883331E697A5E4BBA5E5898D';
  l_element_names_tab(48) := 'SAN_BEFORE_20030331_RSLT';
  l_element_desc_tab(48) := 'Scheduled Revision Result before 31 Mar 2003';
  l_element_rep_tab(48) := 'Standard Monthly Remuneration (Santei)';

  l_jp_element_names_tab(49) := 'E7AE97EFBCBFE7B590E69E9CEFBCBFE69C88E5A489E4BA88E5AE9AE69C88';
  l_element_names_tab(49) := 'SAN_GEP_MTH_RSLT';
  l_element_desc_tab(49) := 'Unscheduled Revision Projected Month Result on Scheduled Revision';
  l_element_rep_tab(49) := 'Geppen Projected Month';

  l_jp_element_names_tab(50) := 'E7AE97EFBCBFE7B590E69E9CEFBCBFE58299E88083E6AC84';
  l_element_names_tab(50) := 'SAN_REPORT_RMKS_RSLT';
  l_element_desc_tab(50) := 'Remarks Column Result for Notification of Santei';
  l_element_rep_tab(50) := 'Remarks Column (Santei)';

  l_jp_element_names_tab(51) := 'E7AE97EFBCBFE8AABFE695B4E68385E5A0B1EFBCBF32303033E5B9B433E69C883331E697A5E4BBA5E5898D';
  l_element_names_tab(51) := 'SAN_ADJ_BEFORE_20030331_INFO';
  l_element_desc_tab(51) := 'Adjustment Information of Remuneration Amount on Scheduled Revision before 31 Mar 2003';
  l_element_rep_tab(51) := 'Adjustment Information (Santei)';

  l_jp_element_names_tab(52) := 'E5889DE69C9FEFBCBFE7B5A6E4B88E31';
  l_element_names_tab(52) := 'INI_SAL1';
  l_element_desc_tab(52) := 'Salary 1 on Balance Initialization';
  l_element_rep_tab(52) := 'Salary 1 (Initial)';

  l_jp_element_names_tab(53) := 'E5889DE69C9FEFBCBFE7B5A6E4B88E32';
  l_element_names_tab(53) := 'INI_SAL2';
  l_element_desc_tab(53) := 'Salary 2 on Balance Initialization';
  l_element_rep_tab(53) := 'Salary 2 (Initial)';

  l_jp_element_names_tab(54) := 'E5889DE69C9FEFBCBFE585B1E9809A31';
  l_element_names_tab(54) := 'INI_COM1';
  l_element_desc_tab(54) := 'Common 1 on Balance Initialization';
  l_element_rep_tab(54) := 'Common 1 (Initial)';

  l_jp_element_names_tab(55) := 'E5889DE69C9FEFBCBFE585B1E9809A32';
  l_element_names_tab(55) := 'INI_COM2';
  l_element_desc_tab(55) := 'Common 2 on Balance Initialization';
  l_element_rep_tab(55) := 'Common 2 (Initial)';

  l_jp_element_names_tab(56) := 'E5889DE69C9FEFBCBFE585B1E9809A33';
  l_element_names_tab(56) := 'INI_COM3';
  l_element_desc_tab(56) := 'Common 3 on Balance Initialization';
  l_element_rep_tab(56) := 'Common 3 (Initial)';

  l_jp_element_names_tab(57) := 'E5889DE69C9FEFBCBFE7AE97E5AE9AE69C88E5A48931';
  l_element_names_tab(57) := 'INI_SAN_GEP1';
  l_element_desc_tab(57) := 'Santei Geppen 1 on Balance Initialization';
  l_element_rep_tab(57) := 'Santei Geppen 1 (Initial)';

  l_jp_element_names_tab(58) := 'E5889DE69C9FEFBCBFE694AFE6899531';
  l_element_names_tab(58) := 'INI_PAY1';
  l_element_desc_tab(58) := 'Payment 1 on Balance Initialization';
  l_element_rep_tab(58) := 'Payment 1 (Initial)';

  l_jp_element_names_tab(59) := 'E5889DE69C9FEFBCBFE8B39EE4B88E31';
  l_element_names_tab(59) := 'INI_BON1';
  l_element_desc_tab(59) := 'Bonus 1 on Balance Initialization';
  l_element_rep_tab(59) := 'Bonus 1 (Initial)';

  l_jp_element_names_tab(60) := 'E5889DE69C9FEFBCBFE8B39EE4B88E32';
  l_element_names_tab(60) := 'INI_BON2';
  l_element_desc_tab(60) := 'Bonus 2 on Balance Initialization';
  l_element_rep_tab(60) := 'Bonus 2 (Initial)';

  l_jp_element_names_tab(61) := 'E5889DE69C9FEFBCBFE98080E881B731';
  l_element_names_tab(61) := 'INI_TRM1';
  l_element_desc_tab(61) := 'Termination 1 on Balance Initialization';
  l_element_rep_tab(61) := 'Termination (Initial)';

  l_jp_element_names_tab(62) := 'E5889DE69C9FEFBCBFE789B9E8B39E31';
  l_element_names_tab(62) := 'INI_SPB1';
  l_element_desc_tab(62) := 'Special bonus 1 on Balance Initialization';
  l_element_rep_tab(62) := 'Special Bonus 1 (Initial)';

  l_jp_element_names_tab(63) := 'E5889DE69C9FEFBCBFE5B9B4E8AABF31';
  l_element_names_tab(63) := 'INI_YEA1';
  l_element_desc_tab(63) := 'Year end adjustment 1 on Balance Initialization';
  l_element_rep_tab(63) := 'Year End Adjustment 1 (Initial)';

  l_jp_element_names_tab(64) := 'E5889DE69C9FEFBCBFE5B9B4E8AABF32';
  l_element_names_tab(64) := 'INI_YEA2';
  l_element_desc_tab(64) := 'Year end adjustment 2 on Balance Initialization';
  l_element_rep_tab(64) := 'Year End Adjustment 2 (Initial)';

  l_jp_element_names_tab(65) := 'E8B39EEFBCBFE59FBAE69CACEFBCBFE99B87E4BF9DEFBCBFE4BF9DE999BAE69699';
  l_element_names_tab(65) := 'BON_EI_PREM_PROC';
  l_element_desc_tab(65) := 'Calculation of Employment Insurance Premium on Bonus';
  l_element_rep_tab(65) := 'Employment Insurance Premium';

  l_jp_element_names_tab(66) := 'E8B39EEFBCBFE59FBAE69CACEFBCBFE68980E5BE97E7A88E';
  l_element_names_tab(66) := 'BON_ITX_PROC';
  l_element_desc_tab(66) := 'Income Tax on Bonus';
  l_element_rep_tab(66) := 'Income Tax';

  l_jp_element_names_tab(67) := 'E8B39EEFBCBFE7B590E69E9CEFBCBFE99B87E4BF9DEFBCBFE8A2ABE4BF9DE999BAE88085';
  l_element_names_tab(67) := 'BON_EI_PREM_EE';
  l_element_desc_tab(67) := 'Employment Insurance Premium on Bonus (Insured Burden)';
  l_element_rep_tab(67) := 'Employment Insurance Premium';

  l_jp_element_names_tab(68) := 'E8B39EEFBCBFE7B590E69E9CEFBCBFE99B87E4BF9DEFBCBFE8A2ABE4BF9DE999BAE88085EFBCBFE99D9EE5B185E4BD8FE88085';
  l_element_names_tab(68) := 'BON_EI_PREM_EE_NRES';
  l_element_desc_tab(68) := 'Employment Insurance Premium on Bonus not subject to Year End Adjustment (Non Resident)';
  l_element_rep_tab(68) := 'Employment Insurance Premium (Non Resident)';

  l_jp_element_names_tab(69) := 'E8B39EEFBCBFE7B590E69E9CEFBCBFE4BD8FE6B091E7A88EEFBCBFE4B880E68BACE5BEB4E58F8E';
  l_element_names_tab(69) := 'BON_LTX_LUMP_SUM_WITHHOLD';
  l_element_desc_tab(69) := 'Lump Sum Collecting Local Tax on Bonus';
  l_element_rep_tab(69) := 'Local Tax (Lump Sum Collection)';

  l_jp_element_names_tab(70) := 'E8B39EEFBCBFE7B590E69E9CEFBCBFE68980E5BE97E7A88E';
  l_element_names_tab(70) := 'BON_ITX';
  l_element_desc_tab(70) := 'Income Tax on Bonus';
  l_element_rep_tab(70) := 'Income Tax';

  l_jp_element_names_tab(71) := 'E8B39EEFBCBFE68980E5BE97E7A88EEFBCBF31393939E5B9B4E7B5A6E4B88EE789B9E588A5E8AABFE695B4E68EA7E999A4';
  l_element_names_tab(71) := 'BON_ITX_1999_SAL_SP_DCT';
  l_element_desc_tab(71) := 'Income Tax Special Adjustment Deduction in 1999 on Bonus';
  l_element_rep_tab(71) := 'Income Tax Special Adjustment Deduction';

  l_jp_element_names_tab(72) := 'E8B39EEFBCBFE68980E5BE97E7A88EEFBCBFE99D9EE5B185E4BD8FE88085';
  l_element_names_tab(72) := 'BON_ITX_NRES';
  l_element_desc_tab(72) := 'Income Tax on Bonus (Non Resident)';
  l_element_rep_tab(72) := 'Income Tax (Non Resident)';

  l_jp_element_names_tab(73) := 'E98080EFBCBFE59FBAE69CACEFBCBFE4BD8FE6B091E7A88EEFBCBFE789B9E588A5E5BEB4E58F8E';
  l_element_names_tab(73) := 'TRM_LTX_SP_WITHHOLD_PROC';
  l_element_desc_tab(73) := 'Calculation of Special Collecting Local Tax on Termination Payment';
  l_element_rep_tab(73) := 'Local Tax (Special Collection)';

  l_jp_element_names_tab(74) := 'E98080EFBCBFE59FBAE69CACEFBCBFE68980E5BE97E68EA7E999A4E9A18D';
  l_element_names_tab(74) := 'TRM_INCOME_DCT_PROC';
  l_element_desc_tab(74) := 'Calculation of Lump Sum Collecting Local Tax on Termination Payment';
  l_element_rep_tab(74) := 'Income Deduction Amount';

  l_jp_element_names_tab(75) := 'E98080EFBCBFE7B590E69E9CEFBCBFE4BD8FE6B091E7A88EEFBCBFE4B880E68BACE5BEB4E58F8E';
  l_element_names_tab(75) := 'TRM_LTX_LUMP_SUM_WITHHOLD';
  l_element_desc_tab(75) := 'Lump Sum Collecting Local Tax on Termination Payment';
  l_element_rep_tab(75) := 'Local Tax (Lump Sum Collection)';

  l_jp_element_names_tab(76) := 'E98080EFBCBFE7B590E69E9CEFBCBFE4BD8FE6B091E7A88EEFBCBFE789B9E588A5E5BEB4E58F8E';
  l_element_names_tab(76) := 'TRM_LTX_SP_WITHHOLD';
  l_element_desc_tab(76) := 'Special Collecting Local Tax on Termination Payment';
  l_element_rep_tab(76) := 'Local Tax (Special Collection)';

  l_jp_element_names_tab(77) := 'E98080EFBCBFE7B590E69E9CEFBCBFE68980E5BE97E68EA7E999A4E9A18D';
  l_element_names_tab(77) := 'TRM_INCOME_DCT';
  l_element_desc_tab(77) := 'Income Deduction on Termination Payment';
  l_element_rep_tab(77) := 'Income Deduction Amount';

  l_jp_element_names_tab(78) := 'E98080EFBCBFE68980E5BE97E7A88E';
  l_element_names_tab(78) := 'TRM_ITX';
  l_element_desc_tab(78) := 'Income Tax on Termination Payment';
  l_element_rep_tab(78) := 'Income Tax';

  l_jp_element_names_tab(79) := 'E789B9E8B39EEFBCBFE59FBAE69CACEFBCBFE99B87E4BF9DEFBCBFE4BF9DE999BAE69699';
  l_element_names_tab(79) := 'SPB_EI_PREM_PROC';
  l_element_desc_tab(79) := 'Calculation of Employment Insurance Premium on Special Bonus';
  l_element_rep_tab(79) := 'Employment Insurance Premium';

  l_jp_element_names_tab(80) := 'E789B9E8B39EEFBCBFE59FBAE69CACEFBCBFE68980E5BE97E7A88E';
  l_element_names_tab(80) := 'SPB_ITX_PROC';
  l_element_desc_tab(80) := 'Calculation of Income Tax on Special Bonus';
  l_element_rep_tab(80) := 'Income Tax';

  l_jp_element_names_tab(81) := 'E789B9E8B39EEFBCBFE7B590E69E9CEFBCBFE99B87E4BF9DEFBCBFE8A2ABE4BF9DE999BAE88085';
  l_element_names_tab(81) := 'SPB_EI_PREM_EE';
  l_element_desc_tab(81) := 'Employment Insurance Premium on Special Bonus (Insured Burden)';
  l_element_rep_tab(81) := 'Employment Insurance Premium';

  l_jp_element_names_tab(82) := 'E789B9E8B39EEFBCBFE7B590E69E9CEFBCBFE99B87E4BF9DEFBCBFE8A2ABE4BF9DE999BAE88085EFBCBFE99D9EE5B185E4BD8FE88085';
  l_element_names_tab(82) := 'SPB_EI_PREM_EE_NRES';
  l_element_desc_tab(82) := 'Employment Insurance Premium on Special Bonus not subject to Year End Adjustment (Non Resident)';
  l_element_rep_tab(82) := 'Employment Insurance Premium (Non Resident)';

  l_jp_element_names_tab(83) := 'E789B9E8B39EEFBCBFE7B590E69E9CEFBCBFE68980E5BE97E7A88E';
  l_element_names_tab(83) := 'SPB_ITX';
  l_element_desc_tab(83) := 'Income Tax on Special Bonus';
  l_element_rep_tab(83) := 'Income Tax';

  l_jp_element_names_tab(84) := 'E789B9E8B39EEFBCBFE68980E5BE97E7A88EEFBCBF31393939E5B9B4E7B5A6E4B88EE789B9E588A5E8AABFE695B4E68EA7E999A4';
  l_element_names_tab(84) := 'SPB_ITX_1999_SAL_SP_DCT';
  l_element_desc_tab(84) := 'Income Tax Special Adjustment Deduction in 1999 on Special Bonus';
  l_element_rep_tab(84) := 'Income Tax Special Adjustment Deduction';

  l_jp_element_names_tab(85) := 'E789B9E8B39EEFBCBFE68980E5BE97E7A88EEFBCBFE99D9EE5B185E4BD8FE88085';
  l_element_names_tab(85) := 'SPB_ITX_NRES';
  l_element_desc_tab(85) := 'Income Tax on Special Bonus (Non Resident)';
  l_element_rep_tab(85) := 'Income Tax (Non Resident)';

  l_jp_element_names_tab(86) := 'E5B9B4EFBCBFE9818EE4B88DE8B6B3E7A88EE9A18D';
  l_element_names_tab(86) := 'YEA_ITX';
  l_element_desc_tab(86) := 'Over and Short Tax Amount on Year End Adjustment';
  l_element_rep_tab(86) := 'Over and Short Tax Amount';

  l_jp_element_names_tab(87) := 'E5B9B4EFBCBFE59FBAE69CACEFBCBFE7B5A6E4B88EE68980E5BE97E68EA7E999A4E5BE8CE381AEE98791E9A18D';
  l_element_names_tab(87) := 'YEA_AMT_AFTER_EMP_INCOME_DCT_PROC';
  l_element_desc_tab(87) := 'Calculation of Amount after Salary Income Deduction on Year End Adjustment';
  l_element_rep_tab(87) := 'Amount after Salary Income Deduction';

  l_jp_element_names_tab(88) := 'E5B9B4EFBCBFE59FBAE69CACEFBCBFE5B7AEE5BC95E5B9B4E7A88EE9A18D';
  l_element_names_tab(88) := 'YEA_NET_ANNUAL_TAX_PROC';
  l_element_desc_tab(88) := 'Calculation of Net Annual Tax Amount on Year End Adjustment';
  l_element_rep_tab(88) := 'Net Annual Tax Amount';

  l_jp_element_names_tab(89) := 'E5B9B4EFBCBFE59FBAE69CACEFBCBFE4BF9DE999BAE69699E585BCE9858DE789B9E68EA7E999A4';
  l_element_names_tab(89) := 'YEA_INS_PREM_SPOUSE_SP_EXM_PROC';
  l_element_desc_tab(89) := 'Calculation of Insurance Premium and Spouse Special Exemption Amount on Year End Adjustment';
  l_element_rep_tab(89) := 'Insurance Premium and Spouse Special Exemption Amount';

  l_jp_element_names_tab(90) := 'E5B9B4EFBCBFE7B590E69E9CEFBCBFE7B5A6E4B88EE68980E5BE97E68EA7E999A4E5BE8CE381AEE98791E9A18D';
  l_element_names_tab(90) := 'YEA_AMT_AFTER_EMP_INCOME_DCT_RSLT';
  l_element_desc_tab(90) := 'Amount after Salary Income Deduction on Year End Adjustment';
  l_element_rep_tab(90) := 'Amount after Salary Income Deduction';

  l_jp_element_names_tab(91) := 'E5B9B4EFBCBFE7B590E69E9CEFBCBFE5B7AEE5BC95E5B9B4E7A88EE9A18D';
  l_element_names_tab(91) := 'YEA_NET_ANNUAL_TAX';
  l_element_desc_tab(91) := 'Net Annual Tax Amount on Year End Adjustment';
  l_element_rep_tab(91) := 'Net Annual Tax Amount';

  l_jp_element_names_tab(92) := 'E5B9B4EFBCBFE7B590E69E9CEFBCBFE689B6E9A48AE68EA7E999A4E58CBAE58886E7AD89';
  l_element_names_tab(92) := 'YEA_DEP_EXM_TYPE_RSLT';
  l_element_desc_tab(92) := 'Dependent Exemption Class etc Information on Year End Adjustment';
  l_element_rep_tab(92) := 'Dependent Exemption Type Information';

  l_jp_element_names_tab(93) := 'E5B9B4EFBCBFE7B590E69E9CEFBCBFE689B6E9A48AE68EA7E999A4E7AD89';
  l_element_names_tab(93) := 'YEA_DEP_EXM_RSLT';
  l_element_desc_tab(93) := 'Dependent Exemption etc on Year End Adjustment';
  l_element_rep_tab(93) := 'Dependent Exemption etc Information';

  l_jp_element_names_tab(94) := 'E5B9B4EFBCBFE7B590E69E9CEFBCBFE4BF9DE999BAE69699E585BCE9858DE789B9E68EA7E999A4';
  l_element_names_tab(94) := 'YEA_INS_PREM_SPOUSE_SP_EXM_RSLT';
  l_element_desc_tab(94) := 'Insurance Premium and Spouse Special Exemption on Year End Adjustment';
  l_element_rep_tab(94) := 'Insurance Premium and Spouse Special Exemption Amount';

  l_jp_element_names_tab(95) := 'E5B9B4EFBCBFE6BA90E6B389E5BEB4E58F8EE7A5A8';
  l_element_names_tab(95) := 'YEA_WITHHOLD_TAX_REPORT_INFO';
  l_element_desc_tab(95) := 'Withholding Tax Report Information on Year End Adjustment';
  l_element_rep_tab(95) := 'Withholding Tax Report Information';

  l_jp_element_names_tab(96) := 'E5B9B4EFBCBFE4BD8FE5AE85E58F96E5BE97E7AD89E789B9E588A5E68EA7E999A4';
  l_element_names_tab(96) := 'YEA_HOUSING_LOAN_TAX_CREDIT';
  l_element_desc_tab(96) := 'Housing Debt Loan etc Special Exemption on Year End Adjustment';
  l_element_rep_tab(96) := 'Housing debt loan etc Special Exemption Amount';

  l_jp_element_names_tab(97) := 'E5B9B4EFBCBFE5898DE881B7E68385E5A0B1';
  l_element_names_tab(97) := 'YEA_PREV_EMP_INFO';
  l_element_desc_tab(97) := 'Previous Employment Information on Year End Adjustment';
  l_element_rep_tab(97) := 'Previous Employment Information';

  l_jp_element_names_tab(98) := 'E5B9B4EFBCBFE8AABFE695B4E68385E5A0B1';
  l_element_names_tab(98) := 'YEA_ADJ_INFO';
  l_element_desc_tab(98) := 'Adjustment Information of Income Tax on Year End Adjustment';
  l_element_rep_tab(98) := 'Adjustment Information (Year End Adjustment)';

  l_jp_element_names_tab(99) := 'E5B9B4EFBCBFE5B9B4E7A88EE9A18D';
  l_element_names_tab(99) := 'YEA_ANNUAL_TAX';
  l_element_desc_tab(99) := 'Annual Tax Amount on Year End Adjustment';
  l_element_rep_tab(99) := 'Annual Tax Amount';

  l_jp_element_names_tab(100) := 'E5B9B4EFBCBFE4BF9DE999BAE69699E585BCE9858DE789B9E68EA7E999A4';
  l_element_names_tab(100) := 'YEA_INS_PREM_SPOUSE_SP_EXM_INFO';
  l_element_desc_tab(100) := 'Adjustment Information of Insurance Premium and Spouse Special Exemption Amount on Year End Adjustment';
  l_element_rep_tab(100) := 'Insurance Premium and Spouse Special Exemption Amount';

  l_jp_element_names_tab(101) := 'E585B1EFBCBFE7A4BEE4BF9DEFBCBFE8A2ABE689B6E9A48AE88085E795B0E58B95E5B18A';
  l_element_names_tab(101) := 'COM_SI_DEP_REPORT_INFO';
  l_element_desc_tab(101) := 'Information for Health Insurance Notification of Nonworking Dependent';
  l_element_rep_tab(101) := 'Health Insurance Notification of Nonworking Dependent Info';

  l_jp_element_names_tab(102) := 'E8B39EEFBCBFE7B590E69E9CEFBCBFE4BB8BE4BF9DEFBCBFE8A2ABE4BF9DE999BAE88085EFBCBFE99D9EE5B185E4BD8FE88085';
  l_element_names_tab(102) := 'BON_CI_PREM_EE_NRES';
  l_element_desc_tab(102) := 'Care Insurance Premium not subject to Year End Adjustment on Bonus (Non Resident)';
  l_element_rep_tab(102) := 'Care Insurance Premium (Non Resident)';

  l_jp_element_names_tab(103) := 'E8B39EEFBCBFE7B590E69E9CEFBCBFE4BB8BE4BF9DEFBCBFE4BA8BE6A5ADE4B8BB';
  l_element_names_tab(103) := 'BON_CI_PREM_ER';
  l_element_desc_tab(103) := 'Care Insurance Premium on Bonus (Employer Burden)';
  l_element_rep_tab(103) := 'Care Insurance Premium (Employer)';

  l_jp_element_names_tab(104) := 'E8B39EEFBCBFE7B590E69E9CEFBCBFE59FBAE98791EFBCBFE8A2ABE4BF9DE999BAE88085';
  l_element_names_tab(104) := 'BON_WPF_PREM_EE';
  l_element_desc_tab(104) := 'Welfare Pension Fund Insurance Premium on Bonus (Insured Burden)';
  l_element_rep_tab(104) := 'Welfare Pension Fund Insurance Premium';

  l_jp_element_names_tab(105) := 'E8B39EEFBCBFE7B590E69E9CEFBCBFE59FBAE98791EFBCBFE8A2ABE4BF9DE999BAE88085EFBCBFE99D9EE5B185E4BD8FE88085';
  l_element_names_tab(105) := 'BON_WPF_PREM_EE_NRES';
  l_element_desc_tab(105) := 'Welfare Pension Fund Insurance Premium not subject to Year End Adjustment on Bonus (Non Resident)';
  l_element_rep_tab(105) := 'Welfare Pension Fund Insurance Premium (Non Resident)';

  l_jp_element_names_tab(106) := 'E8B39EEFBCBFE7B590E69E9CEFBCBFE59FBAE98791EFBCBFE4BA8BE6A5ADE4B8BB';
  l_element_names_tab(106) := 'BON_WPF_PREM_ER';
  l_element_desc_tab(106) := 'Welfare Pension Fund Insurance Premium on Bonus (Employer Burden)';
  l_element_rep_tab(106) := 'Welfare Pension Fund Insurance Premium (Employer)';

  l_jp_element_names_tab(107) := 'E8B39EEFBCBFE7B590E69E9CEFBCBFE581A5E4BF9DEFBCBFE6A899E6BA96E8B39EE4B88EE9A18D';
  l_element_names_tab(107) := 'BON_HI_STD_BON';
  l_element_desc_tab(107) := 'Standard Bonus Amount on Bonus subject to Health Insurance';
  l_element_rep_tab(107) := 'Standard Bonus (Health Insurance)';

  l_jp_element_names_tab(108) := 'E7AE97EFBCBFE8AABFE695B4E68385E5A0B1';
  l_element_names_tab(108) := 'SAN_ADJ_INFO';
  l_element_desc_tab(108) := 'Adjustment Information of Remuneration Amount on Scheduled Revision';
  l_element_rep_tab(108) := 'Adjustment Information (Santei)';

  l_jp_element_names_tab(109) := 'E7AE97EFBCBFE7AE97E5AE9AE59FBAE7A48EE5B18AEFBCBFE58299E88083E6AC84';
  l_element_names_tab(109) := 'SAN_REPORT_RMKS_ADJ_INFO';
  l_element_desc_tab(109) := 'Remarks Column Information for Notification of Santei';
  l_element_rep_tab(109) := 'Remarks Column (Santei)';

  l_jp_element_names_tab(110) := 'E69C88EFBCBFE69C88E9A18DE5A489E69BB4E5B18AEFBCBFE58299E88083E6AC84';
  l_element_names_tab(110) := 'GEP_REPORT_RMKS_ADJ_INFO';
  l_element_desc_tab(110) := 'Remarks Column Information for Notification of Geppen';
  l_element_rep_tab(110) := 'Remarks Column (Geppen)';

  l_jp_element_names_tab(111) := 'E7AE97EFBCBFE7B590E69E9C';
  l_element_names_tab(111) := 'SAN_RSLT';
  l_element_desc_tab(111) := 'Monthly renumeration etc on Scheduled Revision';
  l_element_rep_tab(111) := 'Standard Monthly Remuneration (Santei)';

  l_jp_element_names_tab(112) := 'E8B39EEFBCBFE7B590E69E9CEFBCBFE58E9AE5B9B4EFBCBFE6A899E6BA96E8B39EE4B88EE9A18D';
  l_element_names_tab(112) := 'BON_WP_STD_BON';
  l_element_desc_tab(112) := 'Standard Bonus Amount on Bonus subject to Welfare Pension Insurance';
  l_element_rep_tab(112) := 'Standard Bonus (Welfare Pension Insurancee)';

  l_jp_element_names_tab(113) := 'E8B39EEFBCBFE7B590E69E9CEFBCBFE4BB8BE4BF9DEFBCBFE8A2ABE4BF9DE999BAE88085';
  l_element_names_tab(113) := 'BON_CI_PREM_EE';
  l_element_desc_tab(113) := 'Care Insurance Premium on Bonus (Insured Burden)';
  l_element_rep_tab(113) := 'Care Insurance Premium';

  l_jp_element_names_tab(114) := 'E8B39EEFBCBFE59FBAE69CACEFBCBFE581A5E4BF9DEFBCBFE4BF9DE999BAE69699';
  l_element_names_tab(114) := 'BON_HI_PREM_PROC';
  l_element_desc_tab(114) := 'Calculation of Health Insurance Premium on Bonus';
  l_element_rep_tab(114) := 'Health Insurance Premium';

  l_jp_element_names_tab(115) := 'E8B39EEFBCBFE59FBAE69CACEFBCBFE58E9AE5B9B4EFBCBFE4BF9DE999BAE69699';
  l_element_names_tab(115) := 'BON_WP_PREM_PROC';
  l_element_desc_tab(115) := 'Calculation of Welfare Pension Insurance Premium on Bonus';
  l_element_rep_tab(115) := 'Welfare Pension Insurance Premium';

  l_jp_element_names_tab(116) := 'E8B39EEFBCBFE7B590E69E9CEFBCBFE581A5E4BF9DEFBCBFE8A2ABE4BF9DE999BAE88085';
  l_element_names_tab(116) := 'BON_HI_PREM_EE';
  l_element_desc_tab(116) := 'Health Insurance Premium on Bonus (Insured Burden)';
  l_element_rep_tab(116) := 'Health Insurance Premium';

  l_jp_element_names_tab(117) := 'E8B39EEFBCBFE7B590E69E9CEFBCBFE58E9AE5B9B4EFBCBFE8A2ABE4BF9DE999BAE88085';
  l_element_names_tab(117) := 'BON_WP_PREM_EE';
  l_element_desc_tab(117) := 'Welfare Pension Insurance Premium on Bonus (Insured Burden)';
  l_element_rep_tab(117) := 'Welfare Pension Insurance Premium';

  l_jp_element_names_tab(118) := 'E8B39EEFBCBFE7B590E69E9CEFBCBFE581A5E4BF9DEFBCBFE8A2ABE4BF9DE999BAE88085EFBCBFE99D9EE5B185E4BD8FE88085';
  l_element_names_tab(118) := 'BON_HI_PREM_EE_NRES';
  l_element_desc_tab(118) := 'Health Insurance Premium not subject to Year End Adjustment on Bonus (Non Resident)';
  l_element_rep_tab(118) := 'Health Insurance Premium (Non Resident)';

  l_jp_element_names_tab(119) := 'E8B39EEFBCBFE7B590E69E9CEFBCBFE58E9AE5B9B4EFBCBFE8A2ABE4BF9DE999BAE88085EFBCBFE99D9EE5B185E4BD8FE88085';
  l_element_names_tab(119) := 'BON_WP_PREM_EE_NRES';
  l_element_desc_tab(119) := 'Welfare Pension Insurance Premium on Bonus not subject to Year End Adjustment (Non Resident)';
  l_element_rep_tab(119) := 'Welfare Pension Insurance Premium (Non Resident)';

  l_jp_element_names_tab(120) := 'E8B39EEFBCBFE7B590E69E9CEFBCBFE581A5E4BF9DEFBCBFE4BA8BE6A5ADE4B8BB';
  l_element_names_tab(120) := 'BON_HI_PREM_ER';
  l_element_desc_tab(120) := 'Health Insurance Premium on Bonus (Employer Burden)';
  l_element_rep_tab(120) := 'Health Insurance Premium (Employer)';

  l_jp_element_names_tab(121) := 'E8B39EEFBCBFE7B590E69E9CEFBCBFE58E9AE5B9B4EFBCBFE4BA8BE6A5ADE4B8BB';
  l_element_names_tab(121) := 'BON_WP_PREM_ER';
  l_element_desc_tab(121) := 'Welfare Pension Insurance Premium on Bonus (Employer Burden)';
  l_element_rep_tab(121) := 'Welfare Pension Insurance Premium (Employer)';

  l_jp_element_names_tab(122) := 'E5889DE69C9FEFBCBFE8B39EE4B88E33';
  l_element_names_tab(122) := 'INI_BON3';
  l_element_desc_tab(122) := 'Bonus 3 on Balance Initialization';
  l_element_rep_tab(122) := 'Bonus 3 (Initial)';

  l_jp_element_names_tab(123) := 'E8B39EEFBCBFE7B590E69E9CEFBCBFE581A5E4BF9DEFBCBFE59088E7AE97E5AFBEE8B1A1EFBCBFE98791E98AAD';
  l_element_names_tab(123) := 'BON_HI_ERN_MONEY_SUBJ_SI_ACMLT';
  l_element_desc_tab(123) := 'Health Insurance Premium Accumulation on Bonus';
  l_element_rep_tab(123) := 'Amount subject to Health Insurance (Add Up)';

  l_jp_element_names_tab(124) := 'E8B39EEFBCBFE7B590E69E9CEFBCBFE581A5E4BF9DEFBCBFE59088E7AE97E5AFBEE8B1A1EFBCBFE78FBEE789A9';
  l_element_names_tab(124) := 'BON_HI_ERN_KIND_SUBJ_SI_ACMLT';
  l_element_desc_tab(124) := 'Health Insurance Premium of Earning in Kind Accumulation on Bonus';
  l_element_rep_tab(124) := 'Amount subject to Health Insurance (Add Up) (Kind)';

  l_jp_element_names_tab(125) := 'E8B39EEFBCBFE7B590E69E9CEFBCBFE58E9AE5B9B4EFBCBFE59088E7AE97E5AFBEE8B1A1EFBCBFE98791E98AAD';
  l_element_names_tab(125) := 'BON_WP_ERN_MONEY_SUBJ_SI_ACMLT';
  l_element_desc_tab(125) := 'Welfare Pension Insurance Premium Accumulation on Bonus';
  l_element_rep_tab(125) := 'Amount Subject to Welfare Pension Ins (Add Up)';

  l_jp_element_names_tab(126) := 'E8B39EEFBCBFE7B590E69E9CEFBCBFE58E9AE5B9B4EFBCBFE59088E7AE97E5AFBEE8B1A1EFBCBFE78FBEE789A9';
  l_element_names_tab(126) := 'BON_WP_ERN_KIND_SUBJ_SI_ACMLT';
  l_element_desc_tab(126) := 'Welfare Pension Insurance Premium of Earning in Kind on Bonus';
  l_element_rep_tab(126) := 'Amount Subject to Welfare Pension Ins (Add Up) (Kind)';

  l_jp_element_names_tab(127) := 'E8B39EEFBCBFE7B590E69E9CEFBCBFE581A5E4BF9DEFBCBFE59088E7AE97E5AFBEE8B1A1EFBCBFE4BF9DE999BAE69699EFBCBFE8A2ABE4BF9DE999BAE88085';
  l_element_names_tab(127) := 'BON_HI_PREM_EE_ACMLT';
  l_element_desc_tab(127) := 'Health Insurance Premium Accumulation on Bonus (Insured Burden)';
  l_element_rep_tab(127) := 'Health Insurance Premium (Add Up)';

  l_jp_element_names_tab(128) := 'E8B39EEFBCBFE7B590E69E9CEFBCBFE581A5E4BF9DEFBCBFE59088E7AE97E5AFBEE8B1A1EFBCBFE4BF9DE999BAE69699EFBCBFE4BA8BE6A5ADE4B8BB';
  l_element_names_tab(128) := 'BON_HI_PREM_ER_ACMLT';
  l_element_desc_tab(128) := 'Health Insurance Premium Accumulation on Bonus (Employer Burden)';
  l_element_rep_tab(128) := 'Health Insurance Premium (Add Up) (Employer)';

  l_jp_element_names_tab(129) := 'E8B39EEFBCBFE7B590E69E9CEFBCBFE4BB8BE4BF9DEFBCBFE59088E7AE97E5AFBEE8B1A1EFBCBFE4BF9DE999BAE69699EFBCBFE8A2ABE4BF9DE999BAE88085';
  l_element_names_tab(129) := 'BON_CI_PREM_EE_ACMLT';
  l_element_desc_tab(129) := 'Care Insurance Premium Accumulation on Bonus (Insured Burden)';
  l_element_rep_tab(129) := 'Care Insurance Premium (Add Up)';

  l_jp_element_names_tab(130) := 'E8B39EEFBCBFE7B590E69E9CEFBCBFE4BB8BE4BF9DEFBCBFE59088E7AE97E5AFBEE8B1A1EFBCBFE4BF9DE999BAE69699EFBCBFE4BA8BE6A5ADE4B8BB';
  l_element_names_tab(130) := 'BON_CI_PREM_ER_ACMLT';
  l_element_desc_tab(130) := 'Care Insurance Premium Accumulation on Bonus (Employer Burden)';
  l_element_rep_tab(130) := 'Care Insurance Premium (Add Up) (Employer)';

  l_jp_element_names_tab(131) := 'E8B39EEFBCBFE7B590E69E9CEFBCBFE58E9AE5B9B4EFBCBFE59088E7AE97E5AFBEE8B1A1EFBCBFE4BF9DE999BAE69699EFBCBFE8A2ABE4BF9DE999BAE88085';
  l_element_names_tab(131) := 'BON_WP_PREM_EE_ACMLT';
  l_element_desc_tab(131) := 'Welfare Pension Insurance Premium Accumulation on Bonus (Insured Burden)';
  l_element_rep_tab(131) := 'Welfare Pension Ins Premium (Add Up)';

  l_jp_element_names_tab(132) := 'E8B39EEFBCBFE7B590E69E9CEFBCBFE58E9AE5B9B4EFBCBFE59088E7AE97E5AFBEE8B1A1EFBCBFE4BF9DE999BAE69699EFBCBFE4BA8BE6A5ADE4B8BB';
  l_element_names_tab(132) := 'BON_WP_PREM_ER_ACMLT';
  l_element_desc_tab(132) := 'Welfare Pension Insurance Premium Accumulation on Bonus (Employer Burden)';
  l_element_rep_tab(132) := 'Welfare Pension Ins Premium (Add Up) (Employer)';

  l_jp_element_names_tab(133) := 'E8B39EEFBCBFE7B590E69E9CEFBCBFE59FBAE98791EFBCBFE59088E7AE97E5AFBEE8B1A1EFBCBFE4BF9DE999BAE69699EFBCBFE8A2ABE4BF9DE999BAE88085';
  l_element_names_tab(133) := 'BON_WPF_PREM_EE_ACMLT';
  l_element_desc_tab(133) := 'Welfare Pension Fund Insurance Premium Accumulation on Bonus (Insured Burden)';
  l_element_rep_tab(133) := 'Welfare Pension Fund Insurance Premium (Add Up)';

  l_jp_element_names_tab(134) := 'E8B39EEFBCBFE7B590E69E9CEFBCBFE59FBAE98791EFBCBFE59088E7AE97E5AFBEE8B1A1EFBCBFE4BF9DE999BAE69699EFBCBFE4BA8BE6A5ADE4B8BB';
  l_element_names_tab(134) := 'BON_WPF_PREM_ER_ACMLT';
  l_element_desc_tab(134) := 'Welfare Pension Fund Insurance Premium Accumulation on Bonus (Employer Burden)';
  l_element_rep_tab(134) := 'Welfare Pension Fund Insurance Premium (Add Up) (Employer)';

  l_jp_element_names_tab(135) := 'E8B39EEFBCBFE581A5E4BF9DEFBCBFE8AABFE695B4E68385E5A0B1';
  l_element_names_tab(135) := 'BON_HI_ADJ_INFO';
  l_element_desc_tab(135) := 'Adjustment Information of Health Insurance Premium on Bonus';
  l_element_rep_tab(135) := 'Adjustment Information (Bonus) (Health Insurance)';

  l_jp_element_names_tab(136) := 'E8B39EEFBCBFE58E9AE5B9B4EFBCBFE8AABFE695B4E68385E5A0B1';
  l_element_names_tab(136) := 'BON_WP_ADJ_INFO';
  l_element_desc_tab(136) := 'Adjustment Information of Welfare Pension Insurance Premium on Bonus';
  l_element_rep_tab(136) := 'Adjustment Information (Bonus) (Welfare Pension Ins)';

  l_jp_element_names_tab(137) := 'E7B5A6EFBCBFE9809AE58BA4E68385E5A0B1EFBCBFE4BAA4E9809AE794A8E585B7';
  l_element_names_tab(137) := 'SAL_CMA_PRIVATE_TRANSPORT_INFO';
  l_element_desc_tab(137) := 'Commutation Information about Usage of Public Private Transportation (Auto Car etc)';
  l_element_rep_tab(137) := 'Commutation Information (Private Transportation)';

  l_jp_element_names_tab(138) := 'E7B5A6EFBCBFE9809AE58BA4E68385E5A0B1EFBCBFE4BAA4E9809AE6A99FE996A2';
  l_element_names_tab(138) := 'SAL_CMA_PUBLIC_TRANSPORT_INFO';
  l_element_desc_tab(138) := 'Commutation Information about Utilization of Public Transportation (Train etc)';
  l_element_rep_tab(138) := 'Commutation Information (Public Transportation)';

  l_jp_element_names_tab(139) := 'E7B5A6EFBCBFE59FBAE69CACEFBCBFE9809AE58BA4E6898BE5BD93';
  l_element_names_tab(139) := 'SAL_CMA_PROC';
  l_element_desc_tab(139) := 'Calculation of Commutation Allowance on Salary';
  l_element_rep_tab(139) := 'Commutation Allowance';

  l_jp_element_names_tab(140) := 'E7B5A6EFBCBFE7B590E69E9CEFBCBFE9809AE58BA4E6898BE5BD93EFBCBFE99D9EE8AAB2E7A88EE5AFBEE8B1A1E9A18D';
  l_element_names_tab(140) := 'SAL_CMA_NTXBL_ERN';
  l_element_desc_tab(140) := 'Non Assessable Commutation Allowance on Salary';
  l_element_rep_tab(140) := 'Commutation Allowance (Non Assessable)';

  l_jp_element_names_tab(141) := 'E7B5A6EFBCBFE7B590E69E9CEFBCBFE9809AE58BA4E6898BE5BD93EFBCBFE78FBEE789A9E58886E99D9EE8AAB2E7A88EE5AFBEE8B1A1E9A18D';
  l_element_names_tab(141) := 'SAL_CMA_NTXBL_ERN_KIND';
  l_element_desc_tab(141) := 'Non Assessable Commutation Allowance of Earning in Kind on Salary';
  l_element_rep_tab(141) := 'Commutation Allowance (Non Assessable) (In Kind)';

  l_jp_element_names_tab(142) := 'E7B5A6EFBCBFE7B590E69E9CEFBCBFE9809AE58BA4E6898BE5BD93EFBCBFE8AAB2E7A88EE5AFBEE8B1A1E9A18D';
  l_element_names_tab(142) := 'SAL_CMA_TXBL_ERN';
  l_element_desc_tab(142) := 'Assessable Commutation Allowance on Salary';
  l_element_rep_tab(142) := 'Commutation Allowance (Assessable)';

  l_jp_element_names_tab(143) := 'E7B5A6EFBCBFE7B590E69E9CEFBCBFE9809AE58BA4E6898BE5BD93EFBCBFE78FBEE789A9E58886E8AAB2E7A88EE5AFBEE8B1A1E9A18D';
  l_element_names_tab(143) := 'SAL_CMA_TXBL_ERN_KIND';
  l_element_desc_tab(143) := 'Assessable Commutation Allowance of Earning in Kind on Salary';
  l_element_rep_tab(143) := 'Commutation Allowance (Assessable) (In Kind)';

  l_jp_element_names_tab(144) := 'E7B5A6EFBCBFE7B590E69E9CEFBCBFE9809AE58BA4E6898BE5BD93EFBCBFE99D9EE5B185E4BD8FE88085E8AAB2E7A88EE5AFBEE8B1A1E9A18D';
  l_element_names_tab(144) := 'SAL_CMA_TXBL_ERN_NRES';
  l_element_desc_tab(144) := 'Assessable Commutation Allowance on Salary (Non Resident)';
  l_element_rep_tab(144) := 'Commutation Allowance (Assessable) (Non Resident)';

  l_jp_element_names_tab(145) := 'E7B5A6EFBCBFE7B590E69E9CEFBCBFE9809AE58BA4E6898BE5BD93EFBCBFE99D9EE5B185E4BD8FE88085E78FBEE789A9E58886E8AAB2E7A88EE5AFBEE8B1A1E9A18D';
  l_element_names_tab(145) := 'SAL_CMA_TXBL_ERN_KIND_NRES';
  l_element_desc_tab(145) := 'Assessable Commutation Allowance of Earning in Kind on Salary (Non Resident)';
  l_element_rep_tab(145) := 'Commutation Allowance (Assessable) (Non Resident) (In Kind)';

  l_jp_element_names_tab(146) := 'E7B5A6EFBCBFE7B590E69E9CEFBCBFE9809AE58BA4E6898BE5BD93EFBCBFE7A4BEE4BF9DE5AFBEE8B1A1E9A18DEFBCBFE98791E98AAD';
  l_element_names_tab(146) := 'SAL_CMA_ERN_MONEY_SUBJ_SI';
  l_element_desc_tab(146) := 'Commutation Allowance on Salary subject to Social Insurance';
  l_element_rep_tab(146) := 'Commutation Allowance (Amount subject to Social Insurance)';

  l_jp_element_names_tab(147) := 'E7B5A6EFBCBFE7B590E69E9CEFBCBFE9809AE58BA4E6898BE5BD93EFBCBFE7A4BEE4BF9DE5AFBEE8B1A1E9A18DEFBCBFE78FBEE789A9';
  l_element_names_tab(147) := 'SAL_CMA_ERN_KIND_SUBJ_SI';
  l_element_desc_tab(147) := 'Commutation Allowance of Earning in Kind on Salary subject to Social Insurance';
  l_element_rep_tab(147) := 'Commutation Allowance (Amount subj to Social Ins) (In Kind)';

  l_jp_element_names_tab(148) := 'E7B5A6EFBCBFE7B590E69E9CEFBCBFE9809AE58BA4E6898BE5BD93EFBCBFE7A4BEE4BF9DE5AFBEE8B1A1E9A18DEFBCBFE98791E98AADEFBCBFE3839EE382A4E3838AE382B9E8AABFE695B4';
  l_element_names_tab(148) := 'SAL_CMA_ERN_MONEY_SUBJ_SI_NEGATIVE_ADJ';
  l_element_desc_tab(148) := 'Subtract Adjustment of Commutation Allowance on Salary subject to Social Insurance';
  l_element_rep_tab(148) := 'Commutation Allowance (Amount subj to Social Ins Adjustment)';

  l_jp_element_names_tab(149) := 'E7B5A6EFBCBFE7B590E69E9CEFBCBFE9809AE58BA4E6898BE5BD93EFBCBFE7A4BEE4BF9DE5AFBEE8B1A1E9A18DEFBCBFE78FBEE789A9EFBCBFE3839EE382A4E3838AE382B9E8AABFE695B4';
  l_element_names_tab(149) := 'SAL_CMA_ERN_KIND_SUBJ_SI_NEGATIVE_ADJ';
  l_element_desc_tab(149) := 'Subtract Adjustment of Commutation Allowance of Earning in Kind on Salary subject to Social Insurance';
  l_element_rep_tab(149) := 'Commutation Allowance (Amt subj to Social Ins Adj) (In Kind)';

  l_jp_element_names_tab(150) := 'E7B5A6EFBCBFE7B590E69E9CEFBCBFE9809AE58BA4E6898BE5BD93EFBCBFE7A4BEE4BF9DE59BBAE5AE9AE79A84E8B383E98791';
  l_element_names_tab(150) := 'SAL_CMA_SUBJ_SI_FIXED_WAGE';
  l_element_desc_tab(150) := 'Commutation Allowance on Salary (Social Insurance Fixed Wage)';
  l_element_rep_tab(150) := 'Commutation Allowance (Social Insurance Fixed Wage)';

  l_jp_element_names_tab(151) := 'E7B5A6EFBCBFE7B590E69E9CEFBCBFE9809AE58BA4E6898BE5BD93EFBCBFE99B87E4BF9DE5AFBEE8B1A1E9A18DE69C88E589B2E8AABFE695B4';
  l_element_names_tab(151) := 'SAL_CMA_MTHLY_ERN_SUBJ_EI_ADJ';
  l_element_desc_tab(151) := 'Commutation Allowance on Salary (Amount subject to Employment Insurance by Month)';
  l_element_rep_tab(151) := 'Commutation Allowance (Amt subj to Employment Ins by Month)';

  l_jp_element_names_tab(152) := 'E7B5A6EFBCBFE7B590E69E9CEFBCBFE4BB8BE4BF9DEFBCBFE4BA8BE6A5ADE4B8BBEFBCBFE98080E881B7E69C88';
  l_element_names_tab(152) := 'SAL_CI_PREM_ER_TRM';
  l_element_desc_tab(152) := 'Termination Month Care Insurance Premium on Salary (Employer Burden)';
  l_element_rep_tab(152) := 'Care Insurance Premium (Employer) (Termination Month)';

  l_jp_element_names_tab(153) := 'E7B5A6EFBCBFE7B590E69E9CEFBCBFE4BB8BE4BF9DEFBCBFE8A2ABE4BF9DE999BAE88085EFBCBFE98080E881B7E69C88';
  l_element_names_tab(153) := 'SAL_CI_PREM_EE_TRM';
  l_element_desc_tab(153) := 'Termination Month Care Insurance Premium on Salary (Insured Burden)';
  l_element_rep_tab(153) := 'Care Insurance Premium (Termination Month)';

  l_jp_element_names_tab(154) := 'E7B5A6EFBCBFE7B590E69E9CEFBCBFE4BB8BE4BF9DEFBCBFE8A2ABE4BF9DE999BAE88085EFBCBFE99D9EE5B185E4BD8FE88085EFBCBFE98080E881B7E69C88';
  l_element_names_tab(154) := 'SAL_CI_PREM_EE_NRES_TRM';
  l_element_desc_tab(154) := 'Termination Month Care Insurance Premium on Salary not subject to Year End Adjustment (Non Resident)';
  l_element_rep_tab(154) := 'Care Insurance Premium (Non Resident) (Termination Month)';

  l_jp_element_names_tab(155) := 'E7B5A6EFBCBFE7B590E69E9CEFBCBFE59FBAE98791EFBCBFE4BA8BE6A5ADE4B8BBEFBCBFE98080E881B7E69C88';
  l_element_names_tab(155) := 'SAL_WPF_PREM_ER_TRM';
  l_element_desc_tab(155) := 'Termination Month Welfare Pension Fund Insurance Premium on Salary (Employer Burden)';
  l_element_rep_tab(155) := 'Welfare Pension Fund Ins Prem (Employer) (Termination Month)';

  l_jp_element_names_tab(156) := 'E7B5A6EFBCBFE7B590E69E9CEFBCBFE59FBAE98791EFBCBFE8A2ABE4BF9DE999BAE88085EFBCBFE98080E881B7E69C88';
  l_element_names_tab(156) := 'SAL_WPF_PREM_EE_TRM';
  l_element_desc_tab(156) := 'Termination Month Welfare Pension Fund Insurance Premium on Salary (Insured Burden)';
  l_element_rep_tab(156) := 'Welfare Pension Fund Insurance Premium (Termination Month)';

  l_jp_element_names_tab(157) := 'E7B5A6EFBCBFE7B590E69E9CEFBCBFE59FBAE98791EFBCBFE8A2ABE4BF9DE999BAE88085EFBCBFE99D9EE5B185E4BD8FE88085EFBCBFE98080E881B7E69C88';
  l_element_names_tab(157) := 'SAL_WPF_PREM_EE_NRES_TRM';
  l_element_desc_tab(157) := 'Termination Month Welfare Pension Fund Insurance Premium on Salary not subject to Year End Adjustment (Non Resident)';
  l_element_rep_tab(157) := 'Welfare Pension Fund Ins Prem (Non Resident) (Term Month)';

  l_jp_element_names_tab(158) := 'E7B5A6EFBCBFE7B590E69E9CEFBCBFE581A5E4BF9DEFBCBFE4BA8BE6A5ADE4B8BBEFBCBFE98080E881B7E69C88';
  l_element_names_tab(158) := 'SAL_HI_PREM_ER_TRM';
  l_element_desc_tab(158) := 'Termination Month Health Insurance Premium on Salary (Employer Burden)';
  l_element_rep_tab(158) := 'Health Insurance Premium (Employer) (Termination Month)';

  l_jp_element_names_tab(159) := 'E7B5A6EFBCBFE7B590E69E9CEFBCBFE581A5E4BF9DEFBCBFE8A2ABE4BF9DE999BAE88085EFBCBFE98080E881B7E69C88';
  l_element_names_tab(159) := 'SAL_HI_PREM_EE_TRM';
  l_element_desc_tab(159) := 'Termination Month Health Insurance Premium on Salary (Insured Burden)';
  l_element_rep_tab(159) := 'Health Insurance Premium (Termination Month)';

  l_jp_element_names_tab(160) := 'E7B5A6EFBCBFE7B590E69E9CEFBCBFE581A5E4BF9DEFBCBFE8A2ABE4BF9DE999BAE88085EFBCBFE99D9EE5B185E4BD8FE88085EFBCBFE98080E881B7E69C88';
  l_element_names_tab(160) := 'SAL_HI_PREM_EE_NRES_TRM';
  l_element_desc_tab(160) := 'Termination Month Health Insurance Premium on Salary not subject to Year End Adjustment (Non Resident)';
  l_element_rep_tab(160) := 'Health Insurance Premium (Non Resident) (Termination Month)';

  l_jp_element_names_tab(161) := 'E7B5A6EFBCBFE7B590E69E9CEFBCBFE58E9AE5B9B4EFBCBFE4BA8BE6A5ADE4B8BBEFBCBFE98080E881B7E69C88';
  l_element_names_tab(161) := 'SAL_WP_PREM_ER_TRM';
  l_element_desc_tab(161) := 'Termination Month Welfare Pension Insurance Premium on Salary (Employer Burden)';
  l_element_rep_tab(161) := 'Welfare Pension Insurance Prem (Employer) (Termination Month)';

  l_jp_element_names_tab(162) := 'E7B5A6EFBCBFE7B590E69E9CEFBCBFE58E9AE5B9B4EFBCBFE8A2ABE4BF9DE999BAE88085EFBCBFE98080E881B7E69C88';
  l_element_names_tab(162) := 'SAL_WP_PREM_EE_TRM';
  l_element_desc_tab(162) := 'Termination Month Welfare Pension Insurance Premium on Salary (Insured Burden)';
  l_element_rep_tab(162) := 'Welfare Pension Insurance Premium (Termination Month)';

  l_jp_element_names_tab(163) := 'E7B5A6EFBCBFE7B590E69E9CEFBCBFE58E9AE5B9B4EFBCBFE8A2ABE4BF9DE999BAE88085EFBCBFE99D9EE5B185E4BD8FE88085EFBCBFE98080E881B7E69C88';
  l_element_names_tab(163) := 'SAL_WP_PREM_EE_NRES_TRM';
  l_element_desc_tab(163) := 'Termination Month Welfare Pension Insurance Premium on Salary not subject to  Year End Adjustment (Non Resident)';
  l_element_rep_tab(163) := 'Welfare Pension Ins Prem (Non Resident) (Termination Month)';

  l_jp_element_names_tab(164) := 'E585B1EFBCBFE99D9EE5B185E4BD8FE88085EFBCBFE68385E5A0B1';
  l_element_names_tab(164) := 'COM_NRES_INFO';
  l_element_desc_tab(164) := 'Information for Non Resident';
  l_element_rep_tab(164) := 'Non Resident Information';

  l_jp_element_names_tab(165) := 'E882B2E694B9EFBCBFE59FBAE69CACEFBCBFE5A0B1E985ACE69C88E9A18D';
  l_element_names_tab(165) := 'IKU_MR_PROC';
  l_element_desc_tab(165) := 'Calculation of Standard Monthly Remuneration on Unscheduled Revision after Child-Care Leave';
  l_element_rep_tab(165) := 'Monthly Remuneration (Ikukai)';

  l_jp_element_names_tab(166) := 'E882B2E694B9EFBCBFE7B590E69E9C';
  l_element_names_tab(166) := 'IKU_RSLT';
  l_element_desc_tab(166) := 'Monthly Remuneration etc on Unscheduled Revision after Child-Care Leave';
  l_element_rep_tab(166) := 'Standard Monthly Remuneration (Ikukai)';

  l_jp_element_names_tab(167) := 'E882B2E694B9EFBCBFE8AABFE695B4E68385E5A0B1';
  l_element_names_tab(167) := 'IKU_ADJ_INFO';
  l_element_desc_tab(167) := 'Adjustment Information of Remuneration Amount for Unscheduled Revision after Child-Care Leave';
  l_element_rep_tab(167) := 'Adjustment Information (Ikukai)';

  l_jp_element_names_tab(168) := 'E882B2E694B9EFBCBFE69C88E9A18DE5A489E69BB4E5B18AEFBCBFE58299E88083E6AC84';
  l_element_names_tab(168) := 'IKU_REPORT_RMKS_ADJ_INFO';
  l_element_desc_tab(168) := 'Remarks Column Information for Notification of Geppen at the end of Child-Care Leave';
  l_element_rep_tab(168) := 'Remarks Column (Ikukai)';



  l_jp_element_names_tab(169) := '59656120496E737572616E636520446564756374696F6E20466F726D';
  l_element_names_tab(169) := 'YEA_INS_PREM_EXM_DECLARE_INFO';
  l_element_desc_tab(169) := 'Declaration Finalized Content Information of Insurance Premium Exemtion Declaration and Spouse Special Exemption Declaration';
  l_element_rep_tab(169) := 'Insurance Premium and Spouse Special Exemption';

  hr_utility.set_location(l_proc, 20);

  if (g_dbg) then
    hr_utility.trace('| Element Type Count = ' || l_jp_element_names_tab.COUNT);
    hr_utility.trace('+-------------------------------+ ');
  end if;
--

  FORALL l_tab_cnt IN 1..l_jp_element_names_tab.COUNT

    UPDATE pay_element_types_f
    SET    element_name = l_element_names_tab(l_tab_cnt),
           description = l_element_desc_tab(l_tab_cnt),
           reporting_name = l_element_rep_tab(l_tab_cnt)
    WHERE  element_name LIKE hr_jp_standard_pkg.hextochar(l_jp_element_names_tab(l_tab_cnt),'AL32UTF8')
    AND    legislation_code = 'JP';

  UPDATE pay_element_types_f
  SET    description = description || 'Obsoleted'
  WHERE  ASCII(description) > 127
  AND    legislation_code = 'JP';

  hr_utility.set_location(l_proc, 30);

  if (g_dbg) then
    hr_utility.trace('| Total Elements Updated = ' || SQL%ROWCOUNT);
    hr_utility.trace('+-------------------------------+ ');
  end if;
--
EXCEPTION

  WHEN OTHERS THEN

    hr_utility.set_location(l_proc, 40);

    raise;

END migrate_element_types;
--
-- |-------------------------------------------------------------------|
-- |---------------------< migrate_element_class >---------------------|
-- |-------------------------------------------------------------------|
--
procedure migrate_element_class is
--
  type t_jp_class_name is table of VARCHAR2(200) index by binary_integer;

  type t_class_names_tab is table of pay_element_classifications.classification_name%TYPE index by binary_integer;

  type t_class_desc_tab is table of pay_element_classifications.description%TYPE index by binary_integer;

  l_jp_class_name      t_jp_class_name;
  l_class_names_tab    t_class_names_tab;
  l_class_desc_tab     t_class_desc_tab;

  l_proc              VARCHAR2(50) := g_pkg||'.migrate_element_class';

BEGIN

  l_jp_class_name.DELETE;
  l_class_names_tab.DELETE;
  l_class_desc_tab.DELETE;

  hr_utility.set_location(l_proc, 10);

  l_jp_class_name(1) := 'C%2401%';
  l_class_names_tab(1) := 'TRM_ERN_KIND_TXBL';
  l_class_desc_tab(1) := 'Taxable Earning in Kind for Termination Payment (Resident)';

  l_jp_class_name(2) := 'C%2402%';
  l_class_names_tab(2) := 'TRM_ERN_KIND_NRES_TXBL';
  l_class_desc_tab(2) := 'Taxable Earning in Kind for Term Payment (Non Resident)';

  l_jp_class_name(3) := 'C%1103%';
  l_class_names_tab(3) := 'BON_SI_EI_PREM';
  l_class_desc_tab(3) := 'Employment Insurance Premium for Bonus (Resident)';

  l_jp_class_name(4) := 'C%1102%';
  l_class_names_tab(4) := 'BON_SI_WP_PREM';
  l_class_desc_tab(4) := 'Welfare Pension Insurance Premium for Bonus (Resident)';

  l_jp_class_name(5) := 'C%1101%';
  l_class_names_tab(5) := 'BON_SI_HI_PREM';
  l_class_desc_tab(5) := 'Health Insurance Premium for Bonus (Resident)';

  l_jp_class_name(6) := 'C%1752%';
  l_class_names_tab(6) := 'SPB_SI_NRES_SMALL_COMPANY_MUTUAL_AID_PREM';
  l_class_desc_tab(6) := 'Small Company Mutual Aid Prem for Spcl Bonus (Non Resident)';

  l_jp_class_name(7) := 'C%1751%';
  l_class_names_tab(7) := 'SPB_SI_NRES_EI_PREM';
  l_class_desc_tab(7) := 'Employment Insurance Premium for Special Bonus (Non Resident)';

  l_jp_class_name(8) := 'C%1702%';
  l_class_names_tab(8) := 'SPB_SI_SMALL_COMPANY_MUTUAL_AID_PREM';
  l_class_desc_tab(8) := 'Small Company Mutual Aid Premium for Special Bonus (Resident)';

  l_jp_class_name(9) := 'C%1701%';
  l_class_names_tab(9) := 'SPB_SI_EI_PREM';
  l_class_desc_tab(9) := 'Employment Insurance Premium for Special Bonus (Resident)';

  l_jp_class_name(10) := 'C%1501%';
  l_class_names_tab(10) := 'SPB_ERN_MONEY_TXBL';
  l_class_desc_tab(10) := 'Taxable Earning in Money for Special Bonus (Resident)';

  l_jp_class_name(11) := 'C%1504%';
  l_class_names_tab(11) := 'SPB_ERN_MONEY_SUBJ_EI';
  l_class_desc_tab(11) := 'Earning in Money subject to Employment Ins for Special Bonus';

  l_jp_class_name(12) := 'C%1505%';
  l_class_names_tab(12) := 'SPB_ERN_MONEY_TXBL_NRES';
  l_class_desc_tab(12) := 'Taxable Earning in Money for Special Bonus (Non Resident)';

  l_jp_class_name(13) := 'C%1503%';
  l_class_names_tab(13) := 'SPB_ERN_MONEY_SUBJ_LI';
  l_class_desc_tab(13) := 'Earning in Money subj to Work Accident Ins for Special Bonus';

  l_jp_class_name(14) := 'C%1502%';
  l_class_names_tab(14) := 'SPB_ERN_MONEY_SUBJ_SI';
  l_class_desc_tab(14) := 'Earning in Money subject to Social Ins for Special Bonus';

  l_jp_class_name(15) := 'C%1602%';
  l_class_names_tab(15) := 'SPB_ERN_KIND_SUBJ_SI';
  l_class_desc_tab(15) := 'Earning in Kind subject to Social Insurance for Special Bonus';

  l_jp_class_name(16) := 'C%1605%';
  l_class_names_tab(16) := 'SPB_ERN_KIND_TXBL_NRES';
  l_class_desc_tab(16) := 'Taxable Earning in Kind for Special Bonus (Non Resident)';

  l_jp_class_name(17) := 'C%1603%';
  l_class_names_tab(17) := 'SPB_ERN_KIND_SUBJ_LI';
  l_class_desc_tab(17) := 'Earning in Kind subj to Work Accident Ins for Special Bonus';

  l_jp_class_name(18) := 'C%1601%';
  l_class_names_tab(18) := 'SPB_ERN_KIND_TXBL';
  l_class_desc_tab(18) := 'Taxable Earning in Kind for Special Bonus (Resident)';

  l_jp_class_name(19) := 'C%1604%';
  l_class_names_tab(19) := 'SPB_ERN_KIND_SUBJ_EI';
  l_class_desc_tab(19) := 'Earning in Kind subject to Employment Ins for Special Bonus';

  l_jp_class_name(20) := 'C%2301%';
  l_class_names_tab(20) := 'TRM_ERN_MONEY_TXBL';
  l_class_desc_tab(20) := 'Taxable Earning in Money for Termination Payment (Resident)';

  l_jp_class_name(21) := 'C%2302%';
  l_class_names_tab(21) := 'TRM_ERN_MONEY_TXBL_NRES';
  l_class_desc_tab(21) := 'Taxable Earning in Money for Term Payment (Non Resident)';

  l_jp_class_name(22) := 'C%0402%';
  l_class_names_tab(22) := 'SAL_ERN_KIND_SUBJ_SI';
  l_class_desc_tab(22) := 'Earning in Kind subject to Social Insurance for Salary';

  l_jp_class_name(23) := 'C%0404%';
  l_class_names_tab(23) := 'SAL_ERN_KIND_SUBJ_EI';
  l_class_desc_tab(23) := 'Earning in Kind subject to Employment Insurance for Salary';

  l_jp_class_name(24) := 'C%0405%';
  l_class_names_tab(24) := 'SAL_ERN_KIND_TXBL_NRES';
  l_class_desc_tab(24) := 'Taxable Earning in Kind for Salary (Non Resident)';

  l_jp_class_name(25) := 'C%0503%';
  l_class_names_tab(25) := 'SAL_SI_WPF_PREM';
  l_class_desc_tab(25) := 'Welfare Pension Fund Insurance Premium for Salary (Resident)';

  l_jp_class_name(26) := 'C%0502%';
  l_class_names_tab(26) := 'SAL_SI_WP_PREM';
  l_class_desc_tab(26) := 'Welfare Pension Insurance Premium for Salary (Resident)';

  l_jp_class_name(27) := 'C%0501%';
  l_class_names_tab(27) := 'SAL_SI_HI_PREM';
  l_class_desc_tab(27) := 'Health Insurance Premium for Salary (Resident)';

  l_jp_class_name(28) := 'C%2101%';
  l_class_names_tab(28) := 'YEA_ITX';
  l_class_desc_tab(28) := 'Over and Short Tax Amount for Year End Adjustment';

  l_jp_class_name(29) := 'C%0301%';
  l_class_names_tab(29) := 'SAL_ERN_MONEY_TXBL';
  l_class_desc_tab(29) := 'Taxable Earning in Money for Salary (Resident)';

  l_jp_class_name(30) := 'C%0304%';
  l_class_names_tab(30) := 'SAL_ERN_MONEY_SUBJ_EI';
  l_class_desc_tab(30) := 'Earning in Money subject to Employment Insurance for Salary';

  l_jp_class_name(31) := 'C%0303%';
  l_class_names_tab(31) := 'SAL_ERN_MONEY_SUBJ_LI';
  l_class_desc_tab(31) := 'Earning in Money subject to Work Accident Ins for Salary';

  l_jp_class_name(32) := 'C%0305%';
  l_class_names_tab(32) := 'SAL_ERN_MONEY_TXBL_NRES';
  l_class_desc_tab(32) := 'Taxable Earning in Money for Salary (Non Resident)';

  l_jp_class_name(33) := 'C%0302%';
  l_class_names_tab(33) := 'SAL_ERN_MONEY_SUBJ_SI';
  l_class_desc_tab(33) := 'Earning in Money subject to Social Insurance for Salary';

  l_jp_class_name(34) := 'C%1003%';
  l_class_names_tab(34) := 'BON_ERN_KIND_SUBJ_WAI';
  l_class_desc_tab(34) := 'Earning in Kind subject to Work Accident Insurance for Bonus';

  l_jp_class_name(35) := 'C%1005%';
  l_class_names_tab(35) := 'BON_ERN_KIND_TXBL_NRES';
  l_class_desc_tab(35) := 'Taxable Earning in Kind for Bonus (Non Resident)';

  l_jp_class_name(36) := 'C%1004%';
  l_class_names_tab(36) := 'BON_ERN_KIND_SUBJ_EI';
  l_class_desc_tab(36) := 'Earning in Kind subject to Employment Insurance for Bonus';

  l_jp_class_name(37) := 'C%1001%';
  l_class_names_tab(37) := 'BON_ERN_KIND_TXBL';
  l_class_desc_tab(37) := 'Taxable Earning in Kind for Bonus (Resident)';

  l_jp_class_name(38) := 'C%1002%';
  l_class_names_tab(38) := 'BON_ERN_KIND_SUBJ_SI';
  l_class_desc_tab(38) := 'Earning in Kind subject to Social Insurance for Bonus';

  l_jp_class_name(39) := 'C%0401%';
  l_class_names_tab(39) := 'SAL_ERN_KIND_TXBL';
  l_class_desc_tab(39) := 'Taxable Earning in Kind for Salary (Resident)';

  l_jp_class_name(40) := 'C%0403%';
  l_class_names_tab(40) := 'SAL_ERN_KIND_SUBJ_WAI';
  l_class_desc_tab(40) := 'Earning in Kind subject to Work Accident Insurance for Salary';

  l_jp_class_name(41) := 'C%0500%';
  l_class_names_tab(41) := 'SAL_SI';
  l_class_desc_tab(41) := 'Pre Tax Deduction of Social Ins etc for Salary (Resident)';

  l_jp_class_name(42) := 'C%0400%';
  l_class_names_tab(42) := 'SAL_ERN_KIND';
  l_class_desc_tab(42) := 'Earning in Kind for Salary';

  l_jp_class_name(43) := 'C%1000%';
  l_class_names_tab(43) := 'BON_ERN_KIND';
  l_class_desc_tab(43) := 'Earning in Kind for Bonus';

  l_jp_class_name(44) := 'C%0300%';
  l_class_names_tab(44) := 'SAL_ERN_MONEY';
  l_class_desc_tab(44) := 'Earning in Money for Salary';

  l_jp_class_name(45) := 'C%2100%';
  l_class_names_tab(45) := 'YEA';
  l_class_desc_tab(45) := 'Item for Year End Adjustment';

  l_jp_class_name(46) := 'C%1300%';
  l_class_names_tab(46) := 'BON_DCT';
  l_class_desc_tab(46) := 'Deduction for Bonus';

  l_jp_class_name(47) := 'C%2800%';
  l_class_names_tab(47) := 'SAN';
  l_class_desc_tab(47) := 'Item for Santei';

  l_jp_class_name(48) := 'C%0505%';
  l_class_names_tab(48) := 'SAL_SI_SMALL_COMPANY_MUTUAL_AID_PREM';
  l_class_desc_tab(48) := 'Small Company Mutual Aid Premium for Salary (Resident)';

  l_jp_class_name(49) := 'C%0504%';
  l_class_names_tab(49) := 'SAL_SI_EI_PREM';
  l_class_desc_tab(49) := 'Employment Insurance Premium for Salary (Resident)';

  l_jp_class_name(50) := 'C%1153%';
  l_class_names_tab(50) := 'BON_SI_NRES_EI_PREM';
  l_class_desc_tab(50) := 'Employment Insurance Premium for Bonus (Non Resident)';

  l_jp_class_name(51) := 'C%0700%';
  l_class_names_tab(51) := 'SAL_DCT';
  l_class_desc_tab(51) := 'Deduction for Salary';

  l_jp_class_name(52) := 'C%1150%';
  l_class_names_tab(52) := 'BON_SI_NRES';
  l_class_desc_tab(52) := 'Pre Tax Deduction of Social Ins etc for Bonus (Non Resident)';

  l_jp_class_name(53) := 'C%0550%';
  l_class_names_tab(53) := 'SAL_SI_NRES';
  l_class_desc_tab(53) := 'Pre Tax Deduction of Social Ins etc for Salary (Non Resident)';

  l_jp_class_name(54) := 'C%0900%';
  l_class_names_tab(54) := 'BON_ERN_MONEY';
  l_class_desc_tab(54) := 'Earning in Money for Bonus';

  l_jp_class_name(55) := 'C%1100%';
  l_class_names_tab(55) := 'BON_SI';
  l_class_desc_tab(55) := 'Pre Tax Deduction of Social Ins etc for Bonus (Resident)';

  l_jp_class_name(56) := 'C%2900%';
  l_class_names_tab(56) := 'GEP';	l_class_desc_tab(56) := 'Item for Geppen';

  l_jp_class_name(57) := 'C%2400%';
  l_class_names_tab(57) := 'TRM_ERN_KIND';
  l_class_desc_tab(57) := 'Earning in Kind Item for Termination Payment';

  l_jp_class_name(58) := 'C%2200%';
  l_class_names_tab(58) := 'TRM_INFO';
  l_class_desc_tab(58) := 'Information for Termination Payment';

  l_jp_class_name(59) := 'C%2700%';
  l_class_names_tab(59) := 'TRM_DCT';
  l_class_desc_tab(59) := 'Deduction for Termination Payment';

  l_jp_class_name(60) := 'C%2600%';
  l_class_names_tab(60) := 'TRM_PROC_INFO';
  l_class_desc_tab(60) := 'Middle Process Information for Termination Payment';

  l_jp_class_name(61) := 'C%0600%';
  l_class_names_tab(61) := 'SAL_PROC_INFO';
  l_class_desc_tab(61) := 'Middle Process Information for Salary';

  l_jp_class_name(62) := 'C%0800%';
  l_class_names_tab(62) := 'BON_INFO';
  l_class_desc_tab(62) := 'Information for Bonus';

  l_jp_class_name(63) := 'C%1200%';
  l_class_names_tab(63) := 'BON_PROC_INFO';
  l_class_desc_tab(63) := 'Middle Process Information for Bonus';

  l_jp_class_name(64) := 'C%2000%';
  l_class_names_tab(64) := 'YEA_INFO';
  l_class_desc_tab(64) := 'Information for Year End Adjustment';

  l_jp_class_name(65) := 'C%3000%';
  l_class_names_tab(65) := 'ER_CHARGE';
  l_class_desc_tab(65) := 'Employer Burden Item';

  l_jp_class_name(66) := 'C%0200%';
  l_class_names_tab(66) := 'SAL_INFO';
  l_class_desc_tab(66) := 'Information for Salary';

  l_jp_class_name(67) := 'C%2300%';
  l_class_names_tab(67) := 'TRM_ERN_MONEY';
  l_class_desc_tab(67) := 'Earning in Money for Termination Payment';

  l_jp_class_name(68) := 'C%2500%';
  l_class_names_tab(68) := 'TRM_PRE_TAX_DCT';
  l_class_desc_tab(68) := 'Pre Tax Deduction for Termination Payment';

  l_jp_class_name(69) := 'C%1600%';
  l_class_names_tab(69) := 'SPB_ERN_KIND';
  l_class_desc_tab(69) := 'Earning in Kind for Special Bonus';

  l_jp_class_name(70) := 'C%1400%';
  l_class_names_tab(70) := 'SPB_INFO';
  l_class_desc_tab(70) := 'Information for Special Bonus';

  l_jp_class_name(71) := 'C%1900%';
  l_class_names_tab(71) := 'SPB_DCT';
  l_class_desc_tab(71) := 'Deduction for Special Bonus';

  l_jp_class_name(72) := 'C%1700%';
  l_class_names_tab(72) := 'SPB_SI';
  l_class_desc_tab(72) := 'Pre Tax Ded of Social Ins etc for Spcl Bonus (Resident)';

  l_jp_class_name(73) := 'C%1750%';
  l_class_names_tab(73) := 'SPB_SI_NRES';
  l_class_desc_tab(73) := 'Pre Tax Ded of Social Ins etc for Spcl Bonus (Non Resident)';

  l_jp_class_name(74) := 'C%1800%';
  l_class_names_tab(74) := 'SPB_PROC_INFO';
  l_class_desc_tab(74) := 'Middle Process Information for Special Bonus';

  l_jp_class_name(75) := 'C%1500%';
  l_class_names_tab(75) := 'SPB_ERN_MONEY';
  l_class_desc_tab(75) := 'Earning in Money for Special Bonus';

  l_jp_class_name(76) := 'C%1104%';
  l_class_names_tab(76) := 'BON_SI_SMALL_COMPANY_MUTUAL_AID_PREM';
  l_class_desc_tab(76) := 'Small Company Mutual Aid Premium for Bonus (Resident)';

  l_jp_class_name(77) := 'C%1105%';
  l_class_names_tab(77) := 'BON_SI_WPF_PREM';
  l_class_desc_tab(77) := 'Welfare Pension Fund Insurance Premium for Bonus (Resident)';

  l_jp_class_name(78) := 'C%0902%';
  l_class_names_tab(78) := 'BON_ERN_MONEY_SUBJ_SI';
  l_class_desc_tab(78) := 'Earning in Money subject to Social Insurance for Bonus';

  l_jp_class_name(79) := 'C%0904%';
  l_class_names_tab(79) := 'BON_ERN_MONEY_SUBJ_EI';
  l_class_desc_tab(79) := 'Earning in Money subject to Employment Insurance for Bonus';

  l_jp_class_name(80) := 'C%0903%';
  l_class_names_tab(80) := 'BON_ERN_MONEY_SUBJ_WAI';
  l_class_desc_tab(80) := 'Earning in Money subject to Work Accident Insurance for Bonus';

  l_jp_class_name(81) := 'C%0905%';
  l_class_names_tab(81) := 'BON_ERN_MONEY_TXBL_NRES';
  l_class_desc_tab(81) := 'Assessable Earning in Money for Bonus (Non Resident)';

  l_jp_class_name(82) := 'C%0901%';
  l_class_names_tab(82) := 'BON_ERN_MONEY_TXBL';
  l_class_desc_tab(82) := 'Taxable Earning in Money for Bonus (Resident)';

  l_jp_class_name(83) := 'C%0555%';
  l_class_names_tab(83) := 'SAL_SI_NRES_SMALL_COMPANY_MUTUAL_AID_PREM';
  l_class_desc_tab(83) := 'Small Company Mutual Aid Premium for Salary (Non Resident)';

  l_jp_class_name(84) := 'C%0553%';
  l_class_names_tab(84) := 'SAL_SI_NRES_WPF_PREM';
  l_class_desc_tab(84) := 'Welfare Pension Fund Ins Premium for Salary (Non Resident)';

  l_jp_class_name(85) := 'C%0554%';
  l_class_names_tab(85) := 'SAL_SI_NRES_EI_PREM';
  l_class_desc_tab(85) := 'Employment Insurance Premium for Salary (Non Resident)';

  l_jp_class_name(86) := 'C%0552%';
  l_class_names_tab(86) := 'SAL_SI_NRES_WP_PREM';
  l_class_desc_tab(86) := 'Welfare Pension Insurance Premium for Salary (Non Resident)';

  l_jp_class_name(87) := 'C%0551%';
  l_class_names_tab(87) := 'SAL_SI_NRES_HI_PREM';
  l_class_desc_tab(87) := 'Health Insurance Premium for Salary (Non Resident)';

  l_jp_class_name(88) := 'C%1155%';
  l_class_names_tab(88) := 'BON_SI_NRES_WPF_PREM';
  l_class_desc_tab(88) := 'Welfare Pension Fund Ins Premium for Bonus (Non Resident)';

  l_jp_class_name(89) := 'C%1154%';
  l_class_names_tab(89) := 'BON_SI_NRES_SMALL_COMPANY_MUTUAL_AID_PREM';
  l_class_desc_tab(89) := 'Small Company Mutual Aid Premium for Bonus (Non Resident)';

  l_jp_class_name(90) := 'C%1151%';
  l_class_names_tab(90) := 'BON_SI_NRES_HI_PREM';
  l_class_desc_tab(90) := 'Health Insurance Premium for Bonus (Non Resident)';

  l_jp_class_name(91) := 'C%1152%';
  l_class_names_tab(91) := 'BON_SI_NRES_WP_PREM';
  l_class_desc_tab(91) := 'Welfare Pension Insurance Premium for Bonus (Non Resident)';

  l_jp_class_name(92) := 'C%0100%';
  l_class_names_tab(92) := 'BASIC_INFO';
  l_class_desc_tab(92) := 'Basic Information';

  hr_utility.set_location(l_proc, 20);

  if (g_dbg) then
    hr_utility.trace('| Element Classification Count = ' || l_jp_class_name.COUNT);
    hr_utility.trace('+--------------------------------------------+ ');
  end if;
--

  FORALL l_tab_cnt IN 1..l_jp_class_name.COUNT

    UPDATE pay_element_classifications
    SET    classification_name = l_class_names_tab(l_tab_cnt),
           description = l_class_desc_tab(l_tab_cnt)
    WHERE  classification_name LIKE l_jp_class_name(l_tab_cnt)
    AND    legislation_code = 'JP';

  hr_utility.set_location(l_proc, 30);

  if (g_dbg) then
    hr_utility.trace('| Total Classifications Updated = ' || SQL%ROWCOUNT);
    hr_utility.trace('+-------------------------------+ ');
  end if;
--
EXCEPTION

  WHEN OTHERS THEN

    hr_utility.set_location(l_proc, 40);

    raise;

END migrate_element_class;
--
-- |-------------------------------------------------------------------|
-- |--------------------< migrate_balance_types >----------------------|
-- |-------------------------------------------------------------------|
--
procedure migrate_balance_types is
--
  type t_jp_bal_names_tab is table of VARCHAR2(200) index by binary_integer;

  type t_bal_names_tab is table of pay_balance_types.balance_name%TYPE index by binary_integer;

  type t_bal_rep_tab is table of pay_balance_types.reporting_name%TYPE index by binary_integer;

  l_jp_bal_names_tab  t_jp_bal_names_tab;
  l_bal_names_tab     t_bal_names_tab;
  l_bal_rep_tab       t_bal_rep_tab;

  l_proc              VARCHAR2(50) := g_pkg||'.migrate_balance_types';

BEGIN

  l_jp_bal_names_tab.DELETE;
  l_bal_names_tab.DELETE;
  l_bal_rep_tab.DELETE;

  hr_utility.set_location(l_proc, 10);

  l_jp_bal_names_tab(1) := '42EFBCBFE585B1EFBCBFE58E9AE7949FE5B9B4E98791E4BF9DE999BAE69699E59088E8A888';
  l_bal_names_tab(1) := 'B_COM_WP_PREM';
  l_bal_rep_tab(1) := 'Welfare Pension Insurance Premium';

  l_jp_bal_names_tab(2) := '42EFBCBFE69C88EFBCBFE59BBAE5AE9AE79A84E8B383E98791';
  l_bal_names_tab(2) := 'B_GEP_FIXED_WAGE';
  l_bal_rep_tab(2) := 'Fixed Wage';

  l_jp_bal_names_tab(3) := '42EFBCBFE585B1EFBCBFE7AE97E5AE9AE69C88E5A489EFBCBFE789B9E588A5E8B39EE4B88EE78FBEE789A9';
  l_bal_names_tab(3) := 'B_COM_SAN_GEP_SP_BON_ERN_KIND';
  l_bal_rep_tab(3) := 'Special Bonus in Kind';

  l_jp_bal_names_tab(4) := '42EFBCBFE98080EFBCBFE78FBEE789A9E58886E8AAB2E7A88EE9A18DE59088E8A888';
  l_bal_names_tab(4) := 'B_TRM_TXBL_ERN_KIND';
  l_bal_rep_tab(4) := 'Total Assessable Amount (in Kind)';

  l_jp_bal_names_tab(5) := '42EFBCBFE5B9B4EFBCBFE5B9B4E7A88EE9A18D';
  l_bal_names_tab(5) := 'B_YEA_ANNUAL_TAX';
  l_bal_rep_tab(5) := 'Annual Tax Amount';

  l_jp_bal_names_tab(6) := '42EFBCBFE98080EFBCBFE4BD8FE6B091E7A88EE9A18DEFBCBFE789B9E588A5E5BEB4E58F8EEFBCBFE7A88EE9A18D';
  l_bal_names_tab(6) := 'B_TRM_LTX_SP_WITHHOLD_TAX';
  l_bal_rep_tab(6) := 'Special Collecting Local Tax';

  l_jp_bal_names_tab(7) := '42EFBCBFE789B9E8B39EEFBCBFE7A4BEE4BC9AE4BF9DE999BAE69699E68EA7E999A4E5BE8CE381AEE98791E9A18D';
  l_bal_names_tab(7) := 'B_SPB_AMT_AFTER_SI_PREM_DCT';
  l_bal_rep_tab(7) := 'Amount after Deduction of Social Insurance Premium';

  l_jp_bal_names_tab(8) := '42EFBCBFE5B9B4EFBCBFE9818EE4B88DE8B6B3E7A88EE9A18D';
  l_bal_names_tab(8) := 'B_YEA_TAX_PAY';
  l_bal_rep_tab(8) := 'Over and Short Tax Amount';

  l_jp_bal_names_tab(9) := '42EFBCBFE7B5A6EFBCBFE99D9EE5B185E4BD8FE88085EFBCBFE78FBEE789A9E58886E8AAB2E7A88EE9A18DE59088E8A888';
  l_bal_names_tab(9) := 'B_SAL_TXBL_ERN_KIND_NRES';
  l_bal_rep_tab(9) := 'Total Assessable Amount (Non Resident) (In Kind)';

  l_jp_bal_names_tab(10) := '42EFBCBFE7B5A6EFBCBFE99D9EE5B185E4BD8FE88085EFBCBFE694AFE7B5A6E58886E8AAB2E7A88EE9A18DE59088E8A888';
  l_bal_names_tab(10) := 'B_SAL_TXBL_ERN_MONEY_NRES';
  l_bal_rep_tab(10) := 'Total Assessable Amount (Non Resident)';

  l_jp_bal_names_tab(11) := '42EFBCBFE8B39EEFBCBFE99D9EE5B185E4BD8FE88085EFBCBFE78FBEE789A9E58886E8AAB2E7A88EE9A18DE59088E8A888';
  l_bal_names_tab(11) := 'B_BON_TXBL_ERN_KIND_NRES';
  l_bal_rep_tab(11) := 'Total Assessable Amount (Non Resident) (in Kind)';

  l_jp_bal_names_tab(12) := '42EFBCBFE8B39EEFBCBFE99D9EE5B185E4BD8FE88085EFBCBFE694AFE7B5A6E58886E8AAB2E7A88EE9A18DE59088E8A888';
  l_bal_names_tab(12) := 'B_BON_TXBL_ERN_MONEY_NRES';
  l_bal_rep_tab(12) := 'Total Assessable Amount (Non Resident)';

  l_jp_bal_names_tab(13) := '42EFBCBFE98080EFBCBFE99D9EE5B185E4BD8FE88085EFBCBFE78FBEE789A9E58886E8AAB2E7A88EE9A18DE59088E8A888';
  l_bal_names_tab(13) := 'B_TRM_TXBL_ERN_KIND_NRES';
  l_bal_rep_tab(13) := 'Total Assessable Amount (Non Resident) (In Kind)';

  l_jp_bal_names_tab(14) := '42EFBCBFE98080EFBCBFE99D9EE5B185E4BD8FE88085EFBCBFE694AFE7B5A6E58886E8AAB2E7A88EE9A18DE59088E8A888';
  l_bal_names_tab(14) := 'B_TRM_TXBL_ERN_MONEY_NRES';
  l_bal_rep_tab(14) := 'Total Assessable Amount (Non Resident)';

  l_jp_bal_names_tab(15) := '42EFBCBFE789B9E8B39EEFBCBFE99D9EE5B185E4BD8FE88085EFBCBFE78FBEE789A9E58886E8AAB2E7A88EE9A18DE59088E8A888';
  l_bal_names_tab(15) := 'B_SPB_TXBL_ERN_KIND_NRES';
  l_bal_rep_tab(15) := 'Total Assessable Amount (Non Resident) (In Kind)';

  l_jp_bal_names_tab(16) := '42EFBCBFE789B9E8B39EEFBCBFE99D9EE5B185E4BD8FE88085EFBCBFE694AFE7B5A6E58886E8AAB2E7A88EE9A18DE59088E8A888';
  l_bal_names_tab(16) := 'B_SPB_TXBL_ERN_MONEY_NRES';
  l_bal_rep_tab(16) := 'Total Assessable Amount (Non Resident)';

  l_jp_bal_names_tab(17) := '42EFBCBFE5B9B4EFBCBFE68980E5BE97E68EA7E999A4E9A18DE59088E8A888';
  l_bal_names_tab(17) := 'B_YEA_INCOME_EXM';
  l_bal_rep_tab(17) := 'Total Income Deduction Amount';

  l_jp_bal_names_tab(18) := '42EFBCBFE98080EFBCBFE68980E5BE97E68EA7E999A4E9A18D';
  l_bal_names_tab(18) := 'B_TRM_INCOME_EXM';
  l_bal_rep_tab(18) := 'Income Deduction Amount';

  l_jp_bal_names_tab(19) := '42EFBCBFE8B39EEFBCBFE99B87E794A8E4BF9DE999BAE5AFBEE8B1A1E8B383E98791E7B78FE9A18D';
  l_bal_names_tab(19) := 'B_BON_ERN_SUBJ_EI';
  l_bal_rep_tab(19) := 'Total Amount of Wage subject to Employment Insurance';

  l_jp_bal_names_tab(20) := '42EFBCBFE8B39EEFBCBFE58AB4E781BDE4BF9DE999BAE5AFBEE8B1A1E8B383E98791E7B78FE9A18D';
  l_bal_names_tab(20) := 'B_BON_ERN_SUBJ_WAI';
  l_bal_rep_tab(20) := 'Total Amount of Wage subject to Work Accident Insurance';

  l_jp_bal_names_tab(21) := '42EFBCBFE8B39EEFBCBFE694AFE7B5A6E9A18DE59088E8A888';
  l_bal_names_tab(21) := 'B_BON_ERN';
  l_bal_rep_tab(21) := 'Total Earning Amount';

  l_jp_bal_names_tab(22) := '42EFBCBFE8B39EEFBCBFE68980E5BE97E7A88EE9A18D';
  l_bal_names_tab(22) := 'B_BON_ITX';
  l_bal_rep_tab(22) := 'Income Tax';

  l_jp_bal_names_tab(23) := '42EFBCBFE8B39EEFBCBFE5B7AEE5BC95E694AFE7B5A6E9A18D';
  l_bal_names_tab(23) := 'B_BON_NET_PAY';
  l_bal_rep_tab(23) := 'Net Pay Amount';

  l_jp_bal_names_tab(24) := '42EFBCBFE8B39EEFBCBFE694AFE7B5A6E58886E8AAB2E7A88EE9A18DE59088E8A888';
  l_bal_names_tab(24) := 'B_BON_TXBL_ERN_MONEY';
  l_bal_rep_tab(24) := 'Total Assessable Amount';

  l_jp_bal_names_tab(25) := '42EFBCBFE8B39EEFBCBFE7A4BEE4BC9AE4BF9DE999BAE69699E68EA7E999A4E5BE8CE381AEE98791E9A18D';
  l_bal_names_tab(25) := 'B_BON_AMT_AFTER_SI_PREM_DCT';
  l_bal_rep_tab(25) := 'Amount after Deduction of Social Insurance Premium';

  l_jp_bal_names_tab(26) := '42EFBCBFE8B39EEFBCBFE78FBEE789A9E58886E8AAB2E7A88EE9A18DE59088E8A888';
  l_bal_names_tab(26) := 'B_BON_TXBL_ERN_KIND';
  l_bal_rep_tab(26) := 'Total Assessable Amount (In Kind)';

  l_jp_bal_names_tab(27) := '42EFBCBFE8B39EEFBCBFE68EA7E999A4E9A18DE59088E8A888';
  l_bal_names_tab(27) := 'B_BON_DCT';
  l_bal_rep_tab(27) := 'Total Deduction Amount';

  l_jp_bal_names_tab(28) := '42EFBCBFE8B39EEFBCBFE7A4BEE4BC9AE4BF9DE999BAE69699E59088E8A888';
  l_bal_names_tab(28) := 'B_BON_SI_PREM';
  l_bal_rep_tab(28) := 'Social Insurance Premium';

  l_jp_bal_names_tab(29) := '42EFBCBFE8B39EEFBCBFE99B87E794A8E4BF9DE999BAE69699';
  l_bal_names_tab(29) := 'B_BON_EI_PREM';
  l_bal_rep_tab(29) := 'Employment Insurance Premium';

  l_jp_bal_names_tab(30) := '42EFBCBFE694AFE68995E5898DE587A6E79086E794A8E5B7AEE5BC95E694AFE7B5A6E9A18D';
  l_bal_names_tab(30) := 'B_NET_PAY';
  l_bal_rep_tab(30) := 'Net Pay Amount for PrePayments';

  l_jp_bal_names_tab(31) := '42EFBCBFE7B5A6EFBCBFE99B87E794A8E4BF9DE999BAE5AFBEE8B1A1E8B383E98791E7B78FE9A18D';
  l_bal_names_tab(31) := 'B_SAL_ERN_SUBJ_EI';
  l_bal_rep_tab(31) := 'Total Amount of Wage subject to Employment Insurance';

  l_jp_bal_names_tab(32) := '42EFBCBFE7B5A6EFBCBFE58AB4E781BDE4BF9DE999BAE5AFBEE8B1A1E8B383E98791E7B78FE9A18D';
  l_bal_names_tab(32) := 'B_SAL_ERN_SUBJ_WAI';
  l_bal_rep_tab(32) := 'Total Amount of Wage subject to Wa Insurance';

  l_jp_bal_names_tab(33) := '42EFBCBFE7B5A6EFBCBFE694AFE7B5A6E9A18DE59088E8A888';
  l_bal_names_tab(33) := 'B_SAL_ERN';
  l_bal_rep_tab(33) := 'Total Earning Amount';

  l_jp_bal_names_tab(34) := '42EFBCBFE7B5A6EFBCBFE581A5E5BAB7E4BF9DE999BAE69699';
  l_bal_names_tab(34) := 'B_SAL_HI_PREM';
  l_bal_rep_tab(34) := 'Health Insurance Premium';

  l_jp_bal_names_tab(35) := '42EFBCBFE7B5A6EFBCBFE68980E5BE97E7A88EE9A18D';
  l_bal_names_tab(35) := 'B_SAL_ITX';
  l_bal_rep_tab(35) := 'Income Tax';

  l_jp_bal_names_tab(36) := '42EFBCBFE7B5A6EFBCBFE5B7AEE5BC95E694AFE7B5A6E9A18D';
  l_bal_names_tab(36) := 'B_SAL_NET_PAY';
  l_bal_rep_tab(36) := 'Net Pay Amount';

  l_jp_bal_names_tab(37) := '42EFBCBFE7B5A6EFBCBFE694AFE7B5A6E58886E8AAB2E7A88EE9A18DE59088E8A888';
  l_bal_names_tab(37) := 'B_SAL_TXBL_ERN_MONEY';
  l_bal_rep_tab(37) := 'Total Assessable Amount';

  l_jp_bal_names_tab(38) := '42EFBCBFE7B5A6EFBCBFE7A4BEE4BC9AE4BF9DE999BAE69699E68EA7E999A4E5BE8CE381AEE98791E9A18D';
  l_bal_names_tab(38) := 'B_SAL_AMT_AFTER_SI_PREM_DCT';
  l_bal_rep_tab(38) := 'Amount after Deduction of Social Insurance Premium';

  l_jp_bal_names_tab(39) := '42EFBCBFE7B5A6EFBCBFE78FBEE789A9E58886E8AAB2E7A88EE9A18DE59088E8A888';
  l_bal_names_tab(39) := 'B_SAL_TXBL_ERN_KIND';
  l_bal_rep_tab(39) := 'Total Assessable Amount (In Kind)';

  l_jp_bal_names_tab(40) := '42EFBCBFE7B5A6EFBCBFE68EA7E999A4E9A18DE59088E8A888';
  l_bal_names_tab(40) := 'B_SAL_DCT';
  l_bal_rep_tab(40) := 'Total Deduction Amount';

  l_jp_bal_names_tab(41) := '42EFBCBFE7B5A6EFBCBFE7A4BEE4BC9AE4BF9DE999BAE69699E59088E8A888';
  l_bal_names_tab(41) := 'B_SAL_SI_PREM';
  l_bal_rep_tab(41) := 'Social Insurance Premium';

  l_jp_bal_names_tab(42) := '42EFBCBFE7B5A6EFBCBFE99B87E794A8E4BF9DE999BAE69699';
  l_bal_names_tab(42) := 'B_SAL_EI_PREM';
  l_bal_rep_tab(42) := 'Employment Insurance Premium';

  l_jp_bal_names_tab(43) := '42EFBCBFE7B5A6EFBCBFE58E9AE7949FE5B9B4E98791E4BF9DE999BAE69699';
  l_bal_names_tab(43) := 'B_SAL_WP_PREM';
  l_bal_rep_tab(43) := 'Welfare Pension Insurance Premium';

  l_jp_bal_names_tab(44) := '42EFBCBFE789B9E8B39EEFBCBFE99B87E794A8E4BF9DE999BAE5AFBEE8B1A1E8B383E98791E7B78FE9A18D';
  l_bal_names_tab(44) := 'B_SPB_ERN_SUBJ_EI';
  l_bal_rep_tab(44) := 'Total Amount of Wage subject to Employment Insurance';

  l_jp_bal_names_tab(45) := '42EFBCBFE789B9E8B39EEFBCBFE58AB4E781BDE4BF9DE999BAE5AFBEE8B1A1E8B383E98791E7B78FE9A18D';
  l_bal_names_tab(45) := 'B_SPB_ERN_SUBJ_WAI';
  l_bal_rep_tab(45) := 'Total Amount of Wage subject to Wa Insurance';

  l_jp_bal_names_tab(46) := '42EFBCBFE789B9E8B39EEFBCBFE694AFE7B5A6E9A18DE59088E8A888';
  l_bal_names_tab(46) := 'B_SPB_ERN';
  l_bal_rep_tab(46) := 'Total Earning Amount';

  l_jp_bal_names_tab(47) := '42EFBCBFE789B9E8B39EEFBCBFE68980E5BE97E7A88EE9A18D';
  l_bal_names_tab(47) := 'B_SPB_ITX';
  l_bal_rep_tab(47) := 'Income Tax';

  l_jp_bal_names_tab(48) := '42EFBCBFE789B9E8B39EEFBCBFE5B7AEE5BC95E694AFE7B5A6E9A18D';
  l_bal_names_tab(48) := 'B_SPB_NET_PAY';
  l_bal_rep_tab(48) := 'Net Pay Amount';

  l_jp_bal_names_tab(49) := '42EFBCBFE789B9E8B39EEFBCBFE694AFE7B5A6E58886E8AAB2E7A88EE9A18DE59088E8A888';
  l_bal_names_tab(49) := 'B_SPB_TXBL_ERN_MONEY';
  l_bal_rep_tab(49) := 'Total Assessable Amount';

  l_jp_bal_names_tab(50) := '42EFBCBFE789B9E8B39EEFBCBFE78FBEE789A9E58886E8AAB2E7A88EE9A18DE59088E8A888';
  l_bal_names_tab(50) := 'B_SPB_TXBL_ERN_KIND';
  l_bal_rep_tab(50) := 'Total Assessable Amount (In Kind)';

  l_jp_bal_names_tab(51) := '42EFBCBFE789B9E8B39EEFBCBFE68EA7E999A4E9A18DE59088E8A888';
  l_bal_names_tab(51) := 'B_SPB_DCT';
  l_bal_rep_tab(51) := 'Total Deduction Amount';

  l_jp_bal_names_tab(52) := '42EFBCBFE789B9E8B39EEFBCBFE99B87E794A8E4BF9DE999BAE69699';
  l_bal_names_tab(52) := 'B_SPB_EI_PREM';
  l_bal_rep_tab(52) := 'Employment Insurance Premium';

  l_jp_bal_names_tab(53) := '42EFBCBFE585B1EFBCBFE7AE97E5AE9AE69C88E5A489EFBCBFE694AFE68995E59FBAE7A48EE697A5E695B0';
  l_bal_names_tab(53) := 'B_COM_SAN_GEP_PAY_BASE_DAYS';
  l_bal_rep_tab(53) := 'Payment Base Days (Santei Geppen)';

  l_jp_bal_names_tab(54) := '42EFBCBFE585B1EFBCBFE7AE97E5AE9AE69C88E5A489EFBCBFE7B5A6E4B88EE78FBEE789A9';
  l_bal_names_tab(54) := 'B_COM_SAN_GEP_SAL_ERN_KIND';
  l_bal_rep_tab(54) := 'Salary in Kind (Santei Geppen)';

  l_jp_bal_names_tab(55) := '42EFBCBFE585B1EFBCBFE7AE97E5AE9AE69C88E5A489EFBCBFE7B5A6E4B88EE98791E98AAD';
  l_bal_names_tab(55) := 'B_COM_SAN_GEP_SAL_ERN_MONEY';
  l_bal_rep_tab(55) := 'Salary in Money (Santei Geppen)';

  l_jp_bal_names_tab(56) := '42EFBCBFE585B1EFBCBFE7AE97E5AE9AE69C88E5A489EFBCBFE789B9E588A5E8B39EE4B88EE98791E98AAD';
  l_bal_names_tab(56) := 'B_COM_SAN_GEP_SP_BON_ERN_MONEY';
  l_bal_rep_tab(56) := 'Special Bonus in Money';

  l_jp_bal_names_tab(57) := '42EFBCBFE98080EFBCBFE694AFE7B5A6E9A18DE59088E8A888';
  l_bal_names_tab(57) := 'B_TRM_ERN';
  l_bal_rep_tab(57) := 'Liquidation Amount';

  l_jp_bal_names_tab(58) := '42EFBCBFE98080EFBCBFE5B7AEE5BC95E694AFE7B5A6E9A18D';
  l_bal_names_tab(58) := 'B_TRM_NET_PAY';
  l_bal_rep_tab(58) := 'Net Pay Amount';

  l_jp_bal_names_tab(59) := '42EFBCBFE98080EFBCBFE694AFE7B5A6E58886E8AAB2E7A88EE9A18DE59088E8A888';
  l_bal_names_tab(59) := 'B_TRM_TXBL_ERN_MONEY';
  l_bal_rep_tab(59) := 'Total Assessable Amount';

  l_jp_bal_names_tab(60) := '42EFBCBFE98080EFBCBFE68EA7E999A4E9A18DE59088E8A888';
  l_bal_names_tab(60) := 'B_TRM_DCT';
  l_bal_rep_tab(60) := 'Total Deduction Amount';

  l_jp_bal_names_tab(61) := '42EFBCBFE5B9B4EFBCBFE5B7AEE5BC95E5B9B4E7A88EE9A18D';
  l_bal_names_tab(61) := 'B_YEA_NET_ANNUAL_TAX';
  l_bal_rep_tab(61) := 'Net Annual Tax Amount';

  l_jp_bal_names_tab(62) := '42EFBCBFE5B9B4EFBCBFE5B7AEE5BC95E8AAB2E7A88EE7B5A6E4B88EE68980E5BE97E98791E9A18D';
  l_bal_names_tab(62) := 'B_YEA_NET_TXBL_INCOME';
  l_bal_rep_tab(62) := 'Net Assessable Salary Income Amount';

  l_jp_bal_names_tab(63) := '42EFBCBFE585B1EFBCBFE581A5E5BAB7E4BF9DE999BAE69699E59088E8A888';
  l_bal_names_tab(63) := 'B_COM_HI_PREM';
  l_bal_rep_tab(63) := 'Health Insurance Premium';

  l_jp_bal_names_tab(64) := '42EFBCBFE5B9B4EFBCBFE5BEB4E58F8EE6B888E68980E5BE97E7A88EE59088E8A888';
  l_bal_names_tab(64) := 'B_YEA_WITHHOLD_ITX';
  l_bal_rep_tab(64) := 'Total Collected Income Tax';

  l_jp_bal_names_tab(65) := '42EFBCBFE5B9B4EFBCBFE7B5A6E4B88EE68EA7E999A4E58886E7949FE591BDE4BF9DE999BAE69699';
  l_bal_names_tab(65) := 'B_YEA_SAL_DCT_LIFE_INS_PREM';
  l_bal_rep_tab(65) := 'Life Insurance Premium (Salary Deduction)';

  l_jp_bal_names_tab(66) := '42EFBCBFE5B9B4EFBCBFE7B5A6E4B88EE68EA7E999A4E58886E995B7E69C9FE6908DE5AEB3E4BF9DE999BAE69699';
  l_bal_names_tab(66) := 'B_YEA_SAL_DCT_LONG_TERM_NONLIFE_INS_PREM';
  l_bal_rep_tab(66) := 'Long Term Nonlife Insurance Premium (Salary Deduction)';

  l_jp_bal_names_tab(67) := '42EFBCBFE5B9B4EFBCBFE7B5A6E4B88EE68EA7E999A4E58886E5808BE4BABAE5B9B4E98791E4BF9DE999BAE69699';
  l_bal_names_tab(67) := 'B_YEA_SAL_DCT_INDIVIDUAL_PENSION_PREM';
  l_bal_rep_tab(67) := 'Individual Pension Insurance Premium (Salary Deduction)';

  l_jp_bal_names_tab(68) := '42EFBCBFE5B9B4EFBCBFE7B5A6E4B88EE68980E5BE97E68EA7E999A4E5BE8CE381AEE98791E9A18D';
  l_bal_names_tab(68) := 'B_YEA_AMT_AFTER_EMP_INCOME_DCT';
  l_bal_rep_tab(68) := 'Amount after Salary Income Deduction';

  l_jp_bal_names_tab(69) := '42EFBCBFE5B9B4EFBCBFE7B5A6E4B88EE68EA7E999A4E58886E79FADE69C9FE6908DE5AEB3E4BF9DE999BAE69699';
  l_bal_names_tab(69) := 'B_YEA_SAL_DCT_SHORT_TERM_NONLIFE_INS_PREM';
  l_bal_rep_tab(69) := 'Short Term Nonlife Insurance Premium (Salary Deduction)';

  l_jp_bal_names_tab(70) := '42EFBCBFE5B9B4EFBCBFE694AFE7B5A6E58886E8AAB2E7A88EE9A18DE59088E8A888';
  l_bal_names_tab(70) := 'B_YEA_TXBL_ERN_MONEY';
  l_bal_rep_tab(70) := 'Total Assessable Amount';

  l_jp_bal_names_tab(71) := '42EFBCBFE5B9B4EFBCBFE78FBEE789A9E58886E8AAB2E7A88EE9A18DE59088E8A888';
  l_bal_names_tab(71) := 'B_YEA_TXBL_ERN_KIND';
  l_bal_rep_tab(71) := 'Total Assessable Amount (In Kind)';

  l_jp_bal_names_tab(72) := '42EFBCBFE585B1EFBCBFE99B87E794A8E4BF9DE999BAE69699E59088E8A888';
  l_bal_names_tab(72) := 'B_COM_EI_PREM';
  l_bal_rep_tab(72) := 'Employment Insurance Premium';

  l_jp_bal_names_tab(73) := '42EFBCBFE7B5A6EFBCBFE68980E5BE97E7A88EE794A8E8A888E7AE97E59FBAE7A48EE697A5E695B0';
  l_bal_names_tab(73) := 'B_SAL_ITX_CALC_BASE_DAYS';
  l_bal_rep_tab(73) := 'Calculation Base Days (Income Tax)';

  l_jp_bal_names_tab(74) := '42EFBCBFE7B5A6EFBCBFE4BD8FE6B091E7A88EE9A18D';
  l_bal_names_tab(74) := 'B_SAL_LTX';
  l_bal_rep_tab(74) := 'Local Tax';

  l_jp_bal_names_tab(75) := '42EFBCBFE585B1EFBCBFE78FBEE789A9E58886E8AAB2E7A88EE9A18DE59088E8A888';
  l_bal_names_tab(75) := 'B_COM_TXBL_ERN_KIND';
  l_bal_rep_tab(75) := 'Total Assessable Amount (In Kind)';

  l_jp_bal_names_tab(76) := '42EFBCBFE585B1EFBCBFE99B87E794A8E4BF9DE999BAE5AFBEE8B1A1E8B383E98791E7B78FE9A18D';
  l_bal_names_tab(76) := 'B_COM_ERN_SUBJ_EI';
  l_bal_rep_tab(76) := 'Total Amount of Wage subject to Employment Insurance';

  l_jp_bal_names_tab(77) := '42EFBCBFE585B1EFBCBFE694AFE7B5A6E58886E8AAB2E7A88EE9A18DE59088E8A888';
  l_bal_names_tab(77) := 'B_COM_TXBL_ERN_MONEY';
  l_bal_rep_tab(77) := 'Total Assessable Amount';

  l_jp_bal_names_tab(78) := '42EFBCBFE585B1EFBCBFE4BD8FE6B091E7A88EE9A18DEFBCBFE4B880E68BACE5BEB4E58F8E';
  l_bal_names_tab(78) := 'B_COM_LTX_LUMP_SUM_WITHHOLD';
  l_bal_rep_tab(78) := 'Local Tax (Lump Sum Collection)';

  l_jp_bal_names_tab(79) := '42EFBCBFE585B1EFBCBFE68980E5BE97E7A88EE9A18D';
  l_bal_names_tab(79) := 'B_COM_ITX';
  l_bal_rep_tab(79) := 'Income Tax';

  l_jp_bal_names_tab(80) := '42EFBCBFE585B1EFBCBFE58AB4E781BDE4BF9DE999BAE5AFBEE8B1A1E8B383E98791E7B78FE9A18D';
  l_bal_names_tab(80) := 'B_COM_ERN_SUBJ_WAI';
  l_bal_rep_tab(80) := 'Total Amount of Wage subject to Wa Insurance';

  l_jp_bal_names_tab(81) := '42EFBCBFE98080EFBCBFE4BD8FE6B091E7A88EE9A18DEFBCBFE789B9E588A5E5BEB4E58F8EEFBCBFE5B882E58CBAE794BAE69D91E7A88EE9A18D';
  l_bal_names_tab(81) := 'B_TRM_LTX_SP_WITHHOLD_MUNICIPAL_TAX';
  l_bal_rep_tab(81) := 'Special Collecting Local Tax (Municipal Tax)';

  l_jp_bal_names_tab(82) := '42EFBCBFE585B1EFBCBFE99D9EE5B185E4BD8FE88085EFBCBFE78FBEE789A9E58886E8AAB2E7A88EE9A18DE59088E8A888';
  l_bal_names_tab(82) := 'B_COM_TXBL_ERN_KIND_NRES';
  l_bal_rep_tab(82) := 'Total Assessable Amount (Non Resident) (In Kind)';

  l_jp_bal_names_tab(83) := '42EFBCBFE98080EFBCBFE4BD8FE6B091E7A88EE9A18DEFBCBFE789B9E588A5E5BEB4E58F8EEFBCBFE98080E881B7E68980E5BE97E9A18D';
  l_bal_names_tab(83) := 'B_TRM_LTX_SP_WITHHOLD_TRM_INCOME';
  l_bal_rep_tab(83) := 'Special Collecting Local Tax (Termination Income)';

  l_jp_bal_names_tab(84) := '42EFBCBFE98080EFBCBFE4BD8FE6B091E7A88EE9A18DEFBCBFE789B9E588A5E5BEB4E58F8EEFBCBFE983BDE98193E5BA9CE79C8CE7A88EE9A18D';
  l_bal_names_tab(84) := 'B_TRM_LTX_SP_WITHHOLD_PREFECTURAL_TAX';
  l_bal_rep_tab(84) := 'Special Collecting Local Tax (Prefectural Tax)';

  l_jp_bal_names_tab(85) := '42EFBCBFE7B5A6EFBCBFE58E9AE7949FE5B9B4E98791E59FBAE98791E4BF9DE999BAE69699';
  l_bal_names_tab(85) := 'B_SAL_WPF_PREM';
  l_bal_rep_tab(85) := 'Welfare Pension Fund Insurance Premium';

  l_jp_bal_names_tab(86) := '42EFBCBFE5B9B4EFBCBFE7B5A6E4B88EE68EA7E999A4E58886E7A4BEE4BC9AE4BF9DE999BAE69699';
  l_bal_names_tab(86) := 'B_YEA_SAL_DCT_SI_PREM';
  l_bal_rep_tab(86) := 'Social Insurance Premium (Salary Deduction)';

  l_jp_bal_names_tab(87) := '42EFBCBFE585B1EFBCBFE99D9EE5B185E4BD8FE88085EFBCBFE694AFE7B5A6E58886E8AAB2E7A88EE9A18DE59088E8A888';
  l_bal_names_tab(87) := 'B_COM_TXBL_ERN_MONEY_NRES';
  l_bal_rep_tab(87) := 'Total Assessable Amount (Non Resident)';

  l_jp_bal_names_tab(88) := '42EFBCBFE585B1EFBCBFE581A5E5BAB7E4BF9DE999BAE69699E59088E8A888EFBCBFE4BA8BE6A5ADE4B8BB';
  l_bal_names_tab(88) := 'B_COM_HI_PREM_ER';
  l_bal_rep_tab(88) := 'Health Insurance Premium (Employer)';

  l_jp_bal_names_tab(89) := '42EFBCBFE585B1EFBCBFE58E9AE7949FE5B9B4E98791E59FBAE98791E4BF9DE999BAE69699E59088E8A888EFBCBFE4BA8BE6A5ADE4B8BB';
  l_bal_names_tab(89) := 'B_COM_WPF_PREM_ER';
  l_bal_rep_tab(89) := 'Welfare Pension Fund Insurance Premium (Employer)';

  l_jp_bal_names_tab(90) := '42EFBCBFE585B1EFBCBFE58E9AE7949FE5B9B4E98791E4BF9DE999BAE69699E59088E8A888EFBCBFE4BA8BE6A5ADE4B8BB';
  l_bal_names_tab(90) := 'B_COM_WP_PREM_ER';
  l_bal_rep_tab(90) := 'Welfare Pension Insurance Premium (Employer)';

  l_jp_bal_names_tab(91) := '42EFBCBFE5B9B4EFBCBFE5898DE881B7E68385E5A0B1EFBCBFE7B5A6E4B88EE68980E5BE97E9A18D';
  l_bal_names_tab(91) := 'B_YEA_PREV_EMP_INCOME';
  l_bal_rep_tab(91) := 'Salary Income (Previous Employment)';

  l_jp_bal_names_tab(92) := '42EFBCBFE5B9B4EFBCBFE5898DE881B7E68385E5A0B1EFBCBFE7A4BEE4BC9AE4BF9DE999BAE69699';
  l_bal_names_tab(92) := 'B_YEA_PREV_EMP_SI_PREM';
  l_bal_rep_tab(92) := 'Social Insurance Premium (Previous Employment)';

  l_jp_bal_names_tab(93) := '42EFBCBFE5B9B4EFBCBFE5898DE881B7E68385E5A0B1EFBCBFE68980E5BE97E7A88EE9A18D';
  l_bal_names_tab(93) := 'B_YEA_PREV_EMP_ITX';
  l_bal_rep_tab(93) := 'Income Tax (Previous Employment)';

  l_jp_bal_names_tab(94) := '42EFBCBFE5B9B4EFBCBFE5AFBEE8B1A1E88085E588A4E588A5';
  l_bal_names_tab(94) := 'B_YEA_TYPE';
  l_bal_rep_tab(94) := 'Subjected Person Determination';

  l_jp_bal_names_tab(95) := '42EFBCBFE98080EFBCBFE68980E5BE97E7A88EE9A18D';
  l_bal_names_tab(95) := 'B_TRM_ITX';
  l_bal_rep_tab(95) := 'Income Tax';

  l_jp_bal_names_tab(96) := '42EFBCBFE68980E5BE97E7A88EEFBCBF31393939E5B9B4E7B5A6E4B88EE789B9E588A5E8AABFE695B4E68EA7E999A4EFBCBFE6BA90E6B389E5BEB4E58F8EE7A88EE9A18D';
  l_bal_names_tab(96) := 'B_COM_ITX_1999_SAL_SP_DCT_WITHHOLD_TAX';
  l_bal_rep_tab(96) := 'Income Tax Special Adjustment Deduction (Withholding Tax)';

  l_jp_bal_names_tab(97) := '42EFBCBFE68980E5BE97E7A88EEFBCBF31393939E5B9B4E7B5A6E4B88EE789B9E588A5E8AABFE695B4E68EA7E999A4EFBCBFE68EA7E999A4E9A18D';
  l_bal_names_tab(97) := 'B_COM_ITX_1999_SAL_SP_DCT';
  l_bal_rep_tab(97) := 'Income Tax Special Adjustment Deduction (Deduction)';

  l_jp_bal_names_tab(98) := '42EFBCBFE68980E5BE97E7A88EEFBCBF31393939E5B9B4E7B5A6E4B88EE789B9E588A5E8AABFE695B4E68EA7E999A4EFBCBFE68EA7E999A4E6B888';
  l_bal_names_tab(98) := 'B_COM_ITX_1999_SAL_SP_DCT_TAKEN';
  l_bal_rep_tab(98) := 'Income Tax Special Adjustment Deduction (Deductions Taken)';

  l_jp_bal_names_tab(99) := '42EFBCBFE68980E5BE97E7A88EEFBCBF31393939E5B9B4E7B5A6E4B88EE789B9E588A5E8AABFE695B4E68EA7E999A4EFBCBFE69CAAE68EA7E999A4';
  l_bal_names_tab(99) := 'B_COM_ITX_1999_SAL_SP_DCT_UNTAKEN';
  l_bal_rep_tab(99) := 'Income Tax Special Adj Deduction (Deductions Not Taken)';

  l_jp_bal_names_tab(100) := '42EFBCBFE5B9B4EFBCBFE5BEB4E58F8EE78CB6E4BA88E7A88EE9A18DE59088E8A888';
  l_bal_names_tab(100) := 'B_YEA_GRACE_ITX';
  l_bal_rep_tab(100) := 'Total Grace Tax Amount';

  l_jp_bal_names_tab(101) := '42EFBCBFE7B5A6EFBCBFE5B08FE8A68FE6A8A1E4BC81E6A5ADE585B1E6B888E7AD89E68E9BE98791';
  l_bal_names_tab(101) := 'B_SAL_SMALL_COMPANY_MUTUAL_AID_PREM';
  l_bal_rep_tab(101) := 'Salary Deduction Small Company Mutual Aid Premium';

  l_jp_bal_names_tab(102) := '42EFBCBFE8B39EEFBCBFE5B08FE8A68FE6A8A1E4BC81E6A5ADE585B1E6B888E7AD89E68E9BE98791';
  l_bal_names_tab(102) := 'B_BON_SMALL_COMPANY_MUTUAL_AID_PREM';
  l_bal_rep_tab(102) := 'Small Company Mutual Aid Premium';

  l_jp_bal_names_tab(103) := '42EFBCBFE789B9E8B39EEFBCBFE5B08FE8A68FE6A8A1E4BC81E6A5ADE585B1E6B888E7AD89E68E9BE98791';
  l_bal_names_tab(103) := 'B_SPB_SMALL_COMPANY_MUTUAL_AID_PREM';
  l_bal_rep_tab(103) := 'Salary Deduction Small Company Mutual Aid Premium';

  l_jp_bal_names_tab(104) := '42EFBCBFE5B9B4EFBCBFE7B5A6E4B88EE68EA7E999A4E58886E5B08FE8A68FE6A8A1E4BC81E6A5ADE585B1E6B888E7AD89E68E9BE98791';
  l_bal_names_tab(104) := 'B_YEA_SAL_DCT_SMALL_COMPANY_MUTUAL_AID_PREM';
  l_bal_rep_tab(104) := 'Salary Deduction Small Co Mutual Aid Prem (Salary Deduction)';

  l_jp_bal_names_tab(105) := '42EFBCBFE5B9B4EFBCBFE5898DE881B7E68385E5A0B1EFBCBFE5B08FE8A68FE6A8A1E4BC81E6A5ADE585B1E6B888E7AD89E68E9BE98791';
  l_bal_names_tab(105) := 'B_YEA_PREV_EMP_SMALL_COMPANY_MUTUAL_AID_PREM';
  l_bal_rep_tab(105) := 'Salary Deduction Small Co Mutual Aid Prem (Prev Employment)';

  l_jp_bal_names_tab(106) := '42EFBCBFE5B9B4EFBCBFE694AFE7B5A6E9A18DE59088E8A888';
  l_bal_names_tab(106) := 'B_YEA_ERN';
  l_bal_rep_tab(106) := 'Total Earning Amount';

  l_jp_bal_names_tab(107) := '42EFBCBFE8B39EEFBCBFE4BF9DE999BAE69699E5AFBEE8B1A1E9A18DE59088E8A888';
  l_bal_names_tab(107) := 'B_BON_ERN_SUBJ_SI';
  l_bal_rep_tab(107) := 'Total Amount of Wage subject to Social Insurance';

  l_jp_bal_names_tab(108) := '42EFBCBFE8B39EEFBCBFE58E9AE7949FE5B9B4E98791E59FBAE98791E4BF9DE999BAE69699';
  l_bal_names_tab(108) := 'B_BON_WPF_PREM';
  l_bal_rep_tab(108) := 'Welfare Pension Fund Insurance Premium';

  l_jp_bal_names_tab(109) := '42EFBCBFE8B39EEFBCBFE7A4BEE4BC9AE4BF9DE999BAE5AFBEE8B1A1EFBCBFE98791E98AAD';
  l_bal_names_tab(109) := 'B_BON_ERN_MONEY_SUBJ_SI';
  l_bal_rep_tab(109) := 'Total Amount of Wage subject to Social Insurance';

  l_jp_bal_names_tab(110) := '42EFBCBFE8B39EEFBCBFE7A4BEE4BC9AE4BF9DE999BAE5AFBEE8B1A1EFBCBFE78FBEE789A9';
  l_bal_names_tab(110) := 'B_BON_ERN_KIND_SUBJ_SI';
  l_bal_rep_tab(110) := 'Total Amount of Wage subject to Social Insurance (in Kind)';

  l_jp_bal_names_tab(111) := '42EFBCBFE8B39EEFBCBFE581A5E5BAB7E4BF9DE999BAE69699';
  l_bal_names_tab(111) := 'B_BON_HI_PREM';
  l_bal_rep_tab(111) := 'Health Insurance Premium';

  l_jp_bal_names_tab(112) := '42EFBCBFE8B39EEFBCBFE58E9AE7949FE5B9B4E98791E4BF9DE999BAE69699';
  l_bal_names_tab(112) := 'B_BON_WP_PREM';
  l_bal_rep_tab(112) := 'Welfare Pension Insurance Premium';

  l_jp_bal_names_tab(113) := '42EFBCBFE8B39EEFBCBFE581A5E4BF9DEFBCBFE59088E7AE97E5AFBEE8B1A1EFBCBFE98791E98AAD';
  l_bal_names_tab(113) := 'B_BON_HI_ERN_MONEY_SUBJ_SI_ACMLT';
  l_bal_rep_tab(113) := 'Health Insurance Premium (Accumulation)';

  l_jp_bal_names_tab(114) := '42EFBCBFE8B39EEFBCBFE581A5E4BF9DEFBCBFE59088E7AE97E5AFBEE8B1A1EFBCBFE78FBEE789A9';
  l_bal_names_tab(114) := 'B_BON_HI_ERN_KIND_SUBJ_SI_ACMLT';
  l_bal_rep_tab(114) := 'Health Insurnace Premium (Accumulation) (In Kind)';

  l_jp_bal_names_tab(115) := '42EFBCBFE8B39EEFBCBFE58E9AE5B9B4EFBCBFE59088E7AE97E5AFBEE8B1A1EFBCBFE98791E98AAD';
  l_bal_names_tab(115) := 'B_BON_WP_ERN_MONEY_SUBJ_SI_ACMLT';
  l_bal_rep_tab(115) := 'Welfare Pension Insurance Premium (Add Up)';

  l_jp_bal_names_tab(116) := '42EFBCBFE8B39EEFBCBFE58E9AE5B9B4EFBCBFE59088E7AE97E5AFBEE8B1A1EFBCBFE78FBEE789A9';
  l_bal_names_tab(116) := 'B_BON_WP_ERN_KIND_SUBJ_SI_ACMLT';
  l_bal_rep_tab(116) := 'Welfare Pension Insurance Premium (Add Up) (in Kind)';

  l_jp_bal_names_tab(117) := '42EFBCBFE8B39EEFBCBFE581A5E4BF9DEFBCBFE59088E7AE97E5AFBEE8B1A1EFBCBFE8A2ABE4BF9DE999BAE88085E58886E4BF9DE999BAE69699';
  l_bal_names_tab(117) := 'B_BON_HI_PREM_EE_ACMLT';
  l_bal_rep_tab(117) := 'Health Insurance Premium (Accumulation)';

  l_jp_bal_names_tab(118) := '42EFBCBFE8B39EEFBCBFE581A5E4BF9DEFBCBFE59088E7AE97E5AFBEE8B1A1EFBCBFE4BA8BE6A5ADE4B8BBE58886E4BF9DE999BAE69699';
  l_bal_names_tab(118) := 'B_BON_HI_PREM_ER_ACMLT';
  l_bal_rep_tab(118) := 'Health Insurance Premium (Accumulation) (Employer)';

  l_jp_bal_names_tab(119) := '42EFBCBFE8B39EEFBCBFE4BB8BE4BF9DEFBCBFE59088E7AE97E5AFBEE8B1A1EFBCBFE8A2ABE4BF9DE999BAE88085E58886E4BF9DE999BAE69699';
  l_bal_names_tab(119) := 'B_BON_CI_PREM_EE_ACMLT';
  l_bal_rep_tab(119) := 'Care Insurance Premium (Accumulation)';

  l_jp_bal_names_tab(120) := '42EFBCBFE8B39EEFBCBFE4BB8BE4BF9DEFBCBFE59088E7AE97E5AFBEE8B1A1EFBCBFE4BA8BE6A5ADE4B8BBE58886E4BF9DE999BAE69699';
  l_bal_names_tab(120) := 'B_BON_CI_PREM_ER_ACMLT';
  l_bal_rep_tab(120) := 'Care Insurance Premium (Accumulation) (Employer)';

  l_jp_bal_names_tab(121) := '42EFBCBFE8B39EEFBCBFE58E9AE5B9B4EFBCBFE59088E7AE97E5AFBEE8B1A1EFBCBFE8A2ABE4BF9DE999BAE88085E58886E4BF9DE999BAE69699';
  l_bal_names_tab(121) := 'B_BON_WP_PREM_EE_ACMLT';
  l_bal_rep_tab(121) := 'Welfare Pension Insurance Premium (Add Up)';

  l_jp_bal_names_tab(122) := '42EFBCBFE8B39EEFBCBFE58E9AE5B9B4EFBCBFE59088E7AE97E5AFBEE8B1A1EFBCBFE4BA8BE6A5ADE4B8BBE58886E4BF9DE999BAE69699';
  l_bal_names_tab(122) := 'B_BON_WP_PREM_ER_ACMLT';
  l_bal_rep_tab(122) := 'Welfare Pension Insurance Premium (Add Up) (Employer)';

  l_jp_bal_names_tab(123) := '42EFBCBFE8B39EEFBCBFE59FBAE98791EFBCBFE59088E7AE97E5AFBEE8B1A1EFBCBFE8A2ABE4BF9DE999BAE88085E58886E4BF9DE999BAE69699';
  l_bal_names_tab(123) := 'B_BON_WPF_PREM_EE_ACMLT';
  l_bal_rep_tab(123) := 'Welfare Pension Fund Insurance Premium (Accumulation)';

  l_jp_bal_names_tab(124) := '42EFBCBFE8B39EEFBCBFE59FBAE98791EFBCBFE59088E7AE97E5AFBEE8B1A1EFBCBFE4BA8BE6A5ADE4B8BBE58886E4BF9DE999BAE69699';
  l_bal_names_tab(124) := 'B_BON_WPF_PREM_ER_ACMLT';
  l_bal_rep_tab(124) := 'Welfare Pension Fund Ins Premium (Accumulation) (Employer)';

  l_jp_bal_names_tab(125) := '42EFBCBFE7B5A6EFBCBFE9809AE58BA4E6898BE5BD93EFBCBFE99B87E4BF9DE5AFBEE8B1A1E9A18D5FE69C88E9A18DE8AABFE695B4';
  l_bal_names_tab(125) := 'B_SAL_CMA_MTHLY_ERN_SUB_EI_ADJ';
  l_bal_rep_tab(125) := 'Commutation Allowance (Amt subj to Employment Ins by Month)';

  --
  -- bug.6031466
  --
  l_jp_bal_names_tab(126) := '42EFBCBFE5B9B4EFBCBFE7B5A6E4B88EE68EA7E999A4E58886E59CB0E99C87E4BF9DE999BAE69699';
  l_bal_names_tab(126) := 'B_YEA_SAL_DCT_EARTHQUAKE_INS_PREM';
  l_bal_rep_tab(126) := 'Earthquake Insurance Premium (Salary Deduction)';

  hr_utility.set_location(l_proc, 20);

  if (g_dbg) then
    hr_utility.trace('| Balance Type Count = ' || l_jp_bal_names_tab.COUNT);
    hr_utility.trace('+--------------------------------------------+ ');
  end if;
--

  FORALL l_tab_cnt IN 1..l_jp_bal_names_tab.COUNT

    UPDATE pay_balance_types
    SET    balance_name = l_bal_names_tab(l_tab_cnt),
           reporting_name = l_bal_rep_tab(l_tab_cnt)
    WHERE  balance_name LIKE hr_jp_standard_pkg.hextochar(l_jp_bal_names_tab(l_tab_cnt),'AL32UTF8')
    AND    legislation_code = 'JP';

  UPDATE pay_balance_types
  SET    reporting_name = reporting_name || 'Obsoleted'
  WHERE  ASCII(reporting_name) > 127
  AND    legislation_code = 'JP';

  hr_utility.set_location(l_proc, 30);

  if (g_dbg) then
    hr_utility.trace('| Total Balance Types Updated = ' || SQL%ROWCOUNT);
    hr_utility.trace('+-------------------------------+ ');
  end if;
--
EXCEPTION

  WHEN OTHERS THEN

    hr_utility.set_location(l_proc, 40);

    raise;

END migrate_balance_types;
--
-- |-------------------------------------------------------------------|
-- |--------------------< migrate_bal_dimensions >---------------------|
-- |-------------------------------------------------------------------|
--
procedure migrate_bal_dimensions is
--
  type t_jp_dim_names_tab is table of VARCHAR2(200) index by binary_integer;

  type t_dim_names_tab is table of pay_balance_dimensions.dimension_name%TYPE index by binary_integer;

  type t_dim_desc_tab is table of pay_balance_dimensions.description%TYPE index by binary_integer;

  type t_dim_suffix_tab is table of pay_balance_dimensions.database_item_suffix%TYPE index by binary_integer;

  l_jp_dim_names_tab  t_jp_dim_names_tab;
  l_dim_names_tab     t_dim_names_tab;
  l_dim_desc_tab      t_dim_desc_tab;
  l_dim_suffix_tab    t_dim_suffix_tab;

  l_proc              VARCHAR2(50) := g_pkg||'.migrate_bal_dimensions';

BEGIN

  l_jp_dim_names_tab.DELETE;
  l_dim_names_tab.DELETE;
  l_dim_desc_tab.DELETE;
  l_dim_suffix_tab.DELETE;

  hr_utility.set_location(l_proc, 10);

  l_jp_dim_names_tab(1) := '5F41EFBCBFE5BD93E7B5A6E4B88EE587A6E79086';
  l_dim_names_tab(1) := '_ASG_RUN';
  l_dim_desc_tab(1) := 'Grand Total within Current Payroll Process (Assignment)';
  l_dim_suffix_tab(1) := '_ASG_RUN';

  l_jp_dim_names_tab(2) := '5F41EFBCBFE585A5E7A4BEE697A5EFBCBFE5BD93E697A5';
  l_dim_names_tab(2) := '_ASG_LTD';
  l_dim_desc_tab(2) := 'Grand Total from Hire Date to Processing Date (Assignment)';
  l_dim_suffix_tab(2) := '_ASG_LTD';

  l_jp_dim_names_tab(3) := '5FE694AFE68995E5898DE587A6E79086E794A8';
  l_dim_names_tab(3) := '_PAYMENTS';
  l_dim_desc_tab(3) := 'Used for PrePayments Process';
  l_dim_suffix_tab(3) := '_PAYMENTS';

  l_jp_dim_names_tab(4) := '5F45EFBCBFE69C80E5889DE381AEE585A5E58A9BEFBCBFE5BD93E697A5';
  l_dim_names_tab(4) := '_ELM_LTD';
  l_dim_desc_tab(4) := 'Grand Total from Hire Date to Processing Date (Element)';
  l_dim_suffix_tab(4) := '_ELM_LTD';

  l_jp_dim_names_tab(5) := '5F41EFBCBF31E697A5EFBCBFE5BD93E697A520202020202020202020202020202020204546464543544956455F444154452030312D3031205245534554203132';
  l_dim_names_tab(5) := '_ASG_MTD                      EFFECTIVE_DATE 01-01 RESET 12';
  l_dim_desc_tab(5) := 'Grand Total until Processing Date within the Period from 1st to the End of the Month (Assignment)';
  l_dim_suffix_tab(5) := '_ASG_MTD';

  l_jp_dim_names_tab(6) := '5F41EFBCBF31E69C8831E697A5EFBCBFE5BD93E697A520202020202020202020202020204546464543544956455F444154452030312D3031205245534554203031';
  l_dim_names_tab(6) := '_ASG_YTD                      EFFECTIVE_DATE 01-01 RESET 01';
  l_dim_desc_tab(6) := 'Grand Total until Processing Date within the Period from January 1st to the End of the Year (Assignment)';
  l_dim_suffix_tab(6) := '_ASG_YTD';

  l_jp_dim_names_tab(7) := '5F41EFBCBF38E69C8831E697A5EFBCBFE5BD93E697A520202020202020202020202020204546464543544956455F444154452030312D3038205245534554203031';
  l_dim_names_tab(7) := '_ASG_AUGTD                    EFFECTIVE_DATE 01-08 RESET 01';
  l_dim_desc_tab(7) := 'Grand Total until Processing Date within the Period from August 1st to July 31st next year (Assignment)';
  l_dim_suffix_tab(7) := '_ASG_AUGTD';

  l_jp_dim_names_tab(8) := '5F41EFBCBFE5B7AEE9A18DE981A1E58F8A';
  l_dim_names_tab(8) := '_ASG_RETRO_RUN';
  l_dim_desc_tab(8) := 'Used for Retropay by Run Process';
  l_dim_suffix_tab(8) := '_ASG_RETRO_RUN';

  l_jp_dim_names_tab(9) := '5F41EFBCBFE7B5A6E4B88EE69C9FE99693E9968BE5A78BE697A5EFBCBFE5BD93E697A5';
  l_dim_names_tab(9) := '_ASG_PTD';
  l_dim_desc_tab(9) := 'Grand Total until Processing Date within the Payroll Period (Assignment)';
  l_dim_suffix_tab(9) := '_ASG_PTD';

  l_jp_dim_names_tab(10) := '5F45EFBCBFE7B5A6E4B88EE69C9FE99693E9968BE5A78BE697A5EFBCBFE5BD93E697A5';
  l_dim_names_tab(10) := '_ELM_PTD';
  l_dim_desc_tab(10) := 'Grand Total until Processing Date within the Payroll Period (Element)';
  l_dim_suffix_tab(10) := '_ELM_PTD';

  l_jp_dim_names_tab(11) := '5F41EFBCBFE4BC9AE8A888E5B9B4E5BAA6E9968BE5A78BE697A5EFBCBFE5BD93E697A5202020202020444154455F4541524E4544202020202020202020205245534554203031';
  l_dim_names_tab(11) := '_ASG_FYTD                     DATE_EARNED          RESET 01';
  l_dim_desc_tab(11) := 'Grand Total until Date Earned within the Business Year Period (Assignment)';
  l_dim_suffix_tab(11) := '_ASG_FYTD';

  l_jp_dim_names_tab(12) := '5F41EFBCBF37E69C8831E697A5EFBCBFE5BD93E697A520202020202020202020202020204546464543544956455F444154452030312D3037205245534554203031';
  l_dim_names_tab(12) := '_ASG_JULTD                    EFFECTIVE_DATE 01-07 RESET 01';
  l_dim_desc_tab(12) := 'Grand Total until Processing Date within the Period from July 1st to Jun 30th next year (Assignment)';
  l_dim_suffix_tab(12) := '_ASG_JULTD';

  l_jp_dim_names_tab(13) := '5F41EFBCBFE4BA8BE6A5ADE5B9B4E5BAA6E9968BE5A78BE697A5EFBCBFE5BD93E697A5';
  l_dim_names_tab(13) := '_ASG_BYTD';
  l_dim_desc_tab(13) := 'Grand Total until Processing Date within the Business Year Period (Assignment)';
  l_dim_suffix_tab(13) := '_ASG_BYTD';

  hr_utility.set_location(l_proc, 20);

  if (g_dbg) then
    hr_utility.trace('| Balance Dimension Count = ' || l_jp_dim_names_tab.COUNT);
    hr_utility.trace('+--------------------------------------------+ ');
  end if;
--

  FORALL l_tab_cnt IN 1..l_jp_dim_names_tab.COUNT

    UPDATE pay_balance_dimensions
    SET    dimension_name = l_dim_names_tab(l_tab_cnt),
           database_item_suffix = l_dim_suffix_tab(l_tab_cnt),
           description = l_dim_desc_tab(l_tab_cnt)
    WHERE  dimension_name LIKE hr_jp_standard_pkg.hextochar(l_jp_dim_names_tab(l_tab_cnt),'AL32UTF8')
    AND    legislation_code = 'JP';

  hr_utility.set_location(l_proc, 30);

  if (g_dbg) then
    hr_utility.trace('| Total Balance Dimensions Updated = ' || SQL%ROWCOUNT);
    hr_utility.trace('+-----------------------------------------+ ');
  end if;
--
EXCEPTION

  WHEN OTHERS THEN

    hr_utility.set_location(l_proc, 40);

    raise;

END migrate_bal_dimensions;
--
-- |-------------------------------------------------------------------|
-- |---------------------< migrate_element_sets >----------------------|
-- |-------------------------------------------------------------------|
--
procedure migrate_element_sets is
--
  type t_jp_ele_set_names_tab is table of VARCHAR2(50) index by binary_integer;

  type t_ele_set_names_tab is table of pay_element_sets.element_set_name%TYPE index by binary_integer;

  l_jp_ele_set_names_tab  t_jp_ele_set_names_tab;
  l_ele_set_names_tab     t_ele_set_names_tab;

  l_proc              VARCHAR2(50) := g_pkg||'.migrate_element_sets';

BEGIN

  l_jp_ele_set_names_tab.DELETE;
  l_ele_set_names_tab.DELETE;

  hr_utility.set_location(l_proc, 10);

  l_jp_ele_set_names_tab(1) := 'E8B39EE4B88E';	l_ele_set_names_tab(1) := 'BON';
  l_jp_ele_set_names_tab(2) := 'E7AE97E5AE9A';	l_ele_set_names_tab(2) := 'SAN';
  l_jp_ele_set_names_tab(3) := 'E7B5A6E4B88E';	l_ele_set_names_tab(3) := 'SAL';
  l_jp_ele_set_names_tab(4) := 'E69C88E5A489';	l_ele_set_names_tab(4) := 'GEP';
  l_jp_ele_set_names_tab(5) := 'E98080E881B7E98791';	l_ele_set_names_tab(5) := 'TRM';
  l_jp_ele_set_names_tab(6) := 'E5B9B4E69CABE8AABFE695B4';	l_ele_set_names_tab(6) := 'YEA';
  l_jp_ele_set_names_tab(7) := 'E789B9E588A5E8B39EE4B88E';	l_ele_set_names_tab(7) := 'SPB';
  l_jp_ele_set_names_tab(8) := 'E5868DE5B9B4E69CABE8AABFE695B4';	l_ele_set_names_tab(8) := 'REY';
  l_jp_ele_set_names_tab(9) := 'E882B2E694B9';	l_ele_set_names_tab(9) := 'IKU';

  hr_utility.set_location(l_proc, 20);

  if (g_dbg) then
    hr_utility.trace('| Element Sets Count = ' || l_jp_ele_set_names_tab.COUNT);
    hr_utility.trace('+--------------------------------------------+ ');
  end if;
--

  FORALL l_tab_cnt IN 1..l_jp_ele_set_names_tab.COUNT

    UPDATE pay_element_sets
    SET    element_set_name = l_ele_set_names_tab(l_tab_cnt)
    WHERE  element_set_name LIKE hr_jp_standard_pkg.hextochar(l_jp_ele_set_names_tab(l_tab_cnt),'AL32UTF8')
    AND    legislation_code = 'JP';

  hr_utility.set_location(l_proc, 30);

  if (g_dbg) then
    hr_utility.trace('| Total Element Sets Updated = ' || SQL%ROWCOUNT);
    hr_utility.trace('+-----------------------------------------+ ');
  end if;
--
EXCEPTION

  WHEN OTHERS THEN

    hr_utility.set_location(l_proc, 40);

    raise;

END migrate_element_sets;
--
-- |-------------------------------------------------------------------|
-- |-----------------------< migrate_globals >-------------------------|
-- |-------------------------------------------------------------------|
--
procedure migrate_globals is
--
  type t_jp_global_names_tab is table of VARCHAR2(200) index by binary_integer;

  type t_global_names_tab is table of ff_globals_f.global_name%TYPE index by binary_integer;

  type t_global_desc_tab is table of ff_globals_f.global_description%TYPE index by binary_integer;

  l_jp_global_names_tab  t_jp_global_names_tab;
  l_global_names_tab     t_global_names_tab;
  l_global_desc_tab      t_global_desc_tab;

  l_proc                 VARCHAR2(50) := g_pkg||'.migrate_globals';

BEGIN

  l_jp_global_names_tab.DELETE;
  l_global_names_tab.DELETE;
  l_global_desc_tab.DELETE;

  hr_utility.set_location(l_proc, 10);

  l_jp_global_names_tab(1) := '47EFBCBFE585B1EFBCBFE6BA90E6B389E5BEB4E58F8EE7A88EE9A18DE8A1A8E69C80E5A4A7E689B6E9A48AE88085E695B0';
  l_global_names_tab(1) := 'G_COM_ITX_TBL_NUM_OF_DEP_MAX';
  l_global_desc_tab(1) := 'Maximum Number of Dependent People of Withholding Tax Amount Table';

  l_jp_global_names_tab(2) := '47EFBCBFE7B5A6EFBCBFE581A5E5BAB7E4BF9DE999BAE69699E78E87EFBCBFE8A2ABE4BF9DE999BAE88085E8B2A0E68B85E58886';
  l_global_names_tab(2) := 'G_SAL_HI_PREM_RATE_EE';
  l_global_desc_tab(2) := 'Health Insurance Premium Rate on Salary (Insured)';

  l_jp_global_names_tab(3) := '47EFBCBFE7B5A6EFBCBFE581A5E5BAB7E4BF9DE999BAE69699E78E87';
  l_global_names_tab(3) := 'G_SAL_HI_PREM_RATE';
  l_global_desc_tab(3) := 'Health Insurance Premium Rate on Salary (Whole)';

  l_jp_global_names_tab(4) := '47EFBCBFE98080EFBCBFE7A88EE78E87EFBCBFE794B3E5918AE69BB8E69CAAE68F90E587BA';
  l_global_names_tab(4) := 'G_TRM_UNDECLARE_ITX_RATE';
  l_global_desc_tab(4) := 'Income Tax Rate in case of No File Declaration about Receipt of Termination Income';

  l_jp_global_names_tab(5) := '47EFBCBFE585B1EFBCBFE99B87E794A8E4BF9DE999BAE69699E78E87EFBCBFE4B880E888ACE381AEE4BA8BE6A5AD';
  l_global_names_tab(5) := 'G_COM_EI_PREM_RATE_GEN_BUSINESS';
  l_global_desc_tab(5) := 'Employment Insurance Permium Rate for General Business (Insured)';

  l_jp_global_names_tab(6) := '47EFBCBFE585B1EFBCBFE99B87E794A8E4BF9DE999BAE69699E78E87EFBCBFE8BEB2E69E97E6B0B4E794A3E6A5ADE6B885E98592E8A3BDE980A0E6A5AD';
  l_global_names_tab(6) := 'G_COM_EI_PREM_RATE_AGRICULTURE';
  l_global_desc_tab(6) := 'Employment Insurance Permium Rate for Agriculture Forest Fisher Industry, Liquor Industry (Insured)';

  l_jp_global_names_tab(7) := '47EFBCBFE585B1EFBCBFE99B87E794A8E4BF9DE999BAE69699E78E87EFBCBFE5BBBAE8A8ADE6A5AD';
  l_global_names_tab(7) := 'G_COM_EI_PREM_RATE_CONSTRUCTION';
  l_global_desc_tab(7) := 'Employment Insurance Permium Rate for Construction (Insured)';

  l_jp_global_names_tab(8) := '47EFBCBFE7B5A6EFBCBFE58E9AE7949FE5B9B4E98791E4BF9DE999BAE69699E78E87EFBCBFE8A2ABE4BF9DE999BAE88085E8B2A0E68B85E58886';
  l_global_names_tab(8) := 'G_SAL_WP_PREM_RATE_EE';
  l_global_desc_tab(8) := 'Welfare Pension Insurance Premium Rate on Salary (Insured)';

  l_jp_global_names_tab(9) := '47EFBCBFE7B5A6EFBCBFE58E9AE7949FE5B9B4E98791E4BF9DE999BAE69699E78E87';
  l_global_names_tab(9) := 'G_SAL_WP_PREM_RATE';
  l_global_desc_tab(9) := 'Welfare Pension Insurance Premium Rate on Salary (Whole)';

  l_jp_global_names_tab(10) := '47EFBCBFE7B5A6EFBCBFE59FBAE98791E4BF9DE999BAE69699E78E87';
  l_global_names_tab(10) := 'G_SAL_WPF_PREM_RATE';
  l_global_desc_tab(10) := 'Welfare Pension Fund Insurance Premium Rate on Salary (Whole)';

  l_jp_global_names_tab(11) := '47EFBCBFE7B5A6EFBCBFE59FBAE98791E4BF9DE999BAE69699E78E87EFBCBFE8A2ABE4BF9DE999BAE88085E8B2A0E68B85E58886';
  l_global_names_tab(11) := 'G_SAL_WPF_PREM_RATE_EE';
  l_global_desc_tab(11) := 'Welfare Pension Fund Insurance Premium Rate on Salary (Insured)';

  l_jp_global_names_tab(12) := '47EFBCBFE585B1EFBCBFE7AE97E5AE9AE69C88E5A489EFBCBFE694AFE68995E59FBAE7A48EE697A5E695B0';
  l_global_names_tab(12) := 'G_COM_PAY_BASE_DAYS_MIN';
  l_global_desc_tab(12) := 'Minimum Payment Base Days of Full Time Worker';

  l_jp_global_names_tab(13) := '47EFBCBFE7AE97EFBCBFE694AFE68995E59FBAE7A48EE697A5E695B0EFBCBFE79FADE69982E99693E58AB4E5838DE88085';
  l_global_names_tab(13) := 'G_SAN_PAY_BASE_DAYS_SHORT_TIME_WORKER_MIN';
  l_global_desc_tab(13) := 'Minimum Payment Base Days of Short Time Worker';

  l_jp_global_names_tab(14) := '47EFBCBFE585B1EFBCBFE7A88EE78E87EFBCBFE99D9EE5B185E4BD8FE88085';
  l_global_names_tab(14) := 'G_COM_ITX_RATE_NRES';
  l_global_desc_tab(14) := 'Income Tax Rate (Non Resident)';

  l_jp_global_names_tab(15) := '47EFBCBFE7B5A6EFBCBFE4BB8BE8ADB7E4BF9DE999BAE69699E78E87';
  l_global_names_tab(15) := 'G_SAL_CI_PREM_RATE';
  l_global_desc_tab(15) := 'Care Insurance Premium Rate on Salary (Whole)';

  l_jp_global_names_tab(16) := '47EFBCBFE7B5A6EFBCBFE4BB8BE8ADB7E4BF9DE999BAE69699E78E87EFBCBFE8A2ABE4BF9DE999BAE88085E8B2A0E68B85E58886';
  l_global_names_tab(16) := 'G_SAL_CI_PREM_RATE_EE';
  l_global_desc_tab(16) := 'Care Insurance Premium Rate on Salary (Insured)';

  l_jp_global_names_tab(17) := '47EFBCBFE8B39EEFBCBFE581A5E5BAB7E4BF9DE999BAEFBCBFE6A899E6BA96E8B39EE4B88EEFBCBFE4B88AE99990E9A18D';
  l_global_names_tab(17) := 'G_BON_HI_STD_BON_MAX';
  l_global_desc_tab(17) := 'Maximum Standard Bonus Amount (Health Insurance)';

  l_jp_global_names_tab(18) := '47EFBCBFE8B39EEFBCBFE58E9AE7949FE5B9B4E98791E4BF9DE999BAEFBCBFE6A899E6BA96E8B39EE4B88EEFBCBFE4B88AE99990E9A18D';
  l_global_names_tab(18) := 'G_BON_WP_STD_BON_MAX';
  l_global_desc_tab(18) := 'Maximum Standard Bonus Amount (Welfare Pension Insurance)';

  l_jp_global_names_tab(19) := '47EFBCBFE7B5A6EFBCBFE4BAA4E9809AE6A99FE996A2EFBCBFE99D9EE8AAB2E7A88EE99990E5BAA6E9A18D';
  l_global_names_tab(19) := 'G_SAL_CMA_PUBLIC_TRANSPORT_NTXBL_ERN_MAX';
  l_global_desc_tab(19) := 'Non Assessable Limited Amount per One Month in case of utilizing Public Transportation';

  l_jp_global_names_tab(20) := '47EFBCBFE5B9B4EFBCBFE5AE9AE78E87E6B89BE7A88EE69699E78E87';
  l_global_names_tab(20) := 'G_YEA_PROPORTIONAL_TAX_CREDIT_RATE';
  l_global_desc_tab(20) := 'Proportional Tax Credit Rate on Year End Adjustment';

  l_jp_global_names_tab(21) := '47EFBCBFE5B9B4EFBCBFE5AE9AE78E87E6B89BE7A88EEFBCBFE4B88AE99990E9A18D';
  l_global_names_tab(21) := 'G_YEA_PROPORTIONAL_TAX_CREDIT_MAX';
  l_global_desc_tab(21) := 'Maximum Proportional Tax Credit on Year End Adjustment';

  --
  -- bug.6031466
  --
  l_jp_global_names_tab(22) := '47EFBCBFE98080EFBCBFE4BD8FE6B091E7A88EEFBCBFE789B9E588A5E5BEB4E58F8EEFBCBFE5B882E58CBAE794BAE69D91E7A88EE78E87';
  l_global_names_tab(22) := 'G_TRM_LTX_SP_WITHHOLD_MUNICIPAL_TAX_RATE';
  l_global_desc_tab(22) := 'Municipal Tax Rate of Special Collecting Local Tax on Termination Payment';

  l_jp_global_names_tab(23) := '47EFBCBFE98080EFBCBFE4BD8FE6B091E7A88EEFBCBFE789B9E588A5E5BEB4E58F8EEFBCBFE983BDE98193E5BA9CE79C8CE7A88EE78E87';
  l_global_names_tab(23) := 'G_TRM_LTX_SP_WITHHOLD_PREFECTURAL_TAX_RATE';
  l_global_desc_tab(23) := 'Prefectural Tax Rate of Special Collecting Local Tax on Termination Payment';

  l_jp_global_names_tab(24) := '47EFBCBFE98080EFBCBFE4BD8FE6B091E7A88EEFBCBFE789B9E588A5E5BEB4E58F8EEFBCBFE68EA7E999A4E78E87';
  l_global_names_tab(24) := 'G_TRM_LTX_SP_WITHHOLD_DCTBL_RATE';
  l_global_desc_tab(24) := 'Deduction Rate of Special Collecting Local Tax on Termination Payment';

  hr_utility.set_location(l_proc, 20);

  if (g_dbg) then
    hr_utility.trace('| Global Names Count = ' || l_jp_global_names_tab.COUNT);
    hr_utility.trace('+----------------------------------+ ');
  end if;
--

  hr_general.g_data_migrator_mode := 'Y';

  FORALL l_tab_cnt IN 1..l_jp_global_names_tab.COUNT

    UPDATE ff_globals_f
    SET    global_name = l_global_names_tab(l_tab_cnt),
           global_description = l_global_desc_tab(l_tab_cnt)
    WHERE  global_name LIKE hr_jp_standard_pkg.hextochar(l_jp_global_names_tab(l_tab_cnt),'AL32UTF8')
    AND    legislation_code = 'JP';

  UPDATE ff_globals_f
  SET    global_description = global_description || 'Obsoleted'
  WHERE  ASCII(global_description) > 127
  AND    legislation_code = 'JP';

  hr_utility.set_location(l_proc, 30);

  if (g_dbg) then
    hr_utility.trace('| Total Global Names Updated = ' || SQL%ROWCOUNT);
    hr_utility.trace('+-----------------------------------------+ ');
  end if;
--
EXCEPTION

  WHEN OTHERS THEN

    hr_utility.set_location(l_proc, 40);

    raise;

END migrate_globals;
--
-- |-------------------------------------------------------------------|
-- |-----------------------< migrate_formulas >------------------------|
-- |-------------------------------------------------------------------|
--
procedure migrate_formulas is
--
  type t_jp_formula_names_tab is table of VARCHAR2(200) index by binary_integer;

  type t_formula_names_tab is table of ff_formulas_f.formula_name%TYPE index by binary_integer;

  type t_formula_desc_tab is table of ff_formulas_f.description%TYPE index by binary_integer;

  l_jp_formula_names_tab  t_jp_formula_names_tab;
  l_formula_names_tab     t_formula_names_tab;
  l_formula_desc_tab      t_formula_desc_tab;

  l_proc              VARCHAR2(50) := g_pkg||'.migrate_formulas';

BEGIN

  l_jp_formula_names_tab.DELETE;
  l_formula_names_tab.DELETE;
  l_formula_desc_tab.DELETE;

  hr_utility.set_location(l_proc, 10);

  l_jp_formula_names_tab(1) := '46EFBCBFE69C88EFBCBFE59FBAE69CACEFBCBFE5A0B1E985ACE69C88E9A18D';
  l_formula_names_tab(1) := 'GEP_MR_PROC';
  l_formula_desc_tab(1) := 'Calculation of Standard Monthly Remuneration on Unscheduled Revision';

  l_jp_formula_names_tab(2) := '46EFBCBFE7AE97EFBCBFE59FBAE69CACEFBCBFE5A0B1E985ACE69C88E9A18D';
  l_formula_names_tab(2) := 'SAN_MR_PROC';
  l_formula_desc_tab(2) := 'Calculation of Standard Monthly Remuneration on Scheduled Revision';

  l_jp_formula_names_tab(3) := '4653EFBCBFE69C88EFBCBFE59FBAE69CACEFBCBFE5A0B1E985ACE69C88E9A18D';
  l_formula_names_tab(3) := 'GEP_MR_PROC_SKIP';
  l_formula_desc_tab(3) := 'Judgement of Calculation of Standard Monthly Renumeration on Unscheduled Revision';

  l_jp_formula_names_tab(4) := '4656EFBCBFE585B1EFBCBFE4BD8FE6B091E7A88EEFBCBFE68385E5A0B1EFBCBFE5B882E58CBAE794BAE69D91E382B3E383BCE38389';
  l_formula_names_tab(4) := 'LTX_MUNICIPAL_CODE_VALIDATION';
  l_formula_desc_tab(4) := 'Validation of Local Tax Paying Municipal Code';

  l_jp_formula_names_tab(5) := '4656EFBCBFE585B1EFBCBFE697A5E4BB98595959594D4D';
  l_formula_names_tab(5) := 'DATE_YYYYMM_VALIDATION';
  l_formula_desc_tab(5) := 'Validation of Date Format YYYYMM';

  l_jp_formula_names_tab(6) := '4656EFBCBFE585B1EFBCBFE4BD8FE6B091E7A88EEFBCBFE68385E5A0B1EFBCBFE5BEB4E58F8EE7BEA9E58B99E88085E795AAE58FB7';
  l_formula_names_tab(6) := 'LTX_WITHHOLD_AGENT_NUM_VALIDATION';
  l_formula_desc_tab(6) := 'Validation of Local Tax Withholding Agent Number';

  l_jp_formula_names_tab(7) := '4653EFBCBFE7AE97EFBCBFE59FBAE69CACEFBCBFE5A0B1E985ACE69C88E9A18D';
  l_formula_names_tab(7) := 'SAN_MR_PROC_SKIP';
  l_formula_desc_tab(7) := 'Judgement of Calculation of Standard Monthly Renumeration on Scheduled Revision';

  l_jp_formula_names_tab(8) := '46EFBCBFE7B5A6EFBCBFE59FBAE69CACEFBCBFE581A5E4BF9DEFBCBFE4BF9DE999BAE69699';
  l_formula_names_tab(8) := 'SAL_HI_PREM_PROC';
  l_formula_desc_tab(8) := 'Calculation of Health Insurance Premium on Salary Process';

  l_jp_formula_names_tab(9) := '46EFBCBFE7B5A6EFBCBFE59FBAE69CACEFBCBFE99B87E4BF9DEFBCBFE4BF9DE999BAE69699';
  l_formula_names_tab(9) := 'SAL_EI_PREM_PROC';
  l_formula_desc_tab(9) := 'Calculation of Employment Insurance Premium on Salary Process';

  l_jp_formula_names_tab(10) := '46EFBCBFE7B5A6EFBCBFE59FBAE69CACEFBCBFE58E9AE5B9B4EFBCBFE4BF9DE999BAE69699';
  l_formula_names_tab(10) := 'SAL_WP_PREM_PROC';
  l_formula_desc_tab(10) := 'Calculation of Welfare Pension Insurance Premium on Salary Process';

  l_jp_formula_names_tab(11) := '46EFBCBFE7B5A6EFBCBFE59FBAE69CACEFBCBFE68980E5BE97E7A88E';
  l_formula_names_tab(11) := 'SAL_ITX_PROC';
  l_formula_desc_tab(11) := 'Calculation of Income Tax on Salary Process';

  l_jp_formula_names_tab(12) := '46EFBCBFE7B5A6EFBCBFE4BD8FE6B091E7A88E';
  l_formula_names_tab(12) := 'SAL_LTX';
  l_formula_desc_tab(12) := 'Calculation of Local Tax on Salary Process';

  l_jp_formula_names_tab(13) := '46EFBCBFE7B5A6EFBCBFE68980E5BE97E7A88EEFBCBFE99D9EE5B185E4BD8FE88085';
  l_formula_names_tab(13) := 'SAL_ITX_NRES';
  l_formula_desc_tab(13) := 'Calculation of Income Tax on Salary Process (Non Resident)';

  l_jp_formula_names_tab(14) := '46EFBCBFE585B1EFBCBFE59FBAE69CACEFBCBFE4BD8FE6B091E7A88EEFBCBFE4B880E68BACE5BEB4E58F8E';
  l_formula_names_tab(14) := 'COM_LTX_LUMP_SUM_WITHHOLD_PROC';
  l_formula_desc_tab(14) := 'Calculation of Lump Sum Collecting Local Tax';

  l_jp_formula_names_tab(15) := '46EFBCBFE585B1EFBCBFE59FBAE69CACEFBCBFE689B6E9A48AE68EA7E999A4E7AD89';
  l_formula_names_tab(15) := 'YEA_DEP_EXM_PROC';
  l_formula_desc_tab(15) := 'Calculation of Dependent Exemption etc on Year End Adjustment Process';

  l_jp_formula_names_tab(16) := '46EFBCBFE5868DE5B9B4EFBCBFE7B2BEE7AE97E9A18D';
  l_formula_names_tab(16) := 'REY_ITX';
  l_formula_desc_tab(16) := 'Calculation of Liquidation Amount on Re-year End Adjustment Process';

  l_jp_formula_names_tab(17) := '46EFBCBFE8B39EEFBCBFE59FBAE69CACEFBCBFE99B87E4BF9DEFBCBFE4BF9DE999BAE69699';
  l_formula_names_tab(17) := 'BON_EI_PREM_PROC';
  l_formula_desc_tab(17) := 'Calculation of Employment Insurance Premium on Bonus Process';

  l_jp_formula_names_tab(18) := '46EFBCBFE8B39EEFBCBFE59FBAE69CACEFBCBFE68980E5BE97E7A88E';
  l_formula_names_tab(18) := 'BON_ITX_PROC';
  l_formula_desc_tab(18) := 'Calculation of Income Tax on Bonus Process';

  l_jp_formula_names_tab(19) := '46EFBCBFE8B39EEFBCBFE68980E5BE97E7A88EEFBCBFE99D9EE5B185E4BD8FE88085';
  l_formula_names_tab(19) := 'BON_ITX_NRES';
  l_formula_desc_tab(19) := 'Calculation of Income Tax on Bonus Process (Non Resident)';

  l_jp_formula_names_tab(20) := '46EFBCBFE98080EFBCBFE59FBAE69CACEFBCBFE4BD8FE6B091E7A88EEFBCBFE789B9E588A5E5BEB4E58F8E';
  l_formula_names_tab(20) := 'TRM_LTX_SP_WITHHOLD_PROC';
  l_formula_desc_tab(20) := 'Calculation of Special Collecting Local Tax on Termination Payment Process';

  l_jp_formula_names_tab(21) := '46EFBCBFE98080EFBCBFE59FBAE69CACEFBCBFE68980E5BE97E68EA7E999A4E9A18D';
  l_formula_names_tab(21) := 'TRM_INCOME_DCT_PROC';
  l_formula_desc_tab(21) := 'Calculation of Income Deduction on Termination Payment Process';

  l_jp_formula_names_tab(22) := '46EFBCBFE98080EFBCBFE68980E5BE97E7A88E';
  l_formula_names_tab(22) := 'TRM_ITX';
  l_formula_desc_tab(22) := 'Calculation of Income Tax on Termination Payment Process';

  l_jp_formula_names_tab(23) := '46EFBCBFE789B9E8B39EEFBCBFE59FBAE69CACEFBCBFE99B87E4BF9DEFBCBFE4BF9DE999BAE69699';
  l_formula_names_tab(23) := 'SPB_EI_PREM_PROC';
  l_formula_desc_tab(23) := 'Calculation of Employment Insurance Premium on Special Bonus Process';

  l_jp_formula_names_tab(24) := '46EFBCBFE789B9E8B39EEFBCBFE59FBAE69CACEFBCBFE68980E5BE97E7A88E';
  l_formula_names_tab(24) := 'SPB_ITX_PROC';
  l_formula_desc_tab(24) := 'Calculation of Income Tax on Special Bonus Process';

  l_jp_formula_names_tab(25) := '46EFBCBFE789B9E8B39EEFBCBFE68980E5BE97E7A88EEFBCBFE99D9EE5B185E4BD8FE88085';
  l_formula_names_tab(25) := 'SPB_ITX_NRES';
  l_formula_desc_tab(25) := 'Calculation of Income Tax on Special Bonus Process (Non Resident)';

  l_jp_formula_names_tab(26) := '46EFBCBFE5B9B4EFBCBFE9818EE4B88DE8B6B3E7A88EE9A18D';
  l_formula_names_tab(26) := 'YEA_TAX';
  l_formula_desc_tab(26) := 'Calculation of Over and Short Tax Amount on Year End Adjustment Process';

  l_jp_formula_names_tab(27) := '46EFBCBFE5B9B4EFBCBFE59FBAE69CACEFBCBFE7B5A6E4B88EE68980E5BE97E68EA7E999A4E5BE8CE381AEE98791E9A18D';
  l_formula_names_tab(27) := 'YEA_AMT_AFTER_EMP_INCOME_DCT_PROC';
  l_formula_desc_tab(27) := 'Calculation of Amount after Salary Income Deduction on Year End Adjustment Process';

  l_jp_formula_names_tab(28) := '46EFBCBFE5B9B4EFBCBFE59FBAE69CACEFBCBFE4BF9DE999BAE69699E585BCE9858DE789B9E68EA7E999A4';
  l_formula_names_tab(28) := 'YEA_INS_PREM_SPOUSE_SP_EXM_PROC';
  l_formula_desc_tab(28) := 'Calculation of Insurance Premium and Spouse Special Exemption on Year End Adjustment Process';

  l_jp_formula_names_tab(29) := '46EFBCBFE5B9B4EFBCBFE59FBAE69CACEFBCBFE5B7AEE5BC95E5B9B4E7A88EE9A18D';
  l_formula_names_tab(29) := 'YEA_NET_ANNUAL_TAX_PROC';
  l_formula_desc_tab(29) := 'Calculation of Net Annual Tax Amount on Year End Adjustment Process';

  l_jp_formula_names_tab(30) := '46EFBCBFE5B9B4EFBCBFE5B9B4E7A88EE9A18D';
  l_formula_names_tab(30) := 'YEA_ANNUAL_TAX';
  l_formula_desc_tab(30) := 'Liquidation Amount';

  l_jp_formula_names_tab(31) := '4653EFBCBFE7B5A6EFBCBFE4BD8FE6B091E7A88E';
  l_formula_names_tab(31) := 'SAL_LTX_SKIP';
  l_formula_desc_tab(31) := 'Judgement of Calculation of Local Tax on Salary Process';

  l_jp_formula_names_tab(32) := '4653EFBCBFE585B1EFBCBFE68980E5BE97E7A88EEFBCBFE99D9EE5B185E4BD8FE88085';
  l_formula_names_tab(32) := 'COM_ITX_NRES_SKIP';
  l_formula_desc_tab(32) := 'Judgement of Calculation of Income Tax (Non Resident)';

  l_jp_formula_names_tab(33) := '4653EFBCBFE585B1EFBCBFE59FBAE69CACEFBCBFE4BD8FE6B091E7A88EEFBCBFE4B880E68BACE5BEB4E58F8E';
  l_formula_names_tab(33) := 'COM_LTX_LUMP_SUM_WITHHOLD_PROC_SKIP';
  l_formula_desc_tab(33) := 'Judgement of Calculation of Lump Sum Collecting Local Tax';

  l_jp_formula_names_tab(34) := '4653EFBCBFE8B39EEFBCBFE59FBAE69CACEFBCBFE68980E5BE97E7A88E';
  l_formula_names_tab(34) := 'BON_ITX_PROC_SKIP';
  l_formula_desc_tab(34) := 'Judgement of Calculation of Income Tax on Bonus Process';

  l_jp_formula_names_tab(35) := '4653EFBCBFE8B39EEFBCBFE59FBAE69CACEFBCBFE99B87E4BF9DEFBCBFE4BF9DE999BAE69699';
  l_formula_names_tab(35) := 'BON_EI_PREM_PROC_SKIP';
  l_formula_desc_tab(35) := 'Judgement of Calculation of Employment Insurance Premium on Bonus Process';

  l_jp_formula_names_tab(36) := '4653EFBCBFE7B5A6EFBCBFE59FBAE69CACEFBCBFE581A5E4BF9DEFBCBFE4BF9DE999BAE69699';
  l_formula_names_tab(36) := 'SAL_HI_PREM_PROC_SKIP';
  l_formula_desc_tab(36) := 'Judgement of Calculation of Health Insurance Premium on Salary Process';

  l_jp_formula_names_tab(37) := '4653EFBCBFE7B5A6EFBCBFE59FBAE69CACEFBCBFE58E9AE5B9B4EFBCBFE4BF9DE999BAE69699';
  l_formula_names_tab(37) := 'SAL_WP_PREM_PROC_SKIP';
  l_formula_desc_tab(37) := 'Judgement of Calculation of Welfare Pension Insurance Premium on Salary Process';

  l_jp_formula_names_tab(38) := '4653EFBCBFE7B5A6EFBCBFE59FBAE69CACEFBCBFE68980E5BE97E7A88E';
  l_formula_names_tab(38) := 'SAL_ITX_PROC_SKIP';
  l_formula_desc_tab(38) := 'Judgement of Calculation of Income Tax on Salary Process';

  l_jp_formula_names_tab(39) := '4653EFBCBFE7B5A6EFBCBFE59FBAE69CACEFBCBFE99B87E4BF9DEFBCBFE4BF9DE999BAE69699';
  l_formula_names_tab(39) := 'SAL_EI_PREM_PROC_SKIP';
  l_formula_desc_tab(39) := 'Judgement of Calculation of Employment Insurance Premium on Salary Process';

  l_jp_formula_names_tab(40) := '4653EFBCBFE98080EFBCBFE59FBAE69CACEFBCBFE68980E5BE97E68EA7E999A4E9A18D';
  l_formula_names_tab(40) := 'TRM_INCOME_DCT_PROC_SKIP';
  l_formula_desc_tab(40) := 'Judgement of Calculation of Income Deduction on Termination Payment Process';

  l_jp_formula_names_tab(41) := '4653EFBCBFE585B1EFBCBFE59FBAE69CACEFBCBFE689B6E9A48AE68EA7E999A4E7AD89';
  l_formula_names_tab(41) := 'YEA_DEP_EXM_PROC_SKIP';
  l_formula_desc_tab(41) := 'Judgement of Calculation of Dependent Exemption etc on Year End Adjustment Process';

  l_jp_formula_names_tab(42) := '4653EFBCBFE789B9E8B39EEFBCBFE59FBAE69CACEFBCBFE99B87E4BF9DEFBCBFE4BF9DE999BAE69699';
  l_formula_names_tab(42) := 'SPB_EI_PREM_PROC_SKIP';
  l_formula_desc_tab(42) := 'Judgement of Calculation of Employment Insurance Premium on Special Bonus Process';

  l_jp_formula_names_tab(43) := '4656EFBCBFE58E9AE7949FE5B9B4E98791E59FBAE98791E4BA8BE6A5ADE68980';
  l_formula_names_tab(43) := 'WPF_LOCATION_VALIDATION';
  l_formula_desc_tab(43) := 'Validation of Welfare Pension Fund Location';

  l_jp_formula_names_tab(44) := '4656EFBCBFE58E9AE7949FE5B9B4E98791E4BF9DE999BAE4BA8BE6A5ADE68980';
  l_formula_names_tab(44) := 'WP_LOCATION_VALIDATION';
  l_formula_desc_tab(44) := 'Validation of Welfare Pension Insurance Location';

  l_jp_formula_names_tab(45) := '4656EFBCBFE4BD8FE6B091E7A88EE789B9E588A5E5BEB4E58F8EE7BEA9E58B99E88085';
  l_formula_names_tab(45) := 'LTX_WITHHOLD_AGENT_VALIDATION';
  l_formula_desc_tab(45) := 'Validation of Local Tax Special Withholding Agent';

  l_jp_formula_names_tab(46) := '4656EFBCBFE68980E5BE97E7A88EE5BEB4E58F8EE7BEA9E58B99E88085';
  l_formula_names_tab(46) := 'ITX_WITHHOLD_AGENT_VALIDATION';
  l_formula_desc_tab(46) := 'Validation of Income Tax Withholding Agent';

  l_jp_formula_names_tab(47) := '4656EFBCBFE581A5E5BAB7E4BF9DE999BAE4BA8BE6A5ADE68980';
  l_formula_names_tab(47) := 'HI_LOCATION_VALIDATION';
  l_formula_desc_tab(47) := 'Validation of Health Insurance Location';

  l_jp_formula_names_tab(48) := '4656EFBCBFE58E9AE7949FE5B9B4E98791E4BF9DE999BAE695B4E79086E795AAE58FB7';
  l_formula_names_tab(48) := 'WP_SERIAL_NUM_VALIDATION';
  l_formula_desc_tab(48) := 'Validation of Welfare Pension Insurance Serial Number';

  l_jp_formula_names_tab(49) := '4656EFBCBFE581A5E5BAB7E4BF9DE999BAE8A2ABE4BF9DE999BAE88085E8A8BCE381AEE795AAE58FB7';
  l_formula_names_tab(49) := 'HI_CARD_NUM_VALIDATION';
  l_formula_desc_tab(49) := 'Validation of Number of Health Insurance Card';

  l_jp_formula_names_tab(50) := '4656EFBCBFE99B87E794A8E4BF9DE999BAE8A2ABE4BF9DE999BAE88085E795AAE58FB7';
  l_formula_names_tab(50) := 'EI_NUM_VALIDATION';
  l_formula_desc_tab(50) := 'Validation of Employment Insurance Insured Number';

  l_jp_formula_names_tab(51) := '4656EFBCBFE59FBAE7A48EE5B9B4E98791E795AAE58FB7';
  l_formula_names_tab(51) := 'BASIC_PENSION_NUM_VALIDATION';
  l_formula_desc_tab(51) := 'Validation of Basis Pension Number';

  l_jp_formula_names_tab(52) := '4650EFBCBFE585A8E98A80E3839CE38387E382A3E383BC';
  l_formula_names_tab(52) := 'JBA_SAL_EFILE_RECEIVE_BANK_BODY_PAYMENT';
  l_formula_desc_tab(52) := 'Jba Salary Deposit File (Incoming Bank) (Body)';

  l_jp_formula_names_tab(53) := '4650EFBCBFE585A8E98A80E4BB95E59091E58588E98A80E8A18CE38395E38383E382BFE383BC';
  l_formula_names_tab(53) := 'JBA_SAL_EFILE_SEND_BANK_FOOTER_PAYMENT';
  l_formula_desc_tab(53) := 'Jba Salary Deposit File (Outcoming Bank) (Footer)';

  l_jp_formula_names_tab(54) := '4650EFBCBFE585A8E98A80E4BB95E59091E58588E98A80E8A18CE38398E38383E38380E383BC';
  l_formula_names_tab(54) := 'JBA_SAL_EFILE_SEND_BANK_HEADER_PAYMENT';
  l_formula_desc_tab(54) := 'Jba Salary Deposit File (Outcoming Bank) (Header)';

  l_jp_formula_names_tab(55) := '4650EFBCBFE585A8E98A80E8A2ABE4BB95E59091E58588E98A80E8A18CE38395E38383E382BFE383BC';
  l_formula_names_tab(55) := 'JBA_SAL_EFILE_RECEIVE_BANK_FOOTER_PAYMENT';
  l_formula_desc_tab(55) := 'Jba Salary Deposit File (Incoming Bank) (Footer)';

  l_jp_formula_names_tab(56) := '4650EFBCBFE585A8E98A80E8A2ABE4BB95E59091E58588E98A80E8A18CE38398E38383E38380E383BC';
  l_formula_names_tab(56) := 'JBA_SAL_EFILE_RECEIVE_BANK_HEADER_PAYMENT';
  l_formula_desc_tab(56) := 'Jba Salary Deposit File (Incoming Bank) (Header)';

  l_jp_formula_names_tab(57) := '4656EFBCBFE58AB4E5838DE4BF9DE999BAE4BA8BE6A5ADE4B8BB';
  l_formula_names_tab(57) := 'LI_LOCATION_VALIDATION';
  l_formula_desc_tab(57) := 'Validation of Labor Insurance Employer';

  l_jp_formula_names_tab(58) := '4653EFBCBFE585B1EFBCBFE68980E5BE97E7A88EEFBCBF31393939E5B9B4E7B5A6E4B88EE789B9E588A5E8AABFE695B4E68EA7E999A4EFBCBFE68385E5A0B1';
  l_formula_names_tab(58) := 'COM_ITX_1999_SAL_SP_DCT_INFO_SKIP';
  l_formula_desc_tab(58) := 'Judgement of Calculation of Income Tax Special Adjustment Deduction in 1999';

  l_jp_formula_names_tab(59) := '4653EFBCBFE585B1EFBCBFE68980E5BE97E7A88EEFBCBF31393939E5B9B4E7B5A6E4B88EE789B9E588A5E8AABFE695B4E68EA7E999A4';
  l_formula_names_tab(59) := 'COM_ITX_1999_SAL_SP_DCT_SKIP';
  l_formula_desc_tab(59) := 'Judgement of Calculation of Income Tax Special Adjustment Deduction in 1999';

  l_jp_formula_names_tab(60) := '46EFBCBFE585B1EFBCBFE68980E5BE97E7A88EEFBCBF31393939E5B9B4E7B5A6E4B88EE789B9E588A5E8AABFE695B4E68EA7E999A4';
  l_formula_names_tab(60) := 'COM_ITX_1999_SAL_SP_DCT';
  l_formula_desc_tab(60) := 'Calculation of Income Tax Special Adjustment Deduction in 1999';

  l_jp_formula_names_tab(61) := '4656EFBCBFE5B9B4EFBCBFE5898DE881B7E68385E5A0B1EFBCBFE382ABE3838A';
  l_formula_names_tab(61) := 'KANA_VALIDATION';
  l_formula_desc_tab(61) := 'Validation of Half Size Kana Entry';

  l_jp_formula_names_tab(62) := '4656EFBCBFE4BF9DE999BAE69699EFBCBFE7ABAFE695B0E587A6E79086';
  l_formula_names_tab(62) := 'INS_PREM_ROUNDING_VALIDATION';
  l_formula_desc_tab(62) := 'Validation of Rounding Entry Value';

  l_jp_formula_names_tab(63) := '4650EFBCBFE4BD8FE6B091E7A88EE7B48DE4BB98E38395E382A1E382A4E383ABEFBCBFE38398E38383E38380E383BCE383ACE382B3E383BCE38389E38395E382A9E383BCE3839EE38383E382BF';
  l_formula_names_tab(63) := 'LTX_EFILE_WITHHOLD_AGENT_HEADER_PAYMENT';
  l_formula_desc_tab(63) := 'Local Tax Payment File (Header Record)';

  l_jp_formula_names_tab(64) := '4650EFBCBFE4BD8FE6B091E7A88EE7B48DE4BB98E38395E382A1E382A4E383ABEFBCBFE38387E383BCE382BFE383ACE382B3E383BCE38389E5889DE69C9FE58C96';
  l_formula_names_tab(64) := 'LTX_EFILE_LTX_HEADER_PAYMENT';
  l_formula_desc_tab(64) := 'Local Tax Payment File (Data Record) (Header)';

  l_jp_formula_names_tab(65) := '4650EFBCBFE4BD8FE6B091E7A88EE7B48DE4BB98E38395E382A1E382A4E383ABEFBCBFE38387E383BCE382BFE383ACE382B3E383BCE38389E8A9B3E7B4B0';
  l_formula_names_tab(65) := 'LTX_EFILE_LTX_FOOTER_PAYMENT';
  l_formula_desc_tab(65) := 'Local Tax Payment File (Data Record) (Footer)';

  l_jp_formula_names_tab(66) := '4650EFBCBFE4BD8FE6B091E7A88EE7B48DE4BB98E38395E382A1E382A4E383ABEFBCBFE38387E383BCE382BFE383ACE382B3E383BCE38389E38395E382A9E383BCE3839EE38383E382BF';
  l_formula_names_tab(66) := 'LTX_EFILE_LTX_BODY_PAYMENT';
  l_formula_desc_tab(66) := 'Local Tax Payment File (Data Record) (Body)';

  l_jp_formula_names_tab(67) := '4650EFBCBFE4BD8FE6B091E7A88EE7B48DE4BB98E38395E382A1E382A4E383ABEFBCBFE38388E383ACE383BCE383A9E383ACE382B3E383BCE38389E38395E382A9E383BCE3839EE38383E382BF';
  l_formula_names_tab(67) := 'LTX_EFILE_WITHHOLD_AGENT_FOOTER_PAYMENT';
  l_formula_desc_tab(67) := 'Local Tax Payment File (Trailer Record)';

  l_jp_formula_names_tab(68) := '4650EFBCBFE4BD8FE6B091E7A88EE7B48DE4BB98E38395E382A1E382A4E383ABEFBCBFE382A8E383B3E38389E383ACE382B3E383BCE38389E38395E382A9E383BCE3839EE38383E382BF';
  l_formula_names_tab(68) := 'LTX_EFILE_END_PAYMENT';
  l_formula_desc_tab(68) := 'Local Tax Payment File (End Record)';

  l_jp_formula_names_tab(69) := '4653EFBCBFE8B39EEFBCBFE59FBAE69CACEFBCBFE581A5E4BF9DEFBCBFE4BF9DE999BAE69699';
  l_formula_names_tab(69) := 'BON_HI_PREM_PROC_SKIP';
  l_formula_desc_tab(69) := 'Judgement of Calculation of Health Insurance Premium on Bonus Process';

  l_jp_formula_names_tab(70) := '4653EFBCBFE8B39EEFBCBFE59FBAE69CACEFBCBFE58E9AE5B9B4EFBCBFE4BF9DE999BAE69699';
  l_formula_names_tab(70) := 'BON_WP_PREM_PROC_SKIP';
  l_formula_desc_tab(70) := 'Judgement of Calculation of Welfare Pension Insurance Premium on Bonus Process';

  l_jp_formula_names_tab(71) := '46EFBCBFE8B39EEFBCBFE59FBAE69CACEFBCBFE581A5E4BF9DEFBCBFE4BF9DE999BAE69699';
  l_formula_names_tab(71) := 'BON_HI_PREM_PROC';
  l_formula_desc_tab(71) := 'Calculation of Health Insurance Premium on Bonus Process';

  l_jp_formula_names_tab(72) := '46EFBCBFE8B39EEFBCBFE59FBAE69CACEFBCBFE58E9AE5B9B4EFBCBFE4BF9DE999BAE69699';
  l_formula_names_tab(72) := 'BON_WP_PREM_PROC';
  l_formula_desc_tab(72) := 'Calculation of Welfare Pension Insurance Premium on Bonus Process';

  l_jp_formula_names_tab(73) := '4656EFBCBFE581A5E4BF9DEFBCBFE6A899E6BA96E5A0B1E985ACE69C88E9A18D';
  l_formula_names_tab(73) := 'HI_REVISED_SMR_VALIDATION';
  l_formula_desc_tab(73) := 'Validation of Hi Standard Monthly Remuneration';

  l_jp_formula_names_tab(74) := '4656EFBCBFE58E9AE5B9B4EFBCBFE6A899E6BA96E5A0B1E985ACE69C88E9A18D';
  l_formula_names_tab(74) := 'WP_REVISED_SMR_VALIDATION';
  l_formula_desc_tab(74) := 'Validation of Wp Standard Monthly Remuneration';

  l_jp_formula_names_tab(75) := '4656EFBCBFE8BB8AE4B8A1E68385E5A0B1';
  l_formula_names_tab(75) := 'VEHICLE_INFO_VALIDATION';
  l_formula_desc_tab(75) := 'Validation of Vehicle Information';

  l_jp_formula_names_tab(76) := '46EFBCBFE7B5A6EFBCBFE59FBAE69CACEFBCBFE9809AE58BA4E6898BE5BD93';
  l_formula_names_tab(76) := 'SAL_CMA_PROC';
  l_formula_desc_tab(76) := 'Calculation of Commutation Allowance on Salary Process';

  l_jp_formula_names_tab(77) := '4656EFBCBFE581A5E4BF9DEFBCBFE6A899E6BA96E5A0B1E985ACE69C88E9A18DEFBCBFE5BE93E5898D';
  l_formula_names_tab(77) := 'HI_PRIOR_SMR_VALIDATION';
  l_formula_desc_tab(77) := 'Validation of Hi Prior Standard Monthly Remuneration';

  l_jp_formula_names_tab(78) := '4656EFBCBFE58E9AE5B9B4EFBCBFE6A899E6BA96E5A0B1E985ACE69C88E9A18DEFBCBFE5BE93E5898D';
  l_formula_names_tab(78) := 'WP_PRIOR_SMR_VALIDATION';
  l_formula_desc_tab(78) := 'Validation of Wp Prior Standard Monthly Remuneration';

  l_jp_formula_names_tab(79) := '4642EFBCBFE5B9B4EFBCBFE9818EE4B88DE8B6B3E7A88EE9A18D';
  l_formula_names_tab(79) := 'YEA_ITX';
  l_formula_desc_tab(79) := 'Calculation of Over and Short Tax Amount on Year End Adjustment';

  l_jp_formula_names_tab(80) := '4653EFBCBFE882B2E694B9EFBCBFE59FBAE69CACEFBCBFE5A0B1E985ACE69C88E9A18D';
  l_formula_names_tab(80) := 'IKU_MR_PROC_SKIP';
  l_formula_desc_tab(80) := 'Judgement of Calculation of Standard Monthly Renumeration on Unscheduled Revision after Chid-Care Leave';

  l_jp_formula_names_tab(81) := '46EFBCBFE882B2E694B9EFBCBFE59FBAE69CACEFBCBFE5A0B1E985ACE69C88E9A18D';
  l_formula_names_tab(81) := 'IKU_MR_PROC';
  l_formula_desc_tab(81) := 'Calculation of Standard Monthly Remuneration on Unscheduled Revision after Child-Care Leave';

  l_jp_formula_names_tab(82) := '4A505F4C495F4749505F5052454D';
  l_formula_names_tab(82) := 'LIFE_INS_GIP_PREM_TEMPLATE';
  l_formula_desc_tab(82) := 'Calculation Template of Group Life Insurance Premium Total for Insurance Premium and Spouse Special Exemption Declaration';

  l_jp_formula_names_tab(83) := '4A505F4C495F4C494E435F5052454D';
  l_formula_names_tab(83) := 'LIFE_INS_LINC_PREM_TEMPLATE';
  l_formula_desc_tab(83) := 'Calculation Template of Network Center Life Insurance Premium Total for Insurance Premium and Spouse Special Exemption Declaration';

 -- Added it for Bug# 6054975.

  l_jp_formula_names_tab(84) := '4A505F41495F5052454D5F43414C43';
  l_formula_names_tab(84) := 'ACCIDENT_INS_PREM_TEMPLATE';
  l_formula_desc_tab(84) := 'Calculation Template of Accident Insurance Premium Total for Insurance Premium and Spouse Special Exemption Declaration';

  hr_utility.set_location(l_proc, 20);

  if (g_dbg) then
    hr_utility.trace('| Fast Formulas Count = ' || l_jp_formula_names_tab.COUNT);
    hr_utility.trace('+----------------------------------+ ');
  end if;
--

  FORALL l_tab_cnt IN 1..l_jp_formula_names_tab.COUNT

    UPDATE ff_formulas_f
    SET    formula_name = l_formula_names_tab(l_tab_cnt),
           description = l_formula_desc_tab(l_tab_cnt)
    WHERE  formula_name LIKE hr_jp_standard_pkg.hextochar(l_jp_formula_names_tab(l_tab_cnt),'AL32UTF8')
    AND    legislation_code = 'JP';

  UPDATE ff_formulas_f
  SET    description = description || 'Obsoleted'
  WHERE  ASCII(description) > 127
  AND    legislation_code = 'JP';

  hr_utility.set_location(l_proc, 30);

  if (g_dbg) then
    hr_utility.trace('| Total Formulas Updated = ' || SQL%ROWCOUNT);
    hr_utility.trace('+-----------------------------------+ ');
  end if;
--
EXCEPTION

  WHEN OTHERS THEN

    hr_utility.set_location(l_proc, 40);

    raise;

END migrate_formulas;
--
-- |-------------------------------------------------------------------|
-- |--------------------< migrate_monetary_units >---------------------|
-- |-------------------------------------------------------------------|
--
procedure migrate_monetary_units is
--
  type t_jp_monetary_name_tab is table of VARCHAR2(50) index by binary_integer;

  type t_monetary_name_tab is table of pay_monetary_units.monetary_unit_name%TYPE index by binary_integer;

  l_jp_monetary_name_tab  t_jp_monetary_name_tab;
  l_monetary_name_tab     t_monetary_name_tab;

  l_proc            VARCHAR2(50) := g_pkg||'.migrate_monetary_units';

BEGIN

  l_jp_monetary_name_tab.DELETE;
  l_monetary_name_tab.DELETE;

  hr_utility.set_location(l_proc, 10);

  l_jp_monetary_name_tab(1) := '3130303030E58686';	l_monetary_name_tab(1) := 'TEN_THOUSAND_YEN';
  l_jp_monetary_name_tab(2) := '31303030E58686';	l_monetary_name_tab(2) := 'ONE_THOUSAND_YEN';
  l_jp_monetary_name_tab(3) := '313030E58686';	l_monetary_name_tab(3) := 'ONE_HUNDRED_YEN';
  l_jp_monetary_name_tab(4) := '3130E58686';	l_monetary_name_tab(4) := 'TEN_YEN';
  l_jp_monetary_name_tab(5) := '31E58686';	l_monetary_name_tab(5) := 'ONE_YEN';
  l_jp_monetary_name_tab(6) := '32303030E58686';	l_monetary_name_tab(6) := 'TWO_THOUSAND_YEN';
  l_jp_monetary_name_tab(7) := '35303030E58686';	l_monetary_name_tab(7) := 'FIVE_THOUSAND_YEN';
  l_jp_monetary_name_tab(8) := '353030E58686';	l_monetary_name_tab(8) := 'FIVE_HUNDRED_YEN';
  l_jp_monetary_name_tab(9) := '3530E58686';	l_monetary_name_tab(9) := 'FIFTY_YEN';
  l_jp_monetary_name_tab(10) := '35E58686';	l_monetary_name_tab(10) := 'FIVE_YEN';

  hr_utility.set_location(l_proc, 20);

  if (g_dbg) then
    hr_utility.trace('| Monetary Units Count = ' || l_jp_monetary_name_tab.COUNT);
    hr_utility.trace('+----------------------------------+ ');
  end if;
--

  FORALL l_tab_cnt IN 1..l_jp_monetary_name_tab.COUNT

    UPDATE pay_monetary_units
    SET    monetary_unit_name = l_monetary_name_tab(l_tab_cnt)
    WHERE  monetary_unit_name LIKE hr_jp_standard_pkg.hextochar(l_jp_monetary_name_tab(l_tab_cnt),'AL32UTF8')
    AND    legislation_code = 'JP';

  hr_utility.set_location(l_proc, 30);

  if (g_dbg) then
    hr_utility.trace('| Total Monetary Units Updated = ' || SQL%ROWCOUNT);
    hr_utility.trace('+-----------------------------------------+ ');
  end if;
--
EXCEPTION

  WHEN OTHERS THEN

    hr_utility.set_location(l_proc, 40);

    raise;

END migrate_monetary_units;
--
-- |-------------------------------------------------------------------|
-- |--------------------< migrate_user_columns >-----------------------|
-- |-------------------------------------------------------------------|
--
procedure migrate_user_columns is
--
  type t_jp_column_names_tab is table of VARCHAR2(200) index by binary_integer;

  type t_column_names_tab is table of pay_user_columns.user_column_name%TYPE index by binary_integer;

  l_jp_column_names_tab  t_jp_column_names_tab;
  l_column_names_tab     t_column_names_tab;

  l_proc              VARCHAR2(50) := g_pkg||'.migrate_user_columns';

BEGIN

  l_jp_column_names_tab.DELETE;
  l_column_names_tab.DELETE;

  hr_utility.set_location(l_proc, 10);

  l_jp_column_names_tab(1) := 'E4B880E888ACE98080E881B7';
  l_column_names_tab(1) := 'GEN_TRM';

  l_jp_column_names_tab(2) := 'E9818BE8B383E79BB8E5BD93E9A18DE584AAE58588';
  l_column_names_tab(2) := 'FARE_EQUIVALENT_AMT_PRIORITY_FLAG';

  l_jp_column_names_tab(3) := 'E4B999E6AC84EFBCBFE59FBAE6BA96E9A18D';
  l_column_names_tab(3) := 'OTSU_BASIC_AMT';

  l_jp_column_names_tab(4) := 'E4B999E6AC84EFBCBFE59FBAE6BA96E7A88EE9A18D';
  l_column_names_tab(4) := 'OTSU_BASIC_ITX';

  l_jp_column_names_tab(5) := 'E4B999E6AC84EFBCBFE7A88EE9A18D';
  l_column_names_tab(5) := 'OTSU_ITX';

  l_jp_column_names_tab(6) := 'E4B999E6AC84EFBCBFE78E87';
  l_column_names_tab(6) := 'OTSU_DCTBL_RATE';

  l_jp_column_names_tab(7) := 'E58AA0E7AE97E9A18D';
  l_column_names_tab(7) := 'ADD_AMT';

  l_jp_column_names_tab(8) := 'E8AAB2E7A88EE5AFBEE8B1A1E38395E383A9E382B0';
  l_column_names_tab(8) := 'TXBL_FLAG';

  l_jp_column_names_tab(9) := 'E99A8EE5B7AE';
  l_column_names_tab(9) := 'GRADE_DIFF';

  l_jp_column_names_tab(10) := 'E9A18D';
  l_column_names_tab(10) := 'AMT';

  l_jp_column_names_tab(11) := 'E59FBAE6BA96E9A18D';
  l_column_names_tab(11) := 'BASIC_AMT';

  l_jp_column_names_tab(12) := 'E59FBAE6BA96E7A88EE9A18D';
  l_column_names_tab(12) := 'BASIC_ITX';

  l_jp_column_names_tab(13) := 'E7B5A6EFBCBFE4BB8BE4BF9DEFBCBFE7ABAFE695B0E587A6E79086';
  l_column_names_tab(13) := 'SAL_CI_ROUNDING';

  l_jp_column_names_tab(14) := 'E7B5A6EFBCBFE4BB8BE4BF9DEFBCBFE8A2ABE4BF9DE999BAE88085E8B2A0E68B85E58886EFBCBFE7ABAFE695B0E587A6E79086';
  l_column_names_tab(14) := 'SAL_CI_ROUNDING_EE';

  l_jp_column_names_tab(15) := 'E7B5A6EFBCBFE4BB8BE4BF9DE69699E78E87';
  l_column_names_tab(15) := 'SAL_CI_RATE';

  l_jp_column_names_tab(16) := 'E7B5A6EFBCBFE4BB8BE4BF9DE69699E78E87EFBCBFE8A2ABE4BF9DE999BAE88085E8B2A0E68B85E58886';
  l_column_names_tab(16) := 'SAL_CI_RATE_EE';

  l_jp_column_names_tab(17) := 'E7B5A6EFBCBFE59FBAE98791E69699E78E87';
  l_column_names_tab(17) := 'SAL_WPF_RATE';

  l_jp_column_names_tab(18) := 'E7B5A6EFBCBFE59FBAE98791E69699E78E87EFBCBFE8A2ABE4BF9DE999BAE88085E8B2A0E68B85E58886';
  l_column_names_tab(18) := 'SAL_WPF_RATE_EE';

  l_jp_column_names_tab(19) := 'E7B5A6EFBCBFE581A5E4BF9DE69699E78E87';
  l_column_names_tab(19) := 'SAL_HI_RATE';

  l_jp_column_names_tab(20) := 'E7B5A6EFBCBFE581A5E4BF9DE69699E78E87EFBCBFE8A2ABE4BF9DE999BAE88085E8B2A0E68B85E58886';
  l_column_names_tab(20) := 'SAL_HI_RATE_EE';

  l_jp_column_names_tab(21) := 'E7B5A6EFBCBFE58E9AE5B9B4E69699E78E87';
  l_column_names_tab(21) := 'SAL_WP_RATE';

  l_jp_column_names_tab(22) := 'E7B5A6EFBCBFE58E9AE5B9B4E69699E78E87EFBCBFE8A2ABE4BF9DE999BAE88085E8B2A0E68B85E58886';
  l_column_names_tab(22) := 'SAL_WP_RATE_EE';

  l_jp_column_names_tab(23) := 'E585B1EFBCBFE4BB8BE4BF9DEFBCBFE7ABAFE695B0E587A6E79086';
  l_column_names_tab(23) := 'COM_CI_ROUNDING';

  l_jp_column_names_tab(24) := 'E585B1EFBCBFE4BB8BE4BF9DEFBCBFE7ABAFE695B0E587A6E79086EFBCBFE8A2ABE4BF9DE999BAE88085E8B2A0E68B85E58886';
  l_column_names_tab(24) := 'COM_CI_ROUNDING_EE';

  l_jp_column_names_tab(25) := 'E585B1EFBCBFE4BB8BE4BF9DE69699E78E87';
  l_column_names_tab(25) := 'COM_CI_RATE';

  l_jp_column_names_tab(26) := 'E585B1EFBCBFE4BB8BE4BF9DE69699E78E87EFBCBFE8A2ABE4BF9DE999BAE88085E8B2A0E68B85E58886';
  l_column_names_tab(26) := 'COM_CI_RATE_EE';

  l_jp_column_names_tab(27) := 'E585B1EFBCBFE59FBAE98791EFBCBFE7ABAFE695B0E587A6E79086';
  l_column_names_tab(27) := 'COM_WPF_ROUNDING';

  l_jp_column_names_tab(28) := 'E585B1EFBCBFE59FBAE98791EFBCBFE7ABAFE695B0E587A6E79086EFBCBFE8A2ABE4BF9DE999BAE88085E8B2A0E68B85E58886';
  l_column_names_tab(28) := 'COM_WPF_ROUNDING_EE';

  l_jp_column_names_tab(29) := 'E585B1EFBCBFE59FBAE98791E69699E78E87';
  l_column_names_tab(29) := 'COM_WPF_RATE';

  l_jp_column_names_tab(30) := 'E585B1EFBCBFE59FBAE98791E69699E78E87EFBCBFE8A2ABE4BF9DE999BAE88085E8B2A0E68B85E58886';
  l_column_names_tab(30) := 'COM_WPF_RATE_EE';

  l_jp_column_names_tab(31) := 'E585B1EFBCBFE581A5E4BF9DE69699E78E87';
  l_column_names_tab(31) := 'COM_HI_RATE';

  l_jp_column_names_tab(32) := 'E585B1EFBCBFE581A5E4BF9DE69699E78E87EFBCBFE8A2ABE4BF9DE999BAE88085E8B2A0E68B85E58886';
  l_column_names_tab(32) := 'COM_HI_RATE_EE';

  l_jp_column_names_tab(33) := 'E585B1EFBCBFE58E9AE5B9B4EFBCBFE7ABAFE695B0E587A6E79086';
  l_column_names_tab(33) := 'COM_WP_ROUNDING';

  l_jp_column_names_tab(34) := 'E585B1EFBCBFE58E9AE5B9B4EFBCBFE7ABAFE695B0E587A6E79086EFBCBFE8A2ABE4BF9DE999BAE88085E8B2A0E68B85E58886';
  l_column_names_tab(34) := 'COM_WP_ROUNDING_EE';

  l_jp_column_names_tab(35) := 'E585B1EFBCBFE58E9AE5B9B4E69699E78E87';
  l_column_names_tab(35) := 'COM_WP_RATE';

  l_jp_column_names_tab(36) := 'E585B1EFBCBFE58E9AE5B9B4E69699E78E87EFBCBFE8A2ABE4BF9DE999BAE88085E8B2A0E68B85E58886';
  l_column_names_tab(36) := 'COM_WP_RATE_EE';

  l_jp_column_names_tab(37) := 'E581A5E4BF9DE7AD89E7B49A';
  l_column_names_tab(37) := 'HI_GRADE';

  l_jp_column_names_tab(38) := 'E581A5E4BF9DE7AD89E7B49AEFBCBFE8A888E7AE97E794A8';
  l_column_names_tab(38) := 'HI_GRADE_CALC';

  l_jp_column_names_tab(39) := 'E581A5E4BF9DE6A899E6BA96E5A0B1E985ACE69C88E9A18D';
  l_column_names_tab(39) := 'HI_SMR';

  l_jp_column_names_tab(40) := 'E99990E5BAA6E9A18D';
  l_column_names_tab(40) := 'MAX';

  l_jp_column_names_tab(41) := 'E58E9AE5B9B4E7AD89E7B49A';
  l_column_names_tab(41) := 'WP_GRADE';

  l_jp_column_names_tab(42) := 'E58E9AE5B9B4E7AD89E7B49AEFBCBFE8A888E7AE97E794A8';
  l_column_names_tab(42) := 'WP_GRADE_CALC';

  l_jp_column_names_tab(43) := 'E58E9AE5B9B4E6A899E6BA96E5A0B1E985ACE69C88E9A18D';
  l_column_names_tab(43) := 'WP_SMR';

  l_jp_column_names_tab(44) := 'E68EA7E999A4E9A18D';
  l_column_names_tab(44) := 'ITX_CREDIT';

  l_jp_column_names_tab(45) := 'E794B2E6AC8430E4BABAEFBCBFE59FBAE6BA96E7A88EE9A18D';
  l_column_names_tab(45) := 'KOU_BASIC_AMT';

  l_jp_column_names_tab(46) := 'E794B2E6AC8430E4BABAEFBCBFE7A88EE9A18D';
  l_column_names_tab(46) := 'KOU7_ITX';

  l_jp_column_names_tab(47) := 'E794B2E6AC8431E4BABAEFBCBFE59FBAE6BA96E7A88EE9A18D';
  l_column_names_tab(47) := 'KOU0_BASIC_ITX';

  l_jp_column_names_tab(48) := 'E794B2E6AC8431E4BABAEFBCBFE7A88EE9A18D';
  l_column_names_tab(48) := 'KOU0_ITX';

  l_jp_column_names_tab(49) := 'E794B2E6AC8432E4BABAEFBCBFE59FBAE6BA96E7A88EE9A18D';
  l_column_names_tab(49) := 'KOU1_BASIC_ITX';

  l_jp_column_names_tab(50) := 'E794B2E6AC8432E4BABAEFBCBFE7A88EE9A18D';l_column_names_tab(50) := 'KOU1_ITX';

  l_jp_column_names_tab(51) := 'E794B2E6AC8433E4BABAEFBCBFE59FBAE6BA96E7A88EE9A18D';
  l_column_names_tab(51) := 'KOU2_BASIC_ITX';

  l_jp_column_names_tab(52) := 'E794B2E6AC8433E4BABAEFBCBFE7A88EE9A18D';
  l_column_names_tab(52) := 'KOU2_ITX';

  l_jp_column_names_tab(53) := 'E794B2E6AC8434E4BABAEFBCBFE59FBAE6BA96E7A88EE9A18D';
  l_column_names_tab(53) := 'KOU3_BASIC_ITX';

  l_jp_column_names_tab(54) := 'E794B2E6AC8434E4BABAEFBCBFE7A88EE9A18D';
  l_column_names_tab(54) := 'KOU3_ITX';

  l_jp_column_names_tab(55) := 'E794B2E6AC8435E4BABAEFBCBFE59FBAE6BA96E7A88EE9A18D';
  l_column_names_tab(55) := 'KOU4_BASIC_ITX';

  l_jp_column_names_tab(56) := 'E794B2E6AC8435E4BABAEFBCBFE7A88EE9A18D';
  l_column_names_tab(56) := 'KOU4_ITX';

  l_jp_column_names_tab(57) := 'E794B2E6AC8436E4BABAEFBCBFE59FBAE6BA96E7A88EE9A18D';
  l_column_names_tab(57) := 'KOU5_BASIC_ITX';

  l_jp_column_names_tab(58) := 'E794B2E6AC8436E4BABAEFBCBFE7A88EE9A18D';
  l_column_names_tab(58) := 'KOU5_ITX';

  l_jp_column_names_tab(59) := 'E794B2E6AC8437E4BABAEFBCBFE59FBAE6BA96E7A88EE9A18D';
  l_column_names_tab(59) := 'KOU6_BASIC_ITX';

  l_jp_column_names_tab(60) := 'E794B2E6AC8437E4BABAEFBCBFE7A88EE9A18D';
  l_column_names_tab(60) := 'KOU6_ITX';

  l_jp_column_names_tab(61) := 'E794B2E6AC84EFBCBFE59FBAE6BA96E9A18D';
  l_column_names_tab(61) := 'KOU7_BASIC_ITX';

  l_jp_column_names_tab(62) := 'E794B2E6AC84EFBCBFE78E87';
  l_column_names_tab(62) := 'KOU_DCTBL_RATE';

  l_jp_column_names_tab(63) := 'E5B882E58CBAE794BAE69D91E6B091E7A88E';
  l_column_names_tab(63) := 'MUNICIPAL_TAX';

  l_jp_column_names_tab(64) := 'E5B882E58CBAE794BAE69D91E6B091E7A88EE68EA7E999A4E9A18D';
  l_column_names_tab(64) := 'MUNICIPAL_TAX_DCT';

  l_jp_column_names_tab(65) := 'E5B882E58CBAE794BAE69D91E6B091E7A88EE78E87';
  l_column_names_tab(65) := 'MUNICIPAL_TAX_RATE';

  l_jp_column_names_tab(66) := 'E8B39EEFBCBFE789B9E588A5E581A5E4BF9DE69699E78E87';
  l_column_names_tab(66) := 'BON_HI_RATE';

  l_jp_column_names_tab(67) := 'E8B39EEFBCBFE789B9E588A5E581A5E4BF9DE69699E78E87EFBCBFE8A2ABE4BF9DE999BAE88085E8B2A0E68B85E58886';
  l_column_names_tab(67) := 'BON_HI_RATE_EE';

  l_jp_column_names_tab(68) := 'E8B39EEFBCBFE789B9E588A5E58E9AE5B9B4E69699E78E87';
  l_column_names_tab(68) := 'BON_WP_RATE';

  l_jp_column_names_tab(69) := 'E8B39EEFBCBFE789B9E588A5E58E9AE5B9B4E69699E78E87EFBCBFE8A2ABE4BF9DE999BAE88085E8B2A0E68B85E58886';
  l_column_names_tab(69) := 'BON_WP_RATE_EE';

  l_jp_column_names_tab(70) := 'E99A9CE5AEB3E98080E881B7';
  l_column_names_tab(70) := 'DISABLE_TRM';

  l_jp_column_names_tab(71) := 'E4B88AE99990E9A18D';
  l_column_names_tab(71) := 'MAX';

  l_jp_column_names_tab(72) := 'E7A88EE9A18D';
  l_column_names_tab(72) := 'ITX';

  l_jp_column_names_tab(73) := 'E7A88EE78E87';
  l_column_names_tab(73) := 'ITX_RATE';

  l_jp_column_names_tab(74) := 'E983BDE98193E5BA9CE79C8CE6B091E7A88E';
  l_column_names_tab(74) := 'PREFECTURAL_TAX';

  l_jp_column_names_tab(75) := 'E983BDE98193E5BA9CE79C8CE6B091E7A88EE68EA7E999A4E9A18D';
  l_column_names_tab(75) := 'PREFECTURAL_TAX_DCT';

  l_jp_column_names_tab(76) := 'E983BDE98193E5BA9CE79C8CE6B091E7A88EE78E87';
  l_column_names_tab(76) := 'PREFECTURAL_TAX_RATE';

  l_jp_column_names_tab(77) := 'E5908CE4B880E99A8EE5B7AEE381AEE69C80E5B08FE580A4';
  l_column_names_tab(77) := 'SAME_GRADE_MIN';

  l_jp_column_names_tab(78) := 'E4B899E6AC84EFBCBFE59FBAE6BA96E9A18D';
  l_column_names_tab(78) := 'HEI_BASIC_AMT';

  l_jp_column_names_tab(79) := 'E4B899E6AC84EFBCBFE59FBAE6BA96E7A88EE9A18D';
  l_column_names_tab(79) := 'HEI_BASIC_ITX';

  l_jp_column_names_tab(80) := 'E4B899E6AC84EFBCBFE7A88EE9A18D';
  l_column_names_tab(80) := 'HEI_ITX';

  l_jp_column_names_tab(81) := 'E4B899E6AC84EFBCBFE78E87';
  l_column_names_tab(81) := 'HEI_DCTBL_RATE';

  l_jp_column_names_tab(82) := 'E585B1EFBCBFE581A5E4BF9DEFBCBFE7ABAFE695B0E587A6E79086';
  l_column_names_tab(82) := 'COM_HI_ROUNDING';

  l_jp_column_names_tab(83) := 'E585B1EFBCBFE581A5E4BF9DEFBCBFE7ABAFE695B0E587A6E79086EFBCBFE8A2ABE4BF9DE999BAE88085E8B2A0E68B85E58886';
  l_column_names_tab(83) := 'COM_HI_ROUNDING_EE';

  l_jp_column_names_tab(84) := 'E585B1EFBCBFE581A5E4BF9DEFBCBFE7ABAFE695B0E587A6E79086E382BFE382A4E38397';
  l_column_names_tab(84) := 'COM_HI_ROUNDING_TYPE';

  l_jp_column_names_tab(85) := 'E78E87';
  l_column_names_tab(85) := 'DCTBL_RATE';


  hr_utility.set_location(l_proc, 20);

  if (g_dbg) then
    hr_utility.trace('| User Columns Count = ' || l_jp_column_names_tab.COUNT);
    hr_utility.trace('+----------------------------------+ ');
  end if;
--

  UPDATE pay_user_columns
  SET    user_column_name = 'RATE'
  WHERE  user_column_name LIKE hr_jp_standard_pkg.hextochar('E78E87','AL32UTF8')
  AND    legislation_code = 'JP'
  AND    user_table_id IN (
           SELECT user_table_id
           FROM   pay_user_tables
           WHERE  user_table_name IN (
             hr_jp_standard_pkg.hextochar('54EFBCBFE5B9B4EFBCBFE5808BE4BABAE5B9B4E98791E4BF9DE999BAE69699E68EA7E999A4E9A18DE8A1A8','AL32UTF8'),
             hr_jp_standard_pkg.hextochar('54EFBCBFE5B9B4EFBCBFE7949FE591BDE4BF9DE999BAE69699E68EA7E999A4E9A18DE8A1A8','AL32UTF8'),
             hr_jp_standard_pkg.hextochar('54EFBCBFE5B9B4EFBCBFE995B7E69C9FE6908DE5AEB3E4BF9DE999BAE69699E68EA7E999A4E9A18DE8A1A8','AL32UTF8'),
             hr_jp_standard_pkg.hextochar('54EFBCBFE5B9B4EFBCBFE79FADE69C9FE6908DE5AEB3E4BF9DE999BAE69699E68EA7E999A4E9A18DE8A1A8','AL32UTF8'))
           AND    legislation_code = 'JP');

  hr_utility.set_location(l_proc, 30);

  UPDATE pay_user_columns
  SET    user_column_name = 'EXM'
  WHERE  user_column_name LIKE hr_jp_standard_pkg.hextochar('E68EA7E999A4E9A18D','AL32UTF8')
  AND    legislation_code = 'JP'
  AND    user_table_id IN (
           SELECT user_table_id
           FROM   pay_user_tables
           WHERE  user_table_name IN (
             hr_jp_standard_pkg.hextochar('54EFBCBFE5B9B4EFBCBFE59084E7A8AEE68980E5BE97E68EA7E999A4E9A18DE8A1A8','AL32UTF8'),
             hr_jp_standard_pkg.hextochar('54EFBCBFE5B9B4EFBCBFE9858DE581B6E88085E789B9E588A5E68EA7E999A4E9A18DE697A9E8A68BE8A1A8','AL32UTF8'))
           AND    legislation_code = 'JP');

  hr_utility.set_location(l_proc, 40);

  UPDATE pay_user_columns
  SET    user_column_name = 'STD_DCT'
  WHERE  user_column_name LIKE hr_jp_standard_pkg.hextochar('E68EA7E999A4E9A18D','AL32UTF8')
  AND    legislation_code = 'JP'
  AND    user_table_id = (
           SELECT user_table_id
           FROM   pay_user_tables
           WHERE  user_table_name LIKE hr_jp_standard_pkg.hextochar('54EFBCBFE5B9B4EFBCBFE7B5A6E4B88EE68980E5BE97E68EA7E999A4E5BE8CE381AEE7B5A6E4B88EE7AD89E381AEE98791E9A18DE8A1A832','AL32UTF8')
           AND    legislation_code = 'JP');

  hr_utility.set_location(l_proc, 50);

  FORALL l_tab_cnt IN 1..l_jp_column_names_tab.COUNT

    UPDATE pay_user_columns
    SET    user_column_name = l_column_names_tab(l_tab_cnt)
    WHERE  user_column_name LIKE hr_jp_standard_pkg.hextochar(l_jp_column_names_tab(l_tab_cnt),'AL32UTF8')
    AND    legislation_code = 'JP';

  hr_utility.set_location(l_proc, 60);

  if (g_dbg) then
    hr_utility.trace('| Total User Columns Updated = ' || SQL%ROWCOUNT);
    hr_utility.trace('+-----------------------------------------+ ');
  end if;

--
EXCEPTION

  WHEN OTHERS THEN

    hr_utility.set_location(l_proc, 70);

    raise;

END migrate_user_columns;
--
-- |-------------------------------------------------------------------|
-- |----------------------< migrate_user_rows >------------------------|
-- |-------------------------------------------------------------------|
--
procedure migrate_user_rows is
--
  type t_jp_row_names_tab is table of VARCHAR2(200) index by binary_integer;

  type t_row_names_tab is table of pay_user_rows_f.row_low_range_or_name%TYPE index by binary_integer;

  l_jp_row_names_tab  t_jp_row_names_tab;
  l_row_names_tab     t_row_names_tab;

  l_proc           VARCHAR2(50) := g_pkg||'.migrate_user_rows';

BEGIN

  l_jp_row_names_tab.DELETE;
  l_row_names_tab.DELETE;

  hr_utility.set_location(l_proc, 10);

  l_jp_row_names_tab(1) := 'E9A790E8BB8AE5A0B4E4BBA3E7AD89';
  l_row_names_tab(1) := 'PARKING_FEE';

  l_jp_row_names_tab(2) := 'E69C88E9A18DE8A1A8EFBCBFE689B6E9A48AE8A6AAE6978FE7AD8931E4BABAE38182E3819FE3828AE381AEE68EA7E999A4E9A18D';
  l_row_names_tab(2) := 'MTH_TBL_PER_DEP_EXM';

  l_jp_row_names_tab(3) := 'E98080E881B7E68980E5BE97E68EA7E999A4E9A18DE8A1A8EFBCBFE58BA4E7B69AE5B9B4E695B031E5B9B4E38182E3819FE3828AE381AEE68EA7E999A4E9A18D';
  l_row_names_tab(3) := 'TRM_INCOME_EXM_TBL_PER_SERVICE_YEAR_EXM';

  l_jp_row_names_tab(4) := 'E697A5E9A18DE8A1A8EFBCBFE689B6E9A48AE8A6AAE6978FE7AD8931E4BABAE38182E3819FE3828AE381AEE68EA7E999A4E9A18D';
  l_row_names_tab(4) := 'DAY_TBL_PER_DEP_EXM';

  l_jp_row_names_tab(5) := 'E59FBAE7A48EE68EA7E999A4';
  l_row_names_tab(5) := 'BASIC_EXM';

  l_jp_row_names_tab(6) := 'E9858DE581B6E88085E68EA7E999A4';
  l_row_names_tab(6) := 'SPOUSE_EXM';

  l_jp_row_names_tab(7) := 'E689B6E9A48AE68EA7E999A4';
  l_row_names_tab(7) := 'DEP_EXM';

  l_jp_row_names_tab(8) := 'E694BFE5BA9CE7AEA1E68E8C';
  l_row_names_tab(8) := 'GOVT_MANAGE';

  l_jp_row_names_tab(9) := 'E4B880E888ACE68EA7E999A4E5AFBEE8B1A1E9858DE581B6E88085';
  l_row_names_tab(9) := 'GEN_SPOUSE';

  l_jp_row_names_tab(10) := 'E4B880E888ACE99A9CE5AEB3E88085';
  l_row_names_tab(10) := 'GEN_DISABLE';

  l_jp_row_names_tab(11) := 'E4B880E888ACE689B6E9A48AE8A6AAE6978F';
  l_row_names_tab(11) := 'GEN_DEP';

  l_jp_row_names_tab(12) := 'E5AFA1E5A4AB';
  l_row_names_tab(12) := 'WIDOWER';

  l_jp_row_names_tab(13) := 'E5AFA1E5A9A6';
  l_row_names_tab(13) := 'WIDOW';

  l_jp_row_names_tab(14) := 'E59FBAE7A48E';
  l_row_names_tab(14) := 'BASIC';

  l_jp_row_names_tab(15) := 'E58BA4E58AB4E5ADA6E7949F';
  l_row_names_tab(15) := 'WORKING_STUDENT';

  l_jp_row_names_tab(16) := 'E5908CE5B185E789B9E588A5E99A9CE5AEB3E88085';
  l_row_names_tab(16) := 'SEV_DISABLE_LT';

  l_jp_row_names_tab(17) := 'E5908CE5B185E88081E8A6AAE7AD89';
  l_row_names_tab(17) := 'ELDER_PARENT_LT';

  l_jp_row_names_tab(18) := 'E789B9E5AE9AE689B6E9A48AE8A6AAE6978F';
  l_row_names_tab(18) := 'SPECIFIC_DEP';

  l_jp_row_names_tab(19) := 'E789B9E588A5E381AEE5AFA1E5A9A6';
  l_row_names_tab(19) := 'SP_WIDOW';

  l_jp_row_names_tab(20) := 'E789B9E588A5E99A9CE5AEB3E88085';
  l_row_names_tab(20) := 'SEV_DISABLE';

  l_jp_row_names_tab(21) := 'E5B9B4E5B091E689B6E9A48AE8A6AAE6978F';
  l_row_names_tab(21) := 'JUNIOR_DEP';

  l_jp_row_names_tab(22) := 'E88081E4BABAE68EA7E999A4E5AFBEE8B1A1E9858DE581B6E88085';
  l_row_names_tab(22) := 'ELDER_SPOUSE';

  l_jp_row_names_tab(23) := 'E88081E4BABAE689B6E9A48AE8A6AAE6978F';
  l_row_names_tab(23) := 'ELDER_DEP';

  l_jp_row_names_tab(24) := 'E88081E5B9B4E88085';
  l_row_names_tab(24) := 'ELDER';

  l_jp_row_names_tab(25) := 'E5AFA1E5A4ABE68EA7E999A4EFBCBFE59088E8A888E68980E5BE97';
  l_row_names_tab(25) := 'WIDOWER_EXM_ANNUAL_INCOME';

  l_jp_row_names_tab(26) := 'E5AFA1E5A9A6E68EA7E999A4EFBCBFE59088E8A888E68980E5BE97';
  l_row_names_tab(26) := 'WINDOW_EXM_ANNUAL_INCOME';

  l_jp_row_names_tab(27) := 'E58BA4E58AB4E5ADA6E7949FE68EA7E999A4EFBCBFE59088E8A888E68980E5BE97';
  l_row_names_tab(27) := 'WORKING_STUDENT_EXM_ANNUAL_INCOME';

  l_jp_row_names_tab(28) := 'E68EA7E999A4E5AFBEE8B1A1E9858DE581B6E88085E68EA7E999A4EFBCBFE9858DE581B6E88085E59088E8A888E68980E5BE97';
  l_row_names_tab(28) := 'SPOUSE_EXM_SPOUSE_ANNUAL_INCOME';

  l_jp_row_names_tab(29) := 'E6908DE5AEB3E4BF9DE999BAE69699E68EA7E999A4';
  l_row_names_tab(29) := 'NONLIFE_INS_EXM';

  l_jp_row_names_tab(30) := 'E789B9E588A5E381AEE5AFA1E5A9A6E68EA7E999A4EFBCBFE59088E8A888E68980E5BE97';
  l_row_names_tab(30) := 'SP_WIDOW_EXM_ANNUAL_INCOME';

  l_jp_row_names_tab(31) := 'E5B9B4E69CABE8AABFE695B4E5AFBEE8B1A1EFBCBFE58F8EE585A5E98791E9A18D';
  l_row_names_tab(31) := 'YEA_ANNUAL_INCOME';

  l_jp_row_names_tab(32) := 'E9858DE581B6E88085E789B9E588A5E68EA7E999A4EFBCBFE68980E5BE97E88085E59088E8A888E68980E5BE97';
  l_row_names_tab(32) := 'SPOUSE_SP_EXM_EARNER_ANNUAL_INCOME';

  l_jp_row_names_tab(33) := 'E9858DE581B6E88085E789B9E588A5E68EA7E999A4EFBCBFE9858DE581B6E88085E59088E8A888E68980E5BE97';
  l_row_names_tab(33) := 'SPOUSE_SP_EXM_SPOUSE_ANNUAL_INCOME';

  l_jp_row_names_tab(34) := 'E88081E5B9B4E88085E68EA7E999A4EFBCBFE59088E8A888E68980E5BE97';
  l_row_names_tab(34) := 'ELDER_EXM_ANNUAL_INCOME';

  -- bug.5914738. Earthquake Insurance Premium support
  l_jp_row_names_tab(35) := 'E995B7E69C9FE6908DE5AEB3E4BF9DE999BAE69699E68EA7E999A4';
  l_row_names_tab(35) := 'LONG_TERM_NONLIFE_INS_EXM';

  l_jp_row_names_tab(36) := 'E59CB0E99C87E4BF9DE999BAE69699E68EA7E999A4';
  l_row_names_tab(36) := 'EARTHQUAKE_INS_EXM';

  hr_utility.set_location(l_proc, 20);

  if (g_dbg) then
    hr_utility.trace('| User Rows Count = ' || l_jp_row_names_tab.COUNT);
    hr_utility.trace('+----------------------------------+ ');
  end if;
--

  FORALL l_tab_cnt IN 1..l_jp_row_names_tab.COUNT

    UPDATE pay_user_rows_f
    SET    row_low_range_or_name = l_row_names_tab(l_tab_cnt)
    WHERE  row_low_range_or_name LIKE hr_jp_standard_pkg.hextochar(l_jp_row_names_tab(l_tab_cnt),'AL32UTF8')
    AND    legislation_code = 'JP';

  hr_utility.set_location(l_proc, 30);

  if (g_dbg) then
    hr_utility.trace('| Total User Rows Updated = ' || SQL%ROWCOUNT);
    hr_utility.trace('+-----------------------------------------+ ');
  end if;
--
EXCEPTION

  WHEN OTHERS THEN

    hr_utility.set_location(l_proc, 40);

    raise;

END migrate_user_rows;
--
-- |-------------------------------------------------------------------|
-- |---------------------< migrate_user_tables >-----------------------|
-- |-------------------------------------------------------------------|
--
procedure migrate_user_tables is
--
  type t_jp_table_names_tab is table of VARCHAR2(200) index by binary_integer;

  type t_table_names_tab is table of pay_user_tables.user_table_name%TYPE index by binary_integer;

  type t_row_titles_tab is table of pay_user_tables.user_row_title%TYPE index by binary_integer;

  l_jp_table_names_tab  t_jp_table_names_tab;
  l_table_names_tab     t_table_names_tab;
  l_row_titles_tab      t_row_titles_tab;

  l_proc             VARCHAR2(50) := g_pkg||'.migrate_user_tables';

BEGIN

  l_jp_table_names_tab.DELETE;
  l_table_names_tab.DELETE;
  l_row_titles_tab.DELETE;

  hr_utility.set_location(l_proc, 10);

  l_jp_table_names_tab(1) := '54EFBCBFE5B9B4EFBCBFE5808BE4BABAE5B9B4E98791E4BF9DE999BAE69699E68EA7E999A4E9A18DE8A1A8';
  l_table_names_tab(1) := 'T_YEA_INDIVIDUAL_PENSION_INS_EXM';
  l_row_titles_tab(1) := 'ANNUAL_INS_PREM';

  l_jp_table_names_tab(2) := '54EFBCBFE5B9B4EFBCBFE7B5A6E4B88EE68980E5BE97E68EA7E999A4E5BE8CE381AEE7B5A6E4B88EE7AD89E381AEE98791E9A18DE8A1A831';
  l_table_names_tab(2) := 'T_YEA_AMT_AFTER_EMP_INCOME_DCT1';
  l_row_titles_tab(2) := 'EMP_INCOME';

  l_jp_table_names_tab(3) := '54EFBCBFE5B9B4EFBCBFE7B5A6E4B88EE68980E5BE97E68EA7E999A4E5BE8CE381AEE7B5A6E4B88EE7AD89E381AEE98791E9A18DE8A1A832';
  l_table_names_tab(3) := 'T_YEA_AMT_AFTER_EMP_INCOME_DCT2';
  l_row_titles_tab(3) := 'YEA_EMP_INCOME';

  l_jp_table_names_tab(4) := '54EFBCBFE5B9B4EFBCBFE7949FE591BDE4BF9DE999BAE69699E68EA7E999A4E9A18DE8A1A8';
  l_table_names_tab(4) := 'T_YEA_LIFE_INS_EXM';
  l_row_titles_tab(4) := 'ANNUAL_INS_PREM';

  l_jp_table_names_tab(5) := '54EFBCBFE5B9B4EFBCBFE995B7E69C9FE6908DE5AEB3E4BF9DE999BAE69699E68EA7E999A4E9A18DE8A1A8';
  l_table_names_tab(5) := 'T_YEA_LONG_NONLIFE_INS_EXM';
  l_row_titles_tab(5) := 'ANNUAL_INS_PREM';

  l_jp_table_names_tab(6) := '54EFBCBFE5B9B4EFBCBFE79FADE69C9FE6908DE5AEB3E4BF9DE999BAE69699E68EA7E999A4E9A18DE8A1A8';
  l_table_names_tab(6) := 'T_YEA_SHORT_NONLIFE_INS_EXM';
  l_row_titles_tab(6) := 'ANNUAL_INS_PREM';

  l_jp_table_names_tab(7) := '54EFBCBFE5B9B4EFBCBFE9858DE581B6E88085E789B9E588A5E68EA7E999A4E9A18DE697A9E8A68BE8A1A8';
  l_table_names_tab(7) := 'T_YEA_SPOUSE_SP_EXM_RECKONER';
  l_row_titles_tab(7) := 'SPOUSE_ANNUAL_INCOME';

  l_jp_table_names_tab(8) := '54EFBCBFE5B9B4EFBCBFE59084E7A8AEE68980E5BE97E68EA7E999A4E9A18DE8A1A8';
  l_table_names_tab(8) := 'T_YEA_INCOME_EXM';
  l_row_titles_tab(8) := 'INCOME_EXM_TYPE';

  l_jp_table_names_tab(9) := '54EFBCBFE5B9B4EFBCBFE59084E7A8AEE4B88AE99990E9A18DE8A1A8';
  l_table_names_tab(9) := 'T_YEA_MAX_AMT';
  l_row_titles_tab(9) := 'AMT_TYPE';

  l_jp_table_names_tab(10) := '54EFBCBFE5B9B4EFBCBFE6BA90E6B389E5BEB4E58F8EE7A88EE9A18DE9809FE7AE97E8A1A8';
  l_table_names_tab(10) := 'T_YEA_ITX_RAPID_CALC';
  l_row_titles_tab(10) := 'TXBL_INCOME';

  l_jp_table_names_tab(11) := '54EFBCBFE585B1EFBCBFE6A899E6BA96E5A0B1E985ACE69C88E9A18DE8A1A8';
  l_table_names_tab(11) := 'T_COM_SMR';
  l_row_titles_tab(11) := 'MR';

  l_jp_table_names_tab(12) := '54EFBCBFE585B1EFBCBFE6BA90E6B389E5BEB4E58F8EE7A88EE9A18DE8A1A8EFBCBFE69C88E9A18DE8A1A8E794B2E6AC84EFBCBFE588A5E8A1A831';
  l_table_names_tab(12) := 'T_COM_ITX_MTH_KOU_APPENDIX1';
  l_row_titles_tab(12) := 'AMT_AFTER_SI_PREM_DCT';

  l_jp_table_names_tab(13) := '54EFBCBFE585B1EFBCBFE6BA90E6B389E5BEB4E58F8EE7A88EE9A18DE8A1A8EFBCBFE69C88E9A18DE8A1A8E794B2E6AC84EFBCBFE588A5E8A1A832';
  l_table_names_tab(13) := 'T_COM_ITX_MTH_KOU_APPENDIX2';
  l_row_titles_tab(13) := 'INCOME_EXM_TYPE';

  l_jp_table_names_tab(14) := '54EFBCBFE585B1EFBCBFE6BA90E6B389E5BEB4E58F8EE7A88EE9A18DE8A1A8EFBCBFE69C88E9A18DE8A1A8E794B2E6AC84EFBCBFE588A5E8A1A833';
  l_table_names_tab(14) := 'T_COM_ITX_MTH_KOU_APPENDIX3';
  l_row_titles_tab(14) := 'TXBL_ERN';

  l_jp_table_names_tab(15) := '54EFBCBFE7B5A6EFBCBFE6BA90E6B389E5BEB4E58F8EE7A88EE9A18DE8A1A8EFBCBFE69C88E9A18DE8A1A8E4B999E6AC8431';
  l_table_names_tab(15) := 'T_SAL_ITX_MTH_OTSU1';
  l_row_titles_tab(15) := 'AMT_AFTER_SI_PREM_DCT';

  l_jp_table_names_tab(16) := '54EFBCBFE7B5A6EFBCBFE6BA90E6B389E5BEB4E58F8EE7A88EE9A18DE8A1A8EFBCBFE69C88E9A18DE8A1A8E4B999E6AC8432';
  l_table_names_tab(16) := 'T_SAL_ITX_MTH_OTSU2';
  l_row_titles_tab(16) := 'AMT_AFTER_SI_PREM_DCT';

  l_jp_table_names_tab(17) := '54EFBCBFE7B5A6EFBCBFE6BA90E6B389E5BEB4E58F8EE7A88EE9A18DE8A1A8EFBCBFE697A5E9A18DE8A1A831';
  l_table_names_tab(17) := 'T_SAL_ITX_DAY1';
  l_row_titles_tab(17) := 'AMT_AFTER_SI_PREM_DCT';

  l_jp_table_names_tab(18) := '54EFBCBFE7B5A6EFBCBFE6BA90E6B389E5BEB4E58F8EE7A88EE9A18DE8A1A8EFBCBFE697A5E9A18DE8A1A832';
  l_table_names_tab(18) := 'T_SAL_ITX_DAY2';
  l_row_titles_tab(18) := 'AMT_AFTER_SI_PREM_DCT';

  l_jp_table_names_tab(19) := '54EFBCBFE8B39EEFBCBFE6BA90E6B389E5BEB4E58F8EE7A88EE9A18DE7AE97E587BAE78E87E8A1A8EFBCBFE794B2E6AC8430E4BABA';
  l_table_names_tab(19) := 'T_BON_ITX_RATE_KOU0';
  l_row_titles_tab(19) := 'PREV_MTH_AMT_AFTER_SI_PREM_DCT';

  l_jp_table_names_tab(20) := '54EFBCBFE8B39EEFBCBFE6BA90E6B389E5BEB4E58F8EE7A88EE9A18DE7AE97E587BAE78E87E8A1A8EFBCBFE794B2E6AC8431E4BABA';
  l_table_names_tab(20) := 'T_BON_ITX_RATE_KOU1';
  l_row_titles_tab(20) := 'PREV_MTH_AMT_AFTER_SI_PREM_DCT';

  l_jp_table_names_tab(21) := '54EFBCBFE8B39EEFBCBFE6BA90E6B389E5BEB4E58F8EE7A88EE9A18DE7AE97E587BAE78E87E8A1A8EFBCBFE794B2E6AC8432E4BABA';
  l_table_names_tab(21) := 'T_BON_ITX_RATE_KOU2';
  l_row_titles_tab(21) := 'PREV_MTH_AMT_AFTER_SI_PREM_DCT';

  l_jp_table_names_tab(22) := '54EFBCBFE8B39EEFBCBFE6BA90E6B389E5BEB4E58F8EE7A88EE9A18DE7AE97E587BAE78E87E8A1A8EFBCBFE794B2E6AC8433E4BABA';
  l_table_names_tab(22) := 'T_BON_ITX_RATE_KOU3';
  l_row_titles_tab(22) := 'PREV_MTH_AMT_AFTER_SI_PREM_DCT';

  l_jp_table_names_tab(23) := '54EFBCBFE8B39EEFBCBFE6BA90E6B389E5BEB4E58F8EE7A88EE9A18DE7AE97E587BAE78E87E8A1A8EFBCBFE794B2E6AC8434E4BABA';
  l_table_names_tab(23) := 'T_BON_ITX_RATE_KOU4';
  l_row_titles_tab(23) := 'PREV_MTH_AMT_AFTER_SI_PREM_DCT';

  l_jp_table_names_tab(24) := '54EFBCBFE8B39EEFBCBFE6BA90E6B389E5BEB4E58F8EE7A88EE9A18DE7AE97E587BAE78E87E8A1A8EFBCBFE794B2E6AC8435E4BABA';
  l_table_names_tab(24) := 'T_BON_ITX_RATE_KOU5';
  l_row_titles_tab(24) := 'PREV_MTH_AMT_AFTER_SI_PREM_DCT';

  l_jp_table_names_tab(25) := '54EFBCBFE8B39EEFBCBFE6BA90E6B389E5BEB4E58F8EE7A88EE9A18DE7AE97E587BAE78E87E8A1A8EFBCBFE794B2E6AC8436E4BABA';
  l_table_names_tab(25) := 'T_BON_ITX_RATE_KOU6';
  l_row_titles_tab(25) := 'PREV_MTH_AMT_AFTER_SI_PREM_DCT';

  l_jp_table_names_tab(26) := '54EFBCBFE8B39EEFBCBFE6BA90E6B389E5BEB4E58F8EE7A88EE9A18DE7AE97E587BAE78E87E8A1A8EFBCBFE794B2E6AC8437E4BABA';
  l_table_names_tab(26) := 'T_BON_ITX_RATE_KOU7';
  l_row_titles_tab(26) := 'PREV_MTH_AMT_AFTER_SI_PREM_DCT';

  l_jp_table_names_tab(27) := '54EFBCBFE8B39EEFBCBFE6BA90E6B389E5BEB4E58F8EE7A88EE9A18DE7AE97E587BAE78E87E8A1A8EFBCBFE4B999E6AC84';
  l_table_names_tab(27) := 'T_BON_ITX_RATE_OTSU';
  l_row_titles_tab(27) := 'PREV_MTH_AMT_AFTER_SI_PREM_DCT';

  l_jp_table_names_tab(28) := '54EFBCBFE98080EFBCBFE98080E881B7E68980E5BE97E68EA7E999A4E9A18DE8A1A8';
  l_table_names_tab(28) := 'T_TRM_INCOME_EXM';
  l_row_titles_tab(28) := 'SERVICE_YEARS';

  l_jp_table_names_tab(29) := '54EFBCBFE98080EFBCBFE4BD8FE6B091E7A88EE789B9E588A5E5BEB4E58F8EE7A88EE9A18DE8A1A831';
  l_table_names_tab(29) := 'T_TRM_LTX1';
  l_row_titles_tab(29) := 'AMT_AFTER_TRM_INCOME_DCT';

  l_jp_table_names_tab(30) := '54EFBCBFE98080EFBCBFE4BD8FE6B091E7A88EE789B9E588A5E5BEB4E58F8EE7A88EE9A18DE8A1A832';
  l_table_names_tab(30) := 'T_TRM_LTX2';
  l_row_titles_tab(30) := 'AMT_AFTER_TRM_INCOME_DCT';

  l_jp_table_names_tab(31) := '54EFBCBFE98080EFBCBFE6BA90E6B389E5BEB4E58F8EE7A88EE9A18DE9809FE7AE97E8A1A8';
  l_table_names_tab(31) := 'T_TRM_ITX_RAPID_CALC';
  l_row_titles_tab(31) := 'TXBL_INCOME';

  l_jp_table_names_tab(32) := '54EFBCBFE585B1EFBCBFE59084E7A8AEE59FBAE7A48EE98791E9A18DE8A1A8';
  l_table_names_tab(32) := 'T_COM_BASE_AMT';
  l_row_titles_tab(32) := 'BASE_AMT_TYPE';

  l_jp_table_names_tab(33) := '54EFBCBFE581A5E4BF9DE58E9AE5B9B4E4BF9DE999BAE69699E78E87';
  l_table_names_tab(33) := 'T_HI_WP_PREM_RATE';
  l_row_titles_tab(33) := 'RATE_TYPE';

  l_jp_table_names_tab(34) := '54EFBCBFE7B5A6EFBCBFE4BAA4E9809AE794A8E585B7EFBCBFE99D9EE8AAB2E7A88EE99990E5BAA6E9A18D';
  l_table_names_tab(34) := 'T_SAL_CMA_PRIVATE_TRANSPORT_NTXBL_ERN_MAX';
  l_row_titles_tab(34) := 'DISTANCE';

  l_jp_table_names_tab(35) := '54EFBCBFE7B5A6EFBCBFE9809AE58BA4E6898BE6AEB5EFBCBFE68385E5A0B1';
  l_table_names_tab(35) := 'T_SAL_CMA_METHOD_INFO';
  l_row_titles_tab(35) := 'CMA_METHOD';

  hr_utility.set_location(l_proc, 20);

  if (g_dbg) then
    hr_utility.trace('| User Tables Count = ' || l_jp_table_names_tab.COUNT);
    hr_utility.trace('+----------------------------------+ ');
  end if;
--

  FORALL l_tab_cnt IN 1..l_jp_table_names_tab.COUNT

    UPDATE pay_user_tables
    SET    user_table_name = l_table_names_tab(l_tab_cnt),
           user_row_title = l_row_titles_tab(l_tab_cnt)
    WHERE  user_table_name LIKE hr_jp_standard_pkg.hextochar(l_jp_table_names_tab(l_tab_cnt),'AL32UTF8')
    AND    legislation_code = 'JP';

  hr_utility.set_location(l_proc, 30);

  if (g_dbg) then
    hr_utility.trace('| Total User Tables Updated = ' || SQL%ROWCOUNT);
    hr_utility.trace('+-----------------------------------------+ ');
  end if;
--
EXCEPTION

  WHEN OTHERS THEN

    hr_utility.set_location(l_proc, 40);

    raise;

END migrate_user_tables;
--
-- |-------------------------------------------------------------------|
-- |-------------------------< delete_dbi >----------------------------|
-- |-------------------------------------------------------------------|
--
procedure delete_dbi is
  --
  b_script_already_run          BOOLEAN;
  --
  CURSOR c_del_dtls IS
  SELECT *
  FROM   pay_patch_status
  WHERE  patch_number     = 5758299
  AND    patch_name       = 'JP_UPGRADE_R12'
  AND    phase            = 'C'
  AND    legislation_code = 'JP';
  rec_del_dtls   c_del_dtls%ROWTYPE;
  --
  cursor csr_global is
  select g.global_name,
         g.data_type,
         g.global_id,
         g.business_group_id,
         g.legislation_code,
         g.created_by,
         g.creation_date
  from   ff_globals_f g
  where  g.legislation_code = 'JP'
  and    not exists(
           select null
           from   ff_globals_f g2
           where  g2.global_id = g.global_id
           and    g2.effective_start_date < g.effective_start_date);
  --
begin
  --
  OPEN c_del_dtls;
  FETCH c_del_dtls INTO rec_del_dtls;
    IF c_del_dtls%NOTFOUND THEN
      b_script_already_run := false;
    ELSE
      b_script_already_run := true;
    END IF;
  CLOSE  c_del_dtls;
  --
  IF NOT b_script_already_run THEN
    --
    -- bug.6040440
    -- 1) Delete CUST dbis which are created in pyjpgdbi.sql.
    -- 2) Both B and RB user entities need to be deleted.
    --    No DBIs for RB user entities, so no need to specify RB
    --    in the following 2 delete SQLs.
    -- 3) Delete Global Value DBIs, then rebuild.
    -- 4) PER_BUSINESS_GROUPS -> PER_BUSINESS_GROUPS_PERF
    --
    DELETE ff_compiled_info_f
    WHERE  formula_id in (
             SELECT /*+ ORDERED USE_NL(BG FDU FDT FUE BG2) */
                    distinct f.formula_id
             FROM   ff_formulas_f            f,
                    per_business_groups_perf bg,
                    ff_fdi_usages_f          fdu,
                    ff_database_items        fdt,
                    ff_user_entities         fue,
                    per_business_groups_perf bg2
             where  (f.legislation_code = 'JP' or f.business_group_id is not null)
             and    bg.business_group_id(+) = f.business_group_id
             and    nvl(f.legislation_code, bg.legislation_code) = 'JP'
             and    fdu.formula_id = f.formula_id
             and    fdu.effective_start_date = f.effective_start_date
             and    fdu.effective_end_date = f.effective_end_date
             and    fdu.usage = 'D'
             and    fdt.user_name = fdu.item_name
             and    fue.user_entity_id = fdt.user_entity_id
             -- bug.5758299
             and    (
                       (fue.legislation_code = 'JP' and fue.creator_type in ('E', 'I', 'CUST', 'S')
                    or (fue.creator_type = 'B'))
                    )
             and    bg2.business_group_id(+) = fue.business_group_id
             and    nvl(fue.legislation_code, bg2.legislation_code) = 'JP');
--    dbms_output.put_line(SQL%ROWCOUNT || ' rows deleted from FF_COMPILED_INFO_F');
    --
    DELETE ff_fdi_usages_f
    WHERE  formula_id in (
             SELECT /*+ ORDERED USE_NL(BG FDU FDT FUE BG2) */
                    distinct f.formula_id
             FROM   ff_formulas_f            f,
                    per_business_groups_perf bg,
                    ff_fdi_usages_f          fdu,
                    ff_database_items        fdt,
                    ff_user_entities         fue,
                    per_business_groups_perf bg2
             where  (f.legislation_code = 'JP' or f.business_group_id is not null)
             and    bg.business_group_id(+) = f.business_group_id
             and    nvl(f.legislation_code, bg.legislation_code) = 'JP'
             and    fdu.formula_id = f.formula_id
             and    fdu.effective_start_date = f.effective_start_date
             and    fdu.effective_end_date = f.effective_end_date
             and    fdu.usage = 'D'
             and    fdt.user_name = fdu.item_name
             and    fue.user_entity_id = fdt.user_entity_id
             -- bug.5758299
             and    (
                       (fue.legislation_code = 'JP' and fue.creator_type in ('E', 'I', 'CUST', 'S')
                    or (fue.creator_type = 'B'))
                    )
             and    bg2.business_group_id(+) = fue.business_group_id
             and    nvl(fue.legislation_code, bg2.legislation_code) = 'JP');
--    dbms_output.put_line(SQL%ROWCOUNT || ' rows deleted from FF_FDI_USAGES_F');
    --
    -- bug.5758299
    DELETE ff_user_entities
    WHERE  (    legislation_code = 'JP'
            and creator_type in ('E', 'I', 'B', 'RB', 'CUST', 'S'))
    OR     (    business_group_id IN (
                  SELECT business_group_id
                  FROM   per_business_groups_perf
                  WHERE  legislation_code = 'JP')
            and creator_type in ('B', 'RB'));
--    dbms_output.put_line(SQL%ROWCOUNT || ' rows deleted from FF_USER_ENTITIES');
    --
    -- bug.6040440
    -- Rebuild Global Values DBIs.
    --
    for l_global_rec in csr_global loop
      ffdict.create_global_dbitem(l_global_rec.global_name,
                                  l_global_rec.data_type,
                                  l_global_rec.global_id,
                                  l_global_rec.business_group_id,
                                  l_global_rec.legislation_code,
                                  l_global_rec.created_by,
                                  l_global_rec.creation_date);
--      dbms_output.put_line('Global Value DBI: ' || l_global_rec.global_name || ' created.');
    end loop;
    --
    INSERT INTO pay_patch_status
    (id
     ,patch_number
     ,patch_name
     ,phase
     ,applied_date
     ,legislation_code)
    SELECT pay_patch_status_s.nextval
      ,5758299
      ,'JP_UPGRADE_R12'
      ,'C'
      ,sysdate
      ,'JP'
    FROM dual;
    --
  END IF;
Exception
  --
  When Others Then
  --
   hr_utility.set_location( 'Error in deleting',99  );
   raise;
   --
END delete_dbi;
--
procedure migrate_org_df(
  p_org_information_context in varchar2,
  p_org_information3_o      in varchar2,
  p_org_information3_n      in varchar2)
is
--
  l_proc varchar2(60) := g_pkg||'.migrate_org_df';
--
  l_cnt number := 0;
--
  cursor csr_org_df
  is
  select /*+ ORDERED */
         hoi.rowid row_id
  from   per_business_groups_perf pbg,
         hr_all_organization_units hou,
         hr_organization_information hoi
  where  pbg.legislation_code = 'JP'
  and    hou.business_group_id = pbg.business_group_id
  and    hoi.organization_id = hou.organization_id
  and    hoi.org_information_context = p_org_information_context
  and    hoi.org_information3 = p_org_information3_o;
--
  l_csr_org_df csr_org_df%rowtype;
--
begin
--
  if (g_dbg) then
    hr_utility.set_location(l_proc, 0);
  end if;
--
  open csr_org_df;
  loop
  --
    fetch csr_org_df into l_csr_org_df;
    exit when csr_org_df%notfound;
  --
    update hr_organization_information
    set org_information3 = p_org_information3_n
    where rowid = l_csr_org_df.row_id;
  --
    if l_cnt > 1000 then
    --
      commit;
    --
    end if;
  --
    l_cnt := l_cnt + 1;
  --
  end loop;
  close csr_org_df;
--
  if (g_dbg) then
    hr_utility.set_location(l_proc, 10);
    hr_utility.trace('update cnt                : '||to_char(l_cnt));
    hr_utility.trace('p_org_information_context : '||p_org_information_context);
    hr_utility.trace('p_org_information3_o      : '||p_org_information3_o);
    hr_utility.trace('p_org_information3_n      : '||p_org_information3_n);
  end if;
--
  if l_cnt > 0 then
  --
    commit;
  --
  end if;
--
  if (g_dbg) then
    hr_utility.set_location(l_proc, 1000);
  end if;
--
end migrate_org_df;
--
procedure migrate_li_ff
is
--
  l_proc varchar2(60) := g_pkg||'.migrate_li_ff';
--
  l_li_ff_cnt number := 0;
--
  cursor csr_li_ff
  is
  select /*+ ORDERED */
         count(hoi.org_information_id)
  from   per_business_groups_perf pbg,
         hr_all_organization_units hou,
         hr_organization_information hoi
  where  pbg.legislation_code = 'JP'
  and    hou.business_group_id = pbg.business_group_id
  and    hoi.organization_id = hou.organization_id
  and    hoi.org_information_context in (
           'JP_LI_GIP_INFO',
           'JP_LI_LINC_INFO',
           'JP_ACCIDENT_INS_INFO')
  and    hoi.org_information3 in (
           'JP_LI_GIP_PREM',
           'JP_LI_LINC_PREM',
           'JP_AI_PREM_CALC');
--
begin
--
  if (g_dbg) then
    hr_utility.set_location(l_proc, 0);
  end if;
--
  open csr_li_ff;
  fetch csr_li_ff into l_li_ff_cnt;
  close csr_li_ff;
--
  if (g_dbg) then
    hr_utility.set_location(l_proc, 10);
    hr_utility.trace('migrate li ff cnt : '||to_char(l_li_ff_cnt));
  end if;
--
  if (l_li_ff_cnt > 0) then
  --
    migrate_org_df('JP_LI_GIP_INFO','JP_LI_GIP_PREM','LIFE_INS_GIP_PREM_TEMPLATE');
    migrate_org_df('JP_LI_LINC_INFO','JP_LI_LINC_PREM','LIFE_INS_LINC_PREM_TEMPLATE');
    migrate_org_df('JP_ACCIDENT_INS_INFO','JP_AI_PREM_CALC','ACCIDENT_INS_PREM_TEMPLATE');
  --
  end if;
--
  if (g_dbg) then
    hr_utility.set_location(l_proc, 1000);
  end if;
--
end migrate_li_ff;
--
-- |-------------------------------------------------------------------|
-- |-----------------------< migrate_data >----------------------------|
-- |-------------------------------------------------------------------|
--
procedure migrate_data is
--
  l_count NUMBER(4);
--
  l_proc  VARCHAR2(50) := g_pkg||'.migrate_data';
--
BEGIN

  hr_utility.set_location(l_proc, 10);

  SELECT COUNT(1)
  INTO   l_count
  FROM   pay_input_values_f
  WHERE  legislation_code = 'JP'
  AND    ( ASCII(name) > 127 OR SUBSTR(name,1,1) = '2');

  IF (l_count > 0) THEN
    migrate_input_values;
  END IF;

  hr_utility.set_location(l_proc, 20);

  SELECT COUNT(1)
  INTO   l_count
  FROM   pay_element_types_f
  WHERE  legislation_code = 'JP'
  AND    ASCII(element_name) > 127
  AND    description NOT LIKE '%Obsoleted';

  IF (l_count > 0) THEN
    migrate_element_types;
  END IF;

  hr_utility.set_location(l_proc, 30);

  SELECT COUNT(1)
  INTO   l_count
  FROM   pay_element_classifications
  WHERE  legislation_code = 'JP'
  AND    ASCII(SUBSTR(classification_name,8,1)) > 127;

  IF (l_count > 0) THEN
    migrate_element_class;
  END IF;

  hr_utility.set_location(l_proc, 40);

  SELECT COUNT(1)
  INTO   l_count
  FROM   pay_balance_types
  WHERE  legislation_code = 'JP'
  AND    ASCII(SUBSTR(balance_name,3,1)) > 127
  AND    reporting_name NOT LIKE '%Obsoleted';

  IF (l_count > 0) THEN
    migrate_balance_types;
  END IF;

  hr_utility.set_location(l_proc, 50);

  SELECT COUNT(1)
  INTO   l_count
  FROM   pay_balance_dimensions
  WHERE  legislation_code = 'JP'
  AND    ASCII(SUBSTR(dimension_name,3,1)) > 127;

  IF (l_count > 0) THEN
    migrate_bal_dimensions;
  END IF;

  hr_utility.set_location(l_proc, 60);

  SELECT COUNT(1)
  INTO   l_count
  FROM   pay_element_sets
  WHERE  legislation_code = 'JP'
  AND    ASCII(element_set_name) > 127;

  IF (l_count > 0) THEN
    migrate_element_sets;
  END IF;

  hr_utility.set_location(l_proc, 70);

  SELECT COUNT(1)
  INTO   l_count
  FROM   ff_globals_f
  WHERE  legislation_code = 'JP'
  AND    ASCII(SUBSTR(global_name,3,1)) > 127
  AND    global_description NOT LIKE '%Obsoleted';

  IF (l_count > 0) THEN
    migrate_globals;
  END IF;

  hr_utility.set_location(l_proc, 80);

  SELECT COUNT(1)
  INTO   l_count
  FROM   ff_formulas_f
  WHERE  legislation_code = 'JP'
  AND    ASCII(SUBSTR(formula_name,3,1)) > 127
  AND    description NOT LIKE '%Obsoleted';

  IF (l_count > 0) THEN
    migrate_formulas;
  END IF;

  hr_utility.set_location(l_proc, 90);

  SELECT COUNT(1)
  INTO   l_count
  FROM   pay_monetary_units
  WHERE  legislation_code = 'JP'
  AND    ASCII(SUBSTR(monetary_unit_name,LENGTH(monetary_unit_name),1)) > 127;

  IF (l_count > 0) THEN
    migrate_monetary_units;
  END IF;

  hr_utility.set_location(l_proc, 100);

  SELECT COUNT(1)
  INTO   l_count
  FROM   pay_user_columns
  WHERE  legislation_code = 'JP'
  AND    ASCII(user_column_name) > 127;

  IF (l_count > 0) THEN
    migrate_user_columns;
  END IF;

  hr_utility.set_location(l_proc, 110);

  SELECT COUNT(1)
  INTO   l_count
  FROM   pay_user_rows_f
  WHERE  legislation_code = 'JP'
  AND    ASCII(row_low_range_or_name) > 127;

  IF (l_count > 0) THEN
    migrate_user_rows;
  END IF;

  hr_utility.set_location(l_proc, 120);

  SELECT COUNT(1)
  INTO   l_count
  FROM   pay_user_tables
  WHERE  legislation_code = 'JP'
  AND    ASCII(SUBSTR(user_table_name,3,1)) > 127;

  IF (l_count > 0) THEN
    migrate_user_tables;
  END IF;

  hr_utility.set_location(l_proc, 130);

  -- To delete JP Char DBI's
  delete_dbi;

  hr_utility.set_location(l_proc, 140);
--
  migrate_li_ff;
  hr_utility.set_location('Successful completion of ' || l_proc, 150);
--
EXCEPTION

  WHEN OTHERS THEN

    hr_utility.set_location(l_proc, 150);

    raise;

END migrate_data;
--
END pay_jp_data_migration_pkg;

/

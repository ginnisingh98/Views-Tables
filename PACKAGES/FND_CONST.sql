--------------------------------------------------------
--  DDL for Package FND_CONST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_CONST" AUTHID CURRENT_USER as
  /* $Header: AFSCCONS.pls 120.4 2008/05/23 07:30:46 absandhw ship $ */
  /*#
   * Application data types.
   * The server-side package FND_CONST
   * @rep:scope internal
   * @rep:product FND
   * @rep:displayname Application Constants
   * @rep:compatibility S
   * @rep:lifecycle active
   * @rep:ihelp FND/@e_const#e_const See related online help
   */

  -- although the index is 2000, sys_context only support 30 character names
  -- so the names will be truncated in the sys_context if they exceed 30.
  type t_hashtable is table of varchar2(2000) index by varchar2(2000);

  /*#
   * This API returns specified character in current character codeset.
   * @param ascii_chr Number representation of character in US7ASCII codeset.
   * @paraminfo {@rep:required}
   * @rep:displayname Converts US7ASCII Character Codeset of a Character to Current Character Codeset
   * @rep:scope internal
   * @rep:lifecycle active
   */
  function local_chr(ascii_chr in number) return varchar2;

  function NEWLINE return varchar2;
  function TAB return varchar2;

  function BOOL(v boolean default true) return varchar2;
  function BOOL(v varchar2 default 'true') return boolean;
  function BOOL(v number default 1) return boolean;

  UNDEFINED_I constant integer := -1;
  UNDEFINED_S constant varchar2(2) := to_char(UNDEFINED_I);

  -- initialization modes corresponding to pl/sql parameter modes
  MODE_IN constant varchar2(2) := 'IN';
  MODE_OUT constant varchar2(3) := 'OUT';
  MODE_INOUT constant varchar2(5) := 'INOUT';

  AFLOG_ENABLED constant varchar2(13) := 'AFLOG_ENABLED';
  AFLOG_FILENAME constant varchar2(14) := 'AFLOG_FILENAME';
  AFLOG_LEVEL constant varchar2(11) := 'AFLOG_LEVEL';
  AFLOG_MODULE constant varchar2(12) := 'AFLOG_MODULE';
  APPLICATION_NAME constant varchar2(16) := 'APPLICATION_NAME';
  APPLICATION_SHORT_NAME constant varchar2(22) := 'APPLICATION_SHORT_NAME';
  BASE_LANGUAGE constant varchar2(13) := 'BASE_LANGUAGE';
  CONC_LOGIN_ID constant varchar2(13) := 'CONC_LOGIN_ID';
  CONC_PRIORITY_REQUEST constant varchar2(21) := 'CONC_PRIORITY_REQUEST';
  CONC_PROCESS_ID constant varchar2(15) := 'CONC_PROCESS_ID';
  CONC_PROGRAM_ID constant varchar2(15) := 'CONC_PROGRAM_ID';
  CONC_QUEUE_ID constant varchar2(13) := 'CONC_QUEUE_ID';
  CONC_REQUEST_ID constant varchar2(15) := 'CONC_REQUEST_ID';
  CURRENT_LANGUAGE constant varchar2(16) := 'CURRENT_LANGUAGE';
  CUSTOMER_ID constant varchar2(11) := 'CUSTOMER_ID';
  EMPLOYEE_ID constant varchar2(11) := 'EMPLOYEE_ID';
  FND constant varchar2(3) := 'FND';
  FND_INIT_SQL constant varchar2(12) := 'FND_INIT_SQL';
  FORM_APPL_ID constant varchar2(12) := 'FORM_APPL_ID';
  FORM_ID constant varchar2(7) := 'FORM_ID';
  ICX_LANGUAGE constant varchar2(12) := 'ICX_LANGUAGE';
  ICX_SESSION_ID constant varchar2(14) := 'ICX_SESSION_ID';
  LANGUAGE_COUNT constant varchar2(14) := 'LANGUAGE_COUNT';
  LOGIN_ID constant varchar2(8) := 'LOGIN_ID';
  NLS_CHARACTERSET constant varchar2(16) := 'NLS_CHARACTERSET';
  NLS_DATE_FORMAT constant varchar2(15) := 'NLS_DATE_FORMAT';
  NLS_DATE_LANGUAGE constant varchar2(17) := 'NLS_DATE_LANGUAGE';
  NLS_LANGUAGE constant varchar2(12) := 'NLS_LANGUAGE';
  NLS_NUMERIC_CHARACTERS constant varchar2(22) := 'NLS_NUMERIC_CHARACTERS';
  NLS_SORT constant varchar2(8) := 'NLS_SORT';
  NLS_TERRITORY constant varchar2(13) := 'NLS_TERRITORY';
  ORG_ID constant varchar2(6) := 'ORG_ID';
  ORG_NAME constant varchar2(8) := 'ORG_NAME';
  PARTY_ID constant varchar2(8) := 'PARTY_ID';
  PER_BUSINESS_GROUP_ID constant varchar2(21) := 'PER_BUSINESS_GROUP_ID';
  PER_SECURITY_PROFILE_ID constant varchar2(23) := 'PER_SECURITY_PROFILE_ID';
  PRODUCT_CODE constant varchar2(12) := 'PRODUCT_CODE';
  PROG_APPL_ID constant varchar2(12) := 'PROG_APPL_ID';
  QUEUE_APPL_ID constant varchar2(13) := 'QUEUE_APPL_ID';
  RESP_APPL_ID constant varchar2(12) := 'RESP_APPL_ID';
  RESP_ID constant varchar2(7) := 'RESP_ID';
  RESP_NAME constant varchar2(9) := 'RESP_NAME';
  RT_TEST_ID constant varchar2(10) := 'RT_TEST_ID';
  SECURITY_GROUP_ID constant varchar2(17) := 'SECURITY_GROUP_ID';
  SECURITY_GROUP_ID_POLICY constant varchar2(24) := 'SECURITY_GROUP_ID_POLICY';
  SERVER_ID constant varchar2(9) := 'SERVER_ID';
  SESSION_ID constant varchar2(10) := 'SESSION_ID';
  SITE_ID constant varchar2(7) := 'SITE_ID';
  SUPPLIER_ID constant varchar2(11) := 'SUPPLIER_ID';
  USER_ID constant varchar2(7) := 'USER_ID';
  USER_NAME constant varchar2(9) := 'USER_NAME';

  pragma restrict_references (local_chr, WNDS, WNPS, RNPS);
  pragma restrict_references (NEWLINE, WNDS, WNPS, RNPS);
  pragma restrict_references (TAB, WNDS, WNPS, RNPS);
  pragma restrict_references (BOOL, WNDS, WNPS, RNDS, RNPS);

  pragma restrict_references (FND_CONST, WNDS, WNPS, RNDS, RNPS, TRUST);

end fnd_const;

/

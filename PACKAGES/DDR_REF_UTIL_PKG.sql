--------------------------------------------------------
--  DDL for Package DDR_REF_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."DDR_REF_UTIL_PKG" AUTHID CURRENT_USER AS
/* $Header: ddrurefs.pls 120.0.12010000.4 2010/04/27 00:39:04 gglover ship $ */
  FUNCTION GET_ERR_MSG (p_err_no VARCHAR2 DEFAULT NULL) RETURN VARCHAR2;
  PROCEDURE TRUNC_INTERFACE (p_table_parameters IN VARCHAR2 DEFAULT NULL);
  FUNCTION CHECK_MFG_ITEM_HCHY (p_hchy_cd VARCHAR2, p_hchy_level VARCHAR2) RETURN VARCHAR2;
  FUNCTION CHECK_ORG_HCHY (p_hchy_cd VARCHAR2, p_hchy_level VARCHAR2, p_org_cd VARCHAR2) RETURN VARCHAR2;
  FUNCTION CHECK_RTL_ITEM_HCHY (p_hchy_cd VARCHAR2, p_hchy_level VARCHAR2) RETURN VARCHAR2;
  FUNCTION CHECK_TIME_HCHY (p_hchy_cd VARCHAR2, p_hchy_level VARCHAR2) RETURN VARCHAR2;
  FUNCTION get_ref_map_run_id(p_audit_id VARCHAR2) RETURN NUMBER;
  PROCEDURE parse_pad_accounts(p_max_level IN NUMBER DEFAULT 10);
  c_audit_id NUMBER := NULL;
  c_map_id NUMBER := NULL;
  TYPE account_array IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
END ddr_ref_util_pkg;

/

--------------------------------------------------------
--  DDL for Package DDR_BASE_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."DDR_BASE_UTIL_PKG" AUTHID CURRENT_USER AS
/* $Header: ddrubass.pls 120.0.12010000.3 2010/03/03 04:21:05 vbhave ship $ */
  FUNCTION rtl_inv_item_dups_fnc(p_load_id IN NUMBER DEFAULT NULL) RETURN VARCHAR2;
  FUNCTION rtl_inv_item_dups_s_fnc(p_load_id IN NUMBER DEFAULT NULL) RETURN VARCHAR2;
  FUNCTION prmtn_pln_dups_fnc(p_load_id IN NUMBER DEFAULT NULL) RETURN VARCHAR2;
  FUNCTION prmtn_pln_dups_s_fnc(p_load_id IN NUMBER DEFAULT NULL) RETURN VARCHAR2;
  FUNCTION rtl_ordr_item_dups_fnc(p_load_id IN NUMBER DEFAULT NULL) RETURN VARCHAR2;
  FUNCTION rtl_ordr_item_dups_s_fnc(p_load_id IN NUMBER DEFAULT NULL) RETURN VARCHAR2;
  FUNCTION rtl_ship_item_dups_fnc(p_load_id IN NUMBER DEFAULT NULL) RETURN VARCHAR2;
  FUNCTION rtl_ship_item_dups_s_fnc(p_load_id IN NUMBER DEFAULT NULL) RETURN VARCHAR2;
  FUNCTION rtl_sl_rtn_dups_fnc(p_load_id IN NUMBER  DEFAULT NULL) RETURN VARCHAR2;
  FUNCTION rtl_sl_rtn_dups_s_fnc(p_load_id IN NUMBER DEFAULT NULL) RETURN VARCHAR2;
  FUNCTION sls_frcst_item_dups_fnc(p_load_id IN NUMBER DEFAULT NULL) RETURN VARCHAR2;
  FUNCTION sls_frcst_item_dups_s_fnc(p_load_id IN NUMBER DEFAULT NULL) RETURN VARCHAR2;
  FUNCTION synd_cnsmptn_data_dups_fnc(p_load_id IN NUMBER DEFAULT NULL) RETURN VARCHAR2;
  FUNCTION synd_cnsmptn_data_dups_s_fnc(p_load_id IN NUMBER DEFAULT NULL) RETURN VARCHAR2;
  FUNCTION mfg_ship_item_dups_fnc(p_load_id IN NUMBER DEFAULT NULL) RETURN VARCHAR2;
  FUNCTION mfg_ship_item_dups_s_fnc(p_load_id IN NUMBER DEFAULT NULL) RETURN VARCHAR2;
  FUNCTION decide_dedup_chk RETURN VARCHAR2;
  FUNCTION decide_discover_mode RETURN VARCHAR2;
  FUNCTION decide_run_map_err(map_nm IN VARCHAR2, map_stg IN VARCHAR2) RETURN NUMBER;
  FUNCTION decide_run_typ RETURN VARCHAR2;
  FUNCTION decide_sf_map RETURN VARCHAR2;
  FUNCTION decide_run_cnt_stg(map_nm IN VARCHAR2) RETURN NUMBER;
  FUNCTION decide_run_map(map_nm IN VARCHAR2) RETURN NUMBER;
  PROCEDURE trunc_tble_pub( p_tbl_name IN VARCHAR2);

  FUNCTION get_load_id(p_run_id IN NUMBER) RETURN NUMBER;
  FUNCTION get_map_run_id(p_audit_id VARCHAR2) RETURN NUMBER;
  c_audit_id NUMBER := NULL;
  c_map_id NUMBER := NULL;
END ddr_base_util_pkg;

/

--------------------------------------------------------
--  DDL for Package GCS_DRILLDOWN_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GCS_DRILLDOWN_UTIL_PKG" AUTHID CURRENT_USER AS
/* $Header: gcs_drill_utils.pls 120.2 2007/04/18 01:29:16 mikeward ship $ */

  FUNCTION get_currency_code
    (p_hierarchy_id               NUMBER,
     p_entity_id                  NUMBER)
  RETURN VARCHAR2;

  FUNCTION get_ledger_id
    (p_entity_id                  NUMBER)
  RETURN NUMBER;

  FUNCTION get_ledger_id
    (p_entity_id                  NUMBER,
     p_cal_period_id_str          VARCHAR2)
  RETURN NUMBER;

  FUNCTION get_src_sys_code
    (p_entity_id                  NUMBER)
  RETURN NUMBER;

  FUNCTION get_src_sys_code
    (p_entity_id                  NUMBER,
     p_cal_period_id_str          NUMBER)
  RETURN NUMBER;

  FUNCTION get_dataset_code
    (p_entity_id                  NUMBER,
     p_pristine_cal_period_id_str VARCHAR2)
  RETURN NUMBER;

  FUNCTION get_pristine_cal_period_id
    (p_entity_id                  NUMBER,
     p_fch_cal_period_id_str      VARCHAR2)
  RETURN VARCHAR2;

  FUNCTION url_encode
    (p_string_to_encode           VARCHAR2)
  RETURN VARCHAR2;

END GCS_DRILLDOWN_UTIL_PKG;

/

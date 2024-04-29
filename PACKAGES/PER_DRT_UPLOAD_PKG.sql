--------------------------------------------------------
--  DDL for Package PER_DRT_UPLOAD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_DRT_UPLOAD_PKG" AUTHID CURRENT_USER as
/* $Header: perdrtup.pkh 120.0.12010000.2 2018/06/18 10:18:34 ktithy noship $ */

procedure LOAD_ROW_DRTT (
  X_PRODUCT_CODE in VARCHAR2,
	X_SCHEMA in VARCHAR2,
  X_TABLE_NAME in VARCHAR2,
  X_TABLE_PHASE in VARCHAR2,
  X_RECORD_IDENTIFIER in VARCHAR2,
  X_ENTITY_TYPE in VARCHAR2,
  X_OWNER in VARCHAR2,
  X_LAST_UPDATE_DATE in VARCHAR2 default to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS'));

procedure LOAD_ROW_DRTC (
  X_TABLE_NAME in VARCHAR2,
  X_TABLE_PHASE in VARCHAR2,
  X_RECORD_IDENTIFIER in VARCHAR2,
  X_COLUMN_NAME in VARCHAR2,
  X_COLUMN_PHASE in VARCHAR2 default null,
  X_ATTRIBUTE in VARCHAR2 default null,
  X_FF_TYPE in VARCHAR2,
  X_RULE_TYPE in VARCHAR2 default null,
  X_PARAMETER_1 in VARCHAR2 default null,
  X_PARAMETER_2 in VARCHAR2 default null,
  X_COMMENTS in VARCHAR2 default null,
  X_OWNER in VARCHAR2,
  X_LAST_UPDATE_DATE_C in VARCHAR2 default to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS'));

procedure LOAD_ROW_DRTCC (
  X_TABLE_NAME in VARCHAR2,
  X_TABLE_PHASE in VARCHAR2,
  X_RECORD_IDENTIFIER in VARCHAR2,
  X_COLUMN_NAME_C in VARCHAR2 default null,
  X_FF_NAME in VARCHAR2,
  X_CONTEXT_NAME in VARCHAR2,
  X_COLUMN_NAME in VARCHAR2 default null,
  X_COLUMN_PHASE in VARCHAR2 default null,
  X_ATTRIBUTE in VARCHAR2 default null,
  X_RULE_TYPE in VARCHAR2 default null,
  X_PARAMETER_1 in VARCHAR2 default null,
  X_PARAMETER_2 in VARCHAR2 default null,
  X_COMMENTS in VARCHAR2 default null,
  X_OWNER in VARCHAR2,
  X_LAST_UPDATE_DATE_F in VARCHAR2 default to_char(sysdate, 'YYYY/MM/DD HH24:MI:SS'));

end per_drt_upload_pkg;

/

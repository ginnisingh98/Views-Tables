--------------------------------------------------------
--  DDL for Package ZX_DET_FACTOR_TEMPL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZX_DET_FACTOR_TEMPL_PKG" AUTHID CURRENT_USER as
/* $Header: zxddetfactors.pls 120.4 2005/03/14 10:25:15 scsharma ship $ */

procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_DET_FACTOR_TEMPL_ID in NUMBER,
  X_DET_FACTOR_TEMPL_CODE in VARCHAR2,
  X_TAX_REGIME_CODE in VARCHAR2,
  X_LEDGER_ID in NUMBER,
  X_CHART_OF_ACCOUNTS_ID in NUMBER,
  X_Template_Usage_Code in VARCHAR2,
  X_Record_Type_Code in VARCHAR2,
  X_REQUEST_ID in NUMBER,
  X_DET_FACTOR_TEMPL_NAME in VARCHAR2,
  X_DET_FACTOR_TEMPL_DESC in VARCHAR2,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_PROGRAM_APPLICATION_ID in NUMBER,
  X_PROGRAM_ID in NUMBER,
  X_PROGRAM_LOGIN_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER);

procedure LOCK_ROW (
  X_DET_FACTOR_TEMPL_ID in NUMBER,
  X_DET_FACTOR_TEMPL_CODE in VARCHAR2,
  X_TAX_REGIME_CODE in VARCHAR2,
  X_LEDGER_ID in NUMBER,
  X_CHART_OF_ACCOUNTS_ID in NUMBER,
  X_Template_Usage_Code in VARCHAR2,
  X_Record_Type_Code in VARCHAR2,
  X_REQUEST_ID in NUMBER,
  X_PROGRAM_APPLICATION_ID in NUMBER,
  X_PROGRAM_ID in NUMBER,
  X_PROGRAM_LOGIN_ID in NUMBER,
  X_DET_FACTOR_TEMPL_NAME in VARCHAR2,
  X_DET_FACTOR_TEMPL_DESC in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER);

procedure UPDATE_ROW (
  X_DET_FACTOR_TEMPL_ID in NUMBER,
  X_DET_FACTOR_TEMPL_CODE in VARCHAR2,
  X_TAX_REGIME_CODE in VARCHAR2,
  X_LEDGER_ID in NUMBER,
  X_CHART_OF_ACCOUNTS_ID in NUMBER,
  X_Template_Usage_Code in VARCHAR2,
  X_Record_Type_Code in VARCHAR2,
  X_REQUEST_ID in NUMBER,
  X_DET_FACTOR_TEMPL_NAME in VARCHAR2,
  X_DET_FACTOR_TEMPL_DESC in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_PROGRAM_APPLICATION_ID in NUMBER,
  X_PROGRAM_ID in NUMBER,
  X_PROGRAM_LOGIN_ID in NUMBER,
  X_OBJECT_VERSION_NUMBER in NUMBER);

procedure DELETE_ROW (
  X_DET_FACTOR_TEMPL_ID in NUMBER);

procedure ADD_LANGUAGE;

TYPE T_DET_FACTOR_TEMPL_ID
                  is TABLE of zx_det_factor_templ_b.det_factor_templ_id%type
                     index by binary_integer;
TYPE T_DET_FACTOR_TEMPL_CODE
                  is TABLE of zx_det_factor_templ_b.det_factor_templ_code%type
                     index by binary_integer;
TYPE T_TAX_REGIME_CODE is TABLE of zx_det_factor_templ_b.tax_regime_code%type
                          index by binary_integer;
TYPE T_LEDGER_ID is TABLE of zx_det_factor_templ_b.ledger_id%type
                    index by binary_integer;
TYPE T_CHART_OF_ACCOUNTS_ID
                  is TABLE of zx_det_factor_templ_b.chart_of_accounts_id%type
                     index by binary_integer;
TYPE T_TEMPLATE_USAGE is TABLE of zx_det_factor_templ_b.Template_Usage_Code%type
                         index by binary_integer;
TYPE T_RECORD_TYPE is TABLE of zx_det_factor_templ_b.Record_Type_Code%type
                      index by binary_integer;
TYPE T_DET_FACTOR_TEMPL_NAME
                  is TABLE of zx_det_factor_templ_tl.det_factor_templ_name%type
                     index by binary_integer;
TYPE T_DET_FACTOR_TEMPL_DESC
                  is TABLE of zx_det_factor_templ_tl.det_factor_templ_desc%type
                     index by binary_integer;

procedure bulk_insert_det_factor_templ (
  X_DET_FACTOR_TEMPL_ID       IN t_det_factor_templ_id,
  X_DET_FACTOR_TEMPL_CODE     IN t_det_factor_templ_code,
  X_TAX_REGIME_CODE           IN t_tax_regime_code,
  X_LEDGER_ID                 IN t_ledger_id,
  X_CHART_OF_ACCOUNTS_ID      IN t_chart_of_accounts_id,
  X_Template_Usage_Code            IN t_template_usage,
  X_Record_Type_Code               IN t_record_type,
  X_DET_FACTOR_TEMPL_NAME     IN t_det_factor_templ_name,
  X_DET_FACTOR_TEMPL_DESC     IN t_det_factor_templ_desc);

end ZX_DET_FACTOR_TEMPL_PKG;

 

/

--------------------------------------------------------
--  DDL for Package Body ZX_SIM_TRX_DISTRIBUTION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZX_SIM_TRX_DISTRIBUTION" AS
/* $Header: zxritsimitdistb.pls 120.16.12010000.1 2008/07/28 13:37:19 appldev ship $ */

  g_current_runtime_level NUMBER;
  g_level_statement       CONSTANT  NUMBER := FND_LOG.LEVEL_STATEMENT;
  g_level_procedure       CONSTANT  NUMBER := FND_LOG.LEVEL_PROCEDURE;
  g_level_event           CONSTANT  NUMBER := FND_LOG.LEVEL_EVENT;
  g_level_unexpected      CONSTANT  NUMBER := FND_LOG.LEVEL_UNEXPECTED;

  TYPE var1_tab IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
  trx_line_type_tab        var1_tab;

  PROCEDURE Insert_row
       (p_application_id               NUMBER,
        p_entity_code                  VARCHAR2,
        p_event_class_code             VARCHAR2,
        --p_event_type_code              VARCHAR2,
        p_trx_id                       NUMBER,
        p_hdr_trx_user_key1            VARCHAR2,
        p_hdr_trx_user_key2            VARCHAR2,
        p_hdr_trx_user_key3            VARCHAR2,
        p_hdr_trx_user_key4            VARCHAR2,
        p_hdr_trx_user_key5            VARCHAR2,
        p_hdr_trx_user_key6            VARCHAR2,
        p_trx_line_id                  NUMBER,
        p_line_trx_user_key1           VARCHAR2,
        p_line_trx_user_key2           VARCHAR2,
        p_line_trx_user_key3           VARCHAR2,
        p_line_trx_user_key4           VARCHAR2,
        p_line_trx_user_key5           VARCHAR2,
        p_line_trx_user_key6           VARCHAR2,
        p_trx_level_type               VARCHAR2,
        p_trx_line_dist_id             NUMBER,
        p_dist_trx_user_key1           VARCHAR2,
        p_dist_trx_user_key2           VARCHAR2,
        p_dist_trx_user_key3           VARCHAR2,
        p_dist_trx_user_key4           VARCHAR2,
        p_dist_trx_user_key5           VARCHAR2,
        p_dist_trx_user_key6           VARCHAR2,
        p_dist_level_action            VARCHAR2,
        p_trx_line_dist_date           DATE,
        p_item_dist_number             NUMBER,
        p_dist_intended_use            VARCHAR2,
        p_tax_inclusion_flag           VARCHAR2,
        p_tax_code                     VARCHAR2,
        p_applied_from_tax_dist_id     NUMBER,
        p_adjusted_doc_tax_dist_id     NUMBER,
        p_task_id                      NUMBER,
        p_award_id                     NUMBER,
        p_project_id                   NUMBER,
        p_expenditure_type             VARCHAR2,
        p_expenditure_organization_id  NUMBER,
        p_expenditure_item_date        DATE,
        p_trx_line_dist_amt            NUMBER,
        p_trx_line_dist_qty            NUMBER,
        p_trx_line_quantity            NUMBER,
        p_account_ccid                 NUMBER,
        p_account_string               VARCHAR2,
        p_ref_doc_application_id       NUMBER,
        p_ref_doc_entity_code          VARCHAR2,
        p_ref_doc_event_class_code     VARCHAR2,
        p_ref_doc_trx_id               NUMBER,
        p_ref_doc_hdr_trx_user_key1    VARCHAR2,
        p_ref_doc_hdr_trx_user_key2    VARCHAR2,
        p_ref_doc_hdr_trx_user_key3    VARCHAR2,
        p_ref_doc_hdr_trx_user_key4    VARCHAR2,
        p_ref_doc_hdr_trx_user_key5    VARCHAR2,
        p_ref_doc_hdr_trx_user_key6    VARCHAR2,
        p_ref_doc_line_id              NUMBER,
        p_ref_doc_lin_trx_user_key1    VARCHAR2,
        p_ref_doc_lin_trx_user_key2    VARCHAR2,
        p_ref_doc_lin_trx_user_key3    VARCHAR2,
        p_ref_doc_lin_trx_user_key4    VARCHAR2,
        p_ref_doc_lin_trx_user_key5    VARCHAR2,
        p_ref_doc_lin_trx_user_key6    VARCHAR2,
        p_ref_doc_dist_id              NUMBER,
        p_ref_doc_dist_trx_user_key1   VARCHAR2,
        p_ref_doc_dist_trx_user_key2   VARCHAR2,
        p_ref_doc_dist_trx_user_key3   VARCHAR2,
        p_ref_doc_dist_trx_user_key4   VARCHAR2,
        p_ref_doc_dist_trx_user_key5   VARCHAR2,
        p_ref_doc_dist_trx_user_key6   VARCHAR2,
        p_ref_doc_curr_conv_rate       NUMBER,
        p_numeric1                     NUMBER,
        p_numeric2                     NUMBER,
        p_numeric3                     NUMBER,
        p_numeric4                     NUMBER,
        p_numeric5                     NUMBER,
        p_char1                        VARCHAR2,
        p_char2                        VARCHAR2,
        p_char3                        VARCHAR2,
        p_char4                        VARCHAR2,
        p_char5                        VARCHAR2,
        p_date1                        DATE,
        p_date2                        DATE,
        p_date3                        DATE,
        p_date4                        DATE,
        p_date5                        DATE,
        p_trx_line_dist_tax_amt        NUMBER,
        p_historical_flag              VARCHAR2,
        p_applied_from_application_id  NUMBER,
        p_appl_from_event_class_code   VARCHAR2, --p_applied_from_event_class_code
        p_applied_from_entity_code     VARCHAR2,
        p_applied_from_trx_id          NUMBER,
        p_app_from_hdr_trx_user_key1   VARCHAR2,
        p_app_from_hdr_trx_user_key2   VARCHAR2,
        p_app_from_hdr_trx_user_key3   VARCHAR2,
        p_app_from_hdr_trx_user_key4   VARCHAR2,
        p_app_from_hdr_trx_user_key5   VARCHAR2,
        p_app_from_hdr_trx_user_key6   VARCHAR2,
        p_applied_from_line_id         NUMBER,
        p_app_from_lin_trx_user_key1   VARCHAR2,
        p_app_from_lin_trx_user_key2   VARCHAR2,
        p_app_from_lin_trx_user_key3   VARCHAR2,
        p_app_from_lin_trx_user_key4   VARCHAR2,
        p_app_from_lin_trx_user_key5   VARCHAR2,
        p_app_from_lin_trx_user_key6   VARCHAR2,
        p_applied_from_dist_id         NUMBER,
        p_app_from_dst_trx_user_key1   VARCHAR2,
        p_app_from_dst_trx_user_key2   VARCHAR2,
        p_app_from_dst_trx_user_key3   VARCHAR2,
        p_app_from_dst_trx_user_key4   VARCHAR2,
        p_app_from_dst_trx_user_key5   VARCHAR2,
        p_app_from_dst_trx_user_key6   VARCHAR2,
        p_adj_doc_application_id       NUMBER,   --p_adjusted_doc_application_id
        p_adj_doc_event_class_code     VARCHAR2, --p_adjusted_doc_event_class_code
        p_adjusted_doc_entity_code     VARCHAR2,
        p_adjusted_doc_trx_id          NUMBER,
        p_adj_doc_hdr_trx_user_key1    VARCHAR2,
        p_adj_doc_hdr_trx_user_key2    VARCHAR2,
        p_adj_doc_hdr_trx_user_key3    VARCHAR2,
        p_adj_doc_hdr_trx_user_key4    VARCHAR2,
        p_adj_doc_hdr_trx_user_key5    VARCHAR2,
        p_adj_doc_hdr_trx_user_key6    VARCHAR2,
        p_adjusted_doc_line_id         NUMBER,
        p_adj_doc_lin_trx_user_key1    VARCHAR2,
        p_adj_doc_lin_trx_user_key2    VARCHAR2,
        p_adj_doc_lin_trx_user_key3    VARCHAR2,
        p_adj_doc_lin_trx_user_key4    VARCHAR2,
        p_adj_doc_lin_trx_user_key5    VARCHAR2,
        p_adj_doc_lin_trx_user_key6    VARCHAR2,
        p_adjusted_doc_dist_id         NUMBER,
        p_adj_doc_dst_trx_user_key1    VARCHAR2,
        p_adj_doc_dst_trx_user_key2    VARCHAR2,
        p_adj_doc_dst_trx_user_key3    VARCHAR2,
        p_adj_doc_dst_trx_user_key4    VARCHAR2,
        p_adj_doc_dst_trx_user_key5    VARCHAR2,
        p_adj_doc_dst_trx_user_key6    VARCHAR2,
        p_appl_to_doc_curr_conv_rate   NUMBER, --p_applied_to_doc_curr_conv_rate
        p_tax_variance_calc_flag       VARCHAR2,
        p_ref_doc_trx_line_dist_qty    NUMBER,
        p_price_diff                   NUMBER,
        p_unit_price                   NUMBER,
        p_currency_exchange_rate       NUMBER,
        p_ref_doc_trx_level_type       VARCHAR2,
        p_applied_from_trx_level_type  VARCHAR2,
        p_adjusted_doc_trx_level_type  VARCHAR2,
        p_overriding_recovery_rate     NUMBER,
        p_object_version_number        NUMBER,
        p_created_by                   NUMBER,
        p_creation_date                DATE,
        p_last_updated_by              NUMBER,
        p_last_update_date             DATE,
        p_last_update_login            NUMBER) IS

    l_return_status        VARCHAR2(1000);
    l_msg_count            NUMBER;
    l_msg_data             VARCHAR2(1000);
    sid                    NUMBER;
    p_error_buffer         VARCHAR2(100);
    l_tax_event_type_code  VARCHAR2(30);

  BEGIN

    g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_SIM_TRX_DISTRIBUTION.Insert_Row.BEGIN',
                     'ZX_SIM_TRX_DISTRIBUTION: Insert_Row (+)');
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_SIM_TRX_DISTRIBUTION.Insert_Row',
                     'Insert into ZX_SIM_TRX_DISTS (+)');
    END IF;

    INSERT INTO ZX_SIM_TRX_DISTS (APPLICATION_ID,
                                 ENTITY_CODE,
                                 EVENT_CLASS_CODE,
                                 --EVENT_TYPE_CODE,
                                 TRX_ID,
                                 HDR_TRX_USER_KEY1,
                                 HDR_TRX_USER_KEY2,
                                 HDR_TRX_USER_KEY3,
                                 HDR_TRX_USER_KEY4,
                                 HDR_TRX_USER_KEY5,
                                 HDR_TRX_USER_KEY6,
                                 TRX_LINE_ID,
                                 LINE_TRX_USER_KEY1,
                                 LINE_TRX_USER_KEY2,
                                 LINE_TRX_USER_KEY3,
                                 LINE_TRX_USER_KEY4,
                                 LINE_TRX_USER_KEY5,
                                 LINE_TRX_USER_KEY6,
                                 TRX_LEVEL_TYPE,
                                 TRX_LINE_DIST_ID,
                                 DIST_TRX_USER_KEY1,
                                 DIST_TRX_USER_KEY2,
                                 DIST_TRX_USER_KEY3,
                                 DIST_TRX_USER_KEY4,
                                 DIST_TRX_USER_KEY5,
                                 DIST_TRX_USER_KEY6,
                                 DIST_LEVEL_ACTION,
                                 TRX_LINE_DIST_DATE,
                                 ITEM_DIST_NUMBER,
                                 DIST_INTENDED_USE,
                                 TAX_INCLUSION_FLAG,
                                 TAX_CODE,
                                 APPLIED_FROM_TAX_DIST_ID,
                                 ADJUSTED_DOC_TAX_DIST_ID,
                                 TASK_ID,
                                 AWARD_ID,
                                 PROJECT_ID,
                                 EXPENDITURE_TYPE,
                                 EXPENDITURE_ORGANIZATION_ID,
                                 EXPENDITURE_ITEM_DATE,
                                 TRX_LINE_DIST_AMT,
                                 TRX_LINE_DIST_QTY,
                                 TRX_LINE_QUANTITY,
                                 ACCOUNT_CCID,
                                 ACCOUNT_STRING,
                                 REF_DOC_APPLICATION_ID,
                                 REF_DOC_ENTITY_CODE,
                                 REF_DOC_EVENT_CLASS_CODE,
                                 REF_DOC_TRX_ID,
                                 REF_DOC_HDR_TRX_USER_KEY1,
                                 REF_DOC_HDR_TRX_USER_KEY2,
                                 REF_DOC_HDR_TRX_USER_KEY3,
                                 REF_DOC_HDR_TRX_USER_KEY4,
                                 REF_DOC_HDR_TRX_USER_KEY5,
                                 REF_DOC_HDR_TRX_USER_KEY6,
                                 REF_DOC_LINE_ID,
                                 REF_DOC_LIN_TRX_USER_KEY1,
                                 REF_DOC_LIN_TRX_USER_KEY2,
                                 REF_DOC_LIN_TRX_USER_KEY3,
                                 REF_DOC_LIN_TRX_USER_KEY4,
                                 REF_DOC_LIN_TRX_USER_KEY5,
                                 REF_DOC_LIN_TRX_USER_KEY6,
                                 REF_DOC_DIST_ID,
                                 REF_DOC_DIST_TRX_USER_KEY1,
                                 REF_DOC_DIST_TRX_USER_KEY2,
                                 REF_DOC_DIST_TRX_USER_KEY3,
                                 REF_DOC_DIST_TRX_USER_KEY4,
                                 REF_DOC_DIST_TRX_USER_KEY5,
                                 REF_DOC_DIST_TRX_USER_KEY6,
                                 REF_DOC_CURR_CONV_RATE,
                                 NUMERIC1,
                                 NUMERIC2,
                                 NUMERIC3,
                                 NUMERIC4,
                                 NUMERIC5,
                                 CHAR1,
                                 CHAR2,
                                 CHAR3,
                                 CHAR4,
                                 CHAR5,
                                 DATE1,
                                 DATE2,
                                 DATE3,
                                 DATE4,
                                 DATE5,
                                 TRX_LINE_DIST_TAX_AMT,
                                 HISTORICAL_FLAG,
                                 APPLIED_FROM_APPLICATION_ID,
                                 APPLIED_FROM_EVENT_CLASS_CODE,
                                 APPLIED_FROM_ENTITY_CODE,
                                 APPLIED_FROM_TRX_ID,
                                 APP_FROM_HDR_TRX_USER_KEY1,
                                 APP_FROM_HDR_TRX_USER_KEY2,
                                 APP_FROM_HDR_TRX_USER_KEY3,
                                 APP_FROM_HDR_TRX_USER_KEY4,
                                 APP_FROM_HDR_TRX_USER_KEY5,
                                 APP_FROM_HDR_TRX_USER_KEY6,
                                 APPLIED_FROM_LINE_ID,
                                 APP_FROM_LIN_TRX_USER_KEY1,
                                 APP_FROM_LIN_TRX_USER_KEY2,
                                 APP_FROM_LIN_TRX_USER_KEY3,
                                 APP_FROM_LIN_TRX_USER_KEY4,
                                 APP_FROM_LIN_TRX_USER_KEY5,
                                 APP_FROM_LIN_TRX_USER_KEY6,
                                 APPLIED_FROM_DIST_ID,
                                 APP_FROM_DST_TRX_USER_KEY1,
                                 APP_FROM_DST_TRX_USER_KEY2,
                                 APP_FROM_DST_TRX_USER_KEY3,
                                 APP_FROM_DST_TRX_USER_KEY4,
                                 APP_FROM_DST_TRX_USER_KEY5,
                                 APP_FROM_DST_TRX_USER_KEY6,
                                 ADJUSTED_DOC_APPLICATION_ID,
                                 ADJUSTED_DOC_EVENT_CLASS_CODE,
                                 ADJUSTED_DOC_ENTITY_CODE,
                                 ADJUSTED_DOC_TRX_ID,
                                 ADJ_DOC_HDR_TRX_USER_KEY1,
                                 ADJ_DOC_HDR_TRX_USER_KEY2,
                                 ADJ_DOC_HDR_TRX_USER_KEY3,
                                 ADJ_DOC_HDR_TRX_USER_KEY4,
                                 ADJ_DOC_HDR_TRX_USER_KEY5,
                                 ADJ_DOC_HDR_TRX_USER_KEY6,
                                 ADJUSTED_DOC_LINE_ID,
                                 ADJ_DOC_LIN_TRX_USER_KEY1,
                                 ADJ_DOC_LIN_TRX_USER_KEY2,
                                 ADJ_DOC_LIN_TRX_USER_KEY3,
                                 ADJ_DOC_LIN_TRX_USER_KEY4,
                                 ADJ_DOC_LIN_TRX_USER_KEY5,
                                 ADJ_DOC_LIN_TRX_USER_KEY6,
                                 ADJUSTED_DOC_DIST_ID,
                                 ADJ_DOC_DST_TRX_USER_KEY1,
                                 ADJ_DOC_DST_TRX_USER_KEY2,
                                 ADJ_DOC_DST_TRX_USER_KEY3,
                                 ADJ_DOC_DST_TRX_USER_KEY4,
                                 ADJ_DOC_DST_TRX_USER_KEY5,
                                 ADJ_DOC_DST_TRX_USER_KEY6,
                                 APPLIED_TO_DOC_CURR_CONV_RATE,
                                 TAX_VARIANCE_CALC_FLAG,
                                 REF_DOC_TRX_LINE_DIST_QTY,
                                 PRICE_DIFF,
                                 UNIT_PRICE,
                                 CURRENCY_EXCHANGE_RATE,
                                 REF_DOC_TRX_LEVEL_TYPE,
                                 APPLIED_FROM_TRX_LEVEL_TYPE,
                                 ADJUSTED_DOC_TRX_LEVEL_TYPE,
                                 OVERRIDING_RECOVERY_RATE,
                                 OBJECT_VERSION_NUMBER,
                                 CREATED_BY,
                                 CREATION_DATE,
                                 LAST_UPDATED_BY,
                                 LAST_UPDATE_DATE,
                                 LAST_UPDATE_LOGIN)
                         VALUES (p_application_id,
                                 p_entity_code,
                                 p_event_class_code,
                                 --p_event_type_code,
                                 p_trx_id,
                                 p_hdr_trx_user_key1,
                                 p_hdr_trx_user_key2,
                                 p_hdr_trx_user_key3,
                                 p_hdr_trx_user_key4,
                                 p_hdr_trx_user_key5,
                                 p_hdr_trx_user_key6,
                                 p_trx_line_id,
                                 p_line_trx_user_key1,
                                 p_line_trx_user_key2,
                                 p_line_trx_user_key3,
                                 p_line_trx_user_key4,
                                 p_line_trx_user_key5,
                                 p_line_trx_user_key6,
                                 p_trx_level_type,
                                 p_trx_line_dist_id,
                                 p_dist_trx_user_key1,
                                 p_dist_trx_user_key2,
                                 p_dist_trx_user_key3,
                                 p_dist_trx_user_key4,
                                 p_dist_trx_user_key5,
                                 p_dist_trx_user_key6,
                                 p_dist_level_action,
                                 p_trx_line_dist_date,
                                 p_item_dist_number,
                                 p_dist_intended_use,
                                 p_tax_inclusion_flag,
                                 p_tax_code,
                                 p_applied_from_tax_dist_id,
                                 p_adjusted_doc_tax_dist_id,
                                 p_task_id,
                                 p_award_id,
                                 p_project_id,
                                 p_expenditure_type,
                                 p_expenditure_organization_id,
                                 p_expenditure_item_date,
                                 p_trx_line_dist_amt,
                                 p_trx_line_dist_qty,
                                 p_trx_line_quantity,
                                 p_account_ccid,
                                 p_account_string,
                                 p_ref_doc_application_id,
                                 p_ref_doc_entity_code,
                                 p_ref_doc_event_class_code,
                                 p_ref_doc_trx_id,
                                 p_ref_doc_hdr_trx_user_key1,
                                 p_ref_doc_hdr_trx_user_key2,
                                 p_ref_doc_hdr_trx_user_key3,
                                 p_ref_doc_hdr_trx_user_key4,
                                 p_ref_doc_hdr_trx_user_key5,
                                 p_ref_doc_hdr_trx_user_key6,
                                 p_ref_doc_line_id,
                                 p_ref_doc_lin_trx_user_key1,
                                 p_ref_doc_lin_trx_user_key2,
                                 p_ref_doc_lin_trx_user_key3,
                                 p_ref_doc_lin_trx_user_key4,
                                 p_ref_doc_lin_trx_user_key5,
                                 p_ref_doc_lin_trx_user_key6,
                                 p_ref_doc_dist_id,
                                 p_ref_doc_dist_trx_user_key1,
                                 p_ref_doc_dist_trx_user_key2,
                                 p_ref_doc_dist_trx_user_key3,
                                 p_ref_doc_dist_trx_user_key4,
                                 p_ref_doc_dist_trx_user_key5,
                                 p_ref_doc_dist_trx_user_key6,
                                 p_ref_doc_curr_conv_rate,
                                 p_numeric1,
                                 p_numeric2,
                                 p_numeric3,
                                 p_numeric4,
                                 p_numeric5,
                                 p_char1,
                                 p_char2,
                                 p_char3,
                                 p_char4,
                                 p_char5,
                                 p_date1,
                                 p_date2,
                                 p_date3,
                                 p_date4,
                                 p_date5,
                                 p_trx_line_dist_tax_amt,
                                 p_historical_flag,
                                 p_applied_from_application_id,
                                 p_appl_from_event_class_code,
                                 p_applied_from_entity_code,
                                 p_applied_from_trx_id,
                                 p_app_from_hdr_trx_user_key1,
                                 p_app_from_hdr_trx_user_key2,
                                 p_app_from_hdr_trx_user_key3,
                                 p_app_from_hdr_trx_user_key4,
                                 p_app_from_hdr_trx_user_key5,
                                 p_app_from_hdr_trx_user_key6,
                                 p_applied_from_line_id,
                                 p_app_from_lin_trx_user_key1,
                                 p_app_from_lin_trx_user_key2,
                                 p_app_from_lin_trx_user_key3,
                                 p_app_from_lin_trx_user_key4,
                                 p_app_from_lin_trx_user_key5,
                                 p_app_from_lin_trx_user_key6,
                                 p_applied_from_dist_id,
                                 p_app_from_dst_trx_user_key1,
                                 p_app_from_dst_trx_user_key2,
                                 p_app_from_dst_trx_user_key3,
                                 p_app_from_dst_trx_user_key4,
                                 p_app_from_dst_trx_user_key5,
                                 p_app_from_dst_trx_user_key6,
                                 p_adj_doc_application_id,
                                 p_adj_doc_event_class_code,
                                 p_adjusted_doc_entity_code,
                                 p_adjusted_doc_trx_id,
                                 p_adj_doc_hdr_trx_user_key1,
                                 p_adj_doc_hdr_trx_user_key2,
                                 p_adj_doc_hdr_trx_user_key3,
                                 p_adj_doc_hdr_trx_user_key4,
                                 p_adj_doc_hdr_trx_user_key5,
                                 p_adj_doc_hdr_trx_user_key6,
                                 p_adjusted_doc_line_id,
                                 p_adj_doc_lin_trx_user_key1,
                                 p_adj_doc_lin_trx_user_key2,
                                 p_adj_doc_lin_trx_user_key3,
                                 p_adj_doc_lin_trx_user_key4,
                                 p_adj_doc_lin_trx_user_key5,
                                 p_adj_doc_lin_trx_user_key6,
                                 p_adjusted_doc_dist_id,
                                 p_adj_doc_dst_trx_user_key1,
                                 p_adj_doc_dst_trx_user_key2,
                                 p_adj_doc_dst_trx_user_key3,
                                 p_adj_doc_dst_trx_user_key4,
                                 p_adj_doc_dst_trx_user_key5,
                                 p_adj_doc_dst_trx_user_key6,
                                 p_appl_to_doc_curr_conv_rate,
                                 p_tax_variance_calc_flag,
                                 p_ref_doc_trx_line_dist_qty,
                                 p_price_diff,
                                 p_unit_price,
                                 p_currency_exchange_rate,
                                 p_ref_doc_trx_level_type,
                                 p_applied_from_trx_level_type,
                                 p_adjusted_doc_trx_level_type,
                                 p_overriding_recovery_rate,
                                 1,   --p_object_version_number,
                                 p_created_by,
                                 p_creation_date,
                                 p_last_updated_by,
                                 p_last_update_date,
                                 p_last_update_login);

      IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure,
                       'ZX.PLSQL.ZX_SIM_TRX_DISTRIBUTION.Insert_Row',
                       'Insert into ZX_SIM_TRX_DISTS (-)');
        FND_LOG.STRING(g_level_procedure,
                       'ZX.PLSQL.ZX_SIM_TRX_DISTRIBUTION.Insert_Row.END',
                       'ZX_SIM_TRX_DISTRIBUTION: Insert_Row (-)');
      END IF;

  END Insert_row;

  PROCEDURE Update_row
       (p_application_id               NUMBER,
        p_entity_code                  VARCHAR2,
        p_event_class_code             VARCHAR2,
        --p_event_type_code              VARCHAR2,
        p_trx_id                       NUMBER,
        p_hdr_trx_user_key1            VARCHAR2,
        p_hdr_trx_user_key2            VARCHAR2,
        p_hdr_trx_user_key3            VARCHAR2,
        p_hdr_trx_user_key4            VARCHAR2,
        p_hdr_trx_user_key5            VARCHAR2,
        p_hdr_trx_user_key6            VARCHAR2,
        p_trx_line_id                  NUMBER,
        p_line_trx_user_key1           VARCHAR2,
        p_line_trx_user_key2           VARCHAR2,
        p_line_trx_user_key3           VARCHAR2,
        p_line_trx_user_key4           VARCHAR2,
        p_line_trx_user_key5           VARCHAR2,
        p_line_trx_user_key6           VARCHAR2,
        p_trx_level_type               VARCHAR2,
        p_trx_line_dist_id             NUMBER,
        p_dist_trx_user_key1           VARCHAR2,
        p_dist_trx_user_key2           VARCHAR2,
        p_dist_trx_user_key3           VARCHAR2,
        p_dist_trx_user_key4           VARCHAR2,
        p_dist_trx_user_key5           VARCHAR2,
        p_dist_trx_user_key6           VARCHAR2,
        p_dist_level_action            VARCHAR2,
        p_trx_line_dist_date           DATE,
        p_item_dist_number             NUMBER,
        p_dist_intended_use            VARCHAR2,
        p_tax_inclusion_flag           VARCHAR2,
        p_tax_code                     VARCHAR2,
        p_applied_from_tax_dist_id     NUMBER,
        p_adjusted_doc_tax_dist_id     NUMBER,
        p_task_id                      NUMBER,
        p_award_id                     NUMBER,
        p_project_id                   NUMBER,
        p_expenditure_type             VARCHAR2,
        p_expenditure_organization_id  NUMBER,
        p_expenditure_item_date        DATE,
        p_trx_line_dist_amt            NUMBER,
        p_trx_line_dist_qty            NUMBER,
        p_trx_line_quantity            NUMBER,
        p_account_ccid                 NUMBER,
        p_account_string               VARCHAR2,
        p_ref_doc_application_id       NUMBER,
        p_ref_doc_entity_code          VARCHAR2,
        p_ref_doc_event_class_code     VARCHAR2,
        p_ref_doc_trx_id               NUMBER,
        p_ref_doc_hdr_trx_user_key1    VARCHAR2,
        p_ref_doc_hdr_trx_user_key2    VARCHAR2,
        p_ref_doc_hdr_trx_user_key3    VARCHAR2,
        p_ref_doc_hdr_trx_user_key4    VARCHAR2,
        p_ref_doc_hdr_trx_user_key5    VARCHAR2,
        p_ref_doc_hdr_trx_user_key6    VARCHAR2,
        p_ref_doc_line_id              NUMBER,
        p_ref_doc_lin_trx_user_key1    VARCHAR2,
        p_ref_doc_lin_trx_user_key2    VARCHAR2,
        p_ref_doc_lin_trx_user_key3    VARCHAR2,
        p_ref_doc_lin_trx_user_key4    VARCHAR2,
        p_ref_doc_lin_trx_user_key5    VARCHAR2,
        p_ref_doc_lin_trx_user_key6    VARCHAR2,
        p_ref_doc_dist_id              NUMBER,
        p_ref_doc_dist_trx_user_key1   VARCHAR2,
        p_ref_doc_dist_trx_user_key2   VARCHAR2,
        p_ref_doc_dist_trx_user_key3   VARCHAR2,
        p_ref_doc_dist_trx_user_key4   VARCHAR2,
        p_ref_doc_dist_trx_user_key5   VARCHAR2,
        p_ref_doc_dist_trx_user_key6   VARCHAR2,
        p_ref_doc_curr_conv_rate       NUMBER,
        p_numeric1                     NUMBER,
        p_numeric2                     NUMBER,
        p_numeric3                     NUMBER,
        p_numeric4                     NUMBER,
        p_numeric5                     NUMBER,
        p_char1                        VARCHAR2,
        p_char2                        VARCHAR2,
        p_char3                        VARCHAR2,
        p_char4                        VARCHAR2,
        p_char5                        VARCHAR2,
        p_date1                        DATE,
        p_date2                        DATE,
        p_date3                        DATE,
        p_date4                        DATE,
        p_date5                        DATE,
        p_trx_line_dist_tax_amt        NUMBER,
        p_historical_flag              VARCHAR2,
        p_applied_from_application_id  NUMBER,
        p_appl_from_event_class_code   VARCHAR2, --p_applied_from_event_class_code
        p_applied_from_entity_code     VARCHAR2,
        p_applied_from_trx_id          NUMBER,
        p_app_from_hdr_trx_user_key1   VARCHAR2,
        p_app_from_hdr_trx_user_key2   VARCHAR2,
        p_app_from_hdr_trx_user_key3   VARCHAR2,
        p_app_from_hdr_trx_user_key4   VARCHAR2,
        p_app_from_hdr_trx_user_key5   VARCHAR2,
        p_app_from_hdr_trx_user_key6   VARCHAR2,
        p_applied_from_line_id         NUMBER,
        p_app_from_lin_trx_user_key1   VARCHAR2,
        p_app_from_lin_trx_user_key2   VARCHAR2,
        p_app_from_lin_trx_user_key3   VARCHAR2,
        p_app_from_lin_trx_user_key4   VARCHAR2,
        p_app_from_lin_trx_user_key5   VARCHAR2,
        p_app_from_lin_trx_user_key6   VARCHAR2,
        p_applied_from_dist_id         NUMBER,
        p_app_from_dst_trx_user_key1   VARCHAR2,
        p_app_from_dst_trx_user_key2   VARCHAR2,
        p_app_from_dst_trx_user_key3   VARCHAR2,
        p_app_from_dst_trx_user_key4   VARCHAR2,
        p_app_from_dst_trx_user_key5   VARCHAR2,
        p_app_from_dst_trx_user_key6   VARCHAR2,
        p_adj_doc_application_id       NUMBER,   --p_adjusted_doc_application_id
        p_adj_doc_event_class_code     VARCHAR2, --p_adjusted_doc_event_class_code
        p_adjusted_doc_entity_code     VARCHAR2,
        p_adjusted_doc_trx_id          NUMBER,
        p_adj_doc_hdr_trx_user_key1    VARCHAR2,
        p_adj_doc_hdr_trx_user_key2    VARCHAR2,
        p_adj_doc_hdr_trx_user_key3    VARCHAR2,
        p_adj_doc_hdr_trx_user_key4    VARCHAR2,
        p_adj_doc_hdr_trx_user_key5    VARCHAR2,
        p_adj_doc_hdr_trx_user_key6    VARCHAR2,
        p_adjusted_doc_line_id         NUMBER,
        p_adj_doc_lin_trx_user_key1    VARCHAR2,
        p_adj_doc_lin_trx_user_key2    VARCHAR2,
        p_adj_doc_lin_trx_user_key3    VARCHAR2,
        p_adj_doc_lin_trx_user_key4    VARCHAR2,
        p_adj_doc_lin_trx_user_key5    VARCHAR2,
        p_adj_doc_lin_trx_user_key6    VARCHAR2,
        p_adjusted_doc_dist_id         NUMBER,
        p_adj_doc_dst_trx_user_key1    VARCHAR2,
        p_adj_doc_dst_trx_user_key2    VARCHAR2,
        p_adj_doc_dst_trx_user_key3    VARCHAR2,
        p_adj_doc_dst_trx_user_key4    VARCHAR2,
        p_adj_doc_dst_trx_user_key5    VARCHAR2,
        p_adj_doc_dst_trx_user_key6    VARCHAR2,
        p_appl_to_doc_curr_conv_rate   NUMBER, --p_applied_to_doc_curr_conv_rate
        p_tax_variance_calc_flag       VARCHAR2,
        p_ref_doc_trx_line_dist_qty    NUMBER,
        p_price_diff                   NUMBER,
        p_unit_price                   NUMBER,
        p_currency_exchange_rate       NUMBER,
        p_ref_doc_trx_level_type       VARCHAR2,
        p_applied_from_trx_level_type  VARCHAR2,
        p_adjusted_doc_trx_level_type  VARCHAR2,
        p_overriding_recovery_rate     NUMBER,
        p_object_version_number        NUMBER,
        p_created_by                   NUMBER,
        p_creation_date                DATE,
        p_last_updated_by              NUMBER,
        p_last_update_date             DATE,
        p_last_update_login            NUMBER) IS

    l_return_status VARCHAR2(30);
    l_msg_count     NUMBER;
    l_msg_data      VARCHAR2(240);
    p_error_buffer  VARCHAR2(100);

  BEGIN
    g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_SIM_TRX_DISTRIBUTION.Update_Row.BEGIN',
                     'ZX_SIM_TRX_DISTRIBUTION: Update_Row (+)');
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_SIM_TRX_DISTRIBUTION.Update_Row',
                     'Update ZX_SIM_TRX_DISTS (+)');
    END IF;

/*****************
    UPDATE ZX_TRANSACTION
      SET EVENT_TYPE_CODE = p_event_type_code
      WHERE APPLICATION_ID = p_application_id
      AND ENTITY_CODE      = p_entity_code
      AND EVENT_CLASS_CODE = p_event_class_code
      AND TRX_ID           = p_trx_id
      AND EVENT_TYPE_CODE  = 'STANDARD UPDATED';

**************/

    UPDATE ZX_SIM_TRX_DISTS
      SET APPLICATION_ID                =  p_application_id,
          ENTITY_CODE                   =  p_entity_code,
          EVENT_CLASS_CODE              =  p_event_class_code,
          --EVENT_TYPE_CODE               =  p_event_type_code,
          TRX_ID                        =  p_trx_id,
          HDR_TRX_USER_KEY1             =  p_hdr_trx_user_key1,
          HDR_TRX_USER_KEY2             =  p_hdr_trx_user_key2,
          HDR_TRX_USER_KEY3             =  p_hdr_trx_user_key3,
          HDR_TRX_USER_KEY4             =  p_hdr_trx_user_key4,
          HDR_TRX_USER_KEY5             =  p_hdr_trx_user_key5,
          HDR_TRX_USER_KEY6             =  p_hdr_trx_user_key6,
          TRX_LINE_ID                   =  p_trx_line_id,
          LINE_TRX_USER_KEY1            =  p_line_trx_user_key1,
          LINE_TRX_USER_KEY2            =  p_line_trx_user_key2,
          LINE_TRX_USER_KEY3            =  p_line_trx_user_key3,
          LINE_TRX_USER_KEY4            =  p_line_trx_user_key4,
          LINE_TRX_USER_KEY5            =  p_line_trx_user_key5,
          LINE_TRX_USER_KEY6            =  p_line_trx_user_key6,
          TRX_LEVEL_TYPE                =  p_trx_level_type,
          TRX_LINE_DIST_ID              =  p_trx_line_dist_id,
          DIST_TRX_USER_KEY1            =  p_dist_trx_user_key1,
          DIST_TRX_USER_KEY2            =  p_dist_trx_user_key2,
          DIST_TRX_USER_KEY3            =  p_dist_trx_user_key3,
          DIST_TRX_USER_KEY4            =  p_dist_trx_user_key4,
          DIST_TRX_USER_KEY5            =  p_dist_trx_user_key5,
          DIST_TRX_USER_KEY6            =  p_dist_trx_user_key6,
          DIST_LEVEL_ACTION             =  p_dist_level_action,
          TRX_LINE_DIST_DATE            =  p_trx_line_dist_date,
          ITEM_DIST_NUMBER              =  p_item_dist_number,
          DIST_INTENDED_USE             =  p_dist_intended_use,
          TAX_INCLUSION_FLAG            =  p_tax_inclusion_flag,
          TAX_CODE                      =  p_tax_code,
          APPLIED_FROM_TAX_DIST_ID      =  p_applied_from_tax_dist_id,
          ADJUSTED_DOC_TAX_DIST_ID      =  p_adjusted_doc_tax_dist_id,
          TASK_ID                       =  p_task_id,
          AWARD_ID                      =  p_award_id,
          PROJECT_ID                    =  p_project_id,
          EXPENDITURE_TYPE              =  p_expenditure_type,
          EXPENDITURE_ORGANIZATION_ID   =  p_expenditure_organization_id,
          EXPENDITURE_ITEM_DATE         =  p_expenditure_item_date,
          TRX_LINE_DIST_AMT             =  p_trx_line_dist_amt,
          TRX_LINE_DIST_QTY             =  p_trx_line_dist_qty,
          TRX_LINE_QUANTITY             =  p_trx_line_quantity,
          ACCOUNT_CCID                  =  p_account_ccid,
          ACCOUNT_STRING                =  p_account_string,
          REF_DOC_APPLICATION_ID        =  p_ref_doc_application_id,
          REF_DOC_ENTITY_CODE           =  p_ref_doc_entity_code,
          REF_DOC_EVENT_CLASS_CODE      =  p_ref_doc_event_class_code,
          REF_DOC_TRX_ID                =  p_ref_doc_trx_id,
          REF_DOC_HDR_TRX_USER_KEY1     =  p_ref_doc_hdr_trx_user_key1,
          REF_DOC_HDR_TRX_USER_KEY2     =  p_ref_doc_hdr_trx_user_key2,
          REF_DOC_HDR_TRX_USER_KEY3     =  p_ref_doc_hdr_trx_user_key3,
          REF_DOC_HDR_TRX_USER_KEY4     =  p_ref_doc_hdr_trx_user_key4,
          REF_DOC_HDR_TRX_USER_KEY5     =  p_ref_doc_hdr_trx_user_key5,
          REF_DOC_HDR_TRX_USER_KEY6     =  p_ref_doc_hdr_trx_user_key6,
          REF_DOC_LINE_ID               =  p_ref_doc_line_id,
          REF_DOC_LIN_TRX_USER_KEY1     =  p_ref_doc_lin_trx_user_key1,
          REF_DOC_LIN_TRX_USER_KEY2     =  p_ref_doc_lin_trx_user_key2,
          REF_DOC_LIN_TRX_USER_KEY3     =  p_ref_doc_lin_trx_user_key3,
          REF_DOC_LIN_TRX_USER_KEY4     =  p_ref_doc_lin_trx_user_key4,
          REF_DOC_LIN_TRX_USER_KEY5     =  p_ref_doc_lin_trx_user_key5,
          REF_DOC_LIN_TRX_USER_KEY6     =  p_ref_doc_lin_trx_user_key6,
          REF_DOC_DIST_ID               =  p_ref_doc_dist_id,
          REF_DOC_DIST_TRX_USER_KEY1    =  p_ref_doc_dist_trx_user_key1,
          REF_DOC_DIST_TRX_USER_KEY2    =  p_ref_doc_dist_trx_user_key2,
          REF_DOC_DIST_TRX_USER_KEY3    =  p_ref_doc_dist_trx_user_key3,
          REF_DOC_DIST_TRX_USER_KEY4    =  p_ref_doc_dist_trx_user_key4,
          REF_DOC_DIST_TRX_USER_KEY5    =  p_ref_doc_dist_trx_user_key5,
          REF_DOC_DIST_TRX_USER_KEY6    =  p_ref_doc_dist_trx_user_key6,
          REF_DOC_CURR_CONV_RATE        =  p_ref_doc_curr_conv_rate,
          NUMERIC1                      =  p_numeric1,
          NUMERIC2                      =  p_numeric2,
          NUMERIC3                      =  p_numeric3,
          NUMERIC4                      =  p_numeric4,
          NUMERIC5                      =  p_numeric5,
          CHAR1                         =  p_char1,
          CHAR2                         =  p_char2,
          CHAR3                         =  p_char3,
          CHAR4                         =  p_char4,
          CHAR5                         =  p_char5,
          DATE1                         =  p_date1,
          DATE2                         =  p_date2,
          DATE3                         =  p_date3,
          DATE4                         =  p_date4,
          DATE5                         =  p_date5,
          TRX_LINE_DIST_TAX_AMT         =  p_trx_line_dist_tax_amt,
          HISTORICAL_FLAG               =  p_historical_flag,
          APPLIED_FROM_APPLICATION_ID   =  p_applied_from_application_id,
          APPLIED_FROM_EVENT_CLASS_CODE =  p_appl_from_event_class_code,
          APPLIED_FROM_ENTITY_CODE      =  p_applied_from_entity_code,
          APPLIED_FROM_TRX_ID           =  p_applied_from_trx_id,
          APP_FROM_HDR_TRX_USER_KEY1    =  p_app_from_hdr_trx_user_key1,
          APP_FROM_HDR_TRX_USER_KEY2    =  p_app_from_hdr_trx_user_key2,
          APP_FROM_HDR_TRX_USER_KEY3    =  p_app_from_hdr_trx_user_key3,
          APP_FROM_HDR_TRX_USER_KEY4    =  p_app_from_hdr_trx_user_key4,
          APP_FROM_HDR_TRX_USER_KEY5    =  p_app_from_hdr_trx_user_key5,
          APP_FROM_HDR_TRX_USER_KEY6    =  p_app_from_hdr_trx_user_key6,
          APPLIED_FROM_LINE_ID          =  p_applied_from_line_id,
          APP_FROM_LIN_TRX_USER_KEY1    =  p_app_from_lin_trx_user_key1,
          APP_FROM_LIN_TRX_USER_KEY2    =  p_app_from_lin_trx_user_key2,
          APP_FROM_LIN_TRX_USER_KEY3    =  p_app_from_lin_trx_user_key3,
          APP_FROM_LIN_TRX_USER_KEY4    =  p_app_from_lin_trx_user_key4,
          APP_FROM_LIN_TRX_USER_KEY5    =  p_app_from_lin_trx_user_key5,
          APP_FROM_LIN_TRX_USER_KEY6    =  p_app_from_lin_trx_user_key6,
          APPLIED_FROM_DIST_ID          =  p_applied_from_dist_id,
          APP_FROM_DST_TRX_USER_KEY1    =  p_app_from_dst_trx_user_key1,
          APP_FROM_DST_TRX_USER_KEY2    =  p_app_from_dst_trx_user_key2,
          APP_FROM_DST_TRX_USER_KEY3    =  p_app_from_dst_trx_user_key3,
          APP_FROM_DST_TRX_USER_KEY4    =  p_app_from_dst_trx_user_key4,
          APP_FROM_DST_TRX_USER_KEY5    =  p_app_from_dst_trx_user_key5,
          APP_FROM_DST_TRX_USER_KEY6    =  p_app_from_dst_trx_user_key6,
          ADJUSTED_DOC_APPLICATION_ID   =  p_adj_doc_application_id,
          ADJUSTED_DOC_EVENT_CLASS_CODE =  p_adj_doc_event_class_code,
          ADJUSTED_DOC_ENTITY_CODE      =  p_adjusted_doc_entity_code,
          ADJUSTED_DOC_TRX_ID           =  p_adjusted_doc_trx_id,
          ADJ_DOC_HDR_TRX_USER_KEY1     =  p_adj_doc_hdr_trx_user_key1,
          ADJ_DOC_HDR_TRX_USER_KEY2     =  p_adj_doc_hdr_trx_user_key2,
          ADJ_DOC_HDR_TRX_USER_KEY3     =  p_adj_doc_hdr_trx_user_key3,
          ADJ_DOC_HDR_TRX_USER_KEY4     =  p_adj_doc_hdr_trx_user_key4,
          ADJ_DOC_HDR_TRX_USER_KEY5     =  p_adj_doc_hdr_trx_user_key5,
          ADJ_DOC_HDR_TRX_USER_KEY6     =  p_adj_doc_hdr_trx_user_key6,
          ADJUSTED_DOC_LINE_ID          =  p_adjusted_doc_line_id,
          ADJ_DOC_LIN_TRX_USER_KEY1     =  p_adj_doc_lin_trx_user_key1,
          ADJ_DOC_LIN_TRX_USER_KEY2     =  p_adj_doc_lin_trx_user_key2,
          ADJ_DOC_LIN_TRX_USER_KEY3     =  p_adj_doc_lin_trx_user_key3,
          ADJ_DOC_LIN_TRX_USER_KEY4     =  p_adj_doc_lin_trx_user_key4,
          ADJ_DOC_LIN_TRX_USER_KEY5     =  p_adj_doc_lin_trx_user_key5,
          ADJ_DOC_LIN_TRX_USER_KEY6     =  p_adj_doc_lin_trx_user_key6,
          ADJUSTED_DOC_DIST_ID          =  p_adjusted_doc_dist_id,
          ADJ_DOC_DST_TRX_USER_KEY1     =  p_adj_doc_dst_trx_user_key1,
          ADJ_DOC_DST_TRX_USER_KEY2     =  p_adj_doc_dst_trx_user_key2,
          ADJ_DOC_DST_TRX_USER_KEY3     =  p_adj_doc_dst_trx_user_key3,
          ADJ_DOC_DST_TRX_USER_KEY4     =  p_adj_doc_dst_trx_user_key4,
          ADJ_DOC_DST_TRX_USER_KEY5     =  p_adj_doc_dst_trx_user_key5,
          ADJ_DOC_DST_TRX_USER_KEY6     =  p_adj_doc_dst_trx_user_key6,
          APPLIED_TO_DOC_CURR_CONV_RATE =  p_appl_to_doc_curr_conv_rate,
          TAX_VARIANCE_CALC_FLAG        =  p_tax_variance_calc_flag,
          REF_DOC_TRX_LINE_DIST_QTY     =  p_ref_doc_trx_line_dist_qty,
          PRICE_DIFF                    =  p_price_diff,
          UNIT_PRICE                    =  p_unit_price,
          CURRENCY_EXCHANGE_RATE        =  p_currency_exchange_rate,
          REF_DOC_TRX_LEVEL_TYPE        =  p_ref_doc_trx_level_type,
          APPLIED_FROM_TRX_LEVEL_type   =  p_applied_from_trx_level_type,
          ADJUSTED_DOC_TRX_LEVEL_TYPE   =  p_adjusted_doc_trx_level_type,
          OVERRIDING_RECOVERY_RATE      =  p_overriding_recovery_rate,
          OBJECT_VERSION_NUMBER         =  NVL(p_object_version_number, OBJECT_VERSION_NUMBER + 1),
          CREATED_BY                    =  p_created_by,
          CREATION_DATE                 =  p_creation_date,
          LAST_UPDATED_BY               =  p_last_updated_by,
          LAST_UPDATE_DATE              =  p_last_update_date,
          LAST_UPDATE_LOGIN             =  p_last_update_login
      WHERE APPLICATION_ID = p_application_id
      AND ENTITY_CODE      = p_entity_code
      AND EVENT_CLASS_CODE = p_event_class_code
      AND TRX_ID           = p_trx_id
      AND TRX_LINE_ID      = p_trx_line_id
      AND TRX_LEVEL_TYPE   = p_trx_level_type
      AND TRX_LINE_DIST_ID = p_trx_line_dist_id;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_SIM_TRX_DISTRIBUTION.Update_Row',
                     'Update ZX_SIM_TRX_DISTS (-)');
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_SIM_TRX_DISTRIBUTION.Update_Row.END',
                     'ZX_SIM_TRX_DISTRIBUTION: Update_Row (-)');
    END IF;

  END Update_row;

  PROCEDURE Delete_row
       (p_application_id               NUMBER,
        p_entity_code                  VARCHAR2,
        p_event_class_code             VARCHAR2,
        --p_event_type_code              VARCHAR2,
        p_trx_id                       NUMBER,
        p_hdr_trx_user_key1            VARCHAR2,
        p_hdr_trx_user_key2            VARCHAR2,
        p_hdr_trx_user_key3            VARCHAR2,
        p_hdr_trx_user_key4            VARCHAR2,
        p_hdr_trx_user_key5            VARCHAR2,
        p_hdr_trx_user_key6            VARCHAR2,
        p_trx_line_id                  NUMBER,
        p_line_trx_user_key1           VARCHAR2,
        p_line_trx_user_key2           VARCHAR2,
        p_line_trx_user_key3           VARCHAR2,
        p_line_trx_user_key4           VARCHAR2,
        p_line_trx_user_key5           VARCHAR2,
        p_line_trx_user_key6           VARCHAR2,
        p_trx_level_type               VARCHAR2,
        p_trx_line_dist_id             NUMBER,
        p_dist_trx_user_key1           VARCHAR2,
        p_dist_trx_user_key2           VARCHAR2,
        p_dist_trx_user_key3           VARCHAR2,
        p_dist_trx_user_key4           VARCHAR2,
        p_dist_trx_user_key5           VARCHAR2,
        p_dist_trx_user_key6           VARCHAR2,
        p_dist_level_action            VARCHAR2,
        p_trx_line_dist_date           DATE,
        p_item_dist_number             NUMBER,
        p_dist_intended_use            VARCHAR2,
        p_tax_inclusion_flag           VARCHAR2,
        p_tax_code                     VARCHAR2,
        p_applied_from_tax_dist_id     NUMBER,
        p_adjusted_doc_tax_dist_id     NUMBER,
        p_task_id                      NUMBER,
        p_award_id                     NUMBER,
        p_project_id                   NUMBER,
        p_expenditure_type             VARCHAR2,
        p_expenditure_organization_id  NUMBER,
        p_expenditure_item_date        DATE,
        p_trx_line_dist_amt            NUMBER,
        p_trx_line_dist_qty            NUMBER,
        p_trx_line_quantity            NUMBER,
        p_account_ccid                 NUMBER,
        p_account_string               VARCHAR2,
        p_ref_doc_application_id       NUMBER,
        p_ref_doc_entity_code          VARCHAR2,
        p_ref_doc_event_class_code     VARCHAR2,
        p_ref_doc_trx_id               NUMBER,
        p_ref_doc_hdr_trx_user_key1    VARCHAR2,
        p_ref_doc_hdr_trx_user_key2    VARCHAR2,
        p_ref_doc_hdr_trx_user_key3    VARCHAR2,
        p_ref_doc_hdr_trx_user_key4    VARCHAR2,
        p_ref_doc_hdr_trx_user_key5    VARCHAR2,
        p_ref_doc_hdr_trx_user_key6    VARCHAR2,
        p_ref_doc_line_id              NUMBER,
        p_ref_doc_lin_trx_user_key1    VARCHAR2,
        p_ref_doc_lin_trx_user_key2    VARCHAR2,
        p_ref_doc_lin_trx_user_key3    VARCHAR2,
        p_ref_doc_lin_trx_user_key4    VARCHAR2,
        p_ref_doc_lin_trx_user_key5    VARCHAR2,
        p_ref_doc_lin_trx_user_key6    VARCHAR2,
        p_ref_doc_dist_id              NUMBER,
        p_ref_doc_dist_trx_user_key1   VARCHAR2,
        p_ref_doc_dist_trx_user_key2   VARCHAR2,
        p_ref_doc_dist_trx_user_key3   VARCHAR2,
        p_ref_doc_dist_trx_user_key4   VARCHAR2,
        p_ref_doc_dist_trx_user_key5   VARCHAR2,
        p_ref_doc_dist_trx_user_key6   VARCHAR2,
        p_ref_doc_curr_conv_rate       NUMBER,
        p_numeric1                     NUMBER,
        p_numeric2                     NUMBER,
        p_numeric3                     NUMBER,
        p_numeric4                     NUMBER,
        p_numeric5                     NUMBER,
        p_char1                        VARCHAR2,
        p_char2                        VARCHAR2,
        p_char3                        VARCHAR2,
        p_char4                        VARCHAR2,
        p_char5                        VARCHAR2,
        p_date1                        DATE,
        p_date2                        DATE,
        p_date3                        DATE,
        p_date4                        DATE,
        p_date5                        DATE,
        p_trx_line_dist_tax_amt        NUMBER,
        p_historical_flag              VARCHAR2,
        p_applied_from_application_id  NUMBER,
        p_appl_from_event_class_code   VARCHAR2, --p_applied_from_event_class_code
        p_applied_from_entity_code     VARCHAR2,
        p_applied_from_trx_id          NUMBER,
        p_app_from_hdr_trx_user_key1   VARCHAR2,
        p_app_from_hdr_trx_user_key2   VARCHAR2,
        p_app_from_hdr_trx_user_key3   VARCHAR2,
        p_app_from_hdr_trx_user_key4   VARCHAR2,
        p_app_from_hdr_trx_user_key5   VARCHAR2,
        p_app_from_hdr_trx_user_key6   VARCHAR2,
        p_applied_from_line_id         NUMBER,
        p_app_from_lin_trx_user_key1   VARCHAR2,
        p_app_from_lin_trx_user_key2   VARCHAR2,
        p_app_from_lin_trx_user_key3   VARCHAR2,
        p_app_from_lin_trx_user_key4   VARCHAR2,
        p_app_from_lin_trx_user_key5   VARCHAR2,
        p_app_from_lin_trx_user_key6   VARCHAR2,
        p_applied_from_dist_id         NUMBER,
        p_app_from_dst_trx_user_key1   VARCHAR2,
        p_app_from_dst_trx_user_key2   VARCHAR2,
        p_app_from_dst_trx_user_key3   VARCHAR2,
        p_app_from_dst_trx_user_key4   VARCHAR2,
        p_app_from_dst_trx_user_key5   VARCHAR2,
        p_app_from_dst_trx_user_key6   VARCHAR2,
        p_adj_doc_application_id       NUMBER,   --p_adjusted_doc_application_id
        p_adj_doc_event_class_code     VARCHAR2, --p_adjusted_doc_event_class_code
        p_adjusted_doc_entity_code     VARCHAR2,
        p_adjusted_doc_trx_id          NUMBER,
        p_adj_doc_hdr_trx_user_key1    VARCHAR2,
        p_adj_doc_hdr_trx_user_key2    VARCHAR2,
        p_adj_doc_hdr_trx_user_key3    VARCHAR2,
        p_adj_doc_hdr_trx_user_key4    VARCHAR2,
        p_adj_doc_hdr_trx_user_key5    VARCHAR2,
        p_adj_doc_hdr_trx_user_key6    VARCHAR2,
        p_adjusted_doc_line_id         NUMBER,
        p_adj_doc_lin_trx_user_key1    VARCHAR2,
        p_adj_doc_lin_trx_user_key2    VARCHAR2,
        p_adj_doc_lin_trx_user_key3    VARCHAR2,
        p_adj_doc_lin_trx_user_key4    VARCHAR2,
        p_adj_doc_lin_trx_user_key5    VARCHAR2,
        p_adj_doc_lin_trx_user_key6    VARCHAR2,
        p_adjusted_doc_dist_id         NUMBER,
        p_adj_doc_dst_trx_user_key1    VARCHAR2,
        p_adj_doc_dst_trx_user_key2    VARCHAR2,
        p_adj_doc_dst_trx_user_key3    VARCHAR2,
        p_adj_doc_dst_trx_user_key4    VARCHAR2,
        p_adj_doc_dst_trx_user_key5    VARCHAR2,
        p_adj_doc_dst_trx_user_key6    VARCHAR2,
        p_appl_to_doc_curr_conv_rate   NUMBER, --p_applied_to_doc_curr_conv_rate
        p_tax_variance_calc_flag       VARCHAR2,
        p_ref_doc_trx_line_dist_qty    NUMBER,
        p_price_diff                   NUMBER,
        p_unit_price                   NUMBER,
        p_currency_exchange_rate       NUMBER,
        p_ref_doc_trx_level_type       VARCHAR2,
        p_applied_from_trx_level_type  VARCHAR2,
        p_adjusted_doc_trx_level_type  VARCHAR2,
        p_overriding_recovery_rate     NUMBER,
        p_object_version_number        NUMBER,
        p_created_by                   NUMBER,
        p_creation_date                DATE,
        p_last_updated_by              NUMBER,
        p_last_update_date             DATE,
        p_last_update_login            NUMBER) IS

    l_return_status VARCHAR2(30);
    l_msg_count     NUMBER;
    l_msg_data      VARCHAR2(240);
    p_error_buffer  VARCHAR2(100);

  BEGIN
    g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_SIM_TRX_DISTRIBUTION.Delete_Row.BEGIN',
                     'ZX_SIM_TRX_DISTRIBUTION: Delete_Row (+)');
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_SIM_TRX_DISTRIBUTION.Delete_Row',
                     'Delete from ZX_SIM_TRX_DISTRIBUTION (+)');
    END IF;

    /* Delete code */

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_SIM_TRX_DISTRIBUTION.Delete_Row',
                     'Delete from ZX_SIM_TRX_DISTRIBUTION (-)');
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_SIM_TRX_DISTRIBUTION.Delete_Row.END',
                     'ZX_SIM_TRX_DISTRIBUTION: Delete_Row (-)');
    END IF;

  END Delete_row;

  PROCEDURE Lock_row
       (p_application_id               NUMBER,
        p_entity_code                  VARCHAR2,
        p_event_class_code             VARCHAR2,
        --p_event_type_code              VARCHAR2,
        p_trx_id                       NUMBER,
        p_hdr_trx_user_key1            VARCHAR2,
        p_hdr_trx_user_key2            VARCHAR2,
        p_hdr_trx_user_key3            VARCHAR2,
        p_hdr_trx_user_key4            VARCHAR2,
        p_hdr_trx_user_key5            VARCHAR2,
        p_hdr_trx_user_key6            VARCHAR2,
        p_trx_line_id                  NUMBER,
        p_line_trx_user_key1           VARCHAR2,
        p_line_trx_user_key2           VARCHAR2,
        p_line_trx_user_key3           VARCHAR2,
        p_line_trx_user_key4           VARCHAR2,
        p_line_trx_user_key5           VARCHAR2,
        p_line_trx_user_key6           VARCHAR2,
        p_trx_level_type               VARCHAR2,
        p_trx_line_dist_id             NUMBER,
        p_dist_trx_user_key1           VARCHAR2,
        p_dist_trx_user_key2           VARCHAR2,
        p_dist_trx_user_key3           VARCHAR2,
        p_dist_trx_user_key4           VARCHAR2,
        p_dist_trx_user_key5           VARCHAR2,
        p_dist_trx_user_key6           VARCHAR2,
        p_dist_level_action            VARCHAR2,
        p_trx_line_dist_date           DATE,
        p_item_dist_number             NUMBER,
        p_dist_intended_use            VARCHAR2,
        p_tax_inclusion_flag           VARCHAR2,
        p_tax_code                     VARCHAR2,
        p_applied_from_tax_dist_id     NUMBER,
        p_adjusted_doc_tax_dist_id     NUMBER,
        p_task_id                      NUMBER,
        p_award_id                     NUMBER,
        p_project_id                   NUMBER,
        p_expenditure_type             VARCHAR2,
        p_expenditure_organization_id  NUMBER,
        p_expenditure_item_date        DATE,
        p_trx_line_dist_amt            NUMBER,
        p_trx_line_dist_qty            NUMBER,
        p_trx_line_quantity            NUMBER,
        p_account_ccid                 NUMBER,
        p_account_string               VARCHAR2,
        p_ref_doc_application_id       NUMBER,
        p_ref_doc_entity_code          VARCHAR2,
        p_ref_doc_event_class_code     VARCHAR2,
        p_ref_doc_trx_id               NUMBER,
        p_ref_doc_hdr_trx_user_key1    VARCHAR2,
        p_ref_doc_hdr_trx_user_key2    VARCHAR2,
        p_ref_doc_hdr_trx_user_key3    VARCHAR2,
        p_ref_doc_hdr_trx_user_key4    VARCHAR2,
        p_ref_doc_hdr_trx_user_key5    VARCHAR2,
        p_ref_doc_hdr_trx_user_key6    VARCHAR2,
        p_ref_doc_line_id              NUMBER,
        p_ref_doc_lin_trx_user_key1    VARCHAR2,
        p_ref_doc_lin_trx_user_key2    VARCHAR2,
        p_ref_doc_lin_trx_user_key3    VARCHAR2,
        p_ref_doc_lin_trx_user_key4    VARCHAR2,
        p_ref_doc_lin_trx_user_key5    VARCHAR2,
        p_ref_doc_lin_trx_user_key6    VARCHAR2,
        p_ref_doc_dist_id              NUMBER,
        p_ref_doc_dist_trx_user_key1   VARCHAR2,
        p_ref_doc_dist_trx_user_key2   VARCHAR2,
        p_ref_doc_dist_trx_user_key3   VARCHAR2,
        p_ref_doc_dist_trx_user_key4   VARCHAR2,
        p_ref_doc_dist_trx_user_key5   VARCHAR2,
        p_ref_doc_dist_trx_user_key6   VARCHAR2,
        p_ref_doc_curr_conv_rate       NUMBER,
        p_numeric1                     NUMBER,
        p_numeric2                     NUMBER,
        p_numeric3                     NUMBER,
        p_numeric4                     NUMBER,
        p_numeric5                     NUMBER,
        p_char1                        VARCHAR2,
        p_char2                        VARCHAR2,
        p_char3                        VARCHAR2,
        p_char4                        VARCHAR2,
        p_char5                        VARCHAR2,
        p_date1                        DATE,
        p_date2                        DATE,
        p_date3                        DATE,
        p_date4                        DATE,
        p_date5                        DATE,
        p_trx_line_dist_tax_amt        NUMBER,
        p_historical_flag              VARCHAR2,
        p_applied_from_application_id  NUMBER,
        p_appl_from_event_class_code   VARCHAR2, --p_applied_from_event_class_code
        p_applied_from_entity_code     VARCHAR2,
        p_applied_from_trx_id          NUMBER,
        p_app_from_hdr_trx_user_key1   VARCHAR2,
        p_app_from_hdr_trx_user_key2   VARCHAR2,
        p_app_from_hdr_trx_user_key3   VARCHAR2,
        p_app_from_hdr_trx_user_key4   VARCHAR2,
        p_app_from_hdr_trx_user_key5   VARCHAR2,
        p_app_from_hdr_trx_user_key6   VARCHAR2,
        p_applied_from_line_id         NUMBER,
        p_app_from_lin_trx_user_key1   VARCHAR2,
        p_app_from_lin_trx_user_key2   VARCHAR2,
        p_app_from_lin_trx_user_key3   VARCHAR2,
        p_app_from_lin_trx_user_key4   VARCHAR2,
        p_app_from_lin_trx_user_key5   VARCHAR2,
        p_app_from_lin_trx_user_key6   VARCHAR2,
        p_applied_from_dist_id         NUMBER,
        p_app_from_dst_trx_user_key1   VARCHAR2,
        p_app_from_dst_trx_user_key2   VARCHAR2,
        p_app_from_dst_trx_user_key3   VARCHAR2,
        p_app_from_dst_trx_user_key4   VARCHAR2,
        p_app_from_dst_trx_user_key5   VARCHAR2,
        p_app_from_dst_trx_user_key6   VARCHAR2,
        p_adj_doc_application_id       NUMBER,   --p_adjusted_doc_application_id
        p_adj_doc_event_class_code     VARCHAR2, --p_adjusted_doc_event_class_code
        p_adjusted_doc_entity_code     VARCHAR2,
        p_adjusted_doc_trx_id          NUMBER,
        p_adj_doc_hdr_trx_user_key1    VARCHAR2,
        p_adj_doc_hdr_trx_user_key2    VARCHAR2,
        p_adj_doc_hdr_trx_user_key3    VARCHAR2,
        p_adj_doc_hdr_trx_user_key4    VARCHAR2,
        p_adj_doc_hdr_trx_user_key5    VARCHAR2,
        p_adj_doc_hdr_trx_user_key6    VARCHAR2,
        p_adjusted_doc_line_id         NUMBER,
        p_adj_doc_lin_trx_user_key1    VARCHAR2,
        p_adj_doc_lin_trx_user_key2    VARCHAR2,
        p_adj_doc_lin_trx_user_key3    VARCHAR2,
        p_adj_doc_lin_trx_user_key4    VARCHAR2,
        p_adj_doc_lin_trx_user_key5    VARCHAR2,
        p_adj_doc_lin_trx_user_key6    VARCHAR2,
        p_adjusted_doc_dist_id         NUMBER,
        p_adj_doc_dst_trx_user_key1    VARCHAR2,
        p_adj_doc_dst_trx_user_key2    VARCHAR2,
        p_adj_doc_dst_trx_user_key3    VARCHAR2,
        p_adj_doc_dst_trx_user_key4    VARCHAR2,
        p_adj_doc_dst_trx_user_key5    VARCHAR2,
        p_adj_doc_dst_trx_user_key6    VARCHAR2,
        p_appl_to_doc_curr_conv_rate   NUMBER, --p_applied_to_doc_curr_conv_rate
        p_tax_variance_calc_flag       VARCHAR2,
        p_ref_doc_trx_line_dist_qty    NUMBER,
        p_price_diff                   NUMBER,
        p_unit_price                   NUMBER,
        p_currency_exchange_rate       NUMBER,
        p_ref_doc_trx_level_type       VARCHAR2,
        p_applied_from_trx_level_type  VARCHAR2,
        p_adjusted_doc_trx_level_type  VARCHAR2,
        p_overriding_recovery_rate     NUMBER,
        p_object_version_number        NUMBER,
        p_created_by                   NUMBER,
        p_creation_date                DATE,
        p_last_updated_by              NUMBER,
        p_last_update_date             DATE,
        p_last_update_login            NUMBER) IS

    CURSOR C IS
      SELECT APPLICATION_ID,
             ENTITY_CODE,
             EVENT_CLASS_CODE,
             --EVENT_TYPE_CODE,
             TRX_ID,
             HDR_TRX_USER_KEY1,
             HDR_TRX_USER_KEY2,
             HDR_TRX_USER_KEY3,
             HDR_TRX_USER_KEY4,
             HDR_TRX_USER_KEY5,
             HDR_TRX_USER_KEY6,
             TRX_LINE_ID,
             LINE_TRX_USER_KEY1,
             LINE_TRX_USER_KEY2,
             LINE_TRX_USER_KEY3,
             LINE_TRX_USER_KEY4,
             LINE_TRX_USER_KEY5,
             LINE_TRX_USER_KEY6,
             TRX_LEVEL_TYPE,
             TRX_LINE_DIST_ID,
             DIST_TRX_USER_KEY1,
             DIST_TRX_USER_KEY2,
             DIST_TRX_USER_KEY3,
             DIST_TRX_USER_KEY4,
             DIST_TRX_USER_KEY5,
             DIST_TRX_USER_KEY6,
             DIST_LEVEL_ACTION,
             TRX_LINE_DIST_DATE,
             ITEM_DIST_NUMBER,
             DIST_INTENDED_USE,
             TAX_INCLUSION_FLAG,
             TAX_CODE,
             APPLIED_FROM_TAX_DIST_ID,
             ADJUSTED_DOC_TAX_DIST_ID,
             TASK_ID,
             AWARD_ID,
             PROJECT_ID,
             EXPENDITURE_TYPE,
             EXPENDITURE_ORGANIZATION_ID,
             EXPENDITURE_ITEM_DATE,
             TRX_LINE_DIST_AMT,
             TRX_LINE_DIST_QTY,
             TRX_LINE_QUANTITY,
             ACCOUNT_CCID,
             ACCOUNT_STRING,
             REF_DOC_APPLICATION_ID,
             REF_DOC_ENTITY_CODE,
             REF_DOC_EVENT_CLASS_CODE,
             REF_DOC_TRX_ID,
             REF_DOC_HDR_TRX_USER_KEY1,
             REF_DOC_HDR_TRX_USER_KEY2,
             REF_DOC_HDR_TRX_USER_KEY3,
             REF_DOC_HDR_TRX_USER_KEY4,
             REF_DOC_HDR_TRX_USER_KEY5,
             REF_DOC_HDR_TRX_USER_KEY6,
             REF_DOC_LINE_ID,
             REF_DOC_LIN_TRX_USER_KEY1,
             REF_DOC_LIN_TRX_USER_KEY2,
             REF_DOC_LIN_TRX_USER_KEY3,
             REF_DOC_LIN_TRX_USER_KEY4,
             REF_DOC_LIN_TRX_USER_KEY5,
             REF_DOC_LIN_TRX_USER_KEY6,
             REF_DOC_DIST_ID,
             REF_DOC_DIST_TRX_USER_KEY1,
             REF_DOC_DIST_TRX_USER_KEY2,
             REF_DOC_DIST_TRX_USER_KEY3,
             REF_DOC_DIST_TRX_USER_KEY4,
             REF_DOC_DIST_TRX_USER_KEY5,
             REF_DOC_DIST_TRX_USER_KEY6,
             REF_DOC_CURR_CONV_RATE,
             NUMERIC1,
             NUMERIC2,
             NUMERIC3,
             NUMERIC4,
             NUMERIC5,
             CHAR1,
             CHAR2,
             CHAR3,
             CHAR4,
             CHAR5,
             DATE1,
             DATE2,
             DATE3,
             DATE4,
             DATE5,
             TRX_LINE_DIST_TAX_AMT,
             HISTORICAL_FLAG,
             APPLIED_FROM_APPLICATION_ID,
             APPLIED_FROM_EVENT_CLASS_CODE,
             APPLIED_FROM_ENTITY_CODE,
             APPLIED_FROM_TRX_ID,
             APP_FROM_HDR_TRX_USER_KEY1,
             APP_FROM_HDR_TRX_USER_KEY2,
             APP_FROM_HDR_TRX_USER_KEY3,
             APP_FROM_HDR_TRX_USER_KEY4,
             APP_FROM_HDR_TRX_USER_KEY5,
             APP_FROM_HDR_TRX_USER_KEY6,
             APPLIED_FROM_LINE_ID,
             APP_FROM_LIN_TRX_USER_KEY1,
             APP_FROM_LIN_TRX_USER_KEY2,
             APP_FROM_LIN_TRX_USER_KEY3,
             APP_FROM_LIN_TRX_USER_KEY4,
             APP_FROM_LIN_TRX_USER_KEY5,
             APP_FROM_LIN_TRX_USER_KEY6,
             APPLIED_FROM_DIST_ID,
             APP_FROM_DST_TRX_USER_KEY1,
             APP_FROM_DST_TRX_USER_KEY2,
             APP_FROM_DST_TRX_USER_KEY3,
             APP_FROM_DST_TRX_USER_KEY4,
             APP_FROM_DST_TRX_USER_KEY5,
             APP_FROM_DST_TRX_USER_KEY6,
             ADJUSTED_DOC_APPLICATION_ID,
             ADJUSTED_DOC_EVENT_CLASS_CODE,
             ADJUSTED_DOC_ENTITY_CODE,
             ADJUSTED_DOC_TRX_ID,
             ADJ_DOC_HDR_TRX_USER_KEY1,
             ADJ_DOC_HDR_TRX_USER_KEY2,
             ADJ_DOC_HDR_TRX_USER_KEY3,
             ADJ_DOC_HDR_TRX_USER_KEY4,
             ADJ_DOC_HDR_TRX_USER_KEY5,
             ADJ_DOC_HDR_TRX_USER_KEY6,
             ADJUSTED_DOC_LINE_ID,
             ADJ_DOC_LIN_TRX_USER_KEY1,
             ADJ_DOC_LIN_TRX_USER_KEY2,
             ADJ_DOC_LIN_TRX_USER_KEY3,
             ADJ_DOC_LIN_TRX_USER_KEY4,
             ADJ_DOC_LIN_TRX_USER_KEY5,
             ADJ_DOC_LIN_TRX_USER_KEY6,
             ADJUSTED_DOC_DIST_ID,
             ADJ_DOC_DST_TRX_USER_KEY1,
             ADJ_DOC_DST_TRX_USER_KEY2,
             ADJ_DOC_DST_TRX_USER_KEY3,
             ADJ_DOC_DST_TRX_USER_KEY4,
             ADJ_DOC_DST_TRX_USER_KEY5,
             ADJ_DOC_DST_TRX_USER_KEY6,
             APPLIED_TO_DOC_CURR_CONV_RATE,
             TAX_VARIANCE_CALC_FLAG,
             REF_DOC_TRX_LINE_DIST_QTY,
             PRICE_DIFF,
             UNIT_PRICE,
             CURRENCY_EXCHANGE_RATE,
             REF_DOC_TRX_LEVEL_TYPE,
             APPLIED_FROM_TRX_LEVEL_TYPE,
             ADJUSTED_DOC_TRX_LEVEL_TYPE,
             OVERRIDING_RECOVERY_RATE,
             OBJECT_VERSION_NUMBER,
             CREATED_BY,
             CREATION_DATE,
             LAST_UPDATED_BY,
             LAST_UPDATE_DATE,
             LAST_UPDATE_LOGIN
        FROM ZX_SIM_TRX_DISTS
        WHERE APPLICATION_ID = p_application_id
        AND ENTITY_CODE = p_entity_code
        AND EVENT_CLASS_CODE = p_event_class_code
        AND TRX_LINE_ID = p_trx_line_id
        AND TRX_LEVEL_TYPE = p_trx_level_type
        AND TRX_LINE_DIST_ID = p_trx_line_dist_id
        AND TRX_ID = p_trx_id
        FOR UPDATE OF APPLICATION_ID,
                      ENTITY_CODE,
                      EVENT_CLASS_CODE,
                      TRX_LINE_ID,
                      TRX_LEVEL_TYPE,
                      TRX_LINE_DIST_ID,
                      TRX_ID
        NOWAIT;

    Recinfo C%ROWTYPE;
    debug_info             VARCHAR2(100);
    p_error_buffer         VARCHAR2(100);

  BEGIN

    g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_SIM_TRX_DISTRIBUTION.Lock_row.BEGIN',
                     'ZX_SIM_TRX_DISTRIBUTION: Lock_row (+)');
    END IF;

    debug_info := 'Open cursor C';
    OPEN C;
    debug_info := 'Fetch cursor C';
    FETCH C INTO Recinfo;

    IF (C%NOTFOUND) THEN
      debug_info := 'Close cursor C - DATA NOTFOUND';
      CLOSE C;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
      APP_EXCEPTION.Raise_Exception;
    END IF;

    debug_info := 'Close cursor C';
    CLOSE C;

    IF ((Recinfo.APPLICATION_ID = p_APPLICATION_ID) AND
        (Recinfo.ENTITY_CODE = p_ENTITY_CODE) AND
        (Recinfo.EVENT_CLASS_CODE = p_EVENT_CLASS_CODE) AND
        ((Recinfo.TRX_ID = p_TRX_ID)  OR
         ((Recinfo.TRX_ID IS NULL) AND
          (p_TRX_ID IS NULL))) AND
        ((Recinfo.HDR_TRX_USER_KEY1 = p_HDR_TRX_USER_KEY1)  OR
         ((Recinfo.HDR_TRX_USER_KEY1 IS NULL) AND
          (p_HDR_TRX_USER_KEY1 IS NULL))) AND
        ((Recinfo.HDR_TRX_USER_KEY2 = p_HDR_TRX_USER_KEY2)  OR
         ((Recinfo.HDR_TRX_USER_KEY2 IS NULL) AND
          (p_HDR_TRX_USER_KEY2 IS NULL))) AND
        ((Recinfo.HDR_TRX_USER_KEY3 = p_HDR_TRX_USER_KEY3)  OR
         ((Recinfo.HDR_TRX_USER_KEY3 IS NULL) AND
          (p_HDR_TRX_USER_KEY3 IS NULL))) AND
        ((Recinfo.HDR_TRX_USER_KEY4 = p_HDR_TRX_USER_KEY4)  OR
         ((Recinfo.HDR_TRX_USER_KEY4 IS NULL) AND
          (p_HDR_TRX_USER_KEY4 IS NULL))) AND
        ((Recinfo.HDR_TRX_USER_KEY5 = p_HDR_TRX_USER_KEY5)  OR
         ((Recinfo.HDR_TRX_USER_KEY5 IS NULL) AND
          (p_HDR_TRX_USER_KEY5 IS NULL))) AND
        ((Recinfo.HDR_TRX_USER_KEY6 = p_HDR_TRX_USER_KEY6)  OR
         ((Recinfo.HDR_TRX_USER_KEY6 IS NULL) AND
          (p_HDR_TRX_USER_KEY6 IS NULL))) AND
        ((Recinfo.TRX_LINE_ID = p_TRX_LINE_ID)  OR
         ((Recinfo.TRX_LINE_ID IS NULL) AND
          (p_TRX_LINE_ID IS NULL))) AND
        ((Recinfo.LINE_TRX_USER_KEY1 = p_LINE_TRX_USER_KEY1)  OR
         ((Recinfo.LINE_TRX_USER_KEY1 IS NULL) AND
          (p_LINE_TRX_USER_KEY1 IS NULL))) AND
        ((Recinfo.LINE_TRX_USER_KEY2 = p_LINE_TRX_USER_KEY2)  OR
         ((Recinfo.LINE_TRX_USER_KEY2 IS NULL) AND
          (p_LINE_TRX_USER_KEY2 IS NULL))) AND
        ((Recinfo.LINE_TRX_USER_KEY3 = p_LINE_TRX_USER_KEY3)  OR
         ((Recinfo.LINE_TRX_USER_KEY3 IS NULL) AND
          (p_LINE_TRX_USER_KEY3 IS NULL))) AND
        ((Recinfo.LINE_TRX_USER_KEY4 = p_LINE_TRX_USER_KEY4)  OR
         ((Recinfo.LINE_TRX_USER_KEY4 IS NULL) AND
          (p_LINE_TRX_USER_KEY4 IS NULL))) AND
        ((Recinfo.LINE_TRX_USER_KEY5 = p_LINE_TRX_USER_KEY5)  OR
         ((Recinfo.LINE_TRX_USER_KEY5 IS NULL) AND
          (p_LINE_TRX_USER_KEY5 IS NULL))) AND
        ((Recinfo.LINE_TRX_USER_KEY6 = p_LINE_TRX_USER_KEY6)  OR
         ((Recinfo.LINE_TRX_USER_KEY6 IS NULL) AND
          (p_LINE_TRX_USER_KEY6 IS NULL))) AND
        (Recinfo.TRX_LEVEL_TYPE = p_TRX_LEVEL_TYPE) AND
        ((Recinfo.TRX_LINE_DIST_ID = p_TRX_LINE_DIST_ID)  OR
         ((Recinfo.TRX_LINE_DIST_ID IS NULL) AND
          (p_TRX_LINE_DIST_ID IS NULL))) AND
        ((Recinfo.DIST_TRX_USER_KEY1 = p_DIST_TRX_USER_KEY1)  OR
         ((Recinfo.DIST_TRX_USER_KEY1 IS NULL) AND
          (p_DIST_TRX_USER_KEY1 IS NULL))) AND
        ((Recinfo.DIST_TRX_USER_KEY2 = p_DIST_TRX_USER_KEY2)  OR
         ((Recinfo.DIST_TRX_USER_KEY2 IS NULL) AND
          (p_DIST_TRX_USER_KEY2 IS NULL))) AND
        ((Recinfo.DIST_TRX_USER_KEY3 = p_DIST_TRX_USER_KEY3)  OR
         ((Recinfo.DIST_TRX_USER_KEY3 IS NULL) AND
          (p_DIST_TRX_USER_KEY3 IS NULL))) AND
        ((Recinfo.DIST_TRX_USER_KEY4 = p_DIST_TRX_USER_KEY4)  OR
         ((Recinfo.DIST_TRX_USER_KEY4 IS NULL) AND
          (p_DIST_TRX_USER_KEY4 IS NULL))) AND
        ((Recinfo.DIST_TRX_USER_KEY5 = p_DIST_TRX_USER_KEY5)  OR
         ((Recinfo.DIST_TRX_USER_KEY5 IS NULL) AND
          (p_DIST_TRX_USER_KEY5 IS NULL))) AND
        ((Recinfo.DIST_TRX_USER_KEY6 = p_DIST_TRX_USER_KEY6)  OR
         ((Recinfo.DIST_TRX_USER_KEY6 IS NULL) AND
          (p_DIST_TRX_USER_KEY6 IS NULL))) AND
        (Recinfo.DIST_LEVEL_ACTION = p_DIST_LEVEL_ACTION) AND
        (Recinfo.TRX_LINE_DIST_DATE = p_TRX_LINE_DIST_DATE) AND
        ((Recinfo.ITEM_DIST_NUMBER = p_ITEM_DIST_NUMBER)  OR
         ((Recinfo.ITEM_DIST_NUMBER IS NULL) AND
          (p_ITEM_DIST_NUMBER IS NULL))) AND
        (Recinfo.DIST_INTENDED_USE = p_DIST_INTENDED_USE) AND
        ((Recinfo.TAX_INCLUSION_FLAG = p_TAX_INCLUSION_FLAG)  OR
         ((Recinfo.TAX_INCLUSION_FLAG IS NULL) AND
          (p_TAX_INCLUSION_FLAG IS NULL))) AND
        ((Recinfo.TAX_CODE = p_TAX_CODE)  OR
         ((Recinfo.TAX_CODE IS NULL) AND
          (p_TAX_CODE IS NULL))) AND
        ((Recinfo.APPLIED_FROM_TAX_DIST_ID = p_APPLIED_FROM_TAX_DIST_ID)  OR
         ((Recinfo.APPLIED_FROM_TAX_DIST_ID IS NULL) AND
          (p_APPLIED_FROM_TAX_DIST_ID IS NULL))) AND
        ((Recinfo.ADJUSTED_DOC_TAX_DIST_ID = p_ADJUSTED_DOC_TAX_DIST_ID)  OR
         ((Recinfo.ADJUSTED_DOC_TAX_DIST_ID IS NULL) AND
          (p_ADJUSTED_DOC_TAX_DIST_ID IS NULL))) AND
        ((Recinfo.TASK_ID = p_TASK_ID)  OR
         ((Recinfo.TASK_ID IS NULL) AND
          (p_TASK_ID IS NULL))) AND
        ((Recinfo.AWARD_ID = p_AWARD_ID)  OR
         ((Recinfo.AWARD_ID IS NULL) AND
          (p_AWARD_ID IS NULL))) AND
        ((Recinfo.PROJECT_ID = p_PROJECT_ID)  OR
         ((Recinfo.PROJECT_ID IS NULL) AND
          (p_PROJECT_ID IS NULL))) AND
        ((Recinfo.EXPENDITURE_TYPE = p_EXPENDITURE_TYPE)  OR
         ((Recinfo.EXPENDITURE_TYPE IS NULL) AND
          (p_EXPENDITURE_TYPE IS NULL))) AND
        ((Recinfo.EXPENDITURE_ORGANIZATION_ID = p_EXPENDITURE_ORGANIZATION_ID)  OR
         ((Recinfo.EXPENDITURE_ORGANIZATION_ID IS NULL) AND
          (p_EXPENDITURE_ORGANIZATION_ID IS NULL))) AND
        ((Recinfo.EXPENDITURE_ITEM_DATE = p_EXPENDITURE_ITEM_DATE)  OR
         ((Recinfo.EXPENDITURE_ITEM_DATE IS NULL) AND
          (p_EXPENDITURE_ITEM_DATE IS NULL))) AND
        ((Recinfo.TRX_LINE_DIST_AMT = p_TRX_LINE_DIST_AMT)  OR
         ((Recinfo.TRX_LINE_DIST_AMT IS NULL) AND
          (p_TRX_LINE_DIST_AMT IS NULL))) AND
        ((Recinfo.TRX_LINE_DIST_QTY = p_TRX_LINE_DIST_QTY)  OR
         ((Recinfo.TRX_LINE_DIST_QTY IS NULL) AND
          (p_TRX_LINE_DIST_QTY IS NULL))) AND
        ((Recinfo.TRX_LINE_QUANTITY = p_TRX_LINE_QUANTITY)  OR
         ((Recinfo.TRX_LINE_QUANTITY IS NULL) AND
          (p_TRX_LINE_QUANTITY IS NULL))) AND
        ((Recinfo.ACCOUNT_CCID = p_ACCOUNT_CCID)  OR
         ((Recinfo.ACCOUNT_CCID IS NULL) AND
          (p_ACCOUNT_CCID IS NULL))) AND
        ((Recinfo.ACCOUNT_STRING = p_ACCOUNT_STRING)  OR
         ((Recinfo.ACCOUNT_STRING IS NULL) AND
          (p_ACCOUNT_STRING IS NULL))) AND
        ((Recinfo.REF_DOC_APPLICATION_ID = p_REF_DOC_APPLICATION_ID)  OR
         ((Recinfo.REF_DOC_APPLICATION_ID IS NULL) AND
          (p_REF_DOC_APPLICATION_ID IS NULL))) AND
        ((Recinfo.REF_DOC_ENTITY_CODE = p_REF_DOC_ENTITY_CODE)  OR
         ((Recinfo.REF_DOC_ENTITY_CODE IS NULL) AND
          (p_REF_DOC_ENTITY_CODE IS NULL))) AND
        ((Recinfo.REF_DOC_EVENT_CLASS_CODE = p_REF_DOC_EVENT_CLASS_CODE)  OR
         ((Recinfo.REF_DOC_EVENT_CLASS_CODE IS NULL) AND
          (p_REF_DOC_EVENT_CLASS_CODE IS NULL))) AND
        ((Recinfo.REF_DOC_TRX_ID = p_REF_DOC_TRX_ID)  OR
         ((Recinfo.REF_DOC_TRX_ID IS NULL) AND
          (p_REF_DOC_TRX_ID IS NULL))) AND
        ((Recinfo.REF_DOC_HDR_TRX_USER_KEY1 = p_REF_DOC_HDR_TRX_USER_KEY1)  OR
         ((Recinfo.REF_DOC_HDR_TRX_USER_KEY1 IS NULL) AND
          (p_REF_DOC_HDR_TRX_USER_KEY1 IS NULL))) AND
        ((Recinfo.REF_DOC_HDR_TRX_USER_KEY2 = p_REF_DOC_HDR_TRX_USER_KEY2)  OR
         ((Recinfo.REF_DOC_HDR_TRX_USER_KEY2 IS NULL) AND
          (p_REF_DOC_HDR_TRX_USER_KEY2 IS NULL))) AND
        ((Recinfo.REF_DOC_HDR_TRX_USER_KEY3 = p_REF_DOC_HDR_TRX_USER_KEY3)  OR
         ((Recinfo.REF_DOC_HDR_TRX_USER_KEY3 IS NULL) AND
          (p_REF_DOC_HDR_TRX_USER_KEY3 IS NULL))) AND
        ((Recinfo.REF_DOC_HDR_TRX_USER_KEY4 = p_REF_DOC_HDR_TRX_USER_KEY4)  OR
         ((Recinfo.REF_DOC_HDR_TRX_USER_KEY4 IS NULL) AND
          (p_REF_DOC_HDR_TRX_USER_KEY4 IS NULL))) AND
        ((Recinfo.REF_DOC_HDR_TRX_USER_KEY5 = p_REF_DOC_HDR_TRX_USER_KEY5)  OR
         ((Recinfo.REF_DOC_HDR_TRX_USER_KEY5 IS NULL) AND
          (p_REF_DOC_HDR_TRX_USER_KEY5 IS NULL))) AND
        ((Recinfo.REF_DOC_HDR_TRX_USER_KEY6 = p_REF_DOC_HDR_TRX_USER_KEY6)  OR
         ((Recinfo.REF_DOC_HDR_TRX_USER_KEY6 IS NULL) AND
          (p_REF_DOC_HDR_TRX_USER_KEY6 IS NULL))) AND
        ((Recinfo.REF_DOC_LINE_ID = p_REF_DOC_LINE_ID)  OR
         ((Recinfo.REF_DOC_LINE_ID IS NULL) AND
          (p_REF_DOC_LINE_ID IS NULL))) AND
        ((Recinfo.REF_DOC_LIN_TRX_USER_KEY1 = p_REF_DOC_LIN_TRX_USER_KEY1)  OR
         ((Recinfo.REF_DOC_LIN_TRX_USER_KEY1 IS NULL) AND
          (p_REF_DOC_LIN_TRX_USER_KEY1 IS NULL))) AND
        ((Recinfo.REF_DOC_LIN_TRX_USER_KEY2 = p_REF_DOC_LIN_TRX_USER_KEY2)  OR
         ((Recinfo.REF_DOC_LIN_TRX_USER_KEY2 IS NULL) AND
          (p_REF_DOC_LIN_TRX_USER_KEY2 IS NULL))) AND
        ((Recinfo.REF_DOC_LIN_TRX_USER_KEY3 = p_REF_DOC_LIN_TRX_USER_KEY3)  OR
         ((Recinfo.REF_DOC_LIN_TRX_USER_KEY3 IS NULL) AND
          (p_REF_DOC_LIN_TRX_USER_KEY3 IS NULL))) AND
        ((Recinfo.REF_DOC_LIN_TRX_USER_KEY4 = p_REF_DOC_LIN_TRX_USER_KEY4)  OR
         ((Recinfo.REF_DOC_LIN_TRX_USER_KEY4 IS NULL) AND
          (p_REF_DOC_LIN_TRX_USER_KEY4 IS NULL))) AND
        ((Recinfo.REF_DOC_LIN_TRX_USER_KEY5 = p_REF_DOC_LIN_TRX_USER_KEY5)  OR
         ((Recinfo.REF_DOC_LIN_TRX_USER_KEY5 IS NULL) AND
          (p_REF_DOC_LIN_TRX_USER_KEY5 IS NULL))) AND
        ((Recinfo.REF_DOC_LIN_TRX_USER_KEY6 = p_REF_DOC_LIN_TRX_USER_KEY6)  OR
         ((Recinfo.REF_DOC_LIN_TRX_USER_KEY6 IS NULL) AND
          (p_REF_DOC_LIN_TRX_USER_KEY6 IS NULL))) AND
        ((Recinfo.REF_DOC_DIST_ID = p_REF_DOC_DIST_ID)  OR
         ((Recinfo.REF_DOC_DIST_ID IS NULL) AND
          (p_REF_DOC_DIST_ID IS NULL))) AND
        ((Recinfo.REF_DOC_DIST_TRX_USER_KEY1 = p_REF_DOC_DIST_TRX_USER_KEY1)  OR
         ((Recinfo.REF_DOC_DIST_TRX_USER_KEY1 IS NULL) AND
          (p_REF_DOC_DIST_TRX_USER_KEY1 IS NULL))) AND
        ((Recinfo.REF_DOC_DIST_TRX_USER_KEY2 = p_REF_DOC_DIST_TRX_USER_KEY2)  OR
         ((Recinfo.REF_DOC_DIST_TRX_USER_KEY2 IS NULL) AND
          (p_REF_DOC_DIST_TRX_USER_KEY2 IS NULL))) AND
        ((Recinfo.REF_DOC_DIST_TRX_USER_KEY3 = p_REF_DOC_DIST_TRX_USER_KEY3)  OR
         ((Recinfo.REF_DOC_DIST_TRX_USER_KEY3 IS NULL) AND
          (p_REF_DOC_DIST_TRX_USER_KEY3 IS NULL))) AND
        ((Recinfo.REF_DOC_DIST_TRX_USER_KEY4 = p_REF_DOC_DIST_TRX_USER_KEY4)  OR
         ((Recinfo.REF_DOC_DIST_TRX_USER_KEY4 IS NULL) AND
          (p_REF_DOC_DIST_TRX_USER_KEY4 IS NULL))) AND
        ((Recinfo.REF_DOC_DIST_TRX_USER_KEY5 = p_REF_DOC_DIST_TRX_USER_KEY5)  OR
         ((Recinfo.REF_DOC_DIST_TRX_USER_KEY5 IS NULL) AND
          (p_REF_DOC_DIST_TRX_USER_KEY5 IS NULL))) AND
        ((Recinfo.REF_DOC_DIST_TRX_USER_KEY6 = p_REF_DOC_DIST_TRX_USER_KEY6)  OR
         ((Recinfo.REF_DOC_DIST_TRX_USER_KEY6 IS NULL) AND
          (p_REF_DOC_DIST_TRX_USER_KEY6 IS NULL))) AND
        ((Recinfo.REF_DOC_CURR_CONV_RATE = p_REF_DOC_CURR_CONV_RATE)  OR
         ((Recinfo.REF_DOC_CURR_CONV_RATE IS NULL) AND
          (p_REF_DOC_CURR_CONV_RATE IS NULL))) AND
        ((Recinfo.NUMERIC1 = p_NUMERIC1)  OR
         ((Recinfo.NUMERIC1 IS NULL) AND
          (p_NUMERIC1 IS NULL))) AND
        ((Recinfo.NUMERIC2 = p_NUMERIC2)  OR
         ((Recinfo.NUMERIC2 IS NULL) AND
          (p_NUMERIC2 IS NULL))) AND
        ((Recinfo.NUMERIC3 = p_NUMERIC3)  OR
         ((Recinfo.NUMERIC3 IS NULL) AND
          (p_NUMERIC3 IS NULL))) AND
        ((Recinfo.NUMERIC4 = p_NUMERIC4)  OR
         ((Recinfo.NUMERIC4 IS NULL) AND
          (p_NUMERIC4 IS NULL))) AND
        ((Recinfo.NUMERIC5 = p_NUMERIC5)  OR
         ((Recinfo.NUMERIC5 IS NULL) AND
          (p_NUMERIC5 IS NULL))) AND
        ((Recinfo.CHAR1 = p_CHAR1)  OR
         ((Recinfo.CHAR1 IS NULL) AND
          (p_CHAR1 IS NULL))) AND
        ((Recinfo.CHAR2 = p_CHAR2)  OR
         ((Recinfo.CHAR2 IS NULL) AND
          (p_CHAR2 IS NULL))) AND
        ((Recinfo.CHAR3 = p_CHAR3)  OR
         ((Recinfo.CHAR3 IS NULL) AND
          (p_CHAR3 IS NULL))) AND
        ((Recinfo.CHAR4 = p_CHAR4)  OR
         ((Recinfo.CHAR4 IS NULL) AND
          (p_CHAR4 IS NULL))) AND
        ((Recinfo.CHAR5 = p_CHAR5)  OR
         ((Recinfo.CHAR5 IS NULL) AND
          (p_CHAR5 IS NULL))) AND
        ((Recinfo.DATE1 = p_DATE1)  OR
         ((Recinfo.DATE1 IS NULL) AND
          (p_DATE1 IS NULL))) AND
        ((Recinfo.DATE2 = p_DATE2)  OR
         ((Recinfo.DATE2 IS NULL) AND
          (p_DATE2 IS NULL))) AND
        ((Recinfo.DATE3 = p_DATE3)  OR
         ((Recinfo.DATE3 IS NULL) AND
          (p_DATE3 IS NULL))) AND
        ((Recinfo.DATE4 = p_DATE4)  OR
         ((Recinfo.DATE4 IS NULL) AND
          (p_DATE4 IS NULL))) AND
        ((Recinfo.DATE5 = p_DATE5)  OR
         ((Recinfo.DATE5 IS NULL) AND
          (p_DATE5 IS NULL))) AND
        ((Recinfo.TRX_LINE_DIST_TAX_AMT = p_TRX_LINE_DIST_TAX_AMT)  OR
         ((Recinfo.TRX_LINE_DIST_TAX_AMT IS NULL) AND
          (p_TRX_LINE_DIST_TAX_AMT IS NULL))) AND
        ((Recinfo.HISTORICAL_FLAG = p_HISTORICAL_FLAG)  OR
         ((Recinfo.HISTORICAL_FLAG IS NULL) AND
          (p_HISTORICAL_FLAG IS NULL))) AND
        ((Recinfo.APPLIED_FROM_APPLICATION_ID = p_APPLIED_FROM_APPLICATION_ID)  OR
         ((Recinfo.APPLIED_FROM_APPLICATION_ID IS NULL) AND
          (p_APPLIED_FROM_APPLICATION_ID IS NULL))) AND
        ((Recinfo.APPLIED_FROM_EVENT_CLASS_CODE = p_APPL_FROM_EVENT_CLASS_CODE)  OR
         ((Recinfo.APPLIED_FROM_EVENT_CLASS_CODE IS NULL) AND
          (p_APPL_FROM_EVENT_CLASS_CODE IS NULL))) AND
        ((Recinfo.APPLIED_FROM_ENTITY_CODE = p_APPLIED_FROM_ENTITY_CODE)  OR
         ((Recinfo.APPLIED_FROM_ENTITY_CODE IS NULL) AND
          (p_APPLIED_FROM_ENTITY_CODE IS NULL))) AND
        ((Recinfo.APPLIED_FROM_TRX_ID = p_APPLIED_FROM_TRX_ID)  OR
         ((Recinfo.APPLIED_FROM_TRX_ID IS NULL) AND
          (p_APPLIED_FROM_TRX_ID IS NULL))) AND
        ((Recinfo.APP_FROM_HDR_TRX_USER_KEY1 = p_APP_FROM_HDR_TRX_USER_KEY1)  OR
         ((Recinfo.APP_FROM_HDR_TRX_USER_KEY1 IS NULL) AND
          (p_APP_FROM_HDR_TRX_USER_KEY1 IS NULL))) AND
        ((Recinfo.APP_FROM_HDR_TRX_USER_KEY2 = p_APP_FROM_HDR_TRX_USER_KEY2)  OR
         ((Recinfo.APP_FROM_HDR_TRX_USER_KEY2 IS NULL) AND
          (p_APP_FROM_HDR_TRX_USER_KEY2 IS NULL))) AND
        ((Recinfo.APP_FROM_HDR_TRX_USER_KEY3 = p_APP_FROM_HDR_TRX_USER_KEY3)  OR
         ((Recinfo.APP_FROM_HDR_TRX_USER_KEY3 IS NULL) AND
          (p_APP_FROM_HDR_TRX_USER_KEY3 IS NULL))) AND
        ((Recinfo.APP_FROM_HDR_TRX_USER_KEY4 = p_APP_FROM_HDR_TRX_USER_KEY4)  OR
         ((Recinfo.APP_FROM_HDR_TRX_USER_KEY4 IS NULL) AND
          (p_APP_FROM_HDR_TRX_USER_KEY4 IS NULL))) AND
        ((Recinfo.APP_FROM_HDR_TRX_USER_KEY5 = p_APP_FROM_HDR_TRX_USER_KEY5)  OR
         ((Recinfo.APP_FROM_HDR_TRX_USER_KEY5 IS NULL) AND
          (p_APP_FROM_HDR_TRX_USER_KEY5 IS NULL))) AND
        ((Recinfo.APP_FROM_HDR_TRX_USER_KEY6 = p_APP_FROM_HDR_TRX_USER_KEY6)  OR
         ((Recinfo.APP_FROM_HDR_TRX_USER_KEY6 IS NULL) AND
          (p_APP_FROM_HDR_TRX_USER_KEY6 IS NULL))) AND
        ((Recinfo.APPLIED_FROM_LINE_ID = p_APPLIED_FROM_LINE_ID)  OR
         ((Recinfo.APPLIED_FROM_LINE_ID IS NULL) AND
          (p_APPLIED_FROM_LINE_ID IS NULL))) AND
        ((Recinfo.APP_FROM_LIN_TRX_USER_KEY1 = p_APP_FROM_LIN_TRX_USER_KEY1)  OR
         ((Recinfo.APP_FROM_LIN_TRX_USER_KEY1 IS NULL) AND
          (p_APP_FROM_LIN_TRX_USER_KEY1 IS NULL))) AND
        ((Recinfo.APP_FROM_LIN_TRX_USER_KEY2 = p_APP_FROM_LIN_TRX_USER_KEY2)  OR
         ((Recinfo.APP_FROM_LIN_TRX_USER_KEY2 IS NULL) AND
          (p_APP_FROM_LIN_TRX_USER_KEY2 IS NULL))) AND
        ((Recinfo.APP_FROM_LIN_TRX_USER_KEY3 = p_APP_FROM_LIN_TRX_USER_KEY3)  OR
         ((Recinfo.APP_FROM_LIN_TRX_USER_KEY3 IS NULL) AND
          (p_APP_FROM_LIN_TRX_USER_KEY3 IS NULL))) AND
        ((Recinfo.APP_FROM_LIN_TRX_USER_KEY4 = p_APP_FROM_LIN_TRX_USER_KEY4)  OR
         ((Recinfo.APP_FROM_LIN_TRX_USER_KEY4 IS NULL) AND
          (p_APP_FROM_LIN_TRX_USER_KEY4 IS NULL))) AND
        ((Recinfo.APP_FROM_LIN_TRX_USER_KEY5 = p_APP_FROM_LIN_TRX_USER_KEY5)  OR
         ((Recinfo.APP_FROM_LIN_TRX_USER_KEY5 IS NULL) AND
          (p_APP_FROM_LIN_TRX_USER_KEY5 IS NULL))) AND
        ((Recinfo.APP_FROM_LIN_TRX_USER_KEY6 = p_APP_FROM_LIN_TRX_USER_KEY6)  OR
         ((Recinfo.APP_FROM_LIN_TRX_USER_KEY6 IS NULL) AND
          (p_APP_FROM_LIN_TRX_USER_KEY6 IS NULL))) AND
        ((Recinfo.APPLIED_FROM_DIST_ID = p_APPLIED_FROM_DIST_ID)  OR
         ((Recinfo.APPLIED_FROM_DIST_ID IS NULL) AND
          (p_APPLIED_FROM_DIST_ID IS NULL))) AND
        ((Recinfo.APP_FROM_DST_TRX_USER_KEY1 = p_APP_FROM_DST_TRX_USER_KEY1)  OR
         ((Recinfo.APP_FROM_DST_TRX_USER_KEY1 IS NULL) AND
          (p_APP_FROM_DST_TRX_USER_KEY1 IS NULL))) AND
        ((Recinfo.APP_FROM_DST_TRX_USER_KEY2 = p_APP_FROM_DST_TRX_USER_KEY2)  OR
         ((Recinfo.APP_FROM_DST_TRX_USER_KEY2 IS NULL) AND
          (p_APP_FROM_DST_TRX_USER_KEY2 IS NULL))) AND
        ((Recinfo.APP_FROM_DST_TRX_USER_KEY3 = p_APP_FROM_DST_TRX_USER_KEY3)  OR
         ((Recinfo.APP_FROM_DST_TRX_USER_KEY3 IS NULL) AND
          (p_APP_FROM_DST_TRX_USER_KEY3 IS NULL))) AND
        ((Recinfo.APP_FROM_DST_TRX_USER_KEY4 = p_APP_FROM_DST_TRX_USER_KEY4)  OR
         ((Recinfo.APP_FROM_DST_TRX_USER_KEY4 IS NULL) AND
          (p_APP_FROM_DST_TRX_USER_KEY4 IS NULL))) AND
        ((Recinfo.APP_FROM_DST_TRX_USER_KEY5 = p_APP_FROM_DST_TRX_USER_KEY5)  OR
         ((Recinfo.APP_FROM_DST_TRX_USER_KEY5 IS NULL) AND
          (p_APP_FROM_DST_TRX_USER_KEY5 IS NULL))) AND
        ((Recinfo.APP_FROM_DST_TRX_USER_KEY6 = p_APP_FROM_DST_TRX_USER_KEY6)  OR
         ((Recinfo.APP_FROM_DST_TRX_USER_KEY6 IS NULL) AND
          (p_APP_FROM_DST_TRX_USER_KEY6 IS NULL))) AND
        ((Recinfo.ADJUSTED_DOC_APPLICATION_ID = p_ADJ_DOC_APPLICATION_ID)  OR
         ((Recinfo.ADJUSTED_DOC_APPLICATION_ID IS NULL) AND
          (p_ADJ_DOC_APPLICATION_ID IS NULL))) AND
        ((Recinfo.ADJUSTED_DOC_EVENT_CLASS_CODE = p_ADJ_DOC_EVENT_CLASS_CODE)  OR
         ((Recinfo.ADJUSTED_DOC_EVENT_CLASS_CODE IS NULL) AND
          (p_ADJ_DOC_EVENT_CLASS_CODE IS NULL))) AND
        ((Recinfo.ADJUSTED_DOC_ENTITY_CODE = p_ADJUSTED_DOC_ENTITY_CODE)  OR
         ((Recinfo.ADJUSTED_DOC_ENTITY_CODE IS NULL) AND
          (p_ADJUSTED_DOC_ENTITY_CODE IS NULL))) AND
        ((Recinfo.ADJUSTED_DOC_TRX_ID = p_ADJUSTED_DOC_TRX_ID)  OR
         ((Recinfo.ADJUSTED_DOC_TRX_ID IS NULL) AND
          (p_ADJUSTED_DOC_TRX_ID IS NULL))) AND
        ((Recinfo.ADJ_DOC_HDR_TRX_USER_KEY1 = p_ADJ_DOC_HDR_TRX_USER_KEY1)  OR
         ((Recinfo.ADJ_DOC_HDR_TRX_USER_KEY1 IS NULL) AND
          (p_ADJ_DOC_HDR_TRX_USER_KEY1 IS NULL))) AND
        ((Recinfo.ADJ_DOC_HDR_TRX_USER_KEY2 = p_ADJ_DOC_HDR_TRX_USER_KEY2)  OR
         ((Recinfo.ADJ_DOC_HDR_TRX_USER_KEY2 IS NULL) AND
          (p_ADJ_DOC_HDR_TRX_USER_KEY2 IS NULL))) AND
        ((Recinfo.ADJ_DOC_HDR_TRX_USER_KEY3 = p_ADJ_DOC_HDR_TRX_USER_KEY3)  OR
         ((Recinfo.ADJ_DOC_HDR_TRX_USER_KEY3 IS NULL) AND
          (p_ADJ_DOC_HDR_TRX_USER_KEY3 IS NULL))) AND
        ((Recinfo.ADJ_DOC_HDR_TRX_USER_KEY4 = p_ADJ_DOC_HDR_TRX_USER_KEY4)  OR
         ((Recinfo.ADJ_DOC_HDR_TRX_USER_KEY4 IS NULL) AND
          (p_ADJ_DOC_HDR_TRX_USER_KEY4 IS NULL))) AND
        ((Recinfo.ADJ_DOC_HDR_TRX_USER_KEY5 = p_ADJ_DOC_HDR_TRX_USER_KEY5)  OR
         ((Recinfo.ADJ_DOC_HDR_TRX_USER_KEY5 IS NULL) AND
          (p_ADJ_DOC_HDR_TRX_USER_KEY5 IS NULL))) AND
        ((Recinfo.ADJ_DOC_HDR_TRX_USER_KEY6 = p_ADJ_DOC_HDR_TRX_USER_KEY6)  OR
         ((Recinfo.ADJ_DOC_HDR_TRX_USER_KEY6 IS NULL) AND
          (p_ADJ_DOC_HDR_TRX_USER_KEY6 IS NULL))) AND
        ((Recinfo.ADJUSTED_DOC_LINE_ID = p_ADJUSTED_DOC_LINE_ID)  OR
         ((Recinfo.ADJUSTED_DOC_LINE_ID IS NULL) AND
          (p_ADJUSTED_DOC_LINE_ID IS NULL))) AND
        ((Recinfo.ADJ_DOC_LIN_TRX_USER_KEY1 = p_ADJ_DOC_LIN_TRX_USER_KEY1)  OR
         ((Recinfo.ADJ_DOC_LIN_TRX_USER_KEY1 IS NULL) AND
          (p_ADJ_DOC_LIN_TRX_USER_KEY1 IS NULL))) AND
        ((Recinfo.ADJ_DOC_LIN_TRX_USER_KEY2 = p_ADJ_DOC_LIN_TRX_USER_KEY2)  OR
         ((Recinfo.ADJ_DOC_LIN_TRX_USER_KEY2 IS NULL) AND
          (p_ADJ_DOC_LIN_TRX_USER_KEY2 IS NULL))) AND
        ((Recinfo.ADJ_DOC_LIN_TRX_USER_KEY3 = p_ADJ_DOC_LIN_TRX_USER_KEY3)  OR
         ((Recinfo.ADJ_DOC_LIN_TRX_USER_KEY3 IS NULL) AND
          (p_ADJ_DOC_LIN_TRX_USER_KEY3 IS NULL))) AND
        ((Recinfo.ADJ_DOC_LIN_TRX_USER_KEY4 = p_ADJ_DOC_LIN_TRX_USER_KEY4)  OR
         ((Recinfo.ADJ_DOC_LIN_TRX_USER_KEY4 IS NULL) AND
          (p_ADJ_DOC_LIN_TRX_USER_KEY4 IS NULL))) AND
        ((Recinfo.ADJ_DOC_LIN_TRX_USER_KEY5 = p_ADJ_DOC_LIN_TRX_USER_KEY5)  OR
         ((Recinfo.ADJ_DOC_LIN_TRX_USER_KEY5 IS NULL) AND
          (p_ADJ_DOC_LIN_TRX_USER_KEY5 IS NULL))) AND
        ((Recinfo.ADJ_DOC_LIN_TRX_USER_KEY6 = p_ADJ_DOC_LIN_TRX_USER_KEY6)  OR
         ((Recinfo.ADJ_DOC_LIN_TRX_USER_KEY6 IS NULL) AND
          (p_ADJ_DOC_LIN_TRX_USER_KEY6 IS NULL))) AND
        ((Recinfo.ADJUSTED_DOC_DIST_ID = p_ADJUSTED_DOC_DIST_ID)  OR
         ((Recinfo.ADJUSTED_DOC_DIST_ID IS NULL) AND
          (p_ADJUSTED_DOC_DIST_ID IS NULL))) AND
        ((Recinfo.ADJ_DOC_DST_TRX_USER_KEY1 = p_ADJ_DOC_DST_TRX_USER_KEY1)  OR
         ((Recinfo.ADJ_DOC_DST_TRX_USER_KEY1 IS NULL) AND
          (p_ADJ_DOC_DST_TRX_USER_KEY1 IS NULL))) AND
        ((Recinfo.ADJ_DOC_DST_TRX_USER_KEY2 = p_ADJ_DOC_DST_TRX_USER_KEY2)  OR
         ((Recinfo.ADJ_DOC_DST_TRX_USER_KEY2 IS NULL) AND
          (p_ADJ_DOC_DST_TRX_USER_KEY2 IS NULL))) AND
        ((Recinfo.ADJ_DOC_DST_TRX_USER_KEY3 = p_ADJ_DOC_DST_TRX_USER_KEY3)  OR
         ((Recinfo.ADJ_DOC_DST_TRX_USER_KEY3 IS NULL) AND
          (p_ADJ_DOC_DST_TRX_USER_KEY3 IS NULL))) AND
        ((Recinfo.ADJ_DOC_DST_TRX_USER_KEY4 = p_ADJ_DOC_DST_TRX_USER_KEY4)  OR
         ((Recinfo.ADJ_DOC_DST_TRX_USER_KEY4 IS NULL) AND
          (p_ADJ_DOC_DST_TRX_USER_KEY4 IS NULL))) AND
        ((Recinfo.ADJ_DOC_DST_TRX_USER_KEY5 = p_ADJ_DOC_DST_TRX_USER_KEY5)  OR
         ((Recinfo.ADJ_DOC_DST_TRX_USER_KEY5 IS NULL) AND
          (p_ADJ_DOC_DST_TRX_USER_KEY5 IS NULL))) AND
        ((Recinfo.ADJ_DOC_DST_TRX_USER_KEY6 = p_ADJ_DOC_DST_TRX_USER_KEY6)  OR
         ((Recinfo.ADJ_DOC_DST_TRX_USER_KEY6 IS NULL) AND
          (p_ADJ_DOC_DST_TRX_USER_KEY6 IS NULL))) AND
        ((Recinfo.APPLIED_TO_DOC_CURR_CONV_RATE = p_APPL_TO_DOC_CURR_CONV_RATE)  OR
         ((Recinfo.APPLIED_TO_DOC_CURR_CONV_RATE IS NULL) AND
          (p_APPL_TO_DOC_CURR_CONV_RATE IS NULL))) AND
        ((Recinfo.TAX_VARIANCE_CALC_FLAG = p_TAX_VARIANCE_CALC_FLAG)  OR
         ((Recinfo.TAX_VARIANCE_CALC_FLAG IS NULL) AND
          (p_TAX_VARIANCE_CALC_FLAG IS NULL))) AND
        ((Recinfo.REF_DOC_TRX_LINE_DIST_QTY = p_REF_DOC_TRX_LINE_DIST_QTY )  OR
         ((Recinfo.REF_DOC_TRX_LINE_DIST_QTY IS NULL) AND
          (p_REF_DOC_TRX_LINE_DIST_QTY IS NULL))) AND
        ((Recinfo.PRICE_DIFF = p_PRICE_DIFF  )  OR
         ((Recinfo.PRICE_DIFF IS NULL) AND
          (p_PRICE_DIFF IS NULL))) AND
        ((Recinfo.UNIT_PRICE = p_UNIT_PRICE )  OR
         ((Recinfo.UNIT_PRICE IS NULL) AND
          (p_UNIT_PRICE IS NULL))) AND
        ((Recinfo.CURRENCY_EXCHANGE_RATE = p_CURRENCY_EXCHANGE_RATE )  OR
         ((Recinfo.CURRENCY_EXCHANGE_RATE IS NULL) AND
          (p_CURRENCY_EXCHANGE_RATE IS NULL))) AND
        ((Recinfo.REF_DOC_TRX_LEVEL_TYPE = p_REF_DOC_TRX_LEVEL_TYPE )  OR
         ((Recinfo.REF_DOC_TRX_LEVEL_TYPE IS NULL) AND
          (p_REF_DOC_TRX_LEVEL_TYPE IS NULL))) AND
        ((Recinfo.APPLIED_FROM_TRX_LEVEL_TYPE = p_APPLIED_FROM_TRX_LEVEL_TYPE  )  OR
         ((Recinfo.APPLIED_FROM_TRX_LEVEL_TYPE IS NULL) AND
          (p_APPLIED_FROM_TRX_LEVEL_TYPE IS NULL))) AND
        ((Recinfo.ADJUSTED_DOC_TRX_LEVEL_TYPE = p_ADJUSTED_DOC_TRX_LEVEL_TYPE )  OR
         ((Recinfo.ADJUSTED_DOC_TRX_LEVEL_TYPE IS NULL) AND
          (p_ADJUSTED_DOC_TRX_LEVEL_TYPE IS NULL))) AND
        ((Recinfo.OVERRIDING_RECOVERY_RATE = p_OVERRIDING_RECOVERY_RATE  )  OR
         ((Recinfo.OVERRIDING_RECOVERY_RATE IS NULL) AND
          (p_OVERRIDING_RECOVERY_RATE IS NULL))) AND
        (Recinfo.OBJECT_VERSION_NUMBER = p_OBJECT_VERSION_NUMBER) AND
        (Recinfo.CREATED_BY = p_CREATED_BY) AND
        (Recinfo.CREATION_DATE = p_CREATION_DATE) AND
        (Recinfo.LAST_UPDATED_BY = p_LAST_UPDATED_BY) AND
        (Recinfo.LAST_UPDATE_DATE = p_LAST_UPDATE_DATE) AND
        ((Recinfo.LAST_UPDATE_LOGIN = p_LAST_UPDATE_LOGIN)  OR
         ((Recinfo.LAST_UPDATE_LOGIN IS NULL) AND
          (p_LAST_UPDATE_LOGIN IS NULL))) ) THEN
      return;
    ELSE
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    END IF;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_SIM_TRX_DISTRIBUTION.Lock_row.END',
                     'ZX_SIM_TRX_DISTRIBUTION: Lock_row (-)');
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      p_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

      FND_MESSAGE.SET_NAME('ZX','ZX_UNEXPECTED_ERROR');
      FND_MSG_PUB.Add;

      IF (g_level_unexpected >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_unexpected,
                       'ZX.PLSQL.ZX_SIM_TRX_DISTRIBUTION.Lock_Row',
                       p_error_buffer);
      END IF;

  END Lock_Row;

  PROCEDURE Insert_Temporary_Table
       (p_application_id               NUMBER,
        p_entity_code                  VARCHAR2,
        p_event_class_code             VARCHAR2,
        p_event_type_code              VARCHAR2,
        p_trx_line_id                  NUMBER,
        p_trx_line_dist_id             NUMBER,
        p_trx_id                       NUMBER,
        p_ledger_id                    NUMBER,
        p_reporting_currency_code      VARCHAR2,
        p_currency_conversion_date     DATE,
        p_currency_conversion_type     VARCHAR2,
        p_currency_conversion_rate     NUMBER,
        p_minimum_accountable_unit     NUMBER,
        p_precision                    NUMBER) IS

    l_return_status        VARCHAR2(1000);
    l_msg_count            NUMBER;
    l_msg_data             VARCHAR2(1000);
    sid                    NUMBER;
    p_error_buffer         VARCHAR2(100);
    debug_info             VARCHAR2(100);

    l_event_class_rec      ZX_API_PUB.event_class_rec_type;

  BEGIN

    g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_SIM_TRX_DISTRIBUTION.Insert_Temporary_Table.BEGIN',
                     'ZX_SIM_TRX_DISTRIBUTION: Insert_Temporary_Table (+)');

    END IF;

    DELETE ZX_TRX_HEADERS_GT
      WHERE APPLICATION_ID   = p_application_id
        AND ENTITY_CODE      = p_entity_code
        AND EVENT_CLASS_CODE = p_event_class_code
        AND TRX_ID           = p_trx_id;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_SIM_TRX_DISTRIBUTION.Insert_Temporary_Tables',
                     'Insert into zx_trx_headers_gt (+)');
    END IF;

      INSERT INTO ZX_TRX_HEADERS_GT (INTERNAL_ORGANIZATION_ID,
                                             INTERNAL_ORG_LOCATION_ID,
                                             APPLICATION_ID,
                                             ENTITY_CODE,
                                             EVENT_CLASS_CODE,
                                             EVENT_TYPE_CODE,
                                             TRX_ID,
                                             TRX_DATE,
                                             --TRX_DOC_REVISION,
                                             LEDGER_ID,
                                             TRX_CURRENCY_CODE,
                                             CURRENCY_CONVERSION_DATE,
                                             CURRENCY_CONVERSION_RATE,
                                             CURRENCY_CONVERSION_TYPE,
                                             MINIMUM_ACCOUNTABLE_UNIT,
                                             PRECISION,
                                             LEGAL_ENTITY_ID,
                                             ROUNDING_SHIP_TO_PARTY_ID,
                                             ROUNDING_SHIP_FROM_PARTY_ID,
                                             ROUNDING_BILL_TO_PARTY_ID,
                                             ROUNDING_BILL_FROM_PARTY_ID,
                                             RNDG_SHIP_TO_PARTY_SITE_ID,
                                             RNDG_SHIP_FROM_PARTY_SITE_ID,
                                             RNDG_BILL_TO_PARTY_SITE_ID,
                                             RNDG_BILL_FROM_PARTY_SITE_ID,
                                             ESTABLISHMENT_ID,
                                             RECEIVABLES_TRX_TYPE_ID,
                                             --RELATED_DOC_APPLICATION_ID,
                                             --RELATED_DOC_ENTITY_CODE,
                                             --RELATED_DOC_EVENT_CLASS_CODE,
                                             --RELATED_DOC_TRX_ID,
                                             --REL_DOC_HDR_TRX_USER_KEY1,
                                             --REL_DOC_HDR_TRX_USER_KEY2,
                                             --REL_DOC_HDR_TRX_USER_KEY3,
                                             --REL_DOC_HDR_TRX_USER_KEY4,
                                             --REL_DOC_HDR_TRX_USER_KEY5,
                                             --REL_DOC_HDR_TRX_USER_KEY6,
                                             --RELATED_DOC_NUMBER,
                                             --RELATED_DOC_DATE,
                                             DEFAULT_TAXATION_COUNTRY,
                                             Quote_Flag,
                                             CTRL_TOTAL_HDR_TX_AMT,
                                             TRX_NUMBER,
                                             TRX_DESCRIPTION,
                                             --TRX_COMMUNICATED_DATE,
                                             --BATCH_SOURCE_ID,
                                             --BATCH_SOURCE_NAME,
                                             --DOC_SEQ_ID,
                                             --DOC_SEQ_NAME,
                                             --DOC_SEQ_VALUE,
                                             --TRX_DUE_DATE,
                                             --TRX_TYPE_DESCRIPTION,
                                             --BILLING_TRADING_PARTNER_NAME,
                                             --BILLING_TRADING_PARTNER_NUMBER,
                                             --Billing_Tp_Tax_Reporting_Flag,
                                             --BILLING_TP_TAXPAYER_ID,
                                             DOCUMENT_SUB_TYPE,
                                             SUPPLIER_TAX_INVOICE_NUMBER,
                                             SUPPLIER_TAX_INVOICE_DATE,
                                             SUPPLIER_EXCHANGE_RATE,
                                             TAX_INVOICE_DATE,
                                             TAX_INVOICE_NUMBER,
                                             FIRST_PTY_ORG_ID,
                                             PORT_OF_ENTRY_CODE,
                                             TAX_REPORTING_FLAG,
                                             SHIP_TO_CUST_ACCT_SITE_USE_ID,
                                             BILL_TO_CUST_ACCT_SITE_USE_ID,
                                             PROVNL_TAX_DETERMINATION_DATE,
                                             APPLIED_TO_TRX_NUMBER,
                                             SHIP_THIRD_PTY_ACCT_ID,
                                             BILL_THIRD_PTY_ACCT_ID,
                                             SHIP_THIRD_PTY_ACCT_SITE_ID,
                                             BILL_THIRD_PTY_ACCT_SITE_ID,
                                             VALIDATION_CHECK_FLAG,
                                             --TAX_EVENT_CLASS_CODE,
                                             TAX_EVENT_TYPE_CODE
                                             --DOC_EVENT_STATUS,
                                             --RDNG_SHIP_TO_PTY_TX_PROF_ID,
                                             --RDNG_SHIP_FROM_PTY_TX_PROF_ID,
                                             --RDNG_BILL_TO_PTY_TX_PROF_ID,
                                             --RDNG_BILL_FROM_PTY_TX_PROF_ID,
                                             --RDNG_SHIP_TO_PTY_TX_P_ST_ID,
                                             --RDNG_SHIP_FROM_PTY_TX_P_ST_ID,
                                             --RDNG_BILL_TO_PTY_TX_P_ST_ID,
                                             --RDNG_BILL_FROM_PTY_TX_P_ST_ID
                                             )
                                      SELECT internal_organization_id,
                                             internal_org_location_id,
                                             application_id,
                                             entity_code,
                                             event_class_code,
                                             event_type_code,
                                             trx_id,
                                             trx_date,
                                             --p_trx_doc_revision,
                                             ledger_id,
                                             trx_currency_code,
                                             currency_conversion_date,
                                             currency_conversion_rate,
                                             currency_conversion_type,
                                             minimum_accountable_unit,
                                             precision,
                                             legal_entity_id,
                                             rounding_ship_to_party_id,
                                             rounding_ship_from_party_id,
                                             rounding_bill_to_party_id,
                                             rounding_bill_from_party_id,
                                             rndg_ship_to_party_site_id,
                                             rndg_ship_from_party_site_id,
                                             rndg_bill_to_party_site_id,
                                             rndg_bill_from_party_site_id,
                                             establishment_id,
                                             receivables_trx_type_id,
                                             --p_related_doc_application_id,
                                             --p_related_doc_entity_code,
                                             --p_related_doc_evt_class_code,  --reduced size p_related_doc_event_class_code
                                             --p_related_doc_trx_id,
                                             --p_rel_doc_hdr_trx_user_key1,
                                             --p_rel_doc_hdr_trx_user_key2,
                                             --p_rel_doc_hdr_trx_user_key3,
                                             --p_rel_doc_hdr_trx_user_key4,
                                             --p_rel_doc_hdr_trx_user_key5,
                                             --p_rel_doc_hdr_trx_user_key6,
                                             --p_related_doc_number,
                                             --p_related_doc_date,
                                             default_taxation_country,
                                             Quote_Flag,
                                             ctrl_total_hdr_tx_amt,
                                             trx_number,
                                             trx_description,
                                             --p_trx_communicated_date,
                                             --p_batch_source_id,
                                             --p_batch_source_name,
                                             --p_doc_seq_id,
                                             --p_doc_seq_name,
                                             --p_doc_seq_value,
                                             --p_trx_due_date,
                                             --p_trx_type_description,
                                             --p_billing_trad_partner_name,  --reduced size p_billing_trading_partner_name
                                             --p_billing_trad_partner_number,  --reduced size p_billing_trading_partner_number
                                             --p_billing_tp_tax_report_flg,  --reduced size p_Billing_Tp_Tax_Reporting_Flag
                                             --p_billing_tp_taxpayer_id,
                                             document_sub_type,
                                             supplier_tax_invoice_number,
                                             supplier_tax_invoice_date,
                                             supplier_exchange_rate,
                                             tax_invoice_date,
                                             tax_invoice_number,
                                             first_pty_org_id,
                                             PORT_OF_ENTRY_CODE,
                                             TAX_REPORTING_FLAG,
                                             SHIP_TO_CUST_ACCT_SITE_USE_ID,
                                             BILL_TO_CUST_ACCT_SITE_USE_ID,
                                             PROVNL_TAX_DETERMINATION_DATE,
                                             APPLIED_TO_TRX_NUMBER,
                                             SHIP_THIRD_PTY_ACCT_ID,
                                             BILL_THIRD_PTY_ACCT_ID,
                                             SHIP_THIRD_PTY_ACCT_SITE_ID,
                                             BILL_THIRD_PTY_ACCT_SITE_ID,
                                             VALIDATION_CHECK_FLAG,
                                             --p_tax_event_class_code,
                                             tax_event_type_code--p_tax_event_type_code,
                                             --p_doc_event_status,
                                             --p_rdng_ship_to_pty_tx_prof_id,
                                             --p_rdng_ship_fr_pty_tx_prof_id,  --reduced size p_rdng_ship_from_pty_tx_prof_id
                                             --p_rdng_bill_to_pty_tx_prof_id,
                                             --p_rdng_bill_fr_pty_tx_prof_id,  --reduced size p_rdng_bill_from_pty_tx_prof_id
                                             --p_rdng_ship_to_pty_tx_p_st_id,
                                             --p_rdng_ship_fr_pty_tx_p_st_id,  --reduced size p_rdng_ship_from_pty_tx_p_st_id
                                             --p_rdng_bill_to_pty_tx_p_st_id,
                                             --p_rdng_bill_fr_pty_tx_p_st_id);  --reduced size p_rdng_bill_from_pty_tx_p_st_id
                                        FROM ZX_TRANSACTION
                                        WHERE APPLICATION_ID = p_application_id
                                        AND ENTITY_CODE      = p_entity_code
                                        AND EVENT_CLASS_CODE = p_event_class_code
                                        AND TRX_ID           = p_trx_id;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_SIM_TRX_DISTRIBUTION.Insert_Temporary_Table',
                     'Insert into zx_trx_headers_gt (-)');
    END IF;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_SIM_TRX_DISTRIBUTION.Insert_Temporary_Tables',
                     'Insert into ZX_ITM_DISTRIBUTIONS_GT (+)');
    END IF;

      INSERT INTO ZX_ITM_DISTRIBUTIONS_GT (APPLICATION_ID,
                                           ENTITY_CODE,
                                           EVENT_CLASS_CODE,
                                           --EVENT_TYPE_CODE,
                                           TRX_ID,
                                           HDR_TRX_USER_KEY1,
                                           HDR_TRX_USER_KEY2,
                                           HDR_TRX_USER_KEY3,
                                           HDR_TRX_USER_KEY4,
                                           HDR_TRX_USER_KEY5,
                                           HDR_TRX_USER_KEY6,
                                           TRX_LINE_ID,
                                           LINE_TRX_USER_KEY1,
                                           LINE_TRX_USER_KEY2,
                                           LINE_TRX_USER_KEY3,
                                           LINE_TRX_USER_KEY4,
                                           LINE_TRX_USER_KEY5,
                                           LINE_TRX_USER_KEY6,
                                           TRX_LEVEL_TYPE,
                                           TRX_LINE_DIST_ID,
                                           DIST_TRX_USER_KEY1,
                                           DIST_TRX_USER_KEY2,
                                           DIST_TRX_USER_KEY3,
                                           DIST_TRX_USER_KEY4,
                                           DIST_TRX_USER_KEY5,
                                           DIST_TRX_USER_KEY6,
                                           DIST_LEVEL_ACTION,
                                           TRX_LINE_DIST_DATE,
                                           ITEM_DIST_NUMBER,
                                           DIST_INTENDED_USE,
                                           TAX_INCLUSION_FLAG,
                                           TAX_CODE,
                                           APPLIED_FROM_TAX_DIST_ID,
                                           ADJUSTED_DOC_TAX_DIST_ID,
                                           TASK_ID,
                                           AWARD_ID,
                                           PROJECT_ID,
                                           EXPENDITURE_TYPE,
                                           EXPENDITURE_ORGANIZATION_ID,
                                           EXPENDITURE_ITEM_DATE,
                                           TRX_LINE_DIST_AMT,
                                           TRX_LINE_DIST_QTY,
                                           TRX_LINE_QUANTITY,
                                           ACCOUNT_CCID,
                                           ACCOUNT_STRING,
                                           REF_DOC_APPLICATION_ID,
                                           REF_DOC_ENTITY_CODE,
                                           REF_DOC_EVENT_CLASS_CODE,
                                           REF_DOC_TRX_ID,
                                           REF_DOC_HDR_TRX_USER_KEY1,
                                           REF_DOC_HDR_TRX_USER_KEY2,
                                           REF_DOC_HDR_TRX_USER_KEY3,
                                           REF_DOC_HDR_TRX_USER_KEY4,
                                           REF_DOC_HDR_TRX_USER_KEY5,
                                           REF_DOC_HDR_TRX_USER_KEY6,
                                           REF_DOC_LINE_ID,
                                           REF_DOC_LIN_TRX_USER_KEY1,
                                           REF_DOC_LIN_TRX_USER_KEY2,
                                           REF_DOC_LIN_TRX_USER_KEY3,
                                           REF_DOC_LIN_TRX_USER_KEY4,
                                           REF_DOC_LIN_TRX_USER_KEY5,
                                           REF_DOC_LIN_TRX_USER_KEY6,
                                           REF_DOC_DIST_ID,
                                           REF_DOC_DIST_TRX_USER_KEY1,
                                           REF_DOC_DIST_TRX_USER_KEY2,
                                           REF_DOC_DIST_TRX_USER_KEY3,
                                           REF_DOC_DIST_TRX_USER_KEY4,
                                           REF_DOC_DIST_TRX_USER_KEY5,
                                           REF_DOC_DIST_TRX_USER_KEY6,
                                           REF_DOC_CURR_CONV_RATE,
                                           NUMERIC1,
                                           NUMERIC2,
                                           NUMERIC3,
                                           NUMERIC4,
                                           NUMERIC5,
                                           CHAR1,
                                           CHAR2,
                                           CHAR3,
                                           CHAR4,
                                           CHAR5,
                                           DATE1,
                                           DATE2,
                                           DATE3,
                                           DATE4,
                                           DATE5,
                                           TRX_LINE_DIST_TAX_AMT,
                                           HISTORICAL_FLAG,
                                           APPLIED_FROM_APPLICATION_ID,
                                           APPLIED_FROM_EVENT_CLASS_CODE,
                                           APPLIED_FROM_ENTITY_CODE,
                                           APPLIED_FROM_TRX_ID,
                                           APP_FROM_HDR_TRX_USER_KEY1,
                                           APP_FROM_HDR_TRX_USER_KEY2,
                                           APP_FROM_HDR_TRX_USER_KEY3,
                                           APP_FROM_HDR_TRX_USER_KEY4,
                                           APP_FROM_HDR_TRX_USER_KEY5,
                                           APP_FROM_HDR_TRX_USER_KEY6,
                                           APPLIED_FROM_LINE_ID,
                                           APP_FROM_LIN_TRX_USER_KEY1,
                                           APP_FROM_LIN_TRX_USER_KEY2,
                                           APP_FROM_LIN_TRX_USER_KEY3,
                                           APP_FROM_LIN_TRX_USER_KEY4,
                                           APP_FROM_LIN_TRX_USER_KEY5,
                                           APP_FROM_LIN_TRX_USER_KEY6,
                                           APPLIED_FROM_DIST_ID,
                                           APP_FROM_DST_TRX_USER_KEY1,
                                           APP_FROM_DST_TRX_USER_KEY2,
                                           APP_FROM_DST_TRX_USER_KEY3,
                                           APP_FROM_DST_TRX_USER_KEY4,
                                           APP_FROM_DST_TRX_USER_KEY5,
                                           APP_FROM_DST_TRX_USER_KEY6,
                                           ADJUSTED_DOC_APPLICATION_ID,
                                           ADJUSTED_DOC_EVENT_CLASS_CODE,
                                           ADJUSTED_DOC_ENTITY_CODE,
                                           ADJUSTED_DOC_TRX_ID,
                                           ADJ_DOC_HDR_TRX_USER_KEY1,
                                           ADJ_DOC_HDR_TRX_USER_KEY2,
                                           ADJ_DOC_HDR_TRX_USER_KEY3,
                                           ADJ_DOC_HDR_TRX_USER_KEY4,
                                           ADJ_DOC_HDR_TRX_USER_KEY5,
                                           ADJ_DOC_HDR_TRX_USER_KEY6,
                                           ADJUSTED_DOC_LINE_ID,
                                           ADJ_DOC_LIN_TRX_USER_KEY1,
                                           ADJ_DOC_LIN_TRX_USER_KEY2,
                                           ADJ_DOC_LIN_TRX_USER_KEY3,
                                           ADJ_DOC_LIN_TRX_USER_KEY4,
                                           ADJ_DOC_LIN_TRX_USER_KEY5,
                                           ADJ_DOC_LIN_TRX_USER_KEY6,
                                           ADJUSTED_DOC_DIST_ID,
                                           ADJ_DOC_DST_TRX_USER_KEY1,
                                           ADJ_DOC_DST_TRX_USER_KEY2,
                                           ADJ_DOC_DST_TRX_USER_KEY3,
                                           ADJ_DOC_DST_TRX_USER_KEY4,
                                           ADJ_DOC_DST_TRX_USER_KEY5,
                                           ADJ_DOC_DST_TRX_USER_KEY6,
                                           APPLIED_TO_DOC_CURR_CONV_RATE,
                                           REF_DOC_TRX_LINE_DIST_QTY,
                                           PRICE_DIFF,
                                           UNIT_PRICE,
                                           CURRENCY_EXCHANGE_RATE,
                                           REF_DOC_TRX_LEVEL_TYPE,
                                           APPLIED_FROM_TRX_LEVEL_TYPE,
                                           ADJUSTED_DOC_TRX_LEVEL_TYPE,
                                           OVERRIDING_RECOVERY_RATE,
                                           TAX_VARIANCE_CALC_FLAG)
                                    SELECT application_id,
                                           entity_code,
                                           event_class_code,
                                           --event_type_code,
                                           trx_id,
                                           hdr_trx_user_key1,
                                           hdr_trx_user_key2,
                                           hdr_trx_user_key3,
                                           hdr_trx_user_key4,
                                           hdr_trx_user_key5,
                                           hdr_trx_user_key6,
                                           trx_line_id,
                                           line_trx_user_key1,
                                           line_trx_user_key2,
                                           line_trx_user_key3,
                                           line_trx_user_key4,
                                           line_trx_user_key5,
                                           line_trx_user_key6,
                                           trx_level_type,
                                           trx_line_dist_id,
                                           dist_trx_user_key1,
                                           dist_trx_user_key2,
                                           dist_trx_user_key3,
                                           dist_trx_user_key4,
                                           dist_trx_user_key5,
                                           dist_trx_user_key6,
                                           dist_level_action,
                                           trx_line_dist_date,
                                           item_dist_number,
                                           dist_intended_use,
                                           tax_inclusion_flag,
                                           tax_code,
                                           applied_from_tax_dist_id,
                                           adjusted_doc_tax_dist_id,
                                           task_id,
                                           award_id,
                                           project_id,
                                           expenditure_type,
                                           expenditure_organization_id,
                                           expenditure_item_date,
                                           trx_line_dist_amt,
                                           trx_line_dist_qty,
                                           trx_line_quantity,
                                           account_ccid,
                                           account_string,
                                           ref_doc_application_id,
                                           ref_doc_entity_code,
                                           ref_doc_event_class_code,
                                           ref_doc_trx_id,
                                           ref_doc_hdr_trx_user_key1,
                                           ref_doc_hdr_trx_user_key2,
                                           ref_doc_hdr_trx_user_key3,
                                           ref_doc_hdr_trx_user_key4,
                                           ref_doc_hdr_trx_user_key5,
                                           ref_doc_hdr_trx_user_key6,
                                           ref_doc_line_id,
                                           ref_doc_lin_trx_user_key1,
                                           ref_doc_lin_trx_user_key2,
                                           ref_doc_lin_trx_user_key3,
                                           ref_doc_lin_trx_user_key4,
                                           ref_doc_lin_trx_user_key5,
                                           ref_doc_lin_trx_user_key6,
                                           ref_doc_dist_id,
                                           ref_doc_dist_trx_user_key1,
                                           ref_doc_dist_trx_user_key2,
                                           ref_doc_dist_trx_user_key3,
                                           ref_doc_dist_trx_user_key4,
                                           ref_doc_dist_trx_user_key5,
                                           ref_doc_dist_trx_user_key6,
                                           ref_doc_curr_conv_rate,
                                           numeric1,
                                           numeric2,
                                           numeric3,
                                           numeric4,
                                           numeric5,
                                           char1,
                                           char2,
                                           char3,
                                           char4,
                                           char5,
                                           date1,
                                           date2,
                                           date3,
                                           date4,
                                           date5,
                                           trx_line_dist_tax_amt,
                                           historical_flag,
                                           applied_from_application_id,
                                           applied_from_event_class_code,
                                           applied_from_entity_code,
                                           applied_from_trx_id,
                                           app_from_hdr_trx_user_key1,
                                           app_from_hdr_trx_user_key2,
                                           app_from_hdr_trx_user_key3,
                                           app_from_hdr_trx_user_key4,
                                           app_from_hdr_trx_user_key5,
                                           app_from_hdr_trx_user_key6,
                                           applied_from_line_id,
                                           app_from_lin_trx_user_key1,
                                           app_from_lin_trx_user_key2,
                                           app_from_lin_trx_user_key3,
                                           app_from_lin_trx_user_key4,
                                           app_from_lin_trx_user_key5,
                                           app_from_lin_trx_user_key6,
                                           applied_from_dist_id,
                                           app_from_dst_trx_user_key1,
                                           app_from_dst_trx_user_key2,
                                           app_from_dst_trx_user_key3,
                                           app_from_dst_trx_user_key4,
                                           app_from_dst_trx_user_key5,
                                           app_from_dst_trx_user_key6,
                                           adjusted_doc_application_id,
                                           adjusted_doc_event_class_code,
                                           adjusted_doc_entity_code,
                                           adjusted_doc_trx_id,
                                           adj_doc_hdr_trx_user_key1,
                                           adj_doc_hdr_trx_user_key2,
                                           adj_doc_hdr_trx_user_key3,
                                           adj_doc_hdr_trx_user_key4,
                                           adj_doc_hdr_trx_user_key5,
                                           adj_doc_hdr_trx_user_key6,
                                           adjusted_doc_line_id,
                                           adj_doc_lin_trx_user_key1,
                                           adj_doc_lin_trx_user_key2,
                                           adj_doc_lin_trx_user_key3,
                                           adj_doc_lin_trx_user_key4,
                                           adj_doc_lin_trx_user_key5,
                                           adj_doc_lin_trx_user_key6,
                                           adjusted_doc_dist_id,
                                           adj_doc_dst_trx_user_key1,
                                           adj_doc_dst_trx_user_key2,
                                           adj_doc_dst_trx_user_key3,
                                           adj_doc_dst_trx_user_key4,
                                           adj_doc_dst_trx_user_key5,
                                           adj_doc_dst_trx_user_key6,
                                           applied_to_doc_curr_conv_rate,
                                           REF_DOC_TRX_LINE_DIST_QTY,
                                           PRICE_DIFF,
                                           UNIT_PRICE,
                                           CURRENCY_EXCHANGE_RATE,
                                           REF_DOC_TRX_LEVEL_TYPE,
                                           APPLIED_FROM_TRX_LEVEL_TYPE,
                                           ADJUSTED_DOC_TRX_LEVEL_TYPE,
                                           OVERRIDING_RECOVERY_RATE,
                                           tax_variance_calc_flag
                                      FROM ZX_SIM_TRX_DISTS
                                      WHERE APPLICATION_ID = p_application_id
                                      AND ENTITY_CODE      = p_entity_code
                                      AND EVENT_CLASS_CODE = p_event_class_code
                                      AND TRX_ID           = p_trx_id
                                      AND TRX_LINE_ID      = p_trx_line_id;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_SIM_TRX_DISTRIBUTION.Insert_Temporary_Table',
                     'Insert into ZX_ITM_DISTRIBUTIONS_GT (-)');
    END IF;

    BEGIN

      IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure,
                       'ZX.PLSQL.ZX_SIM_TRX_DISTRIBUTION.Insert_Temporary_Table',
                       'API zx_api_pub.Determine_recovery for Insert_Temporary_Table (+)');
      END IF;

      ZX_API_PUB.Determine_recovery (p_api_version      => 1.0,
                                     p_init_msg_list    => NULL,
                                     p_commit           => NULL,
                                     p_validation_level => NULL,
                                     x_return_status    => l_return_status,
                                     x_msg_count        => l_msg_count,
                                     x_msg_data         => l_msg_data);

      IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure,
                       'ZX.PLSQL.ZX_SIM_TRX_DISTRIBUTION.Insert_Temporary_Table',
                       'API zx_api_pub.Determine_recovery for Insert_Temporary_Table (-)');
      END IF;


      IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure,
                       'ZX.PLSQL.ZX_SIM_TRX_DISTRIBUTION.Insert_Temporary_Table',
                       'Return Status = ' || l_return_status);

        FND_LOG.STRING(g_level_procedure,
                       'ZX.PLSQL.ZX_SIM_TRX_DISTRIBUTION.Insert_Temporary_Table',
                       'Message Count  = ' || l_msg_count);

        FND_LOG.STRING(g_level_procedure,
                       'ZX.PLSQL.ZX_SIM_TRX_DISTRIBUTION.Insert_Temporary_Table',
                       'Message data  = ' || l_msg_data);
      END IF;
    END;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_SIM_TRX_DISTRIBUTION.Insert_Temporary_Table.END',
                     'ZX_SIM_TRX_DISTRIBUTION: Insert_Temporary_Table (-)');
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      p_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

      FND_MESSAGE.SET_NAME('ZX','ZX_UNEXPECTED_ERROR');
      FND_MSG_PUB.Add;

      IF (g_level_unexpected >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_unexpected,
                       'ZX.PLSQL.ZX_SIM_TRX_DISTRIBUTION.Insert_Temporary_Table',
                       p_error_buffer);
      END IF;
  END Insert_Temporary_Table;

  PROCEDURE Update_Transaction_Lines
       (p_application_id               NUMBER,
        p_entity_code                  VARCHAR2,
        p_event_class_code             VARCHAR2,
        p_event_type_code              VARCHAR2,
        p_trx_line_id                  NUMBER,
        p_trx_line_dist_id             NUMBER,
        p_trx_id                       NUMBER,
        p_ledger_id                    NUMBER,
        p_reporting_currency_code      VARCHAR2,
        p_currency_conversion_date     DATE,
        p_currency_conversion_type     VARCHAR2,
        p_currency_conversion_rate     NUMBER,
        p_minimum_accountable_unit     NUMBER,
        p_precision                    NUMBER) IS

    l_return_status        VARCHAR2(1000);
    l_msg_count            NUMBER;
    l_msg_data             VARCHAR2(1000);
    sid                    NUMBER;
    p_error_buffer         VARCHAR2(100);
    debug_info             VARCHAR2(100);

  BEGIN

    g_current_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_SIM_TRX_DISTRIBUTION.Update_Transaction_Lines.BEGIN',
                     'ZX_SIM_TRX_DISTRIBUTION: Update_Transaction_Lines (+)');
    END IF;


    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_SIM_TRX_DISTRIBUTION.Update_Transaction_Lines',
                     'Update ZX_ITM_DISTRIBUTIONS_GT (+)');
    END IF;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_SIM_TRX_DISTRIBUTION.Insert_Temporary_Tables',
                     'Insert into zx_trx_headers_gt (+)');
    END IF;

      INSERT INTO ZX_TRX_HEADERS_GT (INTERNAL_ORGANIZATION_ID,
                                             INTERNAL_ORG_LOCATION_ID,
                                             APPLICATION_ID,
                                             ENTITY_CODE,
                                             EVENT_CLASS_CODE,
                                             EVENT_TYPE_CODE,
                                             TRX_ID,
                                             TRX_DATE,
                                             --TRX_DOC_REVISION,
                                             LEDGER_ID,
                                             TRX_CURRENCY_CODE,
                                             CURRENCY_CONVERSION_DATE,
                                             CURRENCY_CONVERSION_RATE,
                                             CURRENCY_CONVERSION_TYPE,
                                             MINIMUM_ACCOUNTABLE_UNIT,
                                             PRECISION,
                                             LEGAL_ENTITY_ID,
                                             ROUNDING_SHIP_TO_PARTY_ID,
                                             ROUNDING_SHIP_FROM_PARTY_ID,
                                             ROUNDING_BILL_TO_PARTY_ID,
                                             ROUNDING_BILL_FROM_PARTY_ID,
                                             RNDG_SHIP_TO_PARTY_SITE_ID,
                                             RNDG_SHIP_FROM_PARTY_SITE_ID,
                                             RNDG_BILL_TO_PARTY_SITE_ID,
                                             RNDG_BILL_FROM_PARTY_SITE_ID,
                                             ESTABLISHMENT_ID,
                                             RECEIVABLES_TRX_TYPE_ID,
                                             --RELATED_DOC_APPLICATION_ID,
                                             --RELATED_DOC_ENTITY_CODE,
                                             --RELATED_DOC_EVENT_CLASS_CODE,
                                             --RELATED_DOC_TRX_ID,
                                             --REL_DOC_HDR_TRX_USER_KEY1,
                                             --REL_DOC_HDR_TRX_USER_KEY2,
                                             --REL_DOC_HDR_TRX_USER_KEY3,
                                             --REL_DOC_HDR_TRX_USER_KEY4,
                                             --REL_DOC_HDR_TRX_USER_KEY5,
                                             --REL_DOC_HDR_TRX_USER_KEY6,
                                             --RELATED_DOC_NUMBER,
                                             --RELATED_DOC_DATE,
                                             DEFAULT_TAXATION_COUNTRY,
                                             Quote_Flag,
                                             CTRL_TOTAL_HDR_TX_AMT,
                                             TRX_NUMBER,
                                             TRX_DESCRIPTION,
                                             --TRX_COMMUNICATED_DATE,
                                             --BATCH_SOURCE_ID,
                                             --BATCH_SOURCE_NAME,
                                             --DOC_SEQ_ID,
                                             --DOC_SEQ_NAME,
                                             --DOC_SEQ_VALUE,
                                             --TRX_DUE_DATE,
                                             --TRX_TYPE_DESCRIPTION,
                                             --BILLING_TRADING_PARTNER_NAME,
                                             --BILLING_TRADING_PARTNER_NUMBER,
                                             --Billing_Tp_Tax_Reporting_Flag,
                                             --BILLING_TP_TAXPAYER_ID,
                                             DOCUMENT_SUB_TYPE,
                                             SUPPLIER_TAX_INVOICE_NUMBER,
                                             SUPPLIER_TAX_INVOICE_DATE,
                                             SUPPLIER_EXCHANGE_RATE,
                                             TAX_INVOICE_DATE,
                                             TAX_INVOICE_NUMBER,
                                             FIRST_PTY_ORG_ID,
                                             PORT_OF_ENTRY_CODE,
                                             TAX_REPORTING_FLAG,
                                             SHIP_TO_CUST_ACCT_SITE_USE_ID,
                                             BILL_TO_CUST_ACCT_SITE_USE_ID,
                                             PROVNL_TAX_DETERMINATION_DATE,
                                             APPLIED_TO_TRX_NUMBER,
                                             SHIP_THIRD_PTY_ACCT_ID,
                                             BILL_THIRD_PTY_ACCT_ID,
                                             SHIP_THIRD_PTY_ACCT_SITE_ID,
                                             BILL_THIRD_PTY_ACCT_SITE_ID,
                                             VALIDATION_CHECK_FLAG,
                                             --TAX_EVENT_CLASS_CODE,
                                             TAX_EVENT_TYPE_CODE
                                             --DOC_EVENT_STATUS,
                                             --RDNG_SHIP_TO_PTY_TX_PROF_ID,
                                             --RDNG_SHIP_FROM_PTY_TX_PROF_ID,
                                             --RDNG_BILL_TO_PTY_TX_PROF_ID,
                                             --RDNG_BILL_FROM_PTY_TX_PROF_ID,
                                             --RDNG_SHIP_TO_PTY_TX_P_ST_ID,
                                             --RDNG_SHIP_FROM_PTY_TX_P_ST_ID,
                                             --RDNG_BILL_TO_PTY_TX_P_ST_ID,
                                             --RDNG_BILL_FROM_PTY_TX_P_ST_ID
                                             )
                                      SELECT internal_organization_id,
                                             internal_org_location_id,
                                             application_id,
                                             entity_code,
                                             event_class_code,
                                             event_type_code,
                                             trx_id,
                                             trx_date,
                                             --p_trx_doc_revision,
                                             ledger_id,
                                             trx_currency_code,
                                             currency_conversion_date,
                                             currency_conversion_rate,
                                             currency_conversion_type,
                                             minimum_accountable_unit,
                                             precision,
                                             legal_entity_id,
                                             rounding_ship_to_party_id,
                                             rounding_ship_from_party_id,
                                             rounding_bill_to_party_id,
                                             rounding_bill_from_party_id,
                                             rndg_ship_to_party_site_id,
                                             rndg_ship_from_party_site_id,
                                             rndg_bill_to_party_site_id,
                                             rndg_bill_from_party_site_id,
                                             establishment_id,
                                             receivables_trx_type_id,
                                             --p_related_doc_application_id,
                                             --p_related_doc_entity_code,
                                             --p_related_doc_evt_class_code,  --reduced size p_related_doc_event_class_code
                                             --p_related_doc_trx_id,
                                             --p_rel_doc_hdr_trx_user_key1,
                                             --p_rel_doc_hdr_trx_user_key2,
                                             --p_rel_doc_hdr_trx_user_key3,
                                             --p_rel_doc_hdr_trx_user_key4,
                                             --p_rel_doc_hdr_trx_user_key5,
                                             --p_rel_doc_hdr_trx_user_key6,
                                             --p_related_doc_number,
                                             --p_related_doc_date,
                                             default_taxation_country,
                                             Quote_Flag,
                                             ctrl_total_hdr_tx_amt,
                                             trx_number,
                                             trx_description,
                                             --p_trx_communicated_date,
                                             --p_batch_source_id,
                                             --p_batch_source_name,
                                             --p_doc_seq_id,
                                             --p_doc_seq_name,
                                             --p_doc_seq_value,
                                             --p_trx_due_date,
                                             --p_trx_type_description,
                                             --p_billing_trad_partner_name,  --reduced size p_billing_trading_partner_name
                                             --p_billing_trad_partner_number,  --reduced size p_billing_trading_partner_number
                                             --p_billing_tp_tax_report_flg,  --reduced size p_Billing_Tp_Tax_Reporting_Flag
                                             --p_billing_tp_taxpayer_id,
                                             document_sub_type,
                                             supplier_tax_invoice_number,
                                             supplier_tax_invoice_date,
                                             supplier_exchange_rate,
                                             tax_invoice_date,
                                             tax_invoice_number,
                                             first_pty_org_id,
                                             PORT_OF_ENTRY_CODE,
                                             TAX_REPORTING_FLAG,
                                             SHIP_TO_CUST_ACCT_SITE_USE_ID,
                                             BILL_TO_CUST_ACCT_SITE_USE_ID,
                                             PROVNL_TAX_DETERMINATION_DATE,
                                             APPLIED_TO_TRX_NUMBER,
                                             SHIP_THIRD_PTY_ACCT_ID,
                                             BILL_THIRD_PTY_ACCT_ID,
                                             SHIP_THIRD_PTY_ACCT_SITE_ID,
                                             BILL_THIRD_PTY_ACCT_SITE_ID,
                                             VALIDATION_CHECK_FLAG,
                                             --p_tax_event_class_code,
                                             tax_event_type_code--p_tax_event_type_code,
                                             --p_doc_event_status,
                                             --p_rdng_ship_to_pty_tx_prof_id,
                                             --p_rdng_ship_fr_pty_tx_prof_id,  --reduced size p_rdng_ship_from_pty_tx_prof_id
                                             --p_rdng_bill_to_pty_tx_prof_id,
                                             --p_rdng_bill_fr_pty_tx_prof_id,  --reduced size p_rdng_bill_from_pty_tx_prof_id
                                             --p_rdng_ship_to_pty_tx_p_st_id,
                                             --p_rdng_ship_fr_pty_tx_p_st_id,  --reduced size p_rdng_ship_from_pty_tx_p_st_id
                                             --p_rdng_bill_to_pty_tx_p_st_id,
                                             --p_rdng_bill_fr_pty_tx_p_st_id);  --reduced size p_rdng_bill_from_pty_tx_p_st_id
                                        FROM ZX_TRANSACTION
                                        WHERE APPLICATION_ID = p_application_id
                                        AND ENTITY_CODE      = p_entity_code
                                        AND EVENT_CLASS_CODE = p_event_class_code
                                        AND TRX_ID           = p_trx_id;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_SIM_TRX_DISTRIBUTION.Insert_Temporary_Table',
                     'Insert into zx_trx_headers_gt (-)');
    END IF;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_SIM_TRX_DISTRIBUTION.Update_Transaction_Lines',
                     'Insert ZX_ITM_DISTRIBUTIONS_GT (+)');
    END IF;

      INSERT INTO ZX_ITM_DISTRIBUTIONS_GT (APPLICATION_ID,
                                           ENTITY_CODE,
                                           EVENT_CLASS_CODE,
                                           --EVENT_TYPE_CODE,
                                           TRX_ID,
                                           HDR_TRX_USER_KEY1,
                                           HDR_TRX_USER_KEY2,
                                           HDR_TRX_USER_KEY3,
                                           HDR_TRX_USER_KEY4,
                                           HDR_TRX_USER_KEY5,
                                           HDR_TRX_USER_KEY6,
                                           TRX_LINE_ID,
                                           LINE_TRX_USER_KEY1,
                                           LINE_TRX_USER_KEY2,
                                           LINE_TRX_USER_KEY3,
                                           LINE_TRX_USER_KEY4,
                                           LINE_TRX_USER_KEY5,
                                           LINE_TRX_USER_KEY6,
                                           TRX_LEVEL_TYPE,
                                           TRX_LINE_DIST_ID,
                                           DIST_TRX_USER_KEY1,
                                           DIST_TRX_USER_KEY2,
                                           DIST_TRX_USER_KEY3,
                                           DIST_TRX_USER_KEY4,
                                           DIST_TRX_USER_KEY5,
                                           DIST_TRX_USER_KEY6,
                                           DIST_LEVEL_ACTION,
                                           TRX_LINE_DIST_DATE,
                                           ITEM_DIST_NUMBER,
                                           DIST_INTENDED_USE,
                                           TAX_INCLUSION_FLAG,
                                           TAX_CODE,
                                           APPLIED_FROM_TAX_DIST_ID,
                                           ADJUSTED_DOC_TAX_DIST_ID,
                                           TASK_ID,
                                           AWARD_ID,
                                           PROJECT_ID,
                                           EXPENDITURE_TYPE,
                                           EXPENDITURE_ORGANIZATION_ID,
                                           EXPENDITURE_ITEM_DATE,
                                           TRX_LINE_DIST_AMT,
                                           TRX_LINE_DIST_QTY,
                                           TRX_LINE_QUANTITY,
                                           ACCOUNT_CCID,
                                           ACCOUNT_STRING,
                                           REF_DOC_APPLICATION_ID,
                                           REF_DOC_ENTITY_CODE,
                                           REF_DOC_EVENT_CLASS_CODE,
                                           REF_DOC_TRX_ID,
                                           REF_DOC_HDR_TRX_USER_KEY1,
                                           REF_DOC_HDR_TRX_USER_KEY2,
                                           REF_DOC_HDR_TRX_USER_KEY3,
                                           REF_DOC_HDR_TRX_USER_KEY4,
                                           REF_DOC_HDR_TRX_USER_KEY5,
                                           REF_DOC_HDR_TRX_USER_KEY6,
                                           REF_DOC_LINE_ID,
                                           REF_DOC_LIN_TRX_USER_KEY1,
                                           REF_DOC_LIN_TRX_USER_KEY2,
                                           REF_DOC_LIN_TRX_USER_KEY3,
                                           REF_DOC_LIN_TRX_USER_KEY4,
                                           REF_DOC_LIN_TRX_USER_KEY5,
                                           REF_DOC_LIN_TRX_USER_KEY6,
                                           REF_DOC_DIST_ID,
                                           REF_DOC_DIST_TRX_USER_KEY1,
                                           REF_DOC_DIST_TRX_USER_KEY2,
                                           REF_DOC_DIST_TRX_USER_KEY3,
                                           REF_DOC_DIST_TRX_USER_KEY4,
                                           REF_DOC_DIST_TRX_USER_KEY5,
                                           REF_DOC_DIST_TRX_USER_KEY6,
                                           REF_DOC_CURR_CONV_RATE,
                                           NUMERIC1,
                                           NUMERIC2,
                                           NUMERIC3,
                                           NUMERIC4,
                                           NUMERIC5,
                                           CHAR1,
                                           CHAR2,
                                           CHAR3,
                                           CHAR4,
                                           CHAR5,
                                           DATE1,
                                           DATE2,
                                           DATE3,
                                           DATE4,
                                           DATE5,
                                           TRX_LINE_DIST_TAX_AMT,
                                           HISTORICAL_FLAG,
                                           APPLIED_FROM_APPLICATION_ID,
                                           APPLIED_FROM_EVENT_CLASS_CODE,
                                           APPLIED_FROM_ENTITY_CODE,
                                           APPLIED_FROM_TRX_ID,
                                           APP_FROM_HDR_TRX_USER_KEY1,
                                           APP_FROM_HDR_TRX_USER_KEY2,
                                           APP_FROM_HDR_TRX_USER_KEY3,
                                           APP_FROM_HDR_TRX_USER_KEY4,
                                           APP_FROM_HDR_TRX_USER_KEY5,
                                           APP_FROM_HDR_TRX_USER_KEY6,
                                           APPLIED_FROM_LINE_ID,
                                           APP_FROM_LIN_TRX_USER_KEY1,
                                           APP_FROM_LIN_TRX_USER_KEY2,
                                           APP_FROM_LIN_TRX_USER_KEY3,
                                           APP_FROM_LIN_TRX_USER_KEY4,
                                           APP_FROM_LIN_TRX_USER_KEY5,
                                           APP_FROM_LIN_TRX_USER_KEY6,
                                           APPLIED_FROM_DIST_ID,
                                           APP_FROM_DST_TRX_USER_KEY1,
                                           APP_FROM_DST_TRX_USER_KEY2,
                                           APP_FROM_DST_TRX_USER_KEY3,
                                           APP_FROM_DST_TRX_USER_KEY4,
                                           APP_FROM_DST_TRX_USER_KEY5,
                                           APP_FROM_DST_TRX_USER_KEY6,
                                           ADJUSTED_DOC_APPLICATION_ID,
                                           ADJUSTED_DOC_EVENT_CLASS_CODE,
                                           ADJUSTED_DOC_ENTITY_CODE,
                                           ADJUSTED_DOC_TRX_ID,
                                           ADJ_DOC_HDR_TRX_USER_KEY1,
                                           ADJ_DOC_HDR_TRX_USER_KEY2,
                                           ADJ_DOC_HDR_TRX_USER_KEY3,
                                           ADJ_DOC_HDR_TRX_USER_KEY4,
                                           ADJ_DOC_HDR_TRX_USER_KEY5,
                                           ADJ_DOC_HDR_TRX_USER_KEY6,
                                           ADJUSTED_DOC_LINE_ID,
                                           ADJ_DOC_LIN_TRX_USER_KEY1,
                                           ADJ_DOC_LIN_TRX_USER_KEY2,
                                           ADJ_DOC_LIN_TRX_USER_KEY3,
                                           ADJ_DOC_LIN_TRX_USER_KEY4,
                                           ADJ_DOC_LIN_TRX_USER_KEY5,
                                           ADJ_DOC_LIN_TRX_USER_KEY6,
                                           ADJUSTED_DOC_DIST_ID,
                                           ADJ_DOC_DST_TRX_USER_KEY1,
                                           ADJ_DOC_DST_TRX_USER_KEY2,
                                           ADJ_DOC_DST_TRX_USER_KEY3,
                                           ADJ_DOC_DST_TRX_USER_KEY4,
                                           ADJ_DOC_DST_TRX_USER_KEY5,
                                           ADJ_DOC_DST_TRX_USER_KEY6,
                                           APPLIED_TO_DOC_CURR_CONV_RATE,
                                           REF_DOC_TRX_LINE_DIST_QTY,
                                           PRICE_DIFF,
                                           UNIT_PRICE,
                                           CURRENCY_EXCHANGE_RATE,
                                           REF_DOC_TRX_LEVEL_TYPE,
                                           APPLIED_FROM_TRX_LEVEL_TYPE,
                                           ADJUSTED_DOC_TRX_LEVEL_TYPE,
                                           OVERRIDING_RECOVERY_RATE,
                                           TAX_VARIANCE_CALC_FLAG)
                                    SELECT application_id,
                                           entity_code,
                                           event_class_code,
                                           --event_type_code,
                                           trx_id,
                                           hdr_trx_user_key1,
                                           hdr_trx_user_key2,
                                           hdr_trx_user_key3,
                                           hdr_trx_user_key4,
                                           hdr_trx_user_key5,
                                           hdr_trx_user_key6,
                                           trx_line_id,
                                           line_trx_user_key1,
                                           line_trx_user_key2,
                                           line_trx_user_key3,
                                           line_trx_user_key4,
                                           line_trx_user_key5,
                                           line_trx_user_key6,
                                           trx_level_type,
                                           trx_line_dist_id,
                                           dist_trx_user_key1,
                                           dist_trx_user_key2,
                                           dist_trx_user_key3,
                                           dist_trx_user_key4,
                                           dist_trx_user_key5,
                                           dist_trx_user_key6,
                                           dist_level_action,
                                           trx_line_dist_date,
                                           item_dist_number,
                                           dist_intended_use,
                                           tax_inclusion_flag,
                                           tax_code,
                                           applied_from_tax_dist_id,
                                           adjusted_doc_tax_dist_id,
                                           task_id,
                                           award_id,
                                           project_id,
                                           expenditure_type,
                                           expenditure_organization_id,
                                           expenditure_item_date,
                                           trx_line_dist_amt,
                                           trx_line_dist_qty,
                                           trx_line_quantity,
                                           account_ccid,
                                           account_string,
                                           ref_doc_application_id,
                                           ref_doc_entity_code,
                                           ref_doc_event_class_code,
                                           ref_doc_trx_id,
                                           ref_doc_hdr_trx_user_key1,
                                           ref_doc_hdr_trx_user_key2,
                                           ref_doc_hdr_trx_user_key3,
                                           ref_doc_hdr_trx_user_key4,
                                           ref_doc_hdr_trx_user_key5,
                                           ref_doc_hdr_trx_user_key6,
                                           ref_doc_line_id,
                                           ref_doc_lin_trx_user_key1,
                                           ref_doc_lin_trx_user_key2,
                                           ref_doc_lin_trx_user_key3,
                                           ref_doc_lin_trx_user_key4,
                                           ref_doc_lin_trx_user_key5,
                                           ref_doc_lin_trx_user_key6,
                                           ref_doc_dist_id,
                                           ref_doc_dist_trx_user_key1,
                                           ref_doc_dist_trx_user_key2,
                                           ref_doc_dist_trx_user_key3,
                                           ref_doc_dist_trx_user_key4,
                                           ref_doc_dist_trx_user_key5,
                                           ref_doc_dist_trx_user_key6,
                                           ref_doc_curr_conv_rate,
                                           numeric1,
                                           numeric2,
                                           numeric3,
                                           numeric4,
                                           numeric5,
                                           char1,
                                           char2,
                                           char3,
                                           char4,
                                           char5,
                                           date1,
                                           date2,
                                           date3,
                                           date4,
                                           date5,
                                           trx_line_dist_tax_amt,
                                           historical_flag,
                                           applied_from_application_id,
                                           applied_from_event_class_code,
                                           applied_from_entity_code,
                                           applied_from_trx_id,
                                           app_from_hdr_trx_user_key1,
                                           app_from_hdr_trx_user_key2,
                                           app_from_hdr_trx_user_key3,
                                           app_from_hdr_trx_user_key4,
                                           app_from_hdr_trx_user_key5,
                                           app_from_hdr_trx_user_key6,
                                           applied_from_line_id,
                                           app_from_lin_trx_user_key1,
                                           app_from_lin_trx_user_key2,
                                           app_from_lin_trx_user_key3,
                                           app_from_lin_trx_user_key4,
                                           app_from_lin_trx_user_key5,
                                           app_from_lin_trx_user_key6,
                                           applied_from_dist_id,
                                           app_from_dst_trx_user_key1,
                                           app_from_dst_trx_user_key2,
                                           app_from_dst_trx_user_key3,
                                           app_from_dst_trx_user_key4,
                                           app_from_dst_trx_user_key5,
                                           app_from_dst_trx_user_key6,
                                           adjusted_doc_application_id,
                                           adjusted_doc_event_class_code,
                                           adjusted_doc_entity_code,
                                           adjusted_doc_trx_id,
                                           adj_doc_hdr_trx_user_key1,
                                           adj_doc_hdr_trx_user_key2,
                                           adj_doc_hdr_trx_user_key3,
                                           adj_doc_hdr_trx_user_key4,
                                           adj_doc_hdr_trx_user_key5,
                                           adj_doc_hdr_trx_user_key6,
                                           adjusted_doc_line_id,
                                           adj_doc_lin_trx_user_key1,
                                           adj_doc_lin_trx_user_key2,
                                           adj_doc_lin_trx_user_key3,
                                           adj_doc_lin_trx_user_key4,
                                           adj_doc_lin_trx_user_key5,
                                           adj_doc_lin_trx_user_key6,
                                           adjusted_doc_dist_id,
                                           adj_doc_dst_trx_user_key1,
                                           adj_doc_dst_trx_user_key2,
                                           adj_doc_dst_trx_user_key3,
                                           adj_doc_dst_trx_user_key4,
                                           adj_doc_dst_trx_user_key5,
                                           adj_doc_dst_trx_user_key6,
                                           applied_to_doc_curr_conv_rate,
                                           REF_DOC_TRX_LINE_DIST_QTY,
                                           PRICE_DIFF,
                                           UNIT_PRICE,
                                           CURRENCY_EXCHANGE_RATE,
                                           REF_DOC_TRX_LEVEL_TYPE,
                                           APPLIED_FROM_TRX_LEVEL_TYPE,
                                           ADJUSTED_DOC_TRX_LEVEL_TYPE,
                                           OVERRIDING_RECOVERY_RATE,
                                           tax_variance_calc_flag
                                      FROM ZX_SIM_TRX_DISTS
                                      WHERE APPLICATION_ID = p_application_id
                                      AND ENTITY_CODE      = p_entity_code
                                      AND EVENT_CLASS_CODE = p_event_class_code
                                      AND TRX_ID           = p_trx_id;

    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_SIM_TRX_DISTRIBUTION.Update_Transaction_Lines',
                     'Insert ZX_ITM_DISTRIBUTIONS_GT (-)');
    END IF;

    BEGIN

      IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure,
                       'ZX.PLSQL.ZX_SIM_TRX_DISTRIBUTION.Update_Temporary_Table',
                       'API zx_api_pub.Determine_recovery for Update_Temporary_Table (+)');
      END IF;


      ZX_API_PUB.Determine_recovery (p_api_version      => 1.0,
                                     p_init_msg_list    => NULL,
                                     p_commit           => NULL,
                                     p_validation_level => NULL,
                                     x_return_status    => l_return_status,
                                     x_msg_count        => l_msg_count,
                                     x_msg_data         => l_msg_data);

      IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure,
                       'ZX.PLSQL.ZX_SIM_TRX_DISTRIBUTION.Update_Temporary_Table',
                       'API zx_api_pub.Determine_recovery for Update_Temporary_Table (-)');
      END IF;


      IF (g_level_procedure >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_procedure,
                       'ZX.PLSQL.ZX_SIM_TRX_DISTRIBUTION.Update_Temporary_Table',
                       'Return Status = ' || l_return_status);

        FND_LOG.STRING(g_level_procedure,
                       'ZX.PLSQL.ZX_SIM_TRX_DISTRIBUTION.Update_Temporary_Table',
                       'Message Count  = ' || l_msg_count);

        FND_LOG.STRING(g_level_procedure,
                       'ZX.PLSQL.ZX_SIM_TRX_DISTRIBUTION.Update_Temporary_Table',
                       'Message data  = ' || l_msg_data);
      END IF;
    END;
    IF (g_level_procedure >= g_current_runtime_level ) THEN
      FND_LOG.STRING(g_level_procedure,
                     'ZX.PLSQL.ZX_SIM_TRX_DISTRIBUTION.Update_Transaction_Lines',
                     'Update ZX_ITM_DISTRIBUTIONS_GT (-)');
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      p_error_buffer  := sqlcode || ': ' || SUBSTR(SQLERRM, 1, 80);

      FND_MESSAGE.SET_NAME('ZX','ZX_UNEXPECTED_ERROR');
      FND_MSG_PUB.Add;

      IF (g_level_unexpected >= g_current_runtime_level ) THEN
        FND_LOG.STRING(g_level_unexpected,
                       'ZX.PLSQL.ZX_SIM_TRX_DISTRIBUTION.Update_Transaction_Lines',
                       p_error_buffer);
      END IF;
  END Update_Transaction_Lines;

END ZX_SIM_TRX_DISTRIBUTION;

/

--------------------------------------------------------
--  DDL for Package Body QP_SECU_CTRL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_SECU_CTRL_PVT" as
/* $Header: QPXSECCB.pls 120.3.12010000.4 2009/04/10 06:49:49 jputta ship $ */

procedure switch(
  err_buff out nocopy varchar2,
  retcode out nocopy number,
  p_security_control in varchar2,
  p_control in varchar2 default g_n
)
is
  l_security_control_prof varchar2(30);
  l_stmt varchar2(20000);
  l_save boolean;
begin
  l_security_control_prof := nvl(fnd_profile.value(g_security_control_prof), g_security_off);

  if (p_security_control = g_security_off and (l_security_control_prof = g_security_on or p_control = g_y)) then
    begin
      l_save := fnd_profile.save(x_name => g_security_control_prof,
                                 x_value => g_security_off,
                                 x_level_name => 'SITE');

      l_stmt :=
        'create or replace view QP_ARCH_SECU_LIST_HDRS_V as
        select
        AB.ROWID ROW_ID,
        AB.CONTEXT,
        AB.ATTRIBUTE1,
        AB.ATTRIBUTE2,
        AB.ATTRIBUTE3,
        AB.ATTRIBUTE4,
        AB.ATTRIBUTE5,
        AB.ATTRIBUTE6,
        AB.ATTRIBUTE7,
        AB.ATTRIBUTE8,
        AB.ATTRIBUTE9,
        AB.ATTRIBUTE10,
        AB.ATTRIBUTE11,
        AB.ATTRIBUTE12,
        AB.ATTRIBUTE13,
        AB.ATTRIBUTE14,
        AB.ATTRIBUTE15,
        AB.CURRENCY_CODE,
        AB.SHIP_METHOD_CODE,
        AB.FREIGHT_TERMS_CODE,
        AB.LIST_HEADER_ID,
        AB.CREATION_DATE,
        AB.START_DATE_ACTIVE,
        AB.END_DATE_ACTIVE,
        AB.AUTOMATIC_FLAG,
        AB.LIST_TYPE_CODE,
        AB.TERMS_ID,
        AB.ROUNDING_FACTOR,
        AB.REQUEST_ID,
        AB.CREATED_BY,
        AB.LAST_UPDATE_DATE,
        AB.LAST_UPDATED_BY,
        AB.LAST_UPDATE_LOGIN,
        AB.PROGRAM_APPLICATION_ID,
        AB.PROGRAM_ID,
        AB.PROGRAM_UPDATE_DATE,
        AB.DISCOUNT_LINES_FLAG,
        AT.NAME,
        AT.DESCRIPTION,
        AB.COMMENTS,
        AB.GSA_INDICATOR,
        AB.PRORATE_FLAG,
        AB.SOURCE_SYSTEM_CODE,
        AT.VERSION_NO,
        AB.ACTIVE_FLAG,
        AB.MOBILE_DOWNLOAD,
        AB.CURRENCY_HEADER_ID,
        AB.PTE_CODE,
        AB.LIST_SOURCE_CODE,
        AB.ORIG_SYSTEM_HEADER_REF,
        AB.GLOBAL_FLAG,
        AB.ORIG_ORG_ID,
        ''Y'' as VIEW_FLAG,
        ''Y'' as UPDATE_FLAG,
        AB.SHAREABLE_FLAG,
        AB.SOLD_TO_ORG_ID,
        AB.LIMIT_EXISTS_FLAG,
        AB.ARCH_PURG_REQUEST_ID
        FROM QP_ARCH_LIST_HEADERS_TL AT, QP_ARCH_LIST_HEADERS_B AB
        where AB.LIST_HEADER_ID = AT.LIST_HEADER_ID
        AND AB.ARCH_PURG_REQUEST_ID = AT.ARCH_PURG_REQUEST_ID
        AND AT.LANGUAGE = userenv(''LANG'')
        AND AB.LIST_TYPE_CODE = ''PRL''';

      execute immediate l_stmt;

      l_stmt :=
        'create or replace view QP_ARCH_SECU_LIST_HDRS_VL as
        select
        AB.ROWID ROW_ID,
        AB.CONTEXT,
        AB.ATTRIBUTE1,
        AB.ATTRIBUTE2,
        AB.ATTRIBUTE3,
        AB.ATTRIBUTE4,
        AB.ATTRIBUTE5,
        AB.ATTRIBUTE6,
        AB.ATTRIBUTE7,
        AB.ATTRIBUTE8,
        AB.ATTRIBUTE9,
        AB.ATTRIBUTE10,
        AB.ATTRIBUTE11,
        AB.ATTRIBUTE12,
        AB.ATTRIBUTE13,
        AB.ATTRIBUTE14,
        AB.ATTRIBUTE15,
        AB.CURRENCY_CODE,
        AB.SHIP_METHOD_CODE,
        AB.FREIGHT_TERMS_CODE,
        AB.LIST_HEADER_ID,
        AB.CREATION_DATE,
        AB.START_DATE_ACTIVE,
        AB.END_DATE_ACTIVE,
        AB.AUTOMATIC_FLAG,
        AB.LIST_TYPE_CODE,
        AB.TERMS_ID,
        AB.ROUNDING_FACTOR,
        AB.REQUEST_ID,
        AB.CREATED_BY,
        AB.LAST_UPDATE_DATE,
        AB.LAST_UPDATED_BY,
        AB.LAST_UPDATE_LOGIN,
        AB.PROGRAM_APPLICATION_ID,
        AB.PROGRAM_ID,
        AB.PROGRAM_UPDATE_DATE,
        AB.DISCOUNT_LINES_FLAG,
        AT.NAME,
        AT.DESCRIPTION,
        AT.VERSION_NO,
        AB.COMMENTS,
        AB.GSA_INDICATOR,
        AB.PRORATE_FLAG,
        AB.SOURCE_SYSTEM_CODE,
        AB.ASK_FOR_FLAG,
        AB.PARENT_LIST_HEADER_ID,
        AB.START_DATE_ACTIVE_FIRST,
        AB.END_DATE_ACTIVE_FIRST,
        AB.ACTIVE_DATE_FIRST_TYPE,
        AB.START_DATE_ACTIVE_SECOND,
        AB.END_DATE_ACTIVE_SECOND,
        AB.ACTIVE_DATE_SECOND_TYPE,
        AB.ACTIVE_FLAG,
        AB.MOBILE_DOWNLOAD,
        AB.CURRENCY_HEADER_ID,
        AB.PTE_CODE,
        AB.LIST_SOURCE_CODE,
        AB.ORIG_SYSTEM_HEADER_REF,
        AB.GLOBAL_FLAG,
        AB.ORIG_ORG_ID,
        ''Y'' as VIEW_FLAG, ''Y'' as UPDATE_FLAG,
        AB.SHAREABLE_FLAG,
        AB.SOLD_TO_ORG_ID,
        AB.LIMIT_EXISTS_FLAG,
        AB.ARCH_PURG_REQUEST_ID
        FROM QP_ARCH_LIST_HEADERS_TL AT, QP_ARCH_LIST_HEADERS_B AB
        where AB.LIST_HEADER_ID = AT.LIST_HEADER_ID
        and AB.ARCH_PURG_REQUEST_ID = AT.ARCH_PURG_REQUEST_ID
        AND AT.LANGUAGE = userenv(''LANG'')';

      execute immediate l_stmt;

      l_stmt :=
        'create or replace view QP_SECU_LIST_HEADERS_V as
        select
        B.ROWID ROW_ID,
        B.CONTEXT,
        B.ATTRIBUTE1,
        B.ATTRIBUTE2,
        B.ATTRIBUTE3,
        B.ATTRIBUTE4,
        B.ATTRIBUTE5,
        B.ATTRIBUTE6,
        B.ATTRIBUTE7,
        B.ATTRIBUTE8,
        B.ATTRIBUTE9,
        B.ATTRIBUTE10,
        B.ATTRIBUTE11,
        B.ATTRIBUTE12,
        B.ATTRIBUTE13,
        B.ATTRIBUTE14,
        B.ATTRIBUTE15,
        B.CURRENCY_CODE,
        B.SHIP_METHOD_CODE,
        B.FREIGHT_TERMS_CODE,
        B.LIST_HEADER_ID,
        B.CREATION_DATE,
        B.START_DATE_ACTIVE,
        B.END_DATE_ACTIVE,
        B.AUTOMATIC_FLAG,
        B.LIST_TYPE_CODE,
        B.TERMS_ID,
        B.ROUNDING_FACTOR,
        B.REQUEST_ID,
        B.CREATED_BY,
        B.LAST_UPDATE_DATE,
        B.LAST_UPDATED_BY,
        B.LAST_UPDATE_LOGIN,
        B.PROGRAM_APPLICATION_ID,
        B.PROGRAM_ID,
        B.PROGRAM_UPDATE_DATE,
        B.DISCOUNT_LINES_FLAG,
        T.NAME,
        T.DESCRIPTION,
        B.COMMENTS,
        B.GSA_INDICATOR,
        B.PRORATE_FLAG,
        B.SOURCE_SYSTEM_CODE,
        T.VERSION_NO, B.ACTIVE_FLAG,
        B.MOBILE_DOWNLOAD,
        B.CURRENCY_HEADER_ID,
        B.PTE_CODE,
        B.LIST_SOURCE_CODE,
        B.ORIG_SYSTEM_HEADER_REF,
        B.GLOBAL_FLAG,
        B.ORIG_ORG_ID,
        ''Y'' as VIEW_FLAG,
        ''Y'' as UPDATE_FLAG,
        B.SHAREABLE_FLAG,
        B.SOLD_TO_ORG_ID,
        B.LIMIT_EXISTS_FLAG,
        B.LOCKED_FROM_LIST_HEADER_ID
        FROM QP_LIST_HEADERS_ALL_B B, QP_LIST_HEADERS_TL T
        where B.LIST_HEADER_ID = T.LIST_HEADER_ID
        AND T.LANGUAGE = userenv(''LANG'')
        AND B.LIST_TYPE_CODE = ''PRL''';

      execute immediate l_stmt;

      l_stmt :=
        'create or replace view QP_SECU_LIST_HEADERS_VL as
        select
        B.ROWID ROW_ID,
        B.CONTEXT,
        B.ATTRIBUTE1,
        B.ATTRIBUTE2,
        B.ATTRIBUTE3,
        B.ATTRIBUTE4,
        B.ATTRIBUTE5,
        B.ATTRIBUTE6,
        B.ATTRIBUTE7,
        B.ATTRIBUTE8,
        B.ATTRIBUTE9,
        B.ATTRIBUTE10,
        B.ATTRIBUTE11,
        B.ATTRIBUTE12,
        B.ATTRIBUTE13,
        B.ATTRIBUTE14,
        B.ATTRIBUTE15,
        B.CURRENCY_CODE,
        B.SHIP_METHOD_CODE,
        B.FREIGHT_TERMS_CODE,
        B.LIST_HEADER_ID,
        B.CREATION_DATE,
        B.START_DATE_ACTIVE,
        B.END_DATE_ACTIVE,
        B.AUTOMATIC_FLAG,
        B.LIST_TYPE_CODE,
        B.TERMS_ID,
        B.ROUNDING_FACTOR,
        B.REQUEST_ID,
        B.CREATED_BY,
        B.LAST_UPDATE_DATE,
        B.LAST_UPDATED_BY,
        B.LAST_UPDATE_LOGIN,
        B.PROGRAM_APPLICATION_ID,
        B.PROGRAM_ID,
        B.PROGRAM_UPDATE_DATE,
        B.DISCOUNT_LINES_FLAG,
        T.NAME,
        T.DESCRIPTION,
        T.VERSION_NO,
        B.COMMENTS,
        B.GSA_INDICATOR,
        B.PRORATE_FLAG,
        B.SOURCE_SYSTEM_CODE,
        B.ASK_FOR_FLAG,
        B.PARENT_LIST_HEADER_ID,
        B.START_DATE_ACTIVE_FIRST,
        B.END_DATE_ACTIVE_FIRST,
        B.ACTIVE_DATE_FIRST_TYPE,
        B.START_DATE_ACTIVE_SECOND,
        B.END_DATE_ACTIVE_SECOND,
        B.ACTIVE_DATE_SECOND_TYPE,
        B.ACTIVE_FLAG,
        B.MOBILE_DOWNLOAD,
        B.CURRENCY_HEADER_ID,
        B.PTE_CODE,
        B.LIST_SOURCE_CODE,
        B.ORIG_SYSTEM_HEADER_REF,
        B.GLOBAL_FLAG,
        B.ORIG_ORG_ID,
        ''Y'' as VIEW_FLAG,
        ''Y'' as UPDATE_FLAG,
        B.SHAREABLE_FLAG,
        B.SOLD_TO_ORG_ID,
        B.LIMIT_EXISTS_FLAG,
        B.LOCKED_FROM_LIST_HEADER_ID
        FROM QP_LIST_HEADERS_ALL_B B, QP_LIST_HEADERS_TL T
        where B.LIST_HEADER_ID = T.LIST_HEADER_ID
        and T.LANGUAGE = userenv(''LANG'')';

      execute immediate l_stmt;
      commit;

    exception
      when others then
        err_buff := sqlerrm;
        retcode := 2;
      end;

  elsif (p_security_control = g_security_on and (l_security_control_prof = g_security_off or p_control = g_y)) then
    begin
      l_save := fnd_profile.save(x_name => g_security_control_prof,
                                 x_value => g_security_on,
                                 x_level_name => 'SITE');

      l_stmt :=
        'create or replace view QP_ARCH_SECU_LIST_HDRS_V as
        SELECT /*+ leading(update_v) */ AB.ROWID ROW_ID,
        AB.CONTEXT,
        AB.ATTRIBUTE1,
        AB.ATTRIBUTE2,
        AB.ATTRIBUTE3,
        AB.ATTRIBUTE4,
        AB.ATTRIBUTE5,
        AB.ATTRIBUTE6,
        AB.ATTRIBUTE7,
        AB.ATTRIBUTE8,
        AB.ATTRIBUTE9,
        AB.ATTRIBUTE10,
        AB.ATTRIBUTE11,
        AB.ATTRIBUTE12,
        AB.ATTRIBUTE13,
        AB.ATTRIBUTE14,
        AB.ATTRIBUTE15,
        AB.CURRENCY_CODE,
        AB.SHIP_METHOD_CODE,
        AB.FREIGHT_TERMS_CODE,
        AB.LIST_HEADER_ID,
        AB.CREATION_DATE,
        AB.START_DATE_ACTIVE,
        AB.END_DATE_ACTIVE,
        AB.AUTOMATIC_FLAG,
        AB.LIST_TYPE_CODE,
        AB.TERMS_ID,
        AB.ROUNDING_FACTOR,
        AB.REQUEST_ID,
        AB.CREATED_BY,
        AB.LAST_UPDATE_DATE,
        AB.LAST_UPDATED_BY,
        AB.LAST_UPDATE_LOGIN,
        AB.PROGRAM_APPLICATION_ID,
        AB.PROGRAM_ID,
        AB.PROGRAM_UPDATE_DATE,
        AB.DISCOUNT_LINES_FLAG,
        AT.NAME,
        AT.DESCRIPTION,
        AB.COMMENTS,
        AB.GSA_INDICATOR,
        AB.PRORATE_FLAG,
        AB.SOURCE_SYSTEM_CODE,
        AT.VERSION_NO,
        AB.ACTIVE_FLAG,
        AB.MOBILE_DOWNLOAD,
        AB.CURRENCY_HEADER_ID,
        AB.PTE_CODE,
        AB.LIST_SOURCE_CODE,
        AB.ORIG_SYSTEM_HEADER_REF,
        AB.GLOBAL_FLAG,
        AB.ORIG_ORG_ID,
        ''Y'' as VIEW_FLAG,
        ''Y'' as UPDATE_FLAG,
        AB.SHAREABLE_FLAG,
        AB.SOLD_TO_ORG_ID,
        AB.LIMIT_EXISTS_FLAG,
        AB.ARCH_PURG_REQUEST_ID
        FROM QP_ARCH_LIST_HEADERS_TL AT, QP_ARCH_LIST_HEADERS_B AB,
        (select distinct instance_pk1_value from TABLE(CAST(qp_security.auth_instances(''QP_SECU_UPDATE'') as "SYSTEM".qp_inst_pk_vals))) UPDATE_V
        WHERE AB.LIST_HEADER_ID = AT.LIST_HEADER_ID
        and AB.ARCH_PURG_REQUEST_ID = AT.ARCH_PURG_REQUEST_ID
        AND AT.LANGUAGE = userenv(''LANG'')
        AND AB.LIST_TYPE_CODE = ''PRL''
        AND AB.LIST_HEADER_ID = UPDATE_V.INSTANCE_PK1_VALUE
        UNION ALL
        SELECT /*+ leading(view_v) */ AB.ROWID,
        AB.CONTEXT,
        AB.ATTRIBUTE1,
        AB.ATTRIBUTE2,
        AB.ATTRIBUTE3,
        AB.ATTRIBUTE4,
        AB.ATTRIBUTE5,
        AB.ATTRIBUTE6,
        AB.ATTRIBUTE7,
        AB.ATTRIBUTE8,
        AB.ATTRIBUTE9,
        AB.ATTRIBUTE10,
        AB.ATTRIBUTE11,
        AB.ATTRIBUTE12,
        AB.ATTRIBUTE13,
        AB.ATTRIBUTE14,
        AB.ATTRIBUTE15,
        AB.CURRENCY_CODE,
        AB.SHIP_METHOD_CODE,
        AB.FREIGHT_TERMS_CODE,
        AB.LIST_HEADER_ID,
        AB.CREATION_DATE,
        AB.START_DATE_ACTIVE,
        AB.END_DATE_ACTIVE,
        AB.AUTOMATIC_FLAG,
        AB.LIST_TYPE_CODE,
        AB.TERMS_ID,
        AB.ROUNDING_FACTOR,
        AB.REQUEST_ID,
        AB.CREATED_BY,
        AB.LAST_UPDATE_DATE,
        AB.LAST_UPDATED_BY,
        AB.LAST_UPDATE_LOGIN,
        AB.PROGRAM_APPLICATION_ID,
        AB.PROGRAM_ID,
        AB.PROGRAM_UPDATE_DATE,
        AB.DISCOUNT_LINES_FLAG,
        AT.NAME,
        AT.DESCRIPTION,
        AB.COMMENTS,
        AB.GSA_INDICATOR,
        AB.PRORATE_FLAG,
        AB.SOURCE_SYSTEM_CODE,
        AT.VERSION_NO,
        AB.ACTIVE_FLAG,
        AB.MOBILE_DOWNLOAD,
        AB.CURRENCY_HEADER_ID,
        AB.PTE_CODE,
        AB.LIST_SOURCE_CODE,
        AB.ORIG_SYSTEM_HEADER_REF,
        AB.GLOBAL_FLAG,
        AB.ORIG_ORG_ID,
        ''Y'' as VIEW_FLAG,
        ''N'' as UPDATE_FLAG,
        AB.SHAREABLE_FLAG,
        AB.SOLD_TO_ORG_ID,
        AB.LIMIT_EXISTS_FLAG,
        AB.ARCH_PURG_REQUEST_ID
        FROM QP_ARCH_LIST_HEADERS_TL AT, QP_ARCH_LIST_HEADERS_B AB,
        (select distinct instance_pk1_value from TABLE(CAST(qp_security.auth_instances(''QP_SECU_VIEW'') as "SYSTEM".qp_inst_pk_vals)) ) VIEW_V,
        (select distinct instance_pk1_value from TABLE(CAST(qp_security.auth_instances(''QP_SECU_UPDATE'') as "SYSTEM".qp_inst_pk_vals))) UPDATE_V
        WHERE AB.LIST_HEADER_ID = AT.LIST_HEADER_ID
        and AB.ARCH_PURG_REQUEST_ID = AT.ARCH_PURG_REQUEST_ID
        AND AT.LANGUAGE = userenv(''LANG'')
        AND AB.LIST_TYPE_CODE = ''PRL''
        AND AB.LIST_HEADER_ID = VIEW_V.INSTANCE_PK1_VALUE
        and AB.LIST_HEADER_ID = update_v.instance_pk1_value (+)
        and update_v.instance_pk1_value IS NULL
        UNION ALL
        SELECT /*+ leading(view_v) */ AB.ROWID,
        AB.CONTEXT,
        AB.ATTRIBUTE1,
        AB.ATTRIBUTE2,
        AB.ATTRIBUTE3,
        AB.ATTRIBUTE4,
        AB.ATTRIBUTE5,
        AB.ATTRIBUTE6,
        AB.ATTRIBUTE7,
        AB.ATTRIBUTE8,
        AB.ATTRIBUTE9,
        AB.ATTRIBUTE10,
        AB.ATTRIBUTE11,
        AB.ATTRIBUTE12,
        AB.ATTRIBUTE13,
        AB.ATTRIBUTE14,
        AB.ATTRIBUTE15,
        AB.CURRENCY_CODE,
        AB.SHIP_METHOD_CODE,
        AB.FREIGHT_TERMS_CODE,
        AB.LIST_HEADER_ID,
        AB.CREATION_DATE,
        AB.START_DATE_ACTIVE,
        AB.END_DATE_ACTIVE,
        AB.AUTOMATIC_FLAG,
        AB.LIST_TYPE_CODE,
        AB.TERMS_ID,
        AB.ROUNDING_FACTOR,
        AB.REQUEST_ID,
        AB.CREATED_BY,
        AB.LAST_UPDATE_DATE,
        AB.LAST_UPDATED_BY,
        AB.LAST_UPDATE_LOGIN,
        AB.PROGRAM_APPLICATION_ID,
        AB.PROGRAM_ID,
        AB.PROGRAM_UPDATE_DATE,
        AB.DISCOUNT_LINES_FLAG,
        AT.NAME,
        AT.DESCRIPTION,
        AB.COMMENTS,
        AB.GSA_INDICATOR,
        AB.PRORATE_FLAG,
        AB.SOURCE_SYSTEM_CODE,
        AT.VERSION_NO,
        AB.ACTIVE_FLAG,
        AB.MOBILE_DOWNLOAD,
        AB.CURRENCY_HEADER_ID,
        AB.PTE_CODE,
        AB.LIST_SOURCE_CODE,
        AB.ORIG_SYSTEM_HEADER_REF,
        AB.GLOBAL_FLAG,
        AB.ORIG_ORG_ID,
        ''N'' as VIEW_FLAG,
        ''N'' as UPDATE_FLAG,
        AB.SHAREABLE_FLAG,
        AB.SOLD_TO_ORG_ID,
        AB.LIMIT_EXISTS_FLAG,
        AB.ARCH_PURG_REQUEST_ID
        FROM QP_ARCH_LIST_HEADERS_TL AT, QP_ARCH_LIST_HEADERS_B AB,
        (select distinct instance_pk1_value from TABLE(CAST(qp_security.auth_instances(''QP_SECU_VIEW'') as "SYSTEM".qp_inst_pk_vals)) ) VIEW_V
        WHERE AB.LIST_HEADER_ID = AT.LIST_HEADER_ID
        and AB.ARCH_PURG_REQUEST_ID = AT.ARCH_PURG_REQUEST_ID
        AND AT.LANGUAGE = userenv(''LANG'')
        AND AB.LIST_TYPE_CODE = ''PRL''
        AND AB.LIST_HEADER_ID = VIEW_V.instance_pk1_value(+)
        and VIEW_V.instance_pk1_value IS NULL';

      execute immediate l_stmt;

      l_stmt :=
        'create or replace view QP_ARCH_SECU_LIST_HDRS_VL as
        SELECT /*+ leading(update_v) */ AB.ROWID ROW_ID,
        AB.CONTEXT,
        AB.ATTRIBUTE1,
        AB.ATTRIBUTE2,
        AB.ATTRIBUTE3,
        AB.ATTRIBUTE4,
        AB.ATTRIBUTE5,
        AB.ATTRIBUTE6,
        AB.ATTRIBUTE7,
        AB.ATTRIBUTE8,
        AB.ATTRIBUTE9,
        AB.ATTRIBUTE10,
        AB.ATTRIBUTE11,
        AB.ATTRIBUTE12,
        AB.ATTRIBUTE13,
        AB.ATTRIBUTE14,
        AB.ATTRIBUTE15,
        AB.CURRENCY_CODE,
        AB.SHIP_METHOD_CODE,
        AB.FREIGHT_TERMS_CODE,
        AB.LIST_HEADER_ID,
        AB.CREATION_DATE,
        AB.START_DATE_ACTIVE,
        AB.END_DATE_ACTIVE,
        AB.AUTOMATIC_FLAG,
        AB.LIST_TYPE_CODE,
        AB.TERMS_ID,
        AB.ROUNDING_FACTOR,
        AB.REQUEST_ID,
        AB.CREATED_BY,
        AB.LAST_UPDATE_DATE,
        AB.LAST_UPDATED_BY,
        AB.LAST_UPDATE_LOGIN,
        AB.PROGRAM_APPLICATION_ID,
        AB.PROGRAM_ID,
        AB.PROGRAM_UPDATE_DATE,
        AB.DISCOUNT_LINES_FLAG,
        AT.NAME,
        AT.DESCRIPTION,
        AT.VERSION_NO,
        AB.COMMENTS,
        AB.GSA_INDICATOR,
        AB.PRORATE_FLAG,
        AB.SOURCE_SYSTEM_CODE,
        AB.ASK_FOR_FLAG,
        AB.PARENT_LIST_HEADER_ID,
        AB.START_DATE_ACTIVE_FIRST,
        AB.END_DATE_ACTIVE_FIRST,
        AB.ACTIVE_DATE_FIRST_TYPE,
        AB.START_DATE_ACTIVE_SECOND,
        AB.END_DATE_ACTIVE_SECOND,
        AB.ACTIVE_DATE_SECOND_TYPE,
        AB.ACTIVE_FLAG,
        AB.MOBILE_DOWNLOAD,
        AB.CURRENCY_HEADER_ID,
        AB.PTE_CODE,
        AB.LIST_SOURCE_CODE,
        AB.ORIG_SYSTEM_HEADER_REF,
        AB.GLOBAL_FLAG,
        AB.ORIG_ORG_ID,
        ''Y'' as VIEW_FLAG,
        ''Y'' as UPDATE_FLAG,
        AB.SHAREABLE_FLAG,
        AB.SOLD_TO_ORG_ID,
        AB.LIMIT_EXISTS_FLAG,
        AB.ARCH_PURG_REQUEST_ID
        FROM QP_ARCH_LIST_HEADERS_TL AT, QP_ARCH_LIST_HEADERS_B AB,
        (select distinct instance_pk1_value from TABLE(CAST(qp_security.auth_instances(''QP_SECU_UPDATE'') as "SYSTEM". qp_inst_pk_vals))) UPDATE_V
        WHERE AB.LIST_HEADER_ID = AT.LIST_HEADER_ID
        and AB.ARCH_PURG_REQUEST_ID = AT.ARCH_PURG_REQUEST_ID
        AND AT.LANGUAGE = userenv(''LANG'')
        and AB.LIST_HEADER_ID = UPDATE_V.INSTANCE_PK1_VALUE
        UNION ALL
        SELECT /*+ leading(view_v) */ AB.ROWID ROW_ID,
        AB.CONTEXT,
        AB.ATTRIBUTE1,
        AB.ATTRIBUTE2,
        AB.ATTRIBUTE3,
        AB.ATTRIBUTE4,
        AB.ATTRIBUTE5,
        AB.ATTRIBUTE6,
        AB.ATTRIBUTE7,
        AB.ATTRIBUTE8,
        AB.ATTRIBUTE9,
        AB.ATTRIBUTE10,
        AB.ATTRIBUTE11,
        AB.ATTRIBUTE12,
        AB.ATTRIBUTE13,
        AB.ATTRIBUTE14,
        AB.ATTRIBUTE15,
        AB.CURRENCY_CODE,
        AB.SHIP_METHOD_CODE,
        AB.FREIGHT_TERMS_CODE,
        AB.LIST_HEADER_ID,
        AB.CREATION_DATE,
        AB.START_DATE_ACTIVE,
        AB.END_DATE_ACTIVE,
        AB.AUTOMATIC_FLAG,
        AB.LIST_TYPE_CODE,
        AB.TERMS_ID,
        AB.ROUNDING_FACTOR,
        AB.REQUEST_ID,
        AB.CREATED_BY,
        AB.LAST_UPDATE_DATE,
        AB.LAST_UPDATED_BY,
        AB.LAST_UPDATE_LOGIN,
        AB.PROGRAM_APPLICATION_ID,
        AB.PROGRAM_ID,
        AB.PROGRAM_UPDATE_DATE,
        AB.DISCOUNT_LINES_FLAG,
        AT.NAME,
        AT.DESCRIPTION,
        AT.VERSION_NO,
        AB.COMMENTS,
        AB.GSA_INDICATOR,
        AB.PRORATE_FLAG,
        AB.SOURCE_SYSTEM_CODE,
        AB.ASK_FOR_FLAG,
        AB.PARENT_LIST_HEADER_ID,
        AB.START_DATE_ACTIVE_FIRST,
        AB.END_DATE_ACTIVE_FIRST,
        AB.ACTIVE_DATE_FIRST_TYPE,
        AB.START_DATE_ACTIVE_SECOND,
        AB.END_DATE_ACTIVE_SECOND,
        AB.ACTIVE_DATE_SECOND_TYPE,
        AB.ACTIVE_FLAG,
        AB.MOBILE_DOWNLOAD,
        AB.CURRENCY_HEADER_ID,
        AB.PTE_CODE,
        AB.LIST_SOURCE_CODE,
        AB.ORIG_SYSTEM_HEADER_REF,
        AB.GLOBAL_FLAG,
        AB.ORIG_ORG_ID,
        ''Y'' as VIEW_FLAG,
        ''N'' as UPDATE_FLAG,
        AB.SHAREABLE_FLAG,
        AB.SOLD_TO_ORG_ID,
        AB.LIMIT_EXISTS_FLAG,
        AB.ARCH_PURG_REQUEST_ID
        FROM QP_ARCH_LIST_HEADERS_TL AT, QP_ARCH_LIST_HEADERS_B AB,
        (select distinct instance_pk1_value from TABLE(CAST(qp_security.auth_instances(''QP_SECU_VIEW'') as "SYSTEM".qp_inst_pk_vals)) ) VIEW_V,
        (select distinct instance_pk1_value from TABLE(CAST(qp_security.auth_instances(''QP_SECU_UPDATE'') as "SYSTEM".qp_inst_pk_vals))) UPDATE_V
        WHERE AB.LIST_HEADER_ID = AT.LIST_HEADER_ID
        and AB.ARCH_PURG_REQUEST_ID = AT.ARCH_PURG_REQUEST_ID
        AND AT.LANGUAGE = userenv(''LANG'')
        and AB.LIST_HEADER_ID = VIEW_V.INSTANCE_PK1_VALUE
        and AB.LIST_HEADER_ID = update_v.instance_pk1_value (+)
        and update_v.instance_pk1_value IS NULL
        UNION ALL
        SELECT /*+ leading(view_v) */ AB.ROWID ROW_ID,
        AB.CONTEXT,
        AB.ATTRIBUTE1,
        AB.ATTRIBUTE2,
        AB.ATTRIBUTE3,
        AB.ATTRIBUTE4,
        AB.ATTRIBUTE5,
        AB.ATTRIBUTE6,
        AB.ATTRIBUTE7,
        AB.ATTRIBUTE8,
        AB.ATTRIBUTE9,
        AB.ATTRIBUTE10,
        AB.ATTRIBUTE11,
        AB.ATTRIBUTE12,
        AB.ATTRIBUTE13,
        AB.ATTRIBUTE14,
        AB.ATTRIBUTE15,
        AB.CURRENCY_CODE,
        AB.SHIP_METHOD_CODE,
        AB.FREIGHT_TERMS_CODE,
        AB.LIST_HEADER_ID,
        AB.CREATION_DATE,
        AB.START_DATE_ACTIVE,
        AB.END_DATE_ACTIVE,
        AB.AUTOMATIC_FLAG,
        AB.LIST_TYPE_CODE,
        AB.TERMS_ID,
        AB.ROUNDING_FACTOR,
        AB.REQUEST_ID,
        AB.CREATED_BY,
        AB.LAST_UPDATE_DATE,
        AB.LAST_UPDATED_BY,
        AB.LAST_UPDATE_LOGIN,
        AB.PROGRAM_APPLICATION_ID,
        AB.PROGRAM_ID,
        AB.PROGRAM_UPDATE_DATE,
        AB.DISCOUNT_LINES_FLAG,
        AT.NAME,
        AT.DESCRIPTION,
        AT.VERSION_NO,
        AB.COMMENTS,
        AB.GSA_INDICATOR,
        AB.PRORATE_FLAG,
        AB.SOURCE_SYSTEM_CODE,
        AB.ASK_FOR_FLAG,
        AB.PARENT_LIST_HEADER_ID,
        AB.START_DATE_ACTIVE_FIRST,
        AB.END_DATE_ACTIVE_FIRST,
        AB.ACTIVE_DATE_FIRST_TYPE,
        AB.START_DATE_ACTIVE_SECOND,
        AB.END_DATE_ACTIVE_SECOND,
        AB.ACTIVE_DATE_SECOND_TYPE,
        AB.ACTIVE_FLAG,
        AB.MOBILE_DOWNLOAD,
        AB.CURRENCY_HEADER_ID,
        AB.PTE_CODE,
        AB.LIST_SOURCE_CODE,
        AB.ORIG_SYSTEM_HEADER_REF,
        AB.GLOBAL_FLAG,
        AB.ORIG_ORG_ID,
        ''N'' as VIEW_FLAG,
        ''N'' as UPDATE_FLAG,
        AB.SHAREABLE_FLAG,
        AB.SOLD_TO_ORG_ID,
        AB.LIMIT_EXISTS_FLAG,
        AB.ARCH_PURG_REQUEST_ID
        FROM QP_ARCH_LIST_HEADERS_TL AT, QP_ARCH_LIST_HEADERS_B AB,
        (select distinct instance_pk1_value from TABLE(CAST(qp_security.auth_instances(''QP_SECU_VIEW'') as "SYSTEM".qp_inst_pk_vals)) ) VIEW_V
        WHERE AB.LIST_HEADER_ID = AT.LIST_HEADER_ID
        and AB.ARCH_PURG_REQUEST_ID = AT.ARCH_PURG_REQUEST_ID
        AND AT.LANGUAGE = userenv(''LANG'')
        and AB.LIST_HEADER_ID = VIEW_V.instance_pk1_value(+)
        and VIEW_V.instance_pk1_value IS NULL';

      execute immediate l_stmt;

      l_stmt :=
        'create or replace view QP_SECU_LIST_HEADERS_V as
        SELECT B.ROWID ROW_ID, B.CONTEXT, B.ATTRIBUTE1
        , B.ATTRIBUTE2, B.ATTRIBUTE3, B.ATTRIBUTE4, B.ATTRIBUTE5, B.ATTRIBUTE6
        , B.ATTRIBUTE7, B.ATTRIBUTE8, B.ATTRIBUTE9, B.ATTRIBUTE10, B.ATTRIBUTE11
        , B.ATTRIBUTE12, B.ATTRIBUTE13, B.ATTRIBUTE14, B.ATTRIBUTE15, B.CURRENCY_CODE
        , B.SHIP_METHOD_CODE, B.FREIGHT_TERMS_CODE, B.LIST_HEADER_ID, B.CREATION_DATE
        , B.START_DATE_ACTIVE, B.END_DATE_ACTIVE, B.AUTOMATIC_FLAG, B.LIST_TYPE_CODE
        , B.TERMS_ID, B.ROUNDING_FACTOR, B.REQUEST_ID, B.CREATED_BY, B.LAST_UPDATE_DATE
        , B.LAST_UPDATED_BY, B.LAST_UPDATE_LOGIN, B.PROGRAM_APPLICATION_ID, B.PROGRAM_ID
        , B.PROGRAM_UPDATE_DATE, B.DISCOUNT_LINES_FLAG, T.NAME, T.DESCRIPTION
        , B.COMMENTS, B.GSA_INDICATOR, B.PRORATE_FLAG, B.SOURCE_SYSTEM_CODE, T.VERSION_NO
        , B.ACTIVE_FLAG, B.MOBILE_DOWNLOAD, B.CURRENCY_HEADER_ID, B.PTE_CODE
        , B.LIST_SOURCE_CODE, B.ORIG_SYSTEM_HEADER_REF, B.GLOBAL_FLAG, B.ORIG_ORG_ID
        , ''Y'' as VIEW_FLAG, QP_SECURITY.GET_UPDATE_ALLOWED (''QP_LIST_HEADERS'', B.list_header_id) as UPDATE_FLAG
        , B.SHAREABLE_FLAG, B.SOLD_TO_ORG_ID, B.LIMIT_EXISTS_FLAG, B.LOCKED_FROM_LIST_HEADER_ID
        FROM (SELECT DISTINCT G.INSTANCE_ID FROM
         QP_GRANTS G WHERE ( (G.GRANTEE_TYPE = ''USER'' AND G.GRANTEE_ID = QP_SECURITY.GET_USER_ID)
        OR (G.GRANTEE_TYPE = ''RESP'' AND G.GRANTEE_ID = QP_SECURITY.GET_RESP_ID)
        OR (G.GRANTEE_TYPE = ''OU'' AND ((MO_GLOBAL.get_access_mode = ''S'' and G.GRANTEE_ID = sys_context(''multi_org2'', ''current_org_id''))
         or (MO_GLOBAL.get_access_mode =''A'') or (MO_GLOBAL.get_access_mode =''M'' and MO_GLOBAL.check_access(G.GRANTEE_ID) = ''Y'')))
        OR (G.GRANTEE_TYPE = ''GLOBAL'' AND G.GRANTEE_ID = -1)) AND nvl (G.END_DATE, SYSDATE) >= SYSDATE
        AND G.START_DATE <= SYSDATE AND ROWNUM > 0) E
        , QP_LIST_HEADERS_ALL_B B, QP_LIST_HEADERS_TL T
        WHERE E.INSTANCE_ID = B.LIST_HEADER_ID
        AND B.LIST_HEADER_ID = T.LIST_HEADER_ID
        AND T.LANGUAGE = userenv(''LANG'')
        AND B.LIST_TYPE_CODE = ''PRL''
        UNION ALL
        SELECT B.ROWID, B.CONTEXT, B.ATTRIBUTE1, B.ATTRIBUTE2, B.ATTRIBUTE3, B.ATTRIBUTE4
        , B.ATTRIBUTE5, B.ATTRIBUTE6, B.ATTRIBUTE7, B.ATTRIBUTE8, B.ATTRIBUTE9, B.ATTRIBUTE10
        , B.ATTRIBUTE11, B.ATTRIBUTE12, B.ATTRIBUTE13, B.ATTRIBUTE14, B.ATTRIBUTE15, B.CURRENCY_CODE
        , B.SHIP_METHOD_CODE, B.FREIGHT_TERMS_CODE, B.LIST_HEADER_ID, B.CREATION_DATE
        , B.START_DATE_ACTIVE, B.END_DATE_ACTIVE, B.AUTOMATIC_FLAG, B.LIST_TYPE_CODE
        , B.TERMS_ID, B.ROUNDING_FACTOR, B.REQUEST_ID, B.CREATED_BY, B.LAST_UPDATE_DATE
        , B.LAST_UPDATED_BY, B.LAST_UPDATE_LOGIN, B.PROGRAM_APPLICATION_ID, B.PROGRAM_ID
        , B.PROGRAM_UPDATE_DATE, B.DISCOUNT_LINES_FLAG, T.NAME, T.DESCRIPTION
        , B.COMMENTS, B.GSA_INDICATOR, B.PRORATE_FLAG, B.SOURCE_SYSTEM_CODE, T.VERSION_NO
        , B.ACTIVE_FLAG, B.MOBILE_DOWNLOAD, B.CURRENCY_HEADER_ID, B.PTE_CODE
        , B.LIST_SOURCE_CODE, B.ORIG_SYSTEM_HEADER_REF, B.GLOBAL_FLAG, B.ORIG_ORG_ID
        , ''Y'' as VIEW_FLAG, QP_SECURITY.GET_UPDATE_ALLOWED (''QP_LIST_HEADERS'', B.list_header_id) as UPDATE_FLAG
        , B.SHAREABLE_FLAG, B.SOLD_TO_ORG_ID, B.LIMIT_EXISTS_FLAG, B.LOCKED_FROM_LIST_HEADER_ID
        FROM QP_POLICY_LIST_HEADERS_V B, QP_LIST_HEADERS_TL T
        WHERE B.list_header_id is not null
        and NOT EXISTS ( SELECT DISTINCT
        G.INSTANCE_ID FROM QP_GRANTS G
        WHERE ((G.GRANTEE_TYPE = ''USER'' AND G.GRANTEE_ID = QP_SECURITY.GET_USER_ID)
        OR (G.GRANTEE_TYPE = ''RESP'' AND G.GRANTEE_ID = QP_SECURITY.GET_RESP_ID)
        OR (G.GRANTEE_TYPE = ''OU'' AND ((MO_GLOBAL.get_access_mode = ''S'' and G.GRANTEE_ID = sys_context(''multi_org2'', ''current_org_id''))
        OR (MO_GLOBAL.get_access_mode =''A'') or (MO_GLOBAL.get_access_mode =''M'' and MO_GLOBAL.check_access(G.GRANTEE_ID) = ''Y'')))
        OR (G.GRANTEE_TYPE = ''GLOBAL'' AND G.GRANTEE_ID = -1))
        AND nvl (G.END_DATE, sysdate) >= SYSDATE AND G.START_DATE <= SYSDATE
	AND b.list_header_id = g.instance_id
        AND ROWNUM > 0) AND B.LIST_HEADER_ID = T.LIST_HEADER_ID
        AND T.LANGUAGE = userenv(''LANG'')
        AND B.LIST_TYPE_CODE = ''PRL''';

      execute immediate l_stmt;

      l_stmt :=
        'create or replace view QP_SECU_LIST_HEADERS_VL as
        SELECT B.ROWID ROW_ID, B.CONTEXT , B.ATTRIBUTE1, B.ATTRIBUTE2, B.ATTRIBUTE3, B.ATTRIBUTE4
        , B.ATTRIBUTE5, B.ATTRIBUTE6, B.ATTRIBUTE7, B.ATTRIBUTE8, B.ATTRIBUTE9, B.ATTRIBUTE10
        , B.ATTRIBUTE11, B.ATTRIBUTE12, B.ATTRIBUTE13, B.ATTRIBUTE14, B.ATTRIBUTE15
        , B.CURRENCY_CODE, B.SHIP_METHOD_CODE, B.FREIGHT_TERMS_CODE, B.LIST_HEADER_ID
        , B.CREATION_DATE, B.START_DATE_ACTIVE, B.END_DATE_ACTIVE, B.AUTOMATIC_FLAG
        , B.LIST_TYPE_CODE, B.TERMS_ID, B.ROUNDING_FACTOR, B.REQUEST_ID, B.CREATED_BY
        , B.LAST_UPDATE_DATE, B.LAST_UPDATED_BY, B.LAST_UPDATE_LOGIN
        , B.PROGRAM_APPLICATION_ID, B.PROGRAM_ID, B.PROGRAM_UPDATE_DATE, B.DISCOUNT_LINES_FLAG
        , T.NAME, T.DESCRIPTION, T.VERSION_NO, B.COMMENTS, B.GSA_INDICATOR, B.PRORATE_FLAG
        , B.SOURCE_SYSTEM_CODE, B.ASK_FOR_FLAG, B.PARENT_LIST_HEADER_ID, B.START_DATE_ACTIVE_FIRST
        , B.END_DATE_ACTIVE_FIRST, B.ACTIVE_DATE_FIRST_TYPE, B.START_DATE_ACTIVE_SECOND
        , B.END_DATE_ACTIVE_SECOND, B.ACTIVE_DATE_SECOND_TYPE, B.ACTIVE_FLAG
        , B.MOBILE_DOWNLOAD, B.CURRENCY_HEADER_ID, B.PTE_CODE
        , B.LIST_SOURCE_CODE, B.ORIG_SYSTEM_HEADER_REF, B.GLOBAL_FLAG
        , B.ORIG_ORG_ID, ''Y'' as VIEW_FLAG
        , qp_security.GET_UPDATE_ALLOWED (''QP_LIST_HEADERS'', B.list_header_id) as UPDATE_FLAG
        , B.SHAREABLE_FLAG, B.SOLD_TO_ORG_ID, B.LIMIT_EXISTS_FLAG
        , B.LOCKED_FROM_LIST_HEADER_ID
        FROM (SELECT DISTINCT G.INSTANCE_ID FROM QP_GRANTS G
        WHERE ((G.GRANTEE_TYPE = ''USER'' AND G.GRANTEE_ID = qp_security.GET_USER_ID)
        OR (G.GRANTEE_TYPE = ''RESP'' AND G.GRANTEE_ID = qp_security.GET_RESP_ID)
        OR (G.GRANTEE_TYPE = ''OU'' AND ((MO_GLOBAL.get_access_mode = ''S'' and G.GRANTEE_ID = sys_context(''multi_org2'', ''current_org_id''))
         or (MO_GLOBAL.get_access_mode =''A'') or (MO_GLOBAL.get_access_mode =''M'' and MO_GLOBAL.check_access(G.GRANTEE_ID) = ''Y'')))
        OR (G.GRANTEE_TYPE = ''GLOBAL'' AND G.GRANTEE_ID = -1))
        AND nvl (G.END_DATE, SYSDATE) >= SYSDATE AND G.START_DATE <= SYSDATE AND ROWNUM > 0) E
        , QP_LIST_HEADERS_ALL_B B, QP_LIST_HEADERS_TL T
        WHERE E.INSTANCE_ID = B.LIST_HEADER_ID AND B.LIST_HEADER_ID = T.LIST_HEADER_ID
        AND T.LANGUAGE = userenv(''LANG'')
        UNION ALL
        SELECT B.ROWID ROW_ID, B.CONTEXT, B.ATTRIBUTE1, B.ATTRIBUTE2, B.ATTRIBUTE3
        , B.ATTRIBUTE4, B.ATTRIBUTE5, B.ATTRIBUTE6, B.ATTRIBUTE7, B.ATTRIBUTE8
        , B.ATTRIBUTE9, B.ATTRIBUTE10, B.ATTRIBUTE11, B.ATTRIBUTE12, B.ATTRIBUTE13
        , B.ATTRIBUTE14, B.ATTRIBUTE15, B.CURRENCY_CODE, B.SHIP_METHOD_CODE, B.FREIGHT_TERMS_CODE
        , B.LIST_HEADER_ID, B.CREATION_DATE, B.START_DATE_ACTIVE, B.END_DATE_ACTIVE
        , B.AUTOMATIC_FLAG, B.LIST_TYPE_CODE, B.TERMS_ID, B.ROUNDING_FACTOR, B.REQUEST_ID
        , B.CREATED_BY, B.LAST_UPDATE_DATE, B.LAST_UPDATED_BY, B.LAST_UPDATE_LOGIN
        , B.PROGRAM_APPLICATION_ID, B.PROGRAM_ID, B.PROGRAM_UPDATE_DATE, B.DISCOUNT_LINES_FLAG
        , T.NAME, T.DESCRIPTION, T.VERSION_NO, B.COMMENTS, B.GSA_INDICATOR, B.PRORATE_FLAG
        , B.SOURCE_SYSTEM_CODE, B.ASK_FOR_FLAG, B.PARENT_LIST_HEADER_ID, B.START_DATE_ACTIVE_FIRST
        , B.END_DATE_ACTIVE_FIRST, B.ACTIVE_DATE_FIRST_TYPE, B.START_DATE_ACTIVE_SECOND
        , B.END_DATE_ACTIVE_SECOND, B.ACTIVE_DATE_SECOND_TYPE, B.ACTIVE_FLAG, B.MOBILE_DOWNLOAD
        , B.CURRENCY_HEADER_ID, B.PTE_CODE, B.LIST_SOURCE_CODE, B.ORIG_SYSTEM_HEADER_REF
        , B.GLOBAL_FLAG, B.ORIG_ORG_ID, ''Y'' as VIEW_FLAG
        , qp_security.GET_UPDATE_ALLOWED (''QP_LIST_HEADERS'', B.list_header_id) as UPDATE_FLAG
        , B.SHAREABLE_FLAG, B.SOLD_TO_ORG_ID, B.LIMIT_EXISTS_FLAG, B.LOCKED_FROM_LIST_HEADER_ID
        FROM QP_POLICY_LIST_HEADERS_VL B, QP_LIST_HEADERS_TL T
        WHERE B.list_header_id is not null
        and NOT EXISTS ( SELECT G.INSTANCE_ID FROM QP_GRANTS G
        WHERE ((G.GRANTEE_TYPE = ''USER'' AND G.GRANTEE_ID = qp_security.GET_USER_ID)
        OR (G.GRANTEE_TYPE = ''RESP'' AND G.GRANTEE_ID = qp_security.GET_RESP_ID)
        OR (G.GRANTEE_TYPE = ''OU'' AND ((MO_GLOBAL.get_access_mode = ''S'' and G.GRANTEE_ID = sys_context(''multi_org2'', ''current_org_id''))
         or (MO_GLOBAL.get_access_mode =''A'') or (MO_GLOBAL.get_access_mode =''M'' and MO_GLOBAL.check_access(G.GRANTEE_ID) = ''Y'')))
        OR (G.GRANTEE_TYPE = ''GLOBAL'' AND G.GRANTEE_ID = -1)) AND nvl (G.END_DATE,SYSDATE) >= SYSDATE
        AND G.START_DATE <= SYSDATE AND B.LIST_HEADER_ID = G.INSTANCE_ID AND ROWNUM > 0) AND B.LIST_HEADER_ID = T.LIST_HEADER_ID
        AND T.LANGUAGE = userenv(''LANG'')';

      execute immediate l_stmt;
      commit;

    exception
      when others then
        err_buff := sqlerrm;
        retcode := 2;
    end;
  end if;

end switch;

end qp_secu_ctrl_pvt;

/

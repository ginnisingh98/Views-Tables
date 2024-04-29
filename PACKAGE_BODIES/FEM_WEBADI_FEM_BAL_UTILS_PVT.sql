--------------------------------------------------------
--  DDL for Package Body FEM_WEBADI_FEM_BAL_UTILS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FEM_WEBADI_FEM_BAL_UTILS_PVT" AS
/* $Header: FEMVADIBALUTILB.pls 120.1.12010000.2 2009/05/18 19:10:23 huli ship $ */

--X_EXEC_MODE    VARCHAR2(10) := NULL;

PROCEDURE UPLOAD_FEM_BALANCES_INTERFACE(
P_DATA_TABLE_NAME                        VARCHAR2,
P_LOAD_METHOD_CODE                       VARCHAR2,
P_BAL_POST_TYPE_CODE                     VARCHAR2,
P_DATASET_CODE                           NUMBER,
P_CAL_PERIOD_ID                          VARCHAR2,
P_CCTR_ORG_DISPLAY_CODE                  VARCHAR2   DEFAULT NULL,
P_CURRENCY_CODE                          VARCHAR2,
P_CURRENCY_TYPE_CODE                     VARCHAR2,
P_SOURCE_SYSTEM_DISPLAY_CODE             VARCHAR2,
P_LEDGER_DISPLAY_CODE                    VARCHAR2,
P_BUDGET_DISPLAY_CODE                    VARCHAR2  DEFAULT NULL,
P_ENCUMBRANCE_TYPE_CODE                  VARCHAR2  DEFAULT NULL,
P_FINANCIAL_ELEM_DISPLAY_CODE            VARCHAR2  DEFAULT NULL,
P_PRODUCT_DISPLAY_CODE                   VARCHAR2  DEFAULT NULL,
P_NATURAL_ACCOUNT_DISPLAY_CODE           VARCHAR2  DEFAULT NULL,
P_CHANNEL_DISPLAY_CODE                   VARCHAR2  DEFAULT NULL,
P_LINE_ITEM_DISPLAY_CODE                 VARCHAR2  DEFAULT NULL,
P_PROJECT_DISPLAY_CODE                   VARCHAR2  DEFAULT NULL,
P_CUSTOMER_DISPLAY_CODE                  VARCHAR2  DEFAULT NULL,
P_ENTITY_DISPLAY_CODE                    VARCHAR2  DEFAULT NULL,
P_INTERCOMPANY_DISPLAY_CODE              VARCHAR2  DEFAULT NULL,
P_TASK_DISPLAY_CODE                      VARCHAR2  DEFAULT NULL,
P_USER_DIM1_DISPLAY_CODE      IN           VARCHAR2  DEFAULT NULL,

P_USER_DIM2_DISPLAY_CODE        IN         VARCHAR2   DEFAULT NULL,
P_USER_DIM3_DISPLAY_CODE        IN         VARCHAR2   DEFAULT NULL,
P_USER_DIM4_DISPLAY_CODE        IN         VARCHAR2   DEFAULT NULL,
P_USER_DIM5_DISPLAY_CODE        IN         VARCHAR2   DEFAULT NULL,
P_USER_DIM6_DISPLAY_CODE        IN         VARCHAR2   DEFAULT NULL,
P_USER_DIM7_DISPLAY_CODE        IN         VARCHAR2   DEFAULT NULL,
P_USER_DIM8_DISPLAY_CODE        IN         VARCHAR2   DEFAULT NULL,
P_USER_DIM9_DISPLAY_CODE        IN         VARCHAR2   DEFAULT NULL,
P_USER_DIM10_DISPLAY_CODE       IN         VARCHAR2   DEFAULT NULL,
P_XTD_BALANCE_E                 IN         NUMBER     DEFAULT NULL,
P_XTD_BALANCE_F                 IN         NUMBER     DEFAULT NULL,
P_YTD_BALANCE_E                 IN         NUMBER     DEFAULT NULL,
P_YTD_BALANCE_F                 IN         NUMBER     DEFAULT NULL,
P_QTD_BALANCE_E                 IN         NUMBER     DEFAULT NULL,
P_QTD_BALANCE_F                 IN         NUMBER     DEFAULT NULL,
P_PTD_DEBIT_BALANCE_E           IN         NUMBER     DEFAULT NULL,
P_PTD_CREDIT_BALANCE_E          IN         NUMBER     DEFAULT NULL,
P_YTD_DEBIT_BALANCE_E           IN         NUMBER     DEFAULT NULL,
P_YTD_CREDIT_BALANCE_E          IN         NUMBER     DEFAULT NULL,
P_ATTR1                         IN         VARCHAR2   DEFAULT NULL,
P_ATTR2                         IN         VARCHAR2   DEFAULT NULL) is

l_posting_req_id number := null;
l_posting_error_code varchar2(30) := null;
l_previous_error_flag varchar2(1) := null;
l_load_set_id  number := 1;
l_cal_period_number number ;
l_cal_period_end_date date;
l_cal_per_dim_grp_display_code varchar2(500);
l_ds_balance_type_code varchar2(20);
l_col_display varchar2(100);
l_ledger_id number;
l_dataset_code number;
x_return_status varchar2(20);
x_msg_count number;
x_msg_data varchar2(100);
--X_EXEC_MODE    VARCHAR2(10) := NULL;
l_EXEC_MODE    VARCHAR2(10) := NULL;

C_MODULE            CONSTANT FND_LOG_MESSAGES.module%TYPE :=
     'fem.plsql.FEM_WEBADI_FEM_BAL_UTILS_PVT.UPLOAD_FEM_BALANCES_INTERFACE';

begin

select date_assign_value into l_cal_period_end_date from fem_cal_periods_attr
where cal_period_id = P_CAL_PERIOD_ID
and attribute_id = (
select a.attribute_id from fem_dim_attributes_b a,fem_dim_attr_versions_b v
where  a.attribute_id = v.attribute_id
and a.attribute_varchar_label = 'CAL_PERIOD_END_DATE'
and v.default_version_flag = 'Y' );

select number_assign_value into l_cal_period_number from FEM_CAL_PERIODS_ATTR
where cal_period_id = P_CAL_PERIOD_ID
and attribute_id = (
select a.attribute_id from fem_dim_attributes_b a,fem_dim_attr_versions_b v
where  a.attribute_id = v.attribute_id
and a.attribute_varchar_label = 'GL_PERIOD_NUM'
and v.default_version_flag = 'Y' );

select dimension_group_display_code into l_cal_per_dim_grp_display_code	from FEM_DIMENSION_GRPS_B
where dimension_group_id = (select dimension_group_id from fem_cal_periods_b where
cal_period_id = P_CAL_PERIOD_ID);

select dim_attribute_varchar_member into l_ds_balance_type_code from FEM_DATASETS_ATTR
where dataset_code = P_DATASET_CODE
and attribute_id = (
select a.attribute_id from fem_dim_attributes_b a, fem_dim_attr_versions_b v
where  a.attribute_id = v.attribute_id
and attribute_varchar_label = 'DATASET_BALANCE_TYPE_CODE'
and v.default_version_flag = 'Y');

-- CHECKING PROPER COMBO FOR DS BALANCE TYPE CODE, BUDGET CODE AND INCUMBRANCE TYPE-------------


if((l_ds_balance_type_code = 'ACTUAL') AND (P_BUDGET_DISPLAY_CODE is not null OR P_ENCUMBRANCE_TYPE_CODE is not null)) then
     FND_MESSAGE.SET_NAME('FEM','FEM_ADI_DS_ERROR');
     APP_EXCEPTION.Raise_Exception ;
end if;
if ((l_ds_balance_type_code = 'BUDGET') AND (P_BUDGET_DISPLAY_CODE is null OR P_ENCUMBRANCE_TYPE_CODE is not null)) then
     FND_MESSAGE.SET_NAME('FEM','FEM_ADI_DS_ERROR');
     APP_EXCEPTION.Raise_Exception ;
end if;
if ((l_ds_balance_type_code = 'ENCUMBRANCE') AND (P_BUDGET_DISPLAY_CODE is not null OR P_ENCUMBRANCE_TYPE_CODE is null)) then
     FND_MESSAGE.SET_NAME('FEM','FEM_ADI_DS_ERROR');
     APP_EXCEPTION.Raise_Exception ;
end if;

----------------- Finding load method code --------------------------

select ledger_id into l_ledger_id from fem_ledgers_b
where ledger_display_code = p_ledger_display_code;

--if(x_exec_mode is null) then

FEM_LOADER_ENG_UTIL_PKG.Get_XGL_Loader_Exec_Mode(1.0,
                                                 fnd_api.g_false,
                                                 fnd_api.g_false,
                                                 fnd_api.g_true,
                                                 x_return_status,
                                                 x_msg_count,
                                                 x_msg_data,
                                                 p_cal_period_id,
                                                 l_ledger_id,
                                                 p_dataset_code,
                                                 --x_exec_mode
                                                 l_exec_mode
                                                 );
--end if;
--------------------------------------------------------------------

insert into fem_bal_interface_t
(LOAD_SET_ID,
LOAD_METHOD_CODE,
BAL_POST_TYPE_CODE,
DS_BALANCE_TYPE_CODE,
CAL_PER_DIM_GRP_DISPLAY_CODE,
CAL_PERIOD_NUMBER,
CAL_PERIOD_END_DATE,
SOURCE_SYSTEM_DISPLAY_CODE,
LEDGER_DISPLAY_CODE,
CURRENCY_CODE,
CURRENCY_TYPE_CODE,
BUDGET_DISPLAY_CODE,
ENCUMBRANCE_TYPE_CODE,
CCTR_ORG_DISPLAY_CODE,
FINANCIAL_ELEM_DISPLAY_CODE,
PRODUCT_DISPLAY_CODE,
NATURAL_ACCOUNT_DISPLAY_CODE,
CHANNEL_DISPLAY_CODE,
LINE_ITEM_DISPLAY_CODE,
PROJECT_DISPLAY_CODE,
CUSTOMER_DISPLAY_CODE,
ENTITY_DISPLAY_CODE,
INTERCOMPANY_DISPLAY_CODE,
TASK_DISPLAY_CODE,
USER_DIM1_DISPLAY_CODE,
USER_DIM2_DISPLAY_CODE,
USER_DIM3_DISPLAY_CODE,
USER_DIM4_DISPLAY_CODE,
USER_DIM5_DISPLAY_CODE,
USER_DIM6_DISPLAY_CODE,
USER_DIM7_DISPLAY_CODE,
USER_DIM8_DISPLAY_CODE,
USER_DIM9_DISPLAY_CODE,
USER_DIM10_DISPLAY_CODE,
XTD_BALANCE_E,
XTD_BALANCE_F,
YTD_BALANCE_E,
YTD_BALANCE_F,
QTD_BALANCE_E,
QTD_BALANCE_F,
PTD_DEBIT_BALANCE_E,
PTD_CREDIT_BALANCE_E,
YTD_DEBIT_BALANCE_E,
YTD_CREDIT_BALANCE_E,
POSTING_REQUEST_ID,
POSTING_ERROR_CODE,
PREVIOUS_ERROR_FLAG)
VALUES(
l_load_set_id,
--x_exec_mode,
l_exec_mode,
P_BAL_POST_TYPE_CODE,
l_ds_balance_type_code,
l_cal_per_dim_grp_display_code,
l_cal_period_number,
l_cal_period_end_date,
P_SOURCE_SYSTEM_DISPLAY_CODE,
P_LEDGER_DISPLAY_CODE,
P_CURRENCY_CODE,
P_CURRENCY_TYPE_CODE,
P_BUDGET_DISPLAY_CODE,
P_ENCUMBRANCE_TYPE_CODE,
P_CCTR_ORG_DISPLAY_CODE,
P_FINANCIAL_ELEM_DISPLAY_CODE,
P_PRODUCT_DISPLAY_CODE,
P_NATURAL_ACCOUNT_DISPLAY_CODE,
P_CHANNEL_DISPLAY_CODE,
P_LINE_ITEM_DISPLAY_CODE,
P_PROJECT_DISPLAY_CODE,
P_CUSTOMER_DISPLAY_CODE,
P_ENTITY_DISPLAY_CODE,
P_INTERCOMPANY_DISPLAY_CODE,
P_TASK_DISPLAY_CODE,
P_USER_DIM1_DISPLAY_CODE,
P_USER_DIM2_DISPLAY_CODE,
P_USER_DIM3_DISPLAY_CODE,
P_USER_DIM4_DISPLAY_CODE,
P_USER_DIM5_DISPLAY_CODE,
P_USER_DIM6_DISPLAY_CODE,
P_USER_DIM7_DISPLAY_CODE,
P_USER_DIM8_DISPLAY_CODE,
P_USER_DIM9_DISPLAY_CODE,
P_USER_DIM10_DISPLAY_CODE,
P_XTD_BALANCE_E,
P_XTD_BALANCE_F,
P_YTD_BALANCE_E,
P_YTD_BALANCE_F,
P_QTD_BALANCE_E,
P_QTD_BALANCE_F,
P_PTD_DEBIT_BALANCE_E,
P_PTD_CREDIT_BALANCE_E,
P_YTD_DEBIT_BALANCE_E,
P_YTD_CREDIT_BALANCE_E,
l_posting_req_id,
l_posting_error_code,
l_previous_error_flag);

 EXCEPTION
 --
  WHEN DUP_VAL_ON_INDEX THEN
     FND_MESSAGE.SET_NAME('FEM','FEM_ADI_DUPLICATE_ROWS');
     APP_EXCEPTION.Raise_Exception ;
  WHEN others THEN
    --IF FND_LOG.level_unexpected >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_unexpected,
        p_module   => C_MODULE,
        p_msg_text => 'Unexpected error: '||SQLERRM);
    --END IF;
    --IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_procedure,
        p_module   => C_MODULE,
        p_msg_text => 'End Procedure');
    --END IF;

END UPLOAD_FEM_BALANCES_INTERFACE;

FUNCTION GET_ENC_TYPE_ID(P_ENC_TYPE_CODE VARCHAR2) RETURN NUMBER
IS
l_enc_type_id number;

BEGIN
if(P_ENC_TYPE_CODE is null) then
  l_enc_type_id := null;
else
 select encumbrance_type_id into l_enc_type_id from FEM_ENCUMBRANCE_TYPES_B where encumbrance_type_code = P_ENC_TYPE_CODE;
end if;
 return l_enc_type_id;

END GET_ENC_TYPE_ID;

FUNCTION GET_BUDGET_ID(P_BUDGET_DISPLAY_CODE VARCHAR2) RETURN NUMBER
IS
l_budget_id number;

BEGIN
if(P_BUDGET_DISPLAY_CODE is null) then
  l_budget_id := null;
else
 select budget_id into l_budget_id from FEM_BUDGETS_B where budget_display_code = P_BUDGET_DISPLAY_CODE;
end if;
 return l_budget_id;

END GET_BUDGET_ID;

PROCEDURE SET_ALL_REQD_COLS(X_ERROR_FLAG OUT NOCOPY VARCHAR2)
IS
l_fem_type varchar2(20);
l_varchar_field varchar2(20);
l_number_field  varchar2(20);
l_date_field    varchar2(20);
l_lov_field     varchar2(20);
l_varchar_req_field varchar2(20);
l_number_req_field  varchar2(20);
l_date_req_field    varchar2(20);
l_lov_req_field     varchar2(20);
l_display_order     number := 1;

BEGIN

begin

 select 'Y' into x_error_flag from dual where exists(
 select fcp.column_name column_name from fem_tab_column_prop fcp
 where fcp.table_name = 'FEM_BALANCES'
 and fcp.column_property_code = 'PROCESSING_KEY'
 and fcp.column_name not in
 ('CREATED_BY_REQUEST_ID',
 'CREATED_BY_OBJECT_ID',
 'LAST_UPDATED_BY_REQUEST_ID',
 'LAST_UPDATED_BY_OBJECT_ID',
 'CREATION_ROW_SEQUENCE',
 'DATASET_CODE',
 'CAL_PERIOD_ID')
 and (not exists (select 1 from fem_tab_columns_b ftc where table_name = 'FEM_BALANCES' and
 ftc.column_name = fcp.column_name) or
 fcp.column_name in(select column_name from fem_tab_columns_b ftc where table_name = 'FEM_BALANCES' and
 ftc.column_name = fcp.column_name and interface_column_name is null))
 UNION
 select column_name from dba_tab_columns M
 where owner = 'FEM' and table_name = 'FEM_BAL_INTERFACE_T'
 and nullable = 'N'  and column_name in (select substr(interface_col_name,3) from
 bne_interface_cols_b where interface_code = 'FEM_BALANCES_INTF')
 and column_name not in ('LOAD_SET_ID','LOAD_METHOD_CODE','BAL_POST_TYPE_CODE',
'DS_BALANCE_TYPE_CODE','CAL_PER_DIM_GRP_DISPLAY_CODE','CAL_PERIOD_NUMBER','CAL_PERIOD_END_DATE',
'XTD_BALANCE_E','XTD_BALANCE_F','YTD_BALANCE_E','YTD_BALANCE_F','QTD_BALANCE_E','QTD_BALANCE_F',
'PTD_DEBIT_BALANCE_E','PTD_CREDIT_BALANCE_E','YTD_DEBIT_BALANCE_E','YTD_CREDIT_BALANCE_E')
 and not exists (SELECT 1 FROM FEM_TAB_COLUMNS_B T WHERE TABLE_NAME = 'FEM_BALANCES' AND T.INTERFACE_COLUMN_NAME = M.COLUMN_NAME));
 exception
   when NO_DATA_FOUND then
   x_error_flag := 'N';
 end;

if(x_error_flag is not null AND x_error_flag = 'Y') then
  return;
else
  x_error_flag := 'N';
end if;

FND_MESSAGE.SET_NAME ('FEM', 'FEM_ADI_USER_HINT_LOV_REQ');
l_lov_req_field := FND_MESSAGE.GET;
FND_MESSAGE.SET_NAME ('FEM', 'FEM_ADI_USER_HINT_LOV');
l_lov_field := FND_MESSAGE.GET;
FND_MESSAGE.SET_NAME ('FEM', 'FEM_ADI_USER_HINT_TEXT_REQ');
l_varchar_req_field := FND_MESSAGE.GET;
FND_MESSAGE.SET_NAME ('FEM', 'FEM_ADI_USER_HINT_TEXT');
l_varchar_field := FND_MESSAGE.GET;
FND_MESSAGE.SET_NAME ('FEM', 'FEM_ADI_USER_HINT_NUMBER_REQ');
l_number_req_field := FND_MESSAGE.GET;
FND_MESSAGE.SET_NAME ('FEM', 'FEM_ADI_USER_HINT_NUMBER');
l_number_field := FND_MESSAGE.GET;
FND_MESSAGE.SET_NAME ('FEM', 'FEM_ADI_USER_HINT_DATE_REQ');
l_date_req_field := FND_MESSAGE.GET;
FND_MESSAGE.SET_NAME ('FEM', 'FEM_ADI_USER_HINT_DATE');
l_date_field := FND_MESSAGE.GET;

--------------------------- Initially setting interface columns ----------------------------------
for interface_cols in
(select table_name,column_name,data_type,nullable from dba_tab_columns
where owner = 'FEM'
and table_name = 'FEM_BAL_INTERFACE_T'
and column_name in (select substr(interface_col_name,3) from
bne_interface_cols_b where interface_code = 'FEM_BALANCES_INTF'))

loop

 begin
  select fem_data_type_code into l_fem_type from fem_tab_columns_b
  where table_name = 'FEM_BALANCES'
  and interface_column_name = interface_cols.column_name;
  exception
   when NO_DATA_FOUND then
   goto end_loop;  ---- Simulating what 'CONTINUE' key word does in c/c++
 end;
  ------------------------------------ Updating BNE_INTERFACE_COLS_TL table -------------------------
  if(l_fem_type <> 'DIMENSION') then

    update bne_interface_cols_tl
    set user_hint = DECODE(interface_cols.DATA_TYPE, 'VARCHAR2',
                  DECODE(interface_cols.nullable, 'N',l_varchar_req_field, l_varchar_field),
                  DECODE(interface_cols.DATA_TYPE, 'NUMBER',
                  DECODE(interface_cols.nullable, 'N',l_number_req_field, l_number_field),
                  DECODE(interface_cols.DATA_TYPE, 'DATE',
                  DECODE(interface_cols.nullable, 'N',l_date_req_field, l_date_field), NULL)))
    where sequence_num = (select sequence_num from bne_interface_cols_b where interface_col_name = 'P_' || interface_cols.column_name
                          and interface_code = 'FEM_BALANCES_INTF')
    and interface_code = 'FEM_BALANCES_INTF'
    and language = userenv('LANG');
  else

    update bne_interface_cols_tl
    set user_hint = DECODE(interface_cols.nullable, 'N',l_lov_req_field, l_lov_field)
    where sequence_num = (select sequence_num from bne_interface_cols_b where interface_col_name = 'P_' || interface_cols.column_name
                          and interface_code = 'FEM_BALANCES_INTF')
    and interface_code = 'FEM_BALANCES_INTF'
    and language = userenv('LANG');
  end if;
  ---------------------------------------------------------------------------------------------------

  ---------------------------------- Updating BNE_INTERFACE_COLS_B ----------------------------------
  if(interface_cols.nullable <> 'N') then
   update bne_interface_cols_b
   set not_null_flag = 'N',
   required_flag = 'N'
   where interface_code = 'FEM_BALANCES_INTF'
   and interface_col_name = 'P_' || interface_cols.column_name;
  else
   update bne_interface_cols_b
   set not_null_flag = 'Y',
   required_flag = 'Y'
   where interface_code = 'FEM_BALANCES_INTF'
   and interface_col_name = 'P_' || interface_cols.column_name;
  end if;
  ---------------------------------------------------------------------------------------------------
  <<end_loop>>
  NULL;       ----- Just writing an executable code
end loop;
------------------------------- Initial interface cols prop setting done --------------------------


----------------------- Setting property for processing key cols ----------------------------------
for key_recs in
(select table_name,column_name,data_type,nullable from dba_tab_columns
where owner = 'FEM'
and table_name = 'FEM_BAL_INTERFACE_T'
and column_name in (select ftc.interface_column_name interface_column_name from fem_tab_columns_b ftc,fem_tab_column_prop fcp
where ftc.table_name = fcp.table_name
and ftc.column_name = fcp.column_name
and ftc.table_name = 'FEM_BALANCES'
and fcp.column_property_code = 'PROCESSING_KEY'
and ftc.column_name not in
('CREATED_BY_REQUEST_ID',
'CREATED_BY_OBJECT_ID',
'LAST_UPDATED_BY_REQUEST_ID',
'LAST_UPDATED_BY_OBJECT_ID',
'CREATION_ROW_SEQUENCE')))

loop

 begin
 select fem_data_type_code into l_fem_type from fem_tab_columns_b
 where table_name = 'FEM_BALANCES'
 and interface_column_name = key_recs.column_name;
 exception
   when NO_DATA_FOUND then
   goto end_last_loop;  ---- Simulating what 'CONTINUE' key word does in c/c++
 end;

  ------------------------------------ Updating BNE_INTERFACE_COLS_TL table -------------------------
  if(l_fem_type <> 'DIMENSION') then

    update bne_interface_cols_tl
    set user_hint = DECODE(key_recs.DATA_TYPE, 'VARCHAR2',l_varchar_req_field,'NUMBER',l_number_req_field,
                   'DATE',l_date_req_field, NULL)
    where sequence_num = (select sequence_num from bne_interface_cols_b where interface_col_name = 'P_' || key_recs.column_name
                          and interface_code = 'FEM_BALANCES_INTF')
    and interface_code = 'FEM_BALANCES_INTF'
    and language = userenv('LANG');

  else
    update bne_interface_cols_tl
    set user_hint = l_lov_req_field
    where sequence_num = (select sequence_num from bne_interface_cols_b where interface_col_name = 'P_' || key_recs.column_name
                          and interface_code = 'FEM_BALANCES_INTF')
    and interface_code = 'FEM_BALANCES_INTF'
    and language = userenv('LANG');

  end if;
---------------------------------------------------------------------------------------------------

---------------------------------- Updating BNE_INTERFACE_COLS_B ----------------------------------
  update bne_interface_cols_b
  set not_null_flag = 'Y',
  required_flag = 'Y'
  where interface_code = 'FEM_BALANCES_INTF'
  and interface_col_name = 'P_'|| key_recs.column_name;
---------------------------------------------------------------------------------------------------
  <<end_last_loop>>
  NULL; -------- Just writing an executable statement
end loop;

---------------------------------------------------------------------------------------------------
------------------------ Setting up the display order again ---------------------------------------

   update bne_interface_cols_b
   set display_order = null
   where interface_code = 'FEM_BALANCES_INTF' and
   sequence_num not in (1,2,3,4,5,9,10,11,12);

   for bne_cols in
   (
   select interface_col_name from bne_interface_cols_vl
   where interface_code = 'FEM_BALANCES_INTF'
   and display_flag = 'Y' and enabled_flag = 'Y'
   and sequence_num not in (1,2,3,4,5,9,10,11,12)
   order by not_null_flag desc,upper(prompt_above)
   )

  loop  -- Starting the loop to update entries one by one

   update bne_interface_cols_b
   set display_order = l_display_order * 10
   where interface_code = 'FEM_BALANCES_INTF'
   and interface_col_name = bne_cols.interface_col_name;

   l_display_order := l_display_order + 1;

  end loop;

  update bne_layout_cols b
  set interface_seq_num = (select sequence_num from bne_interface_cols_b where interface_code = 'FEM_BALANCES_INTF' and display_order = b.sequence_num
  and sequence_num not in (1,2,3,4,5,9,10,11,12))  where layout_code = 'FEM_BALANCES_LAYOUT'
  and block_id =2;
--------------------------------------------------------------------------------------------------

  COMMIT;

END SET_ALL_REQD_COLS;

END FEM_WEBADI_FEM_BAL_UTILS_PVT;

/

--------------------------------------------------------
--  DDL for Package Body FEM_WEBADI_FACT_TAB_UTILS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FEM_WEBADI_FACT_TAB_UTILS_PVT" AS
/* $Header: FEMVADIFCTRUTILB.pls 120.5 2008/02/20 06:48:27 jcliving noship $ */

G_OBJECT_DEFINITION_ID      NUMBER       := NULL;
G_LEDGER_ID                 NUMBER       := FND_PROFILE.Value_Specific('FEM_LEDGER',FND_GLOBAL.USER_ID);
G_OBJECT_ID                 NUMBER       := NULL;
G_ENTER_IN_DIMS             VARCHAR2(1)  := NULL;

PROCEDURE UPLOAD_FACTOR_TABLE1_INTERFACE(
P_RULE_NAME                        VARCHAR2,
P_FOLDER_NAME                      VARCHAR2,
P_RULE_DESCRIPTION                 VARCHAR2,
P_VERSION_NAME                     VARCHAR2,
P_START_DATE                       VARCHAR2,
P_END_DATE                         VARCHAR2,
P_VERSION_DESCRIPTION              VARCHAR2,
P_FACTOR_TYPE                      VARCHAR2,
P_MATCHING_DIM1                    VARCHAR2,
P_HIERARCHY1                       VARCHAR2,
P_HIER1_VER                        VARCHAR2,
P_LEVEL1                           VARCHAR2,
P_HIERARCHY_REL1                   VARCHAR2,
P_MATCHING_DIM2                    VARCHAR2,
P_HIERARCHY2                       VARCHAR2,
P_HIER2_VER                        VARCHAR2,
P_LEVEL2                           VARCHAR2,
P_HIERARCHY_REL2                   VARCHAR2,
P_MATCHING_DIM3                    VARCHAR2,
P_HIERARCHY3                       VARCHAR2,
P_HIER3_VER                        VARCHAR2,
P_LEVEL3                           VARCHAR2,
P_HIERARCHY_REL3                   VARCHAR2,
P_DISTRIBUTION_DIM                 VARCHAR2,
P_FORCE_TO_HUNDRED                 VARCHAR2,
P_OBJECT_ACCESS_CODE               VARCHAR2,
P_MATCHING_DIM1_MEM                VARCHAR2,
P_MATCHING_DIM2_MEM                VARCHAR2,
P_MATCHING_DIM3_MEM                VARCHAR2,
P_DISTRIBUTION_DIM_MEM             VARCHAR2,
P_AMOUNT                           VARCHAR2)
IS

l_user_id               number      := FND_GLOBAL.USER_ID;
l_update_login          number      := FND_GLOBAL.LOGIN_ID;
l_row_num               number      := NULL;
l_parent_row_num        number      := -1;
l_level_num             number      := 0;
l_dimension_member      varchar2(30);
x_err_code              number;
x_num_msg               number;
l_vs_combo_id           number      := FEM_DIMENSION_UTIL_PKG.Local_VS_Combo_ID(G_LEDGER_ID,x_err_code,x_num_msg);
e_invalid_amount        exception;
l_insert_m1             varchar2(1);
l_insert_m2             varchar2(1);
l_insert_m3             varchar2(1);
BEGIN

if(P_AMOUNT = 0) THEN
  raise e_invalid_amount;
end if;
--------------------------------------------------------- PART 1 ------------------------------------------------------------------------------
--- Entering the rule and rule version details in required tables.This block is executed for only once first time the PLSQL API is invoked.
-----------------------------------------------------------------------------------------------------------------------------------------------

POPULATE_RULE_DETAILS(P_RULE_NAME,P_FOLDER_NAME,P_RULE_DESCRIPTION,P_VERSION_NAME,P_START_DATE,P_END_DATE,P_VERSION_DESCRIPTION,l_vs_combo_id,P_OBJECT_ACCESS_CODE);

------------------------------------------------------ PART 1 ENDS ----------------------------------------------------------------------------

--------------------------------------------------------- PART 2 ------------------------------------------------------------------------------
--- Entering data into fem_factor_tables and fem_factor_table_dims. This block is executed for only once first time the PLSQL API is invoked.
-----------------------------------------------------------------------------------------------------------------------------------------------

POPULATE_FACTOR_TABLE_DIMS(P_VERSION_NAME,P_FACTOR_TYPE,P_MATCHING_DIM1,P_HIERARCHY1,P_HIER1_VER,P_LEVEL1,P_HIERARCHY_REL1,P_MATCHING_DIM2,
                           P_HIERARCHY2,P_HIER2_VER,P_LEVEL2,P_HIERARCHY_REL2,P_MATCHING_DIM3,P_HIERARCHY3,P_HIER3_VER,P_LEVEL3,P_HIERARCHY_REL3,P_DISTRIBUTION_DIM,P_FORCE_TO_HUNDRED);

----------------------------------------------------- PART 2 ENDS -----------------------------------------------------------------------------

--------------------------------------------------------- PART 3 ------------------------------------------------------------------------------
--- Entering dimension members and factor value in the fem_factor_table_fctrs.
-----------------------------------------------------------------------------------------------------------------------------------------------

--------------- Entering values for the first matching dimension member. The factor_value will go with distribution dimension as that shall be the leaf dimension member.

select decode((select 'Y' from fem_factor_table_fctrs where object_definition_id = g_object_definition_id and dim_member = p_matching_dim1_mem and level_num =0),'Y','N','Y') into l_insert_m1 from dual;

if(l_insert_m1 = 'Y') then

   select FEM_FACTORS_ROW_NUM_SEQ.NEXTVAL into l_row_num from dual;

   l_dimension_member := p_matching_dim1_mem;

   insert into FEM_FACTOR_TABLE_FCTRS(OBJECT_DEFINITION_ID,ROW_NUM,PARENT_ROW_NUM,LEVEL_NUM,DIM_MEMBER,FACTOR_VALUE,CREATION_DATE,CREATED_BY,LAST_UPDATED_BY,LAST_UPDATE_DATE,
   LAST_UPDATE_LOGIN,OBJECT_VERSION_NUMBER)
   values(G_OBJECT_DEFINITION_ID,l_row_num,l_parent_row_num,l_level_num,l_dimension_member,0,sysdate,l_user_id,l_user_id,sysdate,l_update_login,0);

else
   select row_num into l_row_num from fem_factor_table_fctrs where object_definition_id = g_object_definition_id and dim_member = p_matching_dim1_mem and level_num = 0;
end if;

l_parent_row_num := l_row_num;
l_level_num := l_level_num + 1;

--------------- Entering values for the second matching dimension member. The factor_value will go with distribution dimension as that shall be the leaf dimension member.

if(p_matching_dim2_mem is not NULL AND length(trim(p_matching_dim2_mem)) <> 0) then

select decode((select 'Y' from fem_factor_table_fctrs where object_definition_id = g_object_definition_id and dim_member = p_matching_dim2_mem and level_num = 1 and parent_row_num = l_parent_row_num),'Y','N','Y') into l_insert_m2 from dual;

if(l_insert_m2 = 'Y') then

    select FEM_FACTORS_ROW_NUM_SEQ.NEXTVAL into l_row_num from dual;

    l_dimension_member := p_matching_dim2_mem;

    insert into FEM_FACTOR_TABLE_FCTRS(OBJECT_DEFINITION_ID,ROW_NUM,PARENT_ROW_NUM,LEVEL_NUM,DIM_MEMBER,FACTOR_VALUE,CREATION_DATE,CREATED_BY,LAST_UPDATED_BY,LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,OBJECT_VERSION_NUMBER)
    values(G_OBJECT_DEFINITION_ID,l_row_num,l_parent_row_num,l_level_num,l_dimension_member,0,sysdate,l_user_id,l_user_id,sysdate,l_update_login,0);
else
   select row_num into l_row_num from fem_factor_table_fctrs where object_definition_id = g_object_definition_id and dim_member = p_matching_dim2_mem and level_num = 1 and parent_row_num =   l_parent_row_num;
end if;

l_parent_row_num := l_row_num;
l_level_num := l_level_num + 1;
end if;

--------------- Entering values for the third matching dimension member. The factor_value will go with distribution dimension as that shall be the leaf dimension member.

if(p_matching_dim3_mem is not NULL AND length(trim(p_matching_dim3_mem)) <> 0) then

select decode((select 'Y' from fem_factor_table_fctrs where object_definition_id = g_object_definition_id and dim_member = p_matching_dim3_mem and level_num =2 and parent_row_num = l_parent_row_num),'Y','N','Y') into l_insert_m3 from dual;

if(l_insert_m3 = 'Y') then

    select FEM_FACTORS_ROW_NUM_SEQ.NEXTVAL into l_row_num from dual;

    l_dimension_member := p_matching_dim3_mem;

    insert into FEM_FACTOR_TABLE_FCTRS(OBJECT_DEFINITION_ID,ROW_NUM,PARENT_ROW_NUM,LEVEL_NUM,DIM_MEMBER,FACTOR_VALUE,CREATION_DATE,CREATED_BY,LAST_UPDATED_BY,LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,OBJECT_VERSION_NUMBER)
    values(G_OBJECT_DEFINITION_ID,l_row_num,l_parent_row_num,l_level_num,l_dimension_member,0,sysdate,l_user_id,l_user_id,sysdate,l_update_login,0);
else
   select row_num into l_row_num from fem_factor_table_fctrs where object_definition_id = g_object_definition_id and dim_member = p_matching_dim3_mem and level_num = 2 and parent_row_num =   l_parent_row_num;
end if;

l_parent_row_num := l_row_num;
l_level_num := l_level_num + 1;
end if;

--------------- Entering values for the distribution dimension. The factor_value will go with distribution dimension as that shall be the leaf dimension member.

select FEM_FACTORS_ROW_NUM_SEQ.NEXTVAL into l_row_num from dual;

l_dimension_member := p_distribution_dim_mem;

insert into FEM_FACTOR_TABLE_FCTRS(OBJECT_DEFINITION_ID,ROW_NUM,PARENT_ROW_NUM,LEVEL_NUM,DIM_MEMBER,FACTOR_VALUE,CREATION_DATE,CREATED_BY,LAST_UPDATED_BY,LAST_UPDATE_DATE,
LAST_UPDATE_LOGIN,OBJECT_VERSION_NUMBER)
values(G_OBJECT_DEFINITION_ID,l_row_num,l_parent_row_num,l_level_num,l_dimension_member,p_amount,sysdate,l_user_id,l_user_id,sysdate,l_update_login,0);

--------------------------------------------------------- END PART 3 --------------------------------------------------------------------------
 EXCEPTION
 --
  WHEN DUP_VAL_ON_INDEX THEN
     FND_MESSAGE.SET_NAME('FEM','FEM_ADI_DUPLICATE_ROWS');
     APP_EXCEPTION.Raise_Exception ;
  WHEN e_invalid_amount THEN
     FND_MESSAGE.SET_NAME('FEM','FEM_NO_FACTORS_ENTERED_TXT');
     APP_EXCEPTION.Raise_Exception ;

END UPLOAD_FACTOR_TABLE1_INTERFACE;

PROCEDURE UPLOAD_FACTOR_TABLE2_INTERFACE(
P_RULE_NAME                        VARCHAR2,
P_FOLDER_NAME                      VARCHAR2,
P_RULE_DESCRIPTION                 VARCHAR2,
P_VERSION_NAME                     VARCHAR2,
P_START_DATE                       VARCHAR2,
P_END_DATE                         VARCHAR2,
P_VERSION_DESCRIPTION              VARCHAR2,
P_FACTOR_TYPE                      VARCHAR2,
P_MATCHING_DIM1                    VARCHAR2,
P_HIERARCHY1                       VARCHAR2,
P_HIER1_VER                        VARCHAR2,
P_LEVEL1                           VARCHAR2,
P_HIERARCHY_REL1                   VARCHAR2,
P_MATCHING_DIM2                    VARCHAR2,
P_HIERARCHY2                       VARCHAR2,
P_HIER2_VER                        VARCHAR2,
P_LEVEL2                           VARCHAR2,
P_HIERARCHY_REL2                   VARCHAR2,
P_MATCHING_DIM3                    VARCHAR2,
P_HIERARCHY3                       VARCHAR2,
P_HIER3_VER                        VARCHAR2,
P_LEVEL3                           VARCHAR2,
P_HIERARCHY_REL3                   VARCHAR2,
P_FORCE_TO_HUNDRED                 VARCHAR2,
P_OBJECT_ACCESS_CODE               VARCHAR2,
P_MATCHING_DIM1_MEM                VARCHAR2,
P_MATCHING_DIM2_MEM                VARCHAR2,
P_MATCHING_DIM3_MEM                VARCHAR2,
P_AMOUNT                           VARCHAR2)
IS

l_user_id               number      := FND_GLOBAL.USER_ID;
l_update_login          number      := FND_GLOBAL.LOGIN_ID;
l_row_num               number      := NULL;
l_parent_row_num        number      := -1;
l_level_num             number      := 0;
l_dimension_member      varchar2(30);
l_amount                number      := null;
x_err_code              number;
x_num_msg               number;
l_vs_combo_id           number      := FEM_DIMENSION_UTIL_PKG.Local_VS_Combo_ID(G_LEDGER_ID,x_err_code,x_num_msg);
l_insert_m1             varchar2(1);
l_insert_m2             varchar2(1);
l_insert_m3             varchar2(1);

e_invalid_amount        exception;
BEGIN


if(P_AMOUNT = 0) THEN
 raise e_invalid_amount;
END IF;
--------------------------------------------------------- PART 1 ------------------------------------------------------------------------------
--- Entering the rule and rule version details in required tables.This block is executed for only once first time the PLSQL API is invoked.
-----------------------------------------------------------------------------------------------------------------------------------------------

POPULATE_RULE_DETAILS(P_RULE_NAME,P_FOLDER_NAME,P_RULE_DESCRIPTION,P_VERSION_NAME,P_START_DATE,P_END_DATE,P_VERSION_DESCRIPTION,l_vs_combo_id,P_OBJECT_ACCESS_CODE);

------------------------------------------------------ PART 1 ENDS ----------------------------------------------------------------------------

--------------------------------------------------------- PART 2 ------------------------------------------------------------------------------
--- Entering data into fem_factor_tables and fem_factor_table_dims. This block is executed for only once first time the PLSQL API is invoked.
-----------------------------------------------------------------------------------------------------------------------------------------------

POPULATE_FACTOR_TABLE_DIMS(P_VERSION_NAME,P_FACTOR_TYPE,P_MATCHING_DIM1,P_HIERARCHY1,P_HIER1_VER,P_LEVEL1,P_HIERARCHY_REL1,P_MATCHING_DIM2,
                           P_HIERARCHY2,P_HIER2_VER,P_LEVEL2,P_HIERARCHY_REL2,P_MATCHING_DIM3,P_HIERARCHY3,P_HIER3_VER,P_LEVEL3,P_HIERARCHY_REL3,NULL,P_FORCE_TO_HUNDRED);

----------------------------------------------------- PART 2 ENDS -----------------------------------------------------------------------------

--------------------------------------------------------- PART 3 ------------------------------------------------------------------------------
--- Entering dimension members and factor value in the fem_factor_table_fctrs.
-----------------------------------------------------------------------------------------------------------------------------------------------

--------------- Entering values for the first matching dimension member.

select decode((select 'Y' from fem_factor_table_fctrs where object_definition_id = g_object_definition_id and dim_member = p_matching_dim1_mem and level_num =0),'Y','N','Y') into l_insert_m1 from dual;

if(l_insert_m1 = 'Y') then

   select FEM_FACTORS_ROW_NUM_SEQ.NEXTVAL into l_row_num from dual;

   l_dimension_member := p_matching_dim1_mem;

   if((p_matching_dim2_mem is null OR length(trim(p_matching_dim2_mem)) =  0) AND (p_matching_dim3_mem is null OR length(trim(p_matching_dim3_mem)) =  0)) then
    l_amount := p_amount;
   else
    l_amount := 0;
   end if;

   insert into FEM_FACTOR_TABLE_FCTRS(OBJECT_DEFINITION_ID,ROW_NUM,PARENT_ROW_NUM,LEVEL_NUM,DIM_MEMBER,FACTOR_VALUE,CREATION_DATE,CREATED_BY,LAST_UPDATED_BY,LAST_UPDATE_DATE,
   LAST_UPDATE_LOGIN,OBJECT_VERSION_NUMBER)
   values(G_OBJECT_DEFINITION_ID,l_row_num,l_parent_row_num,l_level_num,l_dimension_member,l_amount,sysdate,l_user_id,l_user_id,sysdate,l_update_login,0);
else
   select row_num into l_row_num from fem_factor_table_fctrs where object_definition_id = g_object_definition_id and dim_member = p_matching_dim1_mem and level_num = 0;
end if;

   l_parent_row_num := l_row_num;
   l_level_num := l_level_num + 1;

--------------- Entering values for the second matching dimension member. The factor_value will go with distribution dimension as that shall be the leaf dimension member.

if(p_matching_dim2_mem is not NULL AND length(trim(p_matching_dim2_mem)) <> 0) then

select decode((select 'Y' from fem_factor_table_fctrs where object_definition_id = g_object_definition_id and dim_member = p_matching_dim2_mem and level_num = 1 and parent_row_num = l_parent_row_num),'Y','N','Y') into l_insert_m2 from dual;

if(l_insert_m2 = 'Y') then

   select FEM_FACTORS_ROW_NUM_SEQ.NEXTVAL into l_row_num from dual;

   l_dimension_member := p_matching_dim2_mem;

   if(p_matching_dim3_mem is null OR length(trim(p_matching_dim3_mem)) =  0) then
    l_amount := p_amount;
   else
    l_amount := 0;
   end if;

   insert into FEM_FACTOR_TABLE_FCTRS(OBJECT_DEFINITION_ID,ROW_NUM,PARENT_ROW_NUM,LEVEL_NUM,DIM_MEMBER,FACTOR_VALUE,CREATION_DATE,CREATED_BY,LAST_UPDATED_BY,LAST_UPDATE_DATE,
   LAST_UPDATE_LOGIN,OBJECT_VERSION_NUMBER)
   values(G_OBJECT_DEFINITION_ID,l_row_num,l_parent_row_num,l_level_num,l_dimension_member,l_amount,sysdate,l_user_id,l_user_id,sysdate,l_update_login,0);
else
   select row_num into l_row_num from fem_factor_table_fctrs where object_definition_id = g_object_definition_id and dim_member = p_matching_dim2_mem and level_num = 1 and parent_row_num =   l_parent_row_num;
end if;

   l_parent_row_num := l_row_num;
   l_level_num := l_level_num + 1;
end if;

--------------- Entering values for the third matching dimension member. The factor_value will go with distribution dimension as that shall be the leaf dimension member.

if(p_matching_dim3_mem is not NULL AND length(trim(p_matching_dim3_mem)) <> 0) then

select decode((select 'Y' from fem_factor_table_fctrs where object_definition_id = g_object_definition_id and dim_member = p_matching_dim3_mem and level_num =2 and parent_row_num = l_parent_row_num),'Y','N','Y') into l_insert_m3 from dual;

if(l_insert_m3 = 'Y') then

   select FEM_FACTORS_ROW_NUM_SEQ.NEXTVAL into l_row_num from dual;

   l_dimension_member := p_matching_dim3_mem;

   insert into FEM_FACTOR_TABLE_FCTRS(OBJECT_DEFINITION_ID,ROW_NUM,PARENT_ROW_NUM,LEVEL_NUM,DIM_MEMBER,FACTOR_VALUE,CREATION_DATE,CREATED_BY,LAST_UPDATED_BY,LAST_UPDATE_DATE,
   LAST_UPDATE_LOGIN,OBJECT_VERSION_NUMBER)
   values(G_OBJECT_DEFINITION_ID,l_row_num,l_parent_row_num,l_level_num,l_dimension_member,p_amount,sysdate,l_user_id,l_user_id,sysdate,l_update_login,0);

end if;
end if;

--------------------------------------------------------- END PART 3 --------------------------------------------------------------------------
 EXCEPTION
 --
  WHEN DUP_VAL_ON_INDEX THEN
     FND_MESSAGE.SET_NAME('FEM','FEM_ADI_DUPLICATE_ROWS');
     APP_EXCEPTION.Raise_Exception ;
  WHEN e_invalid_amount THEN
     FND_MESSAGE.SET_NAME('FEM','FEM_NO_FACTORS_ENTERED_TXT');
     APP_EXCEPTION.Raise_Exception ;

END UPLOAD_FACTOR_TABLE2_INTERFACE;

PROCEDURE UPLOAD_FACTOR_TABLE3_INTERFACE(
P_RULE_NAME                        VARCHAR2,
P_FOLDER_NAME                      VARCHAR2,
P_RULE_DESCRIPTION                 VARCHAR2,
P_VERSION_NAME                     VARCHAR2,
P_START_DATE                       VARCHAR2,
P_END_DATE                         VARCHAR2,
P_VERSION_DESCRIPTION              VARCHAR2,
P_FACTOR_TYPE                      VARCHAR2,
P_DISTRIBUTION_DIM                 VARCHAR2,
P_FORCE_TO_HUNDRED                 VARCHAR2,
P_OBJECT_ACCESS_CODE               VARCHAR2,
P_DISTRIBUTION_DIM_MEM             VARCHAR2,
P_AMOUNT                           VARCHAR2)
IS

l_user_id               number      := FND_GLOBAL.USER_ID;
l_update_login          number      := FND_GLOBAL.LOGIN_ID;
l_row_num               number      := NULL;
l_parent_row_num        number      := -1;
l_level_num             number      := 0;
l_dimension_member      varchar2(30);
x_err_code              number;
x_num_msg               number;
l_vs_combo_id           number      := FEM_DIMENSION_UTIL_PKG.Local_VS_Combo_ID(G_LEDGER_ID,x_err_code,x_num_msg);
e_invalid_amount         exception;

BEGIN

if(P_AMOUNT = 0) THEN
raise e_invalid_amount;
end if;
--------------------------------------------------------- PART 1 ------------------------------------------------------------------------------
--- Entering the rule and rule version details in required tables.This block is executed for only once first time the PLSQL API is invoked.
-----------------------------------------------------------------------------------------------------------------------------------------------

POPULATE_RULE_DETAILS(P_RULE_NAME,P_FOLDER_NAME,P_RULE_DESCRIPTION,P_VERSION_NAME,P_START_DATE,P_END_DATE,P_VERSION_DESCRIPTION,l_vs_combo_id,P_OBJECT_ACCESS_CODE);

------------------------------------------------------ PART 1 ENDS ----------------------------------------------------------------------------

--------------------------------------------------------- PART 2 ------------------------------------------------------------------------------
--- Entering data into fem_factor_tables and fem_factor_table_dims. This block is executed for only once first time the PLSQL API is invoked.
-----------------------------------------------------------------------------------------------------------------------------------------------

POPULATE_FACTOR_TABLE_DIMS(P_VERSION_NAME,P_FACTOR_TYPE,NULL,NULL,NULL,NULL,NULL,NULL,
                           NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,P_DISTRIBUTION_DIM,P_FORCE_TO_HUNDRED);

----------------------------------------------------- PART 2 ENDS -----------------------------------------------------------------------------

--------------------------------------------------------- PART 3 ------------------------------------------------------------------------------
--- Entering dimension members and factor value in the fem_factor_table_fctrs.
-----------------------------------------------------------------------------------------------------------------------------------------------

--------------- Entering values for the distribution dimension member.

select FEM_FACTORS_ROW_NUM_SEQ.NEXTVAL into l_row_num from dual;

l_dimension_member := p_distribution_dim_mem;

insert into FEM_FACTOR_TABLE_FCTRS(OBJECT_DEFINITION_ID,ROW_NUM,PARENT_ROW_NUM,LEVEL_NUM,DIM_MEMBER,FACTOR_VALUE,CREATION_DATE,CREATED_BY,LAST_UPDATED_BY,LAST_UPDATE_DATE,
LAST_UPDATE_LOGIN,OBJECT_VERSION_NUMBER)
values(G_OBJECT_DEFINITION_ID,l_row_num,l_parent_row_num,l_level_num,l_dimension_member,P_AMOUNT,sysdate,l_user_id,l_user_id,sysdate,l_update_login,0);


--------------------------------------------------------- END PART 3 --------------------------------------------------------------------------
 EXCEPTION
 --
  WHEN DUP_VAL_ON_INDEX THEN
     FND_MESSAGE.SET_NAME('FEM','FEM_ADI_DUPLICATE_ROWS');
     APP_EXCEPTION.Raise_Exception ;
  WHEN e_invalid_amount THEN
     FND_MESSAGE.SET_NAME('FEM','FEM_NO_FACTORS_ENTERED_TXT');
     APP_EXCEPTION.Raise_Exception ;

END UPLOAD_FACTOR_TABLE3_INTERFACE;

PROCEDURE POPULATE_RULE_DETAILS(
P_RULE_NAME                        VARCHAR2,
P_FOLDER_NAME                      VARCHAR2,
P_RULE_DESCRIPTION                 VARCHAR2,
P_VERSION_NAME                     VARCHAR2,
P_START_DATE                       VARCHAR2,
P_END_DATE                         VARCHAR2,
P_VERSION_DESCRIPTION              VARCHAR2,
P_VS_COMBO_ID                      VARCHAR2,
P_OBJECT_ACCESS_CODE               VARCHAR2)
IS

l_old_rule              varchar2(1) := NULL;
l_object_type_code      varchar2(30):= 'FACTOR_TABLE';
l_folder_id             number;
l_local_vs_combo_id     number      := p_vs_combo_id;
l_user_id               number      := FND_GLOBAL.USER_ID;
l_object_access_code    varchar2(30);
l_object_origin_code    varchar2(30):= 'USER';
l_update_login          number      := FND_GLOBAL.LOGIN_ID;

BEGIN
  select folder_id into l_folder_id from fem_folders_vl where folder_name = P_FOLDER_NAME;

  select lookup_code into l_object_access_code from fem_lookups where lookup_type = 'FEM_EDIT_PERMISSION_DSC' and meaning = p_object_access_code;

  select decode((select 'Y' from fem_object_catalog_vl where object_name = p_rule_name),'Y','Y',NULL) into l_old_rule from dual;

  IF(l_old_rule is NULL) THEN
       select FEM_OBJECT_ID_SEQ.NEXTVAL into G_OBJECT_ID from dual;

       INSERT INTO FEM_OBJECT_CATALOG_B(OBJECT_ID,OBJECT_TYPE_CODE,FOLDER_ID,LOCAL_VS_COMBO_ID,CREATION_DATE,CREATED_BY,OBJECT_ACCESS_CODE,OBJECT_ORIGIN_CODE,LAST_UPDATED_BY,
                                     LAST_UPDATE_DATE,LAST_UPDATE_LOGIN,OBJECT_VERSION_NUMBER)
                                     VALUES(G_OBJECT_ID,l_object_type_code,l_folder_id,l_local_vs_combo_id,sysdate,l_user_id,l_object_access_code,
                                     l_object_origin_code,l_user_id,sysdate,l_update_login,0);

       INSERT INTO FEM_OBJECT_CATALOG_TL(OBJECT_ID,OBJECT_NAME,LANGUAGE,SOURCE_LANG,DESCRIPTION,CREATED_BY,CREATION_DATE,LAST_UPDATED_BY,LAST_UPDATE_DATE,LAST_UPDATE_LOGIN)
                                       SELECT G_OBJECT_ID,P_RULE_NAME,LANGUAGE_CODE,'US',P_RULE_DESCRIPTION,l_user_id,sysdate,l_user_id,sysdate,l_update_login
                                       FROM FND_LANGUAGES WHERE INSTALLED_FLAG IN ('I','B');


       select FEM_OBJECT_DEFINITION_ID_SEQ.NEXTVAL into G_OBJECT_DEFINITION_ID from dual;

       INSERT INTO FEM_OBJECT_DEFINITION_B(OBJECT_DEFINITION_ID,OBJECT_ID,EFFECTIVE_START_DATE,EFFECTIVE_END_DATE,OBJECT_ORIGIN_CODE,CREATION_DATE,CREATED_BY,LAST_UPDATED_BY,
                                        LAST_UPDATE_DATE,APPROVAL_STATUS_CODE,OLD_APPROVED_COPY_FLAG,OLD_APPROVED_COPY_OBJ_DEF_ID,APPROVED_BY,APPROVAL_DATE,LAST_UPDATE_LOGIN,
                                        OBJECT_VERSION_NUMBER)
                                        VALUES(G_OBJECT_DEFINITION_ID,G_OBJECT_ID,to_date(P_START_DATE,'DD-MM-RRRR'),to_date(P_END_DATE,'DD-MM-RRRR'),l_object_origin_code,sysdate,
                                        l_user_id,l_user_id,sysdate,'NOT_APPLICABLE','N',NULL,NULL,NULL,l_update_login,0);

       INSERT INTO FEM_OBJECT_DEFINITION_TL(OBJECT_DEFINITION_ID,OBJECT_ID,LANGUAGE,SOURCE_LANG,OLD_APPROVED_COPY_FLAG,DISPLAY_NAME,DESCRIPTION,CREATED_BY,CREATION_DATE,LAST_UPDATED_BY,
                                        LAST_UPDATE_DATE,LAST_UPDATE_LOGIN)
                                        SELECT G_OBJECT_DEFINITION_ID,G_OBJECT_ID,LANGUAGE_CODE,'US','N',P_VERSION_NAME,P_VERSION_DESCRIPTION,l_user_id,sysdate,l_user_id,sysdate,
                                        l_update_login FROM FND_LANGUAGES WHERE INSTALLED_FLAG IN ('I','B');
       G_ENTER_IN_DIMS := 'Y';

  ELSE

       select object_id into G_OBJECT_ID from fem_object_catalog_vl where object_name = p_rule_name;
       select object_definition_id into G_OBJECT_DEFINITION_ID from fem_object_definition_vl where object_id = G_OBJECT_ID and display_name = p_version_name;
       G_ENTER_IN_DIMS := 'N';
  END IF;

END POPULATE_RULE_DETAILS;

PROCEDURE POPULATE_FACTOR_TABLE_DIMS(
P_VERSION_NAME                     VARCHAR2,
P_FACTOR_TYPE                      VARCHAR2,
P_MATCHING_DIM1                    VARCHAR2,
P_HIERARCHY1                       VARCHAR2,
P_HIER1_VER                        VARCHAR2,
P_LEVEL1                           VARCHAR2,
P_HIERARCHY_REL1                   VARCHAR2,
P_MATCHING_DIM2                    VARCHAR2,
P_HIERARCHY2                       VARCHAR2,
P_HIER2_VER                        VARCHAR2,
P_LEVEL2                           VARCHAR2,
P_HIERARCHY_REL2                   VARCHAR2,
P_MATCHING_DIM3                    VARCHAR2,
P_HIERARCHY3                       VARCHAR2,
P_HIER3_VER                        VARCHAR2,
P_LEVEL3                           VARCHAR2,
P_HIERARCHY_REL3                   VARCHAR2,
P_DISTRIBUTION_DIM                 VARCHAR2,
P_FORCE_TO_HUNDRED                 VARCHAR2)
IS

l_user_id               number  := FND_GLOBAL.USER_ID;
l_update_login          number  := FND_GLOBAL.LOGIN_ID;
l_factor_type_code      varchar2(50);
l_dim_id                number  := NULL;
l_hier_obj_id           number  := NULL;
l_hier_obj_def_id       number  := NULL;
l_level_id              number  := NULL;
l_level_num             number  := 0;
l_hierarchy_rel         varchar2(50);
l_force_to_hundred      varchar2(10);

BEGIN

   select lookup_code into l_factor_type_code from fem_lookups where lookup_type = 'FEM_FACTOR_TABLE_TYPES_DSC' and meaning = p_factor_type;

   if(G_ENTER_IN_DIMS = 'Y') THEN

   insert into FEM_FACTOR_TABLES(OBJECT_DEFINITION_ID,
                                 FACTOR_TYPE,
                                 CREATION_DATE,
                                 CREATED_BY,
                                 LAST_UPDATED_BY,
                                 LAST_UPDATE_DATE,
                                 LAST_UPDATE_LOGIN,
                                 OBJECT_VERSION_NUMBER)
                                 values(
                                 G_OBJECT_DEFINITION_ID,
                                 l_factor_type_code,
                                 sysdate,
                                 l_user_id,
                                 l_user_id,
                                 sysdate,
                                 l_update_login,
                                 0);

   if(l_factor_type_code <> 'DISTRIBUTE') then

     -- for factor type 'MATCH' and 'MATCH_AND_DISTRIBUTE' p_match_dim1 parameter will never be null/blank/empty
        select dimension_id into l_dim_id from fem_dimensions_vl where dimension_name = p_matching_dim1;

         if(p_hierarchy1 is not null AND length(trim(p_hierarchy1)) <> 0) then ---------------------- If p_hierarchy1 is not null then p_hier1_ver and p_level1 will also be not null
            select object_id into l_hier_obj_id from fem_object_catalog_vl where object_name = p_hierarchy1 and object_type_code = 'HIERARCHY';
            select object_definition_id into l_hier_obj_def_id from fem_object_definition_vl where display_name = p_hier1_ver and object_id = l_hier_obj_id;
            select dimension_group_id into l_level_id from fem_dimension_grps_vl where dimension_group_name =  p_level1;
            select lookup_code into l_hierarchy_rel from fem_lookups where lookup_type = 'FEM_COND_HIER_RELATIONS' and meaning = p_hierarchy_rel1;
         else
            l_hier_obj_id := null;
            l_hier_obj_def_id := null;
            l_level_id := null;
            l_hierarchy_rel :=null;
          end if;

       insert into fem_factor_table_dims(OBJECT_DEFINITION_ID,LEVEL_NUM,DIMENSION_ID,DIM_USAGE_CODE,FORCE_PERCENT_FLAG,HIER_OBJECT_ID,HIER_OBJ_DEF_ID,HIER_GROUP_ID,HIER_RELATION_CODE,
                                         CREATION_DATE,CREATED_BY,LAST_UPDATED_BY,LAST_UPDATE_DATE,LAST_UPDATE_LOGIN,OBJECT_VERSION_NUMBER)
                                  values(G_OBJECT_DEFINITION_ID,l_level_num,l_dim_id,'MATCH',NULL,l_hier_obj_id,l_hier_obj_def_id,l_level_id,l_hierarchy_rel,
                                         sysdate,l_user_id,l_user_id,sysdate,l_update_login,0);
       l_level_num := l_level_num + 1;

     if(p_matching_dim2 is not null AND length(trim(p_matching_dim2)) <> 0) then
       select dimension_id into l_dim_id from fem_dimensions_vl where dimension_name = p_matching_dim2;

          if(p_hierarchy2 is not null AND length(trim(p_hierarchy2)) <> 0) then
            select object_id into l_hier_obj_id from fem_object_catalog_vl where object_name = p_hierarchy2 and object_type_code = 'HIERARCHY';
            select object_definition_id into l_hier_obj_def_id from fem_object_definition_vl where display_name = p_hier2_ver and object_id = l_hier_obj_id;
            select dimension_group_id into l_level_id from fem_dimension_grps_vl where dimension_group_name =  p_level2;
            select lookup_code into l_hierarchy_rel from fem_lookups where lookup_type = 'FEM_COND_HIER_RELATIONS' and meaning = p_hierarchy_rel2;
          else
            l_hier_obj_id := null;
            l_hier_obj_def_id := null;
            l_level_id := null;
            l_hierarchy_rel :=null;
          end if;

       insert into fem_factor_table_dims(OBJECT_DEFINITION_ID,LEVEL_NUM,DIMENSION_ID,DIM_USAGE_CODE,FORCE_PERCENT_FLAG,HIER_OBJECT_ID,HIER_OBJ_DEF_ID,HIER_GROUP_ID,HIER_RELATION_CODE,
                                         CREATION_DATE,CREATED_BY,LAST_UPDATED_BY,LAST_UPDATE_DATE,LAST_UPDATE_LOGIN,OBJECT_VERSION_NUMBER)
                                  values(G_OBJECT_DEFINITION_ID,l_level_num,l_dim_id,'MATCH',NULL,l_hier_obj_id,l_hier_obj_def_id,l_level_id,l_hierarchy_rel,
                                         sysdate,l_user_id,l_user_id,sysdate,l_update_login,0);
       l_level_num := l_level_num + 1;
     end if;

     if(p_matching_dim3 is not null AND length(trim(p_matching_dim3)) <> 0) then
        select dimension_id into l_dim_id from fem_dimensions_vl where dimension_name = p_matching_dim3;

         if(p_hierarchy3 is not null AND length(trim(p_hierarchy3)) <> 0) then
            select object_id into l_hier_obj_id from fem_object_catalog_vl where object_name = p_hierarchy3 and object_type_code = 'HIERARCHY';
            select object_definition_id into l_hier_obj_def_id from fem_object_definition_vl where display_name = p_hier3_ver and object_id = l_hier_obj_id;
            select dimension_group_id into l_level_id from fem_dimension_grps_vl where dimension_group_name =  p_level3;
            select lookup_code into l_hierarchy_rel from fem_lookups where lookup_type = 'FEM_COND_HIER_RELATIONS' and meaning = p_hierarchy_rel3;
         else
            l_hier_obj_id := null;
            l_hier_obj_def_id := null;
            l_level_id := null;
            l_hierarchy_rel :=null;
         end if;

        insert into fem_factor_table_dims(OBJECT_DEFINITION_ID,LEVEL_NUM,DIMENSION_ID,DIM_USAGE_CODE,FORCE_PERCENT_FLAG,HIER_OBJECT_ID,HIER_OBJ_DEF_ID,HIER_GROUP_ID,HIER_RELATION_CODE,
                                         CREATION_DATE,CREATED_BY,LAST_UPDATED_BY,LAST_UPDATE_DATE,LAST_UPDATE_LOGIN,OBJECT_VERSION_NUMBER)
                                  values(G_OBJECT_DEFINITION_ID,l_level_num,l_dim_id,'MATCH',NULL,l_hier_obj_id,l_hier_obj_def_id,l_level_id,l_hierarchy_rel,
                                         sysdate,l_user_id,l_user_id,sysdate,l_update_login,0);
        l_level_num := l_level_num + 1;
      end if;

    end if; --- End for factor_type check

    if(l_factor_type_code <> 'MATCH') then

       select lookup_code into l_force_to_hundred from fem_lookups where lookup_type = 'FEM_WEBADI_YES_NO' and meaning = p_force_to_hundred;

       if(p_distribution_dim is not null AND length(trim(p_distribution_dim)) <> 0) then
          select dimension_id into l_dim_id from fem_dimensions_vl where dimension_name = p_distribution_dim;
          l_hier_obj_id := null;
          l_hier_obj_def_id := null;
          l_level_id := null;
          insert into fem_factor_table_dims(OBJECT_DEFINITION_ID,LEVEL_NUM,DIMENSION_ID,DIM_USAGE_CODE,FORCE_PERCENT_FLAG,HIER_OBJECT_ID,HIER_OBJ_DEF_ID,HIER_GROUP_ID,HIER_RELATION_CODE,
                                         CREATION_DATE,CREATED_BY,LAST_UPDATED_BY,LAST_UPDATE_DATE,LAST_UPDATE_LOGIN,OBJECT_VERSION_NUMBER)
                                  values(G_OBJECT_DEFINITION_ID,l_level_num,l_dim_id,'DISTRIBUTE',l_force_to_hundred,l_hier_obj_id,l_hier_obj_def_id,l_level_id,null,
                                         sysdate,l_user_id,l_user_id,sysdate,l_update_login,0);
        end if;

    end if;  ---- End for factor_type check

   END IF;

END POPULATE_FACTOR_TABLE_DIMS;

END FEM_WEBADI_FACT_TAB_UTILS_PVT;

/

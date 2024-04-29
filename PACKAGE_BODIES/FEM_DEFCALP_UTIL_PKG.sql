--------------------------------------------------------
--  DDL for Package Body FEM_DEFCALP_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FEM_DEFCALP_UTIL_PKG" AS
-- $Header: fem_defcalp_utl.plb 120.6 2006/07/11 20:27:27 rflippo ship $
/*=======================================================================+
Copyright (c) 1995 Oracle Corporation Redwood Shores, California, USA|
 |                            All rights reserved.                       |
 +=======================================================================+
 | FILENAME
 |   fem_defcalp_utl.sql
 |
 | DESCRIPTION
 |  Create a default Calendar Period member based on the current sysdate and
 |  create a default calendar period hierarchy using this member
 |
 | MODIFICATION HISTORY
 |    Rob Flippo         04/26/2004   Created
 |    Rob Flippo         06/22/2004   Modified select on dimension_group_id
 |                                    to include dimension_id since multiple
 |                                    groups can be named "Year" in the db
 |    Rob Flippo         08/02/2004   Add month and quarter levels to
 |                                    the seeded cal period hier
 |    Rob Flippo         08/20/2004   Change responsibility since all
 |                                    FEM responsibilities are stubbed out
 |    Gordon Cheng       10/11/2004   Defaults profile option FEM_LEDGER
 |                                    at the site level to the default ledger.
 |    Rob Flippo         01/18/2005   Bug#4107563 FEM_DEFCALP.SQL NOT PROPERLY
 |                                    RECOGNIZING WHEN IT HAS ALREADY BEEN RUN
 |    Rob Flippo         02/14/2005   Bug#4167929 Qtr and Month group seq
 |                                    not correct for seeded cal per hier
 |    Rob Flippo         02/15/2005   Bug#4188679 Folder security means
 |                                    need privs on fem_user_folders
 |                                    for sysadmin user
 |    Gordon Cheng       02/28/2005   Bug 3695254. Defaults another ledger:
 |                                    OGL_SOURCE_LEDGER_GROUP.
 |    Rob Flippo         04/27/2005   Bug#4288332 Signature change for
 |                                    new_ledger API
 |    Rob Flippo         05/06/2005   bug#4344994 converted
 |                                    fem_defcalp.sql to a package
 |                                    so that it can be easily called
 |                                    by the Refresh engine
 |    Rob Flippo         05/16/2005   Added exception logic so that the
 |                                    procedure returns an OUT variable
 |                                    designating success or error;
 |                                    Error condition is when the
 |                                    procedure does not create one of
 |                                    the required pieces, such as default
 |                                    ledger, hierarchy, cal period, etc.
 |   Rob Flippo          05/17/2005   Modified for FEM.D compatability
 |                                    by using source_sys_code in
 |                                    new_ledger api rather than
 |                                    source sys display code
 |   Rob Flippo          08/19/2005   Bug#4547880 Update default attr
 |                                    info for budget_first_period and
 |                                    budget_last_period using the
 |                                    created cal period id
 |   Gordon Cheng        11/17/2005   Bug#4540353. Makes sure default ledger
 |                       v115.5       and cal period are assigned to the
 |                                    Budget attributes, if the default
 |                                    assignment is null.
 |   Rob Flippo         05/15/2006    Bug#5201184 Make sure default
 |                                    Bus Rel code assigned to the
 |                                    Business Rel attribute on the
 |                                    Customer dimension if it is null
 |   Rob Flippo         07/11/2006    Bug#5237422 Comment out code to create
 |                                    OGL_SOURCE_LEDGER_GROUP because it is now
 |                                    created via fem_srcledgers.lct/ldt
 *=======================================================================*/


PROCEDURE main (x_status OUT NOCOPY VARCHAR2) IS
   v_dup_cal_period_flag VARCHAR2(1);
   -- Initialization variables

   gv_apps_user_id  CONSTANT NUMBER := FND_GLOBAL.User_Id;
   c_fem    CONSTANT  VARCHAR2(3)  := 'FEM';

   v_user_id NUMBER;
   v_app_id NUMBER;
   v_resp_id NUMBER;

   -- Cal Period variables
   v_rowid ROWID;
   c_cal_period_number CONSTANT NUMBER :=1;
   c_time_dim_group_key CONSTANT NUMBER := 10;
   v_calendar_id NUMBER;
   v_start_date DATE;
   v_end_date DATE;
   v_cal_period_id NUMBER;
   v_dimension_group_id NUMBER; -- group for Year
   v_month_dimgrp_id NUMBER;  -- group for Month
   v_qtr_dimgrp_id NUMBER;  -- group for Quarter
   v_accounting_year NUMBER;
   v_source_system_dc VARCHAR2(150);
   v_source_system_code NUMBER;
   v_ofa_source_sys_code NUMBER;
   v_ofa_source_sys_dc VARCHAR2(150);
   v_num_msg NUMBER;

   v_cal_period_count NUMBER;  -- identifies if 1 cal period exists in db

   -- Hier Object ID variables
   v_object_id NUMBER(9);
   v_object_definition_id NUMBER(9);

   -- Ledger variables
   v_ledger_id FEM_LEDGERS_B.ledger_id%TYPE;
   v_boolean BOOLEAN;
   v_verify_ledger_id FEM_LEDGERS_B.ledger_id%TYPE;
   v_cal_hier_attribute_id FEM_LEDGERS_ATTR.attribute_id%TYPE;
   v_cal_hier_version_id FEM_LEDGERS_ATTR.version_id%TYPE;

   -- Business Relationship variables
   v_bus_rel_mbr_id NUMBER;
   v_bus_rel_dim_id NUMBER;
   v_bus_rel_attr_id NUMBER;
   v_customer_dim_id NUMBER;

   -- Other variables
   v_dim_id FEM_DIMENSIONS_B.dimension_id%TYPE;
   v_count NUMBER;

   -- Message Variables
   v_msg_count NUMBER;
   v_msg_data VARCHAR2(4000);
   v_return_status VARCHAR2(30);
   v_msg_out          NUMBER;


   -- Exceptions
   e_no_def_ledger exception;
   e_bus_rel_error exception;


BEGIN

   v_dup_cal_period_flag := 'N';
   -- Initialization variables
   v_user_id :=gv_apps_user_id;


BEGIN -- Create default Cal Period and Ledger

   select count(*)
   into v_cal_period_count
   from fem_cal_periods_b;

-- If one cal_period exists in the db, then we don't
-- want to create a default cal_period, nor do we want
-- to create a cal_period hier or default ledger

IF v_cal_period_count = 0 THEN

-- Insert privs in fem_user_folders for SYSADMIN user
BEGIN
insert into fem_user_folders
(FOLDER_ID
,USER_ID
,WRITE_FLAG
,CREATED_BY
,CREATION_DATE
,LAST_UPDATED_BY
,LAST_UPDATE_DATE
,LAST_UPDATE_LOGIN
,OBJECT_VERSION_NUMBER)
select 1100
,v_user_id
,'Y'
,v_user_id
,sysdate
,v_user_id
,sysdate
,null
,1
from dual;

EXCEPTION
   when dup_val_on_index then null;
END;

-- Create the Cal Period for the Hierarchy
   select calendar_id
   into v_calendar_id
   from fem_calendars_b
   where calendar_display_code='Default';

   select trunc(sysdate,'YYYY')
   into v_start_date
   from dual;

   v_end_date := LAST_DAY(ADD_MONTHS(v_start_date,11));


     select LPAD(to_char(to_number(to_char(v_end_date,'j'))),7,'0')||
     LPAD(TO_CHAR(c_cal_period_number),15,'0')||
     LPAD(to_char(v_calendar_id),5,'0')||
     LPAD(to_char(c_time_dim_group_key),5,'0')
     into v_cal_period_id
     from dual;


   select dimension_group_id
   into v_dimension_group_id
   from fem_dimension_grps_b
   where dimension_group_display_code = 'Year'
   and dimension_id=1;

   select dimension_group_id
   into v_month_dimgrp_id
   from fem_dimension_grps_b
   where dimension_group_display_code = 'Month'
   and dimension_id=1;

   select dimension_group_id
   into v_qtr_dimgrp_id
   from fem_dimension_grps_b
   where dimension_group_display_code = 'Quarter'
   and dimension_id=1;

   select to_number(to_char(sysdate,'YYYY'))
   into v_accounting_year
   from dual;

   select source_system_code, source_system_display_code
   into v_source_system_code, v_source_system_dc
   from fem_source_systems_b
   where source_system_display_code = 'XGL1';

   begin
   fem_cal_periods_pkg.insert_row(
     X_ROWID => v_rowid
    ,X_CAL_PERIOD_ID => v_cal_period_id
    ,X_OBJECT_VERSION_NUMBER => 1
    ,X_READ_ONLY_FLAG => 'N'
    ,X_DIMENSION_GROUP_ID => v_dimension_group_id
    ,X_CALENDAR_ID => v_calendar_id
    ,X_ENABLED_FLAG => 'Y'
    ,X_PERSONAL_FLAG => 'N'
    ,X_CAL_PERIOD_NAME => to_char(v_end_date,'YYYY/MM/DD')||' Year'
    ,X_DESCRIPTION => 'Created by Installation'
    ,X_CREATION_DATE => sysdate
    ,X_CREATED_BY => v_user_id
    ,X_LAST_UPDATE_DATE => sysdate
    ,X_LAST_UPDATED_BY => v_user_id
    ,X_LAST_UPDATE_LOGIN => null);
   exception
      when dup_val_on_index then
         v_dup_cal_period_flag := 'Y';
   end;

insert into fem_cal_periods_attr (
ATTRIBUTE_ID
,VERSION_ID
,CAL_PERIOD_ID
,DIM_ATTRIBUTE_NUMERIC_MEMBER
,DIM_ATTRIBUTE_VALUE_SET_ID
,DIM_ATTRIBUTE_VARCHAR_MEMBER
,NUMBER_ASSIGN_VALUE
,VARCHAR_ASSIGN_VALUE
,DATE_ASSIGN_VALUE
,CREATION_DATE
,CREATED_BY
,LAST_UPDATED_BY
,LAST_UPDATE_DATE
,LAST_UPDATE_LOGIN
,OBJECT_VERSION_NUMBER
,AW_SNAPSHOT_FLAG)
select A.attribute_id
,V.version_id
,v_cal_period_id
,null
,null
,'N'
,null
,null
,null
,sysdate
,v_user_id
,v_user_id
,sysdate
,null
,1
,'N'
from fem_dim_attributes_b A, fem_dim_attr_versions_b V
where A.attribute_Varchar_label = 'RECON_LEAF_NODE_FLAG'
and A.attribute_id = V.attribute_id
and A.dimension_id = 1
and V.default_version_flag = 'Y';


insert into fem_cal_periods_attr (
ATTRIBUTE_ID
,VERSION_ID
,CAL_PERIOD_ID
,DIM_ATTRIBUTE_NUMERIC_MEMBER
,DIM_ATTRIBUTE_VALUE_SET_ID
,DIM_ATTRIBUTE_VARCHAR_MEMBER
,NUMBER_ASSIGN_VALUE
,VARCHAR_ASSIGN_VALUE
,DATE_ASSIGN_VALUE
,CREATION_DATE
,CREATED_BY
,LAST_UPDATED_BY
,LAST_UPDATE_DATE
,LAST_UPDATE_LOGIN
,OBJECT_VERSION_NUMBER
,AW_SNAPSHOT_FLAG)
select A.attribute_id
,V.version_id
,v_cal_period_id
,null
,null
,'N'
,null
,null
,null
,sysdate
,v_user_id
,v_user_id
,sysdate
,null
,1
,'N'
from fem_dim_attributes_b A, fem_dim_attr_versions_b V
where A.attribute_Varchar_label = 'ADJ_PERIOD_FLAG'
and A.attribute_id = V.attribute_id
and A.dimension_id = 1
and V.default_version_flag = 'Y';

insert into fem_cal_periods_attr (
ATTRIBUTE_ID
,VERSION_ID
,CAL_PERIOD_ID
,DIM_ATTRIBUTE_NUMERIC_MEMBER
,DIM_ATTRIBUTE_VALUE_SET_ID
,DIM_ATTRIBUTE_VARCHAR_MEMBER
,NUMBER_ASSIGN_VALUE
,VARCHAR_ASSIGN_VALUE
,DATE_ASSIGN_VALUE
,CREATION_DATE
,CREATED_BY
,LAST_UPDATED_BY
,LAST_UPDATE_DATE
,LAST_UPDATE_LOGIN
,OBJECT_VERSION_NUMBER
,AW_SNAPSHOT_FLAG)
select A.attribute_id
,V.version_id
,v_cal_period_id
,null
,null
,'N'
,null
,null
,null
,sysdate
,v_user_id
,v_user_id
,sysdate
,null
,1
,'N'
from fem_dim_attributes_b A, fem_dim_attr_versions_b V
where A.attribute_Varchar_label = 'GL_ORIGIN_FLAG'
and A.attribute_id = V.attribute_id
and A.dimension_id = 1
and V.default_version_flag = 'Y';

insert into fem_cal_periods_attr (
ATTRIBUTE_ID
,VERSION_ID
,CAL_PERIOD_ID
,DIM_ATTRIBUTE_NUMERIC_MEMBER
,DIM_ATTRIBUTE_VALUE_SET_ID
,DIM_ATTRIBUTE_VARCHAR_MEMBER
,NUMBER_ASSIGN_VALUE
,VARCHAR_ASSIGN_VALUE
,DATE_ASSIGN_VALUE
,CREATION_DATE
,CREATED_BY
,LAST_UPDATED_BY
,LAST_UPDATE_DATE
,LAST_UPDATE_LOGIN
,OBJECT_VERSION_NUMBER
,AW_SNAPSHOT_FLAG)
select A.attribute_id
,V.version_id
,v_cal_period_id
,null
,null
,'N'
,null
,null
,null
,sysdate
,v_user_id
,v_user_id
,sysdate
,null
,1
,'N'
from fem_dim_attributes_b A, fem_dim_attr_versions_b V
where A.attribute_Varchar_label = 'CUR_PERIOD_FLAG'
and A.attribute_id = V.attribute_id
and A.dimension_id = 1
and V.default_version_flag = 'Y';

insert into fem_cal_periods_attr (
ATTRIBUTE_ID
,VERSION_ID
,CAL_PERIOD_ID
,DIM_ATTRIBUTE_NUMERIC_MEMBER
,DIM_ATTRIBUTE_VALUE_SET_ID
,DIM_ATTRIBUTE_VARCHAR_MEMBER
,NUMBER_ASSIGN_VALUE
,VARCHAR_ASSIGN_VALUE
,DATE_ASSIGN_VALUE
,CREATION_DATE
,CREATED_BY
,LAST_UPDATED_BY
,LAST_UPDATE_DATE
,LAST_UPDATE_LOGIN
,OBJECT_VERSION_NUMBER
,AW_SNAPSHOT_FLAG)
select A.attribute_id
,V.version_id
,v_cal_period_id
,null
,null
,null
,v_accounting_year
,null
,null
,sysdate
,v_user_id
,v_user_id
,sysdate
,null
,1
,'N'
from fem_dim_attributes_b A, fem_dim_attr_versions_b V
where A.attribute_Varchar_label = 'ACCOUNTING_YEAR'
and A.attribute_id = V.attribute_id
and A.dimension_id = 1
and V.default_version_flag = 'Y';

insert into fem_cal_periods_attr (
ATTRIBUTE_ID
,VERSION_ID
,CAL_PERIOD_ID
,DIM_ATTRIBUTE_NUMERIC_MEMBER
,DIM_ATTRIBUTE_VALUE_SET_ID
,DIM_ATTRIBUTE_VARCHAR_MEMBER
,NUMBER_ASSIGN_VALUE
,VARCHAR_ASSIGN_VALUE
,DATE_ASSIGN_VALUE
,CREATION_DATE
,CREATED_BY
,LAST_UPDATED_BY
,LAST_UPDATE_DATE
,LAST_UPDATE_LOGIN
,OBJECT_VERSION_NUMBER
,AW_SNAPSHOT_FLAG)
select A.attribute_id
,V.version_id
,v_cal_period_id
,null
,null
,null
,null
,null
,v_start_date
,sysdate
,v_user_id
,v_user_id
,sysdate
,null
,1
,'N'
from fem_dim_attributes_b A, fem_dim_attr_versions_b V
where A.attribute_Varchar_label = 'CAL_PERIOD_START_DATE'
and A.attribute_id = V.attribute_id
and A.dimension_id = 1
and V.default_version_flag = 'Y';

insert into fem_cal_periods_attr (
ATTRIBUTE_ID
,VERSION_ID
,CAL_PERIOD_ID
,DIM_ATTRIBUTE_NUMERIC_MEMBER
,DIM_ATTRIBUTE_VALUE_SET_ID
,DIM_ATTRIBUTE_VARCHAR_MEMBER
,NUMBER_ASSIGN_VALUE
,VARCHAR_ASSIGN_VALUE
,DATE_ASSIGN_VALUE
,CREATION_DATE
,CREATED_BY
,LAST_UPDATED_BY
,LAST_UPDATE_DATE
,LAST_UPDATE_LOGIN
,OBJECT_VERSION_NUMBER
,AW_SNAPSHOT_FLAG)
select A.attribute_id
,V.version_id
,v_cal_period_id
,null
,null
,null
,null
,null
,v_end_date
,sysdate
,v_user_id
,v_user_id
,sysdate
,null
,1
,'N'
from fem_dim_attributes_b A, fem_dim_attr_versions_b V
where A.attribute_Varchar_label = 'CAL_PERIOD_END_DATE'
and A.attribute_id = V.attribute_id
and A.dimension_id = 1
and V.default_version_flag = 'Y';

insert into fem_cal_periods_attr (
ATTRIBUTE_ID
,VERSION_ID
,CAL_PERIOD_ID
,DIM_ATTRIBUTE_NUMERIC_MEMBER
,DIM_ATTRIBUTE_VALUE_SET_ID
,DIM_ATTRIBUTE_VARCHAR_MEMBER
,NUMBER_ASSIGN_VALUE
,VARCHAR_ASSIGN_VALUE
,DATE_ASSIGN_VALUE
,CREATION_DATE
,CREATED_BY
,LAST_UPDATED_BY
,LAST_UPDATE_DATE
,LAST_UPDATE_LOGIN
,OBJECT_VERSION_NUMBER
,AW_SNAPSHOT_FLAG)
select A.attribute_id
,V.version_id
,v_cal_period_id
,null
,null
,null
,c_cal_period_number
,null
,null
,sysdate
,v_user_id
,v_user_id
,sysdate
,null
,1
,'N'
from fem_dim_attributes_b A, fem_dim_attr_versions_b V
where A.attribute_Varchar_label = 'GL_PERIOD_NUM'
and A.attribute_id = V.attribute_id
and A.dimension_id = 1
and V.default_version_flag = 'Y';

insert into fem_cal_periods_attr (
ATTRIBUTE_ID
,VERSION_ID
,CAL_PERIOD_ID
,DIM_ATTRIBUTE_NUMERIC_MEMBER
,DIM_ATTRIBUTE_VALUE_SET_ID
,DIM_ATTRIBUTE_VARCHAR_MEMBER
,NUMBER_ASSIGN_VALUE
,VARCHAR_ASSIGN_VALUE
,DATE_ASSIGN_VALUE
,CREATION_DATE
,CREATED_BY
,LAST_UPDATED_BY
,LAST_UPDATE_DATE
,LAST_UPDATE_LOGIN
,OBJECT_VERSION_NUMBER
,AW_SNAPSHOT_FLAG)
select A.attribute_id
,V.version_id
,v_cal_period_id
,v_source_system_code
,null
,null
,null
,null
,null
,sysdate
,v_user_id
,v_user_id
,sysdate
,null
,1
,'N'
from fem_dim_attributes_b A, fem_dim_attr_versions_b V
where A.attribute_Varchar_label = 'SOURCE_SYSTEM_CODE'
and A.attribute_id = V.attribute_id
and A.dimension_id = 1
and V.default_version_flag = 'Y';

insert into fem_cal_periods_attr (
ATTRIBUTE_ID
,VERSION_ID
,CAL_PERIOD_ID
,DIM_ATTRIBUTE_NUMERIC_MEMBER
,DIM_ATTRIBUTE_VALUE_SET_ID
,DIM_ATTRIBUTE_VARCHAR_MEMBER
,NUMBER_ASSIGN_VALUE
,VARCHAR_ASSIGN_VALUE
,DATE_ASSIGN_VALUE
,CREATION_DATE
,CREATED_BY
,LAST_UPDATED_BY
,LAST_UPDATE_DATE
,LAST_UPDATE_LOGIN
,OBJECT_VERSION_NUMBER
,AW_SNAPSHOT_FLAG)
select A.attribute_id
,V.version_id
,v_cal_period_id
,null
,null
,null
,null
,'Year'
,null
,sysdate
,v_user_id
,v_user_id
,sysdate
,null
,1
,'N'
from fem_dim_attributes_b A, fem_dim_attr_versions_b V
where A.attribute_Varchar_label = 'CAL_PERIOD_PREFIX'
and A.attribute_id = V.attribute_id
and A.dimension_id = 1
and V.default_version_flag = 'Y';


-- Create the Hierarchy Object
fem_object_catalog_util_pkg.create_object (x_object_id => v_object_id,
               x_object_definition_id => v_object_definition_id,
               x_msg_count => v_msg_count,
               x_msg_data => v_msg_data,
               x_return_status => v_return_status,
               p_api_version => 1,
               p_commit => FND_API.G_FALSE,
               p_object_type_code => 'HIERARCHY',
               p_folder_id => 1100,
               p_local_vs_combo_id => null,
               p_object_access_code => 'W',
               p_object_origin_code => 'SEEDED',
               p_object_name => 'Seeded Calendar Period Hierarchy',
               p_description => 'Created by Installation',
               p_obj_def_name => 'Seeded Calendar Period Hierarchy');

 insert into fem_hierarchies (
HIERARCHY_OBJ_ID
,DIMENSION_ID
,HIERARCHY_TYPE_CODE
,GROUP_SEQUENCE_ENFORCED_CODE
,MULTI_TOP_FLAG
,FINANCIAL_CATEGORY_FLAG
,VALUE_SET_ID
,CALENDAR_ID
,PERIOD_TYPE
,PERSONAL_FLAG
,FLATTENED_ROWS_FLAG
,CREATION_DATE
,CREATED_BY
,LAST_UPDATED_BY
,LAST_UPDATE_DATE
,LAST_UPDATE_LOGIN
,HIERARCHY_USAGE_CODE
,MULTI_VALUE_SET_FLAG
,OBJECT_VERSION_NUMBER)
values (v_object_id
,1
,'OPEN'
,'SEQUENCE_ENFORCED'
,'Y'
,'N'
,null
,v_calendar_id
,null
,'N'
,'N'
,sysdate
,v_user_id
,v_user_id
,sysdate
,null
,'STANDARD'
,'N'
,1);

insert into fem_hier_value_sets
( HIERARCHY_OBJ_ID,
 VALUE_SET_ID,
 CREATION_DATE,
 CREATED_BY,
 LAST_UPDATED_BY,
 LAST_UPDATE_DATE,
 LAST_UPDATE_LOGIN,
 OBJECT_VERSION_NUMBER)
values (v_object_id, v_calendar_id,sysdate,v_user_id,v_user_id,sysdate,null,1);

insert into fem_hier_definitions (
HIERARCHY_OBJ_DEF_ID
,CREATION_DATE
,CREATED_BY
,LAST_UPDATED_BY
,LAST_UPDATE_DATE
,LAST_UPDATE_LOGIN
,OBJECT_VERSION_NUMBER
,FLATTENED_ROWS_COMPLETION_CODE )
values (v_object_definition_id
,sysdate
,v_user_id
,v_user_id
,sysdate
,null
,1
,'COMPLETED');



insert into fem_hier_dimension_grps(
DIMENSION_GROUP_ID
,HIERARCHY_OBJ_ID
,RELATIVE_DIMENSION_GROUP_SEQ
,CREATION_DATE
,CREATED_BY
,LAST_UPDATED_BY
,LAST_UPDATE_DATE
,LAST_UPDATE_LOGIN
,OBJECT_VERSION_NUMBER)
values (v_dimension_group_id
,v_object_id
,1
,sysdate
,v_user_id
,v_user_id
,sysdate
,null
,1);

insert into fem_hier_dimension_grps(
DIMENSION_GROUP_ID
,HIERARCHY_OBJ_ID
,RELATIVE_DIMENSION_GROUP_SEQ
,CREATION_DATE
,CREATED_BY
,LAST_UPDATED_BY
,LAST_UPDATE_DATE
,LAST_UPDATE_LOGIN
,OBJECT_VERSION_NUMBER)
values (v_month_dimgrp_id
,v_object_id
,40
,sysdate
,v_user_id
,v_user_id
,sysdate
,null
,1);

insert into fem_hier_dimension_grps(
DIMENSION_GROUP_ID
,HIERARCHY_OBJ_ID
,RELATIVE_DIMENSION_GROUP_SEQ
,CREATION_DATE
,CREATED_BY
,LAST_UPDATED_BY
,LAST_UPDATE_DATE
,LAST_UPDATE_LOGIN
,OBJECT_VERSION_NUMBER)
values (v_qtr_dimgrp_id
,v_object_id
,20
,sysdate
,v_user_id
,v_user_id
,sysdate
,null
,1);

 insert into fem_cal_periods_hier (
HIERARCHY_OBJ_DEF_ID
,PARENT_DEPTH_NUM
,PARENT_ID
,CHILD_DEPTH_NUM
,CHILD_ID
,SINGLE_DEPTH_FLAG
,DISPLAY_ORDER_NUM
,WEIGHTING_PCT
,CREATION_DATE
,CREATED_BY
,LAST_UPDATED_BY
,LAST_UPDATE_DATE
,LAST_UPDATE_LOGIN
,OBJECT_VERSION_NUMBER)
values (v_object_definition_id
,1
,v_cal_period_id
,1
,v_cal_period_id
,'Y'
,1
,null
,sysdate
,v_user_id
,v_user_id
,sysdate
,null
,1);

 fem_dimension_util_pkg.new_ledger (
 X_RETURN_STATUS => v_return_status
,X_MSG_COUNT => v_msg_count
,X_MSG_DATA => v_msg_data
,P_DISPLAY_CODE => 'DEFAULT_LEDGER'
,P_LEDGER_NAME => 'Default Ledger'
,P_FUNC_CURR_CD => 'USD'
,P_SOURCE_CD => v_source_system_code
,P_CAL_PER_HID => v_object_definition_id
,P_GLOBAL_VS_ID => 1
,P_EPB_DEF_LG_FLG => 'Y'
,P_ENT_CURR_FLG => 'Y'
,P_AVG_BAL_FLG => 'Y'
,P_CHAN_FLG => 'Y'
,P_CCTR_FLG => 'Y'
,P_CUST_FLG => 'Y'
,P_GEOG_FLG => 'Y'
,P_LN_ITEM_FLG => 'Y'
,P_NAT_ACCT_FLG => 'Y'
,P_PROD_FLG => 'Y'
,P_PROJ_FLG => 'Y'
,P_USER1_FLG => 'Y'
,P_USER2_FLG => 'Y'
,P_USER3_FLG => 'Y'
,P_USER4_FLG => 'Y'
,P_USER5_FLG => 'Y'
,P_USER6_FLG => 'Y'
,P_USER7_FLG => 'Y'
,P_USER8_FLG => 'Y'
,P_USER9_FLG => 'Y'
,P_USER10_FLG => 'Y'
,P_ENTITY_FLG => 'Y'
,P_VER_NAME => 'Default'
,P_VER_DISP_CD => 'Default'
,P_LEDGER_DESC => 'Created by Installation');

BEGIN
select ledger_id
into v_verify_ledger_id
from fem_ledgers_b
where ledger_display_code='DEFAULT_LEDGER';

EXCEPTION
   when no_data_found then raise e_no_def_ledger;
END;

commit;

END IF;

EXCEPTION
   when dup_val_on_index then
      null;
END;  -- Create default Cal Period and Ledger


BEGIN

  -- Bug 4740353. Set all missing default budget attribute assignments.
  -- Only process if at least one of the following attributes is null:
  --   BUDGET_LEDGER, BUDGET_FIRST_PERIOD, BUDGET_LAST_PERIOD,
  --   BUDGET_LATEST_OPEN_YEAR

  -- Get BUDGET dimension id
  SELECT dimension_id
  INTO v_dim_id
  FROM fem_dimensions_b
  WHERE dimension_varchar_label = 'BUDGET';

  SELECT count(*)
  INTO v_count
  FROM fem_dim_attributes_b
  WHERE dimension_id = v_dim_id
  AND attribute_varchar_label IN ('BUDGET_LEDGER','BUDGET_LEDGER',
      'BUDGET_FIRST_PERIOD','BUDGET_LAST_PERIOD','BUDGET_LATEST_OPEN_YEAR')
  AND default_assignment IS NULL;

  IF v_count > 0 THEN
    -- Assign newly created 'DEFAULT_LEDGER' as the default assignment for the
    -- BUDGET_LEDGER attribute.  If this is an update, find the earliest
    -- created ledger with calendar periods created associated with it.
    IF v_ledger_id IS NULL THEN
      -- First find attrib and version id for CAL_PERIOD_HIER_OBJ_DEF_ID attrib
      SELECT a.attribute_id, v.version_id
      INTO v_cal_hier_attribute_id, v_cal_hier_version_id
      FROM fem_dim_attributes_b a, fem_dim_attr_versions_b v
      WHERE a.attribute_varchar_label = 'CAL_PERIOD_HIER_OBJ_DEF_ID'
      AND v.attribute_id = a.attribute_id
      AND v.default_version_flag = 'Y'
      AND a.dimension_id =
       (SELECT dimension_id
        FROM fem_dimensions_b
        WHERE dimension_varchar_label = 'LEDGER');

      -- Then find the ledger
      SELECT min(ledger_id)
      INTO v_ledger_id
      FROM fem_ledgers_b
      WHERE enabled_flag = 'Y'
      AND ledger_id IN
       (SELECT ledger_id
        FROM fem_ledgers_attr
        WHERE dim_attribute_numeric_member IN
         (SELECT object_definition_id
          FROM fem_object_definition_b
          WHERE object_id IN
           (SELECT hierarchy_obj_id
            FROM fem_hierarchies
            WHERE calendar_id IN
             (SELECT calendar_id
              FROM fem_cal_periods_b
              WHERE enabled_flag = 'Y')))
        AND attribute_id = v_cal_hier_attribute_id
        AND version_id = v_cal_hier_version_id);
    END IF;

    UPDATE fem_dim_attributes_b
    SET default_assignment = to_char(v_ledger_id)
    WHERE dimension_id = v_dim_id
    AND attribute_varchar_label = 'BUDGET_LEDGER';

    -- If the default calendar period does not exist, find the earliest
    -- created calendar period that belongs to the same calendar as the
    -- BUDGET_LEDGER.
    IF v_cal_period_id IS NULL THEN
      SELECT min(cal_period_id) KEEP (DENSE_RANK FIRST ORDER BY creation_date)
      INTO v_cal_period_id
      FROM fem_cal_periods_b
      WHERE enabled_flag = 'Y'
      AND calendar_id IN
       (SELECT calendar_id
        FROM fem_hierarchies
        WHERE hierarchy_obj_id IN
         (SELECT object_id
          FROM fem_object_definition_b
          WHERE object_definition_id IN
           (SELECT dim_attribute_numeric_member
            FROM fem_ledgers_attr
            WHERE ledger_id = v_ledger_id
            AND attribute_id = v_cal_hier_attribute_id
            AND version_id = v_cal_hier_version_id)));
    END IF;

    UPDATE fem_dim_attributes_b
    SET default_assignment = to_char(v_cal_period_id)
    WHERE dimension_id = v_dim_id
    AND attribute_varchar_label IN ('BUDGET_FIRST_PERIOD','BUDGET_LAST_PERIOD');
    -- Update default assignment for the BUDGET_LATEST_OPEN_YEAR as the
    -- accounting year of the BUDGET_LAST_PERIOD.
    IF v_accounting_year IS NULL THEN
      SELECT C.number_assign_value
      INTO v_accounting_year
      FROM fem_cal_periods_attr C, fem_dim_attributes_b A, fem_dim_attr_versions_b V
      WHERE C.cal_period_id = v_cal_period_id
      AND A.attribute_varchar_label = 'ACCOUNTING_YEAR'
      AND C.attribute_id = V.attribute_id
      AND C.version_id = V.version_id
      AND A.attribute_id = V.attribute_id
      AND V.default_version_flag = 'Y'
      AND A.dimension_id IN
       (SELECT dimension_id
        FROM fem_dimensions_b
        WHERE dimension_varchar_label = 'CAL_PERIOD');
    END IF;

    UPDATE fem_dim_attributes_b
    SET default_assignment = to_char(v_accounting_year)
    WHERE dimension_id = v_dim_id
    AND attribute_varchar_label = 'BUDGET_LATEST_OPEN_YEAR';
  END IF;

EXCEPTION WHEN others THEN null;
END;


-- Default FEM_LEDGER profile option at the site level to 'DEFAULT_LEDGER'
BEGIN
  SELECT ledger_id
  INTO v_ledger_id
  FROM fem_ledgers_b
  WHERE ledger_display_code = 'DEFAULT_LEDGER';

  IF v_ledger_id IS NOT NULL AND FND_PROFILE.value('FEM_LEDGER') IS NULL THEN
    v_boolean := FND_PROFILE.save('FEM_LEDGER', v_ledger_id, 'SITE');

    COMMIT;
  END IF;
EXCEPTION WHEN others THEN null;
END;

/*********************************************************************
Bug#5237422 - Commenting out because we now create the
OGL_SOURCE_LEDGER_GROUP using fem_srcledgers.lct and fem_srcledgers.ldt

-- Bug 3695254: Create OGL_SOURCE_LEDGER_GROUP
BEGIN
  v_ledger_id := null;

  -- If OGL_SOURCE_LEDGER_GROUP is not found, we need to create it.
  BEGIN
    SELECT ledger_id
    INTO v_ledger_id
    FROM fem_ledgers_b
    WHERE ledger_display_code = 'OGL_SOURCE_LEDGER_GROUP';
  EXCEPTION
    WHEN no_data_found THEN

      -- Get the first Cal Period hierarchy created, which
      -- presumably would be the default one we seeded.
      SELECT MIN(h.hierarchy_obj_id)
      INTO v_object_id
      FROM fem_hierarchies h, fem_dimensions_b d
      WHERE d.dimension_varchar_label = 'CAL_PERIOD'
      AND h.dimension_id = d.dimension_id;

      SELECT MIN(object_definition_id)
      INTO v_object_definition_id
      FROM fem_object_definition_b
      WHERE object_id = v_object_id;

      select source_system_code,source_system_display_code
      into v_ofa_source_sys_code,v_ofa_source_sys_dc
      from fem_source_systems_b
      where source_system_display_code = 'OFA';

      fem_dimension_util_pkg.new_ledger (
        X_RETURN_STATUS => v_return_status
       ,X_MSG_COUNT => v_msg_count
       ,X_MSG_DATA => v_msg_data
       ,P_DISPLAY_CODE => 'OGL_SOURCE_LEDGER_GROUP'
       ,P_LEDGER_NAME => 'Oracle General Ledger Source Ledger Group'
       ,P_FUNC_CURR_CD => 'USD'
       ,P_SOURCE_CD => v_ofa_source_sys_code
       ,P_CAL_PER_HID => v_object_definition_id
       ,P_GLOBAL_VS_ID => 1
       ,P_EPB_DEF_LG_FLG => 'N'
       ,P_ENT_CURR_FLG => 'Y'
       ,P_AVG_BAL_FLG => 'Y'
       ,P_CHAN_FLG => 'Y'
       ,P_CCTR_FLG => 'Y'
       ,P_CUST_FLG => 'Y'
       ,P_GEOG_FLG => 'Y'
       ,P_LN_ITEM_FLG => 'Y'
       ,P_NAT_ACCT_FLG => 'Y'
       ,P_PROD_FLG => 'Y'
       ,P_PROJ_FLG => 'Y'
       ,P_USER1_FLG => 'Y'
       ,P_USER2_FLG => 'Y'
       ,P_USER3_FLG => 'Y'
       ,P_USER4_FLG => 'Y'
       ,P_USER5_FLG => 'Y'
       ,P_USER6_FLG => 'Y'
       ,P_USER7_FLG => 'Y'
       ,P_USER8_FLG => 'Y'
       ,P_USER9_FLG => 'Y'
       ,P_USER10_FLG => 'Y'
       ,P_ENTITY_FLG => 'Y'
       ,P_VER_NAME => 'Default'
       ,P_VER_DISP_CD => 'Default'
       ,P_LEDGER_DESC => 'Oracle General Ledger Source Ledger Group');

      -- The New_Ledger API creates ledgers as enabled and not read only.
      -- SLG should not be enabled and should be read only.
      UPDATE fem_ledgers_b
      SET ENABLED_FLAG = 'N', READ_ONLY_FLAG = 'Y'
      WHERE ledger_display_code = 'OGL_SOURCE_LEDGER_GROUP';

      -- Get Source Ledger Group ledger ID to populate FEM_LEDGER_HIER
      SELECT ledger_id
      INTO v_ledger_id
      FROM fem_ledgers_b
      WHERE ledger_display_code = 'OGL_SOURCE_LEDGER_GROUP';


      -- Just make sure it exists as it should have been seeded
      -- by fem_objects.ldt in an earlier phase of the install.
      SELECT object_definition_id
      INTO v_object_definition_id
      FROM fem_object_definition_b
      WHERE object_definition_id = 1505;

      INSERT INTO fem_ledgers_hier
       (HIERARCHY_OBJ_DEF_ID,
        PARENT_DEPTH_NUM,
        PARENT_ID,
        CHILD_DEPTH_NUM,
        CHILD_ID,
        SINGLE_DEPTH_FLAG,
        DISPLAY_ORDER_NUM,
        WEIGHTING_PCT,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN,
        OBJECT_VERSION_NUMBER)
      VALUES
       (v_object_definition_id,
        1,
        v_ledger_id,
        1,
        v_ledger_id,
        'Y',
        1,
        NULL,
        SYSDATE,
        1,
        1,
        SYSDATE,
        0,
        1);

    COMMIT;
  END; -- query if OGL_SOURCE_LEDGER_GROUP exists

EXCEPTION
   when no_data_found then raise e_no_def_ledger;

END; -- Bug 3695254
******************************************************/


-- Bug#5201184 Update fem_dim_attributes_b.default_assignment
-- For the BUSINESS_RELATIONSHIP attribute
BEGIN

   SELECT bus_rel_id
   INTO v_bus_rel_mbr_id
   FROM fem_bus_rel_b
   WHERE bus_rel_display_code = 'INDIVIDUAL_CUSTOMER';

   SELECT dimension_id
   INTO v_customer_dim_id
   FROM fem_dimensions_b
   WHERE dimension_varchar_label = 'CUSTOMER';

   SELECT attribute_id
   INTO v_bus_rel_attr_id
   FROM fem_dim_attributes_b
   WHERE dimension_id = v_customer_dim_id
   AND attribute_varchar_label = 'BUSINESS_RELATIONSHIP';

   UPDATE fem_dim_attributes_b
   SET default_assignment = v_bus_rel_mbr_id
   WHERE attribute_id = v_bus_rel_attr_id
   AND default_assignment IS NULL;


EXCEPTION
   WHEN OTHERS THEN RAISE e_bus_rel_error;

END; -- bug#5201184

x_status := 'SUCCESS';

EXCEPTION
   WHEN e_no_def_ledger THEN x_status := 'ERROR';
        FEM_ENGINES_PKG.USER_MESSAGE
        (P_APP_NAME => c_fem
        ,P_MSG_NAME => 'FEM_GDFT_NO_DEFLEDGER');


   WHEN e_bus_rel_error THEN x_status := 'ERROR';
        FEM_ENGINES_PKG.USER_MESSAGE
        (P_APP_NAME => c_fem
        ,P_MSG_NAME => 'FEM_GDFT_BUS_REL_ERROR');



END main;

END fem_defcalp_util_pkg;

/

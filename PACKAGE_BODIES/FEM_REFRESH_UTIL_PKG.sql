--------------------------------------------------------
--  DDL for Package Body FEM_REFRESH_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FEM_REFRESH_UTIL_PKG" AS
-- $Header: fem_refresh_utl.plb 120.2 2006/07/10 23:35:02 rflippo noship $
/*=======================================================================+
Copyright (c) 1995 Oracle Corporation Redwood Shores, California, USA|
 |                            All rights reserved.                       |
 +=======================================================================+
 | FILENAME
 |   fem_refresh_utl.sql
 |
 | DESCRIPTION
 |  The Refresh Utility package contains procedures called by the Refresh
 |  engine when it is returning a database to its install state.
 |
 |  Procedure List:
 |     del_obsolete_seed_data - this procedure calls all of the delete statements
 |     for removing obsolete seeded data from the database.  This seed data
 |     would otherwise get put back in by the refresh when it calls the ldt
 |     files to repopulate.  The reason for this being that the ldt files
 |     for backports are targeted - i.e, the main ldt file still contains the
 |     obsolete rows.
 |
 | MODIFICATION HISTORY
 |    Rob Flippo         07/06/2005   Created
 |    Rob Flippo         04/24/2006   Bug5002331 Remove refrence to
 |                                    DIM_PROPERTIES in delete statements
 |                                    for FEM_ADMIN_DIMESTUP_TASKS
 |    Rob Flippo         07/10/2006   Bug#5237422 Add deletes for attributes
 |                                    previously made optional
 |
  *=======================================================================*/


PROCEDURE del_obsolete_seed_data (x_status OUT NOCOPY VARCHAR2) IS

v_count number;

------------------------------------------------------------------
-- For bug#5237422
v_ledger_dim_id number;
v_natrl_dim_id number;
v_cctr_dim_id number;
v_finelem_dim_id number;
v_lnitem_dim_id number;

cursor c_ldgattr (p_dimid IN NUMBER) is
select attribute_id from fem_dim_attributes_b
where dimension_id = p_dimid
and attribute_varchar_label in ('LEDGER_CHANNEL_IS_POP_FLAG'
,'LEDGER_CUSTOMER_IS_POP_FLAG'
,'LEDGER_ENTITY_IS_POP_FLAG'
,'LEDGER_FIN_ELEM_IS_POP_FLAG'
,'LEDGER_GEOGRAPHY_IS_POP_FLAG'
,'LEDGER_LINE_ITEM_IS_POP_FLAG'
,'LEDGER_NAT_ACCT_IS_POP_FLAG'
,'LEDGER_PRODUCT_IS_POP_FLAG'
,'LEDGER_PROJECT_IS_POP_FLAG'
,'LEDGER_TASK_IS_POP_FLAG'
,'LEDGER_USER_DIM10_IS_POP_FLAG'
,'LEDGER_USER_DIM1_IS_POP_FLAG'
,'LEDGER_USER_DIM2_IS_POP_FLAG'
,'LEDGER_USER_DIM3_IS_POP_FLAG'
,'LEDGER_USER_DIM4_IS_POP_FLAG'
,'LEDGER_USER_DIM5_IS_POP_FLAG'
,'LEDGER_USER_DIM6_IS_POP_FLAG'
,'LEDGER_USER_DIM7_IS_POP_FLAG'
,'LEDGER_USER_DIM8_IS_POP_FLAG'
,'LEDGER_USER_DIM9_IS_POP_FLAG'
,'LEDGER_CCTR_IS_POP_FLAG' );

cursor c_natattr (p_dimid IN NUMBER) is
select attribute_id from fem_dim_attributes_b
where dimension_id = p_dimid
and attribute_varchar_label in ('FINANCIAL_CATEGORY_FLAG');

cursor c_cctrattr (p_dimid IN NUMBER) is
select attribute_id from fem_dim_attributes_b
where dimension_id = p_dimid
and attribute_varchar_label in ('HIDDEN_FLAG');

cursor c_feattr (p_dimid IN NUMBER) is
select attribute_id from fem_dim_attributes_b
where dimension_id = p_dimid
and attribute_varchar_label in ('CONSOLIDATION_FLAG');

cursor c_lnattr (p_dimid IN NUMBER) is
select attribute_id from fem_dim_attributes_b
where dimension_id = p_dimid
and attribute_varchar_label in ('HIDDEN_FLAG','BUDGET_ALLOWED_FLAG');
------------------------------------------------------------------


BEGIN


-- fem4040716_upd.sql
delete from fem_sic_hier
where hierarchy_obj_def_id = 1501
and child_id = 1
and parent_id = 75;

delete from fem_sic_hier
where hierarchy_obj_def_id = 1501
and child_id = 5
and parent_id = 76;

--fem4196148_drp.sql
BEGIN

   select count(*)
   into v_count
   from fem_tab_columns_b
   where table_name='FEM_CREDIT_LIMITS'
   and column_name = 'CREDIT_LIMIT_TYPE';

   IF v_count > 0 THEN

      delete from fem_tab_columns_b
      where table_name='FEM_CREDIT_LIMITS'
      and column_name in ('CREDIT_LIMIT_ID','CREDIT_LIMIT_TYPE');

      delete from fem_tab_columns_tl
      where table_name='FEM_CREDIT_LIMITS'
      and column_name in ('CREDIT_LIMIT_ID','CREDIT_LIMIT_TYPE');

   END IF;
END;

-- fem4299195_del.sql
delete from fem_folders_tl
where folder_id in (1200, 1300);

delete from fem_folders_b
where folder_id in (1200, 1300);


--fem4453456.sql
delete from FEM_TAB_COLUMNS_B
where table_name = 'FEM_CREDIT_LIMITS'
and column_name = 'CREDIT_LIMIT_AMOUNT';

delete from FEM_INT_COLUMN_MAP
where object_type_code = 'SOURCE_DATA_LOADER'
and target_column_name = 'CREDIT_LIMIT_AMOUNT'
and interface_column_name = 'CREDIT_LIMIT_AMOUNT';

--fem_attr_del.sql
/**********************************************************************
*    FEM.C delete statements
*    Per Bug#3884353 Integration: Attribute Removal
*    and bug#4044974 DATAMODEL CHANGE TO SUPPORT DEFAULT HIERARCHY
*                    FOR CAL PERIOD DIMENSION

**********************************************************************

/****************************
  Calendar
***************************/
delete from fem_calendars_attr
where version_id in
(select version_id from fem_dim_attr_Versions_b
where attribute_id in (select attribute_id
from fem_dim_attributes_b A1, fem_dimensions_b D1
where A1.dimension_id = D1.dimension_id
and D1.dimension_varchar_label = 'CALENDAR'
and A1.attribute_varchar_label in ('DEFAULT_CAL_PERIOD'
)));

delete from fem_dim_attr_versions_tl where version_id in
(select version_id from fem_dim_attr_Versions_b
where attribute_id in (select attribute_id
from fem_dim_attributes_b A1, fem_dimensions_b D1
where A1.dimension_id = D1.dimension_id
and D1.dimension_varchar_label = 'CALENDAR'
and A1.attribute_varchar_label in ('DEFAULT_CAL_PERIOD'
)));

delete from fem_dim_attr_versions_b
where attribute_id in (select attribute_id
from fem_dim_attributes_b A1, fem_dimensions_b D1
where A1.dimension_id = D1.dimension_id
and D1.dimension_varchar_label = 'CALENDAR'
and A1.attribute_varchar_label in ('DEFAULT_CAL_PERIOD'
));

delete from fem_dim_attributes_tl
where attribute_id in (select attribute_id
from fem_dim_attributes_b A1, fem_dimensions_b D1
where A1.dimension_id = D1.dimension_id
and D1.dimension_varchar_label = 'CALENDAR'
and A1.attribute_varchar_label in ('DEFAULT_CAL_PERIOD'
));

delete from fem_dim_attributes_priv
where attribute_id in (select attribute_id
from fem_dim_attributes_b A1, fem_dimensions_b D1
where A1.dimension_id = D1.dimension_id
and D1.dimension_varchar_label = 'CALENDAR'
and A1.attribute_varchar_label in ('DEFAULT_CAL_PERIOD'
));

delete from fem_dim_attributes_b
where attribute_id in (select attribute_id
from fem_dim_attributes_b A1, fem_dimensions_b D1
where A1.dimension_id = D1.dimension_id
and D1.dimension_varchar_label = 'CALENDAR'
and A1.attribute_varchar_label in ('DEFAULT_CAL_PERIOD'
,'DIVISIBLE_FLAG'));


/****************************
  Financial Element
***************************/
delete from fem_fin_elems_attr
where version_id in
(select version_id from fem_dim_attr_Versions_b
where attribute_id in (select attribute_id
from fem_dim_attributes_b A1, fem_dimensions_b D1
where A1.dimension_id = D1.dimension_id
and D1.dimension_varchar_label = 'FINANCIAL_ELEMENT'
and A1.attribute_varchar_label in ('FE_DATA_GROUPING_CODE'
,'DIVISIBLE_FLAG')));

delete from fem_dim_attr_versions_tl where version_id in
(select version_id from fem_dim_attr_Versions_b
where attribute_id in (select attribute_id
from fem_dim_attributes_b A1, fem_dimensions_b D1
where A1.dimension_id = D1.dimension_id
and D1.dimension_varchar_label = 'FINANCIAL_ELEMENT'
and A1.attribute_varchar_label in ('FE_DATA_GROUPING_CODE'
,'DIVISIBLE_FLAG')));

delete from fem_dim_attr_versions_b
where attribute_id in (select attribute_id
from fem_dim_attributes_b A1, fem_dimensions_b D1
where A1.dimension_id = D1.dimension_id
and D1.dimension_varchar_label = 'FINANCIAL_ELEMENT'
and A1.attribute_varchar_label in ('FE_DATA_GROUPING_CODE'
,'DIVISIBLE_FLAG'));

delete from fem_dim_attributes_tl
where attribute_id in (select attribute_id
from fem_dim_attributes_b A1, fem_dimensions_b D1
where A1.dimension_id = D1.dimension_id
and D1.dimension_varchar_label = 'FINANCIAL_ELEMENT'
and A1.attribute_varchar_label in ('FE_DATA_GROUPING_CODE'
,'DIVISIBLE_FLAG'));

delete from fem_dim_attributes_priv
where attribute_id in (select attribute_id
from fem_dim_attributes_b A1, fem_dimensions_b D1
where A1.dimension_id = D1.dimension_id
and D1.dimension_varchar_label = 'FINANCIAL_ELEMENT'
and A1.attribute_varchar_label in ('FE_DATA_GROUPING_CODE'
,'DIVISIBLE_FLAG'));

delete from fem_dim_attr_grps
where attribute_id in (select attribute_id
from fem_dim_attributes_b A1, fem_dimensions_b D1
where A1.dimension_id = D1.dimension_id
and D1.dimension_varchar_label = 'FINANCIAL_ELEMENT'
and A1.attribute_varchar_label in ('FE_DATA_GROUPING_CODE'
,'DIVISIBLE_FLAG'));

delete from fem_dim_attributes_b
where attribute_id in (select attribute_id
from fem_dim_attributes_b A1, fem_dimensions_b D1
where A1.dimension_id = D1.dimension_id
and D1.dimension_varchar_label = 'FINANCIAL_ELEMENT'
and A1.attribute_varchar_label in ('FE_DATA_GROUPING_CODE'
,'DIVISIBLE_FLAG'));


/****************************
  Line Item
***************************/
delete from fem_ln_items_attr
where version_id in
(select version_id from fem_dim_attr_Versions_b
where attribute_id in (select attribute_id
from fem_dim_attributes_b A1, fem_dimensions_b D1
where A1.dimension_id = D1.dimension_id
and D1.dimension_varchar_label = 'LINE_ITEM'
and A1.attribute_varchar_label in ('BAL_SHEET_MODEL_CODE'
,'TP_METHOD_CODE'
,'NEW_TIMING_PCT'
,'WEIGHTING_AVG_PERIOD'
,'ACTIVATION_FLAG'
,'OFFSET_CCTR_ORG'
)));


delete from fem_dim_attr_versions_tl where version_id in
(select version_id from fem_dim_attr_Versions_b
where attribute_id in (select attribute_id
from fem_dim_attributes_b A1, fem_dimensions_b D1
where A1.dimension_id = D1.dimension_id
and D1.dimension_varchar_label = 'LINE_ITEM'
and A1.attribute_varchar_label in ('BAL_SHEET_MODEL_CODE'
,'TP_METHOD_CODE'
,'NEW_TIMING_PCT'
,'WEIGHTING_AVG_PERIOD'
,'ACTIVATION_FLAG'
,'OFFSET_CCTR_ORG'
)));

delete from fem_dim_attr_versions_b
where attribute_id in (select attribute_id
from fem_dim_attributes_b A1, fem_dimensions_b D1
where A1.dimension_id = D1.dimension_id
and D1.dimension_varchar_label = 'LINE_ITEM'
and A1.attribute_varchar_label in ('BAL_SHEET_MODEL_CODE'
,'TP_METHOD_CODE'
,'NEW_TIMING_PCT'
,'WEIGHTING_AVG_PERIOD'
,'ACTIVATION_FLAG'
,'OFFSET_CCTR_ORG'
));

delete from fem_dim_attributes_tl
where attribute_id in (select attribute_id
from fem_dim_attributes_b A1, fem_dimensions_b D1
where A1.dimension_id = D1.dimension_id
and D1.dimension_varchar_label = 'LINE_ITEM'
and A1.attribute_varchar_label in ('BAL_SHEET_MODEL_CODE'
,'TP_METHOD_CODE'
,'NEW_TIMING_PCT'
,'WEIGHTING_AVG_PERIOD'
,'ACTIVATION_FLAG'
,'OFFSET_CCTR_ORG'
));

delete from fem_dim_attributes_priv
where attribute_id in (select attribute_id
from fem_dim_attributes_b A1, fem_dimensions_b D1
where A1.dimension_id = D1.dimension_id
and D1.dimension_varchar_label = 'LINE_ITEM'
and A1.attribute_varchar_label in ('BAL_SHEET_MODEL_CODE'
,'TP_METHOD_CODE'
,'NEW_TIMING_PCT'
,'WEIGHTING_AVG_PERIOD'
,'ACTIVATION_FLAG'
,'OFFSET_CCTR_ORG'
));

delete from fem_dim_attr_grps
where attribute_id in (select attribute_id
from fem_dim_attributes_b A1, fem_dimensions_b D1
where A1.dimension_id = D1.dimension_id
and D1.dimension_varchar_label = 'LINE_ITEM'
and A1.attribute_varchar_label in ('BAL_SHEET_MODEL_CODE'
,'TP_METHOD_CODE'
,'NEW_TIMING_PCT'
,'WEIGHTING_AVG_PERIOD'
,'ACTIVATION_FLAG'
,'OFFSET_CCTR_ORG'
));

delete from fem_dim_attributes_b
where attribute_id in (select attribute_id
from fem_dim_attributes_b A1, fem_dimensions_b D1
where A1.dimension_id = D1.dimension_id
and D1.dimension_varchar_label = 'LINE_ITEM'
and A1.attribute_varchar_label in ('BAL_SHEET_MODEL_CODE'
,'TP_METHOD_CODE'
,'NEW_TIMING_PCT'
,'WEIGHTING_AVG_PERIOD'
,'ACTIVATION_FLAG'
,'OFFSET_CCTR_ORG'
));


/****************************
  Product
***************************/
delete from fem_products_attr where version_id in
(select version_id from fem_dim_attr_Versions_b
where attribute_id in (select attribute_id
from fem_dim_attributes_b A1, fem_dimensions_b D1
where A1.dimension_id = D1.dimension_id
and D1.dimension_varchar_label = 'PRODUCT'
and A1.attribute_varchar_label in ('HIDDEN_FLAG')));


delete from fem_dim_attr_versions_tl where version_id in
(select version_id from fem_dim_attr_Versions_b
where attribute_id in (select attribute_id
from fem_dim_attributes_b A1, fem_dimensions_b D1
where A1.dimension_id = D1.dimension_id
and D1.dimension_varchar_label = 'PRODUCT'
and A1.attribute_varchar_label in ('HIDDEN_FLAG')));

delete from fem_dim_attr_versions_b
where attribute_id in (select attribute_id
from fem_dim_attributes_b A1, fem_dimensions_b D1
where A1.dimension_id = D1.dimension_id
and D1.dimension_varchar_label = 'PRODUCT'
and A1.attribute_varchar_label in ('HIDDEN_FLAG'));

delete from fem_dim_attributes_tl
where attribute_id in (select attribute_id
from fem_dim_attributes_b A1, fem_dimensions_b D1
where A1.dimension_id = D1.dimension_id
and D1.dimension_varchar_label = 'PRODUCT'
and A1.attribute_varchar_label in ('HIDDEN_FLAG'));

delete from fem_dim_attributes_priv
where attribute_id in (select attribute_id
from fem_dim_attributes_b A1, fem_dimensions_b D1
where A1.dimension_id = D1.dimension_id
and D1.dimension_varchar_label = 'PRODUCT'
and A1.attribute_varchar_label in ('HIDDEN_FLAG'));

delete from fem_dim_attr_grps
where attribute_id in (select attribute_id
from fem_dim_attributes_b A1, fem_dimensions_b D1
where A1.dimension_id = D1.dimension_id
and D1.dimension_varchar_label = 'PRODUCT'
and A1.attribute_varchar_label in ('HIDDEN_FLAG'));

delete from fem_dim_attributes_b
where attribute_id in (select attribute_id
from fem_dim_attributes_b A1, fem_dimensions_b D1
where A1.dimension_id = D1.dimension_id
and D1.dimension_varchar_label = 'PRODUCT'
and A1.attribute_varchar_label in ('HIDDEN_FLAG'));


/****************************
  Natural Account
***************************/
delete from fem_nat_accts_attr where version_id in
(select version_id from fem_dim_attr_Versions_b
where attribute_id in (select attribute_id
from fem_dim_attributes_b A1, fem_dimensions_b D1
where A1.dimension_id = D1.dimension_id
and D1.dimension_varchar_label = 'NATURAL_ACCOUNT'
and A1.attribute_varchar_label in ('HIDDEN_FLAG','ACTIVATION_FLAG')));


delete from fem_dim_attr_versions_tl where version_id in
(select version_id from fem_dim_attr_Versions_b
where attribute_id in (select attribute_id
from fem_dim_attributes_b A1, fem_dimensions_b D1
where A1.dimension_id = D1.dimension_id
and D1.dimension_varchar_label = 'NATURAL_ACCOUNT'
and A1.attribute_varchar_label in ('HIDDEN_FLAG','ACTIVATION_FLAG')));

delete from fem_dim_attr_versions_b
where attribute_id in (select attribute_id
from fem_dim_attributes_b A1, fem_dimensions_b D1
where A1.dimension_id = D1.dimension_id
and D1.dimension_varchar_label = 'NATURAL_ACCOUNT'
and A1.attribute_varchar_label in ('HIDDEN_FLAG','ACTIVATION_FLAG'));

delete from fem_dim_attributes_tl
where attribute_id in (select attribute_id
from fem_dim_attributes_b A1, fem_dimensions_b D1
where A1.dimension_id = D1.dimension_id
and D1.dimension_varchar_label = 'NATURAL_ACCOUNT'
and A1.attribute_varchar_label in ('HIDDEN_FLAG','ACTIVATION_FLAG'));

delete from fem_dim_attributes_priv
where attribute_id in (select attribute_id
from fem_dim_attributes_b A1, fem_dimensions_b D1
where A1.dimension_id = D1.dimension_id
and D1.dimension_varchar_label = 'NATURAL_ACCOUNT'
and A1.attribute_varchar_label in ('HIDDEN_FLAG','ACTIVATION_FLAG'));

delete from fem_dim_attr_grps
where attribute_id in (select attribute_id
from fem_dim_attributes_b A1, fem_dimensions_b D1
where A1.dimension_id = D1.dimension_id
and D1.dimension_varchar_label = 'NATURAL_ACCOUNT'
and A1.attribute_varchar_label in ('HIDDEN_FLAG','ACTIVATION_FLAG'));

delete from fem_dim_attributes_b
where attribute_id in (select attribute_id
from fem_dim_attributes_b A1, fem_dimensions_b D1
where A1.dimension_id = D1.dimension_id
and D1.dimension_varchar_label = 'NATURAL_ACCOUNT'
and A1.attribute_varchar_label in ('HIDDEN_FLAG','ACTIVATION_FLAG'));

/****************************
  Ledger
***************************/
delete from fem_ledgers_attr where version_id in
(select version_id from fem_dim_attr_Versions_b
where attribute_id in (select attribute_id
from fem_dim_attributes_b A1, fem_dimensions_b D1
where A1.dimension_id = D1.dimension_id
and D1.dimension_varchar_label = 'LEDGER'
and A1.attribute_varchar_label in ('EPB_DEFAULT_LEDGER_FLAG')));

delete from fem_dim_attr_versions_tl where version_id in
(select version_id from fem_dim_attr_Versions_b
where attribute_id in (select attribute_id
from fem_dim_attributes_b A1, fem_dimensions_b D1
where A1.dimension_id = D1.dimension_id
and D1.dimension_varchar_label = 'LEDGER'
and A1.attribute_varchar_label in ('EPB_DEFAULT_LEDGER_FLAG')));

delete from fem_dim_attr_versions_b
where attribute_id in (select attribute_id
from fem_dim_attributes_b A1, fem_dimensions_b D1
where A1.dimension_id = D1.dimension_id
and D1.dimension_varchar_label = 'LEDGER'
and A1.attribute_varchar_label in ('EPB_DEFAULT_LEDGER_FLAG'));

delete from fem_dim_attributes_tl
where attribute_id in (select attribute_id
from fem_dim_attributes_b A1, fem_dimensions_b D1
where A1.dimension_id = D1.dimension_id
and D1.dimension_varchar_label = 'LEDGER'
and A1.attribute_varchar_label in ('EPB_DEFAULT_LEDGER_FLAG'));

delete from fem_dim_attributes_priv
where attribute_id in (select attribute_id
from fem_dim_attributes_b A1, fem_dimensions_b D1
where A1.dimension_id = D1.dimension_id
and D1.dimension_varchar_label = 'LEDGER'
and A1.attribute_varchar_label in ('EPB_DEFAULT_LEDGER_FLAG'));

delete from fem_dim_attr_grps
where attribute_id in (select attribute_id
from fem_dim_attributes_b A1, fem_dimensions_b D1
where A1.dimension_id = D1.dimension_id
and D1.dimension_varchar_label = 'LEDGER'
and A1.attribute_varchar_label in ('EPB_DEFAULT_LEDGER_FLAG'));

delete from fem_dim_attributes_b
where attribute_id in (select attribute_id
from fem_dim_attributes_b A1, fem_dimensions_b D1
where A1.dimension_id = D1.dimension_id
and D1.dimension_varchar_label = 'LEDGER'
and A1.attribute_varchar_label in ('EPB_DEFAULT_LEDGER_FLAG'));


--fem_dmstptsk_del.sql
delete from fem_admin_dimsetup_tasks
where dimsetup_task  in
('DIM_ASSOCIATIONS');


--fem_enttype_del.sql
delete from fem_entity_types_tl
where entity_type_code in ('CONSOLIDATION','ELIMINATION','OPERATING');
delete from fem_entity_types_b
where entity_type_code in ('CONSOLIDATION','ELIMINATION','OPERATING');



--fem_obs_seeddata.sql
delete from fem_ext_Acct_types_attr where attribute_id in
(select attribute_id from fem_dim_attributes_b
where attribute_varchar_label in ('DEBIT_SIGN','LOAD_SIGN'));

delete from fem_dim_attr_Versions_vl
where attribute_id in (select attribute_id from fem_dim_attributes_b
where attribute_Varchar_label in ('DEBIT_SIGN','LOAD_SIGN'));

delete from fem_dim_attributes_vl where attribute_varchar_label in ('DEBIT_SIGN','LOAD_SIGN');

delete from fem_ln_items_attr where attribute_id in
(select attribute_id from fem_dim_attributes_b
where attribute_Varchar_label = 'STATISTICS_TYPE_FLAG');

delete from fem_dim_attr_Versions_vl
where attribute_id in
(select attribute_id from fem_dim_attributes_b
where attribute_Varchar_label = 'STATISTICS_TYPE_FLAG');
delete from fem_dim_attributes_vl
where attribute_varchar_label = 'STATISTICS_TYPE_FLAG';



----------------------------------------------------------
-- bug#5237422
begin

select dimension_id
into v_ledger_dim_id
from fem_dimensions_b
where dimension_varchar_label = 'LEDGER';

select dimension_id
into v_natrl_dim_id
from fem_dimensions_b
where dimension_varchar_label = 'NATURAL_ACCOUNT';

select dimension_id
into v_cctr_dim_id
from fem_dimensions_b
where dimension_varchar_label = 'COMPANY_COST_CENTER_ORG';

select dimension_id
into v_finelem_dim_id
from fem_dimensions_b
where dimension_varchar_label = 'FINANCIAL_ELEMENT';

select dimension_id
into v_lnitem_dim_id
from fem_dimensions_b
where dimension_varchar_label = 'LINE_ITEM';


/* Obsolete Ledger Dimension Attributes */
for attr in c_ldgattr (v_ledger_dim_id) loop

delete from fem_dsnp_ledgers_attr
where attribute_id = attr.attribute_id;

delete from fem_ledgers_attr
where attribute_id = attr.attribute_id;

delete from fem_dim_attr_versions_tl
where version_id in (select version_id
from fem_dim_attr_Versions_b
where attribute_id = attr.attribute_id);

delete from fem_dim_attr_versions_b
where attribute_id = attr.attribute_id;

delete from fem_dim_attributes_tl
where attribute_id = attr.attribute_id;

delete from fem_dim_attributes_b
where attribute_id = attr.attribute_id;

delete from fem_dim_attr_grps
where attribute_id=attr.attribute_id;

delete from fem_dim_attributes_priv
where attribute_id = attr.attribute_id;

end loop;


/* Obsolete Natural Account Dimension Attributes */
for attr in c_natattr (v_natrl_dim_id) loop

delete from fem_dsnp_ledgers_attr
where attribute_id = attr.attribute_id;

delete from fem_ledgers_attr
where attribute_id = attr.attribute_id;

delete from fem_dim_attr_versions_tl
where version_id in (select version_id
from fem_dim_attr_Versions_b
where attribute_id = attr.attribute_id);

delete from fem_dim_attr_versions_b
where attribute_id = attr.attribute_id;

delete from fem_dim_attributes_tl
where attribute_id = attr.attribute_id;

delete from fem_dim_attributes_b
where attribute_id = attr.attribute_id;

delete from fem_dim_attr_grps
where attribute_id=attr.attribute_id;

delete from fem_dim_attributes_priv
where attribute_id = attr.attribute_id;

end loop;


/* Obsolete CCTR Dimension Attributes */
for attr in c_cctrattr (v_cctr_dim_id) loop

delete from fem_dsnp_ledgers_attr
where attribute_id = attr.attribute_id;

delete from fem_ledgers_attr
where attribute_id = attr.attribute_id;

delete from fem_dim_attr_versions_tl
where version_id in (select version_id
from fem_dim_attr_Versions_b
where attribute_id = attr.attribute_id);

delete from fem_dim_attr_versions_b
where attribute_id = attr.attribute_id;

delete from fem_dim_attributes_tl
where attribute_id = attr.attribute_id;

delete from fem_dim_attributes_b
where attribute_id = attr.attribute_id;

delete from fem_dim_attr_grps
where attribute_id=attr.attribute_id;

delete from fem_dim_attributes_priv
where attribute_id = attr.attribute_id;

end loop;


/* Obsolete Fin Elem Dimension Attributes */
for attr in c_feattr (v_finelem_dim_id) loop

delete from fem_dsnp_ledgers_attr
where attribute_id = attr.attribute_id;

delete from fem_ledgers_attr
where attribute_id = attr.attribute_id;

delete from fem_dim_attr_versions_tl
where version_id in (select version_id
from fem_dim_attr_Versions_b
where attribute_id = attr.attribute_id);

delete from fem_dim_attr_versions_b
where attribute_id = attr.attribute_id;

delete from fem_dim_attributes_tl
where attribute_id = attr.attribute_id;

delete from fem_dim_attributes_b
where attribute_id = attr.attribute_id;

delete from fem_dim_attr_grps
where attribute_id=attr.attribute_id;

delete from fem_dim_attributes_priv
where attribute_id = attr.attribute_id;

end loop;


/* Obsolete Line Item Dimension Attributes */
for attr in c_lnattr (v_lnitem_dim_id) loop

delete from fem_dsnp_ledgers_attr
where attribute_id = attr.attribute_id;

delete from fem_ledgers_attr
where attribute_id = attr.attribute_id;

delete from fem_dim_attr_versions_tl
where version_id in (select version_id
from fem_dim_attr_Versions_b
where attribute_id = attr.attribute_id);

delete from fem_dim_attr_versions_b
where attribute_id = attr.attribute_id;

delete from fem_dim_attributes_tl
where attribute_id = attr.attribute_id;

delete from fem_dim_attributes_b
where attribute_id = attr.attribute_id;

delete from fem_dim_attr_grps
where attribute_id=attr.attribute_id;

delete from fem_dim_attributes_priv
where attribute_id = attr.attribute_id;

end loop;


/*  FEM Data Type */
delete from fem_data_types_tl
where fem_data_type_code = 'VARCHAR2';

delete from fem_data_types_b
where fem_data_type_code = 'VARCHAR2';

delete from fem_data_types_attr
where fem_data_type_code = 'VARCHAR2';

end;

----------------------------------------------------------


END del_obsolete_seed_data;

END fem_refresh_util_pkg;

/

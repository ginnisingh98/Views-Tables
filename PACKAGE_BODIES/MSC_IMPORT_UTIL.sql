--------------------------------------------------------
--  DDL for Package Body MSC_IMPORT_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_IMPORT_UTIL" AS
/* $Header: MSCIMPUB.pls 120.5.12010000.2 2010/03/23 13:51:06 skakani noship $ */

/*=============================================================================
Four global Variables
g_attr_name	- List of attribute names
g_attr_val	- List of attribute values for a particular record in msc_st_item_attributes
g_attr_type	- lov type-1:Number 2: Char 6:Date
g_sql_stmt	- If lov type is 2 then use this sql stmt to get the hidden value
=============================================================================*/

TYPE attr_name_list is table of varchar2(30) index by binary_integer;

TYPE attr_type_list is table of number index by binary_integer;

TYPE sql_stmt_list is table of varchar2(2000) index by binary_integer;

TYPE attr_val_list is table of varchar2(240) index by binary_integer;

TYPE imm_stg_rec is record(
	ROWID					VARCHAR2(240)	,
	SIMULATION_SET_NAME                     VARCHAR2(240)    ,
	ITEM_NAME                               VARCHAR2(250)    ,
	ORGANIZATION_CODE                       VARCHAR2(7)      ,
	SR_INSTANCE_CODE                        VARCHAR2(3)      ,
	ZONE                                    VARCHAR2(60)     ,
	CUSTOMER_NAME                           VARCHAR2(255)    ,
	CUSTOMER_SITE_NAME                      VARCHAR2(30)     ,
	CRITICAL_COMPONENT_FLAG                 VARCHAR2(80)     ,
	FULL_LEAD_TIME                          NUMBER           ,
	PREPROCESSING_LEAD_TIME                 NUMBER           ,
	POSTPROCESSING_LEAD_TIME                NUMBER           ,
	FIXED_LEAD_TIME                         NUMBER           ,
	VARIABLE_LEAD_TIME                      NUMBER           ,
	FIXED_ORDER_QUANTITY                    NUMBER           ,
	FIXED_DAYS_SUPPLY                       NUMBER           ,
	SHRINKAGE_RATE                          NUMBER           ,
	FIXED_LOT_MULTIPLIER                    NUMBER           ,
	MINIMUM_ORDER_QUANTITY                  NUMBER           ,
	MAXIMUM_ORDER_QUANTITY                  NUMBER           ,
	SERVICE_LEVEL                           VARCHAR2(40)     ,
	CARRYING_COST                           NUMBER           ,
	DEMAND_TIME_FENCE_DAYS                  NUMBER           ,
	ATO_FORECAST_CONTROL                    VARCHAR2(80)     ,
	PLANNING_TIME_FENCE_DAYS                NUMBER           ,
	STANDARD_COST                           NUMBER           ,
	PIP_FLAG                                VARCHAR2(80)     ,
	LIST_PRICE                              NUMBER           ,
	SUBSTITUTION_WINDOW                     NUMBER           ,
	SAFETY_STOCK_BUCKET_DAYS                NUMBER           ,
	UNIT_WEIGHT                             NUMBER           ,
	UNIT_VOLUME                             NUMBER           ,
	SAFETY_STOCK_CODE                       VARCHAR2(80)     ,
	SAFETY_STOCK_PERCENT                    NUMBER           ,
	ABC_CLASS_NAME                          VARCHAR2(40)     ,
	MRP_PLANNING_CODE                       VARCHAR2(80)     ,
	DRP_PLANNED                             VARCHAR2(80)     ,
	DAYS_MAX_INV_SUPPLY                     NUMBER           ,
	DAYS_MAX_INV_WINDOW                     NUMBER           ,
	DAYS_TGT_INV_SUPPLY                     NUMBER           ,
	DAYS_TGT_INV_WINDOW                     NUMBER           ,
	CONTINOUS_TRANSFER                      VARCHAR2(80)     ,
	CONVERGENCE                             VARCHAR2(80)     ,
	CREATE_SUPPLY_FLAG                      VARCHAR2(80)     ,
	DIVERGENCE                              VARCHAR2(80)     ,
	PLANNING_EXCEPTION_SET                  VARCHAR2(10)     ,
	INVENTORY_USE_UP_DATE                   DATE             ,
	PLANNING_MAKE_BUY_CODE                  VARCHAR2(80)     ,
	WEIGHT_UOM                              VARCHAR2(3)      ,
	VOLUME_UOM                              VARCHAR2(3)      ,
	ROUNDING_CONTROL_TYPE                   VARCHAR2(80)     ,
	ATP_FLAG                                VARCHAR2(80)     ,
	ATP_COMPONENTS_FLAG                     VARCHAR2(80)     ,
	DEMAND_FULFILLMENT_LT                   VARCHAR2(40)     ,
	LOTS_EXPIRATION                         NUMBER           ,
	CONSIGNED_FLAG                          VARCHAR2(80)     ,
	LEADTIME_VARIABILITY                    VARCHAR2(40)     ,
	PLANNER_CODE                            VARCHAR2(240)    ,
	EO_FLAG                                 VARCHAR2(80)     ,
	EXCESS_HORIZON                          VARCHAR2(40)     ,
	OBSOLESCENCE_DATE                       VARCHAR2(18)     ,
	REPAIR_LEAD_TIME                        VARCHAR2(40)     ,
	REPAIR_YIELD                            VARCHAR2(40)     ,
	REPAIR_COST                             VARCHAR2(40)     ,
	RELIABILITY                             VARCHAR2(240)    ,
	FAILURE_IMPACT                          VARCHAR2(240)    ,
	STANDARD_DEVIATION                      VARCHAR2(40)     ,
	COEFFICIENT_OF_VARIATION                VARCHAR2(40)     ,
	BASIS_AVG_DAILY_DEMAND                  VARCHAR2(40)     ,
	FORECAST_RULE_FOR_DEMANDS               VARCHAR2(30)     ,
	FORECAST_RULE_FOR_RETURNS               VARCHAR2(30)     ,
	LIFE_TIME_BUY_DATE                      DATE             ,
	END_OF_LIFE_DATE                        DATE             ,
	AVG_DEMAND_BEYOND_PH                    NUMBER           ,
	AVG_RETURNS_BEYOND_PH                   NUMBER           ,
	RETURN_FORECAST_TIME_FENCE              NUMBER           ,
	AVERAGE_DAILY_DEMAND                    NUMBER           ,
	DEFECTIVE_ITEM_COST                     NUMBER           ,
	STD_DEVIATION_FOR_DEMAND                NUMBER           ,
	MEAN_INTER_ARRIVAL                      NUMBER           ,
	STD_DEVIATION_INTER_ARRIVAL             NUMBER           ,
	INTERARRIVAL_DIST_METHOD                VARCHAR2(240)    ,
	INTERMITTENT_DEMAND                     VARCHAR2(80)     ,
	MAX_USAGE_FACTOR                        NUMBER           ,
	MIN_REM_SHELF_LIFE_DAYS                 NUMBER           ,
	UNSATISFIED_DEMAND_FACTOR               NUMBER           ,
	DMD_SATISFIED_PERCENT                   NUMBER           ,
	MIN_SUP_DEM_PERCENT                     NUMBER           ,
	ROP_SAFETY_STOCK			NUMBER		 ,
	COMPUTE_SS				VARCHAR2(10)	 ,
	COMPUTE_EOQ				VARCHAR2(10)	 ,
	ORDER_COST				NUMBER
);


g_attr_name attr_name_list;
g_attr_val  attr_val_list;
g_attr_type attr_type_list;
g_sql_stmt  sql_stmt_list;


procedure init is

cursor c_lov_type(l_field_name varchar2) is
select lov_type,sql_statement from
msc_criteria where
folder_object in ('MSC_IMM_UPDATE_ATTRIBUTES',
		  'MSC_REGION_UPDATE_ATTRIBUTES',
		  'MSC_CUST_UPDATE_ATTRIBUTES',
		  'MSC_IMM_DESTINATION_ATTRIBUTES'
		  )
and field_name = l_field_name;

cursor c_lov_type_count(l_field_name varchar2) is
select count(*) from
msc_criteria where
folder_object in ('MSC_IMM_UPDATE_ATTRIBUTES',
		  'MSC_REGION_UPDATE_ATTRIBUTES',
		  'MSC_CUST_UPDATE_ATTRIBUTES',
		  'MSC_IMM_DESTINATION_ATTRIBUTES')
and field_name = l_field_name;
i number;
l_count number :=0;
begin

	g_attr_name(1) := 'SIMULATION_SET_NAME';
	g_attr_type(1) := null;

	g_attr_name(2) :='ITEM_NAME';
	g_attr_type(2) := null;

	g_attr_name(3) :='ORGANIZATION_CODE';
	g_attr_type(3) := null;

	g_attr_name(4) :='SR_INSTANCE_CODE';
	g_attr_type(4) := null;

	g_attr_name(5) :='ZONE';
	g_attr_type(5) := null;

	g_attr_name(6) :='CUSTOMER_NAME';
	g_attr_type(6) := null;

	g_attr_name(7) :='CUSTOMER_SITE_NAME';
	g_attr_type(7) := null;

	g_attr_name(8) :='CRITICAL_COMPONENT_FLAG';
	g_attr_name(9) :='FULL_LEAD_TIME';
	g_attr_name(10) :='PREPROCESSING_LEAD_TIME';
	g_attr_name(11) :='POSTPROCESSING_LEAD_TIME';
	g_attr_name(12) :='FIXED_LEAD_TIME';
	g_attr_name(13) :='VARIABLE_LEAD_TIME';
	g_attr_name(14) :='FIXED_ORDER_QUANTITY';
	g_attr_name(15) :='FIXED_DAYS_SUPPLY';
	g_attr_name(16) :='SHRINKAGE_RATE';
	g_attr_name(17) :='FIXED_LOT_MULTIPLIER';
	g_attr_name(18) :='MINIMUM_ORDER_QUANTITY';
	g_attr_name(19) :='MAXIMUM_ORDER_QUANTITY';
	g_attr_name(20) :='SERVICE_LEVEL';
	g_attr_name(21) :='CARRYING_COST';
	g_attr_name(22) :='DEMAND_TIME_FENCE_DAYS';
	g_attr_name(23) :='ATO_FORECAST_CONTROL';
	g_attr_name(24) :='PLANNING_TIME_FENCE_DAYS';
	g_attr_name(25) :='STANDARD_COST';
	g_attr_name(26) :='PIP_FLAG';
	g_attr_name(27) :='LIST_PRICE';
	g_attr_name(28) :='SUBSTITUTION_WINDOW';
	g_attr_name(29) :='SAFETY_STOCK_BUCKET_DAYS';
	g_attr_name(30) :='UNIT_WEIGHT';
	g_attr_name(31) :='UNIT_VOLUME';
	g_attr_name(32) :='SAFETY_STOCK_CODE';
	g_attr_name(33) :='SAFETY_STOCK_PERCENT';
	g_attr_name(34) :='ABC_CLASS_NAME';
	g_attr_name(35) :='MRP_PLANNING_CODE';
	g_attr_name(36) :='DRP_PLANNED';
	g_attr_name(37) :='DAYS_MAX_INV_SUPPLY';
	g_attr_name(38) :='DAYS_MAX_INV_WINDOW';
	g_attr_name(39) :='DAYS_TGT_INV_SUPPLY';
	g_attr_name(40) :='DAYS_TGT_INV_WINDOW';
	g_attr_name(41) :='CONTINOUS_TRANSFER';
	g_attr_name(42) :='CONVERGENCE';
	g_attr_name(43) :='CREATE_SUPPLY_FLAG';
	g_attr_name(44) :='DIVERGENCE';
	g_attr_name(45) :='PLANNING_EXCEPTION_SET';
	g_attr_name(46) :='INVENTORY_USE_UP_DATE';
	g_attr_name(47) :='PLANNING_MAKE_BUY_CODE';
	g_attr_name(48) :='WEIGHT_UOM';
	g_attr_name(49) :='VOLUME_UOM';
	g_attr_name(50) :='ROUNDING_CONTROL_TYPE';
	g_attr_name(51) :='ATP_FLAG';
	g_attr_name(52) :='ATP_COMPONENTS_FLAG';
	g_attr_name(53) :='DEMAND_FULFILLMENT_LT';
	g_attr_name(54) :='LOTS_EXPIRATION';
	g_attr_name(55) :='CONSIGNED_FLAG';
	g_attr_name(56) :='LEADTIME_VARIABILITY';
	g_attr_name(57) :='PLANNER_CODE';
	g_attr_name(58) :='EO_FLAG';
	g_attr_name(59) :='EXCESS_HORIZON';
	g_attr_name(60) :='OBSOLESCENCE_DATE';
	g_attr_name(61) :='REPAIR_LEAD_TIME';
	g_attr_name(62) :='REPAIR_YIELD';
	g_attr_name(63) :='REPAIR_COST';
	g_attr_name(64) :='RELIABILITY';
	g_attr_name(65) :='FAILURE_IMPACT';
	g_attr_name(66) :='STANDARD_DEVIATION';
	g_attr_name(67) :='COEFFICIENT_OF_VARIATION';
	g_attr_name(68) :='BASIS_AVG_DAILY_DEMAND';
	g_attr_name(69) :='FORECAST_RULE_FOR_DEMANDS';
	g_attr_name(70) :='FORECAST_RULE_FOR_RETURNS';
	g_attr_name(71) :='LIFE_TIME_BUY_DATE';
	g_attr_name(72) :='END_OF_LIFE_DATE';
	g_attr_name(73) :='AVG_DEMAND_BEYOND_PH';
	g_attr_name(74) :='AVG_RETURNS_BEYOND_PH';
	g_attr_name(75) :='RETURN_FORECAST_TIME_FENCE';
	g_attr_name(76) :='AVERAGE_DAILY_DEMAND';
	g_attr_name(77) :='DEFECTIVE_ITEM_COST';
	g_attr_name(78) :='STD_DEVIATION_FOR_DEMAND';
	g_attr_name(79) :='MEAN_INTER_ARRIVAL';
	g_attr_name(80) :='STD_DEVIATION_INTER_ARRIVAL';
	g_attr_name(81) :='INTERARRIVAL_DIST_METHOD';
	g_attr_name(82) :='INTERMITTENT_DEMAND';
	g_attr_name(83) :='MAX_USAGE_FACTOR';
	g_attr_name(84) :='MIN_REM_SHELF_LIFE_DAYS';
	g_attr_name(85) :='UNSATISFIED_DEMAND_FACTOR';
	g_attr_name(86) :='DMD_SATISFIED_PERCENT';
	g_attr_name(87) :='MIN_SUP_DEM_PERCENT';
	g_attr_name(88) :='ROP_SAFETY_STOCK';
	g_attr_name(89) := 'COMPUTE_SS';
	g_attr_name(90) := 'COMPUTE_EOQ';
	g_attr_name(91) := 'ORDER_COST';

	i := 8;
	loop
		l_count:=0;
	--	msc_util.msc_debug('in init i='||i);
		open c_lov_type_count(g_attr_name(i));
		fetch c_lov_type_count into l_count;
		close c_lov_type_count;
	--	msc_util.msc_debug('l_count:'||l_count);
		if l_count=0 then
			g_attr_type(i) := 2;
			g_sql_stmt(i) := null;
		else
			open c_lov_type(g_attr_name(i));
			fetch c_lov_type into g_attr_type(i),g_sql_stmt(i);
			close c_lov_type;
		end if;
		if g_attr_name.count = i then
			exit;
		end if;
		i:=i+1;
	end loop;

end init;

procedure set_attr_val(l_imm_stg_rec imm_stg_Rec) is
i number :=1;
begin
	g_attr_val(1)  :=  l_imm_stg_rec.SIMULATION_SET_NAME;
	g_attr_val(2)  :=  l_imm_stg_rec.ITEM_NAME;
	g_attr_val(3)  :=  l_imm_stg_rec.ORGANIZATION_CODE;
	g_attr_val(4)  :=  l_imm_stg_rec.SR_INSTANCE_CODE;
	g_attr_val(5)  :=  l_imm_stg_rec.ZONE;
	g_attr_val(6)  :=  l_imm_stg_rec.CUSTOMER_NAME;
	g_attr_val(7)  :=  l_imm_stg_rec.CUSTOMER_SITE_NAME;
	g_attr_val(8)  :=  l_imm_stg_rec.CRITICAL_COMPONENT_FLAG;
	g_attr_val(9)  :=  l_imm_stg_rec.FULL_LEAD_TIME;
	g_attr_val(10) :=  l_imm_stg_rec.PREPROCESSING_LEAD_TIME;
	g_attr_val(11) :=  l_imm_stg_rec.POSTPROCESSING_LEAD_TIME;
	g_attr_val(12) :=  l_imm_stg_rec.FIXED_LEAD_TIME;
	g_attr_val(13) :=  l_imm_stg_rec.VARIABLE_LEAD_TIME;
	g_attr_val(14) :=  l_imm_stg_rec.FIXED_ORDER_QUANTITY;
	g_attr_val(15) :=  l_imm_stg_rec.FIXED_DAYS_SUPPLY;
	g_attr_val(16) :=  l_imm_stg_rec.SHRINKAGE_RATE;
	g_attr_val(17) :=  l_imm_stg_rec.FIXED_LOT_MULTIPLIER;
	g_attr_val(18) :=  l_imm_stg_rec.MINIMUM_ORDER_QUANTITY;
	g_attr_val(19) :=  l_imm_stg_rec.MAXIMUM_ORDER_QUANTITY;
	g_attr_val(20) :=  l_imm_stg_rec.SERVICE_LEVEL;
	g_attr_val(21) :=  l_imm_stg_rec.CARRYING_COST;
	g_attr_val(22) :=  l_imm_stg_rec.DEMAND_TIME_FENCE_DAYS;
	g_attr_val(23) :=  l_imm_stg_rec.ATO_FORECAST_CONTROL;
	g_attr_val(24) :=  l_imm_stg_rec.PLANNING_TIME_FENCE_DAYS;
	g_attr_val(25) :=  l_imm_stg_rec.STANDARD_COST;
	g_attr_val(26) :=  l_imm_stg_rec.PIP_FLAG;
	g_attr_val(27) :=  l_imm_stg_rec.LIST_PRICE;
	g_attr_val(28) :=  l_imm_stg_rec.SUBSTITUTION_WINDOW;
	g_attr_val(29) :=  l_imm_stg_rec.SAFETY_STOCK_BUCKET_DAYS;
	g_attr_val(30) :=  l_imm_stg_rec.UNIT_WEIGHT;
	g_attr_val(31) :=  l_imm_stg_rec.UNIT_VOLUME;
	g_attr_val(32) :=  l_imm_stg_rec.SAFETY_STOCK_CODE;
	g_attr_val(33) :=  l_imm_stg_rec.SAFETY_STOCK_PERCENT;
	g_attr_val(34) :=  l_imm_stg_rec.ABC_CLASS_NAME;
	g_attr_val(35) :=  l_imm_stg_rec.MRP_PLANNING_CODE;
	g_attr_val(36) :=  l_imm_stg_rec.DRP_PLANNED;
	g_attr_val(37) :=  l_imm_stg_rec.DAYS_MAX_INV_SUPPLY;
	g_attr_val(38) :=  l_imm_stg_rec.DAYS_MAX_INV_WINDOW;
	g_attr_val(39) :=  l_imm_stg_rec.DAYS_TGT_INV_SUPPLY;
	g_attr_val(40) :=  l_imm_stg_rec.DAYS_TGT_INV_WINDOW;
	g_attr_val(41) :=  l_imm_stg_rec.CONTINOUS_TRANSFER;
	g_attr_val(42) :=  l_imm_stg_rec.CONVERGENCE;
	g_attr_val(43) :=  l_imm_stg_rec.CREATE_SUPPLY_FLAG;
	g_attr_val(44) :=  l_imm_stg_rec.DIVERGENCE;
	g_attr_val(45) :=  l_imm_stg_rec.PLANNING_EXCEPTION_SET;
	g_attr_val(46) :=  l_imm_stg_rec.INVENTORY_USE_UP_DATE;
	g_attr_val(47) :=  l_imm_stg_rec.PLANNING_MAKE_BUY_CODE;
	g_attr_val(48) :=  l_imm_stg_rec.WEIGHT_UOM;
	g_attr_val(49) :=  l_imm_stg_rec.VOLUME_UOM;
	g_attr_val(50) :=  l_imm_stg_rec.ROUNDING_CONTROL_TYPE;
	g_attr_val(51) :=  l_imm_stg_rec.ATP_FLAG;
	g_attr_val(52) :=  l_imm_stg_rec.ATP_COMPONENTS_FLAG;
	g_attr_val(53) :=  l_imm_stg_rec.DEMAND_FULFILLMENT_LT;
	g_attr_val(54) :=  l_imm_stg_rec.LOTS_EXPIRATION;
	g_attr_val(55) :=  l_imm_stg_rec.CONSIGNED_FLAG;
	g_attr_val(56) :=  l_imm_stg_rec.LEADTIME_VARIABILITY;
	g_attr_val(57) :=  l_imm_stg_rec.PLANNER_CODE;
	g_attr_val(58) :=  l_imm_stg_rec.EO_FLAG;
	g_attr_val(59) :=  l_imm_stg_rec.EXCESS_HORIZON;
	g_attr_val(60) :=  l_imm_stg_rec.OBSOLESCENCE_DATE;
	g_attr_val(61) :=  l_imm_stg_rec.REPAIR_LEAD_TIME;
	g_attr_val(62) :=  l_imm_stg_rec.REPAIR_YIELD;
	g_attr_val(63) :=  l_imm_stg_rec.REPAIR_COST;
	g_attr_val(64) :=  l_imm_stg_rec.RELIABILITY;
	g_attr_val(65) :=  l_imm_stg_rec.FAILURE_IMPACT;
	g_attr_val(66) :=  l_imm_stg_rec.STANDARD_DEVIATION;
	g_attr_val(67) :=  l_imm_stg_rec.COEFFICIENT_OF_VARIATION;
	g_attr_val(68) :=  l_imm_stg_rec.BASIS_AVG_DAILY_DEMAND;
	g_attr_val(69) :=  l_imm_stg_rec.FORECAST_RULE_FOR_DEMANDS;
	g_attr_val(70) :=  l_imm_stg_rec.FORECAST_RULE_FOR_RETURNS;
	g_attr_val(71) :=  l_imm_stg_rec.LIFE_TIME_BUY_DATE;
	g_attr_val(72) :=  l_imm_stg_rec.END_OF_LIFE_DATE;
	g_attr_val(73) :=  l_imm_stg_rec.AVG_DEMAND_BEYOND_PH;
	g_attr_val(74) :=  l_imm_stg_rec.AVG_RETURNS_BEYOND_PH;
	g_attr_val(75) :=  l_imm_stg_rec.RETURN_FORECAST_TIME_FENCE;
	g_attr_val(76) :=  l_imm_stg_rec.AVERAGE_DAILY_DEMAND;
	g_attr_val(77) :=  l_imm_stg_rec.DEFECTIVE_ITEM_COST;
	g_attr_val(78) :=  l_imm_stg_rec.STD_DEVIATION_FOR_DEMAND;
	g_attr_val(79) :=  l_imm_stg_rec.MEAN_INTER_ARRIVAL;
	g_attr_val(80) :=  l_imm_stg_rec.STD_DEVIATION_INTER_ARRIVAL;
	g_attr_val(81) :=  l_imm_stg_rec.INTERARRIVAL_DIST_METHOD;
	g_attr_val(82) :=  l_imm_stg_rec.INTERMITTENT_DEMAND;
	g_attr_val(83) :=  l_imm_stg_rec.MAX_USAGE_FACTOR;
	g_attr_val(84) :=  l_imm_stg_rec.MIN_REM_SHELF_LIFE_DAYS;
	g_attr_val(85) :=  l_imm_stg_rec.UNSATISFIED_DEMAND_FACTOR;
	g_attr_val(86) :=  l_imm_stg_rec.DMD_SATISFIED_PERCENT;
	g_attr_val(87) :=  l_imm_stg_rec.MIN_SUP_DEM_PERCENT;
	g_attr_val(88) :=  l_imm_stg_rec.ROP_SAFETY_STOCK;
	g_attr_val(89) :=  l_imm_stg_rec.COMPUTE_SS;
	g_attr_val(90) :=  l_imm_stg_rec.COMPUTE_EOQ;
	g_attr_val(91) :=  l_imm_stg_rec.ORDER_COST;
end set_attr_val;

/*
  This procedure posts a record into msc_item_attributes table

*/
procedure update_record_to_db(stg_rec_rowid VARCHAR2) is

   cursor c_get_simset_id(l_simset_name varchar2) is
   select simulation_set_id
   from msc_item_simulation_sets
   where simulation_set_name = l_simset_name;

   cursor c_get_item_id(l_item_name varchar2,l_org_id number,l_inst_id number) is
   select distinct inventory_item_id
   from msc_system_items
   where item_name = l_item_name and
         organization_id = l_org_id and
         sr_instance_id = l_inst_id and
         plan_id = -1;

   cursor c_get_org_id(l_org_code varchar2) is
   select sr_tp_id
   from msc_trading_partners
   where organization_code = l_org_code;

   cursor c_get_inst_id(l_inst_code varchar2) is
   select instance_id
   from msc_apps_instances
   where instance_code=l_inst_code;

   cursor c_get_zone_id(l_zone varchar2,l_sr_instance_id number) is
   select region_id
   from msc_regions
   where zone=l_zone and
   sr_instance_id=l_sr_instance_id;

   cursor c_get_customer_id(l_cust_name varchar2,l_sr_instance_id number) is
   select partner_id
   from msc_trading_partners
   where partner_type=2 and
   partner_name = l_cust_name and
   sr_instance_id = l_sr_instance_id;

   cursor c_get_cust_site_id (l_cust_id number,l_sr_instance_id number,l_tp_site_code varchar2) is
   select sr_tp_site_id
   from msc_trading_partner_sites
   where partner_id=l_cust_id and
   tp_site_code=l_tp_site_code and
   sr_instance_id = l_sr_instance_id;

   cursor c_get_dest_rowid(l_simset_id number,l_item_id number,l_org_id number,l_inst_id number,l_zone_id number,l_cust_id number,l_site_id number) is
   select rowid
   from msc_item_attributes
   where simulation_set_id=l_simset_id and
   	 inventory_item_id=l_item_id and
   	 organization_id=l_org_id and
   	 sr_instance_id= l_inst_id and
   	 ( region_id=l_zone_id
         or (region_id is null and l_zone_id is null)) and
   	 ( customer_id=l_cust_id
         or (customer_id is null and l_cust_id is null)) and
   	 ( customer_site_id=l_site_id
         or (customer_site_id is null and l_site_id is null));



   l_sim_set_id number;
   l_org_id number;
   l_inst_id number;
   l_item_id number;
   l_zone_id number;
   l_cust_id number;
   l_site_id number;
   l_dest_rowid varchar2(80);

   l_update_stmt varchar2(32000);
   l_insert_stmt varchar2(32000);
   l_insert_cols varchar2(32000);
   l_insert_vals varchar2(32000);

   l_zone_val varchar2(10);
   l_cust_val varchar2(10);
   l_site_val varchar2(10);
   l_sql varchar2(4000);

   Type attr_sql_type is REF CURSOR;
   c_attr_sql attr_sql_type;
   l_hidden varchar2(100);
   l_meaning varchar2(240);
   l_old_val varchar2(240);
   l_first number := 1;

   i number;
   l_upd_attr_count number :=0;
begin
	msc_util.msc_debug('In update proc.. '||g_attr_val(1)||'-'||g_attr_val(2));
	open c_get_simset_id(g_attr_val(1));
	fetch c_get_simset_id into l_sim_set_id;
	close c_get_simset_id;
	msc_util.msc_debug('sim set id'||l_sim_set_id);
	if l_sim_set_id is null	then
		msc_util.msc_debug('Simulation Set Name:'||g_attr_val(1)||' doesnt exist');
		return;
	end if;

	open c_get_org_id(g_attr_val(3));
	fetch c_get_org_id into l_org_id;
	close c_get_org_id;
	msc_util.msc_debug('org id'||l_org_id);
	if l_org_id is null then
		msc_util.msc_debug('Organization Code:'||g_attr_val(3)||' doesnt exist');
		return;
	end if;

	open c_get_inst_id(g_attr_val(4));
	fetch c_get_inst_id into l_inst_id;
	close c_get_inst_id;

	if l_inst_id is null then
		msc_util.msc_debug('Sr Instance Code:'||g_attr_val(4)||' doesnt exist');
		return;
	end if;

	open c_get_item_id(g_attr_val(2),l_org_id,l_inst_id);
	fetch c_get_item_id into l_item_id;
	close c_get_item_id;
	msc_util.msc_debug('item id'||l_item_id);
	if l_item_id is null then
		msc_util.msc_debug('Item name:'||g_attr_val(2)||' doesnt exist');
		return;
	end if;

	open c_get_zone_id(g_attr_val(5),l_inst_id);
	fetch c_get_zone_id into l_zone_id;
	close c_get_zone_id;
	msc_util.msc_debug('zone id:'||l_zone_id);

	open c_get_customer_id(g_attr_val(6),l_inst_id);
	fetch c_get_customer_id into l_cust_id;
	close c_get_customer_id;
	msc_util.msc_debug('cust id:'||l_cust_id);

	open c_get_cust_site_id(l_cust_id,l_inst_id,g_attr_val(7));
	fetch c_get_cust_site_id into l_site_id;
	close c_get_cust_site_id;
	msc_util.msc_debug('site id:'||l_site_id);

	if(l_zone_id is not null and l_cust_id is not null) then
		msc_util.msc_debug('Both zone and customer value were provided for record with simulation set name,item name:'||g_attr_val(1)||','||g_attr_val(2));
		return;
	end if;

	--if(l_zone_id is not null) then
	--elsif l_cust_id is not null then
	--else
	open c_get_dest_rowid(l_sim_set_id,l_item_id,l_org_id,l_inst_id,l_zone_id,l_cust_id,l_site_id);
	fetch c_get_dest_rowid into l_dest_rowid;
	close c_get_dest_rowid;

	msc_util.msc_debug('l_dest_row_id:'||l_dest_rowid);
	l_first := 1;
	if l_dest_rowid is not null then  -- row exists in msc_item_attributes

		l_update_stmt := 'update msc_item_attributes set ';
		msc_util.msc_debug('l_update_stmt:'||l_update_stmt);
		i := 8;
		loop
--		--	msc_util.msc_debug('i,count'||i||':'||g_attr_name.count);
--		--	msc_util.msc_debug('type,val'||g_attr_type(i)||','||g_attr_val(i));
			if(g_attr_val(i) is not null) then
				if g_attr_type(i) = 1 then -- number
					l_hidden := to_char(g_attr_val(i));

				elsif g_attr_type(i) = 2 then --char
					if g_sql_stmt(i) is not null then
						l_sql := 'select hidden,displayed from ('||g_sql_stmt(i)||') where displayed='||''''||g_attr_val(i)||'''';
						msc_util.msc_debug('sql stmt:'||l_sql);
						open c_attr_sql for l_sql;
						fetch c_attr_sql into l_hidden,l_meaning;
						close c_attr_sql;
					else
						l_hidden := g_attr_val(i);
					end if;
					-- following attributes are char columns in msc_item_attributes so add quotes to the value.
					if g_attr_name(i) in ('PLANNING_EXCEPTION_SET','WEIGHT_UOM','VOLUME_UOM','ATP_FLAG','ATP_COMPONENTS_FLAG','ABC_CLASS_NAME','PLANNER_CODE','RELIABILITY','FAILURE_IMPACT','INTERARRIVAL_DIST_METHOD') then
						l_hidden := ''''||l_hidden||'''';
					end if;
					--msc_util.msc_debug('l_hidden,l_meaning:'||l_hidden||','||l_meaning);

				else
					null;
				end if;
				l_sql := 'select '||g_attr_name(i)||' from msc_item_attributes where rowid='||''''||l_dest_rowid||'''';

				msc_util.msc_debug('l_sql:'||l_sql);
				open c_attr_sql for l_sql;
				fetch c_attr_sql into l_old_val;
				close c_attr_sql;

				if(l_first = 1) then
					l_update_stmt := l_update_stmt||g_attr_name(i)||'='||l_hidden;
					l_first := 2;
				else
					l_update_stmt := l_update_stmt||','||g_attr_name(i)||'='||l_hidden;
				end if;

				if l_old_val is null then
					l_upd_attr_count := l_upd_attr_count+1;
				end if;
			end if;
		--	msc_util.msc_debug('l_update_stmt:'||l_update_stmt);
			if i=g_attr_name.count then
				exit;
			end if;
			i:=i+1;
		end loop;
		l_update_stmt := l_update_stmt||',updated_columns_count=updated_columns_count+'||l_upd_attr_count;
		l_update_stmt := l_update_stmt||' where rowid='||''''||l_dest_rowid||'''';
		msc_util.msc_debug('update stmt:'||l_update_stmt);
		msc_Get_name.execute_dsql(l_update_stmt);

	else	-- dest row id is null so insert row into msc_item_attributes
		l_zone_val := nvl(to_char(l_zone_id),'null');
		l_cust_val := nvl(to_char(l_cust_id),'null');
		l_site_val := nvl(to_char(l_site_id),'null');
		l_insert_stmt := 'insert into msc_item_attributes ';
		l_insert_cols := 'plan_id,simulation_set_id,inventory_item_id,organization_id,sr_instance_id,created_by,creation_date,last_update_date,last_updated_by,last_update_login,region_id,region_instance_id,customer_id,customer_site_id,customer_instance_id';
		l_insert_vals := '-1,'||l_sim_set_id||','||l_item_id||','||l_org_id||','||l_inst_id||','||1||',sysdate,sysdate,'||1||','||1||','||l_zone_val||','||l_inst_id||','||l_cust_val||','||l_site_val||','||l_inst_id;
		l_upd_attr_count :=0;
		i := 8;

		loop
--			msc_util.msc_debug('i,count'||i||':'||g_attr_name.count);
--			msc_util.msc_debug('type,val'||g_attr_type(i)||','||g_attr_val(i));
			if g_attr_val(i) is not null then
				if g_attr_type(i) = 1  then -- number
					l_hidden := g_attr_val(i);

				elsif g_attr_type(i) = 2 then --char
					--build a dynamic sql attaching meaning and get hidden value
					if g_sql_stmt(i) is not null then
						l_sql := 'select hidden,displayed from ('||g_sql_stmt(i)||') where displayed='||''''||g_attr_val(i)||'''';
						msc_util.msc_debug('sql stmt:'||l_sql);
						open c_attr_sql for l_sql;
						fetch c_attr_sql into l_hidden,l_meaning;
						close c_attr_sql;
					else
						l_hidden := g_attr_val(i);
					end if;
						-- following attributes are char columns in msc_item_attributes so add quotes to the value.
					if g_attr_name(i) in ('PLANNING_EXCEPTION_SET','WEIGHT_UOM','VOLUME_UOM','ATP_FLAG','ATP_COMPONENTS_FLAG','ABC_CLASS_NAME','PLANNER_CODE','RELIABILITY','FAILURE_IMPACT','INTERARRIVAL_DIST_METHOD') then
						l_hidden := ''''||l_hidden||'''';
					end if;
						--msc_util.msc_debug('l_hidden,l_meaning:'||l_hidden||','||l_meaning);

				else
					null;
				end if;
				l_insert_cols := l_insert_cols||','||g_attr_name(i);
				l_insert_vals := l_insert_vals||','||l_hidden;
				l_upd_attr_count := l_upd_attr_count+1;
			end if;
	--		msc_util.msc_debug('l_insert_stmt:'||l_insert_stmt);
			if i=g_attr_name.count then
				exit;
			end if;
			i:=i+1;
		end loop;
		l_insert_stmt := l_insert_stmt||'('||l_insert_cols||',updated_columns_count) values ('||l_insert_vals||','||l_upd_attr_count||')';
		msc_util.msc_debug('insert stmt:'||l_insert_stmt);
		msc_Get_name.execute_dsql(l_insert_stmt);
	end if;

	delete from msc_st_item_attributes where rowid=stg_rec_rowid;
	commit;
end update_record_to_db;

function sim_set(p_plan_id number) return varchar2 is

 cursor c_sim_set(l_plan_id number) is
 select simulation_set_name from
 msc_item_simulation_sets ms,
 msc_plans mp
 where mp.plan_id=l_plan_id and ms.simulation_set_id = mp.item_simulation_set_id;

 l_sim_set varchar2(80);
begin
  open c_sim_set(p_plan_id);
  fetch c_sim_set into l_sim_set;
  close c_sim_set;

  return l_sim_set;
end sim_set;

procedure attach_simset_toplan(p_plan_id number, p_simset varchar2) is
 cursor c_nextval is
 SELECT msc_item_simulation_sets_s.nextval
 FROM   dual;

 cursor c_simset_id is
 select simulation_set_id from msc_item_simulation_sets where simulation_set_name = p_simset;

 l_count number;
 l_simset_id number;
begin

 open c_simset_id;
 fetch c_simset_id into l_simset_id;
 close c_simset_id;

 if l_simset_id is null then
 	open c_nextval;
 	fetch c_nextval into l_simset_id;
 	close c_nextval;

 	insert into msc_item_simulation_sets(simulation_set_name,simulation_set_id,last_update_date,last_updated_by,last_update_login,created_by,creation_date) values (p_simset,l_simset_id,sysdate,1,1,1,sysdate);
 	commit;
  end if;

  if sim_set(p_plan_id) is null or sim_set(p_plan_id)<>p_simset then
  	update msc_plans set item_simulation_set_id = l_simset_id where plan_id=p_plan_id;
  end if;

  commit;

end attach_simset_toplan;

procedure get_sql(p_attr_name varchar2,p_sql out nocopy varchar2,p_lov_type out nocopy number) is
cursor c_sql is
 select sql_statement,lov_type from
 msc_criteria where
 folder_object in ('MSC_IMM_UPDATE_ATTRIBUTES',
		  'MSC_REGION_UPDATE_ATTRIBUTES',
		  'MSC_CUST_UPDATE_ATTRIBUTES',
		  'MSC_IMM_DESTINATION_ATTRIBUTES'
		  )
and field_name = p_attr_name;
begin

 open c_sql;
 fetch c_sql into p_sql,p_lov_type;
 close c_sql;

end get_sql;

procedure modify_imm_item_attr(p_plan_id number,
                               p_attr_name varchar2,
                               p_attr_val varchar2,
                               p_item_id number,
                               p_org_id number,
                               p_inst_id number) is

 cursor c_simset_id is
 select item_simulation_set_id
 from msc_plans
 where plan_id = p_plan_id;

 cursor c_dest_rowid(p_simset_id number) is
 select rowid
 from msc_item_attributes
 where simulation_set_id=p_simset_id and
 	inventory_item_id = p_item_id and
 	organization_id = p_org_id and
 	sr_instance_id = p_inst_id and
 	region_id is null and
 	customer_id is null;

 l_simset_id number;
 l_lov_type number;
 l_sql varchar2(32000);
 l_old_val varchar2(240);
 l_rowid varchar2(100);

 l_attr_val varchar2(100);
 l_upd_count number := 0;

 type dyn_cur is REF CURSOR;
 c_attr_sql dyn_cur;
begin
null;

 open c_simset_id;
 fetch c_simset_id into l_simset_id;
 close c_simset_id;

 open c_dest_rowid(l_simset_id);
 fetch c_dest_rowid into l_rowid;
 close c_dest_rowid;

 get_sql(p_attr_name,l_sql,l_lov_type);
 if l_lov_type in (2,6)  then
 	l_attr_val := ''''||p_attr_val||'''';
   if l_lov_type = 6 then
 	l_attr_val := ' to_date('||l_attr_val||')';
   end if;
 else
 	l_attr_val := p_attr_val;
 end if;


 if l_rowid is null then -- insert record into msc_item_attributes

 	l_sql := 'insert into msc_item_attributes(plan_id,simulation_set_id,'||
 					'inventory_item_id,'||
 					'organization_id,'||
 					'sr_instance_id,'||
 					p_attr_name||','||
 					'updated_columns_count,'||
 					'last_updated_by,'||
 					'last_update_date,'||
 					'last_update_login,'||
 					'creation_date,'||
 					'created_by) values (-1,'||
 					l_simset_id||','||
 					p_item_id||','||
 					p_org_id||','||
 					p_inst_id||','||
 					l_attr_val||','||
 					1||','||
 					1||','||
 					'sysdate'||','||
 					1||','||
 					'sysdate'||','||
 					1||')';

 	msc_get_name.execute_dsql(l_sql);
 	commit;
 else -- update existing row

  	l_sql := 'select '||p_attr_name||',updated_columns_count from msc_item_attributes where rowid='||''''||l_rowid||'''';


	open c_attr_sql for l_sql;
	fetch c_attr_sql into l_old_val,l_upd_count;
	close c_attr_sql;

	if l_old_val is null then
 		l_upd_count := l_upd_count+1;
 	end if;

 	l_sql := 'update msc_item_attributes set '||p_attr_name||'='||l_attr_val||',updated_columns_count='||l_upd_count||
 		 ' where rowid='||''''||l_rowid||'''';

	msc_get_name.execute_dsql(l_sql);
	commit;

 end if;

end modify_imm_item_attr;

procedure modify_plan_item_attr(p_plan_id number,
				p_attr_name varchar2,
				p_attr_val varchar2,
				p_item_id number,
				p_org_id number,
				p_sr_instance_id number) is
l_sql varchar2(32000);
l_lov_type number;

l_attr_val varchar2(240);

begin

 get_sql(p_attr_name,l_sql,l_lov_type);

 if l_lov_type in (2,6) then
 	l_attr_val := ''''||p_attr_val||'''';
 	if l_lov_type = 6 then
 		l_attr_val := ' to_date('||l_attr_val||')';
 	end if;
 else
 	l_attr_val := p_attr_val;
 end if;

 l_sql := 'update msc_system_items set '||p_attr_name||'='||l_attr_val||
  	  ' where plan_id='||p_plan_id||' and inventory_item_id ='||p_item_id||' and organization_id='||p_org_id||' and sr_instance_id='||p_sr_instance_id;

 msc_get_name.execute_dsql(l_sql);

  l_sql := 'update msc_supplies set applied=2,status=0'||
  	  ' where plan_id='||p_plan_id||' and inventory_item_id ='||p_item_id||' and organization_id='||p_org_id||' and sr_instance_id='||p_sr_instance_id;

  msc_get_name.execute_dsql(l_sql);

   l_sql := 'update msc_demands set applied=2,status=0'||
  	  ' where plan_id='||p_plan_id||' and inventory_item_id ='||p_item_id||' and organization_id='||p_org_id||' and sr_instance_id='||p_sr_instance_id;

    msc_get_name.execute_dsql(l_sql);

     l_sql := 'update msc_supplier_capacities set applied=2,status=0'||
  	  ' where plan_id='||p_plan_id||' and inventory_item_id ='||p_item_id||' and organization_id='||p_org_id||' and sr_instance_id='||p_sr_instance_id;

  msc_get_name.execute_dsql(l_sql);
 commit;


end modify_plan_item_attr;

function get_real_attrname(p_attr_name varchar2) return varchar2 is
l_real_name varchar2(100);
begin
	l_real_name := p_attr_name;
	if p_attr_name = 'ATO_FORECAST_CONTROL_TEXT' then
		l_real_name := 'ATO_FORECAST_CONTROL';
	elsif p_attr_name = 'CONTINOUS_TRANSFER_TEXT' then
		l_real_name := 'CONTINOUS_TRANSFER';
	elsif p_attr_name = 'FCST_RULE_FOR_DEMANDS_TEXT' then
		l_real_name := 'FORECAST_RULE_FOR_DEMANDS';
	elsif p_attr_name = 'FCST_RULE_FOR_RETURNS_TEXT' then
		l_real_name := 'FORECAST_RULE_FOR_RETURNS';
	elsif p_attr_name = 'INTERARRIVAL_TIME' then
		l_real_name := 'MEAN_INTER_ARRIVAL';
	elsif p_attr_name = 'SAFETY_STOCK_DAYS' then
		l_real_name := 'SAFETY_STOCK_BUCKET_DAYS';
	end if;

	return l_real_name;
end get_real_attrname;


PROCEDURE load_frm_stg_tbl (
				errbuf                  OUT NOCOPY VARCHAR2,
                                retcode                 OUT NOCOPY NUMBER,
                                req_id		in 	number,
				stg_tbl		in	varchar2 Default 'MSC_ST_ITEM_ATTRIBUTES'
				) is

Type imm_stg_tbl is REF CURSOR;
c_imm_stg_tbl imm_stg_tbl;
l_imm_stg_rec imm_stg_rec;


cursor c_imm_stg_rec_count(l_req_id number) is
select count(*) from msc_st_item_attributes where request_id=l_req_id;

cursor c_max_req_id is
select max(request_id) from msc_st_item_attributes;

cursor c_imm_stg(l_req_id number) is
select
	ROWID,
	SIMULATION_SET_NAME,
	ITEM_NAME,
	ORGANIZATION_CODE,
	SR_INSTANCE_CODE,
	ZONE,
	CUSTOMER_NAME,
	CUSTOMER_SITE_NAME,
	CRITICAL_COMPONENT_FLAG,
	FULL_LEAD_TIME,
	PREPROCESSING_LEAD_TIME,
	POSTPROCESSING_LEAD_TIME,
	FIXED_LEAD_TIME,
	VARIABLE_LEAD_TIME,
	FIXED_ORDER_QUANTITY,
	FIXED_DAYS_SUPPLY,
	SHRINKAGE_RATE,
	FIXED_LOT_MULTIPLIER,
	MINIMUM_ORDER_QUANTITY,
	MAXIMUM_ORDER_QUANTITY,
	SERVICE_LEVEL,
	CARRYING_COST,
	DEMAND_TIME_FENCE_DAYS,
	ATO_FORECAST_CONTROL,
	PLANNING_TIME_FENCE_DAYS,
	STANDARD_COST,
	PIP_FLAG,
	LIST_PRICE,
	SUBSTITUTION_WINDOW,
	SAFETY_STOCK_BUCKET_DAYS,
	UNIT_WEIGHT,
	UNIT_VOLUME,
	SAFETY_STOCK_CODE,
	SAFETY_STOCK_PERCENT,
	ABC_CLASS_NAME,
	MRP_PLANNING_CODE,
	DRP_PLANNED,
	DAYS_MAX_INV_SUPPLY,
	DAYS_MAX_INV_WINDOW,
	DAYS_TGT_INV_SUPPLY,
	DAYS_TGT_INV_WINDOW,
	CONTINOUS_TRANSFER,
	CONVERGENCE,
	CREATE_SUPPLY_FLAG,
	DIVERGENCE,
	PLANNING_EXCEPTION_SET,
	INVENTORY_USE_UP_DATE,
	PLANNING_MAKE_BUY_CODE,
	WEIGHT_UOM,
	VOLUME_UOM,
	ROUNDING_CONTROL_TYPE,
	ATP_FLAG,
	ATP_COMPONENTS_FLAG,
	DEMAND_FULFILLMENT_LT,
	LOTS_EXPIRATION,
	CONSIGNED_FLAG,
	LEADTIME_VARIABILITY,
	PLANNER_CODE,
	EO_FLAG,
	EXCESS_HORIZON,
	OBSOLESCENCE_DATE,
	REPAIR_LEAD_TIME,
	REPAIR_YIELD,
	REPAIR_COST,
	RELIABILITY,
	FAILURE_IMPACT,
	STANDARD_DEVIATION,
	COEFFICIENT_OF_VARIATION,
	BASIS_AVG_DAILY_DEMAND,
	FORECAST_RULE_FOR_DEMANDS,
	FORECAST_RULE_FOR_RETURNS,
	LIFE_TIME_BUY_DATE,
	END_OF_LIFE_DATE,
	AVG_DEMAND_BEYOND_PH,
	AVG_RETURNS_BEYOND_PH,
	RETURN_FORECAST_TIME_FENCE,
	AVERAGE_DAILY_DEMAND,
	DEFECTIVE_ITEM_COST,
	STD_DEVIATION_FOR_DEMAND,
	MEAN_INTER_ARRIVAL,
	STD_DEVIATION_INTER_ARRIVAL,
	INTERARRIVAL_DIST_METHOD,
	INTERMITTENT_DEMAND,
	MAX_USAGE_FACTOR,
	MIN_REM_SHELF_LIFE_DAYS,
	UNSATISFIED_DEMAND_FACTOR,
	DMD_SATISFIED_PERCENT,
	MIN_SUP_DEM_PERCENT,
	ROP_SAFETY_STOCK,
	COMPUTE_SS,
	COMPUTE_EOQ,
	ORDER_COST
from MSC_ST_ITEM_ATTRIBUTES where request_id=l_req_id;


l_stg_rec_count number;

l_sql_stmt varchar2(32000);
l_select_clause varchar2(32000);
i number;
l_req_id number;

exc_load_fail EXCEPTION;

BEGIN
	msc_util.msc_debug('Staging table name:'||stg_tbl);
	msc_util.msc_debug('Req Id of File Loader is:'||req_id);

	if stg_tbl='MSC_ST_ITEM_ATTRIBUTES' then
		open c_max_req_id;
	 	fetch c_max_req_id into l_req_id;
	 	close c_max_req_id;

	 	if l_req_id is null then
	 		msc_util.msc_debug('No records in staging table MSC_ST_ITEM_ATTRIBUTES');
			return;
	 	end if;

	 	open c_imm_stg_rec_count(l_req_id);
	 	fetch c_imm_stg_rec_count into l_stg_rec_count;
	 	close c_imm_stg_rec_count;

	 	msc_util.msc_debug('No. of records in staging table:'||l_stg_rec_count);

	 	if l_stg_rec_count = 0 then
	 		msc_util.msc_debug('No rows available in MSC_ST_ITEM_ATTRIBUTES');
	 		raise exc_load_fail;
	 	end if;
	 	init; -- This will prepare attribute_names, lov_type, sql_stmt list

	 /*	l_sql_stmt := 'select rowid,';
	 	i := 1;
	 	loop
	 		l_sql_stmt := l_sql_stmt||g_attr_name(i);
	 		if i=g_attr_name.count then
	 			exit;
	 		end if;
	 		l_sql_stmt := l_sql_stmt||', ';
	 		i:=i+1;
	 	end loop;

	 	l_sql_stmt := l_sql_stmt||' from msc_st_item_attributes' ;
	 	--msc_util.msc_debug('l_sql_stmt='||l_sql_stmt);
	 */


	 	msc_util.msc_debug('Max Request Id :'||l_req_id);

	 	open c_imm_stg(l_req_id);
		loop
			fetch c_imm_stg into l_imm_stg_rec;
			exit when c_imm_stg%NOTFOUND;
			msc_util.msc_debug(l_imm_stg_rec.simulation_set_name);
			set_attr_val(l_imm_stg_rec); -- This copies the attribute values of a record into g_attr_val list
			msc_util.msc_debug('after set_attr_val');
			update_record_to_db(l_imm_stg_rec.rowid);
			msc_util.msc_debug('after update_record_to_db');
			commit;
			--msc_util.msc_debug('Fetching values---------------');
			--msc_util.msc_debug(l_imm_stg_rec.simulation_set_name);
		end loop;
		close c_imm_stg;

		msc_util.msc_debug('=============================================');
		msc_util.msc_debug(l_stg_rec_count||' records inserted into staging table');

		open c_imm_stg_rec_count(l_req_id);
	 	fetch c_imm_stg_rec_count into l_stg_rec_count;
	 	close c_imm_stg_rec_count;

		msc_util.msc_debug(l_stg_rec_count||' records not processed properly and not inserted/updated to IMM');
		msc_util.msc_debug('Use the following sql to find out which rows are not processed and inserted/updated to IMM');

	/*	open c_imm_stg_tbl for l_sql_stmt;
		loop
			fetch c_imm_stg_tbl into l_imm_stg_rec;
			exit when c_imm_stg%NOTFOUND;
			msc_util.msc_debug(l_imm_stg_rec.simulation_set_name);
			set_attr_val(l_imm_stg_rec); -- This copies the attribute values of a record into g_attr_val list
			msc_util.msc_debug('after set_attr_val');
			update_record_to_db(l_imm_stg_rec.rowid);
			msc_util.msc_debug('after update_record_to_db');
			commit;
			msc_util.msc_debug('Fetching values---------------');
			msc_util.msc_debug(l_imm_stg_rec.simulation_set_name);
		end loop;
		close c_imm_stg_tbl;
	*/
	end if;

EXCEPTION
   when exc_load_fail then
	retcode := 2;

   when OTHERS THEN
       retcode := 2;
	errbuf := sqlerrm;

END load_frm_stg_tbl;



END MSC_IMPORT_UTIL; -- package

/

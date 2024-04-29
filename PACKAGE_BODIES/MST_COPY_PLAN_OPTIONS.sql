--------------------------------------------------------
--  DDL for Package Body MST_COPY_PLAN_OPTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MST_COPY_PLAN_OPTIONS" AS
/* $Header: MSTCPPOB.pls 120.0 2005/05/26 17:37:29 appldev noship $  */

Type tname_type is table of Varchar2(30);


PROCEDURE copy_plan_options(
                     p_source_plan_id     IN number,
                     p_dest_plan_name     IN varchar2,
                     p_dest_plan_desc     IN varchar2,
                     p_plan_dates_source  IN number,
                     p_dest_start_date    IN date DEFAULT NULL,
                     p_dest_end_date      IN date DEFAULT NULL) IS


v_dest_plan_id       number;
v_dest_start_date    date;
v_dest_end_date      date;
v_statement          varchar2(20000);
l_return_status      varchar2(10);
l_POOLING_FLAG       number;

l_user_id            number;
l_plan_id            number;
BEGIN

  -- Possible values for p_plan_dates_source
  -- 1  Use plan dates from default plan options template
  -- 2  Use plan dates from the source plan
  -- 3  User user specified plan dates

  l_user_id := fnd_global.user_id;

  IF NVL(fnd_profile.value('MST_MTO_LICENSED'),'N') = 'Y' Then
    l_POOLING_FLAG := 1;
  ELSE
    l_POOLING_FLAG := 2;
  END IF;

  if (p_plan_dates_source = 1) then
    begin
      select plan_id
      into l_plan_id
      from mst_plans
      where plan_id = -1-l_user_id;
    exception
      when others then
        l_plan_id := -1;
    end;

    select (sysdate + nvl(system_date_offset, 0)) start_date_new,
           (sysdate + nvl(nvl(system_date_offset,0) + plan_days, 1)) cutoff_date_new
    into v_dest_start_date, v_dest_end_date
    from mst_plans
    where plan_id = l_plan_id;

  elsif (p_plan_dates_source = 2) then
    select start_date, cutoff_date
    into v_dest_start_date, v_dest_end_date
    from mst_plans
    where plan_id = p_source_plan_id;
  elsif (p_plan_dates_source = 3) then
    v_dest_start_date := p_dest_start_date;
    v_dest_end_date := p_dest_end_date;
  else
    v_dest_start_date := p_dest_start_date;
    v_dest_end_date := p_dest_end_date;
  end if;


  select mst_plans_s.nextval
  into v_dest_plan_id
  from dual;

  v_statement :=
              'INSERT INTO MST_PLANS(' ||
	      'plan_id, ' ||
	      'plan_type, ' ||
              'compile_designator, '  ||
              'description, '  ||
              'start_date, '   ||
              'cutoff_date, '  ||
              'OUTSIDE_PROCESSING_FLAG, '  ||
              'DROP_SHIPMENT_FLAG, '  ||
              'SHIP_FROM_SUPPLIER_FLAG, ' ||
              'SHIP_TO_CUSTOMER_FLAG, '  ||
              'RETURN_TO_SUPPLIER_FLAG, '  ||
	      'RETURN_FROM_CUSTOMER_FLAG, '  ||
              'INT_INBOUND_ALL_FLAG, '  ||
              'INT_OUTBOUND_ALL_FLAG, '  ||
              'EXT_OUTBOUND_ALL_FLAG, '  ||
              'EXT_INBOUND_ALL_FLAG, '  ||
              'OPTIMIZATION_STRATEGY_FLAG, '  ||
              'POOLING_FLAG, '  ||
              'MULTI_STOP_TL_FLAG, '  ||
              'CONTINUOUS_MOVE_FLAG, ' ||
	      'OPTIMIZED_FLAG, '  ||
	      'PALLETIZE_FLAG, '  ||
	      'TARGET_TL_UTILIZATION, '  ||
              'MIN_TL_UTILIZATION, '  ||
              'LOCAL_POOLING_SHIPMENT_SIZE, '  ||
              'LOCAL_POOLING_RADIUS, '  ||
              'STOP_NEIGHBORHOOD_RADIUS, '  ||
       	      'GENERAL_POOLING_RADIUS'  ||
	      ',POOL_POINT_COUNT'  ||
	      ',LOADING_UNLOADING_CHARGE'  ||
	      ',LAYOVER_CHARGES'  ||
	      ',ORIGIN_DESTINATION_TL_CHRGS'  ||
	      ',OTHER_TL_CHARGES'  ||
	      ',OTHER_LTL_CHARGES'  ||
	      ',OTHER_PARCEL_CHARGES'  ||
	      ',LTL_DISCOUNT'  ||
	      ',PARCEL_DISCOUNT'  ||
	      ',AUTO_RELEASE'  ||
	      ',AUTO_REL_RULE_SET_ID'  ||
	      ',COMMITMENT_SET_ID'  ||
	      ',CURRENCY_UOM'  ||
	      ',DISTANCE_UOM'  ||
	      ',TIME_UOM'  ||
	      ',VOLUME_UOM'  ||
	      ',WEIGHT_UOM'  ||
	      ',CREATED_BY' ||
              ',CREATION_DATE' ||
              ',LAST_UPDATED_BY' ||
              ',LAST_UPDATE_DATE' ||
              ',LAST_UPDATE_LOGIN' ||
              ',DIMENSION_UOM' ||
	      ',MAXIMUM_EMPTY_LEG_LENGTH) '  ||
  'select   '  ||
              ':v_dest_plan_id, ' ||
              'plan_type, ' ||
              ':p_dest_plan_name, '  ||
              ':p_dest_plan_desc, '  ||
              ':v_dest_start_date, '   ||
              ':v_dest_end_date, '  ||
              'OUTSIDE_PROCESSING_FLAG, '  ||
              'DROP_SHIPMENT_FLAG, '  ||
              'SHIP_FROM_SUPPLIER_FLAG, ' ||
              'SHIP_TO_CUSTOMER_FLAG, '  ||
              'RETURN_TO_SUPPLIER_FLAG, '  ||
              'RETURN_FROM_CUSTOMER_FLAG, '  ||
              'INT_INBOUND_ALL_FLAG, '  ||
              'INT_OUTBOUND_ALL_FLAG, '  ||
              'EXT_OUTBOUND_ALL_FLAG, '  ||
              'EXT_INBOUND_ALL_FLAG, '  ||
              'OPTIMIZATION_STRATEGY_FLAG, '  ||
              l_POOLING_FLAG||',' ||
              'MULTI_STOP_TL_FLAG, '  ||
              'CONTINUOUS_MOVE_FLAG, ' ||
              'OPTIMIZED_FLAG,   '  ||
              'PALLETIZE_FLAG, '  ||
              'TARGET_TL_UTILIZATION, '  ||
              'MIN_TL_UTILIZATION, '  ||
              'LOCAL_POOLING_SHIPMENT_SIZE, '  ||
              'LOCAL_POOLING_RADIUS, '  ||
              'STOP_NEIGHBORHOOD_RADIUS, '  ||
              'GENERAL_POOLING_RADIUS'  ||
              ',POOL_POINT_COUNT'  ||
              ',LOADING_UNLOADING_CHARGE'  ||
              ',LAYOVER_CHARGES'  ||
              ',ORIGIN_DESTINATION_TL_CHRGS'  ||
              ',OTHER_TL_CHARGES'  ||
              ',OTHER_LTL_CHARGES'  ||
              ',OTHER_PARCEL_CHARGES'  ||
              ',LTL_DISCOUNT'  ||
              ',PARCEL_DISCOUNT'  ||
              ',AUTO_RELEASE'  ||
              ',AUTO_REL_RULE_SET_ID'  ||
              ',COMMITMENT_SET_ID'  ||
              ',CURRENCY_UOM'  ||
              ',DISTANCE_UOM'  ||
              ',TIME_UOM'  ||
              ',VOLUME_UOM'  ||
              ',WEIGHT_UOM'  ||
              ',:v_user_id' ||
              ',:v_sysdate' ||
              ',:v_user_id' ||
              ',:v_sysdate' ||
              ',:v_login_id' ||
              ',DIMENSION_UOM' ||
              ',MAXIMUM_EMPTY_LEG_LENGTH '  ||
  'from MST_PLANS '  ||
  'where plan_id = :p_source_plan_id';


  EXECUTE IMMEDIATE v_statement USING v_dest_plan_id, p_dest_plan_name,
    p_dest_plan_desc, v_dest_start_date, v_dest_end_date, fnd_global.user_id,
    sysdate, fnd_global.user_id, sysdate, fnd_global.login_id,
    p_source_plan_id;

  v_statement :=
              'INSERT INTO MST_PLAN_FACILITIES(' ||
 	      'plan_id, ' ||
	      'FACILITY_ID, ' ||
              'INT_INBOUND_FLAG, ' ||
	      'INT_OUTBOUND_FLAG, ' ||
              'OUT_INBOUND_FLAG, ' ||
              'OUT_OUTBOUND_FLAG, '||
              'CREATED_BY, ' ||
              'CREATION_DATE, ' ||
              'LAST_UPDATED_BY, ' ||
              'LAST_UPDATE_DATE, ' ||
              'LAST_UPDATE_LOGIN ) ' ||
          'select  ' ||
 	      ':v_dest_plan_id, ' ||
	      'FACILITY_ID, ' ||
              'INT_INBOUND_FLAG, ' ||
	      'INT_OUTBOUND_FLAG, ' ||
              'OUT_INBOUND_FLAG, ' ||
              'OUT_OUTBOUND_FLAG, ' ||
              ':v_user_id, ' ||
              ':v_sysdate, ' ||
              ':v_user_id, ' ||
              ':v_sysdate, ' ||
              ':v_login_id ' ||
  'from  MST_PLAN_FACILITIES ' ||
  'where plan_id = :p_source_plan_id';

  EXECUTE IMMEDIATE v_statement USING v_dest_plan_id, fnd_global.user_id,
    sysdate, fnd_global.user_id, sysdate, fnd_global.login_id,
    p_source_plan_id;

  v_statement :=
              ' INSERT INTO MST_PLAN_CONSTRAINT_RULES(' ||
 	      'plan_id, '  ||
              'CONSTRAINT_CODE, '  ||
              'TYPE, '  ||
	      'PENALTY_FUNCTION_TYPE, '  ||
              'CREATED_BY, '  ||
              'CREATION_DATE, '  ||
              'LAST_UPDATED_BY, '  ||
              'LAST_UPDATE_DATE, '  ||
              'last_update_login) '  ||
  'select   '  ||
 	      ':v_dest_plan_id, '  ||
              'CONSTRAINT_CODE, '  ||
              'TYPE, '  ||
	      'PENALTY_FUNCTION_TYPE, '  ||
              ':v_user_id, '  ||
              ':v_sysdate, '  ||
              ':v_user_id, '  ||
              ':v_sysdate, '  ||
              ':v_login_id '  ||
  'from mst_plan_constraint_rules '  ||
  'where plan_id = :p_source_plan_id';

  EXECUTE IMMEDIATE v_statement USING v_dest_plan_id, fnd_global.user_id,
    sysdate, fnd_global.user_id, sysdate, fnd_global.login_id,
    p_source_plan_id;


  v_statement :=
              'INSERT INTO MST_PLAN_PENALTY_BREAKS( '  ||
              'plan_id, '  ||
              'CONSTRAINT_CODE, '  ||
              'LOW_RANGE, '  ||
              'HIGH_RANGE, '  ||
              'PENALTY_VALUE, '  ||
              'PENALTY_RATE, '  ||
              'CREATED_BY, '  ||
              'CREATION_DATE, '  ||
              'LAST_UPDATED_BY, '  ||
              'LAST_UPDATE_DATE, '  ||
              'LAST_UPDATE_LOGIN ) '  ||
  'select   '  ||
              ':v_dest_plan_id, '  ||
              'CONSTRAINT_CODE, '   ||
              'LOW_RANGE, '  ||
              'HIGH_RANGE, '  ||
              'PENALTY_VALUE, '  ||
              'PENALTY_RATE, '  ||
              ':v_user_id, '  ||
              ':v_sysdate, '  ||
              ':v_user_id, '  ||
              ':v_sysdate, '  ||
              ':v_login_id '  ||
  'from mst_plan_penalty_breaks ' ||
  'where plan_id = :p_source_plan_id ';

  EXECUTE IMMEDIATE v_statement USING v_dest_plan_id, fnd_global.user_id,
    sysdate, fnd_global.user_id, sysdate, fnd_global.login_id,
    p_source_plan_id;

  commit;

  EXCEPTION
    when no_data_found
      then raise_application_error(-20000,'no data found');
    when others then

  raise_application_error(-20000,sqlerrm||':'||v_statement||
                    'p_source_plan_id' || p_source_plan_id||' ' ||
                     'p_dest_plan_name' ||p_dest_plan_name||' '  ||
                      'p_dest_plan_desc' ||p_dest_plan_desc||' '  ||
                      'p_plan_dates_source' ||p_plan_dates_source||' ' ||
                      'p_dest_start_date' ||p_dest_start_date||' ' ||
                      'p_dest_end_date' ||p_dest_end_date);

END copy_plan_options;


PROCEDURE copy_default_plan_options(p_plan_id NUMBER, p_created_by NUMBER) IS
v_statement          varchar2(20000);
l_return_status      varchar2(10);

BEGIN

  v_statement :=
              'INSERT INTO MST_PLAN_FACILITIES(' ||
 	      'plan_id, ' ||
	      'FACILITY_ID, ' ||
              'INT_INBOUND_FLAG, ' ||
	      'INT_OUTBOUND_FLAG, ' ||
              'OUT_INBOUND_FLAG, ' ||
              'OUT_OUTBOUND_FLAG, '||
              'CREATED_BY, ' ||
              'CREATION_DATE, ' ||
              'LAST_UPDATED_BY, ' ||
              'LAST_UPDATE_DATE, ' ||
              'LAST_UPDATE_LOGIN ) ' ||
          'select  ' ||
 	      ':v_plan_id, ' ||
	      'FACILITY_ID, ' ||
              'INT_INBOUND_FLAG, ' ||
	      'INT_OUTBOUND_FLAG, ' ||
              'OUT_INBOUND_FLAG, ' ||
              'OUT_OUTBOUND_FLAG, ' ||
              ':v_user_id, ' ||
              ':v_sysdate, ' ||
              ':v_user_id, ' ||
              ':v_sysdate, ' ||
              ':v_login_id ' ||
  'from  MST_PLAN_FACILITIES ' ||
  'where plan_id = -1 and created_by = :p_created_by';

  EXECUTE IMMEDIATE v_statement USING p_plan_id, fnd_global.user_id,
    sysdate, fnd_global.user_id, sysdate, fnd_global.login_id,
    p_created_by;

  v_statement :=
              ' INSERT INTO MST_PLAN_CONSTRAINT_RULES(' ||
 	      'plan_id, '  ||
              'CONSTRAINT_CODE, '  ||
              'TYPE, '  ||
	      'PENALTY_FUNCTION_TYPE, '  ||
              'CREATED_BY, '  ||
              'CREATION_DATE, '  ||
              'LAST_UPDATED_BY, '  ||
              'LAST_UPDATE_DATE, '  ||
              'last_update_login) '  ||
  'select   '  ||
 	      ':v_dest_plan_id, '  ||
              'CONSTRAINT_CODE, '  ||
              'TYPE, '  ||
	      'PENALTY_FUNCTION_TYPE, '  ||
              ':v_user_id, '  ||
              ':v_sysdate, '  ||
              ':v_user_id, '  ||
              ':v_sysdate, '  ||
              ':v_login_id '  ||
  'from mst_plan_constraint_rules '  ||
  'where plan_id = -1 and created_by = :p_created_by';

  EXECUTE IMMEDIATE v_statement USING p_plan_id, fnd_global.user_id,
    sysdate, fnd_global.user_id, sysdate, fnd_global.login_id,
    p_created_by;


  v_statement :=
              'INSERT INTO MST_PLAN_PENALTY_BREAKS( '  ||
              'plan_id, '  ||
              'CONSTRAINT_CODE, '  ||
              'LOW_RANGE, '  ||
              'HIGH_RANGE, '  ||
              'PENALTY_VALUE, '  ||
              'PENALTY_RATE, '  ||
              'CREATED_BY, '  ||
              'CREATION_DATE, '  ||
              'LAST_UPDATED_BY, '  ||
              'LAST_UPDATE_DATE, '  ||
              'LAST_UPDATE_LOGIN ) '  ||
  'select   '  ||
              ':v_dest_plan_id, '  ||
              'CONSTRAINT_CODE, '   ||
              'LOW_RANGE, '  ||
              'HIGH_RANGE, '  ||
              'PENALTY_VALUE, '  ||
              'PENALTY_RATE, '  ||
              ':v_user_id, '  ||
              ':v_sysdate, '  ||
              ':v_user_id, '  ||
              ':v_sysdate, '  ||
              ':v_login_id '  ||
  'from mst_plan_penalty_breaks ' ||
  'where plan_id = -1 and created_by = :p_created_by';

  EXECUTE IMMEDIATE v_statement USING p_plan_id, fnd_global.user_id,
    sysdate, fnd_global.user_id, sysdate, fnd_global.login_id,
    p_created_by;

  commit;

  EXCEPTION
    when no_data_found
      then raise_application_error(-20000,'no data found');
    when others then

  raise_application_error(-20000,sqlerrm||':'||v_statement||
                    'p_plan_id ' || p_plan_id||' ' ||
                     'p_created_by ' ||p_created_by);


END copy_default_plan_options;


end mst_copy_plan_options;

/

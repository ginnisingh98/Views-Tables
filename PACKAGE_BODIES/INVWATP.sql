--------------------------------------------------------
--  DDL for Package Body INVWATP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INVWATP" as
/* $Header: INVWATPB.pls 120.1 2005/06/11 07:42:14 appldev  $ */

-- Return values
--   -1   System Error (Oracle Error Message)
--   -2   ATP Group id cannot be null.
--   -3   No ATP Rule specified.
--   -4   Item not found.
--   -5   No UOM Code.
--   -6   No Calendar organization
--   -7   Unable to insert into mtl_group_atps_view
--  For all the above conditions, message ICX_INV_WATP_FAILED is set.
FUNCTION WebAtpInsert
(
  x_organization_id number,
  x_inventory_item_id number,
  x_atp_rule_id number,
  x_request_quantity number,
  x_request_primary_uom_quantity number,
  x_request_date date,
  x_atp_lead_time number,
  x_uom_code varchar2,
  x_demand_class varchar2,
  x_n_column2 number
)
return number
is
  rec_mgav  mtl_group_atps_view%rowtype;
  ret_code  number;
  ret_val   number;
begin
  ret_code := 0;

if ret_code = 0 then
-- atp group id. if n_column2 = 1, get it from sequence,
-- if not use the existing one.
  if x_n_column2 = 1 then
    select
      mtl_demand_interface_s.nextval
    into
      rec_mgav.ATP_GROUP_ID
    from
      dual;
    --INVWATP.WebAtpGroupId := rec_mgav.ATP_GROUP_ID;
    INVWATP.SetAtpGroupId ( rec_mgav.ATP_GROUP_ID );
  else
     rec_mgav.ATP_GROUP_ID := INVWATP.GetAtpGroupId;
     if rec_mgav.ATP_GROUP_ID is null then
       -- cannot proceed with null atp group id
       fnd_message.set_name ( 'EC', 'ICX_INV_WATP_FAILED');
       ret_code := -2;
     end if;
  end if;

--dbms_output.put_line ('Atp group id : '|| to_char (rec_mgav.ATP_GROUP_ID) );
end if; -- ret_code=0

if ret_code = 0 then
-- atp rule id: if passed in, use it. else
-- finds OUT NOCOPY /* file.sql.39 change */ from item if it has atp rule or else
-- takes it from organization default. cannot be null

  if x_atp_rule_id is not null then
    rec_mgav.atp_rule_id := x_atp_rule_id;
  else
    begin
    select atp_rule_id
    into
      rec_mgav.atp_rule_id
    from
       mtl_system_items
    where
       inventory_item_id = x_inventory_item_id and
       organization_id = x_organization_id;

    -- msi table does has null atp rule id, so take it from mtl parameters
    -- from org definition.
    if rec_mgav.atp_rule_id is null then
        begin
          SELECT r.rule_id
          INTO
            rec_mgav.atp_rule_id
          FROM
            mtl_parameters p, mtl_atp_rules r
          WHERE
            p.default_atp_rule_id = r.rule_id
            AND p.organization_id =  x_organization_id;
        exception
         when NO_DATA_FOUND then
           --No Atp Rule specified
           fnd_message.set_name ( 'EC', 'ICX_INV_WATP_FAILED');
           ret_code := -3;
         when OTHERS then
           --System Error
           fnd_message.set_name ( 'EC', 'ICX_INV_WATP_FAILED');
           ret_code := -1;
        end;
    end if;
    exception
    when NO_DATA_FOUND then
       --Item not found
       fnd_message.set_name ( 'EC', 'ICX_INV_WATP_FAILED');
       ret_code := -4;
     when OTHERS then
       --System Error
       fnd_message.set_name ( 'EC', 'ICX_INV_WATP_FAILED');
       ret_code := -1;
    end;
  end if;
--dbms_output.put_line ('Atp Rule id : ' || to_char (rec_mgav.ATP_RULE_ID) );
end if; -- ret_code=0


if ret_code = 0 then
--uom code, takes it from mtl_system_items
  if x_uom_code is not null then
     rec_mgav.uom_code :=  x_uom_code;
  else
       fnd_message.set_name ( 'EC', 'ICX_INV_WATP_FAILED');
       ret_code := -5;
/****
    begin
    select primary_uom_code
    into  rec_mgav.uom_code
    from mtl_system_items
    where
      inventory_item_id = x_inventory_item_id and
      organization_id   = x_organization_id;
    if rec_mgav.uom_code is null then
       fnd_message.set_name ( 'EC', 'ICX_INV_WATP_FAILED');
       ret_code := -5;
    end if;
    exception
     when NO_DATA_FOUND then
       --No UOM code
       fnd_message.set_name ( 'EC', 'ICX_INV_WATP_FAILED');
       ret_code := -5;
     when OTHERS then
       --System Error
       fnd_message.set_name ( 'EC', 'ICX_INV_WATP_FAILED');
       ret_code := -1;
    end;
***/
  end if;
--dbms_output.put_line ('UOM code: ' || rec_mgav.uom_code );
end if; -- ret_code =0



if ret_code = 0 then
  begin
-- calendar organization id
    SELECT MTL.ORGANIZATION_ID
    into rec_mgav.atp_calendar_organization_id
    FROM   HR_ORGANIZATION_UNITS HR, MTL_PARAMETERS MTL
       WHERE  HR.ORGANIZATION_ID = MTL.ORGANIZATION_ID
       AND    MTL.CALENDAR_CODE is not null
       AND    MTL.CALENDAR_EXCEPTION_SET_ID is not null
       AND    MTL.ORGANIZATION_ID = x_organization_id;
    if rec_mgav.atp_calendar_organization_id is null then
      fnd_message.set_name ( 'EC', 'ICX_INV_WATP_FAILED');
      ret_code := -6;
    end if;
  exception
    when NO_DATA_FOUND then
      --No Calendar organization
      fnd_message.set_name ( 'EC', 'ICX_INV_WATP_FAILED');
      ret_code := -6;
    when OTHERS then
      --System Error
      fnd_message.set_name ( 'EC', 'ICX_INV_WATP_FAILED');
      ret_code := -1;
  end;

--dbms_output.put_line ('Calendar org id: ' ||
--       to_char (rec_mgav.atp_calendar_organization_id) );
end if; --ret_code=0

if ret_code = 0 then
begin
INSERT INTO MTL_GROUP_ATPS_VIEW
  (ATP_GROUP_ID,
   ORGANIZATION_ID,
   INVENTORY_ITEM_ID,
   LAST_UPDATE_DATE,
   LAST_UPDATED_BY,
   CREATION_DATE,
   CREATED_BY,
   LAST_UPDATE_LOGIN,
   ATP_RULE_ID,
   REQUEST_QUANTITY,
   REQUEST_PRIMARY_UOM_QUANTITY,
   REQUEST_DATE,
   ATP_LEAD_TIME,
   ATP_CALENDAR_ORGANIZATION_ID,
   AVAILABLE_TO_ATP,
   UOM_CODE,
   DEMAND_CLASS,
   N_COLUMN2
  )
values
  (
   rec_mgav.ATP_GROUP_ID,
   x_ORGANIZATION_ID,
   x_INVENTORY_ITEM_ID,
   sysdate,
   -1,
   sysdate,
   -1,
   -1,
   rec_mgav.ATP_RULE_ID,
   x_REQUEST_QUANTITY,
   x_REQUEST_PRIMARY_UOM_QUANTITY,
   x_REQUEST_DATE,
   x_ATP_LEAD_TIME,
   rec_mgav.ATP_CALENDAR_ORGANIZATION_ID,
   1,
   rec_mgav.UOM_CODE,
   x_DEMAND_CLASS,
   x_N_COLUMN2
  )
;
exception
  when OTHERS then
    -- unable to insert
    fnd_message.set_name ( 'EC', 'ICX_INV_WATP_FAILED');
    ret_code := -7;
end;
end if; -- ret_code=0

ret_val := ret_code;
return (ret_val);

end WebAtpInsert;



PROCEDURE SetAtpGroupId ( x_atp_group_id number ) is
begin
  INVWATP.WebAtpGroupId := x_atp_group_id;
end SetAtpGroupId;

FUNCTION GetAtpGroupId return number is
begin
  return INVWATP.WebAtpGroupId;
end GetAtpGroupId;



-- Return values
--   1   Timed out
--   2   No manager
--   3   Other Error
--  For all the above conditions, message ICX_INV_WATP_FAILED is set.
FUNCTION WebAtpLaunch (
  x_user_id in number,
  x_resp_id in number,
  x_resp_appl_id in number
)
return number
is
  ret_val     number;
  timeout     number;
  mgr_outcome varchar2 (30);
  mgr_message varchar2 (240);
  retval      number;
  retval1     number;
  err_msg     varchar2 (240);
  session_id  number;
  arg_1       varchar2 (80);
  arg_2       varchar2 (80);
  arg_3       varchar2 (80);
  arg_4       varchar2 (80);
  arg_5       varchar2 (80);
  arg_6       varchar2 (80);
  arg_7       varchar2 (80);
  arg_8       varchar2 (80);
  arg_9       varchar2 (80);
  arg_10       varchar2 (80);
  arg_11       varchar2 (80);
  arg_12       varchar2 (80);
  arg_13       varchar2 (80);
  arg_14       varchar2 (80);
  arg_15       varchar2 (80);
  arg_16       varchar2 (80);
  arg_17       varchar2 (80);
  arg_18       varchar2 (80);
  arg_19       varchar2 (80);
  arg_20       varchar2 (80);
begin

timeout  := 240;

fnd_global.apps_initialize (
  x_user_id,
  x_resp_id,
  x_resp_appl_id );


--dbms_output.put_line ( 'Atpgroupid:' || to_char (INVWATP.GetAtpGroupId) );
retval := fnd_transaction.synchronous (
   timeout,
   mgr_outcome,
   mgr_message,
   'INV',
   'INXATP',
--   'INXATP GROUP_ID=343499 DETAIL_FLAG=0 MRP_STATUS=1'
--   'INXATP GROUP_ID=343499 MRP_STATUS=1'
   'INXATP GROUP_ID=' || to_char (INVWATP.GetAtpGroupId) || ' MRP_STATUS=1'
 );


retval1 := fnd_transaction.get_values  (
  arg_1,
  arg_2,
  arg_3,
  arg_4,
  arg_5,
  arg_6,
  arg_7,
  arg_8,
  arg_9,
  arg_10,
  arg_11,
  arg_12,
  arg_13,
  arg_14,
  arg_15,
  arg_16,
  arg_17,
  arg_18,
  arg_19,
  arg_20);



--dbms_output.put_line ('**************************************');
  --dbms_output.put_line ( 'Arg 1:' || arg_1 || ':');
  --dbms_output.put_line ( 'Arg 2:' || arg_2 || ':');
  --dbms_output.put_line ( 'Arg 3:' || arg_3 || ':');
  --dbms_output.put_line ( 'Arg 4:' || arg_4 || ':');
  --dbms_output.put_line ( 'Arg 5:' || arg_5 || ':');
  --dbms_output.put_line ( 'Arg 6:' || arg_6 || ':');
  --dbms_output.put_line ( 'Arg 7:' || arg_7 || ':');
  --dbms_output.put_line ( 'Arg 8:' || arg_8 || ':');
  --dbms_output.put_line ( 'Arg 9:' || arg_9 || ':');

  --dbms_output.put_line ( 'Arg 10:' || arg_10|| ':');
  --dbms_output.put_line ( 'Arg 11:' || arg_11 || ':');
  --dbms_output.put_line ( 'Arg 12:' || arg_12 || ':');
  --dbms_output.put_line ( 'Arg 13:' || arg_13 || ':');
  --dbms_output.put_line ( 'Arg 14:' || arg_14 || ':');
  --dbms_output.put_line ( 'Arg 15:' || arg_15 || ':');
  --dbms_output.put_line ( 'Arg 16:' || arg_16 || ':');
  --dbms_output.put_line ( 'Arg 17:' || arg_17 || ':');
  --dbms_output.put_line ( 'Arg 18:' || arg_18 || ':');
  --dbms_output.put_line ( 'Arg 19:' || arg_19 || ':');
  --dbms_output.put_line ( 'Arg 20:' || arg_20 || ':');
  --dbms_output.put_line ( 'Ret Val1:' || to_char (retval1) || ':');



 if retval = 0 then
 -- success
  --dbms_output.put_line ('Success');
  null;
 elsif retval = 1 then
 -- timeout
  --dbms_output.put_line ('Timed out');
  fnd_message.set_name ( 'EC', 'ICX_INV_WATP_FAILED');
 elsif retval = 2 then
 -- no manager
  --dbms_output.put_line ('No manager');
  fnd_message.set_name ( 'EC', 'ICX_INV_WATP_FAILED');
 elsif retval = 3 then
 -- other
  --dbms_output.put_line ('Other Error');
  fnd_message.set_name ( 'EC', 'ICX_INV_WATP_FAILED');
 end if;

--dbms_output.put_line ('**************************************');
--dbms_output.put_line ('Outcome: ' || mgr_outcome );
--dbms_output.put_line ('Message: ' || mgr_message );
--dbms_output.put_line ('**************************************');

ret_val := retval;
return (ret_val);
end WebAtpLaunch;


-- Return values
--   -1   System Error (Oracle Error Message)
--   -2   ATP Group id cannot be null.
--  For all the above conditions, message ICX_INV_WATP_FAILED is set.
FUNCTION WebAtpFetch (
    x_n_column2 number,
    x_inventory_item_id OUT NOCOPY /* file.sql.39 change */ number,
    x_organization_id OUT NOCOPY /* file.sql.39 change */ number,
    x_request_quantity OUT NOCOPY /* file.sql.39 change */ number,
    x_request_primary_uom_quantity OUT NOCOPY /* file.sql.39 change */ number,
    x_request_date OUT NOCOPY /* file.sql.39 change */ date,
    x_error_code OUT NOCOPY /* file.sql.39 change */ number,
    x_group_available_date OUT NOCOPY /* file.sql.39 change */ date,
    x_request_date_atp_quantity OUT NOCOPY /* file.sql.39 change */ number,
    x_earliest_atp_date OUT NOCOPY /* file.sql.39 change */ date,
    x_earliest_atp_date_quantity OUT NOCOPY /* file.sql.39 change */ number,
    x_request_atp_date OUT NOCOPY /* file.sql.39 change */ date,
    x_request_atp_date_quantity OUT NOCOPY /* file.sql.39 change */ number,
    x_infinite_time_fence_date OUT NOCOPY /* file.sql.39 change */ date
)
return number
is
x_AtpGrpId number;
ret_code   number;
ret_val    number;
begin

  ret_code := 0;

  x_AtpGrpId := INVWATP.GetAtpGroupId;

  if x_AtpGrpId is null then
     --Null Atp Group id
     fnd_message.set_name ( 'EC', 'ICX_INV_WATP_FAILED');
     ret_code := -2;
  else
   begin
    select
      inventory_item_id,
      organization_id,
      request_quantity,
      request_primary_uom_quantity,
      request_date,
      error_code,
      group_available_date,
      request_date_atp_quantity,
      earliest_atp_date,
      earliest_atp_date_quantity,
      request_atp_date,
      request_atp_date_quantity,
      infinite_time_fence_date
    into
      x_inventory_item_id,
      x_organization_id,
      x_request_quantity,
      x_request_primary_uom_quantity,
      x_request_date,
      x_error_code,
      x_group_available_date,
      x_request_date_atp_quantity,
      x_earliest_atp_date,
      x_earliest_atp_date_quantity,
      x_request_atp_date,
      x_request_atp_date_quantity,
      x_infinite_time_fence_date
    from
      MTL_GROUP_ATPS_VIEW
    where
      ATP_GROUP_ID = x_AtpGrpId and
      n_column2    = x_n_column2;
    exception
       when OTHERS then
         --System Error
         fnd_message.set_name ( 'EC', 'ICX_INV_WATP_FAILED');
         ret_code := -1;
    end;
  end if;

ret_val := ret_code;
return (ret_val);
end WebAtpFetch;


-- Return values
--   -1   System Error (Oracle Error Message)
--   -2   ATP Group id cannot be null.
--  For all the above conditions, message ICX_INV_WATP_FAILED is set.
FUNCTION WebAtpClear
return number
 is
  x_AtpGrpId number;
  ret_code   number;
  ret_val    number;
begin

  ret_code := 0;
  x_AtpGrpId := INVWATP.GetAtpGroupId;

  if x_AtpGrpId is null then
     -- null atp group id
     fnd_message.set_name ( 'EC', 'ICX_INV_WATP_FAILED');
     ret_code := -2;
  else
    begin
      delete from mtl_group_atps_view
      where
       atp_group_id = x_AtpGrpId;
    exception
      when OTHERS then
        -- system error
        fnd_message.set_name ( 'EC', 'ICX_INV_WATP_FAILED');
        ret_code := -1;
    end;
  end if;

ret_val := ret_code;
return (ret_val);
end WebAtpClear;

END INVWATP;

/

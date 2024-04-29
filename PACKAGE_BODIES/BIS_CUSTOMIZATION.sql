--------------------------------------------------------
--  DDL for Package Body BIS_CUSTOMIZATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_CUSTOMIZATION" AS
/* $Header: BISVCSTB.pls 120.1 2006/02/03 04:59:56 nbarik noship $ */

procedure insert_custom_registry is

 cursor c_custom_registry is
 select property_name from ak_custom_registry
 where property_name in ('ATTRIBUTE_LABEL_LONG','NODE_DISPLAY_FLAG','DISPLAY_SEQUENCE','ORDER_DIRECTION','INITIAL_SORT_SEQUENCE');
 l_long number    := 0;
 l_display number :=0;
 l_order   number :=0;
 l_sequence number :=0;
 l_sort    number :=0;
begin
  for custom_registry in c_custom_registry loop
     if custom_registry.property_name = 'ATTRIBUTE_LABEL_LONG' then
       l_long := 1;
     elsif custom_registry.property_name = 'NODE_DISPLAY_FLAG' then
       l_display := 1;
     elsif custom_registry.property_name = 'ORDER_DIRECTION' then
       l_order := 1;
     elsif custom_registry.property_name = 'INITIAL_SORT_SEQUENCE' then
       l_sort := 1;
     elsif custom_registry.property_name = 'DISPLAY_SEQUENCE' then
       l_sequence := 1;
     end if;
  end loop;
  if l_long = 0 then
     insert into ak_custom_registry(customization_level_id,custom_level,property_name
           ,translatable,created_by,creation_date,last_updated_by ,last_update_date
           ,last_update_login)
     values(60,'REGION_ITEM', 'ATTRIBUTE_LABEL_LONG','Y',1,SYSDATE,1,SYSDATE,1);
  end if;
  if l_display = 0 then
     insert into ak_custom_registry(customization_level_id,custom_level,property_name
           ,translatable,created_by,creation_date,last_updated_by ,last_update_date
           ,last_update_login)
     values(60,'REGION_ITEM','NODE_DISPLAY_FLAG','N',1,SYSDATE,1,SYSDATE,1);
  end if;
  if l_sequence = 0 then
     insert into ak_custom_registry(customization_level_id,custom_level,property_name
           ,translatable,created_by,creation_date,last_updated_by ,last_update_date
           ,last_update_login)
     values(60,'REGION_ITEM','DISPLAY_SEQUENCE','N',1,SYSDATE,1,SYSDATE,1);
  end if;
  if l_order = 0 then
     insert into ak_custom_registry(customization_level_id,custom_level,property_name
           ,translatable,created_by,creation_date,last_updated_by ,last_update_date
           ,last_update_login)
     values(60,'REGION_ITEM','ORDER_DIRECTION','N',1,SYSDATE,1,SYSDATE,1);
  end if;
  if l_sort = 0 then
     insert into ak_custom_registry(customization_level_id,custom_level,property_name
           ,translatable,created_by,creation_date,last_updated_by ,last_update_date
           ,last_update_login)
     values(60,'REGION_ITEM','INITIAL_SORT_SEQUENCE','N',1,SYSDATE,1,SYSDATE,1);
  end if;
end insert_custom_registry;

procedure delete_region_item is
begin

  delete from ak_region_items
  where attribute_code='ICX_STANDARD_FOOTER'
  and region_code='BISPRINTPAGE';

  delete from ak_region_items_tl
  where attribute_code='ICX_STANDARD_FOOTER'
  and region_code='BISPRINTPAGE';

end delete_region_item;

END BIS_CUSTOMIZATION;

/

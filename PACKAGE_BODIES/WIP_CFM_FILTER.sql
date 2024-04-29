--------------------------------------------------------
--  DDL for Package Body WIP_CFM_FILTER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_CFM_FILTER" as
 /* $Header: wipnocfb.pls 115.8 2002/12/12 15:12:53 rmahidha ship $ */


function org_item_only_rtg_is_cfm
  (
    p_organization_id in number,
    p_item_id in number
  )
  return number
is
  any_cfm_routings number := 2 ;

  /* This cursor finds the cfm_routing_flag value (default SYS_NO) for every
   * match to the item and organization.
   */
  cursor routing_flags is
    select nvl(cfm_routing_flag,2) as value
      from bom_operational_routings
      where assembly_item_id = p_item_id
      and organization_id = p_organization_id
      and alternate_routing_designator is null;

  cursor routing_flags1 is
  select nvl(cfm_routing_flag,2) as value
  from bom_operational_routings
  where assembly_item_id = p_item_id
  and organization_id = p_organization_id
  and alternate_routing_designator is not null;

begin

  for routing_flag in routing_flags loop
  if (routing_flag.value = 3) then --N/w routing exists
      for routing_flag1 in routing_flags1 loop
          if (routing_flag1.value = 2) then -- check if a std routing exists for the routing with N/w
               return 3;
          end if;
      end loop;
      any_cfm_routings := 1;
  elsif (routing_flag.value = 2) then
       any_cfm_routings := 2;
  elsif (routing_flag.value = 1) then
	any_cfm_routings := 1 ; /* Fixed Bug#2183541 */
  end if;
  end loop;

  return any_cfm_routings;

end org_item_only_rtg_is_cfm ;


function org_item_alt_is_cfm
  (
    p_organization_id in number,
    p_item_id in number,
    p_alternate_routing_designator in varchar2
  )
  return number
is
  is_cfm number ;

  /* Find the routing flags for all matches to the parameters.
   * There should be at most one match.
   */
  cursor routing_flags is
    select nvl(cfm_routing_flag,2)
      from bom_operational_routings
      where assembly_item_id = p_item_id
      and organization_id = p_organization_id
      and ((p_alternate_routing_designator is null
            and alternate_routing_designator is null)
           or
           (p_alternate_routing_designator = alternate_routing_designator)) ;

begin

  open routing_flags ;
  fetch routing_flags into is_cfm ;
  if (routing_flags%notfound) then
    is_cfm := 2 ;
  end if ;
  close routing_flags ;

  return is_cfm ;

end org_item_alt_is_cfm ;


end wip_cfm_filter ;

/

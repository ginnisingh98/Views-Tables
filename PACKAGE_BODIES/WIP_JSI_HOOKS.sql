--------------------------------------------------------
--  DDL for Package Body WIP_JSI_HOOKS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_JSI_HOOKS" as
/* $Header: wipjsihb.pls 120.0.12010000.2 2009/06/12 16:03:01 shjindal ship $ */


function
get_default_build_sequence (
  p_interface_id in number,
  p_current_build_sequence in number
  )
return number is
  x_build_sequence number ;
begin

  x_build_sequence := p_current_build_sequence ;

 /*
  begin

  select	WDD.load_seq_number
    into	x_build_sequence
    from	wip_job_schedule_interface WJSI,
		wsh_delivery_details WDD
    where	WJSI.interface_id = p_interface_id
		and WJSI.source_code = 'WICDOL'
		and WDD.source_line_id = WJSI.source_line_id;
   */

  return x_build_sequence ;

end get_default_build_sequence ;

-- Fixed bug 7638816
function
get_default_schedule_group_id (
  p_interface_id in number,
  p_current_schedule_group_id in number
  )
return number is
  x_schedule_group_id number ;
begin
  -- Customer can replace the value below with custom logic
  x_schedule_group_id := p_current_schedule_group_id ;

  return x_schedule_group_id ;

end get_default_schedule_group_id ;


end WIP_JSI_Hooks ;

/

--------------------------------------------------------
--  DDL for Package Body POS_OSP_JOB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POS_OSP_JOB" as
/* $Header: POSASNWB.pls 115.1 99/09/01 10:57:34 porting sh $ */

function r_count(po_line_location_id in number) return number is
x_count number;
begin

  select count(*)
  into x_count
  from po_distributions_all
  where line_location_id = po_line_location_id and
        wip_entity_id is not null;

  return x_count;

end r_count;

function get_osp_info(po_line_location_id in number) return varchar2 is
x_count number;
job_info varchar2(2000);
begin

  x_count := r_count(po_line_location_id);

  if x_count = 1 then

    select ltrim(wipe.wip_entity_name || '-' || wipl.line_code || '-' || pod.wip_operation_seq_num)
    into job_info
    from po_distributions_all pod,
         wip_entities wipe,
         wip_lines wipl
    where pod.line_location_id = po_line_location_id and
          pod.wip_entity_id is not null and
          pod.wip_entity_id = wipe.wip_entity_id and
          pod.wip_line_id = wipl.line_id(+);

    return job_info;

  elsif x_count > 1 then

   return ' ';

  else

    return '&nbsp';

  end if;

end get_osp_info;

function get_wip_info(po_distributions_id in number) return varchar2 is
job_info varchar2(2000);
begin

    select ltrim(wipe.wip_entity_name || '-' || wipl.line_code || '-' || pod.wip_operation_seq_num)
    into job_info
    from po_distributions_all pod,
         wip_entities wipe,
         wip_lines wipl
    where pod.po_distribution_id = po_distributions_id and
          pod.wip_entity_id is not null and
          pod.wip_entity_id = wipe.wip_entity_id and
          pod.wip_line_id = wipl.line_id(+);

   return job_info;

end get_wip_info;

function get_po_distribution_id(po_line_location_id in number) return number is
x_id number;
begin

  if r_count(po_line_location_id) = 1 then

    select po_distribution_id
    into x_id
    from po_distributions_all
    where line_location_id = po_line_location_id and
         wip_entity_id is not null;

    return x_id;
  else
    return null;
  end if;

end get_po_distribution_id;

function get_wip_entity_id(po_line_location_id in number) return number is
x_id number;
begin

  if r_count(po_line_location_id) = 1 then

    select wip_entity_id
    into x_id
    from po_distributions_all
    where line_location_id = po_line_location_id and
         wip_entity_id is not null;

    return x_id;
  else
    return null;
  end if;

end get_wip_entity_id;

function get_wip_seq_num(po_line_location_id in number) return number is
x_id number;
begin

  if r_count(po_line_location_id) = 1 then

    select wip_operation_seq_num
    into x_id
    from po_distributions_all
    where line_location_id = po_line_location_id and
         wip_entity_id is not null;

    return x_id;
  else
    return null;
  end if;

end get_wip_seq_num;

function get_wip_line_id(po_line_location_id in number) return number is
x_id number;
begin

  if r_count(po_line_location_id) = 1 then

    select wip_line_id
    into x_id
    from po_distributions_all
    where line_location_id = po_line_location_id and
         wip_entity_id is not null;

    return x_id;
  else
    return null;
  end if;

end get_wip_line_id;

end pos_osp_job;

/

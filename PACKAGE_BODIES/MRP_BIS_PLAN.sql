--------------------------------------------------------
--  DDL for Package Body MRP_BIS_PLAN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MRP_BIS_PLAN" AS
/* $Header: MRPPRODB.pls 115.0 99/07/16 12:34:11 porting ship $  */
   FUNCTION sched_quant(
                        item_id in number,
                        org_id in number,
                        sched_desig in varchar2,
                        sched_date in date) return number is
  quantity     number;

  begin
   select nvl(sum(nvl(schedule_quantity, 0)),0)
   into quantity
   from mrp_schedule_dates
   where inventory_item_id = item_id
   and   organization_id = org_id
   and   schedule_designator = sched_desig
   and   schedule_date = sched_date;

  return quantity;
  end;

end;

/

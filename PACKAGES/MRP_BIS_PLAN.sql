--------------------------------------------------------
--  DDL for Package MRP_BIS_PLAN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MRP_BIS_PLAN" AUTHID CURRENT_USER AS
/* $Header: MRPPRODS.pls 115.0 99/07/16 12:34:18 porting ship $  */
   FUNCTION sched_quant(
                        item_id in number,
                        org_id in number,
                        sched_desig  in varchar2,
                        sched_date in date)
   return number;

   PRAGMA RESTRICT_REFERENCES (sched_quant, WNDS, WNPS);
end;

 

/

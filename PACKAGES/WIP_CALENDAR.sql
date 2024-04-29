--------------------------------------------------------
--  DDL for Package WIP_CALENDAR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_CALENDAR" AUTHID CURRENT_USER AS
/* $Header: wipltess.pls 120.0 2005/05/25 08:44:12 appldev noship $ */

  PROCEDURE ESTIMATE_LEADTIME
	   (x_org_id      in number,
            x_fixed_lead  in number DEFAULT 0,
            x_var_lead    in number DEFAULT 0,
            x_quantity    in number,
            x_proc_days   in number,
            x_entity_type in number,
            x_fusd        in date,
            x_fucd        in date,
            x_lusd        in date,
            x_lucd        in date,
            x_sched_dir   in number,
            x_est_date    out nocopy date);

END WIP_CALENDAR;

 

/

--------------------------------------------------------
--  DDL for Package MSD_STRIPE_DEMAND_PLAN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSD_STRIPE_DEMAND_PLAN" AUTHID CURRENT_USER as
/* $Header: msdstrps.pls 120.1 2005/10/02 23:56:55 anwroy noship $ */

    --
    -- Public procedure
    --
    Procedure stripe_demand_plan(
        errbuf          out NOCOPY varchar2,
        retcode         out NOCOPY varchar2,
        p_demand_plan_id in number);

    Procedure set_demand_plan(
        p_demand_plan_id in number);


End;

 

/

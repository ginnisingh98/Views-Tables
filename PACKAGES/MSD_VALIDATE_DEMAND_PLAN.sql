--------------------------------------------------------
--  DDL for Package MSD_VALIDATE_DEMAND_PLAN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSD_VALIDATE_DEMAND_PLAN" AUTHID CURRENT_USER as
/* $Header: msddpvls.pls 120.2 2006/03/31 06:33:58 brampall noship $ */

    --
    -- Public procedure
    --
    Procedure validate_demand_plan(
        errbuf          out NOCOPY varchar2,
        retcode         out NOCOPY varchar2,
        p_demand_plan_id in number);

End;

 

/

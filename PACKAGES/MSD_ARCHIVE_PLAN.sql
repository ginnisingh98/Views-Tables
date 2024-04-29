--------------------------------------------------------
--  DDL for Package MSD_ARCHIVE_PLAN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSD_ARCHIVE_PLAN" AUTHID CURRENT_USER AS
/* $Header: msdarchs.pls 120.1 2005/11/01 11:42:46 ziahmed noship $ */

PROCEDURE archive_plan(errbuf out NOCOPY varchar2,retcode out NOCOPY varchar2,
                       p_demand_plan_id in number);

PROCEDURE restore_plan(errbuf out NOCOPY varchar2,retcode out NOCOPY varchar2,
                       p_demand_plan_id in number);
end MSD_ARCHIVE_PLAN;

 

/

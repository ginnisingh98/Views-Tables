--------------------------------------------------------
--  DDL for Package MSD_EOL_PLAN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSD_EOL_PLAN" AUTHID CURRENT_USER AS
/* $Header: msdeolps.pls 120.1 2006/04/06 04:24:59 brampall noship $ */
procedure msd_eol_pre_download_hook(p_demand_plan_id number);

procedure eol_post_archive(p_demand_plan_id number);
END MSD_EOL_PLAN;


 

/

--------------------------------------------------------
--  DDL for Package MSD_COPY_DEMAND_PLAN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSD_COPY_DEMAND_PLAN" AUTHID CURRENT_USER AS
/* $Header: msdcpdps.pls 120.1 2006/03/31 06:24:12 brampall noship $ */

/* Public Procedures */

function copy_demand_plan (
p_new_dp_id in out nocopy number,
p_target_demand_plan_name in VARCHAR2,
p_target_demand_plan_descr in VARCHAR2,
p_shared_db_location in VARCHAR2,
p_source_demand_plan_id in NUMBER,
p_organization_id in number,
p_instance_id  in number,
p_errcode in out nocopy varchar2
) return NUMBER;


END MSD_COPY_DEMAND_PLAN ;

 

/

--------------------------------------------------------
--  DDL for Package MRP_RHX_RESOURCE_AVAILABILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MRP_RHX_RESOURCE_AVAILABILITY" AUTHID CURRENT_USER AS
/* $Header: MRPXNRAS.pls 120.1 2005/08/31 13:24:21 ichoudhu noship $*/
    PROCEDURE calc_res_avail(   arg_organization_id IN  number,
                                arg_department_id   IN  number,
                                arg_resource_id     IN  number,
                                arg_simulation_set  IN  varchar2,
                                arg_24hr_flag       IN  number,
								arg_start_date		IN  date default SYSDATE,
                                arg_cutoff_date     IN  date);
    PROCEDURE populate_avail_resources(
                                arg_simulation_set  IN  varchar2,
                                arg_organization_id IN  number,
								arg_start_date		IN  date default SYSDATE,
                                arg_cutoff_date     IN  date default NULL);
end mrp_rhx_resource_availability;
 

/

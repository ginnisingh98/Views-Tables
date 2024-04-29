--------------------------------------------------------
--  DDL for Package MSC_NET_RES_INST_AVAILABILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_NET_RES_INST_AVAILABILITY" AUTHID CURRENT_USER AS
/* $Header: MSCNRIAS.pls 120.0 2005/05/25 17:46:41 appldev noship $*/



DELETE_WORKDAY  CONSTANT number := 1;
CHANGE_WORKDAY  CONSTANT number := 2;
ADD_WORKDAY     CONSTANT number := 3;
HOLD_TIME       CONSTANT number := 9999999;

PROCEDURE calc_res_ins_avail(   arg_organization_id IN  number,
				arg_sr_instance_id  IN  number,
                                arg_department_id   IN  number,
                                arg_resource_id     IN  number,
                                arg_simulation_set  IN  varchar2,
				arg_instance_id     in  number,
				arg_serial_num      in varchar2,
				arg_equipment_item_id IN number,
                                arg_24hr_flag       IN  number,
				arg_start_date	    IN  date,
                                arg_cutoff_date     IN  date,
                                arg_refresh_number  IN Number);

PROCEDURE populate_avail_res_instances(
                                   arg_refresh_number  IN number,
                                   arg_refresh_flag    IN number,
                                   arg_simulation_set  IN varchar2,
                                   arg_organization_id IN number,
				   arg_sr_instance_id  IN number,
				   arg_start_date      IN date,
                                   arg_cutoff_date     IN date);

PROCEDURE populate_org_res_instances( RETCODE             OUT NOCOPY number,
                                  arg_refresh_flag    IN  number,
                                  arg_refresh_number  IN  number,
				  arg_organization_id IN  number,
				  arg_sr_instance_id  IN  number,
				  arg_start_date      IN  date,
                                  arg_cutoff_date     IN  date );

PROCEDURE LOG_MESSAGE( pBUFF  IN  VARCHAR2);

END MSC_NET_RES_INST_AVAILABILITY;

 

/

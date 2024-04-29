--------------------------------------------------------
--  DDL for Package WIP_WPS_RES_INSTANCE_AVAIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_WPS_RES_INSTANCE_AVAIL" AUTHID CURRENT_USER AS
/* $Header: wipzinss.pls 115.0 2003/09/03 23:03:02 jaliu noship $*/

DELETE_WORKDAY  CONSTANT number := 1;
CHANGE_WORKDAY  CONSTANT number := 2;
ADD_WORKDAY     CONSTANT number := 3;
HOLD_TIME       CONSTANT number := 9999999;

    PROCEDURE calc_ins_avail(   arg_organization_id IN  number,
                                arg_department_id   IN  number,
                                arg_resource_id     IN  number,
                                arg_simulation_set  IN  varchar2,
				arg_instance_id     in  number,
				arg_serial_num      in varchar2,
                                arg_24hr_flag       IN  number,
				arg_start_date	    IN  date default SYSDATE,
                                arg_cutoff_date     IN  date);


end WIP_WPS_RES_INSTANCE_AVAIL;

 

/

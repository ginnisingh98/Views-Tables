--------------------------------------------------------
--  DDL for Package WPS_RES_INSTANCE_AVAILABILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WPS_RES_INSTANCE_AVAILABILITY" AUTHID CURRENT_USER AS
/* $Header: wpsinsas.pls 115.5 2002/03/06 13:18:08 pkm ship       $*/

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


end WPS_RES_INSTANCE_AVAILABILITY;

 

/

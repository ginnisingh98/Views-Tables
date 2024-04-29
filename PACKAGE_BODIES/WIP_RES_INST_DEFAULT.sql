--------------------------------------------------------
--  DDL for Package Body WIP_RES_INST_DEFAULT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_RES_INST_DEFAULT" AS
/* $Header: wipridfb.pls 120.0 2005/05/25 08:42:53 appldev noship $ */

Procedure Default_Res_Instance(
		p_group_id		number,
                p_wip_entity_id         number,
                p_organization_id       number,
                p_substitution_type     number,
		p_operation_seq_num	number,
		p_resource_seq_num	in out nocopy number,
		p_resource_id           number,
		p_instance_id   	number,
                p_parent_seq_num        number,
                p_rowid                 ROWID,
	        p_err_code              out nocopy varchar2,
                p_err_msg               out nocopy varchar2) IS

                x_start_date           date;
                x_completion_date      date;

		x_state_num     number := 0;
		x_resource_seq  number;

begin
     begin

        if (p_resource_seq_num is null) then

            /* If resource_seq_num for the setup instance is null, we need to update
	       with the resource_seq_num of parent setup resource */

	    SELECT resource_seq_num into x_resource_seq
	      FROM wip_operation_resources
	     WHERE organization_id = p_organization_id
	       and wip_entity_id = p_wip_entity_id
	       and operation_seq_num = p_operation_seq_num
	       and resource_id = p_resource_id
	       and parent_resource_seq = p_parent_seq_num;

	  p_resource_seq_num := x_resource_seq;

        end if;

	x_state_num := x_state_num + 1;

        /* Derive date_info */
       if (p_substitution_type = WIP_JOB_DETAILS.wip_add) then
             SELECT start_date, completion_date
               INTO x_start_date, x_completion_date
               FROM WIP_OPERATION_RESOURCES
              WHERE wip_entity_id = p_wip_entity_id
                AND organization_id = p_organization_id
                AND operation_seq_num = p_operation_seq_num
                AND resource_seq_num = p_resource_seq_num;
        end if;

	x_state_num := x_state_num + 1;



	UPDATE WIP_JOB_DTLS_INTERFACE
	SET  	start_date = nvl(start_date,x_start_date),
 		completion_date = nvl(completion_date,x_completion_date),
                resource_seq_num = nvl(resource_seq_num, x_resource_seq)
	WHERE   rowid = p_rowid;

	x_state_num := x_state_num + 1;

	exception
           when others then
              p_err_msg := 'WIPRIDFB(' || x_state_num || '): ' || SQLERRM;
              p_err_code := SQLCODE;
        end;

END Default_Res_Instance;

END WIP_RES_INST_DEFAULT;

/

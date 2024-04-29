--------------------------------------------------------
--  DDL for Package Body WIP_RESOURCE_DEFAULT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_RESOURCE_DEFAULT" AS
/* $Header: wiprsdfb.pls 120.1.12010000.2 2008/09/19 00:28:11 ankohli ship $ */

Procedure DEFAULT_RESOURCE(
		p_group_id		number,
                p_wip_entity_id         number,
                p_organization_id       number,
                p_substitution_type     number,
		p_operation_seq_num	number,
		p_resource_seq_num	number,
		p_resource_id_new	number,
	        p_err_code              out nocopy varchar2,
                p_err_msg               out nocopy varchar2) IS

                x_uom_code             varchar2(3);
                x_basis_type           number;
                x_activity_id          number;
                x_autocharge_type      number;
                x_standard_rate_flag   number;
                x_start_date           date;
                x_completion_date      date;

		x_state_num     number := 0;

BEGIN

	begin
        /* Derive resource information */
         SELECT unit_of_measure, default_basis_type, default_activity_id,
		autocharge_type, standard_rate_flag
	   INTO x_uom_code, x_basis_type, x_activity_id,
		x_autocharge_type, x_standard_rate_flag
           FROM BOM_RESOURCES
          WHERE resource_id = p_resource_id_new;

	x_state_num := x_state_num + 1;

        /* Derive date_info */
         SELECT first_unit_start_date, last_unit_completion_date
	   INTO x_start_date, x_completion_date
           FROM WIP_OPERATIONS
          WHERE wip_entity_id = p_wip_entity_id
	    AND organization_id = p_organization_id
	    AND operation_seq_num = p_operation_seq_num;

	x_state_num := x_state_num + 1;

	if (x_basis_type IS NULL) then
	      x_basis_type := 1; 	/* item, from form */
	End if;

	if (x_standard_rate_flag IS NULL) then
	      x_standard_rate_flag := 1;  /* yes */
	End If;


	UPDATE WIP_JOB_DTLS_INTERFACE
	SET  	scheduled_flag = nvl(scheduled_flag,2),
		assigned_units = nvl(assigned_units,1),
                applied_resource_units = decode(p_substitution_type,WIP_JOB_DETAILS.WIP_ADD,0,applied_resource_units), /*Bug 3499921*/
                applied_resource_value = decode(p_substitution_type,WIP_JOB_DETAILS.WIP_ADD,0,applied_resource_value), /*Bug 3499921*/
		usage_rate_or_amount = decode(usage_rate_or_amount,NULL,NULL,
                                              inv_convert.inv_um_convert(0,WIP_CONSTANTS.MAX_DISPLAYED_PRECISION,usage_rate_or_amount,
		                               			        nvl(uom_code,x_uom_code), x_uom_code,
                                                                        null,null)), /* fix for bug#2367650 +APS*/
		uom_code = x_uom_code,
	 	basis_type = nvl(basis_type,x_basis_type),/*Fix for bug 2119945*/
 		activity_id = decode(p_substitution_type,
                                     WIP_JOB_DETAILS.WIP_ADD,
                                     nvl(activity_id,x_activity_id),
                                     activity_id),  /*Bug 2683271*/
		autocharge_type = nvl(autocharge_type,x_autocharge_type), /*Fix for bug 6767640*/
		standard_rate_flag = nvl(standard_rate_flag,x_standard_rate_flag), /*Fix for bug 6767640*/
 		start_date = nvl(start_date,x_start_date),
 		completion_date = nvl(completion_date,x_completion_date)
	WHERE   group_id = p_group_id
	AND	wip_entity_id = p_wip_entity_id
	AND	organization_id = p_organization_id
	AND	load_type in (WIP_JOB_DETAILS.WIP_RESOURCE,
                              WIP_JOB_DETAILS.WIP_SUB_RES)
	AND	substitution_type = p_substitution_type
	AND     operation_seq_num = p_operation_seq_num
	AND	resource_seq_num =  p_resource_seq_num
	AND	resource_id_new =   p_resource_id_new
        -- jy: no need to default if doing res substitution
        AND not (   load_type = wip_job_details.wip_resource
                and substitution_type = wip_job_details.wip_change
                and substitute_group_num is not null
                and substitute_group_num is not null
               );

	x_state_num := x_state_num + 1;

	exception
           when others then
              p_err_msg := 'WIPRSDFB(' || x_state_num || '): ' || SQLERRM;
              p_err_code := SQLCODE;
        end;

END DEFAULT_RESOURCE;

END WIP_RESOURCE_DEFAULT;

/

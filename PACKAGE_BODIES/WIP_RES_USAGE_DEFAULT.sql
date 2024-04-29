--------------------------------------------------------
--  DDL for Package Body WIP_RES_USAGE_DEFAULT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_RES_USAGE_DEFAULT" as
/* $Header: wiprudfb.pls 120.0 2005/05/25 08:09:23 appldev noship $ */

Procedure Default_Resource_Usages(p_group_id 		in number,
                                   p_parent_header_id   in number := null,
                                   p_wip_entity_id 	in number,
                                   p_organization_id 	in number,
                                   x_err_code 	 out nocopy varchar2,
                                   x_err_msg 	 out nocopy varchar2,
                                   x_return_status  out nocopy varchar2) IS

   Cursor Usage_info (p_group_id number,
                      p_wip_entity_id number,
                      p_organization_id  number) IS
    SELECT operation_seq_num, resource_seq_num
    FROM WIP_JOB_DTLS_INTERFACE
    WHERE group_id = p_group_id
      AND process_phase = WIP_CONSTANTS.ML_VALIDATION
      AND process_status = WIP_CONSTANTS.RUNNING
      AND wip_entity_id = p_wip_entity_id
      AND organization_id = p_organization_id
      AND load_type in
           (WIP_JOB_DETAILS.WIP_RES_USAGE, WIP_JOB_DETAILS.WIP_RES_INSTANCE_USAGE)
      AND substitution_type = WIP_JOB_DETAILS.WIP_ADD
      ORDER BY operation_seq_num, resource_seq_num;

Begin

    FOR cur_row in Usage_info(p_group_id,
                              p_wip_entity_id, p_organization_id) LOOP

      Default_Res_Usage (p_group_id,
                         p_parent_header_id,p_wip_entity_id,
                         p_organization_id,
                         cur_row.operation_seq_num,
                         cur_row.resource_seq_num,
                         WIP_JOB_DETAILS.WIP_ADD,
                         x_err_code,
                         x_err_msg,
                         x_return_status);

    END LOOP;

END DEFAULT_RESOURCE_USAGES;

Procedure Default_Res_Usage ( p_group_id 		in number,
                              p_parent_header_id   in number := null,
                              p_wip_entity_id 	in number,
                              p_organization_id 	in number,
                              p_operation_seq_num 	in number,
                              p_resource_seq_num 	in number,
                              p_substitution_type 	in number,
                              x_err_code 	 out nocopy varchar2,
                              x_err_msg 	 out nocopy varchar2,
                              x_return_status  out nocopy varchar2) IS

    l_last_update_login number;
    l_request_id  number;
    l_program_application_id number;
    l_program_id number;
    l_program_update_date date;
    l_end_date date;
    l_assigned_units number;

    l_parent_header number;
    l_oper_resource number;
BEGIN

    l_last_update_login := 0;
    l_request_id := 0;
    l_program_application_id := 0;
    l_program_id := 0;
    l_program_update_date := sysdate;
    l_end_date := sysdate;
    l_assigned_units := 0;

  begin

    IF p_group_id IS NULL OR p_wip_entity_id IS NULL OR
       p_organization_id IS NULL OR p_operation_seq_num IS NULL OR
       p_resource_seq_num IS NULL OR p_substitution_type IS NULL THEN
       x_err_code := SQLCODE;
       x_err_msg := 'Error in wiprudfb.pls: Primary key cannot be NULL!';
       x_return_status := FND_API.G_RET_STS_ERROR;
       return;
    END IF;

   IF p_substitution_type = WIP_JOB_DETAILS.WIP_ADD THEN

     IF WIP_JOB_DETAILS.std_alone = 0  THEN

        SELECT COUNT(*) INTO l_parent_header
        FROM WIP_JOB_SCHEDULE_INTERFACE
        WHERE header_id = p_parent_header_id
        AND   group_id = p_group_id;

       IF l_parent_header =1 THEN
         SELECT last_update_login,
                request_id,
                program_application_id,
                program_id,
                program_update_date
         INTO   l_last_update_login,
                l_request_id,
                l_program_application_id,
                l_program_id,
                l_program_update_date
         FROM WIP_JOB_SCHEDULE_INTERFACE
         WHERE wip_entity_id = p_wip_entity_id
         AND   organization_id = p_organization_id
         AND   header_id = p_parent_header_id
         AND   group_id = p_group_id;
       END IF;

     ELSE

       select count(*) into l_oper_resource
        from wip_operation_resources
        where wip_entity_id = p_wip_entity_id
        and organization_id = p_organization_id
        and operation_seq_num = p_operation_seq_num
        and resource_seq_num = p_resource_seq_num;

       IF l_oper_resource = 1 THEN
         SELECT last_update_login,
                request_id,
                program_application_id,
                program_id,
                program_update_date
         INTO   l_last_update_login,
                l_request_id,
                l_program_application_id,
                l_program_id,
                l_program_update_date
         FROM WIP_OPERATION_RESOURCES
         WHERE wip_entity_id = p_wip_entity_id
         AND   organization_id = p_organization_id
         AND   operation_seq_num = p_operation_seq_num
         AND   resource_seq_num = p_resource_seq_num;
       END IF;

     END IF;

    UPDATE WIP_JOB_DTLS_INTERFACE
    SET last_update_login = NVL(last_update_login, l_last_update_login),
        request_id = NVL(request_id, l_request_id),
        program_application_id = NVL(program_application_id,
                                     l_program_application_id ),
        program_id = NVL(program_id, l_program_id),
        program_update_date = NVL(program_update_date,l_program_update_date)
    WHERE group_id = p_group_id
    AND   wip_entity_id = p_wip_entity_id
    AND   organization_id = p_organization_id
    AND   operation_seq_num = p_operation_seq_num
    AND   resource_seq_num = p_resource_seq_num
    AND   load_type in (WIP_JOB_DETAILS.WIP_RES_USAGE,
                        WIP_JOB_DETAILS.WIP_RES_INSTANCE_USAGE)
    AND   substitution_type = WIP_JOB_DETAILS.WIP_ADD;

  END IF;

    exception
      When others then
       x_err_code := SQLCODE;
       x_err_msg := 'Error in wiprudfb: '|| SQLERRM;
       x_return_status := FND_API.G_RET_STS_ERROR;
       return;

   end;

  END DEFAULT_RES_USAGE;

END WIP_RES_USAGE_DEFAULT;

/

--------------------------------------------------------
--  DDL for Package Body WIP_RES_USAGE_SUBSTITUTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_RES_USAGE_SUBSTITUTIONS" as
/* $Header: wiprustb.pls 115.6 2002/11/29 17:43:06 simishra ship $ */

Procedure Substitution_Res_Usages( p_group_id   	in number,
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
      AND load_type = WIP_JOB_DETAILS.WIP_RES_USAGE
      AND substitution_type = WIP_JOB_DETAILS.WIP_ADD
      ORDER BY operation_seq_num, resource_seq_num;


Begin

    FOR cur_row in Usage_info(p_group_id, p_wip_entity_id,p_organization_id)Loop

         Sub_Usage(p_group_id, p_wip_entity_id, p_organization_id,
                 cur_row.operation_seq_num, cur_row.resource_seq_num,
                 x_err_code, x_err_msg, x_return_status);

    END LOOP;

END SUBSTITUTION_RES_USAGES;

Procedure Sub_Usage (p_group_id 		in number,
                              p_wip_entity_id 		in number,
                              p_organization_id 	in number,
                              p_operation_seq_num 	in number,
                              p_resource_seq_num 	in number,
                              x_err_code 	 out nocopy varchar2,
                              x_err_msg 	 out nocopy varchar2,
                              x_return_status 	 out nocopy varchar2) IS

  Cursor Usage_Update (p_group_id number, p_wip_entity_id number,
                       p_organization_id number, p_operation_seq_num number,
                       p_resource_seq_num number) IS

   SELECT distinct wip_entity_id , organization_id, operation_seq_num,
          resource_seq_num, start_date, completion_date, assigned_units,
          last_update_date, last_updated_by, creation_date, created_by,
         last_update_login, program_application_id, request_id, program_id,
          program_update_date, substitution_type
   FROM WIP_JOB_DTLS_INTERFACE
   WHERE group_id = p_group_id
   AND   wip_entity_id = p_wip_entity_id
   AND  organization_id = p_organization_id
   AND  operation_seq_num = p_operation_seq_num
   AND  resource_seq_num = p_resource_seq_num
   AND  load_type = WIP_JOB_DETAILS.WIP_RES_USAGE
   ORDER BY start_date;

   l_start_date date;
   l_end_date date;
   tmp1 number;
   x_statement varchar2(2000);

BEGIN

    l_start_date := sysdate;
    l_end_date := sysdate;
    tmp1 := 0;
    x_statement := NULL;

  begin

    IF p_group_id IS NULL OR p_organization_id IS NULL OR p_wip_entity_id IS NULL
       OR p_operation_seq_num IS NULL OR p_resource_seq_num IS NULL THEN
       x_err_code := SQLCODE;
       x_err_msg := 'Error in wiprustb.pls: Primary key cannot be null!';
       x_return_status := FND_API.G_RET_STS_ERROR;
       return;
    END IF;

/************************************************************************
   CHECK THAT IF GROUP_ID, ORGANIZATION_ID, WIP_ENTITY_ID,
   OPERATION_SEQ_NUM AND RESOURCE_SEQ_NUM IS NULL
  **********************************************************************/

       DELETE FROM WIP_OPERATION_RESOURCE_USAGE
       WHERE wip_entity_id = p_wip_entity_id
       AND   organization_id = p_organization_id
       AND   operation_seq_num = p_operation_seq_num
       AND   resource_seq_num = p_resource_seq_num;

/**********************DELETE ALL EXISTING RECORDS BEFORE ADD *************/

   FOR cur_update IN Usage_Update(p_group_id , p_wip_entity_id,
                       p_organization_id, p_operation_seq_num,
                       p_resource_seq_num ) LOOP

      IF cur_update.substitution_type = WIP_JOB_DETAILS.WIP_ADD THEN

        INSERT INTO WIP_OPERATION_RESOURCE_USAGE
         ( WIP_ENTITY_ID  ,
          ORGANIZATION_ID,
          OPERATION_SEQ_NUM,
           RESOURCE_SEQ_NUM,
          START_DATE ,
          COMPLETION_DATE,
          ASSIGNED_UNITS ,
          LAST_UPDATE_DATE,
          LAST_UPDATED_BY,
          CREATION_DATE,
          CREATED_BY,
          LAST_UPDATE_LOGIN,
          REQUEST_ID,
	  PROGRAM_APPLICATION_ID,
	  PROGRAM_ID,
          PROGRAM_UPDATE_DATE )
       VALUES
       ( cur_update.wip_entity_id,
         cur_update.organization_id,
         cur_update.operation_seq_num,
         cur_update.resource_seq_num,
         cur_update.start_date,
         cur_update.completion_date,
         cur_update.assigned_units,
         cur_update.last_update_date,
         cur_update.last_updated_by,
         cur_update.creation_date,
         cur_update.created_by,
         cur_update.last_update_login,
         cur_update.request_id,
         cur_update.program_application_id,
         cur_update.program_id,
         cur_update.program_update_date);

   END IF;

  END LOOP;

 exception
   When others then
     x_err_code := SQLCODE;
     x_err_msg := 'Error in wiprudfb: '|| SQLERRM;
     x_return_status := FND_API.G_RET_STS_ERROR;
     return;
 end;

END Sub_Usage;

END WIP_RES_USAGE_SUBSTITUTIONS;

/

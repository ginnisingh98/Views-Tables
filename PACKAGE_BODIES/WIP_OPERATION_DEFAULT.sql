--------------------------------------------------------
--  DDL for Package Body WIP_OPERATION_DEFAULT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_OPERATION_DEFAULT" as
/* $Header: wipopdfb.pls 115.7 2002/11/29 09:33:36 rmahidha ship $ */

Procedure Default_Operations(p_group_id  in number,
                             p_parent_header_id in number,
                             p_wip_entity_id    in number,
                             p_organization_id  in number,
                             p_substitution_type in number,
                             x_err_code out nocopy varchar2,
                             x_err_msg out nocopy varchar2,
                             x_return_status out nocopy varchar2 ) IS

   CURSOR oper_info ( p_group_id number,
                       p_wip_entity_id  number,
                       p_organization_id number,
                       p_substitution_type number) IS
    SELECT distinct  parent_header_id,operation_seq_num, standard_operation_id,
           department_id, description , first_unit_start_date,
           first_unit_completion_date, last_unit_start_date,
           last_unit_completion_date, minimum_transfer_quantity,
           count_point_type, backflush_flag,last_update_date,
           last_updated_by, creation_date,created_by, last_update_login,
           request_id, program_application_id, program_id, program_update_date,
           attribute_category, attribute1, attribute2, attribute3,
           attribute4, attribute5,
           attribute6, attribute7, attribute8, attribute9, attribute10,
           attribute11, attribute12, attribute13, attribute14, attribute15
     FROM WIP_JOB_DTLS_INTERFACE
    WHERE group_id = p_group_id
      AND process_phase = WIP_CONSTANTS.ML_VALIDATION
      AND process_status in (WIP_CONSTANTS.RUNNING,WIP_CONSTANTS.WARNING)
      AND wip_entity_id = p_wip_entity_id
      AND organization_id = p_organization_id
      AND load_type = WIP_JOB_DETAILS.WIP_OPERATION
      AND substitution_type = p_substitution_type
      ORDER BY operation_seq_num;

  Begin

    For cur_row in oper_info (p_group_id, p_wip_entity_id,
                              p_organization_id, p_substitution_type) Loop

       Default_Oper(p_group_id, cur_row.parent_header_id,
                    p_wip_entity_id, p_organization_id,
                    cur_row.operation_seq_num, p_substitution_type,
                    cur_row.description,cur_row.department_id,
                    cur_row.standard_operation_id,
                    cur_row.first_unit_start_date,
                    cur_row.first_unit_completion_date,
                    cur_row.last_unit_start_date,
                    cur_row.last_unit_completion_date,
                    cur_row.minimum_transfer_quantity,
                    cur_row.count_point_type,
                    cur_row.backflush_flag,
                    x_err_code,x_err_msg, x_return_status);

      END LOOP;

      exception
	when others then
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END DEFAULT_OPERATIONS;

Procedure Default_Oper (p_group_id in number,
                            p_parent_header_id in number := NULL,
                            p_wip_entity_id number,
                            p_organization_id number,
                            p_operation_seq_num number,
                            p_substitution_type number,
                            p_description varchar2 := NULL,
                            p_department_id number := NULL,
                            p_standard_operation_id number:=NULL,
                            p_fusd date := NULL,
                            p_fucd date := NULL,
                            p_lusd date := NULL,
                            p_lucd date := NULL,
                            p_min_xfer_qty number := NULL,
                            p_count_point number := NULL,
                            p_backflush_flag number := NULL,
                            x_err_code out nocopy varchar2,
                            x_err_msg out nocopy varchar2,
                            x_return_status out nocopy varchar2 ) IS

   l_department_id NUMBER;
   l_min_xfer_qty  NUMBER;
   l_count_point_type NUMBER;
   l_operation_description VARCHAR2(240);
   l_backflush_flag NUMBER;
   l_organization_id NUMBER;
   l_first_unit_start_date DATE;
   l_first_unit_completion_date DATE;
   l_last_unit_start_date DATE;
   l_last_unit_completion_date DATE;
   l_start_quantity NUMBER;
   l_standard_oper number;
   l_parent_header number;

BEGIN

  l_department_id := 0;
  l_min_xfer_qty := 0;
  l_count_point_type := 0;
  l_operation_description := null;
  l_backflush_flag := 0;
  l_organization_id := 0;
  l_first_unit_start_date := null;
  l_first_unit_completion_date := null;
  l_last_unit_start_date := null;
  l_last_unit_completion_date := null;
  l_start_quantity := 0;
  l_standard_oper := 0;
  l_parent_header := 0;

  begin

   IF p_group_id IS NULL OR
      (p_wip_entity_id IS NULL and p_parent_header_id IS NULL)OR
      p_organization_id IS NULL OR p_operation_seq_num IS NULL THEN

      x_err_code := SQLCODE;
      x_err_msg := 'Primary key cannot be NULL!';
      x_return_status := FND_API.G_RET_STS_ERROR;
      return;
   END IF;

   IF p_substitution_type = WIP_JOB_DETAILS.WIP_ADD  THEN

      IF p_standard_operation_id IS NOT NULL
         AND p_standard_operation_id IS NOT NULL THEN

        select count(*) into l_standard_oper
        from bom_standard_operations
        where standard_operation_id = p_standard_operation_id
        and organization_id = p_organization_id;

        IF l_standard_oper = 1 THEN
         SELECT department_id, minimum_transfer_quantity,
                count_point_type, operation_description,
                backflush_flag
         INTO  l_department_id, l_min_xfer_qty, l_count_point_type,
               l_operation_description, l_backflush_flag
         FROM   BOM_STANDARD_OPERATIONS
         WHERE standard_operation_id = p_standard_operation_id
         AND  organization_id = p_organization_id;
        END IF;

     END IF;

     IF WIP_JOB_DETAILS.std_alone = 0 THEN

        SELECT COUNT(*) INTO l_parent_header
        FROM WIP_JOB_SCHEDULE_INTERFACE
        WHERE header_id = p_parent_header_id
        AND  group_id = p_group_id;

       IF l_parent_header = 1 THEN
        SELECT organization_id, first_unit_start_date,
               first_unit_completion_date, last_unit_start_date,
               last_unit_completion_date, start_quantity
        INTO   l_organization_id, l_first_unit_start_date,
               l_first_unit_completion_date, l_last_unit_start_date,
               l_last_unit_completion_date, l_start_quantity
        FROM  WIP_JOB_SCHEDULE_INTERFACE
        WHERE header_id = p_parent_header_id
        AND   group_id = p_group_id;
      END IF;

     END IF;
   END IF;

  Exception
     WHEN others then
     x_return_status := FND_API.G_RET_STS_ERROR;
     x_err_msg := 'ERROR IN WIPOPDFB: ' || SQLERRM;
     x_err_code := SQLCODE;
     return;
  end;

   /*******  UPDATE THE WIP_JOB_DTLS_INTERFACE TABLE *************/

       UPDATE WIP_JOB_DTLS_INTERFACE
       SET
           department_id = decode(p_department_id,
                                  NULL, l_department_id, p_department_id),
           minimum_transfer_quantity = decode(p_min_xfer_qty,
                                           NULL,l_min_xfer_qty,p_min_xfer_qty),
           count_point_type = decode(p_count_point,
                                     NULL, l_count_point_type,p_count_point),
           description = decode(p_description,
                                NULL, l_operation_description,p_description),
           backflush_flag= decode(p_backflush_flag,
                                 NULL,l_backflush_flag,p_backflush_flag),
           first_unit_start_date= decode(p_fusd,
                                    NULL,
                                    l_first_unit_start_date,
				    p_fusd),
           first_unit_completion_date= decode(p_fucd,
                                              NULL,
                                              l_first_unit_completion_date,
                                              p_fucd),
           last_unit_start_date = decode(p_lusd,
                                         NULL,
                                         l_last_unit_start_date,
                                         p_lusd),
           last_unit_completion_date = decode(p_lucd,
                                              NULL,
                                              l_last_unit_completion_date,
                                              p_lucd)
       WHERE group_id = p_group_id
       AND  (parent_header_id = p_parent_header_id OR
             wip_entity_id = p_wip_entity_id)
       AND   organization_id = p_organization_id
       AND   load_type = WIP_JOB_DETAILS.WIP_OPERATION
       AND   substitution_type = WIP_JOB_DETAILS.WIP_ADD
       AND   operation_seq_num = p_operation_seq_num;

  END Default_Oper;
END WIP_OPERATION_DEFAULT;

/

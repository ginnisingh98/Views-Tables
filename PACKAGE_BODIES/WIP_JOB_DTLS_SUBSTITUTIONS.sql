--------------------------------------------------------
--  DDL for Package Body WIP_JOB_DTLS_SUBSTITUTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_JOB_DTLS_SUBSTITUTIONS" AS
/* $Header: wipjdstb.pls 120.20.12010000.4 2010/02/05 01:41:15 pding ship $ */

type date_tbl_t is table of date          ; /* Fix for Bug4656331 */
type rowid_tbl_t is table of varchar2(18) ; /* Fix for Bug4656331 */


Procedure Delete_Resource (p_group_id           in number,
                           p_wip_entity_id      in number,
                           p_organization_id    in number,
                           p_err_code           out NOCOPY     varchar2,
                           p_err_msg            out NOCOPY     varchar2) IS

   CURSOR res_info (p_group_id          number,
                   p_wip_entity_id      number,
                   p_organization_id    number) IS
   SELECT distinct operation_seq_num,
          resource_seq_num, resource_id_old, resource_id_new,
          usage_rate_or_amount,
          last_update_date, last_updated_by, creation_date, created_by,
          last_update_login, request_id, program_application_id,
          program_id, program_update_date,
          scheduled_flag, assigned_units, applied_resource_units,
          applied_resource_value, uom_code, basis_type,
          activity_id, autocharge_type, standard_rate_flag,
          start_date, completion_date,attribute_category, attribute1,
          attribute2,attribute3,attribute4,attribute5,attribute6,attribute7,
          attribute8,attribute9,attribute10,attribute11,attribute12,
          attribute13,attribute14,attribute15
     FROM WIP_JOB_DTLS_INTERFACE
    WHERE group_id = p_group_id
      AND process_phase = WIP_CONSTANTS.ML_VALIDATION
      AND process_status in (WIP_CONSTANTS.RUNNING,WIP_CONSTANTS.WARNING)
      AND wip_entity_id = p_wip_entity_id
      AND organization_id = p_organization_id
      AND load_type = WIP_JOB_DETAILS.WIP_RESOURCE
      AND substitution_type = WIP_JOB_DETAILS.WIP_DELETE;

  l_ret_exp_status boolean := true; --Bug#4675116

BEGIN

    begin
    FOR cur_row IN res_info(p_group_id,
                           p_wip_entity_id,
                           p_organization_id) LOOP

         Delete_Resource_Usage(p_wip_entity_id,
                               p_organization_id,
                               cur_row.operation_seq_num,
                               cur_row.resource_seq_num,
                               p_err_code,
                               p_err_msg);

          l_ret_exp_status := WIP_WS_EXCEPTIONS.close_exception_jobop_res
          (
            p_wip_entity_id       => p_wip_entity_id,
            p_operation_seq_num   => cur_row.operation_seq_num,
            p_resource_seq_num    => cur_row.resource_seq_num,
            p_organization_id     => p_organization_id
          );

         DELETE FROM WIP_OPERATION_RESOURCES
          WHERE  wip_entity_id = p_wip_entity_id
            AND  organization_id = p_organization_id
            AND  operation_seq_num = cur_row.operation_seq_num
            AND  resource_seq_num =  cur_row.resource_seq_num
            AND  resource_id    =  cur_row.resource_id_old;

    END LOOP;

    exception
        when others then
             p_err_msg := 'WIPJDSTB, Delete_Resource: ' || SQLERRM;
             p_err_code := SQLCODE;
    end;

END Delete_Resource;


Procedure Add_Resource (p_group_id              number,
                        p_wip_entity_id number,
                        p_organization_id       number,
                        p_err_code   out NOCOPY     varchar2,
                        p_err_msg    out NOCOPY     varchar2) IS


   CURSOR res_info (p_group_id          number,
                   p_wip_entity_id      number,
                   p_organization_id    number) IS
   SELECT distinct operation_seq_num,
          resource_seq_num, resource_id_old, resource_id_new,
          usage_rate_or_amount,
          last_update_date, last_updated_by, creation_date, created_by,
          last_update_login, request_id, program_application_id,
          program_id, program_update_date,
          scheduled_flag, assigned_units, applied_resource_units,
          applied_resource_value, uom_code, basis_type,
          activity_id, autocharge_type, standard_rate_flag,
          start_date, completion_date,attribute_category, attribute1,
          attribute2,attribute3,attribute4,attribute5,attribute6,attribute7,
          attribute8,attribute9,attribute10,attribute11,attribute12,
          attribute13,attribute14,attribute15,schedule_seq_num,
          substitute_group_num,replacement_group_num, firm_flag, setup_id,
          group_sequence_id, group_sequence_number, maximum_assigned_units,
          parent_seq_num, batch_id
     FROM WIP_JOB_DTLS_INTERFACE
    WHERE group_id = p_group_id
      AND process_phase = WIP_CONSTANTS.ML_VALIDATION
      AND process_status in (WIP_CONSTANTS.RUNNING,WIP_CONSTANTS.WARNING)
      AND wip_entity_id = p_wip_entity_id
      AND organization_id = p_organization_id
      AND load_type = WIP_JOB_DETAILS.WIP_RESOURCE
      AND substitution_type = WIP_JOB_DETAILS.WIP_ADD;

  l_scheduling_method number;
  l_scheduled_start_date date;/* Bug 3669728*/
  l_scheduled_completion_date date;/* Bug 3669728*/
  l_first_unit_start_date date;/* Bug 3669728*/
  l_last_unit_completion_date date;/* Bug 3669728*/


BEGIN

    begin

  /* Moved the delete statement out of the loop for fixing bug 4357678
  Every time in the loop, this was deleting the inserted records as well */
   FOR cur_row IN res_info(p_group_id,
                           p_wip_entity_id,
                           p_organization_id) LOOP
        -- if adding setup resource, delete all existing setup resources
        if (cur_row.parent_seq_num is not null) then
         DELETE FROM WIP_OPERATION_RESOURCES
          WHERE  wip_entity_id = p_wip_entity_id
            AND  organization_id = p_organization_id
            AND  operation_seq_num = cur_row.operation_seq_num
            AND  parent_resource_seq =  cur_row.parent_seq_num;
        end if;
    END LOOP ;

    FOR cur_row IN res_info(p_group_id,
                           p_wip_entity_id,
                           p_organization_id) LOOP


        /* insert into table */
        INSERT INTO WIP_OPERATION_RESOURCES(
                wip_entity_id,
                organization_id,
                operation_seq_num,
                resource_seq_num,
                resource_id,
                usage_rate_or_amount,
                last_update_date,
                last_updated_by,
                creation_date,
                created_by,
                last_update_login,
                request_id,
                program_application_id,
                program_id,
                program_update_date,
                scheduled_flag,
                assigned_units,
                applied_resource_units,
                applied_resource_value,
                uom_code,
                basis_type,
                activity_id,
                autocharge_type,
                standard_rate_flag,
                start_date,
                completion_date,
                attribute_category,
                attribute1,
                attribute2,
                attribute3,
                attribute4,
                attribute5,
                attribute6,
                attribute7,
                attribute8,
                attribute9,
                attribute10,
                attribute11,
                attribute12,
                attribute13,
                attribute14,
                attribute15,
                schedule_seq_num,
                substitute_group_num,
                replacement_group_num,
                firm_flag,
                setup_id,
                group_sequence_id,
                group_sequence_number,
                maximum_assigned_units,
                parent_resource_seq,
                batch_id)
        VALUES (
                p_wip_entity_id,
                p_organization_id,
                cur_row.operation_seq_num,
                cur_row.resource_seq_num,
                cur_row.resource_id_new,
                cur_row.usage_rate_or_amount,
                sysdate,/*BUG 6721823*/
                cur_row.last_updated_by,
                cur_row.creation_date,
                cur_row.created_by,
                cur_row.last_update_login,
                cur_row.request_id,
                cur_row.program_application_id,
                cur_row.program_id,
                cur_row.program_update_date,
                cur_row.scheduled_flag,
                cur_row.assigned_units,
                cur_row.applied_resource_units,
                cur_row.applied_resource_value,
                cur_row.uom_code,
                cur_row.basis_type,
                cur_row.activity_id,
                cur_row.autocharge_type,
                cur_row.standard_rate_flag,
                cur_row.start_date,
                cur_row.completion_date,
                cur_row.attribute_category,
                cur_row.attribute1,
                cur_row.attribute2,
                cur_row.attribute3,
                cur_row.attribute4,
                cur_row.attribute5,
                cur_row.attribute6,
                cur_row.attribute7,
                cur_row.attribute8,
                cur_row.attribute9,
                cur_row.attribute10,
                cur_row.attribute11,
                cur_row.attribute12,
                cur_row.attribute13,
                cur_row.attribute14,
                cur_row.attribute15,
                cur_row.schedule_seq_num,
                cur_row.substitute_group_num,
                cur_row.replacement_group_num,
                cur_row.firm_flag,
                cur_row.setup_id,
                cur_row.group_sequence_id,
                cur_row.group_sequence_number,
                cur_row.maximum_assigned_units,
                cur_row.parent_seq_num,
                cur_row.batch_id);

      IF WIP_JOB_DETAILS.std_alone = 0 THEN

        SELECT scheduling_method INTO l_scheduling_method
          FROM WIP_JOB_SCHEDULE_INTERFACE
         WHERE group_id = p_group_id
           AND wip_entity_id = p_wip_entity_id
           AND organization_id = p_organization_id;

      END IF;

      -- We check that whether there're usage records for this resource
      -- If it's stand alone or the scheduling_method is manaul (3)
      -- we need default a resource usage.

      IF WIP_JOB_DETAILS.std_alone = 1 OR
         ( WIP_JOB_DETAILS.std_alone = 0 AND l_scheduling_method = 3) THEN

        IF Num_Of_Usage(p_group_id, /* Fix for bug#3636378 */
                        p_wip_entity_id,
                        p_organization_id,
                        cur_row.operation_seq_num,
                        cur_row.resource_seq_num) = 0 THEN

          Add_Default_Usage(p_wip_entity_id,
                            p_organization_id,
                            cur_row.operation_seq_num,
                            cur_row.resource_seq_num);

        END IF;
      END IF;

/* bug#3669728 - begin */
      select scheduled_start_date,scheduled_completion_date
      into l_scheduled_start_date,l_scheduled_completion_date
      from wip_discrete_jobs
      where wip_entity_id = p_wip_entity_id
      AND   organization_id = p_organization_id;

      IF  (cur_row.start_date  is not null
           AND  cur_row.start_date  < l_scheduled_start_date)
      THEN
         UPDATE wip_discrete_jobs
         set scheduled_start_date = cur_row.start_date
         where wip_entity_id = p_wip_entity_id
         AND   organization_id = p_organization_id;
      END IF;
      IF  (cur_row.completion_date is not null
           AND  cur_row.completion_date > l_scheduled_completion_date)
      THEN
         UPDATE wip_discrete_jobs
         set scheduled_completion_date = cur_row.completion_date
         where wip_entity_id = p_wip_entity_id
         AND   organization_id = p_organization_id;
      END IF;

      select first_unit_start_date,last_unit_completion_date
      into l_first_unit_start_date,l_last_unit_completion_date
      from wip_operations
      where wip_entity_id = p_wip_entity_id
      AND   organization_id = p_organization_id
      AND   operation_seq_num = cur_row.operation_seq_num;

      IF  (cur_row.start_date  is not null
           AND  cur_row.start_date  < l_first_unit_start_date)
      THEN
         UPDATE wip_operations
         set first_unit_start_date = cur_row.start_date,
	     LAST_UPDATE_DATE=sysdate/*BUG 6721823*/
         where wip_entity_id = p_wip_entity_id
         AND   organization_id = p_organization_id
         AND   operation_seq_num = cur_row.operation_seq_num;
      END IF;
      IF  (cur_row.completion_date is not null
           AND  cur_row.completion_date > l_last_unit_completion_date)
      THEN
         UPDATE wip_operations
         set last_unit_completion_date = cur_row.completion_date,
             LAST_UPDATE_DATE=sysdate/*BUG 6721823*/
         where wip_entity_id = p_wip_entity_id
         AND   organization_id = p_organization_id
         AND   operation_seq_num = cur_row.operation_seq_num;
      END IF;
/* bug#3669728 - end */

    END LOOP;

    exception
       when others then
             p_err_msg := 'WIPJDSTB, Add_Resource: ' || SQLERRM;
             p_err_code := SQLCODE;
    end;

END Add_Resource;


Procedure Change_Resource (p_group_id           number,
                           p_wip_entity_id      number,
                           p_organization_id    number,
                           p_err_code   out NOCOPY     varchar2,
                           p_err_msg    out NOCOPY     varchar2) IS

   CURSOR res_info (p_group_id          number,
                   p_wip_entity_id      number,
                   p_organization_id    number) IS
   SELECT distinct operation_seq_num,
          resource_seq_num, resource_id_old, resource_id_new,
          usage_rate_or_amount,
          last_update_date, last_updated_by, creation_date, created_by,
          last_update_login, request_id, program_application_id,
          program_id, program_update_date,
          scheduled_flag, assigned_units, applied_resource_units,
          applied_resource_value, uom_code, basis_type,
          activity_id, autocharge_type, standard_rate_flag,
          start_date, completion_date,attribute_category, attribute1,
          attribute2,attribute3,attribute4,attribute5,attribute6,attribute7,
          attribute8,attribute9,attribute10,attribute11,attribute12,
          attribute13,attribute14,attribute15, schedule_seq_num,
          substitute_group_num, replacement_group_num, firm_flag,setup_id,
          group_sequence_id, group_sequence_number, maximum_assigned_units,
          parent_seq_num, batch_id
     FROM WIP_JOB_DTLS_INTERFACE
    WHERE group_id = p_group_id
      AND process_phase = WIP_CONSTANTS.ML_VALIDATION
      AND process_status in (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING)
      AND wip_entity_id = p_wip_entity_id
      AND organization_id = p_organization_id
      AND load_type = WIP_JOB_DETAILS.WIP_RESOURCE
      AND substitution_type = WIP_JOB_DETAILS.WIP_CHANGE;

       cursor missing_res_csr
       is
       select wo.first_unit_start_date,
              rowidtochar(wor.rowid)
       from   wip_operation_resources wor,
              wip_operations wo
       where  wo.wip_entity_id = wor.wip_entity_id
       and    wo.organization_id = wor.organization_id
       and    wo.operation_seq_num = wor.operation_seq_num
       and    wor.wip_entity_id = p_wip_entity_id
       and    wor.organization_id = p_organization_id
       and    not exists ( select 1
                           FROM   WIP_JOB_DTLS_INTERFACE
                           WHERE group_id = p_group_id
                           AND process_phase = WIP_CONSTANTS.ML_VALIDATION
                           AND process_status in (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING)
                           AND wip_entity_id = p_wip_entity_id
                           AND organization_id = p_organization_id
                           AND load_type = WIP_JOB_DETAILS.WIP_RESOURCE
                           AND operation_seq_num = wor.operation_seq_num
                           AND resource_seq_num  = wor.resource_seq_num
                         ) ;

     l_source_code varchar2(255) ;


  l_scheduling_method   number := 0;
  l_replace_res number := 0;
  l_current_sub number;
  x_status varchar2(30);
  x_msg_count number;
  x_msg_data varchar2(30);
  l_scheduled_start_date date;/* Bug 3669728*/
  l_scheduled_completion_date date;/* Bug 3669728*/
  l_first_unit_start_date date;/* Bug 3669728*/
  l_last_unit_completion_date date;/* Bug 3669728*/
  l_dummy2 VARCHAR2(1);
  l_logLevel number;

  l_ret_exp_status boolean := true; --Bug#4675116

  l_rowidTbl rowid_tbl_t ; /* Fix for Bug#4656331 */
  l_fusdTbl  date_tbl_t  ; /* Fix for Bug#4656331 */

BEGIN

    begin
      FOR cur_row IN res_info(p_group_id,
                           p_wip_entity_id,
                           p_organization_id) LOOP

        l_replace_res := 0;

        select substitute_group_num
            into l_current_sub
          from wip_operation_resources
        where wip_entity_id = p_wip_entity_id
             and operation_seq_num = cur_row.operation_seq_num
             and resource_seq_num = cur_row.resource_seq_num;

        IF (cur_row.substitute_group_num = l_current_sub) THEN

            begin
              select 1
                  into l_replace_res
                 from dual
              where exists (select 1
                                       from wip_sub_operation_resources
                                      where wip_entity_id = p_wip_entity_id
                                           and operation_seq_num = cur_row.operation_seq_num
                                           and substitute_group_num = cur_row.substitute_group_num
                                           and replacement_group_num = cur_row.replacement_group_num);
            exception
              when no_data_found then
                l_replace_res := 0;
            end;

            if (l_replace_res = 1) then
                   wip_sub_op_resources_pkg.Replace_Resources(
                                          p_wip_entity_id,
                                          null,
                                          cur_row.operation_seq_num,
                                          cur_row.substitute_group_num,
                                          cur_row.replacement_group_num,
                                          x_status,
                                          x_msg_count,
                                          x_msg_data);
                 UPDATE WIP_OPERATION_RESOURCES
                       SET start_date      = NVL(cur_row.start_date,start_date),
                               completion_date = NVL(cur_row.completion_date,completion_date),
			   LAST_UPDATE_DATE=sysdate/*BUG 6721823*/
                   WHERE   wip_entity_id        =   p_wip_entity_id
                        AND   organization_id       =   p_organization_id
                        AND   operation_seq_num     =   cur_row.operation_seq_num
                        AND   substitute_group_num  =   cur_row.substitute_group_num;
            end if;
        END IF;

        IF (l_replace_res = 0) then

          --Bug#4675116
          IF (CUR_ROW.RESOURCE_ID_OLD <> CUR_ROW.RESOURCE_ID_NEW) THEN
            L_RET_EXP_STATUS := WIP_WS_EXCEPTIONS.CLOSE_EXCEPTION_JOBOP_RES
            (
              P_WIP_ENTITY_ID     => P_WIP_ENTITY_ID,
              P_OPERATION_SEQ_NUM => cur_row.OPERATION_SEQ_NUM,
              P_RESOURCE_SEQ_NUM  => cur_row.RESOURCE_SEQ_NUM,
              P_ORGANIZATION_ID   => P_ORGANIZATION_ID
            );
          END IF;

          UPDATE WIP_OPERATION_RESOURCES
          SET  resource_id           =   cur_row.resource_id_new,
                usage_rate_or_amount    =   nvl(cur_row.usage_rate_or_amount,
                                                usage_rate_or_amount),
                last_update_date        =   sysdate,/*BUG 6721823*/
                last_updated_by         =   cur_row.last_updated_by,
                creation_date           =   cur_row.creation_date,
                created_by              =   cur_row.created_by,
                last_update_login       =   cur_row.last_update_login,
                request_id              =   cur_row.request_id,
                program_application_id  =   cur_row.program_application_id,
                program_id              =   cur_row.program_id,
                program_update_date     =   cur_row.program_update_date,
                scheduled_flag          =   nvl(cur_row.scheduled_flag,
                                                scheduled_flag),
                assigned_units          =   nvl(cur_row.assigned_units, assigned_units),
                uom_code                =   nvl(cur_row.uom_code, uom_code),
                basis_type              =   nvl(cur_row.basis_type, basis_type),
                activity_id             =   nvl(cur_row.activity_id, activity_id),
                autocharge_type         =   nvl(cur_row.autocharge_type, autocharge_type),
                standard_rate_flag      =   nvl(cur_row.standard_rate_flag, standard_rate_flag),
                start_date              =     nvl(cur_row.start_date, start_date),
                completion_date         =   nvl(cur_row.completion_date, completion_date),
                attribute_category      =   NVL(cur_row.attribute_category,
                                            attribute_category),
                attribute1              =   NVL(cur_row.attribute1,attribute1),
                attribute2              =   NVL(cur_row.attribute2,attribute2),
                attribute3              =   NVL(cur_row.attribute3,attribute3),
                attribute4              =   NVL(cur_row.attribute4,attribute4),
                attribute5              =   NVL(cur_row.attribute5,attribute5),
                attribute6              =   NVL(cur_row.attribute6,attribute6),
                attribute7              =   NVL(cur_row.attribute7,attribute7),
                attribute8              =   NVL(cur_row.attribute8,attribute8),
                attribute9              =   NVL(cur_row.attribute9,attribute9),
                attribute10             =   NVL(cur_row.attribute10,attribute10),
                attribute11             =   NVL(cur_row.attribute11,attribute11),
                attribute12             =   NVL(cur_row.attribute12,attribute12),
                attribute13             =   NVL(cur_row.attribute13,attribute13),
                attribute14             =   NVL(cur_row.attribute14,attribute14),
                attribute15             =   NVL(cur_row.attribute15,attribute15),
                schedule_seq_num = decode(cur_row.schedule_seq_num, fnd_api.g_miss_num, null, cur_row.schedule_seq_num),
                substitute_group_num = decode(cur_row.substitute_group_num, fnd_api.g_miss_num, null, cur_row.substitute_group_num),
                replacement_group_num =  decode(cur_row.replacement_group_num, fnd_api.g_miss_num, null, cur_row.replacement_group_num),
                firm_flag               =   NVL(cur_row.firm_flag, firm_flag),
                setup_id                =   NVL(cur_row.setup_id, setup_id),
                group_sequence_id       =   NVL(cur_row.group_sequence_id, group_sequence_id),
                group_sequence_number   =   NVL(cur_row.group_sequence_number, group_sequence_number),
                maximum_assigned_units  =   NVL(cur_row.maximum_assigned_units, maximum_assigned_units),
                parent_resource_seq     =   NVL(cur_row.parent_seq_num, parent_resource_seq),
                batch_id                =   NVL(cur_row.batch_id,batch_id)
          WHERE   wip_entity_id                 =   p_wip_entity_id
            AND   organization_id               =   p_organization_id
            AND   operation_seq_num     =   cur_row.operation_seq_num
            AND   resource_seq_num      =   cur_row.resource_seq_num
            AND   resource_id           =   cur_row.resource_id_old;

           Delete_Resource_Usage(p_wip_entity_id,
                               p_organization_id,
                               cur_row.operation_seq_num,
                               cur_row.resource_seq_num,
                               p_err_code,
                               p_err_msg);

          IF WIP_JOB_DETAILS.std_alone = 0 THEN

             SELECT scheduling_method INTO l_scheduling_method
               FROM WIP_JOB_SCHEDULE_INTERFACE
              WHERE group_id = p_group_id
                AND wip_entity_id = p_wip_entity_id
                AND organization_id = p_organization_id;

          END IF;

          -- We check that whether there're usage records for this resource
          -- If it's stand alone or the scheduling_method is manual (3)
          -- we need default a resource usage.

         IF WIP_JOB_DETAILS.std_alone = 1 OR
           ( WIP_JOB_DETAILS.std_alone = 0 AND l_scheduling_method = 3) THEN

             IF Num_Of_Usage(p_group_id, /* Fix for bug#3636378 */
                        p_wip_entity_id,
                        p_organization_id,
                        cur_row.operation_seq_num,
                        cur_row.resource_seq_num) = 0 THEN

                 Add_Default_Usage(p_wip_entity_id,
                            p_organization_id,
                            cur_row.operation_seq_num,
                            cur_row.resource_seq_num);

             END IF;

         END IF;

/* bug#3669728 - begin */
         select scheduled_start_date,scheduled_completion_date
         into l_scheduled_start_date,l_scheduled_completion_date
         from wip_discrete_jobs
         where wip_entity_id = p_wip_entity_id
         AND   organization_id = p_organization_id;

         IF  (cur_row.start_date  is not null
              AND  cur_row.start_date  < l_scheduled_start_date)
         THEN
            UPDATE wip_discrete_jobs
            set scheduled_start_date = cur_row.start_date
            where wip_entity_id = p_wip_entity_id
            AND   organization_id = p_organization_id;
         END IF;
         IF  (cur_row.completion_date is not null
              AND  cur_row.completion_date > l_scheduled_completion_date)
         THEN
            UPDATE wip_discrete_jobs
            set scheduled_completion_date = cur_row.completion_date
            where wip_entity_id = p_wip_entity_id
            AND   organization_id = p_organization_id;
         END IF;

         select first_unit_start_date,last_unit_completion_date
         into l_first_unit_start_date,l_last_unit_completion_date
         from wip_operations
         where wip_entity_id = p_wip_entity_id
         AND   organization_id = p_organization_id
         AND   operation_seq_num = cur_row.operation_seq_num;

         IF  (cur_row.start_date  is not null
              AND  cur_row.start_date  < l_first_unit_start_date)
         THEN
            UPDATE wip_operations
            set first_unit_start_date = cur_row.start_date,
	        LAST_UPDATE_DATE=sysdate/*BUG 6721823*/
            where wip_entity_id = p_wip_entity_id
            AND   organization_id = p_organization_id
            AND   operation_seq_num = cur_row.operation_seq_num;
         END IF;
         IF  (cur_row.completion_date is not null
              AND  cur_row.completion_date > l_last_unit_completion_date)
         THEN
            UPDATE wip_operations
            set last_unit_completion_date = cur_row.completion_date,
	        LAST_UPDATE_DATE=sysdate/*BUG 6721823*/
            where wip_entity_id = p_wip_entity_id
            AND   organization_id = p_organization_id
            AND   operation_seq_num = cur_row.operation_seq_num;
         END IF;
/* bug#3669728 - end */

      END IF;

    END LOOP;


    /* Fix for Bug#4656331. Update missing resource start date and completion
          date
       */
       select source_code,
              scheduling_method
       into   l_source_code,
              l_scheduling_method
       from   wip_job_schedule_interface
       where  group_id = p_group_id
       and    wip_entity_id = p_wip_entity_id
       and    organization_id = p_organization_id ;

     /* Fix for Bug#6394857 (FP of 6370245). Removed scheduling method condition in following if and also
 	open cursor when source_code is MSC.

       if (l_source_code = 'MSC' and l_scheduling_method = WIP_CONSTANTS.ML_MANUAL) then
      */

      if (l_source_code = 'MSC') then

       open  missing_res_csr ;
       fetch missing_res_csr
             bulk collect into l_fusdTbl, l_rowidTbl ;
       close missing_res_csr ;

       forall i in 1..l_fusdTbl.count
               update wip_operation_resources
               set    start_date      = l_fusdTbl(i),
                      completion_date = l_fusdTbl(i),
		      LAST_UPDATE_DATE=sysdate/*BUG 6721823*/
               where  rowid = chartorowid(l_rowidTbl(i)) ;
       end if ;

    exception
       when others then
             p_err_msg := 'WIPJDSTB, Change_Resource: ' || SQLERRM;
             p_err_code := SQLCODE;
             l_logLevel := fnd_log.g_current_runtime_level;
             if (l_logLevel <= wip_constants.trace_logging) then
                    wip_logger.log(p_err_msg, l_dummy2);
             end if;

    /* 4656331. Close cursor if still open */
    if missing_res_csr%ISOPEN then
       close missing_res_csr ;
    end if ;

             wip_logger.cleanup(l_dummy2);
    end;
END Change_Resource;



Procedure Delete_Sub_Resource (p_group_id               in number,
                           p_wip_entity_id      in number,
                           p_organization_id    in number,
                           p_err_code           out NOCOPY     varchar2,
                           p_err_msg            out NOCOPY     varchar2) IS

   CURSOR res_info (p_group_id          number,
                   p_wip_entity_id      number,
                   p_organization_id    number) IS
   SELECT distinct operation_seq_num,
          resource_seq_num, resource_id_old, resource_id_new,
          usage_rate_or_amount,
          last_update_date, last_updated_by, creation_date, created_by,
          last_update_login, request_id, program_application_id,
          program_id, program_update_date,
          scheduled_flag, assigned_units, applied_resource_units,
          applied_resource_value, uom_code, basis_type,
          activity_id, autocharge_type, standard_rate_flag,
          start_date, completion_date,attribute_category, attribute1,
          attribute2,attribute3,attribute4,attribute5,attribute6,attribute7,
          attribute8,attribute9,attribute10,attribute11,attribute12,
          attribute13,attribute14,attribute15
     FROM WIP_JOB_DTLS_INTERFACE
    WHERE group_id = p_group_id
      AND process_phase = WIP_CONSTANTS.ML_VALIDATION
      AND process_status in (WIP_CONSTANTS.RUNNING,WIP_CONSTANTS.WARNING)
      AND wip_entity_id = p_wip_entity_id
      AND organization_id = p_organization_id
      AND load_type = WIP_JOB_DETAILS.WIP_SUB_RES
      AND substitution_type = WIP_JOB_DETAILS.WIP_DELETE;


BEGIN

    begin
    FOR cur_row IN res_info(p_group_id,
                           p_wip_entity_id,
                           p_organization_id) LOOP

         Delete_Resource_Usage(p_wip_entity_id,
                               p_organization_id,
                               cur_row.operation_seq_num,
                               cur_row.resource_seq_num,
                               p_err_code,
                               p_err_msg);

         DELETE FROM WIP_SUB_OPERATION_RESOURCES
          WHERE  wip_entity_id = p_wip_entity_id
            AND  organization_id = p_organization_id
            AND  operation_seq_num = cur_row.operation_seq_num
            AND  resource_seq_num =  cur_row.resource_seq_num
            AND  resource_id    =  cur_row.resource_id_old;

    END LOOP;

    exception
        when others then
             p_err_msg := 'WIPJDSTB, Delete_Resource: ' || SQLERRM;
             p_err_code := SQLCODE;
    end;

END Delete_Sub_Resource;


Procedure Add_Sub_Resource (p_group_id          number,
                           p_wip_entity_id      number,
                           p_organization_id    number,
                           p_err_code   out NOCOPY     varchar2,
                           p_err_msg    out NOCOPY     varchar2) IS


   CURSOR res_info (p_group_id          number,
                   p_wip_entity_id      number,
                   p_organization_id    number) IS
   SELECT distinct operation_seq_num,
          resource_seq_num, resource_id_old, resource_id_new,
          usage_rate_or_amount,
          last_update_date, last_updated_by, creation_date, created_by,
          last_update_login, request_id, program_application_id,
          program_id, program_update_date,
          scheduled_flag, assigned_units, maximum_assigned_units,applied_resource_units,
          applied_resource_value, uom_code, basis_type,
          activity_id, autocharge_type, standard_rate_flag,
          start_date, completion_date,attribute_category, attribute1,
          attribute2,attribute3,attribute4,attribute5,attribute6,attribute7,
          attribute8,attribute9,attribute10,attribute11,attribute12,
          attribute13,attribute14,attribute15,schedule_seq_num,
          substitute_group_num,replacement_group_num
     FROM WIP_JOB_DTLS_INTERFACE
    WHERE group_id = p_group_id
      AND process_phase = WIP_CONSTANTS.ML_VALIDATION
      AND process_status in (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING)
      AND wip_entity_id = p_wip_entity_id
      AND organization_id = p_organization_id
      AND load_type = WIP_JOB_DETAILS.WIP_SUB_RES
      AND substitution_type = WIP_JOB_DETAILS.WIP_ADD;

  l_scheduling_method number;

BEGIN

    begin
    FOR cur_row IN res_info(p_group_id,
                           p_wip_entity_id,
                           p_organization_id) LOOP

        /* insert into table */
        INSERT INTO WIP_SUB_OPERATION_RESOURCES(
                wip_entity_id,
                organization_id,
                operation_seq_num,
                resource_seq_num,
                resource_id,
                usage_rate_or_amount,
                last_update_date,
                last_updated_by,
                creation_date,
                created_by,
                last_update_login,
                request_id,
                program_application_id,
                program_id,
                program_update_date,
                scheduled_flag,
                assigned_units,
                maximum_assigned_units,
                applied_resource_units,
                applied_resource_value,
                uom_code,
                basis_type,
                activity_id,
                autocharge_type,
                standard_rate_flag,
                start_date,
                completion_date,
                attribute_category,
                attribute1,
                attribute2,
                attribute3,
                attribute4,
                attribute5,
                attribute6,
                attribute7,
                attribute8,
                attribute9,
                attribute10,
                attribute11,
                attribute12,
                attribute13,
                attribute14,
                attribute15,
                schedule_seq_num,
                substitute_group_num,
                replacement_group_num)

        VALUES (
                p_wip_entity_id,
                p_organization_id,
                cur_row.operation_seq_num,
                cur_row.resource_seq_num,
                cur_row.resource_id_new,
                cur_row.usage_rate_or_amount,
                sysdate,/*BUG 6721823*/
                cur_row.last_updated_by,
                cur_row.creation_date,
                cur_row.created_by,
                cur_row.last_update_login,
                cur_row.request_id,
                cur_row.program_application_id,
                cur_row.program_id,
                cur_row.program_update_date,
                cur_row.scheduled_flag,
                cur_row.assigned_units,
                cur_row.maximum_assigned_units,
                cur_row.applied_resource_units,
                cur_row.applied_resource_value,
                cur_row.uom_code,
                cur_row.basis_type,
                cur_row.activity_id,
                cur_row.autocharge_type,
                cur_row.standard_rate_flag,
                cur_row.start_date,
                cur_row.completion_date,
                cur_row.attribute_category,
                cur_row.attribute1,
                cur_row.attribute2,
                cur_row.attribute3,
                cur_row.attribute4,
                cur_row.attribute5,
                cur_row.attribute6,
                cur_row.attribute7,
                cur_row.attribute8,
                cur_row.attribute9,
                cur_row.attribute10,
                cur_row.attribute11,
                cur_row.attribute12,
                cur_row.attribute13,
                cur_row.attribute14,
                cur_row.attribute15,
                cur_row.schedule_seq_num,
                cur_row.substitute_group_num,
                cur_row.replacement_group_num);


    END LOOP;

    exception
       when others then
             p_err_msg := 'WIPJDSTB, Add_Sub_Resource: ' || SQLERRM;
             p_err_code := SQLCODE;
    end;

END Add_Sub_Resource;


Procedure Change_Sub_Resource (p_group_id               number,
                               p_wip_entity_id          number,
                               p_organization_id        number,
                               p_err_code       out NOCOPY     varchar2,
                               p_err_msg        out NOCOPY     varchar2) IS

   CURSOR res_info (p_group_id          number,
                   p_wip_entity_id      number,
                   p_organization_id    number) IS
   SELECT distinct operation_seq_num,
          resource_seq_num, resource_id_old, resource_id_new,
          usage_rate_or_amount,
          last_update_date, last_updated_by, creation_date, created_by,
          last_update_login, request_id, program_application_id,
          program_id, program_update_date,
          scheduled_flag, assigned_units, maximum_assigned_units,applied_resource_units,
          applied_resource_value, uom_code, basis_type,
          activity_id, autocharge_type, standard_rate_flag,
          start_date, completion_date,attribute_category, attribute1,
          attribute2,attribute3,attribute4,attribute5,attribute6,attribute7,
          attribute8,attribute9,attribute10,attribute11,attribute12,
          attribute13,attribute14,attribute15, schedule_seq_num,
          substitute_group_num, replacement_group_num
     FROM WIP_JOB_DTLS_INTERFACE
    WHERE group_id = p_group_id
      AND process_phase = WIP_CONSTANTS.ML_VALIDATION
      AND process_status in (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING)
      AND wip_entity_id = p_wip_entity_id
      AND organization_id = p_organization_id
      AND load_type = WIP_JOB_DETAILS.WIP_SUB_RES
      AND substitution_type = WIP_JOB_DETAILS.WIP_CHANGE;

  l_scheduling_method   number := 0;

BEGIN

    begin
    FOR cur_row IN res_info(p_group_id,
                           p_wip_entity_id,
                           p_organization_id) LOOP

        /* update the  table */
        /** Fix for bug 2438722 - correct attribute cols updated **/
        UPDATE WIP_SUB_OPERATION_RESOURCES
        SET     resource_id             =   cur_row.resource_id_new,
                usage_rate_or_amount    =   cur_row.usage_rate_or_amount,
                last_update_date        =   sysdate,/*BUG 6721823*/
                last_updated_by         =   cur_row.last_updated_by,
                creation_date           =   cur_row.creation_date,
                created_by              =   cur_row.created_by,
                last_update_login       =   cur_row.last_update_login,
                request_id              =   cur_row.request_id,
                program_application_id  =   cur_row.program_application_id,
                program_id              =   cur_row.program_id,
                program_update_date     =   cur_row.program_update_date,
                scheduled_flag          =   cur_row.scheduled_flag,
                assigned_units          =   cur_row.assigned_units,
                maximum_assigned_units  =   cur_row.maximum_assigned_units,
                applied_resource_units  =   nvl(cur_row.applied_resource_units,applied_resource_units),
                applied_resource_value  =   nvl(cur_row.applied_resource_value,applied_resource_value),
                uom_code                =   cur_row.uom_code,
                basis_type              =   nvl(cur_row.basis_type, basis_type),
                activity_id             =   cur_row.activity_id,
                autocharge_type         =   nvl(cur_row.autocharge_type, autocharge_type),
                standard_rate_flag      =   nvl(cur_row.standard_rate_flag, standard_rate_flag),
                start_date              =   nvl(cur_row.start_date, start_date),
                completion_date         =   nvl(cur_row.completion_date, completion_date),
                attribute_category      =   NVL(cur_row.attribute_category,
                                            attribute_category),
                attribute1              =   NVL(cur_row.attribute1,attribute1),
                attribute2              =   NVL(cur_row.attribute2,attribute2),
                attribute3              =   NVL(cur_row.attribute3,attribute3),
                attribute4              =   NVL(cur_row.attribute4,attribute4),
                attribute5              =   NVL(cur_row.attribute5,attribute5),
                attribute6              =   NVL(cur_row.attribute6,attribute6),
                attribute7              =   NVL(cur_row.attribute7,attribute7),
                attribute8              =   NVL(cur_row.attribute8,attribute8),
                attribute9              =   NVL(cur_row.attribute9,attribute9),
               attribute10              =   NVL(cur_row.attribute10,attribute10),
               attribute11              =   NVL(cur_row.attribute11,attribute11),
               attribute12              =   NVL(cur_row.attribute12,attribute12),
               attribute13              =   NVL(cur_row.attribute13,attribute13),
               attribute14              =   NVL(cur_row.attribute14,attribute14),
               attribute15              =   NVL(cur_row.attribute15,attribute15),
               schedule_seq_num        =   decode(cur_row.schedule_seq_num, fnd_api.g_miss_num, null, cur_row.schedule_seq_num),
                substitute_group_num    =   cur_row.substitute_group_num,
                replacement_group_num   =   cur_row.replacement_group_num
        WHERE   wip_entity_id           =   p_wip_entity_id
          AND   organization_id         =   p_organization_id
          AND   operation_seq_num       =   cur_row.operation_seq_num
          AND   resource_seq_num        =   cur_row.resource_seq_num
          AND   resource_id             =   cur_row.resource_id_old;

         Delete_Resource_Usage(p_wip_entity_id,
                               p_organization_id,
                               cur_row.operation_seq_num,
                               cur_row.resource_seq_num,
                               p_err_code,
                               p_err_msg);

    END LOOP;

    exception
       when others then
             p_err_msg := 'WIPJDSTB, Change_Sub_Resource: ' || SQLERRM;
             p_err_code := SQLCODE;
    end;
END Change_Sub_Resource;

Procedure Add_Resource_Instance (p_group_id         number,
                        p_wip_entity_id             number,
                        p_organization_id           number,
                        p_err_code   out NOCOPY     varchar2,
                        p_err_msg    out NOCOPY     varchar2) IS


   CURSOR res_info (p_group_id          number,
                   p_wip_entity_id      number,
                   p_organization_id    number) IS
   SELECT distinct operation_seq_num, resource_seq_num, resource_serial_number,
          resource_instance_id, start_date, completion_date, batch_id, interface_id,
          created_by, creation_date,last_updated_by,last_update_date
     FROM WIP_JOB_DTLS_INTERFACE
    WHERE group_id = p_group_id
      AND process_phase = WIP_CONSTANTS.ML_VALIDATION
      AND process_status in (WIP_CONSTANTS.RUNNING,WIP_CONSTANTS.WARNING)
      AND wip_entity_id = p_wip_entity_id
      AND organization_id = p_organization_id
      AND load_type = WIP_JOB_DETAILS.WIP_RES_INSTANCE
      AND substitution_type = WIP_JOB_DETAILS.WIP_ADD;

BEGIN

  begin

    /* delete all existing instances on a resource before add */
    Delete_Resource_Instance(p_group_id, p_wip_entity_id, p_organization_id,
                        WIP_JOB_DETAILS.WIP_ADD, p_err_code, p_err_msg);

    FOR cur_row IN res_info(p_group_id,
                           p_wip_entity_id,
                           p_organization_id) LOOP

        /* insert into table */
            INSERT INTO WIP_OP_RESOURCE_INSTANCES (
                    WIP_ENTITY_ID,
                    OPERATION_SEQ_NUM,
                    RESOURCE_SEQ_NUM,
                    ORGANIZATION_ID,
                    LAST_UPDATE_DATE,
                    LAST_UPDATED_BY,
                    CREATION_DATE,
                    CREATED_BY,
                    INSTANCE_ID,
                    SERIAL_NUMBER,
                    START_DATE,
                    COMPLETION_DATE,
                    BATCH_ID
                    )
                  VALUES (
                    p_wip_entity_id,
                    cur_row.operation_seq_num,
                    cur_row.resource_seq_num,
                    p_organization_id,
                    sysdate,/*BUG 6721823*/
                    cur_row.last_updated_by,
                    cur_row.creation_date,
                    cur_row.created_by,
                    cur_row.resource_instance_id,
                    cur_row.resource_serial_number,
                    cur_row.start_date,
                    cur_row.completion_date,
                    cur_row.batch_id
                    );
      end loop;

    exception
       when others then
             p_err_msg := 'WIPJDSTB, Add_Resource_Instance: ' || SQLERRM;
             p_err_code := SQLCODE;
    end;

END Add_Resource_Instance;

Procedure Change_Resource_Instance(p_group_id           number,
                           p_wip_entity_id      number,
                           p_organization_id    number,
                           p_err_code   out NOCOPY     varchar2,
                           p_err_msg    out NOCOPY     varchar2) IS

   CURSOR res_info (p_group_id          number,
                   p_wip_entity_id      number,
                   p_organization_id    number) IS
   SELECT distinct operation_seq_num, resource_seq_num, resource_serial_number,
          resource_instance_id, start_date, completion_date, batch_id,
          created_by, creation_date,last_updated_by,last_update_date
     FROM WIP_JOB_DTLS_INTERFACE
    WHERE group_id = p_group_id
      AND process_phase = WIP_CONSTANTS.ML_VALIDATION
      AND process_status in (WIP_CONSTANTS.RUNNING,WIP_CONSTANTS.WARNING)
      AND wip_entity_id = p_wip_entity_id
      AND organization_id = p_organization_id
      AND load_type = WIP_JOB_DETAILS.WIP_RES_INSTANCE
      AND substitution_type = WIP_JOB_DETAILS.WIP_CHANGE;

  l_ret_exp_status boolean := true; --Bug#4675116

BEGIN

    begin

      FOR  cur_row IN res_info(p_group_id,
                           p_wip_entity_id,
                           p_organization_id) LOOP

          --Bug#4675116
          L_RET_EXP_STATUS := WIP_WS_EXCEPTIONS.close_exp_res_instance_update
          (
             P_WIP_ENTITY_ID        => P_WIP_ENTITY_ID,
             P_OPERATION_SEQ_NUM    => CUR_ROW.OPERATION_SEQ_NUM,
             P_RESOURCE_SEQ_NUM     => CUR_ROW.RESOURCE_SEQ_NUM,
             P_INSTANCE_ID          => CUR_ROW.RESOURCE_INSTANCE_ID,
             P_SERIAL_NUMBER        => CUR_ROW.RESOURCE_SERIAL_NUMBER,
             P_ORGANIZATION_ID      => P_ORGANIZATION_ID
          );

          UPDATE WIP_OP_RESOURCE_INSTANCES
          SET     serial_number       =   nvl(cur_row.resource_serial_number,serial_number),
                  last_update_date    =   sysdate,/*BUG 6721823*/
                  last_updated_by     =   nvl(cur_row.last_updated_by,last_updated_by),
                  creation_date       =   nvl(cur_row.creation_date,creation_date),
                  created_by          =   nvl(cur_row.created_by,created_by),
                  start_date          =   nvl(cur_row.start_date,start_date),
                  completion_date     =   nvl(cur_row.completion_date,completion_date),
                  batch_id            =   nvl(cur_row.batch_id,batch_id)
          WHERE   wip_entity_id       =   p_wip_entity_id
            AND   organization_id     =   p_organization_id
            AND   operation_seq_num   =   cur_row.operation_seq_num
            AND   resource_seq_num    =   cur_row.resource_seq_num
            AND   instance_id         =   cur_row.resource_instance_id;

          Delete_Resource_Usage(p_wip_entity_id,
                               p_organization_id,
                               cur_row.operation_seq_num,
                               cur_row.resource_seq_num,
                               p_err_code,
                               p_err_msg);


      end LOOP;


    exception
       when others then
             p_err_msg := 'WIPJDSTB, Change_Resource_Instance: ' || SQLERRM;
             p_err_code := SQLCODE;
    end;
End Change_Resource_Instance;

Procedure Delete_Resource_Instance (p_group_id               in number,
                           p_wip_entity_id      in number,
                           p_organization_id    in number,
                           p_substitution_type    in number,
                           p_err_code           out NOCOPY     varchar2,
                           p_err_msg            out NOCOPY     varchar2) IS
   CURSOR res_info (p_group_id          number,
                   p_wip_entity_id      number,
                   p_organization_id    number) IS
   SELECT distinct operation_seq_num, resource_seq_num, resource_serial_number,
          resource_instance_id, start_date, completion_date, batch_id
     FROM WIP_JOB_DTLS_INTERFACE
    WHERE group_id = p_group_id
      AND process_phase = WIP_CONSTANTS.ML_VALIDATION
      AND process_status in (WIP_CONSTANTS.RUNNING,WIP_CONSTANTS.WARNING)
      AND wip_entity_id = p_wip_entity_id
      AND organization_id = p_organization_id
      AND load_type = WIP_JOB_DETAILS.WIP_RES_INSTANCE
      AND substitution_type = p_substitution_type;

  l_ret_exp_status boolean := true; --Bug#4675116

begin

  begin
    FOR cur_row IN res_info(p_group_id,
                           p_wip_entity_id,
                           p_organization_id) LOOP

         Delete_Resource_Usage(p_wip_entity_id,
                               p_organization_id,
                               cur_row.operation_seq_num,
                               cur_row.resource_seq_num,
                               p_err_code,
                               p_err_msg);

        --BUG#4675116
        L_RET_EXP_STATUS := WIP_WS_EXCEPTIONS.CLOSE_EXCEPTION_RES_INSTANCE
        (
           P_WIP_ENTITY_ID        => P_WIP_ENTITY_ID,
           P_OPERATION_SEQ_NUM    => CUR_ROW.OPERATION_SEQ_NUM,
           P_RESOURCE_SEQ_NUM     => CUR_ROW.RESOURCE_SEQ_NUM,
           P_INSTANCE_ID          => CUR_ROW.RESOURCE_INSTANCE_ID,
           P_SERIAL_NUMBER        => CUR_ROW.RESOURCE_SERIAL_NUMBER,
           P_ORGANIZATION_ID      => P_ORGANIZATION_ID
        );

        DELETE FROM WIP_OP_RESOURCE_INSTANCES
        WHERE  wip_entity_id = p_wip_entity_id
          AND  organization_id = p_organization_id
          AND  operation_seq_num = cur_row.operation_seq_num
          AND  resource_seq_num =  cur_row.resource_seq_num
          AND  instance_id = cur_row.resource_instance_id;

    END LOOP;

  exception
    when others then
             p_err_msg := 'WIPJDSTB, Delete_Resource_Instance: ' || SQLERRM;
             p_err_code := SQLCODE;
  end;

END Delete_Resource_Instance;


Procedure Delete_Requirement (p_group_id        number,
                        p_wip_entity_id         number,
                        p_organization_id       number,
                        p_err_code      out NOCOPY     varchar2,
                        p_err_msg       out NOCOPY     varchar2) IS


   CURSOR req_info(p_group_Id           number,
                   p_wip_entity_id      number,
                   p_organization_id    number) IS
   SELECT distinct operation_seq_num,
          inventory_item_id_old, inventory_item_id_new,
          quantity_per_assembly,
          last_update_date, last_updated_by, creation_date, created_by,
          last_update_login, request_id, program_application_id,
          program_id, program_update_date,
          department_id, wip_supply_type, date_required,
          required_quantity, quantity_issued, supply_subinventory,
          supply_locator_id, mrp_net_flag, mps_required_quantity,
          mps_date_required, attribute_category, attribute1,
          attribute2,attribute3,attribute4,attribute5,attribute6,attribute7,
          attribute8,attribute9,attribute10,attribute11,attribute12,
          attribute13,attribute14,attribute15
     FROM WIP_JOB_DTLS_INTERFACE
    WHERE group_id = p_group_id
      AND process_phase = WIP_CONSTANTS.ML_VALIDATION
      AND process_status in (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING)
      AND wip_entity_id = p_wip_entity_id
      AND organization_id = p_organization_id
      AND load_type = WIP_JOB_DETAILS.WIP_MTL_REQUIREMENT
      AND substitution_type = WIP_JOB_DETAILS.WIP_DELETE;

    x_return_status  VARCHAR(1);
    x_msg_data       VARCHAR(2000);
    l_dummy          VARCHAR(1);
BEGIN
    x_return_status := fnd_api.g_ret_sts_success;

    begin
    FOR cur_row IN req_info(p_group_id,
                           p_wip_entity_id,
                           p_organization_id) LOOP

         DELETE FROM WIP_REQUIREMENT_OPERATIONS
          WHERE  wip_entity_id = p_wip_entity_id
            AND  organization_id = p_organization_id
            AND  operation_seq_num = cur_row.operation_seq_num
            AND  inventory_item_id = cur_row.inventory_item_id_old;

         wip_picking_pvt.cancel_comp_allocations(p_wip_entity_id => p_wip_entity_id,
                     p_operation_seq_num => cur_row.operation_seq_num,
                     p_inventory_item_id => cur_row.inventory_item_id_old,
                     p_wip_entity_type => wip_constants.discrete,
                     x_return_status  => x_return_status,
                     x_msg_data => x_msg_data);

         if (x_return_status <> fnd_api.g_ret_sts_success) then
           raise FND_API.G_EXC_UNEXPECTED_ERROR;
         end if;

    END LOOP;
    exception
       when others then
             p_err_msg := 'WIPJDSTB, Delete_Requirement: ' || SQLERRM;
             p_err_code := SQLCODE;
             wip_jsi_utils.record_error_text(p_err_msg, TRUE);
    end;

END Delete_Requirement;


Procedure Add_Requirement (p_group_id           number,
                        p_wip_entity_id         number,
                        p_organization_id       number,
                        p_err_code      out NOCOPY     varchar2,
                        p_err_msg       out NOCOPY     varchar2) IS


   CURSOR req_info(p_group_Id           number,
                   p_wip_entity_id      number,
                   p_organization_id    number) IS
   SELECT distinct operation_seq_num,
          inventory_item_id_old, inventory_item_id_new,
          quantity_per_assembly,component_yield_factor, /*Component Yield Enhancement(Bug 4369064)*/
          last_update_date, last_updated_by, creation_date, created_by,
          last_update_login, request_id, program_application_id,
          program_id, program_update_date,
          department_id, wip_supply_type, date_required,
          required_quantity, quantity_issued,
          basis_type,    /* LBM Project */
          supply_subinventory,
          supply_locator_id, mrp_net_flag, mps_required_quantity,
          mps_date_required, auto_request_material, comments,
          attribute_category, attribute1,
          attribute2,attribute3,attribute4,attribute5,attribute6,attribute7,
          attribute8,attribute9,attribute10,attribute11,attribute12,
          attribute13,attribute14,attribute15
     FROM WIP_JOB_DTLS_INTERFACE
    WHERE group_id = p_group_id
      AND process_phase = WIP_CONSTANTS.ML_VALIDATION
      AND process_status in (WIP_CONSTANTS.RUNNING,WIP_CONSTANTS.WARNING)
      AND wip_entity_id = p_wip_entity_id
      AND organization_id = p_organization_id
      AND load_type = WIP_JOB_DETAILS.WIP_MTL_REQUIREMENT
      AND substitution_type = WIP_JOB_DETAILS.WIP_ADD;

    l_material_issue_by_mo VARCHAR2(1);
BEGIN

    begin
    FOR cur_row IN req_info(p_group_id,
                           p_wip_entity_id,
                           p_organization_id) LOOP

        /** Fix for bug 2649338
         -- stripped off time part from date_required and mps_date_required **/
        INSERT INTO WIP_REQUIREMENT_OPERATIONS(
                wip_entity_id,
                organization_id,
                operation_seq_num,
                inventory_item_id,
                quantity_per_assembly,
                component_yield_factor, /*Component Yield Enhancement(Bug 4369064)*/
                last_update_date,
                last_updated_by,
                creation_date,
                created_by,
                last_update_login,
                request_id,
                program_application_id,
                program_id,
                program_update_date,
                department_id,
                wip_supply_type,
                date_required,
                required_quantity,
                quantity_issued,
                basis_type,                 /* LBM Project */
                supply_subinventory ,
                supply_locator_id,
                mrp_net_flag,
                mps_required_quantity,
                mps_date_required,
                auto_request_material,
                comments,
                attribute_category,
                attribute1,
                attribute2,
                attribute3,
                attribute4,
                attribute5,
                attribute6,
                attribute7,
                attribute8,
                attribute9,
                attribute10,
                attribute11,
                attribute12,
                attribute13,
                attribute14,
                attribute15)
        VALUES (
                p_wip_entity_id,
                p_organization_id,
                cur_row.operation_seq_num,
                cur_row.inventory_item_id_new,
                round(cur_row.quantity_per_assembly, 6),
                cur_row.component_yield_factor, /*Component Yield Enhancement(Bug 4369064)*/
                sysdate,/*BUG 6721823*/
                cur_row.last_updated_by,
                cur_row.creation_date,
                cur_row.created_by,
                cur_row.last_update_login,
                cur_row.request_id,
                cur_row.program_application_id,
                cur_row.program_id,
                cur_row.program_update_date,
                cur_row.department_id,
                cur_row.wip_supply_type,
                cur_row.date_required,
                cur_row.required_quantity,
                cur_row.quantity_issued,
                cur_row.basis_type,                 /* LBM Project */
                cur_row.supply_subinventory ,
                cur_row.supply_locator_id,
                cur_row.mrp_net_flag,
                cur_row.mps_required_quantity,
                cur_row.mps_date_required,
                cur_row.auto_request_material,
                cur_row.comments,
                cur_row.attribute_category,
                cur_row.attribute1,
                cur_row.attribute2,
                cur_row.attribute3,
                cur_row.attribute4,
                cur_row.attribute5,
                cur_row.attribute6,
                cur_row.attribute7,
                cur_row.attribute8,
                cur_row.attribute9,
                cur_row.attribute10,
                cur_row.attribute11,
                cur_row.attribute12,
                cur_row.attribute13,
                cur_row.attribute14,
                cur_row.attribute15);

    END LOOP;
    exception
       when others then
             p_err_msg := 'WIPJDSTB, Add_Requirement: ' || SQLERRM;
             p_err_code := SQLCODE;
             wip_jsi_utils.record_error_text(p_err_msg, TRUE);
    end;

END Add_Requirement;


Procedure Change_Requirement (p_group_id        number,
                        p_wip_entity_id         number,
                        p_organization_id       number,
                        p_err_code      out NOCOPY     varchar2,
                        p_err_msg       out NOCOPY     varchar2) IS

   CURSOR req_info(p_group_Id           number,
                   p_wip_entity_id      number,
                   p_organization_id    number) IS
   SELECT distinct operation_seq_num,
          inventory_item_id_old, inventory_item_id_new,
          quantity_per_assembly,component_yield_factor, /*Component Yield Enhancement(Bug 4369064)*/
          last_update_date, last_updated_by, creation_date, created_by,
          last_update_login, request_id, program_application_id,
          program_id, program_update_date,
          department_id, wip_supply_type, date_required,
          required_quantity, quantity_issued,
          basis_type,                                    /* LBM Project */
          supply_subinventory,
          supply_locator_id, mrp_net_flag, mps_required_quantity,
          mps_date_required, auto_request_material, comments,
          attribute_category, attribute1,
          attribute2,attribute3,attribute4,attribute5,attribute6,attribute7,
          attribute8,attribute9,attribute10,attribute11,attribute12,
          attribute13,attribute14,attribute15
     FROM WIP_JOB_DTLS_INTERFACE
    WHERE group_id = p_group_id
      AND process_phase = WIP_CONSTANTS.ML_VALIDATION
      AND process_status in (WIP_CONSTANTS.RUNNING,WIP_CONSTANTS.WARNING)
      AND wip_entity_id = p_wip_entity_id
      AND organization_id = p_organization_id
      AND load_type = WIP_JOB_DETAILS.WIP_MTL_REQUIREMENT
      AND substitution_type = WIP_JOB_DETAILS.WIP_CHANGE;

    l_material_issue_by_mo VARCHAR2(1);
    x_return_status        VARCHAR2(1);
    x_msg_data             VARCHAR2(2000);
    l_required_quantity    NUMBER;
    l_wip_supply_type      NUMBER;
    l_supply_subinventory  VARCHAR(30);
    l_supply_locator_id    NUMBER;
    l_dummy                VARCHAR2(1);

    l_ret_exp_status boolean := true; --Bug#4675116

BEGIN

    begin
    FOR cur_row IN req_info(p_group_id,
                           p_wip_entity_id,
                           p_organization_id) LOOP

        SELECT required_quantity, wip_supply_type, supply_subinventory, supply_locator_id
          into l_required_quantity, l_wip_supply_type, l_supply_subinventory, l_supply_locator_id
        FROM wip_requirement_operations
        WHERE  wip_entity_id            = p_wip_entity_id
          AND  organization_id          = p_organization_id
          AND  operation_seq_num        = cur_row.operation_seq_num
          AND  inventory_item_id        = cur_row.inventory_item_id_old;

        If (l_required_quantity <> cur_row.required_quantity AND
            (cur_row.inventory_item_id_new is NULL or
             cur_row.inventory_item_id_old  = cur_row.inventory_item_id_new) and
            WIP_PICKING_PUB.Is_Component_Pick_Released(p_wip_entity_id => p_wip_entity_id,
                     p_org_id => p_organization_id,
                     p_operation_seq_num => cur_row.operation_seq_num,
                     p_inventory_item_id => cur_row.inventory_item_id_old)) then

           FND_MESSAGE.set_name('WIP', 'WIP_QTY_REQ_CHANGE_WARNING');
           wip_jsi_utils.record_current_error(TRUE) ;

           wip_picking_pub.Update_Component_BackOrdQty(p_wip_entity_id => p_wip_entity_id,
                 p_operation_seq_num => cur_row.operation_seq_num,
                 p_new_component_qty => cur_row.required_quantity,
                 p_inventory_item_id => cur_row.inventory_item_id_old,
                 x_return_status => x_return_status,
                 x_msg_data => x_msg_data);
           if (x_return_status <> fnd_api.g_ret_sts_success) then
             raise FND_API.G_EXC_UNEXPECTED_ERROR;
           end if;

        elsif ( (l_wip_supply_type  <> cur_row.wip_supply_type or
                 l_supply_subinventory <> cur_row.supply_subinventory or
                 l_supply_locator_id <> cur_row.supply_locator_id ) and
               (cur_row.inventory_item_id_new is NULL or
                 cur_row.inventory_item_id_old  = cur_row.inventory_item_id_new) and
               WIP_PICKING_PUB.Is_Component_Pick_Released(p_wip_entity_id => p_wip_entity_id,
                 p_org_id => p_organization_id,
                 p_operation_seq_num => cur_row.operation_seq_num,
                 p_inventory_item_id => cur_row.inventory_item_id_old)) then

            WIP_PICKING_PUB.cancel_comp_allocations(p_wip_entity_id => p_wip_entity_id,
                     p_operation_seq_num => cur_row.operation_seq_num,
                     p_inventory_item_id => cur_row.inventory_item_id_old,
                     p_wip_entity_type =>  WIP_CONSTANTS.DISCRETE,
                     x_return_status => x_return_status,
                     x_msg_data => x_msg_data);

            FND_MESSAGE.set_name('WIP', 'WIP_SUPPLY_CHANGE_WARNING2');
            wip_jsi_utils.record_current_error(TRUE);
        end if;

        --Bug#4675116
        IF (CUR_ROW.INVENTORY_ITEM_ID_OLD <> CUR_ROW.INVENTORY_ITEM_ID_NEW) THEN
          L_RET_EXP_STATUS := WIP_WS_EXCEPTIONS.CLOSE_EXCEPTION_COMPONENT
          (
             P_WIP_ENTITY_ID        => P_WIP_ENTITY_ID,
             P_OPERATION_SEQ_NUM    => CUR_ROW.OPERATION_SEQ_NUM,
             P_COMPONENT_ITEM_ID    => CUR_ROW.INVENTORY_ITEM_ID_OLD,
             P_ORGANIZATION_ID      => P_ORGANIZATION_ID
          );
        END IF;


        /* update table */
        /** Fix for bug 2438722 - correct attribute cols updated **/
        /** Fix for bug 2649338
         -- stripped off time part from date_required and mps_date_required **/
        UPDATE WIP_REQUIREMENT_OPERATIONS
        SET    inventory_item_id     = NVL(cur_row.inventory_item_id_new,
                                           inventory_item_id),
               quantity_per_assembly = NVL(round(
                                        cur_row.quantity_per_assembly,6),
                                        quantity_per_assembly),
               component_yield_factor   = NVL(cur_row.component_yield_factor,
                                          component_yield_factor),/*Component Yield Enhancement(Bug 4369064)*/

               /* LBM Project: if user wants to change the basis_type to null (item basis), he needs to insert fnd_api.g_miss_num into interface table. This should be in the interface user guide */
               /* Bug 5468646 - update component basis */
               basis_type               = decode(cur_row.basis_type, fnd_api.g_miss_num, null, null, basis_type, cur_row.basis_type),
               last_update_date         = sysdate,/*BUG 6721823*/
               last_updated_by          = cur_row.last_updated_by,
               creation_date            = cur_row.creation_date,
               created_by               = cur_row.created_by,
               last_update_login        = NVL(cur_row.last_update_login,
                                              last_update_login),
               request_id               = NVL(cur_row.request_id,
                                              request_id),
               program_application_id   = NVL(cur_row.program_application_id,
                                              program_application_id),
               program_id               = NVL(cur_row.program_id,
                                              program_id),
               program_update_date      = NVL(cur_row.program_update_date,
                                              program_update_date),
               department_id            = NVL(cur_row.department_id,
                                              department_id),
               wip_supply_type          = NVL(cur_row.wip_supply_type,
                                              wip_supply_type),
               date_required            = NVL(cur_row.date_required,
                                              date_required),
               required_quantity        = NVL(cur_row.required_quantity,
                                              required_quantity),
               /* Bug 4887280 - modify decode statement for supply_subinventory, and supply_locator */
               /*Fix for Bug 6860572(FP 6795337): For push components, if null is passed, retain the original subinventory values.
                 Null them if fnd_api.g_miss_char and g_miss_num are passed
                 For Pull components do not allow the inventory to be nulled.*/
               supply_subinventory      = Decode(NVL(cur_row.wip_supply_type, wip_supply_type),
                                                2, Decode(cur_row.supply_subinventory,
                                                NULL,
                                                 supply_subinventory,
                                                fnd_api.g_miss_char,
                                                supply_subinventory,
                                                cur_row.supply_subinventory),
                                                3, Decode(cur_row.supply_subinventory,
                                                NULL,
                                                supply_subinventory,
                                                fnd_api.g_miss_char,
                                                supply_subinventory,
                                                cur_row.supply_subinventory),
                                                Decode(cur_row.supply_subinventory,
                                                NULL,
                                                supply_subinventory,
                                                fnd_api.g_miss_char,
                                                NULL,
                                                cur_row.supply_subinventory)),

               supply_locator_id        = Decode(cur_row.supply_subinventory,
                                                NULL,
                                                supply_locator_id,
                                                fnd_api.g_miss_char,
                                                Decode(NVL(cur_row.wip_supply_type, wip_supply_type),
                                                                2, supply_locator_id,
                                                                3, supply_locator_id,
                                                                NULL),
                                                Decode(cur_row.supply_locator_id,
                                                       fnd_api.g_miss_num,
                                                       NULL,
                                                       cur_row.supply_locator_id)),

               mrp_net_flag             = NVL(cur_row.mrp_net_flag,
                                              mrp_net_flag),
               mps_required_quantity    = NVL(cur_row.mps_required_quantity,
                                              mps_required_quantity),
               mps_date_required        = NVL(cur_row.mps_date_required,
                                              mps_date_required),
               auto_request_material    = NVL( cur_row.auto_request_material,
                                               auto_request_material),
               comments                 = NVL( cur_row.comments, comments),
               attribute_category      =  NVL(cur_row.attribute_category,
                                            attribute_category),
                attribute1              =  NVL(cur_row.attribute1,attribute1),
                attribute2              =  NVL(cur_row.attribute2,attribute2),
                attribute3              =  NVL(cur_row.attribute3,attribute3),
                attribute4              =  NVL(cur_row.attribute4,attribute4),
                attribute5              =  NVL(cur_row.attribute5,attribute5),
                attribute6              =  NVL(cur_row.attribute6,attribute6),
                attribute7              =  NVL(cur_row.attribute7,attribute7),
                attribute8              =  NVL(cur_row.attribute8,attribute8),
                attribute9              =  NVL(cur_row.attribute9,attribute9),
               attribute10              =  NVL(cur_row.attribute10,attribute10),
               attribute11              =  NVL(cur_row.attribute11,attribute11),
               attribute12              =  NVL(cur_row.attribute12,attribute12),
               attribute13              =  NVL(cur_row.attribute13,attribute13),
               attribute14              =  NVL(cur_row.attribute14,attribute14),
               attribute15              =  NVL(cur_row.attribute15,attribute15)
        WHERE  wip_entity_id            = p_wip_entity_id
          AND  organization_id          = p_organization_id
          AND  operation_seq_num        = cur_row.operation_seq_num
          AND  inventory_item_id        = cur_row.inventory_item_id_old;

    END LOOP;
    exception
       when others then
             p_err_msg := 'ERROR IN WIPJDSTB.PLS: CHANGE_REQ ' || SQLERRM;
             p_err_code := SQLCODE;
             wip_jsi_utils.record_error_text(p_err_msg, TRUE);
    end;

END Change_Requirement;

Procedure Add_Operation (p_group_id             in  number,
                         p_wip_entity_id        in  number,
                         p_organization_id      in  number,
                         x_err_code             out NOCOPY varchar2,
                         x_err_msg              out NOCOPY varchar2 ,
                         x_return_status        out NOCOPY varchar2) IS

    CURSOR oper_info ( p_group_id number,
                       p_wip_entity_id  number,
                       p_organization_id number) IS
    SELECT distinct parent_header_id, operation_seq_num, standard_operation_id,
           department_id, description , first_unit_start_date,
           first_unit_completion_date, last_unit_start_date,
           last_unit_completion_date, minimum_transfer_quantity,
           count_point_type, backflush_flag,last_update_date,
           last_updated_by, creation_date,created_by, last_update_login,
           request_id, program_application_id, program_id, program_update_date,
           long_description,
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
      AND substitution_type = WIP_JOB_DETAILS.WIP_ADD;

    CURSOR operations(p_wip_entity_id number,
                      p_organization_id number) IS
    SELECT operation_seq_num
    FROM wip_operations
    WHERE wip_entity_id = p_wip_entity_id
      AND organization_id = p_organization_id
    ORDER BY operation_seq_num ;

   l_scheduled_quantity number := 0;
   l_quantity_in_queue number := 0;
   l_first_operation number := 0;
   l_qty_in_queue_old number := 0;
   previous_operation number := 0;
   next_operation     number := 0;
   l_open_quantity number;
   l_scrap_qty     number := 0;
   l_status_type number;  /*Bug 3484856*/
   l_load_type number;    /*Bug 3484856*/
   l_scheduled_start_date date;/* Bug 3659006*/
   l_scheduled_completion_date date;/* Bug 3659006*/
   l_first_unit_start_date date;     /* Bug 6132987 (FP of 5886171) */
   l_last_unit_completion_date date; /* Bug 6132987 (FP of 5886171) */

BEGIN
 begin

   IF p_group_id IS NULL OR p_organization_id IS NULL OR
      p_wip_entity_id IS NULL THEN

     x_err_code := SQLCODE;
     x_err_msg := 'Error in wipjdstb.pls'|| SQLERRM;
     x_return_status := FND_API.G_RET_STS_ERROR;
     return;
   END IF;

   FOR cur_oper IN oper_info(p_group_id,p_wip_entity_id,p_organization_id) LOOP

     -- Bug 3484856 - select the status of job and load type from wjsi
     SELECT wdj.start_quantity, greatest(wdj.start_quantity - wdj.quantity_completed - wdj.quantity_scrapped, 0), wdj.status_type, we.load_type
       INTO l_scheduled_quantity, l_open_quantity,l_status_type, l_load_type
       FROM wip_discrete_jobs wdj,wip_job_schedule_interface we
      WHERE wdj.wip_entity_id = p_wip_entity_id
        AND wdj.organization_id = p_organization_id
        AND wdj.wip_entity_id =  we.wip_entity_id (+)
        AND wdj.organization_id =  we.organization_id (+)
        AND we.group_id = p_group_id
        AND we.process_phase = WIP_CONSTANTS.ML_VALIDATION
        AND we.process_status in ( WIP_CONSTANTS.RUNNING,  WIP_CONSTANTS.WARNING )
        AND we.header_id = cur_oper.parent_header_id;

     begin
       SELECT min(operation_seq_num)
         INTO l_first_operation
         FROM WIP_OPERATIONS
         WHERE wip_entity_id = p_wip_entity_id
         AND organization_id = p_organization_id;
     exception
        when no_data_found then
           null;
     end;

     -- Bug 3484856 - If job is 'Unreleased' or creating a work-order,
     -- then quantity_in_queue should be 0 else create the operation with
     -- open qty in queue
     IF l_first_operation is null then
       if l_status_type = WIP_CONSTANTS.UNRELEASED or
         ( l_load_type is NOT NULL and
           l_load_type in ( WIP_CONSTANTS.CREATE_JOB,
                            WIP_CONSTANTS.CREATE_NS_JOB,
                            WIP_CONSTANTS.CREATE_EAM_JOB ) ) then
         l_quantity_in_queue := 0;
       else
         l_quantity_in_queue := l_open_quantity;
       end if;

        /* Fix for bug 4273638: Since the operation being added is the
           first operation,move the components currently under op-seq 1
           to the operation being added */
          WIP_OPERATIONS_UTILITIES.Update_Operationless_Reqs
                                 (p_wip_entity_id,
                                  p_organization_id,
                                  cur_oper.operation_seq_num,
                                  NULL, /* repetitive schedule id */
                                  cur_oper.department_id,
                                  cur_oper.first_unit_start_date);


     ELSIF l_first_operation > cur_oper.operation_seq_num THEN

          select quantity_in_queue into l_quantity_in_queue
          from wip_operations
          where wip_entity_id = p_wip_entity_id
            and organization_id = p_organization_id
            and operation_seq_num = l_first_operation;

          -- need to erase the quantity from the current 1st op or
          -- else we are creating duplicate qty
          update wip_operations
          set quantity_in_queue = 0,
	      LAST_UPDATE_DATE=sysdate/*BUG 6721823*/
          where wip_entity_id = p_wip_entity_id
            and organization_id = p_organization_id
            and operation_seq_num = l_first_operation;

      ELSE
          l_quantity_in_queue := 0;

      END IF;

     IF cur_oper.standard_operation_id is not null THEN
        wip_operations_pkg.add(p_organization_id,
                               p_wip_entity_id,
                               cur_oper.operation_seq_num,
                               cur_oper.standard_operation_id,
                               cur_oper.department_id);
        UPDATE WIP_OPERATIONS
        SET  last_update_date = sysdate,/*BUG 6721823*/
             last_updated_by = NVL(cur_oper.last_updated_by,last_updated_by),
             creation_date = NVL(cur_oper.creation_date,creation_date),
             created_by = NVL(cur_oper.created_by, created_by),
             last_update_login = NVL(cur_oper.last_update_login,last_update_login),
             request_id = NVL(cur_oper.request_id ,request_id),
             program_application_id =NVL(cur_oper.program_application_id,program_application_id),
             program_id = NVL(cur_oper.program_id,program_id),
             program_update_date = NVL(cur_oper.program_update_date,
                                       program_update_date),
             description = NVL(cur_oper.description,description),
             first_unit_start_date = NVL(cur_oper.first_unit_start_date,
                                     first_unit_start_date),
             first_unit_completion_date =NVL(cur_oper.first_unit_completion_date,
                                             first_unit_completion_date),
             last_unit_start_date = NVL(cur_oper.last_unit_start_date,
                                        last_unit_start_date),
             last_unit_completion_date = NVL(cur_oper.last_unit_completion_date,
                                             last_unit_completion_date),
             count_point_type = NVL(cur_oper.count_point_type,count_point_type),
             backflush_flag  = NVL(cur_oper.backflush_flag,backflush_flag),
             minimum_transfer_quantity = NVL(cur_oper.minimum_transfer_quantity,
                                             minimum_transfer_quantity),
             long_description = NVL(cur_oper.long_description,
                                            long_description),
             attribute_category = NVL(cur_oper.attribute_category,
                                  attribute_category),
             attribute1 = NVL(cur_oper.attribute1,attribute1),
             attribute2 = NVL(cur_oper.attribute2,attribute2),
             attribute3 = NVL(cur_oper.attribute3,attribute3),
             attribute4 = NVL(cur_oper.attribute4,attribute4),
             attribute5 = NVL(cur_oper.attribute5,attribute5),
             attribute6 = NVL(cur_oper.attribute6,attribute6),
             attribute7 = NVL(cur_oper.attribute7,attribute7),
             attribute8 = NVL(cur_oper.attribute8,attribute8),
             attribute9 = NVL(cur_oper.attribute9,attribute9),
             attribute10 = NVL(cur_oper.attribute10,attribute10),
             attribute11 = NVL(cur_oper.attribute11,attribute11),
             attribute12 = NVL(cur_oper.attribute12,attribute12),
             attribute13 = NVL(cur_oper.attribute13,attribute13),
             attribute14 = NVL(cur_oper.attribute14,attribute14),
             attribute15 = NVL(cur_oper.attribute15,attribute15),
             quantity_in_queue = l_quantity_in_queue
        where wip_entity_id = p_wip_entity_id
        and   organization_id = p_organization_id
        and  operation_seq_num = cur_oper.operation_seq_num
        /* Bug 6132987 (FP of 5886171) */
        RETURNING first_unit_start_date, last_unit_completion_date
        INTO l_first_unit_start_date, l_last_unit_completion_date;

	/* Bug 6132987 (FP of 5886171) - The scheduling dates are updated in WO in the statement above but they are
           not updated in WOR.This causes validation to fail in verify_operation, if the resource dates are outside
           the operation date ranges.
	   So compare the WOR dates with the WO dates and update the WOR dates so that the validation does not fail */
	DECLARE
		CURSOR C_WOR IS
		select start_date, completion_date, rowid
		from wip_operation_resources wor
		where wor.wip_entity_id = p_wip_entity_id
		and wor.organization_id = p_organization_id
		and wor.operation_seq_num = cur_oper.operation_seq_num;

		l_wor_start_date DATE := null;
		l_wor_completion_date DATE := null;
	BEGIN
		FOR rec in C_WOR LOOP
			l_wor_start_date := null;
			l_wor_completion_date := null;

			IF (l_first_unit_start_date > rec.start_date) THEN
				l_wor_start_date := l_first_unit_start_date;
			END IF;

			IF (l_last_unit_completion_date < rec.completion_date) THEN
				l_wor_completion_date := l_last_unit_completion_date;
			END IF;

			IF ((l_wor_start_date IS NOT NULL) OR (l_wor_completion_date IS NOT NULL)) THEN
				UPDATE WIP_OPERATION_RESOURCES
				SET	start_date = nvl(l_wor_start_date, start_date),
					completion_date = nvl(l_wor_completion_date, completion_date),
					LAST_UPDATE_DATE=sysdate/*BUG 6721823*/
				WHERE	rowid = rec.rowid;
			END IF;
		END LOOP;
	END;
	/* Bug 6132987 (FP of 5886171) */


      ELSE

        /* For Enhancement#2864382. Calculate cumulative_scrap_quantity for this operation */
        IF cur_oper.operation_seq_num > l_first_operation THEN
                SELECT SUM(quantity_scrapped)
                  INTO l_scrap_qty
                  FROM wip_operations
                 WHERE organization_id   =  p_organization_id
                   AND wip_entity_id     =  p_wip_entity_id
                   AND operation_seq_num <  cur_oper.operation_seq_num;
        END IF;


        INSERT INTO WIP_OPERATIONS
         ( wip_entity_id,
           operation_seq_num,
           organization_id,
           last_update_date,
           last_updated_by,
           creation_date,
           created_by,
           last_update_login,
           request_id,
           program_application_id,
           program_id,
           program_update_date,
           standard_operation_id,
           department_id,
           description,
           scheduled_quantity,
           quantity_in_queue,
           quantity_running,
           quantity_waiting_to_move,
           quantity_rejected,
           quantity_scrapped,
           quantity_completed,
           cumulative_scrap_quantity,     /* for 2864382 */
           first_unit_start_date,
           first_unit_completion_date,
           last_unit_start_date,
           last_unit_completion_date,
           count_point_type,
           backflush_flag,
           minimum_transfer_quantity,
           long_description,
           attribute_category,
           attribute1,
           attribute2,
           attribute3,
           attribute4,
           attribute5,
           attribute6,
           attribute7,
           attribute8,
           attribute9,
           attribute10,
           attribute11,
           attribute12,
           attribute13,
           attribute14,
           attribute15)
      VALUES
       (   p_wip_entity_id,
           cur_oper.operation_seq_num,
           p_organization_id,
           sysdate,/*BUG 6721823*/
           cur_oper.last_updated_by,
           cur_oper.creation_date,
           cur_oper.created_by,
           cur_oper.last_update_login,
           cur_oper.request_id,
           cur_oper.program_application_id,
           cur_oper.program_id,
           cur_oper.program_update_date,
           cur_oper.standard_operation_id,
           cur_oper.department_id,
           cur_oper.description,
           l_scheduled_quantity,
           l_quantity_in_queue,
           0,0,0,0,0,
           l_scrap_qty,
           cur_oper.first_unit_start_date,
           cur_oper.first_unit_completion_date,
           cur_oper.last_unit_start_date,
           cur_oper.last_unit_completion_date,
           cur_oper.count_point_type,
           cur_oper.backflush_flag,
           cur_oper.minimum_transfer_quantity,
           cur_oper.long_description,
           cur_oper.attribute_category,
           cur_oper.attribute1,
           cur_oper.attribute2,
           cur_oper.attribute3,
           cur_oper.attribute4,
           cur_oper.attribute5,
           cur_oper.attribute6,
           cur_oper.attribute7,
           cur_oper.attribute8,
           cur_oper.attribute9,
           cur_oper.attribute10,
           cur_oper.attribute11,
           cur_oper.attribute12,
           cur_oper.attribute13,
           cur_oper.attribute14,
           cur_oper.attribute15);

   END IF;

/* Bug 3659006 ->modify the job start/end to allow adding operation outside the start/end
of job */

      select scheduled_start_date,scheduled_completion_date
      into l_scheduled_start_date,l_scheduled_completion_date
      from wip_discrete_jobs
      where wip_entity_id = p_wip_entity_id
      AND   organization_id = p_organization_id;

      IF  (cur_oper.first_unit_start_date is not null
           AND  cur_oper.first_unit_start_date < l_scheduled_start_date)
      THEN
         UPDATE wip_discrete_jobs
         set scheduled_start_date = cur_oper.first_unit_start_date
         where wip_entity_id = p_wip_entity_id
         AND   organization_id = p_organization_id;
      END IF;
      IF  (cur_oper.last_unit_completion_date is not null
           AND  cur_oper.last_unit_completion_date > l_scheduled_completion_date)
      THEN
         UPDATE wip_discrete_jobs
         set scheduled_completion_date = cur_oper.last_unit_completion_date
         where wip_entity_id = p_wip_entity_id
         AND   organization_id = p_organization_id;
      END IF;
/*END bug 3659006 */

   END LOOP;

   FOR each_oper IN OPERATIONS(p_wip_entity_id,p_organization_id) LOOP

      IF previous_operation = 0 then

         UPDATE WIP_OPERATIONS
            SET PREVIOUS_OPERATION_SEQ_NUM = NULL,
	        LAST_UPDATE_DATE=sysdate/*BUG 6721823*/
          WHERE wip_entity_id     = p_wip_entity_id
            AND organization_id   = p_organization_id
            AND operation_seq_num = each_oper.operation_seq_num;

          previous_operation := each_oper.operation_seq_num;

      ELSE

         UPDATE WIP_OPERATIONS
            SET PREVIOUS_OPERATION_SEQ_NUM = previous_operation,
	        LAST_UPDATE_DATE=sysdate/*BUG 6721823*/
          WHERE wip_entity_id     = p_wip_entity_id
            AND organization_id   = p_organization_id
            AND operation_seq_num = each_oper.operation_seq_num;

         UPDATE WIP_OPERATIONS
            SET NEXT_OPERATION_SEQ_NUM = each_oper.operation_seq_num,
	        LAST_UPDATE_DATE=sysdate/*BUG 6721823*/
          WHERE wip_entity_id     = p_wip_entity_id
            AND organization_id   = p_organization_id
            AND operation_seq_num = previous_operation;

          -- Fix for Bug#2246970

          previous_operation := each_oper.operation_seq_num;

      END IF;
   END LOOP;

   exception
    when others then
     x_return_status := FND_API.G_RET_STS_ERROR;
     x_err_code := SQLCODE;
     x_err_msg := 'ERROR IN WIPJDSTB : '||SQLERRM;
     return;
   end;

 END ADD_OPERATION;

Procedure Change_Operation (p_group_id          in  number,
                            p_wip_entity_id     in  number,
                            p_organization_id   in  number,
                            x_err_code          out NOCOPY varchar2,
                            x_err_msg           out NOCOPY varchar2,
                            x_return_status     out NOCOPY varchar2) IS

    CURSOR oper_info ( p_group_id number,
                       p_wip_entity_id  number,
                       p_organization_id number) IS
    SELECT WJDI.parent_header_id, WJDI.operation_seq_num, WJDI.standard_operation_id,
           WJDI.department_id, WJDI.description ,
            /*Fix for But 8784056 (FP of 8704687). format the date from WJDI without second before update WIP_OPERATIONS, to make it consistant with other files.*/
           TO_DATE(TO_CHAR(WJDI.first_unit_start_date,WIP_CONSTANTS.DT_NOSEC_FMT),WIP_CONSTANTS.DT_NOSEC_FMT) first_unit_start_date,
           TO_DATE(TO_CHAR(WJDI.first_unit_completion_date,WIP_CONSTANTS.DT_NOSEC_FMT),WIP_CONSTANTS.DT_NOSEC_FMT) first_unit_completion_date,
 	         TO_DATE(TO_CHAR(WJDI.last_unit_start_date,WIP_CONSTANTS.DT_NOSEC_FMT),WIP_CONSTANTS.DT_NOSEC_FMT) last_unit_start_date,
 	         TO_DATE(TO_CHAR(WJDI.last_unit_completion_date,WIP_CONSTANTS.DT_NOSEC_FMT),WIP_CONSTANTS.DT_NOSEC_FMT) last_unit_completion_date,
           WJDI.minimum_transfer_quantity,
           WJDI.count_point_type, WJDI.backflush_flag,WJDI.last_update_date,
           WJDI.last_updated_by, WJDI.creation_date,WJDI.created_by, WJDI.last_update_login,
           WJDI.request_id, WJDI.program_application_id, WJDI.program_id, WJDI.program_update_date,
           WJDI.long_description,
           WJDI.attribute_category, WJDI.attribute1, WJDI.attribute2, WJDI.attribute3,
           WJDI.attribute4, WJDI.attribute5,
           WJDI.attribute6, WJDI.attribute7, WJDI.attribute8, WJDI.attribute9, WJDI.attribute10,
           WJDI.attribute11, WJDI.attribute12, WJDI.attribute13, WJDI.attribute14, WJDI.attribute15,
           WO.standard_operation_id curr_standard_operation_id
     FROM WIP_JOB_DTLS_INTERFACE WJDI, WIP_OPERATIONS WO
     WHERE group_id = p_group_id
      AND WJDI.process_phase = WIP_CONSTANTS.ML_VALIDATION
      AND WJDI.process_status IN (WIP_CONSTANTS.RUNNING,WIP_CONSTANTS.WARNING)
      AND WJDI.wip_entity_id = p_wip_entity_id
      AND WJDI.organization_id = p_organization_id
      AND WJDI.load_type = WIP_JOB_DETAILS.WIP_OPERATION
      AND WJDI.substitution_type = WIP_JOB_DETAILS.WIP_CHANGE
      AND WO.wip_entity_id = p_wip_entity_id
      AND WO.organization_id = p_organization_id
      AND WO.operation_seq_num = WJDI.operation_seq_num;

   l_scheduled_start_date date;/* Bug 3659006*/
   l_scheduled_completion_date date;/* Bug 3659006*/
   l_ret_exp_status boolean := true; /* Bug#4675116 */

BEGIN
 begin

   IF p_group_id IS NULL OR p_organization_id IS NULL OR
      p_wip_entity_id IS NULL THEN

     x_err_code := SQLCODE;
     x_err_msg := 'Error in wipjdstb.pls'|| SQLERRM;
     x_return_status := FND_API.G_RET_STS_ERROR;
     return;
   END IF;

   FOR cur_oper IN oper_info(p_group_id,p_wip_entity_id,p_organization_id) LOOP

      /* fix for bug#2653621, disable update of std_op_id and its department, same as form */
      if (cur_oper.curr_standard_operation_id is not null or cur_oper.standard_operation_id is not null ) then
           WIP_JSI_Utils.record_error_text
             ( 'Changing of Std Operation ID, and its associated Department ID in an operation is disallowed',
                           true);
           cur_oper.standard_operation_id := null;
           cur_oper.department_id := null;
      end if;

      --Bug#4675116
      L_RET_EXP_STATUS := WIP_WS_EXCEPTIONS.CLOSE_EXCEPTION_JOBOP
      (
       P_WIP_ENTITY_ID        => P_WIP_ENTITY_ID,
       P_OPERATION_SEQ_NUM    => cur_oper.operation_seq_num,
       P_DEPARTMENT_ID        => cur_oper.department_id,
       P_ORGANIZATION_ID      => P_ORGANIZATION_ID
      );

      UPDATE WIP_OPERATIONS
      SET  last_update_date = sysdate,/*BUG 6721823*/
           last_updated_by = NVL(cur_oper.last_updated_by,last_updated_by),
           creation_date = NVL(cur_oper.creation_date,creation_date),
           created_by = NVL(cur_oper.created_by, created_by),
         last_update_login = NVL(cur_oper.last_update_login,last_update_login),
           request_id = NVL(cur_oper.request_id ,request_id),
           program_application_id =NVL(cur_oper.program_application_id,
                                    program_application_id),
           program_id = NVL(cur_oper.program_id,program_id),
           program_update_date = NVL(cur_oper.program_update_date,
                                     program_update_date),
           standard_operation_id = NVL(cur_oper.standard_operation_id,
                                       standard_operation_id),
           department_id = NVL(cur_oper.department_id,department_id),
           description = NVL(cur_oper.description,description),
           first_unit_start_date = NVL(cur_oper.first_unit_start_date,
                                   first_unit_start_date),
           first_unit_completion_date =NVL(cur_oper.first_unit_completion_date,
                                           first_unit_completion_date),
           last_unit_start_date = NVL(cur_oper.last_unit_start_date,
                                      last_unit_start_date),
           last_unit_completion_date = NVL(cur_oper.last_unit_completion_date,
                                           last_unit_completion_date),
           count_point_type = NVL(cur_oper.count_point_type,count_point_type),
           backflush_flag  = NVL(cur_oper.backflush_flag,backflush_flag),
           minimum_transfer_quantity = NVL(cur_oper.minimum_transfer_quantity,
                                           minimum_transfer_quantity),
           long_description = NVL(cur_oper.long_description,
                                          long_description),
           attribute_category = NVL(cur_oper.attribute_category,
                                attribute_category),
           attribute1 = NVL(cur_oper.attribute1,attribute1),
           attribute2 = NVL(cur_oper.attribute2,attribute2),
           attribute3 = NVL(cur_oper.attribute3,attribute3),
           attribute4 = NVL(cur_oper.attribute4,attribute4),
           attribute5 = NVL(cur_oper.attribute5,attribute5),
           attribute6 = NVL(cur_oper.attribute6,attribute6),
           attribute7 = NVL(cur_oper.attribute7,attribute7),
           attribute8 = NVL(cur_oper.attribute8,attribute8),
           attribute9 = NVL(cur_oper.attribute9,attribute9),
           attribute10 = NVL(cur_oper.attribute10,attribute10),
           attribute11 = NVL(cur_oper.attribute11,attribute11),
           attribute12 = NVL(cur_oper.attribute12,attribute12),
           attribute13 = NVL(cur_oper.attribute13,attribute13),
           attribute14 = NVL(cur_oper.attribute14,attribute14),
           attribute15 = NVL(cur_oper.attribute15,attribute15)
      where wip_entity_id = p_wip_entity_id
      and   organization_id = p_organization_id
      and  operation_seq_num = cur_oper.operation_seq_num;

      /* Bug 5026773 - Update Material Rquirements to reflect the changed operation. */
       WIP_OPERATIONS_UTILITIES.Update_Reqs
                              (p_wip_entity_id,
                               p_organization_id,
                               cur_oper.operation_seq_num,
                               NULL, /* repetitive schedule id */
                               cur_oper.department_id,
                               cur_oper.first_unit_start_date);

/* Bug 3659006 -> modify the job start/end to allow operation FUSD/LUCD modification outsi
de the start/end of job*/
      select scheduled_start_date,scheduled_completion_date
      into l_scheduled_start_date,l_scheduled_completion_date
      from wip_discrete_jobs
      where wip_entity_id = p_wip_entity_id
      AND   organization_id = p_organization_id;

      IF  (cur_oper.first_unit_start_date is not null
           AND  cur_oper.first_unit_start_date < l_scheduled_start_date)
      THEN
         UPDATE wip_discrete_jobs
         set scheduled_start_date = cur_oper.first_unit_start_date
         where wip_entity_id = p_wip_entity_id
         AND   organization_id = p_organization_id;
      END IF;
      IF  (cur_oper.last_unit_completion_date is not null
           AND  cur_oper.last_unit_completion_date > l_scheduled_completion_date)
      THEN
         UPDATE wip_discrete_jobs
         set scheduled_completion_date = cur_oper.last_unit_completion_date
         where wip_entity_id = p_wip_entity_id
         AND   organization_id = p_organization_id;
      END IF;
/*END bug 3659006 */

    -- Start : Fix Bug#5116297/5129311
    -- Update date_required for Components on this Operation
    UPDATE WIP_REQUIREMENT_OPERATIONS WRO
    SET    WRO.DATE_REQUIRED =
                (SELECT FIRST_UNIT_START_DATE
                 FROM   WIP_OPERATIONS
                 WHERE  WIP_ENTITY_ID     = p_wip_entity_id
                 AND    OPERATION_SEQ_NUM = ABS(WRO.OPERATION_SEQ_NUM)
                 AND    ORGANIZATION_ID   = p_organization_id
                ),
            LAST_UPDATED_BY = nvl(cur_oper.last_updated_by, last_updated_by),
            LAST_UPDATE_DATE = SYSDATE,
            LAST_UPDATE_LOGIN = nvl(cur_oper.last_update_login, last_update_login),
            REQUEST_ID = nvl(cur_oper.request_id, request_id),
            PROGRAM_UPDATE_DATE = SYSDATE,
            PROGRAM_ID = nvl(cur_oper.program_id, program_id),
            PROGRAM_APPLICATION_ID = nvl(cur_oper.program_application_id, program_application_id)
    WHERE   WIP_ENTITY_ID     = p_wip_entity_id
    AND     OPERATION_SEQ_NUM = cur_oper.operation_seq_num
    AND     ORGANIZATION_ID   = p_organization_id ;

    -- End : Fix Bug#5116297/5129311


   END LOOP;

  exception
    when others then
     x_return_status := FND_API.G_RET_STS_ERROR;
     x_err_code := SQLCODE;
     x_err_msg := 'ERROR IN WIPJDSTB : '||SQLERRM;
     return;
  end;

 END CHANGE_OPERATION;

Procedure Verify_Operation (p_group_id          in  number,
                            p_wip_entity_id     in  number,
                            p_organization_id   in  number,
                            x_err_code          out NOCOPY varchar2,
                            x_err_msg           out NOCOPY varchar2,
                            x_return_status     out NOCOPY varchar2) IS

  /* Fix for Bug#4398726. Added WIP_JOB_SCHEDULE_INTERFACE in following sql
   * statement to bypass validation for records populated by planning
   * This is done as per Planning request
  */
  cursor c_invalid_rows is
    select wjdi.interface_id
      from wip_job_dtls_interface wjdi
     where wjdi.group_id = p_group_id
       and wjdi.process_phase = wip_constants.ml_validation
       and wjdi.process_status in (wip_constants.running,
                              wip_constants.warning)
       and wjdi.load_type = wip_job_details.wip_operation
       and wjdi.substitution_type in (wip_job_details.wip_add, wip_job_details.wip_change)
       and wjdi.wip_entity_id = p_wip_entity_id
       and wjdi.organization_id = p_organization_id
       and (wjdi.first_unit_start_date is not null or
             wjdi.last_unit_completion_date is not null)
    /* Fix for Bug#6394857(FP of 6370245).
       and wjdi.group_id not in (select wjsi.group_id
                                 from   wip_job_schedule_interface wjsi
                                 where  wjsi.group_id = p_group_id
                                 and    wjsi.source_code = 'MSC'
                                )
    */
       and wjdi.operation_seq_num =
             (select wo.operation_seq_num
                from wip_operations wo
               where wo.wip_entity_id = p_wip_entity_id
                 and wo.organization_id = p_organization_id
                 and wo.operation_seq_num = wjdi.operation_seq_num
                 and (wo.first_unit_start_date >
                    (select min(start_date)
                       from wip_operation_resources wor
                      where wor.wip_entity_id = p_wip_entity_id
                        and wor.organization_id = p_organization_id
                        and wor.operation_seq_num = wo.operation_seq_num)
                    or
                    wo.last_unit_completion_date <
                     (select max(completion_date)
                        from wip_operation_resources wor
                       where wor.wip_entity_id = p_wip_entity_id
                         and wor.organization_id = p_organization_id
                         and wor.operation_seq_num = wo.operation_seq_num)));

  l_error_exists boolean := false;

begin
  for l_inv_row in c_invalid_rows loop
      l_error_exists := true;
      fnd_message.set_name('WIP', 'WIP_INVALID_SCHEDULE_DATE');
      fnd_message.set_token('INTERFACE', to_char(l_inv_row.interface_id));
      if(wip_job_details.std_alone = 1) then
        wip_interface_err_Utils.add_error(p_interface_id => l_inv_row.interface_id,
                                          p_text         => substr(fnd_message.get,1,500),
                                          p_error_type   => wip_jdi_utils.msg_error);
      else
        wip_interface_err_Utils.add_error(p_interface_id => wip_jsi_utils.current_interface_id,
                                          p_text         => substr(fnd_message.get,1,500),
                                          p_error_type   => wip_jdi_utils.msg_error);
      end if;
  end loop;

  if(l_error_exists) then
      update wip_job_dtls_interface wjdi
         set process_status = wip_constants.error
       where wjdi.group_id = p_group_id
         and wjdi.process_phase = wip_constants.ml_validation
         and wjdi.process_status in (wip_constants.running,
                                wip_constants.warning)
         and wjdi.load_type = wip_job_details.wip_operation
         and wjdi.substitution_type in (wip_job_details.wip_add, wip_job_details.wip_change)
         and wjdi.wip_entity_id = p_wip_entity_id
         and wjdi.organization_id = p_organization_id
         and (wjdi.first_unit_start_date is not null or
               wjdi.last_unit_completion_date is not null)
         and wjdi.operation_seq_num =
             (select wo.operation_seq_num
                from wip_operations wo
               where wo.wip_entity_id = p_wip_entity_id
                 and wo.organization_id = p_organization_id
                 and wo.operation_seq_num = wjdi.operation_seq_num
                 and (wo.first_unit_start_date >
                    (select min(start_date)
                       from wip_operation_resources wor
                      where wor.wip_entity_id = p_wip_entity_id
                        and wor.organization_id = p_organization_id
                        and wor.operation_seq_num = wo.operation_seq_num)
                    or
                    wo.last_unit_completion_date <
                     (select max(completion_date)
                        from wip_operation_resources wor
                       where wor.wip_entity_id = p_wip_entity_id
                         and wor.organization_id = p_organization_id
                         and wor.operation_seq_num = wo.operation_seq_num)));

  end if;

  Exception
    when others then
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_err_msg := 'ERROR IN WIPJDSTB.VERIFY_OPERATION: ' || SQLERRM;
      x_err_code := to_char(SQLCODE);
      return;

end;


Procedure Delete_Resource_Usage(p_wip_entity_id number,
                                p_organization_id number,
                                p_operation_seq_num number,
                                p_resource_seq_num number,
                                x_err_code out NOCOPY varchar2,
                                x_err_msg out NOCOPY varchar2) IS

BEGIN

    DELETE FROM WIP_OPERATION_RESOURCE_USAGE
    WHERE wip_entity_id = p_wip_entity_id
    AND  organization_id = p_organization_id
    AND  operation_seq_num = p_operation_seq_num
    AND  resource_seq_num =  p_resource_seq_num;

   exception
    When others then
     x_err_code := SQLCODE;
     x_err_msg := 'Error in wipjdstb: '||SQLERRM;
     return;

END  DELETE_RESOURCE_USAGE;

Procedure Substitution_Res_Usages( p_group_id           in number,
                                   p_wip_entity_id      in number,
                                   p_organization_id    in number,
                                   x_err_code           out NOCOPY varchar2,
                                   x_err_msg            out NOCOPY varchar2,
                                   x_return_status      out NOCOPY varchar2) IS

   Cursor Usage_info (p_group_id number,
                      p_wip_entity_id number,
                      p_organization_id  number) IS
    SELECT operation_seq_num, resource_seq_num
    FROM WIP_JOB_DTLS_INTERFACE
    WHERE group_id = p_group_id
      AND process_phase = WIP_CONSTANTS.ML_VALIDATION
      AND process_status in (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING)
      AND wip_entity_id = p_wip_entity_id
      AND organization_id = p_organization_id
      AND load_type in (WIP_JOB_DETAILS.WIP_RES_USAGE,
                        WIP_JOB_DETAILS.WIP_RES_INSTANCE_USAGE)
      AND substitution_type = WIP_JOB_DETAILS.WIP_ADD;

Begin

    FOR cur_row in Usage_info(p_group_id, p_wip_entity_id,p_organization_id)Loop

         Sub_Usage(p_group_id, p_wip_entity_id, p_organization_id,
                 cur_row.operation_seq_num, cur_row.resource_seq_num,
                 x_err_code, x_err_msg, x_return_status);

    END LOOP;

END SUBSTITUTION_RES_USAGES;


Procedure Sub_Usage (p_group_id                 in number,
                              p_wip_entity_id           in number,
                              p_organization_id         in number,
                              p_operation_seq_num       in number,
                              p_resource_seq_num        in number,
                              x_err_code                out NOCOPY varchar2,
                              x_err_msg                 out NOCOPY varchar2,
                              x_return_status           out NOCOPY varchar2) IS

  Cursor Usage_Update (p_group_id number, p_wip_entity_id number,
                       p_organization_id number, p_operation_seq_num number,
                       p_resource_seq_num number) IS
   SELECT distinct wip_entity_id , organization_id, operation_seq_num,
          resource_seq_num, resource_instance_id, start_date,
          completion_date, assigned_units, resource_serial_number,
          last_update_date, last_updated_by, creation_date, created_by,
          last_update_login, program_application_id, request_id, program_id,
          program_update_date, substitution_type
   FROM WIP_JOB_DTLS_INTERFACE
   WHERE group_id = p_group_id
   AND   wip_entity_id = p_wip_entity_id
   AND  organization_id = p_organization_id
   AND  operation_seq_num = p_operation_seq_num
   AND  resource_seq_num = p_resource_seq_num
   AND  load_type in (WIP_JOB_DETAILS.WIP_RES_USAGE,
                      WIP_JOB_DETAILS.WIP_RES_INSTANCE_USAGE)
   AND  process_status in (WIP_CONSTANTS.RUNNING,WIP_CONSTANTS.WARNING);

   x_statement varchar2(2000);
   l_resource_id number;

BEGIN

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

       /* delete all existing resource and resource instance usages.*/
       DELETE FROM WIP_OPERATION_RESOURCE_USAGE
       WHERE wip_entity_id = p_wip_entity_id
       AND   organization_id = p_organization_id
       AND   operation_seq_num = p_operation_seq_num
       AND   resource_seq_num = p_resource_seq_num;

/**********************DELETE ALL EXISTING RECORDS BEFORE ADD *************/

   FOR cur_update IN Usage_Update(p_group_id , p_wip_entity_id,
                       p_organization_id, p_operation_seq_num,
                       p_resource_seq_num) LOOP

      IF cur_update.substitution_type = WIP_JOB_DETAILS.WIP_ADD THEN

        INSERT INTO WIP_OPERATION_RESOURCE_USAGE
         ( WIP_ENTITY_ID  ,
          ORGANIZATION_ID,
          OPERATION_SEQ_NUM,
          RESOURCE_SEQ_NUM,
          INSTANCE_ID,
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
          PROGRAM_UPDATE_DATE,
	  SERIAL_NUMBER)
       VALUES
       ( cur_update.wip_entity_id,
         cur_update.organization_id,
         cur_update.operation_seq_num,
         cur_update.resource_seq_num,
         cur_update.resource_instance_id,
         cur_update.start_date,
         cur_update.completion_date,
         cur_update.assigned_units,
         sysdate,/*BUG 6721823*/
         cur_update.last_updated_by,
         cur_update.creation_date,
         cur_update.created_by,
         cur_update.last_update_login,
         cur_update.request_id,
         cur_update.program_application_id,
         cur_update.program_id,
         cur_update.program_update_date,
	 cur_update.resource_serial_number);

   END IF;

  END LOOP;

  Update_cumulative_time(p_wip_entity_id,
                         p_operation_seq_num,
                         p_resource_seq_num);

   exception
    When others then
       x_err_code := SQLCODE;
       x_err_msg := 'Error in wipjdstb: '|| SQLERRM;
       x_return_status := FND_API.G_RET_STS_ERROR;
       return;
  end;

 END Sub_Usage;

-- Used to check whether there're some usage record for a resource.

Function Num_Of_Usage(p_group_id                number,  /* Fix for bug#3636378 */
                      p_wip_entity_id           number,
                      p_organization_id         number,
                      p_operation_seq_num       number,
                      p_resource_seq_num        number) return number IS

  x_count       number := 0;

 BEGIN

   select count(*) into x_count
   from wip_job_dtls_interface
   where group_id = p_group_id  /* Fix for bug#3636378 */
     and wip_entity_id = p_wip_entity_id
     and organization_id = p_organization_id
     and operation_seq_num = p_operation_seq_num
     and resource_seq_num  = p_resource_seq_num
     and load_type = WIP_JOB_DETAILS.WIP_RES_USAGE;

   return x_count;


 END Num_Of_Usage;

-- We will insert a default usage record if
-- 1. the program is stand alone
-- 2. the scheduling method for this job is manully.

Procedure Add_Default_Usage(p_wip_entity_id             number,
                            p_organization_id           number,
                            p_operation_seq_num         number,
                            p_resource_seq_num          number) IS

  BEGIN

    INSERT INTO WIP_OPERATION_RESOURCE_USAGE
      (WIP_ENTITY_ID,
       OPERATION_SEQ_NUM,
       RESOURCE_SEQ_NUM,
       ORGANIZATION_ID,
       LAST_UPDATE_DATE,
       LAST_UPDATED_BY,
       CREATION_DATE,
       CREATED_BY,
       LAST_UPDATE_LOGIN,
       REQUEST_ID,
       PROGRAM_APPLICATION_ID,
       PROGRAM_ID,
       PROGRAM_UPDATE_DATE,
       START_DATE,
       COMPLETION_DATE,
       ASSIGNED_UNITS)
    SELECT
      WIP_ENTITY_ID,
       OPERATION_SEQ_NUM,
       RESOURCE_SEQ_NUM,
       ORGANIZATION_ID,
       LAST_UPDATE_DATE,
       LAST_UPDATED_BY,
       CREATION_DATE,
       CREATED_BY,
       LAST_UPDATE_LOGIN,
       REQUEST_ID,
       PROGRAM_APPLICATION_ID,
       PROGRAM_ID,
       PROGRAM_UPDATE_DATE,
       START_DATE,
       COMPLETION_DATE,
       ASSIGNED_UNITS
     FROM WIP_OPERATION_RESOURCES
    WHERE wip_entity_id = p_wip_entity_id
      AND organization_id = p_organization_id
      AND operation_seq_num = p_operation_seq_num
      AND resource_seq_num  = p_resource_seq_num;

    /*Bug 5727185/5576967: Update cumulative processing time for WORU record*/
    Update_cumulative_time(p_wip_entity_id,
                           p_operation_seq_num,
                           p_resource_seq_num);

 END Add_Default_Usage;

Procedure Add_Op_Link (p_group_id              number,
                        p_wip_entity_id number,
                        p_organization_id       number,
                        p_err_code   out NOCOPY     varchar2,
                        p_err_msg    out NOCOPY     varchar2) IS


   CURSOR op_link_info (p_group_id          number,
                   p_wip_entity_id      number,
                   p_organization_id    number) IS
   SELECT distinct operation_seq_num, next_network_op_seq_num,
          last_update_date, last_updated_by, creation_date, created_by,
          last_update_login,
          attribute_category, attribute1,
          attribute2,attribute3,attribute4,attribute5,attribute6,attribute7,
          attribute8,attribute9,attribute10,attribute11,attribute12,
          attribute13,attribute14,attribute15,schedule_seq_num,
          substitute_group_num,replacement_group_num,batch_id
     FROM WIP_JOB_DTLS_INTERFACE
    WHERE group_id = p_group_id
      AND process_phase = WIP_CONSTANTS.ML_VALIDATION
      AND process_status in (WIP_CONSTANTS.RUNNING,WIP_CONSTANTS.WARNING)
      AND wip_entity_id = p_wip_entity_id
      AND organization_id = p_organization_id
      AND load_type = WIP_JOB_DETAILS.WIP_OP_LINK
      AND substitution_type = WIP_JOB_DETAILS.WIP_ADD;

  l_scheduling_method number;

BEGIN

    begin
    FOR cur_row IN op_link_info(p_group_id,
                           p_wip_entity_id,
                           p_organization_id) LOOP

        /* insert into table */
        INSERT INTO WIP_OPERATION_NETWORKS(
                prior_operation,
                next_operation,
                wip_entity_id,
                organization_id,
                last_update_date,
                last_updated_by,
                creation_date,
                created_by,
                last_update_login,
                attribute_category,
                attribute1,
                attribute2,
                attribute3,
                attribute4,
                attribute5,
                attribute6,
                attribute7,
                attribute8,
                attribute9,
                attribute10,
                attribute11,
                attribute12,
                attribute13,
                attribute14,
                attribute15)
        VALUES (
                cur_row.operation_seq_num,
                cur_row.next_network_op_seq_num,
                p_wip_entity_id,
                p_organization_id,
                sysdate,/*BUG 6721823*/
                cur_row.last_updated_by,
                cur_row.creation_date,
                cur_row.created_by,
                cur_row.last_update_login,
                cur_row.attribute_category,
                cur_row.attribute1,
                cur_row.attribute2,
                cur_row.attribute3,
                cur_row.attribute4,
                cur_row.attribute5,
                cur_row.attribute6,
                cur_row.attribute7,
                cur_row.attribute8,
                cur_row.attribute9,
                cur_row.attribute10,
                cur_row.attribute11,
                cur_row.attribute12,
                cur_row.attribute13,
                cur_row.attribute14,
                cur_row.attribute15);

    END LOOP;

    exception
       when others then
             p_err_msg := 'WIPJDSTB, Add_Op_Link: ' || SQLERRM;
             p_err_code := SQLCODE;
    end;

END Add_Op_Link;

Procedure Delete_Op_Link (p_group_id        number,
                        p_wip_entity_id         number,
                        p_organization_id       number,
                        p_err_code      out NOCOPY     varchar2,
                        p_err_msg       out NOCOPY     varchar2) IS

   CURSOR op_link_info (p_group_id          number,
                   p_wip_entity_id      number,
                   p_organization_id    number) IS
   SELECT distinct operation_seq_num, next_network_op_seq_num,
          last_update_date, last_updated_by, creation_date, created_by,
          last_update_login,
          attribute_category, attribute1,
          attribute2,attribute3,attribute4,attribute5,attribute6,attribute7,
          attribute8,attribute9,attribute10,attribute11,attribute12,
          attribute13,attribute14,attribute15,schedule_seq_num,
          substitute_group_num,replacement_group_num,batch_id
     FROM WIP_JOB_DTLS_INTERFACE
    WHERE group_id = p_group_id
      AND process_phase = WIP_CONSTANTS.ML_VALIDATION
      AND process_status in (WIP_CONSTANTS.RUNNING,WIP_CONSTANTS.WARNING)
      AND wip_entity_id = p_wip_entity_id
      AND organization_id = p_organization_id
      AND load_type = WIP_JOB_DETAILS.WIP_OP_LINK
      AND substitution_type = WIP_JOB_DETAILS.WIP_DELETE;

BEGIN

    begin
    FOR cur_row IN op_link_info(p_group_id,
                           p_wip_entity_id,
                           p_organization_id) LOOP

         DELETE FROM WIP_OPERATION_NETWORKS
          WHERE  wip_entity_id = p_wip_entity_id
            AND  organization_id = p_organization_id
            AND  prior_operation = cur_row.operation_seq_num
            AND  next_operation = cur_row.next_network_op_seq_num;

    END LOOP;
    exception
       when others then
             p_err_msg := 'WIPJDSTB, Delete_Op_Link: ' || SQLERRM;
             p_err_code := SQLCODE;
    end;

END Delete_Op_Link;


Procedure Add_Serial_Association(p_group_id             in  number,
                                 p_wip_entity_id        in  number,
                                 p_organization_id      in  number,
                                 x_err_code            out NOCOPY varchar2,
                                 x_err_msg             out NOCOPY varchar2,
                                 x_return_status       out NOCOPY varchar2) IS

    CURSOR ser_info ( p_group_id number,
                      p_wip_entity_id  number,
                      p_organization_id number) IS
   SELECT wjdi.serial_number_new serial_number,
          nvl(we.primary_item_id, wjsi.primary_item_id) primary_item_id,
          nvl(we.organization_id, wjsi.organization_id) organization_id
     FROM wip_job_dtls_interface wjdi,
          wip_job_schedule_interface wjsi,
          wip_entities we
    WHERE wjdi.group_id = p_group_id
      AND wjsi.group_id = p_group_id
      AND wjdi.process_phase = WIP_CONSTANTS.ML_VALIDATION
      AND wjdi.process_status in (WIP_CONSTANTS.RUNNING,WIP_CONSTANTS.WARNING)
      AND wjdi.wip_entity_id = p_wip_entity_id
      AND wjdi.organization_id = p_organization_id
      AND wjdi.load_type = WIP_JOB_DETAILS.WIP_SERIAL
      AND wjdi.substitution_type = WIP_JOB_DETAILS.WIP_ADD
      AND wjdi.parent_header_id = wjsi.header_id
      AND wjsi.wip_entity_id = we.wip_entity_id (+);

begin
  savepoint wipjdstb10;
   IF p_group_id IS NULL OR p_organization_id IS NULL OR
      p_wip_entity_id IS NULL THEN

     x_err_code := SQLCODE;
     x_err_msg := 'Error in wipjdstb.pls'|| SQLERRM;
     x_return_status := FND_API.G_RET_STS_ERROR;
     return;
   END IF;

  for l_serRec in ser_info(p_group_id, p_wip_entity_id, p_organization_id) loop
    wip_utilities.update_serial(p_serial_number            => l_serRec.serial_number,
                                p_organization_id          => l_serRec.organization_id,
                                p_inventory_item_id        => l_serRec.primary_item_id,
                                p_wip_entity_id            => p_wip_entity_id,
                                p_operation_seq_num        => null,
                                p_intraoperation_step_type => null,
                                x_return_status            => x_return_status);
    if(x_return_status <> fnd_api.g_ret_sts_success) then
      rollback to wipjdstb10;
      wip_utilities.get_message_stack(p_msg => x_err_msg);
      exit;
    end if;
  end loop;
exception
  when others then
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_err_code := SQLCODE;
    x_err_msg := 'ERROR IN WIPJDSTB : '||SQLERRM;

END Add_Serial_Association;

Procedure Change_Serial_Association (p_group_id          in  number,
                                    p_wip_entity_id     in  number,
                                    p_organization_id   in  number,
                                    x_err_code          out NOCOPY varchar2,
                                    x_err_msg           out NOCOPY varchar2,
                                    x_return_status     out NOCOPY varchar2) IS

    CURSOR ser_info ( p_group_id number,
                      p_wip_entity_id  number,
                      p_organization_id number) IS
   SELECT wjdi.serial_number_new,
          wjdi.serial_number_old,
          nvl(we.primary_item_id, wjsi.primary_item_id) primary_item_id,
          nvl(we.organization_id, wjsi.organization_id) organization_id
     FROM wip_job_dtls_interface wjdi,
          wip_job_schedule_interface wjsi,
          wip_entities we
    WHERE wjdi.group_id = p_group_id
      AND wjsi.group_id = p_group_id
      AND wjdi.process_phase = WIP_CONSTANTS.ML_VALIDATION
      AND wjdi.process_status in (WIP_CONSTANTS.RUNNING,WIP_CONSTANTS.WARNING)
      AND wjdi.wip_entity_id = p_wip_entity_id
      AND wjdi.organization_id = p_organization_id
      AND wjdi.load_type = WIP_JOB_DETAILS.WIP_SERIAL
      AND wjdi.substitution_type = WIP_JOB_DETAILS.WIP_CHANGE
      and wjdi.parent_header_id = wjsi.header_id
      and wjsi.wip_entity_id = we.wip_entity_id (+);

BEGIN
  savepoint wipjdstb20;
  IF p_group_id IS NULL OR p_organization_id IS NULL OR
    p_wip_entity_id IS NULL THEN

    x_err_code := SQLCODE;
    x_err_msg := 'Error in wipjdstb.pls'|| SQLERRM;
    x_return_status := FND_API.G_RET_STS_ERROR;
    return;
  END IF;

  for l_serRec in ser_info(p_group_id, p_wip_entity_id, p_organization_id) loop
    wip_utilities.update_serial(p_serial_number            => l_serRec.serial_number_new,
                                p_organization_id          => l_serRec.organization_id,
                                p_inventory_item_id        => l_serRec.primary_item_id,
                                p_wip_entity_id            => p_wip_entity_id,
                                p_operation_seq_num        => null,
                                p_intraoperation_step_type => null,
                                x_return_status            => x_return_status);
    if(x_return_status <> fnd_api.g_ret_sts_success) then
      rollback to wipjdstb20;
      wip_utilities.get_message_stack(p_msg => x_err_msg);
      exit;
    end if;

    wip_utilities.update_serial(p_serial_number            => l_serRec.serial_number_old,
                                p_organization_id          => l_serRec.organization_id,
                                p_inventory_item_id        => l_serRec.primary_item_id,
                                p_wip_entity_id            => null,
                                p_operation_seq_num        => null,
                                p_intraoperation_step_type => null,
                                x_return_status            => x_return_status);
    if(x_return_status <> fnd_api.g_ret_sts_success) then
      wip_utilities.get_message_stack(p_msg => x_err_msg);
      exit;
    end if;

  end loop;

exception
  when others then
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_err_code := SQLCODE;
    x_err_msg := 'ERROR IN WIPJDSTB : '||SQLERRM;
END Change_Serial_Association;

Procedure Delete_Serial_Association (p_group_id          in  number,
                                     p_wip_entity_id     in  number,
                                     p_organization_id   in  number,
                                     x_err_code          out NOCOPY varchar2,
                                     x_err_msg           out NOCOPY varchar2,
                                     x_return_status     out NOCOPY varchar2) IS

   CURSOR ser_info ( p_group_id number,
                      p_wip_entity_id  number,
                      p_organization_id number) IS
   SELECT wjdi.serial_number_old serial_number,
          nvl(we.primary_item_id, wjsi.primary_item_id) primary_item_id,
          nvl(we.organization_id, wjsi.organization_id) organization_id
     FROM wip_job_dtls_interface wjdi,
          wip_job_schedule_interface wjsi,
          wip_entities we
    WHERE wjdi.group_id = p_group_id
      AND wjsi.group_id = p_group_id
      AND wjdi.process_phase = WIP_CONSTANTS.ML_VALIDATION
      AND wjdi.process_status in (WIP_CONSTANTS.RUNNING,WIP_CONSTANTS.WARNING)
      AND wjdi.wip_entity_id = p_wip_entity_id
      AND wjdi.organization_id = p_organization_id
      AND wjdi.load_type = WIP_JOB_DETAILS.WIP_SERIAL
      AND wjdi.substitution_type = WIP_JOB_DETAILS.WIP_DELETE
      AND wjdi.parent_header_id = wjsi.header_id
      AND wjsi.wip_entity_id = we.wip_entity_id (+);

BEGIN
  savepoint wipjdstb30;
  IF p_group_id IS NULL OR p_organization_id IS NULL OR
    p_wip_entity_id IS NULL THEN

    x_err_code := SQLCODE;
    x_err_msg := 'Error in wipjdstb.pls'|| SQLERRM;
    x_return_status := FND_API.G_RET_STS_ERROR;
    return;
  END IF;

  for l_serRec in ser_info(p_group_id, p_wip_entity_id, p_organization_id) loop
    wip_utilities.update_serial(p_serial_number            => l_serRec.serial_number,
                                p_organization_id          => l_serRec.organization_id,
                                p_inventory_item_id        => l_serRec.primary_item_id,
                                p_wip_entity_id            => null,
                                p_operation_seq_num        => null,
                                p_intraoperation_step_type => null,
                                x_return_status            => x_return_status);
    if(x_return_status <> fnd_api.g_ret_sts_success) then
      rollback to wipjdstb30;
      wip_utilities.get_message_stack(p_msg => x_err_msg);
      exit;
    end if;
  end loop;
exception
  when others then
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_err_code := SQLCODE;
    x_err_msg := 'ERROR IN WIPJDSTB : '||SQLERRM;
END Delete_Serial_Association;

Procedure Default_Serial_Associations(p_rowid             in  rowid,
                                      p_wip_entity_id     in  number,
                                      p_organization_id   in  number,
                                      x_err_msg           out NOCOPY varchar2,
                                      x_return_status     out NOCOPY varchar2) IS
    l_defaultSN NUMBER;
    l_rowCount NUMBER;
    l_jobQty NUMBER;
    l_primary_item_id NUMBER;
    l_start_quantity NUMBER;
    l_start_serial VARCHAR2(30);
    l_end_serial VARCHAR2(30);
    l_serialization_start_op NUMBER;
    l_load_type NUMBER;

  begin
    x_return_status := fnd_api.g_ret_sts_success;

    select default_wip_auto_assoc_sn
      into l_defaultSN
      from wip_parameters
     where organization_id = p_organization_id;

    select load_type
      into l_load_type
      from wip_job_schedule_interface
     where rowid = p_rowid;

    if(l_defaultSN = wip_constants.yes and
       l_load_type = wip_constants.create_job) then
      --get the number of serial numbers defaulted and the start quantity of the job

      SELECT count(*)
        INTO l_rowCount
        FROM mtl_serial_numbers
       WHERE wip_entity_id = p_wip_entity_id;

      SELECT start_quantity,
             primary_item_id,
             serialization_start_op
        INTO l_start_quantity,
             l_primary_item_id,
             l_serialization_start_op
        FROM wip_discrete_jobs
       WHERE wip_entity_id = p_wip_entity_id;

      --if the user did not provide enough serial numbers
      if(l_serialization_start_op is not null and
         l_start_quantity > l_rowCount) then
        wip_utilities.generate_serials(p_item_id       => l_primary_item_id,
                                       p_org_id        => p_organization_id,
                                       p_qty           => to_number(l_start_quantity - l_rowCount),
                                       p_wip_entity_id => p_wip_entity_id,
                                       p_revision      => null,
                                       p_lot           => null,
                                       x_start_serial  => l_start_serial,
                                       x_end_serial    => l_end_serial,
                                       x_return_status => x_return_status,
                                       x_err_msg       => x_err_msg);
      end if;
    end if;
  end default_serial_associations;

Procedure Update_Cumulative_Time (
                              p_wip_entity_id           in number,
                              p_operation_seq_num       in number,
                              p_resource_seq_num        in number) IS
    cursor res_usage (p_wip_entity_id number,
                                p_operation_seq_num  number,
                                p_resource_seq_num number) is
          select start_date,
                      completion_date,
                      cumulative_processing_time
           from wip_operation_resource_usage
        where wip_entity_id = p_wip_entity_id
             and operation_seq_num = p_operation_seq_num
             and resource_seq_num = p_resource_seq_num
             and instance_id is null
         order by start_date
         for update;

    current_cpt NUMBER := 0;
begin
    for cur_row in res_usage(p_wip_entity_id, p_operation_seq_num, p_resource_seq_num) loop
           current_cpt := current_cpt + wip_datetimes.datetime_diff_to_mins(cur_row.completion_date, cur_row.start_date);
           update wip_operation_resource_usage
                 set cumulative_processing_time = current_cpt
             where current of res_usage;
    end loop;
end update_cumulative_time;

END WIP_JOB_DTLS_SUBSTITUTIONS;

/

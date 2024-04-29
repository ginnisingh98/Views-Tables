--------------------------------------------------------
--  DDL for Package Body WIP_OPERATION_VALIDATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_OPERATION_VALIDATE" as
/* $Header: wipopvdb.pls 120.1 2006/05/09 00:03:13 panagara noship $ */

/* Helper procedures to validate add/change operation load types */
procedure val_null_values(p_group_id in number,
                          p_parent_header_id in number, /* Fix for Bug#3636378 */
                          p_sub_type in number);
procedure val_dept(p_group_id in number,
                   p_wip_entity_id in number,
                   p_organization_id in number,
                   p_sub_type in number);
procedure val_dept_resources(p_group_id in number,
                             p_wip_entity_id in number,
                             p_organization_id in number,
                             p_sub_type in number);
procedure val_std_op(p_group_id in number,
                     p_wip_entity_id in number,
                     p_organization_id in number,
                     p_sub_type in number);
procedure val_mtq(p_group_id in number,
                  p_wip_entity_id in number,
                  p_organization_id in number,
                  p_sub_type in number);
procedure val_cnt_pnt(p_group_id in number,
                      p_wip_entity_id in number,
                      p_organization_id in number,
                      p_sub_type in number);
procedure val_bfl_flag(p_group_id in number,
                       p_wip_entity_id in number,
                       p_organization_id in number,
                       p_sub_type in number);

/* Helper procedures to validate add operation load types */
procedure val_add_op_seq_num(p_group_id in number,
                             p_wip_entity_id in number,
                             p_organization_id in number);
procedure val_add_sch_date(p_group_id in number,
                           p_wip_entity_id in number,
                           p_organization_id in number,
                           p_parent_header_id in number);

/* Helper procedures to validate change operation load types */
procedure val_change_op_seq_num(p_group_id in number,
                             p_wip_entity_id in number,
                             p_organization_id in number);
procedure val_change_sch_date(p_group_id in number,
                              p_wip_entity_id in number,
                              p_organization_id in number);

/* Public procedures */
Procedure Add_Operation (p_group_id in number,
                         p_parent_header_id in number,
                         p_wip_entity_id in number,
                         p_organization_id in number,
                         x_err_code out nocopy varchar2,
                         x_err_msg  out nocopy varchar2,
                         x_return_status out nocopy varchar2 ) IS
begin

  val_null_values(p_group_id => p_group_id,
                  p_parent_header_id => p_parent_header_id, /* Fix for Bug#3636378 */
                  p_sub_type => wip_job_details.wip_add);

  val_dept(p_group_id        => p_group_id,
           p_wip_entity_id   => p_wip_entity_id,
           p_organization_id => p_organization_id,
           p_sub_type        => wip_job_details.wip_add);

  val_std_op(p_group_id        => p_group_id,
             p_wip_entity_id   => p_wip_entity_id,
             p_organization_id => p_organization_id,
             p_sub_type        => wip_job_details.wip_add);

  val_mtq(p_group_id        => p_group_id,
          p_wip_entity_id   => p_wip_entity_id,
          p_organization_id => p_organization_id,
          p_sub_type        => wip_job_details.wip_add);

  val_cnt_pnt(p_group_id        => p_group_id,
              p_wip_entity_id   => p_wip_entity_id,
              p_organization_id => p_organization_id,
              p_sub_type        => wip_job_details.wip_add);

  val_bfl_flag(p_group_id        => p_group_id,
               p_wip_entity_id   => p_wip_entity_id,
               p_organization_id => p_organization_id,
               p_sub_type        => wip_job_details.wip_add);

  val_add_op_seq_num(p_group_id        => p_group_id,
                     p_wip_entity_id   => p_wip_entity_id,
                     p_organization_id => p_organization_id);

  val_add_sch_date(p_group_id         => p_group_id,
                   p_wip_entity_id    => p_wip_entity_id,
                   p_organization_id  => p_organization_id,
                   p_parent_header_id => p_parent_header_id);

  Exception

    when others then
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_err_msg := 'ERROR IN WIPOPVDB.ADD_OPERATION: ' || SQLERRM;
      x_err_code := to_char(SQLCODE);
      return;

END Add_Operation;


Procedure Change_Operation (p_group_id in number,
                            p_parent_header_id in number,
                            p_wip_entity_id in number,
                            p_organization_id in number,
                            x_err_code out nocopy varchar2,
                            x_err_msg  out nocopy varchar2,
                            x_return_status out nocopy varchar2 ) IS
BEGIN

  val_null_values(p_group_id => p_group_id,
                  p_parent_header_id => p_parent_header_id,  /* Fix for Bug#3636378 */
                  p_sub_type => wip_job_details.wip_change);

  val_dept(p_group_id        => p_group_id,
           p_wip_entity_id   => p_wip_entity_id,
           p_organization_id => p_organization_id,
           p_sub_type        => wip_job_details.wip_change);

  /* Fix for Bug#3546027 */
  val_dept_resources(p_group_id        => p_group_id,
                     p_wip_entity_id   => p_wip_entity_id,
                     p_organization_id => p_organization_id,
                     p_sub_type        => wip_job_details.wip_change);

  val_std_op(p_group_id        => p_group_id,
             p_wip_entity_id   => p_wip_entity_id,
             p_organization_id => p_organization_id,
             p_sub_type        => wip_job_details.wip_change);

  val_mtq(p_group_id        => p_group_id,
          p_wip_entity_id   => p_wip_entity_id,
          p_organization_id => p_organization_id,
          p_sub_type        => wip_job_details.wip_change);

  val_cnt_pnt(p_group_id        => p_group_id,
              p_wip_entity_id   => p_wip_entity_id,
              p_organization_id => p_organization_id,
              p_sub_type        => wip_job_details.wip_change);

  val_bfl_flag(p_group_id        => p_group_id,
               p_wip_entity_id   => p_wip_entity_id,
               p_organization_id => p_organization_id,
               p_sub_type        => wip_job_details.wip_change);

  val_change_op_seq_num(p_group_id        => p_group_id,
                        p_wip_entity_id   => p_wip_entity_id,
                        p_organization_id => p_organization_id);

  val_change_sch_date(p_group_id         => p_group_id,
                      p_wip_entity_id    => p_wip_entity_id,
                      p_organization_id  => p_organization_id);

  Exception

    when others then
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_err_msg := 'ERROR IN WIPOPVDB.CHANGE_OPERATION: ' || SQLERRM;
      x_err_code := to_char(SQLCODE);

      return;

END Change_Operation;

procedure val_null_values(p_group_id in number,
                          p_parent_header_id number, /* Fix for Bug#3636378 */
                          p_sub_type in number) is
  cursor c_invalid_add_rows is
    select interface_id
      from wip_job_dtls_interface
     where group_id = p_group_id
       and parent_header_id = p_parent_header_id /* Fix for Bug#3636378 */
       and process_phase = wip_constants.ml_validation  /* Bug 2751349 */
       and process_status in (wip_constants.running, wip_constants.warning)  /*  Bug 2751349 */
       and substitution_type = p_sub_type
       and load_type = wip_job_details.wip_operation
       and (   operation_seq_num is null
            or department_id is null
            or first_unit_start_date is null
            or first_unit_completion_date is null
            or last_unit_start_date is null
            or last_unit_completion_date is null
            or minimum_transfer_quantity is null
            or count_point_type is null
            or backflush_flag is null
           );

  cursor c_invalid_change_rows is
    select interface_id
      from wip_job_dtls_interface
     where group_id = p_group_id
       and parent_header_id = p_parent_header_id /* Fix for Bug#3636378 */
       and process_phase = wip_constants.ml_validation  /* Bug 2751349 */
       and process_status in (wip_constants.running, wip_constants.warning)  /*  Bug 2751349 */
       and substitution_type = p_sub_type
       and load_type = wip_job_details.wip_operation
       and operation_seq_num is null;

    l_error_exists boolean := false;
    l_interface_id NUMBER;
begin
  if(p_sub_type = wip_job_details.wip_add) then
    open c_invalid_add_rows;
  elsif(p_sub_type = wip_job_details.wip_change) then
    open c_invalid_change_rows;
  else
    return;
  end if;

  loop
  if(p_sub_type = wip_job_details.wip_add) then
    fetch c_invalid_add_rows into l_interface_id;
    exit when c_invalid_add_rows%NOTFOUND;
  elsif(p_sub_type = wip_job_details.wip_change) then
    fetch c_invalid_change_rows into l_interface_id;
    exit when c_invalid_change_rows%NOTFOUND;
  end if;

    l_error_exists := true;
    fnd_message.set_name('WIP', 'WIP_ADD_OP_MIS_VAL');
    fnd_message.set_token('INTERFACE', to_char(l_interface_id));
    if(wip_job_details.std_alone = 1) then
      wip_interface_err_Utils.add_error(p_interface_id => l_interface_id,
                                        p_text         => substr(fnd_message.get,1,500),
                                        p_error_type   => wip_jdi_utils.msg_error);
    else
      wip_interface_err_Utils.add_error(p_interface_id => wip_jsi_utils.current_interface_id,
                                        p_text         => substr(fnd_message.get,1,500),
                                        p_error_type   => wip_jdi_utils.msg_error);
      end if;
  end loop;
  if(c_invalid_add_rows%ISOPEN) then
    close c_invalid_add_rows;
  elsif(c_invalid_change_rows%ISOPEN) then
    close c_invalid_change_rows;
  end if;

  if(l_error_exists) then
    if(p_sub_type = wip_job_details.wip_add) then
      update wip_job_dtls_interface wjdi
         set process_status = wip_constants.error
         where group_id = p_group_id
         and process_phase = wip_constants.ml_validation  /* Bug 2751349 */
         and process_status in (wip_constants.running, wip_constants.warning)  /*  Bug 2751349 */
         and substitution_type = p_sub_type
         and load_type = wip_job_details.wip_operation
         and (   operation_seq_num IS NULL
              OR department_id IS NULL
              OR first_unit_start_date IS NULL
              OR first_unit_completion_date IS NULL
              OR last_unit_start_date IS NULL
              OR last_unit_completion_date IS NULL
              OR minimum_transfer_quantity IS NULL
              OR count_point_type IS NULL
              OR backflush_flag IS NULL
             );
    else
      update wip_job_dtls_interface wjdi
         set process_status = wip_constants.error
         where group_id = p_group_id
         and process_phase = wip_constants.ml_validation  /* Bug 2751349 */
         and process_status in (wip_constants.running, wip_constants.warning)  /*  Bug 2751349 */
         and substitution_type = p_sub_type
         and load_type = wip_job_details.wip_operation
         and operation_seq_num IS NULL;
    end if;
  end if;
end val_null_values;



/*****************************************************************
  CHECK THAT THE GIVEN P_DEPARTMENT_ID, P_ORGANIZATION_ID COMBINATION
  EXISTS IN BOM_DEPARTMENTS TABLE.
*******************************************************************/
procedure val_dept(p_group_id in number,
                   p_wip_entity_id in number,
                   p_organization_id in number,
                   p_sub_type in number) is
  cursor c_invalid_rows is
    select interface_id
      from wip_job_dtls_interface wjdi
     where group_id = p_group_id
       and process_phase = wip_constants.ml_validation
       and process_status in (wip_constants.running,
                              wip_constants.warning)
       and load_type = wip_job_details.wip_operation
       and substitution_type = p_sub_type
       and wip_entity_id = p_wip_entity_id
       and organization_id = p_organization_id
       and (   (    department_id is null --can not add w/null dept
                and p_sub_type = wip_job_details.wip_add
               )
            or (    department_id is not null
                and not exists (select 1
                                  from bom_departments
                                 where department_id = wjdi.department_id
                                   and organization_id = wjdi.organization_id)
               )
           );

  l_error_exists boolean := false;
begin
  for l_inv_row in c_invalid_rows loop
    l_error_exists := true;
    fnd_message.set_name('WIP', 'WIP_DEPARTMENT_NOT_EXIST');
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
     where group_id = p_group_id
       and process_phase = wip_constants.ml_validation
       and process_status in (wip_constants.running,
                              wip_constants.warning)
       and wip_entity_id = p_wip_entity_id
       and organization_id = p_organization_id
       and (   (    department_id is null
                and p_sub_type = wip_job_details.wip_add
               )
            or (    department_id is not null
                and not exists (select 1
                                  from bom_departments
                                 where department_id = wjdi.department_id
                                   and organization_id = wjdi.organization_id)
               )
           );
  end if;
end val_dept;

/* Added procedure for bug#3546027*/
procedure val_dept_resources(p_group_id in number,
                             p_wip_entity_id in number,
                             p_organization_id in number,
                             p_sub_type in number) is
  cursor c_invalid_rows is
    select interface_id,
           operation_seq_num
      from wip_job_dtls_interface wjdi
     where group_id = p_group_id
       and process_phase = wip_constants.ml_validation
       and process_status in (wip_constants.running,
                              wip_constants.warning)
       and load_type = wip_job_details.wip_operation
       and substitution_type = wip_job_details.wip_change
       and wip_entity_id = p_wip_entity_id
       and organization_id = p_organization_id
       and department_id  is not null
       and exists (select 1
                   from  wip_operation_resources wor,
                         wip_operations wo
                   where wo.wip_entity_id = wjdi.wip_entity_id
                   and   wo.operation_seq_num = wjdi.operation_seq_num
                   and   wo.organization_id = wjdi.organization_id
                   and   wo.wip_entity_id = wor.wip_entity_id
                   and   wo.operation_seq_num = wor.operation_seq_num
                   and   wo.organization_id = wor.organization_id
                   and   nvl(wo.repetitive_schedule_id, 1) =
                         nvl(wor.repetitive_schedule_id, 1)
                   and   wo.department_id <> wjdi.department_id
                   ) ;

  l_error_exists boolean := false;
begin

   for l_inv_row in c_invalid_rows loop
    l_error_exists := true;
    fnd_message.set_name('WIP', 'WIP_DEPARTMENT_RESOURCES_EXIST');
    fnd_message.set_token('INTERFACE', to_char(l_inv_row.interface_id));
    fnd_message.set_token('OPERATION_SEQ_NUM', to_char(l_inv_row.operation_seq_num));
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
     where group_id = p_group_id
       and process_phase = wip_constants.ml_validation
       and process_status in (wip_constants.running,
                              wip_constants.warning)
       and load_type = wip_job_details.wip_operation
       and substitution_type = wip_job_details.wip_change
       and wip_entity_id = p_wip_entity_id
       and organization_id = p_organization_id
       and department_id  is not null
       and exists (select 1
                   from  wip_operation_resources wor,
                         wip_operations wo
                   where wo.wip_entity_id = wjdi.wip_entity_id
                   and   wo.operation_seq_num = wjdi.operation_seq_num
                   and   wo.organization_id = wjdi.organization_id
                   and   wo.wip_entity_id = wor.wip_entity_id
                   and   wo.operation_seq_num = wor.operation_seq_num
                   and   wo.organization_id = wor.organization_id
                   and   nvl(wo.repetitive_schedule_id, 1) =
                         nvl(wor.repetitive_schedule_id, 1)
                   and   wo.department_id <> wjdi.department_id
                   ) ;
    end if ;

end val_dept_resources;

/************VALIDATE STANDARD OPERATIONS **************************/
procedure val_std_op(p_group_id in number,
                     p_wip_entity_id in number,
                     p_organization_id in number,
                     p_sub_type in number) is
  cursor c_invalid_rows is
    select interface_id
      from wip_job_dtls_interface wjdi
     where group_id = p_group_id
       and process_phase = wip_constants.ml_validation
       and process_status in (wip_constants.running,
                              wip_constants.warning)
       and load_type = wip_job_details.wip_operation
       and substitution_type = p_sub_type
       and wip_entity_id = p_wip_entity_id
       and organization_id = p_organization_id
       and standard_operation_id is not null
       and standard_operation_id <> fnd_api.g_miss_num
       and not exists (select 1
                         from bom_standard_operations
                        where standard_operation_id = wjdi.standard_operation_id
                          and organization_id = wjdi.organization_id);

  l_error_exists boolean := false;
begin

  for l_inv_row in c_invalid_rows loop
    l_error_exists := true;
    fnd_message.set_name('WIP', 'WIP_STD_OPER_NOT_EXIST');
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
     where group_id = p_group_id
       and process_phase = wip_constants.ml_validation
       and process_status in (wip_constants.running,
                              wip_constants.warning)
       and load_type = wip_job_details.wip_operation
       and substitution_type = p_sub_type
       and wip_entity_id = p_wip_entity_id
       and organization_id = p_organization_id
       and standard_operation_id is not null
       and standard_operation_id <> fnd_api.g_miss_num
       and not exists (select 1
                         from bom_standard_operations
                        where standard_operation_id = wjdi.standard_operation_id
                          and organization_id = wjdi.organization_id);
  end if;
end val_std_op;



/*************VALIDATE MINIMUM TRANSFER QUANTITY ************************/
procedure val_mtq(p_group_id in number,
                  p_wip_entity_id in number,
                  p_organization_id in number,
                  p_sub_type in number) is
  cursor c_invalid_rows is
    select interface_id
      from wip_job_dtls_interface
     where group_id = p_group_id
       and process_phase = wip_constants.ml_validation
       and process_status in (wip_constants.running,
                              wip_constants.warning)
       and load_type = wip_job_details.wip_operation
       and substitution_type = p_sub_type
       and wip_entity_id = p_wip_entity_id
       and organization_id = p_organization_id
       and (   (    p_sub_type = wip_job_details.wip_add
                and minimum_transfer_quantity is null
               )
            or minimum_transfer_quantity < 0);

  l_error_exists boolean := false;
begin
  for l_inv_row in c_invalid_rows loop
    l_error_exists := true;
    fnd_message.set_name('WIP', 'WIP_INVALID_MIN_XFER_QTY');
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
     where group_id = p_group_id
       and process_phase = wip_constants.ml_validation
       and process_status in (wip_constants.running,
                              wip_constants.warning)
       and load_type = wip_job_details.wip_operation
       and substitution_type = p_sub_type
       and wip_entity_id = p_wip_entity_id
       and organization_id = p_organization_id
       and (   (    minimum_transfer_quantity is null
                and p_sub_type = wip_job_details.wip_add
               )
            or minimum_transfer_quantity < 0 );
  end if;
end val_mtq;



/***************VALIDATE COUNT_POINT_TYPE *********************/
procedure val_cnt_pnt(p_group_id in number,
                      p_wip_entity_id in number,
                      p_organization_id in number,
                      p_sub_type in number) is
  cursor c_invalid_rows is
    select interface_id
      from wip_job_dtls_interface wjdi
     where group_id = p_group_id
       and process_phase = wip_constants.ml_validation
       and process_status in (wip_constants.running,
                              wip_constants.warning)
       and load_type = wip_job_details.wip_operation
       and substitution_type = p_sub_type
       and wip_entity_id = p_wip_entity_id
       and organization_id = p_organization_id
       and (   (    count_point_type is null
                and p_sub_type = wip_job_details.wip_add
               )
            or (    count_point_type is not null
                and not exists (select 1
                                  from mfg_lookups mfg_l
                                 where mfg_l.lookup_type = 'BOM_COUNT_POINT_TYPE'
                                   and mfg_l.lookup_code = wjdi.count_point_type )
               )
           );

  l_error_exists boolean := false;
begin

  for l_inv_row in c_invalid_rows loop
    l_error_exists := true;
    fnd_message.set_name('WIP', 'WIP_INVALID_COUNT_POINT');
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
     where group_id = p_group_id
       and process_phase = wip_constants.ml_validation
       and process_status in (wip_constants.running,
                              wip_constants.warning)
       and load_type = wip_job_details.wip_operation
       and substitution_type = p_sub_type
       and wip_entity_id = p_wip_entity_id
       and organization_id = p_organization_id
       and (   (    count_point_type is null
                and p_sub_type = wip_job_details.wip_add
               )
            or (    count_point_type is not null
                and not exists (select 1
                                  from mfg_lookups mfg_l
                                 where mfg_l.lookup_type = 'BOM_COUNT_POINT_TYPE'
                                   and mfg_l.lookup_code = wjdi.count_point_type )
               )
           );
  end if;
end val_cnt_pnt;




/***************VALIDATE COUNT_POINT_TYPE *********************/
procedure val_bfl_flag(p_group_id in number,
                       p_wip_entity_id in number,
                       p_organization_id in number,
                       p_sub_type in number) is
  cursor c_invalid_rows is
    select interface_id
      from wip_job_dtls_interface wjdi
     where group_id = p_group_id
       and process_phase = wip_constants.ml_validation
       and process_status in (wip_constants.running,
                              wip_constants.warning)
       and load_type = wip_job_details.wip_operation
       and substitution_type = p_sub_type
       and wip_entity_id = p_wip_entity_id
       and organization_id = p_organization_id
       and (   (    backflush_flag is null
                and p_sub_type = wip_job_details.wip_add
               )
            or (    backflush_flag is not null
                and not exists (select 1
                                  from mfg_lookups mfg_l
                                 where mfg_l.lookup_type = 'SYS_YES_NO'
                                   and mfg_l.lookup_code = wjdi.backflush_flag)
               )
           );

  l_error_exists boolean := false;
begin

  for l_inv_row in c_invalid_rows loop
    l_error_exists := true;
    fnd_message.set_name('WIP', 'WIP_INVALID_BF_FLAG');
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
     where group_id = p_group_id
       and load_type = wip_job_details.wip_operation
       and substitution_type = p_sub_type
       and process_phase = wip_constants.ml_validation
       and process_status in (wip_constants.running,
                              wip_constants.warning)
       and wip_entity_id = p_wip_entity_id
       and organization_id = p_organization_id
       and (   (    backflush_flag is null
                and p_sub_type = wip_job_details.wip_add
               )
            or (    backflush_flag is not null
                and not exists (select 1
                                  from mfg_lookups mfg_l
                                 where mfg_l.lookup_type = 'SYS_YES_NO'
                                   and mfg_l.lookup_code = wjdi.backflush_flag)
               )
           );
  end if;
end val_bfl_flag;



/*****************************************************************
  CHECK THAT NO RECORDS EXIST IN WIP_OPERATIONS TABLE WITH THE GIVEN
  WIP_ENTITY_ID, ORGANIZATION_ID AND OPERATION_SEQ_NUM.
 *****************************************************************/
procedure val_add_op_seq_num(p_group_id in number,
                             p_wip_entity_id in number,
                             p_organization_id in number) is
  cursor c_invalid_rows is
    select interface_id, operation_seq_num
      from wip_job_dtls_interface wjdi
     where group_id = p_group_id
       and process_phase = wip_constants.ml_validation
       and process_status in (wip_constants.running,
                              wip_constants.warning)
       and load_type = wip_job_details.wip_operation
       and substitution_type = wip_job_details.wip_add
       and wip_entity_id = p_wip_entity_id
       and organization_id = p_organization_id
       and (exists (select 1
                     from wip_operations
                    where wip_entity_id = wjdi.wip_entity_id
                      and organization_id = wjdi.organization_id
                      and operation_seq_num = wjdi.operation_seq_num) or
             operation_seq_num <= 0);

  l_error_exists boolean := false;
begin

  for l_inv_row in c_invalid_rows loop
    l_error_exists := true;
    if(l_inv_row.operation_seq_num <= 10) then
      fnd_message.set_name('WIP','WIP_GREATER_THAN');
      fnd_message.set_token('ENTITY1', 'OPERATION SEQUENCE NUMBER-CAP', TRUE);
      fnd_message.set_token('ENTITY2', '0', FALSE);
    else
      fnd_message.set_name('WIP', 'WIP_OPERATION_ALREADY_EXIST');
      fnd_message.set_token('INTERFACE', to_char(l_inv_row.interface_id));
    end if;
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
     where group_id = p_group_id
       and load_type = wip_job_details.wip_operation
       and substitution_type = wip_job_details.wip_add
       and process_phase = wip_constants.ml_validation
       and process_status in (wip_constants.running,
                              wip_constants.warning)
       and wip_entity_id = p_wip_entity_id
       and organization_id = p_organization_id
       and (exists (select 1
                     from wip_operations
                    where wip_entity_id = wjdi.wip_entity_id
                      and organization_id = wjdi.organization_id
                      and operation_seq_num = wjdi.operation_seq_num)
	    or operation_seq_num <= 0);
  end if;
end val_add_op_seq_num;



/*************VALIDATE SCHEDULE DATE **********************************/
procedure val_add_sch_date(p_group_id in number,
                           p_wip_entity_id in number,
                           p_organization_id in number,
                           p_parent_header_id in number) is
  cursor c_ml_invalid_rows is
    select interface_id
      from wip_job_dtls_interface wjdi
     where group_id = p_group_id
       and process_phase = wip_constants.ml_validation
       and process_status in (wip_constants.running,
                              wip_constants.warning)
       and load_type = wip_job_details.wip_operation
       and substitution_type = wip_job_details.wip_add
       and wip_entity_id = p_wip_entity_id
       and organization_id = p_organization_id
       and parent_header_id = p_parent_header_id
       and (   wjdi.first_unit_start_date is null
            or wjdi.first_unit_completion_date is null
            or wjdi.last_unit_start_date is null
            or wjdi.last_unit_completion_date is null
/* bug3669728 begin */
            or wjdi.first_unit_start_date > wjdi.last_unit_start_date
            or wjdi.first_unit_completion_date > wjdi.last_unit_completion_date
            or wjdi.first_unit_start_date > wjdi.first_unit_completion_date
            or wjdi.last_unit_start_date > wjdi.last_unit_completion_date
/* bug3669728 end */
           );
 /*bug 3659006->should not check for operation FUSD,LUCD to be within job's start/completion dates */

  cursor c_wdj_invalid_rows is
    select interface_id
      from wip_job_dtls_interface wjdi
     where group_id = p_group_id
       and process_phase = wip_constants.ml_validation
       and process_status in (wip_constants.running,
                              wip_constants.warning)
       and load_type = wip_job_details.wip_operation
       and substitution_type = wip_job_details.wip_add
       and wip_entity_id = p_wip_entity_id
       and organization_id = p_organization_id
       and (   first_unit_start_date is null
            or first_unit_completion_date is null
            or last_unit_start_date is null
            or last_unit_completion_date is null
/* bug3669728 begin */
            or wjdi.first_unit_start_date > wjdi.last_unit_start_date
            or wjdi.first_unit_completion_date > wjdi.last_unit_completion_date
            or wjdi.first_unit_start_date > wjdi.first_unit_completion_date
            or wjdi.last_unit_start_date > wjdi.last_unit_completion_date
/* bug3669728 end */
           );
 /*bug 3659006->should not check for operation FUSD,LUCD to be within job's start/completion dates */

    l_interface_id NUMBER;
    l_error_exists boolean := false;
begin

  if(wip_job_details.std_alone = 0) then
    open c_ml_invalid_rows;
  else
    open c_wdj_invalid_rows;
  end if;

  loop
    if(wip_job_details.std_alone = 0) then
      fetch c_ml_invalid_rows into l_interface_id;
      exit when c_ml_invalid_rows%NOTFOUND;
    else
      fetch c_wdj_invalid_rows into l_interface_id;
      exit when c_wdj_invalid_rows%NOTFOUND;
    end if;
    l_error_exists := true; --loop executes only for invalid rows!
    fnd_message.set_name('WIP', 'WIP_INVALID_SCHEDULE_DATE');
    fnd_message.set_token('INTERFACE', to_char(l_interface_id));
    if(wip_job_details.std_alone = 1) then
      wip_interface_err_Utils.add_error(p_interface_id => l_interface_id,
                                        p_text         => substr(fnd_message.get,1,500),
                                        p_error_type   => wip_jdi_utils.msg_error);
    else
      wip_interface_err_Utils.add_error(p_interface_id => wip_jsi_utils.current_interface_id,
                                        p_text         => substr(fnd_message.get,1,500),
                                        p_error_type   => wip_jdi_utils.msg_error);
    end if;


  end loop;
  if(c_ml_invalid_rows%ISOPEN) then
    close c_ml_invalid_rows;
  elsif(c_wdj_invalid_rows%ISOPEN) then
    close c_wdj_invalid_rows;
  end if;

  if(l_error_exists) then
    if(wip_job_details.std_alone = 1) then
      update wip_job_dtls_interface wjdi
         set process_status = wip_constants.error
       where group_id = p_group_id
         and process_phase = wip_constants.ml_validation
         and process_status in (wip_constants.running,
                                wip_constants.warning)
         and load_type = wip_job_details.wip_operation
         and substitution_type = wip_job_details.wip_add
         and wip_entity_id = p_wip_entity_id
         and organization_id = p_organization_id
         and (   wjdi.first_unit_start_date is null
              or wjdi.first_unit_completion_date is null
              or wjdi.last_unit_start_date is null
              or wjdi.last_unit_completion_date is null
/* bug3669728 begin */
              or wjdi.first_unit_start_date > wjdi.last_unit_start_date
              or wjdi.first_unit_completion_date > wjdi.last_unit_completion_date
              or wjdi.first_unit_start_date > wjdi.first_unit_completion_date
              or wjdi.last_unit_start_date > wjdi.last_unit_completion_date
/* bug3669728 end */
             );
    else
      update wip_job_dtls_interface wjdi
         set process_status = wip_constants.error
       where group_id = p_group_id
         and process_phase = wip_constants.ml_validation
         and process_status in (wip_constants.running,
                                wip_constants.warning)
         and load_type = wip_job_details.wip_operation
         and substitution_type = wip_job_details.wip_add
         and wip_entity_id = p_wip_entity_id
         and organization_id = p_organization_id
         and parent_header_id = p_parent_header_id
         and (   wjdi.first_unit_start_date is null
              or wjdi.first_unit_completion_date is null
              or wjdi.last_unit_start_date is null
              or wjdi.last_unit_completion_date is null
/* bug3669728 begin */
              or wjdi.first_unit_start_date > wjdi.last_unit_start_date
              or wjdi.first_unit_completion_date > wjdi.last_unit_completion_date
              or wjdi.first_unit_start_date > wjdi.first_unit_completion_date
              or wjdi.last_unit_start_date > wjdi.last_unit_completion_date
/* bug3669728 end */
             );
    end if;
  end if;
end val_add_sch_date;




/*****************************************************************
  CHECK THAT A RECORD EXISTS IN WIP_OPERATIONS TABLE WITH THE GIVEN
  WIP_ENTITY_ID, ORGANIZATION_ID AND OPERATION_SEQ_NUM.
 *****************************************************************/
procedure val_change_op_seq_num(p_group_id in number,
                             p_wip_entity_id in number,
                             p_organization_id in number) is
  cursor c_invalid_rows is
    select interface_id
      from wip_job_dtls_interface wjdi
     where group_id = p_group_id
       and process_phase = wip_constants.ml_validation
       and process_status in (wip_constants.running,
                              wip_constants.warning)
       and load_type = wip_job_details.wip_operation
       and substitution_type = wip_job_details.wip_change
       and wip_entity_id = p_wip_entity_id
       and not exists (select 1
                         from wip_operations
                        where wip_entity_id = wjdi.wip_entity_id
                          and organization_id = wjdi.organization_id
                          and operation_seq_num = wjdi.operation_seq_num);

  l_error_exists boolean := false;
begin

  for l_inv_row in c_invalid_rows loop
    l_error_exists := true;
    fnd_message.set_name('WIP', 'WIP_OP_NOT_FOUND');
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
     where group_id = p_group_id
       and process_phase = wip_constants.ml_validation
       and process_status in (wip_constants.running,
                              wip_constants.warning)
       and wip_entity_id = p_wip_entity_id
       and not exists (select 1
                         from wip_operations
                        where wip_entity_id = wjdi.wip_entity_id
                          and organization_id = wjdi.organization_id
                          and operation_seq_num = wjdi.operation_seq_num);
  end if;
end val_change_op_seq_num;



/*************VALIDATE SCHEDULE DATE **********************************/
procedure val_change_sch_date(p_group_id in number,
                              p_wip_entity_id in number,
                              p_organization_id in number) is

  cursor c_invalid_rows is
    select interface_id
      from wip_job_dtls_interface wjdi
     where group_id = p_group_id
       and process_phase = wip_constants.ml_validation
       and process_status in (wip_constants.running,
                              wip_constants.warning)
       and load_type = wip_job_details.wip_operation
       and substitution_type = wip_job_details.wip_change
       and wip_entity_id = p_wip_entity_id
       and organization_id = p_organization_id
       and (   wjdi.last_unit_start_date is not null
            or wjdi.first_unit_start_date is not null
            or wjdi.first_unit_completion_date is not null
            or wjdi.last_unit_completion_date is not null
           )
       and exists (select 1
            from wip_operations wo
            where (
/* bug#3669728 begin */
                   (nvl(wjdi.first_unit_start_date, wo.first_unit_start_date)) >
                   (nvl(wjdi.last_unit_start_date, wo.last_unit_start_date))
                       or
                   (nvl(wjdi.first_unit_completion_date, wo.first_unit_completion_date)) >
                   (nvl(wjdi.last_unit_completion_date, wo.last_unit_completion_date))
                       or
                   (nvl(wjdi.first_unit_start_date, wo.first_unit_start_date)) >
                   (nvl(wjdi.first_unit_completion_date, wo.first_unit_completion_date))
                       or
                   (nvl(wjdi.last_unit_start_date, wo.last_unit_start_date)) >
                   (nvl(wjdi.last_unit_completion_date, wo.last_unit_completion_date))
/* bug#3669728 end */
                         )
                      and wip_entity_id = wjdi.wip_entity_id
                      and organization_id = wjdi.organization_id
                      and operation_seq_num = wjdi.operation_seq_num);

    l_error_exists boolean := false;
begin

  for l_row in c_invalid_rows loop
    l_error_exists := true; --loop executes only for invalid rows!
    fnd_message.set_name('WIP', 'WIP_INVALID_SCHEDULE_DATE');
    fnd_message.set_token('INTERFACE', to_char(l_row.interface_id));
    if(wip_job_details.std_alone = 1) then
      wip_interface_err_Utils.add_error(p_interface_id => l_row.interface_id,
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
     where group_id = p_group_id
       and process_phase = wip_constants.ml_validation
       and process_status in (wip_constants.running,
                              wip_constants.warning)
       and load_type = wip_job_details.wip_operation
       and substitution_type = wip_job_details.wip_change
       and wip_entity_id = p_wip_entity_id
       and organization_id = p_organization_id
       and (   wjdi.last_unit_start_date is not null
            or wjdi.first_unit_start_date is not null
            or wjdi.first_unit_completion_date is not null
            or wjdi.last_unit_completion_date is not null
           )
       and exists (select 1
              from wip_operations wo
              where (
/* bug#3669728 begin */
                   (nvl(wjdi.first_unit_start_date, wo.first_unit_start_date)) >
                   (nvl(wjdi.last_unit_start_date, wo.last_unit_start_date))
                       or
                   (nvl(wjdi.first_unit_completion_date, wo.first_unit_completion_date)) >
                   (nvl(wjdi.last_unit_completion_date, wo.last_unit_completion_date))
                       or
                   (nvl(wjdi.first_unit_start_date, wo.first_unit_start_date)) >
                   (nvl(wjdi.first_unit_completion_date, wo.first_unit_completion_date))
                       or
                   (nvl(wjdi.last_unit_start_date, wo.last_unit_start_date)) >
                   (nvl(wjdi.last_unit_completion_date, wo.last_unit_completion_date))
/* bug#3669728 end */
                         )
                      and wip_entity_id = wjdi.wip_entity_id
                      and organization_id = wjdi.organization_id
                      and operation_seq_num = wjdi.operation_seq_num);/*bug 3659006 */

	/* Fix for Bug#3141768. Changed where condition */

  end if;

end val_change_sch_date;

END WIP_OPERATION_VALIDATE;

/

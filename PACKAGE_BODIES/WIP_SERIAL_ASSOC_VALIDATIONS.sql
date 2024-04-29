--------------------------------------------------------
--  DDL for Package Body WIP_SERIAL_ASSOC_VALIDATIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_SERIAL_ASSOC_VALIDATIONS" AS
/* $Header: wipsrvdb.pls 120.2 2006/08/31 15:03:32 sisankar noship $ */

/* forward declarations */
  procedure create_serials(p_group_id              in number,
                           p_wip_entity_id         in number,
                           p_organization_id       in number,
                           p_substitution_type     in number,
                           x_return_status        out nocopy varchar2);

  procedure del_info_exists(p_group_id              in number,
                            p_wip_entity_id         in number,
                            p_organization_id       in number,
                            p_substitution_type     in number,
                            x_return_status        out nocopy varchar2);

  procedure add_info_exists(p_group_id              in number,
                            p_wip_entity_id         in number,
                            p_organization_id       in number,
                            p_substitution_type     in number,
                            x_return_status        out nocopy varchar2);

  --make sure the serial is available for association
  procedure unused_serial_exists(p_group_id              in number,
                                 p_wip_entity_id         in number,
                                 p_organization_id       in number,
                                 p_substitution_type     in number,
                                 x_return_status        out nocopy varchar2);

  procedure used_serial_exists(p_group_id              in number,
                               p_wip_entity_id         in number,
                               p_organization_id       in number,
                               p_substitution_type     in number,
                               x_return_status        out nocopy varchar2);

  procedure valid_parent_load_type(p_group_id              in number,
                                   p_wip_entity_id         in number,
                                   p_organization_id       in number,
                                   p_substitution_type     in number,
                                   x_return_status        out nocopy varchar2);

  procedure valid_job_exists(p_group_id              in number,
                             p_wip_entity_id         in number,
                             p_organization_id       in number,
                             p_substitution_type     in number,
                             x_return_status        out nocopy varchar2);


  procedure change_serial(p_group_id              in number,
                          p_wip_entity_id         in number,
                          p_organization_id       in number,
                          p_substitution_type     in number) is
    l_ret_status VARCHAR2(10);
  begin
    valid_parent_load_type(p_group_id => p_group_id,
                           p_wip_entity_id => p_wip_entity_id,
                           p_organization_id => p_organization_id,
                           p_substitution_type => WIP_JOB_DETAILS.WIP_CHANGE,
                           x_return_status => l_ret_status);

    if(l_ret_status = fnd_api.g_ret_sts_success) then
      valid_job_exists(p_group_id => p_group_id,
                       p_wip_entity_id => p_wip_entity_id,
                       p_organization_id => p_organization_id,
                       p_substitution_type => WIP_JOB_DETAILS.WIP_CHANGE,
                       x_return_status => l_ret_status);
    end if;


    if(l_ret_status = fnd_api.g_ret_sts_success) then
      add_info_exists(p_group_id => p_group_id,
                      p_wip_entity_id => p_wip_entity_id,
                      p_organization_id => p_organization_id,
                      p_substitution_type => WIP_JOB_DETAILS.WIP_CHANGE,
                      x_return_status => l_ret_status);
    end if;

    --if serials do not yet exist in msn, create them here.
    if(l_ret_status = fnd_api.g_ret_sts_success) then
      create_serials(p_group_id => p_group_id,
                      p_wip_entity_id => p_wip_entity_id,
                      p_organization_id => p_organization_id,
                      p_substitution_type => WIP_JOB_DETAILS.WIP_CHANGE,
                      x_return_status => l_ret_status);
    end if;

    if(l_ret_status = fnd_api.g_ret_sts_success) then
      unused_serial_exists(p_group_id => p_group_id,
                           p_wip_entity_id => p_wip_entity_id,
                           p_organization_id => p_organization_id,
                           p_substitution_type => WIP_JOB_DETAILS.WIP_CHANGE,
                           x_return_status => l_ret_status);
    end if;

    if(l_ret_status = fnd_api.g_ret_sts_success) then
      del_info_exists(p_group_id => p_group_id,
                      p_wip_entity_id => p_wip_entity_id,
                      p_organization_id => p_organization_id,
                      p_substitution_type => WIP_JOB_DETAILS.WIP_CHANGE,
                      x_return_status => l_ret_status);
    end if;

    if(l_ret_status = fnd_api.g_ret_sts_success) then
      used_serial_exists(p_group_id => p_group_id,
                         p_wip_entity_id => p_wip_entity_id,
                         p_organization_id => p_organization_id,
                         p_substitution_type => WIP_JOB_DETAILS.WIP_CHANGE,
                         x_return_status => l_ret_status);
    end if;
  end change_serial;

  procedure add_serial(p_group_id              in number,
                       p_wip_entity_id         in number,
                       p_organization_id       in number,
                       p_substitution_type     in number) is
    l_ret_status VARCHAR2(10);
  begin
    valid_parent_load_type(p_group_id => p_group_id,
                           p_wip_entity_id => p_wip_entity_id,
                           p_organization_id => p_organization_id,
                           p_substitution_type => WIP_JOB_DETAILS.WIP_ADD,
                           x_return_status => l_ret_status);

    if(l_ret_status = fnd_api.g_ret_sts_success) then
      valid_job_exists(p_group_id => p_group_id,
                       p_wip_entity_id => p_wip_entity_id,
                       p_organization_id => p_organization_id,
                       p_substitution_type => WIP_JOB_DETAILS.WIP_ADD,
                       x_return_status => l_ret_status);
    end if;

    if(l_ret_status = fnd_api.g_ret_sts_success) then
      add_info_exists(p_group_id => p_group_id,
                      p_wip_entity_id => p_wip_entity_id,
                      p_organization_id => p_organization_id,
                      p_substitution_type => WIP_JOB_DETAILS.WIP_ADD,
                      x_return_status => l_ret_status);
    end if;

    --if serials do not yet exist in msn, create them here.
    if(l_ret_status = fnd_api.g_ret_sts_success) then
      create_serials(p_group_id => p_group_id,
                      p_wip_entity_id => p_wip_entity_id,
                      p_organization_id => p_organization_id,
                      p_substitution_type => WIP_JOB_DETAILS.WIP_ADD,
                      x_return_status => l_ret_status);
    end if;

    if(l_ret_status = fnd_api.g_ret_sts_success) then
      unused_serial_exists(p_group_id => p_group_id,
                           p_wip_entity_id => p_wip_entity_id,
                           p_organization_id => p_organization_id,
                           p_substitution_type => WIP_JOB_DETAILS.WIP_ADD,
                           x_return_status => l_ret_status);
    end if;
  end add_serial;


  procedure delete_serial(p_group_id              in number,
                          p_wip_entity_id         in number,
                          p_organization_id       in number,
                          p_substitution_type     in number) is
    l_ret_status VARCHAR2(10) := fnd_api.g_ret_sts_success;
  begin
    valid_parent_load_type(p_group_id => p_group_id,
                           p_wip_entity_id => p_wip_entity_id,
                           p_organization_id => p_organization_id,
                           p_substitution_type => WIP_JOB_DETAILS.WIP_DELETE,
                          x_return_status => l_ret_status);

    if(l_ret_status = fnd_api.g_ret_sts_success) then
      valid_job_exists(p_group_id => p_group_id,
                       p_wip_entity_id => p_wip_entity_id,
                       p_organization_id => p_organization_id,
                       p_substitution_type => WIP_JOB_DETAILS.WIP_DELETE,
                       x_return_status => l_ret_status);
    end if;

    if(l_ret_status = fnd_api.g_ret_sts_success) then
      del_info_exists(p_group_id => p_group_id,
                      p_wip_entity_id => p_wip_entity_id,
                      p_organization_id => p_organization_id,
                      p_substitution_type => WIP_JOB_DETAILS.WIP_DELETE,
                      x_return_status => l_ret_status);
    end if;


    if(l_ret_status = fnd_api.g_ret_sts_success) then
      used_serial_exists(p_group_id => p_group_id,
                         p_wip_entity_id => p_wip_entity_id,
                         p_organization_id => p_organization_id,
                         p_substitution_type => WIP_JOB_DETAILS.WIP_DELETE,
                         x_return_status => l_ret_status);
    end if;
  end delete_serial;

  procedure del_info_exists(p_group_id              in number,
                            p_wip_entity_id         in number,
                            p_organization_id       in number,
                            p_substitution_type     in number,
                            x_return_status        out nocopy varchar2) is

    cursor c_invalid_rows is
    select interface_id
      from wip_job_dtls_interface wjdi
     where wjdi.group_id = p_group_id
       and wjdi.process_phase = wip_constants.ml_validation
       and wjdi.process_status in (wip_constants.running,
                                   wip_constants.pending,
                                   wip_constants.warning)
       and wjdi.wip_entity_id = p_wip_entity_id
       and wjdi.organization_id = p_organization_id
       and wjdi.load_type = wip_job_details.wip_serial
       and wjdi.substitution_type = p_substitution_type
       and wjdi.serial_number_old is null;

  begin
    x_return_status := fnd_api.g_ret_sts_success;
    for l_inv_row in c_invalid_rows loop
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_message.set_name('WIP', 'WIP_JDI_OLD_SERIAL_MISSING');
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

    if(x_return_status <> fnd_api.g_ret_sts_success) then
      update wip_job_dtls_interface wjdi
        set process_status = wip_constants.error
        where group_id = p_group_id
        and process_phase = wip_constants.ml_validation
        and process_status in (wip_constants.running,
                               wip_constants.pending,
                               wip_constants.warning)
        and wip_entity_id = p_wip_entity_id
        and organization_id = p_organization_id
        and wjdi.load_type = wip_job_details.wip_serial
        and wjdi.substitution_type = p_substitution_type
        and wjdi.serial_number_old is null;
    end if;
  end del_info_exists;

  procedure create_serials(p_group_id              in number,
                           p_wip_entity_id         in number,
                           p_organization_id       in number,
                           p_substitution_type     in number,
                           x_return_status        out nocopy varchar2) is
    cursor c_serials is
    select interface_id,
           we.primary_item_id,
           wjdi.serial_number_new,
           wjdi.rowid
      from wip_job_dtls_interface wjdi,
           wip_entities we
     where wjdi.group_id = p_group_id
       and wjdi.process_phase = wip_constants.ml_validation
       and wjdi.process_status in (wip_constants.running,
                                   wip_constants.pending,
                                   wip_constants.warning)
       and wjdi.wip_entity_id = p_wip_entity_id
       and wjdi.organization_id = p_organization_id
       and wjdi.load_type = wip_job_details.wip_serial
       and wjdi.substitution_type = p_substitution_type
       and wjdi.wip_entity_id = we.wip_entity_id
       and not exists(select 1
                        from mtl_serial_numbers
                       where serial_number = wjdi.serial_number_new
                         and inventory_item_id = we.primary_item_id
                         and current_organization_id = wjdi.organization_id);

    l_start_serial_num VARCHAR2(30);
    l_end_serial_num VARCHAR2(30);
    l_error_msg VARCHAR(2000);
    l_return_status VARCHAR2(1);
  begin
    x_return_status := fnd_api.g_ret_sts_success;
    for l_ser_rec in c_serials loop
      l_start_serial_num := l_ser_rec.serial_number_new;
      wip_utilities.generate_serials(p_org_id => p_organization_id,
                                     p_item_id => l_ser_rec.primary_item_id,
                                     p_qty => 1,
                                     p_wip_entity_id => null, --processing code will fill this in later.
                                     p_revision => null,
                                     p_lot => null,
                                     x_start_serial => l_start_serial_num,
                                     x_end_serial => l_end_serial_num,
                                     x_return_status => l_return_status,
                                     x_err_msg => l_error_msg);

      if(l_return_status <> fnd_api.g_ret_sts_success) then
        x_return_status := fnd_api.g_ret_sts_error;
        fnd_message.set_name('WIP', 'WIP_JDI_SER_CREATION_FAILED');
        fnd_message.set_token('INTERFACE', l_ser_rec.interface_id);
        fnd_message.set_token('MESSAGE', l_error_msg);
        if(wip_job_details.std_alone = 1) then
          wip_interface_err_Utils.add_error(p_interface_id => l_ser_rec.interface_id,
                                            p_text         => substr(fnd_message.get,1,500),
                                            p_error_type   => wip_jdi_utils.msg_error);
        else
          wip_interface_err_Utils.add_error(p_interface_id => wip_jsi_utils.current_interface_id,
                                            p_text         => substr(fnd_message.get,1,500),
                                            p_error_type   => wip_jdi_utils.msg_error);
        end if;
        update wip_job_dtls_interface wjdi
          set process_status = wip_constants.error
          where rowid = l_ser_rec.rowid;
      end if;
    end loop;
  end create_serials;

  procedure add_info_exists(p_group_id              in number,
                            p_wip_entity_id         in number,
                            p_organization_id       in number,
                            p_substitution_type     in number,
                            x_return_status        out nocopy varchar2) is
    cursor c_invalid_rows is
    select interface_id
      from wip_job_dtls_interface wjdi
     where wjdi.group_id = p_group_id
       and wjdi.process_phase = wip_constants.ml_validation
       and wjdi.process_status in (wip_constants.running,
                                   wip_constants.pending,
                                   wip_constants.warning)
       and wjdi.wip_entity_id = p_wip_entity_id
       and wjdi.organization_id = p_organization_id
       and wjdi.load_type = wip_job_details.wip_serial
       and wjdi.substitution_type = p_substitution_type
       and wjdi.serial_number_new is null;

  begin
    x_return_status := fnd_api.g_ret_sts_success;
    for l_inv_row in c_invalid_rows loop
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_message.set_name('WIP', 'WIP_JDI_NEW_SERIAL_MISSING');
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

    if(x_return_status <> fnd_api.g_ret_sts_success) then
      update wip_job_dtls_interface wjdi
        set process_status = wip_constants.error
        where group_id = p_group_id
        and process_phase = wip_constants.ml_validation
        and process_status in (wip_constants.running,
                               wip_constants.pending,
                               wip_constants.warning)
        and wip_entity_id = p_wip_entity_id
        and organization_id = p_organization_id
        and wjdi.load_type = wip_job_details.wip_serial
        and wjdi.substitution_type = p_substitution_type
        and wjdi.serial_number_new is null;
    end if;
  end add_info_exists;

  procedure unused_serial_exists(p_group_id              in number,
                                 p_wip_entity_id         in number,
                                 p_organization_id       in number,
                                 p_substitution_type     in number,
                                 x_return_status        out nocopy varchar2) is
    cursor c_invalid_rows is
    select interface_id
      from wip_job_dtls_interface wjdi
     where wjdi.group_id = p_group_id
       and wjdi.process_phase = wip_constants.ml_validation
       and wjdi.process_status in (wip_constants.running,
                                   wip_constants.pending,
                                   wip_constants.warning)
       and wjdi.wip_entity_id = p_wip_entity_id
       and wjdi.organization_id = p_organization_id
       and wjdi.load_type = wip_job_details.wip_serial
       and wjdi.substitution_type = p_substitution_type
       and not exists(select 1
                        from mtl_serial_numbers msn, wip_entities we
                       where msn.serial_number = wjdi.serial_number_new
                         and msn.current_organization_id = wjdi.organization_id
                         and msn.wip_entity_id is null
                         and msn.group_mark_id is null
                         and msn.current_status in (1,6) --defined not used /* Modified for Bug 5466955 */
                         and msn.inventory_item_id = we.primary_item_id
                         and we.wip_entity_id = p_wip_entity_id);

  begin
    x_return_status := fnd_api.g_ret_sts_success;
    for l_inv_row in c_invalid_rows loop
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_message.set_name('WIP', 'WIP_JDI_INVALID_UNUSED_SERIAL');
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

    if(x_return_status <> fnd_api.g_ret_sts_success) then
      update wip_job_dtls_interface wjdi
        set process_status = wip_constants.error
        where group_id = p_group_id
        and process_phase = wip_constants.ml_validation
        and process_status in (wip_constants.running,
                               wip_constants.pending,
                               wip_constants.warning)
        and wip_entity_id = p_wip_entity_id
        and organization_id = p_organization_id
        and wjdi.load_type = wip_job_details.wip_serial
        and wjdi.substitution_type = p_substitution_type
        and not exists(select 1
                         from mtl_serial_numbers msn, wip_entities we
                        where msn.serial_number = wjdi.serial_number_new
                          and msn.current_organization_id = wjdi.organization_id
                          and msn.wip_entity_id is null
                          and msn.group_mark_id is null
                          and msn.current_status in (1,6) --defined not used /* Modified for Bug 5466955 */
                          and msn.inventory_item_id = we.primary_item_id
                          and we.wip_entity_id = p_wip_entity_id);

    end if;
  end unused_serial_exists;

  procedure used_serial_exists(p_group_id              in number,
                               p_wip_entity_id         in number,
                               p_organization_id       in number,
                               p_substitution_type     in number,
                               x_return_status        out nocopy varchar2) is

    cursor c_invalid_rows is
    select interface_id
      from wip_job_dtls_interface wjdi
     where wjdi.group_id = p_group_id
       and wjdi.process_phase = wip_constants.ml_validation
       and wjdi.process_status in (wip_constants.running,
                                   wip_constants.pending,
                                   wip_constants.warning)
       and wjdi.wip_entity_id = p_wip_entity_id
       and wjdi.organization_id = p_organization_id
       and wjdi.load_type = wip_job_details.wip_serial
       and wjdi.substitution_type = p_substitution_type
       and not exists(select 1
                        from mtl_serial_numbers msn, wip_entities we
                       where msn.serial_number = wjdi.serial_number_old
                         and msn.current_organization_id = wjdi.organization_id
                         and msn.wip_entity_id = p_wip_entity_id
                         and msn.group_mark_id = p_wip_entity_id
                         and msn.operation_seq_num is null
                         and msn.current_status = 1 --defined not used
                         and msn.inventory_item_id = we.primary_item_id
                         and we.wip_entity_id = p_wip_entity_id);

  begin
    x_return_status := fnd_api.g_ret_sts_success;
    for l_inv_row in c_invalid_rows loop
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_message.set_name('WIP', 'WIP_JDI_INVALID_USED_SERIAL');
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

    if(x_return_status <> fnd_api.g_ret_sts_success) then
      update wip_job_dtls_interface wjdi
        set process_status = wip_constants.error
        where group_id = p_group_id
        and process_phase = wip_constants.ml_validation
        and process_status in (wip_constants.running,
                               wip_constants.pending,
                               wip_constants.warning)
        and wip_entity_id = p_wip_entity_id
        and organization_id = p_organization_id
        and wjdi.load_type = wip_job_details.wip_serial
        and wjdi.substitution_type = p_substitution_type
        and not exists(select 1
                         from mtl_serial_numbers msn, wip_entities we
                        where msn.serial_number = wjdi.serial_number_old
                          and msn.current_organization_id = wjdi.organization_id
                          and msn.wip_entity_id = p_wip_entity_id
                          and msn.group_mark_id = p_wip_entity_id
                          and msn.operation_seq_num is null
                          and msn.current_status = 1 --defined not used
                          and msn.inventory_item_id = we.primary_item_id
                          and we.wip_entity_id = p_wip_entity_id);

    end if;
  end used_serial_exists;

  procedure valid_parent_load_type(p_group_id              in number,
                                   p_wip_entity_id         in number,
                                   p_organization_id       in number,
                                   p_substitution_type     in number,
                                   x_return_status        out nocopy varchar2) is
    cursor c_invalid_rows is
    select interface_id
      from wip_job_dtls_interface wjdi
     where wjdi.group_id = p_group_id
       and wjdi.process_phase = wip_constants.ml_validation
       and wjdi.process_status in (wip_constants.running,
                                   wip_constants.pending,
                                   wip_constants.warning)
       and wjdi.wip_entity_id = p_wip_entity_id
       and wjdi.organization_id = p_organization_id
       and wjdi.substitution_type = p_substitution_type
       and wjdi.load_type = wip_job_details.wip_serial
       and not exists (select 1
                         from wip_job_schedule_interface wjsi
                        where wjsi.header_id = wjdi.parent_header_id
                          and wjsi.group_id = wjdi.group_id
                          and wjsi.load_type in (wip_constants.create_job,
                                                 wip_constants.create_ns_job,
                                                 wip_constants.resched_job));

  begin
    x_return_status := fnd_api.g_ret_sts_success;
    for l_inv_row in c_invalid_rows loop
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_message.set_name('WIP', 'WIP_JDI_SER_INV_LOAD_TYPE');
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

    if(x_return_status <> fnd_api.g_ret_sts_success) then
      update wip_job_dtls_interface wjdi
        set process_status = wip_constants.error
        where group_id = p_group_id
        and process_phase = wip_constants.ml_validation
        and process_status in (wip_constants.running,
                               wip_constants.pending,
                               wip_constants.warning)
        and wip_entity_id = p_wip_entity_id
        and organization_id = p_organization_id
        and wjdi.substitution_type = p_substitution_type
        and wjdi.load_type = wip_job_details.wip_serial
        and not exists (select 1
                          from wip_job_schedule_interface wjsi
                         where wjsi.header_id = wjdi.parent_header_id
                           and wjsi.group_id = wjdi.group_id
                           and wjsi.load_type in (wip_constants.create_job,
                                                  wip_constants.create_ns_job,
                                                  wip_constants.resched_job));
    end if;
  end valid_parent_load_type;

  procedure valid_job_exists(p_group_id              in number,
                             p_wip_entity_id         in number,
                             p_organization_id       in number,
                             p_substitution_type     in number,
                             x_return_status        out nocopy varchar2) is
    cursor c_invalid_rows is
    select interface_id
      from wip_job_dtls_interface wjdi
     where wjdi.group_id = p_group_id
       and wjdi.process_phase = wip_constants.ml_validation
       and wjdi.process_status in (wip_constants.running,
                                   wip_constants.pending,
                                   wip_constants.warning)
       and wjdi.wip_entity_id = p_wip_entity_id
       and wjdi.organization_id = p_organization_id
       and wjdi.substitution_type = p_substitution_type
       and wjdi.load_type = wip_job_details.wip_serial
       and not exists (select 1
                         from wip_job_schedule_interface wjsi, wip_discrete_jobs wdj
                        where wjsi.header_id = wjdi.parent_header_id
                          and wjsi.group_id = wjdi.group_id
                          and wjsi.wip_entity_id = wdj.wip_entity_id
                          and wdj.serialization_start_op is not null
                          and wdj.status_type in (wip_constants.unreleased,
                                                  wip_constants.released,
                                                  wip_constants.hold,
                                                  wip_constants.comp_chrg));

  begin
    x_return_status := fnd_api.g_ret_sts_success;
    for l_inv_row in c_invalid_rows loop
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_message.set_name('WIP', 'WIP_JDI_SER_JOB_STATUS');
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

    if(x_return_status <> fnd_api.g_ret_sts_success) then
      update wip_job_dtls_interface wjdi
        set process_status = wip_constants.error
        where group_id = p_group_id
        and process_phase = wip_constants.ml_validation
        and process_status in (wip_constants.running,
                               wip_constants.pending,
                               wip_constants.warning)
        and wip_entity_id = p_wip_entity_id
        and organization_id = p_organization_id
        and wjdi.substitution_type = p_substitution_type
        and wjdi.load_type = wip_job_details.wip_serial
       and not exists (select 1
                         from wip_discrete_jobs wdj
                        where wjdi.wip_entity_id = wdj.wip_entity_id
                          and wdj.serialization_start_op is not null
                          and wdj.status_type in (wip_constants.unreleased,
                                                  wip_constants.released,
                                                  wip_constants.hold,
                                                  wip_constants.comp_chrg));
    end if;
  end valid_job_exists;
end wip_serial_assoc_validations;

/

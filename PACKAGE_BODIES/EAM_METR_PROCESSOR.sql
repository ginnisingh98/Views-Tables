--------------------------------------------------------
--  DDL for Package Body EAM_METR_PROCESSOR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_METR_PROCESSOR" AS
/* $Header: EAMETRPB.pls 115.5 2003/11/20 01:12:56 lllin ship $ */

  procedure start_processing(p_group_id in number,
                             p_retcode out NOCOPY varchar2);
  procedure process_one_meter_data(p_group_id in number,
                                   p_meter_id in number,
                                   p_retcode  out NOCOPY varchar2);
  procedure insert_one_row(p_rowid rowid);
  procedure end_processing(p_group_id in number);


  procedure process_meter_reading_requests(
                   errbuf     out NOCOPY varchar2,
                   retcode    out NOCOPY varchar2,
                   p_group_id in number,
                   p_commit   in boolean default true) is
    cursor allmeters is
      select distinct meter_id
        from eam_meter_readings_interface
       where group_id = p_group_id
         and process_phase = WIP_CONSTANTS.ML_VALIDATION
         and process_status = WIP_CONSTANTS.RUNNING;

    x_meter_id number;
    x_retcode varchar2(1);
    x_has_error boolean := false;
    x_all_error boolean := true;
  begin
    retcode := '0';
    start_processing(p_group_id, retcode);
    if ( retcode = '2' ) then
      errbuf := 'The meter entity information provides are all incorrect. ' ||
                'Please come back after correct them.';
      return;
    end if;

    open allmeters;
    LOOP
      fetch allmeters into x_meter_id;
      EXIT WHEN ( allmeters%NOTFOUND );
      process_one_meter_data(p_group_id, x_meter_id, x_retcode);
      if ( x_retcode = '2' ) then
        x_has_error := true;
      else
        x_all_error := false;
      end if;
    END LOOP;
    close allmeters;

    end_processing(p_group_id);

    if ( x_all_error AND retcode = '2') then
      retcode := '2';
    elsif ( x_has_error OR retcode = '1') then
      retcode := '1';
    else
      retcode := '0';
    end if;

    if ( retcode <> '0' ) then
      errbuf := 'Please go to meter reading interface form to check the problems.';
    end if;

    if ( p_commit ) then
      commit;
    end if;
  end process_meter_reading_requests;


  procedure start_processing(p_group_id in number,
                             p_retcode out NOCOPY varchar2) is
    cursor allrows is
      select rowid, interface_id
        from eam_meter_readings_interface
       where group_id = p_group_id
         and process_phase = WIP_CONSTANTS.ML_VALIDATION
         and process_status = WIP_CONSTANTS.RUNNING;

    x_current_rowid rowid;
    x_interface_id number;
    x_retcode varchar2(1);
    x_has_error boolean := false;
    x_all_error boolean := true;
  begin
    p_retcode := '0';
    -- generates the interface id and lock the rows
    update eam_meter_readings_interface
       set interface_id = wip_interface_s.nextval,
           process_status = WIP_CONSTANTS.RUNNING
     where group_id = p_group_id
       and process_phase = WIP_CONSTANTS.ML_VALIDATION
       and process_status = WIP_CONSTANTS.PENDING;

    -- validate meter name and meter id field for all rows.
    open allrows;
    LOOP
      fetch allrows into x_current_rowid, x_interface_id;
      EXIT WHEN ( allrows%NOTFOUND );
      eam_metr_validator.meter_name(x_current_rowid, x_interface_id, x_retcode);
      if ( x_retcode = '2' ) then
        x_has_error := true;
      else
        x_all_error := false;
      end if;
      eam_metr_validator.meter_id(x_current_rowid, x_interface_id, x_retcode);
      if ( x_retcode = '2' ) then
        x_has_error := true;
      elsif ( x_retcode <> '#' ) then
        x_all_error := false;
      end if;

      if ( x_all_error ) then
        p_retcode := '2';
      elsif ( x_has_error ) then
        p_retcode := '1';
      else
        p_retcode := '0';
      end if;
    END LOOP;
    close allrows;
  end start_processing;


  procedure process_one_meter_data(p_group_id in number,
                                   p_meter_id in number,
                                   p_retcode  out NOCOPY varchar2) is
    cursor meter is
      select rowid, interface_id, disable_flag, meter_id, reading_date
        from eam_meter_readings_interface
       where group_id = p_group_id
         and meter_id = p_meter_id
         and process_phase = WIP_CONSTANTS.ML_VALIDATION
         and process_status = WIP_CONSTANTS.RUNNING
             order by reading_date;

    x_rowid rowid;
    x_interface_id number;
    l_disable_flag varchar2(1);
    l_msg_count number;
    l_msg_data varchar2(5000);
    l_return_status varchar2(1);
    l_meter_id number;
    l_reading_date date;
  begin
    p_retcode := '0';
    open meter;
    LOOP
      fetch meter into x_rowid, x_interface_id, l_disable_flag, l_meter_id, l_reading_date;
      EXIT WHEN ( meter%NOTFOUND );

      savepoint eam_meter_reading_start;

      eam_metr_validator.validate(x_rowid, x_interface_id);

      -- check to see whether the current record errors out or not
      -- due the validation
      if ( eam_int_utils.has_errors ) then
        -- rollback the default, etc.
        rollback to savepoint eam_meter_reading_start;
        -- set the error status for the current record
        update eam_meter_readings_interface
           set process_status = WIP_CONSTANTS.ERROR
         where rowid = x_rowid;
        -- set the return code
        p_retcode := '2';
      else
        -- if the row passed validation, then we set the process phase
        -- and then do the insertion
        update eam_meter_readings_interface
           set process_phase = WIP_CONSTANTS.ML_INSERTION
         where rowid = x_rowid;

        if (l_disable_flag is not null and l_disable_flag='Y') then
                eam_meterreading_pub.disable_meter_reading
                (p_api_version =>1.0,
                x_msg_count => l_msg_count,
                x_msg_data => l_msg_data,
                x_return_status=> l_return_status,
                p_meter_id=>l_meter_id,
                p_meter_reading_date=> l_reading_date);


                if (l_return_status <> 'S') then
                        fnd_message.set_name('EAM', 'EAM_METINT_DISABLE_ERROR');                        eam_int_utils.record_error(x_interface_id,
                                 fnd_message.get,
                                 FALSE);
                        update eam_meter_readings_interface
                        set process_phase = WIP_CONSTANTS.ML_VALIDATION,
                            process_status =  WIP_CONSTANTS.ERROR
                        where rowid = x_rowid;
                else
                        update eam_meter_readings_interface
                        set process_phase = WIP_CONSTANTS.ML_COMPLETE,
                        process_status = WIP_CONSTANTS.COMPLETED
                        where rowid = x_rowid;
                end if;
        else
        	insert_one_row(x_rowid);

        	update eam_meter_readings_interface
           	set process_phase = WIP_CONSTANTS.ML_COMPLETE,
               	process_status = WIP_CONSTANTS.COMPLETED
         	where rowid = x_rowid;
      	end if;
      end if;

      eam_int_utils.load_errors('eam_meter_readings_interface');
    END LOOP;
    close meter;

  end process_one_meter_data;


  procedure insert_one_row(p_rowid rowid) is
  begin
    insert into eam_meter_readings(
      meter_reading_id,
      meter_id,
      current_reading,
      current_reading_date,
      reset_flag,
      life_to_date_reading,
      wip_entity_id,
      description,
      source_line_id,
      source_code,
      created_by,
      creation_date,
      last_update_login,
      last_update_date,
      last_updated_by,
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
      disable_flag
    )
    select eam_meter_readings_s.nextval,
           meter_id,
           reading_value,
           reading_date,
           reset_flag,
           life_to_date_reading,
           wip_entity_id,
           description,
           source_line_id,
           source_code,
           created_by,
           creation_date,
           last_update_login,
           last_update_date,
           last_updated_by,
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
	   disable_flag
      from eam_meter_readings_interface
     where rowid = p_rowid;

  end insert_one_row;


  procedure end_processing(p_group_id in number) is
  begin
    -- delete completed records
    delete from wip_interface_errors
     where interface_id in
           (select interface_id
              from eam_meter_readings_interface
             where process_phase = WIP_CONSTANTS.ML_COMPLETE
               and group_id = p_group_id
               and process_status = WIP_CONSTANTS.COMPLETED);

    delete from eam_meter_readings_interface
     where process_phase = WIP_CONSTANTS.ML_COMPLETE
      and group_id = p_group_id
      and process_status = WIP_CONSTANTS.COMPLETED;

  end end_processing;

END eam_metr_processor;

/

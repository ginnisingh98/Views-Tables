--------------------------------------------------------
--  DDL for Package Body EAM_METR_VALIDATOR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_METR_VALIDATOR" AS
/* $Header: EAMETRVB.pls 115.10 2004/02/21 00:34:53 lllin ship $ */

  procedure validate(p_current_rowid in rowid,
                     p_interface_id in number) is
	l_disable_flag varchar2(1);
  begin
    select disable_flag into l_disable_flag
    from eam_meter_readings_interface
    where rowid=p_current_rowid;

    if (l_disable_flag is null or l_disable_flag='N') then
        populate_reading(p_current_rowid, p_interface_id);
        reading_date(p_current_rowid, p_interface_id);
        reading_values(p_current_rowid, p_interface_id);
    end if;

    last_updated_by_name(p_current_rowid, p_interface_id);
    created_by_name(p_current_rowid, p_interface_id);
    populate_who(p_current_rowid, p_interface_id);
    last_updated_by(p_current_rowid, p_interface_id);
    created_by(p_current_rowid, p_interface_id);

    organization_code(p_current_rowid, p_interface_id);
    organization_id(p_current_rowid, p_interface_id);
    work_order_name_id(p_current_rowid, p_interface_id);
    reset_flag(p_current_rowid, p_interface_id);

  end validate;

  procedure populate_reading(p_current_rowid in rowid,
                             p_interface_id in number) is
        l_current_reading number;
        l_reading_change number;
        l_meter_id number;
        l_last_reading number;
        l_retcode varchar2(1);
        l_reading_date date;
        l_last_reading_date date;
  begin
        meter_name(p_current_rowid => p_current_rowid,
                   p_interface_id => p_interface_id,
                   p_retcode => l_retcode);
        if (l_retcode='2') then
          FND_Message.set_name('EAM', 'EAM_METINT_MISSING_MT_INFO');
          eam_int_utils.record_error(p_interface_id, FND_Message.get, FALSE);
        end if;

        select reading_value, reading_change, meter_id, reading_date
        into l_current_reading, l_reading_change, l_meter_id, l_reading_date
        from eam_meter_readings_interface
        where rowid=p_current_rowid;

        if (l_current_reading is null) then
          if (l_reading_change is null) then
            FND_Message.set_name('EAM', 'EAM_METINT_MISSING_READING');
            eam_int_utils.record_error(p_interface_id, FND_Message.get, FALSE);
          else
                  select max(current_reading_date) into l_last_reading_date
                  from eam_meter_readings
                  where meter_id=l_meter_id
                  and current_reading_date < l_reading_date
		  and (disable_flag is null or disable_flag = 'N');

                if (l_last_reading_date is not null) then
                        select current_reading into l_last_reading
                        from eam_meter_readings
                        where meter_id = l_meter_id
                        and current_reading_date=l_last_reading_date
			and (disable_flag is null or disable_flag = 'N');
                else
                        l_last_reading:=0;
                end if;

                l_current_reading:=l_last_reading+l_reading_change;

              update eam_meter_readings_interface
                set reading_value=l_current_reading
                where rowid=p_current_rowid;
          end if;
        end if;
  exception
        when no_data_found then
          FND_Message.set_name('EAM', 'EAM_METINT_MISSING_READING');
          eam_int_utils.record_error(p_interface_id, FND_Message.get, FALSE);
  end populate_reading;

  procedure populate_who(p_current_rowid in rowid,
                         p_interface_id in number) is
        l_user_id number;
        l_created_by number;
        l_last_updated_by number;
        l_creation_date date;
        l_last_update_date date;
  begin
        l_user_id:=fnd_global.user_id;
        select created_by, last_updated_by, creation_date, last_update_date
        into l_created_by, l_last_updated_by, l_creation_date, l_last_update_date
        from eam_meter_readings_interface
        where rowid=p_current_rowid;

        IF (l_created_by IS NOT NULL
           AND l_last_updated_by IS NOT NULL
           AND l_creation_date IS NOT NULL
           AND l_last_update_date IS NOT NULL)
        THEN
            RETURN;
        END IF;

        if (l_created_by is null) then
                l_created_by:=fnd_global.user_id;
        end if;

        if (l_last_updated_by is null) then
                l_last_updated_by:=fnd_global.user_id;
        end if;

        if (l_creation_date is null) then
                l_creation_date:=sysdate;
        end if;

        if (l_last_update_date is null) then
                l_last_update_date:=sysdate;
        end if;

        update eam_meter_readings_interface
        set created_by=l_created_by,
            last_updated_by=l_last_updated_by,
            creation_date=l_creation_date,
            last_update_date=l_last_update_date
  	WHERE rowid = p_current_rowid;
  end populate_who;


  procedure life_to_date_reading(p_current_rowid in rowid,
                                 p_interface_id in number);



  procedure last_updated_by_name(p_current_rowid in rowid,
                                 p_interface_id in number) is
  begin
    eam_int_utils.derive_id_from_code(
       p_current_rowid,
       p_interface_id,
       'eam_meter_readings_interface mri',
       'LAST_UPDATED_BY',
       'LAST_UPDATED_BY_NAME',
       '(SELECT USER_ID
           FROM FND_USER
          WHERE USER_NAME = mri.LAST_UPDATED_BY_NAME)'
    );
  end last_updated_by_name;


  procedure last_updated_by(p_current_rowid in rowid,
                            p_interface_id in number) is
  begin
    eam_mri_utils.error_if(
          p_current_rowid,
          p_interface_id,
          '((LAST_UPDATED_BY IS NULL AND LAST_UPDATED_BY_NAME IS NULL)
            OR NOT EXISTS
                (SELECT 1
                 FROM FND_USER FU
                 WHERE USER_ID = mri.LAST_UPDATED_BY
                 AND SYSDATE BETWEEN FU.START_DATE AND
                             NVL(FU.END_DATE,SYSDATE+1)))',
          'WIP',
          'WIP_ML_LAST_UPDATED_BY');
  end last_updated_by;


  procedure created_by_name(p_current_rowid in rowid,
                            p_interface_id in number) is
  begin
    eam_int_utils.derive_id_from_code(
       p_current_rowid,
       p_interface_id,
       'eam_meter_readings_interface mri',
       'CREATED_BY',
       'CREATED_BY_NAME',
       '(SELECT USER_ID
           FROM FND_USER
          WHERE USER_NAME = mri.LAST_UPDATED_BY_NAME)'
    );
  end created_by_name;


  procedure created_by(p_current_rowid in rowid,
                       p_interface_id in number) is
  begin
     eam_mri_utils.error_if(
          p_current_rowid,
          p_interface_id,
          '((CREATED_BY IS NULL AND CREATED_BY_NAME IS NULL)
            OR NOT EXISTS
                (SELECT 1
                 FROM FND_USER FU
                 WHERE USER_ID = mri.CREATED_BY
                 AND SYSDATE BETWEEN FU.START_DATE AND
                             NVL(FU.END_DATE,SYSDATE+1)))',
          'WIP',
          'WIP_ML_CREATED_BY');
  end created_by;


  procedure organization_code(p_current_rowid in rowid,
                              p_interface_id in number) is
    x_org_code varchar2(3);
    x_eam_enabled varchar2(1) := null;
  begin
    select organization_code into x_org_code
    from eam_meter_readings_interface
    where rowid = p_current_rowid;

    if ( x_org_code is null ) then
      return;
    end if;

    -- check if the org is EAM enabled
    select eam_enabled_flag
    into x_eam_enabled
    from mtl_parameters
    where organization_code = x_org_code;

    if (nvl(x_eam_enabled, 'N') = 'N') then
      fnd_message.set_name('EAM', 'EAM_ORG_EAM_ENABLED');
      eam_int_utils.record_error(p_interface_id,
                                 fnd_message.get,
                                 FALSE);
    end if;

    eam_int_utils.derive_id_from_code(
       p_current_rowid,
       p_interface_id,
       'eam_meter_readings_interface mri',
       'ORGANIZATION_ID',
       'ORGANIZATION_CODE',
       '(SELECT ORGANIZATION_ID
           FROM ORG_ORGANIZATION_DEFINITIONS
          WHERE ORGANIZATION_CODE = MRI.ORGANIZATION_CODE)',
       FALSE
    );
  exception
    when others then
      fnd_message.set_name('EAM', 'EAM_MR_ORG_INFO_MISSING');
      eam_int_utils.record_error(p_interface_id,
                                 fnd_message.get,
                                 FALSE);
  end organization_code;


  procedure organization_id(p_current_rowid in rowid,
                            p_interface_id in number) is
    x_org_id number := null;
    x_eam_enabled varchar2(1) := null;
  begin
    select organization_id into x_org_id
      from eam_meter_readings_interface
     where rowid = p_current_rowid;
    if ( x_org_id is null ) then
      return;
    end if;

    -- check if the org is EAM enabled
    select eam_enabled_flag
    into x_eam_enabled
    from mtl_parameters
    where organization_id = x_org_id;

    if (nvl(x_eam_enabled, 'N') = 'N') then
      fnd_message.set_name('EAM', 'EAM_ORG_EAM_ENABLED');
      eam_int_utils.record_error(p_interface_id,
                                 fnd_message.get,
                                 FALSE);
    end if;


    eam_mri_utils.error_if(
          p_current_rowid,
          p_interface_id,
          '(NOT EXISTS (SELECT 1
                          FROM ORG_ORGANIZATION_DEFINITIONS
                         WHERE ORGANIZATION_ID= MRI.ORGANIZATION_ID)
            OR TRUNC(SYSDATE) > (SELECT NVL(DISABLE_DATE, SYSDATE + 1)
                                 FROM  ORG_ORGANIZATION_DEFINITIONS
                                 WHERE ORGANIZATION_ID = MRI.ORGANIZATION_ID)
          )',
          'WIP',
          'WIP_ML_ORGANIZATION_ID');
  exception
    when others then
      fnd_message.set_name('EAM', 'EAM_MR_ORG_INFO_MISSING');
      eam_int_utils.record_error(p_interface_id,
                                 fnd_message.get,
                                 FALSE);
  end organization_id;


  procedure work_order_name_id(p_current_rowid in rowid,
                               p_interface_id in number) is
    x_org_id number := null;
    x_work_order_name varchar2(240) := null;
    x_wip_entity_id number := null;
  begin
    select organization_id,
           work_order_name,
           wip_entity_id
      into x_org_id,
           x_work_order_name,
           x_wip_entity_id
      from eam_meter_readings_interface
     where rowid = p_current_rowid;

    if ( x_work_order_name is not null AND
         x_wip_entity_id is null AND
         x_org_id is null ) then
      fnd_message.set_name('EAM', 'EAM_MR_ORG_INFO_MISSING');
      eam_int_utils.record_error(p_interface_id,
                                 fnd_message.get,
                                 FALSE);
    end if;

    eam_int_utils.derive_id_from_code(
       p_current_rowid,
       p_interface_id,
       'eam_meter_readings_interface mri',
       'WIP_ENTITY_ID',
       'WORK_ORDER_NAME',
       '(SELECT WIP_ENTITY_ID
           FROM WIP_ENTITIES
          WHERE ORGANIZATION_ID = MRI.ORGANIZATION_ID
            AND WIP_ENTITY_NAME = MRI.WORK_ORDER_NAME)',
       FALSE
    );

    -- now make sure that wip entity id is valid if not null
    x_wip_entity_id := null;
    select wip_entity_id
      into x_wip_entity_id
      from eam_meter_readings_interface
     where rowid = p_current_rowid;
    if ( x_wip_entity_id is null ) then
      return;
    end if;

    if ( NOT eam_int_utils.request_matches_condition(
               p_current_rowid,
               p_interface_id,
               'eam_meter_readings_interface mri',
               'exists (select 1
                          from wip_discrete_jobs wdj, eam_asset_meters eam, wip_entities we
                         where wdj.wip_entity_id = mri.wip_entity_id
                         	and wdj.organization_id = mri.organization_id
                         	and we.organization_id = mri.organization_id
                         	and eam.organization_id = mri.organization_id
                         	and eam.asset_number = wdj.asset_number
                         	and eam.asset_group_id = wdj.asset_group_id
                         	and eam.meter_id = mri.meter_id
                         	and we.wip_entity_id = wdj.wip_entity_id)') ) then
      eam_int_utils.record_invalid_column_error(
                      p_interface_id,
                      'WIP_ENTITY_ID');
    end if;

  end work_order_name_id;


  procedure meter_name(p_current_rowid in rowid,
                       p_interface_id in number,
                       p_retcode out NOCOPY varchar2) is
  begin
    p_retcode := '0';
    eam_int_utils.derive_id_from_code(
       p_current_rowid,
       p_interface_id,
       'eam_meter_readings_interface mri',
       'METER_ID',
       'METER_NAME',
       '(SELECT METER_ID
           FROM EAM_METERS
          WHERE METER_NAME = MRI.METER_NAME
            AND MRI.READING_DATE BETWEEN
                NVL(FROM_EFFECTIVE_DATE, MRI.READING_DATE-1)
                AND NVL(TO_EFFECTIVE_DATE, MRI.READING_DATE+1))'
    );

    eam_int_utils.derive_code_from_id(
           p_current_rowid,
           p_interface_id,
           'eam_meter_readings_interface mri',
           'METER_ID',
           'METER_NAME',
           '(SELECT METER_NAME
               FROM EAM_METERS
              WHERE METER_ID = MRI.METER_ID
                AND MRI.READING_DATE BETWEEN
                    NVL(FROM_EFFECTIVE_DATE, MRI.READING_DATE-1)
                    AND NVL(TO_EFFECTIVE_DATE, MRI.READING_DATE+1))'
    );

    if ( eam_int_utils.has_errors ) then
      eam_int_utils.load_errors('eam_meter_readings_interface');
      update eam_meter_readings_interface
         set process_status = WIP_CONSTANTS.ERROR,
             process_phase = WIP_CONSTANTS.ML_VALIDATION
       where rowid = p_current_rowid;
       p_retcode := '2';
    end if;
  end meter_name;


  procedure meter_id(p_current_rowid in rowid,
                     p_interface_id in number,
                     p_retcode out NOCOPY varchar2) is
    x_meter_name varchar2(30) := null;
  begin
    p_retcode := '0';

    select meter_name into x_meter_name
    from eam_meter_readings_interface
    where rowid = p_current_rowid;
    -- if meter name is already specified, then we don't need to
    -- validate it again.
    if ( x_meter_name is not null ) then
      		p_retcode := '#';
      		return;
    end if;

    eam_mri_utils.error_if(
          p_current_rowid,
          p_interface_id,
          '(NOT EXISTS
                 (SELECT METER_ID
                    FROM EAM_METERS
                   WHERE METER_NAME = MRI.METER_NAME
                     AND MRI.READING_DATE BETWEEN
                     NVL(FROM_EFFECTIVE_DATE, MRI.READING_DATE-1)
                       AND NVL(TO_EFFECTIVE_DATE, MRI.READING_DATE+1)))',
          'EAM',
          'EAM_MR_INVALID_METER');

    if ( eam_int_utils.has_errors ) then
      		eam_int_utils.load_errors('eam_meter_readings_interface');
      		update eam_meter_readings_interface
        	set process_status = WIP_CONSTANTS.ERROR,
        	process_phase = WIP_CONSTANTS.ML_VALIDATION
       		where rowid = p_current_rowid;
      		p_retcode := '2';
    end if;

  end meter_id;


  procedure reading_date(p_current_rowid in rowid,
                         p_interface_id in number) is
  begin
    eam_mri_utils.error_if(
          p_current_rowid,
          p_interface_id,
          '(MRI.READING_DATE >  SYSDATE
            OR NOT EXISTS
             (SELECT 1
                FROM EAM_METERS EM
               WHERE EM.METER_ID = MRI.METER_ID
                 AND MRI.READING_DATE BETWEEN
                     NVL(EM.FROM_EFFECTIVE_DATE, MRI.READING_DATE-1)
                      AND NVL(EM.TO_EFFECTIVE_DATE, MRI.READING_DATE+1)))',
          'EAM',
          'EAM_MR_INVALID_READING_DATE'
          );
    eam_mri_utils.error_if(
         p_current_rowid,
         p_interface_id,
         '(EXISTS (SELECT 1
                     FROM EAM_METER_READINGS EM
                    WHERE EM.METER_ID = MRI.METER_ID
                      AND EM.CURRENT_READING_DATE = MRI.READING_DATE
		      AND (EM.DISABLE_FLAG IS NULL OR DISABLE_FLAG = ''N'')))',
         'EAM',
         'EAM_SAME_READING_DATE_EXIST'
         );
  end reading_date;


  procedure reset_flag(p_current_rowid in rowid,
                       p_interface_id in number) is
    x_meter_id number;
    x_reading_date date;
    x_ltd number := null;
    x_reset_flag varchar2(1);
  begin
    -- if it is reset and there is any meter reading data in the history table
    -- that are after the reset, then we error out.
    eam_mri_utils.error_if(
          p_current_rowid,
          p_interface_id,
          '((RESET_FLAG = ''Y''
             AND EXISTS
              (SELECT 1
                 FROM EAM_METER_READINGS MR
                WHERE MR.METER_ID = MRI.METER_ID
                  AND MR.CURRENT_READING_DATE > MRI.READING_DATE
		  AND (MR.DISABLE_FLAG IS NULL OR MR.DISABLE_FLAG=''N''))))',
          'EAM',
          'EAM_MR_RESET_NOT_ALLOWED'
          );

     eam_int_utils.warn_irrelevant_column(
                     p_current_rowid,
                     p_interface_id,
                     'eam_meter_readings_interface mri',
                     'LIFE_TO_DATE_READING',
                     'mri.reset_flag = ''Y''');

    -- now default the life to date reading to the previous entry
    begin
      select meter_id,
             reading_date,
             reset_flag
        into x_meter_id,
             x_reading_date,
             x_reset_flag
        from eam_meter_readings_interface
       where rowid = p_current_rowid;

      if ( x_reset_flag is null OR x_reset_flag <> 'Y' ) then
        return;
      end if;

      select life_to_date_reading
        into x_ltd
        from eam_meter_readings
       where meter_id = x_meter_id
         and current_reading_date =
             (select max(current_reading_date)
               from eam_meter_readings
              where meter_id = x_meter_id
                and current_reading_date < x_reading_date
		and (disable_flag is null or disable_flag='N'))
	 and (disable_flag is null or disable_flag='N');
    exception when others then
       x_ltd := null;
    end;

    if ( x_ltd is null ) then
      fnd_message.set_name('EAM', 'EAM_NO_PREV_READING_LTD');
      eam_int_utils.record_error(p_interface_id,
                                 fnd_message.get,
                                 FALSE);
    else
      update eam_meter_readings_interface
         set life_to_date_reading = x_ltd
       where rowid = p_current_rowid;
    end if;
  end reset_flag;


  /**
   * This method do the validation and set the corresponding ltd reading if null.
   */
  procedure reading_values(p_current_rowid in rowid,
                           p_interface_id in number) is
    x_meter_id number := null;
    x_meter_type number := 1;
    l_ltd number;
    x_reading_date date := null;
    x_reading_value number := null;
    x_life_to_date_reading number := null;
    x_value_change_dir number := null;
    x_pre_reading number := null;
    x_next_reading number := null;
    x_rule_broken boolean := false;
    x_pre_ltd number := null;
    x_pre_rowid rowid;
    x_next_rowid rowid;
    x_next_ltd number;
    x_ltd_defaulted boolean := false;
  begin
    -- if both life to date reading and reading value are provided even if
    -- it is not resetting, we ignore the reading value field. Normally, this
    -- would rarely happen.
    eam_int_utils.warn_redundant_column(
           p_current_rowid,
           p_interface_id,
           'eam_meter_readings_interface',
           'life_to_date_reading',
           'reading_value',
           'reset_flag <> ''Y''');

    select mri.reading_value,
           mri.life_to_date_reading,
           mri.meter_id,
           nvl(em.meter_type, 1),
           mri.reading_date,
           em.value_change_dir
      into x_reading_value,
           x_life_to_date_reading,
           x_meter_id,
           x_meter_type,
           x_reading_date,
           x_value_change_dir
      from eam_meter_readings_interface mri,
           eam_meters em
     where mri.meter_id = em.meter_id
       and mri.rowid = p_current_rowid;



    -- if x_life_to_date_reading is not null, then we use it instead of
    -- reading value provided. The validation will be done there.

    -- commented due to bug 2156306
    --if ( x_life_to_date_reading is null ) then
      begin
        select rowid
          into x_pre_rowid
          from eam_meter_readings
         where meter_id = x_meter_id and
               current_reading_date =
               (select max(current_reading_date)
                  from eam_meter_readings
                 where meter_id = x_meter_id
                   and current_reading_date < x_reading_date
		   and (disable_flag is null or disable_flag='N'));

      exception when others then
        --dbms_output.put_line('some exception');
        x_pre_rowid := null;
      end;

      if ( x_pre_rowid is not null ) then
        select current_reading, life_to_date_reading
          into x_pre_reading, x_pre_ltd
          from eam_meter_readings
         where rowid = x_pre_rowid;
      else
        x_pre_reading := null;
         --dbms_output.put_line('null???');
      end if;

      begin
        select rowid
          into x_next_rowid
          from eam_meter_readings
         where current_reading_date =
               (select min(current_reading_date)
                  from eam_meter_readings
                 where meter_id = x_meter_id
                   and current_reading_date > x_reading_date
		   and (disable_flag is null or disable_flag = 'N'));

      exception when others then
        x_next_rowid := null;
      end;

      if ( x_next_rowid is not null ) then
        select current_reading, life_to_date_reading
          into x_next_reading, x_next_ltd
          from eam_meter_readings
         where rowid = x_next_rowid;
      else
        x_next_reading := null;
      end if;

--    dbms_output.put_line('here');
      l_ltd := eam_meters_util.calculate_ltd(x_meter_id,
       x_reading_date, x_reading_value, x_meter_type);
      if ( x_pre_reading is not null ) then
--       dbms_output.put_line('here 1');
        if(x_meter_type = 1) then
          if ( (x_value_change_dir = 1 AND x_pre_reading > x_reading_value)
               OR (x_value_change_dir = 2 AND x_pre_reading < x_reading_value) ) then
            x_rule_broken := true;
          end if;
        elsif (x_meter_type = 2) then
          if ( (x_value_change_dir = 1 AND x_reading_value < 0)
               OR (x_value_change_dir = 2 AND x_reading_value > 0) ) then
            x_rule_broken := true;
          end if;

        end if;
        -- default the ltd reading


        update eam_meter_readings_interface
--           set life_to_date_reading = x_pre_ltd + x_reading_value - x_pre_reading
        set life_to_date_reading = l_ltd
        where rowid = p_current_rowid;
        x_ltd_defaulted := true;
      end if;

      if ( x_next_reading is not null ) then
        if(x_meter_type = 1) then
          if ( (x_value_change_dir = 1 AND x_next_reading < x_reading_value)
             OR (x_value_change_dir = 2 AND x_next_reading > x_reading_value) ) then
          x_rule_broken := true;
          end if;
        elsif (x_meter_type = 2) then
          if ( (x_value_change_dir = 1 AND x_reading_value < 0)
               OR (x_value_change_dir = 2 AND x_reading_value > 0) ) then
            x_rule_broken := true;
          end if;

        end if;

        -- default the ltd reading
        if ( NOT x_ltd_defaulted ) then

          update eam_meter_readings_interface
             --set life_to_date_reading = x_next_ltd + x_reading_value - x_next_reading
           set life_to_date_reading = l_ltd
           where rowid = p_current_rowid;
          x_ltd_defaulted := true;
        end if;
      end if;

      if ( NOT x_ltd_defaulted ) then
        update eam_meter_readings_interface
--           set life_to_date_reading = x_reading_value
        set life_to_date_reading = l_ltd
         where rowid = p_current_rowid;
      end if;

      if ( x_rule_broken ) then
   	fnd_message.set_name('EAM', 'EAM_MR_VALUE_BREAK_PATTERN');
        eam_int_utils.record_error(p_interface_id,
                                   fnd_message.get,
                                   true);

/*
         eam_int_utils.record_error(p_interface_id,
                                    fnd_message.get,
                                    false);
*/
      end if;

    -- commented due to bug 2156306
    -- end if;

  end reading_values;


  /**
   * This method will be called only when ltd column is not null.
   * This method is deprecated. It's not being called anywhere
   */
  procedure life_to_date_reading(p_current_rowid in rowid,
                                 p_interface_id in number) is
    x_reset_flag varchar2(1) := null;
    x_ltd_reading number := null;
    x_reading_date date := null;
    x_pre_ltd number := null;
    x_pre_reading number := null;
    x_pre_rowid rowid;
    x_next_ltd number := null;
    x_next_reading number := null;
    x_next_rowid rowid;
    x_meter_id number := null;
    x_value_change_dir number := null;
    x_rule_broken boolean := false;
    x_defaulted boolean := false;
  begin
    select mri.life_to_date_reading,
           mri.reading_date,
           mri.reset_flag,
           mri.meter_id,
           em.value_change_dir
      into x_ltd_reading,
           x_reading_date,
           x_reset_flag,
           x_meter_id,
           x_value_change_dir
      from eam_meter_readings_interface mri,
           eam_meters em
     where mri.meter_id = em.meter_id
       and mri.rowid = p_current_rowid;

    begin
      select rowid
        into x_pre_rowid
        from eam_meter_readings
       where current_reading_date =
            (select max(current_reading_date)
               from eam_meter_readings
              where meter_id = x_meter_id
                and current_reading_date < x_reading_date
		and (disable_flag is null or disable_flag='N'));

     exception when others then
       x_pre_rowid := null;
     end;

     if ( x_pre_rowid is not null ) then
       select current_reading, life_to_date_reading
         into x_pre_reading, x_pre_ltd
         from eam_meter_readings
        where rowid = x_pre_rowid;
     else
       x_pre_ltd := null;
     end if;


    begin
      select rowid
        into x_next_rowid
        from eam_meter_readings
       where current_reading_date =
             (select min(current_reading_date)
                from eam_meter_readings
               where meter_id = x_meter_id
                 and current_reading_date > x_reading_date
	         and (disable_flag is null or disable_flag='N'));

    exception when others then
      x_next_rowid := null;
    end;

    if ( x_next_rowid is not null ) then
      select life_to_date_reading, current_reading
        into x_next_ltd, x_next_reading
        from eam_meter_readings
       where rowid = x_next_rowid;
    else
      x_next_ltd := null;
    end if;

    if ( x_pre_ltd is not null ) then
      if ( (x_value_change_dir = 1 AND x_pre_ltd > x_ltd_reading)
           OR (x_value_change_dir = 2 AND x_pre_reading < x_ltd_reading) ) then
        x_rule_broken := true;
      end if;
      if ( x_reset_flag <> 'Y' ) then
        update eam_meter_readings_interface
           set reading_value = x_pre_reading + x_ltd_reading - x_pre_ltd
         where rowid = p_current_rowid;
        x_defaulted := true;
      end if;
    end if;

    if ( x_next_ltd is not null ) then
      if ( (x_value_change_dir = 1 AND x_next_ltd < x_ltd_reading)
           OR (x_value_change_dir = 2 AND x_next_ltd > x_ltd_reading) ) then
        x_rule_broken := true;
      end if;
      if ( x_reset_flag <> 'Y' AND (NOT x_defaulted) ) then
        update eam_meter_readings_interface
           set reading_value = x_next_reading + x_ltd_reading - x_next_ltd
         where rowid = p_current_rowid;
      end if;
    end if;

    if ( x_rule_broken ) then
      fnd_message.set_name('EAM', 'EAM_MR_LTD_BREAK_PATTERN');
      eam_int_utils.record_error(p_interface_id,
                                 fnd_message.get,
                                 true);
    end if;

  end life_to_date_reading;

END eam_metr_validator;


/

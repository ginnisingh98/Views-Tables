--------------------------------------------------------
--  DDL for Package Body EAM_METER_READINGS_JSP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_METER_READINGS_JSP" AS
/* $Header: EAMMRRJB.pls 115.8 2002/11/19 23:53:49 aan ship $ */
G_PKG_NAME              CONSTANT VARCHAR2(30) := 'EAM_METER_READINGS_JSP';

-------------------------------------------------------------------------------
-- check if work order has mandatory meter reading
  FUNCTION has_mandatory_meter_reading( p_wip_entity_id in number) RETURN VARCHAR2
  IS
    -- return if job has mandatory meter reading, wrapper function
    ret BOOLEAN;
  BEGIN
    ret := eam_meters_util.has_mandatory_meter_reading(p_wip_entity_id);
    IF ret THEN
      return 'Y';
    ELSE
      return 'N';
    END IF;
  END has_mandatory_meter_reading;

-------------------------------------------------------------------------------
-- check if meter is mandatory
  FUNCTION is_meter_reading_mandatory( p_wip_entity_id in number, p_meter_id in number) RETURN VARCHAR2
  IS
    -- return if job has mandatory meter reading, wrapper function
    ret BOOLEAN;
  BEGIN
    ret := eam_meters_util.is_meter_reading_mandatory(p_wip_entity_id, p_meter_id);
    IF ret THEN
      return 'Y';
    ELSE
      return 'N';
    END IF;
  END is_meter_reading_mandatory;

-------------------------------------------------------------------------------
-- get the last reading's meter reading id of a meter
  FUNCTION get_latest_meter_reading_id( p_meter_id in number) RETURN NUMBER
  IS
    -- return if job has mandatory meter reading, wrapper function
    l_meter_reading_id NUMBER;
    l_last_reading_date date;
  BEGIN

    l_meter_reading_id := null;

    -- fix for bug 2112310. Adding following two select statements for better performance
    select max(mr4.current_reading_date) into l_last_reading_date
    from  eam_meter_readings mr4
    where mr4.meter_id = p_meter_id;

    select max(meter_reading_id) as meter_reading_id into l_meter_reading_id
    from eam_meter_readings
    where meter_id = p_meter_id and
    current_reading_date = l_last_reading_date;

    /* COMMENTING DUE TO BUG 2112310
    -- first get the greatest reading date
    SELECT max(mr5.meter_reading_id) as meter_reading_id
    into l_meter_reading_id
    FROM
      eam_meter_readings mr5,
      (select max(mr4.current_reading_date) as last_reading_date
        from  eam_meter_readings mr4
        where mr4.meter_id = p_meter_id
        group by mr4.meter_id
      ) mr3
    WHERE mr5.meter_id = p_meter_id
      and mr5.current_reading_date = mr3.last_reading_date
    GROUP BY mr5.meter_id;
       END COMMENTING DUE TO BUG 2112310
    */

    return l_meter_reading_id;
  END get_latest_meter_reading_id;


-------------------------------------------------------------------------
--- insert a meter reading row into eam_meter_readings table
-------------------------------------------------------------------------
  procedure insert_row
  (
     p_meter_id               IN NUMBER
    ,p_current_reading        IN NUMBER
    ,p_current_reading_date   IN DATE
    ,p_reset_flag             IN VARCHAR2
    ,p_life_to_date_reading   IN NUMBER
    ,p_wip_entity_id          IN NUMBER
    ,p_description            IN VARCHAR2
  ) IS

  l_reading_id NUMBER;

  BEGIN

    select eam_meter_readings_s.nextval
    into l_reading_id
    from dual;

    insert into eam_meter_readings
    (
      meter_reading_id,
      meter_id,
      current_reading,
      current_reading_date,
      reset_flag,
      life_to_date_reading,
      wip_entity_id,
      description,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by
    ) values
    (
      l_reading_id,
      p_meter_id,
      p_current_reading,
      p_current_reading_date,
      p_reset_flag,
      p_life_to_date_reading,
      p_wip_entity_id,
      p_description,
      sysdate,
      g_created_by,
      sysdate,
      g_last_updated_by
    );
--  EXCEPTION WHEN OTHERS THEN

  END insert_row;

-------------------------------------------------------------------------
-- caculate current reading and current life to date reading
-------------------------------------------------------------------------
  procedure get_current_reading_data
  (
     p_reading                     IN    NUMBER
    ,p_reading_change              IN    NUMBER
    ,p_reset_flag                  IN    VARCHAR2
    ,p_meter_direction             IN    NUMBER
    ,p_before_reading              IN    NUMBER
    ,p_before_ltd_reading          IN    NUMBER
    ,p_after_reading               IN    NUMBER
    ,p_after_ltd_reading           IN    NUMBER
    ,p_reading_date                IN    DATE
    ,p_meter_name                  IN    VARCHAR2
    ,x_current_reading             OUT NOCOPY   NUMBER
    ,x_current_ltd_reading         OUT NOCOPY   NUMBER
    ,p_mtr_warning_shown           IN OUT NOCOPY VARCHAR2
--    ,x_return_status               OUT   VARCHAR2
--    ,x_msg_count                   OUT   NUMBER
--    ,x_msg_data                    OUT   VARCHAR2
  ) IS

  l_current_reading      NUMBER;
  l_current_ltd_reading  NUMBER;
  l_change               NUMBER;
  l_ltd_change_before    NUMBER; -- the amount to the next reading
  l_ltd_change_after     NUMBER; -- the amount to the next reading
  l_return_status        VARCHAR2(250);
  l_range_from           VARCHAR2(250);
  l_range_to             VARCHAR2(250);
  l_range_tmp            VARCHAR2(250);

  BEGIN
    l_current_reading := null;
    l_current_ltd_reading := null;

    l_return_status := FND_API.G_RET_STS_SUCCESS;

    -- get current reading and life to date reading
    if(nvl(p_reset_flag, 'N') = 'Y') then
    -- reset
      if( p_reading is null or p_reading_change is not null) then
        -- reset only need reading field
        eam_execution_jsp.add_message(p_app_short_name => 'EAM', p_msg_name => 'EAM_MRR_RESET_FIELDS'
          ,p_token1 => 'METER_NAME', p_value1 => p_meter_name);
        l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        -- can reset to anything
/*      elsif( (nvl(p_meter_direction, 0) < 1 or nvl(p_meter_direction, 0) > 2) ) then
           -- or
           --  (nvl(p_meter_direction, 0) = 1 and p_reading > nvl(p_before_reading, 0)) or
           --  (nvl(p_meter_direction, 0) = 2 and p_reading < nvl(p_before_reading, 0)) ) then
        -- why bother?
        eam_execution_jsp.add_message(p_app_short_name => 'EAM', p_msg_name => 'EAM_WRR_RESET_WHY');
        l_return_status := FND_API.G_RET_STS_UNEXP_ERROR; */
      else
        -- done!
        l_current_reading := p_reading;
        l_current_ltd_reading := p_before_ltd_reading; -- don't reset ltd
      end if;
    else
    -- not reset
      if (p_reading is not null) then
        l_current_reading := p_reading;
        l_current_ltd_reading := p_reading - nvl(p_before_reading, 0) + nvl(p_before_ltd_reading, 0);
      else
        l_current_reading := nvl(p_before_reading, 0) + p_reading_change;
        l_current_ltd_reading := nvl(p_before_ltd_reading, 0) + p_reading_change;
      end if;
      -- if both not null , and not reset , check for confliction
      if(p_reading is not null and p_reading_change is not null and
        p_reading - nvl(p_before_reading, 0) <> p_reading_change) then
        eam_execution_jsp.add_message(p_app_short_name => 'EAM', p_msg_name => 'EAM_MRR_DATA_CONFLICT'
          ,p_token1 => 'METER_NAME', p_value1 => p_meter_name);
        l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      end if;

      -- no problem?
      if( l_return_status = FND_API.G_RET_STS_SUCCESS) then
      -- check ltd changes?
        l_change := l_current_ltd_reading - nvl(p_before_ltd_reading, 0);
        l_ltd_change_before := 0;
        if( p_before_ltd_reading is not null) then
              l_ltd_change_before := l_current_ltd_reading - p_before_ltd_reading;
        end if;
        l_ltd_change_after := 0;
        if(p_after_ltd_reading is not null) then
          l_ltd_change_after := p_after_ltd_reading - l_current_ltd_reading;
        end if;

        if(  (nvl(p_meter_direction, 0)=1 and (l_ltd_change_before<0 or l_ltd_change_after<0))
          or (nvl(p_meter_direction, 0)=2 and (nvl(l_ltd_change_before, -1)>0 or l_ltd_change_after>0)) ) then
          -- not correct
          if( p_reading is not null) then -- inform reading range
            l_range_from := '';
            l_range_to := '';
            if( p_before_ltd_reading is not null) then
              l_range_from := l_current_reading - l_ltd_change_before;
            end if;
            if( p_after_ltd_reading is not null) then
              l_range_to := l_current_reading + l_ltd_change_after;
            end if;
            -- swap if is descending direction
            if( nvl(p_meter_direction, 0) = 2 ) then
              l_range_tmp := l_range_from;
              l_range_from := l_range_to;
              l_range_to := l_range_tmp;
            end if;
            --baroy
            --If the warning has already been shown, then don't show again
            if(p_mtr_warning_shown <> 'Y') then
              eam_execution_jsp.add_message(
                 p_app_short_name => 'EAM', p_msg_name => 'EAM_MRR_READING_RANGE'
                ,p_token1 => 'FROM', p_value1 => l_range_from
                ,p_token2 => 'TO', p_value2 => l_range_to
                ,p_token3 => 'METER_NAME', p_value3 => p_meter_name
              );
              p_mtr_warning_shown := 'Y';
            end if;
            --baroy
          else -- inform the change range
            l_range_from := '0';
            l_range_to := '';
            if( p_after_ltd_reading is not null) then
              --l_range_to := l_ltd_change_before + l_ltd_change_after;
              l_range_to := p_after_ltd_reading - p_before_ltd_reading;
            end if;
            -- swap if is descending direction
            if( nvl(p_meter_direction, 0) = 2 ) then
              l_range_tmp := l_range_from;
              l_range_from := l_range_to;
              l_range_to := l_range_tmp;
            end if;
            eam_execution_jsp.add_message(
               p_app_short_name => 'EAM', p_msg_name => 'EAM_MRR_CHANGE_RANGE'
              ,p_token1 => 'FROM', p_value1 => l_range_from
              ,p_token2 => 'TO', p_value2 => l_range_to
              ,p_token3 => 'METER_NAME', p_value3 => p_meter_name
            );
          end if;
          l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        end if;

      end if;
    end if;

    x_current_reading := l_current_reading;
    x_current_ltd_reading := l_current_ltd_reading;
  END get_current_reading_data;

-------------------------------------------------------------------------
-- check asset and meter associating
-------------------------------------------------------------------------
  procedure check_asset_meter_association
  (
    p_meter_id                    IN    NUMBER
   ,p_wip_entity_id               IN    NUMBER
   ,p_org_id                      IN    NUMBER        := NULL
   ,p_asset_number                IN    VARCHAR2      := NULL
   ,p_asset_group_id              IN    NUMBER        := NULL
   ,x_return_status               OUT NOCOPY   VARCHAR2
   ,x_msg_count                   OUT NOCOPY   NUMBER
   ,x_msg_data                    OUT NOCOPY   VARCHAR2
  ) IS

  l_org_id               NUMBER;
  l_asset_number         VARCHAR2(250);
  l_asset_group_id       NUMBER;

  BEGIN
    eam_debug.init_err_stack('eam_execution_jsp.add_meter_reading');

    -- not standalone? (can standalone have a wip_entity_id??)
    if (p_wip_entity_id is not null) then
      -- get the info for validation, probablly not useful
      select organization_id, asset_number, asset_group_id
      into l_org_id, l_asset_number, l_asset_group_id
      from wip_discrete_jobs
      where wip_entity_id = p_wip_entity_id;

      if( SQL%NOTFOUND) then -- wip_entity_id not found, should not happen.
        eam_execution_jsp.add_message(p_app_short_name => 'EAM', p_msg_name => 'EAM_WO_NOT_FOUND');
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      elsif (l_org_id is null or l_asset_number is null or l_asset_group_id is null) then
        eam_execution_jsp.add_message(p_app_short_name => 'EAM', p_msg_name => 'EAM_WO_DATA_NULL');
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      elsif ( nvl(p_org_id, l_org_id) <> l_org_id or
              nvl(p_asset_number, l_asset_number)<> l_asset_number or
              nvl(p_asset_group_id, l_asset_group_id) <> l_asset_group_id ) then
        eam_execution_jsp.add_message(p_app_short_name => 'EAM', p_msg_name => 'EAM_WO_DATA_NULL');
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      end if;
      null;
    elsif (p_org_id is null or p_asset_number is null or p_asset_group_id is null) then
        eam_execution_jsp.add_message(p_app_short_name => 'EAM', p_msg_name => 'EAM_WO_MRR_DATA_MISS');
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    end if;

  EXCEPTION WHEN OTHERS THEN
    FND_MSG_PUB.add_exc_msg( p_pkg_name => 'EAM_EXECUTION_JSP.CHECK_ASSET_METER_ASSOCIATION',
    p_procedure_name => EAM_DEBUG.G_err_stack);
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  END check_asset_meter_association;

--------------------------------------------------------------------------------------
-- get the reading that is just before/after the current reading date
-- we need to know the previous reading data and next reading data to do validation
--------------------------------------------------------------------------------------
  procedure get_adjacent_reading
  (
     p_before                      IN    VARCHAR2     := FND_API.G_TRUE
    ,p_meter_id                    IN    NUMBER
    ,p_reading_date                IN    DATE
    ,x_reading_id                  OUT NOCOPY   NUMBER
    ,x_reading_date                OUT NOCOPY   DATE
    ,x_reading                     OUT NOCOPY   NUMBER
    ,x_ltd_reading                 OUT NOCOPY   NUMBER
  ) IS

  l_reading_date   DATE;
  l_reading        NUMBER;
  l_ltd_reading    NUMBER;
  l_reading_id     NUMBER;

  BEGIN

    l_reading_date := null; -- probablly not necessory
    l_reading_id  := null;
    l_reading     := null;
    l_ltd_reading := null;

    if( FND_API.TO_BOOLEAN(p_before)) then
        select max(current_reading_date)
        into l_reading_date
        from eam_meter_readings
        where meter_id = p_meter_id and
              current_reading_date <= p_reading_date  -- use <= here
        group by meter_id;
    else
        select min(current_reading_date)
        into l_reading_date
        from eam_meter_readings
        where meter_id = p_meter_id and
              current_reading_date > p_reading_date -- interesting, use >
        group by meter_id;
    end if;

    if(l_reading_date is not null) then
      -- should always success, just in case that two reading have the same date
      select max(meter_reading_id)
      into l_reading_id
      from eam_meter_readings
      where meter_id = p_meter_id and current_reading_date = l_reading_date
      group by meter_id;

      select life_to_date_reading, current_reading
      into l_ltd_reading, l_reading
      from eam_meter_readings
      where meter_reading_id = l_reading_id;
    end if;

    x_reading_id   := l_reading_id;
    x_reading_date := l_reading_date;
    x_reading      := l_reading;
    x_ltd_reading  := l_ltd_reading;

  EXCEPTION WHEN OTHERS THEN
    x_reading_id   := l_reading_id;
    x_reading_date := l_reading_date;
    x_reading      := l_reading;
    x_ltd_reading  := l_ltd_reading;

  END get_adjacent_reading;

------------------------------------------------------------------------------------
-- record a meter reading data
------------------------------------------------------------------------------------
  procedure add_meter_reading
  (  p_api_version                 IN    NUMBER        := 1.0
    ,p_init_msg_list               IN    VARCHAR2      := FND_API.G_FALSE
    ,p_commit                      IN    VARCHAR2      := FND_API.G_FALSE
    ,p_validate_only               IN    VARCHAR2      := FND_API.G_TRUE
    ,p_record_version_number       IN    NUMBER        := NULL
    ,x_return_status               OUT NOCOPY   VARCHAR2
    ,x_msg_count                   OUT NOCOPY   NUMBER
    ,x_msg_data                    OUT NOCOPY   VARCHAR2
    ,p_wip_entity_id               IN    NUMBER        -- data
    ,p_meter_id                    IN    NUMBER
    ,p_reading_date                IN    DATE
    ,p_reading                     IN    NUMBER
    ,p_reading_change              IN    NUMBER
    ,p_reset_flag                  IN    VARCHAR2
    ,p_mtr_warning_shown           IN OUT NOCOPY  VARCHAR2
  ) IS

  l_api_name           CONSTANT VARCHAR(30) := 'Complete_Workorder';
  l_api_version        CONSTANT NUMBER      := 1.0;
  l_return_status            VARCHAR2(250);
  l_error_msg_code           VARCHAR2(250);
  l_msg_count                NUMBER;
  l_msg_data                 VARCHAR2(250);
  l_err_code                 VARCHAR2(250);
  l_err_stage                VARCHAR2(250);
  l_err_stack                VARCHAR2(250);
  l_data                     VARCHAR2(250);
  l_msg_index_out            NUMBER;

  l_meter_name           VARCHAR2(250);
  l_meter_direction      NUMBER;
  l_effective_date_from  DATE;
  l_effective_date_to    DATE;
  l_reading_date    DATE;   -- the most recent reading date till now
  l_reading         NUMBER;
  l_ltd_reading     NUMBER;

  -- backdate reading validation
  l_before_reading_id     NUMBER; -- meter reading id
  l_before_reading_date   DATE;   -- the last reading just before (<=) the p_reading_date
  l_before_reading        NUMBER;
  l_before_ltd_reading    NUMBER;
  l_after_reading_id      NUMBER; -- the next reading just after (>) the p_reading_date
  l_after_reading_date    DATE;
  l_after_reading         NUMBER;
  l_after_ltd_reading     NUMBER;

  BEGIN

    IF p_commit = FND_API.G_TRUE THEN
       SAVEPOINT add_meter_reaing;
    END IF;

    eam_debug.init_err_stack('eam_execution_jsp.add_meter_reading');

    IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       g_pkg_name)
    THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF FND_API.TO_BOOLEAN(p_init_msg_list)
    THEN
       FND_MSG_PUB.initialize;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- validation logic goes here (mostly)

    BEGIN
      -- get the meter info ...
      select meter_name, value_change_dir, from_effective_date, to_effective_date
      into l_meter_name, l_meter_direction, l_effective_date_from, l_effective_date_to
      from eam_meters
      where meter_id = p_meter_id;

    EXCEPTION WHEN OTHERS THEN
      eam_execution_jsp.add_message(p_app_short_name => 'EAM', p_msg_name => 'EAM_MRR_NOT_FOUND'
          ,p_token1 => 'METER_ID', p_value1 => l_meter_name);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    END;

    -- value check
    if(p_reading is null and p_reading_change is null) then
      eam_execution_jsp.add_message(p_app_short_name => 'EAM', p_msg_name => 'EAM_MRR_FIELD_REQUIRED'
          ,p_token1 => 'METER_NAME', p_value1 => l_meter_name);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    end if;

    IF(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN

      if (p_reading_date is null) then
        -- no reading date
        eam_execution_jsp.add_message(p_app_short_name => 'EAM', p_msg_name => 'EAM_MRR_DATE_NULL'
          ,p_token1 => 'METER_NAME', p_value1 => l_meter_name);
        x_return_status := FND_API.G_RET_STS_ERROR;
      elsif (p_reading_date > sysdate) then
        -- futhure reading
        eam_execution_jsp.add_message(p_app_short_name => 'EAM', p_msg_name => 'EAM_MRR_DATE_BEYOND'
          ,p_token1 => 'METER_NAME', p_value1 => l_meter_name);
        x_return_status := FND_API.G_RET_STS_ERROR;
      elsif ( p_reading_date < nvl(l_effective_date_from, p_reading_date -1)
          or p_reading_date > nvl(l_effective_date_to, sysdate) ) then
        -- not in the meter's effective date range
        eam_execution_jsp.add_message(p_app_short_name => 'EAM', p_msg_name => 'EAM_MRR_EXPIRED'
          ,p_token1 => 'METER_NAME', p_value1 => l_meter_name);
        x_return_status := FND_API.G_RET_STS_ERROR;
      else -- check reading

        get_adjacent_reading(
            p_before       => FND_API.G_TRUE,
            p_meter_id     => p_meter_id,
            p_reading_date => p_reading_date,
            x_reading_id   => l_before_reading_id,
            x_reading_date => l_before_reading_date,
            x_reading      => l_before_reading,
            x_ltd_reading  => l_before_ltd_reading);

        get_adjacent_reading(
            p_before       => FND_API.G_FALSE,
            p_meter_id     => p_meter_id,
            p_reading_date => p_reading_date,
            x_reading_id   => l_after_reading_id,
            x_reading_date => l_after_reading_date,
            x_reading      => l_after_reading,
            x_ltd_reading  => l_after_ltd_reading);

        if( l_before_reading_date = p_reading_date ) then
          -- reading at this time already exists
          eam_execution_jsp.add_message(p_app_short_name => 'EAM', p_msg_name => 'EAM_MRR_DATE_EXIST'
            ,p_token1 => 'METER_NAME', p_value1 => l_meter_name);
          x_return_status := FND_API.G_RET_STS_ERROR;
        else
          eam_meter_readings_jsp.get_current_reading_data(
            p_reading             => p_reading,
            p_reading_change      => p_reading_change,
            p_reset_flag          => p_reset_flag,
            p_meter_direction     => l_meter_direction,
            p_before_reading      => l_before_reading,
            p_before_ltd_reading  => l_before_ltd_reading,
            p_after_reading       => l_after_reading,
            p_after_ltd_reading   => l_after_ltd_reading,
            p_reading_date        => p_reading_date,
            p_meter_name          => l_meter_name,
            x_current_reading     => l_reading,
            x_current_ltd_reading => l_ltd_reading,
            p_mtr_warning_shown   => p_mtr_warning_shown);
        end if;
      end if;
    END IF; -- if(x_return_status = fnd_api.g_ret_success)

    -- if validate not passed then raise error
    l_msg_count := FND_MSG_PUB.count_msg;
    IF l_msg_count = 1 THEN
       eam_execution_jsp.Get_Messages
         (p_encoded  => FND_API.G_FALSE,
          p_msg_index => 1,
          p_msg_count => l_msg_count,
          p_msg_data  => nvl(l_msg_data,FND_API.g_MISS_CHAR),
          p_data      => l_data,
          p_msg_index_out => l_msg_index_out);
          x_msg_count := l_msg_count;
          x_msg_data  := l_msg_data;
    ELSE
       x_msg_count  := l_msg_count;
    END IF;

    IF l_msg_count > 0 THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       RAISE  FND_API.G_EXC_ERROR;
    END IF;

    -- otherwise, ready to make the changes
    -- Fields: p_meter_id, l_reading, l_ltd_reading, p_reset_flag, l_reading_date,
    --         p_wip_entity_id

    insert_row(
       p_meter_id => p_meter_id
      ,p_current_reading => l_reading
      ,p_current_reading_date => p_reading_date
      ,p_reset_flag => p_reset_flag
      ,p_life_to_date_reading => l_ltd_reading
      ,p_wip_entity_id => p_wip_entity_id
      ,p_description => null
     );

    IF FND_API.TO_BOOLEAN(P_COMMIT) THEN
      COMMIT WORK;
    END IF;

  EXCEPTION WHEN FND_API.G_EXC_UNEXPECTED_ERROR  THEN
    IF p_commit = FND_API.G_TRUE THEN
       ROLLBACK TO add_meter_reading;
    END IF;

    FND_MSG_PUB.add_exc_msg( p_pkg_name => 'EAM_EXECUTION_JSP.ADD_METER_READING',
    p_procedure_name => EAM_DEBUG.G_err_stack);
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN FND_API.G_EXC_ERROR THEN
    IF p_commit = FND_API.G_TRUE THEN
       ROLLBACK TO add_meter_reading;
    END IF;

    FND_MSG_PUB.add_exc_msg( p_pkg_name => 'EAM_EXECUTION_JSP.ADD_METER_READING',
    p_procedure_name => EAM_DEBUG.G_err_stack);
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN OTHERS THEN
    IF p_commit = FND_API.G_TRUE THEN
       ROLLBACK TO add_meter_reading;
    END IF;

    FND_MSG_PUB.add_exc_msg( p_pkg_name => 'EAM_EXECUTION_JSP.ADD_METER_READING',
    p_procedure_name => EAM_DEBUG.G_err_stack);

    eam_execution_jsp.add_message(p_app_short_name => 'EAM', p_msg_name => 'EAM_MRR_EXCEPTION'
     ,p_token1 => 'MESSAGE', p_value1 => SQLERRM);
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END add_meter_reading;

end EAM_METER_READINGS_JSP;

/

--------------------------------------------------------
--  DDL for Package Body JTF_AGENDA_CALCULATIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_AGENDA_CALCULATIONS" as
/*$Header: JTFAGCAB.pls 120.2 2005/09/01 22:09:44 pseo ship $*/

  -- get attributes of the task assignment prior to the current
  -- task assignment, dependant on the type of the current task, that is
  -- for an arrival virtual task all tasks in the shift, for a departure
  -- nothing (because this is the first 'task' in the shift), and for a
  -- real task all tasks before the current task including the departure
  procedure get_prior_task_assignment
  ( p_res_id          in  number
  , p_res_type        in  varchar2
  , p_shift_start     in  date
  , p_shift_end       in  date
  , p_sched_start     in  date
  , p_ta_id           in  number
  , p_task_type_id    in  number
  , x_prior_ta_id     out NOCOPY number
  , x_prior_sched_end out NOCOPY date
  , x_prior_found     out NOCOPY boolean
  )
  is
    -- get tasks for this resource in this shift which are before current
    -- task or is the departure virtual task
    cursor c_prior
    ( p_res_id      number
    , p_res_type    varchar2
    , p_shift_start date
    , p_shift_end   date
    , p_sched_start date
    , p_ta_id       number
    )
    is
      select task_assignment_id
      ,      scheduled_end_date
      from jtf_agenda_ta_v
      where resource_id        = p_res_id
      and   resource_type_code = p_res_type
      and   shift_start        = p_shift_start
      and   shift_end          = p_shift_end
      and   ( task_type_id = 20 -- departure task
           or ( task_type_id not in (20,21) -- real tasks
            and ( scheduled_start_date < p_sched_start
               or ( scheduled_start_date = p_sched_start
                and task_assignment_id < p_ta_id ) ) ) )
      order by decode(task_type_id,20,1,0) -- departure task last
      ,        scheduled_start_date desc
      ,        task_assignment_id   desc;

    -- get all tasks for this resource in this shift but without arrival
    cursor c_prior_all
    ( p_res_id      number
    , p_res_type    varchar2
    , p_shift_start date
    , p_shift_end   date
    )
    is
      select task_assignment_id
      ,      scheduled_end_date
      from jtf_agenda_ta_v
      where resource_id        = p_res_id
      and   resource_type_code = p_res_type
      and   shift_start        = p_shift_start
      and   shift_end          = p_shift_end
      and   task_type_id      <> 21 -- not arrival task
      order by decode(task_type_id,20,1,0) -- departure task last
      ,        scheduled_start_date desc
      ,        task_assignment_id   desc;

  begin
    x_prior_ta_id     := null;
    x_prior_sched_end := null;
    x_prior_found     := false;

    -- real task
    if p_task_type_id not in (20,21)
    then
      open c_prior
      ( p_res_id
      , p_res_type
      , p_shift_start
      , p_shift_end
      , p_sched_start
      , p_ta_id
      );
      fetch c_prior
      into x_prior_ta_id
      ,    x_prior_sched_end;

      if c_prior%found
      then
        x_prior_found := true;
      end if;
      close c_prior;

    -- virtual arrival task
    elsif p_task_type_id = 21
    then
      open c_prior_all
      ( p_res_id
      , p_res_type
      , p_shift_start
      , p_shift_end
      );
      fetch c_prior_all
      into x_prior_ta_id
      ,    x_prior_sched_end;

      if c_prior_all%found
      then
        x_prior_found := true;
      end if;
      close c_prior_all;
    end if;
  end get_prior_task_assignment;

  function predict_time_difference
  (
    p_task_assignment_id number
  )
  return number
  is
    l_diff            number       := 0;
    l_sched_start     date         := null;
    l_sched_end       date         := null;
    l_actua_start     date         := null;
    l_actua_end       date         := null;
    l_sched_travel    number       := 0;
    l_res_id          number       := null;
    l_res_type        varchar2(30) := null;
    l_shift_start     date         := null;
    l_shift_end       date         := null;
    l_prior_ta_id     number       := null;
    l_prior_sched_end date         := null;
    l_min_start       date         := null;
    l_free            number       := 0;
    l_bmode           varchar2(30) := null;
    l_plan_start      date         := null;
    l_plan_end        date         := null;
    l_task_type_id    number       := null;
    l_prior_found     boolean      := false;

    cursor c_this ( p_ta_id number )
    is
      select scheduled_start_date
      ,      scheduled_end_date
      ,      actual_start_date
      ,      actual_end_date
      ,      sched_travel_duration
      ,      resource_id
      ,      resource_type_code
      ,      shift_start
      ,      shift_end
      ,      bound_mode_code
      ,      planned_start_date
      ,      planned_end_date
      ,      task_type_id
      from jtf_agenda_ta_v
      where task_assignment_id = p_ta_id;

  begin
    open c_this ( p_task_assignment_id );
    fetch c_this
    into l_sched_start
    ,    l_sched_end
    ,    l_actua_start
    ,    l_actua_end
    ,    l_sched_travel
    ,    l_res_id
    ,    l_res_type
    ,    l_shift_start
    ,    l_shift_end
    ,    l_bmode
    ,    l_plan_start
    ,    l_plan_end
    ,    l_task_type_id;

    if c_this%found
    then
      -- validate shift
      if l_shift_start is null
      or l_shift_end is null
      or l_shift_end < l_shift_start
      then
        -- exit
        return 0;
      end if;

      -- compute difference
      if l_actua_end is not null
      then
        l_diff := l_actua_end - l_sched_end;

      elsif l_actua_start is not null
      then
        l_diff := l_actua_start - l_sched_start;
        if sysdate > l_sched_end + l_diff
        then
          l_diff := sysdate - l_sched_end;
        end if;

      -- no actual dates are found, get the previous task in this trip to find
      -- an actual date
      else
        get_prior_task_assignment ( l_res_id
                                  , l_res_type
                                  , l_shift_start
                                  , l_shift_end
                                  , l_sched_start
                                  , p_task_assignment_id
                                  , l_task_type_id
                                  , l_prior_ta_id
                                  , l_prior_sched_end
                                  , l_prior_found );

        if l_prior_found
        then
          -- this is a recursive function!
          l_diff := predict_time_difference ( l_prior_ta_id );

        -- no previous task found, this is the first task of the trip, take
        -- system date into account
        else
          if sysdate > l_sched_start
          then
            l_diff := sysdate - l_sched_start;
          end if;
        end if;

        -- validate travel time attributes
        if l_sched_travel is null
        or l_sched_travel < 0
        then
          l_sched_travel := 0;
        end if;

        -- compute minimal time resource has to leave in order to arrive
        -- in time to start task (unit of measurement is minute)
        l_min_start := l_sched_start - ( l_sched_travel / 1440 );

        -- correct difference by amount of not scheduled, free time
        l_free := l_min_start - nvl( l_prior_sched_end, l_shift_start );
        l_diff := l_diff - l_free;

        -- correct for time bounds
        if  l_bmode = 'BTS'
        and l_plan_end >= l_plan_start
        -- makes no sense for virtual tasks departure and arrival
        and l_task_type_id not in (20,21)
        then
          if ( l_sched_start + l_diff ) < l_plan_start
          then
            l_diff := l_plan_start - l_sched_start;
          end if;
        end if;
      end if;
    end if;
    close c_this;

    return l_diff;
  end predict_time_difference;

  function set_sequence_flag
  (
    p_task_assignment_id number
  )
  return varchar2
  is
    l_flag        varchar2(1)  := 'N';
    l_res_id      number       := null;
    l_res_type    varchar2(30) := null;
    l_shift_start date         := null;
    l_shift_end   date         := null;
    l_sched_start date         := null;

    cursor c_this ( p_ta_id number )
    is
      select scheduled_start_date
      ,      resource_id
      ,      resource_type_code
      ,      shift_start
      ,      shift_end
      from jtf_agenda_ta_v
      where task_assignment_id = p_ta_id
      and   actual_start_date is null
      and   actual_end_date   is null;

    cursor c_next
    ( p_res_id      number
    , p_res_type    varchar2
    , p_shift_start date
    , p_shift_end   date
    , p_sched_start date
    , p_ta_id       number
    )
    is
      select 'Y'
      from jtf_agenda_ta_v
      where resource_id        = p_res_id
      and   resource_type_code = p_res_type
      and   shift_start        = p_shift_start
      and   shift_end          = p_shift_end
      and   ( scheduled_start_date > p_sched_start
           or ( scheduled_start_date = p_sched_start
            and task_assignment_id > p_ta_id ) )
      and   nvl(actual_start_date,actual_end_date) is not null;

  begin
    open c_this ( p_task_assignment_id );
    fetch c_this
    into l_sched_start
    ,    l_res_id
    ,    l_res_type
    ,    l_shift_start
    ,    l_shift_end;

    if c_this%found
    then
      open c_next
           ( l_res_id
           , l_res_type
           , l_shift_start
           , l_shift_end
           , l_sched_start
           , p_task_assignment_id
           );
      fetch c_next
      into l_flag;

      close c_next;
    end if;
    close c_this;

    return l_flag;
  end set_sequence_flag;

  function get_progress_status
  ( p_resource_id        number
  , p_resource_type_code varchar2
  , p_date               date
  )
  return number
  is
    -- get all escalated tasks in current trip
    cursor c_esc
    ( p_res_id   number
    , p_res_type varchar2
    , p_date     date
    )
    is
      select ''
      from jtf_agenda_v
      where resource_id        = p_res_id
      and   resource_type_code = p_res_type
      and   p_date between shift_start and shift_end
      and   escalation_flag = 'Y';

    cursor c_max
    (
      p_res_id   number
    , p_res_type varchar2
    , p_date     date
    )
    is
      select max(predicted_end_date)
      ,      max(shift_end)
      from jtf_agenda_v
      where resource_id        = p_res_id
      and   resource_type_code = p_res_type
      and   p_date between shift_start and shift_end
      and   task_type_id not in (20,21);

    l_chk            varchar2(1);
    l_max_pred_end   date   := null;
    l_shift_end      date   := null;
    l_dif            number := null;
    l_uom   constant number := 1440; /* unit of measurement is minutes */
    l_margin         number;

  begin
    /* see if any task in current trip is escalated */
    open c_esc ( p_resource_id
               , p_resource_type_code
               , p_date );
    fetch c_esc into l_chk;
    if c_esc%found
    then
      close c_esc;
      return 4; /* escalated */
    end if;
    close c_esc;

    /* get highest predicted end date within trip */
    open c_max
         ( p_resource_id
         , p_resource_type_code
         , p_date
         );
    fetch c_max
    into l_max_pred_end
    ,    l_shift_end;

    /* calculate difference with shift end */
    l_dif := ( l_shift_end - l_max_pred_end ) * l_uom;

    if  c_max%found
    and l_dif is not null
    then
      /* get margin profile option */
      l_margin := to_number( fnd_profile.value(
                             'CSF_RESOURCE_PROGRESS_STATUS') );
      if l_margin is null
      or sqlcode <> 0
      then
        l_margin := 60; /* default value (60 minutes) */
      end if;

      close c_max;

      if l_dif < ( l_margin * -1 )
      then
        return 3; /* behind schedule */
      elsif l_dif > l_margin
      then
        return 1; /* ahead of schedule */
      end if;
      return 2; /* on schedule */
    end if;
    close c_max;

    return 0; /* unknown */
  end get_progress_status;

  function get_assignment_status
  (
     p_resource_id        number
  ,  p_resource_type_code varchar2
  )
  return number
  is
    cursor c_currsta
    is
      select assignment_status_id
      from jtf_agenda_ta_v
      where resource_id        = p_resource_id
      and   resource_type_code = p_resource_type_code
      and   task_type_id not in (20,21)
      and   ( actual_start_date =
              ( select max( actual_start_date )
                from jtf_agenda_ta_v
                where resource_id        = p_resource_id
                and   resource_type_code = p_resource_type_code
                and   task_type_id not in (20,21) )
           or actual_start_date is null )
      order by scheduled_start_date
      ,        task_assignment_id;

    l_status_id number;
  begin
    open c_currsta;
    fetch c_currsta into l_status_id;
    if c_currsta%notfound
    then
      l_status_id := null;
    end if;
    close c_currsta;

    return l_status_id;
  end get_assignment_status;

  function get_status_name
  (
    p_status_id number
  )
  return varchar2
  is
    cursor c_name
    is
      select name
      from jtf_task_statuses_vl
      where task_status_id = p_status_id;
    l_name varchar2(30);
  begin
    open c_name;
    fetch c_name into l_name;
    if c_name%notfound
    then
      l_name := null;
    end if;
    close c_name;

    return l_name;
  end get_status_name;

  function get_current_task
  (
     p_resource_id        number
  ,  p_resource_type_code varchar2
  )
  return number
  is
    cursor c_currtask
    is
      select task_id
      from jtf_agenda_ta_v
      where resource_id        = p_resource_id
      and   resource_type_code = p_resource_type_code
      and   task_type_id not in (20,21)
      and   ( actual_start_date =
              ( select max( actual_start_date )
                from jtf_agenda_ta_v
                where resource_id        = p_resource_id
                and   resource_type_code = p_resource_type_code
                and   task_type_id not in (20,21) )
           or actual_start_date is null )
      order by scheduled_start_date
      ,        task_assignment_id;

    l_task_id number;
  begin
    open c_currtask;
    fetch c_currtask into l_task_id;
    if c_currtask%notfound
    then
      l_task_id := null;
    end if;
    close c_currtask;

    return l_task_id;
  end get_current_task;

  FUNCTION get_shift_start
  (  p_shift_construct_id NUMBER   DEFAULT NULL
  ,  p_resource_id        NUMBER   DEFAULT NULL
  ,  p_resource_type_code VARCHAR2 DEFAULT NULL
  ,  p_date               DATE     DEFAULT NULL
  )
  RETURN DATE
  IS
    l_start         DATE;
    l_time          NUMBER;
    l_return_status VARCHAR2(1);
    l_msg_count     NUMBER;
    l_msg_data      VARCHAR2(2000);
    l_shift         JTF_CALENDAR_PUB.SHIFT_TBL_TYPE;

    CURSOR c_shift_construct IS
      SELECT begin_time
        FROM jtf_cal_shift_constructs
       WHERE shift_construct_id = p_shift_construct_id;

    r_shift_construct c_shift_construct%ROWTYPE;

  BEGIN
    OPEN c_shift_construct;
    FETCH c_shift_construct INTO r_shift_construct;
    IF c_shift_construct%FOUND THEN
      l_time  := r_shift_construct.begin_time -
                 TRUNC(r_shift_construct.begin_time);
      l_start := TRUNC(p_date) + l_time;
    END IF;
    CLOSE c_shift_construct;

    -- No shift start was found using shift_construct_id
    IF l_start IS NULL THEN
      JTF_CALENDAR_PUB.Get_Resource_Shifts
        ( p_api_version   => 1.0                  ,
          p_resource_id   => p_resource_id        ,
          p_resource_type => p_resource_type_code ,
          p_start_date    => p_date               ,
          p_end_date      => p_date               ,
          x_return_status => l_return_status      ,
          x_msg_count     => l_msg_count          ,
          x_msg_data      => l_msg_data           ,
          x_shift         => l_shift
        );

      IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
	l_start := TO_DATE(l_shift(1).start_time, 'hh24:mi');
	l_time  := l_start - TRUNC(l_start);
        l_start := TRUNC(p_date) + l_time;
      END IF;
    END IF;

--    Temporary if Calendar DB objects are invalid
--    l_start := TRUNC(p_date) + ( 8 / 24 );
--    IF l_start > p_date THEN
--      l_start := l_start - 1;
--    END IF;

    RETURN l_start;
  END get_shift_start;

  FUNCTION get_shift_end
  (  p_shift_construct_id NUMBER   DEFAULT NULL
  ,  p_resource_id        NUMBER   DEFAULT NULL
  ,  p_resource_type_code VARCHAR2 DEFAULT NULL
  ,  p_date               DATE     DEFAULT NULL
  )
  RETURN DATE
  IS
    l_end           DATE;
    l_time          NUMBER;
    l_return_status VARCHAR2(1);
    l_msg_count     NUMBER;
    l_msg_data      VARCHAR2(2000);

    l_shift         JTF_CALENDAR_PUB.SHIFT_TBL_TYPE;

    CURSOR c_shift_construct IS
      SELECT end_time
        FROM jtf_cal_shift_constructs
       WHERE shift_construct_id = p_shift_construct_id;

    r_shift_construct c_shift_construct%ROWTYPE;

  BEGIN
    OPEN c_shift_construct;
    FETCH c_shift_construct INTO r_shift_construct;
    IF c_shift_construct%FOUND THEN
      l_time := r_shift_construct.end_time - TRUNC(r_shift_construct.end_time);
      l_end  := TRUNC(p_date) + l_time;
    END IF;
    CLOSE c_shift_construct;

    -- No shift end was found using shift_construct_id
    IF l_end IS NULL THEN
      JTF_CALENDAR_PUB.Get_Resource_Shifts
        ( p_api_version   => 1.0                  ,
          p_resource_id   => p_resource_id        ,
          p_resource_type => p_resource_type_code ,
          p_start_date    => p_date               ,
          p_end_date      => p_date               ,
          x_return_status => l_return_status      ,
          x_msg_count     => l_msg_count          ,
          x_msg_data      => l_msg_data           ,
          x_shift         => l_shift
        );

      IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
	l_end  := TO_DATE(l_shift(1).end_time, 'hh24:mi');
	l_time := l_end - TRUNC(l_end);
        l_end  := TRUNC(p_date) + l_time;
      END IF;
    END IF;

--    Temporary if Calendar DB objects are invalid
--    l_end := ( get_shift_start( p_shift_construct_id,
--                                p_resource_id,
--                                p_resource_type_code,
--                                p_date
--                              ) + ( 9 / 24 ) );

    RETURN l_end;
  END get_shift_end;

  FUNCTION set_escalation_flag
  (
     p_task_id NUMBER
  )
  RETURN VARCHAR2
  IS
        l_return_value     VARCHAR2(1)  := 'N';
        l_object_type_code VARCHAR2(30) := 'TASK';
        l_object_id        NUMBER       := p_task_id;

        CURSOR c_esc IS
          SELECT NULL
            FROM jtf_tasks_b            t,
                 jtf_task_references_vl r,
                 jtf_ec_statuses_vl   s
           WHERE t.task_id = r.task_id
                 AND t.task_type_id   = 22
                 AND t.task_status_id = s.task_status_id
                 AND (s.closed_flag = 'N'
                 OR   s.closed_flag is null)
                 AND (s.completed_flag = 'N'
                 OR   s.completed_flag is null)
                 AND (s.cancelled_flag = 'N'
                 OR   s.cancelled_flag is null)
                 AND r.reference_code   = 'ESC'
                 AND r.object_type_code = l_object_type_code
                 AND r.object_id        = l_object_id;

        CURSOR c_tsk IS
          SELECT t.source_object_type_code,
                 t.source_object_id
            FROM jtf_tasks_b          t,
                 jtf_task_statuses_vl s
           WHERE t.task_id = p_task_id
                 AND t.task_status_id = s.task_status_id
                 AND (s.closed_flag = 'N'
                 OR   s.closed_flag is null)
                 AND (s.completed_flag = 'N'
                 OR   s.completed_flag is null)
                 AND (s.cancelled_flag = 'N'
                 OR   s.cancelled_flag is null);
        r_esc c_esc%ROWTYPE;
        r_tsk c_tsk%ROWTYPE;
  BEGIN
        -- Check if Task is escalated. Ignore completed/cancelled status
        -- of Task.
        OPEN c_esc;
        FETCH c_esc INTO r_esc;
        IF c_esc%FOUND THEN
          l_return_value := 'Y';
        END IF;

        CLOSE c_esc;

        -- If Task is not escalated then check if Service Request is
        -- escalated. Only Tasks which are not completed/cancelled can be
        -- escalated if the Service Request is escalated
        IF l_return_value = 'N' THEN
          OPEN c_tsk;
          FETCH c_tsk INTO r_tsk;
          IF c_tsk%FOUND THEN
            l_object_type_code := r_tsk.source_object_type_code;
            l_object_id        := r_tsk.source_object_id;

            OPEN c_esc;
            FETCH c_esc INTO r_esc;
            IF c_esc%FOUND THEN
              l_return_value := 'Y';
            END IF;
            CLOSE c_esc;
          END IF;
          CLOSE c_tsk;
        END IF;

        RETURN l_return_value;
  END set_escalation_flag;

end JTF_AGENDA_CALCULATIONS;

/

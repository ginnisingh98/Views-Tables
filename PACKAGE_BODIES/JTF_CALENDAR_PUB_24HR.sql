--------------------------------------------------------
--  DDL for Package Body JTF_CALENDAR_PUB_24HR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_CALENDAR_PUB_24HR" AS
/* $Header: jtfclpab.pls 120.8.12010000.6 2009/10/07 15:09:45 anangupt ship $ */

-- ************************************************************************
-- Start of Comments
--      Package Name    : JTF_CLAENDAR_PUB
--      Purpose         : Joint Task Force core Calendar Public API's
--                        This package is for finding the availability,
--                        working shift hours of a particular resource
--                        during a specified period
--      Procedures      : (See below for specification)
--      Notes           : This package is publicly available for use
--      History         : 09/29/99      VMOVVA          created
--                        03/28/02      JAWANG          modified
--                                                      changed jtf_rs_resources_vl
--                                                      to jtf_rs_all_resources_vl
--                        03/27/03      ABRAINA         Modified cursors in Get_available_time
--                                                      and Get_Res_Schedule.
--                        06/16/03      ABRAINA         Fixed GSCC warning.
--                        08/11/03      ABRAINA         Added ResourceDt_To_ServerDT
--                        12/12/05      SBARAT          Changed jtf_rs_resources_vl to jtf_task_resources_vl
--                                                      due to MOAC change, bug# 4455792
--				  12/22/05      MPADHIAR	  Change for Bug # 4400664
--									  In case of UOM is minute(MIN) . It was truncating Second portion
--									  of the Calculated end_time. So giving 1 Minute less
--									  for 2, 5, 8 ,...... 59 Minure Estimated Assigments.
--                        15/03/06      SBARAT          Fixed the bug# 5081907
-- End of Comments
-- ************************************************************************
G_PKG_NAME  CONSTANT VARCHAR2(30):= 'JTF_CALENDAR_PUB_24HR';
G_EXC_REQUIRED_FIELDS_NULL  EXCEPTION;
G_EXC_INVALID_SLOT_DURATION EXCEPTION;
--G_EXC_NOT_VALID_RESOURCE EXCEPTION;
L_PARAMETERS    VARCHAR2(200);
--
-- ************************************************************************
-- Start of comments
--      API name        :
--      Type            : Private
--      Function        : Used to sort the output table
--      Pre-reqs        : None.
--      Parameters      :
--      IN              : None.
--      OUT             : None.
--      RETURN          : sorter PL/SQL table
--      Version         : Current version       1.0
--                        Initial version       1.0
--
--      Notes           :
--
-- End of comments
-- ************************************************************************

procedure sort_tab(l_tab in out NOCOPY SHIFT_TBL_TYPE ) ;
--added by sudhir 25/04/2002
procedure sort_tab_attr(l_tab in out NOCOPY SHIFT_TBL_ATTRIBUTES_TYPE) ;
procedure bubble ( p_index in integer ,
                   l_tab   in out NOCOPY SHIFT_TBL_TYPE ) ;
--added by sudhir 25/04/2002
procedure bubble_attr ( p_index in integer ,
                   l_tab   in out NOCOPY SHIFT_TBL_ATTRIBUTES_TYPE ) ;

Function check_for_required_fields
    (p_resource_id     IN NUMBER   := get_g_miss_num ,
     p_resource_type   IN VARCHAR2 := get_g_miss_char,
     p_start_date      IN DATE     := get_g_miss_date,
     p_end_date    IN DATE     := get_g_miss_date,
     p_duration    IN NUMBER   := get_g_miss_num
        )
return boolean is
begin
    if p_resource_id is null or
       p_resource_type is null or
       p_start_date is null or
       p_end_date   is null or
       p_duration   is null THEN
       return(FALSE);
    else
       return(TRUE);
        end if;
end;


/******** Sort Procedure ****************/
 procedure sort_tab(l_tab in out NOCOPY SHIFT_TBL_TYPE )
 is
      l_last number;
      l_hi   number;
      l_lo   number;
    begin
      begin
        l_last := l_tab.last;
        exception
           when collection_is_null then return;
      end;
      if l_last is null then return; end if;
      for l_hi in 2 .. l_last
      loop
        if l_tab(l_hi).start_time < l_tab(l_hi-1).start_time then
          bubble(l_hi, l_tab);
          for l_lo in reverse 2 .. l_hi-1
          loop
            if l_tab(l_lo).start_time < l_tab(l_lo-1).start_time then
              bubble(l_lo, l_tab);
            else
              exit;
            end if;
          end loop;
        end if;
      end loop;
    end sort_tab;

-- added by sudhir for sorting attribute type table

/******** Sort Procedure ****************/
 procedure sort_tab_attr(l_tab in out NOCOPY SHIFT_TBL_ATTRIBUTES_TYPE)
 is
      l_last number;
      l_hi   number;
      l_lo   number;
    begin
      begin
        l_last := l_tab.last;
        exception
           when collection_is_null then return;
      end;
      if l_last is null then return; end if;
      for l_hi in 2 .. l_last
      loop
        if l_tab(l_hi).start_time < l_tab(l_hi-1).start_time then
          bubble_attr(l_hi, l_tab);
          for l_lo in reverse 2 .. l_hi-1
          loop
            if l_tab(l_lo).start_time < l_tab(l_lo-1).start_time then
              bubble_attr(l_lo, l_tab);
            else
              exit;
            end if;
          end loop;
        end if;
      end loop;
    end sort_tab_attr;


    -- bubble up the row below this one
    procedure bubble ( p_index in integer ,
                       l_tab   in out NOCOPY SHIFT_TBL_TYPE ) is
      l_rec  Shift_Rec_Type;
    begin
      l_rec := l_tab(p_index);
      l_tab(p_index) := l_tab(p_index-1);
      l_tab(p_index-1) := l_rec;
    end bubble;

    -- added by sudhir 25/04/2002

    -- bubble up the row below this one
    procedure bubble_attr ( p_index in integer ,
                           l_tab   in out NOCOPY SHIFT_TBL_ATTRIBUTES_TYPE) is
      l_rec  Shift_Rec_Attributes_Type;
      begin
          l_rec := l_tab(p_index);
          l_tab(p_index) := l_tab(p_index-1);
          l_tab(p_index-1) := l_rec;
    end bubble_attr;

-- **************************************************************************************
-- 	API name 	: Get_Available_Time_Slot
--      p_duration      : Will be passed as > 0 when called from get_available_slot.
--      p_get_available_slot : "Y" - For finding first slot of given duration.
--                             "N" - Don't find slots, get simple the available time.
-- **************************************************************************************

PROCEDURE Get_Available_Time_slot
(   p_api_version   IN     NUMBER,
    p_init_msg_list IN     VARCHAR2:=FND_API.G_FALSE,
    p_resource_id   IN     NUMBER,
    p_resource_type IN     VARCHAR2,
    p_start_date    IN     DATE,
    p_end_date      IN     DATE,
    p_duration      IN     NUMBER,
    p_get_available_slot IN VARCHAR2,
    x_return_status OUT NOCOPY VARCHAR2,
    x_msg_count     OUT NOCOPY NUMBER,
    x_msg_data      OUT NOCOPY VARCHAR2,
    x_shift         OUT NOCOPY SHIFT_TBL_TYPE
)
IS

  --this record is for keeping shift info
  type shift_rec_type is record
  (
   shift_id number,
   shift_duration number
  );
  type shift_tbl_type is table of shift_rec_type index by binary_integer;

-- we are declaring a table of records here again to manuplate the start and end time in DATE datatype.
  type rec_type is record
  ( shift_construct_id number
  , start_time         date
  , end_time         date
  , availability_type  varchar2(40) );

  type tbl_type is table of rec_type index by binary_integer;

   l_api_name           CONSTANT VARCHAR2(30):= 'Get_Available_Time_Slot';
   l_api_version            CONSTANT NUMBER := 1.0;

   -- Gets the shift_id and duration info, used for calculating the right shift pattern based
   -- on the calendar id selected using the parameters passed resource_id, resource_type
   -- and requested_date

    cursor shift_info(p_calendar_id NUMBER) is
    select shift_id,(shift_end_date - shift_start_date) shift_duration
      from jtf_cal_shift_assign
     where calendar_id = p_calendar_id
  order by shift_sequence_number;

  -- Based on the shift_id corresponding shift construction is found.

    cursor c_cal_shift_constr(p_shift_id NUMBER,p_day date, p_uot_value DATE) is
    select shift_construct_id,
           begin_time start_constr,
           end_time end_constr,
           availability_type_code
      from jtf_cal_shift_constructs
     where shift_id = p_shift_id
       and ((start_date_active <=p_day and end_date_active IS NULL) /* bug# 2408759 */
             or (p_day between start_date_active and end_date_active))
       and (
             (
               trunc(begin_time) <= trunc(p_uot_value)
               and
               trunc(end_time)  >= trunc(p_uot_value)
              )
            or
             (
               trunc(begin_time) <= to_date('1995/01/07','YYYY/MM/DD') +
                                        to_number(substr(to_char(trunc(p_uot_value), 'YYYY/MM/DD'),9,2))
               and
               trunc(end_time)  >= to_date('1995/01/07','YYYY/MM/DD') +
                                     to_number(substr(to_char(trunc(p_uot_value), 'YYYY/MM/DD'),9,2))
              )
           )
   order by begin_time;

--  Get all the exceptions and tasks for the resource on the requested date.
-- Added two new parameters p_tz_enabled, p_server_tz_id and
-- modified the query accordingly. Done by SBARAT on 23/06/2005 for Bug# 4443443
-- p_res_Timezone_id to modify exception from resource timezone to server timezone
    cursor c_cal_except(p_calendar_id NUMBER, p_start date, p_end date, p_res_id NUMBER, p_res_type VARCHAR2,p_tz_enabled VARCHAR2,p_server_tz_id NUMBER,p_res_Timezone_id NUMBER) is
    select Decode(p_tz_enabled,'Y',
                      Decode(p_res_Timezone_id,NULL, e.start_date_time,
                             Nvl(HZ_TIMEZONE_PUB.CONVERT_DATETIME(p_res_Timezone_id,
                                                                  p_server_tz_id,
                                                                  e.start_date_time),
                                 e.start_date_time)
                            ),
                      e.start_date_time) 			 start_except,
           Decode(p_tz_enabled,'Y',
                      Decode(p_res_Timezone_id,NULL, e.end_date_time,
                             Nvl(HZ_TIMEZONE_PUB.CONVERT_DATETIME(p_res_Timezone_id,
                                                                  p_server_tz_id,
                                                                  e.end_date_time),
                                 e.end_date_time)
                            ),
                      e.end_date_time)   end_except,
           nvl(Decode(p_tz_enabled,'Y',
                      Decode(p_res_Timezone_id,NULL, a.start_date_active,
                             Nvl(HZ_TIMEZONE_PUB.CONVERT_DATETIME(p_res_Timezone_id,
                                                                  p_server_tz_id,
                                                                  a.start_date_active),
                                 a.start_date_active)
                            ),
                      a.start_date_active) ,p_start) start_assign,
           nvl(Decode(p_tz_enabled,'Y',
                      Decode(p_res_Timezone_id,NULL, a.end_date_active,
                             Nvl(HZ_TIMEZONE_PUB.CONVERT_DATETIME(p_res_Timezone_id,
                                                                  p_server_tz_id,
                                                                  a.end_date_active),
                                 a.end_date_active)
                            ),
                      a.end_date_active),p_end) end_assign
      from jtf_cal_exception_assign a
           ,jtf_cal_exceptions_b    e
     where a.calendar_id  = p_calendar_id
       and a.exception_id = e.exception_id
       and Decode(p_tz_enabled,'Y',
                      Decode(p_res_Timezone_id,NULL, e.start_date_time,
                             Nvl(HZ_TIMEZONE_PUB.CONVERT_DATETIME(p_res_Timezone_id,
                                                                  p_server_tz_id,
                                                                  e.start_date_time),
                                 e.start_date_time)
                            ),
                      e.start_date_time) <= p_end
       and Decode(p_tz_enabled,'Y',
                      Decode(p_res_Timezone_id,NULL, e.end_date_time,
                             Nvl(HZ_TIMEZONE_PUB.CONVERT_DATETIME(p_res_Timezone_id,
                                                                  p_server_tz_id,
                                                                  e.end_date_time),
                                 e.end_date_time)
                            ),
                      e.end_date_time) >= p_start
       and nvl(Decode(p_tz_enabled,'Y',
                      Decode(p_res_Timezone_id,NULL, a.start_date_active,
                             Nvl(HZ_TIMEZONE_PUB.CONVERT_DATETIME(p_res_Timezone_id,
                                                                  p_server_tz_id,
                                                                  a.start_date_active),
                                 a.start_date_active)
                            ),
                      a.start_date_active),p_end) <= p_end --starts before end of range
       and nvl(Decode(p_tz_enabled,'Y',
                      Decode(p_res_Timezone_id,NULL, a.end_date_active,
                             Nvl(HZ_TIMEZONE_PUB.CONVERT_DATETIME(p_res_Timezone_id,
                                                                  p_server_tz_id,
                                                                  a.end_date_active),
                                 a.end_date_active)
                            ),
                      a.end_date_active),p_start) >= p_start -- end after start of range
 UNION ALL
    -- For bug 4547539, added db index skip hint to force db to use second indexed
    -- column schedule_end_date for index search
    -- Removed /*+ index_ss(T JTF_TASKS_B_N12) */ Hint to address performance issue Bug # 5167257 By MPADHIAR

    select   Decode(p_tz_enabled,'Y',
                      Decode(t.timezone_id,NULL, t.scheduled_start_date,
                             Nvl(HZ_TIMEZONE_PUB.CONVERT_DATETIME(t.timezone_id,
                                                                  p_server_tz_id,
                                                                  t.scheduled_start_date),
                                 t.scheduled_start_date)
                            ),
                      t.scheduled_start_date) 			start_except,
           Decode(p_tz_enabled,'Y',
                      Decode(t.timezone_id,NULL, t.scheduled_end_date,
                             Nvl(HZ_TIMEZONE_PUB.CONVERT_DATETIME(t.timezone_id,
                                                                  p_server_tz_id,
                                                                  t.scheduled_end_date),
					   t.scheduled_end_date)
                            ),
                      t.scheduled_end_date)                 end_except,
           p_start start_assign,
           p_end end_assign
      from jtf_tasks_b t,
           jtf_task_assignments a,
           jtf_task_statuses_b s
     where a.resource_id = p_res_id
       and a.resource_type_code = p_res_type
       and Decode(p_tz_enabled,'Y',
                      Decode(t.timezone_id,NULL, t.scheduled_start_date,
                             Nvl(HZ_TIMEZONE_PUB.CONVERT_DATETIME(t.timezone_id,
                                                                  p_server_tz_id,
                                                                  t.scheduled_start_date),
                                 t.scheduled_start_date)
                            ),
                      t.scheduled_start_date)
                <= (trunc(p_end)+86399/84400)
       and Decode(p_tz_enabled,'Y',
                      Decode(t.timezone_id,NULL, t.scheduled_end_date,
                             Nvl(HZ_TIMEZONE_PUB.CONVERT_DATETIME(t.timezone_id,
                                                                  p_server_tz_id,
                                                                  t.scheduled_end_date),
					   t.scheduled_end_date)
                            ),
                      t.scheduled_end_date)
                  >= trunc(p_start)
       and s.task_status_id = a.assignment_status_id
       and t.task_id = a.task_id
       and nvl(s.cancelled_flag,'N') <> 'Y'
    and nvl(s.completed_flag,'N') <> 'Y'
    and t.scheduled_start_date <> t.scheduled_end_date
    order by 1,2; -- bug # 2520762

--
    cursor c_in_valid_cal_dates(p_start date, p_end date, p_res_id NUMBER, p_res_type VARCHAR2) is
    select a.calendar_id, a.start_date_time, a.end_date_time,b.start_date_active, b.end_date_active
      from jtf_cal_resource_assign a,
           jtf_calendars_b b
     where a.resource_id = p_res_id
       and a.resource_type_code = p_res_type
       and a.calendar_id = b.calendar_id
       and a.primary_calendar_flag = 'Y'
       and trunc(a.start_date_time) <= p_end
       and nvl(trunc(a.end_date_time),p_start) >= p_start
       and trunc(b.start_date_active) <= p_end
       and nvl(trunc(b.end_date_active),p_start) >= p_start
  order by b.start_date_active;

   l_shift_id           NUMBER;
   l_prev_shift_id      NUMBER := 0;
   l_calendar_id                NUMBER;
   l_calendar_start_date        DATE;
   l_shifts_total_duration      NUMBER;
   l_left_days                  NUMBER;
   l_shift_date         DATE;
   l_shift_res_date         DATE;
   l_shift          SHIFT_TBL_TYPE;
   l_tbl                tbl_type; -- added by Sarvi.
   l_idx                        number := 0;
   l_utv_1                      DATE;
   l_put                        number := 1;
   l_process                    varchar2(1) := 'Y';
   l_diff                       number;
   l_start_constr               date;

   l_tz_enabled    VARCHAR2(10):=fnd_profile.value('ENABLE_TIMEZONE_CONVERSIONS'); -- Added by SBARAT on 23/06/2005 for Bug# 4443443
   l_server_tz_id               number :=   to_number (fnd_profile.value_specific('SERVER_TIMEZONE_ID'));
   l_res_Timezone_id            number ;

   v_start_date             DATE;
   v_end_date               DATE;
   v_slot_start_date            DATE;
   v_slot_end_date              DATE;
   v_slot_found                 varchar2(1);

  l_calendar_end_date          date;
  l_cal_res_start_date         date;
  l_cal_res_end_date           date;

  l_search_start_dt  date;
  l_search_end_dt    date;

  l_excp_start_dt date;
  l_excp_end_dt date;
  l_assign_start_dt date;
  l_assign_end_dt date;
  l_convert_dates boolean;
  l_shift_tbl shift_tbl_type;
  l_current_tbl_end date;

BEGIN
    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version,
                                        p_api_version,
                                l_api_name,
                                    G_PKG_NAME)
    THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
         FND_MSG_PUB.initialize;
    END IF;

    -- Call to check for required fields
    IF not check_for_required_fields (p_resource_id         =>p_resource_id,
                                      p_resource_type   =>p_resource_type,
                                      p_start_date          =>p_start_date,
                                      p_end_date            =>p_start_date)
    THEN
        l_parameters := 'p_resource_id, p_resource_type, p_start_date, p_end_date';
    RAISE G_EXC_REQUIRED_FIELDS_NULL;
    END IF;

    IF p_duration < 0 THEN
       RAISE G_EXC_INVALID_SLOT_DURATION;
    END IF;
    --
    --  Added for Simplex Timezone Enh # 3040681 by ABRAINA
    --  Set flag for timezone conversion if needed
    l_convert_dates := false;
    If fnd_profile.value_specific('ENABLE_TIMEZONE_CONVERSIONS') = 'Y' Then
       l_res_Timezone_id := Get_Res_Timezone_Id (p_resource_id, p_resource_type);
       If l_res_Timezone_id <> l_server_tz_id Then
          l_convert_dates := true;
       End If;
    End If;


 for n in c_in_valid_cal_dates(p_start_date,p_end_date,p_resource_id,p_resource_type) loop -- valid_cal_date
    l_calendar_id                := n.calendar_id;
    l_calendar_start_date        := NVL(n.start_date_active,p_start_date);
    l_calendar_end_date          := NVL(n.end_date_active,p_end_date);
    l_cal_res_start_date         := NVL(n.start_date_time,p_start_date);
    l_cal_res_end_date           := NVL(n.end_date_time,p_end_date);

    if p_start_date <= l_calendar_start_date or p_start_date <= l_cal_res_start_date then
     if l_calendar_start_date <= l_cal_res_start_date then
         l_search_start_dt := l_cal_res_start_date;
     else
         l_search_start_dt := l_calendar_start_date;
     end if;
    else
         l_search_start_dt := p_start_date;
    end if;

    if p_end_date >= l_calendar_end_date or p_end_date >= l_cal_res_end_date then
     if l_calendar_end_date >= l_cal_res_end_date then
         l_search_end_dt := l_cal_res_end_date;
     else
         l_search_end_dt := l_calendar_end_date;
     end if;
    else
         l_search_end_dt := p_end_date;
    end if;

    l_shift_tbl.delete;
    l_idx := 0;
    l_shifts_total_duration := 0;

    for c in shift_info(l_calendar_id)
    loop
        l_idx := l_idx + 1;
        l_shift_tbl(l_idx).shift_id := c.shift_id;
        l_shift_tbl(l_idx).shift_duration := c.shift_duration;
        l_shifts_total_duration := l_shifts_total_duration + c.shift_duration;
    end loop;

    l_shift_date := trunc(l_search_start_dt);
	--check if the cursor was opened in the previous loop
	if c_cal_except%ISOPEN
	then
	  close c_cal_except;
	end if;
    --open the big task/exception cursor and fetch the first record
If l_shift_tbl.count > 0 Then -- (shift assign check )
    -- Modified by SBARAT on 23/06/2005 for Bug# 4443443
    open c_cal_except(l_calendar_id,l_search_start_dt, l_search_end_dt, p_resource_id, p_resource_type,l_tz_enabled,l_server_tz_id,l_res_Timezone_id);
    FETCH c_cal_except into
       l_excp_start_dt,l_excp_end_dt,l_assign_start_dt,l_assign_end_dt;
    While l_shift_date <= l_search_end_dt Loop
       --if there is only one shift in the calendar then no looping is needed
       if (l_shift_tbl.count = 1)
       then
           l_shift_id := l_shift_tbl(1).shift_id;
           l_prev_shift_id := l_shift_id;
       else
           -- Based on the mod value the shift is selected.  This happens when two shifts are attached to the
           -- calendar and a pattern of two in sequence is required.
           l_left_days := mod((l_shift_date - l_calendar_start_date),l_shifts_total_duration);
           -- This cursor will have all the shift attached to the resources primary calendar
           -- We loop thru the cursor and based on the condition we find the correct shift_id
           for c in 1..l_shift_tbl.count loop
             l_left_days := l_left_days - l_shift_tbl(c).shift_duration;
             IF l_left_days <  0 THEN  -- earlier it was <= it was not picking the correct shift.
               l_prev_shift_id := l_shift_id;
               l_shift_id := l_shift_tbl(c).shift_id;
               EXIT;
             END IF;
           end loop;
       end if;

	   l_shift_res_date:=l_shift_date;

	    -- convert shift date to resource timezone before fetching resource shifts
	    IF (l_convert_dates)
        THEN
         l_shift_res_date := trunc(ResourceDt_To_ServerDT(l_search_start_dt,l_server_tz_id,l_res_Timezone_id));
        END IF;
         --
         -- Find the day of the Requested Date
         --
         --         l_utv := to_char(l_shift_date, 'd');
         -- changed in new api by sudar
         --     l_utv := to_char(l_shift_date, 'DAY');

         if(to_char(to_date('1995/01/01', 'YYYY/MM/DD'), 'DAY') = to_char(l_shift_res_date, 'DAY'))
         then
            l_utv_1 := to_date('1995/01/01', 'YYYY/MM/DD');
         elsif(to_char(to_date('1995/01/02', 'YYYY/MM/DD'), 'DAY') = to_char(l_shift_res_date, 'DAY'))
         then
            l_utv_1 := to_date('1995/01/02', 'YYYY/MM/DD');
         elsif(to_char(to_date('1995/01/03', 'YYYY/MM/DD'), 'DAY') = to_char(l_shift_res_date, 'DAY'))
         then
            l_utv_1 := to_date('1995/01/03', 'YYYY/MM/DD');
         elsif(to_char(to_date('1995/01/04', 'YYYY/MM/DD'), 'DAY') = to_char(l_shift_res_date, 'DAY'))
         then
            l_utv_1 := to_date('1995/01/04', 'YYYY/MM/DD');
         elsif(to_char(to_date('1995/01/05', 'YYYY/MM/DD'), 'DAY') = to_char(l_shift_res_date, 'DAY'))
         then
            l_utv_1 := to_date('1995/01/05', 'YYYY/MM/DD');
         elsif(to_char(to_date('1995/01/06', 'YYYY/MM/DD'), 'DAY') = to_char(l_shift_res_date, 'DAY'))
         then
            l_utv_1 := to_date('1995/01/06', 'YYYY/MM/DD');
         elsif(to_char(to_date('1995/01/07', 'YYYY/MM/DD'), 'DAY') = to_char(l_shift_res_date, 'DAY'))
         then
            l_utv_1 := to_date('1995/01/07', 'YYYY/MM/DD');
         end if;


        --
        -- Find the working hours on the Requested day
        --
        l_tbl.delete;
        l_idx := 0;
        FOR j in c_cal_shift_constr(l_shift_id,l_shift_res_date, l_utv_1) LOOP
           l_idx := l_idx + 1;
           l_tbl(l_idx).shift_construct_id := j.shift_construct_id;

           --added this if cond if start_date passed in is not in the same day as the shift start date -- sudarsana
           if(to_char(l_shift_res_date, 'DAY') <> to_char(j.start_constr , 'DAY'))
           then
              if(trunc(j.end_constr) > to_date('1995/01/07', 'YYYY/MM/DD'))
              then
                 l_diff := 0;
                 l_start_constr := j.start_constr;
                 while(to_char(l_start_constr , 'DAY') <> to_char(l_shift_res_date, 'DAY'))
                 loop
                    l_diff := l_diff +1;
                    l_start_constr := l_start_constr + 1;
                 end loop;
                 l_tbl(l_idx).start_time := (l_shift_res_date - l_diff)
                                               + (j.start_constr - trunc(j.start_constr));
              else
                 l_tbl(l_idx).start_time := (l_shift_res_date - (l_utv_1 -
                                     trunc(j.start_constr))) + (j.start_constr - trunc(j.start_constr));
              end if;
           else
             l_tbl(l_idx).start_time := l_shift_res_date + (j.start_constr - trunc(j.start_constr));
           end if;
           --changed this to adjust to 24 hour shift .. sudarsana
           l_tbl(l_idx).end_time   := l_tbl(l_idx).start_time + (to_number(j.end_constr - j.start_constr) * 24)/24;
           l_tbl(l_idx).availability_type := j.availability_type_code;
           --Do timezone conversion if needed
           IF (l_convert_dates)
           THEN
              l_tbl(l_idx).start_time := ResourceDt_To_ServerDT(l_tbl(l_idx).start_time,l_res_Timezone_id,l_server_tz_id);
              l_tbl(l_idx).end_time := ResourceDt_To_ServerDT(l_tbl(l_idx).end_time,l_res_Timezone_id,l_server_tz_id);
           END IF;
	   IF (l_excp_start_dt IS NOT NULL AND l_excp_end_dt IS NOT NULL)
           THEN
             --loop till all the tasks/excdeptions for the given day's shift
             --is processed
             l_current_tbl_end := l_tbl(l_idx).end_time;
             WHILE (l_excp_start_dt < l_current_tbl_end)
             LOOP
               --process only those tasks/excdeptions which are after the
               --shift start date and which are valid for the current date
               IF ((l_excp_end_dt > l_tbl(l_idx).start_time) AND
                  (l_shift_date BETWEEN TRUNC(l_assign_start_dt)
                    AND TRUNC(l_assign_end_dt)))
               THEN
                 IF (l_excp_start_dt > l_tbl(l_idx).start_time)
                 THEN
                     IF (l_excp_end_dt < l_tbl(l_idx).end_time)
                     THEN
                         --this is the case where tasks/excdeptions are within
                         --a shift, so we're going to split the shift into two
                         --create a bew entry starting at the end of
                         --tasks/exceptions
                         l_idx := l_idx + 1;
                         l_tbl(l_idx).shift_construct_id := j.shift_construct_id;
                         l_tbl(l_idx).start_time := l_excp_end_dt;
                         l_tbl(l_idx).end_time := l_tbl(l_idx-1).end_time;
                         --end the old entry to tasks/exceptions start
                         l_tbl(l_idx-1).end_time := l_excp_start_dt;
                     ELSE
                         --end the old entry to tasks/exceptions start
                         l_tbl(l_idx).end_time := l_excp_start_dt;
						 --exit the task/exception loop since the same
						 --task will probably apply to the next day's shift
						 EXIT;
                     END IF;
                 ELSIF (l_excp_start_dt = l_tbl(l_idx).start_time)
                 THEN
                     IF (l_excp_end_dt < l_tbl(l_idx).end_time)
                     THEN
                         --this is the case where tasks/exceptions are within
                         --a shift, so we're going to set the start of shift
                         --to the end of asks/exceptions
                         l_tbl(l_idx).start_time := l_excp_end_dt;
                     ELSE
                         --this is the case where tasks/exceptions completely
                         --overwrite shift, so delete the shift
                         l_tbl.delete(l_idx);
                         l_idx := l_idx-1;
						 --exit the task/exception loop since the same
						 --task will probably apply to the next day's shift
						 EXIT;
                     END IF;
                 ELSE
                     --l_excp_start_dt < l_tbl(l_idx).start_time
                     IF (l_excp_end_dt < l_tbl(l_idx).end_time)
                     THEN
                         --this is the case where tasks/exceptions start
                         --before the shift start and end before the shift end
                         l_tbl(l_idx).start_time := l_excp_end_dt;
                     ELSE
                         --this is the case where tasks/exceptions start
                         --before the shift start and end on or after the
                         --shift end. so delete
                         l_tbl.delete(l_idx);
                         l_idx := l_idx-1;
						 --exit the task/exception loop since the same
						 --task will probably apply to the next day's shift
						 EXIT;
                     END IF;
                 END IF;
               END IF;
               FETCH c_cal_except into
                  l_excp_start_dt,l_excp_end_dt,l_assign_start_dt,l_assign_end_dt;
               IF c_cal_except%NOTFOUND
               THEN
                  l_excp_start_dt := NULL;
                  l_excp_end_dt := NULL;
                  l_assign_start_dt := NULL;
                  l_assign_end_dt := NULL;
                  EXIT;
               END IF;
             END LOOP;
           END IF;
        END LOOP;

   -- Added for bug 3216561 by ABRAINA
   -- This code is added for handling geting the first available slot fast for the current day.
   -- It exist out from the main while loop.
   v_slot_found := 'N';
   if p_duration > 0 and p_get_available_slot = 'Y' then -- (3)
       for i in 1 .. l_tbl.count loop
           v_start_date := l_tbl(i).start_time;
           v_end_date   := l_tbl(i).end_time;
           IF (l_search_start_dt >= v_start_date)
           THEN
               v_slot_start_date :=  l_search_start_dt;
           ELSE
               v_slot_start_date := v_start_date;
           END IF;

           IF (l_search_end_dt <= v_end_date) THEN
              v_slot_end_date := l_search_end_dt;
           ELSE
              v_slot_end_date := v_end_date;
           END IF;
           -- Check if the requested duration falls between the duration of the available shift time and starttime + duration doesnt fall outside the shift end time.
           -- Modified by SBARAT on 15/03/2006 for bug# 5081907
           IF (((v_slot_end_date - v_slot_start_date)* 24) >= (round(p_duration*60)/60))
                                  AND ( v_slot_start_date + (round(p_duration*60)/(24*60)) <= v_slot_end_date) THEN
               v_slot_found := 'Y';
               x_shift.delete;
               x_shift(1).start_time  := v_slot_start_date;
		 --Change for Bug # 4400664 By MPADHIAR
		 --In case of UOM is minute(MIN) . It was truncating Second portion of the Calculated end_time
		 --So giving 1 Minute less for 2, 5, 8 ,...... 59 Minure Estimated Assigments.
               x_shift(1).end_time := v_slot_start_date + round(p_duration*60)/(24*60);
               x_shift(1).availability_type := l_tbl(i).availability_type;
               x_shift(1).shift_construct_id := l_tbl(i).shift_construct_id;
               EXIT;
           END IF;
       end loop;
   else
      -- store found shift constructs for this day in output pl/sql table
         for r in 1..l_tbl.count
          loop
        -- added this condition to avoid duplicate shifts being returned
            l_put := 1;
            for k in 1..x_shift.count
            loop
             if( (l_tbl(r).shift_construct_id = x_shift(k).shift_construct_id)
                    and ((l_tbl(r).start_time between x_shift(k).start_time and  x_shift(k).end_time)
                    or (l_tbl(r).end_time between x_shift(k).start_time and  x_shift(k).end_time)))
              then
                 l_put := 0;
                 exit;
              end if;
            end loop;
            if((l_prev_shift_id <> l_shift_id))
            then
               if(trunc(l_tbl(r).start_time) < l_shift_date)
               then
                   l_put := '0';
               end if;
            end if;
            if(l_put = 1)
            then
               l_idx := x_shift.count + 1;
             if l_tbl(r).start_time is not null and l_tbl(r).end_time is not null then  -- added for bug#2595871
               -- this if is added to avoid null assignment at output table.
                x_shift(l_idx).shift_construct_id := l_tbl(r).shift_construct_id;
                x_shift(l_idx).start_time         := l_tbl(r).start_time;
                x_shift(l_idx).end_time           := l_tbl(r).end_time;
                x_shift(l_idx).availability_type  := l_tbl(r).availability_type;
             end if;
            end if;
          end loop;
   end if; --(3)

   if  v_slot_found = 'Y' then
     exit;
   end if;
   l_shift_date := l_shift_date + 1;

  end loop;
  --close the big task/exception cursor
  close c_cal_except;
  if  v_slot_found = 'Y' then
    exit;
  end if;
end if; -- (shift assign check )
end loop; -- valid_cal_date

   --
   -- Update return status to Success if there is atleast one available time slot
    if x_shift.count > 1
    then
      -- sort the out table
       sort_tab(x_shift);
    end if;



EXCEPTION
  when g_exc_required_fields_null then
    x_return_status := fnd_api.g_ret_sts_error ;
    fnd_message.set_name('JTF','JTF_CAL_REQUIRED_PARAMETERS');
    fnd_message.set_token('P_PARAMETER', l_parameters);
    fnd_msg_pub.add;
    fnd_msg_pub.count_and_get ( p_count => x_msg_count
                      , p_data  => x_msg_data );

  when fnd_api.g_exc_unexpected_error then
    x_return_status := fnd_api.g_ret_sts_unexp_error;
    fnd_msg_pub.count_and_get ( p_count => x_msg_count
                      , p_data  => x_msg_data );
  when fnd_api.g_exc_error then
    x_return_status := fnd_api.g_ret_sts_unexp_error;
    fnd_msg_pub.count_and_get ( p_count => x_msg_count
                      , p_data  => x_msg_data );

  when G_EXC_INVALID_SLOT_DURATION then
    x_return_status := fnd_api.g_ret_sts_error ;
    fnd_message.set_name('JTF','JTF_CAL_INVALID_DURATION');
    fnd_msg_pub.add;
    fnd_msg_pub.count_and_get ( p_count => x_msg_count
                      , p_data  => x_msg_data );
   when others then
    x_return_status := fnd_api.g_ret_sts_unexp_error ;
    fnd_message.set_name('JTF','JTF_CAL_UNEXPECTED_ERROR');
    fnd_message.set_token('ERROR_CODE',sqlcode);
    fnd_message.set_token('ERROR_MESSAGE',sqlerrm);
    fnd_msg_pub.add;
    fnd_msg_pub.count_and_get ( p_count => x_msg_count
                      , p_data  => x_msg_data );
  END get_available_time_slot;

--*******************check valid resource ********************

-- ****************** Get Available Time  **********************
--
PROCEDURE Get_Available_Time
(   p_api_version   IN     NUMBER,
    p_init_msg_list IN     VARCHAR2:=FND_API.G_FALSE,
    p_resource_id   IN     NUMBER,
    p_resource_type IN     VARCHAR2,
    p_start_date    IN     DATE,
    p_end_date      IN     DATE,
    x_return_status OUT NOCOPY VARCHAR2,
    x_msg_count     OUT NOCOPY NUMBER,
    x_msg_data      OUT NOCOPY VARCHAR2,
    x_shift         OUT NOCOPY SHIFT_TBL_TYPE
)
IS

   l_api_name          CONSTANT VARCHAR2(30) := 'Get_Available_Time';
   l_api_version           CONSTANT NUMBER       := 1.0;
   l_return_status         VARCHAR2(1);
   l_msg_count             NUMBER;
   l_msg_data              VARCHAR2(250);
   l_shift                 SHIFT_TBL_TYPE;

BEGIN
    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
         FND_MSG_PUB.initialize;
    END IF;

    -- Call to check for required fields
    IF not check_for_required_fields (p_resource_id         =>p_resource_id,
                                      p_resource_type       =>p_resource_type,
                                      p_start_date          =>p_start_date,
                                      p_end_date            =>p_start_date)
    THEN
        l_parameters := 'p_resource_id, p_resource_type, p_start_date, p_end_date';
        RAISE G_EXC_REQUIRED_FIELDS_NULL;
    END IF;

     Get_Available_Time_slot
     (  p_api_version           => 1.0,
        p_resource_id           => p_resource_id,
        p_resource_type         => p_resource_type,
        p_start_date            => p_start_date,
        p_end_date              => p_end_date,
    	p_duration              => 0,
        p_get_available_slot    => 'N',
	x_return_status         => l_return_status,
        x_msg_count             => l_msg_count,
        x_msg_data              => l_msg_data,
        x_shift                 => x_shift
        );

  IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)
  THEN
      x_return_status := l_return_status;
      x_msg_count     := l_msg_count;
      x_msg_data      := l_msg_data;
  END IF;

EXCEPTION
  when g_exc_required_fields_null then
    x_return_status := fnd_api.g_ret_sts_error ;
    fnd_message.set_name('JTF','JTF_CAL_REQUIRED_PARAMETERS');
    fnd_message.set_token('P_PARAMETER', l_parameters);
    fnd_msg_pub.add;
    fnd_msg_pub.count_and_get ( p_count => x_msg_count
                      , p_data  => x_msg_data );

  when fnd_api.g_exc_unexpected_error then
    x_return_status := fnd_api.g_ret_sts_unexp_error;
    fnd_msg_pub.count_and_get ( p_count => x_msg_count
                      , p_data  => x_msg_data );
  when fnd_api.g_exc_error then
    x_return_status := fnd_api.g_ret_sts_unexp_error;
    fnd_msg_pub.count_and_get ( p_count => x_msg_count
                      , p_data  => x_msg_data );

  when others then
    x_return_status := fnd_api.g_ret_sts_unexp_error ;
    fnd_message.set_name('JTF','JTF_CAL_UNEXPECTED_ERROR');
    fnd_message.set_token('ERROR_CODE',sqlcode);
    fnd_message.set_token('ERROR_MESSAGE',sqlerrm);
    fnd_msg_pub.add;
    fnd_msg_pub.count_and_get ( p_count => x_msg_count
                      , p_data  => x_msg_data );
  END get_available_time;

--
-- ****************** Get Available Time Slot **********************
--
PROCEDURE Get_Available_Slot
    (p_api_version          IN      NUMBER      ,
    p_init_msg_list     IN      VARCHAR2 := FND_API.G_FALSE,
    p_resource_id       IN          NUMBER      ,
    p_resource_type     IN      VARCHAR2    ,
    p_start_date_time       IN      DATE        ,
        p_end_date_time         IN          DATE            ,
    p_duration          IN      NUMBER      ,
    x_return_status     OUT NOCOPY VARCHAR2     ,
    x_msg_count     OUT NOCOPY NUMBER       ,
    x_msg_data      OUT NOCOPY VARCHAR2 ,
    x_slot_start_date   OUT NOCOPY DATE     ,
        x_slot_end_date         OUT NOCOPY DATE     ,
        x_shift_construct_id    OUT NOCOPY NUMBER          ,
        x_availability_type     OUT NOCOPY VARCHAR2
)
IS
   l_api_name          CONSTANT VARCHAR2(30) := 'Get_Available_Slot';
   l_api_version           CONSTANT NUMBER       := 1.0;
   l_return_status         VARCHAR2(1);
   l_msg_count             NUMBER;
   l_msg_data              VARCHAR2(250);
   l_shift                 SHIFT_TBL_TYPE;
   v_start_date        DATE;
   v_end_date          DATE;
   v_slot_start_date       DATE;
   v_slot_end_date         DATE;

   v_count number;

BEGIN
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version ,
                                        p_api_version ,
                                        l_api_name ,
                                        G_PKG_NAME )
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Call to check for required fields
    IF not check_for_required_fields (p_resource_id     =>p_resource_id,
                                      p_resource_type   =>p_resource_type,
                                      p_start_date      =>p_start_date_time,
                                      p_end_date        =>p_end_date_time,
                                      p_duration        =>p_duration)
    THEN
        l_parameters := 'p_resource_id, p_resource_type, p_start_date_time, p_end_date_time, p_duration';
    RAISE G_EXC_REQUIRED_FIELDS_NULL;
    END IF;


    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

     Get_Available_Time_slot
     (  p_api_version           => 1.0,
        p_resource_id           => p_resource_id,
        p_resource_type         => p_resource_type,
        p_start_date            => p_start_date_time,
        p_end_date              => p_end_date_time,
    	p_duration              => p_duration,
        p_get_available_slot    => 'Y',
	x_return_status         => l_return_status,
        x_msg_count             => l_msg_count,
        x_msg_data              => l_msg_data,
        x_shift                 => l_shift
        );

  IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)
  THEN
  	  x_return_status := l_return_status;
      x_msg_count     := l_msg_count;
      x_msg_data      := l_msg_data;
  ELSE

  	  --always return the first element
  	  IF (l_shift.EXISTS(1))
  	  THEN
      	  x_slot_start_date    := l_shift(1).start_time;
      	  x_slot_end_date      := l_shift(1).end_time;
      	  x_availability_type  := l_shift(1).availability_type;
      	  x_shift_construct_id := l_shift(1).shift_construct_id;
  	  END IF;
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        FND_MSG_PUB.Count_And_Get
            (   p_count         =>      x_msg_count,
                p_data          =>      x_msg_data
            );
  WHEN  G_EXC_REQUIRED_FIELDS_NULL THEN
          x_return_status := FND_API.G_RET_STS_ERROR ;
          fnd_message.set_name('JTF','JTF_CAL_REQUIRED_PARAMETERS');
          fnd_message.set_token('P_PARAMETER', l_parameters);
          fnd_msg_pub.add;
      FND_MSG_PUB.Count_And_Get
            (p_count            =>      x_msg_count,
             p_data             =>      x_msg_data
            );
   when fnd_api.g_exc_error then
    x_return_status := fnd_api.g_ret_sts_unexp_error;
    fnd_msg_pub.count_and_get ( p_count => x_msg_count
                              , p_data  => x_msg_data );
  WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          fnd_message.set_name('JTF','JTF_CAL_UNEXPECTED_ERROR');
          fnd_message.set_token('ERROR_CODE',SQLCODE);
          fnd_message.set_token('ERROR_MESSAGE', SQLERRM);
          fnd_msg_pub.add;
      FND_MSG_PUB.Count_And_Get
         (p_count           =>      x_msg_count,
          p_data            =>      x_msg_data
         );

END Get_Available_Slot;
--
-- *************  Get Resource Shifts  *******************
--
PROCEDURE get_resource_shifts
( p_api_version   in  number
, p_init_msg_list in  varchar2 default fnd_api.g_false
, p_resource_id   in  number
, p_resource_type in  varchar2
, p_start_date    in  date
, p_end_date      in  date
, x_return_status out NOCOPY varchar2
, x_msg_count     out NOCOPY number
, x_msg_data      out NOCOPY varchar2
, x_shift     out NOCOPY shift_tbl_type
)
IS
  type rec_type is record
  ( shift_construct_id number
  , start_time         date
  , end_time           date
  , availability_type  varchar2(40) );

  type tbl_type is table of rec_type index by binary_integer;

  cursor shift_info(p_calendar_id NUMBER) is
  select shift_id,(shift_end_date - shift_start_date) shift_duration
    from jtf_cal_shift_assign
   where calendar_id = p_calendar_id
order by shift_sequence_number;

--  cursor c_cal_shift_constr(p_shift_id NUMBER, p_day date, p_uot_value NUMBER) is
--added by sudarsana 11th oct 2001
cursor c_cal_shift_constr(p_shift_id NUMBER,p_day date, p_uot_value DATE) is
select shift_construct_id,
       begin_time start_constr,
       end_time end_constr,
       availability_type_code
  from jtf_cal_shift_constructs
 where shift_id = p_shift_id
   and ((start_date_active <=p_day and end_date_active IS NULL)   /* bug# 2408759 */
             or (p_day between start_date_active and end_date_active))
          and (
                (
                   trunc(begin_time) <= trunc(p_uot_value)
                   and
                   trunc(end_time)  >= trunc(p_uot_value)
                 )
                 or
                (
               trunc(begin_time) <= to_date('1995/01/07','YYYY/MM/DD') +
                                        to_number(substr(to_char(trunc(p_uot_value), 'YYYY/MM/DD'),9,2))
               and
               trunc(end_time)  >= to_date('1995/01/07','YYYY/MM/DD') +
                                     to_number(substr(to_char(trunc(p_uot_value), 'YYYY/MM/DD'),9,2))
                )
              ) ;

cursor c_cal_except  ( p_calendar_id number, p_day date ) is
select e.start_date_time start_except
      ,e.end_date_time   end_except
  from jtf_cal_exception_assign a
      ,jtf_cal_exceptions_vl    e
 where a.calendar_id  = p_calendar_id
   and a.exception_id = e.exception_id
    -- validate exception assignment
   and (
        ( p_day >= trunc(a.start_date_active)
                  or a.start_date_active is null
        )
        and
        ( p_day <= trunc(a.end_date_active)
                  or a.end_date_active is null
        )
             -- validate exception
        and
        (
          p_day between trunc(e.start_date_time) and trunc(e.end_date_time)
        )
       );

  --added date validation for bug 1355824

  l_api_name        constant varchar2(30)   := 'Get_Resource_Shifts';
  l_api_version     constant number         := 1.0;
  l_parameters               varchar2(2000) := null;
  g_exc_required_fields_null exception;
  l_range_start              date;
  l_range_end                date;
  l_day                  date;
  l_utv                      varchar2(20);
  l_idx                      number := 0;
  l_tbl                  tbl_type;
  l_cnt                  number;
  l_shifts_total_duration    number;
  l_shift_date               date;
  l_left_days                number;
  l_calendar_id              number;
  l_shift_id number;

  l_calendar_name            jtf_calendars_vl.calendar_name%TYPE; -- bug # 2493461 varchar2(100)
  l_calendar_start_date      date;
  l_exp_flg                  varchar2(1) := 'N';
  l_start_date_time          date;

  l_utv_1          DATE;
  k                number;
  l_put            number := 1;
  l_diff           number;
  l_start_constr   date;
  l_process        varchar2(1) := 'Y';
  l_prev_shift_id  number;

  l_server_tz_id   Number :=   to_number (fnd_profile.value_specific('SERVER_TIMEZONE_ID'));
  l_res_Timezone_id Number;

  l_return_status varchar2(1) := FND_API.G_RET_STS_ERROR ;

  l_resource_name            jtf_task_resources_vl.resource_name%TYPE;-- bug # 2418561

BEGIN

  -- standard call to check for call compatibility.
  if not fnd_api.compatible_api_call
         ( l_api_version
         , p_api_version
         , l_api_name
         , g_pkg_name )
  then
    raise fnd_api.g_exc_unexpected_error;
  end if;

  -- initialize message list if p_init_msg_list is set to true.
  if fnd_api.to_boolean ( p_init_msg_list )
  then
    fnd_msg_pub.initialize;
  end if;

  -- call to check for required fields
  if not check_for_required_fields
         ( p_resource_id   => p_resource_id
         , p_resource_type => p_resource_type
         , p_start_date    => p_start_date
         , p_end_date      => p_start_date )
  then
    l_parameters := 'p_resource_id, p_resource_type, p_start_date, p_end_date';
    raise g_exc_required_fields_null;
  end if;

  -- This code is added to get resource name to be printed in error message.
  -- Added for Bug 4063687
  BEGIN
    select resource_name
    into l_resource_name
    --from jtf_rs_all_resources_vl
    --Modified by jawang to fix the bug 2416932
    from jtf_task_resources_vl
    where resource_id = p_resource_id
    and  resource_type = p_resource_type;
  EXCEPTION
    WHEN Others THEN
    NULL;
  END;

  -- initialize api return status to success
  x_return_status := fnd_api.g_ret_sts_success;

  l_shift_date := trunc(p_start_date);
while l_shift_date <= p_end_date Loop

  -- get the primary calendar for a resource on the given date
  --
    begin --(1)
     select a.calendar_id,b.calendar_name,b.start_date_active,a.start_date_time
     into   l_calendar_id,l_calendar_name,l_calendar_start_date,l_start_date_time
     from   jtf_cal_resource_assign a,
              jtf_calendars_vl b
     where  a.resource_id = p_resource_id
     and    a.resource_type_code = p_resource_type
     and    a.calendar_id = b.calendar_id
     and    a.primary_calendar_flag = 'Y'
--  Commented for bug 3891896 by ABRAINA
--     and    l_shift_date between trunc(a.start_date_time) and nvl(trunc(a.end_date_time),to_date(get_g_miss_date,'DD/MM/RRRR'));
     and    l_shift_date between trunc(a.start_date_time) and nvl(trunc(a.end_date_time),l_shift_date);

     -- Added for bug 3270116
     l_return_status := FND_API.G_RET_STS_SUCCESS;

     -- added for bug 1355824
     -- if condition added for bug 3270116 by ABRAINA
     IF Validate_Cal_Date(l_calendar_id, l_shift_date)
     THEN

       l_tbl.delete;
       l_idx := 0;

      BEGIN -- (2)
         select sum(shift_end_date - shift_start_date)
         into   l_shifts_total_duration
         from   jtf_cal_shift_assign
         where  calendar_id = l_calendar_id;

         l_left_days := mod((l_shift_date - l_calendar_start_date),l_shifts_total_duration);

	 l_shift_id := null;
         for c in shift_info(l_calendar_id) loop
         l_left_days := l_left_days - c.shift_duration;
         IF l_left_days <  0 THEN
            l_prev_shift_id := l_shift_id;
            l_shift_id := c.shift_id;
            EXIT;
         END IF;
         end loop;

       -- Added by Sarvi
       -- calculate unit of time value
       -- this is dependant on nls setting
       --l_utv := to_char(l_shift_date,'d');

       --changed l_utv by sudarsana for 24 hr shifts and nls issue 11th oct 2001
       l_utv := to_char(l_shift_date, 'DAY');

         if(to_char(to_date('1995/01/01', 'YYYY/MM/DD'), 'DAY') = to_char(l_shift_date, 'DAY'))
         then
            l_utv_1 := to_date('1995/01/01', 'YYYY/MM/DD');
         elsif(to_char(to_date('1995/01/02', 'YYYY/MM/DD'), 'DAY') = to_char(l_shift_date, 'DAY'))
         then
            l_utv_1 := to_date('1995/01/02', 'YYYY/MM/DD');
         elsif(to_char(to_date('1995/01/03', 'YYYY/MM/DD'), 'DAY') = to_char(l_shift_date, 'DAY'))
         then
            l_utv_1 := to_date('1995/01/03', 'YYYY/MM/DD');
         elsif(to_char(to_date('1995/01/04', 'YYYY/MM/DD'), 'DAY') = to_char(l_shift_date, 'DAY'))
         then
            l_utv_1 := to_date('1995/01/04', 'YYYY/MM/DD');
         elsif(to_char(to_date('1995/01/05', 'YYYY/MM/DD'), 'DAY') = to_char(l_shift_date, 'DAY'))
         then
            l_utv_1 := to_date('1995/01/05', 'YYYY/MM/DD');
         elsif(to_char(to_date('1995/01/06', 'YYYY/MM/DD'), 'DAY') = to_char(l_shift_date, 'DAY'))
         then
            l_utv_1 := to_date('1995/01/06', 'YYYY/MM/DD');
         elsif(to_char(to_date('1995/01/07', 'YYYY/MM/DD'), 'DAY') = to_char(l_shift_date, 'DAY'))
         then
            l_utv_1 := to_date('1995/01/07', 'YYYY/MM/DD');
         end if;

      l_tbl.delete;
      l_idx := 0;
      /* for j in c_cal_shift_constr ( l_shift_id
                                  , l_shift_date
                                   l_utv )*/

      FOR j in c_cal_shift_constr(l_shift_id,l_shift_date, l_utv_1)
      LOOP
        l_idx := l_idx + 1;
        l_tbl(l_idx).shift_construct_id := j.shift_construct_id;
        -- The date part of the shift construct start is just a container
        -- without real meaning. In order to process the multi-day
        -- exceptions more easily, the requested day is added to it, so
        -- that the resulting datetime has a real meaning.
        /*l_tbl(l_idx).start_time         := l_shift_date + ( j.start_constr -
                                                     trunc(j.start_constr) );
        l_tbl(l_idx).end_time           := l_shift_date + ( j.end_constr -
                                                     trunc(j.end_constr) );
        commented this out by sudarsana 11th oct 2001 */
         --added this if cond if start_date passed in is not in the same day as the shift start date -- sudarsana
         if(to_char(l_shift_date, 'DAY') <> to_char(j.start_constr , 'DAY'))
         then
            if(trunc(j.end_constr) > to_date('1995/01/07', 'YYYY/MM/DD'))
            then
              l_diff := 0;
              l_start_constr := j.start_constr;
              while(to_char(l_start_constr , 'DAY') <> to_char(l_shift_date, 'DAY'))
              loop
                 l_diff := l_diff +1;
                 l_start_constr := l_start_constr + 1;
               end loop;
               l_tbl(l_idx).start_time := (l_shift_date - l_diff) + (j.start_constr - trunc(j.start_constr));
            else
               l_tbl(l_idx).start_time := (l_shift_date - (l_utv_1 - trunc(j.start_constr))) + (j.start_constr - trunc(j.start_constr));
            end if;
         else
            l_tbl(l_idx).start_time := l_shift_date + (j.start_constr - trunc(j.start_constr));
         end if;
        l_tbl(l_idx).end_time   := l_tbl(l_idx).start_time + (to_number(j.end_constr - j.start_constr) * 24)/24;
        l_tbl(l_idx).availability_type  := j.availability_type_code;
      end loop;

      -- deduct all exceptions from working hours on the requested day
      -- exceptions can consist of more than one day
      for m in c_cal_except ( l_calendar_id
                            , l_shift_date )
      loop  -- loop the exception cursor
         l_cnt := l_tbl.count;

        for n in 1..l_cnt
        loop   -- loop thru the table loaded with shifts.

          -- If we find an exception satisfying this condition then, we have
          -- to change the start/end time of the shifts accordingly. Like shift 8 - 16
          -- and exception 10-11, then we need to split the record into two like
          -- 8 - 10 and 11 - 16, showing the resource availablity.

          if  m.start_except > l_tbl(n).start_time
          and m.start_except < l_tbl(n).end_time
          and m.end_except   > l_tbl(n).start_time
          and m.end_except  < l_tbl(n).end_time
          then
            -- an extra entry is created at the end of the pl/sql table
            -- is it a problem that the ordering is disrupted this way?
            l_idx := l_tbl.count + 1;
            l_tbl(l_idx).shift_construct_id := l_tbl(n).shift_construct_id;
            l_tbl(l_idx).start_time         := m.end_except; -- this is for the new entry
            l_tbl(l_idx).end_time           := l_tbl(n).end_time; -- this is for the new entry
            l_tbl(l_idx).availability_type  := l_tbl(n).availability_type;
            l_tbl(n).end_time               := m.start_except;  -- This changes the existing entries end_time.

      elsif m.start_except < l_tbl(n).start_time
          and   m.end_except   > l_tbl(n).start_time
          and   m.end_except   < l_tbl(n).end_time
          then
              l_tbl(n).start_time := m.end_except;
            --l_tbl(n).end_time := m.start_except;

      elsif m.start_except > l_tbl(n).start_time
      and   m.start_except < l_tbl(n).end_time
          and   m.end_except   > l_tbl(n).end_time
          then
             l_tbl(n).end_time := m.start_except;
          -- added on 28, Sep 2000 start
          elsif m.start_except >= l_tbl(n).start_time
      and   m.start_except < l_tbl(n).end_time
          and   m.end_except   < l_tbl(n).end_time
          then
               l_tbl(n).start_time := m.end_except;

          elsif m.start_except > l_tbl(n).start_time
          and   m.start_except < l_tbl(n).end_time
          and   m.end_except   <= l_tbl(n).end_time
          then
               l_tbl(n).end_time := m.start_except;
          -- added on 28, Sep 2000 end
      elsif m.start_except = l_tbl(n).start_time
          and   m.end_except   = l_tbl(n).end_time
          then
            l_tbl(n).start_time        := null;
            l_tbl(n).end_time          := null;
            l_tbl(n).availability_type := null;
            l_tbl.delete;

          elsif  m.start_except = l_tbl(n).start_time
      and m.end_except   < l_tbl(n).end_time
          then
            l_tbl(n).start_time        := null;
            l_tbl(n).end_time          := null;
            l_tbl(n).availability_type := null;
            l_tbl.delete;

          elsif  m.start_except < l_tbl(n).start_time -- When exception falls out of the range
      and m.end_except   >l_tbl(n).end_time
          then
            l_tbl.delete;
      -- added jan10, 2001 start
          elsif  m.start_except = l_tbl(n).start_time
      and m.end_except   > l_tbl(n).end_time
          then
            l_tbl(n).start_time        := null;
            l_tbl(n).end_time          := null;
            l_tbl(n).availability_type := null;
            l_tbl.delete;

          elsif  m.start_except < l_tbl(n).start_time
      and m.end_except   = l_tbl(n).end_time
          then
            l_tbl(n).start_time        := null;
            l_tbl(n).end_time          := null;
            l_tbl(n).availability_type := null;
            l_tbl.delete;
          -- added jan10, 2001 end
          end if;

          if l_exp_flg = 'Y' THEN
            l_tbl.delete; -- if we find the exception and shift times are same then delete the row from table of records.
          end if;
        end loop;
      end loop;

      --
      --  Added for Simplex Timezone Enh # 3040681 by ABRAINA
      --
      If fnd_profile.value_specific('ENABLE_TIMEZONE_CONVERSIONS') = 'Y' Then
        l_res_Timezone_id := Get_Res_Timezone_Id (p_resource_id, p_resource_type);
        If l_res_Timezone_id <> l_server_tz_id Then
          l_idx := 0;
          For r in 1..l_tbl.count loop
            l_idx := l_idx + 1;
            l_tbl(l_idx).start_time := ResourceDt_To_ServerDT(l_tbl(l_idx).start_time,l_res_Timezone_id,l_server_tz_id);
            l_tbl(l_idx).end_time := ResourceDt_To_ServerDT(l_tbl(l_idx).end_time,l_res_Timezone_id,l_server_tz_id);
          End Loop;
        End If;
      End If;

      l_process := 'Y';
    --added cond not to process overlapping dates added 19oct 2001

      if(l_process = 'Y')
      then
         -- store found shift constructs for this day in output pl/sql table
         for r in 1..l_tbl.count
         loop
         -- added this condition to avoid duplicate shifts being returned
            l_put := 1;
            for k in 1..x_shift.count
            loop
             if( (l_tbl(r).shift_construct_id = x_shift(k).shift_construct_id)
                    and ((l_tbl(r).start_time between x_shift(k).start_time and  x_shift(k).end_time)
                    or (l_tbl(r).end_time between x_shift(k).start_time and  x_shift(k).end_time)))
             then
                 l_put := 0;
                 exit;
              end if;
            end loop;
            if((l_prev_shift_id <> l_shift_id))
            then
               if(trunc(l_tbl(r).start_time) < l_shift_date)
               then
                        l_put := '0';
                end if;
            end if;
            if(l_put = 1)
            then
                l_idx := x_shift.count + 1;
                x_shift(l_idx).shift_construct_id := l_tbl(r).shift_construct_id;
                -- changed as the times are now of type date
                x_shift(l_idx).start_time         := l_tbl(r).start_time;
                x_shift(l_idx).end_time           := l_tbl(r).end_time;
                x_shift(l_idx).availability_type  := l_tbl(r).availability_type;

             end if;
          end loop;
       end if; -- end of l_process
      exception
        when no_data_found then
        x_return_status := FND_API.G_RET_STS_ERROR ;
        -- Added for bug 3270116
        l_return_status := FND_API.G_RET_STS_ERROR ;
        -- end
	fnd_message.set_name('JTF','JTF_CAL_NO_SHIFTS');
        fnd_message.set_token('P_CAL_NAME', l_calendar_name);
        fnd_msg_pub.add;
    FND_MSG_PUB.Count_And_Get
          (p_count          =>      x_msg_count,
           p_data           =>      x_msg_data
          );
      end; --2
     end if; -- valid cal end if

    exception
      when no_data_found then
        x_return_status := FND_API.G_RET_STS_ERROR ;
        -- No Need to set l_return_status to FND_API.G_RET_STS_ERROR
	-- as for this exception we want to handle it.
	-- For a resource, even if a single shift is returned for a search window
	-- it will return 'S'. This is as per requirement from Field service and Gantt guys.
	l_tbl.delete;  -- to delete the record from TOR if no shift found
        fnd_message.set_name('JTF','JTF_CAL_RES_NO_CAL');
        fnd_message.set_token('P_SHIFT_DATE', l_shift_date);
        fnd_message.set_token('P_RES_NAME', l_resource_name);
        fnd_msg_pub.add;

    FND_MSG_PUB.Count_And_Get
          (p_count          =>      x_msg_count,
           p_data           =>      x_msg_data
          );
    end; -- 1
     l_shift_date := l_shift_date + 1;
end loop;

  -- see if shift constructs have been found
  if x_shift.count = 0
  then
    x_return_status := fnd_api.g_ret_sts_error ;
    -- Added for bug 3270116
    l_return_status := FND_API.G_RET_STS_ERROR ;
    -- end
    fnd_message.set_name('JTF','JTF_CAL_NO_SHIFT_CONSTR_FOUND');
    fnd_msg_pub.add;

    fnd_msg_pub.count_and_get( p_count => x_msg_count
                             , p_data  => x_msg_data );
  end if;


    if x_shift.count > 0
    then
    -- sort the out table
       sort_tab(x_shift);

    end if;

    -- Added for bug 3270116
    -- For a resource, even if a single shift is returned for any search window
    -- it will return 'S'. This is as per requirement from Field service and Gantt guys.
    if l_return_status = FND_API.G_RET_STS_SUCCESS then
           x_return_status := FND_API.G_RET_STS_SUCCESS;
    else
           x_return_status := FND_API.G_RET_STS_ERROR ;
    end if;
    -- end
EXCEPTION
  when g_exc_required_fields_null then
    x_return_status := fnd_api.g_ret_sts_error ;
    fnd_message.set_name('JTF','JTF_CAL_REQUIRED_PARAMETERS');
    fnd_message.set_token('P_PARAMETER', l_parameters);
    fnd_msg_pub.add;
    fnd_msg_pub.count_and_get ( p_count => x_msg_count
                      , p_data  => x_msg_data );

  when fnd_api.g_exc_unexpected_error then
    x_return_status := fnd_api.g_ret_sts_unexp_error;
    fnd_msg_pub.count_and_get ( p_count => x_msg_count
                      , p_data  => x_msg_data );
  when fnd_api.g_exc_error then
    x_return_status := fnd_api.g_ret_sts_unexp_error;
    fnd_msg_pub.count_and_get ( p_count => x_msg_count
                              , p_data  => x_msg_data );

  when others then
    x_return_status := fnd_api.g_ret_sts_unexp_error ;
    fnd_message.set_name('JTF','JTF_CAL_UNEXPECTED_ERROR');
    fnd_message.set_token('ERROR_CODE',sqlcode);
    fnd_message.set_token('ERROR_MESSAGE',sqlerrm);
    fnd_msg_pub.count_and_get ( p_count => x_msg_count
                      , p_data  => x_msg_data );
END get_resource_shifts;
--

--
-- **********  Get Resource Shifts with 15 attributes ***********
--

PROCEDURE get_resource_shifts
( p_api_version   in  number
, p_init_msg_list in  varchar2 default fnd_api.g_false
, p_resource_id   in  number
, p_resource_type in  varchar2
, p_start_date    in  date
, p_end_date      in  date
, x_return_status out NOCOPY varchar2
, x_msg_count     out NOCOPY number
, x_msg_data      out NOCOPY varchar2
, x_shift     out NOCOPY shift_tbl_attributes_type
)
IS
  type rec_attributes_type is record
  ( shift_construct_id number
  , start_time         date
  , end_time           date
  , availability_type  varchar2(40)
  , attribute1         varchar2(150)
  , attribute2         varchar2(150)
  , attribute3         varchar2(150)
  , attribute4         varchar2(150)
  , attribute5         varchar2(150)
  , attribute6         varchar2(150)
  , attribute7         varchar2(150)
  , attribute8         varchar2(150)
  , attribute9         varchar2(150)
  , attribute10        varchar2(150)
  , attribute11        varchar2(150)
  , attribute12        varchar2(150)
  , attribute13        varchar2(150)
  , attribute14        varchar2(150)
  , attribute15        varchar2(150)
  );

  type tbl_attributes_type is table of rec_attributes_type index by binary_integer;

/*  type rec_type is record
  ( shift_construct_id number
  , start_time         date
  , end_time           date
  , availability_type  varchar2(40) );

  type tbl_type is table of rec_type index by binary_integer; */

  cursor shift_info(p_calendar_id NUMBER) is
    select shift_id,(shift_end_date - shift_start_date) shift_duration
    from   jtf_cal_shift_assign
    where  calendar_id = p_calendar_id
    order by shift_sequence_number;

--  cursor c_cal_shift_constr(p_shift_id NUMBER, p_day date, p_uot_value NUMBER) is
--added by sudarsana 11th oct 2001
-- added attributes sudhir 25/04/2002
    cursor c_cal_shift_constr(p_shift_id NUMBER,p_day date, p_uot_value DATE) is
    select shift_construct_id,
           begin_time start_constr,
           end_time end_constr,
           availability_type_code,
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
           attribute15
    from   jtf_cal_shift_constructs
    where  shift_id = p_shift_id
        and ((start_date_active <=p_day and end_date_active IS NULL)  /* bug# 2408759 */
             or (p_day between start_date_active and end_date_active))
--  and    unit_of_time_value = p_uot_value;
--added by sudarsana 11th oct 2001
         and (
                (
                   trunc(begin_time) <= trunc(p_uot_value)
                   and
                   trunc(end_time)  >= trunc(p_uot_value)
                 )
                 or
                (
               trunc(begin_time) <= to_date('1995/01/07','YYYY/MM/DD') +
                                        to_number(substr(to_char(trunc(p_uot_value), 'YYYY/MM/DD'),9,2))
               and
               trunc(end_time)  >= to_date('1995/01/07','YYYY/MM/DD') +
                                     to_number(substr(to_char(trunc(p_uot_value), 'YYYY/MM/DD'),9,2))
                )
              ) ;

  cursor c_cal_except
  ( p_calendar_id number
  , p_day         date )
  is
--changed cur .. sudarsana for  24 hr shifts
     select e.start_date_time start_except
    ,      e.end_date_time   end_except
    from jtf_cal_exception_assign a
    ,    jtf_cal_exceptions_vl    e
    where a.calendar_id  = p_calendar_id
    and   a.exception_id = e.exception_id
    -- validate exception assignment
    and   (
               ( p_day >= trunc(a.start_date_active)
                       or a.start_date_active is null
               )
             and
              ( p_day <= trunc(a.end_date_active)
                           or a.end_date_active is null
              )
             -- validate exception
             and
               (
                  p_day between trunc(e.start_date_time) and trunc(e.end_date_time)
                )
           );


  -- added date validation for bug 1355824

  l_api_name        constant varchar2(30)   := 'Get_Resource_Shifts';
  l_api_version     constant number         := 1.0;
  l_parameters               varchar2(2000) := null;
  g_exc_required_fields_null exception;
  l_range_start              date;
  l_range_end                date;
  l_day                  date;
  l_utv                      varchar2(20);
  l_idx                      number := 0;
  l_tbl                  tbl_attributes_type;
  l_cnt                  number;
  l_shifts_total_duration number;
  l_shift_date date;
  l_left_days number;
  l_calendar_id number;
  l_shift_id number;

  l_calendar_name  jtf_calendars_vl.calendar_name%TYPE; -- bug 2493461 varchar2(100);
  l_calendar_start_date date;
  l_exp_flg varchar2(1) := 'N';
  l_start_date_time date;

  l_utv_1          DATE;
  k                number;
  l_put            number := 1;
  l_diff           number;
  l_start_constr   date;
  l_process        varchar2(1) := 'Y';
  l_prev_shift_id  number;

  l_server_tz_id   Number :=   to_number (fnd_profile.value_specific('SERVER_TIMEZONE_ID'));
  l_res_Timezone_id Number;

  l_return_status varchar2(1) := FND_API.G_RET_STS_ERROR ;

  l_resource_name            jtf_task_resources_vl.resource_name%TYPE;-- bug # 2418561

BEGIN
  -- standard call to check for call compatibility.
  if not fnd_api.compatible_api_call
         ( l_api_version
         , p_api_version
         , l_api_name
         , g_pkg_name )
  then
    raise fnd_api.g_exc_unexpected_error;
  end if;

  -- initialize message list if p_init_msg_list is set to true.
  if fnd_api.to_boolean ( p_init_msg_list )
  then
    fnd_msg_pub.initialize;
  end if;

  -- call to check for required fields
  if not check_for_required_fields
         ( p_resource_id   => p_resource_id
         , p_resource_type => p_resource_type
         , p_start_date    => p_start_date
         , p_end_date      => p_start_date )
  then
    l_parameters := 'p_resource_id, p_resource_type, p_start_date, p_end_date';
    raise g_exc_required_fields_null;
  end if;


  -- initialize api return status to success
  x_return_status := fnd_api.g_ret_sts_success;

  -- This code is added to get resource name to be printed in error message.
  -- Added for Bug 4063687
  BEGIN
    select resource_name
    into l_resource_name
    --from jtf_rs_all_resources_vl
    --Modified by jawang to fix the bug 2416932
    from jtf_task_resources_vl
    where resource_id = p_resource_id
    and  resource_type = p_resource_type;
  EXCEPTION
    WHEN Others THEN
    NULL;
  END;

  -- bug# 1344222
  -- Comment out by jawang on 06/17/2002
  --if not check_resource_status(p_resource_id,p_resource_type) THEN
  --    raise g_exc_not_valid_resource;
  --end if;

  -- get all valid resource-to-calendar assignments for this resource in
  -- this period ordered by start date
  -- because there is a primary flag, only one record is expected

  l_shift_date := trunc(p_start_date);


while l_shift_date <= p_end_date Loop


     -- We first check if there is a valid primary calendar on this date.
     -- get the primary calendar for a resource on the given date
     --
     begin --(1)
       select a.calendar_id,b.calendar_name,b.start_date_active,a.start_date_time
       into   l_calendar_id,l_calendar_name,l_calendar_start_date,l_start_date_time
       from   jtf_cal_resource_assign a,
              jtf_calendars_vl b
       where  a.resource_id = p_resource_id
       and    a.resource_type_code = p_resource_type
       and    a.calendar_id = b.calendar_id
       and    a.primary_calendar_flag = 'Y'
--  Commented for bug 3891896 by ABRAINA
--       and    l_shift_date between trunc(a.start_date_time) and nvl(trunc(a.end_date_time),to_date(get_g_miss_date,'DD/MM/RRRR'));
       and    l_shift_date between trunc(a.start_date_time) and nvl(trunc(a.end_date_time),l_shift_date);

       -- Added for bug 3270116
       l_return_status := FND_API.G_RET_STS_SUCCESS;

       --added l_shift_date in valid_cal loop bug #1355824
       -- if condition added for bug 3270116 by ABRAINA
       IF Validate_Cal_Date(l_calendar_id, l_shift_date)
       THEN

       l_tbl.delete;
       l_idx := 0;

       BEGIN --(2)
        select sum(shift_end_date - shift_start_date)
        into   l_shifts_total_duration
        from   jtf_cal_shift_assign
        where  calendar_id = l_calendar_id;

        l_left_days := mod((l_shift_date - l_calendar_start_date),l_shifts_total_duration);

        l_shift_id := null;
	for c in shift_info(l_calendar_id) loop
           l_left_days := l_left_days - c.shift_duration;
         IF l_left_days <  0 THEN
           l_prev_shift_id := l_shift_id;
           l_shift_id := c.shift_id;
           EXIT;
         END IF;
        end loop;

      -- Added by Sarvi
      -- calculate unit of time value
      -- this is dependant on nls setting
      --l_utv := to_char(l_shift_date,'d');

      --changed l_utv by sudarsana for 24 hr shifts and nls issue 11th oct 2001
       l_utv := to_char(l_shift_date, 'DAY');

         if(to_char(to_date('1995/01/01', 'YYYY/MM/DD'), 'DAY') = to_char(l_shift_date, 'DAY'))
         then
            l_utv_1 := to_date('1995/01/01', 'YYYY/MM/DD');
         elsif(to_char(to_date('1995/01/02', 'YYYY/MM/DD'), 'DAY') = to_char(l_shift_date, 'DAY'))
         then
            l_utv_1 := to_date('1995/01/02', 'YYYY/MM/DD');
         elsif(to_char(to_date('1995/01/03', 'YYYY/MM/DD'), 'DAY') = to_char(l_shift_date, 'DAY'))
         then
            l_utv_1 := to_date('1995/01/03', 'YYYY/MM/DD');
         elsif(to_char(to_date('1995/01/04', 'YYYY/MM/DD'), 'DAY') = to_char(l_shift_date, 'DAY'))
         then
            l_utv_1 := to_date('1995/01/04', 'YYYY/MM/DD');
         elsif(to_char(to_date('1995/01/05', 'YYYY/MM/DD'), 'DAY') = to_char(l_shift_date, 'DAY'))
         then
            l_utv_1 := to_date('1995/01/05', 'YYYY/MM/DD');
         elsif(to_char(to_date('1995/01/06', 'YYYY/MM/DD'), 'DAY') = to_char(l_shift_date, 'DAY'))
         then
            l_utv_1 := to_date('1995/01/06', 'YYYY/MM/DD');
         elsif(to_char(to_date('1995/01/07', 'YYYY/MM/DD'), 'DAY') = to_char(l_shift_date, 'DAY'))
         then
            l_utv_1 := to_date('1995/01/07', 'YYYY/MM/DD');
         end if;

      l_tbl.delete;
      l_idx := 0;

      FOR j in c_cal_shift_constr(l_shift_id,l_shift_date, l_utv_1)
      LOOP
        l_idx := l_idx + 1;
        l_tbl(l_idx).shift_construct_id := j.shift_construct_id;
        -- The date part of the shift construct start is just a container
        -- without real meaning. In order to process the multi-day
        -- exceptions more easily, the requested day is added to it, so
        -- that the resulting datetime has a real meaning.
         --added this if cond if start_date passed in is not in the same day as the shift start date -- sudarsana
         if(to_char(l_shift_date, 'DAY') <> to_char(j.start_constr , 'DAY'))
         then
            if(trunc(j.end_constr) > to_date('1995/01/07', 'YYYY/MM/DD'))
            then
              l_diff := 0;
              l_start_constr := j.start_constr;
              while(to_char(l_start_constr , 'DAY') <> to_char(l_shift_date, 'DAY'))
              loop
                 l_diff := l_diff +1;
                 l_start_constr := l_start_constr + 1;
               end loop;
               l_tbl(l_idx).start_time := (l_shift_date - l_diff) + (j.start_constr - trunc(j.start_constr));
            else
               l_tbl(l_idx).start_time := (l_shift_date - (l_utv_1 - trunc(j.start_constr))) + (j.start_constr - trunc(j.start_constr));
            end if;
         else
            l_tbl(l_idx).start_time := l_shift_date + (j.start_constr - trunc(j.start_constr));
         end if;
        l_tbl(l_idx).end_time   := l_tbl(l_idx).start_time + (to_number(j.end_constr - j.start_constr) * 24)/24;
        l_tbl(l_idx).availability_type  := j.availability_type_code;

        -- Added by Sudhir on 25/04/2002
        l_tbl(l_idx).attribute1  := j.attribute1;
        l_tbl(l_idx).attribute2  := j.attribute2;
        l_tbl(l_idx).attribute3  := j.attribute3;
        l_tbl(l_idx).attribute4  := j.attribute4;
        l_tbl(l_idx).attribute5  := j.attribute5;
        l_tbl(l_idx).attribute6  := j.attribute6;
        l_tbl(l_idx).attribute7  := j.attribute7;
        l_tbl(l_idx).attribute8  := j.attribute8;
        l_tbl(l_idx).attribute9  := j.attribute9;
        l_tbl(l_idx).attribute10 := j.attribute10;
        l_tbl(l_idx).attribute11 := j.attribute11;
        l_tbl(l_idx).attribute12 := j.attribute12;
        l_tbl(l_idx).attribute13 := j.attribute13;
        l_tbl(l_idx).attribute14 := j.attribute14;
        l_tbl(l_idx).attribute15 := j.attribute15;

      end loop;


      -- deduct all exceptions from working hours on the requested day
      -- exceptions can consist of more than one day
      for m in c_cal_except ( l_calendar_id
                            , l_shift_date )
      loop  -- loop the exception cursor
         l_cnt := l_tbl.count;

        for n in 1..l_cnt
        loop   -- loop thru the table loaded with shifts.

          -- If we find an exception satisfying this condition then, we have
          -- to change the start/end time of the shifts accordingly. Like shift 8 - 16
          -- and exception 10-11, then we need to split the record into two like
          -- 8 - 10 and 11 - 16, showing the resource availablity.

          if  m.start_except > l_tbl(n).start_time
          and m.start_except < l_tbl(n).end_time
          and m.end_except   > l_tbl(n).start_time
          and m.end_except  < l_tbl(n).end_time
          then
            -- an extra entry is created at the end of the pl/sql table
            -- is it a problem that the ordering is disrupted this way?
            l_idx := l_tbl.count + 1;
            l_tbl(l_idx).shift_construct_id := l_tbl(n).shift_construct_id;
            l_tbl(l_idx).start_time         := m.end_except; -- this is for the new entry
            l_tbl(l_idx).end_time           := l_tbl(n).end_time; -- this is for the new entry
            l_tbl(l_idx).availability_type  := l_tbl(n).availability_type;

            -- Added by Sudhir on 25/04/2002
        l_tbl(l_idx).attribute1  := l_tbl(n).attribute1;
        l_tbl(l_idx).attribute2  := l_tbl(n).attribute2;
        l_tbl(l_idx).attribute3  := l_tbl(n).attribute3;
        l_tbl(l_idx).attribute4  := l_tbl(n).attribute4;
        l_tbl(l_idx).attribute5  := l_tbl(n).attribute5;
        l_tbl(l_idx).attribute6  := l_tbl(n).attribute6;
        l_tbl(l_idx).attribute7  := l_tbl(n).attribute7;
        l_tbl(l_idx).attribute8  := l_tbl(n).attribute8;
        l_tbl(l_idx).attribute9  := l_tbl(n).attribute9;
        l_tbl(l_idx).attribute10 := l_tbl(n).attribute10;
        l_tbl(l_idx).attribute11 := l_tbl(n).attribute11;
        l_tbl(l_idx).attribute12 := l_tbl(n).attribute12;
        l_tbl(l_idx).attribute13 := l_tbl(n).attribute13;
        l_tbl(l_idx).attribute14 := l_tbl(n).attribute14;
        l_tbl(l_idx).attribute15 := l_tbl(n).attribute15;


            l_tbl(n).end_time               := m.start_except;  -- This changes the existing entries end_time.

      elsif m.start_except < l_tbl(n).start_time
          and   m.end_except   > l_tbl(n).start_time
          and   m.end_except   < l_tbl(n).end_time
          then
              l_tbl(n).start_time := m.end_except;
            --l_tbl(n).end_time := m.start_except;

      elsif m.start_except > l_tbl(n).start_time
      and   m.start_except < l_tbl(n).end_time
          and   m.end_except   > l_tbl(n).end_time
          then
             l_tbl(n).end_time := m.start_except;
          -- added on 28, Sep 2000 start
          elsif m.start_except >= l_tbl(n).start_time
      and   m.start_except < l_tbl(n).end_time
          and   m.end_except   < l_tbl(n).end_time
          then
               l_tbl(n).start_time := m.end_except;

          elsif m.start_except > l_tbl(n).start_time
          and   m.start_except < l_tbl(n).end_time
          and   m.end_except   <= l_tbl(n).end_time
          then
               l_tbl(n).end_time := m.start_except;
          -- added on 28, Sep 2000 end
      elsif m.start_except = l_tbl(n).start_time
          and   m.end_except   = l_tbl(n).end_time
          then
            l_tbl(n).start_time        := null;
            l_tbl(n).end_time          := null;
            l_tbl(n).availability_type := null;

            -- Added by Sudhir on 25/04/2002
        l_tbl(n).attribute1  := null;
        l_tbl(n).attribute2  := null;
        l_tbl(n).attribute3  := null;
        l_tbl(n).attribute4  := null;
        l_tbl(n).attribute5  := null;
        l_tbl(n).attribute6  := null;
        l_tbl(n).attribute7  := null;
        l_tbl(n).attribute8  := null;
        l_tbl(n).attribute9  := null;
        l_tbl(n).attribute10 := null;
        l_tbl(n).attribute11 := null;
        l_tbl(n).attribute12 := null;
        l_tbl(n).attribute13 := null;
        l_tbl(n).attribute14 := null;
        l_tbl(n).attribute15 := null;

            l_tbl.delete;

          elsif  m.start_except = l_tbl(n).start_time
      and m.end_except   < l_tbl(n).end_time
          then
            l_tbl(n).start_time        := null;
            l_tbl(n).end_time          := null;
            l_tbl(n).availability_type := null;

            -- Added by Sudhir on 25/04/2002
        l_tbl(n).attribute1  := null;
        l_tbl(n).attribute2  := null;
        l_tbl(n).attribute3  := null;
        l_tbl(n).attribute4  := null;
        l_tbl(n).attribute5  := null;
        l_tbl(n).attribute6  := null;
        l_tbl(n).attribute7  := null;
        l_tbl(n).attribute8  := null;
        l_tbl(n).attribute9  := null;
        l_tbl(n).attribute10 := null;
        l_tbl(n).attribute11 := null;
        l_tbl(n).attribute12 := null;
        l_tbl(n).attribute13 := null;
        l_tbl(n).attribute14 := null;
        l_tbl(n).attribute15 := null;


            l_tbl.delete;

          elsif  m.start_except < l_tbl(n).start_time -- When exception falls out of the range
      and m.end_except   >l_tbl(n).end_time
          then
            l_tbl.delete;
      -- added jan10, 2001 start
          elsif  m.start_except = l_tbl(n).start_time
      and m.end_except   > l_tbl(n).end_time
          then
            l_tbl(n).start_time        := null;
            l_tbl(n).end_time          := null;
            l_tbl(n).availability_type := null;

            -- Added by Sudhir on 25/04/2002
        l_tbl(n).attribute1  := null;
        l_tbl(n).attribute2  := null;
        l_tbl(n).attribute3  := null;
        l_tbl(n).attribute4  := null;
        l_tbl(n).attribute5  := null;
        l_tbl(n).attribute6  := null;
        l_tbl(n).attribute7  := null;
        l_tbl(n).attribute8  := null;
        l_tbl(n).attribute9  := null;
        l_tbl(n).attribute10 := null;
        l_tbl(n).attribute11 := null;
        l_tbl(n).attribute12 := null;
        l_tbl(n).attribute13 := null;
        l_tbl(n).attribute14 := null;
        l_tbl(n).attribute15 := null;

            l_tbl.delete;

          elsif  m.start_except < l_tbl(n).start_time
      and m.end_except   = l_tbl(n).end_time
          then
            l_tbl(n).start_time        := null;
            l_tbl(n).end_time          := null;
            l_tbl(n).availability_type := null;

            -- Added by Sudhir on 25/04/2002

        l_tbl(n).attribute1  := null;
        l_tbl(n).attribute2  := null;
        l_tbl(n).attribute3  := null;
        l_tbl(n).attribute4  := null;
        l_tbl(n).attribute5  := null;
        l_tbl(n).attribute6  := null;
        l_tbl(n).attribute7  := null;
        l_tbl(n).attribute8  := null;
        l_tbl(n).attribute9  := null;
        l_tbl(n).attribute10 := null;
        l_tbl(n).attribute11 := null;
        l_tbl(n).attribute12 := null;
        l_tbl(n).attribute13 := null;
        l_tbl(n).attribute14 := null;
        l_tbl(n).attribute15 := null;

            l_tbl.delete;
        -- added jan10, 2001 end

          end if;

          if l_exp_flg = 'Y' THEN
            l_tbl.delete; -- if we find the exception and shift times are same then delete the row from table of records.
          end if;
        end loop;
      end loop;

      -- moved to after handling exception so that exception are also get adjusted for resource time zone
      --
      --  Added for Simplex Timezone Enh # 3040681 by ABRAINA
      --
      If fnd_profile.value_specific('ENABLE_TIMEZONE_CONVERSIONS') = 'Y' Then
         l_res_Timezone_id := Get_Res_Timezone_Id (p_resource_id, p_resource_type);
       If l_res_Timezone_id <> l_server_tz_id Then
         l_idx := 0;
         For r in 1..l_tbl.count loop
            l_idx := l_idx + 1;
            l_tbl(l_idx).start_time := ResourceDt_To_ServerDT(l_tbl(l_idx).start_time,l_res_Timezone_id,l_server_tz_id);
            l_tbl(l_idx).end_time := ResourceDt_To_ServerDT(l_tbl(l_idx).end_time,l_res_Timezone_id,l_server_tz_id);
         End Loop;
       End If;
      End If;

      l_process := 'Y';
    --added cond not to process overlapping dates added 19oct 2001

      if(l_process = 'Y')
      then
         -- store found shift constructs for this day in output pl/sql table
         for r in 1..l_tbl.count
         loop
         -- added this condition to avoid duplicate shifts being returned
            l_put := 1;
            for k in 1..x_shift.count
            loop
             if( (l_tbl(r).shift_construct_id = x_shift(k).shift_construct_id)
                    and ((l_tbl(r).start_time between x_shift(k).start_time and  x_shift(k).end_time)
                    or (l_tbl(r).end_time between x_shift(k).start_time and  x_shift(k).end_time)))
             then
                 l_put := 0;
                 exit;
              end if;
            end loop;
            if((l_prev_shift_id <> l_shift_id))
            then
               if(trunc(l_tbl(r).start_time) < l_shift_date)
               then
                        l_put := '0';
                end if;
            end if;

            if(l_put = 1)
            then
                l_idx := x_shift.count + 1;
                x_shift(l_idx).shift_construct_id := l_tbl(r).shift_construct_id;
--                x_shift(l_idx).shift_date         := trunc(l_tbl(r).start_time);
                -- changed as the times are now of type date
                x_shift(l_idx).start_time         := l_tbl(r).start_time;
                x_shift(l_idx).end_time           := l_tbl(r).end_time;
                x_shift(l_idx).availability_type  := l_tbl(r).availability_type;

           -- Added by Sudhir on 25/04/2002
           x_shift(l_idx).attribute1  := l_tbl(r).attribute1;
       x_shift(l_idx).attribute2  := l_tbl(r).attribute2;
       x_shift(l_idx).attribute3  := l_tbl(r).attribute3;
       x_shift(l_idx).attribute4  := l_tbl(r).attribute4;
       x_shift(l_idx).attribute5  := l_tbl(r).attribute5;
           x_shift(l_idx).attribute6  := l_tbl(r).attribute6;
           x_shift(l_idx).attribute7  := l_tbl(r).attribute7;
           x_shift(l_idx).attribute8  := l_tbl(r).attribute8;
           x_shift(l_idx).attribute9  := l_tbl(r).attribute9;
           x_shift(l_idx).attribute10 := l_tbl(r).attribute10;
           x_shift(l_idx).attribute11 := l_tbl(r).attribute11;
           x_shift(l_idx).attribute12 := l_tbl(r).attribute12;
           x_shift(l_idx).attribute13 := l_tbl(r).attribute13;
           x_shift(l_idx).attribute14 := l_tbl(r).attribute14;
           x_shift(l_idx).attribute15 := l_tbl(r).attribute15;

             end if;
          end loop;
       end if; -- end of l_process

      exception
        when no_data_found then
        x_return_status := FND_API.G_RET_STS_ERROR ;
        -- Added for bug 3270116
        l_return_status := FND_API.G_RET_STS_ERROR ;
        -- end
        fnd_message.set_name('JTF','JTF_CAL_NO_SHIFTS');
        fnd_message.set_token('P_CAL_NAME', l_calendar_name);
        fnd_msg_pub.add;
    FND_MSG_PUB.Count_And_Get
          (p_count          =>      x_msg_count,
           p_data           =>      x_msg_data
          );
      end; --2
      end if; -- valid cal end if
     exception
       when no_data_found then
        x_return_status := FND_API.G_RET_STS_ERROR ;
        -- No Need to set l_return_status to FND_API.G_RET_STS_ERROR
	-- as for this exception we want to handle it.
	-- For a resource, even if a single shift is returned in the search window
	-- it will return 'S'. This is as per requirement from Field service and Gantt guys.
        l_tbl.delete;  -- to delete the record from TOR if no shift found
        fnd_message.set_name('JTF','JTF_CAL_RES_NO_CAL');
        fnd_message.set_token('P_SHIFT_DATE', l_shift_date);
        fnd_message.set_token('P_RES_NAME', l_resource_name);
        fnd_msg_pub.add;

    FND_MSG_PUB.Count_And_Get
          (p_count          =>      x_msg_count,
           p_data           =>      x_msg_data
          );
     end; -- 1
     l_shift_date := l_shift_date + 1;

end loop;

  -- see if shift constructs have been found
  if x_shift.count = 0
  then
    x_return_status := fnd_api.g_ret_sts_error ;
    -- Added for bug 3270116
    l_return_status := FND_API.G_RET_STS_ERROR ;
    -- end
    fnd_message.set_name('JTF','JTF_CAL_NO_SHIFT_CONSTR_FOUND');
    fnd_msg_pub.add;

    fnd_msg_pub.count_and_get( p_count => x_msg_count
                             , p_data  => x_msg_data );
  end if;


    if x_shift.count > 0
    then
    -- sort the out table
       sort_tab_attr(x_shift);

    end if;

    -- Added for bug 3270116
    -- For a resource, even if a single shift is returned for any search window
    -- it will return 'S'. This is as per requirement from Field service and Gantt guys.
    if l_return_status = FND_API.G_RET_STS_SUCCESS then
           x_return_status := FND_API.G_RET_STS_SUCCESS;
    else
           x_return_status := FND_API.G_RET_STS_ERROR ;
    end if;
    -- end

EXCEPTION
  when g_exc_required_fields_null then
    x_return_status := fnd_api.g_ret_sts_error ;
    fnd_message.set_name('JTF','JTF_CAL_REQUIRED_PARAMETERS');
    fnd_message.set_token('P_PARAMETER', l_parameters);
    fnd_msg_pub.add;
    fnd_msg_pub.count_and_get ( p_count => x_msg_count
                      , p_data  => x_msg_data );

  when fnd_api.g_exc_unexpected_error then
    x_return_status := fnd_api.g_ret_sts_unexp_error;
    fnd_msg_pub.count_and_get ( p_count => x_msg_count
                      , p_data  => x_msg_data );
  when fnd_api.g_exc_error then
    x_return_status := fnd_api.g_ret_sts_unexp_error;
    fnd_msg_pub.count_and_get ( p_count => x_msg_count
                          , p_data  => x_msg_data );
  when others then
    x_return_status := fnd_api.g_ret_sts_unexp_error ;
    fnd_message.set_name('JTF','JTF_CAL_UNEXPECTED_ERROR');
    fnd_message.set_token('ERROR_CODE',sqlcode);
    fnd_message.set_token('ERROR_MESSAGE',sqlerrm);
    fnd_msg_pub.count_and_get ( p_count => x_msg_count
                      , p_data  => x_msg_data );

  --END;

END get_resource_shifts;
--

/**********************************************************************/
PROCEDURE Is_Res_Available
(   p_api_version           IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE,
    p_resource_id           IN      NUMBER,
    p_resource_type     IN  VARCHAR2,
    p_start_date_time       IN  DATE,
    p_duration          IN  NUMBER,
    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER,
    x_msg_data          OUT NOCOPY VARCHAR2,
    x_avail         OUT NOCOPY VARCHAR2
)
IS
   l_api_name          CONSTANT VARCHAR2(30) := 'Is_Res_Available';
   l_api_version           CONSTANT NUMBER   := 1.0;
   l_return_status         VARCHAR2(1);
   l_msg_count             NUMBER;
   l_msg_data              VARCHAR2(250);
   l_shift                 SHIFT_TBL_TYPE;
   v_begin_time            date;
   v_end_time              date;

BEGIN
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version ,
                                                p_api_version ,
                                l_api_name ,
                                    G_PKG_NAME )
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    -- Call to check for required fields
    IF not check_for_required_fields (p_resource_id         =>p_resource_id,
                                      p_resource_type   =>p_resource_type,
                                      p_start_date        =>p_start_date_time,
                              p_duration          =>p_duration)
    THEN
        l_parameters := 'p_resource_id, p_resource_type, p_start_date_time, p_duration';
    RAISE G_EXC_REQUIRED_FIELDS_NULL;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

   Get_Available_Time
     (  p_api_version           => 1.0,
        p_resource_id           => p_resource_id,
        p_resource_type           => p_resource_type,
        p_start_date            => p_start_date_time,
        p_end_date              => p_start_date_time,
        x_return_status         => l_return_status,
        x_msg_count             => l_msg_count,
        x_msg_data              => l_msg_data,
        x_shift                 => l_shift
        );

 v_begin_time := p_start_date_time;
 		--Change for Bug # 4400664 by MPADHIAR
		 --In case of UOM is minute(MIN) . It was truncating Second portion of the Calculated end_time
		 --So giving 1 Minute less for 2, 5, 8 ,...... 59 Minure Estimated Assigments.
 v_end_time := p_start_date_time + round(p_duration*60)/(24*60);

 x_avail := 'N';

 IF v_end_time > v_begin_time THEN
   for i in 1 .. l_shift.count loop
         IF v_begin_time >= l_shift(i).start_time
            AND v_end_time <= l_shift(i).end_time THEN
             x_avail := 'Y';
             EXIT;
        END IF;
   end loop;
 END IF;

EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        FND_MSG_PUB.Count_And_Get
            (   p_count         =>      x_msg_count,
                p_data          =>      x_msg_data
            );
  WHEN  G_EXC_REQUIRED_FIELDS_NULL THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
          fnd_message.set_name('JTF','JTF_CAL_REQUIRED_PARAMETERS');
          fnd_message.set_token('P_PARAMETER', l_parameters);
          fnd_msg_pub.add;
      FND_MSG_PUB.Count_And_Get
            (p_count            =>      x_msg_count,
             p_data             =>      x_msg_data
            );
  WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          fnd_message.set_name('JTF','JTF_CAL_UNEXPECTED_ERROR');
          fnd_message.set_token('ERROR_CODE',SQLCODE);
          fnd_message.set_token('ERROR_MESSAGE', SQLERRM);
          fnd_msg_pub.add;
        FND_MSG_PUB.Count_And_Get
            (   p_count         =>      x_msg_count,
                p_data          =>      x_msg_data
            );

END Is_Res_Available;
-- **********   Get Resource Schedule   **************
--
PROCEDURE Get_Res_Schedule
(   p_api_version           IN  NUMBER              ,
    p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE ,
    p_resource_id       IN      NUMBER          ,
    p_resource_type     IN  VARCHAR2        ,
    p_start_date        IN  DATE            ,
    p_end_date      IN  DATE            ,
    x_return_status     OUT NOCOPY VARCHAR2     ,
    x_msg_count     OUT NOCOPY NUMBER           ,
    x_msg_data      OUT NOCOPY VARCHAR2     ,
    x_shift         OUT NOCOPY SHIFT_TBL_TYPE
)
IS
   l_api_name           CONSTANT VARCHAR2(30):= 'Get_Rsc_Schedule';
   l_api_version            CONSTANT NUMBER := 1.0;
   l_shift                      SHIFT_TBL_TYPE;
--
   cursor shift_info(p_calendar_id NUMBER) is
   select shift_id,(shift_end_date - shift_start_date) shift_duration
     from jtf_cal_shift_assign
    where calendar_id = p_calendar_id
 order by shift_sequence_number;

   cursor work_hrs(p_shift_id NUMBER, p_day date, p_uot_value date) is
   select shift_construct_id,
          begin_time shift_begin_time,
          end_time shift_end_time,
          availability_type_code
     from jtf_cal_shift_constructs
    where shift_id = p_shift_id
      and ((start_date_active <=p_day and end_date_active IS NULL)  /* bug# 2408759 */
             or (p_day between start_date_active and end_date_active))
      and
            (
             (
               trunc(begin_time) <= trunc(p_uot_value)
               and
               trunc(end_time)  >= trunc(p_uot_value)
             )
            or
            (
               trunc(begin_time) <= to_date('1995/01/07','YYYY/MM/DD') +
                                        to_number(substr(to_char(trunc(p_uot_value), 'YYYY/MM/DD'),9,2))
               and
               trunc(end_time)  >= to_date('1995/01/07','YYYY/MM/DD') +
                                     to_number(substr(to_char(trunc(p_uot_value), 'YYYY/MM/DD'),9,2))
            )
           )
 order by begin_time;
--
   cursor excp_hrs(p_calendar_id NUMBER, p_day DATE) is
   select e.start_date_time  excp_start_time,
          e.end_date_time excp_end_time
     from jtf_cal_exceptions_vl e, jtf_cal_exception_assign a
    where a.calendar_id  = p_calendar_id
      and a.exception_id = e.exception_id
      and (
               ( p_day >= trunc(a.start_date_active)
                       or a.start_date_active is null
               )
           and
              ( p_day <= trunc(a.end_date_active)
                           or a.end_date_active is null
              )
             -- validate exception
             and
               (
                  p_day between trunc(e.start_date_time) and trunc(e.end_date_time)
                )
           ) ;
--
   --
   -- Added two new parameters p_tz_enabled, p_server_tz_id and
   -- modified the query accordingly. Done by SBARAT on 23/06/2005 for Bug# 4443443
   --

   cursor task_hrs(p_res_id NUMBER,p_res_type VARCHAR2,p_req_date DATE,p_tz_enabled VARCHAR2,p_server_tz_id NUMBER) is
   -- For bug 4547539, added db index skip hint to force db to use second indexed
   -- column schedule_end_date for index search
   select /*+ index_ss(T JTF_TASKS_B_N12) */
          trunc(Decode(p_tz_enabled,'Y',
                       Decode(t.timezone_id,NULL, t.scheduled_start_date,
                              Nvl(HZ_TIMEZONE_PUB.CONVERT_DATETIME(t.timezone_id,
                                                                   p_server_tz_id,
                                                                   t.scheduled_start_date),
                                  t.scheduled_start_date)
                             ),
                       t.scheduled_start_date)
               ) task_start_date,
          trunc(Decode(p_tz_enabled,'Y',
                       Decode(t.timezone_id,NULL, t.scheduled_end_date,
                              Nvl(HZ_TIMEZONE_PUB.CONVERT_DATETIME(t.timezone_id,
                                                                   p_server_tz_id,
                                                                   t.scheduled_end_date),
				          t.scheduled_end_date)
                             ),
                       t.scheduled_end_date)
               )  task_end_date,
          Decode(p_tz_enabled,'Y',
                 Decode(t.timezone_id,NULL, t.scheduled_start_date,
                        Nvl(HZ_TIMEZONE_PUB.CONVERT_DATETIME(t.timezone_id,
                                                             p_server_tz_id,
                                                             t.scheduled_start_date),
                            t.scheduled_start_date)
                       ),
                 t.scheduled_start_date)   task_start_time,
          Decode(p_tz_enabled,'Y',
                 Decode(t.timezone_id,NULL, t.scheduled_end_date,
                        Nvl(HZ_TIMEZONE_PUB.CONVERT_DATETIME(t.timezone_id,
                                                             p_server_tz_id,
                                                             t.scheduled_end_date),
				    t.scheduled_end_date)
                       ),
                 t.scheduled_end_date)  task_end_time
    from  jtf_tasks_b t,
          jtf_task_assignments a,
          jtf_task_statuses_b s
   where  a.resource_id = p_res_id
     and  a.resource_type_code = p_res_type
     and  p_req_date between
                             trunc(Decode(p_tz_enabled,'Y',
                                          Decode(t.timezone_id,NULL, t.scheduled_start_date,
                                                 Nvl(HZ_TIMEZONE_PUB.CONVERT_DATETIME(t.timezone_id,
                                                                                      p_server_tz_id,
                                                                                      t.scheduled_start_date),
                                                     t.scheduled_start_date)
                                                ),
                                          t.scheduled_start_date)
                                  )
                         and
                                  Decode(p_tz_enabled,'Y',
                                          Decode(t.timezone_id,NULL, t.scheduled_end_date,
                                                 Nvl(HZ_TIMEZONE_PUB.CONVERT_DATETIME(t.timezone_id,
                                                                                      p_server_tz_id,
                                                                                      t.scheduled_end_date),
                                                     t.scheduled_end_date)
                                                 ),
                                          t.scheduled_end_date)
     and  s.task_status_id = a.assignment_status_id
     AND  t.task_id = a.task_id
     and  nvl(s.cancelled_flag,'N') <> 'Y'
     and  nvl(s.completed_flag,'N') <> 'Y'
     and  t.scheduled_start_date <> t.scheduled_end_date ; -- bug # 2520762
      --

   j                INTEGER := 0;
   l_shift_id           NUMBER;
   l_unit_of_time_value         NUMBER;
   l_calendar_id                NUMBER;
   l_calendar_name              jtf_calendars_vl.calendar_name%TYPE; -- bug 2493461 VARCHAR2(240)
   l_calendar_start_date        DATE;
   l_shifts_total_duration      NUMBER;
   l_left_days                  NUMBER;
   l_shift_date         DATE;
   l_res_type           VARCHAR2(30);

   l_utv_1          DATE;
   k                number;
   l_diff           number;
   l_start_constr   date;
   l_put            number := 1;
   l_utv            varchar2(30);
   l_prev_shift_id  number;
   l_process        varchar2(1) := 'Y';
   l_idx            number      := 0;

l_tz_enabled    VARCHAR2(10):=fnd_profile.value('ENABLE_TIMEZONE_CONVERSIONS'); -- Added by SBARAT on 23/06/2005 for Bug# 4443443
l_server_tz_id   Number :=   to_number (fnd_profile.value_specific('SERVER_TIMEZONE_ID'));
l_res_Timezone_id Number;
m       INTEGER := 0;

l_resource_name            jtf_task_resources_vl.resource_name%TYPE;-- bug # 2418561

BEGIN

     -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (    l_api_version           ,
                                        p_api_version           ,
                                l_api_name          ,
                                        G_PKG_NAME )
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;
    -- Call to check for required fields
    IF not check_for_required_fields (p_resource_id     =>p_resource_id,
                                      p_resource_type   =>p_resource_type,
                                      p_start_date  =>p_start_date,
                                      p_end_date    =>p_end_date)
    THEN
        l_parameters := 'p_resource_id, p_resource_type, p_start_date, p_end_date';
    RAISE G_EXC_REQUIRED_FIELDS_NULL;
    END IF;

  -- This code is added to get resource name to be printed in error message.
  -- Added for Bug 4063687
  BEGIN
    select resource_name
    into l_resource_name
    --from jtf_rs_all_resources_vl
    --Modified by jawang to fix the bug 2416932
    from jtf_task_resources_vl
    where resource_id = p_resource_id
    and  resource_type = p_resource_type;
  EXCEPTION
    WHEN Others THEN
    NULL;
  END;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
--
l_shift_date := trunc(p_start_date);
x_shift.delete;
While l_shift_date <= p_end_date Loop
-- get the primary calendar for a resource on the given date
--
l_shift.delete;
begin --(1)
  select a.calendar_id,b.calendar_name,b.start_date_active
  into   l_calendar_id,l_calendar_name,l_calendar_start_date
  from   jtf_cal_resource_assign a,
         jtf_calendars_vl b
  where  a.resource_id = p_resource_id
  and    a.resource_type_code = p_resource_type
  and    a.calendar_id = b.calendar_id
  and    a.primary_calendar_flag = 'Y'
--  Commented for bug 3891896 by ABRAINA
--  and    l_shift_date between trunc(a.start_date_time) and nvl(trunc(a.end_date_time),to_date(get_g_miss_date,'DD/MM/RRRR'));
  and    l_shift_date between trunc(a.start_date_time) and nvl(trunc(a.end_date_time),l_shift_date);

-- if condition added for bug 3270116 by ABRAINA
IF Validate_Cal_Date(l_calendar_id, l_shift_date)
THEN

--
-- get the shift in which the given date falls for the above calendar
--
  begin --(2)
    select sum(shift_end_date - shift_start_date)
    into   l_shifts_total_duration
    from   jtf_cal_shift_assign
    where  calendar_id = l_calendar_id;
--
    select mod((l_shift_date - l_calendar_start_date),l_shifts_total_duration)
    into   l_left_days
    from dual;
--
    l_shift_id := Null;
    for c in shift_info(l_calendar_id) loop
      l_left_days := l_left_days - c.shift_duration;
      IF l_left_days < 0 THEN
        l_prev_shift_id := l_shift_id;
    l_shift_id := c.shift_id;
        EXIT;
      END IF;
    end loop;

--
-- Find the day of the Requested Date
--
    select to_char(l_shift_date, 'd')
    into   l_unit_of_time_value
    from dual;


    -- changed in new api by sudar
     l_utv := to_char(l_shift_date, 'DAY');
         if(to_char(to_date('1995/01/01', 'YYYY/MM/DD'), 'DAY') = to_char(l_shift_date, 'DAY'))
         then
            l_utv_1 := to_date('1995/01/01', 'YYYY/MM/DD');
         elsif(to_char(to_date('1995/01/02', 'YYYY/MM/DD'), 'DAY') = to_char(l_shift_date, 'DAY'))
         then
            l_utv_1 := to_date('1995/01/02', 'YYYY/MM/DD');
         elsif(to_char(to_date('1995/01/03', 'YYYY/MM/DD'), 'DAY') = to_char(l_shift_date, 'DAY'))
         then
            l_utv_1 := to_date('1995/01/03', 'YYYY/MM/DD');
         elsif(to_char(to_date('1995/01/04', 'YYYY/MM/DD'), 'DAY') = to_char(l_shift_date, 'DAY'))
         then
            l_utv_1 := to_date('1995/01/04', 'YYYY/MM/DD');
         elsif(to_char(to_date('1995/01/05', 'YYYY/MM/DD'), 'DAY') = to_char(l_shift_date, 'DAY'))
         then
            l_utv_1 := to_date('1995/01/05', 'YYYY/MM/DD');
         elsif(to_char(to_date('1995/01/06', 'YYYY/MM/DD'), 'DAY') = to_char(l_shift_date, 'DAY'))
         then
            l_utv_1 := to_date('1995/01/06', 'YYYY/MM/DD');
         elsif(to_char(to_date('1995/01/07', 'YYYY/MM/DD'), 'DAY') = to_char(l_shift_date, 'DAY'))
         then
            l_utv_1 := to_date('1995/01/07', 'YYYY/MM/DD');
         end if;

--
-- Find the working hours on the Requested day
--
    --FOR c1 in work_hrs(l_shift_id, l_unit_of_time_value) LOOP
    FOR c1 in work_hrs(l_shift_id, l_shift_date, l_utv_1) LOOP
      j := l_shift.count + 1;
      l_shift(j).shift_construct_id := c1.shift_construct_id;
      --added this if cond if start_date passed in is not in the same day as the shift start date -- sudarsana
      if(to_char(l_shift_date, 'DAY') <> to_char(c1.shift_begin_time, 'DAY'))
      then
        if(trunc(c1.shift_end_time) > to_date('1995/01/07', 'YYYY/MM/DD'))
        then
              l_diff := 0;
              l_start_constr := c1.shift_begin_time;
              while(to_char(l_start_constr , 'DAY') <> to_char(l_shift_date, 'DAY'))
              loop
                 l_diff := l_diff +1;
                 l_start_constr := l_start_constr + 1;
               end loop;
               l_shift(j).start_time := (l_shift_date - l_diff) + (c1.shift_begin_time - trunc(c1.shift_begin_time));
         else
            l_shift(j).start_time := (l_shift_date - (l_utv_1 - trunc(c1.shift_begin_time))) +
                                                        (c1.shift_begin_time - trunc(c1.shift_begin_time));
         end if;
      else
          l_shift(j).start_time := l_shift_date + (c1.shift_begin_time - trunc(c1.shift_begin_time));
      end if;
      -- changed this to adjust to 24 hour shift .. sudarsana
       l_shift(j).end_time   :=  l_shift(j).start_time +
                                            (to_number(c1.shift_end_time - c1.shift_begin_time) * 24)/24;

If fnd_profile.value_specific('ENABLE_TIMEZONE_CONVERSIONS') = 'Y' Then
  l_res_Timezone_id := Get_Res_Timezone_Id (p_resource_id, p_resource_type);
  If l_res_Timezone_id <> l_server_tz_id Then
       l_shift(j).start_time := ResourceDt_To_ServerDT(l_shift(j).start_time,l_res_Timezone_id,l_server_tz_id);
       l_shift(j).end_time   := ResourceDt_To_ServerDT(l_shift(j).end_time,l_res_Timezone_id,l_server_tz_id);
  End If;
End If;

       l_shift(j).availability_type := 'W';
    END LOOP;
--
-- Find all the Exception hours on the requested date
--
    For c2 in excp_hrs(l_calendar_id, l_shift_date) LOOP
      j := j + 1;
      l_shift(j).start_time := c2.excp_start_time;
      l_shift(j).end_time   := c2.excp_end_time;
      l_shift(j).availability_type := 'E';
    END LOOP;
--
-- Find all the assigned Task hours on the requested date
-- Modified by SBARAT on 23/06/2005 for Bug# 4443443
--
     For c3 in task_hrs(p_resource_id,p_resource_type,l_shift_date,l_tz_enabled,l_server_tz_id) loop
--
-- Modified this code for bug 2817811 by A.Raina
--
        IF l_shift_date = c3.task_start_date and l_shift_date = c3.task_end_date THEN
             j := j + 1;
             l_shift(j).start_time := c3.task_start_time;
             l_shift(j).end_time   := c3.task_end_time;
             l_shift(j).availability_type := 'T';

        ELSIF l_shift_date = c3.task_start_date and l_shift_date <> c3.task_end_date THEN

                 FOR c1 in work_hrs(l_shift_id, l_shift_date, l_utv_1) LOOP
                    c1.shift_begin_time := l_shift_date + (c1.shift_begin_time - trunc(c1.shift_begin_time));
                    c1.shift_end_time := l_shift_date + (c1.shift_end_time - trunc(c1.shift_end_time));
                    IF c3.task_start_time >= c1.shift_begin_time THEN
                        j := j + 1;
                        l_shift(j).start_time := c3.task_start_time;
                        l_shift(j).end_time   := c1.shift_end_time;
                        l_shift(j).availability_type := 'T';
                    ELSE
                        j := j + 1;
                        l_shift(j).start_time := c1.shift_begin_time;
                        l_shift(j).end_time   := c1.shift_end_time;
                        l_shift(j).availability_type := 'T';
                    END IF;
                 END LOOP;

        ELSIF l_shift_date <> c3.task_start_date and l_shift_date <> c3.task_end_date THEN

                 FOR c1 in work_hrs(l_shift_id, l_shift_date, l_utv_1) LOOP
                    c1.shift_begin_time := l_shift_date + (c1.shift_begin_time - trunc(c1.shift_begin_time));
                    c1.shift_end_time   := l_shift_date + (c1.shift_end_time - trunc(c1.shift_end_time));
                    j := j + 1;
                    l_shift(j).start_time := c1.shift_begin_time;
                    l_shift(j).end_time   := c1.shift_end_time;
                    l_shift(j).availability_type := 'T';
                 End Loop;

        ELSIF l_shift_date <> c3.task_start_date and l_shift_date = c3.task_end_date THEN
                 FOR c1 in work_hrs(l_shift_id, l_shift_date, l_utv_1) LOOP
                    c1.shift_begin_time := l_shift_date + (c1.shift_begin_time - trunc(c1.shift_begin_time));
                    c1.shift_end_time := l_shift_date + (c1.shift_end_time - trunc(c1.shift_end_time));

                    IF c3.task_end_time <= c1.shift_end_time THEN
                        j := j + 1;
                        l_shift(j).start_time := c1.shift_begin_time;
                        l_shift(j).end_time   := c3.task_end_time;
                        l_shift(j).availability_type := 'T';
                    ELSE
                        j := j + 1;
                        l_shift(j).start_time := c1.shift_begin_time;
                        l_shift(j).end_time   := c1.shift_end_time;
                        l_shift(j).availability_type := 'T';
                    END IF;

                 END LOOP;
        END IF;
--
--End modification
--

   END LOOP;

      l_process := 'Y';
      if(l_process = 'Y')
      then
      -- store found shift constructs for this day in output pl/sql table
         for r in 1..l_shift.count
          loop
        -- added this condition to avoid duplicate shifts being returned
            l_put := 1;
            for k in 1..x_shift.count
            loop
              if( (l_shift(r).shift_construct_id = x_shift(k).shift_construct_id)
                 and (l_shift(r).start_time between x_shift(k).start_time and x_shift(k).end_time)
                 and (l_shift(r).end_time between x_shift(k).start_time and  x_shift(k).end_time)
                 and (l_shift(r).availability_type =  x_shift(k).availability_type))
              then
                 l_put := 0;
                 exit;
              end if;
            end loop;
            if((l_prev_shift_id <> l_shift_id))
            then
               if(trunc(l_shift(r).start_time) < l_shift_date)
               then
                        l_put := '0';
                end if;
            end if;
            if(l_put = 1)
            then
               l_idx := x_shift.count + 1;
               x_shift(l_idx).shift_construct_id := l_shift(r).shift_construct_id;
               x_shift(l_idx).start_time         := l_shift(r).start_time;
               x_shift(l_idx).end_time           := l_shift(r).end_time;
               x_shift(l_idx).availability_type  := l_shift(r).availability_type;
            end if;

          end loop;

      end if; -- end of l_process check

    exception
      when no_data_found then
    x_return_status := FND_API.G_RET_STS_ERROR ;
        fnd_message.set_name('JTF','JTF_CAL_NO_SHIFTS');
        fnd_message.set_token('P_CAL_NAME', l_calendar_name);
        fnd_msg_pub.add;
    FND_MSG_PUB.Count_And_Get
          (p_count          =>      x_msg_count,
           p_data           =>      x_msg_data
          );
    end; --(2)
 end if; --(1)
 exception
        when no_data_found then
      x_return_status := FND_API.G_RET_STS_ERROR ;
          fnd_message.set_name('JTF','JTF_CAL_RES_NO_CAL');
          fnd_message.set_token('P_SHIFT_DATE', l_shift_date);
          fnd_message.set_token('P_RES_NAME', l_resource_name);
          fnd_msg_pub.add;
      FND_MSG_PUB.Count_And_Get
            (p_count            =>      x_msg_count,
             p_data             =>      x_msg_data
            );
 end; --(1)
l_shift_date := l_shift_date + 1;
end loop;
--
-- Update return status to Success if there is atleast one available time slot
   IF x_shift.count > 0 and x_return_status = 'E' THEN
        x_return_status := FND_API.G_RET_STS_SUCCESS;
   END IF;

    if x_shift.count > 0
    then
    -- sort the out table
       sort_tab(x_shift);

    end if;
EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        FND_MSG_PUB.Count_And_Get
            (   p_count         =>      x_msg_count,
                p_data          =>      x_msg_data
            );
  WHEN  G_EXC_REQUIRED_FIELDS_NULL THEN
          x_return_status := FND_API.G_RET_STS_ERROR ;
          fnd_message.set_name('JTF','JTF_CAL_REQUIRED_PARAMETERS');
          fnd_message.set_token('P_PARAMETER', l_parameters);
          fnd_msg_pub.add;
      FND_MSG_PUB.Count_And_Get
            (p_count            =>      x_msg_count,
             p_data             =>      x_msg_data
            );
  when fnd_api.g_exc_error then
    x_return_status := fnd_api.g_ret_sts_unexp_error;
    fnd_msg_pub.count_and_get ( p_count => x_msg_count
                              , p_data  => x_msg_data );
  WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          fnd_message.set_name('JTF','JTF_CAL_UNEXPECTED_ERROR');
          fnd_message.set_token('ERROR_CODE',SQLCODE);
          fnd_message.set_token('ERROR_MESSAGE', SQLERRM);
          fnd_msg_pub.add;
      FND_MSG_PUB.Count_And_Get
           (p_count         =>      x_msg_count,
            p_data          =>      x_msg_data
           );

 END Get_Res_Schedule;

/***********************************************************/
Function get_g_false return varchar2 is
  begin
    return(fnd_api.g_false);
  end get_g_false;


function get_g_miss_num return number is
  begin
     return(fnd_api.g_miss_num);
  end get_g_miss_num;

function get_g_miss_char return varchar2 is
  begin
     return(fnd_api.g_miss_char);
  end get_g_miss_char;

function get_g_miss_date return date is
  begin
     return(fnd_api.g_miss_date);
  end get_g_miss_date;

--Bug# 1344222
FUNCTION check_resource_status(p_resource_id IN NUMBER,p_resource_type IN VARCHAR2) RETURN BOOLEAN IS
  nDummy NUMBER(1);
BEGIN

  /* p_resource_id and  p_resource_type are mandatory parameters */

  if p_resource_id is null or p_resource_type is null then
    return false;
  end if;

   SELECT 1 INTO nDummy FROM jtf_task_resources_vl
   WHERE resource_id = p_resource_id AND resource_type = p_resource_type
   AND  ((start_date_active IS NULL AND end_date_active IS NULL)
      OR (start_date_active <= SYSDATE AND end_date_active IS NULL)
      OR (SYSDATE BETWEEN start_date_active AND end_date_active));

   return true;

EXCEPTION
 WHEN NO_DATA_FOUND THEN
   return false;
END;

--
--  Function ResourceDt_To_ServerDT Added for Simplex Timezone Enh # 3040681 by ABRAINA
--

Function ResourceDt_To_ServerDT ( P_Resource_DtTime IN date, P_Resource_TZ_Id IN Number , p_Server_TZ_id IN Number ) RETURN date IS

 x_Server_time     Date := P_Resource_DtTime;

 l_api_name        CONSTANT VARCHAR2(30) := 'ResourceDt_To_ServerDT';
 l_API_VERSION       Number := 1.0 ;
 p_API_VERSION       Number := 1.0 ;
 l_INIT_MSG_LIST     varchar2(1) := 'F';
 p_INIT_MSG_LIST     varchar2(1) := 'F';
 X_msg_count       Number;
 X_msg_data        Varchar2(2000);
 X_RETURN_STATUS     Varchar2(10);

BEGIN

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version ,
                                                p_api_version ,
                                l_api_name ,
                                    G_PKG_NAME )
    THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

   HZ_TIMEZONE_PUB.Get_Time( l_API_VERSION
                           , l_INIT_MSG_LIST
                           , P_Resource_TZ_Id
                           , p_Server_TZ_id
                           , P_Resource_DtTime
                           , x_Server_time
                           , X_RETURN_STATUS
                           , X_msg_count
                           , X_msg_data);

Return x_Server_time;

EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        FND_MSG_PUB.Count_And_Get
            (   p_count         =>      x_msg_count,
                p_data          =>      x_msg_data
            );
  WHEN  G_EXC_REQUIRED_FIELDS_NULL THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
          fnd_message.set_name('JTF','JTF_CAL_REQUIRED_PARAMETERS');
          fnd_message.set_token('P_PARAMETER', l_parameters);
          fnd_msg_pub.add;
      FND_MSG_PUB.Count_And_Get
            (p_count            =>      x_msg_count,
             p_data             =>      x_msg_data
            );
  WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          fnd_message.set_name('JTF','JTF_CAL_UNEXPECTED_ERROR');
          fnd_message.set_token('ERROR_CODE',SQLCODE);
          fnd_message.set_token('ERROR_MESSAGE', SQLERRM);
          fnd_msg_pub.add;
        FND_MSG_PUB.Count_And_Get
            (   p_count         =>      x_msg_count,
                p_data          =>      x_msg_data
            );

END ResourceDt_To_ServerDT;

Function Get_Res_Timezone_Id ( p_resource_Id IN NUMBER, p_resource_type IN VARCHAR2 ) RETURN Number IS

 Cursor C_Res_TimeZone Is
 Select TIME_ZONE
   From JTF_RS_RESOURCE_EXTNS
  Where RESOURCE_ID = p_resource_id
    AND 'RS_'||category = p_resource_type
    And trunc(sysdate) between trunc(nvl(START_DATE_ACTIVE,sysdate))
                           and trunc(nvl(END_DATE_ACTIVE,sysdate));

 CURSOR c_group_res_timezone Is
 SELECT TIME_ZONE
   FROM JTF_RS_GROUPS_B
  WHERE group_id = p_resource_id
    AND trunc(SYSDATE) BETWEEN trunc(nvl(START_DATE_ACTIVE,SYSDATE))
                           AND trunc(nvl(END_DATE_ACTIVE,SYSDATE));

 l_res_timezone_id   NUMBER;

BEGIN
  IF p_resource_type = 'RS_GROUP' THEN
    OPEN C_group_res_TimeZone ;
    FETCH C_group_res_TimeZone INTO l_res_timezone_id;
    CLOSE C_group_res_TimeZone ;
  ELSE
    OPEN C_Res_TimeZone ;
    FETCH C_Res_TimeZone INTO l_res_timezone_id;
    CLOSE C_Res_TimeZone ;
  END IF;

  l_res_timezone_id := nvl(l_res_timezone_id,fnd_profile.value_specific('SERVER_TIMEZONE_ID'));

  RETURN l_res_timezone_id;

END Get_Res_Timezone_Id;

-- Function added for bug 3270116 by ABRAINA
Function Validate_Cal_Date ( P_Calendar_Id IN number, P_shift_date IN date ) RETURN boolean IS
  v_valid_cal Number;

BEGIN

 select 1
   into v_valid_cal
   from jtf_calendars_vl a
  where calendar_id = P_Calendar_Id
--  Commented for bug 3891896 by ABRAINA
--    and P_shift_date between trunc(a.start_date_active) and nvl(trunc(a.end_date_active),to_date(get_g_miss_date,'DD/MM/RRRR'));
    and P_shift_date between trunc(a.start_date_active) and nvl(trunc(a.end_date_active),P_shift_date);

If v_valid_cal = 1 Then
  Return (TRUE);
Else
  Return (FALSE);
End If;

End Validate_Cal_Date;


END JTF_CALENDAR_PUB_24HR;

/

--------------------------------------------------------
--  DDL for Package Body JTF_CALENDAR_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_CALENDAR_PUB" AS
/* $Header: jtfclavb.pls 120.4.12010000.3 2009/09/18 08:23:40 anangupt ship $ */

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
--      History         : 11/02/01      Chan-ik Jang    Changed jtf_task_assignments
--                                                      to jtf_task_all_assignments
--      History         : 01/08/02      JAWANG          Undo Chan-ik's Changes
--                        03/05/02      JAWANG          returned attribute1 - 15
--                                                      in Get_Resource_Shifts API.
--                        03/13/02      JAWANG          Fixed GSCC Warning of to_date
--                        03/27/03      ABRAINA         Modified cursors in Get_available_time
--                                                      and Get_Res_Schedule.
--                        04/10/03      ABRAINA         Modified code in Get_Res_Schedule.
--                        04/28/03      ABRAINA         Modified all cursor c_cal_shift_constr
--                                                      and work_hrs for first day of week change
--                        06/16/03      ABRAINA         Fixed GSCC warning.
--                        08/11/03      ABRAINA         Added ResourceDt_To_ServerDT
--                        12/12/05      SBARAT          Changed jtf_rs_resources_vl to jtf_task_resources_vl
--                                                      due to MOAC change, bug# 4455792
-- End of Comments
-- ************************************************************************
G_PKG_NAME 	CONSTANT VARCHAR2(30):= 'JTF_CALENDAR_PUB';
G_EXC_REQUIRED_FIELDS_NULL	EXCEPTION;
--G_EXC_NOT_VALID_RESOURCE EXCEPTION;
L_PARAMETERS	VARCHAR2(200);
--
-- Added sort by jawang on 06/27/2002
procedure sort_tab(l_tab in out NOCOPY SHIFT_TBL_TYPE ) ;
procedure sort_tab_attr(l_tab in out NOCOPY SHIFT_TBL_ATTRIBUTES_TYPE) ;
procedure bubble ( p_index in integer ,
                   l_tab   in out NOCOPY SHIFT_TBL_TYPE ) ;
procedure bubble_attr ( p_index in integer ,
                   l_tab   in out NOCOPY SHIFT_TBL_ATTRIBUTES_TYPE ) ;

Function check_for_required_fields
	(p_resource_id	   IN NUMBER   := get_g_miss_num ,
	 p_resource_type   IN VARCHAR2 := get_g_miss_char,
	 p_start_date	   IN DATE     := get_g_miss_date,
	 p_end_date	   IN DATE     := get_g_miss_date,
	 p_duration	   IN NUMBER   := get_g_miss_num
       )
return boolean is
begin
	if p_resource_id is null or
	   p_resource_type is null or
	   p_start_date	is null or
	   p_end_date	is null or
	   p_duration   is null THEN
	   return(FALSE);
	else
	   return(TRUE);
        end if;
end;

-- Added sort by jawang on 06/27/2002
/******** Sort Procedure ****************/
 procedure sort_tab(l_tab in out NOCOPY SHIFT_TBL_TYPE )
 is
      l_last number;
      l_hi   number;
      l_lo   number;
      l_up_datetime date;
      l_dw_datetime date;
    begin
      begin
        l_last := l_tab.last;
        exception
           when collection_is_null then return;
      end;
      if l_last is null then return; end if;
      for l_hi in 2 .. l_last
      loop
      --
      -- Modified for bug 3510573 by ABRAINA
      --
      -- Modified for bug 3891896 by ABRAINA
      --
      l_up_datetime := to_date( (to_char(l_tab(l_hi).shift_date,'DD/MM/RRRR')||' '||l_tab(l_hi).start_time),'DD/MM/RRRR HH24:MI');
      l_dw_datetime := to_date( (to_char(l_tab(l_hi-1).shift_date,'DD/MM/RRRR')||' '||l_tab(l_hi-1).start_time),'DD/MM/RRRR HH24:MI');
        if l_up_datetime < l_dw_datetime then
      --if l_tab(l_hi).start_time < l_tab(l_hi-1).start_time then
      --
      -- End Modification
      --
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
      l_up_datetime date;
      l_dw_datetime date;
    begin
      begin
        l_last := l_tab.last;
        exception
           when collection_is_null then return;
      end;
      if l_last is null then return; end if;
      for l_hi in 2 .. l_last
      loop
          --
          -- Modified for bug 3510573 by ABRAINA
          --
          -- Modified for bug 3891896 by ABRAINA
          --
          l_up_datetime := to_date( (to_char(l_tab(l_hi).shift_date,'DD/MM/RRRR')||' '||l_tab(l_hi).start_time),'DD/MM/RRRR HH24:MI');
          l_dw_datetime := to_date( (to_char(l_tab(l_hi-1).shift_date,'DD/MM/RRRR')||' '||l_tab(l_hi-1).start_time),'DD/MM/RRRR HH24:MI');
          if l_up_datetime < l_dw_datetime then
          --if l_tab(l_hi).start_time < l_tab(l_hi-1).start_time then
          --
          -- End Modification
          --
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

--
--     *************** Is Resource Available *********************
--
PROCEDURE Is_Res_Available
( 	p_api_version         	IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
	p_resource_id   		IN  	NUMBER,
	p_resource_type		IN	VARCHAR2,
	p_start_date_time		IN	DATE,
	p_duration			IN	NUMBER,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count			OUT NOCOPY NUMBER,
	x_msg_data			OUT NOCOPY VARCHAR2,
	x_avail			OUT NOCOPY VARCHAR2
)
IS
   l_api_name		   CONSTANT VARCHAR2(30) := 'Is_Res_Available';
   l_api_version           CONSTANT NUMBER 	 := 1.0;
   l_return_status         VARCHAR2(1);
   l_msg_count             NUMBER;
   l_msg_data              VARCHAR2(250);
   l_shift                 SHIFT_TBL_TYPE;
   v_begin_time            VARCHAR2(5);
   v_end_time              VARCHAR2(5);

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
    IF not check_for_required_fields (p_resource_id 		=>p_resource_id,
                                      p_resource_type 	=>p_resource_type,
                                      p_start_date 	      =>p_start_date_time,
	                   		  p_duration	      =>p_duration)
    THEN
        l_parameters := 'p_resource_id, p_resource_type, p_start_date_time, p_duration';
	RAISE G_EXC_REQUIRED_FIELDS_NULL;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

   JTF_CALENDAR_PUB.Get_Available_Time
     (  p_api_version           => 1.0,
        p_resource_id           => p_resource_id,
        p_resource_type      	  => p_resource_type,
        p_start_date            => p_start_date_time,
        p_end_date              => p_start_date_time,
        x_return_status         => l_return_status,
        x_msg_count             => l_msg_count,
        x_msg_data              => l_msg_data,
        x_shift                 => l_shift
        );

 v_begin_time := to_char(p_start_date_time,'HH24.MI');
 v_end_time := to_char((p_start_date_time + p_duration/24),'HH24.MI');

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
    		(  	p_count        	=>      x_msg_count,
        		p_data         	=>      x_msg_data
    		);
  WHEN  G_EXC_REQUIRED_FIELDS_NULL THEN
	  x_return_status := FND_API.G_RET_STS_ERROR ;
          fnd_message.set_name('JTF','JTF_CAL_REQUIRED_PARAMETERS');
          fnd_message.set_token('P_PARAMETER', l_parameters);
          fnd_msg_pub.add;
	  FND_MSG_PUB.Count_And_Get
    	    (p_count        	=>      x_msg_count,
       	     p_data         	=>      x_msg_data
    	    );
  WHEN OTHERS THEN
	  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          fnd_message.set_name('JTF','JTF_CAL_UNEXPECTED_ERROR');
          fnd_message.set_token('ERROR_CODE',SQLCODE);
          fnd_message.set_token('ERROR_MESSAGE', SQLERRM);
          fnd_msg_pub.add;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count        	=>      x_msg_count,
        		p_data         	=>      x_msg_data
    		);

END Is_Res_Available;
--
-- ****************** Get Available Time  **********************
--
PROCEDURE Get_Available_Time
(	p_api_version         	IN	NUMBER,
      p_init_msg_list		IN	VARCHAR2:=FND_API.G_FALSE,
      p_resource_id   	      IN    NUMBER,
	p_resource_type		IN	VARCHAR2,
	p_start_date		IN	DATE,
	p_end_date		      IN	DATE,
      x_return_status		OUT NOCOPY VARCHAR2,
      x_msg_count		      OUT NOCOPY NUMBER,
      x_msg_data		      OUT NOCOPY VARCHAR2,
	x_shift			OUT NOCOPY SHIFT_TBL_TYPE
)
IS

-- we are declaring a table of records here again to manuplate the start and end time in DATE datatype.
type rec_type is record
  ( shift_construct_id number
  , start_time         date
  , end_time 	     date
  , availability_type  varchar2(40) );

  type tbl_type is table of rec_type index by binary_integer;

   l_api_name			CONSTANT VARCHAR2(30):= 'Get_Available_Time';
   l_api_version           	CONSTANT NUMBER := 1.0;

-- Gets the shift_id and duration info, used for calculating the right shift pattern based
-- on the calendar id selected using the parameters passed resource_id, resource_type
-- and requested_date

   cursor shift_info(p_calendar_id NUMBER) is
   select shift_id,(shift_end_date - shift_start_date) shift_duration
     from jtf_cal_shift_assign
    where calendar_id = p_calendar_id
 order by shift_sequence_number;

-- Based on the shift_id corresponding shift construction is found.

   cursor c_cal_shift_constr(p_shift_id NUMBER,p_day date, p_uot_value NUMBER) is
   select shift_construct_id,
          begin_time start_constr,
          end_time end_constr,
          availability_type_code
    from  jtf_cal_shift_constructs
   where  shift_id = p_shift_id
--
--Modified condition to take care first Day of week for Bug 1342982
--
        and   to_char(begin_time, 'd') = to_char(p_day, 'd')
--	and    unit_of_time_value = p_uot_value
--end
	-- validate shift construct
	-- added by jawang on 06/07/2002 to fix bug 2393255
	and ( (  p_day between start_date_active
	               and end_date_active)
	or   (start_date_active <=p_day
	and   end_date_active IS NULL));

--  Get all the exceptions and tasks for the resource on the requested date.
-- Added two new parameters p_tz_enabled, p_server_tz_id and
-- modified the query accordingly. Done by SBARAT on 23/06/2005 for Bug# 4443443
   cursor c_cal_except(p_calendar_id NUMBER, p_day date, p_res_id NUMBER, p_res_type VARCHAR2,p_tz_enabled VARCHAR2,p_server_tz_id NUMBER,p_res_Timezone_id NUMBER) is
   	select Decode(p_tz_enabled,'Y',
                      Decode(p_res_Timezone_id,NULL, e.start_date_time,
                             Nvl(HZ_TIMEZONE_PUB.CONVERT_DATETIME(p_res_Timezone_id,
                                                                  p_server_tz_id,
                                                                  e.start_date_time),
                                 e.start_date_time)
                            ),
                      e.start_date_time) start_except,
             Decode(p_tz_enabled,'Y',
                      Decode(p_res_Timezone_id,NULL, e.end_date_time,
                             Nvl(HZ_TIMEZONE_PUB.CONVERT_DATETIME(p_res_Timezone_id,
                                                                  p_server_tz_id,
                                                                  e.end_date_time),
                                 e.end_date_time)
                            ),
                      e.end_date_time)    end_except
      from jtf_cal_exception_assign a
          ,jtf_cal_exceptions_vl    e
      where a.calendar_id  = p_calendar_id
      and   a.exception_id = e.exception_id
    -- validate exception assignment
      and   ( p_day >= trunc(Decode(p_tz_enabled,'Y',
                      Decode(p_res_Timezone_id,NULL, a.start_date_active,
                             Nvl(HZ_TIMEZONE_PUB.CONVERT_DATETIME(p_res_Timezone_id,
                                                                  p_server_tz_id,
                                                                  a.start_date_active),
                                 a.start_date_active)
                            ),
                      a.start_date_active))
             or a.start_date_active is null)
      and   ( p_day <= trunc(Decode(p_tz_enabled,'Y',
                      Decode(p_res_Timezone_id,NULL, a.end_date_active,
                             Nvl(HZ_TIMEZONE_PUB.CONVERT_DATETIME(p_res_Timezone_id,
                                                                  p_server_tz_id,
                                                                  a.end_date_active),
                                 a.end_date_active)
                            ),
                      a.end_date_active))
             or a.end_date_active is null)
    -- validate exception
      and p_day between trunc(Decode(p_tz_enabled,'Y',
                      Decode(p_res_Timezone_id,NULL, e.start_date_time,
                             Nvl(HZ_TIMEZONE_PUB.CONVERT_DATETIME(p_res_Timezone_id,
                                                                  p_server_tz_id,
                                                                  e.start_date_time),
                                 e.start_date_time)
                            ),
                      e.start_date_time))
                and     trunc(Decode(p_tz_enabled,'Y',
                      Decode(p_res_Timezone_id,NULL, e.end_date_time,
                             Nvl(HZ_TIMEZONE_PUB.CONVERT_DATETIME(p_res_Timezone_id,
                                                                  p_server_tz_id,
                                                                  e.end_date_time),
                                 e.end_date_time)
                            ),
                      e.end_date_time))
 UNION ALL
-- we are picking up from scheduled date form tasks.
        select Decode(p_tz_enabled,'Y',
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
                      t.scheduled_end_date)                 end_except
        from   jtf_tasks_b t,
               jtf_task_assignments a,
               jtf_task_statuses_b s   --changed to table from jtf_task_statuses_vl bug #2473783
        where  a.resource_id = p_res_id
        and    a.resource_type_code = p_res_type
        and    Decode(p_tz_enabled,'Y',
                      Decode(t.timezone_id,NULL, t.scheduled_end_date,
                             Nvl(HZ_TIMEZONE_PUB.CONVERT_DATETIME(t.timezone_id,
                                                                  p_server_tz_id,
                                                                  t.scheduled_end_date),
					   t.scheduled_end_date)
                            ),
                      t.scheduled_end_date) >= p_day  -- Changed to "schedule_end_date" for bug 2817811 by A.Raina.
        and    Decode(p_tz_enabled,'Y',
                      Decode(t.timezone_id,NULL, t.scheduled_start_date,
                             Nvl(HZ_TIMEZONE_PUB.CONVERT_DATETIME(t.timezone_id,
                                                                  p_server_tz_id,
                                                                  t.scheduled_start_date),
                                 t.scheduled_start_date)
                            ),
                      t.scheduled_start_date) < p_day+1   --- removed trunc bug #2473783
	and    s.task_status_id = a.assignment_status_id
	and    t.task_id = a.task_id
	and    nvl(s.cancelled_flag,'N') <> 'Y'
	and    nvl(s.completed_flag,'N') <> 'Y'
        and t.scheduled_start_date <> t.scheduled_end_date ;  -- bug # 2520762

--
   j				      INTEGER := 0;
   l_shift_id			NUMBER;
   l_unit_of_time_value       NUMBER;
   l_begin_time			VARCHAR2(5);
   l_end_time                 VARCHAR2(5);
   l_calendar_id              NUMBER;
   l_calendar_name             jtf_calendars_vl.calendar_name%TYPE; --bug # 2493461 VARCHAR2(240)
   l_calendar_start_date      DATE;
   l_shifts_total_duration    NUMBER;
   l_left_days                NUMBER;
   l_availability             VARCHAR2(40);
   l_day            		date;
   l_range_start    		date;
   l_range_end      		date;
   l_utv            		number;
   l_cnt            		number;
   l_count				NUMBER;
   l_shift_date			DATE;
   l_shift				SHIFT_TBL_TYPE;
   l_tbl		            tbl_type; -- added by Sarvi.
   l_idx                      number := 0;
   l_resource_name            jtf_task_resources_vl.resource_name%TYPE; -- bug #2418561
   l_st_time   date;

   l_tz_enabled    VARCHAR2(10):=fnd_profile.value('ENABLE_TIMEZONE_CONVERSIONS'); -- Added by SBARAT on 23/06/2005 for Bug# 4443443
   l_server_tz_id   Number :=   to_number (fnd_profile.value_specific('SERVER_TIMEZONE_ID'));
   l_res_Timezone_id Number;

BEGIN
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
    IF not check_for_required_fields (p_resource_id 		=>p_resource_id,
                                      p_resource_type 	=>p_resource_type,
                                      p_start_date 	    	=>p_start_date,
                                      p_end_date  	    	=>p_start_date)
    THEN
        l_parameters := 'p_resource_id, p_resource_type, p_start_date, p_end_date';
	RAISE G_EXC_REQUIRED_FIELDS_NULL;
    END IF;

	--  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    l_shift_date := trunc(p_start_date);

while l_shift_date <= p_end_date loop

begin --(1)
  -- get the primary calendar for a resource on the given date
  select a.calendar_id,b.start_date_active
  into   l_calendar_id,l_calendar_start_date
  from   jtf_cal_resource_assign a,
         jtf_calendars_b b
  where  a.resource_id = p_resource_id
  and    a.resource_type_code = p_resource_type
  and    a.calendar_id = b.calendar_id
  and    a.primary_calendar_flag = 'Y'
  and    l_shift_date between trunc(a.start_date_time) and nvl(trunc(a.end_date_time),l_shift_date);
--  Commented for bug 3891896 by ABRAINA
--  and    l_shift_date between trunc(a.start_date_time) and nvl(trunc(a.end_date_time),to_date(get_g_miss_date,'DD/MM/RRRR'));
--  end

  -- if condition added for bug 3270116 by ABRAINA
  IF Validate_Cal_Date(l_calendar_id, l_shift_date) THEN -- (1)
  -- get the shift in which the given date falls for the above calendar
  --
  begin --(2)
    select sum(shift_end_date - shift_start_date)
    into   l_shifts_total_duration
    from   jtf_cal_shift_assign
    where  calendar_id = l_calendar_id;

    -- Based on the mod value the shift is selected.  This happens when two shifts are attached to the
    -- calendar and a pattern of two in sequence is required.
    l_left_days := mod((l_shift_date - l_calendar_start_date),l_shifts_total_duration);
    -- This cursor will have all the shift attached to the resources primary calendar
    -- We loop thru the cursor and based on the condition we find the correct shift_id
    l_shift_id := null;
    for c in shift_info(l_calendar_id) loop
      l_left_days := l_left_days - c.shift_duration;
      IF l_left_days <  0 THEN  -- earlier it was <= it was not picking the correct shift.
        l_shift_id := c.shift_id;
        EXIT;
      END IF;
    end loop;
    --
    -- Find the day of the Requested Date
    --
    l_utv := to_char(l_shift_date, 'd');
    --
    -- Find the working hours on the Requested day
    --
    l_tbl.delete;
    l_idx := 0;
    FOR j in c_cal_shift_constr(l_shift_id,l_shift_date, l_utv) LOOP
      l_idx := l_idx + 1;
      l_tbl(l_idx).shift_construct_id := j.shift_construct_id;
      --added this condition for 24hr shift .. sudarsana 22 Oct 2001
       IF trunc(j.start_constr) = trunc(j.end_constr) THEN
          l_tbl(l_idx).start_time := l_shift_date + (j.start_constr - trunc(j.start_constr));
          l_tbl(l_idx).end_time   := l_shift_date + (j.end_constr - trunc(j.end_constr));
      else
          l_tbl(l_idx).start_time := l_shift_date + (j.start_constr - trunc(j.start_constr));
          l_tbl(l_idx).end_time   := l_shift_date + (j.end_constr - trunc(j.end_constr)) +
                                              (trunc(j.end_constr) - trunc(j.start_constr));
      end if;
      l_tbl(l_idx).availability_type := j.availability_type_code;
    END LOOP;

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

    --
    -- Deduct all Task Assignments, Exceptions from working hours on the requested date
    --
    -- Modified by SBARAT on 23/06/2005 for Bug# 4443443
    for m in c_cal_except(l_calendar_id,l_shift_date, p_resource_id, p_resource_type,l_tz_enabled,l_server_tz_id,l_res_Timezone_id)
    loop
        l_cnt := l_tbl.count;
      for n in 1..l_cnt
      loop   -- loop thru the table loaded with shifts.
          -- If we find an exception satisfying this condition then, we have
          -- to change the start/end time of the shifts accordingly. Like shift 8 - 16
          -- and exception 10-11, then we need to split the record into two like
          -- 8 - 10 and 11 - 16, showing the resource availablity.
        --   dbms_output.put_line('shifts:  '||to_Char(l_tbl(n).start_time,'DD-MON-YYYY HH24:MI')|| '-' ||to_char(l_tbl(n).end_time,'dd-mon-yyyy hh24:mi'));
         --  dbms_output.put_line('tasks: '||to_Char(m.start_except,'DD-MON-YYYY HH24:MI')|| '-' ||to_char(m.end_except,'dd-mon-yyyy hh24:mi'));

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
          -- Various possibilities of exception are checked with shift times, to be chopped off.
  	  elsif m.start_except < l_tbl(n).start_time
          and   m.end_except   > l_tbl(n).start_time
          and   m.end_except   < l_tbl(n).end_time
          then
	     l_tbl(n).start_time := m.end_except;
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
          --   l_tbl.delete; # bug :2595871
          elsif  m.start_except = l_tbl(n).start_time
	  and m.end_except   < l_tbl(n).end_time
          then
            l_tbl(n).start_time        := null;
    	    l_tbl(n).end_time          := null;
    	    l_tbl(n).availability_type := null;
            l_tbl.delete;
          -- added Jan10, 2001, start.
          elsif  m.start_except = l_tbl(n).start_time
	  and m.end_except   > l_tbl(n).end_time
          then
            l_tbl(n).start_time        := null;
    	    l_tbl(n).end_time          := null;
    	    l_tbl(n).availability_type := null;
          --   l_tbl.delete;   # bug :2595871

  	  elsif  m.start_except < l_tbl(n).start_time
	  and m.end_except   = l_tbl(n).end_time
          then
            l_tbl(n).start_time        := null;
    	    l_tbl(n).end_time          := null;
    	    l_tbl(n).availability_type := null;
          -- l_tbl.delete;  # bug :2595871
          -- added Jan10, 2001, end.
          elsif  m.start_except < l_tbl(n).start_time -- When exception falls out of the range
	  and m.end_except   >l_tbl(n).end_time
          then
            l_tbl(n).start_time        := null;  -- added for bug #:2595871
            l_tbl(n).end_time          := null;
            l_tbl(n).availability_type := null;
           -- l_tbl.delete;   # bug :2595871
          end if;
      end loop;
    end loop;

      -- store found shift constructs for this day in output pl/sql table
     for r in 1..l_tbl.count
      loop
        --added this condition for 24hr shift .. sudarsana 22 Oct 2001
        if ((trunc(l_tbl(r).end_time)) = trunc((l_tbl(r).start_time))) THEN
           l_idx := x_shift.count + 1;
           x_shift(l_idx).shift_construct_id := l_tbl(r).shift_construct_id;
           x_shift(l_idx).shift_date         := trunc(l_tbl(r).start_time);
        -- reformat the start and end times just at the end of the procedure
        -- when the calculations are done
           x_shift(l_idx).start_time         := to_char(l_tbl(r).start_time,'hh24.mi');
           x_shift(l_idx).end_time           := to_char(l_tbl(r).end_time,'hh24.mi');
           x_shift(l_idx).availability_type  := l_tbl(r).availability_type;
       else
        --added this condition for 24hr shift .. sudarsana 22 Oct 2001
          l_st_time := l_tbl(r).start_time;
          while(trunc(l_st_time) <= trunc(l_tbl(r).end_time))
          loop
              l_idx := x_shift.count + 1;
              x_shift(l_idx).shift_construct_id := l_tbl(r).shift_construct_id;
              x_shift(l_idx).shift_date         := trunc(l_st_time);
              if(trunc(l_st_time) = trunc(l_tbl(r).start_time))
              then
                 x_shift(l_idx).start_time         := to_char(l_tbl(r).start_time,'hh24.mi');
              else
                 x_shift(l_idx).start_time         := '00.00';
              end if;
              if(trunc(l_st_time) = trunc(l_tbl(r).end_time))
              then
                 x_shift(l_idx).end_time           := to_char(l_tbl(r).end_time,'hh24.mi');
              else
                 x_shift(l_idx).end_time         := '23.59';
              end if;
              x_shift(l_idx).availability_type  := l_tbl(r).availability_type;

              l_st_time := l_st_time + 1;
          end loop;
       end if;
      end loop;
  exception
    when no_data_found then
       NULL;
  end; --2
  end if; --(1)
exception
    when no_data_found then
       NULL;
end; -- 1
    l_shift_date := l_shift_date + 1;
end loop;
--
-- Update return status to Success if there is atleast one available time slot
   if x_shift.count = 0  then
    x_return_status := fnd_api.g_ret_sts_error ;
    fnd_message.set_name('JTF','JTF_CAL_NO_SHIFT_CONSTR_FOUND');
    --fnd_message.set_name('JTF','JTF_CAL_NO_SHIFTS_FOR_RESOURCE');
    --fnd_message.set_token('P_RESOURCE_NAME', l_resource_name);
    fnd_msg_pub.add;
    fnd_msg_pub.count_and_get( p_count => x_msg_count
                             , p_data  => x_msg_data );
  end if;

  -- Added sort by jawang on 06/27/2002
  if x_shift.count > 0
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

  when others then
    x_return_status := fnd_api.g_ret_sts_unexp_error ;
    fnd_message.set_name('JTF','JTF_CAL_UNEXPECTED_ERROR');
    fnd_message.set_token('ERROR_CODE',sqlcode);
    fnd_message.set_token('ERROR_MESSAGE',sqlerrm);
    fnd_msg_pub.count_and_get ( p_count => x_msg_count
        		      , p_data  => x_msg_data );
  END get_available_time;


--
-- ****************** Get Available Time Slot **********************
--
PROCEDURE Get_Available_Slot
    (p_api_version         	IN		NUMBER		,
	p_init_msg_list		IN		VARCHAR2 := FND_API.G_FALSE,
	p_resource_id   	IN    		NUMBER		,
	p_resource_type		IN		VARCHAR2	,
	p_start_date_time       IN		DATE		,
        p_end_date_time         IN      	DATE            ,
	p_duration	        IN		NUMBER		,
	x_return_status		OUT NOCOPY VARCHAR2  	,
	x_msg_count		OUT NOCOPY NUMBER		,
	x_msg_data		OUT NOCOPY VARCHAR2	,
	x_slot_start_date	OUT NOCOPY DATE		,
        x_slot_end_date        	OUT NOCOPY DATE		,
        x_shift_construct_id   	OUT NOCOPY NUMBER          ,
        x_availability_type    	OUT NOCOPY VARCHAR2
)
IS
   l_api_name		       CONSTANT VARCHAR2(30) := 'Get_Available_Slot';
   l_api_version               CONSTANT NUMBER 	     := 1.0;
   l_return_status         VARCHAR2(1);
   l_msg_count             NUMBER;
   l_msg_data              VARCHAR2(250);
   l_shift                 jtf_calendar_pub_24hr.SHIFT_TBL_TYPE;
   v_start_date		   DATE;
   v_end_date		   DATE;
   v_slot_start_date  DATE;
   v_slot_end_date DATE;
   i number;

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
    IF not check_for_required_fields (p_resource_id 	=>p_resource_id,
                                      p_resource_type 	=>p_resource_type,
                                      p_start_date 	    =>p_start_date_time,
                                      p_end_date  	    =>p_end_date_time,
				                      p_duration	    =>p_duration)
    THEN
        l_parameters := 'p_resource_id, p_resource_type, p_start_date_time, p_end_date_time, p_duration';
	RAISE G_EXC_REQUIRED_FIELDS_NULL;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
--
    JTF_CALENDAR_PUB_24hr.Get_Available_Slot
       ( p_api_version        => l_api_version ,
         p_init_msg_list      => p_init_msg_list,
         p_resource_id        => p_resource_id,
         p_resource_type      => p_resource_type,
         p_start_date_time    => p_start_date_time,
         p_end_date_time      => p_end_date_time,
         p_duration           => p_duration,
         x_return_status      => x_return_status,
         x_msg_count          => x_msg_count,
         x_msg_data           => x_msg_data,
         x_slot_start_date    => x_slot_start_date,
         x_slot_end_date      => x_slot_end_date,
         x_shift_construct_id => x_shift_construct_id,
         x_availability_type  => x_availability_type );

EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count        	=>      x_msg_count,
        		p_data         	=>      x_msg_data
    		);
  WHEN  G_EXC_REQUIRED_FIELDS_NULL THEN
          x_return_status := FND_API.G_RET_STS_ERROR ;
          fnd_message.set_name('JTF','JTF_CAL_REQUIRED_PARAMETERS');
          fnd_message.set_token('P_PARAMETER', l_parameters);
          fnd_msg_pub.add;
	  FND_MSG_PUB.Count_And_Get
    	    (p_count        	=>      x_msg_count,
       	     p_data         	=>      x_msg_data
    	    );
  WHEN OTHERS THEN
	  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          fnd_message.set_name('JTF','JTF_CAL_UNEXPECTED_ERROR');
          fnd_message.set_token('ERROR_CODE',SQLCODE);
          fnd_message.set_token('ERROR_MESSAGE', SQLERRM);
          fnd_msg_pub.add;
	  FND_MSG_PUB.Count_And_Get
    	 (p_count        	=>      x_msg_count,
       	  p_data         	=>      x_msg_data
    	 );

END Get_Available_Slot;
--
-- *************  Get Resource Shifts  *******************
--
PROCEDURE get_resource_shifts
( p_api_version   in  number
, p_init_msg_list in  varchar2
, p_resource_id   in  number
, p_resource_type in  varchar2
, p_start_date	  in  date
, p_end_date	  in  date
, x_return_status out NOCOPY varchar2
, x_msg_count	  out NOCOPY number
, x_msg_data	  out NOCOPY varchar2
, x_shift	  out NOCOPY shift_tbl_type
)
IS
  type rec_type is record
  ( shift_construct_id number
  , start_time         date
  , end_time 	       date
  , availability_type  varchar2(40) );

  type tbl_type is table of rec_type index by binary_integer;

  cursor shift_info(p_calendar_id NUMBER) is
	select shift_id,(shift_end_date - shift_start_date) shift_duration
    from   jtf_cal_shift_assign
	where  calendar_id = p_calendar_id
    order by shift_sequence_number;

  cursor c_cal_shift_constr(p_shift_id NUMBER, p_day date, p_uot_value NUMBER) is
	select shift_construct_id,
	       begin_time start_constr,
       	   end_time end_constr,
       	   availability_type_code
	from   jtf_cal_shift_constructs
	where  shift_id = p_shift_id
--
--Modified condition to take care first Day of week for Bug 1342982
--
        and   to_char(begin_time, 'd') = to_char(p_day, 'd')
	-- validate shift construct
	-- added by jawang on 06/07/2002 to fix bug 2393255
	and ( (  p_day between start_date_active
	               and end_date_active)
	or   (start_date_active <=p_day
	and    end_date_active IS NULL));


  cursor c_cal_except
  ( p_calendar_id number
  , p_day         date )
  is
    select e.start_date_time start_except
    ,      e.end_date_time   end_except
    from jtf_cal_exception_assign a
    ,    jtf_cal_exceptions_vl    e
    where a.calendar_id  = p_calendar_id
    and   a.exception_id = e.exception_id
    -- validate exception assignment
    and   ( p_day >= trunc(a.start_date_active)
         or a.start_date_active is null)
    and   ( p_day <= trunc(a.end_date_active)
         or a.end_date_active is null)
    -- validate exception
    and p_day between trunc(e.start_date_time)
              and     trunc(e.end_date_time);

-- added the date check for bug #1355824

  l_api_name	    constant varchar2(30)   := 'Get_Resource_Shifts';
  l_api_version     constant number         := 1.0;
  l_parameters               varchar2(2000) := null;
  g_exc_required_fields_null exception;
  l_range_start              date;
  l_range_end                date;
  l_day		             date;
  l_utv                      number;
  l_idx                      number := 0;
  l_tbl		             tbl_type;
  l_cnt		             number;
  l_shifts_total_duration number;
  l_shift_date date;
  l_left_days number;
  l_calendar_id number;
  l_shift_id number;

  l_calendar_name jtf_calendars_vl.calendar_name%TYPE; -- bug # 2493461 varchar2(100)
  l_calendar_start_date date;
  l_exp_flg varchar2(1) := 'N';
  l_start_date_time date;
  l_st_time date;

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
         , JTF_CALENDAR_PUB.g_pkg_name )
  then
    raise fnd_api.g_exc_unexpected_error;
  end if;

  -- initialize message list if p_init_msg_list is set to true.
  if fnd_api.to_boolean ( p_init_msg_list )
  then
    fnd_msg_pub.initialize;
  end if;

  -- call to check for required fields
  if not JTF_CALENDAR_PUB.check_for_required_fields
         ( p_resource_id   => p_resource_id
         , p_resource_type => p_resource_type
         , p_start_date    => p_start_date
         , p_end_date  	   => p_start_date )
  then
    l_parameters := 'p_resource_id, p_resource_type, p_start_date, p_end_date';
    raise g_exc_required_fields_null;
  end if;

  -- initialize api return status to success
  x_return_status := fnd_api.g_ret_sts_success;

  -- bug# 1344222
  -- Comment out by jawang on 06/17/2002

  -- get all valid resource-to-calendar assignments for this resource in
  -- this period ordered by start date
  -- because there is a primary flag, only one record is expected

  -- This code is added to get resource name to be printed in error message.
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

l_shift_date := trunc(p_start_date);

While l_shift_date <= p_end_date Loop
    --added l_shift_date in valid_cal loop bug #1355824

    -- get the primary calendar for a resource on the given date
    --
  BEGIN --(1)
	  select a.calendar_id,b.calendar_name,b.start_date_active,a.start_date_time
	  into   l_calendar_id,l_calendar_name,l_calendar_start_date,l_start_date_time
	  from   jtf_cal_resource_assign a,
		 jtf_calendars_vl b
	  where  a.resource_id = p_resource_id
	  and    a.resource_type_code = p_resource_type
	  and    a.calendar_id = b.calendar_id
	  and    a.primary_calendar_flag = 'Y'
--  Commented for bug 3891896 by ABRAINA
--	  and    l_shift_date between trunc(a.start_date_time) and nvl(trunc(a.end_date_time),to_date(get_g_miss_date,'DD/MM/RRRR'));
	  and    l_shift_date between trunc(a.start_date_time) and nvl(trunc(a.end_date_time),l_shift_date);

          -- Added for bug 3270116
          l_return_status := FND_API.G_RET_STS_SUCCESS;

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
          l_shift_id := c.shift_id;
          EXIT;
        END IF;
      end loop;
-- Added by Sarvi

      -- calculate unit of time value
      -- this is dependant on nls setting
      l_utv := to_char(l_shift_date,'d');
      l_tbl.delete;
      l_idx := 0;
      for j in c_cal_shift_constr ( l_shift_id
                                  , l_shift_date
                                  , l_utv )
      loop
        l_idx := l_idx + 1;
        l_tbl(l_idx).shift_construct_id := j.shift_construct_id;
        -- The date part of the shift construct start is just a container
        -- without real meaning. In order to process the multi-day
        -- exceptions more easily, the requested day is added to it, so
        -- that the resulting datetime has a real meaning.
        -- added this chg for the 24 hr shift split .. sudarsana 23 oct 2001
         IF trunc(j.start_constr) = trunc(j.end_constr) THEN
             l_tbl(l_idx).start_time := l_shift_date + (j.start_constr - trunc(j.start_constr));
             l_tbl(l_idx).end_time   := l_shift_date + (j.end_constr - trunc(j.end_constr));
         else
             l_tbl(l_idx).start_time := l_shift_date + (j.start_constr - trunc(j.start_constr));
             l_tbl(l_idx).end_time   := l_shift_date + (j.end_constr - trunc(j.end_constr)) +
                                              (trunc(j.end_constr) - trunc(j.start_constr));
         end if;
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

      -- moved this code here so that exceptions are also adjusted for time zone conversion
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

      -- store found shift constructs for this day in output pl/sql table
    for r in 1..l_tbl.count
    loop
        if ((trunc(l_tbl(r).end_time)) = trunc((l_tbl(r).start_time))) THEN
           l_idx := x_shift.count + 1;
           x_shift(l_idx).shift_construct_id := l_tbl(r).shift_construct_id;
           x_shift(l_idx).shift_date         := trunc(l_tbl(r).start_time);
        -- reformat the start and end times just at the end of the procedure
        -- when the calculations are done
           x_shift(l_idx).start_time         := to_char(l_tbl(r).start_time,'hh24.mi');
           x_shift(l_idx).end_time           := to_char(l_tbl(r).end_time,'hh24.mi');
           x_shift(l_idx).availability_type  := l_tbl(r).availability_type;
        else
        --added this condition for 24hr shift .. sudarsana 22 Oct 2001
          l_st_time := l_tbl(r).start_time;
          while(trunc(l_st_time) <= trunc(l_tbl(r).end_time))
          loop
              l_idx := x_shift.count + 1;
              x_shift(l_idx).shift_construct_id := l_tbl(r).shift_construct_id;
              x_shift(l_idx).shift_date         := trunc(l_st_time);
              if(trunc(l_st_time) = trunc(l_tbl(r).start_time))
              then
                 x_shift(l_idx).start_time         := to_char(l_tbl(r).start_time,'hh24.mi');
              else
                 x_shift(l_idx).start_time         := '00.00';
              end if;
              if(trunc(l_st_time) = trunc(l_tbl(r).end_time))
              then
                 x_shift(l_idx).end_time           := to_char(l_tbl(r).end_time,'hh24.mi');
              else
                 x_shift(l_idx).end_time         := '23.59';
              end if;
              x_shift(l_idx).availability_type  := l_tbl(r).availability_type;

              l_st_time := l_st_time + 1;
          end loop;
        end if;
    end loop;
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
    	  (p_count        	=>      x_msg_count,
       	   p_data         	=>      x_msg_data
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
    	  (p_count        	=>      x_msg_count,
       	   p_data         	=>      x_msg_data
    	  );
  end; -- 1
-- end loop; -- valid cal
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

  -- Added sort by jawang on 06/27/2002
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
-- **********  Get Resource Shifts with 15 attributes ***********
--

PROCEDURE get_resource_shifts
( p_api_version   in  number
, p_init_msg_list in  varchar2
, p_resource_id   in  number
, p_resource_type in  varchar2
, p_start_date	  in  date
, p_end_date	  in  date
, x_return_status out NOCOPY varchar2
, x_msg_count	  out NOCOPY number
, x_msg_data	  out NOCOPY varchar2
, x_shift	  out NOCOPY shift_tbl_attributes_type
)
IS
  type rec_attributes_type is record
  ( shift_construct_id number
  , start_time         date
  , end_time 	       date
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

  cursor shift_info(p_calendar_id NUMBER) is
	select shift_id,(shift_end_date - shift_start_date) shift_duration
    from   jtf_cal_shift_assign
	where  calendar_id = p_calendar_id
    order by shift_sequence_number;

  cursor c_cal_shift_constr(p_shift_id NUMBER, p_day date, p_uot_value NUMBER) is
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
--
--Modified condition to take care first Day of week for Bug 1342982
--
        and   to_char(begin_time, 'd') = to_char(p_day, 'd')
        -- added by jawang on 06/07/2002 to fix bug 2393255
	and ( (  p_day between start_date_active
		       and end_date_active)
	or   (start_date_active <=p_day
	and    end_date_active IS NULL));

  cursor c_cal_except
  ( p_calendar_id number
  , p_day         date )
  is
    select e.start_date_time start_except
    ,      e.end_date_time   end_except
    from jtf_cal_exception_assign a
    ,    jtf_cal_exceptions_vl    e
    where a.calendar_id  = p_calendar_id
    and   a.exception_id = e.exception_id
    -- validate exception assignment
    and   ( p_day >= trunc(a.start_date_active)
         or a.start_date_active is null)
    and   ( p_day <= trunc(a.end_date_active)
         or a.end_date_active is null)
    -- validate exception
    and p_day between trunc(e.start_date_time)
              and     trunc(e.end_date_time);

   cursor valid_cal
    (p_resource_id number,
     p_resource_type varchar2,p_shift_date DATE) IS
 -- added p_shift_date bug 1355824
  select start_date_time
  from   jtf_cal_resource_assign
  where  resource_id = p_resource_id
  and    resource_type_code = p_resource_type
  and    primary_calendar_flag = 'Y'
  and  (( p_shift_date >= trunc(start_date_time) and end_date_time IS NULL )
          OR (p_shift_date between trunc(start_date_time)
 and trunc(end_date_time)));

  l_api_name	    constant varchar2(30)   := 'Get_Resource_Shifts';
  l_api_version     constant number         := 1.0;
  l_parameters               varchar2(2000) := null;
  g_exc_required_fields_null exception;
  l_range_start              date;
  l_range_end                date;
  l_day		             date;
  l_utv                      number;
  l_idx                      number := 0;
  l_tbl		             tbl_attributes_type;
  l_cnt		             number;
  l_shifts_total_duration number;
  l_shift_date date;
  l_left_days number;
  l_calendar_id number;
  l_shift_id number;

  l_calendar_name jtf_calendars_vl.calendar_name%TYPE; -- bug # 2493461 varchar2(100)
  l_calendar_start_date date;
  l_exp_flg varchar2(1) := 'N';
  l_start_date_time date;
  l_st_time date;
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
         , JTF_CALENDAR_PUB.g_pkg_name )
  then
    raise fnd_api.g_exc_unexpected_error;
  end if;

  -- initialize message list if p_init_msg_list is set to true.
  if fnd_api.to_boolean ( p_init_msg_list )
  then
    fnd_msg_pub.initialize;
  end if;

  -- call to check for required fields
  if not JTF_CALENDAR_PUB.check_for_required_fields
         ( p_resource_id   => p_resource_id
         , p_resource_type => p_resource_type
         , p_start_date    => p_start_date
         , p_end_date  	   => p_start_date )
  then
    l_parameters := 'p_resource_id, p_resource_type, p_start_date, p_end_date';
    raise g_exc_required_fields_null;
  end if;

  -- initialize api return status to success
  x_return_status := fnd_api.g_ret_sts_success;

  -- bug# 1344222
  -- Comment out by jawang on 06/17/2002

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

  -- get all valid resource-to-calendar assignments for this resource in
  -- this period ordered by start date
  -- because there is a primary flag, only one record is expected

  l_shift_date := trunc(p_start_date);

while l_shift_date <= p_end_date Loop
  -- We first check if there is a valid primary calendar on this date.
  -- for v in valid_cal(p_resource_id,p_resource_type,l_shift_date) loop
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

     --added l_shift_date in valid_cal loop bug #1355824
     -- if condition added for bug 3270116 by ABRAINA
     IF Validate_Cal_Date(l_calendar_id, l_shift_date)
     THEN
     -- This check is not necessary. Can be removed after testing.
     begin --(2)
        select sum(shift_end_date - shift_start_date)
        into   l_shifts_total_duration
        from   jtf_cal_shift_assign
        where  calendar_id = l_calendar_id;

        l_left_days := mod((l_shift_date - l_calendar_start_date),l_shifts_total_duration);

      l_shift_id := null;
      for c in shift_info(l_calendar_id) loop
         l_left_days := l_left_days - c.shift_duration;
        IF l_left_days <  0 THEN
           l_shift_id := c.shift_id;
           EXIT;
        END IF;
      end loop;
      -- Added by Sarvi

      -- calculate unit of time value
      -- this is dependant on nls setting
      l_utv := to_char(l_shift_date,'d');
      l_tbl.delete;
      l_idx := 0;
      for j in c_cal_shift_constr ( l_shift_id
                                  , l_shift_date
                                  , l_utv )
      loop
        l_idx := l_idx + 1;
        l_tbl(l_idx).shift_construct_id := j.shift_construct_id;
        -- The date part of the shift construct start is just a container
        -- without real meaning. In order to process the multi-day
        -- exceptions more easily, the requested day is added to it, so
        -- that the resulting datetime has a real meaning.
        -- added this chg for the 24 hr shift split .. sudarsana 23 oct 2001
         IF trunc(j.start_constr) = trunc(j.end_constr) THEN
             l_tbl(l_idx).start_time := l_shift_date + (j.start_constr - trunc(j.start_constr));
             l_tbl(l_idx).end_time   := l_shift_date + (j.end_constr - trunc(j.end_constr));
         else
             l_tbl(l_idx).start_time := l_shift_date + (j.start_constr - trunc(j.start_constr));
             l_tbl(l_idx).end_time   := l_shift_date + (j.end_constr - trunc(j.end_constr)) +
                                              (trunc(j.end_constr) - trunc(j.start_constr));
         end if;
        l_tbl(l_idx).availability_type  := j.availability_type_code;

        -- Added by Jane on 03/05/2002
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

            -- Added by Jane on 03/05/2002
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

            -- Added by Jane on 03/05/2002
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

            -- Added by Jane on 03/05/2002
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

            -- Added by Jane on 03/05/2002
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

            -- Added by Jane on 03/05/2002
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
        end loop; -- end loop thru the table loaded with shifts.
      end loop; -- end loop the exception cursor

        	-- Moved this code here so that exceptions are also considered for timezone conversion
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


      -- store found shift constructs for this day in output pl/sql table
     for r in 1..l_tbl.count
      loop
        if ((trunc(l_tbl(r).end_time)) = trunc((l_tbl(r).start_time))) THEN
           l_idx := x_shift.count + 1;
           x_shift(l_idx).shift_construct_id := l_tbl(r).shift_construct_id;
           x_shift(l_idx).shift_date         := trunc(l_tbl(r).start_time);
        -- reformat the start and end times just at the end of the procedure
        -- when the calculations are done
           x_shift(l_idx).start_time         := to_char(l_tbl(r).start_time,'hh24.mi');
           x_shift(l_idx).end_time           := to_char(l_tbl(r).end_time,'hh24.mi');
           x_shift(l_idx).availability_type  := l_tbl(r).availability_type;

           -- Added by Jane on 03/05/2002
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

        else
        --added this condition for 24hr shift .. sudarsana 22 Oct 2001
          l_st_time := l_tbl(r).start_time;
          while(trunc(l_st_time) <= trunc(l_tbl(r).end_time))
          loop
              l_idx := x_shift.count + 1;
              x_shift(l_idx).shift_construct_id := l_tbl(r).shift_construct_id;
              x_shift(l_idx).shift_date         := trunc(l_st_time);
              if(trunc(l_st_time) = trunc(l_tbl(r).start_time))
              then
                 x_shift(l_idx).start_time         := to_char(l_tbl(r).start_time,'hh24.mi');
              else
                 x_shift(l_idx).start_time         := '00.00';
              end if;
              if(trunc(l_st_time) = trunc(l_tbl(r).end_time))
              then
                 x_shift(l_idx).end_time           := to_char(l_tbl(r).end_time,'hh24.mi');
              else
                 x_shift(l_idx).end_time         := '23.59';
              end if;
              x_shift(l_idx).availability_type  := l_tbl(r).availability_type;

	      -- Added by Jane on 03/05/2002
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


              l_st_time := l_st_time + 1;
          end loop;
       end if;
      end loop;
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
    	  (p_count        	=>      x_msg_count,
       	   p_data         	=>      x_msg_data
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
    	  (p_count        	=>      x_msg_count,
       	   p_data         	=>      x_msg_data
    	  );
  end; -- 1
--  end loop; -- valid cal
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

  -- Added sort by jawang on 06/27/2002
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
-- **********   Get Resource Schedule   **************
--
PROCEDURE Get_Res_Schedule
( 	p_api_version         	IN	NUMBER				,
	p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE	,
	p_resource_id   	IN    	NUMBER			,
	p_resource_type		IN	VARCHAR2		,
	p_start_date		IN	DATE			,
	p_end_date		IN	DATE			,
	x_return_status		OUT NOCOPY VARCHAR2	  	,
	x_msg_count		OUT NOCOPY NUMBER			,
	x_msg_data		OUT NOCOPY VARCHAR2		,
	x_shift			OUT NOCOPY SHIFT_TBL_TYPE
)
IS
   l_api_name			CONSTANT VARCHAR2(30):= 'Get_Rsc_Schedule';
   l_api_version           	CONSTANT NUMBER := 1.0;
--
   cursor shift_info(p_calendar_id NUMBER) is
	select shift_id,(shift_end_date - shift_start_date) shift_duration
        from   jtf_cal_shift_assign
	where  calendar_id = p_calendar_id
        order by shift_sequence_number;
--
   cursor work_hrs(p_shift_id NUMBER, p_day date, p_uot_value NUMBER) is
	select shift_construct_id,
             begin_time  shift_begin_time,
             end_time    shift_end_time,
       	     availability_type_code
	from   jtf_cal_shift_constructs
	where  shift_id = p_shift_id
--
--Modified condition to take care first Day of week for Bug 1342982
--
        and   to_char(begin_time, 'd') = to_char(p_day, 'd')
        -- added by jawang on 06/07/2002 to fix by 2393255
        and ( (  p_day between start_date_active
                       and end_date_active)
        or   (start_date_active <=p_day
        and   end_date_active IS NULL));

--
   cursor excp_hrs(p_calendar_id NUMBER, p_req_date DATE) is
   	select to_char(a.start_date_time,'HH24.MI') excp_start_time,
           to_char(a.end_date_time,'HH24.MI') excp_end_time
   	from   jtf_cal_exceptions_vl a, jtf_cal_exception_assign b
   	where  trunc(a.start_date_time) = p_req_date
   	and    a.exception_id = b.exception_id
   	and    b.calendar_id  = p_calendar_id;
--

   cursor task_hrs(p_res_id NUMBER,p_res_type VARCHAR2,p_req_date DATE,p_tz_enabled VARCHAR2,p_server_tz_id NUMBER) is
   -- we are picking up the schedule time from task.

   --
   -- Removed "distinct" clause added ealier for bug 2817811 by A.Raina
   --
   -- Added two new parameters p_tz_enabled, p_server_tz_id and
   -- modified the query accordingly. Done by SBARAT on 23/06/2005 for Bug# 4443443
   --
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
               to_char(Decode(p_tz_enabled,'Y',
                              Decode(t.timezone_id,NULL, t.scheduled_start_date,
                                     Nvl(HZ_TIMEZONE_PUB.CONVERT_DATETIME(t.timezone_id,
                                                                          p_server_tz_id,
                                                                          t.scheduled_start_date),
                                         t.scheduled_start_date)
                                    ),
                              t.scheduled_start_date), 'HH24.MI'
                      )  task_start_time,
	         to_char(Decode(p_tz_enabled,'Y',
                              Decode(t.timezone_id,NULL, t.scheduled_end_date,
                                     Nvl(HZ_TIMEZONE_PUB.CONVERT_DATETIME(t.timezone_id,
                                                                          p_server_tz_id,
                                                                          t.scheduled_end_date),
                                         t.scheduled_end_date)
                                    ),
                              t.scheduled_end_date), 'HH24.MI'
                      ) task_end_time
        from   jtf_tasks_b t,
               jtf_task_assignments a,
               jtf_task_statuses_b s
        where  a.resource_id = p_res_id
        and    a.resource_type_code = p_res_type
        and    p_req_date between
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
	    and    s.task_status_id = a.assignment_status_id
        AND    t.task_id = a.task_id
	    and    nvl(s.cancelled_flag,'N') <> 'Y'
	    and    nvl(s.completed_flag,'N') <> 'Y'
        and t.scheduled_start_date <> t.scheduled_end_date ; -- bug # 2520762
      --

   j				INTEGER := 0;
   l_shift_id			NUMBER;
   l_unit_of_time_value         NUMBER;
   l_calendar_id                NUMBER;
   l_calendar_name              jtf_calendars_vl.calendar_name%TYPE; -- bug # 2493461 VARCHAR2(240)
   l_calendar_start_date        DATE;
   l_shifts_total_duration      NUMBER;
   l_left_days                  NUMBER;
   l_shift_date			DATE;
   l_res_type			VARCHAR2(30);
   l_st_date                    DATE;
   l_ed_time                    DATE;
   l_st_time                    DATE;
l_shift_b_time varchar2(25);
l_shift_b_date date;
l_shift_e_time varchar2(25);
l_shift_e_date date;
l_tz_enabled    VARCHAR2(10):=fnd_profile.value('ENABLE_TIMEZONE_CONVERSIONS'); -- Added by SBARAT on 23/06/2005 for Bug# 4443443
l_server_tz_id   Number :=   to_number (fnd_profile.value_specific('SERVER_TIMEZONE_ID'));
l_res_Timezone_id Number;

l_resource_name            jtf_task_resources_vl.resource_name%TYPE;-- bug # 2418561

BEGIN
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( 	l_api_version        	,
        	    	    	    	 	p_api_version        	,
   	       	    	 			l_api_name 	    	,
		    	    	    	    	G_PKG_NAME )
	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
	-- Initialize message list if p_init_msg_list is set to TRUE.
	IF FND_API.to_Boolean( p_init_msg_list ) THEN
		FND_MSG_PUB.initialize;
	END IF;
    -- Call to check for required fields
    IF not check_for_required_fields (p_resource_id 	=>p_resource_id,
                                      p_resource_type 	=>p_resource_type,
                                      p_start_date 	=>p_start_date,
                                      p_end_date  	=>p_end_date)
    THEN
        l_parameters := 'p_resource_id, p_resource_type, p_start_date, p_end_date';
	RAISE G_EXC_REQUIRED_FIELDS_NULL;
    END IF;
    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

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

--
l_shift_date := trunc(p_start_date);
x_shift.delete;
While l_shift_date <= p_end_date Loop
-- get the primary calendar for a resource on the given date
--
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
  IF Validate_Cal_Date(l_calendar_id, l_shift_date) THEN -- (1)
  --
  -- get the shift in which the given date falls for the above calendar
  --
  begin --(2)
    select sum(shift_end_date - shift_start_date)
    into   l_shifts_total_duration
    from   jtf_cal_shift_assign
    where  calendar_id = l_calendar_id;

    select mod((l_shift_date - l_calendar_start_date),l_shifts_total_duration)
    into   l_left_days
    from dual;

    l_shift_id := null;
    for c in shift_info(l_calendar_id) loop
      l_left_days := l_left_days - c.shift_duration;
      IF l_left_days < 0 THEN
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
    --
    -- Find the working hours on the Requested day
    --
    --FOR c1 in work_hrs(l_shift_id, l_unit_of_time_value) LOOP
    -- Modified by jawang on 06/07/2002 to fix the bug 2393255
    FOR c1 in work_hrs(l_shift_id, l_shift_date, l_unit_of_time_value) LOOP
     if(trunc(c1.shift_begin_time) = trunc(c1.shift_end_time))
     then
      j := x_shift.count + 1;
      x_shift(j).shift_construct_id := c1.shift_construct_id;
      x_shift(j).shift_date := l_shift_date;
      x_shift(j).start_time := to_char(c1.shift_begin_time, 'hh24.mi');
      x_shift(j).end_time   := to_char(c1.shift_end_time, 'hh24.mi');
      --
      --  Added for Simplex Timezone Enh # 3040681 by ABRAINA
      --
      If fnd_profile.value_specific('ENABLE_TIMEZONE_CONVERSIONS') = 'Y' Then
	  l_res_Timezone_id := Get_Res_Timezone_Id (p_resource_id, p_resource_type);
	  If l_res_Timezone_id <> l_server_tz_id Then
	      l_shift_b_time := to_char(l_shift_date,'DD-MON-YYYY')||' '||to_char(c1.shift_begin_time, 'hh24.mi');
	      l_shift_b_date := to_date(l_shift_b_time,'DD/MM/YYYY HH24:MI');
	      l_shift_e_time := to_char(l_shift_date,'DD-MON-YYYY')||' '||to_char(c1.shift_end_time, 'hh24.mi');
	      l_shift_e_date := to_date(l_shift_e_time,'DD/MM/YYYY HH24:MI');
	      x_shift(j).shift_date := to_char(ResourceDt_To_ServerDT(l_shift_b_date,l_res_Timezone_id,l_server_tz_id),'DD-MON-YYYY');
	      x_shift(j).start_time := to_char(ResourceDt_To_ServerDT(l_shift_b_date,l_res_Timezone_id,l_server_tz_id),'hh24.mi');
	      x_shift(j).end_time   := to_char(ResourceDt_To_ServerDT(l_shift_e_date,l_res_Timezone_id,l_server_tz_id),'hh24.mi');
	  End If;
	End If;
      x_shift(j).availability_type := 'W';
     else
       --added this condition for 24hr shift .. sudarsana 22 Oct 2001
          l_st_time := l_shift_date;
          l_ed_time := l_shift_date + (c1.shift_end_time - trunc(c1.shift_end_time)) +
                                              (trunc(c1.shift_end_time) - trunc(c1.shift_begin_time));
          while(trunc(l_st_time) <= trunc(l_ed_time))
          loop
              j := x_shift.count + 1;
              x_shift(j).shift_construct_id := c1.shift_construct_id;
              x_shift(j).shift_date         := trunc(l_st_time);
              if(trunc(l_st_time) = trunc(l_shift_date))
              then
                 x_shift(j).start_time         := to_char( c1.shift_begin_time,'hh24.mi');
              else
                 x_shift(j).start_time         := '00.00';
              end if;
              if(trunc(l_st_time) = trunc(l_ed_time))
              then
                 x_shift(j).end_time         := to_char(c1.shift_end_time,'hh24.mi');
              else
                 x_shift(j).end_time         := '23.59';
              end if;

              --
              --  Added for Simplex Timezone Enh # 3040681 by ABRAINA
              --
              If fnd_profile.value_specific('ENABLE_TIMEZONE_CONVERSIONS') = 'Y' Then
                l_res_Timezone_id := Get_Res_Timezone_Id (p_resource_id, p_resource_type);
                If l_res_Timezone_id <> l_server_tz_id Then
                    l_shift_b_time := to_char(l_shift_date,'DD-MON-YYYY')||' '||to_char(c1.shift_begin_time, 'hh24.mi');
                    l_shift_b_date := to_date(l_shift_b_time,'DD/MM/YYYY HH24:MI');
                    l_shift_e_time := to_char(l_shift_date,'DD-MON-YYYY')||' '||to_char(c1.shift_end_time, 'hh24.mi');
                    l_shift_e_date := to_date(l_shift_e_time,'DD/MM/YYYY HH24:MI');
                    x_shift(j).shift_date := to_char(ResourceDt_To_ServerDT(l_shift_b_date,l_res_Timezone_id,l_server_tz_id),'DD-MON-YYYY');
                    x_shift(j).start_time := to_char(ResourceDt_To_ServerDT(l_shift_b_date,l_res_Timezone_id,l_server_tz_id),'hh24.mi');
                    x_shift(j).end_time   := to_char(ResourceDt_To_ServerDT(l_shift_e_date,l_res_Timezone_id,l_server_tz_id),'hh24.mi');
                End If;
              End If;
              x_shift(j).availability_type  := 'W';

              l_st_time := l_st_time + 1;
          end loop;
       end if;
    END LOOP;
    --
    -- Find all the Exception hours on the requested date
    --
   For c2 in excp_hrs(l_calendar_id, l_shift_date) LOOP
      j := j + 1;
      x_shift(j).shift_date := l_shift_date;
      x_shift(j).start_time := c2.excp_start_time;
      x_shift(j).end_time   := c2.excp_end_time;
      x_shift(j).availability_type := 'E';
   END LOOP;
    --
    -- Find all the assigned Task hours on the requested date
    --
    -- Modified by SBARAT on 23/06/2005 for Bug# 4443443

    For c3 in task_hrs(p_resource_id,p_resource_type,l_shift_date,l_tz_enabled,l_server_tz_id) loop

    --
    -- Modified this code for bug 2817811 by A.Raina
    --
    IF l_shift_date = c3.task_start_date and l_shift_date = c3.task_end_date THEN
             j := j + 1;
             x_shift(j).shift_date := l_shift_date;
             x_shift(j).start_time := c3.task_start_time;
             x_shift(j).end_time   := c3.task_end_time;
             x_shift(j).availability_type := 'T';
    ELSIF l_shift_date = c3.task_start_date and l_shift_date <> c3.task_end_date THEN

                 FOR c1 in work_hrs(l_shift_id, l_shift_date, l_unit_of_time_value) LOOP
                    IF c3.task_start_time >= to_char(c1.shift_begin_time,'hh24.mi') THEN
                        j := j + 1;
                        x_shift(j).shift_date := l_shift_date;
                        x_shift(j).start_time := c3.task_start_time;
                        x_shift(j).end_time   := to_char(c1.shift_end_time,'hh24.mi');
                        x_shift(j).availability_type := 'T';
                    ELSE
                        j := j + 1;
                        x_shift(j).shift_date := l_shift_date;
                        x_shift(j).start_time := to_char(c1.shift_begin_time,'hh24.mi');
                        x_shift(j).end_time   := to_char(c1.shift_end_time,'hh24.mi');
                        x_shift(j).availability_type := 'T';
                    END IF;
                 END LOOP;

    ELSIF l_shift_date <> c3.task_start_date and l_shift_date <> c3.task_end_date THEN

                 FOR c1 in work_hrs(l_shift_id, l_shift_date, l_unit_of_time_value) LOOP
                    j := j + 1;
                    x_shift(j).shift_date := l_shift_date;
                    x_shift(j).start_time := to_char(c1.shift_begin_time,'hh24.mi');
                    x_shift(j).end_time   := to_char(c1.shift_end_time,'hh24.mi');
                    x_shift(j).availability_type := 'T';
                 End Loop;

    ELSIF l_shift_date <> c3.task_start_date and l_shift_date = c3.task_end_date THEN
                 FOR c1 in work_hrs(l_shift_id, l_shift_date, l_unit_of_time_value) LOOP
                    IF c3.task_end_time <= to_char(c1.shift_end_time,'hh24.mi') THEN
                        j := j + 1;
                        x_shift(j).shift_date := l_shift_date;
                        x_shift(j).start_time := to_char(c1.shift_begin_time,'hh24.mi');
                        x_shift(j).end_time   := c3.task_end_time;
                        x_shift(j).availability_type := 'T';
                    ELSE
                        j := j + 1;
                        x_shift(j).shift_date := l_shift_date;
                        x_shift(j).start_time := to_char(c1.shift_begin_time,'hh24.mi');
                        x_shift(j).end_time   := to_char(c1.shift_end_time,'hh24.mi');
                        x_shift(j).availability_type := 'T';
                    END IF;
                 END LOOP;
    END IF;
    --
    --End modification
    --

    END LOOP;
    exception
      when no_data_found then
	x_return_status := FND_API.G_RET_STS_ERROR ;
        fnd_message.set_name('JTF','JTF_CAL_NO_SHIFTS');
        fnd_message.set_token('P_CAL_NAME', l_calendar_name);
        fnd_msg_pub.add;
	FND_MSG_PUB.Count_And_Get
    	  (p_count        	=>      x_msg_count,
       	   p_data         	=>      x_msg_data
    	  );
    end; --(2)
  end if; --(1)
  exception
        when no_data_found then
	  x_return_status := FND_API.G_RET_STS_ERROR ;
          fnd_message.set_name('JTF','JTF_CAL_RES_NO_CAL');
          fnd_message.set_token('P_RES_NAME', l_resource_name);
          fnd_message.set_token('P_SHIFT_DATE', l_shift_date);
          fnd_msg_pub.add;
	  FND_MSG_PUB.Count_And_Get
    	    (p_count        	=>      x_msg_count,
       	     p_data         	=>      x_msg_data
    	    );
  end; --(1)
  l_shift_date := l_shift_date + 1;
end loop;
--
-- Update return status to Success if there is atleast one available time slot
   IF x_shift.count > 0 and x_return_status = 'E' THEN
        x_return_status := FND_API.G_RET_STS_SUCCESS;
   END IF;

  -- Added sort by jawang on 06/27/2002
   if x_shift.count > 0
   then
    -- sort the out table
       sort_tab(x_shift);
    end if;

EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count        	=>      x_msg_count,
        		p_data         	=>      x_msg_data
    		);
  WHEN  G_EXC_REQUIRED_FIELDS_NULL THEN
          x_return_status := FND_API.G_RET_STS_ERROR ;
          fnd_message.set_name('JTF','JTF_CAL_REQUIRED_PARAMETERS');
          fnd_message.set_token('P_PARAMETER', l_parameters);
          fnd_msg_pub.add;
	  FND_MSG_PUB.Count_And_Get
    	    (p_count        	=>      x_msg_count,
       	     p_data         	=>      x_msg_data
    	    );
  WHEN OTHERS THEN
	  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          fnd_message.set_name('JTF','JTF_CAL_UNEXPECTED_ERROR');
          fnd_message.set_token('ERROR_CODE',SQLCODE);
          fnd_message.set_token('ERROR_MESSAGE', SQLERRM);
          fnd_msg_pub.add;
	  FND_MSG_PUB.Count_And_Get
    	   (p_count        	=>      x_msg_count,
            p_data         	=>      x_msg_data
    	   );

 END Get_Res_Schedule;

function get_g_false return varchar2 is
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

--
--  Function ResourceDt_To_ServerDT Added for Simplex Timezone Enh # 3040681 by ABRAINA
--

--
--  Function ResourceDt_To_ServerDT Added for Simplex Timezone Enh # 3040681 by ABRAINA
--

Function ResourceDt_To_ServerDT ( P_Resource_DtTime IN date, P_Resource_TZ_Id IN Number , p_Server_TZ_id IN Number ) RETURN date IS

 x_Server_time	   Date := P_Resource_DtTime;

 l_api_name		   CONSTANT VARCHAR2(30) := 'ResourceDt_To_ServerDT';
 l_API_VERSION       Number := 1.0 ;
 p_API_VERSION       Number := 1.0 ;
 l_INIT_MSG_LIST     varchar2(1) := 'F';
 p_INIT_MSG_LIST     varchar2(1) := 'F';
 X_msg_count	   Number;
 X_msg_data		   Varchar2(2000);
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
    		(  	p_count        	=>      x_msg_count,
        		p_data         	=>      x_msg_data
    		);
  WHEN  G_EXC_REQUIRED_FIELDS_NULL THEN
	  x_return_status := FND_API.G_RET_STS_ERROR ;
          fnd_message.set_name('JTF','JTF_CAL_REQUIRED_PARAMETERS');
          fnd_message.set_token('P_PARAMETER', l_parameters);
          fnd_msg_pub.add;
	  FND_MSG_PUB.Count_And_Get
    	    (p_count        	=>      x_msg_count,
       	     p_data         	=>      x_msg_data
    	    );
  WHEN OTHERS THEN
	  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          fnd_message.set_name('JTF','JTF_CAL_UNEXPECTED_ERROR');
          fnd_message.set_token('ERROR_CODE',SQLCODE);
          fnd_message.set_token('ERROR_MESSAGE', SQLERRM);
          fnd_msg_pub.add;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count        	=>      x_msg_count,
        		p_data         	=>      x_msg_data
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
   from jtf_calendars_b a
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

END JTF_CALENDAR_PUB;


/

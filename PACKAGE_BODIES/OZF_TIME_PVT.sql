--------------------------------------------------------
--  DDL for Package Body OZF_TIME_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_TIME_PVT" AS
/*$Header: ozfvtimb.pls 120.2 2005/09/26 16:41:19 mkothari noship $*/

g_schema          varchar2(30);
g_phase           varchar2(500);
g_week_offset     number;
g_user_id         number;
g_login_id        number;
g_all_level       varchar2(1);
g_debug_flag 	  VARCHAR2(1)  := 'Y'; -- always show this LOG

g_global_start_date  date;
g_period_set_name varchar2(15) := null;
g_period_type     varchar2(15) := null;
g_week_start_day  varchar2(30) := null;


G_TABLE_NOT_EXIST               EXCEPTION;
G_LOGIN_INFO_NOT_FOUND          EXCEPTION;
G_OZF_PARAMETER_NOT_SETUP       EXCEPTION;
G_ENT_CALENDAR_NOT_FOUND        EXCEPTION;

PRAGMA EXCEPTION_INIT(G_TABLE_NOT_EXIST, -942);

---------------------------------------------------
-- PRIVATE FUNCTION get_week_offset
---------------------------------------------------
function get_week_offset(p_week_start_day varchar2) return number is

   l_week_offset number;

begin

   /*case p_week_start_day
     when '2' then l_week_offset := 0;
     when '3' then l_week_offset := 1;
     when '4' then l_week_offset := 2;
     when '5' then l_week_offset := 3;
     when '6' then l_week_offset := -3;
     when '7' then l_week_offset := -2;
     when '1' then l_week_offset := -1;
   end case;*/

   if p_week_start_day = '2' then
     l_week_offset := 0;
   elsif p_week_start_day = '3' then
     l_week_offset := 1;
   elsif p_week_start_day = '4' then
     l_week_offset := 2;
   elsif p_week_start_day = '5' then
     l_week_offset := 3;
   elsif p_week_start_day = '6' then
     l_week_offset := -3;
   elsif p_week_start_day = '7' then
     l_week_offset := -2;
   elsif p_week_start_day = '1' then
     l_week_offset := -1;
   end if;

   return l_week_offset;

end get_week_offset;

---------------------------------------------------
-- PRIVATE FUNCTION get_week_num
---------------------------------------------------
function get_week_num(p_date date, p_week_offset number) return number is

   l_week_num number;

begin

   l_week_num := to_char(p_date-p_week_offset,'iw');
   return l_week_num;

end get_week_num;

---------------------------------------------------
-- PRIVATE FUNCTION get_period_num
---------------------------------------------------
function get_period_num(week_num number) return number is

   l_period_num  number;

begin

   if week_num in (1,2,3,4) then
     l_period_num := 1;
   elsif week_num in (5,6,7,8) then
     l_period_num := 2;
   elsif week_num in (9,10,11,12,13) then
     l_period_num := 3;
   elsif week_num in (14,15,16,17) then
     l_period_num := 4;
   elsif week_num in (18,19,20,21) then
     l_period_num := 5;
   elsif week_num in (22,23,24,25,26) then
     l_period_num := 6;
   elsif week_num in (27,28,29,30) then
     l_period_num := 7;
   elsif week_num in (31,32,33,34) then
     l_period_num := 8;
   elsif week_num in (35,36,37,38,39) then
     l_period_num := 9;
   elsif week_num in (40,41,42,43) then
     l_period_num := 10;
   elsif week_num in (44,45,46,47) then
     l_period_num := 11;
   else
     l_period_num := 12;
   end if;
   return l_period_num;
end get_period_num;

---------------------------------------------------
-- PRIVATE FUNCTION get_period_start
---------------------------------------------------
function get_period_start(p_date date) return date is

   l_week_start    date;
   l_period_start  date;
   l_week_num      number;
   l_week_sequence number;
   l_period_num    number;

begin

   l_week_start := trunc(p_date-g_week_offset,'iw')+g_week_offset;
   l_week_num := get_week_num(l_week_start,g_week_offset);
   l_period_num := get_period_num(l_week_num);

   if l_week_num in (1,5,9,14,18,22,27,31,35,40,44,48) then
     l_week_sequence := 0;
   elsif l_week_num in (2,6,10,15,19,23,28,32,36,41,45,49) then
     l_week_sequence := 1;
   elsif l_week_num in (3,7,11,16,20,24,29,33,37,42,46,50) then
     l_week_sequence := 2;
   elsif l_week_num in (4,8,12,17,21,25,30,34,38,43,47,51) then
     l_week_sequence := 3;
   else
     l_week_sequence := 4;
   end if;

   l_period_start := l_week_start-l_week_sequence*7;
   return l_period_start;

end get_period_start;

---------------------------------------------------
-- PRIVATE PROCEDURE TRUNCATE_TABLE
---------------------------------------------------
procedure truncate_table (p_table_name in varchar2) is
  l_stmt varchar2(400);
Begin

  l_stmt := 'truncate table '||g_schema||'.'||p_table_name;
  if g_debug_flag = 'Y' then
  	OZF_TP_UTIL_PVT.put_line(l_stmt);
  end if;
  execute immediate l_stmt;

Exception
  WHEN G_TABLE_NOT_EXIST THEN
    null;      -- Oracle 942, table does not exist, no actions
  WHEN OTHERS THEN
    raise;
End truncate_table;

---------------------------------------------------
-- PRIVATE PROCEDURE INIT
---------------------------------------------------
PROCEDURE INIT IS
  l_status		 VARCHAR2(30);
  l_industry	VARCHAR2(30);
begin

   -- ----------------------
   -- Initialize the global variables
   -- ----------------------

   OZF_TP_UTIL_PVT.initialize;

   IF(FND_INSTALLATION.GET_APP_INFO('OZF', l_status, l_industry, g_schema))
        THEN NULL;
   END IF;

   g_user_id := FND_GLOBAL.User_Id;
   g_login_id := FND_GLOBAL.Login_Id;

   IF (g_user_id IS NULL OR g_login_id IS NULL) THEN
     RAISE G_LOGIN_INFO_NOT_FOUND;
   END IF;

   if (g_all_level = 'Y') then
     g_period_set_name := ozf_common_parameters_pvt.get_period_set_name;
     g_period_type     := ozf_common_parameters_pvt.get_period_type;
     if g_debug_flag = 'Y' then
  	   OZF_TP_UTIL_PVT.put_line('Enterprise Calendar = '||g_period_set_name||' ('||g_period_type||')');
     end if;
     g_week_start_day := ozf_common_parameters_pvt.get_start_day_of_week_id;
     if (g_period_set_name is null or g_period_type is null or g_week_start_day is null) then
       raise G_OZF_PARAMETER_NOT_SETUP;
     end if;
     if g_debug_flag = 'Y' then
  	   OZF_TP_UTIL_PVT.put_line('Week Start Day = '||g_week_start_day);
     end if;
     g_week_offset := get_week_offset(g_week_start_day);
     if g_debug_flag = 'Y' then
   	  OZF_TP_UTIL_PVT.put_line('Week offset = '||g_week_offset);
  	   OZF_TP_UTIL_PVT.put_line(' ');
     end if;

--     g_global_start_date := to_date('01/01/1997','MM/DD/YYYY');

     g_global_start_date := ozf_common_parameters_pvt.GET_GLOBAL_START_DATE;
     if (g_global_start_date is null) then
       if g_debug_flag = 'Y' then
         OZF_TP_UTIL_PVT.put_line('Global Start Date is not setup!');
       end if;
       raise G_OZF_PARAMETER_NOT_SETUP;
     end if;

     if g_debug_flag = 'Y' then
  	   OZF_TP_UTIL_PVT.put_line('Global Start Date = ' || g_global_start_date);
           OZF_TP_UTIL_PVT.put_line(' ');
     end if;
   end if;

end INIT;

---------------------------------------------------
-- PRIVATE PROCEDURE LOAD_DAY_INC
-- >> Load Day Level Incrementally
---------------------------------------------------
PROCEDURE LOAD_DAY_INC (p_from_date in date, p_to_date in date) IS

   -- ---------------------------------------------------------
   -- Define local variables
   -- ---------------------------------------------------------
   l_from_date          date;
   l_to_date            date;
   l_day                date;
   l_week_num           number;
   l_p445_num           number;
   l_year_num           number;
   l_day_row            number;
   l_period_year        gl_periods.period_year%TYPE;
   l_quarter_num        gl_periods.quarter_num%TYPE;
   l_period_num         gl_periods.period_num%TYPE;
   l_start_date         gl_periods.start_date%TYPE;
   l_quarter_start_date gl_periods.quarter_start_date%TYPE;
   l_year_start_date    gl_periods.year_start_date%TYPE;
   l_count              number;

   cursor ent_period_cur (day date) is
     select period_year, quarter_num, period_num, start_date, quarter_start_date, year_start_date
     from   gl_periods
     where  adjustment_period_flag='N'
     and    period_set_name=g_period_set_name
     and    period_type=g_period_type
     and    day between start_date and end_date;

begin

   -- ---------------------------------------------------------
   -- Variable initialization
   -- ---------------------------------------------------------
   l_from_date   := p_from_date;
   l_to_date     := p_to_date;
   l_day         := l_from_date;
   l_day_row     := 0;

   -- ----------------------
   -- Populate Day Level
   -- ----------------------
   while l_day <= l_to_date loop
     if (g_all_level='Y') then
       open ent_period_cur(l_day);
       fetch ent_period_cur into l_period_year, l_quarter_num, l_period_num,
                                 l_start_date, l_quarter_start_date, l_year_start_date;
       if (ent_period_cur%notfound) then
         raise G_ENT_CALENDAR_NOT_FOUND;
       else
         l_week_num := get_week_num(l_day,g_week_offset);
         l_p445_num := get_period_num(l_week_num);
         l_year_num := to_char(l_day-g_week_offset,'iyyy');
       end if;
     else
       l_period_year := -1;
       l_quarter_num := null;
       l_period_num := null;
       l_start_date := trunc(sysdate);
       l_quarter_start_date := trunc(sysdate);
       l_year_start_date := trunc(sysdate);
       l_week_num := null;
       l_p445_num := null;
       l_year_num := -1;
     end if;

-- first check if the current day is loaded
       SELECT count(*) into l_count
       FROM   OZF_TIME_DAY
       WHERE  report_date = trunc(l_day);

-- do an incremental update/insert
       if l_count = 0 then  -- new record, insert

        insert into OZF_TIME_DAY
        (report_date,
         report_date_julian,
         start_date,
         end_date,
         month_id,
         ent_period_id,
         ent_period_start_date,
         ent_qtr_id,
         ent_qtr_start_date,
         ent_year_id,
         ent_year_start_date,
         week_id,
         week_start_date,
         creation_date,
         last_update_date,
         last_updated_by,
         created_by,
         last_update_login)
        values(
         trunc(l_day),
         to_char(l_day,'j'),
         l_day,
         l_day,
         to_number(to_char(l_day,'yyyyqmm')),
         --l_period_year||l_quarter_num||lpad(l_period_num,2,'0'),
         l_period_year||l_quarter_num||decode(length(l_period_num),1,'0'||l_period_num, l_period_num),
         l_start_date,
         l_period_year||l_quarter_num,
         l_quarter_start_date,
         l_period_year,
         l_year_start_date,
         l_year_num||lpad(l_p445_num,2,'0')||lpad(l_week_num,2,'0'),
         nvl(trunc(l_day-g_week_offset,'iw')+g_week_offset,trunc(sysdate)),
         sysdate,
         sysdate,
         g_user_id,
         g_user_id,
         g_login_id
        );

        l_day_row := l_day_row+1;

       else -- the day has been loaded, update those changed records only

        update OZF_TIME_DAY
        set
           ent_period_id = --l_period_year||l_quarter_num||lpad(l_period_num,2,'0'),
           l_period_year||l_quarter_num||decode(length(l_period_num),1,'0'||l_period_num, l_period_num),
           ent_period_start_date = l_start_date,
           ent_qtr_id = l_period_year||l_quarter_num,
           ent_qtr_start_date = l_quarter_start_date,
           ent_year_id = l_period_year,
           ent_year_start_date = l_year_start_date,
           week_id = l_year_num||lpad(l_p445_num,2,'0')||lpad(l_week_num,2,'0'),
           week_start_date = nvl(trunc(l_day-g_week_offset,'iw')+g_week_offset,trunc(sysdate)),
           last_update_date = sysdate,
           last_updated_by = g_user_id,
           last_update_login = g_login_id
        where report_date = trunc (l_day)
        and   (ent_period_id <> --l_period_year||l_quarter_num||lpad(l_period_num,2,'0')
               l_period_year||l_quarter_num||decode(length(l_period_num),1,'0'||l_period_num, l_period_num) or
               ent_period_start_date <> l_start_date or
               NVL(ent_qtr_start_date,  to_date('01/01/1000', 'DD/MM/YYYY')) <>
                         NVL(l_quarter_start_date, to_date('01/01/1000', 'DD/MM/YYYY')) or
               NVL(ent_year_start_date, to_date('01/01/1000', 'DD/MM/YYYY')) <>
                         NVL(l_year_start_date, to_date('01/01/1000', 'DD/MM/YYYY')));

        l_day_row := l_day_row + sql%rowcount;

       end if;   --for: if l_count = 0

     if (g_all_level='Y') then
       close ent_period_cur;
     end if;

     l_period_year := null;
     l_quarter_num := null;
     l_period_num := null;
     l_start_date := null;
     l_quarter_start_date := null;
     l_year_start_date := null;

-- move to the next day
     l_day := l_day+1;
   end loop;

   commit;
   if g_debug_flag = 'Y' then
 	  OZF_TP_UTIL_PVT.put_line(to_char(l_day_row)||' records has been populated or updated to Day Level');
   end if;

end LOAD_DAY_INC;

---------------------------------------------------
-- PRIVATE PROCEDURE LOAD_DAY
--    even though this procedure is not used currently,
--    it is coded as a backup of load_day_inc
---------------------------------------------------
PROCEDURE LOAD_DAY(p_from_date in date, p_to_date in date) IS

   -- ---------------------------------------------------------
   -- Define local variables
   -- ---------------------------------------------------------
   l_from_date          date;
   l_to_date            date;
   l_day                date;
   l_week_num           number;
   l_p445_num           number;
   l_year_num           number;
   l_day_row            number;
   l_period_year        gl_periods.period_year%TYPE;
   l_quarter_num        gl_periods.quarter_num%TYPE;
   l_period_num         gl_periods.period_num%TYPE;
   l_start_date         gl_periods.start_date%TYPE;
   l_quarter_start_date gl_periods.quarter_start_date%TYPE;
   l_year_start_date    gl_periods.year_start_date%TYPE;

   cursor ent_period_cur (day date) is
     select period_year, quarter_num, period_num, start_date, quarter_start_date, year_start_date
     from   gl_periods
     where  adjustment_period_flag='N'
     and    period_set_name=g_period_set_name
     and    period_type=g_period_type
     and    day between start_date and end_date;

begin

   truncate_table('OZF_TIME_DAY');

   -- ---------------------------------------------------------
   -- Variable initialization
   -- ---------------------------------------------------------
   l_from_date   := p_from_date;
   l_to_date     := p_to_date;
   l_day         := l_from_date;
   l_day_row     := 0;

   -- ----------------------
   -- Populate Day Level
   -- ----------------------
   while l_day <= l_to_date loop
     open ent_period_cur(l_day);
     fetch ent_period_cur into l_period_year, l_quarter_num, l_period_num, l_start_date, l_quarter_start_date, l_year_start_date;
     if ent_period_cur%notfound then
       raise G_ENT_CALENDAR_NOT_FOUND;
     else
       l_week_num := get_week_num(l_day,g_week_offset);
       l_p445_num := get_period_num(l_week_num);
       l_year_num := to_char(l_day-g_week_offset,'iyyy');
       insert into OZF_TIME_DAY
       (report_date,
        report_date_julian,
        start_date,
        end_date,
        month_id,
        ent_period_id,
        ent_period_start_date,
        ent_qtr_id,
        ent_qtr_start_date,
        ent_year_id,
        ent_year_start_date,
        week_id,
        week_start_date,
        creation_date,
        last_update_date,
        last_updated_by,
        created_by,
        last_update_login)
       values(
        trunc(l_day),
        to_char(l_day,'j'),
        l_day,
        l_day,
        to_number(to_char(l_day,'yyyyqmm')),
        l_period_year||l_quarter_num||decode(length(l_period_num),1,'0'||l_period_num, l_period_num),
        --l_period_year||l_quarter_num||lpad(l_period_num,2,'0'),
        l_start_date,
        l_period_year||l_quarter_num,
        l_quarter_start_date,
        l_period_year,
        l_year_start_date,
        l_year_num||lpad(l_p445_num,2,'0')||lpad(l_week_num,2,'0'),
        trunc(l_day-g_week_offset,'iw')+g_week_offset,
        sysdate,
        sysdate,
        g_user_id,
        g_user_id,
        g_login_id
       );

       l_day_row := l_day_row+1;
     end if;
     close ent_period_cur;
     l_period_year := null;
     l_quarter_num := null;
     l_period_num := null;
     l_start_date := null;
     l_quarter_start_date := null;
     l_year_start_date := null;
     l_day := l_day+1;
   end loop;

   commit;
   if g_debug_flag = 'Y' then
	   OZF_TP_UTIL_PVT.put_line(to_char(l_day_row)||' records has been populated to Day Level');
   end if;

end LOAD_DAY;

---------------------------------------------------
-- PRIVATE PROCEDURE LOAD_WEEK
---------------------------------------------------
PROCEDURE LOAD_WEEK(p_from_date in date, p_to_date in date) IS

   -- ---------------------------------------------------------
   -- Define local variables
   -- ---------------------------------------------------------
   l_from_date          date;
   l_to_date            date;
   l_week               date;
   l_week_end           date;
   l_week_num           number;
   l_period_num         number;
   l_year_num           number;
   l_week_row           number;

begin

   -- ---------------------------------------------------------
   -- Variable initialization
   -- ---------------------------------------------------------
   l_from_date   := p_from_date;
   l_to_date     := trunc(p_to_date-g_week_offset,'iw')+g_week_offset+6;
   l_week        := trunc(l_from_date-g_week_offset,'iw')+g_week_offset;
   l_week_end    := l_week+6;
   l_week_num    := get_week_num(l_week,g_week_offset);
   l_period_num  := get_period_num(l_week_num);
   l_year_num    := to_char(l_week-g_week_offset,'iyyy');
   l_week_row    := 0;

   delete from OZF_TIME_WEEK where start_date <= l_to_date and end_date >= l_from_date;

   -- ----------------------
   -- Populate Week Level
   -- ----------------------
   while l_week <= l_to_date loop
     insert into OZF_TIME_WEEK
     (week_id,
      period445_id,
      sequence,
      name,
      start_date,
      end_date,
      creation_date,
      last_update_date,
      last_updated_by,
      created_by,
      last_update_login)
     values
     (
      l_year_num||lpad(l_period_num,2,'0')||lpad(l_week_num,2,'0'),
      l_year_num||lpad(l_period_num,2,'0'),
      l_week_num,
      to_char(l_week_end,'dd-Mon-rr'),
      l_week,
      l_week_end,
      sysdate,
      sysdate,
      g_user_id,
      g_user_id,
      g_login_id
     );

     l_week := l_week_end+1;
     l_week_end := l_week+6;
     l_week_num := get_week_num(l_week,g_week_offset);
     l_period_num := get_period_num(l_week_num);
     l_year_num := to_char(l_week-g_week_offset,'iyyy');
     l_week_row := l_week_row+1;
   end loop;

   commit;
   if g_debug_flag = 'Y' then
	   OZF_TP_UTIL_PVT.put_line(to_char(l_week_row)||' records has been populated to Week Level');
   end if;

end LOAD_WEEK;

---------------------------------------------------
-- PRIVATE PROCEDURE LOAD_ENT_PERIOD
---------------------------------------------------
PROCEDURE LOAD_ENT_PERIOD(p_from_date in date, p_to_date in date) IS

   -- ---------------------------------------------------------
   -- Define local variables
   -- ---------------------------------------------------------
   l_from_date          date;
   l_to_date            date;
   l_period_row         number;

begin

   -- ---------------------------------------------------------
   -- Variable initialization
   -- ---------------------------------------------------------
   l_from_date   := p_from_date;
   l_to_date     := p_to_date;
   l_period_row  := 0;

   delete from OZF_TIME_ENT_PERIOD where start_date <= l_to_date and end_date >= l_from_date;

   -- ----------------------
   -- Populate Enterprise Period Level
   -- ----------------------
   insert into OZF_TIME_ENT_PERIOD
   (ent_period_id,
    ent_qtr_id,
    ent_year_id,
    sequence,
    name,
    start_date,
    end_date,
    creation_date,
    last_update_date,
    last_updated_by,
    created_by,
    last_update_login)
   select
          to_number(period_year||quarter_num||decode(length(period_num),1,'0'||period_num, period_num)),
          --to_number(period_year||quarter_num||lpad(period_num,2,'0')),
          to_number(period_year||quarter_num),
          to_number(period_year),
          period_num,
          period_name,
          start_date,
          end_date,
          sysdate,
          sysdate,
          g_user_id,
          g_user_id,
          g_login_id
   from   gl_periods
   where  period_set_name = g_period_set_name
   and    period_type = g_period_type
   and    adjustment_period_flag='N'
   and    start_date <= l_to_date
   and    end_date >= l_from_date;

   l_period_row := sql%rowcount;
   commit;
   if g_debug_flag = 'Y' then
	   OZF_TP_UTIL_PVT.put_line(to_char(l_period_row)||' records has been populated to Enterprise Period Level');
   end if;

end LOAD_ENT_PERIOD;

---------------------------------------------------
-- PRIVATE PROCEDURE LOAD_ENT_QUARTER
---------------------------------------------------
PROCEDURE LOAD_ENT_QUARTER(p_from_date in date, p_to_date in date) IS

   -- ---------------------------------------------------------
   -- Define local variables
   -- ---------------------------------------------------------
   l_from_date          date;
   l_to_date            date;
   l_qtr_row            number;

begin

   -- ---------------------------------------------------------
   -- Variable initialization
   -- ---------------------------------------------------------
   l_from_date   := p_from_date;
   l_to_date     := p_to_date;
   l_qtr_row     := 0;

   delete from OZF_TIME_ENT_QTR where start_date <= l_to_date and end_date >= l_from_date;

   -- ----------------------
   -- Populate Enterprise Quarter Level
   -- ----------------------
   insert into OZF_TIME_ENT_QTR
   (ent_qtr_id,
    ent_year_id,
    sequence,
    name,
    start_date,
    end_date,
    creation_date,
    last_update_date,
    last_updated_by,
    created_by,
    last_update_login)
   select distinct gl.period_year||gl.quarter_num,
          gl.period_year,
          gl.quarter_num,
          replace(fnd_message.get_string('OZF','OZF_TP_QUARTER_LABEL'),'&QUARTER_NUMBER',gl.quarter_num)||'-'||to_char(to_date(gl.period_year,'yyyy'),'RR'),
          gl2.start_date,
          gl2.end_date,
          sysdate,
          sysdate,
          g_user_id,
          g_user_id,
          g_login_id
   from   gl_periods gl,
          (select period_year||quarter_num ent_qtr_pk_key, min(start_date) start_date, max(end_date) end_date
           from gl_periods
           where period_set_name=g_period_set_name
           and period_type=g_period_type
           and adjustment_period_flag='N'
           group by period_year||quarter_num) gl2
   where gl.period_year||gl.quarter_num = gl2.ent_qtr_pk_key
   and gl.period_set_name = g_period_set_name
   and gl.period_type = g_period_type
   and gl.adjustment_period_flag='N'
   and gl.start_date <= l_to_date
   and gl.end_date >= l_from_date;

   l_qtr_row := sql%rowcount;
   commit;
   if g_debug_flag = 'Y' then
	   OZF_TP_UTIL_PVT.put_line(to_char(l_qtr_row)||' records has been populated to Enterprise Quarter Level');
   end if;

end LOAD_ENT_QUARTER;

---------------------------------------------------
-- PRIVATE PROCEDURE LOAD_ENT_YEAR
---------------------------------------------------
PROCEDURE LOAD_ENT_YEAR(p_from_date in date, p_to_date in date) IS

   -- ---------------------------------------------------------
   -- Define local variables
   -- ---------------------------------------------------------
   l_from_date          date;
   l_to_date            date;
   l_year_row           number;
   l_end_date           date;

begin

   -- ---------------------------------------------------------
   -- Variable initialization
   -- ---------------------------------------------------------
   l_from_date   := p_from_date;
   l_to_date     := p_to_date;
   l_year_row    := 0;

   select nvl(max(end_date), l_to_date)
   into l_end_date
   from ozf_time_ent_period;

   delete from OZF_TIME_ENT_YEAR where ent_year_id in
   (select period_year
    from gl_periods
    where period_set_name = g_period_set_name
    and period_type = g_period_type
    and adjustment_period_flag='N'
    and start_date <= l_to_date
    and end_date >= l_from_date);

   -- ----------------------
   -- Populate Enterprise Year Level
   -- ----------------------
   insert into OZF_TIME_ENT_YEAR
   (ent_year_id,
    period_set_name,
    period_type,
    sequence,
    name,
    start_date,
    end_date,
    creation_date,
    last_update_date,
    last_updated_by,
    created_by,
    last_update_login)
   select distinct gl.period_year ent_year_pk_key,
          gl.period_set_name period_set_name,
          gl.period_type period_type,
          gl.period_year,
          gl.period_year name,
          gl2.start_date start_date,
          gl2.end_date end_date,
          sysdate creation_date,
          sysdate last_update_date,
          g_user_id last_updated_by,
          g_user_id created_by,
          g_login_id last_update_login
   from gl_periods gl,
        (select period_year period_year, min(start_date) start_date, max(end_date) end_date
         from gl_periods
         where period_set_name=g_period_set_name
         and period_type=g_period_type
         and adjustment_period_flag='N'
         and end_date <= l_end_date
         group by period_year) gl2
   where gl.period_year=gl2.period_year
   and gl.period_set_name = g_period_set_name
   and gl.period_type = g_period_type
   and gl.adjustment_period_flag='N'
   and gl.start_date <= l_to_date
   and gl.end_date >= l_from_date;

   l_year_row := sql%rowcount;
   commit;
   if g_debug_flag = 'Y' then
 	  OZF_TP_UTIL_PVT.put_line(to_char(l_year_row)||' records has been populated to Enterprise Year Level');
   end if;

end LOAD_ENT_YEAR;


---------------------------------------------------
-- PUBLIC PROCEDURE LOAD
---------------------------------------------------
PROCEDURE LOAD(x_errbuf out NOCOPY varchar2,
               x_retcode out NOCOPY Varchar2,
               p_from_date in varchar2,
               p_to_date in varchar2,
               p_all_level in varchar2) IS

-- ---------------------------------------------------------
-- Define local variables
-- ---------------------------------------------------------
   l_from_date          date;
   l_to_date            date;

   l_global_param_list dbms_sql.varchar2_table;

begin

   --l_from_date := trunc(to_date(p_from_date,'YYYY/MM/DD HH24:MI:SS'),'YYYY');
   --l_to_date := last_day(add_months(trunc(to_date(p_to_date, 'YYYY/MM/DD HH24:MI:SS'),'YYYY'),11));

   l_from_date := trunc(to_date(p_from_date,'YYYY/MM/DD HH24:MI:SS'));
   l_to_date := trunc(to_date(p_to_date, 'YYYY/MM/DD HH24:MI:SS'));
   g_all_level := nvl(p_all_level,'Y');
   if g_debug_flag = 'Y' then
 	  OZF_TP_UTIL_PVT.put_line('Data loads from '||l_from_date||' to '||l_to_date);
   end if;

    ----------------------------------------------------------
    -- Calling ozf common parameters api to do common set ups
    -- If it returns false, then program should error out
    ----------------------------------------------------------
    g_phase := 'Call ozf common parameters api to do common set ups';
    l_global_param_list(1) := 'OZF_TP_GLOBAL_START_DATE';


    IF (NOT ozf_common_parameters_pvt.check_global_parameters(l_global_param_list)) THEN
       if g_debug_flag = 'Y' then
          OZF_TP_UTIL_PVT.put_line('Global Start Date has not been set up. ' ||
                                'Program will exit with error status.');
       end if;
       x_retcode := 1;
       raise G_OZF_PARAMETER_NOT_SETUP;
    END IF;


   g_phase := 'Retrieve the ozf common parameters';
   INIT;

   g_phase := 'Load Day Level';
   if g_debug_flag = 'Y' then
   	OZF_TP_UTIL_PVT.start_timer;
   end if;
  --*** LOAD_DAY(l_from_date, l_to_date); -- full refresh
   LOAD_DAY_INC(l_from_date, l_to_date); -- incremental refresh
   if g_debug_flag = 'Y' then
   	OZF_TP_UTIL_PVT.stop_timer;
   	OZF_TP_UTIL_PVT.print_timer('Process Time');
   	OZF_TP_UTIL_PVT.put_line(' ');
   end if;

  if (g_all_level = 'Y') then
   g_phase := 'Load Week Level';
   if g_debug_flag = 'Y' then
   	OZF_TP_UTIL_PVT.start_timer;
   end if;
   LOAD_WEEK(l_from_date, l_to_date);
   if g_debug_flag = 'Y' then
   	OZF_TP_UTIL_PVT.stop_timer;
   	OZF_TP_UTIL_PVT.print_timer('Process Time');
   	OZF_TP_UTIL_PVT.put_line(' ');
   end if;

   g_phase := 'Load Enterprise Period Level';
   if g_debug_flag = 'Y' then
   	OZF_TP_UTIL_PVT.start_timer;
   end if;
   LOAD_ENT_PERIOD(l_from_date, l_to_date);
   if g_debug_flag = 'Y' then
   	OZF_TP_UTIL_PVT.stop_timer;
   	OZF_TP_UTIL_PVT.print_timer('Process Time');
   	OZF_TP_UTIL_PVT.put_line(' ');
   end if;

   g_phase := 'Load Enterprise Quarter Level';
   if g_debug_flag = 'Y' then
   	OZF_TP_UTIL_PVT.start_timer;
   end if;
   LOAD_ENT_QUARTER(l_from_date, l_to_date);
   if g_debug_flag = 'Y' then
   	OZF_TP_UTIL_PVT.stop_timer;
  	 OZF_TP_UTIL_PVT.print_timer('Process Time');
  	 OZF_TP_UTIL_PVT.put_line(' ');
   end if;

   g_phase := 'Load Enterprise Year Level';
   if g_debug_flag = 'Y' then
  	 OZF_TP_UTIL_PVT.start_timer;
   end if;
   LOAD_ENT_YEAR(l_from_date, l_to_date);
   if g_debug_flag = 'Y' then
   OZF_TP_UTIL_PVT.stop_timer;
   OZF_TP_UTIL_PVT.print_timer('Process Time');
   OZF_TP_UTIL_PVT.put_line(' ');
   end if;

   g_phase := 'Load Reporting Structure Table';
   if g_debug_flag = 'Y' then
  	 OZF_TP_UTIL_PVT.start_timer;
   end if;
   LOAD_TIME_RPT_STRUCT(l_from_date, l_to_date);
   if g_debug_flag = 'Y' then
 	  OZF_TP_UTIL_PVT.stop_timer;
 	  OZF_TP_UTIL_PVT.print_timer('Process Time');
 	  OZF_TP_UTIL_PVT.put_line(' ');
   end if;


  else
   truncate_table('OZF_TIME_WEEK');
   truncate_table('OZF_TIME_ENT_PERIOD');
   truncate_table('OZF_TIME_ENT_QTR');
   truncate_table('OZF_TIME_ENT_YEAR');
   truncate_table('OZF_TIME_RPT_STRUCT');
   if g_debug_flag = 'Y' then
	   OZF_TP_UTIL_PVT.put_line(' ');
   end if;
  end if;


EXCEPTION

  WHEN G_OZF_PARAMETER_NOT_SETUP THEN
  if g_debug_flag = 'Y' then
    OZF_TP_UTIL_PVT.put_line(fnd_message.get_string('OZF', 'OZF_TP_INVALID_PARAM_TXT'));
  end if;
    x_retcode := -1;
  WHEN G_LOGIN_INFO_NOT_FOUND THEN
  if g_debug_flag = 'Y' then
    OZF_TP_UTIL_PVT.put_line('Can not get User ID and Login ID, program exit');
  end if;
    x_retcode := -1;
  WHEN G_ENT_CALENDAR_NOT_FOUND THEN
    rollback;
    if g_debug_flag = 'Y' then
     OZF_TP_UTIL_PVT.put_line(fnd_message.get_string('OZF', 'OZF_TP_ENT_CALENDAR_NOT_FOUND'));
    end if;
    x_retcode := -1;
  WHEN OTHERS THEN
    rollback;
    x_retcode := sqlcode;
    x_errbuf  := sqlerrm;
    if g_debug_flag = 'Y' then
    	OZF_TP_UTIL_PVT.put_line(x_retcode||' : '||x_errbuf);
   	 OZF_TP_UTIL_PVT.put_line('
-------------------------------------------
Error occured in Procedure: LOAD
Phase: ' || g_phase);
    end if;
end LOAD;

---------------------------------------------------
-- PUBLIC PROCEDURE LOAD_TIME_RPT_STRUCT
---------------------------------------------------
PROCEDURE LOAD_TIME_RPT_STRUCT(p_from_date in date, p_to_date in date) IS

-- ---------------------------------------------------------
-- Define local variables
-- ---------------------------------------------------------
   l_from_date         date;
   l_to_date           date;
   l_day               date;
   l_week_start_date   date;
   l_ptd_to_date       date;
   l_period_start_date date;
   l_row               number;

--* We should do a full refresh for OZF_TIME_RPT_STRUCT
   cursor c1 is
     select report_date, ent_period_start_date, ent_qtr_start_date,
            ent_year_start_date, week_start_date
     from   OZF_TIME_DAY;
--*this would be incorrect:   where report_date between l_from_date and l_to_date

begin

   truncate_table('OZF_TIME_RPT_STRUCT');

   l_row       := 0;
   l_from_date := trunc(nvl(p_from_date,trunc(add_months(sysdate,-24),'YYYY')));
   l_to_date   := trunc(nvl(p_to_date,trunc(sysdate,'YYYY')));

   FOR c1_rec IN c1 LOOP
     insert into OZF_TIME_RPT_STRUCT
     (calendar_id,
      calendar_type,
      report_date,
      time_id,
      period_type_id,
      record_type_id,
      creation_date,
      last_update_date,
      last_updated_by,
      created_by,
      last_update_login)
     values
     (-1,
      'C',
      c1_rec.report_date,
      to_char(c1_rec.report_date,'j'),
      1,
      1,
      sysdate,
      sysdate,
      g_user_id,
      g_user_id,
      g_login_id);

     l_row := l_row+1;
     l_day:=c1_rec.report_date-1;
     l_week_start_date:=c1_rec.week_start_date;
     l_period_start_date:=c1_rec.ent_period_start_date;

     While l_day >= least(l_week_start_date,l_period_start_date) LOOP
       if l_day >= l_period_start_date then
         if l_day >= l_week_start_date then
           insert into OZF_TIME_RPT_STRUCT
           (calendar_id,
            calendar_type,
            report_date,
            time_id,
            period_type_id,
            record_type_id,
            creation_date,
            last_update_date,
            last_updated_by,
            created_by,
            last_update_login)
           values
           (-1,
            'C',
            c1_rec.report_date,
            to_char(l_day,'j'),
            1,
            2,
            sysdate,
            sysdate,
            g_user_id,
            g_user_id,
            g_login_id);

           l_row := l_row + sql%rowcount;

         else
           select nvl(min(start_date),l_week_start_date) into l_ptd_to_date from OZF_TIME_WEEK
           where start_date >= l_period_start_date
           and start_date < l_week_start_date;

           if l_day < l_ptd_to_date then
             insert into OZF_TIME_RPT_STRUCT
             (calendar_id,
              calendar_type,
              report_date,
              time_id,
              period_type_id,
              record_type_id,
              creation_date,
              last_update_date,
              last_updated_by,
              created_by,
              last_update_login)
             values
             (-1,
              'C',
              c1_rec.report_date,
              to_char(l_day,'j'),
              1,
              4,
              sysdate,
              sysdate,
              g_user_id,
              g_user_id,
              g_login_id);

             l_row := l_row + sql%rowcount;

           end if;
         end if;
       else
         if l_day >= l_week_start_date then
           insert into OZF_TIME_RPT_STRUCT
           (calendar_id,
            calendar_type,
            report_date,
            time_id,
            period_type_id,
            record_type_id,
            creation_date,
            last_update_date,
            last_updated_by,
            created_by,
            last_update_login)
           values
           (-1,
            'C',
            c1_rec.report_date,
            to_char(l_day,'j'),
            1,
            8,
            sysdate,
            sysdate,
            g_user_id,
            g_user_id,
            g_login_id);

           l_row := l_row + sql%rowcount;

         end if;
       end if;

       l_day:=l_day-1;

     END LOOP;

     commit;

     insert into OZF_TIME_RPT_STRUCT
     (calendar_id,
      calendar_type,
      report_date,
      time_id,
      period_type_id,
      record_type_id,
      creation_date,
      last_update_date,
      last_updated_by,
      created_by,
      last_update_login)
     select
      -1,
      'E',
      c1_rec.report_date,
      week_id,
      16,
      16,
      sysdate,
      sysdate,
      g_user_id,
      g_user_id,
      g_login_id
     from OZF_TIME_WEEK
     where start_date >= c1_rec.ent_period_start_date
     and end_date < c1_rec.week_start_date;

     l_row := l_row + sql%rowcount;
     commit;

     insert into OZF_TIME_RPT_STRUCT
     (calendar_id,
      calendar_type,
      report_date,
      time_id,
      period_type_id,
      record_type_id,
      creation_date,
      last_update_date,
      last_updated_by,
      created_by,
      last_update_login)
     select
      -1,
      'E',
      c1_rec.report_date,
      ent_period_id,
      32,
      32,
      sysdate,
      sysdate,
      g_user_id,
      g_user_id,
      g_login_id
     from OZF_TIME_ENT_PERIOD
     where start_date >= c1_rec.ent_qtr_start_date
     and start_date <= c1_rec.ent_period_start_date
     and end_date < c1_rec.report_date
     union all
     select
      -1,
      'E',
      c1_rec.report_date,
      ent_period_id,
      32,
      256,
      --case when end_date >= c1_rec.report_date then 256 else 32 end,
      sysdate,
      sysdate,
      g_user_id,
      g_user_id,
      g_login_id
     from OZF_TIME_ENT_PERIOD
     where start_date >= c1_rec.ent_qtr_start_date
     and start_date <= c1_rec.ent_period_start_date
     and end_date >= c1_rec.report_date;

     l_row := l_row + sql%rowcount;
     commit;

     insert into OZF_TIME_RPT_STRUCT
     (calendar_id,
      calendar_type,
      report_date,
      time_id,
      period_type_id,
      record_type_id,
      creation_date,
      last_update_date,
      last_updated_by,
      created_by,
      last_update_login)
     select
      -1,
      'E',
      c1_rec.report_date,
      ent_qtr_id,
      64,
      64,
      sysdate,
      sysdate,
      g_user_id,
      g_user_id,
      g_login_id
     from OZF_TIME_ENT_QTR
     where start_date >= c1_rec.ent_year_start_date
     and start_date <= c1_rec.ent_qtr_start_date
     and end_date < c1_rec.report_date
     union all
     select
      -1,
      'E',
      c1_rec.report_date,
      ent_qtr_id,
      64,
      512,
      --case when end_date >= c1_rec.report_date then 512 else 64 end,
      sysdate,
      sysdate,
      g_user_id,
      g_user_id,
      g_login_id
     from OZF_TIME_ENT_QTR
     where start_date >= c1_rec.ent_year_start_date
     and start_date <= c1_rec.ent_qtr_start_date
     and end_date >= c1_rec.report_date;

     l_row := l_row + sql%rowcount;
     commit;

     insert into OZF_TIME_RPT_STRUCT
     (calendar_id,
      calendar_type,
      report_date,
      time_id,
      period_type_id,
      record_type_id,
      creation_date,
      last_update_date,
      last_updated_by,
      created_by,
      last_update_login)
     select
      -1,
      'E',
      c1_rec.report_date,
      ent_year_id,
      128,
      128,
      sysdate,
      sysdate,
      g_user_id,
      g_user_id,
      g_login_id
     from OZF_TIME_ENT_YEAR
     where c1_rec.report_date between start_date and end_date;

     l_row := l_row + sql%rowcount;
     commit;

-- All prior years (report_type: 1024), for ITD
     insert into OZF_TIME_RPT_STRUCT
     (calendar_id,
      calendar_type,
      report_date,
      time_id,
      period_type_id,
      record_type_id,
      creation_date,
      last_update_date,
      last_updated_by,
      created_by,
      last_update_login)
     select
      -1,
      'E',
      c1_rec.report_date,
      ent_year_id,
      128,
      1024,
      sysdate,
      sysdate,
      g_user_id,
      g_user_id,
      g_login_id
     from OZF_TIME_ENT_YEAR
     where end_date  >=  g_global_start_date      -- should we use start_date?
       and end_date  <   c1_rec.report_date;

     l_row := l_row + sql%rowcount;
     commit;

   END LOOP; -- c1_rec

if g_debug_flag = 'Y' then
   OZF_TP_UTIL_PVT.put_line(to_char(l_row)||' records has been populated to the Reporting Structure table');
end if;

end LOAD_TIME_RPT_STRUCT;

---------------------------------------------------
-- PUBLIC FUNCTION DEFAULT_LOAD_FROM_DATE
-- this function is used to return the default load
-- from date to the concurrent program parameter
---------------------------------------------------
FUNCTION DEFAULT_LOAD_FROM_DATE(p_load_mode in varchar2)
return varchar2
is

   l_return_date date;

begin
   if p_load_mode = 'INCRE' then

      select greatest(NVL(max(end_date)+1,ozf_common_parameters_pvt.get_global_start_date),
                      ozf_common_parameters_pvt.get_global_start_date)
       into l_return_date
      from ozf_time_day;

   else

      select least(nvl(min(start_date),ozf_common_parameters_pvt.get_global_start_date) ,
                   ozf_common_parameters_pvt.get_global_start_date)
             into l_return_date
      from ozf_time_day;
   end if;

   return fnd_date.date_to_displaydt(l_return_date);

end DEFAULT_LOAD_FROM_DATE;

---------------------------------------------------
-- PUBLIC FUNCTION DEFAULT_LOAD_TO_DATE
-- this function is used to return the default load
-- to date to the concurrent program parameter
---------------------------------------------------
FUNCTION DEFAULT_LOAD_TO_DATE
return varchar2
is

   l_return_date date;
   l_period_set_name varchar2(15) :=  ozf_common_parameters_pvt.get_period_set_name;
   l_period_type varchar2(15) :=  ozf_common_parameters_pvt.get_period_type;

begin

   select max(end_date)
   into l_return_date
   from gl_periods
   where adjustment_period_flag = 'N'
   and period_set_name = l_period_set_name
   and period_type = l_period_type;

   return fnd_date.date_to_displaydt(l_return_date);

end DEFAULT_LOAD_TO_DATE;


END OZF_TIME_PVT;

/

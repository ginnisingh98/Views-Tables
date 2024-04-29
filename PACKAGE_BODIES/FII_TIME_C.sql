--------------------------------------------------------
--  DDL for Package Body FII_TIME_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FII_TIME_C" AS
/*$Header: FIICMT1B.pls 120.49 2007/03/01 07:22:08 arcdixit ship $*/

g_schema          varchar2(30);
g_period_set_name varchar2(15) := null;
g_period_type     varchar2(15) := null;
g_week_start_day  varchar2(30) := null;
g_phase           varchar2(500);
g_week_offset     number;
g_user_id         number := FND_GLOBAL.User_Id;
g_login_id        number := FND_GLOBAL.Login_Id;
g_all_level       varchar2(1);
g_date_not_defined	date;
g_global_start_date  date;
g_debug_flag         VARCHAR2(1) := NVL(FND_PROFILE.value('FII_DEBUG_MODE'), 'N');
--Adding for sba content
g_load_mode       varchar2(10);

-- Bug 5624487
g_unassigned_day date := to_date('12/31/4712', 'MM/DD/YYYY');
g_una_ent_period_year number := to_number(to_char(g_unassigned_day,'yyyy'));
g_una_ent_quarter_num number := 1;
g_una_ent_period_num  number := 1;

G_TABLE_NOT_EXIST EXCEPTION;
G_LOGIN_INFO_NOT_FOUND EXCEPTION;
G_BIS_PARAMETER_NOT_SETUP EXCEPTION;
G_ENT_CALENDAR_NOT_FOUND EXCEPTION;
G_YEAR_NOT_DEFINED EXCEPTION;

PRAGMA EXCEPTION_INIT(G_TABLE_NOT_EXIST, -942);

g_day_row_cnt    number := 0;

---------------------------------------------------
-- Forward declarations of provide procedures
---------------------------------------------------
PROCEDURE LOAD_TIME_RPT_STRUCT;

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

----------------------------------------------------------------
-- PRIVATE function check_validated
--   This function check that the FII_TIME_* tables have
--   been validated.
----------------------------------------------------------------
FUNCTION CHECK_VALIDATED
return varchar2
is
   l_att_tbl DBMS_SQL.VARCHAR2_TABLE;
   l_att_cnt number;
   l_validated varchar2(1) := 'N';

begin

   BIS_COLLECTION_UTILITIES.GET_LAST_USER_ATTRIBUTES
   ( P_OBJECT_NAME     => 'FII_DBI_TIME_M'
   , P_ATTRIBUTE_TABLE => l_att_tbl
   , P_COUNT           => l_att_cnt
   );

   if l_att_cnt > 0 then
      if l_att_tbl(1) = 'Y' then
         l_validated := 'Y';
      end if;
   end if;

   return l_validated;

end CHECK_VALIDATED;

---------------------------------------------------
-- PRIVATE FUNCTION period_updated
---------------------------------------------------
FUNCTION period_updated(p_from_date in date, p_to_date in date) return varchar2 is

  l_updated varchar2(1);

begin

  insert into FII_TIME_GL_PERIODS
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
  select to_number(period_year||quarter_num||decode(length(period_num),1,'0'||period_num, period_num)),
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
  and    start_date <= p_to_date
  and    end_date >= p_from_date;

 -- Bug 4995016. Sequence should not be used for diffing after fix of bug 3961336.
 -- Bug 4966868: Changed not to count rows
  BEGIN
    -- Bug 5624487
    select 'Y'
    into l_updated
    from
    (select ent_period_id,
            ent_qtr_id,
            ent_year_id,
            --sequence,
            name,
            start_date,
            end_date
     from fii_time_ent_period
     where end_date < g_unassigned_day
     minus
     select ent_period_id,
            ent_qtr_id,
            ent_year_id,
            --sequence,
            name,
            start_date,
            end_date
     from FII_TIME_GL_PERIODS)
     where rownum = 1;
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       l_updated := 'N';
   END;

  return l_updated;

end period_updated;

---------------------------------------------------
-- PRIVATE PROCEDURE GATHER_TABLE_STATS
---------------------------------------------------
procedure gather_table_stats
( p_table_name in varchar2
, p_schema_name in varchar := g_schema
) is

begin

  fnd_stats.gather_table_stats( ownname => p_schema_name
                              , tabname => p_table_name
                              );

end gather_table_stats;

---------------------------------------------------
-- PRIVATE PROCEDURE TRUNCATE_TABLE
---------------------------------------------------
procedure truncate_table (p_table_name in varchar2) is
   l_stmt varchar2(400);

begin

   l_stmt := 'truncate table '||g_schema||'.'||p_table_name;
   if g_debug_flag = 'Y' then
      fii_util.put_line('TRUNCATE_TABLE : '||l_stmt);
   end if;
   execute immediate l_stmt;

exception
   WHEN G_TABLE_NOT_EXIST THEN
      null;      -- Oracle 942, table does not exist, no actions
   WHEN OTHERS THEN
      raise;

end truncate_table;

---------------------------------------------------
-- PRIVATE PROCEDURE INIT
---------------------------------------------------
PROCEDURE INIT IS
   l_status    VARCHAR2(30);
   l_industry  VARCHAR2(30);
   l_period_type  VARCHAR2(15);

begin

   -- ----------------------
   -- Initialize the global variables
   -- ----------------------


   IF(FND_INSTALLATION.GET_APP_INFO('FII', l_status, l_industry,
          g_schema)) THEN
      NULL;
   END IF;

   --g_user_id := FND_GLOBAL.User_Id;
   --g_login_id := FND_GLOBAL.Login_Id;

   IF (g_user_id IS NULL OR g_login_id IS NULL) THEN
      RAISE G_LOGIN_INFO_NOT_FOUND;
   END IF;

   if (g_all_level = 'Y') then
      g_period_set_name := bis_common_parameters.get_period_set_name;
      g_period_type := bis_common_parameters.get_period_type;
      if g_debug_flag = 'Y' then
         fii_util.put_line('INIT : '||'Enterprise Calendar = '||g_period_set_name||' ('||g_period_type||')');
      end if;
      g_week_start_day := bis_common_parameters.get_start_day_of_week_id;
      if (g_period_set_name is null or g_period_type is null or g_week_start_day is null) then
         raise G_BIS_PARAMETER_NOT_SETUP;
      end if;

      if g_debug_flag = 'Y' then
         fii_util.put_line('INIT : '||'Week Start Day = '||g_week_start_day);
      end if;
      g_week_offset := get_week_offset(g_week_start_day);
      if g_debug_flag = 'Y' then
         fii_util.put_line('INIT : '||'Week offset = '||g_week_offset);
         fii_util.put_line(' ');
      end if;

      g_global_start_date := bis_common_parameters.get_GLOBAL_START_DATE;
      if (g_global_start_date is null) then
         raise G_BIS_PARAMETER_NOT_SETUP;
      end if;
      if g_debug_flag = 'Y' then
         fii_util.put_line('INIT : '||'Global Start Date = ' ||
                           fnd_date.date_to_displaydate(g_global_start_date));
         fii_util.put_line(' ');
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
   l_end_date           gl_periods.end_date%TYPE;
   l_quarter_start_date gl_periods.quarter_start_date%TYPE;
   l_quarter_end_date   gl_periods.quarter_start_date%TYPE;
   l_year_start_date    gl_periods.year_start_date%TYPE;
   l_year_end_date      gl_periods.year_start_date%TYPE;
   l_count              number;

   cursor ent_period_cur (day date) is
     select period_year, quarter_num, period_num, start_date, end_date, quarter_start_date, year_start_date
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
   -- Bug 5624487
   -- while l_day <= l_to_date loop
   if l_day > l_to_date then
       l_day := g_unassigned_day;
   end if;
   while l_day <= l_to_date or l_day = g_unassigned_day loop

      -- Bug 5624487
      -- if (g_all_level='Y') then
      if (g_all_level='Y' and l_day <> g_unassigned_day) then

         open ent_period_cur(l_day);
         fetch ent_period_cur into l_period_year, l_quarter_num, l_period_num,
                                   l_start_date, l_end_date, l_quarter_start_date, l_year_start_date;
         if (ent_period_cur%notfound) then
	    g_date_not_defined := l_day;

            raise G_ENT_CALENDAR_NOT_FOUND;
         else
            l_week_num := get_week_num(l_day,g_week_offset);
            l_p445_num := get_period_num(l_week_num);
            l_year_num := to_char(l_day-g_week_offset,'iyyy');

            select max(end_date) into l_quarter_end_date
            from gl_periods
            where period_set_name=g_period_set_name
            and period_type=g_period_type
            and adjustment_period_flag='N'
            and period_year=l_period_year
            and quarter_num=l_quarter_num;

            select max(end_date) into l_year_end_date
            from gl_periods
            where period_set_name=g_period_set_name
            and period_type=g_period_type
            and adjustment_period_flag='N'
            and period_year=l_period_year;
         end if;
      else
         l_period_year := -1;
         l_quarter_num := null;
         l_period_num := null;
         l_start_date := trunc(sysdate);
         l_end_date := trunc(sysdate);
         l_quarter_start_date := trunc(sysdate);
         l_quarter_end_date := trunc(sysdate);
         l_year_start_date := trunc(sysdate);
         l_year_end_date := trunc(sysdate);
         l_week_num := null;
         l_p445_num := null;
         l_year_num := -1;
      end if;

-- first check if the current day is loaded
      -- Bug 4966868: Changed not to count rows
      BEGIN
        select 1 into l_count
        from   fii_time_day
        where  report_date = trunc(l_day)
        and rownum = 1;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          l_count := 0;
      END;

-- do an incremental update/insert
      if l_count = 0 then  -- new record, insert

         insert into fii_time_day
         (report_date,
          report_date_julian,
          start_date,
          end_date,
          month_id,
          ent_period_id,
          ent_period_start_date,
          ent_period_end_date,
          ent_qtr_id,
          ent_qtr_start_date,
          ent_qtr_end_date,
          ent_year_id,
          ent_year_start_date,
          ent_year_end_date,
          week_id,
          week_start_date,
          week_end_date,
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
                                     -- lpad(l_period_num,2,'0'),    bug 3370185
          l_start_date,
          l_end_date,
          l_period_year||l_quarter_num,
          l_quarter_start_date,
          l_quarter_end_date,
          l_period_year,
          l_year_start_date,
          l_year_end_date,
          l_year_num||lpad(l_p445_num,2,'0')||lpad(l_week_num,2,'0'),
          nvl(trunc(l_day-g_week_offset,'iw')+g_week_offset,trunc(sysdate)),
          nvl(trunc(l_day-g_week_offset,'iw')+g_week_offset,trunc(sysdate))+6, --week end date,
          sysdate,
          sysdate,
          g_user_id,
          g_user_id,
          g_login_id
         );

         l_day_row := l_day_row+1;

      else -- the day has been loaded, update those changed records only

         update fii_time_day
         set
            ent_period_id = l_period_year||l_quarter_num||decode(length(l_period_num),1,'0'||l_period_num, l_period_num),
                   -- lpad(l_period_num,2,'0'),  bug 3370185
            ent_period_start_date = l_start_date,
            ent_period_end_date = l_end_date,
            ent_qtr_id = l_period_year||l_quarter_num,
            ent_qtr_start_date = l_quarter_start_date,
            ent_qtr_end_date = l_quarter_end_date,
            ent_year_id = l_period_year,
            ent_year_start_date = l_year_start_date,
            ent_year_end_date = l_year_end_date,
            week_id = l_year_num||lpad(l_p445_num,2,'0')||lpad(l_week_num,2,'0'),
            week_start_date = nvl(trunc(l_day-g_week_offset,'iw')+g_week_offset,trunc(sysdate)),
            week_end_date = nvl(trunc(l_day-g_week_offset,'iw')+g_week_offset,trunc(sysdate))+6,
            last_update_date = sysdate,
            last_updated_by = g_user_id,
            last_update_login = g_login_id
         where report_date = trunc (l_day)
         and   (ent_period_id <> l_period_year||l_quarter_num||decode(length(l_period_num),1,'0'||l_period_num, l_period_num)
                    -- lpad(l_period_num,2,'0')   bug 3370185
                  or
                ent_period_start_date <> l_start_date or
                ent_period_end_date <> l_end_date or
                NVL(ent_qtr_start_date,  to_date('01/01/1000', 'DD/MM/YYYY')) <>
                          NVL(l_quarter_start_date, to_date('01/01/1000', 'DD/MM/YYYY')) or
                NVL(ent_qtr_end_date,  to_date('01/01/1000', 'DD/MM/YYYY')) <>
                          NVL(l_quarter_end_date, to_date('01/01/1000', 'DD/MM/YYYY')) or
                NVL(ent_year_start_date, to_date('01/01/1000', 'DD/MM/YYYY')) <>
                          NVL(l_year_start_date, to_date('01/01/1000', 'DD/MM/YYYY')) or
                NVL(ent_year_end_date, to_date('01/01/1000', 'DD/MM/YYYY')) <>
                          NVL(l_year_end_date, to_date('01/01/1000', 'DD/MM/YYYY')));

         l_day_row := l_day_row + sql%rowcount;

      end if;   --for: if l_count = 0

      -- Bug 5624487
      -- if (g_all_level='Y') then
      if (g_all_level='Y' and l_day <> g_unassigned_day) then

         close ent_period_cur;
      end if;

      l_period_year := null;
      l_quarter_num := null;
      l_period_num := null;
      l_start_date := null;
      l_end_date := null;
      l_quarter_start_date := null;
      l_quarter_end_date := null;
      l_year_start_date := null;
      l_year_end_date := null;

-- move to the next day
      -- Bug 5624487
      -- l_day := l_day+1;
      exit when l_day = g_unassigned_day;
      if l_day < l_to_date then
          l_day := l_day + 1;
      else
          l_day := g_unassigned_day;
      end if;

   end loop;

   commit;

   if g_debug_flag = 'Y' then
      fii_util.put_line('LOAD_DAY_INC : '||to_char(l_day_row)||' records has been populated or updated to Day Level');
   end if;

   g_day_row_cnt := l_day_row;

end LOAD_DAY_INC;

---------------------------------------------------
-- PRIVATE PROCEDURE LOAD_DAY
-- this procedure is no longer used
---------------------------------------------------
/*
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

   truncate_table('FII_TIME_DAY');

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
         insert into fii_time_day
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
                   -- lpad(l_period_num,2,'0'),   bug 3370185
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
      fii_util.put_line('LOAD_DAY : '||to_char(l_day_row)||' records has been populated to Day Level');
   end if;

end LOAD_DAY;
*/

---------------------------------------------------
-- PRIVATE PROCEDURE LOAD_MONTH
---------------------------------------------------
PROCEDURE LOAD_MONTH(p_from_date in date, p_to_date in date) IS

   -- ---------------------------------------------------------
   -- Define local variables
   -- ---------------------------------------------------------
   l_from_date          date;
   l_to_date            date;
   l_month              date;
   l_month_end          date;
   l_month_row          number;
   l_min_date           date;

begin

   -- ---------------------------------------------------------
   -- Variable initialization
   -- ---------------------------------------------------------
   l_from_date   := p_from_date;
   l_to_date     := p_to_date;
   l_month       := trunc(l_from_date,'mm');
   l_month_end   := last_day(l_month);
   l_month_row   := 0;

   IF g_load_mode = 'INIT' THEN
   --If it is initial load the first year should not be populated for the prior_year_month_id column
   --Used a decode for the same
    l_min_date := p_from_date;
   ELSE
    -- Incremental run
    select min(start_date) into l_min_date from fii_time_month;
   END  IF;

   -- Bug 5624487
   -- delete from FII_TIME_MONTH where start_date <= l_to_date and end_date >= l_from_date;
   delete from FII_TIME_MONTH
   where start_date <= l_to_date and end_date >= l_from_date
      or end_date >= g_unassigned_day;

   -- ----------------------
   -- Populate Month Level
   -- ----------------------

    -- Bug 5624487
    -- while l_month <= l_to_date loop
    if l_month > l_to_date then
        l_month := trunc(g_unassigned_day,'mm');
        l_month_end := g_unassigned_day;
    end if;
    while l_month <= l_to_date or l_month_end = g_unassigned_day loop

      -- Bug 5624487
      insert into fii_time_month
      (month_id,
       quarter_id,
       name,
       start_date,
       end_date,
       prior_year_month_id,
       creation_date,
       last_update_date,
       last_updated_by,
       created_by,
       last_update_login)
      values
      (
       to_number(to_char(l_month,'yyyyqmm')),
       to_number(to_char(l_month,'yyyyq')),
    decode(l_month_end, g_unassigned_day, null,
       to_char(l_month,'Mon YYYY')
          ),
       l_month,
       l_month_end,
    decode(l_month_end, g_unassigned_day, null,
       decode(to_char (l_min_date, 'YYYY'), to_char (l_month, 'YYYY'), NULL, to_number(to_char(add_months(l_month, -12),'yyyyqmm')))
          ),
       sysdate,
       sysdate,
       g_user_id,
       g_user_id,
       g_login_id
      );

      -- Bug 5624487
      /*
      l_month := l_month_end+1;
      l_month_end := last_day(l_month);
      l_month_row := l_month_row+1;
      */
      l_month_row := l_month_row+1;
      exit when l_month_end = g_unassigned_day;
      l_month := l_month_end+1;
      l_month_end := last_day(l_month);
      if l_month > l_to_date then
          l_month := trunc(g_unassigned_day,'mm');
          l_month_end := g_unassigned_day;
      end if;

     end loop;
   commit;

   if g_debug_Flag = 'Y' then
      fii_util.put_line('LOAD_MONTH : '||to_char(l_month_row)||' records has been populated to Month Level');
   end if;

end LOAD_MONTH;

---------------------------------------------------
-- PRIVATE PROCEDURE LOAD_QUARTER
---------------------------------------------------
PROCEDURE LOAD_QUARTER(p_from_date in date, p_to_date in date) IS

   -- ---------------------------------------------------------
   -- Define local variables
   -- ---------------------------------------------------------
   l_from_date          date;
   l_to_date            date;
   l_qtr                date;
   l_qtr_end            date;
   l_qtr_row            number;
   l_min_date           date;

begin

   -- ---------------------------------------------------------
   -- Variable initialization
   -- ---------------------------------------------------------
   l_from_date   := p_from_date;
   l_to_date     := p_to_date;
   l_qtr         := trunc(l_from_date,'q');
   l_qtr_end     := add_months(last_day(l_qtr),2);
   l_qtr_row     := 0;

   IF g_load_mode = 'INIT' THEN
   --If it is initial load the first year should not be populated for the prior_year_month_id column
   --Used a decode for the same
    l_min_date := p_from_date;
   ELSE
    -- Incremental run
    select min(start_date) into l_min_date from fii_time_qtr;
   END  IF;

   -- Bug 5624487
   -- delete from FII_TIME_QTR where start_date <= l_to_date and end_date >= l_from_date;
   delete from FII_TIME_QTR
   where start_date <= l_to_date and end_date >= l_from_date
      or end_date >= g_unassigned_day;

   -- ----------------------
   -- Populate Quarter Level
   -- ----------------------
    -- Bug 5624487
    -- while l_qtr <= l_to_date loop
    if l_qtr > l_to_date then
        l_qtr := trunc(g_unassigned_day,'q');
        l_qtr_end := g_unassigned_day;
    end if;
    while l_qtr <= l_to_date or l_qtr_end = g_unassigned_day loop

      -- Bug 5624487
      insert into fii_time_qtr
      (quarter_id,
       year_id,
       name,
       start_date,
       end_date,
       prior_year_quarter_id,
       creation_date,
       last_update_date,
       last_updated_by,
       created_by,
       last_update_login)
      values(
       to_number(to_char(l_qtr,'yyyyq')),
       to_number(to_char(l_qtr,'yyyy')),
    decode(l_qtr_end, g_unassigned_day, null,
       to_char(l_qtr,'q,yyyy')
          ),
       l_qtr,
       l_qtr_end,
    decode(l_qtr_end, g_unassigned_day, null,
       decode(to_char (l_min_date, 'YYYY'), to_char (l_qtr, 'YYYY'), NULL, to_number(to_char(add_months(l_qtr, -12),'yyyyq')))
          ),
       sysdate,
       sysdate,
       g_user_id,
       g_user_id,
       g_login_id
      );

      -- Bug 5624487
      /*
      l_qtr := l_qtr_end+1;
      l_qtr_end := add_months(last_day(l_qtr),2);
      l_qtr_row := l_qtr_row+1;
      */
      l_qtr_row := l_qtr_row+1;
      exit when l_qtr_end = g_unassigned_day;
      l_qtr := l_qtr_end+1;
      l_qtr_end := add_months(last_day(l_qtr),2);
      if l_qtr > l_to_date then
          l_qtr := trunc(g_unassigned_day,'q');
          l_qtr_end := g_unassigned_day;
      end if;

     end loop;
   commit;

   if g_debug_flag = 'Y' then
      fii_util.put_line('LOAD_QUARTER : '||to_char(l_qtr_row)||' records has been populated to Quarter Level');
   end if;

end LOAD_QUARTER;

---------------------------------------------------
-- PRIVATE PROCEDURE LOAD_YEAR
---------------------------------------------------
PROCEDURE LOAD_YEAR(p_from_date in date, p_to_date in date) IS

   -- ---------------------------------------------------------
   -- Define local variables
   -- ---------------------------------------------------------
   l_from_date          date;
   l_to_date            date;
   l_year               date;
   l_year_end           date;
   l_year_row           number;
   l_min_date           date;

begin

   -- ---------------------------------------------------------
   -- Variable initialization
   -- ---------------------------------------------------------
   l_from_date   := p_from_date;
   l_to_date     := p_to_date;
   l_year        := trunc(l_from_date,'yyyy');
   l_year_end    := add_months(last_day(l_year),11);
   l_year_row    := 0;

   IF g_load_mode = 'INIT' THEN
   --If it is initial load the first year should not be populated for the prior_year_month_id column
   --Used a decode for the same
    l_min_date := p_from_date;
   ELSE
    -- Incremental run
    select min(start_date) into l_min_date from fii_time_year;
   END  IF;

   -- Bug 5624487
   -- delete from FII_TIME_YEAR where start_date <= l_to_date and end_date >= l_from_date;
   delete from FII_TIME_YEAR
   where start_date <= l_to_date and end_date >= l_from_date
      or end_date >= g_unassigned_day;

   -- ----------------------
   -- Populate Year Level
   -- ----------------------
    -- Bug 5624487
    -- while l_year <= l_to_date loop
    if l_year > l_to_date then
        l_year := trunc(g_unassigned_day,'yyyy');
        l_year_end := g_unassigned_day;
    end if;
    while l_year <= l_to_date or l_year_end = g_unassigned_day loop

      -- Bug 5624487
      insert into fii_time_year
      (year_id,
       name,
       start_date,
       end_date,
       prior_year_id,
       creation_date,
       last_update_date,
       last_updated_by,
       created_by,
       last_update_login)
      values(
       to_number(to_char(l_year,'yyyy')),
    decode(l_year_end, g_unassigned_day, null,
       to_number(to_char(l_year,'yyyy'))
          ),
       l_year,
       l_year_end,
    decode(l_year_end, g_unassigned_day, null,
       decode(to_char (l_min_date, 'YYYY'), to_char (l_year, 'YYYY'), NULL, to_number(to_char(add_months(l_year, -12),'yyyy')))
          ),
       sysdate,
       sysdate,
       g_user_id,
       g_user_id,
       g_login_id
      );

      -- Bug 5624487
      /*
      l_year := l_year_end+1;
      l_year_end := add_months(last_day(l_year),11);
      l_year_row := l_year_row+1;
      */
      l_year_row := l_year_row+1;
      exit when l_year_end = g_unassigned_day;
      l_year := l_year_end+1;
      l_year_end := add_months(last_day(l_year),11);
      if l_year > l_to_date then
          l_year := trunc(g_unassigned_day,'yyyy');
          l_year_end := g_unassigned_day;
      end if;

    end loop;
   commit;

   if g_debug_flag = 'Y' then
      fii_util.put_line('LOAD_YEAR : '||to_char(l_year_row)||' records has been populated to Year Level');
   end if;

end LOAD_YEAR;

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

   -- Bug 5624487
   if l_week > l_to_date then
       l_week := trunc(g_unassigned_day-g_week_offset,'iw')+g_week_offset;
       l_week_end := g_unassigned_day;
   end if;

   l_week_num    := get_week_num(l_week,g_week_offset);
   l_period_num  := get_period_num(l_week_num);
   l_year_num    := to_char(l_week-g_week_offset,'iyyy');
   l_week_row    := 0;

   -- Bug 5624487
   -- delete from FII_TIME_WEEK where start_date <= l_to_date and end_date >= l_from_date;
   delete from FII_TIME_WEEK
   where start_date <= l_to_date and end_date >= l_from_date
      or end_date >= g_unassigned_day;

   -- ----------------------
   -- Populate Week Level
   -- ----------------------

   -- Bug 5624487
   -- while l_week <= l_to_date loop
   while l_week <= l_to_date or l_week_end = g_unassigned_day loop

      -- Bug 5624487
      insert into fii_time_week
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
    decode(l_week_end, g_unassigned_day, null,
       to_char(l_week_end,'dd-Mon-rr')
          ),
       l_week,
       l_week_end,
       sysdate,
       sysdate,
       g_user_id,
       g_user_id,
       g_login_id
      );

      -- Bug 5624487
      /*
      l_week := l_week_end+1;
      l_week_end := l_week+6;
      l_week_num := get_week_num(l_week,g_week_offset);
      l_period_num := get_period_num(l_week_num);
      l_year_num := to_char(l_week-g_week_offset,'iyyy');
      l_week_row := l_week_row+1;
      */
      l_week_row := l_week_row+1;
      exit when l_week_end = g_unassigned_day;
      l_week := l_week_end+1;
      l_week_end := l_week+6;
      if l_week > l_to_date then
          l_week := trunc(g_unassigned_day-g_week_offset,'iw')+g_week_offset;
          l_week_end := g_unassigned_day;
      end if;
      l_week_num := get_week_num(l_week,g_week_offset);
      l_period_num := get_period_num(l_week_num);
      l_year_num := to_char(l_week-g_week_offset,'iyyy');

   end loop;

   commit;
   if g_debug_flag = 'Y' then
     fii_util.put_line('LOAD_WEEK : '||to_char(l_week_row)||' records has been populated to Week Level');
   end if;

   -- Bug 5624487
   update fii_time_day
   set week_id = l_year_num||lpad(l_period_num,2,'0')||lpad(l_week_num,2,'0'),
       week_start_date   = l_week,
       week_end_date     = l_week_end,
       last_update_date  = sysdate,
       last_updated_by   = g_user_id,
       last_update_login = g_login_id
   where report_date = g_unassigned_day;

   commit;

end LOAD_WEEK;

---------------------------------------------------
-- PRIVATE PROCEDURE LOAD_PERIOD_445
---------------------------------------------------
PROCEDURE LOAD_PERIOD_445(p_from_date in date, p_to_date in date) IS

   -- ---------------------------------------------------------
   -- Define local variables
   -- ---------------------------------------------------------
   l_from_date          date;
   l_to_date            date;
   l_period             date;
   l_period_end         date;
   l_period_num         number;
   l_year_num           number;
   l_period_row         number;

begin

   -- ---------------------------------------------------------
   -- Variable initialization
   -- ---------------------------------------------------------
   l_from_date   := p_from_date;
   l_to_date     := trunc(p_to_date-g_week_offset,'iw')+g_week_offset+6;
   l_period      := get_period_start(l_from_date);
   l_period_num  := get_period_num(get_week_num(l_period,g_week_offset));
   if l_period_num in (3,6,9,12) then
     l_period_end  := l_period+34;
     if l_period_num=12 then
       while get_period_num(get_week_num(l_period_end+7,g_week_offset)) = 12 loop
         l_period_end := l_period_end + 7;
       end loop;
     end if;
   else
     l_period_end  := l_period+27;
   end if;

   -- Bug 5624487
   if l_period > l_to_date then
       l_period := get_period_start(g_unassigned_day);
       l_period_end := g_unassigned_day;
       l_period_num := get_period_num(get_week_num(l_period,g_week_offset));
   end if;

   l_year_num    := to_char(l_period-g_week_offset,'iyyy');
   l_period_row  := 0;

   -- Bug 5624487
   -- delete from FII_TIME_P445 where start_date <= l_to_date and end_date >= l_from_date;
   delete from FII_TIME_P445
   where start_date <= l_to_date and end_date >= l_from_date
      or end_date >= g_unassigned_day;

   -- ----------------------
   -- Populate Period 445 Level
   -- ----------------------

   -- Bug 5624487
   -- while l_period <= l_to_date loop
   while l_period <= l_to_date or l_period_end = g_unassigned_day loop

      -- Bug 5624487
      insert into fii_time_p445
      (period445_id,
       year445_id,
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
       l_year_num||lpad(l_period_num,2,'0'),
       l_year_num,
       l_period_num,
    decode(l_period_end, g_unassigned_day, null,
       lpad(l_period_num,2,'0')||' '||l_year_num
          ),
       l_period,
       l_period_end,
       sysdate,
       sysdate,
       g_user_id,
       g_user_id,
       g_login_id
      );

      -- Bug 5624487
      /*
      l_period := l_period_end+1;
      l_period_num  := get_period_num(get_week_num(l_period,g_week_offset));

      if l_period_num in (3,6,9,12) then
         l_period_end := l_period+34;
         if l_period_num=12 then
            while get_period_num(get_week_num(l_period_end+7,g_week_offset)) = 12 loop
               l_period_end := l_period_end + 7;
            end loop;
         end if;
      else
         l_period_end := l_period+27;
      end if;

      l_year_num := to_char(l_period-g_week_offset,'iyyy');
      l_period_row := l_period_row+1;
      */
      l_period_row := l_period_row+1;
      exit when l_period_end = g_unassigned_day;

      l_period := l_period_end+1;
      l_period_num  := get_period_num(get_week_num(l_period,g_week_offset));

      if l_period_num in (3,6,9,12) then
         l_period_end := l_period+34;
         if l_period_num=12 then
            while get_period_num(get_week_num(l_period_end+7,g_week_offset)) = 12 loop
               l_period_end := l_period_end + 7;
            end loop;
         end if;
      else
         l_period_end := l_period+27;
      end if;

      if l_period > l_to_date then
          l_period := get_period_start(g_unassigned_day);
          l_period_end := g_unassigned_day;
          l_period_num := get_period_num(get_week_num(l_period,g_week_offset));
      end if;

      l_year_num := to_char(l_period-g_week_offset,'iyyy');

   end loop;

   commit;

   if g_debug_flag = 'Y' then
      fii_util.put_line('LOAD_PERIOD_445 : '||to_char(l_period_row)||' records has been populated to Period 445 Level');
   end if;

end LOAD_PERIOD_445;

---------------------------------------------------
-- PRIVATE PROCEDURE LOAD_YEAR_445
---------------------------------------------------
PROCEDURE LOAD_YEAR_445(p_from_date in date, p_to_date in date) IS

   -- ---------------------------------------------------------
   -- Define local variables
   -- ---------------------------------------------------------
   l_from_date          date;
   l_to_date            date;
   l_year               date;
   l_year_end           date;
   l_year_num           number;
   l_year_row           number;

begin

   -- ---------------------------------------------------------
   -- Variable initialization
   -- ---------------------------------------------------------
   l_from_date   := trunc(p_from_date-g_week_offset,'iw')+g_week_offset;
   l_to_date     := trunc(p_to_date,'iw')+6;
   --l_year        := trunc(l_from_date,'iyyy')+g_week_offset;
   l_year        := l_from_date;
   l_year_num    := to_char(l_year-g_week_offset,'iyyy');
   l_year_end    := l_year+6;

   while to_char(l_year_end+7-g_week_offset,'iyyy') = l_year_num loop
      l_year_end := l_year_end+7;
   end loop;

   -- Bug 5624487
   if l_year > l_to_date then
       l_year := trunc(g_unassigned_day-g_week_offset,'iw')+g_week_offset;
       l_year_end := g_unassigned_day;
       l_year_num := to_char(l_year-g_week_offset,'iyyy');
   end if;

   while to_char(l_year-7-g_week_offset,'iyyy') = l_year_num loop
      l_year := l_year-7;
   end loop;

   l_year_row    := 0;

   -- Bug 5624487
   -- delete from FII_TIME_YEAR445 where start_date <= l_to_date and end_date >= l_from_date;
   delete from FII_TIME_YEAR445
   where start_date <= l_to_date and end_date >= l_from_date
      or end_date >= g_unassigned_day;

   -- ----------------------
   -- Populate Year 445 Level
   -- ----------------------

   -- Bug 5624487
   -- while l_year <= l_to_date loop
   while l_year <= l_to_date or l_year_end = g_unassigned_day loop

      -- Bug 5624487
      insert into fii_time_year445
      (year445_id,
       name,
       start_date,
       end_date,
       creation_date,
       last_update_date,
       last_updated_by,
       created_by,
       last_update_login)
      values(
       l_year_num,
    decode(l_year_end, g_unassigned_day, null,
       l_year_num
          ),
       l_year,
       l_year_end,
       sysdate,
       sysdate,
       g_user_id,
       g_user_id,
       g_login_id
      );

      -- Bug 5624487
      /*
      l_year := l_year_end+1;
      l_year_num := to_char(l_year-g_week_offset,'iyyy');
      l_year_end := l_year+6;

      while to_char(l_year_end+7-g_week_offset,'iyyy') = l_year_num loop
         l_year_end := l_year_end+7;
      end loop;

      l_year_row := l_year_row+1;
      */
      l_year_row := l_year_row+1;
      exit when l_year_end = g_unassigned_day;

      l_year := l_year_end+1;
      l_year_num := to_char(l_year-g_week_offset,'iyyy');
      l_year_end := l_year+6;

      while to_char(l_year_end+7-g_week_offset,'iyyy') = l_year_num loop
         l_year_end := l_year_end+7;
      end loop;

      if l_year > l_to_date then
          l_year := trunc(g_unassigned_day-g_week_offset,'iw')+g_week_offset;
          l_year_end := g_unassigned_day;
          l_year_num := to_char(l_year-g_week_offset,'iyyy');
      end if;

      while to_char(l_year-7-g_week_offset,'iyyy') = l_year_num loop
         l_year := l_year-7;
      end loop;

   end loop;

   commit;

   if g_debug_flag = 'Y' then
      fii_util.put_line('LOAD_YEAR_445 : '||to_char(l_year_row)||' records has been populated to Year 445 Level');
   end if;

end LOAD_YEAR_445;

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
   l_period_seq 		number;
   l_period_year        number;

  cursor get_years is
  select distinct ent_year_id
  from fii_time_ent_period
  where  start_date <= p_to_date
   and    end_date >= p_from_date;

  cursor get_periods (p_year number) is
  select ent_period_id
  from fii_time_ent_period
  where ent_year_id = p_year
  order by start_date;

begin

   -- ---------------------------------------------------------
   -- Variable initialization
   -- ---------------------------------------------------------
   l_from_date   := p_from_date;
   l_to_date     := p_to_date;
   l_period_row  := 0;

   IF g_load_mode = 'INIT' THEN
    --If it is initial load the first year should not be populated for the prior_year_ent_period_id column
    --Used a decode for the same
    select period_year into l_period_year from gl_periods
    where l_from_date between start_date and end_date
    and   period_set_name = g_period_set_name
    and   period_type = g_period_type
    and   adjustment_period_flag='N';

   ELSE
    --Incremental run
    select period_year into l_period_year from gl_periods
    where (select nvl(min(start_date), l_from_date) from fii_time_ent_period) between start_date and end_date
    and    period_set_name = g_period_set_name
    and    period_type = g_period_type
    and    adjustment_period_flag='N';
   END IF;

   -- Bug 5624487
   -- delete from FII_TIME_ENT_PERIOD where start_date <= l_to_date and end_date >= l_from_date;
   delete from FII_TIME_ENT_PERIOD
   where start_date <= l_to_date and end_date >= l_from_date
      or end_date >= g_unassigned_day;

   -- ----------------------
   -- Populate Enterprise Period Level
   -- ----------------------
   insert into fii_time_ent_period
   (ent_period_id,
    ent_qtr_id,
    ent_year_id,
    sequence,
    name,
    start_date,
    end_date,
    prior_year_ent_period_id,
    creation_date,
    last_update_date,
    last_updated_by,
    created_by,
    last_update_login)
   select to_number(period_year||quarter_num||decode(length(period_num),1,'0'||period_num, period_num)),
                   -- lpad(period_num,2,'0')),   bug 3370185
          to_number(period_year||quarter_num),
          to_number(period_year),
          period_num,
          period_name,
          start_date,
          end_date,
	  decode(l_period_year, period_year, null, to_number((period_year-1)||quarter_num||decode(length(period_num),1,'0'||period_num, period_num))),
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

   if g_debug_flag = 'Y' then
     fii_util.put_line('LOAD_ENT_PERIOD : '||to_char(l_period_row)||' records has been populated to Enterprise Period Level');
   end if;


   for i in get_years
   loop
     -- update period sequence
     l_period_seq := 1;
     for j in get_periods (i.ent_year_id)
     loop
         update fii_time_ent_period
         set sequence = l_period_seq
         where ent_period_id = j.ent_period_id;
         l_period_seq :=l_period_seq + 1;
     end loop;
   end loop;

   commit;

   -- Bug 5624487
   insert into fii_time_ent_period
   (ent_period_id,
    ent_qtr_id,
    ent_year_id,
    sequence,
    name,
    start_date,
    end_date,
    prior_year_ent_period_id,
    creation_date,
    last_update_date,
    last_updated_by,
    created_by,
    last_update_login)
   select to_number(period_year||quarter_num||decode(length(period_num),1,'0'||period_num, period_num)),
                   -- lpad(period_num,2,'0')),   bug 3370185
          to_number(period_year||quarter_num),
          to_number(period_year),
          period_num,
    decode(end_date, g_unassigned_day, null,
          period_name
          ),
          start_date,
          end_date,
    decode(end_date, g_unassigned_day, null,
	  decode(l_period_year, period_year, null, to_number((period_year-1)||quarter_num||decode(length(period_num),1,'0'||period_num, period_num)))
          ),
          sysdate,
          sysdate,
          g_user_id,
          g_user_id,
          g_login_id
   from ( select
              g_una_ent_period_year period_year,
              g_una_ent_quarter_num quarter_num,
              g_una_ent_period_num period_num,
              null period_name,
              g_unassigned_day start_date,
              g_unassigned_day end_date
          from dual );

   commit;

   -- Bug 5624487
   update fii_time_day
   set ent_period_id         = to_number(g_una_ent_period_year||g_una_ent_quarter_num||decode(length(g_una_ent_period_num),1,'0'||g_una_ent_period_num, g_una_ent_period_num)),
       ent_period_start_date = g_unassigned_day,
       ent_period_end_date   = g_unassigned_day,
       ent_qtr_id            = to_number(g_una_ent_period_year||g_una_ent_quarter_num),
       ent_qtr_start_date    = g_unassigned_day,
       ent_qtr_end_date      = g_unassigned_day,
       ent_year_id           = to_number(g_una_ent_period_year),
       ent_year_start_date   = g_unassigned_day,
       ent_year_end_date     = g_unassigned_day,
       last_update_date      = sysdate,
       last_updated_by       = g_user_id,
       last_update_login     = g_login_id
   where report_date = g_unassigned_day;

   commit;

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
   l_qtr_seq            number;
   l_period_year        number;

  cursor get_years is
  select distinct ent_year_id
  from fii_time_ent_period
  where  start_date <= p_to_date
   and    end_date >= p_from_date;

  cursor get_quarters (p_year number) is
  select distinct sequence, start_date, ent_qtr_id
  from fii_time_ent_qtr
  where ent_year_id = p_year
  order by start_date;

begin

   -- ---------------------------------------------------------
   -- Variable initialization
   -- ---------------------------------------------------------
   l_from_date   := p_from_date;
   l_to_date     := p_to_date;
   l_qtr_row     := 0;

   IF g_load_mode = 'INIT' THEN
   --If it is initial load the first year should not be populated for the prior_year_ent_period_id column
   --Used a decode for the same
   select period_year into l_period_year from gl_periods
   where l_from_date between start_date and end_date
   and period_set_name = g_period_set_name
   and    period_type = g_period_type
   and    adjustment_period_flag='N';

   ELSE
    --Incremental run
    select period_year into l_period_year from gl_periods
    where (select nvl(min(start_date), l_from_date) from fii_time_ent_qtr) between start_date and end_date
    and period_set_name = g_period_set_name
    and    period_type = g_period_type
    and    adjustment_period_flag='N';

   END IF;

   -- Bug 5624487
   -- delete from FII_TIME_ENT_QTR where start_date <= l_to_date and end_date >= l_from_date;
   delete from FII_TIME_ENT_QTR
   where start_date <= l_to_date and end_date >= l_from_date
      or end_date >= g_unassigned_day;

   -- ----------------------
   -- Populate Enterprise Quarter Level
   -- ----------------------
   insert into fii_time_ent_qtr
   (ent_qtr_id,
    ent_year_id,
    sequence,
    name,
    start_date,
    end_date,
    prior_year_ent_qtr_id,
    creation_date,
    last_update_date,
    last_updated_by,
    created_by,
    last_update_login)
   select distinct glp.period_year||glp.quarter_num,
          glp.period_year,
          glp.quarter_num,
          replace(fnd_message.get_string('FII','FII_QUARTER_LABEL'),'&QUARTER_NUMBER',glp.quarter_num)||'-'||to_char(to_date(glp.period_year,'yyyy'),'RR'),
          gl2.start_date,
          gl2.end_date,
 	  decode(l_period_year, period_year, NULL, (glp.period_year - 1)||glp.quarter_num),
          sysdate,
          sysdate,
          g_user_id,
          g_user_id,
          g_login_id
   from   gl_periods glp,
          (select period_year||quarter_num ent_qtr_pk_key, min(start_date) start_date, max(end_date) end_date
           from gl_periods
           where period_set_name=g_period_set_name
           and period_type=g_period_type
           and adjustment_period_flag='N'
           group by period_year||quarter_num) gl2
   where glp.period_year||glp.quarter_num = gl2.ent_qtr_pk_key
   and glp.period_set_name = g_period_set_name
   and glp.period_type = g_period_type
   and glp.adjustment_period_flag='N'
   and glp.start_date <= l_to_date
   and glp.end_date >= l_from_date;

   l_qtr_row := sql%rowcount;

   for i in get_years
   loop
     -- update quarter sequence
     l_qtr_seq := 1;
     for k in get_quarters (i.ent_year_id)
     loop
       update fii_time_ent_qtr
       set sequence = l_qtr_seq
       where ent_qtr_id = k.ent_qtr_id;
       l_qtr_seq := l_qtr_seq + 1;
     end loop;
   end loop;

   commit;

   if g_debug_flag = 'Y' then
      fii_util.put_line('LOAD_ENT_QUARTER : '||to_char(l_qtr_row)||' records has been populated to Enterprise Quarter Level');
   end if;

   -- Bug 5624487
   insert into fii_time_ent_qtr
   (ent_qtr_id,
    ent_year_id,
    sequence,
    name,
    start_date,
    end_date,
    prior_year_ent_qtr_id,
    creation_date,
    last_update_date,
    last_updated_by,
    created_by,
    last_update_login)
   select distinct glp.period_year||glp.quarter_num,
          glp.period_year,
          glp.quarter_num,
    decode(end_date, g_unassigned_day, null,
          replace(fnd_message.get_string('FII','FII_QUARTER_LABEL'),'&QUARTER_NUMBER',glp.quarter_num)||'-'||to_char(to_date(glp.period_year,'yyyy'),'RR')
          ),
          glp.start_date,
          glp.end_date,
    decode(end_date, g_unassigned_day, null,
 	  decode(l_period_year, period_year, NULL, (glp.period_year - 1)||glp.quarter_num)
          ),
          sysdate,
          sysdate,
          g_user_id,
          g_user_id,
          g_login_id
   from ( select
              g_una_ent_period_year period_year,
              g_una_ent_quarter_num quarter_num,
              g_unassigned_day start_date,
              g_unassigned_day end_date
          from dual ) glp;

   commit;

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
   l_period_year        number;

begin

   -- ---------------------------------------------------------
   -- Variable initialization
   -- ---------------------------------------------------------
   l_from_date   := p_from_date;
   l_to_date     := p_to_date;
   l_year_row    := 0;

   IF g_load_mode = 'INIT' THEN
    --If it is initial load the first year should not be populated for the prior_year_ent_period_id column
    --Used a decode for the same
    select period_year into l_period_year from gl_periods
    where l_from_date between start_date and end_date
    and period_set_name = g_period_set_name
    and    period_type = g_period_type
    and    adjustment_period_flag='N';

   ELSE
    --Incremental run
    select period_year into l_period_year from gl_periods where (select nvl(min(start_date), l_from_date) from fii_time_ent_year)
    between start_date and end_date
    and period_set_name = g_period_set_name
    and    period_type = g_period_type
    and    adjustment_period_flag='N';

   END IF;

   -- Bug 5624487
   select nvl(max(end_date), l_to_date)
   into l_end_date
   from fii_time_ent_period
   where end_date < g_unassigned_day;

   -- Bug 5624487
   delete from FII_TIME_ENT_YEAR where ent_year_id in
   (select period_year
    from gl_periods
    where period_set_name = g_period_set_name
    and period_type = g_period_type
    and adjustment_period_flag='N'
    and start_date <= l_to_date
    and end_date >= l_from_date)
   or end_date >= g_unassigned_day;

   -- ----------------------
   -- Populate Enterprise Year Level
   -- ----------------------
   insert into fii_time_ent_year
   (ent_year_id,
    period_set_name,
    period_type,
    sequence,
    name,
    start_date,
    end_date,
    prior_ent_year_id,
    creation_date,
    last_update_date,
    last_updated_by,
    created_by,
    last_update_login)
   select distinct glp.period_year ent_year_pk_key,
          glp.period_set_name period_set_name,
          glp.period_type period_type,
          glp.period_year,
          glp.period_year name,
          gl2.start_date start_date,
          gl2.end_date end_date,
	  decode(l_period_year, glp.period_year, NULL, (glp.period_year - 1)),
          sysdate creation_date,
          sysdate last_update_date,
          g_user_id last_updated_by,
          g_user_id created_by,
          g_login_id last_update_login
   from gl_periods glp,
        (select period_year period_year, min(start_date) start_date, max(end_date) end_date
         from gl_periods
         where period_set_name=g_period_set_name
         and period_type=g_period_type
         and adjustment_period_flag='N'
         and end_date <= l_end_date
         group by period_year) gl2
   where glp.period_year=gl2.period_year
   and glp.period_set_name = g_period_set_name
   and glp.period_type = g_period_type
   and glp.adjustment_period_flag='N'
   and glp.start_date <= l_to_date
   and glp.end_date >= l_from_date;

   l_year_row := sql%rowcount;

   commit;

   if g_debug_flag = 'Y' then
      fii_util.put_line('LOAD_ENT_YEAR : '||to_char(l_year_row)||' records has been populated to Enterprise Year Level');
   end if;

   -- Bug 5624487
   insert into fii_time_ent_year
   (ent_year_id,
    period_set_name,
    period_type,
    sequence,
    name,
    start_date,
    end_date,
    prior_ent_year_id,
    creation_date,
    last_update_date,
    last_updated_by,
    created_by,
    last_update_login)
   select distinct glp.period_year ent_year_pk_key,
          glp.period_set_name period_set_name,
          glp.period_type period_type,
          glp.period_year,
    decode(end_date, g_unassigned_day, null,
          glp.period_year
          ),
          glp.start_date start_date,
          glp.end_date end_date,
    decode(end_date, g_unassigned_day, null,
	  decode(l_period_year, glp.period_year, NULL, (glp.period_year - 1))
          ),
          sysdate creation_date,
          sysdate last_update_date,
          g_user_id last_updated_by,
          g_user_id created_by,
          g_login_id last_update_login
   from ( select
              g_una_ent_period_year period_year,
              g_period_set_name period_set_name,
              g_period_type period_type,
              g_unassigned_day start_date,
              g_unassigned_day end_date
          from dual ) glp;

   commit;

end LOAD_ENT_YEAR;

---------------------------------------------------
-- PRIVATE PROCEDURE LOAD_CAL_PERIOD
---------------------------------------------------
PROCEDURE LOAD_CAL_PERIOD IS

   -- ---------------------------------------------------------
   -- Define local variables
   -- ---------------------------------------------------------
   l_period_row         number;

   l_diff_rows number;
   l_period_changed number;

begin

   -- determine if any rows will be different between current set per
   -- gl tables and current set per fii tables
   --Bug 3543939. Get the Calendar id's into a temporary table for use in Load_Time_Cal_Rpt_Struct

   Insert into fii_time_cal_gt(calendar_id)
   select calendar_id
   from (
     (select
       to_number(lpad(cal_name.calendar_id,3,'0')||glp.period_year||glp.quarter_num||decode(length(glp.period_num),1,'0'||glp.period_num, glp.period_num))
              -- lpad(gl.period_num,2,'0'))   bug 3370185
      , to_number(lpad(cal_name.calendar_id,3,'0')||glp.period_year||glp.quarter_num)
      , to_number(lpad(cal_name.calendar_id,3,'0')) calendar_id
      , glp.period_num
      , glp.period_name
      , glp.start_date
      , glp.end_date
      from
        gl_periods glp
      , fii_time_cal_name cal_name
      where glp.adjustment_period_flag = 'N'
      and glp.period_set_name = cal_name.period_set_name
      and glp.period_type = cal_name.period_type
      minus
      select
        cal_period_id
      , cal_qtr_id
      , calendar_id
      , sequence
      , name
      , start_date
      , end_date
      from
        fii_time_cal_period
     )
     union all
     (select
        cal_period_id
      , cal_qtr_id
      , calendar_id
      , sequence
      , name
      , start_date
      , end_date
     from
       fii_time_cal_period
     minus
     select
       to_number(lpad(cal_name.calendar_id,3,'0')||glp.period_year||glp.quarter_num||decode(length(glp.period_num),1,'0'||glp.period_num, glp.period_num))
              -- lpad(gl.period_num,2,'0'))   bug 3370185
      , to_number(lpad(cal_name.calendar_id,3,'0')||glp.period_year||glp.quarter_num)
      , to_number(lpad(cal_name.calendar_id,3,'0')) calendar_id
      , glp.period_num
      , glp.period_name
      , glp.start_date
      , glp.end_date
      from
        gl_periods glp
      , fii_time_cal_name cal_name
      where glp.adjustment_period_flag = 'N'
      and glp.period_set_name = cal_name.period_set_name
      and glp.period_type = cal_name.period_type
     )
   );

   --For Bug 3640141.
   l_period_changed := sql%rowcount;

   if g_debug_flag = 'Y' then
         fii_util.put_line('LOAD_CAL_PERIOD : '||to_char(l_period_changed)||' Calendars have changed in GL');
   end if;

   --For Bug 3543939. If there is a difference then truncate and repopulate FII_TIME_CAL_PERIOD

   -- Bug 4966868: Changed not to count rows
   BEGIN
     select 1 into l_diff_rows
     from  fii_time_cal_gt
     where rownum = 1;
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       l_diff_rows := 0;
   END;

   -- all or nothing!
   -- if there are no differences then there is no more work to do
   if l_diff_rows = 0 then

      if g_debug_flag = 'Y' then
         fii_util.put_line('LOAD_CAL_PERIOD : '||'0 records has been populated to Financial Period Level');
      end if;

      return;

   end if;

   truncate_table('FII_TIME_CAL_PERIOD');

   -- ---------------------------------------------------------
   -- Variable initialization
   -- ---------------------------------------------------------
   l_period_row  := 0;

   -- ----------------------
   -- Populate Financial Period Level
   -- ----------------------
   insert into fii_time_cal_period
   (cal_period_id,
    cal_qtr_id,
    calendar_id,
    sequence,
    name,
    start_date,
    end_date,
    creation_date,
    last_update_date,
    last_updated_by,
    created_by,
    last_update_login)
   select lpad(cal_name.calendar_id,3,'0')||glp.period_year||glp.quarter_num||decode(length(glp.period_num),1,'0'||glp.period_num, glp.period_num),
              -- lpad(gl.period_num,2,'0'),  bug 3370185
          lpad(cal_name.calendar_id,3,'0')||glp.period_year||glp.quarter_num,
          lpad(cal_name.calendar_id,3,'0'),
          glp.period_num,
          glp.period_name,
          glp.start_date,
          glp.end_date,
          sysdate,
          sysdate,
          g_user_id,
          g_user_id,
          g_login_id
   from   gl_periods glp, fii_time_cal_name cal_name
   where  glp.adjustment_period_flag='N'
   and    glp.period_set_name=cal_name.period_set_name
   and    glp.period_type=cal_name.period_type;

   l_period_row := sql%rowcount;

   commit;

   if g_debug_flag = 'Y' then
      fii_util.put_line('LOAD_CAL_PERIOD : '||to_char(l_period_row)||' records has been populated to Financial Period Level');
   end if;

   gather_table_stats('FII_TIME_CAL_PERIOD');

   if g_debug_flag = 'Y' then
      fii_util.put_line('LOAD_CAL_PERIOD : '||'Gathered statistics for Financial Period Level');
   end if;

end LOAD_CAL_PERIOD;

---------------------------------------------------
-- PRIVATE PROCEDURE LOAD_CAL_QUARTER
---------------------------------------------------
PROCEDURE LOAD_CAL_QUARTER IS

   -- ---------------------------------------------------------
   -- Define local variables
   -- ---------------------------------------------------------
   l_qtr_row            number;

   l_diff_rows number;

begin

   -- determine if any rows will be different between current set per
   -- gl tables and current set per fii tables
   -- Bug 4966868: Changed not to count rows
   begin
     select 1
     into l_diff_rows
     from (
       (select
          distinct to_number(lpad(cal_name.calendar_id,3,'0')||glp.period_year||glp.quarter_num)
        , to_number(lpad(cal_name.calendar_id,3,'0')||glp.period_year)
        , to_number(lpad(cal_name.calendar_id,3,'0'))
        , glp.quarter_num
        , to_char(glp.quarter_num)||', '||to_char(glp.period_year)
        , min(gl2.start_date)
        , max(gl2.end_date)
        from
          gl_periods glp
        , fii_time_cal_name cal_name
        , (select period_set_name
           , period_type
           , period_year
           , quarter_num
           , min(start_date) start_date
           , max(end_date) end_date
           from
             gl_periods
           where adjustment_period_flag='N'
           group by
             period_set_name
           , period_type
           , period_year
           , quarter_num
          ) gl2
        where glp.adjustment_period_flag='N'
        and glp.period_set_name=cal_name.period_set_name
        and glp.period_type=cal_name.period_type
        and glp.period_set_name=gl2.period_set_name
        and glp.period_type=gl2.period_type
        and glp.period_year=gl2.period_year
        and glp.quarter_num=gl2.quarter_num
        group by
          to_number(lpad(cal_name.calendar_id,3,'0')||glp.period_year||glp.quarter_num)
        , to_number(lpad(cal_name.calendar_id,3,'0')||glp.period_year)
        , to_number(lpad(cal_name.calendar_id,3,'0'))
        , glp.quarter_num
        , to_char(glp.quarter_num)||', '||to_char(glp.period_year)
        minus
        select
          cal_qtr_id
        , cal_year_id
        , calendar_id
        , sequence
        , name
        , start_date
        , end_date
        from
          fii_time_cal_qtr
       )
       union all
       (select
          cal_qtr_id
        , cal_year_id
        , calendar_id
        , sequence
        , name
        , start_date
        , end_date
        from
          fii_time_cal_qtr
        minus
        select
          distinct to_number(lpad(cal_name.calendar_id,3,'0')||glp.period_year||glp.quarter_num)
        , to_number(lpad(cal_name.calendar_id,3,'0')||glp.period_year)
        , to_number(lpad(cal_name.calendar_id,3,'0'))
        , glp.quarter_num
        , to_char(glp.quarter_num)||', '||to_char(glp.period_year)
        , min(gl2.start_date)
        , max(gl2.end_date)
        from
          gl_periods glp
        , fii_time_cal_name cal_name
        , (select period_set_name
           , period_type
           , period_year
           , quarter_num
           , min(start_date) start_date
           , max(end_date) end_date
           from
             gl_periods
           where adjustment_period_flag = 'N'
           group by
             period_set_name
           , period_type
           , period_year
           , quarter_num
          ) gl2
        where glp.adjustment_period_flag = 'N'
        and glp.period_set_name = cal_name.period_set_name
        and glp.period_type = cal_name.period_type
        and glp.period_set_name = gl2.period_set_name
        and glp.period_type = gl2.period_type
        and glp.period_year = gl2.period_year
        and glp.quarter_num = gl2.quarter_num
        group by
          to_number(lpad(cal_name.calendar_id,3,'0')||glp.period_year||glp.quarter_num)
        , to_number(lpad(cal_name.calendar_id,3,'0')||glp.period_year)
        , to_number(lpad(cal_name.calendar_id,3,'0'))
        , glp.quarter_num
        , to_char(glp.quarter_num)||', '||to_char(glp.period_year)
       )
     )
     where rownum = 1;
   exception
     when NO_DATA_FOUND then
       l_diff_rows := 0;
   end;

   -- all or nothing!
   -- if there are no differences then there is no more work to do
   if l_diff_rows = 0 then

      if g_debug_flag = 'Y' then
         fii_util.put_line('LOAD_CAL_QUARTER : '||'0 records has been populated to Financial Quarter Level');
      end if;

      return;

   end if;

   truncate_table('FII_TIME_CAL_QTR');

   -- ---------------------------------------------------------
   -- Variable initialization
   -- ---------------------------------------------------------
   l_qtr_row     := 0;

   -- ----------------------
   -- Populate Financial Quarter Level
   -- ----------------------
   insert into fii_time_cal_qtr
   (cal_qtr_id,
    cal_year_id,
    calendar_id,
    sequence,
    name,
    start_date,
    end_date,
    creation_date,
    last_update_date,
    last_updated_by,
    created_by,
    last_update_login)
   select distinct lpad(cal_name.calendar_id,3,'0')||glp.period_year||glp.quarter_num,
          lpad(cal_name.calendar_id,3,'0')||glp.period_year,
          lpad(cal_name.calendar_id,3,'0'),
          glp.quarter_num,
          to_char(glp.quarter_num)||', '||to_char(glp.period_year),
          min(gl2.start_date),
          max(gl2.end_date),
          sysdate,
          sysdate,
          g_user_id,
          g_user_id,
          g_login_id
   from   gl_periods glp, fii_time_cal_name cal_name,
          (select period_set_name, period_type, period_year, quarter_num, min(start_date) start_date, max(end_date) end_date
           from gl_periods
           where adjustment_period_flag='N'
           group by period_set_name, period_type, period_year, quarter_num) gl2
   where  glp.adjustment_period_flag='N'
   and    glp.period_set_name=cal_name.period_set_name
   and    glp.period_type=cal_name.period_type
   and    glp.period_set_name=gl2.period_set_name
   and    glp.period_type=gl2.period_type
   and    glp.period_year=gl2.period_year
   and    glp.quarter_num=gl2.quarter_num
   group by lpad(cal_name.calendar_id,3,'0')||glp.period_year||glp.quarter_num,
            lpad(cal_name.calendar_id,3,'0')||glp.period_year,
            lpad(cal_name.calendar_id,3,'0'),
            glp.quarter_num,
            to_char(glp.quarter_num)||', '||to_char(glp.period_year);

   l_qtr_row := sql%rowcount;

   commit;

   if g_debug_flag = 'Y' then
      fii_util.put_line('LOAD_CAL_QUARTER : '||to_char(l_qtr_row)||' records has been populated to Financial Quarter Level');
   end if;

   gather_table_stats('FII_TIME_CAL_QTR');

   if g_debug_flag = 'Y' then
      fii_util.put_line('LOAD_CAL_QUARTER : '||'Gathered statistics for Financial Quarter Level');
   end if;

end LOAD_CAL_QUARTER;

---------------------------------------------------
-- PRIVATE PROCEDURE LOAD_CAL_YEAR
---------------------------------------------------
PROCEDURE LOAD_CAL_YEAR IS

   -- ---------------------------------------------------------
   -- Define local variables
   -- ---------------------------------------------------------
   l_year_row           number;

   l_diff_rows number;

begin

   -- determine if any rows will be different between current set per
   -- gl tables and current set per fii tables
   -- Bug 4966868: Changed not to count rows
   begin
     select 1
     into l_diff_rows
     from (
       (select
          distinct to_number(lpad(cal_name.calendar_id,3,'0')||glp.period_year)
        , to_number(lpad(cal_name.calendar_id,3,'0'))
        , glp.period_year
        , to_char(glp.period_year)
        , min(gl2.start_date)
        , max(gl2.end_date)
        from
          gl_periods glp
        , fii_time_cal_name cal_name
        , (select period_set_name
           , period_type
           , period_year
           , min(start_date) start_date
           , max(end_date) end_date
           from
             gl_periods
           where adjustment_period_flag='N'
           group by
             period_set_name
           , period_type
           , period_year
          ) gl2
        where glp.adjustment_period_flag = 'N'
        and glp.period_set_name = cal_name.period_set_name
        and glp.period_type = cal_name.period_type
        and glp.period_set_name = gl2.period_set_name
        and glp.period_type = gl2.period_type
        and glp.period_year = gl2.period_year
        group by
          cal_name.calendar_id
        , glp.period_year
        minus
        select
          cal_year_id
        , calendar_id
        , sequence
        , name
        , start_date
        , end_date
        from
          fii_time_cal_year
       )
       union all
       (select
          cal_year_id
        , calendar_id
        , sequence
        , name
        , start_date
        , end_date
        from
          fii_time_cal_year
        minus
        select
          distinct to_number(lpad(cal_name.calendar_id,3,'0')||glp.period_year)
        , to_number(lpad(cal_name.calendar_id,3,'0'))
        , glp.period_year
        , to_char(glp.period_year)
        , min(gl2.start_date)
        , max(gl2.end_date)
        from
          gl_periods glp
        , fii_time_cal_name cal_name
        , (select period_set_name
           , period_type
           , period_year
           , min(start_date) start_date
           , max(end_date) end_date
           from
             gl_periods
           where adjustment_period_flag = 'N'
           group by
             period_set_name
           , period_type
           , period_year
          ) gl2
        where glp.adjustment_period_flag = 'N'
        and glp.period_set_name = cal_name.period_set_name
        and glp.period_type = cal_name.period_type
        and glp.period_set_name = gl2.period_set_name
        and glp.period_type = gl2.period_type
        and glp.period_year = gl2.period_year
        group by
          cal_name.calendar_id
        , glp.period_year
       )
     )
     where rownum = 1;
   exception
     when NO_DATA_FOUND then
       l_diff_rows := 0;
   end;

   -- all or nothing!
   -- if there are no differences then there is no more work to do
   if l_diff_rows = 0 then

      if g_debug_flag = 'Y' then
         fii_util.put_line('LOAD_CAL_YEAR : '||'0 records has been populated to Financial Year Level');
      end if;

      return;

   end if;

   truncate_table('FII_TIME_CAL_YEAR');

   -- ---------------------------------------------------------
   -- Variable initialization
   -- ---------------------------------------------------------
   l_year_row    := 0;

   -- ----------------------
   -- Populate Financial Year Level
   -- ----------------------
   insert into fii_time_cal_year
   (cal_year_id,
    calendar_id,
    sequence,
    name,
    start_date,
    end_date,
    creation_date,
    last_update_date,
    last_updated_by,
    created_by,
    last_update_login)
   select distinct lpad(cal_name.calendar_id,3,'0')||glp.period_year,
          lpad(cal_name.calendar_id,3,'0'),
          glp.period_year,
          glp.period_year,
          min(gl2.start_date),
          max(gl2.end_date),
          sysdate,
          sysdate,
          g_user_id,
          g_user_id,
          g_login_id
   from   gl_periods glp, fii_time_cal_name cal_name,
          (select period_set_name, period_type, period_year, min(start_date) start_date, max(end_date) end_date
           from gl_periods
           where adjustment_period_flag='N'
           group by period_set_name, period_type, period_year) gl2
   where  glp.adjustment_period_flag='N'
   and    glp.period_set_name=cal_name.period_set_name
   and    glp.period_type=cal_name.period_type
   and    glp.period_set_name=gl2.period_set_name
   and    glp.period_type=gl2.period_type
   and    glp.period_year=gl2.period_year
   group by cal_name.calendar_id, glp.period_year;

   l_year_row := sql%rowcount;

   commit;

   if g_debug_flag = 'Y' then
      fii_util.put_line('LOAD_CAL_YEAR : '||to_char(l_year_row)||' records has been populated to Financial Year Level');
   end if;

   gather_table_stats('FII_TIME_CAL_YEAR');

   if g_debug_flag = 'Y' then
      fii_util.put_line('LOAD_CAL_YEAR : '||'Gathered statistics for Financial Year Level');
   end if;

end LOAD_CAL_YEAR;

---------------------------------------------------
-- PUBLIC PROCEDURE LOAD
---------------------------------------------------
PROCEDURE LOAD(errbuf out NOCOPY varchar2,
               retcode out NOCOPY Varchar2,
               p_from_date in varchar2,
               p_to_date in varchar2,
               p_all_level in varchar2,
               p_load_mode in varchar2) IS

-- ---------------------------------------------------------
-- Define local variables
-- ---------------------------------------------------------
   l_from_date          date;
   l_to_date            date;

   l_global_param_list dbms_sql.varchar2_table;

   l_bis_setup          varchar2(1) := 'N';
   l_min_date           date;
   l_max_date           date;
   l_max_gl_date        date;
   l_validated          varchar2(1) := 'N';
   l_period_updated     varchar2(1) := 'N';
   l_count              number := 0;
   l_error_msg          varchar2(5000);
   l_error_code         varchar2(5000);
   l_dir       VARCHAR2(400);
   l_mesg       varchar2(2048) ;
   --Bug 4995016
   l_min_start_date       date;
   l_max_end_date       date;
   l_year		number;
   l_start_date		date;
begin

   l_dir:=FII_UTIL.get_utl_file_dir;
   FII_UTIL.initialize('FII_DBI_TIME_M.log','FII_DBI_TIME_M.out',l_dir, 'FII_DBI_TIME_M');


   l_from_date := trunc(to_date(p_from_date,'YYYY/MM/DD HH24:MI:SS'));
   l_to_date := trunc(to_date(p_to_date, 'YYYY/MM/DD HH24:MI:SS'));
   g_all_level := nvl(p_all_level,'Y');
   g_load_mode := p_load_mode;

   if g_debug_flag = 'Y' then
      fii_util.put_line('LOAD : '||'Data loads from ' ||
                        fnd_date.date_to_displaydate(l_from_date) ||
                        ' to ' ||
                        fnd_date.date_to_displaydate(l_to_date));
   end if;

   -----------------------------------------------------
   -- Calling BIS API to do common set ups
   -- If it returns false, then program should error out
   -----------------------------------------------------
   g_phase := 'Call BIS API to do common set ups';
   l_global_param_list(1) := 'BIS_GLOBAL_START_DATE';
   IF (NOT bis_common_parameters.check_global_parameters(l_global_param_list)) THEN
      retcode := 1;
      raise G_BIS_PARAMETER_NOT_SETUP;
   ELSIF (NOT BIS_COLLECTION_UTILITIES.setup('FII_DBI_TIME_M')) THEN
      errbuf := sqlerrm;
      raise_application_error(-20000, 'Error for Time setup: ' || errbuf);
   END IF;

   -- exception handler needs to know whether to perform a wrapup
   -- with error
   l_bis_setup := 'Y';

   g_phase := 'Retrieve the BIS common parameters';
   INIT;

   if g_all_level = 'Y' then

      l_validated := check_validated;

      -- Bug 5624487
      select max(report_date), min(report_date)
      into l_max_date, l_min_date
      from fii_time_day
      where report_date <> g_unassigned_day;

      if p_load_mode = 'INIT' then

         l_validated := 'N';
         l_max_date := null;
      end if;

      if l_validated = 'N' then

         if g_debug_flag = 'Y' then
            fii_util.put_line('LOAD : '||'Time Dimension will be validated.');
            fii_util.put_line(' ');
         end if;

         if l_from_date > g_global_start_date then
           l_from_date := g_global_start_date;
         end if;

         l_to_date := greatest(nvl(l_max_date,l_to_date),l_to_date);

      end if;

      if l_max_date is not null and
         l_from_date > l_max_date+1 then

         l_from_date := l_max_date+1;

      end if;

      --l_start_date is used for finding out the year of the date for which time dimension will run.
      l_start_date := l_from_date;

       -- Bug 4454026
       -- We should default the from date to the start of the fiscal year so that fix of bug 3961336 wroks fine
       -- which is to make the sequence in fii_time_ent_period and fii_time_ent_qtr independent of GL
       -- This is done for initial load and in case the last run was not successfull

        g_phase := 'Checking if all the years in the calendar are fully defined';

        -- This is necessary because once initial load is over, there can be some changes in the already defined calendar
	-- which may result in a calendar not complying with the no. of days range allowed (365 +/- 14)

         IF l_validated = 'Y' THEN
	  truncate_table('FII_TIME_GL_PERIODS');
          l_period_updated := period_updated(l_min_date, l_max_date);
	  IF (l_period_updated = 'Y' and p_load_mode <> 'INIT') THEN
	   l_start_date := l_min_date;
          END IF; --l_period_updated
	 END if; --l_validated

        begin
	 select period_year into l_year
	 from gl_periods a
	 where a.period_set_name = g_period_set_name
	 and a.period_type = g_period_type
	 and a.adjustment_period_flag = 'N'
	 and l_start_date between a.start_date and a.end_date;
	exception
	 when no_data_found then
	  g_date_not_defined := l_from_date;
	  raise G_ENT_CALENDAR_NOT_FOUND;
	end;

	select min(a.start_date), max(end_date) into l_min_start_date, l_max_end_date
	from gl_periods a
	where a.period_set_name = g_period_set_name
	and a.period_type = g_period_type
	and a.adjustment_period_flag = 'N'
	and a.period_year = l_year;


	IF  p_load_mode = 'INIT' then
	 l_from_date := l_min_start_date;
        END IF;

	 -- Bug 4995016. Check for every year if its fully defined or not.
	 -- Allowed limit is 365 + or - 14 days in a year.
	 -- Bug 5284046. Added l_min_start_date <= l_to_date clause to the while loop

         While (l_min_start_date is NOT NULL and l_min_start_date <= l_to_date)	 LOOP

	  IF (l_max_end_date - l_min_start_date) +1 < 352 OR (l_max_end_date - l_min_start_date) +1 > 379 THEN
	    raise G_YEAR_NOT_DEFINED;
          END IF;

          l_year := l_year + 1;

	  select min(a.start_date), max(end_date) into l_min_start_date, l_max_end_date
	  from gl_periods a
	  where a.period_set_name = g_period_set_name
	  and a.period_type = g_period_type
	  and a.adjustment_period_flag = 'N'
	  and a.period_year = l_year;

	 END LOOP;

      if g_debug_flag = 'Y' and
         l_from_date <> to_date(p_from_date,'YYYY/MM/DD HH24:MI:SS') or
         l_to_date <> to_date(p_to_date,'YYYY/MM/DD HH24:MI:SS') then
         fii_util.put_line('LOAD : '||'Resetting data loads as from ' ||
                           fnd_date.date_to_displaydate(l_from_date) ||
                           ' to ' ||
                           fnd_date.date_to_displaydate(l_to_date));
      end if;

   end if; --if g_all_level = 'Y'

   -- if it is initial loading, all the tables will be truncated and re-populated
   if p_load_mode = 'INIT' then
      if g_debug_flag = 'Y' then
         fii_util.put_line('LOAD : '||'This is an initial load, all tables will be truncated and re-populated.');
      end if;

      truncate_table('FII_TIME_DAY');
      truncate_table('FII_TIME_MONTH');
      truncate_table('FII_TIME_QTR');
      truncate_table('FII_TIME_YEAR');
      truncate_table('FII_TIME_WEEK');
      truncate_table('FII_TIME_P445');
      truncate_table('FII_TIME_YEAR445');
      truncate_table('FII_TIME_ENT_PERIOD');
      truncate_table('FII_TIME_ENT_QTR');
      truncate_table('FII_TIME_ENT_YEAR');
      truncate_table('FII_TIME_CAL_NAME');
      truncate_table('FII_TIME_CAL_PERIOD');
      truncate_table('FII_TIME_CAL_QTR');
      truncate_table('FII_TIME_CAL_YEAR');
      truncate_table('FII_TIME_RPT_STRUCT');
      truncate_table('FII_TIME_CAL_RPT_STRUCT');
      truncate_table('FII_TIME_STRUCTURES');
      truncate_table('FII_TIME_ROLLING_OFFSETS');
   else
   -- if it is incremental loading, check if there is any modified period
   -- if there is any modified period, do initial load of the enterprise tables
      if g_debug_flag = 'Y' then
         fii_util.put_line('LOAD : '||'l_validated='||l_validated);
         fii_util.put_line('');
      end if;
      if l_validated = 'Y' then
         --truncate_table('FII_TIME_GL_PERIODS');
         --l_period_updated := period_updated(l_min_date, l_max_date);
         if g_debug_flag = 'Y' then
            fii_util.put_line('LOAD : '||'l_period_updated='||l_period_updated);
            fii_util.put_line('');
         end if;
         if l_period_updated = 'Y' then
            truncate_table('FII_TIME_ENT_PERIOD');
         end if;
         -- both enterprise quarter and enterprise year tables are truncated because function period_updated
         -- can only detect if there is any changes of the existing periods populated into time dimension
         -- If there is a new period added to a quarter, then requires the end date of that quarter to be updated
         -- function period_updated is not able to indicate that, that's why we choose to always truncate the
         -- tables to avoid any further unique constraint violation
         truncate_table('FII_TIME_ENT_QTR');
         truncate_table('FII_TIME_ENT_YEAR');
      end if;
   end if;

   g_phase := 'Load Day Level';
   if g_debug_flag = 'Y' then
      fii_util.put_line(' ');
      fii_util.start_timer;
   end if;

   -- we compare the latest end date defined in GL and the latest end date in fii_time_day
   -- to determine if there is new gl period added or not
   select max(end_date)
   into l_max_gl_date
   from gl_periods
   where  period_set_name = g_period_set_name
   and    period_type = g_period_type
   and    adjustment_period_flag='N';

   -- we will populate the end date columns if they haven't been populated
   -- Bug 4966868: Changed not to count rows
   begin
     -- Bug 5624487
     select 1 into l_count
     from fii_time_day
     where ent_period_end_date is null
     and report_date <> g_unassigned_day
     and rownum = 1;
   exception
     when NO_DATA_FOUND then
       l_count := 0;
   end;

   if l_period_updated = 'Y' or l_max_gl_date > l_max_date or l_count > 0 then
      -- we populate data from the earliest date in FII_TIME_DAY or the from date parameter, see which one is the earliest
      -- to the latest date in FII_TIME_DAY or the to date parameter, see which one is the latest.  This is to make sure
      -- we will insert new records as well as modify existing records if necessary.  If new gl period has been added to
      -- an existing quarter, the quarter end date and the year end date needs to be updated.
      LOAD_DAY_INC(least(nvl(l_min_date,l_from_date),l_from_date), greatest(nvl(l_max_date,l_to_date),l_to_date));
   else
      LOAD_DAY_INC(l_from_date, l_to_date); -- incremental refresh
   end if;
   if g_debug_flag = 'Y' then
      fii_util.stop_timer;
      fii_util.print_timer('Process Time');
      fii_util.put_line(' ');
   end if;

   g_phase := 'Load Month Level';
   if g_debug_flag = 'Y' then
      fii_util.start_timer;
   end if;
   LOAD_MONTH(l_from_date, l_to_date);
   if g_debug_flag = 'Y' then
      fii_util.stop_timer;
      fii_util.print_timer('Process Time');
      fii_util.put_line(' ');
   end if;

   g_phase := 'Load Quarter Level';
   if g_debug_flag = 'Y' then
      fii_util.start_timer;
   end if;
   LOAD_QUARTER(l_from_date, l_to_date);
   if g_debug_flag = 'Y' then
      fii_util.stop_timer;
      fii_util.print_timer('Process Time');
      fii_util.put_line(' ');
   end if;

   g_phase := 'Load Year Level';
   if g_debug_flag = 'Y' then
      fii_util.start_timer;
   end if;
   LOAD_YEAR(l_from_date, l_to_date);
   if g_debug_flag = 'Y' then
      fii_util.stop_timer;
      fii_util.print_timer('Process Time');
      fii_util.put_line(' ');
   end if;

   if (g_all_level = 'Y') then

      g_phase := 'Load Week Level';
      if g_debug_flag = 'Y' then
        fii_util.start_timer;
      end if;
      LOAD_WEEK(l_from_date, l_to_date);
      if g_debug_flag = 'Y' then
         fii_util.stop_timer;
         fii_util.print_timer('Process Time');
         fii_util.put_line(' ');
      end if;

      g_phase := 'Load Period 445 Level';
      if g_debug_flag = 'Y' then
         fii_util.start_timer;
      end if;
      LOAD_PERIOD_445(l_from_date, l_to_date);
      if g_debug_flag = 'Y' then
         fii_util.stop_timer;
         fii_util.print_timer('Process Time');
         fii_util.put_line(' ');
      end if;

      g_phase := 'Load Year 445 Level';
      if g_debug_flag = 'Y' then
         fii_util.start_timer;
      end if;
      LOAD_YEAR_445(l_from_date, l_to_date);
      if g_debug_flag = 'Y' then
         fii_util.stop_timer;
         fii_util.print_timer('Process Time');
          fii_util.put_line(' ');
      end if;

      g_phase := 'Load Enterprise Period Level';
      if g_debug_flag = 'Y' then
         fii_util.start_timer;
      end if;
      if l_period_updated = 'Y' then
      -- we populate data from the earliest date in FII_TIME_DAY or the from date parameter, see which one is the earliest
      -- to the latest date in FII_TIME_DAY or the to date parameter, see which one is the latest.  This is to make sure
      -- we will insert new records as well as existing records that we have been truncated
         LOAD_ENT_PERIOD(least(nvl(l_min_date,l_from_date),l_from_date), greatest(nvl(l_max_date,l_to_date),l_to_date));
      else
         LOAD_ENT_PERIOD(l_from_date, l_to_date);
      end if;
      if g_debug_flag = 'Y' then
         fii_util.stop_timer;
         fii_util.print_timer('Process Time');
         fii_util.put_line(' ');
      end if;

      g_phase := 'Load Enterprise Quarter Level';
      if g_debug_flag = 'Y' then
         fii_util.start_timer;
      end if;
      -- we populate data from the earliest date in FII_TIME_DAY or the from date parameter, see which one is the earliest
      -- to the latest date in FII_TIME_DAY or the to date parameter, see which one is the latest.  This is to make sure
      -- we will insert new records as well as existing records that we have been truncated
      LOAD_ENT_QUARTER(least(nvl(l_min_date,l_from_date),l_from_date), greatest(nvl(l_max_date,l_to_date),l_to_date));
      if g_debug_flag = 'Y' then
         fii_util.stop_timer;
         fii_util.print_timer('Process Time');
         fii_util.put_line(' ');
      end if;

      g_phase := 'Load Enterprise Year Level';
      if g_debug_flag = 'Y' then
         fii_util.start_timer;
      end if;
      -- we populate data from the earliest date in FII_TIME_DAY or the from date parameter, see which one is the earliest
      -- to the latest date in FII_TIME_DAY or the to date parameter, see which one is the latest.  This is to make sure
      -- we will insert new records as well as existing records that we have been truncated
      LOAD_ENT_YEAR(least(nvl(l_min_date,l_from_date),l_from_date), greatest(nvl(l_max_date,l_to_date),l_to_date));
      if g_debug_flag = 'Y' then
         fii_util.stop_timer;
         fii_util.print_timer('Process Time');
         fii_util.put_line(' ');
      end if;

      g_phase := 'Load Financial Calendar Level';
      if g_debug_flag = 'Y' then
         fii_util.start_timer;
      end if;
      LOAD_CAL_NAME;
      if g_debug_flag = 'Y' then
         fii_util.stop_timer;
         fii_util.print_timer('Process Time');
         fii_util.put_line(' ');
      end if;

      g_phase := 'Load Financial Period Level';
      if g_debug_flag = 'Y' then
         fii_util.start_timer;
      end if;
      LOAD_CAL_PERIOD;
      if g_debug_flag = 'Y' then
         fii_util.stop_timer;
         fii_util.print_timer('Process Time');
         fii_util.put_line(' ');
      end if;

      g_phase := 'Load Financial Quarter Level';
      if g_debug_flag = 'Y' then
         fii_util.start_timer;
      end if;
      LOAD_CAL_QUARTER;
      if g_debug_flag = 'Y' then
         fii_util.stop_timer;
         fii_util.print_timer('Process Time');
         fii_util.put_line(' ');
      end if;

      g_phase := 'Load Financial Year Level';
      if g_debug_flag = 'Y' then
         fii_util.start_timer;
      end if;
      LOAD_CAL_YEAR;
      if g_debug_flag = 'Y' then
         fii_util.stop_timer;
         fii_util.print_timer('Process Time');
         fii_util.put_line(' ');
      end if;

      g_phase := 'Refresh Materialized View';
      if g_debug_flag = 'Y' then
         fii_util.put_line('LOAD : '||'Refresh Materialized View');
         fii_util.start_timer;
      end if;

      commit;

      ------------------------------------------------------------------------------
      --Bug 3155474: call BIS wrapper to handle force parallel on MVs
      -----   dbms_mview.REFRESH('FII_TIME_CAL_DAY_MV','C');

      BIS_MV_REFRESH.refresh_wrapper ('FII_TIME_CAL_DAY_MV', 'C');
      ------------------------------------------------------------------------------

      if g_debug_flag = 'Y' then
         fii_util.stop_timer;
         fii_util.print_timer('Process Time');
         fii_util.put_line(' ');
      end if;

      g_phase := 'Load Reporting Structure Table for Financial Calendars';
      if g_debug_flag = 'Y' then
         fii_util.start_timer;
      end if;
      LOAD_TIME_CAL_RPT_STRUCT(l_from_date, l_to_date);
      if g_debug_flag = 'Y' then
         fii_util.stop_timer;
         fii_util.print_timer('Process Time');
         fii_util.put_line(' ');
      end if;

      if g_day_row_cnt > 0 or
         l_validated = 'N' then

         g_phase := 'Load Reporting Structure Table';
         if g_debug_flag = 'Y' then
            fii_util.start_timer;
         end if;
         LOAD_TIME_RPT_STRUCT;
         if g_debug_flag = 'Y' then
            fii_util.stop_timer;
            fii_util.print_timer('Process Time');
            fii_util.put_line(' ');
         end if;

         g_phase := 'Load Time Structures Table';
         IF g_debug_flag = 'Y' THEN
            fii_util.start_timer;
         END IF;
         FII_TIME_STRUCTURE_C.LOAD_TIME_STRUCTURES;
         IF g_debug_flag = 'Y' THEN
            fii_util.stop_timer;
            fii_util.print_timer('Process Time');
            fii_util.put_line(' ');
         END IF;

      else

       begin
         select 1 into l_count
         from FII_TIME_STRUCTURES
         where bitand( record_type_id, 16384+32768+65536 ) <> 0
         and rownum = 1;
       exception
         when NO_DATA_FOUND then
           l_count := 0;
       end;

       -- No new rolling DSO periods detected
       if l_count = 0 then

         g_phase := 'Load Time Structures Table';
         IF g_debug_flag = 'Y' THEN
            fii_util.start_timer;
         END IF;
         FII_TIME_STRUCTURE_C.LOAD_TIME_STRUCTURES;
         IF g_debug_flag = 'Y' THEN
            fii_util.stop_timer;
            fii_util.print_timer('Process Time');
            fii_util.put_line(' ');
         END IF;

       end if;

      end if;

      l_count := 0;
      -- Bug 4966868: Changed not to count rows
      begin
        select 1 into l_count
        from fii_time_rolling_offsets
        where rownum = 1;
      exception
        when no_data_found then
          l_count := 0;
      end;

      if l_count = 0 then
         g_phase := 'Load Rolling Period Offsets Table';
         if g_debug_flag = 'Y' then
            fii_util.start_timer;
         end if;
         FII_TIME_ROLLING_PKG.Load_Rolling_Offsets(l_error_msg,l_error_code);
         if g_debug_flag = 'Y' then
            fii_util.stop_timer;
            fii_util.print_timer('Process Time');
            fii_util.put_line(' ');
         end if;
      end if;

      if g_day_row_cnt > 0 or
         l_validated = 'N' then

         g_phase := 'Gather statistics';
         if g_debug_flag = 'Y' then
            fii_util.start_timer;
         end if;

         -- note: we don't gather stats on FII_TIME_DAY
         -- as this should be done by RSG
         gather_table_stats('FII_TIME_MONTH');

         if g_debug_flag = 'Y' then
            fii_util.put_line('Gathered statistics for Month Level');
         end if;

         gather_table_stats('FII_TIME_QTR');

         if g_debug_flag = 'Y' then
            fii_util.put_line('Gathered statistics for Quarter Level');
         end if;

         gather_table_stats('FII_TIME_YEAR445');

         if g_debug_flag = 'Y' then
            fii_util.put_line('Gathered statistics for Period 445 Level');
         end if;

         IF g_debug_flag = 'Y' THEN
            fii_util.stop_timer;
            fii_util.print_timer('Process Time');
            fii_util.put_line(' ');
         END IF;

      end if;

   else

      truncate_table('FII_TIME_WEEK');
      truncate_table('FII_TIME_P445');
      truncate_table('FII_TIME_YEAR445');
      truncate_table('FII_TIME_ENT_PERIOD');
      truncate_table('FII_TIME_ENT_QTR');
      truncate_table('FII_TIME_ENT_YEAR');
      truncate_table('FII_TIME_CAL_PERIOD');
      truncate_table('FII_TIME_CAL_QTR');
      truncate_table('FII_TIME_CAL_YEAR');
      truncate_table('FII_TIME_RPT_STRUCT');
      truncate_table('FII_TIME_CAL_RPT_STRUCT');

      if g_debug_flag = 'Y' then
         fii_util.put_line(' ');
      end if;

   end if;

   ----------------------------------------------------------------
   -- Calling BIS API to record the range we load.  Only do this
   -- when we have a successful loading
   ----------------------------------------------------------------
   if g_all_level = 'Y' then

      BIS_COLLECTION_UTILITIES.wrapup
      ( p_status => TRUE
      , p_period_from => l_from_date
      , p_period_to => greatest( l_to_date
                               , fnd_date.displaydt_to_date
                                 ( bis_collection_utilities.get_last_refresh_period
                                   ('FII_DBI_TIME_M_F')
                                 )
                               )
      , p_attribute1 => 'Y'
      );

   else

      BIS_COLLECTION_UTILITIES.wrapup (p_status => TRUE,
                                       p_period_from => l_from_date,
                                       p_period_to => l_to_date);


   end if;

exception
   WHEN G_BIS_PARAMETER_NOT_SETUP THEN
      fii_util.put_line(fnd_message.get_string('FII', 'FII_BIS_PARAMETER_NOT_SETUP'));
      retcode := -1;
      rollback;
      if l_bis_setup = 'Y' then
         BIS_COLLECTION_UTILITIES.wrapup
         ( p_status => FALSE
         , p_message => fnd_message.get_string('FII', 'FII_BIS_PARAMETER_NOT_SETUP')
         );
       end if;
   WHEN G_LOGIN_INFO_NOT_FOUND THEN
      fii_util.put_line('Can not get User ID and Login ID, program exit');
      retcode := -1;
      rollback;
      if l_bis_setup = 'Y' then
         BIS_COLLECTION_UTILITIES.wrapup
         ( p_status => FALSE
         , p_message => 'Can not get User ID and Login ID, program exit'
         );
      end if;
   WHEN G_ENT_CALENDAR_NOT_FOUND THEN
      rollback;
      --Bug 3640141. Setting token as the message text has changed.
      fnd_message.set_name('FII','FII_ENT_CALENDAR_NOT_FOUND');
      fnd_message.set_token('DATE_NOT_DEFINED', fnd_date.date_to_displaydate(g_date_not_defined));
      l_mesg := fnd_message.get;
      fii_util.put_line(l_mesg);
      retcode := -1;
      if l_bis_setup = 'Y' then
          BIS_COLLECTION_UTILITIES.wrapup
          ( p_status => FALSE          , p_message => l_mesg);
      end if;
    WHEN G_YEAR_NOT_DEFINED THEN
      --Added for bug 4454026
      rollback;
      fnd_message.set_name('FII','FII_FISCAL_YEAR_NOT_DEFINED');
      fnd_message.set_token('YEAR', l_year);
      fnd_message.set_token('START_DATE', fnd_date.date_to_displaydate(l_min_start_date));
      fnd_message.set_token('END_DATE', fnd_date.date_to_displaydate(l_max_end_date));
      l_mesg := fnd_message.get;
      fii_util.put_line(l_mesg);
      retcode := -1;
      if l_bis_setup = 'Y' then
          BIS_COLLECTION_UTILITIES.wrapup
          ( p_status => FALSE          , p_message => l_mesg);
      end if;
   WHEN OTHERS THEN
      rollback;
      retcode := sqlcode;
      errbuf  := sqlerrm;
      fii_util.put_line(retcode||' : '||errbuf);
      fii_util.put_line('
-------------------------------------------
Error occured in Procedure: LOAD
Phase: ' || g_phase);
      if l_bis_setup = 'Y' then
         BIS_COLLECTION_UTILITIES.wrapup
         ( p_status => FALSE
         , p_message => substr(sqlerrm,1,4000)
         );
      end if;

end LOAD;

---------------------------------------------------
-- PUBLIC PROCEDURE LOAD_CAL_NAME
-- The procedure was changed to public per PJI's request
---------------------------------------------------
PROCEDURE LOAD_CAL_NAME IS

   -- ---------------------------------------------------------
   -- Define local variables
   -- ---------------------------------------------------------
   l_status             VARCHAR2(30);
   l_industry           VARCHAR2(30);
   l_name_row           number;
   l_max_cal_name       number;

   cursor new_cal is
	SELECT inline_view.period_set_name, inline_view.period_type, MAX(gp.creation_date)
	FROM (	SELECT DISTINCT glp.period_set_name , glp.period_type
		FROM	gl_periods glp
		MINUS
		SELECT	DISTINCT cal.period_set_name, cal.period_type
		FROM	fii_time_cal_name cal
	     ) inline_view,
	     gl_periods gp
	WHERE	inline_view.period_set_name = gp.period_set_name
		and inline_view.period_type = gp.period_type

	GROUP BY inline_view.period_set_name, inline_view.period_type
	ORDER BY MAX(gp.creation_date);

begin

   -- ---------------------------------------------------------
   -- Variable initialization
   -- ---------------------------------------------------------
   l_name_row    := 0;

   select nvl(max(calendar_id),0)
   into l_max_cal_name
   from fii_time_cal_name;

   if g_schema is null then
     IF(FND_INSTALLATION.GET_APP_INFO('FII', l_status, l_industry, g_schema)) THEN
       NULL;
     END IF;
   end if;

   -- ----------------------
   -- Populate Calendar Name Level
   -- ----------------------
   FOR new_cal_rec IN new_cal LOOP

      insert into fii_time_cal_name
      (calendar_id,
       period_set_name,
       period_type,
       name,
       creation_date,
       last_update_date,
       last_updated_by,
       created_by,
       last_update_login)
      values(
       l_max_cal_name+1,
       new_cal_rec.period_set_name,
       new_cal_rec.period_type,
       new_cal_rec.period_set_name||' ('||new_cal_rec.period_type||')',
       sysdate,
       sysdate,
       g_user_id,
       g_user_id,
       g_login_id);

       l_max_cal_name := l_max_cal_name+1;
       l_name_row := l_name_row+1;

   end loop;

   commit;

   if g_debug_flag = 'Y' then
      fii_util.put_line('LOAD_CAL_NAME : '||to_char(l_name_row)||' records has been populated to Calendar Name Level');
   end if;

   if l_name_row > 0 then

      gather_table_stats('FII_TIME_CAL_NAME');

      if g_debug_flag = 'Y' then
         fii_util.put_line('LOAD_CAL_NAME : '||'Gathered statistics for Calendar Name Level');
      end if;

   end if;

end LOAD_CAL_NAME;

---------------------------------------------------
-- PUBLIC PROCEDURE LOAD_TIME_RPT_STRUCT
-- the from and to dates are actually ignored.
---------------------------------------------------
PROCEDURE LOAD_TIME_RPT_STRUCT(p_from_date in date, p_to_date in date) IS

begin

   INIT;

   LOAD_TIME_RPT_STRUCT;

end LOAD_TIME_RPT_STRUCT;

---------------------------------------------------
-- PRIVATE PROCEDURE LOAD_TIME_RPT_STRUCT
---------------------------------------------------
PROCEDURE LOAD_TIME_RPT_STRUCT IS

-- ---------------------------------------------------------
-- Define local variables
-- ---------------------------------------------------------
   --l_from_date         date;
   --l_to_date           date;
   l_day               date;
   l_week_start_date   date;
   l_ptd_to_date       date;
   l_period_start_date date;
   l_row               number;

--* We should do a full refresh for FII_TIME_RPT_STRUCT
   -- Bug 5624487
   cursor c1 is
     select report_date, ent_period_start_date, ent_qtr_start_date,
            ent_year_start_date, week_start_date
     from   FII_TIME_DAY
     where report_date <> g_unassigned_day;
--*this would be incorrect:   where report_date between l_from_date and l_to_date

begin

   truncate_table('FII_TIME_RPT_STRUCT');

   l_row       := 0;
   --l_from_date := trunc(nvl(p_from_date,trunc(add_months(sysdate,-24),'YYYY')));
   --l_to_date   := trunc(nvl(p_to_date,trunc(sysdate,'YYYY')));

   FOR c1_rec IN c1 LOOP
      insert into FII_TIME_RPT_STRUCT
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
               insert into FII_TIME_RPT_STRUCT
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
               select nvl(min(start_date),l_week_start_date) into l_ptd_to_date from FII_TIME_WEEK
               where start_date >= l_period_start_date
               and start_date < l_week_start_date;

               if l_day < l_ptd_to_date then
                  insert into FII_TIME_RPT_STRUCT
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
               insert into FII_TIME_RPT_STRUCT
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

      insert into FII_TIME_RPT_STRUCT
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
      from FII_TIME_WEEK
      where start_date >= c1_rec.ent_period_start_date
      and end_date < c1_rec.week_start_date
      union all
      select
       -1,
       'E',
       c1_rec.report_date,
       week_id,
       16,
       2048,
       sysdate,
       sysdate,
       g_user_id,
       g_user_id,
       g_login_id
      from FII_TIME_WEEK
      where c1_rec.report_date between start_date and end_date;

      l_row := l_row + sql%rowcount;

      commit;

      insert into FII_TIME_RPT_STRUCT
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
      from FII_TIME_ENT_PERIOD
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
       sysdate,
       sysdate,
       g_user_id,
       g_user_id,
       g_login_id
      from FII_TIME_ENT_PERIOD
      where start_date >= c1_rec.ent_qtr_start_date
      and start_date <= c1_rec.ent_period_start_date
      and end_date >= c1_rec.report_date;

      l_row := l_row + sql%rowcount;

      commit;

      insert into FII_TIME_RPT_STRUCT
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
      from FII_TIME_ENT_QTR
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
      from FII_TIME_ENT_QTR
      where start_date >= c1_rec.ent_year_start_date
      and start_date <= c1_rec.ent_qtr_start_date
      and end_date >= c1_rec.report_date;

      l_row := l_row + sql%rowcount;

      commit;

      insert into FII_TIME_RPT_STRUCT
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
      from FII_TIME_ENT_YEAR
      where c1_rec.report_date between start_date and end_date;

      l_row := l_row + sql%rowcount;

      commit;

-- All prior years (report_type: 1024), for ITD
      insert into FII_TIME_RPT_STRUCT
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
      from FII_TIME_ENT_YEAR
      where end_date  >=  g_global_start_date      -- should we use start_date?
        and end_date  <   c1_rec.report_date;

      l_row := l_row + sql%rowcount;

      commit;

   END LOOP; -- c1_rec

   if g_debug_flag = 'Y' then
      fii_util.put_line('LOAD_TIME_RPT_STRUCT :'||to_char(l_row)||' records has been populated to the Reporting Structure table');
   end if;

   gather_table_stats('FII_TIME_RPT_STRUCT');

   if g_debug_flag = 'Y' then
      fii_util.put_line('LOAD_TIME_RPT_STRUCT :'||'Gathered statistics for the Reporting Structure table');
   end if;

end LOAD_TIME_RPT_STRUCT;


---------------------------------------------------
-- PUBLIC PROCEDURE LOAD_TIME_CAL_RPT_STRUCT
---------------------------------------------------
PROCEDURE LOAD_TIME_CAL_RPT_STRUCT(p_from_date in date, p_to_date in date) IS

-- ---------------------------------------------------------
-- Define local variables
-- ---------------------------------------------------------
   l_Day              DATE;
   l_Week_Start_Date  DATE;
   l_Earliest_Week    DATE;
   l_Row              NUMBER:=0;
   l_No_Week_Info     VARCHAR2(1):='N';
   l_from_date        DATE:=p_from_date;
   l_to_date          DATE:=p_to_date;
   l_full_extraction_flag	varchar2(1);
   l_max_date_v		varchar2(100);
   l_min_date		date;
   l_max_date		date;

begin

    --Bug 3543939. Get the minimum from date and maximum to date
    SELECT nvl(least(min(report_date),l_from_date),l_from_date),nvl(greatest(max(report_date),l_to_date),l_to_date)
    INTO   l_min_date,l_max_date
    from   FII_TIME_CAL_RPT_STRUCT;

   --Bug 3543939. The Calendar id's to be picked from the temporary table populated in Load_Cal_Period

   For cur_Fiscal_Calendar IN (
         SELECT distinct calendar_id
	 FROM fii_time_cal_gt) LOOP

        --Reset the l_from_date and l_to_date to the parameters passed

        l_from_date:=p_from_date;
	l_to_date:=p_to_date;

        --Check if the from date has been already extracted

          BEGIN

		SELECT 'T'
		INTO l_full_extraction_flag
		FROM FII_TIME_CAL_RPT_STRUCT
		WHERE REPORT_DATE >= p_from_date
		AND CALENDAR_ID = cur_Fiscal_Calendar.CALENDAR_ID
		AND ROWNUM <= 1;
	  EXCEPTION
		WHEN NO_DATA_FOUND THEN
		l_full_extraction_flag := 'F';
	  END;


	  IF l_full_extraction_flag = 'T' THEN

		-- Delete all records for the calendar
		-- and reset the from and to date for
                -- extraction

		DELETE FII_TIME_CAL_RPT_STRUCT
		WHERE CALENDAR_ID = cur_Fiscal_Calendar.CALENDAR_ID;
		l_from_date := l_min_date;
		l_to_date := l_max_date;

	  END IF;

      FOR cur_Fiscal_Days IN (
          SELECT calendar_id
          , report_date
          , cal_period_start_date period_start_date
          , cal_qtr_start_date qtr_start_date
          , cal_year_start_date year_start_date
          FROM fii_time_cal_day_mv
          WHERE  calendar_id = cur_Fiscal_Calendar.calendar_id
          AND report_date BETWEEN l_from_date AND l_to_date) LOOP

         INSERT INTO FII_TIME_CAL_RPT_STRUCT
         ( calendar_id
         , calendar_type
         , report_date
         , time_id
         , period_type_id
         , record_type_id
         , creation_date
         , last_update_date
         , last_updated_by
         , created_by
         , last_update_login)
         VALUES
         (cur_Fiscal_Days.calendar_id
         , 'C'
         , cur_Fiscal_Days.report_date
         , TO_CHAR(cur_Fiscal_Days.report_date,'j')
         , 1
         , 1
         , SYSDATE
         , SYSDATE
         , g_user_id
         , g_user_id
         , g_login_id);

         l_Row := l_Row + SQL%ROWCOUNT;

         COMMIT;

         l_Day := cur_Fiscal_Days.report_date-1;

         BEGIN
             SELECT week_start_date
             INTO l_Week_Start_Date
             FROM fii_time_day
             WHERE report_date = cur_Fiscal_Days.report_date;

             l_No_Week_Info := 'N';

         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               l_No_Week_Info := 'Y';
         END;

         IF l_No_Week_Info ='N' THEN
            SELECT NVL(MIN(start_date),l_Week_Start_Date)
            INTO l_Earliest_Week
            FROM fii_time_week
            WHERE start_date >= cur_Fiscal_Days.period_start_date
            AND start_date < l_Week_Start_Date;

            WHILE l_Day >= cur_Fiscal_Days.period_start_date LOOP
               IF l_Day >= l_Week_Start_Date THEN
                  INSERT INTO FII_TIME_CAL_RPT_STRUCT
                  ( calendar_id
                  , calendar_type
                  , report_date
                  , time_id
                  , period_type_id
                  , record_type_id
                  , creation_date
                  , last_update_date
                  , last_updated_by
                  , created_by
                  , last_update_login)
                  VALUES
                  (cur_Fiscal_Days.calendar_id
                  , 'C'
                  , cur_Fiscal_Days.report_date
                  , TO_CHAR(l_Day,'j')
                  , 1
                  , 2
                  , SYSDATE
                  , SYSDATE
                  , g_user_id
                  , g_user_id
                  , g_login_id);

                  l_Row := l_Row + SQL%ROWCOUNT;

               ELSIF l_Day >= cur_Fiscal_Days.period_start_date AND l_Day < l_Earliest_Week THEN
                  INSERT INTO FII_TIME_CAL_RPT_STRUCT
                  ( calendar_id
                  , calendar_type
                  , report_date
                  , time_id
                  , period_type_id
                  , record_type_id
                  , creation_date
                  , last_update_date
                  , last_updated_by
                  , created_by
                  , last_update_login)
                  VALUES
                  (cur_Fiscal_Days.calendar_id
                  , 'C'
                  , cur_Fiscal_Days.report_date
                  , TO_CHAR(l_Day,'j')
                  , 1
                  , 4
                  , SYSDATE
                  , SYSDATE
                  , g_user_id
                  , g_user_id
                  , g_login_id);

                  l_Row := l_Row + SQL%ROWCOUNT;
               END IF;

               l_Day := l_Day-1;

            END LOOP;

            COMMIT;

            INSERT INTO FII_TIME_CAL_RPT_STRUCT
            ( calendar_id
            , calendar_type
            , report_date
            , time_id
            , period_type_id
            , record_type_id
            , creation_date
            , last_update_date
            , last_updated_by
            , created_by
            , last_update_login)
            SELECT
            cur_Fiscal_Days.calendar_id
            , 'E'
            , cur_Fiscal_Days.report_date
            , week_id
            , 16
            , 16
            , SYSDATE
            , SYSDATE
            , g_user_id
            , g_user_id
            , g_login_id
            FROM FII_TIME_WEEK
            WHERE start_date >= cur_Fiscal_Days.period_start_date
            AND end_date < l_Week_Start_Date;

            l_Row := l_Row + SQL%ROWCOUNT;

            COMMIT;

         ELSE
            INSERT INTO FII_TIME_CAL_RPT_STRUCT
            ( calendar_id
            , calendar_type
            , report_date
            , time_id
            , period_type_id
            , record_type_id
            , creation_date
            , last_update_date
            , last_updated_by
            , created_by
            , last_update_login)
            SELECT
            cur_Fiscal_Days.calendar_id
            , 'C'
            , cur_Fiscal_Days.report_date
            , report_date_julian
            , 1
            , 4
            , SYSDATE
            , SYSDATE
            , g_user_id
            , g_user_id
            , g_login_id
            FROM FII_TIME_CAL_DAY_MV
            WHERE calendar_id = cur_Fiscal_Days.calendar_id
            AND report_date BETWEEN cur_Fiscal_Days.period_start_date AND l_Day;

            l_Row := l_Row + SQL%ROWCOUNT;

            COMMIT;
         END IF;

         INSERT INTO FII_TIME_CAL_RPT_STRUCT
         ( calendar_id
         , calendar_type
         , report_date
         , time_id
         , period_type_id
         , record_type_id
         , creation_date
         , last_update_date
         , last_updated_by
         , created_by
         , last_update_login)
         SELECT
         cur_Fiscal_Days.calendar_id
         , 'G'
         , cur_Fiscal_Days.report_date
         , cal_period_id
         , 32
         , 32
         , SYSDATE
         , SYSDATE
         , g_user_id
         , g_user_id
         , g_login_id
         FROM FII_TIME_CAL_PERIOD
         WHERE start_date >= cur_Fiscal_Days.qtr_start_date
         AND start_date <= cur_Fiscal_Days.period_start_date
         AND end_date < cur_Fiscal_Days.report_date
         AND calendar_id = cur_Fiscal_Days.calendar_id
         UNION ALL
         SELECT
         cur_Fiscal_Days.calendar_id
         , 'G'
         , cur_Fiscal_Days.report_date
         , cal_period_id
         , 32
         , 256
         , SYSDATE
         , SYSDATE
         , g_user_id
         , g_user_id
         , g_login_id
         FROM FII_TIME_CAL_PERIOD
         WHERE start_date >= cur_Fiscal_Days.qtr_start_date
         AND start_date <= cur_Fiscal_Days.period_start_date
         AND end_date >= cur_Fiscal_Days.report_date
         AND calendar_id = cur_Fiscal_Days.calendar_id;

         l_Row := l_Row + SQL%ROWCOUNT;

         COMMIT;

         INSERT INTO FII_TIME_CAL_RPT_STRUCT
         ( calendar_id
         , calendar_type
         , report_date
         , time_id
         , period_type_id
         , record_type_id
         , creation_date
         , last_update_date
         , last_updated_by
         , created_by
         , last_update_login)
         SELECT
         cur_Fiscal_Days.calendar_id
         , 'G'
         , cur_Fiscal_Days.report_date
         , cal_qtr_id
         , 64
         , 64
         , SYSDATE
         , SYSDATE
         , g_user_id
         , g_user_id
         , g_login_id
         FROM FII_TIME_CAL_QTR
         WHERE start_date >= cur_Fiscal_Days.year_start_date
         AND start_date <= cur_Fiscal_Days.qtr_start_date
         AND end_date < cur_Fiscal_Days.report_date
         AND calendar_id = cur_Fiscal_Days.calendar_id
         UNION ALL
         SELECT
         cur_Fiscal_Days.calendar_id
         , 'G'
         , cur_Fiscal_Days.report_date
         , cal_qtr_id
         , 64
         , 512
         , SYSDATE
         , SYSDATE
         , g_user_id
         , g_user_id
         , g_login_id
         FROM FII_TIME_CAL_QTR
         WHERE start_date >= cur_Fiscal_Days.year_start_date
         AND start_date <= cur_Fiscal_Days.qtr_start_date
         AND end_date >= cur_Fiscal_Days.report_date
         AND calendar_id = cur_Fiscal_Days.calendar_id;

         l_Row := l_Row + SQL%ROWCOUNT;

         COMMIT;

         INSERT INTO FII_TIME_CAL_RPT_STRUCT
         ( calendar_id
         , calendar_type
         , report_date
         , time_id
         , period_type_id
         , record_type_id
         , creation_date
         , last_update_date
         , last_updated_by
         , created_by
         , last_update_login)
         SELECT
           cur_Fiscal_Days.calendar_id
         , 'G'
         , cur_Fiscal_Days.report_date
         , cal_year_id
         , 128
         , 128
         , SYSDATE
         , SYSDATE
         , g_user_id
         , g_user_id
         , g_login_id
         FROM FII_TIME_CAL_YEAR
         WHERE calendar_id = cur_Fiscal_Days.calendar_id
         AND cur_Fiscal_Days.report_date BETWEEN start_date AND end_date
         UNION ALL
         SELECT
           cur_Fiscal_Days.calendar_id
         , 'G'
         , cur_Fiscal_Days.report_date
         , cal_year_id
         , 128
         , 1024
         , SYSDATE
         , SYSDATE
         , g_user_id
         , g_user_id
         , g_login_id
         FROM FII_TIME_CAL_YEAR
         WHERE calendar_id = cur_Fiscal_Days.calendar_id
         AND end_date < cur_Fiscal_Days.report_date
         AND end_date  >=  g_global_start_date;

         l_Row := l_Row + SQL%ROWCOUNT;

         COMMIT;

      END LOOP;

   END LOOP;

   IF g_debug_flag = 'Y' THEN
      fii_util.put_line('LOAD_TIME_CAL_RPT_STRUCT : '||TO_CHAR(l_row)||' records has been populated to the Reporting Structure table for Financial Calendars');
   END IF;

   if l_row > 0 then

      gather_table_stats('FII_TIME_CAL_RPT_STRUCT');

      if g_debug_flag = 'Y' then
         fii_util.put_line('LOAD_TIME_CAL_RPT_STRUCT :'||'Gathered statistics for Financial Calendars');
      end if;

   end if;

end LOAD_TIME_CAL_RPT_STRUCT;

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
     if check_validated = 'Y' then
        l_return_date := least(fnd_date.displaydt_to_date
                         ( bis_collection_utilities.get_last_refresh_period
                           ('FII_DBI_TIME_M')
                         ) +1, fnd_date.displaydt_to_date(DEFAULT_LOAD_TO_DATE));
     else
        l_return_date := bis_common_parameters.get_global_start_date;
     end if;
   else
      select least(nvl(min(start_date),bis_common_parameters.get_global_start_date) , bis_common_parameters.get_global_start_date) into l_return_date
      from fii_time_day;
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
   l_period_set_name varchar2(15) := bis_common_parameters.get_period_set_name;
   l_period_type varchar2(15) := bis_common_parameters.get_period_type;

begin

   select max(end_date)
   into l_return_date
   from gl_periods
   where adjustment_period_flag = 'N'
   and period_set_name = l_period_set_name
   and period_type = l_period_type;

   return fnd_date.date_to_displaydt(l_return_date);

end DEFAULT_LOAD_TO_DATE;

END FII_TIME_C;

/

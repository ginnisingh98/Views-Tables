--------------------------------------------------------
--  DDL for Package Body FND_CONC_SSWA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_CONC_SSWA" as
/* $Header: AFCPSSUB.pls 120.5.12010000.5 2015/07/31 20:55:30 ckclark ship $ */


--
-- Package
--   FND_CONC_SSWA
-- Purpose
--   Utilities for the Concurrent SelfService Web Applications
-- History
  --
  -- PRIVATE VARIABLES
  --

  -- Global request_id for use in multiple calls
  g_request_id number;

  -- Global argument counter
  g_arg_count  number;

 TYPE map_record_type is record
           ( attributeno  number,
             enabled    varchar2(1),
             argument varchar2(240)
           );

  TYPE map_tab_type is table of map_record_type
             index by binary_integer;

  attr_to_arg map_tab_type;

  req_phase  varchar2(80);
  req_status varchar2(80);
  req_status_code varchar2(1);
  ran_get_phase  number := -1;
  ran_get_status number := -1;

  TYPE args_array IS varray(100) OF VARCHAR2(240);


  -- Exceptions

  -- Exception Pragmas

  --
  -- Name
  --   map_attr_to_arg
  -- Purpose
  --   Maps the application column name attribute in fnd_concurrent requests
  --   to the enabled arguments of the program's desc flexfield



function map_attr_to_arg(attrno in number,
                           reqid in number) return varchar2 is
  app_id number;
  has_args varchar2(1);
  attr_counter number := 1;
  arg_counter number;
  max_attr number;
  last_attr_disabled number := 0;
  prog_short_name varchar(30);
  loop_count number := 0;
  flex_name  varchar2(40);

  args args_array := args_array(CHR(0), CHR(0), CHR(0), CHR(0),
                                CHR(0), CHR(0), CHR(0), CHR(0),
                                CHR(0), CHR(0), CHR(0), CHR(0),
                                CHR(0), CHR(0), CHR(0), CHR(0),
                                CHR(0), CHR(0), CHR(0), CHR(0),
                                CHR(0), CHR(0), CHR(0), CHR(0),
                                CHR(0), CHR(0), CHR(0), CHR(0),
                                CHR(0), CHR(0), CHR(0), CHR(0),
                                CHR(0), CHR(0), CHR(0), CHR(0),
                                CHR(0), CHR(0), CHR(0), CHR(0),
                                CHR(0), CHR(0), CHR(0), CHR(0),
                                CHR(0), CHR(0), CHR(0), CHR(0),
                                CHR(0), CHR(0), CHR(0), CHR(0),
                                CHR(0), CHR(0), CHR(0), CHR(0),
                                CHR(0), CHR(0), CHR(0), CHR(0),
                                CHR(0), CHR(0), CHR(0), CHR(0),
                                CHR(0), CHR(0), CHR(0), CHR(0),
                                CHR(0), CHR(0), CHR(0), CHR(0),
                                CHR(0), CHR(0), CHR(0), CHR(0),
                                CHR(0), CHR(0), CHR(0), CHR(0),
                                CHR(0), CHR(0), CHR(0), CHR(0),
                                CHR(0), CHR(0), CHR(0), CHR(0),
                                CHR(0), CHR(0), CHR(0), CHR(0),
                                CHR(0), CHR(0), CHR(0), CHR(0),
                                CHR(0), CHR(0), CHR(0), CHR(0));
  cursor c_attrs is
         select  to_number(substr(application_column_name,10)) ,enabled_flag
           from fnd_descr_flex_column_usages
          where application_id = app_id
            and descriptive_flexfield_name = flex_name
          order by column_seq_num;
  begin


    if (attrno > 100) then
       return '';
    end if;

    -- the argument is already calculated
    if (g_request_id is NOT NULL and g_request_id = reqid) then
      return attr_to_arg(attrno).argument;
    end if;

    -- set g_request_id
    g_request_id := reqid;

    -- check if there are more than 25 argument
    select count(*) into g_arg_count
      from fnd_conc_request_arguments
     where request_id = reqid;

    -- clear global array
    attr_counter := 1;

    loop_count := attr_to_arg.COUNT;
    while (attr_counter <= loop_count) loop
        attr_to_arg.delete(attr_counter);
        attr_counter := attr_counter + 1;
    end loop;

    select r.program_application_id , p.concurrent_program_name
      into app_id, prog_short_name
      from fnd_concurrent_requests r, fnd_concurrent_programs p
     where r.request_id = reqid
       and r.concurrent_program_id = p.concurrent_program_id
       and r.program_application_id = p.application_id;

    -- if program has no arguments
    has_args := program_has_args(prog_short_name, app_id);
    if (has_args = 'N') then
       return '';
    end if;

    attr_counter := 1;

	flex_name := '$SRS$.' || prog_short_name;

    if (attr_to_arg.COUNT = 0 OR attr_to_arg.COUNT is null) then
       open c_attrs;
       loop
          fetch c_attrs
          into attr_to_arg(attr_counter).attributeno,
               attr_to_arg(attr_counter).enabled;
          exit when (c_attrs%NOTFOUND
                     or (c_attrs%NOTFOUND is null)
                     or (g_arg_count = 0 AND attr_counter > 24)
                     or (attr_counter > 100));
          attr_counter := attr_counter + 1;
       end loop;
       close c_attrs;

       max_attr := attr_counter;

       -- Set enabled to N for remaining elements of the map table
       -- up to maximum possible request arguments (24 or 100)
       while ((g_arg_count = 0 AND attr_counter <= 24) OR (attr_counter <= 100)) loop
               attr_to_arg(attr_counter).enabled := 'N';
               attr_counter := attr_counter + 1;
       end loop;

       select argument1, argument2, argument3, argument4,
                argument5, argument6, argument7, argument8,
                argument9, argument10, argument11, argument12,
                argument13, argument14, argument15, argument16,
                argument17, argument18, argument19, argument20,
                argument21, argument22, argument23, argument24,
                argument25
           into args(1), args(2), args(3), args(4),
                args(5), args(6), args(7), args(8),
                args(9), args(10), args(11), args(12),
                args(13), args(14), args(15), args(16),
                args(17), args(18), args(19), args(20),
                args(21), args(22), args(23), args(24),
                args(25)
           from fnd_concurrent_requests
          where request_id = reqid;

       if (g_arg_count <> 0) then
         select argument26,argument27,argument28,
                argument29,argument30,argument31,argument32,argument33,
                argument34,argument35,argument36,argument37,argument38,
                argument39,argument40,argument41,argument42,argument43,
                argument44,argument45,argument46,argument47,argument48,
                argument49,argument50,argument51,argument52,argument53,
                argument54,argument55,argument56,argument57,argument58,
                argument59,argument60,argument61,argument62,argument63,
                argument64,argument65,argument66,argument67,argument68,
                argument69,argument70,argument71,argument72,argument73,
                argument74,argument75,argument76,argument77,argument78,
                argument79,argument80,argument81,argument82,argument83,
                argument84,argument85,argument86,argument87,argument88,
                argument89,argument90,argument91,argument92,argument93,
                argument94,argument95,argument96,argument97,argument98,
                argument99,argument100
           into args(26),args(27),args(28),args(29),args(30),
                args(31),args(32),args(33),args(34),args(35),
                args(36),args(37),args(38),args(39),args(40),
                args(41),args(42),args(43),args(44),args(45),
                args(46),args(47),args(48),args(49),args(50),
                args(51),args(52),args(53),args(54),args(55),
                args(56),args(57),args(58),args(59),args(60),
                args(61),args(62),args(63),args(64),args(65),
                args(66),args(67),args(68),args(69),args(70),
                args(71),args(72),args(73),args(74),args(75),
                args(76),args(77),args(78),args(79),args(80),
                args(81),args(82),args(83),args(84),args(85),
                args(86),args(87),args(88),args(89),args(90),
                args(91),args(92),args(93),args(94),args(95),
                args(96),args(97),args(98),args(99),args(100)
           from fnd_conc_request_arguments
          where request_id = reqid;
       end if;

       last_attr_disabled := 0;
       arg_counter := 1;
       loop
    attr_counter := attr_to_arg(arg_counter).attributeno;
          if (attr_to_arg(arg_counter).enabled = 'Y') then
        attr_to_arg(attr_counter).argument := args(arg_counter-last_attr_disabled);
          else
        if (arg_counter < max_attr) then
          -- the attrubute exits but is disabled
                attr_to_arg(attr_counter).argument := '';
          last_attr_disabled := last_attr_disabled+1;
        else
          -- the attribute doesn't exist
          attr_to_arg(arg_counter).argument := '';
        end if;
          end if;
    arg_counter := arg_counter + 1;
    exit when ((g_arg_count = 0 AND arg_counter > 24) OR (arg_counter > 100));
       end loop;
      end if;
      return attr_to_arg(attrno).argument;
  end;



  --
  -- Name
  --   get_phase_and_status
  -- Purpose
  --   Used by get_phase and get_status to get the
  --   phase and status descriptions.
  --
  procedure get_phase_and_status(pcode  in char,
                                 scode  in char,
                                 hold   in char,
                                 enbld  in char,
                                 stdate in date,
                                 rid    in number) is
    upcode varchar2(1);

  begin

    fnd_conc_request_pkg.get_phase_status(pcode, scode, hold, enbld,
			                  null, stdate, rid,
					  req_phase, req_status,
					  upcode, req_status_code);

  end get_phase_and_status;

  --
  -- Name
  --   get_phase
  -- Purpose
  --   Returns a translated phase description.
  --
  function get_phase (pcode  in char,
                       scode  in char,
                       hold   in char,
                       enbld  in char,
                       stdate in date,
                       rid    in number) return varchar2 is

  begin


    /* Did we already run get_status for this request?
     * If so, then return the cached phase value.
     */
    if (ran_get_status = rid) then
      ran_get_status := -1;
      return req_phase;
    end if;

    /* Get phase and status.  Return phase. */
    get_phase_and_status(pcode, scode, hold, enbld, stdate, rid);
    ran_get_phase := rid;

    return req_phase;

  exception
    when others then
      return 'ORA'||SQLCODE;
  end;



  --
  -- Name
  --   get_sswa_status
  -- Purpose
  --   Returns status code as 'C', 'W','E'.
  --
  function get_sswa_status (pcode  in char,
                 scode  in char,
           hold   in char,
                 enbld  in char,
                 stdate in date,
                 rid    in number) return varchar2 is
  begin
    /* Did we already run get_phase for this request?
     * If so, then return the cached status value.
     */
    if (ran_get_phase = rid) then
      ran_get_phase := -1;
      return req_status_code;
    end if;

    /* Get phase and status.  Return status. */
    get_phase_and_status(pcode, scode, hold, enbld, stdate, rid);
    ran_get_status := rid;
    return req_status_code;

  exception
    when others then
      return 'ORA'||SQLCODE;
  end;

  --
  -- Name
  --   get_status
  -- Purpose
  --   Returns status description for sswa.
  --
  function get_status (pcode  in char,
                       scode  in char,
                       hold   in char,
                       enbld  in char,
                       stdate in date,
                       rid    in number) return varchar2 is
  begin
    /* Did we already run get_phase for this request?
     * If so, then return the cached status value.
     */
    if (ran_get_phase = rid) then
      ran_get_phase := -1;
      return req_status;
    end if;

    /* Get phase and status.  Return status. */
    get_phase_and_status(pcode, scode, hold, enbld, stdate, rid);
    ran_get_status := rid;
    return req_status;

  exception
    when others then
      return 'ORA'||SQLCODE;
  end;

   -- private function to get the short schedule description
   -- This function is copied from FNDRSRUN form

   function build_short_schedule (schedule_type varchar2,
                                 schedule_name varchar2,
                                 date1 date,
                                 date2 date,
               class_info varchar2,
                                 req_id number
        ) return varchar2 is
     a varchar2(2000) := null;
     my_schedule_name  varchar2(80);
     interval number := null;
     int_unit varchar2(30) := null;
     cnt number;
	 ltype varchar2(32);

-- variables used for determining the description for advance scheduling
    weekday_spec  boolean := false;   -- if true weekday is specified in map
    date_spec     boolean := false;   -- if true date is specified in map
    month_map   Varchar2(12) ;    -- month bit fields
    date_map    Varchar2(32) ;    -- date bit fields
    weekday_map   Varchar2(7) ;   -- week days bit fields
    weekno_map    Varchar2(5) ;   -- week no bit fields
    month_msg   Varchar2(128) ;   -- message for month part
    date_msg    Varchar2(128) ;   -- message for date part
    weekday_msg   Varchar2(128) ;   -- message for week days part
    added     boolean := false; -- used across no of loops to fill comma in message string

    TYPE temp_record_type is record
           (
	   meaning    varchar2(80)
           );
    temp_record temp_record_type;
    rec_count number;
    TYPE month_array   IS varray(12) OF fnd_lookup_values.meaning%TYPE;
    TYPE week_array    IS varray(6)  OF fnd_lookup_values.meaning%TYPE;
    TYPE weekday_array IS varray(7)  OF fnd_lookup_values.meaning%TYPE;
--  months month_array := month_array('Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec');
--  weeks week_array := week_array('First ', 'Second ', 'Third ', 'Fourth ', 'Last ');
--  weekdays weekday_array := weekday_array('Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat');

    -- Initialize these arrays
    months month_array := month_array(CHR(0), CHR(0), CHR(0), CHR(0), CHR(0),CHR(0), CHR(0), CHR(0), CHR(0), CHR(0), CHR(0), CHR(0));
    weeks week_array := week_array(CHR(0), CHR(0), CHR(0), CHR(0), CHR(0), CHR(0));
    weekdays weekday_array := weekday_array(CHR(0), CHR(0), CHR(0), CHR(0), CHR(0), CHR(0), CHR(0));

   begin

     -- get values for weeks array from lookup FND_SCH_WEEKDAY_TYPE
	 rec_count := 1;
	 ltype := 'FND_SCH_WEEKDAY_TYPE';
     FOR temp_record IN (SELECT meaning
                      FROM fnd_lookup_values_vl
		       WHERE lookup_type = ltype
		       ORDER BY to_number(lookup_code)) LOOP
       weeks(rec_count) := temp_record.meaning;
       rec_count  := rec_count + 1;
     END LOOP;

     -- get values for weekdays array from lookup FND_SCH_WEEK_DAYS
	 rec_count := 1;
	 ltype := 'FND_SCH_WEEK_DAYS';
     FOR temp_record IN (SELECT meaning
                      FROM fnd_lookup_values_vl
		       WHERE lookup_type = ltype
		       ORDER BY to_number(lookup_code)) LOOP
       weekdays(rec_count) := temp_record.meaning;
       rec_count  := rec_count + 1;
     END LOOP;

     -- get values for months array from lookup FND_SCH_MONTHS
	 rec_count := 1;
	 ltype := 'FND_SCH_MONTHS';
     FOR temp_record IN (SELECT meaning
                      FROM fnd_lookup_values_vl
		       WHERE lookup_type = ltype
		       ORDER BY to_number(lookup_code)) LOOP
       months(rec_count) := temp_record.meaning;
       rec_count  := rec_count + 1;
     END LOOP;

     my_schedule_name := schedule_name;


     /* If this is a temp schedule, erase the name */
     SELECT COUNT(*)
       into cnt
       from FND_CONC_RELEASE_CLASSES
      WHERE OWNER_REQ_ID is not null
        AND RELEASE_CLASS_NAME = schedule_name
        AND rownum < 2;

     if cnt>0 then
    my_schedule_name := null;
     end if;

     if (schedule_type in ('A', 'O'))  then
       fnd_message.set_name('FND', 'SCH-NO RECURRENCE');
       a := fnd_message.get;
     elsif schedule_type = 'P' then
       if my_schedule_name is null then
         select resubmit_interval, resubmit_interval_unit_code
           into interval, int_unit
           from fnd_concurrent_requests
          where request_id = req_id;
         if date2 is null then
           fnd_message.set_name('FND','SCH-PERIODIC NO END DATE');
           fnd_message.set_token('UNIT_INTERVAL', to_char(interval));
           fnd_message.set_token('UNIT_TYPE', int_unit );
         else
           fnd_message.set_name('FND','SCH-PERIODIC WITH END DATE');
           fnd_message.set_token('UNIT_INTERVAL', to_char(interval));
           fnd_message.set_token('UNIT_TYPE', int_unit );
           fnd_message.set_token('END_DATE',to_char(date2));
         end if;
       else
         fnd_message.set_name('FND','SCH-PERIODIC');
         fnd_message.set_token('SCH_NAME', my_schedule_name);
       end if;
       a := fnd_message.get;
     elsif schedule_type = 'S' then
     begin -- schedule_type = 'S'
     -- either 39 char map or 56 char map
       if (LENGTH(class_info) = 39) then
       if my_schedule_name is null then
         if date2 is null then
           fnd_message.set_name('FND','SCH-SPECIFIC START');
           fnd_message.set_token('DATE',to_char(date1));
         else
           fnd_message.set_name('FND','SCH-SPECIFIC RANGE');
           fnd_message.set_token('DATE1',to_char(date1));
           fnd_message.set_token('DATE2',to_char(date2));
         end if;
       else
         fnd_message.set_name('FND','SCH-SPECIFIC');
         fnd_message.set_token('SCH_NAME', my_schedule_name);
       end if;
       a := fnd_message.get || ': ';

       for cnt in  1..39 loop
         if substr(class_info, cnt, 1) = '1' then
            a := a || to_char(cnt) || ' ';
         end if;
       end loop;
    else -- handle advance schedule of 56 char map
      month_map := SUBSTR(class_info,45);
      date_map := SUBSTR(class_info,1,32);
      weekday_map := SUBSTR(class_info,33,7);
      weekno_map := SUBSTR(class_info,40,5);

      if (month_map = '111111111111') then
        -- all months specified
        month_msg := month_msg || 'All Months';
      else
        for cnt in 1..12 loop
          if ((SUBSTR(month_map, cnt,1) = '1')) then
            if (added = true) then
              month_msg := month_msg || ',';
            end if;

            month_msg := month_msg || months(cnt);
            added := true;
          end if;
        end loop;
      end if;

      if (INSTR(date_map,'1') <> 0) then
        date_spec := true;
        added := false;
        for cnt in 1..31 loop
          if (SUBSTR(date_map,cnt,1) = '1') then
            if (added = true) then
              date_msg := date_msg || ',';
            end if;

            date_msg := date_msg || TO_CHAR(cnt);
            added := true;
          end if;
        end loop;

        if (SUBSTR(date_map,32) = '1') then
          if (added = true) then
            date_msg := date_msg || ',';
          end if;

          date_msg := date_msg || 'Last day of month';
        end if;
      end if;

      if (INSTR(weekday_map,'1') <> 0) then
        weekday_spec := true;
        added := false;

       /*
         * need not to add every as the message already contains Every..
         * Add only if its specific week days like first/third Mon,Tue
        if (weekno_map = '11111') then
          weekday_msg := weekday_msg || 'Every ';
        else
        */
        if (weekno_map <> '11111') then
          -- insert selected weeks only
          for cnt in 1..5 loop
            if (SUBSTR(weekno_map, cnt,1) = '1') then
              weekday_msg := weekday_msg || weeks(cnt) || ' ';
            end if;
          end loop;
        end if;

        -- set the week days Sun/Mon etc
        for cnt in 1..7 loop
          if (SUBSTR(weekday_map,cnt,1) = '1') then
            if (added = true) then
              weekday_msg := weekday_msg || ',';
            end if;

            weekday_msg := weekday_msg || weekdays(cnt);
            added := true;
          end if;
        end loop;
      end if;

      if (date_spec = true AND weekday_spec = true) then
        begin
        -- both days and date are specified.. use DAD (date and day) messages

        if (date2 IS null) then
          fnd_message.set_name('FND','SCH-ADV-START-DAD');
          fnd_message.set_token('DATES', date_msg);
          fnd_message.set_token('MONTHS', month_msg);
          fnd_message.set_token('DAYS', weekday_msg);
        else
          fnd_message.set_name('FND','SCH-ADV-RANGE-DAD');
          fnd_message.set_token('DATES', date_msg);
          fnd_message.set_token('MONTHS', month_msg);
          fnd_message.set_token('DAYS', weekday_msg);
          fnd_message.set_token('EDATE', to_char(date2));
        end if;
        end;
      else
        begin
        -- either days and date are specified.. use DOD (date or day) messages
        if (date2 IS null) then
          fnd_message.set_name('FND','SCH-ADV-START-DOD');

          if (date_spec = true) then
            fnd_message.set_token('DOD', date_msg);
          else
            fnd_message.set_token('DOD', weekday_msg);
          end if;

          fnd_message.set_token('MONTHS', month_msg);

        else
          fnd_message.set_name('FND','SCH-ADV-RANGE-DOD');

          if (date_spec = true) then
            fnd_message.set_token('DOD', date_msg);
          else
            fnd_message.set_token('DOD', weekday_msg);
          end if;

          fnd_message.set_token('MONTHS', month_msg);
          fnd_message.set_token('EDATE', to_char(date2));

        end if;
        end;
      end if;
      a := fnd_message.get;
    end if; -- handle advance schedule of 56 char map

     end; -- schedule_type = 'S'

     else -- must be 'X'
       fnd_message.set_name('FND','SCH-ADVANCED');
       fnd_message.set_token('SCH_NAME', my_schedule_name);
       a := fnd_message.get;
     end if;
    return substrb(a, 1, 80);
  end build_short_schedule;


  -- FUnction will return schedule description based on the schedule type
  -- This function is copied from FNDRSRUN form

  function get_sch_desc( request_id IN number) return varchar2 is
    l_sch_id             number;
    l_sch_exists         number;
    l_sch_perm           number;
    l_sch_owner_req_id   number;
    l_requested_start_date  date;
    l_request_date       date;
    l_sch_date1          date;
    l_sch_date2          date;
    l_sch_type           varchar2(1);
    l_displayed_schedule varchar2(80);
    l_sch_name           varchar2(20);
    l_sch_curr_values    varchar2(80);
  begin
    select sch_id, sch_exists, sch_perm, sch_owner_req_id,
           requested_start_date, request_date, sch_date1, sch_date2, sch_name,
           sch_curr_values, sch_type
      into l_sch_id, l_sch_exists, l_sch_perm, l_sch_owner_req_id,
           l_requested_start_date, l_request_date, l_sch_date1, l_sch_date2,
           l_sch_name, l_sch_curr_values, l_sch_type
      from fnd_conc_requests_form_v
     where request_id = get_sch_desc.request_id;



    IF (l_sch_id is null) then
       l_sch_exists := 1;
       l_sch_perm := 0;
       l_sch_owner_req_id := get_sch_desc.request_id;
       if (l_requested_start_date <> l_request_date) then
         l_sch_date1 := l_requested_start_date;
         l_sch_type := 'O';
       else
         l_sch_type := 'A';
       end if;
    end if;

    IF (l_sch_owner_req_id is null) then

    l_displayed_schedule :=
    build_short_schedule(l_sch_type,
                                   l_sch_name,
                                   l_sch_date1,
                                   l_sch_date2,
           l_sch_curr_values,
                                   request_id);
    else    /* temp schedule - don't show bogus name */
      l_displayed_schedule :=
      build_short_schedule(l_sch_type,
                                   NULL,
                                   l_sch_date1,
                                   l_sch_date2,
           l_sch_curr_values,
                                   request_id);
    end if;

    return l_displayed_schedule;
  end;

  -- function will return program has arguments or not.
  -- It will return 'Y'/'N'
  function program_has_args(program_name    in varchar2,
                            program_appl_id in number) return varchar2 is

    i number := 0;
    has_orgs varchar2(1) := 'N';
  begin

      select count(*) into i
        from fnd_descr_flex_column_usages
       where application_id = program_appl_id
         and descriptive_flexfield_name = '$SRS$.' || program_name
         and descriptive_flex_context_code = 'Global Data Elements'
         and enabled_flag = 'Y';

      if (i > 0) then
         has_orgs := 'Y';
      else
        has_orgs := 'N';
      end if;

      return has_orgs;

  end;

  -- function will return elapsed time between two times in 'HH24:MI:SS' format
  -- First argument should be later time
  -- It returns varchar2
  function elapsed_time (end_time in date,
                         begin_time in date) return varchar2 is

    e_time varchar2(12) := '';
  begin

    if (end_time is null) then
       return '';
    end if;

    select to_char(trunc(sysdate) + (end_time - begin_time), 'HH24:MI:SS')
      into e_time
      from sys.dual;

    return e_time;

  end;

  -- function will return notification list as concatinated string
  -- It returns varchar2(2000)
  function get_notifications(request_id in number) return varchar2 is

     cursor notifications(req_id number) is
     select substrb(display_name,1,80) dname
       from fnd_conc_pp_actions pp,
            wf_roles wf
      where pp.concurrent_request_id = req_id
        and pp.action_type = 2
        and wf.orig_system_id = pp.orig_system_id
        and wf.orig_system = pp.orig_system
        and wf.name = pp.arguments
     order by sequence;

    notify_string varchar(2000) := null;
  begin

     for rec in notifications(request_id) loop
        if (notify_string is null ) then
            notify_string := rec.dname;
        else
      notify_string := notify_string || ',' || rec.dname;
        end if;
        exit when nvl(lengthb(notify_string),0 ) = 2000;
     end loop;

     return notify_string;

  exception
     when others then
       return null;
  end;

  -- This function will return request diagnostics for a given request_id.
  -- This is a wrapper on top of fnd_conc.diagnose procedure.

     function diagnostics( request_id IN number ) return varchar2 is
        phase  varchar2(80);
        status varchar2(80);
        diag   varchar2(2000);
     begin
        fnd_conc.diagnose(request_id, phase, status, diag );

        return diag;
     end;

  -- This function will return Y/N based on the request outfile information
  -- and request status.

     function get_ofile_status(req_id IN  number) return varchar2 is
        lp_code   varchar2(1);
        lof_name  varchar2(255);
        lof_size  number;
        lsave_of  varchar2(1);
     begin

        begin

	select * into lp_code, lof_name, lof_size, lsave_of from
	(select R.phase_code,
	decode(nvl(A.Action_type,0), 6, O.file_name, R.outfile_name),
	decode(nvl(A.action_type,0), 6, O.file_size, R.ofile_size),
	R.save_output_flag
	from fnd_concurrent_requests R,
	fnd_conc_pp_actions A,
	fnd_conc_req_outputs O
	where R.request_id = A.concurrent_request_id (+)
	and R.request_id = O.concurrent_request_id (+)
	and R.request_id = req_id
	order by A.action_type desc)
	where rownum=1;

        exception
          when no_data_found then
            return 'N';
        end;

        if ( lp_code in ('P','I') ) then
           return 'N';
        end if;

        if ( lsave_of = 'Y' ) then
           if ( lof_name is null ) then
             return 'N';
           end if;

           if ( lof_size is null ) then
              return 'N';
           end if;

           if ( lof_size = 0 ) then
              return 'N';
           end if;
        else
           return 'N';
        end if;

        return 'Y';

     end;


  -- AFCPSSUB.pls
  function test_advance_sch (class_info varchar2, edate date) return varchar2 is
    x varchar2(100);
    begin
      x := build_short_schedule('S', '', sysdate, edate, class_info, -1);
      return x;
    end;


  --
  -- Name
  --   layout_enabled
  -- Purpose
  --   Returns true if program contains any data definition in xml publisher
  --   schema.
  -- Arguments
  --   ProgramApplName - Concurrent Program Application Short Name
  --   ProgramShortName - Concurrent Program Short Name
  --
  function layout_enabled ( ProgramApplName  varchar2,
			    ProgramShortName varchar2) return boolean is
     sqlstmt   varchar2(1000) := 'select count(*) from ' ||
                 ' xdo_templates_vl T, fnd_concurrent_programs P,  ' ||
                 ' fnd_application A , xdo_ds_definitions_vl D ' ||
                 ' where T.ds_app_short_name= :1 and T.data_source_code= :2 ' ||
                 '  and T.template_status = ''E'' ' ||
                 '  and D.data_source_status = ''E'' ' ||
                 '  and sysdate between T.start_date and nvl(T.end_date, sysdate) ' ||
                 '  and sysdate between D.start_date and nvl(D.end_date, sysdate) ' ||
                 '  and D.application_short_name = T.ds_app_short_name ' ||
                 '  and D.data_source_code = T.data_source_code ' ||
                 '  and P.concurrent_program_name= T.data_source_code ' ||
                 '  and A.application_short_name = T.ds_app_short_name ' ||
                 '  and P.application_id = A.application_id ' ||
                 '  and P.output_file_type = ''XML''';
     tablenotfound exception;
     PRAGMA EXCEPTION_INIT(TableNotFound, -942);
     cnt number := 0;
  begin
     execute immediate sqlstmt into cnt using ProgramApplName, ProgramShortName;

     if ( cnt > 0 ) then
       return TRUE;
     else
       return FALSE;
     end if;

     exception
        when TableNotFound then
           return FALSE;
        when no_data_found then
           return FALSE;

  end;

  --
  -- Name
  --   layout_enabled_YN
  -- Purpose
  --   calls layout_enabled but returns Y or N instead of boolean
  --   used for calling from C code
  --
  function layout_enabled_YN (ProgramApplName varchar2,
                              ProgramShortName varchar2) return varchar2 is

  begin
        if(layout_enabled(ProgramApplName, ProgramShortName)) then
                return 'Y';
        else
                return 'N';
        end if;
  end;

  --
  -- Name
  --   publisher_installed
  -- Purpose
  --   Returns true if xml publisher installed otherwise false
  -- Arguments
  --
  function publisher_installed  return boolean is
     tablenotfound exception;
     PRAGMA EXCEPTION_INIT(TableNotFound, -942);
     cnt number := 0;
  begin
     execute immediate 'select count(*) from xdo_templates_vl' into cnt;

     return TRUE;

   exception
      when TableNotFound then
         return FALSE;

  end;

end FND_CONC_SSWA;

/

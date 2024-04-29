--------------------------------------------------------
--  DDL for Package Body FND_DATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_DATE" as
-- $Header: AFDDATEB.pls 120.1.12010000.9 2016/07/19 17:56:49 emiranda ship $

 -- Bug 23667122 - Define internal PLSQL-cache
 type rec_varchar IS RECORD (
  f_chk_value boolean,
  f_state     varchar2(100)
  );
 TYPE t_flags IS TABLE OF rec_varchar INDEX BY VARCHAR2(55);
 z_init_value t_flags; -- initialize values

  --
  -- PUBLIC
  --

  /*
  ** Chk_serverTZ
  **   Check for fnd_timezones.get_server_timezone_code value
  **   only 1 time and cache the result, since it does not change
  **   during the execution of the package fnd_date it has
  **   better performance if it is called only once.
  **       For Internal use only.   ( Bug 23667122 )
  */
  FUNCTION chk_serverTZ RETURN VARCHAR2 AS
    l_rtn   VARCHAR2(100);
    l_fname CONSTANT varchar2(40) := 'serverTZ';
  BEGIN
    l_rtn := NULL;

    IF (z_init_value( l_fname ).f_chk_value = TRUE) THEN

      l_rtn := fnd_timezones.get_server_timezone_code;
      z_init_value( l_fname ).f_state     := l_rtn;
      z_init_value( l_fname ).f_chk_value := FALSE;
    ELSE
      l_rtn := z_init_value( l_fname ).f_state;
    END IF;

    RETURN l_rtn;

  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END chk_serverTZ;

  -- Bug 23667122
  procedure reset_chk_serverTZ as

  begin
    -- Initialize the condition to RELOAD the value
    -- into Cache the next time it executes chk_serverTZ
    --
    z_init_value('serverTZ').f_chk_value := TRUE;
    z_init_value('serverTZ').f_state := NULL;
  end reset_chk_serverTZ;

 -- Initialization routines

  procedure initialize(p_user_mask  varchar2,
                      p_userDT_mask varchar2 default NULL)
  is
  begin
       initialize_with_calendar( p_user_mask,
                                 p_userDT_mask,
                                'GREGORIAN');
  end;


  procedure initialize_with_calendar(p_user_mask varchar2,
                       p_userDT_mask varchar2 default NULL,
                       p_user_calendar varchar2 default 'GREGORIAN')
  is
    my_user_mask varchar2(100) := p_user_mask;
    my_userDT_mask varchar2(200) := p_userDT_mask;
  begin
    if instr(my_user_mask,'|') > 0 then
      my_user_mask := substr(my_user_mask,1,instr(my_user_mask,'|'));
    end if;
    if instr(my_userDT_mask,'|') > 0 then
      my_userDT_mask := substr(my_userDT_mask,1,instr(my_userDT_mask,'|'));
    end if;

    -- Assign the user masks.  If the userDT_mask is null than derive it
    -- from the user_mask
    FND_DATE.user_mask := my_user_mask;
    FND_DATE.userDT_mask := NVL(my_userDT_mask,my_user_mask||' HH24:MI:SS');

    -- Assign the output masks - for now we'll derive them from the user mask.
    -- Strip off any FX or FM in the mask.  This wouldn't actually affect
    -- the output, but we use this mask as the error mask as well.
    FND_DATE.output_mask := REPLACE(REPLACE(FND_DATE.user_mask,'FM'),'FX');
    FND_DATE.outputDT_mask := REPLACE(REPLACE(FND_DATE.userDT_mask,'FM'),'FX');
    FND_DATE.user_calendar := upper(p_user_calendar);
    if not (FND_DATE.user_calendar = 'GREGORIAN'
       or FND_DATE.user_calendar = 'THAI BUDDHA'
       or FND_DATE.user_calendar = 'ARABIC HIJRAH'
       or FND_DATE.user_calendar = 'ENGLISH HIJRAH') then
       FND_DATE.user_calendar := 'GREGORIAN';
    end if;

    if (FND_DATE.user_calendar <> 'GREGORIAN') then
      FND_DATE.is_non_gregorian := true;
    else
      FND_DATE.is_non_gregorian := false;
    end if;
  end;

  -- to_char/to_date for non Gregorian calendar support. Private functions

  FUNCTION to_char_intl(dateval        DATE,
                        output_mask    VARCHAR2,
                        calendar_aware number) RETURN VARCHAR2 IS
  BEGIN
    -- Only non-Gregorian calendar.
    if (calendar_aware = FND_DATE.calendar_aware AND FND_DATE.is_non_gregorian) then
      RETURN to_char(dateval, output_mask, 'NLS_CALENDAR='''||FND_DATE.user_calendar||'''');
    else
      RETURN to_char(dateval, output_mask);
    end if;
  END to_char_intl;

  FUNCTION to_date_intl(chardt         VARCHAR2,
                        output_mask    VARCHAR2,
                        calendar_aware number) RETURN DATE IS
  BEGIN
    -- Only non-Gregorian calendar.
    if (calendar_aware = FND_DATE.calendar_aware AND FND_DATE.is_non_gregorian)  then
      RETURN to_date(chardt, output_mask, 'NLS_CALENDAR='''||FND_DATE.user_calendar||'''');
    else
      RETURN to_date(chardt, output_mask);
    end if;
  END to_date_intl;


  --
  -- Canonical functions
  --
  function canonical_to_date(canonical varchar2) return date is
    dateval  date;
    new_canonical varchar2(30);
  begin
    new_canonical := canonical;
    dateval := to_date(new_canonical, canonical_DT_mask);
    return dateval;
  end canonical_to_date;

  function date_to_canonical(dateval date) return varchar2 is
  begin
    return to_char(dateval, canonical_DT_mask);
  end date_to_canonical;

  --
  -- Date/DisplayDate functions - covers on the now obsolete Date/CharDate
  -- functions.  These functions are used to convert a date to and from
  -- the display format.
  --

  function displaydate_to_date(chardate varchar2) return date is
  begin
    return displaydate_to_date(chardate, fnd_date.calendar_aware_default);
  end displaydate_to_date;

  function displaydate_to_date(chardate varchar2,
                               calendar_aware number) return date is
  begin
    return chardate_to_date(chardate, calendar_aware);
  end displaydate_to_date;


  -- TZ*
  function displayDT_to_date(charDT varchar2) return date is
  begin
    return displayDT_to_date(charDT, fnd_date.calendar_aware_default);
  end displayDT_to_date;

  function displayDT_to_date(charDT varchar2,
                             calendar_aware number ) return date is
  begin
    return displayDT_to_date(charDT, null, calendar_aware);
  end displayDT_to_date;
  -- *TZ

  function date_to_displaydate(dateval date) return varchar2 is
  begin
    return date_to_displaydate(dateval, fnd_date.calendar_aware_default);
  end date_to_displaydate;

  function date_to_displaydate(dateval date,
                               calendar_aware number) return varchar2 is
  begin
    return date_to_chardate(dateval, calendar_aware);
  end date_to_displaydate;

  -- TZ*
  function date_to_displayDT(dateval date) return varchar2 is
  begin
      return date_to_displayDT(dateval, fnd_date.calendar_aware_default);
  end date_to_displayDT;

  function date_to_displayDT(dateval date,
                             calendar_aware number) return varchar2 is
  begin
      return date_to_displayDT(dateval, null, calendar_aware);
  end date_to_displayDT;
  -- *TZ

  -- Date/CharDate functions

  function chardate_to_date(chardate varchar2) return date is
  begin
    return chardate_to_date(chardate, fnd_date.calendar_aware_default);
  end chardate_to_date;

  function chardate_to_date(chardate varchar2,
                            calendar_aware number) return date is
    dateval  date;
    new_chardate varchar2(30);
  begin
    new_chardate := chardate;
    dateval := to_date_intl(new_chardate, user_mask, calendar_aware);
    return dateval;
  end chardate_to_date;

  -- TZ*
  function charDT_to_date(charDT varchar2) return date is
  begin
    return  charDT_to_date(chardt, fnd_date.calendar_aware_default);
  end charDT_to_date;

  function charDT_to_date(charDT varchar2,
                          calendar_aware number) return date is
  begin
    return displayDT_to_date(chardt, null, calendar_aware);
  end charDT_to_date;
  -- *TZ

  function date_to_chardate(dateval date) return varchar2 is
  begin
    return date_to_chardate(dateval, fnd_date.calendar_aware_default);
  end date_to_chardate;

  function date_to_chardate(dateval date,
                            calendar_aware number) return varchar2 is
  begin
    return to_char_intl(dateval, output_mask, calendar_aware);
  end date_to_chardate;

  -- TZ*
  function date_to_charDT(dateval date) return varchar2 is
  begin
    return date_to_charDT(dateval, fnd_date.calendar_aware_default);
  end date_to_charDT;

  function date_to_charDT(dateval date,
                          calendar_aware number) return varchar2 is
  begin
    return date_to_displayDT(dateval, null, calendar_aware);
  end date_to_charDT;

  -- *TZ

  FUNCTION string_to_date(p_string IN VARCHAR2,
                          p_mask   IN VARCHAR2)
    RETURN DATE
    IS
  BEGIN
     --
     -- First, try default settings.
     --
     BEGIN
  RETURN(To_date(p_string, p_mask));
     EXCEPTION
  WHEN OTHERS THEN
     NULL;
     END;

     --
     -- Now try 'NUMERIC DATE LANGUAGE'
     --
     BEGIN
  RETURN(To_date(p_string, p_mask,
           'NLS_DATE_LANGUAGE = ''NUMERIC DATE LANGUAGE'''));
     EXCEPTION
  WHEN OTHERS THEN
     NULL;
     END;

     --
     -- For backward compatibility try 'ARABIC'.
     -- 'ARABIC' uses numeric month names.
     --
     BEGIN
  RETURN(To_date(p_string, p_mask,
           'NLS_DATE_LANGUAGE = ''ARABIC'''));
     EXCEPTION
  WHEN OTHERS THEN
     NULL;
     END;

     --
     -- Now try currently installed languages.
     --
     DECLARE
  --
  -- Base language should come first.
  --
  CURSOR lang_cur IS
     SELECT  nls_language
       FROM fnd_languages
       WHERE installed_flag IN ('B','I')
       ORDER BY installed_flag, nls_language;
     BEGIN
  FOR lang_rec IN lang_cur LOOP
           BEGIN
        RETURN(To_date(p_string, p_mask,
           'NLS_DATE_LANGUAGE = ''' ||
           lang_rec.nls_language || ''''));
     EXCEPTION
        WHEN OTHERS THEN
     NULL;
     END;
  END LOOP;
     EXCEPTION
  WHEN OTHERS THEN
     NULL;
     END;

     --
     -- Now it is time to return NULL.
     --
     RETURN(NULL);
  EXCEPTION
     WHEN OTHERS THEN
  --
  -- This is Top Level Exception.
  --
  RETURN(NULL);
  END string_to_date;

  FUNCTION string_to_canonical(p_string IN VARCHAR2,
             p_mask   IN VARCHAR2)
    RETURN VARCHAR2
    IS
  BEGIN
     RETURN(To_char(string_to_date(p_string, p_mask),
        fnd_date.canonical_dt_mask));
  EXCEPTION
     WHEN OTHERS THEN
  RETURN(NULL);
  END string_to_canonical;

-- use 'set serverout on;' to see the output from this test program

-- NOTE: If this test program is run twice in a row you get an ORA-600. This
-- is logged against PL/SQL as 771171
  procedure test is
    my_date date := SYSDATE;
    my_char varchar2(20) := '01/01/2000 21:20:20';
  begin
    null;

    /*
    --commented out to avoid aru check constraints.

    DBMS_OUTPUT.PUT_LINE('About to call initialize with FMMM/DD/RRRR');
    fnd_date.initialize('FMMM/DD/RRRR');

    -- tz*
    DBMS_OUTPUT.PUT_LINE('About to call timezone initialize');
    if fnd_timezones.TIMEZONES_ENABLED = 'Y' then
      fnd_date_tz.init_timezones_for_fnd_date;
    else
      DBMS_OUTPUT.PUT_LINE('Timezones are not enabled');
    end if;

    DBMS_OUTPUT.PUT_LINE('Timezones are on (y/n) ' ||
    fnd_timezones.get_timezone_enabled_flag);
    DBMS_OUTPUT.PUT_LINE('Server timezone is ' ||
    nvl(fnd_timezones.GET_SERVER_TIMEZONE_CODE,'null'));
    DBMS_OUTPUT.PUT_LINE('Client timezone is ' ||
    nvl(fnd_timezones.GET_CLIENT_TIMEZONE_CODE,'null'));
    -- *tz

    DBMS_OUTPUT.PUT_LINE('User date mask is '||fnd_date.user_mask);
    DBMS_OUTPUT.PUT_LINE('Output date mask is '||fnd_date.output_mask);
    DBMS_OUTPUT.PUT_LINE('UserDT mask is '||fnd_date.userDT_mask);
    DBMS_OUTPUT.PUT_LINE('OutputDT mask is '||fnd_date.outputDT_mask);
    DBMS_OUTPUT.PUT_LINE('Display date is
    '||fnd_date.date_to_displaydate(my_date));
    DBMS_OUTPUT.PUT_LINE('Display DT is '||fnd_date.date_to_displayDT(my_date));

    DBMS_OUTPUT.PUT_LINE('Valid date is '||

                         date_to_displayDT(fnd_date.displaydate_to_date('02/01/2
                         000')));
    DBMS_OUTPUT.PUT_LINE('Valid DT is '||
                   date_to_displayDT(fnd_date.displayDT_to_date(my_char)));

    DBMS_OUTPUT.PUT_LINE('Canon date is '||fnd_date.date_to_canonical(sysdate));
    DBMS_OUTPUT.PUT_LINE('and back is
    '||fnd_date.date_to_displayDT(fnd_date.canonical_to_date('2001/03/12
    14:22:22')));


    select date_to_displayDT(sysdate+5)
    into my_char
    from dual;

    DBMS_OUTPUT.PUT_LINE('Display date from SQL is '||my_char);

    select date_to_canonical(sysdate+5)
    into my_char
    from dual;

    DBMS_OUTPUT.PUT_LINE('Canonical date from SQL is '||my_char);

    DBMS_OUTPUT.PUT_LINE('Valid date (w/no FX in mask) is
    '||to_char(fnd_date.displayDT_to_date('DEC-01-2000'),'DD-MON-YYYY
    HH24:MI:SS'));

    DBMS_OUTPUT.PUT_LINE('Next line should raise an exception.');
    DBMS_OUTPUT.PUT_LINE('Invalid date is
    '||to_char(fnd_date.displaydate_to_date('01-MAR-1999'),'DD-MON-YYYY
    HH24:MI:SS'));

    DBMS_OUTPUT.PUT_LINE('Error - exception not raised.');
    */

  end;


  -- tz*
   function date_to_displayDT(dateval date,new_client_tz_code varchar2) return
     varchar2 is
   begin


     return date_to_displayDT(dateval, new_client_tz_code, fnd_date.calendar_aware_default);

   end date_to_displayDT;

  function date_to_displayDT(dateval date,
                             new_client_tz_code varchar2,
                             calendar_aware number ) return
   varchar2 is
     t_dateval date;
     tz_code varchar2(50);
   begin

     t_dateval := dateval;

     if fnd_date.timezones_enabled then

       if new_client_tz_code is not null then
         tz_code := new_client_tz_code;
       else
         tz_code := fnd_date.client_timezone_code;
       end if;

       if tz_code <> fnd_date.server_timezone_code
        and tz_code <> 'FND_NO_CONVERT' then
         t_dateval := fnd_timezones_pvt.adjust_datetime(dateval
                                                       ,fnd_date.
                                                       server_timezone_code
                                                       ,tz_code);
       end if;
     end if;

     return to_char_intl(t_dateval, outputDT_mask, calendar_aware);

   end date_to_displayDT;

  function displayDT_to_date(charDT varchar2,new_client_tz_code varchar2) return
   date is
   begin
      return displayDT_to_date(charDT,new_client_tz_code, fnd_date.calendar_aware_default);

  end displayDT_to_date;

   function displayDT_to_date(charDT varchar2,
                              new_client_tz_code varchar2,
                              calendar_aware number) return
   date is
     dateval  date;
     -- new_charDT varchar2(20);

     -- Bug 3485847: Modified size of variable from 20 to 30 due to 'ORA-06502:
     -- PL/SQL: numeric or value error: character string buffer too small'
     new_charDT varchar2(30);
     tz_code varchar2(50);
   begin
     new_charDT := charDT;

     dateval := to_date_intl(new_charDT, userDT_mask, calendar_aware);

     if fnd_date.timezones_enabled then

       if new_client_tz_code is not null then
         tz_code := new_client_tz_code;
       else
         tz_code := fnd_date.client_timezone_code;
       end if;

       if tz_code <> fnd_date.server_timezone_code
          and tz_code <> 'FND_NO_CONVERT' then
         dateval := fnd_timezones_pvt.adjust_datetime(dateval
                                                     ,tz_code
                                                     ,fnd_date.
                                                     server_timezone_code);
       end if;
     end if;

     return dateval;

  end displayDT_to_date;

  function adjust_datetime(date_time date
                          ,from_tz varchar2
                          ,to_tz   varchar2) return date is
    begin
      if fnd_date.timezones_enabled then
      return fnd_timezones_pvt.adjust_datetime(date_time,from_tz,to_tz);
    else
      return date_time;
    end if;
  end adjust_datetime;

  -- *tz
  function calendar_awareness_profile(p_application_id    number) return varchar2 is
    begin
       return nvl(fnd_profile.value_specific(name => 'FND_DATE_API_CALENDAR_AWARENESS_DEFAULT',
                                             application_id => p_application_id), '0');
    end calendar_awareness_profile;

  -- Bug 19613037 ISO 8601 formatting and parsing functions.
  FUNCTION date_to_iso8601(dateval IN DATE) RETURN VARCHAR2 IS
    iso8601    VARCHAR2(30);
    -- Bug 23667122 implements the cache for
    --     the value of fnd_timezones.get_server_timezone_code
    --     using the function chk_serverTZ
    l_serverTZ VARCHAR2(100) := chk_serverTZ;
  BEGIN
    -- Bug 23667122 - remove context-switching between sql-and-plsql
    --    by replacing the SELECT .. from DUAL calls with plsql-assignments
    IF l_serverTZ IS NULL THEN
      iso8601 := to_char(dateval, iso8601_mask_localtime);
    ELSE
      iso8601 := to_char(fnd_timezones_pvt.adjust_datetime(dateval,
                                                           l_serverTZ,
                                                           'UTC'),
                         iso8601_mask);
    END IF;
    RETURN iso8601;
  END date_to_iso8601;

  function date_to_iso8601_localtime(dateval in Date) return varchar2 is
    iso8601 varchar2(30);
  begin
    select to_char(dateval, iso8601_mask_localtime) into iso8601 from dual;
    return iso8601;
  end date_to_iso8601_localtime;

  -- Bug 23667122
  --   remove context switch from sql-to-plsql
  FUNCTION iso8601_to_date(iso8601 VARCHAR2) RETURN DATE IS
    ELEM_YEAR        NUMBER := 1;
    ELEM_MONTH       NUMBER := 2;
    ELEM_DAY         NUMBER := 3;
    ELEM_HOUR        NUMBER := 4;
    ELEM_MIN         NUMBER := 5;
    ELEM_SEC         NUMBER := 6;
    ELEM_MILLSEC     NUMBER := 7;
    ELEM_OFFSET_HOUR NUMBER := 8;
    ELEM_OFFSET_MIN  NUMBER := 9;
    ELEM_OFFSET      NUMBER := 10;
    PART_DATE        NUMBER := 0;
    PART_TIME        NUMBER := 1;
    PART_OFFSET      NUMBER := 2;
    OFFSET_NOT_SET   NUMBER := 0;
    OFFSET_POSITIVE  NUMBER := 1;
    OFFSET_NEGATIVE  NUMBER := -1;
    text_length      NUMBER;
    cnt              NUMBER := 0;
    current_char     CHAR(1);
    current_part     NUMBER := PART_DATE;
    current_elem     NUMBER := ELEM_YEAR;
    text             VARCHAR2(30) := iso8601;
    buffer           VARCHAR2(30) := '';
    TYPE num_list IS VARRAY(10) OF PLS_INTEGER;
    elems          num_list := num_list(0,
                                        1,
                                        1,
                                        0,
                                        0,
                                        0,
                                        0,
                                        0,
                                        0,
                                        OFFSET_NOT_SET);
    l_elems_offset PLS_INTEGER;
    retdate        DATE;
    l_serverTZ     VARCHAR2(100) := chk_serverTZ;
    l_eval1        boolean;
    l_eval2        boolean;
  BEGIN

    IF substr(iso8601, length(iso8601), 1) = 'Z' THEN
      text := substr(iso8601, 0, length(iso8601) - 1) || '-00:00';
    END IF;
    text_length := length(text);
    WHILE (cnt < text_length) LOOP
      cnt          := cnt + 1;
      current_char := substr(text, cnt, 1);
      l_eval1 := ( TRIM(TRANSLATE(current_char, '0123456789', ' ')) IS NULL );
      l_eval2 := ( l_eval1 = TRUE AND cnt = text_length ) ;
      IF l_eval1 = TRUE THEN
        buffer := buffer || current_char;
      END IF;
      IF current_part = PART_DATE THEN
        IF current_char = '-' OR current_char = '+' OR current_char = 'T' OR
           l_eval2 = TRUE THEN
          elems(current_elem) := to_number(buffer);
          buffer := '';
          IF current_elem = ELEM_DAY AND
             (cnt <> text_length AND
             (current_char = '-' OR current_char = '+')) THEN
            current_part := PART_OFFSET;
            current_elem := ELEM_OFFSET_HOUR;
            IF current_char = '-' THEN
              elems(ELEM_OFFSET) := OFFSET_NEGATIVE;
            ELSE
              elems(ELEM_OFFSET) := OFFSET_POSITIVE;
            END IF;
            CONTINUE;
          ELSIF current_char = 'T' THEN
            current_part := PART_TIME;
          END IF;
          current_elem := current_elem + 1;
        ELSIF l_eval1 = FALSE THEN
          RETURN NULL;
        END IF;
      ELSIF current_part = PART_TIME THEN
        IF current_char = ':' OR current_char = '.' OR current_char = '-' OR
           current_char = '+' OR
           l_eval2 = TRUE THEN
          elems(current_elem) := to_number(buffer);
          IF current_char = '-' OR current_char = '+' THEN
            buffer       := '';
            current_part := PART_OFFSET;
            current_elem := ELEM_OFFSET_HOUR;
            IF current_char = '-' THEN
              elems(ELEM_OFFSET) := OFFSET_NEGATIVE;
            ELSE
              elems(ELEM_OFFSET) := OFFSET_POSITIVE;
            END IF;
            CONTINUE;
          END IF;
          buffer       := '';
          current_elem := current_elem + 1;
        ELSIF l_eval1 = FALSE THEN
          RETURN NULL;
        END IF;
      ELSIF current_part = PART_OFFSET THEN
        IF current_char = ':' OR l_eval2 = TRUE THEN
          elems(current_elem) := to_number(buffer);
          buffer := '';
          current_elem := current_elem + 1;
        ELSIF l_eval1 = FALSE THEN
          RETURN NULL;
        END IF;
      END IF;
    END LOOP;

    buffer := elems(ELEM_YEAR) || '-' || elems(ELEM_MONTH) || '-' ||
              elems(ELEM_DAY) || 'T' || elems(ELEM_HOUR) || ':' ||
              elems(ELEM_MIN) || ':' || elems(ELEM_SEC);

    l_elems_offset := elems(ELEM_OFFSET);

    IF l_elems_offset = OFFSET_NOT_SET OR l_serverTZ IS NULL THEN
      retdate := to_date(buffer, iso8601_mask_localtime);

    ELSE

      IF l_elems_offset = -1 THEN
        retdate := to_timestamp_tz(buffer || '-' || elems(ELEM_OFFSET_HOUR) || ':' ||
                                   elems(ELEM_OFFSET_MIN),
                                   iso8601_mask_localtime || 'TZH:TZM') at TIME ZONE
                   l_serverTZ;
      ELSE
        retdate := to_timestamp_tz(buffer || '+' || elems(ELEM_OFFSET_HOUR) || ':' ||
                                   elems(ELEM_OFFSET_MIN),
                                   iso8601_mask_localtime || 'TZH:TZM') at TIME ZONE
                   l_serverTZ;
      END IF;

    END IF;
    RETURN retdate;
  END iso8601_to_date;

BEGIN

  -- If the initialize routine is not called (for example on the concurrent
  -- manager side in 11.5) the routines will use the hardcoded format of
  -- DD-MON-RRRR.
  FND_DATE.user_mask := 'DD-MON-RRRR';
  FND_DATE.userDT_mask := FND_DATE.user_mask||' HH24:MI:SS';

  -- Assign the output masks - for now we'll derive them from the user mask.
  -- Strip off any FX or FM in the mask.  This wouldn't actually affect
  -- the output, but we use this mask as the error mask as well.
  FND_DATE.output_mask := REPLACE(REPLACE(FND_DATE.user_mask,'FM'),'FX');
  FND_DATE.outputDT_mask := REPLACE(REPLACE(FND_DATE.userDT_mask,'FM'),'FX');

  -- TZ*
  fnd_date.timezones_enabled := false;
  -- *TZ
  -- For non-Gregorian calendar support.
  fnd_date.user_calendar := 'GREGORIAN';
  fnd_date.is_non_gregorian := false;

  -- Bug 23667122
  --   Initialize cache-array and avoid pragma-restriction errors
  z_init_value('serverTZ').f_chk_value := TRUE;
  z_init_value('serverTZ').f_state := NULL;

end FND_DATE;

/

  GRANT EXECUTE ON "APPS"."FND_DATE" TO "EBSBI";

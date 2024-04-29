--------------------------------------------------------
--  DDL for Package Body BOM_CALENDARS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_CALENDARS_PKG" as
/* $Header: bompbclb.pls 115.2 99/07/16 05:47:10 porting ship $ */


FUNCTION Workday_Pattern_Exist (x_calendar_code VARCHAR2,
				x_shift_num NUMBER,
				x_calendar_or_shift NUMBER) RETURN NUMBER IS
  workday_pattern NUMBER;
BEGIN
  if x_calendar_or_shift = 0 then
    select count(*) into workday_pattern
      from BOM_WORKDAY_PATTERNS
     where calendar_code = x_calendar_code
       and shift_num is null;
  elsif x_calendar_or_shift = 1 then
    select count(*) into workday_pattern from BOM_WORKDAY_PATTERNS
     where calendar_code = x_calendar_code
       and shift_num = x_shift_num;
  end if;
  return (workday_pattern);
END Workday_Pattern_Exist;


PROCEDURE Calendar_Check_Unique (x_calendar_code VARCHAR2) IS
  dummy NUMBER;
BEGIN
  select 1 into dummy from DUAL where not exists
    (select 1 from BOM_CALENDARS
      where calendar_code = x_calendar_code
    );

  EXCEPTION
    when NO_DATA_FOUND then
      fnd_message.set_name('BOM', 'BOM_ALREADY_EXISTS');
      fnd_message.set_token('ENTITY1', 'CALENDAR_CAP', TRUE);
      fnd_message.set_token('ENTITY2', x_calendar_code);
      app_exception.raise_exception;
END Calendar_Check_Unique;


PROCEDURE Check_Exception_Range (x_calendar_code 	       VARCHAR2,
				 x_lo_except_date	IN OUT DATE,
				 x_hi_except_date	IN OUT DATE) IS
  cal_except_date	DATE;
  shift_except_date	DATE;
BEGIN

  select max(exception_date) into cal_except_date
    from BOM_CALENDAR_EXCEPTIONS
   where calendar_code = x_calendar_code;

  select max(exception_date) into shift_except_date
    from BOM_SHIFT_EXCEPTIONS
   where calendar_code = x_calendar_code;

  if (cal_except_date is NULL and shift_except_date is NULL) then
    x_hi_except_date := NULL;
  elsif (cal_except_date is NULL and shift_except_date is not NULL) then
    x_hi_except_date := shift_except_date;
  elsif (cal_except_date is not NULL and shift_except_date is NULL) then
    x_hi_except_date := cal_except_date;
  elsif (cal_except_date is NULL) and (shift_except_date is NULL) then
    begin
      if cal_except_date >= shift_except_date then
        x_hi_except_date := shift_except_date;
      else
        x_hi_except_date := cal_except_date;
      end if;
    end;
  end if;

  cal_except_date := NULL;
  shift_except_date := NULL;

  select min(exception_date) into cal_except_date
    from BOM_CALENDAR_EXCEPTIONS
   where calendar_code = x_calendar_code;
  select min(exception_date) into shift_except_date
    from BOM_SHIFT_EXCEPTIONS
   where calendar_code = x_calendar_code;

  if (cal_except_date is NULL and shift_except_date is NULL) then
    x_lo_except_date := NULL;
  elsif (cal_except_date is NULL and shift_except_date is not NULL) then
    x_lo_except_date := shift_except_date;
  elsif (cal_except_date is not NULL and shift_except_date is NULL) then
    x_lo_except_date := cal_except_date;
  elsif (cal_except_date is not NULL and shift_except_date is not NULL) then
    begin
      if cal_except_date >= shift_except_date then
        x_lo_except_date := shift_except_date;
      else
        x_lo_except_date := cal_except_date;
      end if;
    end;
  end if;

  EXCEPTION
    when NO_DATA_FOUND then
      null;
END Check_Exception_Range;


PROCEDURE Cal_Exception_Check_Unique (x_calendar_code  VARCHAR2,
				      x_exception_date DATE) IS
  dummy NUMBER;
BEGIN
  select 1 into dummy from DUAL where not exists
    (select 1 from BOM_CALENDAR_EXCEPTIONS
      where calendar_code = x_calendar_code
        and exception_date = x_exception_date
    );

  EXCEPTION
    when NO_DATA_FOUND then
      fnd_message.set_name('BOM', 'BOM_ALREADY_EXISTS');
      fnd_message.set_token('ENTITY1', x_exception_date);
      fnd_message.set_token('ENTITY2', NULL);
      app_exception.raise_exception;
END Cal_Exception_Check_Unique;



PROCEDURE Shift_Check_Unique (x_calendar_code VARCHAR2,
			      x_shift_num     NUMBER) IS
  dummy NUMBER;
BEGIN
  select 1 into dummy from DUAL where not exists
    (select 1 from BOM_CALENDAR_SHIFTS
      where calendar_code = x_calendar_code
        and shift_num = x_shift_num
    );

  EXCEPTION
    when NO_DATA_FOUND then
      fnd_message.set_name('BOM', 'BOM_ALREADY_EXISTS');
      fnd_message.set_token('ENTITY1', 'SHIFT NUM', TRUE);
      fnd_message.set_token('ENTITY2', x_shift_num);
      app_exception.raise_exception;
END Shift_Check_Unique;


PROCEDURE Shift_Exception_Check_Unique (x_calendar_code  VARCHAR2,
					x_shift_num	 NUMBER,
				        x_exception_date DATE) IS
  dummy 	NUMBER;
BEGIN
  select 1 into dummy from DUAL where not exists
    (select 1 from BOM_SHIFT_EXCEPTIONS
      where calendar_code = x_calendar_code
	and shift_num = x_shift_num
        and exception_date = x_exception_date
    );

  EXCEPTION
    when NO_DATA_FOUND then
      fnd_message.set_name('BOM', 'BOM_ALREADY_EXISTS');
      fnd_message.set_token('ENTITY1', x_exception_date);
      fnd_message.set_token('ENTITY2', NULL);
    app_exception.raise_exception;
END Shift_Exception_Check_Unique;


PROCEDURE Times_Check_Unique (x_calendar_code VARCHAR2,
			      x_row_id	      VARCHAR2,
                              x_shift_num     NUMBER,
                              x_start_time    NUMBER,
                              x_end_time      NUMBER) IS
  dummy NUMBER;
BEGIN
  select 1 into dummy from DUAL where not exists
    (select 1 from BOM_SHIFT_TIMES
      where calendar_code = x_calendar_code
        and shift_num = x_shift_num
        and from_time = x_start_time
        and to_time = x_end_time
	and (
	     rowid is null
	     or
	     rowid <> x_row_id
	    )
    );

  EXCEPTION
    when NO_DATA_FOUND then
      fnd_message.set_name('BOM', 'BOM_ALREADY_EXISTS');
      fnd_message.set_token('ENTITY1', 'TIME FROM_CAP', TRUE);
      fnd_message.set_token('ENTITY2', 'TIME TO_CAP', TRUE);
      app_exception.raise_exception;
END Times_Check_Unique;


FUNCTION Shift_Times_Overlap (x_calendar_code	VARCHAR2,
			      x_shift_num	NUMBER,
			      x_start_time	NUMBER,
			      x_end_time	NUMBER,
			      x_rowid		VARCHAR2,
			      x_flag		NUMBER) RETURN NUMBER IS
  dummy	NUMBER := 0;
BEGIN
  if x_flag = 1 then
    select count(*) into dummy from dual where not exists
    (select 1 from BOM_SHIFT_TIMES
      where calendar_code = x_calendar_code
        and shift_num = x_shift_num
        and from_time < to_time
        and x_start_time > from_time
        and x_start_time < to_time
    union
     select 1 from BOM_SHIFT_TIMES
      where calendar_code = x_calendar_code
        and shift_num = x_shift_num
        and from_time > to_time
        and (x_start_time > from_time or x_start_time < to_time)
    );
  elsif x_flag = 2 then
    select count(*) into dummy from dual where not exists
    (select 1 from BOM_SHIFT_TIMES
      where calendar_code = x_calendar_code
        and shift_num = x_shift_num
        and from_time < to_time
        and x_start_time > from_time
        and x_start_time < to_time
 	and x_rowid <> x_rowid
    union
     select 1 from BOM_SHIFT_TIMES
      where calendar_code = x_calendar_code
        and shift_num = x_shift_num
        and from_time > to_time
        and (x_start_time > from_time or x_start_time < to_time)
 	and x_rowid <> x_rowid
    );
  end if;

  if Dummy = 0 then
    return (0);
  end if;

  if x_flag = 1 then
    select count(*) into dummy from DUAL where not exists
    (select 1 from BOM_SHIFT_TIMES
      where calendar_code = x_calendar_code
        and shift_num = x_shift_num
        and from_time < to_time
        and x_end_time > from_time
        and x_end_time < to_time
    union
     select 1 from BOM_SHIFT_TIMES
      where calendar_code = x_calendar_code
        and shift_num = x_shift_num
        and from_time > to_time
        and (x_end_time < to_time or x_end_time > from_time)
    );
  elsif x_flag = 2 then
    select count(*) into dummy from DUAL where not exists
    (select 1 from BOM_SHIFT_TIMES
      where calendar_code = x_calendar_code
        and shift_num = x_shift_num
        and from_time < to_time
        and x_end_time > from_time
        and x_end_time < to_time
	and rowid <> x_rowid
    union
     select 1 from BOM_SHIFT_TIMES
      where calendar_code = x_calendar_code
        and shift_num = x_shift_num
        and from_time > to_time
        and (x_end_time < to_time or x_end_time > from_time)
      	and rowid <> x_rowid
    );
  end if;

  if dummy = 0 then
    return (0);
  end if;

  if x_flag = 1 then
    select count(*) into dummy from DUAL where not exists
    (select 1 from BOM_SHIFT_TIMES
      where calendar_code =  x_calendar_code
        and shift_num =  x_shift_num
        and from_time < to_time
        and x_start_time < x_end_time
        and x_start_time < from_time
        and x_end_time > to_time
    union
     select 1 from BOM_SHIFT_TIMES
      where calendar_code = x_calendar_code
        and shift_num = x_shift_num
        and from_time < to_time
        and x_start_time < x_end_time
        and x_start_time > from_time
        and x_end_time < to_time
    );
  elsif x_flag = 2 then
    select count(*) into dummy from DUAL where not exists
    (select 1 from BOM_SHIFT_TIMES
      where calendar_code =  x_calendar_code
        and shift_num =  x_shift_num
        and from_time < to_time
        and x_start_time < x_end_time
        and x_start_time < from_time
        and x_end_time > to_time
	and rowid <> x_rowid
    union
     select 1 from BOM_SHIFT_TIMES
      where calendar_code = x_calendar_code
        and shift_num = x_shift_num
        and from_time < to_time
        and x_start_time < x_end_time
        and x_start_time > from_time
        and x_end_time < to_time
      	and rowid <> x_rowid
    );
  end if;

  if dummy = 0 then
    return (0);
  end if;

  if x_flag = 1 then
    select count(*) into dummy from DUAL where not exists
    (select 1 from BOM_SHIFT_TIMES
      where calendar_code = x_calendar_code
        and shift_num = x_shift_num
        and from_time > to_time
        and x_start_time > x_end_time
        and x_start_time < from_time
        and x_end_time > to_time
    union
     select 1 from BOM_SHIFT_TIMES
      where calendar_code = x_calendar_code
        and shift_num = x_shift_num
        and from_time > to_time
        and x_start_time > x_end_time
        and x_start_time > from_time
        and x_end_time < to_time
    );
  elsif x_flag = 2 then
    select count(*) into dummy from DUAL where not exists
    (select 1 from BOM_SHIFT_TIMES
      where calendar_code = x_calendar_code
        and shift_num = x_shift_num
        and from_time > to_time
        and x_start_time > x_end_time
        and x_start_time < from_time
        and x_end_time > to_time
  	and rowid <> x_rowid
    union
     select 1 from BOM_SHIFT_TIMES
      where calendar_code = x_calendar_code
        and shift_num = x_shift_num
        and from_time > to_time
        and x_start_time > x_end_time
        and x_start_time > from_time
        and x_end_time < to_time
  	and rowid <> x_rowid
    );
  end if;

  if dummy = 0 then
    return (0);
  else
    return (1);
  end if;

END Shift_Times_Overlap;


END BOM_CALENDARS_PKG;

/

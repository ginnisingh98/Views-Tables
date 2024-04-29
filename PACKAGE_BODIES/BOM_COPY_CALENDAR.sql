--------------------------------------------------------
--  DDL for Package Body BOM_COPY_CALENDAR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_COPY_CALENDAR" as
/* $Header: BOMPCPCB.pls 115.1 99/07/16 05:14:55 porting ship $ */



/* Declare private subprograms */

   PROCEDURE Copy_Cal_Workday_Patterns
		 ( x_calendar_code_from VARCHAR2,
    		   x_calendar_code_to	VARCHAR2,
		   x_userid 		NUMBER );

   PROCEDURE Copy_Shift_Workday_Patterns
		 ( x_calendar_code_from VARCHAR2,
		   x_calendar_code_to	VARCHAR2,
		   x_shift_num_from	NUMBER,
		   x_shift_num_to	NUMBER,
		   x_userid		NUMBER );

   PROCEDURE Copy_Cal_Exceptions
		 ( x_calendar_code_from	VARCHAR2,
		   x_calendar_code_to	VARCHAR2,
		   x_start_date		DATE,
		   x_end_date		DATE,
		   x_userid		NUMBER );

   PROCEDURE Copy_Cal_All_Shifts
		 ( x_calendar_code_from	VARCHAR2,
		   x_calendar_code_to	VARCHAR2,
		   x_shift_num_from	NUMBER,
		   x_shift_num_to	NUMBER,
		   x_start_date		DATE,
		   x_end_date		DATE,
		   x_userid		NUMBER );

   PROCEDURE Copy_Cal_Spec_Shift
		 ( x_calendar_code_from	VARCHAR2,
		   x_calendar_code_to 	VARCHAR2,
		   x_shift_num_from	NUMBER,
	 	   x_start_date	   	DATE,
		   x_end_date		DATE,
		   x_userid		NUMBER );

   PROCEDURE Copy_Shift_Times
		 ( x_calendar_code_from	VARCHAR2,
		   x_calendar_code_to	VARCHAR2,
		   x_shift_num_from	NUMBER,
		   x_shift_num_to	NUMBER,
		   x_userid		NUMBER );

   PROCEDURE Copy_Shift_Exceptions
		 ( x_calendar_code_from	VARCHAR2,
		   x_calendar_code_to	VARCHAR2,
		   x_shift_num_from	NUMBER,
		   x_shift_num_to	NUMBER,
		   x_start_date		DATE,
		   x_end_date		DATE,
		   x_userid		NUMBER );

   PROCEDURE Copy_Exceptions_Cal
		 ( x_calendar_code_to	VARCHAR2,
		   x_exception_set_name	VARCHAR2,
		   x_start_date		DATE,
		   x_end_date		DATE,
		   x_userid		NUMBER );

   PROCEDURE Copy_Shift_Exceptions_Cal
		 ( x_calendar_code_from VARCHAR2,
		   x_calendar_code_to	VARCHAR2,
   	   	   x_shift_num_from	NUMBER,
		   x_start_date		DATE,
		   x_end_date		DATE,
		   x_userid		NUMBER );

   PROCEDURE Copy_Exceptions_Shift
		 ( x_calendar_code_to	VARCHAR2,
		   x_shift_num_to	NUMBER,
		   x_exception_set_name	VARCHAR2,
		   x_start_date		DATE,
		   x_end_date		DATE,
		   x_userid		NUMBER );

   PROCEDURE Copy_Cal_Exceptions_Shift
		 ( x_calendar_code_from	VARCHAR2,
		   x_calendar_code_to	VARCHAR2,
		   x_shift_num_to	NUMBER,
		   x_start_date		DATE,
		   x_end_date		DATE,
		   x_userid		NUMBER );


/* End private subprogram declarations */



PROCEDURE Drop_Cal_Cancelled_Excepts IS
BEGIN
  delete from BOM_CALENDAR_EXCEPTIONS
   where created_by = '-99999';

  if (SQL%NOTFOUND) then
    null;
  end if;
END Drop_Cal_Cancelled_Excepts;



PROCEDURE Drop_Shift_Cancelled_Excepts IS
BEGIN
  delete from BOM_SHIFT_EXCEPTIONS
   where created_by = '-99999';

  if (SQL%NOTFOUND) then
    null;
  end if;
END Drop_Shift_Cancelled_Excepts;



PROCEDURE Copy_Calendar (  copy_type			IN  NUMBER,
			   x_calendar_code_from 	IN  VARCHAR2,
			   x_calendar_code_to		IN  VARCHAR2,
			   x_shift_num_from		IN  NUMBER,
			   x_shift_num_to		IN  NUMBER,
			   x_exception_set_name		IN  VARCHAR2,
			   x_start_date			IN  DATE,
			   x_end_date			IN  DATE,
			   x_userid			IN  NUMBER  ) IS

BEGIN

  /* ********************************************************************** */
  /*   copy_type in (1, 2, 3)						    */
  /*  		1 => copies all shifts					    */
  /*  		3 => copies specific shift				    */
  /*   copies information from one calendar to another, including 	    */
  /*   calendar workday patterns, calendar exceptions, and calendar shifts  */
  /* ********************************************************************** */

  if copy_type in (1, 2, 3) then
    Copy_Cal_Workday_Patterns (x_calendar_code_from, x_calendar_code_to,
			       x_userid);
    Copy_Cal_Exceptions (x_calendar_code_from, x_calendar_code_to,
			 x_start_date, x_end_date, x_userid);
    if copy_type = 1 then
      Copy_Cal_All_Shifts (x_calendar_code_from, x_calendar_code_to,
			   x_shift_num_from, x_shift_num_to,
			   x_start_date, x_end_date, x_userid);
    elsif copy_type = 3 then
      Copy_Cal_Spec_Shift (x_calendar_code_from, x_calendar_code_to,
			   x_shift_num_from, x_start_date, x_end_date,
			   x_userid);
    end if;


  /* ********************************************************************** */
  /*   copy_type = 4							    */
  /*   copies information from one shift to another, including   	    */
  /*   shift times, shift exceptions, and shift workday patterns 	    */
  /* ********************************************************************** */

  elsif copy_type = 4 then
    Copy_Shift_Times (x_calendar_code_from, x_calendar_code_to,
		      x_shift_num_from, x_shift_num_to, x_userid);
    Copy_Shift_Exceptions (x_calendar_code_from, x_calendar_code_to,
			   x_shift_num_from, x_shift_num_to,
			   x_start_date, x_end_date, x_userid);
    Copy_Shift_Workday_Patterns (x_calendar_code_from, x_calendar_code_to,
			         x_shift_num_from, x_shift_num_to, x_userid);


  /* ********************************************************************** */
  /*   copy_type = 5							    */
  /*   copies exceptions from an exception set to a calendar 		    */
  /*   from BOM_EXCEPTION_SETS into BOM_CALENDAR_EXCEPTIONS  		    */
  /* ********************************************************************** */

  elsif copy_type = 5 then
    Copy_Exceptions_Cal (x_calendar_code_to, x_exception_set_name,
			 x_start_date, x_end_date, x_userid);


  /* ********************************************************************** */
  /*   copy_type = 6							    */
  /*   copies exceptions from one calendar to another 		  	    */
  /*   from BOM_CALENDAR_EXCEPTIONS into BOM_CALENDAR_EXCEPTIONS 	    */
  /* ********************************************************************** */

  elsif copy_type = 6 then
    Copy_Cal_Exceptions (x_calendar_code_from, x_calendar_code_to,
			 x_start_date, x_end_date, x_userid);


  /* ********************************************************************** */
  /*   copy_type = 7							    */
  /*   copies exceptions from a shift to a calendar           		    */
  /*   from BOM_SHIFT_EXCEPTIONS into BOM_CALENDAR_EXCEPTIONS 		    */
  /* ********************************************************************** */

  elsif copy_type = 7 then
    Copy_Shift_Exceptions_Cal (x_calendar_code_from, x_calendar_code_to,
		               x_shift_num_from, x_start_date, x_end_date, x_userid);


  /* ********************************************************************** */
  /*   copy_type = 8							    */
  /*   copies exceptions from an exception set to a shift 		    */
  /*   from BOM_EXCEPTION_SETS into BOM_SHIFT_EXCEPTIONS  		    */
  /* ********************************************************************** */

  elsif copy_type = 8 then
    Copy_Exceptions_Shift (x_calendar_code_to, x_shift_num_to,
			   x_exception_set_name, x_start_date, x_end_date, x_userid);


  /* ********************************************************************** */
  /*   copy_type = 9							    */
  /*   copies exceptions from a calendar to a shift           		    */
  /*   from BOM_CALENDAR_EXCEPTIONS into BOM_SHIFT_EXCEPTIONS 		    */
  /* ********************************************************************** */

  elsif copy_type = 9 then
    Copy_Cal_Exceptions_Shift (x_calendar_code_from, x_calendar_code_to,
			       x_shift_num_to, x_start_date, x_end_date, x_userid);


  /* ********************************************************************** */
  /*   copy_type = 10							    */
  /*   copies exceptions from one shift to another         		    */
  /*   from BOM_SHIFT_EXCEPTIONS into BOM_SHIFT_EXCEPTIONS 		    */
  /* ********************************************************************** */

  elsif copy_type = 10 then
    Copy_Shift_Exceptions (x_calendar_code_from, x_calendar_code_to,
			   x_shift_num_from, x_shift_num_to,
			   x_start_date, x_end_date, x_userid);

  end if;

END Copy_Calendar;




/*  Define local procedures, available only in package */


PROCEDURE Copy_Cal_Workday_Patterns (x_calendar_code_from VARCHAR2,
				     x_calendar_code_to   VARCHAR2,
				     x_userid		  NUMBER) IS
 v_max_seq_num BOM_WORKDAY_PATTERNS.seq_num%TYPE;
BEGIN

  select NVL(MAX(seq_num),0)
  into v_max_seq_num
  from BOM_WORKDAY_PATTERNS  bwp
  where bwp.calendar_code = x_calendar_code_to
    and shift_num is null;

  insert into BOM_WORKDAY_PATTERNS
	      (	calendar_code,
		seq_num,
		last_update_date,
		last_updated_by,
		creation_date,
		created_by,
		last_update_login,
		days_on,
		days_off,
		description,
		attribute_category,
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
		attribute15 )
      	select
		x_calendar_code_to,
		v_max_seq_num + bwp.seq_num,
		sysdate,
		x_userid,
		sysdate,
		x_userid,
		x_userid,
		bwp.days_on,
		bwp.days_off,
		bwp.description,
		bwp.attribute_category,
		bwp.attribute1,
		bwp.attribute2,
		bwp.attribute3,
		bwp.attribute4,
		bwp.attribute5,
		bwp.attribute6,
		bwp.attribute7,
		bwp.attribute8,
		bwp.attribute9,
		bwp.attribute10,
		bwp.attribute11,
		bwp.attribute12,
		bwp.attribute13,
		bwp.attribute14,
		bwp.attribute15
          from 	BOM_WORKDAY_PATTERNS bwp
         where 	bwp.calendar_code = x_calendar_code_from
           and 	bwp.shift_num is null;

END Copy_Cal_Workday_Patterns;


PROCEDURE Copy_Shift_Workday_Patterns (x_calendar_code_from VARCHAR2,
				       x_calendar_code_to   VARCHAR2,
				       x_shift_num_from	    NUMBER,
				       x_shift_num_to	    NUMBER,
				       x_userid		    NUMBER) IS

  v_max_seq_num BOM_WORKDAY_PATTERNS.seq_num%TYPE;

BEGIN

  select NVL(MAX(seq_num),0)
  into v_max_seq_num
  from BOM_WORKDAY_PATTERNS  bwp
  where bwp.calendar_code = x_calendar_code_to
    and shift_num is not null;

  insert into BOM_WORKDAY_PATTERNS
              ( calendar_code,
                shift_num,
                seq_num,
                last_update_date,
                last_updated_by,
                creation_date,
                created_by,
                last_update_login,
                days_on,
                days_off,
                description,
                attribute_category,
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
                attribute15 )
      	select
                x_calendar_code_to,
                x_shift_num_to,
                v_max_seq_num + bwp1.seq_num,
                sysdate,
 		x_userid,
                sysdate,
 		x_userid,
 		x_userid,
                bwp1.days_on,
                bwp1.days_off,
                bwp1.description,
                bwp1.attribute_category,
                bwp1.attribute1,
                bwp1.attribute2,
                bwp1.attribute3,
                bwp1.attribute4,
                bwp1.attribute5,
                bwp1.attribute6,
                bwp1.attribute7,
                bwp1.attribute8,
                bwp1.attribute9,
                bwp1.attribute10,
                bwp1.attribute11,
                bwp1.attribute12,
                bwp1.attribute13,
                bwp1.attribute14,
                bwp1.attribute15
      	  from 	BOM_WORKDAY_PATTERNS bwp1
         where 	bwp1.calendar_code = x_calendar_code_from
           and  bwp1.shift_num = x_shift_num_from;

END Copy_Shift_Workday_Patterns;



PROCEDURE Copy_Cal_Exceptions (x_calendar_code_from VARCHAR2,
                               x_calendar_code_to   VARCHAR2,
			       x_start_date	    DATE,
			       x_end_date	    DATE,
			       x_userid		    NUMBER) IS

BEGIN

  insert into BOM_CALENDAR_EXCEPTIONS
	      (	calendar_code,
		exception_set_id,
		exception_date,
		last_update_date,
		last_updated_by,
		last_update_login,
		creation_date,
		created_by,
		exception_type,
		attribute_category,
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
		attribute15 )
    	select
		x_calendar_code_to,
		-1,
		bce.exception_date,
		sysdate,
		x_userid,
		x_userid,
		sysdate,
	 	x_userid,
		-- '-99999',
		bce.exception_type,
		bce.attribute_category,
		bce.attribute1,
		bce.attribute2,
		bce.attribute3,
		bce.attribute4,
		bce.attribute5,
		bce.attribute6,
		bce.attribute7,
		bce.attribute8,
		bce.attribute9,
		bce.attribute10,
		bce.attribute11,
		bce.attribute12,
		bce.attribute13,
		bce.attribute14,
		bce.attribute15
 	  from	BOM_CALENDAR_EXCEPTIONS bce
         where 	bce.calendar_code = x_calendar_code_from
           and 	bce.exception_date not in
			(select bce1.exception_date
			   from BOM_CALENDAR_EXCEPTIONS bce1
			  where bce1.calendar_code = x_calendar_code_to)
	   and  bce.exception_date >= x_start_date
	   and  bce.exception_date <= x_end_date;
END Copy_Cal_Exceptions;


PROCEDURE Copy_Cal_All_Shifts (x_calendar_code_from VARCHAR2,
                               x_calendar_code_to   VARCHAR2,
			       x_shift_num_from	    NUMBER,
			       x_shift_num_to	    NUMBER,
			       x_start_date	    DATE,
			       x_end_date	    DATE,
			       x_userid		    NUMBER) IS

  v_max_seq_num BOM_WORKDAY_PATTERNS.seq_num%TYPE;
BEGIN

  insert into BOM_CALENDAR_SHIFTS
 	      (	calendar_code,
		shift_num,
		last_update_date,
		last_updated_by,
		last_update_login,
		creation_date,
		created_by,
		days_on,
		days_off,
		description,
		attribute_category,
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
		attribute15 )
       select
		x_calendar_code_to,
		bcs.shift_num,
		sysdate,
 		'-99999',
		x_userid,
		sysdate,
		x_userid,
		bcs.days_on,
		bcs.days_off,
		bcs.description,
		bcs.attribute_category,
		bcs.attribute1,
		bcs.attribute2,
		bcs.attribute3,
		bcs.attribute4,
		bcs.attribute5,
		bcs.attribute6,
		bcs.attribute7,
		bcs.attribute8,
		bcs.attribute9,
		bcs.attribute10,
		bcs.attribute11,
		bcs.attribute12,
		bcs.attribute13,
		bcs.attribute14,
		bcs.attribute15
  	from	BOM_CALENDAR_SHIFTS bcs
       where	bcs.calendar_code = x_calendar_code_from
	 and	bcs.shift_num not in
			( select bcs1.shift_num
		            from BOM_CALENDAR_SHIFTS bcs1
			   where bcs1.calendar_code = x_calendar_code_to );

  insert into BOM_SHIFT_TIMES
	      (	calendar_code,
		shift_num,
		from_time,
		to_time,
		last_update_date,
		last_updated_by,
		last_update_login,
		creation_date,
		created_by,
		attribute_category,
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
		attribute15 )
	select
		x_calendar_code_to,
		bst1.shift_num,
		bst1.from_time,
		bst1.to_time,
		sysdate,
		x_userid,
		x_userid,
		sysdate,
		x_userid,
		bst1.attribute_category,
		bst1.attribute1,
		bst1.attribute2,
		bst1.attribute3,
		bst1.attribute4,
		bst1.attribute5,
		bst1.attribute6,
		bst1.attribute7,
		bst1.attribute8,
		bst1.attribute9,
		bst1.attribute10,
		bst1.attribute11,
		bst1.attribute12,
		bst1.attribute13,
		bst1.attribute14,
		bst1.attribute15
	  from	BOM_SHIFT_TIMES bst1, BOM_CALENDAR_SHIFTS bcs5
	 where  bcs5.last_updated_by = '-99999'
  	   and  bcs5.calendar_code = x_calendar_code_to
	   and  bcs5.shift_num = bst1.shift_num
    	   and  bst1.calendar_code = x_calendar_code_from;


  select NVL(MAX(seq_num),0)
  into v_max_seq_num
  from BOM_WORKDAY_PATTERNS  bwp
  where bwp.calendar_code = x_calendar_code_to
    and shift_num is not null;

  insert into BOM_WORKDAY_PATTERNS
              ( calendar_code,
                shift_num,
                seq_num,
                last_update_date,
                last_updated_by,
                creation_date,
                created_by,
                last_update_login,
                days_on,
                days_off,
                description,
                attribute_category,
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
                attribute15 )
      	select
                x_calendar_code_to,
                bwp1.shift_num,
                v_max_seq_num + bwp1.seq_num,
                sysdate,
		x_userid,
                sysdate,
		x_userid,
		x_userid,
                bwp1.days_on,
                bwp1.days_off,
                bwp1.description,
                bwp1.attribute_category,
                bwp1.attribute1,
                bwp1.attribute2,
                bwp1.attribute3,
                bwp1.attribute4,
                bwp1.attribute5,
                bwp1.attribute6,
                bwp1.attribute7,
                bwp1.attribute8,
                bwp1.attribute9,
                bwp1.attribute10,
                bwp1.attribute11,
                bwp1.attribute12,
                bwp1.attribute13,
                bwp1.attribute14,
                bwp1.attribute15
	  from	BOM_WORKDAY_PATTERNS bwp1, BOM_CALENDAR_SHIFTS bcs5
	 where  bcs5.last_updated_by = '-99999'
  	   and  bcs5.calendar_code = x_calendar_code_to
	   and  bcs5.shift_num = bwp1.shift_num
    	   and  bwp1.calendar_code = x_calendar_code_from;

  insert into BOM_SHIFT_EXCEPTIONS
              ( calendar_code,
                shift_num,
                exception_set_id,
                exception_date,
		exception_type,
                last_update_date,
                last_updated_by,
                last_update_login,
                creation_date,
                created_by,
                attribute_category,
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
                attribute15 )
        select
                x_calendar_code_to,
                bse1.shift_num,
                -1,
                bse1.exception_date,
		bse1.exception_type,
                sysdate,
		x_userid,
		x_userid,
                sysdate,
		x_userid,
                bse1.attribute_category,
                bse1.attribute1,
                bse1.attribute2,
                bse1.attribute3,
                bse1.attribute4,
                bse1.attribute5,
                bse1.attribute6,
                bse1.attribute7,
                bse1.attribute8,
                bse1.attribute9,
                bse1.attribute10,
                bse1.attribute11,
                bse1.attribute12,
                bse1.attribute13,
                bse1.attribute14,
                bse1.attribute15
	  from	BOM_SHIFT_EXCEPTIONS bse1, BOM_CALENDAR_SHIFTS bcs5
	 where  bcs5.last_updated_by = '-99999'
  	   and  bcs5.calendar_code = x_calendar_code_to
	   and  bcs5.shift_num = bse1.shift_num
    	   and  bse1.calendar_code = x_calendar_code_from
	   and  bse1.exception_date >= x_start_date
	   and  bse1.exception_date <= x_end_date;

  update BOM_CALENDAR_SHIFTS set
		last_updated_by = x_userid
		where calendar_code = x_calendar_code_to
		  and last_updated_by = '-99999';

END Copy_Cal_All_Shifts;



PROCEDURE Copy_Cal_Spec_Shift (x_calendar_code_from VARCHAR2,
                               x_calendar_code_to   VARCHAR2,
			       x_shift_num_from	    NUMBER,
			       x_start_date	    DATE,
			       x_end_date	    DATE,
			       x_userid		    NUMBER) IS

  v_max_seq_num BOM_WORKDAY_PATTERNS.seq_num%TYPE;


BEGIN

  insert into BOM_CALENDAR_SHIFTS
 	      (	calendar_code,
		shift_num,
		last_update_date,
		last_updated_by,
		last_update_login,
		creation_date,
		created_by,
		days_on,
		days_off,
		description,
		attribute_category,
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
		attribute15 )
       select
		x_calendar_code_to,
		x_shift_num_from,
		sysdate,
		x_userid,
		x_userid,
		sysdate,
		x_userid,
		bcs.days_on,
		bcs.days_off,
		bcs.description,
		bcs.attribute_category,
		bcs.attribute1,
		bcs.attribute2,
		bcs.attribute3,
		bcs.attribute4,
		bcs.attribute5,
		bcs.attribute6,
		bcs.attribute7,
		bcs.attribute8,
		bcs.attribute9,
		bcs.attribute10,
		bcs.attribute11,
		bcs.attribute12,
		bcs.attribute13,
		bcs.attribute14,
		bcs.attribute15
  	from	BOM_CALENDAR_SHIFTS bcs
       where	bcs.calendar_code = x_calendar_code_from
	 and	bcs.shift_num = x_shift_num_from;

  insert into BOM_SHIFT_TIMES
	      (	calendar_code,
		shift_num,
		from_time,
		to_time,
		last_update_date,
		last_updated_by,
		last_update_login,
		creation_date,
		created_by,
		attribute_category,
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
		attribute15 )
	select
		x_calendar_code_to,
		x_shift_num_from,
		bst4.from_time,
		bst4.to_time,
		sysdate,
		x_userid,
		x_userid,
		sysdate,
		x_userid,
		bst4.attribute_category,
		bst4.attribute1,
		bst4.attribute2,
		bst4.attribute3,
		bst4.attribute4,
		bst4.attribute5,
		bst4.attribute6,
		bst4.attribute7,
		bst4.attribute8,
		bst4.attribute9,
		bst4.attribute10,
		bst4.attribute11,
		bst4.attribute12,
		bst4.attribute13,
	 	bst4.attribute14,
		bst4.attribute15
	  from	BOM_SHIFT_TIMES bst4
         where  bst4.calendar_code = x_calendar_code_from
	   and  bst4.shift_num = x_shift_num_from;


  select NVL(MAX(seq_num),0)
  into v_max_seq_num
  from BOM_WORKDAY_PATTERNS  bwp
  where bwp.calendar_code = x_calendar_code_to;

  insert into BOM_WORKDAY_PATTERNS
              ( calendar_code,
                shift_num,
                seq_num,
                last_update_date,
                last_updated_by,
                creation_date,
                created_by,
                last_update_login,
                days_on,
                days_off,
                description,
                attribute_category,
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
                attribute15 )
        select
                x_calendar_code_to,
                x_shift_num_from,
                v_max_seq_num + bwp7.seq_num,
                sysdate,
		x_userid,
                sysdate,
		x_userid,
		x_userid,
                bwp7.days_on,
                bwp7.days_off,
                bwp7.description,
                bwp7.attribute_category,
                bwp7.attribute1,
                bwp7.attribute2,
                bwp7.attribute3,
                bwp7.attribute4,
                bwp7.attribute5,
                bwp7.attribute6,
                bwp7.attribute7,
                bwp7.attribute8,
                bwp7.attribute9,
                bwp7.attribute10,
                bwp7.attribute11,
                bwp7.attribute12,
                bwp7.attribute13,
                bwp7.attribute14,
                bwp7.attribute15
      	  from 	BOM_WORKDAY_PATTERNS bwp7
         where 	bwp7.calendar_code = x_calendar_code_from
  	   and	bwp7.shift_num = x_shift_num_from;

  insert into BOM_SHIFT_EXCEPTIONS
              ( calendar_code,
                shift_num,
                exception_set_id,
                exception_date,
		exception_type,
                last_update_date,
                last_updated_by,
                last_update_login,
                creation_date,
                created_by,
                attribute_category,
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
                attribute15 )
        select
                x_calendar_code_to,
                x_shift_num_from,
                -1,
                bse1.exception_date,
		bse1.exception_type,
                sysdate,
		x_userid,
		x_userid,
                sysdate,
	 	x_userid,
                bse1.attribute_category,
                bse1.attribute1,
                bse1.attribute2,
                bse1.attribute3,
                bse1.attribute4,
                bse1.attribute5,
                bse1.attribute6,
                bse1.attribute7,
                bse1.attribute8,
                bse1.attribute9,
                bse1.attribute10,
                bse1.attribute11,
                bse1.attribute12,
                bse1.attribute13,
                bse1.attribute14,
                bse1.attribute15
         from   BOM_SHIFT_EXCEPTIONS bse1
	where 	bse1.calendar_code = x_calendar_code_from
	  and	bse1.shift_num = x_shift_num_from
 	  and   bse1.exception_date >= x_start_date
	  and   bse1.exception_date <= x_end_date;

END Copy_Cal_Spec_Shift;



PROCEDURE Copy_Shift_Times (x_calendar_code_from VARCHAR2,
                            x_calendar_code_to   VARCHAR2,
			    x_shift_num_from	 NUMBER,
			    x_shift_num_to  	 NUMBER,
			    x_userid		 NUMBER) IS

BEGIN

  insert into BOM_SHIFT_TIMES
 	      (	calendar_code,
		shift_num,
		from_time,
		to_time,
		last_update_date,
		last_updated_by,
		last_update_login,
		creation_date,
		created_by,
		attribute_category,
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
		attribute15 )
      	select
		x_calendar_code_to,
		x_shift_num_to,
		bst.from_time,
		bst.to_time,
		sysdate,
		x_userid,
		x_userid,
		sysdate,
		x_userid,
		bst.attribute_category,
		bst.attribute1,
		bst.attribute2,
		bst.attribute3,
		bst.attribute4,
		bst.attribute5,
		bst.attribute6,
		bst.attribute7,
		bst.attribute8,
		bst.attribute9,
		bst.attribute10,
		bst.attribute11,
		bst.attribute12,
		bst.attribute13,
		bst.attribute14,
		bst.attribute15
	  from	BOM_SHIFT_TIMES bst
 	 where  bst.calendar_code = x_calendar_code_from
	   and	bst.shift_num = x_shift_num_from
           and	not exists ( select 1
			       from BOM_SHIFT_TIMES bst1
			      where bst1.calendar_code = x_calendar_code_to
				and bst1.shift_num = x_shift_num_to
				and bst1.from_time = bst.from_time
				and bst1.to_time = bst.to_time );

END Copy_Shift_Times;



PROCEDURE Copy_Shift_Exceptions (x_calendar_code_from  	VARCHAR2,
				 x_calendar_code_to	VARCHAR2,
				 x_shift_num_from	NUMBER,
				 x_shift_num_to		NUMBER,
				 x_start_date		DATE,
				 x_end_date		DATE,
				 x_userid		NUMBER) IS

BEGIN

  insert into BOM_SHIFT_EXCEPTIONS
 	      (	calendar_code,
		shift_num,
		exception_set_id,
		exception_date,
		exception_type,
		last_update_date,
		last_updated_by,
		last_update_login,
		creation_date,
		created_by,
		attribute_category,
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
		attribute15 )
      	select
		x_calendar_code_to,
		x_shift_num_to,
		-1,
		bse.exception_date,
		bse.exception_type,
		sysdate,
		x_userid,
		x_userid,
		sysdate,
		'-99999',
		bse.attribute_category,
		bse.attribute1,
		bse.attribute2,
		bse.attribute3,
		bse.attribute4,
		bse.attribute5,
		bse.attribute6,
		bse.attribute7,
		bse.attribute8,
		bse.attribute9,
		bse.attribute10,
		bse.attribute11,
		bse.attribute12,
		bse.attribute13,
		bse.attribute14,
		bse.attribute15
	 from	BOM_SHIFT_EXCEPTIONS bse
	where	bse.calendar_code = x_calendar_code_from
  	  and   bse.shift_num = x_shift_num_from
	  and	bse.exception_date not in
			(select bse1.exception_date
			   from BOM_SHIFT_EXCEPTIONS bse1
			  where bse1.calendar_code = x_calendar_code_to
			    and bse1.shift_num = x_shift_num_to)
	  and   bse.exception_date >= x_start_date
  	  and   bse.exception_date <= x_end_date;

END Copy_Shift_Exceptions;



PROCEDURE Copy_Exceptions_Cal (x_calendar_code_to   VARCHAR2,
			       x_exception_set_name VARCHAR2,
			       x_start_date	    DATE,
			       x_end_date	    DATE,
			       x_userid		    NUMBER) IS

BEGIN

  insert into BOM_CALENDAR_EXCEPTIONS
 	      (	calendar_code,
		exception_set_id,
		exception_date,
	        exception_type,
		last_update_date,
		last_updated_by,
		last_update_login,
		creation_date,
		created_by,
		attribute_category,
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
		attribute15 )
	select
		x_calendar_code_to,
		-1,
		besd.exception_date,
		besd.exception_type,
		sysdate,
		x_userid,
		x_userid,
		sysdate,
		'-99999',
		besd.attribute_category,
		besd.attribute1,
		besd.attribute2,
		besd.attribute3,
		besd.attribute4,
		besd.attribute5,
		besd.attribute6,
		besd.attribute7,
		besd.attribute8,
		besd.attribute9,
		besd.attribute10,
		besd.attribute11,
		besd.attribute12,
		besd.attribute13,
		besd.attribute14,
		besd.attribute15
	  from	BOM_EXCEPTION_SET_DATES besd, BOM_EXCEPTION_SETS bes
	 where	bes.exception_set_name = x_exception_set_name
  	   and  bes.exception_set_id = besd.exception_set_id
	   and  trunc(besd.exception_date) not in (
			select 	trunc(bce.exception_date)
			  from	BOM_CALENDAR_EXCEPTIONS bce
			 where	bce.calendar_code = x_calendar_code_to )
	   and trunc(besd.exception_date) >= x_start_date
	   and trunc(besd.exception_date) <= x_end_date;

END Copy_Exceptions_Cal;



Procedure Copy_Shift_Exceptions_Cal (x_calendar_code_from   VARCHAR2,
				     x_calendar_code_to     VARCHAR2,
		                     x_shift_num_from	    NUMBER,
				     x_start_date	    DATE,
				     x_end_date		    DATE,
				     x_userid		    NUMBER) IS

BEGIN

  insert into BOM_CALENDAR_EXCEPTIONS
	      ( calendar_code,
                exception_set_id,
                exception_date,
                last_update_date,
                last_updated_by,
                last_update_login,
                creation_date,
                created_by,
                exception_type,
                attribute_category,
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
                attribute15 )
        select
                x_calendar_code_to,
                -1,
                bse9.exception_date,
                sysdate,
		x_userid,
		x_userid,
                sysdate,
		'-99999',
                bse9.exception_type,
                bse9.attribute_category,
                bse9.attribute1,
                bse9.attribute2,
                bse9.attribute3,
                bse9.attribute4,
                bse9.attribute5,
                bse9.attribute6,
                bse9.attribute7,
                bse9.attribute8,
                bse9.attribute9,
                bse9.attribute10,
                bse9.attribute11,
                bse9.attribute12,
                bse9.attribute13,
                bse9.attribute14,
                bse9.attribute15
	 from	BOM_SHIFT_EXCEPTIONS bse9
	where	bse9.calendar_code = x_calendar_code_from
	  and	bse9.shift_num = x_shift_num_from
	  and   bse9.exception_date not in
			(select bce9.exception_date
			   from BOM_CALENDAR_EXCEPTIONS bce9
			  where bce9.calendar_code = x_calendar_code_to)
	  and   bse9.exception_date >= x_start_date
	  and   bse9.exception_date <= x_end_date;

END Copy_Shift_Exceptions_Cal;



PROCEDURE Copy_Exceptions_Shift (x_calendar_code_to   VARCHAR2,
				 x_shift_num_to       NUMBER,
			         x_exception_set_name VARCHAR2,
				 x_start_date	      DATE,
				 x_end_date	      DATE,
				 x_userid	      NUMBER) IS

BEGIN

  insert into BOM_SHIFT_EXCEPTIONS
 	      (	calendar_code,
		shift_num,
		exception_set_id,
		exception_date,
	        exception_type,
		last_update_date,
		last_updated_by,
		last_update_login,
		creation_date,
		created_by,
		attribute_category,
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
		attribute15 )
	select
		x_calendar_code_to,
		x_shift_num_to,
	  	-1,
		besd.exception_date,
		besd.exception_type,
		sysdate,
		x_userid,
		x_userid,
		sysdate,
		'-99999',
		besd.attribute_category,
		besd.attribute1,
		besd.attribute2,
		besd.attribute3,
		besd.attribute4,
		besd.attribute5,
		besd.attribute6,
		besd.attribute7,
		besd.attribute8,
		besd.attribute9,
		besd.attribute10,
		besd.attribute11,
		besd.attribute12,
		besd.attribute13,
		besd.attribute14,
		besd.attribute15
	  from	BOM_EXCEPTION_SET_DATES besd, BOM_EXCEPTION_SETS bes
	 where	bes.exception_set_name = x_exception_set_name
	   and  bes.exception_set_id = besd.exception_set_id
	   and  trunc(besd.exception_date) not in (
			select 	trunc(bse.exception_date)
			  from	BOM_SHIFT_EXCEPTIONS bse
			 where	bse.calendar_code = x_calendar_code_to
			   and	bse.shift_num = x_shift_num_to )
     	   and  trunc(besd.exception_date) >= x_start_date
	   and  trunc(besd.exception_date) <= x_end_date ;

END Copy_Exceptions_Shift;


PROCEDURE Copy_Cal_Exceptions_Shift (x_calendar_code_from   VARCHAR2,
			 	     x_calendar_code_to	    VARCHAR2,
				     x_shift_num_to 	    NUMBER,
				     x_start_date	    DATE,
				     x_end_date	 	    DATE,
				     x_userid		    NUMBER) IS

BEGIN

  insert into BOM_SHIFT_EXCEPTIONS
	      (	calendar_code,
                shift_num,
                exception_set_id,
                exception_date,
                exception_type,
                last_update_date,
                last_updated_by,
                last_update_login,
                creation_date,
                created_by,
                attribute_category,
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
                attribute15 )
        select
                x_calendar_code_to,
                x_shift_num_to,
                -1,
                bce9.exception_date,
                bce9.exception_type,
                sysdate,
		x_userid,
		x_userid,
                sysdate,
		'-99999',
                bce9.attribute_category,
                bce9.attribute1,
                bce9.attribute2,
                bce9.attribute3,
                bce9.attribute4,
                bce9.attribute5,
                bce9.attribute6,
                bce9.attribute7,
                bce9.attribute8,
                bce9.attribute9,
                bce9.attribute10,
                bce9.attribute11,
                bce9.attribute12,
                bce9.attribute13,
                bce9.attribute14,
                bce9.attribute15
	 from	BOM_CALENDAR_EXCEPTIONS bce9
	where	bce9.calendar_code = x_calendar_code_from
	  and	bce9.exception_date not in
			(select bse9.exception_date
			   from BOM_SHIFT_EXCEPTIONS bse9
	 		  where bse9.calendar_code = x_calendar_code_to
			    and bse9.shift_num = x_shift_num_to)
	  and   bce9.exception_date >= x_start_date
	  and   bce9.exception_date <= x_end_date;

END Copy_Cal_Exceptions_Shift;



END BOM_COPY_CALENDAR;

/

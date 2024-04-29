--------------------------------------------------------
--  DDL for Package Body HXT_CLOCK_USER_EDITS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXT_CLOCK_USER_EDITS" AS
/* $Header: hxtclked.pkb 120.0 2005/05/29 06:01:29 appldev noship $ */

/********************************************************
 Because customers will have different definitions
 of what an Employee Number is, get_person_id exists
 as a user exit.
 For base system, this call will return
 a valid person_id, last_name, and first_name from
 the per_people_f using the input value employee_number
 passed in as a parameter.
*********************************************************/
FUNCTION get_person_id(i_employee_number IN VARCHAR2,
                       i_business_group_id IN NUMBER,
                       i_date_worked IN DATE,
                       o_person_id OUT NOCOPY NUMBER,
                       o_last_name OUT NOCOPY VARCHAR2,
		       o_first_name OUT NOCOPY VARCHAR2)RETURN NUMBER IS
BEGIN
  SELECT person_id,
	 last_name,
         first_name
    INTO o_person_id,
	 o_last_name,
	 o_first_name
    FROM per_people_f
   WHERE employee_number = i_employee_number
     AND i_date_worked BETWEEN effective_start_date
                           AND effective_end_date
     AND business_group_id = i_business_group_id;

   RETURN 0;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
       RETURN 1;
    WHEN OTHERS THEN
       RETURN 2;

END get_person_id;
/***********************************************
  determine_pay_date()
  Rules to define what day an employee is paid
  based upon the time punch will vary. We will
  pass in start_time, end_time, and the person_id
  as arguments to this function.
  Phase I merely sets the date worked = to the
  start time. Future releases will need to determine
  the date worked based upon the employee's
  work schedule.
************************************************/
FUNCTION determine_pay_date( i_start_time IN DATE,
			     i_end_time IN DATE,
                             i_person_id IN NUMBER,
                             o_date_worked OUT NOCOPY DATE) RETURN NUMBER IS
BEGIN
  o_date_worked := trunc(i_start_time);  -- SIR268
  RETURN 0;
END determine_pay_date;
END HXT_CLOCK_USER_EDITS;

/

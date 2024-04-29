--------------------------------------------------------
--  DDL for Package Body HR_ASSIGNMENT_SET
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_ASSIGNMENT_SET" AS
/* $Header: pyusasst.pkb 120.0 2005/05/29 09:17:43 appldev noship $ */

/*
 +=====================================================================+
 |              Copyright (c) 1997 Orcale Corporation                  |
 |                 Redwood Shores, California, USA                     |
 |                      All rights reserved.                           |
 +=====================================================================+
Name        : pyusasst.pkb

Description : The set of fuction will check and return 'Y' or 'N'
              based on the data. If the assignment_id or the person id
              is part of assignment_set then the function will return
              true else it will return false.
Change List
-----------

Version Date      Author          ER/CR No. Description of Change
-------+---------+---------------+---------+--------------------------
40.0    09-Aug-00 djoshi                    Date Created

=============================================================================

*/
/* The following function will  check if the assginment is
   part of assignment set or Not. If no assignment_set is defined then
   fuction will always return  'Y'. It is assumed that the
   assignment_id will be a valid assignemnt_id for the given period of
   time. The checking will be done in the query.  In a multi-threaded rep
   the assinment creation cursor will take care picking up the
   correct assignemnt_id based on the date.
   The logic of checking for person id is also the same. If the assignment_id
   of the person_id is in assignment_set then the fuction will return 'Y' and
   if no assignment_set_id is passed then also the fuction will return 'Y'
   in all other case the fuction will return 'N'.
*/

FUNCTION assignment_in_set(p_assignmentset_id number,
                           p_assignment_id number )
RETURN char IS



CURSOR  c_assignment_set(c_assignmentset_id number,c_assignment_id number) IS
SELECT  'Y' FROM hr_assignment_set_amendments
 WHERE  assignment_set_id = c_assignmentset_id
   AND  assignment_id    = c_assignment_id
   AND  upper(include_or_exclude) = 'I';



c_value varchar2(10);


BEGIN

  IF   p_assignmentset_id IS NULL THEN
     	return 'Y';
  END IF;

  OPEN c_assignment_set(p_assignmentset_id,p_assignment_id);
  FETCH c_assignment_set INTO c_value;
  IF c_value ='Y' THEN
     return 'Y';
  ELSE
     return 'N';
  END IF;
EXCEPTION
  WHEN OTHERS THEN
  return 'N';
END; /* assignment_in_set */

/* Following fuction checks to see if, for the person_id
   and assignment_set_id combination is there any assignment_id
   in the assignment set that iS included. If Any  assignment_id
   for a given person_id satisfies the above condition the fuction
   return 'Y'. If no assignment_set_id is passed then also the
   function will return 'Y'.Any error will make the fuction
   return 'F' Any error will make the fuction
   return 'F'

*/


FUNCTION person_in_set(p_assignment_set_id number,
                           p_person_id number )
RETURN char IS


CURSOR c_person_set(c_assignmentset_id number,c_person_id number) IS
select 'Y' from
      per_assignments_f paf,
      hr_assignment_set_amendments hasa
where
       hasa.assignment_set_id = C_ASSIGNMENTSET_ID AND
       hasa.ASSIGNMENT_ID = paf.assignment_id AND
       UPPER(hasa.include_or_exclude) = 'I' AND
       paf.person_id = C_PERSON_ID;
c_value varchar2(10);
Begin
  IF   p_assignment_set_id IS NULL THEN
     	return 'Y';
  END IF;

  OPEN c_person_set(p_assignment_set_id,p_person_id);
  FETCH c_person_set INTO c_value;
  IF c_value ='Y' THEN
     return 'Y';
  ELSE
     return 'N';
  END IF;
EXCEPTION
  WHEN OTHERS THEN
  return 'N';
END;


END HR_ASSIGNMENT_SET;

/

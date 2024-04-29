--------------------------------------------------------
--  DDL for Package HR_ASSIGNMENT_SET
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_ASSIGNMENT_SET" AUTHID CURRENT_USER AS
/* $Header: pyusasst.pkh 120.0 2005/05/29 09:17:54 appldev noship $ */



/*
Name        : hr_assignment_set (Header)
File        : pyusasst.pkh
Description : This package will check if the assignment_id is in
              assignemnt_set or if the person's assigment is in
              assignment_set_id


Change List
-----------

Version Date      Author                 ER/CR No. Description of Change
-------+---------+----------------------+---------+--------------------------

40.0    09-aug-00  djoshi                           This fuction returns True
                                                    or False based on whether
                                                    the assignment_id  or
                                                    person_id is part of the
                                                    assignment_set
=============================================================================

*/
FUNCTION assignment_in_set(p_assignmentset_id in number,
                           p_assignment_id     in number)
                         RETURN char;
         PRAGMA RESTRICT_REFERENCES(assignment_in_set,WNDS,WNPS);
FUNCTION person_in_set(p_assignment_set_id in number,
                           p_person_id     in number)
                         RETURN char;
         PRAGMA RESTRICT_REFERENCES(person_in_set,WNDS,WNPS);
end hr_assignment_set;


 

/

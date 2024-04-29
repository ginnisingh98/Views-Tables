--------------------------------------------------------
--  DDL for Package PER_VALID_GRADES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_VALID_GRADES_PKG" AUTHID CURRENT_USER as
/* $Header: pevgr01t.pkh 115.1 2004/01/13 05:16:30 bsubrama ship $ */
--
PROCEDURE get_grade(p_grade_id    in     number,
          p_grade       IN OUT nocopy VARCHAR2);
--
PROCEDURE get_next_sequence(p_valid_grade_id in out nocopy number);
--
-- Bug 3338072
-- Added new parameters p_date_from and p_date_to
PROCEDURE check_unique_grade(
   p_business_group_id       in number,
   p_job_id                  in number,
   p_grade_id                in number,
   p_rowid                   in varchar2,
   p_date_from               in date,
   p_date_to                 in date default null );
--
PROCEDURE check_date_from(p_grade_id  number,
           p_date_from date);
--
PROCEDURE check_date_to(p_grade_id    number,
         p_date_to     date,
         p_end_of_time date);
--
END PER_VALID_GRADES_PKG;

 

/

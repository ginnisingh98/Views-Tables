--------------------------------------------------------
--  DDL for Package PER_ABV_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_ABV_PKG" AUTHID CURRENT_USER as
/* $Header: peabv01t.pkh 115.1 99/07/17 18:23:47 porting ship $ */
/*===========================================================================+
 |               Copyright (c) 1993 Oracle Corporation                       |
 |                  Redwood Shores, California, USA                          |
 |                       All rights reserved.                                |
 +===========================================================================*/
--
--
--
-- 110.1 SASmith  31-MAR-1998    Change to include new procedure get_parent_max_end_date.
--				 This will return the maximum end date for the assignment.
--
--
--
procedure pre_commit_checks(p_assignment_id number
                          ,p_unit varchar2
                          ,p_rowid varchar2
                          ,p_unique_id IN OUT number);
--
--
procedure populate_fields(p_unit varchar2
                         ,p_unit_meaning IN OUT varchar2);
--
--
procedure check_for_duplicate_record(p_assignment_id number
                                    ,p_unit varchar2
                                    ,p_start_date date
                                    ,p_end_date date );

procedure get_parent_max_end_date(p_assignment_id IN number
                                 ,p_end_date IN OUT date);




--
--

END PER_ABV_PKG;

 

/

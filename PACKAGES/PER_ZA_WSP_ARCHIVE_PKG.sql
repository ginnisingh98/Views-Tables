--------------------------------------------------------
--  DDL for Package PER_ZA_WSP_ARCHIVE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_ZA_WSP_ARCHIVE_PKG" AUTHID CURRENT_USER as
/* $Header: perzawspa.pkh 120.1.12010000.1 2008/07/28 05:54:31 appldev ship $ */

/*+======================================================================+
  |       Copyright (c) 2002 Oracle Corporation                          |
  |                           All rights reserved.                       |
  +======================================================================+
  SQL Script File name : perzawspa.pkh
  Description          : This sql script seeds the Package Header that
                         creates the Workplace Skills Plan Archive code

  Change List:
  ------------

  Name           Date        Version Bug     Text
  -------------- ----------- ------- ------  ----------------------------
  A Mahanty      11-DEC-2006  115.0           First created
  A Mahanty      19-Feb-2007  115.1           Removed gscc errors
  A Mahanty      22-Feb-2007	115.2           Added get_parameter
 ========================================================================
*/

procedure range_cursor
(
   pactid in  number,
   sqlstr out nocopy varchar2
);

procedure action_creation
(
   pactid    in number,
   stperson  in number,
   endperson in number,
   chunk     in number
);

procedure archive_init
(
   pactid in number
);

procedure archive_data
(
   p_assactid       in number,
   p_effective_date in date
);

function get_occupational_category
(
   p_report_date       in per_all_assignments_f.effective_end_date%type,
   p_assignment_id     in per_all_assignments_f.assignment_id%type,
   p_job_id            in per_all_assignments_f.job_id%type,
   p_grade_id          in per_all_assignments_f.grade_id%type,
   p_position_id       in per_all_assignments_f.position_id%type,
   p_business_group_id in per_all_assignments_f.business_group_id%type
)  return varchar2 ;

function get_parameter
(
   name            in varchar2,
   parameter_list  in varchar2
)  return varchar2;

end PER_ZA_WSP_ARCHIVE_PKG;

/

--------------------------------------------------------
--  DDL for Package HRSPINE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRSPINE" AUTHID CURRENT_USER as
/* $Header: pespines.pkh 120.0.12010000.1 2008/07/28 05:59:19 appldev ship $ */
--
--
-- Copyright (c) Oracle Corporation 1991, 1992, 1993. All rights reserved.
--
/*
   NAME
      pyspines.pkh
--
   DESCRIPTION
      Package header for the procedure used in the spinal incrementing
      process.
--
  MODIFIED (DD-MON-YYYY)
     mwcallag   17-JUN-1993 - created.
     stlocke    12-DEC-2001 - Added additional params for new business rule
			      functionality.

rem Change List
rem ===========
rem
rem Version Date        Author         Comment
rem -------+-----------+--------------+----------------------------------------
rem 115.8   25-APR-2002 stlocke	       Added functions used by employee increment
rem				       results report.
rem 115.10  09-DEC-2002 eumenyio       Added whenever oserror
*/

function func_old_spinal_point (p_placement_id 	       in number
			       ,p_effective_start_date in date
			       ,p_step_id   	       in number
			       ,p_grade_rate	       in number) return VARCHAR2;
function func_old_spinal_value (p_placement_id         in number
                               ,p_effective_start_date in date
                               ,p_step_id              in number
                               ,p_grade_rate           in number) return NUMBER;
function func_increment        (p_placement_id         in number
                               ,p_effective_start_date in date
                               ,p_step_id              in number
                               ,p_grade_spine_id       in number) return NUMBER;

    procedure spine
    (
    P_Parent_Spine_ID      	in number default null,
    P_Effective_Date       	in date,
    p_id_flex_num          	in number default null,
    p_concat_segs          	in varchar2 default null,
    P_Business_Group_ID	   	in number,
    p_collective_agreement_id 	in number default null,
    p_person_id                 in number default null,
    p_payroll_id                in number default null,
    p_organization_id           in number default null,
    p_legal_entity              in number default null,
    p_org_structure_ver_id      in number default null,
--    p_ass_sets                  in number default null,
    p_qual_type                 in number default null,
    p_qual_status               in varchar2 default null,
    p_org_structure_top_node    in number default null,
    p_rate_id			in number default null,
    p_business_rule		in varchar2 default null,
    p_dependant_date		in varchar2 default null,
    p_br_date_from		in date default null,
    p_br_date_to                in date default null,
    p_year_from			in number default null,
    p_year_to			in number default null,
    p_message_number	 out nocopy varchar2
    );

end hrspine;

/

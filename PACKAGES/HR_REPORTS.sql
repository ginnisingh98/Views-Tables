--------------------------------------------------------
--  DDL for Package HR_REPORTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_REPORTS" AUTHID CURRENT_USER AS
/* $Header: peperrep.pkh 120.1 2007/09/12 21:39:15 rnestor noship $
 ******************************************************************
 *                                                                *
 *  Copyright (C) 1992 Oracle Corporation UK Ltd.,                *
 *                   Chertsey, England.                           *
 *                                                                *
 *  All rights reserved.                                          *
 *                                                                *
 *  This material has been provided pursuant to an agreement      *
 *  containing restrictions on its use.  The material is also     *
 *  protected by copyright law.  No part of this material may     *
 *  be copied or distributed, transmitted or transcribed, in      *
 *  any form or by any means, electronic, mechanical, magnetic,   *
 *  manual, or otherwise, or disclosed to third parties without   *
 *  the express written permission of Oracle Corporation UK Ltd,  *
 *  Oracle Park, Bittams Lane, Guildford Road, Chertsey, Surrey,  *
 *  England.                                                      *
 *                                                                *
 ******************************************************************
 Name        : hr_reports (HEADER)
 File        : peperrep.pkh
 Description : This package declares functions which are used to
	       return Values for the SRW2 reports.

 Change List
 -----------

 Version Date      Author     ER/CR No. Description of Change
 -------+---------+----------+---------+--------------------------
 70.0    17-JUN-93 JRHODES              Date Created
 70.1    23-JUN-93 JHOBBS               Added get_business_group.
 70.2    30-JUN-93 JHOBBS               Changed get_organization and added
					count_org_subordinates,
					get_lookup_meaning,
					get_organization_hierarchy,
					count_pos_subordinates,
					get_position_hierarchy
		   JRHODES              Added person_matching_skills,
					get_job,
					get_position
		   PCHAPPEL             Added get_payroll_name
	07-JUL-93  PCHAPPEL             added get_element_name
					and changed names to hr_reports
	12-JUL-93  JRHODES              Split_segments
					Gen_partial_matching_lexical
	14_JUL-93  JHOBBS               Added get_desc_flex and
					get_dvlpr_desc_flex
 70.3   04-AUG-93  nkhan                Added get_attributes,
					and split_attributes
					COPIED from jrhodes codes
 70.4   05-AUG-93  JRHODES              Added get_grades and
					get_status
 70.5   05-AUG-93  NKHAN                Chahged get_attributes -
					p_title to p_name
 70.6   06-AUG-93  JHOBBS               Added get_person_name.
 70.7   09-AUG-93  JRHODES              Added get_abs_type
 70.13  13-SEP-95  AMILLS               Added  procedure
					get_desc_flex_context.
 70.11  11-OCT-95  JTHURING             Removed spurious end of comment marker
 110.1  28-NOV-97  MMILLMOR     563806  Changed split_segments and
                                        gen_partial_matching_lexical to take
                                        an additional paramater p_id_flex_code
                                        to correctly identify flexfields.
                                        Procedures are overloaded.
 110.2  01-DEC-97  MMILLMOR     550991  Changed get_desc_flex_context to only
                                        display fields with the given display
                                        flag. Preserved old function by
                                        overloading.
 110.3  10-FEB-98  SBHATTAL   622283    Created new versions of procedures
					1) get_dvlpr_desc_flex
					2) split_attributes
					3) get_attributes
					with an extra parameter
					(p_aol_seperator_flag).
					Retained old versions of these
					procedures for existing calls in
					reports (procedure overloading).
 110.4  15-SEP-99  ASAHAY       641528  Changed split-segments and
                                        gen_partial_matching_lexical to
                                        overload new functionality.
 115.2  12-01-2001 CSIMPSON    1512969  added overloaded get_position
                                        function to return position name
                                        for position_id on the effective
                                        date parameter.
 115.3  30-07-2002 VRAMANAI    2404099  Changed the SegmentTabType from
                                        table of varchar2(60) to table
                                        of varchar2(240)
 115.4  01-08-2002 tabedin     2404098  To avoid gscc warning, changed phase
                                        to pls and moved set verify line to
                                        the begining
 115.5  02-NOV-2002 eumenyio            added nocopy.
 115.6  04-FEB-2005 smparame   4081149  Added new function get_party_number
                                        to return party_number for a party.
 115.8  21-MAR-2007 ande       5651801  Changed return type of get_party_number
                                        to varchar2.
 =================================================================
*/
TYPE SegmentTabType IS TABLE OF VARCHAR2(240)
     INDEX BY BINARY_INTEGER;
SEGTAB SegmentTabType;
SegmentValue1 VARCHAR2(240);
--
--
function get_budget
(p_budget_id            number) return varchar2;
--
--
function get_budget_version
(p_budget_id            number
,p_budget_version_id    number) return varchar2;
--
--
procedure get_organization
(p_organization_id  in  number,
 p_org_name         out nocopy varchar2,
 p_org_type         out nocopy varchar2);
--
--
function get_job
(p_job_id            number) return varchar2;
--
--
function get_position
(p_position_id            number) return varchar2;
--
function get_position
(p_position_id            number,
 p_effective_date         date) return varchar2;
--
function get_grade
(p_grade_id            number) return varchar2;
--
--
function get_status
(p_business_group_id         number,
 p_assignment_status_type_id number,
 p_legislation_code          varchar2 ) return varchar2;
--
--
function get_abs_type
(p_abs_att_type_id            number) return varchar2;
--
--
procedure get_time_period
(p_time_period_id         in number
,p_period_name           out nocopy varchar2
,p_start_date            out nocopy date
,p_end_date              out nocopy date);
--
--
function get_business_group
(p_business_group_id    number) return varchar2;
--
--
function count_org_subordinates
(p_org_structure_version_id  number,
 p_parent_organization_id    number) return number;
--
--
function count_pos_subordinates
(p_pos_structure_version_id  number,
 p_parent_position_id        number) return number;
--
--
procedure get_organization_hierarchy
(p_organization_structure_id in  number,
 p_org_structure_version_id  in  number,
 p_org_structure_name        out nocopy varchar2,
 p_org_version               out nocopy number,
 p_version_start_date        out nocopy date,
 p_version_end_date          out nocopy date);
--
--
procedure get_position_hierarchy
(p_position_structure_id     in  number,
 p_pos_structure_version_id  in  number,
 p_pos_structure_name        out nocopy varchar2,
 p_pos_version               out nocopy number,
 p_version_start_date        out nocopy date,
 p_version_end_date          out nocopy date);
--
--
function get_lookup_meaning
(p_lookup_type  varchar2,
 p_lookup_code  varchar2) return varchar2;
--
--
function person_matching_skills
(p_person_id         in number
,p_job_position_id   in number
,p_job_position_type in varchar2
,p_matching_level    in varchar2
,p_no_of_essential   in number
,p_no_of_desirable   in number)  return boolean;
--
--
function get_payroll_name
(p_session_date date,
 p_payroll_id   number) return varchar2;
--
--
function get_element_name
(p_session_date date,
 p_element_type_id number) return varchar2;
--
--
procedure split_attributes
(p_concatenated_segments in varchar2
,p_title                 in varchar2
,p_segtab               out nocopy segmenttabtype
,p_segments_used        out nocopy number);
--
-- Added for bug fix 622283, version 110.3
--
procedure split_attributes
(p_concatenated_segments in varchar2
,p_title                 in varchar2
,p_aol_seperator_flag    in boolean
,p_segtab               out nocopy segmenttabtype
,p_segments_used        out nocopy number);
--
--
procedure split_segments
(p_concatenated_segments in varchar2
,p_id_flex_num           in number
,p_segtab               out nocopy segmenttabtype
,p_segments_used        out nocopy number);
--
--
procedure split_segments
(p_concatenated_segments in varchar2
,p_id_flex_num           in number
,p_segtab               out nocopy segmenttabtype
,p_segments_used        out nocopy number
,p_id_flex_code          in varchar2);
--
--
procedure split_segments
(p_concatenated_segments in varchar2
,p_id_flex_num           in number
,p_segtab               out nocopy segmenttabtype
,p_segments_used        out nocopy number
,p_id_flex_code          in varchar2
,p_application_id 	in number);
--
--
procedure gen_partial_matching_lexical
(p_concatenated_segments in varchar2
,p_id_flex_num    in number
,p_matching_lexical in out nocopy varchar2);
--
--
procedure gen_partial_matching_lexical
(p_concatenated_segments in varchar2
,p_id_flex_num    in number
,p_matching_lexical in out nocopy varchar2
,p_id_flex_code    in varchar2);
--
--
procedure gen_partial_matching_lexical
(p_concatenated_segments in varchar2
,p_id_flex_num    in number
,p_matching_lexical in out nocopy varchar2
,p_id_flex_code    in varchar2
,p_application_id	in number);
--
--
procedure get_attributes
(p_concatenated_segments in varchar2
,p_name          in varchar2
,p_segments_used out nocopy number
,p_value1 out nocopy varchar2
,p_value2 out nocopy varchar2
,p_value3 out nocopy varchar2
,p_value4 out nocopy varchar2
,p_value5 out nocopy varchar2
,p_value6 out nocopy varchar2
,p_value7 out nocopy varchar2
,p_value8 out nocopy varchar2
,p_value9 out nocopy varchar2
,p_value10 out nocopy varchar2
,p_value11 out nocopy varchar2
,p_value12 out nocopy varchar2
,p_value13 out nocopy varchar2
,p_value14 out nocopy varchar2
,p_value15 out nocopy varchar2
,p_value16 out nocopy varchar2
,p_value17 out nocopy varchar2
,p_value18 out nocopy varchar2
,p_value19 out nocopy varchar2
,p_value20 out nocopy varchar2
,p_value21 out nocopy varchar2
,p_value22 out nocopy varchar2
,p_value23 out nocopy varchar2
,p_value24 out nocopy varchar2
,p_value25 out nocopy varchar2
,p_value26 out nocopy varchar2
,p_value27 out nocopy varchar2
,p_value28 out nocopy varchar2
,p_value29 out nocopy varchar2
,p_value30 out nocopy varchar2 );
--
-- Added for bug fix 622283, version 110.3
--
procedure get_attributes
(p_concatenated_segments 	in varchar2
,p_name          		in varchar2
,p_aol_seperator_flag		in boolean
,p_segments_used 	 out nocopy number
,p_value1 out nocopy varchar2
,p_value2 out nocopy varchar2
,p_value3 out nocopy varchar2
,p_value4 out nocopy varchar2
,p_value5 out nocopy varchar2
,p_value6 out nocopy varchar2
,p_value7 out nocopy varchar2
,p_value8 out nocopy varchar2
,p_value9 out nocopy varchar2
,p_value10 out nocopy varchar2
,p_value11 out nocopy varchar2
,p_value12 out nocopy varchar2
,p_value13 out nocopy varchar2
,p_value14 out nocopy varchar2
,p_value15 out nocopy varchar2
,p_value16 out nocopy varchar2
,p_value17 out nocopy varchar2
,p_value18 out nocopy varchar2
,p_value19 out nocopy varchar2
,p_value20 out nocopy varchar2
,p_value21 out nocopy varchar2
,p_value22 out nocopy varchar2
,p_value23 out nocopy varchar2
,p_value24 out nocopy varchar2
,p_value25 out nocopy varchar2
,p_value26 out nocopy varchar2
,p_value27 out nocopy varchar2
,p_value28 out nocopy varchar2
,p_value29 out nocopy varchar2
,p_value30 out nocopy varchar2 );
--
--
procedure get_segments
(p_concatenated_segments in varchar2
,p_id_flex_num   in number
,p_segments_used out nocopy number
,p_value1 out nocopy varchar2
,p_value2 out nocopy varchar2
,p_value3 out nocopy varchar2
,p_value4 out nocopy varchar2
,p_value5 out nocopy varchar2
,p_value6 out nocopy varchar2
,p_value7 out nocopy varchar2
,p_value8 out nocopy varchar2
,p_value9 out nocopy varchar2
,p_value10 out nocopy varchar2
,p_value11 out nocopy varchar2
,p_value12 out nocopy varchar2
,p_value13 out nocopy varchar2
,p_value14 out nocopy varchar2
,p_value15 out nocopy varchar2
,p_value16 out nocopy varchar2
,p_value17 out nocopy varchar2
,p_value18 out nocopy varchar2
,p_value19 out nocopy varchar2
,p_value20 out nocopy varchar2
,p_value21 out nocopy varchar2
,p_value22 out nocopy varchar2
,p_value23 out nocopy varchar2
,p_value24 out nocopy varchar2
,p_value25 out nocopy varchar2
,p_value26 out nocopy varchar2
,p_value27 out nocopy varchar2
,p_value28 out nocopy varchar2
,p_value29 out nocopy varchar2
,p_value30 out nocopy varchar2 );
--
--
procedure get_desc_flex
(p_appl_short_name    in  varchar2,
 p_desc_flex_name     in  varchar2,
 p_table_alias        in   varchar2,
 p_title              out nocopy varchar2,
 p_label_expr         out nocopy varchar2,
 p_column_expr        out nocopy  varchar2);
--
--
procedure get_desc_flex_context
(p_appl_short_name    in  varchar2,
 p_desc_flex_name     in  varchar2,
 p_table_alias        in  varchar2,
 p_title              out nocopy varchar2,
 p_label_expr         out nocopy varchar2,
 p_column_expr        out nocopy varchar2);
--
--
procedure get_desc_flex_context
(p_appl_short_name    in  varchar2,
 p_desc_flex_name     in  varchar2,
 p_table_alias        in  varchar2,
 p_display            in  varchar2,
 p_title              out nocopy varchar2,
 p_label_expr         out nocopy varchar2,
 p_column_expr        out nocopy varchar2);
--
--
procedure get_dvlpr_desc_flex
(p_appl_short_name    in  varchar2,
 p_desc_flex_name     in  varchar2,
 p_desc_flex_context  in  varchar2,
 p_table_alias        in  varchar2,
 p_title              out nocopy varchar2,
 p_label_expr         out nocopy varchar2,
 p_column_expr        out nocopy varchar2);
--
-- Added for bug fix 622283, version 110.3
--
procedure get_dvlpr_desc_flex
(p_appl_short_name    in  varchar2,
 p_desc_flex_name     in  varchar2,
 p_desc_flex_context  in  varchar2,
 p_table_alias        in  varchar2,
 p_aol_seperator_flag in  boolean,
 p_title              out nocopy varchar2,
 p_label_expr         out nocopy varchar2,
 p_column_expr        out nocopy varchar2);
--
--
function get_person_name
(p_session_date date,
 p_person_id number) return varchar2;
--
--
-- Bug fix 4081149. added function
-- get_party_number
--
function get_party_number
(p_party_id in number) return varchar2;
--changed return type to varchar2
--
end hr_reports;

/

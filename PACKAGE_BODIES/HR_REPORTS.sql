--------------------------------------------------------
--  DDL for Package Body HR_REPORTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_REPORTS" AS
/* $Header: peperrep.pkb 120.1 2007/09/12 21:15:42 rnestor noship $
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
 Name        : hr_reports (BODY)
 File        : hr_reports.pkb
 Description : This package declares functions which are used to
	       return Values for the SRW2 reports.
--
 Change List
 -----------
--
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
		   JRHODES              Added person_matching_skills
					get_job,
					get_position
		   PCHAPPELL            Added get_payroll_name
	 07-JUL-93 PCHAPPELL            Added element_name
	 12-JUL-93 JRHODES              Split_segments
					Gen_partial_matching_lexical
	 14-JUL-93 JHOBBS               Added get_desc_flex and
					get_dvlpr_desc_flex.
70.3     04-AUG-93 NKHAN                Added get_attributes and
					aplit_segments
70.4     05-AUG-93 JRHODES              Added get_grade and get_status
70.5     05-AUG-93 NKHAN                Chahged get_attributes -
					p_title to p_name
70.6     06-AUG-93 JHOBBS               Added get_person_name
70.7     09-AUG-93 JRHODES              Added get_abs_type
70.8     23-oct-93 NKHAN                expanded l_concat_segs in both
					get_attributes  get_segments
					from 240->2000
 80.1/   29-Oct-93 JHobbs   B257        Increased Variable sizes for desc flex
 70.8                                   procedures to 2000 characters.
70.9/    25-Nov-93 Jhobbs   B278        Changed variable declarations to use
80.2                                    %type definitions so that variables are
					always the correct length.
 70.10   01-Mar-94 JRhodes               Altered person_matching_skills
					to allow partial matching
 70.12   23-Nov-94 RFine                Suppressed index on business_group_id
 70.13   13-Sep-95 AMills               Added procedure get_desc_flex_context
                                        that passes out nocopy a concatenated flex
	                                field in order that the report triggers
                                        pass a lexical field to the report
                                        queries.
 70.14   29-SEP-95 AMILLS               Altered person_matching_skills
                                        function to match on discreet segments
                                        instead of an exact segments matching
                                        set.
 70.17   11-OCT-95 JTHURING             Removed spurious end of comment marker
 70.18   22-DEC-95 AMILLS     330536    Changed size of v_label_expr to 32000
                                        to cope with large flexfields.
 70.19   07-MAY-96 AMILLS     363691    Placed conditional clause inside
                                        procedure get_desc_flex_context to
                                        test for assignment table alias as
                                        it uses ass_attribute_category as
                                        opposed to attribute_category.
 70.20   06-SEP-96 DKERR      399209    Replace 's with ''s in form_left_prompt
					columns.
 70.21   22-APR-97 HPATEL               Bug 434553. Altered person_matching_skills to bring                                        back the correct rows
--
 70.22   20-AUG-97 ASAHAY     523506    Placed conditional clause inside
                                        procedure get_desc_flex_context to
                                        test for contacts table alias as
                                        it uses cont_attribute_category as
                                        opposed to attribute_category.
--
110.2	21-AUG-97  Khabibul	N/A     Modified to use _VL views due to change
					in AOL 11.0.4.
110.3   28-NOV-97  MMILLMOR     563806  Changed split_segments and
                                        gen_partial_matching_lexical to take
                                        an additional paramater p_id_flex_code
                                        to correctly identify flexfields.
                                        Procedures are overloaded.
110.4   01-DEC-97  MMILLMOR     550991  Changed get_desc_flex_context to only
                                        display fields with the given display
                                        flag. Preserved old function by
                                        overloading.
110.5   16-DEC-97  MMILLMOR     550991  Changed above fix to default to only
                                        display those segments with the
                                        displayed flag set to 'Y'
110.6   10-FEB-98  SBHATTAL   622283    Created new versions of procedures
					1) get_dvlpr_desc_flex
					2) split_attributes
					3) get_attributes
					with an extra parameter
					(p_aol_seperator_flag).
					Retained old versions of these
					procedures for existing calls in
					reports (procedure overloading).
110.7   03-APR-98  ASAHAY     440841    Placed conditional clause inside
					procedure get_desc_flex_context to
					test for assignment extra info DDF
					table alias as paei as it uses
					aei_information_category as opposed
					to attribute_category.
110.8   12-OCT-98 ASAHAY     735632     Placed conditional clause inside
                                        procedure get_desc_flex_context to
                                        test for table alias (1) app as
                                        it uses appl_information_category
                                        as opposed to attribute_category.
                                        test for table alias (2) addr as
                                        it uses addr_information_category
                                        as opposed to attribute_category.
110.9   08-FEB-99 LTAYLOR               Changed and updated MLS and Date
                                        formats for release 11.5
110.10  09-FEB-99 LSIGRIST              Updated function get_element_name
                                        with MLS changes.
115.4   11-MAY-99 CCARTER     886635    Replaced chr() function calls with
                                        calls to fnd_global.local_chr();
115.5   06-JUL-99 CCARTER     875085    v_title changed from 40 to 60 chr
                                        in get_dvlpr_desc_flex and get_desc_
                                        flex_context.
115.6   15-SEP-99 ASAHAY     641528     Changed split_segments and
                                        gen_partial_matching_lexical to take
                                        an additional paramater p_id_flex_code
                                        to correctly identify flexfields.
                                        Procedures are overloaded.
115.7   21-SEP-99 CCARTER    991360     Added p_table_alias = 'f' in
                                        get_desc_flex_context.
115.8   01-Oct-99 SCNair                Date Track Position related Changes
115.9	22-OCT-99 ASahay     1010205	Increased variable length in
					get_desc_flex_context.
115.10  31-May-00 CTredwin   1123133    Added nvl in get_attributes() to
                                        prevent table access error
115.11  11-Jan-01 adhunter   1577078    Added clause to restrict by application_id
                                        in split_segments procedure
115.12  11-Jan-01 adhunter              Forgot to add above comment for 115.11
115.13  12-Jan-01 CSIMPSON   1512969    added overloaded get_position
                                        function to return position name
                                        for position_id on the effective
                                        date parameter.
115.16  01-Aug-02 tabedin    2404098    added set verify and placed whenever
                                        sqlerror line at the begining
115.17  23-Sep-02 vramanai   2567862    In get_desc_flex procedure,modified
                                        v_ column_expr and v_label_expr from 20000
                                        to 32000 char and in get_desc_flex_context
                                        procedure,SUBSTRB function is added to
                                        v_column_expr and v_label_expr
115.18  02-NOV-02 eumenyio              Added nocopy
115.19  12-DEC-02 joward                MLS enabled grade_name
115.20  27-DEC-02 joward                MLS enabled job name
115.21  17-FEB-03 rthiagar              Fix for bug 3440744. Used
                                        hr_all_organization_units_tl to get
                                        business group name to support
                                        translation.
115.22 22-JUN-04 adhunter               MLS enabled per_absence_attendance_types.name
115.23 07-FEB-05 smparame   4081149     New fucntion get_party_number added.
115.24 08-FEB-05 smparame   4157312     Function get_status modified to return correct
                                        status.
115.25 02-MAY-05 bshukla    4328224     Changed SQL id 12228906: Performance Repository
                                        Fix
115.27 21-MAR-07 ande       5651801     Changed return type of get_party_number
                                        to varchar2.

=================================================================
*/
--
--
FUNCTION get_budget
(p_budget_id            NUMBER  ) return VARCHAR2
--
AS
l_budget_name per_budgets.name%type;
--
begin
--
  hr_utility.trace('Entered Get_Budget');
  --
  hr_utility.set_location('hr_reports.get_budget',1);
  if p_budget_id IS NULL then
     null;
  else
   begin
    hr_utility.set_location('hr_reports.get_budget',5);
    SELECT name
    INTO   l_budget_name
    FROM   per_budgets
    WHERE  budget_id = p_budget_id;
    --
    exception  when NO_DATA_FOUND then null;
   end;
  end if;
  --
  return l_budget_name;
--
end get_budget;
--
--
FUNCTION get_budget_version
(p_budget_id            NUMBER
,p_budget_version_id    NUMBER) return VARCHAR2
--
AS
l_budget_version_number per_budget_versions.version_number%type;
--
begin
--
  hr_utility.trace('Entered Get_Budget_version');
  --
  hr_utility.set_location('hr_reports.get_budget_version',1);
  if p_budget_id IS NULL OR p_budget_version_id IS NULL then
     null;
  else
   begin
    hr_utility.set_location('hr_reports.get_budget_version',5);
    SELECT version_number
    INTO   l_budget_version_number
    FROM   per_budget_versions
    WHERE  budget_id = p_budget_id
    AND    budget_version_id = p_budget_version_id;
    --
    exception  when NO_DATA_FOUND then null;
   end;
  end if;
  --
  return l_budget_version_number;
--
end get_budget_version;
--
--
procedure get_organization
(p_organization_id  in  number,
 p_org_name         out nocopy varchar2,
 p_org_type         out nocopy varchar2)
--
as
begin
--
  hr_utility.trace('Entered get_organization');
  --
  hr_utility.set_location('hr_reports.get_organization',5);
  if p_organization_id is null then
    null;
  else
    begin
      hr_utility.set_location('hr_reports.get_organization',10);
      select orgtl.name,
	     hrl.meaning
      into   p_org_name,
	     p_org_type
      from   hr_all_organization_units_tl orgtl,
             hr_all_organization_units org,
	     hr_lookups hrl
      where  org.organization_id = p_organization_id
        and  org.organization_id = orgtl.organization_id
	and  hrl.lookup_type (+) = 'ORG_TYPE'
	and  hrl.lookup_code (+) = org.type
        and  orgtl.LANGUAGE = userenv('LANG');
    exception
      when no_data_found then null;
    end;
  end if;
  --
--
end get_organization;
--
--
FUNCTION get_job
(p_job_id            NUMBER) return VARCHAR2
--
AS
l_job_name per_jobs.name%type;
--
begin
--
  hr_utility.trace('Entered Get_Job');
  --
   begin
    hr_utility.set_location('hr_reports.get_job',5);
    SELECT name
    INTO   l_job_name
    FROM   per_jobs_vl
    WHERE  job_id = p_job_id;
    --
    exception  when NO_DATA_FOUND then null;
   end;
  --
  return l_job_name;
--
end get_job;
--
--
FUNCTION get_position
(p_position_id            NUMBER) return VARCHAR2
--
AS
--
-- Changed 02-Oct-99 SCNair (per_positions to hr_positions) Date Tracked Positions requirement
--
l_position_name hr_positions.name%type;
--
begin
--
  hr_utility.trace('Entered Get_position');
  --
   begin
    --
    -- Changed 02-Oct-99 SCNair (per_positions to hr_positions) Date Tracked Positions requirement
    --
    hr_utility.set_location('hr_reports.get_position',5);
    SELECT name
    INTO   l_position_name
    FROM   hr_positions
    WHERE  position_id = p_position_id;
    --
    exception  when NO_DATA_FOUND then null;
   end;
  --
  return l_position_name;
--
end get_position;
--
--
FUNCTION get_position
(p_position_id            NUMBER,
 p_effective_date         DATE) return VARCHAR2
--
-- Returns position name on the effective date parameter (this is not necessarily same
-- not session date, so selects from the hr_positions_f view rather than hr_positions view).
--
AS
--
l_position_name hr_all_positions_f.name%type;
--
begin
--
  hr_utility.trace('Entered Get_position');
  --
   begin
    --
    --
    hr_utility.set_location('hr_reports.get_position',5);
    SELECT name
    INTO   l_position_name
    FROM   hr_positions_f paf
    WHERE  paf.position_id = p_position_id
    AND    p_effective_date between paf.effective_start_date and paf.effective_end_date;
    --
    exception  when NO_DATA_FOUND then null;
   end;
  --
  return l_position_name;
--
end get_position;
--
--
FUNCTION get_grade
(p_grade_id          NUMBER) return VARCHAR2
--
AS
l_grade_name per_grades.name%type;
--
begin
--
  hr_utility.trace('Entered Get_Grade');
  --
   begin
    hr_utility.set_location('hr_reports.get_grade',5);
    SELECT name
    INTO   l_grade_name
    FROM   per_grades_vl
    WHERE  grade_id = p_grade_id;
    --
    exception  when NO_DATA_FOUND then null;
   end;
  --
  return l_grade_name;
--
end get_grade;
--
--
FUNCTION get_status
(p_business_group_id            NUMBER,
 p_assignment_status_type_id    NUMBER,
 p_legislation_code             VARCHAR2) return VARCHAR2
--
AS
l_user_status per_assignment_status_types_tl.user_status%type;
--
begin
--
  hr_utility.trace('Entered Get_Status');
  --
   begin
    hr_utility.set_location('hr_reports.get_status',5);
    -- bug fix 4157312
    -- join between per_ass_status_type_amends_tl and
    -- per_ass_status_type_amends changed to outer join.

    SELECT nvl(btl.user_status,atl.user_status)
    INTO   l_user_status
    from   per_assignment_status_types_tl atl
    ,      per_assignment_status_types a
    ,      per_ass_status_type_amends_tl btl
    ,      per_ass_status_type_amends b
    where  b.assignment_status_type_id(+) = a.assignment_status_type_id
    and    a.assignment_status_type_id = atl.assignment_status_type_id
    and    b.ass_status_type_amend_id = btl.ass_status_type_amend_id(+)
    and    a.assignment_status_type_id = P_ASSIGNMENT_STATUS_TYPE_ID
    and    b.business_group_id(+) + 0 = P_BUSINESS_GROUP_ID
    and    nvl(a.business_group_id,P_BUSINESS_GROUP_ID) =
				   P_BUSINESS_GROUP_ID
    and    nvl(a.legislation_code, P_LEGISLATION_CODE) =
				   P_LEGISLATION_CODE
    and    nvl(b.active_flag,a.active_flag) = 'Y'
    and    nvl(b.default_flag,a.active_flag) = 'Y'
    and    decode(btl.ass_status_type_amend_id, NULL, '1', btl.language)
           = decode(btl.ass_status_type_amend_id, NULL, '1', userenv('LANG'))
    and    atl.language = userenv('LANG');
    --
    exception  when NO_DATA_FOUND then null;
   end;
  --
  return l_user_status;
--
end get_status;
--
--
FUNCTION get_abs_type
(p_abs_att_type_id            NUMBER) return VARCHAR2
--
AS
l_abs_name per_absence_attendance_types.name%type;
--
begin
--
  hr_utility.trace('Entered Get_Abs_Type');
  --
   begin
    hr_utility.set_location('hr_reports.get_abs_type',5);
    SELECT name
    INTO   l_abs_name
    FROM   per_abs_attendance_types_vl
    WHERE  absence_attendance_type_id = p_abs_att_type_id;
    --
    exception  when NO_DATA_FOUND then null;
   end;
  --
  return l_abs_name;
--
end get_abs_type;
--
--
PROCEDURE get_time_period
(p_time_period_id         IN NUMBER
,p_period_name           OUT NOCOPY VARCHAR2
,p_start_date            OUT NOCOPY DATE
,p_end_date              OUT NOCOPY DATE)
--
AS
--
begin
--
  hr_utility.trace('Entered Get_time_period');
  --
  hr_utility.set_location('hr_reports.get_time_period',1);
  if p_time_period_id IS NULL then
     null;
  else
   begin
    hr_utility.set_location('hr_reports.get_time_period',5);
    SELECT period_name
    ,      start_date
    ,      end_date
    INTO   p_period_name
    ,      p_start_date
    ,      p_end_date
    FROM   per_time_periods
    WHERE  time_period_id = p_time_period_id;
    --
    exception  when NO_DATA_FOUND then null;
   end;
  end if;
  --
end get_time_period;
--
--
FUNCTION get_element_name
(p_session_date DATE,
 p_element_type_id NUMBER) return VARCHAR2
--
AS
v_element_name pay_element_types_f_tl.element_name%type;
--
begin
hr_utility.trace('Entered hr_reports.get_element_name');
--
hr_utility.set_location('hr_reports.get_element_name',5);
if p_element_type_id is null then
     null;
  else
  begin
 hr_utility.set_location('hr_reports.get_element_name',10);
   select etl.element_name
   into v_element_name
   from pay_element_types_f_tl etl,
        pay_element_types_f e
   where e.element_type_id = p_element_type_id
   and p_session_date between
   e.effective_start_date and
   e.effective_end_date
   and e.element_type_id = etl.element_type_id
   and etl.LANGUAGE = userenv('LANG');
 exception
   when no_data_found then null;
 end;
 end if;
--
 hr_utility.trace('Leaving hr_reports.get_element_name');
--
 return v_element_name;
--
end get_element_name;
--
--
FUNCTION get_payroll_name
(p_session_date DATE,
 p_payroll_id   NUMBER) return VARCHAR2
--
AS
v_payroll_name  pay_payrolls_f.payroll_name%type;
--
begin
--
  hr_utility.trace('Entered hr_reports.get_payroll_name');
--
  hr_utility.set_location('hr_reports.get_payroll_name',5);
 if p_payroll_id is null then
     null;
   else
    begin
  hr_utility.set_location('hr_reports.get_payroll_name',10);
    select p.payroll_name
    into v_payroll_name
    from pay_payrolls_f p
    where payroll_id = p_payroll_id
    and p_session_date between
    p.effective_start_date and
    p.effective_end_date;
  exception
   when no_data_found then null;
  end;
  end if;
--
   hr_utility.trace('Leaving hr_reports.get_payroll_name');
--
  return v_payroll_name;
--
end get_payroll_name;
--
--
FUNCTION get_business_group
(p_business_group_id    NUMBER) return VARCHAR2
--
AS
v_business_group_name  hr_organization_units.name%type;
--
begin
--
  hr_utility.trace('Entered hr_reports.get_business_group');
--
  hr_utility.set_location('hr_reports.get_business_group',5);
  if p_business_group_id is null then
    null;
  else
    begin
      hr_utility.set_location('hr_reports.get_business_group',10);
      select org.name
      into   v_business_group_name
      from   hr_all_organization_units_tl org
    --  where  org.organization_id + 0 = p_business_group_id
    -- Changed for Performance Fix: Bug 4328224
       where  org.organization_id = p_business_group_id
        and  org.language(+) = userenv('LANG');
	-- and  org.business_group_id + 0 = org.organization_id;
    exception
      when no_data_found then null;
    end;
  end if;
--
  hr_utility.trace('Leaving hr_reports.get_business_group');
--
  return v_business_group_name;
--
end get_business_group;
--
--
function count_org_subordinates
(p_org_structure_version_id  number,
 p_parent_organization_id    number) return number
--
AS
v_subordinate_count  number;
--
begin
--
  hr_utility.trace('Entered hr_reports.count_org_subordinates');
--
  hr_utility.set_location('hr_reports.count_org_subordinates',5);
  if p_org_structure_version_id is null or
     p_parent_organization_id is null then
    null;
  else
    begin
      hr_utility.set_location('hr_reports.count_org_subordinates',10);
      select nvl(count(*),0)
      into   v_subordinate_count
      from   per_org_structure_elements ose
      connect by ose.organization_id_parent = prior ose.organization_id_child
      and    ose.org_structure_version_id  = p_org_structure_version_id
      start with ose.organization_id_parent = p_parent_organization_id
      and    ose.org_structure_version_id  = p_org_structure_version_id;
    exception
      when no_data_found then null;
    end;
  end if;
--
  hr_utility.trace('Leaving hr_reports.count_org_subordinates');
--
  return v_subordinate_count;
--
end count_org_subordinates;
--
--
function count_pos_subordinates
(p_pos_structure_version_id  number,
 p_parent_position_id        number) return number
--
AS
v_subordinate_count  number;
--
begin
--
  hr_utility.trace('Entered hr_reports.count_pos_subordinates');
--
  hr_utility.set_location('hr_reports.count_pos_subordinates',5);
  if p_pos_structure_version_id is null or
     p_parent_position_id is null then
    null;
  else
    begin
      hr_utility.set_location('hr_reports.count_pos_subordinates',10);
      select nvl(count(*),0)
      into   v_subordinate_count
      from   per_pos_structure_elements pse
      connect by pse.parent_position_id = prior pse.subordinate_position_id
      and    pse.pos_structure_version_id  = p_pos_structure_version_id
      start with pse.parent_position_id = p_parent_position_id
      and    pse.pos_structure_version_id  = p_pos_structure_version_id;
    exception
      when no_data_found then null;
    end;
  end if;
--
  hr_utility.trace('Leaving hr_reports.count_pos_subordinates');
--
  return v_subordinate_count;
--
end count_pos_subordinates;
--
--
procedure get_organization_hierarchy
(p_organization_structure_id in  number,
 p_org_structure_version_id  in  number,
 p_org_structure_name        out nocopy varchar2,
 p_org_version               out nocopy number,
 p_version_start_date        out nocopy date,
 p_version_end_date          out nocopy date)
--
AS
--
begin
--
  hr_utility.trace('Entered hr_reports.get_organization_hierarchy');
--
  hr_utility.set_location('hr_reports.get_organization_hierarchy',5);
  if p_organization_structure_id is not null then
    begin
      hr_utility.set_location('hr_reports.get_organization_hierarchy',10);
      select ost.name
      into   p_org_structure_name
      from   per_organization_structures ost
      where  ost.organization_structure_id = p_organization_structure_id;
    exception
      when no_data_found then null;
    end;
  elsif p_org_structure_version_id is not null then
    begin
      hr_utility.set_location('hr_reports.get_organization_hierarchy',15);
      select ost.name,
	     osv.version_number,
	     osv.date_from,
	     osv.date_to
      into   p_org_structure_name,
	     p_org_version,
	     p_version_start_date,
	     p_version_end_date
      from   per_organization_structures ost,
	     per_org_structure_versions osv
      where  osv.org_structure_version_id = p_org_structure_version_id
	and  ost.organization_structure_id = osv.organization_structure_id;
    exception
      when no_data_found then null;
    end;
  end if;
--
  hr_utility.trace('Leaving hr_reports.get_organization_hierarchy');
--
end get_organization_hierarchy;
--
--
procedure get_position_hierarchy
(p_position_structure_id     in  number,
 p_pos_structure_version_id  in  number,
 p_pos_structure_name        out nocopy varchar2,
 p_pos_version               out nocopy number,
 p_version_start_date        out nocopy date,
 p_version_end_date          out nocopy date)
--
AS
--
begin
--
  hr_utility.trace('Entered hr_reports.get_position_hierarchy');
--
  hr_utility.set_location('hr_reports.get_position_hierarchy',5);
  if p_position_structure_id is not null then
    begin
      hr_utility.set_location('hr_reports.get_position_hierarchy',10);
      select pst.name
      into   p_pos_structure_name
      from   per_position_structures pst
      where  pst.position_structure_id = p_position_structure_id;
    exception
      when no_data_found then null;
    end;
  elsif p_pos_structure_version_id is not null then
    begin
      hr_utility.set_location('hr_reports.get_position_hierarchy',15);
      select pst.name,
	     psv.version_number,
	     psv.date_from,
	     psv.date_to
      into   p_pos_structure_name,
	     p_pos_version,
	     p_version_start_date,
	     p_version_end_date
      from   per_position_structures pst,
	     per_pos_structure_versions psv
      where  psv.pos_structure_version_id = p_pos_structure_version_id
	and  pst.position_structure_id = psv.position_structure_id;
    exception
      when no_data_found then null;
    end;
  end if;
--
  hr_utility.trace('Leaving hr_reports.get_position_hierarchy');
--
end get_position_hierarchy;
--
--
function get_lookup_meaning
(p_lookup_type  varchar2,
 p_lookup_code  varchar2) return varchar2
--
AS
v_meaning  hr_lookups.meaning%type;
--
begin
--
  hr_utility.trace('Entered hr_reports.get_lookup_meaning');
--
  begin
    hr_utility.set_location('hr_reports.get_lookup_meaning',5);
    select hrl.meaning
    into   v_meaning
    from   hr_lookups hrl
    where  hrl.lookup_type = p_lookup_type
      and  hrl.lookup_code = p_lookup_code;
  exception
    when no_data_found then null;
  end;
--
  hr_utility.trace('Leaving hr_reports.get_lookup_meaning');
--
  return v_meaning;
--
end get_lookup_meaning;
--
--
FUNCTION person_matching_skills
(p_person_id         IN NUMBER
,p_job_position_id   IN NUMBER
,p_job_position_type IN VARCHAR2
,p_matching_level    IN VARCHAR2
,p_no_of_essential   IN NUMBER
,p_no_of_desirable   IN NUMBER)  RETURN BOOLEAN AS
--
-- Local Variables
--
l_person_matches BOOLEAN := TRUE;
--
FUNCTION count_skills (p_person_id         IN NUMBER
		      ,p_job_position_id   IN NUMBER
		      ,p_job_position_type IN VARCHAR2
		      ,p_essential_flag    IN VARCHAR2
		      ,p_number_required   IN NUMBER)
--
		      RETURN BOOLEAN IS
--
l_number_matching NUMBER(10) := 0;
--
BEGIN
--
     BEGIN
     hr_utility.set_location('hr_reports.person_matching_skills',5);
     select sign(count(*))
     into   l_number_matching
     from   per_person_analyses p
     where  p.person_id = P_PERSON_ID
     and exists
	(select null
	 from   per_job_requirements j
	 ,      per_analysis_criteria ja
	 ,      per_analysis_criteria pa
	 where  ((P_JOB_POSITION_TYPE = 'J' and
		 j.job_id = P_JOB_POSITION_ID)
	     or (P_JOB_POSITION_TYPE = 'P' and
		 j.position_id = P_JOB_POSITION_ID))
	 and    j.essential = P_ESSENTIAL_FLAG
	 and    j.analysis_criteria_id = ja.analysis_criteria_id
	 and    p.analysis_criteria_id = pa.analysis_criteria_id
	 and    p.analysis_criteria_id = ja.analysis_criteria_id
	 and    ja.id_flex_num = pa.id_flex_num
	 and  ((ja.segment1 is null or
	       (ja.segment1 is not null and
		ja.segment1 = pa.segment1))
	 or    (ja.segment2 is null or
	       (ja.segment2 is not null and
		ja.segment2 = pa.segment2))
	 or    (ja.segment3 is null or
	       (ja.segment3 is not null and
		ja.segment3 = pa.segment3))
	 or    (ja.segment4 is null or
	       (ja.segment4 is not null and
		ja.segment4 = pa.segment4))
	 or    (ja.segment5 is null or
	       (ja.segment5 is not null and
		ja.segment5 = pa.segment5))
	 or    (ja.segment6 is null or
	       (ja.segment6 is not null and
		ja.segment6 = pa.segment6))
	 or    (ja.segment7 is null or
	       (ja.segment7 is not null and
		ja.segment7 = pa.segment7))
	 or    (ja.segment8 is null or
	       (ja.segment8 is not null and
		ja.segment8 = pa.segment8))
	 or    (ja.segment9 is null or
	       (ja.segment9 is not null and
		ja.segment9 = pa.segment9))
	 or    (ja.segment10 is null or
	       (ja.segment10 is not null and
		ja.segment10 = pa.segment10))
	 or    (ja.segment11 is null or
	       (ja.segment11 is not null and
		ja.segment11 = pa.segment11))
	 or    (ja.segment12 is null or
	       (ja.segment12 is not null and
		ja.segment12 = pa.segment12))
	 or    (ja.segment13 is null or
	       (ja.segment13 is not null and
		ja.segment13 = pa.segment13))
	 or    (ja.segment14 is null or
	       (ja.segment14 is not null and
		ja.segment14 = pa.segment14))
	 or    (ja.segment15 is null or
	       (ja.segment15 is not null and
		ja.segment15 = pa.segment15))
	 or    (ja.segment16 is null or
	       (ja.segment16 is not null and
		ja.segment16 = pa.segment16))
	 or    (ja.segment17 is null or
	       (ja.segment17 is not null and
		ja.segment17 = pa.segment17))
	 or    (ja.segment18 is null or
	       (ja.segment18 is not null and
		ja.segment18 = pa.segment18))
	 or    (ja.segment19 is null or
	       (ja.segment19 is not null and
		ja.segment19 = pa.segment19))
	 or    (ja.segment20 is null or
	       (ja.segment20 is not null and
		ja.segment20 = pa.segment20))
	 or    (ja.segment21 is null or
	       (ja.segment21 is not null and
		ja.segment21 = pa.segment21))
	 or    (ja.segment22 is null or
	       (ja.segment22 is not null and
		ja.segment22 = pa.segment22))
	 or    (ja.segment23 is null or
	       (ja.segment23 is not null and
		ja.segment23 = pa.segment23))
	 or    (ja.segment24 is null or
	       (ja.segment24 is not null and
		ja.segment24 = pa.segment24))
	 or    (ja.segment25 is null or
	       (ja.segment25 is not null and
		ja.segment25 = pa.segment25))
	 or    (ja.segment26 is null or
	       (ja.segment26 is not null and
		ja.segment26 = pa.segment26))
	 or    (ja.segment27 is null or
	       (ja.segment27 is not null and
		ja.segment27 = pa.segment27))
	 or    (ja.segment28 is null or
	       (ja.segment28 is not null and
		ja.segment28 = pa.segment28))
	 or    (ja.segment29 is null or
	       (ja.segment29 is not null and
		ja.segment29 = pa.segment29))
	 or    (ja.segment30 is null or
	       (ja.segment30 is not null and
		ja.segment30 = pa.segment30)))
	 )
     having count(*) >= P_NUMBER_REQUIRED;
--
     EXCEPTION
     when no_data_found then null;
     END;
     --
      RETURN(l_number_matching > 0);
--
END;
--
--
BEGIN
--
  hr_utility.trace('Entered hr_reports.person_matching_skills');
  --
   if p_matching_level = 'A' then
      if p_no_of_essential > 0 then
    hr_utility.set_location('hr_reports.person_matching_skills',10);
	 l_person_matches := count_skills(p_person_id
					 ,p_job_position_id
					 ,p_job_position_type
					 ,'Y'
					 ,p_no_of_essential);
      end if;
   elsif p_matching_level = 'D' then
      if p_no_of_essential > 0 then
    hr_utility.set_location('hr_reports.person_matching_skills',10);
	 l_person_matches := count_skills(p_person_id
					 ,p_job_position_id
					 ,p_job_position_type
					 ,'Y'
					 ,p_no_of_essential);
      end if;
      if p_no_of_desirable > 0
	 and l_person_matches = TRUE then
    hr_utility.set_location('hr_reports.person_matching_skills',10);
	 l_person_matches := count_skills(p_person_id
					 ,p_job_position_id
					 ,p_job_position_type
					 ,'N'
					 ,1);
      end if;
   else            -- matching_level = 'S'
      if p_no_of_essential > 0 then
    hr_utility.set_location('hr_reports.person_matching_skills',10);
	 l_person_matches := count_skills(p_person_id
					 ,p_job_position_id
					 ,p_job_position_type
					 ,'Y'
					 ,1);
      end if;
   end if;
--
   return(l_person_matches);
--
END;
--

PROCEDURE split_segments
(p_concatenated_segments VARCHAR2
,p_id_flex_num NUMBER
,p_segtab OUT NOCOPY SegmentTabType
,p_segments_used OUT NOCOPY NUMBER) IS
 begin
 hr_reports.split_segments(p_concatenated_segments,
                           p_id_flex_num,
                           p_segtab,
                           p_segments_used,
                           NULL);
 end;

PROCEDURE split_segments
(p_concatenated_segments VARCHAR2
,p_id_flex_num NUMBER
,p_segtab OUT NOCOPY SegmentTabType
,p_segments_used OUT NOCOPY NUMBER
,p_id_flex_code VARCHAR2) IS
 begin
 hr_reports.split_segments(p_concatenated_segments,
                           p_id_flex_num,
                           p_segtab,
                           p_segments_used,
                           p_id_flex_code,
                           NULL);
 end;

--
PROCEDURE split_segments
(p_concatenated_segments VARCHAR2
,p_id_flex_num NUMBER
,p_segtab OUT NOCOPY SegmentTabType
,p_segments_used OUT NOCOPY NUMBER
,p_id_flex_code VARCHAR2
,p_application_id NUMBER) IS
--
l_no_of_segs NUMBER;
l_concat_segs VARCHAR2(2000);
l_seg_len NUMBER;
l_start_pos NUMBER;
l_count NUMBER := 1;
l_seg_sep VARCHAR2(1) := '.';
--
begin
hr_utility.trace('Entered hr_reports.split_segments');
--
hr_utility.set_location('hr_reports.split_segments',10);
--
begin
  select DISTINCT CONCATENATED_SEGMENT_DELIMITER
  into   l_seg_sep
  from   fnd_id_flex_structures_vl
  where  ID_FLEX_NUM = P_ID_FLEX_NUM
  and    ID_FLEX_CODE=NVL(p_id_flex_code,ID_FLEX_CODE)
  and    APPLICATION_ID = nvl(p_application_id,APPLICATION_ID);
exception
  when NO_DATA_FOUND then null;
end;
--
hr_utility.set_location('hr_reports.split_segments',10);
--
l_concat_segs := l_seg_sep || p_concatenated_segments || l_seg_sep;
l_no_of_segs := length(l_concat_segs)
		  - length(replace(l_concat_segs,l_seg_sep));
--
while l_count < l_no_of_segs loop
  l_seg_len := instr(l_concat_segs, l_seg_sep,1 , l_count+1)
		     - instr(l_concat_segs, l_seg_sep,1, l_count) - 1;
  l_start_pos := instr(l_concat_segs, l_seg_sep,1, l_count) + 1;
  p_segtab(l_count) := substr(l_concat_segs,l_start_pos,l_seg_len);
  p_segments_used := l_count;
  l_count := l_count + 1;
end loop;
--
end;
--
--


procedure gen_partial_matching_lexical
(p_concatenated_segments IN VARCHAR2
,p_id_flex_num    IN NUMBER
,p_matching_lexical IN OUT NOCOPY VARCHAR2) IS
 begin
 hr_reports.gen_partial_matching_lexical(p_concatenated_segments,
                                         p_id_flex_num,
                                         p_matching_lexical,
                                         NULL);
 end;

procedure gen_partial_matching_lexical
(p_concatenated_segments IN VARCHAR2
,p_id_flex_num    IN NUMBER
,p_matching_lexical IN OUT NOCOPY VARCHAR2
,p_id_flex_code IN VARCHAR2) IS
 begin
 hr_reports.gen_partial_matching_lexical(p_concatenated_segments,
                                         p_id_flex_num,
                                         p_matching_lexical,
                                         p_id_flex_code,
                                         NULL);
 end;


procedure gen_partial_matching_lexical
(p_concatenated_segments IN VARCHAR2
,p_id_flex_num    IN NUMBER
,p_matching_lexical IN OUT NOCOPY VARCHAR2
,p_id_flex_code VARCHAR2
,p_application_id IN NUMBER) IS
--
l_count NUMBER(10) := 0;
l_segtab hr_reports.SegmentTabType;
l_segments_used NUMBER(10);
--
-- this cursor is used to get the order of the segments from the foundation
-- table
--
cursor c1 is
select application_column_name
from   fnd_id_flex_segments_vl
where  id_flex_num = p_id_flex_num
and    id_flex_code = nvl(p_id_flex_code,id_flex_code)
and    enabled_flag = 'Y'
order by segment_num;
--
begin
--
hr_utility.trace('Entered hr_reports.gen_partial_matching_lexical');
--
  hr_utility.set_location ('hr_reports.gen_partial_matching_lexical', 5);
--
  hr_reports.split_segments(p_concatenated_segments
			   ,p_id_flex_num
			   ,l_segtab
			   ,l_segments_used
                           ,p_id_flex_code);
--
  hr_utility.set_location ('hr_reports.gen_partial_matching_lexical', 10);
  for c1rec in c1 loop
  l_count := l_count + 1;
  --
  if l_segtab(l_count) is null then null;
  else
     p_matching_lexical := p_matching_lexical || ' AND ' ||
		       c1rec.application_column_name || '=''' ||
		       l_segtab(l_count) || '''';
  end if;
  end loop;
--
end gen_partial_matching_lexical;
--
-- Added for bug fix 622283, version 110.6
--
procedure get_attributes
(p_concatenated_segments 	IN VARCHAR2
,p_name  			IN VARCHAR2
,p_segments_used 	 OUT NOCOPY NUMBER
,p_value1 OUT NOCOPY VARCHAR2
,p_value2 OUT NOCOPY VARCHAR2
,p_value3 OUT NOCOPY VARCHAR2
,p_value4 OUT NOCOPY VARCHAR2
,p_value5 OUT NOCOPY VARCHAR2
,p_value6 OUT NOCOPY VARCHAR2
,p_value7 OUT NOCOPY VARCHAR2
,p_value8 OUT NOCOPY VARCHAR2
,p_value9 OUT NOCOPY VARCHAR2
,p_value10 OUT NOCOPY VARCHAR2
,p_value11 OUT NOCOPY VARCHAR2
,p_value12 OUT NOCOPY VARCHAR2
,p_value13 OUT NOCOPY VARCHAR2
,p_value14 OUT NOCOPY VARCHAR2
,p_value15 OUT NOCOPY VARCHAR2
,p_value16 OUT NOCOPY VARCHAR2
,p_value17 OUT NOCOPY VARCHAR2
,p_value18 OUT NOCOPY VARCHAR2
,p_value19 OUT NOCOPY VARCHAR2
,p_value20 OUT NOCOPY VARCHAR2
,p_value21 OUT NOCOPY VARCHAR2
,p_value22 OUT NOCOPY VARCHAR2
,p_value23 OUT NOCOPY VARCHAR2
,p_value24 OUT NOCOPY VARCHAR2
,p_value25 OUT NOCOPY VARCHAR2
,p_value26 OUT NOCOPY VARCHAR2
,p_value27 OUT NOCOPY VARCHAR2
,p_value28 OUT NOCOPY VARCHAR2
,p_value29 OUT NOCOPY VARCHAR2
,p_value30 OUT NOCOPY VARCHAR2 ) IS
--
l_aol_seperator_flag		boolean := true;
--
begin
--
  hr_reports.get_attributes(	 p_concatenated_segments
				,p_name
				,l_aol_seperator_flag
				,p_segments_used
				,p_value1
				,p_value2
				,p_value3
				,p_value4
				,p_value5
				,p_value6
				,p_value7
				,p_value8
				,p_value9
				,p_value10
				,p_value11
				,p_value12
				,p_value13
				,p_value14
				,p_value15
				,p_value16
				,p_value17
				,p_value18
				,p_value19
				,p_value20
				,p_value21
				,p_value22
				,p_value23
				,p_value24
				,p_value25
				,p_value26
				,p_value27
				,p_value28
				,p_value29
				,p_value30
			);
--
end get_attributes;
--
-- Added for bug fix 622283, version 110.6
--
procedure get_attributes
(p_concatenated_segments 	IN  VARCHAR2
,p_name  			IN  VARCHAR2
,p_aol_seperator_flag		IN  BOOLEAN
,p_segments_used 	 OUT NOCOPY NUMBER
,p_value1 OUT NOCOPY VARCHAR2
,p_value2 OUT NOCOPY VARCHAR2
,p_value3 OUT NOCOPY VARCHAR2
,p_value4 OUT NOCOPY VARCHAR2
,p_value5 OUT NOCOPY VARCHAR2
,p_value6 OUT NOCOPY VARCHAR2
,p_value7 OUT NOCOPY VARCHAR2
,p_value8 OUT NOCOPY VARCHAR2
,p_value9 OUT NOCOPY VARCHAR2
,p_value10 OUT NOCOPY VARCHAR2
,p_value11 OUT NOCOPY VARCHAR2
,p_value12 OUT NOCOPY VARCHAR2
,p_value13 OUT NOCOPY VARCHAR2
,p_value14 OUT NOCOPY VARCHAR2
,p_value15 OUT NOCOPY VARCHAR2
,p_value16 OUT NOCOPY VARCHAR2
,p_value17 OUT NOCOPY VARCHAR2
,p_value18 OUT NOCOPY VARCHAR2
,p_value19 OUT NOCOPY VARCHAR2
,p_value20 OUT NOCOPY VARCHAR2
,p_value21 OUT NOCOPY VARCHAR2
,p_value22 OUT NOCOPY VARCHAR2
,p_value23 OUT NOCOPY VARCHAR2
,p_value24 OUT NOCOPY VARCHAR2
,p_value25 OUT NOCOPY VARCHAR2
,p_value26 OUT NOCOPY VARCHAR2
,p_value27 OUT NOCOPY VARCHAR2
,p_value28 OUT NOCOPY VARCHAR2
,p_value29 OUT NOCOPY VARCHAR2
,p_value30 OUT NOCOPY VARCHAR2 ) IS
--
l_segtab hr_reports.SegmentTabType;
l_segments_used NUMBER(10);
--
begin
--
hr_utility.trace('Entered hr_reports.get_attributes');
--
  hr_utility.set_location ('hr_reports.get_attributes', 5);
--
  hr_reports.split_attributes(	 p_concatenated_segments
			   	,p_name
				,p_aol_seperator_flag
			   	,l_segtab
			   	,l_segments_used);
--
  for i in nvl(l_segments_used, 0) + 1..30 loop
      l_segtab(i) := null;
  end loop;
  --
  hr_utility.set_location ('hr_reports.get_attributes', 10);
  --
  p_segments_used := l_segments_used;
  p_value1 := l_segtab(1);
  p_value2 := l_segtab(2);
  p_value3 := l_segtab(3);
  p_value4 := l_segtab(4);
  p_value5 := l_segtab(5);
  p_value6 := l_segtab(6);
  p_value7 := l_segtab(7);
  p_value8 := l_segtab(8);
  p_value9 := l_segtab(9);
  p_value10 := l_segtab(10);
  p_value11 := l_segtab(11);
  p_value12 := l_segtab(12);
  p_value13 := l_segtab(13);
  p_value14 := l_segtab(14);
  p_value15 := l_segtab(15);
  p_value16 := l_segtab(16);
  p_value17 := l_segtab(17);
  p_value18 := l_segtab(18);
  p_value19 := l_segtab(19);
  p_value20 := l_segtab(20);
  p_value21 := l_segtab(21);
  p_value22 := l_segtab(22);
  p_value23 := l_segtab(23);
  p_value24 := l_segtab(24);
  p_value25 := l_segtab(25);
  p_value26 := l_segtab(26);
  p_value27 := l_segtab(27);
  p_value28 := l_segtab(28);
  p_value29 := l_segtab(29);
  p_value30 := l_segtab(30);
--
  SegmentValue1 := l_segtab(1);
end get_attributes;
--
-- Added for bug fix 622283, version 110.6
--
PROCEDURE split_attributes
(p_concatenated_segments 	IN  VARCHAR2
,p_title       			IN  VARCHAR2
,p_segtab 		 OUT NOCOPY SegmentTabType
,p_segments_used 	 OUT NOCOPY NUMBER
) IS
--
l_aol_seperator_flag		boolean := true;
--
begin
--
  hr_reports.split_attributes(	 p_concatenated_segments
				,p_title
				,l_aol_seperator_flag
				,p_segtab
				,p_segments_used
			);
--
end split_attributes;
--
-- Added for bug fix 622283, version 110.6
--
PROCEDURE split_attributes
(p_concatenated_segments 	IN  VARCHAR2
,p_title       			IN  VARCHAR2
,p_aol_seperator_flag		IN  BOOLEAN
,p_segtab 		 OUT NOCOPY SegmentTabType
,p_segments_used 	 OUT NOCOPY NUMBER
) IS
--
l_no_of_segs NUMBER;
l_concat_segs VARCHAR2(2000);
l_seg_len NUMBER;
l_start_pos NUMBER;
l_count NUMBER := 1;
l_seg_sep VARCHAR2(1) := '.';
--
begin
hr_utility.trace('Entered hr_reports.split_attributes');
--
hr_utility.set_location('hr_reports.split_attributes',10);
--
if (p_aol_seperator_flag = true) then
--
begin
  select CONCATENATED_SEGMENT_DELIMITER
  into   l_seg_sep
  from   FND_DESCRIPTIVE_FLEXS_VL
  where  DESCRIPTIVE_FLEXFIELD_NAME = P_TITLE;
exception
  when NO_DATA_FOUND then null;
end;
--
else
  l_seg_sep := fnd_global.local_chr(127);
end if;
--
hr_utility.set_location('hr_reports.split_attributes',10);
--
l_concat_segs := l_seg_sep || p_concatenated_segments || l_seg_sep;
l_no_of_segs := length(l_concat_segs)
		  - length(replace(l_concat_segs,l_seg_sep));
--
while l_count < l_no_of_segs loop
  l_seg_len := instr(l_concat_segs, l_seg_sep,1 , l_count+1)
		     - instr(l_concat_segs, l_seg_sep,1, l_count) - 1;
  l_start_pos := instr(l_concat_segs, l_seg_sep,1, l_count) + 1;
  p_segtab(l_count) := substr(l_concat_segs,l_start_pos,l_seg_len);
  p_segments_used := l_count;
  l_count := l_count + 1;
end loop;
--
end split_attributes;
--
--
procedure get_segments
(p_concatenated_segments IN VARCHAR2
,p_id_flex_num   IN NUMBER
,p_segments_used OUT NOCOPY NUMBER
,p_value1 OUT NOCOPY VARCHAR2
,p_value2 OUT NOCOPY VARCHAR2
,p_value3 OUT NOCOPY VARCHAR2
,p_value4 OUT NOCOPY VARCHAR2
,p_value5 OUT NOCOPY VARCHAR2
,p_value6 OUT NOCOPY VARCHAR2
,p_value7 OUT NOCOPY VARCHAR2
,p_value8 OUT NOCOPY VARCHAR2
,p_value9 OUT NOCOPY VARCHAR2
,p_value10 OUT NOCOPY VARCHAR2
,p_value11 OUT NOCOPY VARCHAR2
,p_value12 OUT NOCOPY VARCHAR2
,p_value13 OUT NOCOPY VARCHAR2
,p_value14 OUT NOCOPY VARCHAR2
,p_value15 OUT NOCOPY VARCHAR2
,p_value16 OUT NOCOPY VARCHAR2
,p_value17 OUT NOCOPY VARCHAR2
,p_value18 OUT NOCOPY VARCHAR2
,p_value19 OUT NOCOPY VARCHAR2
,p_value20 OUT NOCOPY VARCHAR2
,p_value21 OUT NOCOPY VARCHAR2
,p_value22 OUT NOCOPY VARCHAR2
,p_value23 OUT NOCOPY VARCHAR2
,p_value24 OUT NOCOPY VARCHAR2
,p_value25 OUT NOCOPY VARCHAR2
,p_value26 OUT NOCOPY VARCHAR2
,p_value27 OUT NOCOPY VARCHAR2
,p_value28 OUT NOCOPY VARCHAR2
,p_value29 OUT NOCOPY VARCHAR2
,p_value30 OUT NOCOPY VARCHAR2 ) IS
--
l_segtab hr_reports.SegmentTabType;
l_segments_used NUMBER(10);
--
begin
--
hr_utility.trace('Entered hr_reports.get_segments');
--
  hr_utility.set_location ('hr_reports.get_segments', 5);
  hr_reports.split_segments(p_concatenated_segments
			   ,p_id_flex_num
			   ,l_segtab
			   ,l_segments_used);
--
  for i in l_segments_used + 1..30 loop
      l_segtab(i) := null;
  end loop;
  --
  hr_utility.set_location ('hr_reports.get_segments', 10);
  --
  p_segments_used := l_segments_used;
  p_value1 := l_segtab(1);
  p_value2 := l_segtab(2);
  p_value3 := l_segtab(3);
  p_value4 := l_segtab(4);
  p_value5 := l_segtab(5);
  p_value6 := l_segtab(6);
  p_value7 := l_segtab(7);
  p_value8 := l_segtab(8);
  p_value9 := l_segtab(9);
  p_value10 := l_segtab(10);
  p_value11 := l_segtab(11);
  p_value12 := l_segtab(12);
  p_value13 := l_segtab(13);
  p_value14 := l_segtab(14);
  p_value15 := l_segtab(15);
  p_value16 := l_segtab(16);
  p_value17 := l_segtab(17);
  p_value18 := l_segtab(18);
  p_value19 := l_segtab(19);
  p_value20 := l_segtab(20);
  p_value21 := l_segtab(21);
  p_value22 := l_segtab(22);
  p_value23 := l_segtab(23);
  p_value24 := l_segtab(24);
  p_value25 := l_segtab(25);
  p_value26 := l_segtab(26);
  p_value27 := l_segtab(27);
  p_value28 := l_segtab(28);
  p_value29 := l_segtab(29);
  p_value30 := l_segtab(30);
--
  SegmentValue1 := l_segtab(1);
end get_segments;
--
--
procedure get_desc_flex
(
 p_appl_short_name    in  varchar2,
 p_desc_flex_name     in  varchar2,
 p_table_alias        in  varchar2,
 p_title              out nocopy varchar2,
 p_label_expr         out nocopy varchar2,
 p_column_expr        out nocopy varchar2
) is
--
 cursor csr_flex_columns(p_application_id  number,
			 p_desc_flex_name  varchar2) is
  select 1 order_col,
	 dfcu.column_seq_num order_col2,
	 dfcu.application_column_name column_name,
	 replace(dfcu.form_left_prompt,'''','''''') label
  from   fnd_descr_flex_contexts dfc,
	 fnd_descr_flex_col_usage_vl dfcu
  where  dfc.descriptive_flexfield_name = p_desc_flex_name
    and  dfc.application_id = p_application_id
    and  dfc.global_flag  = 'Y'
    and  dfc.enabled_flag = 'Y'
    and  dfcu.descriptive_flex_context_code = dfc.descriptive_flex_context_code
    and  dfcu.descriptive_flexfield_name = p_desc_flex_name
    and  dfcu.application_id = p_application_id
    and  dfcu.enabled_flag = 'Y'
  UNION
  select distinct
	 2 order_col,
	 1 order_col2,
	 dfcu.application_column_name column_name,
	 replace(dfcu.form_left_prompt,'''','''''') label
  from   fnd_descr_flex_contexts dfc,
	 fnd_descr_flex_col_usage_vl dfcu
  where  dfc.descriptive_flexfield_name = p_desc_flex_name
    and  dfc.application_id = p_application_id
    and  dfc.global_flag  = 'N'
    and  dfc.enabled_flag = 'Y'
    and  dfcu.descriptive_flex_context_code = dfc.descriptive_flex_context_code
    and  dfcu.descriptive_flexfield_name = p_desc_flex_name
    and  dfcu.application_id = p_application_id
    and  dfcu.enabled_flag = 'Y'
  order by 1,2,3;
--
 v_title           varchar2(400);
 v_column_expr     varchar2(32000);
 v_label_expr      varchar2(32000);
 v_delimiter       varchar2(1);
 v_application_id  number;
--
begin
--
  select app.application_id
  into   v_application_id
  from   fnd_application app
  where  upper(app.application_short_name) = upper(p_appl_short_name);
--
  select df.concatenated_segment_delimiter,
	 df.title
  into   v_delimiter,
	 v_title
  from   fnd_descriptive_flexs_vl df
  where  df.descriptive_flexfield_name = p_desc_flex_name
    and  df.application_id = v_application_id;
--
  for flex_col in csr_flex_columns(v_application_id,
				   p_desc_flex_name) loop
--
    if v_column_expr is null then
--
      v_column_expr := p_table_alias || '.' || flex_col.column_name;
      v_label_expr  := flex_col.label;
--
    else
--
      v_column_expr := v_column_expr || '||''' || v_delimiter || '''||' ||
		       p_table_alias || '.' || flex_col.column_name;
      v_label_expr  := v_label_expr  || '.' || flex_col.label;
--
    end if;
--
  end loop;
--
--
--
--
--





  p_title := v_title;
  p_label_expr  := v_label_expr;
  p_column_expr := v_column_expr;
--
--
end get_desc_flex;
--
procedure get_desc_flex_context
(
 p_appl_short_name    in  varchar2,
 p_desc_flex_name     in  varchar2,
 p_table_alias        in  varchar2,
 p_title              out nocopy varchar2,
 p_label_expr         out nocopy varchar2,
 p_column_expr        out nocopy varchar2
) is
begin
hr_reports.get_desc_flex_context
(p_appl_short_name,
 p_desc_flex_name,
 p_table_alias,
 'Y',
 p_title,
 p_label_expr,
 p_column_expr);
end;
--
procedure get_desc_flex_context
(
 p_appl_short_name    in  varchar2,
 p_desc_flex_name     in  varchar2,
 p_table_alias        in  varchar2,
 p_display            in  varchar2,
 p_title              out nocopy varchar2,
 p_label_expr         out nocopy varchar2,
 p_column_expr        out nocopy varchar2
) is
 cursor csr_flex_columns(p_application_id  number,
			 p_desc_flex_name  varchar2) is
  select 1 order_col,
	 dfcu.column_seq_num order_col2,
	 dfcu.application_column_name column_name,
	 replace(dfcu.form_left_prompt,'''','''''') label,
         'Y' global_flag,
         dfc.descriptive_flex_context_code context
  from   fnd_descr_flex_contexts dfc,
	 fnd_descr_flex_col_usage_vl dfcu
  where  dfc.descriptive_flexfield_name = p_desc_flex_name
    and  dfc.application_id = p_application_id
    and  dfc.global_flag  = 'Y'
    and  dfc.enabled_flag = 'Y'
    and  dfcu.descriptive_flex_context_code = dfc.descriptive_flex_context_code
    and  dfcu.descriptive_flexfield_name = p_desc_flex_name
    and  dfcu.application_id = p_application_id
    and  dfcu.enabled_flag = 'Y'
    and  dfcu.display_flag = NVL(p_display,dfcu.display_flag)
  UNION
  select distinct
	 2 order_col,
	 1 order_col2,
	 dfcu.application_column_name column_name,
	 replace(dfcu.form_left_prompt,'''','''''') label,
         'N' global_flag,
         dfc.descriptive_flex_context_code context
  from   fnd_descr_flex_contexts dfc,
	 fnd_descr_flex_col_usage_vl dfcu
  where  dfc.descriptive_flexfield_name = p_desc_flex_name
    and  dfc.application_id = p_application_id
    and  dfc.global_flag  = 'N'
    and  dfc.enabled_flag = 'Y'
    and  dfcu.descriptive_flex_context_code = dfc.descriptive_flex_context_code
    and  dfcu.descriptive_flexfield_name = p_desc_flex_name
    and  dfcu.application_id = p_application_id
    and  dfcu.enabled_flag = 'Y'
    and  dfcu.display_flag = NVL(p_display,dfcu.display_flag)
  order by 1,6,2;
--
 v_title           varchar2(60);
 v_column_expr     varchar2(32000);
 v_label_expr      varchar2(32000);
 v_delimiter       varchar2(1);
 v_application_id  number;
 v_column          varchar2(250);
 v_column_name     varchar2(200);
 v_attribute_category varchar2(100);
 v_label_name      varchar2(200);
 v_label           varchar2(250);
--
--
begin
--
  select app.application_id
  into   v_application_id
  from   fnd_application app
  where  upper(app.application_short_name) = upper(p_appl_short_name);
--
  select df.concatenated_segment_delimiter,
	 df.title
  into   v_delimiter,
	 v_title
  from   fnd_descriptive_flexs_vl df
  where  df.descriptive_flexfield_name = p_desc_flex_name
    and  df.application_id = v_application_id;
--
  for flex_col in csr_flex_columns(v_application_id,
				   p_desc_flex_name) loop
--
    if flex_col.global_flag = 'Y' then
         if v_column_expr is null then
         v_column := p_table_alias || '.' || flex_col.column_name
                       || '||'''||v_delimiter||'''';
         v_label  :=''''|| flex_col.label||'''' || '||'''||v_delimiter
	         || '''';

         else
         v_column :='||'|| p_table_alias ||'.'|| flex_col.column_name
                        || '||''' ||v_delimiter|| '''';
         v_label := '||'|| ''''||flex_col.label||'''' || '||''' || v_delimiter
                  || '''' ;
         end if;
--
--
    else
--
        if p_table_alias = 'asg' then
           v_attribute_category := p_table_alias || '.' || 'ass_attribute_category';
           elsif p_table_alias = 'addr' then
           v_attribute_category := p_table_alias || '.' || 'addr_attribute_category';
           elsif p_table_alias = 'app' then
           v_attribute_category := p_table_alias || '.' || 'appl_attribute_category';
	   elsif p_table_alias = 'con' then
           v_attribute_category := p_table_alias || '.' || 'cont_attribute_category';
	   elsif p_table_alias = 'paei' then
           v_attribute_category := p_table_alias || '.' || 'aei_information_category';
           elsif p_table_alias = 'f' then
           v_attribute_category := p_table_alias || '.' || 'aei_information_category';
        else
           v_attribute_category := p_table_alias || '.' || 'attribute_category';
        end if;
      v_label_name := flex_col.label;
      v_column_name := p_table_alias ||'.'||flex_col.column_name;
--
        if v_column_expr is null then
         v_label :=substrb(
         'decode('||v_attribute_category||','''||flex_col.context||''','||
         '''' ||v_label_name||''''|| '||''' ||v_delimiter || '''' ||',null)',32000);
--
         v_column :=substrb(
         'decode('||v_attribute_category||','''||flex_col.context||''','||
         v_column_name|| '||''' ||v_delimiter||''''||',null)',32000);
--
         else
--
         v_label := substrb(
         '||decode('||v_attribute_category||','''||flex_col.context||''','||
           ''''||v_label_name||''''|| '||''' || v_delimiter ||
           '''' ||',null)',32000);
--
         v_column := substrb(
         '||decode('||v_attribute_category||','''||flex_col.context||''','||
            v_column_name|| '||''' || v_delimiter || ''''
                        ||',null)',32000);
--
         end if;
    end if;
--
    if v_column_expr is null then
--
       v_column_expr := v_column;
       v_label_expr  := v_label;
--
    else
--
      v_column_expr := v_column_expr || v_column;
      v_label_expr  := v_label_expr  || v_label;
--
    end if;
--
  end loop;
--
  p_title       := v_title;
  p_label_expr  := v_label_expr;
  p_column_expr := v_column_expr;
--
end get_desc_flex_context;
--
-- Added for bug fix 622283, version 110.6
--
procedure get_dvlpr_desc_flex
(
 p_appl_short_name    in  varchar2,
 p_desc_flex_name     in  varchar2,
 p_desc_flex_context  in  varchar2,
 p_table_alias        in  varchar2,
 p_title              out nocopy varchar2,
 p_label_expr         out nocopy varchar2,
 p_column_expr        out nocopy varchar2
) is
--
l_aol_seperator_flag		boolean := true;
--
begin
--
  hr_reports.get_dvlpr_desc_flex(	 p_appl_short_name
					,p_desc_flex_name
					,p_desc_flex_context
					,p_table_alias
					,l_aol_seperator_flag
					,p_title
					,p_label_expr
					,p_column_expr
				);
--
end get_dvlpr_desc_flex;
--
--
-- Added for bug fix 622283, version 110.6
--
procedure get_dvlpr_desc_flex
(
 p_appl_short_name    in  varchar2,
 p_desc_flex_name     in  varchar2,
 p_desc_flex_context  in  varchar2,
 p_table_alias        in  varchar2,
 p_aol_seperator_flag in  boolean,
 p_title              out nocopy varchar2,
 p_label_expr         out nocopy varchar2,
 p_column_expr        out nocopy varchar2
) is
--
 cursor csr_flex_columns(p_application_id     number,
			 p_desc_flex_name     varchar2,
			 p_desc_flex_context  varchar2) is
  select 1 order_col,
	 dfcu.column_seq_num order_col2,
	 dfcu.application_column_name column_name,
	 replace(dfcu.form_left_prompt,'''','''''') label
  from   fnd_descr_flex_contexts dfc,
	 fnd_descr_flex_col_usage_vl dfcu
  where  dfc.descriptive_flexfield_name = p_desc_flex_name
    and  dfc.application_id = p_application_id
    and  dfc.global_flag  = 'Y'
    and  dfc.enabled_flag = 'Y'
    and  dfcu.descriptive_flex_context_code = dfc.descriptive_flex_context_code
    and  dfcu.descriptive_flexfield_name = p_desc_flex_name
    and  dfcu.application_id = p_application_id
    and  dfcu.enabled_flag = 'Y'
  UNION
  select distinct
	 2 order_col,
	 dfcu.column_seq_num order_col2,
	 dfcu.application_column_name column_name,
	 replace(dfcu.form_left_prompt,'''','''''') label
  from   fnd_descr_flex_contexts dfc,
	 fnd_descr_flex_col_usage_vl dfcu
  where  dfc.descriptive_flexfield_name = p_desc_flex_name
    and  dfc.application_id = p_application_id
    and  dfc.descriptive_flex_context_code = p_desc_flex_context
    and  dfc.global_flag  = 'N'
    and  dfc.enabled_flag = 'Y'
    and  dfcu.descriptive_flex_context_code = dfc.descriptive_flex_context_code

    and  dfcu.descriptive_flexfield_name = p_desc_flex_name
    and  dfcu.application_id = p_application_id
    and  dfcu.enabled_flag = 'Y'
  order by 1,2;
--
 v_title           varchar2(60);
 v_column_expr     varchar2(2000);
 v_label_expr      varchar2(2000);
 v_delimiter       varchar2(1);
 v_application_id  number;
--
begin
--
  select app.application_id
  into   v_application_id
  from   fnd_application app
  where  upper(app.application_short_name) = upper(p_appl_short_name);
--
  select df.concatenated_segment_delimiter,
	 df.title
  into   v_delimiter,
	 v_title
  from   fnd_descriptive_flexs_vl df
  where  df.descriptive_flexfield_name = p_desc_flex_name
    and  df.application_id = v_application_id;
--
if (p_aol_seperator_flag = false) then
--
 v_delimiter := fnd_global.local_chr(127);
--
end if;
--
  for flex_col in csr_flex_columns(v_application_id,
				   p_desc_flex_name,
				   p_desc_flex_context) loop
--
    if v_column_expr is null then
--
      v_column_expr := p_table_alias || '.' || flex_col.column_name;
      v_label_expr  := flex_col.label;
--
    else
--
      v_column_expr := v_column_expr || '||''' || v_delimiter || '''||' ||
		       p_table_alias || '.' || flex_col.column_name;
      v_label_expr  := v_label_expr  || '.' || flex_col.label;
--
    end if;
--
  end loop;
--
  p_title       := v_title;
  p_label_expr  := v_label_expr;
  p_column_expr := v_column_expr;
--
end get_dvlpr_desc_flex;
--
--
function get_person_name
(p_session_date date,
 p_person_id number) return varchar2
--
as
v_person_name per_all_people_f.full_name%type;
--
begin
--
  hr_utility.trace('entered hr_reports.get_person_name');
--
  hr_utility.set_location('hr_reports.get_person_name',5);
  if p_person_id is null then
    null;
  else
    begin
      hr_utility.set_location('hr_reports.get_person_name',10);
      select p.full_name
      into   v_person_name
      from   per_all_people_f p
      where  p.person_id = p_person_id
	and  p_session_date between p.effective_start_date
				and p.effective_end_date;
    exception
      when no_data_found then null;
    end;
  end if;
--
 hr_utility.trace('leaving hr_reports.get_person_name');
--
 return v_person_name;
--
end get_person_name;
--
function get_party_number
(p_party_id in number) return varchar2 as
--
  l_party_number hz_parties.party_number%type;
--
begin
  --
  hr_utility.set_location('Entering hr_reports.get_party_number',5);
  --
  begin
     --
     select party_number
     into l_party_number
     from hz_parties
     where party_id = p_party_id;
     --
     hr_utility.set_location('hr_reports.get_party_number',10);
     --
  exception
     when no_data_found then
         null;
         hr_utility.set_location('hr_reports.get_party_number',15);
  end;
  --
  hr_utility.set_location('Leaving hr_reports.get_party_number',20);
  --
  return l_party_number;
  --
end get_party_number;
--
end hr_reports;

/

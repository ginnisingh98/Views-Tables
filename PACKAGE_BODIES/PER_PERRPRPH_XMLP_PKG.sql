--------------------------------------------------------
--  DDL for Package Body PER_PERRPRPH_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PERRPRPH_XMLP_PKG" AS
/* $Header: PERRPRPHB.pls 120.1 2007/12/06 11:33:23 amakrish noship $ */

function BeforeReport return boolean is
begin
P_SESSION_DATE1:=TO_CHAR(P_SESSION_DATE,'DD-MON-YYYY');
declare
 v_pos_hierarchy_name  varchar2(30);
 v_version             number;
 v_version_start_date  date;
 v_version_end_date    date;
begin



--hr_standard.event('BEFORE REPORT');

 c_business_group_name :=
   hr_reports.get_business_group(p_business_group_id);

 hr_reports.get_position_hierarchy(null,
                                   p_pos_structure_version_id,
                                   v_pos_hierarchy_name,
                                   v_version,
                                   v_version_start_date,
                                   v_version_end_date);

 c_pos_hierarchy_name := v_pos_hierarchy_name;
 c_version := v_version;
 c_version_start_date := v_version_start_date;
 c_version_end_date := v_version_end_date;

 if p_session_date <= nvl(c_version_end_date,
                           to_date('31/12/4712','DD/MM/YYYY')) and
    p_session_date >= c_version_start_date then
   c_session_date := p_session_date;
 else
   c_session_date := c_version_start_date;
 end if;


 c_parent_position_name :=
   hr_reports.get_position(p_parent_position_id, c_session_date);


 c_holders_shown :=
   hr_reports.get_lookup_meaning('YES_NO',
                                 p_holder_flag);

end;  return (TRUE);
end;

function c_nameformula(parent_position_id in number) return varchar2 is
begin

begin

 return (hr_reports.get_position(parent_position_id,c_session_date));

end;
RETURN NULL; end;

function c_count_subordsformula(parent_position_id in number) return number is
begin

   return (hr_reports.count_pos_subordinates(p_pos_structure_version_id,
                                     parent_position_id));

end;

function c_count_subords1formula(subordinate_position_id in number) return number is
begin

   return(hr_reports.count_pos_subordinates(p_pos_structure_version_id,
                                     subordinate_position_id));


end;

--function c_count_child_posformula(parent_position_id in number) return number is
function c_count_child_posformula(arg_parent_position_id in number) return number is
begin

declare
 v_count_child_pos number;
begin

 select nvl(count(*),0)
 into   v_count_child_pos
 from   per_pos_structure_elements pse
 where  pse.pos_structure_version_id = p_pos_structure_version_id
   --and  pse.parent_position_id = parent_position_id;
   and  pse.parent_position_id = arg_parent_position_id;

 return v_count_child_pos;

end;
RETURN NULL; end;

function c_count_holdersformula(parent_position_id in number) return number is
begin

declare

  v_count_holders number;

begin

  select count(*)
  into   v_count_holders
  from   per_people_f peo,
         per_assignments_f asg
  where  peo.person_id = asg.person_id
    and  asg.position_id = parent_position_id
    and  c_session_date between peo.effective_start_date
                             and peo.effective_end_date
    and  c_session_date between asg.effective_start_date
                             and asg.effective_end_date
        and peo.current_employee_flag = 'Y'
    and asg.assignment_type <> 'A';

  return v_count_holders;

end;
RETURN NULL; end;

function c_count_holders1formula(subordinate_position_id in number) return number is
begin

declare

  v_count_holders number;

begin

  select count(*)
  into   v_count_holders
  from   per_people_f peo,
         per_assignments_f asg
  where  peo.person_id = asg.person_id
    and  asg.position_id = subordinate_position_id
    and  c_session_date between peo.effective_start_date
                             and peo.effective_end_date
    and  c_session_date between asg.effective_start_date
                             and asg.effective_end_date
    and peo.current_employee_flag = 'Y'
  and asg.assignment_type <> 'A';

  return v_count_holders;

end;
RETURN NULL; end;

function AfterReport return boolean is
begin

--hr_standard.event('AFTER REPORT');

  return (TRUE);
end;

--Functions to refer Oracle report placeholders--

 Function C_BUSINESS_GROUP_NAME_p return varchar2 is
	Begin
	 return C_BUSINESS_GROUP_NAME;
	 END;
 Function C_REPORT_SUBTITLE_p return varchar2 is
	Begin
	 return C_REPORT_SUBTITLE;
	 END;
 Function C_POS_HIERARCHY_NAME_p return varchar2 is
	Begin
	 return C_POS_HIERARCHY_NAME;
	 END;
 Function C_VERSION_p return number is
	Begin
	 return C_VERSION;
	 END;
 Function C_VERSION_START_DATE_p return date is
	Begin
	 return C_VERSION_START_DATE;
	 END;
 Function C_VERSION_END_DATE_p return date is
	Begin
	 return C_VERSION_END_DATE;
	 END;
 Function C_PARENT_POSITION_NAME_p return varchar2 is
	Begin
	 return C_PARENT_POSITION_NAME;
	 END;
 Function C_HOLDERS_SHOWN_p return varchar2 is
	Begin
	 return C_HOLDERS_SHOWN;
	 END;
 Function C_SESSION_DATE_p return date is
	Begin
	 return C_SESSION_DATE;
	 END;
END PER_PERRPRPH_XMLP_PKG ;

/

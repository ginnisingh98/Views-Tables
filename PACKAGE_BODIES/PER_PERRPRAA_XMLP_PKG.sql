--------------------------------------------------------
--  DDL for Package Body PER_PERRPRAA_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_PERRPRAA_XMLP_PKG" AS
/* $Header: PERRPRAAB.pls 120.1 2007/12/06 11:30:06 amakrish noship $ */
function BeforeReport return boolean is
begin
P_SESSION_DATE1:=TO_CHAR(P_SESSION_DATE,'DD-MON-YYYY');
declare
        v_organization_name varchar2(240);
       v_organization_type varchar2(80);

begin


--hr_standard.event('BEFORE REPORT');

 c_business_group_name :=
   hr_reports.get_business_group(p_business_group_id);

 IF p_person_id is null AND p_organization_id is null THEN
    p_organization_id := p_business_group_id;
 END IF;

 hr_reports.get_organization(p_organization_id,v_organization_name,v_organization_type);
 c_organization_name := v_organization_name;



 IF p_person_id is not null THEN
    c_person_name := hr_reports.get_person_name(p_session_date,p_person_id);
 END IF;

 c_abs_type_name1  := hr_reports.get_abs_type(p_abs_type1);
 c_abs_type_name2  := hr_reports.get_abs_type(p_abs_type2);
 c_abs_type_name3  := hr_reports.get_abs_type(p_abs_type3);
 c_abs_type_name4  := hr_reports.get_abs_type(p_abs_type4);
 c_abs_type_name5  := hr_reports.get_abs_type(p_abs_type5);
 c_abs_type_name6  := hr_reports.get_abs_type(p_abs_type6);
 c_abs_type_name7  := hr_reports.get_abs_type(p_abs_type7);
 c_abs_type_name8  := hr_reports.get_abs_type(p_abs_type8);
 c_abs_type_name9  := hr_reports.get_abs_type(p_abs_type9);
 c_abs_type_name10 := hr_reports.get_abs_type(p_abs_type10);

 c_display_abtypes := NULL;
 c_absence_types := NULL;
 c_abtypes_entered := 'N';

 IF p_abs_type1 IS NOT NULL THEN
     c_display_abtypes := c_abs_type_name1||',';
     c_abtypes_entered := 'Y';
     c_absence_types   := p_abs_type1||',';
 END IF;
 IF p_abs_type2  IS NOT NULL THEN
    c_display_abtypes := c_display_abtypes||c_abs_type_name2||',';
    c_abtypes_entered := 'Y';
    c_absence_types   := c_absence_types||p_abs_type2||',';
END IF;
 IF p_abs_type3  IS NOT NULL THEN
    c_display_abtypes := c_display_abtypes||c_abs_type_name3||',';
    c_abtypes_entered := 'Y';
    c_absence_types   := c_absence_types||p_abs_type3||',';
 END IF;
 IF p_abs_type4  IS NOT NULL THEN
    c_display_abtypes := c_display_abtypes||c_abs_type_name4||',';
    c_abtypes_entered := 'Y';
    c_absence_types   := c_absence_types||p_abs_type4||',';
 END IF;
 IF p_abs_type5  IS NOT NULL THEN
    c_display_abtypes := c_display_abtypes||c_abs_type_name5||',';
    c_abtypes_entered := 'Y';
    c_absence_types   := c_absence_types||p_abs_type5||',';
 END IF;
 IF p_abs_type6  IS NOT NULL THEN
    c_display_abtypes := c_display_abtypes||c_abs_type_name6||',';
    c_abtypes_entered := 'Y';
    c_absence_types   := c_absence_types||p_abs_type6||',';
 END IF;
 IF p_abs_type7  IS NOT NULL THEN
    c_display_abtypes := c_display_abtypes||c_abs_type_name7||',';
    c_abtypes_entered := 'Y';
    c_absence_types   := c_absence_types||p_abs_type7||',';
 END IF;
 IF p_abs_type8  IS NOT NULL THEN
    c_display_abtypes := c_display_abtypes||c_abs_type_name8||',';
    c_abtypes_entered := 'Y';
    c_absence_types   := c_absence_types||p_abs_type8||',';
 END IF;
 IF p_abs_type9  IS NOT NULL THEN
    c_display_abtypes := c_display_abtypes||c_abs_type_name9||',';
    c_abtypes_entered := 'Y';
    c_absence_types   := c_absence_types||p_abs_type9||',';
 END IF;
 IF p_abs_type10  IS NOT NULL THEN
    c_display_abtypes := c_display_abtypes||c_abs_type_name10||',';
    c_abtypes_entered := 'Y';
    c_absence_types   := c_absence_types||p_abs_type10||',';
 END IF;
 c_absence_types   := rtrim(c_absence_types,',');
 c_display_abtypes := rtrim(c_display_abtypes,',');
  IF c_absence_types IS NOT NULL then
    p_absence_sql := 'and aat.absence_attendance_type_id in ('||c_absence_types||')';
    p_absence_att_sql := 'and aa.absence_attendance_type_id in ('||c_absence_types||')';
  END IF;


	select value
	into c_nls_language
	from nls_session_parameters
	where parameter = 'NLS_LANGUAGE';


end;  return (TRUE);
end;

function c_running_totalformula(summ_person_id in number, p_absence_attendance_type_id in number) return number is
begin

declare l_runtot NUMBER(12,2);
begin
begin


SELECT  sum (fnd_number.canonical_to_number(target.screen_entry_value))
INTO    l_runtot
FROM   pay_element_entry_values_f target
,      pay_element_entries_f  ee
,      per_absence_attendance_types abtype
,      per_assignments_f ASS
WHERE  ASS.person_id = summ_person_id
AND    ASS.primary_flag = 'Y'
AND    P_SESSION_DATE
       BETWEEN ASS.effective_start_date AND ASS.effective_end_date
AND    ass.assignment_id = ee.assignment_id
AND    target.element_entry_id = EE.element_entry_id
AND    ABTYPE.absence_attendance_type_id = p_absence_attendance_type_id
AND    ABTYPE.input_value_id = target.input_value_id;
EXCEPTION
         when no_data_found then null;
end;
return(l_runtot);
end;
RETURN NULL; end;

function AfterReport return boolean is
begin

--hr_standard.event('AFTER REPORT');

  return (TRUE);
end;

function AfterPForm return boolean is
begin

  return (TRUE);
end;

function BetweenPage return boolean is
begin

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
 Function C_DISPLAY_ABTYPES_p return varchar2 is
	Begin
	 return C_DISPLAY_ABTYPES;
	 END;
 Function C_ORGANIZATION_NAME_p return varchar2 is
	Begin
	 return C_ORGANIZATION_NAME;
	 END;
 Function C_ABTYPES_ENTERED_p return varchar2 is
	Begin
	 return C_ABTYPES_ENTERED;
	 END;
 Function C_ABSENCE_TYPES_p return varchar2 is
	Begin
	 return C_ABSENCE_TYPES;
	 END;
 Function C_ABS_TYPE_NAME1_p return varchar2 is
	Begin
	 return C_ABS_TYPE_NAME1;
	 END;
 Function C_ABS_TYPE_NAME2_p return varchar2 is
	Begin
	 return C_ABS_TYPE_NAME2;
	 END;
 Function C_ABS_TYPE_NAME3_p return varchar2 is
	Begin
	 return C_ABS_TYPE_NAME3;
	 END;
 Function C_ABS_TYPE_NAME4_p return varchar2 is
	Begin
	 return C_ABS_TYPE_NAME4;
	 END;
 Function C_ABS_TYPE_NAME5_p return varchar2 is
	Begin
	 return C_ABS_TYPE_NAME5;
	 END;
 Function C_ABS_TYPE_NAME6_p return varchar2 is
	Begin
	 return C_ABS_TYPE_NAME6;
	 END;
 Function C_ABS_TYPE_NAME7_p return varchar2 is
	Begin
	 return C_ABS_TYPE_NAME7;
	 END;
 Function C_ABS_TYPE_NAME8_p return varchar2 is
	Begin
	 return C_ABS_TYPE_NAME8;
	 END;
 Function C_ABS_TYPE_NAME9_p return varchar2 is
	Begin
	 return C_ABS_TYPE_NAME9;
	 END;
 Function C_ABS_TYPE_NAME10_p return varchar2 is
	Begin
	 return C_ABS_TYPE_NAME10;
	 END;
 Function C_PERSON_NAME_p return varchar2 is
	Begin
	 return C_PERSON_NAME;
	 END;
 Function C_NLS_LANGUAGE_p return varchar2 is
	Begin
	 return C_NLS_LANGUAGE;
	 END;
END PER_PERRPRAA_XMLP_PKG ;

/

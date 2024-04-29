--------------------------------------------------------
--  DDL for Package Body PA_PAXPEAST_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PAXPEAST_XMLP_PKG" AS
/* $Header: PAXPEASTB.pls 120.1 2008/01/09 13:56:45 krreddy noship $ */
FUNCTION  get_company_name    RETURN BOOLEAN IS
  l_name                  gl_sets_of_books.name%TYPE;
BEGIN
/*  SELECT  gl.name
  INTO    l_name
  FROM    gl_sets_of_books gl,pa_implementations pi
  WHERE   gl.set_of_books_id = pi.set_of_books_id;*/
   select name
  into l_name
  from gl_sets_of_books
  where set_of_books_id = fnd_profile.value('GL_SET_OF_BKS_ID');
  c_company_name_header     := l_name;
  RETURN (TRUE);
EXCEPTION
  WHEN   OTHERS  THEN
    RETURN (FALSE);
END;
function BeforeReport return boolean is
begin
declare
init_error exception;
Org_Name hr_organization_units.name%TYPE;
Job_Name per_jobs.name%TYPE;
Sort_By_Meaning pa_lookups.meaning%TYPE;
begin
ORGANIZATION_ID_T:=ORGANIZATION_ID;
JOB_ID_T := JOB_ID;
/*srw.user_exit('FND SRWINIT');*/null;
if organization_id is not NULL then
   select substrb(name,1,60) into Org_Name from
          hr_organization_units
   where
       organization_id = ORGANIZATION_ID_T;
end if;
C_Org_Name := Org_Name;
if Job_id is not NULL then
    select name into Job_Name from per_jobs
    where
       job_id = JOB_ID_T;
end if;
C_Job := Job_Name;
if SORT_BY is not NULL then
  select meaning into Sort_By_Meaning from
          pa_lookups
   where  lookup_code = SORT_BY and
          lookup_type = 'ASSIGNMENT SORT BY';
end if;
C_Sort_By_Meaning := Sort_By_Meaning;
if ( get_company_name <> TRUE ) then
  raise init_error;
end if;
end;  return (TRUE);
end;
function BeforePForm return boolean is
begin
  return (TRUE);
end;
function AfterPForm return boolean is
 l_buffer Varchar2(2000) ;
begin
 EFFECTIVE_DATE_1 := TO_CHAR(EFFECTIVE_DATE ,'DD-MON-YY');
 If organization_id Is Not Null Then
   l_buffer := l_buffer || ' AND a.organization_id = :organization_id ' ;
 End If;
 If job_id Is Not NUll Then
   l_buffer := l_buffer || ' AND a.job_id = :job_id ' ;
 End If;
 If effective_date Is Not Null Then
   l_buffer := l_buffer || ' AND :effective_date between a.effective_start_date and	a.effective_end_date ' ;
   l_buffer := l_buffer || ' AND :effective_date between p.effective_start_date and	p.effective_end_date ' ;
 else
   l_buffer := l_buffer || ' AND sysdate between a.effective_start_date and	a.effective_end_date ' ;
   l_buffer := l_buffer || ' AND sysdate between p.effective_start_date and	p.effective_end_date ' ;
 End If;
 If job_level is Not Null Then
    l_buffer := l_buffer || ' AND jd.segment1 = :job_level ' ;
 End If;
 If job_discipline Is Not Null Then
    l_buffer := l_buffer || ' AND jd.segment2 = :job_discipline ' ;
 End If;
 p_para_sql := l_buffer;
  return (TRUE);
end;
function BetweenPage return boolean is
begin
  return (TRUE);
end;
function AfterReport return boolean is
begin
  /*srw.user_exit('FND SRWEXIT') ;*/null;
  return (TRUE);
end;
--Functions to refer Oracle report placeholders--
 Function C_Company_Name_Header_p return varchar2 is
	Begin
	 return C_Company_Name_Header;
	 END;
 Function C_Org_Name_p return varchar2 is
	Begin
	 return C_Org_Name;
	 END;
 Function C_Job_p return varchar2 is
	Begin
	 return C_Job;
	 END;
 Function C_Sort_By_Meaning_p return varchar2 is
	Begin
	 return C_Sort_By_Meaning;
	 END;
END PA_PAXPEAST_XMLP_PKG ;


/

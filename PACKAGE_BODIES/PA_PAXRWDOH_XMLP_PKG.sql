--------------------------------------------------------
--  DDL for Package Body PA_PAXRWDOH_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PAXRWDOH_XMLP_PKG" AS
/* $Header: PAXRWDOHB.pls 120.0 2008/01/02 11:56:30 krreddy noship $ */

FUNCTION  get_company_name    RETURN BOOLEAN IS
  l_name                  gl_sets_of_books.name%TYPE;
BEGIN
  SELECT  gl.name
  INTO    l_name
  FROM    gl_sets_of_books gl,pa_implementations pi
  WHERE   gl.set_of_books_id = pi.set_of_books_id;

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
ndf Varchar2(80);
begin

/*srw.user_exit('FND SRWINIT');*/null;

if START_ORG_ID is not NULL then
    select substr(name,1,60) into Org_Name from        hr_organization_units
    where organization_id = START_ORG_ID;
end if;
C_Org_Name := Org_Name;
if ( get_company_name <> TRUE ) then
  raise init_error;
end if;

   select meaning into ndf from pa_lookups where
    lookup_code = 'NO_DATA_FOUND' and
    lookup_type = 'MESSAGE';
  c_no_data_found := ndf;
  end;



if P_hierarchy_type = 'PA_REPORTING_ORG' then
	select meaning into p_select_column
	  From pa_lookups
	 where lookup_code = 'PA_REPORTING_ORG' and lookup_type='ALL_HIERARCHY_CLASS';
   P_structure_id  := 'and pi.organization_structure_id = pos1.organization_structure_id';
   P_version_id  := 'and pi.org_structure_version_id = posv.org_structure_version_id';
   P_where_clause := 'and    p.org_structure_version_id = pi.org_structure_version_id';
   p_from_clause := 'PER_ORG_STRUCTURE_VERSIONS      	posv';
   p_where_clause1 := 'and p.organization_id_parent= org.organization_id';
   P_Decode_column := 'pi.org_structure_version_id';
   P_select_column1 := 'pi.org_structure_version_id';
   P_parent_org_id  := 'pi.start_organization_id';
   p_burden         := 'and 1=1';
    if start_org_id is null then
	select start_organization_id into start_org_id from pa_implementations;
    end if;

elsif P_hierarchy_type = 'PA_EXPENDITURE_ORG' then
	select meaning into p_select_column
	  From pa_lookups
	 where lookup_code = 'PA_EXPENDITURE_ORG' and lookup_type='ALL_HIERARCHY_CLASS';
   P_structure_id  := 'and pi.exp_org_structure_id = pos1.organization_structure_id';
   P_version_id  := 'and pi.exp_org_structure_version_id = posv.org_structure_version_id';
   P_where_clause := 'and    p.org_structure_version_id = pi.exp_org_structure_version_id';
   p_from_clause := 'PER_ORG_STRUCTURE_VERSIONS      	posv';
   p_where_clause1 := 'and p.organization_id_parent= org.organization_id ';
   P_Decode_column := 'pi.Exp_org_structure_version_id';
P_select_column1 := 'pi.exp_org_structure_version_id';
P_parent_org_id  := 'pi.exp_start_org_id';
   p_burden         := 'and 1=1';
 if start_org_id is null then
	select exp_start_org_id into start_org_id from pa_implementations;
    end if;


elsif P_hierarchy_type = 'PA_PROJECT_ORG' then
	select meaning into p_select_column
	  From pa_lookups
	 where lookup_code = 'PA_PROJECT_ORG' and lookup_type='ALL_HIERARCHY_CLASS';
   P_structure_id  := 'and pi.proj_org_structure_id = pos1.organization_structure_id';
   P_version_id  := 'and pi.proj_org_structure_version_id = posv.org_structure_version_id';

   P_where_clause := 'and    p.org_structure_version_id = pi.proj_org_structure_version_id';
   p_from_clause := 'PER_ORG_STRUCTURE_VERSIONS      	posv';
   p_where_clause1 := 'and p.organization_id_parent= org.organization_id';
   P_Decode_column := 'pi.proj_org_structure_version_id';
   P_select_column1 := 'pi.proj_org_structure_version_id';
   P_parent_org_id  := 'pi.proj_start_org_id';
   p_burden         := 'and 1=1';
 if start_org_id is null then
	select proj_start_org_id into start_org_id from pa_implementations;
    end if;

elsif p_Hierarchy_Type = 'PA_BURDENING_ORG' then
   P_where_clause := 'and    p.org_structure_version_id =to_number(hr2.org_information2)';
   p_where_clause1 := 'and pi.business_group_id = hr2.organization_id';
   P_structure_id  := 'and p.org_structure_version_id = posv.org_structure_version_id';
   P_version_id  := 'and pos1.organization_structure_id = posv.organization_structure_id';
   P_org_hr      := 'and p.organization_id_parent= org.organization_id';
   p_from_clause := 'hr_organization_information hr2,PER_ORG_STRUCTURE_VERSIONS      	posv';
   P_Decode_column := 'to_number(hr2.org_information2)';
   P_select_column1 := 'p.organization_id_parent';
   p_parent_org_id  :='p.organization_id_parent';
   p_burden:=  'and hr2.org_information_context ' ||'='||''''||'Project Burdening Hierarchy'||'''';
select meaning  into p_select_column
	  From pa_lookups
	 where lookup_code = 'PA_BURDENING_ORG' and lookup_type='ALL_HIERARCHY_CLASS';


if start_org_id is null then

select distinct organization_id_parent into start_org_id
from per_org_structure_elements a
     ,pa_implementations b
     ,hr_organization_information c
where organization_id_parent not in
( select d.ORGANIZATION_ID_CHILD from per_org_structure_elements d
   where d.org_structure_version_id = to_number(c.org_information2)
)
and a.org_structure_version_id = to_number(c.org_information2)
and b.business_group_id = c.organization_id
and c.org_information_context = 'Project Burdening Hierarchy' ;

 end if;
end if;

 return (TRUE);
 EXCEPTION when NO_DATA_FOUND then
       null;
       return(TRUE);
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
 Function C_NO_DATA_FOUND_p return varchar2 is
	Begin
	 return C_NO_DATA_FOUND;
	 END;
END PA_PAXRWDOH_XMLP_PKG ;


/

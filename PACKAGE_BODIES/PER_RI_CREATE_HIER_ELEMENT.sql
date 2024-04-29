--------------------------------------------------------
--  DDL for Package Body PER_RI_CREATE_HIER_ELEMENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_RI_CREATE_HIER_ELEMENT" As
/* $Header: perrihierele.pkb 120.1 2006/04/13 03:24:38 pkagrawa noship $ */
Function get_line_status(p_view Varchar2,p_dp_batch_line_id Number)
Return Varchar2 Is

Type csr_dp_line_status_type Is Ref Cursor;
csr_dp_line_status csr_dp_line_status_type;

l_status Varchar2(2);
l_sql_stmt Varchar2(200);
Begin

   l_sql_stmt :=  'Select line_status From '||p_view||' Where batch_line_id = :1';

   Open csr_dp_line_status For l_sql_stmt using p_dp_batch_line_id;
   Fetch csr_dp_line_status Into l_status;
   Close csr_dp_line_status;

return l_status;

End get_line_status;


Procedure insert_batch_lines(P_BATCH_ID                     in number
			     ,P_DATA_PUMP_BATCH_LINE_ID     in number default null
			     ,P_DATA_PUMP_BUSINESS_GRP_NAME in varchar2 default null
	                     ,P_USER_SEQUENCE               in number default null
			     ,P_LINK_VALUE                  in number default null
			     ,P_EFFECTIVE_DATE              in date
			     ,P_DATE_FROM                   in date
			     ,P_VIEW_ALL_ORGS               in varchar2
			     ,P_END_OF_TIME                 in date
	                     ,P_HR_INSTALLED                in varchar2
	                     ,P_PA_INSTALLED                in varchar2
	                     ,P_POS_CONTROL_ENABLED_FLAG    in varchar2
	                     ,P_WARNING_RAISED              in varchar2
			     ,P_PARENT_ORGANIZATION_NAME    in varchar2
			     ,P_LANGUAGE_CODE               in varchar2
			     ,P_ORG_STR_VERSION_USER_KEY    in varchar2
			     ,P_CHILD_ORGANIZATION_NAME     in varchar2
			     ,P_SECURITY_PROFILE_NAME       in varchar2) as

l_org_structure_user_key   Varchar2(240);
l_temp                     Varchar2(240);
l_org_structure_version_id number;
l_bg_id                    number;
l_temp_id                  number;


l_dp_batch_line_id_org_str     Number;

Cursor csr_get_org_str_user_key(c_batch_line_id in Number) Is
  Select p_org_str_version_user_key
    From hrdpv_create_hierarchy_element
   Where batch_line_id = c_batch_line_id;

Cursor csr_get_org_str_version_id (c_bg_id in number) Is
	select posv.organization_structure_id
	from per_organization_structures pos,per_org_structure_versions posv
	where pos.organization_structure_id = posv.organization_structure_id
	and (posv.business_group_id +0 = c_bg_id
	or posv.business_group_id is null)
	and name = p_org_str_version_user_key;

Cursor csr_bg_id (c_bg_name in varchar2) Is
--	select business_group_id from per_business_groups
--	where name = c_bg_name;

	select hr_api.return_business_group_id(c_bg_name) as business_group_id
	from dual;


Cursor csr_org_str_user_key(c_org_structure_user_key in varchar2 ) Is
  Select unique_key_id
    From hr_pump_batch_line_user_keys
   Where user_key_value = l_org_structure_user_key;



begin

    hr_utility.set_location('Entering per_ri_create_hier_element.insert_batch_lines', 10);

  If p_data_pump_batch_line_id Is Not Null Then

     --get batch line ids
     hr_utility.set_location('Correct Errors Scenario', 20);
     Open csr_get_org_str_user_key(p_data_pump_batch_line_id);
     Fetch csr_get_org_str_user_key Into l_org_structure_user_key;
     Close csr_get_org_str_user_key;


  Else

   hr_utility.set_location('Normal Scenario', 20);

    l_org_structure_user_key     := p_org_str_version_user_key;

  End If;

If l_dp_batch_line_id_org_str Is Null Or get_line_status('HRDPV_CREATE_HIERARCHY_ELEMENT',l_dp_batch_line_id_org_str) <> 'C' Then

Begin
Open csr_bg_id(p_data_pump_business_grp_name);
Fetch csr_bg_id Into l_bg_id;
Close csr_bg_id;
Exception
	When Others Then
	 l_bg_id := Null;
End;

hr_utility.set_location('Business Group id ' || to_char(l_bg_id), 30);

Open csr_get_org_str_version_id(l_bg_id);
Fetch csr_get_org_str_version_id Into l_org_structure_version_id;
Close csr_get_org_str_version_id;

hr_utility.set_location('Org Structure Version id ' || to_char(l_org_structure_version_id) || ' Org Structure Version User Key = ' ||l_org_structure_user_key , 40);


Open csr_org_str_user_key(l_org_structure_user_key);
Fetch csr_org_str_user_key Into l_temp_id;
IF csr_org_str_user_key%NOTFOUND then
hr_utility.set_location('Inserted the User Key '||l_org_structure_user_key , 50);
hr_pump_utils.add_user_key(l_org_structure_user_key,l_org_structure_version_id);
end if;
close csr_org_str_user_key;

hrdpp_create_hierarchy_element.insert_batch_lines(P_BATCH_ID                     => p_batch_id
						  ,P_DATA_PUMP_BATCH_LINE_ID      => p_data_pump_batch_line_id
					          ,P_DATA_PUMP_BUSINESS_GRP_NAME  => p_data_pump_business_grp_name
						  ,P_USER_SEQUENCE                => p_user_sequence
						  ,P_LINK_VALUE                   => p_link_value
						  ,P_EFFECTIVE_DATE               => p_effective_date
						  ,P_DATE_FROM                    => p_date_from
						  ,P_VIEW_ALL_ORGS                => p_view_all_orgs
						  ,P_END_OF_TIME                  => p_end_of_time
						  ,P_HR_INSTALLED                 => p_hr_installed
						  ,P_PA_INSTALLED                 => p_pa_installed
						  ,P_POS_CONTROL_ENABLED_FLAG     => p_pos_control_enabled_flag
						  ,P_WARNING_RAISED               => p_warning_raised
						  ,P_PARENT_ORGANIZATION_NAME     => p_parent_organization_name
						  ,P_LANGUAGE_CODE                => p_language_code
						  ,P_ORG_STR_VERSION_USER_KEY     => l_org_structure_user_key
						  ,P_CHILD_ORGANIZATION_NAME      => p_child_organization_name
						  ,P_SECURITY_PROFILE_NAME        => p_security_profile_name );

End If;

End insert_batch_lines;


End per_ri_create_hier_element;


/

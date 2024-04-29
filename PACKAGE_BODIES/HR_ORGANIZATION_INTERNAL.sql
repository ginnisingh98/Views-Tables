--------------------------------------------------------
--  DDL for Package Body HR_ORGANIZATION_INTERNAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_ORGANIZATION_INTERNAL" as
/* $Header: hrorgbsi.pkb 120.5.12000000.2 2007/04/13 08:12:39 brsinha ship $ */

g_package varchar2(60) := 'hr_organization_internal.';

  procedure HR_ORG_OPERATING_UNIT_UPLOAD
      (
       p_name            	in varchar2
      ,p_organization_id  		in out nocopy number
      ,p_date_from            		in date
      ,p_date_to              		in date
      ,p_internal_external_flag 	in varchar2
      ,p_operating_unit   		in varchar2
       )
  IS
  --
  -- Declare cursors and local variables
  l_organization_name	varchar2(240)	:=p_name;
  l_organization_id	number		:=p_organization_id ;
  l_date_from date			:=p_date_from;
  l_date_to date			:=p_date_to;
  l_internal_external_flag varchar2(30)	:=p_internal_external_flag;
  l_operating_unit_id	number		:=fnd_number.canonical_to_number(p_operating_unit);

  ---
  l_proc                     varchar2(80) := g_package||'hr_org_operating_unit_upload';
  --
  l_int_ext_temp varchar2(30);
  l_business_group_id number;
  l_org_information_id number;
  l_duplicate_org_warning  boolean;
  l_object_version_number_org number;
  l_object_version_number_inf number;
  l_object_version_number  number;
  l_org_info_type_code varchar2(40);
  l_chk_org_par varchar2(1):='N';
  l_int_ext_check varchar2(1):='Y';
  l_ou_check varchar2(1) := 'N';
  l_name_check varchar2(1) := 'N';
  --
  --
--Cursor to check if Operating unit has been assigned or not
  cursor check_ou_exists is
  select hou1.org_information_id,hou1.org_information_context,hou1.object_version_number
    	 ,ho1.object_version_number
  from
       hr_all_organization_units ho1,
       hr_organization_information hou1
  where ho1.organization_id=l_organization_id
  and hou1.organization_id=ho1.organization_id
  and hou1.org_information_context='Exp Organization Defaults';

 -- Cursor to make sure that internal_external flag is not allowed to update
  cursor get_internal_external_flag is
  select 'Y'
  from hr_all_organization_units
  where organization_id=l_organization_id
  and nvl(internal_external_flag,'X')=nvl(l_internal_external_flag,'X');

 -- Cursor to check orgname, start_date or end_date is modified or not, If modified return object_version_number.
  cursor get_object_version_number is
  select object_version_number
  from  hr_all_organization_units
  where organization_id=l_organization_id
  and
  (name <> l_organization_name
   or date_from <> l_date_from
   or nvl(date_to,to_date('31/12/4712','dd/mm/rrrr')) <>
  		nvl(l_date_to,to_date('31/12/4712','dd/mm/rrrr')));


--Cursor to check valid operating unit id is passed or not
cursor is_valid_ou_id is
select 'Y' from HR_OPERATING_UNITS
where trunc(sysdate) between trunc(date_from) and nvl(trunc(date_to), trunc(sysdate))
and organization_id = p_operating_unit;

-- Cursor to check valid organization name is passed or not.
cursor is_valid_name is
select 'Y' from hr_all_organization_units
where  business_group_id =  l_business_group_id
and name = l_organization_name ;
  --
  begin
  --
   l_business_group_id:=fnd_global.per_business_group_id ;
    hr_utility.set_location('id'||l_operating_unit_id,1000);
    hr_utility.set_location('name'||l_organization_name,1000);
    hr_utility.set_location('OID'||l_organization_id,1000);
    hr_utility.set_location('date'||l_date_from,1000);
    hr_utility.set_location('flag'||l_internal_external_flag,1000);
    hr_utility.set_location('Entering '||l_proc,10);
  --
   -- Validation of incoming values.
   if (l_organization_name is null ) then
	hr_utility.set_location ('Error!!' || l_organization_name, 1001);
       Hr_utility.set_message(800,'HR_ORG_NAME_INVALID');
       Hr_utility.raise_error;
   end if ;
   if ( l_organization_id is null) then
     open is_valid_name ;
     fetch is_valid_name into l_name_check ;
     if ( is_valid_name %found ) THEN  -- Organization exists, update needed
       select organization_id into l_organization_id
       from hr_all_organization_units
       where  business_group_id =  l_business_group_id
       and name = l_organization_name ;
       /***********
       hr_utility.set_location ('Error!!' || l_organization_name, 1002);
       Hr_utility.set_message(800,'HR_289773_MULTI_ORG_DUPLICATE');
       Hr_utility.raise_error;
       */
     else      -- Organization does not exist.New org to be created
        null;
     end if;
   end if;
   if (l_date_from is null) then
       	hr_utility.set_location ('Error!!' || l_organization_name, 1003);
       Hr_utility.set_message(800,'HR_START_DATE_INVALID');
       Hr_utility.raise_error;
   end if;
   if ((p_internal_external_flag is null) or (p_internal_external_flag not in ('INT', 'EXT'))) then
      	hr_utility.set_location ('Error!!' , 1004);
       Hr_utility.set_message(800,'HR_INT_EXT_INVALID');
       Hr_utility.raise_error;
   end if;

   if (l_date_to is not null) then
	if (l_date_to < l_date_from) then
	      	hr_utility.set_location ('Error!!' , 1005);
   	        Hr_utility.set_message(800,'HR_END_DATE_INVALID');
		Hr_utility.raise_error;
	end if;
   end if;

   if ( p_operating_unit is not null) then
	open is_valid_ou_id;
	fetch is_valid_ou_id into l_ou_check ;
	if (is_valid_ou_id%NOTFOUND) then
		hr_utility.set_location ('Error!!' , 1006);
	       Hr_utility.set_message(800,'HR_OU_INVALID');
	       Hr_utility.raise_error;
	end if;
   end if;
 -- Validation ends
  hr_utility.set_location(l_proc,20);

  --check if hr organization exists
  if (l_organization_id is not null) then

     --Update row in HR_ORGANIZATION_INFORMATION Table

     open get_internal_external_flag;
     fetch get_internal_external_flag into l_int_ext_check;
     if (get_internal_external_flag%notfound) then
	       Hr_utility.set_message(800,'HR_449749_INT_EXT_ERROR');
		Hr_utility.raise_error;
     end if;
       open check_ou_exists;
       fetch check_ou_exists into l_org_information_id,l_org_info_type_code,l_object_version_number_inf
                                     ,l_object_version_number_org;

      if (check_ou_exists%found) then
              begin
               hr_organization_api.update_org_information(
              p_effective_date       =>sysdate
             ,p_org_information_id   =>l_org_information_id
             ,p_org_info_type_code   =>l_org_info_type_code
             ,p_org_information1     =>l_operating_unit_id
             ,p_object_version_number=>l_object_version_number_inf
             );
             exception
              when others then
              Hr_utility.set_message(800,'HR_449738_UNABLE_TO_UPD_HRORG');
              Hr_utility.raise_error;
              end;

     elsif(l_operating_unit_id is not null) then
        begin
     	  hr_organization_api.create_org_information(
     	   p_effective_date          =>sysdate
     	  ,p_organization_id         =>l_organization_id
     	  ,p_org_information1        =>l_operating_unit_id
     	  ,p_org_info_type_code      =>'Exp Organization Defaults'
     	  ,p_org_information_id      =>l_org_information_id
     	  ,p_object_version_number   =>l_object_version_number);
       exception
       when others then
           Hr_utility.set_message(800,'HR_449738_UNABLE_TO_UPD_HRORG');
           Hr_utility.raise_error;
       end;
     end if;

 -----verify if other parameters modified or not
  begin
  open get_object_version_number;
  fetch get_object_version_number into l_object_version_number_org;
   hr_utility.set_location(l_object_version_number_org,99);
  --Update row in HR_ALL_ORGANIZATION_UNITS Table
  if get_object_version_number%found then
      hr_organization_api.update_organization(
       p_effective_date          =>sysdate
      ,p_name			=>l_organization_name
      ,p_organization_id        =>l_organization_id
      ,p_internal_external_flag =>l_internal_external_flag
      ,p_date_from              =>l_date_from
      ,p_date_to                =>l_date_to
      ,p_object_version_number  =>l_object_version_number_org
      ,p_duplicate_org_warning  =>l_duplicate_org_warning
   );
  end if;
  exception
     when others then
       Hr_utility.set_message(800,'HR_449738_UNABLE_TO_UPD_HRORG');
       Hr_utility.raise_error;
  end;
  close get_internal_external_flag;
  close get_object_version_number;
  close check_ou_exists;


--
  else
  --Create an Hr organization
    hr_utility.set_location(l_proc,30);
      begin
      hr_organization_api.create_hr_organization(
       p_effective_date             =>sysdate
      ,p_business_group_id          =>l_business_group_id
      ,p_name                       =>l_organization_name
      ,p_date_to                    =>l_date_to
      ,p_date_from                  =>l_date_from
      ,p_internal_external_flag     =>l_internal_external_flag
      ,p_enabled_flag               =>'Y'
      ,p_object_version_number_inf  =>l_object_version_number_inf
      ,p_object_version_number_org  =>l_object_version_number_org
      ,p_organization_id            =>l_organization_id
      ,p_org_information_id         =>l_org_information_id
      ,p_duplicate_org_warning      =>l_duplicate_org_warning);
      --
     exception
     when others then
      Hr_utility.set_message(800,'HR_449737_UNABLE_TO_CREATE');
      Hr_utility.raise_error;
     end;

      if(l_operating_unit_id is not null) then
       begin
      hr_organization_api.create_org_information(
       p_effective_date          =>sysdate
      ,p_organization_id         =>l_organization_id
      ,p_org_information1        =>l_operating_unit_id
      ,p_org_info_type_code      =>'Exp Organization Defaults'
      ,p_org_information_id      =>l_org_information_id
      ,p_object_version_number   =>l_object_version_number
     );
     exception
     when others then
      Hr_utility.set_message(800,'HR_449737_UNABLE_TO_CREATE');
      Hr_utility.raise_error;
      end;
    end if;
  end if;
  p_organization_id := l_organization_id ;
 commit;     -- bug 5722328
  --
  --
    hr_utility.set_location('Leaving '||l_proc,40);
  --
  end HR_ORG_OPERATING_UNIT_UPLOAD;
  end HR_ORGANIZATION_INTERNAL;

/

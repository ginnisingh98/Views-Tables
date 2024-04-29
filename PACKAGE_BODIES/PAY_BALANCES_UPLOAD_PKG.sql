--------------------------------------------------------
--  DDL for Package Body PAY_BALANCES_UPLOAD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_BALANCES_UPLOAD_PKG" AS
/* $Header: pybaluld.pkb 120.2 2006/07/21 10:03:51 tbattoo noship $ */

--Global cursor declarations

--Cursor to select business group id
cursor csr_bg_id(p_BG_NAME	VARCHAR2) is
select business_group_id
from per_business_groups
where name =p_BG_NAME;

--Cursor to determine if session id is present in hr_owner_definitions
CURSOR csr_get_session_id IS
SELECT userenv('sessionid') from dual;

cursor csr_get_hr_sess_id(p_session_id HR_OWNER_DEFINITIONS.SESSION_ID%TYPE) is
select session_id
from hr_owner_definitions
where session_id=p_session_id;

--This procedure is used for uploading data into table PAY_BALANCE_CATEGORIES_F
--This procedure is called from pybalcat.lct configuration file
PROCEDURE PAY_BAL_CATF_LOAD_ROW
	(p_CATEGORY_NAME 		IN VARCHAR2
	,p_EFFECTIVE_START_DATE 	IN VARCHAR2
	,p_EFFECTIVE_END_DATE 		IN VARCHAR2
	,p_LEGISLATION_CODE 		IN VARCHAR2
	,p_BUSINESS_GROUP_NAME		IN VARCHAR2
	,p_SAVE_RUN_BALANCE_ENABLED 	IN VARCHAR2
        ,p_USER_CATEGORY_NAME           IN VARCHAR2
	,p_PBC_INFORMATION_CATEGORY     IN VARCHAR2
	,p_PBC_INFORMATION1		IN VARCHAR2
	,p_PBC_INFORMATION2		IN VARCHAR2
	,p_PBC_INFORMATION3		IN VARCHAR2
	,p_PBC_INFORMATION4		IN VARCHAR2
	,p_PBC_INFORMATION5		IN VARCHAR2
	,p_PBC_INFORMATION6		IN VARCHAR2
	,p_PBC_INFORMATION7		IN VARCHAR2
	,p_PBC_INFORMATION8		IN VARCHAR2
	,p_PBC_INFORMATION9		IN VARCHAR2
	,p_PBC_INFORMATION10		IN VARCHAR2
	,p_PBC_INFORMATION11		IN VARCHAR2
	,p_PBC_INFORMATION12		IN VARCHAR2
	,p_PBC_INFORMATION13		IN VARCHAR2
	,p_PBC_INFORMATION14		IN VARCHAR2
	,p_PBC_INFORMATION15		IN VARCHAR2
	,p_PBC_INFORMATION16		IN VARCHAR2
	,p_PBC_INFORMATION17		IN VARCHAR2
	,p_PBC_INFORMATION18		IN VARCHAR2
	,p_PBC_INFORMATION19		IN VARCHAR2
	,p_PBC_INFORMATION20		IN VARCHAR2
	,p_PBC_INFORMATION21		IN VARCHAR2
	,p_PBC_INFORMATION22		IN VARCHAR2
	,p_PBC_INFORMATION23		IN VARCHAR2
	,p_PBC_INFORMATION24		IN VARCHAR2
	,p_PBC_INFORMATION25		IN VARCHAR2
	,p_PBC_INFORMATION26		IN VARCHAR2
	,p_PBC_INFORMATION27		IN VARCHAR2
	,p_PBC_INFORMATION28		IN VARCHAR2
	,p_PBC_INFORMATION29		IN VARCHAR2
	,p_PBC_INFORMATION30		IN VARCHAR2
	,p_OVN				IN VARCHAR2
	,p_OWNER                   	IN VARCHAR2
	) IS

l_balance_category_id   PAY_BALANCE_CATEGORIES_F.BALANCE_CATEGORY_ID%TYPE;
l_category_name    	PAY_BALANCE_CATEGORIES_F.CATEGORY_NAME%TYPE;
l_effective_start_date	PAY_BALANCE_CATEGORIES_F.EFFECTIVE_START_DATE%TYPE;
l_effective_end_date	PAY_BALANCE_CATEGORIES_F.EFFECTIVE_END_DATE%TYPE;
l_legislation_code	PAY_BALANCE_CATEGORIES_F.LEGISLATION_CODE%TYPE;
l_business_group_id	PAY_BALANCE_CATEGORIES_F.BUSINESS_GROUP_ID%TYPE;
l_bus_grp_id		PAY_BALANCE_CATEGORIES_F.BUSINESS_GROUP_ID%TYPE;
l_ovn			PAY_BALANCE_CATEGORIES_F.OBJECT_VERSION_NUMBER%TYPE;
l_owner			VARCHAR2(6);
l_nextval		NUMBER;

cursor csr_sel_bal_category_all is
SELECT balance_category_id
	,category_name
	,effective_start_date
	,effective_end_date
	,legislation_code
	,business_group_id
	,object_version_number
	,DECODE( NVL(last_updated_by,-1), 1, 'SEED', 'CUSTOM')
FROM	PAY_BALANCE_CATEGORIES_F
WHERE	category_name	= p_CATEGORY_NAME
AND	effective_start_date  =to_date(p_EFFECTIVE_START_DATE,'YYYY/MM/DD')
AND 	effective_end_date   =to_date(p_EFFECTIVE_END_DATE,'YYYY/MM/DD')
AND nvl(legislation_code,1) =nvl(p_LEGISLATION_CODE,1);

cursor csr_sel_bal_category_mid is
SELECT balance_category_id
	,category_name
	,effective_start_date
	,effective_end_date
	,legislation_code
	,business_group_id
	,object_version_number
	,DECODE( NVL(last_updated_by,-1), 1, 'SEED', 'CUSTOM')
FROM	PAY_BALANCE_CATEGORIES_F
WHERE	category_name	= p_CATEGORY_NAME
AND	effective_start_date  =to_date(p_EFFECTIVE_START_DATE,'YYYY/MM/DD')
AND nvl(legislation_code,1) =nvl(p_LEGISLATION_CODE,1);

cursor csr_sel_bal_category_few is
SELECT balance_category_id
	,category_name
	,effective_start_date
	,effective_end_date
	,legislation_code
	,business_group_id
	,object_version_number
	,DECODE( NVL(last_updated_by,-1), 1, 'SEED', 'CUSTOM')
FROM	PAY_BALANCE_CATEGORIES_F
WHERE	category_name	= p_CATEGORY_NAME
AND nvl(legislation_code,1) =nvl(p_LEGISLATION_CODE,1);

BEGIN

	open csr_bg_id(p_BUSINESS_GROUP_NAME);
	fetch csr_bg_id into l_bus_grp_id;
	close csr_bg_id;

	--Check if row in ldt is not in the table;
	open csr_sel_bal_category_few;
	fetch csr_sel_bal_category_few into l_balance_category_id,
	      l_category_name,l_effective_start_date,l_effective_end_date,
	      l_legislation_code,l_business_group_id,l_ovn,l_owner;
	if(csr_sel_bal_category_few%found)then
	   open csr_sel_bal_category_all;
	   fetch csr_sel_bal_category_all into l_balance_category_id,
	      l_category_name,l_effective_start_date,l_effective_end_date,
	      l_legislation_code,l_business_group_id,l_ovn,l_owner;
	   if(csr_sel_bal_category_all%found) then
	   --need to perform a date-track correction or row already exists
	      if(p_OWNER='SEED') then
               	   hr_general2.init_fndload(800,1);
	      else
               	   hr_general2.init_fndload(800,-1);
	      end if;
	      update  pay_balance_categories_f
	      set
	         save_run_balance_enabled           = p_SAVE_RUN_BALANCE_ENABLED
                ,user_category_name                 = p_user_category_name
		,pbc_information_category           = p_PBC_INFORMATION_CATEGORY
		,pbc_information1                   = p_pbc_information1
		,pbc_information2                   = p_pbc_information2
		,pbc_information3                   = p_pbc_information3
		,pbc_information4                   = p_pbc_information4
		,pbc_information5                   = p_pbc_information5
		,pbc_information6                   = p_pbc_information6
		,pbc_information7                   = p_pbc_information7
    	        ,pbc_information8                   = p_pbc_information8
		,pbc_information9                   = p_pbc_information9
		,pbc_information10                  = p_pbc_information10
		,pbc_information11                  = p_pbc_information11
		,pbc_information12                  = p_pbc_information12
		,pbc_information13                  = p_pbc_information13
		,pbc_information14                  = p_pbc_information14
		,pbc_information15                  = p_pbc_information15
		,pbc_information16                  = p_pbc_information16
		,pbc_information17                  = p_pbc_information17
		,pbc_information18                  = p_pbc_information18
		,pbc_information19                  = p_pbc_information19
		,pbc_information20                  = p_pbc_information20
		,pbc_information21                  = p_pbc_information21
		,pbc_information22                  = p_pbc_information22
		,pbc_information23                  = p_pbc_information23
		,pbc_information24                  = p_pbc_information24
		,pbc_information25                  = p_pbc_information25
		,pbc_information26                  = p_pbc_information26
		,pbc_information27                  = p_pbc_information27
		,pbc_information28                  = p_pbc_information28
		,pbc_information29                  = p_pbc_information29
		,pbc_information30                  = p_pbc_information30
		,object_version_number              = l_ovn
		where balance_category_id = l_balance_category_id;
		close csr_sel_bal_category_all;

	   else

	      open csr_sel_bal_category_mid;
	      fetch csr_sel_bal_category_mid into l_balance_category_id,
	      l_category_name,l_effective_start_date,l_effective_end_date,
	      l_legislation_code,l_business_group_id,l_ovn,l_owner;
	      if(csr_sel_bal_category_mid%found) then
	      --need to perform a date-track update
	         if(p_OWNER='SEED') then
               	   hr_general2.init_fndload(800,1);
	         else
               	   hr_general2.init_fndload(800,-1);
	         end if;
	         update  pay_balance_categories_f
		 set
		 effective_end_date = to_date(p_EFFECTIVE_END_DATE,'YYYY/MM/DD')
		,save_run_balance_enabled       = p_SAVE_RUN_BALANCE_ENABLED
                ,user_category_name             = p_user_category_name
		,pbc_information_category       = p_PBC_INFORMATION_CATEGORY
		,pbc_information1               = p_pbc_information1
		,pbc_information2               = p_pbc_information2
		,pbc_information3               = p_pbc_information3
		,pbc_information4               = p_pbc_information4
		,pbc_information5               = p_pbc_information5
		,pbc_information6               = p_pbc_information6
		,pbc_information7               = p_pbc_information7
    	      	,pbc_information8               = p_pbc_information8
		,pbc_information9               = p_pbc_information9
		,pbc_information10              = p_pbc_information10
		,pbc_information11              = p_pbc_information11
		,pbc_information12              = p_pbc_information12
		,pbc_information13              = p_pbc_information13
		,pbc_information14              = p_pbc_information14
		,pbc_information15              = p_pbc_information15
		,pbc_information16              = p_pbc_information16
		,pbc_information17              = p_pbc_information17
		,pbc_information18              = p_pbc_information18
		,pbc_information19              = p_pbc_information19
		,pbc_information20              = p_pbc_information20
		,pbc_information21              = p_pbc_information21
		,pbc_information22              = p_pbc_information22
		,pbc_information23              = p_pbc_information23
		,pbc_information24              = p_pbc_information24
		,pbc_information25              = p_pbc_information25
		,pbc_information26              = p_pbc_information26
		,pbc_information27              = p_pbc_information27
		,pbc_information28              = p_pbc_information28
		,pbc_information29              = p_pbc_information29
		,pbc_information30              = p_pbc_information30
		,object_version_number          = l_ovn
		where   balance_category_id = l_balance_category_id;
	      else
	      --need to insert the new date-track row.
	         if(p_OWNER='SEED') then
               	   hr_general2.init_fndload(800,1);
	         else
               	   hr_general2.init_fndload(800,-1);
	         end if;
	         insert into
	         pay_balance_categories_f(balance_category_id,category_name,
     	         effective_start_date,effective_end_date,legislation_code,
	         business_group_id,save_run_balance_enabled,user_category_name,
	         pbc_information_category,pbc_information1,pbc_information2,
		 pbc_information3,pbc_information4,pbc_information5,
		 pbc_information6,pbc_information7,pbc_information8,
	         pbc_information9,pbc_information10,pbc_information11,
	         pbc_information12,pbc_information13,pbc_information14,
	         pbc_information15,pbc_information16,pbc_information17,
	         pbc_information18, pbc_information19,pbc_information20,
	         pbc_information21,pbc_information22,pbc_information23,
	         pbc_information24,pbc_information25,pbc_information26 ,
	         pbc_information27,pbc_information28,pbc_information29,
	         pbc_information30,object_version_number)
	         Values
	         (l_balance_category_id,p_CATEGORY_NAME,
	          to_date(p_EFFECTIVE_START_DATE,'YYYY/MM/DD'),
	          to_date(p_EFFECTIVE_END_DATE,'YYYY/MM/DD'),
	          p_LEGISLATION_CODE,l_bus_grp_id,p_SAVE_RUN_BALANCE_ENABLED,
                  p_user_category_name,
	          p_PBC_INFORMATION_CATEGORY,p_PBC_INFORMATION1,
		  p_PBC_INFORMATION2,p_PBC_INFORMATION3,p_PBC_INFORMATION4,
		  p_PBC_INFORMATION5,p_PBC_INFORMATION6,p_PBC_INFORMATION7,
		  p_PBC_INFORMATION8,p_PBC_INFORMATION9,p_PBC_INFORMATION10,
		  p_PBC_INFORMATION11,p_PBC_INFORMATION12,p_PBC_INFORMATION13,
		  p_PBC_INFORMATION14,p_PBC_INFORMATION15,p_PBC_INFORMATION16,
		  p_PBC_INFORMATION17,p_PBC_INFORMATION18,p_PBC_INFORMATION19,
		  p_PBC_INFORMATION20,p_PBC_INFORMATION21,p_PBC_INFORMATION22,
		  p_PBC_INFORMATION23,p_PBC_INFORMATION24,p_PBC_INFORMATION25,
		  p_PBC_INFORMATION26,p_PBC_INFORMATION27,p_PBC_INFORMATION28,
		  p_PBC_INFORMATION29,p_PBC_INFORMATION30,to_number(p_OVN)
		 );
	       end if;
	       close csr_sel_bal_category_mid;
	    end if;
	else
	--row does not exist in the table. so insert the new row into the table
	    if(p_OWNER='SEED') then
               	   hr_general2.init_fndload(800,1);
	    else
               	   hr_general2.init_fndload(800,-1);
	    end if;

	    insert into
	    pay_balance_categories_f(balance_category_id,category_name,
	    effective_start_date,effective_end_date,legislation_code,
	    business_group_id,save_run_balance_enabled,user_category_name,
            pbc_information_category,
	    pbc_information1,pbc_information2,pbc_information3,pbc_information4,
            pbc_information5,pbc_information6,pbc_information7,pbc_information8,
	    pbc_information9,pbc_information10,pbc_information11,
	    pbc_information12,pbc_information13,pbc_information14,
	    pbc_information15,pbc_information16,pbc_information17,
	    pbc_information18, pbc_information19,pbc_information20,
	    pbc_information21,pbc_information22,pbc_information23,
	    pbc_information24,pbc_information25,pbc_information26 ,
	    pbc_information27,pbc_information28,pbc_information29,
	    pbc_information30,object_version_number)
	    Values
	    (pay_balance_categories_s.nextval,p_CATEGORY_NAME,
	     to_date(p_EFFECTIVE_START_DATE,'YYYY/MM/DD'),
	     to_date(p_EFFECTIVE_END_DATE,'YYYY/MM/DD'),
	     p_LEGISLATION_CODE,l_bus_grp_id,p_SAVE_RUN_BALANCE_ENABLED,
             p_user_category_name,
	     p_PBC_INFORMATION_CATEGORY,p_PBC_INFORMATION1,p_PBC_INFORMATION2,
	     p_PBC_INFORMATION3,p_PBC_INFORMATION4,p_PBC_INFORMATION5,
	     p_PBC_INFORMATION6,p_PBC_INFORMATION7,p_PBC_INFORMATION8,
	     p_PBC_INFORMATION9,p_PBC_INFORMATION10,p_PBC_INFORMATION11,
	     p_PBC_INFORMATION12,p_PBC_INFORMATION13,p_PBC_INFORMATION14,
	     p_PBC_INFORMATION15,p_PBC_INFORMATION16,p_PBC_INFORMATION17,
	     p_PBC_INFORMATION18,p_PBC_INFORMATION19,p_PBC_INFORMATION20,
	     p_PBC_INFORMATION21,p_PBC_INFORMATION22,p_PBC_INFORMATION23,
	     p_PBC_INFORMATION24,p_PBC_INFORMATION25,p_PBC_INFORMATION26,
	     p_PBC_INFORMATION27,p_PBC_INFORMATION28,p_PBC_INFORMATION29,
	     p_PBC_INFORMATION30,to_number(p_OVN)
	    );
	end if;
	close csr_sel_bal_category_few;

END PAY_BAL_CATF_LOAD_ROW;

--This procedure is used for uploading data into table PAY_BALANCE_TYPES
--This is called from pybalcat.lct configuration file
PROCEDURE PAY_BAL_TYPES_LOAD_ROW
	(p_CATEGORY_NAME			IN VARCHAR2
	,p_EFFECTIVE_START_DATE			IN VARCHAR2
	,p_EFFECTIVE_END_DATE			IN VARCHAR2
	,p_LEGISLATION_CODE			IN VARCHAR2
	,p_BALANCE_NAME				IN VARCHAR2
	,p_BUSINESS_GROUP_NAME			IN VARCHAR2
	,p_OWNER                   		IN VARCHAR2	--added
	) IS

l_balance_type_id 	 PAY_BALANCE_TYPES.BALANCE_TYPE_ID%TYPE;
l_balance_name 		 PAY_BALANCE_TYPES.BALANCE_NAME%TYPE;
l_legislation_code	 PAY_BALANCE_TYPES.LEGISLATION_CODE%TYPE;
l_business_group_id	 PAY_BALANCE_TYPES.BUSINESS_GROUP_ID%TYPE;
l_ovn			 PAY_BALANCE_TYPES.object_version_number%TYPE;
l_owner			 VARCHAR2(6);
l_balance_category_id	 PAY_BALANCE_CATEGORIES_F.BALANCE_CATEGORY_ID%TYPE;

--This cursor is used to select the balance type id
cursor csr_sel_bal_type_id(p_BALANCE_NAME	VARCHAR2,
			   p_LEGISLATION_CODE   VARCHAR2,
   			   p_bg_id		NUMBER) is--added
SELECT balance_type_id
FROM   PAY_BALANCE_TYPES
WHERE  balance_name =p_BALANCE_NAME
AND nvl(legislation_code,1) =nvl(p_LEGISLATION_CODE,1)
and (business_group_id =p_bg_id or business_group_id is null);--added

--This cursor is used to select the balance category id
cursor csr_sel_bal_cat_id(p_CATEGORY_NAME	VARCHAR2,
			  p_ESD			VARCHAR2,
			  p_EED			VARCHAR2,
			  p_LEGISLATION_CODE    VARCHAR2,    --Bug 5044079
   			  p_bg_id		NUMBER) is   --Bug 5044079
select balance_category_id
from pay_balance_categories_f
where category_name =p_CATEGORY_NAME
and effective_start_date =to_date(p_ESD,'YYYY/MM/DD')
and effective_end_date =to_date(p_EED,'YYYY/MM/DD')
AND nvl(legislation_code,1) =nvl(p_LEGISLATION_CODE,1)  --Bug 5044079
and (business_group_id =p_bg_id or business_group_id is null);  --Bug 5044079

BEGIN

	open csr_bg_id(p_BUSINESS_GROUP_NAME);
	fetch csr_bg_id into l_business_group_id;
	close csr_bg_id;

	open csr_sel_bal_type_id(p_BALANCE_NAME,p_LEGISLATION_CODE,
				 l_business_group_id);
	fetch csr_sel_bal_type_id into l_balance_type_id;

	if (csr_sel_bal_type_id%found) then
		open csr_sel_bal_cat_id(p_CATEGORY_NAME,p_EFFECTIVE_START_DATE,
                                      p_EFFECTIVE_END_DATE,p_LEGISLATION_CODE,
				      l_business_group_id);
		fetch csr_sel_bal_cat_id into l_balance_category_id;
		if(csr_sel_bal_cat_id%found) then

			if(p_OWNER='SEED') then
               		   hr_general2.init_fndload(800,1);
		        else
               		   hr_general2.init_fndload(800,-1);
		        end if;

			update pay_balance_types
			set balance_category_id =l_balance_category_id
			where balance_type_id=l_balance_type_id;
		end if;
		close csr_sel_bal_cat_id;
	end if;
	close csr_sel_bal_type_id;

END PAY_BAL_TYPES_LOAD_ROW;

--This procedure is used for uploading data into PAY_BAL_ATTRIBUTE_DEFINITIONS
--This is called from pybalade.lct configuration file
PROCEDURE PAY_BAL_ADE_LOAD_ROW
	  (p_ATTRIBUTE_NAME		IN VARCHAR2
	  ,p_LEGISLATION_CODE		IN VARCHAR2
	  ,p_BUSINESS_GROUP_NAME 	IN VARCHAR2
	  ,p_ALTERABLE			IN VARCHAR2
          ,p_user_attribute_name        IN VARCHAR2
	  ,p_OWNER			IN VARCHAR2
	  ) IS

l_attribute_id 		PAY_BAL_ATTRIBUTE_DEFINITIONS.ATTRIBUTE_ID%TYPE;
l_attribute_name	PAY_BAL_ATTRIBUTE_DEFINITIONS.ATTRIBUTE_NAME%TYPE;
l_legislation_code	PAY_BAL_ATTRIBUTE_DEFINITIONS.LEGISLATION_CODE%TYPE;
l_business_group_id	PAY_BAL_ATTRIBUTE_DEFINITIONS.BUSINESS_GROUP_ID%TYPE;
l_alterable		PAY_BAL_ATTRIBUTE_DEFINITIONS.ALTERABLE%TYPE;
l_owner			VARCHAR2(6);
l_temp_attribute_id	PAY_BAL_ATTRIBUTE_DEFINITIONS.ATTRIBUTE_ID%TYPE;
l_session_id		HR_OWNER_DEFINITIONS.SESSION_ID%TYPE;
l_session_id1		HR_OWNER_DEFINITIONS.SESSION_ID%TYPE;

--cursors to check if child rows exist
cursor csr_pba_id(p_attrib_id PAY_BAL_ATTRIBUTE_DEFINITIONS.ATTRIBUTE_ID%TYPE)
is
select attribute_id
from pay_balance_attributes
where attribute_id=p_attrib_id;

cursor csr_pbad_id(p_attrib_id PAY_BAL_ATTRIBUTE_DEFINITIONS.ATTRIBUTE_ID%TYPE)
is
select attribute_id
from pay_bal_attribute_defaults
where attribute_id=p_attrib_id;

--This cursor is used to select the attribute id
cursor csr_sel_attrib_id(p_ATTRIBUTE_NAME	VARCHAR2,
			 p_LEGISLATION_CODE	VARCHAR2,
                         p_bg_id		NUMBER) is
SELECT attribute_id,
       attribute_name,
       alterable,
       legislation_code,
       DECODE( NVL(last_updated_by,-1), 1, 'SEED', 'CUSTOM')
FROM   PAY_BAL_ATTRIBUTE_DEFINITIONS
WHERE  attribute_name = p_ATTRIBUTE_NAME
AND nvl(legislation_code,1) =nvl(p_LEGISLATION_CODE,1)
AND    (business_group_id=p_bg_id OR business_group_id is NULL);

BEGIN
	   open csr_get_session_id;
	   fetch csr_get_session_id into l_session_id;
	   close csr_get_session_id;

	   open csr_get_hr_sess_id(l_session_id);
	   fetch csr_get_hr_sess_id into l_session_id1;
	   if(csr_get_hr_sess_id%notfound) then
    	      hr_startup_data_api_support.create_owner_definition('PAY');
    	   end if;
    	   close csr_get_hr_sess_id;

	--set user mode based on value of OWNER
	if (p_OWNER ='SEED') then

	   if(p_BUSINESS_GROUP_NAME is null AND p_LEGISLATION_CODE is null)then
              hr_startup_data_api_support.enable_startup_mode('GENERIC');

           else
    	      hr_startup_data_api_support.enable_startup_mode('STARTUP');
           end if ;
    	   --Need to set the AOL WHO columns properly. Hence call this
       	   hr_general2.init_fndload(800,1);

	elsif (p_OWNER='CUSTOM') then

	   if(p_BUSINESS_GROUP_NAME is null AND p_LEGISLATION_CODE is null)then

              hr_startup_data_api_support.enable_startup_mode('GENERIC');

	   elsif(p_BUSINESS_GROUP_NAME is not null
	         AND p_LEGISLATION_CODE is null) then

	      hr_startup_data_api_support.enable_startup_mode('USER');

	   end if;
	   --Need to set the AOL WHO columns properly. Hence call this
       	   hr_general2.init_fndload(800,-1);
	end if;--Close end if for OWNER

	open csr_bg_id(p_BUSINESS_GROUP_NAME);
	fetch csr_bg_id into l_business_group_id;
	close csr_bg_id;

	open csr_sel_attrib_id(p_ATTRIBUTE_NAME,
                               p_LEGISLATION_CODE,l_business_group_id);
	fetch csr_sel_attrib_id into
        l_attribute_id,l_attribute_name,l_alterable,l_legislation_code,l_owner;

	--value in the ldt is already present at the customer site
	if(csr_sel_attrib_id%found) then
	   close csr_sel_attrib_id;
	   --ALTERABLE flag needs to be updated
	   if(l_alterable <> p_ALTERABLE) then
	      if((l_business_group_id is null and l_legislation_code is not
	          null) AND (l_ALTERABLE ='Y' and p_ALTERABLE='N')) then
	         --its a startup definition
 	         --updating from Y to N ...so check if child rows exist
	         open csr_pba_id(l_attribute_id);
	         fetch csr_pba_id into l_temp_attribute_id;
	         close csr_pba_id;

	         if (l_temp_attribute_id is not NULL)then
	         --raise error ask to rerun the ldts after deleting the child
		 --rows
	            fnd_message.set_name('PAY', 'HR_7215_DT_CHILD_EXISTS');
	  	    fnd_message.set_token('TABLE_NAME',
			                  'PAY_BAL_ATTRIBUTE_DEFINITIONS');
		    fnd_message.raise_error;
	         end if;

	         open csr_pbad_id(l_attribute_id);
	         fetch csr_pbad_id into l_temp_attribute_id;
	         close csr_pbad_id;

	         if(l_temp_attribute_id is not NULL)then
	         --raise error ask to rerun the ldts after deleting the child
		 --rows
	            fnd_message.set_name('PAY', 'HR_7215_DT_CHILD_EXISTS');
   	            fnd_message.set_token('TABLE_NAME',
				          'PAY_BAL_ATTRIBUTE_DEFINITIONS');
	            fnd_message.raise_error;
	         end if;

	         update PAY_BAL_ATTRIBUTE_DEFINITIONS
	         set ALTERABLE =p_ALTERABLE
	         where attribute_id=l_attribute_id;

	      elsif((l_business_group_id is null and l_legislation_code is not
                  null) AND (l_ALTERABLE ='N' and p_ALTERABLE='Y')) then
	      --updating from N to Y...since child rows dont exist can do direct
	      --update

	         update PAY_BAL_ATTRIBUTE_DEFINITIONS
	         set ALTERABLE =p_ALTERABLE
	         where attribute_id=l_attribute_id;

	      end if;
	   end if;
	else
	   PAY_BAL_ATTRIB_DEFINITION_API.create_bal_attrib_definition
	   (p_effective_date      =>sysdate
	   ,p_attribute_name      => p_ATTRIBUTE_NAME
	   ,p_business_group_id   =>l_business_group_id
	   ,p_legislation_code    =>p_LEGISLATION_CODE
	   ,p_alterable           => p_ALTERABLE
           ,p_user_attribute_name => p_user_attribute_name
	   ,p_attribute_id        => l_attribute_id
	   );
	   close csr_sel_attrib_id;
	end if;

END PAY_BAL_ADE_LOAD_ROW;


--This procedure is used for loading data into table PAY_BALANCE_ATTRIBUTES
--This procedure is called from pybalatt.lct configuration file
PROCEDURE PAY_BAL_ATT_LOAD_ROW
	 (p_ATTRIBUTE_NAME		IN VARCHAR2
	 ,p_ATTR_DEFN_LEG_CODE		IN VARCHAR2
	 ,p_LEGISLATION_CODE		IN VARCHAR2
	 ,p_BALANCE_NAME		IN VARCHAR2
	 ,p_BAL_LEG_CODE		IN VARCHAR2
	 ,p_DIMENSION_NAME		IN VARCHAR2
	 ,p_DIM_LEG_CODE		IN VARCHAR2
	 ,p_BUSINESS_GROUP_NAME		IN VARCHAR2
	 ,p_ATTR_DEFN_BUS_GROUP_NAME    IN VARCHAR2
	 ,p_BAL_BUS_GROUP_NAME		IN VARCHAR2
	 ,p_DIM_BUS_GROUP_NAME		IN VARCHAR2
	 ,p_OWNER			IN VARCHAR2
	 )IS

l_balance_attribute_id 	PAY_BALANCE_ATTRIBUTES.BALANCE_ATTRIBUTE_ID%TYPE;
l_business_group_id	PER_BUSINESS_GROUPS.BUSINESS_GROUP_ID%TYPE;
l_bal_business_group_id	PER_BUSINESS_GROUPS.BUSINESS_GROUP_ID%TYPE;
l_attr_business_group_id	PER_BUSINESS_GROUPS.BUSINESS_GROUP_ID%TYPE;
l_attribute_id 		PAY_BALANCE_ATTRIBUTES.ATTRIBUTE_ID%TYPE;
l_balance_type_id	PAY_BALANCE_TYPES.BALANCE_TYPE_ID%TYPE;
l_balance_dimension_id	PAY_BALANCE_DIMENSIONS.BALANCE_DIMENSION_ID%TYPE;
l_defined_balance_id 	PAY_DEFINED_BALANCES.DEFINED_BALANCE_ID%TYPE;
l_legislation_code 	PAY_BALANCE_ATTRIBUTES.LEGISLATION_CODE%TYPE;
l_def_bal_leg_code	PAY_DEFINED_BALANCES.LEGISLATION_CODE%TYPE;
l_def_bal_bg_id		PAY_DEFINED_BALANCES.BUSINESS_GROUP_ID%TYPE;
l_owner			VARCHAR2(6);
l_session_id		HR_OWNER_DEFINITIONS.SESSION_ID%TYPE;
l_session_id1		HR_OWNER_DEFINITIONS.SESSION_ID%TYPE;

--This cursor is used to select the attribute id
cursor csr_sel_attrib_id(p_ATTRIBUTE_NAME	VARCHAR2,
			 p_LEGISLATION_CODE	VARCHAR2,
			 p_bg_id		NUMBER) is
select attribute_id
from pay_bal_attribute_definitions
where  attribute_name = p_ATTRIBUTE_NAME
AND nvl(legislation_code,1) =nvl(p_LEGISLATION_CODE,1)
and (business_group_id =p_bg_id or business_group_id is null);

--This cursor is used to select the defined balance id
cursor csr_sel_def_bal_id(p_balance_type_id      NUMBER,
		          p_balance_dimension_id NUMBER,
			  p_LEGISLATION_CODE     VARCHAR2,
			  p_bg_id		 NUMBER)is
select defined_balance_id
from pay_defined_balances
where balance_type_id =p_balance_type_id
and balance_dimension_id =p_balance_dimension_id
AND nvl(legislation_code,1) =nvl(p_LEGISLATION_CODE,1)
and (business_group_id =p_bg_id or business_group_id is null);

--This cursor is used to select the balance type id
cursor csr_sel_bal_type_id(p_BALANCE_NAME	VARCHAR2,
			   p_LEGISLATION_CODE	VARCHAR2,
			   p_bg_id		NUMBER) is
select balance_type_id
from pay_balance_types
where balance_name =p_BALANCE_NAME
AND nvl(legislation_code,1) =nvl(p_LEGISLATION_CODE,1)
and (business_group_id =p_bg_id or business_group_id is null);

--This cursor is used to select the balance dimension id
cursor csr_sel_bal_dim_id(p_DIMENSION_NAME	VARCHAR2,
			  p_LEGISLATION_CODE	VARCHAR2,
			  p_bg_id		NUMBER) is
select balance_dimension_id
from pay_balance_dimensions
where dimension_name =p_DIMENSION_NAME
AND nvl(legislation_code,1) =nvl(p_LEGISLATION_CODE,1)
and (business_group_id =p_bg_id or business_group_id is null);

BEGIN
	   open csr_get_session_id;
	   fetch csr_get_session_id into l_session_id;
    	   close csr_get_session_id;

	   open csr_get_hr_sess_id(l_session_id);
	   fetch csr_get_hr_sess_id into l_session_id1;
	   if(csr_get_hr_sess_id%notfound) then

       	      hr_startup_data_api_support.create_owner_definition('PAY');

 	   end if;
    	   close csr_get_hr_sess_id;

	--set user mode based on value of OWNER
	if (p_OWNER ='SEED') then

    	   hr_startup_data_api_support.enable_startup_mode('STARTUP');
    	   --Need to set the AOL WHO columns properly. Hence call this
       	   hr_general2.init_fndload(800,1);

	elsif (p_OWNER='CUSTOM') then

	   if(p_BUSINESS_GROUP_NAME is null AND p_LEGISLATION_CODE is null) then

	      hr_startup_data_api_support.enable_startup_mode('GENERIC');

	   elsif(p_BUSINESS_GROUP_NAME is not null
		 AND p_LEGISLATION_CODE is null) then

	      hr_startup_data_api_support.enable_startup_mode('USER');

	   end if;
	   --Need to set the AOL WHO columns properly. Hence call this
       	   hr_general2.init_fndload(800,-1);
	end if;

	open csr_bg_id(p_BUSINESS_GROUP_NAME);
	fetch csr_bg_id into l_business_group_id;
	close csr_bg_id;

	--Get the balance type id
	open csr_bg_id(p_BAL_BUS_GROUP_NAME);
	fetch csr_bg_id into l_bal_business_group_id;
	close csr_bg_id;

	open csr_sel_bal_type_id(p_BALANCE_NAME,
	                         p_BAL_LEG_CODE,l_bal_business_group_id);
	fetch csr_sel_bal_type_id into l_balance_type_id;
	if (csr_sel_bal_type_id %notfound) then
		null;
	end if;
	close csr_sel_bal_type_id;

	--Get the balance dimension id
	open csr_bg_id(p_DIM_BUS_GROUP_NAME);
	fetch csr_bg_id into l_bal_business_group_id;
	close csr_bg_id;

	open csr_sel_bal_dim_id(p_DIMENSION_NAME,p_DIM_LEG_CODE,
				l_bal_business_group_id);
	fetch csr_sel_bal_dim_id into l_balance_dimension_id;
	if (csr_sel_bal_dim_id%notfound) then
		null;
	end if;
	close csr_sel_bal_dim_id;

	--Get the defined balance id
	open csr_sel_def_bal_id(l_balance_type_id,l_balance_dimension_id,
		                p_BAL_LEG_CODE,l_bal_business_group_id);
	fetch csr_sel_def_bal_id into l_defined_balance_id;
	close csr_sel_def_bal_id;

	--Get the attribute id
	open csr_bg_id(p_ATTR_DEFN_BUS_GROUP_NAME);
	fetch csr_bg_id into l_attr_business_group_id;
	close csr_bg_id;

	open csr_sel_attrib_id(p_ATTRIBUTE_NAME,
	                               p_ATTR_DEFN_LEG_CODE,
				       l_attr_business_group_id);
	fetch csr_sel_attrib_id into l_attribute_id;
	close csr_sel_attrib_id;

	BEGIN

	SELECT balance_attribute_id,
	       attribute_id,
	       defined_balance_id,
	       legislation_code,
	       DECODE( NVL(last_updated_by,-1), 1, 'SEED', 'CUSTOM')
	INTO   l_balance_attribute_id,
	       l_attribute_id,
	       l_defined_balance_id,
	       l_legislation_code,
	       l_owner
	FROM   PAY_BALANCE_ATTRIBUTES
	WHERE  attribute_id = l_attribute_id
	AND    defined_balance_id = l_defined_balance_id
	AND    (business_group_id =l_business_group_id
		OR business_group_id is null);

	EXCEPTION WHEN NO_DATA_FOUND
	THEN

		open csr_sel_attrib_id(p_ATTRIBUTE_NAME,
	                               p_ATTR_DEFN_LEG_CODE,
				       l_attr_business_group_id);
		fetch csr_sel_attrib_id into l_attribute_id;

		if (csr_sel_attrib_id%found) then
		   open
		   csr_sel_def_bal_id(l_balance_type_id,l_balance_dimension_id,
		                      p_BAL_LEG_CODE,l_bal_business_group_id);
		   fetch csr_sel_def_bal_id into l_defined_balance_id;

		   if (csr_sel_def_bal_id%found) then

		      PAY_BALANCE_ATTRIBUTE_API.CREATE_BALANCE_ATTRIBUTE
		      (p_attribute_id =>l_attribute_id
		      ,p_defined_balance_id =>l_defined_balance_id
		      ,p_business_group_id =>l_business_group_id
		      ,p_legislation_code => p_LEGISLATION_CODE
		      ,p_balance_attribute_id =>l_balance_attribute_id
		      );

		   end if;
		   close csr_sel_def_bal_id;
		end if;
		close csr_sel_attrib_id;

	END;

END PAY_BAL_ATT_LOAD_ROW;

--This procedure is used for loading data into table PAY_BAL_ATTRIBUTE_DEFAULTS
--This procedure is called from pybaladf.lct configuration file
PROCEDURE PAY_BAL_ADF_LOAD_ROW
	 (p_CATEGORY_NAME		IN VARCHAR2
	 ,p_EFFECTIVE_START_DATE	IN VARCHAR2
	 ,p_EFFECTIVE_END_DATE		IN VARCHAR2
	 ,p_CAT_LEG_CODE		IN VARCHAR2
	 ,p_LEGISLATION_CODE		IN VARCHAR2
	 ,p_DIMENSION_NAME		IN VARCHAR2
	 ,p_DIM_LEG_CODE		IN VARCHAR2
	 ,p_ATTRIBUTE_NAME		IN VARCHAR2
	 ,p_ATTR_LEG_CODE		IN VARCHAR2
	 ,p_BUSINESS_GROUP_NAME		IN VARCHAR2
	 ,p_CAT_BUS_GROUP_NAME		IN VARCHAR2
	 ,p_DIM_BUS_GROUP_NAME		IN VARCHAR2
	 ,p_ATTR_BUS_GROUP_NAME		IN VARCHAR2
	 ,p_OWNER			IN VARCHAR2
	 )IS

l_bal_attribute_default_id
PAY_BAL_ATTRIBUTE_DEFAULTS.BAL_ATTRIBUTE_DEFAULT_ID%TYPE;
l_balance_category_id PAY_BALANCE_CATEGORIES_F.BALANCE_CATEGORY_ID%TYPE;
l_legislation_code	PAY_BAL_ATTRIBUTE_DEFAULTS.LEGISLATION_CODE%TYPE;
l_attribute_id	 	PAY_BAL_ATTRIBUTE_DEFINITIONS.ATTRIBUTE_ID%TYPE;
l_balance_dimension_id	PAY_BALANCE_DIMENSIONS.BALANCE_DIMENSION_ID%TYPE;
l_business_group_id	PER_BUSINESS_GROUPS.BUSINESS_GROUP_ID%TYPE;
l_attr_bus_group_id	PER_BUSINESS_GROUPS.BUSINESS_GROUP_ID%TYPE;
l_cat_bus_group_id	PER_BUSINESS_GROUPS.BUSINESS_GROUP_ID%TYPE;
l_dim_bus_group_id	PER_BUSINESS_GROUPS.BUSINESS_GROUP_ID%TYPE;
l_owner			VARCHAR2(6);
l_session_id		HR_OWNER_DEFINITIONS.SESSION_ID%TYPE;
l_session_id1		HR_OWNER_DEFINITIONS.SESSION_ID%TYPE;

--This cursor is used to select the balance dimension id
cursor csr_sel_bal_dim_id(p_DIMENSION_NAME	VARCHAR2,
			  p_LEGISLATION_CODE	VARCHAR2,
			  p_bg_id		NUMBER) is
select balance_dimension_id
from pay_balance_dimensions
where dimension_name=p_DIMENSION_NAME
AND nvl(legislation_code,1) =nvl(p_LEGISLATION_CODE,1)
and (business_group_id =p_bg_id or business_group_id is null);

--This cursor is used to determine the attribute_id
cursor csr_sel_attrib_id(p_ATTRIBUTE_NAME	VARCHAR2,
			 p_LEGISLATION_CODE	VARCHAR2,
			 p_bg_id		NUMBER) is
select attribute_id
from pay_bal_attribute_definitions
where attribute_name =p_ATTRIBUTE_NAME
AND nvl(legislation_code,1) =nvl(p_LEGISLATION_CODE,1)
and (business_group_id =p_bg_id or business_group_id is null);

--This cursor is used to determine the balance_category_id
cursor csr_sel_bal_cat_id(p_CATEGORY_NAME	VARCHAR2,
			  p_ESD			VARCHAR2,
			  p_EED			VARCHAR2,
			  p_LEGISLATION_CODE	VARCHAR2) is
select balance_category_id
from pay_balance_categories_f
where category_name =p_CATEGORY_NAME
and effective_start_date =to_date(p_ESD,'YYYY/MM/DD')
and effective_end_date =to_date(p_EED,'YYYY/MM/DD')
AND nvl(legislation_code,1) =nvl(p_LEGISLATION_CODE,1);

BEGIN

	   open csr_get_session_id;
	   fetch csr_get_session_id into l_session_id;
	   close csr_get_session_id;

	   open csr_get_hr_sess_id(l_session_id);
	   fetch csr_get_hr_sess_id into l_session_id1;
	   if(csr_get_hr_sess_id%notfound) then

    	      hr_startup_data_api_support.create_owner_definition('PAY');
    	   end if;
    	   close csr_get_hr_sess_id;

	--set user mode based on value of OWNER
        if (p_OWNER ='SEED') then

    	   hr_startup_data_api_support.enable_startup_mode('STARTUP');
	   --Need to set the AOL WHO columns properly. Hence call this
       	   hr_general2.init_fndload(800,1);

	elsif (p_OWNER='CUSTOM') then

	   if(p_BUSINESS_GROUP_NAME is null AND p_LEGISLATION_CODE is null) then
		   hr_startup_data_api_support.enable_startup_mode('GENERIC');

	   elsif(p_BUSINESS_GROUP_NAME is not null
	          AND p_LEGISLATION_CODE is null) then

	      hr_startup_data_api_support.enable_startup_mode('USER');

	   end if;
	   --Need to set the AOL WHO columns properly. Hence call this
       	   hr_general2.init_fndload(800,-1);
	end if;

	open csr_bg_id(p_BUSINESS_GROUP_NAME);
	fetch csr_bg_id into l_business_group_id;
	close csr_bg_id;

	--Get the balance category id
	open csr_bg_id(p_CAT_BUS_GROUP_NAME);
	fetch csr_bg_id into l_cat_bus_group_id;
	close csr_bg_id;

	open csr_sel_bal_cat_id(p_CATEGORY_NAME,p_EFFECTIVE_START_DATE,
	                           p_EFFECTIVE_END_DATE,p_CAT_LEG_CODE);
        fetch csr_sel_bal_cat_id into l_balance_category_id;
	close csr_sel_bal_cat_id;

	--Get the balance dimension id
	open csr_bg_id(p_DIM_BUS_GROUP_NAME);
	fetch csr_bg_id into l_dim_bus_group_id;
	close csr_bg_id;

	open csr_sel_bal_dim_id(p_DIMENSION_NAME,
	   	                p_DIM_LEG_CODE,l_dim_bus_group_id);
	fetch csr_sel_bal_dim_id into l_balance_dimension_id;
	close csr_sel_bal_dim_id;

	--Get the attribute id
	open csr_bg_id(p_ATTR_BUS_GROUP_NAME);
	fetch csr_bg_id into l_attr_bus_group_id;
	close csr_bg_id;

	open csr_sel_attrib_id(p_ATTRIBUTE_NAME,
	                             p_ATTR_LEG_CODE,l_attr_bus_group_id);
        fetch csr_sel_attrib_id into l_attribute_id;
	close csr_sel_attrib_id;

	BEGIN

	SELECT bal_attribute_default_id,
	       balance_category_id,
	       balance_dimension_id,
	       attribute_id,
	       legislation_code,
	       DECODE( NVL(last_updated_by,-1), 1, 'SEED', 'CUSTOM')
	INTO   l_bal_attribute_default_id,
	       l_balance_category_id,
	       l_balance_dimension_id,
	       l_attribute_id,
	       l_legislation_code,
	       l_owner
       	FROM   PAY_BAL_ATTRIBUTE_DEFAULTS
	WHERE  balance_category_id = l_balance_category_id
        AND    attribute_id = l_attribute_id
	AND    balance_dimension_id =l_balance_dimension_id;


	EXCEPTION WHEN NO_DATA_FOUND
	THEN

	open csr_sel_bal_dim_id(p_DIMENSION_NAME,
	   	                p_DIM_LEG_CODE,l_dim_bus_group_id);
	fetch csr_sel_bal_dim_id into l_balance_dimension_id;

	if(csr_sel_bal_dim_id%found) then
	   open csr_sel_bal_cat_id(p_CATEGORY_NAME,p_EFFECTIVE_START_DATE,
	                           p_EFFECTIVE_END_DATE,p_CAT_LEG_CODE);
	   fetch csr_sel_bal_cat_id into l_balance_category_id;

	   if(csr_sel_bal_cat_id%found) then
	      open csr_sel_attrib_id(p_ATTRIBUTE_NAME,
	                             p_ATTR_LEG_CODE,l_attr_bus_group_id);
	      fetch csr_sel_attrib_id into l_attribute_id;

	      if(csr_sel_attrib_id%found) then

		 PAY_BAL_ATTRIBUTE_DEFAULT_API.create_bal_attribute_default
		 (p_balance_category_id =>l_balance_category_id
		 ,p_balance_dimension_id =>l_balance_dimension_id
 		 ,p_attribute_id => l_attribute_id
		 ,p_business_group_id =>l_business_group_id
		 ,p_legislation_code =>p_LEGISLATION_CODE
		 ,p_bal_attribute_default_id =>l_bal_attribute_default_id
		 );
	      end if;
	      close csr_sel_attrib_id;
	   end if;
	   close csr_sel_bal_cat_id;
	end if;
	close csr_sel_bal_dim_id;

	END;

END PAY_BAL_ADF_LOAD_ROW;
--
-- This procedure provides NLS support for pay_balance_categories_f
--
procedure translate_row_cat
(p_category_name      in varchar2
,p_user_category_name in varchar2
,p_legislation_code   in varchar2
,p_bg_name            in varchar2
,p_owner              in varchar2
)
is
--
cursor get_business_group_id
is
select business_group_id
from   per_business_groups
where  upper(name) = p_bg_name;
--
cursor get_bal_cat_id(p_bg_id number)
is
select balance_category_id
from   pay_balance_categories_f
where  category_name = p_category_name
and    nvl(business_group_id, -1) = nvl(p_bg_id, -1)
and    nvl(legislation_code, 'CORE') = nvl(p_legislation_code, 'CORE');
--
l_bg_id             number;
l_bal_cat_id        number;
--
BEGIN
if p_bg_name is not null then
  open  get_business_group_id;
  fetch get_business_group_id into l_bg_id;
  close get_business_group_id;
end if;
--
open  get_bal_cat_id(l_bg_id);
fetch get_bal_cat_id into l_bal_cat_id;
close get_bal_cat_id;
hr_utility.trace('bal cat id is: '||to_char(l_bal_cat_id));
--
-- now determine what the who columns will be
--
if p_owner = 'SEED' then
  hr_general2.init_fndload(800,1);
else
  hr_general2.init_fndload(800,-1);
end if;
--
  update pay_balance_categories_f
  set user_category_name = p_user_category_name
  where balance_category_id = l_bal_cat_id
  and   userenv('LANG') = (select language_code
                           from   fnd_languages
                           where  installed_flag = 'B');
  --
END translate_row_cat;
--
-- This procedure provides NLS support for pay_bal_attribute_definitions
--
procedure translate_row_attrib
(p_attribute_name      in varchar2
,p_user_attribute_name in varchar2
,p_legislation_code    in varchar2
,p_bg_name             in varchar2
,p_owner               in varchar2
)
is
--
cursor get_business_group_id
is
select business_group_id
from   per_business_groups
where  upper(name) = p_bg_name;
--
cursor get_att_def_id(p_bg_id number)
is
select attribute_id
from   pay_bal_attribute_definitions
where  attribute_name = p_attribute_name
and    nvl(business_group_id, -1) = nvl(p_bg_id, -1)
and    nvl(legislation_code, 'CORE') = nvl(p_legislation_code, 'CORE');
--
l_bg_id             number;
l_att_def_id        number;
--
BEGIN
if p_bg_name is not null then
  open  get_business_group_id;
  fetch get_business_group_id into l_bg_id;
  close get_business_group_id;
end if;
--
open  get_att_def_id(l_bg_id);
fetch get_att_def_id into l_att_def_id;
close get_att_def_id;
hr_utility.trace('att def id is: '||to_char(l_att_def_id));
--
-- now determine what the who columns will be
--
if p_owner = 'SEED' then
  hr_general2.init_fndload(800,1);
else
  hr_general2.init_fndload(800,-1);
end if;
--
  update pay_bal_attribute_definitions
  set user_attribute_name = p_user_attribute_name
  where attribute_id = l_att_def_id
  and   userenv('LANG') = (select language_code
                           from   fnd_languages
                           where  installed_flag = 'B');
  --
END translate_row_attrib;
--
END PAY_BALANCES_UPLOAD_PKG;

/

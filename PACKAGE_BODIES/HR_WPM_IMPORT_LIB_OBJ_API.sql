--------------------------------------------------------
--  DDL for Package Body HR_WPM_IMPORT_LIB_OBJ_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_WPM_IMPORT_LIB_OBJ_API" as
/* $Header: perioapi.pkb 120.8 2006/05/02 23:51:23 sturlapa noship $ */
--
-- Package Variables
--
g_package  varchar2(33) := 'HR_WPM_IMPORT_LIB_OBJ_API.';
g_debug    boolean      := hr_utility.debug_enabled;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< import_library_objective >-----------------------|
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--
--
-- Prerequisites:
--
--
-- In Parameters:
--   Name                           Reqd Type     Description
--
--
-- Post Success:
--
--
--   Name                           Type     Description
--
-- Post Failure:
--
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
procedure IMPORT_LIBRARY_OBJECTIVES
  (
   p_objective_name	           in	varchar2
  ,p_valid_from		           in	date	    	default null
  ,p_valid_to	                   in	date	    	default null
  ,p_target_date	           in	date	    	default null
  ,p_next_review_date	           in	date	    	default null
  ,p_group_code	         	   in	varchar2  	default null
  ,p_priority_code		   in	varchar2  	default null
  ,p_appraise_flag	           in	varchar2  	default 'Y'
  ,p_weighting_percent	           in	number          default null
  ,p_measurement_style_code	   in	varchar2        default 'N_M'
  ,p_measure_name	           in	varchar2        default null
  ,p_measure_comments		   in	varchar2	default null
  ,p_target_value                  in   number          default null
  ,p_uom_code			   in	varchar2	default null
  ,p_measure_type_code		   in	varchar2	default null
  ,p_eligibility_type_code	   in	varchar2        default 'N_P'
  ,p_eligibility_profile_code	   in	number          default null
  ,p_details			   in	varchar2	default null
  ,p_success_criteria		   in	varchar2	default null
  ,p_comments			   in	varchar2	default null
  ,p_attribute_category		   in	varchar2	default null
  ,p_attribute1			   in	varchar2	default null
  ,p_attribute2			   in	varchar2	default null
  ,p_attribute3			   in	varchar2	default null
  ,p_attribute4			   in	varchar2	default null
  ,p_attribute5			   in	varchar2	default null
  ,p_attribute6			   in	varchar2	default null
  ,p_attribute7			   in	varchar2	default null
  ,p_attribute8			   in	varchar2	default null
  ,p_attribute9			   in	varchar2	default null
  ,p_attribute10		   in	varchar2	default null
  ,p_attribute11		   in	varchar2	default null
  ,p_attribute12		   in	varchar2	default null
  ,p_attribute13		   in	varchar2	default null
  ,p_attribute14		   in	varchar2	default null
  ,p_attribute15		   in	varchar2	default null
  ,p_attribute16		   in	varchar2	default null
  ,p_attribute17		   in	varchar2	default null
  ,p_attribute18		   in	varchar2	default null
  ,p_attribute19	 	   in	varchar2	default null
  ,p_attribute20		   in	varchar2	default null
  ,p_attribute21		   in	varchar2	default null
  ,p_attribute22		   in	varchar2	default null
  ,p_attribute23		   in	varchar2	default null
  ,p_attribute24		   in	varchar2	default null
  ,p_attribute25		   in	varchar2	default null
  ,p_attribute26		   in	varchar2	default null
  ,p_attribute27		   in	varchar2	default null
  ,p_attribute28		   in	varchar2	default null
  ,p_attribute29		   in	varchar2	default null
  ,p_attribute30		   in	varchar2	default null
  ,p_return_message        out nocopy varchar2
  ) IS
  l_proc varchar2(50):= 'IMPORT_LIBRARY_OBJECTIVES';

  l_duplicate_name_warning boolean;
  l_weighting_over_100_warning boolean;
  l_weighting_appraisal_warning boolean;

  l_table_name varchar2(30):='PER_OBJECTIVES_LIBRARY';
  l_column_name varchar2(30):='OBJECTIVE_ID';

  l_validate boolean;
  l_effective_date date;
  l_objective_id number;
  l_elig_obj_id number;
  l_elig_obj_elig_prfl_id number;
  l_bg_id number;

  l_eligibility_type_code varchar2(10);
  l_measurement_style_code varchar2(10);
  l_appraise_flag varchar2(2);

  l_object_version_number number;
  l_start_date date;
  l_end_date date;

  p_return_status  varchar2(400);
  is_profile_exists varchar2(1);
  l_elig_prfl_bg_id number(30);

  cursor  bg_cur(cur_p_org_id number) is select BUSINESS_GROUP_ID into l_bg_id from hr_organization_units where ORGANIZATION_ID=cur_p_org_id;

  cursor csr_name(cur_p_eligy_prfl_id number,cur_p_effective_date date) is
    select 'Y',BUSINESS_GROUP_ID
    from   ben_eligy_prfl_f
    where  eligy_prfl_id = cur_p_eligy_prfl_id
    and    cur_p_effective_date <= nvl(effective_end_date,to_date('31-12-4712','DD-MM-YYYY'))
    and    cur_p_effective_date >= effective_start_date
    and    stat_cd='A' ;

  begin
    savepoint import_library_objective_api;

    l_effective_date:=trunc(sysdate);
    l_validate:=false;



    --setting the eligibility type code
    if(p_eligibility_type_code IS Null  Or nvl(length(trim(p_eligibility_type_code)),-1)=-1)then
            l_eligibility_type_code:='N_P';
    else
            l_eligibility_type_code:=TRIM(p_eligibility_type_code);
    end if;

    --setting the appraisal flag
    if(p_appraise_flag IS Null Or nvl(length(trim(p_appraise_flag)),-1)=-1)then
            l_appraise_flag:='N';
    else
            l_appraise_flag:=TRIM(p_appraise_flag);
    end if;

    --setting the mesurement style code
    if(p_measurement_style_code IS Null Or nvl(length(trim(p_measurement_style_code)),-1)=-1 )then
        l_measurement_style_code:='N_M';
    else
        l_measurement_style_code:=TRIM(p_measurement_style_code);
    end if;

    --checkining the mesurement style code
    if(l_measurement_style_code = 'N_M' And (
						nvl(length(trim(p_measure_name)),-1)<>-1 Or
						nvl(length(trim(p_target_value)),-1)<>-1 Or
						nvl(length(trim(p_uom_code)),-1)<>-1 Or
						nvl(length(trim(p_measure_type_code)),-1)<>-1 Or
						nvl(length(trim(p_measure_comments)),-1)<>-1 ))
    then
          fnd_message.set_name('PER', 'HR_51746_WPM_IMP_NO_MTYPE');
          fnd_message.raise_error;
    end if;

    if(l_measurement_style_code ='QUALIT_M') then

	 if nvl(length(trim(p_measure_name)),-1) = -1 then
    	   fnd_message.set_name('PER', 'HR_51744_WPM_IMP_QUAL_TYPE');
           fnd_message.raise_error;
    	 end if;

 	 if( nvl(length(trim(p_target_value)),-1) <> -1 Or
	     nvl(length(trim(p_uom_code)),-1) <> -1 Or
	     nvl(length(trim(p_measure_type_code)),-1) <> -1 ) then
    	   fnd_message.set_name('PER', 'HR_51747_WPM_IMP_INVAL_QUAL');
           fnd_message.raise_error;
    	 end if;

    end if;

   if(l_measurement_style_code ='QUANT_M') then
        if(nvl(length(trim(p_measure_name)),-1) = -1 Or nvl(length(trim(p_target_value)),-1) = -1  Or
	   nvl(length(trim(p_uom_code)),-1) = -1  Or nvl(length(trim(p_measure_type_code)),-1) = -1 ) then
       	   fnd_message.set_name('PER', 'HR_51745_WPM_IMP_QUAN_TYPE');
           fnd_message.raise_error;
       end if;
   end if;

   if(l_eligibility_type_code='N_P' And nvl(length(trim(p_eligibility_profile_code)),-1)<>-1 ) then
       fnd_message.set_name('PER', 'HR_51743_WPM_IMP_SEL_ELIG_TYPE');
       fnd_message.raise_error;
   end if;

   if(l_eligibility_type_code='EXIST_P' And nvl(length(trim(p_eligibility_profile_code)),-1)=-1) then
        fnd_message.set_name('PER', 'HR_51742_WPM_IMP_SEL_ELIG_NAME');
        fnd_message.raise_error;
   end if;



    hr_objective_library_api.create_library_objective
      (p_validate                     => l_validate
      ,p_effective_date               => l_effective_date
      ,p_objective_name               => p_objective_name
      ,p_valid_from                   => p_valid_from
      ,p_valid_to                     => p_valid_to
      ,p_target_date                  => p_target_date
      ,p_next_review_date             => p_next_review_date
      ,p_group_code                   => p_group_code
      ,p_priority_code                => p_priority_code
      ,p_appraise_flag                => l_appraise_flag
      ,p_weighting_percent            => p_weighting_percent
      ,p_measurement_style_code       => l_measurement_style_code
      ,p_measure_name                 => p_measure_name
      ,p_target_value                 => p_target_value
      ,p_uom_code                     => p_uom_code
      ,p_measure_type_code            => p_measure_type_code
      ,p_measure_comments             => p_measure_comments
      ,p_eligibility_type_code        => l_eligibility_type_code
      ,p_details                      => p_details
      ,p_success_criteria             => p_success_criteria
      ,p_comments                     => p_comments
      ,p_attribute_category           => p_attribute_category
      ,p_attribute1                   => p_attribute1
      ,p_attribute2                   => p_attribute2
      ,p_attribute3                   => p_attribute3
      ,p_attribute4                   => p_attribute4
      ,p_attribute5                   => p_attribute5
      ,p_attribute6                   => p_attribute6
      ,p_attribute7                   => p_attribute7
      ,p_attribute8                   => p_attribute8
      ,p_attribute9                   => p_attribute9
      ,p_attribute10                  => p_attribute10
      ,p_attribute11                  => p_attribute11
      ,p_attribute12                  => p_attribute12
      ,p_attribute13                  => p_attribute13
      ,p_attribute14                  => p_attribute14
      ,p_attribute15                  => p_attribute15
      ,p_attribute16                  => p_attribute16
      ,p_attribute17                  => p_attribute17
      ,p_attribute18                  => p_attribute18
      ,p_attribute19                  => p_attribute19
      ,p_attribute20                  => p_attribute20
      ,p_attribute21                  => p_attribute21
      ,p_attribute22                  => p_attribute22
      ,p_attribute23                  => p_attribute23
      ,p_attribute24                  => p_attribute24
      ,p_attribute25                  => p_attribute25
      ,p_attribute26                  => p_attribute26
      ,p_attribute27                  => p_attribute27
      ,p_attribute28                  => p_attribute28
      ,p_attribute29                  => p_attribute29
      ,p_attribute30                  => p_attribute30
      ,p_objective_id		      => l_objective_id
      ,p_object_version_number	      => l_object_version_number
      ,p_duplicate_name_warning       => l_duplicate_name_warning
      ,p_weighting_over_100_warning   => l_weighting_over_100_warning
      ,p_weighting_appraisal_warning  => l_weighting_appraisal_warning
      );
    --
    -- Convert API warning boolean parameter values to specific
    -- messages and add them to Multiple Message List
    --

    if l_weighting_over_100_warning then
      -- fnd_message.set_name('PER', 'HR_50198_WPM_WEIGHT_WARN');
        null;
    end if;

    if l_weighting_appraisal_warning then
       --fnd_message.set_name('PER', 'HR_50223_WPM_APPRAISE_WARN');
         null;
    end if;

   if(l_eligibility_type_code='EXIST_P') then

          -- it will fetch based on security group and security groups
          -- also enabled
       	  l_bg_id :=hr_general.get_business_group_id;
          -- we are ensuring that no way we are not getting
          -- the business group id of the person so
          -- try to initializaint the HRsecurity so that
          -- it will fetch the bgid of the person
          --if(l_bg_id is null) then
             -- HR_Signon.Initialize_HR_Security;
             -- l_bg_id :=hr_general.get_business_group_id;
         -- end if;

          if(l_bg_id is null) then
             open bg_cur(fnd_global.org_id);
                 fetch bg_cur into l_bg_id;
             close bg_cur;
          end if;

          --checking for eligibility profile name existance.
          if(p_eligibility_profile_code is not null) then
             open csr_name(p_eligibility_profile_code,l_effective_date);
               fetch csr_name into is_profile_exists,l_elig_prfl_bg_id;
               if(csr_name%NOTFOUND)then
                    close csr_name;
                    fnd_message.set_name('PER', 'HR_51794_WPM_STALE_DATA');
                    fnd_message.raise_error;
               end if;
               close csr_name;
          end if;

    	  hr_objective_library_api.create_eligy_object
          (
	       	   p_elig_obj_id                    => l_elig_obj_id
    		  ,p_business_group_id              => l_bg_id
	       	  ,p_table_name                     => l_table_name
    		  ,p_column_name                    => l_column_name
	          ,p_column_value                   => l_objective_id
	       	  ,p_effective_date                 => l_effective_date
      		  ,p_effective_start_date           => l_start_date
 	          ,p_effective_end_date             => l_end_date
 	      	  ,p_object_version_number          => l_object_version_number
    	  );


  	  hr_objective_library_api.create_elig_obj_elig_prfl
          (
		    p_business_group_id              => l_elig_prfl_bg_id
		   ,p_elig_obj_id                    => l_elig_obj_id
		   ,p_elig_prfl_id                   => p_eligibility_profile_code
		   ,p_effective_date                 => l_effective_date
   		   ,p_effective_start_date           => l_start_date
 		   ,p_effective_end_date             => l_end_date
 		   ,p_object_version_number          => l_object_version_number
		   ,p_elig_obj_elig_prfl_id          => l_elig_obj_elig_prfl_id
          );
    end if;
    commit;
    -- Convert API non-warning boolean parameter values
    --
    --
    -- Derive the API return status value based on whether
    -- messages of any type exist in the Multiple Message List.
    -- Also disable Multiple Message Detection.
    --
    hr_utility.set_location(' Leaving:' || l_proc,20);
    --
  exception


   when others then
      --
      -- When Multiple Message Detection is enabled catch
      -- any Application specific or other unexpected
      -- exceptions.  Adding appropriate details to the
      -- Multiple Message List.  Otherwise re-raise the
      -- error.
      --
      rollback to import_library_objective_api;
      fnd_message.raise_error;
      hr_utility.set_location(' Leaving:' || l_proc,50);

end import_library_objectives;

end HR_WPM_IMPORT_LIB_OBJ_API;

/

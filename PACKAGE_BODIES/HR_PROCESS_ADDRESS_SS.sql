--------------------------------------------------------
--  DDL for Package Body HR_PROCESS_ADDRESS_SS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_PROCESS_ADDRESS_SS" AS
/* $Header: hraddwrs.pkb 120.3.12010000.4 2009/10/27 06:19:00 ckondapi ship $*/

  -- Package scope global variables.
 l_transaction_table hr_transaction_ss.transaction_table;
 l_count INTEGER := 0;
 l_praddr_ovrlap VARCHAR2(2);
 l_transaction_step_id  hr_api_transaction_steps.transaction_step_id%type;
 l_trs_object_version_number  hr_api_transaction_steps.object_version_number%type;
 g_package      varchar2(31)   := 'HR_PROCESS_ADDRESS_SS';
 g_data_error            exception;
 l_message_number VARCHAR2(10);
 p_trans_rec_count integer;


  /*
  ||===========================================================================
  || FUNCTION: is_a_personal_info_flow
  ||---------------------------------------------------------------------------
  ||
  || Description:
  ||     This function will will check if the current flow is a personal information flow or not.
  ||
  || Access Status:
  ||     Private
  ||
  ||===========================================================================
  */

function is_a_personal_info_flow (
  p_person_id in number
  , p_effective_date in date )
  return boolean
  is

  CURSOR c_get_current_applicant_flag
         (p_person_id      in number
         ,p_eff_date       in date default trunc(sysdate))
  IS
  SELECT   per.current_applicant_flag,
           per.current_employee_flag,
           per.current_npw_flag
  FROM     per_all_people_f   per
  WHERE  per.person_id = p_person_id
  AND    p_eff_date BETWEEN per.effective_start_date and per.effective_end_date;

  l_current_applicant_flag  per_all_people_f.current_applicant_flag%type;
  l_current_employee_flag  per_all_people_f.current_employee_flag%type;
  l_current_npw_flag per_all_people_f.current_npw_flag%type;
  l_applicant_hire boolean := false ;
  l_re_hire boolean := false ;
  p_result  boolean := true;
  begin

   if (p_person_id is null or p_person_id < 0 ) then
        return false;
   end if;

   open c_get_current_applicant_flag(p_person_id, p_effective_date);
   fetch c_get_current_applicant_flag into l_current_applicant_flag, l_current_employee_flag, l_current_npw_flag;
   close c_get_current_applicant_flag;

   -- for rehire and applicant
  if (nvl(l_current_employee_flag, 'N') <>  'Y' AND
      nvl(l_current_npw_flag, 'N') <> 'Y') then
     return false;
  end if;
/*
  -- for applicant hire ---> g_applicant_hire = TRUE
  if (l_current_applicant_flag = 'Y' AND
      nvl(l_current_employee_flag, 'N') <>  'Y' AND
      nvl(l_current_npw_flag, 'N') <> 'Y') then
    l_applicant_hire := true;
  end if;

  if l_applicant_hire = false  then
    p_result := true;
  else
    p_result := false;
  end if;
  */
  return p_result;
  end is_a_personal_info_flow;


  /*
  ||===========================================================================
  || PROCEDURE: create_person_address
  ||---------------------------------------------------------------------------
  ||
  || Description:
  ||     This procedure will call the actual API -
  ||                hr_person_address_api.create_person_address()
  ||
  || Access Status:
  ||     Public.
  ||
  ||===========================================================================
  */
  PROCEDURE create_person_address
    (p_validate                      in     number   default 0
    ,p_effective_date                in     date
    ,p_pradd_ovlapval_override       in     number   default 0
    ,p_validate_county               in     number   default 1
    ,p_person_id                     in     number
    --
    -- PB Add :
    -- The transaction steps have to be created by the login personid.
    -- In case of adding address for contacts person_id is contact_person_id.
    -- Login person id is say employee who is adding the address to his contact.
    --
    ,p_login_person_id               in     number default null
    ,p_business_group_id             in     number default null
    --
    ,p_primary_flag                  in     varchar2
    ,p_style                         in     varchar2
    ,p_date_from                     in     date
    ,p_date_to                       in     date     default null
    ,p_address_type                  in     varchar2 default hr_api.g_varchar2
    ,p_address_type_meaning          in     varchar2 default hr_api.g_varchar2
    ,p_comments                      in     long default hr_api.g_varchar2
    ,p_address_line1                 in     varchar2 default hr_api.g_varchar2
    ,p_address_line2                 in     varchar2 default hr_api.g_varchar2
    ,p_address_line3                 in     varchar2 default hr_api.g_varchar2
    ,p_town_or_city                  in     varchar2 default hr_api.g_varchar2
    ,p_region_1                      in     varchar2 default hr_api.g_varchar2
    ,p_region_2                      in     varchar2 default hr_api.g_varchar2
    ,p_region_3                      in     varchar2 default hr_api.g_varchar2
    ,p_postal_code                   in     varchar2 default hr_api.g_varchar2
    ,p_country                       in     varchar2 default hr_api.g_varchar2
    ,p_country_meaning               in     varchar2 default hr_api.g_varchar2
    ,p_telephone_number_1            in     varchar2 default hr_api.g_varchar2
    ,p_telephone_number_2            in     varchar2 default hr_api.g_varchar2
    ,p_telephone_number_3            in     varchar2 default hr_api.g_varchar2
    ,p_addr_attribute_category       in     varchar2 default hr_api.g_varchar2
    ,p_addr_attribute1               in     varchar2 default hr_api.g_varchar2
    ,p_addr_attribute2               in     varchar2 default hr_api.g_varchar2
    ,p_addr_attribute3               in     varchar2 default hr_api.g_varchar2
    ,p_addr_attribute4               in     varchar2 default hr_api.g_varchar2
    ,p_addr_attribute5               in     varchar2 default hr_api.g_varchar2
    ,p_addr_attribute6               in     varchar2 default hr_api.g_varchar2
    ,p_addr_attribute7               in     varchar2 default hr_api.g_varchar2
    ,p_addr_attribute8               in     varchar2 default hr_api.g_varchar2
    ,p_addr_attribute9               in     varchar2 default hr_api.g_varchar2
    ,p_addr_attribute10              in     varchar2 default hr_api.g_varchar2
    ,p_addr_attribute11              in     varchar2 default hr_api.g_varchar2
    ,p_addr_attribute12              in     varchar2 default hr_api.g_varchar2
    ,p_addr_attribute13              in     varchar2 default hr_api.g_varchar2
    ,p_addr_attribute14              in     varchar2 default hr_api.g_varchar2
    ,p_addr_attribute15              in     varchar2 default hr_api.g_varchar2
    ,p_addr_attribute16              in     varchar2 default hr_api.g_varchar2
    ,p_addr_attribute17              in     varchar2 default hr_api.g_varchar2
    ,p_addr_attribute18              in     varchar2 default hr_api.g_varchar2
    ,p_addr_attribute19              in     varchar2 default hr_api.g_varchar2
    ,p_addr_attribute20              in     varchar2 default hr_api.g_varchar2
    ,p_add_information13             in     varchar2 default hr_api.g_varchar2
    ,p_add_information14             in     varchar2 default hr_api.g_varchar2
    ,p_add_information15             in     varchar2 default hr_api.g_varchar2
    ,p_add_information16             in     varchar2 default hr_api.g_varchar2
    ,p_add_information17             in     varchar2 default hr_api.g_varchar2
    ,p_add_information18             in     varchar2 default hr_api.g_varchar2
    ,p_add_information19             in     varchar2 default hr_api.g_varchar2
    ,p_add_information20             in     varchar2 default hr_api.g_varchar2
    ,p_address_id                       out nocopy number
    ,p_object_version_number            out nocopy number
    -- StartRegistration
    ,p_contact_or_person             in     varchar2 default null
    -- EndRegistration
    ,p_item_type                     in     varchar2
    ,p_item_key                      in     varchar2
    ,p_activity_id                   in     number
    ,p_action                        in     varchar2
    ,p_old_address_id                in     number   default null
    ,p_old_object_version_number     in     number   default null
    ,p_save_mode                     in     varchar2 default null
    ,p_error_message                 out nocopy    long
    , p_contact_relationship_id       in number           default hr_api.g_number
  )
  IS

  l_proc varchar2(200) := g_package || 'create_person_address';
  l_review_item_name           varchar2(50);
  l_date_to                    date;
  l_date_from                  date;
  l_transaction_id             number default null;
  l_result                     varchar2(100) default null;
  -- PB : Added the variables
  l_person_id                  number;
  l_dummy_num  number;
  l_dummy_date date;
  l_dummy_char varchar2(1000);
  l_dummy_bool boolean;

  -- StartRegistration

  l_primary_flag varchar2(10);
    -- StartRegistration
  l_reg_per_ovn                       number default null;
  l_reg_employee_number               number default null;
  l_reg_asg_ovn                       number default null;
  l_reg_full_name                     per_all_people_f.full_name%type default null;
  l_reg_assignment_id                 number;
  l_reg_per_effective_start_date      date;
  l_reg_per_effective_end_date        date;
  l_reg_per_comment_id                number;
  l_reg_assignment_sequence           number;
  l_reg_assignment_number             varchar2(50);
  l_reg_name_combination_warning      boolean;
  l_reg_assign_payroll_warning        boolean;
  l_reg_orig_hire_warning             boolean;
  --Startregistration gsheelum
  l_contact_set                       number;
  -- EndRegistration
  l_api_name                          varchar2(100);
  l_validate_g_per_con_step_id        number;
  l_old_ovn                           number;

  BEGIN
    hr_utility.set_location(' Entering:' || l_proc,5);

         --bug 5375749
    --If user enter effective date for which is less than person joining date then error should come.
    declare
      error_flag boolean := false;
      result     boolean := false;
    begin
      result := is_a_personal_info_flow (p_person_id, p_effective_date);
      error_flag := hr_perinfo_util_web.isDateLessThanCreationDate(p_effective_date,p_person_id);
      if result = true then
         hr_utility.trace('ORCL : inside the result true ');
      end if;
      if error_flag = true then
         hr_utility.trace('ORCL : inside the error_flag true');
      end if;
      if error_flag= true and result= true then
        fnd_message.set_name('PER', 'HR_PERINFO_INVALID_EFFEC_DATE');
        fnd_message.raise_error;
      end if;
    end ;
    --bug 5375749

    -- Call the actual API.
    --
    -- PB : In case of adding a contact and address to contact then person_id
    --      is null or less than 0, so to validate the address data, contact
    --      have to be created.
    --
    l_person_id := p_person_id;
    --
    -- StartRegistration
    l_primary_flag :=p_primary_flag;
    -- EndRegistration
    --
    --startregistration anupam
    -- If coming from overview page and creating a third address then the
    -- value of primary flag could be "T". This is required to be stored in
    -- transaction tables as "T" but the api validation will be as "N" only and
    -- finally it will go in database as N in process_api
    if p_primary_flag = 'T' then
    hr_utility.set_location(l_proc,10);
    l_primary_flag := 'N';
    end if;
    -- endregistration anupam

    IF (p_save_mode = 'SAVE_FOR_LATER') THEN
       hr_utility.set_location(l_proc,15);
       GOTO only_transaction;
    END IF;

    savepoint create_address;
    --
    if (l_person_id is null or l_person_id < 0 ) then
       hr_utility.set_location(l_proc,20);
       --
       -- Now create a dummy contact to the login person and
       -- use the out contact person id to validate the phone.
       --
       l_primary_flag := 'Y';
       --
    -- bug # 2174876
    if p_contact_or_person = 'CONTACT' or p_contact_or_person = 'EMER_CR_NEW_CONT' or p_contact_or_person = 'EMRG_OVRW_UPD' or p_contact_or_person = 'EMRG_OVRW_DEL' or  p_contact_or_person = 'EMER_CR_NEW_REL'
          or  p_contact_or_person = 'DPDNT_CR_NEW_CONT' or  p_contact_or_person = 'DPDNT_OVRW_UPD'  or  p_contact_or_person = 'DPDNT_OVRW_DEL' or  p_contact_or_person = 'DPDNT_CR_NEW_REL'
        or p_contact_or_person = 'COBRA' then
      declare
        l_object_version_number number;
        l_effective_start_date date;
        l_effective_end_date date;
        l_full_name varchar2(255);
        l_comment_id number;
        l_name_combination_warning boolean;
        l_orig_hire_warning boolean;
      begin
       hr_utility.set_location(l_proc,25);
       --ignore the dff validations for Dummy Person created
       hr_person_info_util_ss.create_ignore_df_validation('PER_PEOPLE');
       hr_person_info_util_ss.create_ignore_df_validation('Person Developer DF');
        hr_contact_api.create_person
           (p_start_date => p_effective_date,
            p_business_group_id =>p_business_group_id,
            p_last_name => 'RegistrationDummy',
	    p_first_name => 'Dummy',
            p_sex => 'M',
       --     p_coord_ben_no_cvg_flag => 'Y',
            p_person_id => l_person_id,
            p_object_version_number => l_object_version_number,
            p_effective_start_date => l_effective_start_date,
            p_effective_end_date => l_effective_end_date,
            p_full_name => l_full_name,
            p_comment_id => l_comment_id,
            p_name_combination_warning => l_name_combination_warning,
            p_orig_hire_warning => l_orig_hire_warning);
       hr_person_info_util_ss.remove_ignore_df_validation;
      end;
     end if;
      -- end bug # 2174876
      --end bug # 2138073/2115552
     if p_contact_or_person = 'PERSON' then
       hr_utility.set_location(l_proc,30);
       -- we need to call only BD step to create the dummy person
       -- and nothing else, so use process_selected_transaction
       hr_new_user_reg_ss.process_selected_transaction(
                  p_item_type => p_item_type,
                  p_item_key  => p_item_key,
                  p_api_name => 'HR_PROCESS_PERSON_SS.PROCESS_API');
       l_person_id := to_char(hr_process_person_ss.g_person_id);
     end if;
    end if;
    --
    -- StartRegistration : Changed the primary flag to validate the secondary
    -- address. In case of new person, there is no primary address so while
    -- validating the secondary address create_address errors out, so always
    -- validate as primary address.

    -- First end date the Secondary Address, before creating a new one
    -- and do it in validate false mode, as we have a rollback down.

    IF UPPER(p_action) = 'CHANGE' THEN
       IF UPPER(l_primary_flag) like 'N%' THEN
          hr_utility.set_location(l_proc,35);
          l_old_ovn := p_old_object_version_number;
          hr_person_address_api.update_person_address
                        (p_validate => false
                        ,p_effective_date => p_effective_date
                        ,p_address_id => p_old_address_id
                        ,p_object_version_number => l_old_ovn
                        ,p_date_to => p_date_to);
       END IF;
    END IF;

    hr_person_address_api.create_person_address
      (p_validate                      => hr_java_conv_util_ss.get_boolean (
                                            p_number => p_validate
                                          )
      ,p_effective_date                => p_effective_date
      ,p_pradd_ovlapval_override       => hr_java_conv_util_ss.get_boolean (
                                           p_number => p_pradd_ovlapval_override
                                          )
      ,p_validate_county               => hr_java_conv_util_ss.get_boolean (
                                           p_number => p_validate_county
                                          )
      ,p_person_id                     => l_person_id  -- PB : Modify p_person_id
      ,p_primary_flag                  => l_primary_flag -- StartRegistration
      ,p_style                         => p_style
      ,p_date_from                     => p_effective_date
      ,p_address_type                  => p_address_type
      ,p_comments                      => p_comments
      ,p_address_line1                 => p_address_line1
      ,p_address_line2                 => p_address_line2
      ,p_address_line3                 => p_address_line3
      ,p_town_or_city                  => p_town_or_city
      ,p_region_1                      => p_region_1
      ,p_region_2                      => p_region_2
      ,p_region_3                      => p_region_3
      ,p_postal_code                   => p_postal_code
      ,p_country                       => p_country
      ,p_telephone_number_1            => p_telephone_number_1
      ,p_telephone_number_2            => p_telephone_number_2
      ,p_telephone_number_3            => p_telephone_number_3
      ,p_addr_attribute_category       => p_addr_attribute_category
      ,p_addr_attribute1               => p_addr_attribute1
      ,p_addr_attribute2               => p_addr_attribute2
      ,p_addr_attribute3               => p_addr_attribute3
      ,p_addr_attribute4               => p_addr_attribute4
      ,p_addr_attribute5               => p_addr_attribute5
      ,p_addr_attribute6               => p_addr_attribute6
      ,p_addr_attribute7               => p_addr_attribute7
      ,p_addr_attribute8               => p_addr_attribute8
      ,p_addr_attribute9               => p_addr_attribute9
      ,p_addr_attribute10              => p_addr_attribute10
      ,p_addr_attribute11              => p_addr_attribute11
      ,p_addr_attribute12              => p_addr_attribute12
      ,p_addr_attribute13              => p_addr_attribute13
      ,p_addr_attribute14              => p_addr_attribute14
      ,p_addr_attribute15              => p_addr_attribute15
      ,p_addr_attribute16              => p_addr_attribute16
      ,p_addr_attribute17              => p_addr_attribute17
      ,p_addr_attribute18              => p_addr_attribute18
      ,p_addr_attribute19              => p_addr_attribute19
      ,p_addr_attribute20              => p_addr_attribute20
      ,p_add_information13             => p_add_information13
      ,p_add_information14             => p_add_information14
      ,p_add_information15             => p_add_information15
      ,p_add_information16             => p_add_information16
      ,p_add_information17             => p_add_information17
      ,p_add_information18             => p_add_information18
      ,p_add_information19             => p_add_information19
      ,p_add_information20             => p_add_information20
      --
      -- PB : These out variables should not be written to transaction tables.
      --
      ,p_address_id                    => l_dummy_num -- PB : p_address_id
      ,p_object_version_number         => l_dummy_num -- PB : p_object_version_number
    );
 -- PB : Now rollback all the changes which are performed.
 --

 ROLLBACK to create_address;
 --
 -- -----------------------------------------------------------------------------
 -- We will write the data to transaction tables.
 -- Determine if a transaction step exists for this activity
 -- if a transaction step does exist then the transaction_step_id and
 -- object_version_number are set (i.e. not null).
 -- -----------------------------------------------------------------------------

       <<only_transaction>> -- label for GOTO

      --
      -- Setting the following two helps to see the actual effective
      -- date of the transaction in All Actions Awaiting your attention
      -- table.
      -- Say for address user enters new address with an effective date
      -- this date helps to show as said above and also makes sure
      -- when SFL'd and started again uses this date.
      -- If not set, WF on starting sets this dates to sysdate and it
      -- shows that and also on retrieving SFL it performs as of sysdate
      -- rather than the actual date of the transaction.
      --
      -- We don't support this for contacts as it is always by sysdate
      -- if we end of setting it for contacts it even affects the start
      -- date of the dependents created in registration flow see
      -- bug 3784728 for more details
      --

      IF NOT (p_contact_or_person = 'CONTACT' or p_contact_or_person = 'EMER_CR_NEW_CONT' or p_contact_or_person = 'EMRG_OVRW_UPD' or p_contact_or_person = 'EMRG_OVRW_DEL' or  p_contact_or_person = 'EMER_CR_NEW_REL'
          or  p_contact_or_person = 'DPDNT_CR_NEW_CONT' or  p_contact_or_person = 'DPDNT_OVRW_UPD'  or  p_contact_or_person = 'DPDNT_OVRW_DEL' or  p_contact_or_person = 'DPDNT_CR_NEW_REL') THEN

       hr_utility.set_location(l_proc,40);
       wf_engine.setItemAttrText (itemtype => p_item_type,
                           itemkey  => p_item_key,
                           aname    => 'P_EFFECTIVE_DATE',
                           avalue   =>  to_char(p_effective_date,
                                        g_date_format));

       wf_engine.setItemAttrDate (itemtype => p_item_type,
                           itemkey  => p_item_key,
                           aname    => 'CURRENT_EFFECTIVE_DATE',
                           avalue   =>  p_effective_date);
       END IF;
       --
       -- First, check if transaction id exists or not
       --
       l_transaction_id := hr_transaction_ss.get_transaction_id
                     (p_item_type   => p_item_type
                     ,p_item_key    => p_item_key);
       --
       IF l_transaction_id is null THEN
         hr_utility.set_location(l_proc,45);

        -- Start a Transaction

        hr_transaction_ss.start_transaction
           (itemtype   => p_item_type
           ,itemkey    => p_item_key
           ,actid      => p_activity_id
           ,funmode    => 'RUN'
           ,p_api_addtnl_info => p_contact_or_person
           ,p_login_person_id => nvl(p_login_person_id, p_person_id) -- PB : Modification
           ,result     => l_result);

        l_transaction_id := hr_transaction_ss.get_transaction_id
                        (p_item_type   => p_item_type
                        ,p_item_key    => p_item_key);
       END IF;
       --
       -- Create a transaction step
       --
       hr_transaction_api.create_transaction_step
           (p_validate              => false
           ,p_creator_person_id     => nvl(p_login_person_id, p_person_id) -- PB : Modification
           ,p_transaction_id        => l_transaction_id
           ,p_api_name              => g_package || '.PROCESS_API'
           ,p_item_type             => p_item_type
           ,p_item_key              => p_item_key
           ,p_activity_id           => p_activity_id
           ,p_transaction_step_id   => l_transaction_step_id
           ,p_object_version_number => l_trs_object_version_number);
       --


	l_count := 1;
 	l_transaction_table(l_count).param_name := 'P_PERSON_ID';
 	l_transaction_table(l_count).param_value := p_person_id;
 	l_transaction_table(l_count).param_data_type := 'NUMBER';

--	IF UPPER(p_action) = 'DELETE' THEN
                hr_utility.set_location(l_proc,50);
--		l_effective_date := to_char(trunc(sysdate),l_user_date_format);
--	ELSE
                hr_utility.set_location(l_proc,55);
--		l_effective_date := p_effective_date;
--	END IF;

 	l_count := l_count + 1;
 	l_transaction_table(l_count).param_name := 'P_EFFECTIVE_DATE';
 	l_transaction_table(l_count).param_value := to_char(p_effective_date,
                                                    hr_transaction_ss.g_date_format);
 	l_transaction_table(l_count).param_data_type := 'DATE';

-- 	l_count := l_count + 1;
-- 	l_transaction_table(l_count).param_name := 'P_USER_DATE_FORMAT';
-- 	l_transaction_table(l_count).param_value := l_user_date_format;
-- 	l_transaction_table(l_count).param_data_type := 'VARCHAR2';

 	l_count := l_count + 1;
 	l_transaction_table(l_count).param_name := 'P_OBJECT_VERSION_NUMBER';
 	l_transaction_table(l_count).param_value := p_object_version_number;
 	l_transaction_table(l_count).param_data_type := 'NUMBER';

--    old object version number is same as object version number for create address

 	l_count := l_count + 1;
 	l_transaction_table(l_count).param_name	:= 'P_OLD_OBJECT_VERSION_NUMBER';
 	l_transaction_table(l_count).param_value := p_old_object_version_number;
 	l_transaction_table(l_count).param_data_type := 'NUMBER';

 	l_count := l_count + 1;
 	l_transaction_table(l_count).param_name := 'P_ADDRESS_ID';
 	l_transaction_table(l_count).param_value := p_address_id;
 	l_transaction_table(l_count).param_data_type := 'NUMBER';

--    old address id is same as address id for create address

 	l_count := l_count + 1;
 	l_transaction_table(l_count).param_name := 'P_OLD_ADDRESS_ID';
 	l_transaction_table(l_count).param_value := p_old_address_id;
 	l_transaction_table(l_count).param_data_type := 'NUMBER';

 	l_count := l_count + 1;
 	l_transaction_table(l_count).param_name := 'P_ADDRESS_LINE1';
 	l_transaction_table(l_count).param_value := p_address_line1;
 	l_transaction_table(l_count).param_data_type := 'VARCHAR2';

 	l_count := l_count + 1;
 	l_transaction_table(l_count).param_name := 'P_ADDRESS_LINE2';
 	l_transaction_table(l_count).param_value := p_address_line2;
 	l_transaction_table(l_count).param_data_type := 'VARCHAR2';

 	l_count := l_count + 1;
 	l_transaction_table(l_count).param_name := 'P_ADDRESS_LINE3';
 	l_transaction_table(l_count).param_value := p_address_line3;
 	l_transaction_table(l_count).param_data_type := 'VARCHAR2';

 	l_count := l_count + 1;
 	l_transaction_table(l_count).param_name := 'P_CITY';
 	l_transaction_table(l_count).param_value := p_town_or_city;
 	l_transaction_table(l_count).param_data_type := 'VARCHAR2';

 	l_count := l_count + 1;
 	l_transaction_table(l_count).param_name := 'P_REGION1';
 	l_transaction_table(l_count).param_value := p_region_1;
 	l_transaction_table(l_count).param_data_type := 'VARCHAR2';

-- 	l_count := l_count + 1;
-- 	l_transaction_table(l_count).param_name := 'P_STATE';
-- 	l_transaction_table(l_count).param_value := p_state;
-- 	l_transaction_table(l_count).param_data_type := 'VARCHAR2';

 	l_count := l_count + 1;
 	l_transaction_table(l_count).param_name := 'P_REGION2';
 	l_transaction_table(l_count).param_value := p_region_2;
 	l_transaction_table(l_count).param_data_type := 'VARCHAR2';

 	l_count := l_count + 1;
 	l_transaction_table(l_count).param_name := 'P_REGION3';
 	l_transaction_table(l_count).param_value := p_region_3;
 	l_transaction_table(l_count).param_data_type := 'VARCHAR2';

 	l_count := l_count + 1;
 	l_transaction_table(l_count).param_name := 'P_COUNTRY';
	l_transaction_table(l_count).param_value := p_country_meaning;
 	l_transaction_table(l_count).param_data_type := 'VARCHAR2';

 	l_count := l_count + 1;
 	l_transaction_table(l_count).param_name := 'P_COUNTRY_CODE';
 	l_transaction_table(l_count).param_value := p_country;
 	l_transaction_table(l_count).param_data_type := 'VARCHAR2';

 	l_count := l_count + 1;
 	l_transaction_table(l_count).param_name := 'P_POSTAL_CODE';
 	l_transaction_table(l_count).param_value := p_postal_code;
 	l_transaction_table(l_count).param_data_type := 'VARCHAR2';

 	l_count := l_count + 1;
	l_transaction_table(l_count).param_name := 'P_ADDRESS_TYPE';
 	l_transaction_table(l_count).param_value := p_address_type_meaning;
 	l_transaction_table(l_count).param_data_type := 'VARCHAR2';

 	l_count := l_count + 1;
 	l_transaction_table(l_count).param_name := 'P_ADDRESS_TYPE_CODE';
 	l_transaction_table(l_count).param_value := p_address_type;
 	l_transaction_table(l_count).param_data_type := 'VARCHAR2';

 	l_count := l_count + 1;
 	l_transaction_table(l_count).param_name := 'P_PRADD_OVLAPVAL_OVERRIDE';
        IF (p_pradd_ovlapval_override = 1) THEN
	   hr_utility.set_location(l_proc,60);
 	   l_transaction_table(l_count).param_value := 'Y';
        ELSIF (p_pradd_ovlapval_override = 0) THEN
	   hr_utility.set_location(l_proc,65);
           l_transaction_table(l_count).param_value := 'N';
        END IF;

 	l_transaction_table(l_count).param_data_type := 'VARCHAR2';

        l_count := l_count + 1;
        l_transaction_table(l_count).param_name := 'P_DATE_FROM';
        l_transaction_table(l_count).param_value := to_char(p_date_from,
                                                    hr_transaction_ss.g_date_format);
        l_transaction_table(l_count).param_data_type := 'DATE';

 	l_count := l_count + 1;
 	l_transaction_table(l_count).param_name := 'P_DATE_TO';
 	l_transaction_table(l_count).param_value := to_char(p_date_to,
                                                    hr_transaction_ss.g_date_format);
        l_transaction_table(l_count).param_data_type := 'DATE';

 	l_count := l_count + 1;
 	l_transaction_table(l_count).param_name := 'P_STYLE';
 	l_transaction_table(l_count).param_value := p_style;
 	l_transaction_table(l_count).param_data_type := 'VARCHAR2';

 	l_count := l_count + 1;
 	l_transaction_table(l_count).param_name := 'P_PRIMARY_FLAG';
 	l_transaction_table(l_count).param_value := p_primary_flag;
 	l_transaction_table(l_count).param_data_type := 'VARCHAR2';

 	l_count := l_count + 1;
 	l_transaction_table(l_count).param_name := 'P_ACTION';
 	l_transaction_table(l_count).param_value := UPPER(p_action);
 	l_transaction_table(l_count).param_data_type := 'VARCHAR2';

        l_count := l_count + 1;
        l_transaction_table(l_count).param_name := 'P_TELEPHONE_NUMBER1';
        l_transaction_table(l_count).param_value := p_telephone_number_1;
        l_transaction_table(l_count).param_data_type := 'VARCHAR2';

        l_count := l_count + 1;
        l_transaction_table(l_count).param_name := 'P_TELEPHONE_NUMBER2';
        l_transaction_table(l_count).param_value := p_telephone_number_2;
        l_transaction_table(l_count).param_data_type := 'VARCHAR2';

        l_count := l_count + 1;
        l_transaction_table(l_count).param_name := 'P_TELEPHONE_NUMBER3';
        l_transaction_table(l_count).param_value := p_telephone_number_3;
        l_transaction_table(l_count).param_data_type := 'VARCHAR2';

-- Now add all the Descriptive flex fields into transactions tables

        l_count := l_count + 1; -- CONTEXT
        l_transaction_table(l_count).param_name := 'P_ADDR_ATTRIBUTE_CATEGORY';
        l_transaction_table(l_count).param_value := p_addr_attribute_category;
        l_transaction_table(l_count).param_data_type := 'VARCHAR2';

        l_count := l_count + 1;
        l_transaction_table(l_count).param_name := 'P_ADDR_ATTRIBUTE1';
        l_transaction_table(l_count).param_value := p_addr_attribute1;
        l_transaction_table(l_count).param_data_type := 'VARCHAR2';

        l_count := l_count + 1;
        l_transaction_table(l_count).param_name := 'P_ADDR_ATTRIBUTE2';
        l_transaction_table(l_count).param_value := p_addr_attribute2;
        l_transaction_table(l_count).param_data_type := 'VARCHAR2';

        l_count := l_count + 1;
        l_transaction_table(l_count).param_name := 'P_ADDR_ATTRIBUTE3';
        l_transaction_table(l_count).param_value := p_addr_attribute3;
        l_transaction_table(l_count).param_data_type := 'VARCHAR2';

        l_count := l_count + 1;
        l_transaction_table(l_count).param_name := 'P_ADDR_ATTRIBUTE4';
        l_transaction_table(l_count).param_value := p_addr_attribute4;
        l_transaction_table(l_count).param_data_type := 'VARCHAR2';

        l_count := l_count + 1;
        l_transaction_table(l_count).param_name := 'P_ADDR_ATTRIBUTE5';
        l_transaction_table(l_count).param_value := p_addr_attribute5;
        l_transaction_table(l_count).param_data_type := 'VARCHAR2';

        l_count := l_count + 1;
        l_transaction_table(l_count).param_name := 'P_ADDR_ATTRIBUTE6';
        l_transaction_table(l_count).param_value := p_addr_attribute6;
        l_transaction_table(l_count).param_data_type := 'VARCHAR2';

        l_count := l_count + 1;
        l_transaction_table(l_count).param_name := 'P_ADDR_ATTRIBUTE7';
        l_transaction_table(l_count).param_value := p_addr_attribute7;
        l_transaction_table(l_count).param_data_type := 'VARCHAR2';

        l_count := l_count + 1;
        l_transaction_table(l_count).param_name := 'P_ADDR_ATTRIBUTE8';
        l_transaction_table(l_count).param_value := p_addr_attribute8;
        l_transaction_table(l_count).param_data_type := 'VARCHAR2';

        l_count := l_count + 1;
        l_transaction_table(l_count).param_name := 'P_ADDR_ATTRIBUTE9';
        l_transaction_table(l_count).param_value := p_addr_attribute9;
        l_transaction_table(l_count).param_data_type := 'VARCHAR2';

        l_count := l_count + 1;
        l_transaction_table(l_count).param_name := 'P_ADDR_ATTRIBUTE10';
        l_transaction_table(l_count).param_value := p_addr_attribute10;
        l_transaction_table(l_count).param_data_type := 'VARCHAR2';

        l_count := l_count + 1;
        l_transaction_table(l_count).param_name := 'P_ADDR_ATTRIBUTE11';
        l_transaction_table(l_count).param_value := p_addr_attribute11;
        l_transaction_table(l_count).param_data_type := 'VARCHAR2';

        l_count := l_count + 1;
        l_transaction_table(l_count).param_name := 'P_ADDR_ATTRIBUTE12';
        l_transaction_table(l_count).param_value := p_addr_attribute12;
        l_transaction_table(l_count).param_data_type := 'VARCHAR2';

        l_count := l_count + 1;
        l_transaction_table(l_count).param_name := 'P_ADDR_ATTRIBUTE13';
        l_transaction_table(l_count).param_value := p_addr_attribute13;
        l_transaction_table(l_count).param_data_type := 'VARCHAR2';

        l_count := l_count + 1;
        l_transaction_table(l_count).param_name := 'P_ADDR_ATTRIBUTE14';
        l_transaction_table(l_count).param_value := p_addr_attribute14;
        l_transaction_table(l_count).param_data_type := 'VARCHAR2';

        l_count := l_count + 1;
        l_transaction_table(l_count).param_name := 'P_ADDR_ATTRIBUTE15';
        l_transaction_table(l_count).param_value := p_addr_attribute15;
        l_transaction_table(l_count).param_data_type := 'VARCHAR2';

        l_count := l_count + 1;
        l_transaction_table(l_count).param_name := 'P_ADDR_ATTRIBUTE16';
        l_transaction_table(l_count).param_value := p_addr_attribute16;
        l_transaction_table(l_count).param_data_type := 'VARCHAR2';

        l_count := l_count + 1;
        l_transaction_table(l_count).param_name := 'P_ADDR_ATTRIBUTE17';
        l_transaction_table(l_count).param_value := p_addr_attribute17;
        l_transaction_table(l_count).param_data_type := 'VARCHAR2';

        l_count := l_count + 1;
        l_transaction_table(l_count).param_name := 'P_ADDR_ATTRIBUTE18';
        l_transaction_table(l_count).param_value := p_addr_attribute18;
        l_transaction_table(l_count).param_data_type := 'VARCHAR2';

        l_count := l_count + 1;
        l_transaction_table(l_count).param_name := 'P_ADDR_ATTRIBUTE19';
        l_transaction_table(l_count).param_value := p_addr_attribute19;
        l_transaction_table(l_count).param_data_type := 'VARCHAR2';

        l_count := l_count + 1;
        l_transaction_table(l_count).param_name := 'P_ADDR_ATTRIBUTE20';
        l_transaction_table(l_count).param_value := p_addr_attribute20;
        l_transaction_table(l_count).param_data_type := 'VARCHAR2';


        l_count := l_count + 1;
        l_transaction_table(l_count).param_name := 'P_ADD_INFORMATION13';
        l_transaction_table(l_count).param_value := p_add_information13;
        l_transaction_table(l_count).param_data_type := 'VARCHAR2';


        l_count := l_count + 1;
        l_transaction_table(l_count).param_name := 'P_ADD_INFORMATION14';
        l_transaction_table(l_count).param_value := p_add_information14;
        l_transaction_table(l_count).param_data_type := 'VARCHAR2';


        l_count := l_count + 1;
        l_transaction_table(l_count).param_name := 'P_ADD_INFORMATION15';
        l_transaction_table(l_count).param_value := p_add_information15;
        l_transaction_table(l_count).param_data_type := 'VARCHAR2';


        l_count := l_count + 1;
        l_transaction_table(l_count).param_name := 'P_ADD_INFORMATION16';
        l_transaction_table(l_count).param_value := p_add_information16;
        l_transaction_table(l_count).param_data_type := 'VARCHAR2';


        l_count := l_count + 1;
        l_transaction_table(l_count).param_name := 'P_ADD_INFORMATION17';
        l_transaction_table(l_count).param_value := p_add_information17;
        l_transaction_table(l_count).param_data_type := 'VARCHAR2';

        l_count := l_count + 1;
        l_transaction_table(l_count).param_name := 'P_ADD_INFORMATION18';
        l_transaction_table(l_count).param_value := p_add_information18;
        l_transaction_table(l_count).param_data_type := 'VARCHAR2';

        l_count := l_count + 1;
        l_transaction_table(l_count).param_name := 'P_ADD_INFORMATION19';
        l_transaction_table(l_count).param_value := p_add_information19;
        l_transaction_table(l_count).param_data_type := 'VARCHAR2';

        l_count := l_count + 1;
        l_transaction_table(l_count).param_name := 'P_ADD_INFORMATION20';
        l_transaction_table(l_count).param_value := p_add_information20;
        l_transaction_table(l_count).param_data_type := 'VARCHAR2';

        l_count := l_count + 1;
        l_transaction_table(l_count).param_name := 'P_REVIEW_ACTID';
        l_transaction_table(l_count).param_value := p_activity_id;
        l_transaction_table(l_count).param_data_type := 'VARCHAR2';

        BEGIN
          l_review_item_name := wf_engine.GetActivityAttrText(itemtype  => p_item_type,
                                                  itemkey   => p_item_key,
                                                  actid     => p_activity_id,
                                                  aname     => gv_wf_review_region_item);
        EXCEPTION
        WHEN OTHERS THEN
	   hr_utility.set_location(l_proc || 'EXCEPTION' ,555);
           l_review_item_name := 'HrMainAddressReview';
        END;

        l_count := l_count + 1;
        l_transaction_table(l_count).param_name := 'P_REVIEW_PROC_CALL';
        l_transaction_table(l_count).param_value := l_review_item_name;
        l_transaction_table(l_count).param_data_type := 'VARCHAR2';

        -- StartRegistration gsheelum
        l_count := l_count + 1;
        l_transaction_table(l_count).param_name := 'P_CONTACT_OR_PERSON';
        l_transaction_table(l_count).param_value := P_CONTACT_OR_PERSON;
        l_transaction_table(l_count).param_data_type := 'VARCHAR2';
        -- EndRegistration
        --
        --  This is a marker for the contact person to be used to identify the Address
        --  to be retrieved for the contact person in context in review page.
        --  The HR_LAST_CONTACT_SET is in from the work flow attribute
        begin
	    hr_utility.set_location(l_proc,70);
            l_contact_set := wf_engine.GetItemAttrNumber(itemtype => p_item_type,
                                                itemkey  => p_item_key,
                                                aname    => 'HR_CONTACT_SET');

            exception when others then
	        hr_utility.set_location(l_proc || 'EXCEPTION' ,560 );
                l_contact_set := 0;

        end;

        l_count := l_count + 1;
        l_transaction_table(l_count).param_name := 'P_CONTACT_SET';
        l_transaction_table(l_count).param_value := l_contact_set;
        l_transaction_table(l_count).param_data_type := 'VARCHAR2';

        if (p_contact_relationship_id > 0) then
	   hr_utility.set_location(l_proc,75);
           l_count := l_count + 1;
           l_transaction_table(l_count).param_name := 'P_CONTACT_RELATIONSHIP_ID';
           l_transaction_table(l_count).param_value := p_contact_relationship_id;
           l_transaction_table(l_count).param_data_type := 'NUMBER';
        end if;
        --EndRegistration gsheelum
	 hr_transaction_ss.save_transaction_step
       		(p_item_type => p_item_type
       		,p_item_key => p_item_key
       		,p_actid => p_activity_id
       	        ,p_login_person_id => nvl(p_login_person_id, p_person_id) -- PB Modification
                ,p_transaction_step_id => l_transaction_step_id
       		,p_api_name => g_package || '.PROCESS_API'
       		,p_transaction_data => l_transaction_table);


  hr_utility.set_location(' Leaving:' || l_proc,80);


   EXCEPTION
        WHEN hr_utility.hr_error THEN
	 hr_utility.set_location(' Leaving:' || l_proc,565);

         -- -------------------------------------------
         -- an application error has been raised so we must
         -- redisplay the web form to display the error
         -- --------------------------------------------
         hr_message.provide_error;
         l_message_number := hr_message.last_message_number;
         IF l_message_number = 'APP-7165' OR
            l_message_number = 'APP-7155' THEN
   --populate the p_error_message out variable
          p_error_message := hr_java_conv_util_ss.get_formatted_error_message(
                             p_error_message => p_error_message,
                             p_attr_name => 'Page',
                             p_app_short_name => 'PER',
                             p_message_name => 'HR_UPDATE_NOT_ALLOWED');
         ELSIF l_message_number = 'APP-51139' THEN
          p_error_message := hr_java_conv_util_ss.get_formatted_error_message(
                             p_error_message => p_error_message,
                             p_attr_name => 'AddressType',
                             p_app_short_name => 'PER',
                             p_message_name => 'HR_PERINFO_INVALID_ADDR_TYPE');
         ELSIF l_message_number = 'APP-7952' OR
               l_message_number = 'APP-7953' OR
               l_message_number = 'APP-51276' OR
               l_message_number = 'APP-51282'  THEN
          p_error_message := hr_java_conv_util_ss.get_formatted_error_message(
                             p_error_message => p_error_message,
                             p_app_short_name => 'PER',
                             p_message_name => 'HR_INVALID_CITYSTATEZIPCOUNTY');
         ELSE
          p_error_message := hr_java_conv_util_ss.get_formatted_error_message(
                             p_error_message => p_error_message);
         END IF;
    WHEN OTHERS THEN
    p_error_message := hr_java_conv_util_ss.get_formatted_error_message(
                             p_error_message => p_error_message);
  END create_person_address;

  /*
  ||===========================================================================
  || PROCEDURE: update_person_address
  ||---------------------------------------------------------------------------
  ||
  || Description:
  ||     This procedure will call the actual API -
  ||                hr_person_address_api.update_person_address()
  ||
  || Access Status:
  ||     Public.
  ||
  ||===========================================================================
  */

PROCEDURE update_person_address
  (p_validate                      in     number  default 0
  ,p_effective_date                in     date
  ,p_validate_county               in     number  default 1
  ,p_address_id                    in     number
  ,p_object_version_number         in out nocopy number
  ,p_date_from                     in     date     default hr_api.g_date
  ,p_date_to                       in     date     default hr_api.g_date
  ,p_address_type                  in     varchar2 default hr_api.g_varchar2
  ,p_address_type_meaning          in     varchar2 default hr_api.g_varchar2
  ,p_comments                      in     long default hr_api.g_varchar2
  ,p_address_line1                 in     varchar2 default hr_api.g_varchar2
  ,p_address_line2                 in     varchar2 default hr_api.g_varchar2
  ,p_address_line3                 in     varchar2 default hr_api.g_varchar2
  ,p_town_or_city                  in     varchar2 default hr_api.g_varchar2
  ,p_region_1                      in     varchar2 default hr_api.g_varchar2
  ,p_region_2                      in     varchar2 default hr_api.g_varchar2
  ,p_region_3                      in     varchar2 default hr_api.g_varchar2
  ,p_postal_code                   in     varchar2 default hr_api.g_varchar2
  ,p_country                       in     varchar2 default hr_api.g_varchar2
  ,p_country_meaning               in     varchar2 default hr_api.g_varchar2
  ,p_telephone_number_1            in     varchar2 default hr_api.g_varchar2
  ,p_telephone_number_2            in     varchar2 default hr_api.g_varchar2
  ,p_telephone_number_3            in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute_category       in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute1               in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute2               in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute3               in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute4               in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute5               in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute6               in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute7               in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute8               in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute9               in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute10              in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute11              in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute12              in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute13              in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute14              in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute15              in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute16              in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute17              in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute18              in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute19              in     varchar2 default hr_api.g_varchar2
  ,p_addr_attribute20              in     varchar2 default hr_api.g_varchar2
  ,p_add_information13             in     varchar2 default hr_api.g_varchar2
  ,p_add_information14             in     varchar2 default hr_api.g_varchar2
  ,p_add_information15             in     varchar2 default hr_api.g_varchar2
  ,p_add_information16             in     varchar2 default hr_api.g_varchar2
  ,p_add_information17             in     varchar2 default hr_api.g_varchar2
  ,p_add_information18             in     varchar2 default hr_api.g_varchar2
  ,p_add_information19             in     varchar2 default hr_api.g_varchar2
  ,p_add_information20             in     varchar2 default hr_api.g_varchar2
  ,p_item_type                     in     varchar2
  ,p_item_key                      in     varchar2
  ,p_activity_id                   in     number
  ,p_person_id                     in     number
  --
  -- PB Add :
  -- The transaction steps have to be created by the login personid.
  -- In case of adding phones for contacts parent_is is contact_person_id.
  -- Login person id is say employee who is adding the phones to his contact.
  --
  --TEST
  ,p_contact_or_person             in     varchar2 default null
  ,p_login_person_id               in     number default null
  ,p_primary_flag                  in     varchar2
  ,p_style                         in     varchar2
  ,p_action                        in     varchar2
  ,p_save_mode                     in     varchar2 default null
  ,p_error_message                 out nocopy    long
  , p_contact_relationship_id       in number           default hr_api.g_number
)
  IS

  l_proc varchar2(200) := g_package || 'update_person_address';
  l_old_ovn            number;
  l_old_address_id     per_addresses.address_id%TYPE;
    --startregistration anupam
  l_primary_flag       per_addresses.primary_flag%TYPE;
  --endregistration anupam
  l_review_item_name                        varchar2(50);
  l_date_to                                 date;
  l_date_from                               date;
  l_transaction_id             number default null;
  l_result                     varchar2(100) default null;


  BEGIN
    hr_utility.set_location(' Entering:' || l_proc,5);
 -- save the the old address id and old object version number in temp variables
    l_old_ovn := p_object_version_number;
    l_old_address_id := p_address_id;
    --startregistration anupam
    -- If coming from overview page and updating the third address then the
    -- value of primary flag could be "T". This is required to be stored in
    -- transaction tables as "T" but the api validation will be as "N" only and
    -- finally it will go in database as N in process_api
    l_primary_flag := p_primary_flag;
    if p_primary_flag = 'T' then
    hr_utility.set_location( l_proc,10);
    l_primary_flag := 'N';
    end if;
    -- replacing the p_primary_flag with l_primary_flag in api_calls
    -- endregistration anupam

    IF (p_save_mode = 'SAVE_FOR_LATER') THEN
        hr_utility.set_location( l_proc,15);
       GOTO only_transaction;
    END IF;


    -- Call the actual API.
--    savepoint update_address;
    IF (UPPER(p_action) = 'DELETE') THEN
     hr_utility.set_location( l_proc,20);
      hr_person_address_api.update_person_address
        (p_validate                      => hr_java_conv_util_ss.get_boolean (
                                              p_number => p_validate
                                            )
        ,p_effective_date                => p_effective_date
        ,p_validate_county               => hr_java_conv_util_ss.get_boolean (
                                             p_number => p_validate_county
                                            )
        ,p_address_id                    => p_address_id
        ,p_object_version_number         => p_object_version_number
        ,p_date_from                     => p_date_from
        ,p_date_to                       => p_date_to
      );

    ELSE --Bug#3114508 start
     hr_utility.set_location( l_proc,25);
      hr_person_address_api.update_pers_addr_with_style  --Bug#3114508 end
        (p_validate                      => hr_java_conv_util_ss.get_boolean (
                                              p_number => p_validate
                                            )
        ,p_effective_date                => p_effective_date
        ,p_validate_county               => hr_java_conv_util_ss.get_boolean (
                                             p_number => p_validate_county
                                            )
        ,p_address_id                    => p_address_id
        ,p_object_version_number         => p_object_version_number
        ,p_date_from                     => p_date_from
        ,p_date_to                       => p_date_to
        ,p_address_type                  => p_address_type
        ,p_comments                      => p_comments
        ,p_address_line1                 => p_address_line1
        ,p_address_line2                 => p_address_line2
        ,p_address_line3                 => p_address_line3
        ,p_town_or_city                  => p_town_or_city
        ,p_region_1                      => p_region_1
        ,p_region_2                      => p_region_2
        ,p_region_3                      => p_region_3
        ,p_postal_code                   => p_postal_code
        ,p_country                       => p_country  --Bug#3114508 start
        ,p_style                         => p_style   --Bug#3114508 end
        ,p_telephone_number_1            => p_telephone_number_1
        ,p_telephone_number_2            => p_telephone_number_2
        ,p_telephone_number_3            => p_telephone_number_3
        ,p_addr_attribute_category       => p_addr_attribute_category
        ,p_addr_attribute1               => p_addr_attribute1
        ,p_addr_attribute2               => p_addr_attribute2
        ,p_addr_attribute3               => p_addr_attribute3
        ,p_addr_attribute4               => p_addr_attribute4
        ,p_addr_attribute5               => p_addr_attribute5
        ,p_addr_attribute6               => p_addr_attribute6
        ,p_addr_attribute7               => p_addr_attribute7
        ,p_addr_attribute8               => p_addr_attribute8
        ,p_addr_attribute9               => p_addr_attribute9
        ,p_addr_attribute10              => p_addr_attribute10
        ,p_addr_attribute11              => p_addr_attribute11
        ,p_addr_attribute12              => p_addr_attribute12
        ,p_addr_attribute13              => p_addr_attribute13
        ,p_addr_attribute14              => p_addr_attribute14
        ,p_addr_attribute15              => p_addr_attribute15
        ,p_addr_attribute16              => p_addr_attribute16
        ,p_addr_attribute17              => p_addr_attribute17
        ,p_addr_attribute18              => p_addr_attribute18
        ,p_addr_attribute19              => p_addr_attribute19
        ,p_addr_attribute20              => p_addr_attribute20
        ,p_add_information13             => p_add_information13
        ,p_add_information14             => p_add_information14
        ,p_add_information15             => p_add_information15
        ,p_add_information16             => p_add_information16
        ,p_add_information17             => p_add_information17
        ,p_add_information18             => p_add_information18
        ,p_add_information19             => p_add_information19
        ,p_add_information20             => p_add_information20
      );
    END IF;

 -- -----------------------------------------------------------------------------
 -- We will write the data to transaction tables.
 -- Determine if a transaction step exists for this activity
 -- if a transaction step does exist then the transaction_step_id and
 -- object_version_number are set (i.e. not null).
 -- -----------------------------------------------------------------------------

    <<only_transaction>> -- label for GOTO
    hr_utility.set_location( l_proc,30);
-- Set the P_EFFECTIVE_DATE and CURRENT_EFFECTIVE_DATE in wf item attributes to be retreived
-- in review page

       wf_engine.setItemAttrText (itemtype => p_item_type,
                           itemkey  => p_item_key,
                           aname    => 'P_EFFECTIVE_DATE',
                           avalue   =>  to_char(p_effective_date,
                                        g_date_format));

       wf_engine.setItemAttrDate (itemtype => p_item_type,
                           itemkey  => p_item_key,
                           aname    => 'CURRENT_EFFECTIVE_DATE',
                           avalue   =>  p_effective_date);

  -- First, check if transaction id exists or not
       l_transaction_id := hr_transaction_ss.get_transaction_id
                     (p_item_type   => p_item_type
                     ,p_item_key    => p_item_key);
  --
       IF l_transaction_id is null THEN
        hr_utility.set_location( l_proc,35);
     -- Start a Transaction
        hr_transaction_ss.start_transaction
           (itemtype   => p_item_type
           ,itemkey    => p_item_key
           ,actid      => p_activity_id
           ,funmode    => 'RUN'
           --TEST
           ,p_api_addtnl_info => p_contact_or_person
           -- PB : For creating address for a contact use
           -- use login person id.
           --
           ,p_login_person_id => nvl(p_login_person_id, p_person_id)
           ,result     => l_result);

        l_transaction_id := hr_transaction_ss.get_transaction_id
                        (p_item_type   => p_item_type
                        ,p_item_key    => p_item_key);
       END IF;
  --
  -- Create a transaction step
  --
        hr_transaction_api.create_transaction_step
           (p_validate              => false
           -- PB : For creating address for a contact use
           -- use login person id.
           --
           ,p_creator_person_id     => nvl(p_login_person_id, p_person_id) -- p_person_id
           ,p_transaction_id        => l_transaction_id
           ,p_api_name              => g_package || '.PROCESS_API'
           ,p_item_type             => p_item_type
           ,p_item_key              => p_item_key
           ,p_activity_id           => p_activity_id
           ,p_transaction_step_id   => l_transaction_step_id
           ,p_object_version_number => l_trs_object_version_number);
  --

	l_count := 1;
 	l_transaction_table(l_count).param_name := 'P_PERSON_ID';
 	l_transaction_table(l_count).param_value := p_person_id;
 	l_transaction_table(l_count).param_data_type := 'NUMBER';

--	IF UPPER(p_action) = 'DELETE' THEN
               hr_utility.set_location( l_proc,40);
--		l_effective_date := to_char(trunc(sysdate),l_user_date_format);
--	ELSE
               hr_utility.set_location( l_proc,45);
--		l_effective_date := p_effective_date;
--	END IF;

        l_count := l_count + 1;
        l_transaction_table(l_count).param_name := 'P_EFFECTIVE_DATE';
        l_transaction_table(l_count).param_value := to_char(p_effective_date,
                                                    hr_transaction_ss.g_date_format);
        l_transaction_table(l_count).param_data_type := 'DATE';


-- 	l_count := l_count + 1;
-- 	l_transaction_table(l_count).param_name := 'P_USER_DATE_FORMAT';
-- 	l_transaction_table(l_count).param_value := l_user_date_format;
-- 	l_transaction_table(l_count).param_data_type := 'VARCHAR2';

 	l_count := l_count + 1;
 	l_transaction_table(l_count).param_name := 'P_OBJECT_VERSION_NUMBER';
 	l_transaction_table(l_count).param_value := p_object_version_number;
 	l_transaction_table(l_count).param_data_type := 'NUMBER';

 	l_count := l_count + 1;
 	l_transaction_table(l_count).param_name
			:= 'P_OLD_OBJECT_VERSION_NUMBER';
 	l_transaction_table(l_count).param_value := l_old_ovn;
 	l_transaction_table(l_count).param_data_type := 'NUMBER';

 	l_count := l_count + 1;
 	l_transaction_table(l_count).param_name := 'P_ADDRESS_ID';
 	l_transaction_table(l_count).param_value := p_address_id;
 	l_transaction_table(l_count).param_data_type := 'NUMBER';

 	l_count := l_count + 1;
 	l_transaction_table(l_count).param_name := 'P_OLD_ADDRESS_ID';
 	l_transaction_table(l_count).param_value := l_old_address_id;
 	l_transaction_table(l_count).param_data_type := 'NUMBER';

 	l_count := l_count + 1;
 	l_transaction_table(l_count).param_name := 'P_ADDRESS_LINE1';
 	l_transaction_table(l_count).param_value := p_address_line1;
 	l_transaction_table(l_count).param_data_type := 'VARCHAR2';

 	l_count := l_count + 1;
 	l_transaction_table(l_count).param_name := 'P_ADDRESS_LINE2';
 	l_transaction_table(l_count).param_value := p_address_line2;
 	l_transaction_table(l_count).param_data_type := 'VARCHAR2';

 	l_count := l_count + 1;
 	l_transaction_table(l_count).param_name := 'P_ADDRESS_LINE3';
 	l_transaction_table(l_count).param_value := p_address_line3;
 	l_transaction_table(l_count).param_data_type := 'VARCHAR2';

 	l_count := l_count + 1;
 	l_transaction_table(l_count).param_name := 'P_CITY';
 	l_transaction_table(l_count).param_value := p_town_or_city;
 	l_transaction_table(l_count).param_data_type := 'VARCHAR2';

 	l_count := l_count + 1;
 	l_transaction_table(l_count).param_name := 'P_REGION1';
 	l_transaction_table(l_count).param_value := p_region_1;
 	l_transaction_table(l_count).param_data_type := 'VARCHAR2';

-- 	l_count := l_count + 1;
-- 	l_transaction_table(l_count).param_name := 'P_STATE';
-- 	l_transaction_table(l_count).param_value := p_state;
-- 	l_transaction_table(l_count).param_data_type := 'VARCHAR2';

 	l_count := l_count + 1;
 	l_transaction_table(l_count).param_name := 'P_REGION2';
 	l_transaction_table(l_count).param_value := p_region_2;
 	l_transaction_table(l_count).param_data_type := 'VARCHAR2';

 	l_count := l_count + 1;
 	l_transaction_table(l_count).param_name := 'P_REGION3';
 	l_transaction_table(l_count).param_value := p_region_3;
 	l_transaction_table(l_count).param_data_type := 'VARCHAR2';

 	l_count := l_count + 1;
 	l_transaction_table(l_count).param_name := 'P_COUNTRY';
 	l_transaction_table(l_count).param_value := p_country_meaning;
 	l_transaction_table(l_count).param_data_type := 'VARCHAR2';

 	l_count := l_count + 1;
 	l_transaction_table(l_count).param_name := 'P_COUNTRY_CODE';
 	l_transaction_table(l_count).param_value := p_country;
 	l_transaction_table(l_count).param_data_type := 'VARCHAR2';

 	l_count := l_count + 1;
 	l_transaction_table(l_count).param_name := 'P_POSTAL_CODE';
 	l_transaction_table(l_count).param_value := p_postal_code;
 	l_transaction_table(l_count).param_data_type := 'VARCHAR2';

 	l_count := l_count + 1;
 	l_transaction_table(l_count).param_name := 'P_ADDRESS_TYPE';
 	l_transaction_table(l_count).param_value := p_address_type_meaning;
 	l_transaction_table(l_count).param_data_type := 'VARCHAR2';

 	l_count := l_count + 1;
 	l_transaction_table(l_count).param_name := 'P_ADDRESS_TYPE_CODE';
 	l_transaction_table(l_count).param_value := p_address_type;
 	l_transaction_table(l_count).param_data_type := 'VARCHAR2';

 	l_count := l_count + 1;
 	l_transaction_table(l_count).param_name := 'P_PRADD_OVLAPVAL_OVERRIDE';
 	l_transaction_table(l_count).param_value := 'N';
 	l_transaction_table(l_count).param_data_type := 'VARCHAR2';

        l_count := l_count + 1;
        l_transaction_table(l_count).param_name := 'P_DATE_FROM';
        l_transaction_table(l_count).param_value := to_char(p_date_from,
                                                    hr_transaction_ss.g_date_format);
        l_transaction_table(l_count).param_data_type := 'DATE';

 	l_count := l_count + 1;
 	l_transaction_table(l_count).param_name := 'P_DATE_TO';
        l_transaction_table(l_count).param_value := to_char(p_date_to,
                                                    hr_transaction_ss.g_date_format);
        l_transaction_table(l_count).param_data_type := 'DATE';

 	l_count := l_count + 1;
 	l_transaction_table(l_count).param_name := 'P_STYLE';
 	l_transaction_table(l_count).param_value := p_style;
 	l_transaction_table(l_count).param_data_type := 'VARCHAR2';

 	l_count := l_count + 1;
 	l_transaction_table(l_count).param_name := 'P_PRIMARY_FLAG';
 	l_transaction_table(l_count).param_value := p_primary_flag;
 	l_transaction_table(l_count).param_data_type := 'VARCHAR2';

 	l_count := l_count + 1;
 	l_transaction_table(l_count).param_name := 'P_ACTION';
 	l_transaction_table(l_count).param_value := UPPER(p_action);
 	l_transaction_table(l_count).param_data_type := 'VARCHAR2';

        l_count := l_count + 1;
        l_transaction_table(l_count).param_name := 'P_TELEPHONE_NUMBER1';
        l_transaction_table(l_count).param_value := p_telephone_number_1;
        l_transaction_table(l_count).param_data_type := 'VARCHAR2';

        l_count := l_count + 1;
        l_transaction_table(l_count).param_name := 'P_TELEPHONE_NUMBER2';
        l_transaction_table(l_count).param_value := p_telephone_number_2;
        l_transaction_table(l_count).param_data_type := 'VARCHAR2';

        l_count := l_count + 1;
        l_transaction_table(l_count).param_name := 'P_TELEPHONE_NUMBER3';
        l_transaction_table(l_count).param_value := p_telephone_number_3;
        l_transaction_table(l_count).param_data_type := 'VARCHAR2';

-- Now add all the Descriptive flex fields into transactions tables

        l_count := l_count + 1; -- CONTEXT
        l_transaction_table(l_count).param_name := 'P_ADDR_ATTRIBUTE_CATEGORY';
        l_transaction_table(l_count).param_value := p_addr_attribute_category;
        l_transaction_table(l_count).param_data_type := 'VARCHAR2';

        l_count := l_count + 1;
        l_transaction_table(l_count).param_name := 'P_ADDR_ATTRIBUTE1';
        l_transaction_table(l_count).param_value := p_addr_attribute1;
        l_transaction_table(l_count).param_data_type := 'VARCHAR2';

        l_count := l_count + 1;
        l_transaction_table(l_count).param_name := 'P_ADDR_ATTRIBUTE2';
        l_transaction_table(l_count).param_value := p_addr_attribute2;
        l_transaction_table(l_count).param_data_type := 'VARCHAR2';

        l_count := l_count + 1;
        l_transaction_table(l_count).param_name := 'P_ADDR_ATTRIBUTE3';
        l_transaction_table(l_count).param_value := p_addr_attribute3;
        l_transaction_table(l_count).param_data_type := 'VARCHAR2';

        l_count := l_count + 1;
        l_transaction_table(l_count).param_name := 'P_ADDR_ATTRIBUTE4';
        l_transaction_table(l_count).param_value := p_addr_attribute4;
        l_transaction_table(l_count).param_data_type := 'VARCHAR2';

        l_count := l_count + 1;
        l_transaction_table(l_count).param_name := 'P_ADDR_ATTRIBUTE5';
        l_transaction_table(l_count).param_value := p_addr_attribute5;
        l_transaction_table(l_count).param_data_type := 'VARCHAR2';

        l_count := l_count + 1;
        l_transaction_table(l_count).param_name := 'P_ADDR_ATTRIBUTE6';
        l_transaction_table(l_count).param_value := p_addr_attribute6;
        l_transaction_table(l_count).param_data_type := 'VARCHAR2';

        l_count := l_count + 1;
        l_transaction_table(l_count).param_name := 'P_ADDR_ATTRIBUTE7';
        l_transaction_table(l_count).param_value := p_addr_attribute7;
        l_transaction_table(l_count).param_data_type := 'VARCHAR2';

        l_count := l_count + 1;
        l_transaction_table(l_count).param_name := 'P_ADDR_ATTRIBUTE8';
        l_transaction_table(l_count).param_value := p_addr_attribute8;
        l_transaction_table(l_count).param_data_type := 'VARCHAR2';

        l_count := l_count + 1;
        l_transaction_table(l_count).param_name := 'P_ADDR_ATTRIBUTE9';
        l_transaction_table(l_count).param_value := p_addr_attribute9;
        l_transaction_table(l_count).param_data_type := 'VARCHAR2';

        l_count := l_count + 1;
        l_transaction_table(l_count).param_name := 'P_ADDR_ATTRIBUTE10';
        l_transaction_table(l_count).param_value := p_addr_attribute10;
        l_transaction_table(l_count).param_data_type := 'VARCHAR2';

        l_count := l_count + 1;
        l_transaction_table(l_count).param_name := 'P_ADDR_ATTRIBUTE11';
        l_transaction_table(l_count).param_value := p_addr_attribute11;
        l_transaction_table(l_count).param_data_type := 'VARCHAR2';

        l_count := l_count + 1;
        l_transaction_table(l_count).param_name := 'P_ADDR_ATTRIBUTE12';
        l_transaction_table(l_count).param_value := p_addr_attribute12;
        l_transaction_table(l_count).param_data_type := 'VARCHAR2';

        l_count := l_count + 1;
        l_transaction_table(l_count).param_name := 'P_ADDR_ATTRIBUTE13';
        l_transaction_table(l_count).param_value := p_addr_attribute13;
        l_transaction_table(l_count).param_data_type := 'VARCHAR2';

        l_count := l_count + 1;
        l_transaction_table(l_count).param_name := 'P_ADDR_ATTRIBUTE14';
        l_transaction_table(l_count).param_value := p_addr_attribute14;
        l_transaction_table(l_count).param_data_type := 'VARCHAR2';

        l_count := l_count + 1;
        l_transaction_table(l_count).param_name := 'P_ADDR_ATTRIBUTE15';
        l_transaction_table(l_count).param_value := p_addr_attribute15;
        l_transaction_table(l_count).param_data_type := 'VARCHAR2';

        l_count := l_count + 1;
        l_transaction_table(l_count).param_name := 'P_ADDR_ATTRIBUTE16';
        l_transaction_table(l_count).param_value := p_addr_attribute16;
        l_transaction_table(l_count).param_data_type := 'VARCHAR2';

        l_count := l_count + 1;
        l_transaction_table(l_count).param_name := 'P_ADDR_ATTRIBUTE17';
        l_transaction_table(l_count).param_value := p_addr_attribute17;
        l_transaction_table(l_count).param_data_type := 'VARCHAR2';

        l_count := l_count + 1;
        l_transaction_table(l_count).param_name := 'P_ADDR_ATTRIBUTE18';
        l_transaction_table(l_count).param_value := p_addr_attribute18;
        l_transaction_table(l_count).param_data_type := 'VARCHAR2';

        l_count := l_count + 1;
        l_transaction_table(l_count).param_name := 'P_ADDR_ATTRIBUTE19';
        l_transaction_table(l_count).param_value := p_addr_attribute19;
        l_transaction_table(l_count).param_data_type := 'VARCHAR2';


        l_count := l_count + 1;
        l_transaction_table(l_count).param_name := 'P_ADDR_ATTRIBUTE20';
        l_transaction_table(l_count).param_value := p_addr_attribute20;
        l_transaction_table(l_count).param_data_type := 'VARCHAR2';


        l_count := l_count + 1;
        l_transaction_table(l_count).param_name := 'P_ADD_INFORMATION13';
        l_transaction_table(l_count).param_value := p_add_information13;
        l_transaction_table(l_count).param_data_type := 'VARCHAR2';

        l_count := l_count + 1;
        l_transaction_table(l_count).param_name := 'P_ADD_INFORMATION14';
        l_transaction_table(l_count).param_value := p_add_information14;
        l_transaction_table(l_count).param_data_type := 'VARCHAR2';


        l_count := l_count + 1;
        l_transaction_table(l_count).param_name := 'P_ADD_INFORMATION15';
        l_transaction_table(l_count).param_value := p_add_information15;
        l_transaction_table(l_count).param_data_type := 'VARCHAR2';


        l_count := l_count + 1;
        l_transaction_table(l_count).param_name := 'P_ADD_INFORMATION16';
        l_transaction_table(l_count).param_value := p_add_information16;
        l_transaction_table(l_count).param_data_type := 'VARCHAR2';


        l_count := l_count + 1;
        l_transaction_table(l_count).param_name := 'P_ADD_INFORMATION17';
        l_transaction_table(l_count).param_value := p_add_information17;
        l_transaction_table(l_count).param_data_type := 'VARCHAR2';

        l_count := l_count + 1;
        l_transaction_table(l_count).param_name := 'P_ADD_INFORMATION18';
        l_transaction_table(l_count).param_value := p_add_information18;
        l_transaction_table(l_count).param_data_type := 'VARCHAR2';

        l_count := l_count + 1;
        l_transaction_table(l_count).param_name := 'P_ADD_INFORMATION19';
        l_transaction_table(l_count).param_value := p_add_information19;
        l_transaction_table(l_count).param_data_type := 'VARCHAR2';

        l_count := l_count + 1;
        l_transaction_table(l_count).param_name := 'P_ADD_INFORMATION20';
        l_transaction_table(l_count).param_value := p_add_information20;
        l_transaction_table(l_count).param_data_type := 'VARCHAR2';

        l_count := l_count + 1;
        l_transaction_table(l_count).param_name := 'P_REVIEW_ACTID';
        l_transaction_table(l_count).param_value := p_activity_id;
        l_transaction_table(l_count).param_data_type := 'VARCHAR2';

        BEGIN
	   hr_utility.set_location( l_proc,50);
          l_review_item_name := wf_engine.GetActivityAttrText(itemtype  => p_item_type,
                                                  itemkey   => p_item_key,
                                                  actid     => p_activity_id,
                                                  aname     => gv_wf_review_region_item);
        EXCEPTION
        WHEN OTHERS THEN
	    hr_utility.set_location( l_proc || 'EXCEPTION' ,555);
           l_review_item_name := 'HrMainAddressReview';
        END;

        l_count := l_count + 1;
        l_transaction_table(l_count).param_name := 'P_REVIEW_PROC_CALL';
        l_transaction_table(l_count).param_value := l_review_item_name;
        l_transaction_table(l_count).param_data_type := 'VARCHAR2';
        if (p_contact_relationship_id > 0) then
	  hr_utility.set_location( l_proc,55);
         l_count := l_count + 1;
         l_transaction_table(l_count).param_name := 'P_CONTACT_RELATIONSHIP_ID';
         l_transaction_table(l_count).param_value := p_contact_relationship_id;
         l_transaction_table(l_count).param_data_type := 'NUMBER';
        end if;


	 hr_transaction_ss.save_transaction_step
       		(p_item_type => p_item_type
       		,p_item_key => p_item_key
       	        ,p_login_person_id => nvl(p_login_person_id, p_person_id	)
                ,p_actid => p_activity_id
       		,p_transaction_step_id => l_transaction_step_id
       		,p_api_name => g_package || '.PROCESS_API'
       		,p_transaction_data => l_transaction_table);


hr_utility.set_location(' Leaving:' || l_proc,60);

  EXCEPTION
        WHEN hr_utility.hr_error THEN
	 hr_utility.set_location(' Leaving:' || l_proc,560);

         -- -------------------------------------------
         -- an application error has been raised so we must
         -- redisplay the web form to display the error
         -- --------------------------------------------
         hr_message.provide_error;
         l_message_number := hr_message.last_message_number;
         IF l_message_number = 'APP-7165' OR
            l_message_number = 'APP-7155' THEN
   --populate the p_error_message out variable
          p_error_message := hr_java_conv_util_ss.get_formatted_error_message(
                             p_error_message => p_error_message,
                             p_attr_name => 'Page',
                             p_app_short_name => 'PER',
                             p_message_name => 'HR_UPDATE_NOT_ALLOWED');
         ELSIF l_message_number = 'APP-51139' THEN
          p_error_message := hr_java_conv_util_ss.get_formatted_error_message(
                             p_error_message => p_error_message,
                             p_attr_name => 'AddressType',
                             p_app_short_name => 'PER',
                             p_message_name => 'HR_PERINFO_INVALID_ADDR_TYPE');
         ELSIF l_message_number = 'APP-7952' OR
               l_message_number = 'APP-7953' OR
               l_message_number = 'APP-51276' OR
               l_message_number = 'APP-51282'  THEN
          p_error_message := hr_java_conv_util_ss.get_formatted_error_message(
                             p_error_message => p_error_message,
                             p_app_short_name => 'PER',
                             p_message_name => 'HR_INVALID_CITYSTATEZIPCOUNTY');
         ELSE
          p_error_message := hr_java_conv_util_ss.get_formatted_error_message(
                             p_error_message => p_error_message);
         END IF;
    WHEN OTHERS THEN
    hr_utility.set_location(' Leaving:' || l_proc,565);

    p_error_message := hr_java_conv_util_ss.get_formatted_error_message(
                             p_error_message => p_error_message);
  END update_person_address;

-- ---------------------- < get_address_data_from_tt> -------------------------
-- ---------------------------------------------------------------------------
-- Purpose: This procedure will get transaction data which are pending for
--          approval in workflow for a given person id, workflow process name
--          and workflow activity name.  This is the overloaded version.
-- ---------------------------------------------------------------------------
PROCEDURE get_address_data_from_tt
   (p_item_type                       in     varchar2
   ,p_process_name                    in     varchar2
   ,p_activity_name                   in     varchar2
   ,p_current_person_id               in     varchar2
   ,p_effective_date                  out nocopy    date
   ,p_person_id                       out nocopy number
   ,p_address_id                      out nocopy number
   ,p_object_version_number           out nocopy number
   ,p_primary_flag                    out nocopy varchar2
   ,p_style                           out nocopy varchar2
   ,p_date_from                       out nocopy date
   ,p_date_to                         out nocopy date
   ,p_address_type                    out nocopy varchar2
   ,p_address_type_meaning            out nocopy varchar2
   ,p_comments                        out nocopy varchar2
   ,p_address_line1                   out nocopy varchar2
   ,p_address_line2                   out nocopy varchar2
   ,p_address_line3                   out nocopy varchar2
   ,p_town_or_city                    out nocopy varchar2
   ,p_region_1                        out nocopy varchar2
   ,p_region_2                        out nocopy varchar2
   ,p_region_3                        out nocopy varchar2
   ,p_postal_code                     out nocopy varchar2
   ,p_country                         out nocopy varchar2
   ,p_country_meaning                 out nocopy varchar2
   ,p_telephone_number_1              out nocopy varchar2
   ,p_telephone_number_2              out nocopy varchar2
   ,p_telephone_number_3              out nocopy varchar2
   ,p_addr_attribute_category         out nocopy varchar2
   ,p_addr_attribute1                 out nocopy varchar2
   ,p_addr_attribute2                 out nocopy varchar2
   ,p_addr_attribute3                 out nocopy varchar2
   ,p_addr_attribute4                 out nocopy varchar2
   ,p_addr_attribute5                 out nocopy varchar2
   ,p_addr_attribute6                 out nocopy varchar2
   ,p_addr_attribute7                 out nocopy varchar2
   ,p_addr_attribute8                 out nocopy varchar2
   ,p_addr_attribute9                 out nocopy varchar2
   ,p_addr_attribute10                out nocopy varchar2
   ,p_addr_attribute11                out nocopy varchar2
   ,p_addr_attribute12                out nocopy varchar2
   ,p_addr_attribute13                out nocopy varchar2
   ,p_addr_attribute14                out nocopy varchar2
   ,p_addr_attribute15                out nocopy varchar2
   ,p_addr_attribute16                out nocopy varchar2
   ,p_addr_attribute17                out nocopy varchar2
   ,p_addr_attribute18                out nocopy varchar2
   ,p_addr_attribute19                out nocopy varchar2
   ,p_addr_attribute20                out nocopy varchar2
   ,p_add_information17               out nocopy varchar2
   ,p_add_information18               out nocopy varchar2
   ,p_add_information19               out nocopy varchar2
   ,p_add_information20               out nocopy varchar2
   ,p_action                          out nocopy varchar2
   ,p_old_address_id                  out nocopy varchar2
   ,p_add_information13               out nocopy varchar2
   ,p_add_information14               out nocopy varchar2
   ,p_add_information15               out nocopy varchar2
   ,p_add_information16               out nocopy varchar2
)is

  l_proc varchar2(200) := g_package || 'get_address_data_from_tt';
  l_transaction_id             number;
  l_trans_step_id              number;
  l_trans_obj_vers_num         number;
  l_active_wf_items_tbl        hr_workflow_service.active_wf_items_list;
  l_active_item_keys_tbl       hr_workflow_service.active_wf_items_list;
  l_count                      integer default 0;
--  l_trans_rec_count      integer default 0;
  l_trans_rec_count      number;
begin

  hr_utility.set_location(' Entering:' || l_proc,5);

  -- ------------------------------------------------------------------
  -- Check if there are any transactions waiting to be approved.
  -----------------------------------------------------------------------------

  -- 1) Find all item keys which have a status of "ACTIVE" for p_process_name
  -- 2) Then for those item keys, check if there are any transaction steps
  --    exist. There can be defunct workflow processes.  Therefore, we must
  --    match active processes with transaction tables.
  -- 3) If transaction steps are found, check that if the item key is for the
  --    particular activity (derive the activity_id from p_activity_name).
  --    If found, then there are pending approval transaction data.
  --
  -- Following function will return a PL/SQL table which has following
  -- fields : Item Key, Activity ID
  -----------------------------------------------------------------------------
  l_active_wf_items_tbl := hr_workflow_service.check_active_wf_items
                          (p_item_type           => p_item_type
                          ,p_process_name        => p_process_name
                          ,p_current_person_id   => p_current_person_id
                          ,p_activity_name       => p_activity_name);

  l_count := l_active_wf_items_tbl.COUNT;

  IF l_count > 0
     -- -------------------------------------------------------------------
     -- There are some transactions waiting to be approved for the given
     -- process, person and activity name.
     -- There can only be 1 row returned but not more for
     -- 'HR_MAINT_PERSONAL_DETAILS_FRM', 'HR_MAINT_MAIN_ADDRESS_FRM',
     -- 'HR_MAINT_SECONDARY_ADDRESS_FRM .  For contacts, there can be ??? rows.
     -- -------------------------------------------------------------------
  THEN
    hr_utility.set_location(l_proc,10);


     -- For Personal Information, there can only be 1 transaction step per
     -- item type and item key, therefore, we don't need to handle the multiple
     -- rows situation.

     FOR i in 1..l_count LOOP
         hr_transaction_api.get_transaction_step_info
          (p_item_type             => p_item_type
          ,p_item_key              => l_active_wf_items_tbl(i).active_item_key
          ,p_activity_id           => l_active_wf_items_tbl(i).activity_id
          ,p_transaction_step_id   => l_trans_step_id
          ,p_object_version_number => l_trans_obj_vers_num);
     END LOOP;
  ELSE
     hr_utility.set_location(l_proc,15);
     l_trans_rec_count := 0;
--     p_trans_rec_count := to_char(l_trans_rec_count);
     p_trans_rec_count := l_trans_rec_count;
     RETURN;
  END IF;

  -- If we are here, that means we've found a pending wf item and there should
  -- be matching transaction records.  If we cannot find any transaction step,
  -- that means we have a data integrity error.
  IF l_trans_step_id is NULL OR
     l_trans_step_id = 0
  THEN
     hr_utility.set_location(l_proc,20);
     RAISE g_data_error;
  END IF;
--
-- Now get the transaction data for the given step
  get_address_data_from_tt(
    p_transaction_step_id            => l_trans_step_id
   ,p_effective_date                 => p_effective_date
   ,p_person_id                      => p_person_id
   ,p_address_id                     => p_address_id
   ,p_object_version_number          => p_object_version_number
   ,p_primary_flag                   => p_primary_flag
   ,p_style                          => p_style
   ,p_date_from                      => p_date_from
   ,p_date_to                        => p_date_to
   ,p_address_type                   => p_address_type
   ,p_address_type_meaning           => p_address_type_meaning
   ,p_comments                       => p_comments
   ,p_address_line1                  => p_address_line1
   ,p_address_line2                  => p_address_line2
   ,p_address_line3                  => p_address_line3
   ,p_town_or_city                   => p_town_or_city
   ,p_region_1                       => p_region_1
   ,p_region_2                       => p_region_2
   ,p_region_3                       => p_region_3
   ,p_postal_code                    => p_postal_code
   ,p_country                        => p_country
   ,p_country_meaning                => p_country_meaning
   ,p_telephone_number_1             => p_telephone_number_1
   ,p_telephone_number_2             => p_telephone_number_2
   ,p_telephone_number_3             => p_telephone_number_3
   ,p_addr_attribute_category        => p_addr_attribute_category
   ,p_addr_attribute1                => p_addr_attribute1
   ,p_addr_attribute2                => p_addr_attribute2
   ,p_addr_attribute3                => p_addr_attribute3
   ,p_addr_attribute4                => p_addr_attribute4
   ,p_addr_attribute5                => p_addr_attribute5
   ,p_addr_attribute6                => p_addr_attribute6
   ,p_addr_attribute7                => p_addr_attribute7
   ,p_addr_attribute8                => p_addr_attribute8
   ,p_addr_attribute9                => p_addr_attribute9
   ,p_addr_attribute10               => p_addr_attribute10
   ,p_addr_attribute11               => p_addr_attribute11
   ,p_addr_attribute12               => p_addr_attribute12
   ,p_addr_attribute13               => p_addr_attribute13
   ,p_addr_attribute14               => p_addr_attribute14
   ,p_addr_attribute15               => p_addr_attribute15
   ,p_addr_attribute16               => p_addr_attribute16
   ,p_addr_attribute17               => p_addr_attribute17
   ,p_addr_attribute18               => p_addr_attribute18
   ,p_addr_attribute19               => p_addr_attribute19
   ,p_addr_attribute20               => p_addr_attribute20
   ,p_add_information17              => p_add_information17
   ,p_add_information18              => p_add_information18
   ,p_add_information19              => p_add_information19
   ,p_add_information20              => p_add_information20
   ,p_action                         => p_action
   ,p_old_address_id                 => p_old_address_id
   ,p_add_information13              => p_add_information13
   ,p_add_information14              => p_add_information14
   ,p_add_information15              => p_add_information15
   ,p_add_information16              => p_add_information16
);

 -- p_trans_rec_count := to_char(l_trans_rec_count);
  p_trans_rec_count := l_trans_rec_count;


hr_utility.set_location(' Leaving:' || l_proc,25);

EXCEPTION
  WHEN g_data_error THEN
     hr_utility.set_location(' Leaving:' || l_proc,555);
     RAISE;

END get_address_data_from_tt;


-- ---------------------------------------------------------------------------
-- ---------------------- < get_address_data_from_tt> -------------------------
-- ---------------------------------------------------------------------------
-- Purpose: This procedure will get transaction data which are saved earlier
--          in the current transaction.  This is invoked when a user click BACK
--          button to go back from the Review page to Update page to correct
--          typos or make further changes.  Hence, we need to use the item_type
--          item_key passed in to retrieve the transaction record.
--          This is an overloaded version.
-- ---------------------------------------------------------------------------
PROCEDURE get_address_data_from_tt
   (p_item_type                       in  varchar2
   ,p_item_key                        in  varchar2
   ,p_activity_id                     in  varchar2
   ,p_trans_rec_count                 out nocopy number
   ,p_effective_date                  out nocopy    date
   ,p_person_id                       out nocopy number
   ,p_address_id                      out nocopy number
   ,p_object_version_number           out nocopy number
   ,p_primary_flag                    out nocopy varchar2
   ,p_style                           out nocopy varchar2
   ,p_date_from                       out nocopy date
   ,p_date_to                         out nocopy date
   ,p_address_type                    out nocopy varchar2
   ,p_address_type_meaning            out nocopy varchar2
   ,p_comments                        out nocopy varchar2
   ,p_address_line1                   out nocopy varchar2
   ,p_address_line2                   out nocopy varchar2
   ,p_address_line3                   out nocopy varchar2
   ,p_town_or_city                    out nocopy varchar2
   ,p_region_1                        out nocopy varchar2
   ,p_region_2                        out nocopy varchar2
   ,p_region_3                        out nocopy varchar2
   ,p_postal_code                     out nocopy varchar2
   ,p_country                         out nocopy varchar2
   ,p_country_meaning                 out nocopy varchar2
   ,p_telephone_number_1              out nocopy varchar2
   ,p_telephone_number_2              out nocopy varchar2
   ,p_telephone_number_3              out nocopy varchar2
   ,p_addr_attribute_category         out nocopy varchar2
   ,p_addr_attribute1                 out nocopy varchar2
   ,p_addr_attribute2                 out nocopy varchar2
   ,p_addr_attribute3                 out nocopy varchar2
   ,p_addr_attribute4                 out nocopy varchar2
   ,p_addr_attribute5                 out nocopy varchar2
   ,p_addr_attribute6                 out nocopy varchar2
   ,p_addr_attribute7                 out nocopy varchar2
   ,p_addr_attribute8                 out nocopy varchar2
   ,p_addr_attribute9                 out nocopy varchar2
   ,p_addr_attribute10                out nocopy varchar2
   ,p_addr_attribute11                out nocopy varchar2
   ,p_addr_attribute12                out nocopy varchar2
   ,p_addr_attribute13                out nocopy varchar2
   ,p_addr_attribute14                out nocopy varchar2
   ,p_addr_attribute15                out nocopy varchar2
   ,p_addr_attribute16                out nocopy varchar2
   ,p_addr_attribute17                out nocopy varchar2
   ,p_addr_attribute18                out nocopy varchar2
   ,p_addr_attribute19                out nocopy varchar2
   ,p_addr_attribute20                out nocopy varchar2
   ,p_add_information17               out nocopy varchar2
   ,p_add_information18               out nocopy varchar2
   ,p_add_information19               out nocopy varchar2
   ,p_add_information20               out nocopy varchar2
   ,p_action                          out nocopy varchar2
   ,p_old_address_id                  out nocopy varchar2
   ,p_add_information13               out nocopy varchar2
   ,p_add_information14               out nocopy varchar2
   ,p_add_information15               out nocopy varchar2
   ,p_add_information16               out nocopy varchar2
) is

   l_proc varchar2(200) := g_package || 'get_address_data_from_tt';
   l_trans_step_ids       hr_util_web.g_varchar2_tab_type;
   l_api_names  hr_util_web.g_varchar2_tab_type;
   l_trans_step_rows                  NUMBER  ;

   l_trans_rec_count                  integer default 0;

 BEGIN

  hr_utility.set_location(' Entering:' || l_proc,5);

  -- ------------------------------------------------------------------
  -- Check if there are any transaction rec already saved for the current
  -- transaction. This is used for re-display the Update page when a user
  -- clicks the Back button on the Review page to go back to the Update page
  -- to make further changes or to correct errors.
  -----------------------------------------------------------------------------
  hr_transaction_api.get_transaction_step_info
     (p_item_type              => p_item_type
     ,p_item_key               => p_item_key
     ,p_activity_id            => p_activity_id
     ,p_transaction_step_id    => l_trans_step_ids
     ,p_api_name               => l_api_names
     ,p_rows                   => l_trans_step_rows);


  IF l_trans_step_rows IS NOT NULL OR
     l_trans_step_rows > 0
  THEN
     hr_utility.set_location(l_proc,10);
     l_trans_rec_count := l_trans_step_rows;
  ELSE
     hr_utility.set_location(l_proc,15);
     l_trans_rec_count := 0;
     hr_utility.set_location(' Leaving:' || l_proc,20);

     return;
  END IF;
  --
  -- -------------------------------------------------------------------
  -- There are some changes made earlier in the transaction.
  -- Retrieve the data and return to caller.
  -- -------------------------------------------------------------------
  --
  -- Now get the transaction data for the given step
  -- Need to loop through l_trans_rec_count -1 as the index starts from 0

  FOR i in 0..l_trans_rec_count-1 LOOP
   IF(l_api_names(i) = 'HR_PROCESS_ADDRESS_SS.PROCESS_API') THEN
      hr_utility.set_location(l_proc  || 'LOOP' ,25);
    get_address_data_from_tt(
    p_transaction_step_id            => l_trans_step_ids(i)
   ,p_effective_date                 => p_effective_date
   ,p_person_id                      => p_person_id
   ,p_address_id                     => p_address_id
   ,p_object_version_number          => p_object_version_number
   ,p_primary_flag                   => p_primary_flag
   ,p_style                          => p_style
   ,p_date_from                      => p_date_from
   ,p_date_to                        => p_date_to
   ,p_address_type                   => p_address_type
   ,p_address_type_meaning           => p_address_type_meaning
   ,p_comments                       => p_comments
   ,p_address_line1                  => p_address_line1
   ,p_address_line2                  => p_address_line2
   ,p_address_line3                  => p_address_line3
   ,p_town_or_city                   => p_town_or_city
   ,p_region_1                       => p_region_1
   ,p_region_2                       => p_region_2
   ,p_region_3                       => p_region_3
   ,p_postal_code                    => p_postal_code
   ,p_country                        => p_country
   ,p_country_meaning                => p_country_meaning
   ,p_telephone_number_1             => p_telephone_number_1
   ,p_telephone_number_2             => p_telephone_number_2
   ,p_telephone_number_3             => p_telephone_number_3
   ,p_addr_attribute_category        => p_addr_attribute_category
   ,p_addr_attribute1                => p_addr_attribute1
   ,p_addr_attribute2                => p_addr_attribute2
   ,p_addr_attribute3                => p_addr_attribute3
   ,p_addr_attribute4                => p_addr_attribute4
   ,p_addr_attribute5                => p_addr_attribute5
   ,p_addr_attribute6                => p_addr_attribute6
   ,p_addr_attribute7                => p_addr_attribute7
   ,p_addr_attribute8                => p_addr_attribute8
   ,p_addr_attribute9                => p_addr_attribute9
   ,p_addr_attribute10               => p_addr_attribute10
   ,p_addr_attribute11               => p_addr_attribute11
   ,p_addr_attribute12               => p_addr_attribute12
   ,p_addr_attribute13               => p_addr_attribute13
   ,p_addr_attribute14               => p_addr_attribute14
   ,p_addr_attribute15               => p_addr_attribute15
   ,p_addr_attribute16               => p_addr_attribute16
   ,p_addr_attribute17               => p_addr_attribute17
   ,p_addr_attribute18               => p_addr_attribute18
   ,p_addr_attribute19               => p_addr_attribute19
   ,p_addr_attribute20               => p_addr_attribute20
   ,p_add_information17              => p_add_information17
   ,p_add_information18              => p_add_information18
   ,p_add_information19              => p_add_information19
   ,p_add_information20              => p_add_information20
   ,p_action                         => p_action
   ,p_old_address_id                 => p_old_address_id
   ,p_add_information13              => p_add_information13
   ,p_add_information14              => p_add_information14
   ,p_add_information15              => p_add_information15
   ,p_add_information16              => p_add_information16
   );
  END IF;
 END LOOP;



--  p_trans_rec_count := to_char(l_trans_rec_count);
  p_trans_rec_count := l_trans_rec_count;

hr_utility.set_location(' Leaving:' || l_proc,30);

EXCEPTION
   WHEN g_data_error THEN
   hr_utility.set_location(' Leaving:' || l_proc,555);

      RAISE;

END get_address_data_from_tt;


-- ---------------------------------------------------------------------------
-- ---------------------- < get_address_data_from_tt> -------------------------
-- ---------------------------------------------------------------------------
-- Purpose: This procedure will get transaction data which are pending for
--          approval in workflow for a transaction step id.
-- ---------------------------------------------------------------------------
procedure get_address_data_from_tt
   (p_transaction_step_id             in  number
   ,p_effective_date                  out nocopy date
   ,p_person_id                       out nocopy number
   ,p_address_id                      out nocopy number
   ,p_object_version_number           out nocopy number
   ,p_primary_flag                    out nocopy varchar2
   ,p_style                           out nocopy varchar2
   ,p_date_from                       out nocopy date
   ,p_date_to                         out nocopy date
   ,p_address_type                    out nocopy varchar2
   ,p_address_type_meaning            out nocopy varchar2
   ,p_comments                        out nocopy varchar2
   ,p_address_line1                   out nocopy varchar2
   ,p_address_line2                   out nocopy varchar2
   ,p_address_line3                   out nocopy varchar2
   ,p_town_or_city                    out nocopy varchar2
   ,p_region_1                        out nocopy varchar2
   ,p_region_2                        out nocopy varchar2
   ,p_region_3                        out nocopy varchar2
   ,p_postal_code                     out nocopy varchar2
   ,p_country                         out nocopy varchar2
   ,p_country_meaning                 out nocopy varchar2
   ,p_telephone_number_1              out nocopy varchar2
   ,p_telephone_number_2              out nocopy varchar2
   ,p_telephone_number_3              out nocopy varchar2
   ,p_addr_attribute_category         out nocopy varchar2
   ,p_addr_attribute1                 out nocopy varchar2
   ,p_addr_attribute2                 out nocopy varchar2
   ,p_addr_attribute3                 out nocopy varchar2
   ,p_addr_attribute4                 out nocopy varchar2
   ,p_addr_attribute5                 out nocopy varchar2
   ,p_addr_attribute6                 out nocopy varchar2
   ,p_addr_attribute7                 out nocopy varchar2
   ,p_addr_attribute8                 out nocopy varchar2
   ,p_addr_attribute9                 out nocopy varchar2
   ,p_addr_attribute10                out nocopy varchar2
   ,p_addr_attribute11                out nocopy varchar2
   ,p_addr_attribute12                out nocopy varchar2
   ,p_addr_attribute13                out nocopy varchar2
   ,p_addr_attribute14                out nocopy varchar2
   ,p_addr_attribute15                out nocopy varchar2
   ,p_addr_attribute16                out nocopy varchar2
   ,p_addr_attribute17                out nocopy varchar2
   ,p_addr_attribute18                out nocopy varchar2
   ,p_addr_attribute19                out nocopy varchar2
   ,p_addr_attribute20                out nocopy varchar2
   ,p_add_information17               out nocopy varchar2
   ,p_add_information18               out nocopy varchar2
   ,p_add_information19               out nocopy varchar2
   ,p_add_information20               out nocopy varchar2
   ,p_action                          out nocopy varchar2
   ,p_old_address_id                  out nocopy varchar2
   ,p_add_information13               out nocopy varchar2
   ,p_add_information14               out nocopy varchar2
   ,p_add_information15               out nocopy varchar2
   ,p_add_information16               out nocopy varchar2
)is

l_proc varchar2(200) := g_package || 'get_address_data_from_tt';

begin

  hr_utility.set_location(' Entering:' || l_proc,5);

--
   p_effective_date:= to_date(
      hr_transaction_ss.get_wf_effective_date
        (p_transaction_step_id => p_transaction_step_id),g_date_format);
--
  p_person_id := hr_transaction_api.get_number_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_PERSON_ID');
--
  p_address_id := hr_transaction_api.get_number_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ADDRESS_ID');
--
  p_object_version_number := hr_transaction_api.get_number_value
    (p_transaction_step_id =>  p_transaction_step_id
    ,p_name                => 'P_OBJECT_VERSION_NUMBER');
--
  p_primary_flag := hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_PRIMARY_FLAG');
-- startregistration anupam
  if p_primary_flag = 'T' then
     p_primary_flag :='N';
  end if;
-- endregistration anupam
--
  p_style := hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_STYLE');

--
  p_date_from :=
    hr_transaction_api.get_date_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_DATE_FROM');
--
  p_date_to :=
    hr_transaction_api.get_date_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_DATE_TO');
--
  p_address_type :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ADDRESS_TYPE_CODE');
--
  p_address_type_meaning :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ADDRESS_TYPE');

--
--   p_comments :=
--    hr_transaction_api.get_varchar2_value
--    (p_transaction_step_id => p_transaction_step_id
--    ,p_name                => 'P_COMMENTS');
--
  p_address_line1 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ADDRESS_LINE1');
--
  p_address_line2 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ADDRESS_LINE2');
--
  p_address_line3 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ADDRESS_LINE3');
--
  p_town_or_city :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_CITY');
--
  p_region_1 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_REGION1');
--
  p_region_2 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_REGION2');
--
  p_region_3 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_REGION3');
--
  p_postal_code :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_POSTAL_CODE');
--
  p_country :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_COUNTRY_CODE');
--
  p_country_meaning :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_COUNTRY');
--
  p_telephone_number_1 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_TELEPHONE_NUMBER1');
--
  p_telephone_number_2 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_TELEPHONE_NUMBER2');
--
  p_telephone_number_3 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_TELEPHONE_NUMBER3');
--
  p_addr_attribute_category :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ADDR_ATTRIBUTE_CATEGORY');
--
  p_addr_attribute1 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ADDR_ATTRIBUTE1');
--
  p_addr_attribute2 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ADDR_ATTRIBUTE2');
--
  p_addr_attribute3 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ADDR_ATTRIBUTE3');
--
  p_addr_attribute4 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ADDR_ATTRIBUTE4');
--
  p_addr_attribute5 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ADDR_ATTRIBUTE5');
--
  p_addr_attribute6 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ADDR_ATTRIBUTE6');
--
  p_addr_attribute7 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ADDR_ATTRIBUTE7');
--
  p_addr_attribute8 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ADDR_ATTRIBUTE8');
--
  p_addr_attribute9 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ADDR_ATTRIBUTE9');
--
  p_addr_attribute10 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ADDR_ATTRIBUTE10');
--
  p_addr_attribute11 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ADDR_ATTRIBUTE11');
--
  p_addr_attribute12 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ADDR_ATTRIBUTE12');
--
  p_addr_attribute13 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ADDR_ATTRIBUTE13');
--
  p_addr_attribute14 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ADDR_ATTRIBUTE14');
--
  p_addr_attribute15 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ADDR_ATTRIBUTE15');
--
  p_addr_attribute16 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ADDR_ATTRIBUTE16');
--
  p_addr_attribute17 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ADDR_ATTRIBUTE17');
--
  p_addr_attribute18 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ADDR_ATTRIBUTE18');
--
  p_addr_attribute19 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ADDR_ATTRIBUTE19');
--
  p_addr_attribute20 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ADDR_ATTRIBUTE20');
--


  p_add_information17 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ADD_INFORMATION17');
--

--
  p_add_information18 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ADD_INFORMATION18');
--
--
  p_add_information19 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ADD_INFORMATION19');
--
--
  p_add_information20 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ADD_INFORMATION20');
--
--
  p_action :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ACTION');
--
  p_old_address_id := hr_transaction_api.get_number_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_OLD_ADDRESS_ID');

 p_add_information13 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ADD_INFORMATION13');
--
  p_add_information14 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ADD_INFORMATION14');
--
  p_add_information15 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ADD_INFORMATION15');
--
  p_add_information16 :=
    hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_ADD_INFORMATION16');
--

hr_utility.set_location(' Leaving:' || l_proc,10);


EXCEPTION
   WHEN OTHERS THEN
   -- Reset OUT parameters for nocopy.

   p_effective_date                  := NULL;
   p_person_id                       := NULL;
   p_address_id                      := NULL;
   p_object_version_number           := NULL;
   p_primary_flag                    := NULL;
   p_style                           := NULL;
   p_date_from                       := NULL;
   p_date_to                         := NULL;
   p_address_type                    := NULL;
   p_address_type_meaning            := NULL;
   p_comments                        := NULL;
   p_address_line1                   := NULL;
   p_address_line2                   := NULL;
   p_address_line3                   := NULL;
   p_town_or_city                    := NULL;
   p_region_1                        := NULL;
   p_region_2                        := NULL;
   p_region_3                        := NULL;
   p_postal_code                     := NULL;
   p_country                         := NULL;
   p_country_meaning                 := NULL;
   p_telephone_number_1              := NULL;
   p_telephone_number_2              := NULL;
   p_telephone_number_3              := NULL;
   p_addr_attribute_category         := NULL;
   p_addr_attribute1                 := NULL;
   p_addr_attribute2                 := NULL;
   p_addr_attribute3                 := NULL;
   p_addr_attribute4                 := NULL;
   p_addr_attribute5                 := NULL;
   p_addr_attribute6                 := NULL;
   p_addr_attribute7                 := NULL;
   p_addr_attribute8                 := NULL;
   p_addr_attribute9                 := NULL;
   p_addr_attribute10                := NULL;
   p_addr_attribute11                := NULL;
   p_addr_attribute12                := NULL;
   p_addr_attribute13                := NULL;
   p_addr_attribute14                := NULL;
   p_addr_attribute15                := NULL;
   p_addr_attribute16                := NULL;
   p_addr_attribute17                := NULL;
   p_addr_attribute18                := NULL;
   p_addr_attribute19                := NULL;
   p_addr_attribute20                := NULL;
   p_add_information13               := NULL;
   p_add_information14               := NULL;
   p_add_information15               := NULL;
   p_add_information16               := NULL;
   p_add_information17               := NULL;
   p_add_information18               := NULL;
   p_add_information19               := NULL;
   p_add_information20               := NULL;
   p_action                          := NULL;
   p_old_address_id                  := NULL;
   hr_utility.set_location(' Leaving:' || l_proc,555);

      RAISE;

END get_address_data_from_tt;

/*---------------------------------------------------------------------------+
|                                                                            |
|       Name           : process_api                                         |
|                                                                            |
|       Purpose        : This will procedure is invoked whenever approver    |
|                        approves the address change.                        |
|                                                                            |
+-----------------------------------------------------------------------------*/
PROCEDURE process_api
(p_validate                 in     boolean default false
,p_transaction_step_id      in     number
,p_effective_date           in     varchar2 default null
)
IS

l_proc varchar2(200) := g_package || 'process_api';
l_user_date_format      varchar2(200);
l_validate BOOLEAN := true; l_old_ovn NUMBER; l_ovn NUMBER;
l_old_address_id per_addresses.address_id%TYPE;
l_action VARCHAR2(100); l_effective_date date;
l_address per_addresses%ROWTYPE;
l_pradd_ovrlap BOOLEAN := FALSE;
l_contact_or_person varchar2(100);
l_check_for_sfl varchar2(10);
l_sfl_g_contact_step_id NUMBER;

BEGIN
        hr_utility.set_location(' Entering:' || l_proc,5);
        if (p_effective_date is not null) then
	   hr_utility.set_location( l_proc, 10);
           l_effective_date:= to_date(p_effective_date,g_date_format);
        else
	   hr_utility.set_location( l_proc, 15);
           l_effective_date:= to_date(
               hr_transaction_ss.get_wf_effective_date
                 (p_transaction_step_id => p_transaction_step_id),g_date_format);
        end if;

        -- ------------------------------------------------------------
        -- get user date format
        -- ------------------------------------------------------------
        -- This call is causing an implicit commit and not being used at all
        -- commenting the method call
        -- l_user_date_format := hr_util_misc_web.get_user_date_format;

        l_address.object_version_number :=
                hr_transaction_api.get_number_value
                (p_Transaction_step_id => p_transaction_step_id
                ,p_name => 'P_OBJECT_VERSION_NUMBER');

        l_old_ovn :=
                hr_transaction_api.get_number_value
                (p_Transaction_step_id => p_transaction_step_id
                ,p_name => 'P_OLD_OBJECT_VERSION_NUMBER');

        l_Address.address_id :=
                hr_transaction_api.get_number_value
                (p_Transaction_step_id => p_transaction_step_id
                ,p_name => 'P_ADDRESS_ID');

        l_old_address_id :=
                hr_transaction_api.get_number_value
                (p_Transaction_step_id => p_transaction_step_id
                ,p_name => 'P_OLD_ADDRESS_ID');

        l_action :=
                hr_transaction_api.get_varchar2_value
                (p_Transaction_step_id => p_transaction_step_id
                ,p_name => 'P_ACTION');

        IF      hr_transaction_api.get_varchar2_value
                (p_Transaction_step_id => p_transaction_step_id
                ,p_name => 'P_PRADD_OVLAPVAL_OVERRIDE') = 'Y' THEN
		hr_utility.set_location( l_proc, 20);
                l_pradd_ovrlap := TRUE;
        ELSE
	        hr_utility.set_location( l_proc, 25);
                l_pradd_ovrlap := FALSE;
        END IF;


        l_address.date_from :=
                (hr_transaction_api.get_date_value
                (p_Transaction_step_id => p_transaction_step_id
                ,p_name => 'P_DATE_FROM'));

        l_address.date_to :=
                (hr_transaction_api.get_date_value
                (p_Transaction_step_id => p_transaction_step_id
                ,p_name => 'P_DATE_TO'));

        l_address.person_id :=
                hr_transaction_api.get_number_value
                (p_Transaction_step_id =>
                        p_transaction_step_id
                ,p_name => 'P_PERSON_ID');
        --
        -- PB :
        --
        if l_address.person_id is null or l_address.person_id < 0 then
	   hr_utility.set_location( l_proc, 30);
           --
           -- This is the case where the contact and address are created.
           -- So get contact person id from the global which is set by
           -- hrconwrs.pkb.
           --
           -- StartRegistration
           --
           l_contact_or_person :=
                hr_transaction_api.get_varchar2_value
                (p_Transaction_step_id => p_transaction_step_id
                ,p_name => 'P_CONTACT_OR_PERSON');
           --
    if l_contact_or_person = 'CONTACT' or l_contact_or_person = 'EMER_CR_NEW_CONT' or l_contact_or_person = 'EMRG_OVRW_UPD' or l_contact_or_person = 'EMRG_OVRW_DEL' or  l_contact_or_person = 'EMER_CR_NEW_REL'
          or  l_contact_or_person = 'DPDNT_CR_NEW_CONT' or  l_contact_or_person = 'DPDNT_OVRW_UPD'  or  l_contact_or_person = 'DPDNT_OVRW_DEL' or  l_contact_or_person = 'DPDNT_CR_NEW_REL'       then
	  hr_utility.set_location( l_proc, 35);
              --
              l_address.person_id := hr_process_contact_ss.g_contact_person_id;
              --
           -- In case of SaveForLater run process_create_contact_api
           -- in commit mode to get the g_contact_person_id
           -- this will be rolled back with the current step
           -- after validating the current transaction step

           BEGIN

              select 'NOT_SFL'
              into l_check_for_sfl
              from per_all_people_f
              where person_id =l_address.person_id;

           EXCEPTION
              WHEN no_data_found THEN
	        hr_utility.set_location( l_proc || 'EXCEPTION' , 555);
                l_check_for_sfl := 'SFL';
           END;


           IF  l_check_for_sfl = 'SFL' THEN
              hr_utility.set_location( l_proc, 40);
              hr_utility.set_location('Address: process_api: It is a save for later step' , 1234);
              hr_utility.set_location('g_contact_person_id before :'||hr_process_contact_ss.g_contact_person_id , 1234);

              BEGIN
                    select nvl(hats1.transaction_step_id,0)
                    into   l_sfl_g_contact_step_id
                    from   hr_api_transaction_steps hats1
                    where  hats1.item_type   = 'HRSSA'
                    and    hats1.item_key    =
                               (select hats2.item_key
                                from   hr_api_transaction_steps hats2
                                where  hats2.item_type   = 'HRSSA'
	                            and    hats2.transaction_step_id = p_transaction_step_id )
                    and    hats1.api_name = 'HR_PROCESS_CONTACT_SS.PROCESS_CREATE_CONTACT_API';



                    HR_PROCESS_CONTACT_SS.process_create_contact_api (
                        p_transaction_step_id => l_sfl_g_contact_step_id
                        );

                    l_address.person_id := hr_process_contact_ss.g_contact_person_id;
                    hr_utility.set_location('g_contact_person_id after :'||hr_process_contact_ss.g_contact_person_id , 1234);
              EXCEPTION
                    WHEN others THEN
		    hr_utility.set_location( l_proc || 'EXCEPTION' , 565);
                    null;
              END;
           END IF;

           else -- for person PERSON
	      hr_utility.set_location( l_proc, 45);
              --
              -- StartRegistration : For Create person and address in one
              -- transaction get person id from the package global.
              --
              -- adding the session id check to avoid connection pooling problems.
              /* l_address.person_id := hr_process_person_ss.g_person_id; */
              if (( hr_process_person_ss.g_person_id is not null) and
                              (hr_process_person_ss.g_session_id= ICX_SEC.G_SESSION_ID)) then
			      hr_utility.set_location( l_proc, 50);
               l_address.person_id := hr_process_person_ss.g_person_id;
              --
              end if;
              --
           end if;
           --
        end if;
        --
        l_address.primary_flag :=
                hr_transaction_api.get_varchar2_value
                (p_Transaction_step_id => p_transaction_step_id
                ,p_name => 'P_PRIMARY_FLAG');
        -- startregistration anupam
        -- For tertiary address from overview page we have T for primary flag
        -- it should be changed to N in the database.
        if l_address.primary_flag = 'T' then
	    hr_utility.set_location( l_proc, 55);
            l_address.primary_flag := 'N';
        end if;
        -- endregistration anupam


        l_Address.style :=
                hr_transaction_api.get_varchar2_value
                (p_Transaction_step_id => p_transaction_step_id
                ,p_name => 'P_STYLE');
        l_address.address_type :=
                hr_transaction_api.get_varchar2_value
                (p_Transaction_step_id => p_transaction_step_id
                ,p_name => 'P_ADDRESS_TYPE_CODE');
        l_Address.address_line1 :=
                hr_transaction_api.get_varchar2_value
                (p_Transaction_step_id => p_transaction_step_id
                ,p_name => 'P_ADDRESS_LINE1');
        l_Address.address_line2 :=
                hr_transaction_api.get_varchar2_value
                (p_Transaction_step_id => p_transaction_step_id
                ,p_name => 'P_ADDRESS_LINE2');
        l_Address.address_line3 :=
                hr_transaction_api.get_varchar2_value
                (p_Transaction_step_id => p_transaction_step_id
                ,p_name => 'P_ADDRESS_LINE3');
        l_address.town_or_city :=
                hr_transaction_api.get_varchar2_value
                (p_Transaction_step_id => p_transaction_step_id
                ,p_name => 'P_CITY');
        l_address.region_1 :=
                hr_transaction_api.get_varchar2_value
                (p_Transaction_step_id => p_transaction_step_id
                ,p_name => 'P_REGION1');
        l_address.region_2 :=
                hr_transaction_api.get_varchar2_value
                (p_Transaction_step_id => p_transaction_step_id
                ,p_name => 'P_REGION2');
        l_address.region_3 :=
                hr_transaction_api.get_varchar2_value
                (p_Transaction_step_id => p_transaction_step_id
                ,p_name => 'P_REGION3');
        l_address.postal_code :=
                hr_transaction_api.get_varchar2_value
                (p_Transaction_step_id => p_transaction_step_id
                ,p_name => 'P_POSTAL_CODE');
        l_address.country :=
                hr_transaction_api.get_varchar2_value
                (p_Transaction_step_id => p_transaction_step_id
                ,p_name => 'P_COUNTRY_CODE');
        l_address.telephone_number_1 :=
                hr_transaction_api.get_varchar2_value
                (p_Transaction_step_id => p_transaction_step_id
                ,p_name => 'P_TELEPHONE_NUMBER1');
        l_address.telephone_number_2 :=
                hr_transaction_api.get_varchar2_value
                (p_Transaction_step_id => p_transaction_step_id
                ,p_name => 'P_TELEPHONE_NUMBER2');
        l_address.telephone_number_3 :=
                hr_transaction_api.get_varchar2_value
                (p_Transaction_step_id => p_transaction_step_id
                ,p_name => 'P_TELEPHONE_NUMBER3');

-- Now get all the Descriptive Flex fields
        l_address.addr_attribute_category :=
                hr_transaction_api.get_varchar2_value
                (p_Transaction_step_id => p_transaction_step_id
                ,p_name => 'P_ADDR_ATTRIBUTE_CATEGORY');
        l_address.addr_attribute1 :=
                hr_transaction_api.get_varchar2_value
                (p_Transaction_step_id => p_transaction_step_id
                ,p_name => 'P_ADDR_ATTRIBUTE1');
        l_address.addr_attribute2 :=
                hr_transaction_api.get_varchar2_value
                (p_Transaction_step_id => p_transaction_step_id
                ,p_name => 'P_ADDR_ATTRIBUTE2');
        l_address.addr_attribute3 :=
                hr_transaction_api.get_varchar2_value
                (p_Transaction_step_id => p_transaction_step_id
                ,p_name => 'P_ADDR_ATTRIBUTE3');
        l_address.addr_attribute4 :=
                hr_transaction_api.get_varchar2_value
                (p_Transaction_step_id => p_transaction_step_id
                ,p_name => 'P_ADDR_ATTRIBUTE4');
        l_address.addr_attribute5 :=
                hr_transaction_api.get_varchar2_value
                (p_Transaction_step_id => p_transaction_step_id
                ,p_name => 'P_ADDR_ATTRIBUTE5');
        l_address.addr_attribute6 :=
                hr_transaction_api.get_varchar2_value
                (p_Transaction_step_id => p_transaction_step_id
                ,p_name => 'P_ADDR_ATTRIBUTE6');
        l_address.addr_attribute7 :=
                hr_transaction_api.get_varchar2_value
                (p_Transaction_step_id => p_transaction_step_id
                ,p_name => 'P_ADDR_ATTRIBUTE7');
        l_address.addr_attribute8 :=
                hr_transaction_api.get_varchar2_value
                (p_Transaction_step_id => p_transaction_step_id
                ,p_name => 'P_ADDR_ATTRIBUTE8');
        l_address.addr_attribute9 :=
                hr_transaction_api.get_varchar2_value
                (p_Transaction_step_id => p_transaction_step_id
                ,p_name => 'P_ADDR_ATTRIBUTE9');
        l_address.addr_attribute10 :=
                hr_transaction_api.get_varchar2_value
                (p_Transaction_step_id => p_transaction_step_id
                ,p_name => 'P_ADDR_ATTRIBUTE10');
        l_address.addr_attribute11 :=
                hr_transaction_api.get_varchar2_value
                (p_Transaction_step_id => p_transaction_step_id
                ,p_name => 'P_ADDR_ATTRIBUTE11');
        l_address.addr_attribute12 :=
                hr_transaction_api.get_varchar2_value
                (p_Transaction_step_id => p_transaction_step_id
                ,p_name => 'P_ADDR_ATTRIBUTE12');
        l_address.addr_attribute13 :=
                hr_transaction_api.get_varchar2_value
                (p_Transaction_step_id => p_transaction_step_id
                ,p_name => 'P_ADDR_ATTRIBUTE13');
        l_address.addr_attribute14 :=
                hr_transaction_api.get_varchar2_value
                (p_Transaction_step_id => p_transaction_step_id
                ,p_name => 'P_ADDR_ATTRIBUTE14');
        l_address.addr_attribute15 :=
                hr_transaction_api.get_varchar2_value
                (p_Transaction_step_id => p_transaction_step_id
                ,p_name => 'P_ADDR_ATTRIBUTE15');
        l_address.addr_attribute16 :=
                hr_transaction_api.get_varchar2_value
                (p_Transaction_step_id => p_transaction_step_id
                ,p_name => 'P_ADDR_ATTRIBUTE16');
        l_address.addr_attribute17 :=
                hr_transaction_api.get_varchar2_value
                (p_Transaction_step_id => p_transaction_step_id
                ,p_name => 'P_ADDR_ATTRIBUTE17');
        l_address.addr_attribute18 :=
                hr_transaction_api.get_varchar2_value
                (p_Transaction_step_id => p_transaction_step_id
                ,p_name => 'P_ADDR_ATTRIBUTE18');
        l_address.addr_attribute19 :=
                hr_transaction_api.get_varchar2_value
                (p_Transaction_step_id => p_transaction_step_id
                ,p_name => 'P_ADDR_ATTRIBUTE19');
        l_address.addr_attribute20 :=
                hr_transaction_api.get_varchar2_value
                (p_Transaction_step_id => p_transaction_step_id
                ,p_name => 'P_ADDR_ATTRIBUTE20');
        l_address.add_information17 :=
                hr_transaction_api.get_varchar2_value
                (p_Transaction_step_id => p_transaction_step_id
                ,p_name => 'P_ADD_INFORMATION17');
        l_address.add_information18 :=
                hr_transaction_api.get_varchar2_value
                (p_Transaction_step_id => p_transaction_step_id
                ,p_name => 'P_ADD_INFORMATION18');
        l_address.add_information19 :=
                hr_transaction_api.get_varchar2_value
                (p_Transaction_step_id => p_transaction_step_id
                ,p_name => 'P_ADD_INFORMATION19');
        l_address.add_information20 :=
                hr_transaction_api.get_varchar2_value
                (p_Transaction_step_id => p_transaction_step_id
                ,p_name => 'P_ADD_INFORMATION20');
        l_address.add_information13 :=
                hr_transaction_api.get_varchar2_value
                (p_Transaction_step_id => p_transaction_step_id
                ,p_name => 'P_ADD_INFORMATION13');
        l_address.add_information14 :=
                hr_transaction_api.get_varchar2_value
                (p_Transaction_step_id => p_transaction_step_id
                ,p_name => 'P_ADD_INFORMATION14');
        l_address.add_information15 :=
                hr_transaction_api.get_varchar2_value
                (p_Transaction_step_id => p_transaction_step_id
                ,p_name => 'P_ADD_INFORMATION15');
        l_address.add_information16 :=
                hr_transaction_api.get_varchar2_value
                (p_Transaction_step_id => p_transaction_step_id
                ,p_name => 'P_ADD_INFORMATION16');


        IF UPPER(l_action) = 'CHANGE' THEN
                IF UPPER(l_address.primary_flag) like 'N%' THEN
		hr_utility.set_location( l_proc, 60);
                hr_person_address_api.update_person_address
                        (p_validate => false
                        ,p_effective_date => l_effective_date
                        ,p_address_id => l_old_address_id
                        ,p_object_version_number => l_old_ovn
                        ,p_date_to => l_Address.date_to);
                END IF;
                -- Now enter the new address.
                hr_person_address_api.create_person_address
                        (p_validate => false
                        ,p_effective_date => l_effective_date
                        ,p_person_id => l_address.person_id
                        ,p_primary_flag =>  l_address.primary_flag
                        ,p_style =>  l_address.style
                        ,p_date_from => l_effective_date
                        ,p_address_type => l_address.address_type
                        ,p_address_line1 => l_address.address_line1
                        ,p_address_line2 => l_address.address_line2
                        ,p_address_line3 => l_address.address_line3
                        ,p_town_or_city =>  l_address.town_or_city
                        ,p_region_1 =>  l_address.region_1
                        ,p_region_2 =>  l_address.region_2
                        ,p_region_3 =>  l_address.region_3
                        ,p_postal_code =>  l_Address.postal_code
                        ,p_country => l_address.country
                        ,p_address_id => l_Address.address_id
                        ,p_object_Version_number =>
                                l_address.object_version_number
                        ,p_telephone_number_1 => l_address.telephone_number_1
                        ,p_telephone_number_2 => l_address.telephone_number_2
                        ,p_telephone_number_3 => l_address.telephone_number_3
                        ,p_pradd_ovlapval_override => l_pradd_ovrlap
                        ,p_addr_attribute_category => l_address.addr_attribute_category
                        ,p_addr_attribute1         => l_address.addr_attribute1
                        ,p_addr_attribute2         => l_address.addr_attribute2
                        ,p_addr_attribute3         => l_address.addr_attribute3
                        ,p_addr_attribute4         => l_address.addr_attribute4
                        ,p_addr_attribute5         => l_address.addr_attribute5
                        ,p_addr_attribute6         => l_address.addr_attribute6
                        ,p_addr_attribute7         => l_address.addr_attribute7
                        ,p_addr_attribute8         => l_address.addr_attribute8
                        ,p_addr_attribute9         => l_address.addr_attribute9
                        ,p_addr_attribute10        => l_address.addr_attribute10
                        ,p_addr_attribute11        => l_address.addr_attribute11
                        ,p_addr_attribute12        => l_address.addr_attribute12
                        ,p_addr_attribute13        => l_address.addr_attribute13
                        ,p_addr_attribute14        => l_address.addr_attribute14
                        ,p_addr_attribute15        => l_address.addr_attribute15
                        ,p_addr_attribute16        => l_address.addr_attribute16
                        ,p_addr_attribute17        => l_address.addr_attribute17
                        ,p_addr_attribute18        => l_address.addr_attribute18
                        ,p_addr_attribute19        => l_address.addr_attribute19
                        ,p_addr_attribute20        => l_address.addr_attribute20
                        ,p_add_information13       => l_address.add_information13
                        ,p_add_information14       => l_address.add_information14
                        ,p_add_information15       => l_address.add_information15
                        ,p_add_information16       => l_address.add_information16
                        ,p_add_information17       => l_address.add_information17
                        ,p_add_information18       => l_address.add_information18
                        ,p_add_information19       => l_address.add_information19
                        ,p_add_information20       => l_address.add_information20);
        ELSIF UPPER(l_action) = 'CORRECT' THEN --Bug#3114508 start
	hr_utility.set_location( l_proc, 65);
           if (hr_process_contact_ss.g_is_address_updated = true) then
              l_address.object_version_number := l_address.object_version_number + 1;
           end if;
                hr_person_address_api.update_pers_addr_with_style --Bug#3114508 end
                        (p_validate => false
                        ,p_effective_date => trunc(sysdate)
                        ,p_address_type => l_address.address_type
                        ,p_address_line1 => l_address.address_line1
                        ,p_address_line2 => l_address.address_line2
                        ,p_address_line3 => l_address.address_line3
                        ,p_town_or_city =>  l_address.town_or_city
                        ,p_region_1 =>  l_address.region_1
                        ,p_region_2 =>  l_address.region_2
                        ,p_region_3 =>  l_address.region_3
                        ,p_postal_code =>  l_Address.postal_code
                        ,p_country => l_address.country  --Bug#3114508 start
                        ,p_style   => l_Address.style --Bug#3114508 end
                        ,p_address_id => l_Address.address_id
                        ,p_object_version_number =>
                                l_address.object_version_number
                        ,p_telephone_number_1 => l_address.telephone_number_1
                        ,p_telephone_number_2 => l_address.telephone_number_2
                        ,p_telephone_number_3 => l_address.telephone_number_3
                        ,p_addr_attribute_category => l_address.addr_attribute_category
                        ,p_addr_attribute1         => l_address.addr_attribute1
                        ,p_addr_attribute2         => l_address.addr_attribute2
                        ,p_addr_attribute3         => l_address.addr_attribute3
                        ,p_addr_attribute4         => l_address.addr_attribute4
                        ,p_addr_attribute5         => l_address.addr_attribute5
                        ,p_addr_attribute6         => l_address.addr_attribute6
                        ,p_addr_attribute7         => l_address.addr_attribute7
                        ,p_addr_attribute8         => l_address.addr_attribute8
                        ,p_addr_attribute9         => l_address.addr_attribute9
                        ,p_addr_attribute10        => l_address.addr_attribute10
                        ,p_addr_attribute11        => l_address.addr_attribute11
                        ,p_addr_attribute12        => l_address.addr_attribute12
                        ,p_addr_attribute13        => l_address.addr_attribute13
                        ,p_addr_attribute14        => l_address.addr_attribute14
                        ,p_addr_attribute15        => l_address.addr_attribute15
                        ,p_addr_attribute16        => l_address.addr_attribute16
                        ,p_addr_attribute17        => l_address.addr_attribute17
                        ,p_addr_attribute18        => l_address.addr_attribute18
                        ,p_addr_attribute19        => l_address.addr_attribute19
                        ,p_addr_attribute20        => l_address.addr_attribute20
                        ,p_add_information13       => l_address.add_information13
                        ,p_add_information14       => l_address.add_information14
                        ,p_add_information15       => l_address.add_information15
                        ,p_add_information16       => l_address.add_information16
                        ,p_add_information17       => l_address.add_information17
                        ,p_add_information18       => l_address.add_information18
                        ,p_add_information19       => l_address.add_information19
                        ,p_add_information20       => l_address.add_information20);
           hr_process_contact_ss.g_is_address_updated := false;
        ELSIF UPPER(l_action) = 'DELETE' THEN
		hr_utility.set_location( l_proc, 70);
                hr_person_address_api.update_person_address
                (p_validate => false
                ,p_address_id => l_address.address_id
                ,p_object_version_number => l_address.object_version_number
                ,p_effective_date => l_effective_date
                ,p_date_from => l_address.date_from
                ,p_date_to => l_address.date_to);
        ELSIF UPPER(l_action) = 'NEW' THEN
		hr_utility.set_location( l_proc, 75);
                hr_person_address_api.create_person_address
                        (p_validate => false
                        ,p_effective_date => l_effective_date
                        ,p_person_id => l_address.person_id
                        ,p_primary_flag => l_address.primary_flag
                        ,p_style => l_address.style
                        ,p_date_from => l_effective_date
                        ,p_address_type => l_address.address_type
                        ,p_address_line1 => l_address.address_line1
                        ,p_address_line2 => l_address.address_line2
                        ,p_address_line3 => l_address.address_line3
                        ,p_town_or_city => l_address.town_or_city
                        ,p_region_1 => l_address.region_1
                        ,p_region_2 => l_address.region_2
                        ,p_region_3 => l_address.region_3
                        ,p_postal_code => l_address.postal_code
                        ,p_country => l_address.country
                        ,p_address_id => l_address.address_id
                        ,p_object_Version_number =>
                                l_address.object_version_number
                        ,p_telephone_number_1 => l_address.telephone_number_1
                        ,p_telephone_number_2 => l_address.telephone_number_2
                        ,p_telephone_number_3 => l_address.telephone_number_3
                        ,p_addr_attribute_category => l_address.addr_attribute_category
                        ,p_addr_attribute1         => l_address.addr_attribute1
                        ,p_addr_attribute2         => l_address.addr_attribute2
                        ,p_addr_attribute3         => l_address.addr_attribute3
                        ,p_addr_attribute4         => l_address.addr_attribute4
                        ,p_addr_attribute5         => l_address.addr_attribute5
                        ,p_addr_attribute6         => l_address.addr_attribute6
                        ,p_addr_attribute7         => l_address.addr_attribute7
                        ,p_addr_attribute8         => l_address.addr_attribute8
                        ,p_addr_attribute9         => l_address.addr_attribute9
                        ,p_addr_attribute10        => l_address.addr_attribute10
                        ,p_addr_attribute11        => l_address.addr_attribute11
                        ,p_addr_attribute12        => l_address.addr_attribute12
                        ,p_addr_attribute13        => l_address.addr_attribute13
                        ,p_addr_attribute14        => l_address.addr_attribute14
                        ,p_addr_attribute15        => l_address.addr_attribute15
                        ,p_addr_attribute16        => l_address.addr_attribute16
                        ,p_addr_attribute17        => l_address.addr_attribute17
                        ,p_addr_attribute18        => l_address.addr_attribute18
                        ,p_addr_attribute19        => l_address.addr_attribute19
                        ,p_addr_attribute20        => l_address.addr_attribute20
                        ,p_add_information13       => l_address.add_information13
                        ,p_add_information14       => l_address.add_information14
                        ,p_add_information15       => l_address.add_information15
                        ,p_add_information16       => l_address.add_information16
                        ,p_add_information17       => l_address.add_information17
                        ,p_add_information18       => l_address.add_information18
                        ,p_add_information19       => l_address.add_information19
                        ,p_add_information20       => l_address.add_information20);
        END IF;

	hr_utility.set_location(' Leaving:' || l_proc,80);

END process_api;

END hr_process_address_ss;

/

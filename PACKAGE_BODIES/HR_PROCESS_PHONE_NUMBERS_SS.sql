--------------------------------------------------------
--  DDL for Package Body HR_PROCESS_PHONE_NUMBERS_SS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_PROCESS_PHONE_NUMBERS_SS" AS
 /* $Header: hrphnwrs.pkb 120.0 2005/05/31 02:10:29 appldev noship $*/

   g_package      varchar2(30)   := 'HR_PROCESS_PHONE_NUMBERS_SS';
   l_result                     varchar2(100) default null;
   g_save_transaction_error exception;

/*
||===========================================================================
|| PROCEDURE: save_transaction
||---------------------------------------------------------------------------
||
|| Description: Common procedure to save transaction
*/

procedure save_transaction(
    p_phone_id in number
  , p_item_type in varchar2
  , p_item_key  in varchar2
  , p_activity_id in number
  , p_date_from  in date default trunc(sysdate)
  , p_phone_type in varchar2
  , p_phone_number in varchar2
  , p_parent_id in number
  , p_parent_table in VARCHAR2 default 'PER_ALL_PEOPLE_F'
  , p_login_person_id  in NUMBER
  , p_per_or_contact in varchar2 default null
  , p_contact_set in varchar2 default '1'
  , p_effective_date in date default trunc(sysdate)
  , p_object_version_number in number
  , p_phone_type_meaning  in varchar2
  , p_attribute_category  in varchar2 default null
  , p_attribute1 in varchar2 default null
  , p_attribute2 in varchar2 default null
  , p_attribute3 in varchar2 default null
  , p_attribute4 in varchar2 default null
  , p_attribute5 in varchar2 default null
  , p_attribute6 in varchar2 default null
  , p_attribute7 in varchar2 default null
  , p_attribute8 in varchar2 default null
  , p_attribute9 in varchar2 default null
  , p_attribute10 in varchar2 default null
  , p_attribute11 in varchar2 default null
  , p_attribute12 in varchar2 default null
  , p_attribute13 in varchar2 default null
  , p_attribute14 in varchar2 default null
  , p_attribute15 in varchar2 default null
  , p_attribute16 in varchar2 default null
  , p_attribute17 in varchar2 default null
  , p_attribute18 in varchar2 default null
  , p_attribute19 in varchar2 default null
  , p_attribute20 in varchar2 default null
  , p_attribute21 in varchar2 default null
  , p_attribute22 in varchar2 default null
  , p_attribute23 in varchar2 default null
  , p_attribute24 in varchar2 default null
  , p_attribute25 in varchar2 default null
  , p_attribute26 in varchar2 default null
  , p_attribute27 in varchar2 default null
  , p_attribute28 in varchar2 default null
  , p_attribute29 in varchar2 default null
  , p_attribute30 in varchar2 default null
  , p_error_message  out nocopy varchar2
  , p_contact_relationship_id       in number           default hr_api.g_number
)
as
  l_transaction_id             number default null;
  l_transaction_step_id        number default null;
  l_trans_obj_vers_num         number default null;
  l_count                      integer default 0;
  l_transaction_table hr_transaction_ss.transaction_table;
  l_review_item_name  varchar2(50);
  l_proc   varchar2(72)  := g_package||'save_transaction';

begin
  --
  -- First, check if transaction id exists or not
  hr_utility.set_location('Entering:'||l_proc, 5);
  l_transaction_id := hr_transaction_ss.get_transaction_id
                     (p_item_type   => p_item_type
                     ,p_item_key    => p_item_key);
  --
  IF l_transaction_id is null THEN
     -- Start a Transaction
        hr_utility.set_location('l_transaction_id is null THEN:'||l_proc,10);
        hr_transaction_ss.start_transaction
           (itemtype   => p_item_type
           ,itemkey    => p_item_key
           ,actid      => p_activity_id
           ,funmode    => 'RUN'
           ,p_api_addtnl_info => p_per_or_contact
           ,p_login_person_id => nvl(p_login_person_id, p_parent_id)
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
     ,p_creator_person_id     => nvl(p_login_person_id, p_parent_id)
     ,p_transaction_id        => l_transaction_id
     ,p_api_name              => g_package || '.PROCESS_API'
     ,p_item_type             => p_item_type
     ,p_item_key              => p_item_key
     ,p_activity_id           => p_activity_id
     ,p_transaction_step_id   => l_transaction_step_id
     ,p_object_version_number => l_trans_obj_vers_num);
  --
  l_count := 1;
  l_transaction_table(l_count).param_name := 'P_PERSON_ID';
  l_transaction_table(l_count).param_value := p_parent_id;
  l_transaction_table(l_count).param_data_type := 'NUMBER';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_PHONE_ID';
  l_transaction_table(l_count).param_value := p_phone_id;
  l_transaction_table(l_count).param_data_type := 'NUMBER';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_PHONE_TYPE';
  l_transaction_table(l_count).param_value := p_phone_type;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_PHONE_TYPE_MEANING';
  l_transaction_table(l_count).param_value := p_phone_type_meaning;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_PHONE_NUMBER';
  l_transaction_table(l_count).param_value := p_phone_number;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_OBJECT_VERSION_NUMBER';
  l_transaction_table(l_count).param_value := p_object_version_number;
  l_transaction_table(l_count).param_data_type := 'NUMBER';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_DATE_FROM';
  l_transaction_table(l_count).param_value :=  to_char(p_date_from,
                                               hr_transaction_ss.g_date_format);
  l_transaction_table(l_count).param_data_type := 'DATE';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_EFFECTIVE_DATE';
  l_transaction_table(l_count).param_value := to_char(p_effective_date,
                                              hr_transaction_ss.g_date_format);
  l_transaction_table(l_count).param_data_type := 'DATE';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_PARENT_TABLE';
  l_transaction_table(l_count).param_value := p_parent_table;
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
  hr_utility.set_location('Exiting:'||l_proc, 15);
  EXCEPTION
  WHEN OTHERS THEN
    hr_utility.set_location('Exception:Others'||l_proc,555);
    l_review_item_name := 'HrPhoneNumbersReview';
  END;

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_REVIEW_PROC_CALL';
  l_transaction_table(l_count).param_value := l_review_item_name;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  -- Dff fields start
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE_CATEGORY';
  l_transaction_table(l_count).param_value := p_attribute_category;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE1';
  l_transaction_table(l_count).param_value := p_attribute1;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE2';
  l_transaction_table(l_count).param_value := p_attribute2;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE3';
  l_transaction_table(l_count).param_value := p_attribute3;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE4';
  l_transaction_table(l_count).param_value := p_attribute4;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE5';
  l_transaction_table(l_count).param_value := p_attribute5;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE6';
  l_transaction_table(l_count).param_value := p_attribute6;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE7';
  l_transaction_table(l_count).param_value := p_attribute7;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE8';
  l_transaction_table(l_count).param_value := p_attribute8;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE9';
  l_transaction_table(l_count).param_value := p_attribute9;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE10';
  l_transaction_table(l_count).param_value := p_attribute10;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE11';
  l_transaction_table(l_count).param_value := p_attribute11;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE12';
  l_transaction_table(l_count).param_value := p_attribute12;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE13';
  l_transaction_table(l_count).param_value := p_attribute13;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE14';
  l_transaction_table(l_count).param_value := p_attribute14;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE15';
  l_transaction_table(l_count).param_value := p_attribute15;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE16';
  l_transaction_table(l_count).param_value := p_attribute16;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE17';
  l_transaction_table(l_count).param_value := p_attribute17;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE18';
  l_transaction_table(l_count).param_value := p_attribute18;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE19';
  l_transaction_table(l_count).param_value := p_attribute19;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE20';
  l_transaction_table(l_count).param_value := p_attribute20;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE21';
  l_transaction_table(l_count).param_value := p_attribute21;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE22';
  l_transaction_table(l_count).param_value := p_attribute22;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE23';
  l_transaction_table(l_count).param_value := p_attribute23;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE24';
  l_transaction_table(l_count).param_value := p_attribute24;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE25';
  l_transaction_table(l_count).param_value := p_attribute25;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE26';
  l_transaction_table(l_count).param_value := p_attribute26;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE27';
  l_transaction_table(l_count).param_value := p_attribute27;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE28';
  l_transaction_table(l_count).param_value := p_attribute28;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE29';
  l_transaction_table(l_count).param_value := p_attribute29;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE30';
  l_transaction_table(l_count).param_value := p_attribute30;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  -- Dff fields end

  -- Contact specific start
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_PER_OR_CONTACT';
  l_transaction_table(l_count).param_value := p_per_or_contact;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_CONTACT_SET';
  l_transaction_table(l_count).param_value := p_contact_set;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';

  if (p_contact_relationship_id > 0 ) then
    hr_utility.set_location('p_contact_relationship_id > 0:'||l_proc,25);
    l_count := l_count + 1;
    l_transaction_table(l_count).param_name := 'P_CONTACT_RELATIONSHIP_ID';
    l_transaction_table(l_count).param_value := p_contact_relationship_id;
    l_transaction_table(l_count).param_data_type := 'NUMBER';
  end if;
  -- Contact specific end


  hr_transaction_ss.save_transaction_step
                (p_item_type => p_item_type
                ,p_item_key => p_item_key
                ,p_actid => p_activity_id
                ,p_login_person_id => nvl(p_login_person_id, p_parent_id)
                ,p_transaction_step_id => l_transaction_step_id
                ,p_api_name => g_package || '.PROCESS_API'
                ,p_transaction_data => l_transaction_table);

  EXCEPTION
  WHEN OTHERS THEN
    hr_utility.set_location('Exception:Others'||l_proc,555);
    p_error_message := hr_java_conv_util_ss.get_formatted_error_message(
                             p_error_message => p_error_message);

 end save_transaction;

  /*
  ||===========================================================================
  || PROCEDURE: create_phone
  ||---------------------------------------------------------------------------
  ||
  || Description:
  || Description:
  ||     This procedure will call the actual API -
  ||                hr_phone_api.create_phone()
  ||
  || Pre Conditions:
  ||
  || In Arguments:
  ||     Contains entire list of parameters that are defined in the actual
  ||     API. For details see pephnapi.pkb file.
  ||
  || out nocopy Arguments:
  ||
  || In out nocopy Arguments:
  ||
  || Post Success:
  ||     Executes the API call.
  ||
  || Post Failure:
  ||     Raises an exception
  ||
  || Access Status:
  ||     Public.
  ||
  ||===========================================================================
  */

  procedure create_phone(p_date_from  date
    , p_date_to  date default null
    , p_phone_type  VARCHAR2
    , p_phone_number  VARCHAR2
    , p_parent_id  NUMBER
    , p_parent_table  VARCHAR2
    --
    -- PB Add :
    -- The transaction steps have to be created by the login personid.
    -- In case of adding phones for contacts parent_is is contact_person_id.
    -- Login person id is say employee who is adding the phones to his contact.
    --
    , p_login_person_id     NUMBER default null
    , p_business_group_id   number default null
    , p_attribute_category  VARCHAR2 default hr_api.g_varchar2
    , p_attribute1  VARCHAR2 default hr_api.g_varchar2
    , p_attribute2  VARCHAR2 default hr_api.g_varchar2
    , p_attribute3  VARCHAR2 default hr_api.g_varchar2
    , p_attribute4  VARCHAR2 default hr_api.g_varchar2
    , p_attribute5  VARCHAR2 default hr_api.g_varchar2
    , p_attribute6  VARCHAR2 default hr_api.g_varchar2
    , p_attribute7  VARCHAR2 default hr_api.g_varchar2
    , p_attribute8  VARCHAR2 default hr_api.g_varchar2
    , p_attribute9  VARCHAR2 default hr_api.g_varchar2
    , p_attribute10  VARCHAR2 default hr_api.g_varchar2
    , p_attribute11  VARCHAR2 default hr_api.g_varchar2
    , p_attribute12  VARCHAR2 default hr_api.g_varchar2
    , p_attribute13  VARCHAR2 default hr_api.g_varchar2
    , p_attribute14  VARCHAR2 default hr_api.g_varchar2
    , p_attribute15  VARCHAR2 default hr_api.g_varchar2
    , p_attribute16  VARCHAR2 default hr_api.g_varchar2
    , p_attribute17  VARCHAR2 default hr_api.g_varchar2
    , p_attribute18  VARCHAR2 default hr_api.g_varchar2
    , p_attribute19  VARCHAR2 default hr_api.g_varchar2
    , p_attribute20  VARCHAR2 default hr_api.g_varchar2
    , p_attribute21  VARCHAR2 default hr_api.g_varchar2
    , p_attribute22  VARCHAR2 default hr_api.g_varchar2
    , p_attribute23  VARCHAR2 default hr_api.g_varchar2
    , p_attribute24  VARCHAR2 default hr_api.g_varchar2
    , p_attribute25  VARCHAR2 default hr_api.g_varchar2
    , p_attribute26  VARCHAR2 default hr_api.g_varchar2
    , p_attribute27  VARCHAR2 default hr_api.g_varchar2
    , p_attribute28  VARCHAR2 default hr_api.g_varchar2
    , p_attribute29  VARCHAR2 default hr_api.g_varchar2
    , p_attribute30  VARCHAR2 default hr_api.g_varchar2
    -- StartRegistration
    , p_per_or_contact varchar2 default null
    , p_validate  number
    , p_effective_date  date
    , p_object_version_number out nocopy  NUMBER
    , p_phone_id out nocopy  NUMBER
    , p_item_type                     in     varchar2
    , p_item_key                      in     varchar2
    , p_activity_id                   in     number
    , p_phone_type_meaning            in     varchar2
    , p_save_mode                     in     varchar2 default null
    , p_error_message                 out nocopy    varchar2
    , p_contact_relationship_id       in number           default hr_api.g_number
  )
  as

  l_transaction_id             number default null;
  l_transaction_step_id        number default null;
  l_trans_obj_vers_num         number default null;
  l_count                      integer default 0;
  l_transaction_table hr_transaction_ss.transaction_table;
  l_review_item_name  varchar2(50);
  l_message_number VARCHAR2(10);
  --
  l_parent_id         number;
  l_dummy_num  number;
  l_dummy_date date;
  l_dummy_char varchar2(1000);
  l_dummy_bool boolean;
  --
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
  l_contact_set                       number;
  -- EndRegistration
  l_api_name                          varchar2(100);
  l_validate_g_per_con_step_id        number;
  --
  l_error_message                 long default null;
  l_proc   varchar2(72)  := g_package||'create_phone';

  begin

    hr_utility.set_location('Entering:'||l_proc, 5);
    IF (p_save_mode = 'SAVE_FOR_LATER') THEN
       hr_utility.set_location('SFL:GOTO only_txn'||l_proc,10);
       GOTO only_transaction;
    END IF;

    SAVEPOINT create_contact_and_phone;
    l_parent_id := p_parent_id;
    --
    if (l_parent_id is null or l_parent_id < 0 ) then
       --
      -- bug # 2174876
    hr_utility.set_location('l_parent_id is null or l_parent_id < 0 :'||l_proc,15);

    if p_per_or_contact = 'CONTACT' or p_per_or_contact = 'EMER_CR_NEW_CONT' or p_per_or_contact = 'EMRG_OVRW_UPD' or p_per_or_contact = 'EMRG_OVRW_DEL' or  p_per_or_contact = 'EMER_CR_NEW_REL'
          or  p_per_or_contact = 'DPDNT_CR_NEW_CONT' or  p_per_or_contact = 'DPDNT_OVRW_UPD'  or  p_per_or_contact = 'DPDNT_OVRW_DEL' or  p_per_or_contact = 'DPDNT_CR_NEW_REL'
        or p_per_or_contact = 'COBRA' then
      declare
        l_object_version_number number;
        l_effective_start_date date;
        l_effective_end_date date;
        l_full_name varchar2(255);
        l_comment_id number;
        l_name_combination_warning boolean;
        l_orig_hire_warning boolean;
      begin
       --ignore the dff validations for Dummy Person created
       hr_person_info_util_ss.create_ignore_df_validation('PER_PEOPLE');
       hr_person_info_util_ss.create_ignore_df_validation('Person Developer DF');
        hr_contact_api.create_person
           (p_start_date => p_effective_date,
            p_business_group_id =>p_business_group_id,
            p_last_name => 'RegistrationDummy',
	    p_first_name => 'Dummy',
	    p_sex => 'M',
--            p_coord_ben_no_cvg_flag => 'Y',
            p_person_id => l_parent_id,
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
     if p_per_or_contact = 'PERSON' then
       hr_utility.set_location('p_per_or_contact = PERSON:'||l_proc,20);
       hr_new_user_reg_ss.processNewUserTransaction(
                  WfItemType => p_item_type,
                  WfItemKey  => p_item_key,
                  PersonId   => l_parent_id,
                  AssignmentId => l_reg_assignment_id);
     end if;
      --
    end if;
    --
    -- here's the delegated call to the old PL/SQL routine
    --
    hr_phone_api.create_phone(
      p_date_from   => p_date_from,
      p_phone_type  => p_phone_type,
      p_phone_number => p_phone_number,
      -- PB Add
      -- In case of create of a new contact p_parent_id comes as -1 so
      -- use p_login_person_id to validate the phone addition.
      --
      p_parent_id => l_parent_id, -- PB : Modify p_parent_id,
      p_parent_table => p_parent_table,
      p_attribute_category => p_attribute_category,
      p_attribute1 => p_attribute1,
      p_attribute2 => p_attribute2,
      p_attribute3 => p_attribute3,
      p_attribute4 => p_attribute4,
      p_attribute5 => p_attribute5,
      p_attribute6 => p_attribute6,
      p_attribute7 => p_attribute7,
      p_attribute8 => p_attribute8,
      p_attribute9 => p_attribute9,
      p_attribute10 => p_attribute10,
      p_attribute11 => p_attribute11,
      p_attribute12 => p_attribute12,
      p_attribute13 => p_attribute13,
      p_attribute14 => p_attribute14,
      p_attribute15 => p_attribute15,
      p_attribute16 => p_attribute16,
      p_attribute17 => p_attribute17,
      p_attribute18 => p_attribute18,
      p_attribute19 => p_attribute19,
      p_attribute20 => p_attribute20,
      p_attribute21 => p_attribute21,
      p_attribute22 => p_attribute22,
      p_attribute23 => p_attribute23,
      p_attribute24 => p_attribute24,
      p_attribute25 => p_attribute25,
      p_attribute26 => p_attribute26,
      p_attribute27 => p_attribute27,
      p_attribute28 => p_attribute28,
      p_attribute29 => p_attribute29,
      p_attribute30 => p_attribute30,
      --
      -- PB : Use the savepoint and rollback rather than
      -- the parameter.
      --
      -- p_validate => hr_java_conv_util_ss.get_boolean (p_number => p_validate),
      p_validate => false,
      p_effective_date => p_effective_date,
      p_object_version_number => l_dummy_num,  -- p_object_version_number,
      p_phone_id => l_dummy_num);   -- p_phone_id);
  --

  hr_utility.set_location('rollback to create_contact_and_phone:'||l_proc,25);
  rollback to create_contact_and_phone;

  <<only_transaction>> -- label for GOTO

--  This is a marker for the contact person to be used to identify the phone numbers
--  to be retrieved for the contact person in context in review page.
--  The HR_LAST_CONTACT_SET is got from the work flow attribute
 begin

   l_contact_set := wf_engine.GetItemAttrNumber(itemtype => p_item_type,
                                                itemkey  => p_item_key,
                                                aname    => 'HR_CONTACT_SET');

 exception when others then
   hr_utility.set_location('Exception:others'||l_proc,555);
   l_contact_set := 0;

 end;

  save_transaction(
    p_phone_id => p_phone_id
  , p_item_type => p_item_type
  , p_item_key => p_item_key
  , p_activity_id => p_activity_id
  , p_date_from => p_date_from
  , p_phone_type => p_phone_type
  , p_phone_number => p_phone_number
  , p_parent_id  => p_parent_id
  , p_parent_table => p_parent_table
  , p_login_person_id  => p_login_person_id
  , p_per_or_contact => p_per_or_contact
  , p_contact_set => l_contact_set
  , p_effective_date => p_effective_date
  , p_object_version_number => p_object_version_number
  , p_phone_type_meaning => p_phone_type_meaning
  , p_attribute_category => p_attribute_category
  , p_attribute1 => p_attribute1
  , p_attribute2 => p_attribute2
  , p_attribute3 => p_attribute3
  , p_attribute4 => p_attribute4
  , p_attribute5 => p_attribute5
  , p_attribute6 => p_attribute6
  , p_attribute7 => p_attribute7
  , p_attribute8 => p_attribute8
  , p_attribute9 => p_attribute9
  , p_attribute10 => p_attribute10
  , p_attribute11 => p_attribute11
  , p_attribute12 => p_attribute12
  , p_attribute13 => p_attribute13
  , p_attribute14 => p_attribute14
  , p_attribute15 => p_attribute15
  , p_attribute16 => p_attribute16
  , p_attribute17 => p_attribute17
  , p_attribute18 => p_attribute18
  , p_attribute19 => p_attribute19
  , p_attribute20 => p_attribute20
  , p_attribute21 => p_attribute21
  , p_attribute22 => p_attribute22
  , p_attribute23 => p_attribute23
  , p_attribute24 => p_attribute24
  , p_attribute25 => p_attribute25
  , p_attribute26 => p_attribute26
  , p_attribute27 => p_attribute27
  , p_attribute28 => p_attribute28
  , p_attribute29 => p_attribute29
  , p_attribute30 => p_attribute30
  , p_error_message => l_error_message
  , p_contact_relationship_id =>p_contact_relationship_id);

  -- check if we got any errors
  IF (l_error_message IS NOT NULL) THEN

     raise g_save_transaction_error;
  END IF;

  EXCEPTION
  WHEN g_save_transaction_error THEN
   -- No need to call formatted_error_message, as the messages is already
   -- formatted.
   hr_utility.set_location('Exception:g_save_transaction_error'||l_proc,560);
   p_error_message := l_error_message;
  WHEN hr_utility.hr_error THEN
         -- -------------------------------------------
         -- an application error has been raised so we must
         -- redisplay the web form to display the error
         -- --------------------------------------------
         hr_utility.set_location('Exception:hr_utility.hr_error THEN'||l_proc,565);
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
         ELSE
          p_error_message := hr_java_conv_util_ss.get_formatted_error_message(
                             p_error_message => p_error_message);
         END IF;
  WHEN OTHERS THEN
    hr_utility.set_location('Exception:Others'||l_proc,570);
    p_error_message := hr_java_conv_util_ss.get_formatted_error_message(
                             p_error_message => p_error_message);

 end create_phone;

  /*
  ||===========================================================================
  || PROCEDURE: update_phone
  ||---------------------------------------------------------------------------
  ||
  || Description:
  || Description:
  ||     This procedure will call the actual API -
  ||                hr_phone_api.update_phone()
  ||
  || Pre Conditions:
  ||
  || In Arguments:
  ||     Contains entire list of parameters that are defined in the actual
  ||     API. For details see pephnapi.pkb file.
  ||
  || out nocopy Arguments:
  ||
  || In out nocopy Arguments:
  ||
  || Post Success:
  ||     Executes the API call.
  ||
  || Post Failure:
  ||     Raises an exception
  ||
  || Access Status:
  ||     Public.
  ||
  ||===========================================================================
  */

 procedure update_phone(p_phone_id  NUMBER
    , p_date_from  date
    , p_date_to  date
    , p_phone_type  VARCHAR2
    , p_phone_number  VARCHAR2
    , p_per_or_contact varchar2 default null
    --
    -- PB Add :
    -- The transaction steps have to be created by the login personid.
    -- In case of adding phones for contacts parent_is is contact_person_id.
    -- Login person id is say employee who is adding the phones to his contact.
    --
    , p_login_person_id     NUMBER default hr_api.g_number
    , p_attribute_category  VARCHAR2 default hr_api.g_varchar2
    , p_attribute1  VARCHAR2 default hr_api.g_varchar2
    , p_attribute2  VARCHAR2 default hr_api.g_varchar2
    , p_attribute3  VARCHAR2 default hr_api.g_varchar2
    , p_attribute4  VARCHAR2 default hr_api.g_varchar2
    , p_attribute5  VARCHAR2 default hr_api.g_varchar2
    , p_attribute6  VARCHAR2 default hr_api.g_varchar2
    , p_attribute7  VARCHAR2 default hr_api.g_varchar2
    , p_attribute8  VARCHAR2 default hr_api.g_varchar2
    , p_attribute9  VARCHAR2 default hr_api.g_varchar2
    , p_attribute10  VARCHAR2 default hr_api.g_varchar2
    , p_attribute11  VARCHAR2 default hr_api.g_varchar2
    , p_attribute12  VARCHAR2 default hr_api.g_varchar2
    , p_attribute13  VARCHAR2 default hr_api.g_varchar2
    , p_attribute14  VARCHAR2 default hr_api.g_varchar2
    , p_attribute15  VARCHAR2 default hr_api.g_varchar2
    , p_attribute16  VARCHAR2 default hr_api.g_varchar2
    , p_attribute17  VARCHAR2 default hr_api.g_varchar2
    , p_attribute18  VARCHAR2 default hr_api.g_varchar2
    , p_attribute19  VARCHAR2 default hr_api.g_varchar2
    , p_attribute20  VARCHAR2 default hr_api.g_varchar2
    , p_attribute21  VARCHAR2 default hr_api.g_varchar2
    , p_attribute22  VARCHAR2 default hr_api.g_varchar2
    , p_attribute23  VARCHAR2 default hr_api.g_varchar2
    , p_attribute24  VARCHAR2 default hr_api.g_varchar2
    , p_attribute25  VARCHAR2 default hr_api.g_varchar2
    , p_attribute26  VARCHAR2 default hr_api.g_varchar2
    , p_attribute27  VARCHAR2 default hr_api.g_varchar2
    , p_attribute28  VARCHAR2 default hr_api.g_varchar2
    , p_attribute29  VARCHAR2 default hr_api.g_varchar2
    , p_attribute30  VARCHAR2 default hr_api.g_varchar2
    , p_object_version_number in out nocopy  NUMBER
    , p_validate  number
    , p_effective_date  date
    , p_parent_id  NUMBER
    , p_item_type                     in     varchar2
    , p_item_key                      in     varchar2
    , p_activity_id                   in     number
    , p_phone_type_meaning            in     varchar2
    , p_save_mode                     in     varchar2 default null
    , p_error_message                 out nocopy    varchar2
    , p_contact_relationship_id       in number           default hr_api.g_number
  )
  as

  l_transaction_id             number default null;
  l_transaction_step_id        number default null;
  l_trans_obj_vers_num         number default null;
  l_count                      integer default 0;
  l_transaction_table hr_transaction_ss.transaction_table;
  l_review_item_name           varchar2(50);
  l_message_number VARCHAR2(10);
  l_error_message                 long default null;
  l_proc   varchar2(72)  := g_package||'update_phone';

  begin

    hr_utility.set_location('Entering:'||l_proc, 5);
    IF (p_save_mode = 'SAVE_FOR_LATER') THEN
       hr_utility.set_location('SFL:Goto only_txn'||l_proc,10);
       GOTO only_transaction;
    END IF;


    -- here's the delegated call to the old PL/SQL routine
    hr_phone_api.update_phone(
      p_phone_id => p_phone_id,
      p_date_from   => p_date_from,
      p_phone_type  => p_phone_type,
      p_phone_number => p_phone_number,
      p_attribute_category => p_attribute_category,
      p_attribute1 => p_attribute1,
      p_attribute2 => p_attribute2,
      p_attribute3 => p_attribute3,
      p_attribute4 => p_attribute4,
      p_attribute5 => p_attribute5,
      p_attribute6 => p_attribute6,
      p_attribute7 => p_attribute7,
      p_attribute8 => p_attribute8,
      p_attribute9 => p_attribute9,
      p_attribute10 => p_attribute10,
      p_attribute11 => p_attribute11,
      p_attribute12 => p_attribute12,
      p_attribute13 => p_attribute13,
      p_attribute14 => p_attribute14,
      p_attribute15 => p_attribute15,
      p_attribute16 => p_attribute16,
      p_attribute17 => p_attribute17,
      p_attribute18 => p_attribute18,
      p_attribute19 => p_attribute19,
      p_attribute20 => p_attribute20,
      p_attribute21 => p_attribute21,
      p_attribute22 => p_attribute22,
      p_attribute23 => p_attribute23,
      p_attribute24 => p_attribute24,
      p_attribute25 => p_attribute25,
      p_attribute26 => p_attribute26,
      p_attribute27 => p_attribute27,
      p_attribute28 => p_attribute28,
      p_attribute29 => p_attribute29,
      p_attribute30 => p_attribute30,
      p_object_version_number => p_object_version_number,
      p_validate => hr_java_conv_util_ss.get_boolean (p_number => p_validate),
      p_effective_date => p_effective_date);

   <<only_transaction>> -- label for GOTO

  save_transaction(
    p_phone_id => p_phone_id
  , p_item_type => p_item_type
  , p_item_key => p_item_key
  , p_activity_id => p_activity_id
  , p_date_from => p_date_from
  , p_phone_type => p_phone_type
  , p_phone_number => p_phone_number
  , p_parent_id  => p_parent_id
  , p_login_person_id  => p_login_person_id
  , p_effective_date => p_effective_date
  , p_object_version_number => p_object_version_number
  , p_phone_type_meaning => p_phone_type_meaning
  , p_attribute_category => p_attribute_category
  ,p_per_or_contact => p_per_or_contact
  , p_attribute1 => p_attribute1
  , p_attribute2 => p_attribute2
  , p_attribute3 => p_attribute3
  , p_attribute4 => p_attribute4
  , p_attribute5 => p_attribute5
  , p_attribute6 => p_attribute6
  , p_attribute7 => p_attribute7
  , p_attribute8 => p_attribute8
  , p_attribute9 => p_attribute9
  , p_attribute10 => p_attribute10
  , p_attribute11 => p_attribute11
  , p_attribute12 => p_attribute12
  , p_attribute13 => p_attribute13
  , p_attribute14 => p_attribute14
  , p_attribute15 => p_attribute15
  , p_attribute16 => p_attribute16
  , p_attribute17 => p_attribute17
  , p_attribute18 => p_attribute18
  , p_attribute19 => p_attribute19
  , p_attribute20 => p_attribute20
  , p_attribute21 => p_attribute21
  , p_attribute22 => p_attribute22
  , p_attribute23 => p_attribute23
  , p_attribute24 => p_attribute24
  , p_attribute25 => p_attribute25
  , p_attribute26 => p_attribute26
  , p_attribute27 => p_attribute27
  , p_attribute28 => p_attribute28
  , p_attribute29 => p_attribute29
  , p_attribute30 => p_attribute30
  , p_error_message => l_error_message
  , p_contact_relationship_id=>p_contact_relationship_id
  );

  -- check if we got any errors
  IF (l_error_message IS NOT NULL) THEN
     hr_utility.set_location('l_error_message IS NOT NULL:'||l_proc,15);
     raise g_save_transaction_error;
  END IF;

   hr_utility.set_location('Exiting:'||l_proc, 20);
   EXCEPTION
  WHEN g_save_transaction_error THEN
   -- No need to call formatted_error_message, as the messages is already
   -- formatted.
   hr_utility.set_location('Exception:g_save_transaction_error'||l_proc,555);
   p_error_message := l_error_message;
   WHEN hr_utility.hr_error THEN
         -- -------------------------------------------
         -- an application error has been raised so we must
         -- redisplay the web form to display the error
         -- --------------------------------------------
         hr_utility.set_location('Exception:hr_utility.hr_error'||l_proc,560);
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
         ELSE
          p_error_message := hr_java_conv_util_ss.get_formatted_error_message(
                             p_error_message => p_error_message);
         END IF;
    WHEN OTHERS THEN
    hr_utility.set_location('Exception:Others'||l_proc,565);
    p_error_message := hr_java_conv_util_ss.get_formatted_error_message(
                             p_error_message => p_error_message);

  end update_phone;

  /*
  ||===========================================================================
  || PROCEDURE: delete_phone
  ||---------------------------------------------------------------------------
  ||
  || Description:
  || Description:
  ||     This procedure will call the actual API -
  ||                hr_phone_api.delete_phone()
  ||
  || Pre Conditions:
  ||
  || In Arguments:
  ||     Contains entire list of parameters that are defined in the actual
  ||     API. For details see pephnapi.pkb file.
  ||
  || out nocopy Arguments:
  ||
  || In out nocopy Arguments:
  ||
  || Post Success:
  ||     Executes the API call.
  ||
  || Post Failure:
  ||     Raises an exception
  ||
  || Access Status:
  ||     Public.
  ||
  ||===========================================================================
  */

  procedure delete_phone(p_validate  number
    , p_phone_id  NUMBER
    , p_object_version_number  NUMBER
    , p_parent_id                     in     number
    --
    -- PB Add :
    -- The transaction steps have to be created by the login personid.
    -- In case of adding phones for contacts parent_is is contact_person_id.
    -- Login person id is say employee who is adding the phones to his contact.
    --
    , p_login_person_id     NUMBER default hr_api.g_number
    , p_item_type                     in     varchar2
    , p_item_key                      in     varchar2
    , p_activity_id                   in     number
    , p_phone_type_meaning            in     varchar2
    , p_save_mode                     in     varchar2 default null
    , p_error_message                 out nocopy    varchar2
    , p_per_or_contact varchar2 default null
 )
  as

  l_transaction_id             number default null;
  l_transaction_step_id        number default null;
  l_trans_obj_vers_num         number default null;
  l_count                      integer default 0;
  l_transaction_table hr_transaction_ss.transaction_table;
  l_review_item_name           varchar2(50);
  l_message_number VARCHAR2(10);
  l_error_message                 long default null;
  l_proc   varchar2(72)  := g_package||'delete_phone';

  begin
    hr_utility.set_location('Entering:'||l_proc, 5);
    IF (p_save_mode = 'SAVE_FOR_LATER') THEN
       hr_utility.set_location('SFL:Goto only_txn'||l_proc,10);
       GOTO only_transaction;
    END IF;

    -- here's the delegated call to the old PL/SQL routine
    hr_phone_api.delete_phone(
      p_validate => hr_java_conv_util_ss.get_boolean (p_number => p_validate),
      p_phone_id => p_phone_id,
      p_object_version_number => p_object_version_number);

  <<only_transaction>> -- label for GOTO

  save_transaction(
    p_phone_id => p_phone_id
  , p_item_type => p_item_type
  , p_item_key => p_item_key
  , p_activity_id => p_activity_id
  , p_phone_type => 'DELETE'
  , p_phone_number => 'DELETE_NUMBER'
  , p_parent_id  => p_parent_id
  , p_login_person_id  => p_login_person_id
  , p_per_or_contact => p_per_or_contact
  , p_object_version_number => p_object_version_number
  , p_phone_type_meaning => p_phone_type_meaning
  , p_error_message => l_error_message);

  -- check if we got any errors
  IF (l_error_message IS NOT NULL) THEN
     hr_utility.set_location('l_error_message IS NOT NULL:'||l_proc,15);
     raise g_save_transaction_error;
  END IF;

  hr_utility.set_location('Exiting:'||l_proc, 20);
  EXCEPTION
  WHEN g_save_transaction_error THEN
   -- No need to call formatted_error_message, as the messages is already
   -- formatted.
   hr_utility.set_location('Exception:g_save_transaction_error'||l_proc,555);
   p_error_message := l_error_message;
   WHEN hr_utility.hr_error THEN
         -- -------------------------------------------
         -- an application error has been raised so we must
         -- redisplay the web form to display the error
         -- --------------------------------------------
         hr_utility.set_location('Exception:hr_utility.hr_error'||l_proc,560);
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
         ELSE
          p_error_message := hr_java_conv_util_ss.get_formatted_error_message(
                             p_error_message => p_error_message);
         END IF;
    WHEN OTHERS THEN
    hr_utility.set_location('Exception:Others'||l_proc,565);
    p_error_message := hr_java_conv_util_ss.get_formatted_error_message(
                             p_error_message => p_error_message);

  end delete_phone;

  /*
  ||===========================================================================
  || PROCEDURE: create_or_update_phone
  ||---------------------------------------------------------------------------
  ||
  || Description:
  || Description:
  ||     This procedure will call the actual API -
  ||                hr_phone_api.create_or_update_phone()
  ||
  || Pre Conditions:
  ||
  || In Arguments:
  ||     Contains entire list of parameters that are defined in the actual
  ||     API. For details see pephnapi.pkb file.
  ||
  || out nocopy Arguments:
  ||
  || In out nocopy Arguments:
  ||
  || Post Success:
  ||     Executes the API call.
  ||
  || Post Failure:
  ||     Raises an exception
  ||
  || Access Status:
  ||     Public.
  ||
  ||===========================================================================
  */

  procedure create_or_update_phone(p_update_mode  VARCHAR2
    , p_phone_id in out nocopy  NUMBER
    , p_object_version_number in out nocopy  NUMBER
    , p_date_from  date
    , p_date_to  date
    , p_phone_type  VARCHAR2
    , p_phone_number  VARCHAR2
    , p_parent_id  NUMBER
    , p_parent_table  VARCHAR2
    , p_attribute_category  VARCHAR2
    , p_attribute1  VARCHAR2 default hr_api.g_varchar2
    , p_attribute2  VARCHAR2 default hr_api.g_varchar2
    , p_attribute3  VARCHAR2 default hr_api.g_varchar2
    , p_attribute4  VARCHAR2 default hr_api.g_varchar2
    , p_attribute5  VARCHAR2 default hr_api.g_varchar2
    , p_attribute6  VARCHAR2 default hr_api.g_varchar2
    , p_attribute7  VARCHAR2 default hr_api.g_varchar2
    , p_attribute8  VARCHAR2 default hr_api.g_varchar2
    , p_attribute9  VARCHAR2 default hr_api.g_varchar2
    , p_attribute10  VARCHAR2 default hr_api.g_varchar2
    , p_attribute11  VARCHAR2 default hr_api.g_varchar2
    , p_attribute12  VARCHAR2 default hr_api.g_varchar2
    , p_attribute13  VARCHAR2 default hr_api.g_varchar2
    , p_attribute14  VARCHAR2 default hr_api.g_varchar2
    , p_attribute15  VARCHAR2 default hr_api.g_varchar2
    , p_attribute16  VARCHAR2 default hr_api.g_varchar2
    , p_attribute17  VARCHAR2 default hr_api.g_varchar2
    , p_attribute18  VARCHAR2 default hr_api.g_varchar2
    , p_attribute19  VARCHAR2 default hr_api.g_varchar2
    , p_attribute20  VARCHAR2 default hr_api.g_varchar2
    , p_attribute21  VARCHAR2 default hr_api.g_varchar2
    , p_attribute22  VARCHAR2 default hr_api.g_varchar2
    , p_attribute23  VARCHAR2 default hr_api.g_varchar2
    , p_attribute24  VARCHAR2 default hr_api.g_varchar2
    , p_attribute25  VARCHAR2 default hr_api.g_varchar2
    , p_attribute26  VARCHAR2 default hr_api.g_varchar2
    , p_attribute27  VARCHAR2 default hr_api.g_varchar2
    , p_attribute28  VARCHAR2 default hr_api.g_varchar2
    , p_attribute29  VARCHAR2 default hr_api.g_varchar2
    , p_attribute30  VARCHAR2 default hr_api.g_varchar2
    , p_validate  number
    , p_effective_date  date
    , p_item_type                     in     varchar2
    , p_item_key                      in     varchar2
    , p_activity_id                   in     number
    , p_phone_type_meaning            in     varchar2
  )
  as
  l_proc   varchar2(72)  := g_package||'create_or_update_phone';

  begin

    -- here's the delegated call to the old PL/SQL routine
    hr_utility.set_location('Entering:'||l_proc, 5);
    hr_phone_api.create_or_update_phone(
      p_update_mode => p_update_mode,
      p_phone_id => p_phone_id,
      p_object_version_number => p_object_version_number,
      p_date_from => p_date_from,
      p_phone_type => p_phone_type,
      p_phone_number => p_phone_number,
      p_parent_id => p_parent_id,
      p_parent_table => p_parent_table,
      p_attribute_category => p_attribute_category,
      p_attribute1 => p_attribute1,
      p_attribute2 => p_attribute2,
      p_attribute3 => p_attribute3,
      p_attribute4 => p_attribute4,
      p_attribute5 => p_attribute5,
      p_attribute6 => p_attribute6,
      p_attribute7 => p_attribute7,
      p_attribute8 => p_attribute8,
      p_attribute9 => p_attribute9,
      p_attribute10 => p_attribute10,
      p_attribute11 => p_attribute11,
      p_attribute12 => p_attribute12,
      p_attribute13 => p_attribute13,
      p_attribute14 => p_attribute14,
      p_attribute15 => p_attribute15,
      p_attribute16 => p_attribute16,
      p_attribute17 => p_attribute17,
      p_attribute18 => p_attribute18,
      p_attribute19 => p_attribute19,
      p_attribute20 => p_attribute20,
      p_attribute21 => p_attribute21,
      p_attribute22 => p_attribute22,
      p_attribute23 => p_attribute23,
      p_attribute24 => p_attribute24,
      p_attribute25 => p_attribute25,
      p_attribute26 => p_attribute26,
      p_attribute27 => p_attribute27,
      p_attribute28 => p_attribute28,
      p_attribute29 => p_attribute29,
      p_attribute30 => p_attribute30,
      p_validate => hr_java_conv_util_ss.get_boolean (p_number => p_validate),
      p_effective_date => p_effective_date);
      hr_utility.set_location('Exiting:'||l_proc, 10);
  end create_or_update_phone;

-- ---------------------------------------------------------------------------
-- ---------------------- < get_phone_data_from_tt> -------------------------
-- ---------------------------------------------------------------------------
-- Purpose: This procedure will get transaction data which are saved earlier
--          in the current transaction.  This is invoked when a user click BACK
--          button to go back from the Review page to Update page to correct
--          typos or make further changes or vice-versa.  Hence, we need to use
--          the item_type item_key passed in to retrieve the transaction record.
-- ---------------------------------------------------------------------------
PROCEDURE get_phone_data_from_tt
   (p_item_type                       in  varchar2
   ,p_item_key                        in  varchar2
   ,p_activity_id                     in  varchar2
   ,p_trans_rec_count                 out nocopy number
   ,p_person_id                       out nocopy number
   ,p_phone_numbers_data              out nocopy varchar2
) is

   --
   -- Cursor to detect phone type transaction data.
   cursor csr_hatv(cv_transaction_step_id in number,
                   cv_name in varchar2) is
    select hatv.number_value
    from   hr_api_transaction_values hatv
    where  hatv.transaction_step_id = cv_transaction_step_id
    and    hatv.name                = cv_name;
   --
   l_trans_step_id                    number default null;
--   l_trans_obj_vers_num               number default null;
   l_trans_rec_count                  integer default 0;
   l_trans_step_ids       hr_util_web.g_varchar2_tab_type;
   l_trans_obj_vers_nums  hr_util_web.g_varchar2_tab_type;
   l_trans_step_rows                  NUMBER  ;
   ln_index                           number  default 0;
   l_phone_data                       varchar2(4000);
   l_dummy                            number;
   l_proc   varchar2(72)  := g_package||'get_phone_data_from_tt';

 BEGIN
  -- ------------------------------------------------------------------
  -- Check if there are any transaction rec already saved for the current
  -- transaction. This is used for re-display the Update page when a user
  -- clicks the Back button on the Review page to go back to the Update page
  -- to make further changes or to correct errors.
  -----------------------------------------------------------------------------
  -- For a given item key, there could be multiple transaction steps saved.

         hr_utility.set_location('Entering:'||l_proc, 5);
         hr_transaction_api.get_transaction_step_info
             (p_item_type              => p_item_type
             ,p_item_key               => p_item_key
             ,p_activity_id            => p_activity_id
             ,p_transaction_step_id    => l_trans_step_ids
             ,p_object_version_number  => l_trans_obj_vers_nums
             ,p_rows                   => l_trans_step_rows);

        --
        -- ---------------------------------------------------------------------
        -- NOTE:We need to adjust the index which referrences l_trans_step_ids
        --    by 1 because that table was created with the index starts at 0
        --    in hr_transaction_api.get_transaction_step_info.
        -- ---------------------------------------------------------------------
        --
        ln_index := 0;

        hr_utility.set_location('Entering For Loop 1..l_trans_step_rows:'||l_proc,10);
        FOR j in 1..l_trans_step_rows
        LOOP
          --
          -- Now get the transaction data for the given step
          -- Get the Phone transaction data only.
          --
          begin
            --
            -- We can't relay on the exception from the procedure to
            -- determine whether the step is of phone or not use a
            -- direct cursor.
            --
            /*
              l_dummy := hr_transaction_api.get_number_Value
                        (p_transaction_step_id =>
                                        l_trans_step_ids(ln_index)
                        ,p_name => 'P_PHONE_ID');
            */
            --
            for l_rec in csr_hatv(l_trans_step_ids(ln_index), 'P_PHONE_ID') loop
              --
              get_phone_data_from_tt(
                 p_transaction_step_id            => l_trans_step_ids(ln_index)
                ,p_person_id                      => p_person_id
                ,p_phone_data                     => l_phone_data);
              --
              l_trans_rec_count  := l_trans_rec_count  + 1;
              p_phone_numbers_data := p_phone_numbers_data||l_phone_data||'~';
            --
            end loop;
            --
          exception
            when others then
            hr_utility.set_location('Exception:Others'||l_proc,555);
                 null;
          end;
           ln_index := ln_index + 1;
        END LOOP;
        hr_utility.set_location('Exiting For Loop:'||l_proc,15);

    p_trans_rec_count := l_trans_rec_count;
    hr_utility.set_location('Exiting:'||l_proc, 20);
EXCEPTION
   WHEN OTHERS THEN
   hr_utility.set_location('Exception:Others'||l_proc,555);
      RAISE;

END get_phone_data_from_tt;

-- ---------------------------------------------------------------------------
-- ---------------------- < get_phone_data_from_tt> -------------------------
-- ---------------------------------------------------------------------------
-- Purpose: This procedure will get transaction data which are pending for
--          approval in workflow for a transaction step id.
--          This is a overloaded version
-- ---------------------------------------------------------------------------
procedure get_phone_data_from_tt
   (p_transaction_step_id             in  number
   ,p_person_id                       out nocopy number
   ,p_phone_data                      out nocopy varchar2
)is

 l_phone_id              per_phones.phone_id%type;
 l_phone_type            per_phones.phone_type%type;
 l_phone_number          per_phones.phone_number%type;
 l_object_version_number per_phones.object_version_number%type;
 l_phone_type_meaning hr_lookups.meaning%TYPE;
 --StartRgistration
 l_contact_set           varchar2(20);
 l_proc   varchar2(72)  := g_package||'get_phone_data_from_tt';

begin


--
  hr_utility.set_location('Entering:'||l_proc, 5);
  p_person_id := hr_transaction_api.get_number_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_PERSON_ID');
--
  l_phone_id := hr_transaction_api.get_number_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_PHONE_ID');
--
  l_phone_type := hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_PHONE_TYPE');
--
  l_phone_type_meaning := hr_transaction_api.get_varchar2_Value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name => 'P_PHONE_TYPE_MEANING');
--
  l_phone_number := hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_PHONE_NUMBER');
--
  l_object_version_number := hr_transaction_api.get_number_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_OBJECT_VERSION_NUMBER');
--
--StartRegistration
--
  begin
    l_contact_set := hr_transaction_api.get_varchar2_value
    (p_transaction_step_id => p_transaction_step_id
    ,p_name                => 'P_CONTACT_SET');
  exception
    when others then
    hr_utility.set_location('Exception:Others'||l_proc,555);
      l_contact_set := 1;
  end;
  if l_contact_set is null then
     l_contact_set := 1;
  end if;

--
--EndRegistration
--
-- Now string all the retreived items into phone_data
-- Added more data for Registration
--

 p_phone_data := nvl(l_phone_id,0)||'^'||l_phone_type||'^'||l_phone_type_meaning||'^'||l_phone_number||'^'||nvl(l_object_version_number,0)||'^'||nvl(l_contact_set,0)||'^'||nvl(l_contact_set,0); -- Packer
 hr_utility.set_location('Exiting:'||l_proc, 15);

EXCEPTION
   WHEN OTHERS THEN
      hr_utility.set_location('Exception:Others'||l_proc,555);
      RAISE;

END get_phone_data_from_tt;

PROCEDURE get_transaction_details
   (p_item_type                       in  varchar2
   ,p_item_key                        in  varchar2
   ,p_activity_id                     in  varchar2
   ,p_trans_rec_count                 out nocopy number
   ,p_person_id                       out nocopy number
   ,p_phone_numbers_details           in out nocopy sshr_phone_details_tab_typ
) IS
  --
  -- Cursor to detect phone type transaction data.
  cursor csr_hatv(cv_transaction_step_id in number,
    cv_name in varchar2) is
    select hatv.number_value
    from   hr_api_transaction_values hatv
    where  hatv.transaction_step_id = cv_transaction_step_id
    and    hatv.name                = cv_name;
  --
  l_trans_step_id                    number default null;
  -- l_trans_obj_vers_num               number default null;
  l_trans_rec_count                  integer default 0;
  l_trans_step_ids       hr_util_web.g_varchar2_tab_type;
  l_trans_obj_vers_nums  hr_util_web.g_varchar2_tab_type;
  l_trans_step_rows                  NUMBER  ;
  ln_index                           number  default 0;
  i                                  number  default 1;
  l_proc   varchar2(72)  := g_package||'get_transaction_details';

 BEGIN
  -- ------------------------------------------------------------------
  -- Check if there are any transaction rec already saved for the current
  -- transaction. This is used for re-display the Update page when a user
  -- clicks the Back button on the Review page to go back to the Update page
  -- to make further changes or to correct errors.
  -----------------------------------------------------------------------------
  -- For a given item key, there could be multiple transaction steps saved.

  hr_utility.set_location('Entering:'||l_proc, 5);
  hr_transaction_api.get_transaction_step_info
    (p_item_type              => p_item_type
    ,p_item_key               => p_item_key
    ,p_activity_id            => p_activity_id
    ,p_transaction_step_id    => l_trans_step_ids
    ,p_object_version_number  => l_trans_obj_vers_nums
    ,p_rows                   => l_trans_step_rows);

    --
    -- ---------------------------------------------------------------------
    -- NOTE:We need to adjust the index which referrences l_trans_step_ids
    --    by 1 because that table was created with the index starts at 0
    --    in hr_transaction_api.get_transaction_step_info.
    -- ---------------------------------------------------------------------
    --
    ln_index := 0;

    hr_utility.set_location('Entering For Loop:1..l_trans_step_rows'||l_proc,10);
    FOR j in 1..l_trans_step_rows
    LOOP
      --
      -- Now get the transaction data for the given step
      -- Get the Phone transaction data only.
      --
      BEGIN
        FOR l_rec in csr_hatv(l_trans_step_ids(ln_index), 'P_PHONE_ID')
	    LOOP
        ----
        p_person_id := hr_transaction_api.get_number_value
          (p_transaction_step_id => l_trans_step_ids(ln_index)
          ,p_name                => 'P_PERSON_ID');
        --
        p_phone_numbers_details(i).phone_id := to_char(nvl(hr_transaction_api.get_number_value
          (p_transaction_step_id => l_trans_step_ids(ln_index)
          ,p_name                => 'P_PHONE_ID'), 0));
        --
        p_phone_numbers_details(i).phone_type := hr_transaction_api.get_varchar2_value
          (p_transaction_step_id => l_trans_step_ids(ln_index)
          ,p_name                => 'P_PHONE_TYPE');
        --
        p_phone_numbers_details(i).phone_type_meaning := hr_transaction_api.get_varchar2_Value
          (p_transaction_step_id => l_trans_step_ids(ln_index)
          ,p_name => 'P_PHONE_TYPE_MEANING');
        --
        p_phone_numbers_details(i).phone_number := hr_transaction_api.get_varchar2_value
          (p_transaction_step_id => l_trans_step_ids(ln_index)
          ,p_name                => 'P_PHONE_NUMBER');
        --
        p_phone_numbers_details(i).object_version_number := to_char(nvl(hr_transaction_api.get_number_value
          (p_transaction_step_id => l_trans_step_ids(ln_index)
          ,p_name                => 'P_OBJECT_VERSION_NUMBER'), 0));

        p_phone_numbers_details(i).attribute_category := hr_transaction_api.get_varchar2_Value
          (p_transaction_step_id => l_trans_step_ids(ln_index)
          ,p_name => 'P_ATTRIBUTE_CATEGORY');
        --
        p_phone_numbers_details(i).attribute1 := hr_transaction_api.get_varchar2_Value
          (p_transaction_step_id => l_trans_step_ids(ln_index)
          ,p_name => 'P_ATTRIBUTE1');
        --
        p_phone_numbers_details(i).attribute2 := hr_transaction_api.get_varchar2_Value
          (p_transaction_step_id => l_trans_step_ids(ln_index)
          ,p_name => 'P_ATTRIBUTE2');
        --
        p_phone_numbers_details(i).attribute3 := hr_transaction_api.get_varchar2_Value
          (p_transaction_step_id => l_trans_step_ids(ln_index)
          ,p_name => 'P_ATTRIBUTE3');
        --
        p_phone_numbers_details(i).attribute4 := hr_transaction_api.get_varchar2_Value
          (p_transaction_step_id => l_trans_step_ids(ln_index)
          ,p_name => 'P_ATTRIBUTE4');
        --
        p_phone_numbers_details(i).attribute5 := hr_transaction_api.get_varchar2_Value
          (p_transaction_step_id => l_trans_step_ids(ln_index)
          ,p_name => 'P_ATTRIBUTE5');
        --
        p_phone_numbers_details(i).attribute6 := hr_transaction_api.get_varchar2_Value
           (p_transaction_step_id => l_trans_step_ids(ln_index)
          ,p_name => 'P_ATTRIBUTE6');
        --
        p_phone_numbers_details(i).attribute7 := hr_transaction_api.get_varchar2_Value
          (p_transaction_step_id => l_trans_step_ids(ln_index)
          ,p_name => 'P_ATTRIBUTE7');
        --
        p_phone_numbers_details(i).attribute8 := hr_transaction_api.get_varchar2_Value
          (p_transaction_step_id => l_trans_step_ids(ln_index)
          ,p_name => 'P_ATTRIBUTE8');
        --
        p_phone_numbers_details(i).attribute9 := hr_transaction_api.get_varchar2_Value
          (p_transaction_step_id => l_trans_step_ids(ln_index)
          ,p_name => 'P_ATTRIBUTE9');
        --
        p_phone_numbers_details(i).attribute10 := hr_transaction_api.get_varchar2_Value
          (p_transaction_step_id => l_trans_step_ids(ln_index)
          ,p_name => 'P_ATTRIBUTE10');
        --
        p_phone_numbers_details(i).attribute11 := hr_transaction_api.get_varchar2_Value
          (p_transaction_step_id => l_trans_step_ids(ln_index)
          ,p_name => 'P_ATTRIBUTE11');
        --
        p_phone_numbers_details(i).attribute12 := hr_transaction_api.get_varchar2_Value
          (p_transaction_step_id => l_trans_step_ids(ln_index)
          ,p_name => 'P_ATTRIBUTE12');
        --
        p_phone_numbers_details(i).attribute13 := hr_transaction_api.get_varchar2_Value
          (p_transaction_step_id => l_trans_step_ids(ln_index)
          ,p_name => 'P_ATTRIBUTE13');
        --
        p_phone_numbers_details(i).attribute14 := hr_transaction_api.get_varchar2_Value
          (p_transaction_step_id => l_trans_step_ids(ln_index)
          ,p_name => 'P_ATTRIBUTE14');
        --
        p_phone_numbers_details(i).attribute15 := hr_transaction_api.get_varchar2_Value
          (p_transaction_step_id => l_trans_step_ids(ln_index)
          ,p_name => 'P_ATTRIBUTE15');
        --
        p_phone_numbers_details(i).attribute16 := hr_transaction_api.get_varchar2_Value
          (p_transaction_step_id => l_trans_step_ids(ln_index)
          ,p_name => 'P_ATTRIBUTE16');
        --
        p_phone_numbers_details(i).attribute17 := hr_transaction_api.get_varchar2_Value
          (p_transaction_step_id => l_trans_step_ids(ln_index)
          ,p_name => 'P_ATTRIBUTE17');
        --
        p_phone_numbers_details(i).attribute18 := hr_transaction_api.get_varchar2_Value
          (p_transaction_step_id => l_trans_step_ids(ln_index)
          ,p_name => 'P_ATTRIBUTE18');
        --
        p_phone_numbers_details(i).attribute19 := hr_transaction_api.get_varchar2_Value
          (p_transaction_step_id => l_trans_step_ids(ln_index)
          ,p_name => 'P_ATTRIBUTE19');
        --
        p_phone_numbers_details(i).attribute20 := hr_transaction_api.get_varchar2_Value
          (p_transaction_step_id => l_trans_step_ids(ln_index)
          ,p_name => 'P_ATTRIBUTE20');
        --
        p_phone_numbers_details(i).attribute21 := hr_transaction_api.get_varchar2_Value
          (p_transaction_step_id => l_trans_step_ids(ln_index)
          ,p_name => 'P_ATTRIBUTE21');
        --
        p_phone_numbers_details(i).attribute22 := hr_transaction_api.get_varchar2_Value
          (p_transaction_step_id => l_trans_step_ids(ln_index)
          ,p_name => 'P_ATTRIBUTE22');
        --
        p_phone_numbers_details(i).attribute23 := hr_transaction_api.get_varchar2_Value
          (p_transaction_step_id => l_trans_step_ids(ln_index)
          ,p_name => 'P_ATTRIBUTE23');
        --
        p_phone_numbers_details(i).attribute24 := hr_transaction_api.get_varchar2_Value
          (p_transaction_step_id => l_trans_step_ids(ln_index)
          ,p_name => 'P_ATTRIBUTE24');
        --
        p_phone_numbers_details(i).attribute25 := hr_transaction_api.get_varchar2_Value
          (p_transaction_step_id => l_trans_step_ids(ln_index)
          ,p_name => 'P_ATTRIBUTE25');
        --
        p_phone_numbers_details(i).attribute26 := hr_transaction_api.get_varchar2_Value
          (p_transaction_step_id => l_trans_step_ids(ln_index)
          ,p_name => 'P_ATTRIBUTE26');
        --
        p_phone_numbers_details(i).attribute27 := hr_transaction_api.get_varchar2_Value
          (p_transaction_step_id => l_trans_step_ids(ln_index)
          ,p_name => 'P_ATTRIBUTE27');
        --
        p_phone_numbers_details(i).attribute28 := hr_transaction_api.get_varchar2_Value
          (p_transaction_step_id => l_trans_step_ids(ln_index)
          ,p_name => 'P_ATTRIBUTE28');
        --
        p_phone_numbers_details(i).attribute29 := hr_transaction_api.get_varchar2_Value
          (p_transaction_step_id => l_trans_step_ids(ln_index)
          ,p_name => 'P_ATTRIBUTE29');
        --
        p_phone_numbers_details(i).attribute30 := hr_transaction_api.get_varchar2_Value
          (p_transaction_step_id => l_trans_step_ids(ln_index)
          ,p_name => 'P_ATTRIBUTE30');
        --
        p_phone_numbers_details(i).parent_id := hr_transaction_api.get_number_value
          (p_transaction_step_id => l_trans_step_ids(ln_index)
          ,p_name => 'P_PERSON_ID');

        i := i + 1;
        l_trans_rec_count  := l_trans_rec_count  + 1;
        --
        END LOOP;
        --
      EXCEPTION
        WHEN OTHERS THEN
        hr_utility.set_location('Exception:Others'||l_proc,555);
          RAISE;
      END;
        ln_index := ln_index + 1;
    END LOOP;
    hr_utility.set_location('Exiting For Loop:'||l_proc,15);

    p_trans_rec_count := l_trans_rec_count;
    hr_utility.set_location('Exiting:'||l_proc, 20);

EXCEPTION
  WHEN OTHERS THEN
    hr_utility.set_location('Exception:Others'||l_proc,555);
    RAISE;
END get_transaction_details;

PROCEDURE get_transaction_details
   (p_item_type                       in  varchar2
   ,p_item_key                        in  varchar2
   ,p_activity_id                     in  varchar2
   ,p_trans_rec_count                 out nocopy number
   ,p_person_id                       out nocopy number
   ,p_con_phone_numbers_details       in out nocopy sshr_con_phone_details_tab_typ
) IS
  --
  -- Cursor to detect phone type transaction data.
  cursor csr_hatv(cv_transaction_step_id in number,
    cv_name in varchar2) is
    select hatv.number_value
    from   hr_api_transaction_values hatv
    where  hatv.transaction_step_id = cv_transaction_step_id
    and    hatv.name                = cv_name;
  --
  l_trans_step_id                    number default null;
  -- l_trans_obj_vers_num               number default null;
  l_trans_rec_count                  integer default 0;
  l_trans_step_ids       hr_util_web.g_varchar2_tab_type;
  l_trans_obj_vers_nums  hr_util_web.g_varchar2_tab_type;
  l_trans_step_rows                  NUMBER  ;
  ln_index                           number  default 0;
  i                                  number  default 1;
  l_proc   varchar2(72)  := g_package||'get_transaction_details';

 BEGIN
  -- ------------------------------------------------------------------
  -- Check if there are any transaction rec already saved for the current
  -- transaction. This is used for re-display the Update page when a user
  -- clicks the Back button on the Review page to go back to the Update page
  -- to make further changes or to correct errors.
  -----------------------------------------------------------------------------
  -- For a given item key, there could be multiple transaction steps saved.

  hr_utility.set_location('Entering:'||l_proc, 5);
  hr_transaction_api.get_transaction_step_info
    (p_item_type              => p_item_type
    ,p_item_key               => p_item_key
    ,p_activity_id            => p_activity_id
    ,p_transaction_step_id    => l_trans_step_ids
    ,p_object_version_number  => l_trans_obj_vers_nums
    ,p_rows                   => l_trans_step_rows);

    --
    -- ---------------------------------------------------------------------
    -- NOTE:We need to adjust the index which referrences l_trans_step_ids
    --    by 1 because that table was created with the index starts at 0
    --    in hr_transaction_api.get_transaction_step_info.
    -- ---------------------------------------------------------------------
    --
    ln_index := 0;

    hr_utility.set_location('Entering For Loop:1..l_trans_step_rows'||l_proc,10);
    FOR j in 1..l_trans_step_rows
    LOOP
      --
      -- Now get the transaction data for the given step
      -- Get the Phone transaction data only.
      --
      BEGIN
        FOR l_rec in csr_hatv(l_trans_step_ids(ln_index), 'P_PHONE_ID')
	    LOOP
        ----
        p_person_id := hr_transaction_api.get_number_value
          (p_transaction_step_id => l_trans_step_ids(ln_index)
          ,p_name                => 'P_PERSON_ID');
        --
        p_con_phone_numbers_details(i).phone_id := to_char(nvl(hr_transaction_api.get_number_value
          (p_transaction_step_id => l_trans_step_ids(ln_index)
          ,p_name                => 'P_PHONE_ID'), 0));
        --
        p_con_phone_numbers_details(i).phone_type := hr_transaction_api.get_varchar2_value
          (p_transaction_step_id => l_trans_step_ids(ln_index)
          ,p_name                => 'P_PHONE_TYPE');
        --
        p_con_phone_numbers_details(i).phone_type_meaning := hr_transaction_api.get_varchar2_Value
          (p_transaction_step_id => l_trans_step_ids(ln_index)
          ,p_name => 'P_PHONE_TYPE_MEANING');
        --
        p_con_phone_numbers_details(i).phone_number := hr_transaction_api.get_varchar2_value
          (p_transaction_step_id => l_trans_step_ids(ln_index)
          ,p_name                => 'P_PHONE_NUMBER');
        --
        p_con_phone_numbers_details(i).object_version_number := to_char(nvl(hr_transaction_api.get_number_value
          (p_transaction_step_id => l_trans_step_ids(ln_index)
          ,p_name                => 'P_OBJECT_VERSION_NUMBER'), 0));

        p_con_phone_numbers_details(i).attribute_category := hr_transaction_api.get_varchar2_Value
          (p_transaction_step_id => l_trans_step_ids(ln_index)
          ,p_name => 'P_ATTRIBUTE_CATEGORY');
        --
        p_con_phone_numbers_details(i).attribute1 := hr_transaction_api.get_varchar2_Value
          (p_transaction_step_id => l_trans_step_ids(ln_index)
          ,p_name => 'P_ATTRIBUTE1');
        --
        p_con_phone_numbers_details(i).attribute2 := hr_transaction_api.get_varchar2_Value
          (p_transaction_step_id => l_trans_step_ids(ln_index)
          ,p_name => 'P_ATTRIBUTE2');
        --
        p_con_phone_numbers_details(i).attribute3 := hr_transaction_api.get_varchar2_Value
          (p_transaction_step_id => l_trans_step_ids(ln_index)
          ,p_name => 'P_ATTRIBUTE3');
        --
        p_con_phone_numbers_details(i).attribute4 := hr_transaction_api.get_varchar2_Value
          (p_transaction_step_id => l_trans_step_ids(ln_index)
          ,p_name => 'P_ATTRIBUTE4');
        --
        p_con_phone_numbers_details(i).attribute5 := hr_transaction_api.get_varchar2_Value
          (p_transaction_step_id => l_trans_step_ids(ln_index)
          ,p_name => 'P_ATTRIBUTE5');
        --
        p_con_phone_numbers_details(i).attribute6 := hr_transaction_api.get_varchar2_Value
           (p_transaction_step_id => l_trans_step_ids(ln_index)
          ,p_name => 'P_ATTRIBUTE6');
        --
        p_con_phone_numbers_details(i).attribute7 := hr_transaction_api.get_varchar2_Value
          (p_transaction_step_id => l_trans_step_ids(ln_index)
          ,p_name => 'P_ATTRIBUTE7');
        --
        p_con_phone_numbers_details(i).attribute8 := hr_transaction_api.get_varchar2_Value
          (p_transaction_step_id => l_trans_step_ids(ln_index)
          ,p_name => 'P_ATTRIBUTE8');
        --
        p_con_phone_numbers_details(i).attribute9 := hr_transaction_api.get_varchar2_Value
          (p_transaction_step_id => l_trans_step_ids(ln_index)
          ,p_name => 'P_ATTRIBUTE9');
        --
        p_con_phone_numbers_details(i).attribute10 := hr_transaction_api.get_varchar2_Value
          (p_transaction_step_id => l_trans_step_ids(ln_index)
          ,p_name => 'P_ATTRIBUTE10');
        --
        p_con_phone_numbers_details(i).attribute11 := hr_transaction_api.get_varchar2_Value
          (p_transaction_step_id => l_trans_step_ids(ln_index)
          ,p_name => 'P_ATTRIBUTE11');
        --
        p_con_phone_numbers_details(i).attribute12 := hr_transaction_api.get_varchar2_Value
          (p_transaction_step_id => l_trans_step_ids(ln_index)
          ,p_name => 'P_ATTRIBUTE12');
        --
        p_con_phone_numbers_details(i).attribute13 := hr_transaction_api.get_varchar2_Value
          (p_transaction_step_id => l_trans_step_ids(ln_index)
          ,p_name => 'P_ATTRIBUTE13');
        --
        p_con_phone_numbers_details(i).attribute14 := hr_transaction_api.get_varchar2_Value
          (p_transaction_step_id => l_trans_step_ids(ln_index)
          ,p_name => 'P_ATTRIBUTE14');
        --
        p_con_phone_numbers_details(i).attribute15 := hr_transaction_api.get_varchar2_Value
          (p_transaction_step_id => l_trans_step_ids(ln_index)
          ,p_name => 'P_ATTRIBUTE15');
        --
        p_con_phone_numbers_details(i).attribute16 := hr_transaction_api.get_varchar2_Value
          (p_transaction_step_id => l_trans_step_ids(ln_index)
          ,p_name => 'P_ATTRIBUTE16');
        --
        p_con_phone_numbers_details(i).attribute17 := hr_transaction_api.get_varchar2_Value
          (p_transaction_step_id => l_trans_step_ids(ln_index)
          ,p_name => 'P_ATTRIBUTE17');
        --
        p_con_phone_numbers_details(i).attribute18 := hr_transaction_api.get_varchar2_Value
          (p_transaction_step_id => l_trans_step_ids(ln_index)
          ,p_name => 'P_ATTRIBUTE18');
        --
        p_con_phone_numbers_details(i).attribute19 := hr_transaction_api.get_varchar2_Value
          (p_transaction_step_id => l_trans_step_ids(ln_index)
          ,p_name => 'P_ATTRIBUTE19');
        --
        p_con_phone_numbers_details(i).attribute20 := hr_transaction_api.get_varchar2_Value
          (p_transaction_step_id => l_trans_step_ids(ln_index)
          ,p_name => 'P_ATTRIBUTE20');
        --
        p_con_phone_numbers_details(i).attribute21 := hr_transaction_api.get_varchar2_Value
          (p_transaction_step_id => l_trans_step_ids(ln_index)
          ,p_name => 'P_ATTRIBUTE21');
        --
        p_con_phone_numbers_details(i).attribute22 := hr_transaction_api.get_varchar2_Value
          (p_transaction_step_id => l_trans_step_ids(ln_index)
          ,p_name => 'P_ATTRIBUTE22');
        --
        p_con_phone_numbers_details(i).attribute23 := hr_transaction_api.get_varchar2_Value
          (p_transaction_step_id => l_trans_step_ids(ln_index)
          ,p_name => 'P_ATTRIBUTE23');
        --
        p_con_phone_numbers_details(i).attribute24 := hr_transaction_api.get_varchar2_Value
          (p_transaction_step_id => l_trans_step_ids(ln_index)
          ,p_name => 'P_ATTRIBUTE24');
        --
        p_con_phone_numbers_details(i).attribute25 := hr_transaction_api.get_varchar2_Value
          (p_transaction_step_id => l_trans_step_ids(ln_index)
          ,p_name => 'P_ATTRIBUTE25');
        --
        p_con_phone_numbers_details(i).attribute26 := hr_transaction_api.get_varchar2_Value
          (p_transaction_step_id => l_trans_step_ids(ln_index)
          ,p_name => 'P_ATTRIBUTE26');
        --
        p_con_phone_numbers_details(i).attribute27 := hr_transaction_api.get_varchar2_Value
          (p_transaction_step_id => l_trans_step_ids(ln_index)
          ,p_name => 'P_ATTRIBUTE27');
        --
        p_con_phone_numbers_details(i).attribute28 := hr_transaction_api.get_varchar2_Value
          (p_transaction_step_id => l_trans_step_ids(ln_index)
          ,p_name => 'P_ATTRIBUTE28');
        --
        p_con_phone_numbers_details(i).attribute29 := hr_transaction_api.get_varchar2_Value
          (p_transaction_step_id => l_trans_step_ids(ln_index)
          ,p_name => 'P_ATTRIBUTE29');
        --
        p_con_phone_numbers_details(i).attribute30 := hr_transaction_api.get_varchar2_Value
          (p_transaction_step_id => l_trans_step_ids(ln_index)
          ,p_name => 'P_ATTRIBUTE30');
        --
        p_con_phone_numbers_details(i).parent_id := hr_transaction_api.get_number_value
          (p_transaction_step_id => l_trans_step_ids(ln_index)
          ,p_name => 'P_PERSON_ID');

        --bug#3542613
        p_con_phone_numbers_details(i).contact_set := hr_transaction_api.get_varchar2_Value
          (p_transaction_step_id => l_trans_step_ids(ln_index)
          ,p_name                => 'P_CONTACT_SET');

        i := i + 1;
        l_trans_rec_count  := l_trans_rec_count  + 1;
        --
        END LOOP;
        --
      EXCEPTION
        WHEN OTHERS THEN
          hr_utility.set_location('Exception:Others'||l_proc,555);
          RAISE;
      END;
        ln_index := ln_index + 1;
    END LOOP;
    hr_utility.set_location('Exiting For Loop:'||l_proc,15);

    p_trans_rec_count := l_trans_rec_count;
    hr_utility.set_location('Exiting:'||l_proc, 20);

EXCEPTION
  WHEN OTHERS THEN
          hr_utility.set_location('Exception:Others'||l_proc,555);
    RAISE;
END get_transaction_details;




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
l_count INTEGER;
l_deleted_phone_count INTEGER;
l_phone_id per_phones.phone_id%TYPE;
l_phone_ovn per_phones.object_version_number%TYPE;
l_phone_type per_phones.phone_type%TYPE;
l_phone_number per_phones.phone_number%TYPE;
l_deleted_ovn per_phones.object_version_number%TYPE;
l_effective_date date;
l_person_id per_all_people_f.person_id%TYPE;
l_per_or_contact varchar2(30);
l_trs_object_version_number
    hr_api_transaction_steps.object_version_number%type;
l_transaction_step_id
    hr_api_transaction_steps.transaction_step_id%type;
l_check_for_sfl varchar2(10);
l_sfl_g_contact_step_id NUMBER;
l_proc   varchar2(72)  := g_package||'process_api';


BEGIN
        hr_utility.set_location('Entering:'||l_proc, 5);
        if (p_effective_date is not null) then
          hr_utility.set_location('p_effective_date is not null:'||l_proc,10);
          l_effective_date:= to_date(p_effective_date,g_date_format);
        else
          hr_utility.set_location('p_effective_date is  null:'||l_proc,15);
          l_effective_date:= to_date(
            hr_transaction_ss.get_wf_effective_date
                (p_transaction_step_id => p_transaction_step_id),g_date_format);
        end if;

        l_person_id :=
                hr_transaction_api.get_number_Value
                (p_transaction_step_id =>
                        p_transaction_step_id
                ,p_name => 'P_PERSON_ID');

        savepoint process_phones;
        l_phone_number :=
                        hr_transaction_api.get_varchar2_Value
                        (p_transaction_step_id =>
                                p_transaction_step_id
                        ,p_name => 'P_PHONE_NUMBER');
        l_phone_ovn :=
                       hr_transaction_api.get_number_Value
                       (p_transaction_step_id =>
                                p_transaction_step_id
                        ,p_name => 'P_OBJECT_VERSION_NUMBER');
        l_phone_type :=
                        hr_transaction_api.get_varchar2_Value
                        (p_transaction_step_id =>
                                p_transaction_step_id
                        ,p_name => 'P_PHONE_TYPE');
        l_phone_id :=
                        hr_transaction_api.get_number_Value
                        (p_transaction_step_id =>
                                        p_transaction_step_id
                        ,p_name => 'P_PHONE_ID');
        IF l_phone_id IS NULL THEN
        hr_utility.set_location('IF l_phone_id IS NULL THEN:'||l_proc,20);
                  -- It's a new phone number.
           --
           -- PB : Add
           --
          --
           if l_person_id is null or l_person_id < 0 then
              --
              -- This is the case where the contact was created.
              -- So get contact person id from the global.
              --
              -- StartRegistration
              hr_utility.set_location('l_person_id is null or l_person_id < 0:'||l_proc,25);
              l_per_or_contact :=
                        hr_transaction_api.get_varchar2_Value
                        (p_transaction_step_id =>
                                        p_transaction_step_id
                        ,p_name => 'P_PER_OR_CONTACT');
              --
              hr_utility.set_location('Phone.process_api l_per_or_contact : '
                                     || l_per_or_contact, 22);
              --
    if l_per_or_contact = 'CONTACT' or l_per_or_contact = 'EMER_CR_NEW_CONT' or l_per_or_contact = 'EMRG_OVRW_UPD' or l_per_or_contact = 'EMRG_OVRW_DEL' or  l_per_or_contact = 'EMER_CR_NEW_REL'
          or  l_per_or_contact = 'DPDNT_CR_NEW_CONT' or  l_per_or_contact = 'DPDNT_OVRW_UPD'  or  l_per_or_contact = 'DPDNT_OVRW_DEL' or  l_per_or_contact = 'DPDNT_CR_NEW_REL'       then

                 l_person_id := hr_process_contact_ss.g_contact_person_id;

              -- In case of SaveForLater run process_create_contact_api
              -- in commit mode to get the g_contact_person_id
              -- this will be rolled back with the current step
              -- after validating the current transaction step

              -- In Case of SFL also person id is available due to recent changes
              -- in hr_transaction_ss v 115.18
              -- So the SFL specific code is not required anymore.

              else
                 -- l_per_or_contact = 'PERSON'
                 -- l_person_id := hr_process_person_ss.g_person_id;
                 -- Adding the session id check to avoid connection pooling problems.
                 if (( hr_process_person_ss.g_person_id is not null) and
                       (hr_process_person_ss.g_session_id= ICX_SEC.G_SESSION_ID)) then
                     hr_utility.set_location('hr_process_person_ss.g_person_id is not null AND hr_process_person_ss.g_session_id= ICX_SEC.G_SESSION_ID:'||l_proc,30);
                     l_person_id := hr_process_person_ss.g_person_id;
                 end if;
              end if;
              --
           end if;
           --
           hr_utility.set_location('Phone.process_api l_person_id : '
                                     || l_person_id, 22);
           hr_phone_api.create_phone
                        (p_validate => FALSE
                        ,p_phone_id => l_phone_id
                        ,p_phone_number => l_phone_number
                        ,p_object_version_number => l_phone_ovn
                        ,p_phone_type => l_phone_type
                        ,p_effective_date => l_effective_date
                        ,p_parent_id => l_person_id
                        ,p_parent_table => 'PER_ALL_PEOPLE_F'
                        ,p_date_from =>  l_Effective_date
                        ,p_attribute_category => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE_CATEGORY')
                        ,p_attribute1 => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE1')
			,p_attribute2 => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE2')
			,p_attribute3 => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE3')
			,p_attribute4 => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE4')
			,p_attribute5 => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE5')
			,p_attribute6 => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE6')
			,p_attribute7 => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE7')
			,p_attribute8 => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE8')
			,p_attribute9 => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE9')
			,p_attribute10 => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE10')
			,p_attribute11 => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE11')
			,p_attribute12 => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE12')
			,p_attribute13 => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE13')
			,p_attribute14 => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE14')
			,p_attribute15 => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE15')
			,p_attribute16 => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE16')
			,p_attribute17 => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE17')
			,p_attribute18 => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE18')
			,p_attribute19 => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE19')
			,p_attribute20 => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE20')
			,p_attribute21 => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE21')
			,p_attribute22 => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE22')
			,p_attribute23 => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE23')
			,p_attribute24 => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE24')
			,p_attribute25 => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE25')
			,p_attribute26 => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE26')
			,p_attribute27 => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE27')
			,p_attribute28 => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE28')
			,p_attribute29 => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE29')
			,p_attribute30 => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE30'));
        ELSIF  l_phone_type = 'DELETE' THEN
               -- Delete the existing phone nuber.
                       hr_utility.set_location('l_phone_type = DELETE THEN:'||l_proc,35);
                       hr_phone_api.delete_phone
                        (p_validate => FALSE
                        ,p_phone_id => l_phone_id
                        ,p_object_version_number => l_phone_ovn
                        );
        ELSE
               -- Update the existing phone number.
                        hr_phone_api.update_phone
                        (p_validate => FALSE
                        ,p_phone_id => l_phone_id
                        ,p_phone_number => l_phone_number
                        ,p_phone_type => l_phone_type
                        ,p_object_version_number => l_phone_ovn
                        ,p_effective_date =>  l_effective_date
                        ,p_attribute_category => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE_CATEGORY')
                        ,p_attribute1 => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE1')
			,p_attribute2 => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE2')
			,p_attribute3 => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE3')
			,p_attribute4 => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE4')
			,p_attribute5 => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE5')
			,p_attribute6 => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE6')
			,p_attribute7 => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE7')
			,p_attribute8 => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE8')
			,p_attribute9 => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE9')
			,p_attribute10 => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE10')
			,p_attribute11 => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE11')
			,p_attribute12 => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE12')
			,p_attribute13 => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE13')
			,p_attribute14 => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE14')
			,p_attribute15 => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE15')
			,p_attribute16 => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE16')
			,p_attribute17 => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE17')
			,p_attribute18 => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE18')
			,p_attribute19 => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE19')
			,p_attribute20 => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE20')
			,p_attribute21 => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE21')
			,p_attribute22 => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE22')
			,p_attribute23 => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE23')
			,p_attribute24 => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE24')
			,p_attribute25 => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE25')
			,p_attribute26 => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE26')
			,p_attribute27 => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE27')
			,p_attribute28 => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE28')
			,p_attribute29 => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE29')
			,p_attribute30 => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE30'));
        END IF; -- If it's a new of existing phone number ?

        IF p_validate = TRUE THEN
                hr_utility.set_location('IF p_validate = TRUE THEN:'||l_proc,40);
                ROLLBACK TO process_phones;
        END IF;
        hr_utility.set_location('Exiting:'||l_proc,45);

        EXCEPTION
        WHEN hr_utility.hr_error THEN
        -- ---------------------------------------------------
        -- ---------------------------------------------------
        -- an application error has been raised so we must
        -- redisplay the web form to display the error
        -- ----------------------------------------------------
        hr_utility.set_location('Exception:hr_utility.hr_error'||l_proc,555);
        RAISE;
        WHEN OTHERS THEN
        hr_utility.set_location('Exception:Others'||l_proc,560);
        RAISE;
/*
        hr_util_disp_web.display_fatal_errors
        (p_message => UPPER(g_package || '.process_api: '
        || SQLERRM));
*/
END process_api;
end hr_process_phone_numbers_ss;

/

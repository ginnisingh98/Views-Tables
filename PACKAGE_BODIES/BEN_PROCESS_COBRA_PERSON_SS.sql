--------------------------------------------------------
--  DDL for Package Body BEN_PROCESS_COBRA_PERSON_SS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PROCESS_COBRA_PERSON_SS" AS
/* $Header: bencbrwf.pkb 115.7 2004/02/26 04:01:41 vvprabhu noship $*/

-- Global variables
  g_package               constant varchar2(75):='BEN_PROCESS_COBRA_PERSON_SS.';
  g_wf_review_regn_itm_attr_name  constant varchar2(2000)
                                  := 'HR_REVIEW_REGION_ITEM';

  g_data_error                   exception;

--
-- ---------------------------------------------------------------------------+
-- ----------------------------- < process_api > -----------------------------+
-- ---------------------------------------------------------------------------+
-- Purpose: This procedure will be invoked in workflow notification
--          when an approver approves all the changes.  This procedure
--          will call the api to update to the database with p_validate
--          equal to false.
-- ---------------------------------------------------------------------------+
PROCEDURE process_api
          (p_validate IN BOOLEAN DEFAULT FALSE
          ,p_transaction_step_id IN NUMBER)
IS
--
  l_effective_start_date             date default null;
  l_effective_end_date               date default null;
  l_full_name                        per_all_people_f.full_name%type;
  l_comment_id                       per_all_people_f.comment_id%type;
  l_name_combination_warning         boolean default null;
  l_assign_payroll_warning           boolean default null;
  l_orig_hire_warning                boolean default null;
  l_employee_number                  per_all_people_f.employee_number%type
                                     := hr_api.g_varchar2;
  l_ovn                              number default null;
  l_person_id                        per_all_people_f.person_id%type
                                     default null;

--Start Registration

  l_assignment_id                    number default null;
  l_povn                             number default null;
  l_aovn                             number default null;
  l_assignment_sequence              number default null;
  l_assignment_number                number default null;
  l_assignment_extra_info_id         number;
  l_aei_object_version_number        number;
  l_flow_name                        varchar2(30) default null;
  l_asg_effective_end_date           date;
  l_asg_effective_start_date         date;
  prflvalue                          varchar2(2000) default null;
  l_item_type                        wf_items.item_type%type default null;
  l_item_key                         wf_items.item_key%type default null;
  l_transaction_step                 number default null;
  l_life_event_transaction_step      number default null;
  l_user_id               number;
  l_user_name             fnd_user.user_name%TYPE;
  l_user_pswd             fnd_user.encrypted_user_password%TYPE;
  l_pswd_hint             fnd_user.description%TYPE;
  l_api_error             boolean;
  l_respons_id            number ;
  l_respons_appl_id       number ;
  l_owner                 number ;
  l_session_number        number ;
  l_start_date            date;
  l_end_date              date;
  l_last_logon_date       date;
  l_password_date         date;
  l_password_accesses_left                 number ;
  l_password_lifespan_accesses             number ;
  l_password_lifespan_days                 number ;
  l_employee_id                            number ;
  l_customer_id                            number ;
  l_supplier_id                            number ;
  l_business_group_id                      number ;
  l_email_address                          varchar2(240);
  l_fax                                    varchar2(80);
  l_ptnl_ler ben_ptnl_ler_for_per%ROWTYPE;
  l_dummy_num number;
  l_life_event_ovn number;
  l_life_event_eff_date   date;
  --l_ptnl_ler_for_per_id                    varchar2(80);
  --l_ler_csd_by_ptnl_ler_id                 ben_ptnl_ler_for_per.csd_by_ptnl_ler_for_per_id%type;
  l_ler_lf_evt_ocrd_dt                     ben_ptnl_ler_for_per.lf_evt_ocrd_dt%type;
  --l_new_ler_lf_evt_ocrd_dt                 varchar2(80);
  l_flow_mode             varchar2(80);
  l_subflow_mode          varchar2(80);
  l_life_event_name       ben_ler_f.name%type;
  --l_evt_transaction_step_id varchar2(80);
  --l_error_message         long default null;


BEGIN
--
  SAVEPOINT process_basic_details;

--
-- Get the person_id first.  If it is null, that means we'll create a new
-- employee.  If it is not null, we will do an update to the person record.

  l_person_id := hr_transaction_api.get_number_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PERSON_ID');
--
  l_employee_number := hr_transaction_api.get_varchar2_value
                          (p_transaction_step_id => p_transaction_step_id
                          ,p_name => 'P_EMPLOYEE_NUMBER');
--
  l_ovn := hr_transaction_api.get_number_value
             (p_transaction_step_id => p_transaction_step_id
             ,p_name => 'P_OBJECT_VERSION_NUMBER');
--
  l_flow_name := hr_transaction_api.get_varchar2_value
                          (p_transaction_step_id => p_transaction_step_id
                          ,p_name => 'P_FLOW_NAME');

  l_item_type := hr_transaction_api.get_varchar2_value
                          (p_transaction_step_id => p_transaction_step_id
                          ,p_name => 'P_ITEM_TYPE');

  l_item_key := hr_transaction_api.get_varchar2_value
                          (p_transaction_step_id => p_transaction_step_id
                          ,p_name => 'P_ITEM_KEY');
--

  if l_flow_name = 'Cobra' then
   hr_contact_api.create_person
    (p_validate                => p_validate
 --
    --,p_start_date              => sysdate
    ,p_start_date              => hr_transaction_api.get_date_value
                                   (p_transaction_step_id => p_transaction_step_id
                                   ,p_name => 'P_DATE_START')
--
    ,p_business_group_id       => hr_transaction_api.get_number_value
                                   (p_transaction_step_id => p_transaction_step_id
                                   ,p_name => 'P_BUSINESS_GROUP_ID')
--
    ,p_last_name               => hr_transaction_api.get_varchar2_value
                                  (p_transaction_step_id => p_transaction_step_id
                                  ,p_name => 'P_LAST_NAME')
--
    ,p_sex                     => hr_transaction_api.get_varchar2_value
                                   (p_transaction_step_id => p_transaction_step_id
                                   ,p_name => 'P_SEX')
--
    ,p_person_type_id          => null
--
    ,p_comments                => hr_transaction_api.get_varchar2_value
                                   (p_transaction_step_id => p_transaction_step_id
                                   ,p_name => 'P_PER_COMMENTS')
--
    ,p_date_employee_data_verified => hr_transaction_api.get_date_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_DATE_EMPLOYEE_DATA_VERIFIED')
--
    ,p_date_of_birth            => hr_transaction_api.get_date_value
                                   (p_transaction_step_id => p_transaction_step_id
                                   ,p_name => 'P_DATE_OF_BIRTH')
--
    ,p_email_address            => hr_transaction_api.get_varchar2_value
                                   (p_transaction_step_id => p_transaction_step_id
                                   ,p_name => 'P_EMAIL_ADDRESS')
--
    ,p_expense_check_send_to_addres => hr_transaction_api.get_varchar2_value
                                   (p_transaction_step_id => p_transaction_step_id
                                   ,p_name => 'P_EXPENSE_CHECK_SEND_TO_ADDRES')
--
    ,p_first_name               => hr_transaction_api.get_varchar2_value
                                   (p_transaction_step_id => p_transaction_step_id
                                   ,p_name => 'P_FIRST_NAME')
--
    ,p_known_as                 => hr_transaction_api.get_varchar2_value
                                    (p_transaction_step_id => p_transaction_step_id
                                    ,p_name => 'P_KNOWN_AS')
--
    ,p_marital_status           => hr_transaction_api.get_varchar2_value
                                   (p_transaction_step_id => p_transaction_step_id
                                   ,p_name => 'P_MARITAL_STATUS')
--
    ,p_middle_names             => hr_transaction_api.get_varchar2_value
                                   (p_transaction_step_id => p_transaction_step_id
                                   ,p_name => 'P_MIDDLE_NAMES')
--
    ,p_nationality              => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_NATIONALITY')
--
    ,p_national_identifier      => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_NATIONAL_IDENTIFIER')
--
    ,p_previous_last_name       => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PREVIOUS_LAST_NAME')
--
    ,p_registered_disabled_flag => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_REGISTERED_DISABLED_FLAG')
--
    ,p_title                    => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_TITLE')
--
    ,p_vendor_id                => hr_transaction_api.get_number_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_VENDOR_ID')
--
    ,p_work_telephone           => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_WORK_TELEPHONE')
--
    ,p_attribute_category       => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE_CATEGORY')
--
    ,p_attribute1               => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE1')
--
    ,p_attribute2               => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE2')
--
    ,p_attribute3               => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE3')
--
    ,p_attribute4               => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE4')
--
    ,p_attribute5               => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE5')
--
    ,p_attribute6               => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE6')
--
    ,p_attribute7               => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE7')
--
    ,p_attribute8               => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE8')
--
    ,p_attribute9               => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE9')
--
    ,p_attribute10              => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE10')
--
    ,p_attribute11              => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE11')
--
    ,p_attribute12              => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE12')
--
    ,p_attribute13              => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE13')
--
    ,p_attribute14              => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE14')
--
    ,p_attribute15              => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE15')
--
    ,p_attribute16              => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE16')
--
    ,p_attribute17              => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE17')
--
    ,p_attribute18              => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE18')
--
    ,p_attribute19              => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE19')
--
    ,p_attribute20              => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE20')
--
    ,p_attribute21              => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE21')
--
    ,p_attribute22              => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE22')
--
    ,p_attribute23              => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE23')
--
    ,p_attribute24              => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE24')
--
    ,p_attribute25              => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE25')
--
    ,p_attribute26              => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE26')
--
    ,p_attribute27              => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE27')
--
    ,p_attribute28              => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE28')
--
    ,p_attribute29              => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE29')
--
    ,p_attribute30              => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_ATTRIBUTE30')
--
    ,p_per_information_category => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION_CATEGORY')
--
    ,p_per_information1         => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION1')
--
    ,p_per_information2         => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION2')
--
    ,p_per_information3         => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION3')
--
    ,p_per_information4         => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION4')
--
    ,p_per_information5         => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION5')
--
    ,p_per_information6         => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION6')
--
    ,p_per_information7         => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION7')
--
    ,p_per_information8         => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION8')
--
    ,p_per_information9         => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION9')
--
    ,p_per_information10        => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION10')
--
    ,p_per_information11        => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION11')

--
    ,p_per_information12        => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION12')
--
    ,p_per_information13        => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION13')
--
    ,p_per_information14        => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION14')
--
    ,p_per_information15        => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION15')
--
    ,p_per_information16        => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION16')
--
    ,p_per_information17        => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION17')
--
    ,p_per_information18        => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION18')
--
    ,p_per_information19        => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION19')
--
    ,p_per_information20        => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION20')
--
    ,p_per_information21        => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION21')
--
    ,p_per_information22        => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION22')
--
    ,p_per_information23        => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION23')
--
    ,p_per_information24        => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION24')
--
    ,p_per_information25        => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION25')
--
    ,p_per_information26        => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION26')
--
    ,p_per_information27        => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION27')
--
    ,p_per_information28        => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION28')
--
    ,p_per_information29        => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION29')
--
    ,p_per_information30        => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PER_INFORMATION30')
--
    ,p_correspondence_language  => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_CORRESPONDENCE_LANGUAGE')
--
    ,p_honors                   => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_HONORS')
--
    ,p_pre_name_adjunct         => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_PRE_NAME_ADJUNCT')
--
    ,p_suffix                   => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_SUFFIX')
--
    ,p_town_of_birth           => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_TOWN_OF_BIRTH')
--
    ,p_region_of_birth         => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_REGION_OF_BIRTH')
--
    ,p_country_of_birth        => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_COUNTRY_OF_BIRTH')
--
    ,p_global_person_id        => hr_transaction_api.get_varchar2_value
                                (p_transaction_step_id => p_transaction_step_id
                                ,p_name => 'P_GLOBAL_PERSON_ID')
--
    ,p_person_id               => l_person_id
    ,p_object_version_number   => l_povn
    ,p_effective_start_date    => l_effective_start_Date
    ,p_effective_end_date      => l_effective_end_Date
    ,p_full_name               => l_full_name
    ,p_comment_id              => l_comment_id
    ,p_name_combination_warning=> l_name_combination_warning
    ,p_orig_hire_warning       => l_orig_hire_warning
    );

   prflvalue := fnd_profile.value('BEN_USER_TO_ORG_LINK');

   ben_assignment_api.create_ben_asg
        (p_validate                      => p_validate  --in     boolean  default false
         ,p_event_mode                   => false
         --,p_effective_date               => trunc(sysdate)
         ,p_effective_date               => hr_transaction_api.get_date_value
                                           (p_transaction_step_id => p_transaction_step_id
                                           ,p_name => 'P_DATE_START')
         ,p_person_id                    => l_person_id
         ,p_organization_id              => nvl(prflvalue,hr_transaction_api.get_number_value
                                        (p_transaction_step_id => p_transaction_step_id
                                         ,p_name => 'P_BUSINESS_GROUP_ID'))
         ,p_assignment_status_type_id    => 1
         ,p_assignment_id                => l_assignment_id  --   out number
         ,p_object_version_number        => l_aovn ---   out nocopy number
         ,p_effective_start_date         => l_asg_effective_start_date   --   out date
         ,p_effective_end_date           => l_asg_effective_end_date    --   out date
         ,p_assignment_extra_info_id     => l_assignment_extra_info_id
         ,p_aei_object_version_number    => l_aei_object_version_number
         );
  end if;
-- end cobra codes
--
   l_life_event_transaction_step := to_number(wf_engine.GetItemAttrText
                    (itemtype   => l_item_type,
                     itemkey    => l_item_key,
                     aname      =>'LIFE_EVENT_TRANSACTION_STEP'));
   if l_life_event_transaction_step is not null then
      ben_create_ptnl_ler_ss.get_ptnl_ler_data_from_tt
     (p_transaction_step_id             => l_life_event_transaction_step
     ,p_csd_by_ptnl_ler_for_per_id   =>  l_ptnl_ler.csd_by_ptnl_ler_for_per_id   -- in  number    default null
     ,p_lf_evt_ocrd_dt               =>  l_ler_lf_evt_ocrd_dt               -- in  out date
     ,p_ptnl_ler_for_per_stat_cd     =>  l_ptnl_ler.ptnl_ler_for_per_stat_cd     -- in  varchar2  default null
     ,p_ptnl_ler_for_per_src_cd      =>  l_ptnl_ler.ptnl_ler_for_per_src_cd      -- in  varchar2  default null
     ,p_mnl_dt                       =>  l_ptnl_ler.mnl_dt                       -- in  date      default null
     ,p_enrt_perd_id                 =>  l_ptnl_ler.enrt_perd_id                 -- in  number    default null
     ,p_ler_id                       =>  l_ptnl_ler.ler_id                       -- in  number    default null
     ,p_person_id                    =>  l_ptnl_ler.person_id                    -- in  number    default null
     ,p_business_group_id            =>  l_ptnl_ler.business_group_id            -- in  number    default null
     ,p_dtctd_dt                     =>  l_ptnl_ler.dtctd_dt                     -- in  date      default null
     ,p_procd_dt                     =>  l_ptnl_ler.procd_dt                     -- in  date      default null
     ,p_unprocd_dt                   =>  l_ptnl_ler.unprocd_dt                   -- in  date      default null
     ,p_voidd_dt                     =>  l_ptnl_ler.voidd_dt                     -- in  date      default null
     ,p_mnlo_dt                      =>  l_ptnl_ler.mnlo_dt                      -- in  date      default null
     ,p_ntfn_dt                      =>  l_ptnl_ler.ntfn_dt                      -- in  date      default null
     ,p_request_id                   =>  l_ptnl_ler.request_id                   -- in  number    default null
     ,p_program_application_id       =>  l_ptnl_ler.program_application_id       -- in  number    default null
     ,p_program_id                   =>  l_ptnl_ler.program_id                   -- in  number    default null
     ,p_program_update_date          =>  l_ptnl_ler.program_update_date          -- in  date      default null
     ,p_effective_date               => l_life_event_eff_date
     ,p_flow_mode                    => l_flow_mode
     ,p_subflow_mode                 => l_subflow_mode
     ,p_life_event_name              => l_life_event_name
     );

     --l_new_ler_lf_evt_ocrd_dt := to_char(l_ler_lf_evt_ocrd_dt,hr_transaction_ss.g_date_format);

     ben_ptnl_ler_for_per_api.create_ptnl_ler_for_per
  (p_validate                     =>  false
  ,p_ptnl_ler_for_per_id          =>  l_dummy_num                               -- out number
  ,p_csd_by_ptnl_ler_for_per_id   =>  l_ptnl_ler.csd_by_ptnl_ler_for_per_id   -- in  number    default null
  ,p_lf_evt_ocrd_dt               =>  l_ler_lf_evt_ocrd_dt               -- in  date      default null
  ,p_ptnl_ler_for_per_stat_cd     =>  l_ptnl_ler.ptnl_ler_for_per_stat_cd     -- in  varchar2  default null
  ,p_ptnl_ler_for_per_src_cd      =>  l_ptnl_ler.ptnl_ler_for_per_src_cd      -- in  varchar2  default null
  ,p_mnl_dt                       =>  l_ptnl_ler.mnl_dt                       -- in  date      default null
  ,p_enrt_perd_id                 =>  l_ptnl_ler.enrt_perd_id                 -- in  number    default null
  ,p_ler_id                       =>  l_ptnl_ler.ler_id                       -- in  number    default null
  ,p_person_id                    =>  l_person_id                    -- in  number    default null
  ,p_business_group_id            =>  l_ptnl_ler.business_group_id            -- in  number    default null
  ,p_dtctd_dt                     =>  l_ptnl_ler.dtctd_dt                     -- in  date      default null
  ,p_procd_dt                     =>  l_ptnl_ler.procd_dt                     -- in  date      default null
  ,p_unprocd_dt                   =>  l_ptnl_ler.unprocd_dt                   -- in  date      default null
  ,p_voidd_dt                     =>  l_ptnl_ler.voidd_dt                     -- in  date      default null
  ,p_mnlo_dt                      =>  l_ptnl_ler.mnlo_dt                      -- in  date      default null
  ,p_ntfn_dt                      =>  l_ptnl_ler.ntfn_dt                      -- in  date      default null
  ,p_request_id                   =>  l_ptnl_ler.request_id                   -- in  number    default null
  ,p_program_application_id       =>  l_ptnl_ler.program_application_id       -- in  number    default null
  ,p_program_id                   =>  l_ptnl_ler.program_id                   -- in  number    default null
  ,p_program_update_date          =>  l_ptnl_ler.program_update_date          -- in  date      default null
  ,p_object_version_number        =>  l_life_event_ovn                                     -- out number
  ,p_effective_date               =>  l_life_event_eff_date               --in  date
  );

     /*ben_create_ptnl_ler_ss.create_ptnl_ler_for_per
     (p_validate                     =>  'N'
     ,p_ptnl_ler_for_per_id          =>  l_ptnl_ler_for_per_id          -- out number
     ,p_csd_by_ptnl_ler_for_per_id   =>  to_char(l_ptnl_ler.csd_by_ptnl_ler_for_per_id)   -- in  number    default null
     ,p_lf_evt_ocrd_dt               =>  l_new_ler_lf_evt_ocrd_dt               -- in  out date
     ,p_ptnl_ler_for_per_stat_cd     =>  l_ptnl_ler.ptnl_ler_for_per_stat_cd     -- in  varchar2  default null
     ,p_ptnl_ler_for_per_src_cd      =>  l_ptnl_ler.ptnl_ler_for_per_src_cd      -- in  varchar2  default null
     ,p_mnl_dt                       =>  to_char(l_ptnl_ler.mnl_dt,hr_transaction_ss.g_date_format)                       -- in  date      default null
     ,p_enrt_perd_id                 =>  to_char(l_ptnl_ler.enrt_perd_id)                 -- in  number    default null
     ,p_ler_id                       =>  to_char(l_ptnl_ler.ler_id)                       -- in  number    default null
     ,p_person_id                    =>  to_char(l_person_id)                    -- in  number    default null
     ,p_business_group_id            =>  to_char(l_ptnl_ler.business_group_id)            -- in  number    default null
     ,p_dtctd_dt                     =>  to_char(l_ptnl_ler.dtctd_dt,hr_transaction_ss.g_date_format)                     -- in  date      default null
     ,p_procd_dt                     =>  to_char(l_ptnl_ler.procd_dt,hr_transaction_ss.g_date_format)                     -- in  date      default null
     ,p_unprocd_dt                   =>  to_char(l_ptnl_ler.unprocd_dt,hr_transaction_ss.g_date_format)                   -- in  date      default null
     ,p_voidd_dt                     =>  to_char(l_ptnl_ler.voidd_dt,hr_transaction_ss.g_date_format)                     -- in  date      default null
     ,p_mnlo_dt                      =>  to_char(l_ptnl_ler.mnlo_dt,hr_transaction_ss.g_date_format)                      -- in  date      default null
     ,p_ntfn_dt                      =>  to_char(l_ptnl_ler.ntfn_dt,hr_transaction_ss.g_date_format)                      -- in  date      default null
     ,p_request_id                   =>  to_char(l_ptnl_ler.request_id)                   -- in  number    default null
     ,p_program_application_id       =>  to_char(l_ptnl_ler.program_application_id)       -- in  number    default null
     ,p_program_id                   =>  to_char(l_ptnl_ler.program_id)                   -- in  number    default null
     ,p_program_update_date          =>  to_char(l_ptnl_ler.program_update_date,hr_transaction_ss.g_date_format)          -- in  date      default null
     ,p_object_version_number        =>  l_life_event_ovn                        -- out number
     ,p_effective_date               =>  to_char(l_life_event_eff_date,hr_transaction_ss.g_date_format)                   --in  date
     ,p_item_type                    =>  l_item_type
     ,p_item_key                     =>  l_item_key
     ,p_activity_id                  =>  null
     ,p_flow_mode                    =>  l_flow_mode
     ,p_subflow_mode                 =>  l_subflow_mode
     ,p_life_event_name              =>  l_life_event_name
     ,p_transaction_step_id          =>  l_evt_transaction_step_id
     ,p_error_message                =>  l_error_message
     ,p_hire_dt                      =>  null
     );*/
   end if;
--
   l_transaction_step := to_number(wf_engine.GetItemAttrText
                    (itemtype   => l_item_type,
                     itemkey    => l_item_key,
                     aname      =>'USER_TRANSACTION_STEP'));
   if l_transaction_step is not null then
      ben_process_user_ss_api.get_user_data_from_tt(
           p_transaction_step_id          => l_transaction_step
          ,p_user_name                    => l_user_name
          ,p_user_pswd                    => l_user_pswd
          ,p_pswd_hint                    => l_pswd_hint
          ,p_owner                        => l_owner
          ,p_session_number               => l_session_number
          ,p_start_date                   => l_start_date
          ,p_end_date                     => l_end_date
          ,p_last_logon_date              => l_last_logon_date
          ,p_password_date                => l_password_date
          ,p_password_accesses_left       => l_password_accesses_left
          ,p_password_lifespan_accesses   => l_password_lifespan_accesses
          ,p_password_lifespan_days       => l_password_lifespan_days
          ,p_employee_id                  => l_employee_id
          ,p_email_address                => l_email_address
          ,p_fax                          => l_fax
          ,p_customer_id                  => l_customer_id
          ,p_supplier_id                  => l_supplier_id
          ,p_business_group_id            => l_business_group_id
          ,p_respons_id                   => l_respons_id
          ,p_respons_appl_id              => l_respons_appl_id
          );

      l_user_pswd := wf_engine.GetItemAttrText
                    (itemtype   => l_item_type,
                     itemkey    => l_item_key,
                     aname      =>'USER_ACCOUNT_INFO');

      wf_engine.SetItemAttrText (itemtype => l_item_type,
                           itemkey  => l_item_key,
                           aname    => 'USER_ACCOUNT_INFO',
                           avalue   => null);
      ben_process_user_ss_api.create_user_details(
           p_validate                     => false
          ,p_user_name                    => l_user_name
          ,p_owner                        => l_owner
          ,p_unencrypted_password         => trim(l_user_pswd)
          ,p_session_number               => l_session_number
          ,p_start_date                   => l_start_date
          ,p_end_date                     => l_end_date
          ,p_last_logon_date              => l_last_logon_date
          ,p_description                  => l_pswd_hint
          ,p_password_date                => l_password_date
          ,p_password_accesses_left       => l_password_accesses_left
          ,p_password_lifespan_accesses   => l_password_lifespan_accesses
          ,p_password_lifespan_days       => l_password_lifespan_days
          ,p_employee_id                  => l_person_id
          ,p_email_address                => l_email_address
          ,p_fax                          => l_fax
          ,p_customer_id                  => l_customer_id
          ,p_supplier_id                  => l_supplier_id
          ,p_business_group_id            => l_business_group_id
          ,p_responsibility_id            => l_respons_id
          ,p_respons_application_id       => l_respons_appl_id
          ,p_api_error                    => l_api_error
          ,p_user_id                      => l_user_id
          );

   end if;
   hr_process_person_ss.g_session_id := ICX_SEC.G_SESSION_ID;
   hr_process_person_ss.g_person_id := l_person_id;
   hr_process_person_ss.g_assignment_id := l_assignment_id;
--   hr_utility.set_location('g_person_id =' || hr_process_person_ss.g_person_id, 8888);

--
--
   if l_assign_payroll_warning then
     -- ------------------------------------------------------------+
     -- The assign payroll warning has been set so we must set the
     -- error so we can retrieve the text using fnd_message.get
     -- -------------------------------------------------------------+
     null;
  end if;
--
--
   if p_validate = true then
     rollback to process_basic_details;
  end if;
--
--
EXCEPTION
  when hr_utility.hr_error then
    -- -----------------------------------------------------------------+
    -- An application error has been raised by the API so we must set
    -- the error.
    -- -----------------------------------------------------------------+
        rollback to process_basic_details;
        raise;

END process_api;
--
------------------------------------------------------------------------+
-------------------------Create_Person----------------------------------+
------------------------------------------------------------------------+
procedure create_person
  (p_item_type                     in varchar2
  ,p_item_key                      in varchar2
  ,p_actid                         in number
  ,p_login_person_id               in number
  ,p_process_section_name          in varchar2
  ,p_action_type                   in varchar2
  ,p_validate                      in varchar2 default 'Y'  --boolean default  false
--  ,p_hire_date                     in     date
  ,p_hire_date                     in     varchar2
  ,p_business_group_id             in     number
  ,p_last_name                     in     varchar2
  ,p_sex                           in     varchar2
  ,p_review_page_region_code       in varchar2 default hr_api.g_varchar2
  ,p_person_type_id                in     number   default null
  ,p_per_comments                  in     varchar2 default null
  ,p_date_employee_data_verified   in     date     default null
  ,p_date_of_birth                 in     date     default null
  ,p_email_address                 in     varchar2 default null
  ,p_employee_number               in out nocopy varchar2
  ,p_expense_check_send_to_addres  in     varchar2 default null
  ,p_first_name                    in     varchar2 default null
  ,p_known_as                      in     varchar2 default null
  ,p_marital_status                in     varchar2 default null
  ,p_middle_names                  in     varchar2 default null
  ,p_nationality                   in     varchar2 default null
  ,p_national_identifier           in     varchar2 default null
  ,p_previous_last_name            in     varchar2 default null
  ,p_registered_disabled_flag      in     varchar2 default null
  ,p_title                         in     varchar2 default null
  ,p_vendor_id                     in     number   default null
  ,p_work_telephone                in     varchar2 default null
  ,p_attribute_category            in     varchar2 default null
  ,p_attribute1                    in     varchar2 default null
  ,p_attribute2                    in     varchar2 default null
  ,p_attribute3                    in     varchar2 default null
  ,p_attribute4                    in     varchar2 default null
  ,p_attribute5                    in     varchar2 default null
  ,p_attribute6                    in     varchar2 default null
  ,p_attribute7                    in     varchar2 default null
  ,p_attribute8                    in     varchar2 default null
  ,p_attribute9                    in     varchar2 default null
  ,p_attribute10                   in     varchar2 default null
  ,p_attribute11                   in     varchar2 default null
  ,p_attribute12                   in     varchar2 default null
  ,p_attribute13                   in     varchar2 default null
  ,p_attribute14                   in     varchar2 default null
  ,p_attribute15                   in     varchar2 default null
  ,p_attribute16                   in     varchar2 default null
  ,p_attribute17                   in     varchar2 default null
  ,p_attribute18                   in     varchar2 default null
  ,p_attribute19                   in     varchar2 default null
  ,p_attribute20                   in     varchar2 default null
  ,p_attribute21                   in     varchar2 default null
  ,p_attribute22                   in     varchar2 default null
  ,p_attribute23                   in     varchar2 default null
  ,p_attribute24                   in     varchar2 default null
  ,p_attribute25                   in     varchar2 default null
  ,p_attribute26                   in     varchar2 default null
  ,p_attribute27                   in     varchar2 default null
  ,p_attribute28                   in     varchar2 default null
  ,p_attribute29                   in     varchar2 default null
  ,p_attribute30                   in     varchar2 default null
  ,p_per_information_category      in     varchar2 default null
  ,p_per_information1              in     varchar2 default null
  ,p_per_information2              in     varchar2 default null
  ,p_per_information3              in     varchar2 default null
  ,p_per_information4              in     varchar2 default null
  ,p_per_information5              in     varchar2 default null
  ,p_per_information6              in     varchar2 default null
  ,p_per_information7              in     varchar2 default null
  ,p_per_information8              in     varchar2 default null
  ,p_per_information9              in     varchar2 default null
  ,p_per_information10             in     varchar2 default null
  ,p_per_information11             in     varchar2 default null
  ,p_per_information12             in     varchar2 default null
  ,p_per_information13             in     varchar2 default null
  ,p_per_information14             in     varchar2 default null
  ,p_per_information15             in     varchar2 default null
  ,p_per_information16             in     varchar2 default null
  ,p_per_information17             in     varchar2 default null
  ,p_per_information18             in     varchar2 default null
  ,p_per_information19             in     varchar2 default null
  ,p_per_information20             in     varchar2 default null
  ,p_per_information21             in     varchar2 default null
  ,p_per_information22             in     varchar2 default null
  ,p_per_information23             in     varchar2 default null
  ,p_per_information24             in     varchar2 default null
  ,p_per_information25             in     varchar2 default null
  ,p_per_information26             in     varchar2 default null
  ,p_per_information27             in     varchar2 default null
  ,p_per_information28             in     varchar2 default null
  ,p_per_information29             in     varchar2 default null
  ,p_per_information30             in     varchar2 default null
  ,p_date_of_death                 in     date     default null
  ,p_background_check_status       in     varchar2 default null
  ,p_background_date_check         in     date     default null
  ,p_blood_type                    in     varchar2 default null
  ,p_correspondence_language       in     varchar2 default null
  ,p_fast_path_employee            in     varchar2 default null
  ,p_fte_capacity                  in     number   default null
  ,p_honors                        in     varchar2 default null
  ,p_internal_location             in     varchar2 default null
  ,p_last_medical_test_by          in     varchar2 default null
  ,p_last_medical_test_date        in     date     default null
  ,p_mailstop                      in     varchar2 default null
  ,p_office_number                 in     varchar2 default null
  ,p_on_military_service           in     varchar2 default null
  ,p_pre_name_adjunct              in     varchar2 default null
  ,p_projected_start_date          in     date     default null
  ,p_resume_exists                 in     varchar2 default null
  ,p_resume_last_updated           in     date     default null
  ,p_second_passport_exists        in     varchar2 default null
  ,p_student_status                in     varchar2 default null
  ,p_work_schedule                 in     varchar2 default null
  ,p_suffix                        in     varchar2 default null
  ,p_benefit_group_id              in     number   default null
  ,p_receipt_of_death_cert_date    in     date     default null
  ,p_coord_ben_med_pln_no          in     varchar2 default null
  ,p_coord_ben_no_cvg_flag         in     varchar2 default 'N'
  ,p_uses_tobacco_flag             in     varchar2 default null
  ,p_dpdnt_adoption_date           in     date     default null
  ,p_dpdnt_vlntry_svce_flag        in     varchar2 default 'N'
  ,p_original_date_of_hire         in     date     default null
  ,p_adjusted_svc_date             in     date     default null
  ,p_town_of_birth                in      varchar2 default null
  ,p_region_of_birth              in      varchar2 default null
  ,p_country_of_birth             in      varchar2 default null
  ,p_global_person_id             in      varchar2 default null
  ,p_effective_date               in      date default sysdate
  ,p_attribute_update_mode        in      varchar2 default null
  ,p_object_version_number        in      number default null
  ,p_applicant_number             in      varchar2 default null
  ,p_comments                     in      varchar2 default null
  ,p_rehire_authorizor            in      varchar2 default null
  ,p_rehire_recommendation        in      varchar2 default null
  ,p_hold_applicant_date_until    in      date     default null
  ,p_rehire_reason                in      varchar2 default null
  ,p_flow_name                    in      varchar2 default null
  ,p_person_id                        out nocopy number
  ,p_assignment_id                    out nocopy number
  ,p_per_object_version_number        out nocopy number
  ,p_asg_object_version_number        out nocopy number
  ,p_per_effective_start_date         out nocopy date
  ,p_per_effective_end_date           out nocopy date
  ,p_full_name                        out nocopy varchar2
  ,p_per_comment_id                   out nocopy number
  ,p_assignment_sequence              out nocopy number
  ,p_assignment_number                out nocopy varchar2
  ,p_name_combination_warning         out nocopy varchar2    ---boolean
  ,p_assign_payroll_warning           out nocopy varchar2    ---boolean
  ,p_orig_hire_warning                out nocopy varchar2    ---boolean
  ,p_return_status                    out nocopy varchar2    -- Bug 2149113
  ) IS

  CURSOR  get_wf_actid (c_activity_name  in varchar2) IS
  SELECT  distinct wfias.activity_id
  FROM    wf_item_activity_statuses_v  wfias
  WHERE   wfias.item_type = p_item_type
  and     wfias.item_key  = p_item_key
  and     wfias.activity_name = c_activity_name;

------+
  l_transaction_id             number default null;
  l_transaction_step_id        number default null;
  l_trans_obj_vers_num         number default null;
  l_count                      integer default 0;
  l_transaction_table hr_transaction_ss.transaction_table;
  l_review_item_name  varchar2(50);
  --
  l_full_name_duplicate_flag      varchar2(1) default null;
  l_result                  varchar2(50);
  l_per_ovn                           number default null;
  l_employee_number                   number default null;
  l_asg_ovn                           number default null;
  l_full_name                     per_all_people_f.full_name%type default null;
  l_person_id                    number;
  l_assignment_id                number;
  l_per_effective_start_date    date;
  l_asg_effective_end_date      date;
  l_asg_effective_start_date    date;
  l_per_effective_end_date      date;
  l_hire_date                   date;
  l_per_comment_id                number;
  l_assignment_sequence           number;
  l_assignment_number             varchar2(50);
  l_name_combination_warning      boolean;
  l_assign_payroll_warning        boolean;
  l_orig_hire_warning             boolean;
  l_parent_id         number;
  l_dummy_num  number;
  l_dummy_date date;
  l_dummy_char varchar2(1000);
  l_dummy_bool boolean;
  l_validate boolean;
  l_vendor_id                     number default null;
  l_benefit_group_id              number default null;
  l_fte_capacity                  number default null;
  l_person_type_id                number default null;
  -- start cobra codes
  l_assignment_extra_info_id      number;
  l_aei_object_version_number     number;
  prflvalue                          varchar2(2000) default null;
--
Begin

    SAVEPOINT create_cobra_person;
    --Bug 2149113
    fnd_msg_pub.initialize;
    p_return_status := 'Y';
    --End
    --

   if p_validate = 'N' OR p_validate is null
   then
      l_validate := false;
   else
      l_validate := true;
   end if;
---------+
-- Java caller will set p_vendor_id, p_benefit_group_id and p_fte_capacity to
-- hr_api.g_number value.  We need to set these back to null before saving to
-- transaction table.

   if p_vendor_id = 0
   then
      l_vendor_id := null;
   else
      l_vendor_id := p_vendor_id;
   end if;
--
   if p_benefit_group_id = 0
   then
      l_benefit_group_id := null;
   else
      l_benefit_group_id := p_benefit_group_id;
   end if;
--
   if p_fte_capacity = 0
   then
      l_fte_capacity := null;
   else
      l_fte_capacity := p_fte_capacity;
   end if;
 --
   if p_person_type_id = 0
   then
      l_person_type_id := null;
   else
      l_person_type_id := p_person_type_id;
   end if;

 -- start cobra codes
 if p_flow_name = 'Cobra' then
   if (to_date(p_hire_date,hr_transaction_ss.g_date_format) > p_effective_date) then
       l_hire_date := p_effective_date;
   else
       l_hire_date := to_date(p_hire_date,hr_transaction_ss.g_date_format);
   end if;
   hr_contact_api.create_person
        (p_validate                      => false  --in     boolean  default false
        ,p_start_date                    => l_hire_date
        ,p_business_group_id             => p_business_group_id
        ,p_last_name                     => p_last_name
        ,p_sex                           => p_sex
        ,p_person_type_id                => null
        ,p_comments                      => p_per_comments
        ,p_date_employee_data_verified   => p_date_employee_data_verified
        ,p_date_of_birth                 => p_date_of_birth
        ,p_email_address                 => p_email_address
        ,p_expense_check_send_to_addres  => p_expense_check_send_to_addres
        ,p_first_name                    => p_first_name
        ,p_known_as                      => p_known_as
        ,p_marital_status                => p_marital_status
        ,p_middle_names                  => p_middle_names
        ,p_nationality                   => p_nationality
        ,p_national_identifier           => p_national_identifier
        ,p_previous_last_name            => p_previous_last_name
        ,p_registered_disabled_flag      => p_registered_disabled_flag
        ,p_title                         => p_title
        ,p_vendor_id                     => l_vendor_id
        ,p_work_telephone                => p_work_telephone
        ,p_attribute_category            => p_attribute_category
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
        ,p_per_information_category      => p_per_information_category
        ,p_per_information1              => p_per_information1
        ,p_per_information2              => p_per_information2
        ,p_per_information3              => p_per_information3
        ,p_per_information4              => p_per_information4
        ,p_per_information5              => p_per_information5
        ,p_per_information6              => p_per_information6
        ,p_per_information7              => p_per_information7
        ,p_per_information8              => p_per_information8
        ,p_per_information9              => p_per_information9
        ,p_per_information10             => p_per_information10
        ,p_per_information11             => p_per_information11
        ,p_per_information12             => p_per_information12
        ,p_per_information13             => p_per_information13
        ,p_per_information14             => p_per_information14
        ,p_per_information15             => p_per_information15
        ,p_per_information16             => p_per_information16
        ,p_per_information17             => p_per_information17
        ,p_per_information18             => p_per_information18
        ,p_per_information19             => p_per_information19
        ,p_per_information20             => p_per_information20
        ,p_per_information21             => p_per_information21
        ,p_per_information22             => p_per_information22
        ,p_per_information23             => p_per_information23
        ,p_per_information24             => p_per_information24
        ,p_per_information25             => p_per_information25
        ,p_per_information26             => p_per_information26
        ,p_per_information27             => p_per_information27
        ,p_per_information28             => p_per_information28
        ,p_per_information29             => p_per_information29
        ,p_per_information30             => p_per_information30
        ,p_correspondence_language       => p_correspondence_language
        ,p_honors                        => p_honors
        ,p_pre_name_adjunct              => p_pre_name_adjunct
        ,p_suffix                        => p_suffix
        ,p_town_of_birth                 => p_town_of_birth
        ,p_region_of_birth               => p_region_of_birth
        ,p_country_of_birth              => p_country_of_birth
        ,p_global_person_id              => p_global_person_id
        ,p_person_id                     => l_person_id  --   out number
        ,p_object_version_number         => l_per_ovn ---   out nocopy number
        ,p_effective_start_date          => l_per_effective_start_date   --   out date
        ,p_effective_end_date            => l_per_effective_end_date    --   out date
        ,p_full_name                     => l_full_name   ---   out nocopy varchar2
        ,p_comment_id                    => l_per_comment_id     ---   out nocopy number
        ,p_name_combination_warning      => l_name_combination_warning   --   out boolean
        ,p_orig_hire_warning             => l_orig_hire_warning  --  out boolean
   );
  --
    hr_utility.set_location('Leaving  ben_process_cobra_person_ss.create_personnnnnnnnnn ' || l_person_id, 2006);
    prflvalue := fnd_profile.value('BEN_USER_TO_ORG_LINK');
    ben_assignment_api.create_ben_asg
        (p_validate                      => l_validate  --in     boolean  default false
         ,p_event_mode                   => false
         ,p_effective_date               => l_hire_date
        -- ,p_effective_date               => trunc(sysdate)
         ,p_person_id                    => l_person_id
         ,p_organization_id              => nvl(prflvalue,p_business_group_id) --new profile??
         ,p_assignment_status_type_id    => 1
         ,p_assignment_id                => l_assignment_id  --   out number
         ,p_object_version_number        => l_asg_ovn ---   out nocopy number
         ,p_effective_start_date         => l_asg_effective_start_date   --   out date
         ,p_effective_end_date           => l_asg_effective_end_date    --   out date
         ,p_assignment_extra_info_id     => l_assignment_extra_info_id
         ,p_aei_object_version_number    => l_aei_object_version_number
         );

  end if;

  rollback to create_cobra_person;
  --
  -- First, check if transaction id exists or not
  --
  l_transaction_id := hr_transaction_ss.get_transaction_id
                     (p_item_type   => p_item_type
                     ,p_item_key    => p_item_key);
  --
  if l_transaction_id is null then
     -- Start a Transaction
        hr_transaction_ss.start_transaction
           (itemtype   => p_item_type
           ,itemkey    => p_item_key
           ,actid      => p_actid
           ,funmode    => 'RUN'
           ,p_login_person_id => p_login_person_id  --nvl(p_login_person_id, p_parent_id)
           ,result     => l_result);

        l_transaction_id := hr_transaction_ss.get_transaction_id
                        (p_item_type   => p_item_type
                        ,p_item_key    => p_item_key);
  end if;
------------------+
  --
  -- First check step id already exists, which happens when user navigates
  -- back from review or page after this page.
  --
  hr_transaction_api.get_transaction_step_info
                (p_item_type             => p_item_type
                ,p_item_key              => p_item_key
                ,p_activity_id           => p_actid
                ,p_transaction_step_id   => l_transaction_step_id
                ,p_object_version_number => l_trans_obj_vers_num);
  --
  if l_transaction_step_id is null then
     --
     -- Create a transaction step
     --
     hr_transaction_api.create_transaction_step
     (p_validate              => false
     ,p_creator_person_id     => p_login_person_id  --nvl(p_login_person_id, p_parent_id)
     ,p_transaction_id        => l_transaction_id
     ,p_api_name              => g_package || 'PROCESS_API'
     ,p_item_type             => p_item_type
     ,p_item_key              => p_item_key
     ,p_activity_id           => p_actid
     ,p_transaction_step_id   => l_transaction_step_id
     ,p_object_version_number => l_trans_obj_vers_num);
     --
  end if;
  --

  --
  -- Create a transaction step
  --
  --
  l_count := 1;
  l_transaction_table(l_count).param_name := 'P_ITEM_TYPE';
  l_transaction_table(l_count).param_value := p_item_type;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ITEM_KEY';
  l_transaction_table(l_count).param_value := p_item_key;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
  --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ACTIVITY_ID';
  l_transaction_table(l_count).param_value := p_actid;
  l_transaction_table(l_count).param_data_type := 'NUMBER';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_PROCESS_SECTION_NAME';
  l_transaction_table(l_count).param_value := p_process_section_name;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ACTION_TYPE';
  l_transaction_table(l_count).param_value := p_action_type;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_DATE_START';
  l_transaction_table(l_count).param_value := to_char(l_hire_date,hr_transaction_ss.g_date_format);
  l_transaction_table(l_count).param_data_type := 'DATE';
--
-- We don't want to derive the business_group_id because we want to save a
-- db sql statement call to improve the performance.
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_BUSINESS_GROUP_ID';
  l_transaction_table(l_count).param_value := p_business_group_id;
  l_transaction_table(l_count).param_data_type := 'NUMBER';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_LAST_NAME';
  l_transaction_table(l_count).param_value := p_last_name;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_SEX';
  l_transaction_table(l_count).param_value := p_sex;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_PERSON_TYPE_ID';
  l_transaction_table(l_count).param_value := l_person_type_id;
  l_transaction_table(l_count).param_data_type := 'NUMBER';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_PER_COMMENTS';
  l_transaction_table(l_count).param_value := p_per_comments;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_DATE_EMPLOYEE_DATA_VERIFIED';
  l_transaction_table(l_count).param_value := to_char(p_date_employee_data_verified,
                                              hr_transaction_ss.g_date_format);
  l_transaction_table(l_count).param_data_type := 'DATE';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_DATE_OF_BIRTH';
  l_transaction_table(l_count).param_value := to_char(p_date_of_birth,
                                              hr_transaction_ss.g_date_format);
  l_transaction_table(l_count).param_data_type := 'DATE';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_EMAIL_ADDRESS';
  l_transaction_table(l_count).param_value := p_email_address;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_EXPENSE_CHECK_SEND_TO_ADDRES';
  l_transaction_table(l_count).param_value := p_expense_check_send_to_addres;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_FIRST_NAME';
  l_transaction_table(l_count).param_value := p_first_name;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_KNOWN_AS';
  l_transaction_table(l_count).param_value := p_known_as;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_MARITAL_STATUS';
  l_transaction_table(l_count).param_value := p_marital_status;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_MIDDLE_NAMES';
  l_transaction_table(l_count).param_value := p_middle_names;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_NATIONALITY';
  l_transaction_table(l_count).param_value := p_nationality;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_NATIONAL_IDENTIFIER';
  l_transaction_table(l_count).param_value := p_national_identifier;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_PREVIOUS_LAST_NAME';
  l_transaction_table(l_count).param_value := p_previous_last_name;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_REGISTERED_DISABLED_FLAG';
  l_transaction_table(l_count).param_value := p_registered_disabled_flag;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_TITLE';
  l_transaction_table(l_count).param_value := p_title;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_VENDOR_ID';
  l_transaction_table(l_count).param_value := to_char(l_vendor_id);
  l_transaction_table(l_count).param_data_type := 'NUMBER';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_WORK_TELEPHONE';
  l_transaction_table(l_count).param_value := p_work_telephone;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE_CATEGORY';
  l_transaction_table(l_count).param_value := p_attribute_category;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE1';
  l_transaction_table(l_count).param_value := p_attribute1;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE2';
  l_transaction_table(l_count).param_value := p_attribute2;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE3';
  l_transaction_table(l_count).param_value := p_attribute3;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE4';
  l_transaction_table(l_count).param_value := p_attribute4;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE5';
  l_transaction_table(l_count).param_value := p_attribute5;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE6';
  l_transaction_table(l_count).param_value := p_attribute6;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE7';
  l_transaction_table(l_count).param_value := p_attribute7;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE8';
  l_transaction_table(l_count).param_value := p_attribute8;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE9';
  l_transaction_table(l_count).param_value := p_attribute9;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE10';
  l_transaction_table(l_count).param_value := p_attribute10;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE11';
  l_transaction_table(l_count).param_value := p_attribute11;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE12';
  l_transaction_table(l_count).param_value := p_attribute12;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE13';
  l_transaction_table(l_count).param_value := p_attribute13;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE14';
  l_transaction_table(l_count).param_value := p_attribute14;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE15';
  l_transaction_table(l_count).param_value := p_attribute15;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE16';
  l_transaction_table(l_count).param_value := p_attribute16;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE17';
  l_transaction_table(l_count).param_value := p_attribute17;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE18';
  l_transaction_table(l_count).param_value := p_attribute18;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE19';
  l_transaction_table(l_count).param_value := p_attribute19;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE20';
  l_transaction_table(l_count).param_value := p_attribute20;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE21';
  l_transaction_table(l_count).param_value := p_attribute21;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE22';
  l_transaction_table(l_count).param_value := p_attribute22;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE23';
  l_transaction_table(l_count).param_value := p_attribute23;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE24';
  l_transaction_table(l_count).param_value := p_attribute24;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE25';
  l_transaction_table(l_count).param_value := p_attribute25;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE26';
  l_transaction_table(l_count).param_value := p_attribute26;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE27';
  l_transaction_table(l_count).param_value := p_attribute27;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE28';
  l_transaction_table(l_count).param_value := p_attribute28;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE29';
  l_transaction_table(l_count).param_value := p_attribute29;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE30';
  l_transaction_table(l_count).param_value := p_attribute30;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_PER_INFORMATION_CATEGORY';
  l_transaction_table(l_count).param_value := p_per_information_category;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_PER_INFORMATION1';
  l_transaction_table(l_count).param_value := p_per_information1;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_PER_INFORMATION2';
  l_transaction_table(l_count).param_value := p_per_information2;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_PER_INFORMATION3';
  l_transaction_table(l_count).param_value := p_per_information3;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_PER_INFORMATION4';
  l_transaction_table(l_count).param_value := p_per_information4;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_PER_INFORMATION5';
  l_transaction_table(l_count).param_value := p_per_information5;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_PER_INFORMATION6';
  l_transaction_table(l_count).param_value := p_per_information6;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_PER_INFORMATION7';
  l_transaction_table(l_count).param_value := p_per_information7;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_PER_INFORMATION8';
  l_transaction_table(l_count).param_value := p_per_information8;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_PER_INFORMATION9';
  l_transaction_table(l_count).param_value := p_per_information9;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_PER_INFORMATION10';
  l_transaction_table(l_count).param_value := p_per_information10;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_PER_INFORMATION11';
  l_transaction_table(l_count).param_value := p_per_information11;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_PER_INFORMATION12';
  l_transaction_table(l_count).param_value := p_per_information12;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_PER_INFORMATION13';
  l_transaction_table(l_count).param_value := p_per_information13;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_PER_INFORMATION14';
  l_transaction_table(l_count).param_value := p_per_information14;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_PER_INFORMATION15';
  l_transaction_table(l_count).param_value := p_per_information15;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_PER_INFORMATION16';
  l_transaction_table(l_count).param_value := p_per_information16;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_PER_INFORMATION17';
  l_transaction_table(l_count).param_value := p_per_information17;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_PER_INFORMATION18';
  l_transaction_table(l_count).param_value := p_per_information18;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_PER_INFORMATION19';
  l_transaction_table(l_count).param_value := p_per_information19;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_PER_INFORMATION20';
  l_transaction_table(l_count).param_value := p_per_information20;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_PER_INFORMATION21';
  l_transaction_table(l_count).param_value := p_per_information21;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_PER_INFORMATION22';
  l_transaction_table(l_count).param_value := p_per_information22;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_PER_INFORMATION23';
  l_transaction_table(l_count).param_value := p_per_information23;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_PER_INFORMATION24';
  l_transaction_table(l_count).param_value := p_per_information24;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_PER_INFORMATION25';
  l_transaction_table(l_count).param_value := p_per_information25;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_PER_INFORMATION26';
  l_transaction_table(l_count).param_value := p_per_information26;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_PER_INFORMATION27';
  l_transaction_table(l_count).param_value := p_per_information27;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_PER_INFORMATION28';
  l_transaction_table(l_count).param_value := p_per_information28;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_PER_INFORMATION29';
  l_transaction_table(l_count).param_value := p_per_information29;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_PER_INFORMATION30';
  l_transaction_table(l_count).param_value := p_per_information30;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_DATE_OF_DEATH';
  l_transaction_table(l_count).param_value := to_char
                                              (p_date_of_death
                                              ,hr_transaction_ss.g_date_format);
  l_transaction_table(l_count).param_data_type := 'DATE';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_BACKGROUND_CHECK_STATUS';
  l_transaction_table(l_count).param_value := p_background_check_status;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_BACKGROUND_DATE_CHECK';
  l_transaction_table(l_count).param_value := to_char
                                              (p_background_date_check
                                              ,hr_transaction_ss.g_date_format);
  l_transaction_table(l_count).param_data_type := 'DATE';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_BLOOD_TYPE';
  l_transaction_table(l_count).param_value := p_blood_type;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_CORRESPONDENCE_LANGUAGE';
  l_transaction_table(l_count).param_value := p_correspondence_language;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_FAST_PATH_EMPLOYEE';
  l_transaction_table(l_count).param_value := p_fast_path_employee;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_FTE_CAPACITY';
  l_transaction_table(l_count).param_value := to_char(l_fte_capacity);
  l_transaction_table(l_count).param_data_type := 'NUMBER';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_HONORS';
  l_transaction_table(l_count).param_value := p_honors;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_INTERNAL_LOCATION';
  l_transaction_table(l_count).param_value := p_internal_location;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_LAST_MEDICAL_TEST_BY';
  l_transaction_table(l_count).param_value := p_last_medical_test_by;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_LAST_MEDICAL_TEST_DATE';
  l_transaction_table(l_count).param_value := to_char
                                              (p_last_medical_test_date
                                              ,hr_transaction_ss.g_date_format);
  l_transaction_table(l_count).param_data_type := 'DATE';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_MAILSTOP';
  l_transaction_table(l_count).param_value := p_mailstop;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_OFFICE_NUMBER';
  l_transaction_table(l_count).param_value := p_office_number;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ON_MILITARY_SERVICE';
  l_transaction_table(l_count).param_value := p_on_military_service;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_PRE_NAME_ADJUNCT';
  l_transaction_table(l_count).param_value := p_pre_name_adjunct;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_PROJECTED_START_DATE';
  l_transaction_table(l_count).param_value := to_char
                                              (p_projected_start_date
                                              ,hr_transaction_ss.g_date_format);
  l_transaction_table(l_count).param_data_type := 'DATE';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_RESUME_EXISTS';
  l_transaction_table(l_count).param_value := p_resume_exists;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_RESUME_LAST_UPDATED';
  l_transaction_table(l_count).param_value := to_char
                                              (p_resume_last_updated
                                              ,hr_transaction_ss.g_date_format);
  l_transaction_table(l_count).param_data_type := 'DATE';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_SECOND_PASSPORT_EXISTS';
  l_transaction_table(l_count).param_value := p_second_passport_exists;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_STUDENT_STATUS';
  l_transaction_table(l_count).param_value := p_student_status;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_WORK_SCHEDULE';
  l_transaction_table(l_count).param_value := p_work_schedule;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_SUFFIX';
  l_transaction_table(l_count).param_value := p_suffix;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_BENEFIT_GROUP_ID';
  l_transaction_table(l_count).param_value := to_char(l_benefit_group_id);
  l_transaction_table(l_count).param_data_type := 'NUMBER';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_RECEIPT_OF_DEATH_CERT_DATE';
  l_transaction_table(l_count).param_value := to_char
                                              (p_receipt_of_death_cert_date
                                              ,hr_transaction_ss.g_date_format);
  l_transaction_table(l_count).param_data_type := 'DATE';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_COORD_BEN_MED_PLN_NO';
  l_transaction_table(l_count).param_value := p_coord_ben_med_pln_no;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_COORD_BEN_NO_CVG_FLAG';
  l_transaction_table(l_count).param_value := p_coord_ben_no_cvg_flag;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_USES_TOBACCO_FLAG';
  l_transaction_table(l_count).param_value := p_uses_tobacco_flag;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_DPDNT_ADOPTION_DATE';
  l_transaction_table(l_count).param_value := to_char
                                              (p_dpdnt_adoption_date
                                              ,hr_transaction_ss.g_date_format);
  l_transaction_table(l_count).param_data_type := 'DATE';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_DPDNT_VLNTRY_SVCE_FLAG';
  l_transaction_table(l_count).param_value := p_dpdnt_vlntry_svce_flag;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ORIGINAL_DATE_OF_HIRE';
  l_transaction_table(l_count).param_value := to_char
                                             (p_original_date_of_hire
                                             ,hr_transaction_ss.g_date_format);
  l_transaction_table(l_count).param_data_type := 'DATE';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ADJUSTED_SVC_DATE';
  l_transaction_table(l_count).param_value := to_char
                                              (p_adjusted_svc_date
                                              ,hr_transaction_ss.g_date_format);
  l_transaction_table(l_count).param_data_type := 'DATE';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_TOWN_OF_BIRTH';
  l_transaction_table(l_count).param_value := p_town_of_birth;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_REGION_OF_BIRTH';
  l_transaction_table(l_count).param_value := p_region_of_birth;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_COUNTRY_OF_BIRTH';
  l_transaction_table(l_count).param_value := p_country_of_birth;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_GLOBAL_PERSON_ID';
  l_transaction_table(l_count).param_value := p_global_person_id;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_PERSON_ID';
  l_transaction_table(l_count).param_value := p_person_id;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ASSIGNMENT_ID';
  l_transaction_table(l_count).param_value := p_assignment_id;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_PER_OBJECT_VERSION_NUMBER';
  l_transaction_table(l_count).param_value := p_per_object_version_number;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ASG_OBJECT_VERSION_NUMBER';
  l_transaction_table(l_count).param_value := p_asg_object_version_number;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_PER_EFFECTIVE_START_DATE';
  l_transaction_table(l_count).param_value := to_char
                                              (p_per_effective_start_date
                                              ,hr_transaction_ss.g_date_format);
  l_transaction_table(l_count).param_data_type := 'DATE';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_PER_EFFECTIVE_END_DATE';
  l_transaction_table(l_count).param_value := to_char
                                              (p_per_effective_end_date
                                              ,hr_transaction_ss.g_date_format);
  l_transaction_table(l_count).param_data_type := 'DATE';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_REVIEW_PROC_CALL';
  l_transaction_table(l_count).param_value := p_review_page_region_code;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_REVIEW_ACTID';
  l_transaction_table(l_count).param_value := p_actid;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_EFFECTIVE_DATE';
  l_transaction_table(l_count).param_value := to_char(p_effective_date,
                                              hr_transaction_ss.g_date_format);
  l_transaction_table(l_count).param_data_type := 'DATE';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ATTRIBUTE_UPDATE_MODE';
  l_transaction_table(l_count).param_value := p_attribute_update_mode;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_OBJECT_VERSION_NUMBER';
  l_transaction_table(l_count).param_value := p_object_version_number;
  l_transaction_table(l_count).param_data_type := 'NUMBER';
--
 l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_APPLICANT_NUMBER';
  l_transaction_table(l_count).param_value := p_applicant_number;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_COMMENTS';
  l_transaction_table(l_count).param_value := p_comments;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_EMPLOYEE_NUMBER';
  l_transaction_table(l_count).param_value := p_employee_number;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_HOLD_APPLICANT_DATE_UNTIL';
  l_transaction_table(l_count).param_value := to_char
                                              (p_hold_applicant_date_until
                                              ,hr_transaction_ss.g_date_format);
  l_transaction_table(l_count).param_data_type := 'DATE';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_REHIRE_AUTHORIZOR';
  l_transaction_table(l_count).param_value := p_rehire_authorizor;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_REHIRE_RECOMMENDATION';
  l_transaction_table(l_count).param_value := p_rehire_recommendation;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_REHIRE_REASON';
  l_transaction_table(l_count).param_value := p_rehire_reason;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_FULL_NAME';
  l_transaction_table(l_count).param_value := l_full_name;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
 --
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_FLOW_NAME';
  l_transaction_table(l_count).param_value := p_flow_name;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
 --

 hr_transaction_ss.save_transaction_step
                (p_item_type => p_item_type
                ,p_item_key => p_item_key
                ,p_actid => p_actid
                ,p_login_person_id     => p_login_person_id
                ,p_transaction_step_id => l_transaction_step_id
                ,p_api_name => g_package || 'PROCESS_API'
                ,p_transaction_data => l_transaction_table);
--

  p_person_id := l_person_id;
  p_assignment_id := l_assignment_id;
  p_per_object_version_number := l_per_ovn;
  p_asg_object_version_number := l_asg_ovn;
  p_per_effective_start_date := l_per_effective_start_date;
  p_per_effective_end_date := l_per_effective_end_date;
  p_full_name := l_full_name;
  p_per_comment_id := l_per_comment_id;
  p_assignment_sequence := l_assignment_sequence;
  p_assignment_number := l_assignment_number;
--
-- Need to convert the boolean true/false value to varchar2 value because on
-- return back to Java program which won't recognize the value.
  if l_name_combination_warning
  then
     p_name_combination_warning := 'Y';
  else
     p_name_combination_warning := 'N';
  end if;
--
  if l_assign_payroll_warning
  then
     p_assign_payroll_warning := 'Y';
  else
     p_assign_payroll_warning := 'N';
  end if;
--
  if l_orig_hire_warning
  then
     p_orig_hire_warning := 'Y';
  else
     p_orig_hire_warning := 'N';
  end if;
--
  p_employee_number := l_employee_number;

  hr_utility.set_location('Leaving  ben_process_cobra_person_ss.create_person ' || hr_process_person_ss.g_person_id, 200);

EXCEPTION
  when g_data_error then
    hr_utility.raise_error;

  when others then
  -- NOCOPY Changes
	  p_person_id                         := null;
	  p_assignment_id                     := null;
	  p_per_object_version_number         := null;
	  p_asg_object_version_number         := null;
	  p_per_effective_start_date          := null;
	  p_per_effective_end_date            := null;
	  p_full_name                         := null;
	  p_per_comment_id                    := null;
	  p_assignment_sequence               := null;
	  p_assignment_number                 := null;
	  p_name_combination_warning          := null;
	  p_assign_payroll_warning            := null;
	  p_orig_hire_warning                 := null;
	-- NOCOPY Changes
        -- Bug 2149113
          fnd_msg_pub.add;  --hr_utility.raise_error;
          p_return_status := 'N';
	--End 2149113
END create_person;
--
--   End Registration
--
END ben_process_cobra_person_ss;
--
--

/

--------------------------------------------------------
--  DDL for Package Body PQP_RIW_COURSE_WRAPPER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_RIW_COURSE_WRAPPER" as
/* $Header: pqpriwcowr.pkb 120.0.12010000.5 2009/04/24 08:38:00 psengupt noship $ */

-- =============================================================================
-- ~ Package Body Global variables:
-- =============================================================================
g_package  varchar2(33) := 'pqp_riw_course_wrapper.';
g_course_rec                     OTA_ACTIVITY_VERSIONS_VL%rowtype;
g_interface_code              varchar2(150);
--

-- =============================================================================
-- Default_Record_Values:
-- =============================================================================
function Default_Course_Rec
         return OTA_ACTIVITY_VERSIONS_VL%rowtype is
  l_proc_name    constant varchar2(150) := g_package||'Default_Course_Rec';
  l_course_rec     OTA_ACTIVITY_VERSIONS_VL%rowtype;
begin

  Hr_Utility.set_location(' Entering: '||l_proc_name, 5);
  /*
   ==========================================================================
   g_varchar2  constant varchar2(9) := '$Sys_Def$';
   g_number  constant number        := -987123654;
   g_date  constant date            := to_date('01-01-4712', 'DD-MM-SYYYY');
   ==========================================================================
  */
  Hr_Utility.set_location(' Before : ', 5);
  l_course_rec.activity_id                   :=  hr_api.g_number;
  l_course_rec.superseded_by_act_version_id  :=  hr_api.g_number;
  l_course_rec.developer_organization_id     :=  hr_api.g_number;
  l_course_rec.controlling_person_id         :=  hr_api.g_number;

  l_course_rec.version_name                  :=  hr_api.g_varchar2;
  Hr_Utility.set_location(' l_course_rec.version_name: '||l_course_rec.version_name, 5);
  l_course_rec.comments                      :=  hr_api.g_varchar2;
  Hr_Utility.set_location(' l_course_rec.comments: '||l_course_rec.comments, 5);
  l_course_rec.description                   :=  hr_api.g_varchar2;
  Hr_Utility.set_location(' l_course_rec.description: '||l_course_rec.description, 5);
  l_course_rec.duration_units                :=  hr_api.g_varchar2;
  Hr_Utility.set_location(' l_course_rec.duration_units: '||l_course_rec.expenses_allowed, 5);
--  l_course_rec.duration                      :=  hr_api.g_number;
  Hr_Utility.set_location(' l_course_rec.duration: '||l_course_rec.duration, 5);
  l_course_rec.end_date                      :=  hr_api.g_date;
  l_course_rec.intended_audience             :=  hr_api.g_varchar2;
  l_course_rec.language_id                   :=  hr_api.g_number;
  l_course_rec.maximum_attendees             :=  hr_api.g_number;
  l_course_rec.minimum_attendees             :=  hr_api.g_number;
  l_course_rec.objectives                    :=  hr_api.g_varchar2;
  Hr_Utility.set_location(' l_course_rec.objectives: '||l_course_rec.expenses_allowed, 5);
  l_course_rec.start_date                    :=  hr_api.g_date;
  l_course_rec.success_criteria              :=  hr_api.g_varchar2;
  l_course_rec.user_status                   :=  hr_api.g_varchar2;
  l_course_rec.vendor_id                     :=  hr_api.g_number;
  l_course_rec.actual_cost                   :=  hr_api.g_number;
  l_course_rec.budget_cost                   :=  hr_api.g_number;
  l_course_rec.budget_currency_code          :=  hr_api.g_varchar2;
  l_course_rec.expenses_allowed              :=  hr_api.g_varchar2;

  l_course_rec.professional_credit_type      :=  hr_api.g_varchar2;
  l_course_rec.professional_credits          :=  hr_api.g_number;
  l_course_rec.maximum_internal_attendees    :=  hr_api.g_number;
  l_course_rec.tav_information_category      :=  hr_api.g_varchar2;
  l_course_rec.tav_information1              :=  hr_api.g_varchar2;
  l_course_rec.tav_information2              :=  hr_api.g_varchar2;
  l_course_rec.tav_information3              :=  hr_api.g_varchar2;
  l_course_rec.tav_information4              :=  hr_api.g_varchar2;
  l_course_rec.tav_information5              :=  hr_api.g_varchar2;
  l_course_rec.tav_information6              :=  hr_api.g_varchar2;
  l_course_rec.tav_information7              :=  hr_api.g_varchar2;
  l_course_rec.tav_information8              :=  hr_api.g_varchar2;
  l_course_rec.tav_information9              :=  hr_api.g_varchar2;
  l_course_rec.tav_information10             :=  hr_api.g_varchar2;
  l_course_rec.tav_information11             :=  hr_api.g_varchar2;
  l_course_rec.tav_information12             :=  hr_api.g_varchar2;
  l_course_rec.tav_information13             :=  hr_api.g_varchar2;
  l_course_rec.tav_information14             :=  hr_api.g_varchar2;
  l_course_rec.tav_information15             :=  hr_api.g_varchar2;
  l_course_rec.tav_information16             :=  hr_api.g_varchar2;
  l_course_rec.tav_information17             :=  hr_api.g_varchar2;
  l_course_rec.tav_information18             :=  hr_api.g_varchar2;
  l_course_rec.tav_information19             :=  hr_api.g_varchar2;
  l_course_rec.tav_information20             :=  hr_api.g_varchar2;
  l_course_rec.inventory_item_id 	       :=  hr_api.g_number;
  l_course_rec.organization_id	       :=  hr_api.g_number;
  l_course_rec.rco_id			       :=  hr_api.g_number;
  l_course_rec.version_code                  :=  hr_api.g_varchar2;
  l_course_rec.keywords                      :=  hr_api.g_varchar2;
  l_course_rec.business_group_id	       :=  hr_api.g_number;
  l_course_rec.data_source                   :=  hr_api.g_varchar2;
  l_course_rec.competency_update_level       :=  hr_api.g_varchar2;

  Hr_Utility.set_location('Leaving: '||l_proc_name, 80);
  return l_course_rec;
exception
  when others then
  Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
  raise;

end Default_Course_Rec;


-- =============================================================================
-- Get_Record_Values:
-- =============================================================================
function Get_Record_Values
        (p_interface_code in varchar2 default null)
         return OTA_ACTIVITY_VERSIONS_VL%rowtype is

  cursor bne_cols(c_interface_code in varchar2) is
  select lower(bic.interface_col_name) interface_col_name
    from bne_interface_cols_b  bic
   where bic.interface_code = c_interface_code
     and bic.display_flag ='Y';
  --and bic.interface_col_type <> 2;

  -- To query cols which are not displayed (DFF segments)
   cursor bne_cols_no_disp(c_interface_code in varchar2) is
  select lower(bic.interface_col_name) interface_col_name
    from bne_interface_cols_b  bic
   where bic.interface_code = c_interface_code
     and bic.display_flag ='N';

  l_course_rec            OTA_ACTIVITY_VERSIONS_VL%rowtype;
  col_name             varchar2(150);
  l_proc_name constant varchar2(150) := g_package||'Get_Record_Values';
begin

  Hr_Utility.set_location(' Entering: '||l_proc_name, 5);
 hr_utility.set_location('p_interface_code'||p_interface_code, 10);
  l_course_rec := Default_Course_Rec;
 hr_utility.set_location('p_interface_code'||p_interface_code, 20);
 hr_utility.set_location('g_interface_code'||g_interface_code, 5);


  for col_rec in bne_cols (g_interface_code)
  loop
 hr_utility.set_location(' in loop col_rec.interface_col_name'||col_rec.interface_col_name, 15);
   case col_rec.interface_col_name

    when 'p_activity_id' then
          l_course_rec.activity_id := g_course_rec.activity_id;
    when 'p_superseded_by_act_version_id' then
          l_course_rec.superseded_by_act_version_id := g_course_rec.superseded_by_act_version_id;
    when 'p_developer_organization_id' then
          l_course_rec.developer_organization_id := g_course_rec.developer_organization_id;
    when 'p_controlling_person_id' then
          l_course_rec.controlling_person_id := g_course_rec.controlling_person_id;
    when 'p_version_name' then
          l_course_rec.version_name := g_course_rec.version_name;
    when 'p_comments' then
          l_course_rec.comments := g_course_rec.comments;
    when 'p_description' then
          l_course_rec.description := g_course_rec.description;
    when 'p_duration' then
          l_course_rec.duration := g_course_rec.duration;
    when 'p_duration_units' then
          l_course_rec.duration_units := g_course_rec.duration_units;
    when 'p_end_date' then
          l_course_rec.end_date := g_course_rec.end_date;
    when 'p_intended_audience' then
          l_course_rec.intended_audience := g_course_rec.intended_audience;
    when 'p_language_id' then
          l_course_rec.language_id := g_course_rec.language_id;
    when 'p_maximum_attendees' then
          l_course_rec.maximum_attendees := g_course_rec.maximum_attendees;
    when 'p_minimum_attendees' then
          l_course_rec.minimum_attendees := g_course_rec.minimum_attendees;
    when 'p_objectives' then
          l_course_rec.objectives := g_course_rec.objectives;
    when 'p_start_date' then
          l_course_rec.start_date := g_course_rec.start_date;
    when 'p_success_criteria' then
          l_course_rec.success_criteria := g_course_rec.success_criteria;
    when 'p_user_status' then
          l_course_rec.user_status := g_course_rec.user_status;
    when 'p_vendor_id' then
          l_course_rec.vendor_id := g_course_rec.vendor_id;
    when 'p_actual_cost' then
          l_course_rec.actual_cost := g_course_rec.actual_cost;
    when 'p_budget_cost' then
          l_course_rec.budget_cost := g_course_rec.budget_cost;
    when 'p_budget_currency_code' then
          l_course_rec.budget_currency_code := g_course_rec.budget_currency_code;
    when 'p_expenses_allowed' then
          l_course_rec.expenses_allowed := g_course_rec.expenses_allowed;
    when 'p_professional_credit_type' then
          l_course_rec.professional_credit_type := g_course_rec.professional_credit_type;
    when 'p_professional_credits' then
          l_course_rec.professional_credits := g_course_rec.professional_credits;
    when 'p_maximum_internal_attendees' then
          l_course_rec.maximum_internal_attendees := g_course_rec.maximum_internal_attendees;
    when 'p_inventory_item_id' then
          l_course_rec.inventory_item_id := g_course_rec.inventory_item_id;
    when 'p_organization_id' then
          l_course_rec.organization_id := g_course_rec.organization_id;
    when 'p_rco_id' then
          l_course_rec.rco_id := g_course_rec.rco_id;
    when 'p_version_code' then
          l_course_rec.version_code := g_course_rec.version_code;
    when 'p_keywords' then
          l_course_rec.keywords := g_course_rec.keywords;
    when 'p_business_group_id' then
          l_course_rec.business_group_id := g_course_rec.business_group_id;
    when 'p_data_source' then
          l_course_rec.data_source := g_course_rec.data_source;
    when 'p_competency_update_level' then
          l_course_rec.competency_update_level := g_course_rec.competency_update_level;

    -- DFF
    when 'p_tav_information_category' then
          l_course_rec.tav_information_category := g_course_rec.tav_information_category;
          if l_course_rec.tav_information_category is not null then
          for col_rec1 in bne_cols_no_disp(g_interface_code) loop

             case col_rec1.interface_col_name
             when 'p_tav_information1' then
                   l_course_rec.tav_information1 := g_course_rec.tav_information1;
             when 'p_tav_information2' then
                   l_course_rec.tav_information2 := g_course_rec.tav_information2;
             when 'p_tav_information3' then
                   l_course_rec.tav_information3 := g_course_rec.tav_information3;
             when 'p_tav_information4' then
                   l_course_rec.tav_information4 := g_course_rec.tav_information4;
             when 'p_tav_information5' then
                   l_course_rec.tav_information5 := g_course_rec.tav_information5;
             when 'p_tav_information6' then
                   l_course_rec.tav_information6 := g_course_rec.tav_information6;
             when 'p_tav_information7' then
                   l_course_rec.tav_information7 := g_course_rec.tav_information7;
             when 'p_tav_information8' then
                   l_course_rec.tav_information8 := g_course_rec.tav_information8;
             when 'p_tav_information9' then
                   l_course_rec.tav_information9 := g_course_rec.tav_information9;
             when 'p_tav_information10' then
                   l_course_rec.tav_information10 := g_course_rec.tav_information10;
             when 'p_tav_information11' then
                   l_course_rec.tav_information11 := g_course_rec.tav_information11;
             when 'p_tav_information12' then
                   l_course_rec.tav_information12 := g_course_rec.tav_information12;
             when 'p_tav_information13' then
                   l_course_rec.tav_information13 := g_course_rec.tav_information13;
             when 'p_tav_information14' then
                   l_course_rec.tav_information14 := g_course_rec.tav_information14;
             when 'p_tav_information15' then
                   l_course_rec.tav_information15 := g_course_rec.tav_information15;
             when 'p_tav_information16' then
                   l_course_rec.tav_information16 := g_course_rec.tav_information16;
             when 'p_tav_information17' then
                   l_course_rec.tav_information17 := g_course_rec.tav_information17;
             when 'p_tav_information18' then
                   l_course_rec.tav_information18 := g_course_rec.tav_information18;
             when 'p_tav_information19' then
                   l_course_rec.tav_information19 := g_course_rec.tav_information19;
             when 'p_tav_information20' then
                   l_course_rec.tav_information20 := g_course_rec.tav_information20;
             else
                  null;
             end case;
            end loop;
           end if;
   else
      null;
   end case;
  end loop;
  Hr_Utility.set_location(' Leaving: '||l_proc_name, 80);
  return l_course_rec;

end Get_Record_Values;
-- ----------------------------------------------------------------------------
-- |------------------------< InsUpd_Course >-----------------------|
-- ----------------------------------------------------------------------------
PROCEDURE InsUpd_Course
  (p_effective_date               in     date
  ,p_validate                     in     number    default hr_api.g_false_num
  ,p_activity_id                  in     number
  ,p_superseded_by_act_version_id in     number    default null
  ,p_developer_organization_id    in     number
  ,p_controlling_person_id        in     number    default null
  ,p_version_name                 in     varchar2
  ,p_comments                     in     varchar2  default null
  ,p_description                  in     varchar2  default null
  ,p_duration                     in     number    default null
  ,p_duration_units               in     varchar2  default null
  ,p_end_date                     in     date      default null
  ,p_intended_audience            in     varchar2  default null
  ,p_language_id                  in     number    default null
  ,p_maximum_attendees            in     number    default null
  ,p_minimum_attendees            in     number    default null
  ,p_objectives                   in     varchar2  default null
  ,p_start_date                   in     date      default null
  ,p_success_criteria             in     varchar2  default null
  ,p_user_status                  in     varchar2  default null
  ,p_vendor_id                    in     number    default null
  ,p_actual_cost                  in     number    default null
  ,p_budget_cost                  in     number    default null
  ,p_budget_currency_code         in     varchar2  default null
  ,p_expenses_allowed             in     varchar2  default null
  ,p_professional_credit_type     in     varchar2  default null
  ,p_professional_credits         in     number    default null
  ,p_maximum_internal_attendees   in     number    default null
  ,p_tav_information_category     in     varchar2  default null
  ,p_tav_information1             in     varchar2  default null
  ,p_tav_information2             in     varchar2  default null
  ,p_tav_information3             in     varchar2  default null
  ,p_tav_information4             in     varchar2  default null
  ,p_tav_information5             in     varchar2  default null
  ,p_tav_information6             in     varchar2  default null
  ,p_tav_information7             in     varchar2  default null
  ,p_tav_information8             in     varchar2  default null
  ,p_tav_information9             in     varchar2  default null
  ,p_tav_information10            in     varchar2  default null
  ,p_tav_information11            in     varchar2  default null
  ,p_tav_information12            in     varchar2  default null
  ,p_tav_information13            in     varchar2  default null
  ,p_tav_information14            in     varchar2  default null
  ,p_tav_information15            in     varchar2  default null
  ,p_tav_information16            in     varchar2  default null
  ,p_tav_information17            in     varchar2  default null
  ,p_tav_information18            in     varchar2  default null
  ,p_tav_information19            in     varchar2  default null
  ,p_tav_information20            in     varchar2  default null
  ,p_inventory_item_id            in     number    default null
  ,p_organization_id              in     number    default null
  ,p_rco_id                       in     number    default null
  ,p_version_code                 in     varchar2  default null
  ,p_keywords                     in     varchar2  default null
  ,p_business_group_id            in     number    default null
  ,p_activity_version_id          in     number    default null
  ,p_object_version_number        in     number    default null
  ,p_return_status                   out nocopy varchar2
  ,p_data_source                  in     varchar2  default null
  ,p_competency_update_level      in     varchar2  default null
  ,P_CRT_UPD			  in 	 varchar2   default null
  ) is
  -- =============================================================================
  -- Variables for API Boolean parameters
  -- =============================================================================

  l_validate                      boolean;

  -- =============================================================================
  -- Other variables
  -- =============================================================================

  l_activity_version_id          number;
  l_activity_category		 varchar2(72);
  l_primary_flag		 varchar2(72):='Y';
  l_aci_information_category     varchar2(72);
  l_category_usage_id		 number(9,0);
  p_aci_information1             varchar2(72);
  p_aci_information2             varchar2(72);
  p_aci_information3             varchar2(72);
  p_aci_information4             varchar2(72);
  p_aci_information5             varchar2(72);
  p_aci_information6             varchar2(72);
  p_aci_information7             varchar2(72);
  p_aci_information8             varchar2(72);
  p_aci_information9             varchar2(72);
  p_aci_information10            varchar2(72);
  p_aci_information11            varchar2(72);
  p_aci_information12            varchar2(72);
  p_aci_information13            varchar2(72);
  p_aci_information14            varchar2(72);
  p_aci_information15            varchar2(72);
  p_aci_information16            varchar2(72);
  p_aci_information17            varchar2(72);
  p_aci_information18            varchar2(72);
  p_aci_information19            varchar2(72);
  p_aci_information20            varchar2(72);
  l_error_msg                    varchar2(4000);
  l_course_rec     OTA_ACTIVITY_VERSIONS_VL%rowtype;
  l_interface_code      varchar2(40);
  l_crt_upd             varchar2(1);
-- =============================================================================
-- ~ Package Body Cursor variables:
-- =============================================================================

Cursor C_Sel_one is
    Select ota_activity_definitions.CATEGORY_USAGE_ID
      from ota_activity_definitions
     where activity_id = p_activity_id;

-- =============================================================================
-- Default_Record_Values:
-- =============================================================================
  l_proc    varchar2(72) := g_package ||'InsUpd_Course';

  l_create_flag    number(2) := 1;
  e_upl_not_allowed exception; -- when mode is 'View Only'
  e_crt_not_allowed exception; -- when mode is 'Update Only'
  g_upl_err_msg varchar2(100) := 'Upload NOT allowed.';
  g_crt_err_msg varchar2(100) := 'Creating NOT allowed.';
  l_act_ver_id      number(9,0);
  l_obj_ver_num       number(2);
  l_object_version_number  number(2);
  l_crt_upd_len         number;


Begin
--hr_utility.trace_on(null, 'Course_Trace');
hr_utility.set_location(' Entering:' || l_proc,10);
  --
  -- Issue a savepoint
  --
  savepoint pqp_riw_course_wrapper;
  --
  -- Convert constant values to their corresponding boolean value
  --
  l_validate :=
    hr_api.constant_to_boolean
      (p_constant_value => p_validate);
  --
  -- Register Surrogate ID or user key values
  --
  ota_tav_ins.set_base_key_value
    (p_activity_version_id => p_activity_version_id
    );
  --
  -- Call API
  --
  l_activity_version_id := p_activity_version_id;
  hr_utility.set_location('The version id is : '||l_activity_version_id, 89);
  if l_activity_version_id is not null then
       l_create_flag := 2;  --update course
  else
       l_create_flag := 1;  --create course
  end if;

 l_crt_upd_len := LENGTH(p_crt_upd);
 l_crt_upd := SUBSTR(p_crt_upd, 1, 1);
 IF l_crt_upd_len > 1 THEN
     l_interface_code := SUBSTR(p_crt_upd, 3);
 ELSE
     l_interface_code := null;
 END IF;

 if (l_crt_upd = 'D') then
   raise e_upl_not_allowed;  -- View only flag is enabled but Trying to Upload
  end if;
  if (l_crt_upd = 'U' and l_create_flag = 1) then
   raise e_crt_not_allowed;  -- Update only flag is enabled but Trying to Create
 end if;

 if(l_create_flag = 1) then
  ota_activity_version_api.create_activity_version
    (p_effective_date               => p_effective_date
    ,p_validate                     => l_validate
    ,p_activity_id                  => p_activity_id
    ,p_superseded_by_act_version_id => p_superseded_by_act_version_id
    ,p_developer_organization_id    => p_developer_organization_id
    ,p_controlling_person_id        => p_controlling_person_id
    ,p_version_name                 => p_version_name
    ,p_comments                     => p_comments
    ,p_description                  => p_description
    ,p_duration                     => p_duration
    ,p_duration_units               => p_duration_units
    ,p_end_date                     => p_end_date
    ,p_intended_audience            => p_intended_audience
    ,p_language_id                  => p_language_id
    ,p_maximum_attendees            => p_maximum_attendees
    ,p_minimum_attendees            => p_minimum_attendees
    ,p_objectives                   => p_objectives
    ,p_start_date                   => p_start_date
    ,p_success_criteria             => p_success_criteria
    ,p_user_status                  => p_user_status
    ,p_vendor_id                    => p_vendor_id
    ,p_actual_cost                  => p_actual_cost
    ,p_budget_cost                  => p_budget_cost
    ,p_budget_currency_code         => p_budget_currency_code
    ,p_expenses_allowed             => p_expenses_allowed
    ,p_professional_credit_type     => p_professional_credit_type
    ,p_professional_credits         => p_professional_credits
    ,p_maximum_internal_attendees   => p_maximum_internal_attendees
    ,p_tav_information_category     => p_tav_information_category
    ,p_tav_information1             => p_tav_information1
    ,p_tav_information2             => p_tav_information2
    ,p_tav_information3             => p_tav_information3
    ,p_tav_information4             => p_tav_information4
    ,p_tav_information5             => p_tav_information5
    ,p_tav_information6             => p_tav_information6
    ,p_tav_information7             => p_tav_information7
    ,p_tav_information8             => p_tav_information8
    ,p_tav_information9             => p_tav_information9
    ,p_tav_information10            => p_tav_information10
    ,p_tav_information11            => p_tav_information11
    ,p_tav_information12            => p_tav_information12
    ,p_tav_information13            => p_tav_information13
    ,p_tav_information14            => p_tav_information14
    ,p_tav_information15            => p_tav_information15
    ,p_tav_information16            => p_tav_information16
    ,p_tav_information17            => p_tav_information17
    ,p_tav_information18            => p_tav_information18
    ,p_tav_information19            => p_tav_information19
    ,p_tav_information20            => p_tav_information20
    ,p_inventory_item_id            => p_inventory_item_id
    ,p_organization_id              => p_organization_id
    ,p_rco_id                       => p_rco_id
    ,p_version_code                 => p_version_code
    ,p_keywords                     => p_keywords
    ,p_business_group_id            => p_business_group_id
    ,p_activity_version_id          => l_act_ver_id
    ,p_object_version_number        => l_obj_ver_num
    ,p_data_source                  => p_data_source
    ,p_competency_update_level      => p_competency_update_level
    );

    hr_utility.set_location('The code has created success', 90);
    Open C_Sel_one;
    Fetch C_Sel_one into l_category_usage_id;
    Close C_Sel_one;
    hr_utility.set_location('After that success as well', 90);



ota_activity_category_api.create_act_cat_inclusion
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_activity_version_id          => l_act_ver_id
    ,p_activity_category            => l_activity_category
    ,p_comments                     => p_comments
    ,p_object_version_number        => l_obj_ver_num
    ,p_aci_information_category     => l_aci_information_category
    ,p_aci_information1             => p_aci_information1
    ,p_aci_information2             => p_aci_information2
    ,p_aci_information3             => p_aci_information3
    ,p_aci_information4             => p_aci_information4
    ,p_aci_information5             => p_aci_information5
    ,p_aci_information6             => p_aci_information6
    ,p_aci_information7             => p_aci_information7
    ,p_aci_information8             => p_aci_information8
    ,p_aci_information9             => p_aci_information9
    ,p_aci_information10            => p_aci_information10
    ,p_aci_information11            => p_aci_information11
    ,p_aci_information12            => p_aci_information12
    ,p_aci_information13            => p_aci_information13
    ,p_aci_information14            => p_aci_information14
    ,p_aci_information15            => p_aci_information15
    ,p_aci_information16            => p_aci_information16
    ,p_aci_information17            => p_aci_information17
    ,p_aci_information18            => p_aci_information18
    ,p_aci_information19            => p_aci_information19
    ,p_aci_information20            => p_aci_information20
    ,p_start_date_active            => null
    ,p_end_date_active              => null
    ,p_primary_flag                 => l_primary_flag
    ,p_category_usage_id            => l_category_usage_id
    );
 end if;

 if l_create_flag = 2 then
 hr_utility.set_location('Inside the update', 90);
 g_interface_code := nvl(l_interface_code,'PQP_OLM_COURSE_INTF');

 g_course_rec.activity_id										:= p_activity_id;
 g_course_rec.superseded_by_act_version_id	:= p_superseded_by_act_version_id;
 g_course_rec.developer_organization_id			:= p_developer_organization_id;
 g_course_rec.controlling_person_id					:= p_controlling_person_id    ;
 g_course_rec.version_name									:= p_version_name             ;
 g_course_rec.comments											:= p_comments                 ;
 g_course_rec.description										:= p_description              ;
 g_course_rec.duration											:= p_duration                 ;
 g_course_rec.duration_units								:= p_duration_units           ;
 g_course_rec.end_date											:= p_end_date                 ;
 g_course_rec.intended_audience							:= p_intended_audience        ;
 g_course_rec.language_id										:= p_language_id              ;
 g_course_rec.maximum_attendees							:= p_maximum_attendees        ;
 g_course_rec.minimum_attendees							:= p_minimum_attendees        ;
 g_course_rec.objectives										:= p_objectives               ;
 g_course_rec.start_date										:= p_start_date               ;
 g_course_rec.success_criteria							:= p_success_criteria         ;
 g_course_rec.user_status										:= p_user_status              ;
 g_course_rec.vendor_id											:= p_vendor_id                ;
 g_course_rec.actual_cost										:= p_actual_cost              ;
 g_course_rec.budget_cost										:= p_budget_cost              ;
 g_course_rec.budget_currency_code					:= p_budget_currency_code     ;
 g_course_rec.expenses_allowed							:= p_expenses_allowed         ;
 g_course_rec.professional_credit_type			:= p_professional_credit_type ;
 g_course_rec.professional_credits					:= p_professional_credits     ;
 g_course_rec.maximum_internal_attendees		:= p_maximum_internal_attendees;
 g_course_rec.tav_information_category			:= p_tav_information_category  ;
 g_course_rec.tav_information1							:= p_tav_information1          ;
 g_course_rec.tav_information2							:= p_tav_information2          ;
 g_course_rec.tav_information3							:= p_tav_information3          ;
 g_course_rec.tav_information4							:= p_tav_information4          ;
 g_course_rec.tav_information5							:= p_tav_information5          ;
 g_course_rec.tav_information6							:= p_tav_information6          ;
 g_course_rec.tav_information7							:= p_tav_information7          ;
 g_course_rec.tav_information8							:= p_tav_information8          ;
 g_course_rec.tav_information9							:= p_tav_information9          ;
 g_course_rec.tav_information10							:= p_tav_information10         ;
 g_course_rec.tav_information11							:= p_tav_information11         ;
 g_course_rec.tav_information12							:= p_tav_information12         ;
 g_course_rec.tav_information13							:= p_tav_information13         ;
 g_course_rec.tav_information14							:= p_tav_information14         ;
 g_course_rec.tav_information15							:= p_tav_information15         ;
 g_course_rec.tav_information16							:= p_tav_information16         ;
 g_course_rec.tav_information17							:= p_tav_information17         ;
 g_course_rec.tav_information18							:= p_tav_information18         ;
 g_course_rec.tav_information19							:= p_tav_information19         ;
 g_course_rec.tav_information20							:= p_tav_information20         ;
 g_course_rec.inventory_item_id							:= p_inventory_item_id 	     ;
 g_course_rec.organization_id							:= p_organization_id	     ;
 g_course_rec.rco_id								:= p_rco_id			     ;
 g_course_rec.version_code							:= p_version_code                ;
 g_course_rec.keywords								:= p_keywords                    ;
 g_course_rec.business_group_id							:= p_business_group_id	     ;
 g_course_rec.data_source							:= p_data_source              ;
 g_course_rec.competency_update_level				                := p_competency_update_level   ;




l_course_rec := Get_Record_Values(g_interface_code);

select object_version_number into l_object_version_number from
     ota_activity_versions where activity_version_id = l_activity_version_id;

ota_activity_version_api.update_activity_version
  (
  p_effective_date               => p_effective_date,
  p_activity_version_id          => l_activity_version_id,
  p_activity_id                  => l_course_rec.activity_id,
  p_superseded_by_act_version_id => l_course_rec.superseded_by_act_version_id,
  p_developer_organization_id    => l_course_rec.developer_organization_id,
  p_controlling_person_id        => l_course_rec.controlling_person_id,
  p_object_version_number        => l_object_version_number,
  p_version_name                 => l_course_rec.version_name,
  p_comments                     => l_course_rec.comments,
  p_description                  => l_course_rec.description,
  p_duration                     => l_course_rec.duration,
  p_duration_units               => l_course_rec.duration_units,
  p_end_date                     => l_course_rec.end_date,
  p_intended_audience            => l_course_rec.intended_audience,
  p_language_id                  => l_course_rec.language_id ,
  p_maximum_attendees            => l_course_rec.maximum_attendees,
  p_minimum_attendees            => l_course_rec.minimum_attendees,
  p_objectives                   => l_course_rec.objectives,
  p_start_date                   => l_course_rec.start_date,
  p_success_criteria             => l_course_rec.success_criteria,
  p_user_status                  => l_course_rec.user_status,
  p_vendor_id                    => l_course_rec.vendor_id,
  p_actual_cost                  => l_course_rec.actual_cost,
  p_budget_cost                  => l_course_rec.budget_cost,
  p_budget_currency_code         => l_course_rec.budget_currency_code,
  p_expenses_allowed             => l_course_rec.expenses_allowed,
  p_professional_credit_type     => l_course_rec.professional_credit_type,
  p_professional_credits         => l_course_rec.professional_credits,
  p_maximum_internal_attendees   => l_course_rec.maximum_internal_attendees
    ,p_tav_information_category     => l_course_rec.tav_information_category
    ,p_tav_information1             => l_course_rec.tav_information1
    ,p_tav_information2             => l_course_rec.tav_information2
    ,p_tav_information3             => l_course_rec.tav_information3
    ,p_tav_information4             => l_course_rec.tav_information4
    ,p_tav_information5             => l_course_rec.tav_information5
    ,p_tav_information6             => l_course_rec.tav_information6
    ,p_tav_information7             => l_course_rec.tav_information7
    ,p_tav_information8             => l_course_rec.tav_information8
    ,p_tav_information9             => l_course_rec.tav_information9
    ,p_tav_information10            => l_course_rec.tav_information10
    ,p_tav_information11            => l_course_rec.tav_information11
    ,p_tav_information12            => l_course_rec.tav_information12
    ,p_tav_information13            => l_course_rec.tav_information13
    ,p_tav_information14            => l_course_rec.tav_information14
    ,p_tav_information15            => l_course_rec.tav_information15
    ,p_tav_information16            => l_course_rec.tav_information16
    ,p_tav_information17            => l_course_rec.tav_information17
    ,p_tav_information18            => l_course_rec.tav_information18
    ,p_tav_information19            => l_course_rec.tav_information19
    ,p_tav_information20            => l_course_rec.tav_information20
    ,p_inventory_item_id            => l_course_rec.inventory_item_id
    ,p_organization_id              => l_course_rec.organization_id
    ,p_rco_id                       => l_course_rec.rco_id
    ,p_version_code                 => l_course_rec.version_code
    ,p_keywords                     => l_course_rec.keywords
    ,p_business_group_id            => l_course_rec.business_group_id
    ,p_data_source                  => l_course_rec.data_source
    ,p_competency_update_level      => l_course_rec.competency_update_level
  );
 end if;



  hr_utility.set_location(' Leaving:' || l_proc,20);

exception

  when e_upl_not_allowed then
    hr_utility.set_message(8303, 'PQP_230500_HROSS_GENERIC_ERR');
    hr_utility.set_message_token('GENERIC_TOKEN',g_upl_err_msg);
    hr_utility.set_location('Leaving: ' || l_proc, 90);
    hr_utility.raise_error;
  when e_crt_not_allowed then
    hr_utility.set_message(8303, 'PQP_230500_HROSS_GENERIC_ERR');
    hr_utility.set_message_token('GENERIC_TOKEN',g_crt_err_msg);
    hr_utility.set_location('Leaving: ' || l_proc, 100);
    hr_utility.raise_error;
when others then
   --l_error_msg := Substr(SQLERRM,1,2000);
   hr_utility.set_location('SQLCODE :' || SQLCODE,90);
   hr_utility.set_location('SQLERRM :' || SQLERRM,90);
   --hr_utility.set_message(8303, 'PQP_230500_HROSS_GENERIC_ERR');
   --hr_utility.set_message_token('GENERIC_TOKEN',substr(l_error_msg,1,500) );
   hr_utility.set_location(' Leaving:' || l_proc,50);
   hr_utility.raise_error;

end InsUpd_Course;
end pqp_riw_course_wrapper;

/

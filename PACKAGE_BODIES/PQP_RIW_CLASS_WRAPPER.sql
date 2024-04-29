--------------------------------------------------------
--  DDL for Package Body PQP_RIW_CLASS_WRAPPER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_RIW_CLASS_WRAPPER" as
/* $Header: pqpriwclwr.pkb 120.0.12010000.8 2009/04/24 08:37:28 psengupt noship $ */

-- =============================================================================
-- ~ Package Body Global variables:
-- =============================================================================
g_package  varchar2(33) := 'pqp_riw_class_wrapper';
g_class_rec                     ota_events_vl%rowtype;
g_interface_code              varchar2(150);
g_course_end_time					varchar2(9);
g_course_start_time			varchar2(9);

-- =============================================================================
-- Default_Record_Values:
-- =============================================================================
function Default_Class_Rec
         return ota_events_vl%rowtype is
  l_proc_name    constant varchar2(150) := g_package||'Default_Class_Rec';
  l_class_rec     ota_events_vl%rowtype;

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

  l_class_rec.vendor_id               :=  hr_api.g_number      ;
  l_class_rec.activity_version_id     :=  hr_api.g_number      ;
  l_class_rec.business_group_id       :=  hr_api.g_number      ;
  l_class_rec.organization_id         :=  hr_api.g_number      ;
  l_class_rec.event_type              :=  hr_api.g_varchar2    ;
  l_class_rec.title                   :=  hr_api.g_varchar2    ;
  l_class_rec.budget_cost             :=  hr_api.g_number      ;
  l_class_rec.actual_cost             :=  hr_api.g_number      ;
  Hr_Utility.set_location(' One : ', 5);
  l_class_rec.budget_currency_code    :=  hr_api.g_varchar2    ;
  Hr_Utility.set_location(' Two : ', 5);
  l_class_rec.centre                  :=  hr_api.g_varchar2    ;
  Hr_Utility.set_location(' Three : ', 5);
  l_class_rec.comments                :=  hr_api.g_varchar2    ;
  Hr_Utility.set_location(' Four : ', 5);
  l_class_rec.course_end_date         :=  hr_api.g_date        ;
  Hr_Utility.set_location(' Five : ', 5);
--  l_class_rec.course_end_time         :=  hr_api.g_varchar2    ;
  g_course_end_time         :=  hr_api.g_varchar2    ;
  Hr_Utility.set_location(' Siz : ', 5);
  l_class_rec.course_start_date       :=  hr_api.g_date        ;
  Hr_Utility.set_location(' Sev : ', 5);
--  l_class_rec.course_start_time       :=  hr_api.g_varchar2    ;
  g_course_start_time       :=  hr_api.g_varchar2    ;
  Hr_Utility.set_location(' Ei : ', 5);

  l_class_rec.duration                :=  hr_api.g_number      ;
  l_class_rec.duration_units          :=  hr_api.g_varchar2    ;
  l_class_rec.enrolment_end_date      :=  hr_api.g_date        ;
  l_class_rec.enrolment_start_date    :=  hr_api.g_date        ;
  l_class_rec.language_id             :=  hr_api.g_number      ;
  l_class_rec.user_status             :=  hr_api.g_varchar2    ;
  l_class_rec.development_event_type  :=  hr_api.g_varchar2    ;
  l_class_rec.event_status            :=  hr_api.g_varchar2    ;

  l_class_rec.price_basis             :=  hr_api.g_varchar2    ;
  l_class_rec.currency_code           :=  hr_api.g_varchar2    ;
  l_class_rec.maximum_attendees       :=  hr_api.g_number      ;
  l_class_rec.maximum_internal_attendees:=  hr_api.g_number      ;
  l_class_rec.minimum_attendees       :=  hr_api.g_number      ;
  l_class_rec.standard_price          :=  hr_api.g_number      ;
  l_class_rec.category_code           :=  hr_api.g_varchar2    ;
  l_class_rec.parent_event_id         :=  hr_api.g_number      ;
  l_class_rec.book_independent_flag   :=  hr_api.g_varchar2    ;
  l_class_rec.public_event_flag       :=  hr_api.g_varchar2    ;
  l_class_rec.secure_event_flag       :=  hr_api.g_varchar2    ;
  l_class_rec.evt_information_category:=  hr_api.g_varchar2    ;
  l_class_rec.evt_information1        :=  hr_api.g_varchar2    ;
  l_class_rec.evt_information2        :=  hr_api.g_varchar2    ;
  l_class_rec.evt_information3        :=  hr_api.g_varchar2    ;
  l_class_rec.evt_information4        :=  hr_api.g_varchar2    ;
  l_class_rec.evt_information5        :=  hr_api.g_varchar2    ;
  l_class_rec.evt_information6        :=  hr_api.g_varchar2    ;
  l_class_rec.evt_information7        :=  hr_api.g_varchar2    ;
  l_class_rec.evt_information8        :=  hr_api.g_varchar2    ;
  l_class_rec.evt_information9        :=  hr_api.g_varchar2    ;
  l_class_rec.evt_information10       :=  hr_api.g_varchar2    ;
  l_class_rec.evt_information11       :=  hr_api.g_varchar2    ;
  l_class_rec.evt_information12       :=  hr_api.g_varchar2    ;
  l_class_rec.evt_information13       :=  hr_api.g_varchar2 ;
  l_class_rec.evt_information14       :=  hr_api.g_varchar2 ;
  l_class_rec.evt_information15       :=  hr_api.g_varchar2 ;
  l_class_rec.evt_information16       :=  hr_api.g_varchar2 ;
  l_class_rec.evt_information17       :=  hr_api.g_varchar2 ;
  l_class_rec.evt_information18       :=  hr_api.g_varchar2 ;
  l_class_rec.evt_information19       :=  hr_api.g_varchar2 ;
  l_class_rec.evt_information20       :=  hr_api.g_varchar2 ;
  l_class_rec.project_id              :=  hr_api.g_number   ;
  l_class_rec.owner_id                :=  hr_api.g_number   ;
  l_class_rec.line_id	              :=  hr_api.g_number   ;
  l_class_rec.org_id	              :=  hr_api.g_number   ;
  l_class_rec.training_center_id      :=  hr_api.g_number   ;
  l_class_rec.location_id	      :=  hr_api.g_number   ;
  l_class_rec.offering_id	      :=  hr_api.g_number   ;
  l_class_rec.timezone	              :=  hr_api.g_varchar2 ;
  l_class_rec.parent_offering_id      :=  hr_api.g_number   ;
  l_class_rec.data_source             :=  hr_api.g_varchar2 ;

  Hr_Utility.set_location('Leaving: '||l_proc_name, 80);
  return l_class_rec;
exception
  when others then
  Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
  raise;

end Default_Class_Rec;


-- =============================================================================
-- Get_Record_Values:
-- =============================================================================
function Get_Record_Values
        (p_interface_code in varchar2 default null)
         return ota_events_vl%rowtype is

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

  l_class_rec            ota_events_vl%rowtype;
  col_name             varchar2(150);
  l_proc_name constant varchar2(150) := g_package||'Get_Record_Values';
begin

  Hr_Utility.set_location(' Entering: '||l_proc_name, 5);
 hr_utility.set_location('p_interface_code'||p_interface_code, 10);
  l_class_rec := Default_Class_Rec;
 hr_utility.set_location('p_interface_code'||p_interface_code, 20);
 hr_utility.set_location('g_interface_code'||g_interface_code, 5);


  for col_rec in bne_cols (g_interface_code)
  loop
 hr_utility.set_location(' in loop col_rec.interface_col_name'||col_rec.interface_col_name, 15);
   case col_rec.interface_col_name

    when 'p_vendor_id' then
          l_class_rec.vendor_id := g_class_rec.vendor_id;
    when 'p_activity_version_id' then
          l_class_rec.activity_version_id := g_class_rec.activity_version_id;
    when 'p_business_grouid' then
          l_class_rec.business_group_id := g_class_rec.business_group_id;
    when 'p_organization_id' then
          l_class_rec.organization_id := g_class_rec.organization_id;
    when 'p_event_type' then
          l_class_rec.event_type := g_class_rec.event_type;
    when 'p_title' then
          l_class_rec.title := g_class_rec.title;
    when 'p_budget_cost' then
          l_class_rec.budget_cost := g_class_rec.budget_cost;
    when 'p_actual_cost' then
          l_class_rec.actual_cost := g_class_rec.actual_cost;
    when 'p_budget_currency_code' then
          l_class_rec.budget_currency_code := g_class_rec.budget_currency_code;
    when 'p_centre' then
          l_class_rec.centre := g_class_rec.centre;
    when 'p_comments' then
          l_class_rec.comments := g_class_rec.comments;
    when 'p_course_end_date' then
          l_class_rec.course_end_date := g_class_rec.course_end_date;
    when 'p_course_end_time' then
--          l_class_rec.course_end_time := g_class_rec.course_end_time;
          g_course_end_time := g_class_rec.course_end_time;
    when 'p_course_start_date' then
          l_class_rec.course_start_date := g_class_rec.course_start_date;
    when 'p_course_start_time' then
--          l_class_rec.course_start_time := g_class_rec.course_start_time;
					g_course_start_time:= g_class_rec.course_start_time;
    when 'p_duration' then
          l_class_rec.duration := g_class_rec.duration;
    when 'p_duration_units' then
          l_class_rec.duration_units := g_class_rec.duration_units;
    when 'p_enrolment_end_date' then
          l_class_rec.enrolment_end_date := g_class_rec.enrolment_end_date;
    when 'p_enrolment_start_date' then
          l_class_rec.enrolment_start_date := g_class_rec.enrolment_start_date;
    when 'p_language_id' then
          l_class_rec.language_id := g_class_rec.language_id;
    when 'p_user_status' then
          l_class_rec.user_status := g_class_rec.user_status;
    when 'p_development_event_type' then
          l_class_rec.development_event_type := g_class_rec.development_event_type;
    when 'p_event_status' then
          l_class_rec.event_status := g_class_rec.event_status;
    when 'p_price_basis' then
          l_class_rec.price_basis := g_class_rec.price_basis;
    when 'p_currency_code' then
          l_class_rec.currency_code := g_class_rec.currency_code;
    when 'p_maximum_attendees' then
          l_class_rec.maximum_attendees := g_class_rec.maximum_attendees;
    when 'p_maximum_internal_attendees' then
          l_class_rec.maximum_internal_attendees := g_class_rec.maximum_internal_attendees;
    when 'p_minimum_attendees' then
          l_class_rec.minimum_attendees := g_class_rec.minimum_attendees;
    when 'p_standard_price' then
          l_class_rec.standard_price := g_class_rec.standard_price;
    when 'p_category_code' then
          l_class_rec.category_code := g_class_rec.category_code;
    when 'p_parent_event_id' then
          l_class_rec.parent_event_id := g_class_rec.parent_event_id;
    when 'p_book_independent_flag' then
          l_class_rec.book_independent_flag := g_class_rec.book_independent_flag;
    when 'p_public_event_flag' then
          l_class_rec.public_event_flag := g_class_rec.public_event_flag;
    when 'p_secure_event_flag' then
          l_class_rec.secure_event_flag := g_class_rec.secure_event_flag;
    when 'p_project_id' then
          l_class_rec.project_id := g_class_rec.project_id;
    when 'p_owner_id' then
          l_class_rec.owner_id := g_class_rec.owner_id;
    when 'p_line_id' then
          l_class_rec.line_id := g_class_rec.line_id;
    when 'p_org_id' then
          l_class_rec.org_id := g_class_rec.org_id;
    when 'p_training_center_id' then
          l_class_rec.training_center_id := g_class_rec.training_center_id;
    when 'p_location_id' then
          l_class_rec.location_id := g_class_rec.location_id;
    when 'p_offering_id' then
          l_class_rec.offering_id := g_class_rec.offering_id;
    when 'p_timezone' then
          l_class_rec.timezone := g_class_rec.timezone;
    when 'p_parent_offering_id' then
          l_class_rec.parent_offering_id := g_class_rec.parent_offering_id;
    when 'p_data_source' then
          l_class_rec.data_source := g_class_rec.data_source;

    -- DFF
    when 'p_evt_information_category' then
          l_class_rec.evt_information_category := g_class_rec.evt_information_category;
          if l_class_rec.evt_information_category is not null then
          for col_rec1 in bne_cols_no_disp(g_interface_code) loop

             case col_rec1.interface_col_name
             when 'p_evt_information1' then
                   l_class_rec.evt_information1 := g_class_rec.evt_information1;
             when 'p_evt_information2' then
                   l_class_rec.evt_information2 := g_class_rec.evt_information2;
             when 'p_evt_information3' then
                   l_class_rec.evt_information3 := g_class_rec.evt_information3;
             when 'p_evt_information4' then
                   l_class_rec.evt_information4 := g_class_rec.evt_information4;
             when 'p_evt_information5' then
                   l_class_rec.evt_information5 := g_class_rec.evt_information5;
             when 'p_evt_information6' then
                   l_class_rec.evt_information6 := g_class_rec.evt_information6;
             when 'p_evt_information7' then
                   l_class_rec.evt_information7 := g_class_rec.evt_information7;
             when 'p_evt_information8' then
                   l_class_rec.evt_information8 := g_class_rec.evt_information8;
             when 'p_evt_information9' then
                   l_class_rec.evt_information9 := g_class_rec.evt_information9;
             when 'p_evt_information10' then
                   l_class_rec.evt_information10 := g_class_rec.evt_information10;
             when 'p_evt_information11' then
                   l_class_rec.evt_information11 := g_class_rec.evt_information11;
             when 'p_evt_information12' then
                   l_class_rec.evt_information12 := g_class_rec.evt_information12;
             when 'p_evt_information13' then
                   l_class_rec.evt_information13 := g_class_rec.evt_information13;
             when 'p_evt_information14' then
                   l_class_rec.evt_information14 := g_class_rec.evt_information14;
             when 'p_evt_information15' then
                   l_class_rec.evt_information15 := g_class_rec.evt_information15;
             when 'p_evt_information16' then
                   l_class_rec.evt_information16 := g_class_rec.evt_information16;
             when 'p_evt_information17' then
                   l_class_rec.evt_information17 := g_class_rec.evt_information17;
             when 'p_evt_information18' then
                   l_class_rec.evt_information18 := g_class_rec.evt_information18;
             when 'p_evt_information19' then
                   l_class_rec.evt_information19 := g_class_rec.evt_information19;
             when 'p_evt_information20' then
                   l_class_rec.evt_information20 := g_class_rec.evt_information20;
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
  return l_class_rec;

end Get_Record_Values;

-- =============================================================================
-- InsUpd_Class:
-- =============================================================================

PROCEDURE InsUpd_Class
  (p_effective_date               in     date      default sysdate
  ,p_event_id                     in     number    default null
  ,p_vendor_id                    in     number    default null
  ,p_activity_version_id          in     number    default null
  ,p_dummy_col_offering		  in	 varchar2
  ,p_parent_offering_id           in     number
  ,p_business_group_id            in     number
  ,p_organization_id              in     number    default null
  ,p_event_type                   in     varchar2
  ,p_object_version_number        in     number
  ,p_title                        in     varchar2
  ,p_budget_cost                  in     number    default null
  ,p_actual_cost                  in     number    default null
  ,p_budget_currency_code         in     varchar2  default null
  ,p_centre                       in     varchar2  default null
  ,p_comments                     in     varchar2  default null
  ,p_course_end_date              in     date      default null
  ,p_course_end_time              in     varchar2  default null
  ,p_course_start_date            in     date      default null
  ,p_course_start_time            in     varchar2  default null
  ,p_duration                     in     number    default null
  ,p_duration_units               in     varchar2  default null
  ,p_enrolment_end_date           in     date      default null
  ,p_enrolment_start_date         in     date      default null
  ,p_language_id                  in     number    default null
  ,p_user_status                  in     varchar2  default null
  ,p_development_event_type       in     varchar2  default null
  ,p_event_status                 in     varchar2  default null
  ,p_price_basis                  in     varchar2  default null
  ,p_currency_code                in     varchar2  default null
  ,p_maximum_attendees            in     number    default null
  ,p_maximum_internal_attendees   in     number    default null
  ,p_minimum_attendees            in     number    default null
  ,p_standard_price               in     number    default null
  ,p_category_code                in     varchar2  default null
  ,p_parent_event_id              in     number    default null
  ,p_book_independent_flag        in     varchar2  default null
  ,p_public_event_flag            in     varchar2  default null
  ,p_secure_event_flag            in     varchar2  default null
  ,p_evt_information_category     in     varchar2  default null
  ,p_evt_information1             in     varchar2  default null
  ,p_evt_information2             in     varchar2  default null
  ,p_evt_information3             in     varchar2  default null
  ,p_evt_information4             in     varchar2  default null
  ,p_evt_information5             in     varchar2  default null
  ,p_evt_information6             in     varchar2  default null
  ,p_evt_information7             in     varchar2  default null
  ,p_evt_information8             in     varchar2  default null
  ,p_evt_information9             in     varchar2  default null
  ,p_evt_information10            in     varchar2  default null
  ,p_evt_information11            in     varchar2  default null
  ,p_evt_information12            in     varchar2  default null
  ,p_evt_information13            in     varchar2  default null
  ,p_evt_information14            in     varchar2  default null
  ,p_evt_information15            in     varchar2  default null
  ,p_evt_information16            in     varchar2  default null
  ,p_evt_information17            in     varchar2  default null
  ,p_evt_information18            in     varchar2  default null
  ,p_evt_information19            in     varchar2  default null
  ,p_evt_information20            in     varchar2  default null
  ,p_project_id                   in     number    default null
  ,p_owner_id                     in     number    default null
  ,p_line_id                      in     number    default null
  ,p_org_id                       in     number    default null
  ,p_training_center_id           in     number    default null
  ,p_location_id                  in     number    default null
  ,p_offering_id                  in     number    default null
  ,p_timezone                     in     varchar2  default null
  ,p_validate                     in     number    default hr_api.g_false_num
  ,p_return_status                   out nocopy varchar2
  ,p_data_source                  in     varchar2  default null
  ,P_CRT_UPD			  in 	 varchar2   default null
  ) is


  -- =============================================================================
  -- Variables for API Boolean parameters
  -- =============================================================================

  l_validate                      boolean;
  -- =============================================================================
  -- Variables for IN/OUT parameters
  -- =============================================================================
  l_event_id                      ota_events.event_id%TYPE;

  -- =============================================================================
  -- Other variables
  -- =============================================================================

  l_error_msg              varchar2(4000);

  -- =============================================================================
  -- Default_Record_Values:
  -- =============================================================================


  l_proc    varchar2(72) := g_package ||'InsUpd_Class';

  l_create_flag    number(2) := 1;
  l_public_event_flag varchar2(30);
  e_upl_not_allowed exception; -- when mode is 'View Only'
  e_crt_not_allowed exception; -- when mode is 'Update Only'
  g_upl_err_msg varchar2(100) := 'Upload NOT allowed.';
  g_crt_err_msg varchar2(100) := 'Creating NOT allowed.';

  l_ev_id          number(9,0);
  l_obj_ver_num    number(3);
  l_object_version_number  number(3);
  l_class_rec     ota_events_vl%rowtype;
  l_interface_code      varchar2(40);
  l_crt_upd             varchar2(1);
  l_crt_upd_len         number;


  Begin
    --hr_utility.trace_on(null, 'Class_Trace');
    hr_utility.set_location('Entering: '|| l_proc, 11);
    l_validate :=    hr_api.constant_to_boolean  (p_constant_value => p_validate);
    l_event_id := p_event_id;
    --
    -- Call API
    --
  if l_event_id is not null then
      l_create_flag := 2;
  else
      l_create_flag := 1;
  end if;

  if(p_public_event_flag is not null)then
     if (p_public_event_flag ='Y') then  -- If restricted public event flag is set to 'N'
        l_public_event_flag :='N';
     end if;
     if (p_public_event_flag ='N') then  -- If unrestricted public event flag is set to 'Y'
        l_public_event_flag :='Y';
     end if;
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

 hr_utility.set_location('The class Id is : '||l_event_id, 89);

 if l_create_flag = 1 then
  ota_event_api.create_class
    (p_effective_date               => p_effective_date
    ,p_event_id                     => l_ev_id
    ,p_vendor_id                    => p_vendor_id
    ,p_activity_version_id          => p_activity_version_id
    ,p_business_group_id            => p_business_group_id
    ,p_organization_id              => p_organization_id
    ,p_event_type                   => p_event_type
    ,p_object_version_number        => l_obj_ver_num
    ,p_title                        => p_title
    ,p_budget_cost                  => p_budget_cost
    ,p_actual_cost                  => p_actual_cost
    ,p_budget_currency_code         => p_budget_currency_code
    ,p_centre                       => p_centre
    ,p_comments                     => p_comments
    ,p_course_end_date              => p_course_end_date
    ,p_course_end_time              => p_course_end_time
    ,p_course_start_date            => p_course_start_date
    ,p_course_start_time            => p_course_start_time
    ,p_duration                     => p_duration
    ,p_duration_units               => p_duration_units
    ,p_enrolment_end_date           => p_enrolment_end_date
    ,p_enrolment_start_date         => p_enrolment_start_date
    ,p_language_id                  => p_language_id
    ,p_user_status                  => p_user_status
    ,p_development_event_type       => p_development_event_type
    ,p_event_status                 => p_event_status
    ,p_price_basis                  => p_price_basis
    ,p_currency_code                => p_currency_code
    ,p_maximum_attendees            => p_maximum_attendees
    ,p_maximum_internal_attendees   => p_maximum_internal_attendees
    ,p_minimum_attendees            => p_minimum_attendees
    ,p_standard_price               => p_standard_price
    ,p_category_code                => p_category_code
    ,p_parent_event_id              => p_parent_event_id
    ,p_book_independent_flag        => p_book_independent_flag
    ,p_public_event_flag            => l_public_event_flag
    ,p_secure_event_flag            => p_secure_event_flag
    ,p_evt_information_category     => p_evt_information_category
    ,p_evt_information1             => p_evt_information1
    ,p_evt_information2             => p_evt_information2
    ,p_evt_information3             => p_evt_information3
    ,p_evt_information4             => p_evt_information4
    ,p_evt_information5             => p_evt_information5
    ,p_evt_information6             => p_evt_information6
    ,p_evt_information7             => p_evt_information7
    ,p_evt_information8             => p_evt_information8
    ,p_evt_information9             => p_evt_information9
    ,p_evt_information10            => p_evt_information10
    ,p_evt_information11            => p_evt_information11
    ,p_evt_information12            => p_evt_information12
    ,p_evt_information13            => p_evt_information13
    ,p_evt_information14            => p_evt_information14
    ,p_evt_information15            => p_evt_information15
    ,p_evt_information16            => p_evt_information16
    ,p_evt_information17            => p_evt_information17
    ,p_evt_information18            => p_evt_information18
    ,p_evt_information19            => p_evt_information19
    ,p_evt_information20            => p_evt_information20
    ,p_project_id                   => p_project_id
    ,p_owner_id                     => p_owner_id
    ,p_line_id                      => p_line_id
    ,p_org_id                       => p_org_id
    ,p_training_center_id           => p_training_center_id
    ,p_location_id                  => p_location_id
    ,p_offering_id                  => p_offering_id
    ,p_timezone                     => p_timezone
    ,p_parent_offering_id           => p_parent_offering_id
    ,p_validate                     => l_validate
    ,p_data_source                  => p_data_source
    );
 end if;


 if l_create_flag = 2 then
 g_interface_code := nvl(l_interface_code,'PQP_OLM_CLASS_INTF');

 g_class_rec.vendor_id               :=   p_vendor_id                    ;
  Hr_Utility.set_location(' One : ', 5);
 g_class_rec.activity_version_id     :=   p_activity_version_id          ;

 g_class_rec.business_group_id       :=   p_business_group_id            ;
 g_class_rec.organization_id         :=   p_organization_id              ;
 g_class_rec.event_type              :=   p_event_type                   ;
 g_class_rec.title                   :=   p_title                        ;
 g_class_rec.budget_cost             :=   p_budget_cost                  ;
 g_class_rec.actual_cost             :=   p_actual_cost                  ;
 g_class_rec.budget_currency_code    :=   p_budget_currency_code         ;
 g_class_rec.centre                  :=   p_centre                       ;
 g_class_rec.comments                :=   p_comments                     ;
 g_class_rec.course_end_date         :=   p_course_end_date              ;
  Hr_Utility.set_location(' two : ', 5);
 g_class_rec.course_end_time         :=   p_course_end_time              ;
  Hr_Utility.set_location(' three : ', 5);
 g_class_rec.course_start_date       :=   p_course_start_date            ;
  Hr_Utility.set_location(' Four : ', 5);
 g_class_rec.course_start_time       :=   p_course_start_time            ;
  Hr_Utility.set_location(' Five : ', 5);
 g_class_rec.duration                :=   p_duration                    ;
 g_class_rec.duration_units          :=   p_duration_units               ;
 g_class_rec.enrolment_end_date      :=   p_enrolment_end_date           ;
 g_class_rec.enrolment_start_date    :=   p_enrolment_start_date         ;
 g_class_rec.language_id             :=   p_language_id                  ;
 g_class_rec.user_status             :=   p_user_status                  ;
 g_class_rec.development_event_type  :=   p_development_event_type       ;
 g_class_rec.event_status            :=   p_event_status                 ;
  Hr_Utility.set_location(' Six : ', 5);
 g_class_rec.price_basis             :=   p_price_basis                  ;
 g_class_rec.currency_code           :=   p_currency_code                ;
 g_class_rec.maximum_attendees       :=   p_maximum_attendees            ;
 g_class_rec.maximum_internal_attendees:=   p_maximum_internal_attendees   ;
 g_class_rec.minimum_attendees       :=   p_minimum_attendees            ;
 g_class_rec.standard_price          :=   p_standard_price               ;
 g_class_rec.category_code           :=   p_category_code                ;
 g_class_rec.parent_event_id         :=   p_parent_event_id              ;
 g_class_rec.book_independent_flag   :=   p_book_independent_flag        ;
 g_class_rec.public_event_flag       :=   l_public_event_flag            ;
 g_class_rec.secure_event_flag       :=   p_secure_event_flag            ;
 g_class_rec.evt_information_category:=   p_evt_information_category     ;
 g_class_rec.evt_information1        :=   p_evt_information1             ;
 g_class_rec.evt_information2        :=   p_evt_information2             ;
 g_class_rec.evt_information3        :=   p_evt_information3             ;
 g_class_rec.evt_information4        :=   p_evt_information4             ;
 g_class_rec.evt_information5        :=   p_evt_information5             ;
 g_class_rec.evt_information6        :=   p_evt_information6             ;
 g_class_rec.evt_information7        :=   p_evt_information7             ;
 g_class_rec.evt_information8        :=   p_evt_information8             ;
 g_class_rec.evt_information9        :=   p_evt_information9             ;
 g_class_rec.evt_information10       :=   p_evt_information10            ;
 g_class_rec.evt_information11       :=   p_evt_information11            ;
 g_class_rec.evt_information12       :=   p_evt_information12          ;
 g_class_rec.evt_information13       :=   p_evt_information13           ;
 g_class_rec.evt_information14       :=   p_evt_information14           ;
 g_class_rec.evt_information15       :=   p_evt_information15					;
 g_class_rec.evt_information16       :=   p_evt_information16          ;
 g_class_rec.evt_information17       :=   p_evt_information17          ;
 g_class_rec.evt_information18       :=   p_evt_information18          ;
 g_class_rec.evt_information19       :=   p_evt_information19          ;
 g_class_rec.evt_information20       :=   p_evt_information20          ;
 g_class_rec.project_id              :=   p_project_id                 ;
 g_class_rec.owner_id                :=   p_owner_id                   ;
 g_class_rec.line_id	              :=  p_line_id	               ;
 g_class_rec.org_id	              :=  p_org_id	               ;
 g_class_rec.training_center_id      :=   p_training_center_id         ;
 g_class_rec.location_id	      :=  p_location_id	               ;
 g_class_rec.offering_id	      :=  p_offering_id		       ;
 g_class_rec.timezone	              :=  p_timezone	               ;
 g_class_rec.parent_offering_id      :=   p_parent_offering_id 	       ;
 g_class_rec.data_source             :=   p_data_source                ;

  select object_version_number into l_object_version_number from ota_events
    where event_id = l_event_id;

l_class_rec := Get_Record_Values(g_interface_code);
  ota_event_api.update_class
    (p_effective_date               => p_effective_date
    ,p_event_id                     => l_event_id
    ,p_vendor_id                    => l_class_rec.vendor_id
    ,p_activity_version_id          => l_class_rec.activity_version_id
    ,p_business_group_id            => l_class_rec.business_group_id
    ,p_organization_id              => l_class_rec.organization_id
    ,p_event_type                   => l_class_rec.event_type
    ,p_object_version_number        => l_object_version_number
    ,p_title                        => l_class_rec.title
    ,p_budget_cost                  => l_class_rec.budget_cost
    ,p_actual_cost                  => l_class_rec.actual_cost
    ,p_budget_currency_code         => l_class_rec.budget_currency_code
    ,p_centre                       => l_class_rec.centre
    ,p_comments                     => l_class_rec.comments
    ,p_course_end_date              => l_class_rec.course_end_date
    ,p_course_end_time              => g_course_end_time
    ,p_course_start_date            => l_class_rec.course_start_date
    ,p_course_start_time            => g_course_start_time
    ,p_duration                     => l_class_rec.duration
    ,p_duration_units               => l_class_rec.duration_units
    ,p_enrolment_end_date           => l_class_rec.enrolment_end_date
    ,p_enrolment_start_date         => l_class_rec.enrolment_start_date
    ,p_language_id                  => l_class_rec.language_id
    ,p_user_status                  => l_class_rec.user_status
    ,p_development_event_type       => l_class_rec.development_event_type
    ,p_event_status                 => l_class_rec.event_status
    ,p_price_basis                  => l_class_rec.price_basis
    ,p_currency_code                => l_class_rec.currency_code
    ,p_maximum_attendees            => l_class_rec.maximum_attendees
    ,p_maximum_internal_attendees   => l_class_rec.maximum_internal_attendees
    ,p_minimum_attendees            => l_class_rec.minimum_attendees
    ,p_standard_price               => l_class_rec.standard_price
    ,p_category_code                => l_class_rec.category_code
    ,p_parent_event_id              => l_class_rec.parent_event_id
    ,p_book_independent_flag        => l_class_rec.book_independent_flag
    ,p_public_event_flag            => l_class_rec.public_event_flag
    ,p_secure_event_flag            => l_class_rec.secure_event_flag
    ,p_evt_information_category     => l_class_rec.evt_information_category
    ,p_evt_information1             => l_class_rec.evt_information1
    ,p_evt_information2             => l_class_rec.evt_information2
    ,p_evt_information3             => l_class_rec.evt_information3
    ,p_evt_information4             => l_class_rec.evt_information4
    ,p_evt_information5             => l_class_rec.evt_information5
    ,p_evt_information6             => l_class_rec.evt_information6
    ,p_evt_information7             => l_class_rec.evt_information7
    ,p_evt_information8             => l_class_rec.evt_information8
    ,p_evt_information9             => l_class_rec.evt_information9
    ,p_evt_information10            => l_class_rec.evt_information10
    ,p_evt_information11            => l_class_rec.evt_information11
    ,p_evt_information12            => l_class_rec.evt_information12
    ,p_evt_information13            => l_class_rec.evt_information13
    ,p_evt_information14            => l_class_rec.evt_information14
    ,p_evt_information15            => l_class_rec.evt_information15
    ,p_evt_information16            => l_class_rec.evt_information16
    ,p_evt_information17            => l_class_rec.evt_information17
    ,p_evt_information18            => l_class_rec.evt_information18
    ,p_evt_information19            => l_class_rec.evt_information19
    ,p_evt_information20            => l_class_rec.evt_information20
    ,p_project_id                   => l_class_rec.project_id
    ,p_owner_id                     => l_class_rec.owner_id
    ,p_line_id                      => l_class_rec.line_id
    ,p_org_id                       => l_class_rec.org_id
    ,p_training_center_id           => l_class_rec.training_center_id
    ,p_location_id                  => l_class_rec.location_id
    ,p_offering_id                  => l_class_rec.offering_id
    ,p_timezone                     => l_class_rec.timezone
    ,p_parent_offering_id           => l_class_rec.parent_offering_id
    ,p_validate                     => l_validate
    ,p_data_source                  => l_class_rec.data_source
    );
 end if;

  Exception

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



end InsUpd_Class;

end pqp_riw_class_wrapper;

/

--------------------------------------------------------
--  DDL for Package Body PQP_RIW_OFFERING_WRAPPER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_RIW_OFFERING_WRAPPER" as
/* $Header: pqpriwofwr.pkb 120.0.12010000.7 2009/04/28 13:25:27 sravikum noship $ */

-- =============================================================================
-- ~ Package Body Global variables:
-- =============================================================================
g_package  varchar2(33) := 'pqp_riw_offering_wrapper.';
g_offering_rec                     ota_offerings_vl%rowtype;
g_interface_code              varchar2(150);
g_player_toolbar_flag					varchar2(9);
g_player_new_window_flag			varchar2(9);

-- =============================================================================
-- Default_Record_Values:
-- =============================================================================
function Default_Offering_Rec
         return ota_offerings_vl%rowtype is
  l_proc_name    constant varchar2(150) := g_package||'Default_Offering_Rec';
  l_offering_rec     ota_offerings_vl%rowtype;

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
  l_offering_rec.business_group_id          :=  hr_api.g_number;
  l_offering_rec.name                       :=  hr_api.g_varchar2   ;
  l_offering_rec.start_date                 :=  hr_api.g_date       ;
  l_offering_rec.activity_version_id        :=  hr_api.g_number     ;
  l_offering_rec.end_date                   :=  hr_api.g_date       ;
  l_offering_rec.owner_id                   :=  hr_api.g_number     ;
  l_offering_rec.delivery_mode_id           :=  hr_api.g_number     ;
  l_offering_rec.language_id                :=  hr_api.g_number     ;
  Hr_Utility.set_location('   after : l_offering_rec.language_id', 5);
  l_offering_rec.duration                   :=  hr_api.g_number     ;
  Hr_Utility.set_location('   after : l_offering_rec.duration', 5);
  l_offering_rec.duration_units             :=  hr_api.g_varchar2   ;
  Hr_Utility.set_location('   after : l_offering_rec.duration_units', 5);
  l_offering_rec.learning_object_id         :=  hr_api.g_number     ;
  Hr_Utility.set_location(' Before duration : ', 5);
--  l_offering_rec.player_toolbar_flag        :=  hr_api.g_varchar2   ;
  g_player_toolbar_flag												:=hr_api.g_varchar2;

  Hr_Utility.set_location('   after : l_offering_rec.player_toolbar_flag', 5);
  l_offering_rec.player_toolbar_bitset      :=  hr_api.g_number     ;
  Hr_Utility.set_location('   after : l_offering_rec.player_toolbar_bitset', 5);
--  l_offering_rec.player_new_window_flag     :=  hr_api.g_varchar2   ;

  g_player_new_window_flag 												:=hr_api.g_varchar2;
  Hr_Utility.set_location('   after :g_player_new_window_flag '||g_player_new_window_flag, 5);
  l_offering_rec.maximum_attendees          :=  hr_api.g_number     ;
  Hr_Utility.set_location('   after :l_offering_rec.maximum_attendees ', 5);
  l_offering_rec.maximum_internal_attendees :=  hr_api.g_number     ;
  Hr_Utility.set_location('   after :l_offering_rec.maximum_attendees ', 5);

  l_offering_rec.minimum_attendees          :=  hr_api.g_number     ;
  Hr_Utility.set_location('   after :l_offering_rec.maximum_attendees ', 5);

  l_offering_rec.actual_cost                :=  hr_api.g_number     ;

  Hr_Utility.set_location('   after :l_offering_rec.maximum_attendees ', 5);
  l_offering_rec.budget_cost                :=  hr_api.g_number     ;
  Hr_Utility.set_location('   after :l_offering_rec.maximum_attendees ', 5);
  l_offering_rec.budget_currency_code       :=  hr_api.g_varchar2   ;
  Hr_Utility.set_location('   after :l_offering_rec.maximum_attendees ', 5);
  l_offering_rec.price_basis                :=  hr_api.g_varchar2   ;
  l_offering_rec.currency_code              :=  hr_api.g_varchar2   ;
  l_offering_rec.standard_price             :=  hr_api.g_number     ;
  l_offering_rec.attribute_category         :=  hr_api.g_varchar2   ;
  l_offering_rec.attribute1                 :=  hr_api.g_varchar2   ;
  l_offering_rec.attribute2                 :=  hr_api.g_varchar2   ;
  l_offering_rec.attribute3                 :=  hr_api.g_varchar2   ;
  l_offering_rec.attribute4                 :=  hr_api.g_varchar2   ;
  l_offering_rec.attribute5                 :=  hr_api.g_varchar2   ;
  l_offering_rec.attribute6                 :=  hr_api.g_varchar2   ;
  l_offering_rec.attribute7                 :=  hr_api.g_varchar2   ;
  l_offering_rec.attribute8                 :=  hr_api.g_varchar2   ;
  l_offering_rec.attribute9                 :=  hr_api.g_varchar2   ;
  l_offering_rec.attribute10                :=  hr_api.g_varchar2   ;
  l_offering_rec.attribute11                :=  hr_api.g_varchar2   ;
  l_offering_rec.attribute12                :=  hr_api.g_varchar2   ;
  l_offering_rec.attribute13                :=  hr_api.g_varchar2   ;
  l_offering_rec.attribute14                :=  hr_api.g_varchar2   ;
  l_offering_rec.attribute15                :=  hr_api.g_varchar2   ;
  l_offering_rec.attribute16                :=  hr_api.g_varchar2   ;
  l_offering_rec.attribute17                :=  hr_api.g_varchar2   ;
  l_offering_rec.attribute18                :=  hr_api.g_varchar2   ;
  l_offering_rec.attribute19                :=  hr_api.g_varchar2   ;
  l_offering_rec.attribute20                :=  hr_api.g_varchar2   ;
  l_offering_rec.data_source                :=  hr_api.g_varchar2   ;
  l_offering_rec.vendor_id                  :=  hr_api.g_number     ;
  l_offering_rec.description		    :=  hr_api.g_varchar2   ;
  l_offering_rec.competency_update_level    :=  hr_api.g_varchar2  ;
  l_offering_rec.language_code              :=  hr_api.g_varchar2  ;

  Hr_Utility.set_location('Leaving: '||l_proc_name, 80);
  return l_offering_rec;
exception
  when others then
  Hr_Utility.set_location('Leaving: '||l_proc_name, 90);
  raise;

end Default_Offering_Rec;


-- =============================================================================
-- Get_Record_Values:
-- =============================================================================
function Get_Record_Values
        (p_interface_code in varchar2 default null)
         return ota_offerings_vl%rowtype is

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

  l_offering_rec            ota_offerings_vl%rowtype;
  col_name             varchar2(150);
  l_proc_name constant varchar2(150) := g_package||'Get_Record_Values';
begin

  Hr_Utility.set_location(' Entering: '||l_proc_name, 5);
 hr_utility.set_location('p_interface_code'||p_interface_code, 10);
  l_offering_rec := Default_Offering_Rec;
 hr_utility.set_location('p_interface_code'||p_interface_code, 20);
 hr_utility.set_location('g_interface_code'||g_interface_code, 5);


  for col_rec in bne_cols (g_interface_code)
  loop
 hr_utility.set_location(' in loop col_rec.interface_col_name'||col_rec.interface_col_name, 15);
   case col_rec.interface_col_name

    when 'p_business_group_id' then
          l_offering_rec.business_group_id := g_offering_rec.business_group_id;
    when 'p_name' then
          l_offering_rec.name := g_offering_rec.name;
    when 'p_start_date' then
          l_offering_rec.start_date := g_offering_rec.start_date;
    when 'p_activity_version_id' then
          l_offering_rec.activity_version_id := g_offering_rec.activity_version_id;
    when 'p_end_date' then
          l_offering_rec.end_date := g_offering_rec.end_date;
    when 'p_owner_id' then
          l_offering_rec.owner_id := g_offering_rec.owner_id;
    when 'p_delivery_mode_id' then
          l_offering_rec.delivery_mode_id := g_offering_rec.delivery_mode_id;
    when 'p_language_id' then
          l_offering_rec.language_id := g_offering_rec.language_id;
    when 'p_duration' then
          l_offering_rec.duration := g_offering_rec.duration;
    when 'p_duration_units' then
          l_offering_rec.duration_units := g_offering_rec.duration_units;
    when 'p_learning_object_id' then
          l_offering_rec.learning_object_id := g_offering_rec.learning_object_id;
    when 'p_player_toolbar_flag' then
          l_offering_rec.player_toolbar_flag := g_offering_rec.player_toolbar_flag;
					g_player_toolbar_flag 						 := g_offering_rec.player_toolbar_flag;
    when 'p_player_toolbar_bitset' then
          l_offering_rec.player_toolbar_bitset := g_offering_rec.player_toolbar_bitset;
    when 'p_player_exit_flag' then
          l_offering_rec.player_toolbar_bitset := g_offering_rec.player_toolbar_bitset;
    when 'p_player_previous_flag' then
          l_offering_rec.player_toolbar_bitset := g_offering_rec.player_toolbar_bitset;
    when 'p_player_outline_flag' then
          l_offering_rec.player_toolbar_bitset := g_offering_rec.player_toolbar_bitset;
    when 'p_player_next_flag' then
          l_offering_rec.player_toolbar_bitset := g_offering_rec.player_toolbar_bitset;

    when 'p_player_new_window_flag' then
          l_offering_rec.player_new_window_flag := g_offering_rec.player_new_window_flag;
					g_player_new_window_flag							:= g_offering_rec.player_new_window_flag;
    when 'p_maximum_attendees' then
          l_offering_rec.maximum_attendees := g_offering_rec.maximum_attendees;
    when 'p_maximum_internal_attendees' then
          l_offering_rec.maximum_internal_attendees := g_offering_rec.maximum_internal_attendees;
    when 'p_minimum_attendees' then
          l_offering_rec.minimum_attendees := g_offering_rec.minimum_attendees;
    when 'p_actual_cost' then
          l_offering_rec.actual_cost := g_offering_rec.actual_cost;
    when 'p_budget_cost' then
          l_offering_rec.budget_cost := g_offering_rec.budget_cost;
    when 'p_budget_currency_code' then
          l_offering_rec.budget_currency_code := g_offering_rec.budget_currency_code;
    when 'p_price_basis' then
          l_offering_rec.price_basis := g_offering_rec.price_basis;
    when 'p_currency_code' then
          l_offering_rec.currency_code := g_offering_rec.currency_code;
    when 'p_standard_price' then
          l_offering_rec.standard_price := g_offering_rec.standard_price;
    when 'p_vendor_id' then
          l_offering_rec.vendor_id := g_offering_rec.vendor_id;
    when 'p_description' then
          l_offering_rec.description := g_offering_rec.description;
    when 'p_competency_update_level' then
          l_offering_rec.competency_update_level := g_offering_rec.competency_update_level;
    when 'p_language_code' then
          l_offering_rec.language_code := g_offering_rec.language_code;
    -- DFF
    when 'p_attribute_category' then
          l_offering_rec.attribute_category := g_offering_rec.attribute_category;
          if l_offering_rec.attribute_category is not null then
          for col_rec1 in bne_cols_no_disp(g_interface_code) loop

             case col_rec1.interface_col_name
             when 'p_attribute1' then
                   l_offering_rec.attribute1 := g_offering_rec.attribute1;
             when 'p_attribute2' then
                   l_offering_rec.attribute2 := g_offering_rec.attribute2;
             when 'p_attribute3' then
                   l_offering_rec.attribute3 := g_offering_rec.attribute3;
             when 'p_attribute4' then
                   l_offering_rec.attribute4 := g_offering_rec.attribute4;
             when 'p_attribute5' then
                   l_offering_rec.attribute5 := g_offering_rec.attribute5;
             when 'p_attribute6' then
                   l_offering_rec.attribute6 := g_offering_rec.attribute6;
             when 'p_attribute7' then
                   l_offering_rec.attribute7 := g_offering_rec.attribute7;
             when 'p_attribute8' then
                   l_offering_rec.attribute8 := g_offering_rec.attribute8;
             when 'p_attribute9' then
                   l_offering_rec.attribute9 := g_offering_rec.attribute9;
             when 'p_attribute10' then
                   l_offering_rec.attribute10 := g_offering_rec.attribute10;
             when 'p_attribute11' then
                   l_offering_rec.attribute11 := g_offering_rec.attribute11;
             when 'p_attribute12' then
                   l_offering_rec.attribute12 := g_offering_rec.attribute12;
             when 'p_attribute13' then
                   l_offering_rec.attribute13 := g_offering_rec.attribute13;
             when 'p_attribute14' then
                   l_offering_rec.attribute14 := g_offering_rec.attribute14;
             when 'p_attribute15' then
                   l_offering_rec.attribute15 := g_offering_rec.attribute15;
             when 'p_attribute16' then
                   l_offering_rec.attribute16 := g_offering_rec.attribute16;
             when 'p_attribute17' then
                   l_offering_rec.attribute17 := g_offering_rec.attribute17;
             when 'p_attribute18' then
                   l_offering_rec.attribute18 := g_offering_rec.attribute18;
             when 'p_attribute19' then
                   l_offering_rec.attribute19 := g_offering_rec.attribute19;
             when 'p_attribute20' then
                   l_offering_rec.attribute20 := g_offering_rec.attribute20;
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
  return l_offering_rec;

end Get_Record_Values;

-- =============================================================================
-- InsUpd_Offering:
-- =============================================================================

PROCEDURE InsUpd_Offering
  (p_validate                     in     number    default hr_api.g_false_num
  ,p_effective_date               in     date
  ,p_business_group_id            in     number
  ,p_name                         in     varchar2
  ,p_start_date                   in     date
  ,p_activity_version_id          in     number    default null
  ,p_end_date                     in     date      default null
  ,p_owner_id                     in     number    default null
  ,p_delivery_mode_id             in     number    default null
  ,p_language_id                  in     number    default null
  ,p_duration                     in     number    default null
  ,p_duration_units               in     varchar2  default null
  ,p_learning_object_id           in     number    default null
  ,p_player_toolbar_flag          in     varchar2  default null
  ,p_player_exit_flag		  in     varchar2  default null
  ,p_player_next_flag		  in     varchar2  default null
  ,p_player_previous_flag	  in     varchar2  default null
  ,p_player_outline_flag	  in	 varchar2  default null
  ,p_player_new_window_flag       in     varchar2  default null
  ,p_maximum_attendees            in     number    default null
  ,p_maximum_internal_attendees   in     number    default null
  ,p_minimum_attendees            in     number    default null
  ,p_actual_cost                  in     number    default null
  ,p_budget_cost                  in     number    default null
  ,p_budget_currency_code         in     varchar2  default null
  ,p_price_basis                  in     varchar2  default null
  ,p_currency_code                in     varchar2  default null
  ,p_standard_price               in     number    default null
  ,p_attribute_category           in     varchar2  default null
  ,p_attribute1                   in     varchar2  default null
  ,p_attribute2                   in     varchar2  default null
  ,p_attribute3                   in     varchar2  default null
  ,p_attribute4                   in     varchar2  default null
  ,p_attribute5                   in     varchar2  default null
  ,p_attribute6                   in     varchar2  default null
  ,p_attribute7                   in     varchar2  default null
  ,p_attribute8                   in     varchar2  default null
  ,p_attribute9                   in     varchar2  default null
  ,p_attribute10                  in     varchar2  default null
  ,p_attribute11                  in     varchar2  default null
  ,p_attribute12                  in     varchar2  default null
  ,p_attribute13                  in     varchar2  default null
  ,p_attribute14                  in     varchar2  default null
  ,p_attribute15                  in     varchar2  default null
  ,p_attribute16                  in     varchar2  default null
  ,p_attribute17                  in     varchar2  default null
  ,p_attribute18                  in     varchar2  default null
  ,p_attribute19                  in     varchar2  default null
  ,p_attribute20                  in     varchar2  default null
  ,p_offering_id                  in     number    default null
  ,p_object_version_number        in     number
  ,p_return_status                   out nocopy varchar2
  ,p_data_source                  in     varchar2  default null
  ,p_vendor_id                    in     number  default null
  ,p_description                  in     varchar2  default null
  ,p_competency_update_level      in     varchar2  default null
  ,p_language_code                in     varchar2  default null
  ,P_CRT_UPD			  in 	 varchar2   default null
  ) is
  -- =============================================================================
  -- Variables for API Boolean parameters
  -- =============================================================================
  l_validate                      boolean;

  -- =============================================================================
  -- Other variables
  -- =============================================================================

  l_activity_version_id number;
  l_category_usage_id            number;
  l_player_toolbar_bitset	 number;
  l_offering_id                  number;
  l_player_exit_flag		 varchar2(72);
  l_player_next_flag		 varchar2(72);
  l_player_previous_flag	 varchar2(72);
  l_player_outline_flag	  	 varchar2(72);
  l_error_msg                    varchar2(4000);
  p_organization_id		 number;
  p_event_type			 varchar2(72);
  p_title			 varchar2(72);
  p_course_end_date		 date;
  p_course_start_date		 date;
  p_enrolment_end_date		 date;
  p_enrolment_start_date	 date;
  p_event_status		 varchar2(72);
  p_book_independent_flag	 varchar2(72);
  p_public_event_flag		 varchar2(72);
  p_secure_event_flag		 varchar2(72);
  p_timezone			 varchar2(72);
  l_title			 varchar2(72);
  l_event_id			 number;
  l_create_flag                  number(3) := 1;
  l_off_id                       number;
  l_obj_ver_num                  number;
  l_object_version_number        number;
  e_upl_not_allowed exception; -- when mode is 'View Only'
  e_crt_not_allowed exception; -- when mode is 'Update Only'
  g_upl_err_msg varchar2(100) := 'Upload NOT allowed.';
  g_crt_err_msg varchar2(100) := 'Creating NOT allowed.';
  l_offering_rec     ota_offerings_vl%rowtype;
  l_interface_code            varchar2(40);
  l_crt_upd                   varchar2(1);
  l_crt_upd_len               number;

-- =============================================================================
-- Default_Record_Values:
-- =============================================================================
l_proc                    varchar2(72) := g_package||'InsUpd_Offering';

begin
--hr_utility.trace_on(null, 'Offer_Trace');
hr_utility.set_location('Entering: '|| l_proc, 11);
  --
  -- Issue a savepoint
  --
  savepoint InsUpd_Offering;

  --
  -- Convert constant values to their corresponding boolean value
  --
  l_validate :=    hr_api.constant_to_boolean  (p_constant_value => p_validate);

  -- $ Finding the value for the  l_player_toolbar_bitset based on the input
  -- $ Flag values
  l_player_exit_flag		  :=1;
  l_player_previous_flag	  :=2;
  l_player_next_flag		  :=4;
  l_player_outline_flag	  	  :=1024;
  l_player_toolbar_bitset	  :=0;

  l_offering_id := p_offering_id;

hr_utility.set_location('The offering id is : '||l_offering_id, 90);

  if l_offering_id is not null then
       l_create_flag := 2;  --Update Offering
  else
       l_create_flag := 1;  --create Offering
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

  if p_player_exit_flag ='Y' then
	l_player_toolbar_bitset := l_player_toolbar_bitset + l_player_exit_flag;
  end if;

  if p_player_previous_flag ='Y' then
	l_player_toolbar_bitset := l_player_toolbar_bitset + l_player_previous_flag;
  end if;

  if p_player_next_flag ='Y' then
	l_player_toolbar_bitset := l_player_toolbar_bitset + l_player_next_flag;
  end if;

  if p_player_outline_flag ='Y' then
	l_player_toolbar_bitset := l_player_toolbar_bitset + l_player_outline_flag;
  end if;

  --
  -- Call API
  --
if l_create_flag = 1 then
ota_offering_api.create_offering
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_business_group_id            => p_business_group_id
    ,p_name                         => p_name
    ,p_start_date                   => p_start_date
    ,p_activity_version_id          => p_activity_version_id
    ,p_end_date                     => p_end_date
    ,p_owner_id                     => p_owner_id
    ,p_delivery_mode_id             => p_delivery_mode_id
    ,p_language_id                  => p_language_id
    ,p_duration                     => p_duration
    ,p_duration_units               => p_duration_units
    ,p_learning_object_id           => p_learning_object_id
    ,p_player_toolbar_flag          => p_player_toolbar_flag
    ,p_player_toolbar_bitset        => l_player_toolbar_bitset
    ,p_player_new_window_flag       => p_player_new_window_flag
    ,p_maximum_attendees            => p_maximum_attendees
    ,p_maximum_internal_attendees   => p_maximum_internal_attendees
    ,p_minimum_attendees            => p_minimum_attendees
    ,p_actual_cost                  => p_actual_cost
    ,p_budget_cost                  => p_budget_cost
    ,p_budget_currency_code         => p_budget_currency_code
    ,p_price_basis                  => p_price_basis
    ,p_currency_code                => p_currency_code
    ,p_standard_price               => p_standard_price
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
    ,p_offering_id                  => l_off_id
    ,p_object_version_number        => l_obj_ver_num
    ,p_data_source                  => p_data_source
    ,p_vendor_id                    => p_vendor_id
    ,p_description                  => p_description
    ,p_competency_update_level      => p_competency_update_level
    ,p_language_code                => p_language_code
    );

      -- $ Creating the Default Class for SELFPACED Offering (407)
      -- $ Setting the default values for the Default Class

	p_organization_id := p_business_group_id;
	p_event_type := 'SELFPACED';
	p_title := p_name;
	p_course_end_date := p_end_date;
	p_course_start_date := p_start_date;
	p_enrolment_end_date := p_end_date;
	p_enrolment_start_date := p_start_date;
	p_event_status := 'N';
	p_book_independent_flag := 'N';
	p_public_event_flag := 'N';
	p_secure_event_flag :='N';
	p_timezone:= 'America/Chicago';

     if p_delivery_mode_id = 407 then

	ota_event_api.create_class
	    (p_effective_date               => p_effective_date
	    ,p_event_id                     => l_event_id
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
	--    ,p_centre                       => p_centre
	--    ,p_comments                     => p_comments
	    ,p_course_end_date              => p_course_end_date
	--    ,p_course_end_time              => p_course_end_time
	    ,p_course_start_date            => p_course_start_date
	--    ,p_course_start_time            => p_course_start_time
	    ,p_duration                     => p_duration
	    ,p_duration_units               => p_duration_units
	    ,p_enrolment_end_date           => p_enrolment_end_date
	    ,p_enrolment_start_date         => p_enrolment_start_date
	    ,p_language_id                  => p_language_id
	--    ,p_user_status                  => p_user_status
	--    ,p	_development_event_type       => p_development_event_type
	    ,p_event_status                 => p_event_status
	    ,p_price_basis                  => p_price_basis
	    ,p_currency_code                => p_currency_code
	    ,p_maximum_attendees            => p_maximum_attendees
	    ,p_maximum_internal_attendees   => p_maximum_internal_attendees
	    ,p_minimum_attendees            => p_minimum_attendees
	    ,p_standard_price               => p_standard_price
	--    ,p_category_code                => p_category_code
	--    ,p_parent_event_id              => p_parent_event_id
	    ,p_book_independent_flag        => p_book_independent_flag
	    ,p_public_event_flag            => p_public_event_flag
	    ,p_secure_event_flag            => p_secure_event_flag
	--    ,p_project_id                   => p_project_id
	    ,p_owner_id                     => p_owner_id
	--    ,p_line_id                      => p_line_id
	--    ,p_org_id                       => p_org_id
	--    ,p_training_center_id           => p_training_center_id
	--    ,p_location_id                  => p_location_id
	--    ,p_offering_id                  => l_offering_id
	    ,p_timezone                     => p_timezone
	    ,p_parent_offering_id           => l_off_id
	    ,p_validate                     => l_validate
	    ,p_data_source                  => p_data_source
	    );


	 l_title := p_name || to_char(l_event_id);
	update ota_events set title = l_title where event_id = l_event_id;
	update ota_events_tl set title = l_title where event_id = l_event_id;

    end if;

  end if;

  if l_create_flag = 2 then

 g_interface_code := nvl(l_interface_code,'PQP_OLM_OFFERING_INTF');
 hr_utility.set_location('g_interface_code'||g_interface_code, 95);

 g_offering_rec.business_group_id         	:= p_business_group_id          ;
 g_offering_rec.name                      	:= p_name                       ;
 g_offering_rec.start_date                	:= p_start_date                 ;
 g_offering_rec.activity_version_id       	:= p_activity_version_id        ;
 g_offering_rec.end_date                  	:= p_end_date                   ;
 g_offering_rec.owner_id                  	:= p_owner_id                   ;
 g_offering_rec.delivery_mode_id          	:= p_delivery_mode_id           ;
 g_offering_rec.language_id               	:= p_language_id                ;
 g_offering_rec.duration                  	:= p_duration                   ;
 g_offering_rec.duration_units            	:= p_duration_units             ;
 g_offering_rec.learning_object_id        	:= p_learning_object_id         ;
 g_offering_rec.player_toolbar_flag       	:= p_player_toolbar_flag        ;
 g_offering_rec.player_toolbar_bitset     	:= l_player_toolbar_bitset      ;
 g_offering_rec.player_new_window_flag    	:= p_player_new_window_flag     ;
 g_offering_rec.maximum_attendees         	:= p_maximum_attendees          ;
 g_offering_rec.maximum_internal_attendees	:= p_maximum_internal_attendees ;
 g_offering_rec.minimum_attendees         	:= p_minimum_attendees          ;
 g_offering_rec.actual_cost               	:= p_actual_cost                ;
 g_offering_rec.budget_cost               	:= p_budget_cost                ;
 g_offering_rec.budget_currency_code      	:= p_budget_currency_code       ;
 g_offering_rec.price_basis               	:= p_price_basis                ;
 g_offering_rec.currency_code             	:= p_currency_code              ;
 g_offering_rec.standard_price            	:= p_standard_price             ;
 g_offering_rec.attribute_category        	:= p_attribute_category         ;
 g_offering_rec.attribute1                	:= p_attribute1                 ;
 g_offering_rec.attribute2                	:= p_attribute2                 ;
 g_offering_rec.attribute3                	:= p_attribute3                 ;
 g_offering_rec.attribute4                	:= p_attribute4                 ;
 g_offering_rec.attribute5                	:= p_attribute5                 ;
 g_offering_rec.attribute6                	:= p_attribute6                 ;
 g_offering_rec.attribute7                	:= p_attribute7                 ;
 g_offering_rec.attribute8                	:= p_attribute8                 ;
 g_offering_rec.attribute9                	:= p_attribute9                 ;
 g_offering_rec.attribute10               	:= p_attribute10                ;
 g_offering_rec.attribute11               	:= p_attribute11                ;
 g_offering_rec.attribute12               	:= p_attribute12                ;
 g_offering_rec.attribute13               	:= p_attribute13                ;
 g_offering_rec.attribute14               	:= p_attribute14                ;
 g_offering_rec.attribute15               	:= p_attribute15                ;
 g_offering_rec.attribute16               	:= p_attribute16                ;
 g_offering_rec.attribute17               	:= p_attribute17                ;
 g_offering_rec.attribute18               	:= p_attribute18                ;
 g_offering_rec.attribute19               	:= p_attribute19                ;
 g_offering_rec.attribute20               	:= p_attribute20                ;
 g_offering_rec.data_source               	:= p_data_source                ;
 g_offering_rec.vendor_id                 	:= p_vendor_id                  ;
 g_offering_rec.description		   	:= p_description		;
 g_offering_rec.competency_update_level   	:= p_competency_update_level   ;
 g_offering_rec.language_code             	:= p_language_code             ;

   select object_version_number into l_object_version_number
    from ota_offerings where
     offering_id = l_offering_id;

l_offering_rec := Get_Record_Values(g_interface_code);
   ota_offering_api.update_offering
    (p_validate                     => l_validate
    ,p_effective_date               => p_effective_date
    ,p_business_group_id            => l_offering_rec.business_group_id
    ,p_name                         => l_offering_rec.name
    ,p_start_date                   => l_offering_rec.start_date
    ,p_activity_version_id          => l_offering_rec.activity_version_id
    ,p_end_date                     => l_offering_rec.end_date
    ,p_owner_id                     => l_offering_rec.owner_id
    ,p_delivery_mode_id             => l_offering_rec.delivery_mode_id
    ,p_language_id                  => l_offering_rec.language_id
    ,p_duration                     => l_offering_rec.duration
    ,p_duration_units               => l_offering_rec.duration_units
    ,p_learning_object_id           => l_offering_rec.learning_object_id
    ,p_player_toolbar_flag          => g_player_toolbar_flag
    ,p_player_toolbar_bitset        => l_offering_rec.player_toolbar_bitset
    ,p_player_new_window_flag       => g_player_new_window_flag
    ,p_maximum_attendees            => l_offering_rec.maximum_attendees
    ,p_maximum_internal_attendees   => l_offering_rec.maximum_internal_attendees
    ,p_minimum_attendees            => l_offering_rec.minimum_attendees
    ,p_actual_cost                  => l_offering_rec.actual_cost
    ,p_budget_cost                  => l_offering_rec.budget_cost
    ,p_budget_currency_code         => l_offering_rec.budget_currency_code
    ,p_price_basis                  => l_offering_rec.price_basis
    ,p_currency_code                => l_offering_rec.currency_code
    ,p_standard_price               => l_offering_rec.standard_price
    ,p_attribute_category           => l_offering_rec.attribute_category
    ,p_attribute1                   => l_offering_rec.attribute1
    ,p_attribute2                   => l_offering_rec.attribute2
    ,p_attribute3                   => l_offering_rec.attribute3
    ,p_attribute4                   => l_offering_rec.attribute4
    ,p_attribute5                   => l_offering_rec.attribute5
    ,p_attribute6                   => l_offering_rec.attribute6
    ,p_attribute7                   => l_offering_rec.attribute7
    ,p_attribute8                   => l_offering_rec.attribute8
    ,p_attribute9                   => l_offering_rec.attribute9
    ,p_attribute10                  => l_offering_rec.attribute10
    ,p_attribute11                  => l_offering_rec.attribute11
    ,p_attribute12                  => l_offering_rec.attribute12
    ,p_attribute13                  => l_offering_rec.attribute13
    ,p_attribute14                  => l_offering_rec.attribute14
    ,p_attribute15                  => l_offering_rec.attribute15
    ,p_attribute16                  => l_offering_rec.attribute16
    ,p_attribute17                  => l_offering_rec.attribute17
    ,p_attribute18                  => l_offering_rec.attribute18
    ,p_attribute19                  => l_offering_rec.attribute19
    ,p_attribute20                  => l_offering_rec.attribute20
    ,p_offering_id                  => l_offering_id
    ,p_object_version_number        => l_object_version_number
    ,p_data_source                  => l_offering_rec.data_source
    ,p_vendor_id                    => l_offering_rec.vendor_id
    ,p_description                  => l_offering_rec.description
    ,p_competency_update_level      => l_offering_rec.competency_update_level
    ,p_language_code                => l_offering_rec.language_code
    );
  end if;

  hr_utility.set_location(' Leaving:' || l_proc,30);
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


end InsUpd_Offering;
end pqp_riw_offering_wrapper;

/

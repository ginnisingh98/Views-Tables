--------------------------------------------------------
--  DDL for Package Body OTA_TAV_API_BUSINESS_RULES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_TAV_API_BUSINESS_RULES" as
/* $Header: ottav02t.pkb 120.4 2005/08/19 13:12:44 estreacy noship $ */
--
--
-- Global package name
--
g_package		varchar2(33)	:= '  ota_tav_api.';
--
-- Global api dml status
--
g_api_dml		boolean;
--
--
--
------------------------------------------------------------------------------
-- |-------------------------<set_globals>-----------------------------------|
------------------------------------------------------------------------------
--Description:
-- Sets the global variablesstart date and end date
--
Procedure set_globals
  (
   start_date date
  ,end_date  date
  ) is
--
v_proc                   varchar2(72) := g_package||'set_globals';
--
Begin
--
hr_utility.set_location('Entering:'|| v_proc, 5);
--
--
 g_version_start_date := start_date;
 g_version_end_date := end_date;
--
hr_utility.set_location('Leaving:'|| v_proc, 10);
--
End set_globals;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< call_error_message >--------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   Passes the error information to the procedure set_message of package
--   hr_utility.
--
Procedure call_error_message
  (
   p_error_appl             varchar2
  ,p_error_txt              varchar2
  ) is
  --
  v_proc                  varchar2(72) := g_package||'call_error_message';
  --
Begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  -- ** TEMP ** Add error message with the following text.
  --
  fnd_message.set_name      ( p_error_appl     ,p_error_txt);
  fnd_message.raise_error;
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  --
End call_error_message;
--
-- ----------------------------------------------------------------------------
-- |------------------------< call_warning_message >--------------------------|
-- ----------------------------------------------------------------------------
--
-- Description:
--   Passes the error information to the procedure set_message of package
--   hr_utility.
--
Procedure call_warning_message
  (
   p_warning_txt              varchar2
  ) is
  --
  v_proc                  varchar2(72) := g_package||'call_warning_message';
  --
Begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  -- ** TEMP ** Add warning message with the following text.
  --
  -- fnd_message.set_name( 'OTA', OTA_TAV_<name>');
  fnd_message.set_name( 'OTA', p_warning_txt);
  fnd_message.raise_error;
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  --
End call_warning_message;
--
-- ----------------------------------------------------------------------------
-- |---------------------< check_currency  >----------------------------------|
-- ----------------------------------------------------------------------------
--
procedure check_currency (p_currency_code in varchar2) is
  --
  v_proc      varchar2(72) := g_package||'check_currency';
begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  ota_general.check_currency_is_valid
                   (p_currency_code);
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  --
  exception
    when app_exception.application_exception then
       if hr_multi_message.exception_add
               (p_associated_column1   => 'OTA_ACTIVITY_VERSIONS.CURRENCY_CODE'
               ) then
          hr_utility.set_location(' Leaving:'|| v_proc,70);
          raise;
       end if;
     hr_utility.set_location(' Leaving:'|| v_proc,80);
end check_currency;
--
-- ----------------------------------------------------------------------------
-- |---------------------< check_vendor    >----------------------------------|
-- ----------------------------------------------------------------------------
--
procedure check_vendor (p_vendor_id in number) is
  --
  v_proc      varchar2(72) := g_package||'check_vendor';
begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  ota_general.check_vendor_is_valid(p_vendor_id);
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  --
  exception
    when app_exception.application_exception then
       if hr_multi_message.exception_add
               (p_associated_column1   => 'OTA_ACTIVITY_VERSIONS.VENDOR_ID'
               ) then
          hr_utility.set_location(' Leaving:'|| v_proc,70);
          raise;
       end if;
     hr_utility.set_location(' Leaving:'|| v_proc,80);
end check_vendor;
--
-- ----------------------------------------------------------------------------
-- |---------------------< check_cost_vals >----------------------------------|
-- ----------------------------------------------------------------------------
--
procedure check_cost_vals
              (p_budget_currency_code in varchar2
              ,p_budget_cost in number
              ,p_actual_cost in number) is
  --
  v_proc      varchar2(72) := g_package||'check_cost_vals';
begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  if (p_budget_cost is not null or p_actual_cost is not null) and
      p_budget_currency_code is null then
      --
      fnd_message.set_name('OTA','OTA_13394_TAV_COST_ATTR');
      fnd_message.raise_error;
      --
  end if;
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  --
  exception
    when app_exception.application_exception then
       if hr_multi_message.exception_add
               (p_associated_column1   => 'OTA_ACTIVITY_VERSIONS.CURRENCY_CODE'
               ,p_associated_column2   => 'OTA_ACTIVITY_VERSIONS.BUDGET_COST'
               ,p_associated_column3   => 'OTA_ACTIVITY_VERSIONS.ACTUAL_COST'
               ) then
          hr_utility.set_location(' Leaving:'|| v_proc,70);
          raise;
       end if;
     hr_utility.set_location(' Leaving:'|| v_proc,80);
end check_cost_vals;
--
-- ----------------------------------------------------------------------------
-- |---------------------< check_professional_credit_vals >-------------------|
-- ----------------------------------------------------------------------------
--
procedure check_professional_credit_vals
              (p_professional_credit_type in varchar2
              ,p_professional_credits     in number) is
  --
  v_proc      varchar2(72) := g_package||'check_professional_credit_vals';
begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  if (p_professional_credit_type is null and
      p_professional_credits is not null)
  or (p_professional_credit_type is not null and
      p_professional_credits is null) then
      --
      fnd_message.set_name('OTA','OTA_13422_TAV_PROF_CREDIT_VALS');
      fnd_message.raise_error;
      --
  end if;
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  --
  exception
      when app_exception.application_exception then
         if hr_multi_message.exception_add
                 (p_associated_column1   => 'OTA_ACTIVITY_VERSIONS.PROFESSIONAL_CREDITS'
                 ,p_associated_column2   => 'OTA_ACTIVITY_VERSIONS.PROFESSIONAL_CREDIT_TYPE'
                 ) then
            hr_utility.set_location(' Leaving:'|| v_proc,70);
            raise;
         end if;
     hr_utility.set_location(' Leaving:'|| v_proc,80);
end check_professional_credit_vals;
--
-- ----------------------------------------------------------------------------
-- |---------------------< check_professional_credit_type >-------------------|
-- ----------------------------------------------------------------------------
--
procedure check_professional_credit_type
              (p_professional_credit_type in varchar2) is
  --
  v_proc      varchar2(72) := g_package||'check_professional_credit_type';
begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
    ota_general.check_domain_value
        ( 'PROFESSIONAL_CREDIT_TYPE', p_professional_credit_type);
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  --
  exception
        when app_exception.application_exception then
           if hr_multi_message.exception_add
                   (p_associated_column2   => 'OTA_ACTIVITY_VERSIONS.PROFESSIONAL_CREDIT_TYPE'
                   ) then
              hr_utility.set_location(' Leaving:'|| v_proc,70);
              raise;
           end if;
     hr_utility.set_location(' Leaving:'|| v_proc,80);
end check_professional_credit_type;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< check_min_max_values >-------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   The minimum attendees must be less then or equal to the maximum attendees.
--
Procedure check_min_max_values
  (
   p_min  in  number
  ,p_max  in  number
  ) Is
  --
  v_proc 	varchar2(72) := g_package||'check_min_max_values';
  --
Begin
  --
  hr_utility.set_location('Entering:'||v_proc, 5);
  --
  If p_min is not null   AND   p_max is not null   then
    --
    If p_min > p_max  Then
      --
      -- ** TEMP ** Add error message with the following text.
      --
      call_error_message( p_error_appl           =>   'OTA'
                        , p_error_txt          =>  'OTA_13298_GEN_MINMAX_ORDER'
                        );
      --
    End If;
    --
  End If;
  --
  hr_utility.set_location(' Leaving:'||v_proc, 10);
  --
End check_min_max_values;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< check_unique_name >---------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   Validates the unique key.
--
Procedure check_unique_name
  (
   p_business_group_id in number
  ,p_activity_id       in number
  ,p_version_name      in varchar2
  ,p_activity_version_id in number
  ) is
  --
  v_exists                varchar2(1);
  v_proc                  varchar2(72) := g_package||'check_unique_name';
  --
  v_business_group_id number;
  --
  cursor get_activity is
  select business_group_id
  from   ota_activity_definitions tad
  where  activity_id = p_activity_id;
  --
  cursor sel_unique_key is
select 'Y'
from ota_activity_versions_vl  tav
,    ota_activity_definitions tad
where tav.version_name = p_version_name
and   tav.activity_id  = tad.activity_id
and (p_activity_version_id is null or
    (p_activity_version_id is not null and
     tav.activity_version_id <> p_activity_version_id))
and   tad.business_group_id+0 = v_business_group_id;

  --
Begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  if p_business_group_id is null then
     open get_activity;
     fetch get_activity into v_business_group_id;
     close get_activity;
  else
     v_business_group_id := p_business_group_id;
  end if;
  --
  Open  sel_unique_key;
  fetch sel_unique_key into v_exists;
  --
  if sel_unique_key%found then
    --
    close sel_unique_key;
    --
    -- ** TEMP ** Add error message with the following text.
    --
    call_error_message( p_error_appl           =>   'OTA'
                      , p_error_txt          =>  'OTA_13301_TAV_DUPLICATE'
                      );
    --
  end if;
  --
  close sel_unique_key;
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  --
End check_unique_name;
--
-- ----------------------------------------------------------------------------
-- |---------------------< check_superseding_version >------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--    An activity version may not be superseded by a version whose end_date
--    is less then or equal to its own. The superseding activity version must
--    have an end date greater than the end date of the activity it supersedes.
--
Procedure check_superseding_version
  (
   p_sup_act_vers_id in  number
  ,p_end_date        in  date
  ) is
  --
  v_sup_end_date         date;
  v_proc                 varchar2(72) := g_package||'check_superseding_version';
  --
  cursor sel_version is
    select end_date
      from ota_activity_versions    tav
     where tav.activity_version_id  =  p_sup_act_vers_id;
--
Begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  If p_sup_act_vers_id is not null  Then
    --
    Open  sel_version;
    Fetch sel_version into v_sup_end_date;
    --
    If sel_version%notfound then
      --
      Close sel_version;
      --
      -- ** TEMP ** Add error message with the following text.
      --
      call_error_message( p_error_appl           =>   'OTA'
                        , p_error_txt          =>  'OTA_13293_TAV_NO_SUP'
                        );
      --
    Elsif nvl( v_sup_end_date, hr_api.g_eot)
       < nvl(  p_end_date, hr_general.end_of_time) Then
      --
      Close sel_version;
      --
      -- ** TEMP ** Add error message with the following text.
      --
      call_error_message( p_error_appl           =>   'OTA'
                        , p_error_txt          =>  'OTA_13302_TAV_SUP_DATE'
                        );
      --
    End if;
    --
    Close sel_version;
    --
  End if;
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  --
End check_superseding_version;
--
-- ---------------------------------------------------------------------------
-- |-------------------------< find_overlapping_versions >-------------------|
-- ---------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   Checks to see if an Activity has overlapping versions. If a version has a
--   start date between another version's start date and end date then
--   overlapping versions exist.
--
Procedure find_overlapping_versions
  (
    p_activity_id  in  number
  ) is
  --
  overlapping_vers        number;
  v_proc                  varchar2(72) := g_package||'find_overlapping_versions';
  --
  cursor find_overlapping_vers is
    select 1
      from ota_activity_versions  tav1
     where tav1.activity_id = p_activity_id
     and exists
         ( select 1
             from ota_activity_versions tav2
            where tav2.activity_id = p_activity_id
            and tav1.activity_version_id <> tav2.activity_version_id
            and tav2.start_date between
                tav1.start_date and nvl(tav1.end_date, hr_general.end_of_time)
         );

Begin
--
 hr_utility.set_location('Entering:'|| v_proc, 5);
--
Open find_overlapping_vers;
Fetch find_overlapping_vers into overlapping_vers;
--
If find_overlapping_vers%found then
 --
 Close find_overlapping_vers;
 --
 -- ** TEMP ** Add error message with the following text.
 --
 call_error_message ( p_error_appl       => 'OTA'
                    , p_error_txt        => 'OTA_13469_TAV_OVERLAPS '
                    );
 --
End if;
Close find_overlapping_vers;
--
 hr_utility.set_location('Leaving:'|| v_proc, 10);
--
End find_overlapping_versions;
--
-- ---------------------------------------------------------------------------
-- |--------------------------< check_user_status >---------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   The user status must be in the domain 'Activity User Status'.
--
Procedure check_user_status
  (
   p_user_status  in  varchar2
  ) is
  --
  v_proc                  varchar2(72) := g_package||'check_user_status';
  --
Begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  If p_user_status is not null  Then
    --
    ota_general.check_domain_value( 'ACTIVITY_USER_STATUS', p_user_status);
    --
  End if;
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  --
End check_user_status;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< check_success_criteria >-----------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   The success criteria must be in the domain 'Activity Success Criteria'.
--
Procedure check_success_criteria
  (
   p_succ_criteria  in  varchar2
  ) is
  --
  v_proc                  varchar2(72) := g_package||'check_success_criteria';
  --
Begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  IF p_succ_criteria is not null  Then
    --
    ota_general.check_domain_value('ACTIVITY_SUCCESS_CRITERIA',p_succ_criteria);
    --
  End if;
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  --
End check_success_criteria;
--
-- ----------------------------------------------------------------------------
-- |----------------------< get_activity_version_id >-------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   Return the surrogate key from a passed parameter
--
Function get_activity_version_id
  (
   p_activity_id      in     number
  ,p_version_name     in     varchar2
  )
   Return number is
  --
  v_activity_version_id   ota_activity_versions.activity_version_id%TYPE ;
  v_proc                  varchar2(72) := g_package||'get_activity_version_id';
  --
  cursor sel_version_id is
    select activity_version_id
      from ota_activity_versions_vl   tav
     where tav.activity_id    =    p_activity_id
       and tav.version_name   =    p_version_name;

  --
Begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  If p_activity_id is not null   AND   p_version_name is not null  Then
    --
    Open  sel_version_id;
    fetch sel_version_id into v_activity_version_id;
    --
    If sel_version_id%notfound then
      --
      close sel_version_id;
      --
      -- ** TEMP ** Add error message with the following text.
      --
      call_error_message( p_error_appl           =>   'OTA'
                        , p_error_txt          =>  'OTA_13303_TAV_NOT_EXISTS'
                        );
      --
    End if;
    --
    close sel_version_id;
    --
    return( v_activity_version_id);
    --
  Else
    --
    -- ** TEMP ** Add error message with the following text.
    --
    call_error_message( p_error_appl           =>   'OTA'
                      , p_error_txt          =>  'OTA_13303_TAV_NOT_EXISTS'
                      );
    --
  End if;
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  --
End get_activity_version_id;
--
-- ----------------------------------------------------------------------------
-- |----------------------< get_activity_version_name >-----------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   Return the activity version name.
--
Function get_activity_version_name
  (
   p_activity_version_id   in   number
  ) Return varchar2 is
  --
  v_version_name         ota_activity_versions.version_name%TYPE;
  v_proc                 varchar2(72) := g_package||'get_activity_version_name';
  --
  cursor sel_vers_name is
    select version_name
      from ota_activity_versions_tl     tav
     where tav.activity_version_id   = p_activity_version_id
        and tav.language = USERENV('LANG');
  --
Begin
  --
  If p_activity_version_id is not null  Then
    --
    Open  sel_vers_name;
    fetch sel_vers_name into v_version_name;
    --
    If sel_vers_name%notfound then
      --
      v_version_name := null;
      --
    End if;
    --
    close sel_vers_name;
    --
    Return( v_version_name);
    --
  End if;
  --
  Return( null);
  --
End get_activity_version_name;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< check_start_end_dates >-----------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   Validates the startdate and enddate.
--   Startdate must be less than, or equal to, enddate.
--
Procedure check_start_end_dates
  (
   p_start_date     in     date
  ,p_end_date       in     date
  ) is
  --
  v_proc                  varchar2(72) := g_package||'check_start_end_dates';
  --
Begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  ota_general.check_start_end_dates( p_start_date, p_end_date);
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  --
End check_start_end_dates;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< check_dates_update_rud >-----------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   Validates the startdate and enddate.
--   Update of start and end dates must not invalidate valid resoruce usages
--   for this activity version.
--
Procedure check_dates_update_rud
  (
   p_activity_version_id   in    number
  ,p_start_date            in    date
  ,p_end_date              in    date
  ,p_old_start_date        in    date
  ,p_old_end_date          in    date
  ) is
  --
  v_start_date            date;
  v_end_date              date;
  v_proc                  varchar2(72) := g_package||'check_dates_update_rud';
  --
  cursor sel_check_dates is
    select start_date
         , end_date
      from ota_resource_usages       rud
     where rud.activity_version_id   = p_activity_version_id;
  --
Begin
  if hr_multi_message.no_error_message
      (p_check_message_name1 => 'OTA_13312_GEN_DATE_ORDER'
  ) then
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  Open  sel_check_dates;
  Fetch sel_check_dates into v_start_date
                           , v_end_date;
  --
  Loop
    --
    Exit When sel_check_dates%notfound OR sel_check_dates%notfound is null;
    --
    -- If the resource usage end/start date has not changed then
    -- set it's value to the activity version end/start date.
    --
    If not ota_general.value_changed(p_old_end_date,v_end_date) Then
      --
      v_end_date:=p_end_date;
      --
    End if;
    --
    If not ota_general.value_changed(p_old_start_date,v_start_date) Then
      --
      v_start_date:=p_start_date;
      --
    End if;
    --
    If ota_general.check_par_child_dates_fun( p_start_date
                                    , p_end_date
                                    , v_start_date
                                    , v_end_date ) then
      --
      call_error_message( p_error_appl       =>  'OTA'
                      , p_error_txt          =>  'OTA_13560_TAV_RUD_DATES'
                      );
      --
    End if;
    --
    Fetch sel_check_dates into v_start_date
                             , v_end_date;
  End loop;
  --
  Close sel_check_dates;
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  --
  end if;
  exception
      when app_exception.application_exception then
         if hr_multi_message.exception_add
                 (p_associated_column1   => 'OTA_ACTIVITY_VERSIONS.START_DATE'
                 ,p_associated_column2   => 'OTA_ACTIVITY_VERSIONS.END_DATE'
                 ) then
            hr_utility.set_location(' Leaving:'|| v_proc,70);
            raise;
         end if;
     hr_utility.set_location(' Leaving:'|| v_proc,80);
End check_dates_update_rud;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< check_dates_update_ple >-----------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   Validates the startdate and enddate.
--   Update of start and end dates must not invalidate price list entry
--   for this activity version.
--
Procedure check_dates_update_ple
  (
   p_activity_version_id   in    number
  ,p_start_date            in    date
  ,p_end_date              in    date
  ) is
  --
  v_start_date            date;
  v_end_date              date;
  v_proc                  varchar2(72) := g_package||'check_dates_update_ple';
  --
  cursor sel_check_dates is
    select start_date
         , end_date
      from ota_price_list_entries    ple
     where ple.activity_version_id   = p_activity_version_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  Open  sel_check_dates;
  Fetch sel_check_dates into v_start_date
                           , v_end_date;
  --
  Loop
    --
    Exit When sel_check_dates%notfound OR sel_check_dates%notfound is null;
    --
    If ota_general.check_par_child_dates_fun( p_start_date
                                     , p_end_date
                                     , v_start_date
                                     , v_end_date ) then
      --
      call_error_message( p_error_appl       =>  'OTA'
                      , p_error_txt          =>  'OTA_13561_TAV_PLE_DATES'
                      );
      --
    End if;
    --
    Fetch sel_check_dates into v_start_date
                             , v_end_date;
  End loop;
  --
  Close sel_check_dates;
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  --
End check_dates_update_ple;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< check_dates_update_tbd >-----------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   Validates the startdate and enddate.
--   Update of start and end dates must not invalidate booking deals
--   for this activity version.
--
Procedure check_dates_update_tbd
  (
   p_activity_version_id   in    number
  ,p_start_date            in    date
  ,p_end_date              in    date
  ) is
  --
  v_start_date            date;
  v_end_date              date;
  v_proc                  varchar2(72) := g_package||'check_dates_update_tbd';
  --
  cursor sel_check_dates is
    select start_date
         , end_date
      from ota_booking_deals         tbd
     where tbd.activity_version_id   = p_activity_version_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  Open  sel_check_dates;
  Fetch sel_check_dates into v_start_date
                           , v_end_date;
  --
  Loop
    --
    Exit When sel_check_dates%notfound OR sel_check_dates%notfound is null;
    --
    If ota_general.check_par_child_dates_fun( p_start_date
                                     , p_end_date
                                     , v_start_date
                                     , v_end_date ) then
      --
      call_error_message( p_error_appl       =>  'OTA'
                      , p_error_txt          =>  'OTA_13562_TAV_TBD_DATES'
                      );
      --
    End if;
    --
    Fetch sel_check_dates into v_start_date
                             , v_end_date;
  End loop;
  --
  Close sel_check_dates;
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  --
End check_dates_update_tbd;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< check_dates_update_evt >-----------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   Validates the startdate and enddate.
--   Update of start and end dates must not invalidate events
--   for this activity version.
--   This requires a check to ensure that the activity version dates do not
--   invalidate the Event Booking DAtes or the Event Course Dates if either
--   have been entered.
--
Procedure check_dates_update_evt
  (
   p_activity_version_id   in    number
  ,p_start_date            in    date
  ,p_end_date              in    date
  ) is
  --
  v_start_date            date;
  v_end_date              date;
  v_proc                  varchar2(72) := g_package||'check_dates_update_evt';
  l_obj_off varchar2(30) := ota_utility.Get_lookup_meaning('OTA_CATALOG_OBJECT_TYPE','O',810);
  l_obj_act varchar2(30) := ota_utility.Get_lookup_meaning('OTA_CATALOG_OBJECT_TYPE','H',810);

  --
  cursor sel_check_dates is
    select start_date
         , end_date
      from ota_offerings off -- bug 3534657
     where off.activity_version_id   = p_activity_version_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  Open  sel_check_dates;
  Fetch sel_check_dates into v_start_date
                           , v_end_date;
  --
  Loop
    --
    Exit When sel_check_dates%notfound OR sel_check_dates%notfound is null;
    --
    -- Assignment if course_start_date or course_end_date is null
    --
    If v_start_date is null  Then
      --
      v_start_date   :=  p_start_date;
      --
    End if;
    --
    If v_end_date is null  Then
      --
      v_end_date   :=  hr_api.g_eot;
      --
    End if;
    --
    If ota_general.check_par_child_dates_fun( p_start_date
                                     , p_end_date
                                     , v_start_date
                                     , v_end_date ) then
      --
      fnd_message.set_name      ( 'OTA','OTA_443166_OBJ_CHILD_DATE');
      fnd_message.set_token('OBJECT_NAME', l_obj_act );
      fnd_message.set_token('CHILD_OBJECT', l_obj_off);
      fnd_message.raise_error;
/*
      call_error_message( p_error_appl       =>  'OTA'
                      , p_error_txt          =>  'OTA_13559_TAV_EVT_DATES'
                      );
*/
      --
    End if;
    --
    Fetch sel_check_dates into v_start_date
                             , v_end_date;
  End loop;
  --
  Close sel_check_dates;
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  --
End check_dates_update_evt;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< check_category_dates >------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   Validates the startdate and enddate with respect to category dates.
--
Procedure check_category_dates
  (
   p_activity_version_id    in    number
  ,p_start_date             in    date
  ,p_end_date               in    date
  ) is
  --
  -- Declare cursors and local variables
  --
  -- Cursor to get value if parent category is already exits in child hierarchy of base category

  CURSOR cur_cat_start_end_date is
    select
      ctu.start_date_active,
      nvl(ctu.end_date_active, hr_api.g_eot)
    from
      ota_category_usages ctu,
      ota_act_cat_inclusions aci
    where
      ctu.category_usage_id = aci.category_usage_id
      and aci.activity_version_id = p_activity_version_id
      and ctu.type='C'
      and aci.primary_flag='Y';
  --
  -- Variables for API Boolean parameters
  l_proc                 varchar2(72) := g_package ||'check_category_dates';
  l_cat_start_date        date;
  l_cat_end_date          date;

Begin
  hr_utility.set_location(' Entering:' || l_proc,10);
  --
  IF hr_multi_message.no_exclusive_error
          (p_check_column1        => 'OTA_ACTIVITY_VERSIONS.START_DATE'
          ,p_check_column2        => 'OTA_ACTIVITY_VERSIONS.END_DATE'
          ,p_associated_column1   => 'OTA_ACTIVITY_VERSIONS.START_DATE'
          ,p_associated_column2   => 'OTA_ACTIVITY_VERSIONS.END_DATE'
          ) THEN
     --
     OPEN cur_cat_start_end_date;
     FETCH cur_cat_start_end_date into l_cat_start_date, l_cat_end_date;

     IF cur_cat_start_end_date%FOUND THEN
        CLOSE cur_cat_start_end_date;
        IF ( l_cat_start_date > p_start_date
             or l_cat_end_date < nvl(p_end_date, hr_api.g_eot)
           ) THEN
          --
          fnd_message.set_name      ( 'OTA','OTA_13062_ACT_OUT_OF_CAT_DATES');
	  fnd_message.raise_error;
          --
        End IF;
     ELSE
        CLOSE cur_cat_start_end_date;
     End IF;
  End IF;
  --
  hr_utility.set_location(' Leaving:' || l_proc,10);
Exception
  when app_exception.application_exception then
    IF hr_multi_message.exception_add
                 (p_associated_column1   => 'OTA_ACTIVITY_VERSIONS.START_DATE'
                 ,p_associated_column2   => 'OTA_ACTIVITY_VERSIONS.END_DATE'
                 ) THEN
       hr_utility.set_location(' Leaving:'|| l_proc,20);
       raise;
    END IF;

    hr_utility.set_location(' Leaving:'|| l_proc,30);
  --
End check_category_dates;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< check_if_evt_exists >--------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   Delete Validation.
--   This activity version may not be deleted if child rows in
--   ota_events exist.
--
Procedure check_if_evt_exists
  (
   p_activity_version_id  in  number
  ) is
  --
  v_exists                varchar2(1);
  v_proc                  varchar2(72) := g_package||'check_if_evt_exists';
  --
  cursor sel_evt_exists is
    select 'Y'
      from ota_events              evt
     where evt.activity_version_id = p_activity_version_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  Open  sel_evt_exists;
  fetch sel_evt_exists into v_exists;
  --
  if sel_evt_exists%found then
    --
    close sel_evt_exists;
    --
    -- ** TEMP ** Add error message with the following text.
    --
    call_error_message( p_error_appl           =>   'OTA'
                      , p_error_txt          =>  'OTA_13304_TAV_DEL_EVT_EXISTS'
                      );
    --
  end if;
  --
  close sel_evt_exists;
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  --
End check_if_evt_exists;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< check_if_off_exists >--------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   Delete Validation.
--   This activity version may not be deleted if child rows in
--   ota_offerings exist.
--
Procedure check_if_off_exists
  (
   p_activity_version_id  in  number
  ) is
  --
  v_exists                varchar2(1);
  v_proc                  varchar2(72) := g_package||'check_if_off_exists';
  --
  cursor sel_off_exists is
    select 'Y'
      from ota_offerings             off
     where off.activity_version_id = p_activity_version_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  Open  sel_off_exists;
  fetch sel_off_exists into v_exists;
  --
  if sel_off_exists%found then
    --
    close sel_off_exists;
    --
    -- ** TEMP ** Add error message with the following text.
    --
    call_error_message( p_error_appl           =>   'OTA'
                      , p_error_txt          =>  'OTA_443400_TAV_DEL_OFF_EXISTS'
                      );
    --
  end if;
  --
  close sel_off_exists;
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  --
End check_if_off_exists;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< check_if_tpm_exists >--------------------------|
-- ----------------------------------------------------------------------------
-- PUBLIC
-- Description:
--   Delete Validation.
--   This activity version may not be deleted if child rows in
--   ota_training_plan_members exist.
--
Procedure check_if_tpm_exists
  (
   p_activity_version_id  in  number
  ) is
  --
  v_proc                  varchar2(72) := g_package||'check_if_tpm_exists';
  --
  -- dynamic sql statment to check if the activity version is referenced
  -- in training plan members
  --
  Cursor c_get_tpm_rows is
    Select 'Y'
    from OTA_TRAINING_PLAN_MEMBERS
    where activity_version_id = p_activity_version_id;
  --
  l_dyn_curs   integer;
  l_dyn_rows   integer;
  l_dummy      varchar2(1);
--
Begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  -- Check if the activity version is referenced in training plan members table
  open c_get_tpm_rows;
  fetch c_get_tpm_rows into l_dummy;
  if c_get_tpm_rows%found then
    close c_get_tpm_rows;
    call_error_message( p_error_appl         =>  'OTA'
                      , p_error_txt          =>  'OTA_13820_TAV_NO_DEL_TPM_EXIST');
  else
    close c_get_tpm_rows;
  end if;
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  --
End check_if_tpm_exists;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< check_if_tbd_exists >--------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   Delete Validation.
--   This activity version may not be deleted if child rows in
--   ota_booking_deals exist.
--
Procedure check_if_tbd_exists
  (
   p_activity_version_id  in  number
  ) is
  --
  v_exists                varchar2(1);
  v_proc                  varchar2(72) := g_package||'check_if_tbd_exists';
  --
  cursor sel_tbd_exists is
    select 'Y'
      from ota_booking_deals         tbd
     where tbd.activity_version_id = p_activity_version_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  Open  sel_tbd_exists;
  fetch sel_tbd_exists into v_exists;
  --
  if sel_tbd_exists%found then
    --
    close sel_tbd_exists;
    --
    -- ** TEMP ** Add error message with the following text.
    --
    call_error_message( p_error_appl           =>   'OTA'
                      , p_error_txt          =>  'OTA_13305_TAV_DEL_TBD_EXISTS'
                      );
    --
  end if;
  --
  close sel_tbd_exists;
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  --
End check_if_tbd_exists;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< check_if_ple_exists >--------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   Delete Validation.
--   This activity version may not be deleted if child rows in
--   ota_price_lists_entries exist.
--
Procedure check_if_ple_exists
  (
   p_activity_version_id  in  number
  ) is
  --
  v_exists                varchar2(1);
  v_proc                  varchar2(72) := g_package||'check_if_ple_exists';
  --
  cursor sel_ple_exists is
    select 'Y'
      from ota_price_list_entries  ple
     where ple.activity_version_id = p_activity_version_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  Open  sel_ple_exists;
  fetch sel_ple_exists into v_exists;
  --
  if sel_ple_exists%found then
    --
    close sel_ple_exists;
    --
    -- ** TEMP ** Add error message with the following text.
    --
    call_error_message( p_error_appl           =>   'OTA'
                      , p_error_txt          =>  'OTA_13306_TAV_DEL_PLE_EXISTS'
                      );
    --
  end if;
  --
  close sel_ple_exists;
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  --
End check_if_ple_exists;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< check_if_comp_exists >--------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   Delete Validation.
--   This activity version may not be deleted if child rows in
--   per_competence_elements exist.
--
Procedure check_if_comp_exists
  (
   p_activity_version_id  in  number
  ) is
  --
  v_exists                varchar2(1);
  v_proc                  varchar2(72) := g_package||'check_if_comp_exists';
  --
  cursor sel_comp_exists is
    select 'Y'
      from per_competence_elements  pce
     where pce.activity_version_id = p_activity_version_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  Open  sel_comp_exists;
  fetch sel_comp_exists into v_exists;
  --
  if sel_comp_exists%found then
    --
    close sel_comp_exists;
    --
    -- ** TEMP ** Add error message with the following text.
    --
    call_error_message( p_error_appl           =>   'OTA'
                      , p_error_txt          =>  'OTA_443398_TAV_DEL_COMP_EXISTS'
                      );
    --
  end if;
  --
  close sel_comp_exists;
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  --
End check_if_comp_exists;
--

--
-- ----------------------------------------------------------------------------
-- |-------------------------< check_if_lpm_exists >--------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   Delete Validation.
--   This activity version may not be deleted if child rows in
--   ota_learning_path_members exist.
--
Procedure check_if_lpm_exists
  (
   p_activity_version_id  in  number
  ) is
  --
  v_exists                varchar2(1);
  v_proc                  varchar2(72) := g_package||'check_if_lpm_exists';
  --
  cursor sel_lpm_exists is
    select 'Y'
      from ota_learning_path_members  lpm
     where lpm.activity_version_id = p_activity_version_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  Open  sel_lpm_exists;
  fetch sel_lpm_exists into v_exists;
  --
  if sel_lpm_exists%found then
    --
    close sel_lpm_exists;
    --
    -- ** TEMP ** Add error message with the following text.
    --
    call_error_message( p_error_appl           =>   'OTA'
                      , p_error_txt          =>  'OTA_443399_TAV_DEL_LPM_EXISTS'
                      );
    --
  end if;
  --
  close sel_lpm_exists;
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  --
End check_if_lpm_exists;
--

-- ----------------------------------------------------------------------------
-- |-------------------------< check_if_tav_exists >--------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   Delete Validation.
--   This activity version may not be deleted if child rows in
--   ota_activity_versions exists where this activity version has superseded
--   another earlier activity version.
--
Procedure check_if_tav_exists
  (
   p_activity_version_id  in  number
  ) is
  --
  v_exists                varchar2(1);
  v_proc                  varchar2(72) := g_package||'check_if_tav_exists';
  --
  cursor sel_tav_exists is
    select 'Y'
      from ota_activity_versions             tav
     where tav.superseded_by_act_version_id  =  p_activity_version_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  Open  sel_tav_exists;
  fetch sel_tav_exists into v_exists;
  --
  if sel_tav_exists%found then
    --
    close sel_tav_exists;
    --
    -- ** TEMP ** Add error message with the following text.
    --
    call_error_message( p_error_appl           =>   'OTA'
                      , p_error_txt          =>  'OTA_13307_TAV_DEL_SUP_EXISTS'
                      );
    --
  end if;
  --
  close sel_tav_exists;
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  --
End check_if_tav_exists;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< check_if_tsp_exists >--------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   Delete Validation.
--   This activity version may not be deleted if child rows in
--   ota_skill_provisions.
--
Procedure check_if_tsp_exists
  (
   p_activity_version_id  in  number
  ) is
  --
  v_exists                varchar2(1);
  v_proc                  varchar2(72) := g_package||'check_if_tsp_exists';
  --
  cursor sel_tsp_exists is
    select 'Y'
      from ota_skill_provisions             tsp
     where tsp.activity_version_id  =  p_activity_version_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  Open  sel_tsp_exists;
  fetch sel_tsp_exists into v_exists;
  --
  if sel_tsp_exists%found then
    --
    close sel_tsp_exists;
    --
    -- ** TEMP ** Add error message with the following text.
    --
    call_error_message( p_error_appl           =>   'OTA'
                      , p_error_txt          =>  'OTA_443265_TAV_DEL_TSP_EXISTS'
                      );
    --
  end if;
  --
  close sel_tsp_exists;
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  --
End check_if_tsp_exists;
--

-- ----------------------------------------------------------------------------
-- |------------------------< check_duration_units >--------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   The duration units must be in the domain 'Units'.
--
Procedure check_duration_units
  (
   p_duration_units  in  varchar2
  ) is
  --
  v_proc                  varchar2(72) := g_package||'check_duration_units';
  --
Begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  If p_duration_units is not null  Then
    --
    ota_general.check_domain_value( 'OTA_DURATION_UNITS', p_duration_units);
    --
  End if;
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  --
End check_duration_units;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< check_duration >------------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   The duration must be a positive integer greater than zero.
--
Procedure check_duration
  (
   p_duration  in  number
  ) is
  --
  v_proc                  varchar2(72) := g_package||'check_duration';
  --
Begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  If p_duration <= 0 Then
    --
    -- ** TEMP ** Add error message with the following text.
    --
    call_error_message( p_error_appl           =>   'OTA'
                      , p_error_txt          =>  'OTA_13308_TAV_DURATION_POS'
                      );
    --
  end if;
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  --
End check_duration;
--
-- ----------------------------------------------------------------------------
-- |---------------------------< check_language >-----------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   The language must be in the domain 'Languages'.
--
Procedure check_language
  (
   p_language_id  in  number
  ) is
  v_exists                varchar2(1);
  v_proc                  varchar2(72) := g_package||'check_language';
  --
  cursor sel_language is
    select 'Y'
      from fnd_languages       lan
     where lan.language_id  =  p_language_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  Open  sel_language;
  fetch sel_language into v_exists;
  --
  If p_language_id is not null  Then
    --
    if sel_language%notfound then
      --
      close sel_language;
      --
      -- ** TEMP ** Add error message with the following text.
      --
      call_error_message( p_error_appl           =>   'OTA'
                        , p_error_txt          =>  'OTA_13309_TAV_NO_LANG'
                        );
      --
    End if;
    --
  End if;
  --
  close sel_language;
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  --
End check_language;
--
-- ----------------------------------------------------------------------------
-- |-------------------< check_controlling_person >---------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   The controlling person should exist as a valid person on the Validity
--   Start Date of the Activity Version.
--
Procedure check_controlling_person
  (
   p_person_id  in  number
  ,p_date       in  date
  ) is
  --
  v_proc                  varchar2(72) := g_package||'check_controlling_person';
  --
Begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  If p_person_id is not null  Then
    --
    If NOT ota_general.check_person( p_person_id, nvl(p_date,hr_api.g_sot)) Then
      --
      -- ** TEMP ** Add error message with the following text.
      --
      call_error_message( p_error_appl           =>   'OTA'
                        , p_error_txt          =>  'OTA_13295_TAV_NO_MAN'
                        );
      --
    End if;
    --
  End if;
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  --
End check_controlling_person;
--
-- ----------------------------------------------------------------------------
-- |----------------------< exist_multiple_versions >---------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   Checks whether multiple activity versions exist when updating the start and--   end dates of an activity version
--
Function exist_multiple_versions
  (
   p_activity_id  in  number,
   p_activity_version_id in number,
   p_start_date   in date,
   p_end_date     in date
  ) Return boolean is
  --
  v_proc                 varchar2(72) := g_package||'exist_multiple_versions';
  --
  v_exists varchar2(1) := 'N';
  v_start_date date;
  v_end_date date;
  v_default_end_date date;
  --
  cursor sel_versions is
    select 'Y'
      from ota_activity_versions    tav
     where tav.activity_id        = p_activity_id
     and ((tav.activity_version_id <> p_activity_version_id
     and p_activity_version_id is not null )
     or  p_activity_version_id is null)
     and  v_start_date <= nvl(tav.end_date,
                           greatest(v_default_end_date,tav.start_date))
     and  v_end_date   >= nvl(tav.start_date,hr_api.g_sot);
  --
Begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  if p_start_date is null then
     v_start_date := hr_api.g_sot;
  else
     v_start_date := p_start_date;
  end if;
  --
  if p_end_date is null then
     v_end_date := hr_api.g_eot;
  else
     v_end_date := p_end_date;
  end if;
  --
  -- When inserting a new version the end date of the previous version
  -- will be set to p_start_date-1 if it is not already set. Therefore we
  -- should only validate up to this date.
  --
  -- When updating the default end date should be the end of time
  --
  if p_activity_version_id is null then
     if p_start_date is null then
        v_default_end_date := hr_api.g_eot;
     else
        v_default_end_date := p_start_date - 1;
     end if;
  else
     v_default_end_date := hr_api.g_eot;
  end if;
  --
hr_utility.trace(to_char(v_start_date));
hr_utility.trace(to_char(v_end_date));
hr_utility.trace(to_char(v_default_end_date));
--
  Open  sel_versions;
  fetch sel_versions into v_exists;
  --
  if sel_versions%found then
hr_utility.trace('Returning true');
     close sel_versions;
     return(true);
  else
hr_utility.trace('Returning False');
     close sel_versions;
     return(false);
  end if;
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  --
End exist_multiple_versions;
--
--
-- ----------------------------------------------------------------------------
-- |--------------------< check_multiple_con_version>----------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   If the Activity Definitions is specified with the
--   MULTIPLE_CON_VERSIONS_FLAG set to 'N' then Versions of the Activity may not
--
Procedure check_multiple_con_version
  (
   p_activity_id    in  number,
   p_activity_version_id in number,
   p_start_date     in date,
   p_end_date       in date
  ) is
  --
  v_proc              varchar2(72) := g_package||'check_multiple_con_versions';
  v_exists            varchar2(1);
  --
  cursor sel_activity is
    select 'Y'
      from ota_activity_definitions          tad
     where tad.activity_id                =  p_activity_id
       and tad.multiple_con_versions_flag =  'N' ;
  --
Begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  Open  sel_activity;
  Fetch sel_activity into v_exists ;
  --
  If sel_activity%found Then
    --
    If exist_multiple_versions( p_activity_id
                              , p_activity_version_id
                              , p_start_date
                              , p_end_date) Then
      --
      --
      call_error_message( p_error_appl           =>   'OTA'
                        , p_error_txt          =>  'OTA_13310_TAV_NO_CON_VERS'
                        );
      --
    End if;
    --
  End if;
  --
  Close  sel_activity;
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  --
End check_multiple_con_version;
--
--
-- ----------------------------------------------------------------------------
-- |------------------< set_superseding_version >-----------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   If the Activity Definitions is specified with the
--   MULTIPLE_CON_VERSIONS_FLAG set to 'N' and a new version is created for
--   that activity, the superseded by field on the previous version must be
--   populated with the name of the new version
--
Procedure set_superseding_version
  (
   p_activity_id         in  number
  ,p_activity_version_id in number
  ,p_start_date          in date
  ) is
 --
 l_ovn                            number(9);
  v_version_id                    number(9);
  v_start_date                    date;
  v_end_date                      date;
  v_object_version_number         number;
  v_proc            varchar2(72) := g_package||'set_superseding_version';
  --
  cursor get_previous_version is
  select tav.activity_version_id
  ,      tav.start_date
  ,      tav.end_date
  ,      tav.object_version_number
  from   ota_activity_versions    tav
  ,      ota_activity_definitions tad
  where  tad.activity_id = p_activity_id
  and    tad.multiple_con_versions_flag = 'N'
  and    tav.activity_id = tad.activity_id
  and    tav.start_date =
    (select max(tav2.start_date)
     from   ota_activity_versions tav2
     where  tav2.activity_version_id <> p_activity_version_id
     and    tav2.activity_id = p_activity_id);
  --
Begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  open get_previous_version;
  fetch get_previous_version into v_version_id,
                                  v_start_date,
                                  v_end_date,
                                  v_object_version_number;
  --
  if get_previous_version%notfound then
     null;
  elsif
     v_start_date > p_start_date-1 then
/*
       fnd_message.set_name('OTA','OTA_13500_TAV_NO_CLOSE_DATE');
       fnd_message.raise_error;
*/
null;
  else
     --
     -- If the end date is not null then we do not want to update it
     --
     if v_end_date is not null then
        v_end_date := hr_api.g_date;
     else
        v_end_date := p_start_date - 1;
     end if;
     --
     ota_tav_upd.upd(p_activity_version_id => v_version_id
                    ,p_activity_id         => p_activity_id
                    ,p_superseded_by_act_version_id => p_activity_version_id
                    ,p_end_date            => v_end_date
                    ,p_object_version_number => v_object_version_number);
  end if;
  close get_previous_version;
  --
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  --
End set_superseding_version;
--
-- ----------------------------------------------------------------------------
-- |--------------------< set_superseding_start_date>-------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--  If the previous version has an end date then the start date defaults to
--  the end date of the previous version plus one
--
Function set_superseding_start_date
  (
   p_activity_id    in  number
  ) Return date is
  --
  v_proc              varchar2(72) := g_package||'set_superseding-start_date';
  v_max_end_date      date;
  v_activity_id       number;
  v_activity_version_id  number;
  --
  cursor get_versions is
    select tav.end_date
      from ota_activity_versions          tav
          , ota_activity_definitions       tad
     where tav.activity_id                =   tad.activity_id --p_activity_id
       and tad.activity_id = p_activity_id -- Bug 2808274
       and tad.multiple_con_versions_flag =  'N'
       order by tav.end_date desc;
  --
Begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  Open  get_versions;
  Fetch get_versions into v_max_end_date;
  --
  If get_versions%found and v_max_end_date is not null Then
    --
   return(v_max_end_date + 1);
   --
  Else
    --
   return (sysdate);
    --
  End if;
  --
  Close  get_versions;
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  --
End set_superseding_start_date;
--
-- ---------------------------------------------------------------------------
-- |------------------< check_version_after_supersede >----------------------|
-- ---------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   If the Activity Definitions is specified with the
--   MULTIPLE_CON_VERSIONS_FLAG set to 'N' and the latest Activity Version has
--   been superseded by a Version of a different Activity, then new Version of
--   the Activity are not allowed (because there would be confusion over which
--   is the valid versiou of the activity, the new one or the superseding one).
--
Procedure check_version_after_supersede
  (
   p_activity_id    in  number
  ) is
  --
  v_exists          varchar2(1);
  v_act_version_id  number(9);
  v_proc            varchar2(72) := g_package||'check_version_after_supersede';
  --
  cursor sel_latest_version is
    select tav.superseded_by_act_version_id
      from ota_activity_definitions          tad
         , ota_activity_versions             tav
     where tad.activity_id                =  p_activity_id
       and tad.multiple_con_versions_flag =  'N'
       and tav.activity_id                =  tad.activity_id
       and nvl(tav.end_date, hr_api.g_eot) =
           (select max( nvl(tav2.end_date, hr_api.g_eot))
            from   ota_activity_versions tav2
            where  tav2.activity_id                =  p_activity_id);
  --
  cursor sel_superseded_act( pc_activity_version_id  IN  number) is
    select 'Y'
      from ota_activity_versions       tav
     where tav.activity_id          =  p_activity_id
       and tav.activity_version_id  =  pc_activity_version_id ;
  --
Begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
    Open  sel_latest_version;
    Fetch sel_latest_version into v_act_version_id;
    --
    If sel_latest_version%found then
      --
      If v_act_version_id is not null  Then
        --
        Open  sel_superseded_act( v_act_version_id);
        Fetch sel_superseded_act into v_exists;
        --
        If sel_superseded_act%notfound then
          --
          -- The activities of the actual activity version and the superseded
          -- activity version are different.
          --
          close sel_latest_version;
          close sel_superseded_act;
          --
          fnd_message.set_name('OTA','OTA_13311_TAV_NO_CON_SUP');
          fnd_message.raise_error;
          --
        End if;
        --
        close sel_superseded_act;
        --
      End if;
      --
    End if;
    --
    close sel_latest_version;
    --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  --
End check_version_after_supersede;
--

-- ----------------------------------------------------------------------------
-- |-----------------------------< check_OE_Lines_exist>------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   If The inventory id that link to this Activity has been ordered through
--   Order Line than user cannot change the inventory id.
--
--
Procedure check_OE_lines_exist
(
p_activity_version_id in number,
p_inventory_item_id  in number,
p_organization_id    in number
)IS
 l_proc            varchar2(72) := g_package||'check_OE_lines_exist';
  l_exists	varchar2(1);
  l_old_inventory_item_id mtl_system_items_b.inventory_item_id%type;
  l_old_organization_id  mtl_system_items_b.organization_id%type;
 --
--  cursor to check is inventory id is valid.
--
   cursor csr_order_line is
     select null
     from oe_order_lines_all
     where inventory_item_id = p_inventory_item_id and
           org_id = p_organization_id;

     cursor csr_order_line_exist is
     select null
     from oe_order_lines_all
     where inventory_item_id = l_old_inventory_item_id and
           org_id = l_old_organization_id;


     cursor csr_old_inventory is
	select inventory_item_id,
             organization_id
	from ota_activity_versions
	where activity_version_id = p_activity_version_id;
--
Begin
  --
  hr_utility.set_location('Entering:'|| l_proc, 5);

 OPEN csr_old_inventory;
 FETCH csr_old_inventory into l_old_inventory_item_id,
	l_old_organization_id;
 CLOSE  csr_old_inventory;
  if ((p_activity_version_id is not null) and
      nvl(l_old_inventory_item_id,hr_api.g_number) <>
         nvl(p_inventory_item_id,hr_api.g_number)) then
  --
     hr_utility.set_location('Entering:'||l_proc, 10);

  --
    if p_inventory_item_id is null and l_old_inventory_item_id is not null then
        hr_utility.set_location('Entering:'||l_proc, 15);
            open csr_order_line_exist;
            fetch csr_order_line_exist into l_exists;
            if csr_order_line_exist%found then
               fnd_message.set_name('OTA','OTA_13695_TAV_INV_EXIST');
               fnd_message.raise_error;
            end if;
            close csr_order_line_exist;
            hr_utility.set_location('Entering:'||l_proc, 20);


    end if;
    if (p_inventory_item_id is not null  and
       p_organization_id is not null) and
       (l_old_inventory_item_id is not null and
        l_old_organization_id is not null) then
         hr_utility.set_location('Entering:'||l_proc, 25);
            open csr_order_line_exist;
            fetch csr_order_line_exist into l_exists;
            if csr_order_line_exist%found then
               fnd_message.set_name('OTA','OTA_13695_TAV_INV_EXIST');
               fnd_message.raise_error;
            end if;
            close csr_order_line_exist;
            hr_utility.set_location('Entering:'||l_proc, 30);
    end if;
    --
   end if;
  hr_utility.set_location(' Leaving:'|| l_proc, 35);
  --
  exception
      when app_exception.application_exception then
         if hr_multi_message.exception_add
                 (p_associated_column1   => 'OTA_ACTIVITY_VERSIONS.INVENTORY_ITEM_ID'
                 ) then
            hr_utility.set_location(' Leaving:'|| l_proc,70);
            raise;
         end if;
     hr_utility.set_location(' Leaving:'|| l_proc,80);
End check_OE_lines_exist;

--
-- ----------------------------------------------------------------------------
-- |----------------------------< chk_Inventory_item_id>----------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   If The inventory id is not a valid inventory id in MTL_SYSTEM_ITEMS_B table
--   then user has to provide the correct one.
--
--
--
Procedure check_Inventory_item_id
(
p_activity_version_id in number,
p_inventory_item_id  in number,
p_organization_id    in number
)IS
 l_proc            varchar2(72) := g_package||'check_Inventory_item_id';
  l_exists	varchar2(1);
  l_old_inventory_item_id mtl_system_items_b.inventory_item_id%type;
  l_old_organization_id   mtl_system_items_b.organization_id%type;
  L_NUM number ;
--
--  cursor to check is inventory id is valid.
--
   cursor csr_inventory is
     select null
     from mtl_system_items_b
     where inventory_item_id = p_inventory_item_id and
           organization_id = p_organization_id;

   cursor csr_old_inventory is
	select inventory_item_id,
		 organization_id
      from
      ota_activity_versions
      where activity_version_id <> p_activity_version_id;

  cursor cur_offerings is
      select 1 from ota_offerings off,ota_category_usages  cat
      where  cat.type ='DM'
      and    (cat.online_flag = 'Y' or( cat.online_flag = 'N' and cat.synchronous_flag = 'N'))
      and    cat.category_usage_id = off.delivery_mode_id
      and    off.activity_version_id = p_activity_version_id;

cursor csr_enr is -- For bug 4401602
      select 1 from ota_offerings off,
              ota_events  evt,
              ota_delegate_bookings tdb
      where  evt.parent_offering_id = off.offering_id
      and    tdb.event_id = evt.event_id
      and    off.activity_version_id = p_activity_version_id;

Begin
  --

  hr_utility.set_location('Entering:'|| l_proc, 5);
   IF p_activity_version_id is not null THEN
      OPEN csr_old_inventory;
	FETCH csr_old_inventory into l_old_inventory_item_id,
						l_old_organization_id;
	CLOSE csr_old_inventory;
   END IF;

  if (((p_activity_version_id is not null) and
      (nvl(l_old_inventory_item_id ,hr_api.g_number) <>
         nvl(p_inventory_item_id,hr_api.g_number)or
          nvl(l_old_organization_id,hr_api.g_number) <>
          nvl(p_organization_id,hr_api.g_number)))
   or (p_activity_version_id is null)) then
  --
     hr_utility.set_location('Entering:'||l_proc, 10);

  --
    if p_inventory_item_id is not null  and
       p_organization_id is not null then
         hr_utility.set_location('Entering:'||l_proc, 15);
            open csr_inventory;
            fetch csr_inventory into l_exists;
            if csr_inventory%notfound then
               fnd_message.set_name('OTA','OTA_13693_TAV_NO_INV');
               fnd_message.raise_error;
            end if;
            close csr_inventory;
            hr_utility.set_location('Entering:'||l_proc, 20);
    elsif p_inventory_item_id is not null  and
          p_organization_id is null then
	    fnd_message.set_name('OTA','OTA_13892_TAV_INV_COMB_INVALID');
          fnd_message.raise_error;
    elsif p_inventory_item_id is null  and
          p_organization_id is not null then
	    fnd_message.set_name('OTA','OTA_13892_TAV_INV_COMB_INVALID');
          fnd_message.raise_error;

    end if;
    --
   end if;

  if ( p_activity_version_id is not null
       and p_inventory_item_id is not null
        and  (nvl(l_old_inventory_item_id ,hr_api.g_number) <>
         nvl(p_inventory_item_id,hr_api.g_number))) then

		open cur_offerings;
		fetch cur_offerings
		  into l_num;
		       if cur_offerings%found then
	               fnd_message.set_name('OTA','OTA_443662_ACT_INVENTORY');
                   fnd_message.raise_error;
               end if;
		close cur_offerings;


             	open csr_enr; -- Bug 4401602
		fetch csr_enr
		  into l_num;
	       if csr_enr%found then
	               fnd_message.set_name('OTA','OTA_443915_TAV_INV_ENR_EXITS');
                   fnd_message.raise_error;
               end if;
		close csr_enr;


  end if;



  hr_utility.set_location(' Leaving:'|| l_proc, 30);
  --
  exception
    when app_exception.application_exception then
       if hr_multi_message.exception_add
               (p_associated_column1   => 'OTA_ACTIVITY_VERSIONS.INVENTORY_ITEM_ID'
               ) then
          hr_utility.set_location(' Leaving:'|| l_proc,70);
          raise;
       end if;
     hr_utility.set_location(' Leaving:'|| l_proc,80);
End check_inventory_item_id;

--
-- ----------------------------------------------------------------------------
-- |-----------------------------< check_unique_rco_id>------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   Check uniqueness of rco_id
--
--
--
--
Procedure check_unique_rco_id
(
p_activity_version_id in number,
p_rco_id  		    in number)

IS

l_proc  varchar2(72) := g_package||'check_unique_rco_id';
l_exists	varchar2(1);

cursor csr_rco is
     select null
     from ota_activity_versions
     where rco_id = p_rco_id;

Begin

 hr_utility.set_location('Entering:'||l_proc, 5);

if (((p_activity_version_id is not null) and
      nvl(ota_tav_shd.g_old_rec.rco_id,hr_api.g_number) <>
         nvl(p_rco_id,hr_api.g_number))
   or (p_activity_version_id is null)) then
  --
     hr_utility.set_location('Entering:'||l_proc, 10);
     if (p_rco_id is not null) then
          hr_utility.set_location('Entering:'||l_proc, 15);
           open csr_rco;
            fetch csr_rco into l_exists;
            if csr_rco%found then
               ota_tav_shd.constraint_error(p_constraint_name =>'OTA_ACTIVITY_VERSIONS_UK5');
            end if;
            close csr_rco;
            hr_utility.set_location('Leaving:'||l_proc, 20);
      end if;
end if;
exception
    when app_exception.application_exception then
       if hr_multi_message.exception_add
               (p_associated_column1   => 'OTA_ACTIVITY_VERSIONS.RCO_ID'
               ) then
          hr_utility.set_location(' Leaving:'|| l_proc,70);
          raise;
       end if;
     hr_utility.set_location(' Leaving:'|| l_proc,80);
hr_utility.set_location('Leaving:'||l_proc, 30);
End;

--
-- ----------------------------------------------------------------------------
-- |-----------------------------< check_course_lp_dates>------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   Check dates of Course and Learning Path
--
--
--
--
Procedure check_course_lp_dates
(
p_activity_version_id IN NUMBER,
p_start_date IN DATE,
p_end_date IN DATE)

IS

l_proc  varchar2(72) := g_package||'check_course_lp_dates';
l_exists	varchar2(1);
l_upd_start_date BOOLEAN;
l_upd_end_date BOOLEAN;
l_start_date DATE;
l_end_date DATE;
l_learning_path_id NUMBER;

CURSOR csr_course_lp_dates(l_start_date DATE, l_end_date DATE) IS
SELECT lps.learning_path_id
FROM ota_learning_paths_vl lps,
  ota_learning_path_members lpm
WHERE lpm.learning_path_id = lps.learning_path_id
   AND lpm.activity_version_id = p_activity_version_id
   AND (( l_end_date IS NOT NULL AND lps.start_date_active > l_end_date)
           OR (lps.end_date_active IS NOT NULL AND l_start_date > lps.end_date_active));

Begin

 hr_utility.set_location('Entering:'||l_proc, 5);
IF hr_multi_message.no_exclusive_error
    (p_check_column1        => 'OTA_ACTIVITY_VERSIONS.START_DATE'
    ,p_check_column2        => 'OTA_ACTIVITY_VERSIONS.END_DATE'
    ,p_associated_column1   => 'OTA_ACTIVITY_VERSIONS.START_DATE'
    ,p_associated_column2   => 'OTA_ACTIVITY_VERSIONS.END_DATE' ) THEN

    IF (NVL(ota_tav_shd.g_old_rec.start_date, hr_api.g_date) <>
         NVL( p_start_date, hr_api.g_date )) THEN
       l_upd_start_date := TRUE;
       l_start_date := p_start_date;
    ELSE
       l_upd_start_date := FALSE;
       l_start_date := ota_tav_shd.g_old_rec.start_date;
    END IF;

    IF (NVL(ota_tav_shd.g_old_rec.end_date, hr_api.g_date) <>
         NVL( p_end_date, hr_api.g_date )) THEN
       l_upd_end_date := TRUE;
       l_end_date := p_end_date;
    ELSE
       l_upd_end_date := FALSE;
       l_end_date := ota_tav_shd.g_old_rec.end_date;
    END IF;

    IF (l_upd_start_date OR l_upd_end_date) THEN

      OPEN csr_course_lp_dates(l_start_date, l_end_date);
      FETCH csr_course_lp_dates INTO l_learning_path_id;

      IF csr_course_lp_dates%FOUND THEN
          call_error_message( p_error_appl           =>   'OTA'
                      , p_error_txt          =>  'OTA_443073_CRS_LP_DTS_INVALID'
                      );
        CLOSE csr_course_lp_dates;
      ELSE
          CLOSE csr_course_lp_dates;
      END IF;
   END IF;
 END IF;

hr_utility.set_location('Leaving:'||l_proc, 80);
End;

-- ----------------------------------------------------------------------------
-- |-------------------------< check_if_noth_exists >--------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   Delete Validation.
--   This activity version may not be deleted if child rows in
--   ota_notrng_histories exists where this activity version.
--
Procedure check_if_noth_exists
  (
   p_activity_version_id  in  number
  )
IS
  --
  v_exists                varchar2(1);
  v_proc                  varchar2(72) := g_package||'check_if_noth_exists';
  --
  cursor sel_noth_exists is
    select 'Y'
      from ota_notrng_histories        nth
     where nth.activity_version_id  =  p_activity_version_id;
  --
Begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  Open  sel_noth_exists;
  fetch sel_noth_exists into v_exists;
  --
  if sel_noth_exists%found then
    --
    close sel_noth_exists;
    --
    -- ** TEMP ** Add error message with the following text.
    --
    call_error_message( p_error_appl           =>   'OTA'
                      , p_error_txt          =>  'OTA_443546_TAV_DEL_NTH_EXISTS'
                      );
    --
  end if;
  --
  close sel_noth_exists;
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  --

end check_if_noth_exists;

-- ----------------------------------------------------------------------------
-- |-------------------------< check_if_crt_exists >--------------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   Delete Validation.
--   This activity version may not be deleted if child rows in
--   ota_certification_members exists where this activity version.
--
Procedure check_if_crt_exists
  (
   p_activity_version_id  in  number
  )
IS
  --
  v_exists                varchar2(1);
  v_proc                  varchar2(72) := g_package||'check_if_crt_exists';
  --
  cursor sel_ctm_exists is
    select 'Y'
      from ota_certification_members        ctm
     where ctm.object_id  =  p_activity_version_id
     and ctm.object_type = 'H';
  --
Begin
  --
  hr_utility.set_location('Entering:'|| v_proc, 5);
  --
  Open  sel_ctm_exists;
  fetch sel_ctm_exists into v_exists;
  --
  if sel_ctm_exists%found then
    --
    close sel_ctm_exists;
    --
    --
    --
    call_error_message( p_error_appl           =>   'OTA'
                      , p_error_txt          =>  'OTA_443949_TAV_DEL_CTM_EXISTS'
                      );
    --
  end if;
  --
  close sel_ctm_exists;
  --
  hr_utility.set_location(' Leaving:'|| v_proc, 10);
  --

end check_if_crt_exists;

--
-- ----------------------------------------------------------------------------
-- |-----------------------------< check_course_crt_dates>---------------------|
-- ----------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
--   Check dates of Course and Certification
--
--
--
--
Procedure check_course_crt_dates
(
p_activity_version_id IN NUMBER,
p_start_date IN DATE,
p_end_date IN DATE)

IS

l_proc  varchar2(72) := g_package||'check_course_crt_dates';
l_exists	varchar2(1);
l_upd_start_date BOOLEAN;
l_upd_end_date BOOLEAN;
l_start_date DATE;
l_end_date DATE;
l_certification_id NUMBER;

CURSOR csr_course_crt_dates(l_start_date DATE, l_end_date DATE) IS
SELECT ctm.certification_id
FROM ota_certification_members ctm
WHERE ctm.object_id = p_activity_version_id
   AND ctm.object_type='H'
   AND (
        (l_end_date IS NOT NULL AND ctm.start_date_active > l_end_date)
		 OR (l_end_date is not null and ctm.end_date_active is not null AND ctm.end_date_active > l_end_date)
         OR (ctm.start_date_active < l_start_date)
		 OR (ctm.end_date_active IS NOT NULL AND l_start_date > ctm.end_date_active)
	   )
    ;


Begin

 hr_utility.set_location('Entering:'||l_proc, 5);
IF hr_multi_message.no_exclusive_error
    (p_check_column1        => 'OTA_ACTIVITY_VERSIONS.START_DATE'
    ,p_check_column2        => 'OTA_ACTIVITY_VERSIONS.END_DATE'
    ,p_associated_column1   => 'OTA_ACTIVITY_VERSIONS.START_DATE'
    ,p_associated_column2   => 'OTA_ACTIVITY_VERSIONS.END_DATE' ) THEN

     IF (NVL(ota_tav_shd.g_old_rec.start_date, hr_api.g_date) <>
         NVL( p_start_date, hr_api.g_date )) THEN
       l_upd_start_date := TRUE;
       l_start_date := p_start_date;
    ELSE
       l_upd_start_date := FALSE;
       l_start_date := ota_tav_shd.g_old_rec.start_date;
    END IF;

    IF (NVL(ota_tav_shd.g_old_rec.end_date, hr_api.g_date) <>
         NVL( p_end_date, hr_api.g_date )) THEN
       l_upd_end_date := TRUE;
       l_end_date := p_end_date;
    ELSE
       l_upd_end_date := FALSE;
       l_end_date := ota_tav_shd.g_old_rec.end_date;
    END IF;

    IF (l_upd_start_date OR l_upd_end_date) THEN

      OPEN csr_course_crt_dates(l_start_date, l_end_date);
      FETCH csr_course_crt_dates INTO l_certification_id;

      IF csr_course_crt_dates%FOUND THEN
          call_error_message( p_error_appl           =>   'OTA'
                      , p_error_txt          =>  'OTA_443808_CRS_CRT_DTS_INVALID'
                      );
        CLOSE csr_course_crt_dates;
      ELSE
          CLOSE csr_course_crt_dates;
      END IF;
   END IF;
 END IF;

hr_utility.set_location('Leaving:'||l_proc, 80);
End check_course_crt_dates;
end ota_tav_api_business_rules;

/

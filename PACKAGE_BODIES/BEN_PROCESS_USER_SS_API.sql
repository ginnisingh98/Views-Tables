--------------------------------------------------------
--  DDL for Package Body BEN_PROCESS_USER_SS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_PROCESS_USER_SS_API" AS
/* $Header: benusrwf.pkb 120.0.12000000.2 2007/02/22 10:33:20 vvprabhu noship $*/

-- Global variables
  g_package                  constant varchar2(80):='ben_process_user_ss_api.';
  g_data_error               exception;
  g_void_fnd_user_rec        ben_process_user_utility.fnd_user_record;
  g_void_fnd_resp_rec        ben_process_user_utility.fnd_resp_record;

--
function get_transaction_step_id
   (p_item_type                       in  varchar2
   ,p_item_key                        in  varchar2
   ,p_activity_id                     in  number
   ) return number is
  --
  l_obj_vers_num               number;
  l_no_of_rows                 number := 0;
  l_transaction_step_id        number := null;
  --
begin
  --
  /*if p_user_name is null then
    return l_transaction_step_id;
  end if;*/
  --
  -- ------------------------------------------------------------------
  -- Check if there are any transaction rec already saved for the curren
  -- transaction. This is used for re-display of the user page when a user
  -- clicks series of Back buttons starting from the Review page to go back to the user page
  -- to make further changes or to correct errors.
  -----------------------------------------------------------------------------
  --
  hr_transaction_api.get_transaction_step_info
   (p_item_type              => p_item_type
   ,p_item_key               => p_item_key
   ,p_activity_id            => p_activity_id
   ,p_transaction_step_id    => l_transaction_step_id
   ,p_object_version_number  => l_obj_vers_num
   );
  --
  if l_no_of_rows > 0 then
    null;
  else
     return l_transaction_step_id;
  end if;
  --
  /*for i in 1..l_no_of_rows loop
  l_user_name
         := hr_transaction_api.get_varchar2_value
                    (p_transaction_step_id => l_transaction_step_ids(i-1)
                    ,p_name                => 'P_USER_NAME');
     if p_user_name = l_user_name then
      l_transaction_step_id := l_transaction_step_ids(i-1);
      exit;
     end if;
  end loop;*/
  --
  return l_transaction_step_id;
  --
end get_transaction_step_id;
--
-- ---------------------------------------------------------------------------
-- ---------------------- < get_user_data_from_tt> -------------------------
-- ---------------------------------------------------------------------------
-- Purpose: This procedure will get transaction data which are pending for
--          approval in workflow for a transaction step id.
--          This is the procedure which does the actual work.
-- ---------------------------------------------------------------------------
procedure get_user_data_from_tt
  (p_transaction_step_id             in  number
  ,p_user_name                    out nocopy varchar2
  ,p_user_pswd                    out nocopy varchar2
  ,p_pswd_hint                    out nocopy varchar2
  ,p_owner                        out nocopy varchar2
  ,p_session_number               out nocopy number
  ,p_start_date                   out nocopy date
  ,p_end_date                     out nocopy date
  ,p_last_logon_date              out nocopy date
  ,p_password_date                out nocopy date
  ,p_password_accesses_left       out nocopy number
  ,p_password_lifespan_accesses   out nocopy number
  ,p_password_lifespan_days       out nocopy number
  ,p_employee_id                  out nocopy number
  ,p_email_address                out nocopy varchar2
  ,p_fax                          out nocopy varchar2
  ,p_customer_id                  out nocopy number
  ,p_supplier_id                  out nocopy number
  ,p_business_group_id            out nocopy number
  ,p_respons_id                   out nocopy number
  ,p_respons_appl_id              out nocopy number
   ) is
  --
   cursor c_txn_values is
     select txn.name
           ,txn.varchar2_value
           ,txn.number_value
           ,txn.date_value
     from  hr_api_transaction_values txn
     where txn.transaction_step_id = p_transaction_step_id
     and   (txn.varchar2_value is not null or
            txn.number_value is not null or
            txn.date_value is not null);
  --
begin
  --
  if p_transaction_step_id is null then
    return;
  end if;
  --
  for l_txn_values in c_txn_values loop
  --
    if l_txn_values.name = 'P_USER_NAME' then
      p_user_name := l_txn_values.varchar2_value;
    elsif l_txn_values.name = 'P_ENCRYPTED_PASSWORD' then
      p_user_pswd := l_txn_values.varchar2_value;
    elsif l_txn_values.name = 'P_DESCRIPTION' then
      p_pswd_hint := l_txn_values.varchar2_value;
    elsif l_txn_values.name = 'P_OWNER' then
      p_owner := l_txn_values.varchar2_value;
    elsif l_txn_values.name = 'P_SESSION_NUMBER' then
      p_session_number := l_txn_values.number_value;
    elsif l_txn_values.name = 'P_START_DATE' then
      p_start_date := l_txn_values.date_value;
    elsif l_txn_values.name = 'P_END_DATE' then
      p_end_date := l_txn_values.date_value;
    elsif l_txn_values.name = 'P_LAST_LOGON_DATE' then
      p_last_logon_date := l_txn_values.date_value;
    elsif l_txn_values.name = 'P_PASSWORD_DATE' then
      p_password_date := l_txn_values.date_value;
    elsif l_txn_values.name = 'P_PASSWORD_ACCESSES_LEFT' then
      p_password_accesses_left := l_txn_values.number_value;
    elsif l_txn_values.name = 'P_PASSWORD_LIFESPAN_ACCESSES' then
      p_password_lifespan_accesses := l_txn_values.number_value;
    elsif l_txn_values.name = 'P_PASSWORD_LIFESPAN_DAYS' then
      p_password_lifespan_days := l_txn_values.number_value;
    elsif l_txn_values.name = 'P_EMPLOYEE_ID' then
      p_employee_id := l_txn_values.number_value;
    elsif l_txn_values.name = 'P_EMAIL_ADDRESS' then
      p_email_address := l_txn_values.varchar2_value;
    elsif l_txn_values.name = 'P_FAX' then
      p_fax := l_txn_values.varchar2_value;
    elsif l_txn_values.name = 'P_CUSTOMER_ID' then
      p_customer_id := l_txn_values.number_value;
    elsif l_txn_values.name = 'P_SUPPLIER_ID' then
      p_supplier_id := l_txn_values.number_value;
    elsif l_txn_values.name = 'P_BUSINESS_GROUP_ID' then
      p_business_group_id := l_txn_values.number_value;
    elsif l_txn_values.name = 'P_RESPONSIBILITY_ID' then
      p_respons_id := l_txn_values.number_value;
    elsif l_txn_values.name = 'P_RESPONSIBILITY_APPL_ID' then
      p_respons_appl_id := l_txn_values.number_value;
    end if;
    --
  end loop;
  --
end get_user_data_from_tt;
--
-- ----------------------------------------------------------------------------
-- |---------------------- < create_sec_profile_asg > ------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE create_sec_profile_asg
  (p_user_id               in fnd_user.user_id%type
  ,p_sec_group_id          in fnd_security_groups.security_group_id%type
  ,p_sec_profile_id        in per_security_profiles.security_profile_id%type
  ,p_resp_id               in fnd_responsibility.responsibility_id%type
  ,p_resp_app_id           in per_sec_profile_assignments.responsibility_application_id%type
  ,p_start_date            in per_sec_profile_assignments.start_date%type
  ,p_end_date              in per_sec_profile_assignments.end_date%type default null
  ,p_business_group_id     in per_sec_profile_assignments.business_group_id%type default null

  ) is
--
--
  cursor lc_get_sec_group_id IS
  select fsg.security_group_id
  from   fnd_security_groups fsg
  where  fsg.security_group_id = p_sec_group_id;
--
  cursor lc_get_sec_profile IS
  select psp.security_profile_id
        ,psp.business_group_id
  from   per_security_profiles psp
  where  psp.security_profile_id = p_sec_profile_id;
--
  l_bg_id               per_security_profiles.business_group_id%type := null;
  l_dummy               number default null;
  l_sec_prof_asg_id
        per_sec_profile_assignments.sec_profile_assignment_id%type := null;
  l_obj_vers_num
        per_sec_profile_assignments.object_version_number%type := null;
  l_proc                varchar2(72) := g_package|| 'create_sec_profile_asg';

BEGIN
  hr_utility.set_location('Entering:' || l_proc, 10);
  --
  --Validate input parameters first.
  --Validate security group id

    l_dummy := null;

    open lc_get_sec_group_id;
    fetch lc_get_sec_group_id into l_dummy;
    if lc_get_sec_group_id%NOTFOUND
    then
       close lc_get_sec_group_id;
       fnd_message.set_name('FND', 'SQL_NO_DATA_FOUND');
       fnd_message.set_token('TABLE', 'FND_SECURITY_GROUPS');
       fnd_message.set_token('COLUMN', 'SECURITY_GROUP_ID');
       fnd_message.set_token('VALUE', to_char(p_sec_group_id));
       hr_utility.raise_error;
    else
       close lc_get_sec_group_id;
    end if;
  --
  -- Validate security_profile_id
     l_dummy := null;

    open lc_get_sec_profile;
    fetch lc_get_sec_profile into l_dummy, l_bg_id;
    --
    if lc_get_sec_profile%NOTFOUND
    then
       close lc_get_sec_profile;
       fnd_message.set_name('FND', 'SQL_NO_DATA_FOUND');
       fnd_message.set_token('TABLE', 'PER_SECURITY_PROFILES');
       fnd_message.set_token('COLUMN', 'SECURITY_PROFILE_ID');
       fnd_message.set_token('VALUE', to_char(p_sec_profile_id));
       hr_utility.raise_error;
    else
       close lc_get_sec_profile;
    end if;
  --
  -- Validate Start Date cannot be null
  if p_start_date is null
  then
     hr_utility.set_message(800, 'HR_50374_SSL_MAND_START_DATE');
     hr_utility.raise_error;
  end if;
--
if p_end_date is not null
  then
     if p_end_date < nvl(p_start_date, p_end_date + 1)
     then
        hr_utility.set_message(800, 'HR_51070_CAU_START_END');
        hr_utility.raise_error;
     end if;
  end if;
  --
  -- Now call the per_asp_ins.ins which will insert a row into
  -- per_sec_profile_assignments as well as fnd_user_resp_groups.
  per_asp_ins.ins
    (p_user_id                      => p_user_id
    ,p_security_group_id            => p_sec_group_id
    ,p_business_group_id            => l_bg_id
    ,p_security_profile_id          => p_sec_profile_id
    ,p_responsibility_id            => p_resp_id
    ,p_responsibility_application_i => p_resp_app_id
    ,p_start_date                   => p_start_date
    ,p_end_date                     => p_end_date
    ,p_sec_profile_assignment_id    => l_sec_prof_asg_id
    ,p_object_version_number        => l_obj_vers_num
    );

--
  hr_utility.set_location('Leaving:'||l_proc, 50);


END create_sec_profile_asg;
--
-- ---------------------------------------------------------------------------
-- ---------------------- < add_func_sec_exclusion_rules> -------------------------
-- ---------------------------------------------------------------------------
procedure add_func_sec_exclusion_rules
      (p_resp_id               in fnd_responsibility.responsibility_id%type
      ,p_resp_app_id           in fnd_responsibility.application_id%type)
is
--
  cursor lc_get_resp_func (p_resp_id in
                              fnd_responsibility.responsibility_id%type
                          ,p_app_id  in
                              fnd_responsibility.application_id%type)
  is
  select   frf.action_id, frf.rule_type
  from     fnd_resp_functions frf
  where    frf.application_id = p_app_id
  and      frf.responsibility_id = p_resp_id;
--

  cursor lc_get_function_name (p_func_id in fnd_form_functions.function_id%type)
  is
  select   fff.function_name
  from     fnd_form_functions fff
  where    fff.function_id = p_func_id;
--
  cursor lc_get_menu_name (p_menu_id in fnd_menus.menu_id%type)
  is
  select   fm.menu_name
  from     fnd_menus fm
  where    fm.menu_id = p_menu_id;
--
  cursor lc_get_resp_id (p_resp_id in
                              fnd_responsibility.responsibility_id%type
                          ,p_app_id  in
                              fnd_responsibility.application_id%type)
  is
  select   fr.responsibility_key
  FROM     fnd_responsibility fr
  where    fr.application_id = p_app_id
  and      fr.responsibility_id = p_resp_id;
--
  l_proc                      varchar2(72) := g_package ||
                                              'add_func_sec_exclusion_rules';
  l_rule_name                 fnd_form_functions.function_name%type;
  l_resp_key                  fnd_responsibility.responsibility_key%type;
  l_func_sec_excl_err         exception;
--
begin
  hr_utility.set_location('Entering:'|| l_proc, 11);
--
  for get_resp_func_rec in lc_get_resp_func
            (p_resp_id => p_resp_id
            ,p_app_id  => p_resp_app_id)
        loop
           --
           if get_resp_func_rec.rule_type = 'F'
           then
              -- derive the function_name from fnd_form_functions
              open lc_get_function_name
                   (p_func_id => get_resp_func_rec.action_id);
              fetch lc_get_function_name into l_rule_name;
              if lc_get_function_name%NOTFOUND
              then
                 -- raise an error
                 close lc_get_function_name;
                 raise l_func_sec_excl_err;
              else
                 close lc_get_function_name;
              end if;
           else
              -- derive the menu_name from fnd_menus
              open lc_get_menu_name
                   (p_menu_id => get_resp_func_rec.action_id);
              fetch lc_get_menu_name into l_rule_name;
              if lc_get_menu_name%NOTFOUND
              then
                 -- raise an error
                 close lc_get_menu_name;
                 raise l_func_sec_excl_err;
              else
                 close lc_get_menu_name;
              end if;
           end if;

              open lc_get_resp_id
                   (p_resp_id => p_resp_id
                    ,p_app_id  => p_resp_app_id);
              fetch lc_get_resp_id into l_resp_key;
              if lc_get_resp_id%NOTFOUND
              then
                 -- raise an error
                 close lc_get_resp_id;
                 raise l_func_sec_excl_err;
              else
                 close lc_get_resp_id;
              end if;

      fnd_function_security.security_rule
      (responsibility_key  => l_resp_key
      ,rule_type           => get_resp_func_rec.rule_type
      ,rule_name           => l_rule_name);

    end loop;
--
  hr_utility.set_location('Leaving:'|| l_proc, 15);
--
exception
    when l_func_sec_excl_err then
       hr_utility.set_message(800, 'HR_BUILD_FUNC_EXCL_RULE_ERR');
       hr_utility.raise_error;
--
    when others then
       hr_utility.set_message(800, 'HR_BUILD_FUNC_EXCL_RULE_ERR');
       hr_utility.raise_error;
--
END add_func_sec_exclusion_rules;
--
-- ---------------------------------------------------------------------------
-- ---------------------- < create_user_details> -------------------------
-- ---------------------------------------------------------------------------
-- Purpose: This procedure does have user hooks and actually calls fnd_user_pkg to do inserts.
-- ---------------------------------------------------------------------------
procedure create_user_details
           (p_validate                   in boolean  default false
           ,p_user_name                  in varchar2
           ,p_owner                      in varchar2 default null
           ,p_unencrypted_password       in varchar2
           ,p_session_number             in number default 0
           ,p_start_date                 in date default sysdate
           ,p_end_date                   in date default null
           ,p_last_logon_date            in date default null
           ,p_description                in varchar2 default null
           ,p_password_date              in date default sysdate
           ,p_password_accesses_left     in number default null
           ,p_password_lifespan_accesses in number default null
           ,p_password_lifespan_days     in number default null
           ,p_employee_id                in number default null
           ,p_email_address              in varchar2 default null
           ,p_fax                        in varchar2 default null
           ,p_customer_id                in number default null
           ,p_supplier_id                in number default null
           ,p_business_group_id          in number default null
           ,p_responsibility_id          in number default null
           ,p_respons_application_id     in number default null
           ,p_api_error                  out nocopy boolean
           ,p_user_id                    out nocopy number
           ) is

   l_user_id             number(15);
   l_start_date          date;
   l_end_date            date;
   l_last_logon_date     date;
   l_password_date       date;
   l_respons_id          number ;
   l_respons_appl_id     number ;
   l_employee_id         number default null;
   prflvalue             varchar2(2000);
   l_enable_sec_groups    varchar2(2000) default null;
   l_sec_group_id         fnd_security_groups.security_group_id%type := null;
   l_out_func_sec_excl_tbl   hr_user_acct_utility.func_sec_excl_tbl;

   l_proc                varchar2(72) := g_package||'create_user_details';

   cursor  lc_get_sec_group_id
  is
  select  fsg.security_group_id
  from    fnd_security_groups fsg
  where   fsg.security_group_key = decode(p_business_group_id,0, 'STANDARD',to_char(p_business_group_id));
  --

begin
--
  hr_utility.set_location('Entering:'|| l_proc, 10);

  savepoint create_user_details;
  p_api_error := false;

 /************************************************************/
 /*When this procedure gets called from create_user_details via
 update_user_details(i.e userid/password getting created from
 user page on pressing next  after typing in userid/password),
 the responsibility that will get attached to this new user is
 the value of the profile 'BEN_NEW_USER_RESP_PROFILE'.

 But if it's decided to generate user/pswd instead of typing it
 in user page, by calling update_user_details(passing all
 parameters as null) on pressing next
 button,putting logic in the hooks then customer can pass respo-
 nsibility_id and responsibility_application_id via global variables
 defined in ben_process_user_utility package header.The value of
 the global variables will be copied to the parameter for fnd_user_pkg.
 createuserid and fnd_user_resp_groups_api and fnd_resp_functions api.

 Also we have taken care of the fact that username,password,
 start_date,end_date,last_logon_date,password_date,password_
 accesses_left,password_lifespan_accesses,password_lifespan_days,
 email_address,fax,description,employee_id can be passed to
 us from hooks via global variables in ben_process_user_utility
 package header.*/

 /************************************************************/

  -- Clear the global record variables first.  Otherwise,these variables
  -- may retain values from previous executions.
  --

    ben_process_user_utility.g_fnd_user_record := g_void_fnd_user_rec;
    ben_process_user_utility.g_fnd_resp_record := g_void_fnd_resp_rec;

  prflvalue := fnd_profile.value('BEN_NEW_USER_RESP_PROFILE');
  if prflvalue is not null  and
     p_responsibility_id is null and
     p_respons_application_id is null then
     l_respons_id := substr(prflvalue,1,length(prflvalue)-3);
     l_respons_appl_id := substr(prflvalue,length(prflvalue)-2);
  elsif p_responsibility_id is not null and
        p_respons_application_id is not null then
     l_respons_id := p_responsibility_id;
     l_respons_appl_id := p_respons_application_id;
  end if;

  /*if p_employee_id is null then
  if ((hr_process_person_ss.g_session_id is not null) and
     (hr_process_person_ss.g_session_id = ICX_SEC.G_SESSION_ID))
  and hr_process_person_ss.g_person_id is not null
  then
  --if hr_process_person_ss.g_person_id is not null then

     l_employee_id := hr_process_person_ss.g_person_id;
  end if;
  else*/
  if p_employee_id is not null then
     l_employee_id := p_employee_id;
  end if;

  -- Truncate the time portion from all date parameters
  -- which are passed in.

  l_start_date        := trunc(p_start_date);
  l_end_date          := trunc(p_end_date);
  l_last_logon_date   := trunc(p_last_logon_date);
  l_password_date     := trunc(p_password_date);


  --<<before process hook>>

   -- Start of API User Hook for the before hook of create_user_details

   -- Users can use this hook to return username,password,responsibilities.
   --
  begin
   hr_utility.set_location('Calling ben_process_user_ss_bk1.create_user_details_b', 12);

   ben_process_user_ss_bk1.create_user_details_b
           (p_user_name                 => p_user_name
           ,p_owner                     => p_owner
           ,p_unencrypted_password      => p_unencrypted_password
           ,p_session_number            => p_session_number
           ,p_start_date                => l_start_date
           ,p_end_date                  => l_end_date
           ,p_last_logon_date           => l_last_logon_date
           ,p_description               => p_description
           ,p_password_date             => l_password_date
           ,p_password_accesses_left    => p_password_accesses_left
           ,p_password_lifespan_accesses=> p_password_lifespan_accesses
           ,p_password_lifespan_days    => p_password_lifespan_days
           ,p_employee_id               => p_employee_id
           ,p_email_address             => p_email_address
           ,p_fax                       => p_fax
           ,p_customer_id               => p_customer_id
           ,p_supplier_id               => p_supplier_id
           ,p_responsibility_id         => nvl(p_responsibility_id,l_respons_id)
           ,p_respons_application_id    => nvl(p_respons_application_id,l_respons_appl_id)
           ,p_business_group_id         => p_business_group_id
           );

    hr_utility.set_location('After calling ben_process_user_bk1.create_user_details_b'
                            ,14);

  EXCEPTION
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_USER_DETAILS'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_user_details
    --
  end;
  --

  l_user_id := fnd_user_pkg.createuserid
           (x_user_name                 => nvl(ben_process_user_utility.g_fnd_user_record.user_name,p_user_name)
           ,x_owner                     => p_owner
           ,x_unencrypted_password      => nvl(ben_process_user_utility.g_fnd_user_record.password,p_unencrypted_password)
           ,x_start_date                => nvl(ben_process_user_utility.g_fnd_user_record.start_date,p_start_date)
           ,x_end_date                  => nvl(ben_process_user_utility.g_fnd_user_record.end_date,p_end_date)
           ,x_last_logon_date           => nvl(ben_process_user_utility.g_fnd_user_record.last_logon_date,p_last_logon_date)
           ,x_description               => nvl(ben_process_user_utility.g_fnd_user_record.description,p_description)
           ,x_password_date             => nvl(ben_process_user_utility.g_fnd_user_record.password_date,p_password_date)
           ,x_password_accesses_left    => nvl(ben_process_user_utility.g_fnd_user_record.password_accesses_left,p_password_accesses_left)
           ,x_password_lifespan_accesses=> nvl(ben_process_user_utility.g_fnd_user_record.password_lifespan_accesses,p_password_lifespan_accesses)
           ,x_password_lifespan_days    => nvl(ben_process_user_utility.g_fnd_user_record.password_lifespan_days,p_password_lifespan_days)
           ,x_employee_id               => nvl(ben_process_user_utility.g_fnd_user_record.employee_id,l_employee_id)
           ,x_email_address             => nvl(ben_process_user_utility.g_fnd_user_record.email_address,p_email_address)
           ,x_fax                       => nvl(ben_process_user_utility.g_fnd_user_record.fax,p_fax)
           ,x_customer_id               => nvl(ben_process_user_utility.g_fnd_user_record.customer_id,p_customer_id)
           ,x_supplier_id               => nvl(ben_process_user_utility.g_fnd_user_record.supplier_id,p_supplier_id)
           );
--

  if (l_respons_id is not null or ben_process_user_utility.g_fnd_resp_record.responsibility_id is not null)
  and (l_respons_appl_id is not null or ben_process_user_utility.g_fnd_resp_record.respons_application_id is not null) then
    --
       -- Get the profile option value for 'ENABLE_SECURITY_GROUPS'
       -- Use value_specific because you want the value of the resp being
       -- assigned, not the resp you used to login.
       --
       l_enable_sec_groups := nvl(fnd_profile_server.value_specific(
                                         'ENABLE_SECURITY_GROUPS'
                                        ,l_user_id
                                        , nvl(ben_process_user_utility.g_fnd_resp_record.responsibility_id,l_respons_id)
                                        , nvl(ben_process_user_utility.g_fnd_resp_record.respons_application_id,l_respons_appl_id))
                                    ,'N');

       if l_enable_sec_groups = 'N' then

          hr_utility.set_location (l_proc ||
                ' before create_fnd_user_resp_groups', 50);
          --
          -- **********************************************
          -- Create the new fnd_user_resp_groups record
          -- **********************************************
	     -- NOTE: Only insert a row into fnd_user_resp_groups
	     --       when the profile option 'ENABLE_SECURITY_GROUPS'
	     --       is 'N'.
             --
          fnd_user_resp_groups_api.insert_assignment(
           user_id                       => l_user_id
          ,responsibility_id             => nvl(ben_process_user_utility.g_fnd_resp_record.responsibility_id,l_respons_id)
          ,responsibility_application_id => nvl(ben_process_user_utility.g_fnd_resp_record.respons_application_id,l_respons_appl_id)
          ,security_group_id             => 0
          ,start_date                    => nvl(ben_process_user_utility.g_fnd_user_record.start_date,p_start_date)
          ,end_date                      => nvl(ben_process_user_utility.g_fnd_user_record.end_date,p_end_date)
          ,description                   => null
          );

      else
          -- 'ENABLE_SECURITY_GROUPS' = 'Y'; customers have the option to insert
          -- into fnd_user_resp_groups only if view-all security profile of the
          -- employee's business group is to be used.
          -- If a restricted security
          -- profile is to be used, then we must call hrasprhi.pkb which will
          -- insert one row into per_sec_profile_assignments as well as to
          -- fnd_user_resp_groups.

          -- Insert into fnd_user_resp_groups only
          -- get the security_group_id for the employee's business_group_id
        if (ben_process_user_utility.g_fnd_resp_record.security_group_id is null
           or ben_process_user_utility.g_fnd_resp_record.security_profile_id is null) then
          open lc_get_sec_group_id;
          fetch lc_get_sec_group_id into l_sec_group_id;
          if lc_get_sec_group_id%NOTFOUND then

                close lc_get_sec_group_id;
                fnd_message.set_name('FND', 'SQL_NO_DATA_FOUND');
                fnd_message.set_token('TABLE', 'FND_SECURITY_GROUPS');
                fnd_message.set_token('COLUMN', 'SECURITY_GROUP_KEY');
                fnd_message.set_token('VALUE', to_char(p_business_group_id));
                hr_utility.raise_error;
          else
                close lc_get_sec_group_id;
          end if;

             hr_utility.set_location (l_proc ||
                ' before create_fnd_user_resp_groups', 53);
             --
          fnd_user_resp_groups_api.insert_assignment(
           user_id                       => l_user_id
          ,responsibility_id             => nvl(ben_process_user_utility.g_fnd_resp_record.responsibility_id,l_respons_id)
          ,responsibility_application_id => nvl(ben_process_user_utility.g_fnd_resp_record.respons_application_id,l_respons_appl_id)
          ,security_group_id             => l_sec_group_id
          ,start_date                    => nvl(ben_process_user_utility.g_fnd_user_record.start_date,p_start_date)
          ,end_date                      => nvl(ben_process_user_utility.g_fnd_user_record.end_date,p_end_date)
          ,description                   => null
          );

         hr_utility.set_location (l_proc ||
                ' after create_fnd_user_resp_groups', 54);
             --
       else
             -- sec_group_id and sec_profile_id are filled in
             -- call peasprhi.pkb to insert into per_sec_profile_assignments
             -- as well as fnd_user_resp_groups.

	     hr_utility.set_location (l_proc ||
				 ' before create_sec_profile_asg', 56);

             -- Insert this row into per_sec_profile_assignments
             create_sec_profile_asg
                (p_user_id            => l_user_id
                ,p_sec_group_id       => ben_process_user_utility.g_fnd_resp_record.security_group_id
                ,p_sec_profile_id     => ben_process_user_utility.g_fnd_resp_record.security_profile_id
                ,p_resp_id            => nvl(ben_process_user_utility.g_fnd_resp_record.responsibility_id,l_respons_id)
                ,p_resp_app_id        => nvl(ben_process_user_utility.g_fnd_resp_record.respons_application_id,l_respons_appl_id)
                ,p_start_date         => nvl(ben_process_user_utility.g_fnd_user_record.start_date,p_start_date)
                ,p_end_date           => nvl(ben_process_user_utility.g_fnd_user_record.end_date,p_end_date)
                );

             hr_utility.set_location (l_proc ||
                                 ' after create_sec_profile_asg', 57);
          end if;
      end if;
  end if;
--
--

  <<add_func_security_exclusion>>
  -- ************************************************
  -- Now create the fnd_resp_functions
  -- ************************************************

  hr_utility.set_location(l_proc, 60);
  --
  /*add_func_sec_exclusion_rules
     (p_resp_id            => nvl(ben_process_user_utility.g_fnd_resp_record.responsibility_id,l_respons_id)
     ,p_resp_app_id        => nvl(ben_process_user_utility.g_fnd_resp_record.respons_application_id,l_respons_appl_id));
   */
  --
--

--<<after_process_hook>>

  BEGIN
    --
    -- Start of API User Hook for the after hook of create_user_details
   hr_utility.set_location('Calling ben_proocess_user_ss_bk1.create_user_details_a', 12);

   ben_process_user_ss_bk1.create_user_details_a
           (p_user_name                 => nvl(ben_process_user_utility.g_fnd_user_record.user_name,p_user_name)
           ,p_owner                     => p_owner
           ,p_unencrypted_password      => nvl(ben_process_user_utility.g_fnd_user_record.password,p_unencrypted_password)
           ,p_session_number            => p_session_number
           ,p_start_date                => nvl(ben_process_user_utility.g_fnd_user_record.start_date,p_start_date)
           ,p_end_date                  => nvl(ben_process_user_utility.g_fnd_user_record.end_date,p_end_date)
           ,p_last_logon_date           => nvl(ben_process_user_utility.g_fnd_user_record.last_logon_date,p_last_logon_date)
           ,p_description               => nvl(ben_process_user_utility.g_fnd_user_record.description,p_description)
           ,p_password_date             => nvl(ben_process_user_utility.g_fnd_user_record.password_date,p_password_date)
           ,p_password_accesses_left    => nvl(ben_process_user_utility.g_fnd_user_record.password_accesses_left,p_password_accesses_left)
           ,p_password_lifespan_accesses=> nvl(ben_process_user_utility.g_fnd_user_record.password_lifespan_accesses,p_password_lifespan_accesses)
           ,p_password_lifespan_days    => nvl(ben_process_user_utility.g_fnd_user_record.password_lifespan_days,p_password_lifespan_days)
           ,p_employee_id               => nvl(ben_process_user_utility.g_fnd_user_record.employee_id,l_employee_id)
           ,p_email_address             => nvl(ben_process_user_utility.g_fnd_user_record.email_address,p_email_address)
           ,p_fax                       => nvl(ben_process_user_utility.g_fnd_user_record.fax,p_fax)
           ,p_customer_id               => nvl(ben_process_user_utility.g_fnd_user_record.customer_id,p_customer_id)
           ,p_supplier_id               => nvl(ben_process_user_utility.g_fnd_user_record.supplier_id,p_supplier_id)
           ,p_responsibility_id         => nvl(ben_process_user_utility.g_fnd_resp_record.responsibility_id,l_respons_id)
           ,p_respons_application_id    => nvl(ben_process_user_utility.g_fnd_resp_record.respons_application_id,l_respons_appl_id)
           ,p_user_id                   => l_user_id
           ,p_business_group_id         => p_business_group_id
           );

EXCEPTION
    WHEN hr_api.cannot_find_prog_unit THEN
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_USER_DETAILS'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_user_acct
    --
  end;
  --

  if p_validate then
    ROLLBACK TO create_user_details;
    p_user_id := null;
    p_api_error := false;
    --raise hr_api.validate_enabled;
  end if;
  --
  -- Set all output arguments
  --
    p_user_id := l_user_id;
    p_api_error := false;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 80);
exception
  --
  when hr_api.validate_enabled then
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO create_user_details;
    p_user_id := null;
    p_api_error := false;
  when others then
    p_user_id := null;
    p_api_error := true;
    fnd_msg_pub.add;
  --

end create_user_details;
--
-- ---------------------------------------------------------------------------
-- ------------------------- < update_user_details > -------------------------
-- ---------------------------------------------------------------------------
-- Purpose: This procedure will perform validations when a user presses Next
--          on user page or on the Review page.
--          Either case, the data will be saved to the transaction table.
--          If this procedure is invoked from Review page, it will first check
--          that if a transaction already exists.  If it does, it will update
--          the current transaction record.
--          NOTE: The p_validate_mode cannot be in boolean because this
--                procedure will be called from Java which has a different
--                boolean value from pl/sql.
-- ---------------------------------------------------------------------------
procedure update_user_details
  (p_item_type                    in varchar2
  ,p_item_key                     in varchar2
  ,p_actid                        in number
  ,p_login_person_id              in number
  ,p_process_section_name         in varchar2
  ,p_review_page_region_code      in varchar2
  ,p_user_name                    in varchar2
  ,p_owner                        in varchar2
  ,p_unencrypted_password         in varchar2
  ,p_session_number               in number
  ,p_start_date                   in date
  ,p_end_date                     in date
  ,p_last_logon_date              in date
  ,p_description                  in varchar2
  ,p_password_date                in date
  ,p_password_accesses_left       in number
  ,p_password_lifespan_accesses   in number
  ,p_password_lifespan_days       in number
  ,p_employee_id                  in number
  ,p_email_address                in varchar2
  ,p_fax                          in varchar2
  ,p_customer_id                  in number
  ,p_supplier_id                  in number
  ,p_business_group_id            in number
  ) is
 --
  l_transaction_table             hr_transaction_ss.transaction_table;
  l_api_error                     boolean;
  l_transaction_id                number := null;
  l_transaction_step_id           number := null;
  l_respons_id                    number := null;
  l_respons_appl_id               number := null;
  l_result                        varchar2(100);
  l_transaction_step              varchar2(100) default null;
  l_trans_obj_vers_num            number;
  l_user_id                       number;
  l_employee_id                   number default null;
  l_count                         number := 1;
  prflvalue  varchar2(2000);
  l_user_pswd             fnd_user.encrypted_user_password%TYPE;

begin
  --
    --savepoint create_user_details;
    --
    prflvalue := fnd_profile.value('BEN_NEW_USER_RESP_PROFILE');
    if prflvalue is not null
    then
       l_respons_id := substr(prflvalue,1,length(prflvalue)-3);
       l_respons_appl_id := substr(prflvalue,length(prflvalue)-2);
    end if;
    /*if p_employee_id is null then
      if ((hr_process_person_ss.g_session_id is not null) and
     (hr_process_person_ss.g_session_id = ICX_SEC.G_SESSION_ID))
      and hr_process_person_ss.g_person_id is not null then
         l_employee_id := hr_process_person_ss.g_person_id;
       end if;
     else*/
     if p_employee_id is not null then
        l_employee_id := p_employee_id;
     end if;

      -- Getting unencrypted password

     l_user_pswd := wf_engine.GetItemAttrText
                    (itemtype   => p_item_type,
                     itemkey    => p_item_key,
                     aname      =>'USER_ACCOUNT_INFO');

     -- Setting wf attribute 'USER_ACCOUNT_INFO' to null

/*     wf_engine.SetItemAttrText (itemtype => p_item_type,
                           itemkey  => p_item_key,
                           aname    => 'USER_ACCOUNT_INFO',
                           avalue   => null);

*/
    hr_utility.set_location('Entering'||g_package, 5);
     create_user_details
           (p_validate                    => true
           ,p_user_name                   => p_user_name
           ,p_owner                       => p_owner
           ,p_unencrypted_password        => l_user_pswd
           ,p_session_number              => p_session_number
           ,p_start_date                  => p_start_date
           ,p_end_date                    => p_end_date
           ,p_last_logon_date             => p_last_logon_date
           ,p_description                 => p_description
           ,p_password_date               => p_password_date
           ,p_password_accesses_left      => p_password_accesses_left
           ,p_password_lifespan_accesses  => p_password_lifespan_accesses
           ,p_password_lifespan_days      => p_password_lifespan_days
           ,p_employee_id                 => p_employee_id
           ,p_email_address               => p_email_address
           ,p_fax                         => p_fax
           ,p_customer_id                 => p_customer_id
           ,p_supplier_id                 => p_supplier_id
           ,p_business_group_id           => p_business_group_id
           ,p_responsibility_id           => l_respons_id
           ,p_respons_application_id      => l_respons_appl_id
           ,p_api_error                   => l_api_error
           ,p_user_id                     => l_user_id
           );
--
    --hr_utility.set_location('Entering'||g_package||'we are hereeeeeeeeee1', 5);
   if l_api_error then
     raise g_data_error;
  end if;
    --hr_utility.set_location('Entering'||g_package||'we are hereeeeeeeeee2', 5);
--
   --rollback to create_user_details;
----------------------------------------------------------------------
-- Now save the data to transaction table.  When coming from user page
-- first time, a transaction step won't exist.  We'll  have to save to
-- transaction table.  Then when the review page is displayed user can press back to
-- go back to user page and enters some more changes or correct whatever he
-- just entered At this point, a transaction step already exists.
-- Before saving to the transaction table, we need to see if a transaction step
-- already exists or not.  This could happen when a user enters data to user
-- Page --> Next --> Next -->...-->Review Page --> Back to usr page to
-- correct wrong entry or to make further changes --> Next -->Next -->...--> Review Page.
-- Use the activity_id to check if a transaction step already
-- exists.
-------------------------------------------------------------------------------
--
    hr_utility.set_location('Entering next line'||g_package, 6);
  l_transaction_id := hr_transaction_ss.get_transaction_id
                     (p_item_type   => p_item_type
                     ,p_item_key    => p_item_key);
--
    hr_utility.set_location('Entering next line line'||g_package, 7);
  if l_transaction_id is null then
     hr_transaction_ss.start_transaction
        (itemtype   => p_item_type
        ,itemkey    => p_item_key
        ,actid      => p_actid
        ,funmode    => 'RUN'
        ,p_login_person_id => p_login_person_id
        ,result     => l_result);
     --
    hr_utility.set_location('Entering next line line'||g_package, 8);
     l_transaction_id := hr_transaction_ss.get_transaction_id
                     (p_item_type   => p_item_type
                     ,p_item_key    => p_item_key);
  end if;
  --
    --hr_utility.set_location('Entering'||g_package||'we are hereeeeeeeeee3', 5);
  l_transaction_step_id := get_transaction_step_id
                          (p_item_type              => p_item_type
                          ,p_item_key               => p_item_key
                          ,p_activity_id            => p_actid);
 --
  if l_transaction_step_id is null then
    --hr_utility.set_location('Entering'||g_package||'we are hereeeeeeeeee4', 5);
    hr_transaction_api.create_transaction_step
     (p_validate              => false
     ,p_creator_person_id     => p_login_person_id
     ,p_transaction_id        => l_transaction_id
     ,p_api_name              => upper(g_package || 'process_api')
     ,p_item_type             => p_item_type
     ,p_item_key              => p_item_key
     ,p_activity_id           => p_actid
     ,p_transaction_step_id   => l_transaction_step_id
     ,p_object_version_number => l_trans_obj_vers_num);
  end if;
  --
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
  --hr_utility.set_location('Entering'||g_package||'we are hereeeeeeeeee5', 5);
  l_transaction_table(l_count).param_name := 'P_PROCESS_SECTION_NAME';
  l_transaction_table(l_count).param_value := p_process_section_name;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
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
  l_transaction_table(l_count).param_name := 'P_USER_NAME';
  l_transaction_table(l_count).param_value := nvl(ben_process_user_utility.g_fnd_user_record.user_name,p_user_name);
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_OWNER';
  l_transaction_table(l_count).param_value := p_owner;
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_ENCRYPTED_PASSWORD';
  l_transaction_table(l_count).param_value := nvl(ben_process_user_utility.g_fnd_user_record.password,p_unencrypted_password);
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_SESSION_NUMBER';
  l_transaction_table(l_count).param_value := p_session_number;
  l_transaction_table(l_count).param_data_type := 'NUMBER';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_START_DATE';
  l_transaction_table(l_count).param_value := nvl(to_char(ben_process_user_utility.g_fnd_user_record.start_date,hr_transaction_ss.g_date_format),to_char(p_start_date,
                                              hr_transaction_ss.g_date_format));
  l_transaction_table(l_count).param_data_type := 'DATE';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_END_DATE';
  l_transaction_table(l_count).param_value := nvl(to_char(ben_process_user_utility.g_fnd_user_record.end_date,hr_transaction_ss.g_date_format),to_char(p_end_date,
                                              hr_transaction_ss.g_date_format));
  l_transaction_table(l_count).param_data_type := 'DATE';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_LAST_LOGON_DATE';
  l_transaction_table(l_count).param_value := nvl(to_char(ben_process_user_utility.g_fnd_user_record.last_logon_date,hr_transaction_ss.g_date_format),to_char(p_last_logon_date,
                                              hr_transaction_ss.g_date_format));
  l_transaction_table(l_count).param_data_type := 'DATE';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_DESCRIPTION';
  l_transaction_table(l_count).param_value := nvl(ben_process_user_utility.g_fnd_user_record.description,p_description);
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_PASSWORD_DATE';
  l_transaction_table(l_count).param_value := nvl(to_char(ben_process_user_utility.g_fnd_user_record.password_date,hr_transaction_ss.g_date_format),to_char(p_password_date,
                                              hr_transaction_ss.g_date_format));
  l_transaction_table(l_count).param_data_type := 'DATE';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_PASSWORD_ACCESSES_LEFT';
  l_transaction_table(l_count).param_value := nvl(ben_process_user_utility.g_fnd_user_record.password_accesses_left,p_password_accesses_left);
  l_transaction_table(l_count).param_data_type := 'NUMBER';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_PASSWORD_LIFESPAN_ACCESSES';
  l_transaction_table(l_count).param_value := nvl(ben_process_user_utility.g_fnd_user_record.password_lifespan_accesses,p_password_lifespan_accesses);
  l_transaction_table(l_count).param_data_type := 'NUMBER';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_PASSWORD_LIFESPAN_DAYS';
  l_transaction_table(l_count).param_value := nvl(ben_process_user_utility.g_fnd_user_record.password_lifespan_days,p_password_lifespan_days);
  l_transaction_table(l_count).param_data_type := 'NUMBER';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_EMPLOYEE_ID';
  l_transaction_table(l_count).param_value := nvl(ben_process_user_utility.g_fnd_user_record.employee_id,l_employee_id);
  l_transaction_table(l_count).param_data_type := 'NUMBER';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_EMAIL_ADDRESS';
  l_transaction_table(l_count).param_value := nvl(ben_process_user_utility.g_fnd_user_record.email_address,p_email_address);
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_FAX';
  l_transaction_table(l_count).param_value := nvl(ben_process_user_utility.g_fnd_user_record.fax,p_fax);
  l_transaction_table(l_count).param_data_type := 'VARCHAR2';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_CUSTOMER_ID';
  l_transaction_table(l_count).param_value := nvl(ben_process_user_utility.g_fnd_user_record.customer_id,p_customer_id);
  l_transaction_table(l_count).param_data_type := 'NUMBER';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_SUPPLIER_ID';
  l_transaction_table(l_count).param_value := nvl(ben_process_user_utility.g_fnd_user_record.supplier_id,p_supplier_id);
  l_transaction_table(l_count).param_data_type := 'NUMBER';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_BUSINESS_GROUP_ID';
  l_transaction_table(l_count).param_value := p_business_group_id;
  l_transaction_table(l_count).param_data_type := 'NUMBER';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_RESPONSIBILITY_ID';
  l_transaction_table(l_count).param_value := nvl(ben_process_user_utility.g_fnd_resp_record.responsibility_id,l_respons_id);
  l_transaction_table(l_count).param_data_type := 'NUMBER';
--
  l_count := l_count + 1;
  l_transaction_table(l_count).param_name := 'P_RESPONSIBILITY_APPL_ID';
  l_transaction_table(l_count).param_value := nvl(ben_process_user_utility.g_fnd_resp_record.respons_application_id,l_respons_appl_id);
  l_transaction_table(l_count).param_data_type := 'NUMBER';
--
--
  --hr_utility.set_location('Entering'||g_package||'we are hereeeeeeeeee7', 5);
  hr_transaction_ss.save_transaction_step
                (p_item_type           => p_item_type
                ,p_item_key            => p_item_key
                ,p_actid               => p_actid
                ,p_login_person_id     => p_login_person_id
                ,p_transaction_step_id => l_transaction_step_id
                ,p_api_name            => upper(g_package || 'process_api')
                ,p_transaction_data    => l_transaction_table);
    --hr_utility.set_location('Entering'||g_package||'we are hereeeeeeeeee8', 5);
    --hr_utility.set_location('Entering'||g_package||'we are hereeeeeeeeee9'||l_transaction_step_id, 55);
--
   if p_employee_id is null then
    --hr_utility.set_location('Entering'||g_package||'we are hereeeeeeeeee10', 5);
      wf_engine.SetItemAttrText (itemtype => p_item_type,
                           itemkey  => p_item_key,
                           aname    => 'USER_TRANSACTION_STEP',
                           avalue   => to_char(l_transaction_step_id));
   end if;
     -- bug 3728862, set the USER_ACCOUNT_INFO attr. here instead of setting from UserReviewCO
     wf_engine.SetItemAttrText (itemtype => p_item_type,
                           itemkey  => p_item_key,
                           aname    => 'USER_ACCOUNT_INFO',
                           avalue   => nvl(ben_process_user_utility.g_fnd_user_record.password,l_user_pswd));
exception
  when g_data_error then
   null;

  when others then
     fnd_msg_pub.add;

end update_user_details;
--
-- ---------------------------------------------------------------------------
-- ----------------------------- < process_api > -----------------------------
-- ---------------------------------------------------------------------------
-- Purpose: This procedure will be invoked in workflow notification
--          when an approver approves all the changes.  This procedure
--          will call the api to update to the database with p_validate
--          equal to false.
-- ---------------------------------------------------------------------------
procedure process_api
          (p_validate IN BOOLEAN DEFAULT FALSE
          ,p_transaction_step_id IN NUMBER) is
  --
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
  prflvalue                                varchar2(2000);
  l_item_type                        wf_items.item_type%type default null;
  l_item_key                         wf_items.item_key%type default null;
  l_transaction_step_id              number default null;
  --
begin
  --

  l_employee_id := hr_transaction_api.get_number_value
                          (p_transaction_step_id => p_transaction_step_id
                          ,p_name => 'P_EMPLOYEE_ID');


   if l_employee_id is null then

       null;

   else

      get_user_data_from_tt(
   p_transaction_step_id          => p_transaction_step_id
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
  --
   l_item_type := hr_transaction_api.get_varchar2_value
                          (p_transaction_step_id => p_transaction_step_id
                          ,p_name => 'P_ITEM_TYPE');

  l_item_key := hr_transaction_api.get_varchar2_value
                          (p_transaction_step_id => p_transaction_step_id
                          ,p_name => 'P_ITEM_KEY');

  l_user_pswd := wf_engine.GetItemAttrText
                    (itemtype   => l_item_type,
                     itemkey    => l_item_key,
                     aname      =>'USER_ACCOUNT_INFO');

/*  wf_engine.SetItemAttrText (itemtype => l_item_type,
                           itemkey  => l_item_key,
                           aname    => 'USER_ACCOUNT_INFO',
                           avalue   => null);
*/
    --hr_utility.set_location('Entering'||g_package, 5);
     create_user_details
           (p_validate                    => false
           ,p_user_name                   => l_user_name
           ,p_owner                       => l_owner
           ,p_unencrypted_password        => trim(l_user_pswd)
           ,p_session_number              => l_session_number
           ,p_start_date                  => l_start_date
           ,p_end_date                    => l_end_date
           ,p_last_logon_date             => l_last_logon_date
           ,p_description                 => l_pswd_hint
           ,p_password_date               => l_password_date
           ,p_password_accesses_left      => l_password_accesses_left
           ,p_password_lifespan_accesses  => l_password_lifespan_accesses
           ,p_password_lifespan_days      => l_password_lifespan_days
           ,p_employee_id                 => l_employee_id
           ,p_email_address               => l_email_address
           ,p_fax                         => l_fax
           ,p_customer_id                 => l_customer_id
           ,p_supplier_id                 => l_supplier_id
           ,p_business_group_id           => l_business_group_id
           ,p_responsibility_id           => l_respons_id
           ,p_respons_application_id      => l_respons_appl_id
           ,p_api_error                   => l_api_error
           ,p_user_id                     => l_user_id
           );

  -- bug 3728862, set the USER_ACCOUNT_INFO attr. here instead of setting from UserReviewCO
  wf_engine.SetItemAttrText (itemtype => l_item_type,
   		     itemkey  => l_item_key,
		     aname    => 'USER_ACCOUNT_INFO',
		     avalue   => nvl(ben_process_user_utility.g_fnd_user_record.password,l_user_pswd));

--
    --hr_utility.set_location('Entering'||g_package||'we are hereeeeeeeeee1', 5);
   if l_api_error then
     raise g_data_error;
  end if;
  end if;
--
end process_api;
--

end ben_process_user_ss_api;
--

/

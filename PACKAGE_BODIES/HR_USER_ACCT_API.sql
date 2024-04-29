--------------------------------------------------------
--  DDL for Package Body HR_USER_ACCT_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_USER_ACCT_API" as
/* $Header: hrusrapi.pkb 120.3.12000000.2 2007/02/14 08:14:27 amunsi ship $ */
--
-- Private Global Variables
--
--
g_package                    varchar2(33) := 'hr_user_acct_api.';
g_api_vers                   constant number := 1.0;
g_empty_fnd_user_rec         hr_user_acct_utility.fnd_user_rec;
g_emtpy_fnd_resp_tbl         hr_user_acct_utility.fnd_responsibility_tbl;
g_emtpy_fnd_prof_opt_val_tbl hr_user_acct_utility.fnd_profile_opt_val_tbl;
g_empty_fnd_resp_func_tbl    hr_user_acct_utility.fnd_resp_functions_tbl;
g_empty_func_sec_excl_tbl    hr_user_acct_utility.func_sec_excl_tbl;
--
-- ----------------------------------------------------------------------------
-- |-----------------------< create_user_acct >------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE create_user_acct
  (p_validate                      in     boolean  default false
  ,p_person_id                     in     number
  ,p_per_effective_start_date      in     date     default null
  ,p_per_effective_end_date        in     date     default null
  ,p_assignment_id                 in     number   default null
  ,p_asg_effective_start_date      in     date     default null
  ,p_asg_effective_end_date        in     date     default null
  ,p_business_group_id             in     number
  ,p_date_from                     in     date     default null
  ,p_date_to                       in     date     default null
  ,p_hire_date                     in     date     default null
  ,p_org_structure_id              in     number   default null
  ,p_org_structure_vers_id         in     number   default null
  ,p_parent_org_id                 in     number   default null
  ,p_single_org_id                 in     number   default null
  ,p_run_type                      in     varchar2 default null
  ,p_user_id                       out nocopy    number
  )
is
  --
  -- Declare cursors and local variables
  -- The following two variables must be declared ahead of the cursors because
  -- they are referenced inside the cursors.
  l_exist_resp_id       fnd_responsibility.responsibility_id%type;
  l_exist_resp_app_id   fnd_responsibility.application_id%type;
  --
  --
  CURSOR  lc_get_existing_fnd_resp
  IS
  SELECT  fr.responsibility_id
         ,frtl.responsibility_name
         ,fr.responsibility_key
         ,fr.application_id             resp_app_id
         ,frtl.description
         ,fr.start_date
         ,fr.end_date
         ,fdg.data_group_name
         ,fr.data_group_application_id  data_group_app_id
         ,fm.menu_name
         ,frg.request_group_name
         ,fr.request_group_id
         ,fr.group_application_id       req_group_app_id
         ,fr.version
         ,fr.web_host_name
         ,fr.web_agent_name
  FROM    fnd_responsibility           fr
         ,fnd_responsibility_tl        frtl
         ,fnd_menus                    fm
         ,fnd_data_groups              fdg
         ,fnd_request_groups           frg
  WHERE   fr.responsibility_id = l_exist_resp_id
  AND     fr.application_id = l_exist_resp_app_id
  AND     fr.responsibility_id = frtl.responsibility_id
  AND     fr.data_group_id = fdg.data_group_id
  AND     fr.menu_id = fm.menu_id
  AND     fr.request_group_id = frg.request_group_id(+)
--BUG 3648732
  AND     fr.application_id = frtl.application_id
  AND     fr.application_id   = frg.application_id(+);
  --
  --
  CURSOR  lc_fnd_resp_exists (p_resp_key   in varchar2)
  IS
  SELECT  responsibility_id, application_id
  FROM    fnd_responsibility
  WHERE   responsibility_key = p_resp_key;
  --
  CURSOR  lc_get_sec_group_id
  IS
  SELECT  security_group_id
  FROM    fnd_security_groups
  WHERE   security_group_key = to_char(p_business_group_id);
  --
  l_proc                varchar2(72) := g_package||'create_user_acct';
  l_hire_date           date default null;
  l_date_from           date default null;
  l_date_to             date default null;
  --
  l_user_name           fnd_user.user_name%type default null;
  l_fnd_user_start_date fnd_user.start_date%type default null;
  l_fnd_user_end_date   fnd_user.end_date%type default null;
  l_email_address       fnd_user.email_address%type default null;
  l_fax                 fnd_user.email_address%type default null;
  l_customer_id         fnd_user.customer_id%type default null;
  l_description         fnd_user.description%type default null;
  l_language            fnd_profile_option_values.profile_option_value%type
                        default null;
  l_user_id             number default null;
--
  l_fnd_resp_rec        hr_user_acct_utility.fnd_responsibility_rec;
  l_responsibility_id   fnd_responsibility.responsibility_id%type := null;
  l_responsibility_key  fnd_responsibility.responsibility_key%type := null;
  l_user_resp_start_date  fnd_user_resp_groups.start_date%type;
  l_user_resp_end_date    fnd_user_resp_groups.end_date%type;
  l_user_level_only     boolean default false;
  l_count               number default 0;
  l_prof_opt_val_count  number default 0;
  l_resp_count          number default 0;
  l_resp_func_count     number default 0;
  l_out_profile_opt_val_tbl hr_user_acct_utility.fnd_profile_opt_val_tbl;
  l_out_profile_opt_val_count  number default 0;
  l_profile_value_saved  boolean default null;
  l_msg_text             varchar2(2000) default null;
  l_new_resp_id          fnd_responsibility.responsibility_id%type := null;
  l_temp                 varchar2(2000) default null;
  l_out_func_sec_excl_tbl   hr_user_acct_utility.func_sec_excl_tbl;
  l_old_resp_rec         lc_get_existing_fnd_resp%rowtype;
  l_user_resp_app_id     fnd_responsibility.application_id%type := null;
  l_temp_id              number(15) default null;
  l_status               varchar2(2000) default null;
  l_enable_sec_groups    varchar2(2000) default null;
  l_sec_profile_asg_count   number(15) default null;
  l_sec_group_id         fnd_security_groups.security_group_id%type := null;

--
BEGIN
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint.
  --
  savepoint create_user_acct;
  l_hire_date                   := trunc(p_hire_date);
  l_date_from                   := trunc(p_date_from);
  l_date_to                     := trunc(p_date_to);
  --
  begin
    -- Clear the global record table variables first.  Otherwise,these variables
    -- will retain values from the previous employee.
    --
    hr_user_acct_utility.g_fnd_user_rec := g_empty_fnd_user_rec;
    hr_user_acct_utility.g_fnd_resp_tbl := g_emtpy_fnd_resp_tbl;
    hr_user_acct_utility.g_fnd_profile_opt_val_tbl :=
                                  g_emtpy_fnd_prof_opt_val_tbl;
    hr_user_acct_utility.g_fnd_resp_functions_tbl :=
                                  g_empty_fnd_resp_func_tbl;
    --
    -- Start of API User Hook for the before hook of create_user_acct
    -- The Person ID, per_all_people_f.effective_start_date and
    -- per_all_people_f.effective_end_date along with the concurrent
    -- program's input parameters are passed to the user hooks so
    -- that the user can retrieve the proper person record or
    -- assignment record to determine what user name, password and
    -- the start date for the fnd_users account.  Normally, the start
    -- date for the fnd_users account is the hire date.  But the user
    -- can change it to a later date but not earlier in their user hooks code.
    --
    -- Users should use the create_user_acct_b user hook to
    -- return username, password, responsibilities and profile option values.
    --
    hr_utility.set_location('Calling hr_user_acct_bk1.create_user_acct_b', 12);
    --
    hr_user_acct_bk1.create_user_acct_b
      (p_person_id                    => p_person_id
      ,p_per_effective_start_date     => p_per_effective_start_date
      ,p_per_effective_end_date       => p_per_effective_end_date
	 ,p_assignment_id                => p_assignment_id
      ,p_asg_effective_start_date     => p_asg_effective_start_date
      ,p_asg_effective_end_date       => p_asg_effective_end_date
      ,p_business_group_id            => p_business_group_id
      ,p_date_from                    => l_date_from
      ,p_date_to                      => l_date_to
      ,p_org_structure_id             => p_org_structure_id
      ,p_org_structure_vers_id        => p_org_structure_vers_id
      ,p_parent_org_id                => p_parent_org_id
      ,p_single_org_id                => p_single_org_id
      ,p_run_type                     => p_run_type
      ,p_hire_date                    => l_hire_date
      );

    hr_utility.set_location('After calling hr_user_acct_bk1.create_user_acct_b'
                            ,14);

  EXCEPTION
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_USER_ACCOUNT'
        ,p_hook_type   => 'BP'
        );
    --
    -- End of API User Hook for the before hook of create_fnd_user_resp
    --
  end;
  --
  --
  hr_utility.set_location(l_proc, 20);
  --
  --
  -----------------------------------------------------------------------------
  -- NOTE: User hooks can pass information back to us, such as user name,
  --       password, responsibilities and profile info. via global variables
  --       in the dummy hr_user_acct_utility package header.  We directly
  --       move information from there to the parameters in
  --       create_fnd_user.  Validations will be done in individual business
  --       process, such as create_fnd_user, not at the wrapper level.
  --
  -----------------------------------------------------------------------------
  --
  -- In R11.5, the java program no longer needs the host port information since
  -- the java program is executed within the same session and context.  However,
  -- the fup api still has this parameter as mandatory.  We just pass
  -- null value to the parameter.
  --

  -- Fix 2288014.
  -- Passing password_date to the modified hr_user_acct_internal.create_fnd_user
  -- enabling users to have control over password change after first login.
  --
  hr_user_acct_internal.create_fnd_user
      (p_hire_date                    => l_hire_date
      ,p_user_name                    =>
               hr_user_acct_utility.g_fnd_user_rec.user_name
      ,p_password                     =>
               hr_user_acct_utility.g_fnd_user_rec.password
      ,p_user_start_date              =>
               hr_user_acct_utility.g_fnd_user_rec.start_date
      ,p_user_end_date                =>
               hr_user_acct_utility.g_fnd_user_rec.end_date
      ,p_email_address                =>
               hr_user_acct_utility.g_fnd_user_rec.email_address
      ,p_fax                          =>
               hr_user_acct_utility.g_fnd_user_rec.fax
      ,p_description                  =>
               hr_user_acct_utility.g_fnd_user_rec.description
      ,p_password_date    =>
               hr_user_acct_utility.g_fnd_user_rec.password_date -- Fix 2288014
      ,p_language                     =>
               hr_user_acct_utility.g_fnd_user_rec.language
      ,p_host_port                    => null
      ,p_employee_id                  =>
               hr_user_acct_utility.g_fnd_user_rec.employee_id
      ,p_customer_id                  =>
               hr_user_acct_utility.g_fnd_user_rec.customer_id
      ,p_supplier_id                  =>
               hr_user_acct_utility.g_fnd_user_rec.supplier_id
      ,p_user_id                      => l_user_id
      );
  --
  hr_utility.set_location(l_proc, 30);
  --
  -- Create the fnd_responsibility record
  --
  l_resp_count := hr_user_acct_utility.g_fnd_resp_tbl.count;
  --
  IF l_resp_count < 1
     -- No fnd_user_resp_groups, per_sec_profile_assignments,
     -- function exclusions or profile option values to insert
  THEN
     goto after_process_hook;
  END IF;
  --
  FOR i in 1..l_resp_count
  LOOP
     --
     -- Clear the l_responsibility_id first
     l_responsibility_id := null;
     l_user_resp_app_id := null;

     l_responsibility_key :=
            hr_user_acct_utility.g_fnd_resp_tbl(i).new_resp_key;
     --
     IF hr_user_acct_utility.g_fnd_resp_tbl(i).new_resp_name
        IS NOT NULL
        AND
        hr_user_acct_utility.g_fnd_resp_tbl(i).new_resp_key IS NOT NULL
     THEN
         -- Create a new responsibility,check if using a template responsibility
         IF hr_user_acct_utility.g_fnd_resp_tbl(i).existing_resp_id
            IS NOT NULL
         THEN
            -- That means we want to create a new responsiblity based on an
            -- existing responsibility as template.  We need to read the
            -- template responsibility record first.
            --
               l_exist_resp_id :=
               hr_user_acct_utility.g_fnd_resp_tbl(i).existing_resp_id;
               l_exist_resp_app_id :=
            hr_user_acct_utility.g_fnd_resp_tbl(i).existing_resp_app_id;
               --
               -- read the existing responsibility rec
               --
               OPEN lc_get_existing_fnd_resp;
               FETCH lc_get_existing_fnd_resp into l_old_resp_rec;
               IF lc_get_existing_fnd_resp%NOTFOUND
               THEN
                  CLOSE lc_get_existing_fnd_resp;
                  fnd_message.set_name('FND', 'SQL_NO_DATA_FOUND');
                  fnd_message.set_token('TABLE', 'FND_RESPONSIBILITY');
                  fnd_message.set_token('COLUMN', 'RESPONSIBILITY_ID');
                  fnd_message.set_token('VALUE', to_char(l_exist_resp_id));
                  hr_utility.raise_error;
               ELSE
                  CLOSE lc_get_existing_fnd_resp;
               END IF;

               l_fnd_resp_rec.new_resp_app_id := l_old_resp_rec.resp_app_id ;
               l_fnd_resp_rec.new_resp_description := null;
               l_fnd_resp_rec.new_resp_start_date :=l_old_resp_rec.start_date;
               l_fnd_resp_rec.new_resp_end_date := null;
               l_fnd_resp_rec.new_resp_data_group_name :=
                    l_old_resp_rec.data_group_name;
               l_fnd_resp_rec.new_resp_data_grp_app_id :=
                    l_old_resp_rec.data_group_app_id;
               l_fnd_resp_rec.new_resp_menu_name := l_old_resp_rec.menu_name;
               l_fnd_resp_rec.new_resp_request_group_name :=
                    l_old_resp_rec.request_group_name;
               l_fnd_resp_rec.new_resp_req_grp_app_id :=
                    l_old_resp_rec.req_group_app_id;
               l_fnd_resp_rec.new_resp_version := l_old_resp_rec.version;
               l_fnd_resp_rec.new_resp_web_host_name :=
                    l_old_resp_rec.web_host_name;
               l_fnd_resp_rec.new_resp_web_agent_name :=
                    l_old_resp_rec.web_agent_name;
                 --
               --
         END IF;  -- existing_resp_id is not null
         --

         -- Even the responsibility is new, check if the new responsibility
         -- is already created in an eariler processing of new users who come
         -- first in the batch.  When the user hook passes in the new resp
         -- info, the responsibility id is not known yet.
         --
         For check_resp_rec in lc_fnd_resp_exists
             (p_resp_key     =>
               hr_user_acct_utility.g_fnd_resp_tbl(i).new_resp_key)
         LOOP
             l_responsibility_id := check_resp_rec.responsibility_id;
             l_user_resp_app_id := check_resp_rec.application_id;
         END LOOP;
         --
         IF l_responsibility_id IS NOT NULL
         THEN
            -- No need to create the responsibility again
            null;
         ELSE
            -- Now, move the new responsibility information in the global
            -- rec to l_fnd_resp_rec work area.
            --
            l_fnd_resp_rec.new_resp_name :=
                hr_user_acct_utility.g_fnd_resp_tbl(i).new_resp_name;
            l_responsibility_key :=
                hr_user_acct_utility.g_fnd_resp_tbl(i).new_resp_key;
            l_fnd_resp_rec.new_resp_key :=
                hr_user_acct_utility.g_fnd_resp_tbl(i).new_resp_key;
            l_fnd_resp_rec.new_resp_description :=
            hr_user_acct_utility.g_fnd_resp_tbl(i).new_resp_description;
            --
            IF hr_user_acct_utility.g_fnd_resp_tbl(i).new_resp_app_id <>
               hr_api.g_number
            THEN
               l_fnd_resp_rec.new_resp_app_id :=
               hr_user_acct_utility.g_fnd_resp_tbl(i).new_resp_app_id;
               -- Set the application_id for fnd_user_resp_groups to
               -- the new resp app id
               l_user_resp_app_id :=
               hr_user_acct_utility.g_fnd_resp_tbl(i).new_resp_app_id;
            ELSE
               -- Set the application_id for fnd_user_resp_groups to
               -- the template responsibility's app id
               l_user_resp_app_id := l_fnd_resp_rec.new_resp_app_id;
            END IF;
            --
            IF hr_user_acct_utility.g_fnd_resp_tbl(i).new_resp_start_date <>
               hr_api.g_date
            THEN
               l_fnd_resp_rec.new_resp_start_date :=
               hr_user_acct_utility.g_fnd_resp_tbl(i).new_resp_start_date;
            END IF;
            --
            IF hr_user_acct_utility.g_fnd_resp_tbl(i).new_resp_end_date <>
               hr_api.g_date
            THEN
               l_fnd_resp_rec.new_resp_end_date :=
               hr_user_acct_utility.g_fnd_resp_tbl(i).new_resp_end_date;
            END IF;
            --
            IF
            hr_user_acct_utility.g_fnd_resp_tbl(i).new_resp_data_group_name
                 <> hr_api.g_varchar2
            THEN
               l_fnd_resp_rec.new_resp_data_group_name :=
            hr_user_acct_utility.g_fnd_resp_tbl(i).new_resp_data_group_name;
            END IF;
            --
            IF
            hr_user_acct_utility.g_fnd_resp_tbl(i).new_resp_data_grp_app_id
                  <> hr_api.g_number
            THEN
               l_fnd_resp_rec.new_resp_data_grp_app_id :=
            hr_user_acct_utility.g_fnd_resp_tbl(i).new_resp_data_grp_app_id;
               --
            END IF;
            --
            IF
            hr_user_acct_utility.g_fnd_resp_tbl(i).new_resp_menu_name
                    <> hr_api.g_varchar2
            THEN
               l_fnd_resp_rec.new_resp_menu_name :=
            hr_user_acct_utility.g_fnd_resp_tbl(i).new_resp_menu_name;
            END IF;
            --
            IF
          hr_user_acct_utility.g_fnd_resp_tbl(i).new_resp_request_group_name
                     <> hr_api.g_varchar2
            THEN
               l_fnd_resp_rec.new_resp_request_group_name :=
         hr_user_acct_utility.g_fnd_resp_tbl(i).new_resp_request_group_name;
            END IF;
            --
            IF
            hr_user_acct_utility.g_fnd_resp_tbl(i).new_resp_req_grp_app_id
                     <> hr_api.g_number
            THEN
               l_fnd_resp_rec.new_resp_req_grp_app_id :=
             hr_user_acct_utility.g_fnd_resp_tbl(i).new_resp_req_grp_app_id;
            END IF;
            --
            IF hr_user_acct_utility.g_fnd_resp_tbl(i).new_resp_version
                     <> hr_api.g_varchar2
            THEN
               l_fnd_resp_rec.new_resp_version :=
               hr_user_acct_utility.g_fnd_resp_tbl(i).new_resp_version;
            END IF;
            --
            IF hr_user_acct_utility.g_fnd_resp_tbl(i).new_resp_web_host_name
                     <> hr_api.g_varchar2
            THEN
               l_fnd_resp_rec.new_resp_web_host_name :=
              hr_user_acct_utility.g_fnd_resp_tbl(i).new_resp_web_host_name;
            END IF;
            --
           IF hr_user_acct_utility.g_fnd_resp_tbl(i).new_resp_web_agent_name
                     <> hr_api.g_varchar2
            THEN
               l_fnd_resp_rec.new_resp_web_agent_name :=
             hr_user_acct_utility.g_fnd_resp_tbl(i).new_resp_web_agent_name;
            END IF;
            --
            hr_utility.set_location(l_proc, 40);
            -- **********************************************
            -- Create the new responsibility
            -- **********************************************
            hr_user_acct_internal.create_fnd_responsibility
                (p_resp_key            => l_fnd_resp_rec.new_resp_key
                ,p_resp_name           => l_fnd_resp_rec.new_resp_name
                ,p_resp_app_id         => l_fnd_resp_rec.new_resp_app_id
                ,p_resp_description    => l_fnd_resp_rec.new_resp_description
                ,p_start_date          => l_fnd_resp_rec.new_resp_start_date
                ,p_end_date            => l_fnd_resp_rec.new_resp_end_date
                ,p_data_group_name     =>
                        l_fnd_resp_rec.new_resp_data_group_name
                ,p_data_group_app_id  => l_fnd_resp_rec.new_resp_data_grp_app_id
                ,p_menu_name          => l_fnd_resp_rec.new_resp_menu_name
                ,p_request_group_name  =>
                        l_fnd_resp_rec.new_resp_request_group_name
                ,p_request_group_app_id =>
                       l_fnd_resp_rec.new_resp_req_grp_app_id
                ,p_version             => l_fnd_resp_rec.new_resp_version
                ,p_web_host_name       => l_fnd_resp_rec.new_resp_web_host_name
                ,p_web_agent_name      => l_fnd_resp_rec.new_resp_web_agent_name
                ,p_responsibility_id   => l_responsibility_id
                );
          --
          -- Save the new responsibility id for later use when creating profile
          -- option values.
          --
          END IF;  -- l_responsibility_id is null on checking the new resp key
  --
       ELSE
          -- new resp name is null, no need to create a new responsibility.
          -- Attach an existing responsibility to the new user.
          l_responsibility_id :=
             hr_user_acct_utility.g_fnd_resp_tbl(i).existing_resp_id;
          l_responsibility_key :=
             hr_user_acct_utility.g_fnd_resp_tbl(i).existing_resp_key;
          l_user_resp_app_id :=
             hr_user_acct_utility.g_fnd_resp_tbl(i).existing_resp_app_id;
       END IF;
       --
       l_fnd_resp_rec.user_resp_start_date :=
            hr_user_acct_utility.g_fnd_resp_tbl(i).user_resp_start_date;

       l_fnd_resp_rec.user_resp_end_date :=
            hr_user_acct_utility.g_fnd_resp_tbl(i).user_resp_end_date;

       l_fnd_resp_rec.user_resp_description :=
            hr_user_acct_utility.g_fnd_resp_tbl(i).user_resp_description;

       l_fnd_resp_rec.sec_group_id :=
            hr_user_acct_utility.g_fnd_resp_tbl(i).sec_group_id;

       l_fnd_resp_rec.sec_profile_id :=
            hr_user_acct_utility.g_fnd_resp_tbl(i).sec_profile_id;
       --
       -- Get the profile option value for 'ENABLE_SECURITY_GROUPS'
       -- Use value_specific because you want the value of the resp being
       -- assigned, not the resp you used to login.
       -- The following code is copied from FNDSCAUS.fmb
       -- FND_RESTRICT_SECURITY_GROUP program unit.
       --
       l_enable_sec_groups := nvl(fnd_profile_server.value_specific(
                                         'ENABLE_SECURITY_GROUPS'
                                        ,l_user_id
                                        ,l_responsibility_id
                                        ,l_user_resp_app_id)
                                    ,'N');

       IF l_enable_sec_groups = 'N'
	  THEN
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
          hr_user_acct_internal.create_fnd_user_resp_groups
            (p_user_id                    => l_user_id
            ,p_responsibility_id          => l_responsibility_id
            ,p_application_id             => l_user_resp_app_id
	    ,p_sec_group_id               => 0
            ,p_start_date                 => l_fnd_resp_rec.user_resp_start_date
            ,p_end_date                   => l_fnd_resp_rec.user_resp_end_date
            ,p_description               => l_fnd_resp_rec.user_resp_description
           );

           hr_utility.set_location (l_proc ||
             ' after create_fnd_user_resp_groups', 51);
       ELSE
          -- 'ENABLE_SECURITY_GROUPS' = 'Y'; customers have the option to insert
          -- into fnd_user_resp_groups only if view-all security profile of the
          -- employee's business group is to be used.  This will be applicable
          -- to Employee Self Service responsibility.  If a restricted security
          -- profile is to be used, then we must call hrasprhi.pkb which will
          -- insert one row into per_sec_profile_assignments as well as to
          -- fnd_user_resp_groups.

          IF l_fnd_resp_rec.sec_group_id IS NULL OR
             l_fnd_resp_rec.sec_profile_id IS NULL
          THEN
             -- Insert into fnd_user_resp_groups only
             -- get the security_group_id for the employee's business_group_id

             OPEN lc_get_sec_group_id;
             FETCH lc_get_sec_group_id into l_sec_group_id;
             IF lc_get_sec_group_id%NOTFOUND
             THEN
                CLOSE lc_get_sec_group_id;
                fnd_message.set_name('FND', 'SQL_NO_DATA_FOUND');
                fnd_message.set_token('TABLE', 'FND_SECURITY_GROUPS');
                fnd_message.set_token('COLUMN', 'SECURITY_GROUP_KEY');
                fnd_message.set_token('VALUE', to_char(p_business_group_id));
                hr_utility.raise_error;
             ELSE
                CLOSE lc_get_sec_group_id;
             END IF;

             hr_utility.set_location (l_proc ||
                ' before create_fnd_user_resp_groups', 53);
             --
             hr_user_acct_internal.create_fnd_user_resp_groups
               (p_user_id               => l_user_id
               ,p_responsibility_id     => l_responsibility_id
               ,p_application_id        => l_user_resp_app_id
               ,p_sec_group_id          => l_sec_group_id
               ,p_start_date            => l_fnd_resp_rec.user_resp_start_date
               ,p_end_date              => l_fnd_resp_rec.user_resp_end_date
               ,p_description           => l_fnd_resp_rec.user_resp_description
              );

             hr_utility.set_location (l_proc ||
                ' after create_fnd_user_resp_groups', 54);
             --
          ELSE
             -- sec_group_id and sec_profile_id are filled in
             -- call peasprhi.pkb to insert into per_sec_profile_assignments
             -- as well as fnd_user_resp_groups.

	     hr_utility.set_location (l_proc ||
				 ' before create_sec_profile_asg', 56);

             -- Insert this row into per_sec_profile_assignments
             hr_user_acct_internal.create_sec_profile_asg
                (p_user_id            => l_user_id
                ,p_sec_group_id       => l_fnd_resp_rec.sec_group_id
                ,p_sec_profile_id     => l_fnd_resp_rec.sec_profile_id
                ,p_resp_key           => l_responsibility_key
                ,p_resp_app_id        => l_user_resp_app_id
                ,p_start_date         => l_fnd_resp_rec.user_resp_start_date
                ,p_end_date           => l_fnd_resp_rec.user_resp_end_date
                );

             hr_utility.set_location (l_proc ||
                                 ' after create_sec_profile_asg', 57);
          END IF;
       END IF;  -- End l_enable_sec_groups check
  --
  END LOOP;  -- end of loop of g_fnd_resp_tbl
  --
--
--
  <<add_func_security_exclusion>>
  -- ************************************************
  -- Now create the fnd_resp_functions
  -- ************************************************

  hr_utility.set_location(l_proc, 60);
  --
  l_resp_func_count :=
        hr_user_acct_utility.g_fnd_resp_functions_tbl.count;
  --
  IF l_resp_func_count < 1
  THEN
     goto add_profile_opt_values;
  END IF;
  --
  -- Initialize l_out_func_sec_excl_tbl
  l_out_func_sec_excl_tbl := g_empty_func_sec_excl_tbl;
  --
  -- Build the function security exclusion rules table by
  -- combining the template responsibility's rules with
  -- any new rules.
  --
  hr_user_acct_internal.build_func_sec_exclusion_rules
    (p_func_sec_excl_tbl  => hr_user_acct_utility.g_fnd_resp_functions_tbl
    ,p_out_func_sec_excl_tbl => l_out_func_sec_excl_tbl);
  --
  l_resp_func_count := l_out_func_sec_excl_tbl.count;

  IF l_resp_func_count < 1
  THEN
     goto add_profile_opt_values;
  END IF;
  --
  FOR i in 1..l_resp_func_count
  LOOP
     hr_user_acct_internal.create_fnd_resp_functions
       (p_resp_key  => l_out_func_sec_excl_tbl(i).resp_key
       ,p_rule_type => l_out_func_sec_excl_tbl(i).rule_type
       ,p_rule_name => l_out_func_sec_excl_tbl(i).rule_name
       ,p_delete_flag => 'N');
  END LOOP;
--
--
  <<add_profile_opt_values>>
  -- ************************************************
  -- Now create the fnd_profile_option_values
  -- ************************************************

  hr_utility.set_location(l_proc, 70);
  --
  l_prof_opt_val_count :=
        hr_user_acct_utility.g_fnd_profile_opt_val_tbl.count;
  --
  IF l_prof_opt_val_count < 1
  THEN
     goto after_process_hook;
  END IF;
  --
  -- NOTE: For Profile Option Level, 10003 = 'RESP', 10004 = 'USER'.
  IF l_resp_count < 1
  THEN
     -- That means there is no responsibility attached to the new user id.
     -- We only need to add profile option values at the user level. We
     -- will do that at the end of this IF statement.
     goto add_user_lvl_profile_val;
  END IF;
  --
  -- The user id is attached to some responsibilities
  -- Add profile option values at either the responsibility or user level.
  -- Check if a new responsibility is created and a template
  -- responsibility_id is used for creating the new responsibility.
  -- Loop through the hr_user_acct_utility.g_fnd_resp_tbl table.  If
  -- a new responsibility is created via a template responsibility, we'll
  -- create profile option values for the new responsibility based on the
  -- template responsibility.
  FOR i in 1..l_resp_count
  LOOP
        --
        IF hr_user_acct_utility.g_fnd_resp_tbl(i).new_resp_key IS NOT NULL
           AND
           hr_user_acct_utility.g_fnd_resp_tbl(i).existing_resp_id
              IS NOT NULL
        THEN
           -- New responsibility using an existing resp as a template, we'll
           -- make a copy of the profile option values from the template resp
           -- for the new responsibility.
           hr_user_acct_internal.build_resp_profile_val
             (p_template_resp_id =>
                hr_user_acct_utility.g_fnd_resp_tbl(i).existing_resp_id
             ,p_template_resp_app_id =>
                hr_user_acct_utility.g_fnd_resp_tbl(i).existing_resp_app_id
             ,p_new_resp_key  =>
                hr_user_acct_utility.g_fnd_resp_tbl(i).new_resp_key
             ,p_new_resp_app_id =>
              hr_user_acct_utility.g_fnd_resp_tbl(i).new_resp_app_id
             ,p_fnd_profile_opt_val_tbl =>
                    hr_user_acct_utility.g_fnd_profile_opt_val_tbl
             ,p_out_profile_opt_val_tbl => l_out_profile_opt_val_tbl
             );
           --
           l_out_profile_opt_val_count := l_out_profile_opt_val_tbl.count;
           --
           OPEN lc_fnd_resp_exists (p_resp_key  =>
              hr_user_acct_utility.g_fnd_resp_tbl(i).new_resp_key);
           FETCH lc_fnd_resp_exists into l_new_resp_id, l_temp_id;
           IF lc_fnd_resp_exists%NOTFOUND
           THEN
              CLOSE lc_fnd_resp_exists;
              fnd_message.set_name('FND', 'SQL_NO_DATA_FOUND');
              fnd_message.set_token('TABLE', 'FND_RESPONSIBILITY');
              fnd_message.set_token('COLUMN', 'RESPONSIBILITY_KEY');
              fnd_message.set_token('VALUE',
                 hr_user_acct_utility.g_fnd_resp_tbl(i).new_resp_key);
              hr_utility.raise_error;
           ELSE
              CLOSE lc_fnd_resp_exists;
           END IF;
           --
           IF l_out_profile_opt_val_count > 0
           THEN
              --
              FOR j in 1..l_out_profile_opt_val_count
              LOOP
                 -- Reset the variable before each loop
                 l_profile_value_saved := null;
                 hr_user_acct_internal.create_fnd_profile_values
                   (p_profile_opt_name         =>
                      l_out_profile_opt_val_tbl(j).profile_option_name
                   ,p_profile_opt_value        =>
                      l_out_profile_opt_val_tbl(j).profile_option_value
                   ,p_profile_level_name       => 'RESP'
                   ,p_profile_level_value      => l_new_resp_id
                   ,p_profile_lvl_val_app_id   =>
                      l_out_profile_opt_val_tbl(j).profile_level_value_app_id
                   ,p_profile_value_saved      => l_profile_value_saved
                   );
                   --
                   IF l_profile_value_saved
                   THEN
                      null;
                   ELSE
                      -- Write the error to the log file and continue to
                      -- process.
                      l_msg_text := null;
                      fnd_message.set_name('PER', 'HR_PROFILE_VAL_NOT_ADDED');
                      fnd_message.set_token('RESP_KEY',
                           hr_user_acct_utility.g_fnd_resp_tbl(i).new_resp_key);
                      fnd_message.set_token('PROFIE_OPTION_NAME',
                         l_out_profile_opt_val_tbl(j).profile_option_name);
                      fnd_message.set_token('PROFILE_OPTION_VALUE',
                         l_out_profile_opt_val_tbl(j).profile_option_value);
                      hr_utility.raise_error;
                   END IF;
              END LOOP; -- end loop for inserting each profile opt value rec
                        -- at the responsibility level

           END IF;  -- end l_out_profile_opt_val_count > 0
        ELSIF
           hr_user_acct_utility.g_fnd_resp_tbl(i).new_resp_key IS NOT NULL
        THEN
           -- that means existing resp id is null, we'll just attach profile
           -- option values at the new resp level.
           hr_user_acct_internal.build_resp_profile_val
             (p_template_resp_id => null
             ,p_template_resp_app_id => null
             ,p_new_resp_key  =>
               hr_user_acct_utility.g_fnd_resp_tbl(i).new_resp_key
             ,p_new_resp_app_id =>
              hr_user_acct_utility.g_fnd_resp_tbl(i).new_resp_app_id
             ,p_fnd_profile_opt_val_tbl =>
                    hr_user_acct_utility.g_fnd_profile_opt_val_tbl
             ,p_out_profile_opt_val_tbl => l_out_profile_opt_val_tbl
             );
           --
           l_out_profile_opt_val_count := l_out_profile_opt_val_tbl.count;
           --
           OPEN lc_fnd_resp_exists (p_resp_key  =>
              hr_user_acct_utility.g_fnd_resp_tbl(i).new_resp_key);
           FETCH lc_fnd_resp_exists into l_new_resp_id, l_temp_id;
           IF lc_fnd_resp_exists%NOTFOUND
           THEN
              CLOSE lc_fnd_resp_exists;
              fnd_message.set_name('FND', 'SQL_NO_DATA_FOUND');
              fnd_message.set_token('TABLE', 'FND_RESPONSIBILITY');
              fnd_message.set_token('COLUMN', 'RESPONSIBILITY_KEY');
              fnd_message.set_token('VALUE',
                 hr_user_acct_utility.g_fnd_resp_tbl(i).new_resp_key);
              hr_utility.raise_error;
           ELSE
              CLOSE lc_fnd_resp_exists;
           END IF;
           --
           IF l_out_profile_opt_val_count > 0
           THEN
              --
              FOR j in 1..l_out_profile_opt_val_count
              LOOP
                 l_profile_value_saved := null;
                 hr_user_acct_internal.create_fnd_profile_values
                   (p_profile_opt_name         =>
                      l_out_profile_opt_val_tbl(j).profile_option_name
                   ,p_profile_opt_value        =>
                      l_out_profile_opt_val_tbl(j).profile_option_value
                   ,p_profile_level_name       => 'RESP'
                   ,p_profile_level_value      => l_new_resp_id
                   ,p_profile_lvl_val_app_id   =>
                      l_out_profile_opt_val_tbl(j).profile_level_value_app_id
                   ,p_profile_value_saved      => l_profile_value_saved
                   );
                   IF l_profile_value_saved
                   THEN
                      null;
                   ELSE
                      -- Write the error to the log file and continue to
                      -- process.
                      l_msg_text := null;
                      fnd_message.set_name('PER', 'HR_PROFILE_VAL_NOT_ADDED');
                      fnd_message.set_token('RESP_KEY',
                           hr_user_acct_utility.g_fnd_resp_tbl(i).new_resp_key);
                      l_temp :=l_out_profile_opt_val_tbl(j).profile_option_name;
                      fnd_message.set_token('PROFIE_OPTION_NAME', l_temp);
                      --
                      l_temp:=l_out_profile_opt_val_tbl(j).profile_option_value;
                      fnd_message.set_token('PROFILE_OPTION_VALUE', l_temp);
                      hr_utility.raise_error;
                   END IF;
              END LOOP; -- end loop for inserting each profile opt value rec
                        -- at the responsibility level

           END IF;  -- end l_out_proifile_opt_val_count > 0
        END IF;  -- end new_resp_key is not null
        --
  END LOOP;   -- end loop of hr_user_acct_utility.g_fnd_resp_tbl
  --
  --
  <<add_user_lvl_profile_val>>
  --
  -- Now insert user level profile opt values
  FOR i in 1..l_prof_opt_val_count
  LOOP
  l_profile_value_saved := null;
  IF hr_user_acct_utility.g_fnd_profile_opt_val_tbl(i).profile_level_name
     = 'USER'
  THEN
     hr_user_acct_internal.create_fnd_profile_values
          (p_profile_opt_name        =>
      hr_user_acct_utility.g_fnd_profile_opt_val_tbl(i).profile_option_name
          ,p_profile_opt_value       =>
      hr_user_acct_utility.g_fnd_profile_opt_val_tbl(i).profile_option_value
          ,p_profile_level_name      => 'USER'
          ,p_profile_level_value      =>l_user_id  -- Fix 2825757
          ,p_profile_lvl_val_app_id  =>
hr_user_acct_utility.g_fnd_profile_opt_val_tbl(i).profile_level_value_app_id
          ,p_profile_value_saved      => l_profile_value_saved
          );
      --
      IF l_profile_value_saved
      THEN
         null;
      ELSE
         -- Write the error to the log file and continue to process.
         l_msg_text := null;
         fnd_message.set_name('PER', 'HR_PROFILE_USER_VAL_NOT_ADDED');
         l_temp := l_out_profile_opt_val_tbl(i).profile_option_name;
         fnd_message.set_token('PROFIE_OPTION_NAME', l_temp);
         --
         l_temp := l_out_profile_opt_val_tbl(i).profile_option_value;
         fnd_message.set_token('PROFILE_OPTION_VALUE', l_temp);
         hr_utility.raise_error;
      END IF;
  END IF;
  END LOOP;
  --

  <<after_process_hook>>

  BEGIN
    --
    -- Start of API User Hook for the after hook of create_user_acct
    --
    hr_user_acct_bk1.create_user_acct_a
      (p_person_id                    => p_person_id
      ,p_per_effective_start_date     => p_per_effective_start_date
      ,p_per_effective_end_date       => p_per_effective_end_date
	 ,p_assignment_id                => p_assignment_id
      ,p_asg_effective_start_date     => p_asg_effective_start_date
      ,p_asg_effective_end_date       => p_asg_effective_end_date
      ,p_business_group_id            => p_business_group_id
      ,p_date_from                    => l_date_from
      ,p_date_to                      => l_date_to
      ,p_org_structure_id             => p_org_structure_id
      ,p_org_structure_vers_id        => p_org_structure_vers_id
      ,p_parent_org_id                => p_parent_org_id
      ,p_single_org_id                => p_single_org_id
      ,p_run_type                     => p_run_type
      ,p_hire_date                    => l_hire_date
      );

  EXCEPTION
    WHEN hr_api.cannot_find_prog_unit THEN
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'CREATE_USER_ACCOUNT'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_user_acct
    --
  end;
  --
  -- Set all output arguments
  --
  p_user_id               := l_user_id;
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  IF p_validate
  THEN
    raise hr_api.validate_enabled;
  END IF;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 80);

EXCEPTION
  WHEN hr_api.validate_enabled THEN
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO create_user_acct;
    --
    ---------------------------------------------------------------------------
    -- NOTE:
    -- In R11.5, the java program WebSessionManager.class is now a stored
    -- procedure on the database.  It is being executed as part of the
    -- transaction.  When we rollback, the initial fnd_user record created by
    -- the java program will also be rolled back.  We no longer need to
    -- remove the dangling fnd_user manually.
    ---------------------------------------------------------------------------
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    p_user_id               := null;
    --
    --
  WHEN others THEN
    --
    -- A validation or unexpected error has occurred
    --
    --
    ROLLBACK TO create_user_acct;
    --
    ---------------------------------------------------------------------------
    -- NOTE:
    -- In R11.5, the java program WebSessionManager.class is now a stored
    -- procedure on the database.  It is being executed as part of the
    -- transaction.  When we rollback, the initial fnd_user record created by
    -- the java program will also be rolled back.  We no longer need to
    -- remove the dangling fnd_user manually.
    ---------------------------------------------------------------------------
    --
    p_user_id               := null;
    raise;
    --
END create_user_acct;
--
--
-- ----------------------------------------------------------------------------
-- |-------------------------- < update_user_acct > --------------------------|
-- |                                                                          |
-- | USAGE:                                                                   |
-- | -----                                                                    |
-- | This wrapper module is used to update fnd_user and                       |
-- | fnd_user_resp_groups, or per_sec_profile_assignments records specifically|
-- | for expiring a user account.                                             |
-- | User accounts for terminated employees will not be deleted because       |
-- | some HR history forms have sql statements join to the fnd_user table     |
-- | derive the who columns.                                                  |
-- ----------------------------------------------------------------------------
--
PROCEDURE update_user_acct
  (p_validate                      in     boolean  default false
  ,p_person_id                     in     number
  ,p_per_effective_start_date      in     date     default null
  ,p_per_effective_end_date        in     date     default null
  ,p_assignment_id                 in     number   default null
  ,p_asg_effective_start_date      in     date     default null
  ,p_asg_effective_end_date        in     date     default null
  ,p_business_group_id             in     number
  ,p_date_from                     in     date     default null
  ,p_date_to                       in     date     default null
  ,p_org_structure_id              in     number   default null
  ,p_org_structure_vers_id         in     number   default null
  ,p_parent_org_id                 in     number   default null
  ,p_single_org_id                 in     number   default null
  ,p_run_type                      in     varchar2 default null
  ,p_inactivate_date               in     date
  )
is
--
l_date                date default null;
--
--
CURSOR  lc_get_user_id
IS
SELECT  user_id
FROM    fnd_user
WHERE   employee_id = p_person_id
AND     nvl(end_date, hr_api.g_eot) > l_date;
--
-- Cursor to select all records which belongs to the terminated employee's
-- user id and the end date is null or the end date is greater than the
-- termination date.
--
CURSOR  lc_get_sec_profile_asg (c_user_id   in number)
IS
SELECT  sec_profile_assignment_id
       ,security_group_id
       ,security_profile_id
       ,responsibility_id
	  ,responsibility_application_id
	  ,object_version_number
	  ,start_date
FROM    per_sec_profile_assignments
WHERE   user_id = c_user_id
AND     nvl(end_date, l_date + 1) > l_date;
--
-- Cursor to select all records which belongs to the terminated employee's
-- user id and the end date is null or the end date is greater than the
-- termination date.
--
-- Fix for bug 4147802 starts here. used fnd_user_resp_groups_direct view
-- in place of fnd_user_resp_groups. Also the column description is removed.
--
CURSOR  lc_get_user_resp (c_user_id   in number)
IS
/*
SELECT  responsibility_application_id
       ,responsibility_id
	  ,security_group_id
       ,start_date
       ,end_date
      -- ,description
FROM    fnd_user_resp_groups_direct
WHERE   user_id = c_user_id
AND     nvl(end_date, l_date + 1) > l_date
AND trunc(sysdate) between start_date and nvl(end_date,sysdate);  --5090502
*/
SELECT  furgd.responsibility_application_id
       ,furgd.responsibility_id
       ,furgd.security_group_id
       ,furgd.start_date
       ,furgd.end_date
      -- ,description
FROM    fnd_user_resp_groups_direct furgd, FND_RESPONSIBILITY fr
WHERE   furgd.user_id = c_user_id
AND fr.responsibility_id = furgd.responsibility_id
AND trunc(sysdate) between fr.start_date and nvl(fr.end_date,sysdate)
AND     nvl(furgd.end_date, l_date + 1) > l_date
AND trunc(sysdate) between furgd.start_date and nvl(furgd.end_date,sysdate);
--
--

l_proc                varchar2(72) := g_package||'update_user_acct';
--
--
BEGIN
  hr_utility.set_location('Entering:'|| l_proc, 10);
  --
  -- Issue a savepoint.
  --
  savepoint update_user_acct;
  l_date  := trunc(p_inactivate_date) + 1; -- Bug 4960718
  --
  begin
    --
    hr_user_acct_bk2.update_user_acct_b
      (p_person_id                    => p_person_id
      ,p_per_effective_start_date     => p_per_effective_start_date
      ,p_per_effective_end_date       => p_per_effective_end_date
      ,p_assignment_id                => p_assignment_id
      ,p_asg_effective_start_date     => p_asg_effective_start_date
      ,p_asg_effective_end_date       => p_asg_effective_end_date
      ,p_business_group_id            => p_business_group_id
      ,p_date_from                    => p_date_from
      ,p_date_to                      => p_date_to
      ,p_org_structure_id             => p_org_structure_id
      ,p_org_structure_vers_id        => p_org_structure_vers_id
      ,p_parent_org_id                => p_parent_org_id
      ,p_single_org_id                => p_single_org_id
      ,p_run_type                     => p_run_type
      ,p_inactivate_date              => l_date
      );


  EXCEPTION
    when hr_api.cannot_find_prog_unit then
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_USER_ACCOUNT'
        ,p_hook_type   => 'BP'
        );
    --
  end;
  --
  --
  hr_utility.set_location(l_proc, 20);
  --
  --
  -- Update fnd_user.end_date with the p_inactivate_date passed in
  -- A person may have more than 1 user accounts opened.  Need to
  -- get all the user ids associated to the person.
  --
  FOR get_user_ids in lc_get_user_id
  LOOP
  --
  ----------------------------------------------------------------------------
  -- NOTE:
  --   As of the time writing this code, the allowable update function is to
  --   inactivate an fnd_user.date_to when an employee is terminated.
  --   No code is provided to massively update other attributes of the fnd_user
  --   rec, such as the password.  For bulk changes to password, we need to know
  --   the old password (decrypted) and as of now, there is no way to decrypt
  --   a password without using the java code.  Hence, the only functionality
  --   allowed for updating an fnd_user rec is to end date the record.
  ----------------------------------------------------------------------------
      hr_user_acct_internal.update_fnd_user
        (p_user_id               => get_user_ids.user_id
        ,p_end_date              => l_date
        );
        --
	   -- Need to end date all rows in per_sec_profile_assignments associated
	   -- the user id.
	   -- The per_asp_upd(peasprhi.pkb) api will transparently end date the
	   -- fnd_user_resp_groups records as well.


	   FOR  get_sec_prf_asg in lc_get_sec_profile_asg
                              (c_user_id  => get_user_ids.user_id)
	   LOOP
	   hr_utility.trace('Calling update_sec_profile_asg with ' || get_sec_prf_asg.sec_profile_assignment_id);
		 hr_user_acct_internal.update_sec_profile_asg
		  (p_sec_profile_asg_id => get_sec_prf_asg.sec_profile_assignment_id

	       ,p_object_version_number => get_sec_prf_asg.object_version_number
	       ,p_start_date => get_sec_prf_asg.start_date
	       ,p_end_date => l_date -- Fix 2978610
		  );
        END LOOP;


        -- Need to end date the fnd_user_resp_groups record for
        -- each user id.
        -- The cursor needs to return the application_id, start_date
        -- end_date, description, responsibility_id in addition to
        -- user_id because these attributes are the required parameters
        -- in fnd_user_resp_groups update_row.
        --
	   -- If 'ENABLE_SECURITY_GROUPS' = 'Y' and the data are setup
	   -- correctly, there should not be any rows returned from the
	   -- lc_get_user_resp cursor because the peasprhi.pkb api  would
	   -- have already end dated the fnd_user_resp_groups record.  If
	   -- we have rows returned from the lc_get_user_resp, that means
	   -- 'ENABLE_SECURITY_GROUPS' = 'N'.  Hence, we need to end date
	   -- the fnd_user_resp_groups rows.
	   FOR get_user_resp in lc_get_user_resp
                                (c_user_id  => get_user_ids.user_id)
	   LOOP
	   hr_utility.trace('Calling update_fnd_user_resp_groups with ');
	   hr_utility.trace('user_id' || get_user_ids.user_id);
	   hr_utility.trace('security_group_id' || get_user_resp.security_group_id);
	   hr_utility.trace('p_end_date' || l_date);

           hr_user_acct_internal.update_fnd_user_resp_groups
             (p_user_id           => get_user_ids.user_id
             ,p_responsibility_id => get_user_resp.responsibility_id
             ,p_resp_application_id
						    => get_user_resp.responsibility_application_id
	        ,p_security_group_id => get_user_resp.security_group_id
             ,p_start_date        => get_user_resp.start_date
             ,p_end_date          => l_date
             --,p_description       => get_user_resp.description -- Bug 4147802
             );
        END LOOP;
  END LOOP;
  --
  hr_utility.set_location(l_proc, 30);
  --
  --
  BEGIN
    --
    -- Start of API User Hook for the after hook of create_user_acct
    --
    hr_user_acct_bk2.update_user_acct_a
      (p_person_id                    => p_person_id
      ,p_per_effective_start_date     => p_per_effective_start_date
      ,p_per_effective_end_date       => p_per_effective_end_date
      ,p_assignment_id                => p_assignment_id
      ,p_asg_effective_start_date     => p_asg_effective_start_date
      ,p_asg_effective_end_date       => p_asg_effective_end_date
      ,p_business_group_id            => p_business_group_id
      ,p_date_from                    => p_date_from
      ,p_date_to                      => p_date_to
      ,p_org_structure_id             => p_org_structure_id
      ,p_org_structure_vers_id        => p_org_structure_vers_id
      ,p_parent_org_id                => p_parent_org_id
      ,p_single_org_id                => p_single_org_id
      ,p_run_type                     => p_run_type
      ,p_inactivate_date              => l_date
      );

  EXCEPTION
    WHEN hr_api.cannot_find_prog_unit THEN
      hr_api.cannot_find_prog_unit_error
        (p_module_name => 'UPDATE_USER_ACCOUNT'
        ,p_hook_type   => 'AP'
        );
    --
    -- End of API User Hook for the after hook of create_user_acct
    --
  end;
  --
  -- Set all output arguments, if any.
  --
  -- When in validation only mode raise the Validate_Enabled exception
  --
  IF p_validate
  THEN
    raise hr_api.validate_enabled;
  END IF;
  --
  hr_utility.set_location(' Leaving:'||l_proc, 70);

EXCEPTION
  WHEN hr_api.validate_enabled THEN
    --
    -- As the Validate_Enabled exception has been raised
    -- we must rollback to the savepoint
    --
    ROLLBACK TO update_user_acct;
    --
    -- Only set output warning arguments
    -- (Any key or derived arguments must be set to null
    -- when validation only mode is being used.)
    --
    --
  WHEN others THEN
    --
    -- A validation or unexpected error has occurred
    --
    --
    ROLLBACK TO update_user_acct;
    raise;
    --
END update_user_acct;
--
--
END hr_user_acct_api;

/

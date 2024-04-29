--------------------------------------------------------
--  DDL for Package Body HR_SIGNON
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_SIGNON" AS
/* $Header: hrsignon.pkb 120.1.12010000.2 2008/10/30 04:56:00 ubhat ship $ */
-----------------------------------------------------------------------
-----------------------------------------------------------------------
-- PRIVATE FUNCTIONS
-----------------------------------------------------------------------
-----------------------------------------------------------------------
   --
   --------------------------------------------------------------------
   --< Generic_Error >-------------------------------------------------
   --------------------------------------------------------------------
   --
   -- Description:
   --
   --
   --
   PROCEDURE Generic_Error
      (p_routine IN VARCHAR2
      ,p_errcode IN NUMBER
      ,p_errmsg  IN VARCHAR2
      )
   IS
   BEGIN
      fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
      fnd_message.set_token('ROUTINE', p_routine);
      fnd_message.set_token('ERRNO', p_errcode);
      fnd_message.set_token('REASON', p_errmsg);
      fnd_message.raise_error;
   END Generic_Error;
   --
   --------------------------------------------------------------------
   --< Get_BG_ID >-----------------------------------------------------
   --------------------------------------------------------------------
   --
   -- Description:
   --    This function will return the business group to be used for
   --    the session.
   --
   --    Depending on the setting of the 'ENABLE_SECURITY_GROUPS'
   --    profile option the business group will be derived in one of
   --    two ways:
   --
   --    ENABLE_SECURITY_GROUPS = 'Y'
   --    Multi security groups can be used for the same responsibility.
   --    The business group is derived by querying PER_BUSINESS_GROUPS
   --    with the security group that the user selected at signon.
   --
   --    ENABLE_SECURITY_GROUPS = 'N'
   --    Single security group model is in use, so the business group
   --    is found by finding the value of the business group profile
   --    set on the responsibility the user is logged into.
   --
   FUNCTION Get_BG_ID
      (p_security_group_id        IN NUMBER
      ,p_responsibility_id        IN NUMBER
      ,p_resp_app_id              IN NUMBER
      )
   RETURN NUMBER
   IS
   --
   l_business_group_id   NUMBER  DEFAULT NULL;
   --
   BEGIN
      --
      -- Find the business group (if there is one)
      --
      --
      -- If the enable security groups profile is set to Y then retrieve
      -- the business group by scanning the per_business_group view with
      -- the supplied security_group_id
      --
      BEGIN
         SELECT business_group_id
           INTO l_business_group_id
           FROM per_business_groups
          WHERE security_group_id = to_char(p_security_group_id);
      EXCEPTION
         WHEN no_data_found THEN
            l_business_group_id := NULL;
      END;

     -- This is required to handle model 2 of multi tenancy (PEO)
      -- i.e. the security group corresponds to the enterprise rather than the
      -- business group.
      -- Note:
      -- 1. For model 1 of multi tenancy (BPO) this is not required as the
      --    security group corresponds to the business group.
      -- 2. By the time this method is called the enterprise OLS context should
      --    have been set.
      IF l_business_group_id is null AND
         hr_multi_tenancy_pkg.is_multi_tenant_system THEN
        l_business_group_id := hr_multi_tenancy_pkg.get_bus_grp_from_sec_grp
          (p_security_group_id => p_security_group_id);
      END IF;
      --
      RETURN l_business_group_id;
      --
   END Get_BG_ID;
   --
   --------------------------------------------------------------------
   --< Check_Business_Group_Lockout >----------------------------------
   --------------------------------------------------------------------
   --
   -- Description:
   --    Checks if the specified business group has been 'locked out'.
   --
   --    This is a feature used by the Data Migrator project for
   --    Fidelity.
   --
   --    When a specific business group is being migrated, a database
   --    profile is set with its ID - if a user then tries to login to
   --    this business group whilst the migration is in progress then
   --    they will not be permitted to enter any HR forms since we null
   --    the profile options for business group and security profile.
   --
   PROCEDURE Check_Business_Group_Lockout
      (p_business_group_id    IN  NUMBER
      ,p_security_group_id    IN  NUMBER
      ,p_sg_enabled           IN  BOOLEAN
      )
   IS
   --
   -- Data migrator BG lockout cursor
   --
   CURSOR c_chk_bg_locked (l_business_group_id IN NUMBER)
   IS
   SELECT 'Y'
     FROM per_business_groups
    WHERE security_group_id = to_char(p_security_group_id)
      AND business_group_id = l_business_group_id;
   --
   l_bg_lockout         NUMBER  DEFAULT NULL;
   l_exists             VARCHAR2(1);
   l_lockout_exception  EXCEPTION;
   --
   BEGIN
      --
      --
      -- Get the value for the data migratior business group lockout
      -- profile
      --
      l_bg_lockout :=
         TO_NUMBER(fnd_profile.value('HR_DM_BG_LOCKOUT'));
      --
      -- If the profile has been set (ie. a migration is in progress)
      -- then do some checking
      --
      IF l_bg_lockout IS NOT NULL THEN
         --
         -- Now check if the business group the current user is trying to
         -- log into is currently locked (ie. it is being migrated)
         --
         IF (p_sg_enabled) THEN
            OPEN c_chk_bg_locked(l_bg_lockout);
            --
            FETCH c_chk_bg_locked INTO l_exists;
            --
            IF c_chk_bg_locked%FOUND THEN
               CLOSE c_chk_bg_locked;
               --
               -- Set the BG/SP profiles to null to ensure that no
               -- business group specific data can be entered by the user
               --
               fnd_profile.put
                  (name => 'PER_SECURITY_PROFILE_ID'
                  ,val => NULL
                  );
               fnd_profile.put
                  (name => 'PER_BUSINESS_GROUP_ID'
                  ,val => NULL
                  );
               --
               -- Now raise an exception to break out of this procedure
               --
               RAISE l_lockout_exception;
            END IF;
            --
            CLOSE c_chk_bg_locked;
         ELSE
            IF (l_bg_lockout = p_business_group_id) THEN
               --
               -- Set the BG/SP profiles to null to ensure that no
               -- business group specific data can be entered by the user
               --
               fnd_profile.put
                  (name => 'PER_SECURITY_PROFILE_ID'
                  ,val => NULL
                  );
               fnd_profile.put
                  (name => 'PER_BUSINESS_GROUP_ID'
                  ,val => NULL
                  );
               --
               -- Now raise an exception to break out of this procedure
               --
               RAISE l_lockout_exception;
            END IF;
         END IF;
      END IF;
      --
   EXCEPTION
      WHEN OTHERS THEN
         RAISE;
   END Check_Business_Group_Lockout;
   --
   -----------------------------------------------------------------------
   --< Get_SP_ID >--------------------------------------------------------
   -----------------------------------------------------------------------
   --
   -- Description:
   --    This function will return the security profile to be used for
   --    the session.
   --
   --    Unlike in R11 we no longer determine the security profile for a
   --    session by inspecting the relavent profile option at resp/site
   --    level.
   --
   --    For R11i all security profile assignments are maintained through
   --    the 'assign security profiles' form, and are stored in the
   --    PER_SEC_PROFILE_ASSIGNMENTS table.
   --
   --
   FUNCTION Get_SP_ID
      (p_user_id              IN NUMBER
      ,p_responsibility_id    IN NUMBER
      ,p_resp_app_id          IN NUMBER
      ,p_business_group_id    IN NUMBER
      ,p_security_group_id    IN NUMBER
      )
   RETURN NUMBER
   IS
   --
   CURSOR c_get_sp_assignment
   IS
   SELECT p1.security_profile_id
     FROM per_sec_profile_assignments p1
         ,per_security_profiles p2
    WHERE p1.security_profile_id = p2.security_profile_id
      AND p1.user_id = p_user_id
      AND p1.responsibility_id = p_responsibility_id
      AND p1.responsibility_application_id = p_resp_app_id
      AND p1.business_group_id = p_business_group_id
      AND p1.security_group_id = p_security_group_id
     -- AND SYSDATE BETWEEN p1.start_date -- modified for the bug 6344997
      AND trunc(SYSDATE) BETWEEN p1.start_date
                      AND NVL(p1.end_date, hr_general.END_OF_TIME);
   --
   CURSOR c_get_implicit_sp
   IS
   SELECT MIN(security_profile_id)
     FROM per_security_profiles
    WHERE business_group_id = p_business_group_id
      AND view_all_flag = 'Y';
   --
   l_security_profile_id  NUMBER  DEFAULT NULL;
   --
   BEGIN
      --
      -- First of all try and get the security_profile_id by scanning
      -- for active security profile assignments
      --
      OPEN c_get_sp_assignment;
      --
      FETCH c_get_sp_assignment INTO l_security_profile_id;
      --
      IF c_get_sp_assignment%NOTFOUND THEN
         --
         l_security_profile_id := NULL;
         --
      END IF;
      --
      CLOSE c_get_sp_assignment;
      --
      IF l_security_profile_id IS NOT NULL THEN
         RETURN l_security_profile_id;
      END IF;
      --
      -- There is no assignment - try and find the id of the view all
      -- profile for the business group
      --
      OPEN c_get_implicit_sp;
      --
      FETCH c_get_implicit_sp INTO l_security_profile_id;
      --
      IF c_get_implicit_sp%NOTFOUND THEN
         --
         l_security_profile_id := NULL;
         --
      END IF;
      --
      CLOSE c_get_implicit_sp;
      --
      RETURN l_security_profile_id;
      --
   END Get_SP_ID;
   --
   -----------------------------------------------------------------------
   --< Set_Profile_Values >-----------------------------------------------
   -----------------------------------------------------------------------
   --
   -- Description:
   --    This procedure sets the values for the PER_SECURITY_PROFILE_ID
   --    and PER_BUSINESS_GROUP_ID profiles in the server-side profile
   --    cache.
   --
   --    Note:  The values set here will override any database settings
   --           that exist for these profiles.
   --
   PROCEDURE Set_Profile_Values
      (p_business_group_id    IN NUMBER
      ,p_security_profile_id  IN NUMBER
      )
   IS
   --
   BEGIN
      --
      fnd_profile.put(name => 'PER_SECURITY_PROFILE_ID'
                     ,val => p_security_profile_id
                     );
      fnd_profile.put(name => 'PER_BUSINESS_GROUP_ID'
                     ,val => p_business_group_id
                     );
      --
   END Set_Profile_Values;
   --
   -----------------------------------------------------------------------
   --< Security_Groups_Enabled >------------------------------------------
   -----------------------------------------------------------------------
   --
   -- Description:
   --    This function checks whether or not security groups are enabled.
   --    This is done by primarily checking the profile
   --    ENABLE_SECURITY_GROUPS.  If this is set then an additional check
   --    is made to ensure that the enable security groups concurrent
   --    program has been run - this is done by querying the
   --    per_business_groups view for any business groups (other than the
   --    setup business group) with a security_group_id of 0.
   --    Note: any business groups created whilst security groups are not
   --    enabled have a default value of 0.
   --
   FUNCTION Security_Groups_Enabled
   RETURN VARCHAR2
   IS
   --
   l_dummy  VARCHAR2(1);
   --
   CURSOR c_check_sec_process_run
   IS
   SELECT 'Y'
     FROM per_business_groups
    WHERE business_group_id <> 0
      AND security_group_id = '0';
   --
   BEGIN
      --
      -- check if the enable_security_groups profile is set to 'Y'
      IF fnd_profile.value('ENABLE_SECURITY_GROUPS') = 'Y' THEN
         -- profile is enabled... make sure that the enable security groups
         -- concurrent process has been run... otherwise return false else
         -- the HR security initialization code will fail
         --
         -- to tell if the concurrent process has been run we can just look
         -- for any business groups other than the setup business group that
         -- have a security group ID of 0.
         OPEN c_check_sec_process_run;
         --
         FETCH c_check_sec_process_run INTO l_dummy;
         --
         IF c_check_sec_process_run%NOTFOUND THEN
            --
            CLOSE c_check_sec_process_run;
            RETURN 'Y';
            --
         ELSE
            --
            CLOSE c_check_sec_process_run;
            RETURN 'N';
            --
         END IF;
      ELSE
         -- profile is not enabled, so return false
         RETURN 'N';
      END IF;
      --
   END Security_Groups_Enabled;
   --
   -----------------------------------------------------------------------
   --< Get_Security_Profile_ID >------------------------------------------
   -----------------------------------------------------------------------
   --
   -- Description:
   --    This function returns the security profile to be used for a
   --    session, given the user/resp/app/security group that the user
   --    has signed into.
   --
   --    Depending whether or not multiple security groups are enabled
   --    for the application, the business group and security profile
   --    profile options may also be setup here.
   --
   -- Arguments
   --   p_user_id             User ID for the session
   --   p_responsibility_id   Responsibility ID for the session
   --   p_application_id      Responsibility application ID for the session
   --   p_security_group_id   Security group ID for the session
   --
   -- Returns
   --   Security profile ID to use for the session (this value is used
   --   to setup the cached global in fnd_client_info)
   --
   FUNCTION Get_Security_Profile_ID
      (p_user_id            IN  NUMBER
      ,p_responsibility_id  IN  NUMBER
      ,p_application_id     IN  NUMBER
      ,p_security_group_id  IN  NUMBER
      ) RETURN NUMBER
   IS
   --
   l_business_group_id        NUMBER  DEFAULT NULL;
   l_security_profile_id      NUMBER  DEFAULT NULL;
   --
   BEGIN
      --
      -- Retrieve the value for the ENABLE_SECURITY_GROUPS profile option.
      -- If this is enabled then the business group for the session is
      -- derived from the security group that the user selected at login.
      -- If security groups are enabled then the security profile assignment
      -- for the session is found by querying PER_SEC_PROFILE_ASSIGNMENTS
      -- and if no explicit assignment exists then default view-all profile
      -- for the business group is assigned.
      --
      -- If security groups are not enabled then the business group and
      -- security profile are assigned by setting the profile options and
      -- as such no processing will be done here.
      --
      IF Security_Groups_Enabled = 'Y' THEN
         --
         -- Retrieve the business group to be used for the session.
         --
         l_business_group_id
            := Get_BG_ID
               (p_security_group_id       => p_security_group_id
               ,p_responsibility_id       => p_responsibility_id
               ,p_resp_app_id             => p_application_id
               );
         --
         IF l_business_group_id IS NOT NULL THEN
            --
            -- Check if the business group has been 'locked out'.
            -- This is a feature used by the Data Migrator project for Fidelity.
            -- When a specific business group is being migrated, a database
            -- profile is set with its ID - if a user then tries to login to this
            -- business group whilst the migration is in progress then they will
            -- not be permitted to enter any HR forms since we null the profile
            -- options for business group and security profile.
            --
            Check_Business_Group_Lockout
               (p_business_group_id => l_business_group_id
               ,p_security_group_id => p_security_group_id
               ,p_sg_enabled        => TRUE
               );
            --
            -- Get the security profile for the session.
            -- Unlike in R11 we no longer determine the security profile for a
            -- session by inspecting the relavent profile option at resp/site
            -- level.
            -- For R11i all security profile assignments are maintained through
            -- the 'assign security profiles' form, and are stored in the
            -- PER_SEC_PROFILE_ASSIGNMENTS table.
            --
            l_security_profile_id
               := Get_SP_ID
                     (p_user_id           => p_user_id
                     ,p_responsibility_id => p_responsibility_id
                     ,p_resp_app_id       => p_application_id
                     ,p_business_group_id => l_business_group_id
                     ,p_security_group_id => p_security_group_id
                     );
            --
            -- Store the retrieved values for the BG/SP profile options in the
            -- server-side cache.
            --
            Set_Profile_Values
               (p_business_group_id    => l_business_group_id
               ,p_security_profile_id  => l_security_profile_id
               );
         ELSE
            --
            -- The site level defaults will be used for this session so
            -- retrieve the value from the profile cache now..
            --
            l_security_profile_id
               := TO_NUMBER(fnd_profile.value('PER_SECURITY_PROFILE_ID'));
            --
         END IF;
      ELSE
         BEGIN
            Check_Business_Group_Lockout
               (p_business_group_id =>
                      TO_NUMBER(fnd_profile.value('PER_BUSINESS_GROUP_ID'))
               ,p_security_group_id => 0
               ,p_sg_enabled        => FALSE
               );
            --
            l_security_profile_id
               := TO_NUMBER(fnd_profile.value('PER_SECURITY_PROFILE_ID'));
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;
      END IF;
      --
      RETURN l_security_profile_id;
      --
   END Get_Security_Profile_ID;
   --
   -----------------------------------------------------------------------
   ------------------------< derive_legislation >-------------------------
   -----------------------------------------------------------------------
   --
   PROCEDURE derive_legislation IS
   --
   l_leg_code varchar2(150);
   l_business_group_id number(15);
   --
   BEGIN
     --
     l_leg_code := hr_api.return_legislation_code(
                               fnd_profile.value('PER_BUSINESS_GROUP_ID'));
     --
     --
     hr_api.set_legislation_context(l_leg_code);
     --
   EXCEPTION
   WHEN NO_DATA_FOUND THEN
     null;
   --
   END derive_legislation;
--
-----------------------------------------------------------------------
-----------------------------------------------------------------------
-- PUBLIC FUNCTIONS
-----------------------------------------------------------------------
-----------------------------------------------------------------------
   --
   -----------------------------------------------------------------------
   --< Initialize_HR_Security >-------------------------------------------
   -----------------------------------------------------------------------
   --
   -- Description:
   --    This procedure is called during initialization of applications
   --    that use the HR secure user functionality.  It determines the
   --    security profile and business group to use for the session based
   --    on the user_id, responsibility_id, application_id and
   --    security_group_id of the session and set the appropriate profile
   --    values.
   --
   -- Arguments
   --   None.
   --
   PROCEDURE Initialize_HR_Security
   IS
   --
   l_security_profile_id NUMBER;
   l_null_row            per_security_profiles%rowtype;
   --
   BEGIN


      --
      -- 2876315
      --
      session_context := fnd_global.session_context ;

      -- HR Multi Tenancy Addition:- Bug 7501793
      if hr_multi_tenancy_pkg.is_multi_tenant_system then
        hr_multi_tenancy_pkg.set_context(null);
      end if;

      --
      -- Reset the package global just in case the initialization fails
      -- since we want to prevent the old value being used in a different
      -- session.
      --
      g_hr_security_profile := l_null_row;
      --
      -- Get the security profile to use for this session - note that this
      -- function call will transparently set the profile values for
      -- PER_SECURITY_PROFILE_ID and PER_BUSINESS_GROUP_ID.
      --
      l_security_profile_id :=
         Get_Security_Profile_ID
            (fnd_global.user_id
            ,fnd_global.resp_id
            ,fnd_global.resp_appl_id
            ,fnd_global.security_group_id
            );
      --
      -- If a security profile was found/returned then populate the package
      -- level global variable with the appropriate row for the ID
      -- from per_security_profiles.
      --
      IF l_security_profile_id IS NOT NULL THEN
         BEGIN
           select *
           into   hr_signon.g_hr_security_profile
           from   per_security_profiles
           where  security_profile_id = l_security_profile_id;
         EXCEPTION
            when NO_DATA_FOUND then
               --
               -- Ignore NO_DATA_FOUND error if context=0
               --
               if l_security_profile_id = 0 then
                  null;
               else
                  raise;
               end if;
         END;
      ELSE
         null;
      END IF;
      --
      -- call private procedure to identify legislation_code from bg_id
      -- and call hr_api to setup the application context
      -- HR_ESSION_DATA namespace LEG_CODE with the session's legislation_code.
      --
      derive_legislation;

   EXCEPTION
      WHEN OTHERS THEN
         generic_error('HR_SIGNON.INITIALIZE_HR_SECURITY', sqlcode, sqlerrm);
   END Initialize_HR_Security;
   --
END HR_SIGNON;

/

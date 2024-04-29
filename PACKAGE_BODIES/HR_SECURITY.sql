--------------------------------------------------------
--  DDL for Package Body HR_SECURITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_SECURITY" AS
/* $Header: hrscsec.pkb 120.5.12010000.3 2009/05/11 11:31:00 rnemani ship $ */
   --
   -- PRIVATE FUNCTIONS AND PROCEDURES
   --
   --
   -- This is the security profile id for the view security
   -- profile which is associated with the setup business group
   --
   VIEW_ALL_PROFILE  CONSTANT NUMBER := 0;
   --
   --
   -- 1999-07-19 Bug 775399. A value of -1 for the ORG_ID
   -- component of the 'client_info' string indicates that
   -- the user connected to apps but should not see any rows
   --
   VIEW_NO_ROWS_ORG_ID     CONSTANT NUMBER := -1;
   --
   g_apps_schema_mode      VARCHAR2(3);
   g_user_id               NUMBER;
   g_resp_id               NUMBER;
   g_resp_appl_id          NUMBER;
   g_security_group_id     NUMBER;
   g_person_id             NUMBER;
   g_context               per_security_profiles%ROWTYPE;
   g_view_no_rows          BOOLEAN;
   g_effective_date        DATE := sysdate;
   TYPE per_list is table of boolean index by binary_integer;
   g_person_list per_list;

   --
   -- DK 2001-11-17
   -- 2086208.  Cache the value of ICX_SEC.G_SESSION_ID so that the
   -- person list can be rebuilt on a change of login session even if
   -- the user,resp,sec group remain the same. An alternative scheme is
   -- to track session switching based on the value of
   -- FND_GLOBAL.SESSION_CONTEXT. This would cause the person list to
   -- be rebuilt on each call to FND_GLOBAL.APPS_INITIALIZE.
   --
   g_icx_session_id        NUMBER := 0 ;


   --
   -----------------------------------------------------------------------
   -----------------------------------------------------------------------
   -- begin BIS/discoverer section
   -----------------------------------------------------------------------
   --
   g_org_id_initialized          BOOLEAN        := FALSE;
   g_org_id                      VARCHAR2(15);
   g_mo_context                  per_security_profiles%ROWTYPE;
   g_mo_person_id                NUMBER;
   g_mo_org_sec_known            BOOLEAN;
   --
   -----------------------------------------------------------------------
   -- end BIS/discoverer section
   -----------------------------------------------------------------------
   --
   -----------------------------------------------------------------------
   --< raise_error >------------------------------------------------------
   -----------------------------------------------------------------------
   --
   -- Description:
   --    Raise an internal error. Not translated.
   --
   PROCEDURE raise_error
      (p_message in varchar2
      )
   IS
   BEGIN
      raise_application_error(-20001, p_message);
   END raise_error;
   --
   -- PUBLIC FUNCTIONS AND PROCEDURES
   --
   -----------------------------------------------------------------------
   --< get_hr_security_context >------------------------------------------
   -----------------------------------------------------------------------
   --
   FUNCTION get_hr_security_context
   RETURN NUMBER
   IS
   BEGIN
      return (hr_signon.g_hr_security_profile.security_profile_id);
   END get_hr_security_context;
   --
   -----------------------------------------------------------------------
   --< get_security_profile >---------------------------------------------
   -----------------------------------------------------------------------
   --
   FUNCTION get_security_profile
   RETURN NUMBER
   IS
   --
   l_security_profile_id number := -1;
   --
   CURSOR get_reporting_id
   IS
   SELECT security_profile_id
     FROM per_security_profiles
    WHERE reporting_oracle_username = USER;
   --
   BEGIN
      --
      -- Check the schema mode. APPS schemas have one of the following
      -- 'U' Universal (APPS schemas)
      -- 'M' Multi-lingual
      -- 'K' Multi-currency
      --
      -- In this case check the security profile
      --
      IF ( g_apps_schema_mode = 'Y' ) THEN
         --
         -- If the security context is not set then use the
         -- seeded view all security profile.
         --
         l_security_profile_id := NVL(get_hr_security_context,VIEW_ALL_PROFILE);
      ELSE
         --
         -- If the current schema is attached to a security profile
         -- then return that otherwise we are in a custom schema and
         -- so the view_all profile can be returned.
         --
         OPEN get_reporting_id;
         FETCH get_reporting_id INTO l_security_profile_id;
         --
         IF get_reporting_id%NOTFOUND THEN
            CLOSE get_reporting_id;
            l_security_profile_id := VIEW_ALL_PROFILE;
         END IF;
      END IF;
      --
      RETURN (l_security_profile_id);
   END get_security_profile;
  --
  -----------------------------------------------------------------------
  --< get_person_id >------------------------------------------------
  -----------------------------------------------------------------------
  --
  function get_person_id return number is
  --
  cursor get_sec_person_id(p_security_profile_id number) is
  select named_person_id
  from per_security_profiles
  where security_profile_id=p_security_profile_id;
  --
  cursor get_user_person_id(p_user_id number) is
  select employee_id
  from fnd_user
  where user_id=p_user_id;
  --
  l_person_id number;
  --
  begin
  --
  open get_sec_person_id(get_security_profile);
  fetch get_sec_person_id into l_person_id;
  close get_sec_person_id;
  if l_person_id is null then
    open get_user_person_id(g_user_id);
    fetch get_user_person_id into l_person_id;
    close get_user_person_id;
  end if;
  --
  return l_person_id;
  --
  end get_person_id;
  --
--
-----------------------------------------------------------------------
--< Sync_Person_Cache >------------------------------------------------
-----------------------------------------------------------------------
--
-- Description:
--
-- For the mean-time, two sets of person cache are maintained.
-- This is not ideal, but has been done to prevent regressions, both
-- functional and performance, using the evaluate_access method;
-- g_person_list will be obsoleted going forward.
-- Here people in hr_security_internal.g_per_tbl are added to
-- g_person_list for backwards compatibility.
--
PROCEDURE sync_person_cache
IS

    i NUMBER;

BEGIN

    --
    -- Sync the two sets of cache.
    --
    IF hr_security_internal.g_per_tbl.COUNT > 0 THEN
        i := hr_security_internal.g_per_tbl.FIRST;
        WHILE i <= hr_security_internal.g_per_tbl.LAST LOOP
            g_person_list(i) := TRUE;
            i := hr_security_internal.g_per_tbl.NEXT(i);
        END LOOP;
    END IF;

END sync_person_cache;
--
-----------------------------------------------------------------------
--< Initialise_Globals >-----------------------------------------------
-----------------------------------------------------------------------
--
-- Description:
--    This procedure will initialise all the package globals.  It is
--    called when any procedure in the package is first run, and also
--    whenever the user switches responsibility (and hence calls
--    the get_security_profile_id function which then in turns calls
--    this procedure).
--
PROCEDURE Initialise_Globals
IS
  --
  -- Retrieves the mode of the current schema together with
  -- the ORG_ID part of CLIENT_INFO for Bug 775399
  --
  -- 1999-07-19
  -- 1. Change SUBSTR to SUBSTRB
  -- 2. First column now returns 'Y' if the schema is of apps type
  --	'U' Universal (APPS schemas)
  --	'M' Multi-lingual
  --	'K' Multi-currency
  --
  CURSOR csr_get_schema_mode
  IS
  SELECT DECODE(READ_ONLY_FLAG,'U', 'Y'
                              ,'M', 'Y'
                              ,'K', 'Y'
                              ,'N') schema_mode,
         DECODE(SUBSTRB(USERENV('CLIENT_INFO'), 1, 1),' ', NULL,
                SUBSTRB(USERENV('CLIENT_INFO'),1, 10))
           FROM FND_ORACLE_USERID
          WHERE ORACLE_USERNAME = user;
  --
  -- Get the row from per_security_profiles corresponding to the
  -- security profile for the session
  --
  CURSOR csr_get_sec_prf(p_security_profile_id number)
  IS
  SELECT *
    FROM per_security_profiles
   WHERE security_profile_id = p_security_profile_id;

  --
  -- Gets the person stored against a given user.
  --
  CURSOR csr_get_person
      (p_user_id IN NUMBER) IS
  SELECT fndu.employee_id
  FROM   fnd_user fndu
  WHERE  p_user_id IS NOT NULL
  AND    fndu.user_id = p_user_id;

  --
  -- Cursors to build security cache.
  -- Bug 3346940.
  -- Added the "granted_user_id is null" clause to prevent
  -- this from picking up static user lists.
  --
  cursor get_people(p_security_profile_id number) is
  select person_id
    from per_person_list
   where security_profile_id=p_security_profile_id
   and   granted_user_id is null;

  --
  -- Bug 3584578.
  -- All supervisor security is now evaluated in
  -- hr_security_internal.evaluate_access.
  --
/*  cursor get_super_people(p_top_person_id number,
                          p_max_levels    number) is
  select asg.person_id
    from (select a.person_id,
                 a.supervisor_id
            from per_all_assignments_f a
            where trunc(sysdate) between a.effective_start_date
	                             and a.effective_end_date
              and assignment_type <> 'B') asg
   connect by asg.supervisor_id = prior asg.person_id
          and Level<=nvl(p_max_levels,Level)+1
   start with asg.person_id=p_top_person_id;
  --
  cursor get_super_people_ppl(p_security_profile_id     number,
                              p_top_person_id           number,
                              p_max_levels              number) is
  select asg.person_id
    from (select a.person_id,
                 a.supervisor_id
            from per_all_assignments_f a
           where trunc(sysdate) between a.effective_start_date
	                            and a.effective_end_date
             and assignment_type <> 'B') asg
   where exists (select null
                   from per_person_list ppl
                  where ppl.security_profile_id=p_security_profile_id
                    and ppl.person_id=asg.person_id)
  connect by asg.supervisor_id = prior asg.person_id
         and Level<=nvl(p_max_levels,Level)+1
  start with asg.person_id=p_top_person_id ;
  --
  cursor get_super_people_primary(p_top_person_id number,
                                  p_max_levels    number) is
  select asg.person_id
    from (select a.person_id,
                 a.supervisor_id
            from per_all_assignments_f a
            where trunc(sysdate) between a.effective_start_date
	                             and a.effective_end_date
              and assignment_type <> 'B'
              and a.primary_flag='Y') asg
  connect by asg.supervisor_id = prior person_id
         and Level<=nvl(p_max_levels,Level)+1
  start with asg.person_id=p_top_person_id ;
  --
  cursor get_super_people_primary_ppl(p_security_profile_id number,
                                      p_top_person_id       number,
                                      p_max_levels          number) is
  select asg.person_id
    from (select a.person_id,
                 a.supervisor_id
            from per_all_assignments_f a
           where trunc(sysdate) between a.effective_start_date
	                            and a.effective_end_date
             and assignment_type <> 'B'
             and a.primary_flag='Y' ) asg
   where exists (select null
                   from per_person_list ppl
                  where ppl.security_profile_id=p_security_profile_id
                    and ppl.person_id=asg.person_id)
  connect by asg.supervisor_id = prior asg.person_id
         and Level<=nvl(p_max_levels,Level)+1
  start with asg.person_id=p_top_person_id ;
*/

  l_security_profile_id number;
  l_what_to_evaluate    number;
  l_use_static_lists    boolean;
--
BEGIN
--
  -- DK 2001-11-17
  -- 2086208. Save the ICX session id when the person list is created.
  -- check_person_list calls initialize_globals if the value saved is
  -- different to the current value of icx_sec.g_session_id
  g_icx_session_id  := icx_sec.g_session_id;
  --
  -- Get the schema mode and org_id from client_info
  --
  OPEN  csr_get_schema_mode;
  FETCH csr_get_schema_mode into g_apps_schema_mode, g_org_id;
  CLOSE csr_get_schema_mode;
  --
  l_security_profile_id:=hr_security.get_security_profile;
  g_user_id:=fnd_global.user_id;
  g_resp_id:=fnd_global.resp_id;
  g_resp_appl_id:=fnd_global.resp_appl_id;
  g_security_group_id:=fnd_global.security_group_id;

  -- g_person_id:=get_person_id; -- Bug 2807573 see below
  -- g_person_list.delete; --6012095(forward port of 5985232)

  --
  IF (RTRIM(g_org_id) = TO_CHAR(VIEW_NO_ROWS_ORG_ID) AND g_apps_schema_mode = 'Y' ) THEN
    g_view_no_rows := TRUE;
    g_context := null;
  ELSE
    g_view_no_rows := FALSE;

    --
    -- Get the security profile information
    --
    OPEN csr_get_sec_prf(l_security_profile_id);
    FETCH csr_get_sec_prf INTO g_context;
    --
    IF csr_get_sec_prf%NOTFOUND THEN
       CLOSE csr_get_sec_prf;
       raise_error('HR SECURITY ERROR : INVALID PROFILE VALUE '||l_security_profile_id);
    ELSE
      CLOSE csr_get_sec_prf;
    END IF;

    --
    -- Bug 2807573 DK 17-FEB-2003
    --
    -- Initialization of g_person_id moved to avoid potentially
    -- unnecessary query.
    IF ( g_context.view_all_flag = 'N' ) THEN
       g_person_id:=get_person_id;
    END IF;

    --
    -- Reset this flag to false whenever security is re-initialised.
    -- This tells show_bis_record to re-evaluate organization security
    -- permissions using g_mo_context instead of g_context.
    --
    g_mo_org_sec_known := FALSE;

    --
    -- Get the security profile as set in the profile option
    -- 'MO:Security Profile'.
    --
    OPEN  csr_get_sec_prf(p_security_profile_id =>
          to_number(fnd_profile.value('XLA_MO_SECURITY_PROFILE_LEVEL')));
    FETCH csr_get_sec_prf INTO g_mo_context;
    CLOSE csr_get_sec_prf;

    --
    -- If MO: Security Profile is not set, use HR: Security Profile.
    --
    IF g_mo_context.security_profile_id IS NULL THEN
        g_mo_context   := g_context;
        g_mo_person_id := g_person_id;
    ELSE
        --
        -- Fetch the person from the MO profile.
        --
        IF (NVL(g_mo_context.view_all_flag, 'Y') = 'N') THEN
           IF g_mo_context.named_person_id IS NOT NULL THEN
              g_mo_person_id := g_mo_context.named_person_id;
           ELSE
              OPEN  csr_get_person(g_user_id);
              FETCH csr_get_person INTO g_mo_person_id;
              CLOSE csr_get_person;
           END IF;
        END IF;
    END IF;

    --
    -- Bug 3584578.
    -- All supervisor security is now evaluated in
    -- hr_security_internal.evaluate_access.

/*
    --
    -- look to see if we are using supervisor hierarchies

    -- DKERR 5/2002
    -- Performance fixes for Bug 2374967 made to
    --
    -- get_super_people
    -- get_super_people_ppl
    -- get_super_people_primary
    -- get_super_people_primary_ppl
    --
    -- See also 2041460
    --
    -- In each cursor we construct the list of all assignments as of today
    -- before we apply the hierarchical query condition ie
    -- "supervisor = prior person_id". This performs much better than the
    -- original version which applied the date restriction to assignment rows
    -- as part of the query condition. However these queries still require a
    -- of high amount of i/o and performance will depend on how much of
    -- the assignment table is already in the buffer cache.
    -- For this reason and also the amount of session memory required to
    -- cache potentially tens of thousands of person ids make this a less
    -- scaleable solution than building the cache on a demand basis from
    -- from a fixed number - possibly 3 levels.
    --
    -- Bug 3346940.
    -- The "supervisor_flag = 'Y'" excludes assignment-based supervisor
    -- hierarchies.  These are built separately in evaluate_access.
    -- Person-based hierarchies are build below, but only if there are
    -- not any user-based org or user-based pos restrictions.
    -- If there are user-based org or user-based pos restrictions, the
    -- person-based hierarchies are built in evaluate_access, not here.
    --
    if g_context.restrict_by_supervisor_flag = 'Y' then
      if  g_context.view_all_organizations_flag='Y'
      and g_context.view_all_positions_flag='Y'
      and g_context.view_all_payrolls_flag='Y'
      and g_context.custom_restriction_flag='N' then
        --
        -- we are only restricting by supervisor so do not
        -- join to per_person_list
        --
        if g_context.exclude_secondary_asgs_flag='Y' then
          --
          -- find all of the people who are in the supervisor hierarchy of
          -- primary assignments
          --
          for per_rec in get_super_people_primary(g_person_id
                                                 ,g_context.supervisor_levels)
          loop
            g_person_list(per_rec.person_id):=TRUE;
          end loop;
        else
          -- find all of the people who are in the supervisor hierarchy of
          -- any assignments
          for per_rec in get_super_people(g_person_id
                                         ,g_context.supervisor_levels) loop
            g_person_list(per_rec.person_id):=TRUE;
          end loop;
         end if;

      elsif NVL(g_context.top_organization_method, 'S') <> 'U'
        and NVL(g_context.top_position_method, 'S') <> 'U'
        and NVL(g_context.custom_restriction_flag, 'N') <> 'U'
        and NVL(g_context.restrict_on_individual_asg, 'N') <> 'Y' then
        --
        -- Bug 3346940.
        -- Only evaluate person-based supervisor security if user-based
        -- org, pos and custom security is not in use and (bug 3507431)
        -- the security is not on an individual assignment level.
        --
        -- we are also restricting by another thing, so join to
        --  per_person_list
        --
        if g_context.exclude_secondary_asgs_flag='Y' then
          --
          -- find all of the people who are in the supervisor hierarchy of
          -- primary assignments as well as the other security restrictions
	  --
          for per_rec in get_super_people_primary_ppl(l_security_profile_id
                                                 ,g_person_id
                                                 ,g_context.supervisor_levels)
          loop
            g_person_list(per_rec.person_id):=TRUE;
          end loop;

        else
          --
	  -- find all of the people who are in the supervisor hierarchy of
          -- any assignments as well as the other security restrictions
	  --
          for per_rec in get_super_people_ppl(l_security_profile_id
                                         ,g_person_id
                                         ,g_context.supervisor_levels) loop
            g_person_list(per_rec.person_id):=TRUE;
          end loop;
         end if;
      end if;
    end if;

    --
    -- The static per_person_list is now cached during evaluate_access
    -- so this code can be commented out.  Although this is cached
    -- into a separate table and synched up at the moment, it is
    -- expected that g_person_list can be obsoleted and replaced by
    -- g_per_tbl.
    --
    else
      --
      -- Bug 2807573 DK 17-FEB-2003
      --
      -- For a view all security profile we don't need to get
      -- the per_person_list. It should be empty for such a profile
      -- but checking involves a range scan and hence unnecessary i/o.
      --
      IF ( g_context.view_all_flag = 'N' ) THEN

         -- we are not restricting by hierarchy, so
         -- find all of the people who are in the security profile
         for per_rec in get_people(l_security_profile_id) loop
           g_person_list(per_rec.person_id):=TRUE;
         end loop;
      END IF ;

    end if;
*/
    --
    -- The below call to evaluate_access determines all the security
    -- permissions for the logged on user and caches lists of their
    -- orgs, positions, people, etc.
    --
    -- Where user-based security or assignment-level security is used,
    -- the security is dynamically assessed, otherwise it picks up
    -- the permissions from per_person_list.
    --
    -- hr_security_internal.evaluate_access keeps a separate person
    -- cache at the moment, although it is expected that g_person_list
    -- can be completely replaced by g_per_tbl in the near future
    -- (this exercise requires references to g_person_list to be
    --  replaced by g_per_tbl).
    --
    if (g_context.view_all_flag = 'N' ) then
        --
        -- Fetch the parameters that allow different modelling options.
        -- THESE PARAMETERS ARE FOR DEVELOPMENT USE ONLY AT PRESENT.
        --
        g_effective_date   := hr_security_internal.get_effective_date;
        l_what_to_evaluate := hr_security_internal.get_what_to_evaluate;
        l_use_static_lists := hr_security_internal.get_use_static_lists;

        hr_security_internal.evaluate_access
            (p_person_id        => g_person_id
            ,p_user_id          => g_user_id
            ,p_effective_date   => g_effective_date
            ,p_sec_prof_rec     => g_context
            ,p_what_to_evaluate => l_what_to_evaluate
            ,p_use_static_lists => l_use_static_lists);

        --
        -- The two sets of person cache are synched.
        --
        --sync_person_cache;  --6012095(Forward Port of 5985232)

    end if;

/*  --
    -- GRANTED USERS ARE NOW ADDED IN EVALUATE_ACCESS
    --
    -- add granted users if using a restricted profile.
    -- A user can have been granted access to a person but still be using
    -- a view all responsiblity. In which case there will be rows in
    -- PER_PERSON_LIST but as this is a view all profile we can ignore them.
    --
    -- 2807573 21-FEB-2003
    -- Only deal with grant access when using a restricted profile.
    --
    if (g_context.view_all_flag = 'N' ) then
      if g_context.allow_granted_users_flag='Y' then
        for per_rec in get_granted_users(g_user_id) loop
          g_person_list(per_rec.person_id):=TRUE;
        end loop;
      end if;
    end if;
*/

    -- remove the current user if required.
    if g_context.exclude_person_flag='Y' then
      --g_person_list.delete(g_person_id);--6012095 (Forward port of 5985232)
      hr_security_internal.g_per_tbl.delete(g_person_id);
    end if;
    --

  END IF;

END Initialise_Globals;
   --
   -----------------------------------------------------------------------
   --< view_all >---------------------------------------------------------
   -----------------------------------------------------------------------
   --
   FUNCTION view_all return varchar2
   IS
   BEGIN

        --
        -- 2876315
        --
        if ( hr_signon.session_context <> fnd_global.session_context )
        then
          hr_signon.initialize_hr_security;
          initialise_globals;
        end if;


        RETURN (NVL(hr_signon.g_hr_security_profile.view_all_flag
                   ,g_context.view_all_flag));


   END view_all;
   --
   -----------------------------------------------------------------------
   --< no_restrictions >--------------------------------------------------
   -----------------------------------------------------------------------
   --
   FUNCTION no_restrictions return boolean
   IS
   BEGIN

   --
   -- Bug 2638726
   -- DK 18-NOV-2002 Modified to use hr_signon cache
   --

   if  (NVL(hr_signon.g_hr_security_profile.restrict_by_supervisor_flag,
            g_context.restrict_by_supervisor_flag) = 'N'
   and  NVL(hr_signon.g_hr_security_profile.view_all_organizations_flag,
            g_context.view_all_organizations_flag) = 'Y'
   and  NVL(hr_signon.g_hr_security_profile.view_all_positions_flag,
            g_context.view_all_positions_flag)     = 'Y'
   and  NVL(hr_signon.g_hr_security_profile.view_all_payrolls_flag,
            g_context.view_all_payrolls_flag)      = 'Y'
   and  NVL(hr_signon.g_hr_security_profile.custom_restriction_flag,
            g_context.custom_restriction_flag)     = 'N' ) then
           RETURN true;
   else
           RETURN false;
   end if;
   END no_restrictions;
   -----------------------------------------------------------------------
   --< view_all_applicants >----------------------------------------------
   -----------------------------------------------------------------------
   --
   FUNCTION view_all_applicants
   RETURN BOOLEAN
   IS
   BEGIN
     if (NVL(hr_signon.g_hr_security_profile.view_all_applicants_flag
             ,g_context.view_all_applicants_flag) = 'Y') then
        RETURN  TRUE;
     else
        return FALSE;
     end if;
   END view_all_applicants;
   --

   -----------------------------------------------------------------------
   --< view_all_cwk >-----------------------------------------------------
   -----------------------------------------------------------------------
   --
   FUNCTION view_all_cwk
   RETURN BOOLEAN
   IS
   BEGIN
     if NVL(hr_signon.g_hr_security_profile.view_all_cwk_flag
           ,g_context.view_all_cwk_flag) = 'Y'  then
       return true;
     else
       return false;
     end if;
   END view_all_cwk;
   --
   -----------------------------------------------------------------------
   --< view_all_contacts >------------------------------------------------
   -----------------------------------------------------------------------
   --
   FUNCTION view_all_contacts
   RETURN BOOLEAN
   IS
   BEGIN
     if NVL(hr_signon.g_hr_security_profile.view_all_contacts_flag
           ,g_context.view_all_contacts_flag) = 'Y' then
       return true;
     else
       return false;
     end if;
   END view_all_contacts;
   --
   -----------------------------------------------------------------------
   --< view_all_candidates >----------------------------------------------
   -----------------------------------------------------------------------
   --
   function view_all_candidates return boolean is
     --
   begin
     -- This function will return TRUE if iRecruitment is not installed
     -- or view_all_candidates_flag is set to 'All'.
     if (nvl(hr_signon.g_hr_security_profile.view_all_candidates_flag,
             g_context.view_all_candidates_flag) = 'Y' or
         nvl(fnd_profile.value('IRC_INSTALLED_FLAG'), 'N') = 'N') then
       --
       return true;
       --
     else
       --
       return false;
       --
     end if;
     --
   end view_all_candidates;
   --
   -----------------------------------------------------------------------
   --< view_all_employees >-----------------------------------------------
   -----------------------------------------------------------------------
   --
   FUNCTION view_all_employees
   RETURN BOOLEAN
   IS
   BEGIN
     if NVL(hr_signon.g_hr_security_profile.view_all_employees_flag
           ,g_context.view_all_employees_flag) = 'Y' then
       return true;
     else
       return false;
     end if;
   END view_all_employees;
   --
   -----------------------------------------------------------------------
   --< restricted_applicants >----------------------------------------------
   -----------------------------------------------------------------------
   --
   FUNCTION restricted_applicants
   RETURN BOOLEAN
   IS
   BEGIN
     if (NVL(hr_signon.g_hr_security_profile.view_all_applicants_flag
             ,g_context.view_all_applicants_flag) = 'N') then
        RETURN  TRUE;
     else
        return FALSE;
     end if;
   END restricted_applicants;
   --
   -----------------------------------------------------------------------
   --< restricted_cwk >-----------------------------------------------------
   -----------------------------------------------------------------------
   --
   FUNCTION restricted_cwk
   RETURN BOOLEAN
   IS
   BEGIN
     if NVL(hr_signon.g_hr_security_profile.view_all_cwk_flag
           ,g_context.view_all_cwk_flag) = 'N'  then
       return true;
     else
       return false;
     end if;
   END restricted_cwk;
   --
   -----------------------------------------------------------------------
   --< restricted_contacts >------------------------------------------------
   -----------------------------------------------------------------------
   --
   FUNCTION restricted_contacts
   RETURN BOOLEAN
   IS
   BEGIN
     if NVL(hr_signon.g_hr_security_profile.view_all_contacts_flag
           ,g_context.view_all_contacts_flag) = 'N' then
       return true;
     else
       return false;
     end if;
   END restricted_contacts;
   --
   -----------------------------------------------------------------------
   --< restricted_employees >-----------------------------------------------
   -----------------------------------------------------------------------
   --
   FUNCTION restricted_employees
   RETURN BOOLEAN
   IS
   BEGIN
     if NVL(hr_signon.g_hr_security_profile.view_all_employees_flag
           ,g_context.view_all_employees_flag) = 'N' then
       return true;
     else
       return false;
     end if;
   END restricted_employees;
   --
   -----------------------------------------------------------------------
   --< view_all_organizations >-------------------------------------------
   -----------------------------------------------------------------------
   --
   FUNCTION view_all_organizations
   RETURN BOOLEAN
   IS
   BEGIN
      RETURN
         (NVL(hr_signon.g_hr_security_profile.view_all_organizations_flag
             ,g_context.view_all_organizations_flag) = 'Y' );
   END view_all_organizations;
   --
   -----------------------------------------------------------------------
   --< view_all_positions >-----------------------------------------------
   -----------------------------------------------------------------------
   --
   FUNCTION view_all_positions
   RETURN BOOLEAN
   IS
   BEGIN
      RETURN
         (NVL(hr_signon.g_hr_security_profile.view_all_positions_flag
             ,g_context.view_all_positions_flag) = 'Y' );
   END view_all_positions;
   --
   -----------------------------------------------------------------------
   --< restrict_by_supervisor >-------------------------------------------
   -----------------------------------------------------------------------
   --
   FUNCTION restrict_by_supervisor
   RETURN BOOLEAN
   IS
   BEGIN
      RETURN
         (NVL(hr_signon.g_hr_security_profile.restrict_by_supervisor_flag
             ,g_context.restrict_by_supervisor_flag) = 'Y' );
   END restrict_by_supervisor;
   --
  --
   --
   -----------------------------------------------------------------------
   --< view_all_payrolls >------------------------------------------------
   -----------------------------------------------------------------------
   --
   FUNCTION view_all_payrolls
   RETURN BOOLEAN
   IS
   BEGIN
      RETURN
         (NVL(hr_signon.g_hr_security_profile.view_all_payrolls_flag
             ,g_context.view_all_payrolls_flag) = 'Y' );
   END view_all_payrolls;
   --
  --
   --
   -----------------------------------------------------------------------
   --< exclude_person >------------------------------------------------
   -----------------------------------------------------------------------
   --
   FUNCTION exclude_person
   RETURN BOOLEAN
   IS
   BEGIN
      RETURN
         (NVL(hr_signon.g_hr_security_profile.exclude_person_flag
             ,g_context.exclude_person_flag) = 'Y' );
   END exclude_person;
   --
   -----------------------------------------------------------------------
   --< check_person_list >------------------------------------------------
   -----------------------------------------------------------------------
   --
   FUNCTION check_person_list
    (p_person_id  IN  NUMBER
    )
   RETURN BOOLEAN
   IS
   begin

     IF globals_need_refreshing THEN
       hr_signon.initialize_hr_security;
       initialise_globals;
     END IF;
     --
     -- return g_person_list.exists(p_person_id); -- Fixed for bug 5985232
     return hr_security_internal.g_per_tbl.exists(p_person_id); -- Fixed for bug 5985232 (6320769)

   END check_person_list;
   --
   -- Added for Bug 8465433
   -----------------------------------------------------------------------
   --< check_vac_person_list >------------------------------------------------
   -----------------------------------------------------------------------
   --
   FUNCTION check_vac_person_list
    (p_person_id  IN  NUMBER
    )
   RETURN BOOLEAN
   IS
   begin

     IF globals_need_refreshing THEN
       initialise_globals;
     END IF;
     return hr_security_internal.g_vac_per_tbl.exists(p_person_id);

   END check_vac_person_list;
   --
   -----------------------------------------------------------------------
   --< globals_need_refreshing >------------------------------------------
   -----------------------------------------------------------------------
   --
   FUNCTION globals_need_refreshing
   RETURN BOOLEAN
   IS

     l_return BOOLEAN;

   BEGIN

    --- DK 2001-11-17
    ---
    --- Bug 2086208
    --- Along with changes in the cached values of user,resp and security group
    --- a change in the ICX session id causes the person list to be rebuilt.
    --- Ideally this would be signalled via the product initialization code
    ---

     IF g_user_id           <> fnd_global.user_id
     or g_resp_id           <> fnd_global.resp_id
     or g_resp_appl_id      <> fnd_global.resp_appl_id
     or g_security_group_id <> fnd_global.security_group_id
     or g_icx_session_id    <> icx_sec.g_session_id
     THEN
       l_return := TRUE;
     ELSE
       l_return := FALSE;

     END IF;
     --
     return l_return;

   END globals_need_refreshing;
   --
   -----------------------------------------------------------------------
   --< check_organization_list >------------------------------------------
   -----------------------------------------------------------------------
   --
   FUNCTION check_organization_list
      (p_organization_id  IN  NUMBER
      )
   RETURN BOOLEAN
   IS
   --
   CURSOR chk_org_list
   IS
   SELECT 1
     FROM per_organization_list
    WHERE security_profile_id = get_security_profile
      AND organization_id = p_organization_id;
   --
   l_return_value BOOLEAN;
   l_dummy        NUMBER;
   --
   BEGIN
      OPEN chk_org_list;
      FETCH chk_org_list INTO l_dummy;
      l_return_value := chk_org_list%FOUND;
      CLOSE chk_org_list;
      --
      RETURN (l_return_value);
   END check_organization_list;
   --
   -----------------------------------------------------------------------
   --< check_position_list >----------------------------------------------
   -----------------------------------------------------------------------
   --
   FUNCTION check_position_list
      (p_position_id  IN  NUMBER
      )
   RETURN BOOLEAN
   IS
   CURSOR chk_pos_list IS
   SELECT 1
     FROM per_position_list
    WHERE security_profile_id = get_security_profile
      AND position_id = p_position_id;
   --
   l_return_value BOOLEAN;
   l_dummy        NUMBER;
   --
   BEGIN
      OPEN chk_pos_list;
      FETCH chk_pos_list INTO l_dummy;
      l_return_value := chk_pos_list%FOUND;
      CLOSE chk_pos_list;
      --
      RETURN (l_return_value);
   END check_position_list;
   --
   -----------------------------------------------------------------------
   --< check_payroll_list >-----------------------------------------------
   -----------------------------------------------------------------------
   --
   FUNCTION check_payroll_list
      (p_payroll_id IN NUMBER
      )
   RETURN BOOLEAN
   IS
   CURSOR chk_pay_list
   IS
   SELECT 1
     FROM pay_payroll_list
    WHERE security_profile_id = get_security_profile
      AND payroll_id = p_payroll_id;
   --
   l_return_value boolean;
   l_dummy        number;
   --
   BEGIN
      OPEN chk_pay_list;
      FETCH chk_pay_list INTO l_dummy;
      l_return_value := chk_pay_list%FOUND;
      CLOSE chk_pay_list;
      --
      RETURN (l_return_value);
   END check_payroll_list;
   --
   -----------------------------------------------------------------------
   --< show_person >-- overloaded and called directly from secure views --
   -----------------------------------------------------------------------
   --
   function show_person(
            p_person_id              in number
           ,p_current_applicant_flag in varchar2
           ,p_current_employee_flag  in varchar2
           ,p_current_npw_flag       in varchar2
           ,p_employee_number        in varchar2
           ,p_applicant_number       in varchar2
           ,p_npw_number             in varchar2
           ) return varchar2 is
     --
   begin
     -- if the profile excludes users, prevent the logged on user from seeing
     -- themselves under any circumstances.
     if (p_person_id = g_person_id and exclude_person) then
       --
       return 'FALSE';
       --
     end if;
     -- Return TRUE if the security profile has no person restrictions.
     if (view_all = 'Y' or
        (view_all_employees and view_all_applicants and view_all_cwk and
         view_all_contacts and view_all_candidates)) then
       --
       return 'TRUE';
       --
     end if;
     -- Return TRUE if the security profile has no work structure
     -- restrictions and the person restriction is "Restricted" for this
     -- type of person.
     if (no_restrictions and
        ((p_current_employee_flag = 'Y' and restricted_employees) or
         (p_current_applicant_flag = 'Y' and restricted_applicants) or
         (p_current_npw_flag = 'Y' and restricted_cwk) or
         (p_employee_number is null and p_applicant_number is null and
          p_npw_number is null and restricted_contacts and
          view_all_candidates))) then
       --
       return 'TRUE';
       --
     end if;
     -- Return TRUE if the security profile is view all contacts or you
     -- can see all the other types of people (and so contacts too)
     -- and where this person is a contact.

     -- A condition with view_all_contacts_flag = All and
     -- view_all_candidates_flag = None, will not be taken care in below
     -- IF condition. ie: in such a scenario, its been decided that contacts
     -- will be populated in per_person_list through PERSLM. Thereby this
     -- function (SHOW_PERSON) will return a TRUE through CHECK_PERSON_LIST.

     -- Contacts     Candidates     Contacts cached
     -- ------------------------------------------
     -- All          All            No
     -- All          None           Yes
     -- Restricted   All            Yes
     -- Restricted   None           Yes
     if view_all_contacts and view_all_candidates and
        p_employee_number is null and p_applicant_number is null and
        p_npw_number is null then
       --
       return 'TRUE';
       --
     end if;
     -- Return TRUE if the profile has restrictions but they
     -- are not relevant to this person.

     -- Applicants are treated different: they must be only
     -- an applicant and not an employee / contingent worker
     -- to immediately return TRUE.  This prevents emps or
     -- cwks being visible in an applicant-only security
     -- profile.  Applicants who are also emps and cwks will
     -- have their security determined by listgen so the person
     -- list must be checked in this example.
     if (p_current_employee_flag = 'Y' and view_all_employees) or
        (p_current_npw_flag = 'Y' and view_all_cwk) or
        (p_current_applicant_flag ='Y' and nvl(p_current_npw_flag, 'N') = 'N'
        and nvl(p_current_employee_flag, 'N') = 'N'
        and view_all_applicants) then
       --
       return 'TRUE';
       --
     end if;
     --
     if view_all_applicants and p_applicant_number is not null and
        p_employee_number is null and p_npw_number is null then
        -- Profile is view all applicants, person is or has been an applicant
        -- and they person have not been an employee/cont worker so grant
        -- access.  If the person is/was an Emp/CWK then grant access based
        -- on Emp/CWK criteria i.e. if the person is also an Emp and is
        -- visible then grant access.  This does mean that an Ex-Emp and Apl
        -- will disappear from a view_all_applicants/restricted employees
        -- profile on termination of the application if the terminated Emp
        -- assignment does not allow access to this person for this profile.
        -- i.e. the profile allows access to Emps in "Org 1" but when the
        -- person was an employee they were in "Org 2".

        -- This is slightly inconsistent with behaviour of PERSLM when
        -- granting access to Ex-Emp and Ex-Apl people for profiles which
        -- are restricted_employees and restricted_applicants but is better
        -- than the current situation.

        -- We could/do have similar problems with view_all_emp and
        -- view_all_npw profiles but it's less likely that customers have
        -- view_all_emp/npw profiles.  For now we'll ignore these cases.
       return 'TRUE';
       --
     end if;

     -- code start for bug 8242764
     if ( no_restrictions and view_all_employees) then
       if (( (not view_all_cwk) and nvl(p_current_npw_flag, 'N') = 'Y' )
         or
         ( (not view_all_applicants) and nvl(p_current_applicant_flag, 'N') = 'Y' ))
       then
          NULL;
       else
	       if(HR_GENERAL2.is_person_type(p_person_id,'EX_EMP',g_effective_date)) then
	         return 'TRUE';
	       end if;
       end if;
     end if;
     -- code end for bug 8242764

     -- If security evaluation was deferred at logon, or if the person/
     -- assignment permissions are unknown for some other reason, use
     -- caching on demand to evaluate permissions on the fly.
     if not hr_security_internal.per_access_known then
       -- Passing a value to p_what_to_evaluate avoids evaluating
       -- permissions for irrelevant security criteria.
       hr_security_internal.evaluate_access(
          p_person_id        => g_person_id
         ,p_user_id          => g_user_id
         ,p_effective_date   => g_effective_date
         ,p_sec_prof_rec     => g_context
         ,p_what_to_evaluate => hr_security_internal.g_per_sec_only);
       -- The two sets of person cache are synched.
       --sync_person_cache;--Fixed for bug 6012095(Fwd port of 5985232)
       --
     end if;
     -- We must check the person list to determine this person's security.
     if check_person_list(p_person_id) then
       --
       return 'TRUE';
       --
     end if;
     -- This person cannot be visible.
     return 'FALSE';
     --
   end show_person;
   --
   -----------------------------------------------------------------------
   --< show_person >--- original called from show_record -----------------
   -----------------------------------------------------------------------
   --
   FUNCTION show_person
      (p_person_type_id   IN  NUMBER
      ,p_person_id        IN  NUMBER
      ,p_employee_number  IN  VARCHAR2
      ,p_applicant_number IN  VARCHAR2
      )
    RETURN VARCHAR2
    IS
     BEGIN
     --   added for bug 4193763
  if (p_person_id = g_person_id and exclude_person) then
       --
       return 'FALSE';
       --
      end if;

   --   added for bug 4193763
     --
      -- If View All is set to 'Yes' OR
      --    the profile is view all contact and both the numbers are null OR
      --    the profile is view all emp/apl/cwk
      --
      IF    view_all = 'Y'
        OR (view_all_contacts AND
	    view_all_employees  AND
            view_all_applicants AND
            view_all_cwk) THEN
        RETURN 'TRUE';
      END IF;

      --
      -- Return TRUE if the security profile is view all contacts and
      -- this person is a contact.
      --
      IF view_all_contacts          AND
        p_employee_number is null   AND
	p_applicant_number is null  THEN
	return 'TRUE';
      END IF;

      --
      -- If View All Employees is 'Yes' and this is an employee
      --
      IF   (view_all_employees AND p_employee_number IS NOT NULL)
        OR (view_all_employees AND p_employee_number IS NOT NULL) THEN
        --
        -- If this is the excluding person return false
        --
	-- added for bug 4193763
	-- commented the if condition
       -- if exclude_person and p_person_id=g_person_id then
         -- RETURN 'FALSE';
       -- else
          RETURN 'TRUE';
       -- end if;
       -- added for bug 4193763
      --
      -- If View All Applicants is 'Yes' and this is an applicant
      --
      ELSIF p_applicant_number IS NOT NULL THEN
        if view_all_applicants and view_all_employees and view_all_cwk then
           RETURN 'TRUE';
        end if;
      END IF;

      --
      -- If security evaluation was deferred at logon,
      -- or if the person / assignment permissions are unknown for
      -- some other reason, use caching on demand to evaluate
      -- permissions on the fly.
      --
      IF NOT hr_security_internal.per_access_known THEN
          --
          -- Passing a value to p_what_to_evaluate avoids evaluating
          -- permissions for irrelevant security criteria.
          --
          hr_security_internal.evaluate_access
              (p_person_id        => g_person_id
              ,p_user_id          => g_user_id
              ,p_effective_date   => g_effective_date
              ,p_sec_prof_rec     => g_context
              ,p_what_to_evaluate => hr_security_internal.g_PER_SEC_ONLY);

          --
          -- The two sets of person cache are synched.
          --
          --sync_person_cache; --6012095(Forward Port of 5985232)

      END IF;

      --
      -- Check the global pl/sql table for the person
      --
      IF check_person_list(p_person_id) THEN
        RETURN 'TRUE';

      END IF;
      RETURN 'FALSE';
   END show_person;
   --
   -----------------------------------------------------------------------
   --< show_asg_for_per >-------------------------------------------------
   -----------------------------------------------------------------------
   --
   -- This function is private.  To make use of this function, use the
   -- wrapper function show_record (which is public).
   --
   -- This function has been renamed from show_assignment to
   -- show_asg_for_per as part of the assignment and user security
   -- changes (bug 3346940).  This function assesses assignment security
   -- at the person level, i.e., if you can see the person you can see
   -- all their assignments.
   --
   -- show_record calls this function by default unless another parameter
   -- is passed to show_record, in which case it calls show_assignment.
   --
   FUNCTION show_asg_for_per
      (p_assignment_id    IN  NUMBER
      ,p_person_id        IN  NUMBER
      ,p_assignment_type  IN  VARCHAR2
      )
   RETURN VARCHAR2 IS

   BEGIN
  --
  -- added for bug 4193763
   if (p_person_id = g_person_id and exclude_person) then
       --
       return 'FALSE';
       --
     end if;
  -- added for bug 4193763
  --
      IF ((view_all = 'Y')
          OR (view_all_employees AND
              view_all_applicants AND
              view_all_cwk  AND
              view_all_contacts)
          OR (no_restrictions))
      THEN
         RETURN 'TRUE';
      ELSIF (view_all_applicants AND p_assignment_type = 'A') THEN
         RETURN 'TRUE';
      ELSIF (view_all_employees AND p_assignment_type = 'E') THEN
         RETURN 'TRUE';
      ELSIF (view_all_CWK AND p_assignment_type = 'C') THEN
         RETURN 'TRUE';
      ELSIF (check_person_list(p_person_id)) THEN
         RETURN 'TRUE';
      ELSE
         RETURN 'FALSE';
      END IF;
   END show_asg_for_per;
   --
   -----------------------------------------------------------------------
   --< show_assignment >--------------------------------------------------
   -----------------------------------------------------------------------
   --
   -- This function is private.  To make use of this function, use the
   -- wrapper function show_record (which is public).
   --
   -- This function has been added as part of the assignment
   -- and user security changes (bug 3346940).  The previous
   -- show_assignment, which assesses security at a person level, has
   -- been re-named to show_asg_for_per.
   --
   -- This function assesses security for each individual assignment.
   --
   -- show_record calls this function if an additional parameter is
   -- passed to show_record.
   --
   FUNCTION show_assignment
      (p_assignment_id    IN  NUMBER
      ,p_person_id        IN  NUMBER
      ,p_assignment_type  IN  VARCHAR2
      )
   RETURN VARCHAR2 IS

   BEGIN

      --
      -- Exclude the current user or named user if set.
      --
      IF exclude_person
       AND p_person_id = g_person_id
      THEN
         RETURN 'FALSE';
      END IF;

      --
      -- Assess the permissions using the given parameters if
      -- possible.
      --
      IF ((view_all = 'Y')
          OR (view_all_employees AND
              view_all_applicants AND
              view_all_cwk  AND
              view_all_contacts)
          OR (no_restrictions))
      THEN
          RETURN 'TRUE';
      ELSIF (view_all_applicants AND p_assignment_type = 'A') THEN
          RETURN 'TRUE';
      ELSIF (view_all_employees AND p_assignment_type = 'E') THEN
          RETURN 'TRUE';
      ELSIF (view_all_cwk AND p_assignment_type = 'C') THEN
          RETURN 'TRUE';
      END IF;

      --
      -- If security evaluation was deferred at logon,
      -- or if the person / assignment permissions are unknown for
      -- some other reason, use caching on demand to evaluate
      -- permissions on the fly.
      --
      IF NOT hr_security_internal.per_access_known THEN
          --
          -- Passing a value to p_what_to_evaluate avoids evaluating
          -- permissions for irrelevant security criteria.
          --
          hr_security_internal.evaluate_access
              (p_person_id        => g_person_id
              ,p_user_id          => g_user_id
              ,p_effective_date   => g_effective_date
              ,p_sec_prof_rec     => g_context
              ,p_what_to_evaluate => hr_security_internal.g_PER_SEC_ONLY);

          --
          -- The two sets of person cache are synched.
          --
          --sync_person_cache;--(Fwd port of 5985232)

      END IF;

      --
      -- If restricting at an individual assignment level, check
      -- the assignments list, rather than the person list.
      --
      IF NVL(g_context.restrict_on_individual_asg, 'N') = 'Y'
      THEN
          IF hr_security_internal.g_asg_tbl.EXISTS(p_assignment_id) THEN
              RETURN 'TRUE';
          ELSE
              RETURN 'FALSE';
          END IF;
      ELSE
          --
          -- For safety, continue using check_person_list rather than
          -- referencing hr_security_internal.g_per_tbl until
          -- evaluate_access does all the work.
          --
          IF check_person_list(p_person_id) THEN
              RETURN 'TRUE';
          ELSE
              RETURN 'FALSE';
          END IF;
      END IF;

   END show_assignment;
   --
   -----------------------------------------------------------------------
   --< show_organization >------------------------------------------------
   -----------------------------------------------------------------------
   --
   FUNCTION show_organization
     (p_organization_id  IN  NUMBER
      )
   RETURN VARCHAR2
   IS
   BEGIN

       --
       -- The revised changes here made for enhancement 3346940
       -- obsolete check_organization_list (it is no longer used).
       -- Instead the cached organization list is accessed directly.
       --

       --
       -- Immediately return true if there is no security.
       --
       IF (view_all = 'Y' OR view_all_organizations) THEN
           RETURN 'TRUE';
       END IF;

       --
       -- If security evaluation was deferred at logon,
       -- or if organization permissions are unknown for
       -- some other reason, use caching on demand to evaluate
       -- permissions on the fly.
       --
       IF NOT hr_security_internal.org_access_known THEN
           --
           -- Passing a value to p_what_to_evaluate avoids evaluating
           -- permissions for non-org security criteria.
           --
           hr_security_internal.evaluate_access
               (p_person_id        => g_person_id
               ,p_user_id          => g_user_id
               ,p_effective_date   => g_effective_date
               ,p_sec_prof_rec     => g_context
               ,p_what_to_evaluate => hr_security_internal.g_ORG_SEC_ONLY);
       END IF;

       IF hr_security_internal.g_org_tbl.EXISTS(p_organization_id) THEN
           RETURN 'TRUE';
       ELSE
           RETURN 'FALSE';
       END IF;

   END show_organization;
   --
   -----------------------------------------------------------------------
   --< show_position >----------------------------------------------------
   -----------------------------------------------------------------------
   --
   FUNCTION show_position
      (p_position_id  IN  NUMBER
      )
   RETURN VARCHAR2
   IS
   BEGIN

       --
       -- The revised changes here made for enhancement 3346940
       -- obsolete check_position_list (it is no longer used).
       -- Instead the cached position list is accessed directly.
       --

       --
       -- Immediately return true if there is no security.
       --
       IF (view_all = 'Y' OR view_all_positions) THEN
           RETURN 'TRUE';
       END IF;

       --
       -- If security evaluation was deferred at logon,
       -- or if position permissions are unknown for
       -- some other reason, use caching on demand to evaluate
       -- permissions on the fly.
       --
       IF NOT hr_security_internal.pos_access_known THEN
           --
           -- Passing a value to p_what_to_evaluate avoids evaluating
           -- permissions for non-pos security criteria.
           --
           hr_security_internal.evaluate_access
               (p_person_id        => g_person_id
               ,p_user_id          => g_user_id
               ,p_effective_date   => g_effective_date
               ,p_sec_prof_rec     => g_context
               ,p_what_to_evaluate => hr_security_internal.g_POS_SEC_ONLY);
       END IF;

       IF hr_security_internal.g_pos_tbl.EXISTS(p_position_id) THEN
           RETURN 'TRUE';
       ELSE
           RETURN 'FALSE';
       END IF;

   END show_position;
   --
   -----------------------------------------------------------------------
   --< show_payroll >-----------------------------------------------------
   -----------------------------------------------------------------------
   --
   FUNCTION show_payroll
      (p_payroll_id  IN  NUMBER
      )
   RETURN VARCHAR2
   IS
   BEGIN

       --
       -- The revised changes here made for enhancement 3346940
       -- obsolete check_payroll_list (it is no longer used).
       -- Instead the cached payroll list is accessed directly.
       --

       --
       -- Immediately return true if there is no security.
       --
       IF (view_all = 'Y' OR view_all_payrolls) THEN
           RETURN 'TRUE';
       END IF;

       --
       -- If security evaluation was deferred at logon,
       -- or if payroll permissions are unknown for
       -- some other reason, use caching on demand to evaluate
       -- permissions on the fly.
       --
       IF NOT hr_security_internal.pay_access_known THEN
           --
           -- Passing a value to p_what_to_evaluate avoids evaluating
           -- permissions for non-pos security criteria.
           --
           hr_security_internal.evaluate_access
               (p_person_id        => g_person_id
               ,p_user_id          => g_user_id
               ,p_effective_date   => g_effective_date
               ,p_sec_prof_rec     => g_context
               ,p_what_to_evaluate => hr_security_internal.g_PAY_SEC_ONLY);
       END IF;

       IF hr_security_internal.g_pay_tbl.EXISTS(p_payroll_id) THEN
           RETURN 'TRUE';
       ELSE
           RETURN 'FALSE';
       END IF;

   END show_payroll;
   --
   -----------------------------------------------------------------------
   --< show_vacancy >-----------------------------------------------------
   -----------------------------------------------------------------------
   --
   FUNCTION show_vacancy
      (p_vacancy_id       IN  NUMBER
      ,p_organization_id  IN  NUMBER
      ,p_position_id      IN  NUMBER
      ,p_manager_id       IN  NUMBER
      ,p_security_method  IN  VARCHAR2
      ,p_business_group_id IN VARCHAR2 default null
      )
   RETURN VARCHAR2
   IS
     CURSOR CSR_TEAM is
     Select 1
       from irc_rec_team_members team
           ,per_all_people_f  per
           ,fnd_user usr
      where team.vacancy_id  = p_vacancy_id
        and team.party_id    = nvl(per.party_id, usr.customer_id)
        and per.person_id(+) = usr.employee_id
        and sysdate          between per.effective_start_date
	                         and per.effective_end_date
        and usr.user_id      = g_user_id;
      l_dummy number;
      l_user_in_team boolean;
      l_bg_id number;
   BEGIN

     -- Bug 5188828
     -- Vacancies should be restricted to BG of security profile when profile is local

        l_bg_id := get_sec_profile_bg_id;
        if (l_bg_id is not null and
          p_business_group_id is not null and
          l_bg_id <> p_business_group_id ) then
              return 'FALSE';
        end if;

      /*
      ** If the security profile is "View All" or the vacancy is
      ** "Unsecured" then allow access.
      */
      IF (   view_all = 'Y'
         OR  p_security_method = 'U') THEN
	 return 'TRUE';
      END IF;

      /*
      ** Check for Team security.
      */
      IF p_security_method = 'T' THEN
         open csr_team;
	 fetch csr_team into l_dummy;
	 IF csr_team %found THEN
	   close csr_team;
	   return 'TRUE';
	 ELSE
	   close csr_team;
	   return 'FALSE';
	 END IF;
      /*
      ** Check for Business and Team security.
      */
      ELSIF nvl(p_security_method,'B') = 'B' THEN

        IF     p_organization_id IS NULL
	   AND p_position_id     IS NULL
	   AND ((restrict_by_supervisor AND p_manager_id IS NULL)
		 OR (NOT restrict_by_supervisor)) THEN
           /*
	   ** The organization and position are NULL and either not using
	   ** supervisor security or we are using supervisor security but
	   ** the vacancy manager is NULL so allow access as there is nothing
	   ** to restrict by.
	   */
           RETURN 'TRUE';
        ELSIF (restrict_by_supervisor
	       AND (p_manager_id IS NULL
	                OR
		    (    p_manager_id IS NOT NULL
		     AND check_vac_person_list(p_manager_id))))
               OR  (NOT restrict_by_supervisor) THEN
	   /*
	   ** We are EITHER using supervisor security and either the manager is
	   ** NULL or we have access to the manager OR we are not using
	   ** supervisor security so grant access based Org and Pos.
	   */
           IF (    p_organization_id IS NOT NULL
	          AND p_position_id IS NULL) THEN
             RETURN show_organization(p_organization_id);
           ELSIF (    p_organization_id IS NOT NULL
	          AND p_position_id IS NOT NULL) THEN
             IF (     show_organization(p_organization_id) = 'TRUE'
                  AND show_position(p_position_id) = 'TRUE' )
             THEN
               RETURN 'TRUE';
--             ELSE
--               RETURN 'FALSE';
             END IF;
           ELSIF (     p_position_id IS NULL
	           AND p_organization_id IS NULL) then
	      RETURN 'TRUE';
	   ELSE
	     RETURN 'FALSE';
	   END IF;
        END IF;
	/*
	** No access based on org, pos and supervisor so check the team
	** access for this user.
	*/
        open csr_team;
	fetch csr_team into l_dummy;
	IF csr_team %found THEN
	  close csr_team;
	  return 'TRUE';
	ELSE
	  close csr_team;
	  return 'FALSE';
	END IF;
      END IF; /* security_method = 'B' */
   END show_vacancy;
   --
   -----------------------------------------------------------------------
   --< show_record >------------------------------------------------------
   -----------------------------------------------------------------------
   --
   FUNCTION show_record
      (p_table_name  IN  VARCHAR2
      ,p_unique_id   IN  NUMBER
      ,p_val1        IN  VARCHAR2  DEFAULT NULL
      ,p_val2        IN  VARCHAR2  DEFAULT NULL
      ,p_val3        IN  VARCHAR2  DEFAULT NULL
      ,p_val4        IN  VARCHAR2  DEFAULT NULL
      ,p_val5        IN  VARCHAR2  DEFAULT NULL
      )
   RETURN VARCHAR2
   IS
   BEGIN

      --
      -- 3676633
      --
      IF ( globals_need_refreshing ) THEN
        hr_signon.initialize_hr_security;
        initialise_globals;
      END IF;


      IF (g_view_no_rows) THEN
         RETURN 'FALSE';
      END IF;
      --
      IF (p_table_name = 'PER_ALL_PEOPLE_F') THEN
         RETURN (show_person(p_person_id        => p_unique_id,
                             p_person_type_id   => p_val1,
                             p_employee_number  => p_val2,
                             p_applicant_number => p_val3));
      ELSIF (p_table_name = 'PER_ALL_ASSIGNMENTS_F') THEN
         --
         -- Assess assignment level security if the extra parameter
         -- is passed in, otherwise assess security at the person
         -- level (show_asg_for_per).
         --
         IF NVL(p_val3, 'N') = 'Y' THEN
            RETURN (show_assignment(p_assignment_id   => p_unique_id,
                                    p_person_id       => p_val1,
                                    p_assignment_type => p_val2 ));
         ELSE
            RETURN (show_asg_for_per(p_assignment_id   => p_unique_id,
                                     p_person_id       => p_val1,
                                     p_assignment_type => p_val2 ));
         END IF;
      ELSIF (p_table_name = 'HR_ALL_ORGANIZATION_UNITS') THEN
         RETURN (show_organization(p_organization_id => p_unique_id ));
      ELSIF (p_table_name = 'PER_ALL_POSITIONS' ) THEN
         RETURN (show_position(p_position_id => p_unique_id));
      ELSIF (p_table_name = 'PAY_ALL_PAYROLLS_F') THEN
         RETURN (show_payroll(p_payroll_id => p_unique_id));
      ELSIF (p_table_name = 'PER_ALL_VACANCIES') THEN
         RETURN (show_vacancy(p_vacancy_id      => p_unique_id,
                              p_organization_id => p_val1,
                              p_position_id     => p_val2,
			      p_manager_id      => p_val3,
			      p_security_method => p_val4,
			      p_business_group_id => p_val5));
      ELSE
         raise_error ('HR_SECURITY : INVALID TABLE NAME');
      END IF;
   END show_record;
   --
   -----------------------------------------------------------------------
   --< Show_BIS_Record >--------------------------------------------------
   -----------------------------------------------------------------------
   --
   -- Description:
   --    This procedure is used from BIS views to restrict records based
   --    on the organization.
   --
   FUNCTION Show_BIS_Record
   ( p_org_id in NUMBER
   )
   RETURN VARCHAR2
   IS

     l_pv_org_id          number;
     l_org_id             number;

     --
     -- Checks to see if there are any records in org_access for
     -- the current responsibility. fnd_global.resp_appl_id is used
     -- to improve index performance.
     --
     CURSOR c_chk_resp_in_org_access IS
     SELECT null
     FROM   org_access oa
     WHERE  oa.resp_application_id = g_resp_appl_id
     AND    oa.responsibility_id = g_resp_id;

     --
     -- Returns a single record in org_access that matches the
     -- current responsibility and p_org_id (if one exists).
     -- fnd_global.resp_appl_id is used to improve index performance.
     --
     CURSOR c_get_org_access_org IS
     SELECT oa.organization_id
     FROM   org_access oa
     WHERE  oa.resp_application_id = g_resp_appl_id
     AND    oa.responsibility_id = g_resp_id
     AND    oa.organization_id = p_org_id;

     --
     -- Gets all inventory orgs belonging to a particular operating unit.
     --
     CURSOR c_get_inventory_org (org_id IN NUMBER) IS
     SELECT null
     FROM   hr_organization_information oi
     WHERE  oi.organization_id = p_org_id
     AND    oi.org_information_context = 'Accounting Information'
     AND    to_number(oi.org_information3) = org_id;


   BEGIN

      --
      -- If p_org_id is null then always show the record.
      --
      IF (p_org_id IS NULL) THEN
         RETURN 'TRUE';
      END IF;

      IF globals_need_refreshing THEN
        --
        -- Bug 3476231.
        -- This bug-fix adds support for all HRMS organization security
        -- features.  In addition to supporting operating unit and
        -- inventory org security features, it supports organization
        -- hierarchy, include and exclude orgs and user-based organization
        -- security.
        -- To do this effectively, it is now necessary to re-initialise
        -- security whenever the user, resp, etc. changes, hence the
        -- globals_need_refreshing function call.
        --
        -- This function re-evaluates organization security using the
        -- MO: Security Profile instead of HR: Security Profile
        -- by calling evaluate_access with the g_mo_contexts (see below).
        -- If MO: Security Profile has no value, the context is already
        -- set to HR: Security Profile.
        --
        hr_signon.initialize_hr_security;
        initialise_globals;
      END IF;

      --
      -- Immediately return TRUE if there is no security.
      --
      IF g_mo_context.security_profile_id IS NULL OR
       NVL(g_mo_context.view_all_flag, 'Y') = 'Y' OR
       NVL(g_mo_context.view_all_organizations_flag, 'Y') = 'Y' OR
       NVL(g_mo_context.org_security_mode, 'NONE') = 'NONE'
      THEN
         RETURN 'TRUE';
      END IF;

      --
      -- Evaluate organization security by operating unit.
      --
      IF g_mo_context.org_security_mode = 'OU' THEN
        --
        -- The org security mode is operating unit only.  Get the
        -- 'MO:Operating Unit' profile option.
        --
        l_pv_org_id := to_number(fnd_profile.value('ORG_ID'));

        --
        -- The value of the profile option 'MO:Operating Unit' is
        -- validated against p_org_id.
        --
        IF l_pv_org_id = p_org_id THEN
          RETURN 'TRUE';
        ELSE
          RETURN 'FALSE';
        END IF;

      --
      -- Evaluate organization security by operating unit
      -- and inventory organizations.
      --
      ELSIF g_mo_context.org_security_mode = 'OU_INV' THEN
        --
        -- The org_security_mode is operating unit and inventory orgs.
        -- Get the 'MO:Operating Unit' profile option.
        --
        l_pv_org_id := to_number(fnd_profile.value('ORG_ID'));

        --
        -- The value of the profile option 'MO:Operating Unit' is
        -- compared against p_org_id.
        --
        IF l_pv_org_id = p_org_id THEN
          RETURN 'TRUE';
        END IF;

        --
        -- Get the org_access rows and see if any orgs match. If there are
        -- no matches against p_org_id, FALSE is returned.  If no rows
        -- exist for the current responsibility, p_org_id is checked against
        -- the inventory orgs for the operating unit via hr_organization_units.
        --
        OPEN  c_chk_resp_in_org_access;
        FETCH c_chk_resp_in_org_access into l_org_id;

        IF c_chk_resp_in_org_access%FOUND THEN
          --
          -- There are matching records, so see if any orgs in org_access
          -- match p_org_id.
          --
          OPEN  c_get_org_access_org;
          FETCH c_get_org_access_org INTO l_org_id;

          IF c_get_org_access_org%FOUND THEN
            CLOSE c_chk_resp_in_org_access;
            CLOSE c_get_org_access_org;
            RETURN 'TRUE';
          ELSE
            CLOSE c_chk_resp_in_org_access;
            CLOSE c_get_org_access_org;
            RETURN 'FALSE';
          END IF;

        ELSE
          --
          -- There are no records in org_access that match the responsibility
          -- so get the inventory orgs for the operating unit.
          --
          CLOSE c_chk_resp_in_org_access;

          OPEN  c_get_inventory_org (l_pv_org_id);
          FETCH c_get_inventory_org into l_org_id;

          IF c_get_inventory_org%FOUND THEN
            CLOSE c_get_inventory_org;
            RETURN 'TRUE';
          ELSE
            CLOSE c_get_inventory_org;
            RETURN 'FALSE';
          END IF;

        END IF;

      --
      -- Evaluate organization security by organization hierarchy
      -- and / or a discrete list of organizations.
      --
      ELSIF g_mo_context.org_security_mode = 'HIER' THEN
        --
        -- This flag indicates whether the organization permissions have
        -- already been cached using g_mo_context.
        --
        IF NOT g_mo_org_sec_known THEN
          --
          -- Re-evaluate organization security using the g_mo_context.
          --
          hr_security_internal.evaluate_access
              (p_person_id        => g_mo_person_id
              ,p_user_id          => g_user_id
              ,p_effective_date   => g_effective_date
              ,p_sec_prof_rec     => g_mo_context
              ,p_what_to_evaluate => hr_security_internal.g_ORG_SEC_ONLY);

          --
          -- Set this flag so that the permissions are not re-evaluated
          -- with each function call. This flag is reset back to false
          -- when the user's logon attributes change (for example, the
          -- user changes responsibility).
          --
          g_mo_org_sec_known := TRUE;

        END IF;

        IF hr_security_internal.g_org_tbl.EXISTS(p_org_id) THEN
            RETURN 'TRUE';
        ELSE
            RETURN 'FALSE';
        END IF;

      END IF;

     RETURN 'FALSE';

   END Show_BIS_Record;
  --
  -----------------------------------------------------------------------
  --< add_assignment >---------------------------------------------------
  -----------------------------------------------------------------------
  --
  procedure add_assignment
    (p_person_id     number
    ,p_assignment_id number) is
  begin

    IF globals_need_refreshing THEN
      hr_signon.initialize_hr_security;
      initialise_globals;
    END IF;

    IF g_context.view_all_flag <> 'Y' AND
     NVL(g_context.restrict_on_individual_asg, 'N') = 'Y' AND
     p_person_id IS NOT NULL AND
     p_assignment_id IS NOT NULL
    THEN
      hr_security_internal.g_asg_tbl(p_assignment_id) := p_person_id;
    END IF;

  end add_assignment;
   --
   -----------------------------------------------------------------------
   --< add_person >-------------------------------------------------------
   -----------------------------------------------------------------------
   --
  procedure add_person(p_person_id number) is
    --
  begin
    --
    if globals_need_refreshing then
      hr_signon.initialize_hr_security;
      initialise_globals;
    end if;
    --
    if g_context.view_all_flag <> 'Y' then
      --
      --g_person_list(p_person_id) := TRUE;--6012095(Forward port of 5985232)
      hr_security_internal.g_per_tbl(p_person_id) := TRUE;
      --
    end if;
    --
  end add_person;
   --
   -----------------------------------------------------------------------
   --< remove_person >----------------------------------------------------
   -----------------------------------------------------------------------
   --
  procedure remove_person(p_person_id number) is
  begin
    if g_context.view_all_flag<>'Y' then
      -- g_person_list.delete(p_person_id); --6012095(Forward port of 5985232)
      hr_security_internal.g_per_tbl.delete(p_person_id);
    end if;
  end remove_person;
  --
  -----------------------------------------------------------------------
  --< add_organization >-------------------------------------------------
  -----------------------------------------------------------------------
  --
  procedure add_organization
    (p_organization_id  number,
     p_security_Profile_id   number) is
  begin
    --
    IF globals_need_refreshing THEN
      hr_signon.initialize_hr_security;
      initialise_globals;
    END IF;
    --
    IF g_context.view_all_flag <> 'Y' AND
       g_context.view_all_organizations_flag = 'N' AND
       p_organization_id IS NOT NULL
    THEN
      hr_security_internal.g_org_tbl(p_organization_id) := TRUE;
    END IF;
    --
    IF (NVL(g_context.top_organization_method, 'S') <> 'U') THEN
        hr_security_internal.add_org_to_security_list(p_security_Profile_id,
                                                      p_organization_id);
    END IF;
    --
  end add_organization;
  --
  --
  -----------------------------------------------------------------------
  --< add_position >-----------------------------------------------------
  -----------------------------------------------------------------------
  --
  procedure add_position
    (p_position_id  number,
     p_security_profile_id   number) is
  begin
    --
    IF globals_need_refreshing THEN
      hr_signon.initialize_hr_security;
      initialise_globals;
    END IF;
    --
    IF g_context.view_all_flag <> 'Y' AND
       g_context.view_all_positions_flag = 'N' AND
       p_position_id IS NOT NULL
    THEN
      hr_security_internal.g_pos_tbl(p_position_id) := TRUE;
    END IF;
    --
    IF (NVL(g_context.top_position_method, 'S') <> 'U') THEN
        hr_security_internal.add_pos_to_security_list(p_security_profile_id,
                                                      p_position_id);
    END IF;
    --
  end add_position;
  --
  --
  -----------------------------------------------------------------------
  --< add_payroll >------------------------------------------------------
  -----------------------------------------------------------------------
  --
  procedure add_payroll
    (p_payroll_id number) is
  begin

    IF globals_need_refreshing THEN
      hr_signon.initialize_hr_security;
      initialise_globals;
    END IF;

    IF g_context.view_all_flag <> 'Y' AND
       g_context.view_all_payrolls_flag = 'N' AND
       p_payroll_id IS NOT NULL
    THEN
      hr_security_internal.g_pay_tbl(p_payroll_id) := TRUE;
    END IF;

  end add_payroll;
  --
  -------------------------------------------------------------------------
  ---------------------< get_sec_profile_bg_id >---------------------------
  -------------------------------------------------------------------------
  --
  FUNCTION get_sec_profile_bg_id
  RETURN NUMBER
  is
  begin
    if fnd_global.user_id <> -1 then

      if globals_need_refreshing then
        hr_signon.initialize_hr_security;
        initialise_globals;
      end if;

      return g_context.business_group_id;

    else
      return null;
    end if;
  end get_sec_profile_bg_id;
  --
  -------------------------------------------------------------------------
  ---------------------< restrict_on_individual_asg >----------------------
  -------------------------------------------------------------------------
  --
  FUNCTION restrict_on_individual_asg
  RETURN BOOLEAN
  IS

  BEGIN
      --
      -- Ensure the cache is up to date.
      --
      IF globals_need_refreshing THEN
        hr_signon.initialize_hr_security;
        initialise_globals;
      END IF;

      --
      -- Return the restrict on individual assignment flag.
      --
      RETURN (NVL(hr_signon.g_hr_security_profile.restrict_on_individual_asg
                 ,NVL(g_context.restrict_on_individual_asg, 'N')) = 'Y');

  END restrict_on_individual_asg;
  --
  -------------------------------------------------------------------------
  ---------------------< restrict_by_supervisor_flag >---------------------
  -------------------------------------------------------------------------
  --
  FUNCTION restrict_by_supervisor_flag
  RETURN VARCHAR2
  IS

  BEGIN
      --
      -- Ensure the cache is up to date.
      --
      IF globals_need_refreshing THEN
        hr_signon.initialize_hr_security;
        initialise_globals;
      END IF;

      --
      -- Return the type of supervisor security.
      --
      RETURN (NVL(hr_signon.g_hr_security_profile.restrict_on_individual_asg
                 ,NVL(g_context.restrict_on_individual_asg, 'N')));

  END restrict_by_supervisor_flag;
  --
  --
  PROCEDURE delete_list_for_bg(p_business_group_id NUMBER)
  IS
  BEGIN
    hr_security_internal.delete_security_list_for_bg(p_business_group_id);
  END;
  --
  --
  PROCEDURE delete_per_from_list(p_person_id   number)
  IS
  BEGIN
    hr_security_internal.delete_per_from_security_list(p_person_id);
  END;
  --
  --
  PROCEDURE delete_org_from_list(p_organization_id    number)
  IS
  BEGIN
    hr_security_internal.delete_org_from_security_list(p_organization_id);
  END;
  --
  --
  PROCEDURE delete_pos_from_list(p_position_id    number)
  IS
  BEGIN
    hr_security_internal.delete_pos_from_security_list(p_position_id);
  END;
  --
  --
  PROCEDURE delete_payroll_from_list(p_payroll_id     number)
  IS
  BEGIN
    hr_security_internal.delete_pay_from_security_list(p_payroll_id);
  END;
  --
  --
  -------------------------------------------------------------------------
  ---------------------< PACKAGE INITIALIZATION >--------------------------
  -------------------------------------------------------------------------
  --
BEGIN
   --
   -- Initialise package global variables
   --
   hr_signon.initialize_hr_security;
   Initialise_Globals;
   --
END HR_SECURITY;

/

  GRANT EXECUTE ON "APPS"."HR_SECURITY" TO "HR_REPORTING_USER";

--------------------------------------------------------
--  DDL for Package Body PAY_PYUCSLIS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PYUCSLIS_PKG" AS
/* $Header: pyucslis.pkb 120.26.12010000.7 2009/04/07 09:59:57 rnemani ship $ */
--
--
  g_package varchar2(20) := 'pay_pyucslis_pkg.';
  g_debug boolean := hr_utility.debug_enabled;
--
--
-- Start changes for the Bug 5438641
-- The procedure modified for Bulk Collect.

procedure add_contacts_for_person(
          p_person_id              number,
          p_business_group_id      number,
          p_generation_scope       varchar2,
          p_effective_date         date
          ) is
  --
  l_proc     varchar2(72):= g_package||'add_contacts_for_person';
  l_prog_id  number(15)  := fnd_profile.value('CONC_PROGRAM_ID');
  l_req_id   number(15)  := fnd_profile.value('CONC_REQUEST_ID');
  l_appl_id  number(15)  := fnd_profile.value('CONC_PROGRAM_APPLICATION_ID');
  l_upd_date date        := trunc(sysdate);
  --
begin
  --
  hr_utility.set_location('Entering: '||l_proc, 10);
  -- Insert a record for each contact of the person. Only process  those
  -- profiles which are in the generation scope but include ALL contacts
  -- for this person_id.

  -- Added DISTINCT so that it handles multiple contact relationships
  -- between the same two people. Do not insert if using user-based
  -- security as this is assessed dynamically.
  insert into per_person_list(security_profile_id, person_id, request_id,
                              program_application_id, program_id,
                              program_update_date)
         select /*+ USE_NL(PSP) */
	        distinct ppl.security_profile_id, pcr.contact_person_id,
                l_req_id, l_appl_id, l_prog_id, l_upd_date
           from per_contact_relationships pcr,
                per_person_list ppl,
                per_security_profiles psp
          where ppl.person_id = p_person_id
            and ppl.security_profile_id = psp.security_profile_id
            and (psp.view_all_contacts_flag = 'N' or
                (psp.view_all_contacts_flag = 'Y' and
                psp.view_all_candidates_flag = 'X'))
            and (nvl(psp.top_organization_method, 'S') <> 'U' and
                nvl(psp.top_position_method, 'S') <> 'U' and
                nvl(psp.custom_restriction_flag, 'N') <> 'U')
            and ((psp.business_group_id = p_business_group_id and
                p_generation_scope = 'ALL_BUS_GRP') or
                (psp.business_group_id is null and
                p_generation_scope = 'ALL_GLOBAL') or
                p_generation_scope = 'ALL_PROFILES')
            and pcr.person_id = ppl.person_id
            and not exists
                (select /*+ NO_MERGE */ null
                   from per_all_assignments_f asg
                  where asg.person_id = pcr.contact_person_id
                  and asg.ASSIGNMENT_TYPE <> 'B')   -- Bug 4450149
            and not exists
                (select /*+ NO_MERGE */ null
                   from per_person_list ppl1
                  where ppl1.person_id = pcr.contact_person_id
                    and ppl1.granted_user_id is null
                    and ppl1.security_profile_id = ppl.security_profile_id);
  --
  hr_utility.set_location('Leaving: '||l_proc, 99);
  --
end add_contacts_for_person;

--
procedure add_unrelated_contacts(
          p_business_group_id      number
         ,p_generation_scope       varchar2
         ,p_effective_date         date
         ) is
  --
  type l_number_t is table of number index by binary_integer;
  --
  l_per_tbl    l_number_t;
  l_per_bg_tbl l_number_t;
  l_sp_tbl     l_number_t;
  l_sp_bg_tbl  l_number_t;
  --
  l_proc     varchar2(72) := g_package||'.add_unrelated_contacts';
  l_prog_id  number(15)   := fnd_profile.value('CONC_PROGRAM_ID');
  l_req_id   number(15)   := fnd_profile.value('CONC_REQUEST_ID');
  l_appl_id  number(15)   := fnd_profile.value('CONC_PROGRAM_APPLICATION_ID');
  l_upd_date date         := trunc(sysdate);
  t_varchar  varchar2(1);
  -- Fetch the unrelated contacts, excluding the Candidates (iRecruitment
  -- registered user's) that are in scope.
  cursor csr_get_unrelated_contacts is
         select distinct
                papf.person_id,
                papf.business_group_id
           from per_all_people_f papf
          where not exists
                (select null
                   from per_all_assignments_f asg
                  where asg.person_id = papf.person_id)
            and not exists
                (select null
                   from per_contact_relationships pcr
                  where pcr.contact_person_id = papf.person_id)
            and ((p_generation_scope = 'ALL_BUS_GRP' and
                  papf.business_group_id = p_business_group_id) or
                  p_generation_scope <> 'ALL_BUS_GRP')
            and not exists
                (select null
                   from per_person_type_usages_f ptuf,
                        per_person_types ppt
                  where ppt.system_person_type = 'IRC_REG_USER'
                    and ptuf.person_type_id = ppt.person_type_id
                    and ptuf.person_id = papf.person_id);
    -- Fetch the security profiles that restrict by contacts, are
    -- in profile scope and are not user-based.
    --
    -- Cursor for p_generation_scope = 'ALL_BUS_GRP'
    cursor csr_get_sec_profs_bg is
           select psp.security_profile_id,
                  psp.business_group_id
             from per_security_profiles psp
            where (psp.view_all_contacts_flag   = 'N' or
                  (psp.view_all_contacts_flag   = 'Y' and
                   psp.view_all_candidates_flag = 'X'))
              and (nvl(psp.top_organization_method, 'S') <> 'U' and
                   nvl(psp.top_position_method, 'S')     <> 'U' and
                   nvl(psp.custom_restriction_flag, 'N') <> 'U')
              and psp.business_group_id = p_business_group_id;
    --
    -- Cursor for p_generation_scope <> 'ALL_BUS_GRP'
    cursor csr_get_sec_profs is
           select psp.security_profile_id,
                  psp.business_group_id
             from per_security_profiles psp
            where (psp.view_all_contacts_flag   = 'N' or
                  (psp.view_all_contacts_flag   = 'Y' and
                   psp.view_all_candidates_flag = 'X'))
              and (nvl(psp.top_organization_method, 'S') <> 'U' and
                   nvl(psp.top_position_method, 'S')     <> 'U' and
                   nvl(psp.custom_restriction_flag, 'N') <> 'U')
              and ((p_generation_scope = 'ALL_GLOBAL' and
                    psp.business_group_id is null) or
                    p_generation_scope = 'ALL_PROFILES');
  --

begin
  --
  hr_utility.set_location('Entering: '||l_proc, 1);
  hr_utility.set_location('Request ID '||p_request_id, 15);
  --
  -- Bulk collect the unrelated contacts into PL/SQL tables.
  open  csr_get_unrelated_contacts;
  fetch csr_get_unrelated_contacts bulk collect into l_per_tbl, l_per_bg_tbl;
  close csr_get_unrelated_contacts;
  --
  hr_utility.set_location(l_proc, 10);
  --
  if l_per_tbl.count > 0 then
    -- When there are unrelated contacts, bulk collect the security
    -- profiles that restrict by contacts.
    hr_utility.set_location(l_proc, 20);
    --
    if p_generation_scope = 'ALL_BUS_GRP' then
      --
      open  csr_get_sec_profs_bg;
      fetch csr_get_sec_profs_bg bulk collect into l_sp_tbl, l_sp_bg_tbl;
      close csr_get_sec_profs_bg;
      --
    else
      --
      open  csr_get_sec_profs;
      fetch csr_get_sec_profs bulk collect into l_sp_tbl, l_sp_bg_tbl;
      close csr_get_sec_profs;
      --
    end if;
    --
    hr_utility.set_location(l_proc, 30);
    --
     if l_sp_tbl.count > 0 then
      --
      hr_utility.set_location(l_proc, 40);
      --
      for i in l_sp_tbl.first..l_sp_tbl.last loop
        -- Insert the unrelated contacts for each security profile.
        -- Enforce the business group restriction when restricting
        -- by all profiles.
        for j in l_per_tbl.first..l_per_tbl.last
        --
        loop

	 if  (p_generation_scope <> 'ALL_PROFILES' or
         (p_generation_scope = 'ALL_PROFILES' and
                       nvl(l_sp_bg_tbl(i), l_per_bg_tbl(j)) =
                      l_per_bg_tbl(j)))

	then
         begin

             select 'X'  into t_varchar
                         from per_person_list p2
                        where p2.person_id = l_per_tbl(j)
                          and p2.security_profile_id = l_sp_tbl(i);

         exception
          when no_Data_found then

           insert into per_person_list(security_profile_id, person_id,
                                    request_id, program_application_id,
                                    program_id, program_update_date)
              values (l_sp_tbl(i), l_per_tbl(j), l_req_id,
                       l_appl_id, l_prog_id, l_upd_date);
          --
          end;

        --
	end if;
      end loop;
      end loop;
      --
    end if;
    --
  end if;
  --
  hr_utility.set_location('Leaving: '||l_proc, 999);
  --
end add_unrelated_contacts;
--

/* =======================================================================
  NAME
    delete_old_person_list_changes
  DESCRIPTION
    Delete entries in the person list changes table which are no longer
    required because they are currently employed.
  PARAMETERS
    l_effective_date        - date at which we are running.
========================================================================== */
--
PROCEDURE delete_old_person_list_changes (l_effective_date DATE)
IS
BEGIN
--
  hr_utility.set_location('hr_listgen.delete_old_person_list_changes',10);
  --
  -- Stubb out as part of ex-person security enhancements.
  --
  hr_utility.set_location('hr_listgen.delete_old_person_list_changes',20);
--
END delete_old_person_list_changes;
--
--
--
--
/* =======================================================================
  NAME
    build_payroll_list
  DESCRIPTION
    Insert payroll list entries for the current security profile based on
    the secured payroll table per_security_payrolls generated by the define
    security profile form. If the include_exclude option in the security
    profile is set to 'I' then the specified payrolls are copied to the payroll
    list. If the include_exclude flag is 'E' then all other payrolls for
    the business group are inserted into the list.
  PARAMETERS
    l_security_profile_id          - identifier of the current security profile
    l_business_group_id            - business group of the security profile.
    l_include_exclude_payroll_flag - include/exclude option of security profile
    l_effective_date               - date at which the lists are generated
    l_update_date                  - today's date.

========================================================================== */
    PROCEDURE build_payroll_list (l_security_profile_id          NUMBER,
                                  l_business_group_id            NUMBER,
                                  l_include_exclude_payroll_flag VARCHAR2,
                                  l_effective_date               DATE,
                                  l_update_date                  DATE)
    IS
    BEGIN
--
      IF (l_include_exclude_payroll_flag = 'I') THEN
--
        hr_utility.set_location('hr_listgen.build_payroll_list', 10);
--
        INSERT INTO pay_payroll_list
              (payroll_id,
               security_profile_id,
               request_id,
               program_application_id,
               program_id,
               program_update_date)
        SELECT distinct pay.payroll_id,
               l_security_profile_id,
               p_request_id,
               p_program_application_id,
               p_program_id,
               l_update_date
        FROM   pay_all_payrolls_f pay,
               pay_security_payrolls sec
        WHERE  sec.security_profile_id = l_security_profile_id
        AND    sec.payroll_id = pay.payroll_id;
/* Coomented for bug 8219374
        AND    l_effective_date
               BETWEEN pay.effective_start_date
               AND     pay.effective_end_date;*/
--
      ELSE                                     -- exclude payrolls
--
        hr_utility.set_location('hr_listgen.build_payroll_list', 20);
--
        INSERT INTO pay_payroll_list
              (payroll_id,
               security_profile_id,
               request_id,
               program_application_id,
               program_id,
               program_update_date)
        SELECT distinct pay.payroll_id,
               l_security_profile_id,
               p_request_id,
               p_program_application_id,
               p_program_id,
               l_update_date
        FROM   pay_all_payrolls_f pay
        WHERE
/*  Coomented for bug 8219374
       l_effective_date
               BETWEEN pay.effective_start_date
               AND     pay.effective_end_date
        AND    */
        pay.business_group_id + 0 = l_business_group_id
        AND    NOT EXISTS
              (SELECT NULL
               FROM   pay_security_payrolls sec
               WHERE  sec.security_profile_id = l_security_profile_id
               AND    sec.payroll_id = pay.payroll_id) ;
--
      END IF;                                  -- include payrolls
--
    END build_payroll_list;
--
--
/* =======================================================================
  NAME
    build_organization_list
  DESCRIPTION
    Insert values into the organization list for the security profile.
    Starting with the organization specified a tree walk of the organization
    structure element table per_org_structure_elements takes place and
    all organization below that specified are inserted into the organization
    list. If the include_top_org option is specified then that organisation
    is explicitly inserted into the list. The business group is
    inserted into the organisation list if not previously inserted.
  PARAMETERS
    l_security_profile_id       - identifier of the current security profile
    l_include_top_org_flag      - include/exclude top organization option
    l_organization_structure_id - identifier of the organization structure
                                  to be used.
    l_organization_id           - top organization to consider within the
                                  organization structure
    l_exclude_business_groups_flag - include/exclude all business groups when
                                  running in global mode
    l_effective_date            - effective date of the run to pick the
                                  structure version.
    l_update_date               - todays date.
    p_business_group_mode       - LOCAL/GLOBAL depends on type of security
                                  profile.
========================================================================== */
--
PROCEDURE build_organization_list (
          l_security_profile_id          NUMBER,
          l_include_top_org_flag         VARCHAR2,
          l_organization_structure_id    NUMBER,
          l_organization_id              NUMBER,
          l_exclude_business_groups_flag VARCHAR2,
          l_effective_date               DATE,
          l_update_date                  DATE,
          p_business_group_mode          VARCHAR2) IS
   --
   l_proc varchar2(100) := 'pay_pyucslis_pkg.build_organization_list';
   --
 begin
   --
   hr_utility.set_location(l_proc, 10);
   --
   -- Insert all organizations in the hierarchy (excluding the top organization).
   --
   INSERT INTO per_organization_list
          (security_profile_id,
          organization_id,
          request_id,
          program_application_id,
          program_id,
          program_update_date )
   SELECT l_security_profile_id,
          o.organization_id_child,
          p_request_id,
          p_program_application_id,
          p_program_id,
          l_update_date
     FROM per_org_structure_elements o
  CONNECT BY o.organization_id_parent = PRIOR o.organization_id_child
      AND o.org_structure_version_id = PRIOR o.org_structure_version_id
    START WITH o.organization_id_parent = l_organization_id
      AND o.org_structure_version_id =
          (SELECT v.org_structure_version_id
             FROM per_org_structure_versions v
            WHERE v.organization_structure_id = l_organization_structure_id
              AND l_effective_date BETWEEN v.date_from
              AND NVL(v.date_to, TO_DATE('31-12-4712','dd-mm-yyyy')));
   --
   hr_utility.set_location(l_proc, 20);
   --
   -- Insert all organizations in the organization list that have their
   -- include / exclude flag set to 'I'.
   --
   INSERT INTO per_organization_list
          (security_profile_id,
          request_id,
          program_id,
          program_application_id,
          program_update_date,
          organization_id)
   SELECT l_security_profile_id,
          p_request_id,
          p_program_id,
          p_program_application_id,
          l_update_date,
          pso.organization_id
     FROM per_security_organizations pso
    WHERE pso.entry_type = 'I'
      AND pso.security_profile_id = l_security_profile_id
      AND NOT EXISTS
          (SELECT NULL
             FROM per_organization_list pol
            WHERE pol.security_profile_id = l_security_profile_id
              AND pol.organization_id = pso.organization_id);
   --
   hr_utility.set_location(l_proc, 30);
   --
   -- Include the Top Organization if the security profile permits.
   --
   IF (l_include_top_org_flag = 'Y') THEN
      --
      IF l_organization_id IS NOT NULL THEN
         --
         hr_utility.set_location(l_proc, 40);
         --
         INSERT INTO per_organization_list
                (security_profile_id,
                organization_id,
                request_id,
                program_application_id,
                program_id,
                program_update_date )
         SELECT l_security_profile_id,
                l_organization_id,
                p_request_id,
                p_program_application_id,
                p_program_id,
                l_update_date
           FROM DUAL
          /* Duplicate check. Required because of organization list Includes */
          WHERE NOT EXISTS
               (SELECT NULL
                  FROM per_organization_list pol
                 WHERE pol.security_profile_id = l_security_profile_id
                   AND pol.user_id IS NULL
                   AND pol.organization_id = l_organization_id);
         --
      END IF;
      --
   END IF;
   --
   hr_utility.set_location(l_proc, 50);
   --
   IF p_business_group_mode='GLOBAL' AND
      NVL(l_exclude_business_groups_flag, 'N') = 'N' THEN
      --
      -- Include all business groups in the hierarchy for the GLOBAL sec prof.
      --
      INSERT INTO per_organization_list
            (security_profile_id,
             organization_id,
             request_id,
             program_application_id,
             program_id,
             program_update_date )
      SELECT DISTINCT
             l_security_profile_id,
             org.business_group_id,
             p_request_id,
             p_program_application_id,
             p_program_id,
             l_update_date
        FROM hr_all_organization_units org
        ,    per_organization_list lst
       WHERE lst.security_profile_id = l_security_profile_id
         AND lst.organization_id=org.organization_id
         AND NOT EXISTS
                (SELECT 1
                   FROM per_organization_list lst2
                  WHERE lst2.organization_id = org.business_group_id
                    AND lst2.user_id IS NULL
                    AND lst2.security_profile_id = l_security_profile_id);
      --
   ELSIF p_business_group_mode = 'LOCAL' AND
      NVL(l_exclude_business_groups_flag, 'N') = 'N' THEN
      --
      -- Include the business group for a LOCAL security profile.
      --
      INSERT INTO per_organization_list
            (security_profile_id,
             organization_id,
             request_id,
             program_application_id,
             program_id,
             program_update_date )
      SELECT l_security_profile_id,
             s.business_group_id,
             p_request_id,
             p_program_application_id,
             p_program_id,
             l_update_date
        FROM per_security_profiles s
       WHERE s.security_profile_id = l_security_profile_id
         AND NOT EXISTS
            (SELECT NULL
               FROM per_organization_list b
              WHERE b.organization_id = s.business_group_id
                AND b.user_id IS NULL
                AND b.security_profile_id = l_security_profile_id);
      --
   END IF;
   --
   -- Remove the organizations listed as 'Exclude' in the organization list.
   --
   DELETE
     FROM per_organization_list
    WHERE security_profile_id = l_security_profile_id
      AND user_id IS NULL
      AND organization_id IN
          (SELECT organization_id
             FROM per_security_organizations
            WHERE security_profile_id = l_security_profile_id
              AND entry_type = 'E');
   --
   -- BUSINESS_GROUP_ID's should be excluded from PER_ORGANIZATION_LIST for a
   -- global security profile with EXCLUDE_BUSINESS_GROUPS_FLAG is set as 'Y'.
   --
   -- Here an exclusive DELETE command is used, because in global security
   -- profile a business group can be a child of child of another business
   -- group (ie: more than one hierarchy below). In such cases a NOT EXISTS
   -- clause will not identify these business groups, when we use CONNECT BY.
   -- ie: While using NOT EXISTS clause along with CONNECT BY, then NOT EXISTS
   -- will scan only the first level of hierarchy and not the subsequent levels
   -- below.
   --
   IF p_business_group_mode = 'GLOBAL' AND
      NVL(l_exclude_business_groups_flag, 'N') = 'Y' THEN
      --
      DELETE
        FROM per_organization_list pol
       WHERE pol.security_profile_id = l_security_profile_id
         AND pol.user_id IS NULL
         AND pol.organization_id IN
             (SELECT org.business_group_id
                FROM hr_all_organization_units org
               WHERE org.organization_id = pol.organization_id
                 AND org.organization_id = org.business_group_id);
      --
   END IF;
   --
END build_organization_list;
--
/* =======================================================================
  NAME
    build_position_list
  DESCRIPTION
    Insert values into the position list for the security profile.
    A tree walk of the position structure table takes place starting with
    the top position specified. If the 'all_organisations' option is
    specified then a row is inserted for each position in the structure
    below the top position. If 'all_organizations' is not specified then
    rows are only inserted if the position encountered exists in an
    organization in the organization list for the security profile. If
    the 'include top position' option is specified then the position is
    explictly inserted into the position list.
  PARAMETERS
    l_security_profile_id         - identifier of the current security profile.
    l_view_all_organizations_flag - all organizations option
    l_include_top_position_flag   - include/exclude top position option
    l_position_structure_id       - position structure to be used.
    l_position_id                 - top position in the position structure
                                    to be used.
    l_effective_date              - effective_date of the run at which to
                                    pick the version.
    l_update_date                 - today's date.
========================================================================== */
--
    PROCEDURE build_position_list (l_security_profile_id         NUMBER,
                                   l_view_all_organizations_flag VARCHAR2,
                                   l_include_top_position_flag   VARCHAR2,
                                   l_position_structure_id       NUMBER,
                                   l_position_id                 NUMBER,
                                   l_effective_date              DATE,
                                   l_update_date                 DATE)
    IS
    BEGIN
--
      IF (l_view_all_organizations_flag = 'N') THEN
--
        hr_utility.set_location('hr_listgen.build_position_list', 10);
--
        INSERT  INTO per_position_list
               (security_profile_id,
                position_id,
                request_id,
                program_application_id,
                program_id,
                program_update_date )
        SELECT  l_security_profile_id,
                p.subordinate_position_id,
                p_request_id,
                p_program_application_id,
                p_program_id,
                l_update_date
        FROM    per_pos_structure_elements p
        WHERE   EXISTS
               (SELECT NULL
                FROM   hr_all_positions_f    pp,
                       per_organization_list ol
                WHERE  ol.organization_id    = pp.organization_id
                AND    pp.position_id        = p.subordinate_position_id
                AND    ol.security_profile_id= l_security_profile_id)
        START   WITH p.parent_position_id    = l_position_id
        AND     p.pos_structure_version_id      =
               (SELECT v.pos_structure_version_id
                FROM   per_pos_structure_versions v
                WHERE  v.position_structure_id = l_position_structure_id
                AND    l_effective_date
                BETWEEN v.date_from
                AND NVL(v.date_to, to_date('31-12-4712','dd-mm-yyyy')))
        CONNECT BY p.parent_position_id    = PRIOR p.subordinate_position_id
        AND     p.pos_structure_version_id = PRIOR p.pos_structure_version_id;
--
        -- Include the top position.
--
        IF ( l_include_top_position_flag = 'Y') THEN
--
          hr_utility.set_location('hr_listgen.build_position_list', 20);
--
          INSERT  INTO per_position_list
                 (security_profile_id,
                  position_id,
                  request_id,
                  program_application_id,
                  program_id,
                  program_update_date )
          SELECT  l_security_profile_id,
                  l_position_id,
                  p_request_id,
                  p_program_application_id,
                  p_program_id,
                  l_update_date
          FROM    sys.dual
          WHERE   EXISTS
                 (SELECT NULL
                  FROM   hr_all_positions_f    pp,
                         per_organization_list ol
                  WHERE  ol.organization_id    = pp.organization_id
                  AND    pp.position_id        = l_position_id
                  AND    ol.security_profile_id= l_security_profile_id);
--
        END IF;                                 -- Include the top position.
--
      ELSE                                    -- l_view_all_organizations_flag
--
        hr_utility.set_location('hr_listgen.build_position_list', 30);
--
        INSERT  INTO per_position_list
               (security_profile_id,
                position_id,
                request_id,
                program_application_id,
                program_id,
                program_update_date )
        SELECT  l_security_profile_id,
                p.subordinate_position_id,
                p_request_id,
                p_program_application_id,
                p_program_id,
                l_update_date
        FROM    per_pos_structure_elements p
        START   WITH p.parent_position_id    = l_position_id
        AND     p.pos_structure_version_id      =
               (SELECT v.pos_structure_version_id
                FROM   per_pos_structure_versions v
                WHERE  v.position_structure_id = l_position_structure_id
                AND    l_effective_date
                BETWEEN v.date_from
                AND NVL(v.date_to, to_date('31-12-4712','dd-mm-yyyy')))
        CONNECT BY p.parent_position_id    = PRIOR p.subordinate_position_id
        AND     p.pos_structure_version_id = PRIOR p.pos_structure_version_id;
--
        -- Include top position.
--
        IF ( l_include_top_position_flag = 'Y') THEN
--
          hr_utility.set_location('hr_listgen.build_position_list', 40);
--
          INSERT INTO per_position_list
                 (security_profile_id,
                  position_id,
                  request_id,
                  program_application_id,
                  program_id,
                  program_update_date )
          VALUES  (l_security_profile_id,
                  l_position_id,
                  p_request_id,
                  p_program_application_id,
                  p_program_id,
                  l_update_date);
--
        END IF;                                  -- Include the top position.
--
      END IF;                                      -- View all organizations.
--
    END build_position_list;
--
--
/* =======================================================================
  NAME
    build_contact_list
  DESCRIPTION
    Insert contacts into the person list for the security profile.
  PARAMETERS
    p_security_profile_id         - security profile identifier
    p_effective_date              - date at which the lists are generated
    p_business_group_id           - business group ID from the security profile.
                                    If it's null(global profile) include contacts
				    from all BGs. Otherwise just for the profiles
				    business group.
========================================================================== */
--
procedure build_contact_list(
          p_security_profile_id         number,
	  p_view_all_contacts_flag      varchar2, -- Added for bug (6376000/4774264)
          p_effective_date              date,
          p_business_group_id           number
          ) is
  --
  l_proc     varchar2(72):= g_package||'build_contact_list';
  l_prog_id  number(15)  := fnd_profile.value('CONC_PROGRAM_ID');
  l_req_id   number(15)  := fnd_profile.value('CONC_REQUEST_ID');
  l_appl_id  number(15)  := fnd_profile.value('CONC_PROGRAM_APPLICATION_ID');
  l_upd_date date        := trunc(sysdate);
  --
begin
  --
  hr_utility.set_location('Entering: ' || l_proc, 10);

  IF p_view_all_contacts_flag = 'Y' then ---- Added for bug (6376000/4774264)
	-- If the Security profile set as -- View All contacts = Yes
	-- In this case we need to Insert the contact records for,
	-- 1) Related contacts - If the person/Employee is visible then Only Insert
	--     contacts related to the Person/Employee.
	--  --> Query #2 will populate these records.
	-- 2) Unrelated Contacts - Insert all Unrelated i.e which is not belong to any
	--      Person/Record in system.
	--  --> Query #3 will populate these records.
        -- 3) View All contacts = Yes --> Insert all reacords which are related to the
        --    Person/Employee in the system but not populated because of the Security Profile setup like
	--      Employee = Restricted.
	--  --> Query #1 will populate these records.


  --  Query #1
	 insert into per_person_list(security_profile_id, request_id, program_id
                             ,program_application_id, program_update_date
                             ,person_id)
         select distinct p_security_profile_id, l_req_id, l_prog_id,
                l_appl_id, l_upd_date, pcr.contact_person_id
           from per_contact_relationships pcr,
                per_all_people_f ppl -- per_person_list ppl for bug (6376000/4774264)
          where ppl.person_id = pcr.person_id
            and (pcr.business_group_id = p_business_group_id or
                p_business_group_id is null)
          --  and ppl.security_profile_id = p_security_profile_id for bug (6376000/4774264)
            and not exists
                (select null
                   from per_all_assignments_f asg
                  where asg.person_id = pcr.contact_person_id
                  and asg.ASSIGNMENT_TYPE <> 'B')  -- Bug 4450149
            and not exists
                (select null
                   from per_person_list ppl1
                  where ppl1.person_id = pcr.contact_person_id
                    and ppl1.granted_user_id is null
                    and ppl1.security_profile_id = p_security_profile_id ); -- ppl.security_profile_id) for bug (6376000/4774264)
  --
          hr_utility.set_location(l_proc, 20);
   Else
  -- Insert into person list, all people with a contact relationship to
  -- someone already in the person list as long as their system person type
  -- is 'other'
  -- Added DISTINCT to handle two or more contact relationships
  -- for the same two people (e.g., the same person is a brother and
  -- emergency contact).

  -- Instead of using using the worker numbers to evaluate whether the
  -- current record is a contact another AND NOT EXISTS can check for
  -- assignments.
  -- This way, all contacts who are also another type will be ignored,
  -- it should be assumed that their assignments will be processed by an
  -- earlier part of LISTGEN.
  --  Query #2
  insert into per_person_list(security_profile_id, request_id, program_id
                             ,program_application_id, program_update_date
                             ,person_id)
         select distinct ppl.security_profile_id, l_req_id, l_prog_id,
                l_appl_id, l_upd_date, pcr.contact_person_id
           from per_contact_relationships pcr,
                per_person_list ppl
          where ppl.person_id = pcr.person_id
            and (pcr.business_group_id = p_business_group_id or
                p_business_group_id is null)
            and ppl.security_profile_id = p_security_profile_id
            and not exists
                (select null
                   from per_all_assignments_f asg
                  where asg.person_id = pcr.contact_person_id
                  and asg.ASSIGNMENT_TYPE <> 'B')  -- Bug 4450149
            and not exists
                (select null
                   from per_person_list ppl1
                  where ppl1.person_id = pcr.contact_person_id
                    and ppl1.granted_user_id is null
                    and ppl1.security_profile_id = ppl.security_profile_id);
  --
		  hr_utility.set_location(l_proc, 30);
  End if;
  -- Inserts all unrelated contacts(excluding the candidates, those
  -- registered from iRecruitment) who do not have any other assignments.
  -- If there are additional assignments these will be excluded from here
  -- on the assumption that they would have been evaluated in the previous
  -- stages of listgen.
  --  Query #3
  insert into per_person_list(security_profile_id, request_id,
                              program_application_id, program_id,
                              program_update_date, person_id)
         select distinct psp.security_profile_id, l_req_id, l_appl_id,
                l_prog_id, l_upd_date, papf.person_id
           from per_all_people_f papf,
                per_security_profiles psp
          where psp.security_profile_id = p_security_profile_id
            and (psp.business_group_id = papf.business_group_id or
                 psp.business_group_id is null)
            and not exists
                (select null
                   from per_all_assignments_f asg
                  where asg.person_id = papf.person_id)
            and not exists ---- Rever Commneted for for bug 4774264
                (select null
                   from per_contact_relationships pcr
                  where pcr.contact_person_id = papf.person_id)
            and not exists
                (select null
                   from per_person_type_usages_f ptuf,
                        per_person_types ppt
                  where ppt.system_person_type = 'IRC_REG_USER'
                    and ptuf.person_type_id = ppt.person_type_id
                    and ptuf.person_id = papf.person_id)
            and not exists
                (select null
                   from per_person_list ppl
                  where ppl.person_id = papf.person_id
                    and ppl.granted_user_id is null
                    and ppl.security_profile_id = psp.security_profile_id);
  --
  hr_utility.set_location('Leaving: ' || l_proc, 99);
  --
end build_contact_list;
--
/* =======================================================================
  NAME
    add_person_list_changes
  DESCRIPTION
    Insert additional person list entries for persons in the person list
    changes table. If an entry exists for the security profile in the
    person list changes table and there is not an entry already for that
    person in the person list then a row is inserted. Only persons who
    have a termination date before the effective date and who do
    not have a current period of service (at effective date) are added. As
    'B' assignments are created on termination we need to exclude these
    assignments from consideration.
  PARAMETERS
    l_security_profile_id - identifier of the current security profile.
    l_effective_date      - date for which the secure lists are generated.
    l_update_date         - today's date.
========================================================================= */
--
    PROCEDURE add_person_list_changes (l_security_profile_id NUMBER,
                                       l_effective_date      DATE,
                                       l_update_date         DATE)
    IS
    BEGIN
--
      hr_utility.set_location('hr_listgen.add_person_list_changes',10);
--
      INSERT INTO per_person_list
            (security_profile_id,
             person_id,
             request_id,
             program_application_id,
             program_id,
             program_update_date )
      SELECT DISTINCT l_security_profile_id,
             plc.person_id,
             p_request_id,
             p_program_application_id,
             p_program_id,
             l_update_date
      FROM   per_person_list_changes plc
      WHERE  plc.security_profile_id = l_security_profile_id
      AND    NOT EXISTS
            (SELECT  NULL
             FROM    per_all_assignments_f pos
             WHERE   pos.person_id         = plc.person_id
             AND     pos.assignment_type  <> 'B'
             AND     l_effective_date
                     BETWEEN  pos.effective_start_date
                     AND      pos.effective_end_date)
      AND    EXISTS
            (SELECT  NULL
             FROM    per_all_assignments_f pos
             WHERE   pos.person_id         = plc.person_id
             AND     l_effective_date > pos.effective_start_date)
      AND    NOT EXISTS
            (SELECT  NULL
	     FROM    per_person_list ppl
	     WHERE   ppl.person_id = plc.person_id
             AND     ppl.granted_user_Id IS NULL
	     AND     ppl.security_profile_id = plc.security_profile_id);
--
      hr_utility.set_location('hr_listgen.add_person_list_changes',20);
--
    END add_person_list_changes;


/* =======================================================================
  NAME
    create_person_list
  DESCRIPTION
  populates the per_person_list using dynamic sql
  PARAMETERS
  Few parameters are needed due it inheriting from the parent function
  sec_rec    - Row in per_security_profiles for current profile
========================================================================= */
--

PROCEDURE create_person_list(sec_rec          PER_SECURITY_PROFILES%ROWTYPE,
                             p_effective_date date,
			     p_update_date    date,
			     p_who_to_process varchar2)
IS
  l_select_text varchar2(500);
  l_where_clause varchar2(3000);
  l_restriction_flags varchar2(1000);
  l_execution_stmt varchar2(8500);
  l_execution_stmt2 varchar2(8500);
  l_exclude_flags varchar2(1000);

  l_sec_rec_security_profile_id varchar2(2000);

  -- for the bug 5214715

    PROCEDURE execute_statement
      AS
        l_cursor_id   NUMBER;
        l_dsql_text   VARCHAR2(32767);
        l_num_of_rows NUMBER;
        l_num number(10);
        j number(10):=1;
        i  number(10):=50;
      BEGIN
      hr_utility.set_location('Entering execute_statement',10);
        l_cursor_id := dbms_sql.open_cursor;
        fnd_dsql.set_cursor(l_cursor_id);

        l_dsql_text := fnd_dsql.get_text(FALSE);
        l_num := length(l_dsql_text);

/* -- use to print the final sql query
        while j < l_num +50
        loop
         hr_utility.set_location(substr(l_dsql_text,j,i),10);
        -- hr_utility.set_location('-------------------------',20);
       -- dbms_output.put_line(substr(l_dsql_text,i));
        j := j+50;
        end loop;
*/
      dbms_sql.parse(l_cursor_id, l_dsql_text, dbms_sql.native);
    hr_utility.set_location('after parse',10);
        fnd_dsql.do_binds;
      hr_utility.set_location('after bind',10);
        l_num_of_rows := dbms_sql.execute(l_cursor_id);
    hr_utility.set_location('after execuate ',10);
        dbms_sql.close_cursor(l_cursor_id);
        hr_utility.set_location('Leaveing execute_statement',10);
    END execute_statement;

  /*-- for the bug 5214715  --*/
    PROCEDURE add_comm_str ( p_sec_rec           IN PER_SECURITY_PROFILES%ROWTYPE ) as
     l_restriction_flags varchar2(2000);
     l_exclude_flags     varchar2(2000);
      BEGIN
        hr_utility.set_location('Entering add_comm_str',10);
    l_restriction_flags :='';
      if (p_sec_rec.view_all_cwk_flag = 'N') then
        if length(l_restriction_flags)>0 then
          l_restriction_flags:=l_restriction_flags||' OR ';
        end if;
        l_restriction_flags:=l_restriction_flags||' ASSIGNMENT.assignment_type=''C''';
      end if;

      if (p_sec_rec.view_all_employees_flag = 'N') then
        if length(l_restriction_flags)>0 then
          l_restriction_flags:=l_restriction_flags||' OR ';
        end if;
        l_restriction_flags:=l_restriction_flags||' ASSIGNMENT.assignment_type=''E''';
      end if;

      if (p_sec_rec.view_all_applicants_flag = 'N') then
        /*
        ** Change in logic due to bug 3024532.  Process Applicant assignments
        ** regardless of the employee/Cwk restriction.  This means that EMP-APL
        ** are visible to a profile by virtue of Appl assignment even if Emp
        ** assignment is not visible.
        */
        if length(l_restriction_flags)>0 then
          l_restriction_flags:=l_restriction_flags||' OR ';
        end if;
        l_restriction_flags:=l_restriction_flags||
                              '( ASSIGNMENT.assignment_type=''A'' )';
      end if;

      if l_restriction_flags is not null or
         length(l_restriction_flags) = 0
      then
        fnd_dsql.add_text(' and ( ');
        fnd_dsql.add_text(l_restriction_flags);
        fnd_dsql.add_text(' ) ');
      end if;

      l_exclude_flags :='';
      if (p_sec_rec.view_all_cwk_flag = 'X') then
        if length(l_exclude_flags)>0 then
          l_exclude_flags:=l_exclude_flags||' AND ';
        end if;
        l_exclude_flags:=l_exclude_flags||'ASSIGNMENT.assignment_type<>''C''';
      end if;
      --
      if (p_sec_rec.view_all_employees_flag = 'X') then
        if length(l_exclude_flags)>0 then
          l_exclude_flags:=l_exclude_flags||' AND ';
        end if;
        l_exclude_flags:=l_exclude_flags||'ASSIGNMENT.assignment_type<>''E''';
      end if;
      --
      if (p_sec_rec.view_all_applicants_flag = 'X') then
        if length(l_exclude_flags)>0 then
          l_exclude_flags:=l_exclude_flags||' AND ';
        end if;
        l_exclude_flags:=l_exclude_flags||
                              '(ASSIGNMENT.assignment_type<>''A'' )';
      end if;
      --
      if l_exclude_flags is not null or
         length(l_exclude_flags) = 0
      then
        fnd_dsql.add_text(' and ( ');
        fnd_dsql.add_text(l_exclude_flags);
        fnd_dsql.add_text(' ) ');
      end if;
      hr_utility.set_location('Leaveing add_comm_str',10);
    END add_comm_str;

  /*-- for the bug 5214715  --*/
-- XXCUSTOM - procedure to add static insert statement text
    PROCEDURE init_statement
           (
         --   p_person_id         IN NUMBER
            p_request_id        IN NUMBER
           ,p_prog_appl_id      IN NUMBER
           ,p_program_id        IN NUMBER
           ,p_update_date       IN DATE
          -- ,p_from_clause       IN VARCHAR2
         ---  ,p_generation_scope  IN VARCHAR2
          -- ,p_business_group_id IN NUMBER
          -- ,p_assignment_type   IN VARCHAR2
           ,p_sec_rec           IN PER_SECURITY_PROFILES%ROWTYPE
           )
      AS
      BEGIN
      hr_utility.set_location('Entering init_statement',10);
        fnd_dsql.init;

     fnd_dsql.add_text(
       'INSERT into per_person_list
       (security_profile_id,
        person_id,
        request_id,
        program_application_id,
        program_id,
        program_update_date ) ');

-- Add the insert statement and binds
        fnd_dsql.add_text( ' SELECT DISTINCT ');
        fnd_dsql.add_bind(p_sec_rec.security_profile_id);
        fnd_dsql.add_text(' , assignment.person_id ');
        fnd_dsql.add_text(' ,');
        fnd_dsql.add_bind(nvl(p_request_id,''));
	    fnd_dsql.add_text(' , ');
        fnd_dsql.add_bind(nvl(p_program_application_id,''));
    	fnd_dsql.add_text(' , ');
        fnd_dsql.add_bind(nvl(p_program_id,''));
	    fnd_dsql.add_text(' , ');
        fnd_dsql.add_bind(to_date(to_char(p_update_date,'DD/MM/YYYY'),'DD/MM/YYYY'));
        fnd_dsql.add_text(' FROM   per_all_assignments_f    ASSIGNMENT ');

/*-------- additional select clause ---------------*/

  if (instr(UPPER(p_sec_rec.restriction_text),'PERSON.')>0) or
	(p_sec_rec.view_all_applicants_flag = 'N'
		and (p_sec_rec.view_all_employees_flag <>'Y'
                or p_sec_rec.view_all_cwk_flag <>'Y')) then
        fnd_dsql.add_text(', per_all_people_f PERSON ');
   End if;

   if p_sec_rec.view_all_organizations_flag='N' then
      Fnd_dsql.add_text(', per_organization_list ol ');
   end if;

   if instr(UPPER(p_sec_rec.restriction_text),'PERSON_TYPE.')>0 then
      Fnd_dsql.add_text(', per_person_type_usages_f PERSON_TYPE ');
   end if;

  if p_sec_rec.view_all_positions_flag='N' then
     fnd_dsql.add_text(', per_position_list pl ');
  end if;

  if p_sec_rec.view_all_payrolls_flag='N' then
     fnd_dsql.add_text( ' , pay_payroll_list ppl ');
  end if;

  if p_sec_rec.view_all_organizations_flag='Y' then
    null;
  end if;
 /*------------------ end additional select clause -----------------*/

 /*-------------- start where clause -------------------*/
   fnd_dsql.add_text(' Where ');
   fnd_dsql.add_text(' ASSIGNMENT.business_group_id = ');

  if p_sec_rec.business_group_id is null then
   fnd_dsql.add_text(' nvl(to_number('||nvl(to_char(p_sec_rec.business_group_id),
         'ASSIGNMENT.business_group_id')||'), ASSIGNMENT.business_group_id) ');
  else
   fnd_dsql.add_bind(p_sec_rec.business_group_id);
  end if;

 if (instr(UPPER(p_sec_rec.restriction_text),'PERSON.')>0) or
	(p_sec_rec.view_all_applicants_flag = 'N'
		and (p_sec_rec.view_all_employees_flag <>'Y'
                or p_sec_rec.view_all_cwk_flag <>'Y')) then

       fnd_dsql.add_text(' and ASSIGNMENT.person_id=PERSON.person_id and ');
       fnd_dsql.add_text(' ( '); -- 5214715
       fnd_dsql.add_bind(to_date(to_char(p_effective_date,'DD/MM/YYYY'),'DD/MM/YYYY'));
       fnd_dsql.add_text(' between PERSON.effective_start_date and PERSON.effective_end_date ');
        /* Got a fresh future person */
       fnd_dsql.add_text( ' or (PERSON.effective_start_date>= ');
       fnd_dsql.add_bind(to_date(to_char(p_effective_date,'DD/MM/YYYY'),'DD/MM/YYYY'));
       fnd_dsql.add_text(' AND NOT EXISTS
                            (SELECT NULL
                             FROM   per_all_people_f papf1
                             WHERE  papf1.person_id = PERSON.person_id
                             AND    papf1.effective_start_date < PERSON.effective_start_date)) ');

       fnd_dsql.add_text(' ) '); -- 5214715
 End if;

   if p_sec_rec.view_all_organizations_flag='N' then
      fnd_dsql.add_text(' and ol.security_profile_id = ');
      fnd_dsql.add_bind(p_sec_rec.security_profile_id);
      fnd_dsql.add_text(' and ol.organization_id=ASSIGNMENT.organization_id ');
   end if;

   if instr(UPPER(p_sec_rec.restriction_text),'PERSON_TYPE.')>0 then
      fnd_dsql.add_text(' and PERSON_TYPE.person_id = ASSIGNMENT.person_id and ');
      fnd_dsql.add_bind (to_date(to_char(p_effective_date,'DD/MM/YYYY'),'DD/MM/YYYY'));
      fnd_dsql.add_text(' BETWEEN PERSON_TYPE.effective_start_date AND PERSON_TYPE.effective_end_date ');
   end if;

  if p_sec_rec.view_all_positions_flag='N' then
      fnd_dsql.add_text(' and pl.security_profile_id = ');
      fnd_dsql.add_bind(p_sec_rec.security_profile_id );
      fnd_dsql.add_text(' and (pl.position_id=ASSIGNMENT.position_id or ASSIGNMENT.position_id is null )');
  end if;

  if p_sec_rec.view_all_payrolls_flag='N' then
     fnd_dsql.add_text(' and (( ppl.security_profile_id = ');
     fnd_dsql.add_bind(p_sec_rec.security_profile_id);
     fnd_dsql.add_text(' and ppl.payroll_id=ASSIGNMENT.payroll_id )');
     fnd_dsql.add_text(' or ASSIGNMENT.payroll_id is null )');
  end if;

  if p_sec_rec.view_all_organizations_flag='Y' then
     null;
  end if;
     /*-------------- End where clause -------------------*/
      hr_utility.set_location('Leaveing init_statement',10);
end init_statement;

BEGIN
    hr_utility.set_location('Entering Craete_person_list',10);
     init_statement
           (
            --p_person_id         => p_person_id
            p_request_id        => p_request_id
           ,p_prog_appl_id      => p_program_application_id
           ,p_program_id        => p_program_id
           ,p_update_date       => p_update_date
           -- ,p_from_clause       => p_from_clause
           -- ,p_generation_scope  => p_generation_scope
          -- ,p_business_group_id => p_business_group_id
           -- ,p_assignment_type   => p_assignment_type
           ,p_sec_rec           => sec_rec
           );


  -- Selects what type of assignment records we are interested in
  -- (Only ones where the relevant flag is N (Restricted))
  --
  -- Also adds check to make sure the relevant number for the assignment is not
  -- null ie for assignment_type of E, PERSON.employee_number must not be null
  --

   /*--------- Start for l_restriction_flags and l_exclude_flags ----------------*/

add_comm_str( p_sec_rec => sec_rec  );

/*--------- end for l_restriction_flags and l_exclude_flags----------------*/

fnd_dsql.add_text(' and ( ');
fnd_dsql.add_text(' ( '); -- 5214715
fnd_dsql.add_bind(to_date(to_char(p_effective_date,'DD/MM/YYYY'),'DD/MM/YYYY'));
fnd_dsql.add_text(' between ASSIGNMENT.effective_start_date and ASSIGNMENT.effective_end_date)
                    or ( ASSIGNMENT.effective_start_date>= ');
fnd_dsql.add_bind(to_date(to_char(p_effective_date,'DD/MM/YYYY'),'DD/MM/YYYY'));
fnd_dsql.add_text(' AND NOT EXISTS ( SELECT NULL
                                    FROM per_all_assignments_f pos1
                                   WHERE pos1.person_id = ASSIGNMENT.person_id AND ');
fnd_dsql.add_bind(to_date(to_char(p_effective_date,'DD/MM/YYYY'),'DD/MM/YYYY'));
fnd_dsql.add_text(' BETWEEN pos1.effective_start_date AND pos1.effective_end_date ) ');
fnd_dsql.add_text('
    		 AND NOT EXISTS
    		 (SELECT NULL
    		  FROM   per_all_assignments_f pos1
    		  WHERE  pos1.person_id = ASSIGNMENT.person_id
    		  AND	 ((pos1.assignment_type=''E'' and
    			   pos1.period_of_service_id=ASSIGNMENT.period_of_service_id) or
    			  (pos1.assignment_type=''A'' and
    			   pos1.application_id=ASSIGNMENT.application_id) or
    			  (pos1.assignment_type=''C'' and
    			   pos1.period_of_placement_date_start =
    			   ASSIGNMENT.period_of_placement_date_start))
    		  AND	 pos1.effective_start_date< ASSIGNMENT.effective_start_date)
   	          or  (ASSIGNMENT.effective_end_date < ');

fnd_dsql.add_bind(to_date(to_char(p_effective_date,'DD/MM/YYYY'),'DD/MM/YYYY'));
-- added and clause for bug 5168364
fnd_dsql.add_text(' and assignment.effective_end_date = (select max(effective_end_date)
                                       from per_all_assignments_f asg
                                      where asg.person_id = assignment.person_id
                                        and asg.assignment_type in(''A'',''C'',''E'')
                                     ) ');
fnd_dsql.add_text(' AND NOT EXISTS
		  (SELECT NULL
		     FROM per_all_assignments_f papf
		    WHERE papf.person_Id = ASSIGNMENT.person_id
		      AND papf.assignment_type in(''A'',''C'',''E'')
		      AND papf.effective_end_date >= ');
fnd_dsql.add_bind( to_date(to_char(p_effective_date,'DD/MM/YYYY'),'DD/MM/YYYY'));
fnd_dsql.add_text(' ))))'); -- 5214715

fnd_dsql.add_text(' and not exists(select 1
                   from per_person_list ppl
                   where ppl.security_profile_id = ');
fnd_dsql.add_bind(sec_rec.security_profile_id);
fnd_dsql.add_text(' and ppl.person_id = assignment.person_id
                   and    ppl.granted_user_id is null)');

  -- if the custom sql flag is set and the restriction text is not empty
  -- (>2 chars) then append the custom sql to the end of the statement

  if  sec_rec.custom_restriction_flag='Y' and length(sec_rec.restriction_text)>2 then
    fnd_dsql.add_text(' and ');
    fnd_dsql.add_text(sec_rec.restriction_text);
  end if;

 if g_debug then
    hr_utility.trace('select '||to_char(length(l_select_text)));
    hr_utility.trace('where '||to_char(length(l_where_clause)));
    l_execution_stmt2:=l_execution_stmt;
    while length(l_execution_stmt2)>0 loop
      hr_utility.trace(substr(l_execution_stmt2,1,70));
      l_execution_stmt2:=substr(l_execution_stmt2,71);
    end loop;
  end if;

 Execute_statement;
      hr_utility.set_location('Leaveing Craete_person_list',10);
END create_person_list;


--
-- ----------------------------------------------------------------------------
-- |---------------------< clear_per_list_table >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure clear_per_list_table (
          p_person_id          number,
          p_generation_scope   varchar2,
          p_business_group_id  number,
          p_effective_date     date) is
  --
  l_proc          varchar2(72)  := g_package||'clear_per_list_table';
  --
  l_sub_str       varchar2(1000);
  l_del_str       varchar2(8000);
  l_exe_str       varchar2(9000);

--
begin
  --
  hr_utility.set_location('Entering : '||l_proc,10);
  --
  -- Clear the records for this person.

  -- Bug6809753 - start
    l_del_str := ' delete from per_person_list ppl where
                 ppl.person_id = '||p_person_id||'
                 and ppl.granted_user_id is null and exists
                 (select ''X'' from per_security_profiles pspf
                 where pspf.security_profile_id = ppl.security_profile_id ';
  -- Bug6809753 - end

  if p_generation_scope = 'ALL_BUS_GRP' then

/* Commented Bug6809753 - start
     delete from per_person_list ppl where
                 ppl.person_id = p_person_id
                 and ppl.granted_user_id is null and exists
                 (select 'X' from per_security_profiles pspf
                 where pspf.security_profile_id = ppl.security_profile_id
                   and pspf.business_group_id = p_business_group_id);
    Commented Bug6809753 - end */

 -- Bug6809753 - start
    l_sub_str := ' and pspf.business_group_id = '||p_business_group_id||' ';
 -- Bug6809753 - end

  end if;
  if p_generation_scope = 'ALL_GLOBAL' then

  /* Commented Bug6809753 - start
     delete from per_person_list ppl where
                 ppl.person_id = p_person_id
                 and ppl.granted_user_id is null and exists
                 (select 'X' from per_security_profiles pspf
                 where pspf.security_profile_id = ppl.security_profile_id
		           and pspf.business_group_id is null);
   Commented Bug6809753 - end */

   -- Bug6809753 - start
   l_sub_str := ' and pspf.business_group_id is null ';
   -- Bug6809753 - end

  end if;
  if p_generation_scope = 'ALL_PROFILES' then

 /* Commented Bug6809753 - start
     delete from per_person_list ppl where
                 ppl.person_id = p_person_id
                 and ppl.granted_user_id is null and exists
                 (select 'X' from per_security_profiles pspf
                 where pspf.security_profile_id = ppl.security_profile_id);
   Commented Bug6809753 - end */

 -- Bug6809753 - start
   l_sub_str := '';
 -- Bug6809753 - end

  end if;
  -- un commanted the below line - Bug6809753
  l_exe_str := l_del_str||l_sub_str||')';

  execute immediate l_exe_str; -- Bug6809753

  -- Clear records for the contacts of this person
  -- 2906862 - dkerr 2003-05-01
  -- I've restricted the scan of PER_SECURITY_PROFILES to restricted
  -- contact profiles - which can drastically reduce the amount of I/O
  -- performed.
  -- Analysis of major customer data suggests the following :
  -- 1. Security profiles with "view_all_contacts_flag='N'"
  --    are usually a minority.
  -- 2. A typical installation may have hundreds of security
  --    profiles.
  --

  /* Commented Bug6809753 - start

  if p_generation_scope = 'ALL_BUS_GRP' then

  delete from per_person_list ppl
                  where ppl.security_profile_id in
                        (select pspf.security_profile_id
                           from per_security_profiles pspf
                          where (pspf.view_all_contacts_flag = 'N' or
                                (pspf.view_all_contacts_flag = 'Y' and
                                pspf.view_all_candidates_flag = 'X'))
                                and pspf.business_group_id = p_business_group_id
				)
		    and ppl.person_id in (
                        select pcr.contact_person_id
                          from per_contact_relationships pcr,
                               per_person_type_usages_f ptu,
                               per_person_types ppt
                         where pcr.person_id = p_person_id
                          and pcr.contact_person_id = ptu.person_id
                           and to_date(to_char(p_effective_date,'dd/mm/yyyy'), 'dd/mm/yyyy')
                               between ptu.effective_start_date
                               and ptu.effective_end_date
                           and ptu.person_type_id = ppt.person_type_id
                           and ppt.system_person_type = 'OTHER')
                    and ppl.granted_user_id is null;


  End if;
  if p_generation_scope = 'ALL_GLOBAL' then
    delete from per_person_list ppl
                  where ppl.security_profile_id in
                        (select pspf.security_profile_id
                           from per_security_profiles pspf
                          where (pspf.view_all_contacts_flag = 'N' or
                                (pspf.view_all_contacts_flag = 'Y' and
                                pspf.view_all_candidates_flag = 'X'))
                                and pspf.business_group_id is null
				)
		    and ppl.person_id in (
                        select pcr.contact_person_id
                          from per_contact_relationships pcr,
                               per_person_type_usages_f ptu,
                               per_person_types ppt
                         where pcr.person_id = p_person_id
                          and pcr.contact_person_id = ptu.person_id
                           and to_date(to_char(p_effective_date,'dd/mm/yyyy'), 'dd/mm/yyyy')
                               between ptu.effective_start_date
                               and ptu.effective_end_date
                           and ptu.person_type_id = ppt.person_type_id
                           and ppt.system_person_type = 'OTHER')
                    and ppl.granted_user_id is null;
  End if;
  if p_generation_scope = 'ALL_PROFILES' then
  delete from per_person_list ppl
                  where ppl.security_profile_id in
                        (select pspf.security_profile_id
                           from per_security_profiles pspf
                          where (pspf.view_all_contacts_flag = 'N' or
                                (pspf.view_all_contacts_flag = 'Y' and
                                pspf.view_all_candidates_flag = 'X'))
				)
		    and ppl.person_id in (
                        select pcr.contact_person_id
                          from per_contact_relationships pcr,
                               per_person_type_usages_f ptu,
                               per_person_types ppt
                         where pcr.person_id = p_person_id
                          and pcr.contact_person_id = ptu.person_id
                           and to_date(to_char(p_effective_date,'dd/mm/yyyy'), 'dd/mm/yyyy')

                               between ptu.effective_start_date
                               and ptu.effective_end_date
                           and ptu.person_type_id = ppt.person_type_id
                           and ppt.system_person_type = 'OTHER')
                    and ppl.granted_user_id is null;
  End if;

  Commented Bug6809753 - end */
    --
    -- Bug6809753 -start
    l_del_str := ' delete from per_person_list ppl
                  where ppl.security_profile_id in
                        (select pspf.security_profile_id
                           from per_security_profiles pspf
                          where (pspf.view_all_contacts_flag = ''N'' or
                                (pspf.view_all_contacts_flag = ''Y'' and
                                pspf.view_all_candidates_flag = ''X'')) '
                                ||l_sub_str||')
                    and ppl.person_id in (
                        select pcr.contact_person_id
                          from per_contact_relationships pcr,
                               per_person_type_usages_f ptu,
                               per_person_types ppt
                         where pcr.person_id = '||p_person_id||
                         ' and pcr.contact_person_id = ptu.person_id
                           and to_date('''||to_char(p_effective_date,
                               'dd/mm/yyyy')||''', ''dd/mm/yyyy'')
                               between ptu.effective_start_date
                               and ptu.effective_end_date
                           and ptu.person_type_id = ppt.person_type_id
                           and ppt.system_person_type = ''OTHER'')
                    and ppl.granted_user_id is null';
  --
  l_exe_str := l_del_str;
  --
  execute immediate l_exe_str;
  -- Bug6809753 -end

  hr_utility.set_location('Leaving : '||l_proc,20);
    --
end clear_per_list_table;
--
--
-- ----------------------------------------------------------------------------
-- |----------------------< clear_unrelated_contacts >------------------------|
-- ----------------------------------------------------------------------------
--
procedure clear_unrelated_contacts (
          p_generation_scope        in varchar2,
          p_business_group_id       in number
          ) is
  --
  l_proc          varchar2(72)  := g_package||'clear_unrelated_contacts';
  --
begin
  --
  hr_utility.set_location('Entering : '||l_proc,10);
  --
if p_generation_scope <> 'ALL_BUS_GRP' then

  delete from per_person_list ppl
   where ppl.security_profile_id in
         (select pspf.security_profile_id
            from per_security_profiles pspf
           where (pspf.view_all_contacts_flag = 'N' or
                 (pspf.view_all_contacts_flag = 'Y' and
                 pspf.view_all_candidates_flag = 'X')))
  /*   and ppl.person_id in
         (select papf.person_id
            from per_all_people_f papf
           where papf.person_id = ppl.person_id
             and ((p_generation_scope = 'ALL_BUS_GRP' and
                 papf.business_group_id = p_business_group_id) or
                 p_generation_scope <> 'ALL_BUS_GRP')) */
     and not exists
         (select null
            from per_all_assignments_f asg
           where asg.person_id = ppl.person_id)
     and not exists
         (select null
            from per_contact_relationships pcr
           where pcr.contact_person_id = ppl.person_id);

  else
     delete from per_person_list ppl
   where ppl.security_profile_id in
         (select pspf.security_profile_id
            from per_security_profiles pspf
           where (pspf.view_all_contacts_flag = 'N' or
                 (pspf.view_all_contacts_flag = 'Y' and
                 pspf.view_all_candidates_flag = 'X')))
    and ppl.person_id in
         (select papf.person_id
            from per_all_people_f papf
           where papf.person_id = ppl.person_id
             and papf.business_group_id = p_business_group_id)
     and not exists
         (select null
            from per_all_assignments_f asg
           where asg.person_id = ppl.person_id)
     and not exists
         (select null
            from per_contact_relationships pcr
           where pcr.contact_person_id = ppl.person_id);
 end if;
  --
  hr_utility.set_location('Leaving : '||l_proc,20);
  --
end clear_unrelated_contacts;
--
-- ----------------------------------------------------------------------------
-- |---------------------< clear_sp_list_table >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure clear_sp_list_table (
          p_generation_scope      varchar2,
          p_business_group_id     number,
          p_security_profile_id   number,
          p_clear_people_flag     boolean
          ) is
  --
  l_proc varchar2(72) := g_package||'clear_sp_list_table';
  --
begin
  --
  hr_utility.set_location('Entering : '||l_proc, 10);
  -- Clearing Organization static list
  delete
    from per_organization_list
   where security_profile_id = p_security_profile_id
     and user_id is null;
  --
  hr_utility.set_location(l_proc, 20);
  -- Clearing Position static list
  delete
    from per_position_list
   where security_profile_id = p_security_profile_id
     and user_id is null;
  --
  hr_utility.set_location(l_proc, 30);
  -- Clearing the Person static list
  if p_clear_people_flag then
    --
    delete
      from per_person_list
     where security_profile_id = p_security_profile_id
       and granted_user_id is null;
    --
  end if;
  --
  hr_utility.set_location(l_proc, 40);
  -- Clearing Payroll static list
  delete
    from pay_payroll_list
   where security_profile_id = p_security_profile_id;
  --
  hr_utility.set_location('Leaving : '||l_proc, 99);
  --
end clear_sp_list_table;
--
/* =======================================================================
  NAME
    process_person
  DESCRIPTION

  PARAMETERS
    l_effective_date      - date for which the secure lists are generated.
========================================================================= */
--
PROCEDURE process_person (p_person_id         per_all_people_f.person_id%TYPE,
                          p_effective_date    date,
			  p_business_group_id number,
			  p_generation_scope  varchar2,
			  p_who_to_process    varchar2)
IS
 l_proc varchar2(50) := g_package||'process_person';
 l_effective_date date;

 /*
 ** Notes on this cursor:
 **
 ** Returns people who are :
 **    Current on effective date.
 **    Current at somepoint in the future and either don't exist today
 **    or are 'ex' people today.
 **
 **  The date returned is the greatest out of the calculated ESD and the
 **  effective date.
 **
 **  For a current applicant who is hired in the future then that person
 **  will have PTU data which causes them to qualify against both these
 **  conditions. The min(esd) will result in only one of those PTU records
 **  to be taken into account and so the correct date is calculated.
 */
  /* Commented Bug6809753 - start
  cursor c_current_person is
  select  ppf.person_id, greatest(min(ppf.effective_start_date), p_effective_date)
     from  per_person_type_usages_f ppf,
           per_person_types ppt
    where  ppf.person_id = p_person_id
     and  ppf.person_type_id = ppt.person_type_id  --taken out for Performance bug.
       -- Current person today
      and  ((    -- ppf.person_type_id = ppt.person_type_id and
                ppt.business_group_id =
   	                       nvl(p_business_group_id,ppt.business_group_id)
             and p_effective_date between ppf.effective_start_date
  	                            and ppf.effective_end_date
             and ppt.system_person_type in ('EMP','APL','CWK'))
  	  OR
 	 -- Future person
  	  (   -- ppf.person_type_id = ppt.person_type_id and
  	       ppt.business_group_id =
   	                       nvl(p_business_group_id,ppt.business_group_id)
  	   and p_effective_date < ppf.effective_start_date
             and ppt.system_person_type in ('EMP','APL','CWK')))
  group by ppf.person_id;
Commented Bug6809753 - end */

-- Bug6809753 - start
cursor c_current_person is
 select  ppf.person_id, greatest(min(ppf.effective_start_date), p_effective_date)
   from  per_person_type_usages_f ppf,
         per_person_types ppt
  where  ppf.person_id = p_person_id
         /*
	 ** Current person today
	 */
    and  ((    ppf.person_type_id = ppt.person_type_id
           and ppt.business_group_id =
 	                       nvl(p_business_group_id,ppt.business_group_id)
           and p_effective_date between ppf.effective_start_date
	                            and ppf.effective_end_date
           and ppt.system_person_type in ('EMP','APL','CWK'))
	  OR
	 /*
	 ** Future person
	 */
	  (    ppf.person_type_id = ppt.person_type_id
	   and ppt.business_group_id =
 	                       nvl(p_business_group_id,ppt.business_group_id)
	   and p_effective_date < ppf.effective_start_date
           and ppt.system_person_type in ('EMP','APL','CWK')))
  group by ppf.person_id;

/*-- Start changes made for the bug 5252738 - Bug6809753 ---*/
     /* ** To exclude Current person today */

 cursor c_exclude_person is
 select  ppf.person_id
   from  per_person_type_usages_f ppf,
         per_person_types ppt
  where  ppf.person_id = p_person_id

    and  (   ppf.person_type_id = ppt.person_type_id
           and ppt.business_group_id =
 	                       nvl(p_business_group_id,ppt.business_group_id)
           and p_effective_date between ppf.effective_start_date
	                            and ppf.effective_end_date
           and ppt.system_person_type in ('EMP','APL','CWK'));
  /*-- End changes made for the bug 5252738 -Bug6809753 ---*/
 -- Bug6809753 - End

 cursor c_former_person is
 select  ppf.person_id, paf.assignment_type,
         least(max(paf.effective_end_date), p_effective_date) effective_date
   from  per_person_type_usages_f ppf,
         per_person_types ppt,
	 per_all_assignments_f paf
  where  ppf.person_id = p_person_id
    and  ppf.person_id = paf.person_id
    and  paf.assignment_type in ('A','C','E')
    and  paf.effective_start_date < p_effective_date
         /*
	 ** Existed as a current person at somepoint in history
	 */
    and  (     ppf.person_type_id = ppt.person_type_id
           and p_effective_date > ppf.effective_start_date
           and ppt.system_person_type in ('EMP','APL','CWK'))
	 /*
	 ** ...as an ex person on the effective date
	 */
    and exists (select null
	          from per_person_type_usages_f ppf1,
		       per_person_types ppt1
		 where ppf1.person_id = ppf.person_id
		   and p_effective_date between ppf1.effective_start_date
			         and ppf1.effective_end_date
	           and ppf1.person_type_id = ppt1.person_type_id
		   and ppt1.business_group_id = nvl(p_business_group_id,
		                                    ppt1.business_group_id)
		   and ppt1.system_person_type in ('EX_EMP','EX_APL','EX_CWK'))
          /*
	  ** ...and not a current person on effective date or in the future.
	  **
	  **   (Due to the implementation of PTU I can be both EMP and EX-APL
	  **    today.  i.e. I'm an employee who was successfully hired after
	  **    some application process. In this case the person should be
	  **    processed as a current and not an ex person.  Note the
	  **    exception for APLs who are former EMPs/CWKs - in this
	  **    case an APL who is also term'd should be visible as both an
	  **    APL and as EX-EMP/EX-CWK therefore this cursor can see people
	  **    who are EX-EMP/EX-CWK but who are also APL
	  */
    and not exists (select null
	              from per_person_type_usages_f ppf2,
		           per_person_types ppt2
		     where ppf2.person_id = ppf.person_id
		       and p_effective_date < ppf2.effective_end_date
	               and ppf2.person_type_id = ppt2.person_type_id
		       and ppt2.business_group_id = nvl(p_business_group_id,
		                                        ppt2.business_group_id)
		       and ppt2.system_person_type in ('EMP','CWK'))
  group by ppf.person_id, paf.assignment_type
  order by effective_date desc;

 cursor c_get_asg(p_person_id number,
                  p_effective_date date) is
        select paf.assignment_id, paf.effective_start_date
          from per_all_assignments_f paf
         where paf.person_id = p_person_id
   and paf.assignment_type not in ('B','O')        -- added from bug 4352765,  Bug 7412855
  and ( (p_effective_date between paf.effective_start_date
                                     and paf.effective_end_date)
                or
                (paf.effective_start_date > p_effective_date and
                not exists (select null
                              from per_all_assignments_f paf1
                             where paf1.assignment_id = paf.assignment_id
                               and paf1.effective_start_date <=
                                                      paf.effective_start_date)));

 cursor c_is_current_apl is
        select 'Y'
	  from per_person_type_usages_f ptu,
	       per_person_types ppt
	 where ptu.person_id = p_person_id
	   and p_effective_date < ptu.effective_end_date
	   and ptu.person_type_Id = ppt.person_type_id
	   and ppt.system_person_type = 'APL';
 cursor c_is_former is
        select 'Y'
	  from per_person_type_usages_f ptu,
	       per_person_types ppt
	 where ptu.person_id = p_person_id
	   and p_effective_date between ptu.effective_start_date
	                            and ptu.effective_end_date
	   and ptu.person_type_id = ppt.person_type_id
	   and ppt.system_person_type in ('EX_EMP','EX_CWK');

 l_is_current_apl varchar2(1) := 'N';
 l_is_former varchar2(1) := 'N';

 l_person_id       number;
 l_assignment_type PER_ALL_ASSIGNMENTS_F.ASSIGNMENT_TYPE%TYPE;
 l_person_proc_date  date;
 lc_person_id number(10); -- Bug6809753
 l_cleared_ppl  boolean := FALSE;

BEGIN

 hr_utility.set_location('Entering : '||l_proc,10);
 hr_utility.set_location('p_person_id '||p_person_id,15);
 hr_utility.set_location('p_effective_date '||to_char(p_effective_date,
                                                      'DD-MON-YYYY'),20);
 hr_utility.set_location('p_business_group_id '||p_business_group_id,25);
 hr_utility.set_location('p_generation_scope '||p_generation_scope,30);

 /*
 ** We need to find out quickly if the person is an APL today or in the
 ** future so we can control processing later.
 open c_is_current_apl;
 fetch c_is_current_apl into l_is_current_apl;
 close c_is_current_apl;
 */
 /*
 ** We need to find out if the person is current any 'EX' type
 open c_is_former;
 fetch c_is_former into l_is_former;
 close c_is_former;
 */

 hr_utility.set_location(l_proc,40);

 if    p_who_to_process in ('CURRENT','ALL')
--    or (    p_who_to_process = 'TERM'
--        and l_is_current_apl = 'Y'
--	and l_is_former = 'Y')
 then

   /*
   ** The current implementation coded below has one flaw when processing a former
   ** EMP/CWK who as applied for a job and is an APL with who to process as ALL.  In
   ** this case the person will be processed three times.
   **    1) As an APL by the current_person cursor.
   **    2) As an APL by the former_person cursor.
   **    3) As an EX-EMP/EX-CWK by the former_person cursor.
   **
   ** Optimizations for this issue will be considered at a later date.  If this comment
   ** is still in the file then you know the optimization has not yet been completed.
   */

   hr_utility.set_location(l_proc,50);
   /*
   ** We are processing current EMP/APL/CWK or
   ** we are processing former EMP/APL/CWK but the person we are dealing
   ** with is both a current APL and a former EMP/CWK in which case we
   ** also need to process them here.  This is because an APL should also
   ** be visible to the profiles who could see them when EMP/CWK.
   **
   ** In this section will determine whether the person is EMP/APL/CWK now or
   ** in the future and process them accordingly on the relevant date.
   */
   open c_current_person;
   fetch c_current_person into l_person_id, l_person_proc_date;

   if c_current_person%found then
     close c_current_person;
     /*
     ** Clear out the person list for this person_id
     */
     clear_per_list_table(p_person_id => p_person_id,
                      p_business_group_id => p_business_group_id,
		      p_generation_scope  => p_generation_scope,
		      p_effective_date    => p_effective_date);
     l_cleared_ppl := TRUE;

     /*
     ** Populate the person list for each assignment that this person has.
     */
     for l_asgrec in c_get_asg(l_person_id, l_person_proc_date) loop
       hr_utility.set_location(l_proc,60);
       hr_utility.trace('processing assignment :'||
                              to_char(l_asgrec.assignment_id));
       hr_security_internal.add_to_person_list(
                  p_effective_date    => l_person_proc_date,
                  p_assignment_id     => l_asgrec.assignment_id,
		  p_business_group_id => p_business_group_id,
		  p_generation_scope  => p_generation_scope);

     end loop;
   else
     close c_current_person;
   end if;
 end if;

 if     p_who_to_process in ('TERM','ALL')
--    or (    p_who_to_process = 'CURRENT'
--        and l_is_current_apl = 'Y'
--	and l_is_former = 'Y')
 then
   hr_utility.set_location(l_proc,70);
   /*
   ** We are processing former EMP/APL/CWK or
   ** we are processing current EMP/APL/CWK but the person we are dealing
   ** with is both a current APL and a former EMP/CWK in which case we
   ** also need to process them here.  This is because an APL should also
   ** be visible to the people who could see them when EMP/CWK.
   **
   ** In this section will determine whether the person is EX-EMP/EX-APL/EX-CWK
   ** now and process them accordingly on the relevant date.  In this case the
   ** relevant date is the effective_end_date of the last assignment they had.
   ** Note that we process a person twice if they are EX-APL and EX-EMP/EX-CWK.
   */
      -- Bug6809753 -start
    /*-- Start changes made for the bug 5252738 - Bug6809753 ---*/
   open c_exclude_person;
   fetch c_exclude_person into lc_person_id;

  if c_exclude_person%notfound then
  /*-- End changes made for the bug 5252738 - Bug6809753 ---*/
  -- Bug6809753 -end

   for l_former_person in c_former_person loop
     hr_utility.set_location(l_proc,80);
     if l_cleared_ppl <> TRUE then
       /*
       ** Clear out the person list for this person_id if it's not been cleared
       ** already for this person.
       */
       clear_per_list_table(p_person_id => p_person_id,
                      p_business_group_id => p_business_group_id,
		      p_generation_scope  => p_generation_scope,
		      p_effective_date    => p_effective_date);
       l_cleared_ppl := TRUE;
     end if;
     /*
     ** Populate the person list for each assignment that this person has.
     */
     for l_asgrec in c_get_asg(l_former_person.person_id,
                               l_former_person.effective_date) loop

       hr_utility.set_location(l_proc,90);
       hr_utility.trace('processing assignment :'||
                              to_char(l_asgrec.assignment_id));

       hr_security_internal.add_to_person_list(
                  p_effective_date    => l_former_person.effective_date,
                  p_assignment_id     => l_asgrec.assignment_id,
		  p_business_group_id => p_business_group_id,
		  p_generation_scope  => p_generation_scope);

     end loop;
     if l_former_person.assignment_type in ('E','C') then
       /*
       ** Exit if we've processed either an Emp or CWK.  For an APL or EX-APL
       ** who is also EX-EMP/EX-CWK we will process the APL/EX_APL record then
       ** the EX-EMP/EX-CWK record then exit.
       ** For someone who is both EX-EMP and EX-CWK we only want to process the
       ** person for the EX-type they were last. i.e. an EMP leaves and returns
       ** as CWK then leaves they will be both EX-EMP and EX-CWK in the PTU
       ** table. We only want to process them as EX-CWK.
       */
       hr_utility.set_location(l_proc,100);
       exit;
     end if;
   end loop;
   -- Bug6809753 -start
   end if;
   close c_exclude_person; /*-- End changes made for the bug 5252738 - Bug6809753 ---*/
   -- Bug6809753 -end
 end if;
 /*
 ** Load up the contacts for this person
 */
 add_contacts_for_person(p_person_id      => p_person_id,
                         p_effective_date => p_effective_date,
			 p_generation_scope => p_generation_scope,
			 p_business_group_id => p_business_group_id);

 hr_utility.set_location('Leaving : '||l_proc,110);

END process_person;
--
-- ----------------------------------------------------------------------------
-- |---------------------< generate_opp_lists >-------------------------------|
-- ----------------------------------------------------------------------------
--
procedure generate_opp_lists(
          p_effective_date        in date
         ,p_generation_scope      in varchar2
         ,p_business_group_id     in number
         ) is
  --
  l_effective_date      date;
  l_update_date         date;
  l_found               boolean default false;
  l_business_group_mode varchar2(20);
  l_proc                varchar2(72) := g_package||'.generate_opp_lists';
  --
  cursor security_profiles is
         select *
           from per_security_profiles
          where ((business_group_id = p_business_group_id and
                p_generation_scope = 'ALL_BUS_GRP')
             or (business_group_id is null and
                p_generation_scope = 'ALL_GLOBAL')
             or (p_generation_scope = 'ALL_PROFILES')
            and org_security_mode in ('NONE','HIER'));
  --
begin
  --
  -- Get the session date and the current date to avoid multiple selects.
  hr_utility.set_location('Entering '||l_proc, 10);
  hr_utility.set_location('Request ID '||p_request_id, 15);
  --
  l_effective_date := trunc(p_effective_date);
  l_update_date    := trunc(sysdate);
  --
  hr_utility.set_location(l_proc, 20);
  --
  for sec_rec in security_profiles loop
    --
    -- Delete previous entries for the profile. By using this function
    -- we will be using the old generation mechanism so we need to clear
    -- the person list data upfront.
    clear_sp_list_table(p_generation_scope    => p_generation_scope,
                        p_business_group_id   => sec_rec.business_group_id,
                        p_security_profile_id => sec_rec.security_profile_id,
                        p_clear_people_flag   => false);
    --
    hr_utility.set_location(l_proc, 30);
    --
    if (sec_rec.view_all_flag = 'N') then
      --
      hr_utility.set_location(l_proc, 40);
      --
      if (sec_rec.view_all_payrolls_flag = 'N')  then
        --
        hr_utility.set_location(l_proc, 50);
        --
        -- Build the payroll list.
        build_payroll_list(sec_rec.security_profile_id,
                           sec_rec.business_group_id,
                           sec_rec.include_exclude_payroll_flag,
                           l_effective_date,
                           l_update_date);
      --
      end if;  -- view_all_payrolls_flag
      --
      -- Do not insert the orgs if using user-based security.
      if (sec_rec.view_all_organizations_flag      = 'N'  and
        nvl(sec_rec.top_organization_method, 'S') <> 'U') then
        --
        hr_utility.set_location(l_proc, 60);
        --
        -- Determine business_group mode for the current security profile
        if sec_rec.business_group_id is null then
          l_business_group_mode := 'GLOBAL';
        else
          l_business_group_mode := 'LOCAL';
        end if;
        --
        -- Build organization list
        build_organization_list(sec_rec.security_profile_id,
                                sec_rec.include_top_organization_flag,
                                sec_rec.organization_structure_id,
                                sec_rec.organization_id,
                                sec_rec.exclude_business_groups_flag,
                                l_effective_date,
                                l_update_date,
                                l_business_group_mode);
        --
      end if;
      --
      -- Do not insert the positions if using user-based security.
      if (sec_rec.view_all_positions_flag      = 'N'  and
        nvl(sec_rec.top_position_method, 'S') <> 'U') then
        --
        hr_utility.set_location(l_proc, 70);
        --
        -- Build position list
        build_position_list(sec_rec.security_profile_id,
                            sec_rec.view_all_organizations_flag,
                            sec_rec.include_top_position_flag,
                            sec_rec.position_structure_id,
                            sec_rec.position_id,
                            l_effective_date,
                            l_update_date);
        --
      end if;
      --
      hr_utility.set_location(l_proc, 80);
      --
    end if;
    --
    l_found:=true;
    --
    hr_utility.set_location('Request ID '||p_request_id, 15);
    --
  end loop;
  --
  hr_utility.set_location(l_proc, 80);
  -- Clearing all unrelated contacts.
  clear_unrelated_contacts(p_generation_scope  => p_generation_scope,
                           p_business_group_id => p_business_group_id);
  --
  -- Add unrelated contacts for the profiles we've processed.
  hr_utility.set_location(l_proc, 90);
  hr_utility.set_location('Request ID '||p_request_id, 15);
  --
  add_unrelated_contacts(p_business_group_id => p_business_group_id,
                         p_generation_scope  => p_generation_scope,
                         p_effective_date    => l_effective_date);
  --
  hr_utility.set_location('Leaving '||l_proc, 130);
  --
end generate_opp_lists;

--
-- ----------------------------------------------------------------------------
-- |---------------------< build_lists_for_users >----------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE build_lists_for_users
  (p_sec_prof_rec      IN hr_security_internal.g_sec_prof_r
  ,p_effective_date    IN DATE
  ,p_debug             IN BOOLEAN DEFAULT FALSE
  ,p_user_id           IN NUMBER default null
  ,p_process_all_users IN BOOLEAN DEFAULT TRUE)

 IS

    --
    -- Local variables
    --
    l_proc     varchar2(72):= g_package||'build_lists_for_users';
    l_debug_type NUMBER := hr_security_internal.g_NO_DEBUG;
    l_person_id  NUMBER;
    l_employee_id NUMBER;
    l_user_id NUMBER;
    l_all_static_users VARCHAR2(1) := 'Y';
    --
    l_api_ovn NUMBER := 3;
    l_del_static_lists_warning BOOLEAN;

    --
    l_resp_id      NUMBER;
    l_resp_app_id  NUMBER;
    l_sec_grp_id   NUMBER;

    --
    -- Fetch the users in the static user list, ignoring users that do
    -- not have a person attached.  If p_user_id has a value then just that
	-- single user will be fetched.
    --
    CURSOR csr_get_users IS
    SELECT seu.user_id
          ,usr.employee_id person_id
          ,seu.security_user_id
          ,seu.object_version_number
    FROM   per_security_users seu
          ,fnd_user usr
    WHERE  seu.security_profile_id = p_sec_prof_rec.security_profile_id
    AND    (seu.process_in_next_run_flag = 'Y' OR l_all_static_users = 'Y')
    AND    seu.user_id = usr.user_id
    AND    usr.employee_id IS NOT NULL
    AND    nvl(p_user_id,usr.user_id) = seu.user_id;

    --
    -- Retrieve details of first responsibility available
    -- for the user to which this security profile is
    -- attached to perform the apps_initialize
    --
    CURSOR csr_get_resp (p_user_id number,p_security_profile_id varchar2)
    IS
    SELECT fusg.responsibility_id,
           fusg.responsibility_application_id,
           fusg.security_group_id
    FROM   FND_USER_RESP_GROUPS fusg
    WHERE  fusg.user_id = p_user_id
    AND    p_effective_date BETWEEN fusg.start_date
           AND NVL(fusg.end_date,p_effective_date)
   AND EXISTS(
       SELECT level_value  FROM
       fnd_profile_option_values
       WHERE profile_option_id = (SELECT profile_option_id  FROM  fnd_profile_options_vl
                                  WHERE profile_option_name = 'PER_SECURITY_PROFILE_ID')
       AND PROFILE_OPTION_VALUE = p_security_profile_id --SECURITY_PROFILE_ID
       AND LEVEL_ID=10003
       AND level_value=fusg.responsibility_id )
    AND    rownum = 1;

    CURSOR csr_get_resp_sge (p_user_id number,p_security_profile_id varchar2)
    IS
    SELECT fusg.responsibility_id,
           fusg.responsibility_application_id,
           fusg.security_group_id
    FROM   FND_USER_RESP_GROUPS fusg
    WHERE  fusg.user_id = p_user_id
    AND    p_effective_date BETWEEN fusg.start_date
           AND NVL(fusg.end_date,p_effective_date)
   AND EXISTS(
       SELECT RESPONSIBILITY_ID FROM per_sec_profile_assignments_v
       WHERE user_id = p_user_id
         AND security_profile_id = p_security_profile_id
         AND responsibility_id = fusg.responsibility_id)
   AND    rownum = 1;

BEGIN
    hr_utility.set_location(l_proc||' sec prof id '||
                              to_char(p_sec_prof_rec.security_profile_id),13);
    hr_utility.set_location(l_proc||' p_effective_date '||
                              p_effective_date,13);
    hr_utility.set_location(l_proc||' p_user_id '||
                              p_user_id,13);

    --
    -- Check that the mandatory parameters have been entered.
    --
    IF p_sec_prof_rec.security_profile_id IS NOT NULL
    AND p_effective_date IS NOT NULL THEN

        --
        -- If debug output is required, set the debug type.
        --
        IF p_debug THEN
            l_debug_type := hr_security_internal.G_FND_LOG;
        END IF;
        --
        -- make sure that single users who are unchecked in the security
		-- profiles form are picked up.
        --
        -- if p_process_all_user is true then run for everybody, regardless of
		-- process flag status.
        --
        IF (p_user_id is not null OR p_process_all_users)
        THEN
           l_all_static_users := 'Y';
        ELSE
           l_all_static_users := 'N';
        END IF;

        FOR user_rec IN csr_get_users LOOP

            -- Bug 3598627
            -- If user-based custom security is used then
            -- retrieve the first valid responsibility for
            -- user to which this security profile is
            -- attached and call 'apps_initialize' procedure
            -- to set the REQUIRED user level context.
            --
            -- Note: The first valid responsibility may not
            --       set the correct responsibility level
            --       context, but it is user level context
            --       required here will be correct.
            --
            -- If valid responsibility is not found for user
            -- security permisions will not be stored in the
            -- static list.

            l_resp_id     := NULL;
            l_resp_app_id := NULL;
            l_sec_grp_id  := NULL;


            IF (p_sec_prof_rec.custom_restriction_flag = 'U')
            THEN
          if fnd_profile.value('ENABLE_SECURITY_GROUPS') = 'N' then
          OPEN
          csr_get_resp(user_rec.user_id,to_char(p_sec_prof_rec.security_profile_id));
          FETCH csr_get_resp INTO l_resp_id,
                                  l_resp_app_id,
                                  l_sec_grp_id;
          hr_utility.set_location('Security Groups No - Resp id-'||l_resp_id,555);
         CLOSE csr_get_resp;
         else
         OPEN
         csr_get_resp_sge(user_rec.user_id,to_char(p_sec_prof_rec.security_profile_id));
         FETCH csr_get_resp_sge INTO l_resp_id,
                                     l_resp_app_id,
                                     l_sec_grp_id;
         hr_utility.set_location('Security Groups Yes - Resp id '||l_resp_id,556);
         CLOSE csr_get_resp_sge;
         end if;
         IF l_resp_id is not null then
                fnd_global.apps_initialize(user_rec.user_id,
                                           l_resp_id,
                                           l_resp_app_id,
                                           l_sec_grp_id);
         else
         hr_utility.set_location('Security Profile was not attached to any responsibility of this user',557);
         end if;
            END IF;

            -- If user-based custom security is not used or
            -- valid responsibility is found when used.
            --
            IF (NVL(p_sec_prof_rec.custom_restriction_flag, 'N') <> 'U')
               OR (l_resp_id IS NOT NULL) THEN
              --
              -- For each user in the static list, assess
              -- permissions and store in the static tables.
              --
              -- Set the person to be the named person on the
              -- security profile if set, otherwise use the
              -- person on the user.
              --
              l_person_id := NVL(p_sec_prof_rec.named_person_id
                                ,user_rec.person_id);

              hr_security_internal.evaluate_access
                (p_person_id            => l_person_id
                ,p_user_id              => user_rec.user_id
                ,p_effective_date       => p_effective_date
                ,p_sec_prof_rec         => p_sec_prof_rec
                ,p_what_to_evaluate     => hr_security_internal.g_ALL
                ,p_use_static_lists     => FALSE
                ,p_update_static_lists  => TRUE
                ,p_debug                => l_debug_type);
                --
			   --Bug 4742108 set everyone back to N if they have been processed
			   -- regardless of whether processing all or marked static users.
			      l_api_ovn := user_rec.object_version_number;
				  --  Bug 4338667
                  --  now record has been processed need to set
				  --  process_in_next_run_flag from 'Y' to 'N'.
				  --
				  hr_security_user_api.update_security_user
				  (p_effective_date       => p_effective_date
                  ,p_security_user_id     => user_rec.security_user_id
                  ,p_user_id              => user_rec.user_id
                  ,p_security_profile_id  => p_sec_prof_rec.security_profile_id
                  ,p_process_in_next_run_flag => 'N'
                  ,p_object_version_number    => l_api_ovn
				  ,p_del_static_lists_warning => l_del_static_lists_warning);
            END IF;
        END LOOP;
    END IF; -- p_sec_prof_rec.security_profile_id has value
hr_utility.set_location('Leaving : '||l_proc,50);
END build_lists_for_users;
--
-- ----------------------------------------------------------------------------
-- |---------------------< build_lists_for_user >------------------------------|
-- ----------------------------------------------------------------------------
-- built for gsi enhancement bug 4634655 and 4338667.
-- this is not a public api but customers have been granted permission to call
-- this procedure directly so DO NOT change parameters as this will invalidate
-- customer code.
--
PROCEDURE build_lists_for_user
  (p_security_profile_id  number,
   p_user_id number,
   p_effective_date date default trunc(sysdate)) IS
   --
   -- Local Variables
   --
   l_proc                varchar2(72):= g_package||'build_lists_for_user';
   l_debug               boolean default FALSE;
   l_process_all_users   boolean := TRUE; -- as just running for one user.
   l_user_id             number;
   l_security_profile_id number;
   l_sec_prof_rec hr_security_internal.g_sec_prof_r; -- per_security_profiles
   --                                                   %ROWTYPE;
   -- Cursors:
   --
   -- check that user and profile exist in per_security_users
   --
    CURSOR csr_check_user_exists(p_user_id number, p_security_profile_id number)
	IS
    SELECT seu.user_id,
           seu.security_profile_id
    FROM   per_security_users seu
    WHERE  seu.user_id = p_user_id
    AND    seu.security_profile_id = p_security_profile_id;
   --
   -- get security profile
   --
    CURSOR csr_security_profile_record(l_security_profile_id number)
	IS
    SELECT *
	from   per_security_profiles
    where  security_profile_id = l_security_profile_id;
--
BEGIN
--
   hr_utility.trace('Processing for Single User');
   hr_utility.set_location('Entering : '||l_proc,10);
   --
   -- Check that the mandatory parameters have been entered.
   --
   IF p_security_profile_id IS NOT NULL
   AND p_user_id IS NOT NULL
   THEN
      -- if they exist continue processing, if they don't then do nothing.
      -- check that user and security profile exist
      OPEN  csr_check_user_exists(p_user_id, p_security_profile_id);
                FETCH csr_check_user_exists
				 INTO l_user_id,
				      l_security_profile_id;
                CLOSE csr_check_user_exists;
      hr_utility.set_location(l_proc||'p_effective_date : '||p_effective_date,20);
      hr_utility.set_location(l_proc||'p_user_id : '||p_user_id,21);
      hr_utility.set_location(l_proc||'p_security_profile_id : '||
                                       p_security_profile_id,23);
      hr_utility.set_location(l_proc||'l_user_id : '||l_user_id,25);
      hr_utility.set_location(l_proc||'l_security_profile_id : '||
                                       l_security_profile_id,27);
      hr_utility.set_location('IF l_user_id or l_security profile id is null '
	                          ,30);
      hr_utility.set_location('then it has not been found in per_security_users'
	                          ,30);
      --
      -- if they exist then get security profile for user
      --
      OPEN  csr_security_profile_record(l_security_profile_id);
                FETCH csr_security_profile_record
				 INTO l_sec_prof_rec;
                CLOSE csr_security_profile_record;
      -- call build lists for users for a single user
      hr_utility.set_location(l_proc||'call build_lists_for_users '
	                                ||p_effective_date,40);
      build_lists_for_users
        (p_sec_prof_rec      => l_sec_prof_rec
        ,p_effective_date    => trunc(p_effective_date)
        ,p_debug             => l_debug
		,p_user_id           => l_user_id
		,p_process_all_users => l_process_all_users);
   END IF;
   hr_utility.set_location('Leaving : '||l_proc,69);
END build_lists_for_user;
--
-- ----------------------------------------------------------------------------
-- |---------------------< generate_list_control >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure generate_list_control(
                     p_effective_date            date,
                     p_generation_scope          varchar2,
		             p_business_group_id         varchar2 default null,
		             p_security_profile_id       varchar2 default null,
		             p_who_to_process            varchar2 default null,
		             p_action_parameter_group_id varchar2 default null,
					 p_user_id                   varchar2 default null,
					 p_static_user_processing    varchar2 default 'ALL_STATIC',
		     -- Bug fix 3816741
		             errbuf    out NOCOPY        varchar2,
             	     retcode   out NOCOPY        number) is

 l_proc varchar2(60) := g_package||'generate_list_control';

 l_business_group_id         number;
 l_security_profile_id       number;
 l_action_parameter_group_id number;
 l_user_id                   number;
 l_security_profile_name     per_security_profiles.security_profile_name%TYPE;
 l_logging                   pay_action_parameters.parameter_value%TYPE;
 l_request_id                number;
 l_effective_date            varchar2(50);
 l_update_date  date;
 l_debug        boolean := FALSE;
 l_success      boolean;
 l_status       varchar2(100);
 l_phase        varchar2(100);
 l_dev_status   varchar2(100);
 l_dev_phase    varchar2(100);
 l_message      varchar2(100);
 l_request_data varchar2(100);
 c_wait         number := 60;
 c_timeout      number := 300;
 l_process_all_users boolean := TRUE;

 -- bug fix 3816741 starts here

 l_call_status boolean;

 -- bug fix 3816741 ends here

  --
  -- Fetch the action parameter to determine if logging
  -- should be switched on.
  --
  CURSOR csr_get_action_param IS
  SELECT pap.parameter_value
  FROM   pay_action_parameters pap
  WHERE  pap.parameter_name = 'LOGGING';

  CURSOR security_profiles
    IS
      SELECT  *
      FROM    per_security_profiles
      WHERE  (  (business_group_id = p_business_group_id and
                 p_generation_scope = 'ALL_BUS_GRP')
              OR
                (business_group_id is null and
                 p_generation_scope = 'ALL_GLOBAL')
              OR
	        (p_generation_scope = 'ALL_PROFILES')
      AND     org_security_mode IN ('NONE','HIER')
              );
--
begin
 hr_utility.set_location('Entering : '||l_proc,10);

 l_effective_date := fnd_date.date_to_canonical(p_effective_date);
 l_security_profile_id := to_number(p_security_profile_id);
 l_business_group_id := to_number(p_business_group_id);
 l_user_id := to_number(p_user_id);
 l_action_parameter_group_id := to_number(p_action_parameter_group_id);
 l_update_date    := trunc(sysdate);
 --
 /*
 ** Perform restart checking....
 */
 l_request_data := fnd_conc_global.request_data;
 hr_utility.set_location(l_request_data,12);
 if l_request_data is not null then

   OPEN  csr_get_action_param;
   FETCH csr_get_action_param INTO l_logging;
   CLOSE csr_get_action_param;

   --
   -- If logging is set to General, enable debugging.
   --
   IF instr(NVL(l_logging, 'N'), 'G') <> 0 THEN
       l_debug := TRUE;
   END IF;
   -- Bug 4338667. If user has been specified just run for that user.
   -- calling build_list for user rather than buld lists for users to avoid
   -- having to dup code by calling sec rec cursor for just this users
   -- security profile id.  If this is considerably less efficient then we can
   -- revise.
/*
   IF p_user_id IS NOT NULL
   THEN
      hr_utility.trace('Processing for Single User - 1');
      --
      build_lists_for_user
        (p_security_profile_id => p_security_profile_id
        ,p_user_id             => l_user_id
        ,p_effective_date      => p_effective_date);
   END IF;
*/
   -- Bug 4338667 process all static users unless process only flagged users has
   -- been choosen
  IF p_static_user_processing = 'FLAGGED_STATIC'
  THEN
     l_process_all_users := FALSE;
  ELSE
     l_process_all_users := TRUE;
  END IF;

   /*
   ** On restart we need to finish off by processing the
   ** ex-emps.
   */
   FOR sec_rec in security_profiles LOOP
     hr_utility.set_location(l_proc||' SP id '||
                             to_char(sec_rec.security_profile_id),13);
     add_person_list_changes (sec_rec.security_profile_id,
                              p_effective_date,
                              l_update_date);

     --
     -- Build static lists for any users in the list of people to
     -- build static lists for.  At present, this is outside of the
     -- multithreaded PYUGEN process.
     --
     build_lists_for_users
        (p_sec_prof_rec      => sec_rec
        ,p_effective_date    => p_effective_date
        ,p_process_all_users => l_process_all_users
        ,p_user_id           => l_user_id
        ,p_debug             => l_debug);

   END LOOP;

   -- Bug fix 3816741 starts here
   -- code to check the status of child request. PERSLM will error out
   -- if any of the parallel process for MSL_PERSON_LIST concurrent
   -- program errors out.

    l_call_status :=  fnd_concurrent.get_request_status(
   				                      request_id => l_request_data,
                                      phase      => l_phase,
                                      status     => l_status,
                                      dev_phase  => l_dev_phase,
                                      dev_status => l_dev_status,
                                      message    => l_message);

     hr_utility.set_location(l_proc||' Dev phase:'||l_dev_phase,14);
     hr_utility.set_location(l_proc||' Dev status:'||l_dev_status,15);

     if  l_dev_phase = 'COMPLETE' and l_dev_status = 'ERROR' then
         errbuf := l_message;
         retcode := 2;
     else
         retcode := 0;
     end if;

   -- Bug fix 3816741 ends here
   return;

 end if;
 /*
 ** Validate the input parameters where appropriate.
 **
 ** For ALL_PROFILES and ALL_GLOBAL if any value has been provided for BG ID or
 ** SP ID we'll just ignore them.
 */
 if p_generation_scope in ('SINGLE_PROF','SINGLE_USER') and
    p_security_profile_id is null then
    /*
    ** No security profile has been specified.
    */
    hr_utility.set_message(800,'PER_289776_NO_PROF_ID');
    hr_utility.raise_error;
 elsif p_generation_scope = 'ALL_BUS_GRP' and
       p_business_group_id is null then
    /*
    ** No business group has been specified.
    */
    hr_utility.set_message(800,'PER_289777_NO_BG_ID');
    hr_utility.raise_error;
 elsif p_generation_scope = 'SINGLE_USER' and
       p_user_id is null then
    /*
    ** No user has been specified.  Bug 4338667.
    */
    hr_utility.set_message(800,'PER_50293_NO_USER_ID');
    hr_utility.raise_error;
 end if;
 -- Bug 4338667 call build_lists_for_user directly if single user option
 -- specified.
 --
/* IF p_generation_scope = 'SINGLE_USER'
 THEN
      hr_utility.trace('Processing for Single User');
      build_lists_for_user
        (p_security_profile_id => p_security_profile_id
        ,p_user_id             => l_user_id
        ,p_effective_date      => p_effective_date);
 ELSE */
 if p_generation_scope in ('SINGLE_PROF','SINGLE_USER') then
   hr_utility.trace('Processing for Single Profile or Single User');
   hr_utility.set_location(l_proc||'Single Profile or Single User ',19);
   hr_utility.set_location(l_proc||'call generate_lists ',20);
   generate_lists(p_effective_date         => p_effective_date,
                  p_generation_scope       => p_generation_scope,
                  p_security_profile_id    => l_security_profile_id,
		  p_who_to_process         => p_who_to_process,
		  p_user_id                => l_user_id,
		  p_static_user_processing => p_static_user_processing);
 else
   /*
   ** We are doing all profiles, all profiles in BG or all global profiles.
   ** In this case we can process by assignment using PYUGEN if HR is installed.
   ** If HR is shared then use the old sequential mechanism.
   */
   if hr_general.chk_product_installed(800) = 'TRUE' then
     hr_utility.set_location(l_proc,30);
     /*
     ** HR is fully installed so we will use PYUGEN for the person list. First
     ** we must generate the Org, Pos and Payroll list information...
     */
     generate_opp_lists(p_effective_date    => p_effective_date,
                        p_generation_scope  => p_generation_scope,
		        p_business_group_id => l_business_group_id);
     /*
     ** ...now submit PYUGEN to do the people bit...
     */
     hr_utility.set_location(l_proc,40);

     l_request_id := fnd_request.submit_request(application => 'PER',
                program     => 'MSL_PERSON_LIST',
                sub_request => TRUE,
		argument1   => 'ARCHIVE',
		argument2   => 'PESLM',
		argument3   => 'HR_PROCESS',
		argument4   => l_effective_date,
		argument5   => l_effective_date,
		argument6   => 'PROCESS',
		argument7   => fnd_profile.value('PER_BUSINESS_GROUP_ID'),
		argument8   => null,
		argument9   => null,
		argument10  => l_action_parameter_group_id,
		argument11  => 'BUSINESS_GROUP_ID='||l_business_group_id,
		argument12  => 'GENERATION_SCOPE='||p_generation_scope,
		argument13  => 'WHO_TO_PROCESS='||p_who_to_process,
		argument14  => chr(0));

     /*
     ** Set the status of the process and then exit until the sub-requests
     ** have completed.
     */
     -- Bug fix 3816741
     -- l_request_id passed as request_data to check the status of
     -- MSL_PERSON_LIST concurrent program.

     if l_request_id = 0 then
	errbuf := fnd_message.get;
	retcode := 2;
     else
        fnd_conc_global.set_req_globals(conc_status => 'PAUSED',
                                     request_data=> l_request_id );
	retcode := 0;
     end if;
   else
     /*
     ** HR is shared so use the old mechanism but using the new submission
     ** mechanism.
     */
     hr_utility.set_location(l_proc,50);
     generate_lists(p_effective_date    => p_effective_date,
                    p_generation_scope  => p_generation_scope,
		    p_business_group_id => l_business_group_id,
		    p_who_to_process    => p_who_to_process,
		    p_user_id           => l_user_id,
		    p_static_user_processing => p_static_user_processing);
   end if;
 --end if;
end if;
hr_utility.set_location('Leaving : '||l_proc,100);

end generate_list_control;
--
-- ----------------------------------------------------------------------------
-- |---------------------< generate_list_control >-----------------------------|
-- ----------------------------------------------------------------------------
--
-- Bug fix 3816741
-- Calls the overloaded  generate_list_control which has errbuf and retcode
-- parameter added to return the concurrent program status.

procedure generate_list_control(
             p_effective_date            date,
             p_generation_scope          varchar2,
		     p_business_group_id         varchar2 default null,
		     p_security_profile_id       varchar2 default null,
		     p_who_to_process            varchar2,
		     p_action_parameter_group_id varchar2,
			 p_user_id                   varchar2 default null,
			 p_static_user_processing    varchar2 default 'ALL_STATIC') is

    l_errbuf varchar2(32000);
    l_retcode number;
begin
     generate_list_control( p_effective_date => p_effective_date,
                            p_generation_scope    => p_generation_scope,
                            p_business_group_id   => p_business_group_id,
                            p_security_profile_id => p_security_profile_id,
			    p_who_to_process      => p_who_to_process,
			    p_action_parameter_group_id => p_action_parameter_group_id,
			    p_user_id            => p_user_id,
			    p_static_user_processing => p_static_user_processing,
                            errbuf => l_errbuf,
                            retcode => l_retcode);
end generate_list_control;

--
-- ----------------------------------------------------------------------------
-- |-------------------------< submit_security >------------------------------|
-- ----------------------------------------------------------------------------
--
procedure submit_security(errbuf 		      out NOCOPY varchar2,
                          retcode 		      out NOCOPY number,
                          p_effective_date 	          varchar2,
                          p_generation_scope 	      varchar2,
                          p_business_group_id 	      varchar2,
                          p_security_profile_id       varchar2,
			              p_who_to_process            varchar2,
			              p_action_parameter_group_id varchar2,
			              p_user_name                 varchar2 default null,
						  p_static_user_processing    varchar2 default 'ALL_STATIC') is

  l_proc varchar2(100) := g_package||'submit_security';

begin

-- hr_utility.trace_on('F','LISTGEN');

 hr_utility.set_location('Entering '||l_proc,10);

 --
 -- Set variables used for WHO columns
 --
 p_program_id := fnd_profile.value('CONC_PROGRAM_ID');
 p_request_id := fnd_profile.value('CONC_REQUEST_ID');
 p_program_application_id := fnd_profile.value('CONC_PROGRAM_APPLICATION_ID');
 p_update_date := trunc(sysdate);

 generate_list_control
       (p_effective_date => nvl(fnd_date.canonical_to_date(p_effective_date)
	    ,sysdate),
        p_generation_scope          => p_generation_scope,
        p_business_group_id         => p_business_group_id,
        p_security_profile_id       => p_security_profile_id,
		p_who_to_process            => p_who_to_process,
		p_action_parameter_group_id => p_action_parameter_group_id,
		p_user_id                   => p_user_name,
		-- p_user_name is a misnomer;user name shows on param but passes user id
		p_static_user_processing    => p_static_user_processing,
		-- Bug 3816741. Parameters passed to get the concurrent program status.
		errbuf => errbuf,
        retcode => retcode);

 hr_utility.set_location('Leaving '||l_proc,20);
end;
--
-- ----------------------------------------------------------------------------
-- |----------------------< generate_lists >----------------------------------|
-- ----------------------------------------------------------------------------
--
procedure generate_lists(
          p_effective_date        in date
         ,p_security_profile_name in varchar2 default 'ALL_SECURITY_PROFILES'
         ,p_business_group_mode   in varchar2 default 'LOCAL'
          ) is
  --
  l_generation_scope   varchar2(30);
  l_proc               varchar2(72) := g_package||'generate_lists';
  --
begin
  --
  if p_security_profile_name = 'ALL_SECURITY_PROFILES' then
    --
    l_generation_scope := 'ALL_PROFILES';
    --
  else
     l_generation_scope := 'SINGLE_PROF';
  end if;
  --
  generate_lists(p_effective_date         => p_effective_date,
                 p_generation_scope       => l_generation_scope,
                 p_security_profile_name  => p_security_profile_name,
                 p_who_to_process         => 'ALL');
  --
end generate_lists;
--
-- ----------------------------------------------------------------------------
-- |----------------------< generate_lists >----------------------------------|
-- ----------------------------------------------------------------------------
--
procedure generate_lists(
          p_effective_date         in date
         ,p_generation_scope       in varchar2
         ,p_business_group_id      in number   default null
         ,p_security_profile_id    in number   default null
         ,p_security_profile_name  in varchar2 default null
         ,p_who_to_process         in varchar2 default null
         ,p_user_id                in number   default null
		 ,p_static_user_processing in varchar2 default 'ALL_STATIC'
          ) is
  --
  l_effective_date       date;
  l_update_date          date;
  l_found                boolean default false;
  l_debug                boolean      := false;
  l_business_group_mode  varchar2(30);
  l_proc                 varchar2(72) := g_package||'generate_lists';
  l_logging              pay_action_parameters.parameter_value%type;
  l_process_all_users    boolean default true;
  l_user_id              number;
  --
  -- Fetch the action parameter to determine if logging
  -- should be switched on.
  cursor csr_get_action_param is
         select pap.parameter_value
           from pay_action_parameters pap
          where pap.parameter_name = 'LOGGING';
  --
  cursor security_profiles is
         select *
           from per_security_profiles
          where (((security_profile_id = p_security_profile_id or
                security_profile_name = p_security_profile_name)
                and p_generation_scope in ('SINGLE_PROF','SINGLE_USER'))
             or (business_group_id = p_business_group_id and
                p_generation_scope = 'ALL_BUS_GRP')
             or (business_group_id is null and
                p_generation_scope='ALL_GLOBAL')
             or (p_generation_scope = 'ALL_PROFILES'))
            and org_security_mode in ('NONE', 'HIER');
  --
begin
  --
  -- Get the session date and the current date to avoid multiple selects.
  hr_utility.set_location('Entering '||l_proc, 10);
  --
  l_effective_date := trunc(p_effective_date);
  l_update_date    := trunc(sysdate);
  l_user_id        := p_user_id;
  -- Get the debug paramater
  open  csr_get_action_param;
  fetch csr_get_action_param into l_logging;
  close csr_get_action_param;
  --
  -- If logging is set to General, enable debugging.
  if instr(nvl(l_logging, 'N'), 'G') <> 0 then
    l_debug := true;
  end if;
  -- Bug 4338667: if user name is passed then this must be running for single
  -- user in single security profile, so just call build_list_for_user directly.
 /* IF p_user_id IS NOT NULL
   THEN
      hr_utility.trace('Processing for Single User - 2');
      build_lists_for_user
        (p_security_profile_id => p_security_profile_id
        ,p_user_id             => l_user_id
        ,p_effective_date      => p_effective_date);
   END IF; */
  --
  -- Bug 4338667:  if not explicitly processing for certain static users then
  -- process for all of them
  IF p_static_user_processing = 'FLAGGED_STATIC'
  THEN
     l_process_all_users := FALSE;
  ELSE
     l_process_all_users := TRUE;
  END IF;
  --
  hr_utility.set_location(l_proc, 20);
  --
  for sec_rec in security_profiles loop
    --
    -- Delete previous entries for the profile. By using this function
    -- we will be using the old generation mechanism so we need to clear
    -- the person list data upfront.
    clear_sp_list_table(p_generation_scope    => p_generation_scope,
                        p_business_group_id   => sec_rec.business_group_id,
                        p_security_profile_id => sec_rec.security_profile_id,
                        p_clear_people_flag   => true);
    --
    hr_utility.set_location(l_proc, 30);
    --
    -- If there are no restrictions or this profile uses user-based
    -- security, do not execute the inserts.
    if(sec_rec.view_all_employees_flag     = 'N'   or
       sec_rec.view_all_applicants_flag    = 'N'   or
       sec_rec.view_all_cwk_flag           = 'N'   or
      (sec_rec.view_all_contacts_flag      = 'N'   or
      (sec_rec.view_all_contacts_flag      = 'Y'   and
       sec_rec.view_all_candidates_flag    = 'X')) or
       sec_rec.view_all_organizations_flag = 'N'   or
       sec_rec.view_all_positions_flag     = 'N'   or
       sec_rec.view_all_payrolls_flag      = 'N'   or
       sec_rec.custom_restriction_flag     = 'Y')  then
      --
      hr_utility.set_location(l_proc, 40);
      --
      if (sec_rec.view_all_payrolls_flag = 'N')  then
        --
        hr_utility.set_location(l_proc, 50);
        --
        -- Build the payroll list.
        build_payroll_list(sec_rec.security_profile_id,
                           sec_rec.business_group_id,
                           sec_rec.include_exclude_payroll_flag,
                           l_effective_date,
                           l_update_date);
        --
      end if; -- view_all_payrolls_flag
      --
      -- Do not insert if using user-based security.
      if(sec_rec.view_all_organizations_flag       = 'N'  and
        nvl(sec_rec.top_organization_method, 'S') <> 'U') then
        --
        hr_utility.set_location(l_proc, 60);
        -- Determine business_group mode for the current security profile
        if sec_rec.business_group_id is null then
          l_business_group_mode := 'GLOBAL';
        else
          l_business_group_mode := 'LOCAL';
        end if;
        -- Build organization list
        build_organization_list(sec_rec.security_profile_id,
                                sec_rec.include_top_organization_flag,
                                sec_rec.organization_structure_id,
                                sec_rec.organization_id,
                                sec_rec.exclude_business_groups_flag,
                                l_effective_date,
                                l_update_date,
                                l_business_group_mode);
        --
      end if;
      --
      -- Do not insert if using user-based security.
      if(sec_rec.view_all_positions_flag           = 'N'  and
        nvl(sec_rec.top_organization_method, 'S') <> 'U'  and
        nvl(sec_rec.top_position_method, 'S')     <> 'U') then
        --
        hr_utility.set_location(l_proc, 70);
        -- Build position list
        build_position_list(sec_rec.security_profile_id,
                            sec_rec.view_all_organizations_flag,
                            sec_rec.include_top_position_flag,
                            sec_rec.position_structure_id,
                            sec_rec.position_id,
                            l_effective_date,
                            l_update_date);
        --
      end if;
      --
      -- Build person list if we have any person level restriction.
      if(sec_rec.view_all_employees_flag               = 'N'    or
         sec_rec.view_all_applicants_flag              = 'N'    or
         sec_rec.view_all_cwk_flag                     = 'N'    or
        (sec_rec.view_all_contacts_flag                = 'N'    or
        (sec_rec.view_all_contacts_flag                = 'Y'    and
         sec_rec.view_all_candidates_flag              = 'X'))) and
        (nvl(sec_rec.top_organization_method, 'S')    <> 'U'    and
         nvl(sec_rec.top_position_method, 'S')        <> 'U'    and
         nvl(sec_rec.custom_restriction_flag, 'N')    <> 'U')   then
        --
        create_person_list(sec_rec,
                           l_effective_date,
                           l_update_date,
                           p_who_to_process);
        --
      end if;
      --
      -- Add person list changes.
      add_person_list_changes(sec_rec.security_profile_id,
                              l_effective_date,
                              l_update_date);
      --
      -- Build static lists for any users in the list of people to
      -- build static lists for.
      build_lists_for_users(p_sec_prof_rec      => sec_rec
                           ,p_effective_date    => l_effective_date
                           ,p_process_all_users => l_process_all_users
                           ,p_user_id           => l_user_id
                           ,p_debug             => l_debug);
      --
    end if;
    --
    -- We only populate build_contact_list if restricting by contacts.
    -- Otherwise there is no point in populating the lists because
    -- show_person handles view_all_contacts = Yes profiles.
    -- The contact list is also only built when user-based restrictions
    -- are not in use.
    --
    -- A condition with view_all_contacts_flag = All and
    -- view_all_candidates_flag = None, needs caching (ie: similar to
    -- record existing in per_person_list). The additional OR condition
    -- is included as part of Candidate Security enchancements.
    if(sec_rec.view_all_contacts_flag             = 'N'   or
      (sec_rec.view_all_contacts_flag             = 'Y'   and
       sec_rec.view_all_candidates_flag           = 'X')) and
      (nvl(sec_rec.top_organization_method, 'S') <> 'U'   and
       nvl(sec_rec.top_position_method, 'S')     <> 'U'   and
       nvl(sec_rec.custom_restriction_flag, 'N') <> 'U')  then
      --
      build_contact_list(p_security_profile_id => sec_rec.security_profile_id,
			 p_view_all_contacts_flag => sec_rec.view_all_contacts_flag, -- Added for bug (6376000/4774264)
                         p_effective_date      => l_effective_date,
                         p_business_group_id   => sec_rec.business_group_id);
      --
    end if;
    --
    l_found := true;
    --
  end loop;
  --
  hr_utility.set_location(l_proc, 130);
  --
  if not l_found then
    --
    hr_utility.set_message(800, 'HR_PROFILE_NOT_FOUND');
    hr_utility.set_message_token ('PROFILE_NAME', p_security_profile_name);
    hr_utility.raise_error;
    --
  end if;
  --
  hr_utility.set_location('Leaving '||l_proc, 140);
  --
end generate_lists;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< range_cursor >--------------------------------|
-- ----------------------------------------------------------------------------
--
procedure range_cursor (pactid in 	  number,
			sqlstr out NOCOPY varchar2) is

 l_proc varchar2(100) := g_package||'range_curosr';
 l_generation_scope varchar2(20);
begin
 --hr_utility.trace_on('F','LISTGEN');
 hr_utility.set_location('Entering : '||l_proc,10);
 select pay_core_utils.get_parameter('GENERATION_SCOPE',
                                 pa1.legislative_parameters)
   into l_generation_scope
   from pay_payroll_actions pa1
  where payroll_action_id = pactid;

 /*
 ** Define the SQL statement to get the people we want to process. Provide
 ** initial filtering based on business group if appropriate.
 */
 if    l_generation_scope = 'ALL_PROFILES'
    or l_generation_scope = 'ALL_GLOBAL'
 then
   hr_utility.set_location(l_proc,20);
   sqlstr := 'select distinct per.person_id
                from per_all_people_f per
		    ,pay_payroll_actions ppa
	       where ppa.payroll_action_id = :payroll_action_id
              order by per.person_id';
--	         and ppa.effective_date between per.effective_start_date
--	                                    and per.effective_end_date
 else
   /*
   **scope is ALL_BUS_GRP
   */
   hr_utility.set_location(l_proc,30);
   sqlstr := 'select distinct per.person_id
                from per_all_people_f per
		    ,pay_payroll_actions ppa
	       where ppa.payroll_action_id = :payroll_action_id
		 and pay_core_utils.get_parameter(''BUSINESS_GROUP_ID'',
                                   ppa.legislative_parameters) =
				          per.business_group_id
              order by per.person_id';
--	         and ppa.effective_date between per.effective_start_date
--		                            and per.effective_end_date
 end if;
 hr_utility.set_location('Leaving : '||l_proc,40);
end range_cursor;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< action_creation >-----------------------------|
-- ----------------------------------------------------------------------------
--
-- Purpose : This routine creates assignment actions for a specific chunk.
--           Only one action is created for a single person ID. If a person
--           has multiple assignments then we ignore all but the first one.
--           This is so that we can process all the assignment records within
--           the same chunk(and therefore thread). Later in the process we
--           will get a list of all assignment IDs for a person and process
--           each one of them.
--
-- Notes :
--
procedure action_creation (pactid    in number,
                           stperson  in number,
			   endperson in number,
			   chunk     in number) is

 l_temp_person_id per_all_people_f.person_id%TYPE;
 l_lockingactid   pay_assignment_actions.assignment_action_id%TYPE;
 l_business_group_id number;
 l_generation_scope varchar2(20);
 l_who_to_proc   varchar2(20);

 l_proc varchar2(100) := g_package||'action_creation';

 /*
 ** Cursor to select the individual person ID's for each person in the range
 ** between stperson and endperson.
 **
 ** Use the emp/apl/cwk number columns to filter out contact only people
 ** unless they become a Emp/Apl/Cwl in the future.
 */
 cursor c_actions(pactid    number,
                  stperson  number,
		  endperson number) is
	select distinct ppf.person_id
	  from per_person_type_usages_f ppf
	      ,pay_payroll_actions   ppa
	      ,per_person_types ppt
	 where ppf.person_id between stperson and endperson
	   and ppa.payroll_action_id = pactid
	   -- and ppf.person_type_id = ppt.person_type_id --commented Bug6809753
           and ((    l_business_group_id = ppt.business_group_id
                 and l_generation_scope = 'ALL_BUS_GRP')
                    OR
		(    l_generation_scope = 'ALL_GLOBAL')
                    OR
		(    l_generation_scope = 'ALL_PROFILES'))
           and ((    l_who_to_proc in ('CURRENT','ALL')
                 /*
	         ** Current person today
	         */
                 and  ((  ppf.person_type_id = ppt.person_type_id and -- un commented Bug6809753
                          ppa.effective_date between ppf.effective_start_date
	                                           and ppf.effective_end_date
                 and ppt.system_person_type in ('EMP','APL','CWK'))
	              OR
	         /*
	         ** Future person
	         */
	        (        ppf.person_type_id = ppt.person_type_id and -- un commented Bug6809753
	                 ppa.effective_date < ppf.effective_start_date
                     and ppt.system_person_type in ('EMP','APL','CWK'))))
		 OR
		 (    l_who_to_proc in ('TERM','ALL')
                  /*
      	          ** Existed as a current person at somepoint in history
	          */
                  and  (    ppf.person_type_id = ppt.person_type_id
                        and ppa.effective_date > ppf.effective_start_date
                        and ppt.system_person_type in ('EMP','APL','CWK'))
	          /*
	          ** ...as an ex person on the effective date
	          */
                  and exists (select null
	                        from per_person_type_usages_f ppf1,
		                     per_person_types ppt1
		               where ppf1.person_id = ppf.person_id
		                 and ppa.effective_date between ppf1.effective_start_date
			                                    and ppf1.effective_end_date
	                         and ppf1.person_type_id = ppt1.person_type_id
 	                         and ppt1.business_group_id = ppt.business_group_id
		                 and ppt1.system_person_type in ('EX_EMP','EX_APL','EX_CWK'))
                  /*
	          ** ...and not a current person on effective date or in
		  ** the future.
	          **
	          **    Due to the implementation of PTU I can be both EMP and EX-APL
	          **    today.  i.e. I'm an employee who was successfully hired after
	          **    some application process. In this case the person should be
	          **    processed as a current and not an ex person.  Note the
	          **    exception for APLs who are either former EMPs/CWKs - in this
	          **    case an APL who is also term'd should be visible as both an
	          **    APL and as EX-EMP/EX-CWK therefore this cursor can see people
	          **    who are EX-EMP/EX-CWK but who are also APL
	          */
                  and not exists (select null
	                            from per_person_type_usages_f ppf2,
		                         per_person_types ppt2
		                   where ppf2.person_id = ppf.person_id
		                     and ppa.effective_date < ppf2.effective_end_date
	                             and ppf2.person_type_id = ppt2.person_type_id
		                     and ppt2.business_group_id = ppt.business_group_id
				     and ppt2.system_person_type in ('EMP','CWK'))));


 /*********************************************************************************************
 ** Bug 3464720.
 ** The cursor was used prior to the termination enhancement. For performance reason this will
 ** be used if terminated people are not selected.
 *********************************************************************************************/
 /*
 ** Cursor to select the assignment ID's for each person in the range
 ** between stperson and endperson.
 */
 cursor c_actions_prev(pactid    number,
                       stperson  number,
		       endperson number) is
	select distinct asg.assignment_id,
	                asg.person_id
	  from per_all_assignments_f asg
	      ,pay_payroll_actions   ppa
	 where asg.assignment_type in ('E','A','C')
	   and asg.person_id between stperson and endperson
           and ppa.payroll_action_id = pactid
           and (    pay_core_utils.get_parameter('BUSINESS_GROUP_ID',
                                   ppa.legislative_parameters) =
				          asg.business_group_id
                and pay_core_utils.get_parameter('GENERATION_SCOPE',
                                   ppa.legislative_parameters) =
				       'ALL_BUS_GRP'
                    OR
		    pay_core_utils.get_parameter('GENERATION_SCOPE',
                                   ppa.legislative_parameters) =
				       'ALL_GLOBAL'
                    OR
		    pay_core_utils.get_parameter('GENERATION_SCOPE',
                                   ppa.legislative_parameters) =
				       'ALL_PROFILES')
           and ((ppa.effective_date between asg.effective_start_date
                                        and asg.effective_end_date)
                or
                (asg.effective_start_date > ppa.effective_date and
                not exists (select null
                              from per_all_assignments_f paf1
                             where paf1.assignment_id = asg.assignment_id
                               and paf1.effective_start_date <
                                                      ppa.effective_date)));



begin

 l_temp_person_id := null;

 select pay_core_utils.get_parameter('BUSINESS_GROUP_ID',
                                   ppa.legislative_parameters),
        pay_core_utils.get_parameter('GENERATION_SCOPE',
                                   ppa.legislative_parameters),
        pay_core_utils.get_parameter('WHO_TO_PROCESS',
                                   ppa.legislative_parameters)
   into l_business_group_id, l_generation_scope, l_who_to_proc
   from pay_payroll_actions ppa
  where ppa.payroll_action_id  = pactid;

/*********************************
** If terminated people selected
**********************************/
 IF (l_who_to_proc in ('TERM', 'ALL'))
 THEN

 for perrec in c_actions(pactid, stperson, endperson) loop

   select pay_assignment_actions_s.nextval
     into l_lockingactid
     from dual;

   if l_temp_person_id is null then
     /*
     ** This is the first iteration so set the temp variable
     ** and insert the first action record.
     */
     l_temp_person_id := perrec.person_id;
     hr_nonrun_asact.insact(lockingactid => l_lockingactid,
                            assignid     => -1,
                            pactid       => pactid,
			    chunk        => chunk,
			    greid        => null,
			    object_id    => perrec.person_id,
			    object_type  => 'PER_ALL_PEOPLE_F');
   end if;

   if l_temp_person_id <> perrec.person_id then
     /*
     ** The person ID has changed since last time and so we need to
     ** insert an action record for this assignment
     */
     l_temp_person_id := perrec.person_id;
     hr_nonrun_asact.insact(lockingactid => l_lockingactid,
                            assignid     => -1,
                            pactid       => pactid,
			    chunk        => chunk,
			    greid        => null,
			    object_id    => perrec.person_id,
			    object_type  => 'PER_ALL_PEOPLE_F');
   end if;
 end loop;

 ELSE
 /******************************************
 ** If terminated people are not selected
 ******************************************/
 for asgrec in c_actions_prev(pactid, stperson, endperson) loop

   select pay_assignment_actions_s.nextval
     into l_lockingactid
     from dual;

   if l_temp_person_id is null then
     /*
     ** This is the first iteration so set the temp variable
     ** and insert the first action record.
     */
     l_temp_person_id := asgrec.person_id;

     -- Bug 3630537
     -- Passed person_id/PER_ALL_PEOPLE_F as object_id/object_type, procedure
     -- archive_data needs it to process a person.
     hr_nonrun_asact.insact(lockingactid => l_lockingactid,
                            assignid     => -1,
                            pactid       => pactid,
                            chunk        => chunk,
                            greid        => null,
                            object_id    => asgrec.person_id,
                            object_type  => 'PER_ALL_PEOPLE_F');
   end if;

   if l_temp_person_id <> asgrec.person_id then
     /*
     ** The person ID has changed since last time and so we need to
     ** insert an action record for this assignment
     */
     l_temp_person_id := asgrec.person_id;

     -- Bug 3630537
     -- Passed person_id/PER_ALL_PEOPLE_F as object_id/object_type, procedure
     -- archive_data needs it to process a person.
     hr_nonrun_asact.insact(lockingactid => l_lockingactid,
                            assignid     => -1,
                            pactid       => pactid,
                            chunk        => chunk,
                            greid        => null,
                            object_id    => asgrec.person_id,
                            object_type  => 'PER_ALL_PEOPLE_F');
   end if;
 end loop;

END IF;

end action_creation;

--
-- ----------------------------------------------------------------------------
-- |---------------------------< initialization >-----------------------------|
-- ----------------------------------------------------------------------------
--
-- Purpose : This process is called for each slave process to perform
--           standard initialization.
--
-- Notes :
--
procedure initialization(p_payroll_action_id in number)
is
begin
 --
 -- Set WHO column globals...
 --
 p_program_id := fnd_profile.value('CONC_PROGRAM_ID');
 p_request_id := fnd_profile.value('CONC_REQUEST_ID');
 p_program_application_id := fnd_profile.value('CONC_PROGRAM_APPLICATION_ID');
 p_update_date := trunc(sysdate);

end initialization;
--
-- ----------------------------------------------------------------------------
-- |----------------------------< archive_data >------------------------------|
-- ----------------------------------------------------------------------------
--
-- Purpose : This process is called for each assignment action and performs the
--           processing required for each individual person. We have access
--           to an assignment ID but need to determine security for a person
--           so convert the assignment ID into a person ID and then kickoff
--           the processing for that person.
--
-- Notes :
--
procedure archive_data(p_assactid       in number,
                       p_effective_date in date) is

 cursor c_person is
 select  ass.object_id
   from  pay_assignment_actions ass
  where  ass.assignment_action_id = p_assactid;

 l_person_id          per_all_people_f.person_id%TYPE;
 l_business_group_id  number;
 l_generation_scope   varchar2(20);
 l_who_to_process     varchar2(30);

begin
--hr_utility.trace_on('F','PERSLM');


 select pay_core_utils.get_parameter('BUSINESS_GROUP_ID',
                                   ppa.legislative_parameters),
        pay_core_utils.get_parameter('GENERATION_SCOPE',
                                   ppa.legislative_parameters),
	pay_core_utils.get_parameter('WHO_TO_PROCESS',
                                   ppa.legislative_parameters)
   into l_business_group_id, l_generation_scope, l_who_to_process
   from pay_payroll_actions ppa,
        pay_assignment_actions paa
  where ppa.payroll_action_id = paa.payroll_action_id
    and paa.assignment_action_id = p_assactid;

 /*
 ** Get the person ID from the assignment action.
 */
 open  c_person;
 fetch c_person into l_person_id;
 close c_person;

 pay_pyucslis_pkg.process_person(l_person_id,
                                 p_effective_date,
				 l_business_group_id,
				 l_generation_scope,
				 l_who_to_process);

end archive_data;

function chk_person_in_profile (p_person_id in        number,
                                p_security_profile_id number)
return varchar2 is

  l_dummy number;
  cursor c_per_in_profile is
      select 1
        from per_person_list
       where person_id = p_person_id
         and granted_user_id is null
         and security_profile_id = p_security_profile_id;

begin

  open c_per_in_profile;
  fetch c_per_in_profile into l_dummy;
  if c_per_in_profile%FOUND then
    close c_per_in_profile;
    return 'Y';
  else
    close c_per_in_profile;
    return 'X';
  end if;

end;
--
-- --------------------------------------------------------------------------
-- |------------------------< submit_cand_sec_opt >-------------------------|
-- --------------------------------------------------------------------------
--
procedure submit_cand_sec_opt(
          errbuf            out nocopy varchar2,
          retcode           out nocopy number,
          p_profile_option  in  varchar2
          ) is
  --
  -- Local variables
  l_proc     varchar2(72):= g_package||'submit_cand_sec_opt';
  l_prog_id  number(15)  := fnd_profile.value('CONC_PROGRAM_ID');
  l_req_id   number(15)  := fnd_profile.value('CONC_REQUEST_ID');
  l_appl_id  number(15)  := fnd_profile.value('CONC_PROGRAM_APPLICATION_ID');
  l_upd_date date        := trunc(sysdate);
  l_sec_cnt  number      := 1;
  --
  -- Exception variables
  e_irec_not_installed   exception;
  --
  -- Record Type declaration
  type sec_rec is record (
       security_profile_id   varchar2(15),
       security_profile_name varchar2(240)
       );
  --
  -- Table type declaration
  type report_rec is table of sec_rec index by binary_integer;
  --
  -- Security profile records not processed due to the
  -- unavailability of lock.
  sec_not_processed      report_rec;
  --
  -- Get all security profiles excluding the view_all profiles.
  cursor csr_security_prof is
         select pspv.*
           from per_security_profiles_v pspv
          where pspv.view_all_flag = 'N'
            and pspv.view_all_candidates_flag <> p_profile_option;
  --
begin
  --
  hr_utility.set_location('Entering '||l_proc, 10);
  --
  -- Checking that whether iRecruitment is installed.
  if nvl(fnd_profile.value('IRC_INSTALLED_FLAG'), 'N') = 'N' then
     raise e_irec_not_installed;
  end if;
  --
  hr_utility.set_location(l_proc, 20);
  -- Assume that, iRecruitment is installed, hence continuing the process.
  for r_sec in csr_security_prof loop
    --
    begin
      --
      hr_utility.set_location(l_proc, 30);
      -- Get the lock of the respective security profile record.
      per_security_profiles_pkg.lock_row(
        x_rowid                        => r_sec.row_id,
        x_security_profile_id          => r_sec.security_profile_id,
        x_business_group_id            => r_sec.business_group_id,
        x_position_id                  => r_sec.position_id,
        x_organization_id              => r_sec.organization_id,
        x_position_structure_id        => r_sec.position_structure_id,
        x_organization_structure_id    => r_sec.organization_structure_id,
        x_include_top_org_flag         => rtrim(r_sec.include_top_organization_flag),
        x_include_top_position_flag    => rtrim(r_sec.include_top_position_flag),
        x_security_profile_name        => rtrim(r_sec.security_profile_name),
        x_view_all_applicants_flag     => rtrim(r_sec.view_all_applicants_flag),
        x_view_all_employees_flag      => rtrim(r_sec.view_all_employees_flag),
        x_view_all_flag                => rtrim(r_sec.view_all_flag),
        x_view_all_organizations_flag  => rtrim(r_sec.view_all_organizations_flag),
        x_view_all_payrolls_flag       => rtrim(r_sec.view_all_payrolls_flag),
        x_view_all_positions_flag      => rtrim(r_sec.view_all_positions_flag),
        x_view_all_cwk_flag            => rtrim(r_sec.view_all_cwk_flag),
        x_view_all_contacts_flag       => rtrim(r_sec.view_all_contacts_flag),
        x_view_all_candidates_flag     => rtrim(r_sec.view_all_candidates_flag),
        x_include_exclude_payroll_flag => rtrim(r_sec.include_exclude_payroll_flag),
        x_reporting_oracle_username    => rtrim(r_sec.reporting_oracle_username),
        x_allow_granted_users_flag     => rtrim(r_sec.allow_granted_users_flag),
        x_restrict_by_supervisor_flag  => rtrim(r_sec.restrict_by_supervisor_flag),
        x_supervisor_levels            => r_sec.supervisor_levels,
        x_exclude_secondary_asgs_flag  => rtrim(r_sec.exclude_secondary_asgs_flag),
        x_exclude_person_flag          => rtrim(r_sec.exclude_person_flag),
        x_named_person_id              => r_sec.named_person_id,
        x_custom_restriction_flag      => rtrim(r_sec.custom_restriction_flag),
        x_restriction_text             => rtrim(r_sec.restriction_text),
        x_exclude_business_groups_flag => rtrim(r_sec.exclude_business_groups_flag),
        x_org_security_mode            => rtrim(r_sec.org_security_mode),
        x_restrict_on_individual_asg   => rtrim(r_sec.restrict_on_individual_asg),
        x_top_organization_method      => rtrim(r_sec.top_organization_method),
        x_top_position_method          => rtrim(r_sec.top_position_method)
        );
      --
      hr_utility.set_location(l_proc, 40);
      -- Sucessfully locked the row, now updating the
      -- view_all_candidates_flag with the given value through parameter
      -- p_profile_option
      per_security_profiles_pkg.update_row(
        x_rowid                        => r_sec.row_id,
        x_security_profile_id          => r_sec.security_profile_id,
        x_business_group_id            => r_sec.business_group_id,
        x_position_id                  => r_sec.position_id,
        x_organization_id              => r_sec.organization_id,
        x_position_structure_id        => r_sec.position_structure_id,
        x_organization_structure_id    => r_sec.organization_structure_id,
        x_include_top_org_flag         => r_sec.include_top_organization_flag,
        x_include_top_position_flag    => r_sec.include_top_position_flag,
        x_security_profile_name        => r_sec.security_profile_name,
        x_view_all_applicants_flag     => r_sec.view_all_applicants_flag,
        x_view_all_employees_flag      => r_sec.view_all_employees_flag,
        x_view_all_flag                => r_sec.view_all_flag,
        x_view_all_organizations_flag  => r_sec.view_all_organizations_flag,
        x_view_all_payrolls_flag       => r_sec.view_all_payrolls_flag,
        x_view_all_positions_flag      => r_sec.view_all_positions_flag,
        x_view_all_cwk_flag            => r_sec.view_all_cwk_flag,
        x_view_all_contacts_flag       => r_sec.view_all_contacts_flag,
        x_view_all_candidates_flag     => p_profile_option,
        x_include_exclude_payroll_flag => r_sec.include_exclude_payroll_flag,
        x_reporting_oracle_username    => r_sec.reporting_oracle_username,
        x_allow_granted_users_flag     => r_sec.allow_granted_users_flag,
        x_restrict_by_supervisor_flag  => r_sec.restrict_by_supervisor_flag,
        x_supervisor_levels            => r_sec.supervisor_levels,
        x_exclude_secondary_asgs_flag  => r_sec.exclude_secondary_asgs_flag,
        x_exclude_person_flag          => r_sec.exclude_person_flag,
        x_named_person_id              => r_sec.named_person_id,
        x_custom_restriction_flag      => r_sec.custom_restriction_flag,
        x_restriction_text             => r_sec.restriction_text,
        x_exclude_business_groups_flag => r_sec.exclude_business_groups_flag,
        x_org_security_mode            => r_sec.org_security_mode,
        x_restrict_on_individual_asg   => r_sec.restrict_on_individual_asg,
        x_top_organization_method      => r_sec.top_organization_method,
        x_top_position_method          => r_sec.top_position_method,
        x_request_id                   => l_req_id,
        x_program_application_id       => l_appl_id,
        x_program_id                   => l_prog_id,
        x_program_update_date          => l_upd_date
        );
      --
      hr_utility.set_location('Sec Prof Id:'||r_sec.security_profile_id, 50);
      hr_utility.set_location('Sec Name:'||r_sec.security_profile_name, 55);
      hr_utility.set_location('BG Id:'||r_sec.business_group_id, 60);
      --
    exception
      --
      -- Could not obtain the lock.
      when others then
        --
        -- Keeping the failed record details into a PL/SQL cache. This will
        -- be shown to customer in a report format in concurrent log after
        -- the warning (translated) message.
        sec_not_processed(l_sec_cnt).security_profile_id
                := r_sec.security_profile_id;
        sec_not_processed(l_sec_cnt).security_profile_name
                := r_sec.security_profile_name;
        l_sec_cnt := l_sec_cnt + 1;
        --
        -- Keeping the information traced.
        hr_utility.trace('Cannot process security profile :');
        hr_utility.trace('Sec Prof Id: '||r_sec.security_profile_id);
        hr_utility.trace('Sec Name: '||r_sec.security_profile_name);
        hr_utility.trace('BG Id: '||r_sec.business_group_id);
        hr_utility.trace('BG Name: '||r_sec.business_group_name);
        --
      --
    end;
    --
  end loop;
  --
  hr_utility.set_location(l_proc, 70);
  -- Needs to format the report of failed records (if any) after the
  -- warning message.
  if sec_not_processed.count > 0 then
    --
    hr_utility.set_location(l_proc, 80);
    -- Setting the message to get the translated message text
    fnd_message.set_name('PER', 'PER_449705_SEC_UPDATE_FAILED');
    --
    errbuf  := null;
    errbuf  := nvl(fnd_message.get, 'PER_449705_SEC_UPDATE_FAILED');
    retcode := 1; -- Concurrent process finished with a warning.
    --
    -- Looping through the PL/SQL cache and writing to the concurrent
    -- log file.
    for i in sec_not_processed.first..sec_not_processed.last loop
      --
      fnd_file.put_line(fnd_file.log,
               sec_not_processed(i).security_profile_name||'('||
               sec_not_processed(i).security_profile_id||')');
      --
    end loop;
    --
  end if;
  --
  hr_utility.set_location('Leaving '||l_proc, 99);
  --
exception
  --
  when e_irec_not_installed then
    --
    -- Setting the message to get the translated message text
    fnd_message.set_name('PER', 'PER_449706_IRC_NOT_INSTALLED');
    --
    errbuf  := null;
    errbuf  := nvl(fnd_message.get, 'PER_449706_IRC_NOT_INSTALLED');
    retcode := 1; -- Concurrent process finished with a warning.
  --
  hr_utility.set_location('Leaving '||l_proc, 99);
  --
end submit_cand_sec_opt;
--
END pay_pyucslis_pkg;

/

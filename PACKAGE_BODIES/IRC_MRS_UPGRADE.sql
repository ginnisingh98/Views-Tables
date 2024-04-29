--------------------------------------------------------
--  DDL for Package Body IRC_MRS_UPGRADE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_MRS_UPGRADE" AS
/* $Header: irmrsupg.pkb 120.0 2005/07/26 15:14:58 mbocutt noship $ */

-- ----------------------------------------------------------------------------
-- |--------------------------< migrateVacancyRecSite >-----------------------|
-- ----------------------------------------------------------------------------
procedure migrateVacancyRecSite(
   p_process_ctrl   IN            varchar2,
   p_start_pkid     IN            number,
   p_end_pkid       IN            number,
   p_rows_processed    OUT nocopy number)
is
--
  l_internal_site_id irc_all_recruiting_sites.recruiting_site_id%type;
  l_external_site_id irc_all_recruiting_sites.recruiting_site_id%type;
  l_api_ovn per_recruitment_activities.object_version_number%type;
  l_int_ext_rec_id per_recruitment_activities.recruitment_activity_id%type;
  l_third_rec_id per_recruitment_activities.recruitment_activity_id%type;
  l_rec_activity_for_id per_recruitment_activity_for.recruitment_activity_for_id%type;
  l_raa_id number;
  l_vac_name per_all_vacancies.name%type;
  l_ovn number;
  l_rows_processed number := 0;
  l_unique_name per_recruitment_activities.name%type;
  l_temp_name varchar2(60);
  l_dummy number;
--
-- This cursor loops over all recruitment activities for iRecruitment vacancies
-- which still have an internal or external flag set
--
  cursor csr_rec_activity is
    select pra.recruitment_activity_id recruitment_activity_id
          ,pra.internal_posting internal_posting
          ,pra.external_posting external_posting
          ,pra.business_group_id business_group_id
          ,pra.date_start date_start
          ,pra.name name
          ,pra.recruiting_site_id recruiting_site_id
          ,pra.object_version_number object_version_number
          ,pra.date_end date_end
          ,pra.posting_content_id posting_content_id
      from per_recruitment_activities pra
          ,irc_posting_contents ipc
     where ipc.posting_content_id = pra.posting_content_id
       and ipc.posting_content_id between p_start_pkid  and p_end_pkid
       and (pra.internal_posting is not null or pra.external_posting is not null);
--
-- This cursor gets all vacancies associated with a recruitment activity
--
  cursor csr_rec_activity_for(p_recruitment_activity_id number) is
    select pfr.business_group_id business_group_id
          ,pfr.vacancy_id vacancy_id
      from per_recruitment_activity_for pfr
     where pfr.recruitment_activity_id = p_recruitment_activity_id;
--
-- This cursor gets all assignments in which a person has applied for a recruitment activity
-- and looks to see is the person is an emp-apl
--
  cursor csr_asg_rec_activity(p_recruitment_activity_id number) is
    select asg.assignment_id assignment_id
          ,asg.object_version_number object_version_number
          ,ppf.current_employee_flag current_employee_flag
      from per_all_assignments_f asg
          ,per_all_people_f ppf
     where asg.person_id = ppf.person_id
       and trunc(sysdate) between asg.effective_start_date and asg.effective_end_date
       and trunc(sysdate) between ppf.effective_start_date and ppf.effective_end_date
       and asg.recruitment_activity_id = p_recruitment_activity_id;
--
-- This cursor looks for the internal recruiting_site_id
--
   cursor csr_internal is
    select irs.recruiting_site_id recruiting_site_id
      from irc_all_recruiting_sites irs
     where irs.internal = 'Y'
       and irs.external = 'N';
--
-- This cursor looks for the external recruiting_site_id
--
   cursor csr_external is
    select irs.recruiting_site_id recruiting_site_id
      from irc_all_recruiting_sites irs
     where irs.external = 'Y'
       and irs.internal = 'N';
--
   cursor csr_raa_id is
     select per_recruitment_activities_s.nextval
       from sys.dual;
--
 cursor csr_site_exists(p_posting_content_id number,p_recruiting_site_id number) is
   select 1
     from per_recruitment_activities pra
    where posting_content_id=p_posting_content_id
      and recruiting_site_id=p_recruiting_site_id;
--
cursor dup_ints is
  select raa.recruitment_activity_id
    from per_recruitment_activities raa
        ,per_recruitment_activity_for raf
   where raa.posting_content_id is not null
     and raa.internal_posting='Y'
     and raa.recruitment_activity_id=raf.recruitment_activity_id
     and exists (select 1
                   from per_recruitment_activity_for raf2
                       ,per_recruitment_activities raa2
                  where raf2.vacancy_id=raf.vacancy_id
                    and raf2.recruitment_activity_id=raa2.recruitment_activity_id
                    and raa2.internal_posting='Y'
                    and raf2.recruitment_activity_id <> raf.recruitment_activity_id
                    and raf2.creation_date < raf.creation_date)
  order by 1;
--
cursor dup_exts is
  select raa.recruitment_activity_id
    from per_recruitment_activities raa
        ,per_recruitment_activity_for raf
   where raa.posting_content_id is not null
     and raa.external_posting='Y'
     and raa.recruitment_activity_id=raf.recruitment_activity_id
     and exists (select 1
                   from per_recruitment_activity_for raf2
                       ,per_recruitment_activities raa2
                  where raf2.vacancy_id=raf.vacancy_id
                    and raf2.recruitment_activity_id=raa2.recruitment_activity_id
                    and raa2.external_posting='Y'
                    and raf2.recruitment_activity_id <> raf.recruitment_activity_id
                    and raf2.creation_date < raf.creation_date)
  order by 1;
--
begin
-- Get the internal and external sites IDs
--
  open csr_internal;
  fetch csr_internal into l_internal_site_id;
  close csr_internal;
--
  open csr_external;
  fetch csr_external into l_external_site_id;
  close csr_external;
--
  if (l_internal_site_id is not null and l_external_site_id is not null) then
--
-- Check for recruitment modifications
--
  for int_recs in dup_ints loop
    update per_recruitment_activities
       set internal_posting=null
          ,external_posting=null
     where recruitment_activity_id = int_recs.recruitment_activity_id;
  end loop;
--
  for ext_recs in dup_exts loop
    update per_recruitment_activities
       set internal_posting=null
          ,external_posting=null
     where recruitment_activity_id = ext_recs.recruitment_activity_id;
  end loop;
--
-- Loop over all iRecruitment recruitment activities
--
  for csr_rec_activity_rec in csr_rec_activity
  loop
    if csr_rec_activity_rec.internal_posting = 'Y'
    then
--
-- If the recruitment activity is currently for internal, we know it has not
-- yet been migrated, so update it to point to the internal site
-- clear the existing data so we know not to process the row in future
-- and set the external site id
--
      update per_recruitment_activities
         set internal_posting = null
            ,external_posting = null
            ,recruiting_site_id = l_internal_site_id
       where recruitment_activity_id = csr_rec_activity_rec.recruitment_activity_id;
--
--
-- If this is an external posting too, then create a new external posting
      if csr_rec_activity_rec.external_posting = 'Y'
      then
--
-- Check to see if the external site already exists in case we migrated it
-- without clearing the data already;
--
        open csr_site_exists(csr_rec_activity_rec.posting_content_id,l_external_site_id);
        fetch csr_site_exists into l_dummy;
        if csr_site_exists%found then
          close csr_site_exists;
        else
          close csr_site_exists;
          open csr_raa_id;
          fetch csr_raa_id into l_raa_id;
          close csr_raa_id;
          l_vac_name := csr_rec_activity_rec.name;
          l_temp_name := l_vac_name||l_raa_id;
          if (lengthb(l_temp_name) > 30) then
            l_vac_name := substrb(l_temp_name,1,30 - lengthb(to_char(l_raa_id)))
            ||l_raa_id;
          else
            l_vac_name := l_temp_name;
          end if;
          per_recruitment_activity_api.create_recruitment_activity
          (
           p_business_group_id            => csr_rec_activity_rec.business_group_id
          ,p_date_start                   => csr_rec_activity_rec.date_start
          ,p_name                         => l_vac_name
          ,p_date_end                     => csr_rec_activity_rec.date_end
          ,p_posting_content_id           => csr_rec_activity_rec.posting_content_id
          ,p_recruiting_site_id           => l_external_site_id
          ,p_recruitment_activity_id      => l_int_ext_rec_id
          ,p_object_version_number        => l_ovn
          );
--
-- add recruitment_activity_for records for the new recruitment activity
--
          for csr_rec_activity_for_rec in csr_rec_activity_for(csr_rec_activity_rec.recruitment_activity_id)
          loop
            per_rec_activity_for_api.create_rec_activity_for
            (
             p_business_group_id     => csr_rec_activity_for_rec.business_group_id
            ,p_vacancy_id            => csr_rec_activity_for_rec.vacancy_id
            ,p_rec_activity_id       => l_int_ext_rec_id
            ,p_rec_activity_for_id   => l_rec_activity_for_id
            ,p_object_version_number => l_ovn
            );
          end loop;
--
-- update any non-employee assignments which were pointing to this recruitment activity so that
-- they point to the new external one
--
          update per_all_assignments_f asg
             set recruitment_activity_id = l_int_ext_rec_id
           where recruitment_activity_id = csr_rec_activity_rec.recruitment_activity_id
             and not exists(select 1
                               from per_all_people_f per
                              where per.person_id=asg.person_id
                                and asg.effective_start_date
                                between per.effective_start_date and per.effective_end_date
                                and per.current_employee_flag <> 'Y'
                            );
        end if; -- end of csr_site_exists
--
      end if;  -- end of external_posting
--
-- If this has an third party site too, then add a recruitment activity for that
--
      if csr_rec_activity_rec.recruiting_site_id is not null
      then
--
-- Check to see if the third party site already exists in case we migrated it
-- without clearing the data already;
--
        open csr_site_exists(csr_rec_activity_rec.posting_content_id,csr_rec_activity_rec.recruiting_site_id);
        fetch csr_site_exists into l_dummy;
        if csr_site_exists%found then
          close csr_site_exists;
        else
           close csr_site_exists;
           open csr_raa_id;
           fetch csr_raa_id into l_raa_id;
           close csr_raa_id;
           l_vac_name := csr_rec_activity_rec.name;
           l_temp_name := l_vac_name||l_raa_id;
           if (lengthb(l_temp_name) > 30) then
             l_vac_name := substrb(l_temp_name,1,30 - lengthb(to_char(l_raa_id)))
             ||l_raa_id;
           else
             l_vac_name := l_temp_name;
           end if;
           per_recruitment_activity_api.create_recruitment_activity
           (
            p_business_group_id            => csr_rec_activity_rec.business_group_id
           ,p_date_start                   => csr_rec_activity_rec.date_start
           ,p_name                         => l_vac_name
           ,p_date_end                     => csr_rec_activity_rec.date_end
           ,p_posting_content_id           => csr_rec_activity_rec.posting_content_id
           ,p_recruiting_site_id           => csr_rec_activity_rec.recruiting_site_id
           ,p_recruitment_activity_id      => l_third_rec_id
           ,p_object_version_number        => l_ovn
           );
--
-- add recruitment_activity_for records for the new recruitment activity
--
           for csr_rec_activity_for_rec in csr_rec_activity_for(csr_rec_activity_rec.recruitment_activity_id)
           loop
             per_rec_activity_for_api.create_rec_activity_for
             (
              p_business_group_id     => csr_rec_activity_for_rec.business_group_id
             ,p_vacancy_id            => csr_rec_activity_for_rec.vacancy_id
             ,p_rec_activity_id       => l_third_rec_id
             ,p_rec_activity_for_id   => l_rec_activity_for_id
             ,p_object_version_number => l_ovn
             );
           end loop;
      end if;  -- end of csr_site_exists
--
    end if;  -- end of recruiting_site_id
--
    elsif csr_rec_activity_rec.external_posting = 'Y'
    then
--
-- this is not an internal posting, but it is an external posting, so turn the
-- existing recruitment activity in to the external posting
-- clear the existing data so we know not to process the row again
--
      update per_recruitment_activities
         set internal_posting=null
            ,external_posting=null
            ,recruiting_site_id=l_external_site_id
       where recruitment_activity_id = csr_rec_activity_rec.recruitment_activity_id;

-- if there is a third party recruiting site, then add a line for that
--
      if csr_rec_activity_rec.recruiting_site_id is not null
      then
--
-- Check to see if the third party site already exists in case we migrated it
-- without clearing the data already;
--
        open csr_site_exists(csr_rec_activity_rec.posting_content_id,csr_rec_activity_rec.recruiting_site_id);
        fetch csr_site_exists into l_dummy;
        if csr_site_exists%found
        then
          close csr_site_exists;
        else
          close csr_site_exists;
          open csr_raa_id;
          fetch csr_raa_id into l_raa_id;
          close csr_raa_id;
          l_vac_name := csr_rec_activity_rec.name;
          l_temp_name := l_vac_name||l_raa_id;
          if (lengthb(l_temp_name) > 30) then
            l_vac_name := substrb(l_temp_name,1,30 - lengthb(to_char(l_raa_id)))
            ||l_raa_id;
          else
            l_vac_name := l_temp_name;
          end if;
          per_recruitment_activity_api.create_recruitment_activity
          (
           p_business_group_id            => csr_rec_activity_rec.business_group_id
          ,p_date_start                   => csr_rec_activity_rec.date_start
          ,p_name                         => l_vac_name
          ,p_date_end                     => csr_rec_activity_rec.date_end
          ,p_posting_content_id           => csr_rec_activity_rec.posting_content_id
          ,p_recruiting_site_id           => csr_rec_activity_rec.recruiting_site_id
          ,p_recruitment_activity_id      => l_third_rec_id
          ,p_object_version_number        => l_ovn
          );
--
-- add recruitment_activity_for records for the new recruitment activity
--
        for csr_rec_activity_for_rec in csr_rec_activity_for(csr_rec_activity_rec.recruitment_activity_id)
        loop
          per_rec_activity_for_api.create_rec_activity_for
          (
           p_business_group_id     => csr_rec_activity_for_rec.business_group_id
          ,p_vacancy_id            => csr_rec_activity_for_rec.vacancy_id
          ,p_rec_activity_id       => l_third_rec_id
          ,p_rec_activity_for_id   => l_rec_activity_for_id
          ,p_object_version_number => l_ovn
          );
        end loop;
      end if;  -- end of csr_site_exists
--
    end if; -- end of recruiting_site_id
--
    elsif csr_rec_activity_rec.recruiting_site_id is not null then
--
-- this is not for internal or external, only for 3rd party, so just clear the flag data
--
      update per_recruitment_activities
         set internal_posting=null
            ,external_posting=null
       where recruitment_activity_id=csr_rec_activity_rec.recruitment_activity_id;
    end if; -- end of recruiting_site_id
--
-- clean the variables for the next pass
--
    l_int_ext_rec_id := null;
    l_third_rec_id := null;
    l_rows_processed := l_rows_processed + 1;
--
  end loop;
    p_rows_processed := l_rows_processed;
  end if;
end migrateVacancyRecSite;
--
-- ----------------------------------------------------------------------------
-- |--------------------------< migrateVacancyRecSiteTL >---------------------|
-- ----------------------------------------------------------------------------
procedure migrateVacancyRecSiteTL(
   p_process_ctrl   IN            varchar2,
   p_start_pkid     IN            number,
   p_end_pkid       IN            number,
   p_rows_processed    OUT nocopy number)
is
--
  l_rows_processed number := 0;
  --
  cursor csr_rec_sites is
  select irs.recruiting_site_id recruiting_site_id
        ,irs.site_name site_name
        ,dbms_lob.substr(irs.posting_url) posting_url
        ,dbms_lob.substr(irs.redirection_url) redirection_url
    from irc_all_recruiting_sites irs
   where not exists (select null
                     from irc_all_recruiting_sites_tl itl
                    where itl.recruiting_site_id = irs.recruiting_site_id)
   and irs.recruiting_site_id between p_start_pkid  and p_end_pkid;
  --
  cursor csr_lang is
  select language_code from fnd_languages
  where installed_flag in ('I', 'B');
 --
begin
  hr_general.g_data_migrator_mode :='Y';
  for csr_rec_sites_rec in csr_rec_sites
  loop
    for csr_lang_rec in csr_lang
    loop
      --
      irc_irt_ins.ins_tl
      (p_recruiting_site_id       => csr_rec_sites_rec.recruiting_site_id
      ,p_language_code            => csr_lang_rec.language_code
      ,p_site_name                => csr_rec_sites_rec.site_name
      ,p_redirection_url          => csr_rec_sites_rec.redirection_url
      ,p_posting_url              => csr_rec_sites_rec.posting_url
      );
    end loop;
    l_rows_processed := l_rows_processed + 1;
  end loop;
  --
  update irc_all_recruiting_sites irs
  set internal_name=upper(site_name)
  where internal_name is null
  and irs.recruiting_site_id between p_start_pkid  and p_end_pkid;
  --
  p_rows_processed := l_rows_processed;
  --
end migrateVacancyRecSiteTL;
--
end irc_mrs_upgrade;

/

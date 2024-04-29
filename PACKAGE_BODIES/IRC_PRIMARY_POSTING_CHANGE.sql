--------------------------------------------------------
--  DDL for Package Body IRC_PRIMARY_POSTING_CHANGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_PRIMARY_POSTING_CHANGE" AS
/* $Header: irppiupg.pkb 120.5 2006/10/18 01:48:34 gjaggava noship $*/

-- ----------------------------------------------------------------------------
-- |--------------------------< update_primary_posting_data >-----------------|
-- ----------------------------------------------------------------------------
procedure update_primary_posting_data(
   p_process_ctrl   IN            varchar2,
   p_start_pkid     IN            number,
   p_end_pkid       IN            number,
   p_rows_processed    OUT nocopy number)
is
--
-- This cursor gets all of the vacancy records to be processed
--
  cursor get_vacs is
  select per_vac.vacancy_id from per_all_vacancies per_vac
  where per_vac.vacancy_id between p_start_pkid and p_end_pkid
  and per_vac.primary_posting_id is null;
--
-- this cursor gets all of the dummy recruitment activity records
--
  cursor get_dummy_posting(p_vacancy_id number) is
  select per_rac.posting_content_id
  , per_rac.recruitment_activity_id
  , per_for.recruitment_activity_for_id
  from  per_recruitment_activities per_rac
      , per_recruitment_activity_for per_for
  where per_for.vacancy_id=p_vacancy_id
  and per_for.recruitment_activity_id = per_rac.recruitment_activity_id
  and per_rac.posting_content_id is not null
  and per_rac.recruiting_site_id is null
  and not exists (select null
     from  per_recruitment_activity_for per_for2
     where per_for2.recruitment_activity_id = per_for.recruitment_activity_id
     and per_for2.vacancy_id <> per_for.vacancy_id)
  order by per_rac.posting_content_id;
--
  l_rows_processed number := 0;
--
begin
  for vac_rec in get_vacs loop
    for posting_rec in get_dummy_posting(vac_rec.vacancy_id) loop
      update per_all_vacancies
      set primary_posting_id=posting_rec.posting_content_id
      where vacancy_id=vac_rec.vacancy_id;

      update per_all_assignments_f
      set recruitment_activity_id = null
      where recruitment_activity_id=posting_rec.recruitment_activity_id;

      delete from per_recruitment_activity_for
      where recruitment_activity_for_id=posting_rec.recruitment_activity_for_id;
      delete from per_recruitment_activities
      where recruitment_activity_id=posting_rec.recruitment_activity_id;

    end loop;
    l_rows_processed := l_rows_processed + 1;

  end loop;

  p_rows_processed := l_rows_processed;
end update_primary_posting_data;
--
end irc_primary_posting_change;

/

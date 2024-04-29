--------------------------------------------------------
--  DDL for Package Body IRC_MDS_MIGRATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_MDS_MIGRATION" AS
/* $Header: irmdsmig.pkb 120.0 2005/07/26 15:14:47 mbocutt noship $ */

-- ----------------------------------------------------------------------------
-- |--------------------------< migrateJobSearchData >------------------------|
-- ----------------------------------------------------------------------------
procedure migrateJobSearchData(
   p_process_ctrl   IN            varchar2,
   p_start_pkid     IN            number,
   p_end_pkid       IN            number,
   p_rows_processed    OUT nocopy number)
is

  cursor csr_ak_customizations is
    select SEARCH_CRITERIA_ID, name
    from ak_customizations_tl ac, irc_search_criteria isc
    where region_code = 'IRC_APPL_JOB_SEARCH_TBL'
    and region_application_id = 800
    and ac.customization_code = isc.search_name
    and isc.SEARCH_CRITERIA_ID between p_start_pkid
                               and p_end_pkid;

  l_current_name            VARCHAR2(80);
  l_current_id              NUMBER(15);
  l_rows_processed number := 0;

begin

  /*
  ** For each customization record which is stored in IRC_SEARCH_CRITERIA
  ** update the search_name.
  */
  for c_cust in csr_ak_customizations loop

    /*
    ** Set language for iteration....
    */
    l_current_id := c_cust.SEARCH_CRITERIA_ID;
    l_current_name := c_cust.name;

    /*
    ** Update the Search Criteria
    */
        update irc_search_criteria
        set SEARCH_NAME = l_current_name
        where SEARCH_CRITERIA_ID = l_current_id;

    l_rows_processed := l_rows_processed + SQL%ROWCOUNT;

  end loop;

  p_rows_processed := l_rows_processed;

Exception
  --
  When Others Then
    --
    raise;
end;



-- ----------------------------------------------------------------------------
-- |--------------------------< createworkPrefsData >------------------------|
-- ----------------------------------------------------------------------------
procedure createworkPrefsData(
   p_process_ctrl   IN            varchar2,
   p_start_pkid     IN            number,
   p_end_pkid       IN            number,
   p_rows_processed    OUT nocopy number)
is
--
  cursor csr_irc_notifications is
    select inp.PERSON_ID inp_person_id,
    pad.town_or_city city,
    pad.address_type addtype
    from irc_notification_preferences inp,
    per_addresses pad
    where
    inp.person_id = pad.person_id(+)
    and pad.ADDRESS_TYPE(+) ='REC'
    and inp.person_id between p_start_pkid
                               and p_end_pkid
    order by inp_person_id,addtype ;
--
 cursor csr_work_choices(p_person_id number) is
    select null
    from irc_search_criteria isc
    where isc.object_id = p_person_id
    and isc.object_type in ('WORK','WPREF');
--
  l_rows_processed number       := 0;
  l_search_criteria_id number   := null;
  l_ovn_number number           := null;
  l_dummy varchar2(1);
--
begin
--
  /*
  ** For each personid record in IRC_NOTIFICATION_PREFERENCES ,
  ** insert a record in IRC_SEARCH_CRITERIA.
  */
--
  for c_notifs in csr_irc_notifications loop
    /*
    **The cursor will return the personid.If there are two addresttype for person
    ** then first the REC addresstype will be selected and then the null
    ** addresstype will be selected in cursor.This is achieved by the order by
    ** clause.So only the first record will be inserted and second record is
    ** restricted.
    */
    open csr_work_choices(c_notifs.inp_person_id);
    fetch csr_work_choices into l_dummy;
    if csr_work_choices%notfound then
      close csr_work_choices;
     /*
      ** insert the work preferences in Search Criteria
      */
      irc_search_criteria_api.create_work_choices (
      p_effective_date                    => trunc(sysdate)
      ,p_person_id                         => c_notifs.inp_person_id
      ,p_employee                         => 'Y'
      ,p_contractor                       => 'Y'
      ,p_employment_category              => 'FULLTIME'
      ,p_match_competence                 => 'Y'
      ,p_match_qualification              => 'Y'
      ,p_salary_period                    => 'ANNUAL'
      ,p_work_at_home                     => null
      ,p_location                         => c_notifs.city
      ,p_object_version_number            => l_ovn_number
      ,p_search_criteria_id               => l_search_criteria_id
      );
    else
      close csr_work_choices;
   end if;
--
   l_rows_processed := l_rows_processed + 1;
  end loop;
  p_rows_processed := l_rows_processed;
Exception
  --
  When Others Then
    --
    raise;
end;
end irc_mds_migration;

/

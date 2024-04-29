--------------------------------------------------------
--  DDL for Package Body IRC_CMP_UPGRADE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_CMP_UPGRADE" AS
/* $Header: ircmpupg.pkb 120.1 2007/12/22 14:38:40 gaukumar noship $ */

-- ----------------------------------------------------------------------------
-- |--------------------------< migrateVacCommProps >---------------------|
-- ----------------------------------------------------------------------------
procedure migrateVacCommProps(
   p_process_ctrl   IN            varchar2,
   p_start_pkid     IN            number,
   p_end_pkid       IN            number,
   p_rows_processed    OUT nocopy number)
is
--
  l_rows_processed number := 0;
  --
  cursor csr_vacancy is
  select pav.vacancy_id
    from per_all_vacancies pav
   where not exists (select null
                     from irc_comm_properties icp
                     where icp.object_type = 'VACANCY'
              and  icp.object_id = pav.vacancy_id
             )
   and pav.vacancy_id between p_start_pkid  and p_end_pkid;
 --
 l_communication_property_id    number := 0;
 l_object_version_number        number := 0;
 --
begin

  for csr_vacancy_rec in csr_vacancy
  loop
      --
      irc_cmp_ins.ins
      (
       p_effective_date            =>  sysdate
      ,p_object_type               => 'VACANCY'
      ,p_object_id                 => csr_vacancy_rec.vacancy_id
      ,p_default_comm_status       => 'CLOSED'
      ,p_allow_attachment_flag     => 'NONE'
      ,p_auto_notification_flag    => 'N'
      ,p_allow_add_recipients      => 'INT'
      ,p_default_moderator         => 'REC_N_HRNG_MGR'
      ,p_communication_property_id => l_communication_property_id
      ,p_object_version_number     => l_object_version_number
     );

      l_rows_processed := l_rows_processed + 1;
  end loop;
  --
  p_rows_processed := l_rows_processed;
  --
end migrateVacCommProps;
--
end irc_cmp_upgrade;

/

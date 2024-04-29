--------------------------------------------------------
--  DDL for Package Body IRC_CREATE_NOTIFICATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IRC_CREATE_NOTIFICATION_PKG" as
/* $Header: ircnrpkg.pkb 120.0 2006/06/22 07:43:04 narvenka noship $ */

-- ----------------------------------------------------------------------------
-- |-------------------------< create_notification >--------------------------|
-- ----------------------------------------------------------------------------
procedure create_notification (errbuf  out nocopy varchar2
                              ,retcode out nocopy number
                              ,p_process_number in varchar2
                              ,p_max_number_proc in varchar2
                              ,p_table_owner in varchar2
                              ,p_batch_size in varchar2
                              )is
--
l_worker_id            number := to_number(nvl(p_process_number,'1'));
l_num_workers          number := to_number(p_max_number_proc);
l_batch_size           number := to_number(p_batch_size);
l_any_rows_to_process  boolean;
l_rows_processed       number := 0;

l_unique_upd_name      varchar2(30);
l_update_name          varchar2(30) := 'IRCRUPCREATENOTIFCP';
l_table_name           varchar2(30);
l_table_owner          varchar2(30);
l_status               varchar2(255);
l_industry             varchar2(255);
l_dummy                boolean;
l_party_id             per_all_people_f.party_id%TYPE := null;
--
--
type person_id_t is table of per_all_assignments_f.person_id%type index by binary_integer;
l_person_ids person_id_t;
--
type party_id_t is table of per_all_people_f.party_id%TYPE index by binary_integer;
l_party_ids party_id_t;
--
type l_rowid_type is table of rowid index by binary_integer;
l_rowid                l_rowid_type;
l_start_rowid          rowid;
l_end_rowid            rowid;
--

-- **************************************************
-- *** Use ROWID hint to ensure ROWID access path ***
-- **************************************************

--
-- This cursor picks all the applicants who do not have a notification
-- preferences record.
--
 cursor csr_get_appl_with_no_notif(start_rowid rowid, end_rowid rowid) is
SELECT /*+ ROWID(ppf1) */
        ppf1.person_id person_id
       ,ppf1.rowid
       ,ppf1.party_id party_id
   FROM per_all_people_f ppf1
  WHERE trunc(sysdate) between ppf1.effective_start_date and ppf1.effective_end_date
    AND ppf1.rowid BETWEEN start_rowid and end_rowid
    AND person_id = (select min(person_id)
                       from per_all_assignments_f paaf
                      where paaf.assignment_type = 'A'
                        and trunc(sysdate) between paaf.effective_start_date and paaf.effective_end_date
                        and person_id in (select ppf.person_id
                                           from per_all_people_f ppf
                                          where ppf.party_id = ppf1.party_id
                                            and trunc(sysdate) between ppf.effective_start_date
                                                                   and ppf.effective_end_date
                                          AND NOT EXISTS ( SELECT /*+ no_unnest */ 1
                                                             FROM irc_notification_preferences inp
                                                                 ,per_all_people_f ppf2
                                                            WHERE ppf.party_id = ppf2.party_id
                                                              AND ppf2.person_id = inp.person_id
                                                              AND trunc(sysdate) between ppf2.effective_start_date
                                                                                     and ppf2.effective_end_date
                                                         )
                                         )
                    );
--

--
begin
--
  l_table_name := 'PER_ALL_PEOPLE_F';
  l_dummy:=fnd_installation.get_app_info(
              application_short_name=>'PER'
              ,status                =>l_status
              ,industry              =>l_industry
              ,oracle_schema         =>l_table_owner);
--
  if ((l_dummy = FALSE)
      OR
     (l_table_owner is null))
  then
     raise_application_error(-20001,'Cannot get schema name for product : '|| 'PER');
  end if;
--
  ad_parallel_updates_pkg.initialize_rowid_range(
            ad_parallel_updates_pkg.ROWID_RANGE,
            l_table_owner,
            l_table_name,
            l_update_name,
            l_worker_id,
            l_num_workers,
            l_batch_size,
            0);

  ad_parallel_updates_pkg.get_rowid_range(
           l_start_rowid,
           l_end_rowid,
           l_any_rows_to_process,
           l_batch_size,
           TRUE);
--
  while (l_any_rows_to_process = TRUE)
  loop
    --
    open csr_get_appl_with_no_notif(l_start_rowid,l_end_rowid);
      fetch csr_get_appl_with_no_notif bulk collect into l_person_ids
                                                        ,l_rowid
                                                        ,l_party_ids;

    l_rows_processed := csr_get_appl_with_no_notif%ROWCOUNT;

    close csr_get_appl_with_no_notif;
    --
    if(l_rows_processed > 0)
    then
      forall i in l_person_ids.first..l_person_ids.last
      --
        insert into irc_notification_preferences
        ( NOTIFICATION_PREFERENCE_ID
         ,PERSON_ID
         ,PARTY_ID
         ,MATCHING_JOBS
         ,MATCHING_JOB_FREQ
         ,RECEIVE_INFO_MAIL
         ,ALLOW_ACCESS
         ,LAST_UPDATE_DATE
         ,LAST_UPDATED_BY
         ,LAST_UPDATE_LOGIN
         ,CREATED_BY
         ,CREATION_DATE
         ,OBJECT_VERSION_NUMBER)
        values
        ( IRC_NOTIFICATION_PREFS_S.nextval
         ,l_person_ids(i)
         ,l_party_ids(i)
         ,'N'
         ,'1'
         ,'N'
         ,'Y'
         ,sysdate
         ,1
         ,null
         ,1
         ,sysdate
         ,1);
      --
      -- end FORALL
      --
    --
    commit;
    end if;
    --
    l_person_ids.delete;
    l_rowid.delete;
    l_party_ids.delete;
    --
    -- mark a range of rowids as processed
    --
    ad_parallel_updates_pkg.processed_rowid_range
    ( l_rows_processed
     ,l_end_rowid
    );
    --
    -- get new range of rowids
    --
    ad_parallel_updates_pkg.get_rowid_range
    ( l_start_rowid
     ,l_end_rowid
     ,l_any_rows_to_process
     ,l_batch_size
     ,FALSE
    );
    --
  end loop;
--
  end create_notification;
--
end irc_create_notification_pkg;

/

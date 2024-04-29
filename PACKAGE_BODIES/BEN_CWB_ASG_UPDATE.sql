--------------------------------------------------------
--  DDL for Package Body BEN_CWB_ASG_UPDATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CWB_ASG_UPDATE" as
/* $Header: bencwbau.pkb 120.9.12010000.2 2008/08/05 14:37:03 ubhat ship $ */
/* ===========================================================================+
 * Name
 *   Compensation Workbench Transaction Update Package
 * Purpose
 *   This package is used to insert record into ben_transaction table
 *   when performance rating or promotion details
 *   are updated on the Worksheet.
 *
 * Version Date        Author    Comment
 * -------+-----------+---------+----------------------------------------------
 * 115.0   15-Feb-2003 maagrawa   created
 * 115.1   05-Mar-2003 maagrawa   Added fnd_msg_pub.add to stack error msg.
 * 115.2   10-Mar-2003 maagrawa   Flex Errors thrown by AOL and HR are now
 *                                available in pl/sql error stack.
 * 115.3   20-Mar-2003 maagrawa   If Performance Type is not defined then
 *                                performance rating updates are done with
 *                                no events. (Enh 2847438).
 * 115.4   02-Apr-2003 maagrawa   Bug 2876281.
 *                                Mask the perf api error with user
 *                                friendly BEN error.
 * 115.5   12-Jan-2004 maagrawa   Global Budgeting Change.
 * 115.6   25-Mar-2004 maagrawa   Add a general message before the errors
 *                                received from HR apis for SS.
 * 115.7   29-Mar-2004 maagrawa   Update ben_cwb_person_info with perf/promo
 *                                ids when called from PP.
 * 115.8   25-May-2004 maagrawa   Splitting of perf/promo record and have
 *                                them  floating across plans.
 * 115.9   01-Jul-2004 maagrawa   Do not validate data in online mode.(Temp)
 * 115.10  14-Jul-2004 aprabhak   Added get_update_mode routine to get the
 *                                date track mode.
 * 115.11  07-Dec-2004 maagrawa   Error if perf date or promo date not defined.
 * 115.12  22-Dec-2004 steotia    Added create_audit_record and audit writing
 *                                functionality
 * 115.13  22-Dec-2004 steotia    Taking care of null emp_interview_typ_cd
 *                                Adding exception block to select stmts.
 * 115.14  03-Jan-2005 steotia    Bug 4083398 - no data found correction
 * 115.16  07-Jan-2005 steotia    Added SCL audit event for promotions.
 *                                Corrected cursor for promotions.
 * 115.17  11-Jan-2005 steotia    Writing fnd_user.employee_id
 * 115.18  02-Feb-2005 steotia    Bug 4150327
 * 115.19  10-Feb-2005 maagrawa   Pass group_pl_id as plan reference to
 *                                process_rating, process_promotions.
 * 115.20  20-Feb-2005 steotia    Performance improvement(audit):
 *                                Replacing select into by explicit cursors
 * 115.21  06-Apr-2005 steotia    Bugfix 4273451
 * 115.22  26-Sep-2005 steotia    Bugfix 4618895: Taking in 'PROCD' employees
 *                                also for audit.
 * 115.23  06-Oct-2005 steotia    Bugfix 4607721: Modified process_rating.
 * 115.24  19-Oct-2005 steotia    Bugfix 4607721: Corrected event comparison.
 * 115.25  27-Oct-2005 maagrawa   4704175. Removed to_date on attribute1.
 * 115.26  20-Dec-2005 maagrawa   Valid online changes only if the profile
 *                                BEN_CWB_ASG_PERF_VALIDATE is "Yes".
 * 115.27  16-Feb-2006 maagrawa   Null the new position id when job changes
 *                                with no position change and the employee
 *                                previously had a position.
 * 115.28  28-Mar-2006 maagrawa   PERF: SQL Repository changes.
 * 115.29  29-Mar-2006 maagrawa   Re-sync with R12 version.
 * 115.30  01-Aug-2006 maagrawa   3227317. If people group involved, call the
 *                                api to have group name appended.
 * 115.31  20-Sep-2006 steotia    5531065: Using Performance Overrides (but
 *                                only if used through SS)
 * 115.32  13-Jun-2008 sgnanama   7167952:Used substr in cursors c_job
 *                                c_grade and c_position
 * ==========================================================================+
 */

g_package  varchar2(80) := 'ben_cwb_asg_update.';
g_debug boolean := hr_utility.debug_enabled;
g_validate varchar2(30) := fnd_profile.value('BEN_CWB_ASG_PERF_VALIDATE');


FUNCTION get_update_mode(
  p_assignment_id  IN per_all_assignments_f.assignment_id%TYPE
 ,p_ovn            IN per_all_assignments_f.object_version_number%TYPE
 ,p_effective_date IN DATE
)
RETURN VARCHAR2
IS
  l_correction           boolean;
  l_update               boolean;
  l_update_override      boolean;
  l_update_change_insert boolean;

  l_datetrack_update_mode varchar2(100);

  l_validation_start_date date;
  l_validation_end_date date;

begin

  per_asg_shd.lck
    (p_effective_date        => p_effective_date
    ,p_datetrack_mode        => hr_api.g_correction
    ,p_assignment_id         => p_assignment_id
    ,p_object_version_number => p_ovn
    ,p_validation_start_date => l_validation_start_date
    ,p_validation_end_date   => l_validation_end_date);

  per_asg_shd.find_dt_upd_modes
      (p_effective_date       => p_effective_date
      ,p_base_key_value       => p_assignment_id
      ,p_correction           => l_correction
      ,p_update               => l_update
      ,p_update_override      => l_update_override
      ,p_update_change_insert => l_update_change_insert);

  if l_update then
      -- we can do an update
      l_datetrack_update_mode := hr_api.g_update;
    elsif l_update_change_insert then
      -- we can do an update change insert
      l_datetrack_update_mode := hr_api.g_update_change_insert;
    elsif (l_validation_start_date = p_effective_date) and
           l_correction then
      -- we can only perform a correction
      l_datetrack_update_mode := hr_api.g_correction;
    else
      -- we cannot perform an update due to a restriction within the APIs
      l_datetrack_update_mode := hr_api.g_update;
    end if;

  RETURN l_datetrack_update_mode;
END;






procedure delete_transaction
   (p_transaction_id in number
   ,p_transaction_type in varchar2) is
begin
  delete ben_transaction
  where transaction_id = p_transaction_id
  and   transaction_type = p_transaction_type;
end;
--
--
-- -------------------------------------------------------------------------
-- |-------------------------< create_audit_record_rating >-----------------|
-- -------------------------------------------------------------------------
--
-- Description
-- This is an internal procedure
--
 procedure create_audit_record_rating
         (p_txn_old          in        ben_transaction%rowtype
         ,p_group_pl_id      in        number
         ) is

   l_txn_new ben_transaction%rowtype;
   l_cwb_audit_id ben_cwb_audit.cwb_audit_id%type;
   l_object_version_number ben_cwb_audit.object_version_number%type;
   l_cd_meaning_old hr_lookups.meaning%type;
   l_cd_meaning_new hr_lookups.meaning%type;
   l_per_in_ler_id ben_per_in_ler.per_in_ler_id%type;
   l_pl_id ben_cwb_pl_dsgn.pl_id%type;
   l_lf_evt_ocrd_dt ben_cwb_pl_dsgn.lf_evt_ocrd_dt%type;
   l_person_id fnd_user.employee_id%type;
   --
   cursor c_per_in_ler is
       select inf.group_per_in_ler_id
             ,inf.group_pl_id pl_id
             ,inf.lf_evt_ocrd_dt
       from   ben_cwb_person_info inf
             ,ben_cwb_pl_dsgn pl
       where inf.assignment_id         = p_txn_old.transaction_id
       and   inf.group_pl_id           = p_group_pl_id
       and   inf.group_pl_id           = pl.pl_id
       and   inf.lf_evt_ocrd_dt        = pl.lf_evt_ocrd_dt
       and   pl.oipl_id                = -1
       and   to_char(pl.perf_revw_strt_dt,'yyyy/mm/dd') = p_txn_old.attribute1
       and   nvl(pl.emp_interview_typ_cd,'-1') = nvl(p_txn_old.attribute2,'-1');
    --
   cursor c_lookup(v_lookup_type varchar2
                  ,v_lookup_code varchar2) is
      select meaning
      from hr_lookups
      where lookup_type = v_lookup_type
      and   lookup_code = v_lookup_code;
   --
   cursor c_person_id
      (l_user_id fnd_user.employee_id%type) is
      select employee_id
      from fnd_user
      where user_id = l_user_id;
   --
   cursor c_collect_record_rating
      (p_assgn_id   number
      ,p_trans_type varchar2) is
      select *
      from ben_transaction
      where transaction_id = p_assgn_id
      and transaction_type = p_trans_type;
   --

   l_proc    varchar2(72) := g_package||'create_audit_record_rating';

   --
 begin
 --
  if g_debug then
     hr_utility.set_location('Entering:'|| l_proc,2);
     hr_utility.set_location('p_txn_old.attribute1: ' || p_txn_old.attribute1 , 3);
     hr_utility.set_location('p_txn_old.attribute2: ' || p_txn_old.attribute2, 5);
     hr_utility.set_location('p_txn_old.transaction_id: ' || p_txn_old.transaction_id, 6);
  end if;


  l_txn_new := null;
  open c_person_id(fnd_global.user_id);
  fetch c_person_id into l_person_id;
  close c_person_id;
  --
  open c_per_in_ler;
  fetch c_per_in_ler into l_per_in_ler_id, l_pl_id, l_lf_evt_ocrd_dt;
  close c_per_in_ler;
   --
  if g_debug then
     hr_utility.set_location('l_per_in_ler_id: ' || l_per_in_ler_id, 6);
     hr_utility.set_location('l_pl_id: ' || l_pl_id, 7);
     hr_utility.set_location('l_lf_evt_ocrd_dt: ' || l_lf_evt_ocrd_dt, 10);
  end if;

   begin
    select * into l_txn_new
    from ben_transaction
    where transaction_id = p_txn_old.transaction_id
    and transaction_type = p_txn_old.transaction_type;
    --
    if(  ((p_txn_old.attribute3 is null)
      and (l_txn_new.attribute3 is not null))
      or ((l_txn_new.attribute3 is null)
      and (p_txn_old.attribute3 is not null))
      or (p_txn_old.attribute3 <> l_txn_new.attribute3) ) then
     -- write the meaning
      open c_lookup('PERFORMANCE_RATING', p_txn_old.attribute3);
      fetch c_lookup into l_cd_meaning_old;
      close c_lookup;
      --
      open c_lookup('PERFORMANCE_RATING', l_txn_new.attribute3);
      fetch c_lookup into l_cd_meaning_new;
      close c_lookup;
      --
      --
      	if(ben_cwb_audit_api.return_lookup_validity('PR')=true) then
	 ben_cwb_audit_api.create_audit_entry
	    (p_group_per_in_ler_id      => l_per_in_ler_id
            ,p_group_pl_id              => l_pl_id
            ,p_lf_evt_ocrd_dt           => l_lf_evt_ocrd_dt
            ,p_pl_id                    => l_pl_id
            ,p_group_oipl_id            => -1
            ,p_audit_type_cd            => 'PR'
            ,p_old_val_varchar          => l_cd_meaning_old
            ,p_new_val_varchar          => l_cd_meaning_new
            ,p_date_stamp               => sysdate
            ,p_change_made_by_person_id => l_person_id
            ,p_cwb_audit_id             => l_cwb_audit_id
            ,p_object_version_number    => l_object_version_number
            );
        end if;
    end if;
   exception
   when no_data_found then
      if(p_txn_old.attribute3 is not null) then
     -- write the meaning
     open c_lookup('PERFORMANCE_RATING', p_txn_old.attribute3);
     fetch c_lookup into l_cd_meaning_old;
     close c_lookup;
      --
      l_cd_meaning_new := null;
      --
      --
      	if(ben_cwb_audit_api.return_lookup_validity('PR')=true) then
	 ben_cwb_audit_api.create_audit_entry
	    (p_group_per_in_ler_id      => l_per_in_ler_id
            ,p_group_pl_id              => l_pl_id
            ,p_lf_evt_ocrd_dt           => l_lf_evt_ocrd_dt
            ,p_pl_id                    => l_pl_id
            ,p_group_oipl_id            => -1
            ,p_audit_type_cd            => 'PR'
            ,p_old_val_varchar          => l_cd_meaning_old
            ,p_new_val_varchar          => l_cd_meaning_new
            ,p_date_stamp               => sysdate
            ,p_change_made_by_person_id => l_person_id
            ,p_cwb_audit_id             => l_cwb_audit_id
            ,p_object_version_number    => l_object_version_number
            );
        end if;
    end if;
   end;
   --
   --
end create_audit_record_rating;
--
--
-- ------------------------------------------------------------------------
-- |---------------------< create_audit_record_promotion >-----------------|
-- ------------------------------------------------------------------------
--
-- Description
-- This is an internal procedure
--
 procedure create_audit_record_promotion
         (p_txn_old          in        ben_transaction%rowtype
         ,p_group_pl_id      in        number
         ) is

   l_txn_new ben_transaction%rowtype; --- line 118 ---
   l_cwb_audit_id ben_cwb_audit.cwb_audit_id%type;
   l_object_version_number ben_cwb_audit.object_version_number%type;
   l_cd_meaning_old varchar2(240);
   l_cd_meaning_new varchar2(240);
   l_per_in_ler_id ben_per_in_ler.per_in_ler_id%type;
   l_pl_id ben_cwb_pl_dsgn.pl_id%type;
   l_lf_evt_ocrd_dt ben_cwb_pl_dsgn.lf_evt_ocrd_dt%type;
   l_lang varchar2(30);
   l_temp varchar2(30);
   l_person_id fnd_user.employee_id%type;

   --
     cursor c_per_in_ler is
       select inf.group_per_in_ler_id
             ,inf.group_pl_id pl_id
             ,inf.lf_evt_ocrd_dt
       from   ben_cwb_person_info inf
             ,ben_cwb_pl_dsgn pl
       where inf.assignment_id         = p_txn_old.transaction_id
       and   inf.group_pl_id           = p_group_pl_id
       and   inf.group_pl_id           = pl.pl_id
       and   inf.lf_evt_ocrd_dt        = pl.lf_evt_ocrd_dt
       and   pl.oipl_id                = -1
       and   to_char(pl.asg_updt_eff_date,'yyyy/mm/dd') = p_txn_old.attribute1;
   --
   cursor c_lookup(v_lookup_type varchar2
                  ,v_lookup_code varchar2) is
      select meaning
      from hr_lookups
      where lookup_type = v_lookup_type
      and   lookup_code = v_lookup_code;
   --
   cursor c_person_id is
      select employee_id
      from fnd_user
      where user_id = fnd_global.user_id;
   --
   cursor c_collect_record_promotions
      (v_assgn_id   number
      ,v_trans_type varchar2) is
      select *
      from ben_transaction
      where transaction_id = v_assgn_id
      and transaction_type = v_trans_type;
   --
   cursor c_job
      (v_job_id number
      ,v_lang   varchar2) is
      select substr(name,1,200)
      from per_jobs_tl
      where job_id = v_job_id
      and language = v_lang;
   --
   cursor c_grade
      (v_grade_id number
      ,v_lang     varchar2) is
      select substr(name,1,200)
      from per_grades_tl
      where grade_id = v_grade_id
      and language = v_lang;
   --
   cursor c_position
      (v_position_id number
      ,v_lang     varchar2) is
      select substr(name,1,200)
      from hr_all_positions_f_tl
      where position_id = v_position_id
      and language = l_lang;
   --

   l_proc    varchar2(72) := g_package||'create_audit_record_promotion';

 begin
 --
  if g_debug then
     hr_utility.set_location('Entering:'|| l_proc,2);
     hr_utility.set_location('p_txn_old.attribute1: ' || p_txn_old.attribute1 , 3);
     hr_utility.set_location('p_txn_old.attribute2: ' || p_txn_old.attribute2, 5);
     hr_utility.set_location('p_txn_old.transaction_id: ' || p_txn_old.transaction_id, 6);
  end if;

  l_txn_new := null;
  --
  open c_person_id;
  fetch c_person_id into l_person_id;
  close c_person_id;

  select userenv('LANG') into l_lang
  from dual;
  --
  open c_per_in_ler;
  fetch c_per_in_ler into l_per_in_ler_id, l_pl_id, l_lf_evt_ocrd_dt;
  close c_per_in_ler;
   --
  if g_debug then
     hr_utility.set_location('l_per_in_ler_id: ' || l_per_in_ler_id,6);
     hr_utility.set_location('l_pl_id: ' || l_pl_id,7);
     hr_utility.set_location('l_lf_evt_ocrd_dt: ' || l_lf_evt_ocrd_dt, 10);
  end if;

   begin
    select * into l_txn_new
    from ben_transaction
    where transaction_id = p_txn_old.transaction_id
    and transaction_type = p_txn_old.transaction_type;
    --
    if(  ((p_txn_old.attribute5 is null)
      and (l_txn_new.attribute5 is not null))
      or ((l_txn_new.attribute5 is null)
      and (p_txn_old.attribute5 is not null))
      or (p_txn_old.attribute5 <> l_txn_new.attribute5) ) then
     --
    open c_job(p_txn_old.attribute5,l_lang);
    fetch c_job into l_cd_meaning_old;
    close c_job;
    --
    open c_job(l_txn_new.attribute5,l_lang);
    fetch c_job into l_cd_meaning_new;
    close c_job;
    --
      --
      --
      	if(ben_cwb_audit_api.return_lookup_validity('JO')=true) then
	 ben_cwb_audit_api.create_audit_entry
	    (p_group_per_in_ler_id      => l_per_in_ler_id
            ,p_group_pl_id              => l_pl_id
            ,p_lf_evt_ocrd_dt           => l_lf_evt_ocrd_dt
            ,p_pl_id                    => l_pl_id
            ,p_group_oipl_id            => -1
            ,p_audit_type_cd            => 'JO'
            ,p_old_val_varchar          => l_cd_meaning_old
            ,p_new_val_varchar          => l_cd_meaning_new
            ,p_date_stamp               => sysdate
            ,p_change_made_by_person_id => l_person_id
            ,p_cwb_audit_id             => l_cwb_audit_id
            ,p_object_version_number    => l_object_version_number
            );
        end if;
    end if;
    --
     if(  ((p_txn_old.attribute3 is null)
      and (l_txn_new.attribute3 is not null))
      or ((l_txn_new.attribute3 is null)
      and (p_txn_old.attribute3 is not null))
      or (p_txn_old.attribute3 <> l_txn_new.attribute3) ) then
     --
      open c_lookup('EMP_ASSIGN_REASON', p_txn_old.attribute3);
      fetch c_lookup into l_cd_meaning_old;
      close c_lookup;
      --
      open c_lookup('EMP_ASSIGN_REASON', l_txn_new.attribute3);
      fetch c_lookup into l_cd_meaning_new;
      close c_lookup;
      --
      --
      	if(ben_cwb_audit_api.return_lookup_validity('CR')=true) then
	 ben_cwb_audit_api.create_audit_entry
	    (p_group_per_in_ler_id      => l_per_in_ler_id
            ,p_group_pl_id              => l_pl_id
            ,p_lf_evt_ocrd_dt           => l_lf_evt_ocrd_dt
            ,p_pl_id                    => l_pl_id
            ,p_group_oipl_id            => -1
            ,p_audit_type_cd            => 'CR'
            ,p_old_val_varchar          => l_cd_meaning_old
            ,p_new_val_varchar          => l_cd_meaning_new
            ,p_date_stamp               => sysdate
            ,p_change_made_by_person_id => l_person_id
            ,p_cwb_audit_id             => l_cwb_audit_id
            ,p_object_version_number    => l_object_version_number
            );
        end if;
    end if;
    --
     if(  ((p_txn_old.attribute7 is null)
      and (l_txn_new.attribute7 is not null))
      or ((l_txn_new.attribute7 is null)
      and (p_txn_old.attribute7 is not null))
      or (p_txn_old.attribute7 <> l_txn_new.attribute7) ) then
     --
     open c_grade(p_txn_old.attribute7,l_lang);
     fetch c_grade into l_cd_meaning_old;
     close c_grade;
     --
     open c_grade(l_txn_new.attribute7,l_lang);
     fetch c_grade into l_cd_meaning_new;
     close c_grade;
     --
      --
      --
      	if(ben_cwb_audit_api.return_lookup_validity('GR')=true) then
	 ben_cwb_audit_api.create_audit_entry
	    (p_group_per_in_ler_id      => l_per_in_ler_id
            ,p_group_pl_id              => l_pl_id
            ,p_lf_evt_ocrd_dt           => l_lf_evt_ocrd_dt
            ,p_pl_id                    => l_pl_id
            ,p_group_oipl_id            => -1
            ,p_audit_type_cd            => 'GR'
            ,p_old_val_varchar          => l_cd_meaning_old
            ,p_new_val_varchar          => l_cd_meaning_new
            ,p_date_stamp               => sysdate
            ,p_change_made_by_person_id => l_person_id
            ,p_cwb_audit_id             => l_cwb_audit_id
            ,p_object_version_number    => l_object_version_number
            );
        end if;
    end if;
    --
     if( ((p_txn_old.attribute8 is null)
      and (l_txn_new.attribute8 is not null))
      or ((l_txn_new.attribute8 is null)
      and (p_txn_old.attribute8 is not null))
      or (p_txn_old.attribute8 <> l_txn_new.attribute8) ) then
     --
        if(ben_cwb_audit_api.return_lookup_validity('PG')=true) then
	 ben_cwb_audit_api.create_audit_entry
	    (p_group_per_in_ler_id      => l_per_in_ler_id
            ,p_group_pl_id              => l_pl_id
            ,p_lf_evt_ocrd_dt           => l_lf_evt_ocrd_dt
            ,p_pl_id                    => l_pl_id
            ,p_group_oipl_id            => -1
            ,p_audit_type_cd            => 'PG'
            ,p_old_val_varchar          => p_txn_old.attribute8
            ,p_new_val_varchar          => l_txn_new.attribute8
            ,p_date_stamp               => sysdate
            ,p_change_made_by_person_id => l_person_id
            ,p_cwb_audit_id             => l_cwb_audit_id
            ,p_object_version_number    => l_object_version_number
            );
        end if;
    end if;
    if(  ((p_txn_old.attribute6 is null)
      and (l_txn_new.attribute6 is not null))
      or ((l_txn_new.attribute6 is null)
      and (p_txn_old.attribute6 is not null))
      or (p_txn_old.attribute6 <> l_txn_new.attribute6) ) then
     --
     open c_position(p_txn_old.attribute6,l_lang);
     fetch c_position into l_cd_meaning_old;
     close c_position;
     --
     open c_position(l_txn_new.attribute6,l_lang);
     fetch c_position into l_cd_meaning_new;
     close c_position;
     --
      --
      	if(ben_cwb_audit_api.return_lookup_validity('PO')=true) then
	 ben_cwb_audit_api.create_audit_entry
	    (p_group_per_in_ler_id      => l_per_in_ler_id
            ,p_group_pl_id              => l_pl_id
            ,p_lf_evt_ocrd_dt           => l_lf_evt_ocrd_dt
            ,p_pl_id                    => l_pl_id
            ,p_group_oipl_id            => -1
            ,p_audit_type_cd            => 'PO'
            ,p_old_val_varchar          => l_cd_meaning_old
            ,p_new_val_varchar          => l_cd_meaning_new
            ,p_date_stamp               => sysdate
            ,p_change_made_by_person_id => l_person_id
            ,p_cwb_audit_id             => l_cwb_audit_id
            ,p_object_version_number    => l_object_version_number
            );
        end if;
    end if;
     if( ((p_txn_old.attribute9 is null)
      and (l_txn_new.attribute9 is not null))
      or ((l_txn_new.attribute9 is null)
      and (p_txn_old.attribute9 is not null))
      or (p_txn_old.attribute9 <> l_txn_new.attribute9) ) then
     --
        if(ben_cwb_audit_api.return_lookup_validity('SCL')=true) then
	 ben_cwb_audit_api.create_audit_entry
	    (p_group_per_in_ler_id      => l_per_in_ler_id
            ,p_group_pl_id              => l_pl_id
            ,p_lf_evt_ocrd_dt           => l_lf_evt_ocrd_dt
            ,p_pl_id                    => l_pl_id
            ,p_group_oipl_id            => -1
            ,p_audit_type_cd            => 'SCL'
            ,p_old_val_varchar          => p_txn_old.attribute9
            ,p_new_val_varchar          => l_txn_new.attribute9
            ,p_date_stamp               => sysdate
            ,p_change_made_by_person_id => l_person_id
            ,p_cwb_audit_id             => l_cwb_audit_id
            ,p_object_version_number    => l_object_version_number
            );
        end if;
    end if;
     if( ((p_txn_old.attribute11 is null)
      and (l_txn_new.attribute11 is not null))
      or ((l_txn_new.attribute11 is null)
      and (p_txn_old.attribute11 is not null))
      or (p_txn_old.attribute11 <> l_txn_new.attribute11) ) then
     --
        if(ben_cwb_audit_api.return_lookup_validity('AF1')=true) then
	 ben_cwb_audit_api.create_audit_entry
	    (p_group_per_in_ler_id      => l_per_in_ler_id
            ,p_group_pl_id              => l_pl_id
            ,p_lf_evt_ocrd_dt           => l_lf_evt_ocrd_dt
            ,p_pl_id                    => l_pl_id
            ,p_group_oipl_id            => -1
            ,p_audit_type_cd            => 'AF1'
            ,p_old_val_varchar          => p_txn_old.attribute11
            ,p_new_val_varchar          => l_txn_new.attribute11
            ,p_date_stamp               => sysdate
            ,p_change_made_by_person_id => l_person_id
            ,p_cwb_audit_id             => l_cwb_audit_id
            ,p_object_version_number    => l_object_version_number
            );
        end if;
    end if;
     if( ((p_txn_old.attribute12 is null)
      and (l_txn_new.attribute12 is not null))
      or ((l_txn_new.attribute12 is null)
      and (p_txn_old.attribute12 is not null))
      or (p_txn_old.attribute12 <> l_txn_new.attribute12) ) then
     --
        if(ben_cwb_audit_api.return_lookup_validity('AF2')=true) then
	 ben_cwb_audit_api.create_audit_entry
	    (p_group_per_in_ler_id      => l_per_in_ler_id
            ,p_group_pl_id              => l_pl_id
            ,p_lf_evt_ocrd_dt           => l_lf_evt_ocrd_dt
            ,p_pl_id                    => l_pl_id
            ,p_group_oipl_id            => -1
            ,p_audit_type_cd            => 'AF2'
            ,p_old_val_varchar          => p_txn_old.attribute12
            ,p_new_val_varchar          => l_txn_new.attribute12
            ,p_date_stamp               => sysdate
            ,p_change_made_by_person_id => l_person_id
            ,p_cwb_audit_id             => l_cwb_audit_id
            ,p_object_version_number    => l_object_version_number
            );
        end if;
    end if;
     if( ((p_txn_old.attribute13 is null)
      and (l_txn_new.attribute13 is not null))
      or ((l_txn_new.attribute13 is null)
      and (p_txn_old.attribute13 is not null))
      or (p_txn_old.attribute13 <> l_txn_new.attribute13) ) then
     --
        if(ben_cwb_audit_api.return_lookup_validity('AF3')=true) then
	 ben_cwb_audit_api.create_audit_entry
	    (p_group_per_in_ler_id      => l_per_in_ler_id
            ,p_group_pl_id              => l_pl_id
            ,p_lf_evt_ocrd_dt           => l_lf_evt_ocrd_dt
            ,p_pl_id                    => l_pl_id
            ,p_group_oipl_id            => -1
            ,p_audit_type_cd            => 'AF3'
            ,p_old_val_varchar          => p_txn_old.attribute13
            ,p_new_val_varchar          => l_txn_new.attribute13
            ,p_date_stamp               => sysdate
            ,p_change_made_by_person_id => l_person_id
            ,p_cwb_audit_id             => l_cwb_audit_id
            ,p_object_version_number    => l_object_version_number
            );
        end if;
    end if;
     if( ((p_txn_old.attribute14 is null)
      and (l_txn_new.attribute14 is not null))
      or ((l_txn_new.attribute14 is null)
      and (p_txn_old.attribute14 is not null))
      or (p_txn_old.attribute14 <> l_txn_new.attribute14) ) then
     --
        if(ben_cwb_audit_api.return_lookup_validity('AF4')=true) then
	 ben_cwb_audit_api.create_audit_entry
	    (p_group_per_in_ler_id      => l_per_in_ler_id
            ,p_group_pl_id              => l_pl_id
            ,p_lf_evt_ocrd_dt           => l_lf_evt_ocrd_dt
            ,p_pl_id                    => l_pl_id
            ,p_group_oipl_id            => -1
            ,p_audit_type_cd            => 'AF4'
            ,p_old_val_varchar          => p_txn_old.attribute14
            ,p_new_val_varchar          => l_txn_new.attribute14
            ,p_date_stamp               => sysdate
            ,p_change_made_by_person_id => l_person_id
            ,p_cwb_audit_id             => l_cwb_audit_id
            ,p_object_version_number    => l_object_version_number
            );
        end if;
    end if;
     if( ((p_txn_old.attribute15 is null)
      and (l_txn_new.attribute15 is not null))
      or ((l_txn_new.attribute15 is null)
      and (p_txn_old.attribute15 is not null))
      or (p_txn_old.attribute15 <> l_txn_new.attribute15) ) then
     --
        if(ben_cwb_audit_api.return_lookup_validity('AF5')=true) then
	 ben_cwb_audit_api.create_audit_entry
	    (p_group_per_in_ler_id      => l_per_in_ler_id
            ,p_group_pl_id              => l_pl_id
            ,p_lf_evt_ocrd_dt           => l_lf_evt_ocrd_dt
            ,p_pl_id                    => l_pl_id
            ,p_group_oipl_id            => -1
            ,p_audit_type_cd            => 'AF5'
            ,p_old_val_varchar          => p_txn_old.attribute15
            ,p_new_val_varchar          => l_txn_new.attribute15
            ,p_date_stamp               => sysdate
            ,p_change_made_by_person_id => l_person_id
            ,p_cwb_audit_id             => l_cwb_audit_id
            ,p_object_version_number    => l_object_version_number
            );
        end if;
    end if;
     if( ((p_txn_old.attribute16 is null)
      and (l_txn_new.attribute16 is not null))
      or ((l_txn_new.attribute16 is null)
      and (p_txn_old.attribute16 is not null))
      or (p_txn_old.attribute16 <> l_txn_new.attribute16) ) then
     --
        if(ben_cwb_audit_api.return_lookup_validity('AF6')=true) then
	 ben_cwb_audit_api.create_audit_entry
	    (p_group_per_in_ler_id      => l_per_in_ler_id
            ,p_group_pl_id              => l_pl_id
            ,p_lf_evt_ocrd_dt           => l_lf_evt_ocrd_dt
            ,p_pl_id                    => l_pl_id
            ,p_group_oipl_id            => -1
            ,p_audit_type_cd            => 'AF6'
            ,p_old_val_varchar          => p_txn_old.attribute16
            ,p_new_val_varchar          => l_txn_new.attribute16
            ,p_date_stamp               => sysdate
            ,p_change_made_by_person_id => l_person_id
            ,p_cwb_audit_id             => l_cwb_audit_id
            ,p_object_version_number    => l_object_version_number
            );
        end if;
    end if;
     if( ((p_txn_old.attribute17 is null)
      and (l_txn_new.attribute17 is not null))
      or ((l_txn_new.attribute17 is null)
      and (p_txn_old.attribute17 is not null))
      or (p_txn_old.attribute17 <> l_txn_new.attribute17) ) then
     --
        if(ben_cwb_audit_api.return_lookup_validity('AF7')=true) then
	 ben_cwb_audit_api.create_audit_entry
	    (p_group_per_in_ler_id      => l_per_in_ler_id
            ,p_group_pl_id              => l_pl_id
            ,p_lf_evt_ocrd_dt           => l_lf_evt_ocrd_dt
            ,p_pl_id                    => l_pl_id
            ,p_group_oipl_id            => -1
            ,p_audit_type_cd            => 'AF7'
            ,p_old_val_varchar          => p_txn_old.attribute17
            ,p_new_val_varchar          => l_txn_new.attribute17
            ,p_date_stamp               => sysdate
            ,p_change_made_by_person_id => l_person_id
            ,p_cwb_audit_id             => l_cwb_audit_id
            ,p_object_version_number    => l_object_version_number
            );
        end if;
    end if;
     if( ((p_txn_old.attribute18 is null)
      and (l_txn_new.attribute18 is not null))
      or ((l_txn_new.attribute18 is null)
      and (p_txn_old.attribute18 is not null))
      or (p_txn_old.attribute18 <> l_txn_new.attribute18) ) then
     --
        if(ben_cwb_audit_api.return_lookup_validity('AF8')=true) then
	 ben_cwb_audit_api.create_audit_entry
	    (p_group_per_in_ler_id      => l_per_in_ler_id
            ,p_group_pl_id              => l_pl_id
            ,p_lf_evt_ocrd_dt           => l_lf_evt_ocrd_dt
            ,p_pl_id                    => l_pl_id
            ,p_group_oipl_id            => -1
            ,p_audit_type_cd            => 'AF8'
            ,p_old_val_varchar          => p_txn_old.attribute18
            ,p_new_val_varchar          => l_txn_new.attribute18
            ,p_date_stamp               => sysdate
            ,p_change_made_by_person_id => l_person_id
            ,p_cwb_audit_id             => l_cwb_audit_id
            ,p_object_version_number    => l_object_version_number
            );
        end if;
    end if;
     if( ((p_txn_old.attribute19 is null)
      and (l_txn_new.attribute19 is not null))
      or ((l_txn_new.attribute19 is null)
      and (p_txn_old.attribute19 is not null))
      or (p_txn_old.attribute19 <> l_txn_new.attribute19) ) then
     --
        if(ben_cwb_audit_api.return_lookup_validity('AF9')=true) then
	 ben_cwb_audit_api.create_audit_entry
	    (p_group_per_in_ler_id      => l_per_in_ler_id
            ,p_group_pl_id              => l_pl_id
            ,p_lf_evt_ocrd_dt           => l_lf_evt_ocrd_dt
            ,p_pl_id                    => l_pl_id
            ,p_group_oipl_id            => -1
            ,p_audit_type_cd            => 'AF9'
            ,p_old_val_varchar          => p_txn_old.attribute19
            ,p_new_val_varchar          => l_txn_new.attribute19
            ,p_date_stamp               => sysdate
            ,p_change_made_by_person_id => l_person_id
            ,p_cwb_audit_id             => l_cwb_audit_id
            ,p_object_version_number    => l_object_version_number
            );
        end if;
    end if;
     if( ((p_txn_old.attribute20 is null)
      and (l_txn_new.attribute20 is not null))
      or ((l_txn_new.attribute20 is null)
      and (p_txn_old.attribute20 is not null))
      or (p_txn_old.attribute20 <> l_txn_new.attribute20) ) then
     --
        if(ben_cwb_audit_api.return_lookup_validity('AF10')=true) then
	 ben_cwb_audit_api.create_audit_entry
	    (p_group_per_in_ler_id      => l_per_in_ler_id
            ,p_group_pl_id              => l_pl_id
            ,p_lf_evt_ocrd_dt           => l_lf_evt_ocrd_dt
            ,p_pl_id                    => l_pl_id
            ,p_group_oipl_id            => -1
            ,p_audit_type_cd            => 'AF10'
            ,p_old_val_varchar          => p_txn_old.attribute20
            ,p_new_val_varchar          => l_txn_new.attribute20
            ,p_date_stamp               => sysdate
            ,p_change_made_by_person_id => l_person_id
            ,p_cwb_audit_id             => l_cwb_audit_id
            ,p_object_version_number    => l_object_version_number
            );
        end if;
    end if;
     if( ((p_txn_old.attribute21 is null)
      and (l_txn_new.attribute21 is not null))
      or ((l_txn_new.attribute21 is null)
      and (p_txn_old.attribute21 is not null))
      or (p_txn_old.attribute21 <> l_txn_new.attribute21) ) then
     --
        if(ben_cwb_audit_api.return_lookup_validity('AF11')=true) then
	 ben_cwb_audit_api.create_audit_entry
	    (p_group_per_in_ler_id      => l_per_in_ler_id
            ,p_group_pl_id              => l_pl_id
            ,p_lf_evt_ocrd_dt           => l_lf_evt_ocrd_dt
            ,p_pl_id                    => l_pl_id
            ,p_group_oipl_id            => -1
            ,p_audit_type_cd            => 'AF11'
            ,p_old_val_varchar          => p_txn_old.attribute21
            ,p_new_val_varchar          => l_txn_new.attribute21
            ,p_date_stamp               => sysdate
            ,p_change_made_by_person_id => l_person_id
            ,p_cwb_audit_id             => l_cwb_audit_id
            ,p_object_version_number    => l_object_version_number
            );
        end if;
    end if;
     if( ((p_txn_old.attribute22 is null)
      and (l_txn_new.attribute22 is not null))
      or ((l_txn_new.attribute22 is null)
      and (p_txn_old.attribute22 is not null))
      or (p_txn_old.attribute22 <> l_txn_new.attribute22) ) then
     --
        if(ben_cwb_audit_api.return_lookup_validity('AF12')=true) then
	 ben_cwb_audit_api.create_audit_entry
	    (p_group_per_in_ler_id      => l_per_in_ler_id
            ,p_group_pl_id              => l_pl_id
            ,p_lf_evt_ocrd_dt           => l_lf_evt_ocrd_dt
            ,p_pl_id                    => l_pl_id
            ,p_group_oipl_id            => -1
            ,p_audit_type_cd            => 'AF12'
            ,p_old_val_varchar          => p_txn_old.attribute22
            ,p_new_val_varchar          => l_txn_new.attribute22
            ,p_date_stamp               => sysdate
            ,p_change_made_by_person_id => l_person_id
            ,p_cwb_audit_id             => l_cwb_audit_id
            ,p_object_version_number    => l_object_version_number
            );
        end if;
    end if;
     if( ((p_txn_old.attribute23 is null)
      and (l_txn_new.attribute23 is not null))
      or ((l_txn_new.attribute23 is null)
      and (p_txn_old.attribute23 is not null))
      or (p_txn_old.attribute23 <> l_txn_new.attribute23) ) then
     --
        if(ben_cwb_audit_api.return_lookup_validity('AF13')=true) then
	 ben_cwb_audit_api.create_audit_entry
	    (p_group_per_in_ler_id      => l_per_in_ler_id
            ,p_group_pl_id              => l_pl_id
            ,p_lf_evt_ocrd_dt           => l_lf_evt_ocrd_dt
            ,p_pl_id                    => l_pl_id
            ,p_group_oipl_id            => -1
            ,p_audit_type_cd            => 'AF13'
            ,p_old_val_varchar          => p_txn_old.attribute23
            ,p_new_val_varchar          => l_txn_new.attribute23
            ,p_date_stamp               => sysdate
            ,p_change_made_by_person_id => l_person_id
            ,p_cwb_audit_id             => l_cwb_audit_id
            ,p_object_version_number    => l_object_version_number
            );
        end if;
    end if;
     if( ((p_txn_old.attribute24 is null)
      and (l_txn_new.attribute24 is not null))
      or ((l_txn_new.attribute24 is null)
      and (p_txn_old.attribute24 is not null))
      or (p_txn_old.attribute24 <> l_txn_new.attribute24) ) then
     --
        if(ben_cwb_audit_api.return_lookup_validity('AF14')=true) then
	 ben_cwb_audit_api.create_audit_entry
	    (p_group_per_in_ler_id      => l_per_in_ler_id
            ,p_group_pl_id              => l_pl_id
            ,p_lf_evt_ocrd_dt           => l_lf_evt_ocrd_dt
            ,p_pl_id                    => l_pl_id
            ,p_group_oipl_id            => -1
            ,p_audit_type_cd            => 'AF14'
            ,p_old_val_varchar          => p_txn_old.attribute24
            ,p_new_val_varchar          => l_txn_new.attribute24
            ,p_date_stamp               => sysdate
            ,p_change_made_by_person_id => l_person_id
            ,p_cwb_audit_id             => l_cwb_audit_id
            ,p_object_version_number    => l_object_version_number
            );
        end if;
    end if;
     if( ((p_txn_old.attribute25 is null)
      and (l_txn_new.attribute25 is not null))
      or ((l_txn_new.attribute25 is null)
      and (p_txn_old.attribute25 is not null))
      or (p_txn_old.attribute25 <> l_txn_new.attribute25) ) then
     --
        if(ben_cwb_audit_api.return_lookup_validity('AF15')=true) then
	 ben_cwb_audit_api.create_audit_entry
	    (p_group_per_in_ler_id      => l_per_in_ler_id
            ,p_group_pl_id              => l_pl_id
            ,p_lf_evt_ocrd_dt           => l_lf_evt_ocrd_dt
            ,p_pl_id                    => l_pl_id
            ,p_group_oipl_id            => -1
            ,p_audit_type_cd            => 'AF15'
            ,p_old_val_varchar          => p_txn_old.attribute25
            ,p_new_val_varchar          => l_txn_new.attribute25
            ,p_date_stamp               => sysdate
            ,p_change_made_by_person_id => l_person_id
            ,p_cwb_audit_id             => l_cwb_audit_id
            ,p_object_version_number    => l_object_version_number
            );
        end if;
    end if;
     if( ((p_txn_old.attribute26 is null)
      and (l_txn_new.attribute26 is not null))
      or ((l_txn_new.attribute26 is null)
      and (p_txn_old.attribute26 is not null))
      or (p_txn_old.attribute26 <> l_txn_new.attribute26) ) then
     --
        if(ben_cwb_audit_api.return_lookup_validity('AF16')=true) then
	 ben_cwb_audit_api.create_audit_entry
	    (p_group_per_in_ler_id      => l_per_in_ler_id
            ,p_group_pl_id              => l_pl_id
            ,p_lf_evt_ocrd_dt           => l_lf_evt_ocrd_dt
            ,p_pl_id                    => l_pl_id
            ,p_group_oipl_id            => -1
            ,p_audit_type_cd            => 'AF16'
            ,p_old_val_varchar          => p_txn_old.attribute26
            ,p_new_val_varchar          => l_txn_new.attribute26
            ,p_date_stamp               => sysdate
            ,p_change_made_by_person_id => l_person_id
            ,p_cwb_audit_id             => l_cwb_audit_id
            ,p_object_version_number    => l_object_version_number
            );
        end if;
    end if;
     if( ((p_txn_old.attribute27 is null)
      and (l_txn_new.attribute27 is not null))
      or ((l_txn_new.attribute27 is null)
      and (p_txn_old.attribute27 is not null))
      or (p_txn_old.attribute27 <> l_txn_new.attribute27) ) then
     --
        if(ben_cwb_audit_api.return_lookup_validity('AF17')=true) then
	 ben_cwb_audit_api.create_audit_entry
	    (p_group_per_in_ler_id      => l_per_in_ler_id
            ,p_group_pl_id              => l_pl_id
            ,p_lf_evt_ocrd_dt           => l_lf_evt_ocrd_dt
            ,p_pl_id                    => l_pl_id
            ,p_group_oipl_id            => -1
            ,p_audit_type_cd            => 'AF17'
            ,p_old_val_varchar          => p_txn_old.attribute27
            ,p_new_val_varchar          => l_txn_new.attribute27
            ,p_date_stamp               => sysdate
            ,p_change_made_by_person_id => l_person_id
            ,p_cwb_audit_id             => l_cwb_audit_id
            ,p_object_version_number    => l_object_version_number
            );
        end if;
    end if;
     if( ((p_txn_old.attribute28 is null)
      and (l_txn_new.attribute28 is not null))
      or ((l_txn_new.attribute28 is null)
      and (p_txn_old.attribute28 is not null))
      or (p_txn_old.attribute28 <> l_txn_new.attribute28) ) then
     --
        if(ben_cwb_audit_api.return_lookup_validity('AF18')=true) then
	 ben_cwb_audit_api.create_audit_entry
	    (p_group_per_in_ler_id      => l_per_in_ler_id
            ,p_group_pl_id              => l_pl_id
            ,p_lf_evt_ocrd_dt           => l_lf_evt_ocrd_dt
            ,p_pl_id                    => l_pl_id
            ,p_group_oipl_id            => -1
            ,p_audit_type_cd            => 'AF18'
            ,p_old_val_varchar          => p_txn_old.attribute28
            ,p_new_val_varchar          => l_txn_new.attribute28
            ,p_date_stamp               => sysdate
            ,p_change_made_by_person_id => l_person_id
            ,p_cwb_audit_id             => l_cwb_audit_id
            ,p_object_version_number    => l_object_version_number
            );
        end if;
    end if;
     if( ((p_txn_old.attribute29 is null)
      and (l_txn_new.attribute29 is not null))
      or ((l_txn_new.attribute29 is null)
      and (p_txn_old.attribute29 is not null))
      or (p_txn_old.attribute29 <> l_txn_new.attribute29) ) then
     --
        if(ben_cwb_audit_api.return_lookup_validity('AF19')=true) then
	 ben_cwb_audit_api.create_audit_entry
	    (p_group_per_in_ler_id      => l_per_in_ler_id
            ,p_group_pl_id              => l_pl_id
            ,p_lf_evt_ocrd_dt           => l_lf_evt_ocrd_dt
            ,p_pl_id                    => l_pl_id
            ,p_group_oipl_id            => -1
            ,p_audit_type_cd            => 'AF19'
            ,p_old_val_varchar          => p_txn_old.attribute29
            ,p_new_val_varchar          => l_txn_new.attribute29
            ,p_date_stamp               => sysdate
            ,p_change_made_by_person_id => l_person_id
            ,p_cwb_audit_id             => l_cwb_audit_id
            ,p_object_version_number    => l_object_version_number
            );
        end if;
    end if;
     if( ((p_txn_old.attribute30 is null)
      and (l_txn_new.attribute30 is not null))
      or ((l_txn_new.attribute30 is null)
      and (p_txn_old.attribute30 is not null))
      or (p_txn_old.attribute30 <> l_txn_new.attribute30) ) then
     --
        if(ben_cwb_audit_api.return_lookup_validity('AF20')=true) then
	 ben_cwb_audit_api.create_audit_entry
	    (p_group_per_in_ler_id      => l_per_in_ler_id
            ,p_group_pl_id              => l_pl_id
            ,p_lf_evt_ocrd_dt           => l_lf_evt_ocrd_dt
            ,p_pl_id                    => l_pl_id
            ,p_group_oipl_id            => -1
            ,p_audit_type_cd            => 'AF20'
            ,p_old_val_varchar          => p_txn_old.attribute30
            ,p_new_val_varchar          => l_txn_new.attribute30
            ,p_date_stamp               => sysdate
            ,p_change_made_by_person_id => l_person_id
            ,p_cwb_audit_id             => l_cwb_audit_id
            ,p_object_version_number    => l_object_version_number
            );
        end if;
    end if;
     if( ((p_txn_old.attribute31 is null)
      and (l_txn_new.attribute31 is not null))
      or ((l_txn_new.attribute31 is null)
      and (p_txn_old.attribute31 is not null))
      or (p_txn_old.attribute31 <> l_txn_new.attribute31) ) then
     --
        if(ben_cwb_audit_api.return_lookup_validity('AF21')=true) then
	 ben_cwb_audit_api.create_audit_entry
	    (p_group_per_in_ler_id      => l_per_in_ler_id
            ,p_group_pl_id              => l_pl_id
            ,p_lf_evt_ocrd_dt           => l_lf_evt_ocrd_dt
            ,p_pl_id                    => l_pl_id
            ,p_group_oipl_id            => -1
            ,p_audit_type_cd            => 'AF21'
            ,p_old_val_varchar          => p_txn_old.attribute31
            ,p_new_val_varchar          => l_txn_new.attribute31
            ,p_date_stamp               => sysdate
            ,p_change_made_by_person_id => l_person_id
            ,p_cwb_audit_id             => l_cwb_audit_id
            ,p_object_version_number    => l_object_version_number
            );
        end if;
    end if;
     if( ((p_txn_old.attribute32 is null)
      and (l_txn_new.attribute32 is not null))
      or ((l_txn_new.attribute32 is null)
      and (p_txn_old.attribute32 is not null))
      or (p_txn_old.attribute32 <> l_txn_new.attribute32) ) then
     --
        if(ben_cwb_audit_api.return_lookup_validity('AF22')=true) then
	 ben_cwb_audit_api.create_audit_entry
	    (p_group_per_in_ler_id      => l_per_in_ler_id
            ,p_group_pl_id              => l_pl_id
            ,p_lf_evt_ocrd_dt           => l_lf_evt_ocrd_dt
            ,p_pl_id                    => l_pl_id
            ,p_group_oipl_id            => -1
            ,p_audit_type_cd            => 'AF22'
            ,p_old_val_varchar          => p_txn_old.attribute32
            ,p_new_val_varchar          => l_txn_new.attribute32
            ,p_date_stamp               => sysdate
            ,p_change_made_by_person_id => l_person_id
            ,p_cwb_audit_id             => l_cwb_audit_id
            ,p_object_version_number    => l_object_version_number
            );
        end if;
    end if;
     if( ((p_txn_old.attribute33 is null)
      and (l_txn_new.attribute33 is not null))
      or ((l_txn_new.attribute33 is null)
      and (p_txn_old.attribute33 is not null))
      or (p_txn_old.attribute33 <> l_txn_new.attribute33) ) then
     --
        if(ben_cwb_audit_api.return_lookup_validity('AF23')=true) then
	 ben_cwb_audit_api.create_audit_entry
	    (p_group_per_in_ler_id      => l_per_in_ler_id
            ,p_group_pl_id              => l_pl_id
            ,p_lf_evt_ocrd_dt           => l_lf_evt_ocrd_dt
            ,p_pl_id                    => l_pl_id
            ,p_group_oipl_id            => -1
            ,p_audit_type_cd            => 'AF23'
            ,p_old_val_varchar          => p_txn_old.attribute33
            ,p_new_val_varchar          => l_txn_new.attribute33
            ,p_date_stamp               => sysdate
            ,p_change_made_by_person_id => l_person_id
            ,p_cwb_audit_id             => l_cwb_audit_id
            ,p_object_version_number    => l_object_version_number
            );
        end if;
    end if;
     if( ((p_txn_old.attribute34 is null)
      and (l_txn_new.attribute34 is not null))
      or ((l_txn_new.attribute34 is null)
      and (p_txn_old.attribute34 is not null))
      or (p_txn_old.attribute34 <> l_txn_new.attribute34) ) then
     --
        if(ben_cwb_audit_api.return_lookup_validity('AF24')=true) then
	 ben_cwb_audit_api.create_audit_entry
	    (p_group_per_in_ler_id      => l_per_in_ler_id
            ,p_group_pl_id              => l_pl_id
            ,p_lf_evt_ocrd_dt           => l_lf_evt_ocrd_dt
            ,p_pl_id                    => l_pl_id
            ,p_group_oipl_id            => -1
            ,p_audit_type_cd            => 'AF24'
            ,p_old_val_varchar          => p_txn_old.attribute34
            ,p_new_val_varchar          => l_txn_new.attribute34
            ,p_date_stamp               => sysdate
            ,p_change_made_by_person_id => l_person_id
            ,p_cwb_audit_id             => l_cwb_audit_id
            ,p_object_version_number    => l_object_version_number
            );
        end if;
    end if;
     if( ((p_txn_old.attribute35 is null)
      and (l_txn_new.attribute35 is not null))
      or ((l_txn_new.attribute35 is null)
      and (p_txn_old.attribute35 is not null))
      or (p_txn_old.attribute35 <> l_txn_new.attribute35) ) then
     --
        if(ben_cwb_audit_api.return_lookup_validity('AF25')=true) then
	 ben_cwb_audit_api.create_audit_entry
	    (p_group_per_in_ler_id      => l_per_in_ler_id
            ,p_group_pl_id              => l_pl_id
            ,p_lf_evt_ocrd_dt           => l_lf_evt_ocrd_dt
            ,p_pl_id                    => l_pl_id
            ,p_group_oipl_id            => -1
            ,p_audit_type_cd            => 'AF25'
            ,p_old_val_varchar          => p_txn_old.attribute35
            ,p_new_val_varchar          => l_txn_new.attribute35
            ,p_date_stamp               => sysdate
            ,p_change_made_by_person_id => l_person_id
            ,p_cwb_audit_id             => l_cwb_audit_id
            ,p_object_version_number    => l_object_version_number
            );
        end if;
    end if;
     if( ((p_txn_old.attribute36 is null)
      and (l_txn_new.attribute36 is not null))
      or ((l_txn_new.attribute36 is null)
      and (p_txn_old.attribute36 is not null))
      or (p_txn_old.attribute36 <> l_txn_new.attribute36) ) then
     --
        if(ben_cwb_audit_api.return_lookup_validity('AF26')=true) then
	 ben_cwb_audit_api.create_audit_entry
	    (p_group_per_in_ler_id      => l_per_in_ler_id
            ,p_group_pl_id              => l_pl_id
            ,p_lf_evt_ocrd_dt           => l_lf_evt_ocrd_dt
            ,p_pl_id                    => l_pl_id
            ,p_group_oipl_id            => -1
            ,p_audit_type_cd            => 'AF26'
            ,p_old_val_varchar          => p_txn_old.attribute36
            ,p_new_val_varchar          => l_txn_new.attribute36
            ,p_date_stamp               => sysdate
            ,p_change_made_by_person_id => l_person_id
            ,p_cwb_audit_id             => l_cwb_audit_id
            ,p_object_version_number    => l_object_version_number
            );
        end if;
    end if;
     if( ((p_txn_old.attribute37 is null)
      and (l_txn_new.attribute37 is not null))
      or ((l_txn_new.attribute37 is null)
      and (p_txn_old.attribute37 is not null))
      or (p_txn_old.attribute37 <> l_txn_new.attribute37) ) then
     --
        if(ben_cwb_audit_api.return_lookup_validity('AF27')=true) then
	 ben_cwb_audit_api.create_audit_entry
	    (p_group_per_in_ler_id      => l_per_in_ler_id
            ,p_group_pl_id              => l_pl_id
            ,p_lf_evt_ocrd_dt           => l_lf_evt_ocrd_dt
            ,p_pl_id                    => l_pl_id
            ,p_group_oipl_id            => -1
            ,p_audit_type_cd            => 'AF27'
            ,p_old_val_varchar          => p_txn_old.attribute37
            ,p_new_val_varchar          => l_txn_new.attribute37
            ,p_date_stamp               => sysdate
            ,p_change_made_by_person_id => l_person_id
            ,p_cwb_audit_id             => l_cwb_audit_id
            ,p_object_version_number    => l_object_version_number
            );
        end if;
    end if;
     if( ((p_txn_old.attribute38 is null)
      and (l_txn_new.attribute38 is not null))
      or ((l_txn_new.attribute38 is null)
      and (p_txn_old.attribute38 is not null))
      or (p_txn_old.attribute38 <> l_txn_new.attribute38) ) then
     --
        if(ben_cwb_audit_api.return_lookup_validity('AF28')=true) then
	 ben_cwb_audit_api.create_audit_entry
	    (p_group_per_in_ler_id      => l_per_in_ler_id
            ,p_group_pl_id              => l_pl_id
            ,p_lf_evt_ocrd_dt           => l_lf_evt_ocrd_dt
            ,p_pl_id                    => l_pl_id
            ,p_group_oipl_id            => -1
            ,p_audit_type_cd            => 'AF28'
            ,p_old_val_varchar          => p_txn_old.attribute38
            ,p_new_val_varchar          => l_txn_new.attribute38
            ,p_date_stamp               => sysdate
            ,p_change_made_by_person_id => l_person_id
            ,p_cwb_audit_id             => l_cwb_audit_id
            ,p_object_version_number    => l_object_version_number
            );
        end if;
    end if;
     if( ((p_txn_old.attribute39 is null)
      and (l_txn_new.attribute39 is not null))
      or ((l_txn_new.attribute39 is null)
      and (p_txn_old.attribute39 is not null))
      or (p_txn_old.attribute39 <> l_txn_new.attribute39) ) then
     --
        if(ben_cwb_audit_api.return_lookup_validity('AF29')=true) then
	 ben_cwb_audit_api.create_audit_entry
	    (p_group_per_in_ler_id      => l_per_in_ler_id
            ,p_group_pl_id              => l_pl_id
            ,p_lf_evt_ocrd_dt           => l_lf_evt_ocrd_dt
            ,p_pl_id                    => l_pl_id
            ,p_group_oipl_id            => -1
            ,p_audit_type_cd            => 'AF29'
            ,p_old_val_varchar          => p_txn_old.attribute39
            ,p_new_val_varchar          => l_txn_new.attribute39
            ,p_date_stamp               => sysdate
            ,p_change_made_by_person_id => l_person_id
            ,p_cwb_audit_id             => l_cwb_audit_id
            ,p_object_version_number    => l_object_version_number
            );
        end if;
    end if;
     if( ((p_txn_old.attribute40 is null)
      and (l_txn_new.attribute40 is not null))
      or ((l_txn_new.attribute40 is null)
      and (p_txn_old.attribute40 is not null))
      or (p_txn_old.attribute40 <> l_txn_new.attribute40) ) then
     --
        if(ben_cwb_audit_api.return_lookup_validity('AF30')=true) then
	 ben_cwb_audit_api.create_audit_entry
	    (p_group_per_in_ler_id      => l_per_in_ler_id
            ,p_group_pl_id              => l_pl_id
            ,p_lf_evt_ocrd_dt           => l_lf_evt_ocrd_dt
            ,p_pl_id                    => l_pl_id
            ,p_group_oipl_id            => -1
            ,p_audit_type_cd            => 'AF30'
            ,p_old_val_varchar          => p_txn_old.attribute40
            ,p_new_val_varchar          => l_txn_new.attribute40
            ,p_date_stamp               => sysdate
            ,p_change_made_by_person_id => l_person_id
            ,p_cwb_audit_id             => l_cwb_audit_id
            ,p_object_version_number    => l_object_version_number
            );
        end if;
    end if;
   exception
   when no_data_found then
      l_cd_meaning_new := null;
      if(p_txn_old.attribute5 is not null) then
      --
      open c_job(p_txn_old.attribute5,l_lang);
      fetch c_job into l_cd_meaning_old;
      close c_job;
      --
      --
      	if(ben_cwb_audit_api.return_lookup_validity('JO')=true) then
	 ben_cwb_audit_api.create_audit_entry
	    (p_group_per_in_ler_id      => l_per_in_ler_id
            ,p_group_pl_id              => l_pl_id
            ,p_lf_evt_ocrd_dt           => l_lf_evt_ocrd_dt
            ,p_pl_id                    => l_pl_id
            ,p_group_oipl_id            => -1
            ,p_audit_type_cd            => 'JO'
            ,p_old_val_varchar          => l_cd_meaning_old
            ,p_new_val_varchar          => l_cd_meaning_new
            ,p_date_stamp               => sysdate
            ,p_change_made_by_person_id => l_person_id
            ,p_cwb_audit_id             => l_cwb_audit_id
            ,p_object_version_number    => l_object_version_number
            );
        end if;
    end if;
      if(p_txn_old.attribute3 is not null) then
     --
      open c_lookup('EMP_ASSIGN_REASON', p_txn_old.attribute3);
      fetch c_lookup into l_cd_meaning_old;
      close c_lookup;
      --
      --
      	if(ben_cwb_audit_api.return_lookup_validity('CR')=true) then
	 ben_cwb_audit_api.create_audit_entry
	    (p_group_per_in_ler_id      => l_per_in_ler_id
            ,p_group_pl_id              => l_pl_id
            ,p_lf_evt_ocrd_dt           => l_lf_evt_ocrd_dt
            ,p_pl_id                    => l_pl_id
            ,p_group_oipl_id            => -1
            ,p_audit_type_cd            => 'CR'
            ,p_old_val_varchar          => l_cd_meaning_old
            ,p_new_val_varchar          => l_cd_meaning_new
            ,p_date_stamp               => sysdate
            ,p_change_made_by_person_id => l_person_id
            ,p_cwb_audit_id             => l_cwb_audit_id
            ,p_object_version_number    => l_object_version_number
            );
        end if;
    end if;
    --
      if(p_txn_old.attribute7 is not null) then
     --
     open c_grade(p_txn_old.attribute7,l_lang);
     fetch c_grade into l_cd_meaning_old;
     close c_grade;
     --
      --
      --
      	if(ben_cwb_audit_api.return_lookup_validity('GR')=true) then
	 ben_cwb_audit_api.create_audit_entry
	    (p_group_per_in_ler_id      => l_per_in_ler_id
            ,p_group_pl_id              => l_pl_id
            ,p_lf_evt_ocrd_dt           => l_lf_evt_ocrd_dt
            ,p_pl_id                    => l_pl_id
            ,p_group_oipl_id            => -1
            ,p_audit_type_cd            => 'GR'
            ,p_old_val_varchar          => l_cd_meaning_old
            ,p_new_val_varchar          => l_cd_meaning_new
            ,p_date_stamp               => sysdate
            ,p_change_made_by_person_id => l_person_id
            ,p_cwb_audit_id             => l_cwb_audit_id
            ,p_object_version_number    => l_object_version_number
            );
        end if;
    end if;
    --
      if(p_txn_old.attribute8 is not null) then
     --
        if(ben_cwb_audit_api.return_lookup_validity('AF')=true) then
	 ben_cwb_audit_api.create_audit_entry
	    (p_group_per_in_ler_id      => l_per_in_ler_id
            ,p_group_pl_id              => l_pl_id
            ,p_lf_evt_ocrd_dt           => l_lf_evt_ocrd_dt
            ,p_pl_id                    => l_pl_id
            ,p_group_oipl_id            => -1
            ,p_audit_type_cd            => 'AF'
            ,p_old_val_varchar          => p_txn_old.attribute8
            ,p_new_val_varchar          => l_txn_new.attribute8
            ,p_date_stamp               => sysdate
            ,p_change_made_by_person_id => l_person_id
            ,p_cwb_audit_id             => l_cwb_audit_id
            ,p_object_version_number    => l_object_version_number
            );
        end if;
    end if;
    if(p_txn_old.attribute6 is not null) then
     --
     open c_position(p_txn_old.attribute6,l_lang);
     fetch c_position into l_cd_meaning_old;
     close c_position;
     --
      --
      --
      	if(ben_cwb_audit_api.return_lookup_validity('PO')=true) then
	 ben_cwb_audit_api.create_audit_entry
	    (p_group_per_in_ler_id      => l_per_in_ler_id
            ,p_group_pl_id              => l_pl_id
            ,p_lf_evt_ocrd_dt           => l_lf_evt_ocrd_dt
            ,p_pl_id                    => l_pl_id
            ,p_group_oipl_id            => -1
            ,p_audit_type_cd            => 'PO'
            ,p_old_val_varchar          => l_cd_meaning_old
            ,p_new_val_varchar          => l_cd_meaning_new
            ,p_date_stamp               => sysdate
            ,p_change_made_by_person_id => l_person_id
            ,p_cwb_audit_id             => l_cwb_audit_id
            ,p_object_version_number    => l_object_version_number
            );
        end if;
    end if;
    if(p_txn_old.attribute11 is not null) then
     --
        if(ben_cwb_audit_api.return_lookup_validity('AF1')=true) then
	 ben_cwb_audit_api.create_audit_entry
	    (p_group_per_in_ler_id      => l_per_in_ler_id
            ,p_group_pl_id              => l_pl_id
            ,p_lf_evt_ocrd_dt           => l_lf_evt_ocrd_dt
            ,p_pl_id                    => l_pl_id
            ,p_group_oipl_id            => -1
            ,p_audit_type_cd            => 'AF1'
            ,p_old_val_varchar          => p_txn_old.attribute11
            ,p_new_val_varchar          => l_txn_new.attribute11
            ,p_date_stamp               => sysdate
            ,p_change_made_by_person_id => l_person_id
            ,p_cwb_audit_id             => l_cwb_audit_id
            ,p_object_version_number    => l_object_version_number
            );
        end if;
    end if;
    if(p_txn_old.attribute12 is not null) then
     --
        if(ben_cwb_audit_api.return_lookup_validity('AF2')=true) then
	 ben_cwb_audit_api.create_audit_entry
	    (p_group_per_in_ler_id      => l_per_in_ler_id
            ,p_group_pl_id              => l_pl_id
            ,p_lf_evt_ocrd_dt           => l_lf_evt_ocrd_dt
            ,p_pl_id                    => l_pl_id
            ,p_group_oipl_id            => -1
            ,p_audit_type_cd            => 'AF2'
            ,p_old_val_varchar          => p_txn_old.attribute12
            ,p_new_val_varchar          => l_txn_new.attribute12
            ,p_date_stamp               => sysdate
            ,p_change_made_by_person_id => l_person_id
            ,p_cwb_audit_id             => l_cwb_audit_id
            ,p_object_version_number    => l_object_version_number
            );
        end if;
    end if;
    if(p_txn_old.attribute13 is not null) then
     --
        if(ben_cwb_audit_api.return_lookup_validity('AF3')=true) then
	 ben_cwb_audit_api.create_audit_entry
	    (p_group_per_in_ler_id      => l_per_in_ler_id
            ,p_group_pl_id              => l_pl_id
            ,p_lf_evt_ocrd_dt           => l_lf_evt_ocrd_dt
            ,p_pl_id                    => l_pl_id
            ,p_group_oipl_id            => -1
            ,p_audit_type_cd            => 'AF3'
            ,p_old_val_varchar          => p_txn_old.attribute13
            ,p_new_val_varchar          => l_txn_new.attribute13
            ,p_date_stamp               => sysdate
            ,p_change_made_by_person_id => l_person_id
            ,p_cwb_audit_id             => l_cwb_audit_id
            ,p_object_version_number    => l_object_version_number
            );
        end if;
    end if;
    if(p_txn_old.attribute14 is not null) then
     --
        if(ben_cwb_audit_api.return_lookup_validity('AF4')=true) then
	 ben_cwb_audit_api.create_audit_entry
	    (p_group_per_in_ler_id      => l_per_in_ler_id
            ,p_group_pl_id              => l_pl_id
            ,p_lf_evt_ocrd_dt           => l_lf_evt_ocrd_dt
            ,p_pl_id                    => l_pl_id
            ,p_group_oipl_id            => -1
            ,p_audit_type_cd            => 'AF4'
            ,p_old_val_varchar          => p_txn_old.attribute14
            ,p_new_val_varchar          => l_txn_new.attribute14
            ,p_date_stamp               => sysdate
            ,p_change_made_by_person_id => l_person_id
            ,p_cwb_audit_id             => l_cwb_audit_id
            ,p_object_version_number    => l_object_version_number
            );
        end if;
    end if;
    if(p_txn_old.attribute15 is not null) then
     --
        if(ben_cwb_audit_api.return_lookup_validity('AF5')=true) then
	 ben_cwb_audit_api.create_audit_entry
	    (p_group_per_in_ler_id      => l_per_in_ler_id
            ,p_group_pl_id              => l_pl_id
            ,p_lf_evt_ocrd_dt           => l_lf_evt_ocrd_dt
            ,p_pl_id                    => l_pl_id
            ,p_group_oipl_id            => -1
            ,p_audit_type_cd            => 'AF5'
            ,p_old_val_varchar          => p_txn_old.attribute15
            ,p_new_val_varchar          => l_txn_new.attribute15
            ,p_date_stamp               => sysdate
            ,p_change_made_by_person_id => l_person_id
            ,p_cwb_audit_id             => l_cwb_audit_id
            ,p_object_version_number    => l_object_version_number
            );
        end if;
    end if;
    if(p_txn_old.attribute16 is not null) then
     --
        if(ben_cwb_audit_api.return_lookup_validity('AF6')=true) then
	 ben_cwb_audit_api.create_audit_entry
	    (p_group_per_in_ler_id      => l_per_in_ler_id
            ,p_group_pl_id              => l_pl_id
            ,p_lf_evt_ocrd_dt           => l_lf_evt_ocrd_dt
            ,p_pl_id                    => l_pl_id
            ,p_group_oipl_id            => -1
            ,p_audit_type_cd            => 'AF6'
            ,p_old_val_varchar          => p_txn_old.attribute16
            ,p_new_val_varchar          => l_txn_new.attribute16
            ,p_date_stamp               => sysdate
            ,p_change_made_by_person_id => l_person_id
            ,p_cwb_audit_id             => l_cwb_audit_id
            ,p_object_version_number    => l_object_version_number
            );
        end if;
    end if;
    if(p_txn_old.attribute17 is not null) then
     --
        if(ben_cwb_audit_api.return_lookup_validity('AF7')=true) then
	 ben_cwb_audit_api.create_audit_entry
	    (p_group_per_in_ler_id      => l_per_in_ler_id
            ,p_group_pl_id              => l_pl_id
            ,p_lf_evt_ocrd_dt           => l_lf_evt_ocrd_dt
            ,p_pl_id                    => l_pl_id
            ,p_group_oipl_id            => -1
            ,p_audit_type_cd            => 'AF7'
            ,p_old_val_varchar          => p_txn_old.attribute17
            ,p_new_val_varchar          => l_txn_new.attribute17
            ,p_date_stamp               => sysdate
            ,p_change_made_by_person_id => l_person_id
            ,p_cwb_audit_id             => l_cwb_audit_id
            ,p_object_version_number    => l_object_version_number
            );
        end if;
    end if;
    if(p_txn_old.attribute18 is not null) then
     --
        if(ben_cwb_audit_api.return_lookup_validity('AF8')=true) then
	 ben_cwb_audit_api.create_audit_entry
	    (p_group_per_in_ler_id      => l_per_in_ler_id
            ,p_group_pl_id              => l_pl_id
            ,p_lf_evt_ocrd_dt           => l_lf_evt_ocrd_dt
            ,p_pl_id                    => l_pl_id
            ,p_group_oipl_id            => -1
            ,p_audit_type_cd            => 'AF8'
            ,p_old_val_varchar          => p_txn_old.attribute18
            ,p_new_val_varchar          => l_txn_new.attribute18
            ,p_date_stamp               => sysdate
            ,p_change_made_by_person_id => l_person_id
            ,p_cwb_audit_id             => l_cwb_audit_id
            ,p_object_version_number    => l_object_version_number
            );
        end if;
    end if;
    if(p_txn_old.attribute19 is not null) then
     --
        if(ben_cwb_audit_api.return_lookup_validity('AF9')=true) then
	 ben_cwb_audit_api.create_audit_entry
	    (p_group_per_in_ler_id      => l_per_in_ler_id
            ,p_group_pl_id              => l_pl_id
            ,p_lf_evt_ocrd_dt           => l_lf_evt_ocrd_dt
            ,p_pl_id                    => l_pl_id
            ,p_group_oipl_id            => -1
            ,p_audit_type_cd            => 'AF9'
            ,p_old_val_varchar          => p_txn_old.attribute19
            ,p_new_val_varchar          => l_txn_new.attribute19
            ,p_date_stamp               => sysdate
            ,p_change_made_by_person_id => l_person_id
            ,p_cwb_audit_id             => l_cwb_audit_id
            ,p_object_version_number    => l_object_version_number
            );
        end if;
    end if;
    if(p_txn_old.attribute20 is not null) then
     --
        if(ben_cwb_audit_api.return_lookup_validity('AF10')=true) then
	 ben_cwb_audit_api.create_audit_entry
	    (p_group_per_in_ler_id      => l_per_in_ler_id
            ,p_group_pl_id              => l_pl_id
            ,p_lf_evt_ocrd_dt           => l_lf_evt_ocrd_dt
            ,p_pl_id                    => l_pl_id
            ,p_group_oipl_id            => -1
            ,p_audit_type_cd            => 'AF10'
            ,p_old_val_varchar          => p_txn_old.attribute20
            ,p_new_val_varchar          => l_txn_new.attribute20
            ,p_date_stamp               => sysdate
            ,p_change_made_by_person_id => l_person_id
            ,p_cwb_audit_id             => l_cwb_audit_id
            ,p_object_version_number    => l_object_version_number
            );
        end if;
    end if;
    if(p_txn_old.attribute21 is not null) then
     --
        if(ben_cwb_audit_api.return_lookup_validity('AF11')=true) then
	 ben_cwb_audit_api.create_audit_entry
	    (p_group_per_in_ler_id      => l_per_in_ler_id
            ,p_group_pl_id              => l_pl_id
            ,p_lf_evt_ocrd_dt           => l_lf_evt_ocrd_dt
            ,p_pl_id                    => l_pl_id
            ,p_group_oipl_id            => -1
            ,p_audit_type_cd            => 'AF11'
            ,p_old_val_varchar          => p_txn_old.attribute21
            ,p_new_val_varchar          => l_txn_new.attribute21
            ,p_date_stamp               => sysdate
            ,p_change_made_by_person_id => l_person_id
            ,p_cwb_audit_id             => l_cwb_audit_id
            ,p_object_version_number    => l_object_version_number
            );
        end if;
    end if;
    if(p_txn_old.attribute22 is not null) then
     --
        if(ben_cwb_audit_api.return_lookup_validity('AF12')=true) then
	 ben_cwb_audit_api.create_audit_entry
	    (p_group_per_in_ler_id      => l_per_in_ler_id
            ,p_group_pl_id              => l_pl_id
            ,p_lf_evt_ocrd_dt           => l_lf_evt_ocrd_dt
            ,p_pl_id                    => l_pl_id
            ,p_group_oipl_id            => -1
            ,p_audit_type_cd            => 'AF12'
            ,p_old_val_varchar          => p_txn_old.attribute22
            ,p_new_val_varchar          => l_txn_new.attribute22
            ,p_date_stamp               => sysdate
            ,p_change_made_by_person_id => l_person_id
            ,p_cwb_audit_id             => l_cwb_audit_id
            ,p_object_version_number    => l_object_version_number
            );
        end if;
    end if;
    if(p_txn_old.attribute23 is not null) then
     --
        if(ben_cwb_audit_api.return_lookup_validity('AF13')=true) then
	 ben_cwb_audit_api.create_audit_entry
	    (p_group_per_in_ler_id      => l_per_in_ler_id
            ,p_group_pl_id              => l_pl_id
            ,p_lf_evt_ocrd_dt           => l_lf_evt_ocrd_dt
            ,p_pl_id                    => l_pl_id
            ,p_group_oipl_id            => -1
            ,p_audit_type_cd            => 'AF13'
            ,p_old_val_varchar          => p_txn_old.attribute23
            ,p_new_val_varchar          => l_txn_new.attribute23
            ,p_date_stamp               => sysdate
            ,p_change_made_by_person_id => l_person_id
            ,p_cwb_audit_id             => l_cwb_audit_id
            ,p_object_version_number    => l_object_version_number
            );
        end if;
    end if;
    if(p_txn_old.attribute24 is not null) then
     --
        if(ben_cwb_audit_api.return_lookup_validity('AF14')=true) then
	 ben_cwb_audit_api.create_audit_entry
	    (p_group_per_in_ler_id      => l_per_in_ler_id
            ,p_group_pl_id              => l_pl_id
            ,p_lf_evt_ocrd_dt           => l_lf_evt_ocrd_dt
            ,p_pl_id                    => l_pl_id
            ,p_group_oipl_id            => -1
            ,p_audit_type_cd            => 'AF14'
            ,p_old_val_varchar          => p_txn_old.attribute24
            ,p_new_val_varchar          => l_txn_new.attribute24
            ,p_date_stamp               => sysdate
            ,p_change_made_by_person_id => l_person_id
            ,p_cwb_audit_id             => l_cwb_audit_id
            ,p_object_version_number    => l_object_version_number
            );
        end if;
    end if;
    if(p_txn_old.attribute25 is not null) then
     --
        if(ben_cwb_audit_api.return_lookup_validity('AF15')=true) then
	 ben_cwb_audit_api.create_audit_entry
	    (p_group_per_in_ler_id      => l_per_in_ler_id
            ,p_group_pl_id              => l_pl_id
            ,p_lf_evt_ocrd_dt           => l_lf_evt_ocrd_dt
            ,p_pl_id                    => l_pl_id
            ,p_group_oipl_id            => -1
            ,p_audit_type_cd            => 'AF15'
            ,p_old_val_varchar          => p_txn_old.attribute25
            ,p_new_val_varchar          => l_txn_new.attribute25
            ,p_date_stamp               => sysdate
            ,p_change_made_by_person_id => l_person_id
            ,p_cwb_audit_id             => l_cwb_audit_id
            ,p_object_version_number    => l_object_version_number
            );
        end if;
    end if;
    if(p_txn_old.attribute26 is not null) then
     --
        if(ben_cwb_audit_api.return_lookup_validity('AF16')=true) then
	 ben_cwb_audit_api.create_audit_entry
	    (p_group_per_in_ler_id      => l_per_in_ler_id
            ,p_group_pl_id              => l_pl_id
            ,p_lf_evt_ocrd_dt           => l_lf_evt_ocrd_dt
            ,p_pl_id                    => l_pl_id
            ,p_group_oipl_id            => -1
            ,p_audit_type_cd            => 'AF16'
            ,p_old_val_varchar          => p_txn_old.attribute26
            ,p_new_val_varchar          => l_txn_new.attribute26
            ,p_date_stamp               => sysdate
            ,p_change_made_by_person_id => l_person_id
            ,p_cwb_audit_id             => l_cwb_audit_id
            ,p_object_version_number    => l_object_version_number
            );
        end if;
    end if;
    if(p_txn_old.attribute27 is not null) then
     --
        if(ben_cwb_audit_api.return_lookup_validity('AF17')=true) then
	 ben_cwb_audit_api.create_audit_entry
	    (p_group_per_in_ler_id      => l_per_in_ler_id
            ,p_group_pl_id              => l_pl_id
            ,p_lf_evt_ocrd_dt           => l_lf_evt_ocrd_dt
            ,p_pl_id                    => l_pl_id
            ,p_group_oipl_id            => -1
            ,p_audit_type_cd            => 'AF17'
            ,p_old_val_varchar          => p_txn_old.attribute27
            ,p_new_val_varchar          => l_txn_new.attribute27
            ,p_date_stamp               => sysdate
            ,p_change_made_by_person_id => l_person_id
            ,p_cwb_audit_id             => l_cwb_audit_id
            ,p_object_version_number    => l_object_version_number
            );
        end if;
    end if;
    if(p_txn_old.attribute28 is not null) then
     --
        if(ben_cwb_audit_api.return_lookup_validity('AF18')=true) then
	 ben_cwb_audit_api.create_audit_entry
	    (p_group_per_in_ler_id      => l_per_in_ler_id
            ,p_group_pl_id              => l_pl_id
            ,p_lf_evt_ocrd_dt           => l_lf_evt_ocrd_dt
            ,p_pl_id                    => l_pl_id
            ,p_group_oipl_id            => -1
            ,p_audit_type_cd            => 'AF18'
            ,p_old_val_varchar          => p_txn_old.attribute28
            ,p_new_val_varchar          => l_txn_new.attribute28
            ,p_date_stamp               => sysdate
            ,p_change_made_by_person_id => l_person_id
            ,p_cwb_audit_id             => l_cwb_audit_id
            ,p_object_version_number    => l_object_version_number
            );
        end if;
    end if;
    if(p_txn_old.attribute29 is not null) then
     --
        if(ben_cwb_audit_api.return_lookup_validity('AF19')=true) then
	 ben_cwb_audit_api.create_audit_entry
	    (p_group_per_in_ler_id      => l_per_in_ler_id
            ,p_group_pl_id              => l_pl_id
            ,p_lf_evt_ocrd_dt           => l_lf_evt_ocrd_dt
            ,p_pl_id                    => l_pl_id
            ,p_group_oipl_id            => -1
            ,p_audit_type_cd            => 'AF19'
            ,p_old_val_varchar          => p_txn_old.attribute29
            ,p_new_val_varchar          => l_txn_new.attribute29
            ,p_date_stamp               => sysdate
            ,p_change_made_by_person_id => l_person_id
            ,p_cwb_audit_id             => l_cwb_audit_id
            ,p_object_version_number    => l_object_version_number
            );
        end if;
    end if;
    if(p_txn_old.attribute30 is not null) then
     --
        if(ben_cwb_audit_api.return_lookup_validity('AF20')=true) then
	 ben_cwb_audit_api.create_audit_entry
	    (p_group_per_in_ler_id      => l_per_in_ler_id
            ,p_group_pl_id              => l_pl_id
            ,p_lf_evt_ocrd_dt           => l_lf_evt_ocrd_dt
            ,p_pl_id                    => l_pl_id
            ,p_group_oipl_id            => -1
            ,p_audit_type_cd            => 'AF20'
            ,p_old_val_varchar          => p_txn_old.attribute30
            ,p_new_val_varchar          => l_txn_new.attribute30
            ,p_date_stamp               => sysdate
            ,p_change_made_by_person_id => l_person_id
            ,p_cwb_audit_id             => l_cwb_audit_id
            ,p_object_version_number    => l_object_version_number
            );
        end if;
    end if;
    if(p_txn_old.attribute31 is not null) then
     --
        if(ben_cwb_audit_api.return_lookup_validity('AF21')=true) then
	 ben_cwb_audit_api.create_audit_entry
	    (p_group_per_in_ler_id      => l_per_in_ler_id
            ,p_group_pl_id              => l_pl_id
            ,p_lf_evt_ocrd_dt           => l_lf_evt_ocrd_dt
            ,p_pl_id                    => l_pl_id
            ,p_group_oipl_id            => -1
            ,p_audit_type_cd            => 'AF21'
            ,p_old_val_varchar          => p_txn_old.attribute31
            ,p_new_val_varchar          => l_txn_new.attribute31
            ,p_date_stamp               => sysdate
            ,p_change_made_by_person_id => l_person_id
            ,p_cwb_audit_id             => l_cwb_audit_id
            ,p_object_version_number    => l_object_version_number
            );
        end if;
    end if;
    if(p_txn_old.attribute32 is not null) then
     --
        if(ben_cwb_audit_api.return_lookup_validity('AF22')=true) then
	 ben_cwb_audit_api.create_audit_entry
	    (p_group_per_in_ler_id      => l_per_in_ler_id
            ,p_group_pl_id              => l_pl_id
            ,p_lf_evt_ocrd_dt           => l_lf_evt_ocrd_dt
            ,p_pl_id                    => l_pl_id
            ,p_group_oipl_id            => -1
            ,p_audit_type_cd            => 'AF22'
            ,p_old_val_varchar          => p_txn_old.attribute32
            ,p_new_val_varchar          => l_txn_new.attribute32
            ,p_date_stamp               => sysdate
            ,p_change_made_by_person_id => l_person_id
            ,p_cwb_audit_id             => l_cwb_audit_id
            ,p_object_version_number    => l_object_version_number
            );
        end if;
    end if;
    if(p_txn_old.attribute33 is not null) then
     --
        if(ben_cwb_audit_api.return_lookup_validity('AF23')=true) then
	 ben_cwb_audit_api.create_audit_entry
	    (p_group_per_in_ler_id      => l_per_in_ler_id
            ,p_group_pl_id              => l_pl_id
            ,p_lf_evt_ocrd_dt           => l_lf_evt_ocrd_dt
            ,p_pl_id                    => l_pl_id
            ,p_group_oipl_id            => -1
            ,p_audit_type_cd            => 'AF23'
            ,p_old_val_varchar          => p_txn_old.attribute33
            ,p_new_val_varchar          => l_txn_new.attribute33
            ,p_date_stamp               => sysdate
            ,p_change_made_by_person_id => l_person_id
            ,p_cwb_audit_id             => l_cwb_audit_id
            ,p_object_version_number    => l_object_version_number
            );
        end if;
    end if;
    if(p_txn_old.attribute34 is not null) then
     --
        if(ben_cwb_audit_api.return_lookup_validity('AF24')=true) then
	 ben_cwb_audit_api.create_audit_entry
	    (p_group_per_in_ler_id      => l_per_in_ler_id
            ,p_group_pl_id              => l_pl_id
            ,p_lf_evt_ocrd_dt           => l_lf_evt_ocrd_dt
            ,p_pl_id                    => l_pl_id
            ,p_group_oipl_id            => -1
            ,p_audit_type_cd            => 'AF24'
            ,p_old_val_varchar          => p_txn_old.attribute34
            ,p_new_val_varchar          => l_txn_new.attribute34
            ,p_date_stamp               => sysdate
            ,p_change_made_by_person_id => l_person_id
            ,p_cwb_audit_id             => l_cwb_audit_id
            ,p_object_version_number    => l_object_version_number
            );
        end if;
    end if;
    if(p_txn_old.attribute35 is not null) then
     --
        if(ben_cwb_audit_api.return_lookup_validity('AF25')=true) then
	 ben_cwb_audit_api.create_audit_entry
	    (p_group_per_in_ler_id      => l_per_in_ler_id
            ,p_group_pl_id              => l_pl_id
            ,p_lf_evt_ocrd_dt           => l_lf_evt_ocrd_dt
            ,p_pl_id                    => l_pl_id
            ,p_group_oipl_id            => -1
            ,p_audit_type_cd            => 'AF25'
            ,p_old_val_varchar          => p_txn_old.attribute35
            ,p_new_val_varchar          => l_txn_new.attribute35
            ,p_date_stamp               => sysdate
            ,p_change_made_by_person_id => l_person_id
            ,p_cwb_audit_id             => l_cwb_audit_id
            ,p_object_version_number    => l_object_version_number
            );
        end if;
    end if;
    if(p_txn_old.attribute36 is not null) then
     --
        if(ben_cwb_audit_api.return_lookup_validity('AF26')=true) then
	 ben_cwb_audit_api.create_audit_entry
	    (p_group_per_in_ler_id      => l_per_in_ler_id
            ,p_group_pl_id              => l_pl_id
            ,p_lf_evt_ocrd_dt           => l_lf_evt_ocrd_dt
            ,p_pl_id                    => l_pl_id
            ,p_group_oipl_id            => -1
            ,p_audit_type_cd            => 'AF26'
            ,p_old_val_varchar          => p_txn_old.attribute36
            ,p_new_val_varchar          => l_txn_new.attribute36
            ,p_date_stamp               => sysdate
            ,p_change_made_by_person_id => l_person_id
            ,p_cwb_audit_id             => l_cwb_audit_id
            ,p_object_version_number    => l_object_version_number
            );
        end if;
    end if;
    if(p_txn_old.attribute37 is not null) then
     --
        if(ben_cwb_audit_api.return_lookup_validity('AF27')=true) then
	 ben_cwb_audit_api.create_audit_entry
	    (p_group_per_in_ler_id      => l_per_in_ler_id
            ,p_group_pl_id              => l_pl_id
            ,p_lf_evt_ocrd_dt           => l_lf_evt_ocrd_dt
            ,p_pl_id                    => l_pl_id
            ,p_group_oipl_id            => -1
            ,p_audit_type_cd            => 'AF27'
            ,p_old_val_varchar          => p_txn_old.attribute37
            ,p_new_val_varchar          => l_txn_new.attribute37
            ,p_date_stamp               => sysdate
            ,p_change_made_by_person_id => l_person_id
            ,p_cwb_audit_id             => l_cwb_audit_id
            ,p_object_version_number    => l_object_version_number
            );
        end if;
    end if;
    if(p_txn_old.attribute38 is not null) then
     --
        if(ben_cwb_audit_api.return_lookup_validity('AF28')=true) then
	 ben_cwb_audit_api.create_audit_entry
	    (p_group_per_in_ler_id      => l_per_in_ler_id
            ,p_group_pl_id              => l_pl_id
            ,p_lf_evt_ocrd_dt           => l_lf_evt_ocrd_dt
            ,p_pl_id                    => l_pl_id
            ,p_group_oipl_id            => -1
            ,p_audit_type_cd            => 'AF28'
            ,p_old_val_varchar          => p_txn_old.attribute38
            ,p_new_val_varchar          => l_txn_new.attribute38
            ,p_date_stamp               => sysdate
            ,p_change_made_by_person_id => l_person_id
            ,p_cwb_audit_id             => l_cwb_audit_id
            ,p_object_version_number    => l_object_version_number
            );
        end if;
    end if;
    if(p_txn_old.attribute39 is not null) then
     --
        if(ben_cwb_audit_api.return_lookup_validity('AF29')=true) then
	 ben_cwb_audit_api.create_audit_entry
	    (p_group_per_in_ler_id      => l_per_in_ler_id
            ,p_group_pl_id              => l_pl_id
            ,p_lf_evt_ocrd_dt           => l_lf_evt_ocrd_dt
            ,p_pl_id                    => l_pl_id
            ,p_group_oipl_id            => -1
            ,p_audit_type_cd            => 'AF29'
            ,p_old_val_varchar          => p_txn_old.attribute39
            ,p_new_val_varchar          => l_txn_new.attribute39
            ,p_date_stamp               => sysdate
            ,p_change_made_by_person_id => l_person_id
            ,p_cwb_audit_id             => l_cwb_audit_id
            ,p_object_version_number    => l_object_version_number
            );
        end if;
    end if;
    if(p_txn_old.attribute40 is not null) then
     --
        if(ben_cwb_audit_api.return_lookup_validity('AF30')=true) then
	 ben_cwb_audit_api.create_audit_entry
	    (p_group_per_in_ler_id      => l_per_in_ler_id
            ,p_group_pl_id              => l_pl_id
            ,p_lf_evt_ocrd_dt           => l_lf_evt_ocrd_dt
            ,p_pl_id                    => l_pl_id
            ,p_group_oipl_id            => -1
            ,p_audit_type_cd            => 'AF30'
            ,p_old_val_varchar          => p_txn_old.attribute40
            ,p_new_val_varchar          => l_txn_new.attribute40
            ,p_date_stamp               => sysdate
            ,p_change_made_by_person_id => l_person_id
            ,p_cwb_audit_id             => l_cwb_audit_id
            ,p_object_version_number    => l_object_version_number
            );
        end if;
    end if;

   end;
   --
   --
end create_audit_record_promotion;
----------------------------------------------------

procedure insert_or_update_transaction
    (p_transaction_id      in number
    ,p_transaction_type    in varchar2
    ,p_txn_rec             in g_txn%rowtype) is
  cursor c_found is
     select txn.transaction_id
     from   ben_transaction txn
     where  txn.transaction_id = p_transaction_id
     and    txn.transaction_type = p_transaction_type;
  l_transaction_id number;
begin

  open  c_found;
  fetch c_found into l_transaction_id;
  close c_found;

  if l_transaction_id is null then
    insert into ben_transaction
        (transaction_id ,transaction_type
        ,attribute1 ,attribute2
        ,attribute3 ,attribute4
        ,attribute5 ,attribute6
        ,attribute7 ,attribute8
        ,attribute9 ,attribute10
        ,attribute11 ,attribute12
        ,attribute13 ,attribute14
        ,attribute15 ,attribute16
        ,attribute17 ,attribute18
        ,attribute19 ,attribute20
        ,attribute21 ,attribute22
        ,attribute23 ,attribute24
        ,attribute25 ,attribute26
        ,attribute27 ,attribute28
        ,attribute29 ,attribute30
        ,attribute31 ,attribute32
        ,attribute33 ,attribute34
        ,attribute35 ,attribute36
        ,attribute37 ,attribute38
        ,attribute39 ,attribute40)
    values
       (p_transaction_id ,p_transaction_type
       ,p_txn_rec.attribute1 ,p_txn_rec.attribute2
       ,p_txn_rec.attribute3 ,p_txn_rec.attribute4
       ,p_txn_rec.attribute5 ,p_txn_rec.attribute6
       ,p_txn_rec.attribute7 ,p_txn_rec.attribute8
       ,p_txn_rec.attribute9 ,p_txn_rec.attribute10
       ,p_txn_rec.attribute11 ,p_txn_rec.attribute12
       ,p_txn_rec.attribute13 ,p_txn_rec.attribute14
       ,p_txn_rec.attribute15 ,p_txn_rec.attribute16
       ,p_txn_rec.attribute17 ,p_txn_rec.attribute18
       ,p_txn_rec.attribute19 ,p_txn_rec.attribute20
       ,p_txn_rec.attribute21 ,p_txn_rec.attribute22
       ,p_txn_rec.attribute23 ,p_txn_rec.attribute24
       ,p_txn_rec.attribute25 ,p_txn_rec.attribute26
       ,p_txn_rec.attribute27 ,p_txn_rec.attribute28
       ,p_txn_rec.attribute29 ,p_txn_rec.attribute30
       ,p_txn_rec.attribute31 ,p_txn_rec.attribute32
       ,p_txn_rec.attribute33 ,p_txn_rec.attribute34
       ,p_txn_rec.attribute35 ,p_txn_rec.attribute36
       ,p_txn_rec.attribute37 ,p_txn_rec.attribute38
       ,p_txn_rec.attribute39 ,p_txn_rec.attribute40);
  else
    update ben_transaction
    set attribute1  = p_txn_rec.attribute1
       ,attribute2  = p_txn_rec.attribute2
       ,attribute3  = p_txn_rec.attribute3
       ,attribute4  = p_txn_rec.attribute4
       ,attribute5  = p_txn_rec.attribute5
       ,attribute6  = p_txn_rec.attribute6
       ,attribute7  = p_txn_rec.attribute7
       ,attribute8  = p_txn_rec.attribute8
       ,attribute9  = p_txn_rec.attribute9
       ,attribute10 = p_txn_rec.attribute10
       ,attribute11 = p_txn_rec.attribute11
       ,attribute12 = p_txn_rec.attribute12
       ,attribute13 = p_txn_rec.attribute13
       ,attribute14 = p_txn_rec.attribute14
       ,attribute15 = p_txn_rec.attribute15
       ,attribute16 = p_txn_rec.attribute16
       ,attribute17 = p_txn_rec.attribute17
       ,attribute18 = p_txn_rec.attribute18
       ,attribute19 = p_txn_rec.attribute19
       ,attribute20 = p_txn_rec.attribute20
       ,attribute21 = p_txn_rec.attribute21
       ,attribute22 = p_txn_rec.attribute22
       ,attribute23 = p_txn_rec.attribute23
       ,attribute24 = p_txn_rec.attribute24
       ,attribute25 = p_txn_rec.attribute25
       ,attribute26 = p_txn_rec.attribute26
       ,attribute27 = p_txn_rec.attribute27
       ,attribute28 = p_txn_rec.attribute28
       ,attribute29 = p_txn_rec.attribute29
       ,attribute30 = p_txn_rec.attribute30
       ,attribute31 = p_txn_rec.attribute31
       ,attribute32 = p_txn_rec.attribute32
       ,attribute33 = p_txn_rec.attribute33
       ,attribute34 = p_txn_rec.attribute34
       ,attribute35 = p_txn_rec.attribute35
       ,attribute36 = p_txn_rec.attribute36
       ,attribute37 = p_txn_rec.attribute37
       ,attribute38 = p_txn_rec.attribute38
       ,attribute39 = p_txn_rec.attribute39
       ,attribute40 = p_txn_rec.attribute40
    where transaction_id = p_transaction_id
    and   transaction_type = p_transaction_type;
  end if;
end insert_or_update_transaction;

procedure process_rating
    (p_validate_data          in varchar2 default 'Y'
    ,p_assignment_id          in number
    ,p_person_id              in number
    ,p_business_group_id      in number
    ,p_perf_revw_strt_dt      in varchar2
    ,p_perf_type              in varchar2
    ,p_perf_rating            in varchar2
    ,p_person_name            in varchar2
    ,p_update_person_id       in number
    ,p_update_date            in date
    ,p_group_pl_id            in number) is
  l_txn          g_txn%rowtype;
  l_process_status   varchar2(30)  := null;
  l_save_status      varchar2(30)  := null;

  ---- audit changes begin ------------------------------
  l_txn_record   ben_transaction%rowtype;
  cursor c_collect_record_rating
   (p_assgn_id number
   ,g_ws_perf_rec_typ varchar2
   ,p_perf_revw_dt varchar2
   ,p_perfor_type varchar2
    ) is
   select *
   from ben_transaction
   where transaction_id = p_assgn_id
   and transaction_type = g_ws_perf_rec_typ || p_perf_revw_dt || p_perfor_type;
  -------- end ------------------------------------------

  l_encoded_message    varchar2(2000);
  l_app_short_name     varchar2(2000);
  l_message_name       varchar2(2000);

begin
  --
  -- If Performance Start Date not defined, return with error.
  --
  if p_perf_revw_strt_dt is null then
     fnd_message.set_name ('BEN', 'BEN_93190_PERF_STRT_NOT_DFND');
     fnd_message.raise_error;
  end if;
  --

  ---- audit changes begin ------------------------------
  -------------------------------------------------------
  -- need of old record for writing into the audit log --
  -------------------------------------------------------
  open c_collect_record_rating(p_assignment_id,g_ws_perf_rec_type,p_perf_revw_strt_dt,p_perf_type);
  fetch c_collect_record_rating into l_txn_record;
  close c_collect_record_rating;
  -------- end ------------------------------------------

  if p_perf_rating is not null then
    null;
  else
    delete_transaction(p_transaction_id => p_assignment_id
                      ,p_transaction_type => g_ws_perf_rec_type||p_perf_revw_strt_dt||p_perf_type);

  ---- audit changes begin ------------------------------
  if(l_txn_record.transaction_id is not null) then
    create_audit_record_rating(l_txn_record,p_group_pl_id);
  end if;
  -------- end ------------------------------------------

    return;
  end if;

  l_txn.assignment_id := p_assignment_id;
  l_txn.attribute1    := p_perf_revw_strt_dt;
  l_txn.attribute2    := p_perf_type;
  l_txn.attribute3    := p_perf_rating;
  l_txn.attribute4    := to_char(p_update_date, 'yyyy/mm/dd');
  l_txn.attribute5    := p_update_person_id;

  if p_validate_data = 'Y' and g_validate = 'Y' then
    --
    savepoint ben_cwb_perf_upd_trans;

    l_save_status := 'PERF_STARTED';
    process_rating(p_person_id         => p_person_id
                  ,p_txn_rec           => l_txn
                  ,p_business_group_id => p_business_group_id
                  ,p_process_status    => l_process_status
                  ,p_effective_date    => to_date(p_perf_revw_strt_dt,'yyyy/mm/dd'));
    l_save_status := 'PERF_COMPLETE';

    rollback to ben_cwb_perf_upd_trans;
    l_save_status := null;
    --
  end if;
  --
  insert_or_update_transaction(p_transaction_id   => p_assignment_id
                              ,p_transaction_type => g_ws_perf_rec_type||p_perf_revw_strt_dt||p_perf_type
                              ,p_txn_rec          => l_txn);


  ---- audit changes begin ------------------------------
  if(l_txn_record.transaction_id is not null) then
    create_audit_record_rating(l_txn_record,p_group_pl_id);
  else
   l_txn_record.transaction_id   := p_assignment_id;
   l_txn_record.attribute1       := p_perf_revw_strt_dt;
   l_txn_record.attribute2       := p_perf_type;
   l_txn_record.transaction_type := (g_ws_perf_rec_type||p_perf_revw_strt_dt||p_perf_type);
   create_audit_record_rating(l_txn_record,p_group_pl_id);
  end if;
  -------- end ------------------------------------------

  --
exception
  when others then
    if l_save_status is not null then
      rollback to ben_cwb_perf_upd_trans;
    end if;
    --
    ben_on_line_lf_evt.get_ser_message
         (p_encoded_message => l_encoded_message,
          p_app_short_name  => l_app_short_name,
          p_message_name    => l_message_name);

    if l_message_name is null then
      fnd_message.set_name('PER','HR_ASG_PROCESS_API_ERROR');
      fnd_message.set_token('ERROR_MSG',substr(sqlerrm,1,1000));
    elsif l_save_status = 'PERF_STARTED' and
          l_message_name =  'HR_13000_SAL_DATE_NOT_UNIQUE' then
      l_encoded_message := fnd_message.get_encoded;
      fnd_message.set_name('BEN', 'BEN_93371_RATING_EXST_FOR_DATE');
    else
      l_encoded_message := fnd_message.get;
       fnd_message.set_name('BEN', 'BEN_93934_CWB_EMP_SAVE_API_ERR');
       fnd_message.set_token('NAME', p_person_name);
       fnd_message.set_token('MESSAGE', l_encoded_message);
    end if;
    fnd_msg_pub.add;

end process_rating;


procedure process_promotions
     (p_validate_data          in varchar2 default 'Y'
     ,p_assignment_id          in number
     ,p_person_id              in number
     ,p_business_group_id      in number
     ,p_asg_updt_eff_date      in varchar2
     ,p_change_reason          in varchar2
     ,p_job_id                 in number
     ,p_position_id            in number
     ,p_grade_id               in number
     ,p_people_group_id        in number
     ,p_soft_coding_keyflex_id in number
     ,p_ass_attribute1         in varchar2
     ,p_ass_attribute2         in varchar2
     ,p_ass_attribute3         in varchar2
     ,p_ass_attribute4         in varchar2
     ,p_ass_attribute5         in varchar2
     ,p_ass_attribute6         in varchar2
     ,p_ass_attribute7         in varchar2
     ,p_ass_attribute8         in varchar2
     ,p_ass_attribute9         in varchar2
     ,p_ass_attribute10        in varchar2
     ,p_ass_attribute11        in varchar2
     ,p_ass_attribute12        in varchar2
     ,p_ass_attribute13        in varchar2
     ,p_ass_attribute14        in varchar2
     ,p_ass_attribute15        in varchar2
     ,p_ass_attribute16        in varchar2
     ,p_ass_attribute17        in varchar2
     ,p_ass_attribute18        in varchar2
     ,p_ass_attribute19        in varchar2
     ,p_ass_attribute20        in varchar2
     ,p_ass_attribute21        in varchar2
     ,p_ass_attribute22        in varchar2
     ,p_ass_attribute23        in varchar2
     ,p_ass_attribute24        in varchar2
     ,p_ass_attribute25        in varchar2
     ,p_ass_attribute26        in varchar2
     ,p_ass_attribute27        in varchar2
     ,p_ass_attribute28        in varchar2
     ,p_ass_attribute29        in varchar2
     ,p_ass_attribute30        in varchar2
     ,p_person_name            in varchar2
     ,p_update_person_id       in number
     ,p_update_date            in date
     ,p_group_pl_id            in number) is
  l_txn          g_txn%rowtype;
  l_process_status   varchar2(30)  := null;
  l_save_status      varchar2(30)  := null;

  ---- audit changes begin ------------------------------
  l_txn_record   ben_transaction%rowtype;
  l_txn_record_n ben_transaction%rowtype;
  cursor c_collect_record_promotions
   (p_assgn_id number
   ,g_ws_perf_rec_typ varchar2
   ,p_asg_updt_eff_dt varchar2
    ) is
   select *
   from ben_transaction
   where transaction_id = p_assgn_id
   and transaction_type = g_ws_perf_rec_typ || p_asg_updt_eff_dt;

  -------- end ------------------------------------------


  l_encoded_message    varchar2(2000);
  l_app_short_name     varchar2(2000);
  l_message_name       varchar2(2000);

begin

  --
  -- If Assignment Update Date not defined, return with error.
  --
  if p_asg_updt_eff_date is null then
    fnd_message.set_name ('BEN', 'BEN_93191_PROMO_EFFDT_NOT_DFND');
    fnd_message.raise_error;
  end if;

  ---- audit changes begin ------------------------------
  -------------------------------------------------------
  -- need of old record for writing into the audit log --
  -------------------------------------------------------
  open c_collect_record_promotions(p_assignment_id,g_ws_asg_rec_type,p_asg_updt_eff_date);
  fetch c_collect_record_promotions into l_txn_record;
  close c_collect_record_promotions;
  -------- end ------------------------------------------


  if p_job_id          is not null or p_grade_id        is not null or
     p_position_id     is not null or p_change_reason   is not null or
     p_people_group_id is not null or p_soft_coding_keyflex_id is not null or
     p_ass_attribute1  is not null or p_ass_attribute2  is not null or
     p_ass_attribute3  is not null or p_ass_attribute4  is not null or
     p_ass_attribute5  is not null or p_ass_attribute6  is not null or
     p_ass_attribute7  is not null or p_ass_attribute8  is not null or
     p_ass_attribute9  is not null or p_ass_attribute10 is not null or
     p_ass_attribute11 is not null or p_ass_attribute12 is not null or
     p_ass_attribute13 is not null or p_ass_attribute14 is not null or
     p_ass_attribute15 is not null or p_ass_attribute16 is not null or
     p_ass_attribute17 is not null or p_ass_attribute18 is not null or
     p_ass_attribute19 is not null or p_ass_attribute20 is not null or
     p_ass_attribute21 is not null or p_ass_attribute22 is not null or
     p_ass_attribute23 is not null or p_ass_attribute24 is not null or
     p_ass_attribute25 is not null or p_ass_attribute26 is not null or
     p_ass_attribute27 is not null or p_ass_attribute28 is not null or
     p_ass_attribute29 is not null or p_ass_attribute30 is not null then
    null;
  else
    delete_transaction(p_transaction_id => p_assignment_id
                      ,p_transaction_type => g_ws_asg_rec_type||p_asg_updt_eff_date);

  ---- audit changes begin ------------------------------
  if(l_txn_record.transaction_id is not null) then
    create_audit_record_promotion(l_txn_record,p_group_pl_id);
  end if;
  -------- end ------------------------------------------

    return;
  end if;

  l_txn.assignment_id := p_assignment_id;
  l_txn.attribute1    := p_asg_updt_eff_date;
  l_txn.attribute3    := p_change_reason;
  l_txn.attribute5    := p_job_id;
  l_txn.attribute6    := p_position_id;
  l_txn.attribute7    := p_grade_id;
  l_txn.attribute8    := p_people_group_id;
  l_txn.attribute9    := p_soft_coding_keyflex_id;
  l_txn.attribute11   := p_ass_attribute1;
  l_txn.attribute12   := p_ass_attribute2;
  l_txn.attribute13   := p_ass_attribute3;
  l_txn.attribute14   := p_ass_attribute4;
  l_txn.attribute15   := p_ass_attribute5;
  l_txn.attribute16   := p_ass_attribute6;
  l_txn.attribute17   := p_ass_attribute7;
  l_txn.attribute18   := p_ass_attribute8;
  l_txn.attribute19   := p_ass_attribute9;
  l_txn.attribute20   := p_ass_attribute10;
  l_txn.attribute21   := p_ass_attribute11;
  l_txn.attribute22   := p_ass_attribute12;
  l_txn.attribute23   := p_ass_attribute13;
  l_txn.attribute24   := p_ass_attribute14;
  l_txn.attribute25   := p_ass_attribute15;
  l_txn.attribute26   := p_ass_attribute16;
  l_txn.attribute27   := p_ass_attribute17;
  l_txn.attribute28   := p_ass_attribute18;
  l_txn.attribute29   := p_ass_attribute19;
  l_txn.attribute30   := p_ass_attribute20;
  l_txn.attribute31   := p_ass_attribute21;
  l_txn.attribute32   := p_ass_attribute22;
  l_txn.attribute33   := p_ass_attribute23;
  l_txn.attribute34   := p_ass_attribute24;
  l_txn.attribute35   := p_ass_attribute25;
  l_txn.attribute36   := p_ass_attribute26;
  l_txn.attribute37   := p_ass_attribute27;
  l_txn.attribute38   := p_ass_attribute28;
  l_txn.attribute39   := p_ass_attribute29;
  l_txn.attribute40   := p_ass_attribute30;

  -- If people group is involved, always call the api as it
  -- will take care to append all the people group segments.
  -- If this procedure is not called in validation mode and
  -- as we are calling the api for people group only, do not
  -- show any errors as user is not expecting any now and would
  -- like to handle only in post-process (Bug 3227317).
  if (p_validate_data = 'Y' and g_validate = 'Y') or
      p_people_group_id is not null then
    --
    savepoint ben_cwb_asg_upd_trans;

    l_save_status := 'PROMO_STARTED';

    begin
    process_promotions(p_person_id    => p_person_id
                      ,p_asg_txn_rec => l_txn
                      ,p_business_group_id => p_business_group_id
                      ,p_process_status => l_process_status
                      ,p_effective_date => to_date(p_asg_updt_eff_date,'yyyy/mm/dd'));
    exception
      when others then
        if p_validate_data = 'Y' and g_validate = 'Y' then
          raise;
        end if;
    end;

    l_save_status := 'PROMO_COMPLETE';

    rollback to ben_cwb_asg_upd_trans;
    l_save_status := null;
    --
  end if;
  --
  insert_or_update_transaction(p_transaction_id   => p_assignment_id
                              ,p_transaction_type => g_ws_asg_rec_type||p_asg_updt_eff_date
                              ,p_txn_rec          => l_txn);

  ---- audit changes begin ------------------------------
  if(l_txn_record.transaction_id is not null) then
    create_audit_record_promotion(l_txn_record,p_group_pl_id);
  else
   l_txn_record.transaction_id   := p_assignment_id;
   l_txn_record.attribute1       := p_asg_updt_eff_date;
   l_txn_record.transaction_type := (g_ws_asg_rec_type||p_asg_updt_eff_date);
   create_audit_record_promotion(l_txn_record,p_group_pl_id);
  end if;
  -------- end ------------------------------------------

  --
exception
  when others then
    if l_save_status is not null then
      rollback to ben_cwb_asg_upd_trans;
    end if;
    --
    ben_on_line_lf_evt.get_ser_message
         (p_encoded_message => l_encoded_message,
          p_app_short_name  => l_app_short_name,
          p_message_name    => l_message_name);

    if l_message_name is null then
      fnd_message.set_name('PER','HR_ASG_PROCESS_API_ERROR');
      fnd_message.set_token('ERROR_MSG',substr(sqlerrm,1,1000));
    else
      l_encoded_message := fnd_message.get;
       fnd_message.set_name('BEN', 'BEN_93934_CWB_EMP_SAVE_API_ERR');
       fnd_message.set_token('NAME', p_person_name);
       fnd_message.set_token('MESSAGE', l_encoded_message);
    end if;
    fnd_msg_pub.add;

end process_promotions;


procedure process_rating
                  (p_person_id              in  number
                  ,p_txn_rec                in  g_txn%rowtype
                  ,p_business_group_id      in  number
                  ,p_audit_log              in  varchar2 default 'N'
                  ,p_process_status         in out nocopy varchar2
                  ,p_group_per_in_ler_id    in number default null
                  ,p_effective_date         in date) is
  l_proc                 varchar2(80) := g_package || '.process_rating';
  l_evt_ovn                  number;
  l_next_review_date_warning boolean;
  l_perf_date                date;
  l_event_id                 number;
  l_performance_review_id    number;
  l_perf_ovn                 number;
  l_update_event_id          number;
  l_update_review_id         number;
  l_event_type               varchar2(30);
  --
  cursor c_performance_id_in_db is
     select perf.performance_review_id
           ,perf.event_id
           ,perf.object_version_number
     from  per_performance_reviews perf
     where perf.person_id = p_person_id
     and   perf.review_date = l_perf_date;
  --
  cursor c_perf_id_attached_event_type is
     select evt.type
     from  per_events evt
     where evt.assignment_id = p_txn_rec.assignment_id
     and   evt.date_start <= l_perf_date
     and   evt.event_id = l_event_id;
  --
begin
  --
  hr_utility.set_location('Entering ' || l_proc, 5);
  l_event_type := null;
  --
  if (p_txn_rec.attribute1 is null or
      p_txn_rec.attribute3 is null) then
    hr_utility.set_location('No Processing returning ' || l_proc, 5);
    return;
  else
    l_perf_date := to_date(p_txn_rec.attribute1, 'yyyy/mm/dd');

    l_perf_date := p_effective_date;

    hr_utility.set_location('l_perf_date ' || l_perf_date, 10);

    open c_performance_id_in_db;
    fetch c_performance_id_in_db into l_performance_review_id, l_event_id, l_perf_ovn;
    close c_performance_id_in_db;

    if l_event_id is not null then
	open c_perf_id_attached_event_type;
	fetch c_perf_id_attached_event_type into l_event_type;
	close c_perf_id_attached_event_type;
    end if;

    hr_utility.set_location(l_performance_review_id||','||l_event_id||','||l_perf_date,15);
    hr_utility.set_location(l_event_type,16);
    hr_utility.set_location(p_txn_rec.attribute2,17);

    if(l_event_type is not null) then
	if (l_event_type <> nvl(p_txn_rec.attribute2,'-1')) then
    		hr_utility.set_location('Rating type mismatch '||l_event_type||'&'||p_txn_rec.attribute2, 20);
		fnd_message.set_name ('BEN', 'BEN_93371_RATING_EXST_FOR_DATE');
		fnd_message.raise_error;
	 end if;
    end if;

    if (p_txn_rec.attribute2 is not null and l_event_id is null) then
	if(l_performance_review_id is not null) then
		hr_utility.set_location('Not Creating Evt. Assign Id: ' ||p_txn_rec.assignment_id, 30);
		fnd_message.set_name ('BEN', 'BEN_93371_RATING_EXST_FOR_DATE');
		fnd_message.raise_error;
	else
		hr_utility.set_location('Creating Evt. Assign Id: ' ||p_txn_rec.assignment_id, 30);
   		per_events_api.create_event(
				 p_validate                    => false
				,p_date_start                 => l_perf_date
				,p_type                       => p_txn_rec.attribute2
				,p_business_group_id          => p_business_group_id
				,p_assignment_id              => p_txn_rec.assignment_id
				,p_emp_or_apl                 => 'E'
				,p_event_id                   => l_event_id
				,p_object_version_number      => l_evt_ovn);
	end if;
     end if;

     if(l_performance_review_id is not null) then
	hr_utility.set_location('Updating Review Record ', 40);
	hr_perf_review_api.update_perf_review(
		  p_validate                   => false
		 ,p_performance_review_id      => l_performance_review_id
	         ,p_performance_rating         => p_txn_rec.attribute3
	         ,p_object_version_number      => l_perf_ovn
	         ,p_next_review_date_warning   => l_next_review_date_warning);
     else
	if(l_event_id is not null) then
		hr_utility.set_location('Creating Review Record ', 40);
		hr_perf_review_api.create_perf_review(
			p_validate                   => false
		        ,p_performance_review_id      => l_performance_review_id
		        ,p_person_id                  => p_person_id
		        ,p_event_id                   => l_event_id
		        ,p_review_date                => l_perf_date
		        ,p_performance_rating         => p_txn_rec.attribute3
		        ,p_object_version_number      => l_perf_ovn
		        ,p_next_review_date_warning   => l_next_review_date_warning);
	else
		hr_utility.set_location('Creating Review Record with null event', 40);
		hr_perf_review_api.create_perf_review(
			 p_validate                   => false
		        ,p_performance_review_id      => l_performance_review_id
		        ,p_person_id                  => p_person_id
		        ,p_review_date                => l_perf_date
		        ,p_performance_rating         => p_txn_rec.attribute3
		        ,p_object_version_number      => l_perf_ovn
		        ,p_next_review_date_warning   => l_next_review_date_warning);
	end if;
     end if;
    end if;

   --
   if p_group_per_in_ler_id is not null then
     --
     update ben_cwb_person_info
     set    new_perf_event_id   = l_update_event_id,
            new_perf_review_id  = l_update_review_id
     where  group_per_in_ler_id = p_group_per_in_ler_id;
     --
   end if;
  --
  p_process_status := 'CWB_PERF_SUS';
  --
  hr_utility.set_location('Leaving ' || l_proc, 5);
  --
EXCEPTION
 WHEN OTHERS THEN
   p_process_status := null;
   raise;

end process_rating;

procedure process_promotions
                  (p_person_id              in  number
                  ,p_asg_txn_rec            in  g_txn%rowtype
                  ,p_business_group_id      in  number
                  ,p_audit_log              in  varchar2 default 'N'
                  ,p_process_status         in out nocopy varchar2
                  ,p_group_per_in_ler_id    in number default null
                  ,p_effective_date         in date) is
  --
  l_proc                 varchar2(80) := g_package || '.process_promotions';
  l_effective_date  date;
  l_assignment_id   number;
  l_datetrack_mode  varchar2(30);
  l_concat_segments hr_soft_coding_keyflex.concatenated_segments%TYPE;
  l_group_name      pay_people_groups.group_name%TYPE;
  l_comment_id      per_all_assignments_f.comment_id%TYPE;
  l_no_mgr_warning  boolean;
  l_othr_mgr_warning boolean;
  l_spp_delete_warning boolean;
  l_tax_dist_changed   boolean;
  l_entry_chg_warning  varchar2(30);
  l_scl_id             number;
  l_people_group_id    number;
  l_update_position_id number;
  l_update_done        boolean := false;
  --
  cursor c_asg is
     select asg.*
     from   per_all_assignments_f asg
     where  asg.assignment_id = l_assignment_id
     and    l_effective_date between
            asg.effective_start_date and asg.effective_end_date;
  l_asg_rec c_asg%rowtype;
  --
begin
  --
  hr_utility.set_location('Entering ' || l_proc, 5);
  --
  if p_asg_txn_rec.attribute1 is not null then
    l_effective_date := to_date(p_asg_txn_rec.attribute1, 'yyyy/mm/dd');
    l_assignment_id  := p_asg_txn_rec.assignment_id;
  end if;

    l_effective_date := p_effective_date;

  if l_effective_date is null or l_assignment_id is null then
    return;
  end if;

  open c_asg;
  fetch c_asg into l_asg_rec;
  close c_asg;

  l_people_group_id := nvl(p_asg_txn_rec.attribute8, l_asg_rec.people_group_id);
  l_scl_id          := nvl(p_asg_txn_rec.attribute9, l_asg_rec.soft_coding_keyflex_id);

  if p_asg_txn_rec.attribute3 is not null  or p_asg_txn_rec.attribute10 is not null or
     p_asg_txn_rec.attribute11 is not null or p_asg_txn_rec.attribute12 is not null or
     p_asg_txn_rec.attribute13 is not null or p_asg_txn_rec.attribute14 is not null or
     p_asg_txn_rec.attribute15 is not null or p_asg_txn_rec.attribute16 is not null or
     p_asg_txn_rec.attribute17 is not null or p_asg_txn_rec.attribute18 is not null or
     p_asg_txn_rec.attribute19 is not null or p_asg_txn_rec.attribute20 is not null or
     p_asg_txn_rec.attribute21 is not null or p_asg_txn_rec.attribute22 is not null or
     p_asg_txn_rec.attribute23 is not null or p_asg_txn_rec.attribute24 is not null or
     p_asg_txn_rec.attribute25 is not null or p_asg_txn_rec.attribute26 is not null or
     p_asg_txn_rec.attribute27 is not null or p_asg_txn_rec.attribute28 is not null or
     p_asg_txn_rec.attribute29 is not null or p_asg_txn_rec.attribute30 is not null or
     p_asg_txn_rec.attribute31 is not null or p_asg_txn_rec.attribute32 is not null or
     p_asg_txn_rec.attribute33 is not null or p_asg_txn_rec.attribute34 is not null or
     p_asg_txn_rec.attribute35 is not null or p_asg_txn_rec.attribute36 is not null or
     p_asg_txn_rec.attribute37 is not null or p_asg_txn_rec.attribute38 is not null or
     p_asg_txn_rec.attribute39 is not null or p_asg_txn_rec.attribute40 is not null or
     p_asg_txn_rec.attribute9 is not null then
    --
    hr_utility.set_location('Updating Assign Flex' , 30);
    /*if l_asg_rec.effective_start_date = l_effective_date then
      l_datetrack_mode := hr_api.g_correction;
    else
      l_datetrack_mode := hr_api.g_update;
    end if;*/

     l_datetrack_mode := get_update_mode(
                                p_assignment_id  => l_assignment_id
                               ,p_ovn            => l_asg_rec.object_version_number
                               ,p_effective_date => l_effective_date
                          );
    ben_batch_utils.WRITE('l_datetrack_mode '|| l_datetrack_mode);

    hr_assignment_api.update_emp_asg(
      p_validate                  => false
     ,p_effective_date            => l_effective_date
     ,p_datetrack_update_mode     => l_datetrack_mode
     ,p_assignment_id             => l_assignment_id
     ,p_object_version_number     => l_asg_rec.object_version_number
     ,p_change_reason             => nvl(p_asg_txn_rec.attribute3,
                                         l_asg_rec.change_reason)
     ,p_ass_attribute_category    => l_asg_rec.ass_attribute_category
     ,p_ass_attribute1            => nvl(p_asg_txn_rec.attribute11,
                                         l_asg_rec.ass_attribute1)
     ,p_ass_attribute2            => nvl(p_asg_txn_rec.attribute12,
                                         l_asg_rec.ass_attribute2)
     ,p_ass_attribute3            => nvl(p_asg_txn_rec.attribute13,
                                         l_asg_rec.ass_attribute3)
     ,p_ass_attribute4             => nvl(p_asg_txn_rec.attribute14,
                                          l_asg_rec.ass_attribute4)
     ,p_ass_attribute5             => nvl(p_asg_txn_rec.attribute15,
                                          l_asg_rec.ass_attribute5)
     ,p_ass_attribute6             => nvl(p_asg_txn_rec.attribute16,
                                          l_asg_rec.ass_attribute6)
     ,p_ass_attribute7                => nvl(p_asg_txn_rec.attribute17,
                                             l_asg_rec.ass_attribute7)
     ,p_ass_attribute8                => nvl(p_asg_txn_rec.attribute18,
                                             l_asg_rec.ass_attribute8)
     ,p_ass_attribute9                => nvl(p_asg_txn_rec.attribute19,
                                             l_asg_rec.ass_attribute9)
     ,p_ass_attribute10               => nvl(p_asg_txn_rec.attribute20,
                                             l_asg_rec.ass_attribute10)
     ,p_ass_attribute11               => nvl(p_asg_txn_rec.attribute21,
                                             l_asg_rec.ass_attribute11)
     ,p_ass_attribute12               => nvl(p_asg_txn_rec.attribute22,
                                             l_asg_rec.ass_attribute12)
     ,p_ass_attribute13               => nvl(p_asg_txn_rec.attribute23,
                                             l_asg_rec.ass_attribute13)
     ,p_ass_attribute14               => nvl(p_asg_txn_rec.attribute24,
                                             l_asg_rec.ass_attribute14)
     ,p_ass_attribute15               => nvl(p_asg_txn_rec.attribute25,
                                             l_asg_rec.ass_attribute15)
     ,p_ass_attribute16               => nvl(p_asg_txn_rec.attribute26,
                                             l_asg_rec.ass_attribute16)
     ,p_ass_attribute17               => nvl(p_asg_txn_rec.attribute27,
                                             l_asg_rec.ass_attribute17)
     ,p_ass_attribute18               => nvl(p_asg_txn_rec.attribute28,
                                             l_asg_rec.ass_attribute18)
     ,p_ass_attribute19               => nvl(p_asg_txn_rec.attribute29,
                                             l_asg_rec.ass_attribute19)
     ,p_ass_attribute20               => nvl(p_asg_txn_rec.attribute30,
                                             l_asg_rec.ass_attribute20)
     ,p_ass_attribute21               => nvl(p_asg_txn_rec.attribute31,
                                             l_asg_rec.ass_attribute21)
     ,p_ass_attribute22               => nvl(p_asg_txn_rec.attribute32,
                                             l_asg_rec.ass_attribute22)
     ,p_ass_attribute23               => nvl(p_asg_txn_rec.attribute33,
                                             l_asg_rec.ass_attribute23)
     ,p_ass_attribute24               => nvl(p_asg_txn_rec.attribute34,
                                             l_asg_rec.ass_attribute24)
     ,p_ass_attribute25               => nvl(p_asg_txn_rec.attribute35,
                                             l_asg_rec.ass_attribute25)
     ,p_ass_attribute26               => nvl(p_asg_txn_rec.attribute36,
                                             l_asg_rec.ass_attribute26)
     ,p_ass_attribute27               => nvl(p_asg_txn_rec.attribute37,
                                             l_asg_rec.ass_attribute27)
     ,p_ass_attribute28               => nvl(p_asg_txn_rec.attribute38,
                                             l_asg_rec.ass_attribute28)
     ,p_ass_attribute29               => nvl(p_asg_txn_rec.attribute39,
                                             l_asg_rec.ass_attribute29)
     ,p_ass_attribute30               => nvl(p_asg_txn_rec.attribute40,
                                             l_asg_rec.ass_attribute30)
     ,p_concatenated_segments         => l_concat_segments
     ,p_soft_coding_keyflex_id        => l_scl_id
     ,p_comment_id                    => l_comment_id
     ,p_effective_start_date          => l_asg_rec.effective_start_date
     ,p_effective_end_date            => l_asg_rec.effective_end_date
     ,p_no_managers_warning           => l_no_mgr_warning
     ,p_other_manager_warning         => l_othr_mgr_warning);
    --
    l_update_done := true;
    p_process_status := 'CWB_PROM_SUS';
    --
  end if;
  --
  if p_asg_txn_rec.attribute5  is not null or
     p_asg_txn_rec.attribute6  is not null or
     p_asg_txn_rec.attribute7  is not null or
     p_asg_txn_rec.attribute8  is not null then
    --
    hr_utility.set_location('Updating Job/Grade/Position People Group ', 40);
    --
    /*if l_asg_rec.effective_start_date = l_effective_date then
      l_datetrack_mode := hr_api.g_correction;
    else
      l_datetrack_mode := hr_api.g_update;
    end if;*/

    l_datetrack_mode := get_update_mode(
                                p_assignment_id  => l_assignment_id
                               ,p_ovn            => l_asg_rec.object_version_number
                               ,p_effective_date => l_effective_date
                          );
    ben_batch_utils.WRITE('l_datetrack_mode '|| l_datetrack_mode);

    --
    -- If the employee already had a position and the user changes only
    -- the job and does not change the position, then update the
    -- assignment with null position id as it would have resulted
    -- in invalid job/position combination.
    --
    if p_asg_txn_rec.attribute6 is null and
       l_asg_rec.position_id is not null and
       p_asg_txn_rec.attribute5 is not null then
      -- Shashank, please have a warning logged in post-process
      -- in this case.
      l_update_position_id := null;
    else
      l_update_position_id := nvl(p_asg_txn_rec.attribute6,
                                  l_asg_rec.position_id);
    end if;

    hr_assignment_api.update_emp_asg_criteria(
       p_validate                   => false
      ,p_effective_date             => l_effective_date
      ,p_datetrack_update_mode      => l_datetrack_mode
      ,p_assignment_id              => l_assignment_id
      ,p_object_version_number      => l_asg_rec.object_version_number
      ,p_grade_id                   => nvl(p_asg_txn_rec.attribute7,
                                           l_asg_rec.grade_id)
      ,p_position_id                => l_update_position_id
      ,p_job_id                     => nvl(p_asg_txn_rec.attribute5,
                                           l_asg_rec.job_id)
      ,p_special_ceiling_step_id    => l_asg_rec.special_ceiling_step_id
      ,p_group_name                 => l_group_name
      ,p_effective_start_date       => l_asg_rec.effective_start_date
      ,p_effective_end_date         => l_asg_rec.effective_end_date
      ,p_people_group_id            => l_people_group_id
      ,p_org_now_no_manager_warning => l_no_mgr_warning
      ,p_other_manager_warning      => l_othr_mgr_warning
      ,p_spp_delete_warning         => l_spp_delete_warning
      ,p_entries_changed_warning    => l_entry_chg_warning
      ,p_tax_district_changed_warning => l_tax_dist_changed);
    --
    l_update_done := true;
    p_process_status := 'CWB_PROM_SUS';
    --
  end if;
  --
  if p_group_per_in_ler_id is not null and l_update_done then
    --
    update ben_cwb_person_info
    set    new_assgn_ovn       = l_asg_rec.object_version_number
    where  group_per_in_ler_id = p_group_per_in_ler_id;
    --
  end if;
  --
  hr_utility.set_location('Leaving ' || l_proc, 5);
  --
  EXCEPTION
   WHEN OTHERS THEN
     p_process_status := null;
     raise;
end process_promotions;


end ben_cwb_asg_update;

/
